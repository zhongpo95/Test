// 나비저택의 채택할 여섯 독립 사건을 실제 선택 수치와 대조해 검토 후보로 묶는다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..'),repo=path.resolve(__dirname,'../../..');
const old=JSON.parse(fs.readFileSync(path.join(repo,'content/roguelite/13-butterfly.json'),'utf8'));
const original=JSON.parse(fs.readFileSync(path.join(root,'drafts/butterfly-expansion-04.json'),'utf8')).parsed;
const request=JSON.parse(fs.readFileSync(path.join(root,'requests/butterfly-expansion-04.json'),'utf8'));
const cards=JSON.parse(fs.readFileSync(path.join(root,'drafts/butterfly-cards-05.json'),'utf8')).parsed.cards;
const removed=JSON.parse(fs.readFileSync(path.join(root,'revisions/butterfly-expansion-rejected-04.json'),'utf8')).removed;
const events=original.events.filter(x=>!removed.some(r=>r.key===x.key)),changes=[];
function edit(obj,field,value,key,reason){if(JSON.stringify(obj[field])===JSON.stringify(value))return;changes.push({key,field,before:obj[field],after:value,reason});obj[field]=value;}
for(const event of events){
 const plan=request.brief.plans.find(x=>x.key===event.key);
 if(event.choices.length!==plan.choices.length)throw Error('선택수 변경. '+event.key);
 for(const [i,choice]of event.choices.entries())for(const field of ['card','card2','cost','level','density','gold','potions','chance'])edit(choice,field,plan.choices[i][field],event.key+'#'+(i+1),'집필 원안의 확정 수치·null·참조와 대조한다.');
 edit(event,'failure',plan.failure||null,event.key,'확률이 있는 사건만 실패 문장을 가진다.');
}
for(const plan of request.brief.newCards){const c=cards.find(x=>x.key===plan.key);if(!c)throw Error('카드 누락. '+plan.key);for(const field of ['name','grade','effects','evolution'])if(JSON.stringify(c[field])!==JSON.stringify(plan[field]))throw Error('카드 계획과 다름. '+c.key+'.'+field);}
if(cards.length!==6)throw Error('새 카드6개 필요.');
const ec=k=>events.find(x=>x.key===k);
function text(key,story,intro,labels,results,fact){const event=ec(key);edit(event,'story',story,key,'제작 해설을 빼고 다른 물건·부탁과 남은 문제를 장면으로 표현한다.');edit(event,'intro',intro,key,'행동할 문제를 요약한다.');if(labels)labels.forEach((v,i)=>edit(event.choices[i],'label',v,key+'#'+(i+1),'비용과 맡는 범위의 연결을 드러낸다.'));results.forEach((v,i)=>edit(event.choices[i],'result',v,key+'#'+(i+1),'카드의 준비·보수 제공자·남겨 둔 부탁과 개인 사냥 부담을 실제 보상에 맞춘다.'));edit(event,'canonFact',fact,key,'확인한 원작 소재와 별도 창작 문제를 구분한다.');}
text('kny_unread_bottles','비에 젖은 보급 상자를 열자 병의 이름표가 번져 있다. 시노부는 이름을 모르는 것을 먼저 쓰지 말라고 하고, 아오이는 확인한 병과 빈 용기부터 따로 놓는다. 젖지 않은 기록지가 있기는 하지만 전부 대조하려면 준비물이 더 필요하다.','기록까지 확인할지, 확실한 보급만 챙길지 정한다.',[
 '새 이름표를 사서 시노부와 병의 기록을 대조한다','포장 재료를 사서 아오이와 확인된 보급만 챙긴다','빈 용기 운반만 돕고 일당과 확인된 물약을 받는다'
],[
 '이름표 값을 치르고 기록과 맞는 병을 나누었다. 시노부에게 출발 전에 회복 준비를 확인하는 요령을 듣고 챙겼다. 끝내 읽히지 않는 병은 따로 남겨 함부로 사용하지 않는다.',
 '포장 재료를 마련해 확인된 보급만 묶었다. 아오이가 짐을 나누는 순서와 회복 준비를 보여 준다. 기록을 전부 복원하지는 않고, 모르는 병은 다음 확인자에게 남긴다.',
 '빈 용기를 옮기고 운반 일당과 이름이 확인된 물약 하나를 받았다. 번진 이름표는 손대지 않고 내려놓았다. 병의 사용법을 새로 익히지는 못했다.'
],'공식 저택 치료·시노부 약학·아오이 지원에서 별도 젖은 보급 문제를 창작한다. 보급병·기록지는 실제 퀘스트 물품이 아니며 미확인 약 사용이나 즉시 치료를 구현하지 않는다.');
text('kny_white_linen','회복 중인 사람들에게 건넬 흰 천을 말리려는데 비가 그치지 않는다. 아오이는 아직 마르지 않은 묶음을 펼쳐 보이고, 이노스케는 돌아가면 마른 보급을 가져올 길이 있다고 나선다. 오늘 맡을 길목을 넓혀 가져올지, 필요한 만큼만 새로 구할지 정해야 한다.','새 천을 구하거나 돌아가는 길을 맡거나 필요한 범위만 줄인다.',null,[
 '새 천 값을 내고 필요한 몫을 나누어 묶었다. 아오이에게 다시 빠뜨리지 않도록 보급을 정리하는 준비를 배웠다. 젖은 천은 그대로 말려 두고 오늘 쓸 분량부터 건넨다.',
 '이노스케와 돌아가는 길에서 보급을 옮겼다. 길을 살피며 발을 움직이는 요령을 익힌 대신, 넓어진 내 구역에는 적이 더 많이 드나든다. 길 전체가 안전해진 것은 아니다.',
 '좁은 길목만 맡기로 하고 출발용 물약 하나를 챙겼다. 내 구역의 적 수는 줄지만 새 천을 모두 마련하지는 못했다. 남은 묶음은 저택에 두고 필요한 일만 돕는다.'
],'공식 나비저택 치료와 아오이 지원, 이노스케 산 감각에서 마르지 않은 천과 돌아가는 보급길을 별도로 창작한다. 환자 상태·옷 장비·NPC 운반은 생성하지 않는다.');
text('kny_crow_dispatch','전령 까마귀가 새 임무를 빠르게 읽는다. 맡을 일을 놓쳐 같은 문장을 다시 듣자 탄지로가 숨을 고르고 확인할 순서를 정하자고 한다. 아오이는 설명을 듣는 동안 출발할 보급을 묶고 있지만, 아직 빠진 준비물이 있다.','안내를 확인할지, 보급을 맞출지, 기록만 맡을지 정한다.',[
 '기록용품을 사서 탄지로와 맡을 일을 다시 확인한다','부족한 포장을 마련해 아오이와 출발 목록을 맞춘다','안내를 옮겨 적는 일만 맡고 보수를 받는다'
],[
 '기록용품을 마련하고 서두를 때도 호흡을 흐트러뜨리지 않으며 안내를 다시 나누어 들었다. 탄지로와 배운 준비를 챙겼지만, 맡기지 않은 임무까지 새로 받지는 않는다.',
 '부족한 포장 값을 내고 아오이와 가져갈 몫을 나눴다. 출발 중에도 준비를 이어갈 요령을 챙겼다. 까마귀의 긴 안내를 전부 정리하는 일은 다른 사람에게 남긴다.',
 '까마귀가 읽는 안내를 기록지에 옮기고 기록 일당을 받았다. 기록을 넘긴 뒤 보급 준비는 떠날 사람에게 맡긴다. 새 임무 장소로 이동하지 않고 현재 구역으로 돌아간다.'
],'공식 26화의 전령 까마귀와 새 임무 안내에서 별도 기록 혼선을 창작한다. 특정 본편 임무를 해결하거나 실제 목적지·남은 시간을 바꾸지 않는다.');
text('kny_midday_noise','출발할 짐을 묶는 소리와 발소리가 뒤섞이자 젠이츠가 문턱에서 멈춘다. 한꺼번에 들린 소리 중 무엇을 먼저 확인할지 망설이는 사이, 탄지로는 짐 자루에 묻은 풀을 살핀다. 모든 소리를 없앨 수는 없으니 소리를 줄이거나 확인할 순서를 바꿀 수 있다.','짐 소리를 줄이거나 주변 흔적을 먼저 보거나 맡을 범위를 줄인다.',[
 '완충천을 사서 짐 소리를 줄이고 젠이츠와 움직일 순간을 맞춘다','조사 도구를 사서 탄지로와 주변 흔적부터 확인한다','맡을 길목을 한 곳 줄이고 물약을 챙긴다'
],[
 '완충천 값을 내고 부딪치는 짐을 다시 묶었다. 남은 소리 사이에서 한 번 움직일 순간에 집중하는 젠이츠의 준비를 챙겼다. 모든 소리를 알아듣는 능력을 얻은 것은 아니다.',
 '조사 도구를 마련하고 짐에 묻은 것과 주변 자국을 차례로 비교했다. 탄지로가 짚어 준 상대를 관찰하는 요령을 공격 준비에 남겼다. 소리 자체는 남아 있지만 확인할 순서는 정했다.',
 '맡을 길목을 하나 넘겨 내 구역의 적 부담을 줄이고 보급 물약을 받았다. 많은 소리를 구분하는 일은 남겨 두었다. 출발 전 챙기는 범위만 줄인 것이다.'
],'공식 젠이츠 청각과 탄지로 후각을 별도 소란스러운 출발 장면으로 각색한다. 실종자·밤길 수색을 반복하거나 소리 탐지 UI를 지급하지 않는다.');
text('kny_mixed_traces','저택 밖 보급길의 자국은 한 방향으로 이어지는데, 젖은 짐과 풀 냄새는 서로 다르게 남아 있다. 탄지로는 보이는 자국만 곧장 따르지 않고 냄새가 갈라지는 곳을 짚는다. 이노스케는 주변 길까지 직접 맡으면 알 수 있다고 나선다.','조사비와 강한 구역을 감수해 확인할지, 넓은 길을 맡을지, 확인한 곳만 남길지 정한다.',null,[
 '탄지로와 남은 흔적을 나누어 확인하고 조사 보수를 받았다. 관찰한 약점을 공격 준비로 남겼지만, 조사하며 맡기로 한 구역에는 더 강한 적이 남는다. 잃어버린 사람을 찾은 사건은 아니다.',
 '이노스케와 주변 길목을 넓게 맡았다. 빠르게 길을 살피는 준비를 챙긴 대신 내 구역에 더 많은 적이 드나든다. 냄새가 남은 이유를 전부 밝혀 낸 것은 아니다.',
 '확인한 곳만 기록에 남기고 조사 일당을 받았다. 맡을 길목을 한 곳 줄였지만 다른 흔적은 더 따라가지 않았다. 적이 없어지는 대신 내 구역의 부담만 줄어든다.'
],'공식 탄지로 후각·이노스케 산 감각에서 별도 보급길 흔적을 창작한다. 확률 70은 맵 판정이며 원작 감각이 실패했다는 본편 장면을 재현하지 않는다.');
text('kny_before_departure','떠나려던 순간 보급낭의 바닥이 벌어져 준비한 것들이 떨어졌다. 시노부는 상대에 맞춰 가져갈 것을 다시 고르자고 하고, 카나오는 짐을 나누면 발을 옮기는 데 덜 걸린다고 몸으로 보여 준다. 이노스케는 큰 짐을 한쪽으로 모아 들 테니 강한 길을 맡자고 재촉한다.','벌어진 보급낭을 계기로 가져갈 준비와 맡을 부담을 다시 고른다.',[
 '새 포장을 사서 시노부와 상대에 맞는 준비만 골라 담는다','운반 도구를 사서 카나오와 움직일 순서에 맞춰 짐을 나눈다','이노스케와 큰 짐을 맡고 더 강한 길목도 받는다','보급 정리만 돕고 일당과 물약을 받는다'
],[
 '새 포장 값을 내고 상대의 특성을 살펴 가져갈 준비를 추렸다. 시노부의 조언을 관통과 강한 상대를 향한 공격 준비에 남겼다. 모든 적에게 쓸 새 독이나 약을 받은 것은 아니다.',
 '운반 도구를 마련해 발에 걸리는 짐을 나누었다. 카나오가 보여 준 움직임에 맞춰 정확히 공격할 준비를 챙겼다. 다른 사람의 짐까지 전부 정리하지는 않았다.',
 '큰 짐을 모아 맡고 이노스케에게 밀고 나가는 자세를 배웠다. 더 강한 적이 드나드는 내 구역과 방어의 빈틈은 감수해야 한다. 준비물을 모두 새것으로 바꾼 것은 아니다.',
 '떨어진 보급을 거두고 정리 일당과 물약 하나를 받았다. 벌어진 보급낭을 다시 꾸릴 일은 떠날 사람에게 남겼다. 다른 공격 자세는 새로 챙기지 않았다.'
],'공식 저택 치료·출발과 시노부 약학·카나오 신체 능력·이노스케 성향을 별도 보급낭 파손으로 각색한다. 새 독 기술·장비 수선 기능·실제 임무 전환은 없다.');
const merged={...old,cards:[...old.cards,...cards],events:[...old.events,...events]};
merged.sources=[...new Set([...old.sources,'https://kimetsu.com/anime/risshihen/story/?story=26','https://kimetsu.com/anime/character/?chara=kanawo'])];
merged.canonBoundary+=' 젖은 병 이름표·흰 천·안내 혼선·소란스러운 짐·갈라진 흔적·벌어진 보급낭은 공식 역할에서 별도로 창작한 독립 문제다. 이름 모를 병을 사용하거나 환자 상태를 바꾸지 않는다. 등장한 물건은 퀘스트 인벤토리에 저장되지 않고 지정 카드·골드·물약·개인 필드 값만 변한다.';
const check=require(path.join(repo,'tools/check-content-candidates.cjs')).inspect(merged);if(check.errors.length)throw Error(JSON.stringify(check.errors));
fs.writeFileSync(path.join(root,'revisions/butterfly-expansion-curated-05.json'),JSON.stringify(merged,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'revisions/butterfly-expansion-curation-05.json'),JSON.stringify({changes,removed,check,notes:['새9사건 중3개 미채택,6개 독립 사건 채택 후보.','새 카드6개는 별도Gemma집필에서 수치·참조를 원래 계획과 전부 대조했다.','병·짐·길목과 다른 문제를 선택 후에도 남겼다. 원작 본편 장면 재현이나 새로운 능력 지급이 아니다.']},null,2)+'\n',{flag:'wx'});
const review={review:true,system:'사건 독립 검토자다. 제공된 사실·효과·수치와 충돌하는 구체적인 문장만 지적한다. 맵의 각색과 원작을 구분한다. JSON {verdict,issues:[{key,problem,evidence,suggestion}],strengths:[string]}로 답한다.',brief:{sourceFacts:request.brief.sourceFacts,mechanics:request.brief.mechanics,existingCards:old.cards,data:{cards,events},questions:['병·천·안내·소리·흔적·보급낭이라는6문제가 원작역할과충돌하는가?','모든수치·골드비용·확률성공실패·지정카드가문장과이어지는가?','현재체력지불·실제퀘스트물품·원작호흡·독·임무이동을생성하는듯한약속이있는가?','비용을내고준비하기·넓은구역맡기·일당이라는반복이있더라도각상황에남은문제와인물반응차이가 충분한가?']}};
fs.writeFileSync(path.join(root,'requests/butterfly-expansion-review-05.json'),JSON.stringify(review,null,2)+'\n',{flag:'wx'});
console.log('나비저택 새6사건·6카드 검토 후보 보존.');
