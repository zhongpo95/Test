// 사건·카드 제작 도구의 JSON 요청과 기존 응답 파일을 공통 모니터링에 연결한다.
const fs = require('node:fs');
const path = require('node:path');
const {createHash} = require('node:crypto');

function buildContent(input) {
  if (!input || typeof input !== 'object' || Array.isArray(input)) throw new Error('사건·카드 요청 형식이 잘못됐습니다.');
  if (typeof input.system !== 'string' || !input.system.trim() || input.system.length > 20000) throw new Error('system은 비어 있지 않은 20,000자 이내 텍스트여야 합니다.');
  if (!input.brief || !['string', 'object'].includes(typeof input.brief) || Buffer.byteLength(JSON.stringify(input.brief)) > 256 * 1024) throw new Error('brief는 256KiB 이내의 자료여야 합니다.');
  if (input.schema !== 'json' && (!input.schema || typeof input.schema !== 'object' || Array.isArray(input.schema))) throw new Error('JSON 출력 스키마를 지정해 주세요.');
  if (Buffer.byteLength(JSON.stringify(input.schema)) > 128 * 1024) throw new Error('출력 스키마가 너무 큽니다.');
  if (input.review !== undefined && typeof input.review !== 'boolean') throw new Error('review는 true 또는 false여야 합니다.');
  const name = input.sourceName || '사건·카드 요청';
  if (typeof name !== 'string' || name.length > 150 || /[\\/]/.test(name)) throw new Error('자료 이름은 경로가 아닌 150자 이내 파일명이어야 합니다.');
  return {mode: 'content', text: name, system: input.system, brief: input.brief, schema: input.schema, review: !!input.review};
}

function contentPayload(input, model) {
  return {model, stream: false, think: false, format: input.schema, keep_alive: '10m',
    messages: [{role: 'system', content: input.system}, {role: 'user', content: JSON.stringify(input.brief)}],
    options: {num_ctx: 16384, num_predict: 8192, temperature: input.review ? 0.15 : 0.7, top_p: 0.95, top_k: 64}};
}

function contentResult(raw) {
  let parsed = null;
  let parseError = null;
  const text = raw.message?.content || '';
  try { parsed = JSON.parse(text); } catch (error) { parseError = error.message; }
  const seconds = (raw.eval_duration || 0) / 1e9;
  const result = {text, seconds: (raw.total_duration || 0) / 1e9, tokensPerSecond: seconds ? (raw.eval_count || 0) / seconds : 0, raw, parsed, parseError};
  const error = raw.error || (raw.done_reason === 'length' ? '출력 길이 한도로 JSON 답변이 잘렸습니다.' : parseError ? '모델 답변의 JSON 형식이 잘못됐습니다.' : undefined);
  return {result, error};
}

function importContentArchive(monitor, directory, model) {
  let imported = 0;
  let skipped = 0;
  const errors = [];
  for (const group of ['drafts', 'reviews']) {
    const folder = path.join(directory, group);
    if (!fs.existsSync(folder)) continue;
    for (const name of fs.readdirSync(folder).filter(name => name.endsWith('.json'))) {
      const file = path.join(folder, name);
      try {
        if (!fs.statSync(file).isFile() || fs.statSync(file).size > 18 * 1024 * 1024) throw new Error('파일이 너무 크거나 일반 파일이 아닙니다.');
        const bytes = fs.readFileSync(file);
        const item = JSON.parse(bytes.toString('utf8').replace(/^\uFEFF/, ''));
        if (!item.request || !item.payload || !item.raw || !Number.isFinite(Date.parse(item.started)) || !Number.isFinite(Date.parse(item.finished)) || item.payload.model !== model) { skipped++; continue; }
        const input = buildContent({...item.request, schema: item.payload.format, sourceName: name});
        const hex = createHash('sha256').update(path.resolve(file)).update(item.started).digest('hex');
        const id = item.monitorRecordId || `${hex.slice(0, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${hex.slice(16, 20)}-${hex.slice(20, 32)}`;
        const {result, error} = contentResult(item.raw);
        if (monitor.import({id, input, startedAt: item.started, finishedAt: item.finished, elapsedMs: Math.max(0, Date.parse(item.finished) - Date.parse(item.started)),
          status: error ? 'error' : 'success', result, error, archive: {file: path.resolve(file), sha256: createHash('sha256').update(bytes).digest('hex')}})) imported++;
        else skipped++;
      } catch (error) { errors.push({file, error: error.message}); }
    }
  }
  return {imported, skipped, errors};
}

module.exports = {buildContent, contentPayload, contentResult, importContentArchive};
