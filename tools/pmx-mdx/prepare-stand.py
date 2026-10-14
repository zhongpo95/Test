# 사 PMX의 관절 축과 눈 감기 모프를 대기 동작 제작용 자료로 변환합니다.
import argparse, hashlib, importlib.util, json
from pathlib import Path
import numpy as np

p=argparse.ArgumentParser()
p.add_argument('--parser',required=True);p.add_argument('--input',required=True)
p.add_argument('--base',required=True);p.add_argument('--output',required=True)
a=p.parse_args();source=Path(a.input);base=Path(a.base);out=Path(a.output)
if out.exists():raise FileExistsError(out)
spec=importlib.util.spec_from_file_location('pmx_reader',a.parser)
pmx=importlib.util.module_from_spec(spec);spec.loader.exec_module(pmx);model=pmx.load(str(source))
g=json.loads((base/'geometry.json').read_text(encoding='utf8'));conversion=json.loads((base/'conversion.json').read_text(encoding='utf8'))
if hashlib.sha256(source.read_bytes()).hexdigest()!=conversion['source_sha256']:raise ValueError('Source PMX differs from base conversion')
original=np.array([b.location for b in model.bones])[:,[2,0,1]]
converted=np.array([b['pivot'] for b in g['bones']])
scale=np.linalg.norm(converted[35]-converted[32])/np.linalg.norm(original[35]-original[32])
offset=converted[17]-original[17]*scale
if np.max(np.abs(original*scale+offset-converted))>0.0002:raise ValueError('PMX coordinate transform mismatch')
axes=[]
for b in model.bones:
 c=b.localCoordinate
 axes.append({'x':np.array(c.x_axis)[[2,0,1]].tolist(),'z':np.array(c.z_axis)[[2,0,1]].tolist()} if c else None)
blink=next(m for m in model.morphs if m.name=='まばたき')
points=np.array([model.vertices[o.index].co for o in blink.offsets])[:,[2,0,1]]*scale+offset
deltas=np.array([o.offset for o in blink.offsets])[:,[2,0,1]]*scale
visible={tuple(np.round(v*1000).astype(int)) for s in g['surfaces'] for v in np.array(s['vertices'])}
eye_band=(points[:,2]>=converted[17,2]+.6)&(points[:,2]<=converted[17,2]+5.6)&(points[:,0]<converted[17,0]-2.3)&(np.abs(points[:,1]-converted[17,1])>.6)
present=np.array([tuple(np.round(v*1000).astype(int)) in visible for v in points])
points=points[eye_band&present];deltas=deltas[eye_band&present]
if len(points)<500:raise ValueError('Source blink eye mapping is incomplete')
# 가장 먼 변위를 차례로 선택한 뒤 군집 평균을 구해 눈 감기 오차를 제한합니다.
centres=[np.zeros(3)]
for _ in range(95):
 distances=np.min(np.sum((deltas[:,None,:]-np.array(centres)[None,:,:])**2,axis=2),axis=1)
 centres.append(deltas[np.argmax(distances)])
centres=np.array(centres)
for _ in range(25):
 labels=np.argmin(np.sum((deltas[:,None,:]-centres[None,:,:])**2,axis=2),axis=1)
 for i in range(len(centres)):
  if np.any(labels==i):centres[i]=deltas[labels==i].mean(axis=0)
errors=np.linalg.norm(deltas-centres[labels],axis=1)
if errors.max()>0.13:raise ValueError('Blink clustering error exceeds 0.13 Warcraft units')
used=sorted(set(labels));remap={old:new for new,old in enumerate(used)};centres=centres[used];labels=np.array([remap[int(i)] for i in labels])
result={'source_sha256':conversion['source_sha256'],'axes':axes,'blink_centres':centres.tolist(),
 'blink_vertices':[{'position':point.tolist(),'cluster':int(label),'delta':delta.tolist()} for point,label,delta in zip(points,labels,deltas)],
 'blink_error_max':float(errors.max()),'blink_error_mean':float(errors.mean())}
out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(result),encoding='utf8')
print(json.dumps({k:result[k] for k in ['blink_error_max','blink_error_mean']}))
