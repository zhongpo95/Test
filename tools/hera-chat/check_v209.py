# 외침 설정의 게임 내 유지와 새 게임 초기화 및 파일 접근 차단을 검사한다.
import argparse
from pathlib import Path
from lupa.lua53 import LuaRuntime
from archive import Archive
from build_v209 import patch, CHAT
from check import MOCK


def session(source):
    vm = LuaRuntime(unpack_returned_tuples=True)
    vm.execute(MOCK)
    vm.execute('''file_calls=0
      package.loaded['jass.storm']={
        load=function() file_calls=file_calls+1;return 'old file text' end,
        save=function() file_calls=file_calls+1;error('file write forbidden') end}
    ''')
    vm.execute(source.decode('utf8'))
    return vm


def run(source):
    original = Archive(source.read_bytes())
    changed = patch(original.read)[CHAT]
    vm = session(changed)
    vm.execute('''
      for i=1,10 do assert(edits[i].text=='');chord(18,48+i%10) end
      assert(#sent==0 and file_calls==0)
      edit_text(1,'게임 안 문구');record(1);chord(17,49)
      local entry=buttons[#buttons]
      entry:on_button_right_clicked();entry:on_button_drag_and_drop(nil,500,300)
      local x,y=entry.x,entry.y
      close_panel();entry.on_button_clicked();chord(17,49)
      assert(sent[1]=='게임 안 문구' and entry.x==x and entry.y==y)
      history_text='-z1';triggers[2].action();chord(17,49)
      assert(sent[2]=='게임 안 문구' and file_calls==0)
      payload=sent[2];triggers[1].action();assert(#received==1 and #native_chat==0)
    ''')
    new = session(changed)
    new.execute('''
      assert(edits[1].text=='' and buttons[#buttons].x==1515 and buttons[#buttons].y==18)
      edit_text(1,'새 게임');chord(17,49);assert(#sent==0)
      chord(18,49);assert(sent[1]=='새 게임' and file_calls==0)
    ''')
    assert b'jass.storm' not in changed and b'tloc_chat_tool.txt' not in changed
    print('PASS no file reads/writes, empty initial slots, in-game text/key/position retention, no chat auto-registration, new-game reset, synchronized shout')
    print('Lua 5.3 mock/syntax checks only; Warcraft runtime/visual/multiplayer untested')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    run(parser.parse_args().source)
