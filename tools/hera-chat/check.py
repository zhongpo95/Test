# 실제 외침 스크립트의 입력과 저장, 진단 중지 및 기존 수명 보호를 Lua 5.3으로 검사한다.
import argparse
import re
from pathlib import Path
from lupa.lua53 import LuaRuntime
from archive import Archive
from patch import CHAT, NATIVE, patch


MOCK = r'''
frames={}; buttons={}; edits={}; triggers={}; physical={}; sent={}; saves={}
active=true; chatting=false; focus=0; received={}; native_chat={}
KEY={ALT=18,CTRL=17,ESC=27}; KEY_STR={}; LocalPlayer=1
local methods={}
function methods:set_text(v) self.text_value=v end
function methods:set_focus(v) self.focused=v end
function methods:hide() self.visible=false end
function methods:show() self.visible=true end
function methods:get_is_show() return self.visible end
function methods:set_level(v) end
function methods:set_enable_drag(v) self.is_drag=v end
function methods:set_position(x,y) self.x=x;self.y=y end
local function build(kind,args)
  args._id=#frames+1;args.visible=true
  if type(args.text)=='table' then args.text=setmetatable(args.text,{__index=methods}) end
  setmetatable(args,{__index=methods});frames[#frames+1]=args
  if kind=='button' then buttons[#buttons+1]=args end
  if kind=='edit' then edits[#edits+1]=args end
  return args
end
class={}
for _,kind in ipairs({'panel','text','button','edit'}) do
  class[kind]={builder=function(_,args) return build(kind,args) end}
end
japi={GetChatState=function() return chatting end,GetMouseFocus=function() return focus end,
  GetKeyState=function() return false end,
  DzSyncData=function(prefix,text) assert(prefix=='ChatTool');sent[#sent+1]=text end,
  DzTriggerRegisterSyncData=function(t,prefix,local_only) assert(prefix=='ChatTool' and not local_only) end,
  DzGetTriggerSyncData=function() return payload end,DzGetTriggerSyncPlayer=function() return 2 end,
  EXDisplayChat=function(p,recipient,text) native_chat[#native_chat+1]={p,recipient,text} end}
package.loaded['jass.japi']=japi
package.loaded['jass.common']={Player=function(i) return i+1 end,TriggerRegisterPlayerChatEvent=function() end}
package.loaded['jass.storm']={load=function() return saved_content end,
  save=function(path,text) assert(path=='tloc_chat_tool.txt');saves[#saves+1]=text;return true end}
package.loaded['hera_compat']={installed={ui={IsKeyDown=function(k) return physical[k]==true end}}}
package.loaded['gameplay.interface.ui.icon_chat']={}
game={register_event=function(e) if e.on_key_down then input=e end end}
function IsWindowActive() return active end
function CreateTrigger() local t={};triggers[#triggers+1]=t;return t end
function TriggerAddAction(t,f) t.action=f end
function GetTriggerPlayer() return 1 end
function GetEventPlayerChatString() return history_text end
function getplayer(p) return {dispatch_chat=function(_,text) received[#received+1]={p,text} end} end
function uiy_show_text() end
function uiy_hide() end
function press(k) physical[k]=true;input.on_key_down(k) end
function release(k) physical[k]=nil;input.on_key_up(k) end
function chord(a,b) press(a);press(b);release(b);release(a) end
function edit_text(i,text) edits[i].on_edit_text_changed(edits[i],text) end
function record(i) buttons[i+1].on_button_clicked(buttons[i+1]) end
function close_panel() buttons[1].on_button_clicked() end
'''


def chat_vm(source):
    vm = LuaRuntime(unpack_returned_tuples=True)
    vm.execute(MOCK)
    vm.globals().saved_content = '\n'.join(f'-slot{i}' for i in range(1, 11))
    vm.execute(source.decode('utf8'))
    return vm


def run(read):
    changes = patch(read)
    vm = LuaRuntime(unpack_returned_tuples=True)
    syntax = 0
    for name, raw in changes.items():
        if name.endswith('.lua'):
            vm.execute('assert(load(...))', raw.decode('utf8'), '@' + name)
            syntax += 1
    print('PASS changed Lua 5.3 syntax:', syntax)

    before = chat_vm(read(CHAT))
    before.execute('chord(18,49);assert(#sent==0)')
    vm = chat_vm(changes[CHAT])
    vm.execute('''
      for i=1,10 do chord(18,48+i%10);assert(sent[i]=='-slot'..i) end
      assert(#sent==10)
      press(18);press(49);press(49);assert(#sent==11);release(49)
      press(50);assert(#sent==12);release(50);release(18)
      chord(49,18);assert(#sent==13)
      press(49);release(49);assert(#sent==13)
      press(18);press(16);press(49);release(49);release(16);release(18);assert(#sent==13)
      chatting=true;chord(18,49);assert(#sent==13)
      press(18);chatting=false;press(49);release(49);release(18);assert(#sent==13)
      focus=edits[1]._id;input.on_mouse_down();chord(18,49);assert(#sent==13)
      focus=0;chord(18,49);assert(#sent==13)
      close_panel();chord(18,49);assert(#sent==14)
      active=false;chord(18,49);active=true;chord(18,49);assert(#sent==15)
      press(18);active=false;release(18);active=true;press(49);release(49);assert(#sent==15)
    ''')
    print('PASS v203 missing key-state reproduction, Alt+1..0, reverse order, held Alt, repeat suppression, extra keys, chat/edit/background guards')

    vm = chat_vm(changes[CHAT])
    vm.execute('''
      record(1);press(117);release(117);assert(#sent==0 and #saves==1)
      press(117);assert(#sent==0);release(117);assert(sent[1]=='-slot1')
      record(1);chord(17,117);assert(#saves==2 and #sent==1)
      chord(17,117);assert(#sent==2)
      record(1);chord(18,50);assert(#saves==2)
      chord(17,117);assert(#sent==3)
      record(1);press(18);press(16);press(49);release(49);release(16);release(18)
      assert(#saves==2)
      record(1);press(27);release(27);assert(#saves==2)
      chord(17,117);assert(#sent==4)
      edit_text(1,'-수정');chord(17,117);assert(sent[5]=='-수정')
      edit_text(1,'');chord(17,117);assert(#sent==5)
      edit_text(1,string.rep('a',256));chord(17,117);assert(#sent==5)
      edit_text(1,string.rep('a',255));chord(17,117);assert(#sent==6)
      history_text='-새명령';triggers[2].action();chord(18,48);assert(sent[7]=='-새명령')
      local saved=#saves;triggers[2].action();assert(#saves==saved)
      payload='-수정';triggers[1].action();assert(#received==1 and received[1][1]==2 and #native_chat==1)
      for _,text in ipairs({'','  ','a\\nb',string.rep('a',256)}) do payload=text;triggers[1].action() end
      assert(#received==1 and #native_chat==1)
    ''')
    saved = vm.globals().saves[len(vm.globals().saves)]
    restored = LuaRuntime(unpack_returned_tuples=True)
    restored.execute(MOCK)
    restored.globals().saved_content = saved
    restored.execute(changes[CHAT].decode('utf8'))
    restored.execute("chord(18,48);assert(sent[1]=='-새명령')")
    print('PASS custom single/two-key recording, duplicates, cancel, input limits, history, saved settings reload, one synchronized command dispatch')

    vm = LuaRuntime(unpack_returned_tuples=True)
    vm.execute('''
      frame=10;calls={};japi={FrameGetChatMessage=function() return frame end}
      for _,n in ipairs({'FrameSetAlpha','FrameShow','FrameClearAllPoints','FrameSetAbsolutePoint'}) do
        japi[n]=function(...) calls[n]=table.pack(...) end
      end
      package.loaded['jass.japi']=japi
    ''')
    vm.globals().native = vm.execute(changes[NATIVE].decode('utf8'))
    vm.execute('''native.clear_chat_frame();assert(calls.FrameSetAlpha[2]==0 and calls.FrameShow[2]==false)
      assert(calls.FrameSetAbsolutePoint[3]==2 and calls.FrameSetAbsolutePoint[4]==2)
      frame=0;calls={};native.clear_chat_frame();assert(next(calls)==nil)''')
    print('PASS native chat frame hidden, transparent and offscreen; invalid handle ignored')

    vm = LuaRuntime(unpack_returned_tuples=True)
    vm.execute('''
      io.open=function() error('unexpected disk write') end
      package.loaded['jass.console']={write=function() error('unexpected console output') end}
      package.loaded['jass.common']={}
      package.loaded['jass.runtime']={}
      package.preload['jass.log']=function() error('unexpected log initialization') end
    ''')
    for name in ('hera_boot.lua', 'hera_trace_ring.lua', 'hera_startup_trace.lua',
                 'hera_gameplay_diagnostic.lua', 'hera_ui_trace.lua', 'hera_move_trace.lua',
                 'hera_callback_probe.lua', 'scripts/jh/base/log.lua'):
        module = name.removesuffix('.lua').removeprefix('scripts/').replace('/', '.')
        vm.globals().package.loaded[module] = vm.execute(changes[name].decode('utf8'))
    vm.execute('''
      require('hera_boot').note('ERROR');require('hera_boot').record_runtime_error('FAIL')
      assert(require('hera_trace_ring').new('test.txt').write('ERROR'))
      local startup=require('hera_startup_trace');startup.install();startup.flush();startup.start_flush()
      local d=require('hera_gameplay_diagnostic');d.install();d.monster('ERROR');d.phase('ERROR');d.local_input('ERROR');d.command('ERROR')
      assert(d.track_damage(function(x) return x+1 end)(41)==42)
      print('silent');log.info('silent');log.warn('silent');log.error('silent')
      package.loaded['jh.base.handle_ref']={is_alive=function() return alive end}
      GetUnitTypeId=function() return 1 end
    ''')
    vm.globals().diag = vm.execute(changes['hera_desync_diagnostic.lua'].decode('utf8'))
    vm.execute('''
      local d=diag;d.install();d.event('ERROR');d.snapshot('ERROR');d.runtime('ERROR',function() error('diagnostic detail executed') end)
      d.item('ERROR',123);d.ui_receive('ERROR');d.building.trace('ERROR');d.building.snapshot(nil)
      alive=true;local g=d.building;local npc={handle=1,handle_generation=1};local cleaned,removed=0,0
      local s=g.watch(npc,function() cleaned=cleaned+1 end)
      g.bind(s,{remove=function() removed=removed+1 end});assert(g.active(s))
      alive=false;assert(not g.active(s) and cleaned==1 and removed==1)
      assert(not g.active(s) and cleaned==1 and removed==1)
    ''')
    vm.execute("package.loaded['jass.debug']={handle_ref=function() end,handle_unref=function() end}")
    vm.globals().refs = vm.execute(changes['scripts/jh/base/handle_ref.lua'].decode('utf8'))
    vm.execute('''
      local r=refs;local h,fresh,g=r.ref(9);assert(h==9 and fresh and r.is_alive(h,g))
      assert(r.hold(h));assert(r.begin_remove(h,g));assert(not r.is_alive(h,g))
      assert(not r.begin_remove(h,g));assert(not r.unref(h,g));assert(r.release(h))
      local _,_,nextgen=r.ref(9);assert(nextgen~=g and not r.is_current(9,g))
    ''')
    print('PASS no diagnostic file/console initialization or writes; damage forwarding, building cancellation and handle generations preserved')

    jass = changes['war3map.j'].decode('utf8')
    assert 'if key != 84 then' in jass
    for direction in ('Down', 'Up'):
        callback = re.search(r'function HeraChatToolKey' + direction + r' takes.*?endfunction', jass, re.S).group()
        code = re.search(r'EXExecuteScript\("([^\n]*)"\)', callback).group(1)
        code = code.replace('" + I2S(DzGetTriggerKey()) + "', '49')
        vm.execute('assert(load(...))', code)
        # EXExecuteScript의 표현식 경로와 일반 Lua 청크 모두 허용한다.
        vm.execute('assert(load(...))', 'return ' + code)
        assert vm.eval(code) == ''  # 초기화 전에는 UI 모듈을 새로 불러오지 않는다.
        method = 'on_key_' + direction.lower()
        vm.execute("calls=0;package.loaded['gameplay.interface.ui.chat_tool']={" + method + "=function(k) assert(k==49);calls=calls+1 end}")
        assert vm.eval(code) == ''
        assert vm.globals().calls == 1
        vm.execute("package.loaded['gameplay.interface.ui.chat_tool']=nil")
        emoji = re.search(r'function HeraUIBridgeEmoji' + direction + r' takes.*?endfunction', jass, re.S).group()
        assert 'hera_emoji_input' in emoji and f'call HeraChatToolKey{direction}()' in emoji
    assert 'elseif HeraUIBridgeOperation == 53 then' in jass
    print('PASS native key callback source wiring, pre-init guard and original T-key emoji routing (not a JASS compile or Warcraft test)')
    print('Warcraft runtime, multiplayer and visual inspection: NOT RUN')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    args = parser.parse_args()
    if args.source.is_dir():
        run(lambda name: (args.source / name).read_bytes())
    else:
        archive = Archive(args.source.read_bytes())
        run(archive.read)
