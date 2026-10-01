// 무료 사건·행동력 최대치·기본 후보 세 개를 구현하기 전 관련 소스를 해시와 함께 보존한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),files=['Data/Data_Expedition.j','Data/Data_PrototypeStats.j','System/ExpeditionPrototype.j','UI/UI_ExpeditionPrototype.j','tools/generate-prototype-content.cjs','tools/generate-content-review.cjs','tools/check-content-candidates.cjs','tools/content-schema.json','tools/check-hunt-prototype.cjs'];
const saved=[];for(const p of files){const bytes=fs.readFileSync(p),out=path.join(root,'before-action-options-94',p);fs.mkdirSync(path.dirname(out),{recursive:true});fs.writeFileSync(out,bytes,{flag:'wx'});saved.push({path:p,sha256:crypto.createHash('sha256').update(bytes).digest('hex')});}
fs.writeFileSync(path.join(root,'before-action-options-94/manifest.json'),JSON.stringify({sourceRevision:'bc8ca55',reason:'사용자가 무료사건·행동력최대치·특정카드조건을 이번재제작에 포함하고 후보와사건행동모두기본세개를 요청했다.',files:saved,policy:'원본은 활성 Import에서 제외한다. 맵을 만들지 않는다.'},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({archived:saved.length,mapCreated:false}));
