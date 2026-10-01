// 잘못 연결된 원문과 수정 문장을 작은 묶음으로 제시해 Gemma의 판단도 대조한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'../../..'),cases=[];
function add(id,f,key,choice,original=false){const file=original?path.join(root,'copy_archive/gemma_rebuild_2026-10-01/revisions',f.replace('.json','-before-semantic-08.json')):path.join(root,'content/roguelite',f);const w=JSON.parse(fs.readFileSync(file,'utf8'));const e=w.events.find(x=>x.key===key),b=e.choices[choice-1];cases.push({id,action:b.label,result:b.result,paid:b.cost,receivedGold:b.gold,monsterLevelChange:b.level,monsterCountChange:b.density});}
add('original_saber','01-fuyuki.json','temple_gate',2,true);
add('original_darkness','02-axel.json','axel_request',2,true);
add('original_chris','02-axel.json','axel_crowded_road',2,true);
add('original_receipt','02-axel.json','axel_stolen_notice',2,true);
add('revised_saber','01-fuyuki.json','temple_gate',2);
add('revised_darkness','02-axel.json','axel_request',2);
add('revised_chris','02-axel.json','axel_crowded_road',2);
add('revised_receipt','02-axel.json','axel_stolen_notice',2);
const schema={type:'object',required:['checks'],additionalProperties:false,properties:{checks:{type:'array',minItems:8,maxItems:8,items:{type:'object',required:['id','consistent','evidence','suggestion'],additionalProperties:false,properties:{id:{type:'string'},consistent:{type:'boolean'},evidence:{type:'string'},suggestion:{type:'string'}}}}}};
const system='각 action과 result가 서로 일치하는지 판정한다. action의 인물이 세이버인데 result가 캐스터만 등장하면 불일치다. 다크니스 선택의 결과가 크리스의 수색이면 불일치다. 크리스 선택의 결과가 아쿠아의 보급이면 불일치다. 몬스터 변화가 둘 다0인데 새로 더 위험한 의뢰를 맡았다고 쓰면 불일치다. 일치하는 사례는 consistent true, evidence와 suggestion 빈 문자열. 불일치면 evidence에 결과에서 문제인 정확한 구절만 적고 한국어1문장의 개선을 쓴다. NPC가 여러 명 있다고 무조건 불일치가 아니다. 인물 이름이 action과 같다는 이유로 불일치라고 하지 않는다. 결과에 숫자 보상을 전부 쓰거나 정확한 숫자를 반복할 필요는 없다. 새로운 원작 능력·설정·수치를 제안하지 않는다. 8개 각각 판단하고 그대로 복사한 잘못된 원문을 수정안으로 제시하지 않는다.';
fs.writeFileSync(path.join(__dirname,'semantic-contrast-03.json'),JSON.stringify({review:true,schema,system,brief:{cases}},null,2)+'\n',{flag:'wx'});
console.log('작은 대조 검토 요청을 보존했습니다.');
