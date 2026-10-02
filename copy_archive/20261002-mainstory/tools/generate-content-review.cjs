// 활성 사건·카드의 실제 수치와 이야기, 선택 조건을 읽기 쉬운 검토 문서로 생성한다.
'use strict';
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..'),dir=path.join(root,'content/roguelite');
const worlds=fs.readdirSync(dir).filter(f=>f.endsWith('.json')).sort().map(f=>JSON.parse(fs.readFileSync(path.join(dir,f),'utf8')));
const names={attack_percent:'공격력',damage_percent:'대미지',final_damage_percent:'최종 대미지',boss_damage_percent:'보스 피해',normal_damage_percent:'일반 몬스터 피해',crit_chance:'치명 확률',crit_damage:'치명 피해 보너스',swift:'신속',action_speed:'행동 속도',move_speed:'이동 속도',charge_speed:'차지 속도',penetration:'방관',max_health_percent:'최대 체력',damage_reduction:'피해 감소',leech:'실제 피해 흡수',regeneration:'최대 체력 재생',kill_gold:'처치 골드',event_choices:'사건 후보',moving_damage:'추가 이동 속도 40%일 때 대미지',directional_damage:'헤드·백 적중 대미지',nondirectional_damage:'비방향 공격 대미지',shielded_damage:'보호막 중 대미지',charge_damage:'차지 공격 대미지',healthy_damage:'체력 65% 이상 대미지'};
names.action_capacity='행동력 최대치 (증가분 지급)';
const effect=e=>names[e.stat]+' '+(e.value>0?'+':'')+e.value+(['swift','kill_gold','event_choices','action_capacity'].includes(e.stat)?'':e.stat==='regeneration'?'%/초':'%');
const effects=a=>a.map(effect).join(' · ')||'없음';
const grade=['','노말','레어','에픽','프리즘'];
const cards=new Map(worlds.flatMap(w=>w.cards.map(c=>[c.key,c]))),events=new Map(worlds.flatMap(w=>w.events.map(e=>[e.key,e])));
const lines=['# 검토용 사건·카드 목록','','이 문서는 활성 JSON에서 생성했다. 원작 역할을 활용한 맵 전용 창작이며, 아래 수치와 연출은 원작에 존재하는 능력이라고 주장하지 않는다. 실제 인게임 재미와 가독성은 아직 검증하지 않았다.','','사건 후보는 기본 3개·최대 4개다. 사건 진입은 표시된 행동력 0 또는 1을 사용한다. 행동력 소진 후에는 무료 사건도 등장하지 않는다. 행동력 최대치가 카드 획득·중복 강화로 늘면 증가분을 남은 행동력에 한 번 더한다. 카드는 해당 행동에 지정된 카드를 지급하고, 이미 보유한 동일 카드는 기본 효과의 50%씩 강화한다. 각성은 임시 제거하여 기본 효과만 적용한다. 확률 선택의 비용과 사냥터 변화는 실패에도 적용된다. 후속 사건은 해당 플레이어의 선택 기록과 보유 조건을 만족해야 후보에 들어오며 즉시·확정 등장은 아니다.','','사건에서는 물약을 보상으로 지급하지 않는다. 물약 사용과 소모품 효과는 유지한다. 흡수·재생은 합산 최대 체력 10%/초 한도이고 물약은 제외한다. 음수 최대 체력은 능력치 패널티이며 사건에서 현재 체력을 지불하는 비용이 아니다.','','| 구역 | 머리 효과 | 입문 카드 | 성장 카드 | 사건 |','| --- | --- | --- | --- | --- |'];
for(const w of worlds)lines.push(`| ${w.world.name} | ${effects(w.world.effects||[w.world.bonus])} | ${w.world.entryCard?cards.get(w.world.entryCard).name:'공통 사건, 머리 없음'} | ${w.cards.length} | ${w.events.length} |`);
for(const w of worlds){
 lines.push('','## '+w.world.name,'',w.world.work,'',w.canonBoundary||'확인한 인물의 역할과 맵 전용 창작을 구분한다.','','### 카드','','| 카드 | 효과 이름 | 등급 | 기본 효과 | 각성 목표와 추가 효과 | 원작과 각색 근거 |','| --- | --- | --- | --- | --- | --- |');
 for(const c of w.cards){const ev=c.evolution,goal=ev.kind===1?ev.goal+'처치':ev.kind===2?'실제 피해 '+ev.goal:ev.kind===3?'연속 무피격 '+ev.goal+'초':'없음';lines.push(`| ${c.name} | ${c.effectName} | ${grade[c.grade]} | ${effects(c.effects)} | ${goal}${ev.kind?' → '+effects(ev.effects):''} | ${c.canonFact} |`);}
 lines.push('','### 사건','');
 for(const e of w.events){
  lines.push('#### '+e.title,'',e.story,'','원작과 각색 근거. '+e.canonFact,'');
  lines.push('사건 행동력. '+(e.actionCost??1)+(e.actionCost===0?' (무료)':'')+'.','');
  if(e.previous){const parent=events.get(e.previous);lines.push(`등장 조건. 「${parent.title}」의 ${Math.abs(e.previousChoice)}번 행동 ${e.previousChoice<0?'실패':'성공'} 기록.`, '');}
  if(e.requiredCard)lines.push('보유 조건. '+cards.get(e.requiredCard).name+' · '+cards.get(e.requiredCard).effectName+'.','');
  lines.push('| 행동 | 보상 | 비용·필드 변화·판정 | 결과 |','| --- | --- | --- | --- |');
  for(const [i,b] of e.choices.entries()){
   const reward=[b.card&&cards.get(b.card).name+' · '+cards.get(b.card).effectName,b.card2&&cards.get(b.card2).name+' · '+cards.get(b.card2).effectName,b.gold&&'골드 +'+b.gold,b.potions&&'물약 +'+b.potions].filter(Boolean).join(' / ')||'후속 진행';
   const cost=[b.cost&&b.cost+'골드',b.level&&'적 단계 '+(b.level>0?'+':'')+b.level,b.density&&'동시 적 수 '+(b.density>0?'+':'')+b.density,b.chance<100&&'성공 '+b.chance+'%'].filter(Boolean).join(' / ')||'추가 비용 없음';
   lines.push(`| ${i+1}. ${b.label} | ${reward} | ${cost} | ${b.result.replace(/\n/g,' ')} |`);
  }
  if(e.failure)lines.push('','실패 결과. '+e.failure);
  lines.push('');
 }
 lines.push('공식 설정 참고. '+w.sources.map((u,i)=>`[자료 ${i+1}](${u})`).join(', ')+'.','');
}
const file=path.join(root,'md/roguelite/검토용 사건 카드 목록.md'),text=lines.join('\n');
if(process.argv.includes('--check')){if(fs.readFileSync(file,'utf8').replace(/\r\n/g,'\n')!==text)throw Error('검토 문서와 활성 JSON이 다릅니다.');}else fs.writeFileSync(file,text);
console.log('검토 문서 '+events.size+'사건, '+cards.size+'카드.');
