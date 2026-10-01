// 세 카드의 교체 뒤 기존 검사와 Gemma 상세 기록의 원문 일치를 저장한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),{spawn}=require('node:child_process');
const root=path.resolve(__dirname,'..');
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
async function main(){
 const old=JSON.parse(fs.readFileSync(path.join(__dirname,'ci-commands-18.json'),'utf8'));
 const commands=await Promise.all(old.commands.map(x=>new Promise(resolve=>{const args=x.command.split(' ').slice(1),child=spawn(process.execPath,args,{cwd:process.cwd(),windowsHide:true});let stdout='',stderr='';child.stdout.on('data',d=>stdout+=d);child.stderr.on('data',d=>stderr+=d);child.on('close',exit=>resolve({command:x.command,exit,stdout,stderr}));})));
 const passed=commands.every(x=>x.exit===0);write('validation/ci-commands-19.json',{passed,commands});assert(passed);
 const record=JSON.parse(fs.readFileSync(path.join(root,'reviews/card-contrast-review-47.json'),'utf8'));
 const endpoint='http://127.0.0.1:18765',page=await fetch(endpoint+'/');assert(page.ok);const token=(await page.text()).match(/const token = '([a-f0-9]+)'/)?.[1];assert(token);
 const response=await fetch(endpoint+'/api/records/'+record.monitorRecordId,{headers:{'X-Session-Token':token}});assert(response.ok);const d=await response.json();
 assert.equal(d.id,record.monitorRecordId);assert.equal(d.status,'success');assert.deepEqual(d.result.raw,record.raw);for(const k of ['brief','schema','system'])assert.deepEqual(d.input[k],record.request[k]);
 write('validation/monitor-content-check-19.json',{checks:[{file:'reviews/card-contrast-review-47.json',recordId:d.id,status:d.status,inputMatches:true,rawMatches:true}],limits:'기록 API의 입력·원문·ID·성공 상태를 대조했다. 저장 성공과 콘텐츠 정확성·재미·밸런스는 별개다.'});
 console.log(JSON.stringify({commands:commands.length,passed,monitorCheckedRequests:1}));
}
main().catch(e=>{console.error(e.message);process.exitCode=1;});
