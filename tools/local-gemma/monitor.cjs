// 로컬 Gemma 요청의 진행 상태와 제한된 처리 기록을 PC에 보관한다.
const fs = require('node:fs');
const path = require('node:path');
const {randomUUID} = require('node:crypto');

const MAX_RECORDS = 100;
const MAX_BYTES = 128 * 1024 * 1024;
const recordName = /^[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}\.json$/;
const inputKeys = ['mode', 'kind', 'language', 'world', 'brief', 'draft', 'text', 'glossary', 'history', 'images'];

function snapshot(input) {
  const keys = input.mode === 'content' ? ['mode', 'text', 'system', 'brief', 'schema', 'review'] : input.mode === 'review' ? inputKeys : input.mode === 'translate' ? ['mode', 'language', 'text', 'glossary'] : input.mode === 'story' ? ['mode', 'world', 'text', 'glossary'] : ['mode'];
  const clean = Object.fromEntries(keys.filter(key => input[key] !== undefined).map(key => [key, input[key]]));
  const images = items => (items || []).map(({name, data}) => ({name, data}));
  if (clean.images) clean.images = images(clean.images);
  if (clean.history) clean.history = clean.history.map(({role, content, images: attached}) => ({role, content, ...(attached ? {images: images(attached)} : {})}));
  return clean;
}

function summary(record, bytes = 0) {
  const input = record.input;
  return {id: record.id, startedAt: record.startedAt, finishedAt: record.finishedAt, status: record.status, mode: input.mode, kind: input.kind,
    preview: (input.mode === 'content' ? input.text : input.brief || input.text || 'GPU 메모리 해제').slice(0, 120), contentReview: input.review, archived: !!record.archive, imageCount: (input.images?.length || 0) + (input.history || []).reduce((count, turn) => count + (turn.images?.length || 0), 0),
    round: input.mode === 'review' ? (input.history?.length || 0) / 2 + 1 : undefined, elapsedMs: record.elapsedMs,
    seconds: record.result?.seconds, tokensPerSecond: record.result?.tokensPerSecond, error: record.error, bytes};
}

function createMonitor(directory, {maxRecords = MAX_RECORDS, maxBytes = MAX_BYTES, recoverInterrupted = true} = {}) {
  const entries = new Map();
  let storageError;
  const failed = error => { storageError = `자동 기록 저장·읽기 실패. ${error.message}`; };
  const filename = id => path.join(directory, `${id}.json`);
  function write(record) {
    if (!directory) return;
    try {
      const data = JSON.stringify(record);
      const target = filename(record.id);
      fs.writeFileSync(target + '.tmp', data, 'utf8');
      fs.renameSync(target + '.tmp', target);
      entries.set(record.id, summary(record, Buffer.byteLength(data)));
    } catch (error) {
      failed(error);
      try { fs.unlinkSync(filename(record.id) + '.tmp'); } catch {}
    }
  }
  function prune() {
    let total = [...entries.values()].reduce((size, item) => size + item.bytes, 0);
    for (const item of [...entries.values()].sort((a, b) => a.startedAt.localeCompare(b.startedAt))) {
      if (entries.size <= maxRecords && total <= maxBytes) break;
      if (item.status === 'running') continue;
      try { fs.unlinkSync(filename(item.id)); entries.delete(item.id); total -= item.bytes; }
      catch (error) { failed(error); break; }
    }
  }
  if (directory) {
    try {
      fs.mkdirSync(directory, {recursive: true});
      for (const name of fs.readdirSync(directory).filter(name => recordName.test(name))) {
        try {
          const file = path.join(directory, name);
          const record = JSON.parse(fs.readFileSync(file, 'utf8'));
          if (`${record.id}.json` !== name || !record.input || typeof record.startedAt !== 'string') throw new Error(`기록 형식 오류 (${name}).`);
          entries.set(record.id, summary(record, fs.statSync(file).size));
          if (record.status === 'running' && recoverInterrupted) {
            record.status = 'interrupted'; record.finishedAt = new Date().toISOString();
            record.elapsedMs = Date.parse(record.finishedAt) - Date.parse(record.startedAt);
            record.error = '서버가 종료되어 완료 여부를 확인할 수 없습니다.';
            write(record);
          }
        } catch (error) { failed(error); }
      }
      prune();
    } catch (error) { failed(error); }
  }
  let active;
  return {
    begin(input) {
      active = {id: randomUUID(), startedAt: new Date().toISOString(), status: 'running', input: snapshot(input)};
      write(active);
      return active;
    },
    finish(record, status, result, error) {
      Object.assign(record, {status, finishedAt: new Date().toISOString(), elapsedMs: Date.now() - Date.parse(record.startedAt), result, error});
      write(record); prune();
      active = undefined;
    },
    list() {
      return {active: active ? {...summary(active), elapsedMs: Date.now() - Date.parse(active.startedAt)} : null,
        records: [...entries.values()].reverse().sort((a, b) => b.startedAt.localeCompare(a.startedAt)),
        storage: {enabled: !!directory, directory, error: storageError, maxRecords, maxBytes}};
    },
    read(id) {
      if (!recordName.test(`${id}.json`) || !entries.has(id)) return null;
      try { return JSON.parse(fs.readFileSync(filename(id), 'utf8')); }
      catch (error) { failed(error); throw new Error('기록을 읽을 수 없습니다. 저장 폴더를 확인해 주세요.'); }
    },
    import(record) {
      if (!recordName.test(`${record.id}.json`)) throw new Error('기록 ID 형식이 잘못됐습니다.');
      if (entries.has(record.id)) return false;
      if (!directory) throw new Error('자동 기록 저장 폴더가 없습니다.');
      write(record);
      if (!entries.has(record.id)) throw new Error(storageError);
      prune();
      return true;
    }
  };
}

module.exports = {createMonitor};
