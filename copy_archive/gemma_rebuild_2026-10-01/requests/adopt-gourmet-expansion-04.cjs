// 미식전 독립 사건 확장을 검사한 뒤 원본을 보존하고 활성 데이터에 반영한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const file=path.join(repo,'content/roguelite/14-gourmet.json');
const candidate=JSON.parse(fs.readFileSync(path.join(root,'revisions/gourmet-expansion-curated-04.json'),'utf8'));
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);
if(check.errors.length)throw Error(JSON.stringify(check.errors));
const old=fs.readFileSync(file),backup=path.join(root,'before-gourmet-expansion-04.json');
fs.writeFileSync(backup,old,{flag:'wx'});
const review=JSON.parse(fs.readFileSync(path.join(root,'reviews/gourmet-expansion-review-04.json'),'utf8')).parsed;
fs.writeFileSync(path.join(root,'revisions/gourmet-expansion-decision-04.json'),JSON.stringify({sourceRevision:'a6b6402',beforeFile:path.relative(repo,backup).replaceAll('\\','/'),beforeSha256:crypto.createHash('sha256').update(old).digest('hex'),review,decision:'3개 새 독립 사건과 관련 카드3개 채택. 기존 사건3개·카드6개·머리효과 유지.',reasons:['청소·채집 지도·학교 모임 준비라는 서로 다른 공식 소재에서 별도 문제를 구성했다.','세 사건은 이전 행동·특정 카드 조건 없이 머리 소지 시 독립적으로 등장한다.','비용·개인 필드 변화·확률 실패와 지정 보상이 구현된 사건 함수를 따른다.'],limits:['Gemma 지적 없음은 재미·실제 Warcraft·원작 전수 검증의 증거가 아니다.','아오이 학교 적응과 일반 길드 활동만 확인했고 새로운 초대장·물건·수치는 창작이다.'],candidateCheck:check},null,2)+'\n',{flag:'wx'});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');
console.log(JSON.stringify({head:candidate.world.name,cards:candidate.cards.length,events:candidate.events.length,roots:candidate.events.filter(e=>!e.previous).length,check}));
