# 기존 묵시록 자산에 한국어 바닥 아이템 툴팁을 적용한 멀티플레이 시험 맵을 만든다.
import os
import pathlib
import runpy

work = pathlib.Path(__file__).parent
os.environ.setdefault('HERA_MAP_OUT', str(work / 'Hera_RPG_Init_v169_MP.w3x'))
os.environ.setdefault('HERA_MAP_TITLE', 'Hera RPG initialization v169 MP')
os.environ.setdefault('HERA_MAP_REVISION', '169 MP')
runpy.run_path(str(work / 'build_hera_rpg_v166.py'), run_name='__main__')
