# 신쿠 보호 상태의 피해와 생명 손실을 차단한 GHJ 1.7을 원본 보존 방식으로 만든다.
import argparse
import hashlib
import json
from pathlib import Path

from archive import Archive

BASE_SHA256 = '118b1ecd197ef6a63cd49da42944f393b9ffc4839a2ee5a655d563d048a8c550'
DAMAGE = 'scripts/combat/damagemonster.lua'
UNIT = 'scripts/jh/ac/unit.lua'


def replace_once(raw, old, new):
    if b'\r\n' in raw:
        old, new = old.replace('\n', '\r\n'), new.replace('\n', '\r\n')
    old, new = old.encode('utf8'), new.encode('utf8')
    assert raw.count(old) == 1, 'unexpected source context: ' + old.decode('utf8')
    return raw.replace(old, new, 1)


def protected(name):
    return (f'{name}:hasdata("BOSS-真红") and ({name}:hasdata("永恒之轮")'
            f' or {name}:hasdata("真红永恒") or {name}:hasdata("真红-世界之羽永恒"))')


def patch_damage(raw):
    anchor = 'local function isDamageInvalid(damageinfo)\n  local u = damageinfo.u\n'
    return replace_once(raw, anchor, anchor +
        '  if ' + protected('u') + ' then\n    return true\n  end\n')


def patch_unit(raw):
    anchor = 'function unit:losshp(soc, dehp, perdehp, perdemaxhp)\n'
    raw = replace_once(raw, anchor, anchor +
        '  if ' + protected('self') + ' then\n    return\n  end\n')
    anchor = 'function unit:damagelosshp(dehp, soc)\n'
    return replace_once(raw, anchor, anchor +
        '  if dehp > 0 and ' + protected('self') + ' then\n    return\n  end\n')


def build(source, output):
    assert not output.exists(), 'output already exists'
    data = source.read_bytes()
    assert hashlib.sha256(data).hexdigest() == BASE_SHA256, 'unexpected GHJ 1.6 baseline'
    archive = Archive(data)
    prefix = data[:archive.base]
    assert prefix[:4] == b'HM3W' and prefix[8:16] == b'GHJ 1.6\0'
    changes = {
        DAMAGE: patch_damage(archive.read(DAMAGE)),
        UNIT: patch_unit(archive.read(UNIT)),
        'war3map.w3i': replace_once(archive.read('war3map.w3i'), 'GHJ 1.6\0', 'GHJ 1.7\0'),
        'war3map.j': replace_once(archive.read('war3map.j'),
            'call SetMapName("GHJ 1.6")', 'call SetMapName("GHJ 1.7")'),
        'hera_build_info.lua': replace_once(archive.read('hera_build_info.lua'),
            'title="GHJ 1.6"', 'title="GHJ 1.7"'),
        'scripts/main.lua': replace_once(archive.read('scripts/main.lua'),
            'GameVersion = "1.6"', 'GameVersion = "1.7"'),
    }
    result = bytearray(archive.write(changes))
    result[8:15] = b'GHJ 1.7'
    checked = Archive(bytes(result))
    assert checked.base == archive.base and checked.hashes == archive.hashes
    assert result[:archive.base] == prefix[:8] + b'GHJ 1.7' + prefix[15:]
    changed_ids = {archive.index(name) for name in changes}
    for name, content in changes.items():
        assert checked.read(name) == content, name
    for index, row in enumerate(archive.blocks):
        if index in changed_ids:
            continue
        assert checked.blocks[index] == row
        offset, size, _, _ = row
        assert data[archive.base+offset:archive.base+offset+size] == result[checked.base+offset:checked.base+offset+size]
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('xb') as stream:
        stream.write(result)
    assert hashlib.sha256(source.read_bytes()).hexdigest() == BASE_SHA256
    return {
        'title': 'GHJ 1.7',
        'source_sha256': BASE_SHA256,
        'output_sha256': hashlib.sha256(result).hexdigest(),
        'changed': list(changes),
        'unchanged_blocks': len(archive.blocks) - len(changed_ids),
        'unrelated_blocks_byte_identical': True,
        'warcraft_runtime_tested': False,
    }


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    print(json.dumps(build(args.source, args.output), ensure_ascii=False, indent=2))
