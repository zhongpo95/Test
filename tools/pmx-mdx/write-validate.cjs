// PMX 변환 자료를 클래식 MDX로 저장하고 다시 읽어 메시와 텍스처를 검사합니다.
const fs = require('fs');
const path = require('path');
const [dependencyRoot, folder] = process.argv.slice(2);
const base = path.join(dependencyRoot,'viewer/node_modules/mdx-m3-viewer/dist/cjs');
const load = name => require(path.join(base,'parsers/mdlx',name)).default;
const Model = load('model'), Bone = load('bone'), Helper = load('helper'), Texture = load('texture');
const Material = load('material'), Layer = load('layer'), Geoset = load('geoset'), Extent = load('extent');
const Sequence = load('sequence'), GeosetAnimation = load('geosetanimation'), Attachment = load('attachment');
const { BlpImage } = require(path.join(base,'parsers/blp/image'));
const sanityTest = require(path.join(base,'utils/mdlx/sanitytest/sanitytest')).default;
global.ImageData = class {
  constructor(width,height) { this.width=width; this.height=height; this.data=new Uint8ClampedArray(width*height*4); }
};
function assert(condition,message) { if (!condition) throw new Error(message); }
function extent(vertices) {
  const result = new Extent();
  result.min.fill(Infinity);result.max.fill(-Infinity);
  for (const point of vertices) {
    for (let i=0;i<3;i++) { result.min[i]=Math.min(result.min[i],point[i]);result.max[i]=Math.max(result.max[i],point[i]); }
    result.boundsRadius=Math.max(result.boundsRadius,Math.hypot(...point));
  }
  return result;
}
function buffer(file) {
  const bytes=fs.readFileSync(file);
  return bytes.buffer.slice(bytes.byteOffset,bytes.byteOffset+bytes.byteLength);
}
const payload = JSON.parse(fs.readFileSync(path.join(folder,'geometry.json'),'utf8'));
const model = new Model();model.name=payload.model;model.blendTime=150;
const weighted = new Set(payload.surfaces.flatMap(surface => surface.groups.flat()));
const order = payload.bones.map((_,i)=>i).filter(i=>weighted.has(i)).concat(payload.bones.map((_,i)=>i).filter(i=>!weighted.has(i)));
const ids = new Map(order.map((source,index)=>[source,index]));
for (const source of order) {
  const entry=payload.bones[source];const bone=weighted.has(source)?new Bone():new Helper();
  bone.name=entry.name;bone.objectId=ids.get(source);bone.parentId=entry.parent<0?-1:ids.get(entry.parent);
  assert(Number.isInteger(bone.parentId),'Missing bone parent');
  const visited=new Set([source]);let parent=entry.parent;
  while(parent>=0) { assert(!visited.has(parent),'Bone hierarchy cycle');visited.add(parent);parent=payload.bones[parent].parent; }
  if(weighted.has(source)) model.bones.push(bone);else model.helpers.push(bone);
  model.pivotPoints.push(new Float32Array(entry.pivot));
}
const origin = new Attachment();origin.name='Origin Ref';origin.objectId=payload.bones.length;origin.parentId=-1;origin.attachmentId=0;
model.attachments.push(origin);model.pivotPoints.push(new Float32Array([0,0,0]));
for (const entry of payload.textures) { const texture=new Texture();texture.path=entry.path;model.textures.push(texture); }
for (const entry of payload.materials) {
  const material=new Material(),layer=new Layer();
  layer.textureId=entry.texture;layer.filterMode=entry.filter_mode;layer.alpha=entry.diffuse[3];layer.flags=entry.two_sided?16:0;
  material.layers.push(layer);model.materials.push(material);
}
const expectedGeosets=[];
for (const surface of payload.surfaces) {
  let groups=new Map(),vertices=new Map(),sourceVertices=[],faces=[];
  function flush() {
    if(!faces.length) return;
    const geo=new Geoset();const points=sourceVertices.map(i=>surface.vertices[i]);
    geo.vertices=new Float32Array(points.flat());geo.normals=new Float32Array(sourceVertices.flatMap(i=>surface.normals[i]));
    geo.uvSets=[new Float32Array(sourceVertices.flatMap(i=>surface.uv[i]))];
    geo.faces=new Uint16Array(faces.flat());geo.faceTypeGroups=new Uint32Array([4]);geo.faceGroups=new Uint32Array([geo.faces.length]);
    geo.vertexGroups=new Uint8Array(sourceVertices.map(i=>groups.get(surface.groups[i].join(','))));
    const keys=Array.from(groups.keys()).map(key=>key.split(',').map(Number));
    geo.matrixGroups=new Uint32Array(keys.map(key=>key.length));geo.matrixIndices=new Uint32Array(keys.flatMap(key=>key.map(index=>ids.get(index))));
    geo.materialId=surface.material;geo.extent=extent(points);geo.sequenceExtents=[extent(points)];
    const color=payload.materials[surface.material].diffuse;
    if(color.slice(0,3).some(value=>value!==1)) {
      const animation=new GeosetAnimation();animation.geosetId=model.geosets.length;animation.flags=2;
      animation.color=new Float32Array([color[2],color[1],color[0]]);model.geosetAnimations.push(animation);
    }
    expectedGeosets.push(points);model.geosets.push(geo);
    groups=new Map();vertices=new Map();sourceVertices=[];faces=[];
  }
  for(const triangle of surface.faces) {
    const additions=new Set(triangle.map(i=>surface.groups[i].join(',')).filter(key=>!groups.has(key)));
    if(groups.size+additions.size>256 || vertices.size+triangle.filter(i=>!vertices.has(i)).length>4096) flush();
    const face=[];
    for(const i of triangle) {
      const key=surface.groups[i].join(',');if(!groups.has(key))groups.set(key,groups.size);
      if(!vertices.has(i)) { vertices.set(i,vertices.size);sourceVertices.push(i); }
      face.push(vertices.get(i));
    }
    faces.push(face);
  }
  flush();
}
model.extent=extent(payload.surfaces.flatMap(surface=>surface.vertices));
const stand=new Sequence();stand.name='Stand';stand.interval=new Uint32Array([0,1000]);stand.extent=extent(payload.surfaces.flatMap(surface=>surface.vertices));model.sequences.push(stand);
const output=path.join(folder,payload.model+'.mdx');assert(!fs.existsSync(output),'Existing model is preserved');
fs.writeFileSync(output,Buffer.from(model.saveMdx()));
const decoded=new Model();decoded.load(buffer(output));
assert(Buffer.from(decoded.saveMdx()).equals(fs.readFileSync(output)),'MDX roundtrip mismatch');
let maximumError=0;
for(let i=0;i<decoded.geosets.length;i++) {
  const geo=decoded.geosets[i];assert(geo.vertices.length/3<=4096,'Geoset vertex limit');assert(geo.matrixGroups.length<=256,'Matrix group limit');
  assert(geo.faces.every(index=>index<geo.vertices.length/3),'Triangle references missing vertex');
  assert(Array.from(geo.vertices).every(Number.isFinite),'Non-finite vertex');
  assert(geo.matrixIndices.every(index=>index<decoded.bones.length),'Skin references an unweighted bone');
  for(let j=0;j<geo.vertices.length;j++)maximumError=Math.max(maximumError,Math.abs(geo.vertices[j]-expectedGeosets[i][Math.floor(j/3)][j%3]));
}
assert(maximumError<0.001,'Converted static pose mismatch');
const nodes=[...decoded.bones,...decoded.helpers,...decoded.attachments];assert(nodes.every((node,i)=>node.objectId===i),'Legacy node ID order');
const textures=[];
for(const texture of decoded.textures) {
  const file=path.join(folder,...texture.path.split('\\'));assert(fs.existsSync(file),'Missing imported texture');
  const image=new BlpImage();image.load(buffer(file));let mipmaps=0;
  for(let level=0;level<16 && image.mipmapOffsets[level];level++) {
    const decodedImage=image.getMipmap(level);assert(decodedImage.data.length===decodedImage.width*decodedImage.height*4,'BLP mipmap decode size');
    if(level===0)fs.writeFileSync(file+'.rgba',decodedImage.data);mipmaps++;
  }
  textures.push({path:texture.path,width:image.width,height:image.height,mipmaps});
}
const sanity=sanityTest(decoded);fs.writeFileSync(path.join(folder,'sanity.json'),JSON.stringify(sanity,null,2));
const severe=[];
function messages(node) { if(node.type==='severe')severe.push(node.message);for(const child of node.nodes||[])messages(child); }
messages(sanity);
assert(sanity.errors===0,'MDX structure errors');assert(severe.every(message=>message==='Missing "Death" sequence'),'Unexpected severe model issue');
const report={version:decoded.version,triangles:decoded.geosets.reduce((sum,geo)=>sum+geo.faces.length/3,0),geosets:decoded.geosets.length,bones:decoded.bones.length,helpers:decoded.helpers.length,attachments:decoded.attachments.length,sequences:decoded.sequences.map(sequence=>sequence.name),roundtrip_identical:true,static_pose_max_error:maximumError,textures,sanity:{errors:sanity.errors,severe:sanity.severe,warnings:sanity.warnings,unused:sanity.unused},expected_limitations:['Static model: no source animation files and no Death sequence']};
fs.writeFileSync(path.join(folder,'validation.json'),JSON.stringify(report,null,2));
fs.writeFileSync(path.join(folder,'pose.json'),JSON.stringify({name:payload.model,geosets:decoded.geosets.map(geo=>({vertices:Array.from({length:geo.vertices.length/3},(_,i)=>Array.from(geo.vertices.slice(i*3,i*3+3))),normals:Array.from({length:geo.normals.length/3},(_,i)=>Array.from(geo.normals.slice(i*3,i*3+3))),uv:Array.from({length:geo.uvSets[0].length/2},(_,i)=>[geo.uvSets[0][i*2],1-geo.uvSets[0][i*2+1]]),faces:Array.from({length:geo.faces.length/3},(_,i)=>Array.from(geo.faces.slice(i*3,i*3+3))),material:geo.materialId})),materials:payload.materials,textures}));
console.log(JSON.stringify(report));
