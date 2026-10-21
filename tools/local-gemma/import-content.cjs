// 프로젝트 제작 도구가 이미 보존한 Gemma 응답을 PC의 모니터링 기록으로 가져온다.
const path = require('node:path');
const fs = require('node:fs');
const {createMonitor} = require('./monitor.cjs');
const {importContentArchive} = require('./content.cjs');
const {MODEL} = require('./server.cjs');

try {
  const directory = process.argv[2] && path.resolve(process.argv[2]);
  if (!directory || !fs.statSync(directory).isDirectory()) throw new Error('drafts와 reviews가 있는 원본 보관 폴더를 지정해 주세요.');
  if (!process.env.LOCALAPPDATA) throw new Error('Windows 로컬 저장 폴더가 없습니다.');
  const monitor = createMonitor(path.join(process.env.LOCALAPPDATA, 'ArcanaGemma', 'records'), {recoverInterrupted: false});
  const summary = importContentArchive(monitor, directory, MODEL);
  console.log(JSON.stringify(summary, null, 2));
  if (summary.errors.length) process.exitCode = 1;
} catch (error) { console.error(error.message); process.exitCode = 1; }
