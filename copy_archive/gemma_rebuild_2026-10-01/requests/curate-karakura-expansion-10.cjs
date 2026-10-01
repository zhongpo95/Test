// 카라쿠라 사건 문장을 개인 필드 손익과 연결하고 바느질 카드의 겹친 효과를 조정한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/karakura-expansion-fixed-09.json'),'utf8'));
const draft=JSON.parse(fs.readFileSync(path.join(root,'drafts/karakura-expansion-text-09.json'),'utf8')).parsed;
const current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/10-karakura.json'),'utf8'));
assert.deepEqual(draft.events.map(e=>e.key),fixed.events.map(e=>e.key));
const changes=[];function edit(obj,field,value,key,reason){changes.push({key,field,before:obj[field],after:value,reason});obj[field]=value;}
const cards=structuredClone(fixed.cards);
edit(cards[0],'effects',[{stat:'charge_speed',value:6},{stat:'crit_damage',value:15}],cards[0].key,'원안 행동3·치명피해15는 기존 레어 어새신 행동3·치명피해25보다 같은 축에서 모두 약하다. 세밀한 손 준비를 차지속도6·치명피해15로 구분해 캐릭터의 차지 사용에 따라 선택 가치가 달라지게 한다.');
edit(cards[0],'keyword','차지 속도 · 치명타 피해',cards[0].key,'새 능력치 종류를 실제 단위에 맞춘다.');
const events=fixed.events.map((p,i)=>{assert.equal(draft.events[i].choices.length,p.choices.length);return {key:p.key,title:p.title,story:draft.events[i].story,intro:draft.events[i].intro,previous:null,previousChoice:0,requiredCard:null,choices:p.choices.map((b,j)=>({label:draft.events[i].choices[j].label,result:draft.events[i].choices[j].result,card:b.card,card2:b.card2,gold:b.gold,cost:b.cost,level:b.level,density:b.density,potions:b.potions,chance:b.chance})),failure:p.failure,canonFact:p.canonFact,uncertain:[]};});
const e=k=>events.find(x=>x.key===k);function scene(key,intro,rs){const x=e(key);edit(x,'intro',intro,key,'대화형 정해줘 요청과 완전한 해결 요구를 덜고 맡을 일을 안내한다.');rs.forEach((r,i)=>edit(x.choices[i],'result',r,key+'#'+(i+1),'비용·지정 카드·보수 제공자·개인 사냥 변화를 연결한다. 근거 없는 기능과 모든 부탁의 해결을 약속하지 않는다.'));}
scene('bl_ripped_sleeve','소매를 준비할지, 바깥 길목을 살필지 정한다.',[
 '천과 실 값을 내고 우류와 팔이 걸리지 않을 여유를 남겼다. 한 땀을 서두르기보다 힘을 모아 정확히 잇는 준비를 배웠다. 콘의 실타래는 풀었지만 바깥 길목 확인은 남았다.',
 '우류와 넓은 길목을 먼저 살피며 어느 곳을 겨눌지 짚었다. 맡을 범위가 늘어 개인 사냥의 적 수가 많아졌다. 소매 정리는 이치고에게 남긴다.',
 '실타래를 풀고 남은 천을 나누어 준비 작업의 보수를 받았다. 우류가 다시 쓸 실을 따로 두었다. 바느질과 길목 확인까지 끝낸 것은 아니다.'
]);
scene('bl_chad_toy','아이 앞에 설 자리를 준비하거나 통행할 범위만 정리할 수 있다.',[
 '표시 도구 값을 내고 차드와 사람을 밀지 않고 앞에 설 자리를 골랐다. 몸을 오래 버티게 하고 누군가 앞을 지키는 준비를 배웠다. 다른 길목 확인은 이치고에게 맡긴다.',
 '맡을 길목을 한 곳 나누어 다른 사람에게 넘겼다. 보급 물약을 챙기고 개인 사냥의 적 수를 줄였다. 아이가 찾는 일은 차드에게 남긴다.',
 '가게 앞 짐 정리만 돕고 상인에게 작업 보수를 받았다. 차드는 인형을 그대로 조심스레 들고 있다. 아이와 다른 길의 문제를 대신 끝내지는 않았다.'
]);
scene('bl_yuzu_supplies','남겨 둘 보급을 준비할지, 바깥 길을 맡을지 정한다.',[
 '보급 비용을 내고 유즈와 돌아올 사람의 몫을 따로 묶었다. 오래 움직이고 준비한 몫을 챙기는 요령을 배웠다. 바깥 길을 살피는 일은 이치고에게 남긴다.',
 '이치고와 더 강한 적이 드나드는 길목을 맡기로 했다. 앞에 나서서 지킬 준비를 배우고 개인 사냥의 적 단계가 올라갔다. 집에 남길 보급까지 전부 챙기지는 못했다.',
 '가까운 보급을 분류하고 맡긴 곳에서 보수와 물약을 받았다. 유즈에게 비워 둔 칸을 다시 보여 주었다. 누구도 준비 없이 돌아오게 하지는 말자고 하며 바깥 일은 남긴다.'
]);
scene('bl_don_audience','보일 신호를 맞추거나 통행할 범위를 나누어 맡는다.',[
 '표시용품 값을 내고 칸온지와 멀리서도 보일 손짓을 맞췄다. 놓친 곳을 하나 더 살피고 움직일 자리를 찾는 준비를 배웠다. 콘과 좁은 길을 정리할 일은 아직 남았다.',
 '이치고와 더 넓은 길목까지 맡아 사람들이 지나갈 자리를 나누었다. 동료 앞에 나설 준비를 배우는 대신 개인 사냥의 적 수가 늘었다. 촬영을 모두 끝내거나 다른 길까지 비운 것은 아니다.',
 '맡을 길목을 한 곳 줄이고 촬영 짐 정리를 도왔다. 촬영 준비자에게 보수와 물약을 받고 개인 사냥의 적 수를 줄였다. 멀리 보낼 인사는 칸온지에게 남긴다.'
]);
scene('bl_uncertain_kit','불완전한 묶음에 비용을 걸지, 확인된 물품을 마련할지 정한다.',[
 '180골드를 내고 확인한 묶음은 필요한 목록에 맞았다. 우라하라와 빠뜨릴 준비를 한 번 더 살피는 요령을 배우고 보급 물약 두 개를 챙겼다. 목록 밖의 새 장비까지 받은 것은 아니다.',
 '확인된 물품 값을 내고 우라하라와 다음 싸움에 남길 준비를 골랐다. 빠뜨릴 곳을 살피는 요령을 배우고 보급 물약 하나를 받았다. 값싼 묶음의 빈칸은 그대로 남겨 둔다.',
 '묶음을 사지 않고 창고의 빈 상자를 정리했다. 우라하라에게 작업 보수를 받았다. 안에 무엇이 들어 있는지 확인하는 일은 맡지 않는다.'
]);
scene('bl_tatsuki_space','발 놓을 자리를 맞출지, 맡을 구역을 줄일지 정한다.',[
 '연습 준비물 값을 내고 타츠키와 발을 놓은 뒤 몸을 돌리는 순서를 맞췄다. 공격 방향과 버틸 자세를 준비했다. 기다리는 사람들의 연습까지 모두 대신하지는 않았다.',
 '보급 비용을 내고 오리히메와 맡을 길목을 한 곳 줄였다. 오래 움직일 몸의 준비를 챙기고 개인 사냥의 적 수를 줄였다. 연습 자리를 정하는 일은 타츠키에게 남긴다.',
 '연습에는 끼어들지 않고 모서리의 짐만 정리했다. 준비를 맡긴 곳에서 보수와 물약을 받았다. 타츠키가 맞출 자세와 기다리는 사람의 순서는 남겨 둔다.'
]);
edit(e('bl_uncertain_kit'),'failure','준비 묶음의 목록이 끝까지 맞지 않았다. 지불한 180골드는 돌아오지 않고 카드와 보급 물약도 받지 못한다. 확인되지 않은 물품을 쓸 수 있다고 하지는 않는다.','bl_uncertain_kit','비용을 띄어 쓰고 실패의 실제 결과를 분명히 한다.');
const merged={...current,cards:[...current.cards,...cards],events:[...current.events,...events]};merged.canonBoundary+=' 추가된 소매·인형·가족 보급·공개 촬영·불완전 준비 묶음·연습 자리는 공식 생활과 성격 소재에서 별도 창작한 문제다. 원작 할인 행사가 실제로 있었다고 주장하지 않으며 65%는 맵의 수치다. 군중·가족 상태·옷·장비·호위 NPC를 생성하거나 변형하지 않는다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(merged);if(check.errors.length)throw Error(JSON.stringify(check));
fs.writeFileSync(path.join(root,'revisions/karakura-expansion-curated-10.json'),JSON.stringify(merged,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/karakura-expansion-curation-10.json'),JSON.stringify({sourceRevision:'6d4b0d8',raw:'drafts/karakura-expansion-text-09.json',changes,check,notes:['기존 머리·카드9장·사건8개와 신규 사건의 수치·참조는 유지했다.','신규 우류 카드만 기존 레어와의 동일 축 열위를 줄여 다른 차지 준비로 바꾸었다. 원안 효과도 changes에 보존한다.']},null,2)+'\n',{flag:'wx'});
const request={review:true,system:'독립 검토자다. JSON {verdict,issues:[{key,problem,evidence,suggestion}],strengths:[string]}로 원작·행동·실제 수치의 모순을 찾는다. 맵 전용 수치를 원작 고유 능력이라고 오해하지 않는다.',brief:{sourceFacts:fixed.sourceFacts,existingCards:current.cards,newContent:{cards,events},mechanics:'독립6사건. 비용·level/density는 먼저 적용. 성공 때만 card/gold/potions. 불완전 묶음180비용·65% 성공은우라하라카드+물약2,실패는비용만.확정묶음260비용·같은카드+물약1.이미가진카드100골드.개인몹강함1..5·적수1..10.현재체력비용없음.재생은최대체력%/초,흡수와합산10%/초,물약별도.신규우류카드차지6·치명피해15이고 실제 바느질 장비를 지급하지 않는다.',questions:['몸을 조종·즉시 치료·새 활·참백도·퇴마·군중 이동이라는 미구현 기술을 약속하는가?','범위와 비용·보수·지정 카드가 결과와 맞는가?','확률 실패를 성공으로 쓰거나 원작 할인 행사라고 단정하는가?','기존 배송·경보의 제목만 바꾼 반복인가?']}};
fs.writeFileSync(path.join(root,'requests/karakura-expansion-review-10.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({cards:merged.cards.length,events:merged.events.length,roots:merged.events.filter(e=>!e.previous).length,check}));
