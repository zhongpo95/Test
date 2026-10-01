// 사건·카드 제작 CLI가 공통 기록 API를 사용하고 원문 응답 파일을 보존하는지 검사한다.
const {test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const {run} = require('./gemma-content.cjs');

function files(t) {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'arcana-gemma-client-'));
  assert(path.resolve(directory).startsWith(path.resolve(os.tmpdir()) + path.sep));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  t.mock.method(console, 'log', () => {});
  const requestFile = path.join(directory, 'request.json');
  const outputFile = path.join(directory, 'output.json');
  const request = {system: '사건을 JSON으로 작성한다.', brief: {world: '새 세계관'}, review: false};
  fs.writeFileSync(requestFile, JSON.stringify(request));
  return {requestFile, outputFile, request};
}

function recordingFetch(raw, calls = []) {
  return async (url, options) => {
    calls.push({url, options});
    if (url.endsWith('/')) return new Response("const token = 'abcdef123456';");
    return new Response(JSON.stringify({raw, recordId: '11111111-1111-1111-1111-111111111111'}));
  };
}

test('공통 기록 API로만 호출하고 요청·원래 payload·raw와 기록 ID를 출력 파일에 보존', async t => {
  const f = files(t); const calls = [];
  const raw = {message: {content: '{"events":[]}'}, total_duration: 1e9, eval_count: 30};
  await run([f.requestFile, f.outputFile], {fetchImpl: recordingFetch(raw, calls)});
  assert.deepEqual(calls.map(item => item.url), ['http://127.0.0.1:18765/', 'http://127.0.0.1:18765/api/content']);
  assert.equal(calls[1].options.headers['X-Session-Token'], 'abcdef123456');
  const body = JSON.parse(calls[1].options.body); assert.equal(body.sourceName, 'request.json'); assert.deepEqual(body.schema, require('./content-schema.json'));
  const saved = JSON.parse(fs.readFileSync(f.outputFile, 'utf8'));
  assert.deepEqual(saved.request, f.request); assert.deepEqual(saved.raw, raw); assert.deepEqual(saved.parsed, {events: []});
  assert.equal(saved.payload.model, 'gemma4:12b-it-qat'); assert.equal(saved.payload.options.num_predict, 8192);
  assert.equal(saved.monitorRecordId, '11111111-1111-1111-1111-111111111111');
  await assert.rejects(run([f.requestFile, f.outputFile], {fetchImpl: recordingFetch(raw, calls)}), /덮어쓰지/);
  assert.equal(calls.length, 2);
});

test('JSON 잘림·파싱 오류도 원래 응답 파일을 만든 뒤 오류로 알림', async t => {
  const f = files(t);
  for (const [index, raw] of [{message: {content: '{"events":[]}'}, done_reason: 'length'}, {message: {content: '{'}}].entries()) {
    const output = path.join(path.dirname(f.outputFile), `broken-${index}.json`);
    await assert.rejects(run([f.requestFile, output], {fetchImpl: recordingFetch(raw)}), /원문은 출력 파일에 보존/);
    const saved = JSON.parse(fs.readFileSync(output, 'utf8')); assert.deepEqual(saved.raw, raw); assert(saved.monitorRecordId);
  }
});

test('기록 서버 연결·API 실패 시 기록 없는 직접 Ollama 호출로 우회하지 않음', async t => {
  const f = files(t); const calls = [];
  await assert.rejects(run([f.requestFile, f.outputFile], {fetchImpl: async url => { calls.push(url); throw new Error('offline'); }}), /모니터링 서버에 연결/);
  assert.deepEqual(calls, ['http://127.0.0.1:18765/']); assert(!fs.existsSync(f.outputFile));
  await assert.rejects(run([f.requestFile, f.outputFile], {fetchImpl: async url => url.endsWith('/') ? new Response("const token = 'abcdef';") : new Response(JSON.stringify({error: '처리 중인 요청'}), {status: 409})}), /처리 중인 요청/);
  assert(!fs.existsSync(f.outputFile));
});
