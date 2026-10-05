// 검수된 다단계 원고를 기존 사건 키와 카드 ID 순서를 보존하여 적용한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..');
function apply(reviewRoot){
const dir=path.join(root,'content/roguelite');
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
let count=0,nodes=0;
for(const file of fs.readdirSync(dir).filter(f=>f.endsWith('.json')).sort()){
 const filePath=path.join(dir,file),w=read(filePath),world=w.world.key;
 if(world==='common')continue;
 const pen=world==='penacony';
 const draft=read(path.join(reviewRoot,pen?'penacony-rewrite-review/dialogue-v3/candidate-ready.json':`head-stories-choice-rebuild/${world}/accepted.json`));
 const ending=pen?read(path.join(reviewRoot,'penacony-rewrite-review/ending-v4/ending-flow.review-only.json')):draft.ending;
 const endingKey=world+'_main_ending_memorial';
 for(const c of draft.chapters){
  const e=w.events.find(e=>e.key===c.key);if(!e||e.mainStage!==c.stage)throw Error('사건 단계 불일치 '+c.key);
  const final=c.stage===w.world.mainStory.length;
  if(e.choices.length!==c.choices.length)throw Error('선택 수 불일치 '+c.key);
  for(let i=0;i<e.choices.length;i++){
   const b=e.choices[i],d=c.choices[i];if(!w.cards.some(x=>x.key===d.card))throw Error('보상 키 없음 '+d.card);
   if(!final&&b.card!==d.card)throw Error('보상 순서 변경 '+c.key);
   if(b.chance!==100||['cost','gold','level','density','potions'].some(k=>b[k]!==0)||b.card2)throw Error('지연 지급 불가 '+c.key);
   if(final&&b.card!==endingKey)w.cards.find(x=>x.key===b.card).retiredMainReward=true;
   b.label=(c.choiceSpeaker?c.choiceSpeaker+' · ':'')+d.label;b.result=d.result;b.card=final?endingKey:d.card;
  }
  e.title=c.title;e.intro=c.intro;e.story=c.story;
  e.dialogue={enabled:true,commonResult:final?'':c.commonResult,nodes:(c.followUps||[]).map(n=>({key:n.id,story:[n.story,n.prompt?(n.speaker?n.speaker+' · ':'')+n.prompt:''].filter(Boolean).join('\n\n'),choices:n.choices.map(b=>({label:(n.choiceSpeaker?n.choiceSpeaker+' · ':'')+b.label,result:b.result}))}))};
  if(final)e.dialogue.nodes.push(pen?{key:'ending',story:ending.afterVictory+'\n\n선데이 · '+ending.question,choices:[{label:ending.answer,result:ending.afterAnswer}]}:{key:'ending',story:[c.commonResult,ending.transition,ending.prompt?(ending.speaker?ending.speaker+' · ':'')+ending.prompt:''].filter(Boolean).join('\n\n'),choices:ending.choices.map(b=>({label:(ending.choiceSpeaker?ending.choiceSpeaker+' · ':'')+b.label,result:b.result}))});
  nodes+=e.dialogue.nodes.length;count++;
 }
 if(!w.cards.some(c=>c.key===endingKey))w.cards.push({key:endingKey,name:ending.card.name,effectName:'메인 엔딩 기념 · 효과 설계 중',keyword:ending.card.description,grade:4,effects:[],evolution:{kind:0,goal:0,effects:[]},endingCard:true,canonFact:ending.card.description,uncertain:['효과와 수치는 검수 후 설계한다.']});
 w.reviewRecords=[...(draft.records||[]),...(pen?[ending.gemmaRecord]:[])];
 fs.writeFileSync(filePath,JSON.stringify(w,null,2).replaceAll('일리야','이리야')+'\n');
}
return {reviewedEvents:count,dialogueNodes:nodes,endingCards:13};
}
if(require.main===module){if(!process.argv[2])throw Error('검수 원고 폴더가 필요합니다.');console.log(JSON.stringify(apply(path.resolve(process.argv[2]))));}
module.exports={apply};
