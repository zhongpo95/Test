# Hera RPG v150 야에 사쿠라 E 충전 종료 수정

v149에서 E를 뗀 후 기류가 계속 생성되는 경로를 수정했습니다. v148의 E 해제 입력 네이티브 충돌 회피는 유지합니다.

## 확인된 문제

v149 해제 요청 이름 `HeraYaeRelease`는 ASCII 13바이트로 설치 JN 동기화 접두사 제한 9바이트를 초과합니다. 프로젝트의 `Library/DzAPISync.j` 14, 28행에 해당 제한이 명시되어 있습니다. v149 부팅 로그에는 E 해제 전송 기록이 있지만 실제 해제 명령 852138 및 A1S0 시전 기록은 없습니다. UI 호출 집계에서도 전송이 증가하는 동안 수신 조회가 거의 증가하지 않습니다.

E 스킬은 충전 취소 상태가 설정될 때까지 50ms마다 기류 효과를 다시 생성합니다. 해제 요청 미전달과 계속 생성되는 효과가 연결됩니다. 이펙트 객체는 기존 Effectcreate 수명 처리에서 파괴되므로 임의로 모델을 숨기거나 피해 계산을 바꾸지 않습니다. 네이티브 내부의 정확한 패킷 거부 지점은 직접 계측하지 않았습니다.

## 변경

- 메시지 이름을 8바이트 `HeraYaeE`로 줄였습니다.
- 접두사 9바이트 제한을 모듈 초기화에서 검사합니다.
- 수신기 등록 및 모든 조건 검사 전 수신 진입을 부팅 로그에 추가했습니다.
- 실제 송신자의 영웅을 확인하여 일반 JASS 명령으로 원래 A1S0 충전 해제를 실행하는 방식은 유지합니다.
- E 충전·피해·스킬 수치는 변경하지 않았습니다.

## 검증

- 정적 검사 완료. v150 추출 Lua 593개 문법, 새 접두사와 모듈 포함, 원본 E/A1S0 스킬 코드 보존 확인.
- 빌드·패키지 검사 완료. MPQ 5,652개 블록 해시와 파일 조회 검사 통과.
- Lua 모의 검사 60개 통과. 네이티브의 접두사 길이 제한을 모델링하여 기존 13바이트 이름 거부를 재현했습니다. 실제 A19K, E 충전 루프, A1S0 콜백을 실행해 두 클라이언트에서 짧은 충전·긴 충전·반복 사용·중복/잘못된 요청을 검사했습니다. 해제 수신 다음 50ms 처리에서 충전 효과 생성이 멈추고 발도가 한 번 실행되며 이후 2초간 기류를 추가 생성하지 않습니다.
- 실제 Warcraft 실행, 엔진 명령 수락, 네트워크 전달·지연·멀티 동기화, 화면 검증은 미실시입니다. JASS 로직 변경 및 JASS 재컴파일은 없습니다.

양쪽 모두 v150으로 실행하고 빈 공간에서 E 짧게 누르기와 길게 누른 뒤 떼기를 확인합니다. 확인할 항목은 기류가 멎고 발도가 나가는지입니다. 부팅 로그에는 `REGISTERED`, `LOCAL SEND`, `SYNC RECEIVE`, `SYNC BEGIN`, `SYNC END`를 기록하며 전체 40건 제한입니다.

맵 SHA256 `ede0ac590decd0b6edef6e7976583d834a3f0b842d311eaf6400803c14cc01f3`

## 원본 작업 폴더에 적용

맵 원본과 모델팩은 이 저장소에 포함하지 않습니다. 별도 Hera RPG 작업 폴더의 v148을 보존한 복사본에서 아래를 실행합니다. 모의 검사에는 Lua 5.3을 포함한 Lupa가 필요하고 패키지 검사에는 독립 검증기로 추출한 v148/v150 소스가 필요합니다.

```powershell
$patchDirectory = '검토한 패치 디렉터리의 절대 경로'
git apply --check "$patchDirectory/integration.patch"
git apply "$patchDirectory/integration.patch"
Copy-Item -LiteralPath "$patchDirectory/yae_release.lua" -Destination './hera-port/scripts/gameplay/feature/shot/yae_release.lua'
python build_hera_rpg.py
node validate_hera_rpg.js Hera_RPG_Init_v150.w3x hera-rpg-validation-v150
python "$patchDirectory/check_v150.py" (Get-Location).Path
python "$patchDirectory/check_packaged_v150.py"
```

현재 위치는 v148 맵 작업 폴더입니다. `integration.patch`는 v148 대비 기존 파일 수정이고 새 모듈은 `yae_release.lua`입니다. 이미 v149 또는 v150인 폴더에 이 누적 패치를 재적용하지 않습니다.
