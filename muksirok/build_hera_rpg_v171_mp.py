# 바닥 아이템 원본 설명을 한국어로 표시하는 묵시록 시험 맵을 만든다.
import os
import pathlib
import runpy

work = pathlib.Path(__file__).parent
os.environ.setdefault('HERA_MAP_OUT', str(work / 'Hera_RPG_Init_v171_MP.w3x'))
os.environ.setdefault('HERA_MAP_TITLE', 'Hera RPG initialization v171 MP')
os.environ.setdefault('HERA_MAP_REVISION', '171 MP')
runpy.run_path(str(work / 'build_hera_rpg_v166.py'), run_name='__main__')
