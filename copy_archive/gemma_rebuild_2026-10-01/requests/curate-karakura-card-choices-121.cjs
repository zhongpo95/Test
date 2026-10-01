// 카라쿠라 집필의 옛 보수·내부키·미완성 반응을 고치고 고정된 분기로 독립 검토를 요청한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');const root=path.resolve(__dirname,'..');const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));const save=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});const fixed=read('requests/karakura-card-choices-fixed-120.json'),d=structuredClone(fixed.data),files=Array.from({length:4},(_,i)=>'drafts/karakura-scenes-text-120-'+(i+1)+'.json'),drafts=files.map(read);assert.equal(drafts.flatMap(x=>x.parsed.events).length,19);
const reactions={
  "bl_shop_boxes": [
    "이치고는 옮길 짐을 들기 전에 가려진 수취인 쪽지를 다른 상자와 나눴고 콘은 아직 짐 사이에 남았다.",
    "우류는 젖은 쪽지의 읽히는 선만 남겼고 모르는 주소를 이치고가 짐작한 이름으로 채우지 않았다.",
    "오리히메는 운반대에 올릴 짐과 아직 멈춘 짐을 따로 놓고 수취인을 찾는 일은 우류 쪽에 남겼다."
  ],
  "bl_rooftop_marks": [
    "요루이치는 정비한 발판 옆의 간격을 짚었지만 이어진 발자국의 주인까지 알았다고 하지는 않았다.",
    "루키아는 맡을 입구를 표시했고 요루이치가 본 지붕 위의 흔적은 다른 줄에 남겼다.",
    "루키아는 줄인 귀환 몫만 표시하고 아직 보지 않은 골목을 지나온 길처럼 적지 않았다."
  ],
  "bl_return_receipt": [
    "우라하라는 이번 주소에 맞출 목록을 펼쳤고 아직 확인하지 않은 물품의 칸을 채우지는 않았다.",
    "차드는 돌아갈 사람이 지나갈 간격을 남겼고 우류가 읽은 주소를 다른 짐과 섞지 않았다.",
    "우류는 맡을 메모의 끝을 접었지만 아직 보내지 않은 집에도 전달이 끝났다고 표시하지 않았다."
  ],
  "bl_closed_lane": [
    "루키아는 새 흔적이 남은 쪽을 표시했고 이미 통과한 운반대를 그 길로 다시 밀지 않았다.",
    "차드는 돌아올 사람이 읽을 표식을 먼저 세웠고 콘의 발에 걸린 끈은 당기지 않았다.",
    "콘은 풀린 발부터 움직였고 차드는 남겨 둔 표식을 콘이 지나갈 쪽에 다시 묶지 않았다."
  ],
  "bl_light_parcel": [
    "오리히메는 늦어진 짐과 남은 운반대를 나누고 콘이 가린 메모부터 다시 보자고 했다.",
    "우라하라는 필요한 목록만 펼쳤고 우류는 새 상자의 주소를 예전에 읽은 쪽지와 구분했다.",
    "유즈는 돌아갈 보급을 따로 묶었지만 아직 맡지 않은 배송 짐까지 네 몫으로 올리지는 않았다."
  ],
  "bl_stray_alarm": [
    "요루이치는 확인한 신호의 골목만 짚었고 우류는 다른 쪽에서 울린 표시를 아직 남겨 두었다.",
    "차드는 치운 짐을 통행로 옆으로 옮겼지만 엇갈린 신호의 주인을 찾았다고 말하지 않았다.",
    "우류는 서로 다른 경보 표시를 나란히 두고 요루이치가 보지 않은 골목의 답은 비워 두었다."
  ],
  "bl_unmarked_corner": [
    "루키아는 돌아갈 갈림의 표식을 새로 놓고 잘못 따라간 경보를 확인된 주소로 바꾸지 않았다.",
    "우라하라는 기록에서 빠진 지점을 짚었지만 빈 골목에 있던 것이 무엇인지 대신 채우지는 않았다.",
    "차드는 돌아올 사람이 설 간격을 남겼고 루키아는 아직 표시할 갈림을 다른 쪽에 두었다."
  ],
  "bl_joint_training": [
    "이치고는 한 번의 틈을 고른 뒤 돌아설 자리를 짚었고 차드는 다음 움직임의 몫을 남겼다.",
    "차드는 버틸 자리와 돌아올 쪽을 나눴고 이치고의 칼이 닿을 간격을 짐으로 채우지 않았다.",
    "차드는 줄인 훈련 몫만 표시하고 아직 맡지 않은 상대까지 네 앞에 있다고 말하지 않았다."
  ],
  "bl_ripped_sleeve": [
    "우류는 새 천과 당겼던 소매를 나란히 놓고 다음 움직임에서 다시 벌어질 끝부터 짚었다.",
    "우류는 먼저 맡을 길을 표시했지만 아직 꿰매지 않은 소매를 끝난 일로 접지는 않았다.",
    "콘은 발에서 풀린 실을 옆으로 밀었고 우류는 남은 천과 실타래를 다시 같은 뭉치에 넣지 않았다."
  ],
  "bl_chad_toy": [
    "차드는 작은 인형을 아이가 볼 쪽으로 내렸고 사람이 지나갈 자리에 큰 짐을 놓지 않았다.",
    "이치고는 네가 맡을 바깥 쪽을 짚었지만 차드가 들고 있던 인형의 주인을 대신 정하지 않았다.",
    "차드는 돌아올 간격을 남겼고 아이가 아직 가리키지 않은 길을 네가 다녀온 곳처럼 표시하지 않았다."
  ],
  "bl_yuzu_supplies": [
    "유즈는 돌아올 사람의 칸을 따로 묶었고 이치고가 잠깐이라고 말한 시간으로 그 몫을 줄이지 않았다.",
    "이치고는 맡을 바깥 쪽을 짚었고 유즈는 아직 돌아오지 않은 사람의 보급을 먼저 쓰지 않았다.",
    "유즈는 가까운 몫과 돌아올 보급을 나눴지만 비워 둔 한 칸에 다른 사람의 짐을 채우지는 않았다."
  ],
  "bl_don_audience": [
    "칸온지는 표시한 신호가 보일 쪽을 향했지만 아직 지나갈 수 없는 콘의 자리도 다시 보았다.",
    "이치고는 넓힐 몫을 먼저 나눴고 칸온지는 그 길을 촬영 짐으로 다시 가리지 않았다.",
    "콘은 비워진 간격으로 발을 뺐고 아직 듣지 않은 칸온지의 인사를 대신 끝내지는 않았다."
  ],
  "bl_uncertain_kit": [
    "우라하라는 맞는 목록의 물품만 따로 놓고 남은 묶음까지 같은 상태라고 보증하지 않았다.",
    "우류는 확인된 목록의 끝을 맞췄고 우라하라는 불완전한 묶음의 빈칸을 따로 남겼다.",
    "유즈는 이번에 맡을 보급만 담았고 확인되지 않은 묶음 속의 물품을 그 안에 넣지는 않았다."
  ],
  "bl_tatsuki_space": [
    "타츠키는 발 놓을 자리부터 짚었고 오리히메는 기다리는 사람의 몫을 짐으로 채우지 않았다.",
    "오리히메는 줄인 구역의 준비를 나눴지만 타츠키가 연습할 간격까지 네 짐으로 채우지는 않았다.",
    "차드는 돌아올 사람의 간격을 비웠고 아직 시작하지 않은 타츠키의 연습을 끝난 일로 적지 않았다."
  ],
  "bl_empty_bench": [
    "카린은 옮긴 쪽을 짧게 짚었지만 비워 둔 자리의 이유를 모두에게 떠들지는 않았다.",
    "이치고는 네가 맡을 길을 짚었고 카린은 아무도 안 보인다는 손님의 말에 자리를 다시 채우지 않았다.",
    "루키아는 줄인 안내 몫을 표시했지만 손님에게 보이지 않던 것을 네가 볼 수 있다고 말하지 않았다."
  ],
  "bl_welcome_at_door": [
    "잇신은 아직 듣지 못한 아들의 이야기를 다시 물었고 이치고는 돌려받을 물건부터 가리켰다.",
    "유즈는 손님이 지날 간격을 남겼고 잇신이 묻던 다른 용건까지 대신 답하지 않았다.",
    "유즈는 짧은 용건의 보급을 나눴지만 잇신이 듣고 싶어 하던 이야기를 끝난 일로 적지는 않았다."
  ],
  "bl_small_shop_clerk": [
    "우루루는 받칠 도구 옆에 상자를 내려놓았고 진타는 더 맡기려던 짐의 부탁부터 다시 물었다.",
    "차드는 네가 맡을 몫과 점원에게 남은 일을 나눴고 손님이 밀던 상자를 모두 우루루 앞에 놓지 않았다.",
    "진타는 거절한 추가 짐을 따로 남겼고 손님에게 옮겨 달라는 말과 얕보는 말은 다르다고 다시 말했다."
  ],
  "bl_unasked_invitation": [
    "케이고는 자기 약속부터 설명했고 이치고는 아직 답하지 않은 안내를 이미 정한 일로 적지 말라고 했다.",
    "이치고는 맡을 범위를 짚었지만 케이고가 대신 잡았던 약속까지 받아들이지는 않았다.",
    "우라하라는 따로 물은 길을 펼쳤고 케이고가 먼저 말했던 안내를 확인된 경로로 바꾸지 않았다."
  ],
  "bl_urahara_return_list": [
    "우라하라는 다음에도 맡겠다는 네 답을 남겼고 우류는 이번 받는 사람의 줄부터 다시 맞췄다.",
    "루키아는 아직 맡지 않을 골목을 나눴고 콘은 예전 목록의 물건을 새 빈칸에 먼저 넣지 않았다.",
    "우류는 더 강한 확인 몫의 목록만 펼쳤지만 루키아가 아직 보지 않은 골목의 답은 적지 않았다."
  ]
};
function past(label){const ends=[['만든다','만들었다'],['치운다','치웠다'],['모은다','모았다'],['비운다','비웠다'],['묻는다','물었다'],['옮긴다','옮겼다'],['복구한다','복구했다'],['보여 준다','보여 주었다'],['따라간다','따라갔다'],['맡긴다','맡겼다'],['세운다','세웠다'],['듣는다','들었다'],['읽는다','읽었다'],['적는다','적었다'],['살핀다','살폈다'],['연다','열었다'],['건넌다','건넜다'],['돌본다','돌봤다'],['맞춘다','맞췄다'],['싣는다','실었다'],['확인한다','확인했다'],['준비한다','준비했다'],['받는다','받았다'],['나눈다','나눴다'],['줄인다','줄였다'],['맡는다','맡았다'],['답한다','답했다'],['고른다','골랐다'],['돕는다','도왔다'],['지킨다','지켰다'],['넓힌다','넓혔다'],['남긴다','남겼다'],['찾는다','찾았다'],['정한다','정했다'],['짚는다','짚었다'],['한다','했다']];for(const [a,b]of ends)if(label.endsWith(a))return label.slice(0,-a.length)+b+'.';throw Error('과거형 명시가 필요한 행동. '+label);}
for(const e of d.events){assert.equal(reactions[e.key].length,3);for(const c of e.choices)past(c.label);}
const indexProblems=[];for(const e of d.events){const draft=drafts.flatMap(x=>x.parsed.events).find(x=>x.key===e.key);assert(draft);assert.equal(draft.choices.length,3);if(JSON.stringify(draft.choices.map(c=>c.index))!==JSON.stringify([1,2,3]))indexProblems.push({event:e.key,indices:draft.choices.map(c=>c.index)});for(const [i,c]of e.choices.entries()){let action=past(c.label);if(c.cost>0&&!c.label.includes('골드'))action+=' 준비에 '+c.cost+'골드를 썼다.';if(c.level>0)action+=' 내 개인 사냥의 적 강함 단계가 '+c.level+' 늘었다.';if(c.level<0)action+=' 내 개인 사냥의 적 강함 단계를 '+(-c.level)+' 낮췄다(최저 1).';if(c.density>0)action+=' 내 개인 사냥의 적 수 단계가 '+c.density+' 늘었다.';if(c.density<0)action+=' 내 개인 사냥의 적 수 단계를 '+(-c.density)+' 낮췄다(최저 1).';if(c.potions>0)action+=' 보급 물약 '+c.potions+'개를 받았다.';c.result=action+' '+reactions[e.key][i];}}
const checked=require(path.resolve(__dirname,'../../../tools/check-content-candidates.cjs')).inspect(d);assert.deepEqual(checked.errors,[]);assert.deepEqual(checked.warnings,[]);save('revisions/karakura-card-choices-curated-121.json',d);
save('revisions/karakura-card-choices-discarded-121.json',{drafts:files.map((file,i)=>({file,recordId:drafts[i].monitorRecordId})),indexProblems,discarded:[{what:'성공문구에실패복사·카드없음·경보적수2의전행동전파',why:'120-2가실패문구를모든성공결과에복사했다. 확정카드/필드와불일치한다.',replace:'성공의과거형/실제부담/물약과남은문제를고정하고실패는70%또는65%경계에서만표시한다.',revisit:'다음집필입력에서failure를제거하고성공/실패집필을구분해실제데이터와대조할때.'},{what:'같은카드의확률/확정가격·상자골드4번의고아후속',why:'같은카드는빌드비교가아니고4번제외시후속이막힌다.',replace:'확정묶음은우류의다른기억,옛배송후속은우류보유자의새방문으로바꿨다.',revisit:'돈핵심의사건을별도요청하고동급카드선택과비교할때.'},{what:'경로정리의안전확정·NPC주체의능력치산문',why:'짐분류의결과는카드성장이며실제통로전투/장비/새기술/동행을추가하지않는다.',replace:'확인한몫과모르는길을분리하고개인사냥변화에한정했다.',revisit:'별도기믹을요청하고원작/구현을검증했을때.'}]});
const issue={type:'object',additionalProperties:false,required:['key','problem','evidence','suggestion'],properties:{key:{type:'string'},problem:{type:'string'},evidence:{type:'string'},suggestion:{type:'string'}}},schema={type:'object',additionalProperties:false,required:['verdict','issues','strengths'],properties:{verdict:{type:'string',enum:['PASS','REVISE']},issues:{type:'array',items:issue},strengths:{type:'array',items:{type:'string'}}}};
const facts=read('requests/karakura-scenes-text-120-1.json').brief.verifiedFacts;
for(let n=1;n<=2;n++){const events=d.events.slice(n===1?0:10,n===1?10:19).map(e=>({...e,choices:e.choices.map((c,i)=>({index:i+1,...c}))}));save('requests/karakura-card-choices-review-121-'+n+'.json',{review:true,schema,system:'한국어독립검토자. 실제입력의구체적모순만근거와지적한다. 카드능력과사건필드부담,방문행동력과시간을구분한다. PASS에맞추지않는다. 공식확인역할밖의설정/마법을추측하지않는다.',brief:{world:d.world,cards:d.cards,events,allEventRoutes:d.events.map(e=>({key:e.key,previous:e.previous,previousChoice:e.previousChoice,requiredCard:e.requiredCard,choices:e.choices.map((c,i)=>({index:i+1,card:c.card}))})),policy:fixed.policy,verifiedFacts:facts,checks:["각사건다른지정카드3장. 입문/성공부모/필수카드재지급없음. 모든행동에후속이필요한기획은아님.","상자1/2/3의후속과경보실패-1유지. 옛4번은우류보유의새방문이라previous=null이다.","경보1은70%비용100적수2,묶음1은65%비용180. 실패에도비용/AP/필드유지,보상없음. 성공은지정카드와potions개수만받음.","벤치AP0은골드무료아님. AP0플레이어에게무료도없음. 우라하라최대치1은방문횟수/현재증가분1한번이며시간증가아님.","새8기억kind0은의도적각성없음. 초/처치/실제피해목표를같은단위로비교하지않음.","신속은고정값,재생초당최대체력%,흡수실제피해%. 합산10%/초한도,물약별개. moving은현재속도400대비추가속도40%정규화이며걷는상태아님.","장면은공식인물역할의창작방문이다. 몬스터강함/적수변화는개인사냥으로별도원작전투/NPC능력/보호막생성/의복/영체이탈/순보/귀도아님."]}});}
console.log(JSON.stringify({cards:25,events:19,choices:57,indexProblems,checked}));
