// 카드부여와 엘릭서의 벡터 상태 텍스처를 TGA로 생성합니다.
const fs = require('fs'), path = require('path');
const sharp = require(process.env.SHARP_PATH || 'sharp');
const root = path.resolve(__dirname, '..');
const row = (fill, stroke) => `<rect x="1" y="1" width="510" height="126" fill="${fill}" stroke="${stroke}" stroke-width="2"/><path fill="${stroke}" d="M0 0H5V128H0Z"/>`;
const step = (fill, stroke, mark='') => `<rect x="3" y="3" width="58" height="58" rx="8" fill="${fill}" stroke="${stroke}" stroke-width="3"/>${mark}`;
const assets = {
  Row: [512,128,row('#ffffff','#b8deec')],
  Selected: [512,128,row('#e2f7ff','#22b9e3')],
  Disabled: [256,64,'<path fill="#86adbd" d="M14 0H256L240 64H0Z"/>'],
  StepEmpty: [64,64,step('#e8f4fa','#b9d8e6')],
  StepSuccess: [64,64,step('#27bee8','#1598c4','<path d="M16 32L27 43L48 20" fill="none" stroke="white" stroke-width="5"/>')],
  StepFail: [64,64,step('#dfe7ec','#a4b7c2','<path d="M21 21L43 43M43 21L21 43" stroke="#7c919e" stroke-width="4"/>')],
  StepRisk: [64,64,step('#fff0f2','#e8b7c1')],
  StepPenalty: [64,64,step('#e9879d','#cc617b','<path d="M18 32H46" stroke="white" stroke-width="5"/>')],
  Lock: [64,64,'<rect x="16" y="28" width="32" height="27" rx="4" fill="#708d9d"/><path d="M23 29V20a9 9 0 0 1 18 0v9" fill="none" stroke="#708d9d" stroke-width="6"/><circle cx="32" cy="40" r="3" fill="white"/>'],
};
(async()=>{
  const dir=path.join(root,'assets/upgrade/crafting');
  fs.mkdirSync(dir,{recursive:true});
  const manifest=[];
  for(const [name,[w,h,body]] of Object.entries(assets)) {
    const svg=Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}">${body}</svg>`);
    fs.writeFileSync(path.join(dir,name+'.svg'),svg);
    const rgba=await sharp(svg).ensureAlpha().raw().toBuffer();
    const header=Buffer.alloc(18); header[2]=2; header.writeUInt16LE(w,12); header.writeUInt16LE(h,14); header[16]=32; header[17]=0x28;
    const bgra=Buffer.from(rgba);
    for(let i=0;i<rgba.length;i+=4){bgra[i]=rgba[i+2];bgra[i+2]=rgba[i];}
    const file=`UI_Upgrade_${name}.tga`;
    fs.writeFileSync(path.join(root,'war3mapImported',file),Buffer.concat([header,bgra]));
    manifest.push({path:`war3mapImported\\${file}`,width:w,height:h});
  }
  fs.writeFileSync(path.join(dir,'import-manifest.json'),JSON.stringify(manifest,null,2)+'\n');
  console.log(`Created ${manifest.length} crafting textures.`);
})().catch(e=>{console.error(e);process.exit(1)});
