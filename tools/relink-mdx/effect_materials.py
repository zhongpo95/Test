# 지크프리트 EST의 색 텍스처와 EPB 윤곽 메시를 워크래프트 이펙트 소재 및 공유 BLP로 준비합니다.
import argparse
import hashlib
import importlib.util
import io
import json
import math
import shutil
import struct
from pathlib import Path

import numpy as np
from PIL import Image


def field(data, table, index):
    vtable = table - struct.unpack_from('<i', data, table)[0]
    length = struct.unpack_from('<H', data, vtable)[0]
    entry = 4 + index * 2
    offset = struct.unpack_from('<H', data, vtable + entry)[0] if entry < length else 0
    return table + offset if offset else None


def pointer(data, offset):
    return offset + struct.unpack_from('<I', data, offset)[0]


def text(data, offset):
    if offset is None:
        return ''
    start = pointer(data, offset)
    length = struct.unpack_from('<I', data, start)[0]
    return data[start + 4:start + 4 + length].decode('utf8')


def texture_files(file):
    data = file.read_bytes()
    if data[4:8] != b'ETIM':
        raise ValueError('Unexpected ETI identifier')
    vector = pointer(data, field(data, struct.unpack_from('<I', data)[0], 0))
    files = []
    for index in range(struct.unpack_from('<I', data, vector)[0]):
        table = pointer(data, vector + 4 + index * 4)
        paths = [text(data, field(data, table, i)) for i in (0, 1)]
        files.append({suffix: next((p for p in paths if p.endswith('.' + suffix)), '')
                      for suffix in ('texture', 'epb')})
    return files


def read_est(file):
    data = file.read_bytes()
    magic, count, mapping, functions, payload, stride, per_entry, pad = struct.unpack_from('<4s7I', data)
    if magic != b'EFF\0' or stride != 16 or per_entry != 28:
        raise ValueError('Unsupported EST layout')
    entries = []
    for index in range(count):
        base = struct.unpack_from('<I', data, mapping + 4 * index)[0]
        blocks = {}
        for slot in range(per_entry):
            flag, tag, size, offset = struct.unpack_from('<I4sII', data, functions + (index * per_entry + slot) * stride)
            if size:
                start = base + offset
                if start < payload or start + size > len(data):
                    raise ValueError('EST block outside payload')
                blocks[tag.decode().strip()] = {'offset': start, 'size': size}
        part = blocks['PART']['offset']
        esp, life = struct.unpack_from('<hh', data, part)
        entry = {'index': index, 'esp': esp, 'life_frames_raw': life, 'blocks': blocks}
        for tag, role in [('TSC', 'color'), ('TSM', 'mask'), ('TSN', 'normal')]:
            if tag in blocks:
                start = blocks[tag]['offset']
                resource, kind = struct.unpack_from('<HB', data, start)
                entry[role] = {'resource': resource, 'kind_raw': kind}
        if 'TEX' in blocks:
            entry['legacy_texture_index'] = data[blocks['TEX']['offset'] + 0x1e]
        entries.append(entry)
    return entries


def read_epb(file):
    data = file.read_bytes()
    magic, version, topology, vertices, indices, triangles, streams, stream_offset, index_offset = struct.unpack_from('<4sI4s6I', data)
    if version != 0x01000001:
        raise ValueError('Unsupported EPB version')
    tag, stride, vertex_offset, flags = struct.unpack_from('<4s3I', data, stream_offset)
    if (magic, topology, streams, data[36:40], tag, stride) != (b'EPB\0', b'TRIL', 1, b'U16\0', b'ST0\0', 16):
        raise ValueError('Unsupported EPB vertex/index format')
    if indices != triangles * 3 or index_offset + indices * 2 > len(data) or vertex_offset + vertices * stride > len(data):
        raise ValueError('EPB array size mismatch')
    points = [struct.unpack_from('<8e', data, vertex_offset + i * stride) for i in range(vertices)]
    faces = struct.unpack_from('<' + str(indices) + 'H', data, index_offset)
    if not vertices or any(i >= vertices for i in faces) or not all(math.isfinite(v) for p in points for v in p):
        raise ValueError('EPB geometry is invalid')
    if any(p[2] != 0 or p[3] != 0 for p in points):
        raise ValueError('EPB position is not the inspected planar layout')
    return {'positions': [[p[0], p[1]] for p in points], 'uv': [[p[4], p[5]] for p in points],
            'faces': faces, 'source_sha256': hashlib.sha256(data).hexdigest()}


def read_image(file):
    data = file.read_bytes()
    # Pillow omits some sRGB DXGI aliases; their compressed blocks are identical.
    # Keep stored sRGB channel values and the source file unchanged.
    if data[84:88] == b'DX10':
        format_id = struct.unpack_from('<I', data, 128)[0]
        alias = {72: 71, 75: 74, 78: 77}.get(format_id)
        if alias is not None:
            data = data[:128] + struct.pack('<I', alias) + data[132:]
    return Image.open(io.BytesIO(data)).convert('RGBA')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--raw', type=Path, required=True)
    parser.add_argument('--events', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists():
        raise FileExistsError('Existing effects output is preserved')
    args.output.mkdir(parents=True)
    effects = []
    selections = {}
    for file in sorted((args.raw / 'effect/savedata/pl1100').glob('*.est')):
        entries = read_est(file)
        effects.append({'source': file.relative_to(args.raw).as_posix(), 'entries': entries})
        for entry in entries:
            color = entry.get('color')
            if color:
                selected = selections.setdefault(color['resource'], {'indices': set(), 'multi_frame': False})
                selected['indices'].add(entry.get('legacy_texture_index', 0))
                selected['multi_frame'] |= color['kind_raw'] == 0
    materials, images, unsupported = [], {}, []
    for resource, selection in sorted(selections.items()):
        files = texture_files(args.raw / f'effect/texture/{resource:03}/effect_texture_info.eti')
        if selection['multi_frame']:
            groups = [(f'SiegfriedFX_{resource:03}_Flipbook', [x for x in files if x['texture']])]
        else:
            groups = [(f'SiegfriedFX_{resource:03}_{i:03}', [files[i]]) for i in sorted(selection['indices']) if i < len(files)]
        for name, frames in groups:
            retained = []
            for frame in frames:
                if not frame['epb'] or not (args.raw / frame['epb']).is_file():
                    unsupported.append({'model': name, 'frame': frame, 'reason': 'Original contour EPB unavailable; no synthetic quad substituted'})
                    continue
                try:
                    geometry = read_epb(args.raw / frame['epb'])
                    image = read_image((args.raw / frame['texture']).with_suffix('.dds'))
                except (ValueError, OSError, NotImplementedError) as error:
                    unsupported.append({'model': name, 'frame': frame, 'reason': str(error)})
                    continue
                key = frame['texture']
                if key not in images:
                    images[key] = {'image': image, 'source_size': image.size, 'geometry': geometry,
                                   'source_texture': key, 'source_epb': frame['epb']}
                retained.append(key)
            if retained:
                materials.append({'name': name, 'resource': resource, 'frames': retained,
                                  'frame_order': 'ETI texture order', 'stand_ms_per_frame': 50,
                                  'stand_duration': max(400, len(retained) * 50),
                                  'timing_is_warcraft_reconstruction': True, 'skipped_frames': len(frames) - len(retained)})
    textures = args.output / 'Warcraft/Siegfried_FX'
    textures.mkdir(parents=True)
    atlas_source = args.output / 'Info/atlas-source'
    atlas_source.mkdir(parents=True)
    spec = importlib.util.spec_from_file_location('helmet_atlas', Path(__file__).with_name('pack-atlas.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    keys = sorted(images)
    atlases = []
    for page, start in enumerate(range(0, len(keys), 16)):
        part = keys[start:start + 16]
        rows = math.ceil(len(part) / 4)
        height = 256 * (1 << (rows - 1).bit_length())
        atlas = Image.new('RGBA', (1024, height), (0, 0, 0, 0))
        atlas_path = f'Siegfried_FX/Atlas_{page:02}.blp'
        for index, key in enumerate(part):
            item = images[key]
            image = item.pop('image')
            image.thumbnail((240, 240), Image.Resampling.LANCZOS)
            x, y = (index % 4) * 256, (index // 4) * 256
            padded = Image.fromarray(np.pad(np.asarray(image), ((8, 8), (8, 8), (0, 0)), mode='edge'), 'RGBA')
            atlas.paste(padded, (x, y))
            item['atlas'] = atlas_path
            item['atlas_size'] = [1024, height]
            item['rect'] = [x + 8, y + 8, image.width, image.height]
            item['geometry']['mapped_uv'] = [[(x + 8 + u * image.width) / 1024,
                                              (y + 8 + v * image.height) / height] for u, v in item['geometry']['uv']]
        destination = args.output / 'Warcraft' / atlas_path
        levels = module.save_jpeg_blp(atlas, destination)
        atlas.save(atlas_source / f'Atlas_{page:02}.png')
        atlases.append({'path': atlas_path, 'width': 1024, 'height': height, 'mipmaps': levels, 'bytes': destination.stat().st_size})
    originals = args.output / 'Originals'
    for file in (args.raw / 'effect').rglob('*'):
        if file.is_file() and file.suffix in ('.est', '.bxm', '.texture', '.epb', '.eti'):
            destination = originals / file.relative_to(args.raw)
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(file, destination)
    shutil.copy2(args.events, args.output / 'Info/motion-events.json')
    manifest = {'source_effects': effects, 'material_models': materials, 'images': images,
                'atlases': atlases, 'unsupported_frames': unsupported, 'blp_jpeg_quality': 95, 'padding': 8,
                'source_mesh_format': 'EPB TRIL U16 ST0 half-float position/UV',
                'coordinates': 'Source planar origin is centered; image aspect preserved; longest side 240 WC units',
                'source_est_automatic_emission_shader_masks_distortion_not_converted': True,
                'selector_interpretation': 'Color resource and legacy TEX index; kind 0 exposes complete ETI frame set; original EST compositing unverified',
                'warcraft_runtime_tested': False}
    (args.output / 'Info/effects-manifest.json').write_text(json.dumps(manifest, indent=2), encoding='utf8')
    print(json.dumps({'source_est': len(effects), 'material_models': len(materials), 'original_images': len(images),
                      'atlases': len(atlases), 'atlas_bytes': sum(x['bytes'] for x in atlases), 'unsupported_frames': len(unsupported)}))


if __name__ == '__main__':
    main()
