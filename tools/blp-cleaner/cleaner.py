# BLP 사용 흔적을 분석하고 검증된 삭제 후보만 새 맵 복사본에서 정리한다.
import argparse
import ctypes as c
import fnmatch
import hashlib
import json
import os
import re
import shutil
import struct
import tempfile
from dataclasses import dataclass, field
from pathlib import Path

from mpq import Archive, MpqError, load_library
from references import (builtin_reason, decode_text, matches_pattern, mdx_textures,
                        normalize, script_patterns, text_views)


INTERNAL = {'(listfile)', '(attributes)', '(signature)'}
MEDIA = {'.blp', '.tga', '.dds', '.png', '.jpg', '.jpeg', '.bmp', '.gif',
         '.wav', '.mp3', '.ogg', '.flac', '.mp4', '.webm', '.ttf', '.otf'}
SCRIPT = {'.j', '.lua', '.fdf', '.toc', '.mdl'}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def file_digest(path):
    with open(path, 'rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def import_entries(data):
    if len(data) < 8:
        raise ValueError('가져오기 목록이 잘렸습니다.')
    version, count = struct.unpack_from('<II', data)
    if version != 1 or count > len(data):
        raise ValueError('지원하지 않는 가져오기 목록입니다.')
    pos, entries = 8, []
    for _ in range(count):
        if pos >= len(data) or data[pos] not in (0, 1, 5, 8, 10, 13):
            raise ValueError('가져오기 경로 형식을 읽을 수 없습니다.')
        end = data.find(b'\0', pos + 1)
        if end < 0:
            raise ValueError('가져오기 파일명 끝을 찾을 수 없습니다.')
        name = data[pos + 1:end].replace(b'/', b'\\')
        if data[pos] in (0, 5, 8):
            name = b'war3mapImported\\' + name
        entries.append((name.lower(), data[pos:end + 1]))
        pos = end + 1
    if pos != len(data):
        raise ValueError('가져오기 목록 뒤에 해석하지 못한 데이터가 있습니다.')
    return entries


def prune_imports(data, removed):
    entries = import_entries(data)
    removed = {name.replace(b'/', b'\\').lower() for name in removed}
    kept = [raw for name, raw in entries if name not in removed]
    return struct.pack('<II', 1, len(kept)) + b''.join(kept)


@dataclass
class Texture:
    name: str
    size: int
    compressed_size: int
    status: str = 'candidate'
    reasons: list = field(default_factory=list)


@dataclass
class Analysis:
    source: Path
    source_hash: str
    source_size: int
    members: list
    hashes: dict
    textures: list
    blockers: list
    keep: list
    prefix: bytes = b''

    def report(self):
        return {'format_version': 1, 'source': str(self.source), 'source_sha256': self.source_hash,
                'source_bytes': self.source_size, 'scanned_members': len(self.members),
                'blockers': self.blockers, 'keep_patterns': self.keep,
                'candidate_count': sum(row.status == 'candidate' for row in self.textures),
                'candidate_compressed_bytes': sum(row.compressed_size for row in self.textures
                                                  if row.status == 'candidate'),
                'textures': [vars(row) for row in self.textures],
                'runtime_tested': False,
                'scope': '정적 참조 검사. 실제 게임에서의 미사용을 증명하지 않습니다.'}


def analyze(source, dll, keep=(), progress=lambda text: None):
    source = Path(source).resolve()
    if source.suffix.lower() not in ('.w3x', '.w3m') or not source.is_file():
        raise ValueError('분석할 .w3x 또는 .w3m 맵 파일을 선택하세요.')
    progress('맵의 원본 해시와 파일 목록을 읽고 있습니다.')
    source_hash = file_digest(source)
    blockers, hashes, textures, patterns = [], {}, [], []
    with Archive(dll, source) as archive:
        members = archive.members()
        if len({member.block_index for member in members}) != archive.info(36):
            blockers.append('파일 목록과 MPQ의 실제 파일 개수가 다릅니다.')
        prefix_size = archive.info(5, c.c_uint64)
        if prefix_size > 16 * 1024 * 1024:
            raise ValueError('지원하지 않는 크기의 맵 헤더입니다.')
        with source.open('rb') as stream:
            prefix = stream.read(prefix_size)
        names = {normalize(member.name): member for member in members}
        if len(names) != len(members):
            blockers.append('중복 경로 또는 여러 언어 버전이 있는 맵입니다.')
        if any(member.locale != 0 for member in members):
            blockers.append('언어별 파일이 있는 맵은 자동 정리하지 않습니다.')
        if '(listfile)' not in names:
            blockers.append('전체 파일 이름을 확인할 (listfile)이 없습니다.')
        if '(signature)' in names or archive.info(27):
            blockers.append('서명된 맵은 자동 정리하지 않습니다.')
        # StormLib SFileMpqFlags = 39. 보호 도구가 변형한 MPQ는 다시 쓰지 않는다.
        if archive.info(39) & 0x1c:
            blockers.append('MPQ 헤더 또는 파일 표에 손상/보호 흔적이 있습니다.')
        if any(re.fullmatch(r'file\d{8}\.[^\\]+', normalize(member.name)) for member in members):
            blockers.append('이름을 복원하지 못한 파일이 있습니다.')
        entry_scripts = [n for n in names if n in ('war3map.j', 'scripts\\war3map.j',
                                                   'war3map.lua', 'scripts\\war3map.lua')]
        if not entry_scripts:
            blockers.append('실행 스크립트를 찾을 수 없습니다.')
        for member in members:
            if normalize(member.name).endswith('.blp'):
                textures.append(Texture(member.name, member.size, member.compressed_size))
        # 확장자 없는 아이콘, .tga 대체 경로, 같은 이름의 다른 폴더도 보수적으로 보존한다.
        aliases = {}
        for row in textures:
            base = normalize(row.name).rsplit('\\', 1)[-1]
            aliases[row.name] = base[:-4]
            reason = builtin_reason(row.name)
            if reason:
                row.status, row.reasons = 'unknown', [reason]
            if any(fnmatch.fnmatchcase(normalize(row.name), normalize(glob)) for glob in keep):
                row.status, row.reasons = 'keep', ['사용자 보존 패턴']
        for index, member in enumerate(members):
            name = normalize(member.name)
            progress(f'파일 검사 {index + 1}/{len(members)}. {member.name}')
            try:
                data = archive.read(member)
                hashes[(member.raw_name, member.locale)] = digest(data)
            except (MpqError, OSError) as exc:
                blockers.append(str(exc))
                continue
            if name == 'war3map.imp':
                try:
                    import_entries(data)
                except ValueError as exc:
                    blockers.append(str(exc))
                continue  # 가져오기 등록 자체는 사용 근거가 아니다.
            if name in INTERNAL:
                continue
            suffix = Path(name).suffix
            if suffix in ('.jc', '.luac', '.dll', '.exe') or data.startswith((b'\x1bLua', b'\x1bLJ', b'MZ')):
                blockers.append('실행 내용을 검사할 수 없는 파일. ' + member.name)
            if suffix == '.mdx' or data.startswith(b'MDLX'):
                try:
                    mdx_textures(data)
                except ValueError as exc:
                    blockers.append(member.name + '. ' + str(exc))
            elif suffix in SCRIPT:
                try:
                    source_text = decode_text(data)
                    if suffix == '.mdl' and not re.search(r'\bModel\s+"', source_text):
                        raise ValueError('MDL 모델 구조를 확인할 수 없음')
                    if suffix in ('.j', '.lua'):
                        if re.search(r'//!\s*import\b', source_text):
                            raise ValueError('외부 파일 import가 남아 있는 스크립트')
                        if name in entry_scripts and not re.search(r'\bfunction\s+main\b', source_text):
                            raise ValueError('실행 스크립트 main 함수 없음')
                        # Lua의 다중 대입/테이블 변경은 현재 분석 범위 밖이다.
                        found, unresolved = script_patterns(source_text, allow_assignments=suffix == '.j')
                        patterns.extend((pattern, member.name) for pattern in found)
                        if unresolved:
                            blockers.append(member.name + '. 미해결 동적 참조. ' + ', '.join(unresolved))
                except ValueError as exc:
                    blockers.append(member.name + '. ' + str(exc))
            if suffix == '.blp' and not data.startswith((b'BLP1', b'BLP2')):
                for row in textures:
                    if row.name == member.name and row.status != 'keep':
                        row.status, row.reasons = 'unknown', ['BLP 파일 헤더를 확인할 수 없음']
            if suffix in MEDIA and not data.startswith(b'MDLX'):
                continue
            views = text_views(data)
            for row in textures:
                if len(row.reasons) >= 6 and row.status == 'used':
                    continue
                if any(aliases[row.name] in view for view in views):
                    if row.status != 'keep':
                        row.status = 'used'
                    row.reasons.append('문자열 참조. ' + member.name)
        for row in textures:
            for pattern, member_name in patterns:
                if matches_pattern(row.name, pattern):
                    if row.status != 'keep':
                        row.status = 'used'
                    if len(row.reasons) < 6:
                        row.reasons.append('경로/동적 패턴 참조. ' + member_name + ' → ' + pattern)
            if row.status == 'candidate':
                if blockers:
                    row.status, row.reasons = 'unknown', ['맵 전체 검사 미완료. 상단 보존 사유 참조']
                else:
                    row.reasons = ['검사한 파일에서 직접/간접 사용 흔적을 찾지 못함']
    if file_digest(source) != source_hash:
        raise ValueError('분석 중 원본 맵이 변경되었습니다. 다시 분석하세요.')
    return Analysis(source, source_hash, source.stat().st_size, members, hashes,
                    sorted(textures, key=lambda row: (row.status, normalize(row.name))),
                    sorted(set(blockers)), list(keep), prefix)


def clean(analysis, selected, output, dll, progress=lambda text: None):
    selected = set(selected)
    candidates = {row.name for row in analysis.textures if row.status == 'candidate'}
    if analysis.blockers:
        raise ValueError('검사하지 못한 참조가 있어 자동 정리를 중단했습니다.')
    if not selected or not selected <= candidates:
        raise ValueError('삭제 후보에서 하나 이상의 BLP를 선택하세요.')
    output = Path(output).resolve()
    if output == analysis.source or output.exists():
        raise ValueError('원본과 기존 파일은 덮어쓰지 않습니다. 새 출력 경로를 선택하세요.')
    if output.suffix.lower() != analysis.source.suffix.lower():
        raise ValueError('출력 맵의 확장자는 원본과 같아야 합니다.')
    if not output.parent.is_dir():
        raise ValueError('출력 폴더가 없습니다.')
    if file_digest(analysis.source) != analysis.source_hash:
        raise ValueError('분석 뒤 원본 맵이 변경되었습니다. 다시 분석하세요.')
    removed = [member for member in analysis.members if member.name in selected]
    expected = {key: value for key, value in analysis.hashes.items()
                if key not in {(member.raw_name, member.locale) for member in removed}}
    expected = {key: value for key, value in expected.items()
                if key[0].decode('ascii', errors='replace').lower() not in INTERNAL}
    # 임시 폴더에서 삭제/재압축/검증을 완료한 뒤 새 이름으로만 게시한다.
    with tempfile.TemporaryDirectory(prefix='blp-cleaner-', dir=output.parent) as work:
        staging = Path(work) / output.name
        progress('원본을 복사하고 선택한 BLP를 정리하고 있습니다.')
        shutil.copyfile(analysis.source, staging)
        if file_digest(staging) != analysis.source_hash:
            raise ValueError('복사 중 원본 맵이 변경되었습니다.')
        with Archive(dll, staging, write=True) as archive:
            import_member = next((m for m in analysis.members if normalize(m.name) == 'war3map.imp'), None)
            if import_member:
                imports = prune_imports(archive.read(import_member), [m.raw_name for m in removed])
                archive.put(import_member.raw_name, imports)
                expected[(import_member.raw_name, 0)] = digest(imports)
            for member in removed:
                archive.remove(member)
            archive.compact()
        progress('남은 파일의 해시와 삭제 결과를 검증하고 있습니다.')
        with Archive(dll, staging) as archive:
            if archive.info(5, c.c_uint64) != len(analysis.prefix):
                raise ValueError('맵 헤더 위치가 변경되었습니다. 출력하지 않습니다.')
            actual_members = [m for m in archive.members() if normalize(m.name) not in INTERNAL]
            actual = {(m.raw_name, m.locale) for m in actual_members}
            if actual != set(expected):
                raise ValueError('정리 후 파일 목록이 예상과 다릅니다. 출력하지 않습니다.')
            for member in actual_members:
                if digest(archive.read(member)) != expected[(member.raw_name, member.locale)]:
                    raise ValueError('보존 파일의 내용이 변경되었습니다. ' + member.name)
            for member in removed:
                if archive.exists(member.raw_name):
                    raise ValueError('삭제한 BLP가 맵에 남아 있습니다. ' + member.name)
        with staging.open('rb') as stream:
            if stream.read(len(analysis.prefix)) != analysis.prefix:
                raise ValueError('맵 헤더가 변경되었습니다. 출력하지 않습니다.')
        if file_digest(analysis.source) != analysis.source_hash:
            raise ValueError('작업 중 원본 맵이 변경되었습니다. 출력하지 않습니다.')
        output_hash = file_digest(staging)
        output_size = staging.stat().st_size
        # Windows rename은 목적지가 이미 있으면 실패한다. 경쟁 상황에서도 덮어쓰지 않는다.
        if os.name != 'nt':
            raise ValueError('검증된 맵 게시 기능은 Windows에서 지원합니다.')
        os.rename(staging, output)
    return {'output': str(output), 'output_sha256': output_hash,
            'output_bytes': output_size, 'saved_bytes': analysis.source_size - output_size,
            'removed': sorted(selected), 'verified_retained_members': len(expected),
            'source_unchanged': True, 'runtime_tested': False}


def write_report(path, report):
    # 보고서 경로 실수로 원본/기존 파일을 덮어쓰지 않는다.
    with open(path, 'x', encoding='utf-8') as stream:
        json.dump(report, stream, ensure_ascii=False, indent=2)
        stream.write('\n')


def main():
    parser = argparse.ArgumentParser(description='Warcraft III BLP 정적 참조 분석 및 복사본 정리')
    parser.add_argument('map', type=Path)
    parser.add_argument('--stormlib', type=Path)
    parser.add_argument('--report', type=Path, required=True)
    parser.add_argument('--keep', action='append', default=[], help='보존할 맵 내부 경로 패턴')
    parser.add_argument('--output', type=Path, help='지정하면 모든 삭제 후보를 새 맵에서 제거')
    args = parser.parse_args()
    if args.report.exists() or (args.output and args.report.resolve() == args.output.resolve()):
        parser.error('보고서는 원본/출력 맵과 다른 새 경로를 지정하세요.')
    try:
        dll = load_library(args.stormlib)
        analysis = analyze(args.map, dll, args.keep)
        report = analysis.report()
        if args.output:
            report['cleanup'] = clean(analysis, [r.name for r in analysis.textures if r.status == 'candidate'],
                                      args.output, dll)
        write_report(args.report, report)
        print(json.dumps({'report': str(args.report), 'candidates': report['candidate_count'],
                          'blocked': bool(analysis.blockers)}, ensure_ascii=False))
    except (OSError, ValueError, MpqError) as exc:
        # 창 모드 EXE의 CLI에서도 오류 사유를 읽을 수 있도록 새 보고서에 남긴다.
        try:
            if not args.report.exists():
                write_report(args.report, {'error': str(exc), 'runtime_tested': False})
        except OSError:
            pass
        parser.exit(1, str(exc) + '\n')


if __name__ == '__main__':
    main()
