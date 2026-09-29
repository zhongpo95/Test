# 독립 Lua VM 여섯 개와 이벤트 큐로 좌표 전달 및 로컬 입력 분리를 검사한다.
import argparse
import importlib.util
import json
import math
import re
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.dont_write_bytecode = True


def boot_expression():
    script = (ROOT / 'war3map.j').read_text(encoding='utf8')
    expressions = re.findall(r'set result = EXExecuteScript\("([^"\n]+)"\)', script)
    assert len(expressions) == 1
    return expressions[0]


class Peer:
    def __init__(self, bus, me, missing_sync=False):
        self.bus, self.me = bus, me
        self.lua = bus.LuaRuntime(unpack_returned_tuples=True)
        self.triggers, self.timers, self.units = {}, {}, {}
        self.next_handle, self.unit_count = 10, 0
        self.context, self.selection = {}, None
        self.logs, self.orders, self.mouse_calls = [], [], 0
        self.mouse = (200 + me * 50, 400 - me * 30)
        self.throw_mouse = False
        j = self.lua.table()
        self.j = j
        bindings = {
            'GetLocalPlayer': lambda: me, 'GetPlayerId': lambda p: p, 'Player': lambda p: p,
            'GetPlayerSlotState': lambda p: 1, 'GetPlayerController': lambda p: 0,
            'DisplayTimedTextToPlayer': lambda p, x, y, duration, text: self.logs.append(text),
            'CreateTrigger': self.trigger, 'CreateTimer': self.timer,
            'TriggerAddAction': lambda t, cb: self.triggers[t]['actions'].append(cb),
            'TimerStart': self.timer_start, 'DestroyTimer': lambda t: self.timers.pop(t, None),
            'CreateUnit': self.unit, 'SetUnitX': lambda h, x: self.units[h].update(x=x),
            'SetUnitY': lambda h, y: self.units[h].update(y=y),
            'TriggerRegisterPlayerChatEvent': lambda t, *args: self.triggers[t].update(kind='chat'),
            'TriggerRegisterPlayerUnitEvent': lambda t, *args: self.triggers[t].update(kind='spell'),
            'GetTriggerPlayer': lambda: self.context['sender'],
            'GetEventPlayerChatString': lambda: self.context['chat'],
            'GetSpellAbilityId': lambda: 1093681994,
            'GetTriggerUnit': lambda: self.context['unit'],
            'GetOwningPlayer': lambda unit: self.units[unit]['owner'],
            'GetSpellTargetX': lambda: self.context['x'], 'GetSpellTargetY': lambda: self.context['y'],
            'ClearSelection': lambda: setattr(self, 'selection', None),
            'SelectUnit': lambda h, flag: setattr(self, 'selection', h),
            'GetWorldBounds': lambda: 999, 'CreateFogModifierRect': lambda *args: 998,
        }
        for name, value in bindings.items():
            j[name] = value
        for name in ('PlayerSlotState', 'MapControl', 'PlayerUnitEvent', 'FogState', 'CameraField', 'AllianceType'):
            j['Convert' + name] = lambda value: value
        for name in ('UnitAddAbility', 'SetUnitInvulnerable', 'SetUnitMoveSpeed', 'SetUnitScale',
                     'SetUnitPathing', 'FogModifierStart', 'PanCameraToTimed', 'SetCameraField', 'SetPlayerAlliance'):
            j[name] = lambda *args: None
        api = self.lua.table()
        api['DzGetMouseTerrainX'] = lambda: self.mouse[0] + 1
        api['DzGetMouseTerrainY'] = lambda: self.mouse[1] + 1
        if not missing_sync:
            api['DzTriggerRegisterSyncData'] = lambda t, prefix, flag: self.triggers[t].update(kind=prefix)
            api['DzGetTriggerSyncData'] = lambda: self.context['data']
            api['DzGetTriggerSyncPlayer'] = lambda: self.context['sender']
            api['DzSyncData'] = lambda prefix, data: bus.queue.append(('sync', me, prefix, data))
        message = self.lua.table(mouse=self.read_mouse, order_point=self.order)
        # Python 함수를 Lua 함수로 감싸 실제 type(function) 검사도 통과시킨다.
        wrap = self.lua.eval('function(f) return function(...) return f(...) end end')
        for table in (j, api, message):
            for key in list(table.keys()):
                table[key] = wrap(table[key])
        self.lua.globals().mock_modules = self.lua.table()
        for name, module in [('jass.common', j), ('jass.japi', api), ('jass.message', message)]:
            self.lua.globals().mock_modules[name] = module
        self.lua.globals().mock_log = self.logs.append
        self.lua.globals().mock_mouse_source = (ROOT / 'mouse_test.lua').read_text(encoding='utf8')
        self.lua.execute('''
            require = function(name)
                if name == 'mouse_test' then
                    if mouse_module then return mouse_module end
                    local fn, err = load(mock_mouse_source, '@mouse_test.lua')
                    assert(fn, err)
                    mouse_module = fn() or true
                    return mouse_module
                end
                assert(mock_modules[name], name)
                return mock_modules[name]
            end
            io.open = function() return {
                write = function(self, text) mock_log(text) end,
                flush = function() end
            } end
        ''')
        # 설치 DLL과 같은 return (...) 래퍼에서 실제 JASS 부팅 식을 실행한다.
        assert self.lua.execute('return (' + boot_expression() + ')') == 'MT LUA READY'

    def handle(self):
        self.next_handle += 1
        return self.next_handle

    def trigger(self):
        handle = self.handle()
        self.triggers[handle] = {'actions': [], 'kind': None}
        return handle

    def timer(self):
        return self.handle()

    def timer_start(self, timer, period, repeat, callback):
        self.timers[timer] = {'due': self.bus.time + period, 'period': period,
                              'repeat': repeat, 'callback': callback}

    def unit(self, player, kind, x, y, facing):
        self.unit_count += 1
        handle = 1000 + self.unit_count
        self.units[handle] = {'owner': player, 'x': x, 'y': y}
        return handle

    def read_mouse(self):
        self.mouse_calls += 1
        if self.throw_mouse:
            raise RuntimeError('injected mouse error')
        return self.mouse

    def order(self, order, x, y):
        assert order == 852066
        assert self.selection == 1002 + self.me * 4
        self.orders.append((order, x, y))
        self.bus.queue.append(('spell', self.me, self.selection, x, y))

    def fire(self, kind, context):
        self.context = context
        for trigger in self.triggers.values():
            if trigger['kind'] == kind:
                for action in trigger['actions']:
                    action()


class Bus:
    def __init__(self, runtime, missing_sync=False):
        self.LuaRuntime, self.time, self.queue = runtime, 0, []
        self.peers = [Peer(self, me, missing_sync) for me in range(6)]

    def flush(self):
        while self.queue:
            event = self.queue.pop(0)
            if event[0] == 'sync':
                _, sender, prefix, data = event
                for peer in self.peers:
                    peer.fire(prefix, {'sender': sender, 'data': data})
            else:
                _, sender, unit, x, y = event
                for peer in self.peers:
                    peer.fire('spell', {'sender': sender, 'unit': unit, 'x': x, 'y': y})

    def chat(self, sender, text):
        for peer in self.peers:
            peer.fire('chat', {'sender': sender, 'chat': text})
        self.flush()

    def advance(self, duration):
        end = self.time + duration
        while True:
            due = min((timer['due'] for peer in self.peers for timer in peer.timers.values()), default=math.inf)
            if due > end:
                break
            self.time = due
            for peer in self.peers:
                for handle, timer in list(peer.timers.items()):
                    if timer['due'] <= due + 1e-8:
                        timer['due'] += timer['period']
                        timer['callback']()
            self.flush()
        self.time = end


def binary_checks():
    spec = importlib.util.spec_from_file_location('builder', ROOT / 'build.py')
    builder = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(builder)
    data = builder.members()
    blob, pos = data['war3map.w3i'], 0

    def read(fmt):
        nonlocal pos
        values = struct.unpack_from('<' + fmt, blob, pos)
        pos += struct.calcsize('<' + fmt)
        return values

    def string():
        nonlocal pos
        end = blob.index(0, pos)
        result = blob[pos:end].decode('utf8')
        pos = end + 1
        return result

    assert read('III')[0] == 25
    assert string() == builder.TITLE
    for _ in range(3): string()
    read('8f')
    assert read('7I')[4:6] == (32, 32)
    assert read('c') == (b'L',)
    read('I')
    for _ in range(4): string()
    read('I')
    for _ in range(4): string()
    read('I3f4BI'); string(); read('c4B')
    assert read('I') == (6,)
    for player in range(6):
        assert read('4I') == (player, 1, 1, 1)
        string(); read('2f2I')
    assert read('I') == (6,)
    team_masks = []
    for player in range(6):
        flags, mask = read('2I')
        assert flags == 0 and mask == 1 << player
        assert string() == 'Tester team ' + str(player + 1)
        team_masks.append(mask)
    assert sum(team_masks) == 63 and len(set(team_masks)) == 6
    assert read('4I') == (0, 0, 0, 0) and pos == len(blob)
    script = data['war3map.j'].decode('utf8')
    assert 'call SetTeams(6)' in script and 'call SetPlayerTeam(Player(i), i)' in script
    assert len(data['war3map.w3e']) == 53 + 33 * 33 * 7
    assert len(data['war3map.wpm']) == 16 + 128 * 128
    # W3A를 별도 커서로 읽어 중력건과 같은 핵심 Channel 설정을 확인한다.
    blob, pos = data['war3map.w3a'], 0
    assert read('3I') == (1, 0, 1)
    assert read('8s') == (b'ANclA0CJ',)
    count = read('I')[0]
    mods = {}
    for _ in range(count):
        field = read('4s')[0].decode('ascii')
        kind, level, pointer = read('3I')
        value = string() if kind == 3 else read('f' if kind in (1, 2) else 'I')[0]
        assert read('4s') == (b'A0CJ',)
        mods[field] = value
    assert pos == len(blob)
    assert mods['Ncl2'] == 2 and mods['Ncl3'] == 1 and mods['Ncl6'] == 'innerfire'
    assert mods['Ncl1'] == 0 and mods['arng'] == 200000
    return 'W3I/W3E/WPM/W3A structure, six user slots and distinct lobby teams matching JASS passed'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--lupa-root', type=Path)
    parser.add_argument('--report', type=Path, required=True)
    args = parser.parse_args()
    if args.lupa_root:
        sys.path.insert(0, str(args.lupa_root))
    from lupa.lua53 import LuaRuntime, LuaSyntaxError
    results = [binary_checks()]
    probe = LuaRuntime()
    old_boot = "local ok, err = pcall(require, 'mouse_test'); if ok then return 'MT LUA READY' else return 'MT LUA ERROR ' .. tostring(err) end"
    try:
        probe.execute('return (' + old_boot + ')')
    except LuaSyntaxError:
        results.append('v002 boot syntax failure reproduced under EXExecuteScript return-expression wrapper')
    else:
        raise AssertionError('Old boot must fail before module initialization')
    probe.execute("require = function() error('injected module load failure') end")
    boot_error = probe.execute('return (' + boot_expression() + ')')
    assert boot_error.startswith('MT LUA ERROR ') and 'injected module load failure' in boot_error
    results.append('v003 boot expression parses and reports a module initialization error')
    bus = Bus(LuaRuntime)
    results.append('actual JASS boot expression initializes module, units and triggers in all six Lua VMs')
    bus.chat(0, '-mouse'); bus.advance(2)
    for peer in bus.peers:
        assert (peer.units[1003]['x'], peer.units[1003]['y']) == (200, 400)
        assert any('M ACK 6/6 PASS' in text for text in peer.logs)
        assert peer.mouse_calls == (1 if peer.me == 0 else 0)
    results.append('six VM mouse delivery, identical markers, 6/6 receipts, owner-only read passed')
    bus.chat(1, '-dz'); bus.advance(2)
    for peer in bus.peers:
        assert (peer.units[1007]['x'], peer.units[1007]['y']) == (251, 371)
        assert any('D ACK 6/6 PASS' in text for text in peer.logs)
    results.append('alternate Dz coordinates and six receipts passed')
    bus.queue.append(('sync', 2, 'MT003XY', '0|M|99|999|999')); bus.flush()
    bus.queue.append(('sync', 0, 'MT003XY', '0|M|1|999|999')); bus.flush()
    bus.queue.append(('sync', 0, 'MT003XY', '0|M|100|99999|999')); bus.flush()
    for peer in bus.peers:
        assert (peer.units[1003]['x'], peer.units[1003]['y']) == (200, 400)
    results.append('spoofed sender, stale sequence and out-of-bounds packet rejected')
    bus.peers[2].mouse = (math.nan, 0)
    bus.chat(2, '-mouse'); bus.advance(2)
    for peer in bus.peers:
        assert peer.units[1011]['x'] == -150
    results.append('NaN local coordinates blocked before shared mutation')
    bus.chat(3, '-order'); bus.advance(12)
    assert len(bus.peers[3].orders) == 100
    for peer in bus.peers:
        assert len(peer.orders) == (100 if peer.me == 3 else 0)
        assert peer.selection == 1001 + peer.me * 4
        assert (peer.units[1016]['x'], peer.units[1016]['y']) == (350, 310)
        assert not peer.timers
    bus.chat(3, '-status')
    assert all(any('O #100' in text and 'ACK 6/6 PASS' in text for text in peer.logs) for peer in bus.peers)
    results.append('100 owner-only point orders, all peer spell receipts, restored selection, timer cleanup passed')
    bus.chat(4, '-track'); bus.advance(2); bus.chat(4, '-stop'); bus.advance(1)
    assert all(not peer.timers for peer in bus.peers)
    results.append('shared stop terminates every peer timer')
    bus.peers[5].throw_mouse = True
    bus.chat(5, '-order'); bus.advance(12)
    assert not bus.peers[5].orders
    assert all(not peer.timers for peer in bus.peers)
    results.append('Lua mouse exception sends no order and does not leak shared timers')
    no_sync = Bus(LuaRuntime, missing_sync=True)
    no_sync.chat(0, '-mouse'); no_sync.advance(2)
    assert no_sync.peers[0].mouse_calls == 0
    no_sync.chat(0, '-local'); no_sync.advance(2)
    assert no_sync.peers[0].mouse_calls == 1
    results.append('missing sync API disables shared sampling while local diagnostic remains usable')
    report = {'lua': '5.3', 'peerVMs': 6, 'checks': results,
              'realGameTested': False, 'multiplayerTested': False,
              'limitation': 'Mocks cannot validate DLL behavior, engine order routing or real network timing.'}
    args.report.write_text(json.dumps(report, indent=2), encoding='utf8')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
