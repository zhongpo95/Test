// 나즈린 초안의 의뢰 모순과 결과 복사를 고치고 검토용 후보와 변경 이유를 보존한다.
'use strict';
const fs = require('node:fs');
const path = require('node:path');
const root = path.join(__dirname, '..');
const plan = JSON.parse(fs.readFileSync(path.join(root,'requests/nazrin-plan-01.json'),'utf8'));
const raw = JSON.parse(fs.readFileSync(path.join(root,'drafts/nazrin-text-01.json'),'utf8')).parsed;
const prose = {
  common_nazrin_signal: {
    story:'상인이 비탈에서 빠뜨린 운반 상자를 찾아 달라며 길가에 의뢰 쪽지를 남겼다. 나즈린의 다우징 막대는 진흙 아래를 가리키지만 나무 상자인지 고철인지는 아직 알 수 없다. 들쥐들이 먹을 것부터 먹어 버렸다는 말에, 남은 반응과 수색 범위를 따로 살핀다.',
    results:[
      '비에 젖은 표시를 다시 세우고 나즈린과 여러 반응의 방향을 대조했다. 상자를 찾았다고 단정하지 않고 어떤 자리를 먼저 살필지 구분하는 경험을 남겼다.',
      '강한 기척을 피하는 나즈린이 빠져나갈 자리를 남기고 넓은 구역을 맡았다. 더 많은 적을 상대해야 하지만 좁은 곳에 몰리기 전에 돌아갈 간격을 확인했다.',
      '고철 옆에서 의뢰 쪽지의 표식이 붙은 상자를 찾아 상인에게 넘겼다. 약속한 보수와 탐색 경험을 얻었지만 깊은 구역에 남은 강한 적까지 사라지지는 않았다.',
      '입구에 쌓인 빈 상자를 운반하고 정해진 일당을 받았다. 나즈린은 비탈의 반응을 더 살피고, 당신은 운반한 물건의 수를 확인하고 일을 마쳤다.'
    ],
    failure:'진흙을 걷어 냈지만 막대가 가리킨 자리에서는 고철만 나왔다. 작업비는 돌아오지 않았고 깊은 구역의 강한 적도 그대로 남아, 의뢰 보수를 받지 못한 채 젖은 표시를 다시 살폈다.'
  },
  common_nazrin_found: {
    story:'의뢰 상자를 넘긴 자리에서 나즈린의 막대가 다른 방향으로 흔들린다. 첫 상자를 찾았어도 새 반응의 정체까지 알 수는 없고, 비탈에는 열린 구덩이와 강한 적이 남아 있다. 나즈린은 더 깊이 들어가기 전에 돌아갈 자리가 있는지 확인한다.',
    results:[
      '나즈린이 빠져나갈 비탈을 지키며 한층 강한 적이 다니는 구역을 맡았다. 끝낸 수색의 작은 추가 보수와 물러날 간격을 남겼지만 새 구역의 부담은 계속됐다.',
      '남은 상자를 옮기고 흩어진 작업 도구를 수거하여 추가 일당을 받았다. 더 넓은 뒷정리 구역을 맡은 만큼 오가는 적도 늘었다.',
      '울타리 자재를 사서 위험한 길 한 곳을 닫고 작업장에 남은 보급 물약을 챙겼다. 강한 구역 하나를 덜 맡게 되었지만 다른 수색 길의 적은 남았다.'
    ],
    failure:null
  },
  common_nazrin_false: {
    story:'의뢰 상자를 찾지 못한 자리에서 나즈린이 젖은 측정 끈을 펼친다. 표시했던 깊이와 방향을 다시 확인해야 하지만 이미 쓴 작업비는 돌아오지 않는다. 강한 적이 남은 구역을 바라보며 재측정과 남은 작업을 나눈다.',
    results:[
      '새 끈을 마련해 젖은 표시를 다시 세우고 나즈린과 반응을 구분했다. 이번에는 상자나 보수를 되찾은 것이 아니라 방향을 재는 경험을 남겼다.',
      '나즈린이 물러날 자리를 남기고 주변의 넓은 구역을 추가로 맡았다. 적은 더 늘었지만 돌아갈 틈을 놓치지 않는 간격을 확인했다.',
      '빈 상자를 옮기고 깊은 구역으로 이어진 작업 길 한 곳을 정리했다. 끝낸 작업의 일당을 받았으며 그 길의 강한 적까지 계속 맡지는 않게 됐다.'
    ],
    failure:null
  }
};
const events = plan.plan.map(e => ({key:e.key,title:e.title,story:prose[e.key].story,intro:e.intro,previous:e.previous,previousChoice:e.previousChoice,requiredCard:e.requiredCard,choices:e.choices.map((c,i)=>({...c,result:prose[e.key].results[i]})),failure:prose[e.key].failure,canonFact:'물건 탐색·들쥐의 제한·강한 상대를 피하는 원작 특징을 이용한 맵 전용 의뢰다. 보탑·비창의 원작 수색이나 성련선 결말을 재현하지 않는다.',uncertain:[]}));
const content = {world:{key:'common',name:'여행길',work:'동방프로젝트',intro:'',effects:[],entryCard:null},sources:plan.sources,canonBoundary:'나즈린의 원작 설정문·구문구수 전재에서 탐색, 들쥐의 먹이 제한, 불리한 전투를 피하는 성향을 확인했다. 개발사 사이트 직접 열기는 실패했다. 상인·상자·비용·보수·남은 적과 개인 후속은 맵의 창작이며 쥐 소환·탐지 스킬·원작 보탑을 지급하지 않는다.',cards:plan.cards,events};
fs.writeFileSync(path.join(root,'drafts/nazrin-curated-02.json'),JSON.stringify(content,null,2)+'\n',{flag:'wx'});
fs.writeFileSync(path.join(__dirname,'nazrin-curation-02.json'),JSON.stringify({raw:'../drafts/nazrin-text-01.json',candidate:'../drafts/nazrin-curated-02.json',issues:[{key:'common_nazrin_signal',reason:'상자를 찾아 달라는 의뢰인데 상인이 상자를 두고 갔다고 써 분실 상황과 모순된다.'},{key:'all_results',reason:'Gemma가 모든 결과에 선택 문장을 그대로 복사했다. 실제 성공·이득·남은 위험의 결과 장면을 새로 작성했다.'},{key:'failure',reason:'성공 카드 없음·능력이 가짜라고 단정하지 않음 같은 제작 안내를 문장에 복사했다. 고철·지출·남은 적으로 상황을 보여준다.'},{key:'common_nazrin_found',reason:'Gemma가 실제 장면 대신 플레이어가 할 수 있는 선택 목록을 이야기로 복사했다. 미확인 반응·남은 구덩이·퇴로 확인으로 고쳤다.'}],mechanicsChanged:false,originalText:raw,curatedText:prose},null,2)+'\n',{flag:'wx'});
const request = {review:true,system:'한국어로 제시된 후보를 편집 검토한다. 원작의 전체 설정을 별도로 확인한 것처럼 답하지 않는다. 최대 4개 문제이며 없다면 빈 배열로 반환한다. 각 지적은 실제 key와 짧은 문장 인용을 적고, 선택 행동·성공과 실패·이미 지출한 비용·남아 있는 적의 부담·지급하는 효과와 모순되는 구절을 짚는다. 기존 stats의 서사적 각색은 허용하지만 쥐 소환·새 회피 기술·의뢰 아이템·치유를 플레이어에게 지급하지 않는다. failure는 최초 선택의 작업비와 적 단계 증가가 남고 카드와 골드는 주지 않는다. 개인 후속은 성공 또는 실패 중 하나만 열리고 추가 행동력을 소모한다.',schema:{type:'object',required:['issues','overall'],additionalProperties:false,properties:{issues:{type:'array',maxItems:4,items:{type:'object',required:['key','quote','reason'],additionalProperties:false,properties:{key:{type:'string'},quote:{type:'string'},reason:{type:'string'}}}},overall:{type:'string'}}},brief:{candidate:content}};
fs.writeFileSync(path.join(root,'requests/nazrin-review-02.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
console.log('나즈린 후보의 수정 전후와 별도 검토 요청을 보존했습니다.');
