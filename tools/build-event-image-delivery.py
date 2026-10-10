# 공식 사건 이미지의 원본과 구도를 보존하며 표시용 패딩을 제거한 텍스처를 출력한다.
import argparse
import hashlib
import json
import shutil
from collections import Counter
from pathlib import Path, PurePosixPath

from PIL import Image, ImageChops, ImageDraw, ImageFont


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def source_relative(record, group):
    value = str(record['sourceFile']).replace('\\', '/')
    marker = '/official-event-wave-20261005/'
    if marker in value:
        value = value.split(marker, 1)[1]
    elif ':' in value or value.startswith('/'):
        value = group + '/originals/' + PurePosixPath(value).name
    relative = PurePosixPath(value)
    if relative.is_absolute() or '..' in relative.parts or ':' in value:
        raise ValueError('원본 상대 경로가 올바르지 않습니다. ' + value)
    return relative.as_posix()


def resolve_source(record, manifest, source_root):
    relative = source_relative(record, manifest.parent.name)
    candidates = [source_root / relative, source_root / 'event-source-records' / relative,
                  manifest.parent / 'originals' / PurePosixPath(relative).name,
                  manifest.parent / PurePosixPath(relative).name,
                  Path(record['sourceFile'])]
    expected = record['sourceSHA']
    for candidate in candidates:
        if candidate.is_file() and digest(candidate) == expected:
            return candidate, relative
    raise ValueError('해시가 일치하는 원본을 찾지 못했습니다. ' + relative)


def content_bounds(image):
    rgb = image.convert('RGB')
    background = Image.new('RGB', rgb.size, rgb.getpixel((0, 0)))
    return ImageChops.difference(rgb, background).getbbox()


def read_records(source_root):
    records = {}
    manifests = sorted((source_root / 'event-source-records').glob('*/manifest.json'))
    if not manifests:
        raise ValueError('event-source-records의 manifest.json이 없습니다.')
    for manifest in manifests:
        for record in json.loads(manifest.read_text(encoding='utf-8-sig')):
            name = PurePosixPath(record['importPath'].replace('\\', '/')).name
            if name in records:
                raise ValueError('텍스처 기록이 중복되었습니다. ' + name)
            records[name] = (record, manifest)
    return records, manifests


def contact_sheet(assets, output):
    columns, cell_width, cell_height = 5, 280, 210
    sheet = Image.new('RGB', (columns * cell_width,
                             ((len(assets) + columns - 1) // columns) * cell_height), '#faf8f2')
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default(size=13)
    for index, asset in enumerate(assets):
        x, y = (index % columns) * cell_width, (index // columns) * cell_height
        image = Image.open(output / asset['target'].replace('\\', '/')).convert('RGBA')
        aspect = asset['aspectRatio']
        width, height = (250, round(250 / aspect)) if aspect >= 250 / 155 else (round(155 * aspect), 155)
        image = image.resize((width, height), Image.Resampling.LANCZOS)
        sheet.paste(image, (x + (cell_width - width) // 2, y + (160 - height) // 2), image)
        label = PurePosixPath(asset['target'].replace('\\', '/')).stem.replace('UI_Event_', '')
        draw.text((x + 10, y + 163), label, fill='#30382f', font=font)
        draw.text((x + 10, y + 182), f"{aspect:.4f}  {asset['operation']}", fill='#626b5e', font=font)
    sheet.save(output / 'contact-sheet.png')


def run(args):
    source_root, texture_root, output = args.source_root.resolve(), args.texture_root.resolve(), args.output_dir.resolve()
    if output.exists():
        raise ValueError('출력은 기존 파일이 없는 새 폴더여야 합니다.')
    for input_root in (source_root, texture_root):
        if output == input_root or input_root in output.parents:
            raise ValueError('출력 폴더를 입력 폴더 안에 만들 수 없습니다.')
    records, manifests = read_records(source_root)
    catalog = json.loads((source_root / 'event-texture-manifest.json').read_text(encoding='utf-8-sig'))
    names = sorted(PurePosixPath(row['target'].replace('\\', '/')).name for row in catalog)
    if len(set(names)) != len(names):
        raise ValueError('사건 텍스처 목록에 중복이 있습니다.')
    prepared = []
    for name in names:
        if not name.startswith('UI_Event_') or not name.endswith('.tga') or name not in records:
            raise ValueError('사건 텍스처에 대응하는 출처 기록이 없습니다. ' + name)
        record, manifest = records[name]
        source, relative = resolve_source(record, manifest, source_root)
        texture = texture_root / name
        old_hash = digest(texture)
        if old_hash != record['tgaSHA256']:
            raise ValueError('기존 텍스처가 출처 기록과 다릅니다. ' + name)
        original = Image.open(source).convert('RGBA')
        crop = record.get('crop', [0, 0, *original.size])
        if len(crop) != 4 or not (0 <= crop[0] < crop[2] <= original.width and 0 <= crop[1] < crop[3] <= original.height):
            raise ValueError('원본 구도 범위가 잘못되었습니다. ' + name)
        before = Image.open(texture).convert('RGBA')
        bounds = content_bounds(before)
        padded = bounds != (0, 0, *before.size)
        contain = record.get('fitMode') == 'contain'
        if before.size != (256, 256) or padded != contain:
            raise ValueError('알려진 출력 규칙과 다른 텍스처입니다. ' + name)
        prepared.append((name, record, source, relative, texture, old_hash, original, crop, bounds, contain))

    output.mkdir(parents=True)
    (output / 'war3mapImported').mkdir()
    backup = output / 'copy_archive'
    (backup / 'war3mapImported').mkdir(parents=True)
    portable_root = output / 'source-root'
    for manifest in manifests:
        relative_manifest = manifest.relative_to(source_root)
        archived = backup / relative_manifest
        archived.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(manifest, archived)
        portable_records = json.loads(manifest.read_text(encoding='utf-8-sig'))
        for record in portable_records:
            record['sourceFile'] = source_relative(record, manifest.parent.name)
            record['file'] = record['importPath'].replace('\\', '/')
            if record.get('png'):
                record['png'] = PurePosixPath(record['png'].replace('\\', '/')).name
        write_json(portable_root / relative_manifest, portable_records)
    shutil.copy2(source_root / 'event-texture-manifest.json', backup / 'event-texture-manifest.json')
    shutil.copy2(source_root / 'event-texture-manifest.json', portable_root / 'event-texture-manifest.json')

    assets = []
    for name, record, source, relative, texture, old_hash, original, crop, bounds, contain in prepared:
        destination = output / 'war3mapImported' / name
        shutil.copy2(texture, backup / 'war3mapImported' / name)
        original_copy = portable_root / relative
        original_copy.parent.mkdir(parents=True, exist_ok=True)
        if original_copy.exists() and digest(original_copy) != record['sourceSHA']:
            raise ValueError('이동 가능한 원본 경로가 충돌합니다. ' + relative)
        shutil.copy2(source, original_copy)
        if contain:
            # 저장 캔버스만 정규화하며 화면의 aspectRatio가 원본 비율을 복원한다.
            original.crop(crop).resize((256, 256), Image.Resampling.LANCZOS).save(destination, compression=None)
        else:
            shutil.copy2(texture, destination)
        encoded = destination.read_bytes()
        after = Image.open(destination).convert('RGBA')
        if encoded[2] != 2 or encoded[16] != 32 or after.size != (256, 256):
            raise ValueError('RGBA32 비압축 TGA 검증에 실패했습니다. ' + name)
        if contain and content_bounds(after) != (0, 0, 256, 256):
            raise ValueError('출력에 단색 패딩이 남았습니다. ' + name)
        if digest(backup / 'war3mapImported' / name) != old_hash or digest(original_copy) != record['sourceSHA']:
            raise ValueError('원본 보존 검증에 실패했습니다. ' + name)
        new_hash = digest(destination)
        if not contain and new_hash != old_hash:
            raise ValueError('기존 cover 이미지가 변경되었습니다. ' + name)
        assets.append({'target': 'war3mapImported\\' + name,
                       'aspectRatio': round((crop[2] - crop[0]) / (crop[3] - crop[1]), 9) if contain else 1.0,
                       'sourceRelativePath': relative, 'sourceHash': record['sourceSHA'],
                       'originalCrop': crop, 'sourcePage': record['sourcePage'], 'sourceUrl': record['sourceUrl'],
                       'eventKeys': record['eventKeys'], 'oldHash': old_hash, 'newHash': new_hash,
                       'contentBoundsBefore': list(bounds),
                       'operation': 'normalized' if contain else 'preserved'})
    manifest = {'schemaVersion': 1,
                'encoding': '256x256 uncompressed RGBA32; display with aspectRatio', 'assets': assets}
    write_json(output / 'texture-manifest.json', manifest)
    contact_sheet(assets, output)
    report = {'assetCount': len(assets), 'paddingRemoved': sum(a['operation'] == 'normalized' for a in assets),
              'originalBytesPreserved': sum(a['operation'] == 'preserved' for a in assets),
              'sourceHashesVerified': len(assets), 'backupsVerified': len(assets),
              'sourceManifestCount': len(manifests), 'rgba32Decoded': len(assets),
              'contentBoundsBefore': dict(Counter(str(a['contentBoundsBefore']) for a in assets)),
              'outputDirectory': str(output), 'mapCreated': False, 'runtimeTested': False,
              'contactSheet': 'contact-sheet.png', 'portableSourceRoot': 'source-root'}
    write_json(output / 'validation-report.json', report)
    print(json.dumps(report, ensure_ascii=False))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='공식 사건 이미지의 패딩을 제거하고 구도와 출처를 보존합니다.')
    parser.add_argument('--source-root', type=Path, required=True)
    parser.add_argument('--texture-root', type=Path, required=True)
    parser.add_argument('--output-dir', type=Path, required=True)
    run(parser.parse_args())
