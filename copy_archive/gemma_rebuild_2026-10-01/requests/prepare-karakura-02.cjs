// 반복된 제작 설명을 제외하고 행동 결과만 구체적으로 다시 집필하도록 요청한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const base=path.resolve(__dirname,'..'),first=JSON.parse(fs.readFileSync(path.join(__dirname,'karakura-text-01.json'),'utf8'));
const plan=JSON.parse(fs.readFileSync(path.join(base,'revisions/karakura-plan-01.json'),'utf8'));
const hints={
 bl_shop_boxes:['이치고가 짐을 먼저 통과시킨다. 길 끝의 큰 흔적까지 맡아 돌아간다.','우류가 글씨뿐 아니라 물에 떨어진 쪽지를 실로 꿰어 다시 엮는다.','오리히메가 사람들의 방향을 나누어 비좁은 뒷길을 정리한다.','콘을 꺼내 짐을 나누는 동안 원래 앞길을 맡으려던 사람들이 흩어져 그 길이 붐빈다.'],
 bl_rooftop_marks:['낡은 발판을 새 재료로 고치고 아래의 막힌 길을 피해 간다.','루키아가 입구에서 적의 접근을 기다리는 동안 좁은 길에 많은 흔적이 모인다.'],
 bl_return_receipt:['우라하라가 비용을 받고 길에 맞는 준비물을 골라 같은 실수를 줄이게 한다.','차드와 운반 끈을 바꾸고 짐을 나눠 좁은 길을 비운다.'],
 bl_closed_lane:['루키아와 더 큰 발자국을 따라 사람 없는 바깥 골목을 맡는다.','차드와 새 표식을 세우고 돌아갈 때 쓸 보급품을 챙긴다.'],
 bl_light_parcel:['오리히메와 배송 쪽지 뒤의 사람 이름을 확인하고 그쪽부터 살핀다.','우라하라가 작은 묶음으로 다시 포장해 목적지별로 헷갈리지 않게 한다.'],
 bl_stray_alarm:['신호가 겹치는 지점을 찾아 경보 담당자의 수고비를 받는다. 함께 몰려든 흔적은 귀환길에 남는다.','차드가 짐을 맡아 옆길을 비우고 사람들이 돌아갈 폭을 확보한다.','우류가 어긋난 위치를 표시에서 찾아 새 쪽지에 경보 지점을 바르게 적는다.'],
 bl_unmarked_corner:['모자란 표식을 다시 마련해 루키아와 갈림길을 되짚고 돌아갈 길을 정리한다.','우라하라가 기록을 받으면서 앞서 비어 있던 위치 하나를 찾아 낸다.'],
 bl_joint_training:['준비 비용을 쓰고 이치고와 큰 적의 빈틈을 맡는다. 한 번에 힘을 모으는 동안 다음 동작은 조금 무거워진다.','차드와 지지대를 마련해 몸이 쏠리지 않을 자리를 고르고 좁은 통로를 비운다.']
};
const schema={type:'object',properties:{events:{type:'array',items:{type:'object',properties:{key:{type:'string'},results:{type:'array',items:{type:'string',maxLength:210}}},required:['key','results'],additionalProperties:false}}},required:['events'],additionalProperties:false};
const request={schema,system:'한국어 게임 사건의 행동 결과를 쓰는 작가다. 8사건의 key와 행동 순서, 결과 개수를 유지한다. 기존 초안의 "준비를 접었으며", "비용이 지출된다", "남은 적 수를 줄인다"처럼 기획 설명을 복사한 결과는 모두 폐기했다. 이번 결과는 실제 일어난 물건·길·사람의 변화를 1~2문장으로 보여 주는 소설 문장이어야 한다. 숫자, 카드 획득, 스탯, 제작 설명은 쓰지 않는다. 새 시스템·기술·관계 수치·추후 사건을 약속하지 않는다. 인물의 능력을 플레이어가 얻었다고 설명하지 않는다. 매번 칭찬·미소를 덧붙이지 않는다. 예시에서 문장만 참고하고 소재는 복사하지 않는다.',brief:{example:{action:'젖은 길드 의뢰서를 다시 정리한다',result:'루시가 마른 종이 위에 지워진 주소를 옮겨 적었다. 접힌 의뢰서가 게시판으로 돌아오자 어느 집까지 짐을 보내야 하는지 읽을 수 있게 됐다.'},facts:first.brief.facts,events:plan.events.map(e=>({key:e.key,problem:e.story,actions:e.choices.map((b,i)=>({action:b.label,changes:hints[e.key][i]}))}))}};
fs.writeFileSync(path.join(__dirname,'karakura-results-02.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log('카라쿠라 반복 결과 제외 후 재집필 요청을 보존했습니다.');
