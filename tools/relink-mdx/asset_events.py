# 리링크 BXM의 사운드·이펙트 호출 정보를 읽고 원본 모션과 연결합니다.
import argparse
import csv
import json
import struct
import xml.etree.ElementTree as ET
from pathlib import Path


def read_bxm(file):
    data = Path(file).read_bytes()
    magic, options, count, attributes, text_size = struct.unpack_from('>4sIHHI', data)
    if magic not in (b'BXM\0', b'XML\0') or not count:
        raise ValueError(f'Invalid BXM: {file}')
    kv = 16 + count * 8
    text = kv + attributes * 4
    if text + text_size != len(data):
        raise ValueError(f'BXM size mismatch: {file}')
    def string(offset):
        if offset == 65535:
            return ''
        if offset >= text_size:
            raise ValueError('BXM string outside text block')
        end = data.index(b'\0', text + offset)
        return data[text + offset:end].decode('utf8')
    pairs = [(string(k), string(v)) for k, v in struct.iter_unpack('>HH', data[kv:text])]
    visited = set()
    def node(index):
        if index >= count or index in visited:
            raise ValueError('Invalid BXM child reference')
        visited.add(index)
        children, first, nattr, attr = struct.unpack_from('>4H', data, 16 + index * 8)
        if attr + nattr >= attributes:
            raise ValueError('Invalid BXM attribute reference')
        name, value = pairs[attr]
        element = ET.Element(name, dict(pairs[attr + 1:attr + 1 + nattr]))
        element.text = value or None
        element.extend(node(first + i) for i in range(children))
        return element
    root = node(0)
    if len(visited) != count:
        raise ValueError('Unreachable BXM nodes')
    return root


def records(raw, conversion):
    motions = {Path(x['source']).stem: x for x in conversion['motions']}
    result = []
    for file in sorted(Path(raw).glob('*_seq_edit_*.bxm')):
        kind = file.stem.rsplit('_', 1)[1]
        if kind not in ('se', 'effect'):
            continue
        source = '_'.join(file.stem.split('_')[:2])
        motion = motions.get(source, {})
        for element in read_bxm(file).iter('Seq'):
            result.append({'kind': kind, 'source_bxm': file.name, 'motion': source,
                           'mdx_sequence': motion.get('name', ''), 'attributes': element.attrib})
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--raw', type=Path, required=True)
    parser.add_argument('--conversion', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists():
        raise FileExistsError('Existing event output is preserved')
    data = records(args.raw, json.loads(args.conversion.read_text(encoding='utf8')))
    args.output.mkdir(parents=True)
    (args.output / 'motion-events.json').write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding='utf8')
    with (args.output / 'motion-events.csv').open('w', newline='', encoding='utf-8-sig') as handle:
        writer = csv.DictWriter(handle, fieldnames=['kind', 'source_bxm', 'motion', 'mdx_sequence', 'attributes'])
        writer.writeheader()
        writer.writerows({**x, 'attributes': json.dumps(x['attributes'], ensure_ascii=False)} for x in data)
    print(json.dumps({'records': len(data), 'sound': sum(x['kind'] == 'se' for x in data),
                      'effects': sum(x['kind'] == 'effect' for x in data)}))
