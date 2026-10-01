// Gemma 결과의 수고비 방향과 남은 위험을 수정해 카라쿠라 검토 후보를 저장한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const base=path.resolve(__dirname,'..'),root=path.resolve(__dirname,'../../..');
const plan=JSON.parse(fs.readFileSync(path.join(__dirname,'karakura-plan-01.json'),'utf8'));
const first=JSON.parse(fs.readFileSync(path.join(base,'drafts/karakura-text-01.json'),'utf8')).parsed;
const second=JSON.parse(fs.readFileSync(path.join(base,'drafts/karakura-results-02.json'),'utf8')).parsed;
for(const e of plan.events){
 const one=first.events.find(x=>x.key===e.key),two=second.events.find(x=>x.key===e.key);
 if(!one||!two||two.results.length!==e.choices.length)throw Error('서사 개수 불일치. '+e.key);
 e.intro=one.intro;
 e.choices.forEach((b,i)=>{b.result=two.results[i];});
}
const get=key=>plan.events.find(x=>x.key===key);
const boxes=get('bl_shop_boxes');
boxes.story='우라하라 상점 앞에 네 갈래 길로 보낼 짐이 쌓였다. 콘이 끼어든 상자에는 수취인 이름이 가려져 있고, 젖어 갈라진 배송 쪽지를 이치고와 우류가 서로 다르게 읽는다. 오리히메는 사람 없는 뒷길부터 확인하자고 한다.';
boxes.choices[0].result='이치고가 짐을 먼저 통과시키고 돌아갈 길의 입구를 짚었다. 그 길 끝에는 더 큰 발자국이 이어져 있어 짐을 보내는 일만으로는 끝나지 않는다.';
boxes.choices[1].result='우류가 떨어진 쪽지 조각을 실로 이어 순서를 되찾았다. 새 종이 위에 두 주소를 따로 옮겨 적자 서로 다른 집의 짐이 한 묶음에 섞였다는 사실이 드러났다.';
boxes.choices[3].result='콘을 상자에서 꺼내고 뒤섞인 짐을 다시 나눴다. 상점의 수고비와 약품은 챙겼지만, 분류하는 동안 놓친 발자국이 앞길 쪽으로 더 모였다.';
get('bl_rooftop_marks').choices[0].result='요루이치가 짚은 낡은 발판을 새 재료로 고쳤다. 아래의 막힌 길을 피해 돌아갈 폭이 생겼고, 요루이치는 다음 발을 놓을 곳부터 보여 줬다.';
get('bl_return_receipt').choices[0].result='우라하라가 길에 맞는 표식과 묶음끈을 골라 짐 위에 놓았다. 주소만 읽고 나섰다면 빠뜨렸을 갈림길이 이제 배송 쪽지에도 표시됐다.';
get('bl_closed_lane').choices[0].result='루키아와 사람 없는 바깥 골목의 자국을 살폈다. 작은 발자국 뒤로 더 큰 흔적이 이어져 있어 돌아갈 때는 그 길을 직접 맡아야 한다.';
get('bl_light_parcel').choices[0].result='오리히메가 배송 쪽지 뒤에 남은 이름을 다시 읽었다. 먼저 살펴야 할 집을 나누고, 잃어버린 짐을 기다리는 사람에게 돌아갈 경로를 짚었다.';
get('bl_stray_alarm').choices[0].result='요루이치와 신호가 겹치는 지점을 찾아 빈 경보를 가려냈다. 경보 담당자가 수고비를 건넸지만, 추적하는 동안 다른 골목에서 몰려든 흔적은 귀환길에 남아 있다.';
get('bl_stray_alarm').choices[2].result='우류가 어긋난 표시를 대조해 두 경보가 같은 곳을 가리킨다는 점을 찾아냈다. 새 쪽지의 위치를 고치자 같은 신호를 쫓아 길을 두 번 돌아갈 필요가 사라졌다.';
get('bl_joint_training').choices[0].result='이치고와 한 번의 틈에 힘을 모으는 박자를 맞췄다. 다음 동작이 조금 무거워지는 대신 힘을 흩뜨리지 않게 되었고, 준비한 길에서는 더 큰 상대의 흔적을 맡기로 했다.';
fs.writeFileSync(path.join(__dirname,'karakura-curated-03.json'),JSON.stringify(plan,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(root,'content/roguelite/10-karakura.json'),JSON.stringify(plan,null,2)+'\n',{flag:'wx'});
console.log('카라쿠라 카드 9종과 사건 8개를 역검토 후보로 보존했습니다.');
