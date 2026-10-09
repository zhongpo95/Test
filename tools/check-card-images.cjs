// 현재 보상 전체의 그림 연결, 누적 카드 공유와 보관함의 큰 그림 표시를 검증한다.
'use strict';
const fs = require('node:fs'), path = require('node:path'), assert = require('node:assert/strict');
const {fresh} = require('./check-expedition-ui.cjs');
const root = path.resolve(__dirname, '..');
const read = file => fs.readFileSync(path.join(root, file), 'utf8');
const registry = read('Data/Data_PrototypeCardImages.j');
const index = JSON.parse(read('content/card-images/card-index.json'));
const manifest = JSON.parse(read('content/card-images/texture-manifest.json'));
const sources = JSON.parse(read('content/card-images/ending-sources.json'));
const registrations = [...registry.matchAll(/call SetImages\((\d+), "([^"]+)", "([^"]+)"\)/g)]
  .map(m => ({id:Number(m[1]), icon:m[2], art:m[3]}));
assert.equal(new Set(registrations.map(x=>x.id)).size, registrations.length, '중복 그림 등록 ID');
const paths = new Set(manifest.assets.map(x=>x.target));
assert.equal(paths.size, manifest.assets.length, '중복 맵 경로');
assert.equal(sources.length, 13);
const t = fresh(0, true), e = t.e;
for (const x of registrations) e.SetImages(x.id, x.icon, x.art);
const group = new Map();
for (const x of index) {
  assert.ok(!group.has(x.characterId), '중복 캐릭터 카드');
  group.set(x.characterId, x);
  for (const id of x.rewardIds) {
    assert.equal(e.ProtoCardCharacter[id], x.characterId, '그림 공유 기준 변경 ' + id);
    assert.equal(e.ProtoCardHead[id], x.head);
    assert.equal(e.ProtoCardName[id], x.name);
    assert.equal(e.ProtoCardArt(id), 'war3mapImported\\' + x.icon);
    assert.equal(e.ProtoCardIllustration(id), 'war3mapImported\\' + x.art);
    assert.ok(paths.has(e.ProtoCardArt(id)), '아이콘 파일 누락 ' + id);
    assert.ok(paths.has(e.ProtoCardIllustration(id)), '큰 그림 파일 누락 ' + id);
  }
}
let rewards = 0;
for (let id=e.PROTO_CARD_FIRST;id<=e.PROTO_CARD_LAST;id++) {
  assert.ok(group.has(e.ProtoCardCharacter[id]), '그림 없는 보상 ' + id);
  rewards++;
}
for (const x of sources) {
  assert.equal(e.ProtoCardKey[x.cardId], x.cardKey, '엔딩 카드 ID 변경');
  assert.equal(e.ProtoCardName[x.cardId], x.cardName);
  assert.equal(e.ProtoCardEnding[x.cardId], 1);
}
const fateReviewFile = path.join(root, 'content/card-images/fate-calm-review.json');
if (fs.existsSync(fateReviewFile)) {
  const fateReview = JSON.parse(fs.readFileSync(fateReviewFile, 'utf8'));
  const replacements = JSON.parse(read('content/card-images/fate-calm-sources.json'));
  assert.deepEqual(replacements.map(x=>x.cardId), [14,16,17,18,19,20,26]);
  assert.equal(fateReview.animeOnly, true);
  for (const x of fateReview.requestedExclusions) {
    assert.equal(e.ProtoCardArt(x.characterId), 'war3mapImported\\' + x.icon);
    assert.equal(e.ProtoCardIllustration(x.characterId), 'war3mapImported\\' + x.art);
    for (const texture of x.textures) {
      assert.equal(manifest.assets.find(a=>a.target===texture.target).sha256, texture.sha256,
        '사용자가 유지하도록 지정한 그림이 변경됨 ' + x.name);
    }
  }
  for (const x of replacements) {
    assert.equal(e.ProtoCardKey[x.cardId], x.cardKey);
    assert.ok(/^https:\/\/(www\.fate-sn\.com\/ubw\/story\/img\/|www\.fatestaynightusa\.com\/1st\/assets\/img\/character\/)/.test(x.sourceUrl),
      '페이트 애니메이션 공식 장면 이외의 출처 ' + x.cardName);
    for (const old of [x.oldIcon,x.oldArt]) assert.ok(!paths.has('war3mapImported\\'+old));
    const a=x.artCrop, i=x.iconCrop;
    assert.ok(i[0]>=a[0] && i[1]>=a[1] && i[2]<=a[2] && i[3]<=a[3], '얼굴 아이콘이 큰 그림과 다른 영역을 사용함');
    assert.equal(a[2]-a[0],a[3]-a[1]);
    assert.equal(i[2]-i[0],i[3]-i[1]);
  }
}
// 실제 JASS Render를 모의 프레임에서 실행하여 목록과 큰 그림이 준비 중 표시로 빠지지 않는지 확인한다.
e.ExpUIOpen(e.EXP_UI_CARDS);
for (const x of index) {
  e.ProtoCharacterOwned[e.ExpKey(0, x.characterId)] = true;
  e.ProtoCardRevision[0]++;
  e.UIPrototypeCards_Selected = x.characterId;
  t.render();
  assert.equal(t.frame(e.UIPrototypeCards_GalleryArt).texture, 'war3mapImported\\' + x.art);
  assert.equal(t.visible(e.UIPrototypeCards_GalleryEmpty), false);
}
const missing = manifest.assets.find(x=>x.role==='portrait');
const invalidPaths = new Set([...paths].filter(x=>x!==missing.target));
assert.ok(index.some(x=>!invalidPaths.has('war3mapImported\\'+x.art)), '파일 누락 검출 음성 대조군');
assert.equal(rewards, index.reduce((n,x)=>n+x.rewardIds.length,0));
console.log(JSON.stringify({rewardDefinitions:rewards,cardPictures:index.length,endingPictures:sources.length,
  textureFiles:paths.size,checks:'catalog identity, grouped rewards, import coverage, mock gallery rendering, missing-file control',
  runtimeTested:false}));
