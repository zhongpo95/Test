# 확인된 여섯 UI 텍스처만 기존 변환식으로 재출력하고 이전 파일과 전체 해시를 보존합니다.
import argparse
import hashlib
import io
import json
import re
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[3]
REVIEW = Path(__file__).resolve().parent
CANONICAL = Path(r'D:\Work\ARCANA\war3mapImported')
EXPORT = Path(r'D:\Work\ARCANA\assets\head-expansion-20261010\quality-polish\exports\v1')
ARCHIVE = ROOT / 'copy_archive/quality_polish_20261010/image-crop-fix'
SOURCES = ['UI_Card_RGT_11_Art.tga', 'UI_Card_GBF_io_Art.tga',
           'UI_Card_FT_gray-fullbuster_Art.tga', 'UI_Card_FTG_juvia_Art.tga']
HEAD_SOURCE = 'UI_Event_XP_ikebukuro_head.tga'
HEAD_THUMB = 'UI_EventThumb_XP_ikebukuro_head.tga'
MANIFESTS = ['texture-manifest.json', 'thumbnail-manifest.json', 'thumbnail-focus.json']


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def write_json(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def inventory():
    return {str(p.relative_to(CANONICAL)): {'sha256': sha(p), 'bytes': p.stat().st_size}
            for p in sorted(CANONICAL.rglob('*')) if p.is_file()}


def tga_bytes(image):
    data = io.BytesIO()
    image.save(data, format='TGA', compression=None)
    return data.getvalue()


def opaque_resize(image, size, box):
    paper = Image.new('RGBA', size, '#faf8f2')
    paper.alpha_composite(image.resize(size, Image.Resampling.LANCZOS, box=tuple(box)))
    return paper


def update_asset_fields(path, target, changes):
    # 배열 전체를 재직렬화하지 않고 대상 객체에서 지정한 필드만 바꿉니다.
    text = path.read_text(encoding='utf-8')
    decoder = json.JSONDecoder()
    matches = []
    for start in re.finditer(r'^    \{', text, re.M):
        pos = start.start() + 4
        obj, length = decoder.raw_decode(text[pos:])
        if obj.get('target') == target:
            matches.append((pos, pos + length, obj))
    assert len(matches) == 1, (target, len(matches))
    start, end, obj = matches[0]
    block = text[start:end]
    for key, value in changes.items():
        pattern = re.compile(r'^(      "' + re.escape(key) + r'": )', re.M)
        field = pattern.search(block)
        assert field, (target, key)
        value_start = field.end()
        _, old_length = decoder.raw_decode(block[value_start:])
        encoded = json.dumps(value, ensure_ascii=False, indent=2).replace('\n', '\n      ')
        block = block[:value_start] + encoded + block[value_start + old_length:]
    path.write_text(text[:start] + block + text[end:], encoding='utf-8', newline='')
    updated = next(a for a in read(path)['assets'] if a['target'] == target)
    assert all(updated[k] == v for k, v in changes.items())
    return updated


def prepare():
    assert not EXPORT.exists(), '새 내보내기 폴더만 허용합니다.'
    assert not ARCHIVE.exists(), '이전 보존 폴더를 덮어쓰지 않습니다.'
    thumbnail_path = ROOT / 'content/event-images/thumbnail-manifest.json'
    event_path = ROOT / 'content/event-images/texture-manifest.json'
    thumbs = {a['source']: a for a in read(thumbnail_path)['assets']}
    events = {a['target']: a for a in read(event_path)['assets']}
    head_record = events['war3mapImported\\' + HEAD_SOURCE]
    source_original = Path(head_record['sourceFile'])
    assert sha(source_original) == head_record['sourceSha256']
    expected_names = [Path(thumbs['war3mapImported\\' + s]['target'].replace('\\', '/')).name for s in SOURCES]
    expected_names += [HEAD_SOURCE, HEAD_THUMB]
    baseline = inventory()
    assert all(n in baseline for n in expected_names)
    ARCHIVE.mkdir(parents=True)
    (ARCHIVE / 'war3mapImported').mkdir()
    (ARCHIVE / 'metadata').mkdir()
    write_json(ARCHIVE / 'canonical-before.json', baseline)
    for name in expected_names:
        shutil.copy2(CANONICAL / name, ARCHIVE / 'war3mapImported' / name)
        assert sha(ARCHIVE / 'war3mapImported' / name) == baseline[name]['sha256']
    for name in MANIFESTS:
        shutil.copy2(ROOT / 'content/event-images' / name, ARCHIVE / 'metadata' / name)
    EXPORT.mkdir(parents=True)
    destination = EXPORT / 'war3mapImported'
    destination.mkdir()
    changes = []
    for name in SOURCES:
        source = 'war3mapImported\\' + name
        record = thumbs[source]
        target_name = Path(record['target'].replace('\\', '/')).name
        image = Image.open(CANONICAL / name).convert('RGBA')
        assert image.size == (512, 512) and sha(CANONICAL / name) == record['sourceSha256']
        previous = opaque_resize(image, (256, 128), record['crop'])
        assert hashlib.sha256(tga_bytes(previous)).hexdigest() == record['sha256'], name
        new_crop = [0.0, 0.0, 512.0, 288.0]
        output = destination / target_name
        opaque_resize(image, (256, 128), new_crop).save(output, compression=None)
        updated = update_asset_fields(thumbnail_path, record['target'], {
            'crop': new_crop, 'anchor': [0.5, 0.0], 'sha256': sha(output)})
        changes.append({'source': source, 'target': record['target'], 'before': record['sha256'],
                        'after': sha(output), 'bytes': output.stat().st_size, 'reason': '머리와 모자 윗부분을 보존하도록 상단 정렬.'})
    original = Image.open(source_original).convert('RGBA')
    assert original.size == (704, 995)
    previous_source = opaque_resize(original, (256, 256), head_record['viewport'])
    assert hashlib.sha256(tga_bytes(previous_source)).hexdigest() == head_record['sha256']
    new_box = [0, 0, 704, 396]
    new_source = opaque_resize(original, (256, 256), new_box)
    new_source.save(destination / HEAD_SOURCE, compression=None)
    new_source.resize((256, 128), Image.Resampling.LANCZOS).save(destination / HEAD_THUMB, compression=None)
    head_hash = sha(destination / HEAD_SOURCE)
    thumb_hash = sha(destination / HEAD_THUMB)
    update_asset_fields(event_path, head_record['target'], {
        'file': str(destination / HEAD_SOURCE), 'viewport': new_box, 'originalCrop': new_box,
        'sha256': head_hash, 'newHash': head_hash})
    update_asset_fields(thumbnail_path, 'war3mapImported\\' + HEAD_THUMB, {
        'file': str(destination / HEAD_THUMB), 'sourceSha256': head_hash, 'sha256': thumb_hash})
    for name in [HEAD_SOURCE, HEAD_THUMB]:
        output = destination / name
        changes.append({'source': str(source_original), 'target': 'war3mapImported\\' + name,
                        'before': baseline[name]['sha256'], 'after': sha(output), 'bytes': output.stat().st_size,
                        'reason': '중앙 미카도·마사오미·안리와 상단 시즈오의 얼굴을 보존.'})
    focus_path = ROOT / 'content/event-images/thumbnail-focus.json'
    focus = read(focus_path)
    assert all('war3mapImported\\' + name not in focus['overrides'] for name in SOURCES)
    additions = {}
    for name in SOURCES:
        additions['war3mapImported\\' + name] = {'anchor': [0.5, 0.0],
            'reason': '2026-10-10 실제 썸네일 비교. 머리와 모자 윗부분이 잘리지 않도록 상단 정렬.'}
    inserted = json.dumps(additions, ensure_ascii=False, indent=2)[2:-2]
    inserted = '\n'.join('  ' + line for line in inserted.splitlines()) + ',\n'
    focus_text = focus_path.read_text(encoding='utf-8')
    assert focus_text.count('  "overrides": {\n') == 1
    focus_path.write_text(focus_text.replace('  "overrides": {\n', '  "overrides": {\n' + inserted, 1), encoding='utf-8', newline='')
    assert len(read(focus_path)['overrides']) == len(focus['overrides']) + 4
    for name in expected_names:
        output = destination / name
        encoded = output.read_bytes()
        image = Image.open(output)
        assert encoded[2] == 2 and encoded[16] == 32 and image.getchannel('A').getextrema() == (255, 255)
        assert image.size == ((256, 256) if name == HEAD_SOURCE else (256, 128))
    assert inventory() == baseline, '준비 단계에서는 canonical을 바꾸지 않습니다.'
    assert sha(source_original) == head_record['sourceSha256']
    record = {'schemaVersion': 1, 'canonical': str(CANONICAL), 'export': str(EXPORT), 'archive': str(ARCHIVE),
              'canonicalBeforeFiles': len(baseline), 'changedFiles': changes, 'originalPreserved': str(source_original),
              'originalSha256': sha(source_original), 'canonicalInstalled': False, 'mapCreated': False, 'runtimeTested': False}
    write_json(EXPORT / 'change-manifest.json', record)
    write_json(REVIEW / 'texture-change-manifest.json', record)
    # 실제 출력 TGA를 읽어 기존 보존본과 같은 표시 비율로 비교합니다.
    shown = [n for n in expected_names if n != HEAD_SOURCE]
    sheet = Image.new('RGB', (1040, len(shown) * 335), '#e8e3d8')
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.truetype(r'C:\Windows\Fonts\malgun.ttf', 16)
    for i, name in enumerate(shown):
        y = i * 335
        draw.text((10, y + 4), name + ' | 변경 전 → 실제 새 출력', font=font, fill='black')
        for x, file in [(10, ARCHIVE / 'war3mapImported' / name), (530, destination / name)]:
            sheet.paste(Image.open(file).convert('RGB').resize((500, 281)), (x, y + 40))
    sheet.save(REVIEW / 'texture-before-after.png')
    print(json.dumps({'stage': 'prepared', 'files': len(changes), 'baselineFiles': len(baseline), 'canonicalChanged': False}))


def install():
    record = read(REVIEW / 'texture-change-manifest.json')
    baseline = read(ARCHIVE / 'canonical-before.json')
    assert inventory() == baseline, '준비 후 다른 변경이 생겼으면 설치하지 않습니다.'
    changed_names = {Path(a['target'].replace('\\', '/')).name for a in record['changedFiles']}
    for asset in record['changedFiles']:
        name = Path(asset['target'].replace('\\', '/')).name
        output = EXPORT / 'war3mapImported' / name
        assert sha(output) == asset['after']
        assert sha(ARCHIVE / 'war3mapImported' / name) == asset['before']
        shutil.copy2(output, CANONICAL / name)
    after = inventory()
    assert set(after) == set(baseline)
    changed = {name for name in baseline if baseline[name] != after[name]}
    assert changed == changed_names, (changed, changed_names)
    assert sha(Path(record['originalPreserved'])) == record['originalSha256']
    assert sum(a['bytes'] for a in record['changedFiles']) == sum(baseline[n]['bytes'] for n in changed_names)
    write_json(REVIEW / 'canonical-after.json', after)
    record.update(canonicalInstalled=True, preservedOtherFiles=len(baseline)-len(changed),
                  bytesDelta=0, archiveHashesVerified=len(changed), canonicalAfterFiles=len(after))
    write_json(REVIEW / 'texture-change-manifest.json', record)
    write_json(EXPORT / 'change-manifest.json', record)
    print(json.dumps({'stage': 'installed', 'changedFiles': len(changed), 'preservedOtherFiles': record['preservedOtherFiles'],
                      'bytesDelta': 0, 'originalPreserved': True, 'runtimeTested': False}))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('stage', choices=['prepare', 'install'])
    args = parser.parse_args()
    (prepare if args.stage == 'prepare' else install)()
