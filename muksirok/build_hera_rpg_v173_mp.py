# 바닥 아이템의 한글 이름표 글꼴을 교체한 묵시록 시험 맵을 만든다.
import os
import pathlib
import runpy

work = pathlib.Path(__file__).parent
os.environ.setdefault('HERA_MAP_OUT', str(work / 'Hera_RPG_Init_v173_MP.w3x'))
os.environ.setdefault('HERA_MAP_TITLE', 'Hera RPG initialization v173 MP')
os.environ.setdefault('HERA_MAP_REVISION', '173 MP')
os.environ.setdefault('HERA_ITEM_NAME_OVERRIDES', str(work / 'item-name-overrides.tsv'))
os.environ.setdefault('HERA_TEXT_TAG_FONT', r'Fonts\NanumGothic-Regular.ttf')
runpy.run_path(str(work / 'build_hera_rpg_v166.py'), run_name='__main__')
