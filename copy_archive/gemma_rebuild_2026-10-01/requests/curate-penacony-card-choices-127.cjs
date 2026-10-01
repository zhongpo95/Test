// 페나코니 집필의 내부키·조건 오독을 반려하고 실제 보상과 장면이 맞는 결과를 재검토한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');const root=path.resolve(__dirname,'..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8')),save=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/penacony-card-choices-fixed-125.json'),d=structuredClone(fixed.data),files=Array.from({length:4},(_,i)=>'drafts/penacony-scenes-text-125-'+(i+1)+'.json'),drafts=files.map(read);
const reactions={
 hsr_dreamy_slots:[
  '그림이 같은 줄에서 멈추자 어벤츄린은 이번 몫과 다음 판의 돈을 나눠 보라고 했다. 너는 한 번만 돌리겠다는 말을 지키고 기다리는 손님에게 자리를 넘겼다.',
  '어벤츄린은 기계에 넣지 않은 돈의 쓰임을 먼저 물었다. 출구를 확인했지만 놀이 줄에 남은 손님들까지 모두 돌아간 것은 아니다.',
  '미샤가 너에게 다음 발을 둘 표시를 짚었다. 코인 자루는 통로 밖으로 나갔지만 흩어진 손님들은 다른 출구를 다시 찾고 있었다.'
 ],
 hsr_after_win:[
  '스파클은 떠나는 사람이 늘자 다른 배역으로 박수의 방향을 바꿨다. 너는 먼 출구까지 맡았지만 아직 같은 얼굴을 따라오는 손님은 남아 있었다.',
  '갤러거는 나가는 사람과 구경하는 사람의 발걸음을 나눴다. 네가 맡은 길목은 줄었지만 놀이가 끝난 이유를 대신 말해 주지는 않았다.',
  '블랙 스완은 출구를 떠난 기억과 박수를 따라 돌아온 기억을 겹쳐 적지 않았다. 아직 밖으로 나가지 않은 손님의 기억까지 끝난 일로 만들지는 않았다.'
 ],
 hsr_after_loss:[
  '블랙 스완은 그림보다 네 손이 멈추지 못한 순간을 다시 물었다. 다음 당첨의 답은 주지 않았고 틀린 그림도 다른 것으로 바꾸지 않았다.',
  '갤러거는 작은 소리가 나는 출구 쪽 안내를 다시 확인했다. 돌아갈 준비는 나눴지만 잃은 판돈을 대신 채워 주지는 않았다.',
  '미샤는 다음 놀이가 아니라 돌아갈 때 들려줄 이야기를 물었다. 너에게 짚은 길이 아직 지나지 않은 길까지 모두 확인한 뜻은 아니다.'
 ],
 hsr_sorted_tokens:[
  '미샤가 너에게 낡은 귀환 표시를 다시 짚었다. 자루가 떠난 자리와 손님이 흩어진 길은 다른 표시로 남겨 두었다.',
  '어벤츄린은 당장 쓸 준비물과 돌아갈 몫을 나눴다. 네가 맡지 않은 출구의 코인까지 이번 짐에 넣지는 않았다.',
  '스파클은 같은 줄에서 또 시작할 이유가 있냐며 박수의 방향을 바꿨다. 맡을 길목은 줄었지만 다음 놀이의 역할까지 정하지는 않았다.'
 ],
 hsr_soulglad:[
  '갤러거는 먼 길의 소문과 실제 옆길을 본 사람의 말을 구분했다. 같은 광고를 읽었다고 같은 길을 확인한 것은 아니었다.',
  '미샤가 너에게 광고 아래 가려진 호텔 표시를 짚었다. 음료를 든 손님들이 그와 대화하며 짐을 맡긴 것은 아니다.',
  '갤러거는 지금 옮길 짐과 귀환에 남길 짐을 나눴다. 같은 말을 반복한 손님의 처음 주문은 다시 물어야 했다.'
 ],
 hsr_masked_stage:[
  '스파클이 바꾼 배역의 박자에 맞춰 막 밖으로 나왔다. 왼쪽을 가리켰던 얼굴이 이번에는 왜 오른쪽을 보는지는 묻지 못했다.',
  '블랙 스완은 두 말을 들었을 때 네 걸음이 꺾인 장면을 비교했다. 길이 갈린 순간은 남았지만 아직 지나지 않은 출구는 확인하지 못했다.',
  '블랙 스완은 네가 지나온 순서만 따로 들었다. 바뀐 얼굴의 말이 어느 순간 갈렸는지까지 같은 기억으로 합치지는 않았다.'
 ],
 hsr_remembered_exit:[
  '어벤츄린은 좁은 곳에 모인 준비물을 넓은 쪽으로 나눴다. 사람들의 걸음이 꺾이는 자리는 그대로 남아 있었다.',
  '갤러거는 경비가 본 구역과 아직 말하지 않은 구역을 나눴다. 경비 안내 한 줄을 모든 귀환길의 답으로 바꾸지는 않았다.',
  '아케론은 장검을 뽑기 전에 발을 둘 간격을 남겼다. 너는 맡을 길목을 줄였지만 그녀의 검법이나 이동 기술을 얻지는 않았다.'
 ],
 hsr_walking_sign:[
  '미샤가 너에게 움직이지 않는 호텔 입구의 표시를 짚었다. 광고판은 여전히 손님들을 다른 가게 쪽으로 부르고 있었다.',
  '블랙 스완은 같은 간판을 두 번 봤다는 네 기억을 따로 들었다. 반복한 길을 새 목적지라고 적지 않았다.',
  '미샤는 너에게 광고가 떠난 자리와 발을 둘 자리를 구분해 보자고 했다. 아직 광고를 따라가는 손님들의 길까지 대신 정하지 않았다.'
 ],
 hsr_scattered_banknotes:[
  '지폐를 챙겨 돌아오자 어벤츄린은 남은 몫보다 멀리 따라간 이유부터 물었다. 너에게 남은 이동 부담은 다음 사냥 준비에도 이어졌다.',
  '어벤츄린은 네가 계산한 길과 더 가야 하는 길을 나눴다. 위험을 맡겠다는 답을 당첨된 결과라고 바꾸지는 않았다.',
  '어벤츄린은 다음에 쓸 준비물을 지폐와 따로 담았다. 눈앞의 길목은 줄였지만 머신에서 나오는 지폐는 멈추지 않았다.'
 ],
 hsr_floating_treat:[
  '미샤는 간식보다 먼저 내디딘 네 발을 보고 다른 별의 여행을 물었다. 빈자리를 살핀 것이 뒤쪽 길까지 확인한 뜻은 아니었다.',
  '미샤는 네가 고른 간식보다 처음 가 봤던 별의 이야기에 귀를 기울였다. 앞에서 뜨던 간식은 다른 손님의 손보다 먼저 움직였다.',
  '반디는 간식을 잡는 사진 대신 옆에서 보이는 풍경을 가리켰다. 그 순간을 기다렸지만 관광객이 고른 사진까지 대신 찍지는 않았다.'
 ],
 hsr_dream_eye_gap:[
  '아케론은 그림의 연결과 실제 발을 둘 간격을 따로 짚었다. 외부인인 너는 공사장 안으로 들어가지 않고 바깥 담당 몫을 맡았다.',
  '블랙 스완은 도면의 연결과 네가 본 통로를 다른 기억으로 들었다. 도면 사본이 막힌 공사장의 출입 허가가 되지는 않았다.',
  '아케론은 돌아설 자리부터 남겼다. 맡을 바깥 통로를 줄였지만 도면의 길이 실제로 연결됐다고 답하지 않았다.'
 ],
 hsr_scene_after_applause:[
  '스파클은 마지막 박자에서도 다른 배역으로 답했다. 너는 장면을 마쳤지만 다음 손님이 기다리는 자리를 새 무대라고 정하지 않았다.',
  '스파클이 이어 간 배역에서 네가 마칠 부분을 골랐다. 다음 체험 손님의 차례는 남았고 이번 부담은 네 사냥 준비로 가져갔다.',
  '블랙 스완은 종료 표시와 이어진 장면을 겹쳐 적지 않았다. 맡은 길목은 줄였지만 아직 바뀌는 배역의 마지막 답은 듣지 못했다.'
 ],
 hsr_monster_last_order:[
  '갤러거는 새 잔을 건네기 전에 손님이 처음 말했던 주문을 다시 물었다. 잔의 단맛과 지금 내려놓고 싶은 이유는 같은 답이 아니었다.',
  '갤러거는 손님을 예의 있게 대하면서도 바뀐 주문을 그대로 넘기지 않았다. 배운 준비가 손님의 말을 모두 확인한 뜻은 아니다.',
  '갤러거는 이번에 옮길 몫과 뒤에 남길 주문을 나눴다. 손님에게 처음 주문을 묻는 차례는 아직 남아 있었다.'
 ],
 hsr_jade_unwritten_price:[
  '제이드는 골드를 셈한 뒤 네가 그 물건을 고른 이유를 다시 물었다. 이동이 느려지는 카드 조건은 다음 사냥에서도 남았다.',
  '제이드는 더 맡겠다는 답과 감당할 수 있다는 답을 같은 줄에 적지 않았다. 너는 이번 강함 부담을 골랐으며 미래 부채를 약속하지 않았다.',
  '블랙 스완은 들은 조건과 아직 답하지 않은 조건을 나눠 들었다. 전달할 몫을 줄인 것이 제이드의 모든 거래를 끝낸 뜻은 아니다.'
 ],
 hsr_name_over_song:[
  '뒤편 관객이 안내를 듣자 로빈은 앞줄에도 같은 말이 전해졌는지 물었다. 이름을 외치는 소리는 줄었지만 노래는 아직 시작되지 않았다.',
  '친구는 이름부터 외치려던 말을 멈추고 기다릴 이유를 첫마디로 정했다. 로빈은 그 답을 대신 부르지 않았다.',
  '갤러거는 돌아갈 관객의 몫을 공연 자리의 짐과 나눴다. 안내를 맡을 길은 줄었지만 뒤편의 마지막 답까지 듣지는 못했다.'
 ],
 hsr_introduction_left:[
  '참가자는 광고 문구보다 자기 이름을 먼저 말했다. 로빈은 이름이 놓인 줄을 들었지만 그 시도가 오디션 우승이라는 뜻은 아니다.',
  '로빈이 들을 자리를 마련하자 참가자는 빈 여백을 다시 봤다. 이름을 언제 말할지는 참가자에게 남겨 두었다.',
  '스파클은 광고 속 이름과 참가자의 이름을 서로 다른 배역으로 읽었다. 너는 안내를 더 맡았지만 참가자 대신 소개하지 않았다.'
 ],
 hsr_cowboy_in_frame:[
  '부트힐은 바꾼 배경보다 그 이유가 사진 아래에 남을지 먼저 물었다. 관광객이 어떤 설명을 붙일지는 아직 보지 못했다.',
  '부트힐은 IPC에 알릴 말을 숨기지 않았다. 너는 맡을 사냥 부담을 골랐지만 총격이나 그의 복수를 대신하지 않았다.',
  '부트힐은 좁힌 촬영 범위에서도 누구에게 보여 줄 말인지 먼저 물었다. 관광객이 붙일 설명의 뜻은 남아 있었다.'
 ],
 hsr_view_without_armor:[
  '반디는 갑옷 사진이 없는 안내에서 보고 싶은 풍경을 짚었다. 관광객에게 SAM을 보여 주겠다는 약속은 하지 않았다.',
  '미샤는 너에게 사진 속 이름보다 들려준 여행의 다음 길을 물었다. 반디가 어떤 풍경을 고를지는 대신 답하지 않았다.',
  '반디는 기다린 순간의 풍경을 살폈다. 맡을 안내 길목을 줄인 것이 병을 치료하거나 갑옷을 얻은 뜻은 아니다.'
 ],
 hsr_name_after_poster:[
  '로빈은 준비를 도운 네 자리와 이름을 말한 참가자의 자리를 나눴다. 다음 손님에게 소개를 들려줄 사람도 참가자로 남겼다.',
  '로빈은 참가자가 답할 간격을 남겼다. 더 맡을 부담은 네 사냥의 몫이며 참가자의 공연을 대신한 것은 아니다.',
  '갤러거는 네가 돌아갈 몫을 관객 자리의 짐과 나눴다. 참가자가 자기 자리를 다시 알릴 차례는 남겨 두었다.'
 ],
 hsr_photo_missing_caption:[
  '부트힐은 설명지에 빠졌던 이유를 확인했다. 관광객은 수호자라는 말을 지우고 왜 배경을 바꿨는지 같은 줄에 적었다.',
  '부트힐은 네가 전한 말이 IPC를 지키겠다는 말로 바뀌지 않았는지 다시 봤다. 그에게 남은 복수까지 끝난 일로 적지는 않았다.',
  '블랙 스완은 네가 배경을 바꾼 이유부터 들었다. 맡을 전달 범위를 줄였지만 관광객이 적을 다음 설명까지 대신 쓰지는 않았다.'
 ],
 hsr_misha_second_page:[
  '미샤는 다음에 들려주겠다는 네 이야기를 안내지의 여백에 남기려 했다. 아직 떠나지 않은 길을 지난 여행처럼 적지는 않았다.',
  '갤러거는 지금 쓸 몫과 나중에 찾을 몫을 나눴다. 미샤가 너에게 묻던 다음 여행 이야기는 남겨 두었다.',
  '블랙 스완은 전에 본 안내와 이번에 들은 안내를 따로 들었다. 미샤는 아직 떠나지 않은 길의 답을 먼저 채우지 않았다.'
 ],
 hsr_robin_next_row:[
  '로빈은 뒤편의 친구가 기다릴 간격을 남겼다. 이름을 외치는 자리만 있다고 모두 노래를 들은 것은 아니었다.',
  '반디는 다른 자리에서 보이는 풍경을 살폈다. 너는 안내를 더 맡았지만 로빈의 아직 시작하지 않은 노래를 끝난 일로 답하지 않았다.',
  '갤러거는 관객이 돌아갈 몫을 나눴다. 맡은 귀환 길목은 줄었지만 뒤편의 친구에게 첫마디가 들렸는지는 다시 물어야 했다.'
 ]
};
const oldScript=fs.readFileSync(path.join(root,'requests/curate-karakura-card-choices-121.cjs'),'utf8');const basePast=new Function('return ('+oldScript.match(/function past\(label\)\{[^\n]+/)[0]+')')();
function past(label){for(const [a,b]of [['뻗는다','뻗었다'],['들려준다','들려주었다'],['배운다','배웠다'],['돌린다','돌렸다'],['챙긴다','챙겼다'],['돌아본다','돌아봤다'],['빠져나간다','빠져나갔다'],['전한다','전했다'],['이어 간다','이어 갔다']])if(label.endsWith(a))return label.slice(0,-a.length)+b+'.';return basePast(label);}
const unknown=[];for(const e of d.events){assert.equal(reactions[e.key].length,3);for(const c of e.choices)try{past(c.label);}catch{unknown.push(c.label);}}assert.deepEqual(unknown,[]);
const rejected=[];for(const e of d.events){const draft=drafts.flatMap(x=>x.parsed.events).find(x=>x.key===e.key);assert(draft);assert.deepEqual(draft.choices.map(c=>c.index),[1,2,3]);for(const [i,c]of e.choices.entries()){const raw=draft.choices[i];if(/hsr_|카드 보상:|보호막 18/.test(raw.reactionText))rejected.push({event:e.key,choice:i+1,raw,reason:'내부키 노출·보상표 복사이며 보호막 조건을 생성으로 오독할 여지가 있다. 장면의 말·물건·남은 문제로 대체한다.'});let action=past(c.label);if(c.cost>0&&!c.label.includes('골드'))action+=' 준비에 '+c.cost+'골드를 썼다.';if(c.gold>0)action+=' 성공 보수 '+c.gold+'골드를 받았다.';if(c.level>0)action+=' 내 개인 사냥의 적 강함 단계가 '+c.level+' 늘었다.';if(c.level<0)action+=' 내 개인 사냥의 적 강함 단계를 '+(-c.level)+' 낮췄다(최저 1).';if(c.density>0)action+=' 내 개인 사냥의 적 수 단계가 '+c.density+' 늘었다.';if(c.density<0)action+=' 내 개인 사냥의 적 수 단계를 '+(-c.density)+' 낮췄다(최저 1).';assert.equal(c.potions,0);c.result=action+' '+reactions[e.key][i];}}
d.events.find(e=>e.key==='hsr_dreamy_slots').failure='회전판은 맞지 않은 그림에서 멈췄다. 바꿔 넣은300골드는 돌아오지 않고 카드와 당첨금도 받지 못했다. 어벤츄린은 다음 판을 대신 돌려주지 않는다. 그림보다 멈추지 못한 손을 돌아볼 차례다.';
d.events.find(e=>e.key==='hsr_scattered_banknotes').failure='지폐를 따라갔지만 돌려받을 몫을 챙기지 못했다. 건200골드는 돌아오지 않고 카드와 보수도 받지 못했다. 어벤츄린은 다음 길을 가기 전에 따라간 범위부터 다시 묻는다.';
d.events.find(e=>e.key==='hsr_scene_after_applause').failure='마지막 장면의 박자를 맞추지 못했다. 준비에 쓴150골드는 돌아오지 않고 카드도 받지 못했다. 스파클은 다른 배역으로 박수쳤고 다음 체험 손님은 자기 차례를 기다렸다.';
d.events.find(e=>e.key==='hsr_introduction_left').failure='참가자는 광고 문구까지 읽었지만 자기 이름을 첫마디로 말하지 못했다. 소개지에 쓴150골드는 돌아오지 않고 카드도 받지 못했다. 로빈은 참가자가 말할 여백을 남겼다.';
const check=require(path.resolve(__dirname,'../../../tools/check-content-candidates.cjs')).inspect(d);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
save('revisions/penacony-card-choices-curated-127.json',d);
save('revisions/penacony-card-choices-discarded-127.json',{drafts:files.map((file,i)=>({file,recordId:drafts[i].monitorRecordId})),rejected,decision:'성공/실패 입력을 분리하여 가짜 실패의 성공문 복사는 사라졌다. 그러나66결과 모두 내부키 또는 보상표를 썼고 안전 길 확정·제이드 신뢰·로빈의 공연 흐름 조정까지 확대했다. 전면 문장 검토로 실제 비용/필드와 각 장면의 남은 문제를 분리했다.',discarded:[{what:'제이드와 반디의 같은 카드·다른 가격 선택',why:'돈과 적 수만 바꾸면 빌드를 비교하는 세 카드가 아니다.',replacement:'제이드의 조건 읽기/반디의 다른 풍경 기억과 기존 카드로 분화했다.',revisit:'사용자가 같은 카드의 비용 비교를 별도로 요청할 때.'},{what:'16일반 골드와 모든 물약 보상',why:'사용자의 보상 제거 지시다.',replacement:'지정 카드와 기존 필드 부담으로 정리했다. 두 돈 핵심 당첨금은 유지한다.',revisit:'사용자가 해당 보상을 명시적으로 재도입할 때.'},{what:'모든 길의 안전 확정·제이드 신뢰·로빈 공연 조정',why:'카드 기억과 원정 필드 변화에서 본편 결과나 관계 시스템을 확정할 근거가 없다.',replacement:'확인한 안내/아직 답하지 않은 몫·아직 시작하지 않은 노래를 남겼다.',revisit:'해당 기믹과 원작 근거를 별도로 요청하고 검증할 때.'}],adoptedAfterEditing:[{draft:4,event:'hsr_photo_missing_caption',idea:'배경을 바꾼 이유를 먼저 다시 듣는다.',boundary:'내부키는 삭제하고 관광객의 잘못된 IPC 설명과 아직 적지 않은 다음 말을 남긴다.'},{draft:4,event:'hsr_misha_second_page',idea:'여백에 다음 이야기를 남기려 한다.',boundary:'꿈속 여행자와의 대화이며 여행 완수/시간 증가가 아니다.'}]});
const issue={type:'object',additionalProperties:false,required:['key','problem','evidence','suggestion'],properties:{key:{type:'string'},problem:{type:'string'},evidence:{type:'string'},suggestion:{type:'string'}}},schema={type:'object',additionalProperties:false,required:['verdict','issues','strengths'],properties:{verdict:{type:'string',enum:['PASS','REVISE']},issues:{type:'array',items:issue},strengths:{type:'array',items:{type:'string'}}}};
for(let n=1;n<=2;n++){const events=d.events.slice(n===1?0:11,n===1?11:22).map(e=>({...e,choices:e.choices.map((c,i)=>({index:i+1,...c}))}));save('requests/penacony-card-choices-review-127-'+n+'.json',{review:true,schema,system:'한국어 독립 검토자. 실제 입력의 모순을 구체적인 근거와 지적한다. PASS에 맞추지 않는다. 원작 능력과 창작 카드 기억을 구분한다. 물약보상이 없으며 보급은 이야기상의 준비다.',brief:{world:d.world,cards:d.cards,events,verifiedFacts:read('requests/penacony-scenes-text-125-1.json').brief.verifiedFacts,policy:fixed.policy,allRoutes:d.events.map(e=>({key:e.key,previous:e.previous,previousChoice:e.previousChoice,requiredCard:e.requiredCard,choices:e.choices.map((c,i)=>({index:i+1,card:c.card}))})),checks:['각 사건은 다른 지정 카드3장. 부모/필수/입문 카드 재지급 없음. 무료 간식은 물품 비용 무료가 아님.','네 확률 행동의 실패는 비용만 유지하고 카드/골드 보상 없음. 성공은600/260 두 당첨금 외 직접골드0. 모든 물약0.','미샤는 꿈속 여행자에게만 말을 건다. 일반 손님이 그에게 답하거나 짐을 맡기지 않는다.','보호막 조건은 새 보호막 생성이 아니고 이동 조건은 현재400대비 증가량을40%로 정규화한다. 걷는 상태 아님.','최대치1은 현재행동력 증가분1 한 번이며 사냥시간 증가 아님. 두 새 보유 방문은 개인 자격이다.','공사장 내부로 들어가지 않는다. 갤러거는 원작 몬스터 바 점주가 아니고 로빈은 오디션 심사위원이 아니다. 부트힐은 IPC에 복수하려는 인물이다.','NPC 신뢰/관계/질병 치료/본편 임무 성공/실제 장비/새 기술/즉시 체력 회복은 없다. 개인 사냥 부담을 별도 준비로 다룬다.']}});}
console.log(JSON.stringify({cards:29,events:22,choices:66,rejected:rejected.length,check}));
