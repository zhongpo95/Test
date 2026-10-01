# 기존 배치 스크립트에 현재 Import.j를 연결하여 맵을 생성하지 않고 JASS만 컴파일한다.
import argparse
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path


def run(args):
    root = Path(__file__).resolve().parents[1]
    out = args.output_dir.resolve()
    if out.exists():
        raise ValueError('검증 출력은 새 폴더를 사용해야 합니다.')
    out.mkdir(parents=True)
    (out / 'pjass').mkdir()
    (out / 'logs').mkdir()
    (out / 'backups').mkdir()
    (out / 'bin').mkdir()
    template = args.template.read_bytes()
    source, replaced = re.subn(r'//! import "[^"\n]*[\\/]Import\.j"', lambda _: '//! import "' + str(root / 'Import.j') + '"', template.decode('utf-8-sig'))
    if replaced != 1:
        raise ValueError('검증 템플릿의 Import.j 진입부는 정확히 하나여야 합니다.')
    (out / 'input.j').write_text(source, encoding='utf8')
    for name in ('common.j', 'Blizzard.j', 'SFmpq.dll'):
        shutil.copy2(args.compiler_data / name, out / name)
    shutil.copy2(args.compiler_data / 'bin/SFmpq.dll', out / 'bin/SFmpq.dll')
    shutil.copy2(args.compiler_data / 'pjass/f2d22c84.exe', out / 'pjass/f2d22c84.exe')
    shutil.copy2(args.jn_root / 'jasshelper/vexorianjasshelper.exe', out / 'vexorianjasshelper.exe')
    (out / 'jasshelper.conf').write_text('[lookupfolders]\n"' + str(args.jn_root / 'import') + '\\"\n[jasscompiler]\n"pjass\\f2d22c84.exe"\n"$COMMONJ $BLIZZARDJ $WAR3MAPJ"\n[noreturnfixer]\n[doshadowfixer]\n', encoding='utf8')
    try:
        result = subprocess.run([str(out / 'vexorianjasshelper.exe'), '--scriptonly', 'common.j', 'Blizzard.j', 'input.j', 'war3map.j'], cwd=out, capture_output=True, timeout=60, creationflags=subprocess.CREATE_NO_WINDOW)
    except subprocess.TimeoutExpired:
        report = {'template':str(args.template.resolve()),'compiler_exit':None,'map_created':False,'error':'컴파일러가 60초 안에 종료되지 않음. 출력 폴더의 로그를 확인해야 함.'}
        (out / 'report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
        print(json.dumps(report,ensure_ascii=False))
        return True
    report = {'template':str(args.template.resolve()), 'template_sha256':hashlib.sha256(template).hexdigest(), 'compiler_exit':result.returncode, 'map_created':False}
    compiled = out / 'war3map.j'
    if result.returncode == 0 and compiled.exists():
        check = subprocess.run([str(out / 'pjass/f2d22c84.exe'), 'common.j', 'Blizzard.j', 'war3map.j'], cwd=out, capture_output=True, timeout=60, creationflags=subprocess.CREATE_NO_WINDOW)
        report['pjass_exit'] = check.returncode
        report['script_sha256'] = hashlib.sha256(compiled.read_bytes()).hexdigest()
        report['pjass_output'] = check.stdout.decode(errors='replace')[-2000:]
    else:
        error = out / 'logs/compileerrors.txt'
        report['error'] = error.read_text(encoding='utf-8-sig', errors='replace')[-5000:] if error.exists() else result.stdout.decode(errors='replace')[-2000:]
    (out / 'report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
    print(json.dumps(report,ensure_ascii=False))
    return report.get('pjass_exit',1) != 0


if __name__ == '__main__':
    p=argparse.ArgumentParser()
    for option in ('template','jn-root','compiler-data','output-dir'):
        p.add_argument('--'+option, type=Path, required=True)
    raise SystemExit(run(p.parse_args()))
