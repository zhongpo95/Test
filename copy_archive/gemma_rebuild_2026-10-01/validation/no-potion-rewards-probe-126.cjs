// 활성 사건의 모든 성공·실패에서 물약 수가 유지되고 재도입 데이터가 거부되는지 검사한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto'),{execFileSync}=require('node:child_process');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');const {fresh}=require('../../../tools/check-expedition-ui.cjs'),{inspect}=require('../../../tools/check-content-candidates.cjs');
const originals=['tools/check-content-rebuild.cjs','tools/check-hunt-prototype.cjs','tools/check-content-candidates.cjs','tools/content-schema.json'].map(file=>{const bytes=execFileSync('git',['show','5e6eb08:'+file],{cwd:repo,encoding:null});return {file,sha256:crypto.createHash('sha256').update(bytes).digest('hex'),base64:bytes.toString('base64')};});
const beforePath=path.join(root,'before-potion-reward-validation-126.json');if(!fs.existsSync(beforePath))fs.writeFileSync(beforePath,JSON.stringify({sourceRevision:'5e6eb08',originals},null,2)+'\n',{flag:'wx'});
const runs=[];let removedDataCases=0;
for(const file of fs.readdirSync(path.join(repo,'content/roguelite')).filter(x=>x.endsWith('.json'))){
 const d=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite',file),'utf8'));assert.deepEqual(inspect(d).errors,[]);
 const card=(e,k)=>e.ProtoCardKey.indexOf(k),scene=(e,k)=>e.ProtoEventKey.indexOf(k);
 function enter(e,key){assert(e.ProtoEventEligible(0,scene(e,key)),key);e.ProtoOffer(0);e.ProtoCandidates[e.ExpKey(0,1)]=scene(e,key);e.ProtoAction(0,2101);assert.equal(e.ProtoSelected[0],scene(e,key));}
 function requirements(e,event){if(event.previous){const p=d.events.find(x=>x.key===event.previous);requirements(e,p);enter(e,p.key);const random=e.GetRandomInt;e.GetRandomInt=()=>event.previousChoice<0?100:1;e.ProtoResolve(0,Math.abs(event.previousChoice));e.GetRandomInt=random;e.ProtoResume(0);}if(event.requiredCard)e.ProtoGrantCard(0,card(e,event.requiredCard));}
 const bad=structuredClone(d);bad.events[0].choices[0].potions=1;assert(inspect(bad).errors.some(x=>x.reason==='사건에서 물약을 보상으로 지급하지 않음'));removedDataCases++;
 for(const event of d.events)for(const [i,b]of event.choices.entries())for(const roll of b.chance<100?[1,100]:[1]){
  assert.equal(b.potions,0);assert(!/물약/.test(b.label+b.result));
  const {e}=fresh(0,true);e.online=[true,true,false,false];for(let pid=0;pid<2;pid++){e.ProtoCodexSlot[pid]=1;e.ProtoAction(pid,2001);}e.ExpGold[0]=10000;
  if(d.world.key!=='common')e.ProtoGrantHead(0,e.ProtoHeadKey.indexOf(d.world.key));requirements(e,event);e.ExpGold[0]=10000;
  enter(e,event.key);assert(e.ProtoBranchAllowed(0,i+1));assert(!/물약/.test(e.ProtoBranchText(0,i+1)));
  const amounts=[0,1].map(pid=>e.GetItemCharges(e.PlayerItem1[pid]));e.GetRandomInt=()=>roll;e.ProtoResolve(0,i+1);
  assert.deepEqual([0,1].map(pid=>e.GetItemCharges(e.PlayerItem1[pid])),amounts);assert(!/물약/.test(e.ProtoOutcome[0]));
  const outcome=e.ProtoOutcome[0];e.ProtoResolve(0,i+1);assert.equal(e.ProtoOutcome[0],outcome);assert.deepEqual([0,1].map(pid=>e.GetItemCharges(e.PlayerItem1[pid])),amounts);
  runs.push({file,event:event.key,choice:i+1,success:roll<=b.chance,chargesUnchanged:true,repeatUnchanged:true});
 }
}
const report={passed:true,events:new Set(runs.map(x=>x.event)).size,branches:runs.length,forbiddenDataCases:removedDataCases,runs,mapCreated:false,limits:'실제 JASS 변환 함수의 모의 실행이다. 물약 사용과 회복 효과는 기존 별도 회귀로 검증한다. Warcraft·화면·실전 멀티·저장·밸런스는 미검증.'};
fs.writeFileSync(path.join(__dirname,'no-potion-rewards-probe-126.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({passed:true,events:report.events,branches:runs.length,forbiddenDataCases:removedDataCases}));
