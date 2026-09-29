// 첸 E·R의 실제 JASS 콜백을 모의 실행하여 돌진 피해와 시전별 중복 타격을 검증한다.
const fs = require('node:fs'), path = require('node:path'), assert = require('node:assert/strict');
const {environment} = require('./check-expedition.cjs');
let checks = 0;
const check = (name, fn) => {fn(); checks++; console.log('PASS ' + name);};
function fresh(skill) {
  const file = `Hero/Chen/HeroChen${skill}.j`;
  const source = fs.readFileSync(path.join(__dirname, '..', file), 'utf8');
  const timers = [], groups = [], hits = [], enemies = [];
  let expired, enumerated, e;
  const no = () => {};
  const extras = {
    CheckG: null, HeroSkillVelue2: [0,0,0,0,.513], HeroSkillVelue3: [0,0,0,0,1.293],
    HeroSkillCD2: [0,0,0,0,16], HeroSkillCD3: [0,0,0,0,30], Arcana_ChargeSpeed: [1,1], EffectOff: [true,true],
    CastingTextFrame: 0, CastingBar: 0, SkillSpeed: () => 0,
    GetSpellAbilityId: () => skill === 'E' ? 'A019' : 'A01C', GetTriggerUnit: () => e.MainUnit[e.eventPlayer],
    GetSpellTargetX: () => 1000, GetSpellTargetY: () => 0, AngleWBP: () => 0,
    GetOwningPlayer: u => u.p, GetWidgetX: u => u.x, GetWidgetY: u => u.y,
    IsUnitDeadVJ: u => u.dead, IsUnitInRangeXY: (u,x,y,r) => Math.hypot(u.x-x,u.y-y) <= r,
    GetEnumUnit: () => enumerated, IsUnitInGroup: (u,g) => g.has(u), GroupAddUnit: (g,u) => g.add(u),
    PolarX: (r,a) => r*Math.cos(a*Math.PI/180), PolarY: (r,a) => r*Math.sin(a*Math.PI/180),
    SetUnitSafePolarUTA: (u,r,a) => {if (!u.blocked) {u.x += extras.PolarX(r,a); u.y += extras.PolarY(r,a);}},
    HeroDeal: (raw,caster,target,damage,...flags) => hits.push({caster,target,damage,flags,tick:expired.data.i}),
    UnitEffectTime2: (raw,x,y) => ({x,y}), CameraShaker: {setShakeForPlayer:no},
    AnimationStart3:no, Sound3D:no, CooldownFIX:no, DummyMagicleash:no, BuffNoST:{Apply:no},
    CastingBarShow:no, DzFrameSetValue:no, DzFrameSetText:no, DzSyncData:no,
    AddSpecialEffect:()=>({}), AddSpecialEffectTarget:()=>({}), DestroyEffect:no, EXSetUnitFacing:no,
    R2S:String, DzGetMouseTerrainX:()=>1000, DzGetMouseTerrainY:()=>0,
    party: {create: () => {
      const group = {super:new Set(), destroyed:false, destroy(){this.destroyed=true;}};
      groups.push(group); return group;
    }},
    tick: {getExpired:()=>expired, create:()=> {
      const t = {data:null, destroyed:false, start(seconds,repeat,callback){this.seconds=seconds;this.callback=callback;}, destroy(){this.destroyed=true;}};
      timers.push(t); return t;
    }},
    splash: {ENEMY:0, range(filter,caster,x,y,r,callback) {
      this.source=caster; this.x=x; this.y=y;
      for (const target of enemies) if (!target.dead && Math.hypot(target.x-x,target.y-y)<=r) {enumerated=target; callback();}
    }},
  };
  e = environment([file], extras, ['Main','EffectFunction','EffectFunction2','splashD','splashD1','splashD2','splashD3','splashD4','RSyncData2']).env;
  // 구조체의 실제 destroy 본문도 실행하여 중단·정상 종료의 그룹 반환을 확인한다.
  const body = source.match(/method destroy takes nothing returns nothing([\s\S]*?)endmethod/)[1];
  const destroyJS = body.split(/\r?\n/).map(line => {
    const s=line.trim(); if (!s) return '';
    if (s.startsWith('if ')) return 'if ('+s.slice(3,-5)+') {';
    if (s==='endif') return '}';
    if (s.startsWith('call ') || s.startsWith('set ')) return s.slice(s.startsWith('call ')?5:4)+';';
    throw Error('Unsupported destroy statement: '+s);
  }).join('\n');
  e.FxEffect = {create() {
    const fx = {caster:null,dummy:null,ul:0,TargetX:0,TargetY:0,pid:0,i:0,speed:0,deallocated:false,deallocate(){this.deallocated=true;}};
    fx.destroy=Function('with(this){'+destroyJS+'}'); return fx;
  }};
  e.MainUnit=[0,1].map(p=>({p,x:0,y:p*2000,dead:false,abilities:new Set()}));
  const step = t => {expired=t; t.callback();};
  const finish = t => {for(let i=0;!t.destroyed && i<100;i++) step(t); assert(t.destroyed);};
  function start(pid=0,stage=1) {
    const groupCount=groups.length;
    e.eventPlayer=pid; e.Main(); const charge=timers.at(-1);
    if(skill==='E') return charge;
    e.Stack[pid]=stage; e.RSyncData2(); const dash=timers.at(-1);
    step(charge); assert(charge.destroyed); assert.equal(groups.length,groupCount); return dash;
  }
  return {e,timers,groups,hits,enemies,step,finish,start};
}
for (const skill of ['E','R']) {
  for (const stage of skill==='E' ? [1] : [1,2,3,4]) check(`${skill} ${stage}단계 경로·끝점 동일 피해, 적별 1회`,()=> {
    const t=fresh(skill), total=skill==='E'?450:315, radius=skill==='E'?200:150;
    const near={x:20,y:0}, overlap={x:total-20,y:0}, endOnly={x:total+radius+50,y:0}, outside={x:total+radius+101,y:0};
    t.enemies.push(near,overlap,endOnly,outside); const timer=t.start(0,stage); t.finish(timer);
    const damage=skill==='E' ? .513*1.7*2.6 : 1.293*1.5*[1,1.3,1.6,1.9*2.22][stage-1];
    for (const target of [near,overlap,endOnly]) {
      const h=t.hits.filter(h=>h.target===target); assert.equal(h.length,1); assert(Math.abs(h[0].damage-damage)<1e-10);
      assert.deepEqual(h[0].flags,skill==='E'?[true,false,true,false]:[true,false,false,true]);
    }
    assert(t.hits.find(h=>h.target===near).tick<10); assert.equal(t.hits.find(h=>h.target===endOnly).tick,10);
    assert(!t.hits.some(h=>h.target===outside)); assert.equal(t.e.MainUnit[0].x,total);
    assert(t.groups.every(g=>g.destroyed)); assert(timer.data.deallocated); assert.equal(t.e.CheckG,null);
  });
  check(`${skill} 이동이 막혀도 반복 타격 없음, 다음 시전은 다시 타격`,()=> {
    const t=fresh(skill); t.e.MainUnit[0].blocked=true; t.enemies.push({x:10,y:0});
    t.finish(t.start()); assert.equal(t.hits.length,1); t.finish(t.start()); assert.equal(t.hits.length,2);
    assert.equal(t.groups.length,2); assert(t.groups.every(g=>g.destroyed));
  });
  check(`${skill} 두 플레이어의 돌진 타격 기록은 독립`,()=> {
    const t=fresh(skill); t.e.MainUnit[1].y=0; const target={x:50,y:0}; t.enemies.push(target);
    const a=t.start(0), b=t.start(1);
    while(!a.destroyed || !b.destroyed) {if(!a.destroyed)t.step(a);if(!b.destroyed)t.step(b);}
    assert.equal(t.hits.length,2); assert.equal(new Set(t.hits.map(h=>h.caster)).size,2);
    assert(t.groups.every(g=>g.destroyed));
  });
  check(`${skill} 돌진 중 취소 시 타격 그룹 반환`,()=> {
    const t=fresh(skill), timer=t.start(); t.step(timer); assert.equal(t.groups.length,1);
    if(skill==='E') t.e.IsCastingChenE[0]=false; else t.e.MainUnit[0].dead=true;
    t.step(timer); assert(timer.destroyed); assert(timer.data.deallocated); assert(t.groups[0].destroyed);
  });
}
check('R 최대 차지 자동 발동에서도 경로 타격 및 그룹 반환',()=> {
  const t=fresh('R'); t.enemies.push({x:25,y:0}); t.e.Main(); t.finish(t.timers[0]);
  assert.equal(t.hits.length,1); assert(Math.abs(t.hits[0].damage-1.293*1.5*1.9*2.22)<1e-10);
  assert.equal(t.e.Stack[0],0); assert.equal(t.groups.length,1); assert(t.groups[0].destroyed);
});
console.log(`Verified ${checks} Chen dash scenarios.`);
