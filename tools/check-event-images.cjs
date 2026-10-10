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
const thumbnails = JSON.parse(fs.readFileSync(path.join(root,'content/event-images/thumbnail-manifest.json'),'utf8'));
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
assert.equal(thumbnails.displayAspect,16/9,'사건 썸네일의 표시 비율이 16:9가 아님');
assert.deepEqual(thumbnails.encodedSize,[256,128],'사건 썸네일 저장 크기 변경');
const thumbnailBySource = new Map(), thumbnailTargets = new Set();
const thumbnailFocus = JSON.parse(fs.readFileSync(path.join(root,'content/event-images/thumbnail-focus.json'),'utf8'));
for (const asset of thumbnails.assets) {
  assert.match(asset.source,/^war3mapImported\\[A-Za-z0-9_-]+\.(?:tga|blp)$/i,'썸네일 원본 경로 오류');
  assert.match(asset.target,/^war3mapImported\\UI_EventThumb_[A-Za-z0-9_-]+\.tga$/,'썸네일 출력 경로 오류');
  assert.ok(!thumbnailBySource.has(asset.source) && !thumbnailTargets.has(asset.target),'중복된 썸네일 원본 또는 출력 경로');
  thumbnailBySource.set(asset.source,asset);
  thumbnailTargets.add(asset.target);
  const source=fs.readFileSync(path.join(textureRoot,asset.source.slice('war3mapImported\\'.length)));
  assert.equal(createHash('sha256').update(source).digest('hex'),asset.sourceSha256,'썸네일 내보내기 이후 변경된 원본 '+asset.source);
  assert.ok(Array.isArray(asset.sourceSize) && asset.sourceSize.length===2 && asset.sourceSize.every(x=>Number.isInteger(x)&&x>0),'원본 크기 오류 '+asset.source);
  assert.ok(Number.isFinite(asset.sourceAspect) && asset.sourceAspect>0,'원본 표시 비율 오류 '+asset.source);
  const expectedSourceAspect=imageAspects.get(asset.source) ?? asset.sourceSize[0]/asset.sourceSize[1];
  assert.equal(asset.sourceAspect,expectedSourceAspect,'원본 그림 표시 비율 변경 '+asset.source);
  for (const field of ['contentBounds','crop']) {
    const bounds=asset[field];
    assert.ok(Array.isArray(bounds) && bounds.length===4 && bounds.every(Number.isFinite),'썸네일 '+field+' 기록 오류 '+asset.source);
    assert.ok(bounds[0]>=0 && bounds[1]>=0 && bounds[2]>bounds[0] && bounds[3]>bounds[1] &&
      bounds[2]<=asset.sourceSize[0]+1e-6 && bounds[3]<=asset.sourceSize[1]+1e-6,'썸네일 '+field+' 원본 경계 초과 '+asset.source);
  }
  const [left,top,right,bottom]=asset.crop, [contentLeft,contentTop,contentRight,contentBottom]=asset.contentBounds;
  assert.ok(left>=contentLeft-1e-6 && top>=contentTop-1e-6 && right<=contentRight+1e-6 && bottom<=contentBottom+1e-6,
    '제거한 패딩이 크롭에 다시 포함됨 '+asset.source);
  const croppedAspect=asset.sourceAspect*((right-left)/asset.sourceSize[0])/((bottom-top)/asset.sourceSize[1]);
  assert.ok(Math.abs(croppedAspect-thumbnails.displayAspect)<1e-6,'크롭 영역의 실제 표시 비율이 16:9가 아님 '+asset.source);
  assert.ok(Array.isArray(asset.anchor) && asset.anchor.length===2 && asset.anchor.every(x=>Number.isFinite(x)&&x>=0&&x<=1),'썸네일 구도 중심 오류 '+asset.source);
  assert.deepEqual(asset.anchor,thumbnailFocus.overrides[asset.source]?.anchor ?? thumbnailFocus.defaultAnchor,
    '구도 설정 이후 썸네일을 다시 내보내야 함 '+asset.source);
  const data=fs.readFileSync(path.join(textureRoot,asset.target.slice('war3mapImported\\'.length)));
  assert.equal(data.length,asset.bytes,'썸네일 파일 크기 불일치 '+asset.target);
  assert.equal(createHash('sha256').update(data).digest('hex'),asset.sha256,'다른 버전의 사건 썸네일 '+asset.target);
  assert.ok(data.length>=18 && data[1]===0 && data[2]===2 && data.readUInt16LE(12)===256 && data.readUInt16LE(14)===128 &&
    data[16]===32 && (data[17]&15)===8,'256x128 비압축 RGBA32 TGA가 아님 '+asset.target);
  const pixels=18+data[0], pixelEnd=pixels+256*128*4;
  assert.ok(data.length>=pixelEnd,'잘린 썸네일 픽셀 데이터 '+asset.target);
  for (let offset=pixels+3;offset<pixelEnd;offset+=4) assert.equal(data[offset],255,'투명 여백이 남은 썸네일 '+asset.target);
}
const expectedThumbnail=source=>{
  const asset=thumbnailBySource.get(source);
  assert.ok(asset,'원본 그림의 썸네일 누락 '+source);
  return asset.target;
};
assert.equal(catalog.replace(/\r\n/g,'\n'), generate(worlds), '검토 JSON과 생성 카탈로그가 다릅니다.');
const t = fresh(0, true), e = t.e, images = new Set();
const idByKey = new Map();
for (let id=1;id<=e.PROTO_EVENT_COUNT;id++) {
  assert.ok(e.ProtoEventKey[id], '사건 정의 누락 '+id);
  assert.ok(!idByKey.has(e.ProtoEventKey[id]), '사건 key 중복 '+e.ProtoEventKey[id]);
  idByKey.set(e.ProtoEventKey[id],id);
  const image = e.ProtoEventIcon[id];
  assert.match(image, /^war3mapImported\\UI_EventThumb_[A-Za-z0-9_-]+\.tga$/, '동일 규격 썸네일을 사용하지 않는 사건 '+id+' '+e.ProtoEventName[id]);
  const target = path.join(textureRoot,image.slice('war3mapImported\\'.length));
  assert.ok(fs.existsSync(target) && fs.statSync(target).isFile(), '사건 그림 파일 누락 '+id+' '+target);
  assert.ok(thumbnailTargets.has(image),'등록되지 않은 사건 썸네일 '+image);
  assert.equal(e.ProtoEventImageAspect[id], Number(thumbnails.displayAspect.toFixed(6)), '생성된 사건 썸네일 표시 비율 오류 '+id);
  images.add(image);
}
let entries = 0, explicitImages = 0, regionalImages = 0, commonImages = 0;
for (const world of worlds) {
  if (world.world.key!=='common') {
    for (let slot=0;slot<4;slot++) {
      const id = idByKey.get(world.world.key+'_entry_'+slot);
      assert.ok(id, '지역 방문 사건 누락 '+world.world.key+' '+slot);
      assert.equal(e.ProtoEventIcon[id], expectedThumbnail(world.world.entryIcon), '지역 방문 그림의 썸네일 연결 오류 '+id);
      entries++;
    }
  }
  for (const event of world.events) {
    const id = idByKey.get(event.key);
    assert.ok(id, '생성 사건 누락 '+event.key);
    if (event.icon) {
      assert.equal(e.ProtoEventIcon[id], expectedThumbnail(event.icon), '명시한 사건 그림의 썸네일 연결 오류 '+event.key);
      explicitImages++;
    } else {
      assert.ok(regionalKeys.has(event.key), '그림 선정 검토 없이 지역 대표로 대체되는 사건 '+event.key);
      assert.ok(world.world.entryIcon, '대표 그림 없는 사건 '+event.key);
      assert.equal(e.ProtoEventIcon[id], expectedThumbnail(world.world.entryIcon), '지역 대표 그림의 썸네일 연결 오류 '+event.key);
      regionalImages++;
    }
    if (world.world.key==='common') {
      assert.ok(event.icon, '공통 사건의 인물 그림 누락 '+event.key);
      commonImages++;
    }
  }
}
assert.equal(e.PROTO_EVENT_COUNT, entries+explicitImages+regionalImages);
assert.deepEqual(images,thumbnailTargets,'사용되지 않거나 누락된 사건 썸네일');
// 후보와 선택 후 본문을 같은 사건으로 렌더링하여 표시 단계별 기본 아이콘 복귀를 잡는다.
const samples = [
  [129, 'ab68_weed_hand', 'UI_Card_BAM1_16000_Art.tga'],
  [133, 'abydos_main_01', 'UI_Event_ABE_classroom.tga'],
  [372, 'hsr_view_without_armor', 'UI_Card_HSR_1310_Icon.tga'],
  [377, 'hsr_main_01', 'UI_Card_Misha.tga'],
  [idByKey.get('axel_main_03'), 'axel_main_03', path.win32.basename(eventByKey.get('axel_main_03').icon)],
  [idByKey.get('fy_shelter_question'), 'fy_shelter_question', 'UI_Card_FSN_ch09_Art.tga'],
  [idByKey.get('axel_party_water'), 'axel_party_water', 'UI_Card_KSO1_aqua_Art.tga'],
];
t.start();
for (const [id,key] of samples) {
  assert.equal(e.ProtoEventKey[id], key, '회귀 검사 대상 사건 ID 변경');
}
function checkImage(frameId, id, image, box, width, height) {
  const f=t.frame(frameId), [x,y,w,h]=box;
  assert.ok(t.visible(frameId), '사건 그림 프레임 숨김');
  assert.equal(f.texture, image, '사건 그림 표시 경로 오류');
  assert.ok(Number.isFinite(f.w) && Number.isFinite(f.h) && f.w>0 && f.h>0, '유효하지 않은 그림 크기');
  assert.ok(f.w<=w+1e-9 && f.h<=h+1e-9, '사건 그림이 표시 영역을 벗어남');
  assert.ok(Math.abs(f.x+f.w/2-(x+w/2))<1e-9, '사건 그림 가로 가운데 정렬 오류');
  assert.ok(Math.abs(-f.y+f.h/2-(y+h/2))<1e-9, '사건 그림 세로 가운데 정렬 오류');
  const pixelAspect=(f.w*width/0.8)/(f.h*height/0.6);
  assert.ok(Math.abs(pixelAspect-e.ProtoEventImageAspect[id])<0.000001, '클라이언트 화면에서 썸네일 비율이 변형됨');
  return f;
}
const resolutions=[[1600,900],[1280,960],[2560,1080]];
let mockScenes=0,candidateChecks=0,storyChecks=0;
for (const [width,height] of resolutions) {
  e.windowWidth=width;e.windowHeight=height;
  e.DialogueNode[0]=0;
  e.ProtoStage[0]=1;e.ExpUIOpen(9);
  let expectedDimensions;
  // 모든 사건을 1~4칸 각각에 표시해 원본 종류와 후보 개수에 따라 크기가 달라지지 않게 한다.
  for (let choices=1;choices<=4;choices++) {
    e.ProtoChoices[0]=choices;
    for (let first=1;first<=e.PROTO_EVENT_COUNT;first+=choices) {
      for (let i=1;i<=choices;i++) e.ProtoCandidates[e.ExpKey(0,i)]=Math.min(first+i-1,e.PROTO_EVENT_COUNT);
      t.render();mockScenes++;
      for (let i=1;i<=choices;i++) {
        const id=e.ProtoCandidates[e.ExpKey(0,i)];
        const image=checkImage(e.UIExpeditionPrototype_CandidateIcon[i],id,e.ProtoEventIcon[id],[0.012,0.052,0.150,0.108],width,height);
        const dimensions=[image.w,image.h,image.y];
        if (!expectedDimensions) expectedDimensions=dimensions;
        assert.deepEqual(dimensions,expectedDimensions,'사건 또는 후보 수에 따라 그림 크기·위쪽 정렬이 달라짐 '+id);
        const title=t.frame(e.UIExpeditionPrototype_CandidateTitle[i]);
        const intro=t.frame(e.UIExpeditionPrototype_CandidateIntro[i]);
        const bonus=t.frame(e.UIExpeditionPrototype_CandidateBonus[i]);
        const footer=t.frame(e.UIExpeditionPrototype_CandidateFooter[i]);
        assert.ok(-image.y+image.h<=-title.y,'그림과 사건 제목이 겹침 '+id);
        assert.ok(-title.y+title.h<=-intro.y,'사건 제목과 소개가 겹침 '+id);
        if (t.visible(bonus.id)) {
          assert.ok(-intro.y+intro.h<=-bonus.y,'사건 소개와 보상이 겹침 '+id);
          assert.ok(-bonus.y+bonus.h<=-footer.y,'사건 보상과 선택 버튼이 겹침 '+id);
        } else assert.ok(-intro.y+intro.h<=-footer.y,'사건 소개와 선택 버튼이 겹침 '+id);
        candidateChecks++;
      }
    }
  }
  for (const [id,,image] of samples) {
    e.ProtoSelected[0]=id;
    for (const stage of [2,3]) {
      e.ProtoStage[0]=stage;t.render();
      checkImage(e.UIExpeditionPrototype_StoryIcon,id,expectedThumbnail('war3mapImported\\'+image),[0.018,0.045,0.080,0.080],width,height);
      mockScenes++;storyChecks++;
    }
  }
  // 대화 노드가 있는 후속 장면은 작은 그림 영역을 사용한다.
  e.ProtoSelected[0]=168;e.DialogueNode[0]=1;
  e.ProtoStage[0]=2;t.render();
  checkImage(e.UIExpeditionPrototype_StoryIcon,168,expectedThumbnail('war3mapImported\\UI_Event_ACE_friends.tga'),[0.018,0.045,0.044,0.044],width,height);
  mockScenes++;storyChecks++;
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
  uniqueTextures:images.size,eventTextureHashes:manifest.assets.length,thumbnailHashes:thumbnailTargets.size,sourceHashes:thumbnailBySource.size,
  mockScenes,candidateChecks,storyChecks,resolutions,zeroSizeChecks:3,textureRoot,
  checks:'source and thumbnail hashes, opaque 256x128 RGBA32, crop bounds and 16:9 aspect, event mapping, all candidates at 1-4 choices, consistent image dimensions, nonoverlapping frames, story frames, zero size guard',
  runtimeTested:false}));
