# 참조 누락과 원본 손상 방지를 합성 맵 및 실제 StormLib으로 검증한다.
import ctypes as c
import os
import struct
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from cleaner import analyze, clean, file_digest, import_entries, prune_imports, write_report
from mpq import Archive, load_library
from references import builtin_reason, decode_text, matches_pattern, mdx_textures, script_patterns, text_views


def imports(entries):
    return struct.pack('<II', 1, len(entries)) + b''.join(bytes([flag]) + name + b'\0' for flag, name in entries)


def model(texture=b'used.blp'):
    record = struct.pack('<I', 0) + texture.ljust(260, b'\0') + struct.pack('<I', 0)
    return b'MDLXVERS\x04\0\0\0' + struct.pack('<I', 800) + b'TEXS' + struct.pack('<I', len(record)) + record


class ReferenceTests(unittest.TestCase):
    def test_mdx_texture_and_corruption(self):
        self.assertEqual(mdx_textures(model()), [b'used.blp'])
        for invalid in [model()[:-1], b'MDLX', b'xxxx' + model()[4:]]:
            with self.assertRaises(ValueError):
                mdx_textures(invalid)

    def test_import_registration_is_removable_and_other_bytes_unchanged(self):
        data = imports([(5, b'a.blp'), (13, b'custom\\b.blp'), (8, b'c.mdx')])
        self.assertEqual(import_entries(data)[0][0], b'war3mapimported\\a.blp')
        self.assertEqual(prune_imports(data, [b'WAR3MAPIMPORTED/A.BLP']),
                         imports([(13, b'custom\\b.blp'), (8, b'c.mdx')]))
        self.assertEqual(prune_imports(imports([(0, b'a.blp'), (1, b'b.blp')]),
                                      [b'war3mapImported\\a.blp']), imports([(1, b'b.blp')]))

    def test_import_truncation_and_unknown_flag(self):
        for data in [b'', imports([(13, b'a.blp')])[:-1], imports([(99, b'a.blp')]),
                     imports([]) + b'bad', struct.pack('<II', 2, 0)]:
            with self.assertRaises(ValueError):
                import_entries(data)

    def test_builtin_and_automatic_icons(self):
        for path in ['Textures\\unused.blp', 'UI\\Console\\skin.blp',
                     'DISBTNIcon.blp', 'war3mapPreview.blp']:
            self.assertIsNotNone(builtin_reason(path))
        self.assertIsNone(builtin_reason('war3mapImported\\free.blp'))

    def test_script_literal_and_constant_concatenation(self):
        patterns, unknown = script_patterns(r'call DzFrameSetTexture(f, "war3mapImported\\a" + "b.blp", 0)')
        self.assertEqual(unknown, [])
        self.assertIn('war3mapimported\\ab.blp', patterns)

    def test_array_domain_and_numeric_pattern(self):
        source = r'''
set icons[0] = "one.blp"
set icons[1] = "two.blp"
call DzFrameSetTexture(f, icons[index], 0)
call DzFrameSetTexture(f, "frames\\f" + I2S(n) + ".blp", 0)
'''
        patterns, unknown = script_patterns(source)
        self.assertEqual(unknown, [])
        self.assertEqual(patterns, {'one.blp', 'two.blp', 'frames\\f*.blp'})
        self.assertTrue(matches_pattern('frames/f007.blp', 'frames\\f*.blp'))
        self.assertFalse(matches_pattern('other.blp', 'frames\\f*.blp'))

    def test_unresolved_function_parameters_are_not_resolved_from_other_scopes(self):
        source = '''string path = "a.blp"
function F takes string path returns nothing
call DzFrameSetTexture(f, path, 0)
endfunction'''
        self.assertEqual(script_patterns(source)[1], ['DzFrameSetTexture'])

    def test_unknown_variable_return_and_cycle(self):
        for expression in ['missing', 'GetTexture()', 'cycle', 'I2S(x)', '"\\x61.blp"']:
            source = 'set cycle = cycle\ncall DzFrameSetTexture(f, ' + expression + ', 0)'
            self.assertTrue(script_patterns(source)[1], expression)

    def test_comments_do_not_create_unknown_calls(self):
        source = '// call DzFrameSetTexture(f, missing, 0)\ncall DzFrameSetTexture(f, "a.blp", 0)'
        self.assertEqual(script_patterns(source), ({'a.blp'}, []))

    def test_lua_path_and_dynamic_loader(self):
        self.assertEqual(script_patterns('BlzFrameSetTexture(f, "a" .. tostring(n) .. ".blp", 0, true)'),
                         ({'a*.blp'}, []))
        self.assertTrue(script_patterns('load("dynamic")')[1])
        self.assertTrue(script_patterns('local setter = BlzFrameSetTexture\nsetter(f, path, 0, true)')[1])
        self.assertTrue(script_patterns('path = "a.blp"\nBlzFrameSetTexture(f,path,0,true)', allow_assignments=False)[1])

    def test_item_string_field_path_is_not_missed(self):
        self.assertEqual(script_patterns('call BlzSetItemStringField(item, ITEM_SF_ICON, "f" + "ree.blp")'),
                         ({'free.blp'}, []))
        self.assertTrue(script_patterns('call BlzSetItemStringField(item, field, unresolved)')[1])

    def test_binary_and_legacy_encoding_references(self):
        for encoding in ['utf-8', 'cp949', 'utf-16-le', 'utf-16-be']:
            for prefix in (b'\0\xff', b'\0'):
                data = prefix + '효과\\아이콘.blp'.encode(encoding) + b'\0'
                self.assertTrue(any('아이콘.blp' in view for view in text_views(data)))
        with self.assertRaises(ValueError):
            decode_text(b'\x1bLua\0')

    def test_extension_substitution(self):
        self.assertTrue(matches_pattern('x.blp', 'x.tga'))
        self.assertTrue(matches_pattern('x.blp', 'x'))
        self.assertTrue(matches_pattern('icon[1].blp', 'icon[*].blp'))

    def test_unsupported_assignment_is_not_ignored(self):
        source = 'path = "a.blp"\nif ready then path = buildPath() end\nBlzFrameSetTexture(f,path,0,true)'
        self.assertTrue(script_patterns(source)[1])

    def test_report_never_overwrites(self):
        with tempfile.TemporaryDirectory() as work:
            path = Path(work) / 'original.w3x'
            path.write_bytes(b'original')
            with self.assertRaises(FileExistsError):
                write_report(path, {})
            self.assertEqual(path.read_bytes(), b'original')


@unittest.skipUnless(os.name == 'nt' and os.environ.get('STORMLIB_PATH'), 'Windows와 STORMLIB_PATH 필요')
class ArchiveTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.dll = load_library(os.environ['STORMLIB_PATH'])

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='BLP 도구 검사 ')
        self.root = Path(self.temp.name)
        self.source = self.root / '원본 맵.w3x'
        self.output = self.root / '정리 맵.w3x'
        self.assets = {
            b'war3map.j': b'function main takes nothing returns nothing\nendfunction\n',
            b'model.mdx': model(b'used.blp'),
            b'used.blp': b'BLP1' + os.urandom(2048),
            b'free.blp': b'BLP1' + os.urandom(16384),
            b'war3mapImported\\unused.blp': b'BLP1' + os.urandom(4096),
            b'war3map.imp': imports([(13, b'used.blp'), (13, b'free.blp'), (5, b'unused.blp')]),
        }
        with Archive(self.dll, self.source, create=True) as archive:
            for name, data in self.assets.items():
                archive.put(name, data)
        self.original = self.source.read_bytes()

    def tearDown(self):
        self.temp.cleanup()

    def add(self, name, data, locale=0):
        with Archive(self.dll, self.source, write=True) as archive:
            archive.put(name, data, locale)

    def scan(self):
        return analyze(self.source, self.dll)

    def test_real_mpq_clean_preserves_source_and_every_remaining_member(self):
        analysis = self.scan()
        self.assertEqual(analysis.blockers, [])
        candidates = {row.name for row in analysis.textures if row.status == 'candidate'}
        self.assertEqual(candidates, {'free.blp', 'war3mapImported\\unused.blp'})
        result = clean(analysis, candidates, self.output, self.dll)
        self.assertGreater(result['saved_bytes'], 12000)
        self.assertEqual(self.source.read_bytes(), self.original)
        with Archive(self.dll, self.output) as archive:
            self.assertEqual(archive.read(b'used.blp'), self.assets[b'used.blp'])
            self.assertEqual(archive.read(b'war3map.j'), self.assets[b'war3map.j'])
            self.assertEqual(archive.read(b'war3map.imp'), imports([(13, b'used.blp')]))
            self.assertFalse(archive.exists(b'free.blp'))
        self.assertEqual(result['output_sha256'], file_digest(self.output))

    def test_partial_selection_keeps_unselected_candidates(self):
        clean(self.scan(), ['free.blp'], self.output, self.dll)
        with Archive(self.dll, self.output) as archive:
            self.assertTrue(archive.exists(b'war3mapImported\\unused.blp'))

    def test_direct_object_script_ui_and_builtin_references(self):
        self.add(b'war3map.w3u', b'\2\0\0\0' + b'free.blp\0')
        self.add(b'UI\\layout.fdf', b'BackdropBackground "war3mapImported\\unused.blp",')
        self.add(b'Textures\\override.blp', b'BLP1test')
        analysis = self.scan()
        statuses = {row.name: row.status for row in analysis.textures}
        self.assertEqual(statuses['free.blp'], 'used')
        self.assertEqual(statuses['war3mapImported\\unused.blp'], 'used')
        self.assertEqual(statuses['Textures\\override.blp'], 'unknown')

    def test_dynamic_fragment_reference_is_kept(self):
        self.add(b'war3map.j', self.assets[b'war3map.j'] +
                 b'call DzFrameSetTexture(f, "fr" + "ee.blp", 0)\n')
        self.assertEqual(next(row for row in self.scan().textures if row.name == 'free.blp').status, 'used')

    def test_unknown_dynamic_path_blocks_clean(self):
        self.add(b'war3map.j', self.assets[b'war3map.j'] + b'call DzFrameSetTexture(f, missing, 0)\n')
        analysis = self.scan()
        self.assertTrue(analysis.blockers)
        self.assertFalse(any(row.status == 'candidate' for row in analysis.textures))
        with self.assertRaises(ValueError):
            clean(analysis, ['free.blp'], self.output, self.dll)
        self.assertFalse(self.output.exists())

    def test_corrupt_model_blocks_clean(self):
        self.add(b'broken.mdx', b'MDLXbad')
        self.assertTrue(self.scan().blockers)

    def test_invalid_import_table_blocks_clean(self):
        self.add(b'war3map.imp', b'invalid')
        self.assertTrue(self.scan().blockers)

    def test_protected_script_blocks_clean(self):
        self.add(b'Kkmap.jc', b'encrypted script')
        self.assertTrue(self.scan().blockers)

    def test_locale_blocks_clean(self):
        self.add(b'used.blp', b'BLP1localized', 1042)
        self.assertTrue(self.scan().blockers)

    def test_missing_listfile_blocks_clean(self):
        self.source = self.root / '목록 없는 맵.w3x'
        class CreateInfo(c.Structure):
            _fields_ = [('size', c.c_uint32), ('version', c.c_uint32), ('data', c.c_void_p),
                        *[(name, c.c_uint32) for name in ('data_size', 'stream', 'listfile', 'attributes',
                          'signature', 'attr_flags', 'sector_size', 'chunk_size', 'max_files')]]
        info = CreateInfo()
        info.size, info.sector_size, info.max_files = c.sizeof(info), 4096, 64
        handle = c.c_void_p()
        self.dll.SFileCreateArchive2.argtypes = [c.c_wchar_p, c.POINTER(CreateInfo), c.POINTER(c.c_void_p)]
        self.dll.SFileCreateArchive2.restype = c.c_bool
        self.assertTrue(self.dll.SFileCreateArchive2(str(self.source), c.byref(info), c.byref(handle)))
        self.assertTrue(self.dll.SFileCloseArchive(handle))
        with Archive(self.dll, self.source, write=True) as archive:
            for name, data in self.assets.items():
                archive.put(name, data)
        self.assertTrue(self.scan().blockers)

    def test_map_prefix_is_preserved(self):
        prefix = b'HM3W' + b'BLP cleaner fixture'.ljust(508, b'\0')
        self.source.write_bytes(prefix + self.source.read_bytes())
        clean(self.scan(), ['free.blp'], self.output, self.dll)
        self.assertEqual(self.output.read_bytes()[:512], prefix)

    def test_incomplete_listing_blocks_clean(self):
        original = Archive.members
        with patch.object(Archive, 'members', lambda obj: [m for m in original(obj) if m.raw_name != b'model.mdx']):
            self.assertTrue(self.scan().blockers)

    def test_verification_failure_prevents_publishing(self):
        analysis = self.scan()
        original = Archive.read
        def corrupted_read(archive, member, **kwargs):
            data = original(archive, member, **kwargs)
            if hasattr(member, 'raw_name') and member.raw_name == b'used.blp':
                return b'corruption'
            return data
        with patch.object(Archive, 'read', corrupted_read):
            with self.assertRaises(ValueError):
                clean(analysis, ['free.blp'], self.output, self.dll)
        self.assertFalse(self.output.exists())
        self.assertEqual(self.source.read_bytes(), self.original)

    def test_keep_glob(self):
        analysis = analyze(self.source, self.dll, ['free.*', 'WAR3MAPIMPORTED/*'])
        self.assertEqual(sum(row.status == 'candidate' for row in analysis.textures), 0)

    def test_stale_analysis_and_existing_output_are_rejected(self):
        analysis = self.scan()
        with self.assertRaises(ValueError):
            clean(analysis, ['free.blp'], self.source, self.dll)
        self.output.write_bytes(b'do not touch')
        with self.assertRaises(ValueError):
            clean(analysis, ['free.blp'], self.output, self.dll)
        self.assertEqual(self.output.read_bytes(), b'do not touch')
        self.add(b'new.txt', b'changed')
        with self.assertRaises(ValueError):
            clean(analysis, ['free.blp'], self.root / 'new.w3x', self.dll)

    def test_used_or_injected_selection_rejected(self):
        analysis = self.scan()
        for selected in [['used.blp'], ['war3map.j'], [], ['missing.blp']]:
            with self.assertRaises(ValueError):
                clean(analysis, selected, self.output, self.dll)

    def test_failure_leaves_no_output_or_staging(self):
        analysis = self.scan()
        with patch.object(Archive, 'compact', side_effect=RuntimeError('injected compact failure')):
            with self.assertRaises(RuntimeError):
                clean(analysis, ['free.blp'], self.output, self.dll)
        self.assertFalse(self.output.exists())
        self.assertEqual(self.source.read_bytes(), self.original)
        self.assertEqual(sorted(p.name for p in self.root.iterdir()), [self.source.name])


if __name__ == '__main__':
    unittest.main(verbosity=2)
