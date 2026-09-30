# 리링크 지크프리트 MDX 변환

설치된 게임에서 별도로 추출한 지크프리트 기본 복장 `pl1100`과 검 `wp1100`을 클래식 MDX 800 및 BLP1로 변환합니다. LOD2 본체 15,778개와 검 954개를 합쳐 16,732개 삼각형을 유지하며, `pl/pl1100`의 MOT 파일을 각각 독립된 시퀀스로 넣습니다. 게임 원본과 이전 출력물을 덮어쓰지 않습니다.

## 준비

- Blender 3.6.23, Python 3.12와 NumPy/Pillow, Node.js.
- [GBFRDataTools 2.0.0](https://github.com/Nenkai/GBFRDataTools) 및 [GraniteTextureReader 1.1.5](https://github.com/Nenkai/GraniteTextureReader). 해당 실행 파일의 .NET 런타임이 필요합니다.
- 의존성 폴더 안의 `GBFRBlenderTools-main` 디렉터리에 [GBFRBlenderTools](https://github.com/WistfulHopes/GBFRBlenderTools/tree/b4f2e66f71e45c257b5e91eba3c9c8382b45f1cf) 소스가 있어야 합니다.
- `GBFR2Blender2GBFR-custom_bones` 디렉터리에 [MOT 파서가 있는 custom_bones 브랜치](https://github.com/WistfulHopes/GBFR2Blender2GBFR/tree/75446daaef4dd1342d47f0431685391483869ac9) 소스가 있어야 합니다.
- 독립 검증용 의존성을 `npm install --prefix "$deps/viewer" mdx-m3-viewer@5.12.0 --ignore-scripts --no-audit --no-fund`로 설치합니다.

게임 데이터와 외부 파서 소스는 저장소에 포함하지 않습니다. 외부 도구의 라이선스는 각각의 저장소를 참조합니다.

## 추출 입력

`$raw` 아래에 원래 상대 경로를 유지하여 다음 파일을 추출합니다. 아래 명령의 `$archive`는 설치 폴더의 `data.i`를 가리킵니다.

```powershell
GBFRDataTools.exe extract -i $archive -f model/pl/pl1100/pl1100.minfo -o $raw
GBFRDataTools.exe extract -i $archive -f model/pl/pl1100/pl1100.skeleton -o $raw
GBFRDataTools.exe extract -i $archive -f model/pl/pl1100/vars/0.mmat -o $raw
GBFRDataTools.exe extract -i $archive -f model/wp/wp1100/wp1100.minfo -o $raw
GBFRDataTools.exe extract -i $archive -f model/wp/wp1100/wp1100.skeleton -o $raw
GBFRDataTools.exe extract -i $archive -f model/wp/wp1100/vars/0.mmat -o $raw
GBFRDataTools.exe extract -i $archive -f model_streaming/lod2/pl1100.mmesh -o $raw
GBFRDataTools.exe extract -i $archive -f model_streaming/lod2/wp1100.mmesh -o $raw
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

검 텍스처는 같은 폴더의 `97da40170d14745a559f5517e599f224ec2d9cc76b789967ebef136420ebfbe7.gtp`도 필요합니다. 이 경로와 해시는 현재 설치 데이터에서 확인한 값이며 다른 게임 버전에서는 재확인이 필요합니다.

## 변환과 검증

`$output`은 비어 있는 새 폴더여야 합니다. `--motions 0000 0010 0520 3000 3400` 같은 옵션으로 먼저 일부 모션만 검사할 수 있습니다.

```powershell
blender.exe --background --factory-startup --python-exit-code 1 --python tools/relink-mdx/convert.py -- --raw $raw --dependencies $deps --output $output --lod 2
python tools/relink-mdx/textures.py --source $textures --model-folder $output
node tools/relink-mdx/validate.cjs $deps $output
python tools/relink-mdx/compare.py $output
```

최종 게임 가져오기 파일은 `Siegfried.mdx`와 `Siegfried\*.blp` 다섯 개입니다. BLP의 사용자 지정 가져오기 경로에서 `Siegfried\` 접두사를 그대로 유지합니다. NPZ, JSON, RGBA는 원본 대조와 렌더링을 위한 검사 자료로, 맵에 가져올 필요가 없습니다.

`conversion.json`에는 원본 모션 파일과 MDX 구간이 기록됩니다. 기본 동작은 다음과 같이 연결했습니다. 원본 지크프리트 액션 설정에서 `3000`부터 `3004`까지의 일반 공격 콤보와 `3400`의 마니강스를 확인했습니다. 달리기는 후보 자세를 보고 선택했고, 사망에는 원본의 뒤로 넘어지는 `0520` 모션을 사용합니다. 나머지 시퀀스 이름은 `Relink <원본 ID>`이며 명시적인 애니메이션 선택용입니다.

| MDX 시퀀스 | 원본 ID |
| --- | --- |
| Stand | 0000 |
| Stand Alternate | 0001 |
| Walk | 0010 |
| Attack - 1 ~ 5 | 3000 ~ 3004 |
| Spell | 3400 |
| Death | 0520 |

## 변환 범위와 검증 경계

- 60fps 원본 뼈 모션을 샘플링한 후 위치 0.02 워크래프트 단위, 회전 0.1도, 스케일 0.0002 허용 오차로 키를 줄입니다. 이동량과 회전, 점프 높이를 유지하므로 일부 공격·연출 모션에는 원본의 큰 이동이 남아 있습니다.
- 검은 오른손 소켓 `pl1100_400`에 연결합니다. Y축 위쪽 좌표를 Z축 위쪽으로 바꾸고 원본 1단위를 워크래프트 60단위로 변환합니다.
- 클래식 SD의 균등한 행렬 그룹에 맞춰 스킨 가중치를 네 칸으로 근사합니다. 원본의 연속 가중치와 완전히 동일한 메시 변형은 아닙니다.
- 각 지오셋은 정점 4,096개 및 행렬 그룹 256개 이하로 나눕니다. 시퀀스별 경계는 모든 프레임의 영향을 받는 뼈와 메시 범위를 포함합니다.
- BLP1은 256색 팔레트, 8비트 알파, 전체 밉맵을 포함합니다. 노멀 맵, 리링크 셰이더, VFX, IK, 실시간 천·머리카락 물리는 포함하지 않습니다.
- 일부 연출 MOT에는 본체 스켈레톤에 없는 `0x7000` 이상의 채널이 있습니다. 해당 채널은 본체 뼈 모션에서 제외하고 `conversion.json`의 `missing_bones`에 원본 ID를 기록합니다. 캐릭터 뼈에 해당하는 채널은 별도로 유지합니다.
- 독립 파서의 MDX 재저장 바이트 일치, BLP 전체 밉맵 디코딩, 구조 검사 및 대표 자세의 원본 대조를 수행합니다. `Relink` 사용자 지정 시퀀스 이름과 사용되지 않는 원본 노드는 구조 검사에서 경고나 미사용 항목으로 보고될 수 있습니다.
- `pose-comparison.json`은 키 축소 후 내보내기 오차와 SD 가중치 근사 오차를 별도로 기록합니다. 대표 프레임의 내보내기 최대 오차가 0.5단위를 초과하면 검증이 실패합니다.
- 실제 워크래프트 및 월드 에디터에서의 불러오기, 애니메이션 자동 선택과 성능은 별도의 런타임 시험이 필요합니다. 독립 파서나 Blender 렌더 성공이 게임 실행 검증을 대신하지 않습니다.
