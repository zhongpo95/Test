// 학원도시 초안의 고체력 효과 반전과 내부 키 노출을 고쳐 현장 이야기로 재검토한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const write=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const fixed=read('requests/academy-expansion-fixed-58.json'),draft=read('drafts/academy-expansion-text-58.json').parsed,current=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/04-academy.json'),'utf8'));
assert.deepEqual(draft.events.map(e=>e.key),fixed.events.map(e=>e.key));
const changes=[],edit=(o,k,v,key,reason)=>{if(o[k]===v)return;changes.push({key,field:k,before:o[k],after:v,reason});o[k]=v;};
const events=fixed.events.map((p,i)=>{assert.equal(draft.events[i].choices.length,p.choices.length);return {key:p.key,title:p.title,story:draft.events[i].story,intro:draft.events[i].intro,previous:p.previous||null,previousChoice:p.previousChoice||0,requiredCard:null,choices:p.choices.map((b,j)=>({label:draft.events[i].choices[j].label,result:draft.events[i].choices[j].result,card:b.card,card2:b.card2,cost:b.cost,gold:b.gold,level:b.level,density:b.density,potions:b.potions,chance:b.chance})),failure:p.failure||null,canonFact:p.canonFact,uncertain:[]};});
const stories=[
 '토우마가 동전을 삼킨 자판기를 보며 남은 한 닢을 꺼내자 미코토는 익숙한 방법이 있다며 발을 보낸다. 네 손에도 아직 마시지 못한 음료값이 남아 있고 토우마는 네 동전까지 같은 곳에 넣을 필요는 없다고 말한다. 다른 가게는 아직 열려 있지만 자판기 앞의 두 사람은 그쪽을 보고 있지 않다.',
 '케이크를 막 나누려던 쿠로코가 호출을 듣고 일어서자 우이하루는 아직 들지 못한 자기 찻잔을 본다. 사텐은 돌아올 때도 남아 있겠냐고 묻고 쿠로코는 나갔다 온 뒤의 이야기까지 지금 못 한다고 말한다. 네 손에는 포장하지 않은 간식과 가져갈 짐이 남아 있다.',
 '쿠로코가 먼저 나설 준비를 하는데 우이하루는 네가 맡을 일에도 아직 대답을 듣지 못했다고 말한다. 쿠로코는 이미 들은 이야기라며 앞을 보고 우이하루는 누가 대답한 것이냐고 되묻는다. 너는 아직 자기 몫을 말하지 않았고 두 사람 사이에도 답하지 못한 말이 남아 있다.',
 '오락실에서 학생이 중간에 떠나자 테츠소는 방금 하려던 말과 버튼 사이에 손을 멈춘다. 좋아하던 게임인데도 누구에게 말을 이어야 할지 몰라 자기 옆의 빈 의자를 보고 있다. 네 다음 동전과 아직 누르지 않은 버튼이 같은 자리에서 기다리고 있다.',
 '성하제에서 너를 안내하던 미코토가 다음 전시를 가리키다가 자기 무대 차례를 떠올려 말을 멈춘다. 우이하루는 전시를 더 보고 싶어 하고 사텐은 미코토에게도 돌아갈 자리가 남아 있냐고 묻는다. 네가 더 구경할 전시와 미코토가 기다리는 무대의 방향이 갈라진다.',
 '다른 곳에서 음료를 마련했던 네 앞에서 미코토가 아직 뜯지 않은 자기 몫을 내려놓는다. 토우마는 자판기에 남은 동전부터 떠올리고 미코토는 지금 손의 것을 마시기 전에 또 같은 기계를 볼 것이냐고 묻는다. 네가 마련한 보급은 손에 있는데 다음 준비는 아직 끝나지 않았다.'
];
const intros=['남은 동전도 같은 자판기에 넣어야 할까?','돌아올 한 잔과 가져갈 짐 중 자기 몫을 정한다.','들은 대답과 내가 하지 않은 대답이 어긋났다.','빈 의자 옆에서 내 다음 동전을 쓸까?','전시를 더 볼까, 무대 앞에서 기다릴까?','손에 든 음료를 열기 전에 남은 준비를 정한다.'];
const results=[
 ['다른 음료값160골드를 내고 자기 남은 몫을 챙겼다. 삼킨 동전 뒤에도 준비를 찾는 기억으로 처치 골드가 늘고 받는 피해가 줄었다. 토우마는 네 음료와 자기 손의 한 닢을 번갈아 본다.',
  '더 강한 개인 사냥을 맡는 부담을 택하고 미코토와 준비의 끝을 기다렸다. 차지 준비 속도와 최대 체력이 늘었다. 미코토는 자판기를 한 번 더 보다가 네 손에 남은 준비를 묻는다.',
  '더 많은 개인 사냥을 맡는 부담을 택하고 토우마와 남은 몫을 나누었다. 처치 골드가 늘고 받는 피해가 줄었다. 토우마는 자기 동전까지 같은 몫으로 세지 말라며 한 닢을 다시 쥔다.',
  '전달할 짐을 옮긴 보수로110골드와물약1개를 받았다. 자판기 앞에 가려졌던 공간은 비었지만 토우마는 아직 자기 동전의 자리를 보고 있다.'],
 ['포장값180골드를 내고 돌아올 한 잔을 남겼다. 급히 나서도 자기 몫을 남기는 기억으로 신속과 체력65%이상일 때 가하는 피해가 늘었다. 사텐은 포장된 쪽을 보고 자기 잔까지 남겨야 하냐고 묻는다.',
  '더 많은 개인 사냥을 맡는 부담을 택하고 우이하루의 남은 답을 기다렸다. 사건 후보와 보스에게 가하는 피해가 늘었다. 우이하루는 아직 들지 못한 잔을 내려놓고 쿠로코가 나갈 쪽을 본다.',
  '자기 짐을 옮긴 보수로130골드와물약1개를 받았다. 사텐의 찻잔은 자리에 남았고 쿠로코는 돌아올 때의 말까지 아직 하지 못했다.'],
 ['준비값180골드를 내고 자기가 맡을 일을 끝까지 답했다. 남은 질문을 놓치지 않는 기억으로 사건 후보와 보스에게 가하는 피해가 늘었다. 우이하루는 네 대답을 들었지만 쿠로코 쪽에는 아직 묻던 말이 남아 있다.',
  '더 강한 개인 사냥을 맡는 부담을 택하고 쿠로코의 다음 행동을 기억했다. 행동속도가 늘고 받는 피해가 줄었다. 쿠로코는 네가 맡을 몫과 자기 앞에 남은 질문을 따로 본다.',
  '자기가 맡을 사냥의 적 수를 줄이고 남은 전달물의 보수100골드를 받았다. 우이하루에게는 자기 몫을 줄였다고 전했고 두 사람이 서로 답할 약속은 아직 남아 있다.'],
 ['자기 다음 차례값200골드를 내고 남은 버튼을 지켜봤다. 다음 입력을 기다리는 기억으로 행동속도와 비방향 공격 피해가 늘었다. 테츠소는 빈 의자에 이어 하려던 말을 아직 버튼 앞에 남긴다.',
  '더 많은 개인 사냥을 맡는 부담을 택하고 테츠소와 다음 입력의 간격을 봤다. 행동속도와 비방향 공격 피해가 늘었다. 테츠소는 학생이 앉았던 자리보다 아직 자기 손 앞의 버튼을 먼저 본다.',
  '반납할 물품을 운반한 보수로140골드와물약1개를 받았다. 테츠소 옆 의자는 비었지만 네가 내려놓은 짐은 그 자리를 가리지 않게 옮겼다.'],
 ['기다릴 준비값210골드를 내고 무대 앞의 호흡을 기억했다. 차지 공격 피해와 치명타 피해가 늘었다. 미코토는 자기 차례를 떠올린 뒤에도 우이하루가 보고 싶다던 전시를 한 번 더 가리킨다.',
  '더 강한 개인 사냥을 맡는 부담을 택하고 미코토와 준비의 끝을 기다렸다. 차지 준비 속도와 최대 체력이 늘었다. 사텐은 미코토에게 물었던 돌아갈 자리를 아직 가리키고 있다.',
  '안내를 마친 짐을 운반한 보수로150골드와물약1개를 받았다. 우이하루와 사텐이 구경할 쪽은 비었고 미코토는 다음 전시와 무대 사이에서 다시 말을 잇는다.'],
 ['다음 보급값120골드를 내고 준비를 끝낼 때를 맞췄다. 미코토의 짧은 기다림을 기억해 차지 준비 속도와 최대 체력이 늘었다. 토우마는 자판기에 남은 동전보다 이제 손에 든 짐을 먼저 챙긴다.',
  '더 많은 개인 사냥을 맡는 부담을 택하고 미코토의 짧은 호흡을 기억했다. 차지 공격 피해와 치명타 피해가 늘었다. 미코토는 아직 뜯지 않은 자기 음료를 들고 토우마의 다음 말을 기다린다.',
  '남은 짐을 반환한 보수로150골드와물약1개를 받았다. 토우마는 내려놓은 짐을 보고 자기 손에도 아직 남은 것이 있다는 듯 한 닢을 다시 챙긴다.']
];
events.forEach((e,i)=>{edit(e,'story',stories[i],e.key,'공식 사실의 창작 방문과 당장 남은 손·말을 유지한다. 역할 대체 금지 같은 구현 제약과 선택해야 한다는 안내 문장은 사건 이야기에서 제거한다.');edit(e,'intro',intros[i],e.key,'제약을 설명하는 대신 지금 남은 문제를 짧게 적는다.');e.choices.forEach((c,j)=>edit(c,'result',results[i][j],e.key+'#'+(j+1),'내부 카드 key 노출과 능력치 목록을 성장 기억으로 바꾸고 쿠로코의 고체력 가하는 피해를 받는 피해 감소로 반전한 오류를 고친다. 지불·필드·골드·물약·인물에게 남은 행동을 연결한다.'));});
edit(events[5],'title','아직 뜯지 않은 한 잔',events[5].key,'부정 비교 제목보다 자기 앞선 선택에서 남은 실제 소품을 제목으로 쓴다.');
const candidate={...current,sources:[...new Set([...current.sources,...fixed.sourceFacts.map(s=>s.source)])],cards:[...current.cards,...fixed.cards],events:[...current.events,...events]};
candidate.canonBoundary+=' 자판기에남은동전·호출뒤간식·여행자가답할약속·오락실빈의자·성하제의무대준비는공식소개에서각색한서로다른방문이다. 자판기뒤음료후속은자신이별도음료를마련한성공1번에서만열린다. 원작자판기파괴·미사카동생실험·쿠로코와우이하루의화해·피습·성하제공연종류/승패를바꾸지않고실제NPC동행/미니게임/원작초능력/음료아이템/사냥중추가처치가생기지않는다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(candidate);assert.deepEqual(check.errors,[]);assert.deepEqual(check.warnings,[]);
write('revisions/academy-expansion-curated-59.json',candidate);write('revisions/academy-expansion-curation-59.json',{sourceRevision:'8c8ff70',raw:'drafts/academy-expansion-text-58.json',changes,check,numericExceptions:[]});
write('requests/academy-expansion-review-59.json',{review:true,schema:read('requests/mitakihara-expansion-review-20.json').schema,system:'한국어 독립 검토자다. story·result를 그 사건 choices의 card/cost/gold/potions/level/density/chance와 직접 비교한다. 실제 불일치만 issues에 적고 단순 취향이나 검증하지 않은 실전 밸런스를 오류로 단정하지 않는다. PASS 또는 REVISE를 판단하고 새로운 스탯이나 가격을 제안하지 않는다.',brief:{sourceFacts:fixed.sourceFacts,cards:[...fixed.cards,current.cards.find(c=>c.key==='academy_kuroko_response')],events,mechanics:{eventCost:'모든사건진입AP1',pause:'사건중개인사냥정지,실제추가처치없음',field:'각선택level/density는이후개인사냥에지속. cost와필드를먼저적용',reward:'성공일때만card/gold/potions. 실패에도비용과필드유지. 중복card는100골드',headAndHistory:'머리가있어야관련사건이열리고음료후속은자기자판기사건성공1번만',healthy:'healthy_damage는내체력65%이상일때가하는대미지추가. 받는피해감소는damage_reduction',health:'최대체력성장은현재/최대비율보존,즉시체력비율회복없음'},checks:['원작인물에게기술·화해·승패·원작장비·관리자권한·학생의사정을플레이어가대신정하는가?','실제NPC손을조작하거나게임기전원을끄고미니게임/음료아이템/원작초능력을새기능으로약속하는가?','각선택의지불·골드·물약·지속강함/수가결과와다른가?','후속이앞선성공에서이미얻도록보장된동일카드를또주는가?']}});
console.log(JSON.stringify({newCards:6,newRoots:5,newFollowups:1,changes:changes.length,check}));
