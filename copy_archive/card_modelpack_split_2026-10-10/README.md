# Arcana_A 이미지 전용 팩

`Arcana_A.asi`에는 카드 TGA 348개만 넣는다. MPQ의 내부 목록 파일을 제외하면 모든 항목이 기존 `war3mapImported\파일명.tga` 이미지이며, DLL·실행 코드·모델·스크립트를 포함하지 않는다. 파일 첫 바이트부터 MPQ v0 헤더가 시작한다. 확장자는 `.asi`지만 실행 가능한 DLL은 아니다.

실행부는 `Arcana_Loader.asi`로 분리한다. 맵 초기화 때 기존 Lua 호출로 작은 로더를 로드하고, 로더가 **자기 파일과 같은 폴더**의 `Arcana_A.asi`를 Storm에 연결한다. A 파일의 이미지 요청 경로와 원본 바이트는 그대로다.

## 전달본

`C:\Users\ctqho\OneDrive\Documents\Warcraft III\Maps\mm\2\카드_이미지팩_Arcana_A_20261010`

| 파일 | 내용 | 크기 |
| --- | --- | --- |
| `Arcana_A.asi` | 이미지 348개와 MPQ 내부 목록 | 80,819,510바이트, 약 77.08MiB |
| `Arcana_Loader.asi` | 이미지 팩을 연결하는 x86 실행부 | 3,072바이트 |

이전 실행부·그림 결합형 ASI와 원본 v6는 보존한다. 변경 전 코드는 `copy_archive/card_modelpack_combined_2026-10-10`에 있다.

## 설치와 호출

1. 워크래프트를 종료하고 **두 파일 모두** `War3.exe` 옆에 둔다. 이 PC의 위치는 `C:\Program Files (x86)\war3\Arcana_A.asi`와 `C:\Program Files (x86)\war3\Arcana_Loader.asi`다.
2. 이 PR의 코드를 적용한 맵을 실행한다. `System/CardModelPack.j`는 `Arcana_Loader.asi`를 한 번 로드한다. 이미지 초기화는 `ArcanaCardModelPack` 이후 실행된다.
3. 로더는 자신의 설치 폴더에서 `Arcana_A.asi`를 연다. 실제 TGA 헤더를 읽지 못하면 초기화를 실패 처리한다.
4. I키 보유 카드, 카드 보상의 얼굴 아이콘과 큰 그림을 확인한다. 이후 그림만 업데이트할 때는 같은 경로의 A 파일을 교체하면 된다. 로더 동작을 변경한 경우는 로더도 교체한다.

모든 플레이어가 두 파일을 설치해야 한다. 대상은 Windows x86/JN 환경이며 Reforged에서는 호출하지 않는다. Lua API 미지원은 `UNSUPPORTED`, 파일 누락·DLL 초기화 실패는 `FAILED`, 성공은 `OK`로 로컬 로그에 기록한다. 설치 결과는 전투·보상·동기화된 게임 상태에 사용하지 않는다.

## 맵 임포트

실제 맵에서 그림 표시를 확인한 뒤 `map-imports-to-remove.txt`에 있는 **카드 TGA 348개만** 가져오기 관리자에서 제거한다. 다른 UI 배경·프레임·모델은 대상이 아니다. 팩을 만드는 것만으로 기존 맵에 들어 있는 이미지가 제거되지는 않는다. 제거 전 맵과 원본 TGA는 보존한다.

이 작업에서는 W3X를 만들거나 게임 폴더에 파일을 설치하지 않았다. 기존 `D:\Work\GitHub\Test` 적용은 PR을 통해 진행한다.

## 검증

- 정적·패키지 검사. A 파일이 MPQ 헤더로 시작하고 실행부를 포함하지 않는지, 항목이 이미지 348개와 내부 목록 하나인지 확인했다. 전체 이미지 SHA-256과 임포트 경로가 v6 원본과 일치한다. A 파일 전체 해시도 이전 전달본의 순수 MPQ와 같다.
- 빌드·컴파일. 로더 C 빌드, 현재 Import.j를 연결한 JassHelper/PJass 스크립트 컴파일 통과. PJass의 기존 의미 검사 제외 24건은 보고서에 명시한다.
- 별도 프로세스 검사. 설치된 Storm.dll을 표준 MPQ 암호 테이블로 초기화한 진단 환경에서 분리된 로더의 연결, 이미지 348개 바이트 비교, 해제를 통과했다. A 파일 누락·손상 시 초기화 실패도 확인했다. 설치된 Lua DLL로 같은 호출의 성공·실패·미지원 처리와 종료 시 해제를 검사했다.
- 한계. 표준 암호 테이블 초기화는 진단 코드에만 있으며 배포 로더에는 하드코딩 주소·게임 메모리 변경을 넣지 않는다. 이 검사는 실제 맵 진입 성공을 증명하지 않는다.
- 미수행. Warcraft 맵 실행, 실제 화면 표시, 재입장, 멀티플레이 및 Reforged.

## 재생성

TinyCC 0.9.27 x86 컴파일러와 Unicode StormLib DLL을 빌드에만 사용한다. 출력은 기존 파일이 없는 새 폴더로 지정한다. 플레이어에게는 컴파일러나 StormLib 설치가 필요하지 않다.

```powershell
& <tcc.exe> -shared tools/card-modelpack/loader.c -lkernel32 -o <card-loader.dll>
& <python.exe> tools/card-modelpack/build.py --source <카드텍스처_v6> --output <새_출력_폴더> --loader <card-loader.dll> --stormlib <x64_StormLib.dll>
```

`probe.c`의 두 번째 인수는 실행부인 `Arcana_Loader.asi`다. 같은 폴더에 이미지 팩을 두어야 한다. 이 도구는 게임 초기화가 없는 독립 프로세스이므로 실패 결과만으로 인게임 호환성을 판단하지 않는다.

외부 아카이브 연결은 [War3MpqOuter 구현](https://github.com/NameForTac/War3MpqOuter/blob/main/dllmain.cpp), Lua `'*'` 모드는 [Lua 공식 설명](https://www.lua.org/manual/5.3/manual.html#pdf-package.loadlib)을 참고했다. 로더는 직접 작성한 공개 소스이며 네트워크·후킹·레지스트리 변경을 수행하지 않는다. 이미지 출처는 `texture-manifest.json`에 보존한다.
