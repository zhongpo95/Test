// 선택 행동과 결과 문장의 인물·문제·남은 위험을 Gemma와 대조할 검토 요청을 보존한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'../../..');
const groups=[['01-fuyuki.json','02-axel.json'],['03-abydos.json','04-academy.json']];
const schema={type:'object',required:['findings'],additionalProperties:false,properties:{findings:{type:'array',maxItems:12,items:{type:'object',required:['key','choice','reason','replacement'],additionalProperties:false,properties:{key:{type:'string'},choice:{type:'integer',minimum:1,maximum:4},reason:{type:'string'},replacement:{type:'string'}}}}}};
const system='한국어 사건의 선택과 결과를 대조하는 편집자다. 실제 문제만 최대12개 찾는다. 다른 선택의 인물·행동을 결과에 붙였거나, 증가하는 위험을 없앴다고 쓰거나, 변화하지 않는 사냥터가 더 위험해졌다고 쓰거나, 표시되지 않은 신규 능력·회복·보수를 획득했다고 쓰는 문장을 찾아 고친다. 모든 선택이 즉시 문제를 해결할 필요는 없으며 조사와 준비도 결과다. 원작을 새로 추측하거나 캐릭터 능력을 플레이어에게 그대로 주지 않는다. 비용·카드·필드 수치를 바꾸지 않고 결과 문장만 고친다. 카드 능력치가 실재하고 NPC가 서사 안에서 능력을 쓰는 것은 플레이어 신규 스킬 부여가 아니다. 결과의 효력은 아래 주어진 보상과 위험만이다. 후속에서 다루는 문제를 첫 결과에서 완전히 없앴다고 쓰지 않는다. 레벨 증가는 강한 적을 앞으로 감수, 수 증가는 더 많은 적을 앞으로 감수, 감소는 그 길을 피하거나 통로를 줄이는 뜻이다. 수고비는 gold가 양수일 때 플레이어가 받으며 cost는 플레이어가 지출한다. 각 replacement는 선택 인물과 한 행동 및 남은 결과가 드러나는 한국어 1~2문장이다. 해석만 가능한 취향 지적과 숫자 밸런스 평가는 제외한다.';
for(let i=0;i<groups.length;i++){
 const ws=groups[i].map(f=>JSON.parse(fs.readFileSync(path.join(root,'content/roguelite',f),'utf8')));
 const brief={worlds:ws.map(w=>({name:w.world.name,canonBoundary:w.canonBoundary,facts:w.cards.map(c=>({name:c.name,fact:c.canonFact})),events:w.events.map(e=>({key:e.key,story:e.story,previous:e.previous,choices:e.choices.map(b=>({action:b.label,result:b.result,card:[b.card,b.card2].filter(Boolean).map(k=>{const c=w.cards.find(c=>c.key===k);return c?{name:c.name,role:c.effectName,effects:c.effects}:k}),cost:b.cost,gold:b.gold,potions:b.potions,level:b.level,density:b.density,chance:b.chance}))}))}))};
 fs.writeFileSync(path.join(__dirname,'semantic-audit-0'+(i+1)+'.json'),JSON.stringify({review:true,schema,system,brief},null,2)+'\n',{flag:'wx'});
}
console.log('후유키·액셀 및 아비도스·학원도시의 대조 요청을 보존했습니다.');
