# 원본 MPQ를 보존하고 지정한 멤버와 버전 정보만 교체합니다.
import argparse
import hashlib
import json
import struct
import zlib
from pathlib import Path

TABLE = [0] * 1280
seed = 0x100001
for i in range(256):
    for j in range(5):
        seed = (seed * 125 + 3) % 0x2aaaab
        a = (seed & 65535) << 16
        seed = (seed * 125 + 3) % 0x2aaaab
        TABLE[i + j * 256] = a | (seed & 65535)

def hash_name(name, kind):
    a, b = 0x7fed7fed, 0xeeeeeeee
    for c in name.replace('/', '\\').upper().encode():
        a = TABLE[kind * 256 + c] ^ ((a + b) & 0xffffffff)
        b = (c + a + b + (b << 5) + 3) & 0xffffffff
    return a

def crypt(data, key, encrypt=False):
    output = bytearray()
    seed = 0xeeeeeeee
    for value, in struct.iter_unpack('<I', data):
        seed = (seed + TABLE[0x400 + (key & 255)]) & 0xffffffff
        decoded = value if encrypt else value ^ ((key + seed) & 0xffffffff)
        output += struct.pack('<I', value ^ ((key + seed) & 0xffffffff))
        key = ((((~key & 0xffffffff) << 21) + 0x11111111) | (key >> 11)) & 0xffffffff
        seed = (decoded + seed + (seed << 5) + 3) & 0xffffffff
    return bytes(output)

class Archive:
    def __init__(self, data):
        self.data = data
        self.base = data.index(b'MPQ\x1a')
        self.header = list(struct.unpack_from('<4sIIHHIIII', data, self.base))
        _, _, _, version, shift, ho, bo, hn, bn = self.header
        assert version == 0
        self.sector = 512 << shift
        self.hashes = list(struct.iter_unpack('<IIHHI', crypt(data[self.base+ho:self.base+ho+hn*16], hash_name('(hash table)', 3))))
        self.blocks = list(struct.iter_unpack('<IIII', crypt(data[self.base+bo:self.base+bo+bn*16], hash_name('(block table)', 3))))

    def index(self, name):
        key = (hash_name(name, 1), hash_name(name, 2))
        rows = [r for r in self.hashes if r[:2] == key]
        assert len(rows) == 1, name
        return rows[0][4]

    def read(self, name):
        off, stored, size, flags = self.blocks[self.index(name)]
        assert not flags & 0x10000, 'encrypted member unsupported'
        data = self.data[self.base+off:self.base+off+stored]
        if flags & 0x200:
            assert not flags & 0x1000000
            count = (size+self.sector-1)//self.sector
            offsets = struct.unpack_from('<'+'I'*(count+1), data)
            chunks = []
            for i in range(count):
                chunk = data[offsets[i]:offsets[i+1]]
                expected = min(self.sector, size-i*self.sector)
                if len(chunk) < expected:
                    assert chunk[0] == 2
                    chunk = zlib.decompress(chunk[1:])
                chunks.append(chunk)
            data = b''.join(chunks)
        assert len(data) == size
        return data

    def write(self, replacements, old_revision=179, new_revision=180):
        out = bytearray(self.data)
        blocks = list(self.blocks)
        for name, content in replacements.items():
            index = self.index(name)
            blocks[index] = (len(out)-self.base, len(content), len(content), 0x80000000)
            out.extend(content)
        header = list(self.header)
        header[6] = len(out)-self.base
        out.extend(crypt(b''.join(struct.pack('<IIII', *r) for r in blocks), hash_name('(block table)', 3), True))
        header[2] = len(out)-self.base
        struct.pack_into('<4sIIHHIIII', out, self.base, *header)
        # 같은 길이의 로비 이름을 바꾸어 MPQ 시작 오프셋을 보존한다.
        prefix = bytes(out[:self.base])
        old = f'v{old_revision} MP'.encode()
        new = f'v{new_revision} MP'.encode()
        assert len(old) == len(new) and old in prefix
        out[:self.base] = prefix.replace(old, new)
        return bytes(out)
