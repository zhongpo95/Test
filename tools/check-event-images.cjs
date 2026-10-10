// 모든 사건의 그림 연결과 파일 존재, 생성 데이터 및 실제 UI 표시 경로를 검사한다.
'use strict';
const fs = require('node:fs'), path = require('node:path'), assert = require('node:assert/strict');
const {createHash} = require('node:crypto');
const {generate} = require('./generate-prototype-content.cjs');
const {fresh} = require('./check-expedition-ui.cjs');
const root = path.resolve(__dirname, '..');
const args = process.argv.slice(2);
assert.equal(args.length, 2, '사용법. node tools/check-event-images.cjs --texture-root <war3mapImported 폴더>');
assert.equal(args[0], '--texture-root', '텍스처 폴더를 --texture-root로 지정하세요.');
const textureRoot = fs.realpathSync(args[1]);
assert.ok(fs.statSync(textureRoot).isDirectory(), '텍스처 경로가 폴더가 아닙니다.');
const contentRoot = path.join(root, 'content/roguelite');
const worlds = fs.readdirSync(contentRoot).filter(f=>f.endsWith('.json')).sort()
  .map(f=>JSON.parse(fs.readFileSync(path.join(contentRoot,f),'utf8')));
const catalog = fs.readFileSync(path.join(root, 'Data/Data_PrototypeCatalog.j'),'utf8');
const manifest = JSON.parse(fs.readFileSync(path.join(root,'content/event-images/texture-manifest.json'),'utf8'));
const cardIndex = JSON.parse(fs.readFileSync(path.join(root,'content/card-images/card-index.json'),'utf8'));
const cardManifest = JSON.parse(fs.readFileSync(path.join(root,'content/card-images/texture-manifest.json'),'utf8'));
const assignments = ['first','second'].flatMap(part=>JSON.parse(fs.readFileSync(
  path.join(root,'content/event-images/character-assignment-'+part+'.json'),'utf8')));
const eventByKey = new Map(worlds.flatMap(world=>world.events.map(event=>[event.key,event])));
const assignedKeys = new Set(), assignedImages = new Set();
const regionalReview = JSON.parse(fs.readFileSync(path.join(root,'content/event-images/regional-fallback-review.json'),'utf8'));
const regionalKeys = new Set(regionalReview.map(row=>row.eventKey));
assert.equal(regionalKeys.size,regionalReview.length,'지역 대표 그림 검토 중복');
for (const review of regionalReview) {
  assert.ok(eventByKey.has(review.eventKey) && review.reason, '지역 대표 그림의 사건 또는 유지 사유 누락');
  assert.ok(!eventByKey.get(review.eventKey).icon, '이미 전용 그림을 지정한 사건이 대표 그림 검토에 남음 '+review.eventKey);
}
// 파일 존재와 별개로, 검토한 인물·본문 근거·실제 배정 경로가 어긋나지 않는지 확인한다.
for (const assignment of assignments) {
  const event=eventByKey.get(assignment.eventKey);
  assert.ok(event, '그림 검토 기록에 없는 사건 '+assignment.eventKey);
  assert.ok(!assignedKeys.has(assignment.eventKey), '중복된 사건 그림 검토 '+assignment.eventKey);
  assignedKeys.add(assignment.eventKey);
  assert.ok(['character-illustration','character-portrait'].includes(assignment.kind), '인물 그림을 사건 장면으로 분류하면 안 됩니다.');
  assert.equal(event.icon, assignment.image, '검토한 사건 인물과 다른 그림 배정 '+event.key);
  const imageField=assignment.kind==='character-portrait'?'icon':'art';
  assert.ok(cardIndex.some(card=>card.name===assignment.character && 'war3mapImported\\'+card[imageField]===assignment.image),
    '인물 이름과 그림 등록이 일치하지 않음 '+event.key);
  assert.ok(assignment.evidence && (event.intro+'\n'+event.story).includes(assignment.evidence),
    '실제 사건 본문에 없는 그림 선정 근거 '+event.key);
  assignedImages.add(assignment.image);
}
for (const image of assignedImages) {
  const asset=cardManifest.assets.find(asset=>asset.target===image);
  assert.ok(asset, '등록되지 않은 인물 삽화 '+image);
  const data=fs.readFileSync(path.join(textureRoot,image.slice('war3mapImported\\'.length)));
  assert.equal(createHash('sha256').update(data).digest('hex'),asset.sha256,'다른 버전의 인물 삽화 '+image);
}
const imageAspects = new Map(manifest.assets.map(asset=>[asset.target,asset.aspectRatio]));
assert.equal(imageAspects.size, manifest.assets.length, '사건 그림 메타데이터 경로 중복');
// 같은 파일명인 구버전 패딩 텍스처가 섞여도 표시 비율 검사만 통과하지 않도록 한다.
for (const asset of manifest.assets) {
  const filename=asset.target.slice('war3mapImported\\'.length);
  assert.match(filename, /^UI_Event_[A-Za-z0-9_-]+\.tga$/, '사건 텍스처 경로 오류');
  const data=fs.readFileSync(path.join(textureRoot,filename));
  assert.equal(createHash('sha256').update(data).digest('hex'),asset.newHash,
    '코드와 다른 버전의 사건 텍스처. 새 ASI 입력을 함께 적용하세요. '+filename);
}
assert.equal(catalog.replace(/\r\n/g,'\n'), generate(worlds), '검토 JSON과 생성 카탈로그가 다릅니다.');
const t = fresh(0, true), e = t.e, images = new Set();
const idByKey = new Map();
for (let id=1;id<=e.PROTO_EVENT_COUNT;id++) {
  assert.ok(e.ProtoEventKey[id], '사건 정의 누락 '+id);
  assert.ok(!idByKey.has(e.ProtoEventKey[id]), '사건 key 중복 '+e.ProtoEventKey[id]);
  idByKey.set(e.ProtoEventKey[id],id);
  const image = e.ProtoEventIcon[id];
  assert.match(image, /^war3mapImported\\[A-Za-z0-9_-]+\.(?:tga|blp)$/i, '사용자 그림이 없는 사건 '+id+' '+e.ProtoEventName[id]);
  const target = path.join(textureRoot,image.slice('war3mapImported\\'.length));
  assert.ok(fs.existsSync(target) && fs.statSync(target).isFile(), '사건 그림 파일 누락 '+id+' '+target);
  if (image.startsWith('war3mapImported\\UI_Event_')) assert.ok(imageAspects.has(image), '사건 그림 비율 메타데이터 누락 '+image);
  const aspect = imageAspects.get(image) ?? 1;
  assert.ok(Number.isFinite(aspect) && aspect>0, '사건 그림 비율 오류 '+image);
  assert.equal(e.ProtoEventImageAspect[id], Number(aspect.toFixed(6)), '생성된 사건 그림 비율 오류 '+id);
  images.add(image);
}
let entries = 0, explicitImages = 0, regionalImages = 0, commonImages = 0;
for (const world of worlds) {
  if (world.world.key!=='common') {
    for (let slot=0;slot<4;slot++) {
      const id = idByKey.get(world.world.key+'_entry_'+slot);
      assert.ok(id, '지역 방문 사건 누락 '+world.world.key+' '+slot);
      assert.equal(e.ProtoEventIcon[id], world.world.entryIcon, '지역 방문 그림 변경 '+id);
      assert.equal(e.ProtoEventImageAspect[id], 1, '지역 방문 그림은 정사각형으로 표시해야 함 '+id);
      entries++;
    }
  }
  for (const event of world.events) {
    const id = idByKey.get(event.key);
    assert.ok(id, '생성 사건 누락 '+event.key);
    if (event.icon) {
      assert.equal(e.ProtoEventIcon[id], event.icon, '명시한 사건 그림이 대체됨 '+event.key);
      explicitImages++;
    } else {
      assert.ok(regionalKeys.has(event.key), '그림 선정 검토 없이 지역 대표로 대체되는 사건 '+event.key);
      assert.ok(world.world.entryIcon, '대표 그림 없는 사건 '+event.key);
      assert.equal(e.ProtoEventIcon[id], world.world.entryIcon, '지역 대표 그림 대체 실패 '+event.key);
      regionalImages++;
    }
    if (world.world.key==='common') {
      assert.ok(event.icon, '공통 사건의 인물 그림 누락 '+event.key);
      commonImages++;
    }
  }
}
assert.equal(e.PROTO_EVENT_COUNT, entries+explicitImages+regionalImages);
// 후보와 선택 후 본문을 같은 사건으로 렌더링하여 표시 단계별 기본 아이콘 복귀를 잡는다.
const samples = [
  [129, 'ab68_weed_hand', 'UI_Card_BAM1_16000_Art.tga'],
  [133, 'abydos_main_01', 'UI_Event_ABE_classroom.tga'],
  [372, 'hsr_view_without_armor', 'UI_Card_HSR_1310_Icon.tga'],
  [377, 'hsr_main_01', 'UI_Card_Misha.tga'],
];
assert.ok(Math.abs(e.ProtoEventImageAspect[168]-600/338)<0.000001, '자신과 닮은 누군가 그림의 원본 비율 오류');
t.start();
e.ProtoChoices[0] = samples.length;
for (let i=0;i<samples.length;i++) {
  const [id,key] = samples[i];
  assert.equal(e.ProtoEventKey[id], key, '회귀 검사 대상 사건 ID 변경');
  e.ProtoCandidates[e.ExpKey(0,i+1)] = id;
}
function checkImage(frameId, id, image, box, width, height) {
  const f=t.frame(frameId), [x,y,w,h]=box;
  assert.ok(t.visible(frameId), '사건 그림 프레임 숨김');
  assert.equal(f.texture, 'war3mapImported\\'+image, '사건 그림 표시 경로 오류');
  assert.ok(Number.isFinite(f.w) && Number.isFinite(f.h) && f.w>0 && f.h>0, '유효하지 않은 그림 크기');
  assert.ok(f.w<=w+1e-9 && f.h<=h+1e-9, '사건 그림이 표시 영역을 벗어남');
  assert.ok(Math.abs(f.x+f.w/2-(x+w/2))<1e-9, '사건 그림 가로 가운데 정렬 오류');
  assert.ok(Math.abs(-f.y+f.h/2-(y+h/2))<1e-9, '사건 그림 세로 가운데 정렬 오류');
  const pixelAspect=(f.w*width/0.8)/(f.h*height/0.6);
  assert.ok(Math.abs(pixelAspect-e.ProtoEventImageAspect[id])<0.000001, '클라이언트 화면에서 원본 그림 비율이 변형됨');
}
const resolutions=[[1600,900],[1280,960],[2560,1080]];
let mockScenes=0;
for (const [width,height] of resolutions) {
  e.windowWidth=width;e.windowHeight=height;
  e.DialogueNode[0]=0;
  e.ProtoStage[0]=1;e.ExpUIOpen(9);t.render();
  for (let i=0;i<samples.length;i++) {
    const [id,,image]=samples[i];
    checkImage(e.UIExpeditionPrototype_CandidateIcon[i+1],id,image,[0.012,0.052,0.150,0.088],width,height);
    mockScenes++;
  }
  for (const [id,,image] of samples) {
    e.ProtoSelected[0]=id;
    for (const stage of [2,3]) {
      e.ProtoStage[0]=stage;t.render();
      checkImage(e.UIExpeditionPrototype_StoryIcon,id,image,[0.018,0.045,0.080,0.080],width,height);
      mockScenes++;
    }
  }
  // 대화 노드가 있는 후속 장면은 작은 그림 영역을 사용한다.
  e.ProtoSelected[0]=168;e.DialogueNode[0]=1;
  e.ProtoStage[0]=2;t.render();
  checkImage(e.UIExpeditionPrototype_StoryIcon,168,'UI_Event_ACE_friends.tga',[0.018,0.045,0.044,0.044],width,height);
  mockScenes++;
}
const lastImage={...t.frame(e.UIExpeditionPrototype_StoryIcon)};
for (const [width,height] of [[0,0],[0,900],[1600,0]]) {
  e.windowWidth=width;e.windowHeight=height;t.render();
  const current=t.frame(e.UIExpeditionPrototype_StoryIcon);
  assert.equal(current.w,lastImage.w, '클라이언트 크기가 0일 때 마지막 비율을 보존해야 함');
  assert.equal(current.h,lastImage.h, '클라이언트 크기가 0일 때 마지막 비율을 보존해야 함');
}
console.log(JSON.stringify({events:e.PROTO_EVENT_COUNT,entries,explicitImages,regionalImages,commonImages,
  characterAssignments:assignments.length,characterTextureHashes:assignedImages.size,
  uniqueTextures:images.size,eventTextureHashes:manifest.assets.length,mockScenes,resolutions,zeroSizeChecks:3,textureRoot,
  checks:'custom image coverage, texture existence, generated catalog, explicit image priority, content aspect ratios, candidate and story frames, client aspect fit and zero size guard',
  runtimeTested:false}));
