// 학원도시 초안의 반응·대사 주체를 검토하고 고정 보상과 결합하여 역검토를 준비한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/academy-card-choices-fixed-91.json'),before=read('before-academy-card-choices-91.json'),raw=new Map();
for(let n=1;n<=4;n++){const d=read('drafts/academy-scenes-text-91-'+n+'.json');assert.equal(d.parseError,null);assert.deepEqual(d.parsed.events.map(e=>e.key),d.request.brief.events.map(e=>e.key));for(const [i,e]of d.parsed.events.entries()){assert.deepEqual(e.choices.map(c=>c.index),d.request.brief.events[i].choices.map(c=>c.index));for(const c of e.choices)raw.set(e.key+'#'+c.index,c);}}
const reactions={
 'academy_bad_signal#3':'사텐이 표식을 가리키자 우이하루는 아직 연락이 닿지 않은 집을 그 길과 다른 줄에 남긴다.',
 'academy_signal_answer#3':'토우마는 먼저 내보낼 사람을 짚고 미코토는 전원 확인이 끝나지 않은 쪽을 따로 가리킨다.',
 'academy_urban_rumor#3':'사텐은 마지막으로 들은 소문을 메모하되 확인한 표식 옆에는 아직 쓰지 않는다.',
 'academy_coin_test#3':'미코토는 작업자가 사선 밖으로 나간 것을 보고도 마지막 사람이 지날 방향부터 다시 확인한다.',
 'academy_second_route#2':'쿠로코는 닫은 통로보다 아직 남겨 둔 통로에 누가 있을 것인지 묻는다.',
 'academy_display_window#3':'미코토는 드러난 소품을 한 번 더 보려 하고 쿠로코는 비워 둔 길 끝에서 순찰 시간을 짚는다.',
 'academy_sweet_orders#3':'우이하루는 아직 확인되지 않은 주문 줄을 남기고 사텐은 그 줄의 짐을 다른 상자에 넣지 않는다.',
 'academy_pool_bundle#3':'완나이는 줄인 바깥 구역을 표시하고 아와츠키는 아직 균형이 맞지 않은 꾸러미를 따로 남긴다.',
 'academy_guts_corner#3':'군하가 먼저 든 짐의 도착지를 묻자 토우마는 방금 나눈 표시를 그 짐 앞으로 민다.',
 'academy_parade_markers#1':'쿠로코는 확인되지 않은 표식이 섞이지 않도록 옛 상자를 닫지 않은 채 옆에 둔다.',
 'academy_parade_markers#3':'사텐은 남긴 상자를 버릴 물건으로 표시하지 않고 내일 확인할 항목을 그 위에 적는다.',
 'academy_vending_left_coin#3':'미코토가 다시 자판기를 보자 토우마는 네가 가져갈 짐과 자기 손의 한 닢부터 따로 짚는다.',
 'academy_tea_after_call#3':'사텐은 남긴 찻잔을 가리키며 누구의 몫인지 묻고 쿠로코는 아직 돌아온 뒤의 대답까지 하지는 않는다.',
 'academy_unanswered_promise#3':'우이하루는 네가 줄인 항목을 표시한 뒤 쿠로코에게 아직 듣지 못한 대답을 다시 묻는다.',
 'academy_arcade_empty_seat#2':'테츠소는 버튼 위에 멈춘 손을 보다가 학생이 앉았던 빈 의자 쪽으로 시선을 돌린다.',
 'academy_arcade_empty_seat#3':'테츠소는 빈 의자가 다시 채워진 것처럼 말하지 않고 아까 끝내지 못한 게임 이야기를 잇는다.',
 'academy_festival_before_stage#3':'미코토는 네가 남긴 무대 차례를 보고 우이하루가 더 보고 싶다던 전시를 다시 가리킨다.',
 'academy_drink_after_vending#3':'토우마는 가져갈 보급부터 들고 미코토는 아직 열지 않은 음료를 그대로 손에 남긴다.'
};
const changes=[];
const events=fixed.events.map(e=>({...e,choices:e.choices.map((c,j)=>{
 const key=e.key+'#'+(j+1),draft=raw.get(key);if(!draft)return {...c};assert(reactions[key]);
 const planned=fixed.changes.find(x=>x.key===e.key&&x.index===j+1),memory=fixed.cards.find(x=>x.key===c.card);assert(planned&&memory);
 const action=planned.action.replace(/한다$/,'했다').replace(/남긴다$/,'남겼다').replace(/센다$/,'셌다').replace(/듣는다$/,'들었다').replace(/기다린다$/,'기다렸다').replace(/맞춘다$/,'맞췄다').replace(/펼친다$/,'펼쳤다').replace(/나눈다$/,'나눴다').replace(/둔다$/,'두었다'),parts=[];if(c.cost)parts.push(c.cost+'골드를 지불했다.');parts.push('「'+memory.effectName+'」의 기억 카드1장을 얻었다.');
 if(c.level>0)parts.push('내 사냥의 몬스터 강함 단계가'+c.level+'올랐다.');if(c.level<0)parts.push('내 사냥의 몬스터 강함 단계를 최저1범위에서'+(-c.level)+'낮췄다.');
 if(c.density>0)parts.push('내 사냥의 적 수 단계가'+c.density+'올랐다.');if(c.density<0)parts.push('내 사냥의 적 수 단계를 최저1범위에서'+(-c.density)+'낮췄다.');if(c.potions)parts.push('물약'+c.potions+'개를 받았다.');
 const result=action+'. '+parts.join(' ')+' '+reactions[key];
 changes.push({key,rawAction:draft.actionText,rawReaction:draft.reactionText,after:result,reason:'여행자 행동의 완료형과 원래 대사 주체·남은 문제를 맞췄다. 미소/끄덕임·미확인표식버림오독·말없이앞보는쿠로코를대답못받은인물로바꾼오독·학생복귀/비법시연확정은 제외한다.'});return {...c,result};
}),failure:e.failure?e.failure.replace('카드와 기록 확인 보수도 받지 못한다.','카드는 받지 못한다.'):null}));
const candidate={...before,cards:fixed.cards,events};assert.equal(changes.length,18);assert.deepEqual(candidate.world,before.world);
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('revisions/academy-card-choices-curated-92.json',candidate);
write('revisions/academy-card-choices-curation-92.json',{rawDrafts:[1,2,3,4].map(n=>'drafts/academy-scenes-text-91-'+n+'.json'),changes,removedChoices:fixed.removedChoices,newCards:fixed.addedCards,failureCorrection:{event:'academy_parade_markers',before:before.events.find(e=>e.key==='academy_parade_markers').failure,after:candidate.events.find(e=>e.key==='academy_parade_markers').failure},unchanged:'기존21카드·머리효과·세 자기 후속번호를 유지한다. 고정91의 비용·필드·물약·확률과 세 기억을 대조한다.',revisit:'행동 주체·원래 인물 관계·남은 현장 문제와 실제 보상이 함께 맞아야 한다. 원작 결말·새 기술·NPC 성장을 만들지 않는다.',check});
for(let start=0,batch=1;start<events.length;start+=6,batch++){
 const slice=events.slice(start,start+6),refs=new Set(slice.flatMap(e=>e.choices.map(c=>c.card)));
 write('requests/academy-card-choices-review-92-'+batch+'.json',{review:true,schema:read('requests/abydos-expansion-review-70.json').schema,system:'한국어 독립 검토자다. 실제 데이터와 글의 불일치만 issues에 쓴다. 몬스터강함/적수는 지속 단계 변화량이며 캐릭터 레벨이 아니다. UI가 정확한 카드 이름·능력치를 덧붙인다. 새로운 기능이나 밸런스를 제안하지 않는다.',brief:{cards:candidate.cards.filter(c=>refs.has(c.key)),events:slice,mechanics:{reward:'성공때 지정카드1장과potions개물약 지급. 즉시골드0. 처치골드능력치와중복100골드는별개다. result는성공만이다.',cost:'cost선지불.실패때비용/AP/필드는유지되고카드/물약지급없음.',field:'level몬스터강함,density몬스터수 단계의 변화량. 초기1/4,최저1,상한5/10. 플레이어능력·피로·시간아님.',history:fixed.policy.history,stats:'기억은여행자성장. move3은3%. regen시간회복/흡수합산10%상한,즉시회복아님. maxHP현재/최대비율유지. healthy65%이상. 비방향은헤드/백플래그없는공격이며공간이동/새보호막없음.',boundary:candidate.canonBoundary},checks:['모든사건서로다른지정카드3종이며직접골드대안/부모카드반복없는가?','비용·물약·필드·확률·실패와문장일치하는가?','장면의대사주체·남은문제와원래공식역할을따르며갈등완화/학생복귀/자판기돈반환/큰범죄/연주결과확정없는가?']}});
}
console.log(JSON.stringify({events:18,choices:54,newCards:8,changedResults:18,check}));
