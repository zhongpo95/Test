// 로컬 Gemma의 호출 제한과 번역 보존 및 검토 대화의 자료 유지를 모의 검증한다.
const assert = require('node:assert/strict');
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const {test} = require('node:test');
const {createServer, MODEL, protectedValues, validateTranslation} = require('./server.cjs');

async function fixture(t, responder, options = {}) {
  const calls = [];
  const server = createServer({logDirectory: null, ...options, fetchImpl: async (url, options) => {
    calls.push({url, options, body: options.body ? JSON.parse(options.body) : null});
    return responder(url, options, calls);
  }});
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  t.after(() => new Promise(resolve => { server.close(resolve); server.closeAllConnections(); }));
  const base = `http://127.0.0.1:${server.address().port}`;
  const html = await (await fetch(base)).text();
  const token = html.match(/const token = '([a-f0-9]+)'/)[1];
  const post = (body, headers = {}, route = '/api/run') => fetch(base + route, {method: 'POST', headers: {'Content-Type': 'application/json', 'X-Session-Token': token, ...headers}, body: JSON.stringify(body)});
  const get = route => fetch(base + route, {headers: {'X-Session-Token': token}});
  return {base, token, post, get, calls};
}
function recordsDirectory(t) {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'arcana-gemma-monitor-'));
  assert(path.resolve(directory).startsWith(path.resolve(os.tmpdir()) + path.sep));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  return directory;
}
const response = data => new Response(JSON.stringify(data), {headers: {'Content-Type': 'application/json'}});
const translation = {mode: 'translate', language: 'ko', text: '获得100金币。|n恢复药水+1次。', glossary: '金币=골드'};
const review = {mode: 'review', ...require('./검토요청예시.json')};
const imageBytes = fs.readFileSync(path.join(__dirname, '../../assets/expedition/preview-start.png'));
const image = {name: 'preview-start.png', data: 'data:image/png;base64,' + imageBytes.toString('base64')};

test('이미지만 있는 검토와 후속 수정 이미지를 실제 메시지의 이미지 필드로 유지', async t => {
  const f = await fixture(t, () => response({message: {content: '카드 간격을 확인해 주세요.'}, done_reason: 'stop'}));
  const request = {...review, kind: 'image', brief: '카드 선택 화면의 가독성 검토', draft: '', images: [image]};
  const first = await f.post(request);
  assert.equal(first.status, 200);
  const answer = (await first.json()).text;
  assert.deepEqual(f.calls[0].body.messages.at(-1).images, [image.data.split(',')[1]]);
  assert(f.calls[0].body.messages.at(-1).content.includes(image.name));
  const revised = {...image, name: '수정본.png'};
  const history = [{role: 'user', content: request.text, images: [image]}, {role: 'assistant', content: answer}];
  assert.equal((await f.post({...request, text: '새 수정 이미지와 비교해 줘.', images: [revised], history})).status, 200);
  assert.deepEqual(f.calls[1].body.messages[2].images, [image.data.split(',')[1]]);
  assert(f.calls[1].body.messages.at(-1).content.includes('수정본.png'));
  assert.deepEqual(f.calls[1].body.messages.at(-1).images, [revised.data.split(',')[1]]);
});

test('이미지 URL·위조 형식·과대 해상도·개수와 assistant 이미지 첨부를 호출 전에 거부', async t => {
  const f = await fixture(t, () => response({}));
  const oversized = Buffer.from(imageBytes); oversized.writeUInt32BE(100000, 16);
  for (const patch of [
    {kind: 'image'}, {images: [{name: '외부 이미지', data: 'https://example.com/image.png'}]},
    {images: [{name: '거짓 PNG', data: 'data:image/png;base64,' + Buffer.from('<svg/>').toString('base64')}]},
    {images: [{name: '잘못된 MIME', data: image.data.replace('image/png', 'image/jpeg')}]},
    {images: [{name: '과대 이미지', data: 'data:image/png;base64,' + oversized.toString('base64')}]},
    {images: [{name: '과대 파일', data: 'data:image/png;base64,' + 'A'.repeat(5600001)}]},
    {images: [image, image, image, image]},
    {images: [image, image], history: [{role: 'user', content: '질문', images: [image, image]}, {role: 'assistant', content: '답변'}]},
    {history: [{role: 'user', content: '질문'}, {role: 'assistant', content: '답변', images: [image]}]}
  ]) assert.equal((await f.post({...review, ...patch})).status, 400);
  assert.equal(f.calls.length, 0);
});

test('JPEG 자료를 전달하고 이미지 때문에 넘친 텍스트 예산을 조용히 잘라내지 않음', async t => {
  const f = await fixture(t, () => response({message: {content: '검토'}, done_reason: 'stop'}));
  const jpeg = fs.readFileSync(path.join(__dirname, '../../assets/upgrade/portrait-source.jpg'));
  const picture = {name: 'portrait.jpg', data: 'data:image/jpeg;base64,' + jpeg.toString('base64')};
  assert.equal((await f.post({...review, images: [picture]})).status, 200);
  const count = f.calls.length;
  assert.equal((await f.post({...review, brief: 'a'.repeat(3900), draft: 'b'.repeat(3900), images: [image, image, image]})).status, 400);
  assert.equal(f.calls.length, count);
});

test('검토 대화에 최초 조건·초안·이전 답변·최신 수정본을 함께 유지', async t => {
  const f = await fixture(t, () => response({message: {content: 'A 보상과 B 개인 자원을 수정해 주세요.'}, done_reason: 'stop'}));
  const first = await f.post(review);
  assert.equal(first.status, 200);
  const answer = (await first.json()).text;
  const revised = '수정본. A는 무료 100골드. B는 개인 골드 50을 지불하고 단서. C는 무료 떠나기. 다시 확인해 줘.';
  const history = [{role: 'user', content: review.text}, {role: 'assistant', content: answer, tool_calls: [{name: 'shell'}]}];
  assert.equal((await f.post({...review, text: revised, history, model: 'cloud', tools: ['shell']})).status, 200);
  const messages = f.calls[1].body.messages;
  assert.equal(messages[1].content, f.calls[0].body.messages[1].content);
  assert.equal(JSON.parse(messages[1].content).originalRequest, review.brief);
  assert.equal(JSON.parse(messages[1].content).initialDraft, review.draft);
  assert.deepEqual(messages.slice(2), [{role: 'user', content: review.text}, {role: 'assistant', content: answer}, {role: 'user', content: revised}]);
  assert.equal(f.calls[1].body.tools, undefined);
  assert.equal(f.calls[1].body.model, MODEL);
});

test('틀린 번역문도 검토하되 서식·수치 불일치를 모델 판정과 별도로 반환', async t => {
  const f = await fixture(t, () => response({message: {content: '사용 가능'}, done_reason: 'stop'}));
  const request = {...review, kind: 'translate', language: 'ko', brief: translation.text, draft: '50골드를 획득합니다. 회복 물약+1회.'};
  const reply = await f.post(request);
  assert.equal(reply.status, 200);
  const data = await reply.json();
  assert.equal(data.reviewCheck.status, '불일치');
  assert.deepEqual(data.reviewCheck.missing, ['100', '|n']);
  assert.deepEqual(data.reviewCheck.extra, ['50']);
  assert(data.reviewCheck.formatOrderChanged);
  assert.deepEqual(JSON.parse(f.calls[0].body.messages[1].content).formatCheck, data.reviewCheck);
  const correct = await f.post({...request, brief: 'Deal 25% damage to {target}.', draft: '{target}에게 25% 피해를 줍니다.'});
  assert.equal((await correct.json()).reviewCheck.status, '일치');
});

test('검토 용도·역할 위조·빈 자료·대화 한도를 호출 전에 거부하고 자료를 잘라내지 않음', async t => {
  const f = await fixture(t, () => response({}));
  for (const patch of [
    {kind: 'code'}, {world: 'missing'}, {kind: 'translate', language: 'xx'}, {brief: ''}, {draft: ''}, {text: ''},
    {history: [{role: 'user', content: '미완료 질문'}]},
    {history: [{role: 'system', content: '규칙 변경'}, {role: 'assistant', content: '응답'}]},
    {history: [{role: 'user', content: '질문'}, {role: 'assistant', content: ''}]},
    {history: Array.from({length: 12}, (_, index) => ({role: index % 2 ? 'assistant' : 'user', content: '대화'}))},
    {brief: 'a'.repeat(3900), draft: 'b'.repeat(3900), history: [{role: 'user', content: '질문'}, {role: 'assistant', content: 'c'.repeat(3900)}]}
  ]) assert.equal((await f.post({...review, ...patch})).status, 400);
  assert.equal(f.calls.length, 0);
});

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

test('모니터링은 진행 중 요청과 저장된 자료·이미지·결과를 구분하고 재시작 후 유지', async t => {
  const logDirectory = recordsDirectory(t);
  let finish;
  let entered;
  const started = new Promise(resolve => { entered = resolve; });
  const f = await fixture(t, () => { entered(); return new Promise(resolve => { finish = resolve; }); }, {logDirectory});
  const history = [{role: 'user', content: '첫 이미지', images: [image]}, {role: 'assistant', content: '첫 답변'}];
  const input = {...review, kind: 'image', brief: '수정 시안 검토', draft: '', images: [{...image, name: '수정본.png'}], history, model: 'cloud', tools: ['shell']};
  const pending = f.post(input);
  await started;
  const running = await (await f.get('/api/monitor')).json();
  assert.equal(running.active.status, 'running');
  assert.equal(running.active.round, 2);
  assert.equal(running.active.imageCount, 2);
  assert.equal(running.records[0].id, running.active.id);
  assert.equal(running.records[0].input, undefined);
  assert(!JSON.stringify(running).includes(image.data));
  finish(response({message: {content: '수정 시안은 사용 가능'}, eval_duration: 1e9, total_duration: 2e9, eval_count: 70}));
  assert.equal((await pending).status, 200);
  const complete = await (await f.get('/api/monitor')).json();
  assert.equal(complete.active, null);
  assert.equal(complete.records[0].status, 'success');
  assert.equal(complete.records[0].tokensPerSecond, 70);
  const detail = await (await f.get('/api/records/' + running.active.id)).json();
  assert.equal(detail.input.images[0].data, image.data);
  assert.deepEqual(detail.input.history, history);
  assert.equal(detail.input.tools, undefined);
  assert.equal(detail.result.text, '수정 시안은 사용 가능');
  assert.equal((await fetch(f.base + '/api/monitor')).status, 403);
  assert.equal((await fetch(f.base + '/api/records/' + detail.id)).status, 403);
  assert.equal((await f.get('/api/records/../../server.cjs')).status, 404);
  const reopened = await fixture(t, () => response({}), {logDirectory});
  assert.deepEqual((await (await reopened.get('/api/records/' + detail.id)).json()).input, detail.input);
  assert.equal((await (await reopened.get('/api/monitor')).json()).records[0].status, 'success');
});

test('모델 중단·시간 초과·서식 오류도 기록하고 설치 상태와 모델 적재 메모리를 구분', async t => {
  const logDirectory = recordsDirectory(t);
  const f = await fixture(t, url => url.endsWith('/api/tags') ? response({models: [{name: MODEL}]}) : url.endsWith('/api/ps') ? response({models: [{name: MODEL, size_vram: 123456, context_length: 16384}]}) : response({message: {content: '서식 없는 답변'}}), {logDirectory});
  assert.equal((await f.post(translation)).status, 502);
  const failed = (await (await f.get('/api/monitor')).json()).records[0];
  assert.equal(failed.status, 'error'); assert.match(failed.error, /누락/);
  const status = await (await f.get('/api/status')).json();
  assert.equal(status.ready, true); assert.equal(status.loaded, true); assert.equal(status.modelVramBytes, 123456); assert.equal(status.contextLength, 16384);
  const timeout = await fixture(t, (url, options) => new Promise((resolve, reject) => options.signal.addEventListener('abort', () => reject(new DOMException('timeout', 'AbortError')), {once: true})), {logDirectory, requestTimeoutMs: 25});
  assert.equal((await timeout.post({...review, kind: 'image', images: [image]})).status, 502);
  assert.equal((await (await timeout.get('/api/monitor')).json()).records[0].status, 'timeout');
  let entered;
  const started = new Promise(resolve => { entered = resolve; });
  const cancelled = await fixture(t, (url, options) => { entered(); return new Promise((resolve, reject) => options.signal.addEventListener('abort', () => reject(new DOMException('cancel', 'AbortError')), {once: true})); }, {logDirectory});
  const controller = new AbortController();
  const pending = fetch(cancelled.base + '/api/run', {method: 'POST', headers: {'Content-Type': 'application/json', 'X-Session-Token': cancelled.token}, body: JSON.stringify(review), signal: controller.signal});
  await started; controller.abort(); await assert.rejects(pending, {name: 'AbortError'});
  for (let attempt = 0; attempt < 20; attempt++) {
    const monitor = await (await cancelled.get('/api/monitor')).json();
    if (!monitor.active) { assert.equal(monitor.records[0].status, 'cancelled'); break; }
    if (attempt === 19) assert.fail('취소 상태 기록 실패');
    await new Promise(resolve => setTimeout(resolve, 10));
  }
});

test('모델 서버가 끊겨도 기록 조회 가능하며 기록 쓰기 실패는 결과를 잃지 않고 알림', async t => {
  const logDirectory = recordsDirectory(t);
  const f = await fixture(t, () => { throw new Error('fetch failed'); }, {logDirectory});
  assert.equal((await f.post(review)).status, 502);
  const status = await (await f.get('/api/status')).json();
  assert.equal(status.connected, false); assert.equal(status.ready, false); assert.equal(status.loaded, null);
  assert.equal((await (await f.get('/api/monitor')).json()).records[0].status, 'error');
  const blocked = path.join(logDirectory, 'file'); fs.writeFileSync(blocked, '폴더 대신 파일');
  const failure = await fixture(t, () => response({message: {content: '결과는 반환'}}), {logDirectory: blocked});
  assert.equal((await failure.post(review)).status, 200);
  const monitor = await (await failure.get('/api/monitor')).json();
  assert.match(monitor.storage.error, /실패/); assert.equal(monitor.records.length, 0); assert.equal(monitor.active, null);
});

test('번역·사건 요청의 무관한 이미지·이력 필드는 기록과 다음 요청을 방해하지 않음', async t => {
  const f = await fixture(t, () => response({message: {content: '초안'}}), {logDirectory: recordsDirectory(t)});
  assert.equal((await f.post({mode: 'story', world: 'original', text: '사건', history: '무관한 필드', images: {url: 'https://example.com'}})).status, 200);
  const item = (await (await f.get('/api/monitor')).json()).records[0];
  const detail = await (await f.get('/api/records/' + item.id)).json();
  assert.deepEqual(detail.input, {mode: 'story', world: 'original', text: '사건'});
  assert.equal((await f.post({}, {}, '/api/unload')).status, 200);
});

test('서버 종료 기록 복구와 100건·128MiB 보관 한도에 따른 오래된 기록 정리', t => {
  const {createMonitor} = require('./monitor.cjs');
  const logDirectory = recordsDirectory(t);
  let monitor = createMonitor(logDirectory);
  const running = monitor.begin(review);
  monitor = createMonitor(logDirectory);
  assert.equal(monitor.read(running.id).status, 'interrupted');
  for (let i = 0; i < 105; i++) {
    const record = monitor.begin({...review, text: `기록 ${i}`});
    monitor.finish(record, 'success', {text: '답변'});
  }
  assert.equal(monitor.list().records.length, 100);
  assert.equal(monitor.read(running.id), null);
  const largeDirectory = recordsDirectory(t);
  assert.equal(monitor.list().storage.maxBytes, 128 * 1024 * 1024);
  // 같은 용량 정리 경로를 작은 한도로 검증해 대용량 시험 파일을 만들지 않는다.
  const large = createMonitor(largeDirectory, {maxBytes: 4096});
  const old = large.begin({...review, text: '이전 자료'.repeat(200)}); large.finish(old, 'success', {text: '답변'});
  const record = large.begin(review); large.finish(record, 'success', {text: '새 답변'});
  assert.equal(large.read(old.id), null); assert.equal(large.list().records.length, 1);
});

const contentRequest = {sourceName: 'academy-text-01.json', review: false, system: '사건·카드 초안을 JSON으로 작성한다.', brief: {world: '학원도시', choices: ['A 100골드', 'B 개인 50골드', 'C 무료']}, schema: {type: 'object', properties: {story: {type: 'string'}}}};

test('제작 CLI의 긴 JSON 요청을 고정 모델·기존 추론 설정으로 기록하고 원문 응답 유지', async t => {
  const raw = {model: MODEL, message: {content: '{"story":"100골드 사건 초안"}'}, done_reason: 'stop', total_duration: 3e9, eval_duration: 1e9, eval_count: 65};
  const f = await fixture(t, () => response(raw), {logDirectory: recordsDirectory(t)});
  const input = {...contentRequest, brief: {text: '조건 '.repeat(1600)}, model: 'cloud', tools: ['shell'], stream: true, options: {num_ctx: 1}};
  const reply = await f.post(input, {}, '/api/content');
  assert.equal(reply.status, 200);
  const data = await reply.json(); assert.deepEqual(data.raw, raw);
  const payload = f.calls[0].body;
  assert.equal(payload.model, MODEL); assert.equal(payload.stream, false); assert.equal(payload.think, false); assert.equal(payload.keep_alive, '10m');
  assert.deepEqual(payload.options, {num_ctx: 16384, num_predict: 8192, temperature: 0.7, top_p: 0.95, top_k: 64});
  assert.deepEqual(JSON.parse(payload.messages[1].content), input.brief); assert.deepEqual(payload.format, input.schema); assert.equal(payload.tools, undefined);
  const detail = await (await f.get('/api/records/' + data.recordId)).json();
  assert.equal(detail.input.mode, 'content'); assert.equal(detail.status, 'success'); assert.deepEqual(detail.input.brief, input.brief); assert.deepEqual(detail.result.raw, raw);
  assert.equal((await f.post({...contentRequest, review: true}, {}, '/api/content')).status, 200);
  assert.equal(f.calls[1].body.options.temperature, 0.15);
});

test('잘린 제작 JSON·파싱 오류·모델 오류는 실패로 기록하며 CLI가 원문을 보존할 수 있게 반환', async t => {
  for (const raw of [{message: {content: '{"story":'}, done_reason: 'length'}, {message: {content: '잘못된 JSON'}}, {error: 'model failed'}]) {
    const f = await fixture(t, () => response(raw), {logDirectory: recordsDirectory(t)});
    const reply = await f.post(contentRequest, {}, '/api/content');
    assert.equal(reply.status, 200);
    const data = await reply.json(); assert.deepEqual(data.raw, raw);
    const detail = await (await f.get('/api/records/' + data.recordId)).json();
    assert.equal(detail.status, 'error'); assert(detail.error); assert.deepEqual(detail.result.raw, raw);
  }
});

test('제작 API도 인증·출처·자료 한도를 검사하고 동시 호출을 기존 요청과 함께 제한', async t => {
  const f = await fixture(t, () => response({}));
  assert.equal((await f.post(contentRequest, {'X-Session-Token': ''}, '/api/content')).status, 403);
  assert.equal((await f.post(contentRequest, {Origin: 'https://example.com'}, '/api/content')).status, 403);
  for (const patch of [{system: ''}, {brief: null}, {brief: {text: 'x'.repeat(256 * 1024)}}, {schema: null}, {schema: 'not-json'}, {schema: []}, {review: 'true'}, {sourceName: '../file.json'}]) assert.equal((await f.post({...contentRequest, ...patch}, {}, '/api/content')).status, 400);
  assert.equal(f.calls.length, 0);
  let finish;
  let entered;
  const started = new Promise(resolve => { entered = resolve; });
  const blocked = await fixture(t, () => { entered(); return new Promise(resolve => { finish = resolve; }); }, {logDirectory: recordsDirectory(t)});
  const pending = blocked.post(contentRequest, {}, '/api/content'); await started;
  const active = (await (await blocked.get('/api/monitor')).json()).active;
  assert.equal(active.mode, 'content'); assert.equal(active.preview, contentRequest.sourceName);
  assert.equal((await blocked.post(review)).status, 409);
  finish(response({message: {content: '{}'}})); assert.equal((await pending).status, 200);
});

test('기존 제작·검토 응답을 시각과 원문을 유지해 가져오고 중복·가공본·다른 모델 제외', t => {
  const {createMonitor} = require('./monitor.cjs');
  const {importContentArchive} = require('./content.cjs');
  const archive = recordsDirectory(t); const logDirectory = recordsDirectory(t);
  for (const group of ['drafts', 'reviews']) fs.mkdirSync(path.join(archive, group));
  const item = {started: '2026-10-01T01:00:00Z', finished: '2026-10-01T01:00:03Z', request: contentRequest, payload: {model: MODEL, format: contentRequest.schema}, raw: {message: {content: '{"story":"元の出力"}'}, done_reason: 'stop', total_duration: 3e9}};
  const file = path.join(archive, 'drafts', 'old.json'); fs.writeFileSync(file, JSON.stringify(item));
  fs.writeFileSync(path.join(archive, 'reviews', 'truncated.json'), JSON.stringify({...item, raw: {message: {content: '{'}, done_reason: 'length'}}));
  fs.writeFileSync(path.join(archive, 'drafts', 'curated.json'), JSON.stringify({story: '수정 원고'}));
  fs.writeFileSync(path.join(archive, 'drafts', 'other-model.json'), JSON.stringify({...item, payload: {...item.payload, model: 'other'}}));
  const monitor = createMonitor(logDirectory);
  const first = importContentArchive(monitor, archive, MODEL);
  assert.deepEqual(first, {imported: 2, skipped: 2, errors: []});
  const old = monitor.list().records.find(record => record.preview === 'old.json');
  assert.equal(old.archived, true); assert.equal(old.elapsedMs, 3000);
  const detail = monitor.read(old.id); assert.deepEqual(detail.result.raw, item.raw); assert.equal(detail.startedAt, item.started); assert.equal(detail.archive.file, file);
  assert.deepEqual(importContentArchive(monitor, archive, MODEL), {imported: 0, skipped: 4, errors: []});
  const live = monitor.begin(contentRequest);
  fs.writeFileSync(path.join(archive, 'drafts', 'already-monitored.json'), JSON.stringify({...item, monitorRecordId: live.id}));
  assert.equal(importContentArchive(monitor, archive, MODEL).imported, 0);
  assert.equal(monitor.list().active.id, live.id);
  const reopened = createMonitor(logDirectory, {recoverInterrupted: false}); assert.equal(reopened.read(live.id).status, 'running');
  assert.equal(fs.readFileSync(file, 'utf8'), JSON.stringify(item));
});
