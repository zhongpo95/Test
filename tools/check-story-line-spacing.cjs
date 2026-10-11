// 사건 본문의 문단 여백과 TEXT 표시 및 캐시를 실제 JASS 함수로 검사한다.
const fs=require('node:fs'),assert=require('node:assert/strict');
const {environment}=require('./check-expedition.cjs');
const prefix='UIExpeditionPrototype_';let writes=[],loaded=[],created=[],fonts=[],fallback=0,result=17;
const {env:e}=environment(['UI/UI_ExpeditionPrototype.j'],{
 StringLength:s=>Buffer.byteLength(s),SubString:(s,a,b)=>Buffer.from(s).subarray(a,b).toString(),JNStringCount:(s,t)=>s.split(t).length-1,
 DzFrameSetFont:(...args)=>fonts.push(args),
 DzFrameSetText:(id,s)=>writes.push([id,s]),DzLoadToc:p=>loaded.push(p),FrameCount:()=>42,
 DzCreateFrame:(...args)=>{created.push(args);return result;},ExpUILabel:()=>{fallback++;return 23;}
},['SpaceStoryParagraphs','PaperText','SetStoryText','CreateStoryText'].map(n=>prefix+n));
e[prefix+'StoryPanel']=9;
assert.equal(e[prefix+'CreateStoryText'](),23);
assert.equal(fallback,1);assert.deepEqual(loaded,[]);assert.deepEqual(created,[]);
e[prefix+'StoryText']=17;
const value='첫 문단|n|n|cFF865500중요한 단서|r와 다음 줄';
e[prefix+'SetStoryText'](value);assert.equal(writes.length,1);assert(writes[0][1].includes('|n|n'));assert(writes[0][1].includes('|cff875b21'));
e[prefix+'SetStoryText'](value);assert.equal(writes.length,1);
e[prefix+'SetStoryText']('행동 상세');e[prefix+'SetStoryText'](value);assert.equal(writes.length,3);
const space=e[prefix+'SpaceStoryParagraphs'];
assert.equal(space('첫 문장입니다. 다음 문장입니다.'),'첫 문장입니다.|n|n다음 문장입니다.');
assert.equal(space('첫 문단|n|n대사'),'첫 문단|n|n|n대사');
assert.equal(space('보상 +2.0%'),'보상 +2.0%');
assert.equal(space('가'.repeat(301)+' 끝. 다음'),'가'.repeat(301)+' 끝. 다음');
const many='문단|n|n'.repeat(3)+'끝';assert.equal(space(many),many);
const colored='|cff123456첫 문장입니다. 다음 문장|r';assert.equal(space(colored),'|cff123456첫 문장입니다.|n|n다음 문장|r');
assert(writes[0][1].includes('|n|n|n'));
const ui=fs.readFileSync('UI/UI_ExpeditionPrototype.j','utf8');assert(!ui.includes('RenderSpacedStory'));assert(!ui.includes('StoryMeasure'));
console.log('PASS 기존 TEXT 생성, FDF 미호출, 문단/색상 보존, 캐시/상세 복귀. 엔진 렌더링은 미검증.');
