# 지크프리트 사운드와 이펙트 소재

설치된 PL1100·WP1100 사운드 뱅크와 PL1100 EST를 별도 출력 폴더로 추출합니다. 이전 모델·모션·배포물은 변경하지 않습니다. 게임 원본과 외부 실행 파일·파서 소스는 Git에 넣지 않습니다.

## 사운드

맵용 기본 범위는 **스킬 8종과 오의의 호출 후보만** 사용합니다. 전체 뱅크 출력에는 필드·마을·일반 전투 대사가 섞여 있으므로 검증된 HIRC 표에서 원본 스킬 액션의 모션을 따라 선택합니다. `--actions`는 원본 ActionInfo에서 만든 `id/name/motions` 목록이며, 스킬 전용 출력의 `Info/source-skill-actions.json`으로 선택 절차를 다시 실행할 수 있습니다.

```powershell
python tools/relink-mdx/select_skill_sound.py --sound $sound --actions $actions --output $skillSound
```

기본 언어 선택은 **일본어 음성 + 효과음**입니다. 2026-10-04 선택 결과는 **128개 / 5,420,932바이트**입니다. 일본어 78개, 효과음 50개이며 모션 호출 57행 중 54행에 음원이 있습니다. 스킬은 원본 액션의 정확한 `34xx` 모션 목록, 오의는 `1800/1810/1820`만 선택합니다. 일반 공격·피격·이동은 선택의 출발점으로 사용하지 않으며, 스킬에서 함께 호출하는 공용 검 소리는 포함합니다. 음성 파일명이 스킬/오의 계열인지도 검사합니다. 기존 디코딩 검사와 SHA-256이 일치하는 파일을 재사용하고, 공유 파일은 한 번만 복사합니다. 임의로 후보 하나만 고르지 않습니다.

스킬 전용 HTML 목록은 스킬별 필터와 동적으로 계산한 파일 수를 표시하며, 선택에 없는 언어 항목은 표시하지 않습니다. `Info/스킬별_사운드.csv`에는 원본 모션·MDX Spell 번호·호출 시점·이벤트·재생 후보가 들어 있습니다. 오의 공용 호출 `core_ougi_cut_in`, `core_ougi_stop_pl1100`은 미해결로 표시합니다. 기존 전체 출력은 별도 백업으로 옮겨 보존하며, 새 패키지는 영어·원본 BNK·무관한 음원을 다시 포함하지 않습니다.

Python **3.12**, [vgmstream r2117](https://github.com/vgmstream/vgmstream/releases/tag/r2117), [wwiser v20260808](https://github.com/bnnm/wwiser/releases/tag/v20260808), 별도 폴더에 설치한 `lameenc==1.8.4`가 필요합니다. `audioop`는 Python 3.13에서 제거되어 이 도구는 3.12를 사용합니다. 뱅크는 설치본 `data/sound`에 있습니다. [리링크 오디오 문서](https://nenkai.github.io/relink-modding/tutorials/audio/audio_extraction/)를 참고합니다.

```powershell
python tools/relink-mdx/asset_events.py --raw $raw/pl/pl1100 --conversion $model/conversion.json --output $events
python tools/relink-mdx/extract_sound.py --game $game --vgmstream $vgmstream --pylibs $pylibs --events $events/motion-events.json --output $sound --work $soundWork
python tools/relink-mdx/link_sound_events.py --game $game --wwiser $wwiser --sound $sound --events $events/motion-events.json --work $hircWork
```

모든 출력·작업 폴더는 새 경로를 사용합니다. `vo_pl1100*`, `pl1100*`, `wp1100*` BNK의 DIDX/DATA를 읽고 언어·미디어 ID·원본 SHA-256이 같은 항목을 중복 제거합니다. 원본 BNK는 해시와 함께 보존합니다. WEM은 원래 샘플 수 전체를 디코딩하고, 음성은 MP3 모노 44.1kHz 96kbps, 효과음은 PCM16 WAV 모노 22.05kHz로 만듭니다. 스테레오는 두 채널의 평균을 사용하며 음량 정규화는 하지 않습니다. 반복 구간을 반복 렌더하지 않고 전체 1회분을 내보내며 원래 반복 정보는 JSON에 남깁니다. 최종 파일도 전체 디코딩하여 채널·샘플레이트·길이를 검사합니다.

`Info/sound-list.csv`는 원본 뱅크별 미디어 목록, `sound-manifest.json`은 중복 제거 파일·해시·디코딩 검사입니다. `motion-sounds.csv`는 파일명 마커만으로 찾은 초기 후보이며 정확한 호출표로 쓰지 않습니다. **`hirc-motion-sounds.csv`**는 원본 BXM 이벤트의 Wwise 해시에서 Event→ActionPlay→Child→Source ID를 따라 찾은 후보입니다. 여러 뱅크 버전·랜덤 분기·스위치 후보의 합집합으로, 믹싱·조건 선택·피치·음량·정지 동작을 재현하지 않습니다. 모든 샘플을 자동으로 모델에 연결하지 않습니다.

2026-10-04 설치본에서는 27개 뱅크의 5,375개 미디어 항목에서 일본어 음성 2,134개, 영어 음성 2,105개, 효과음 959개, 총 **5,198개 파일 / 62,611,698바이트**를 만들었습니다. 전투 외 필드·마을 대사도 포함합니다. 이벤트 언어별 235행 중 217행에 재생 후보가 연결되었습니다. 정지 이벤트 외 미해결 공용 호출은 `core_pl_sword_justguard_B`, `core_ougi_stop_pl1100`, `core_ougi_cut_in`입니다. 재생 가능한 공용 소리를 찾았다고 가정하지 않습니다.

## 이펙트 소재

Python 3.12·Pillow·NumPy, 기존 `pack-atlas.py`, `mdx-m3-viewer@5.12.0`, Blender 3.6.23을 사용합니다. `$fxRaw`에 원래 경로로 `effect/pl1100.bxm`, `effect/savedata/pl1100/*.est`, 참조된 `effect/texture/###/*` 전체를 추출합니다. `.texture`는 GBFRDataTools `tex-to-dds`로 DDS를 준비하며 원본과 DDS는 구분합니다. 현재 설치본에서 확인한 참조 리소스는 다음과 같습니다.

```text
000 001 002 003 004 005 006 007 008 009 011 012 013 016 018 020 021 035
041 048 155 156 157 158 161 162 168 170 172 173 174 192 249 455 550 581
```

```powershell
GBFRDataTools.exe tex-to-dds -i $fxRaw/effect/texture
python tools/relink-mdx/effect_materials.py --raw $fxRaw --events $events/motion-events.json --output $effects
node tools/relink-mdx/build_effect_materials.cjs $deps $effects
blender.exe --background --factory-startup --python-exit-code 1 --python tools/relink-mdx/render_effect_materials.py -- $effects
python tools/relink-mdx/build_catalogs.py --sound $sound --effects $effects
```

EST 구조의 참고 자료는 [PlatinumGames EST template](https://github.com/Nenkai/010GameTemplates/blob/main/PlatinumGames/Plat_Eff_Est.bt)입니다. 현재 설치본 EFF0의 함수별 블록, 색 리소스 TSC 및 TEX 인덱스를 읽습니다. EPB의 TRIL/U16/ST0 half-float 평면 위치·UV·삼각형을 보존합니다. Pillow가 생략한 DDS BC1/2/3 sRGB 별칭은 동일한 압축 블록의 포맷 ID만 메모리에서 바꿔 디코딩하며 원본은 수정하지 않습니다.

**출력은 원본 입자 효과 전체가 아닌 색·윤곽 소재입니다.** TSC kind 0은 ETI 목록의 전체 프레임을 노출하고 나머지는 legacy TEX 인덱스로 선택합니다. 이 해석과 원본 EST 합성 관계는 미검증입니다. 이동·방출·수명 곡선·마스크·노멀·왜곡·커스텀 esp·원본 색 변화는 변환하지 않습니다. 게임별 MOVE 블록의 레이아웃 차이를 다른 게임의 값으로 대체하지 않습니다. 원본 EST와 참조 `.texture/.epb/.eti/.bxm`은 함께 보존합니다.

161개 이미지를 긴 변 240픽셀로 줄이고 8픽셀 테두리 복제 여백을 넣어 공유 JPEG 품질 95 BLP1 11장으로 묶습니다. 전체 밉을 포함하며 최대 페이지는 1024입니다. MDX 평면은 원본 종횡비를 유지하고 긴 변 240 워크래프트 단위, 중심 좌표 0,0,0, 빌보드, AddAlpha입니다. Stand는 재구성한 50ms/프레임·최소 400ms 구간의 1회 재생이며, Death는 투명입니다. 시작·끝에 별도 페이드를 넣습니다. **원본 게임의 크기·시간·방향을 재현한 값은 아닙니다.**

현재 결과는 원본 EST 71개, 소재 MDX 32개 / 368,899바이트, 공유 BLP 11장 / 8,418,637바이트입니다. 원본 윤곽 EPB가 없는 56개 프레임은 임의 사각형을 넣지 않고 제외합니다. 누락 프레임이 있는 소재는 020(15개), 021(24개), 155(6개), 550(9개)입니다. `Info/material-source-est.csv`는 색 리소스가 같은 EST 엔트리와 소재 후보의 대응이며 원본 입자 전체의 일대일 변환표가 아닙니다. `Info/motion-events.json`은 611개 이펙트 호출의 원본 속성을 포함하며 공용 효과 호출도 있으므로 모든 호출을 PL1100 EST에 연결했다고 주장하지 않습니다.

리소스 192와 249는 각각 유일한 프레임의 EPB가 없어 MDX를 생성하지 않았습니다. 이 두 프레임을 포함하여 제외 프레임 합계가 56개입니다. 다중 파일 DDS 변환에서는 `-o`를 생략해 원본 옆에 각각 생성합니다.

BLP 사용자 지정 가져오기 경로는 `Siegfried_FX\Atlas_00.blp`부터 `Atlas_10.blp`까지 유지합니다. 사용하는 소재에 필요한 아틀라스만 가져올 수 있고, 전체 패키지는 11장을 포함합니다. MP3/WAV는 필요한 파일만 선택합니다.

## 확인한 범위

- 정적 검사. Python AST, Node 및 생성된 HTML 스크립트 구문, 경로·카탈로그 파일 참조를 검사합니다.
- 변환·파일 검사. 5,198개 사운드 전체 디코딩, 원본 샘플 수 및 최종 포맷·길이 확인. MDX 32개 재저장 바이트 일치, 구조 오류·심각한 문제·경고 0개. 모든 Stand 밀리초에서 프레임 한 개만 선택됨을 확인. EPB 삼각형 일치 및 위치·UV 역변환 오차 확인. 11개 BLP 전체 밉을 독립 디코딩합니다.
- 시각 검사. 독립 재읽은 MDX 메시와 디코딩 BLP로 모델별 6시점, 총 192개 PNG와 소재 비교판을 렌더합니다. Blender의 투명+방출 셰이더는 AddAlpha 근사이며 원본 게임 또는 워크래프트 실제 렌더가 아닙니다. GIF는 이 6개 시점을 반복하며 모든 원본 프레임을 보여주지 않습니다. KMTA 페이드와 실제 빌보드 회전은 렌더 검증에 포함하지 않습니다.
- 전달 검사. ZIP CRC·파일 SHA-256, 원본 뱅크·게임 인덱스 및 이전 33 폴더 파일 보존을 확인합니다.
- 실제 런타임. 워크래프트·월드 에디터 가져오기·사운드 재생·이펙트 합성·성능·멀티플레이는 미검증입니다. 저장소 CI는 자산 런타임 검사가 아닙니다.
