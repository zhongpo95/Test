# 텍스처 참조와 동적 경로를 보수적으로 찾아 삭제에서 제외한다.
import re
import struct
from collections import Counter


BUILTIN_ROOTS = ('textures', 'replaceabletextures', 'units', 'abilities', 'doodads',
                 'terrainart', 'splats', 'ui', 'environment', 'objects', 'buildings',
                 'destructables', 'fonts')
SINKS = {'DzFrameSetTexture': 1, 'JNFrameSetTexture': 1, 'BlzFrameSetTexture': 1,
         'BlzSetAbilityIcon': 1, 'BlzSetItemIconPath': 1, 'CreateImage': 0,
         'SetCineFilterTexture': 0, 'Preload': 0, 'MultiboardSetItemIcon': 1,
         'MultiboardSetItemsIcon': 1, 'BlzSetItemStringField': 2, 'BlzSetUnitStringField': 2,
         'BlzSetAbilityStringField': 2, 'BlzSetAbilityStringLevelField': 3,
         'BlzSetAbilityStringLevelArrayField': 4, 'BlzAddAbilityStringLevelArrayField': 3}
TOKEN = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|'
                   r'\[\[.*?\]\]|[A-Za-z_]\w*|\d+(?:\.\d+)?|\.\.|[^\s]', re.S)
COMMENTS = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|'
                      r'\[\[.*?\]\]|//[^\n]*|--\[\[.*?\]\]|--[^\n]*|/\*.*?\*/', re.S)


def normalize(path):
    return re.sub(r'\\+', lambda _: '\\', path.replace('/', '\\')).lower()


def builtin_reason(name):
    name = normalize(name)
    base = name.rsplit('\\', 1)[-1]
    if name.split('\\')[0] in BUILTIN_ROOTS:
        return '기본 게임 리소스를 교체할 수 있는 경로'
    if base in ('war3mappreview.blp', 'war3mapmap.blp'):
        return '엔진이 자동으로 불러오는 맵 이미지'
    if base.startswith(('disbtn', 'dispas')):
        return '비활성 아이콘의 자동 참조 가능성'
    return None


def text_views(data):
    # 바이너리 오브젝트에도 문자열이 들어간다. 손실 디코딩은 검색에만 사용한다.
    encodings = ['utf-8', 'cp949', 'gb18030']
    views = [normalize(data.decode(enc, errors='replace')) for enc in encodings]
    if b'\0' in data:
        # 바이너리 필드의 UTF-16 문자열은 홀수 오프셋에서도 시작할 수 있다.
        views.extend(normalize(data[offset:].decode(enc, errors='replace'))
                     for enc in ('utf-16-le', 'utf-16-be') for offset in (0, 1))
    return list(dict.fromkeys(views))


def decode_text(data):
    if b'\0' in data or data.startswith((b'\x1bLua', b'\x1bLJ')):
        raise ValueError('텍스트가 아닌 스크립트 또는 모델')
    for enc in ('utf-8-sig', 'cp949', 'gb18030'):
        try:
            return data.decode(enc)
        except UnicodeDecodeError:
            pass
    raise ValueError('지원하지 않는 문자 인코딩')


def mdx_textures(data):
    if data[:4] != b'MDLX':
        raise ValueError('MDX 헤더를 읽을 수 없음')
    pos, result, has_version = 4, [], False
    while pos < len(data):
        if pos + 8 > len(data):
            raise ValueError('잘린 MDX 청크')
        tag, size = struct.unpack_from('<4sI', data, pos)
        start, end = pos + 8, pos + 8 + size
        if end > len(data):
            raise ValueError('MDX 청크 크기 오류')
        if tag == b'VERS':
            if size != 4 or struct.unpack_from('<I', data, start)[0] not in (800, 900, 1000, 1100):
                raise ValueError('지원하지 않는 MDX 버전')
            has_version = True
        if tag == b'TEXS':
            if size % 268:
                raise ValueError('MDX 텍스처 표 크기 오류')
            for offset in range(start, end, 268):
                path = data[offset + 4:offset + 264]
                if b'\0' not in path:
                    raise ValueError('MDX 텍스처 경로 끝을 찾을 수 없음')
                result.append(path.split(b'\0', 1)[0])
        pos = end
    if not has_version:
        raise ValueError('MDX 버전 청크 없음')
    return result


def split_top(tokens, separators):
    result, current, depth = [], [], 0
    for token in tokens:
        if token in ('(', '['):
            depth += 1
        elif token in (')', ']'):
            depth -= 1
        if token in separators and depth == 0:
            result.append(current)
            current = []
        else:
            current.append(token)
    result.append(current)
    return result


def call_arguments(tokens, start):
    depth = 0
    for end in range(start, len(tokens)):
        if tokens[end] == '(':
            depth += 1
        elif tokens[end] == ')':
            depth -= 1
            if depth == 0:
                return split_top(tokens[start + 1:end], {','}), end
    raise ValueError('닫히지 않은 함수 호출')


def unquote(token):
    if token.startswith('[[') and token.endswith(']]'):
        return token[2:-2]
    if len(token) < 2 or token[0] not in ('"', "'") or token[-1] != token[0]:
        return None
    inner = token[1:-1]
    result, pos = [], 0
    while pos < len(inner):
        char = inner[pos]
        if char == '\\':
            pos += 1
            if pos >= len(inner) or inner[pos] not in '\\"\'nrt':
                return None  # 숫자/16진 이스케이프는 추측하지 않는다.
            char = {'n': '\n', 'r': '\r', 't': '\t'}.get(inner[pos], inner[pos])
        result.append(char)
        pos += 1
    return ''.join(result)


def script_patterns(source, allow_assignments=True):
    """해결한 경로 패턴과 해결하지 못한 호출 목록을 반환한다.

    단순 대입/배열의 모든 대입 값을 합집합으로 추적한다. 함수 인자, 사용자
    함수 반환값, 복잡한 식은 안전하다고 추측하지 않고 미해결로 남긴다.
    """
    source = COMMENTS.sub(lambda m: '\n' * m[0].count('\n')
                          if m[0].startswith(('//', '--', '/*')) else m[0], source)
    assignments, parameters = {}, set()
    for match in re.finditer(r'\bfunction\s+\w+\s+takes\s+(.*?)\s+returns\b', source):
        parameters.update(re.findall(r'\bstring\s+(\w+)', match[1]))
    for match in re.finditer(r'\bfunction\s+[\w.:]*\s*\(([^)]*)\)', source):
        parameters.update(re.findall(r'\b[A-Za-z_]\w*\b', match[1]))
    for line in source.splitlines():
        match = re.match(r'\s*(?:(?:set|local|string|constant)\s+)*'
                         r'(\w+)(?:\s*\[[^\]]*\])?\s*=\s*(?!=)(.+?)\s*;?\s*$', line)
        if match:
            assignments.setdefault(match[1], []).append(TOKEN.findall(match[2].rstrip(';')))
    # 같은 변수에 대한 다른 형태의 대입을 누락한 경우 상수라고 단정하지 않는다.
    writes = Counter(re.findall(r'\b(\w+)(?:\s*\[[^\]]*\])?\s*=(?!=)', source))
    uncertain_assignments = {name for name, values in assignments.items() if writes[name] != len(values)}

    def evaluate(tokens, seen=frozenset()):
        if not tokens or len(seen) > 24:
            return None
        if tokens[0] == '(':
            try:
                _, end = call_arguments(tokens, 0)
            except ValueError:
                return None
            if end == len(tokens) - 1:
                return evaluate(tokens[1:-1], seen)
        pieces = split_top(tokens, {'+', '..'})
        if len(pieces) > 1:
            result = {''}
            for piece in pieces:
                values = evaluate(piece, seen)
                if values is None or len(result) * len(values) > 256:
                    return None
                result = {left + right for left in result for right in values}
            return result
        if len(tokens) == 1:
            literal = unquote(tokens[0])
            if literal is not None:
                return {literal}
            if tokens[0] in ('null', 'nil'):
                return {''}
        if len(tokens) >= 3 and tokens[1] == '(' and tokens[-1] == ')':
            if tokens[0] in ('I2S', 'R2S', 'R2SW', 'tostring'):
                return {'*'}
            return None
        name = tokens[0]
        if len(tokens) != 1 and not (len(tokens) >= 4 and tokens[1] == '[' and tokens[-1] == ']'):
            return None
        if not allow_assignments or name in parameters or name in uncertain_assignments or name in seen or name not in assignments:
            return None
        result = set()
        for expression in assignments[name]:
            values = evaluate(expression, seen | {name})
            if values is None:
                return None
            result.update(values)
            if len(result) > 256:
                return None
        return result

    tokens = TOKEN.findall(source)
    patterns, unresolved = set(), []
    for index, token in enumerate(tokens[:-1]):
        if tokens[index + 1] != '(':
            continue
        arg_index = SINKS.get(token)
        # 추가 플러그인의 텍스처 함수도 미해결로 보존한다.
        texture_name = re.search(r'(?:Set.*Texture|Set.*Icon|Set.*Ability.*String)', token, re.I)
        if arg_index is None:
            if texture_name:
                unresolved.append(token)
            continue
        try:
            args, _ = call_arguments(tokens, index + 1)
            values = evaluate(args[arg_index]) if arg_index < len(args) else None
        except ValueError:
            values = None
        if values is None or any(value and not normalize(value).replace('*', '') for value in values):
            unresolved.append(token)
        else:
            patterns.update(normalize(value) for value in values if value)
    # 외부 소스/바이트코드 실행은 정적 경로 목록만으로 검증할 수 없다.
    if re.search(r'\b(?:loadstring|loadfile|dofile|require|load)\s*\(', source):
        unresolved.append('외부 또는 동적 스크립트 실행')
    for sink in SINKS:
        if re.search(r'=\s*' + re.escape(sink) + r'\b', source):
            unresolved.append('함수 별칭. ' + sink)
    return patterns, sorted(set(unresolved))


def matches_pattern(name, pattern):
    name, pattern = normalize(name), normalize(pattern)
    # 확장자를 생략하거나 .tga를 지정한 엔진 경로도 BLP 대체 가능성을 보존한다.
    aliases = {name, name[:-4], name[:-4] + '.tga'}
    expression = re.escape(pattern).replace(r'\*', '.*')
    return any(re.fullmatch(expression, alias) for alias in aliases)
