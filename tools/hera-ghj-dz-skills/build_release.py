# GHJ 1.5의 Dz 지점형 채널 스킬을 동기화된 시전 이벤트로 보완한다.
import argparse
import hashlib
import json
from pathlib import Path

from archive import Archive


BASE_SHA256 = '1c8ff203bfea4ca44cc16736703f47a6c50f2a83b6ea75ec31a6d4638c7924f7'
ACTION = 'scripts/gameplay/feature/shot/act.lua'


def patch_action(raw):
    old = (
        '  elseif target_type == 2 or target_type == 6 then\n'
        '    return IssuePointOrderById(unit, order, x, y)\n'
    ).encode('utf8')
    new = (
        '  elseif target_type == 2 or target_type == 6 then\n'
        '    local issued = IssuePointOrderById(unit, order, x, y)\n'
        '    if issued == false and target_type == 2 and slk.ability[id]\n'
        '        and slk.ability[id].code == "ANcl" then\n'
        '      local u = getunit(unit)\n'
        '      local listeners = u.trigger and u.trigger["单位-发动技能"]\n'
        '      if not listeners or #listeners == 0 then return false end\n'
        '      local cd = tonumber(slk.ability[id].Cool1) or 0\n'
        '      if cd > 0 then japi.EXSetAbilityState(ability_handle, 1, cd) end\n'
        '      local args = {unit=unit, skill=ability, x=x, y=y}\n'
        '      for _, listener in ipairs(listeners) do listener(args) end\n'
        '      return true\n'
        '    end\n'
        '    return issued\n'
    ).encode('utf8')
    assert raw.count(old) == 1, 'point-order path changed'
    return raw.replace(old, new, 1)


def build(source, output):
    assert not output.exists(), 'output already exists'
    data = source.read_bytes()
    assert hashlib.sha256(data).hexdigest() == BASE_SHA256, 'unexpected GHJ 1.5 baseline'
    archive = Archive(data)
    changes = {ACTION: patch_action(archive.read(ACTION))}
    result = archive.write(changes)
    checked = Archive(result)
    assert checked.base == archive.base and checked.hashes == archive.hashes
    assert checked.read(ACTION) == changes[ACTION]
    changed_id = archive.index(ACTION)
    for index, row in enumerate(archive.blocks):
        if index == changed_id:
            continue
        assert checked.blocks[index] == row
        offset, size, _, _ = row
        assert data[archive.base + offset:archive.base + offset + size] == result[checked.base + offset:checked.base + offset + size]
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('xb') as stream:
        stream.write(result)
    return {
        'title': 'GHJ 1.5',
        'source_sha256': BASE_SHA256,
        'output_sha256': hashlib.sha256(result).hexdigest(),
        'changed': list(changes),
        'unchanged_blocks': len(archive.blocks) - 1,
        'unrelated_blocks_byte_identical': True,
    }


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    print(json.dumps(build(args.source, args.output), ensure_ascii=False, indent=2))
