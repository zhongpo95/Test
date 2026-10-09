# 카드 이미지 적용 안내

현재 카드 카탈로그의 캐릭터·물품 카드 그림 161쌍과 엔딩 기념 카드 13쌍을 포함한다. 동일 지역·동일 이름의 보상은 기존 캐릭터 카드에 합쳐지므로 같은 그림을 공유한다. 작은 얼굴 아이콘과 큰 일러스트를 구분한다.

## 가져오기

1. 처음 적용한다면 `Arcana_Card_Textures_20261010.zip`의 `war3mapImported` 안에 있는 348개 TGA를 가져온다.
2. 기존 캐릭터 그림 v27을 이미 적용했다면 `Arcana_Ending_Card_Textures_20261010.zip`의 엔딩 그림 26개만 추가한다.
   페이트 교체본은 `Arcana_Fate_Calm_Textures_20261010.zip`의 14개 파일을 추가한다. 이전 전체 v2를 적용했다면 이 페이트 묶음만 추가하면 된다.
3. 맵 내부 경로는 ZIP 내부 경로와 같은 `war3mapImported\파일이름.tga`이다. 추가 폴더를 경로 앞에 붙이지 않는다.
4. 이 PR의 `Data/Data_PrototypeCardImages.j`도 적용한다. 기존 코드가 큰 그림과 작은 아이콘을 각각 `ProtoCardIllustration`과 `ProtoCardArt`로 표시한다.

전체 ZIP은 그림 파일과 적용 자료를 묶으며 기존 카드 보관함 배경·희귀도 프레임을 교체하지 않는다. ZIP 밖의 `originals`는 페이트 캐릭터와 엔딩 표지의 출처 원본 보존용이므로 맵에 넣지 않는다.

최종 결과 폴더는 `C:\Users\ctqho\OneDrive\Documents\Warcraft III\Maps\mm\2\카드텍스처_20261010_v5`이다. 이전 v27·v2와 게임 원화가 포함된 검토본 v3를 보존했으며, 적용 대상은 애니메이션판 v5다.

## 구성과 출처

- `card-index.json`은 174개 카드 그림과 각 그림을 공유하는 보상 ID 목록이다.
- `texture-manifest.json`은 그림별 맵 경로, 크기, SHA-256, 원본 URL과 제작진 정보를 기록한다. 알려지지 않은 개별 작가명을 추정하지 않는다.
- 페이트 7명의 그림 14개를 교체했고 다른 텍스처 334개의 해시는 v2와 동일하다. 키레이·타이가·에미야 시로, 사용자 제공 시로코 그림, 블루아카이브 메모리얼과 기존 얼굴 교정본을 보존했다.
- 교체하는 7명 모두 ufotable 애니메이션판이다. 세이버·린·아처·어새신·랜서는 UBW 공식 에피소드 장면, 사쿠라·캐스터는 Heaven's Feel 공식 소개 장면을 사용한다. 차분한 상반신과 얼굴·고유 복장이 보이는 그림을 선택하고, 큰 그림과 얼굴 아이콘을 같은 원본에서 자른다. 기존 게임 설정화 후보는 제외했다. 선택·반려 사유는 `fate-calm-review.json`, 원본 경로와 크롭은 `fate-calm-sources.json`에 기록한다.
- 엔딩 카드 13종에는 각 작품의 공식 키비주얼을 기념 표지로 사용한다. 작품 대표 그림이며 결말의 특정 장면을 직접 그린 삽화는 아니다. 현재 카탈로그에서 엔딩 카드의 전투 효과는 미설정인 상태다.
- `preview/all-cards.jpg`와 `preview/ending-cards.jpg`는 가져오기 전 그림 확인용이다.
- `preview/fate-before-after.jpg`는 페이트 7명의 교체 전후 비교이며 `preview/fate-anime.jpg`는 최종 애니메이션판 큰 그림과 얼굴 아이콘의 미리보기다. 예전 TGA 14개는 `페이트카드_20261010/copy_archive/기존_페이트_그림`에 따로 보존했다.

## 검증 범위

카탈로그의 보상 924개가 모두 그림에 연결되는지, 같은 캐릭터 그림을 공유하는지, 모든 TGA의 해시·RGBA 형식·크기와 ZIP 내용을 확인한다. 기존 프레임과 JASS 표시 함수를 이용하는 모의 UI 검사도 수행한다. 자세한 결과는 `validation-report.json`과 PR 설명에 기록한다.

JassHelper와 PJass로 변경된 `DataPrototypeCardImages` 모듈의 컴파일을 통과했다. 검증 파일의 `DataPrototypeCatalog` 의존 라이브러리와 `config/main`은 빈 스텁이며 전체 맵 컴파일은 수행하지 않았다. 전체 UI 모의 검사 18묶음과 생성 카탈로그 일치 검사도 통과했다.

Warcraft 실제 가져오기·화면 표시·멀티플레이는 별도 확인이 필요하다. W3X 파일은 만들지 않는다. 파일을 가져온 뒤에는 I키 목록, 선택한 카드의 큰 그림, 마우스를 올렸을 때의 얼굴 그림을 확인한다.

## 재생성

```powershell
python tools/build-card-image-delivery.py --source-root <기존 card-character-images-20261004 폴더> --replacement-root <페이트카드_20261010 폴더> --output-dir <새 출력 폴더>
node tools/check-card-images.cjs
```

원본 소스 폴더와 이전 ZIP을 보존하며 새 출력 폴더만 만든다. 엔딩 코드 추가 전 원본은 `copy_archive/card_images_2026-10-10`, 페이트 교체 전 원본은 `copy_archive/fate_card_images_2026-10-10`에 보존했다.
