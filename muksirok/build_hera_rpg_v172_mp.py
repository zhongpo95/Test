# 바닥 아이템의 원본 오브젝트 이름을 한국어로 바꾼 묵시록 시험 맵을 만든다.
import os
import pathlib
import runpy

work = pathlib.Path(__file__).parent
os.environ.setdefault('HERA_MAP_OUT', str(work / 'Hera_RPG_Init_v172_MP.w3x'))
os.environ.setdefault('HERA_MAP_TITLE', 'Hera RPG initialization v172 MP')
os.environ.setdefault('HERA_MAP_REVISION', '172 MP')
os.environ.setdefault('HERA_ITEM_NAME_OVERRIDES', str(work / 'item-name-overrides.tsv'))
runpy.run_path(str(work / 'build_hera_rpg_v166.py'), run_name='__main__')
