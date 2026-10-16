# 원본 결함 재현과 수정 MPQ의 Lua 문법 및 보호 상태 전환을 검사한다.
import argparse
import hashlib
import json
from pathlib import Path
from lupa.lua53 import LuaRuntime
from archive import Archive
from build import BASE_SHA256, DAMAGE, UNIT, patch_damage, patch_unit


def check(source, output):
    base = Archive(source.read_bytes())
    fixed = Archive(output.read_bytes())
    assert hashlib.sha256(base.data).hexdigest() == BASE_SHA256
    assert fixed.read(DAMAGE) == patch_damage(base.read(DAMAGE))
    assert fixed.read(UNIT) == patch_unit(base.read(UNIT))
    lua = LuaRuntime(unpack_returned_tuples=True, encoding=None)
    compile_lua = lua.eval('function(s, n) local f, e = load(s, n, "t"); assert(f, e) end')
    files = base.read('(listfile)').decode('utf8').splitlines()
    checked = 0
    for name in files:
        if name.lower().endswith('.lua'):
            compile_lua(fixed.read(name), ('@' + name).encode('utf8'))
            checked += 1
    boss = fixed.read('scripts/gameplay/monster/boss/Zhenhong.lua').decode('utf-8-sig').replace('\r\n', '\n')
    start = boss.index('                      local cs3 = 0\n', boss.index('u:setdata("永恒之轮")'))
    end = boss.index('                      ac.wait(6000, function()', start)
    regression = Path(__file__).with_name('regression.lua').read_text(encoding='utf-8-sig')
    counts = {}
    for patched, archive in ((False, base), (True, fixed)):
        runtime = LuaRuntime(unpack_returned_tuples=True)
        runtime.globals().patched = patched
        runtime.globals().damage_source = archive.read(DAMAGE).decode('utf-8-sig')
        runtime.globals().unit_source = archive.read(UNIT).decode('utf-8-sig')
        runtime.globals().expiry_source = boss[start:end]
        counts['fixed_assertions' if patched else 'baseline_assertions'] = runtime.execute(regression)
    return {'lua_version': '5.3', 'syntax_checked_lua_files': checked, **counts,
            'warcraft_runtime_tested': False, 'visual_tested': False, 'multiplayer_tested': False}


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    print(json.dumps(check(args.source, args.output), indent=2))
