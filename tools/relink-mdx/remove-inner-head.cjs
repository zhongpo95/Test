// 하관 보호대가 있는 PL1102의 안쪽 얼굴 메시를 제거하고 나머지 메시·모션을 보존합니다.
const fs = require('fs');
const path = require('path');
const [dependencies, input, output] = process.argv.slice(2);
const Model = require(path.join(dependencies, 'viewer/node_modules/mdx-m3-viewer/dist/cjs/parsers/mdlx/model')).default;

function check(condition, message) {
  if (!condition) throw new Error(message);
}
function buffer(file) {
  const bytes = fs.readFileSync(file);
  return bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset+bytes.byteLength);
}
const conversion = JSON.parse(fs.readFileSync(path.join(input, 'conversion.json')));
check(conversion.body_variant === 'pl1102' && conversion.lod === 2, 'Only inspected PL1102 LOD2 is supported');
check(!conversion.inner_head_cleanup, 'Input head was already removed');
check(!fs.existsSync(output), 'Existing output is preserved');
const originalFile = path.join(input, 'Siegfried.mdx');
const model = new Model();
model.load(buffer(originalFile));
check(conversion.skin_maps.length === model.geosets.length, 'Source geoset mapping mismatch');
check(model.geosetAnimations.length === 0 && model.bones.every(b => b.geosetId === -1), 'Explicit geoset references require remapping');
const originalGeosets = model.geosets;
const removed = [], kept = [];
for (let i = 0; i < originalGeosets.length; i++) {
  const geo = originalGeosets[i], map = conversion.skin_maps[i];
  if (map.entity === 'fp1100' || (map.entity === 'pl1100' && geo.materialId === 0)) {
    removed.push({ index:i, entity:map.entity, material:geo.materialId, triangles:geo.faces.length/3 });
  } else {
    kept.push(i);
  }
}
// PL1102's first body material is its separate inner-face strip, not armor or neck skin.
check(conversion.textures[0] === 'fp1100_face_lod0_albd', 'Unexpected body material layout');
check(removed.filter(g => g.entity === 'pl1100').reduce((s, g) => s+g.triangles, 0) === 76, 'Inner-face strip mismatch');
check(removed.filter(g => g.entity === 'fp1100').reduce((s, g) => s+g.triangles, 0) === 2412, 'Separate head mesh mismatch');
model.geosets = kept.map(i => originalGeosets[i]);
const bytes = Buffer.from(model.saveMdx());
const decoded = new Model();
decoded.load(bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset+bytes.byteLength));
check(Buffer.from(decoded.saveMdx()).equals(bytes), 'MDX roundtrip mismatch');
decoded.geosets = originalGeosets;
check(Buffer.from(decoded.saveMdx()).equals(fs.readFileSync(originalFile)), 'Unexpected change outside removed geosets');
const report = { body_variant:'pl1102', removed_geosets:removed,
  removed_triangles:removed.reduce((s, g) => s+g.triangles, 0),
  original_triangles:conversion.triangles,
  triangles:model.geosets.reduce((s, g) => s+g.faces.length/3, 0),
  only_inner_face_geosets_removed:true, retained_geometry_skin_uv_identical:true,
  nodes_animation_materials_textures_identical:true, roundtrip_identical:true, warcraft_runtime_tested:false };
check(report.triangles === 12785, 'Unexpected retained triangle count');
fs.mkdirSync(output, { recursive:true });
fs.writeFileSync(path.join(output, 'Siegfried.mdx'), bytes);
for (const texture of model.textures) {
  const relative = texture.path.replaceAll('\\', '/');
  check(relative.startsWith('Siegfried_Helmet/') && !relative.includes('..'), 'Unexpected texture path');
  const destination = path.join(output, relative);
  fs.mkdirSync(path.dirname(destination), { recursive:true });
  fs.copyFileSync(path.join(input, relative), destination);
}
fs.writeFileSync(path.join(output, 'conversion.json'), JSON.stringify({ ...conversion,
  skin_maps:kept.map(i => conversion.skin_maps[i]), triangles:report.triangles, geosets:model.geosets.length,
  inner_head_cleanup:report }, null, 2));
fs.writeFileSync(path.join(output, 'head-cleanup.json'), JSON.stringify(report, null, 2));
console.log(JSON.stringify(report));
