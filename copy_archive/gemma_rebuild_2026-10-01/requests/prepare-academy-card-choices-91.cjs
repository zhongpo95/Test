// 학원도시의 보수 대안과 같은 카드 반복을 세 지정 기억으로 나누고 현장 글을 Gemma에 요청한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const file=path.join(repo,'content/roguelite/04-academy.json'),bytes=fs.readFileSync(file),before=JSON.parse(bytes);
fs.writeFileSync(path.join(root,'before-academy-card-choices-91.json'),bytes,{flag:'wx'});
const card=(key,name,effectName,keyword,pairs,canonFact)=>({key,name,effectName,keyword,grade:2,effects:pairs.map(([stat,value])=>({stat,value})),evolution:{kind:0,goal:0,effects:[]},canonFact,uncertain:[]});
const addedCards=[
 card('academy_uiharu_order','우이하루 카자리','확인할 순서','사건 후보 · 일반 적',[['event_choices',1],['normal_damage_percent',12]],'기존 지부 기록·정보 지원에서 확인할 대상을 나누는 여행자의 기억이다. 새 해킹·자동 수색·행동력 증가·원작 사건 해결은 없다.'),
 card('academy_saten_detour','사텐 루이코','돌아가는 길의 표식','이동 · 일반 적',[['move_speed',3],['normal_damage_percent',14]],'능력이 없어도 발품과 생활 속 확인을 이어 가는 기존 역할에서 여행자가 귀환길을 정하는 기억이다. 이동은3%이며 새 이동 기술이나 능력 개발은 없다.'),
 card('academy_saten_box','사텐 루이코','짐 아래의 빈칸','공격력 · 차지 속도',[['attack_percent',12],['charge_speed',4]],'기존 납품·진열 정리에서 짐을 옮기기 전에 남은 항목을 살피는 여행자의 기억이다. 새 무기·물류 자동보수·NPC 능력치 상승은 없다.'),
 card('academy_kuroko_line','시라이 쿠로코','넘지 않을 선','비방향 · 받는 피해',[['nondirectional_damage',12],['damage_reduction',4]],'기존 사격 통로 안내에서 넘어가지 않을 경계를 정하는 여행자의 기억이다. 비방향은 헤드/백 플래그 없는 공격이며 공간이동·보호막·무적을 지급하지 않는다.'),
 card('academy_touma_address','카미조 토우마','도착지를 먼저','최대 체력 · 보스',[['max_health_percent',8],['boss_damage_percent',10]],'기존 운반과 남은 몫을 먼저 확인하는 역할에서 가져갈 곳을 확인하는 여행자의 기억이다. 실제 실종 해결·불행 면역·이매진 브레이커 전수·즉시 치료는 없다.'),
 card('academy_tessou_seat','테츠소 츠즈리','빈자리에도 이어질 말','최대 체력 · 치명 피해',[['max_health_percent',8],['crit_damage',12]],'공식17화의 좋아하던 게임과 혼자 남은 대화에서 빈자리를 가리지 않고 이야기를 듣는 여행자의 기억이다. 학생의 복귀·게임 승리·NPC 치료·새 미니게임은 없다.'),
 card('academy_tessou_interval','테츠소 츠즈리','눌러야 할 때까지','차지 속도 · 치명 피해',[['charge_speed',5],['crit_damage',15]],'공식17화의 게임센터 만남에서 입력 사이의 간격을 기다리는 여행자의 기억이다. 새로운 게임 기술·콤보 시스템·학생의 다음 선택을 정하지 않는다.'),
 card('academy_uiharu_list','우이하루 카자리','접어 두지 않은 항목','치명 피해 · 고체력',[['crit_damage',12],['healthy_damage',10]],'정보와 남은 약속을 확인하는 기존 역할에서 아직 끝내지 않은 항목을 남기는 여행자의 기억이다. 고체력은65%이상이고 즉시 회복·갈등 해소·새 추적 기술은 없다.')
];
const events=structuredClone(before.events),changes=[],removedChoices=[];
function change(key,index,values,action){const e=events.find(e=>e.key===key),old=structuredClone(e.choices[index-1]);assert(old);e.choices[index-1]={...old,...values,gold:0,result:''};changes.push({key,index,before:old,after:structuredClone(e.choices[index-1]),action});}
function trim(key){const e=events.find(e=>e.key===key);assert.equal(e.choices.length,4);removedChoices.push({key,index:4,choice:structuredClone(e.choices[3])});e.choices=e.choices.slice(0,3);}
change('academy_bad_signal',3,{card:'academy_saten_detour',cost:80,density:-1,potions:2,label:'80골드로 우회 보급을 준비하고 사텐과 돌아올 골목의 표식을 남긴다'},'사텐과 보급이 돌아올 골목을 확인하고 우회로에 표식을 남긴다');trim('academy_bad_signal');
change('academy_signal_answer',3,{card:'academy_uiharu_order',cost:160,label:'160골드로 기록용품을 마련하고 우이하루에게 확인할 대상을 나눠 전한다'},'우이하루에게 현장 기록을 나눠 전하고 아직 확인하지 않은 대상을 남긴다');
change('academy_urban_rumor',3,{card:'academy_saten_detour',cost:160,label:'160골드로 안내를 준비하고 사텐과 돌아갈 골목을 비운다'},'사텐과 모인 사람들의 돌아갈 방향을 나누고 골목의 표식을 확인한다');
change('academy_coin_test',3,{card:'academy_kuroko_line',cost:160,label:'160골드로 안내를 준비하고 쿠로코와 넘어가지 않을 사선을 정한다'},'쿠로코와 작업자 통로의 경계를 표시하고 사선 밖으로 안내한다');
change('academy_second_route',2,{card:'academy_uiharu_order',label:'120골드로 봉쇄를 준비하고 우이하루와 남길 통로의 기록을 나눈다'},'우이하루에게 닫은 통로와 남길 통로의 기록을 따로 전한다');
change('academy_display_window',3,{card:'academy_kuroko_line',cost:160,label:'160골드로 운반을 준비하고 쿠로코와 진열을 가리지 않을 선을 남긴다'},'쿠로코와 진열 아래의 상자를 나누고 순찰에 나설 길을 비워 둔다');
change('academy_sweet_orders',3,{card:'academy_saten_box',cost:160,label:'160골드로 운반을 준비하고 사텐과 주문표 아래의 짐을 나눈다'},'사텐과 주문표 아래의 짐을 나누고 아직 확인하지 않은 항목을 펼친다');
trim('academy_pair_step');
change('academy_pool_bundle',3,{card:'academy_kongo_pair',cost:160,label:'160골드로 운반을 준비하고 콘고와 맡을 범위를 줄여 보폭을 맞춘다'},'콘고와 바깥에서 맡을 범위를 줄이고 준비물을 함께 옮길 보폭을 맞춘다');
change('academy_guts_corner',3,{card:'academy_touma_address',cost:160,label:'160골드로 운반을 준비하고 토우마와 짐의 도착지를 먼저 확인한다'},'토우마와 짐의 도착지 표시를 확인하고 갈 곳이 다른 짐을 따로 남긴다');
change('academy_parade_markers',1,{},'우이하루와 예전 표식의 기록을 대조하고 확인한 것만 새 상자로 옮긴다');
change('academy_parade_markers',3,{card:'academy_saten_box',cost:160,label:'160골드로 정리를 준비하고 사텐과 내일 확인할 상자를 나눈다'},'사텐과 맡을 길목을 줄이고 아직 확인하지 않은 표식의 상자를 따로 남긴다');
change('academy_vending_left_coin',3,{card:'academy_touma_address',label:'내 사냥의 적 수 단계를1올리고 토우마와 남은 짐을 가져갈 곳부터 정한다'},'토우마와 남은 짐을 가져갈 곳을 정하되 자판기에 삼켜진 동전과 손에 남은 몫은 따로 센다');trim('academy_vending_left_coin');
change('academy_tea_after_call',3,{card:'academy_saten_box',cost:160,label:'160골드로 운반을 준비하고 사텐과 가져갈 짐과 남길 자리를 나눈다'},'사텐과 가져갈 짐과 남길 찻잔의 자리를 따로 나눈다');
change('academy_unanswered_promise',3,{card:'academy_uiharu_list',cost:160,label:'160골드로 전달을 준비하고 우이하루에게 줄인 몫과 남은 항목을 말한다'},'우이하루에게 자기가 맡을 몫을 줄였다고 말하고 아직 대답하지 않은 항목을 남긴다');
change('academy_arcade_empty_seat',2,{card:'academy_tessou_interval',label:'내 사냥의 적 수 단계를1올리고 테츠소와 다음 입력의 간격을 기다린다'},'테츠소와 다음 버튼을 누르기 전에 입력 사이의 간격을 기다린다');
change('academy_arcade_empty_seat',3,{card:'academy_tessou_seat',cost:160,label:'160골드로 내 차례를 준비하고 빈 의자를 가리지 않은 채 테츠소의 말을 듣는다'},'빈 의자를 가리지 않게 자기 짐을 옮기고 테츠소가 하려던 말을 듣는다');
change('academy_festival_before_stage',3,{card:'academy_uiharu_list',cost:160,label:'160골드로 안내를 준비하고 우이하루와 남은 전시와 무대 차례를 따로 적는다'},'우이하루와 더 볼 전시를 적되 미코토가 돌아갈 무대 차례는 따로 남긴다');
change('academy_drink_after_vending',3,{card:'academy_touma_address',cost:160,label:'160골드로 운반을 준비하고 토우마와 손에 남은 보급의 도착지를 정한다'},'토우마와 손에 든 보급을 가져갈 곳을 정하고 삼켜진 동전을 다시 찾을 일은 남긴다');
for(const e of events){assert.equal(e.choices.length,3);assert.equal(new Set(e.choices.map(c=>c.card)).size,3);for(const c of e.choices){assert(c.card);assert.equal(c.gold,0);assert.notEqual(c.card,before.world.entryCard);}}
const fixed={sourceRevision:'5622efe',beforeFile:'before-academy-card-choices-91.json',beforeSha256:crypto.createHash('sha256').update(bytes).digest('hex'),world:before.world,cards:[...before.cards,...addedCards],addedCards,events,changes,removedChoices,policy:{history:'구조백업 성공1/현장진입 성공2/다른곳음료 성공1의 자기 후속과 번호를 유지한다. 부모가 준 카드를 후속에서 다시 주지 않는다.',stats:'기존21카드와 머리효과는 그대로 유지한다. 기존스탯의 레어기억8장을 더한다.',candidate:'사건 후보2~4는 유지한다. 사건 안은18사건54선택의 세 지정카드다.',gold:'기존 직접골드16개는 모두 제거한다. 처치골드/중복100/카드의처치골드능력치는 별개다.',fourth:'네번째 세 선택 중 보급기능은 구조사건3번에 결합하고 보수만 주던 둘은 제외했다.'},sources:before.sources};
assert.equal(before.events.flatMap(e=>e.choices).filter(c=>c.gold>0).length,16);
write('requests/academy-card-choices-fixed-91.json',fixed);
const schema={type:'object',properties:{events:{type:'array',items:{type:'object',properties:{key:{type:'string'},choices:{type:'array',items:{type:'object',properties:{index:{type:'integer',enum:[1,2,3]},actionText:{type:'string'},reactionText:{type:'string'}},required:['index','actionText','reactionText'],additionalProperties:false}}},required:['key','choices'],additionalProperties:false}}},required:['events'],additionalProperties:false};
const changed=events.filter(e=>changes.some(x=>x.key===e.key));
for(let start=0,batch=1;start<changed.length;start+=4,batch++){
 const slice=changed.slice(start,start+4),s=structuredClone(schema);s.properties.events.minItems=slice.length;s.properties.events.maxItems=slice.length;s.properties.events.items.properties.key.enum=slice.map(e=>e.key);
 write('requests/academy-scenes-text-91-'+batch+'.json',{review:false,schema:s,system:'한국어 사건 작가다. 입력key/index마다 여행자가 직접 한 행동 actionText 한 문장과 원래 인물의 남은 문제에 대한 reactionText 한 문장을 쓴다. 숫자·비용·카드·보상·능력치·확률·실패·내부키를 문장에 쓰지 않는다. 행동 주체는 플레이어이며 칭찬/끄덕임을 반복하지 않는다. 원작 기술·결말·미니게임을 추가하지 않는다.',brief:{events:slice.map(e=>({key:e.key,story:e.story,canonFact:e.canonFact,choices:changes.filter(x=>x.key===e.key).map(c=>({index:c.index,action:c.action}))})),boundary:before.canonBoundary,format:'actionText/reactionText만 쓴다. 실제 기억·비용·지속 필드·물약은 고정 데이터에서 별도로 결합한다. 테츠소의 학생 복귀·우이하루와쿠로코완전화해·자판기돈반환·미코토연주/원작큰범죄의결과를 확정하지 않는다.'}});
}
console.log(JSON.stringify({events:18,choices:54,newCards:8,changedChoices:changes.length,batches:Math.ceil(changed.length/4),removedGoldChoices:16}));
