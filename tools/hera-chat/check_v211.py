# 실제 채팅 표시 함수와 글자 컨트롤로 한글 자모의 폰트 전환을 검사한다.
import argparse
from pathlib import Path
from lupa.lua53 import LuaRuntime
from archive import Archive
from build_v211 import patch, KOREAN


def run(source):
    arc = Archive(source.read_bytes())
    after = patch(arc.read)[KOREAN]
    for fixed, korean in [(False, arc.read(KOREAN)), (True, after)]:
        vm = LuaRuntime(unpack_returned_tuples=True)
        # 번역 사전과 폭 자료도 최종 맵의 실제 모듈로 읽는다.
        vm.globals().read_module = lambda name: arc.read(name.replace('.', '/')+'.lua').decode('utf8')
        vm.execute('''table.insert(package.searchers,1,function(name)
          return assert(load(read_module(name),'@'..name))
        end)
        class={panel={}};extends=function(base) return function(def) return def end end
        package.loaded['jh.ui.base.controls.class']={}
        package.loaded['jh.ui.base.controls.panel']={}
        io.open=function() return nil end
        fonts={};rendered={};japi={
          FrameSetTextFont=function(id,font,size) fonts[id]=font end,
          FrameSetText=function(id,text) rendered[id]=text end,
          FrameSetSize=function() end}
        ''')
        vm.globals().package.loaded.hera_korean = vm.execute(korean.decode('utf8'))
        vm.execute(arc.read('scripts/jh/ui/base/controls/text.lua').decode('utf8'))
        chat = arc.read('scripts/system/chat/init.lua').decode('utf8').replace('\r\n', '\n')
        start = chat.index("  local text_width = require('hera_text_width')")
        end = chat.index('  local usefulbox = {}', start)
        vm.globals().set_chat_text = vm.execute(chat[start:end]+'\nreturn set_chat_text')
        vm.execute('''frame=setmetatable({_id=1,font_size=13,align=0,
          font_path='Fonts\\\\gamefont.ttc',set_control_size=function() end},{__index=class.text})''')
        for text in ['ㅋㅋ', 'ㅎㅎ', 'ㅁㄴㅇ', 'ㅏㅓㅗ', '-ㅋㅌ', '안녕하세요', '가나다 ㅋㅋ']:
            line = '|cFFFF0000SunHo99|r:'+text
            vm.globals().set_chat_text(vm.globals().frame, line)
            selected = vm.globals().frame.font_path
            expected = fixed or any(0xAC00 <= ord(c) <= 0xD7A3 for c in text)
            assert (selected == 'Fonts\\NanumGothic-Regular.ttf') == expected, (text, selected)
            assert vm.globals().rendered[1] == line
        vm.globals().set_chat_text(vm.globals().frame, 'SunHo99:hello123')
        assert vm.globals().frame.font_path == 'Fonts\\gamefont.ttc'
        print('PASS', 'fixed Korean font selection' if fixed else 'reproduced missed Jamo font switch', 'with actual chat/text code')
    print('Lua mock/static validation only; actual Warcraft input/rendering untested')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    run(parser.parse_args().source)
