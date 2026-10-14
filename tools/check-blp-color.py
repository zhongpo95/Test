# BLP JPEG의 원시 색상 성분과 기존 YCbCr 오류의 재발을 검사한다.
import importlib.util
import io
from pathlib import Path

from PIL import Image

spec = importlib.util.spec_from_file_location('converter', Path(__file__).with_name('convert-modelpack-blp.py'))
converter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(converter)

for color in [(255, 0, 0), (0, 255, 0), (0, 0, 255), (255, 255, 255), (0, 0, 0), (220, 70, 30)]:
    original = Image.new('RGBA', (32, 16), (*color, 255))
    data = converter.encode(original, 90)
    decoded, _, count = converter.decode_verify(data, original)
    assert count == 6
    assert max(abs(a-b) for a, b in zip(decoded.getpixel((0, 0)), (*color, 255))) <= 2
    jpeg = converter.raw_bgra_jpeg(original, 90)
    pos = 2
    components = None
    while jpeg[pos+1] != 0xDA:
        marker = jpeg[pos+1]
        size = int.from_bytes(jpeg[pos+2:pos+4], 'big')
        assert not 0xE0 <= marker <= 0xEF, 'Unexpected color interpretation metadata'
        if marker == 0xC0:
            components = jpeg[pos+9]
        pos += size + 2
    assert components == 4, 'BLP requires four raw components'

old = io.BytesIO()
Image.new('RGB', (16, 16), 'red').save(old, format='JPEG')
try:
    converter.decode_raw_bgra_jpeg(old.getvalue())
except ValueError:
    pass
else:
    raise AssertionError('Old YCbCr format was incorrectly accepted')

alpha = Image.new('RGBA', (16, 16), (20, 80, 160, 127))
decoded, _, _ = converter.decode_verify(converter.encode(alpha, 90), alpha)
assert decoded.getchannel('A').tobytes() == alpha.getchannel('A').tobytes()
print('PASS: raw BGRA colors, four components, metadata, mipmaps, YCbCr rejection, alpha preservation')
