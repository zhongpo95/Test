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
- 기본 변환은 입력 모션 파일이 없는 PMX에 정적인 `Stand`를 만듭니다. 아래의 사 대기 제작 단계는 이 기본 변환에 두 개의 대기를 추가합니다. 이동·공격·사망 동작은 만들지 않습니다.

## 실제 검증 범위

- MDX 저장 후 독립 재읽기, 재저장 바이트 일치, 모든 지오셋의 정점·인덱스·스킨 참조·유한 좌표, 기본 자세 좌표 오차, BLP 전체 밉맵을 검사합니다.
- 지오셋은 정점 4096개와 행렬 그룹 256개 이하로 나눕니다. Origin 부착 위치를 포함합니다.
- 일반 유닛 검사의 `Missing "Death" sequence` 한 건은 정적 모델의 명시적인 제한으로 허용합니다. 다른 구조 오류나 심각한 문제는 실패합니다. 사망 동작이 존재한다고 보고하지 않습니다.
- `pose.json`과 독립 디코딩한 BLP를 이용한 Blender 앞·뒤·얼굴 렌더를 확인합니다. 실제 워크래프트·월드 에디터 불러오기나 인게임 성능은 별도 검사이며 렌더 성공으로 대체하지 않습니다.

## 사의 두 대기 모션

`stand-motion.cjs`는 이번 사 모델의 본 이름과 비율을 확인하여 만든 전용 제작 도구입니다. 임의의 PMX에 적용하는 범용 리타게터가 아닙니다. 원본 모션을 추출한 파일이 아니라 [사용자 지정 영상](https://www.youtube.com/watch?v=3E3QgXVwTeA)의 자세와 첨부 이미지를 보고 골격 키를 새로 작성합니다.

| MDX 시퀀스 | 참고 구간 | 반복 길이 | 동작 |
| --- | --- | --- | --- |
| Stand - 1 | 1:48~1:55 | 7초 | 손을 입가로 올려 흠 제스처를 하고 내립니다. |
| Stand - 2 | 1:36~1:37 | 4초 | 팔짱 자세를 유지하며 가볍게 호흡합니다. |

입·턱·혀의 개별 키는 만들지 않습니다. 원본 PMX의 눈 감기 모프를 눈 주변에만 적용하고 흠 동작 및 팔짱의 눈 깜빡임에 사용합니다. 원점은 고정하고 양발은 비대칭 기본 자세의 접지 위치를 유지합니다. 골반에는 작은 체중 이동을 허용합니다. 일반 Stand 계열 두 개로 저장하므로 Alternate 속성을 추가할 필요가 없습니다. 특정 동작은 시퀀스 인덱스 0 또는 1로 선택할 수 있습니다.

영상의 전신 자세를 참고하여 오른쪽 다리에 체중을 두고 왼쪽 무릎을 부드럽게 굽힙니다. 골반과 가슴의 기울기를 나누고 어깨를 낮추며 상체와 고개의 방향을 다르게 잡습니다. 발은 원래 차렷 자세에서 조금 앞뒤로 배치하고 다리 IK를 키로 구워 접지를 유지합니다.

흠 동작은 팔꿈치를 낮게 두고 아래팔을 앞으로 회전시키는 경로를 직접 작성합니다. 손목은 아래팔의 방향을 따르고 비틀림을 두 본에 분산합니다. 상체 회전에 맞춰 팔짱 손의 목표를 계산하고 흠 동작의 손은 고개 기울기에 맞춰 입가로 올립니다. 내린 팔은 몸통에 붙이지 않고 팔꿈치를 느슨하게 벌립니다. 원본 관절 축으로 손가락을 접고 엄지를 안으로 모읍니다. 팔짱은 위쪽 손을 반대 팔에 얹고 아래쪽 손을 팔 아래에 접습니다. 어깨 장식의 방향을 유지하고 소매 판과 긴 소매를 아래로 처지게 하며 머리카락에는 작은 후행 움직임을 줍니다.

정적인 기본 변환 폴더와 같은 원본 PMX를 입력으로 사용하고 출력은 새 경로로 지정합니다. `prepare-stand.py`에는 Python 3 및 NumPy가 필요합니다. 원본 파일 해시와 좌표 변환을 확인하고 관절 축 및 눈 감기 자료를 생성합니다. 눈 변위를 96개 이하의 군집으로 근사하며 최대 오차가 0.13 워크래프트 단위를 넘으면 실패합니다.

모션 단계는 MDX와 검사 자료만 생성하며 BLP 경로와 메시 정점·노멀·UV·삼각형을 유지합니다. 눈 주변의 스킨 그룹만 추가한 눈 감기 본으로 바꿉니다. 가중치가 없어지는 원래 본은 계층과 이름을 유지하는 Helper로 저장하며 CSV에는 변경된 노드 번호를 기록합니다. 배포할 때 기본 변환의 BLP도 함께 복사해야 합니다.

```powershell
python tools/pmx-mdx/prepare-stand.py --parser $pmxParser --input $pmx --base $baseConversion --output $motionRig
node tools/pmx-mdx/stand-motion.cjs $deps $baseConversion $motionOutput $motionRig
blender.exe --background --factory-startup --python-exit-code 1 --python tools/pmx-mdx/render-stand.py -- $baseConversion $motionOutput --animate
```

렌더 입력은 `write-validate.cjs`가 생성한 `pose.json` 및 BLP 디코딩 PNG입니다. 모션 도구는 재읽은 MDX의 채널과 스킨 그룹을 `render-motion.json`에 내보내고 Blender가 이를 다시 계산하여 프레임을 만듭니다. `--animate`를 생략하면 대표 자세의 전신·상체 PNG만 렌더합니다. 연속 프레임은 발까지 보이는 전신 구도로 렌더합니다.

- MDX 바이트 재저장 일치, 원래 메시·텍스처 경로 및 눈 주변 이외의 스킨 그룹 보존과 구조 오류를 검사합니다.
- 50ms 키로 회전을 저장하고 재읽기 후 25ms 간격으로 행렬과 원점, 양발의 접지 목표 및 발·발끝 본에만 가중된 발 메시 정점을 확인합니다. 골반 변위는 4.5 단위 이내, 발 접지와 정점의 움직임은 0.01 단위 이내를 검사합니다. 500ms 간격으로 제작 좌표와 재읽기 좌표를 비교합니다.
- 인접 회전 키의 변화가 12도를 넘으면 실패합니다. 눈 감기 변위는 위치 채널로 저장하고 렌더에서도 재읽은 채널을 계산합니다.
- 반복 시작·끝 정점 오차와 입 본의 직접 애니메이션 부재를 검사합니다. 각 시퀀스 및 지오셋의 애니메이션 범위를 다시 계산합니다.
- 두 모델에서 구조 오류·경고는 0건이고 Death 부재 1건만 알려진 제한으로 남습니다.
- 렌더와 GIF는 제작 및 외형 확인 자료입니다. 실제 워크래프트·월드 에디터의 재생 검증을 뜻하지 않습니다.
