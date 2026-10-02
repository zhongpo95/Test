# StormLib으로 맵 파일을 열고 내용과 목록을 보존하며 복사본을 편집한다.
import ctypes as c
import os
import sys
from dataclasses import dataclass
from pathlib import Path


class MpqError(RuntimeError):
    pass


class FindData(c.Structure):
    _fields_ = [('name', c.c_char * 260), ('plain_name', c.c_void_p),
                ('hash_index', c.c_uint32), ('block_index', c.c_uint32),
                ('size', c.c_uint32), ('flags', c.c_uint32),
                ('compressed_size', c.c_uint32), ('time_low', c.c_uint32),
                ('time_high', c.c_uint32), ('locale', c.c_uint32)]


@dataclass(frozen=True)
class Member:
    raw_name: bytes
    size: int
    compressed_size: int
    locale: int = 0
    block_index: int = 0

    @property
    def name(self):
        for encoding in ('utf-8', 'cp949', 'gb18030'):
            try:
                return self.raw_name.decode(encoding)
            except UnicodeDecodeError:
                pass
        return self.raw_name.decode('latin1')


def load_library(path=None):
    if os.name != 'nt':
        raise MpqError('맵 처리는 Windows에서 지원합니다.')
    if path is None:
        path = Path(getattr(sys, '_MEIPASS', Path(__file__).parent)) / 'StormLib.dll'
    path = Path(path).resolve()
    if not path.is_file():
        raise MpqError('StormLib.dll을 찾을 수 없습니다. 배포 EXE를 사용하거나 --stormlib 경로를 지정하세요.')
    try:
        dll = c.WinDLL(str(path), use_last_error=True)
    except OSError as exc:
        raise MpqError('64비트 Unicode StormLib.dll을 불러오지 못했습니다. ' + str(exc)) from exc
    handle = c.c_void_p
    uint = c.c_uint32
    pointer = c.POINTER(handle)
    signatures = {
        'SFileOpenArchive': ([c.c_wchar_p, uint, uint, pointer], c.c_bool),
        'SFileCreateArchive': ([c.c_wchar_p, uint, uint, pointer], c.c_bool),
        'SFileCloseArchive': ([handle], c.c_bool),
        'SFileOpenFileEx': ([handle, c.c_char_p, uint, pointer], c.c_bool),
        'SFileGetFileSize': ([handle, c.POINTER(uint)], uint),
        'SFileReadFile': ([handle, c.c_void_p, uint, c.POINTER(uint), handle], c.c_bool),
        'SFileCloseFile': ([handle], c.c_bool),
        'SFileHasFile': ([handle, c.c_char_p], c.c_bool),
        'SFileFindFirstFile': ([handle, c.c_char_p, c.POINTER(FindData), c.c_wchar_p], handle),
        'SFileFindNextFile': ([handle, c.POINTER(FindData)], c.c_bool),
        'SFileFindClose': ([handle], c.c_bool),
        'SFileSetLocale': ([uint], uint),
        'SFileGetFileInfo': ([handle, c.c_int, c.c_void_p, uint, c.POINTER(uint)], c.c_bool),
        'SFileRemoveFile': ([handle, c.c_char_p, uint], c.c_bool),
        'SFileCreateFile': ([handle, c.c_char_p, c.c_uint64, uint, uint, uint, pointer], c.c_bool),
        'SFileWriteFile': ([handle, c.c_void_p, uint, uint], c.c_bool),
        'SFileFinishFile': ([handle], c.c_bool),
        'SFileCompactArchive': ([handle, c.c_wchar_p, c.c_bool], c.c_bool),
    }
    for name, (arguments, result) in signatures.items():
        getattr(dll, name).argtypes = arguments
        getattr(dll, name).restype = result
    return dll


class Archive:
    def __init__(self, dll, path, write=False, create=False):
        self.dll = dll
        self.handle = c.c_void_p()
        if create:
            ok = dll.SFileCreateArchive(str(path), 0x00100000, 4096, c.byref(self.handle))
        else:
            ok = dll.SFileOpenArchive(str(path), 0, 0 if write else 0x100, c.byref(self.handle))
        self.check(ok, '맵 열기 실패')

    @staticmethod
    def check(ok, operation):
        if not ok:
            raise MpqError(operation + ' (StormLib 오류 ' + str(c.get_last_error()) + ')')

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc, traceback):
        ok = self.dll.SFileCloseArchive(self.handle)
        self.handle = None
        if exc_type is None:
            self.check(ok, '맵 닫기 실패')

    def members(self):
        data = FindData()
        search = self.dll.SFileFindFirstFile(self.handle, b'*', c.byref(data), None)
        self.check(search and search != c.c_void_p(-1).value, '파일 목록 조회 실패')
        result = []
        try:
            while True:
                result.append(Member(bytes(data.name), data.size, data.compressed_size,
                                     data.locale, data.block_index))
                if not self.dll.SFileFindNextFile(search, c.byref(data)):
                    if c.get_last_error() != 18:  # ERROR_NO_MORE_FILES
                        self.check(False, '파일 목록 읽기 실패')
                    break
        finally:
            self.dll.SFileFindClose(search)
        return result

    def info(self, kind, value_type=c.c_uint32):
        value = value_type()
        self.check(self.dll.SFileGetFileInfo(self.handle, kind, c.byref(value), c.sizeof(value), None),
                   '맵 정보 조회 실패')
        return value.value

    def exists(self, name):
        return bool(self.dll.SFileHasFile(self.handle, name))

    def read(self, member, limit=128 * 1024 * 1024):
        if isinstance(member, bytes):
            member = Member(member, 0, 0)
        previous = self.dll.SFileSetLocale(member.locale)
        handle = c.c_void_p()
        try:
            self.check(self.dll.SFileOpenFileEx(self.handle, member.raw_name, 0, c.byref(handle)),
                       '파일 열기 실패. ' + member.name)
            high = c.c_uint32()
            size = self.dll.SFileGetFileSize(handle, c.byref(high))
            if high.value or size == 0xffffffff or size > limit:
                raise MpqError('분석 가능한 파일 크기를 초과했습니다. ' + member.name)
            buffer = c.create_string_buffer(size)
            count = c.c_uint32()
            self.check(self.dll.SFileReadFile(handle, buffer, size, c.byref(count), None),
                       '파일 읽기 실패. ' + member.name)
            if count.value != size:
                raise MpqError('파일을 끝까지 읽지 못했습니다. ' + member.name)
            return buffer.raw
        finally:
            if handle.value:
                self.dll.SFileCloseFile(handle)
            self.dll.SFileSetLocale(previous)

    def remove(self, member):
        previous = self.dll.SFileSetLocale(member.locale)
        try:
            self.check(self.dll.SFileRemoveFile(self.handle, member.raw_name, 0),
                       '삭제 실패. ' + member.name)
        finally:
            self.dll.SFileSetLocale(previous)

    def put(self, name, data, locale=0):
        handle = c.c_void_p()
        self.check(self.dll.SFileCreateFile(self.handle, name, 0, len(data), locale,
                                           0x80000200, c.byref(handle)), '파일 생성 실패')
        try:
            self.check(self.dll.SFileWriteFile(handle, data, len(data), 2), '파일 쓰기 실패')
        finally:
            self.check(self.dll.SFileFinishFile(handle), '파일 쓰기 마무리 실패')

    def compact(self):
        self.check(self.dll.SFileCompactArchive(self.handle, None, False), '맵 재압축 실패')
