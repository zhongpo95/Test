// 단순 통행 안내로 보이던 오리히메 행동과 집중 공격의 서사를 확인된 역할에 맞춘다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'../../..'),file=path.join(root,'content/roguelite/10-karakura.json');
const old=fs.readFileSync(file),w=JSON.parse(old);
fs.writeFileSync(path.join(__dirname,'10-karakura-before-role-05.json'),old,{flag:'wx'});
const boxes=w.events.find(e=>e.key==='bl_shop_boxes');
boxes.story='우라하라 상점 앞에 네 갈래 길로 보낼 짐이 쌓였다. 콘이 끼어든 상자에는 수취인 이름이 가려져 있고, 젖어 갈라진 배송 쪽지를 이치고와 우류가 서로 다르게 읽는다. 오리히메는 부서진 운반대 때문에 뒷길의 짐이 멈췄다는 점을 알아챈다.';
boxes.choices[2].label='오리히메와 부서진 운반대를 복구한다';
boxes.choices[2].result='오리히메가 손을 뻗자 꺾였던 운반대의 금이 사라졌다. 새 묶음끈으로 짐을 옮겨 뒷길을 비우고, 복원된 받침이 다시 부러지지 않게 고정했다.';
boxes.canonFact='우라하라의 사신 물품 지원, 우류의 손재주, 개조혼백 콘과 오리히메의 현상 거절 능력을 활용했다. 배송 문제와 운반대 복구는 맵 창작이며 플레이어에게 새 복원 기술을 지급하지 않는다.';
const lane=w.events.find(e=>e.key==='bl_closed_lane');
lane.story='오리히메가 운반대를 복구한 뒤 짐이 통과한 뒷길은 조용해졌다. 하지만 바깥 골목의 흔적은 아직 남아 있어 루키아가 그쪽을 맡으려 한다. 차드는 돌아오는 사람이 길을 잃지 않게 표식을 더 세우자고 한다.';
lane.intro='복원한 운반대가 지나간 길 바깥에 다른 흔적이 이어진다.';
const training=w.events.find(e=>e.key==='bl_joint_training');
training.choices[0].result='이치고와 한 번의 틈에 힘을 모으는 박자를 맞췄다. 다음 동작은 조금 느려지지만 한 번에 더 무거운 일격을 모으게 되었고, 준비한 길에서는 더 큰 상대의 흔적을 맡기로 했다.';
fs.writeFileSync(file,JSON.stringify(w,null,2)+'\n');
console.log('오리히메의 복원 행동과 집중 공격의 느린 다음 동작을 명확히 했습니다.');
