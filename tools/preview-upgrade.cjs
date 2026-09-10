// 실제 TGA와 JASS 배치 좌표를 조합한 강화 화면의 정적 미리보기를 만듭니다.
const fs=require('fs'),path=require('path');
const sharp=require(process.env.SHARP_PATH || 'sharp');
const root=path.resolve(__dirname,'..'), W=1600,H=900;
async function texture(name) {
 const b=fs.readFileSync(path.join(root,`war3mapImported/UI_Upgrade_${name}.tga`));
 const w=b.readUInt16LE(12),h=b.readUInt16LE(14),rgba=Buffer.alloc(w*h*4);
 for(let i=0;i<rgba.length;i+=4){rgba[i]=b[18+i+2];rgba[i+1]=b[18+i+1];rgba[i+2]=b[18+i];rgba[i+3]=b[18+i+3];}
 const png=await sharp(rgba,{raw:{width:w,height:h,channels:4}}).png().toBuffer();
 return 'data:image/png;base64,'+png.toString('base64');
}
(async()=>{
 const tex={};for(const n of ['Background','Panel','Header','Card','TabActive','TabIdle','Action','Close','Portrait'])tex[n]=await texture(n);
 const parts=[];
 const rect=(name,x,y,w,h)=>parts.push(`<image href="${tex[name]}" x="${x*2000}" y="${(0.6-y-h)*1500}" width="${w*2000}" height="${h*1500}" preserveAspectRatio="none"/>`);
 const text=(str,x,y,size=0.010,color='#315a70',anchor='middle')=>parts.push(`<text x="${x*2000}" y="${(0.6-y)*1500}" fill="${color}" font-size="${size*1500}" text-anchor="${anchor}" dominant-baseline="central">${str}</text>`);
 parts.push('<rect width="1600" height="900" fill="#233947"/>');
 text('상단 기본 메뉴 영역 · 퀘스트 / 메뉴(F10) / 동맹 / 로그(F12)',0.020,0.584,0.010,'#d6edf8','start');
 rect('Background',0,0,.8,.568);rect('Portrait',.535,0,.265,.568);
 rect('Header',.12,.498,.405,.06);rect('Close',.489,.515,.026,.026);
 text('ARCANA',.013,.534,.016,'#2eb9df','start');text('UPGRADE',.014,.511,.008,'#709db1','start');
 text('장비강화',.136,.533,.016,'#244f65','start');text('EQUIPMENT  /  CARD  /  ELIXIR',.137,.511,.007,'#6792a6','start');
 ['장비강화','카드부여','엘릭서'].forEach((v,i)=>{rect(i?'TabIdle':'TabActive',.01,.399-.048*i,.09,.032);text(v,.022,.417-.048*i,.011,i?'#fff':'#2699be','start');});
 text('ESC  닫기',.014,.030,.008,'#709db1','start');
 rect('Panel',.12,.0175,.405,.475);rect('Card',.14,.3545,.365,.120);rect('Card',.14,.0415,.365,.290);
 text('장착 무기',.3225,.4545,.011);text('강화 정보',.3225,.3115,.011);
 // 무기/재료 아이콘과 수치는 실제 게임 데이터 대신 설명용 표시를 사용합니다.
 parts.push('<rect x="318" y="251.25" width="104" height="78" rx="3" fill="#d0eaf5" stroke="#6daec8"/>');
 text('무기',.185,.4065,.012,'#367e9b');
 text('장착한 무기 이름',.232,.4165,.012,'#315a70','start');text('T3   /   +12   /   품질 85',.232,.3885,.009,'#315a70','start');
 text('12  &gt;&gt;  13',.3225,.2825,.012);text('강화 확률  65.00%',.3225,.2475,.010);text('운명  12.50%',.3225,.2265,.008);
 text('무기 공격력 +1,240',.235,.1855,.009);text('&gt;&gt;',.3225,.1855,.010);text('무기 공격력 +1,380',.410,.1855,.009);
 text('재료',.210,.1405,.008);text('× 12',.259,.1405,.010);text('골드',.350,.1405,.008);text('× 2,500',.405,.1405,.010);
 rect('Action',.2375,.0605,.170,.036);text('강화',.3225,.0785,.011,'#fff');
 const svg=Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}"><style>text{font-family:'Malgun Gothic',sans-serif}</style>${parts.join('')}</svg>`);
 await sharp(svg).png().toFile(path.join(root,'assets/upgrade/preview.png'));
 console.log('Preview rendered. Values and icon labels are illustrative; not a game screenshot.');
})().catch(e=>{console.error(e);process.exit(1)});
