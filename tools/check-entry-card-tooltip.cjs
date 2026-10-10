// 머리 후보의 입문 카드 미리보기와 실제 지급, 로컬 입력 및 창 전환 경계를 검증한다.
const assert = require('node:assert/strict');
const fs = require('node:fs'), path = require('node:path');
const {fresh} = require('./check-expedition-ui.cjs');
const registry = fs.readFileSync(path.join(__dirname, '../Data/Data_PrototypeCardImages.j'), 'utf8');
const registrations = [...registry.matchAll(/call SetImages\((\d+), "([^"]+)", "([^"]+)"\)/g)];
let checks = 0, headsChecked = 0, placementChecks = 0;
const resolutions = [[1280, 960], [1600, 900], [2560, 1080]];
const plain = value => value.replace(/\|c[\da-f]{8}|\|r/gi, '');
function check(name, run) { run(); checks++; console.log('PASS ' + name); }
function setup() {
  const t = fresh(0, true);
  // 공통 mock은 비UI Init을 생략하므로 실제 등록문을 기존 카드 그림 검사와 같이 적용한다.
  for (const [,id,icon,art] of registrations) t.e.SetImages(Number(id), icon, art);
  t.start();
  t.entries = [];
  for (let head = 1; head <= t.e.PROTO_HEAD_COUNT; head++) {
    const event = Array.from({length:t.e.PROTO_EVENT_COUNT}, (_, i) => i + 1)
      .find(id => t.e.ProtoEventKind[id] === 0 && t.e.ProtoEventHead[id] === head);
    assert(event, '입문 사건이 없는 머리 ' + head);
    t.entries.push(event);
  }
  return t;
}
function offer(t, ids) {
  const e = t.e;
  e.ProtoStage[0] = 1;
  e.ProtoSelected[0] = 0;
  e.ProtoChoices[0] = ids.length;
  e.ExpOfferVersion[0]++;
  for (let slot = 1; slot <= 4; slot++) e.ProtoCandidates[e.ExpKey(0, slot)] = ids[slot - 1] || 0;
  e.ExpUIOpen(9);
  t.render();
}
const button = (t, slot) => t.e.ExpUIButtons[t.e.UIExpeditionPrototype_CandidateButtons[slot]];
const tooltip = t => t.frame(t.e.UIExpeditionPrototype_EntryTooltip);
const tooltipText = t => plain(t.frame(t.e.UIExpeditionPrototype_EntryTooltipText).text);
function enter(t, slot = 1, player = 0) { t.event(button(t, slot), 2, player); t.render(); }
function selected(t, slot) {
  return t.e.UIExpeditionCommon_ButtonSelected[t.e.UIExpeditionPrototype_CandidateButtons[slot]];
}
function hidden(t, slot = 1) {
  assert.equal(tooltip(t).shown, false, '이전 입문 카드 설명이 남음');
  assert.equal(t.e.UIExpeditionPrototype_HoverCandidate, 0, '이전 후보 호버가 남음');
  assert.equal(selected(t, slot), false, '이전 후보 강조가 남음');
}
function stats(e) { return Array.from({length:e.PROTO_STAT_LAST}, (_, i) => e.ProtoStatValues[i + 1]); }
function gameState(e) {
  return JSON.stringify({run:e.ExpRun, revision:e.ExpRevision, offer:e.ExpOfferVersion[0],
    stage:e.ProtoStage[0], chosen:e.ProtoSelected[0], ap:e.ProtoAP[0], gold:e.ExpGold[0],
    heads:e.ProtoHeadCount[0], cardRevision:e.ProtoCardRevision[0], stats:stats(e),
    candidates:Array.from({length:4}, (_, i) => e.ProtoCandidates[e.ExpKey(0, i + 1)]),
    rewards:Array.from({length:e.PROTO_CARD_LAST - e.PROTO_CARD_FIRST + 1}, (_, i) => e.ProtoRewardCopies[e.ExpKey(0, i + e.PROTO_CARD_FIRST)])});
}
// Mock의 TOPLEFT 상대 좌표를 화면 좌표로 풀어 화면 경계와 실제 프레임 겹침을 검사한다.
function rect(t, id) {
  const f = t.frame(id);
  const base = f.absolute || id === 0 ? {x:0, y:0} : rect(t, f.relative ?? f.parent);
  return {x:base.x + (f.x || 0), y:base.y + (f.y || 0), w:f.w || 0, h:f.h || 0};
}

check('모든 지역의 입문 카드 이미지와 보상 설명이 실제 지급 증분과 일치', () => {
  const t = setup(), e = t.e;
  assert.equal(t.entries.length, t.e.PROTO_HEAD_COUNT);
  for (const event of t.entries) {
    offer(t, [event]); enter(t);
    const card = e.ProtoHeadEntryCard[e.ProtoEventHead[event]];
    assert(t.visible(tooltip(t).id));
    const text = tooltipText(t);
    assert(text.includes(e.ProtoDisplayCardName(0, card)));
    assert(text.includes(e.ProtoCardEffectName[card]));
    assert(text.includes('새 카드'));
    assert.equal(text, plain(e.ProtoEventCardPreview(0, card)));
    assert.equal(t.frame(e.UIExpeditionPrototype_EntryTooltipIcon).texture, e.ProtoCardArt(card));
    assert(e.ProtoCardArt(card).endsWith('.tga'), '등록된 캐릭터 그림 대신 기본 아이콘 사용 ' + card);
    assert.equal(t.frame(e.UIExpeditionPrototype_EntryTooltipBorder).texture, e.ProtoCardFrame(e.ProtoCardGrade[card]));
    const before = stats(e);
    e.ProtoGrantEventCard(0, card);
    const after = stats(e);
    let effects = 0;
    for (let i = 0; i < after.length; i++) {
      const gain = after[i] - before[i];
      if (Math.abs(gain) > 1e-8) {
        assert(text.includes(e.ProtoEffectText(i + 1, gain)), '실제 지급 수치가 미리보기에 없음 ' + card);
        effects++;
      }
    }
    assert(effects > 0);
    headsChecked++;
  }
});

check('후보 1~4개와 세 화면 비율에서 팝업은 해당 후보와 겹치지 않고 아이콘 비율 유지', () => {
  const t = setup(), e = t.e;
  for (const [width, height] of resolutions) {
    e.windowWidth = width; e.windowHeight = height;
    for (let count = 1; count <= 4; count++) {
      offer(t, t.entries.slice(0, count));
      for (let slot = 1; slot <= count; slot++) {
        enter(t, slot);
        const tip = rect(t, tooltip(t).id), cover = rect(t, button(t, slot));
        assert(tip.x >= 0 && tip.x + tip.w <= .8 + 1e-9 && tip.y <= .6 + 1e-9 && tip.y - tip.h >= 0, '팝업 화면 이탈');
        assert(tip.x + tip.w <= cover.x || cover.x + cover.w <= tip.x || tip.y <= cover.y - cover.h || cover.y <= tip.y - tip.h, '팝업이 호버 후보를 덮음');
        const icon = t.frame(e.UIExpeditionPrototype_EntryTooltipIcon);
        assert(Math.abs(icon.w * width / .8 - icon.h * height / .6) < 1e-7, '정사각형 아이콘이 왜곡됨');
        assert.equal(tooltip(t).parent, e.UIExpeditionPrototype_EventRoot);
        assert.equal(tooltip(t).type, 'BACKDROP');
        for (const f of t.frames.values()) if (f.parent === tooltip(t).id) {
          if (f.type === 'TEXT') assert.equal(f.enabled, false, '툴팁 글자가 입력을 가로챔');
          else assert.equal(f.type, 'BACKDROP');
        }
        placementChecks++;
      }
    }
  }
});

check('호버는 로컬 표시만 바꾸며 진입·이탈 강조 및 다른 플레이어 입력을 구분', () => {
  const t = setup(), e = t.e;
  offer(t, t.entries.slice(0, 3));
  t.packets.length = 0; t.executions.length = 0;
  const before = gameState(e);
  enter(t, 1, 1); hidden(t);
  enter(t, 1);
  assert.equal(selected(t, 1), true);
  const backdrop = t.frame(e.UIExpeditionCommon_ButtonBackdrops[e.UIExpeditionPrototype_CandidateButtons[1]]);
  assert(backdrop.texture.endsWith('SheetHover.tga'));
  t.event(button(t, 1), 3, 1); t.render();
  assert(t.visible(tooltip(t).id), '원격 이탈이 로컬 팝업을 숨김');
  enter(t, 2);
  assert.equal(selected(t, 1), false); assert.equal(selected(t, 2), true);
  t.event(button(t, 1), 3); t.render();
  assert(t.visible(tooltip(t).id), '늦게 도착한 이전 후보 이탈이 현재 팝업을 숨김');
  t.event(button(t, 2), 3); hidden(t, 2);
  assert(backdrop.texture.endsWith('Sheet.tga'));
  assert.equal(gameState(e), before, '호버가 게임 상태를 변경함');
  assert.equal(t.packets.length, 0, '호버가 동기화 패킷을 전송함');
  assert.equal(t.executions.length, 0, '호버가 로컬 TriggerExecute를 실행함');
});

check('창 닫기·상태 변경·후보 교체와 재개방 때 이전 설명을 재사용하지 않음', () => {
  const changes = [
    ['닫기', e => e.ExpUIOpen(0)],
    ['능력치 이동', e => e.ExpUIOpen(e.EXP_UI_STATS)],
    ['결과 단계', e => { e.ProtoSelected[0] = e.ProtoCandidates[e.ExpKey(0, 1)]; e.ProtoStage[0] = 3; }],
    ['후보 버전', e => e.ExpOfferVersion[0]++],
    ['후보 ID', (e,t) => { e.ProtoCandidates[e.ExpKey(0, 1)] = t.entries[2]; }],
    ['새 런', e => e.ExpRun++],
    ['강화창', e => { e.F_UpgradeOnOff[0] = true; }],
    ['캐릭터 미선택', e => { e.PickCheck[0] = false; }],
    ['사냥 종료', e => { e.ExpPrototypeActive = false; }],
    ['참가 해제', e => { e.ExpMember[0] = false; }]
  ];
  for (const [name, change] of changes) {
    const t = setup(), e = t.e;
    offer(t, t.entries.slice(0, 3)); enter(t);
    assert(t.visible(tooltip(t).id));
    change(e, t); t.render(); hidden(t);
    e.PickCheck[0] = true; e.ExpPrototypeActive = true; e.ExpMember[0] = true; e.F_UpgradeOnOff[0] = false;
    offer(t, t.entries.slice(0, 3));
    assert.equal(tooltip(t).shown, false, name + ' 뒤 재개방에 이전 설명 표시');
  }
});

check('일반 사건에는 입문 카드 팝업을 띄우지 않고 실제 리롤도 기존 호버 해제', () => {
  const t = setup(), e = t.e;
  e.ProtoGrantHead(0, 1);
  const regular = Array.from({length:e.PROTO_EVENT_COUNT}, (_, i) => i + 1)
    .find(id => e.ProtoEventKind[id] !== 0 && e.ProtoEventEligible(0, id));
  assert(regular);
  offer(t, [regular]); enter(t);
  assert.equal(tooltip(t).shown, false);
  offer(t, t.entries.slice(1, 4)); enter(t);
  e.ExpGold[0] = 2000; t.render();
  const before = e.ExpOfferVersion[0];
  t.click(t.common(2300));
  assert(e.ExpOfferVersion[0] > before);
  hidden(t);
});

check('머리 후보 클릭은 호버 뒤에도 기존 동기화로 행동력 없이 카드 즉시 지급', () => {
  const t = setup(), e = t.e;
  offer(t, t.entries.slice(0, 3)); enter(t);
  const card = e.ProtoHeadEntryCard[1], ap = e.ProtoAP[0], before = e.ProtoHeadCount[0];
  t.packets.length = 0;
  t.event(button(t, 1), 4);
  assert.equal(t.packets.length, 1);
  assert.equal(t.packets[0].channel, 'ExpCmd');
  assert.equal(t.packets[0].data, `${e.ExpRun}|${e.ExpRevision}|${e.ExpOfferVersion[0]}|2101`);
  assert.equal(e.ProtoHeadCount[0], before, '동기화 수신 전에 지급됨');
  t.flush(); t.render();
  assert.equal(e.ProtoHeadCount[0], before + 1);
  assert.equal(e.ProtoAP[0], ap);
  assert(e.ProtoOwnsCharacter(0, card));
  assert.equal(e.ProtoRewardCopies[e.ExpKey(0, card)], 1);
  assert.equal(e.ProtoStage[0], 3);
  hidden(t);
});

check('이미 가진 입문 인물은 누적 합산 대신 이번 추가분과 보유 희귀도를 표시', () => {
  const t = setup(), e = t.e, card = e.ProtoHeadEntryCard[1];
  e.ProtoGrantEventCard(0, card); e.ProtoGrantEventCard(0, card);
  // 같은 인물의 다른 사건 보상까지 가진 상태에서도 입문 효과만 추가되어야 한다.
  const related = Array.from({length:e.PROTO_CARD_LAST - e.PROTO_CARD_FIRST + 1}, (_, i) => i + e.PROTO_CARD_FIRST)
    .find(id => id !== card && e.ProtoCardCharacter[id] === e.ProtoCardCharacter[card]);
  assert(related); e.ProtoGrantEventCard(0, related);
  e.ProtoCharacterGrade[e.ExpKey(0, e.ProtoCardCharacter[card])] = 3;
  offer(t, [t.entries[0]]); enter(t);
  const text = tooltipText(t);
  assert(text.includes('효과 추가'));
  assert(text.includes('이번에 추가'));
  assert(!text.includes('누적 보상') && !text.includes('선택한 보상의 합산 효과'));
  assert.equal(t.frame(e.UIExpeditionPrototype_EntryTooltipBorder).texture, e.ProtoCardFrame(3));
  assert(text.includes('[' + e.ExpEventGradeName(3) + ']'));
  const before = stats(e);
  e.ProtoGrantEventCard(0, card);
  const after = stats(e);
  for (let i = 0; i < after.length; i++) if (Math.abs(after[i] - before[i]) > 1e-8)
    assert(text.includes(e.ProtoEffectText(i + 1, after[i] - before[i])));
});

check('미샤의 대기 중 서사 변화는 최초 획득 추가분에만 표시되고 실제 지급과 일치', () => {
  const t = setup(), e = t.e;
  const event = t.entries.find(id => e.ProtoHeadKey[e.ProtoEventHead[id]] === 'penacony');
  const card = e.ProtoHeadEntryCard[e.ProtoEventHead[event]];
  assert.equal(e.ProtoCardKey[card], 'hsr_misha');
  const rule = e.ProtoStoryChangeForCharacter[e.ProtoCardCharacter[card]];
  const reveal = Array.from({length:e.PROTO_EVENT_COUNT}, (_, i) => i + 1)
    .find(id => e.ProtoStoryChangeFirst[id] === rule);
  assert(rule > 0 && reveal, '미샤 서사 변화 설정 누락');
  const before = stats(e);
  // 일반 진행 순서를 재현하는 검사가 아니라 지급 대기 상태의 미리보기 경계 검사다.
  e.ProtoUnlockStoryChanges(0, reveal);
  assert.deepEqual(stats(e), before, '미보유 미샤의 서사 보너스가 먼저 지급됨');
  offer(t, [event]); enter(t);
  const text = tooltipText(t);
  assert(text.includes(e.ProtoStoryChangeName[rule]));
  assert(text.includes('서사 변화 추가 효과 · 최초 획득 시'));
  assert.equal(text, plain(e.ProtoEventCardPreview(0, card)));
  e.ProtoGrantEventCard(0, card);
  const granted = stats(e);
  for (let i = 0; i < granted.length; i++) if (Math.abs(granted[i] - before[i]) > 1e-8)
    assert(text.includes(e.ProtoEffectText(i + 1, granted[i] - before[i])), '서사 효과를 포함한 실제 지급 증분 불일치');
  t.render();
  const next = tooltipText(t);
  assert(next.includes('효과 추가'));
  assert(!next.includes('서사 변화 추가 효과'), '이미 받은 서사 보너스를 다시 받는 것처럼 표시');
  e.ProtoGrantEventCard(0, card);
  const repeated = stats(e);
  for (let i = 0; i < repeated.length; i++) {
    assert(Math.abs(repeated[i] - granted[i] - e.LoadReal(e.ProtoEffectData, card, i + 1)) < 1e-8, '서사 보너스가 중복 지급됨');
    if (Math.abs(repeated[i] - granted[i]) > 1e-8)
      assert(next.includes(e.ProtoEffectText(i + 1, repeated[i] - granted[i])));
  }
});

console.log(JSON.stringify({checks, headsChecked, placementChecks, resolutions, runtimeTested:false}));
