# GHJ 1.5의 Dz 지점 스킬 시전 경로를 기록하는 시험 맵을 만든다.
import argparse
import hashlib
import json
import struct
from pathlib import Path

from archive import Archive


BASE_SHA256 = '1c8ff203bfea4ca44cc16736703f47a6c50f2a83b6ea75ec31a6d4638c7924f7'
TITLE = b'GHJ 1.5 FIX TEST'
ACTION = 'scripts/gameplay/feature/shot/act.lua'
MOUSE = 'scripts/gameplay/hero/heroskill/mouseget.lua'
RUNTIME = 'scripts/gameplay/start/hero_select/runtime.lua'
TRACKED = 'id == "A0H2" or id == "A0KJ" or id == "A0KI"'


def replace_once(raw, old, new):
    old, new = old.encode('utf8'), new.encode('utf8')
    assert raw.count(old) == 1, (raw.count(old), old[:100])
    return raw.replace(old, new, 1)


def patched_action(raw):
    raw = replace_once(raw, 'local function has_selected_hero(sy)',
        'local dz_probe_count = 0\n'
        'GHJDzProbe = function(stage, detail)\n'
        '  if dz_probe_count >= 600 then return end\n'
        '  dz_probe_count = dz_probe_count + 1\n'
        '  pcall(function()\n'
        '    local slot = GetPlayerId(GetLocalPlayer()) + 1\n'
        '    local file = io.open("Logs/GHJ_DzSkills_p" .. slot .. ".txt", "a")\n'
        '    if file then\n'
        '      file:write(dz_probe_count .. " " .. stage .. " " .. tostring(detail) .. "\\n")\n'
        '      file:close()\n'
        '    end\n'
        '  end)\n'
        'end\n'
        'GHJDzProbe("LOAD", "GHJ 1.5 FIX TEST")\n\n'
        'local function has_selected_hero(sy)')
    raw = replace_once(raw,
        '    if unit ~= 0 and unit == Hero[id1] then\n'
        '      local u = getunit(unit)\n'
        '      if u:hasdata("弓箭系统-装备中") and code == 65 then\n'
        '        mouse.immediate(unit, YDWEAbilityId2OrderId("A0DL"))',
        '    if unit ~= 0 and unit == Hero[id1] then\n'
        '      local u = getunit(unit)\n'
        '      if code == 65 or code == 67 or code == 69 then\n'
        '        if u.type == HeroType["史尔特尔"] or u.type == HeroType["波风水门"] then\n'
        '          GHJDzProbe("KEY", "code=" .. tostring(code) .. " unit=" .. tostring(unit)\n'
        '            .. " combo=" .. tostring(u:getdata("42连携"))\n'
        '            .. " pause=" .. tostring(u:getdata("史尔特尔-连招暂停时间")))\n'
        '        end\n'
        '      end\n'
        '      if u:hasdata("弓箭系统-装备中") and code == 65 then\n'
        '        mouse.immediate(unit, YDWEAbilityId2OrderId("A0DL"))')
    raw = replace_once(raw,
        '            local id = type(ability) == "number" and ability > 0 and ID2S(ability) or type(ability) == "string" and ability or nil\n',
        '            local id = type(ability) == "number" and ability > 0 and ID2S(ability) or type(ability) == "string" and ability or nil\n'
        '            if ' + TRACKED + ' then\n'
        '              GHJDzProbe("BUTTON", "id=" .. id .. " pos=" .. x .. "," .. y\n'
        '                .. " order=" .. tostring(order) .. " target=" .. tostring(target_type)\n'
        '                .. " hotkey=" .. tostring(ability_data and ability_data.Hotkey)\n'
        '                .. " name=" .. tostring(ability_data and ability_data.Name))\n'
        '            end\n')
    raw = replace_once(raw,
        '              local ability_handle = japi.EXGetUnitAbility(unit, type(ability) == "string" and S2ID(ability) or ability)\n'
        '              if 0 < ability_handle and not is_cooling(ability_handle) then',
        '              local ability_handle = japi.EXGetUnitAbility(unit, type(ability) == "string" and S2ID(ability) or ability)\n'
        '              if ' + TRACKED + ' then\n'
        '                GHJDzProbe("MATCH", "id=" .. id .. " handle=" .. tostring(ability_handle)\n'
        '                  .. " cooldown=" .. tostring(ability_handle and ability_handle > 0 and is_cooling(ability_handle)))\n'
        '              end\n'
        '              if 0 < ability_handle and not is_cooling(ability_handle) then')
    return replace_once(raw,
        '  elseif target_type == 2 or target_type == 6 then\n'
        '    return IssuePointOrderById(unit, order, x, y)\n',
        '  elseif target_type == 2 or target_type == 6 then\n'
        '    local issued = IssuePointOrderById(unit, order, x, y)\n'
        '    if ' + TRACKED + ' then\n'
        '      GHJDzProbe("ISSUE_POINT", "id=" .. id .. " order=" .. tostring(order)\n'
        '        .. " issued=" .. tostring(issued))\n'
        '    end\n'
        '    if issued == false and target_type == 2 and slk.ability[id]\n'
        '        and slk.ability[id].code == "ANcl" then\n'
        '      local u = getunit(unit)\n'
        '      local listeners = u.trigger and u.trigger["单位-发动技能"]\n'
        '      if not listeners or #listeners == 0 then return false end\n'
        '      local cd = tonumber(slk.ability[id].Cool1) or 0\n'
        '      if cd > 0 then japi.EXSetAbilityState(ability_handle, 1, cd) end\n'
        '      local args = {unit=unit, skill=ability, x=x, y=y}\n'
        '      for _, listener in ipairs(listeners) do listener(args) end\n'
        '      if ' + TRACKED + ' then GHJDzProbe("FALLBACK", id) end\n'
        '      return true\n'
        '    end\n'
        '    return issued\n')


def patched_mouse(raw):
    raw = replace_once(raw,
        '  cast_sequence = cast_sequence + 1\n'
        '  japi.DzSyncData(cast_prefix, table.concat({unit, cast_sequence, ability, order, target_type,',
        '  cast_sequence = cast_sequence + 1\n'
        '  if GHJDzProbe and (ability == S2ID("A0H2") or ability == S2ID("A0KJ")\n'
        '      or ability == S2ID("A0KI")) then\n'
        '    GHJDzProbe("SEND", "id=" .. ID2S(ability) .. " order=" .. tostring(order)\n'
        '      .. " x=" .. tostring(x) .. " y=" .. tostring(y))\n'
        '  end\n'
        '  japi.DzSyncData(cast_prefix, table.concat({unit, cast_sequence, ability, order, target_type,')
    raw = replace_once(raw,
        '    tonumber(ability), tonumber(order), tonumber(target_type), tonumber(target)\n'
        '  local x, y = tonumber(xs), tonumber(ys)\n'
        '  local sender = japi.DzGetTriggerSyncPlayer()',
        '    tonumber(ability), tonumber(order), tonumber(target_type), tonumber(target)\n'
        '  local x, y = tonumber(xs), tonumber(ys)\n'
        '  if GHJDzProbe and (ability == S2ID("A0H2") or ability == S2ID("A0KJ")\n'
        '      or ability == S2ID("A0KI")) then GHJDzProbe("RECV", payload) end\n'
        '  local sender = japi.DzGetTriggerSyncPlayer()')
    return replace_once(raw,
        '  cast_received[sy] = seq\n'
        '  M.cast_action(hero, ability_handle, order, target_type, x, y, target, kind)',
        '  cast_received[sy] = seq\n'
        '  if GHJDzProbe and (ability == S2ID("A0H2") or ability == S2ID("A0KJ")\n'
        '      or ability == S2ID("A0KI")) then GHJDzProbe("ACCEPT", ID2S(ability)) end\n'
        '  M.cast_action(hero, ability_handle, order, target_type, x, y, target, kind)')


def patched_runtime(raw):
    return replace_once(raw,
        '  u:addtrgevent("单位-发动技能", function(args)\n    gunskilltrg(args)\n  end)',
        '  u:addtrgevent("单位-发动技能", function(args)\n'
        '    if GHJDzProbe and (args.skill == S2ID("A0H2") or args.skill == S2ID("A0KJ")\n'
        '        or args.skill == S2ID("A0KI")) then GHJDzProbe("SPELL", ID2S(args.skill)) end\n'
        '    gunskilltrg(args)\n'
        '  end)')


def build(source, output):
    assert not output.exists(), 'output already exists'
    data = source.read_bytes()
    assert hashlib.sha256(data).hexdigest() == BASE_SHA256, 'unexpected GHJ 1.5 baseline'
    archive = Archive(data)
    prefix = data[:archive.base]
    title_end = prefix.index(b'\0', 8)
    assert prefix[:4] == b'HM3W' and prefix[8:title_end] == b'GHJ 1.5'

    changes = {
        ACTION: patched_action(archive.read(ACTION)),
        MOUSE: patched_mouse(archive.read(MOUSE)),
        RUNTIME: patched_runtime(archive.read(RUNTIME)),
    }
    info = archive.read('war3map.w3i')
    info_end = info.index(b'\0', 12)
    assert struct.unpack_from('<I', info)[0] == 25 and info[12:info_end] == b'GHJ 1.5'
    changes['war3map.w3i'] = info[:12] + TITLE + info[info_end:]
    changes['war3map.j'] = replace_once(
        archive.read('war3map.j'), 'call SetMapName("GHJ 1.5")', 'call SetMapName("GHJ 1.5 FIX TEST")'
    )
    changes['hera_build_info.lua'] = replace_once(
        archive.read('hera_build_info.lua'), 'title="GHJ 1.5"', 'title="GHJ 1.5 FIX TEST"'
    )

    result = bytearray(archive.write(changes))
    delta = len(TITLE) - (title_end - 8)
    assert delta > 0 and prefix[-delta:] == b'\0' * delta
    result[:archive.base] = prefix[:8] + TITLE + b'\0' + prefix[title_end + 1:-delta]
    checked = Archive(bytes(result))
    assert checked.base == archive.base and checked.hashes == archive.hashes
    changed_ids = {archive.index(name) for name in changes}
    for name, raw in changes.items():
        assert checked.read(name) == raw, name
    for i, row in enumerate(archive.blocks):
        if i not in changed_ids:
            assert checked.blocks[i] == row
            off, size, _, _ = row
            assert data[archive.base + off:archive.base + off + size] == result[checked.base + off:checked.base + off + size]

    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('xb') as stream:
        stream.write(result)
    report = {
        'title': TITLE.decode(), 'source_sha256': BASE_SHA256,
        'output_sha256': hashlib.sha256(result).hexdigest(), 'changed': list(changes),
        'unchanged_blocks': len(archive.blocks) - len(changed_ids),
        'unrelated_blocks_byte_identical': True,
        'runtime_tested': False, 'multiplayer_tested': False,
    }
    output.with_suffix('.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf8')
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    print(json.dumps(build(args.source, args.output), ensure_ascii=False, indent=2))
