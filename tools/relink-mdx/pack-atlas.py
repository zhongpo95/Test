# 지크프리트 머리갑옷 텍스처를 두 JPEG BLP 아틀라스로 묶습니다.
import argparse
import hashlib
import io
import json
import struct
from pathlib import Path

import numpy as np
from PIL import Image

from textures import eye_diffuse


def save_jpeg_blp(image, destination):
    width, height = image.size
    offsets, sizes, payload = [0]*16, [0]*16, bytearray()
    level = 0
    while True:
        rgba = np.asarray(image)
        # Pillow inverts CMYK samples when writing; BLP expects raw BGRA JPEG components.
        raw = Image.fromarray(255-rgba[:, :, [2, 1, 0, 3]], 'CMYK')
        stream = io.BytesIO()
        raw.save(stream, format='JPEG', quality=95, subsampling=0)
        data = stream.getvalue()
        if data[:2] != b'\xff\xd8':
            raise ValueError('Invalid JPEG header')
        offsets[level], sizes[level] = 162+len(payload), len(data)-2
        payload.extend(data[2:])
        level += 1
        if image.size == (1, 1):
            break
        image = image.resize((max(1, image.width//2), max(1, image.height//2)), Image.Resampling.LANCZOS)
    destination.write_bytes(b'BLP1' + struct.pack('<6I', 0, 8, width, height, 4, 1)
                            + struct.pack('<16I', *offsets) + struct.pack('<16I', *sizes)
                            + struct.pack('<I', 2) + b'\xff\xd8' + payload)
    return level


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--helmet-source', type=Path, required=True)
    parser.add_argument('--model-folder', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists():
        raise FileExistsError('Existing atlas output is preserved')
    model = json.loads((args.model_folder/'conversion.json').read_text(encoding='utf-8'))
    if model.get('body_variant') != 'pl1101':
        raise ValueError('This atlas layout is for the inspected PL1101 helmet model')
    pages = [
        ('Armor', 1024, [('pl1100_armor_lod0_albd', 0, 0, 512),
                         ('pl1100_cloth_lod0_albd', 512, 0, 512),
                         ('pl1100_helm_lod0_albd', 0, 512, 512),
                         ('wp1100_lod0_albd', 512, 512, 512)]),
        ('Face', 512, [('fp1100_face_lod0_albd', 0, 0, 256),
                      ('pl1100_skin_lod0_albd', 256, 0, 256),
                      ('fp1100_l_eye_lod0_warcraft_albd', 0, 256, 128),
                      ('fp1100_r_eye_lod0_warcraft_albd', 128, 256, 128)])]
    planned = {name for _, _, tiles in pages for name, _, _, _ in tiles}
    if planned != set(model['textures']):
        raise ValueError('Texture layout does not match the model')
    args.output.mkdir(parents=True)
    folder = args.output/'Siegfried_Helmet'
    folder.mkdir()
    mapping, atlases = {}, []
    for label, size, tiles in pages:
        atlas = Image.new('RGBA', (size, size), (128, 128, 128, 255))
        atlas_path = 'Siegfried_Helmet/Atlas_'+label+'.blp'
        for name, x, y, slot in tiles:
            if name.endswith('_warcraft_albd'):
                image = eye_diffuse(args.source, name)
                source = 'composited original eye layers'
            else:
                source = (args.helmet_source if '_helm_' in name else args.source)/(name+'.tga')
                image = Image.open(source).convert('RGBA')
            original_size = image.size
            content = slot-16
            image = image.resize((content, content), Image.Resampling.LANCZOS)
            padded = Image.fromarray(np.pad(np.asarray(image), ((8, 8), (8, 8), (0, 0)), mode='edge'), 'RGBA')
            atlas.paste(padded, (x, y))
            mapping[name] = {'atlas':atlas_path, 'width':size, 'height':size,
                             'rect':[x+8, y+8, content, content], 'source':str(source),
                             'source_size':original_size,
                             'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest() if isinstance(source, Path) else None}
        destination = args.output/atlas_path
        atlas.save(str(destination)+'.source.png')
        levels = save_jpeg_blp(atlas, destination)
        atlases.append({'path':atlas_path, 'width':size, 'height':size, 'mipmaps':levels,
                        'bytes':destination.stat().st_size})
    manifest = {'atlases':atlases, 'mapping':mapping, 'quality':95, 'padding':8,
                'warcraft_runtime_tested':False}
    (args.output/'atlas-manifest.json').write_text(json.dumps(manifest, indent=2), encoding='utf-8')
    print(json.dumps({'atlases':atlases, 'total_bytes':sum(a['bytes'] for a in atlases)}))


if __name__ == '__main__':
    main()
