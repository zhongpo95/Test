# v149 추출본의 Lua 문법과 수정 코드 포함 여부 및 기존 스킬 보존을 검사한다.
from pathlib import Path
import sys

r = Path.cwd()
sys.path.insert(0, str(r / 'analysis-deps'))
from lupa.lua53 import LuaRuntime

lua = LuaRuntime(encoding=None, unpack_returned_tuples=True)
check = lua.eval(b'function(s) local a,b=load(s);return a~=nil,b end')
extracted = r / 'hera-rpg-validation-v149'
sources = list(extracted.rglob('*.lua'))
assert len(sources) == 593
for path in sources:
    ok, error = check(path.read_bytes())
    assert ok, (path, error)

for name in ['scripts/gameplay/feature/shot/act.lua',
             'scripts/gameplay/feature/shot/yae_release.lua',
             'hera_boot.lua', 'hera_gameplay_diagnostic.lua']:
    assert (extracted / name).read_bytes() == (r / 'hera-port' / name).read_bytes(), name

for name in ['scripts/gameplay/hero/heroskill/八重樱/skill.lua',
             'scripts/gameplay/hero/heroskill/八重樱/basicskill.lua']:
    assert (extracted / name).read_bytes() == (r / 'hera-rpg-validation-v148' / name).read_bytes(), name

act = (extracted / 'scripts/gameplay/feature/shot/act.lua').read_text(encoding='utf-8')
assert 'message.order_immediate(852138)' not in act
assert act.count('yae_release.request()') == 1
assert 'v149' in (extracted / 'hera_boot.lua').read_text(encoding='utf-8')
print('PASS 593 packaged Lua sources parse; input hook and sync receiver match overlays; Yae E and A1S0 skill logic unchanged from v148.')
