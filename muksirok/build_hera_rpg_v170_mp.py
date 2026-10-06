# 묵시록 멀티플레이 충돌 직전 UI와 아이템 대상을 기록하는 시험 맵을 만든다.
import os
import pathlib
import runpy

work = pathlib.Path(__file__).parent
os.environ.setdefault('HERA_MAP_OUT', str(work / 'Hera_RPG_Init_v170_MP.w3x'))
os.environ.setdefault('HERA_MAP_TITLE', 'Hera RPG initialization v170 MP')
os.environ.setdefault('HERA_MAP_REVISION', '170 MP')
runpy.run_path(str(work / 'build_hera_rpg_v166.py'), run_name='__main__')
