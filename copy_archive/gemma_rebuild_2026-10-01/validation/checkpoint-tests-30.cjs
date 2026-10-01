// 행동력 변경 뒤 회귀 명령과 Gemma 요청·응답 저장 기록을 대조한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),{spawn}=require('node:child_process');const root=path.resolve(__dirname,'..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));const save=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
async function main(){
 const list=read('validation/ci-commands-29.json').commands.map(x=>x.command).concat('node tools/check-event-action-options.cjs');
 const commands=await Promise.all(list.map(command=>new Promise(resolve=>{const child=spawn(process.execPath,command.split(' ').slice(1),{cwd:process.cwd(),windowsHide:true});let stdout='',stderr='';child.stdout.on('data',d=>stdout+=d);child.stderr.on('data',d=>stderr+=d);child.on('close',exit=>resolve({command,exit,stdout,stderr}));})));
 const passed=commands.every(c=>c.exit===0);save('validation/ci-commands-30.json',{passed,commands});assert(passed,JSON.stringify(commands.filter(c=>c.exit!==0)));
 const base='http://127.0.0.1:18765',page=await fetch(base+'/');assert(page.ok);const token=(await page.text()).match(/const token = '([a-f0-9]+)'/)?.[1];assert(token);
 const records=['drafts/action-scenes-text-95.json','reviews/action-scenes-review-96.json','reviews/action-scenes-review-97.json'],checks=[];
 for(const file of records){const r=read(file),res=await fetch(base+'/api/records/'+r.monitorRecordId,{headers:{'X-Session-Token':token}});assert(res.ok);const d=await res.json();assert.equal(d.id,r.monitorRecordId);assert.equal(d.status,'success');assert.deepEqual(d.result.raw,r.raw);for(const k of ['brief','schema','system'])assert.deepEqual(d.input[k],r.request[k]);checks.push({file,recordId:d.id,status:d.status,inputMatches:true,rawMatches:true});}
 save('validation/monitor-content-check-30.json',{checks,limits:'원문·입력·기록ID·저장성공의대조다. 내용정확성·재미·밸런스·실게임증명과구분한다.'});
 const counts={heads:0,cards:0,events:0,roots:0,followups:0,free:[],requiredCard:[],threeChoiceEvents:0,directGoldChoices:0};
 for(const file of fs.readdirSync('content/roguelite').filter(x=>x.endsWith('.json'))){const d=JSON.parse(fs.readFileSync(path.join('content/roguelite',file),'utf8'));if(d.world.key!=='common')counts.heads++;counts.cards+=d.cards.length;counts.events+=d.events.length;for(const e of d.events){counts[e.previous?'followups':'roots']++;if(e.actionCost===0)counts.free.push(e.key);if(e.requiredCard)counts.requiredCard.push({event:e.key,card:e.requiredCard});if(e.choices.length===3)counts.threeChoiceEvents++;counts.directGoldChoices+=e.choices.filter(c=>c.gold>0).length;}}
 save('validation/action-options-check-30.json',{...counts,commands:commands.length,records:checks.length,normalCost:1,defaultCandidates:3,maxCandidates:4,statKinds:25,limits:'모의실행과정적데이터집계다. 시각·Warcraft·멀티·저장·재미·실전밸런스는미검증.'});console.log(JSON.stringify({passed,commands:commands.length,records:checks.length,...counts}));
}
main().catch(e=>{console.error(e.message);process.exitCode=1;});
