// 첫 재검토의 오계산과 누락된 기존 카드 문맥을 보존하고 전체 획득 경로로 재검토한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');const root=path.resolve(__dirname,'..');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));const save=(p,x)=>fs.writeFileSync(path.join(root,p),JSON.stringify(x,null,2)+'\n',{flag:'wx'});
const request=read('requests/action-scenes-review-96.json'),before=read('revisions/action-scenes-before-95.json')['04-academy.json'].data;
request.brief.existingWorld=before;
request.brief.examples=[{beforeAP:1,incidentCost:1,cardMaxIncrease:1,afterAP:1,afterMax:11,otherBranchAfterAP:0},{beforeAP:5,incidentCost:1,cardMaxIncrease:1,afterAP:5,afterMax:11,otherBranchAfterAP:4},{goldCost:0,incidentCost:1,levelDelta:1,densityDelta:0,meaning:'골드는 안 쓰지만 사건 행동력1과 더 강한 개인 사냥을 부담한다.'}];
request.brief.reviewNote='96검토의 세 주장은 독립 검토에서 아래 이유로 반영하지 않았다. 앞 검토에 동의하려 하지 말고 실제 새 모순이 있으면 지적해라. 보상 카드가 추가 행동 한 번을 주는 효과다. 반드시 전투 능력이나 골드를 같이 줄 필요는 없다.';
const rejected=[{key:'card_effect_logic_conflict',why:'1-1+1=1이며0이 아니다. 원래AP와 같아도 다른 두 선택보다 한 번 더 사건을 경험한다. 최대치11은 실제보상이며 이후 재계산은 충전하지 않는다.'},{key:'required_card_dependency_loop',why:'기존29카드와18사건을 제공하지 않아 경로를 확인할 수 없었던 검토 한계다. academy_uiharu_order는 signal_answer/second_route, academy_uiharu_list는 unanswered_promise에서 지급하며 순환이 없다.'},{key:'cost_and_density_inconsistency',why:'goldcost와사건APcost는서로다르다. next_shift3은AP1/골드0/level+1이다. density0과무료사건은연관없다.'}];
save('revisions/action-scenes-review-response-97.json',{recordId:read('reviews/action-scenes-review-96.json').monitorRecordId,rejected,implementationChange:false,revisit:'실제 함수 실행이 공개된 산식이나 보유조건과 다를 때 수정한다.'});
request.brief.priorReviewResponse=rejected;save('requests/action-scenes-review-97.json',request);
