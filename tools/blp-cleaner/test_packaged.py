# 배포 EXE가 내장 런타임과 DLL만으로 실제 맵 정리 및 실패 보고를 수행하는지 검사한다.
import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

from cleaner import file_digest
from mpq import Archive, load_library
from test_cleaner import imports, model


@unittest.skipUnless(os.name == 'nt' and os.environ.get('BLP_PACKAGED_EXE') and
                     os.environ.get('STORMLIB_PATH'), '패키징된 EXE 경로와 StormLib 필요')
class PackagedTests(unittest.TestCase):
    def run_exe(self, dynamic=False):
        with tempfile.TemporaryDirectory(prefix='배포 EXE 검사 ') as folder:
            source = Path(folder) / '원본.w3x'
            output = Path(folder) / '정리.w3x'
            report_path = Path(folder) / '결과.json'
            dll = load_library(os.environ['STORMLIB_PATH'])
            script = b'function main takes nothing returns nothing\nendfunction\n'
            if dynamic:
                script += b'call DzFrameSetTexture(f, unresolved, 0)\n'
            with Archive(dll, source, create=True) as archive:
                for name, data in {
                    b'war3map.j': script, b'unit.mdx': model(), b'used.blp': b'BLP1retained',
                    b'free.blp': b'BLP1' + os.urandom(8192),
                    b'war3map.imp': imports([(13, b'free.blp'), (13, b'used.blp')]),
                }.items():
                    archive.put(name, data)
            original_hash = file_digest(source)
            result = subprocess.run([os.environ['BLP_PACKAGED_EXE'], '--cli', str(source),
                                     '--output', str(output), '--report', str(report_path)],
                                    cwd=folder, timeout=45, creationflags=subprocess.CREATE_NO_WINDOW)
            self.assertEqual(file_digest(source), original_hash)
            report = json.loads(report_path.read_text(encoding='utf-8'))
            if dynamic:
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('error', report)
                self.assertFalse(output.exists())
            else:
                self.assertEqual(result.returncode, 0)
                self.assertEqual(report['cleanup']['removed'], ['free.blp'])
                self.assertGreater(report['cleanup']['saved_bytes'], 7000)
                with Archive(dll, output) as archive:
                    self.assertEqual(archive.read(b'used.blp'), b'BLP1retained')
                    self.assertEqual(archive.read(b'war3map.j'), script)

    def test_executable_cleans_with_embedded_library(self):
        self.run_exe()

    def test_executable_blocks_unknown_references_and_writes_error(self):
        self.run_exe(dynamic=True)


if __name__ == '__main__':
    unittest.main(verbosity=2)
