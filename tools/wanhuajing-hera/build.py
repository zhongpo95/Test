# 만화경 원본의 MPQ 해시를 보존하고 보호 리소스 및 헤라 호환 스크립트를 새 맵에 포장한다.
import argparse
import ctypes as c
import hashlib
import io
import json
from pathlib import Path
import re
import struct
import zlib

SOURCE_SHA256 = '901c31b06081e784490cdf0a99bde3680d60c6028a433a6ef57f20a0e9ec71d3'
ASSET_KEY = bytes.fromhex('a1fdf7ecdab2cc384336824cf15e6d12')
TABLE = [0] * 1280
seed = 0x100001
for i in range(256):
    for j in range(5):
        seed = (seed * 125 + 3) % 0x2aaaab
        high = (seed & 65535) << 16
        seed = (seed * 125 + 3) % 0x2aaaab
        TABLE[i + j * 256] = high | (seed & 65535)


def file_hash(path):
    with Path(path).open('rb') as f:
        return hashlib.file_digest(f, 'sha256').hexdigest()


def name_hash(name, kind):
    a, b = 0x7fed7fed, 0xeeeeeeee
    for v in name.replace('/', '\\').encode('utf8').upper():
        a = TABLE[kind * 256 + v] ^ ((a + b) & 0xffffffff)
        b = (v + a + b + (b << 5) + 3) & 0xffffffff
    return a


def crypt(data, key, encrypt=False):
    out = bytearray()
    seed = 0xeeeeeeee
    for (word,) in struct.iter_unpack('<I', data):
        seed = (seed + TABLE[0x400 + (key & 255)]) & 0xffffffff
        value = word ^ ((key + seed) & 0xffffffff)
        out += struct.pack('<I', value)
        plain = word if encrypt else value
        key = ((((~key & 0xffffffff) << 21) + 0x11111111) | (key >> 11)) & 0xffffffff
        seed = (plain + seed + (seed << 5) + 3) & 0xffffffff
    return out


def restore_asset(data):
    if data[:4] not in (bytes.fromhex('e3b1a7dd'), bytes.fromhex('ecb9bbb4')):
        return data, None
    out = bytearray(len(data))
    for i, key in enumerate(ASSET_KEY):
        translation = bytes(v ^ key for v in range(256))
        out[i::16] = data[i::16].translate(translation)
    data = bytes(out)
    if data.startswith(b'MDLX'):
        offset = 4
        while offset < len(data):
            assert offset + 8 <= len(data), 'Truncated MDX chunk'
            tag, size = struct.unpack_from('<4sI', data, offset)
            assert all(32 <= v < 127 for v in tag), 'Invalid MDX tag'
            offset += 8 + size
        assert offset == len(data), 'Invalid MDX chunk boundary'
        return data, 'MDX'
    assert data.startswith(b'BLP1') and len(data) >= 156, 'Invalid BLP header'
    compression, flags, width, height = struct.unpack_from('<4I', data, 4)
    assert compression in (0, 1) and 0 < width <= 16384 and 0 < height <= 16384
    offsets = struct.unpack_from('<16I', data, 28)
    sizes = struct.unpack_from('<16I', data, 92)
    for offset, size in zip(offsets, sizes):
        assert not size or (offset >= 156 and offset + size <= len(data)), 'Invalid BLP mipmap'
    return data, 'BLP'


class Archive:
    def __init__(self, path, dll_path):
        self.dll = c.WinDLL(str(dll_path), use_last_error=True)
        h, u = c.c_void_p, c.c_uint32
        for name, args, result in [
            ('SFileOpenArchive', [c.c_wchar_p, u, u, c.POINTER(h)], c.c_bool),
            ('SFileOpenFileEx', [h, c.c_char_p, u, c.POINTER(h)], c.c_bool),
            ('SFileGetFileSize', [h, c.POINTER(u)], u),
            ('SFileReadFile', [h, h, u, c.POINTER(u), h], c.c_bool),
            ('SFileCloseFile', [h], c.c_bool), ('SFileCloseArchive', [h], c.c_bool),
            ('SFileHasFile', [h, c.c_char_p], c.c_bool),
        ]:
            fn = getattr(self.dll, name)
            fn.argtypes, fn.restype = args, result
        self.handle = h()
        assert self.dll.SFileOpenArchive(str(path), 0, 0x100, c.byref(self.handle)), c.get_last_error()

    def exists(self, name):
        return self.dll.SFileHasFile(self.handle, name.encode('utf8'))

    def read(self, name):
        handle = c.c_void_p()
        assert self.dll.SFileOpenFileEx(self.handle, name.encode('utf8'), 0, c.byref(handle)), (name, c.get_last_error())
        try:
            size = self.dll.SFileGetFileSize(handle, None)
            assert size < 128 * 1024 * 1024
            data, read = c.create_string_buffer(size), c.c_uint32()
            assert self.dll.SFileReadFile(handle, data, size, c.byref(read), None), (name, c.get_last_error())
            assert read.value == size
            return data.raw
        finally:
            self.dll.SFileCloseFile(handle)

    def close(self):
        self.dll.SFileCloseArchive(self.handle)


def modules(source):
    start = source.index('var_4 ={') + len('var_4 ={')
    depth, module_start = 0, None
    spans = []
    token = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|\b[A-Za-z_][A-Za-z_0-9]*\b|[^\s]')
    for match in token.finditer(source, start):
        word = match[0]
        if depth == 0 and word == 'function':
            module_start = match.start()
        if word in ('function', 'if', 'do', 'repeat'):
            depth += 1
        elif word in ('end', 'until'):
            depth -= 1
            if depth == 0:
                spans.append((module_start, match.end()))
        elif depth == 0 and word == '}':
            break
    assert len(spans) > 1400
    return spans


def prepare_bundle(data, output):
    source = data.decode('utf8')
    alphabet = list(map(int, re.findall(r'\d+', re.match(r'local var_0\s*=\s*\{([^}]+)\}', source)[1])))
    assert len(set(alphabet)) == 256
    table_end = source.index(' local var_3')
    strings = [bytes(alphabet[int(i)] for i in re.findall(r'\d+', m[1]))
               for m in re.finditer(r'var_1\s*\(\s*\{([\d\s,]*)\}\s*\)', source[:table_end])]
    globals_end = source.index(' local var_4', table_end)
    names = [bytes(alphabet[int(i)] for i in re.findall(r'\d+', m[1])).decode('utf8')
             for m in re.finditer(r'var_1\s*\(\s*\{([\d\s,]*)\}\s*\)', source[table_end:globals_end])]
    assert len(names) == 3315
    spans = modules(source)
    replacements = {
        34: "function () return require('hera_wanhua').library end",
        89: "function () return require('hera_wanhua').model_info(var_6(350)) end",
        1014: 'function () var_6(1131) var_6(392) end',
        1022: "function () require('hera_wanhua').note('JN retains ownership of external archives') end",
        1067: "function () require('hera_wanhua').platform() end",
        708: "function () require('hera_wanhua').plugins() var_6(1391)(require('hera_wanhua').env.Plugins) end",
        281: "function () return require('hera_wanhua').window() end",
        1030: "function () local m=require('hera_wanhua') return require('hera_session')(m.env,m.note) end",
        426: "function () local m=require('hera_wanhua') require('hera_effects')(m.env,m.note) end",
        202: "function () return require('hera_wanhua').scenery() end",
    }
    a, b = spans[1271 - 1]
    chat, count = re.subn(r'local var_64257 =.*?var_64252 \. register_event',
                         "require('hera_wanhua').chat_input() var_64252 . register_event", source[a:b], flags=re.S)
    assert count == 1, 'Chat input patch no longer matches'
    replacements[1271] = chat
    a, b = spans[838 - 1]
    skill, count = re.subn(r'if var_27600 \. item then\s*return var_27552 \. GetItemAbility \( var_27600 \. item \. handle , 0 \) end',
                          '', source[a:b])
    assert count == 1, 'Legacy item ability path patch no longer matches'
    skill, count = re.subn(r'local var_27574 =.*?local var_27575 =',
                          "local var_27574 = require('hera_wanhua').ability_template local var_27575 =",skill,flags=re.S)
    assert count == 1, 'Ability template patch no longer matches'
    replacements[838] = skill
    for index in sorted(replacements, reverse=True):
        a, b = spans[index - 1]
        source = source[:a] + replacements[index] + source[b:]
    index_lua = '{' + ','.join('[' + json.dumps(n, ensure_ascii=False) + ']=' + str(i)
                             for i, n in enumerate(names, 1)) + '}'
    source = source[:globals_end] + " require('hera_wanhua').attach(var_3," + index_lua + ') ' + source[globals_end:]
    # 매 모듈 진입을 기록해 JASS의 중첩 xpcall도 오류를 숨기지 못하게 한다.
    source = source.replace('local var_11 = var_4 [ var_10 ]()',
                            "require('hera_wanhua').enter(var_10) local var_11 = var_4 [ var_10 ]()")
    # 생성된 호환 스크립트의 오류 위치를 한 줄짜리 번들에서 구별할 수 있게 한다.
    body_start = source.index('var_4 ={')
    source = source[:body_start] + re.sub(
        r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|\b(?:function|end|then|do)\b',
        lambda m: m[0] + ('\n' if m[0] in ('function', 'end', 'then', 'do') else ''), source[body_start:])
    output.mkdir(parents=True, exist_ok=True)
    (output / 'run.lua').write_text(source, encoding='utf8')
    (output / 'bundle-summary.json').write_text(json.dumps({'modules':len(spans), 'strings':len(strings), 'globals':len(names)}, indent=2))
    return source.encode('utf8'), strings


def compress(data, sector_size):
    if not data:
        return data, 0x80000000
    pieces = []
    for offset in range(0, len(data), sector_size):
        raw = data[offset:offset + sector_size]
        packed = b'\x02' + zlib.compress(raw, 6)
        pieces.append(packed if len(packed) < len(raw) else raw)
    offsets = [4 * (len(pieces) + 1)]
    for piece in pieces:
        offsets.append(offsets[-1] + len(piece))
    packed = struct.pack('<' + str(len(offsets)) + 'I', *offsets) + b''.join(pieces)
    return (packed, 0x80000200) if len(packed) < len(data) else (data, 0x80000000)


def prepare_images(archive, strings, staging):
    from PIL import Image
    candidates = set()
    for raw in strings:
        try: name = raw.decode('utf8')
        except UnicodeDecodeError: continue
        if len(name) < 260 and re.search(r'\.(?:blp|png|webp|tga|jpg|jpeg)$', name, re.I) and not any(c in name for c in '\r\n\0'):
            candidates.add(name)
    for name in list(candidates):
        if re.search(r'%0?\d*d', name) and name.count('%') == 1:
            for i in range(0, 1001):
                expanded = name % i
                if archive.exists(expanded): candidates.add(expanded)
    target = staging / 'images'
    target.mkdir(exist_ok=True)
    manifest, added, failed = {}, {}, []
    for name in sorted(candidates):
        if not archive.exists(name): continue
        try:
            data, _ = restore_asset(archive.read(name))
            if data[:2] == b'MZ': continue
            try:
                original = Image.open(io.BytesIO(data))
                original.load()
            except OSError:
                # 일부 원본 TGA의 RLE 패킷은 스캔라인 경계를 넘어간다.
                if len(data) < 18 or data[2] != 10 or data[16] != 32: raise
                width, height = struct.unpack_from('<HH',data,12)
                offset, pixels = 18 + data[0], bytearray()
                while len(pixels) < width * height * 4:
                    packet=data[offset];offset+=1;count=(packet&127)+1
                    size=4 if packet&128 else count*4
                    chunk=data[offset:offset+size];offset+=size
                    assert len(chunk)==size,'Truncated TGA packet'
                    pixels.extend(chunk*count if packet&128 else chunk)
                assert len(pixels)==width*height*4,'Invalid TGA pixel count'
                original=Image.frombytes('RGBA',(width,height),bytes(pixels),'raw','BGRA')
                if not data[17]&32:original=original.transpose(Image.Transpose.FLIP_TOP_BOTTOM)
                if data[17]&16:original=original.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
            with original:
                if original.width > 8192 or original.height > 8192: raise ValueError('oversized UI texture')
                img = original.convert('RGBA')
                # 비압축 32비트 TGA로 저장해 런타임의 정수 좌표 자르기에도 사용한다.
                tga = struct.pack('<BBBHHBHHHHBB',0,0,2,0,0,0,0,0,img.width,img.height,32,0x28) + img.tobytes('raw','BGRA')
                key = hashlib.sha256(tga).hexdigest()[:24]
                member = 'HeraWanhua\\tex_' + key + '.tga'
                disk = target / ('tex_' + key + '.tga')
                if not disk.exists(): disk.write_bytes(tga)
                added[member] = disk
                manifest[name.replace('/','\\').lower()] = {'path':member,'width':img.width,'height':img.height}
        except Exception as error:
            failed.append({'name':name,'error':str(error)})
    entries = []
    for name, item in sorted(manifest.items()):
        entries.append('[' + json.dumps(name,ensure_ascii=False) + ']={path=' + json.dumps(item['path']) + ',width=' + str(item['width']) + ',height=' + str(item['height']) + '}')
    data = ('-- 원본 맵 이미지와 헤라 TGA 리소스의 경로 및 크기를 연결한다.\nreturn {\n'+',\n'.join(entries)+'\n}\n').encode('utf8')
    (staging/'hera_assets.lua').write_bytes(data)
    (staging/'image-report.json').write_text(json.dumps({'textures':len(manifest),'files':len(added),'raw_bytes':sum(p.stat().st_size for p in added.values()),'failed':failed},ensure_ascii=False,indent=2),encoding='utf8')
    print('Prepared images',len(manifest),'unique',len(added),'failed',len(failed),flush=True)
    return data, added


def prepare_jass(data, staging):
    source = data.decode('utf8').replace('\r\n', '\n')
    if not re.search(r'(?m)^native DzSetUnitModel ',source):
        source = re.sub(r'(?m)^endglobals$', 'endglobals\nnative DzSetUnitModel takes unit whichUnit, string path returns nothing', source, count=1)
    signatures = {m[1]:(m[2],m[3]) for m in re.finditer(r'(?m)^native (\w+) takes ([^\r\n]+) returns (\w+)',source)}
    names = '''DzGetGameUI DzCreateFrameByTagName DzDestroyFrame DzFrameClearAllPoints
DzFrameSetAbsolutePoint DzFrameSetPoint DzFrameSetSize DzFrameSetEnable DzFrameSetPriority
DzFrameSetAlpha DzFrameSetText DzFrameSetFont DzFrameSetTextColor DzFrameSetTexture
DzFrameShow DzGetWindowWidth DzGetWindowHeight DzGetMouseXRelative DzGetMouseYRelative
DzFrameHideInterface DzFrameEditBlackBorders DzFrameGetParent DzFrameGetHeight
DzSimpleFontStringFindByName DzSimpleFrameFindByName DzSimpleTextureFindByName
DzFrameGetCommandBarButton DzFrameGetItemBarButton DzFrameGetUpperButtonBarButton
DzFrameGetMinimap DzFrameGetChatMessage DzFrameGetTooltip DzFrameFindByName DzLoadToc
DzFrameGetText DzFrameGetAlpha DzFrameSetScale DzFrameSetModel DzFrameSetAnimate
DzFrameSetAnimateOffset DzFrameGetPortrait DzGetMouseFocus DzGetWheelDelta DzIsKeyDown DzIsWindowActive
DzSetUnitModel DzGetUnitUnderMouse DzGetTriggerKey'''.split()
    for name, (args, result) in signatures.items():
        kinds = [] if args == 'nothing' else [arg.strip().split()[0] for arg in args.split(',')]
        if name.startswith(('DzFrame', 'DzSimple', 'DzClickFrame')) and name not in names and all(
                kind in ('integer', 'real', 'string', 'boolean') for kind in kinds):
            if result in ('integer', 'real', 'string', 'boolean', 'nothing'):
                names.append(name)
    # 구형 헤라에는 jass.code가 없으므로 실제로 사용하는 맵 JASS 함수만 연결한다.
    for name in ('get_player_name', 'YDWERPGBillingGetItem', 'YDWERPGBillingHasStatus', 'YDWERPGBillingHasItem'):
        match = re.search(r'(?m)^\s*function ' + name + r' takes ([^\n]+?) returns (\w+)', source)
        assert match, 'Missing map function: ' + name
        signatures[name] = (match[1], match[2])
        names.append(name)
    fields, specs, branches = {}, [], []
    default = {'integer':'0', 'real':'0.0', 'string':'""', 'boolean':'false', 'unit':'null', 'player':'null'}
    types = {'integer':'Integer', 'real':'Real', 'string':'String', 'boolean':'Boolean', 'unit':'Unit', 'player':'Player'}
    for operation, name in enumerate(names, 1):
        args, result = signatures[name]
        params = [] if args == 'nothing' else [x.strip().split() for x in args.split(',')]
        counts, target_args, spec_args = {}, [], []
        for kind, _ in params:
            counts[kind] = counts.get(kind, 0) + 1
            field = types[kind] + str(counts[kind])
            fields[field] = kind
            target_args.append('HW' + field)
            spec_args.append(field)
        result_field = types.get(result, 'nothing')
        if result != 'nothing': fields[result_field + 'Result'] = result
        statement = f'{name}({", ".join(target_args)})'
        statement = ('call ' + statement) if result == 'nothing' else ('set HW' + result_field + 'Result = ' + statement)
        branches.append(('    if' if operation == 1 else '    elseif') + f' HWOperation == {operation} then\n        {statement}\n')
        specs.append([name, operation, result_field, spec_args])
    declarations = '''
    trigger HWEvaluator = null
    integer HWOperation = 0
    boolean HWBusy = false
    boolean HWCompleted = false
    integer HWStatusFrame = 0
'''
    declarations += ''.join(f'    {kind} HW{field} = {default[kind]}\n' for field, kind in fields.items())
    source, count = re.subn(r'(?m)^endglobals$', lambda _: declarations + 'endglobals', source, count=1)
    assert count == 1, 'Missing JASS globals boundary'
    dispatch = '''// 헤라 Lua 요청을 JASS에서 실행하고 초기화 상태를 기록한다.
function HWEvaluate takes nothing returns boolean
'''+''.join(branches)+'''    endif
    set HWCompleted = true
    return false
endfunction
function HWInput takes integer kind returns nothing
    call EXExecuteScript("require('hera_wanhua').input(" + I2S(kind) + ")")
endfunction
function HWLeftDown takes nothing returns nothing
    call HWInput(1)
endfunction
function HWLeftUp takes nothing returns nothing
    call HWInput(2)
endfunction
function HWRightDown takes nothing returns nothing
    call HWInput(3)
endfunction
function HWRightUp takes nothing returns nothing
    call HWInput(4)
endfunction
function HWMouseMove takes nothing returns nothing
    call HWInput(5)
endfunction
function HWWheel takes nothing returns nothing
    call HWInput(6)
endfunction
function HWKeyDown takes nothing returns nothing
    call EXExecuteScript("require('hera_wanhua').key_input(7," + I2S(DzGetTriggerKey()) + ")")
endfunction
function HWKeyUp takes nothing returns nothing
    call EXExecuteScript("require('hera_wanhua').key_input(8," + I2S(DzGetTriggerKey()) + ")")
endfunction
function HWRefresh takes nothing returns nothing
    local string result = EXExecuteScript("require('hera_wanhua').tick()")
    if result == null then
        call PauseTimer(GetExpiredTimer())
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 30.0, "Hera Wanhua v4: Lua update failed; refresh stopped.")
        return
    endif
    if result != "" then
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 30.0, result)
    endif
endfunction
function HWStart takes nothing returns nothing
    local string result = EXExecuteScript("require('hera_wanhua').start()")
    if result == null or result == "" then
        call DestroyTimer(GetExpiredTimer())
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 30.0, "Hera Wanhua v4: Lua startup failed; refresh not started.")
        return
    endif
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0.0, 0.0, 20.0, result)
    call TimerStart(GetExpiredTimer(), 0.033333333, true, function HWRefresh)
endfunction
function HWInit takes nothing returns nothing
    local integer key = 8
    set HWEvaluator = CreateTrigger()
    call TriggerAddCondition(HWEvaluator, Condition(function HWEvaluate))
    call DzTriggerRegisterMouseEventByCode(null, 1, 1, false, function HWLeftDown)
    call DzTriggerRegisterMouseEventByCode(null, 1, 0, false, function HWLeftUp)
    call DzTriggerRegisterMouseEventByCode(null, 2, 1, false, function HWRightDown)
    call DzTriggerRegisterMouseEventByCode(null, 2, 0, false, function HWRightUp)
    call DzTriggerRegisterMouseMoveEventByCode(null, false, function HWMouseMove)
    call DzTriggerRegisterMouseWheelEventByCode(null, false, function HWWheel)
    loop
        exitwhen key > 254
        call DzTriggerRegisterKeyEventByCode(null, key, 1, false, function HWKeyDown)
        call DzTriggerRegisterKeyEventByCode(null, key, 0, false, function HWKeyUp)
        set key = key + 1
    endloop
    call TimerStart(CreateTimer(), 0.0, false, function HWStart)
endfunction
'''
    # 원본의 후킹용 가짜 EXExecuteScript 대신 설치 JN 네이티브를 사용한다.
    source, count = re.subn(r'function EXExecuteScript takes string p1 returns string\s*call GetTriggeringTrigger\(\)\s*return ""\s*endfunction', '', source)
    assert count == 1
    source = re.sub(r'(?m)^endglobals$', 'endglobals\nnative EXExecuteScript takes string script returns string', source, count=1)
    source = re.sub(r'(?m)^native DzGetUnitNeededXP[^\r\n]*', '// 설치 JN에 없는 미호출 네이티브 선언을 제외한다.', source)
    source = source.replace('\tcall Cheat("exec-lua:load")', '// 헤라의 EXExecuteScript 시작 경로를 사용한다.')
    source = source.replace('function main takes nothing returns nothing', dispatch + '\nfunction main takes nothing returns nothing',1)
    source = source.replace('\tcall initializePlugin()', '\tcall HWInit()', 1)
    (staging/'war3map.j').write_text(source,encoding='utf8')
    bindings = '-- 헤라 UI 연결기의 검증된 JASS 호출 번호와 인수 필드를 정의한다.\nreturn ' + json.dumps(specs,ensure_ascii=False).replace('[','{').replace(']','}')
    (staging/'hera_bindings.lua').write_text(bindings,encoding='utf8')
    return source.encode('utf8'), bindings.encode('utf8')


def pack_map(source_path, output_path, archive, patches, staging):
    assert not output_path.exists(), 'Output already exists; choose a new version'
    with source_path.open('rb') as source:
        prefix = source.read(8192)
        base = prefix.index(b'MPQ\x1a')
        _, header_size, archive_size, version, shift, hash_pos, block_pos, hash_count, block_count = struct.unpack_from('<4sIIHHIIII',prefix,base)
        assert header_size == 32 and version == 0 and block_count == 10611
        source.seek(base+hash_pos)
        hashes = bytearray(crypt(source.read(hash_count*16), name_hash('(hash table)',3)))
        source.seek(base+block_pos)
        original_blocks = list(struct.iter_unpack('<4I',crypt(source.read(block_count*16),name_hash('(block table)',3))))
    def resolve(name):
        a,b=name_hash(name,1),name_hash(name,2)
        for i in range(hash_count):
            slot=(name_hash(name,0)+i)%hash_count
            ha,hb,locale,platform,index=struct.unpack_from('<IIHHI',hashes,slot*16)
            if index==0xffffffff:return slot,None
            if (ha,hb)==(a,b):return slot,index
        raise RuntimeError('MPQ hash table is full')
    replacements={}
    added=[]
    for name,data in patches.items():
        slot,index=resolve(name)
        if index is None:
            index=block_count+len(added);added.append((index,data))
            struct.pack_into('<IIHHI',hashes,slot*16,name_hash(name,1),name_hash(name,2),0,0,index)
        replacements[index]=(name,data)
    rows=[];blocks=[];counts={'BLP':0,'MDX':0};output_path.parent.mkdir(parents=True,exist_ok=True)
    with output_path.open('xb') as out:
        out.write(prefix[:base]);out.write(b'\0'*32)
        for index in range(block_count+len(added)):
            if index in replacements:
                name,data=replacements[index];kind='patch'
                if isinstance(data,Path): data=data.read_bytes()
            else:
                data=archive.read(f'File{index:08d}.xxx')
                data,kind=restore_asset(data)
                if kind:counts[kind]+=1
                name=None
            offset=out.tell()-base
            packed,flags=compress(data,512<<shift)
            out.write(packed);blocks.append((offset,len(packed),len(data),flags))
            rows.append({'index':index,'name':name,'kind':kind,'size':len(data),'sha256':hashlib.sha256(data).hexdigest()})
            if index%1000==0:print('Packed',index,flush=True)
        hp=out.tell()-base;out.write(crypt(hashes,name_hash('(hash table)',3),True))
        bp=out.tell()-base;out.write(crypt(b''.join(struct.pack('<4I',*row) for row in blocks),name_hash('(block table)',3),True))
        size=out.tell()-base
        out.seek(base);out.write(struct.pack('<4sIIHHIIII',b'MPQ\x1a',32,size,0,shift,hp,bp,hash_count,len(blocks)))
    report={'source_sha256':SOURCE_SHA256,'output':str(output_path),'output_sha256':file_hash(output_path),'restored':counts,'files':rows}
    (staging/'build-report.json').write_text(json.dumps(report,indent=2),encoding='utf8')
    assert file_hash(source_path)==SOURCE_SHA256
    return report


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--stormlib', type=Path, required=True)
    parser.add_argument('--prepare-only', action='store_true')
    parser.add_argument('--prepare-images', action='store_true')
    args = parser.parse_args()
    assert args.source.resolve() != args.output.resolve(), 'Original must not be overwritten'
    assert file_hash(args.source) == SOURCE_SHA256, 'This patch is only for the verified v0.175 map'
    archive = Archive(args.source, args.stormlib)
    try:
        staging = args.output.parent / 'staging'
        run, strings = prepare_bundle(archive.read('run.lua'), staging)
        jass, bindings = prepare_jass(archive.read('war3map.j'),staging)
        if args.prepare_images:
            prepare_images(archive,strings,staging)
        if args.prepare_only:
            print('Prepared bundle', len(run), flush=True)
            return
        patches={'run.lua':run,'war3map.j':jass,'hera_bindings.lua':bindings}
        entry = "-- 헤라 JASS 시작 타이머에서 호환 스크립트를 초기화한다.\nreturn require('hera_wanhua')\n".encode('utf8')
        patches.update({'main.lua':entry,'load.lua':entry,'config.lua':'-- 외부 플랫폼 DLL 부트스트랩을 사용하지 않는다.\nreturn true\n'.encode('utf8')})
        for path in Path(__file__).parent.glob('*.lua'):
            patches[path.name]=path.read_bytes();(staging/path.name).write_bytes(path.read_bytes())
        assets, images = prepare_images(archive, strings, staging)
        patches['hera_assets.lua']=assets
        patches.update(images)
        report=pack_map(args.source,args.output,archive,patches,staging)
        print(json.dumps({k:v for k,v in report.items() if k!='files'},ensure_ascii=False),flush=True)
    finally:
        archive.close()


if __name__ == '__main__':
    main()
