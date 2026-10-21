# 맵을 선택하고 BLP 분석 결과를 검토하여 정리된 복사본을 만드는 화면을 제공한다.
import queue
import sys
import threading
import tkinter as tk
from datetime import datetime
from pathlib import Path
from tkinter import filedialog, messagebox, ttk

from cleaner import analyze, clean, write_report
from mpq import load_library


LABELS = {'candidate': '삭제 후보', 'used': '참조 있음', 'unknown': '판정 불가 · 보존', 'keep': '지정 보존'}


def size_text(value):
    return f'{value / 1024 / 1024:,.2f} MB' if abs(value) >= 1024 * 1024 else f'{value / 1024:,.1f} KB'


class App:
    def __init__(self, root):
        self.root = root
        self.analysis = None
        self.selected = set()
        self.events = queue.Queue()
        self.busy = False
        self.latest_progress = ''
        root.title('ARCANA BLP 정리 도구')
        root.geometry('1120x760')
        root.minsize(900, 650)
        root.protocol('WM_DELETE_WINDOW', self.close)
        style = ttk.Style(root)
        style.theme_use('clam')
        style.configure('.', font=('맑은 고딕', 10))
        style.configure('Treeview', rowheight=29)
        style.configure('Title.TLabel', font=('맑은 고딕', 19, 'bold'))
        outer = ttk.Frame(root, padding=20)
        outer.pack(fill='both', expand=True)
        ttk.Label(outer, text='BLP 정리 도구', style='Title.TLabel').pack(anchor='w')
        ttk.Label(outer, text='사용 흔적을 검사하고 선택한 후보만 새 맵에서 정리합니다. 원본은 보존됩니다.').pack(anchor='w', pady=(4, 16))
        picker = ttk.Frame(outer)
        picker.pack(fill='x')
        self.map_path = tk.StringVar()
        self.path_entry = ttk.Entry(picker, textvariable=self.map_path)
        self.path_entry.pack(side='left', fill='x', expand=True)
        self.browse = ttk.Button(picker, text='맵 선택', command=self.choose_map)
        self.browse.pack(side='left', padx=(8, 0))
        self.scan = ttk.Button(picker, text='분석 시작', command=self.start_scan)
        self.scan.pack(side='left', padx=(8, 0))
        keep_row = ttk.Frame(outer)
        keep_row.pack(fill='x', pady=(10, 12))
        ttk.Label(keep_row, text='추가 보존 패턴').pack(side='left')
        self.keep = tk.StringVar()
        self.keep_entry = ttk.Entry(keep_row, textvariable=self.keep)
        self.keep_entry.pack(side='left', fill='x', expand=True, padx=8)
        ttk.Label(keep_row, text=r'예. MyUI\*; *Portrait*.blp').pack(side='left')
        self.summary = tk.StringVar(value='1. 맵 선택 → 2. 분석 → 3. 후보 확인 → 4. 정리된 복사본 저장')
        ttk.Label(outer, textvariable=self.summary, font=('맑은 고딕', 11, 'bold')).pack(anchor='w', pady=(0, 10))
        actions = ttk.Frame(outer)
        actions.pack(fill='x', pady=(0, 8))
        self.filter = tk.StringVar(value='전체')
        combo = ttk.Combobox(actions, textvariable=self.filter, state='readonly', width=20,
                             values=['전체', *LABELS.values()])
        combo.pack(side='left')
        combo.bind('<<ComboboxSelected>>', lambda _: self.render())
        self.all_button = ttk.Button(actions, text='삭제 후보 모두 선택', command=lambda: self.select_all(True))
        self.all_button.pack(side='left', padx=8)
        self.none_button = ttk.Button(actions, text='선택 해제', command=lambda: self.select_all(False))
        self.none_button.pack(side='left')
        ttk.Label(actions, text='선택 칸을 클릭하거나 Space 키로 변경').pack(side='right')
        frame = ttk.Frame(outer)
        frame.pack(fill='both', expand=True)
        self.table = ttk.Treeview(frame, columns=('selected', 'status', 'name', 'size', 'reason'), show='headings', selectmode='browse')
        for key, text, width in [('selected', '선택', 48), ('status', '분류', 125), ('name', '맵 내부 경로', 360),
                                 ('size', '압축 용량', 90), ('reason', '판정 근거', 350)]:
            self.table.heading(key, text=text)
            self.table.column(key, width=width, minwidth=45, stretch=key in ('name', 'reason'))
        self.table.tag_configure('candidate', foreground='#156344')
        self.table.tag_configure('unknown', foreground='#8b5900')
        scrollbar = ttk.Scrollbar(frame, orient='vertical', command=self.table.yview)
        horizontal = ttk.Scrollbar(frame, orient='horizontal', command=self.table.xview)
        self.table.configure(yscrollcommand=scrollbar.set, xscrollcommand=horizontal.set)
        self.table.grid(row=0, column=0, sticky='nsew')
        scrollbar.grid(row=0, column=1, sticky='ns')
        horizontal.grid(row=1, column=0, sticky='ew')
        frame.rowconfigure(0, weight=1)
        frame.columnconfigure(0, weight=1)
        self.table.bind('<Button-1>', self.click_row)
        self.table.bind('<space>', self.toggle_focused)
        self.table.bind('<<TreeviewSelect>>', self.show_reason)
        self.detail = tk.Text(outer, height=5, wrap='word', font=('맑은 고딕', 10), state='disabled', background='#f4f5f7', relief='flat')
        self.detail.pack(fill='x', pady=(10, 8))
        self.status = tk.StringVar(value='정적 분석으로 실제 게임의 미사용을 100% 증명할 수는 없습니다.')
        ttk.Label(outer, textvariable=self.status, wraplength=1040).pack(anchor='w')
        self.progress = ttk.Progressbar(outer, mode='indeterminate')
        self.progress.pack(fill='x', pady=(8, 12))
        bottom = ttk.Frame(outer)
        bottom.pack(fill='x')
        self.selection_label = tk.StringVar(value='선택한 파일 없음')
        ttk.Label(bottom, textvariable=self.selection_label).pack(side='left')
        self.save = ttk.Button(bottom, text='정리된 복사본 저장', command=self.start_clean, state='disabled')
        self.save.pack(side='right')
        self.report_button = ttk.Button(bottom, text='분석 보고서 저장', command=self.save_report, state='disabled')
        self.report_button.pack(side='right', padx=8)
        self.controls = [self.path_entry, self.keep_entry, self.browse, self.scan, self.all_button, self.none_button]
        root.after(100, self.poll)

    def choose_map(self):
        path = filedialog.askopenfilename(title='정리할 맵 선택', filetypes=[('Warcraft III 맵', '*.w3x *.w3m')])
        if path:
            self.map_path.set(path)
            self.analysis = None
            self.selected.clear()
            self.render()

    def set_detail(self, text):
        self.detail.configure(state='normal')
        self.detail.delete('1.0', 'end')
        self.detail.insert('1.0', text)
        self.detail.configure(state='disabled')

    def set_busy(self, busy):
        self.busy = busy
        for control in self.controls:
            control.configure(state='disabled' if busy else 'normal')
        if busy:
            self.progress.start(12)
        else:
            self.progress.stop()
        self.update_selection()

    def worker(self, operation, callback):
        self.latest_progress = ''
        self.set_busy(True)
        def run():
            try:
                value = operation(lambda text: setattr(self, 'latest_progress', text))
                self.events.put(('done', callback, value))
            except Exception as exc:
                self.events.put(('error', str(exc)))
        threading.Thread(target=run, daemon=True).start()

    def poll(self):
        if self.busy and self.latest_progress:
            self.status.set(self.latest_progress)
        try:
            while True:
                event = self.events.get_nowait()
                self.set_busy(False)
                if event[0] == 'error':
                    self.status.set('작업을 완료하지 못했습니다.')
                    messagebox.showerror('작업 중단', event[1])
                else:
                    event[1](event[2])
        except queue.Empty:
            pass
        self.root.after(100, self.poll)

    def start_scan(self):
        path = self.map_path.get().strip()
        if not path:
            messagebox.showinfo('맵 선택', '먼저 분석할 맵을 선택하세요.')
            return
        keep = [part.strip() for part in self.keep.get().split(';') if part.strip()]
        self.analysis = None
        self.selected.clear()
        self.render()
        self.worker(lambda progress: analyze(path, load_library(), keep, progress), self.scanned)

    def scanned(self, analysis):
        self.analysis = analysis
        self.selected = {row.name for row in analysis.textures if row.status == 'candidate'}
        report = analysis.report()
        self.summary.set(f'BLP {len(analysis.textures):,}개 · 삭제 후보 {report["candidate_count"]:,}개 · '
                         f'후보 압축 용량 {size_text(report["candidate_compressed_bytes"])}')
        self.status.set('분석 완료. 후보 용량과 실제 맵 절약 용량은 재압축 결과에 따라 다릅니다.')
        self.set_detail('\n'.join(analysis.blockers) if analysis.blockers else
                        '판정 근거를 확인하고 지울 후보만 선택하세요. 기본 게임 경로와 판정 불가 파일은 보존합니다.\n'
                        '추가 보존 패턴이나 맵 경로를 수정했다면 다시 분석해야 적용됩니다.')
        self.render()

    def render(self):
        self.table.delete(*self.table.get_children())
        if self.analysis:
            for index, row in enumerate(self.analysis.textures):
                if self.filter.get() not in ('전체', LABELS[row.status]):
                    continue
                checked = '☑' if row.name in self.selected else ('☐' if row.status == 'candidate' else '—')
                self.table.insert('', 'end', iid=str(index), values=(checked, LABELS[row.status], row.name,
                                  size_text(row.compressed_size), '; '.join(row.reasons)), tags=(row.status,))
        self.update_selection()

    def update_selection(self):
        size = sum(row.compressed_size for row in self.analysis.textures if row.name in self.selected) if self.analysis else 0
        self.selection_label.set(f'선택 {len(self.selected):,}개 · 압축 용량 {size_text(size)}')
        self.save.configure(state='normal' if self.analysis and self.selected and not self.busy else 'disabled')
        self.report_button.configure(state='normal' if self.analysis and not self.busy else 'disabled')

    def select_all(self, select):
        self.selected = {row.name for row in self.analysis.textures if row.status == 'candidate'} if select and self.analysis else set()
        self.render()

    def click_row(self, event):
        if self.table.identify_column(event.x) == '#1':
            self.toggle(self.table.identify_row(event.y))

    def toggle_focused(self, _event):
        self.toggle(self.table.focus())
        return 'break'

    def toggle(self, row_id):
        if self.busy or not self.analysis or not row_id:
            return
        row = self.analysis.textures[int(row_id)]
        if row.status != 'candidate':
            return
        if row.name in self.selected:
            self.selected.remove(row.name)
        else:
            self.selected.add(row.name)
        self.table.set(row_id, 'selected', '☑' if row.name in self.selected else '☐')
        self.update_selection()

    def show_reason(self, _event):
        selection = self.table.selection()
        if self.analysis and selection:
            row = self.analysis.textures[int(selection[0])]
            self.set_detail(row.name + '\n' + '\n'.join(row.reasons) +
                            ('\n' + '\n'.join(self.analysis.blockers) if row.status == 'unknown' else ''))

    def inputs_current(self):
        keep = [part.strip() for part in self.keep.get().split(';') if part.strip()]
        if Path(self.map_path.get()).resolve() != self.analysis.source or keep != self.analysis.keep:
            messagebox.showinfo('다시 분석', '맵 경로나 보존 패턴을 변경했습니다. 다시 분석하세요.')
            return False
        return True

    def start_clean(self):
        if not self.analysis or not self.selected or not self.inputs_current():
            return
        source = self.analysis.source
        output = filedialog.asksaveasfilename(title='정리된 맵을 새 이름으로 저장',
                                              initialdir=source.parent, initialfile=source.stem + '_BLP정리' + source.suffix,
                                              defaultextension=source.suffix, filetypes=[('Warcraft III 맵', '*' + source.suffix)])
        if not output:
            return
        if Path(output).exists():
            messagebox.showerror('다른 이름 필요', '기존 파일은 덮어쓰지 않습니다. 새 이름을 지정하세요.')
            return
        selected = set(self.selected)
        self.worker(lambda progress: clean(self.analysis, selected, output, load_library(), progress), self.cleaned)

    def cleaned(self, result):
        report = self.analysis.report()
        report['cleanup'] = result
        report_path = Path(result['output'] + '.blp-report-' + datetime.now().strftime('%Y%m%d-%H%M%S-%f') + '.json')
        note = ''
        try:
            write_report(report_path, report)
            note = '\n보고서. ' + str(report_path)
        except OSError as exc:
            note = '\n맵 저장은 완료했지만 보고서 저장에 실패했습니다. ' + str(exc)
        self.status.set(f'정리 완료. {len(result["removed"])}개 삭제 · 실제 절약 {size_text(result["saved_bytes"])}')
        messagebox.showinfo('정리 완료', result['output'] + '\n원본과 남은 파일의 내용 보존을 확인했습니다.' +
                            '\n게임 내 화면과 플레이는 정리된 맵에서 확인하세요.' + note)

    def save_report(self):
        if not self.analysis or not self.inputs_current():
            return
        path = filedialog.asksaveasfilename(title='분석 보고서 저장', defaultextension='.json',
                                            initialfile=self.analysis.source.stem + '_BLP분석.json',
                                            filetypes=[('JSON 보고서', '*.json')])
        if path:
            try:
                write_report(path, self.analysis.report())
                self.status.set('분석 보고서 저장 완료. ' + path)
            except OSError as exc:
                messagebox.showerror('보고서 저장 실패', str(exc))

    def close(self):
        if self.busy:
            messagebox.showinfo('작업 중', '현재 작업이 끝난 뒤 창을 닫아주세요.')
        else:
            self.root.destroy()


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == '--cli':
        from cleaner import main
        sys.argv.pop(1)
        main()
    else:
        window = tk.Tk()
        App(window)
        window.mainloop()
