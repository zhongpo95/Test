// 줄 분할이 한글, 색상 태그, 문장부호, 원문 줄바꿈과 넘침을 지키는지 1.28 바이트 단위 모의로 검사한다.
const assert=require('node:assert/strict');
const {environment}=require('./check-expedition.cjs');
const p='StoryLineLayout_';
const bytes=s=>Buffer.from(s,'utf8');
const {env:e}=environment(['UI/UI_StoryLineLayout.j'],{
 StringLength:s=>bytes(s).length,
 // 1.28처럼 바이트 단위로 자른다. 잘린 바이트도 다시 이어 붙이면 원래 글자가 되도록 latin1로 보존한다.
 SubString:(s,a,b)=>bytes(s).subarray(a,b).toString('latin1'),
 StringHash:s=>s,InitHashtable:()=>new Map(),SaveBoolean:(t,a,b,v)=>t.set(a+':'+b,v),HaveSavedBoolean:(t,a,b)=>t.has(a+':'+b)
});
// 모의 SubString이 latin1로 돌려준 조각을 원래 UTF-8 글자로 되돌린다.
const text=s=>Buffer.from(s,'latin1').toString('utf8');
const narrow=' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{}~';
e[p+'CharBytes']=3;for(const c of narrow)e.Narrow.set(c+':0',true);
const run=(v,w=0.274,f=0.011)=>{const ok=e.StoryLineLayout(v,w,f);return {ok,lines:Array.from({length:e.StoryLineCount},(_,i)=>text(e.StoryLines[i]))};};
const plain=s=>s.replace(/\|c[0-9a-fA-F]{8}|\|r/g,'');
const units=s=>[...plain(s)].reduce((n,c)=>n+(narrow.includes(c)?0.5:1),0);
const s534='죠스타 저택에 |cFF006B8F디오|r가 들어온 날, |cFF006B8F죠나단|r은 함께 지낼 또래를 반기려 한다. 그러나 디오는 가까워지려는 손길을 밀어내고 저택 안의 시선도 자기 쪽으로 돌린다. 죠나단은 한집에 산다는 이유만으로 서로를 이해할 수 없다는 사실을 처음 배운다.';
let r=run(s534);assert.equal(r.ok,true);
const cap=0.274/0.011;
for(const l of r.lines)assert(units(l)<=cap+1e-9,'줄 폭 초과 '+l);
// 글자, 문장부호, 공백이 빠지거나 늘지 않는다.
assert.equal(r.lines.map(plain).join(' '),plain(s534));
// 각 줄은 색상 태그가 짝을 이루고 깨진 글자가 없다.
for(const l of r.lines)assert(!l.includes('�'));
console.log(r.lines.join('\n'));
// 원문 줄바꿈과 빈 줄은 그대로 남고, 줄을 넘어가는 색상은 다음 줄 앞에 다시 붙는다.
const s133='수많은 학교가 모인 도시 키보토스에서 아비도스 고등학교는 사막화와 거액의 빚으로 |cFFA53528폐교 직전이다.|r 남은 학생은 |cFF006B8F시로코|r, |cFF006B8F세리카|r, 노노미, 아야네와 선배 |cFF006B8F호시노|r 다섯 명이다.|n|n이들은 대책위원회를 만들어 학교를 지키지만 헬멧단의 공격까지 반복된다.|n|n도움을 요청받아 온 어른인 선생이 길에서 지쳐 쓰러진다. 행동파 학생 시로코가 그를 발견하고 상태를 살핀다.';
r=run(s133);assert.equal(r.ok,true);assert.equal(r.lines.filter(l=>plain(l)==='').length,2);
for(const l of r.lines)assert(units(l)<=cap+1e-9);
const colored='가나다 |cFFA53528'+'라마바사 '.repeat(8)+'끝|r 다음';r=run(colored);assert.equal(r.ok,true);
assert(r.lines[1].startsWith('|cFFA53528'),'색상 이어 붙이기 '+r.lines[1]);
// 실패: 한 줄보다 긴 단어, 줄 수 초과, 빈 글.
assert.equal(run('가'.repeat(30)).ok,false);
assert.equal(run(Array(30).fill('가').join('|n')).ok,false);
assert.equal(run('').ok,false);
// 숫자와 소수점은 반 칸으로 세어 한 줄에 더 많이 담는다.
r=run('보상 +2.0% 증가 '.repeat(6));assert.equal(r.ok,true);for(const l of r.lines)assert(units(l)<=cap+1e-9);
// 보정값을 키우면 줄이 늘어난다.
const before=run(s534).lines.length;e.StoryLineEm=1.5;const after=run(s534).lines.length;e.StoryLineEm=1.0;assert(after>before);
console.log('PASS 한글/색상/문장부호 보존, 원문 줄바꿈 유지, 폭·줄 수 넘침 시 실패 반환. 실제 글꼴 폭과 게임 표시는 미검증.');
// 비교 샘플: 원본 TEXT를 먼저 채우고, 성공했을 때만 줄 TEXT를 모두 보인 뒤 원본을 숨긴다.
{
const q='UIExpeditionPrototype_';const calls=[];
const {env:u}=environment(['UI/UI_StoryLineLayout.j','UI/UI_ExpeditionPrototype.j'],{
 StringLength:s=>bytes(s).length,SubString:(s,a,b)=>bytes(s).subarray(a,b).toString('latin1'),
 StringHash:s=>s,InitHashtable:()=>new Map(),SaveBoolean:(t,a,b,v)=>t.set(a+':'+b,v),HaveSavedBoolean:(t,a,b)=>t.has(a+':'+b),
 DzFrameSetText:(f,s)=>calls.push(['text',f,s]),DzFrameShow:(f,v)=>calls.push(['show',f,v]),
 DzFrameClearAllPoints:()=>{},DzFrameSetPoint:()=>{},DzFrameSetSize:()=>{},DisplayTimedTextToPlayer:()=>{},
 ProtoEventStory:[],JN_FRAMEPOINT_TOPLEFT:0,JNStringReplace:(s,a,b)=>s.split(a).join(b),I2S:String,R2SW:(v,w,p)=>v.toFixed(p)
},['StoryLineLayout','StoryLineLayout_ByteUnits','StoryLineLayout_PushLine','StoryLineLayout_FlushWord','StoryLineLayout_StartWord',q+'PaperText',q+'PlaceCoverPart',q+'PitchRender']);
u.StoryLineLayout_CharBytes=3;for(const c of narrow)u.Narrow.set(c+':0',true);
u[q+'PitchOriginal']=1;u[q+'PitchRight']=2;u[q+'PitchInfo']=3;u[q+'PitchRoot']=4;
for(let i=0;i<u.STORY_LINE_MAX;i++)u[q+'PitchLines'][i]=100+i;
u.ProtoEventStory[534]=s534;u[q+'PitchEvent']=534;u[q+'PitchRender']();
const idx=(pred)=>calls.findIndex(pred);
const rightFilled=idx(c=>c[0]==='text'&&c[1]===2), lastLine=calls.map((c,i)=>c[0]==='show'&&c[1]>=100&&c[2]?i:-1).filter(i=>i>=0).pop(), rightHidden=idx(c=>c[0]==='show'&&c[1]===2&&c[2]===false);
assert(rightFilled>=0&&rightFilled<lastLine&&lastLine<rightHidden,'원본→줄 표시→원본 숨김 순서');
assert(calls.some(c=>c[0]==='text'&&c[1]===3&&c[2].includes('줄 배치')));
// 실패하면 오른쪽 원본은 보인 채로 남고 줄 TEXT는 하나도 보이지 않는다.
calls.length=0;u.ProtoEventStory[534]='가'.repeat(40);u[q+'PitchRender']();
assert(!calls.some(c=>c[0]==='show'&&c[1]>=100&&c[2]));assert(!calls.some(c=>c[0]==='show'&&c[1]===2&&c[2]===false));
assert(calls.some(c=>c[0]==='text'&&c[1]===3&&c[2].includes('분할 실패')));
// 줄 수가 높이를 넘치면 같은 방식으로 원본을 유지한다.
calls.length=0;u.ProtoEventStory[534]=Array(23).fill('가나다').join('|n');u[q+'PitchGap']=0.03;u[q+'PitchRender']();
assert(!calls.some(c=>c[0]==='show'&&c[1]===2&&c[2]===false));assert(calls.some(c=>c[0]==='text'&&c[1]===3&&c[2].includes('높이 넘침')));
console.log('PASS 샘플 전환 순서(원본 → 줄 표시 → 원본 숨김), 분할 실패·높이 넘침 시 원본 유지. 모의 실행이며 게임 표시는 미검증.');
}
