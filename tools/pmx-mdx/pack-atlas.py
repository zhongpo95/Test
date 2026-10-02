# 사의 원본 텍스처를 여백을 둔 공유 아틀라스와 JPEG BLP로 묶습니다.
import argparse,hashlib,io,json,struct
from pathlib import Path
import numpy as np
from PIL import Image
parser=argparse.ArgumentParser();parser.add_argument('--base',required=True,type=Path);parser.add_argument('--output',required=True,type=Path);args=parser.parse_args()
assert not args.output.exists(),'Preserve existing output';args.output.mkdir(parents=True)
names=['Ming2_Base','Ming2_ToonFoot'];geometry={name:json.loads((args.base/name/'geometry.json').read_text(encoding='utf8')) for name in names}
source=lambda name,index:geometry[name]['textures'][index]['source']
shared=[(source(names[0],0),0,0,512),(source(names[0],6),512,0,512),(source(names[0],4),0,512,512),(source(names[0],1),512,512,256),(source(names[0],5),768,512,256),(None,512,768,64)]
pages=[('Common',1024,shared),('Base',512,[(source(names[0],3),0,0,512)]),('ToonFoot',1024,[(source(names[1],0),0,0,512),(source(names[1],4),512,0,512),(source(names[1],8),0,512,512)])]
lookup={};entries=[]
def jpeg_blp(image,file):
 width,height=image.size;offsets=[0]*16;sizes=[0]*16;payload=bytearray();level=0
 while True:
  rgba=np.asarray(image);raw=Image.fromarray(255-rgba[:,:,[2,1,0,3]],'CMYK');stream=io.BytesIO();raw.save(stream,format='JPEG',quality=95,subsampling=0)
  data=stream.getvalue();assert data[:2]==b'\xff\xd8';offsets[level]=162+len(payload);sizes[level]=len(data)-2;payload.extend(data[2:]);level+=1
  if image.size==(1,1):break
  image=image.resize((max(1,image.width//2),max(1,image.height//2)),Image.Resampling.LANCZOS)
 file.write_bytes(b'BLP1'+struct.pack('<6I',0,8,width,height,4,1)+struct.pack('<16I',*offsets)+struct.pack('<16I',*sizes)+struct.pack('<I',2)+b'\xff\xd8'+payload)
 return level
for label,size,tiles in pages:
 atlas=Image.new('RGBA',(size,size),(128,128,128,255));atlas_path='Ming2_Atlas/'+label+'.blp';tile_info=[]
 for src,x,y,tile_size in tiles:
  image=Image.open(src).convert('RGBA') if src else Image.new('RGBA',(1,1),'white');original_size=image.size
  content=tile_size-16;image=image.resize((content,content),Image.Resampling.LANCZOS);padded=Image.fromarray(np.pad(np.asarray(image),((8,8),(8,8),(0,0)),mode='edge'),'RGBA');atlas.paste(padded,(x,y))
  item={'atlas':atlas_path,'width':size,'height':size,'rect':[x+8,y+8,content,content],'source':src,'source_size':original_size,'source_sha256':hashlib.sha256(Path(src).read_bytes()).hexdigest() if src else None}
  lookup[src]=item;tile_info.append(item)
 target=args.output/atlas_path;target.parent.mkdir(exist_ok=True);atlas.save(str(target)+'.source.png');mips=jpeg_blp(atlas,target)
 entries.append({'path':atlas_path,'width':size,'height':size,'bytes':target.stat().st_size,'mipmaps':mips,'encoding':'BLP1 JPEG BGRA quality 95','padding':8,'tiles':tile_info})
mapping={name:[lookup[t['source']] for t in geometry[name]['textures']] for name in names}
manifest={'atlases':entries,'models':mapping,'quality':95,'input':'Original PNG textures, before palette quantization','warcraft_runtime_tested':False}
(args.output/'atlas-manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf8')
print(json.dumps({'atlases':[{k:e[k] for k in ['path','width','height','bytes']} for e in entries],'total_bytes':sum(e['bytes'] for e in entries)},ensure_ascii=True))
