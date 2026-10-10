// 실제 JASS 본문 배치 함수를 모의 폰트 높이로 실행해 간격과 복원 경로를 검사한다.
const assert=require('node:assert/strict');
const {environment}=require('./check-expedition.cjs');
const frames=new Map();const frame=id=>{if(!frames.has(id))frames.set(id,{});return frames.get(id);};
const clean=s=>s.replace(/\|c[0-9a-f]{8}|\|r/gi,'');let measures=0;
const prefix='UIExpeditionPrototype_';
const names=['PaperText','PlaceCoverPart','StoryLastColor','RenderSpacedStory'].map(n=>prefix+n);
const {env:e}=environment(['UI/UI_ExpeditionPrototype.j'],{
 StringLength:s=>s.length,SubString:(s,a,b)=>s.slice(a,b),JNStringCount:(s,w)=>s.split(w).length-1,JNStringSplit:(s,w,i)=>s.split(w)[i]||'',
 DzFrameSetText:(id,s)=>frame(id).text=s,DzFrameShow:(id,b)=>frame(id).shown=b,
 DzFrameClearAllPoints:()=>{},DzFrameSetPoint:(id,p,parent,r,x,y)=>Object.assign(frame(id),{x,y}),DzFrameSetSize:(id,w,h)=>Object.assign(frame(id),{w,h}),
 DzFrameGetHeight:id=>{measures++;return Math.max(1,Math.ceil(clean(frame(id).text).length/30))*.011;},JN_FRAMEPOINT_TOPLEFT:0
},names);
e[prefix+'StoryText']=1;e[prefix+'StoryMeasure']=2;e[prefix+'StoryPanel']=3;
for(let i=0;i<32;i++)e[prefix+'StoryLines'][i]=100+i;
const render=e[prefix+'RenderSpacedStory'];
const text='|cFF865500긴 색상 문구가 다음 줄에서도 같은 색상을 유지하며 이어집니다 정말 그렇습니다|r|n|n다음 문단입니다.';
render(text,.126,.242);const count=e[prefix+'StoryLineCount'];assert(count>=4);assert(frame(101).text.includes('|cff875b21'));
assert(Math.abs(frame(100).y-frame(101).y-.013)<1e-6);
const before=measures;render(text,.126,.242);assert.equal(measures,before);
render('아주 긴 설명 '.repeat(300),.126,.242);assert(frame(1).text.includes('아주 긴 설명'));for(let i=0;i<32;i++)assert(!frame(100+i).shown);
render('짧은 설명',.104,.264);assert.equal(clean(frame(100).text),'짧은 설명');assert.equal(frame(1).text,'');
console.log('PASS 실제 JASS 함수의 줄 간격, 색상 유지, 문단, 캐시, 넘침 복원, 재진입. 실제 게임 폰트 측정은 미검증.');

