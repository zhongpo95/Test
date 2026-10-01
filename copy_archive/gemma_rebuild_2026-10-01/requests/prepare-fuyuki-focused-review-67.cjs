// 실제 피해 함수와 랜서 설명의 이동속도 정정을 이전 잘못된 검토 기준과 구분해 재검토한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const candidate=read('revisions/fuyuki-expansion-curated-66.json'),event=candidate.events.find(e=>e.key==='fy_after_one_block'),card=candidate.cards.find(c=>c.key==='fy_lancer_second');
const request={review:true,schema:read('requests/fuyuki-expansion-review-64.json').schema,system:'한국어 독립 검토자다. 제공한 실제 JASS 함수와 표시·예시를 기준으로 카드와 사건 결과의 실제 불일치만 검토한다. 이전 이동중이라는 기준은 잘못되었으니 따르지 않는다. 스탯이나 필드 수치를 바꾸지 말고 PASS 또는 REVISE로 판단한다.',brief:{card,event,evidence:read('revisions/fuyuki-moving-correction-66.json').evidence,mechanics:{moving:'moving_damage는 기본400에서 추가된 이동속도 비례 가하는 피해다. 이동 여부 조건이 아니다. 추가속도40%에서12%전부 적용된다.',field:'이 사건 선택지2의level+1은 이후 개인사냥의적강함단계다. moving카드가 이동속도스탯을 새로 더하는 효과는 없다.',penetration:'penetration4는방어관통4%다. 원작 필중·즉사기술이 아니다.',shielded:'선택지1의shielded_damage는이미보호막있을때피해이며새보호막은없다.'},checks:['결과의추가이동속도에따른피해가코드와다른가?','이동속도자체상승·움직일때만발동·새돌진·자동방패를약속하는가?','400/480/560예시의0/6/12가식과다른가?']}};
fs.writeFileSync(path.join(root,'requests/fuyuki-focused-review-67.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});console.log('랜서실제함수집중검토저장.');
