# 바닥 아이템 이름표에 게임 기본 한중 글꼴을 적용한 묵시록 시험 맵을 만든다.
import os
import pathlib
import runpy

work = pathlib.Path(__file__).parent
os.environ.setdefault('HERA_MAP_OUT', str(work / 'Hera_RPG_Init_v174_MP.w3x'))
os.environ.setdefault('HERA_MAP_TITLE', 'Hera RPG initialization v174 MP')
os.environ.setdefault('HERA_MAP_REVISION', '174 MP')
os.environ.setdefault('HERA_ITEM_NAME_OVERRIDES', str(work / 'item-name-overrides.tsv'))
os.environ.setdefault('HERA_TEXT_TAG_FONT', r'Fonts\FRIZQT__.ttf')
os.environ.setdefault('HERA_MASTER_FONT', r'Fonts\FRIZQT__.ttf')
runpy.run_path(str(work / 'build_hera_rpg_v166.py'), run_name='__main__')
