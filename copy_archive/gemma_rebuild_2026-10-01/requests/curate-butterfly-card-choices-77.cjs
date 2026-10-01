// 나비저택의 세 카드 선택 집필을 기존 이야기와 실제 지급·부담에 맞춰 검토용으로 정리한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/butterfly-card-choices-fixed-76.json'),before=read('before-butterfly-card-choices-76.json');
const drafts=[1,2,3].flatMap(n=>read('drafts/butterfly-card-choices-text-76-'+n+'.json').parsed.events);
assert.deepEqual(drafts.map(e=>e.key),fixed.events.map(e=>e.key));
const results={
 'kny_night_path#1':'등불과 밧줄에160골드를 내고 소리를 따라 길을 잃은 보급꾼을 찾았다. 젠이츠의 한순간에 힘을 모으는 준비를 기억해 차지 공격과 치명타 피해를 높였지만, 내 사냥의 강함 단계는1올랐다. 보급꾼이 돌아갈 길을 묻자 젠이츠는 들어온 소리와 나갈 발소리를 다시 나누어 듣는다.',
 'kny_night_found#2':'짐을 나눌 도구에180골드를 내고 카나오가 먼저 비운 발자리를 따라 발을 옮겼다. 정확히 움직이는 준비를 기억해 이동속도와 치명타확률을 높이고, 내 사냥의 적 수 단계를1낮춘 뒤 물약2개를 받았다. 카나오는 짐을 놓은 자리보다 다음에 디딜 자리를 다시 비워 준다.',
 'kny_night_found#3':'짐 소리를 줄일 천에180골드를 내고 젠이츠와 움직일 순간을 맞췄다. 소리 사이의 한순간을 기억해 차지 준비속도와 보스에게 가하는 피해를 높였다. 젠이츠가 다시 귀를 기울일 때 네가 먼저 짐을 들어 소리를 내자, 그는 아직 움직일 때가 아니라고 손을 세운다.',
 'kny_night_wrong#3':'발판 확인 도구에180골드를 내고 이노스케와 보이지 않는 쪽의 움직임도 살폈다. 그 기억으로 방어관통과 헤드·백이 없는 공격의 피해를 높이고, 내 사냥의 적 수 단계를1낮춘 뒤 물약1개를 받았다. 이노스케는 빈 기록지의 같은 길보다 아직 밟지 않은 쪽을 가리킨다.',
 'kny_unread_bottles#3':'기록 대조 도구에260골드를 내고 시노부와 다음 상대에 맞춰 가져갈 준비를 구별했다. 상대를 먼저 살피는 기억으로 방어관통과 보스에게 가하는 피해를 높였다. 시노부는 끝내 읽히지 않은 병을 네 짐에서 빼고 다음 확인자에게 남겨 둔다.',
 'kny_white_linen#3':'길을 확인할 도구에180골드를 내고 이노스케와 보이지 않는 구간의 발판을 살폈다. 방어관통과 헤드·백이 없는 공격의 피해를 높이는 기억을 얻고, 내 사냥의 적 수 단계를1낮춘 뒤 물약1개를 받았다. 이노스케는 젖은 천을 들고도 발을 놓을 곳부터 보라며 다음 길목을 짚는다.',
 'kny_crow_dispatch#3':'반복할 준비에180골드를 내고 탄지로와 임무를 들은 뒤 움직일 차례까지 맞췄다. 꾸준히 되짚은 준비를 기억해 일반 행동속도와 보스에게 가하는 피해를 높였다. 까마귀가 안내를 다시 읽자 탄지로는 이번에는 네가 맡을 동작부터 기다린다.',
 'kny_midday_noise#3':'반응 연습 도구에200골드를 내고 젠이츠와 한 번 움직일 순간을 준비했다. 한순간에 힘을 모으는 기억으로 차지 공격과 치명타 피해를 높이고, 내 사냥의 적 수 단계를1낮춘 뒤 물약1개를 받았다. 짐 소리가 다시 겹쳐도 젠이츠는 네가 힘을 주려는 순간까지 손을 들어 기다린다.',
 'kny_mixed_traces#1':'조사 도구에140골드를 내고 탄지로와 서로 다른 흔적을 나누어 확인했다. 그 관찰을 기억해 실제 헤드·백 적중 공격의 피해와 방어관통을 높였지만, 내 사냥의 강함 단계는1올랐다. 탄지로는 한 방향으로 난 자국만 다시 보려는 네게 냄새가 갈라진 곳을 짚어 준다.',
 'kny_mixed_traces#3':'발판 확인 도구에180골드를 내고 이노스케와 자국이 끊긴 쪽도 살폈다. 보이지 않는 쪽을 놓치지 않는 기억으로 방어관통과 헤드·백이 없는 공격의 피해를 높이고, 내 사냥의 적 수 단계를1낮췄다. 이노스케가 다른 길로 발을 옮기자 너는 기록지의 같은 자국에만 표시하려던 손을 거둔다.',
 'kny_senior_challenge#3':'연습할 자리에180골드를 내고 탄지로와 먼저 인사한 뒤 각자 맡을 동작을 반복했다. 일반 행동속도와 보스에게 가하는 피해를 높이는 꾸준함을 기억하고, 내 사냥의 강함 단계를1낮춘 뒤 물약1개를 받았다. 무라타가 맡을 자리를 묻자 이노스케는 승부 이야기를 아직 접지 않은 채 그 옆을 돌아본다.',
 'kny_frightened_visitor#3':'이야기할 자리에180골드를 내고 탄지로와 말 사이에도 자기 숨을 고르며 손님에게 다음 말을 건넸다. 초당 최대체력0.4%재생과현재체력65%이상에서 가하는 피해10%를 얻고, 내 사냥의 적 수 단계를1낮췄다. 탄지로가 네 말을 기다리는 동안 너도 손님의 대답을 재촉하지 않는다.',
 'kny_first_gourd#2':'도구값220골드를 내고 탄지로와 한 번에 힘주기보다 자기 숨을 계속 잇는 연습을 했다. 그 기억으로 초당 최대체력0.4%재생과현재체력65%이상에서 가하는 피해10%를 얻었다. 아오이는 터진 소리를 세기보다 아직 설명하지 않은 다음 숨의 길이를 묻는다.',
 'kny_first_gourd#3':'반복할 자리에160골드를 내고 탄지로와 도구를 들고 거두는 차례부터 맞췄다. 일반 행동속도와 보스에게 가하는 피해를 높이는 꾸준함을 기억하고, 내 사냥의 적 수 단계를1낮춘 뒤 물약1개를 받았다. 아오이가 다음 도구를 건넬 때 너는 먼저 내려놓을 자리를 비운다.',
 'kny_morning_greeting#2':'내 사냥의 강함 단계를1올리는 부담을 맡고 탄지로가 다음 동작에서도 숨을 잇는 보폭을 따랐다. 끊기지 않는 호흡을 기억해 신속과현재체력65%이상에서 가하는 피해를 높였다. 탄지로가 아침 인사에 다시 답하자 너도 아직 남은 질문을 잊지 않는다.',
 'kny_morning_greeting#3':'연습할 자리에160골드를 내고 탄지로와 말한 뒤 움직일 차례까지 반복했다. 꾸준히 이어가는 기억으로 일반 행동속도와 보스에게 가하는 피해를 높였다. 질문이 끝났다고 손을 내리자 탄지로는 아직 남은 다음 동작을 가리킨다.',
 'kny_hand_return#3':'포장에180골드를 내고 아오이와 도구를 다시 묶어 다음 차례의 보급을 나눴다. 필요한 몫부터 챙기는 기억으로 초당 최대체력0.4%재생과이후처치당추가골드2를 얻고 물약1개를 받았다. 카나오는 네 손이 남아 있던 자리를 다음 사람에게 비워 둔다.',
 'kny_partition_role#2':'내 사냥의 적 수 단계를1올리는 부담을 맡고 이노스케처럼 막힌 쪽을 직접 열어 보았다. 일반몬스터에게 가하는 피해와 헤드·백이 없는 공격의 피해를 높이는 돌파를 기억한 대신 받는 피해도 늘어난다. 이노스케는 열린 길을 보더니 다음 막은 누가 맡을 것인지 묻는다.',
 'kny_partition_role#3':'길목 표식에160골드를 내고 이노스케와 돌아갈 보폭을 맞췄다. 먼저 발을 놓을 길을 살피는 기억으로 이동속도와 일반몬스터에게 가하는 피해를 높이고, 내 사냥의 적 수 단계를1낮춘 뒤 물약1개를 받았다. 이노스케는 방금 남긴 표식을 넘어가려다 네가 돌아올 자리를 다시 짚는 것을 본다.',
 'kny_after_first_gourd#3':'내 연습 도구에180골드를 내고 탄지로와 성공 뒤에도 자기 숨을 계속 이었다. 초당 최대체력0.4%재생과현재체력65%이상에서 가하는 피해10%를 얻고 물약2개를 받았다. 아오이는 터진 도구를 치우며 이번에는 설명이 끝나기 전에 네가 움직이는지 살핀다.'
};
const intros={kny_night_found:'돌아온 길은 확인했지만 다음에는 언제 발을 움직일까?',kny_crow_dispatch:'길게 읽은 안내 뒤에 아직 맡지 않은 준비가 남아 있다.',kny_senior_challenge:'선배의 몫과 승부, 인사 뒤의 반복은 서로 다른 준비가 된다.'};
const changes=[];
const events=fixed.events.map((e,i)=>{
 const old=before.events.find(x=>x.key===e.key),raw=drafts[i];assert.equal(raw.choices.length,3);
 const story=old.story,intro=intros[e.key]||old.intro;
 const choices=e.choices.map((c,j)=>{
  const tag=e.key+'#'+(j+1),previous=old.choices[j];
  const same=['card','card2','cost','gold','level','density','potions','chance'].every(k=>previous?.[k]===c[k]);
  assert(same||results[tag],tag+'의 변경된 보상 결과가 없음');
  const result=results[tag]||previous.result;
  for(const [field,value] of Object.entries({label:c.label,result}))if(raw.choices[j][field]!==value)changes.push({key:tag,field,before:raw.choices[j][field],after:value,reason:same?'기존 행동·보상이 같은 검토 완료 문장을 유지하고 불필요한 칭찬/새 인물/누락을 되돌린다.':'물약 소비를 지급으로, 보수 정리를 카드 기억으로 바꾸고 실제 비용·지속 강함/적 수·효과를 맞춘다.'});
  return {...c,result};
 });
 for(const [field,value] of Object.entries({story,intro}))if(raw[field]!==value)changes.push({key:e.key,field,before:raw[field],after:value,reason:'원래 현장 문제를 유지하고 사라진 보수 대안과 선택 전 결정·새 인물·칭찬 반복을 제거한다.'});
 return {...e,story,intro,choices};
});
const candidate={...before,events};
assert.deepEqual(candidate.cards,before.cards);assert.deepEqual(candidate.world,before.world);
for(const e of candidate.events){assert.equal(e.choices.length,3);assert.equal(new Set(e.choices.map(c=>c.card)).size,3);for(const c of e.choices)assert.equal(c.gold,0);}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('revisions/butterfly-card-choices-curated-77.json',candidate);
write('revisions/butterfly-card-choices-curation-77.json',{drafts:[1,2,3].map(n=>'drafts/butterfly-card-choices-text-76-'+n+'.json'),changes,policy:'사건 안의 세 행동이 서로 다른 지정 카드로 이어진다. 사건 후보2~4개/카드 수치/머리효과는 유지한다. 일반 즉시골드 대안은 제거하되 비용·나중 처치수급·중복보상은 별개다.',changedResults:Object.keys(results),check});
for(let start=0,batch=1;start<events.length;start+=6,batch++){
 const slice=events.slice(start,start+6),refs=[...new Set(slice.flatMap(e=>e.choices.map(c=>c.card)))];
 write('requests/butterfly-card-choices-review-77-'+batch+'.json',{review:true,schema:read('requests/abydos-expansion-review-70.json').schema,system:'한국어독립검토자다. 실제card/cost/gold/potions/level/density/chance와문장을대조해불일치만issues에쓴다. PASS/REVISE를판정한다. 실제명시된보상을누락했다고오독하거나변화량-1을최종값-1로읽지않는다. 정답강요·근거없는원작성취·NPC성장도검토한다.',brief:{sourceFacts:read('requests/butterfly-pitches-72.json').brief.sourceFacts,cards:candidate.cards.filter(c=>refs.includes(c.key)),events:slice,mechanics:{cost:'선택시cost선지불,확률실패에도비용/AP/필드변화유지',field:'level강함,density적수단계의지속변화량. 최종값은max(1,현재+변화량),강함상한5/적수상한10',reward:'성공때지정카드1장+potions개물약지급. 즉시gold=0. 카드kill_gold는이후처치때추가수급,이미가진카드는100골드중복보상(별개). 물약은소비가아님.',history:'kny_night_path성공1번->found,실패-1번->wrong. first_gourd성공1번만after_first_gourd. 개인기록만.',stats:'신속고정,crit_chance확률%p,action_speed일반행동,charge_speed준비속도,charge_damage차지태그피해,healthy현재HP65%이상,regen초당최대체력%/흡수합산10%상한/즉시회복아님,direction플래그+실제각도,nonDirection둘다false',boundary:'공식훈련/인물소개로만든별도창작방문. 미확인차승부/동전장면/원작큰결말/미니게임/장비/동행/감지스킬/현재체력비용없음.'},checks:['각사건3개서로다른카드와그효과/비용/필드/물약에맞는가?','예전골드보수·물약사용·사냥터단계를NPC근력으로쓰는오류가남았는가?','선택전현장문제가있고분기후그행동의결과가남는가?']}});
}
console.log(JSON.stringify({events:events.length,choices:51,changedResults:Object.keys(results).length,curationChanges:changes.length,directGoldChoices:0,check}));
