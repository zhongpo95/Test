# BLP 이미지 모델팩 적용

완성 파일은 `D:\Work\ARCANA\builds\asi\20261013_blp_colorfix\Arcana_A.asi`다.
기존 `Arcana_A.asi`와 원본 TGA는 보존했으며 게임 폴더에는 설치하지 않았다.

**이전 `20261013_blp_final` 팩은 게임에서 보라색·초록색으로 보이는 JPEG 색상 오류가 있으므로 사용하지 않는다.** 일반 JPEG의 YCbCr 변환을 제거하고 BLP1용 원시 B/G/R/A 네 성분으로 재생성했다. 기존 미리보기 검사는 JPEG 디코더의 자동 색 변환 때문에 이 오류를 발견하지 못했다.

## 적용 순서

1. 이미 #213의 BLP 경로 변경을 적용한 맵은 **이번 수정 ASI만 교체**하면 된다. 아직 적용하지 않은 맵은 #213의 Data/UI 변경을 맵 소스에 적용한다. 확장자를 `.blp`로 변경했으므로 **기존 TGA 경로를 사용하는 맵에 새 ASI만 교체하면 안 된다.**
2. Warcraft를 종료한 상태에서 설치된 `C:\Program Files (x86)\war3\Arcana_A.asi`를 별도 보관하고 새 파일로 교체한다. 기존 ASI 로드 방식과 파일명은 유지한다.
3. 맵에 자체 임포트된 TGA 대신 외부 BLP를 사용하는 변경이다. 새 BLP는 팩에 있으므로 맵에 중복 임포트할 필요가 없다. 기존 임포트의 일괄 삭제는 이 작업에 포함하지 않았다.
4. 사건 선택/본문/결과, 보유 카드/툴팁, 투명 테두리 및 일반 UI를 게임에서 확인한다. 문제 발생 시 이전 맵과 이전 ASI를 함께 복원한다.

`source-patch`에는 수정 변환기와 회귀 검사 사본, `images\war3mapImported`에는 재패키징할 BLP 원본이 있다.
`Arcana_B`의 미래 이미지 168개도 같은 팩에 넣었지만, 미래 스토리를 현재 게임에 등록하지는 않았다.

## 용량과 화질

- TGA 1,744개 변환, 기존 BLP 5개 보존, 총 1,749개.
- 불투명 1,378개는 BLP1 JPEG 품질 90, 4:4:4이며 색 변환 없이 B/G/R/A 성분을 저장한다.
- 투명 366개는 BLP1 256색 팔레트와 8비트 알파다. 원본 크기와 알파는 유지하지만 색 양자화/디더링으로 미세한 점무늬나 색 차이가 생긴다. 무손실 전환이 아니다.
- 변환 이미지의 전체 밉맵을 1×1까지 생성했다.
- 기존 설치 팩은 267,635,330바이트, 새 팩은 143,795,345바이트로 약 46.27% 작다. 오류가 있던 BLP 팩 91,239,304바이트보다는 52,556,041바이트 크다. 새 팩에는 미래 이미지 168개가 추가되어 두 팩의 구성은 동일하지 않다.
- 새 ASI SHA-256은 `6e4fe7077e1109794be2f72066a03a091f9ea2206f642f06e1ebfd488aaac59c`다.

## 검증 범위

이번 수정에서 수행한 검증은 다음과 같다.

- 정적/변환 검사. 원색·흰색·검정·혼합색 회귀 검사, JPEG 네 성분과 APP 색상 메타데이터 부재, 기존 YCbCr 형식 거부, 투명도 보존을 검사했다. 전체 변환본의 모든 밉맵 크기/경계/원시 디코딩을 확인했다.
- 패키지 검사. ASI 내부 1,749개 파일 해시와 완성 ASI 해시를 검증했다. 원본 파일 해시, 팔레트 BLP 366개와 기존 BLP 5개가 이전 작업과 동일함을 확인했다.
- 시각 검사. 원본과 원시 성분으로 디코딩한 액셀 사건 이미지 및 장비강화 배경을 비교했다. Pillow의 기본 BLP 색상 변환 결과는 호환성 검증 근거로 사용하지 않았다.
- 빌드/실행. 기존 로더로 ASI 패키징을 완료했다. JASS/UI 코드 변경은 없으므로 이번에는 맵 컴파일을 반복하지 않았다. Warcraft 실게임 표시·입력·멀티플레이 검증과 설치는 수행하지 않았다. 맵도 생성하지 않았다.

원본 TGA의 출처/해시 기록은 기존 content manifest에 그대로 남겼다. `content/blp-textures.json`이 변환 파일 목록이며 생성기는 이 목록에 있는 경로만 BLP로 출력한다. 기존 TGA 원본 검사용 `check-event-images.cjs`는 새 BLP 팩 검증기로 사용하지 않는다.

## 재생성

Pillow와 NumPy가 있는 Python으로 다음 명령을 실행한다. 출력 폴더는 존재하지 않는 새 경로를 사용한다.

```powershell
python -B tools/check-blp-color.py
python tools/convert-modelpack-blp.py --source D:\Work\ARCANA\war3mapImported --source D:\Work\ARCANA\Arcana_B\war3mapImported --output D:\Work\ARCANA\builds\asi\새폴더 --quality 90
& D:\Work\ARCANA\tools\asi-packager\ArcanaASIPackager.exe --source D:\Work\ARCANA\builds\asi\새폴더\images --output D:\Work\ARCANA\builds\asi\새폴더\Arcana_A.asi --report D:\Work\ARCANA\builds\asi\새폴더\pack-report.json
```

형식 참고는 [Magos BLP1 형식 문서](https://github.com/Kanma/BLPConverter/blob/master/doc/MagosBlpFormat.txt)다.

원시 JPEG 성분 처리 참고는 [blp-rs 인코더](https://github.com/WarRaft/blp-rs/blob/main/src/blp/encode.rs)다.
