// 미타키하라 원본을 보존하고 인물별 세 기억·무료 방문·카드 조건의 집필 요청을 만든다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..'),file=path.join(repo,'content/roguelite/05-mitakihara.json');
const bytes=fs.readFileSync(file),before=JSON.parse(bytes),d=structuredClone(before);const save=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
save('before-mitaka-card-choices-100.json',{sha256:crypto.createHash('sha256').update(bytes).digest('hex'),base64:bytes.toString('base64'),data:before});
const memory=(key,name,effectName,keyword,effects,fact)=>({key,name,effectName,keyword,grade:2,effects:Object.entries(effects).map(([stat,value])=>({stat,value})),evolution:{kind:0,goal:0,effects:[]},canonFact:fact+' 여행자의 성장으로 각색하며 원작 능력·새 기술·아이템이나 운명 변경을 지급하지 않는다.',uncertain:[]});
const added=[
 memory('madoka_return_markers','카나메 마도카','돌아와 줄 자리','최대 체력 · 고체력',{max_health_percent:8,healthy_damage:12},'친구를 걱정하는 성격에서 돌아올 사람의 자리를 남기는 기억이다. 고체력은65%이상이다.'),
 memory('madoka_mami_rear','토모에 마미','내 뒤에 둘 여백','차지 속도 · 받는 피해',{charge_speed:5,damage_reduction:4},'후배를 돌보는 선배의 역할에서 자신의 조준과 뒤편의 준비를 구분하는 기억이다.'),
 memory('madoka_kyoko_unshared','사쿠라 쿄코','허투루 버리지 않을 것','이동 · 치명 피해',{move_speed:3,crit_damage:14},'음식을 늘 먹는 면모에서 버리지 않고 남길 몫을 확인하는 기억이다. 이동3%와 치명 피해14%p다.'),
 memory('madoka_homura_retreat','아케미 호무라','빈칸으로 남긴 길','치명 피해 · 일반 적',{crit_damage:12,normal_damage_percent:14},'준비와 경계를 세우는 기존 역할에서 확인하지 않은 곳을 함부로 채우지 않는 기억이다. 시간 정지나 제한시간 추가는 없다.'),
 memory('madoka_sayaka_carry','미키 사야카','가방을 닫기 전에','치명 확률 · 비방향',{crit_chance:4,nondirectional_damage:12},'친구를 문병하는 행동에서 준비된 물건부터 챙기는 기억이다. 비방향은 헤드/백 플래그 없는 공격이며 손 치료나 소원 실현을 하지 않는다.'),
 memory('madoka_hitomi_walk','시즈키 히토미','함께 갈 수 있는 구간','이동 · 최대 체력',{move_speed:3,max_health_percent:8},'여러 습관과 친구 관계에서 함께 갈 구간만 맡는 기억이다. 연애 결말·실제 시간 증가를 뜻하지 않는다.'),
 memory('madoka_mami_next','토모에 마미','다음에도 들을 이야기','행동력 최대치',{action_capacity:1},'후배의 선택을 돕는 역할에서 다음 방문에도 맡을 몫을 정하는 기억이다. 행동력 최대치와 현재행동력 증가분1만 지급하며 사냥 제한시간은 늘지 않는다.')
];d.cards.push(...added);
const branch=(label,card,cost=160,level=0,density=0,potions=0)=>({label,card,card2:null,gold:0,cost,level,density,potions,chance:100,result:''});
const event=key=>{const e=d.events.find(e=>e.key===key);assert(e);return e;};
const removed=[];
for(const e of d.events){e.choices.forEach((c,i)=>{if(c.gold>0)removed.push({event:e.key,choice:i+1,original:c});c.gold=0;});}
const parking=event('madoka_parking_seed');parking.title='자전거 보관소의 검은 씨앗';parking.story='병원 자전거 보관소에서 부화 직전의 그리프 시드를 발견했다. 마도카는 마미에게 도움을 청하고 사야카는 시민들이 접근하지 못하도록 경계한다. 연락을 받은 호무라는 다른 길로 돌아가라고 한다. 도움을 기다리는 동안 너도 맡을 일을 정해야 한다.';parking.intro='도움을 기다리는 자전거 보관소에서 맡을 일을 정한다.';parking.choices=parking.choices.slice(0,3);parking.choices[1].potions=1;parking.canonFact='원 TV3화 공식 줄거리의 병원 자전거 보관소·그리프 시드·사야카 경계·마도카의 도움 요청에서 별도 사전 준비를 각색한다. 플레이어 개입과 호무라 연락은 창작이며 본편 마녀전 결말이나 마미 운명을 바꾸지 않는다.';
const mentor=event('madoka_mentor_return');mentor.story+=' 마도카는 돌아올 표시를 남기고 마미는 뒤편 준비까지 혼자 맡지 말자고 한다.';mentor.choices[2]=branch('100골드로 보급을 마련하고 마미의 뒤편에서 맡을 길목을 줄인다','madoka_mami_rear',100,0,-1,2);
event('madoka_familiar_trace').story+=' 쿄코는 같은 흔적을 다른 쪽에서 살피며 추적할 구역을 나누라고 한다.';
const church=event('madoka_church_food');church.choices[2]=branch('160골드로 귀환 보급을 준비하고 쿄코가 남길 몫을 따로 둔다','madoka_kyoko_unshared',160,0,-1);church.canonFact='원 TV7화 공식 줄거리의 쿄코와 사야카의 폐허 교회 방문을 배경으로 각색한다. 음식과 준비에서 여행자가 맡는 선택은 창작이며 둘의 갈등·소원·소울젬 결말을 해결하지 않는다.';
const wish=event('madoka_one_wish');wish.choices=wish.choices.slice(0,3);wish.choices[1].potions=1;
const warning=event('madoka_warning');warning.story+=' 마미는 먼 거리에서 볼 자리를, 마도카는 남은 사람들의 귀환길을 가리킨다.';warning.choices[2]=branch('100골드로 보급을 마련하고 호무라와 확인하지 않은 강한 구역을 맡지 않는다','madoka_homura_retreat',100,-1,0,2);
const visit=event('madoka_visit_music');visit.choices[1].card='madoka_sayaka_carry';visit.choices[2]=branch('160골드로 포장을 마련하고 마도카와 돌아와 받을 몫을 남긴다','madoka_return_markers',160,0,0,1);visit.failure='이전 목록에서도 음악 제목을 확인하지 못했다. 연락 비용120골드는 돌아오지 않고 카드를 받지 못한다. 사야카는 쪽지를 가방 안에 다시 넣는다.';
const home=event('madoka_home_morning');home.choices=home.choices.slice(0,3);home.choices[2].card='madoka_return_markers';
const appts=event('madoka_afterclass_appts');appts.choices[2]=branch('160골드로 안내를 마련하고 히토미와 함께 갈 구간만 맡는다','madoka_hitomi_walk',160,0,-1);appts.actionCost=0;
event('madoka_transfer_practice').choices[2]=branch('160골드로 정리를 준비하고 호무라와 확인하지 않은 담당 구역을 줄인다','madoka_homura_retreat',160,0,-1);
event('madoka_room_visit').choices[2]=branch('160골드로 보급을 준비하고 마미의 뒤편에서 맡을 길목을 줄인다','madoka_mami_rear',160,0,-1,1);
event('madoka_boundary_entrance').choices[2]=branch('160골드로 귀환 준비를 하고 마도카와 더 약한 바깥 구역만 맡는다','madoka_return_markers',160,-1);
d.events.push({key:'madoka_folded_edge',title:'한 걸음 뒤에서 들을 말',intro:'마미가 네가 표시한 입구의 간격을 알아보고 지도를 다시 편다.',story:'마미는 네가 들어갈 위치와 물러설 자리를 표시했던 지도를 보며 다음에도 같은 일을 맡을지 묻는다. 마도카는 돌아올 자리부터 남기자고 하고 사야카는 마미의 뒤편 준비도 비어 있다고 한다. 익힌 간격이 있어 입구부터 다시 설명할 필요는 없지만 다음 방문까지 맡을지는 네가 답해야 한다.',previous:null,previousChoice:0,requiredCard:'madoka_mami_distance',actionCost:1,failure:null,canonFact:'마미의 후배 안내 역할을 사용한 별도 만남이다. 자신의 들어가기 전의 한 걸음 카드 보유를 조건으로 다음 몫을 정한다. 방문 행동력 추가는 사냥 시간 증가·마미 생존·본편 운명 변경이나 인물의 시간 능력이 아니다.',uncertain:[],choices:[branch('200골드로 내 준비를 하고 마미에게 다음 방문의 몫까지 답한다','madoka_mami_next',200),branch('160골드로 보급을 준비하고 마미와 뒤편의 담당 길목을 줄인다','madoka_mami_rear',160,0,-1),branch('마도카와 더 많은 적이 오가는 귀환길의 자리를 맡는다','madoka_return_markers',0,0,1)]});
for(const url of ['https://www.madoka-magica.com/tv/archives/story/03.html','https://www.madoka-magica.com/tv/archives/story/05.html','https://www.madoka-magica.com/tv/archives/story/07.html'])if(!d.sources.includes(url))d.sources.push(url);
d.canonBoundary+=' 새 카드의 행동력 최대치 증가는 여행자의 방문 횟수이며 사냥 제한시간이나 인물의 시간 능력이 아니다. 사전 준비와 이후 교회 장면은 같은 날이 아니다. 병원 자전거 보관소는 원 TV3화, 폐허 교회는 원 TV7화 공식 줄거리로 별도 대조했다.';
save('requests/mitaka-card-choices-fixed-100.json',{beforeSha256:crypto.createHash('sha256').update(bytes).digest('hex'),sourceRevision:'e85e943',data:d,addedCards:added.map(c=>c.key),removedGold:removed,policy:{cards:'각 사건 서로 다른 지정카드3종. 입문·부모 보상 카드를 후속에서 반복하지 않음.',cost:'cost선지불. 실패해도 AP/골드/필드 변화 유지. 성공만 카드와 물약 지급.',field:'level은개인몬스터강함(1~5),density는동시몬스터수(1~10). 초기1/4. 플레이어레벨·NPC능력아님.',ap:'기본후보3최대4. 방문AP1또는0,잔여AP0이면무료도등장안함. 최대치증가분만현재AP에도한번지급.',history:'주차장 성공1→mentor_return,성공3→warning의 자기 기록 번호 유지.',canon:d.canonBoundary}});
const choiceSchema={type:'object',additionalProperties:false,required:['index','actionText','reactionText'],properties:{index:{type:'integer',enum:[1,2,3]},actionText:{type:'string'},reactionText:{type:'string'}}};
for(let batch=0;batch<3;batch++){const events=d.events.slice(batch*4,batch===2?13:batch*4+4);const schema={type:'object',additionalProperties:false,required:['events'],properties:{events:{type:'array',minItems:events.length,maxItems:events.length,items:{type:'object',additionalProperties:false,required:['key','choices'],properties:{key:{type:'string',enum:events.map(e=>e.key)},choices:{type:'array',minItems:3,maxItems:3,items:choiceSchema}}}}}};
save('requests/mitaka-scenes-text-100-'+(batch+1)+'.json',{review:false,schema,system:'한국어 사건 집필자. 모든 문장은 한국어다. 확정된 장면·인물·수치·지정카드·선택 순서는 변경하지 않고 각 행동 뒤 여행자가 한 일과 인물의 다음 반응을 과거형으로 쓴다. 창작 기억을 원작 신규 초능력·장비·완전한 해결이라고 주장하지 않는다. 미소/끄덕임 반복이나 능력치 설명 복사는 피한다. 출력은 JSON뿐이다.',brief:{events,cards:d.cards,policy:{...d.canonBoundary},rules:['actionText는label행동이완료된과거형1문장이다. 비용/강함/적수/물약 변화가있으면누락하지않는다.','reactionText는행동에반응하는구체적말/손/물건과아직남은문제1문장이다. 보상은데이터가표시하므로스탯을산문으로길게복사하지않는다.','물약은제공된potions개만받는다. 직접골드는0. 물약을사용/소비/마셨다고쓰지않는다.','마도카입문카드를다시얻는것이아니라돌아올자리의새기억이다. 큐베계약의지속최대체력패널티는현재체력지불이아니다.','골드0선택도방문AP는별개다. 음수필드는단계감소이며양수는개인사냥부담이다.','마미의운명·소울젬·교회갈등·쿄스케치료·연애결말을해결하지않는다. 시간정지/추가사냥시간/새전투/자동처치는없다.']}});}
console.log(JSON.stringify({cards:d.cards.length,events:d.events.length,choices:d.events.reduce((n,e)=>n+e.choices.length,0),removedGold:removed.length,addedCards:added.length}));
