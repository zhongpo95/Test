// 추출된 EPB 윤곽·UV와 공유 BLP를 클래식 MDX 이펙트 소재로 만들고 독립 재읽기 검사를 수행합니다.
const fs = require('fs');
const path = require('path');
const [dependencies, folder] = process.argv.slice(2);
const base = path.join(dependencies, 'viewer/node_modules/mdx-m3-viewer/dist/cjs');
const type = name => require(path.join(base, 'parsers/mdlx', name)).default;
const Model = type('model'), Sequence = type('sequence'), Material = type('material');
const Layer = type('layer'), Texture = type('texture'), Geoset = type('geoset');
const Bone = type('bone'), GeosetAnimation = type('geosetanimation'), Extent = type('extent');
const Attachment = type('attachment');
const { FloatAnimation } = require(path.join(base, 'parsers/mdlx/animations'));
const { BlpImage } = require(path.join(base, 'parsers/blp/image'));
const sanityTest = require(path.join(base, 'utils/mdlx/sanitytest/sanitytest')).default;
global.ImageData = class {
  constructor(width, height) { this.width=width; this.height=height; this.data=new Uint8ClampedArray(width*height*4); }
};
const manifest = JSON.parse(fs.readFileSync(path.join(folder, 'Info/effects-manifest.json')));
const output = path.join(folder, 'Warcraft');
const qa = path.join(folder, 'Info');
const buffer = bytes => bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset+bytes.byteLength);
function check(value, message) { if (!value) throw new Error(message); }
function animation(name, frames, values, interpolation=0) {
  const track = new FloatAnimation();
  track.name=name; track.frames=frames; track.values=values.map(x=>new Float32Array([x]));
  track.interpolationType=interpolation;
  return track;
}
function extent(vertices) {
  const result = new Extent();
  result.min.set([-1, Infinity, Infinity]); result.max.set([1, -Infinity, -Infinity]);
  for (let i=0; i<vertices.length; i+=3) {
    for (let c=1; c<3; c++) {
      result.min[c]=Math.min(result.min[c], vertices[i+c]);
      result.max[c]=Math.max(result.max[c], vertices[i+c]);
    }
    result.boundsRadius=Math.max(result.boundsRadius, Math.hypot(vertices[i], vertices[i+1], vertices[i+2])+1);
  }
  return result;
}
const reports=[], previews=[];
for (const source of manifest.material_models) {
  const file=path.join(output, source.name+'.mdx');
  check(!fs.existsSync(file), 'Existing model is preserved');
  const model=new Model(); model.name=source.name;
  const duration=source.stand_duration, deathStart=duration+100, deathEnd=duration+300;
  for (const [name, start, end] of [['Stand',0,duration],['Death',deathStart,deathEnd]]) {
    const sequence=new Sequence(); sequence.name=name; sequence.interval.set([start,end]); sequence.flags=1;
    model.sequences.push(sequence);
  }
  const bone=new Bone(); bone.name='EffectBillboard'; bone.objectId=0; bone.flags|=8;
  model.bones.push(bone); model.pivotPoints.push(new Float32Array(3));
  const origin=new Attachment(); origin.name='Origin Ref'; origin.objectId=1; origin.parentId=0; origin.attachmentId=0;
  model.attachments.push(origin); model.pivotPoints.push(new Float32Array(3));
  const pages=[...new Set(source.frames.map(key=>manifest.images[key].atlas))];
  for (let index=0; index<pages.length; index++) {
    const texture=new Texture(); texture.path=pages[index].replaceAll('/','\\'); model.textures.push(texture);
    const layer=new Layer(); layer.textureId=index; layer.filterMode=4; layer.flags=1|16|32|128;
    layer.animations.push(animation('KMTA',[0,30,Math.max(31,duration-70),duration,deathStart,deathEnd],[0,1,1,0,0,0],1));
    const material=new Material(); material.layers.push(layer); model.materials.push(material);
  }
  let positionError=0, uvError=0;
  source.frames.forEach((key, index)=>{
    const item=manifest.images[key], geometry=item.geometry;
    const [width,height]=item.source_size, scale=240/Math.max(width,height);
    const positions=geometry.positions.flatMap(([x,y])=>[0,(x+.5)*width*scale,(y+.5)*height*scale]);
    const geoset=new Geoset(); geoset.vertices=new Float32Array(positions);
    geoset.normals=new Float32Array(geometry.positions.flatMap(()=>[1,0,0]));
    geoset.faces=new Uint16Array(geometry.faces); geoset.faceTypeGroups=new Uint32Array([4]);
    geoset.faceGroups=new Uint32Array([geometry.faces.length]);
    geoset.vertexGroups=new Uint8Array(geometry.positions.length);
    geoset.matrixGroups=new Uint32Array([1]); geoset.matrixIndices=new Uint32Array([0]);
    geoset.uvSets=[new Float32Array(geometry.mapped_uv.flat())];
    geoset.materialId=pages.indexOf(item.atlas); geoset.extent=extent(positions);
    geoset.sequenceExtents=[geoset.extent,geoset.extent]; model.geosets.push(geoset);
    const start=Math.round(index*duration/source.frames.length), end=Math.round((index+1)*duration/source.frames.length);
    const alpha=new GeosetAnimation(); alpha.geosetId=index;
    alpha.animations.push(animation('KGAO', index===0?[0,end,deathStart,deathEnd]:[0,start,end,deathStart,deathEnd],
                                   index===0?[1,0,0,0]:[0,1,0,0,0]));
    model.geosetAnimations.push(alpha);
  });
  model.extent=extent(model.geosets.flatMap(g=>Array.from(g.vertices)));
  model.sequences.forEach(s=>s.extent=model.extent);
  const bytes=Buffer.from(model.saveMdx()); fs.writeFileSync(file,bytes);
  const decoded=new Model(); decoded.load(buffer(bytes));
  check(Buffer.from(decoded.saveMdx()).equals(bytes),'MDX roundtrip changed bytes');
  decoded.geosets.forEach((geo,index)=>{
    const item=manifest.images[source.frames[index]], geometry=item.geometry;
    const [width,height]=item.source_size, scale=240/Math.max(width,height);
    check(geo.faces.length===geometry.faces.length && geo.faces.every((v,i)=>v===geometry.faces[i]), 'EPB triangles changed');
    for (let i=0; i<geometry.positions.length; i++) {
      positionError=Math.max(positionError,Math.abs(geo.vertices[i*3+1]/(width*scale)-.5-geometry.positions[i][0]),
                             Math.abs(geo.vertices[i*3+2]/(height*scale)-.5-geometry.positions[i][1]));
      const [x,y,w,h]=item.rect, [aw,ah]=item.atlas_size;
      uvError=Math.max(uvError,Math.abs((geo.uvSets[0][i*2]*aw-x)/w-geometry.uv[i][0]),
                      Math.abs((geo.uvSets[0][i*2+1]*ah-y)/h-geometry.uv[i][1]));
    }
  });
  check(positionError<.000001 && uvError<.00001, 'Source EPB position/UV recovery differs');
  const sanity=sanityTest(decoded);
  fs.writeFileSync(path.join(qa, source.name+'.sanity.json'),JSON.stringify(sanity));
  check(sanity.errors===0 && sanity.severe===0, 'Effect structure failed sanity check');
  for (let time=0; time<duration; time++) {
    const visible=decoded.geosetAnimations.filter(g=>{
      const track=g.animations[0]; let key=0;
      while (key+1<track.frames.length && track.frames[key+1]<=time) key++;
      return track.values[key][0]===1;
    }).length;
    check(visible===1, 'Flipbook does not select exactly one source frame');
  }
  reports.push({file:path.basename(file),geosets:decoded.geosets.length,triangles:decoded.geosets.reduce((n,g)=>n+g.faces.length/3,0),
                bytes:bytes.length,roundtrip_identical:true,source_epb_positions_inverse_error:positionError,source_epb_uv_inverse_error:uvError,
                sanity:{errors:sanity.errors,severe:sanity.severe,warnings:sanity.warnings,unused:sanity.unused},
                all_stand_milliseconds_single_frame_checked:true});
  previews.push({name:source.name,duration,geosets:decoded.geosets.map((g,index)=>({vertices:Array.from(g.vertices),faces:Array.from(g.faces),
     uv:Array.from(g.uvSets[0]),texture:decoded.textures[decoded.materials[g.materialId].layers[0].textureId].path,
     alpha_frames:decoded.geosetAnimations[index].animations[0].frames,alpha_values:decoded.geosetAnimations[index].animations[0].values.map(x=>x[0])}))});
}
const textureReports=[];
const decodedFolder=path.join(qa,'decoded-atlases'); fs.mkdirSync(decodedFolder);
for (const atlas of manifest.atlases) {
  const bytes=fs.readFileSync(path.join(output,atlas.path));
  const image=new BlpImage(); image.load(buffer(bytes));
  const sizes=[];
  for (let level=0; level<16 && image.mipmapOffsets[level]; level++) {
    const pixels=image.getMipmap(level); check(pixels.data.length===pixels.width*pixels.height*4,'BLP mip size mismatch');
    sizes.push([pixels.width,pixels.height]);
    if (level===0) fs.writeFileSync(path.join(decodedFolder,path.basename(atlas.path)+'.rgba'),pixels.data);
  }
  check(sizes.length===atlas.mipmaps && sizes.at(-1).every(x=>x===1),'Full BLP mip chain missing');
  textureReports.push({path:atlas.path,width:image.width,height:image.height,mipmaps:sizes});
}
fs.writeFileSync(path.join(qa,'effects-validation.json'),JSON.stringify({models:reports,textures:textureReports,warcraft_runtime_tested:false},null,2));
fs.writeFileSync(path.join(qa,'render-input.json'),JSON.stringify(previews));
console.log(JSON.stringify({models:reports.length,mdx_bytes:reports.reduce((n,r)=>n+r.bytes,0),errors:reports.reduce((n,r)=>n+r.sanity.errors,0),
                           severe:reports.reduce((n,r)=>n+r.sanity.severe,0),warnings:reports.reduce((n,r)=>n+r.sanity.warnings,0),textures:textureReports.length}));
