// 사건 표시 변경이 본문·보상·ID를 보존하는지 검사한다.
'use strict';
const fs=require('fs'),cp=require('child_process'),assert=require('assert');
const {highlight,highlightConfig}=require('./generate-prototype-content.cjs');
const baseline=process.argv[2] || cp.execFileSync('git',['merge-base','HEAD','origin/main'],{encoding:'utf8'}).trim();
const plain=s=>s.replace(/\\n/g,'\n').replace(/\s/g,'');
const strip=s=>s.replace(/\|c[0-9a-f]{8}|\|r/gi,'');
let events=0,changed=0,colored=0;
for(const f of fs.readdirSync('content/roguelite').filter(f=>f.endsWith('.json'))){
 const file='content/roguelite/'+f,now=JSON.parse(fs.readFileSync(file,'utf8'));
 const before=JSON.parse(cp.execFileSync('git',['show',baseline+':'+file],{encoding:'utf8',maxBuffer:4e6}));
 now.events.forEach((e,i)=>{events++;assert.equal(plain(e.story),plain(before.events[i].story),e.key);if(e.story!==before.events[i].story)changed++;before.events[i].story=e.story;
 const rendered=highlight(e.story,now.world.key,'story',highlightConfig);assert.equal(strip(rendered),e.story.replace(/\\n/g,'\n'));assert(!rendered.includes('undefined'));if(rendered.includes('|c'))colored++;
 });assert.deepStrictEqual(now,before,f);
}
const academy=JSON.parse(fs.readFileSync('content/roguelite/04-academy.json','utf8')).events.find(e=>e.key==='academy_main_01');
const text=highlight(academy.story,'academy','story',highlightConfig);
assert(text.includes('\n\n'));assert(text.includes('|cFF865500복제인간 이야기|r'));
assert.equal(highlight('열린 문','fuyuki','label',highlightConfig),'열린 문');
assert.equal(strip(highlight('시로는 약속을 기억한다.','fuyuki','label',highlightConfig)),'시로는 약속을 기억한다.');
assert.deepStrictEqual(JSON.parse(fs.readFileSync('content/roguelite-id-registry.json','utf8')),JSON.parse(cp.execFileSync('git',['show',baseline+':content/roguelite-id-registry.json'],{encoding:'utf8'})));
console.log(JSON.stringify({events,changed,colored,gameplayPreserved:true,idsPreserved:true,runtimeTested:false}));
