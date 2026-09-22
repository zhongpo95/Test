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
local cache, counter, definitions, toc_calls = {}, 10000, {}, {}
local passive_frames = {}
local native_calls = 0
function get_native_calls() return native_calls end
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
    native_calls=native_calls+1
    if definitions[globals.HWOperation]==mock_fail_native then error('Injected native bridge failure') end
    globals.HWCompleted=true
    globals.HWIntegerResult=handle()
    if globals.HWOperation==16 then globals.HWIntegerResult=1280 end
    if globals.HWOperation==17 then globals.HWIntegerResult=720 end
    if globals.HWOperation==18 or globals.HWOperation==19 then globals.HWIntegerResult=0 end
    globals.HWRealResult=0
    globals.HWStringResult=''
    globals.HWBooleanResult=false
    local name = definitions[globals.HWOperation]
    if name=='DzCreateFrameByTagName' and globals.HWString2:match('^HW%d+$') then
        passive_frames[globals.HWIntegerResult]={kind=globals.HWString1,template=globals.HWString3}
    elseif name=='DzFrameSetEnable' and passive_frames[globals.HWInteger1] then
        error('Observed v5 failure injected: passive frame DzFrameSetEnable')
    end
    if name=='get_player_name' then
        globals.HWStringResult=common.GetPlayerName(common.Player(globals.HWInteger1-1))..'x'
    elseif name=='YDWERPGBillingGetItem' then
        globals.HWIntegerResult=0
    elseif name=='DzLoadToc' then
        local path=globals.HWString1
        local toc=assert(cache['jass.storm'].load(path), 'TOC is not in the map: '..path)
        for fdf in toc:gmatch('[^\\r\\n]+') do
            assert(cache['jass.storm'].load(fdf), 'FDF is not in the map: '..fdf)
        end
        toc_calls[#toc_calls+1]=path
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
-- YDWE libs_message drops new fields except the native hook property.
local message_hook
cache['jass.message']=setmetatable({keyboard={},selection=function() return 0 end}, {
    __index=function(_,key) if key=='hook' then return message_hook end end,
    __newindex=function(_,key,value)
        if key=='hook' and (type(value)=='function' or value==nil) then message_hook=value end
    end,
})
cache['jass.message'].origin_load=function() error('Dropped field must not run') end
assert(cache['jass.message'].origin_load==nil)
cache['jass.log']=setmetatable({path='logs\\\\mock.log'}, {__index=function() return function(...) end end})
local saved={}
-- With local file reads disabled, disk writes are not part of the MPQ read path.
cache['jass.storm']={load=function(name) return host_load(name) end,save=function(name,data) saved[name]=data;return true end}
function check_packaged_fdf()
    assert(#toc_calls==1 and toc_calls[1]=='HeraWanhua_ui.toc')
    for name in pairs(saved) do
        assert(not name:lower():match('%.fdf$') and not name:lower():match('%.toc$'), 'UI wrote a runtime file: '..name)
    end
end
function check_passive_templates()
    local count=0
    for _,frame in pairs(passive_frames) do
        assert(frame.template==(frame.kind=='TEXT' and 'HeraWanhuaText' or 'HeraWanhuaImage'))
        count=count+1
    end
    assert(count>0)
end
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
local logs, log_names={}, {}
io.open=function(name) log_names[name]=true;return {write=function(self,...) for _,v in ipairs({...}) do logs[#logs+1]=tostring(v) end;return self end,close=function() return true end} end
function get_logs() return table.concat(logs) end
function check_version_log() assert(log_names['Logs/Hera_Wanhua_'..cache.hera_wanhua.version..'_p1.txt']) end
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
    if name in ('HeraWanhua_ui.toc', 'HeraWanhua_base.fdf', 'HeraWanhua_fonts.fdf'):
        path=args.staging/name
        return path.read_bytes() if path.is_file() else None
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
base_fdf = (args.staging / 'HeraWanhua_base.fdf').read_text(encoding='utf8')
image_fdf = re.search(r'Frame "BACKDROP" "HeraWanhuaImage"\s*\{([^}]+)\}', base_fdf)[1]
text_fdf = re.search(r'Frame "TEXT" "HeraWanhuaText"\s*\{([^}]+)\}', base_fdf)[1]
assert re.search(r'BackdropBackground "([^"]+)"', image_fdf)[1] == r'UI\Widgets\EscMenu\Human\blank-background.blp'
assert 'FrameFont "fonts3.ttf", 0.012' in text_fdf
assert all('LayerStyle "IGNORETRACKEVENTS"' in body for body in (image_fdf, text_fdf))
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
print('Map state',lua.execute(b"local e=require('hera_wanhua').env;if not e.game or not e.game.player or not e.get_player_list then return 'not initialized' end;return tostring(e.game.client_mode),tostring(e.game.save_mode),#e.get_player_list(),tostring(e.game.state)"))
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
local message=require('jass.message')
for _,name in ipairs({'origin_load','create_list','list_add','list_remove','list_enum_range'}) do
    assert(type(rawget(message,name))=='function', 'Missing message compatibility function: '..name)
end
assert(message.origin_load==require('jass.storm').load)
local previous_hook=message.hook
local hook=function() return true end
message.hook=hook
assert(message.hook==hook and rawget(message,'hook')==nil)
message.hook=previous_hook
check_version_log()
local catalog=require('hera_fdf_catalog')
local fdf=require('hera_fdf')
local fonts=require('jass.storm').load('HeraWanhua_fonts.fdf')
for name,template in pairs(catalog.templates) do
    for size=0,catalog.maximum do
        local data
        if name=='edit' then data=template:format(size,size,size,size/1000)
        else data=template:format(size,size/1000) end
        assert(fonts:find(data,1,true), 'Packaged FDF content mismatch: '..name..size)
        fdf.load(data)
    end
end
assert(not pcall(fdf.load, 'Frame "TEXT" "missing_template" {}'))
assert(not pcall(fdf.load, catalog.templates.text:format(catalog.maximum+1,1)))
assert(not pcall(fdf.load, catalog.templates.text:format(12,1)))
check_packaged_fdf()
check_passive_templates()
'''.encode('utf8'))
report['missing_jass_code_fallback_checked'] = True
report['player_name_suffix_and_utf8_checked'] = True
report['debug_console_disabled'] = True
report['message_newindex_and_native_hook_checked'] = True
report['packaged_fdf_without_local_reads_checked'] = True
report['fdf_template_variants_checked'] = 1028
report['versioned_log_path_checked'] = True
lua.execute(b'''
local common,storm=require('jass.common'),require('jass.storm')
local old_id,old_load=common.GetUnitTypeId,storm.load
common.GetUnitTypeId=function() return 1 end
local notes,paths={},{}
local top=145.5
paths['test.mdx']='MDLXMODL'..string.pack('<I4',372)..string.rep(string.char(0),364)..string.pack('<fI4',top,0)
paths['truncated.mdx']='MDLXMODL'..string.pack('<I4',372)..'short'
storm.load=function(path) return paths[path] end
local path='test.mdl'
local unit={get_model_file=function() return path end}
local port={env={game={unit={all_units={[77]=unit}}}},note=function(s) notes[#notes+1]=s end}
local height=require('hera_overhead')(port)
assert(height(77)==top)
path='truncated.mdx';assert(height(77)==60)
path='missing.mdx';assert(height(77)==60)
assert(height(0)==0)
common.GetUnitTypeId=function() return 0 end
assert(height(77)==0)
common.GetUnitTypeId,storm.load=old_id,old_load
assert(type(rawget(require('jass.message'),'unit_overhead'))=='function')
''')
report['unit_overhead_bounds_and_fallback_checked'] = True
lua.execute(b'''
local port=require('hera_wanhua')
local ui=port.library('ui')
local record=ui.create()
ui.set_attribute(record,'render_type',1)
ui.set_attribute(record,'text','Native failure probe')
ui.set_size(record,100,20)
WindowEventCallBack=nil
port.env.newui.render_gui=function() ui.render(record) end
port.env.newui.render_gui2=function() error('Rendering continued after native failure') end
mock_fail_native='DzFrameSetSize'
local message=port.tick()
assert(port.status=='BLOCKED' and port.native_failed=='DzFrameSetSize')
assert(message:find('HERA_NATIVE_FAILED: DzFrameSetSize',1,true))
local calls=get_native_calls()
assert(port.tick()=='')
port.input(10)
assert(not pcall(require('jass.japi').DzFrameShow,record.frame,true))
assert(get_native_calls()==calls)
''')
report['passive_templates_and_native_failure_stop_checked'] = True
(args.staging/'mock-report.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf8')
print('JASS fallback, packaged FDF, passive UI, overhead and native failure stop checks passed')
