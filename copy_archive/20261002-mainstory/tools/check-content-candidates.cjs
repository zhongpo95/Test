// 사건·카드 초안의 참조, 단위, 무효 선택과 후속 연결을 실행 데이터 반영 전에 검사한다.
'use strict';
const fs = require('node:fs');
const stats = new Set(['attack_percent','damage_percent','final_damage_percent','boss_damage_percent','normal_damage_percent','crit_chance','crit_damage','swift','action_speed','move_speed','charge_speed','penetration','max_health_percent','damage_reduction','leech','regeneration','kill_gold','event_choices','moving_damage','directional_damage','nondirectional_damage','shielded_damage','charge_damage','healthy_damage','action_capacity']);

function inspect(input) {
  const data = input.parsed || input;
  const errors = [], warnings = [];
  const fail = (key, reason) => errors.push({key, reason});
  if (!Array.isArray(data.cards) || !Array.isArray(data.events)) return {errors:[{key:'root',reason:'cards와 events 배열이 필요함'}],warnings};
  const cards = new Map(), events = new Map();
  function index(list, target, kind) {
    for (const item of list) {
      if (!item || !/^[a-z][a-z0-9_]*$/.test(item.key || '')) {fail(kind,'유효한 영어 key가 없음');continue;}
      if (target.has(item.key)) fail(item.key,'중복 key');
      target.set(item.key,item);
    }
  }
  index(data.cards,cards,'cards'); index(data.events,events,'events');
  if (!data.world || !/^[a-z][a-z0-9_]*$/.test(data.world.key || '') || !data.world.name || !data.world.work) fail('world','작품의 key·이름·원작이 필요함');
  if (data.world?.key!=='common' && !cards.has(data.world?.entryCard)) fail('world','지역 입문 카드 참조 없음');
  const seen = new Set();
  function effects(key, list) {
    if (!Array.isArray(list)) {fail(key,'effects 배열이 없음');return;}
    const used = new Set();
    for (const effect of list) {
      if (!effect || typeof effect!=='object') {fail(key,'효과 객체가 아님');continue;}
      if (used.has(effect.stat)) fail(key,'같은 스탯을 한 효과 목록에 중복 정의함');
      used.add(effect.stat);
      if (!stats.has(effect.stat) || !Number.isFinite(effect.value)) fail(key,'허용되지 않은 스탯 또는 비정상 수치');
      if (['regeneration','leech','kill_gold','event_choices'].includes(effect.stat) && effect.value < 0) fail(key,'음수로 구현하지 않는 수급·회복 스탯');
      if (effect.stat==='regeneration' && effect.value>1) warnings.push({key,reason:'카드 하나의 초당 재생이 최대체력 1%를 넘음. 별도 밸런스 검토 필요'});
      if (effect.stat==='swift' && effect.value!==0 && Math.abs(effect.value)<45) warnings.push({key,reason:'신속은 고정 수치다. '+effect.value+'는 행동 속도 '+(effect.value/45).toFixed(3)+'%, 쿨타임 감소 '+(effect.value/46).toFixed(3)+'%p에 해당하므로 단위와 선택 가치를 재검토해야 함'});
      if (effect.stat==='event_choices' && !Number.isInteger(effect.value)) fail(key,'사건 후보 증가는 정수여야 함');
      if (effect.stat==='action_capacity' && (!Number.isInteger(effect.value) || effect.value<0)) fail(key,'행동력 최대치 증가는 음수가 아닌 정수여야 함');
    }
  }
  effects('world',data.world?.effects || [data.world?.bonus]);
  for (const [key, card] of cards) {
    if (!card.name || !card.effectName || !card.keyword || !Number.isInteger(card.grade) || card.grade<1 || card.grade>4 || card.choices) fail(key,'카드 필수 필드 누락 또는 사건 객체가 cards에 들어감');
    effects(key,card.effects);
    if (!card.evolution || ![0,1,2,3].includes(card.evolution.kind)) {fail(key,'각성 kind는 없음·처치·실제피해·연속무피격 중 하나여야 함');continue;}
    effects(key,card.evolution.effects);
    if (card.evolution.kind===0 && (card.evolution.goal!==0 || card.evolution.effects?.length)) fail(key,'각성 없음인데 목표 또는 효과가 존재함');
    if (card.evolution.kind>0 && (!Number.isFinite(card.evolution.goal) || !(card.evolution.goal>0) || !card.evolution.effects?.length)) fail(key,'각성 목표와 추가 효과가 필요함');
  }
  for (const [key,event] of events) {
    if (!event.title || !event.story || !event.intro || event.effects) fail(key,'사건 필수 필드 누락 또는 카드 객체가 events에 들어감');
    if (event.actionCost!==undefined && ![0,1].includes(event.actionCost)) fail(key,'사건 행동력 비용은 0 또는 1이어야 함');
    if (!Array.isArray(event.choices) || event.choices.length<2 || event.choices.length>4) {fail(key,'선택지는 2~4개여야 함');continue;}
    if (event.requiredCard && !cards.has(event.requiredCard)) fail(key,'requiredCard 참조 없음');
    if (event.previous) {
      const previous=events.get(event.previous);
      if (!previous || previous.key===key || !Number.isInteger(event.previousChoice) || !event.previousChoice || Math.abs(event.previousChoice)>previous.choices?.length) fail(key,'이전 사건·선택 참조 오류');
      else if (event.previousChoice<0 && previous.choices[-event.previousChoice-1]?.chance===100) fail(key,'반드시 성공하는 선택의 실패 후속 사건');
    }
    event.choices.forEach((choice,i)=>{
      const tag=key+'#'+(i+1);
      if (!choice || typeof choice!=='object') {fail(tag,'선택 객체가 아님');return;}
      if (!choice.label || !choice.result) fail(tag,'행동과 결과 문장이 필요함');
      for (const field of ['gold','cost','level','density','potions','chance']) {
        if (!Number.isInteger(choice[field])) fail(tag,field+'는 정수여야 함');
      }
      if (choice.cost<0 || choice.potions<0 || choice.gold<0 || choice.chance<1 || choice.chance>100) fail(tag,'비용·보상·성공률 범위 오류');
      if (choice.potions!==0) fail(tag,'사건에서 물약을 보상으로 지급하지 않음');
      if (choice.health || choice.healthCost || choice.hpCost) fail(tag,'현재 체력 지불·회복은 사건 보상 필드에서 사용하지 않음');
      for (const field of ['card','card2']) if (choice[field]) {
        if (!cards.has(choice[field])) fail(tag,field+' 참조 없음');
        else seen.add(choice[field]);
      }
      if (!choice.card && !choice.card2 && !choice.gold && !choice.potions && !choice.level && !choice.density && !data.events.some(next=>next.previous===key && Math.abs(next.previousChoice)===i+1)) fail(tag,'이득·필드 개입·후속 사건이 모두 없는 선택');
      if (choice.chance<100 && !event.failure) fail(tag,'확률 실패의 결과 설명이 없음');
      if (choice.card && choice.card===choice.card2) fail(tag,'같은 카드를 한 선택에서 두 번 지급함');
      if (/구매|지불/.test(choice.label) && !choice.cost) warnings.push({key:tag,reason:'구매·지불이라고 설명하지만 골드 비용이 0임'});
    });
    const path=new Set([key]);let parent=event.previous;
    while(parent && events.has(parent)) {
      if(path.has(parent)) {fail(key,'후속 사건에 순환 참조가 있음');break;}
      path.add(parent);parent=events.get(parent).previous;
    }
  }
  for (const key of cards.keys()) if (!seen.has(key) && data.world?.entryCard!==key) fail(key,'지급 사건이나 입장 카드 참조가 없음');
  return {cards:cards.size,events:events.size,errors,warnings};
}
if (require.main===module) {
  const file=process.argv[2];
  if (!file) throw new Error('검사할 JSON 경로가 필요합니다.');
  const result=inspect(JSON.parse(fs.readFileSync(file,'utf8').replace(/^\uFEFF/,'')));
  console.log(JSON.stringify(result,null,2));
  if (result.errors.length) process.exitCode=1;
}
module.exports={inspect};
