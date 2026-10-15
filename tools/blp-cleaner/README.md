# ARCANA BLP 정리 도구

Warcraft III `.w3x` / `.w3m` 안의 BLP 사용 흔적을 검사하고, 선택한 삭제 후보를 제거한 **새 맵**을 만드는 Windows 64비트 도구입니다. 게임 스크립트에 설치하거나 가져오기 할 필요가 없습니다.

## 실행 방법

1. `ArcanaBLPCleaner.exe`를 실행합니다. 배포 EXE에는 Python과 StormLib이 포함되어 있습니다.
2. **맵 선택 → 분석 시작**을 누릅니다.
3. 파일별 판정 근거를 확인합니다. 삭제 후보는 기본 선택되며, 선택 칸이나 Space 키로 보존할 파일을 제외할 수 있습니다.
4. **정리된 복사본 저장**을 누르고 새 이름을 지정합니다.
5. 결과 맵과 함께 저장되는 JSON 보고서에서 삭제 목록, 실제 절약 용량, 보존 파일 검사 결과를 확인합니다.

`추가 보존 패턴`에는 `MyUI\*; *Portrait*.blp`처럼 세미콜론으로 구분한 패턴을 넣을 수 있습니다. 맵 경로 또는 패턴을 바꿨다면 다시 분석해야 적용됩니다. **분석 보고서 저장**은 맵을 수정하지 않습니다.

## 분류 기준과 한계

| 분류 | 처리 |
| --- | --- |
| 삭제 후보 | 검사한 내용에서 사용 흔적이 없는 BLP. 선택한 파일만 제거합니다. |
| 참조 있음 | 모델·오브젝트·스크립트·UI·기타 파일에서 파일명 또는 경로 사용 흔적을 찾았습니다. |
| 판정 불가 · 보존 | 기본 경로 교체, 자동 아이콘, 읽기 실패 또는 미해결 동적 참조 등. 삭제할 수 없습니다. |
| 지정 보존 | 사용자가 지정한 보존 패턴과 일치합니다. |

- MDX 청크와 TEXS 구조를 검사합니다. 모든 모델을 보존 대상으로 취급하므로 사용하지 않는 모델이 참조하는 BLP도 남깁니다. 모델 자체를 지우는 도구는 아닙니다.
- MPQ에서 압축을 해제한 파일의 문자열을 검색합니다. 오브젝트 바이너리, SLK/TXT/WTS, FDF/TOC, JASS/Lua와 MDL도 검색 대상입니다. 오브젝트 필드의 실행 여부까지 추적하지는 않습니다.
- UTF-8, CP949, GB18030, UTF-16 문자열과 슬래시·대소문자 차이를 고려합니다. 확장자 없는 경로, TGA 지정으로 읽히는 BLP, 같은 이름의 다른 폴더도 보수적으로 보존합니다. 부분 문자열이나 주석만 일치해도 보존될 수 있습니다.
- `war3map.imp`와 `(listfile)`에 이름이 있다는 사실만으로는 사용 중이라고 판단하지 않습니다.
- `Textures`, `ReplaceableTextures`, `Units`, `UI` 등 기본 게임 경로와 `DISBTN`/`DISPAS` 아이콘, 맵 미리보기 이미지는 보존합니다.
- 텍스처 함수의 문자열 상수와 문자열 결합, JASS의 단순 변수/배열 대입을 추적합니다. 숫자 변환을 포함한 경로는 패턴으로 보존합니다. Lua 변수·테이블·다중 대입의 값 추적은 지원하지 않아 미해결로 처리합니다.
- **함수 인자나 사용자 함수 반환값처럼 해석하지 못한 텍스처 경로가 하나라도 있으면 남은 후보를 모두 판정 불가로 전환하고 자동 정리를 막습니다.** 사용자 함수의 호출 인자까지 추적하는 범용 JASS/Lua 해석기는 아닙니다. 일부 일반 맵도 이 때문에 정리가 차단될 수 있습니다.
- 누락된 파일 목록, 읽기 실패, 암호화 스크립트/실행 파일, 잘못된 모델이나 가져오기 표, 언어별 파일, 서명된 맵도 자동 정리하지 않습니다. 보호를 해제하는 기능은 없습니다.
- 사용자 정의 로더, 알려지지 않은 플러그인, 엔진의 모든 암묵적 참조를 완전히 재현하지는 않습니다. **삭제 후보는 정적 분석 결과이며, 실제 게임의 미사용을 100% 증명하지 않습니다.** 정리된 맵의 아이콘·모델·UI와 플레이는 Warcraft에서 확인하세요.

## 원본과 출력 보호

- 원본은 읽기 전용으로 분석하며, 기존 파일과 원본을 덮어쓰지 않습니다.
- 분석 후 원본이 바뀌었으면 다시 분석하도록 중단합니다.
- 출력 폴더의 임시 복사본에서만 삭제와 MPQ 재압축을 수행합니다.
- `war3map.imp`에서도 삭제한 경로를 제거하고 다른 가져오기 항목의 원본 바이트는 유지합니다.
- MPQ 앞의 맵 헤더와 남은 모든 파일의 SHA-256을 검증합니다. `(listfile)`, `(attributes)` 등 MPQ 내부 관리 파일과 갱신한 가져오기 목록은 의도된 변경입니다.
- 검증에 실패하면 결과 맵을 게시하지 않습니다. 후보 압축 용량과 실제 맵 절약 용량은 재압축 결과에 따라 다릅니다.
- 분석은 파일당 최대 128 MiB, 맵 앞 헤더 최대 16 MiB를 지원합니다. 초과 파일은 추측해서 지우지 않습니다.

## 소스 실행 및 빌드

Python 3.11 이상 64비트와 Tcl/Tk, Unicode 64비트 StormLib이 필요합니다. GUI 소스 실행은 `app.py` 옆에 `StormLib.dll`을 두고 `python app.py`로 실행합니다.

```powershell
# 읽기 전용 분석
python cleaner.py "C:\Maps\map.w3x" --stormlib "C:\Tools\StormLib.dll" --report "C:\Maps\analysis.json"

# 모든 삭제 후보를 새 맵에서 정리. 보고서와 출력은 모두 새 경로여야 합니다.
python cleaner.py "C:\Maps\map.w3x" --stormlib "C:\Tools\StormLib.dll" --report "C:\Maps\cleanup.json" --output "C:\Maps\map_clean.w3x" --keep "MyUI\*"

# 배포 EXE도 같은 CLI 인수를 지원합니다. 창 모드 EXE이므로 결과는 JSON으로 확인합니다.
# PowerShell에서는 Start-Process -Wait로 완료를 기다릴 수 있습니다.
.\ArcanaBLPCleaner.exe --cli "C:\Maps\map.w3x" --report "C:\Maps\analysis.json"

# 개발용 빌드. 가상환경 사용을 권장합니다.
python -m pip install -r requirements-build.txt
.\build.ps1 -PythonExe python
```

`build.ps1`은 공식 StormLib 릴리스의 고정된 DLL ZIP을 다운로드하고 SHA-256을 확인합니다. 이미 확보한 DLL은 `-StormLibPath`로 지정할 수 있습니다. 테스트 통과 후 `dist\ArcanaBLPCleaner.exe`를 생성하고, EXE 자체에서도 합성 맵 정리와 오류 보고를 검사합니다. 소스에는 DLL이나 생성 EXE를 커밋하지 않습니다.

## 검증

```powershell
$env:STORMLIB_PATH = 'C:\Tools\StormLib.dll'
$env:BLP_GUI_TESTS = '1'
python -B -m unittest discover -s . -v
```

참조 분석 단위 검사와 합성 MPQ의 실제 읽기·삭제·재압축·해시 검사, 실패 시 출력 중단을 검사합니다. `STORMLIB_PATH` 또는 Windows가 없으면 MPQ 통합 검사는 건너뜁니다. 이 검사는 Warcraft 런타임이나 시각 검증을 대신하지 않습니다.

## 의존성 출처

- [StormLib 공식 소스와 API](https://github.com/ladislav-zezula/StormLib), [공식 v9.40 릴리스](https://github.com/ladislav-zezula/StormLib/releases/tag/v9.40). 포함된 라이선스는 `StormLib-LICENSE.txt`입니다.
- [MDX·MDL 및 가져오기 형식 참고 구현](https://github.com/flowtsohg/mdx-m3-viewer/tree/master/src/parsers).
- EXE 패키징은 [PyInstaller](https://pyinstaller.org/)를 사용합니다. Python/Tcl/Tk 런타임이 함께 포함됩니다.
