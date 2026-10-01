// 부분 실행으로 보존된 원안을 덮어쓰지 않고 미식전 집필 요청만 완성한다.
'use strict';
const fs=require('node:fs'),path=require('node:path'),vm=require('node:vm');
const file=path.join(__dirname,'prepare-gourmet-expansion-06.cjs');
const code=fs.readFileSync(file,'utf8').split('\n').filter(line=>!line.startsWith("fs.writeFileSync(path.join(root,'revisions/gourmet-pitch-selection-05.json')")&&!line.startsWith("fs.writeFileSync(path.join(root,'requests/gourmet-expansion-fixed-06.json')")).join('\n');
vm.runInNewContext(code,{require,__dirname,console},{filename:file});
