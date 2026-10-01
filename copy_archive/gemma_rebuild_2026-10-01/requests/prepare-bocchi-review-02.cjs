// 봇치 후보의 선택 차이와 원작 연결을 별도로 검토할 요청을 보존한다.
'use strict';
const fs = require('node:fs');
const path = require('node:path');
const root = path.join(__dirname, '..');
const plan = JSON.parse(fs.readFileSync(path.join(__dirname, 'bocchi-plan-01.json'), 'utf8'));
const draft = JSON.parse(fs.readFileSync(path.join(root, 'drafts', 'bocchi-text-01.json'), 'utf8')).parsed;
const request = {
  review: true,
  system: '한국어 편집 검토를 한다. 제시된 원작 근거와 실제 카드 수치만 판단 근거로 사용한다. 인터넷을 읽었다고 하지 않는다. 최대 6개 지적이며 개수를 채우지 않는다. 문제가 없으면 issues를 빈 배열로 둔다. 한 지적마다 정확한 key와 짧은 문장 인용을 제시한다. 수정 문장을 복사하는 대신 왜 문제가 되는지 설명한다. 비전투 작품을 개인 전투 능력치로 각색하는 것 자체가 오류인 것은 아니다. 각색의 연결이 설명되는지, 선택으로 다음 경험이나 손익이 실제로 달라지는지, 서로 바꿔도 되는 말뿐인 장면인지 살핀다. 효과를 추가 구현하라고 요구하지 않는다.',
  schema: {
    type: 'object', required: ['issues', 'overall'], additionalProperties: false,
    properties: {
      issues: {type: 'array', maxItems: 6, items: {type: 'object', required: ['key', 'quote', 'reason'], additionalProperties: false, properties: {key: {type: 'string'}, quote: {type: 'string'}, reason: {type: 'string'}}}},
      overall: {type: 'string'}
    }
  },
  brief: {plan, draft, rules: ['체력을 사건 비용으로 사용하지 않는다.', '후속 사건에도 별도 행동력을 쓴다.', '플레이어 악기 연주·음악 전투·SNS·관객 수 시스템은 없다.', '기존 카드 stat을 원작 능력 그대로 구현한 것처럼 쓰지 않는다.', '미채택 후보이며 원문 지적이 채택을 보장하지 않는다.']}
};
fs.writeFileSync(path.join(__dirname, 'bocchi-review-02.json'), JSON.stringify(request, null, 2) + '\n', {flag: 'wx'});
console.log('봇치 후보의 별도 검토 요청을 보존했습니다.');
