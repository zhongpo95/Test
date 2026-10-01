// 나비저택 검토의 선택 번호 오판을 기록하고 채택 문안과 활성 데이터를 보존한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');
const data=JSON.parse(fs.readFileSync(path.join(root,'drafts/butterfly-curated-03.json'),'utf8'));
const review=JSON.parse(fs.readFileSync(path.join(root,'reviews/butterfly-review-03.json'),'utf8')).parsed;
const follow=data.events.find(e=>e.key==='kny_night_found');
const previous=data.events.find(e=>e.key===follow.previous);
assert.equal(follow.previousChoice,1);
assert.equal(previous.choices[follow.previousChoice-1].card,'kny_zenitsu');
const failure=data.events.find(e=>e.key==='kny_night_wrong'),before=failure.intro;
failure.intro='다시 나설 준비를 갖출지, 위험을 감수하고 돌파할지, 남은 길을 줄일지 정한다.';
const decisions=review.issues.map(issue=>({issue,decision:'미반영',reason:issue.key==='kny_night_found'?'previousChoice는 1부터 시작한다. +1은 젠이츠 수색의 성공, -1은 같은 행동의 실패다. Gemma는 두 번째 행동을 선택 1로 읽었지만 생성기·사건 처리·모의 실행은 첫 번째 행동으로 처리한다.':'성공 시 비용 160 지불 뒤 보수 200을 획득하며 실패에는 비용만 남는다. 결과와 손익 UI에 각각 지출·획득이 표시되므로 모순이 아니다.'}));
fs.writeFileSync(path.join(root,'revisions/butterfly-final-decision-04.json'),JSON.stringify({review:decisions,changes:[{key:failure.key,field:'intro',before,after:failure.intro,reason:'제작자의 환불 정책 설명 대신 다음 행동의 상황을 표시한다.'}],mechanicsUnchanged:true},null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'drafts/butterfly-final-04.json'),JSON.stringify(data,null,2)+'\n',{flag:'wx'});
const {inspect}=require(path.resolve(root,'../../tools/check-content-candidates.cjs'));
assert.deepEqual(inspect(data).errors,[]);
fs.writeFileSync(path.resolve(root,'../../content/roguelite/13-butterfly.json'),JSON.stringify(data,null,2)+'\n',{flag:'wx'});
console.log('나비저택 머리 1종·카드 6장·사건 3개 채택. 오판 2개는 이유와 함께 보존.');
