// 줄 진단의 로컬 격리, 본문 읽기, 닫기와 재사용을 검사한다.
const assert=require('node:assert/strict');
const {environment}=require('./check-expedition.cjs');
const p='UIExpeditionPrototype_';const logs=[],shown=[];let reads=0;
const {env:e}=environment(['UI/UI_ExpeditionPrototype.j'],{
 StringLength:s=>Buffer.byteLength(s),SubString:(s,a,b)=>Buffer.from(s).subarray(a,b).toString(),JNStringCount:(s,t)=>s.split(t).length-1,
 DisplayTimedTextToPlayer:(...args)=>logs.push(args[4]),DzFrameShow:(...args)=>shown.push(args),DzFrameGetText:()=>{reads++;return '현재 프레임|n|n원문';},ProtoDialogueStoryText:()=> '현재 원문',
 ProtoEventStory:[],ProtoStage:[2],ProtoSelected:[534],ExpUIPanel:9
},['SpaceStoryParagraphs','LineTestLog','LineTest','LineTestClose'].map(n=>p+n));
e.DzGetTriggerUIEventPlayer=()=>e.eventPlayer;
e[p+'LineTestRoot']=17;e[p+'StoryText']=23;e.ProtoEventStory[534]='첫 문장. 다음 문장';e.ProtoEventStory[133]='첫 문단|n|n둘째 문단';
e.eventPlayer=1;e[p+'LineTest']();assert.equal(logs.length,0);assert.equal(shown.length,0);
e.eventPlayer=0;e[p+'LineTest']();assert.equal(reads,1);assert.equal(e[p+'LineTestVisible'],true);assert(logs.some(s=>s.includes('첫 문장./N//N/다음 문장')));assert(logs.some(s=>s.includes('현재 프레임/N//N/원문')));
const count=logs.length;e[p+'LineTest']();assert.equal(logs.length,count);assert.equal(e[p+'LineTestVisible'],false);
e[p+'LineTest']();e.eventPlayer=1;e[p+'LineTestClose']();assert.equal(e[p+'LineTestVisible'],true);e.eventPlayer=0;e[p+'LineTestClose']();assert.equal(e[p+'LineTestVisible'],false);
e.ExpUIPanel=0;e[p+'LineTest']();assert.equal(reads,2);assert(logs.some(s=>s.includes('T2는 사건')));
console.log('PASS 로컬 격리, 진단 문자열, 본문 읽기, 토글/닫기, 비사건 안내. 실제 게임 표시 미검증.');
