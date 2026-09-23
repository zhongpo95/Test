# MPQ 압축 경계와 보호 리소스 검증 및 LNI 상속 의미를 검사한다.
import argparse
from pathlib import Path
import random
import struct
import sys
import tempfile
import zlib
from build import ASSET_KEY, compress, crypt, name_hash, prepare_jass, restore_asset

parser = argparse.ArgumentParser()
parser.add_argument('--lua-deps', type=Path)
parser.add_argument('--original-jass', type=Path, required=True)
args = parser.parse_args()
if args.lua_deps: sys.path.insert(0, str(args.lua_deps))
from lupa.lua53 import LuaRuntime

# 원본과 같은 64 KiB 섹터 경계 전후와 비압축 섹터 혼합을 복원한다.
count = 0
for size in (0, 1, 65535, 65536, 65537, 131072):
    for data in (b'a' * size, random.Random(size).randbytes(size)):
        packed, flags = compress(data, 65536)
        if flags == 0x80000200:
            sectors = (len(data) + 65535) // 65536
            offsets = struct.unpack_from('<' + 'I' * (sectors + 1), packed)
            decoded = []
            for i in range(sectors):
                block = packed[offsets[i]:offsets[i + 1]]
                wanted = min(65536, len(data) - i * 65536)
                if len(block) < wanted:
                    assert block[0] == 2
                    block = zlib.decompress(block[1:])
                decoded.append(block)
            assert b''.join(decoded) == data
        else:
            assert packed == data
        count += 1
assert name_hash('war3map.j', 1) == name_hash('WAR3MAP.J', 1)
raw = bytes(range(256))
assert crypt(crypt(raw, 0xcafebabe, True), 0xcafebabe) == raw
model = b'MDLXVERS' + struct.pack('<II', 4, 800)
encrypted = bytes(v ^ ASSET_KEY[i % 16] for i, v in enumerate(model))
assert restore_asset(encrypted) == (model, 'MDX')
try:
    restore_asset(encrypted[:-1])
except AssertionError:
    pass
else:
    raise AssertionError('Truncated protected model was accepted')
with tempfile.TemporaryDirectory() as temporary:
    compiled, _ = prepare_jass(args.original_jass.read_bytes(), Path(temporary))
    lines = compiled.decode('utf8').splitlines()
    assert lines.count('globals') == lines.count('endglobals') == 1
    end = lines.index('endglobals')
    assert lines.index('    trigger HWEvaluator = null') < end
    assert lines.index('native EXExecuteScript takes string script returns string') > end
    assert '//endglobals from BzAPI' in compiled.decode('utf8')

lua = LuaRuntime(unpack_returned_tuples=True)
parse = lua.execute((Path(__file__).parent / 'hera_lni.lua').read_text(encoding='utf8'))
source = '''<enum>
rare = 7
<default>
kind = rare
values = {1, 2, name = "기본"}
[부모]
text = [=[
첫 줄
둘째 줄]=]
enabled = true
[자식:부모]
values = {3, 4}
enabled = false
'''
data, defaults, enum = parse(source, 'fixture.lni')
assert data['부모']['kind'] == data['자식']['kind'] == 7
assert data['부모']['values'][1] == 1 and data['자식']['values'][1] == 3
assert data['부모']['text'] == data['자식']['text'] == '첫 줄\n둘째 줄'
assert data['부모']['enabled'] is True and data['자식']['enabled'] is False
previous = lua.table_from([data, defaults, enum])
second, _, _ = parse('[다음]\nkind = rare\n', 'second.lni', previous)
assert second['다음']['values']['name'] == '기본' and second['다음']['kind'] == 7
try:
    parse('[bad:missing]\na=1', 'invalid.lni')
except Exception as error:
    assert 'missing parent' in str(error)
else:
    raise AssertionError('Missing LNI parent accepted')
print(f'PASS: {count} MPQ sector cases, table cipher, MDX corruption rejection, JASS globals boundary, LNI inheritance/enum/multiline/previous-file/error cases')
