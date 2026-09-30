# 추출된 지크프리트 텍스처를 알파와 밉맵을 가진 BLP1 파일로 변환합니다.
import argparse
import json
import struct
from pathlib import Path

from PIL import Image


def save_blp(source, destination, maximum=1024):
    image = Image.open(source).convert('RGBA')
    image.thumbnail((maximum, maximum), Image.Resampling.LANCZOS)
    width, height = image.size
    if width & (width-1) or height & (height-1):
        raise ValueError('Classic BLP textures require power-of-two dimensions')
    palette_image = image.convert('RGB').quantize(colors=256)
    palette = palette_image.getpalette()
    palette.extend([0] * (768-len(palette)))
    palette_bytes = b''.join(bytes([palette[i+2],palette[i+1],palette[i],255]) for i in range(0,768,3))
    offsets, sizes, payload = [0]*16, [0]*16, bytearray()
    level = 0
    while True:
        indexed = image.convert('RGB').quantize(palette=palette_image)
        encoded = indexed.tobytes() + image.getchannel('A').tobytes()
        offsets[level] = 156 + 1024 + len(payload)
        sizes[level] = len(encoded)
        payload.extend(encoded)
        level += 1
        if image.width == 1 and image.height == 1:
            break
        image = image.resize((max(1,image.width//2), max(1,image.height//2)), Image.Resampling.LANCZOS)
    header = b'BLP1' + struct.pack('<6I',1,8,width,height,4,1) + struct.pack('<16I',*offsets) + struct.pack('<16I',*sizes)
    destination.parent.mkdir(parents=True, exist_ok=True)
    if destination.exists():
        raise FileExistsError(destination)
    destination.write_bytes(header + palette_bytes + payload)
    return {'file':destination.name,'width':width,'height':height,'mipmaps':level,'alpha_bits':8}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--model-folder', type=Path, required=True)
    args = parser.parse_args()
    model = json.loads((args.model_folder/'conversion.json').read_text())
    report = [save_blp(args.source/(name+'.tga'), args.model_folder/'Siegfried'/(name+'.blp')) for name in model['textures']]
    (args.model_folder/'textures.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
    print(json.dumps(report,indent=2))


if __name__ == '__main__':
    main()
