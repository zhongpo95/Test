# 범위 표시의 JPEG BLP를 무손실 TGA로 변환하고 텍스처 경로만 바꾼 비교 맵을 만든다.
import argparse
import hashlib
import importlib.util
import io
import json
import shutil
import struct
from pathlib import Path

from PIL import Image


def sha(data):
    return hashlib.sha256(data).hexdigest()


def jpeg_blp_to_tga(data):
    if data[:4] != b'BLP1':
        raise ValueError('Expected BLP1')
    compression, alpha_bits, width, height, _, mipmaps = struct.unpack_from('<6I', data, 4)
    if compression != 0 or alpha_bits != 8 or not mipmaps:
        raise ValueError('Expected JPEG BLP with 8-bit alpha and mipmaps')
    offsets = struct.unpack_from('<16I', data, 28)
    sizes = struct.unpack_from('<16I', data, 92)
    header_size = struct.unpack_from('<I', data, 156)[0]
    if header_size > 624:
        raise ValueError('Unexpected JPEG header size')
    header = data[160:160 + header_size]
    checked_mips = []
    for level in range(max(width, height).bit_length()):
        offset, size = offsets[level], sizes[level]
        if offset < 160 + header_size or not size or offset + size > len(data):
            raise ValueError('Invalid mipmap bounds')
        jpeg = Image.open(io.BytesIO(header + data[offset:offset + size]))
        jpeg.load()
        if jpeg.mode != 'CMYK' or jpeg.size != (max(1, width >> level), max(1, height >> level)):
            raise ValueError('Unexpected JPEG component count or mipmap size')
        if jpeg.info.get('adobe_transform') is not None:
            raise ValueError('Adobe color conversion is not valid for this BLP')
        checked_mips.append(list(jpeg.size))
        if level == 0:
            # BLP JPEG의 네 성분은 CMYK가 아니라 BGRA다. Pillow의 CMYK 반전을 되돌린다.
            # RGB/RGBA convert()는 인쇄용 색 변환을 적용하고 원본 알파를 잃으므로 사용하지 않는다.
            bgra = bytes(255 - component for component in jpeg.tobytes())
    tga_header = struct.pack('<BBBHHBHHHHBB', 0, 0, 2, 0, 0, 0, 0, 0, width, height, 32, 0x28)
    tga = tga_header + bgra
    with Image.open(io.BytesIO(tga)) as decoded:
        if decoded.mode != 'RGBA' or decoded.tobytes('raw', 'BGRA') != bgra:
            raise AssertionError('TGA round trip changed a color or alpha component')
    return tga, {'size': [width, height], 'validated_source_mips': checked_mips,
                 'alpha_range': [min(bgra[3::4]), max(bgra[3::4])],
                 'all_bgra_components_preserved': True}


def patch_texture(model, old_path, new_path):
    if model[:4] != b'MDLX' or len(new_path.encode('ascii')) >= 260:
        raise ValueError('Invalid model or texture path')
    result = bytearray(model)
    pos, matches = 4, []
    while pos < len(model):
        tag, size = struct.unpack_from('<4sI', model, pos)
        start, end = pos + 8, pos + 8 + size
        if end > len(model):
            raise ValueError('Invalid MDX chunk bounds')
        if tag == b'TEXS':
            if size % 268:
                raise ValueError('Invalid texture chunk')
            for entry in range(start, end, 268):
                path = model[entry + 4:entry + 264].split(b'\0')[0].decode('ascii')
                if path == old_path:
                    result[entry + 4:entry + 264] = new_path.encode('ascii').ljust(260, b'\0')
                    matches.append([entry + 4, entry + 264])
        pos = end
    if pos != len(model) or len(matches) != 1:
        raise ValueError('Expected exactly one matching texture reference')
    first, last = matches[0]
    if result[:first] != model[:first] or result[last:] != model[last:]:
        raise AssertionError('Non-texture model data changed')
    return bytes(result), matches[0]


def run(args):
    source, output, assets = args.source.resolve(), args.output.resolve(), args.assets.resolve()
    if source == output or output.exists():
        raise ValueError('Output must be a new map path')
    assets.mkdir(parents=True, exist_ok=True)
    model, texture = args.model.read_bytes(), args.texture.read_bytes()
    name = 'Etc Boss AOE2_OpenGL.tga'
    tga, texture_report = jpeg_blp_to_tga(texture)
    patched, path_range = patch_texture(model, 'Etc Boss AOE2.blp', name)
    model_path = assets / 'Etc Boss AOE2_OpenGL_TGA.mdx'
    texture_path = assets / name
    model_path.write_bytes(patched)
    texture_path.write_bytes(tga)
    spec = importlib.util.spec_from_file_location('expedition_build', Path(__file__).with_name('build-expedition.py'))
    build = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(build)
    dll = build.load_dll(args.stormlib)
    source_hash = sha(source.read_bytes())
    archive = build.Archive(dll, source)
    try:
        if archive.read('Etc Boss AOE2.mdx') != model or archive.read('Etc Boss AOE2.blp') != texture:
            raise ValueError('Desktop assets do not match the source map')
        members = set(archive.read('(listfile)').decode('utf-8-sig').splitlines())
        original_imports = archive.read('war3map.imp')
        version, count = struct.unpack_from('<II', original_imports)
        if version != 1:
            raise ValueError('Unsupported import table')
        pos = 8
        for _ in range(count):
            end = original_imports.index(b'\0', pos + 1)
            name_in_map = original_imports[pos + 1:end].decode('utf8').replace('/', '\\')
            if original_imports[pos] in (5, 8) and not name_in_map.lower().startswith('war3mapimported\\'):
                name_in_map = 'war3mapImported\\' + name_in_map
            members.add(name_in_map)
            pos = end + 1
        if pos != len(original_imports):
            raise ValueError('Unexpected import table tail')
        hashes = {n: sha(archive.read(n)) for n in members if n and n not in ('(listfile)', '(attributes)')}
        imports = build.import_table(original_imports, [name])
    finally:
        archive.close()
    import_path = assets / 'war3map.imp'
    import_path.write_bytes(imports)
    shutil.copy2(source, output)
    replacements = {'Etc Boss AOE2.mdx': model_path, name: texture_path, 'war3map.imp': import_path}
    archive = build.Archive(dll, output, write=True)
    try:
        for target, path in replacements.items():
            if not dll.SFileAddFileEx(archive.handle, str(path), target.encode('utf8'), 0x80000200, 2, 2):
                raise OSError('Cannot import ' + target)
    finally:
        archive.close()
    archive = build.Archive(dll, output)
    try:
        expected = {**hashes, **{n: sha(p.read_bytes()) for n, p in replacements.items()}}
        for member, digest in expected.items():
            if sha(archive.read(member)) != digest:
                raise AssertionError('Map member mismatch: ' + member)
    finally:
        archive.close()
    import_path.unlink()
    if sha(source.read_bytes()) != source_hash or args.model.read_bytes() != model or args.texture.read_bytes() != texture:
        raise AssertionError('Original input changed')
    report = {'source_map': str(source), 'source_map_sha256': source_hash,
              'output_map': str(output), 'output_map_sha256': sha(output.read_bytes()),
              'original_model_sha256': sha(model), 'original_blp_sha256': sha(texture),
              'model_sha256': sha(patched), 'texture_sha256': sha(tga),
              'model_changed_field': 'TEXS texture path only', 'model_path_byte_range': path_range,
              'material_filter_mode': 'Additive (unchanged)', 'texture': texture_report,
              'unchanged_map_members': len(set(hashes) - set(replacements)),
              'replaced_map_members': sorted(set(hashes) & set(replacements)),
              'added_map_members': sorted(set(replacements) - set(hashes)),
              'script_sha256': hashes['war3map.j'], 'compiler_rerun': False, 'runtime_tested': False}
    (assets / 'report.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf8')
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    for arg in ('source', 'output', 'assets', 'model', 'texture', 'stormlib'):
        parser.add_argument('--' + arg, required=True, type=Path)
    run(parser.parse_args())
