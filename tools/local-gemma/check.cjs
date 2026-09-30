// 로컬 Gemma의 호출 제한과 번역 서식 보존 및 오류 처리를 모의 검증한다.
const assert = require('node:assert/strict');
const http = require('node:http');
const {test} = require('node:test');
const {createServer, MODEL, protectedValues, validateTranslation} = require('./server.cjs');

async function fixture(t, responder) {
  const calls = [];
  const server = createServer({fetchImpl: async (url, options) => {
    calls.push({url, options, body: options.body ? JSON.parse(options.body) : null});
    return responder(url, options, calls);
  }});
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  t.after(() => new Promise(resolve => { server.close(resolve); server.closeAllConnections(); }));
  const base = `http://127.0.0.1:${server.address().port}`;
  const html = await (await fetch(base)).text();
  const token = html.match(/const token = '([a-f0-9]+)'/)[1];
  const post = (body, headers = {}, route = '/api/run') => fetch(base + route, {method: 'POST', headers: {'Content-Type': 'application/json', 'X-Session-Token': token, ...headers}, body: JSON.stringify(body)});
  return {base, token, post, calls};
}
const response = data => new Response(JSON.stringify(data), {headers: {'Content-Type': 'application/json'}});
const translation = {mode: 'translate', language: 'ko', text: '获得100金币。|n恢复药水+1次。', glossary: '金币=골드'};

test('Warcraft 서식·숫자·변수·rawcode·경로와 실제 줄바꿈 보존 및 누락 거부', () => {
  const original = "|cff00ff00伤害+12.5%|r|n{hero} %s 'I0CC' war3mapImported\\icon.blp\r\n下一行";
  const saved = protectedValues(original);
  assert.equal(validateTranslation(saved.source, saved.values), original);
  assert.throws(() => validateTranslation(saved.source.replace('|cff00ff00', ''), saved.values), /누락/);
  assert.throws(() => validateTranslation(saved.source + ' 12.5%', saved.values), /누락/);
  assert.throws(() => validateTranslation(saved.source.replace('12.5%', '15%'), saved.values), /변경/);
  assert.throws(() => validateTranslation(saved.source.replace('|r|n', '|n|r'), saved.values), /변경/);
  assert.equal(validateTranslation('{target}에게 25% 피해.', protectedValues('Deal 25% damage to {target}.').values), '{target}에게 25% 피해.');
});

test('인증 누락·타 사이트·외부 Host·다른 용도·과대 입력을 모델 호출 전에 거부', async t => {
  const f = await fixture(t, () => response({}));
  assert.equal((await f.post(translation, {'X-Session-Token': ''})).status, 403);
  assert.equal((await f.post(translation, {Origin: 'https://example.com'})).status, 403);
  const foreignHost = await new Promise(resolve => {
    http.get(f.base, {headers: {Host: 'example.com'}}, reply => { reply.resume(); resolve(reply.statusCode); });
  });
  assert.equal(foreignHost, 403);
  assert.equal((await f.post({...translation, mode: 'code'})).status, 400);
  assert.equal((await f.post({...translation, text: '가'.repeat(4001)})).status, 400);
  assert.equal((await f.post({...translation, language: 'xx'})).status, 400);
  assert.equal((await f.post(translation, {}, '/api/execute')).status, 404);
  assert.equal(f.calls.length, 0);
});

test('고정 로컬 모델로 번역하고 서식 복원 및 실제 응답 속도 반환', async t => {
  const f = await fixture(t, () => response({message: {content: '골드 100 획득.|n회복 물약 +1회.'}, done_reason: 'stop', total_duration: 2000000000, eval_duration: 1000000000, eval_count: 30}));
  const reply = await f.post({...translation, model: 'gemma4:cloud', tools: [{name: 'shell'}]});
  assert.equal(reply.status, 200);
  const data = await reply.json();
  assert.equal(data.text, '골드 100 획득.|n회복 물약 +1회.');
  assert.equal(data.tokensPerSecond, 30);
  assert.equal(f.calls[0].body.model, MODEL);
  assert.equal(f.calls[0].url, 'http://127.0.0.1:11435/api/chat');
  assert.equal(f.calls[0].body.tools, undefined);
  assert.equal(f.calls[0].body.think, false);
});

test('세계관 참고를 포함한 사건 생성과 지원하지 않는 세계관 거부', async t => {
  const f = await fixture(t, () => response({message: {content: '초안'}, done_reason: 'stop'}));
  assert.equal((await f.post({mode: 'story', world: 'scarlet', text: '새로운 사건'})).status, 200);
  const prompt = JSON.parse(f.calls[0].body.messages[1].content);
  assert(prompt.projectReference.includes('홍마관'));
  assert(prompt.projectReference.includes('ProtoSetScene'));
  assert.equal((await f.post({mode: 'story', world: 'missing', text: '사건'})).status, 400);
});

test('출력 잘림·서식 손실·빈 답변·서버 실패를 성공 결과로 반환하지 않음', async t => {
  for (const data of [{message: {content: '잘림'}, done_reason: 'length'}, {message: {content: '서식 삭제'}}, {message: {content: ''}}]) {
    const f = await fixture(t, () => response(data));
    assert.equal((await f.post(translation)).status, 502);
  }
  const f = await fixture(t, () => { throw new Error('fetch failed'); });
  assert.equal((await f.post(translation)).status, 502);
});

test('생성 중 중복 호출을 거부하고 완료 후 메모리 해제 가능', async t => {
  let finish;
  let entered;
  const started = new Promise(resolve => { entered = resolve; });
  const f = await fixture(t, (url, options, calls) => {
    if (calls.length === 1) { entered(); return new Promise(resolve => { finish = resolve; }); }
    return response({done: true});
  });
  const first = f.post({mode: 'story', world: 'original', text: '사건'});
  await started;
  assert.equal((await f.post(translation)).status, 409);
  finish(response({message: {content: '초안'}, done_reason: 'stop'}));
  assert.equal((await first).status, 200);
  assert.equal((await f.post({}, {}, '/api/unload')).status, 200);
  assert.equal(f.calls[1].body.keep_alive, 0);
});

test('화면 요청 취소가 모델 요청까지 전달되고 다음 요청을 다시 허용', async t => {
  let entered;
  let aborted;
  const started = new Promise(resolve => { entered = resolve; });
  const cancelled = new Promise(resolve => { aborted = resolve; });
  const f = await fixture(t, (url, options, calls) => {
    if (calls.length > 1) return response({done: true});
    entered();
    return new Promise((resolve, reject) => options.signal.addEventListener('abort', () => {
      aborted();
      reject(new DOMException('cancelled', 'AbortError'));
    }, {once: true}));
  });
  const controller = new AbortController();
  const first = fetch(f.base + '/api/run', {method: 'POST', headers: {'Content-Type': 'application/json', 'X-Session-Token': f.token}, body: JSON.stringify({mode: 'story', world: 'original', text: '사건'}), signal: controller.signal});
  await started;
  controller.abort();
  await assert.rejects(first, {name: 'AbortError'});
  await cancelled;
  assert.equal((await f.post({}, {}, '/api/unload')).status, 200);
});
