# 카드 외부 ASI 모델팩

카드 그림 174쌍, TGA 348개를 맵 밖의 `Arcana_Cards_20261010_v2.asi` 하나에 묶는다. ASI는 직접 작성한 x86 DLL과 MPQ v0의 결합이며, 맵 초기화 때 Lua `package.loadlib`로 로드한다. 원본 TGA의 바이트와 `war3mapImported\파일명.tga` 경로를 보존한다. 그림의 해상도나 알파를 줄이지 않는다.

## 현재 전달본

`C:\Users\ctqho\OneDrive\Documents\Warcraft III\Maps\mm\2\카드_외부모델팩_20261010_v2`

- 원본 TGA 합계 193,870,800바이트, 약 184.89MiB.
- ASI 80,822,070바이트, 약 77.08MiB. MPQ 압축은 4KB 섹터 zlib다.
- 게임용 설치 파일은 ASI 하나다. 별도의 MPQ는 개발자·편집기용으로 보존한다.
- 원본 그림 v6와 이전 MIX 시안 v1을 그대로 보존한다.

## 플레이어 설치

1. 워크래프트를 종료하고 ZIP의 `Arcana_Cards_20261010_v2.asi`를 `War3.exe` 옆에 둔다. 이 PC의 대상 경로는 `C:\Program Files (x86)\war3\Arcana_Cards_20261010_v2.asi`다.
2. 이 PR의 코드를 적용한 맵을 실행한다. 맵의 `ArcanaCardModelPack` 초기화가 ASI를 한 번 로드한다. MIX처럼 게임 전체 시작 때 자동 로드하는 방식을 요구하지 않는다.
3. I키 보유 카드, 카드 보상의 아이콘과 큰 그림을 확인한다. 다른 플레이어도 같은 ASI를 설치해야 한다.
4. 제거할 때는 게임을 종료하고 이 ASI만 삭제한다. 기존 게임 MPQ나 레지스트리를 변경하지 않는다.

대상은 현재 사용 중인 Windows x86/JN 환경이다. Reforged에서는 호출하지 않는다. Lua의 `package.loadlib`가 제공되지 않으면 로그에 `UNSUPPORTED`, 파일 누락·DLL 초기화 실패면 `FAILED`, 성공이면 `OK`를 기록한다. 로그의 설치 결과는 클라이언트마다 다르므로 전투·보상·동기화된 상태에 사용하지 않는다.

## 맵 연결과 용량 감소

`Import.j`에 `System/CardModelPack.j`를 추가하고 `DataPrototypeCardImages`에 `ArcanaCardModelPack` 의존성을 지정한다. 이미지 등록 및 UI 표시보다 먼저 팩을 로드한다. 기존 JN/JAPI 라이브러리를 사용하며 맵 안에 실행 DLL을 임포트하지 않는다.

실제 맵에서 그림 표시를 확인한 다음, 가져오기 관리자에서 `map-imports-to-remove.txt`의 **카드 TGA 348개만** 제거한다. ASI를 만드는 것만으로 이미 임포트된 맵의 용량이 줄어들지는 않는다. 다른 UI 배경·프레임·모델은 제거 대상이 아니다. 제거 전 맵과 원본 TGA를 보존한다. 설치하지 않은 플레이어는 외부로 옮긴 그림을 볼 수 없다.

이 작업에서는 W3X를 만들거나 편집하지 않았고 게임 폴더에 ASI를 설치하지 않았다. `D:\Work\GitHub\Test` 적용은 PR을 통해 진행한다.

## 검증 범위

- 정적·패키지 검사. MPQ와 ASI에서 348개 파일을 모두 다시 읽어 v6 원본 SHA-256과 비교했다. x86 PE DLL, MPQ v0, 헤더 512바이트 경계와 기존 임포트 경로를 확인했다.
- 컴파일. ASI 로더 C 빌드, 현재 `Import.j`를 연결한 JassHelper/PJass 스크립트 컴파일을 통과했다. PJass가 보고한 기존 의미 검사 제외 24건은 별도로 기록한다. 카드 그림 연결·모의 보관함 검사도 통과했다.
- 별도 프로세스 검사. 실제 설치 폴더의 Storm.dll을 표준 MPQ 암호 테이블로 초기화한 진단 프로세스에서 ASI 로드, 원본 348개 바이트 비교, 해제를 통과했다. 실제 Lua DLL에서 동일 로드 표현식의 성공·실패·미지원 처리와 Lua 종료 시 해제도 확인했다.
- 한계. 게임 시작 전 DLL 단독 로드 상태에서는 기존 게임 MPQ의 파일 검색도 실패했다. 표준 암호 테이블 초기화는 **진단 코드에만** 있으며 배포 로더에는 하드코딩 주소·게임 메모리 변경을 넣지 않는다. 이 조건부 검사를 실제 맵 진입 성공으로 취급하지 않는다.
- 미수행. Warcraft 맵 실행, 실제 화면 표시, 재입장, 멀티플레이, Reforged. 실제 Lua/JAPI 환경에서 같은 API가 노출되는지는 맵 실행으로 확인해야 한다.

## 재빌드

TinyCC 0.9.27의 x86 컴파일러와 Unicode StormLib DLL을 사용한다. 출력은 새 폴더로 지정하며 기존 파일을 덮어쓰지 않는다. 런타임에는 TinyCC와 StormLib를 설치하지 않는다.

```powershell
& <tcc.exe> -shared tools/card-modelpack/loader.c -lkernel32 -o <card-loader.dll>
& <python.exe> tools/card-modelpack/build.py --source <카드텍스처_v6> --output <새_출력_폴더> --loader <card-loader.dll> --stormlib <x64_StormLib.dll>
```

`probe.c`는 게임을 실행하지 않고 Storm으로 파일을 읽는 진단 도구다. 게임의 초기화가 없는 독립 프로세스이므로 실패 결과만으로 인게임 호환성을 판단하지 않는다. 특정 DLL의 암호 테이블을 초기화하는 추가 진단 코드는 배포용 빌드와 분리해 보존한다.

외부 아카이브 연결 방식은 [War3MpqOuter 구현](https://github.com/NameForTac/War3MpqOuter/blob/main/dllmain.cpp), Lua의 `'*'` 모드 동작은 [Lua 공식 설명](https://www.lua.org/manual/5.3/manual.html#pdf-package.loadlib)을 참고했다. 이 팩의 C 로더는 저장소에 공개된 직접 작성 코드이며 네트워크·후킹·레지스트리 변경을 수행하지 않는다. 그림 출처는 `texture-manifest.json`에 보존한다.
