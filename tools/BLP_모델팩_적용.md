# BLP 이미지 모델팩 적용

완성 파일은 `D:\Work\ARCANA\builds\asi\20261013_blp_final\Arcana_A.asi`다.
기존 `Arcana_A.asi`와 원본 TGA는 보존했으며 게임 폴더에는 설치하지 않았다.

## 적용 순서

1. 이 PR의 Data/UI 변경을 맵 소스에 적용한다. 확장자를 `.blp`로 변경했으므로 **기존 TGA 경로를 사용하는 맵에 새 ASI만 교체하면 안 된다.**
2. Warcraft를 종료한 상태에서 설치된 `C:\Program Files (x86)\war3\Arcana_A.asi`를 별도 보관하고 새 파일로 교체한다. 기존 ASI 로드 방식과 파일명은 유지한다.
3. 맵에 자체 임포트된 TGA 대신 외부 BLP를 사용하는 변경이다. 새 BLP는 팩에 있으므로 맵에 중복 임포트할 필요가 없다. 기존 임포트의 일괄 삭제는 이 작업에 포함하지 않았다.
4. 사건 선택/본문/결과, 보유 카드/툴팁, 투명 테두리 및 일반 UI를 게임에서 확인한다. 문제 발생 시 이전 맵과 이전 ASI를 함께 복원한다.

`source-patch`에는 적용 소스 사본, `images\war3mapImported`에는 재패키징할 BLP 원본이 있다.
`Arcana_B`의 미래 이미지 168개도 같은 팩에 넣었지만, 미래 스토리를 현재 게임에 등록하지는 않았다.

## 용량과 화질

- TGA 1,744개 변환, 기존 BLP 5개 보존, 총 1,749개.
- 불투명 1,378개는 BLP1 JPEG 품질 90, 4:4:4이다.
- 투명 366개는 BLP1 256색 팔레트와 8비트 알파다. 원본 크기와 알파는 유지하지만 색 양자화/디더링으로 미세한 점무늬나 색 차이가 생긴다. 무손실 전환이 아니다.
- 변환 이미지의 전체 밉맵을 1×1까지 생성했다.
- 기존 설치 팩은 267,635,330바이트, 새 팩은 91,239,304바이트로 65.91% 작다. 새 팩에는 미래 이미지 168개가 추가되어 두 팩의 구성은 동일하지 않다.
- 새 ASI SHA-256은 `6de50bc6e43c87a9aadb49c31eb014c782b880b6f75654688247cefabbc69ca6`다.

## 검증 범위

변환본 전체의 밉맵 크기/경계/디코딩과 팔레트 알파 보존을 확인했다. JPEG 1,378개는 Pillow BLP 디코더로 추가 확인했다. ASI 제작기는 내부 모든 파일의 해시를 변환본과 대조했다. 대표 비교 이미지도 육안으로 확인했다. 게임 실행부는 기존 제작기의 로더이며 게임에서 실행해 검증하지 않았다.

적용 소스의 변환 대상 정적 경로 1,667건에서 BLP 누락 0건, 생성 데이터 일치, 카드 그림 모의 검사, UI 모의 검사 18개 및 JASSHelper/PJASS 컴파일을 확인했다. 컴파일 환경의 기존 `24 errors ignored` 메시지는 남아 있다. 실게임 표시·입력·멀티플레이와 GPU 메모리 절감은 미검증이다. 맵은 생성하지 않았다.

원본 TGA의 출처/해시 기록은 기존 content manifest에 그대로 남겼다. `content/blp-textures.json`이 변환 파일 목록이며 생성기는 이 목록에 있는 경로만 BLP로 출력한다. 기존 TGA 원본 검사용 `check-event-images.cjs`는 새 BLP 팩 검증기로 사용하지 않는다.

## 재생성

Pillow와 NumPy가 있는 Python으로 다음 명령을 실행한다. 출력 폴더는 존재하지 않는 새 경로를 사용한다.

```powershell
python tools/convert-modelpack-blp.py --source D:\Work\ARCANA\war3mapImported --source D:\Work\ARCANA\Arcana_B\war3mapImported --output D:\Work\ARCANA\builds\asi\새폴더 --quality 90
& D:\Work\ARCANA\tools\asi-packager\ArcanaASIPackager.exe --source D:\Work\ARCANA\builds\asi\새폴더\images --output D:\Work\ARCANA\builds\asi\새폴더\Arcana_A.asi --report D:\Work\ARCANA\builds\asi\새폴더\pack-report.json
```

형식 참고는 [Magos BLP1 형식 문서](https://github.com/Kanma/BLPConverter/blob/master/doc/MagosBlpFormat.txt)다.
