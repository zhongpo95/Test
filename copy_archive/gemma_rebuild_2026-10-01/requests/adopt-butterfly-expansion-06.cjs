// 나비저택 검토 후보의 카드 이름을 다듬고 원본 보존 후 활성 풀에 반영한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const candidate=JSON.parse(fs.readFileSync(path.join(root,'revisions/butterfly-expansion-curated-05.json'),'utf8'));
const names={kny_aoi_supply:['필요한 몫을 먼저','재생 · 처치 골드'],kny_kanao_quiet:['발이 움직이기 전에','이동 · 치명 확률'],kny_tanjiro_smell:['겹친 흔적 사이','방향 적중 · 관통'],kny_shinobu_points:['상대를 먼저 알기','관통 · 보스'],kny_zenitsu_listen:['소리 사이의 한순간','차지 속도 · 보스'],kny_inosuke_terrain:['먼저 발을 내딛는 길','이동 · 일반 적']};
const changes=[];
for(const [key,[effectName,keyword]]of Object.entries(names)){const c=candidate.cards.find(x=>x.key===key);changes.push({key,before:{effectName:c.effectName,keyword:c.keyword},after:{effectName,keyword},reason:'스탯 열 이름을 그대로 붙인 초안 대신 사건의 준비·인물 태도를 담고 실제 옵션 단위를 키워드에 남긴다.'});c.effectName=effectName;c.keyword=keyword;}
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);if(check.errors.length)throw Error(JSON.stringify(check.errors));
fs.writeFileSync(path.join(root,'revisions/butterfly-expansion-curated-06.json'),JSON.stringify(candidate,null,2)+'\n',{flag:'wx'});
const file=path.join(repo,'content/roguelite/13-butterfly.json'),old=fs.readFileSync(file),backup=path.join(root,'before-butterfly-expansion-06.json');
fs.writeFileSync(backup,old,{flag:'wx'});
const review=JSON.parse(fs.readFileSync(path.join(root,'reviews/butterfly-expansion-review-05.json'),'utf8')).parsed;
fs.writeFileSync(path.join(root,'revisions/butterfly-expansion-decision-06.json'),JSON.stringify({sourceRevision:'a6b6402',beforeFile:path.relative(repo,backup).replaceAll('\\','/'),beforeSha256:crypto.createHash('sha256').update(old).digest('hex'),review,changes,decision:'6개 새 독립 사건·관련 카드6개 채택. 반복 사건3개와 원안 출력 오류는 별도 제외 이유와 원문 보존.',reviewLimits:['Gemma는 05후보에서 지적 없음. 이후 06은 카드 효과 이름·키워드만 편집했으며 숫자·사건·참조를 바꾸지 않았다.','실제 Warcraft·화면·멀티플레이·성능·재미·밸런스 검증은 아니다.'],candidateCheck:check},null,2)+'\n',{flag:'wx'});
fs.writeFileSync(file,JSON.stringify(candidate,null,2)+'\n');
console.log(JSON.stringify({head:candidate.world.name,cards:candidate.cards.length,events:candidate.events.length,roots:candidate.events.filter(e=>!e.previous).length,check}));
