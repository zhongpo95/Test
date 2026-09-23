# 동기화 이탈과 종료 경로의 상태 기록을 보강한 묵시록 시험 맵을 만든다.
import os
import pathlib
import runpy

work = pathlib.Path(__file__).parent
os.environ.setdefault('HERA_MAP_OUT', str(work / 'Hera_RPG_Init_v177_MP.w3x'))
os.environ.setdefault('HERA_MAP_TITLE', 'Hera RPG initialization v177 MP')
os.environ.setdefault('HERA_MAP_REVISION', '177 MP')
runpy.run_path(str(work / 'build_hera_rpg_v176_mp.py'), run_name='__main__')
