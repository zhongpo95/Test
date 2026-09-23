# 헤라 생성 MPQ의 파일을 읽고 교체하는 진단용 도구다.
import struct, zlib
from pathlib import Path
MASK = 4294967295
T = [0] * 1280
s = 1048577
for i in range(256):
    for j in range(5):
        s = (s * 125 + 3) % 2796203
        a = (s & 65535) << 16
        s = (s * 125 + 3) % 2796203
        T[i + j * 256] = a | s & 65535

def nh(name, k):
    a, b = (2146271213, 4008636142)
    for c in name.replace('/', '\\').upper().encode():
        a = T[k * 256 + c] ^ a + b & MASK
        b = c + a + b + (b << 5) + 3 & MASK
    return a

def crypt(data, key, encrypt=False):
    out = bytearray()
    s = 4008636142
    for v, in struct.iter_unpack('<I', data):
        s = s + T[1024 + (key & 255)] & MASK
        w = v ^ key + s & MASK
        out += struct.pack('<I', w)
        plain = v if encrypt else w
        key = (((~key & MASK) << 21) + 286331153 | key >> 11) & MASK
        s = plain + s + (s << 5) + 3 & MASK
    return out

class Map:

    def __init__(self, path):
        self.data = bytearray(Path(path).read_bytes())
        self.base = 512
        assert self.data[512:516] == b'MPQ\x1a'
        h = struct.unpack_from('<IIHH4I', self.data, 516)
        assert h[0] == 32 and h[2] == 0
        self.shift = h[3]
        self.hp, self.bp, self.hn, self.bn = h[4:]
        self.hashes = crypt(self.data[512 + self.hp:512 + self.hp + self.hn * 16], nh('(hash table)', 3))
        self.blocks = list(struct.iter_unpack('<4I', crypt(self.data[512 + self.bp:512 + self.bp + self.bn * 16], nh('(block table)', 3))))

    def index(self, name):
        matches = [v[4] for v in struct.iter_unpack('<IIHHI', self.hashes) if v[:2] == (nh(name, 1), nh(name, 2))]
        assert len(matches) == 1, (name, matches)
        return matches[0]

    def read(self, name):
        off, stored, size, flags = self.blocks[self.index(name)]
        b = self.data[512 + off:512 + off + stored]
        assert not flags & 65536
        if not flags & 512:
            return bytes(b[:size])
        n = (size + (512 << self.shift) - 1) // (512 << self.shift)
        offsets = struct.unpack_from('<' + 'I' * (n + 1), b)
        out = bytearray()
        for i in range(n):
            part = b[offsets[i]:offsets[i + 1]]
            wanted = min(512 << self.shift, size - len(out))
            if len(part) < wanted:
                assert part[0] == 2
                part = zlib.decompress(part[1:])
            out += part
        assert len(out) == size
        return bytes(out)
