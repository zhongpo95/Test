# ARCANA ASI 제작기

폴더를 선택하면 하위 폴더의 **모든 파일**을 실행 로더와 함께 하나의 ASI로 묶는 Windows 프로그램이다. 카드 수·확장자·manifest에 제한을 두지 않는다. Python·컴파일러·별도 DLL을 설치하지 않고 EXE를 실행한다.

## 사용법

1. ZIP을 풀고 `ArcanaASIPackager.exe`를 실행한다.
2. **입력 폴더**에서 넣을 파일이 있는 폴더를 선택한다.
3. **저장 파일**에서 입력 폴더 밖의 저장 위치와 이름을 지정한다. 기본 이름은 `Arcana_A.asi`다.
4. 미리보기의 경로가 맵 임포트 경로와 일치하는지 확인한다.
5. **ASI 만들기**를 누른다. 압축과 원본 SHA-256 검증이 끝나면 완료를 표시한다.

기존 ASI를 덮어쓰지 않고 입력 파일도 수정하지 않는다. 업데이트는 새 위치에 생성한 후 완성본을 교체한다. 모든 확장자를 포함하므로 이미지 전용 A 팩은 **이미지만 있는 폴더**를 선택한다.

## 임포트 경로

선택한 폴더 아래의 상대 경로를 그대로 보존한다.

- 입력 폴더 안에 `war3mapImported`가 있으면 **경로 앞부분**을 비운다.
- `war3mapImported` 폴더 자체를 골랐다면 **경로 앞부분**에 `war3mapImported`를 입력한다.
- 일반 폴더에도 필요한 접두 폴더를 지정할 수 있다. 목록에서 최종 경로를 확인한다.

예를 들어 최종 경로는 `war3mapImported\UI_Card_FateCalm_caster_Icon.tga`다. 팩 제작만으로 맵의 임포트 경로나 호출 코드가 바뀌지는 않는다.

## 단일 ASI 구조

앞쪽은 직접 작성한 x86 실행 로더다. 뒤쪽 512바이트 경계에 MPQ v0 아카이브를 붙인다. MPQ 항목은 선택한 폴더의 파일들과 내부 `(listfile)` 목록 하나다. 실행부는 MPQ 항목이 아니므로 MPQ 도구의 파일 목록에 별도 로더가 나타나지 않는다.

맵이 ASI를 로드하면 실행부가 **자신의 ASI 파일**을 Storm에 연결한다. 특정 카드에 의존하지 않고 내부 목록을 읽을 수 있는지 확인한다. 설치할 파일은 생성된 ASI 하나이며 `Arcana_Loader.asi`는 필요 없다.

`D:\Work\ARCANA\mix`의 ASI 13개를 읽기 전용으로 확인했다. 모두 MZ/PE 실행부 뒤 48,128~53,760바이트에 MPQ가 있다. 해당 파일은 실행하거나 수정하지 않았다.

## 우리 맵에 적용

`System/CardModelPack.j`가 맵 초기화 때 `Arcana_A.asi`를 기존 Lua 방식으로 한 번 로드한다. `DataPrototypeCardImages`는 이 초기화 뒤에 실행된다.

생성된 `Arcana_A.asi`를 `C:\Program Files (x86)\war3\War3.exe` 옆에 둔다. 이 코드가 적용된 맵에서 호출한다. 파일명을 바꾸면 맵 호출도 맞춰 바꿔야 한다. 모든 플레이어가 같은 팩을 설치한다.

실제 화면에서 확인한 뒤 기존 목록의 카드 TGA 348개만 맵 임포트에서 제거하면 맵 크기를 줄일 수 있다. 다른 UI 텍스처·모델은 제거 대상이 아니다. 이 작업에서는 맵을 만들거나 게임 폴더에 설치하지 않았다.

대상은 Windows x86/JN, Game.dll 1.28.5.7680이다. Reforged에서는 호출하지 않는다. 설치 결과는 로컬 로그에만 기록하고 전투·보상·동기화 상태에 사용하지 않는다.

## 전달본

`C:\Users\ctqho\OneDrive\Documents\Warcraft III\Maps\mm\2\ASI_제작기_20261010`

- `Arcana_ASI_Packager_20261010.zip`. EXE·사용법·검증 요약·라이선스.
- `ArcanaASIPackager.exe`. 압축 라이브러리·로더·Python/Tk 런타임을 내장한 단일 실행 파일.
- `생성예제\Arcana_A.asi`. EXE로 만든 현재 카드 이미지 348개 팩. 프로그램 ZIP에는 큰 예제 팩을 포함하지 않는다.

변경 전 분리형 코드는 `copy_archive/card_modelpack_split_2026-10-10`에, 이전 배포 폴더와 원본 TGA도 그대로 보존한다.

## 검증 범위

- 핵심 기능. 하위 폴더·한글 파일명·다른 확장자·빈 파일의 압축과 SHA-256 비교, 접두 경로 유지, 덮어쓰기 방지, 입력 폴더 안의 출력 거절, 빈 입력·잘못된 로더·잘못된 접두 경로 거절 통과.
- 프로그램. 독립 EXE로 혼합 파일 4개와 카드 이미지 348개 생성 통과. GUI 폴더·출력 선택과 생성 버튼, 백그라운드 완료 표시를 숨긴 Tk 창에서 검사했다. 실제 화면 육안 확인은 미수행이다.
- C/JASS. 로더 빌드, 현재 Import.j를 연결한 JassHelper/PJass 컴파일 통과. 기존 의미 검사 제외 24건을 보고서에 명시한다.
- 별도 진단. 설치된 Storm.dll을 표준 MPQ 암호 테이블로 초기화한 환경에서 새 팩의 이미지 348개 읽기·비교·해제 통과. MPQ 없는 ASI 초기화 실패, 실제 Lua DLL의 성공·실패·미지원 및 종료 시 해제 검사 통과.
- 한계. 표준 암호 테이블 초기화는 진단 코드에만 있고 배포 로더에는 없다. 실제 Warcraft 맵 진입·그림 표시·재입장·멀티플레이는 미수행이다. 별도 프로세스 검사를 인게임 성공으로 취급하지 않는다.

제한된 Codex 실행 환경에서는 PyInstaller 단일 EXE의 자식 프로세스가 반복 실행되는 현상이 있었다. 해당 검증 프로세스를 종료한 후 일반 Windows 실행으로 재검증했으며 혼합 파일과 348개 카드 팩이 모두 정상 생성됐다.

## 명령줄과 재빌드

~~~powershell
.\ArcanaASIPackager.exe --source "D:\입력폴더" --output "D:\배포\Arcana_A.asi"
.\ArcanaASIPackager.exe --source "D:\카드\war3mapImported" --prefix war3mapImported --output "D:\배포\Arcana_A.asi"
~~~

재빌드는 Python 3.12 x64, PyInstaller 6.16.0, TinyCC 0.9.27 x86, x64 Unicode StormLib DLL을 사용한다. `build-program.ps1`에 해당 경로를 전달한다. 출력은 기존 파일이 없는 새 폴더로 지정한다.

일반 폴더 제작과 검증은 `build.py`, 화면과 독립 EXE 진입점은 `packager.py`, 런타임 연결은 `loader.c`에 있다. 로더는 네트워크·후킹·레지스트리 변경을 수행하지 않는다.
