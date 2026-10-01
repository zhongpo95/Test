// 나비저택 집필의 분기 뒤바뀜과 선결정·손으로 친 표주박·방향 조건 오류를 실제 데이터에 맞춘다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..'),read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/butterfly-expansion-fixed-73.json'),draft=read('drafts/butterfly-expansion-text-73.json').parsed,current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/13-butterfly.json'),'utf8'));
assert.deepEqual(draft.events.map(e=>e.key),fixed.events.map(e=>e.key));
const corrections=[];
for(const c of fixed.cards){if(c.key==='kny_kanao_return_hand'){const before=c.canonFact;c.canonFact=c.canonFact.replace('헤드/백 플래그가 있는 공격의 피해','헤드/백 플래그와 해당 위치의 유효 각도가 함께 맞아 실제 헤드·백 적중한 공격의 피해');corrections.push({key:c.key,field:'canonFact',before,after:c.canonFact,reason:'ExpeditionEffects의directional판정과AttackAngle의HeadTrue/BackTrue를 읽었다. 플래그만 있으면 적용된다는 요청73의 설명은 불완전해서 수치6/10과참조를 유지하고 조건만 고친다.'});}}
const events=fixed.events.map((p,i)=>{assert.equal(draft.events[i].choices.length,p.choices.length);return {key:p.key,title:p.title,story:draft.events[i].story,intro:draft.events[i].intro,previous:p.previous||null,previousChoice:p.previousChoice||0,requiredCard:null,choices:p.choices.map((b,j)=>({label:draft.events[i].choices[j].label,result:draft.events[i].choices[j].result,card:b.card,card2:b.card2,cost:b.cost,gold:b.gold,level:b.level,density:b.density,potions:b.potions,chance:b.chance})),failure:p.failure||null,canonFact:p.canonFact,uncertain:[]};});
const changes=[],edit=(o,k,v,key,reason)=>{if(o[k]===v)return;changes.push({key,field:k,before:o[k],after:v,reason});o[k]=v;};
const stories=[
 '표주박을 보고 네가 먼저 큰 것을 집자 아오이가 아직 설명을 끝내지 않았다고 손을 멈춘다. 탄지로가 자기 도구에 숨을 잇는 동안 너는 크기가 곧 실력이라는 말을 삼킨다. 아오이는 네가 불어 볼 도구를 내려놓고 설명부터 들을 것인지 묻는다.',
 '탄지로에게 아침 인사를 하려는데 그가 대답하다가 자기 호흡의 박자를 다시 잇는다. 하루 종일 유지하려는 연습이라고 듣고 나니 네 다음 질문이 입끝에 남는다. 탄지로는 질문도 듣겠다면서 그 말을 하는 동안에도 자기 숨의 길이를 다시 맞춘다.',
 '카나오와 손동작으로 반응을 맞추던 네가 끝났다고 생각한 순간에도 손은 앞으로 남아 있다. 카나오는 다음 차례를 준비하고 아오이는 손을 거둘 때도 훈련이라고 말한다. 네가 손을 당기는 사이 카나오는 다음 동작을 이미 기다리고 있다.',
 '이노스케가 가림막 뒤로 옮겨 간 네 위치를 가리키고는 이제 네가 맞혀 보라고 한다. 눈앞의 막만 보던 네가 발을 움직이자 이노스케도 다른 쪽으로 발판을 바꾼다. 먼저 막을 걷으려는 네 손을 보고 이노스케는 아직 승부가 끝난 게 아니라고 한다.',
 '첫 표주박 도전이 끝난 뒤 네가 도구를 내려놓으려는데 탄지로는 아직 숨을 잇고 있다. 아오이가 터진 소리만 세면 다음 박자를 놓친다고 네 손을 본다. 네가 첫 성공을 다시 말하려 하자 탄지로는 다음 숨은 언제 시작할 것인지 묻는다.'
];
const intros=['큰 도구를 골랐지만 설명은 아직 못 들었다.','질문은 남았고 탄지로의 연습도 계속되고 있다.','끝났다고 생각한 손은 아직 돌아오지 않았다.','눈앞의 막을 걷으면 승부도 끝나는 걸까?','첫 소리는 끝났지만 숨은 아직 이어진다.'];
const results=[
 ['도구값120골드를 먼저 내고 숨을 이어 표주박을 터뜨렸다. 그 기억으로 차지 공격 대미지14%와일반 행동속도3%가 늘었다. 네가 터진 소리를 자랑하려 하자 아오이는 다음에는 설명부터 끝까지 들으라고 한다.',
  '도구값220골드를 내고 탄지로의 박자를 따라 충분히 연습했다. 차지 공격 대미지14%와일반 행동속도3%가 늘었다. 아오이는 네가 큰 도구를 다시 집으려는지 작은 도구의 다음 숨을 잇는지 손부터 본다.',
  '표주박을 내려놓고 개인 사냥의 적 수 단계를1낮춘 뒤 물약1개를 받았다. 탄지로가 연습을 계속하자 아오이는 네가 내려놓은 도구를 옆에 두고 아직 듣지 않은 설명을 마친다.'],
 ['내 연습 도구에180골드를 내고 탄지로 옆에서 자기 숨을 이어 보았다. 초당 최대체력0.4%재생과현재체력65%이상에서 가하는 피해10%를 얻었다. 탄지로가 남은 질문을 다시 묻자 너도 대답할 말과 이어야 할 숨을 같이 고르게 된다.',
  '개인 사냥의 강함 단계를1올리는 부담을 맡고 끊긴 호흡의 박자를 다시 이었다. 초당 최대체력0.4%재생과현재체력65%이상에서 가하는 피해10%가 늘었다. 탄지로는 네 숨이 끊길 때마다 자기 박자도 다시 시작하며 남은 질문을 잊지 않는다.',
  '질문을 미루고 네가 맡은 짧은 일을 마쳐100골드를 받았다. 돌아오자 탄지로의 연습은 여전히 이어지고 네가 하지 않은 질문도 다시 입끝에 남는다.'],
 ['추가 연습 준비에200골드를 내고 같은 속도로 손을 다시 거두었다. 일반 행동속도6%와실제 헤드·백 적중 공격의 대미지10%가 늘었다. 아오이는 손을 내밀 때보다 거둘 때를 지켜보고 카나오는 그 손이 돌아온 다음 차례를 시작한다.',
  '개인 사냥의 적 수 단계를1올리는 부담을 맡고 손동작을 작게 줄여 다시 보았다. 치명타확률6%p와이동속도4%가 늘었다. 카나오가 동작을 바꾸자 너는 작은 움직임도 다시 거둬야 한다는 것을 손끝에서 확인한다.',
  '오늘 차례를 마치고 짧은 일의 보수100골드와물약1개를 챙겼다. 아오이가 도구를 정리하는 동안 카나오는 네 손이 남았던 자리를 비워 두고 다음 사람의 차례를 기다린다.'],
 ['내 연습 준비에180골드를 내고 가림막 너머 발판의 변화를 살폈다. 방어관통8%와헤드·백이 없는 비방향 공격 대미지12%가 늘었다. 네가 한쪽을 가리키자 이노스케는 방금 전과 다른 곳으로 다시 발을 옮긴다.',
  '개인 사냥의 적 수 단계를1올리는 부담을 맡고 눈에 안 보이는 움직임을 다시 살폈다. 방어관통8%와헤드·백이 없는 비방향 공격 대미지12%가 늘었다. 이노스케는 한 번 맞혔다고 끝내지 말라며 네가 가리킨 쪽에서 다시 움직인다.',
  '가림막 승부를 접고 개인 사냥의 적 수 단계를1낮춘 뒤90골드와물약1개를 챙겼다. 이노스케는 네가 보급을 든 손을 보더니 이번에는 그 짐을 든 채로 해 보라고 승부를 다시 꺼낸다.'],
 ['다음 연습 도구에140골드를 내고 터진 소리 뒤에도 숨을 이어 보았다. 차지 준비속도9%와차지 공격 대미지10%가 늘었다. 탄지로는 첫 성공을 다시 세는 대신 방금 잇기 시작한 숨이 어디까지 가는지 기다린다.',
  '개인 사냥의 강함 단계를1올리는 부담을 맡고 탄지로가 다음 빈틈을 보는 감각을 기억했다. 실제 헤드·백 적중 공격의 대미지14%와방어관통5%가 늘었다. 탄지로는 네가 성공한 쪽만 다시 보자 이번에는 다음 동작이 시작되는 쪽을 가리킨다.',
  '오늘 연습을 마치고 짧은 일의 보수100골드와물약2개를 챙겼다. 아오이는 터진 도구를 옮기며 내일 설명부터 들을 것인지 묻고 탄지로의 숨은 네가 대답한 뒤에도 이어진다.']
];
events.forEach((e,i)=>{edit(e,'story',stories[i],e.key,'선택 전220/180/200/140골드를 이미 내고 정답을 고른 서술을 제거하고 현재 물건·인사·손·가림막 문제로 되돌린다.');edit(e,'intro',intros[i],e.key,'반드시 완성해야 한다는 최선 강요 대신 아직 남은 문제를 쓴다.');e.choices.forEach((c,j)=>{let label=fixed.events[i].choices[j].action;if(i===0&&j===0)label='도구값120골드를 먼저 내고 숨을 불어 표주박을 터뜨려 본다';edit(c,'label',label,e.key+'#'+(j+1),'첫 사건의120/220분기 뒤바뀜을 실제 순서로 되돌리고 손으로 내리치는 표주박을 불어 보는 창작 시험으로 명시한다.');edit(c,'result',results[i][j],e.key+'#'+(j+1),'확률 성공을 실패로 쓴 오류·적 수를 난이도로 뭉갠 누락·물약 개수 누락·즉시회복/공포감지/동기화·반복 칭찬을 고치고 방향은 실제 헤드·백 적중으로 명시한다.');});});
const candidate={...current,sources:[...new Set([...current.sources,...fixed.sourceFacts.map(s=>s.source)])],cards:[...current.cards,...fixed.cards],events:[...current.events,...events]};
candidate.canonBoundary+=' 표주박 크기/시험·아침인사·손을거두는반응·가림막승부는공식훈련/감각소개에서만든별도창작방문이다. 표주박후속은자기60%도전성공1번에서만열리고확정2번/실패/타인기록은열지않는다. 실제미니게임·호흡/감지스킬·장비·동행·탄지로원작성취나카나오마음의결말을지급하지않는다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('requests/butterfly-expansion-fixed-74.json',fixed);write('revisions/butterfly-expansion-curated-74.json',candidate);write('revisions/butterfly-expansion-curation-74.json',{sourceRevision:'233aa7c',raw:'drafts/butterfly-expansion-text-73.json',changes,descriptionCorrections:corrections,numericExceptions:[],rewardReferenceCorrections:[],check});
const refs=[...new Set(events.flatMap(e=>e.choices.map(c=>c.card)).filter(Boolean))],cards=refs.map(key=>candidate.cards.find(c=>c.key===key));
write('requests/butterfly-expansion-review-74.json',{review:true,schema:read('requests/abydos-expansion-review-70.json').schema,system:'한국어 독립 검토자다. story/label/result를해당card/cost/gold/potions/level/density/chance와직접대조해실제불일치만issues에쓴다. PASS/REVISE와사유를쓴다. 새밸런스·원작성취·미구현기능을추가하지않는다. 자연스러운표현과영어key의단순차이를오류로분류하지않는다.',brief:{sourceFacts:fixed.sourceFacts,cards,events,mechanics:{cost:'사건진입AP1,cost선지불후chance%. 실패에도비용/AP/필드유지,카드/골드/물약없음.',field:'level강함,density적수지속변화량. 음수감소,최저1/강함최대5/수최대10. 사건중개인사냥정지.',reward:'성공때만카드/gold/potions,중복100골드. NPC성장아닌여행자기억. 현재체력비용/새AP/시간/도구장비/미니게임/동행/감지스킬없음.',history:'후속은자기첫표주박60%도전성공1번만. 확정2번/실패/타인기록안됨.',direction:'directional_damage는플래그만으로되지않고(head플래그와HeadTrue각도)또는(back플래그와BackTrue각도)의실제헤드/백적중공격에만적용. nondirectional_damage는head=false,back=false만.',charge:'charge_damage는차지태그공격피해,charge_speed는차지준비속도,action_speed는일반행동속도,move_speed는이동속도. 서로다름.',health:'regeneration은초당최대체력%재생/즉시회복아님. 흡수/재생합산10%초. healthy_damage는현재체력65%이상에서가하는피해.',crit:'crit_chance는확률%p. 모든공격확정치명아님.'},checks:['첫사건순서는120골드60%/220골드확정/적수감소+물약1과맞는가?','성공을실패로쓰거나NPC가성장/자동감지/표주박장비/호흡완성/동전마음해방을얻는가?','강함과적수·물약1/2·선지불·후속자기1번과일치하는가?','선택전대가를이미내거나최선정답을강요하는가?','칭찬/끄덕임보다다른행동과인물의작은반응이남는가?']}});
console.log(JSON.stringify({newCards:6,newRoots:4,newFollowups:1,changes:changes.length,descriptionCorrections:corrections.length,check}));
