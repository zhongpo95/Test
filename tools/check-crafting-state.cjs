// 실제 JASS 함수의 진입·차감·수령 흐름을 모의 네이티브 환경에서 검증합니다.
// Warcraft 실행이나 네트워크 검증을 대체하지 않습니다.
const fs=require('fs'),path=require('path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');
function model(file,names,localPlayer=0){
  const source=fs.readFileSync(path.join(root,file),'utf8');
  const globals=source.match(/\bglobals\b([\s\S]*?)\bendglobals\b/)[1].replace(/\/\*[\s\S]*?\*\//g,'');
  const env={},ui=new Map(),items=new Map(),sent=[];
  let rng=0,awards=0;
  for(const line of globals.split(/\r?\n/)){
    const m=line.trim().match(/^(?:private )?(integer|boolean|string|real|hashtable) (array )?(\w+)(\[[^\n]+\])?/);
    if(!m)continue;
    const zero=m[1]==='string'?null:m[1]==='boolean'?false:0;
    env[m[3]]=m[2]?(m[4]?Array.from({length:64},()=>Array(256).fill(zero)):Array(8192).fill(zero)):zero;
  }
  const no=()=>{};
  Object.assign(env,{
    connected:true,eventPlayer:0,eventFrame:0,syncData:'1',
    Player:x=>x,GetPlayerId:x=>x,GetLocalPlayer:()=>localPlayer,
    DzGetTriggerUIEventPlayer:()=>env.eventPlayer,DzGetTriggerSyncPlayer:()=>env.eventPlayer,
    DzGetTriggerUIEventFrame:()=>env.eventFrame,DzGetTriggerSyncData:()=>env.syncData,
    JNObjectCharacterServerConnectCheck:()=>env.connected,
    PLAYER_DATA:[0,1,2,3,4],PlayerSlotNumber:[1,1,1,1,1],F_ItemButtonsBackDrop:[],UI_Tip:999,
    I2S:String,S2I:x=>parseInt(x)||0,R2SW:(x,w,p)=>Number(x).toFixed(p),
    StashLoad:(p,k,d)=>items.has(p+':'+k)?items.get(p+':'+k):d,
    StashSave:(p,k,v)=>items.set(p+':'+k,v),StashRemove:(p,k)=>items.delete(p+':'+k),
    GetItemIDs:s=>{
      assert(s != null && s !== '' && s !== '0', 'Empty slot reached JN item parser');
      return Number(String(s).match(/ID(\d+)/)?.[1]||0);
    },
    IsEmptyItem:s=>s == null || s === '' || s === '0' || env.GetItemIDs(s) === 0,
    GetItemCharge:s=>Number(String(s).match(/C(\d+)/)?.[1]||0),
    SetItemCharge:(s,n)=>`ID39;C${n};`,
    AddIvItem:(pid,slot,s)=>{items.set(pid+':영웅1.아이템'+slot,s);awards++;},
    GetRandomInt:()=>{rng++;return 1;},
    StringHash:x=>x,LoadInteger:()=>0,
    JNStringSplit:(s,sep,i)=>String(s).split(sep)[i]||'',
    JNConvertColor:()=>0,
    DzFrameShow:(f,show)=>ui.set(f,show),
    DzSyncData:(event,data)=>sent.push({event,data}),
    IntegerPool:{Create:()=>({add:no,pick:()=>{rng++;return rng;},destroy:no})},
  });
  for(const m of source.matchAll(/\b(JN_\w+|gg_snd_\w+)\b/g))env[m[1]]=0;
  for(const name of ['DzFrameSetText','DzFrameSetEnable','DzFrameSetTexture','DzFrameSetPoint','DzFrameSetTextColor','StartSound','VJDebugMsg'])env[name]=no;
  for(const name of ['SetItemCardBonus1','SetItemCardBonus2','SetItemCardBonus3','SetItemElixirLevel1','SetItemElixirLevel2'])env[name]=(s,v)=>s+name+'='+v+';';
  const expr=s=>s.split(/("(?:\\.|[^"\\])*")/g).map((p,i)=>i%2?p:p.replace(/\band\b/g,'&&').replace(/\bor\b/g,'||').replace(/\bnot\b/g,'!')).join('');
  for(const name of names){
    const m=source.match(new RegExp('function '+name+' takes (.*?) returns \\w+([\\s\\S]*?)endfunction'));
    assert(m,'Missing '+name);
    const params=m[1]==='nothing'?'':m[1].split(',').map(p=>p.trim().split(/\s+/)[1]).join(',');
    const js=[];
    for(let line of m[2].split(/\r?\n/)){
      line=line.trim();if(!line||line.startsWith('//'))continue;
      if(line.startsWith('local ')){
        const v=line.match(/^local \w+ (array )?(\w+)(?:\s*=\s*(.*))?/);
        js.push(`let ${v[2]}=${v[3]?expr(v[3]):v[1]?'Array(8192).fill(0)':'0'};`);
      }else if(line==='loop')js.push('for(let guard=0;guard<10000;guard++){');
      else if(line==='endloop'||line==='endif')js.push('}');
      else if(line==='else')js.push('}else{');
      else if(line.startsWith('elseif '))js.push('}else if('+expr(line.slice(7,-5))+'){');
      else if(line.startsWith('if '))js.push('if('+expr(line.slice(3,-5))+'){');
      else if(line.startsWith('exitwhen '))js.push('if('+expr(line.slice(9))+')break;');
      else if(line.startsWith('set '))js.push(expr(line.slice(4))+';');
      else if(line.startsWith('call '))js.push(expr(line.slice(5))+';');
      else if(line.startsWith('return'))js.push(expr(line)+';');
      else throw Error('Unsupported statement '+line);
    }
    env[name]=Function('env',`with(env){return function(${params}){${js.join('\n')}}}`)(env);
  }
  return {env,items,ui,sent,rng:()=>rng,awards:()=>awards};
}
const cardNames=['StoneSlot','StoneRefresh','StoneStart','StoneBegin','StoneSetOpen','ClickButton','ButtonWork'];
const card=model('UI/UI_Stone.j',cardNames),c=card.env;
c.F_StoneBackDrop=100;c.F_ArcanaButton[1]=101;c.F_ArcanaButton[2]=102;c.F_ArcanaButton[3]=103;
card.items.set('0:영웅1.아이템50','ID39;C2;');
// 기본값, 빈 문자열, null을 반환하는 슬롯이 있어도 파서에 넘기면 안 됩니다.
card.items.set('0:영웅1.아이템51','');
card.items.set('0:영웅1.아이템52',null);
c.connected=false;c.StoneSetOpen(0,true);
assert.equal(card.ui.get(100),true);assert.equal(card.rng(),0);assert.equal(card.items.get('0:영웅1.아이템50'),'ID39;C2;');
c.StoneBegin();assert.equal(c.StoneActive[0],false);
c.connected=true;c.StoneBegin();assert.equal(c.StoneActive[0],true);assert.equal(card.items.get('0:영웅1.아이템50'),'ID39;C1;');
c.StoneBegin();assert.equal(card.items.get('0:영웅1.아이템50'),'ID39;C1;');
c.eventFrame=101;c.ClickButton();c.ClickButton();assert.equal(card.sent.length,1);assert.equal(card.sent[0].data,'1');
c.StoneSetOpen(0,false);c.StoneSetOpen(0,true);assert.equal(c.StoneActive[0],true);
for(let row=1;row<=3;row++)for(let step=0;step<10;step++){c.syncData=String(row);c.ButtonWork();}
assert(c.StoneResult[0].includes('SetItemCardBonus1=4;'));assert(c.StoneResult[0].includes('SetItemCardBonus3=3;'));
assert.equal(card.awards(),0);
for(let i=0;i<50;i++)card.items.set('0:영웅1.아이템'+i,'ID1;');
c.StoneBegin();assert.equal(card.awards(),0);assert(c.StoneResult[0]);
card.items.delete('0:영웅1.아이템2');c.StoneBegin();assert.equal(card.awards(),1);assert.equal(c.StoneResult[0],'');
console.log('Card: preview without consumption, prerequisites, single start charge, pending click, tab persistence, completed result retention/claim passed.');
const elNames=['NormalizeWeights','SetupPaths','GetPathChance','ElRefresh','ElSend','ElixirSetOpen','ClickLButton','ClickLButton2','ClickLButton3','SyncElixirOpen'];
for(const localPlayer of [0,1]){
  const el=model('UI/UI_Elixir.j',elNames,localPlayer),e=el.env;
  e.El_BackDrop=201;e.El_BackDrop2=202;e.El_B=203;
  e.ElixirSetOpen(0,true);assert.equal(el.rng(),0);assert.equal(el.sent.length,0);
  if(localPlayer===0){
    e.eventFrame=203;e.ClickLButton();e.ClickLButton();assert.equal(el.sent.length,1);
    e.ElixirSetOpen(0,false);
  }
  e.SyncElixirOpen();assert.equal(el.rng(),3);
  if(localPlayer===0){
    assert.equal(el.ui.get(201),false);assert.equal(e.ElSession[0],true);
    e.NowCount[0]=6;e.ElixirSetOpen(0,true);assert.equal(e.NowCount[0],6);assert.equal(el.rng(),3);
    e.ElResultReady[0]=true;e.ResultLevel[0][1]=3;e.ResultLevel[0][2]=4;
    for(let i=0;i<50;i++)el.items.set('0:영웅1.아이템'+i,'ID1;');
    e.ClickLButton3();assert.equal(el.awards(),0);assert.equal(e.ElResultReady[0],true);
    el.items.delete('0:영웅1.아이템7');e.ClickLButton3();e.ClickLButton3();assert.equal(el.awards(),1);assert.equal(e.ElSession[0],false);
  }else assert.equal(e.ElSession[0],false);
}
console.log('Elixir: display without RNG, one pending start, 3 draws per simulated client, closed response, progress retention, full inventory and single claim passed.');
console.log('Mocked JASS source checks only; Warcraft runtime and multiplayer remain untested.');
