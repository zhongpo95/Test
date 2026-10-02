// 사 모델의 골격으로 흠 동작과 팔짱 대기를 만들고 MDX 재읽기와 반복 경계를 검사합니다.
const fs=require('fs'),path=require('path');
const [deps,input,output]=process.argv.slice(2);
const lib=path.join(deps,'viewer/node_modules/mdx-m3-viewer/dist/cjs');
const Model=require(path.join(lib,'parsers/mdlx/model')).default;
const Sequence=require(path.join(lib,'parsers/mdlx/sequence')).default;
const Extent=require(path.join(lib,'parsers/mdlx/extent')).default;
const {Vector4Animation}=require(path.join(lib,'parsers/mdlx/animations'));
const sanityTest=require(path.join(lib,'utils/mdlx/sanitytest/sanitytest')).default;
const {vec3,quat,mat3,mat4}=require(path.join(deps,'viewer/node_modules/gl-matrix'));
function check(ok,msg){if(!ok)throw Error(msg);}
function read(file){const b=fs.readFileSync(file);return b.buffer.slice(b.byteOffset,b.byteOffset+b.byteLength);}
const geometry=JSON.parse(fs.readFileSync(path.join(input,'geometry.json'),'utf8'));
const original=path.join(input,geometry.model+'.mdx');const model=new Model();model.load(read(original));
const nodes=[...model.bones,...model.helpers,...model.attachments];
check(model.sequences.length===1&&nodes.every(n=>n.animations.length===0),'Use the unanimated PMX conversion as input');
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
const chest=pivot(get('上半身2')),centre=chest[1];
function basis(direction,width){
 const y=norm(direction),x=norm(sub(width,scale(y,vec3.dot(width,y)))),z=norm(vec3.cross([],x,y));
 return mat3.fromValues(...x,...y,...z);
}
function orient(fromDirection,fromWidth,toDirection,toWidth){
 const r=mat3.multiply([],basis(toDirection,toWidth),mat3.transpose([],basis(fromDirection,fromWidth)));
 return quat.normalize([],quat.fromMat3([],r));
}
function solveArm(shoulder,elbow,wrist,target,pole){
 const l1=vec3.distance(shoulder,elbow),l2=vec3.distance(elbow,wrist),delta=sub(target,shoulder);
 const distance=Math.min(l1+l2-0.05,Math.max(Math.abs(l1-l2)+0.05,vec3.length(delta))),direction=norm(delta);
 const actual=add(shoulder,scale(direction,distance)),a=(l1*l1-l2*l2+distance*distance)/(2*distance);
 const bend=norm(sub(sub(pole,shoulder),scale(direction,vec3.dot(sub(pole,shoulder),direction))));
 const joint=add(add(shoulder,scale(direction,a)),scale(bend,Math.sqrt(Math.max(0,l1*l1-a*a))));
 return {elbow:joint,wrist:actual};
}
function smooth(x){return x*x*(3-2*x);}
function envelope(t,keys){
 for(let i=1;i<keys.length;i++)if(t<=keys[i][0]){const [a,v]=keys[i-1],[b,w]=keys[i];return v+(w-v)*smooth((t-a)/(b-a));}
 return keys.at(-1)[1];
}
const arms=['左','右'].map((side,index)=>{
 const prefix=index===0?'L':'R';
 const joint={side,prefix,index,upper:get(side+'腕'),elbow:get(side+'ひじ'),wrist:get(side+'手首'),twist:get(side+'腕捩'),halfTwist:get(side+'腕捩1'),foreTwist:get(side+'手捩'),halfForeTwist:get(side+'手捩1')};
 joint.finger=get(side+'中指１');joint.tip=get(side+'中指３');joint.width=sub(pivot(get(side+'小指１')),pivot(get(side+'人指１')));
 joint.direction=sub(pivot(joint.tip),pivot(joint.finger));return joint;
});
function author(t,kind){
 const rotations=nodes.map(()=>identity.slice()),worldQ=[],worldM=[];
 const breathe=Math.sin(t*2*Math.PI/(kind==='cross'?4:7));
 const gesture=kind==='hmm'?envelope(t,[[0,0],[1.2,0],[2.7,1],[3.5,1],[4.7,0],[7,0]]):0;
 const bob=kind==='hmm'?envelope(t,[[0,0],[2.65,0],[3.05,1],[3.5,0],[7,0]]):0;
 function reset(){worldQ.length=0;worldM.length=0;}
 function resolve(i){
  if(worldM[i])return;
  const n=nodes[i],p=n.parentId;if(p>=0)resolve(p);
  const local=mat4.fromRotationTranslationScaleOrigin([],rotations[i],[0,0,0],[1,1,1],pivot(i));
  worldQ[i]=p>=0?mul(worldQ[p],rotations[i]):rotations[i];
  worldM[i]=p>=0?mat4.multiply([],worldM[p],local):local;
 }
 function setWorld(i,q){const parent=nodes[i].parentId;if(parent>=0)resolve(parent);rotations[i]=parent>=0?mul(inv(worldQ[parent]),q):q;reset();}
 function transformed(i){resolve(i);return vec3.transformMat4([],pivot(i),worldM[i]);}
 rotations[get('上半身1')]=axis([0,1,0],0.25*breathe);
 rotations[get('上半身2')]=axis([0,1,0],0.35*breathe);
 rotations[get('首')]=axis([0,1,0],kind==='hmm'?(-3*gesture-1.8*bob):0.5*breathe);
 rotations[get('頭')]=mul(axis([0,0,1],kind==='hmm'?-2.5*gesture:8+0.5*breathe),axis([0,1,0],kind==='hmm'?-2*gesture:0));
 for(const arm of arms){
  const left=arm.index===0,sign=left?1:-1;
  const s=transformed(arm.upper),e=pivot(arm.elbow),w=pivot(arm.wrist);
  let target,pole,fingers,width,curl;
  if(kind==='cross'){
   target=left?[chest[0]-9,centre-3.0,chest[2]-0.2]:[chest[0]-7,centre+4.0,chest[2]+3.4];
   pole=[chest[0]-8,centre+sign*15,chest[2]-5];
   fingers=[0,-sign,0.25];width=[0,0,sign];curl=0.18;
  }else{
   const idle=[chest[0]+0.5,centre+sign*9,chest[2]-20];
   const mouth=[chest[0]-10.5,centre+5.5,chest[2]+11.5];
   target=left?vec3.lerp([],idle,mouth,gesture):idle;
   pole=[chest[0]-6,centre+sign*15,chest[2]-6];
   fingers=left?vec3.lerp([],[0,0.08,-1],[-0.1,-0.28,1],gesture):[0,-0.08,-1];
   width=left?vec3.lerp([],[1,0,0],[0,-1,0],gesture):[1,0,0];curl=left?0.18+0.75*gesture:0.18;
  }
  target[2]+=0.12*breathe;
  const solved=solveArm(s,e,w,target,pole);
  const upperRotation=quat.rotationTo([],norm(sub(e,pivot(arm.upper))),norm(sub(solved.elbow,s)));
  setWorld(arm.upper,upperRotation);
  const foreRotation=quat.rotationTo([],norm(sub(w,e)),norm(sub(solved.wrist,solved.elbow)));
  setWorld(arm.elbow,foreRotation);
  const handRotation=kind==='hmm'&&left?quat.slerp([],orient(arm.direction,arm.width,[0,0.08,-1],[1,0,0]),orient(arm.direction,arm.width,[-0.1,-0.1,1],[0,-1,0]),gesture):orient(arm.direction,arm.width,fingers,width);
  setWorld(arm.wrist,handRotation);
  for(const finger of ['人指','中指','薬指','小指'])for(let segment=1;segment<=3;segment++){
   const name=arm.side+finger+['','１','２','３'][segment];
   rotations[get(name)]=axis(arm.width,-sign*curl*(segment===1?45:75));
  }
  rotations[get(arm.side+'親指１')]=axis([0,0,1],sign*curl*20);
  rotations[get(arm.side+'親指２')]=axis(arm.width,sign*curl*35);reset();
  const cloth=get(arm.prefix+'_sleeveD_01_jnt_1'),next=get(arm.prefix+'_sleeveD_01_jnt_2');
  const sway=0.025*Math.sin(2*Math.PI*t/(kind==='cross'?4:7));
  setWorld(cloth,quat.rotationTo([],norm(sub(pivot(next),pivot(cloth))),norm([0.09,sign*0.04+sway,-1])));
 }
 rotations[get('tail_jnt1')]=axis([0,0,1],0.9*breathe);
 reset();for(let i=0;i<nodes.length;i++)resolve(i);
 return {rotations,matrices:worldM};
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
const keys=nodes.map(()=>({frames:[],values:[]}));
for(const clip of clips){
 const seq=new Sequence();seq.name=clip.name;seq.interval=new Uint32Array([clip.start,clip.start+clip.duration]);seq.extent=extent();
 model.sequences.push(seq);const extents=model.geosets.map(()=>extent());
 for(let ms=0;ms<=clip.duration;ms+=50){
  const pose=author(ms/1000,clip.kind);
  pose.rotations.forEach((q,i)=>{const prev=keys[i].values.at(-1);if(prev&&quat.dot(prev,q)<0)q=q.map(v=>-v);keys[i].frames.push(clip.start+ms);keys[i].values.push(q);});
  const skinned=skin(pose.matrices);
  skinned.forEach((g,i)=>{include(extents[i],g.vertices);include(seq.extent,g.vertices);include(model.extent,g.vertices);});
 }
 model.geosets.forEach((g,i)=>g.sequenceExtents.push(extents[i]));
}
function pad(e){for(let k=0;k<3;k++){e.min[k]-=0.2;e.max[k]+=0.2;}e.boundsRadius+=0.4;}
model.geosets.forEach(g=>{g.extent=extent();for(const e of g.sequenceExtents){include(g.extent,[Array.from(e.min),Array.from(e.max)]);pad(e);}pad(g.extent);});
model.sequences.forEach(s=>pad(s.extent));pad(model.extent);
let tracks=0;
nodes.forEach((node,i)=>{
 if(keys[i].values.every(q=>Math.abs(quat.dot(q,identity))>0.99999999))return;
 const a=new Vector4Animation();a.name='KGRT';a.interpolationType=1;a.frames=keys[i].frames;a.values=keys[i].values.map(q=>new Float32Array(q));node.animations.push(a);tracks++;
});
fs.mkdirSync(output,{recursive:true});const file=path.join(output,geometry.model+'.mdx');check(!fs.existsSync(file),'Preserve existing output');
fs.writeFileSync(file,Buffer.from(model.saveMdx()));const decoded=new Model();decoded.load(read(file));
check(Buffer.from(decoded.saveMdx()).equals(fs.readFileSync(file)),'MDX roundtrip mismatch');
const decodedNodes=[...decoded.bones,...decoded.helpers,...decoded.attachments];
for(let i=0;i<geometry.bones.length;i++)if(/(嘴|Jaw|Tongue|tooth)/.test(geometry.bones[i].source_name))check(decodedNodes[sourceIds[i]].animations.length===0,'Mouth joint animated');
function decodedPose(time){
 const matrices=[];
 function resolve(i){if(matrices[i])return;const n=decodedNodes[i],p=n.parentId;if(p>=0)resolve(p);
  let q=identity;const a=n.animations.find(a=>a.name==='KGRT');
  if(a){let j=0;while(j+1<a.frames.length&&a.frames[j+1]<=time)j++;q=a.values[j];if(j+1<a.frames.length&&time>a.frames[j])q=quat.slerp([],q,a.values[j+1],(time-a.frames[j])/(a.frames[j+1]-a.frames[j]));}
  const local=mat4.fromRotationTranslationScaleOrigin([],q,[0,0,0],[1,1,1],decoded.pivotPoints[i]);matrices[i]=p>=0?mat4.multiply([],matrices[p],local):local;
 }
 for(let i=0;i<decodedNodes.length;i++)resolve(i);return matrices;
}
const baseline=JSON.parse(fs.readFileSync(path.join(input,'pose.json'),'utf8'));
const preview={name:geometry.model,materials:baseline.materials,textures:baseline.textures};
fs.writeFileSync(path.join(output,'render-motion.json'),JSON.stringify({...preview,nodes:decodedNodes.map((n,i)=>{const a=n.animations.find(a=>a.name==='KGRT');return {parent:n.parentId,pivot:Array.from(decoded.pivotPoints[i]),rotation:a?{frames:a.frames,values:a.values.map(q=>Array.from(q))}:null};}),geosets:decoded.geosets.map(g=>({vertices:Array.from(g.vertices),normals:Array.from(g.normals),uv:Array.from(g.uvSets[0]),faces:Array.from(g.faces),material:g.materialId,vertexGroups:Array.from(g.vertexGroups),matrixGroups:Array.from(g.matrixGroups),matrixIndices:Array.from(g.matrixIndices)})),clips}));
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
 const samples=clip.kind==='hmm'?[0,2.7,3.2,4.2,5.5]:[0,1,2,3];
 for(const t of samples)fs.writeFileSync(path.join(output,clip.kind+'-'+t+'.json'),JSON.stringify({...preview,geosets:skin(decodedPose(clip.start+t*1000))}));
}
check(maxRoundtrip<0.002,'Serialized animation mismatch');
const sanity=sanityTest(decoded);fs.writeFileSync(path.join(output,'sanity.json'),JSON.stringify(sanity,null,2));
const severe=[];function messages(n){if(n.type==='severe')severe.push(n.message);for(const c of n.nodes||[])messages(c);}messages(sanity);
check(sanity.errors===0&&severe.every(m=>m==='Missing "Death" sequence'),'Unexpected model structure issue');
check(decoded.geosets.length===model.geosets.length&&decoded.textures.length===model.textures.length,'Mesh/texture topology changed');
const inputModel=new Model();inputModel.load(read(original));
for(let i=0;i<decoded.geosets.length;i++)for(const field of ['vertices','normals','faces','vertexGroups','matrixGroups','matrixIndices'])check(Buffer.from(decoded.geosets[i][field].buffer).equals(Buffer.from(inputModel.geosets[i][field].buffer)),'Source mesh changed: '+field);
check(decoded.textures.every((t,i)=>t.path===inputModel.textures[i].path),'Source texture paths changed');
const report={model:geometry.model,triangles:decoded.geosets.reduce((s,g)=>s+g.faces.length/3,0),rotation_tracks:tracks,sequences:checks,roundtrip_identical:true,animated_pose_max_error:maxRoundtrip,reference_url:'https://www.youtube.com/watch?v=3E3QgXVwTeA',reference_clips:clips.map(c=>({name:c.name,seconds:c.reference})),motion_source:'Hand-authored skeletal reconstruction from user-specified video and image',mouth_animation:false,warcraft_runtime_tested:false,sanity:{errors:sanity.errors,severe:sanity.severe,warnings:sanity.warnings,unused:sanity.unused}};
fs.writeFileSync(path.join(output,'motion-validation.json'),JSON.stringify(report,null,2));console.log(JSON.stringify(report));
