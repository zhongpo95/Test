// 창병 조우의 누락된 카드 학습과 이동 효과를 보완하고 지속 필드 변화를 명시한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/fuyuki-expansion-fixed-38.json'),draft=read('drafts/fuyuki-expansion-text-38.json').parsed,current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/01-fuyuki.json'),'utf8'));
assert.deepEqual(draft.events.map(e=>e.key),fixed.events.map(e=>e.key));
const intro='창이 비킨 쪽을 택할지 발을 둘 간격부터 볼지 정한다.';
const results=[
 '랜서 앞에서 일격의 방향과 빠른 발을 고르는 요령을 배웠다. 더 강한 길목을 맡아 개인 사냥의 적 단계가 1 올랐다. 랜서는 창끝만 보고 지나갈 수 있을 것 같았냐고 묻고 세이버는 네가 옮긴 발의 자리를 본다.',
 '180골드로 등불을 마련하고 세이버에게 발을 빨리 옮기며 받는 피해를 줄이는 요령을 배웠다. 랜서는 창을 돌린 쪽보다 등불을 놓은 쪽을 먼저 본다. 세이버는 이번에는 창의 움직임과 네 발의 움직임을 함께 보자고 한다.',
 '가까이 다가가는 대신 맡을 길목을 줄여 개인 사냥의 적 수가 줄었다. 세이버는 아직 간격을 제대로 보지 못했다면 다시 보러 와도 된다고 말한다. 랜서는 네가 물러난 쪽을 지켜보며 창을 자기 옆으로 돌린다.'
];
const changes=[];
const events=fixed.events.map((p,i)=>{const d=draft.events[i];assert.equal(d.choices.length,p.choices.length);changes.push({key:p.key,field:'intro',before:d.intro,after:intro,reason:'위압감을 평가하는 문장 대신 실제 선택의 질문을 쓴다.'});return {key:p.key,title:p.title,story:d.story,intro,previous:null,previousChoice:0,requiredCard:null,choices:p.choices.map((b,j)=>{changes.push({key:p.key+'#'+(j+1),field:'result',before:d.choices[j].result,after:results[j],reason:'첫 분기 방향·이동 카드 학습과 두 번째 이동 속도 학습 누락을 채운다. 다음 한 구역에서만 강해지는 듯한 설명·랜서의 단정적 비웃음을 빼고 지속 개인 적 단계/밀도와 인물의 남은 행동으로 쓴다.'});return {label:d.choices[j].label,result:results[j],card:b.card,card2:b.card2,gold:b.gold,cost:b.cost,level:b.level,density:b.density,potions:b.potions,chance:b.chance};}),failure:null,canonFact:p.canonFact,uncertain:[]};});
const merged={...current,cards:[...current.cards,...fixed.cards],events:[...current.events,...events]};
merged.canonBoundary+=' 창병과 좁은 길의 조우는 공식 창병 영령과 세이버의 소개에서 창작한 독립 만남이다. 랜서의 마스터·진의·필중 기술·본편 승부를 결정하지 않고 창이나 등불을 실제 아이템으로 지급하지 않는다. 무료로 간격을 배우는 선택도 행동력을 쓰고 지속 개인 적 단계가 올라간다. NPC 전투 동행이 아니다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(merged);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('revisions/fuyuki-expansion-curated-40.json',merged);write('revisions/fuyuki-expansion-curation-40.json',{sourceRevision:'95b850d',raw:'drafts/fuyuki-expansion-text-38.json',changes,check});
const schema=read('requests/magnolia-expansion-review-29.json').schema;
write('requests/fuyuki-expansion-review-40.json',{review:true,schema,system:'한국어 독립 검토자다. 원작 사실과 새로운 창작을 나누고 실제 수치·인물 주체·새 기능의 모순만 issues에 쓴다. 카드의 요령은 수치 성장 비유다. PASS나REVISE를 반환한다.',brief:{sourceFacts:fixed.sourceFacts,newContent:{cards:fixed.cards,events},mechanics:'독립1사건,모두100%성공. 행동력1. 비용·필드단계/밀도선적용,지정카드/골드/물약성공뒤지급. 현재체력소모·실제NPC동행·원작기술·실물등불없음. 개인필드변경은지속된다.',questions:['원작소개에서확인하지않은마스터·진의·승부를확정하는가?','방향/이동/방어의카드학습과단계/밀도·비용이실제분기와맞는가?']}});
console.log(JSON.stringify({cards:merged.cards.length,events:merged.events.length,check}));
