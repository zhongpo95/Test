// 강화 UI 벡터 패널과 인물 이미지를 Warcraft III용 TGA로 변환합니다.
const fs = require('fs');
const path = require('path');
const sharp = require(process.env.SHARP_PATH || 'sharp');
const root = path.resolve(__dirname, '..');
const out = path.join(root, 'war3mapImported');
const source = path.join(root, 'assets/upgrade');
const svg = (w, h, body) => Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">${body}</svg>`);
const gradient = '<defs><linearGradient id="bg" x2="0.8" y2="1"><stop stop-color="#cceefa"/><stop offset="1" stop-color="#eff8fd"/></linearGradient></defs>';
const assets = {
  Background: [1024, 1024, gradient + '<path fill="url(#bg)" d="M0 0H1024V1024H0Z"/><g fill="#fff" opacity=".25"><path d="M0 170L650 0H840L0 290Z"/><path d="M0 830L1024 390V450L0 960Z"/></g><g fill="#8bccdf" opacity=".12"><path d="M80 0H150L40 1024H0Z"/><path d="M310 0H335L230 1024H200Z"/></g>'],
  Panel: [512, 512, '<path fill="#edf8fd" fill-opacity=".96" d="M0 0H512V512H0Z"/><path fill="#fff" fill-opacity=".6" d="M0 0H512V3H0Z"/>'],
  Header: [512, 128, '<path fill="#ddf3fc" d="M0 0H512V128H0Z"/><path fill="#29bde6" d="M0 0H5V128H0Z"/><path fill="#fff" opacity=".45" d="M360 0H430L390 128H320Z"/>'],
  Card: [512, 256, '<path fill="#fff" fill-opacity=".78" d="M0 0H512V256H0Z"/><path stroke="#b8deec" stroke-width="2" fill="none" d="M1 1H511V255H1Z"/><path fill="#37c1e7" d="M0 0H5V256H0Z"/>'],
  TabIdle: [256, 64, '<path fill="#88b6c9" d="M0 0H256L240 60H0Z"/>'],
  TabActive: [256, 64, '<path fill="#25bce9" d="M0 8H256L240 64H0Z"/><path fill="#fff" d="M0 0H256L240 55H0Z"/>'],
  TabHover: [256, 64, '<path fill="#c5edf8" d="M0 0H256L240 60H0Z"/><path fill="#fff" d="M0 0H5V60H0Z"/>'],
  Action: [256, 64, '<path fill="#149dcc" d="M14 6H256L240 64H0Z"/><path fill="#36c5ed" d="M14 0H256L240 58H0Z"/>'],
  ActionHover: [256, 64, '<path fill="#1699c2" d="M14 6H256L240 64H0Z"/><path fill="#68dcf7" d="M14 0H256L240 58H0Z"/>'],
  Close: [64, 64, '<path fill="#fff" fill-opacity=".9" d="M0 0H64V64H0Z"/><path stroke="#39839e" stroke-width="4" d="M22 22L42 42M42 22L22 42"/>'],
};
async function saveTga(name, input, w, h) {
  const { data, info } = await sharp(input).resize(w, h, {fit:'fill'}).ensureAlpha().raw().toBuffer({resolveWithObject:true});
  const header = Buffer.alloc(18);
  header[2] = 2;
  header.writeUInt16LE(w,12); header.writeUInt16LE(h,14);
  header[16] = 32; header[17] = 0x28;
  const bgra = Buffer.alloc(data.length);
  for(let i=0;i<data.length;i+=4) { bgra[i]=data[i+2]; bgra[i+1]=data[i+1]; bgra[i+2]=data[i]; bgra[i+3]=data[i+3]; }
  fs.writeFileSync(path.join(out,`UI_Upgrade_${name}.tga`),Buffer.concat([header,bgra]));
  return {path:`war3mapImported\\UI_Upgrade_${name}.tga`,width:w,height:h,bytes:18+info.size};
}
(async()=>{
  fs.mkdirSync(out,{recursive:true}); fs.mkdirSync(source,{recursive:true});
  const manifest=[];
  for(const [name,[w,h,body]] of Object.entries(assets)) {
    const vector=svg(w,h,body);
    fs.writeFileSync(path.join(source,`${name}.svg`),vector);
    manifest.push(await saveTga(name,vector,w,h));
  }
  // 16:9 게임 화면의 실제 인물 영역 비율에 맞춘 뒤 POT 텍스처로 저장합니다.
  const portraitPath=path.join(source,'portrait-source.jpg');
  const visualAspect=(0.265 / 0.800 * 1600) / (0.568 / 0.600 * 900);
  const cropHeight=560;
  const cropWidth=Math.round(cropHeight*visualAspect);
  const portrait=await sharp(portraitPath).extract({left:535,top:235,width:cropWidth,height:cropHeight}).png().toBuffer();
  manifest.push(await saveTga('Portrait',portrait,512,1024));
  fs.writeFileSync(path.join(source,'import-manifest.json'),JSON.stringify(manifest,null,2)+'\n');
  console.log(`Created ${manifest.length} uncompressed BGRA TGA textures.`);
})().catch(e=>{console.error(e);process.exit(1)});
