// 지크프리트의 UV와 텍스처 참조를 아틀라스로 바꾸고 메시·모션 보존을 검사합니다.
const fs = require('fs');
const path = require('path');
const [dependencies, input, atlasRoot, output] = process.argv.slice(2);
const base = path.join(dependencies, 'viewer/node_modules/mdx-m3-viewer/dist/cjs');
const Model = require(path.join(base, 'parsers/mdlx/model')).default;
const Texture = require(path.join(base, 'parsers/mdlx/texture')).default;
const { BlpImage } = require(path.join(base, 'parsers/blp/image'));

function check(condition, message) {
  if (!condition) throw new Error(message);
}
function buffer(file) {
  const data = fs.readFileSync(file);
  return data.buffer.slice(data.byteOffset, data.byteOffset+data.byteLength);
}
const manifest = JSON.parse(fs.readFileSync(path.join(atlasRoot, 'atlas-manifest.json')));
const originalFile = path.join(input, 'Siegfried.mdx');
const original = new Model();
original.load(buffer(originalFile));
const model = new Model();
model.load(buffer(originalFile));
check(!fs.existsSync(output), 'Existing output is preserved');
check(model.textures.every(t => t.wrapMode === 0 && t.replaceableId === 0), 'Unsupported texture wrapping');
check(model.materials.every(m => m.layers.length === 1 && m.layers[0].animations.length === 0), 'Unsupported material animation');
const tiles = model.textures.map(t => manifest.mapping[path.basename(t.path.replaceAll('\\', '/'), '.blp')]);
check(tiles.every(Boolean), 'Texture missing from atlas');
const paths = manifest.atlases.map(a => a.path);
const oldIds = model.materials.map(m => m.layers[0].textureId);
let error = 0;
for (const geo of model.geosets) {
  check(geo.uvSets.length === 1, 'Unsupported UV sets');
  const tile = tiles[oldIds[geo.materialId]], [x, y, w, h] = tile.rect;
  const uv = geo.uvSets[0];
  for (let i = 0; i < uv.length; i += 2) {
    const u = uv[i], v = uv[i+1];
    check(u >= 0 && u <= 1 && v >= 0 && v <= 1, 'UV outside source texture');
    uv[i] = (x+u*w)/tile.width;
    uv[i+1] = (y+v*h)/tile.height;
    error = Math.max(error, Math.abs((uv[i]*tile.width-x)/w-u), Math.abs((uv[i+1]*tile.height-y)/h-v));
  }
}
model.materials.forEach((m, i) => m.layers[0].textureId = paths.indexOf(tiles[oldIds[i]].atlas));
model.textures = paths.map(p => {
  const texture = new Texture();
  texture.path = p.replaceAll('/', '\\');
  return texture;
});
const bytes = Buffer.from(model.saveMdx());
const restored = new Model();
restored.load(bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset+bytes.byteLength));
check(Buffer.from(restored.saveMdx()).equals(bytes), 'MDX roundtrip mismatch');
restored.textures = original.textures;
restored.materials.forEach((m, i) => m.layers[0].textureId = oldIds[i]);
restored.geosets.forEach((g, i) => g.uvSets = original.geosets[i].uvSets);
check(Buffer.from(restored.saveMdx()).equals(fs.readFileSync(originalFile)), 'Change outside UV and texture references');
check(error < 0.000001, 'UV remap error');
global.ImageData = class {
  constructor(width, height) {
    this.width = width;
    this.height = height;
    this.data = new Uint8ClampedArray(width*height*4);
  }
};
fs.mkdirSync(output, { recursive:true });
const textures = [];
for (const atlas of manifest.atlases) {
  const source = path.join(atlasRoot, atlas.path), destination = path.join(output, atlas.path);
  const image = new BlpImage();
  image.load(buffer(source));
  let levels = 0;
  for (let i = 0; i < 16 && image.mipmapOffsets[i]; i++) {
    const mip = image.getMipmap(i);
    check(mip.width === Math.max(1, atlas.width >> i) && mip.height === Math.max(1, atlas.height >> i), 'BLP mip dimensions');
    check(mip.data.length === mip.width*mip.height*4, 'BLP payload size');
    if (i === 0) {
      fs.mkdirSync(path.dirname(destination), { recursive:true });
      fs.writeFileSync(destination+'.rgba', mip.data);
    }
    levels++;
  }
  check(levels === atlas.mipmaps, 'Incomplete mip chain');
  fs.copyFileSync(source, destination);
  textures.push({ path:atlas.path, bytes:fs.statSync(destination).size, width:image.width, height:image.height, mipmaps:levels });
}
fs.writeFileSync(path.join(output, 'Siegfried.mdx'), bytes);
fs.copyFileSync(path.join(input, 'conversion.json'), path.join(output, 'conversion.json'));
fs.writeFileSync(path.join(output, 'atlas-validation.json'), JSON.stringify({ textures, uv_inverse_max_error:error,
  only_uv_and_texture_references_changed:true, geometry_skin_animation_preserved:true,
  roundtrip_identical:true, warcraft_runtime_tested:false }, null, 2));
console.log(JSON.stringify({ texture_count:textures.length, texture_bytes:textures.reduce((s, t) => s+t.bytes, 0), uv_error:error }));
