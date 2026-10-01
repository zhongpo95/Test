// 아비도스 초안의 메타데이터·다른 언어·임의 실패 확률을 보존하고 현장 행동과 인물 반응만 재요청한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/abydos-card-choices-fixed-86.json'),drafts=[1,2,3,4].map(n=>read('drafts/abydos-card-choices-text-86-'+n+'.json'));
for(const d of drafts){assert.equal(d.parseError,null);assert.deepEqual(d.parsed.events.map(e=>e.key),d.request.brief.events.map(e=>e.key));}
write('revisions/abydos-card-choices-draft-rejection-87.json',{rawDrafts:[1,2,3,4].map(n=>'drafts/abydos-card-choices-text-86-'+n+'.json'),reasons:['86-1은 cpu:카드키/비용/필드 등의 내부 표기와 다른 JSON 문법 조각을 결과 문자열에 넣었다. 물약과 몬스터 감소를 문장 밖에 밀어냈다.','86-2는 다른 언어를 섞고 확정 선택에70/60/75%의 미구현 실패를 만들어 넣었다. 이동3%를 고정3처럼 표시하고 여행자가 아니라 인물의 체력을 바꾸었다.','86-3은 현장 행동의 주체를 여행자 대신 NPC로 바꾸고 반복 끄덕임/수긍만 적었다. 선택에 따른 지속 필드 감소를 누락한 결과도 있다.','86-4는 괄호 수치에 의존하며 실제로 선택한 행동이 거의 없고 무츠키의 기다림을 정직함으로 바꾸거나 아루 다음 말을 무츠키 다음 말로 혼동했다.'],decision:'원문/요청/ID/저장기록은 그대로 보존하고 활성 콘텐츠에는 쓰지 않는다.',retry:'Gemma 출력은 actionText와 reactionText로 나눠 수치·보상·실패·내부표기 없이 현장 글만 만든다. 고정86의 실제 보상은 코드가 붙이고 Codex가 장면과 문장을 검토한다.',numericChanges:[],revisit:'주체·관계·실제 행동·남은 문제가 맞고 새 장면/기술/결말을 만들지 않았는지 독립 검토와 고정 수치 대조가 필요하다.'});
const schema={type:'object',properties:{events:{type:'array',items:{type:'object',properties:{key:{type:'string'},choices:{type:'array',items:{type:'object',properties:{index:{type:'integer',enum:[1,2,3]},actionText:{type:'string'},reactionText:{type:'string'}},required:['index','actionText','reactionText'],additionalProperties:false}}},required:['key','choices'],additionalProperties:false}}},required:['events'],additionalProperties:false};
for(let batch=1;batch<=4;batch++){
 const original=read('requests/abydos-card-choices-text-86-'+batch+'.json'),s=structuredClone(schema),events=original.brief.events;
 s.properties.events.minItems=events.length;s.properties.events.maxItems=events.length;s.properties.events.items.properties.key.enum=events.map(e=>e.key);
 write('requests/abydos-scenes-text-87-'+batch+'.json',{review:false,schema:s,system:'한국어 사건 작가다. 입력key/index마다 actionText 한 문장과 reactionText 한 문장만 쓴다. actionText는 여행자(너)가 선택label의 행동을 실제로 한 현장이다. reactionText는 원래story의 남은 문제에 관련 인물이 한 작은 반응이다. 숫자·카드획득·보상·능력치·확률·실패·비용·cpu·JSON·메타데이터는 쓰지 않는다. 새 장면이나 원작 기술을 덧붙이지 않고 칭찬·끄덕임만 반복하지 않는다.',brief:{events:events.map(e=>({key:e.key,story:e.story,canonFact:e.canonFact,choices:e.choices.map(c=>({index:c.index,action:c.label,memory:fixed.cards.find(k=>k.key===c.card).effectName}))})),boundary:fixed.policy.history+' 기존 원작 역할과 작은 만남만 사용한다. 여행자 행동의 결과를 NPC의 성장·새 기술·실제 무기·현재체력 지불·빚 해소·큰 결말로 바꾸지 않는다.',format:'actionText/reactionText만 출력하며 고정된 카드·비용·필드·물약은 코드가 붙인다. 카드와 수치를 별도로 쓰지 않는다.'}});
}
console.log(JSON.stringify({events:16,choices:23,batches:4,rejectedDrafts:4,numericChanges:0}));
