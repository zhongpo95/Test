# 일반 채팅 후에도 외침 슬롯과 사용자 저장 설정이 유지되는지 검사한다.
import argparse
from pathlib import Path
from archive import Archive
from build_v208 import patch, CHAT
from check_v206 import chat_vm


def run(source):
    original = Archive(source.read_bytes())
    before = chat_vm(original.read(CHAT))
    before.execute("history_text='-z1';triggers[2].action();chord(18,49);chord(18,48);assert(sent[1]=='-slot2' and sent[2]=='-z1' and #saves==1)")
    changed = patch(original.read)[CHAT]
    vm = chat_vm(changed)
    vm.execute('''
      for _,text in ipairs({'-z1','-zx','-slot1','hello-world','hello',''}) do
        history_text=text;triggers[2].action()
      end
      assert(#saves==0)
      for i=1,10 do chord(18,48+i%10);assert(sent[i]=='-slot'..i) end
      edit_text(1,'직접 설정');assert(#saves==1)
      record(1);chord(17,49);assert(#saves==2)
      history_text='-z1';triggers[2].action();chord(17,49)
      assert(sent[11]=='직접 설정' and #saves==2)
      press(13);release(13);chord(17,49);assert(#sent==11)
      triggers[2].action();chord(17,49);assert(sent[12]=='직접 설정')
      press(13);release(13);GetTriggerPlayer=function() return 2 end
      triggers[2].action();chord(17,49);assert(#sent==12)
      press(27);release(27);chord(17,49);assert(#sent==13)
    ''')
    print('PASS reproduced -z1 slot shift; fixed all 10 slots unchanged/no autosave, manual text/key save, local chat close and remote chat guard')
    vm.execute('assert(load(...))', changed.decode('utf8'))
    print('PASS Lua 5.3 syntax; Warcraft runtime/visual/multiplayer untested')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    run(parser.parse_args().source)
