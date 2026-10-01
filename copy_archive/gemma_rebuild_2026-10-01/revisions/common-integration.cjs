// 공통 사건의 Gemma 서사를 검토하여 확정한 손익 데이터와 결합한다. 일회성 작업 파일이다.
const fs=require('node:fs'),path=require('node:path');
const ar='copy_archive/gemma_rebuild_2026-10-01';
const w=JSON.parse(fs.readFileSync(path.join(ar,'revisions/common-plan-01.json'),'utf8'));
const raw=JSON.parse(fs.readFileSync(path.join(ar,'drafts/common-text-01.json'),'utf8')).parsed;
const intros=['벽의 전화번호로 작은 의뢰를 맡길 수 있다.','시험철의 신사에 심부름이 몰렸다.','정리한 길목 끝에서 주소가 틀린 것을 알았다.','모피를 재는 저울과 설명이 서로 맞지 않는다.','거절당한 거래를 다른 구매자와 다시 따져 본다.','성사된 협상의 말과 영수증을 대조한다.','젖은 화물 덮개를 그대로 둘 수 없다.','호로의 귀향길과 다음 거래를 함께 준비한다.'];
for(const [i,e] of w.events.entries()){
 const r=raw.events.find(x=>x.key===e.key);
 if(!r||r.choices.length!==e.choices.length)throw Error('서사 참조 오류 '+e.key);
 e.story=r.story;e.intro=intros[i];
 e.choices.forEach((b,j)=>b.result=r.choices[j].result.replace(/합니다\./g,'했다.').replace(/받습니다\./g,'받았다.'));
}
const by=k=>w.events.find(e=>e.key===k);
by('common_five_coin').choices[0].result='야토에게 작은 의뢰를 맡기고 함께 길목을 살폈다. 그가 대단한 보상보다 약속한 일을 끝내는 모습을 보며 첫 경험을 얻었다.';
by('common_five_coin').choices[1].result='유키네가 길을 여는 동안 더 강한 적이 다니는 통로를 맡았다. 검이 닿는 간격을 살피는 경험을 얻었다.';
by('common_shrine_work').choices[1].result='유키네와 통로를 나누어 더 많은 적이 들어오는 길을 맡았다. 빠져나갈 자리를 지키며 검의 경계를 익혔다.';
by('common_lost_address').story='야토와 함께 정리한 길목 끝에서 의뢰인의 주소가 틀렸다는 사실을 알았다. 작업은 했지만 연락할 사람이 없어 마무리가 남았다. 히요리는 근처 사람들이 기억하는 길부터 확인하자고 한다.';
by('common_lost_address').choices[0].result='히요리와 주변 사람들에게 주소를 다시 물었다. 사람들이 오갈 통로를 더 열어 남은 적도 늘었지만 돌아올 길을 기억했다.';
by('common_lost_address').choices[1].result='추가 자재비를 내고 연락 지점의 통로 하나를 닫았다. 남은 적 수를 줄이고 의뢰인이 맡긴 보급 물약을 회수했다.';
by('common_fur_scale').choices[2].result='호로가 짚은 저울의 차이를 근거로 조건을 다시 제시했다. 상대가 거래를 받아들여 말 뒤에 숨은 의도를 읽는 경험을 얻었다.';
by('common_rain_cargo').choices[1].result='호로와 상대에게 화물 상태를 솔직히 알렸다. 더 강한 적이 있는 확인 장소까지 맡으며 물건보다 말의 모순을 먼저 살피는 요령을 얻었다.';
by('common_northern_route').choices[0].result='호로와 함께 우회로의 자재비를 냈다. 적이 들어오는 통로 하나를 줄이고 다음 길을 살펴볼 단서를 얻었다.';
const report=require('./check-content-candidates.cjs').inspect(w);
if(report.errors.length)throw Error(JSON.stringify(report));
fs.writeFileSync('content/roguelite/08-common.json',JSON.stringify(w,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(ar,'revisions/common-codex-02.json'),JSON.stringify(w,null,2)+'\n',{flag:'wx'});
console.log(report);
