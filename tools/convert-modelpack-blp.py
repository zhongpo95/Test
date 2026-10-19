# 원본을 보존하며 모델팩 이미지를 BLP1으로 변환하고 밉맵·투명도·참조 경로를 검증한다.
import argparse
import hashlib
import io
import json
import math
import re
import shutil
import struct
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageOps


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def normalize_card_art(image):
    # 완전히 투명한 바깥 여백만 제거하고 얼굴이 있는 위쪽을 우선해 정사각형을 채운다.
    box = image.getchannel('A').getbbox()
    if box is None:
        raise ValueError('Empty card illustration')
    cropped = image.crop(box)
    fitted = ImageOps.fit(cropped, (512, 512), Image.Resampling.LANCZOS, centering=(0.5, 0.0))
    return fitted, list(box)


def levels(image):
    yield image
    while image.size != (1, 1):
        image = image.resize(tuple(max(1, n // 2) for n in image.size), Image.Resampling.LANCZOS)
        yield image


def raw_bgra_jpeg(image, quality):
    # BLP1은 일반 JPEG의 YCbCr 대신 B/G/R/A 네 성분을 그대로 사용한다.
    # Pillow의 CMYK 저장 시 반전을 미리 상쇄하고 색상 해석용 APP 마커를 제외한다.
    r, g, b, a = image.split()
    packed = ImageChops.invert(Image.merge('CMYK', (b, g, r, a)))
    stream = io.BytesIO()
    packed.save(stream, format='JPEG', quality=quality, subsampling=0)
    data = stream.getvalue()
    output, pos = bytearray(data[:2]), 2
    while pos < len(data):
        assert data[pos] == 255
        marker = data[pos+1]
        size = int.from_bytes(data[pos+2:pos+4], 'big')
        end = pos + 2 + size
        if marker == 0xDA:
            output.extend(data[pos:])
            break
        if not (0xE0 <= marker <= 0xEF or marker == 0xFE):
            output.extend(data[pos:end])
        pos = end
    return bytes(output)


def decode_raw_bgra_jpeg(data):
    image = Image.open(io.BytesIO(data))
    if image.mode != 'CMYK':
        raise ValueError('BLP JPEG must have four raw BGRA components, not RGB/YCbCr')
    # CMYK->RGB 색 변환이나 Adobe 방식 반전 없이 원시 성분을 읽는다.
    tile = image.tile[0]
    image.tile = [tile._replace(args=('CMYK', ''))]
    image.load()
    b, g, r, a = image.split()
    return Image.merge('RGBA', (r, g, b, a))


def encode(image, quality):
    alpha = image.getchannel('A').getextrema() != (255, 255)
    chunks = []
    if alpha:
        palette = image.convert('RGB').quantize(256, method=Image.Quantize.MEDIANCUT)
        colors = palette.getpalette()
        colors += [0] * (768 - len(colors))
        extra = b''.join(bytes((colors[i+2], colors[i+1], colors[i], 0)) for i in range(0, 768, 3))
        for mip in levels(image):
            indices = mip.convert('RGB').quantize(palette=palette, dither=Image.Dither.FLOYDSTEINBERG)
            chunks.append(indices.tobytes() + mip.getchannel('A').tobytes())
    else:
        extra = struct.pack('<I', 2) + b'\xff\xd8'
        for mip in levels(image):
            data = raw_bgra_jpeg(mip, quality)
            assert data[:2] == b'\xff\xd8'
            chunks.append(data[2:])
    offsets, lengths = [0]*16, [0]*16
    cursor = 156 + len(extra)
    for i, data in enumerate(chunks):
        offsets[i], lengths[i] = cursor, len(data)
        cursor += len(data)
    header = b'BLP1' + struct.pack('<6I', int(alpha), 8 if alpha else 0, *image.size, 4 if alpha else 5, 1)
    return header + struct.pack('<16I', *offsets) + struct.pack('<16I', *lengths) + extra + b''.join(chunks)


def decode_verify(data, original):
    assert data[:4] == b'BLP1'
    compression, alpha, w, h, kind, subtype = struct.unpack_from('<6I', data, 4)
    offsets = struct.unpack_from('<16I', data, 28)
    sizes = struct.unpack_from('<16I', data, 92)
    first = None
    for i, mip in enumerate(levels(original)):
        start, size = offsets[i], sizes[i]
        assert start >= 156 and start + size <= len(data)
        payload = data[start:start+size]
        if compression == 0:
            shared = struct.unpack_from('<I', data, 156)[0]
            decoded = decode_raw_bgra_jpeg(data[160:160+shared] + payload)
            assert decoded.getchannel('A').getextrema() == (255, 255)
        else:
            pixels = mip.width*mip.height
            assert size == pixels*2 and alpha == 8 and kind == 4
            pal = np.frombuffer(data[156:1180], dtype=np.uint8).reshape(256, 4)
            ids = np.frombuffer(payload[:pixels], dtype=np.uint8)
            rgb = pal[ids][:, [2, 1, 0]]
            a = np.frombuffer(payload[pixels:], dtype=np.uint8).reshape(-1, 1)
            decoded = Image.fromarray(np.concatenate((rgb, a), axis=1).reshape(mip.height, mip.width, 4))
            assert decoded.getchannel('A').tobytes() == mip.getchannel('A').tobytes()
        assert decoded.size == mip.size
        if i == 0:
            first = decoded
    assert not any(offsets[i+1:]) and not any(sizes[i+1:])
    # 투명 픽셀의 숨은 RGB 대신 실제 합성 결과로 오차를 측정한다.
    error = 0.0
    for color in ('white', 'black'):
        bg = Image.new('RGBA', original.size, color)
        a = np.asarray(Image.alpha_composite(bg, original).convert('RGB'), dtype=float)
        b = np.asarray(Image.alpha_composite(bg, first).convert('RGB'), dtype=float)
        error = max(error, float(np.mean((a-b)**2)))
    return first, (round(10*math.log10(255**2/error), 2) if error else 99.0), i+1


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--source', type=Path, action='append', required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--quality', type=int, default=90)
    p.add_argument('--normalize-card-art', action='store_true')
    args = p.parse_args()
    registry = (Path(__file__).resolve().parents[1] / 'Data/Data_PrototypeCardImages.j').read_text(encoding='utf8') if args.normalize_card_art else ''
    registered_art = set(re.findall(r'call SetImages\(\d+, "[^"]+", "([^"]+)"', registry))
    args.output.mkdir(parents=True, exist_ok=False)
    target = args.output / 'images' / 'war3mapImported'
    target.mkdir(parents=True)
    preview = args.output / 'preview'
    preview.mkdir()
    files = {}
    for root in args.source:
        for path in sorted(root.glob('*')):
            if path.suffix.lower() not in ('.tga', '.blp'):
                continue
            key = path.stem.lower()
            if key in files:
                raise ValueError(f'Duplicate output name: {path} / {files[key]}')
            files[key] = path
    rows = []
    for n, path in enumerate(files.values(), 1):
        out = target / (path.stem + '.blp')
        row = dict(source=str(path), name=out.name, sourceBytes=path.stat().st_size, sourceSha256=digest(path))
        if path.suffix.lower() == '.blp':
            shutil.copy2(path, out)
            row['encoding'] = 'existing BLP preserved'
        else:
            with Image.open(path) as im:
                original = im.convert('RGBA')
            if args.normalize_card_art and (path.stem in registered_art or (path.name.startswith('UI_Card_') and path.stem.endswith('_Art'))):
                original, box = normalize_card_art(original)
                row['cardArtCrop'] = box
            data = encode(original, args.quality)
            decoded, psnr, mip_count = decode_verify(data, original)
            out.write_bytes(data)
            alpha = original.getchannel('A').getextrema() != (255, 255)
            row.update(encoding='palette256-alpha8' if alpha else f'JPEG-rawBGRA-{args.quality}-444',
                       size=list(original.size), psnr=psnr, mipCount=mip_count, alphaExact=True)
            if n <= 3 or 'karakura_head' in path.stem or 'academy_head' in path.stem or psnr < 30:
                board = Image.new('RGB', (original.width*2, original.height), '#ece9df')
                board.paste(original, (0, 0), original)
                board.paste(decoded, (original.width, 0), decoded)
                board.save(preview / (path.stem + '.png'))
        row.update(outputBytes=out.stat().st_size, outputSha256=digest(out))
        assert digest(path) == row['sourceSha256']
        rows.append(row)
        if n % 100 == 0:
            print(f'{n}/{len(files)}', flush=True)
    report = dict(files=len(rows), sourceBytes=sum(x['sourceBytes'] for x in rows),
                  blpBytes=sum(x['outputBytes'] for x in rows), quality=args.quality,
                  originalFilesPreserved=True, warcraftRuntimeTested=False, rows=rows)
    (args.output/'conversion-report.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf8')
    print(json.dumps({k:v for k,v in report.items() if k!='rows'}), flush=True)


if __name__ == '__main__':
    main()
