// 사건 본문 FDF 연결과 실제 JASS의 캐시 및 생성 실패 경로를 검사한다.
const fs=require('node:fs'),assert=require('node:assert/strict');
const {environment}=require('./check-expedition.cjs');
const prefix='UIExpeditionPrototype_';let writes=[],loaded=[],created=[],fonts=[],fallback=0,result=17;
const {env:e}=environment(['UI/UI_ExpeditionPrototype.j'],{
 DzFrameSetFont:(...args)=>fonts.push(args),
 DzFrameSetText:(id,s)=>writes.push([id,s]),DzLoadToc:p=>loaded.push(p),FrameCount:()=>42,
 DzCreateFrame:(...args)=>{created.push(args);return result;},ExpUILabel:()=>{fallback++;return 23;}
},['PaperText','SetStoryText','CreateStoryText'].map(n=>prefix+n));
e[prefix+'StoryPanel']=9;
assert.equal(e[prefix+'CreateStoryText'](),17);
assert.deepEqual(loaded,['war3mapImported\\Arcana_EventStory.toc']);
assert.deepEqual(created,[['ArcanaEventStory',9,42]]);assert.equal(fallback,0);
result=0;assert.equal(e[prefix+'CreateStoryText'](),23);assert.equal(fallback,1);
assert.deepEqual(fonts,[[17,'Fonts\\DFHeiMd.ttf',0.011,0],[23,'Fonts\\DFHeiMd.ttf',0.011,0]]);
e[prefix+'StoryText']=17;
const value='첫 문단|n|n|cFF865500중요한 단서|r와 다음 줄';
e[prefix+'SetStoryText'](value);assert.equal(writes.length,1);assert(writes[0][1].includes('|n|n'));assert(writes[0][1].includes('|cff875b21'));
e[prefix+'SetStoryText'](value);assert.equal(writes.length,1);
e[prefix+'SetStoryText']('행동 상세');e[prefix+'SetStoryText'](value);assert.equal(writes.length,3);
const toc=fs.readFileSync('war3mapImported/Arcana_EventStory.toc','utf8').trim();assert(fs.existsSync(toc.replaceAll('\\','/')));
const fdf=fs.readFileSync(toc.replaceAll('\\','/'),'utf8');
for(const text of ['Frame "TEXTAREA" "ArcanaEventStory"','Height 0.242,','FontShadowColor 0.0 0.0 0.0 0.0,','FontShadowOffset 0.0 0.0,','TextAreaLineGap 0.002,','TextAreaMaxLines 512,','TextAreaScrollBar "ArcanaEventStoryScrollBar"'])assert(fdf.includes(text));
const ui=fs.readFileSync('UI/UI_ExpeditionPrototype.j','utf8');assert(!ui.includes('RenderSpacedStory'));assert(!ui.includes('StoryMeasure'));
console.log('PASS FDF/TOC 경로, 기본 높이/간격, 생성 실패 대체, 문단/색상 보존, 캐시/상세 복귀. 엔진 렌더링은 미검증.');
