// 채택 후보의 이야기와 실제 손익을 묶어 Gemma의 역검토 입력을 만든다.
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'../../..'),out=__dirname;
const pairs=[['04-academy','05-mitakihara'],['06-aincrad','07-zegagrande'],['08-common']];
const schema={type:'object',properties:{findings:{type:'array',items:{type:'object',properties:{key:{type:'string'},choice:{type:'integer'},severity:{type:'string',enum:['blocker','improve','none']},reason:{type:'string'},suggestion:{type:'string'}},required:['key','choice','severity','reason','suggestion'],additionalProperties:false}}},required:['findings'],additionalProperties:false};
for(const [i,pair] of pairs.entries()){
 const worlds=pair.map(p=>JSON.parse(fs.readFileSync(path.join(root,'content/roguelite',p+'.json'),'utf8')));
 const brief=worlds.map(w=>({world:w.world.name,canonBoundary:w.canonBoundary, sources:w.sources,cards:w.cards.map(c=>({key:c.key,name:c.name,effectName:c.effectName,effects:c.effects,evolution:c.evolution})),events:w.events.map(e=>({key:e.key,story:e.story,previous:e.previous,previousChoice:e.previousChoice,failure:e.failure,choices:e.choices}))}));
 const request={review:true,schema,system:'한국어 사건·카드를 비판적으로 검토한다. 원작 세부 사실은 출처를 실제 확인하지 못하면 틀렸다고 단정하지 않는다. 현재 체력은 비용으로 쓰지 않는다. 카드의 max_health_percent 음수는 최대체력 능력치 패널티이며 현재체력 지불과 다르다. 각성 kind는 0 없음, 1 처치수, 2 실제 누적 피해, 3 연속 무피격 초다. goal을 카드 효과 수치나 등급으로 오독하지 마라. crit_damage 25는 치명타 추가 보너스 25퍼센트포인트다. 적 단계 상승은 더 강한 적, density 상승은 더 많은 근접 적이다. 결과에 쓰인 적 감소가 해당 choice의 음수 필드로 구현됐는지 확인하라. 사건 선택 시 행동력 1을 쓰고 표시된 골드 비용·필드 변화는 실패에도 적용된다. 같은 카드 이미 보유하면 100골드로 교환한다. 서사의 행동과 실제 손익이 맞는지, 미구현 효과를 약속하는지, 명백히 열등한 선택인지, 후속 조건과 사건의 말이 모순인지 검토한다. 문제 있는 사례만 최대 8개 지적하고 구체적인 key와 행동 번호를 쓴다. 개인 취향과 확정 버그를 구분하고 코드나 존재하지 않는 사실을 invent하지 않는다.',brief};
 fs.writeFileSync(path.join(out,'reverse-'+(i+1)+'-01.json'),JSON.stringify(request,null,2)+'\n',{flag:'wx'});
}
