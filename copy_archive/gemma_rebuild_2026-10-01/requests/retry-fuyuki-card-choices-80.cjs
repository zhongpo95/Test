// 여러 사건을 결과 문자열에 합친 Gemma 원문을 폐기하고 수정 대상만 더 작은 묶음으로 다시 요청한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/fuyuki-card-choices-fixed-79.json'),requests=[1,2].map(n=>read('requests/fuyuki-card-choices-text-79-'+n+'.json'));
const events=requests.flatMap(r=>r.brief.events).map(({unchangedChoices,...e})=>e);
assert.equal(events.length,14);
write('revisions/fuyuki-card-choices-draft-rejection-80.json',{file:'drafts/fuyuki-card-choices-text-79-1.json',reasons:['JSON 구문은 통과했지만 일곱 사건 중 최초 사건의 key만 출력했다.','요청하지 않은 ReplaceCard 메타데이터와 다른 사건의 선택을 결과 문자열 안에 섞었다.','적 수 변화와 물약 지급을 심리적 압박이나 체력 소모로 바꾸거나 누락했다.'],decision:'원문/요청/모니터링 기록은 그대로 보존하고 활성 콘텐츠에 반영하지 않는다.',retry:'수정하지않는분기입력제외,사건4개이하로분할,사건수와key/선택번호/문장메타데이터유입을검사한다.',numericChanges:[],revisit:'구조가맞아도실제선택의지정카드/비용/개인필드/물약과독립결과문장을다시대조해야한다.'});
for(let start=0,batch=1;start<events.length;start+=4,batch++){
 const slice=events.slice(start,start+4),keys=slice.map(e=>e.key),refs=new Set(slice.flatMap(e=>e.choices.map(c=>c.card))),schema=structuredClone(requests[0].schema);
 Object.assign(schema.properties.events,{minItems:slice.length,maxItems:slice.length});schema.properties.events.items.properties.key.enum=keys;
 schema.properties.events.items.properties.choices.minItems=1;schema.properties.events.items.properties.choices.maxItems=3;
 schema.properties.events.items.properties.choices.items.properties.index.enum=[1,2,3];
 write('requests/fuyuki-card-choices-text-80-'+batch+'.json',{review:false,schema,system:'한국어 사건 작가다. events에각요청key를별도객체로한번씩같은순서로출력한다. 각사건의choices는입력에주어진index만출력한다. label은입력그대로,result는한국어행동/기억/비용/부담/지급/작은반응3문장만쓴다. result에JSON·key·ReplaceCard·메타데이터·다른사건을붙이지않는다. 변경하지않는선택은출력하지않는다.',brief:{cards:fixed.cards.filter(c=>refs.has(c.key)),events:slice,mechanics:requests[0].brief.mechanics,boundary:requests[0].brief.boundary,checks:['4개이하사건마다key와지정index를나눈다. 결과문장에기술메타데이터없음.','density±1은사냥몬스터수의지속변화고피로/시간/정보량아님. level±1은몬스터강함이고여행자능력아님.','potions1/2는물약그개수지급이고사용/소비/즉시회복아님.','추가골드·칭찬반복·새인물·가벼워진마나/새스킬을만들지않음.']}});
}
console.log(JSON.stringify({events:events.length,batches:4,branches:fixed.changes.length,rejectedDraft:1,numericChanges:0}));
