// 숫자 필드를 서사에 복사한 마그놀리아 초안을 제외하고 이야기 전용 요청을 보존한다.
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..');
const first=JSON.parse(fs.readFileSync(path.join(__dirname,'magnolia-text-01.json'),'utf8'));
const plan=JSON.parse(fs.readFileSync(path.join(root,'revisions/magnolia-plan-01.json'),'utf8'));
plan.events.find(e=>e.key==='ft_timber').choices[0].cost=120;
plan.events.find(e=>e.key==='ft_timber').choices[0].density=-1;
plan.events.find(e=>e.key==='ft_fish').choices[0].density=-1;
plan.events.find(e=>e.key==='ft_fish').story+=' 엘자와 웬디도 옆에서 수송할 짐을 정리하고 있다.';
fs.writeFileSync(path.join(root,'revisions/magnolia-plan-02.json'),JSON.stringify(plan,null,2)+'\n',{flag:'wx'});
const schema=first.schema;
const props=schema.properties.events.items.properties;
props.intro.maxLength=110;props.story.maxLength=350;props.choices.items.properties.result.maxLength=180;
const request={schema,system:'한국어 게임 사건을 공동 집필한다. 주어진 9사건을 모두 출력한다. key, 행동 수와 순서를 유지한다. intro는 미확정 결과를 말하지 않는 1문장이다. story는 플레이어가 개입할 문제를 2~3문장으로 제시한다. result는 행동 후에 변한 구체적인 상황을 1~2문장으로 묘사한다. 매번 칭찬하거나 웃는 결과를 반복하지 말고 물품·문서·통로·원래 문제에 무엇이 달라졌는지 쓴다. 영어 필드명, 숫자, 카드 보상, 코드, 획득 스킬, 모델·제작 설명을 문장에 넣지 않는다. 인물이 할 수 없는 마법을 쓰거나 플레이어가 원작 능력을 얻는다고 약속하지 않는다. 샤를은 확정 미래를 보지 않는다. 모든 선택을 영웅적인 희생으로 과장하지 않는다.',brief:{facts:first.brief.facts,events:plan.events.map(e=>({key:e.key,title:e.title,situation:e.story,previousAction:e.previous?plan.events.find(p=>p.key===e.previous).choices[Math.abs(e.previousChoice)-1].label+(e.previousChoice<0?' 실패 이후':' 이후'):e.requiredCard?'나츠와 공격 준비를 이미 배운 뒤':'선행 행동 없음',actions:e.choices.map(b=>({action:b.label,learning:b.card?plan.cards.find(c=>c.key===b.card).name+'의 준비를 익힘':'일의 수고비 또는 보급품을 챙김',consequence:b.density>0?'돌아갈 길에서 더 많은 적을 감수':b.density<0?'통로를 정리해 주변 위험을 줄임':b.level>0?'위험한 길을 맡아 더 강한 적을 감수':b.cost>0?'자재나 장비 준비에 비용을 지출':'일을 마치고 의뢰를 확인'}))}))}};
fs.writeFileSync(path.join(__dirname,'magnolia-text-02.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log('마그놀리아 이야기 전용 재요청 보존.');
