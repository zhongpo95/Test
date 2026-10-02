# 원정 UI 텍스처 적용 안내

맵은 생성하거나 변경하지 않았다. 강화 UI 원본은 유지하고, 출발 화면은 원정 안내서, 사건 화면은 이야기와 행동 선택, 캐릭터 상태는 어두운 정보 화면으로 구분했다.

## 임포트

1. `Arcana_UI_Textures.zip`을 압축 해제한다.
2. `war3mapImported` 폴더 안 TGA 10개를 맵 에디터에서 가져온다.
3. 각 파일의 사용자 지정 경로를 아래와 똑같이 설정한다. 로컬 폴더 경로를 임포트 경로로 쓰지 않는다.
4. 코드 변경과 텍스처를 함께 적용한다. 텍스처만 넣어서는 새 배치가 표시되지 않는다.

| 파일 | 맵 안 임포트 경로 |
| --- | --- |
| UI_Arcana_Ink.tga | `war3mapImported\UI_Arcana_Ink.tga` |
| UI_Arcana_Panel.tga | `war3mapImported\UI_Arcana_Panel.tga` |
| UI_Arcana_Selected.tga | `war3mapImported\UI_Arcana_Selected.tga` |
| UI_Arcana_Button.tga | `war3mapImported\UI_Arcana_Button.tga` |
| UI_Arcana_Active.tga | `war3mapImported\UI_Arcana_Active.tga` |
| UI_Arcana_Paper.tga | `war3mapImported\UI_Arcana_Paper.tga` |
| UI_Arcana_Sheet.tga | `war3mapImported\UI_Arcana_Sheet.tga` |
| UI_Arcana_SheetHover.tga | `war3mapImported\UI_Arcana_SheetHover.tga` |
| UI_Arcana_Rule.tga | `war3mapImported\UI_Arcana_Rule.tga` |
| UI_Arcana_Route.tga | `war3mapImported\UI_Arcana_Route.tga` |

파일 원본은 `assets/expedition/polish/imports/`에 있으며 목록·해시는 `texture-manifest.json`에 있다. 텍스처는 비압축 32비트 RGBA TGA, 가로·세로는 2의 거듭제곱이다. `tools/build-expedition-skin.py`로 재생성할 수 있다. 다른 맵의 그림이나 제공 폴더의 텍스처는 복사하지 않았다.

## 화면별 변경

- 출발. 경로 장식과 안내 제목, 원정 규칙·출발 장비·파티 준비 상태를 분리했다. 공통 메뉴를 숨겨 제목과 겹치지 않으며 X/ESC로 닫는다.
- 사건. 밝은 종이색 패널과 직사각형 선택 영역을 사용한다. 설명·보상·비용·확정 영역과 최대 4개 후보/행동 흐름을 유지한다.
- 능력치. 이름과 수치를 분리해 숫자를 오른쪽 정렬한다. 카드 효과는 값이 0인 항목을 숨기고 성장과 조건부·생존 효과로 구분한다.
- 보유 카드. 어두운 바탕, 밝은 본문, 등급별 강조와 지속되는 선택 표시를 사용한다. 아이콘 설명은 불투명한 툴팁으로 표시한다.
- 강화 화면. 이번 변경에서 레이아웃과 기존 텍스처는 수정하지 않았다.

## 검증 범위

- 정적/모의 실행. CI에 등록된 17개 검사 명령 통과. 선택·페이지·정렬·Tab·닫기·타인 입력 차단과 동기화 경계를 검사했다.
- 정적 시각 검사. 실제 JASS 프레임에서 추출한 11개 장면, 선택 장면의 글자 영역 추정 초과 0건. `../hunt-ui/` 미리보기를 참고한다.
- 컴파일. 현재 체크아웃을 참조하도록 Import.j를 임시 재지정하여 JassHelper/PJass를 실행한다. 검증용 출력은 스크립트이며 맵이 아니다. 두 도구 종료 코드 0. PJass 출력에 `24 errors ignored`가 있으므로 진단 무시가 없는 컴파일이라고 주장하지 않는다. `compile-report.json`에 원문을 보존했다.
- 미검증. Warcraft 실제 렌더링·텍스처 임포트·폰트 줄바꿈·실제 마우스 입력·멀티플레이. 정적 미리보기의 기본 Warcraft 아이콘은 자리표시자로 표시된다.

큰 카드 그림은 기존 지역 아이콘을 확대한다. 캐릭터별 일러스트 연결은 이번 범위에 포함하지 않았다. 이전 UI 코드와 해시는 `copy_archive/ui_polish_2026-10-02/`에 보존했으며 활성 import에 넣지 않았다.
