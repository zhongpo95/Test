// 학원도시 세 카드 재구성 뒤 회귀 검사 및 Gemma 일곱 요청의 저장 원문을 대조한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),{spawn}=require('node:child_process');
const root=path.resolve(__dirname,'..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
async function main(){
 const commands=await Promise.all(read('validation/ci-commands-28.json').commands.map(x=>new Promise(resolve=>{const child=spawn(process.execPath,x.command.split(' ').slice(1),{cwd:process.cwd(),windowsHide:true});let stdout='',stderr='';child.stdout.on('data',d=>stdout+=d);child.stderr.on('data',d=>stderr+=d);child.on('close',exit=>resolve({command:x.command,exit,stdout,stderr}));})));
 const passed=commands.every(x=>x.exit===0);write('validation/ci-commands-29.json',{passed,commands});assert(passed);
 const endpoint='http://127.0.0.1:18765',page=await fetch(endpoint+'/');assert(page.ok);const token=(await page.text()).match(/const token = '([a-f0-9]+)'/)?.[1];assert(token);
 const records=[...[1,2,3,4].map(n=>'drafts/academy-scenes-text-91-'+n+'.json'),...[1,2,3].map(n=>'reviews/academy-card-choices-review-92-'+n+'.json')];
 const checks=[];for(const file of records){const record=read(file),response=await fetch(endpoint+'/api/records/'+record.monitorRecordId,{headers:{'X-Session-Token':token}});assert(response.ok);const d=await response.json();assert.equal(d.id,record.monitorRecordId);assert.equal(d.status,'success');assert.deepEqual(d.result.raw,record.raw);for(const k of ['brief','schema','system'])assert.deepEqual(d.input[k],record.request[k]);checks.push({file,recordId:d.id,status:d.status,inputMatches:true,rawMatches:true});}
 write('validation/monitor-content-check-29.json',{checks,limits:'입력·원문·ID·저장 성공을 대조했다. 콘텐츠 정확성·재미·밸런스 검증과 구분한다.'});
 const dominated=[];for(const file of fs.readdirSync('content/roguelite').filter(x=>x.endsWith('.json'))){const d=JSON.parse(fs.readFileSync(path.join('content/roguelite',file),'utf8'));for(const a of d.cards)for(const b of d.cards){if(a.key===b.key||a.grade!==b.grade)continue;const av=Object.fromEntries(a.effects.map(e=>[e.stat,e.value])),bv=Object.fromEntries(b.effects.map(e=>[e.stat,e.value])),keys=[...new Set([...Object.keys(av),...Object.keys(bv)])];if(keys.every(k=>(av[k]||0)>=(bv[k]||0))&&keys.some(k=>(av[k]||0)>(bv[k]||0)))dominated.push({file,stronger:a.key,weaker:b.key});}}
 write('validation/card-contrast-audit-after-93.json',{pairs:dominated,limits:'기본 효과만 성분별 비교했다. 비용·각성·조건 빈도·다른 스탯 환산·실전 밸런스는 별도다.'});assert.deepEqual(dominated,[]);
 console.log(JSON.stringify({commands:commands.length,passed,monitorCheckedRequests:checks.length,dominatedPairs:dominated.length}));
}
main().catch(e=>{console.error(e.message);process.exitCode=1;});
