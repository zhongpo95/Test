# Wwise 이벤트 계층을 따라 모션의 사운드 호출과 추출된 미디어 ID를 연결합니다.
import argparse
import csv
import json
import subprocess
import sys
import xml.etree.ElementTree as ET
from collections import defaultdict
from pathlib import Path


def event_hash(name):
    value = 2166136261
    for byte in name.lower().encode('utf8'):
        value = ((value * 16777619) & 0xffffffff) ^ byte
    return value


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--game', type=Path, required=True)
    parser.add_argument('--wwiser', type=Path, required=True)
    parser.add_argument('--sound', type=Path, required=True)
    parser.add_argument('--events', type=Path, required=True)
    parser.add_argument('--work', type=Path, required=True)
    args = parser.parse_args()
    if args.work.exists():
        raise FileExistsError('Existing HIRC dump is preserved')
    args.work.mkdir(parents=True)
    sound = json.loads((args.sound / 'Info/sound-manifest.json').read_text(encoding='utf8'))
    sources = [args.game / 'data/sound' / x['path'] for x in sound['banks'] if x['media'] == 0]
    sources += [args.game / 'data/sound/core.bnk']
    sources += [x for x in (args.game / 'data/sound/SE').glob('core*.bnk') if not x.stem.endswith('_m')]
    graphs = defaultdict(lambda: defaultdict(list))
    for index, source in enumerate(sources):
        relative = source.relative_to(args.game / 'data/sound')
        language = relative.parts[0] if len(relative.parts) > 1 else 'SE'
        target = args.work / f'{index}_{source.stem}'
        run = subprocess.run([sys.executable, str(args.wwiser), '-d', 'xml', '-dn', str(target), str(source)],
                             capture_output=True, text=True, encoding='utf8', errors='replace')
        if run.returncode:
            raise RuntimeError(run.stdout + run.stderr)
        root = ET.parse(target.with_suffix('.xml')).getroot()
        for item in root.findall('./object/list/object'):
            identity = item.find("./field[@name='ulID']")
            if identity is None:
                continue
            name = item.get('name')
            fields = item.findall('.//field')
            media = [int(x.get('value')) for x in fields if x.get('name') == 'sourceID' and int(x.get('value')) > 0]
            if name == 'CAkEvent':
                references = [int(x.get('value')) for x in fields if x.get('name') == 'ulActionID']
            elif name in ('CAkActionPlay', 'CAkActionPlayAndContinue', 'CAkActionTrigger'):
                references = [int(x.get('value')) for x in fields if x.get('name') == 'idExt']
            elif name.startswith('CAkAction'):
                references = []
            else:
                references = [int(x.get('value')) for x in fields if x.get('name') in ('ulChildID', 'ulPlayID', 'eventID')]
            graphs[language][int(identity.get('value'))].append({'type': name, 'media': media, 'refs': references})
        if (index + 1) % 5 == 0:
            print(json.dumps({'banks_parsed': index + 1, 'total': len(sources)}), flush=True)

    def resolve(language, identity):
        pending, seen, media, missing = [identity], set(), set(), set()
        while pending:
            current = pending.pop()
            if current in seen:
                continue
            seen.add(current)
            nodes = graphs[language].get(current, [])
            if not nodes:
                missing.add(current)
            for node in nodes:
                media.update(node['media'])
                pending.extend(node['refs'])
        return sorted(media), sorted(missing)

    links = []
    common_missing = set()
    events = json.loads(args.events.read_text(encoding='utf8'))
    for event in events:
        if event['kind'] != 'se':
            continue
        name = event['attributes'].get('EventName', '')
        languages = [('Japanese', 'Voice_JP'), ('English(US)', 'Voice_EN')] if name.lower().startswith('pl1100_vo_') else [('SE', 'SE')]
        for language, folder in languages:
            ids, missing = resolve(language, event_hash(name))
            files = sorted({x['file'] for x in sound['media'] if x['language'] == folder and x['media_id'] in ids})
            available = {x['media_id'] for x in sound['media'] if x['language'] == folder}
            unavailable = sorted(set(ids) - available)
            if language == 'SE':
                common_missing.update(unavailable)
            links.append({**event, 'event': name, 'event_hash': event_hash(name), 'language': folder,
                          'candidate_media_ids': ids, 'candidate_files': files, 'missing_media_ids': unavailable,
                          'unresolved_hirc_nodes': missing,
                          'match_basis': 'HIRC event/action/child/source IDs; union of bank versions and alternatives',
                          'mixing_switches_volume_pitch_reproduced': False})
    (args.sound / 'Info/hirc-motion-sounds.json').write_text(json.dumps(links, indent=2, ensure_ascii=False), encoding='utf8')
    with (args.sound / 'Info/hirc-motion-sounds.csv').open('w', newline='', encoding='utf-8-sig') as handle:
        writer = csv.DictWriter(handle, fieldnames=['motion', 'mdx_sequence', 'start_seconds', 'language', 'event', 'candidate_files', 'missing_media_ids', 'unresolved_hirc_nodes'])
        writer.writeheader()
        for item in links:
            writer.writerow({**{k: item[k] for k in ['motion', 'mdx_sequence', 'language', 'event']},
                             'start_seconds': item['attributes'].get('StartTime', ''),
                             'candidate_files': '|'.join(item['candidate_files']),
                             'missing_media_ids': '|'.join(map(str, item['missing_media_ids'])),
                             'unresolved_hirc_nodes': '|'.join(map(str, item['unresolved_hirc_nodes']))})
    (args.work / 'common-media-ids.json').write_text(json.dumps(sorted(common_missing)), encoding='utf8')
    print(json.dumps({'event_language_rows': len(links), 'rows_with_audio': sum(bool(x['candidate_files']) for x in links),
                      'common_missing_ids': len(common_missing), 'unresolved_rows': sum(bool(x['unresolved_hirc_nodes']) for x in links)}))


if __name__ == '__main__':
    main()
