// 본문 표시가 측정 프레임에 의존하지 않고 문단과 색상을 유지하는지 검사한다.
const fs=require('fs'),assert=require('node:assert/strict');
const {environment}=require('./check-expedition.cjs');
const source=fs.readFileSync('UI/UI_ExpeditionPrototype.j','utf8');
assert(!source.includes('RenderSpacedStory'));assert(!source.includes('StoryMeasure'));assert(!source.includes('StoryCached'));
assert(source.includes('call PaperText(StoryText, ProtoDialogueStoryText(pid), PAPER_BODY)'));
assert(source.includes('call PaperText(StoryText, "[행동 상세 · 커서를 옮기면 사건 설명]|n" + ProtoDialogueChoiceText(pid, HoverBranch, false), PAPER_BODY)'));
let visible='';const {env}=environment(['UI/UI_ExpeditionPrototype.j'],{DzFrameSetText:(_,s)=>visible=s},['UIExpeditionPrototype_PaperText']);
for(const text of ['형제는 돌의 힘을 확인한다.|n|n로제 · 기다려 온 건 무엇이었던 거죠?','|cFF006B8F제노스|r와 함께 도시로 향한다.','긴 설명 '.repeat(100)]){
 env.UIExpeditionPrototype_PaperText(1,text,'|cff485047');assert.equal(visible.replace(/\|c[0-9a-f]{8}|\|r/gi,''),text.replace(/\|c[0-9a-f]{8}|\|r/gi,''));
}
console.log('PASS 본문·호버의 단일 TEXT 복구 및 문단·강조·긴 원문 보존. 실제 렌더링 미검증.');
