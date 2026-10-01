// 카라쿠라 재집필의 중복 키·잘못된 발단·단계 표현을 분기별 원본과 대조해 고친다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/karakura-expansion-fixed-39.json'),draft=read('drafts/karakura-expansion-text-41.json').parsed,current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/10-karakura.json'),'utf8'));
assert.equal(draft.events.length,fixed.events.length);
const introValues=['왜 비워 두었는지 묻기 전에 옆으로 옮길까?','잇신의 걱정을 듣거나 이치고의 용건부터 마칠지 정한다.','들 수 있다는 이유로 부탁을 계속 늘려도 될까?','케이고가 허락받지 않은 약속을 누가 맡을지 정한다.'];
const results=[
 ['카린이 비워 둔 자리 옆으로 움직이며 빠른 발과 좋은 몸 상태에서 일격에 힘을 싣는 요령을 배웠다. 카린은 비켜 주면 되는 일을 모두 설명할 필요는 없다고 한다. 손님이 다시 앉으려 하자 이치고는 자기가 내준 자리를 가리킨다.',
  '이치고에게 공격력과 보스에게 힘을 싣는 요령을 배우고 개인 사냥의 적 단계를 1 올렸다. 카린은 자리를 옮기라는 말이 위험을 찾아가라는 뜻은 아니었다고 한다. 이치고는 네가 맡을 범위까지만 다시 짚는다.',
  '손님 안내의 보수 120골드를 받고 개인 사냥의 적 수를 줄였다. 카린은 사람이 앉은 쪽을 한 번 더 보고 말을 줄인다. 이치고는 빈 곳을 굳이 다시 채우지 않는다.'],
 ['180골드로 머무를 준비를 하고 최대 체력을 늘려 몸 상태를 천천히 유지하는 요령을 배웠다. 잇신이 아들과 무엇을 했냐고 다시 묻자 이치고는 물건만 돌려받는 일이라고 한 번 더 말한다. 유즈는 용건이 끝나면 안쪽 이야기까지 길어질 것 같다며 웃는다.',
  '유즈에게 몸 상태를 천천히 유지하며 처치 보수를 챙기는 요령을 배웠다. 맡을 길목을 넓혀 개인 사냥의 적 수가 늘었다. 유즈가 문을 비켜 주는 사이에도 잇신은 이치고의 친구가 온 이유부터 묻고 있다.',
  '이치고의 짧은 용건을 마치고 물약 2개를 받았다. 잇신은 다음에는 앉을 시간도 남겨 오라고 한다. 이치고는 다음 약속까지 대신 만들지는 말라며 물건을 챙긴다.'],
 ['220골드로 받칠 도구를 마련하고 우루루에게 차지 일격과 치명타에 힘을 모으는 요령을 배웠다. 우루루는 도구를 어디에 놓을지부터 묻는다. 진타는 들 수 있다고 모든 부탁을 받아야 하는 것은 아니라며 추가 상자를 뒤로 민다.',
  '차드에게 최대 체력을 늘려 받는 피해를 줄이는 요령을 배웠다. 점원에게 미룬 길목을 나눠 맡아 개인 사냥의 적 수가 더 늘었다. 차드는 맡을 몫을 짧게 말하고 진타는 손님에게 그보다 더 맡긴 적은 없다고 한다.',
  '추가 심부름을 받지 않고 마친 안내의 보수 130골드를 받았다. 맡을 길목을 줄여 개인 사냥의 적 수가 줄었다. 진타가 상자를 더 받지 않자 우루루도 지금 들고 있던 것부터 내려놓는다.'],
 ['케이고의 말을 끝까지 듣고 사건의 다른 후보를 살피며 빠르게 행동을 이어 가는 요령을 배웠다. 케이고는 같이 갈 줄 알았다는 말과 같이 가기로 했다는 말이 다르다는 지적을 듣는다. 이치고는 이번에는 물어보고 약속하라고 한다.',
  '이치고에게 공격력과 보스에게 힘을 싣는 요령을 배우고 개인 사냥의 적 단계를 1 올렸다. 이치고는 정한 범위 밖까지 약속한 것은 아니라고 케이고에게 말한다. 케이고도 이번에는 네가 맡기로 한 범위만 전한다.',
  '140골드로 따로 안내를 구하고 우라하라에게 사건의 다른 후보와 보스에게 힘을 싣는 요령을 배웠다. 우라하라는 먼저 누구와 한 약속인지 묻는다. 케이고는 이번 안내까지 이치고와 함께 가기로 했다고 덧붙이지 않는다.']
];
const changes=[];
function change(key,field,before,after,reason){if(before!==after)changes.push({key,field,before,after,reason});}
const events=fixed.events.map((p,i)=>{const d=draft.events[i];assert.equal(d.choices.length,p.choices.length);p.choices.forEach((b,j)=>assert.equal(d.choices[j].label,b.action));
 change(p.key,'key',d.key,p.key,'두 번째 사건이 첫 번째 사건 키를 복사했다. 원래 의원 문 앞 사건의 일치하는 장면·선택 순서를 직접 확인하고 고정 키로 고쳤다.');
 change(p.key,'story',d.story,p.scene,'첫 사건 story가 이미 선택하고 배운 결과로 바뀌어 선택 이전의 발단을 복구한다. 나머지는 고정 발단의 주체를 유지한다.');
 change(p.key,'intro',d.intro,introValues[i],'직감·분위기의 추상 평가 대신 실제 갈등의 질문을 쓴다.');
 return {key:p.key,title:p.title,story:p.scene,intro:introValues[i],previous:null,previousChoice:0,requiredCard:null,choices:p.choices.map((b,j)=>{change(p.key+'#'+(j+1),'result',d.choices[j].result,results[i][j],'한 명 강해짐을 적 단계 상승으로 고친다. 신뢰·감동·효율 대신 인물 반응을 구체화하고 실제 NPC 전투 동행처럼 보이는 이동을 제거한다. 비용·카드 학습·물약·필드·보수와 발단 주체를 맞춘다.');return {label:d.choices[j].label,result:results[i][j],card:b.card,card2:b.card2,gold:b.gold,cost:b.cost,level:b.level,density:b.density,potions:b.potions,chance:b.chance};}),failure:null,canonFact:p.canonFact,uncertain:[]};});
const merged={...current,cards:[...current.cards,...fixed.cards],events:[...current.events,...events]};
merged.canonBoundary+=' 카린의 빈 벤치·잇신의 문밖 환영·우루루에게 맡긴 큰 심부름·케이고의 허락 없는 초대는 제작사 인물 특징에서 별도로 만든 독립 만남이다. 카린의 영감과 우루루의 초인성을 플레이어의 시야나 신규 기술로 지급하지 않는다. 잇신은 의원을 운영하지만 선택은 실제 진료나 즉시 회복이 아니다. 케이고의 사건 후보 증가는 행동력이 아니며 최대4후보에 제한된다. 차드와 다른 인물의 대화는 상시 전투 동행 기능이 아니다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(merged);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('revisions/karakura-expansion-curated-42.json',merged);write('revisions/karakura-expansion-curation-42.json',{sourceRevision:'95b850d',raw:'drafts/karakura-expansion-text-41.json',changes,check});
const schema=read('requests/magnolia-expansion-review-29.json').schema;
write('requests/karakura-expansion-review-42.json',{review:true,schema,system:'한국어 독립 검토자다. 제공 공식 사실과 새 창작의 구분·수치·인물의 요구·새 기능의 실제 모순만 issues에 쓴다. 카드 요령은 성장 비유다. PASS나REVISE를 반환한다.',brief:{sourceFacts:fixed.sourceFacts,newContent:{cards:fixed.cards,events},mechanics:'독립4사건,100%성공,행동력1. 비용·적단계/밀도는선적용,성공카드/골드/물약지급. 필드는지속변경이며감소는하한제한. 현재HP코스트·즉시치유·진료·유령시야·실제NPC동행·새기술없음. 사건후보는최대4이며행동력아님. 흡수재생합10%/초,물약별도.',questions:['카린의영감을플레이어에게주거나사냥필드의적단계를한명만강해지는것처럼쓰는가?','무료성장/골드지불/필드부담/완화·보수·물약·지정카드가수치와맞는가?','사건을이미선택한뒤의결과로시작하거나깨진내부필드목록을노출하는가?']}});
console.log(JSON.stringify({cards:merged.cards.length,events:merged.events.length,check}));
