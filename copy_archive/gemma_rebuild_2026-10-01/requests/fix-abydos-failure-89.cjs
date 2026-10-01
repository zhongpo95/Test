// 아비도스 역검토가 놓친 삭제된 골드 보수의 실패 문구를 제거하고 해당 사건만 다시 검토한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const candidate=read('revisions/abydos-card-choices-curated-88.json'),event=candidate.events.find(e=>e.key==='abydos_antique_note'),before=event.failure;
assert(event.choices.every(c=>c.gold===0));assert(before.includes('카드와 기록 확인 보수도 받지 못한다.'));
event.failure=before.replace('카드와 기록 확인 보수도 받지 못한다.','카드는 받지 못한다.');
write('revisions/abydos-card-choices-curated-89.json',candidate);
write('revisions/abydos-card-choices-curation-89.json',{event:event.key,before,after:event.failure,reason:'기록 확인의 직접 골드를 없앴는데 실패문구가 그 보수를 기대하게 하는 문제가 남았다. Gemma88 세PASS가 이를 놓쳐 Codex 데이터대조로 수정했다.',mechanicsChanged:false,revisit:'모델PASS만으로 승인하지 않고 성공/실패의 지급·삭제 문구를 함께 검사한다.'});
const request=read('requests/abydos-card-choices-review-88-2.json'),refs=new Set(event.choices.map(c=>c.card));request.brief.cards=candidate.cards.filter(c=>refs.has(c.key));request.brief.events=[event];request.brief.checks.push('삭제한 기록 확인 골드를 성공이나 실패의 보수로 기대하게 하는 문구가 남아 있는가?');
write('requests/abydos-failure-review-89.json',request);
console.log(JSON.stringify({changedFailure:1,mechanicsChanged:false}));
