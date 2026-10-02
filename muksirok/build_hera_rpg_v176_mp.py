# 앨리스 재능 설명을 복원한 묵시록 한국어 시험 맵을 만든다.
import os
import pathlib
import runpy

work = pathlib.Path(__file__).parent
os.environ.setdefault('HERA_MAP_OUT', str(work / 'Hera_RPG_Init_v176_MP.w3x'))
os.environ.setdefault('HERA_MAP_TITLE', 'Hera RPG initialization v176 MP')
os.environ.setdefault('HERA_MAP_REVISION', '176 MP')
runpy.run_path(str(work / 'build_hera_rpg_v175_mp.py'), run_name='__main__')
