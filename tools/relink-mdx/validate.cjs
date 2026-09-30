// 독립 MDX·BLP 파서로 지크프리트 결과를 검사하고 렌더링용 자세를 복원합니다.
const fs = require('fs');
const path = require('path');
const [dependencyRoot, modelFolder] = process.argv.slice(2);
const base = path.join(dependencyRoot, 'viewer/node_modules/mdx-m3-viewer/dist/cjs');
const Model = require(path.join(base, 'parsers/mdlx/model')).default;
const { BlpImage } = require(path.join(base, 'parsers/blp/image'));
const sanityTest = require(path.join(base, 'utils/mdlx/sanitytest/sanitytest')).default;
const { mat4, quat, vec3 } = require(path.join(dependencyRoot, 'viewer/node_modules/gl-matrix'));
global.ImageData = class {
  constructor(width, height) {
    this.width = width;
    this.height = height;
    this.data = new Uint8ClampedArray(width * height * 4);
  }
};

function buffer(file) {
  const bytes = fs.readFileSync(file);
  return bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
}

const model = new Model();
model.load(buffer(path.join(modelFolder, 'Siegfried.mdx')));
const nodes = [...model.bones, ...model.helpers, ...model.attachments];
if (nodes.some((node,index) => node.objectId !== index)) throw new Error('Node IDs must match legacy chunk order');
const report = { version: model.version, sequences: model.sequences.length, bones: model.bones.length, helpers:model.helpers.length, attachments:model.attachments.length,
  geosets: model.geosets.length, triangles: model.geosets.reduce((sum, geo) => sum + geo.faces.length / 3, 0),
  roundtripIdentical: Buffer.from(model.saveMdx()).equals(fs.readFileSync(path.join(modelFolder, 'Siegfried.mdx'))), textures: [] };
const sanity = sanityTest(model);
report.sanity = { errors: sanity.errors, severe: sanity.severe, warnings: sanity.warnings, unused: sanity.unused };
fs.writeFileSync(path.join(modelFolder, 'sanity.json'), JSON.stringify(sanity, null, 2));
for (const texture of model.textures) {
  const file = path.join(modelFolder, ...texture.path.split('\\'));
  const image = new BlpImage();
  image.load(buffer(file));
  const sizes = [];
  for (let level = 0; level < 16 && image.mipmapOffsets[level]; level++) {
    const decoded = image.getMipmap(level);
    if (decoded.data.length !== decoded.width * decoded.height * 4) throw new Error('BLP decode size');
    sizes.push([decoded.width, decoded.height]);
    if (level === 0) fs.writeFileSync(file + '.rgba', decoded.data);
  }
  report.textures.push({ path: texture.path, width: image.width, height: image.height, mipmaps: sizes });
}

function sample(bone, tag, time, fallback) {
  const animation = bone.animations.find(animation => animation.name === tag);
  if (!animation) return fallback;
  const frames = animation.frames;
  let right = frames.findIndex(frame => frame >= time);
  if (right < 0) return animation.values[frames.length - 1];
  if (right === 0 || frames[right] === time) return animation.values[right];
  const left = right - 1;
  const t = (time - frames[left]) / (frames[right] - frames[left]);
  if (tag === 'KGRT') return quat.slerp(quat.create(), animation.values[left], animation.values[right], t);
  return animation.values[left].map((value, index) => value * (1-t) + animation.values[right][index] * t);
}

const preview = path.join(modelFolder, 'poses');
fs.mkdirSync(preview, { recursive: true });
const conversion = JSON.parse(fs.readFileSync(path.join(modelFolder, 'conversion.json')));
for (const entry of conversion.motions) {
  if (!['0000','0010','0020','0030','0500','0520','0620','3000','3011','3200','3400','0b00','c000'].includes(entry.source.slice(7,11))) continue;
  const frames = [0, Math.floor(entry.frames / 2), entry.frames - 1];
  for (const frame of frames) {
    const time = entry.start + Math.round(frame * 1000 / 60);
    const worlds = [];
    function worldMatrix(id) {
      if (worlds[id]) return worlds[id];
      const bone = nodes[id];
      const pivot = model.pivotPoints[bone.objectId];
      const translation = sample(bone, 'KGTR', time, [0,0,0]);
      const rotation = sample(bone, 'KGRT', time, [0,0,0,1]);
      const scale = sample(bone, 'KGSC', time, [1,1,1]);
      const local = mat4.fromRotationTranslationScaleOrigin(mat4.create(), rotation, translation, scale, pivot);
      worlds[id] = bone.parentId < 0 ? local : mat4.multiply(mat4.create(), worldMatrix(bone.parentId), local);
      return worlds[id];
    }
    for (const bone of nodes) worldMatrix(bone.objectId);
    const geosets = [];
    for (const geo of model.geosets) {
      const groups = [];
      let offset = 0;
      for (const size of geo.matrixGroups) {
        groups.push(geo.matrixIndices.slice(offset, offset + size));
        offset += size;
      }
      const vertices = [], normals = [];
      for (let index = 0; index < geo.vertices.length / 3; index++) {
        const group = groups[geo.vertexGroups[index]];
        const source = geo.vertices.slice(index*3,index*3+3);
        const normal = geo.normals.slice(index*3,index*3+3);
        const target = [0,0,0], targetNormal = [0,0,0];
        for (const node of group) {
          const transformed = vec3.transformMat4(vec3.create(), source, worlds[node]);
          for (let component = 0; component < 3; component++) {
            target[component] += transformed[component]/group.length;
            targetNormal[component] += (worlds[node][component]*normal[0] + worlds[node][4+component]*normal[1] + worlds[node][8+component]*normal[2])/group.length;
          }
        }
        if (target.some(value => !Number.isFinite(value))) throw new Error('Non-finite skinning');
        vertices.push(target);
        normals.push(Array.from(vec3.normalize(vec3.create(), targetNormal)));
      }
      const faces = [];
      for (let index = 0; index < geo.faces.length; index += 3) faces.push(Array.from(geo.faces.slice(index,index+3)));
      const uv = [];
      for (let index = 0; index < geo.uvSets[0].length; index += 2) uv.push([geo.uvSets[0][index],1-geo.uvSets[0][index+1]]);
      geosets.push({ vertices, normals, faces, uv, material: geo.materialId });
    }
    fs.writeFileSync(path.join(preview, entry.source.replace('.mot','')+'_'+frame+'.json'), JSON.stringify({ name:entry.name, source:entry.source, frame, geosets,
      materials:model.materials.map(mat => model.textures[mat.layers[0].textureId].path) }));
  }
}
fs.writeFileSync(path.join(modelFolder, 'validation.json'), JSON.stringify(report,null,2));
console.log(JSON.stringify(report));
if (report.sanity.errors || report.sanity.severe || !report.roundtripIdentical) process.exitCode = 1;
