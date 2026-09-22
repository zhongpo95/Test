# 만화경 v0.175 헤라 호환 시험본 v9

제공된 `万华镜v0.175.w3x`를 보존하고 별도 `Hera_Wanhua_0175_v9.w3x`를 만든다. 원본 제작자 SDK 없이 맵 내부 호출부를 분석해 만든 **초기 호환 시험본**이다. v8에서 배경과 선택 원은 보였으나 캐릭터 모델이 표시되지 않고 UI 갱신도 중단됐다. v9는 확인된 초기화 오류와 일부 UI 리소스를 보완한다. 모델 텍스처 연결은 미해결이며 정상 플레이 가능한 완성본은 아니다.

v2는 시작·갱신 호출에서 중복 `return`을 제거하고, Lua가 null을 반환하면 타이머를 중단하고 오류를 한 번 표시한다. [YDWE의 EXExecuteScript](https://github.com/actboy168/YDWE/blob/master/Development/Plugin/Warcraft3/yd_lua_engine/lua_engine/lua_loader.cpp)는 전달식을 `return (...)`으로 감싼다. 설치 DLL의 `return (%s)` 문자열과 일치함을 확인했고, 생성된 JASS 문자열에 같은 규칙을 적용해 v1의 실패와 v2의 통과를 재현했다.

v3는 설치 헤라에 `jass.code`가 없는 경우, 맵에 정의된 `get_player_name`과 사용 중인 `YDWERPGBilling` 조회 함수 3개를 기존 JASS 디스패처로 연결한다. 원래 함수의 반환값을 사용하며 플레이어 이름 뒤의 내부 `x` 표식도 유지한다. 연결하지 않은 플랫폼 저장 함수는 제공하지 않는다. 디버그 콘솔은 자동으로 열지 않고 파일 로그를 사용한다.

v4는 모듈 860의 `origin_load` 호출 실패를 수정한다. [YDWE의 jass.message](https://github.com/actboy168/YDWE/blob/master/Development/Plugin/Warcraft3/yd_lua_engine/lua_engine/libs_message.cpp)는 `__newindex`에서 `hook` 이외의 새 필드 대입을 무시한다. 따라서 `origin_load`와 목록 함수 4개를 `rawset`으로 등록한다. 기존 메타테이블과 네이티브 `hook` 처리 방식은 유지한다. 부트 검사에도 이 제약을 적용해 v3의 모듈 64개·프레임 0개 상태와 동일 오류를 재현했다.

v5는 `load_fdf`가 실행 중 저장한 파일을 다시 읽지 못해 문자열 결합에서 중단되는 문제를 수정한다. [YDWE의 파일 읽기 경로](https://github.com/actboy168/YDWE/blob/master/Development/Plugin/Warcraft3/yd_lua_engine/lua_engine/fix_baselib.cpp)는 로컬 파일 읽기를 허용하지 않으면 MPQ로 읽는다. 기본 UI와 글꼴·입력 상자 정의를 FDF·TOC로 맵에 포함하고 한 번 로드한다. 글꼴 크기 0~256의 네 가지 형식을 준비하며, 다른 내용이나 범위 밖 요청은 오류로 알린다. 기본 정의의 누락된 `字体.ttf`는 맵에 있는 `fonts.ttf`로 연결한다. 로그 경로와 머리말은 현재 버전에서 생성한다.

v6는 v5 로그의 `DzFrameSetEnable` 네이티브 실패와 체력바 `unit_overhead` 누락을 다룬다. 어댑터의 이미지·텍스트는 기본 배경·글꼴과 입력 추적 제외 속성을 갖춘 FDF 템플릿으로 생성하며, 생성 직후 활성화 상태를 바꾸는 호출은 제거한다. 네이티브 브리지 오류 후에는 후속 브리지 호출·화면 갱신·입력 처리를 중단하고 최초 오류를 표시한다. 체력바 높이는 현재 모델의 MDX 경계 상단으로 근사하며 읽을 수 없으면 60을 사용하고 제한을 기록한다. 원본의 애니메이션별 머리 위 부착점과 동일한 결과는 아니다. 충돌 덤프의 단일 원인을 확정하거나 실제 종료 문제가 해결됐다고 판정한 버전은 아니다.

v7는 전체 화면에 쓰인 투명 이미지의 잘라낸 결과를 실행 중 로컬 파일로 만들던 경로를 제거한다. 맵 안에 64×64 결과를 미리 포장하고, 이미지의 `u_rgb`를 프레임 색상에 적용해 검은 배경 효과가 흰색으로 표시되던 누락을 보완한다. `get_element_size()`는 원본 호출 의미에 맞게 UI 객체 수를 반환하며, 첫 화면 전에 좌표 변환기를 준비한다. 지연 선택 이벤트는 삭제되거나 XLS 데이터가 없는 유닛을 건너뛰고, 내부 능력 템플릿 유닛은 게임의 PauseUnit 훅에 등록되지 않도록 해당 불필요한 호출을 제거한다.

v8는 PVE 모드와 초보 난이도 선택 후 발생한 `SetUnitCollisionSize`와 `SetPariticle2Size` 누락을 처리한다. 해당 함수가 실제로 있는 환경은 그대로 사용하며, 없는 환경에서만 제한을 한 번 기록하고 계속한다. 원본 `set_collision`의 Lua 반경 기록과 `SetUnitPathing`에 의한 충돌 켜기·끄기는 유지한다. 엔진의 양수 충돌 반경은 원래 유닛 값이 남으므로 원본과 정확히 같지 않다. 입자 크기만 조절하는 기능도 기본 입자 크기를 유지한다. 이를 전체 효과 크기 조절로 대체하지 않는다.

v9는 건축사 등록보다 먼저 발생하는 레벨 갱신에서 원본 카드 풀을 준비하고, 내부 비플레이어 슬롯의 권한·개인 장식 저장 조회를 건너뛴다. 동적으로 조합되는 연속 WebP 27장과 저장 UI 두 장을 변환 목록에 추가하고 잘못된 확장자·폴더의 UI 참조 세 개를 실제 리소스에 연결한다. 검은 테두리 효과는 원본 알파를 유지한 검정 TGA를 별도 포장해 검정 착색일 때 사용한다.

원본 SHA-256은 `901c31b06081e784490cdf0a99bde3680d60c6028a433a6ef57f20a0e9ec71d3`이다. 빌더는 다른 원본, 원본 덮어쓰기 및 기존 결과 덮어쓰기를 거부한다. 원본 맵, 복원한 원본 스크립트·에셋 및 DLL은 저장소에 포함하지 않는다.

## 적용 범위

- 기존 MPQ 해시 슬롯과 블록 번호를 유지하며 보호 BLP 3,197개, MDX 1,413개를 복원한다.
- 전용 DLL 부트스트랩 대신 JN `EXExecuteScript`와 JASS 트리거로 초기화·UI·마우스·키보드를 연결한다. 맵에 들어 있는 외부 DLL은 실행하지 않는다.
- 기본 이미지·텍스트 UI를 Dz 프레임으로 옮긴다. 참조·별칭 3,228개를 TGA로 연결하고 64×64 결과와 검정 테두리 변형을 함께 포장한다. 중복 제거 후 총 5,022개 이미지 파일이다.
- 구형 LNI의 기본값·열거값·상속을 읽고, 기본 효과 생성과 사운드를 Warcraft 네이티브에 연결한다.
- 중국 계정·클라우드 응답을 대신 생성하지 않는다. 저장값은 해당 게임 세션의 메모리에만 남으며 종료하면 사라진다. 서버 저장은 지원하지 않는다.

## 남아 있는 제한

캐릭터 모델 복구는 미완료다. 초기 건축사의 `-909478866.mdx`는 MDLX 형식으로 복원되지만, 참조하는 `MH-819509167.blp`와 `MH933634193.blp`는 원본·v8 MPQ에서 해당 경로로 조회되지 않았다. 따라서 모델 바이트 복원을 모델 표시 성공으로 해석하면 안 된다. 대체 캐릭터나 임의 텍스처를 넣지 않았으며, v9에서도 모델이 보이지 않을 수 있다.

원본 `opengl`, `ui`, `mprender` 구현을 재현한 것은 아니다. MDXS 셰이더, 동영상, UI 3D 회전, UV 변형, 일부 클리핑·애니메이션·색상·효과 모델 교체는 지원하지 않거나 단순화했다. 이미지 RGB는 0~1 범위를 지원하며 초과 밝기는 1로 제한한다. 텍스트 폭·월드 좌표 투영·채팅 상태는 근사값이다. 설치 엔진에는 현재 조준 중인 능력을 읽는 `common_selector`가 없어 `(0, 0, 0)`을 반환하며 제한을 기록한다. 기본 명령 입력은 그대로지만 원본의 전용 조준·스킬 취소·아이템 대상 분기까지 재현한 것은 아니다. [YDWE message 구현](https://github.com/actboy168/YDWE/blob/master/Development/Plugin/Warcraft3/yd_lua_engine/lua_engine/libs_message.cpp)과 설치 DLL의 함수 문자열, 실제 nil 호출 로그를 확인했다. 전용 창 크기 조절은 런처 설정을 사용한다. UI 클릭의 원래 게임 입력 차단, 단축키, 효과 제거 시점, 아이템 능력 템플릿, 동기화와 모든 캐릭터 스킬은 실제 게임에서 확인해야 한다.

오류와 지원하지 않는 호출은 게임 폴더의 `Logs/Hera_Wanhua_v9_p1.txt`에 기록한다. 플레이어 번호에 따라 `p2`, `p3` 등으로 바뀐다. 초기화 상태에도 시험본과 서버 저장 미지원 안내가 표시된다. `initialized; gameplay unverified`는 Lua 초기화 반환 상태이며 게임 정상 작동 판정이 아니다. FDF 로드 네이티브는 반환값이 없으므로 템플릿이 실제로 화면에 적용됐는지는 게임에서 확인해야 한다.

## 빌드

Windows, Python 3.11 이상, Pillow, 64비트 StormLib가 필요하다. Lua 검사에는 Lupa의 Lua 5.3 런타임이 추가로 필요하다. StormLib와 JASS 검사기는 신뢰할 수 있는 기존 설치 경로를 지정한다.

```powershell
python -m pip install Pillow lupa
python tools/wanhuajing-hera/build.py 'C:/maps/万华镜v0.175.w3x' 'C:/build/Hera_Wanhua_0175_v9.w3x' --stormlib 'C:/tools/StormLib.dll'
```

결과 옆 `staging`에는 생성 스크립트, 변환 이미지, 블록별 SHA-256을 담은 `build-report.json`이 만들어진다. `--prepare-only --prepare-images`는 맵 포장 없이 검사 입력을 준비한다.

## 검증 재현

```powershell
python tools/wanhuajing-hera/check_core.py --original-jass 'C:/build/original-war3map.j'
python tools/wanhuajing-hera/check_boot.py --source 'C:/maps/万华镜v0.175.w3x' --staging 'C:/build/staging' --stormlib 'C:/tools/StormLib.dll' --common-j 'C:/JN/common.j' --library-dir Library
& 'C:/JN/pjass.exe' 'C:/JN/common.j' 'C:/JN/Blizzard.j' 'C:/build/staging/war3map.j'
python tools/wanhuajing-hera/check_pack.py --source 'C:/maps/万华镜v0.175.w3x' --output 'C:/build/Hera_Wanhua_0175_v9.w3x' --stormlib 'C:/tools/StormLib.dll' --report 'C:/build/staging/build-report.json'
```

`check_core.py`의 원본 JASS는 원본 맵의 `war3map.j`를 읽기 전용으로 추출한 것이다. Lupa를 별도 폴더에 설치했다면 검사기에 `--lua-deps`를 지정할 수 있다.

정적 검사는 압축 섹터 경계·리소스 손상 거부·JASS 삽입 위치·LNI 상속과 문자열·Lua 문법을 확인한다. 부트 모의 검사는 1명 접속 상태에서 Lua 초기화와 10초 분량의 타이머 콜백만 진행한다. 실제 네이티브·SLK 객체·서버 동기화·렌더링·플레이어 조작을 재현하지 않는다. `check_pack.py`는 전체 블록과 패치 경로를 다시 읽고 원본 해시 슬롯 보존 및 원본 파일 불변을 확인한다.

v9의 실제 게임 및 화면 검사는 미실시다. v8의 모델 미표시·초록 블록·흰 가장자리·겹친 글자는 사용자 스크린샷으로 확인했다. v9에서 모드·난이도 선택 후 진행과 UI 갱신, 테두리 색상 및 연속 이미지 표시를 확인해야 한다. 모델 텍스처 연결, 이동·스킬·전투·멀티플레이 검증도 남아 있다.
