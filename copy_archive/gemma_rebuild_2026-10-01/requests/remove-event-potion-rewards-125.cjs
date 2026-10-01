// 활성 사건과 집필 대기 중인 페나코니의 물약 보상을 원본 보존 후 제거한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const save=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const originals=[],changes=[];const docs=[];
for(const file of fs.readdirSync(path.join(repo,'content/roguelite')).filter(x=>x.endsWith('.json'))){const bytes=fs.readFileSync(path.join(repo,'content/roguelite',file)),d=JSON.parse(bytes);originals.push({file,sha256:crypto.createHash('sha256').update(bytes).digest('hex'),base64:bytes.toString('base64')});docs.push({file,d});}
const fixedPath=path.join(root,'requests/penacony-card-choices-fixed-124.json'),fixedBytes=fs.readFileSync(fixedPath),fixed=JSON.parse(fixedBytes);originals.push({file:'requests/penacony-card-choices-fixed-124.json',sha256:crypto.createHash('sha256').update(fixedBytes).digest('hex'),base64:fixedBytes.toString('base64')});
const beforePath=path.join(root,'before-event-potion-rewards-125.json');
if(fs.existsSync(beforePath))assert.deepEqual(JSON.parse(fs.readFileSync(beforePath,'utf8')),{sourceRevision:'5e6eb08',originals});else save('before-event-potion-rewards-125.json',{sourceRevision:'5e6eb08',originals});
const leftover=[];
function clean(data,file){
 for(const e of data.events)for(const [i,c]of e.choices.entries()){
  if(c.potions>0||/물약/.test(c.label+c.result))changes.push({file,event:e.key,choice:i+1,original:structuredClone(c)});
  c.potions=0;
  c.result=c.result.replace(/(?:보급\s*)?물약\s*[0-9]+개를 받았다\.\s*/g,'');
  c.label=c.label.replace('식사와 물약 준비','식사 준비').replace('보수와 보급 물약','보수').replace('작업 보수와 물약','작업 보수').replace('보수와 물약','보수').replace('일당과 물약','일당');
  c.result=c.result.replace(/와 (?:보급\s*)?물약\s*[0-9]+개를 받았다/g,'를 받았다').replace(/와 (?:보급용\s*|보급\s*)?물약(?: 한 개)?을 받았다/g,'를 받았다').replace('보급 물약도 챙겼다. ','').replace('그리고 물약 하나를 받았다','').replace('보급 물약 하나를 받았다','보급 준비를 마쳤다');
 }
 const set=(key,i,field,value)=>{const e=data.events.find(x=>x.key===key);if(e)e.choices[i-1][field]=value;};
 set('common_lost_address',2,'result','추가 자재비를 내고 연락 지점의 통로 하나를 닫았다. 맡을 적 수를 줄이고 남은 연락 장소의 준비를 정리했다.');
 set('common_nazrin_found',3,'result','울타리 자재를 사서 위험한 길 한 곳을 닫았다. 강한 구역 하나를 덜 맡게 되었지만 다른 수색 길의 적은 남았다.');
 set('axel_priest_supply',1,'result','아쿠아가 다음 모험의 건강을 기원했다. 천천히 이어지는 축복의 기억을 얻었다.');
 if(file==='11-penacony.json'){
  set('hsr_view_without_armor',3,'label','갑옷을 요구하지 않고 맡을 안내 길목을 줄인다');
  set('hsr_view_without_armor',3,'result','갑옷을 보여 달라는 요구를 거들지 않고 맡을 안내 길목을 줄였다. 개인 사냥의 적 수를 줄였다. 반디는 안내에 남은 풍경을 보고 있고 관광객은 다음 질문을 고르고 있다.');
  set('hsr_name_over_song',3,'result','시작 안내를 전달한 보수로 60골드를 받았고 개인 사냥의 적 수를 줄였다. 네 안내를 들은 뒤편 관객이 앞줄까지 준비됐다는 말을 다시 전한다. 로빈은 아직 노래를 시작하지 않고 마지막 답을 듣는다.');
  set('hsr_name_after_poster',3,'result','맡을 안내 자리를 줄이고 보수 80골드를 받았으며 개인 사냥의 적 수를 줄였다. 참가자에게 잘못 붙은 자리 표시를 직접 보여 주었다. 로빈은 참가자가 자기 자리를 다시 알릴 때까지 곁에서 듣는다.');
 }
 set('fma_ling_lunch',3,'result','보급에 100골드를 썼다. 맡을 길목을 한 곳 줄여 개인 사냥의 적 수를 줄였다. 린의 식사비는 식탁 위에 남겨 두었다.');
 set('fma_pie_delivery',1,'result','포장과 연락에 120골드를 쓰고 겹친 이름을 구분할 수 있었다. 휴즈와 놓친 부분을 한 번 더 살피는 요령을 배우고 준비 작업 보수 200골드를 받았다. 그레이시아는 표시가 나뉜 상자부터 따로 놓는다.');
 set('pc_after_portions',2,'card','pc_kokkoro_notes');
 set('pc_after_portions',2,'result','남겨 둔 식사를 건네고 포장 재료에 120골드를 썼다. 콧코로와 떠날 일행의 몫을 목록에 나눠 적는 요령을 익혔다. 페코린느는 비어 있는 네 그릇을 보고 다음 끼니를 다시 묻는다.');
 set('pc_faded_spice_map',4,'result','채집은 맡지 않고 의뢰처의 보급품 정리를 도와 정리 보수를 받았다. 흐린 지도와 그 길의 재료는 직접 확인하지 못했다.');
 set('pc_dusty_room',3,'result','맡을 길목 하나를 다른 일행에게 넘겼다. 정리는 필요한 만큼만 마쳤고 안쪽 상자는 남겨 두었다. 내 구역의 적 수는 줄지만 적이 없어지지는 않는다.');
 set('pc_tea_invitation',3,'result','보급 정리를 도왔다. 오늘 맡을 길목을 한 곳 줄여 내 구역의 적 수도 줄었다. 아오이의 첫 인사는 대신하지 않고 모임 안내는 다른 사람에게 맡긴다.');
 set('pc_witness_hours',2,'result','포장 비용을 내고 확인할 길목 하나를 덜어 보급을 다시 묶었다. 개인 사냥의 적 수를 줄였다. 남은 진술의 대조는 카스미에게 맡긴다.');
 set('pc_monica_market_watch',3,'result','보급 비용을 내고 강한 적이 드나들던 길을 맡을 범위에서 덜었다. 개인 사냥의 적 단계가 내려갔다. 남은 경계는 다른 사람에게 맡긴다.');
 for(const e of data.events){assert(e.choices.every(c=>c.potions===0));for(const c of e.choices)if(/물약/.test(c.label+c.result))leftover.push({file,event:e.key,label:c.label,result:c.result});}
 data.canonBoundary+=' 사건 선택의 물약 보상은 전부 없앴다. 보급·식사·음료의 서사는 카드 기억 또는 필드 준비이며 물약 지급이나 즉시 체력 회복이 아니다.';
 const result=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(data);assert.deepEqual(file==='pending-penacony'?result.errors.filter(x=>x.reason!=='행동과 결과 문장이 필요함'):result.errors,[],file);
 return data;
}
for(const x of docs)clean(x.d,x.file);clean(fixed.data,'pending-penacony');assert.deepEqual(leftover,[]);
fixed.removedPotions=changes.filter(x=>x.file==='pending-penacony');fixed.policy.cost+=' 물약 보상은 전부0이다.';
save('revisions/event-potion-rewards-decision-125.json',{userInstruction:'물약보상도 전부 제거해줘',sourceRevision:'5e6eb08',activeChoicesRemoved:changes.filter(x=>x.file!=='pending-penacony'&&x.original.potions>0).length,pendingChoicesRemoved:changes.filter(x=>x.file==='pending-penacony'&&x.original.potions>0).length,changes,decision:'물약 사용·소모품 효과와 흡수/재생은 유지한다. 사건 물약 지급과 해당 안내만 제거한다. 물약만 남았던 미식전 식사 전달은 기존 콧코로 목록 카드로 바꾸어 비용만 지불하는 빈 선택을 막는다. 아직 호출하지 않은124집필 요청은 보상 변경으로 폐기 보존하고125요청으로 대체한다.',discardReason:'물약은 사건 보상에서 제외한다는 사용자 지시다. 기존 물약 보상의 신규 제안/재도입은 하지 않는다.',revisit:'사용자가 물약 보상 재도입을 명시했을 때만.'});
for(const {file,d}of docs)fs.writeFileSync(path.join(repo,'content/roguelite',file),JSON.stringify(d,null,2)+'\n');
save('requests/penacony-card-choices-fixed-125.json',fixed);
for(let n=1;n<=4;n++){const r=JSON.parse(fs.readFileSync(path.join(root,'requests/penacony-scenes-text-124-'+n+'.json'),'utf8'));r.brief.events=r.brief.events.map(e=>{const {failure,...current}=fixed.data.events.find(x=>x.key===e.key);return {...current,choices:current.choices.map(({result,...c},i)=>({index:i+1,...c}))};});r.brief.cards=fixed.data.cards;r.brief.policy=fixed.policy;r.brief.rules.push('물약 보상은 모든 선택에서0이며 물약을 받거나 즉시 치유되는 결과를 쓰지 않는다. 보급은 서사상의 준비다.');save('requests/penacony-scenes-text-125-'+n+'.json',r);}
console.log(JSON.stringify({activeRemoved:changes.filter(x=>x.file!=='pending-penacony'&&x.original.potions>0).length,pendingRemoved:fixed.removedPotions.filter(x=>x.original.potions>0).length,files:docs.length}));
