// JASS의 실제 Main 배치를 읽어 카드부여·엘릭서 정적 미리보기를 생성합니다.
const fs=require('fs'), path=require('path');
const sharp=require(process.env.SHARP_PATH || 'sharp');
const root=path.resolve(__dirname,'..');
const textures=new Map();
async function texture(file){
  file=path.basename(file.replaceAll('\\','/'));
  if(textures.has(file))return textures.get(file);
  const b=fs.readFileSync(path.join(root,'war3mapImported',file));
  const w=b.readUInt16LE(12),h=b.readUInt16LE(14),rgba=Buffer.alloc(w*h*4);
  if(b[2]!==2||b[16]!==32||b[17]!==0x28)throw Error('Unsupported TGA '+file);
  for(let i=0;i<rgba.length;i+=4){rgba[i]=b[18+i+2];rgba[i+1]=b[18+i+1];rgba[i+2]=b[18+i];rgba[i+3]=b[18+i+3];}
  const url='data:image/png;base64,'+(await sharp(rgba,{raw:{width:w,height:h,channels:4}}).png().toBuffer()).toString('base64');
  textures.set(file,url);return url;
}
const esc=s=>String(s).replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;');
function scene(file){
  const source=fs.readFileSync(path.join(root,file),'utf8');
  const frames=[{type:'ROOT',x:0,y:0,w:.8,h:.6,show:true}];
  const env={JN_FRAMEPOINT_CENTER:4,JN_FRAMEPOINT_BOTTOMLEFT:6,JN_TEXT_JUSTIFY_TOP:0,JN_TEXT_JUSTIFY_LEFT:0,JN_TEXT_JUSTIFY_CENTER:1};
  for(const m of source.matchAll(/(?:integer|string|boolean|real) array (\w+)(\[[^\n]*\])?/g))env[m[1]]=m[2]?Array.from({length:64},()=>[]):[];
  const create=(type,parent)=>{frames.push({type,parent,w:0,h:0,show:true,size:.010,color:'#315a70'});return frames.length-1;};
  Object.assign(env,{
    GetGameplayUI:()=>0, FrameCount:()=>0, I2S:String,
    DzCreateFrameByTagName:(type,name,parent)=>create(type,parent),
    DzFrameSetPoint:(id,point,parent,relative,x,y)=>Object.assign(frames[id],{parent,point,relative,x,y}),
    DzFrameSetAbsolutePoint:(id,point,x,y)=>Object.assign(frames[id],{parent:0,point,relative:6,x,y}),
    DzFrameSetSize:(id,w,h)=>Object.assign(frames[id],{w,h}),
    DzFrameSetTexture:(id,file)=>frames[id].texture=file,
    DzFrameSetAllPoints:(id,parent)=>frames[id].all=parent,
    DzFrameSetText:(id,text)=>frames[id].text=text,
    DzFrameSetFont:(id,font,size)=>frames[id].size=size,
    JNConvertColor:(a,r,g,b)=>`rgb(${r},${g},${b})`,
    DzFrameSetTextColor:(id,color)=>frames[id].color=color,
    DzFrameShow:(id,show)=>frames[id].show=show,
    JNFrameSetTextAlignment:(id,v,h)=>frames[id].left=true,
  });
  for(const prefix of ['Stone','El']){
    env[prefix+'Panel']=(parent,texture,x,y,w,h)=>{const id=create('BACKDROP',parent);Object.assign(frames[id],{texture,x,y,w,h,point:4,relative:6});return id;};
    env[prefix+'Text']=(parent,text,x,y,size)=>{const id=create('TEXT',parent);Object.assign(frames[id],{text,x,y,size,point:4,relative:6});return id;};
  }
  const body=source.match(/private function Main takes nothing returns nothing([\s\S]*?)endfunction/)[1];
  const js=[];
  for(let line of body.split(/\r?\n/)){
    line=line.trim();
    if(!line||line.startsWith('//'))continue;
    if(line.startsWith('local ')){const m=line.match(/local \w+ (\w+)(?: = (.*))?/);env[m[1]]=0;if(m[2])js.push(`${m[1]}=${m[2]};`);}
    else if(line==='loop')js.push('for(let guard=0;guard<1000;guard++){');
    else if(line==='endloop'||line==='endif')js.push('}');
    else if(line==='else')js.push('}else{');
    else if(line.startsWith('if '))js.push(line.replace(/^if (.*) then$/,'if($1){'));
    else if(line.startsWith('exitwhen '))js.push('if('+line.slice(9)+')break;');
    else if(line.startsWith('set ')){const lhs=line.slice(4).split('=')[0].trim().split('[')[0];if(!(lhs in env))env[lhs]=0;js.push(line.slice(4)+';');}
    else if(line.startsWith('call ')){const name=line.slice(5).split('(')[0];if(name in env)js.push(line.slice(5)+';');}
    else throw Error('Unparsed layout '+line);
  }
  Function('env','with(env){'+js.join('\n')+'}')(env);
  function box(id){
    const f=frames[id];if(id===0)return f;if(f.all)return box(f.all);
    const p=box(f.parent),w=f.w,h=f.h;
    return {x:p.x+(f.relative===4?p.w/2:0)+(f.x||0)-(f.point===4?w/2:0),y:p.y+(f.relative===4?p.h/2:0)+(f.y||0)-(f.point===4?h/2:0),w,h};
  }
  return {frames,env,box};
}
async function render(kind){
  const card=kind==='card';
  const {frames,env,box}=scene(card?'UI/UI_Stone.j':'UI/UI_Elixir.j');
  const panel=card?env.F_StoneBackDrop:kind==='result'?env.El_BackDrop2:env.El_BackDrop;
  frames[panel].show=true;
  if(card){
    frames[env.StoneMaterial].text='카드 부여 재료   0개 보유  /  시작 시 1개 필요';frames[env.StoneStatus].text='카드 부여 재료가 부족합니다.';frames[env.StoneStartBD].texture='UI_Upgrade_Disabled.tga';
    frames[env.F_ArcanaText[8]].text='0회 균열';
    for(let i=1;i<=3;i++)frames[env.F_ArcanaButton2BackDrop[i+3]].texture='UI_Upgrade_Disabled.tga';
    for(let i=0;i<4;i++){
      for(const arr of [env.F_ArcanaTextA,env.F_ArcanaTextB])frames[arr[i]].text=`${[6,7,9,10][i]}회 · Lv ${i+1}`;
      if(i<3)frames[env.F_ArcanaTextC[i]].text=`${[5,7,10][i]}회 · Lv ${i+1}`;
    }
  }
  else if(kind==='elixir'){
    frames[env.CountText].text='남은 연성 10회';frames[env.ElHint].text='선택 내용을 확인한 뒤 결정하세요.';
    frames[env.El_BT].text='결정';frames[env.El_RollT].text='재선택 1회';
    for(let i=1;i<=5;i++){frames[env.El_MainR[i]].text='20.0%';frames[env.El_MainR2[i]].text='대성공 40.0%';}
    ['이번 연성에서 3번 연성','선택한 연성 단계를 1~2단계 상승','남은 모든 연성에서 선택한 연성 대성공 확률 15% 상승'].forEach((s,i)=>frames[env.El_SelectText[i+1]].text=s);
    frames[env.El_Select[2]].texture='UI_Upgrade_Selected.tga';frames[env.El_Main[3]].texture='UI_Upgrade_Selected.tga';
  }else{frames[env.EL_LevelTextA].text='3 단계';frames[env.EL_LevelTextB].text='4 단계';}
  const parts=[];
  const rect=async(file,x,y,w,h)=>parts.push(`<image href="${await texture(file)}" x="${x*2000}" y="${(0.6-y-h)*1500}" width="${w*2000}" height="${h*1500}" preserveAspectRatio="none"/>`);
  const text=(s,x,y,size=.010,color='#315a70')=>parts.push(`<text x="${x*2000}" y="${(.6-y)*1500}" font-size="${size*1500}" fill="${color}" text-anchor="middle" dominant-baseline="central">${esc(s)}</text>`);
  parts.push('<rect width="1600" height="900" fill="#202b31"/>');
  text('정적 배치 미리보기 · 실제 게임 화면이 아니며 수치는 예시입니다.',.4,.583,.009,'#fff');
  await rect('UI_Upgrade_Background.tga',0,0,.8,.568);await rect('UI_Upgrade_Portrait.tga',.535,0,.265,.568);
  await rect('UI_Upgrade_Header.tga',.12,.498,.405,.06);await rect('UI_Upgrade_Close.tga',.489,.515,.026,.026);
  text('ARCANA',.040,.533,.016,'#2eb9df');text(card?'카드부여':'엘릭서',.166,.533,.016);
  for(let i=0;i<3;i++){await rect(`UI_Upgrade_Tab${i===(card?1:2)?'Active':'Idle'}.tga`,.01,.399-.048*i,.09,.032);text(['장비강화','카드부여','엘릭서'][i],.052,.417-.048*i,.010,i===(card?1:2)?'#2699be':'#fff');}
  text('ESC 닫기',.032,.030,.008);
  const visible=id=>{if(id===0)return true;return frames[id].show&&visible(frames[id].parent);};
  for(let i=1;i<frames.length;i++){
    const f=frames[i];if(!visible(i))continue;
    const b=box(i);
    if(f.texture)await rect(f.texture,b.x,b.y,b.w,b.h);
    if(f.text){
      const clean=f.text.replace(/\|c[0-9a-f]{8}|\|r/ig,'');
      const max=b.w?Math.floor(b.w*2000/(f.size*1500)):1000;
      const lines=[];let line='';let width=0;
      for(const ch of clean){const cw=ch.charCodeAt(0)>255?1:.55;if(width+cw>max){lines.push(line);line='';width=0;}line+=ch;width+=cw;}if(line)lines.push(line);
      const cy=b.y+b.h/2;
      lines.forEach((l,n)=>text(l,b.x+b.w/2,cy+((lines.length-1)/2-n)*f.size*1.25,f.size,f.color));
    }
  }
  const svg=Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="900"><style>text{font-family:'Malgun Gothic',sans-serif}</style>${parts.join('')}</svg>`);
  const dir=path.join(root,'assets/upgrade/crafting');fs.mkdirSync(dir,{recursive:true});
  await sharp(svg).png().toFile(path.join(dir,`preview-${kind}.png`));
  // Actual child rectangles must stay within the shared content panel.
  const p=box(panel),bad=[];
  for(let i=1;i<frames.length;i++)if(visible(i)&&frames[i].type!=='SPRITE'&&i!==panel){const b=box(i);if(b.w&&b.h&&(b.x<p.x-.001||b.y<p.y-.001||b.x+b.w>p.x+p.w+.001||b.y+b.h>p.y+p.h+.001))bad.push(i);}
  if(bad.length)throw Error(kind+' out-of-bounds frames '+bad.join(','));
  console.log(`${kind}: source layout rendered; content bounds passed.`);
}
(async()=>{for(const kind of ['card','elixir','result'])await render(kind);})().catch(e=>{console.error(e);process.exit(1)});
