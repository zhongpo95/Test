# 원본 스킬 모션의 Wwise 호출로 확인된 음성·효과음만 골라 별도 워크래프트 패키지로 만듭니다.
import argparse
import csv
import hashlib
import json
import re
import shutil
from collections import Counter
from pathlib import Path

from build_catalogs import sound_catalog


def sha(file):
    return hashlib.sha256(file.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--sound', type=Path, required=True)
    parser.add_argument('--actions', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--languages', nargs='+', choices=['Voice_JP', 'Voice_EN', 'SE'], default=['Voice_JP', 'SE'])
    args = parser.parse_args()
    if args.output.exists():
        raise FileExistsError('Previous sound deliveries are preserved')
    source_manifest = args.sound / 'Info/sound-manifest.json'
    source_links = args.sound / 'Info/hirc-motion-sounds.json'
    sound = json.loads(source_manifest.read_text(encoding='utf8'))
    links = json.loads(source_links.read_text(encoding='utf8'))
    actions = json.loads(args.actions.read_text(encoding='utf8'))
    abilities = sorted((x for x in actions if any(0x3400 <= int(m, 16) <= 0x347f for m in x['motions'])),
                       key=lambda x: min(int(m, 16) for m in x['motions']))
    if len(abilities) != 8:
        raise ValueError('Expected eight source Siegfried ability actions')
    groups = [{'name': f'스킬 {i + 1} ({action["motions"][0]})', 'action_id': action['id'],
               'source_action_name': action['name'], 'motions': ['pl1100_' + m for m in action['motions']]}
              for i, action in enumerate(abilities)]
    groups.append({'name': '오의 (1800·1810·1820)', 'motions': ['pl1100_1800', 'pl1100_1810', 'pl1100_1820']})
    by_motion = {}
    for group in groups:
        for motion in group['motions']:
            if motion in by_motion:
                raise ValueError('Source skill actions share a motion; selection needs review')
            by_motion[motion] = group['name']
    selected_links = [{**row, 'selection_group': by_motion[row['motion']]}
                      for row in links if row['motion'] in by_motion and row['language'] in args.languages]
    files = {file for row in selected_links for file in row['candidate_files']}
    if not files:
        raise ValueError('No source-linked ability audio was found')
    converted = [x for x in sound['converted'] if x['file'] in files]
    if files != {x['file'] for x in converted} or any(not x['decoded_all_samples'] for x in converted):
        raise ValueError('Selected media is missing or was not fully decoded')
    for item in converted:
        if Path(item['file']).parts[1].startswith('Voice_') and not re.match(r'PL110[02]_vo_(ATK_ability_|SP_charge_)', Path(item['file']).name):
            raise ValueError('Unverified dialogue voice reached the skill selection')
        if sha(args.sound / item['file']) != item['sha256']:
            raise ValueError('Previously validated sound file changed')
    args.output.mkdir(parents=True)
    for item in converted:
        target = (args.output / item['file']).resolve()
        if not target.is_relative_to(args.output.resolve()):
            raise ValueError('Selected media path escaped output')
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(args.sound / item['file'], target)
        if sha(target) != item['sha256']:
            raise ValueError('Selected sound copy differs')
    info = args.output / 'Info'
    info.mkdir()
    selected_media = [x for x in sound['media'] if x['file'] in files]
    used_banks = {x['bank'] for x in selected_media}
    result = {**{k: sound[k] for k in ['decoder', 'mp3_encoder', 'loop_export']},
              'banks': [x for x in sound['banks'] if x['path'] in used_banks],
              'media': selected_media, 'converted': converted, 'errors': [], 'selected_languages': args.languages,
              'selection_groups': groups, 'scope': '스킬 8종과 오의에 호출된 소리만 포함합니다. 필드·마을 대사와 스킬에 호출되지 않는 전투·이동 소리는 제외했습니다.',
              'source_manifest_sha256': sha(source_manifest), 'source_hirc_links_sha256': sha(source_links),
              'source_actions_sha256': sha(args.actions), 'warcraft_runtime_tested': False}
    (info / 'sound-manifest.json').write_text(json.dumps(result, indent=2, ensure_ascii=False), encoding='utf8')
    (info / 'source-skill-actions.json').write_text(json.dumps(abilities, indent=2, ensure_ascii=False), encoding='utf8')
    (info / 'hirc-motion-sounds.json').write_text(json.dumps(selected_links, indent=2, ensure_ascii=False), encoding='utf8')
    with (info / '스킬별_사운드.csv').open('w', newline='', encoding='utf-8-sig') as handle:
        writer = csv.DictWriter(handle, fieldnames=['group', 'motion', 'mdx_sequence', 'start_seconds', 'language', 'event', 'candidate_files'])
        writer.writeheader()
        for row in selected_links:
            writer.writerow({'group': row['selection_group'], 'motion': row['motion'], 'mdx_sequence': row['mdx_sequence'],
                             'start_seconds': row['attributes'].get('StartTime', ''), 'language': row['language'],
                             'event': row['event'], 'candidate_files': '|'.join(row['candidate_files'])})
    unresolved = [x for x in selected_links if x['unresolved_hirc_nodes'] or x['missing_media_ids']]
    report = {'scope': result['scope'], 'groups': groups, 'files': len(converted),
              'language_counts': dict(Counter(Path(x['file']).parts[1] for x in converted)),
              'bytes': sum(x['bytes'] for x in converted), 'source_event_rows': len(selected_links),
              'rows_with_audio': sum(bool(x['candidate_files']) for x in selected_links),
              'unresolved_events': sorted({x['event'] for x in unresolved}),
              'all_selection_files_reachable_from_skill_hirc_events': True, 'all_sha256_match': True,
              'dialogue_voice_markers_excluded': True, 'shared_effects_required_by_skill_events_retained': True,
              'reused_full_decode_validation_by_sha256': True, 'warcraft_runtime_tested': False}
    (info / 'selection-validation.json').write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding='utf8')
    sound_catalog(args.output)
    print(json.dumps({k: report[k] for k in ['files', 'language_counts', 'bytes', 'source_event_rows', 'rows_with_audio', 'unresolved_events']}))


if __name__ == '__main__':
    main()
