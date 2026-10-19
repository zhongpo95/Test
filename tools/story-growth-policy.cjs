// 작품별 완결 핵심과 기본 상품 가격의 검증 기준이다. 실제 원고는 content/roguelite에서 관리한다.
'use strict';
const specs={
 fuyuki:['e_skill_damage',120,25,'e_skill_damage','crit_chance'],axel:['r_skill_damage',90,20,'r_skill_damage','skill_haste'],
 abydos:['q_skill_damage',100,22,'q_skill_damage','attack_percent'],academy:['w_skill_damage',120,25,'w_skill_damage','skill_haste'],
 mitakihara:['shielded_damage',50,15,'q_skill_damage','skill_haste'],aincrad:['action_speed',30,8,'action_speed','basic_damage'],
 zegagrande:['c_skill_damage',100,22,'c_skill_damage','boss_damage_percent'],magnolia:['f_skill_damage',120,25,'f_skill_damage','attack_percent'],
 karakura:['penetration',30,6,'penetration','crit_damage'],penacony:['crit_chance',50,10,'crit_chance','crit_damage'],
 amestris:['attack_percent',60,12,'attack_percent','penetration'],butterfly:['charge_speed',40,10,'charge_speed','charge_damage'],
 gourmet:['d_skill_damage',120,25,'d_skill_damage','attack_percent'],amphoreus:['final_damage_percent',25,5,'damage_percent','boss_damage_percent'],
 phantom_blood:['directional_damage',40,10,'directional_damage','crit_damage'],madolche:['crit_damage',100,25,'crit_damage','crit_chance'],
 tengu:['s_skill_damage',90,20,'s_skill_damage','skill_haste'],ikebukuro:['move_speed',20,8,'move_speed','action_speed'],
 frieren:['skill_haste',100,20,'skill_haste','e_skill_damage'],dungeon_meshi:['leech',20,3,'attack_percent','action_speed'],
 hunter_exam:['a_skill_damage',100,22,'a_skill_damage','crit_chance'],roswaal_mansion:['healthy_damage',50,8,'attack_percent','skill_haste'],
 z_city:['normal_damage_percent',80,20,'normal_damage_percent','basic_damage'],witch_prison:['damage_percent',40,8,'damage_percent','crit_chance'],
 persona5:['boss_damage_percent',60,15,'boss_damage_percent','crit_damage'],persona5_royal:['final_damage_percent',25,5,'damage_percent','skill_haste'],
 hakugyokurou:['nondirectional_damage',50,12,'nondirectional_damage','q_skill_damage'],scarlet_mist:['dash_cooldown_reduction',50,5,'move_speed','skill_haste'],
 common:['attack_percent',0,8,'attack_percent','skill_haste']
};
const prices={attack_percent:[4,250],crit_chance:[3,300],crit_damage:[8,300],skill_haste:[5,400],action_speed:[4,300],basic_damage:[8,350],penetration:[2,400],charge_speed:[5,300],charge_damage:[6,350],move_speed:[3,300],directional_damage:[6,350],nondirectional_damage:[6,350],normal_damage_percent:[10,250],boss_damage_percent:[6,350],damage_percent:[3,350]};
for(const k of ['q','w','e','r','a','s','d','f','c'])prices[k+'_skill_damage']=[6,350];
const names={attack_percent:'공격력',crit_chance:'치명타 확률',crit_damage:'치명타 피해',skill_haste:'스킬가속',action_speed:'공격 속도',basic_damage:'일반 공격 대미지',penetration:'방어력 관통',charge_speed:'차지 속도',charge_damage:'차지 공격 대미지',move_speed:'이동 속도',directional_damage:'헤드·백 피해',nondirectional_damage:'비방향 피해',normal_damage_percent:'일반 몬스터 피해',boss_damage_percent:'보스 피해',damage_percent:'대미지',final_damage_percent:'최종 대미지',leech:'흡혈',regeneration:'체력 재생',shielded_damage:'보호막 중 피해',healthy_damage:'체력 65% 이상 피해',dash_cooldown_reduction:'대시 재사용 감소',move_damage_scale:'추가 이동속도당 피해',recovery_speed:'흡혈 회복 속도'};
for(const k of ['q','w','e','r','a','s','d','f','c'])names[k+'_skill_damage']=k.toUpperCase()+' 스킬 대미지';
const text=effects=>effects.map(e=>names[e.stat]+' +'+e.value+(e.stat==='skill_haste'?'':'%')).join(' · ');

names.chosen_skill_damage='선택한 스킬 대미지';
prices.chosen_skill_damage=[6,350];
module.exports={specs,prices,names,text};
