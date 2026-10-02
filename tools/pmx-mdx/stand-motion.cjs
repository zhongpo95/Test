// 사의 골격과 눈 감기 모프로 흠 동작과 팔짱 대기를 만들고 MDX 반복 경계를 검사합니다.
const fs=require('fs'),path=require('path');
const [deps,input,output,rigFile]=process.argv.slice(2);
const lib=path.join(deps,'viewer/node_modules/mdx-m3-viewer/dist/cjs');
const Model=require(path.join(lib,'parsers/mdlx/model')).default;
const Sequence=require(path.join(lib,'parsers/mdlx/sequence')).default;
const Extent=require(path.join(lib,'parsers/mdlx/extent')).default;
const Bone=require(path.join(lib,'parsers/mdlx/bone')).default;
const Helper=require(path.join(lib,'parsers/mdlx/helper')).default;
const {Vector4Animation,Vector3Animation}=require(path.join(lib,'parsers/mdlx/animations'));
const sanityTest=require(path.join(lib,'utils/mdlx/sanitytest/sanitytest')).default;
const {vec3,quat,mat3,mat4}=require(path.join(deps,'viewer/node_modules/gl-matrix'));
function check(ok,msg){if(!ok)throw Error(msg);}
function read(file){const b=fs.readFileSync(file);return b.buffer.slice(b.byteOffset,b.byteOffset+b.byteLength);}
const geometry=JSON.parse(fs.readFileSync(path.join(input,'geometry.json'),'utf8'));
const rig=JSON.parse(fs.readFileSync(rigFile,'utf8'));
check(rig.source_sha256===JSON.parse(fs.readFileSync(path.join(input,'conversion.json'),'utf8')).source_sha256,'Motion rig source mismatch');
const original=path.join(input,geometry.model+'.mdx');const model=new Model();model.load(read(original));
let nodes=[...model.bones,...model.helpers,...model.attachments];
check(model.sequences.length===1&&nodes.every(n=>n.animations.length===0),'Use the unanimated PMX conversion as input');
const head=nodes.find(n=>n.name===geometry.bones.find(b=>b.source_name==='頭').name).objectId;
const blinkBones=rig.blink_centres.map((delta,i)=>{
 const bone=new Bone();bone.name='Blink_'+String(i).padStart(3,'0');bone.objectId=nodes.length+i;bone.parentId=head;
 model.bones.push(bone);model.pivotPoints.push(new Float32Array(model.pivotPoints[head]));return {bone,delta};
});
const ordered=[...model.bones,...model.helpers,...model.attachments],ids=new Map(ordered.map((n,i)=>[n.objectId,i]));
model.pivotPoints=ordered.map(n=>model.pivotPoints[n.objectId]);
ordered.forEach(n=>{n.parentId=n.parentId>=0?ids.get(n.parentId):-1;n.objectId=ids.get(n.objectId);});nodes=ordered;
const pointKey=p=>Array.from(p,v=>Math.round(v*1000)).join(',');
const blinkMap=new Map(rig.blink_vertices.map(v=>[pointKey(v.position),v.cluster]));
let blinkVertices=0;
const altered=new Map();
for(let gi=0;gi<model.geosets.length;gi++){
 const g=model.geosets[gi],groups=[];let offset=0;
 for(const count of g.matrixGroups){groups.push(Array.from(g.matrixIndices.slice(offset,offset+count),id=>ids.get(id)));offset+=count;}
 const merged=new Map(),values=[],vertexGroups=[];const affected=[];
 for(let i=0;i<g.vertices.length/3;i++){
  const cluster=blinkMap.get(pointKey(g.vertices.slice(i*3,i*3+3)));let group=groups[g.vertexGroups[i]];
  if(cluster!==undefined){group=new Array(4).fill(blinkBones[cluster].bone.objectId);affected.push(i);blinkVertices++;}
  const key=group.join(',');if(!merged.has(key)){merged.set(key,values.length);values.push(group);}vertexGroups.push(merged.get(key));
 }
 check(values.length<=256,'Blink exceeds classic matrix group limit');
 g.vertexGroups=new Uint8Array(vertexGroups);g.matrixGroups=new Uint32Array(values.map(g=>g.length));g.matrixIndices=new Uint32Array(values.flat());altered.set(gi,new Set(affected));
}
check(blinkVertices>500,'Blink vertex mapping failed');
const weightedIds=new Set(model.geosets.flatMap(g=>Array.from(g.matrixIndices)));
const unusedBones=model.bones.filter(b=>!weightedIds.has(b.objectId));
model.bones=model.bones.filter(b=>weightedIds.has(b.objectId));
for(const b of unusedBones){const h=new Helper();h.name=b.name;h.objectId=b.objectId;h.parentId=b.parentId;h.flags=b.flags&~0x100;model.helpers.push(h);}
const finalOrder=[...model.bones,...model.helpers,...model.attachments],finalIds=new Map(finalOrder.map((n,i)=>[n.objectId,i]));
model.pivotPoints=finalOrder.map(n=>model.pivotPoints[n.objectId]);
for(const g of model.geosets)g.matrixIndices=new Uint32Array(Array.from(g.matrixIndices,id=>finalIds.get(id)));
for(const n of finalOrder){n.parentId=n.parentId>=0?finalIds.get(n.parentId):-1;n.objectId=finalIds.get(n.objectId);}
for(const [old,id] of ids)ids.set(old,finalIds.get(id));nodes=finalOrder;
const sourceIds=geometry.bones.map(b=>nodes.findIndex(n=>n.name===b.name));
const byName=new Map(geometry.bones.map((b,i)=>[b.source_name,sourceIds[i]]));
const get=name=>{check(byName.has(name),'Missing joint '+name);return byName.get(name);};
const pivot=i=>Array.from(model.pivotPoints[i]);
const sub=(a,b)=>vec3.subtract([],a,b),add=(a,b)=>vec3.add([],a,b);
const scale=(a,s)=>vec3.scale([],a,s),norm=a=>vec3.normalize([],a);
const mul=(a,b)=>quat.normalize([],quat.multiply([],a,b));
const inv=a=>quat.invert([],a);
const axis=(a,deg)=>quat.setAxisAngle([],norm(a),deg*Math.PI/180);
const identity=[0,0,0,1];
const sourceAxis=(id,key)=>rig.axes[geometry.bones.findIndex(b=>b.name===nodes[id].name)]?.[key];
const chest=pivot(get('上半身2')),centre=chest[1];
function basis(direction,width){
 const y=norm(direction),x=norm(sub(width,scale(y,vec3.dot(width,y)))),z=norm(vec3.cross([],x,y));
 return mat3.fromValues(...x,...y,...z);
}
function orient(fromDirection,fromWidth,toDirection,toWidth){
 const r=mat3.multiply([],basis(toDirection,toWidth),mat3.transpose([],basis(fromDirection,fromWidth)));
 return quat.normalize([],quat.fromMat3([],r));
}
function solveArm(shoulder,elbow,wrist,target,pole,restShoulder){
 const l1=vec3.distance(restShoulder,elbow),l2=vec3.distance(elbow,wrist),delta=sub(target,shoulder);
 const distance=Math.min(l1+l2-0.05,Math.max(Math.abs(l1-l2)+0.05,vec3.length(delta))),direction=norm(delta);
 const actual=add(shoulder,scale(direction,distance)),a=(l1*l1-l2*l2+distance*distance)/(2*distance);
 const bend=norm(sub(sub(pole,shoulder),scale(direction,vec3.dot(sub(pole,shoulder),direction))));
 const joint=add(add(shoulder,scale(direction,a)),scale(bend,Math.sqrt(Math.max(0,l1*l1-a*a))));
 return {elbow:joint,wrist:actual};
}
function smooth(x){return x*x*x*(10+x*(-15+6*x));}
function envelope(t,keys){
 for(let i=1;i<keys.length;i++)if(t<=keys[i][0]){const [a,v]=keys[i-1],[b,w]=keys[i];return v+(w-v)*smooth((t-a)/(b-a));}
 return keys.at(-1)[1];
}
const gestureKeys=[[0,0],[0.85,0],[2.5,1],[3.65,1],[5,0],[7,0]];
const arms=['左','右'].map((side,index)=>{
 const prefix=index===0?'L':'R';
 const joint={side,prefix,index,upper:get(side+'腕'),elbow:get(side+'ひじ'),wrist:get(side+'手首'),twist:get(side+'腕捩'),halfTwist:get(side+'腕捩1'),foreTwist:get(side+'手捩'),halfForeTwist:get(side+'手捩1')};
 joint.finger=get(side+'中指１');joint.tip=get(side+'中指３');joint.width=sub(pivot(get(side+'小指１')),pivot(get(side+'人指１')));
 joint.direction=sub(pivot(joint.tip),pivot(joint.finger));return joint;
});
function author(t,kind){
 const rotations=nodes.map(()=>identity.slice()),translations=nodes.map(()=>[0,0,0]),worldQ=[],worldM=[];
 const breathe=Math.sin(t*2*Math.PI/(kind==='cross'?4:7));
 const gesture=kind==='hmm'?envelope(t,gestureKeys):0;
 const bob=kind==='hmm'?envelope(t,[[0,0],[2.5,0],[2.9,1],[3.25,0],[7,0]]):0;
 const close=kind==='hmm'?envelope(t,[[0,0],[2.35,0],[2.5,1],[3.22,1],[3.45,0],[7,0]]):envelope(t,[[0,0],[2.8,0],[2.9,1],[3,1],[3.14,0],[4,0]]);
 const speed=kind==='hmm'?(envelope(t+0.025,gestureKeys)-envelope(t-0.025,gestureKeys))/0.05:0;
 blinkBones.forEach(({bone,delta})=>{translations[bone.objectId]=scale(delta,close);});
 function reset(){worldQ.length=0;worldM.length=0;}
 function resolve(i){
  if(worldM[i])return;
  const n=nodes[i],p=n.parentId;if(p>=0)resolve(p);
  const local=mat4.fromRotationTranslationScaleOrigin([],rotations[i],translations[i],[1,1,1],pivot(i));
  worldQ[i]=p>=0?mul(worldQ[p],rotations[i]):rotations[i];
  worldM[i]=p>=0?mat4.multiply([],worldM[p],local):local;
 }
 function setWorld(i,q){const parent=nodes[i].parentId;if(parent>=0)resolve(parent);rotations[i]=parent>=0?mul(inv(worldQ[parent]),q):q;reset();}
 function transformed(i){resolve(i);return vec3.transformMat4([],pivot(i),worldM[i]);}
 rotations[get('上半身1')]=axis([0,1,0],0.25*breathe);
 rotations[get('上半身2')]=axis([0,1,0],0.35*breathe);
 rotations[get('首')]=axis([0,1,0],kind==='hmm'?(-2.5*gesture-1.2*bob):0.35*breathe);
 rotations[get('頭')]=mul(axis([0,0,1],kind==='hmm'?-1.5*gesture:5+0.3*breathe),axis([0,1,0],kind==='hmm'?-1.8*gesture-0.8*bob:0));
 for(const arm of arms){
  const left=arm.index===0,sign=left?1:-1;
  const s=transformed(arm.upper),e=pivot(arm.elbow),w=pivot(arm.wrist);
  let target,pole,fingers,width,curl;
  if(kind==='cross'){
   target=left?[chest[0]-6.7,centre-7.0,chest[2]+0.4]:[chest[0]-7.6,centre+4.5,chest[2]+4.2];
   pole=[chest[0]-6.5,centre+sign*15,chest[2]-6.8];
   fingers=left?[0.85,-0.65,0.28]:[0.3,1,0.35];width=[0,0,sign];curl=left?0.75:0.4;
  }else{
   curl=left?0.22+0.78*envelope(t,[[0,0],[0.9,0],[1.8,1],[3.8,1],[5.2,0],[7,0]]):0.22;
  }
  let solved;
  if(kind==='cross'){target[2]+=0.12*breathe;solved=solveArm(s,e,w,target,pole,pivot(arm.upper));}
  else{
   // 팔꿈치를 낮게 유지하고 아래팔을 앞으로 돌려 IK의 굽힘 방향 반전을 없앱니다.
   const upperLength=vec3.distance(pivot(arm.upper),e),foreLength=vec3.distance(e,w),amount=left?gesture:0;
   const down=norm([-0.12,sign*0.03,-1]),raised=norm([-0.5,sign*0.05,-0.866]);
   const elbowDown=add(s,scale(down,upperLength)),elbowRaised=add(s,scale(raised,upperLength));
   const idleDirection=norm(sub([chest[0]-0.8,centre+sign*10,chest[2]-20.5],elbowDown));
   const raisedDirection=norm(sub([chest[0]-6.8,centre+2.5,chest[2]+12.3],elbowRaised));
   const startAngle=Math.atan2(-idleDirection[0],-idleDirection[2]),endAngle=Math.atan2(-raisedDirection[0],-raisedDirection[2]);
   const angle=startAngle+((endAngle<0?endAngle+2*Math.PI:endAngle)-startAngle)*amount;
   const lateral=idleDirection[1]+(raisedDirection[1]-idleDirection[1])*amount,planar=Math.sqrt(1-lateral*lateral);
   const fore=[-Math.sin(angle)*planar,lateral,-Math.cos(angle)*planar];
   const elbow=add(s,scale(norm(vec3.lerp([],down,raised,amount)),upperLength));
   solved={elbow,wrist:add(elbow,scale(fore,foreLength))};
  }
  const upperRotation=orient(sub(e,pivot(arm.upper)),[-1,0,0],sub(solved.elbow,s),[-1,0,0]);
  setWorld(arm.upper,upperRotation);
  resolve(get('上半身2'));const bodyRotation=worldQ[get('上半身2')];
  for(const ornament of ['cloudA_01_jnt','cloudB_01_jnt'])setWorld(get(arm.prefix+'_'+ornament),bodyRotation);
  const hangingSleeve=orient(sub(e,pivot(arm.upper)),[-1,0,0],[0.03,sign*0.12,-1],[-1,0,0]);
  const sleeveRotation=quat.slerp([],hangingSleeve,upperRotation,0.18);
  for(const part of ['sleeveA_01_jnt','sleeveB_01_jnt','sleeveC_jnt','sleeveF_01_jnt','sleeve_all_jnt'])setWorld(get(arm.prefix+'_'+part),sleeveRotation);
  const foreDirection=norm(sub(solved.wrist,solved.elbow));
  const foreWidth=kind==='hmm'?norm(vec3.cross([],[0,-sign,0],foreDirection)):[1,0,0];
  const foreRotation=orient(sub(w,e),arm.width,foreDirection,foreWidth);
  setWorld(arm.elbow,foreRotation);
  if(kind==='hmm'){width=vec3.transformQuat([],foreWidth,axis(foreDirection,left?90*gesture:0));fingers=foreDirection;}
  const foreFull=orient(sub(w,e),arm.width,foreDirection,width);
  setWorld(arm.foreTwist,foreFull);setWorld(arm.halfForeTwist,quat.slerp([],foreRotation,foreFull,0.5));
  const handRotation=orient(arm.direction,arm.width,fingers,width);
  setWorld(arm.wrist,handRotation);
  for(const [f,finger] of ['人指','中指','薬指','小指'].entries())for(let segment=1;segment<=3;segment++){
   const name=arm.side+finger+['','１','２','３'][segment];
   const id=get(name),bend=sourceAxis(id,'z');
   const align=segment===1?quat.rotationTo([],norm(sub(pivot(get(arm.side+finger+'２')),pivot(id))),norm(arm.direction)):identity;
   rotations[id]=mul(axis(bend,sign*curl*([0,65+f*3,88,58][segment])),align);
  }
  const thumb=get(arm.side+'親指０'),thumbNext=get(arm.side+'親指１');
  const thumbCurl=kind==='cross'?0.85:curl;
  rotations[thumb]=quat.slerp([],identity,quat.rotationTo([],norm(sub(pivot(thumbNext),pivot(thumb))),norm(add(arm.direction,scale(arm.width,0.32)))),thumbCurl);
  rotations[thumbNext]=axis(arm.width,-sign*thumbCurl*22);
  rotations[get(arm.side+'親指２')]=axis(arm.width,-sign*thumbCurl*40);reset();
  const cloth=get(arm.prefix+'_sleeveD_01_jnt_1'),next=get(arm.prefix+'_sleeveD_01_jnt_2');
  const sway=0.025*breathe+0.04*speed;
  setWorld(cloth,quat.rotationTo([],norm(sub(pivot(next),pivot(cloth))),norm([0.09+0.035*speed,sign*0.04+sway,-1])));
  for(const segment of [5,10,15,20,25])rotations[get(arm.prefix+'_sleeveD_01_jnt_'+segment)]=axis([0,1,0],0.10*Math.sin(2*Math.PI*t/(kind==='cross'?4:7)-segment*0.12)+0.14*speed);
  if(left){const hem=get('L_sleeveI_01_jnt'),hemEnd=get('L_sleeveI_02_jnt');
   setWorld(hem,quat.rotationTo([],norm(sub(pivot(hemEnd),pivot(hem))),norm([0.08,sign*0.15,-1])));
  }
 }
 for(const [prefix,sign] of [['L',1],['R',-1]]){
  rotations[get(prefix+'_hairE_jnt1')]=mul(axis([0,1,0],4+0.45*breathe+1.2*gesture),axis([1,0,0],-sign*(6+0.4*breathe)));
  for(const segment of [5,9,13])rotations[get(prefix+'_hairE_jnt'+segment)]=axis([0,1,0],0.32*Math.sin(2*Math.PI*t/(kind==='cross'?4:7)-segment*0.18)+0.3*speed);
  rotations[get(prefix+'_hairC_02_jnt')]=axis([0,1,0],0.2*breathe+0.25*speed);
 }
 rotations[get('tail_jnt1')]=axis([0,0,1],0.9*breathe);
 reset();for(let i=0;i<nodes.length;i++)resolve(i);
 return {rotations,translations,matrices:worldM};
}
function skin(matrices){
 return model.geosets.map(g=>{
  const groups=[];let offset=0;
  for(const count of g.matrixGroups){const ids=Array.from(g.matrixIndices.slice(offset,offset+count));const m=new Array(16).fill(0);for(const id of ids)for(let k=0;k<16;k++)m[k]+=matrices[id][k]/count;groups.push(m);offset+=count;}
  const vertices=[],normals=[];
  for(let i=0;i<g.vertices.length;i+=3){const m=groups[g.vertexGroups[i/3]];vertices.push(vec3.transformMat4([],g.vertices.slice(i,i+3),m));normals.push(norm(vec3.transformMat3([],g.normals.slice(i,i+3),mat3.fromMat4([],m))));}
  return {vertices,normals,uv:Array.from({length:g.uvSets[0].length/2},(_,i)=>[g.uvSets[0][2*i],1-g.uvSets[0][2*i+1]]),faces:Array.from({length:g.faces.length/3},(_,i)=>Array.from(g.faces.slice(i*3,i*3+3))),material:g.materialId};
 });
}
function extent(){const e=new Extent();e.min.fill(Infinity);e.max.fill(-Infinity);return e;}
function include(e,vertices){for(const p of vertices){for(let k=0;k<3;k++){e.min[k]=Math.min(e.min[k],p[k]);e.max[k]=Math.max(e.max[k],p[k]);}e.boundsRadius=Math.max(e.boundsRadius,Math.hypot(...p));}}
const clips=[{name:'Stand - 1',kind:'hmm',start:0,duration:7000,reference:[108,115]},{name:'Stand - 2',kind:'cross',start:8000,duration:4000,reference:[96,97]}];
model.sequences=[];model.extent=extent();model.geosets.forEach(g=>g.sequenceExtents=[]);
const keys=nodes.map(()=>({frames:[],values:[],translations:[]}));
for(const clip of clips){
 const seq=new Sequence();seq.name=clip.name;seq.interval=new Uint32Array([clip.start,clip.start+clip.duration]);seq.extent=extent();
 model.sequences.push(seq);const extents=model.geosets.map(()=>extent());
 for(let ms=0;ms<=clip.duration;ms+=50){
  const pose=author(ms/1000,clip.kind);
  pose.rotations.forEach((q,i)=>{const prev=keys[i].values.at(-1);if(prev&&quat.dot(prev,q)<0)q=q.map(v=>-v);keys[i].frames.push(clip.start+ms);keys[i].values.push(q);keys[i].translations.push(pose.translations[i]);});
  const skinned=skin(pose.matrices);
  skinned.forEach((g,i)=>{include(extents[i],g.vertices);include(seq.extent,g.vertices);include(model.extent,g.vertices);});
 }
 model.geosets.forEach((g,i)=>g.sequenceExtents.push(extents[i]));
}
function pad(e){for(let k=0;k<3;k++){e.min[k]-=0.2;e.max[k]+=0.2;}e.boundsRadius+=0.4;}
model.geosets.forEach(g=>{g.extent=extent();for(const e of g.sequenceExtents){include(g.extent,[Array.from(e.min),Array.from(e.max)]);pad(e);}pad(g.extent);});
model.sequences.forEach(s=>pad(s.extent));pad(model.extent);
let tracks=0,translationTracks=0;
let maxKeyRotation=0;
keys.forEach(key=>{for(let j=1;j<key.frames.length;j++)if(key.frames[j]-key.frames[j-1]===50)maxKeyRotation=Math.max(maxKeyRotation,2*Math.acos(Math.min(1,Math.abs(quat.dot(key.values[j],key.values[j-1]))))*180/Math.PI);});
check(maxKeyRotation<12,'Abrupt skeletal rotation between adjacent keys');
nodes.forEach((node,i)=>{
 if(!keys[i].values.every(q=>Math.abs(quat.dot(q,identity))>0.99999999)){
  const a=new Vector4Animation();a.name='KGRT';a.interpolationType=1;a.frames=keys[i].frames;a.values=keys[i].values.map(q=>new Float32Array(q));node.animations.push(a);tracks++;
 }
 if(keys[i].translations.some(p=>vec3.length(p)>0.000001)){
  const a=new Vector3Animation();a.name='KGTR';a.interpolationType=1;a.frames=keys[i].frames;a.values=keys[i].translations.map(p=>new Float32Array(p));node.animations.push(a);translationTracks++;
 }
});
fs.mkdirSync(output,{recursive:true});const file=path.join(output,geometry.model+'.mdx');check(!fs.existsSync(file),'Preserve existing output');
fs.writeFileSync(file,Buffer.from(model.saveMdx()));const decoded=new Model();decoded.load(read(file));
check(Buffer.from(decoded.saveMdx()).equals(fs.readFileSync(file)),'MDX roundtrip mismatch');
const decodedNodes=[...decoded.bones,...decoded.helpers,...decoded.attachments];
const csv=value=>/[",\r\n]/.test(String(value))?'"'+String(value).replaceAll('"','""')+'"':String(value);
const boneRows=[['source_bone_index','source_bone_name','mdx_node_id','mdx_node_name','parent_source_index','pivot_X','pivot_Y','pivot_Z']];
geometry.bones.forEach((b,i)=>boneRows.push([i,b.source_name,sourceIds[i],b.name,b.parent,...b.pivot]));
blinkBones.forEach(({bone})=>boneRows.push(['',bone.name,bone.objectId,bone.name,geometry.bones.findIndex(b=>b.source_name==='頭'),...pivot(bone.objectId)]));
fs.writeFileSync(path.join(output,geometry.model+'_bones.csv'),'\ufeff'+boneRows.map(row=>row.map(csv).join(',')).join('\n')+'\n');
for(let i=0;i<geometry.bones.length;i++)if(/(嘴|Jaw|Tongue|tooth)/.test(geometry.bones[i].source_name))check(decodedNodes[sourceIds[i]].animations.length===0,'Mouth joint animated');
function decodedPose(time){
 const matrices=[];
 function resolve(i){if(matrices[i])return;const n=decodedNodes[i],p=n.parentId;if(p>=0)resolve(p);
  let q=identity;const a=n.animations.find(a=>a.name==='KGRT');
  if(a){let j=0;while(j+1<a.frames.length&&a.frames[j+1]<=time)j++;q=a.values[j];if(j+1<a.frames.length&&time>a.frames[j])q=quat.slerp([],q,a.values[j+1],(time-a.frames[j])/(a.frames[j+1]-a.frames[j]));}
  let translation=[0,0,0];const b=n.animations.find(a=>a.name==='KGTR');
  if(b){let j=0;while(j+1<b.frames.length&&b.frames[j+1]<=time)j++;translation=b.values[j];if(j+1<b.frames.length&&time>b.frames[j])translation=vec3.lerp([],translation,b.values[j+1],(time-b.frames[j])/(b.frames[j+1]-b.frames[j]));}
  const local=mat4.fromRotationTranslationScaleOrigin([],q,translation,[1,1,1],decoded.pivotPoints[i]);matrices[i]=p>=0?mat4.multiply([],matrices[p],local):local;
 }
 for(let i=0;i<decodedNodes.length;i++)resolve(i);return matrices;
}
const baseline=JSON.parse(fs.readFileSync(path.join(input,'pose.json'),'utf8'));
const preview={name:geometry.model,materials:baseline.materials,textures:baseline.textures};
fs.writeFileSync(path.join(output,'render-motion.json'),JSON.stringify({...preview,nodes:decodedNodes.map((n,i)=>{const channel=name=>{const a=n.animations.find(a=>a.name===name);return a?{frames:a.frames,values:a.values.map(q=>Array.from(q))}:null;};return {parent:n.parentId,pivot:Array.from(decoded.pivotPoints[i]),rotation:channel('KGRT'),translation:channel('KGTR')};}),geosets:decoded.geosets.map(g=>({vertices:Array.from(g.vertices),normals:Array.from(g.normals),uv:Array.from(g.uvSets[0]),faces:Array.from(g.faces),material:g.materialId,vertexGroups:Array.from(g.vertexGroups),matrixGroups:Array.from(g.matrixGroups),matrixIndices:Array.from(g.matrixIndices)})),clips}));
const checks=[];let maxRoundtrip=0;
for(const clip of clips){
 const first=skin(decodedPose(clip.start)),last=skin(decodedPose(clip.start+clip.duration));let seam=0;
 first.forEach((g,i)=>g.vertices.forEach((v,j)=>v.forEach((x,k)=>seam=Math.max(seam,Math.abs(x-last[i].vertices[j][k])))));
 check(seam<0.001,'Loop seam '+clip.name);
 for(let ms=0;ms<=clip.duration;ms+=25){
  const matrices=decodedPose(clip.start+ms);check(matrices.every(m=>m.every(Number.isFinite)),'Non-finite animated matrix');
  for(const root of ['全ての親','センター','下半身','右足首D','左足首D']){
   const id=get(root),point=vec3.transformMat4([],pivot(id),matrices[id]);check(vec3.distance(point,pivot(id))<0.001,'Root/foot displacement '+root);
  }
  if(ms%500===0){
   const actual=skin(matrices),expected=skin(author(ms/1000,clip.kind).matrices);
   actual.forEach((g,i)=>g.vertices.forEach((v,j)=>v.forEach((x,k)=>{check(Number.isFinite(x),'Non-finite skinned position');maxRoundtrip=Math.max(maxRoundtrip,Math.abs(x-expected[i].vertices[j][k]));})));
  }
 }
 checks.push({name:clip.name,interval:[clip.start,clip.start+clip.duration],loop_seam_max_error:seam,root_and_feet_fixed:true});
 const samples=clip.kind==='hmm'?[0,1.4,1.8,2.2,2.7,3.2,4.2,4.6,5.5]:[0,1,2,3];
 for(const t of samples)fs.writeFileSync(path.join(output,clip.kind+'-'+t+'.json'),JSON.stringify({...preview,geosets:skin(decodedPose(clip.start+t*1000))}));
}
check(maxRoundtrip<0.002,'Serialized animation mismatch');
const sanity=sanityTest(decoded);fs.writeFileSync(path.join(output,'sanity.json'),JSON.stringify(sanity,null,2));
const severe=[];function messages(n){if(n.type==='severe')severe.push(n.message);for(const c of n.nodes||[])messages(c);}messages(sanity);
check(sanity.errors===0&&severe.every(m=>m==='Missing "Death" sequence'),'Unexpected model structure issue');
check(decoded.geosets.length===model.geosets.length&&decoded.textures.length===model.textures.length,'Mesh/texture topology changed');
const inputModel=new Model();inputModel.load(read(original));
for(let i=0;i<decoded.geosets.length;i++){
 for(const field of ['vertices','normals','faces'])check(Buffer.from(decoded.geosets[i][field].buffer).equals(Buffer.from(inputModel.geosets[i][field].buffer)),'Source mesh changed: '+field);
 const groups=g=>{let offset=0;return Array.from(g.matrixGroups,count=>{const group=Array.from(g.matrixIndices.slice(offset,offset+count));offset+=count;return group;});};
 const before=groups(inputModel.geosets[i]),after=groups(decoded.geosets[i]);
 for(let j=0;j<decoded.geosets[i].vertexGroups.length;j++)if(!altered.get(i).has(j))check(JSON.stringify(before[inputModel.geosets[i].vertexGroups[j]].map(id=>ids.get(id)))===JSON.stringify(after[decoded.geosets[i].vertexGroups[j]]),'Non-blink skin changed');
 for(const j of altered.get(i))check(decoded.geosets[i].vertices[j*3+2]>pivot(get('頭'))[2]+0.5,'Blink changes mouth or lower face');
}
check(decoded.textures.every((t,i)=>t.path===inputModel.textures[i].path),'Source texture paths changed');
const report={model:geometry.model,triangles:decoded.geosets.reduce((s,g)=>s+g.faces.length/3,0),rotation_tracks:tracks,translation_tracks:translationTracks,blink_vertices:blinkVertices,blink_error_max:rig.blink_error_max,max_key_rotation_degrees:maxKeyRotation,sequences:checks,roundtrip_identical:true,animated_pose_max_error:maxRoundtrip,reference_url:'https://www.youtube.com/watch?v=3E3QgXVwTeA',reference_clips:clips.map(c=>({name:c.name,seconds:c.reference})),motion_source:'Hand-authored skeletal reconstruction from user-specified video and image; source PMX blink morph baked into eye-only translation bones',mouth_animation:false,warcraft_runtime_tested:false,sanity:{errors:sanity.errors,severe:sanity.severe,warnings:sanity.warnings,unused:sanity.unused}};
fs.writeFileSync(path.join(output,'motion-validation.json'),JSON.stringify(report,null,2));console.log(JSON.stringify(report));
