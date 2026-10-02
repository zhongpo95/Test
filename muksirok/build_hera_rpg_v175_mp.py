# 바닥 아이템 이름표 글꼴과 엔진 이름 진단을 확인할 묵시록 시험 맵을 만든다.
import os
import pathlib
import runpy

work = pathlib.Path(__file__).parent
os.environ.setdefault('HERA_MAP_OUT', str(work / 'Hera_RPG_Init_v175_MP.w3x'))
os.environ.setdefault('HERA_MAP_TITLE', 'Hera RPG initialization v175 MP')
os.environ.setdefault('HERA_MAP_REVISION', '175 MP')
os.environ.setdefault('HERA_ITEM_NAME_OVERRIDES', str(work / 'item-name-overrides.tsv'))
for setting in ('CHATFONT', 'ESCMENUTEXTFONT', 'INFOPANELTEXTFONT',
                'MASTERFONT', 'MESSAGEFONT', 'TEXTTAGFONT'):
    os.environ.setdefault('HERA_' + setting, r'Fonts\FRIZQT__.ttf')
runpy.run_path(str(work / 'build_hera_rpg_v166.py'), run_name='__main__')
