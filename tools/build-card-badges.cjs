// 카드 현재 단계의 청록색·자주색 배지 텍스처를 생성합니다.
const fs=require('fs'),path=require('path');
const sharp=require(process.env.SHARP_PATH||'sharp');
(async()=>{
  for(const [name,color] of [['BadgeGain','#176078'],['BadgePenalty','#873d61']]){
    const svg=Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="512" height="48"><rect width="512" height="48" rx="8" fill="${color}"/></svg>`);
    const rgba=await sharp(svg).ensureAlpha().raw().toBuffer();
    const header=Buffer.alloc(18);header[2]=2;header.writeUInt16LE(512,12);header.writeUInt16LE(48,14);header[16]=32;header[17]=0x28;
    for(let i=0;i<rgba.length;i+=4){const r=rgba[i];rgba[i]=rgba[i+2];rgba[i+2]=r;}
    fs.writeFileSync(path.join(__dirname,'../war3mapImported',`UI_Upgrade_${name}.tga`),Buffer.concat([header,rgba]));
  }
})().catch(e=>{console.error(e);process.exit(1)});
