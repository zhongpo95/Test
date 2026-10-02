// 사 모델의 UV와 텍스처 참조를 아틀라스로 바꾸고 모션 보존을 검사합니다.
const fs=require('fs'),path=require('path');
const [deps,input,atlasRoot,output]=process.argv.slice(2),lib=path.join(deps,'viewer/node_modules/mdx-m3-viewer/dist/cjs');
const Model=require(path.join(lib,'parsers/mdlx/model')).default,Texture=require(path.join(lib,'parsers/mdlx/texture')).default;
const {BlpImage}=require(path.join(lib,'parsers/blp/image')),sanityTest=require(path.join(lib,'utils/mdlx/sanitytest/sanitytest')).default;
const manifest=JSON.parse(fs.readFileSync(path.join(atlasRoot,'atlas-manifest.json'),'utf8')),motion=JSON.parse(fs.readFileSync(path.join(input,'render-motion.json'),'utf8')),name=motion.name;
function check(ok,message){if(!ok)throw Error(message);}
function read(file){const b=fs.readFileSync(file);return b.buffer.slice(b.byteOffset,b.byteOffset+b.byteLength);}
const original=new Model();original.load(read(path.join(input,name+'.mdx')));const model=new Model();model.load(read(path.join(input,name+'.mdx')));
check(!fs.existsSync(output),'Preserve existing output');fs.mkdirSync(output,{recursive:true});
const mapping=manifest.models[name],atlasPaths=[...new Set(mapping.map(t=>t.atlas))];check(mapping.length===model.textures.length,'Texture mapping count');
check(model.materials.every(m=>m.layers.length===1&&m.layers[0].animations.length===0),'Unsupported material animation/layers');
check(model.textures.every(t=>t.wrapMode===0&&t.replaceableId===0),'Unsupported repeating/replacement texture');
const materialTextures=model.materials.map(m=>m.layers[0].textureId);let uvError=0;
for(let gi=0;gi<model.geosets.length;gi++){
 const g=model.geosets[gi],tile=mapping[materialTextures[g.materialId]],[x,y,w,h]=tile.rect;check(g.uvSets.length===1,'Multiple UV sets');
 const uv=g.uvSets[0];for(let i=0;i<uv.length;i+=2){const u=uv[i],v=uv[i+1];check(u>=0&&u<=1&&v>=0&&v<=1,'UV outside texture');uv[i]=(x+u*w)/tile.width;uv[i+1]=(y+v*h)/tile.height;uvError=Math.max(uvError,Math.abs((uv[i]*tile.width-x)/w-u),Math.abs((uv[i+1]*tile.height-y)/h-v));}
}
model.materials.forEach((m,i)=>m.layers[0].textureId=atlasPaths.indexOf(mapping[materialTextures[i]].atlas));
model.textures=atlasPaths.map(p=>{const t=new Texture();t.path=p.replaceAll('/','\\');return t;});
const file=path.join(output,name+'.mdx');fs.writeFileSync(file,Buffer.from(model.saveMdx()));const decoded=new Model();decoded.load(read(file));check(Buffer.from(decoded.saveMdx()).equals(fs.readFileSync(file)),'Roundtrip mismatch');
const restored=new Model();restored.load(read(file));restored.textures=original.textures;restored.materials.forEach((m,i)=>m.layers[0].textureId=materialTextures[i]);restored.geosets.forEach((g,i)=>g.uvSets=original.geosets[i].uvSets);check(Buffer.from(restored.saveMdx()).equals(fs.readFileSync(path.join(input,name+'.mdx'))),'Changes outside UV and texture references');check(uvError<0.000001,'UV remap error');
global.ImageData=class{constructor(width,height){this.width=width;this.height=height;this.data=new Uint8ClampedArray(width*height*4);}};
const textures=[];
for(const p of atlasPaths){const image=new BlpImage(),file=path.join(atlasRoot,p);image.load(read(file));let levels=0;for(let level=0;level<16&&image.mipmapOffsets[level];level++){const im=image.getMipmap(level);check(im.width===Math.max(1,image.width>>level)&&im.height===Math.max(1,image.height>>level),'Wrong mip dimensions');check(im.data.length===im.width*im.height*4,'Wrong mip payload');if(level===0)fs.writeFileSync(file+'.rgba',im.data);levels++;}textures.push({path:p.replaceAll('/','\\'),width:image.width,height:image.height,mipmaps:levels,bytes:fs.statSync(file).size});}
const materials=motion.materials.map((m,i)=>({...m,texture:decoded.materials[i].layers[0].textureId}));
const preview={...motion,materials,textures,geosets:motion.geosets.map((g,i)=>({...g,uv:Array.from(decoded.geosets[i].uvSets[0])}))};fs.writeFileSync(path.join(output,'render-motion.json'),JSON.stringify(preview));
for(const f of fs.readdirSync(input).filter(f=>/^(hmm|cross)-[0-9.]+\.json$/.test(f))){const sample=JSON.parse(fs.readFileSync(path.join(input,f),'utf8'));sample.materials=materials;sample.textures=textures;sample.geosets.forEach((g,i)=>{const uv=decoded.geosets[i].uvSets[0];g.uv=Array.from({length:uv.length/2},(_,j)=>[uv[j*2],1-uv[j*2+1]]);});fs.writeFileSync(path.join(output,f),JSON.stringify(sample));}
const sanity=sanityTest(decoded);check(sanity.errors===0&&sanity.warnings===0,'Model structure issue');
const report={model:name,texture_count:textures.length,texture_bytes:textures.reduce((s,t)=>s+t.bytes,0),textures,uv_inverse_max_error:uvError,roundtrip_identical:true,only_uv_and_texture_references_changed:true,geometry_skin_animation_identical_to_v5:true,sanity:{errors:sanity.errors,warnings:sanity.warnings,severe:sanity.severe},warcraft_runtime_tested:false};fs.writeFileSync(path.join(output,'atlas-validation.json'),JSON.stringify(report,null,2));console.log(JSON.stringify(report));
