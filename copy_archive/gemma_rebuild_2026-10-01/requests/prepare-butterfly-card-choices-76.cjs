// 골드 대안과 동일 카드 중복을 없애고 나비저택 사건을 서로 다른 세 카드의 행동으로 재구성한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..'),read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const file=path.join(repo,'content/roguelite/13-butterfly.json'),bytes=fs.readFileSync(file),before=JSON.parse(bytes);
fs.writeFileSync(path.join(root,'before-butterfly-card-choices-76.json'),bytes,{flag:'wx'});
const b=(card,label,cost=0,level=0,density=0,chance=100,potions=0)=>({card,card2:null,label,result:'',cost,gold:0,level,density,chance,potions});
const choices={
 kny_night_path:[b('kny_zenitsu','등불과 밧줄을 마련해 젠이츠가 짚은 길을 확인한다',160,1,0,70),b('kny_inosuke','이노스케와 막힌 길을 직접 열어 본다',0,0,2),b('kny_tanjiro','탄지로와 서두르지 않고 남은 짐을 운반한다',220)],
 kny_night_found:[b('kny_kanao','카나오와 반응 훈련을 위한 도구를 마련한다',240),b('kny_kanao_quiet','180골드로 짐을 나눌 도구를 마련하고 카나오가 먼저 비운 발자리를 따라 본다',180,0,-1,100,2),b('kny_zenitsu_listen','180골드로 짐 소리를 줄일 천을 마련하고 젠이츠와 움직일 순간을 맞춘다',180)],
 kny_night_wrong:[b('kny_shinobu','시노부와 다음 출발의 회복 준비를 갖춘다',160),b('kny_inosuke','이노스케에게 더 강한 구역을 맡는 자세를 묻는다',0,1),b('kny_inosuke_partition','180골드로 발판 확인 도구를 마련하고 이노스케와 보이지 않은 쪽의 움직임도 살핀다',180,0,-1,100,1)],
 kny_unread_bottles:[b('kny_shinobu','새 이름표를 사서 시노부와 병의 기록을 대조한다',220),b('kny_aoi_supply','포장 재료를 사서 아오이와 확인된 보급만 챙긴다',140),b('kny_shinobu_points','260골드로 기록 대조 도구를 마련하고 시노부와 다음 상대에 맞는 준비를 구별한다',260)],
 kny_white_linen:[b('kny_aoi_supply','새 천을 마련하고 아오이와 보급 묶음을 나눈다',180),b('kny_inosuke_terrain','이노스케와 돌아가는 보급길을 넓게 맡는다',0,0,1),b('kny_inosuke_partition','180골드로 길을 확인할 도구를 마련하고 이노스케와 보이지 않는 구간을 살핀다',180,0,-1,100,1)],
 kny_crow_dispatch:[b('kny_tanjiro','기록용품을 사서 탄지로와 맡을 일을 다시 확인한다',160),b('kny_aoi_supply','부족한 포장을 마련해 아오이와 출발 목록을 맞춘다',200),b('kny_tanjiro_return','180골드로 반복할 준비를 마련하고 탄지로와 임무를 들은 뒤 움직일 차례까지 맞춘다',180)],
 kny_midday_noise:[b('kny_zenitsu_listen','완충천을 사서 짐 소리를 줄이고 젠이츠와 움직일 순간을 맞춘다',180),b('kny_tanjiro_smell','조사 도구를 사서 탄지로와 주변 흔적부터 확인한다',220),b('kny_zenitsu','200골드로 반응 연습 도구를 마련하고 젠이츠와 한 번 움직일 순간을 준비한다',200,0,-1,100,1)],
 kny_mixed_traces:[b('kny_tanjiro_smell','도구를 마련해 탄지로가 짚은 흔적을 조사한다',140,1,0,70),b('kny_inosuke_terrain','이노스케와 넓은 주변 길목을 직접 맡는다',0,0,2),b('kny_inosuke_partition','180골드로 발판 확인 도구를 마련하고 이노스케와 자국이 끊긴 쪽도 살핀다',180,0,-1)],
 kny_before_departure:before.events.find(e=>e.key==='kny_before_departure').choices.slice(0,3).map(c=>({...c,gold:0})),
 kny_senior_challenge:[b('kny_murata_senior','무라타에게 버틸 몫을 묻고 준비 물품을 마련한다',180),b('kny_inosuke','이노스케의 승부를 대신 맡고 더 강한 사냥을 준비한다',0,1),b('kny_tanjiro_return','180골드로 연습할 자리를 마련하고 탄지로와 먼저 인사한 뒤 각자 맡을 동작을 반복한다',180,-1,0,100,1)],
 kny_return_to_training:before.events.find(e=>e.key==='kny_return_to_training').choices.slice(0,3).map(c=>({...c,gold:0})),
 kny_frightened_visitor:[b('kny_nezuko_will','두 사람 사이를 비워 두고 네즈코의 행동을 지켜본다'),b('kny_tanjiro','탄지로와 손님이 머무를 자리를 마련한다',180),b('kny_morning_breath','180골드로 이야기할 자리를 마련하고 탄지로와 말 사이에도 자기 숨을 고른다',180,0,-1)],
 kny_first_gourd:[b('kny_gourd_breath','도구값120골드를 먼저 내고 숨을 불어 표주박을 터뜨려 본다',120,0,0,60),b('kny_morning_breath','도구값220골드를 내고 탄지로와 한 번에 힘주기보다 숨을 계속 잇는 연습을 한다',220),b('kny_tanjiro_return','160골드로 반복할 자리를 마련하고 탄지로와 도구를 들고 거두는 순서부터 맞춘다',160,0,-1,100,1)],
 kny_morning_greeting:[b('kny_morning_breath','180골드로 내 연습 도구를 마련하고 옆에서 자기 숨을 잇는다',180),b('kny_tanjiro','내 사냥의 강함 단계를1올리고 탄지로가 다음 동작에서도 숨을 잇는 보폭을 따른다',0,1),b('kny_tanjiro_return','160골드로 연습할 자리를 마련하고 탄지로와 말한 뒤 움직일 차례까지 반복한다',160)],
 kny_hand_return:[b('kny_kanao_return_hand','200골드로 내 추가 연습 준비를 하고 같은 속도에 다시 맞춘다',200),b('kny_kanao_small_motion','내 사냥의 적 수 단계를1올리고 손동작을 작게 줄여 다시 본다',0,0,1),b('kny_aoi_supply','180골드로 도구를 다시 묶을 포장을 마련하고 아오이와 다음 차례의 보급을 나눈다',180,0,0,100,1)],
 kny_partition_role:[b('kny_inosuke_partition','180골드로 내 연습 준비를 하고 발판의 변화를 살핀다',180),b('kny_inosuke','내 사냥의 적 수 단계를1올리고 이노스케처럼 막힌 쪽을 직접 열어 본다',0,0,1),b('kny_inosuke_terrain','160골드로 길목 표식을 마련하고 이노스케와 돌아갈 보폭을 맞춘다',160,0,-1,100,1)],
 kny_after_first_gourd:[b('kny_gourd_second','140골드로 내 다음 연습 도구를 마련하고 터진 소리 뒤에도 숨을 잇는다',140),b('kny_tanjiro_smell','내 사냥의 강함 단계를1올리고 탄지로가 다음 빈틈을 보는 감각을 기억한다',0,1),b('kny_morning_breath','180골드로 내 연습 도구를 마련하고 탄지로와 성공 뒤에도 숨을 계속 잇는다',180,0,0,100,2)]
};
const events=before.events.map(e=>({...e,choices:choices[e.key]}));
for(const e of events){assert.equal(e.choices.length,3);assert.equal(new Set(e.choices.map(c=>c.card)).size,3);for(const c of e.choices){assert(before.cards.some(k=>k.key===c.card));assert.equal(c.gold,0);}}
const failed=events.find(e=>e.key==='kny_night_wrong');assert.equal(failed.previousChoice,-1);
write('requests/butterfly-card-choices-fixed-76.json',{sourceRevision:'233aa7c',beforeFile:'before-butterfly-card-choices-76.json',beforeSha256:crypto.createHash('sha256').update(bytes).digest('hex'),world:before.world,cards:before.cards,events,policy:{human:'골드만주는선택지제거후카드·카드·카드구성으로보완',gold:0,distinctCardsPerEvent:3,rootGrowth:'서로다른카드효과와비용/개인필드부담비교',history:'야간수색성공1번/실패-1번과표주박성공1번을같은인덱스로유지',unchanged:['카드수치/각성조건','머리효과','사건후보2~4개','사냥기본10골드','리롤500+100','흡수/재생상한10%초','무기/영구성장','맵미제작']}});
const stats={attack_percent:'공격력%증가',damage_percent:'대미지증가',final_damage_percent:'최종대미지증가',boss_damage_percent:'보스에게가하는피해',normal_damage_percent:'일반몬스터에게가하는피해',crit_chance:'치명타확률%p',crit_damage:'치명타피해%',swift:'신속고정값',action_speed:'일반행동속도%',move_speed:'이동속도%',charge_speed:'차지준비속도%',penetration:'방어관통%',max_health_percent:'최대체력%비율보존',damage_reduction:'받는피해감소%',leech:'피해에서흡수할양%',regeneration:'초당최대체력%재생',kill_gold:'이후처치당추가골드',event_choices:'사건후보추가',moving_damage:'이동속도400초과/추가40%에서최대인조건피해',directional_damage:'플래그와유효각도가모두맞은실제헤드/백적중피해%',nondirectional_damage:'헤드/백플래그가둘다없는공격피해%',shielded_damage:'기존보호막이남아있을때가하는피해%',charge_damage:'차지태그공격피해%',healthy_damage:'현재체력65%이상때가하는피해%'};
const sourceFacts=read('requests/butterfly-pitches-72.json').brief.sourceFacts;
for(let start=0,batch=1;start<events.length;start+=6,batch++){
 const slice=events.slice(start,start+6),schema=read('requests/academy-expansion-text-58.json').schema;schema.properties.events.minItems=schema.properties.events.maxItems=slice.length;
 write('requests/butterfly-card-choices-text-76-'+batch+'.json',{review:false,schema,system:'한국어사건작가다. 각사건의key와choices순서/개수3을그대로지킨다. story는선택전현장문제3문장,intro는남은문제1문장,label은지정action그대로,result는성공한여행자행동·지불과정확한카드기억/필드/물약·인물의작은반응2~3문장이다. 칭찬/끄덕임/범용효율메뉴/선택전선지불을반복하지않는다.',brief:{sourceFacts,events:slice.map(e=>({...e,choices:e.choices.map(c=>({action:c.label,card:before.cards.find(k=>k.key===c.card),cost:c.cost,gold:0,level:c.level,density:c.density,potions:c.potions,chance:c.chance}))})),stats,rules:[
 '모든선택성공보상은지정카드1장이다. 즉시골드보상없다. 비용은선지불,level강함/density적수는변화량이고사건후개인필드에계속남는다. 음수는줄임이다. 즉시NPC성장/호흡스킬/감지/소환/장비를주지않는다.',
 '70/60%result는성공일때만쓴다. 실패문장은기존failure를유지한다. 자기야간수색성공1번/실패-1번과표주박성공1번후속을지킨다. 후속카드를첫사건에서먼저주지않는다.',
 '현재체력비용/새AP/시간은없고흡수/재생합산초당10%상한,물약은보급소모품이다. 최대체력은현재비율보존이다. 카드의kill_gold는나중처치당추가수급이며지금골드지급과다르다.',
 '새인물/원작중요결말/미확인동전/차승부를넣지않는다. 같은인물의다른기억카드도서로다른성장효과다. 기존등장인물의별도행동으로연결하되원작성취를대신완료하지않는다.'
]}});
}
console.log(JSON.stringify({events:events.length,choices:51,distinctCards:3,directGoldChoices:0,batches:3}));
