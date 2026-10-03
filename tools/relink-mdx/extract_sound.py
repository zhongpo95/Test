# 지크프리트 Wwise 뱅크를 원본 그대로 보존하고 음성 MP3·효과음 WAV와 모션 대응표를 만듭니다.
import argparse
import audioop
import csv
import hashlib
import json
import re
import struct
import subprocess
import sys
import wave
from collections import Counter
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path


def chunks(data, start=0, align=False):
    offset = start
    while offset + 8 <= len(data):
        name, size = struct.unpack_from('<4sI', data, offset)
        end = offset + 8 + size
        if end > len(data):
            raise ValueError('Truncated audio chunk')
        yield name, data[offset + 8:end]
        offset = end + (size % 2 if align else 0)
    if offset not in (len(data), len(data) + 1):
        raise ValueError('Audio chunk alignment mismatch')


def marker(data):
    if data[:4] != b'RIFF' or data[8:12] != b'WAVE':
        raise ValueError('Embedded media is not Wwise RIFF')
    for name, payload in chunks(data, 12, True):
        if name == b'LIST' and payload[:4] == b'adtl':
            for tag, label in chunks(payload, 4, True):
                if tag == b'labl':
                    return label[4:].rstrip(b'\0').decode('utf8')
    return ''


def digest(data):
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--game', type=Path, required=True)
    parser.add_argument('--vgmstream', type=Path, required=True)
    parser.add_argument('--pylibs', type=Path, required=True)
    parser.add_argument('--events', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--work', type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists() or args.work.exists():
        raise FileExistsError('Existing sound output and work are preserved')
    sys.path.insert(0, str(args.pylibs))
    import lameenc
    args.output.mkdir(parents=True)
    args.work.mkdir(parents=True)
    banks = [f for f in (args.game / 'data/sound').rglob('*.bnk')
             if f.stem.startswith(('vo_pl1100', 'pl1100', 'wp1100'))]
    if not banks:
        raise FileNotFoundError('Siegfried banks were not found')
    bank_info, media, jobs = [], [], {}
    for bank in sorted(banks):
        relative = bank.relative_to(args.game / 'data/sound')
        data = bank.read_bytes()
        bank_hash = digest(data)
        destination = args.output / 'Originals/banks' / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(data)
        table = dict(chunks(data))
        index = table.get(b'DIDX', b'')
        if len(index) % 12:
            raise ValueError('Invalid media index')
        bank_info.append({'path': relative.as_posix(), 'sha256': bank_hash, 'media': len(index) // 12})
        for number, (media_id, offset, size) in enumerate(struct.iter_unpack('<III', index)):
            raw = table[b'DATA'][offset:offset + size]
            if len(raw) != size:
                raise ValueError('Media outside bank DATA')
            label = marker(raw)
            language = {'Japanese': 'Voice_JP', 'English(US)': 'Voice_EN', 'SE': 'SE'}[relative.parts[0]]
            key = (language, media_id, digest(raw))
            filename = re.sub(r'[^a-zA-Z0-9_\-]', '_', label or 'unnamed')[:75] + f'_{media_id}'
            extension = '.wav' if language == 'SE' else '.mp3'
            output = Path('Warcraft') / language / (filename + extension)
            if key not in jobs:
                if any(x['file'] == output.as_posix() for x in jobs.values()):
                    raise ValueError('Distinct media collide at an output filename')
                wem = args.work / f'{language}_{media_id}.wem'
                if wem.exists():
                    raise ValueError('Distinct media reuse a language/media ID')
                wem.write_bytes(raw)
                jobs[key] = {'file': output.as_posix(), 'wem': wem}
            media.append({'bank': relative.as_posix(), 'bank_index': number, 'media_id': media_id,
                          'language': language, 'source_marker': label, 'wem_sha256': key[2],
                          'file': jobs[key]['file']})

    def convert(item):
        output = args.output / item['file']
        output.parent.mkdir(parents=True, exist_ok=True)
        native = item['wem'].with_suffix('.wav')
        run = subprocess.run([str(args.vgmstream), '-i', '-I', '-o', str(native), str(item['wem'])],
                             capture_output=True, text=True, encoding='utf8', errors='replace')
        if run.returncode:
            raise RuntimeError(f'{item["wem"].name}: {run.stderr} {run.stdout}')
        info = json.loads(run.stdout)
        with wave.open(str(native)) as handle:
            rate, channels, width, frames = handle.getframerate(), handle.getnchannels(), handle.getsampwidth(), handle.getnframes()
            pcm = handle.readframes(frames)
        if width != 2 or channels not in (1, 2) or frames != info['numberOfSamples']:
            raise ValueError('Unexpected decoded PCM format or sample count')
        if channels == 2:
            pcm = audioop.tomono(pcm, 2, .5, .5)
        target_rate = 22050 if output.suffix == '.wav' else 44100
        converted, state = audioop.ratecv(pcm, 2, 1, rate, target_rate, None)
        if output.suffix == '.wav':
            with wave.open(str(output), 'wb') as handle:
                handle.setparams((1, 2, target_rate, 0, 'NONE', 'not compressed'))
                handle.writeframes(converted)
        else:
            encoder = lameenc.Encoder()
            encoder.set_bit_rate(96)
            encoder.set_in_sample_rate(target_rate)
            encoder.set_channels(1)
            encoder.set_quality(2)
            output.write_bytes(encoder.encode(converted) + encoder.flush())
        verify = subprocess.run([str(args.vgmstream), '-i', '-O', '-I', str(output)],
                                capture_output=True, text=True, encoding='utf8', errors='replace')
        if verify.returncode:
            raise RuntimeError(f'Converted sound decoding failed: {output.name}')
        decoded = json.loads(verify.stdout)
        if decoded['channels'] != 1 or decoded['sampleRate'] != target_rate:
            raise ValueError('Converted sound format mismatch')
        source_duration = frames / rate
        output_duration = decoded['numberOfSamples'] / target_rate
        if abs(output_duration - source_duration) > .1:
            raise ValueError('Converted duration mismatch')
        return {'file': item['file'], 'source_rate': rate, 'source_channels': channels,
                'source_samples': frames, 'seconds': source_duration, 'output_seconds': output_duration,
                'source_loop': info['loopingInfo'], 'output_rate': target_rate, 'output_channels': 1,
                'pcm_rms': audioop.rms(pcm, 2), 'bytes': output.stat().st_size,
                'sha256': digest(output.read_bytes()), 'decoded_all_samples': True}

    converted = {}
    errors = []
    with ThreadPoolExecutor(max_workers=6) as pool:
        futures = {pool.submit(convert, item): item for item in jobs.values()}
        for count, future in enumerate(as_completed(futures), 1):
            item = futures[future]
            try:
                converted[item['file']] = future.result()
            except Exception as error:
                errors.append({'file': item['file'], 'error': str(error)})
            if count % 200 == 0 or count == len(futures):
                print(json.dumps({'decoded': count, 'total': len(futures), 'errors': len(errors)}), flush=True)

    def normalize(name):
        return re.sub(r'(?i)(pl110)\d', r'\g<1>0', name).lower()
    event_links = []
    for event in json.loads(args.events.read_text(encoding='utf8')):
        if event['kind'] != 'se':
            continue
        name = event['attributes'].get('EventName', '')
        normalized = normalize(name)
        candidates = [x for x in media if normalize(x['source_marker']) == normalized
                      or normalize(x['source_marker']).startswith(normalized + '_')]
        event_links.append({**event, 'candidate_files': sorted(set(x['file'] for x in candidates)),
                            'match_basis': 'WEM filename marker prefix; not Wwise HIRC playback resolution'})
    info_folder = args.output / 'Info'
    info_folder.mkdir()
    result = {'banks': bank_info, 'media': media, 'converted': sorted(converted.values(), key=lambda x: x['file']),
              'errors': errors, 'event_links': event_links, 'decoder': 'vgmstream r2117',
              'mp3_encoder': 'lameenc 1.8.4 / LAME', 'loop_export': 'one full pass; original loop metadata preserved',
              'warcraft_runtime_tested': False}
    (info_folder / 'sound-manifest.json').write_text(json.dumps(result, indent=2, ensure_ascii=False), encoding='utf8')
    with (info_folder / 'sound-list.csv').open('w', newline='', encoding='utf-8-sig') as handle:
        writer = csv.DictWriter(handle, fieldnames=['language', 'bank', 'media_id', 'source_marker', 'file', 'seconds', 'bytes'])
        writer.writeheader()
        for item in media:
            meta = converted.get(item['file'], {})
            writer.writerow({key: item.get(key, meta.get(key, '')) for key in writer.fieldnames})
    with (info_folder / 'motion-sounds.csv').open('w', newline='', encoding='utf-8-sig') as handle:
        writer = csv.DictWriter(handle, fieldnames=['motion', 'mdx_sequence', 'start_seconds', 'event', 'candidate_files', 'match_basis'])
        writer.writeheader()
        for event in event_links:
            writer.writerow({'motion': event['motion'], 'mdx_sequence': event['mdx_sequence'],
                             'start_seconds': event['attributes'].get('StartTime', ''),
                             'event': event['attributes'].get('EventName', ''),
                             'candidate_files': '|'.join(event['candidate_files']), 'match_basis': event['match_basis']})
    for bank in banks:
        relative = bank.relative_to(args.game / 'data/sound').as_posix()
        if digest(bank.read_bytes()) != next(x['sha256'] for x in bank_info if x['path'] == relative):
            raise ValueError('Game source bank changed')
    print(json.dumps({'banks': len(banks), 'embedded_media': len(media), 'unique_files': len(converted),
                      'languages': dict(Counter(x['language'] for x in media)), 'errors': len(errors),
                      'bytes': sum(x['bytes'] for x in converted.values()), 'matched_motion_events': sum(bool(x['candidate_files']) for x in event_links)}))
    if errors:
        raise RuntimeError('Some sounds failed; see manifest errors')


if __name__ == '__main__':
    main()
