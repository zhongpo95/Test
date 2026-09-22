# 만화경 v0.175 헤라 호환 시험본 v5

제공된 `万华镜v0.175.w3x`를 보존하고 별도 `Hera_Wanhua_0175_v5.w3x`를 만든다. 원본 제작자 SDK 없이 맵 내부 호출부를 분석해 만든 **초기 호환 시험본**이다. 실제 헤라 로딩, 영웅 선택, 전투 및 멀티플레이 성공은 아직 확인하지 않았다.

v2는 시작·갱신 호출에서 중복 `return`을 제거하고, Lua가 null을 반환하면 타이머를 중단하고 오류를 한 번 표시한다. [YDWE의 EXExecuteScript](https://github.com/actboy168/YDWE/blob/master/Development/Plugin/Warcraft3/yd_lua_engine/lua_engine/lua_loader.cpp)는 전달식을 `return (...)`으로 감싼다. 설치 DLL의 `return (%s)` 문자열과 일치함을 확인했고, 생성된 JASS 문자열에 같은 규칙을 적용해 v1의 실패와 v2의 통과를 재현했다.

v3는 설치 헤라에 `jass.code`가 없는 경우, 맵에 정의된 `get_player_name`과 사용 중인 `YDWERPGBilling` 조회 함수 3개를 기존 JASS 디스패처로 연결한다. 원래 함수의 반환값을 사용하며 플레이어 이름 뒤의 내부 `x` 표식도 유지한다. 연결하지 않은 플랫폼 저장 함수는 제공하지 않는다. 디버그 콘솔은 자동으로 열지 않고 파일 로그를 사용한다.

v4는 모듈 860의 `origin_load` 호출 실패를 수정한다. [YDWE의 jass.message](https://github.com/actboy168/YDWE/blob/master/Development/Plugin/Warcraft3/yd_lua_engine/lua_engine/libs_message.cpp)는 `__newindex`에서 `hook` 이외의 새 필드 대입을 무시한다. 따라서 `origin_load`와 목록 함수 4개를 `rawset`으로 등록한다. 기존 메타테이블과 네이티브 `hook` 처리 방식은 유지한다. 부트 검사에도 이 제약을 적용해 v3의 모듈 64개·프레임 0개 상태와 동일 오류를 재현했다.

v5는 `load_fdf`가 실행 중 저장한 파일을 다시 읽지 못해 문자열 결합에서 중단되는 문제를 수정한다. [YDWE의 파일 읽기 경로](https://github.com/actboy168/YDWE/blob/master/Development/Plugin/Warcraft3/yd_lua_engine/lua_engine/fix_baselib.cpp)는 로컬 파일 읽기를 허용하지 않으면 MPQ로 읽는다. 기본 UI와 글꼴·입력 상자 정의를 FDF·TOC로 맵에 포함하고 한 번 로드한다. 글꼴 크기 0~256의 네 가지 형식을 준비하며, 다른 내용이나 범위 밖 요청은 오류로 알린다. 기본 정의의 누락된 `字体.ttf`는 맵에 있는 `fonts.ttf`로 연결한다. 로그 경로와 머리말은 현재 버전에서 생성한다.

원본 SHA-256은 `901c31b06081e784490cdf0a99bde3680d60c6028a433a6ef57f20a0e9ec71d3`이다. 빌더는 다른 원본, 원본 덮어쓰기 및 기존 결과 덮어쓰기를 거부한다. 원본 맵, 복원한 원본 스크립트·에셋 및 DLL은 저장소에 포함하지 않는다.

## 적용 범위

- 기존 MPQ 해시 슬롯과 블록 번호를 유지하며 보호 BLP 3,197개, MDX 1,413개를 복원한다.
- 전용 DLL 부트스트랩 대신 JN `EXExecuteScript`와 JASS 트리거로 초기화·UI·마우스·키보드를 연결한다. 맵에 들어 있는 외부 DLL은 실행하지 않는다.
- 기본 이미지·텍스트 UI를 Dz 프레임으로 옮긴다. 참조 이미지 3,196개를 중복 제거한 TGA 3,188개로 변환한다.
- 구형 LNI의 기본값·열거값·상속을 읽고, 기본 효과 생성과 사운드를 Warcraft 네이티브에 연결한다.
- 중국 계정·클라우드 응답을 대신 생성하지 않는다. 저장값은 해당 게임 세션의 메모리에만 남으며 종료하면 사라진다. 서버 저장은 지원하지 않는다.

## 남아 있는 제한

원본 `opengl`, `ui`, `mprender` 구현을 재현한 것은 아니다. MDXS 셰이더, 동영상, UI 3D 회전, UV 변형, 일부 클리핑·애니메이션·색상·효과 모델 교체는 지원하지 않거나 단순화했다. 텍스트 폭·월드 좌표 투영·채팅 상태는 근사값이다. 전용 창 크기 조절은 런처 설정을 사용한다. UI 클릭의 원래 게임 입력 차단, 단축키, 효과 제거 시점, 아이템 능력 템플릿, 동기화와 모든 캐릭터 스킬은 실제 게임에서 확인해야 한다.

오류와 지원하지 않는 호출은 게임 폴더의 `Logs/Hera_Wanhua_v5_p1.txt`에 기록한다. 플레이어 번호에 따라 `p2`, `p3` 등으로 바뀐다. 초기화 상태에도 시험본과 서버 저장 미지원 안내가 표시된다. `initialized; gameplay unverified`는 Lua 초기화 반환 상태이며 게임 정상 작동 판정이 아니다. FDF 로드 네이티브는 반환값이 없으므로 템플릿이 실제로 화면에 적용됐는지는 게임에서 확인해야 한다.

## 빌드

Windows, Python 3.11 이상, Pillow, 64비트 StormLib가 필요하다. Lua 검사에는 Lupa의 Lua 5.3 런타임이 추가로 필요하다. StormLib와 JASS 검사기는 신뢰할 수 있는 기존 설치 경로를 지정한다.

```powershell
python -m pip install Pillow lupa
python tools/wanhuajing-hera/build.py 'C:/maps/万华镜v0.175.w3x' 'C:/build/Hera_Wanhua_0175_v5.w3x' --stormlib 'C:/tools/StormLib.dll'
```

결과 옆 `staging`에는 생성 스크립트, 변환 이미지, 블록별 SHA-256을 담은 `build-report.json`이 만들어진다. `--prepare-only --prepare-images`는 맵 포장 없이 검사 입력을 준비한다.

## 검증 재현

```powershell
python tools/wanhuajing-hera/check_core.py --original-jass 'C:/build/original-war3map.j'
python tools/wanhuajing-hera/check_boot.py --source 'C:/maps/万华镜v0.175.w3x' --staging 'C:/build/staging' --stormlib 'C:/tools/StormLib.dll' --common-j 'C:/JN/common.j' --library-dir Library
& 'C:/JN/pjass.exe' 'C:/JN/common.j' 'C:/JN/Blizzard.j' 'C:/build/staging/war3map.j'
python tools/wanhuajing-hera/check_pack.py --source 'C:/maps/万华镜v0.175.w3x' --output 'C:/build/Hera_Wanhua_0175_v5.w3x' --stormlib 'C:/tools/StormLib.dll' --report 'C:/build/staging/build-report.json'
```

`check_core.py`의 원본 JASS는 원본 맵의 `war3map.j`를 읽기 전용으로 추출한 것이다. Lupa를 별도 폴더에 설치했다면 검사기에 `--lua-deps`를 지정할 수 있다.

정적 검사는 압축 섹터 경계·리소스 손상 거부·JASS 삽입 위치·LNI 상속과 문자열·Lua 문법을 확인한다. 부트 모의 검사는 1명 접속 상태에서 Lua 초기화와 10초 분량의 타이머 콜백만 진행한다. 실제 네이티브·SLK 객체·서버 동기화·렌더링·플레이어 조작을 재현하지 않는다. `check_pack.py`는 전체 블록과 패치 경로를 다시 읽고 원본 해시 슬롯 보존 및 원본 파일 불변을 확인한다.

실제 게임 및 화면 검사는 미실시다. 첫 확인 순서는 맵 선택·로딩, 초기 화면 버튼과 영웅 선택, 이동·기본 스킬, 2인 접속 및 동기화다.
