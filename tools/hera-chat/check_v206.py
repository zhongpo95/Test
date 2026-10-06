# 실제 Lua 코드로 미지원 API, 선택 전 채팅 및 기본 채팅 재배치를 모의 검사한다.
import argparse
from pathlib import Path
from lupa.lua53 import LuaRuntime
from archive import Archive
from build_v206 import patch, CHAT, PLAYER, NATIVE
from check import MOCK


def chat_vm(raw, supported=False):
    vm = LuaRuntime(unpack_returned_tuples=True)
    vm.execute(MOCK)
    vm.globals().saved_content = '\n'.join(f'-slot{i}' for i in range(1, 11))
    if not supported:
        vm.execute('japi.GetChatState=nil')
    vm.execute(raw.decode('utf8'))
    return vm


def run(source):
    archive = Archive(source.read_bytes())
    changes = patch(archive.read)
    before = chat_vm(archive.read(CHAT))
    before.execute('''record(1);chord(17,49);assert(#saves==1)
      local ok,err=pcall(function() chord(17,49) end)
      assert(not ok and tostring(err):find('GetChatState',1,true));assert(#sent==0)''')
    vm = chat_vm(changes[CHAT])
    vm.execute('''
      record(1);chord(17,49);assert(#saves==1 and #sent==0)
      chord(17,49);assert(sent[1]=='-slot1')
      record(1);chord(18,49);assert(#saves==2)
      for i=1,10 do chord(18,48+i%10);assert(sent[i+1]=='-slot'..i) end
      press(18);press(49);press(49);release(49);release(18);assert(#sent==12)
      chord(49,18);assert(#sent==13)
      press(18);press(16);press(49);release(49);release(16);release(18);assert(#sent==13)
      press(13);press(13);release(13);chord(18,49);assert(#sent==13)
      press(13);release(13);chord(18,49);assert(#sent==14)
      press(13);release(13);press(27);release(27);chord(18,49);assert(#sent==15)
      press(13);release(13);history_text='hello';triggers[2].action()
      chord(18,49);assert(#sent==16)
      focus=edits[1]._id;input.on_mouse_down();chord(18,49);assert(#sent==16)
      close_panel();chord(18,49);assert(#sent==17)
      record(1);press(117);release(117);press(117);release(117);assert(#sent==18)
      payload='hello';triggers[1].action();assert(#received==1 and #native_chat==0)
      for _,text in ipairs({'','  ','a\\nb',string.rep('a',256)}) do payload=text;triggers[1].action() end
      assert(#received==1)
    ''')
    # 저장된 사용자 지정 키와 문구는 재시작 후에도 그대로 사용한다.
    restored = LuaRuntime(unpack_returned_tuples=True)
    restored.execute(MOCK)
    restored.execute('japi.GetChatState=nil')
    restored.globals().saved_content = vm.globals().saves[len(vm.globals().saves)]
    restored.execute(changes[CHAT].decode('utf8'))
    restored.execute("press(117);release(117);assert(sent[1]=='-slot1')")
    supported = chat_vm(changes[CHAT], True)
    supported.execute('''chatting=true;chord(18,49);assert(#sent==0)
      chatting=1;chord(18,49);assert(#sent==0)
      chatting=0;chord(18,49);assert(#sent==1)
      chatting=false;chord(18,49);assert(#sent==2)''')
    print('PASS missing GetChatState reproduction, recording/execution, all Alt slots, repeated/reversed/extra keys, chat/edit guards, saved settings, one custom dispatch')

    s = changes[PLAYER].decode('utf8').replace('\r\n', '\n')
    dispatch = s[s.index('function mt:dispatch_chat(str)'):s.index('\nfunction mt:setcameraheight')]
    vm = LuaRuntime(unpack_returned_tuples=True)
    vm.execute('''mt={};Hero={};shown={};commands=0
      UI_NewChat=function(p,header,text) shown[#shown+1]={p.id,text} end
      getunit=function(h) return {handle=h} end
      package.loaded.hera_korean_commands={normalize=function(s) return s end}
      player=setmetatable({id=1,handle=100},{__index=mt})''')
    vm.execute(dispatch)
    vm.execute('''player:dispatch_chat('before');assert(#shown==1 and shown[1][2]=='before')
      player.trigger={['玩家-聊天']={}};player:dispatch_chat('empty');assert(#shown==2)
      player.trigger['玩家-聊天']={function(args)
        commands=commands+1;assert(args.u.handle==123);UI_NewChat(args.p,args.chat,args.raw_chat)
      end};Hero[1]=123;player:dispatch_chat('after');assert(commands==1 and #shown==3)
      UI_NewChat=nil;player.trigger=nil;player:dispatch_chat('loading')''')
    print('PASS pre-hero custom chat, loading guard, post-hero command/display exactly once')

    start = s.index('  Trg_PlayerChat = war3.CreateTrigger(function()')
    hook = s[start:s.index('\n  Trg_EVENT_PLAYER_UNIT_SELECTED', start)]
    vm.execute('''queue={};native_alpha=255;native_x=0
      japi={FrameGetChatMessage=function() return 7 end,
        FrameSetAlpha=function(f,a) assert(f==7);native_alpha=a end,
        FrameClearAllPoints=function(f) assert(f==7) end,
        FrameSetAbsolutePoint=function(f,p,x,y) assert(f==7);native_x=x end,
        FrameShow=function() error('unsupported chat FrameShow') end}
      package.loaded['jass.japi']=japi
      ac={wait=function(ms,fn) assert(ms==1);queue[#queue+1]=fn end}
      war3={CreateTrigger=function(fn) return fn end}
      GetTriggerPlayer=function() return 100 end
      GetEventPlayerChatString=function() return 'typed' end
      getplayer=function() return {dispatch_chat=function() end} end''')
    native = vm.execute(archive.read(NATIVE).decode('utf8'))
    vm.globals().package.loaded['system.bootstrap.native_ui'] = native
    vm.execute(hook)
    vm.execute('''Trg_PlayerChat();assert(#queue==1)
      native_alpha=255;native_x=0;queue[1]();assert(native_alpha==0 and native_x==2)''')
    print('PASS deferred native chat hiding after simulated engine layout reset; no FrameShow')
    for name, raw in changes.items():
        vm.execute('assert(load(...))', raw.decode('utf8'), '@'+name)
    print('PASS changed Lua 5.3 syntax; runtime/multiplayer/visual untested')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    run(parser.parse_args().source)
