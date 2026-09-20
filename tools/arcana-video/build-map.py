# 원본 맵을 보존하며 영상 테스트 코드와 MP4를 복사본에 넣고 다시 읽어 검증한다.
import argparse
import ctypes as C
from ctypes import wintypes as W
import hashlib
import json
import pathlib
import re
import shutil

parser = argparse.ArgumentParser()
parser.add_argument('--source', type=pathlib.Path, required=True)
parser.add_argument('--output', type=pathlib.Path, required=True)
parser.add_argument('--stormlib', type=pathlib.Path, required=True)
parser.add_argument('--clip', type=pathlib.Path, required=True)
args = parser.parse_args()
if args.source.resolve() == args.output.resolve():
    raise ValueError('The test map must not overwrite its source')
root = pathlib.Path(__file__).resolve().parent
lib = C.WinDLL(str(args.stormlib), use_last_error=True)

def bind(name, arguments, result=C.c_bool):
    function = getattr(lib, name)
    function.argtypes, function.restype = arguments, result
    return function

open_mpq = bind('SFileOpenArchive', [C.c_void_p, W.DWORD, W.DWORD, C.POINTER(W.HANDLE)])
close_mpq = bind('SFileCloseArchive', [W.HANDLE])
open_file = bind('SFileOpenFileEx', [W.HANDLE, C.c_char_p, W.DWORD, C.POINTER(W.HANDLE)])
close_file = bind('SFileCloseFile', [W.HANDLE])
file_size = bind('SFileGetFileSize', [W.HANDLE, C.POINTER(W.DWORD)], W.DWORD)
read_file = bind('SFileReadFile', [W.HANDLE, C.c_void_p, W.DWORD, C.POINTER(W.DWORD), C.c_void_p])
add_file = bind('SFileAddFileEx', [W.HANDLE, C.c_void_p, C.c_char_p, W.DWORD, W.DWORD, W.DWORD])
wide = None

def path_buffer(path):
    return C.create_unicode_buffer(str(path)) if wide else C.create_string_buffer(str(path).encode('utf-8'))

def archive(path, readonly):
    global wide
    for mode in ([True, False] if wide is None else [wide]):
        wide = mode
        handle = W.HANDLE()
        if open_mpq(path_buffer(path), 0, 0x100 if readonly else 0, C.byref(handle)):
            return handle
    raise OSError(C.get_last_error(), 'Cannot open MPQ', str(path))

def read(handle, name):
    member = W.HANDLE()
    if not open_file(handle, name.encode('utf-8'), 0, C.byref(member)):
        raise OSError(C.get_last_error(), 'Cannot open member', name)
    try:
        high = W.DWORD()
        size = file_size(member, C.byref(high))
        if high.value or size == 0xffffffff:
            raise ValueError('Invalid MPQ member size')
        if not size:
            return b''
        buffer, count = C.create_string_buffer(size), W.DWORD()
        if not read_file(member, buffer, size, C.byref(count), None) or count.value != size:
            raise OSError(C.get_last_error(), 'Cannot read member', name)
        return buffer.raw
    finally:
        close_file(member)

def sha(data):
    return hashlib.sha256(data).hexdigest()

source_hash = sha(args.source.read_bytes())
handle = archive(args.source, True)
try:
    names = read(handle, '(listfile)').decode('utf-8-sig').splitlines()
    original = {name: sha(read(handle, name)) for name in names if name}
    script = read(handle, 'war3map.j').decode('utf-8')
    if 'ArcanaVideoTest_Init' in script:
        raise ValueError('Map already contains the video test')
    natives = ('native JNArcVideoOpen takes string asset returns integer\r\n'
               'native JNArcVideoClose takes nothing returns nothing\r\n'
               'native JNArcVideoStatus takes nothing returns string\r\n')
    location = re.search(r'(?m)^[ \t]*native\s', script)
    if not location:
        raise ValueError('Native declaration insertion point not found')
    script = script[:location.start()] + natives + script[location.start():]
    test = (root / 'ArcanaVideoTest.j').read_text(encoding='utf-8').replace('\n', '\r\n')
    marker = 'function main takes nothing returns nothing'
    if script.count(marker) != 1:
        raise ValueError('Ambiguous main function')
    script = script.replace(marker, test + '\r\n' + marker, 1)
    main = re.search(marker + r'.*?\r?\nendfunction', script, re.S)
    body = main.group().rsplit('endfunction', 1)[0] + '    call ArcanaVideoTest_Init()\r\nendfunction'
    script = script[:main.start()] + body + script[main.end():]
    imports = read(handle, 'war3map.imp')
    count = int.from_bytes(imports[4:8], 'little')
    imports = imports[:4] + (count + 1).to_bytes(4, 'little') + imports[8:] + b'\x0darcana_video_test.mp4\0'
    wts = read(handle, 'war3map.wts').decode('utf-8')
    title = re.compile(r'(STRING 779\r?\n\{\r?\n).*?(\r?\n\})', re.S)
    if len(title.findall(wts)) != 1:
        raise ValueError('Expected original test map title was not found')
    wts = title.sub(lambda m: m.group(1) + 'OPENGL VIDEO TEST - 0.15' + m.group(2), wts, count=1)
finally:
    close_mpq(handle)

args.output.parent.mkdir(parents=True, exist_ok=True)
staging = args.output.parent / 'map-source'
staging.mkdir(exist_ok=True)
payloads = {'war3map.j': script.encode('utf-8'), 'war3map.imp': imports,
            'war3map.wts': wts.encode('utf-8'), 'arcana_video_test.mp4': args.clip.read_bytes()}
for name, data in payloads.items():
    (staging / name).write_bytes(data)
shutil.copy2(args.source, args.output)
handle = archive(args.output, False)
try:
    for name in payloads:
        if not add_file(handle, path_buffer(staging / name), name.encode('utf-8'), 0x80000200, 2, 2):
            raise OSError(C.get_last_error(), 'Cannot add map member', name)
finally:
    if not close_mpq(handle):
        raise OSError(C.get_last_error(), 'Cannot finalize map')
handle = archive(args.output, True)
try:
    changed = [name for name, digest in original.items() if sha(read(handle, name)) != digest]
    if set(changed) - {'war3map.j', 'war3map.imp', 'war3map.wts', '(listfile)', '(attributes)'}:
        raise AssertionError('Unexpected changed members. ' + repr(changed))
    for name, expected in payloads.items():
        if read(handle, name) != expected:
            raise AssertionError('Pack verification failed. ' + name)
finally:
    close_mpq(handle)
if sha(args.source.read_bytes()) != source_hash:
    raise AssertionError('Original map was changed')
report = {'sourceSHA256': source_hash, 'outputSHA256': sha(args.output.read_bytes()),
          'originalMembers': len(original), 'changedMembers': changed,
          'preservedMembers': len(original) - len(changed), 'addedMembers': ['arcana_video_test.mp4'],
          'sourceUnchanged': True, 'runtimeTested': False}
(args.output.parent / 'map-build-report.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
print(json.dumps(report))
