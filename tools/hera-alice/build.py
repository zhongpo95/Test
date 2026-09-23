# 검증된 v177 복사본에 앨리스 수정과 v178 식별자만 적용한다.
import argparse
import hashlib
import json
import struct
from pathlib import Path

from fix import patch
from mpq import Map, crypt, nh

SOURCE_HASH = '183149b5e386774d33fb742daa3e313a44d630256a3e40653269efcb5a855c6f'
ALICE = 'scripts/gameplay/var/pools/mwx/pools_mwx_alice.lua'
TITLE = b'Hera RPG initialization v178 MP'

def build(source, output):
    if output.exists() or source.resolve() == output.resolve():
        raise ValueError('원본이나 기존 출력 파일을 덮어쓸 수 없습니다.')
    archive = Map(source)
    if hashlib.sha256(archive.data).hexdigest() != SOURCE_HASH:
        raise ValueError('검증된 v177 맵과 다릅니다.')
    changes = {ALICE: patch(archive.read(ALICE))}
    boot = archive.read('hera_boot.lua')
    old_boot_title = b'return "Hera RPG initialization v160\\nStatus = "'
    assert boot.count(old_boot_title) == 1
    changes['hera_boot.lua'] = boot.replace(
        old_boot_title, b'return "Hera RPG initialization v178 MP\\nStatus = "')
    changes['hera_build_info.lua'] = (
        '-- 실행 맵의 실제 빌드 식별자를 진단 로그에 제공한다.\n'
        'return {revision="178 MP",title="Hera RPG initialization v178 MP"}\n'
    ).encode('utf-8')
    jass = archive.read('war3map.j')
    old = b'Hera RPG initialization v177 MP'
    assert jass.count(b'call SetMapName("' + old + b'")') == 1
    changes['war3map.j'] = jass.replace(b'call SetMapName("' + old + b'")',
                                      b'call SetMapName("' + TITLE + b'")')
    w3i = archive.read('war3map.w3i')
    end = w3i.index(b'\0', 12)
    assert w3i[12:end] == old
    changes['war3map.w3i'] = w3i[:12] + TITLE + w3i[end:]
    original_blocks = list(archive.blocks)
    for name, content in changes.items():
        index = archive.index(name)
        archive.blocks[index] = (len(archive.data) - 512, len(content), len(content), 0x80000000)
        archive.data.extend(content)
    block_offset = len(archive.data) - 512
    archive.data.extend(crypt(b''.join(struct.pack('<4I', *b) for b in archive.blocks),
                              nh('(block table)', 3), True))
    struct.pack_into('<I', archive.data, 520, len(archive.data) - 512)
    struct.pack_into('<I', archive.data, 532, block_offset)
    end = archive.data.index(0, 8)
    assert bytes(archive.data[8:end]) == old and len(TITLE) == len(old)
    archive.data[8:end] = TITLE
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('xb') as f:
        f.write(archive.data)
    result = Map(output)
    for name, content in changes.items():
        assert result.read(name) == content, name
    changed_indices = {archive.index(name) for name in changes}
    for i, block in enumerate(original_blocks):
        if i not in changed_indices:
            assert result.blocks[i] == block
    assert result.hashes == archive.hashes
    report = {'source_sha256': SOURCE_HASH,
              'output_sha256': hashlib.sha256(result.data).hexdigest(),
              'changed_members': list(changes),
              'preserved_blocks': len(original_blocks) - len(changes),
              'runtime_verified': False}
    output.with_suffix('.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
    print(json.dumps(report))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    build(args.source, args.output)
