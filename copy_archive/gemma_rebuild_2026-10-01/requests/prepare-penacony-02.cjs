// 누락된 사건·행동이 있는 Gemma 초안을 보존하고 모든 결과를 필수 필드로 다시 요청한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const plan=JSON.parse(fs.readFileSync(path.join(__dirname,'../revisions/penacony-plan-01.json'),'utf8'));
const before=JSON.parse(fs.readFileSync(path.join(__dirname,'penacony-results-01.json'),'utf8'));
const properties=Object.fromEntries(plan.events.map(e=>[e.key,{type:'array',minItems:e.choices.length,maxItems:e.choices.length,items:{type:'string',maxLength:210}}]));
const schema={type:'object',properties:{results:{type:'object',properties,required:Object.keys(properties),additionalProperties:false},slotFailure:{type:'string',maxLength:210}},required:['results','slotFailure'],additionalProperties:false};
const system=before.system+' 앞선 응답은 사건 둘과 대부분의 행동을 누락했고 성공 칸에 실패 결과를 넣어 사용할 수 없었다. 이번에는 8개 사건 각각에 제시한 순서대로 모든 행동의 성공 결과를 쓴다. 결과를 하나로 합치지 않는다. 슬롯머신 첫 행동은 당첨 성공 결과이며 실패 문장은 slotFailure에만 쓴다. 각 결과는 1~2문장이면 충분하다.';
fs.writeFileSync(path.join(__dirname,'penacony-results-02.json'),JSON.stringify({schema,system,brief:before.brief},null,2)+'\n',{flag:'wx'});
console.log('모든 페나코니 행동의 필수 결과 필드를 보존했습니다.');
