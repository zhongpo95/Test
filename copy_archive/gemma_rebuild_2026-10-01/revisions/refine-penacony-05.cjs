// 손님 무리를 적으로 오독할 표현과 당첨 예언 문장을 정리해 귀환 부담을 연결한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'../../..'),file=path.join(root,'content/roguelite/11-penacony.json');
const w=JSON.parse(fs.readFileSync(file,'utf8'));fs.writeFileSync(path.join(__dirname,'11-penacony-before-return-05.json'),JSON.stringify(w,null,2)+'\n',{flag:'wx'});
const get=k=>w.events.find(e=>e.key===k);
w.canonBoundary+=' 손님 무리가 몬스터로 변하는 것이 아니다. 추가 안내·짐을 맡아 귀환 구간이 늘거나 혼잡한 길을 피하는 부담을 개인 사냥터 변화로 대응한다.';
get('hsr_dreamy_slots').choices[2].label='코인을 정리하고 모인 손님들의 귀환 안내를 맡는다';
get('hsr_dreamy_slots').choices[2].result='굴러다니는 코인을 자루에 담아 안내대에 넘기고 수고비와 보급품을 받았다. 모여든 손님들의 귀환 안내까지 맡아 더 넓은 길을 확인해야 했다.';
get('hsr_after_win').choices[0].label='스파클의 배역에 맞추고 손님들을 먼 출구로 안내한다';
get('hsr_after_win').choices[0].result='스파클이 바뀐 배역으로 박수의 방향을 돌리자 빈자리가 보였다. 그 박자에 맞춰 무대 밖으로 나와 손님들을 먼 출구까지 안내하느라 더 넓은 길을 맡았다.';
get('hsr_after_loss').choices[0].result='블랙 스완과 회전판보다 손을 멈추지 못했던 장면을 먼저 돌아봤다. 다음 판을 맞히는 답은 얻지 못했지만, 어떤 제안에 흔들렸는지 기억을 정리했다.';
get('hsr_soulglad').choices[2].label='안내대의 보급 짐과 추가 귀환 안내를 맡는다';
get('hsr_soulglad').choices[2].result='안내대의 짐을 먼저 쓸 것과 나중에 찾을 것으로 나누고 수고비를 받았다. 짐을 맡긴 손님들의 귀환 안내도 받아 평소보다 넓은 길을 확인해야 했다.';
get('hsr_walking_sign').choices[2].label='광고판을 따라온 손님들의 귀환까지 맡는다';
get('hsr_walking_sign').choices[2].result='광고판을 따라온 사람들에게 멈춰 있는 안내 표시를 알려 주고 수고비와 보급품을 받았다. 뒤에서 합류한 손님들의 귀환까지 맡아 더 넓은 길을 확인했다.';
fs.writeFileSync(file,JSON.stringify(w,null,2)+'\n');console.log('귀환 안내와 사냥터 부담의 연결을 정리했습니다.');
