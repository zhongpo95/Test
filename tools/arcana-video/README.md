# JN OpenGL 영상 시제품

워크래프트를 **JNLoader와 OpenGL 모드**로 실행했을 때, 맵에 포함된 MP4/WebM 영상을 화면 중앙에서 재생한다. 현재 시제품은 **최대 640×360 안에서 영상 비율 유지, 30fps, 무음**이다. 웹페이지 표시와 음성 재생은 구현 범위에 포함하지 않는다.

## 구성과 동작

- `Plugin.cs`는 JN의 `IPlugin`으로 로드되고 영상용 네이티브 3개를 등록한다. 맵 자원은 JN의 Storm API로 읽는다.
- `VideoPlayer.cs`는 별도 FFmpeg 프로세스에서 크기 정보가 있는 RGBA PAM 프레임을 받아 고정 최대 크기 버퍼 두 개로 전달한다. 원본의 표시 비율과 픽셀 종횡비를 반영해 정사각형 픽셀로 변환하며 여백을 덧붙이지 않는다. 프레임 헤더와 크기를 제한하고 불완전한 프레임은 오류로 처리한다. FFmpeg 창은 표시하지 않는다.
- `OpenGlOverlay.cs`는 한국용 Game.dll이 사용하는 `wglSwapLayerBuffers`와 일반 `SwapBuffers`에 EasyHook을 연결한다. 중첩 호출에서는 한 번만 그린다. 전달받은 프레임의 비율대로 창 너비 70%·높이 60% 안에 맞춰 중앙에 표시하며, 영상 바깥은 게임 화면으로 남긴다. 그래픽 상태를 복원하고, 맵 종료와 닫기 요청에서 디코더를 정리한다. 텍스처는 해당 OpenGL 컨텍스트의 다음 화면 교체 때 해제한다.
- `ArcanaVideoTest.j`는 요청한 테스트 맵용 채팅 명령이다. 재생 호출은 명령을 입력한 로컬 플레이어에게만 실행한다.

중국 맵의 DLL이나 Game.dll 버전별 고정 주소를 사용하지 않는다. 직접 만든 연결 코드를 설치된 JN 런타임과 EasyHook에 맞춰 빌드한다.

## 테스트 방법

1. 플러그인 설치 후 해당 Warcraft 폴더의 JNLoader를 **OpenGL 모드로 다시 실행**한다. 이미 열린 게임에는 새 플러그인이 소급 적용되지 않는다.
2. `0.15_OPENGL_VIDEO_TEST.w3x`를 연다. 맵 내부 표시 이름은 `OPENGL VIDEO TEST - 0.15`다.
3. 맵 시작 후 약 12초 뒤 준비 메시지가 나온다.
4. `-video`를 입력한다. 중앙에 맵에 포함된 무음 영상이 나온다. 기본 예제는 8초 색상표이며, `build-map.py --clip`으로 지정한 영상에 따라 내용과 길이가 달라진다.
5. 재생 중 `-videoclose`로 즉시 닫거나, 영상이 끝나면 자동으로 닫히는지 확인한다. `-video`로 다시 재생할 수 있다.
6. `-videostatus`는 OpenGL 감지와 디코더 상태를 표시한다.

게임 화면과 입력은 계속 동작한다. 영상에 클릭 버튼이나 입력 차단을 추가하지 않았다. 렌더러가 감지되지 않으면 재생 요청이 실패하며 상태 메시지에 이유를 표시한다.

세로·정사각형 영상도 고정 16:9 틀 없이 표시한다. 영상 파일 자체에 포함된 검은 부분이나 배경은 그대로 보인다. 화면 비율 수정은 DLL에 있으므로 기존 설치자는 `Arcana.Video.dll`도 교체한 뒤 게임을 다시 실행해야 한다.

## 설치되는 파일

```text
Warcraft/
  JNService/Plugins/Arcana.Video.dll
  JNService/Plugins/ArcanaVideo/ffmpeg.exe
  JNService/Plugins/ArcanaVideo/LICENSE
  JNService/Plugins/ArcanaVideo/README.txt
Maps/.../0.15_OPENGL_VIDEO_TEST.w3x
```

Warcraft와 JN 기본 파일은 교체하지 않는다. 사용을 중지하려면 게임을 종료한 뒤 `JNService/Plugins/Arcana.Video.dll`을 플러그인 폴더 밖으로 옮기고 다시 실행한다.

로그는 `%TEMP%/ArcanaVideo/player-<게임 PID>.log`에 기록한다. 영상 임시 파일도 같은 폴더에 만들며, 정상 종료·수동 닫기·디코딩 실패 시 정리한다. 게임 프로세스가 강제 종료되면 임시 파일이 남을 수 있다.

이 시제품을 실행하는 PC에는 위 연결 플러그인과 디코더가 필요하다. 맵 파일 하나만으로 일반 JN 설치에 새 기능이 생기지는 않는다.

## JASS 인터페이스

```jass
// 맵 내부 영상 자원을 로컬 플레이어 화면에 재생한다.
native JNArcVideoOpen takes string asset returns integer
native JNArcVideoClose takes nothing returns nothing
native JNArcVideoStatus takes nothing returns string
```

`JNArcVideoOpen`은 요청 접수 시 1, 파일·환경 오류 시 0을 반환한다. 실제 디코딩은 별도 작업에서 진행하므로 1이 최종 화면 출력 성공을 뜻하지 않는다. 상대 경로의 MP4/WebM만 허용하며 파일 크기는 256MB 이하로 제한한다. 새 영상을 열면 이전 재생을 닫는다. 플러그인이 없는 환경에서는 이 네이티브를 사용하는 맵을 실행할 수 없다.

## 빌드와 검증

`build.ps1`에 `-WarcraftDirectory`와 `-OutputDirectory`를 전달한다. 설치된 `Cirnix.JassNative.Runtime.dll`, `Cirnix.JassNative.dll`, `EasyHook.dll`을 참조하고 Windows의 .NET Framework C# 컴파일러로 x86 DLL과 독립 시험 프로그램을 빌드한다.

`build-map.py`는 `--source`, `--output`, `--stormlib`, `--clip`을 받는다. 이 도구는 분석에 사용한 **0.15 맵**의 제목 항목과 스크립트 형식에 맞춘 것이다. 원본을 덮어쓰지 않고 JASS·수입 목록·제목과 영상만 복사본에 반영한다. MPQ를 다시 열어 수정된 항목과 원본 보존 여부를 대조한다.

`install.ps1`은 완성된 DLL·FFmpeg·라이선스·테스트 맵만 설치하고 설치 전후 해시를 확인한다. 대상에 다른 내용의 같은 이름 파일이 있으면 백업을 만든다.

2026-09-16에 수행한 검증은 다음과 같다.

| 구분 | 결과 |
|---|---|
| C# 빌드 | 설치된 JN을 참조하여 x86 빌드 성공. 경고도 오류로 처리. |
| JASS 문법 | common.j·Blizzard.j와 최종 맵 스크립트 총 49,879행 PJass 통과. |
| 독립 실행 | 수정 DLL과 동일한 코드로 숨겨진 시험 창의 NVIDIA OpenGL 4.6에서 총 48개 검사 통과. 1,815회 화면 교체, 358개 프레임 변화 표본 확인. |
| 동작 시험 | 영상 프레임 변화, 240프레임 완료 후 자동 닫기, 수동 닫기, 재재생, 8회 빠른 열기/닫기, 손상 파일·누락 파일 처리, 임시 파일 정리 확인. |
| 그래픽 상태 | 관찰한 화면 교체에서 viewport·행렬 모드·unpack alignment·depth/blend/scissor 활성화 상태 복원 확인. 모든 확장 상태 조합을 시험한 것은 아님. |
| 화면 비율 | 정사각형·세로형·가로형·비정사각형 픽셀 영상에서 디코딩 크기, 실제 표시 영역, 양옆의 게임 배경, 색상 채널과 상하 방향을 확인. 잘못된 PAM 헤더·크기·잘린 프레임 거부 확인. |
| 사용자 세로 영상 | 480×852 H.264 MP4를 203×360으로 표시. 약 11.87초, 356프레임 재생 완료와 자동 닫기 후 배경 복원을 독립 시험에서 확인. 원본 영상은 변환 없이 맵에 포함. |
| 시각 확인 | 수정 후 독립 시험 화면에서 사용자 세로 영상과 정사각형 영상의 여백 없는 출력 확인. 이전 DLL에서는 사용자가 제공한 Warcraft 화면으로 색상표와 정사각형 MP4 출력 확인. |
| MPQ 보존 | 기존 905개 중 902개 동일. war3map.j·war3map.imp·war3map.wts 수정, MP4 1개 추가. 원본 SHA-256 유지. |
| 워크래프트 실제 실행 | **이전 DLL은 사용자 실행으로 확인.** JNLoader OpenGL 실행 후 맵 로딩과 `-video` 영상 출력 성공. 게임 로그에서 OpenGL 감지와 240프레임 완료를 확인했고 사용자가 재재생·자동 닫기를 확인함. **비율 수정 DLL과 새 세로 영상의 게임 내 출력은 아직 미확인.** |
| 게임 내 추가 검증 | **미수행.** 비율 수정 후 재생·재재생·자동 닫기, 수동 닫기, 창 전환·해상도 변경 및 다른 플러그인과의 장시간 공존은 별도 확인 필요. |
| 멀티플레이 | **미수행.** 단일 로컬 재생 시제품이며 배포 전 별도 검증 필요. |

독립 시험은 Warcraft나 JN을 실행하거나 다른 프로세스에 코드를 주입하지 않는다. 시험 프로그램 자체에 후크와 OpenGL 컨텍스트를 만들며, 실제 게임 호환성 검증을 대신하지 않는다.

## 의존 파일 출처

- JN 플러그인 인터페이스와 Storm API는 [JassNative 공개 소스](https://github.com/BlacklightsC/JassNative)를 대조했고, 컴파일 참조는 현재 설치 파일을 사용했다.
- 화면 교체 연결은 JN에 이미 포함된 EasyHook을 사용한다. [EasyHook 로컬 후크 문서](https://easyhook.github.io/tutorials/createlocalhook.html)를 참조했다.
- FFmpeg는 [공식 다운로드 안내](https://www.ffmpeg.org/download.html)가 연결하는 [Gyan 빌드](https://www.gyan.dev/ffmpeg/builds/)를 사용했다. 실제 확보 버전은 `9.0.1-essentials_build`이며, 배포 ZIP의 공개 SHA-256과 다운로드 결과가 일치했다.
- FFmpeg ZIP SHA-256은 `fec81ae03971d9dd4be3ebe02e263bd2ec1d789483f931bdba5f5715e65da2e9`다. FFmpeg 바이너리·라이선스는 별도 로컬 패키지에 두고 Git 소스에는 포함하지 않는다.
- FFmpeg의 출력 형식과 필터 옵션은 [FFmpeg 문서](https://ffmpeg.org/ffmpeg.html)와 [필터 문서](https://ffmpeg.org/ffmpeg-filters.html)에 따른다.
- 프레임 크기와 RGBA 픽셀 전달은 [PAM 형식 명세](https://netpbm.sourceforge.net/doc/pam.html)의 헤더·래스터 구조를 사용한다. 외부 PAM 파일을 받는 범용 리더가 아니라 지정한 FFmpeg 출력 형식만 처리한다.
