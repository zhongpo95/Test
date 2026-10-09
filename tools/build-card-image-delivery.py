# 검토된 카드 그림을 보존하고 빠진 엔딩 카드 그림과 임포트 묶음을 만든다.
import argparse
import hashlib
import json
import re
import shutil
import zipfile
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]


def digest(data):
    return hashlib.sha256(data).hexdigest()


def write_json(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf8')


def build(args):
    out = args.output_dir.resolve()
    if out.exists():
        raise ValueError('기존 결과를 보존하기 위해 새 출력 폴더를 지정해야 합니다.')
    out.mkdir(parents=True)
    imports = out / 'war3mapImported'
    imports.mkdir()
    catalog = (ROOT / 'Data/Data_PrototypeCatalog.j').read_text(encoding='utf-8-sig')
    names = {int(i): n for i, n in re.findall(r'set ProtoCardName\[(\d+)\] = "([^"\n]*)"', catalog)}
    keys = {int(i): n for i, n in re.findall(r'set ProtoCardKey\[(\d+)\] = "([^"\n]*)"', catalog)}
    heads = {int(i): int(h) for i, h in re.findall(r'set ProtoCardHead\[(\d+)\] = (\d+)', catalog)}
    groups = {}
    for card, name in sorted(names.items()):
        groups.setdefault((heads[card], name), []).append(card)
    registry = (ROOT / 'Data/Data_PrototypeCardImages.j').read_text(encoding='utf-8-sig')
    images = {int(i): (icon, art) for i, icon, art in re.findall(r'call SetImages\((\d+), "([^"]+)", "([^"]+)"\)', registry)}
    source = args.source_root.resolve()
    previous = source / 'active-images-v27'
    legacy = json.loads((previous / 'texture-manifest.json').read_text(encoding='utf-8-sig'))['assets']
    replacements = []
    replacement_file = ROOT / 'content/card-images/fate-calm-sources.json'
    if replacement_file.exists():
        if args.replacement_root is None:
            raise ValueError('페이트 교체 원본 폴더를 --replacement-root로 지정해야 합니다.')
        replacements = json.loads(replacement_file.read_text(encoding='utf8'))
    superseded = {name for row in replacements for name in (row['oldIcon'], row['oldArt'])}
    assets = []
    with zipfile.ZipFile(previous / 'Arcana_Character_Images_Active_v27.zip') as archive:
        for row in legacy:
            target = row['target'].replace('\\', '/')
            if Path(target).parts != ('war3mapImported', Path(target).name):
                raise ValueError('예상 밖의 임포트 경로 ' + target)
            data = archive.read(target)
            if digest(data) != row['sha256']:
                raise ValueError('기존 그림 해시 불일치 ' + target)
            if Path(target).name in superseded:
                continue
            (out / target).write_bytes(data)
            assets.append({**row, 'file': target, 'preservedFrom': 'active-images-v27'})
    endings = json.loads((ROOT / 'content/card-images/ending-sources.json').read_text(encoding='utf8'))
    originals = out / 'originals'
    originals.mkdir()
    for row in replacements:
        if keys.get(row['cardId']) != row['cardKey'] or names.get(row['cardId']) != row['cardName']:
            raise ValueError('페이트 교체 대상 ID 또는 이름이 변경되었습니다.')
        original = args.replacement_root / 'originals' / row['sourceFile']
        if digest(original.read_bytes()) != row['sourceSha256']:
            raise ValueError('페이트 교체 원본 해시 불일치 ' + row['sourceFile'])
        shutil.copy2(original, originals / row['sourceFile'])
        image = Image.open(original).convert('RGBA')
        for role, size, stem, box in [('icon', 128, row['icon'], row['iconCrop']),
                                     ('portrait', 512, row['art'], row['artCrop'])]:
            if not (0 <= box[0] < box[2] <= image.width and 0 <= box[1] < box[3] <= image.height):
                raise ValueError('원본 밖의 페이트 크롭 ' + row['cardKey'])
            target = 'war3mapImported/' + stem + '.tga'
            image.crop(box).resize((size, size), Image.Resampling.LANCZOS).save(out / target)
            data = (out / target).read_bytes()
            assets.append({'cardIds': [row['cardId']], 'character': row['cardName'], 'role': role,
                           'target': target.replace('/', '\\'), 'file': target, 'size': [size, size],
                           'sha256': digest(data), 'bytes': len(data), 'sourcePage': row['sourcePage'],
                           'sourceUrl': row['sourceUrl'], 'sourceSha256': row['sourceSha256'],
                           'sourceFile': 'originals/' + row['sourceFile'], 'artist': row['credit'],
                           'sourceKind': row['sourceKind'], 'viewport': box,
                           'note': row['reason']})
    for row in endings:
        if keys.get(row['cardId']) != row['cardKey'] or names.get(row['cardId']) != row['cardName']:
            raise ValueError('엔딩 카드 ID 또는 이름이 변경되었습니다. ' + row['cardKey'])
        original = source / 'headcard-wave-20261005' / row['sourceFile']
        if digest(original.read_bytes()) != row['sourceSha256']:
            raise ValueError('원본 그림 해시 불일치 ' + row['sourceFile'])
        shutil.copy2(original, originals / row['sourceFile'])
        image = Image.open(original).convert('RGBA')
        box = row['crop']
        if not (0 <= box[0] < box[2] <= image.width and 0 <= box[1] < box[3] <= image.height):
            raise ValueError('원본 밖의 크롭 ' + row['cardKey'])
        cropped = image.crop(box)
        for role, size, stem in [('icon', 128, row['icon']), ('portrait', 512, row['art'])]:
            target = 'war3mapImported/' + stem + '.tga'
            # 정사각형 크롭을 같은 비율로 변환하며 인물·색상·구도는 추가 편집하지 않는다.
            texture = cropped.resize((size, size), Image.Resampling.LANCZOS)
            texture.save(out / target)
            data = (out / target).read_bytes()
            assets.append({'cardIds': [row['cardId']], 'character': row['cardName'], 'role': role,
                           'target': target.replace('/', '\\'), 'file': target, 'size': [size, size],
                           'sha256': digest(data), 'bytes': len(data), 'sourcePage': row['sourcePage'],
                           'sourceUrl': row['sourceUrl'], 'sourceSha256': row['sourceSha256'],
                           'sourceFile': 'originals/' + row['sourceFile'], 'artist': row['credit'],
                           'sourceKind': '공식 작품 키비주얼', 'viewport': box,
                           'note': '엔딩의 기념 표지이며 결말 장면을 직접 묘사한 삽화는 아니다.'})
    by_file = {Path(a['file']).name: a for a in assets}
    if len(by_file) != len(assets):
        raise ValueError('중복 텍스처 파일 이름이 있습니다.')
    index = []
    for (head, name), cards in groups.items():
        character = cards[0]
        if character not in images:
            raise ValueError('그림 등록이 빠진 카드 ' + name)
        icon, art = images[character]
        for stem in (icon, art):
            if stem + '.tga' not in by_file:
                raise ValueError('임포트 파일이 빠진 카드 ' + name)
        index.append({'characterId': character, 'head': head, 'name': name, 'rewardIds': cards,
                      'icon': icon + '.tga', 'art': art + '.tga',
                      'ending': keys[character].endswith('_ending_memorial')})
    for a in assets:
        p = out / a['file']
        with Image.open(p) as im:
            if list(im.size) != a['size'] or im.mode != 'RGBA':
                raise ValueError('그림 크기 또는 RGBA 형식 불일치 ' + a['file'])
        if digest(p.read_bytes()) != a['sha256']:
            raise ValueError('출력 그림 해시 불일치 ' + a['file'])
    manifest = {'assets': assets, 'catalogSha256': digest((ROOT / 'Data/Data_PrototypeCatalog.j').read_bytes()),
                'registrySha256': digest((ROOT / 'Data/Data_PrototypeCardImages.j').read_bytes()), 'runtimeTested': False}
    write_json(out / 'texture-manifest.json', manifest)
    write_json(out / 'card-index.json', index)
    shutil.copy2(ROOT / 'Data/Data_PrototypeCardImages.j', out / 'Data_PrototypeCardImages.j')
    font = ImageFont.truetype('C:/Windows/Fonts/malgun.ttf', 14)
    preview = out / 'preview'
    preview.mkdir()
    for filename, subset, cols, tile in [('all-cards.jpg', index, 10, 142),
                                         ('ending-cards.jpg', [x for x in index if x['ending']], 5, 234)]:
        sheet = Image.new('RGB', (cols * tile, ((len(subset) + cols - 1) // cols) * (tile + 62)), '#131a24')
        draw = ImageDraw.Draw(sheet)
        for i, row in enumerate(subset):
            x, y = (i % cols) * tile, (i // cols) * (tile + 62)
            im = Image.open(imports / row['art']).convert('RGBA').resize((tile - 10, tile - 10))
            sheet.paste(im, (x + 5, y + 5), im)
            caption, lines = '', []
            for letter in row['name']:
                if draw.textlength(caption + letter, font=font) > tile - 10:
                    lines.append(caption)
                    caption = ''
                caption += letter
            lines.append(caption)
            for line, value in enumerate(lines):
                draw.text((x + 5, y + tile + line * 18), value, fill='#e4d1a8', font=font)
            draw.text((x + 5, y + tile + 40), str(row['characterId']), fill='#98a8b7', font=font)
        sheet.save(preview / filename, quality=93)
    if replacements:
        # 애니메이션판의 상반신과 작은 얼굴 아이콘을 교체 전 그림과 비교한다.
        sheet = Image.new('RGB', (len(replacements) * 220, 444), '#141b25')
        draw = ImageDraw.Draw(sheet)
        with zipfile.ZipFile(previous / 'Arcana_Character_Images_Active_v27.zip') as archive:
            comparison = Image.new('RGB', (len(replacements) * 220, 803), '#141b25')
            compare_draw = ImageDraw.Draw(comparison)
            for i, row in enumerate(replacements):
                x = i * 220 + 10
                art = Image.open(imports / (row['art'] + '.tga')).convert('RGB')
                icon = Image.open(imports / (row['icon'] + '.tga')).convert('RGB')
                sheet.paste(art.resize((200, 200), Image.Resampling.LANCZOS), (x, 40))
                sheet.paste(icon, (x + 36, 268))
                draw.text((x, 8), row['cardName'], font=font, fill='#e8d9b6')
                draw.text((x + 42, 408), '얼굴 아이콘', font=font, fill='#a8bacb')
                old_art = Image.open(archive.open('war3mapImported/' + row['oldArt'])).convert('RGB')
                old_icon = Image.open(archive.open('war3mapImported/' + row['oldIcon'])).convert('RGB')
                comparison.paste(old_art.resize((200, 200), Image.Resampling.LANCZOS), (x, 46))
                comparison.paste(old_icon, (x + 36, 262))
                comparison.paste(art.resize((200, 200), Image.Resampling.LANCZOS), (x, 449))
                comparison.paste(icon, (x + 36, 665))
                compare_draw.text((x, 10), row['cardName'] + ' · 교체 전', font=font, fill='#e8d9b6')
                compare_draw.text((x, 413), '애니메이션판 · 교체 후', font=font, fill='#a8bacb')
        sheet.save(preview / 'fate-anime.jpg', quality=94)
        comparison.save(preview / 'fate-before-after.jpg', quality=94)
    readme = (ROOT / 'content/card-images/README.md').read_text(encoding='utf8')
    (out / 'README.md').write_text(readme, encoding='utf8')
    # 새 카드만 넣을 경우와 최초 전체 적용을 모두 지원하며 압축 내부 경로도 함께 검사한다.
    for filename, selected in [('Arcana_Card_Textures_20261010.zip', assets),
                                ('Arcana_Ending_Card_Textures_20261010.zip', assets[len(legacy) - len(superseded) + len(replacements) * 2:]),
                                ('Arcana_Fate_Calm_Textures_20261010.zip',
                                 [a for a in assets if Path(a['file']).stem in
                                  {stem for row in replacements for stem in (row['icon'], row['art'])}]),
                                ('Arcana_Caster_Robes_Textures_20261010.zip',
                                 [a for a in assets if a.get('cardIds') == [20]
                                  and a.get('sourceKind') == 'ufotable 공식 애니메이션 장면'])]:
        if not selected:
            continue
        with zipfile.ZipFile(out / filename, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as z:
            for a in selected:
                z.write(out / a['file'], a['file'])
            z.write(out / 'texture-manifest.json', 'texture-manifest.json')
            z.write(out / 'card-index.json', 'card-index.json')
            z.write(out / 'README.md', 'README.md')
            z.write(out / 'Data_PrototypeCardImages.j', 'Data_PrototypeCardImages.j')
        with zipfile.ZipFile(out / filename) as z:
            for a in selected:
                if digest(z.read(a['file'])) != a['sha256']:
                    raise ValueError('ZIP 내용 해시 불일치 ' + a['file'])
    report = {'rewardDefinitions': len(names), 'cardPictures': len(index), 'existingPictures': len(legacy) // 2,
              'newEndingPictures': len(endings), 'textureFiles': len(assets), 'missingCards': [],
              'replacedFatePictures': len(replacements), 'preservedExistingHashes': len(legacy) - len(superseded), 'checkedFormat': 'RGBA TGA',
              'zipHashesVerified': True, 'runtimeTested': False, 'mapCreated': False}
    write_json(out / 'validation-report.json', report)
    write_json(ROOT / 'content/card-images/card-index.json', index)
    write_json(ROOT / 'content/card-images/texture-manifest.json', manifest)
    write_json(ROOT / 'content/card-images/validation-report.json', report)
    print(json.dumps(report, ensure_ascii=False))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--source-root', type=Path, required=True)
    parser.add_argument('--replacement-root', type=Path)
    parser.add_argument('--output-dir', type=Path, required=True)
    build(parser.parse_args())
