# 리링크 지크프리트 MDX 변환

설치된 게임에서 별도로 추출한 지크프리트 기본 복장 `pl1100`, 검 `wp1100`, 얼굴 `fp1100`을 클래식 MDX 800 및 BLP1로 변환합니다. LOD2 본체 15,778개, 검 954개, 얼굴 2,412개를 합쳐 19,144개 삼각형입니다. 전투용 변환은 비전투 모션을 제외하고 워크래프트 X·Y를 0,0으로 고정하며, 높이와 팔다리 동작은 유지합니다. 게임 원본과 이전 출력물을 덮어쓰지 않습니다.

## 준비

- Blender 3.6.23, Python 3.12와 NumPy/Pillow, Node.js.
- [GBFRDataTools 2.0.0](https://github.com/Nenkai/GBFRDataTools) 및 [GraniteTextureReader 1.1.5](https://github.com/Nenkai/GraniteTextureReader). 해당 실행 파일의 .NET 런타임이 필요합니다.
- 의존성 폴더 안의 `GBFRBlenderTools-main` 디렉터리에 [GBFRBlenderTools](https://github.com/WistfulHopes/GBFRBlenderTools/tree/b4f2e66f71e45c257b5e91eba3c9c8382b45f1cf) 소스가 있어야 합니다.
- `GBFR2Blender2GBFR-custom_bones` 디렉터리에 [MOT 파서가 있는 custom_bones 브랜치](https://github.com/WistfulHopes/GBFR2Blender2GBFR/tree/75446daaef4dd1342d47f0431685391483869ac9) 소스가 있어야 합니다.
- 독립 검증용 의존성을 `npm install --prefix "$deps/viewer" mdx-m3-viewer@5.12.0 --ignore-scripts --no-audit --no-fund`로 설치합니다.

게임 데이터와 외부 파서 소스는 저장소에 포함하지 않습니다. 외부 도구의 라이선스는 각각의 저장소를 참조합니다.

사운드 추출·이펙트 소재 변환은 [sound-effects.md](sound-effects.md)의 별도 절차와 제한을 따릅니다. EST 전체 입자 동작을 재현하는 도구는 아닙니다.

## 추출 입력

`$raw` 아래에 원래 상대 경로를 유지하여 다음 파일을 추출합니다. 아래 명령의 `$archive`는 설치 폴더의 `data.i`를 가리킵니다.

```powershell
GBFRDataTools.exe extract -i $archive -f model/pl/pl1100/pl1100.minfo -o $raw
GBFRDataTools.exe extract -i $archive -f model/pl/pl1100/pl1100.skeleton -o $raw
GBFRDataTools.exe extract -i $archive -f model/pl/pl1100/vars/0.mmat -o $raw
GBFRDataTools.exe extract -i $archive -f model/wp/wp1100/wp1100.minfo -o $raw
GBFRDataTools.exe extract -i $archive -f model/wp/wp1100/wp1100.skeleton -o $raw
GBFRDataTools.exe extract -i $archive -f model/wp/wp1100/vars/0.mmat -o $raw
GBFRDataTools.exe extract -i $archive -f model/fp/fp1100/fp1100.minfo -o $raw
GBFRDataTools.exe extract -i $archive -f model/fp/fp1100/fp1100.skeleton -o $raw
GBFRDataTools.exe extract -i $archive -f model/fp/fp1100/vars/0.mmat -o $raw
GBFRDataTools.exe extract -i $archive -f model_streaming/lod2/pl1100.mmesh -o $raw
GBFRDataTools.exe extract -i $archive -f model_streaming/lod2/wp1100.mmesh -o $raw
GBFRDataTools.exe extract -i $archive -f model_streaming/lod2/fp1100.mmesh -o $raw
GBFRDataTools.exe extract-all -i $archive -f pl/pl1100/ -o $raw
```

LOD 선택을 바꾸면 같은 번호의 메시를 추가로 추출해야 합니다. 텍스처는 `granite/2k/gts/1/1.gts`와 아래 해시의 `.gtp` 파일을 추출하고, 각 가상 텍스처를 GraniteTextureReader의 `extract -t <1.gts> -f <해시> -o <텍스처 폴더>`로 복원합니다. `-l 0`에 해당하는 알베도 TGA를 사용합니다.

| 알베도 | 가상 텍스처 해시 |
| --- | --- |
| pl1100_armor_lod0_albd | 0571c7ac9dd06171da16b4a2318e4114af1411121355b85032a4574afed4073d |
| pl1100_cloth_lod0_albd | bbb4f7816b1fde07a01315ab76786bffa119a48e507ca9e0299118c6ee29f7b8 |
| pl1100_hair_lod0_albd | bdca879e3f553a2dd7674fb1e1f85c263f200c6404a450ed78f2f86ed1ca46d7 |
| pl1100_skin_lod0_albd | 7a452d012d62e14b719cb96ada820b5370f2dddece0466859a791d9ade043824 |
| wp1100_lod0_albd | 25ed65e72930baecabb32aa864ec08f758ccbd445490615adf07933cadcd6d7c |
| fp1100_face_lod0_albd | 5e5bfc594e5856204288fd65a2b66a4c5c3012716bae3314ccdfcca96b9f2b1f |

검 텍스처는 같은 폴더의 `97da40170d14745a559f5517e599f224ec2d9cc76b789967ebef136420ebfbe7.gtp`도 필요합니다. 이 경로와 해시는 현재 설치 데이터에서 확인한 값이며 다른 게임 버전에서는 재확인이 필요합니다.

눈은 고정 해상도 원본이 있는 `granite/4k/gts/2/2.gts`를 사용합니다. 왼눈 페이지는 `fb172709ef4d3e6db5885f1d002b471c2d4ea918769cf150ae0b5bf4c8647e06`, 오른눈 페이지는 `f83912e2c87f82b88abdb52a4b3c4219ad26248bfb2d3820140afe56484f7312`입니다. 각각 `-l 0` 흰자, `-l 1` 홍채, 왼눈의 `-l 2` 공유 하이라이트를 복원합니다. 페이지에 걸친 공유 하이라이트 때문에 양쪽 GTP가 모두 필요합니다. `textures.py`는 같은 UV의 원본 RGBA를 합성하여 눈마다 불투명 확산 BLP를 만듭니다. 리링크의 눈 시차 셰이더는 재현하지 않습니다.

## 변환과 검증

`$output`은 비어 있는 새 폴더여야 합니다. `--motions 0000 0010 0520 3000 3400` 같은 옵션으로 먼저 일부 모션만 검사할 수 있습니다.

```powershell
blender.exe --background --factory-startup --python-exit-code 1 --python tools/relink-mdx/convert.py -- --raw $raw --dependencies $deps --output $output --lod 2 --combat-only --in-place
python tools/relink-mdx/textures.py --source $textures --model-folder $output
node tools/relink-mdx/validate.cjs $deps $output
python tools/relink-mdx/compare.py $output
```

최종 게임 가져오기 파일은 `Siegfried.mdx`와 `Siegfried\*.blp` 여덟 개입니다. BLP의 사용자 지정 가져오기 경로에서 `Siegfried\` 접두사를 그대로 유지합니다. NPZ, JSON, RGBA는 원본 대조와 렌더링을 위한 검사 자료로, 맵에 가져올 필요가 없습니다.

`conversion.json`에는 원본 모션 파일, MDX 구간, 제외한 모션 및 모든 프레임의 골반 높이가 기록됩니다. `--combat-only`는 현재 설치본 292개 중 149개를 유지합니다. 기본 동작 세 개와 나머지 전투 모션 146개를 다음처럼 연결합니다. 달리기는 후보 자세를 보고 선택했고, 사망에는 뒤로 넘어지는 `0520`을 사용합니다. 전투 모션은 원본 ID 순으로 연속 번호를 부여하며, 일반 공격도 사용자의 요청에 따라 `Spell - 번호`로 바꿉니다.

| MDX 시퀀스 | 원본 ID |
| --- | --- |
| Stand | 0000 |
| Walk | 0010 |
| Death | 0520 |
| Spell - 1 ~ 146 | 아래 전투 범위의 원본 ID 순서 |

전투 범위는 회피·가드·점프 전환 `0030..0052`, 검 준비 `0060`, 공중 전환 `0065..0067`, 점프·공중 회피·착지 `0080..00a2`, 피격·다운·회복 `0500..067f`, 링크/오의 `1800..1820`, 공격·스킬 `3000..3aff`입니다. 원본 액션 설정의 일반·저스트·공중 공격, 가드 및 여덟 스킬 참조는 존재하는 MOT 파일에 대해 모두 포함합니다. 대기 변형, 추가 이동 변형, 감정 표현, 컷신 및 기타 연출 모션 143개를 제외합니다. 원본 액션 설정에만 있고 실제 MOT가 없는 `3021`, `3022`는 생성하지 않습니다. 필요하면 `--motions`로 유지 목록 안에서 일부만 검사할 수 있습니다.

번호별 원본 액션은 배포 패키지의 `motions.csv`에서 확인합니다. JASS에서 특정 번호를 정확히 선택하려면 이 파일의 0부터 시작하는 인덱스를 `SetUnitAnimationByIndex`에 사용합니다.

## 변환 범위와 검증 경계

- 60fps 원본 뼈 모션을 샘플링한 후 위치 0.02 워크래프트 단위, 회전 0.1도, 스케일 0.0002 허용 오차로 키를 줄입니다. `--in-place`에서는 원본 X·Z, 즉 워크래프트 X·Y의 골반 이동을 루트에서 상쇄합니다. 골반까지의 조상 노드 키를 줄이지 않아 원점 고정을 유지하며, 높이는 변경하지 않습니다. 독립 파서는 유지한 모든 프레임에서 XY 및 높이 오차가 0.002단위 이하인지 검사합니다.
- 검은 오른손 소켓 `pl1100_400`에 연결합니다. Y축 위쪽 좌표를 Z축 위쪽으로 바꾸고 원본 1단위를 워크래프트 60단위로 변환합니다.
- 얼굴은 본체의 목·머리 뼈 `_004`, `_005`, `_a04`를 공유합니다. 얼굴 전용 뼈의 바인드 좌표를 유지하고 독립 루트를 머리에 연결하므로, 얼굴·눈이 모든 모션에서 머리를 따라갑니다. 표정은 중립이며 별도 FP 표정 MOT는 포함하지 않습니다.
- 클래식 SD의 균등한 행렬 그룹에 맞춰 스킨 가중치를 네 칸으로 근사합니다. 원본의 연속 가중치와 완전히 동일한 메시 변형은 아닙니다.
- 각 지오셋은 정점 4,096개 및 행렬 그룹 256개 이하로 나눕니다. 시퀀스별 경계는 모든 프레임의 영향을 받는 뼈와 메시 범위를 포함합니다.
- BLP1은 256색 팔레트, 8비트 알파, 전체 밉맵을 포함합니다. 노멀 맵, 리링크 셰이더, VFX, IK, 실시간 천·머리카락 물리는 포함하지 않습니다.
- 일부 연출 MOT에는 본체 스켈레톤에 없는 `0x7000` 이상의 채널이 있습니다. 해당 채널은 본체 뼈 모션에서 제외하고 `conversion.json`의 `missing_bones`에 원본 ID를 기록합니다. 캐릭터 뼈에 해당하는 채널은 별도로 유지합니다.
- 독립 파서의 MDX 재저장 바이트 일치, BLP 전체 밉맵 디코딩, 구조 검사 및 유지한 모든 시퀀스의 시작·중간·끝 자세 원본 대조를 수행합니다. 얼굴까지 포함하여 메시 매핑 누락도 검사합니다. 사용되지 않는 원본 노드와 시퀀스 경계 키는 미사용 항목으로 보고될 수 있습니다.
- `pose-comparison.json`은 키 축소 후 내보내기 오차와 SD 가중치 근사 오차를 별도로 기록합니다. 대표 프레임의 내보내기 최대 오차가 0.5단위를 초과하면 검증이 실패합니다.
- 실제 워크래프트 및 월드 에디터에서의 불러오기, 애니메이션 자동 선택과 성능은 별도의 런타임 시험이 필요합니다. 독립 파서나 Blender 렌더 성공이 게임 실행 검증을 대신하지 않습니다.

## 머리갑옷 변형과 압축 아틀라스

현재 설치본의 `pl1101`은 얼굴을 덮는 머리갑옷 복장입니다. `model/pl/pl1101/`와 `model_streaming/lod2/pl1101.mmesh`를 추가 추출하고 `--body-variant pl1101`로 변환합니다. 기본 `pl1100` 스켈레톤과 바이트가 일치하는지 검사하며, MOT는 기존 `pl/pl1100`에서 읽습니다. 검 `wp1100`과 별도 얼굴·눈 `fp1100`을 함께 연결하고, 변형마다 다른 재질 수에 맞춰 슬롯을 계산합니다. LOD2 본체·검·얼굴 합계는 15,021개 삼각형입니다. `pl1102`는 하관 보호대가 추가된 별도 머리갑옷 형태이며 `--body-variant pl1102`로 변환합니다. 합계 15,273개 삼각형이고 스켈레톤·MOT와 텍스처 여덟 장은 PL1101과 공유합니다.

머리갑옷 알베도는 기존 `granite/2k/gts/1/1.gts`의 프로젝트 자료에서 확인한 `605da43698ba626975793c2156bda51f0a09ba30fc6aa49f21559d14613766f6` 페이지입니다. 해당 `1_<해시>.gtp`를 같은 GTS 폴더에 추가 추출하고 GraniteTextureReader `extract -t <1.gts> -f <해시> -l 0`으로 복원합니다. 게임 버전이 바뀌면 재확인이 필요합니다.

```powershell
blender.exe --background --factory-startup --python-exit-code 1 --python tools/relink-mdx/convert.py -- --raw $raw --dependencies $deps --output $helmetOutput --lod 2 --body-variant pl1101 --combat-only --in-place
python tools/relink-mdx/pack-atlas.py --source $textures --helmet-source $helmetTextures --model-folder $helmetOutput --output $atlasRoot
node tools/relink-mdx/apply-atlas.cjs $deps $helmetOutput $atlasRoot $atlasOutput
node tools/relink-mdx/validate.cjs $deps $atlasOutput
python tools/relink-mdx/compare.py $atlasOutput --source-folder $helmetOutput
```

`pack-atlas.py`는 확인한 PL1101/PL1102 공유 텍스처 여덟 장 전용 배치입니다. 갑옷·천·머리갑옷·검은 1024 아틀라스, 얼굴·피부·눈은 512 아틀라스에 묶습니다. 타일에 가장자리 복제 여백 8픽셀을 두고 원본 TGA와 눈 합성 이미지에서 JPEG 품질 95, BGRA 4성분 BLP1을 생성합니다. 큰 타일 내용은 496, 얼굴·피부는 240, 각 눈은 112 해상도입니다. 해상도 축소와 JPEG 손실 압축을 함께 적용합니다.

`apply-atlas.cjs`는 UV가 0~1 범위이고 단일 UV·재질 레이어, 반복과 텍스처 애니메이션이 없는 입력만 처리합니다. UV와 텍스처 참조를 원복한 MDX가 원래 변환 파일과 바이트 단위로 일치하는지 검사하여 메시·스킨·모션 보존을 확인합니다. BLP 전체 밉도 독립 디코딩합니다. 원래 출력과 아틀라스 출력은 별도 폴더를 사용하며, 최상위 `.rgba`를 검사 결과의 폭·높이로 PNG로 변환하면 미리보기에 사용할 수 있습니다. 일반 CMYK 색공간 변환을 적용하거나 알파를 버리는 BLP 리더를 쓰면 안 됩니다.

최종 경로는 `Siegfried_Helmet\\Atlas_Armor.blp`, `Siegfried_Helmet\\Atlas_Face.blp` 두 개이며 합계 1,487,282바이트입니다. MDX 파일은 배포 시 `Siegfried_Helmet.mdx`로 이름을 바꿔도 내부 BLP 경로는 그대로 유지됩니다. 두 번째 복장은 `Siegfried_Helmet_2.mdx`로 배포하며 두 모델이 같은 BLP 두 장을 참조합니다. 함께 가져올 때 텍스처는 한 번만 추가합니다. 작은 밉에서는 인접 타일이 섞일 수 있으며, 실제 워크래프트·월드 에디터의 가져오기와 원거리 외형은 미검증입니다.

## 닫힌 머리갑옷 안쪽 얼굴 정리

PL1102의 하관 보호대 안에서는 별도 FP1100 얼굴·눈·입 메시와 본체의 얼굴 조각을 제거합니다. PL1101의 노출된 입은 유지합니다. 서로 동일한 삼각형인지 여부만으로 갑옷 밖으로 겹치는지를 판단할 수 없으므로, 렌더에서 실제 가려지는 영역을 확인한 PL1102 LOD2에만 적용합니다.

```powershell
node tools/relink-mdx/remove-inner-head.cjs $deps $atlasOutput $cleanOutput
node tools/relink-mdx/validate.cjs $deps $cleanOutput
python tools/relink-mdx/compare.py $cleanOutput --source-folder $helmetOutput
```

이 후처리는 확인한 원본 배치에서 별도 얼굴 2,412개와 본체 안쪽 얼굴 76개, 총 2,488개 삼각형을 제거합니다. 갑옷·검·목 피부와 나머지 메시·스킨·UV·재질·텍스처·149개 모션 및 뼈는 바꾸지 않습니다. 제거한 지오셋을 원복한 MDX가 입력과 바이트 단위로 일치하는지 검사하며, 최종 삼각형은 12,785개입니다. 기존 범위는 보수적인 경계로 유지합니다. 이전 파일과 혼동하지 않도록 정리본을 `Siegfried_Helmet_2_v3.mdx`로 따로 배포하고, BLP는 기존 공유 경로 두 개를 그대로 사용합니다.

얼굴 메시를 제거한 후에도 노드 ID와 모션 채널을 보존하기 위해 얼굴 뼈는 유지합니다. 구조 검사에서 정점이 연결되지 않은 뼈 경고 91개가 발생하며, 다른 경고·오류·심각한 문제는 없습니다. 이 경고를 숨기기 위해 노드 종류나 계층을 바꾸지 않습니다. 실제 워크래프트·월드 에디터에서의 재생은 미검증입니다.
