# 표준 Lua 문법과 네이티브 대역 환경에서 맵의 동기 초기화 경로를 검사한다.
from pathlib import Path
import json
import hashlib
import re
import sys
import argparse
parser = argparse.ArgumentParser(description='Warcraft runtime is not emulated; only startup Lua and deferred callbacks are checked.')
for name in ('source', 'staging', 'stormlib', 'common-j', 'library-dir'):
    parser.add_argument('--' + name, type=Path, required=True)
parser.add_argument('--lua-deps', type=Path)
args = parser.parse_args()
if args.lua_deps: sys.path.insert(0, str(args.lua_deps))
from lupa.lua53 import LuaRuntime
from build import Archive, restore_asset
archive = Archive(args.source, args.stormlib)

lua = LuaRuntime(encoding=None, unpack_returned_tuples=True)
lua.execute(b'''
local cache, counter, definitions = {}, 10000, {}
cache.utf8=utf8
local common = {}
local timers, now, expired = {}, 0, 0
function common.TimerStart(timer, timeout, periodic, callback)
    timers[timer]={timeout=math.max(timeout,0.001),next=now+math.max(timeout,0.001),periodic=periodic,callback=callback}
end
function common.DestroyTimer(timer) timers[timer]=nil end
function common.PauseTimer(timer) if timers[timer] then timers[timer].paused=true end end
function common.GetExpiredTimer() return expired end
function advance(seconds)
    local finish, count = now+seconds,0
    while true do
        local id, entry
        for key, candidate in pairs(timers) do
            if not candidate.paused and candidate.next<=finish and (not entry or candidate.next<entry.next or candidate.next==entry.next and key<id) then id,entry=key,candidate end
        end
        if not entry then break end
        count=count+1;assert(count<100000,'Mock timer runaway')
        now,expired=entry.next,id
        if entry.periodic then entry.next=entry.next+entry.timeout else timers[id]=nil end
        local ok,err=pcall(entry.callback)
        if not ok then cache.hera_wanhua.error(err) end
    end
    now=finish
    return count
end
local function handle() counter=counter+1;return counter end
function define(name, result)
    if common[name] then return end
    common[name] = function(...)
        if name:sub(1,7)=='Convert' then return (...) or 0 end
        if name=='Player' then return (...) + 1 end
        if name=='GetPlayerId' then return (...) - 1 end
        if name=='GetLocalPlayer' then return 1 end
        if name=='GetPlayerName' then return 'Player'..tostring(...) end
        if name=='GetPlayerController' then return (...) == 1 and 0 or 1 end
        if name=='GetPlayerSlotState' then return (...) == 1 and 1 or 0 end
        if name=='GetRectMinX' or name=='GetRectMinY' then return -16384 end
        if name=='GetRectMaxX' or name=='GetRectMaxY' then return 16384 end
        if name:sub(1,6)=='Create' or name:sub(1,4)=='Init' then return handle() end
        if result=='boolean' then return false end
        if result=='string' then return '' end
        if result=='nothing' then return nil end
        return 0
    end
end
local japi = {}
function define_japi(name, result) define(name,result);japi[name]=common[name] end
local globals = {HWEvaluator=1, HWBusy=false, HWOperation=0, HWCompleted=false}
function register_binding(name, operation) definitions[operation] = name end
function common.TriggerEvaluate()
    globals.HWCompleted=true
    globals.HWIntegerResult=handle()
    if globals.HWOperation==16 then globals.HWIntegerResult=1280 end
    if globals.HWOperation==17 then globals.HWIntegerResult=720 end
    if globals.HWOperation==18 or globals.HWOperation==19 then globals.HWIntegerResult=0 end
    globals.HWRealResult=0
    globals.HWStringResult=''
    globals.HWBooleanResult=false
    local name = definitions[globals.HWOperation]
    if name=='get_player_name' then
        globals.HWStringResult=common.GetPlayerName(common.Player(globals.HWInteger1-1))..'x'
    elseif name=='YDWERPGBillingGetItem' then
        globals.HWIntegerResult=0
    end
    return false
end
local runtime = {}
cache['jass.common']=common
cache['jass.japi']=japi
cache['jass.globals']=globals
cache['jass.runtime']=runtime
cache['jass.console']={enable=true,write=function(...) end}
cache['jass.ai']={}
cache['jass.bignum']={new=function(data) return {data=data} end,bin=function(hex) return hex:gsub('..',function(v) return string.char(tonumber(v,16)) end) end,sha1=function(data) return host_sha1(data) end,hex=function(data) return (data:gsub('.',function(v) return string.format('%02x',v:byte()) end)) end}
cache['jass.hook']={}
cache['jass.slk']={unit={},item={},ability={},buff={},doodad={},destructable={},upgrade={}}
cache['jass.debug']={gchash=function() end,handle_ref=function() end,handle_unref=function() end,handledef=function() return {type='unknown'} end,handlecount=function() return 0 end,handlemax=function() return 0 end}
cache['jass.message']={keyboard={},hook=function() end,selection=function() return 0 end}
cache['jass.log']=setmetatable({path='logs\\\\mock.log'}, {__index=function() return function(...) end end})
local saved={}
cache['jass.storm']={load=function(name) return saved[name] or host_load(name) end,save=function(name,data) saved[name]=data;return true end}
function require(name)
    if cache[name] then return cache[name] end
    if package.preload[name] then cache[name]=package.preload[name]();return cache[name] end
    local data=host_module(name)
    if not data then error('MOCK_MISSING_MODULE: '..name) end
    local fn,err=load(data, '@'..name, 't')
    assert(fn,err)
    local result=fn()
    cache[name]=result == nil and true or result
    return cache[name]
end
local logs={}
io.open=function() return {write=function(self,...) for _,v in ipairs({...}) do logs[#logs+1]=tostring(v) end;return self end,close=function() return true end} end
function get_logs() return table.concat(logs) end
function inspect_port() return cache.hera_wanhua end
''')
base = args.common_j
for name, result in re.findall(r'(?m)^\s*(?:constant\s+)?native\s+(\w+).*?returns\s+(\w+)',base.read_text(encoding='utf8')):
    lua.globals().define(name.encode(), result.encode())
for path in args.library_dir.glob('*.j'):
    for name,result in re.findall(r'(?m)^\s*native\s+((?:Dz|EX)\w+).*?returns\s+(\w+)',path.read_text(encoding='utf8',errors='replace')):
        lua.globals().define_japi(name.encode(),result.encode())

def host_module(name):
    name=name.decode('utf8')+'.lua'
    for p in [Path(__file__).parent/name, args.staging/name]:
        if p.is_file(): return p.read_bytes()
    return archive.read(name) if archive.exists(name) else None

def host_load(name):
    name=name.decode('utf8')
    if name.startswith('HeraWanhua\\tex_'):
        path=args.staging/'images'/name.split('\\')[-1]
        if path.is_file(): return path.read_bytes()
    return restore_asset(archive.read(name))[0] if archive.exists(name) else None

lua.globals().host_module=host_module
lua.globals().host_load=host_load
lua.globals().host_sha1=lambda data: hashlib.sha1(data).digest()
lua.execute(b"for _,spec in ipairs(require('hera_bindings')) do register_binding(spec[1],spec[2]) end")
check=lua.eval(b'function(data) local fn,err=load(data); return fn~=nil,err end')
syntax_count = 0
for path in list(Path(__file__).parent.glob('*.lua'))+list(args.staging.glob('*.lua')):
    ok,err=check(path.read_bytes())
    assert ok,(path,err)
    syntax_count += 1
print('Lua syntax passed')
# 설치된 yd_lua_engine은 전달식을 return (%s)로 감싸서 평가한다.
# JASS의 실제 문자열을 읽어 검사해야 중복 return 같은 연결부 오류를 잡을 수 있다.
jass = (args.staging / 'war3map.j').read_text(encoding='utf8')
def execute_jass_expression(function_name):
    body = re.search(r'(?ms)^function ' + function_name + r' takes .*?^endfunction', jass)[0]
    literal = re.search(r'EXExecuteScript\(("(?:[^"\\]|\\.)*")\)', body)[1]
    expression = json.loads(literal)
    result = lua.execute(('return (' + expression + ')').encode('utf8'))
    assert isinstance(result, bytes), (function_name, 'EXExecuteScript must return a string')
    return result

result=execute_jass_expression('HWStart')
print(result.decode('utf8',errors='replace'))
timer_calls = lua.globals().advance(10)
print('Deferred timer calls', timer_calls)
execute_jass_expression('HWRefresh')
lua.execute(b"""
local port=require('hera_wanhua')
local original=WindowEventCallBack
local seen={}
WindowEventCallBack=function(kind) seen[#seen+1]={kind,require('jass.japi').GetTriggerKey()} end
port.key_input(7,65);port.key_input(8,65)
WindowEventCallBack=original
assert(seen[1][1]==7 and seen[2][1]==8 and seen[1][2]==65 and seen[2][2]==65)
assert(port.trigger_key==nil)
""")
print('Map state',lua.execute(b"local e=require('hera_wanhua').env;if not e.game or not e.get_player_list then return 'not initialized' end;return tostring(e.game.client_mode),tostring(e.game.save_mode),#e.get_player_list(),tostring(e.game.state)"))
print(lua.execute(b"return require('hera_wanhua').summary()").decode('utf8',errors='replace'))
logs=lua.globals().get_logs()
(args.staging/'mock-boot.log').write_bytes(logs)
lines=logs.decode('utf8',errors='replace').splitlines()
print('\n'.join([line for line in lines if line.startswith(('ERROR','MODULE'))][-18:]))
archive.close()
port = lua.globals().inspect_port()
errors = [key.decode('utf8', errors='replace') for key in port[b'errors']]
report = {'lua_syntax_files': syntax_count, 'modules_entered': len(port[b'modules']),
          'deferred_timer_calls': timer_calls, 'errors': errors, 'runtime_tested': False,
          'adapter_key_forwarding_checked': True,
          'native_expression_wrapping_checked': True,
          'limits': 'No real natives, SLK objects, sync network, player input, GPU, or gameplay simulation.'}
(args.staging/'mock-report.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf8')
if errors: raise SystemExit(1)
lua.execute('''
local common=require('jass.common')
local code=require('jass.code')
assert(code.get_player_name(1)=='Player1x')
assert(code.YDWERPGBillingGetItem(common.Player(0),'test')==0)
assert(code.YDWERPGBillingHasItem(common.Player(0),'test')==false)
assert(code.YDWERPGBillingHasStatus(common.Player(0),'test')==false)
local original=common.GetPlayerName
common.GetPlayerName=function() return '테스트鸟9' end
local player=require('hera_wanhua').env.game.player[2]
player._base_name=nil
assert(player:get_name()=='테스트鸟9')
common.GetPlayerName=original
assert(require('jass.console').enable==false)
'''.encode('utf8'))
report['missing_jass_code_fallback_checked'] = True
report['player_name_suffix_and_utf8_checked'] = True
report['debug_console_disabled'] = True
(args.staging/'mock-report.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf8')
print('JASS code fallback, player name and disabled console checks passed')
