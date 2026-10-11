// 사건 본문이 원본 TEXT를 먼저 채우고, 줄 분할이 성공했을 때만 0.014 간격 줄 TEXT로 바뀌는지 검사한다.
const assert=require('node:assert/strict');
const {environment}=require('./check-expedition.cjs');
const q='UIExpeditionPrototype_';const calls=[];const places=[];
const bytes=s=>Buffer.from(s,'utf8');
const narrow=' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{}~';
const {env:u}=environment(['UI/UI_StoryLineLayout.j','UI/UI_ExpeditionPrototype.j'],{
 StringLength:s=>bytes(s).length,SubString:(s,a,b)=>bytes(s).subarray(a,b).toString('latin1'),
 StringHash:s=>s,InitHashtable:()=>new Map(),SaveBoolean:(t,a,b,v)=>t.set(a+':'+b,v),HaveSavedBoolean:(t,a,b)=>t.has(a+':'+b),
 DzFrameSetText:(f,s)=>calls.push(['text',f,s]),DzFrameShow:(f,v)=>calls.push(['show',f,v]),
 DzFrameClearAllPoints:()=>{},DzFrameSetPoint:(f,a,p,b,x,y)=>places.push([f,x,-y]),DzFrameSetSize:()=>{},
 JN_FRAMEPOINT_TOPLEFT:0,JNStringReplace:(s,a,b)=>s.split(a).join(b),ExpUILabel:()=>23
},['StoryLineLayout','StoryLineLayout_ByteUnits','StoryLineLayout_PushLine','StoryLineLayout_FlushWord','StoryLineLayout_StartWord',q+'PaperText',q+'PlaceCoverPart',q+'SetStoryText',q+'SetOutcomeText',q+'CreateStoryText']);
u.StoryLineLayout_CharBytes=3;for(const c of narrow)u.Narrow.set(c+':0',true);
u[q+'StoryPanel']=9;assert.equal(u[q+'CreateStoryText'](),23);
u[q+'StoryText']=2;for(let i=0;i<u.STORY_LINE_MAX;i++)u[q+'StoryLineFrames'][i]=100+i;
assert.equal(u[q+'STORY_LINE_GAP'],0.014);
const s534='죠스타 저택에 |cFF006B8F디오|r가 들어온 날, |cFF006B8F죠나단|r은 함께 지낼 또래를 반기려 한다. 그러나 디오는 가까워지려는 손길을 밀어내고 저택 안의 시선도 자기 쪽으로 돌린다. 죠나단은 한집에 산다는 이유만으로 서로를 이해할 수 없다는 사실을 처음 배운다.';
const lineShows=()=>calls.filter(c=>c[0]==='show'&&c[1]>=100&&c[2]);
// 와이드 화면(16:9): 원본을 먼저 채우고, 줄 TEXT를 모두 보인 뒤 원본을 숨긴다.
u[q+'ImagePixelAspect']=4/3;u[q+'SetStoryText'](s534,0.126,0.242);
const firstText=calls.findIndex(c=>c[0]==='text'&&c[1]===2), lastLine=calls.map((c,i)=>c[0]==='show'&&c[1]>=100&&c[2]?i:-1).filter(i=>i>=0).pop(), hide=calls.findIndex(c=>c[0]==='show'&&c[1]===2&&c[2]===false);
assert(firstText===0&&firstText<lastLine&&lastLine<hide,'원본 → 줄 표시 → 원본 숨김');
assert(Math.abs(u.StoryLineEm-1.03*0.75)<1e-9);
const wide=lineShows().length;assert(wide>=4&&wide<=6,'와이드 줄 수 '+wide);
const ys=places.filter(p=>p[0]>=100).map(p=>p[2]);ys.forEach((y,i)=>assert(Math.abs(y-(0.126+i*0.014))<1e-9));
// 같은 글, 같은 위치, 같은 화면 비율이면 다시 그리지 않는다.
let n=calls.length;u[q+'SetStoryText'](s534,0.126,0.242);assert.equal(calls.length,n);
// 화면 비율이 바뀌면 다시 나누고, 4:3에서는 줄이 늘어난다.
calls.length=0;u[q+'ImagePixelAspect']=1.0;u[q+'SetStoryText'](s534,0.126,0.242);assert(lineShows().length>wide);
// 후속 장면 위치로 바뀌면 같은 글도 다시 배치한다.
calls.length=0;places.length=0;u[q+'SetStoryText'](s534,0.104,0.264);assert(places.some(p=>p[0]===100&&Math.abs(p[2]-0.104)<1e-9));
// 실패: 높이 넘침과 긴 단어는 원본을 숨기지 않고 줄 TEXT도 보이지 않는다.
for(const bad of [Array(18).fill('가나다').join('|n'),'가'.repeat(40)]){
 calls.length=0;u[q+'SetStoryText'](bad,0.126,0.242);
 assert(!lineShows().length);assert(!calls.some(c=>c[0]==='show'&&c[1]===2&&c[2]===false));
 assert(calls.some(c=>c[0]==='text'&&c[1]===2&&c[2].includes(bad.slice(0,3))));
}
// 실패 뒤 정상 본문으로 돌아오면 다시 줄 TEXT로 바뀐다.
calls.length=0;u[q+'SetStoryText']('짧은 본문입니다.',0.126,0.242);assert.equal(lineShows().length,1);
console.log('PASS 원본 우선 표시, 0.014 간격 배치, 화면 비율·위치별 재배치, 넘침·긴 단어 시 원본 유지. 모의 실행이며 게임 표시는 미검증.');

// 사건 결과도 같은 분할기를 사용하며 보상 색상, 빈 줄과 원본 대체를 유지한다.
u[q+'OutcomePanel']=19;u[q+'OutcomeText']=3;
for(let i=0;i<u.STORY_LINE_MAX;i++)u[q+'OutcomeLineFrames'][i]=200+i;
u[q+'ImagePixelAspect']=4/3;calls.length=0;places.length=0;
const outcome='오월에 남은 눈|n눈길의 방해를 지나도 겨울은 끝나지 않는다. 레이무는 더 깊은 곳으로 향한다.|n|n|cff28633f[획득 보상]|r|n이동 속도 +3.0%|n비방향 공격 데미지 증가 +3.0%|n|n[메인 이야기 1/13]';
u[q+'SetOutcomeText'](outcome);
assert.equal(calls[0][1],3);assert.equal(calls[0][0],'text');
assert(calls.some(c=>c[0]==='text'&&c[1]>=200&&c[2].includes('|cff28633f')));
assert(calls.some(c=>c[0]==='show'&&c[1]===3&&c[2]===false));
places.filter(p=>p[0]>=200).forEach((p,i)=>assert(Math.abs(p[2]-(0.056+i*0.015))<1e-9));
n=calls.length;u[q+'SetOutcomeText'](outcome);assert.equal(calls.length,n);
for(const bad of [Array(22).fill('보상').join('|n'),'가'.repeat(100)]){
 calls.length=0;u[q+'SetOutcomeText'](bad);
 assert(!calls.some(c=>c[0]==='show'&&c[1]>=200&&c[2]));
 assert(!calls.some(c=>c[0]==='show'&&c[1]===3&&!c[2]));
}
calls.length=0;u[q+'SetOutcomeText']('짧은 결과');assert(calls.some(c=>c[0]==='show'&&c[1]===200&&c[2]));
calls.length=0;u[q+'ImagePixelAspect']=1;u[q+'SetOutcomeText']('짧은 결과');assert(calls.length>0);
console.log('PASS 결과 행간 0.015, 보상색, 캐시, 넘침/긴 단어 대체, 결과 전환과 화면 비율 재배치.');
