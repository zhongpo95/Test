// Gemma 집필을 독립 검토하고 확정된 수치와 분리한 재검토 요청을 보존한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const save=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/action-scenes-fixed-95.json'),draft=read('drafts/action-scenes-text-95.json').parsed;
assert.equal(draft.events.length,2);
const events=structuredClone(fixed.events);
const results=[
 ['내 준비를 마치고 우이하루에게 다음에 맡을 항목까지 답했다. 사텐이 안내할 골목과 쿠로코의 경계는 아직 맡을 사람이 필요하다.', '귀환길에 표식을 남겼다. 우이하루의 남은 항목과 쿠로코가 지킬 경계는 따로 남아 있다.', '강한 적이 드나드는 통로에서 넘어가지 않을 선을 정했다. 우이하루에게 추가로 맡겠다는 답은 하지 못했다.'],
 ['짐의 도착지를 확인하고 운반 준비를 마쳤다. 사텐의 상자와 쿠로코가 돌아올 자리는 다음 사람의 몫으로 남겼다.', '더 많은 적이 오가는 납품 구역에서 먼저 나를 상자를 나눴다. 짐의 도착지와 쿠로코가 돌아올 자리는 아직 정하지 못했다.', '포장을 마련하고 쿠로코가 돌아올 자리를 비워 두었다. 토우마와 사텐의 짐은 아직 도착지를 기다린다.']
];
events.forEach((e,i)=>{const d=draft.events.find(x=>x.key===e.key);assert(d);assert.equal(d.choices.length,3);e.choices.forEach((c,j)=>{assert.equal(d.choices[j].index,j+1);c.result=results[i][j];});});
save('revisions/action-scenes-curated-96.json',{card:fixed.card,events,free:fixed.free,policy:fixed.policy});
save('revisions/action-scenes-discarded-96.json',{draftRecord:read('drafts/action-scenes-text-95.json').monitorRecordId,discarded:[{what:'할당되지 않은 영역·미결 항목의 세부 사항이라는 제목과 할당량 확정 문구',why:'기관 문서 같은 표현이 만남의 장면을 흐리고 행동력 증가가 NPC의 초능력처럼 읽힐 수 있다.',replace:'확인한 뒤에도 남은 몫·접지 않은 항목의 답과 여행자가 맡을 일의 기억',revisit:'업무 배분 자체를 다루는 작품의 장면에서 구체적인 대사가 있을 때.'},{what:'위험 통로 경계를 설정했다·상자 분류를 완료했다만 적은 결과',why:'맵의 개인 사냥 강함/적 수 부담이 빠진다.',replace:'강한 적/더 많은 적이 오가는 개인 사냥 부담을 완료 문장에도 명시',revisit:'실제로 필드 부담이 없는 다른 행동일 때.'}]});
const schema={type:'object',additionalProperties:false,required:['verdict','issues','strengths'],properties:{verdict:{type:'string',enum:['PASS','REVISE']},issues:{type:'array',items:{type:'object',additionalProperties:false,required:['key','problem','evidence','suggestion'],properties:{key:{type:'string'},problem:{type:'string'},evidence:{type:'string'},suggestion:{type:'string'}}}},strengths:{type:'array',items:{type:'string'}}}};
save('requests/action-scenes-review-96.json',{review:true,schema,system:'한국어 독립 검토자. PASS를 목표로 하지 말고 주어진 구현 규칙·장면·지정 카드·비용·보유 조건의 실제 모순을 찾아라. 원작 사실이라고 새 능력이나 큰 사건 해결을 추측하지 않는다.',brief:{content:{card:fixed.card,events,free:fixed.free},policy:fixed.policy,checks:['두 사건에 각기 지정 카드 세 장이 있으며 requiredCard 자체를 보상으로 다시 지급하지 않는가?','카드는 기존 전투 효과와 행동력 최대치+1을 구분하는가? 후자는 얻을 때 현재AP도1지급하지만 매번 충전하지 않는다.','AP무료는 시간 무료/골드 무료와 다르다. 각 선택에 적힌 비용/강함/적 수는 그대로 적용되고 공유 만남 기록과 간격 제한도 유지한다.','이야기에 선택지 인물이 모두 있고 결과가 비용/필드 부담과 다른 성장 축에 맞는가?','교전 정지는 게임 UI 기능이지 학원도시 인물의 시간 정지 능력이 아니다. 기존 방문에서 각색한 장면이다. 원작 갈등 해결이나 신규 장비 아이템 지급을 확정하지 않는다.'],runtime:{normalCost:1,freeCost:0,max:'10 + 모든 보유 카드의 action_capacity 정수 합',grant:'처음 획득/각성으로 최대치가 증가하면 그 증가분만 현재AP에 지급',repeat:'ProtoRefreshStats 반복/카드 중복/화면갱신은 변화량0이므로 지급0',candidateBase:3,candidateCap:4,apZero:'무료 사건도 등장하지 않으며 사냥/준비 완료만 진행',encounter:'사건을 선택하면 파티공유 기록 소비, 보유 조건은 플레이어별'}}});
console.log(JSON.stringify({events:events.length,newCard:fixed.card.key,free:6}));
