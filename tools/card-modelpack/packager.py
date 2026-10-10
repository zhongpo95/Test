# 폴더와 저장 위치를 선택해 로더 통합 ASI를 만드는 독립 Windows 프로그램이다.
import argparse
import json
import queue
import sys
import threading
from pathlib import Path

from build import build_pack, collect_files


def bundled(name):
    return Path(getattr(sys, '_MEIPASS', Path(__file__).parent)) / name


def gui():
    import tkinter as tk
    from tkinter import filedialog, messagebox, ttk

    root = tk.Tk()
    root.title('ARCANA ASI 제작기')
    root.geometry('760x530')
    root.minsize(650, 500)
    root.option_add('*Font', ('맑은 고딕', 10))
    style = ttk.Style(root)
    style.theme_use('vista')
    panel = ttk.Frame(root, padding=24)
    panel.pack(fill='both', expand=True)
    panel.columnconfigure(1, weight=1)
    ttk.Label(panel, text='폴더를 하나의 ASI로', font=('맑은 고딕', 19, 'bold')).grid(row=0, column=0, columnspan=3, sticky='w', pady=(0, 8))
    ttk.Label(panel, text='하위 폴더와 모든 파일을 압축합니다. 실행 로더도 ASI 안에 포함됩니다.').grid(row=1, column=0, columnspan=3, sticky='w', pady=(0, 24))
    source, output, prefix = tk.StringVar(), tk.StringVar(), tk.StringVar()
    events, busy, controls = queue.Queue(), False, []

    def preview():
        try:
            rows = collect_files(source.get(), prefix.get())
            size = sum(row['bytes'] for row in rows) / 1024 / 1024
            summary.set(f'{len(rows):,}개 파일 · 원본 {size:,.1f} MB')
            paths.configure(state='normal')
            paths.delete('1.0', 'end')
            paths.insert('end', '\n'.join(row['name'] for row in rows[:12]))
            if len(rows) > 12:
                paths.insert('end', f'\n… 외 {len(rows) - 12:,}개')
            paths.configure(state='disabled')
        except Exception as error:
            summary.set(str(error))

    def choose_source():
        folder = filedialog.askdirectory(title='ASI에 넣을 파일이 있는 폴더 선택')
        if folder:
            source.set(folder)
            if not output.get():
                output.set(str(Path(folder).parent / 'Arcana_A.asi'))
            preview()

    def choose_output():
        filename = filedialog.asksaveasfilename(title='ASI 저장 위치', initialfile='Arcana_A.asi',
                                              defaultextension='.asi', filetypes=[('ASI 팩', '*.asi')])
        if filename:
            output.set(filename)

    for row, label, variable, command in ((2, '입력 폴더', source, choose_source), (3, '저장 파일', output, choose_output)):
        ttk.Label(panel, text=label).grid(row=row, column=0, sticky='w', padx=(0, 14), pady=6)
        entry = ttk.Entry(panel, textvariable=variable)
        entry.grid(row=row, column=1, sticky='ew', pady=6)
        button = ttk.Button(panel, text='찾아보기', command=command)
        button.grid(row=row, column=2, padx=(10, 0), pady=6)
        controls.extend((entry, button))
    ttk.Label(panel, text='경로 앞부분').grid(row=4, column=0, sticky='w', padx=(0, 14), pady=6)
    prefix_entry = ttk.Entry(panel, textvariable=prefix)
    prefix_entry.grid(row=4, column=1, columnspan=2, sticky='ew', pady=6)
    controls.append(prefix_entry)
    ttk.Label(panel, text='보통 비워 둡니다. war3mapImported 폴더 자체를 골랐다면 war3mapImported를 입력하세요.',
              wraplength=660).grid(row=5, column=0, columnspan=3, sticky='w', pady=(2, 12))
    summary = tk.StringVar(value='입력 폴더를 선택해 주세요.')
    ttk.Label(panel, textvariable=summary).grid(row=6, column=0, columnspan=3, sticky='w', pady=(0, 6))
    paths = tk.Text(panel, height=7, wrap='none', relief='solid', borderwidth=1, state='disabled')
    paths.grid(row=7, column=0, columnspan=3, sticky='nsew')
    panel.rowconfigure(7, weight=1)
    status = tk.StringVar(value='원본은 수정하지 않으며, 이미 있는 ASI를 덮어쓰지 않습니다.')
    ttk.Label(panel, textvariable=status, wraplength=660).grid(row=8, column=0, columnspan=3, sticky='w', pady=(12, 4))
    bar = ttk.Progressbar(panel, maximum=100)
    bar.grid(row=9, column=0, columnspan=3, sticky='ew', pady=(0, 12))

    def start():
        nonlocal busy
        if not source.get() or not output.get():
            messagebox.showerror('입력 확인', '입력 폴더와 저장 파일을 지정해 주세요.')
            return
        values = (source.get(), output.get(), prefix.get())
        busy = True
        for widget in controls:
            widget.configure(state='disabled')
        bar['value'] = 0
        status.set('파일 목록을 확인하고 있습니다.')

        def worker():
            try:
                def progress(stage, index, total, name):
                    if index == 1 or index == total or index % max(1, total // 100) == 0:
                        events.put(('progress', (stage, index, total, name)))
                report = build_pack(values[0], values[1], bundled('loader.dll'), bundled('StormLib.dll'), values[2], progress)
                events.put(('done', (values[1], report)))
            except Exception as error:
                events.put(('error', str(error)))
        threading.Thread(target=worker, daemon=True).start()

    create = ttk.Button(panel, text='ASI 만들기', command=start)
    create.grid(row=10, column=0, columnspan=3, sticky='e')
    controls.append(create)
    prefix_entry.bind('<FocusOut>', lambda event: preview() if source.get() else None)

    def poll():
        nonlocal busy
        try:
            while True:
                kind, value = events.get_nowait()
                if kind == 'progress':
                    stage, index, total, name = value
                    bar['value'] = (0 if stage == '압축' else 50) + 50 * index / total
                    status.set(f'{stage} {index:,}/{total:,} · {name}')
                else:
                    busy = False
                    for widget in controls:
                        widget.configure(state='normal')
                    if kind == 'done':
                        filename, report = value
                        bar['value'] = 100
                        status.set(f"완료 · {report['files']:,}개 파일 · {report['asiBytes'] / 1024 / 1024:,.1f} MB · 원본 검증 통과")
                        messagebox.showinfo('ASI 생성 완료', filename + '\n\n별도 로더 파일 없이 이 ASI 하나를 배포하면 됩니다.')
                    else:
                        status.set('생성 실패 · 원본과 기존 출력 파일은 보존됩니다.')
                        messagebox.showerror('ASI 생성 실패', value)
        except queue.Empty:
            pass
        root.after(100, poll)

    def close():
        if busy:
            messagebox.showinfo('작업 중', '압축과 검증이 끝난 뒤 닫아 주세요.')
        else:
            root.destroy()
    root.protocol('WM_DELETE_WINDOW', close)
    poll()
    root.mainloop()


def main():
    parser = argparse.ArgumentParser(description='폴더 전체를 로더 통합 ASI로 묶습니다.')
    parser.add_argument('--source', type=Path)
    parser.add_argument('--output', type=Path)
    parser.add_argument('--prefix', default='')
    parser.add_argument('--report', type=Path)
    args = parser.parse_args()
    if not args.source:
        gui()
        return
    if not args.output:
        parser.error('--source를 사용하면 --output도 필요합니다.')
    report = build_pack(args.source, args.output, bundled('loader.dll'), bundled('StormLib.dll'), args.prefix)
    if args.report:
        with args.report.open('x', encoding='utf8') as stream:
            stream.write(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    if sys.stdout:
        print(json.dumps(report, ensure_ascii=False))


if __name__ == '__main__':
    main()
