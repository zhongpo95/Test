// 로컬 Gemma 4의 사건·카드 초안과 재검토 응답을 원문 그대로 보존한다.
'use strict';
const fs = require('node:fs');
const path = require('node:path');

async function run() {
  const [requestFile, outputFile] = process.argv.slice(2);
  if (!requestFile || !outputFile) throw new Error('요청 JSON과 출력 JSON 경로를 지정해 주세요.');
  if (fs.existsSync(outputFile)) throw new Error('기존 응답 파일을 덮어쓰지 않습니다.');
  const request = JSON.parse(fs.readFileSync(requestFile, 'utf8').replace(/^\uFEFF/, ''));
  if (!request.system || !request.brief) throw new Error('system과 brief가 필요합니다.');
  const payload = {
    model: 'gemma4:12b-it-qat', stream: false, think: false,
    format: request.schema || (request.review ? 'json' : require('./content-schema.json')), keep_alive: '10m',
    messages: [{role: 'system', content: request.system}, {role: 'user', content: JSON.stringify(request.brief)}],
    options: {num_ctx: 16384, num_predict: 8192, temperature: request.review ? 0.15 : 0.7, top_p: 0.95, top_k: 64}
  };
  const started = new Date().toISOString();
  console.log('Gemma 4 요청 시작. ' + path.basename(requestFile));
  const response = await fetch('http://127.0.0.1:11435/api/chat', {
    method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(payload),
    signal: AbortSignal.timeout(300000)
  });
  if (!response.ok) throw new Error('모델 서버 오류. HTTP ' + response.status);
  const raw = await response.json();
  if (raw.error) throw new Error(raw.error);
  let parsed = null;
  let parseError = null;
  try { parsed = JSON.parse(raw.message?.content || ''); } catch (error) { parseError = error.message; }
  fs.mkdirSync(path.dirname(outputFile), {recursive: true});
  fs.writeFileSync(outputFile, JSON.stringify({started, finished: new Date().toISOString(), request, payload, raw, parsed, parseError}, null, 2) + '\n', {flag: 'wx'});
  if (raw.done_reason === 'length' || parseError) throw new Error('잘림 또는 JSON 오류. 원문은 출력 파일에 보존했습니다.');
  console.log(JSON.stringify({file: outputFile, seconds: +(raw.total_duration / 1e9).toFixed(1), tokens: raw.eval_count, keys: Object.keys(parsed)}));
}
run().catch(error => {console.error(error.message);process.exitCode = 1;});
