// 공역 재집필의 골드 누락과 적 수·강함 오기를 실제 분기와 대조한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/zegagrande-expansion-fixed-25.json'),'utf8')),draft=JSON.parse(fs.readFileSync(path.join(root,'drafts/zegagrande-expansion-text-26.json'),'utf8')).parsed,current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/07-zegagrande.json'),'utf8'));
assert.deepEqual(draft.events.map(e=>e.key),fixed.events.map(e=>e.key));
const changes=[];function edit(obj,field,value,key,reason){if(obj[field]===value)return;changes.push({key,field,before:obj[field],after:value,reason});obj[field]=value;}
const events=fixed.events.map((p,i)=>{assert.equal(draft.events[i].choices.length,p.choices.length);return {key:p.key,title:p.title,story:draft.events[i].story,intro:draft.events[i].intro,previous:null,previousChoice:0,requiredCard:null,choices:p.choices.map((b,j)=>({label:draft.events[i].choices[j].label,result:draft.events[i].choices[j].result,card:b.card,card2:b.card2,gold:b.gold,cost:b.cost,level:b.level,density:b.density,potions:b.potions,chance:b.chance})),failure:p.failure||null,canonFact:p.canonFact,uncertain:[]};});
const endings=[
 ['로제타는 확인한 날짜와 아직 묻지 못한 부분을 따로 적고 라캄은 확인한 기록만 항로 옆에 남긴다.','로제타는 서로 다른 날짜를 같은 안내로 옮겨 적지 말자고 한다. 라캄은 다음에 같은 이야기를 들으면 날짜부터 묻겠다고 답한다.','라캄은 남긴 길과 비워 둔 길을 나누어 표시하고 로제타는 확인하지 않은 부분을 지우지 않고 남긴다.'],
 ['롤란은 목적을 먼저 들었으면 돌아오지 않아도 됐겠다고 웃고 비는 방금 가리킨 쪽을 다시 살핀다.','라캄은 더 강한 적이 오가는 길임을 다시 짚고 롤란은 안내를 듣던 여행자에게 그 길을 쉽게 권하지 말자고 한다.','비가 남은 길을 가리키자 롤란은 이번에는 어디에 가려는지 먼저 묻는다.'],
 ['랜슬롯은 첫 순서보다 다음 사람이 이어받을 자리를 다시 확인하고 베인은 돌아올 사람을 기다릴 쪽에 선다.','베인은 돌아올 길을 남겨 두되 너의 바깥에는 더 많은 적이 접근할 것이라고 짚는다.','랜슬롯은 약한 구역에서 돌아오는 쪽도 비워 두지 말자고 하고 베인은 받은 물약을 챙겼는지 묻는다.','앞에 모였던 사람들이 다음 교대 자리를 살피는 동안 랜슬롯은 아직 비어 있는 뒤쪽을 다시 확인한다.'],
 ['퍼시벌은 묶음 수가 같아졌는지보다 그 사람이 들고 갈 수 있는지 먼저 본다. 약한 여행자가 작은 묶음을 다시 들어 보자 베인은 남은 쪽을 맡는다.','베인은 바깥의 강한 적을 맡을 준비를 하고 퍼시벌은 약한 여행자의 짐에 같은 부담을 다시 얹지 말자고 한다.','퍼시벌은 가벼워진 짐을 다시 들 수 있는지 묻고 여행자는 다음 길에서 멈출 곳을 짚는다.'],
 ['요달라하는 네가 발을 옮긴 뒤 낚싯대를 건드리지 않았는지 먼저 본다. 더 보여 달라는 말에는 낚시할 자리를 가리킨다.','나루메아는 검이 닿는 방향만 보지 말고 옆 통로도 남기자고 한다. 요달라하는 너희가 비운 물가 자리에 다시 낚싯대를 둔다.','요달라하는 긴 짐이 빠져나간 길을 보고 낚싯대를 옮길 필요는 없겠다고 한다.'],
 ['이오는 더 큰 힘을 쓰기 전에 앞줄이 무엇을 보고 있는지 다시 묻는다. 비가 서로의 어깨 대신 이오 쪽을 가리키자 다음 시범을 기다리던 사람들이 자리를 바꾼다.','라캄은 늘어난 적이 오갈 바깥 길을 다시 확인하고 비는 안쪽 자리가 막히지 않았는지 돌아본다.','이오는 남은 자리에 누가 서 있었는지 묻고 비는 아직 자리를 옮기지 않은 뒷줄을 가리킨다.']
];
const intros=['서로 다른 날짜의 안내 중 무엇을 확인할지 정한다.','먼저 목적을 물을지 바깥 길을 확인할지 정한다.','비어 있는 교대 자리와 돌아올 길을 나눈다.','같은 묶음에 다른 부담을 다시 나눈다.','낚시꾼의 짧은 발 움직임을 다시 살펴본다.','더 큰 시범보다 먼저 보는 자리를 나눈다.'];
events.forEach((e,i)=>{edit(e,'intro',intros[i],e.key,'추상적 지시·체계적 배정 대신 해당 사건 문제를 요약한다.');e.choices.forEach((b,j)=>{
 let result=b.result.replace(/\s*"[^"\n]*"\s*$/,'').trim();
 if(b.cost&&!result.includes(String(b.cost))){const names=['복사 용품','표시 용품','표시 용품','묶을 용품','연습 도구','바닥 표시 용품'];result=result.replace(/^.*? 내고 /,names[i]+' 값'+b.cost+'골드를 내고 ');}
 result=result.replace('담당하는 구역의 수가 1개 줄었다.','개인 사냥의 적 수가 줄었다.').replace('개인 몬스터 강함이 1 증가했다.','개인 사냥의 적 단계가 올라갔다.').replace('개인 몬스터 강함이 1 낮아졌다.','개인 사냥의 적 단계가 낮아졌다.').replace('개인 몬스터 수가 2개 증가했다.','개인 사냥의 적 수가 늘었다.');
 if(e.key==='gbf_io_audience'&&j===1)result=result.replace('개인 사냥의 적 단계가 올라갔다.','개인 사냥의 적 수가 늘었다.');
 edit(b,'result',result+' '+endings[i][j],e.key+'#'+(j+1),'누락 비용을 보완하고 적 수를 강함으로 오해한 결과를 정정한다. 반복되는 무주체 설명 대사를 각 인물의 남은 행동으로 바꾼다. 고정 수치는 유지한다.');
});});
const merged={...current,sources:[...new Set([...current.sources,...fixed.sourceFacts.map(s=>s.source)])],cards:[...current.cards,...fixed.cards],events:[...current.events,...events]};
merged.canonBoundary+=' 안내 날짜·여행자의 목적·교대·짐의 부담·낚시꾼의 발 움직임·관객 자리는 인물 소개에서 별도 창작했다. 요달라하에게서 낚시 결과가 아니라 몸놀림을 배운다. 롤란의 비밀·교회 직업·루리아의 운명·세계 위기는 새 선택으로 해결하지 않는다. 같은 풀의 만남은 여러 여행 시점이며 모든 인물이 동시에 한 장소에 모였다는 뜻은 아니다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(merged);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
fs.writeFileSync(path.join(root,'revisions/zegagrande-expansion-curated-27.json'),JSON.stringify(merged,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/zegagrande-expansion-curation-27.json'),JSON.stringify({sourceRevision:'51b0c55',raw:'drafts/zegagrande-expansion-text-26.json',changes,check,notes:['고정6카드·6사건 수치와 기존 콘텐츠는 유지한다.','최초 성공·실패와 물약 반전은 별도 이유를 남기고 재집필했다.','재집필은 비용 누락과 이오 분기의 적 수·강함 오기 및 반복 설명 대사를 보완한다.']},null,2)+'\n',{flag:'wx'});
const schema=JSON.parse(fs.readFileSync(path.join(root,'requests/mitakihara-expansion-review-20.json'),'utf8')).schema;
const request={review:true,schema,system:'한국어 독립 검토자다. verdict는 PASS 또는 REVISE. 원작·수치·행동의 실제 모순만 issues에 쓴다. 성장 비유를 원작 기술로 오해하지 않고 문제 없는 항목은 넣지 않는다.',brief:{sourceFacts:fixed.sourceFacts,newContent:{cards:fixed.cards,events},mechanics:'독립6사건. cost/level/density먼저, 성공card/gold/potions. 기록주인70%첫선택은160골드후성공시에만카드와180보수,실패비용만. 물약선택은100골드소비후물약1획득과적단계-1. 소지카드100골드. 현재체력지불없음. 흡수재생합산10%/초물약별도. 실제낚시·NPC동행·새마법·시간여행없음.',questions:['공식 성격·안내·관찰·기사 역할·낚시꾼을 자처하는 검호와 충돌하는가?','성공과 실패, 비용·보수·물약 및 개인 적 강함과 수가 맞는가?','낚시기록 재탕이나 기존 화물·사격·연금의 이름만 바꾼 사건인가?']}};
fs.writeFileSync(path.join(root,'requests/zegagrande-expansion-review-27.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({cards:merged.cards.length,events:merged.events.length,check}));
