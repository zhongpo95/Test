// 실제 개인 사건 UI의 모의 프레임과 표시 문자열을 정적 미리보기 입력으로 추출한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),os=require('node:os'),assert=require('node:assert/strict');
const {fresh}=require('./check-expedition-ui.cjs');
const scenes=[];
function capture(t,name){
  const position=id=>{const f=t.frame(id);if(id===0)return {x:0,y:0,priority:0};const p=position(f.relative??f.parent);return {x:(f.absolute?0:p.x)+(f.x||0),y:(f.absolute?.6:p.y)-(f.y||0),priority:f.priority??p.priority};};
  scenes.push({name,frames:[...t.frames.values()].filter(f=>f.id>0&&t.visible(f.id)&&['BACKDROP','TEXT'].includes(f.type)).map(f=>({...f,...position(f.id)}))});
}
let t=fresh(0,true),e=t.e;t.click(t.common(-98));capture(t,'start');t.start();e.ExpGold[0]=1000;
e.ProtoGrantHead(0,e.ProtoHeadKey.indexOf('academy'));e.ProtoGrantHead(0,e.ProtoHeadKey.indexOf('penacony'));
for(const [name,keys] of [['candidates-3',['academy_bad_signal','common_fur_scale','hsr_dreamy_slots']],['candidates-4',['academy_bad_signal','common_fur_scale','hsr_dreamy_slots','common_five_coin']]]){
  e.ProtoChoices[0]=keys.length;e.ProtoOffer(0);
  keys.forEach((key,i)=>{const id=e.ProtoEventKey.indexOf(key);assert(id>0,key);assert(e.ProtoEventEligible(0,id),key);e.ProtoCandidates[i+1]=id;});t.render();capture(t,name);
}
e.ProtoSelected[0]=e.ProtoEventKey.indexOf('common_fur_scale');e.ProtoStage[0]=2;t.render();capture(t,'actions-4');
for(let id=e.PROTO_CARD_FIRST;id<e.PROTO_CARD_FIRST+24;id++)e.ProtoGrantCard(0,id);
e.ProtoGrantEventCard(0,e.PROTO_CARD_FIRST);e.ProtoRefreshStats(0);e.ExpUIOpen(e.EXP_UI_STATS);t.render();capture(t,'stats');
t.click(e.ExpUIButtons[e.UIPrototypeStatus_Cells[22]]);capture(t,'cards');
t.event(e.UIPrototypeStatus_Hotspots[18],2);t.render();capture(t,'cards-hover');
const output=process.argv[2]||path.join(os.tmpdir(),'arcana-hunt-ui-frames.json');fs.writeFileSync(output,JSON.stringify(scenes));console.log(output);
