# 기존 맵의 두 모서리 배치와 1초 지연을 실제 변경 Lua에서 검사한다.
import argparse
from pathlib import Path
from lupa.lua53 import LuaRuntime
from archive import Archive
from build_v207 import patch, NATIVE, PLAYER


def run(source):
    original = Archive(source.read_bytes())
    changes = patch(original.read)
    for frame in (10, 0):
        vm = LuaRuntime(unpack_returned_tuples=True)
        vm.execute('''
          frame=...;waits={};points={};clears=0;EnableCustomUI=false
          japi={FrameGetChatMessage=function() return frame end,
            FrameClearAllPoints=function(f) assert(f==10);clears=clears+1 end,
            FrameSetAbsolutePoint=function(f,p,x,y) assert(f==10);points[p]={x,y} end,
            FrameShow=function() error('chat FrameShow must not be called') end,
            FrameSetAlpha=function() error('chat alpha must not be changed') end}
          package.loaded['jass.japi']=japi
          ac={wait=function(ms,fn) waits[#waits+1]={ms,fn} end}
        ''', frame)
        vm.globals().native = vm.execute(changes[NATIVE].decode('utf8'))
        vm.execute('''native.init();assert(#waits==2 and clears==0)
          assert(waits[1][1]==1000);waits[1][2]()
          if frame==0 then assert(clears==0 and next(points)==nil)
          else
            assert(clears==1 and points[6][1]==2 and points[6][2]==2)
            assert(points[2][1]==2.29 and points[2][2]==2.14)
            assert(points[2][1]>points[6][1] and points[2][2]>points[6][2])
          end''')
    before = original.read(PLAYER).decode('utf8').replace('\r\n', '\n')
    after = changes[PLAYER].decode('utf8').replace('\r\n', '\n')
    removed = '''    -- 엔진이 새 채팅을 추가한 뒤 복구하는 기본 프레임 배치를 다시 숨긴다.
    ac.wait(1, function() require("system.bootstrap.native_ui").clear_chat_frame() end)
'''
    assert after == before.replace(removed, '', 1)
    for name, raw in changes.items():
        vm.execute('assert(load(...))', raw.decode('utf8'), '@'+name)
    print('PASS two-corner offscreen rectangle after 1000ms, invalid frame guard, no alpha/FrameShow, only obsolete per-chat relocation removed')
    print('Lua mock/static checks only; actual Warcraft rendering not tested')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    run(parser.parse_args().source)
