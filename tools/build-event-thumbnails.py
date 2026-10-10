# 사건에 연결된 원본을 보존하고 동일한 가로형 표시 규격의 UI 썸네일을 내보낸다.
import argparse
import hashlib
import json
from pathlib import Path, PureWindowsPath

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
ASPECT = 16 / 9
SIZE = (256, 128)


def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def sources():
    result = set()
    for path in sorted((ROOT / 'content/roguelite').glob('*.json')):
        data = read(path)
        entry = data['world'].get('entryIcon')
        if data['world']['key'] != 'common':
            result.add(entry)
        result.update(event.get('icon') or entry for event in data['events'])
    if None in result:
        raise ValueError('사건에 연결된 원본 그림이 없습니다.')
    return sorted(result)


def export(texture_root, output):
    if output.exists():
        raise ValueError('원본과 이전 결과를 보존하도록 새 출력 폴더를 지정하세요.')
    event_assets = {a['target']: a for a in read(ROOT / 'content/event-images/texture-manifest.json')['assets']}
    card_assets = {a['target']: a for a in read(ROOT / 'content/card-images/texture-manifest.json')['assets']}
    focus = read(ROOT / 'content/event-images/thumbnail-focus.json')
    referenced = sources()
    if set(focus['overrides']) - set(referenced):
        raise ValueError('사용하지 않는 그림의 구도 지정이 있습니다.')
    output.mkdir(parents=True)
    (output / 'war3mapImported').mkdir()
    assets = []
    targets = set()
    for source in referenced:
        name = PureWindowsPath(source).name
        if source != 'war3mapImported\\' + name:
            raise ValueError('원본 그림 경로가 올바르지 않습니다. ' + source)
        path = texture_root / name
        source_hash = sha(path)
        record = event_assets.get(source) or card_assets.get(source)
        if record and source_hash != record.get('newHash', record.get('sha256')):
            raise ValueError('검토한 버전과 다른 원본입니다. ' + source)
        image = Image.open(path).convert('RGBA')
        bounds = image.getchannel('A').getbbox()
        if not bounds:
            raise ValueError('완전히 투명한 그림입니다. ' + source)
        # 전신 컷아웃의 좁은 실루엣은 여백이 아니다. 내부가 불투명한 사각 패딩만 제거한다.
        # 254 알파로 저장된 원본도 있으므로 완전 불투명에 가까운 값까지 허용한다.
        if image.getchannel('A').crop(bounds).getextrema()[0] < 250:
            bounds = (0, 0, image.width, image.height)
        # 저장 비율과 표시 비율이 다른 기존 사건 TGA도 원래 구도로 계산한다.
        source_aspect = event_assets.get(source, {}).get('aspectRatio', image.width / image.height)
        content_aspect = source_aspect * ((bounds[2] - bounds[0]) / image.width) / ((bounds[3] - bounds[1]) / image.height)
        anchor = focus['overrides'].get(source, {'anchor': focus['defaultAnchor']})
        ax, ay = anchor['anchor']
        if not (0 <= ax <= 1 and 0 <= ay <= 1):
            raise ValueError('구도 중심 범위 오류. ' + source)
        left, top, right, bottom = map(float, bounds)
        if content_aspect > ASPECT:
            width = (right - left) * ASPECT / content_aspect
            left += (right - left - width) * ax
            right = left + width
        else:
            height = (bottom - top) * content_aspect / ASPECT
            top += (bottom - top - height) * ay
            bottom = top + height
        crop = [left, top, right, bottom]
        # 이 도구는 UI용 결정적 자산 내보내기이며 원본 일러스트를 덮어쓰지 않는다.
        thumb = image.resize(SIZE, Image.Resampling.LANCZOS, box=tuple(crop))
        paper = Image.new('RGBA', SIZE, '#faf8f2')
        paper.alpha_composite(thumb)
        target = 'war3mapImported\\UI_EventThumb_' + Path(name).stem.removeprefix('UI_') + '.tga'
        if target.lower() in targets:
            raise ValueError('썸네일 출력 경로가 중복되었습니다. ' + target)
        targets.add(target.lower())
        destination = output / PureWindowsPath(target).as_posix()
        paper.save(destination, compression=None)
        encoded = destination.read_bytes()
        decoded = Image.open(destination)
        if encoded[2] != 2 or encoded[16] != 32 or decoded.size != SIZE or decoded.getextrema()[3] != (255, 255):
            raise ValueError('UI 썸네일 형식 검증에 실패했습니다. ' + target)
        if sha(path) != source_hash:
            raise ValueError('내보내기 중 원본이 변경됐습니다. ' + source)
        assets.append({'source': source, 'sourceSha256': source_hash, 'sourceSize': list(image.size),
                       'contentBounds': list(bounds), 'sourceAspect': source_aspect,
                       'crop': [round(x, 6) for x in crop], 'anchor': [ax, ay],
                       'target': target, 'sha256': sha(destination), 'bytes': destination.stat().st_size})
    manifest = {'schemaVersion': 1, 'displayAspect': ASPECT, 'encodedSize': list(SIZE),
                'encoding': 'uncompressed RGBA32 TGA; display at 16:9', 'assets': assets}
    (output / 'thumbnail-manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    # 실제 인게임 가로형 크기로 그린 검토용 연락판. 파일명 번호는 manifest 순서와 같다.
    font = ImageFont.load_default(size=12)
    for first in range(0, len(assets), 30):
        rows = assets[first:first + 30]
        sheet = Image.new('RGB', (5 * 280, ((len(rows) + 4) // 5) * 190), '#ede9df')
        draw = ImageDraw.Draw(sheet)
        for i, asset in enumerate(rows):
            x, y = (i % 5) * 280 + 8, (i // 5) * 190 + 5
            thumb = Image.open(output / PureWindowsPath(asset['target']).as_posix()).convert('RGB').resize((264, 148))
            sheet.paste(thumb, (x, y))
            label = f"{first + i + 1:03d} " + PureWindowsPath(asset['source']).stem.removeprefix('UI_')
            draw.text((x, y + 150), label[:39], fill='#30382f', font=font)
        sheet.save(output / f'contact-{first // 30 + 1:02d}.png')
    report = {'thumbnails': len(assets), 'alphaPaddingRemoved': sum(a['contentBounds'] != [0, 0, *a['sourceSize']] for a in assets),
              'sourceHashesPreserved': len(assets), 'displayAspect': ASPECT, 'encodedSize': list(SIZE),
              'mapCreated': False, 'runtimeTested': False}
    (output / 'validation-report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(report))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='사건 UI 그림을 같은 16:9 규격으로 내보냅니다.')
    parser.add_argument('--texture-root', type=Path, required=True)
    parser.add_argument('--output-dir', type=Path, required=True)
    args = parser.parse_args()
    export(args.texture_root.resolve(), args.output_dir.resolve())
