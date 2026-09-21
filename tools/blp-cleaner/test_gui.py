# GUI의 선택과 보존 동작 및 입력 변경 후 재분석 요구를 검증한다.
import os
import unittest
from pathlib import Path
from unittest.mock import patch

from cleaner import Analysis, Texture


@unittest.skipUnless(os.environ.get('BLP_GUI_TESTS') == '1', 'GUI 검사는 BLP_GUI_TESTS=1로 실행')
class GuiTests(unittest.TestCase):
    def setUp(self):
        import tkinter as tk
        from app import App
        self.root = tk.Tk()
        self.root.withdraw()
        self.app = App(self.root)
        source = Path('example.w3x').resolve()
        self.app.map_path.set(str(source))
        self.analysis = Analysis(source, 'hash', 123, [], {}, [
            Texture('free.blp', 10, 8, 'candidate', ['unused']),
            Texture('used.blp', 20, 12, 'used', ['reference']),
            Texture('maybe.blp', 30, 16, 'unknown', ['dynamic'])], [], [])
        self.app.scanned(self.analysis)
        self.root.update_idletasks()

    def tearDown(self):
        self.root.destroy()

    def test_only_candidates_can_be_selected(self):
        self.assertEqual(self.app.selected, {'free.blp'})
        self.app.toggle('1')
        self.app.toggle('2')
        self.assertEqual(self.app.selected, {'free.blp'})
        self.app.toggle('0')
        self.assertFalse(self.app.selected)
        self.assertEqual(str(self.app.save['state']), 'disabled')
        self.app.select_all(True)
        self.assertEqual(self.app.selected, {'free.blp'})

    def test_filter_preserves_selection(self):
        self.app.filter.set('참조 있음')
        self.app.render()
        self.assertEqual(self.app.table.get_children(), ('1',))
        self.assertEqual(self.app.selected, {'free.blp'})

    def test_changed_inputs_and_busy_state(self):
        self.app.keep.set('free.*')
        with patch('app.messagebox.showinfo'):
            self.assertFalse(self.app.inputs_current())
        self.app.set_busy(True)
        self.assertEqual(str(self.app.save['state']), 'disabled')
        self.app.toggle('0')
        self.assertEqual(self.app.selected, {'free.blp'})
        self.app.set_busy(False)


if __name__ == '__main__':
    unittest.main(verbosity=2)
