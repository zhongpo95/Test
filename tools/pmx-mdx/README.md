# PMX 경량 MDX 변환

PMX의 얼굴·골격·기본 재질을 유지하여 클래식 MDX 800 및 BLP1으로 변환합니다. 얼굴 재질 0~6은 보존하고 나머지 메시를 Blender Decimate로 줄입니다. 삼각형 목표는 기본 20,000개이며, `--target-triangles 0`은 메시 축소를 생략합니다. 입력 PMX 및 텍스처와 기존 출력물을 덮어쓰지 않습니다.

## 의존성

- Blender 3.6.23과 Blender Python 3.10에서 읽을 수 있는 Pillow 10.4.0.
- [MMD Tools PMX 파서](https://github.com/MMD-Blender/blender_mmd_tools/tree/29d1478cf4385945b1c011d4c1e6adda7ad7cf70/mmd_tools/core/pmx). 외부 파서 및 모델 자산은 저장소에 포함하지 않습니다.
- Node.js와 `mdx-m3-viewer@5.12.0`. 의존성 루트의 `viewer/node_modules` 아래에 설치합니다.

```powershell
python -m pip download Pillow==10.4.0 --only-binary=:all: --platform win_amd64 --python-version 310 --implementation cp --abi cp310 --no-deps --dest $wheelFolder
npm install --prefix "$deps/viewer" mdx-m3-viewer@5.12.0 --ignore-scripts --no-audit --no-fund
```

Pillow wheel은 ZIP으로 읽어 임시 라이브러리 폴더에 풉니다. 시스템 Blender나 Python 설치를 수정하지 않고 해당 폴더만 `PYTHONPATH`에 추가합니다. PMX 파서의 경로는 `mmd_tools/core/pmx/__init__.py`입니다.

## 변환과 검사

출력은 비어 있는 새 폴더를 사용합니다. `$modelName`은 `Ming2_Base`처럼 짧은 ASCII 이름을 사용하며 텍스처 경로의 접두사로도 쓰입니다.

```powershell
$env:PYTHONPATH = $pillowFolder
blender.exe --background --factory-startup --python-exit-code 1 --python tools/pmx-mdx/convert.py -- --input $pmx --parser $pmxParser --output $output --name $modelName --target-triangles 20000
Remove-Item Env:\PYTHONPATH
node tools/pmx-mdx/write-validate.cjs $deps $output
```

맵에는 `$modelName.mdx`와 `$modelName/*.blp`만 가져옵니다. MDX 내부에 기록된 `$modelName\Texture_00.blp` 같은 사용자 지정 경로를 유지합니다. `geometry.json`, `pose.json`, JSON 검사 결과, RGBA 디코딩 파일은 검사 자료이며 맵 가져오기 파일이 아닙니다.

## 변환 범위

- 얼굴·눈·눈썹·입 재질 0~6은 축소하지 않습니다. PMX의 투명도가 0인 표정·의상 선택용 메시를 기본 외형에서 제외하고 `conversion.json`에 기록합니다. 이 재질 번호 규칙은 이번 입력 모델에서 확인한 구성에 맞춥니다.
- PMX Y축 위쪽을 워크래프트 Z축 위쪽으로 바꾸고, 기본 외형의 높이를 120단위로 맞춥니다. 모델 수평 중심 및 발바닥을 원점 기준으로 배치합니다.
- PMX 골격을 유지하고 이름을 `PMX_0000`처럼 ASCII로 바꿉니다. 원래 이름, 부모, 피벗은 변환 자료에 남깁니다. 가중치 뼈를 먼저 저장하고 보조 노드를 뒤에 배치하여 클래식 노드 인덱스를 맞춥니다.
- BDEF1/2/4 및 SDEF의 기본 가중치를 읽고 클래식의 네 칸 균등 행렬 그룹으로 근사합니다. SDEF의 특수 회전 보간, IK·부여 변형·물리·모프는 포함하지 않습니다.
- BLP1은 최대 1024 해상도, 256색 팔레트, 8비트 알파, 전체 밉맵입니다. PMX의 기본 텍스처·확산색·재질 투명도를 유지하고 구체 맵·toon 전용 셰이더는 포함하지 않습니다.
- 입력 폴더 밖의 텍스처 경로는 차단합니다. 누락 텍스처는 변환을 실패시키며, RGB가 검정인 단색 그림자 재질만 원래 검정색과 투명도를 유지하는 흰색 기본 텍스처를 사용합니다. 이번 입력의 누락 `T_actor_jsspsi_body_01_N.png`는 해당 그림자 재질입니다.
- 입력에 VMD 등 모션 파일이 없어 기본 자세 `Stand`만 만듭니다. 정적 장식 모델로 사용할 수 있으며 이동·공격·사망 동작을 만들지는 않습니다.

## 실제 검증 범위

- MDX 저장 후 독립 재읽기, 재저장 바이트 일치, 모든 지오셋의 정점·인덱스·스킨 참조·유한 좌표, 기본 자세 좌표 오차, BLP 전체 밉맵을 검사합니다.
- 지오셋은 정점 4096개와 행렬 그룹 256개 이하로 나눕니다. Origin 부착 위치를 포함합니다.
- 일반 유닛 검사의 `Missing "Death" sequence` 한 건은 정적 모델의 명시적인 제한으로 허용합니다. 다른 구조 오류나 심각한 문제는 실패합니다. 사망 동작이 존재한다고 보고하지 않습니다.
- `pose.json`과 독립 디코딩한 BLP를 이용한 Blender 앞·뒤·얼굴 렌더를 확인합니다. 실제 워크래프트·월드 에디터 불러오기나 인게임 성능은 별도 검사이며 렌더 성공으로 대체하지 않습니다.
