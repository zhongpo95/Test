// 후유키 초안의 수량·강함 혼동과 누락 보수·방패 오해를 고치고 만난 인물의 보상으로 연결한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/fuyuki-expansion-fixed-63.json'),draft=read('drafts/fuyuki-expansion-text-63.json').parsed,current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/01-fuyuki.json'),'utf8'));
assert.deepEqual(draft.events.map(e=>e.key),fixed.events.map(e=>e.key));
const rewardReferenceCorrections=[{event:'fy_next_arrow_wait',choice:3,before:fixed.events[4].choices[2].card,after:'fy_taiga_list',reason:'궁도부 후속에는 랜서가 나타나지 않는다. 랜서의 새 감각을 난데없이 보상으로 주기보다 실제 만난 타이가에게 놓친 준비를 다시 묻는 카드로 연결한다. 비용·필드·확률·골드·물약은 유지한다.'}];
fixed.events[4].choices[2].card='fy_taiga_list';fixed.events[4].choices[2].action='더 강한 개인 사냥을 맡고 타이가에게 놓친 준비를 한 번 더 묻는다';
const changes=[],edit=(o,k,v,key,reason)=>{if(o[k]===v)return;changes.push({key,field:k,before:o[k],after:v,reason});o[k]=v;};
const events=fixed.events.map((p,i)=>{assert.equal(draft.events[i].choices.length,p.choices.length);return {key:p.key,title:p.title,story:draft.events[i].story,intro:draft.events[i].intro,previous:p.previous||null,previousChoice:p.previousChoice||0,requiredCard:null,choices:p.choices.map((b,j)=>({label:draft.events[i].choices[j].label,result:draft.events[i].choices[j].result,card:b.card,card2:b.card2,cost:b.cost,gold:b.gold,level:b.level,density:b.density,potions:b.potions,chance:b.chance})),failure:p.failure||null,canonFact:p.canonFact,uncertain:[]};});
const stories=[
 '타이가와 사쿠라가 묵을 준비를 하는데 시로의 손에 펼치지 않은 이불 하나가 남아 있다. 세이버는 사라져 자리를 비울 수 없고 타이가는 네가 아직 외투를 벗지 않은 것을 본다. 사쿠라가 이불 끝을 받아 들자 너는 자기 외투와 아직 남은 한 사람 몫을 번갈아 본다.',
 '네가 놓은 화살이 표적에 닿기 전에 바닥에 내려앉자 타이가는 다음 화살보다 네 손부터 보라고 한다. 시로가 화살을 가져오지만 너는 이미 다시 쏠 자세를 잡고 있다. 타이가는 가져온 화살을 아직 받지도 않았는데 무엇부터 서두르는지 묻는다.',
 '교회에서 키레이가 보호를 설명하자 너는 문 안에 있으면 다음 위험도 사라질 것이라 생각한다. 린은 감독자가 말한 범위에 네 다음 사냥까지 들어 있었냐고 묻는다. 키레이는 먼저 네가 무엇을 보호받으려는지 말하라며 대답을 기다린다.',
 '아처가 막아낸 다음에도 상대의 손을 보는 사이 너는 대응이 끝났다고 한 발을 내놓는다. 랜서는 창을 고쳐 쥐며 그 발자리도 다음 움직임 안에 들어갈 수 있다고 말한다. 아처는 눈을 상대의 손에서 떼지 않은 채 네가 어디에 발을 둘 것인지 묻는다.',
 '타이가에게 성급한 동작을 물었던 네 앞에 시로가 다음 화살을 놓는다. 타이가는 아직 줄을 당기지 않았는데 네 눈이 벌써 표적에 가 있다고 말한다. 시로가 가져온 화살은 손 닿을 곳에 있지만 네 손은 그것을 받기 전에 다시 앞을 향한다.'
];
const intros=['내 이불을 펼칠까, 외투를 챙길까?','다음 화살을 받기 전에 무엇을 물을까?','이 말에 내 다음 사냥도 들어 있었을까?','막아 냈다고 이 발자리도 안전할까?','놓지 않은 손보다 결과가 먼저 앞서갔다.'];
const results=[
 ['침구값160골드를 내고 자기 몫을 마련해 남은 이불 끝을 함께 들었다. 사쿠라의 한 사람 몫을 기억해 최대 체력과 시간에 따른 재생이 늘었다. 사쿠라는 펼친 쪽을 내려놓고도 아직 남은 이불 끝을 시로에게 묻는다.',
  '개인 사냥의 적 강함 단계를1올리는 부담을 맡고 바깥에서 살필 자리를 정했다. 세이버의 경계를 기억해 신속과 이미 보호막을 유지하고 있을 때의 가하는 피해가 늘었다. 세이버는 네가 볼 바깥과 자기가 남을 자리를 따로 살핀다.',
  '외투를 챙겨 오늘 방문을 마쳤다. 세이버의 기본 방어를 기억해 받는 피해가 줄었다. 타이가는 벗지 않은 외투를 보고 다음에는 방문할 몫부터 말하라고 한다.'],
 ['연습 준비값180골드를 내고 자기 성급한 동작을 끝까지 물었다. 타이가의 지적을 기억해 치명타 확률과 방향 공격 피해가 늘었다. 타이가는 네 표적을 가리키다가 다시 화살을 받을 손을 본다.',
  '개인 사냥의 몬스터 수 단계를1올리는 부담을 맡고 자기 실패의 동작을 물었다. 치명타 확률과 방향 공격 피해가 늘었다. 타이가는 더 많이 하는 것과 서두르는 것이 같은 말은 아니라며 다음 화살 앞에 말을 남긴다.',
  '연습을 마치고 자기가 맡은 정리의 보수120골드를 받았다. 시로가 가져온 화살은 내려놓았지만 타이가는 네가 처음 던진 질문을 아직 끝내지 않는다.'],
 ['감독자의 보호라는 말을 받아들여 자기 경계를 좁혔다. 키레이의 말을 기억해 받는 피해는 줄었지만 일반 몬스터에게 가하는 피해도 줄었다. 린은 보호의 범위를 다시 묻고 키레이는 네가 아직 말하지 않은 다음 사냥을 기다린다.',
  '준비값200골드를 내고 린에게 다음 위험을 따로 물었다. 린의 때를 살피는 기억으로 치명타 확률과 신속이 늘었다. 린은 교회 안보다 네가 나갈 쪽을 보고 키레이의 대답에서 아직 빠진 것을 묻는다.',
  '개인 사냥의 몬스터 수 단계를1낮추고 귀환 준비의 물약2개를 챙겼다. 문 밖으로 가져갈 보급은 정했지만 키레이가 되물었던 보호의 뜻은 네 대답을 기다리고 있다.'],
 ['방어 준비값220골드를 내고 막은 다음까지 보는 대응을 기억했다. 받는 피해가 줄고 이미 보호막을 유지하고 있을 때의 가하는 피해가 늘었다. 아처는 네가 뒤로 뺀 발보다 상대가 아직 움직이지 않은 손을 본다.',
  '개인 사냥의 적 강함 단계를1올리는 부담을 맡고 랜서의 창끝 다음 발을 봤다. 이동 중 가하는 피해와 방어 관통이 늘었다. 랜서는 네가 고른 발자리를 보지만 다음에 어느 쪽으로 움직일지는 아직 말하지 않는다.',
  '개인 사냥의 몬스터 수 단계를1낮추고 뒤로 물러날 준비의 물약1개를 챙겼다. 자기 발은 뺐지만 아처와 랜서가 보는 다음 움직임은 여전히 남아 있다.'],
 ['연습 준비값150골드를 내고 화살을 놓기 전 기다릴 간격을 맞췄다. 타이가의 지적을 기억해 차지 준비 속도와 치명타 확률이 늘었다. 시로가 화살을 놓은 자리와 네 손 사이에 이번에는 한 번 더 볼 틈이 남았다.',
  '연습 준비값220골드를 내고 타이가에게 다음 간격을 다시 물었다. 차지 준비 속도와 치명타 확률이 늘었다. 타이가는 네가 표적보다 먼저 묻는 말을 듣고도 다음 화살을 받을 손부터 보라고 한다.',
  '개인 사냥의 적 강함 단계를1올리는 부담을 맡고 타이가에게 놓친 준비를 한 번 더 물었다. 사건 후보와 이후 처치당 골드가 늘었다. 타이가는 질문이 늘었다고 다음 화살을 받을 차례까지 잊지 말라며 네 손을 다시 본다.',
  '연습을 마치고 남은 자기 준비에서100골드와물약2개를 챙겼다. 타이가는 마지막 화살을 먼저 들지 않고 네가 내려놓은 손과 아직 남은 표적을 번갈아 본다.']
];
events.forEach((e,i)=>{edit(e,'story',stories[i],e.key,'자기 실패의 주체를 유지하고 원작 방패 유지·실제 안전구역·인물 강제배치·메타 선택 안내를 현장 반응으로 바꾼다.');edit(e,'intro',intros[i],e.key,'당장 남은 이불·손·보호의 범위·발자리를 짧게 묻는다.');e.choices.forEach((c,j)=>edit(c,'result',results[i][j],e.key+'#'+(j+1),'수량을 강함으로 바꾼 오류·보수100누락·모호한 치명타·자동방패 오해·실제 추가사냥·칭찬만 남는 결과를 고치고 인물의 남은 행동을 쓴다.'));});
edit(events[4].choices[2],'label',fixed.events[4].choices[2].action,events[4].key+'#3','등장하지 않은 랜서 대신 만난 타이가의 준비 카드와 연결한다.');
const candidate={...current,sources:[...new Set([...current.sources,...fixed.sourceFacts.map(s=>s.source)])],cards:[...current.cards,...fixed.cards],events:[...current.events,...events]};
candidate.canonBoundary+=' 숙박의한몫·궁도부의내실패·교회보호범위·막아낸다음의발자리는공식역할에서각색한별도방문이다. 궁도후속은자기성공1번에서만열린다. 원작인질거래·영체화·성배계약·보구·사격점수·자동방패·실제NPC순찰을지급하지않는다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('requests/fuyuki-expansion-fixed-64.json',fixed);write('revisions/fuyuki-expansion-curated-64.json',candidate);write('revisions/fuyuki-expansion-curation-64.json',{sourceRevision:'5d5efd9',raw:'drafts/fuyuki-expansion-text-63.json',changes,rewardReferenceCorrections,numericExceptions:[],check});
const refs=[...new Set(events.flatMap(e=>e.choices.map(c=>c.card)).filter(Boolean))],cards=refs.map(key=>candidate.cards.find(c=>c.key===key));
write('requests/fuyuki-expansion-review-64.json',{review:true,schema:read('requests/academy-expansion-review-60.json').schema,system:'한국어 독립 검토자다. 각사건story/result를그사건card/cost/gold/potions/level/density/chance와직접대조한다. 제공한메커니즘정의를쓰고영어key와자연스러운한국어설명의단순표현차이를스탯오류로분류하지않는다. 실제불일치만issues에적고PASS또는REVISE를판단한다. 새로운수치·기능·균형을추가하지않는다.',brief:{sourceFacts:fixed.sourceFacts,cards,events,mechanics:{cost:'진입AP1. cost골드를먼저내고chance%성공판정. 실패에도비용/AP/필드유지,성공보상없음',field:'level/density는현재절대값아닌지속변화량. 양수증가/음수감소. 최저1,강함최대5,수최대10. 사건중사냥정지',reward:'성공일때만지정card/gold/potions. 중복card는100골드',history:'후속은자기궁도사건성공1번만. 부모카드taiga_arrow와후속카드interval/list는다르다',shielded:'shielded_damage는이미보호막있을때가하는피해증가. 새보호막생성없음',moving:'moving_damage는이동중가하는피해증가',crit:'crit_chance는치명타확률%p,crit_damage는치명피해%',health:'최대체력성장은현재/최대비율보존. regeneration은초당최대체력%재생,즉시회복없음. 흡수/재생합산10%/초',charge:'charge_speed는차지준비속도,charge_damage는차지공격대미지증가',normal:'normal_damage_percent의음수는일반몬스터에게가하는피해감소이며받는피해감소와다름',choices:'event_choices는사건후보+1최대4,분기수/AP/확률아님',gold:'kill_gold는이후몬스터처치당추가골드,currentgold지급은branch.gold'},checks:['인질·원작승패·타인숙박·영체화·계약·보구를여행자가결정하는가?','방패생성·실제순찰·추가처치·새사격·미니게임·안전구역을기능으로약속하는가?','실제지정카드와받는피해/일반몬스터피해의축·확률·골드·물약·필드가다른가?','실제남은행동과인물반응이있는가,칭찬만하거나빈정리인가?']}});
console.log(JSON.stringify({newCards:7,newRoots:4,newFollowups:1,changes:changes.length,rewardReferenceCorrections:rewardReferenceCorrections.length,check}));
