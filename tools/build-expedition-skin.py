# 원정 전용 기하학 UI 텍스처와 임포트 목록을 생성한다. 기존 이미지나 맵은 변경하지 않는다.
from pathlib import Path
import hashlib
import json
import zipfile
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/expedition/polish'
DEST = OUT / 'imports'
DEST.mkdir(parents=True, exist_ok=True)

def panel(name, size, color, border, accent=None):
    im = Image.new('RGBA', size, color)
    d = ImageDraw.Draw(im)
    w, h = size
    d.rectangle((0, 0, w-1, h-1), outline=border, width=2)
    if accent:
        d.line((16, 1, min(w-16, 90), 1), fill=accent, width=3)
    return name, im

textures = [
    panel('UI_Arcana_Ink', (256,256), '#111e2b', '#111e2b'),
    panel('UI_Arcana_Panel', (512,512), '#1a2b3b', '#35495b', '#b6a178'),
    panel('UI_Arcana_Selected', (512,512), '#243d50', '#70c9c2', '#b5eee0'),
    panel('UI_Arcana_Button', (512,128), '#24394a', '#496073'),
    panel('UI_Arcana_Active', (512,128), '#385f67', '#89cbbf'),
    panel('UI_Arcana_Paper', (256,256), '#ede9df', '#ede9df'),
    panel('UI_Arcana_Sheet', (512,512), '#faf8f2', '#c9c1b1', '#927346'),
    panel('UI_Arcana_SheetHover', (512,512), '#fffaf0', '#9f8456', '#bda36e'),
    panel('UI_Arcana_Rule', (512,4), '#baac91', '#baac91'),
]
# 출발 화면에 쓰는 추상적인 경로 장식. 문구는 게임 TEXT 프레임으로 표시한다.
im = Image.new('RGBA', (640,800), '#e2e8e3')
d = ImageDraw.Draw(im)
for x in range(-500,800,80):
    d.line((x,0,x+600,800), fill='#d5ded8', width=1)
points=[(100,660),(250,540),(170,350),(440,210),(500,80)]
d.line(points,fill='#607d73',width=3)
for i,(x,y) in enumerate(points):
    d.ellipse((x-13,y-13,x+13,y+13),fill='#e2e8e3',outline='#607d73',width=3)
    d.ellipse((x-4,y-4,x+4,y+4),fill='#b2935a')
textures.append(('UI_Arcana_Route',im))
manifest=[]
for name, im in textures:
    p=DEST/(name+'.tga')
    if name == 'UI_Arcana_Route':
        im = im.resize((1024, 1024), Image.Resampling.LANCZOS)
    im.save(p)
    manifest.append({'file':p.name,'import_path':'war3mapImported\\'+p.name,'size':im.size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(OUT/'texture-manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
with zipfile.ZipFile(OUT/'Arcana_UI_Textures.zip','w',zipfile.ZIP_DEFLATED) as z:
    for p in sorted(DEST.glob('*.tga')): z.write(p,'war3mapImported/'+p.name)
print(f'{len(manifest)} textures generated; no map created.')
