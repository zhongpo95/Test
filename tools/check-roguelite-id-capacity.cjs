// 콘텐츠 추가 시 기존 ID 보존, 네 플레이어의 키 분리와 입장 사건 연결을 검증한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const {allocateIds,generate}=require('./generate-prototype-content.cjs');
const {fresh}=require('./check-expedition-ui.cjs');
const root=path.resolve(__dirname,'..'), read=p=>fs.readFileSync(path.join(root,p),'utf8');
const registry=JSON.parse(read('content/roguelite-id-registry.json'));
const worlds=fs.readdirSync(path.join(root,'content/roguelite')).filter(f=>f.endsWith('.json')).sort()
  .map(f=>JSON.parse(read('content/roguelite/'+f)));
let checks=0;
function check(name,fn){fn();checks++;console.log('PASS '+name);}
const baseline={
  heads:{last:13,count:13,hash:'a24560141d0c02c345781517d5f91a4714c3e5bcc98f6588bdb250901427bd0a'},
  cards:{last:936,count:924,hash:'b77051f97ffdbd1f4f4fa8428cfa4741f2cb2f2d2b5af4aae2b657c01780889c'},
  events:{last:493,count:493,hash:'b1df7a0fc18d940d311ac071f0aba0ef7a089b7dcc7834ccf491901918b38f25'}
};
const fixture=(key,cards=1,events=1)=>({world:{key},cards:Array.from({length:cards},(_,i)=>({key:key+'_card_'+i})),events:Array.from({length:events},(_,i)=>({key:key+'_event_'+i}))});
check('확장 이전 머리 13개·카드 924개·사건 493개의 ID 고정',()=>{
  for(const [kind,b] of Object.entries(baseline)){
    const pairs=Object.entries(registry[kind]).filter(([,id])=>id<=b.last).sort((a,b)=>a[1]-b[1]);
    assert.equal(pairs.length,b.count);
    assert.equal(crypto.createHash('sha256').update(JSON.stringify(pairs)).digest('hex'),b.hash,kind+' 기존 ID 변경');
  }
  const catalog=read('Data/Data_PrototypeCatalog.j');
  for(const [kind,field] of [['heads','ProtoHeadKey'],['cards','ProtoCardKey'],['events','ProtoEventKey']]){
    const actual=Object.fromEntries([...catalog.matchAll(new RegExp('set '+field+'\\[(\\d+)\\] = "([^"]+)"','g'))].map(m=>[m[2],Number(m[1])]));
    assert.deepEqual(actual,registry[kind],kind+' 생성 결과와 등록 불일치');
  }
  assert.equal(catalog.replace(/\r\n/g,'\n'),generate(worlds));
});
check('원고 순서와 엔딩 카드 위치에 영향받지 않고 신규 키만 말미 배정',()=>{
  const added=fixture('capacity_append',3,2), before=JSON.stringify(registry);
  added.cards[0].endingCard=true;
  const expanded=allocateIds([added,...worlds].reverse(),registry);
  assert.equal(JSON.stringify(registry),before,'기존 등록 객체 변경');
  for(const kind of ['heads','cards','events'])for(const [key,id] of Object.entries(registry[kind]))assert.equal(expanded[kind][key],id);
  assert.equal(expanded.cards.capacity_append_card_0,Math.max(...Object.values(registry.cards))+1);
  assert.equal(expanded.events.capacity_append_entry_0,Math.max(...Object.values(registry.events))+1);
  assert.equal(expanded.events.capacity_append_event_0,expanded.events.capacity_append_entry_0+4);
  const more=fixture('capacity_append_later');
  const twice=allocateIds([...worlds,added,more],expanded);
  for(const kind of ['heads','cards','events'])for(const [key,id] of Object.entries(expanded[kind]))assert.equal(twice[kind][key],id);
});
check('카드 원고 순서를 바꾸어도 서사 변화가 런타임의 같은 대표 캐릭터에 연결됨',()=>{
  const reversed=structuredClone(worlds);
  for(const world of reversed)world.cards.reverse();
  const links=text=>[...text.matchAll(/set ProtoStoryChangeCharacter\[(\d+)\] = (\d+)/g)].map(m=>[Number(m[1]),Number(m[2])]);
  const expected=links(generate(worlds)),actual=links(generate(reversed));
  assert(expected.length>0);assert.deepEqual(actual,expected);
  const e=fresh(0,true).e;
  for(const [,character] of actual)assert.equal(e.ProtoCardCharacter[character],character,'대표 카드가 아닌 보상 카드에 서사 변화 연결');
});
check('2047번까지 허용하고 2048번 카드·사건 및 훼손된 등록은 거부',()=>{
  const lastCard=Math.max(...Object.values(registry.cards)),lastEvent=Math.max(...Object.values(registry.events));
  const fill=fixture('capacity_limit',2047-lastCard,2047-lastEvent-4);
  const limit=allocateIds([...worlds,fill],registry);
  assert.equal(Math.max(...Object.values(limit.cards)),2047);
  assert.equal(Math.max(...Object.values(limit.events)),2047);
  const tooManyCards=structuredClone(fill);tooManyCards.cards.push({key:'capacity_extra_card'});
  assert.throws(()=>allocateIds([...worlds,tooManyCards],registry),/cards 최대 2047/);
  const tooManyEvents=structuredClone(fill);tooManyEvents.events.push({key:'capacity_extra_event'});
  assert.throws(()=>allocateIds([...worlds,tooManyEvents],registry),/events 최대 2047/);
  const duplicate=structuredClone(registry);duplicate.cards[Object.keys(duplicate.cards)[1]]=13;
  assert.throws(()=>allocateIds(worlds,duplicate),/연속성 오류/);
  assert.throws(()=>allocateIds(worlds.slice(1),registry),/등록된 콘텐츠 키를 제거/);
  assert.throws(()=>allocateIds([...worlds,fixture(worlds[0].world.key)],registry),/key 중복/);
});
check('네 플레이어의 8192개 키 및 사건 분기 최댓값이 충돌하지 않음',()=>{
  const e=fresh(0,true).e,used=new Set();
  for(let pid=0;pid<4;pid++)for(let id=0;id<=2047;id++){
    const key=e.ExpKey(pid,id);
    assert(key>=0&&key<8192);
    assert(!used.has(key));used.add(key);
    assert.equal(e.ProtoStoryKey(pid,id),key);
  }
  assert.equal(used.size,8192);
  assert.equal(e.ExpKey(3,2047),8191);
  assert.equal(e.ProtoChoiceKey(2047,4),8191);
});
check('숫자 위치와 무관한 신규 입구가 소유 플레이어에게만 열리고 행동력은 무료',()=>{
  const t=fresh(0,true),e=t.e;t.start();
  const head=e.PROTO_HEAD_COUNT+1,first=e.PROTO_EVENT_COUNT+1;
  e.PROTO_HEAD_COUNT=head;e.PROTO_EVENT_COUNT+=4;e.ProtoHeadKey[head]='capacity_entry';e.ProtoHeadEntryCard[head]=e.PROTO_CARD_FIRST;
  for(let pid=0;pid<4;pid++){
    const event=first+pid;
    e.ExpMember[pid]=true;e.ProtoAP[pid]=20;e.ProtoHeadCount[pid]=0;
    e.ProtoHeadEntryEvent[head*4+pid]=event;
    e.ProtoEventHead[event]=head;e.ProtoEventKind[event]=0;e.ProtoEventChoices[event]=1;e.ProtoEventAPCost[event]=0;
  }
  for(let pid=0;pid<4;pid++)for(let owner=0;owner<4;owner++)assert.equal(e.ProtoEventEligible(pid,first+owner),pid===owner);
  const ap=e.ProtoAP[0];e.ProtoStage[0]=1;e.ProtoCandidates[e.ExpKey(0,1)]=first;
  e.ProtoAction(0,2101);
  assert.equal(e.ProtoAP[0],ap);assert.equal(e.ProtoHeadCount[0],1);assert(e.ProtoHeadOwned[e.ExpKey(0,head)]);
  assert.equal(e.ProtoEventEligible(1,first+1),true,'다른 플레이어 입구 소진');
  e.ProtoHeadCount[1]=2;assert.equal(e.ProtoEventEligible(1,first+1),false,'머리 최대 2장 위반');
});
check('2047번 카드의 보상·각성 기록이 다른 플레이어의 낮은 번호와 겹치지 않음',()=>{
  const t=fresh(0,true),e=t.e;t.start();
  e.ProtoCardCharacter[2047]=2047;e.ProtoCardGrade[2047]=1;e.ProtoCardName[2047]='용량 검증 카드';e.ProtoCardKey[2047]='capacity_reward';
  e.ProtoEvolutionKind[2047]=1;e.ProtoEvolutionGoal[2047]=10;e.ProtoSetEffect(2047,e.PROTO_STAT_ATTACK,7,false);
  for(let pid=0;pid<4;pid++){
    e.ExpMember[pid]=true;e.ProtoOutcome[pid]='';e.ProtoGrantCard(pid,2047);
    assert.equal(e.ProtoRewardCopies[e.ExpKey(pid,2047)],1);
    assert.equal(e.ProtoStat(pid,e.PROTO_STAT_ATTACK),7);
    if(pid<3)assert.equal(e.ProtoRewardCopies[e.ExpKey(pid+1,1023)],0,'옛 1024 간격으로 보상 이력 침범');
  }
  e.ProtoKill(0);
  assert.equal(e.ProtoCardProgress[e.ExpKey(0,2047)],1);
  for(let pid=1;pid<4;pid++)assert.equal(e.ProtoCardProgress[e.ExpKey(pid,2047)],0);
});
check('등록된 모든 지역의 네 입구에서 머리·입문 카드·무료 행동력·문자열 도감 저장이 일치함',()=>{
  const t=fresh(0,true),e=t.e;t.start();
  const entries=new Set();
  for(let pid=0;pid<4;pid++)e.ExpMember[pid]=true;
  for(let head=1;head<=e.PROTO_HEAD_COUNT;head++){
    const card=e.ProtoHeadEntryCard[head];assert(card>=e.PROTO_CARD_FIRST&&card<=e.PROTO_CARD_LAST);
    for(let pid=0;pid<4;pid++){
      const id=e.ProtoHeadEntryEvent[head*4+pid];
      assert(id>0&&id<=e.PROTO_EVENT_COUNT);assert(!entries.has(id));entries.add(id);
      assert.equal(e.ProtoEventKey[id],e.ProtoHeadKey[head]+'_entry_'+pid);
      assert.equal(e.ProtoEventHead[id],head);assert.equal(e.ProtoEventKind[id],0);
      e.ProtoHeadCount[pid]=0;e.ProtoAP[pid]=20;
      for(let owner=0;owner<4;owner++)assert.equal(e.ProtoEventEligible(pid,e.ProtoHeadEntryEvent[head*4+owner]),owner===pid);
      e.localPlayer=pid;e.ProtoStage[pid]=1;e.ProtoCandidates[e.ExpKey(pid,1)]=id;
      const copies=e.ProtoRewardCopies[e.ExpKey(pid,card)];
      e.ProtoAction(pid,2101);
      assert.equal(e.ProtoAP[pid],20);assert.equal(e.ProtoHeadCount[pid],1);
      assert.equal(e.ProtoHeadOwned[e.ExpKey(pid,head)],true);
      assert.equal(e.ProtoRewardCopies[e.ExpKey(pid,card)],copies+1);
      assert.equal(e.StashLoad(e.PLAYER_DATA[pid],e.PROTO_SAVE_PREFIX+'머리도감.'+e.ProtoHeadKey[head],''),'1');
      assert.equal(e.StashLoad(e.PLAYER_DATA[pid],e.PROTO_SAVE_PREFIX+'카드도감.'+e.ProtoCardKey[card],''),'1');
    }
  }
  assert.equal(entries.size,e.PROTO_HEAD_COUNT*4);
  // 마지막 지역까지 실제 저장 키로 읽은 패킷을 동기화해 숫자 ID 변경과 저장 형식의 분리를 확인한다.
  for(let pid=0;pid<4;pid++){
    const bits=[];
    for(let head=1;head<=e.PROTO_HEAD_COUNT;head++){
      bits.push(e.StashLoad(e.PLAYER_DATA[pid],e.PROTO_SAVE_PREFIX+'머리도감.'+e.ProtoHeadKey[head],'0'));
      e.ProtoHeadKnown[e.ExpKey(pid,head)]=false;
    }
    e.ProtoCodexSlot[pid]=0;e.eventPlayer=pid;e.syncData=[e.PlayerSlotNumber[pid],...bits].join('|');e.ProtoCodexSync();
    for(let head=1;head<=e.PROTO_HEAD_COUNT;head++)assert.equal(e.ProtoHeadKnown[e.ExpKey(pid,head)],true);
    assert.equal(e.ProtoCodexSlot[pid],e.PlayerSlotNumber[pid]);
  }
});
check('2047번까지 초기화해도 다른 플레이어의 카드·사건 이력과 영구 도감이 보존됨',()=>{
  const e=fresh(0,true).e;
  e.PROTO_CARD_LAST=2047;e.PROTO_EVENT_COUNT=2047;
  // JavaScript 배열은 범위를 자동 확장하므로 JASS의 실제 8192칸 경계를 별도로 강제한다.
  for(const [name,array] of Object.entries(e))if(Array.isArray(array)&&array.length===8192){
    const boundary=key=>{if(typeof key==='string'&&/^-?\d+$/.test(key))assert(Number(key)>=0&&Number(key)<8192,name+' 범위 초과 '+key);};
    e[name]=new Proxy(array,{get(target,key){boundary(key);return target[key];},set(target,key,value){boundary(key);target[key]=value;return true;}});
  }
  const fields=['ExpCardOwned','ExpCardSeen','ExpCardReserved','ProtoEvolved','ProtoCharacterOwned','ProtoCharacterEvolved'];
  const numbers=['ExpArcana','ProtoCardProgress','ProtoCardStacks','ProtoRewardCopies','ProtoCharacterGrade','ProtoMainProgress','ProtoCandidates'];
  for(let pid=0;pid<4;pid++){
    for(const id of [13,1023,1024,2047]){
      for(const field of fields)e[field][e.ExpKey(pid,id)]=true;
      for(const field of numbers)e[field][e.ExpKey(pid,id)]=7;
      e.ProtoEventHistory[e.ProtoStoryKey(pid,id)]=3;
    }
    e.ProtoHeadOwned[e.ExpKey(pid,e.PROTO_HEAD_COUNT)]=true;
    e.ProtoHeadKnown[e.ExpKey(pid,e.PROTO_HEAD_COUNT)]=true;
  }
  for(let pid=0;pid<4;pid++){
    e.ResetPid=pid;e.ProtoResetRunCards();
    for(const id of [13,1023,1024,2047]){
      for(const field of fields)assert.equal(e[field][e.ExpKey(pid,id)],false,field);
      for(const field of numbers)assert.equal(e[field][e.ExpKey(pid,id)],0,field);
      assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(pid,id)],0);
    }
    assert.equal(e.ProtoHeadOwned[e.ExpKey(pid,e.PROTO_HEAD_COUNT)],false);
    assert.equal(e.ProtoHeadKnown[e.ExpKey(pid,e.PROTO_HEAD_COUNT)],true,'영구 도감 초기화');
    if(pid<3){
      assert.equal(e.ProtoRewardCopies[e.ExpKey(pid+1,2047)],7);
      assert.equal(e.ProtoEventHistory[e.ProtoStoryKey(pid+1,2047)],3);
    }
  }
});
check('모든 엔딩 카드가 일반 캐릭터와 합쳐지지 않고 독립 인벤토리 항목으로 획득됨',()=>{
  const e=fresh(0,true).e;const pid=3;e.localPlayer=pid;
  for(const world of worlds)for(const card of world.cards.filter(c=>c.endingCard)){
    const id=registry.cards[card.key];
    assert.equal(e.ProtoCardCharacter[id],id,card.key+' 엔딩 대표 카드 누락');
    e.ProtoGrantCard(pid,id);
    assert.equal(e.ProtoIsInventoryCard(pid,id),true,card.key+' 엔딩 인벤토리 누락');
    assert.equal(e.StashLoad(e.PLAYER_DATA[pid],e.PROTO_SAVE_PREFIX+'카드도감.'+card.key,''),'1');
  }
});
console.log(JSON.stringify({checks,heads:Object.keys(registry.heads).length,cards:Object.keys(registry.cards).length,events:Object.keys(registry.events).length,maximumEntityId:2047,maximumPlayerKey:8191,runtimeTested:false}));
