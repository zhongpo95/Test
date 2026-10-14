# 실제 File숫자 파일명도 보존하는 클래식 MPQ v0 패키지를 작성한다.
import struct
import zlib


TABLE = [0] * 0x500
seed = 0x100001
for i in range(256):
    for j in range(5):
        seed = (seed * 125 + 3) % 0x2AAAAB
        high = (seed & 0xFFFF) << 16
        seed = (seed * 125 + 3) % 0x2AAAAB
        TABLE[i + j * 256] = high | (seed & 0xFFFF)


def hash_name(name, kind):
    a, b = 0x7FED7FED, 0xEEEEEEEE
    for char in name.replace('/', '\\').encode('ascii').upper():
        a = (TABLE[(kind << 8) + char] ^ (a + b)) & 0xFFFFFFFF
        b = (char + a + b + (b << 5) + 3) & 0xFFFFFFFF
    return a


def encrypt(data, key):
    seed, result = 0xEEEEEEEE, []
    for (value,) in struct.iter_unpack('<I', data):
        seed = (seed + TABLE[0x400 + (key & 255)]) & 0xFFFFFFFF
        result.append(value ^ ((key + seed) & 0xFFFFFFFF))
        key = (((~key << 21) + 0x11111111) | (key >> 11)) & 0xFFFFFFFF
        seed = (value + seed + (seed << 5) + 3) & 0xFFFFFFFF
    return struct.pack('<%dI' % len(result), *result)


def validate_source(path, names):
    # 목록 밖 파일이나 로케일 변형이 있으면 조용히 누락시키지 않고 중단한다.
    with path.open('rb') as stream:
        prefix = stream.read(512)
        header = stream.read(32)
        if prefix[:4] != b'HM3W' or header[:4] != b'MPQ\x1a':
            raise ValueError('Expected classic map header')
        hs, total, version, sector, hp, bp, hc, bc = struct.unpack_from('<IIHHIIII', header, 4)
        if hs != 32 or version != 0 or path.stat().st_size != total+512:
            raise ValueError('Unsupported archive version or trailing signature')
        stream.seek(512+hp)
        encrypted = stream.read(hc*16)
    key, seed, decoded = hash_name('(hash table)', 3), 0xEEEEEEEE, []
    for (value,) in struct.iter_unpack('<I', encrypted):
        seed = (seed + TABLE[0x400+(key & 255)]) & 0xFFFFFFFF
        plain = value ^ ((key+seed) & 0xFFFFFFFF)
        decoded.append(plain)
        key = (((~key << 21)+0x11111111) | (key >> 11)) & 0xFFFFFFFF
        seed = (plain+seed+(seed << 5)+3) & 0xFFFFFFFF
    known = {(hash_name(n, 1), hash_name(n, 2)) for n in list(names)+['(listfile)', '(attributes)']}
    raw = struct.pack('<%dI' % len(decoded), *decoded)
    for a, b, locale, platform, index in struct.iter_unpack('<IIHHI', raw):
        if index < 0xFFFFFFFE:
            if index >= bc or (a, b) not in known or locale != 0 or platform != 0:
                raise ValueError('Incomplete file list or unsupported localized member')


def write_mpq(path, members):
    blocks, seen = [], set()
    with path.open('wb') as out:
        out.write(bytes(32))
        for name, data in members:
            if name.lower() in seen:
                raise ValueError('Duplicate MPQ member ' + name)
            seen.add(name.lower())
            offset, size = out.tell(), len(data)
            if data:
                chunks = []
                for start in range(0, size, 4096):
                    raw = data[start:start+4096]
                    packed = b'\x02' + zlib.compress(raw, 6)
                    chunks.append(packed if len(packed) < len(raw) else raw)
                positions = [(len(chunks)+1)*4]
                for chunk in chunks:
                    positions.append(positions[-1] + len(chunk))
                out.write(struct.pack('<%dI' % len(positions), *positions))
                for chunk in chunks:
                    out.write(chunk)
            blocks.append((name, offset, out.tell()-offset, size, 0x80000200 if size else 0x80000000))
        count = 4
        while count < len(blocks)*2:
            count *= 2
        hashes = [(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFF, 0xFFFF, 0xFFFFFFFF)] * count
        for index, (name, *_rest) in enumerate(blocks):
            slot = hash_name(name, 0) % count
            while hashes[slot][4] != 0xFFFFFFFF:
                slot = (slot+1) % count
            hashes[slot] = (hash_name(name, 1), hash_name(name, 2), 0, 0, index)
        hpos = out.tell()
        out.write(encrypt(b''.join(struct.pack('<IIHHI', *row) for row in hashes), hash_name('(hash table)', 3)))
        bpos = out.tell()
        out.write(encrypt(b''.join(struct.pack('<IIII', *row[1:]) for row in blocks), hash_name('(block table)', 3)))
        total = out.tell()
        out.seek(0)
        out.write(b'MPQ\x1a' + struct.pack('<IIHHIIII', 32, total, 0, 3, hpos, bpos, count, len(blocks)))
