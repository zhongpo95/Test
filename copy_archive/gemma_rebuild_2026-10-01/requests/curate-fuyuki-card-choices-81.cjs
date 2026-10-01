// 후유키 재집필의 누락·혼동을 고정 보상과 현장 행동에 맞추고 세 카드 검토안을 정리한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/fuyuki-card-choices-fixed-79.json'),before=read('before-fuyuki-card-choices-79.json');
const drafts=[1,2,3,4].map(n=>read('drafts/fuyuki-card-choices-text-80-'+n+'.json'));
const rawEvents=drafts.flatMap(d=>d.parsed.events),requests=drafts.flatMap(d=>d.request.brief.events);
assert.deepEqual(rawEvents.map(e=>e.key),requests.map(e=>e.key));
const raw=new Map();
for(const [i,e]of rawEvents.entries()){
 assert.deepEqual(e.choices.map(c=>c.index),requests[i].choices.map(c=>c.index));
 for(const c of e.choices){assert(!/ReplaceCard|\{\s*"|card2/.test(c.result));raw.set(e.key+'#'+c.index,c);}
}
const scenes={
 'school_circle#2':['시로와 학생들을 밖으로 안내하기 전에 막힌 문의 구조를 하나씩 확인했다.','시로가 문을 붙잡는 동안 네가 먼저 바깥으로 보낼 사람을 부른다.'],
 'school_circle#3':['린과 학생을 내보낼 순서를 다른 줄에 적어 대피 통로를 나눴다.','린은 기록지의 마지막 이름까지 확인한 뒤 아직 복도 안에 남은 쪽을 가리킨다.'],
 'school_circle_trace#3':['린과 남은 흔적을 나눠 적고 같은 곳을 다시 확인할 차례부터 맞췄다.','린은 확인하지 않은 줄을 네 기록으로 채우지 않고 다음에 물을 항목으로 남긴다.'],
 'temple_gate#3':['세이버와 돌아갈 길에 표식을 놓고 서로 발을 둘 간격을 나눴다.','세이버는 산문을 넘은 것처럼 서두르지 말라며 네가 뒤로 뺀 발부터 본다.'],
 'fy_club_inventory#2':['시로와 부실 밖 길목의 문과 보관할 자리를 하나씩 확인했다.','시로가 상자의 주인을 다시 묻자 너도 확인한 길과 아직 묻지 않은 사람을 나눠 적는다.'],
 'fy_club_inventory#3':['시로와 이름 없는 상자의 포장을 나누고 주인이 올 때까지 맡을 몫을 정했다.','타이가는 그 상자에 아무 이름이나 쓰지 않고 네가 맡을 몫만 따로 표시한다.'],
 'fy_regular_contact#3':['시로와 답 없는 곳에 다시 연락할 일을 나누고 이미 끝난 일과 다른 줄에 적었다.','린은 네가 맡은 항목을 지우는 대신 누구에게 다시 물을지 옆에 남긴다.'],
 'fy_shinji_offer#1':['연락 비용을 내고 더 넓은 길목에서 제안과 맞는 자료를 찾아 린과 빈틈을 짚었다.','신지가 답을 재촉하자 린은 확인한 문장과 아직 빠진 조건을 따로 펼친다.'],
 'fy_shinji_offer#3':['시로와 제안에 답하기 전에 확인할 일을 나눴다.','신지는 협력할 것이냐고 다시 묻지만 시로는 아직 확인하지 않은 조건부터 남긴다.'],
 'fy_pause_outside#3':['시로와 가까운 길의 준비를 나누고 멀리 갈 몫은 다른 사람에게 남겼다.','세이버가 둘러볼 길을 묻자 시로는 네가 맡은 가까운 쪽부터 다시 가리킨다.'],
 'fy_teacher_statement#1':['더 넓은 길목에서 빠진 시각과 장소를 찾고 린과 직접 본 말의 순서를 맞췄다.','린은 교사의 이름 아래에 결론을 쓰려던 네 손을 멈추고 아직 듣기만 한 줄을 짚는다.'],
 'fy_teacher_statement#2':['시로와 진술에 나온 길을 직접 보며 문의 구조와 지나갈 자리를 기록에 맞췄다.','시로는 들은 말까지 같은 표시로 채우지 않고 아직 묻지 않은 자리를 남긴다.'],
 'fy_teacher_statement#3':['시로와 확인되지 않은 일을 남겨 두고 다음에 직접 물을 몫을 나눴다.','린이 빈 줄을 다시 보자 시로는 같은 학교의 사람이라는 이유로 그 줄을 채우지 않는다.'],
 'fy_two_ideals#3':['시로와 다음에 맡을 보급을 나누되 둘의 주장은 다른 줄에 남겼다.','아처가 감당할 몫을 다시 묻자 시로도 네가 맡지 않은 사람의 이름을 지우지 않는다.'],
 'fy_lancer_crossing#3':['세이버와 물러선 자리에서 검끝이 지나갈 간격을 다시 살폈다.','랜서가 창을 고쳐 쥐자 세이버는 이번에는 빈 쪽보다 네 검이 돌아올 쪽을 보라고 한다.'],
 'fy_arrow_on_floor#2':['시로가 건넨 화살을 받기 전에 내 손과 도구가 닿는 순서를 먼저 살폈다.','타이가는 다음 표적보다 네가 아직 받지 않은 화살부터 보라고 한다.'],
 'fy_arrow_on_floor#3':['타이가와 준비 목록을 나눠 적고 아직 손에 받지 않은 물건부터 확인했다.','타이가는 화살을 받았는지 묻고 시로는 네가 비워 둔 손 앞으로 그것을 다시 놓는다.'],
 'fy_shelter_question#3':['린과 보호의 말에서 빠진 범위를 자료에 나눠 적고 다음 위험에 맞춰 준비했다.','키레이가 아직 답을 기다리자 린은 교회 밖의 네 사냥까지 약속한 말은 없다고 자료를 돌려 준다.'],
 'fy_after_one_block#3':['아처와 다음 큰 상대를 관찰할 위치를 나누고 되돌아설 순간을 다시 짚었다.','랜서가 창을 돌리자 아처는 막았던 손보다 아직 시작하지 않은 다음 움직임을 본다.'],
 'fy_next_arrow_wait#2':['시로가 건넨 화살을 받을 차례부터 다시 맞추며 내 손과 도구의 순서를 살폈다.','타이가는 네 눈이 표적을 떠난 뒤에도 다음 화살을 받을 손은 놓치지 말라고 한다.']
};
const changes=[];
const events=fixed.events.map(e=>{
 const old=before.events.find(x=>x.key===e.key);
 return {...e,choices:e.choices.map((c,j)=>{
  const key=e.key+'#'+(j+1),d=raw.get(key);if(!d)return {...c};
  assert.equal(d.label,c.label);assert(scenes[key]);
  const memory=fixed.cards.find(k=>k.key===c.card),parts=[];
  if(c.cost)parts.push(c.cost+'골드를 지불했다.');
  parts.push('「'+memory.effectName+'」의 기억 카드1장을 얻었다.');
  if(c.level>0)parts.push('내 사냥의 몬스터 강함 단계는'+c.level+'올랐다.');
  if(c.level<0)parts.push('내 사냥의 몬스터 강함 단계를 최저1범위에서'+(-c.level)+'낮췄다.');
  if(c.density>0)parts.push('내 사냥의 적 수 단계는'+c.density+'올랐다.');
  if(c.density<0)parts.push('내 사냥의 적 수 단계를 최저1범위에서'+(-c.density)+'낮췄다.');
  if(c.potions)parts.push('물약'+c.potions+'개를 받았다.');
  const result=scenes[key][0]+' '+parts.join(' ')+' '+scenes[key][1];
  changes.push({key,field:'result',before:d.result,after:result,reason:'심리적압박/정보량/추가행동력으로바꾼필드부담과물약지급누락·반복칭찬·잘못된아처카드수치를고치고실제기억카드와현장반응을분리한다.'});
  return {...c,result};
 }),failure:e.failure?e.failure.replace('카드와 자료 보수는 받지 못한다.','카드는 받지 못한다.').replace('확인 보수와 카드는 받지 못하며','카드는 받지 못하며'):null};
});
const candidate={...before,cards:fixed.cards,events};
assert.equal(changes.length,20);assert.deepEqual(candidate.world,before.world);
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('revisions/fuyuki-card-choices-curated-81.json',candidate);
write('revisions/fuyuki-card-choices-curation-81.json',{rawDrafts:[1,2,3,4].map(n=>'drafts/fuyuki-card-choices-text-80-'+n+'.json'),rejectedEarlier:['drafts/fuyuki-card-choices-text-79-1.json','drafts/fuyuki-card-choices-text-79-2.json'],changes,removedChoices:before.events.filter(e=>e.choices.length>3).map(e=>({key:e.key,choices:e.choices.slice(3)})),newCards:fixed.addedCards,unchangedMechanics:'수정79에고정한카드·비용·확률·필드·물약값을유지한다. 기존카드21장효과와머리효과는변경없다. 후속번호1번은유지한다.',check});
for(let start=0,batch=1;start<events.length;start+=6,batch++){
 const slice=events.slice(start,start+6),refs=new Set(slice.flatMap(e=>e.choices.map(c=>c.card)));
 write('requests/fuyuki-card-choices-review-81-'+batch+'.json',{review:true,schema:read('requests/abydos-expansion-review-70.json').schema,system:'한국어독립검토자다. 데이터와문장을직접대조해실제불일치만issues에쓴다. 초기적수4/강함1이고level/density는변화량이다. UI가카드이름과정확한효과를덧붙인다. 새조건/새밸런스를제안하거나감소를불가능하다고가정하지않는다.',brief:{cards:candidate.cards.filter(c=>refs.has(c.key)),events:slice,mechanics:{reward:'성공때지정카드1장과물약potions개지급. 즉시골드0. 이름/등급/정확한효과는ProtoGrantEventCard가결과에덧붙인다. 중복100골드와이후처치골드는별개다.',cost:'cost선지불,실패때도비용/AP/필드변화유지. result는성공일때만. 실패때카드/물약없음.',field:'초기몬스터강함1/적수4. level/density는변화량. max(1,현재+변화량),상한5/10. level플레이어레벨아님,강한몬스터부담이다. UI에최저1과실제전후값표시.',history:'school_circle자기성공1번만trace,fy_arrow_on_floor자기성공1번만next_arrow_wait. 후속전용interval카드는부모에지급하지않음.',stats:'attack_percent공격력%,action_speed일반행동속도,swift고정신속,DR받는피해감소,방향피해는플래그+각도,보호막피해는기존보호막조건/새보호막지급아님,regen시간회복/현재체력즉시회복아님',boundary:'기존canonFact/공식역할에서별도창작한다. 새NPC/스킬/장비/동행/무적/현재체력비용/본편큰결말/시로이상정답완성없음.'},checks:['모든사건서로다른카드3종,입문card반복없음,골드대안없음인가?','표시한기억과기본효과/비용/필드/물약/후속이맞는가?','원래현장문제에서행동과작은반응이이어지는가?']}});
}
console.log(JSON.stringify({events:16,choices:48,newCards:2,changes:changes.length,check}));
