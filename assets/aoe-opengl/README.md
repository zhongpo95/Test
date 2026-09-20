# 범위 표시 OpenGL 비교본

사용자는 같은 범위 표시가 OpenGL에서만 테두리가 거칠어지고 반투명 면이 사라진다고 보고했다. 이번 파일은 JPEG BLP 텍스처 로딩 경로를 우회하는 비교본이다. 실제 OpenGL에서 수정 효과와 DirectX 화면 일치는 아직 검증하지 않았다.

## 적용한 변경

- `Etc Boss AOE2_OpenGL_TGA.mdx`는 원본 모델의 텍스처 경로만 `Etc Boss AOE2_OpenGL.tga`로 변경했다.
- TGA는 512×512, 비압축 32비트 BGRA, 8비트 알파다. JPEG의 네 원시 성분을 해독한 뒤 RGB와 알파 값을 추가 손실 없이 저장했다.
- 두 원형 평면, 애니메이션, Additive 재질, 깊이 설정은 원본과 같다. 범위 표시 JASS와 공격 판정도 변경하지 않았다.
- JPEG BLP의 원본 밉맵 10단계는 모두 정상 크기로 해독됐다. TGA는 최상위 이미지만 저장하므로 실제 게임의 축소 필터링과 밉맵 처리는 인게임 확인 대상이다.

## 바로 확인하는 방법

`Maps/mm/2/ARCRPG_RL_04_AOE_GL_TGA.w3x`를 OpenGL로 실행하고, 원정 중 범위 표시의 테두리와 안쪽 그라데이션을 확인한다. 이 맵은 RL-04 복사본에 위 리소스를 넣은 것이며 기존 맵을 덮어쓰지 않는다.

정상으로 보이면 해당 텍스처 로딩 경로가 원인 범위를 좁히는 근거가 된다. 동일하게 깨지면 TGA 변환만으로는 해결되지 않은 것이므로 렌더링 상태·색상 알파·그래픽 드라이버 경로를 더 확인해야 한다. 실제 게임 확인 전에는 해결 완료로 취급하지 않는다.

별도 맵에 직접 넣으려면 모델과 TGA를 함께 가져온다. TGA의 사용자 지정 가져오기 경로는 앞에 `war3mapImported\\` 없이 정확히 `Etc Boss AOE2_OpenGL.tga`로 설정하고, 범위 표시 유닛의 모델을 새 MDX로 지정한다.

## 확인한 근거와 검증

바탕화면의 원본 MDX·BLP는 RL-04에 들어 있는 파일과 SHA-256이 일치한다. MDX 800의 두 재질은 filter mode 3, flags 0xF1이다. BLP는 JPEG 압축, 8비트 알파이며 해독한 알파 범위는 0~235다. BLP JPEG는 일반 CMYK 이미지가 아니라 BGRA 성분을 저장하므로 일반 이미지의 `convert('RGBA')`를 쓰면 원본 알파를 잃을 수 있다. 변환기는 그 색 공간 변환을 하지 않는다. [BLP 형식 작성자의 분석](https://www.hiveworkshop.com/threads/blp-specifications-wc3.279306/), [MDX 형식 분석](https://www.hiveworkshop.com/threads/mdx-specifications.240487/)

설치된 Warcraft 1.28.5.768의 Game.dll을 실행 없이 정적으로 확인했다. OpenGL의 glAlphaFunc 호출부 RVA 0x1710D0은 GL_GEQUAL과 공통 알파 임계값 함수를 사용한다. Direct3D 상태 설정 경로도 RVA 0x175FB3에서 같은 함수 RVA 0x1698A0을 호출한다. 기본 임계값 테이블은 `(255, 192, 4, 4, 4, 4)`다. 따라서 기본 임계값이 OpenGL에서만 다르다고 확정할 수 없고, 앞서 제안했던 Additive → AddAlpha 변경도 확정된 해결책이 아니다. 정적 확인만으로 실제 GPU에 적용된 상태나 텍스처 저장 형식까지 알 수는 없다. Game.dll을 수정하지 않았다.

| 구분 | 결과 |
|---|---|
| 파일 구조 | MDX 텍스처 경로 외 바이트 동일, 원본 밉맵 10단계 유효 |
| 텍스처 검사 | TGA를 독립적으로 다시 읽어 BGRA 1,048,576개 성분 값 전부 일치 |
| 맵 전달 검사 | 모델·가져오기 목록 교체, TGA 1개 추가. 기존 멤버 2,385개 해시 유지, JASS 바이트 동일 |
| 컴파일 | 미실행. RL-04의 검증된 컴파일 결과를 그대로 사용 |
| 시각·런타임 | 실제 Warcraft OpenGL/DirectX 비교 미수행 |

원본·변환 파일·맵 해시는 `report.json`, 재생성 도구는 `tools/build-aoe-gl-test.py`에 있다. 이 리소스는 자동 빌드 manifest에 등록하지 않아 기존 정식 RL-04와 이후 일반 빌드의 범위 표시에 자동 적용되지 않는다.
