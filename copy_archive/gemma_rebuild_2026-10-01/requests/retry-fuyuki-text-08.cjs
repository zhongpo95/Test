// 후유키 초안의 제작 안내 문장을 제외하고 인물 반응이 있는 사건 문장을 재요청한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..');
const fixed=JSON.parse(fs.readFileSync(path.join(root,'requests/fuyuki-expansion-fixed-07.json'),'utf8'));
const scenes=[
 '타이가는 부실의 상자를 손가락으로 세다가 목록을 다시 편다. 한 상자에는 가져온 사람의 이름이 없다. 시로는 먼저 학생들에게 물어보자고 한다.',
 '린이 빈 연락 기록을 시로 앞에 놓는다. 시로는 다른 사람의 일을 돕다 잊었다고 한다. 세이버는 확인할 곳을 나누면 될지 묻는다.',
 '신지는 자신이 라이더의 마스터라는 말을 먼저 꺼내고 협력을 제안한다. 린은 원하는 조건이 빠져 있다고 지적한다. 시로는 받아들일지보다 먼저 무엇을 확인할지 망설인다.',
 '아처가 지도에 들어갈 길과 돌아설 자리를 다른 표시로 그린다. 시로는 표시 밖의 사람들을 가리킨다. 둘은 네가 어느 길목을 맡을지 기다린다.',
 '린이 오늘은 잠깐 바깥을 둘러보자고 한다. 세이버는 낯선 길에서 자꾸 주위를 살피고 시로의 걸음이 앞서간다. 준비할 물건과 걸을 범위를 골라야 한다.',
 '잇세이의 진술에는 직접 본 일과 들은 일이 같은 줄에 적혀 있다. 린은 어느 말이 어느 쪽인지 다시 묻고 싶어 한다. 시로는 같은 학교 선생님이라는 이유만으로 결론 내릴 수 없다고 말한다.',
 '시로와 아처는 다음 싸움에서 무엇을 먼저 맡을지 다르게 생각한다. 시로는 놓치게 될 사람을, 아처는 감당할 결과를 짚는다. 누구에게 맞추더라도 둘의 의견 차이는 남는다.'
];
const content=fixed.events.map((e,i)=>({key:e.key,title:e.title,scene:scenes[i],choices:e.choices.map(b=>({action:b.action,successReward:{card:b.card,cost:b.cost,gold:b.gold,potions:b.potions,personalEnemyStrength:b.level,personalEnemyCount:b.density,chance:b.chance}}))}));
const str={type:'string'},schema={type:'object',additionalProperties:false,required:['events'],properties:{events:{type:'array',minItems:7,maxItems:7,items:{type:'object',additionalProperties:false,required:['key','story','intro','choices'],properties:{key:str,story:str,intro:str,choices:{type:'array',minItems:2,maxItems:4,items:{type:'object',additionalProperties:false,required:['label','result'],properties:{label:str,result:str}}}}}}}};
const request={review:false,schema,system:'게임 화면에 들어갈 한국어 이야기만 쓴다. 사건마다 인물의 짧은 반응과 물건 하나를 보여 준다. story는 3문장, intro는 어느 일을 맡을지 안내하는 1문장, 결과는 2~3문장이다. 제작 문서, 공식 몇 화, 창작이다, 구현하지 않는다, NPC, 스탯 같은 설명을 절대 출력하지 않는다. 전부 끝냈다는 결말 대신 선택한 일을 끝내고 선택하지 않은 문제를 남긴다.',brief:{content,cards:fixed.cards.map(c=>({key:c.key,name:c.name,effects:c.effects})),canonSources:fixed.sourceFacts,example:{story:'린이 빈 연락 기록을 시로 앞에 놓는다. 시로는 다른 일을 돕다 잊었다고 말하지만 린은 다음 확인까지 남에게 맡길 수는 없다고 한다. 세이버가 둘 사이에서 오늘 맡을 곳부터 나누자고 제안한다.',intro:'빠진 연락을 확인할지, 맡을 범위를 줄일지 정한다.',result:'기록용품 값을 내고 린과 먼저 확인할 연락부터 나누었다. 답이 온 곳과 오지 않은 곳을 구분하며 판단할 순서를 익혔다. 답 없는 곳까지 안전하다고 결론 내리지는 않는다.'},rules:['각 key와 선택 순서를 유지한다. 숫자를 결과에서 다시 나열할 필요는 없지만 지급 카드가 어떤 준비인지 보여 준다.','비용은 준비물·연락·기록에 쓴다. 캐릭터에게 강의료나 우정을 구매하지 않는다. 골드 보수는 조사 자료의 정리·물건 작업을 의뢰한 곳에서 받고 물약은 보급품으로 받는다.','개인 몹 강함 +1이면 더 강한 적을 맡았다는 결과, 적 수 +1이면 더 넓은 길목을 맡아 적 수가 늘었다는 결과를 포함한다. 감소도 정리된 맡을 구역에 연결한다.','60%와 70% 선택의 result는 성공 결과다. 자료 보수를 받을 근거와 지정 카드의 준비를 보여 준다. 실패 문장은 별도 고정 계획에 있으므로 작성하지 않는다.','새 전투·지형·동료 NPC·관계·역사·정체 확정 기능은 없다. 이번 사건의 연락·지도·증언과 인물 의견은 작은 각색이며 본편 승패와 결말을 바꾸지 않는다.','동일한 나열 문장이나 효율적·체계적 정리라는 문구를 반복하지 않는다. 인물의 말과 맡지 않은 일을 사건별로 다르게 쓴다.']}};
fs.writeFileSync(path.join(root,'revisions/fuyuki-text-rejection-07.json'),JSON.stringify({raw:'drafts/fuyuki-expansion-text-07.json',decision:'문장 재요청. 수치·참조 계획은 유지.',reasons:['모든 intro가 공식 몇 화·창작·NPC 같은 제작 메타데이터로 채워져 게임 화면 설명에 맞지 않는다.','결과가 기록 정리·효율 같은 추상 문장을 반복하고 카드 보상·개인 필드 부담·보수 제공자 설명이 빠졌다.','효과 이름이 스탯과 제작 용어의 나열이라 인물의 느낌이 약하다.'],revisit:'새 문장만 별도로 보존하여 기존 원안을 덮어쓰지 않고 실제 수치와 다시 대조한다.'},null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'requests/fuyuki-expansion-text-08.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log('후유키 화면용 문장 재요청 보존.');
