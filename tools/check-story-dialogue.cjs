// 다단계 대화의 원고 출처와 기존 카드 ID·보상 보존을 검증한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {generate}=require('./generate-prototype-content.cjs'),{inspect}=require('./check-content-candidates.cjs');
const root=path.resolve(__dirname,'..');
const dir=path.join(root,'content/roguelite'),files=fs.readdirSync(dir).filter(f=>f.endsWith('.json')).sort();
const worlds=files.map(f=>JSON.parse(fs.readFileSync(path.join(dir,f),'utf8')));
const generated=generate(worlds), actual=fs.readFileSync(path.join(root,'Data/Data_PrototypeCatalog.j'),'utf8').replace(/\r\n/g,'\n');assert.equal(actual,generated);
const ids=new Map([...generated.matchAll(/set ProtoCardKey\[(\d+)\] = "([^"]+)"/g)].map(m=>[m[2],Number(m[1])]));
const registry=JSON.parse(fs.readFileSync(path.join(root,'content/roguelite-id-registry.json'),'utf8'));
let count=0,nodes=0,finals=0,firstChoices=0,followChoices=0;
const baseline={count:0,nodes:0,finals:0,choices:0};
for(const w of worlds){assert.equal(inspect(w).errors.length,0,w.world.key);for(const c of w.cards)assert.equal(ids.get(c.key),registry.cards[c.key],c.key+' 고정 ID 변경');for(const e of w.events.filter(e=>e.dialogue)){count++;firstChoices+=e.choices.length;nodes+=e.dialogue.nodes.length;followChoices+=e.dialogue.nodes.reduce((n,x)=>n+x.choices.length,0);const final=e.mainStage===w.world.mainStory.length;if(final){finals++;assert.equal(e.dialogue.nodes.at(-1).key,'ending');}if(registry.heads[w.world.key]<=13){baseline.count++;baseline.nodes+=e.dialogue.nodes.length;baseline.choices+=e.choices.length;if(final)baseline.finals++;assert.ok(!JSON.stringify(e).includes('일리야'));}}}
assert.deepEqual(baseline,{count:198,nodes:84,finals:13,choices:594},'기존 13작품의 대화 구조 보존');
assert.equal(count,worlds.reduce((n,w)=>n+(w.world.mainStory?.length||0),0),'모든 메인 사건에 대화 연결');
assert.equal(finals,worlds.filter(w=>w.world.mainStory).length);
assert.equal(firstChoices,count*3);
const pen=worlds.find(w=>w.world.key==='penacony').events.find(e=>e.mainStage===15),last=pen.dialogue.nodes.at(-1);
assert.equal(last.choices.length,1);assert.equal(last.choices[0].label,'왜냐면... 언젠가... 우린 꿈에서 깨어날 거니까');assert.ok(last.story.includes('대체... 생명은 왜 깊은 잠에 빠지는 건가?'));assert.ok(last.story.includes('선데이를 격파한다'));
const invalid=structuredClone(worlds.find(w=>w.world.key==='fuyuki'));invalid.events.find(e=>e.dialogue).dialogue.nodes.push({key:'illegal',story:'x',choices:[{label:'x',result:'x',gold:100}]});assert.ok(inspect(invalid).errors.length);
const invalidCard=structuredClone(worlds[0]);invalidCard.cards[0].effects=[];assert.ok(inspect(invalidCard).errors.length);
if(process.argv[2])for(const file of fs.readdirSync(process.argv[2]).filter(f=>f.endsWith('.json'))){const before=JSON.parse(fs.readFileSync(path.join(process.argv[2],file),'utf8')),after=worlds.find(w=>w.world.key===before.world.key);assert.ok(after,'기존 작품이 사라짐 '+before.world.key);for(const c of before.cards){const now=after.cards.find(x=>x.key===c.key);assert.deepEqual(now.effects,c.effects);assert.deepEqual(now.evolution,c.evolution);}for(const e of before.events){const now=after.events.find(x=>x.key===e.key);if(!now.dialogue)assert.deepEqual(now,e);else if(e.mainStage!==before.world.mainStory.length)e.choices.forEach((b,i)=>{for(const k of ['card','card2','cost','gold','chance','level','density','potions'])assert.equal(now.choices[i][k],b[k]);});}}
console.log(JSON.stringify({catalogEvents:count,initialChoices:firstChoices,dialogueNodes:nodes,followChoices,endingCards:finals,registeredCardIDs:ids.size,checks:'generated catalog, ID stability, deterministic rewards, ending order, invalid payload rejection, optional baseline preservation',runtimeTested:false},null,2));
