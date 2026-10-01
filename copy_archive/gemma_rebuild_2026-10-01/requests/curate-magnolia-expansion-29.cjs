// 마그놀리아 초안의 적 수·강함 오기와 누락된 부담 감소를 고정 분기에 맞춘다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/magnolia-expansion-fixed-28.json'),'utf8')),draft=JSON.parse(fs.readFileSync(path.join(root,'drafts/magnolia-expansion-text-28.json'),'utf8')).parsed,current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/09-magnolia.json'),'utf8'));
assert.deepEqual(draft.events.map(e=>e.key),fixed.events.map(e=>e.key));
const changes=[];function edit(obj,field,value,key,reason){if(obj[field]===value)return;changes.push({key,field,before:obj[field],after:value,reason});obj[field]=value;}
const events=fixed.events.map((p,i)=>{assert.equal(draft.events[i].choices.length,p.choices.length);return {key:p.key,title:p.title,story:draft.events[i].story,intro:draft.events[i].intro,previous:null,previousChoice:0,requiredCard:null,choices:p.choices.map((b,j)=>({label:draft.events[i].choices[j].label,result:draft.events[i].choices[j].result,card:b.card,card2:b.card2,gold:b.gold,cost:b.cost,level:b.level,density:b.density,potions:b.potions,chance:b.chance})),failure:null,canonFact:p.canonFact,uncertain:[]};});
const intros=['식사할 철과 아직 쓸 부품을 어떻게 나눌까?','그레이 몫을 먼저 챙길지 돌아올 사람부터 셀지 정한다.','사진을 가져온 손님과 의뢰인을 같은 줄에 둘지 정한다.','먼저 가라는 뜻이었는지 돌아올 쪽을 맡겠다는 뜻인지 다시 묻는다.','부서진 벽 옆을 정리할지 바깥 일을 맡을지 정한다.','결말을 먼저 알려 줄지 독자가 멈춘 줄을 함께 읽을지 정한다.'];
const endings=[
 ['가질은 의자에 끼울 부품 쪽을 밀어 놓고 먹을 철만 자기 앞으로 당긴다. 미라젠은 아직 쓸 철을 식사로 내놓지 않게 표시를 남긴다.','나츠는 부품을 가져올 길을 가리키고 가질은 이번에는 먹을 철과 바꿔 들지 말라고 한다.','미라젠은 의자에 끼울 철을 챙기고 가질은 자기 몫이 남았는지 다시 묻는다.'],
 ['쥬비아가 그레이 쪽에 두었던 우산 하나를 옮기자 미라젠은 아직 돌아오지 않은 사람의 몫을 짚는다.','그레이는 자기 우산을 더 늘리지 말자고 하고 쥬비아는 돌아올 자리에 하나만 남겨 둔다.','남은 우산을 받아 든 사람이 누구를 기다리냐고 묻자 쥬비아는 다시 그레이 쪽을 본다.'],
 ['미라젠은 사진을 내민 사람에게 먼저 보고 싶던 것이 무엇인지 묻는다. 루시는 뒤에서 기다리던 의뢰인의 서류를 따로 받는다.','루시는 부탁의 첫 줄을 다시 읽고 미라젠은 사진을 가져온 손님에게 지금은 이야기를 길게 듣기 어렵다고 말한다.','사진을 돌려받은 손님이 다시 줄 끝에 서자 미라젠은 이번에는 무슨 부탁으로 왔는지 먼저 묻는다.'],
 ['나츠가 앞쪽으로 돌아서자 렉서스는 돌아오는 길까지 비우라는 말은 아니었다고 덧붙인다. 루시는 이제야 답의 끝을 적는다.','렉서스는 나츠가 돌아올 쪽도 맡겠다고 한 번 더 말하고 루시는 그 말부터 나츠에게 전한다.','렉서스는 남긴 연락에 돌아올 쪽 이야기도 적혔는지 확인하고 루시는 빠졌던 줄을 다시 읽는다.'],
 ['길다트가 남은 문틀을 돌아보자 미라젠은 그 옆에 짐을 놓지 말라고 한다. 너는 벽이 남은 쪽과 손이 닿을 쪽을 다시 짚는다.','엘자는 바깥 일을 맡기 전에 남은 문틀 쪽을 비워 두자고 한다. 길다트는 이번에는 그 옆을 지나지 않는다.','미라젠은 정리한 파편보다 아직 남은 벽부터 살피고 길다트는 문이 있던 쪽을 다시 가리킨다.','받은 물약을 챙기는 동안 미라젠은 다음 짐을 부서진 벽 옆에 쌓지 말자고 한다.'],
 ['루시는 다음 페이지를 보여 주려던 손을 멈추고 독자가 물은 줄을 고쳐 적는다. 해피는 이번에는 왜 그 길을 택했는지 읽어 보자고 한다.','루시는 남은 의뢰의 첫 줄을 적고 해피는 소설의 다음 페이지를 그 종이와 섞지 말라고 한다.','루시는 정리한 종이를 받아 들고 답이 뒤에 있다는 말 대신 독자가 멈춘 줄부터 다시 읽는다.']
];
events.forEach((e,i)=>{edit(e,'intro',intros[i],e.key,'추상적 효율 설명 대신 사건의 질문을 남긴다.');e.choices.forEach((b,j)=>{
 let result=b.result.split('。').join('.');
 result=result.replace('분류 용품을 지불하고','분류 용품을 마련해').replace('우산 표시 용품을 지불하고','우산 표시 용품을 마련해').replace('표시 용품을 지불하여','표시 용품을 마련해').replaceAll('표시 용품을 지불하고','표시 용품을 마련해').replace('종이 값을 지불하고','새 종이에');
 const s=result.split(/(?<=[.!?])\s+/);result=s.slice(0,2).join(' ');
 if(b.level===1&&b.density===0)result=result.replace('개인 적의 강함이 1 상승했으며 적의 수가 1명 늘어났다.','개인 사냥의 적 단계가 1 올라갔다.');
 if(b.level===0&&b.density===1)result=result.replace('개인 적의 강함이 1 상승했으며 적의 수가 1명 늘어났다.','개인 사냥의 적 수가 늘었다.');
 result=result.replace('개인 적의 강함은 그대로이나 적의 수가 2명 늘어났다.','개인 사냥의 적 수가 늘었다.').replace('개인 적의 강함은 그대로이나 적의 수가 1명 늘어났다.','개인 사냥의 적 수가 늘었다.');
 if(b.density===-1)result=result.replace('추가적인 요령이나 변화는 없다.','개인 사냥의 적 수가 줄었다.');
 if(e.key==='ft_two_umbrellas'&&j===2)result+=' 개인 사냥의 적 수가 줄었다.';
 result=result.replace('추가적인 요령이나 변화는 없다.','이번에는 배움을 청하지 않았다.').replace('체계적으로 분류한다.','따로 듣는다.');
 edit(b,'result',result+' '+endings[i][j],e.key+'#'+(j+1),'나츠·엘자 선택에 없는 적 수 증가와 그레이 선택에 없는 단계 증가를 제거하고 렉서스 분기의 적 수 감소 누락을 보완한다. 비용·물약·카드 수치는 유지하고 반복적인 외곽 감시·재정비 결말을 인물의 남은 행동으로 바꾼다.');
});});
const merged={...current,sources:[...new Set([...current.sources,...fixed.sourceFacts.map(s=>s.source)])],cards:[...current.cards,...fixed.cards],events:[...current.events,...events]};
merged.canonBoundary+=' 철 식사와 수리 부품·우산의 몫·잡지 방문객·짧은 답의 오해·벽 파손·소설 독자는 공식 인물 소개에서 별도로 창작했다. 렉서스 사건은 복귀 이후, 루시의 소설 사건은 신인 소설가 소개를 참고한 독립 만남이다. 모든 사건이 길드 재건의 같은 날짜에 일어난다는 뜻은 아니다. 가질의 철 식사·쥬비아의 물 신체·실제 벽 파손·NPC 전투 동행·새 원작 마법은 플레이어 기능이 아니다. 렉서스 카드의 공격력 감소는 지속 스탯이며 현재 체력을 지불하지 않는다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(merged);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
fs.writeFileSync(path.join(root,'revisions/magnolia-expansion-curated-29.json'),JSON.stringify(merged,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/magnolia-expansion-curation-29.json'),JSON.stringify({sourceRevision:'51b0c55',raw:'drafts/magnolia-expansion-text-28.json',changes,check},null,2)+'\n',{flag:'wx'});
const schema=JSON.parse(fs.readFileSync(path.join(root,'requests/mitakihara-expansion-review-20.json'),'utf8')).schema;
fs.writeFileSync(path.join(root,'requests/magnolia-expansion-review-29.json'),JSON.stringify({review:true,schema,system:'한국어 독립 검토자다. verdict는 PASS 또는 REVISE. 원작 사실·수치·행동의 실제 모순만 issues에 쓴다. 성장 비유를 원작 기술로 오해하지 않는다.',brief:{sourceFacts:fixed.sourceFacts,newContent:{cards:fixed.cards,events},mechanics:'독립6사건. cost/level/density 먼저, 성공 card/gold/potions. 모두100%다. currentHP지불없음. 흡수재생합산10%/초 물약별도. 실제벽파손·NPC동행·철식사·새마법·연애결말·파문해결없음. 같은풀은여러여행시점이다.',questions:['공식 인물 특징과 사건이 충돌하는가?','지불·보수·물약·카드 학습과 개인 적 강함·수가 고정 분기와 맞는가?','렉서스의 지속 공격력 감소를 현재체력 비용 또는 원작 처벌로 오해시키는가?']}},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({cards:merged.cards.length,events:merged.events.length,check}));
