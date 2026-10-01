// 페나코니 집필의 보상 누락과 NPC 칭찬 반복을 수정하고 별도 재검토를 요청한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/penacony-expansion-fixed-45.json'),draft=read('drafts/penacony-expansion-text-45.json').parsed;
const current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/11-penacony.json'),'utf8'));
assert.deepEqual(draft.events.map(e=>e.key),fixed.events.map(e=>e.key));
const changes=[];
function edit(o,k,v,key,reason){if(o[k]===v)return;changes.push({key,field:k,before:o[k],after:v,reason});o[k]=v;}
const events=fixed.events.map((p,i)=>{assert.equal(draft.events[i].choices.length,p.choices.length);return {key:p.key,title:p.title,story:draft.events[i].story,intro:draft.events[i].intro,previous:p.previous||null,previousChoice:p.previousChoice||0,requiredCard:null,choices:p.choices.map((b,j)=>({label:draft.events[i].choices[j].label,result:draft.events[i].choices[j].result,card:b.card,card2:b.card2,gold:b.gold,cost:b.cost,level:b.level,density:b.density,potions:b.potions,chance:b.chance})),failure:p.failure||null,canonFact:p.canonFact,uncertain:[]};});
const intros=[
 '이름을 부르는 친구와 안내를 듣지 못한 관객 사이에서 맡을 일을 정한다.',
 '광고를 읽은 참가자가 자기 이름도 말할 수 있게 어떤 도움을 줄까?',
 '멋진 사진과 그 사진을 본 사람이 이해할 뜻은 같을까?',
 '갑옷을 기다리는 사람 곁에서 반디에게 먼저 무엇을 물을까?',
 '도움을 준 자리와 무대에 설 자리가 함께 표시되었다.',
 '광고를 뺀 사진에 반대 뜻의 설명이 붙었다.'
];
const results=[
 ['160골드로 듣기 좋은 다른 자리를 마련하고 뒤편 관객에게 시작 안내를 전했다. 로빈의 노래를 기다린 태도가 기억에 남아 공격력과 지속 체력 재생이 늘었다. 로빈은 앞줄의 큰 환호보다 뒤편에서 준비됐다는 답을 먼저 듣는다.',
  '친구와 첫마디까지 기다리기로 하고 개인 사냥의 적 수를 늘리는 부담을 택했다. 로빈의 첫마디를 기다린 기억으로 공격력과 고체력에서 가하는 피해가 늘었다. 친구는 이름을 외치려던 입을 다물고 언제 첫마디가 나올지 기다린다.',
  '시작 안내를 전달한 보수로 60골드와 물약 2개를 받았고 개인 사냥의 적 수를 줄였다. 네 안내를 들은 뒤편 관객이 앞줄까지 준비됐다는 말을 다시 전한다. 로빈은 아직 노래를 시작하지 않고 마지막 답을 듣는다.'],
 ['150골드로 새 소개지를 마련했고 참가자가 자기 이름부터 말하는 시도에 성공해 보수 60골드를 받았다. 로빈과 함께 첫마디를 기다린 기억으로 공격력과 고체력에서 가하는 피해가 늘었다. 참가자는 다음 소개에서도 여백을 보며 자기 이름을 빼지 않으려 한다.',
  '200골드로 안내 자리를 마련하고 참가자의 소개를 먼저 들어 줄 사람을 찾았다. 노래보다 앞선 목소리를 듣는 기억으로 공격력과 지속 체력 재생이 늘었다. 로빈은 준비한 말을 대신 읽지 않고 참가자가 새로 고른 첫 문장을 듣는다.',
  '광고 안내를 전달하고 맡은 일의 보수 120골드를 받았다. 참가자는 아직 이름이 없는 소개지를 손에 들고 있고 로빈은 빈 여백을 가리키던 손이 움직이는지 지켜본다.'],
 ['180골드로 IPC 광고가 들어오지 않는 사진 자리를 마련하고 배경을 바꾼 이유를 적었다. 많은 시선보다 한 표적을 보는 부트힐의 태도가 남아 보스와 방향 조건에서 가하는 피해가 늘었다. 관광객은 사진을 받은 뒤에도 어떤 설명을 붙일지 다시 읽는다.',
  '부트힐이 IPC에 알리려는 말을 듣고 개인 사냥의 적 단계를 높이는 부담을 택했다. 숨기지 않은 발걸음의 기억으로 이동속도와 그 증가량에 따른 피해가 늘었지만 받는 피해도 커졌다. 부트힐은 관광객에게 자신을 멋진 배경으로만 보았는지 다시 묻는다.',
  '촬영할 자리를 안내한 보수로 120골드를 받았고 개인 사냥의 적 수를 줄였다. 관광객에게 사진의 설명은 본인이 다시 물어야 한다고 전했다. 부트힐은 아직 카메라를 든 관광객의 다음 말을 기다린다.'],
 ['170골드로 풍경 안내를 마련하고 반디에게 갑옷 대신 보고 싶은 곳을 물었다. 갑옷 밖의 풍경을 고르는 기억으로 최대 체력과 이동속도가 늘었다. 반디는 갑옷 사진이 없는 안내에서 자신이 가리킨 풍경을 다시 본다.',
  '풍경 안내를 직접 전달하는 대신 개인 사냥의 적 수를 늘리는 부담을 택했다. 반디와 보고 싶은 풍경을 고르는 기억으로 최대 체력과 이동속도가 늘었다. 갑옷을 기다리던 여행자는 아직 질문을 바꾸지 않았지만 반디는 안내의 다른 면을 펼친다.',
  '갑옷을 보여 달라는 요구를 거들지 않고 안내를 마쳐 물약 2개를 받았다. 개인 사냥의 적 수를 줄였다. 반디는 안내에 남은 풍경을 보고 있고 관광객은 다음 질문을 고르고 있다.'],
 ['130골드로 잘못 붙은 자리 표시를 고쳐 참가자의 이름과 무대 자리를 다시 적었다. 앞선 목소리를 기다린 로빈의 태도가 남아 공격력과 지속 체력 재생이 늘었다. 다음 손님은 참가자를 찾아가고 너는 준비를 도운 자리에 남았다.',
  '다음 안내를 맡고 손님에게 자신은 준비를 도운 사람이라고 설명해 보수 180골드를 받았다. 로빈은 참가자가 있는 쪽을 다시 가리키고 손님은 듣고 싶었던 말을 그에게 묻는다.',
  '맡을 안내 자리를 줄이고 보수 80골드와 물약 1개를 받았으며 개인 사냥의 적 수를 줄였다. 참가자에게 잘못 붙은 자리 표시를 직접 보여 주었다. 로빈은 참가자가 자기 자리를 다시 알릴 때까지 곁에서 듣는다.'],
 ['140골드로 설명지를 다시 마련해 부트힐이 IPC의 수호자가 아니라 그들에게 알릴 말을 가진 레인저라고 적었다. 빠진 말을 되찾는 기억으로 사건 후보와 치명타 피해가 늘었다. 관광객은 사진 아래에 왜 배경을 바꾸었는지도 함께 남긴다.',
  '부트힐이 IPC에 알리려는 말을 전하고 개인 사냥의 적 단계를 높이는 부담을 택했다. 숨기지 않은 발걸음의 기억으로 이동속도와 그 증가량에 따른 피해가 늘었지만 받는 피해도 커졌다. 관광객은 수호자라고 적었던 설명 위에 선을 긋는다.',
  '사진 설명을 다시 물어야 한다고 전달하고 보수 150골드를 받았으며 개인 사냥의 적 수를 줄였다. 관광객은 잘못 쓴 설명을 접고 부트힐에게 다음 말을 묻는다. 부트힐은 배경보다 그 종이에 적힐 말을 보고 있다.']
];
events.forEach((e,i)=>{edit(e,'intro',intros[i],e.key,'반드시 옳은 일을 해야 한다는 지시 대신 선택할 문제를 요약한다.');e.choices.forEach((b,j)=>edit(b,'result',results[i][j],e.key+'#'+(j+1),'모델이 빠뜨린 카드 성장·지불·보수·물약·필드 변화와 이동 카드의 부담을 명시한다. 칭찬/미소/신뢰라는 같은 결말 대신 인물에게 남은 행동을 쓴다. 자원 선택을 무관심으로 비난하지 않는다.'));});
edit(events[0],'story',fixed.events[0].scene,events[0].key,'플레이어 곁의 친구가 사라져 선택의 주체가 불분명해진 초안을 고친다.');
edit(events[4],'story','참가자가 첫 소개를 마친 뒤 이름을 적은 안내지에 준비를 도운 네 자리까지 출연석으로 표시되었다. 다음 손님은 그 표시를 보고 네게 공연을 부탁한다. 로빈은 누가 소개를 준비했고 누가 이름을 말했는지 다시 구분하자고 한다.',events[4].key,'참가자 이름이 있는데 플레이어를 가수로 오해하는 이유가 없었다. 잘못 붙은 자리 표시를 창작 발단으로 특정한다.');
const candidate={...current,sources:[...new Set([...current.sources,...fixed.sourceFacts.map(x=>x.source)])],cards:[...current.cards,...fixed.cards],events:[...current.events,...events]};
candidate.canonBoundary+=' 공연 안내의 관객 갈등·오디션의 빈 이름·IPC 광고가 들어온 관광 사진·갑옷을 기다리는 관광객과 두 개인 후속은 개발팀 소개에서 각색한 별도 만남이다. 로빈은 새 오디션의 심사위원이 아니며 참가자 대신 노래하지 않는다. 부트힐은 IPC 직원이 아니라 그들에게 복수하려는 갤럭시 레인저다. 수호자라는 후속 문장은 관광객의 잘못된 설명이고 사건에서 바로잡는다. 반디의 카드 체력 성장은 질병 치료가 아니며 SAM을 지급하거나 소환하지 않는다. 서로 다른 여행 시점의 독립 사건이다. 새 군중은 사냥 몬스터가 아니며 개인 필드 변화는 별도 원정 준비 조건이다. 후속은 자신의 성공한 1번 선택에만 연결한다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('revisions/penacony-expansion-curated-46.json',candidate);
write('revisions/penacony-expansion-curation-46.json',{sourceRevision:'d94e43d',raw:'drafts/penacony-expansion-text-45.json',changes,check,numericExceptions:[]});
const schema=read('requests/mitakihara-expansion-review-20.json').schema;
write('requests/penacony-expansion-review-46.json',{review:true,schema,system:'한국어 독립 검토자다. PASS 또는 REVISE로 판단한다. 입력에 실제로 있는 모순만 issues에 쓴다. 후보의 새 장면은 창작이므로 제공된 공식 인물의 역할·목적을 뒤집는지 검토한다. 카드 기억의 성장과 원작 기술 전수를 구분한다. 성공 결과는 실패 결과와 별도다.',brief:{sourceFacts:fixed.sourceFacts,newContent:{cards:fixed.cards,events},mechanics:'각 사건 진입은 행동력1. 머리 소지와 자신의 previousChoice 양수 성공을 후속 조건으로 검사한다. cost/level/density 먼저 적용하고 성공시에만 card/gold/potions를 준다. 오디션1번150골드70%성공이면카드+60골드,실패면150골드비용만이며성공후속은안뜬다. 같은 카드 이미소지시100골드교환. 현재체력비용없음. regeneration0.4는초당최대체력0.4%,물약과별도. moving_damage는기본400대비이동증가량에비례하며이동중에만발동하는옵션아님. 피해감소-3은지속받는피해부담. 관객은적유닛으로바뀌지않고NPC동행/새전투/사진시스템없음.',questions:['로빈·부트힐·반디의 역할과 목적을 뒤집거나 NPC 대신 플레이어가 공연/갑옷을 명령하는가?','지불·성공·실패·카드 효과·물약·개인 적 강함과 수가 결과와 맞는가?','실패나 다른 플레이어 기록에서도 새 성공 후속이 열린다고 설명하는가?','부트힐을 IPC의 수호자로 실제 설정하거나 반디 질병을 치료했다고 쓰는가?']}});
console.log(JSON.stringify({newCards:fixed.cards.length,newRoots:events.filter(e=>!e.previous).length,newFollowups:events.filter(e=>e.previous).length,check}));
