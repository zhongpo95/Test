# 실제 초기화 소스에서 기본 채팅 숨김 오류와 난이도 로더 도달 여부를 모의 검사한다.
import sys
from pathlib import Path
from lupa.lua53 import LuaRuntime
from archive import Archive
from build_v205 import NATIVE, patch

source = Archive(Path(sys.argv[1]).read_bytes())
before = source.read(NATIVE)
after = patch(before)
eol = b'\r\n' if b'\r\n' in before else b'\n'
start = before.index(b'function M.clear_chat_frame()')
assert after == before[:start] + before[start:].replace(b'  japi.FrameShow(frame, false)' + eol, b'', 1)


def run(native, custom, frame):
    vm = LuaRuntime(unpack_returned_tuples=True)
    vm.execute('''
      waits={};loaded={};alpha=nil;position=nil;chat_show_calls=0
      EnableCustomUI=...;chat_frame=select(2,...);UITransparency=0
      local noop=function() end
      japi=setmetatable({
        FrameGetChatMessage=function() return chat_frame end,
        FrameSetAlpha=function(frame,value) assert(frame==chat_frame);alpha=value end,
        FrameShow=function(frame,show)
          if frame==chat_frame and chat_frame~=0 then
            chat_show_calls=chat_show_calls+1;error('Call jass function crash.<TriggerEvaluate>')
          end
        end,
        FrameSetAbsolutePoint=function(frame,anchor,x,y)
          if frame==chat_frame then position={anchor,x,y} end
        end,
        FrameGetMinimap=function() return 20 end,
        DzFrameGetUpperButtonBarButton=function(i) return 30+i end,
        GetGameUI=function() return 40 end,
        DzSimpleFrameFindByName=function() return 50 end,
        DzSimpleFontStringFindByName=function() return 51 end,
        DzSimpleTextureFindByName=function() return 52 end
      },{__index=function() return noop end})
      ac={wait=function(ms,f) waits[#waits+1]={ms=ms,fn=f} end}
      package.loaded['jass.japi']=japi
      package.loaded['jass.message']={}
      package.loaded['jass.console']={}
      package.loaded['jass.globals']={}
      for _,n in ipairs({'jh.japi','system.war3.id'}) do package.loaded[n]={} end
      package.loaded['hera_scene_diagnostic']={install=noop}
      package.loaded['system.bootstrap.debug_console']={init=noop,enable=noop}
      package.loaded['system.bootstrap.module_loader']={load_game_modules=function() loaded.game=true end}
      package.loaded['system.bootstrap.neutral_name']={apply=noop}
      package.loaded['system.bootstrap.player_config']={init=noop,apply_bgm_enabled=noop}
      package.loaded['system.bootstrap.quest_info']={create=function() loaded.quest=true end}
      package.loaded['system.sound']={}
      package.loaded['hera_boot']={note=noop,run_stage=function(name,f) f();return true end}
      package.loaded['hera_api_audit']={run=noop}
      package.loaded['gameplay.permission.permission_store']={on_ready=noop}
      package.loaded['jh.ac.player']={{isplayer=function() return true end}}
      package.loaded['hera_startup_trace']={start_flush=noop}
      package.loaded['hera_difficulty_input']={bind=function() loaded.bound=true;return 1 end}
      package.preload['gameplay.start.difficulty.ui']=function() loaded.difficulty=true;return {} end
    ''', custom, frame)
    vm.globals().package.loaded['system.bootstrap.native_ui'] = vm.execute(native)
    loader = source.read('scripts/gameplay/start/difficulty/loader.lua')
    vm.execute("package.preload['gameplay.start.difficulty.loader']=assert(load(...))", loader)
    try:
        vm.execute(source.read('scripts/main.lua'))
    except Exception as error:
        return vm, str(error)
    # 실제 게임/퀘스트 지연 콜백과 그 뒤 등록되는 난이도 콜백을 순서대로 실행한다.
    vm.execute('''
      local i=1
      while i<=#waits do
        local w=waits[i];i=i+1
        if w.ms<1000 then w.fn() end
      end
      assert(loaded.game and loaded.quest and loaded.difficulty and loaded.bound)
    ''')
    return vm, None


for custom in (False, True):
    vm, error = run(before, custom, 10)
    assert error and 'Call jass function crash.<TriggerEvaluate>' in error
    assert vm.globals().chat_show_calls == 1
    vm, error = run(after, custom, 10)
    assert error is None, error
    assert vm.globals().chat_show_calls == 0 and vm.globals().alpha == 0
    assert vm.globals().position[2] == 2 and vm.globals().position[3] == 2
    vm, error = run(after, custom, 0)
    assert error is None and vm.globals().chat_show_calls == 0
print('PASS v204 FrameShow failure reproduced; v205 reaches difficulty UI loader and input binding with custom UI on/off and invalid chat frame')
print('PASS exact single-call removal; alpha and offscreen placement retained')
print('Mock validation only; actual Warcraft difficulty screen and multiplayer not tested')
