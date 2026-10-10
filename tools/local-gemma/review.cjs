// Codex나 터미널에서 로컬 Gemma에 텍스트와 이미지 초안 검토를 요청한다.
const fs = require('node:fs');
const path = require('node:path');

async function main() {
  if (process.argv.length !== 3) throw new Error('사용법. node tools/local-gemma/review.cjs 검토요청.json');
  const input = JSON.parse(fs.readFileSync(process.argv[2], 'utf8').replace(/^\uFEFF/, ''));
  const images = [...(input.images || [])];
  if (input.imagePaths !== undefined) {
    if (!Array.isArray(input.imagePaths) || input.imagePaths.length > 3) throw new Error('imagePaths는 이미지 경로 최대 3개의 배열이어야 합니다.');
    for (const imagePath of input.imagePaths) {
      if (typeof imagePath !== 'string') throw new Error('이미지 경로는 문자열이어야 합니다.');
      const resolved = path.resolve(path.dirname(path.resolve(process.argv[2])), imagePath);
      const ext = path.extname(resolved).toLowerCase();
      if (!['.png', '.jpg', '.jpeg'].includes(ext) || fs.statSync(resolved).size > 4 * 1024 * 1024) throw new Error('PNG·JPEG 이미지이며 파일당 4MB 이내여야 합니다.');
      images.push({name: path.basename(resolved), data: `data:image/${ext === '.png' ? 'png' : 'jpeg'};base64,${fs.readFileSync(resolved).toString('base64')}`});
    }
  }
  const base = 'http://127.0.0.1:18765';
  const page = await (await fetch(base, {signal: AbortSignal.timeout(5000)})).text();
  const token = page.match(/const token = '([a-f0-9]+)'/)?.[1];
  if (!token) throw new Error('작업 화면을 확인할 수 없습니다. 시작.cmd를 실행해 주세요.');
  const reply = await fetch(base + '/api/run', {method: 'POST', headers: {'Content-Type': 'application/json', 'X-Session-Token': token}, body: JSON.stringify({...input, images, mode: 'review'}), signal: AbortSignal.timeout(310000)});
  const data = await reply.json();
  if (!reply.ok) throw new Error(data.error || '검토 요청 실패.');
  console.log(JSON.stringify({...data, history: [...(input.history || []), {role: 'user', content: input.text.trim(), ...(images.length ? {images} : {})}, {role: 'assistant', content: data.text}]}, null, 2));
}
main().catch(error => { console.error(error.message === 'fetch failed' ? '로컬 도구에 연결할 수 없습니다. 시작.cmd를 실행해 주세요.' : error.message); process.exitCode = 1; });
