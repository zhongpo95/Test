// 원작과 구현 범위를 벗어난 이누야샤 초안의 구체적인 모순을 별도 모델 검토에 넘긴다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..');
const pitches=JSON.parse(fs.readFileSync(path.join(root,'drafts/inuyasha-pitches-01.json'),'utf8')).parsed.pitches;
const request={review:true,system:'원작 설정과 게임 구현의 사실 검토자다. 초안의 canonUse 자기평가를 사실로 믿지 마라. brief의 확인된 사실과 금지 기능에 직접 대조하고 각 제안을 채택 또는 폐기하라. 제목별로 구체적인 모순 두 개 이상을 찾아라. 좋은 문장을 새로 쓰는 요청이 아니다.',schema:{type:'object',additionalProperties:false,required:['decisions'],properties:{decisions:{type:'array',items:{type:'object',additionalProperties:false,required:['title','decision','reasons'],properties:{title:{type:'string'},decision:{type:'string'},reasons:{type:'array',items:{type:'string'}}}}}}},brief:{facts:['철쇄아를 쓰는 인물은 이누야샤다. 셋쇼마루의 천생아와 구분한다.','미륵의 풍혈은 물체를 빨아들이는 저주다. 주변 생명력을 자동 흡수한다고 바꾸지 않는다.','산고의 비래골은 거대한 부메랑 형태 무기다. 풍혈 확산을 봉인하는 결계 발생 장치라고 확인하지 않았다.','싯포의 변신은 미륵의 풍혈 중심을 옮기는 능력이 아니다.','금강은 우라스에의 술법으로 되살아났다. 천생아로 금강이 부활했다고 연결하지 않는다.','금사매 마을의 협조와 금강 카드 지급은 별도 근거가 필요하다.'],source:'https://www.sunrise-world.net/titles/pickup_029.php',implementation:['현재 체력 비용·자해·일시 체력 감소·행동력 증감·특수 환각 적·보호막 생성·적 공격력 디버프는 구현하지 않는다.','shielded_damage는 이미 보호막을 유지할 때 피해 증가다. 보호막 수치를 생성하거나 늘리는 능력치가 아니다.','regeneration은 최대 체력 %/초다. 초안의 5와 8은 큰 지속 회복으로 일반 카드의 0.6~0.8%와 차이가 크다. 흡수·재생 총 10% 한도만으로 적절한 밸런스라 할 수 없다.'],pitches}};
fs.writeFileSync(path.join(root,'requests/inuyasha-review-01.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log('이누야샤 초안 설정·미구현 기능 대조 요청.');
