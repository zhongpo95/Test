// 호접저 초안의 단계·수량 혼동과 추상적인 반응을 실제 분기와 인물의 행동으로 고친다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/butterfly-expansion-fixed-36.json'),draft=read('drafts/butterfly-expansion-text-36.json').parsed;
const current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/13-butterfly.json'),'utf8'));
assert.deepEqual(draft.events.map(x=>x.key),fixed.events.map(x=>x.key));
const intros=['선배에게 버틸 몫을 배울지 이노스케의 도전을 맡을지 정한다.','두 사람을 부를 때 꾸준함을 보여 줄지 승부나 관심을 앞세울지 정한다.','놀란 사람을 안심시키는 동안 네즈코의 의지를 어떻게 지킬까?'];
const results=[
 ['180골드로 준비 물품을 마련하고 최대 체력을 늘려 받는 피해를 줄이는 요령을 배웠다. 무라타는 큰소리를 낸 사람보다 끝까지 자리를 지킬 사람이 필요할 때도 있다고 말한다. 이노스케는 아직 누가 더 강한지 답을 못 들었다며 다시 묻는다.',
  '이노스케와 작은 상대와 방향 조건 없는 일격에 힘을 싣는 요령을 배웠다. 받는 피해가 늘어나는 카드 부담을 얻고 개인 사냥의 적 단계도 1 올랐다. 이노스케가 다음 상대부터 찾자 무라타는 선배라는 호칭은 아직 바뀌지 않는다고 한다.',
  '개인 사냥의 적 단계를 1 낮추고 물약 1개를 받았다. 무라타는 승부를 벌일 대신 맡을 자리부터 확인하자고 한다. 이노스케는 빈 자리를 누가 맡을 거냐고 돌아본다.'],
 ['160골드로 반복할 자리를 마련하고 빠른 동작과 보스에게 힘을 싣는 요령을 배웠다. 탄지로는 어느 쪽이 먼저 왔는지 묻지 않고 두 사람 몫의 자리를 가리킨다. 젠이츠와 이노스케도 문 앞에서 더 버티지는 않는다.',
  '이노스케와 작은 상대와 방향 조건 없는 일격에 힘을 싣는 요령을 배웠다. 받는 피해가 늘어나는 카드 부담과 함께 개인 사냥의 적 수도 늘었다. 이노스케가 먼저 들어가자 젠이츠는 자기가 뒤처진 것은 아니라며 바로 따라간다.',
  '200골드로 반응을 보여 줄 자리를 마련하고 차지 일격과 치명타에 힘을 모으는 요령을 배웠다. 젠이츠가 보는 사람 앞쪽에 서려 하자 탄지로는 이번에는 끝까지 함께하자고 부른다. 이노스케는 멀리서 보지 말고 같이 들어오라고 한다.'],
 ['네즈코가 움직이지 않는 동안 상대의 놀람에도 동요하지 않고 좋은 몸 상태를 유지하는 요령을 배웠다. 탄지로는 동생에게 사람을 해치지 말라고 다시 명령하지 않는다. 방문객도 아무 일 없는 두 사람 사이에서 발을 한 번 멈춘다.',
  '180골드로 손님이 머무를 자리를 마련하고 탄지로에게 신속과 좋은 몸 상태에서 힘을 쓰는 요령을 배웠다. 탄지로는 손님에게 먼저 거리를 두어도 된다고 말한다. 네즈코는 손님을 따라 움직이지 않는다.',
  '방문 안내의 보수 100골드를 받고 개인 사냥의 적 수를 줄였다. 탄지로는 다음에 놀라지 않을 수 있도록 입구에서 먼저 설명하겠다고 한다. 방문객은 네즈코에게 가까이 오라는 요구 없이 돌아간다.']
];
const changes=[];
const events=fixed.events.map((p,i)=>{const d=draft.events[i];assert.equal(d.choices.length,p.choices.length);changes.push({key:p.key,field:'intro',before:d.intro,after:intros[i],reason:'인물의 미확인 냉철함·태도 시험과 긴장 안내 대신 실제 사건의 질문을 쓴다.'});return {key:p.key,title:p.title,story:d.story,intro:intros[i],previous:null,previousChoice:0,requiredCard:null,choices:p.choices.map((b,j)=>{changes.push({key:p.key+'#'+(j+1),field:'result',before:d.choices[j].result,after:results[i][j],reason:'적 단계 감소를 적 수 감소로 바꾼 오류를 수정한다. 실제 대련 결과·추상적인 신뢰/효율 평가를 제거하고 카드 학습·지속 부담·비용·물약·필드 변화와 인물의 남은 반응을 명시한다.'});return {label:d.choices[j].label,result:results[i][j],card:b.card,card2:b.card2,gold:b.gold,cost:b.cost,level:b.level,density:b.density,potions:b.potions,chance:b.chance};}),failure:null,canonFact:p.canonFact,uncertain:[]};});
const merged={...current,sources:[...new Set([...current.sources,...fixed.sourceFacts.map(x=>x.source)])],cards:[...current.cards,...fixed.cards],events:[...current.events,...events]};
merged.canonBoundary+=' 무라타의 선배 호칭과 이노스케의 도전·복귀 직전의 두 동료·네즈코를 두려워하는 방문객은 공식 특징에서 새로 만든 짧은 만남이다. 25화의 발전 주체는 탄지로이며 카나오가 플레이어에게 배우는 장면이 아니다. 무라타의 말은 창작 대사이며 실제 대련이나 NPC 동행이 없다. 네즈코 만남은 해가 진 뒤의 방문으로 한정하고 자기 의지를 지우는 암시 시험·공격 통제·즉시 치료는 없다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(merged);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('revisions/butterfly-expansion-curated-37.json',merged);write('revisions/butterfly-expansion-curation-37.json',{sourceRevision:'95b850d',raw:'drafts/butterfly-expansion-text-36.json',changes,check});
const schema=read('requests/magnolia-expansion-review-29.json').schema;
write('requests/butterfly-expansion-review-37.json',{review:true,schema,system:'한국어 독립 검토자다. 원작 주체·조건·실제 수치와 행동의 모순만 issues에 쓴다. PASS나REVISE를 반환한다. 카드의 요령은 수치 성장 비유이며 원작 기술의 지급이 아니다.',brief:{sourceFacts:fixed.sourceFacts,newContent:{cards:fixed.cards,events},mechanics:'모두독립3사건. 행동력1회사용,100%성공. 비용·적단계·밀도는먼저적용,카드·골드·물약은성공뒤지급. 단계와적수는별개다. 물약은획득. 현재체력소모없음. 재생흡수합10%/초,물약별도. 개인필드변경은선택후지속한다.',questions:['25화 성장 주체를 카나오로 뒤집거나 무라타의 새로운 말을 공식 대사로 주장하는가?','네즈코의 자기 의지를 지우거나 공격 시험·동행·새 기술·즉시 치료를 만드는가?','각분기의지불·배움·골드·물약·필드단계/밀도가숫자와맞는가?']}});
console.log(JSON.stringify({cards:merged.cards.length,events:merged.events.length,check}));
