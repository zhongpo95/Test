# 변환한 지크프리트 사운드 청음 목록과 이펙트 소재 미리보기·원본 대응표를 만듭니다.
import argparse
import csv
import html
import json
from collections import Counter, defaultdict
from pathlib import Path

from PIL import Image, ImageDraw, ImageStat


STYLE = '''body{font:16px system-ui;background:#101722;color:#edf2fa;margin:24px auto;max-width:1180px;padding:0 20px}h1{font-size:28px}p{line-height:1.6;color:#b9c8dd}a{color:#8fbeff}input,select,button{font:inherit;padding:9px;background:#202d40;color:#edf2fa;border:1px solid #456080;border-radius:5px;margin:4px}input{min-width:260px}.filters{position:sticky;top:0;background:#101722;padding:12px 0}article{background:#1b2638;padding:14px;margin:12px 0;border-radius:8px}small{color:#b9c8dd}code{overflow-wrap:anywhere}audio{display:block;width:100%;max-width:520px;margin:10px 0}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(270px,1fr));gap:16px}.grid article{margin:0}.grid img{width:256px;max-width:100%}.meta{line-height:1.6;font-size:14px}.missing{color:#ffca88}'''


def page(title, content):
    return '<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>' + title + '</title><style>' + STYLE + '</style><body>' + content + '</body></html>'


def sound_catalog(root):
    manifest = json.loads((root / 'Info/sound-manifest.json').read_text(encoding='utf8'))
    links = json.loads((root / 'Info/hirc-motion-sounds.json').read_text(encoding='utf8'))
    sources, events, motions, groups = defaultdict(set), defaultdict(set), defaultdict(set), defaultdict(set)
    for item in manifest['media']:
        sources[item['file']].add(item['bank'])
    for item in links:
        for file in item['candidate_files']:
            events[file].add(item['event'])
            if item['mdx_sequence']:
                motions[file].add(item['mdx_sequence'])
            if item.get('selection_group'):
                groups[file].add(item['selection_group'])
    data = [{**item, 'language': Path(item['file']).parts[1], 'banks': sorted(sources[item['file']]),
             'events': sorted(events[item['file']]), 'motions': sorted(motions[item['file']]), 'groups': sorted(groups[item['file']])}
            for item in manifest['converted']]
    counts = Counter(x['language'] for x in data)
    scope = html.escape(manifest.get('scope', '전투·필드·마을 대사를 포함합니다.'))
    labels = {'Voice_JP': '일본어 음성', 'Voice_EN': '영어 음성', 'SE': '효과음'}
    summary = ' · '.join(f'{name} {counts[key]:,}개' for key, name in labels.items() if counts[key])
    options = ''.join(f'<option value="{key}">{name}</option>' for key, name in labels.items() if counts[key])
    content = f'<h1>지크프리트 사운드</h1><p>{summary}.<br>{scope} 모션 필터는 원본 사운드 이벤트의 재생 후보를 보여줍니다. 게임의 랜덤 선택·믹싱·음량은 재현하지 않습니다.</p>' + '''
<div class="filters"><input id="search" placeholder="파일명·이벤트·뱅크 검색" aria-label="사운드 검색"><select id="language" aria-label="언어"><option value="">전체 언어</option>''' + options + '''</select><select id="group" aria-label="스킬"><option value="">전체 스킬</option></select><select id="motion" aria-label="모션"><option value="">전체 모션</option></select><span id="count"></span></div><div id="items"></div><button id="more">100개 더 보기</button><p>폴더 구조를 유지하고 이 HTML을 브라우저로 열어 주세요. 맵에는 선택한 MP3/WAV만 가져오면 됩니다. 워크래프트 실제 재생은 미검증입니다.</p>
<script id="data" type="application/json">''' + json.dumps(data, ensure_ascii=False).replace('<', '\\u003c') + '''</script><script>
const data=JSON.parse(document.getElementById('data').textContent);
const search=document.getElementById('search'), language=document.getElementById('language'), group=document.getElementById('group'), motion=document.getElementById('motion'), items=document.getElementById('items'), more=document.getElementById('more');
let limit=100;
const names=[...new Set(data.flatMap(x=>x.motions))].sort((a,b)=>a.localeCompare(b,undefined,{numeric:true}));
for(const name of names){const option=document.createElement('option');option.value=name;option.textContent=name;motion.append(option);}
const groupNames=[...new Set(data.flatMap(x=>x.groups))].sort((a,b)=>a.localeCompare(b,undefined,{numeric:true}));
group.hidden=groupNames.length===0;
for(const name of groupNames){const option=document.createElement('option');option.value=name;option.textContent=name;group.append(option);}
function element(tag,text){const node=document.createElement(tag);if(text!==undefined)node.textContent=text;return node;}
function render(){
 const q=search.value.toLowerCase();
 const filtered=data.filter(x=>(!language.value||x.language===language.value)&&(!group.value||x.groups.includes(group.value))&&(!motion.value||x.motions.includes(motion.value))&&(!q||[x.file,...x.banks,...x.events,...x.motions,...x.groups].join(' ').toLowerCase().includes(q)));
 document.getElementById('count').textContent=filtered.length.toLocaleString()+'개';items.replaceChildren();
 for(const x of filtered.slice(0,limit)){
  const row=element('article'),title=element('code',x.file.split('/').pop()),audio=element('audio');audio.controls=true;audio.preload='none';audio.src=encodeURI(x.file);
  const link=element('a','파일 열기');link.href=encodeURI(x.file);
  row.append(title,element('div',x.language+' · '+x.seconds.toFixed(2)+'초 · '+(x.bytes/1024).toFixed(1)+' KB'),audio,link);
  if(x.events.length)row.append(element('p','이벤트 '+x.events.join(' / ')+' · 모션 '+(x.motions.join(' / ')||'변환 모델에 없는 모션')));
  if(x.groups.length)row.append(element('div',x.groups.join(' / ')));
  row.append(element('small',x.banks.join(' / ')));items.append(row);
 }more.hidden=filtered.length<=limit;
}
for(const control of [search,language,group,motion])control.addEventListener('input',()=>{limit=100;render();});
more.addEventListener('click',()=>{limit+=100;render();});render();
</script>'''
    (root / '사운드_목록.html').write_text(page('지크프리트 사운드', content), encoding='utf8')
    return len(data)


def effect_catalog(root):
    manifest = json.loads((root / 'Info/effects-manifest.json').read_text(encoding='utf8'))
    renders = json.loads((root / 'Info/render-validation.json').read_text(encoding='utf8'))
    models = {x['name']: x for x in manifest['material_models']}
    sheet = Image.new('RGB', (1024, ((len(renders) + 3) // 4) * 158), '#101722')
    draw = ImageDraw.Draw(sheet)
    cards = []
    for i, item in enumerate(renders):
        model = models[item['model']]
        frames = [Image.open(root / 'Info/previews' / name).convert('RGB') for name in item['files']]
        frames[0].save(root / 'Info/previews' / (item['model'] + '.gif'), save_all=True,
                       append_images=frames[1:], duration=round(model['stand_duration'] / len(frames)), loop=0)
        frame = max(frames, key=lambda image: ImageStat.Stat(image.convert('L')).mean[0]).copy()
        frame.thumbnail((140, 140))
        x, y = (i % 4) * 256, (i // 4) * 158
        sheet.paste(frame, (x + 58, y))
        draw.text((x + 4, y + 140), item['model'], fill='#dee8f6')
        name = html.escape(model['name'])
        warning = '<p class="missing">윤곽 파일이 없는 ' + str(model['skipped_frames']) + '개 프레임 제외.</p>' if model['skipped_frames'] else ''
        cards.append('<article><img loading="lazy" src="Info/previews/' + name + '.gif" alt="' + name + '"><h3>' + name + '</h3><div class="meta">원본 리소스 ' + str(model['resource']) + ' · 변환 프레임 ' + str(len(model['frames'])) + '개<br>Stand ' + str(model['stand_duration']) + 'ms · Death 투명<br><a href="Warcraft/' + name + '.mdx">MDX 파일</a></div>' + warning + '</article>')
    sheet.save(root / 'Info/effects-contact.jpg', quality=94)
    content = '<h1>지크프리트 이펙트 소재 32개</h1><p>원본 EST 71개에서 색 텍스처와 EPB 윤곽을 추출한 소재입니다. 완성된 원본 입자 이펙트가 아닙니다.<br>방출·이동·마스크·왜곡·게임 셰이더는 미변환이며, 원본은 Originals에 보존했습니다.<br>GIF는 MDX/BLP를 재읽어 렌더한 6개 시점의 반복 미리보기입니다. Stand는 1회 재생이며, 프레임 순서·크기·시간은 워크래프트용 재구성입니다. 실제 게임의 합성·빌보드·페이드는 미검증입니다.</p><p>맵에 가져올 때 공유 BLP 11개의 경로를 <code>Siegfried_FX\\Atlas_00.blp</code>부터 그대로 지정해 주세요.</p><div class="grid">' + ''.join(cards) + '</div>'
    (root / '이펙트_소재_목록.html').write_text(page('지크프리트 이펙트 소재', content), encoding='utf8')
    with (root / 'Info/material-source-est.csv').open('w', newline='', encoding='utf-8-sig') as handle:
        writer = csv.DictWriter(handle, fieldnames=['source_est', 'entry', 'esp', 'color_resource', 'kind_raw', 'legacy_texture_index', 'candidate_material_models'])
        writer.writeheader()
        for effect in manifest['source_effects']:
            for entry in effect['entries']:
                if 'color' in entry:
                    resource = entry['color']['resource']
                    writer.writerow({'source_est': effect['source'], 'entry': entry['index'], 'esp': entry['esp'],
                                     'color_resource': resource, 'kind_raw': entry['color']['kind_raw'],
                                     'legacy_texture_index': entry.get('legacy_texture_index', ''),
                                     'candidate_material_models': '|'.join(x['name'] + '.mdx' for x in models.values() if x['resource'] == resource)})
    paths = [file.relative_to(root / 'Warcraft').as_posix().replace('/', '\\') for file in sorted((root / 'Warcraft').rglob('*')) if file.is_file()]
    (root / 'import-paths.txt').write_text('\n'.join(paths) + '\n', encoding='utf8')
    return len(cards)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--sound', type=Path, required=True)
    parser.add_argument('--effects', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps({'sound_catalog_rows': sound_catalog(args.sound), 'effect_catalog_rows': effect_catalog(args.effects)}))
