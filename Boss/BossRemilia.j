/*
    레밀리아 스칼렛 보스 (동방 홍마향) - 1페이즈 + 10% 전환 + 2페이즈 (기획서 「레밀리아 보스전 기획」 표의 수치)

    - 이동 능력과 일반 AI 없이 0.02초 전투 틱 하나가 모든 행동을 직접 제어한다 (아쳐와 같은 구조).
      보스는 'Aloc', Amov 제거. 위치는 SetUnitPosition 으로만 바꾼다.
    - 1페이즈: 체력 100% → 10%. 체력 하한 10% (그 아래로 내려가지 않음).
    - 햇빛 띠: 시작 2줄, 체력 85% 부터 3줄. 20초마다 한 줄이 다른 자리로 옮겨 간다 (사라짐 2초 / 나타남 2초).
      레밀리아는 스스로 움직여서 햇빛 안에 멈추지 않는다. 마왕의 요람으로 햇빛에 들어가면 화상 그로기.
    - 걷기 대신 박쥐 흩어짐: 사라졌다가 대상 근처 햇빛 밖에서 다시 모인다.
    - 기본 패턴: 뱀파이어 클로, 하트 브레이크, 스칼렛 슛, 날갯짓 / 큰 패턴: 마왕의 요람, 퀸 오브 미드나이트(카운터), 다윗의 별.
    - 체력 70%·40% 기믹은 아직 없음 (GimmickHook 자리만).
    - 10% 전환「붉은 안개 이변」: 무적 약 8초. 햇빛이 꺼지고 붉은 필터, 완전 회복 뒤 2페이즈 (첫 패턴 스피어 더 궁니르).
    - 2페이즈: 붉은 안개 농도 게이지(100 시작, 체력바 아래). 카운터·대형·기믹 성공으로 걷히고, 시간·피격으로 다시 찬다.
      농도 70 이하 햇빛 1줄, 40 이하 2줄, 10 이하 3줄. 짤패턴(하트브레이크 2연, 배드 레이디 스크램블, 홍색의 명계, 박쥐 떼,
      박쥐 산개, 날개 치기), 대형(스피어 더 궁니르, 미저러블 페이트 87.5%~, 드라큘라 크레이들 햇빛 있을 때),
      기믹 75% 운명 예지 · 50% 퀸 오브 미드나잇(어둠) · 25% 홍색의 환상향(전멸기). 기믹이 끝날 때까지 체력은 그 줄에서 멈춘다.
      10% 아래는 마지막 발악 (대형 패턴 간격 짧아짐).

    ※ 이펙트는 임시(기본 게임 모델·맵에 이미 있는 ArcanaFX). 실제 선택은 이펙트 뷰어로 나중에.
    ※ 음성 없음 (사운드 미리 틀기 구조만 둠).
*/
library BossRemilia requires Tick,DataUnit,UIBossHP,DamageEffect2,UIBossEnd,DataMap,Boss1,BossAggro,ItemPickUp,UIMainQuest,UIPick,AnimationTime,CameraShaker,Euclid,Splash,PSound,BGMSound,Missile,EffectDummy,FXKnockback,CustomStun
    globals
        // ===== 오브젝트 =====
        // 레밀리아 유닛 rawcode 는 Data_Unit.j 의 REMILIA_UNIT_ID (모델 war3mapImported\Hero-Model_Remilia.mdx)
        constant integer REMILIA_DATA_INDEX = 28
        // 전장 테마 번호 (GetMap). 1=카운터 훈련, 2=그 외 보스, 3=아쳐
        private constant integer ARENA_THEMA = 4
        private constant integer ENTRANCE_DUMMY = 'e01I'
        // 원형 예고 장판 더미 (AOE.j 와 같은 데칼, 반경 100 기준. stand 1초 동안 채워진다)
        private constant integer DECAL_ID = 'h00H'
        // 직선 범위 예고 (아쳐와 같은 [I0]Attack2: 원점에서 +X 로 길이 384, 폭 78)
        private constant string TELE_LINE = "[I0]Attack2.mdx"
        private constant real TELE_LINE_W = 78
        private constant real TELE_LEN = 384

        // ===== 이펙트 (임시) =====
        // 맵에 이미 있는 아쳐용 ArcanaFX 를 임시로 쓴다
        // 붉은 섬광 / 흰 섬광 / 파편 / 퍼지는 고리 / 모이는 빛 / 붉은 바닥 균열 / 푸른 고리 섬광(카운터 준비)
        private constant string FX_FLASH_RED = "ArcanaFX\\F5202.mdx"
        private constant string FX_FLASH_WHITE = "ArcanaFX\\F5291.mdx"
        private constant string FX_SPARKS = "ArcanaFX\\F9906.mdx"
        private constant string FX_BURST = "ArcanaFX\\F3099.mdx"
        private constant string FX_GATHER = "ArcanaFX\\D0008-V001.mdx"
        private constant string FX_CRACK = "ArcanaFX\\F0681.mdx"
        private constant string FX_COUNTER_READY = "ArcanaFX\\F6321.mdx"
        // 붉은 초승달 베기 궤적 (Death 0.43초, 반경 416, 바닥에 눕고 +X 가 바깥쪽)
        private constant string FX_CLAW = "ArcanaFX\\F6773.mdx"
        private constant real FX_CLAW_R = 416
        // 하트 브레이크 창: 붉은 나선 화살
        private constant string FX_SPEAR = "ArcanaFX\\F4435.mdx"
        // 스칼렛 슛 큰 탄
        private constant string FX_ORB = "Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl"
        private constant real FX_ORB_SIZE = 2.2
        // 박쥐 떼 (기본 게임 캐리언 스웜)
        private constant string FX_BATS = "Abilities\\Spells\\Undead\\CarrionSwarm\\CarrionSwarmMissile.mdl"
        private constant string FX_BATS_HIT = "Abilities\\Spells\\Undead\\CarrionSwarm\\CarrionSwarmDamage.mdl"
        // 햇빛 줄기 (나타날 때) / 화상 (보스에 붙임, 그로기 동안 유지)
        private constant string FX_SUN_SHAFT = "Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl"
        private constant string FX_BURN = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedTarget.mdl"
        private constant string FX_BURN_HIT = "Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl"
        // 마왕의 요람 회전 돌진 잔상
        private constant string FX_SPIN = "Abilities\\Spells\\NightElf\\FanOfKnives\\FanOfKnivesCaster.mdl"
        // 퀸 오브 미드나이트 눈빛 (머리에 붙임)
        private constant string FX_EYES = "Abilities\\Spells\\Undead\\UnholyFrenzy\\UnholyFrenzyTarget.mdl"
        // 지면 충격 (기본)
        private constant string FX_STOMP = "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl"
        // 다윗의 별 레이저 번개 (붉은 손가락 죽음)
        private constant string LZ_LASER = "AFOD"

        // ===== 햇빛 띠 =====
        // 칸 4개: 켜진 띠 최대 3줄 + 옮겨 가며 사라지는 띠 1줄
        private constant integer SB_MAX = 4
        private constant integer SB_DEC = 8
        // 띠 하나: 길이 900 x 폭 250
        private constant real SB_HALF_LEN = 450
        private constant real SB_HALF_W = 125
        private constant real SB_FADE = 2.0
        private constant real SB_MOVE_EVERY = 20.0
        private constant real SB_THIRD_HP = 0.85
        // 레밀리아 몸 반경 (햇빛에 닿았는지 볼 때 더하는 여유)
        private constant real BOSS_R = 40

        // ===== 박쥐 흩어짐 =====
        private constant real BAT_HIDE = 0.4
        private constant real BAT_TRAVEL = 0.8
        private constant real BAT_TELL = 0.7
        private constant real BAT_RADIUS = 200
        private constant real BAT_NEAR = 300
        private constant real BAT_FAR = 450
        private constant real BAT_COOL = 4.0
        // 이 거리보다 멀면 박쥐로 다가간다
        private constant real BAT_GAP = 650

        // ===== 기본 패턴 =====
        private constant real CLAW_R = 350
        private constant real CLAW_HALF = 70
        private constant real CLAW_TELL = 0.9
        private constant real CLAW_TELL2 = 0.6
        private constant real HEART_W = 120
        private constant real HEART_TELL = 0.9
        private constant real HEART_LEN = 1400
        private constant real HEART_SPEED = 3000
        private constant integer SHOOT_N = 5
        private constant real SHOOT_GAP = 15
        private constant real SHOOT_SPEED = 650
        private constant real SHOOT_RANGE = 1300
        private constant real SHOOT_R = 90
        private constant real FLAP_R = 300
        private constant real FLAP_BEHIND = 2.0
        private constant real FLAP_BEHIND_ARC = 120
        private constant real FLAP_BEHIND_DIST = 450
        private constant real FLAP_KNOCK = 300
        private constant real FLAP_TELL = 0.6

        // ===== 큰 패턴 =====
        // 마왕의 요람: 조준 1.2초 (마지막 0.4초 고정), 돌진 1100, 폭 220
        private constant real CRADLE_AIM = 1.2
        private constant real CRADLE_LOCK = 0.4
        private constant real CRADLE_LEN = 1100
        private constant real CRADLE_W = 220
        private constant real CRADLE_SPEED = 2400
        private constant real CRADLE_KNOCK = 250
        private constant real CRADLE_STAY = 2.5
        private constant real BURN_GROGGY = 4.5
        // 퀸 오브 미드나이트: 300 물러남 → 카운터 창 2.0초 → 할퀴며 돌진
        private constant real QUEEN_BACK = 300
        private constant real QUEEN_WINDOW = 2.0
        private constant real QUEEN_LUNGE = 450
        private constant real QUEEN_REACH = 200
        private constant real QUEEN_W = 300
        private constant real QUEEN_GROGGY = 4.5
        private constant real QUEEN_STUN = 1.0
        // 다윗의 별: 대상 둘레 삼각형 (외접원 반지름), 레이저 길이·폭, 예고, 두 번째 삼각형 시작, 가운데 폭발
        private constant real STAR_R = 380
        private constant real STAR_LEN = 1600
        private constant real STAR_W = 110
        private constant real STAR_TELL = 1.5
        private constant real STAR_SECOND = 1.0
        private constant real STAR_CORE_R = 200
        private constant real STAR_CORE_TELL = 1.0

        // 패턴 뒤 휴식 (기본 1.0~1.5초, 큰 패턴 2.5~3초)
        private constant real REST_FILL_MIN = 1.0
        private constant real REST_FILL_MAX = 1.5
        private constant real REST_BIG_MIN = 2.5
        private constant real REST_BIG_MAX = 3.0
        private constant real IDLE_TURN = 360
        private constant real COUNTER_ARC = 60

        // ===== 피해 (테스트용 초안, 아쳐와 같은 150~350 범위) =====
        private constant real PARTY_HP_BONUS = 0.70
        private constant real TICK = 0.02
        private constant real PHASE1_FLOOR = 0.10
        private constant real DMG_CLAW = 160
        private constant real DMG_HEART = 220
        private constant real DMG_SHOOT = 150
        private constant real DMG_FLAP = 150
        private constant real DMG_BAT = 100
        private constant real DMG_CRADLE = 300
        private constant real DMG_QUEEN = 350
        private constant real DMG_LASER = 250
        private constant real DMG_STAR_CORE = 300

        // 패턴 번호
        private constant integer PAT_CLAW = 1
        private constant integer PAT_HEART = 2
        private constant integer PAT_SHOOT = 3
        private constant integer PAT_FLAP = 4
        private constant integer PAT_CRADLE = 5
        private constant integer PAT_QUEEN = 6
        private constant integer PAT_STAR = 7
        private constant integer PAT_BAT = 8
        // 2페이즈 짤패턴
        private constant integer PAT_HEART2 = 9
        private constant integer PAT_SCRAMBLE = 10
        private constant integer PAT_MEIKAI = 11
        private constant integer PAT_SWARM = 12
        // 2페이즈 대형 패턴
        private constant integer PAT_GUNGNIR = 13
        private constant integer PAT_MISERY = 14
        private constant integer PAT_DRACULA = 15
        // 2페이즈 기믹 (선택되지 않고 체력 줄에서 강제)
        private constant integer PAT_FATE = 16
        private constant integer PAT_NIGHT = 17
        private constant integer PAT_GENSO = 18
        private constant integer PAT_MAX = 18

        // ===== 10% 전환·2페이즈 (기획서 표의 수치) =====
        private constant real TRANS_TIME = 8.0
        // 붉은 안개: 성공하면 걷힘 / 시간·피격으로 다시 참
        private constant real FOG_COUNTER = 15
        private constant real FOG_BIG = 15
        private constant real FOG_DRACULA = 10
        private constant real FOG_GIMMICK = 25
        private constant real FOG_FATE_HIT = 5
        private constant real FOG_NIGHT_FAIL = 20
        // 기획서에 수치가 없어 정함: 4초마다 +1, 영웅이 맞을 때마다 +2
        private constant real FOG_TIME_EVERY = 4.0
        private constant real FOG_HIT = 2
        private constant real FOG_AFTER_GENSO = 50
        // 2페이즈 짤패턴
        private constant real HEART2_GAP = 0.6
        private constant real SCRAMBLE_LEN = 700
        private constant real SCRAMBLE_W = 220
        private constant real SCRAMBLE_TELL = 0.9
        private constant real SCRAMBLE_STAY = 1.5
        private constant real MEIKAI_R = 150
        private constant integer MEIKAI_N = 6
        private constant real MEIKAI_TELL = 1.0
        private constant real SWARM_W = 200
        private constant real SWARM_LEN = 1100
        private constant real SWARM_TELL = 1.0
        // 스피어 더 궁니르: 2.0초 모음, 폭 260, 던지기 0.8초 전 고정, 마지막 1.0초 카운터, 끝에 꽂혀 1초 뒤 반경 300 폭발
        private constant real GUNGNIR_CHARGE = 2.0
        private constant real GUNGNIR_W = 260
        private constant real GUNGNIR_LOCK = 0.8
        private constant real GUNGNIR_COUNTER = 1.0
        private constant real GUNGNIR_BOOM_R = 300
        private constant real GUNGNIR_GROGGY = 4.5
        // 미저러블 페이트: 영웅에게서 300 떨어진 말뚝, 사슬 400, 6초, 말뚝은 3타, 성공 기절 3초, 실패 반경 250 폭발
        private constant real MISERY_DIST = 300
        private constant real MISERY_CHAIN = 400
        private constant real MISERY_TIME = 6.0
        private constant integer MISERY_HITS = 3
        private constant real MISERY_STUN = 3.0
        private constant real MISERY_BOOM_R = 250
        private constant real MISERY_UNLOCK = 0.875
        // 드라큘라 크레이들: 돌진 끝에서 뛰어올라 1.0초 뒤 반경 300 내리찍기
        private constant real DRACULA_SLAM_TELL = 1.0
        private constant real DRACULA_SLAM_R = 300
        // 기믹 그로기
        private constant real GIMMICK_GROGGY = 6.0
        // 75% 운명 예지: 예고 3초, 1.2초 간격, 0.6초 전 번쩍, 5개 → 4개, 맞으면 최대 체력 25% + 안개 +5, 2번 미만이면 성공
        private constant real FATE_SHOW = 3.0
        private constant real FATE_GAP = 1.2
        private constant real FATE_FLASH = 0.6
        private constant real FATE_DMG = 0.25
        private constant real FATE_CROSS_W = 240
        private constant real FATE_LINE_W = 220
        private constant real FATE_CIRCLE_R = 200
        // 50% 퀸 오브 미드나잇(어둠): 5번 돌진, 예고 1.0초(마지막 0.6초 카운터), 돌진 뒤 1.5초 보임, 돌진 사이 3초 이상,
        // 카운터+작열 3번이면 성공. 실패하면 안개 +20 뒤 앞쪽 반원 반경 800(예고 2초) 최대 체력 70%
        private constant integer NIGHT_DASHES = 5
        private constant real NIGHT_TELL = 1.0
        private constant real NIGHT_COUNTER = 0.6
        private constant real NIGHT_SHOW = 1.5
        private constant real NIGHT_CYCLE = 3.2
        private constant integer NIGHT_NEED = 3
        private constant real NIGHT_FINAL_R = 800
        private constant real NIGHT_FINAL_TELL = 2.0
        private constant real NIGHT_FINAL_DMG = 0.70
        // 25% 홍색의 환상향: 무적 10초 시전, 3단계로 가장자리부터 붉은 빛, 마지막엔 햇빛 안만 안전
        private constant real GENSO_CAST = 10.0
        private constant real GENSO_RING_TELL = 1.5
        private constant real GENSO_TICK_DMG = 0.10
        private constant real GENSO_NARROW_W = 60
        private constant real LAST_STRUGGLE = 0.10
        private constant real DMG_HEART2 = 200
        private constant real DMG_SCRAMBLE = 250
        private constant real DMG_MEIKAI = 180
        private constant real DMG_SWARM = 200
        private constant real DMG_GUNGNIR = 350
        private constant real DMG_GUNGNIR_BOOM = 300
        private constant real DMG_MISERY_BOOM = 300
        private constant real DMG_DRACULA_SLAM = 300
        private constant real DMG_NIGHT_DASH = 250
        // 이펙트 (임시)
        private constant string FX_FOG = "Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayTarget.mdl"
        private constant string FX_STAKE = "ArcanaFX\\F4435.mdx"
        private constant string LZ_CHAIN = "DRAL"
        // 안개 게이지 화면 (체력바 바로 아래)
        private integer FogBack = 0
        private integer FogFill = 0
        private integer FogText = 0
        private constant real FOG_UI_X = 330.0
        private constant real FOG_UI_Y = 626.0
        private constant real FOG_UI_W = 364.0
        private constant real FOG_UI_H = 10.0
        private real array PatCool
        private integer array PatWeight

        // 투사체 슬롯 (스칼렛 슛 2파 10발 + 창 + 박쥐)
        private constant integer MAXP = 16

        // 상태
        constant integer REMILIA_READY = 0
        constant integer REMILIA_PHASE1 = 1
        // 체력 10%: 1페이즈 끝 → 전환 → 2페이즈
        constant integer REMILIA_PHASE_END = 2
        constant integer REMILIA_TRANSITION = 3
        constant integer REMILIA_PHASE2 = 4
        constant integer REMILIA_ENDED = 5

        // 레밀리아 모델 애니메이션 인덱스 (Hero-Model_Remilia.mdx SEQS 순서, model-info.md 에서 동작 확인)
        private constant integer AN_STAND = 0
        private constant integer AN_READY = 1
        // 할퀴기 (한 팔, 휘두름 약 0.45초) / 몸을 돌리며 손등 베기
        private constant integer AN_ATTACK = 2
        private constant integer AN_SPELL1 = 3
        // 창 소환 / 창 들고 유지(반복) / 창 던지기 (놓는 순간 약 0.15초)
        private constant integer AN_SPEAR_SUMMON = 4
        private constant integer AN_SPEAR_HOLD = 5
        private constant integer AN_SPEAR_THROW = 6
        private constant integer AN_DEATH = 11
        // 날개에 몸을 말고 박쥐로 흩어짐
        private constant integer AN_BAT_OUT = 12
        // 엎드려 나는 자세: 시작 / 반복 / 착지 / 공중에서 구르며 균형 잡기
        private constant integer AN_FLY_START = 13
        private constant integer AN_FLY_LOOP = 14
        private constant integer AN_FLY_TUMBLE = 15
        private constant integer AN_FLY_LAND = 16
        // 팔·날개를 뒤로 젖힘 / 그 자세 유지(반복)
        private constant integer AN_WINDUP = 17
        private constant integer AN_WINDUP_HOLD = 29
        // 두 팔을 들어 올림 (시전·발사)
        private constant integer AN_CAST = 19
        // 날개로 몸을 감싼 채 나타나 일어섬 (박쥐에서 다시 모임)
        private constant integer AN_BAT_IN = 22
        // 날개를 활짝 펼침 (웅크렸다가)
        private constant integer AN_WING_BURST = 23
        // 빠르게 앞으로 찌르기
        private constant integer AN_LUNGE = 25
        // 뒤로 공중제비
        private constant integer AN_BACKFLIP = 26
        // 팔·날개를 크게 펼치는 큰 시전
        private constant integer AN_BIG_CAST = 28
        // 창을 들고 높이 뛰어오름 / 공중에 떠 있음(반복) / 내리찍기
        private constant integer AN_LEAP = 7
        private constant integer AN_HOVER = 8
        private constant integer AN_PLUNGE = 9
        // 그로기: Death 를 이 시각에서 멈춘다. Death 는 끝에 몸이 사라지므로(0.75초부터 마법진, 1.25초에 몸 사라짐)
        // 날개·고개가 처진 0.70초에서 멈춘다
        private constant real DOWN_FREEZE_AT = 0.70
        private real array AnimDur
        private boolean array AnimLoop

        // ===== 음성 (홍마성전설 1·2, 같은 성우). 44.1kHz 모노 mp3 로 다시 만듦 (D:\Work\ARCANA\Claude outputs\remilia-sound-check\final) =====
        // 칸마다 여러 개면 무작위로 하나. 대사는 한 번에 하나만 (아쳐와 같은 잠금)
        private constant string SND_DIR = "war3mapImported\\RemiliaSnd\\"
        private constant integer VO_START = 0
        private constant integer VO_BAT = 1
        private constant integer VO_CLAW = 2
        private constant integer VO_HEART = 3
        private constant integer VO_SHOOT = 4
        private constant integer VO_CRADLE = 5
        private constant integer VO_QUEEN = 6
        private constant integer VO_STAR = 7
        private constant integer VO_GROGGY = 8
        private constant integer VO_COUNTERHIT = 9
        // 아래는 2단계 이후에 연결 (70%·40% 기믹, 10% 전환, 2페이즈 주문)
        private constant integer VO_VLAD = 10
        private constant integer VO_FUYAJOU = 11
        private constant integer VO_TRANSITION = 12
        private constant integer VO_PHASE2 = 13
        private constant integer VO_GUNGNIR = 14
        private constant integer VO_DRACULA = 15
        private constant integer VO_FATE = 16
        private constant integer VO_NIGHTMARE = 17
        private constant integer VO_GENSOKYO = 18
        private constant integer VO_SCARLETDEVIL = 19
        private constant integer VO_WIPE = 20
        private constant integer VO_DEFEAT = 21
        private constant integer VO_SLOTS = 22
        // 미저러블 페이트: 맞는 대사 없음
        private string array VoFile
        private real array VoDur
        private integer array VoStart
        private integer array VoN
        private integer VoCount = 0
        // 공격 기합 사이 최소 간격 (매번 소리치지 않게)
        private constant real GRUNT_GAP = 2.0

        integer array RemiliaFightAt
        private integer CheckFight = 0
        // 맵 시작 직후 이펙트·사운드 미리 불러오기 (아쳐와 같은 방식)
        private string array PreModel
        private integer PreCount = 0
        private integer PreIdx = 0
        private timer PreTimer = CreateTimer()
        private unit PreUnitA = null
        private unit PreUnitB = null
        private string array PreSnd
        private integer PreSndCount = 0
        private integer PreSndIdx = 0
        private boolean FinOk = false
    endglobals

    // ======================================================================
    // 전투 문맥
    // ======================================================================
    struct RemiliaFight
        unit boss = null
        unit entrance = null
        party ul
        integer rect = 0
        integer state = REMILIA_READY
        real now = 0
        tick t
        real animEnd = 0
        // 반복하지 않는 동작이 끝나면 이어서 틀 동작 (-1 이면 대기 동작)
        integer animNext = -1
        real downFreeze = 0

        unit array mem[6]
        real array behindT[6]
        integer memN = 0

        // 패턴
        integer pat = 0
        integer step = 0
        real patStart = 0
        real nextSelect = 0
        integer lastFill = 0
        integer lastBig = 0
        integer fillN = 0
        integer bigEvery = 2
        real array readyAt[20]
        real batAt = 0
        boolean flapWant = false
        real holdUntil = 0
        texttag patTag = null
        real patTagEnd = 0

        // 체력 구간
        boolean third = false
        boolean g70 = false
        boolean g40 = false
        real endAt = 0
        // 박쥐로 흩어진 동안 (피해 잠금·투명)
        boolean hidden = false
        // 음성: 재생 중인 대사가 끝나는 시각, 다음 기합 가능 시각
        real voiceUntil = 0
        real gruntAt = 0

        // 전환·2페이즈
        real transStart = 0
        integer transStep = 0
        // 무적 (전환·홍색의 환상향)
        boolean invuln = false
        // 붉은 안개 농도 0~100
        real fog = 100
        real fogAt = 0
        // 2페이즈 기믹 진행 (0 아직, 1 진행 중, 2 끝)
        integer g75 = 0
        integer g50 = 0
        integer g25 = 0
        boolean lastStruggle = false
        // 화면 필터 (0 없음, 1 붉은 달빛, 2 어둠, 3 붉은 빛 차오름)
        integer filter = 0
        // 홍색의 명계 원 (최대 36개: 위치·터지는 시각·파 번호)
        real array mkX[48]
        real array mkY[48]
        real array mkAt[48]
        integer mkN = 0
        party mkHit
        // 미저러블 페이트 말뚝 (참가자 번호별)
        unit array stake[6]
        effect array stakeFx[6]
        lightning array chain[6]
        real array stakeHP[6]
        integer array stakeHits[6]
        // 운명 예지 (공격 종류·위치·방향·번호 글자·예고)
        integer array fK[8]
        real array fX[8]
        real array fY[8]
        real array fA[8]
        texttag array fTag[8]
        integer fN = 0
        integer fFlash = 0
        real array fcX[6]
        real array fcY[6]
        integer fcN = 0
        integer fRound = 0
        real fRoundAt = 0
        integer fDone = 0
        integer array memHits[6]
        // 퀸 오브 미드나잇(어둠): 돌진 번호, 성공 수, 이번 돌진 시작 시각
        integer nDash = 0
        integer nGood = 0
        real nAt = 0
        // 홍색의 환상향: 붉은 빛이 덮은 반경, 다음 피해·탄 시각
        real gCover = 0
        real gTickAt = 0
        real gShootAt = 0
        integer gStage = 0
        // 선 예고(따라오는 것) 폭
        real cTeleW = 220
        boolean slam = false

        // 대상·좌표
        unit target = null
        real ax = 0
        real ay = 0
        real ang = 0
        real face = 270
        real tx = 0
        real ty = 0
        real dashLeft = 0
        real dashSpeed = 0
        real dashLen = 0
        boolean burn = false
        real nextFx = 0
        effect cTele = null
        real cTeleAng = -1
        real cGoldAt = 0
        effect burnFx = null
        effect eyeFx = null
        unit array cue[3]
        party hit
        group decals

        // 햇빛 띠 (상태 0 없음, 1 나타나는 중, 2 켜짐, 3 사라지는 중)
        real array sbX[4]
        real array sbY[4]
        real array sbA[4]
        integer array sbState[4]
        real array sbT[4]
        // 띠의 반폭 (보통 125, 홍색의 환상향의 좁은 빛줄은 60)
        real array sbW[4]
        unit array sbU[32]
        real sbMoveAt = 0
        integer sbNext = 0

        // 다윗의 별 레이저 (시작점·방향)
        real array lx[6]
        real array ly[6]
        real array la[6]

        // 투사체: 1 스칼렛 탄, 2 창, 3 박쥐(피해 없음)
        integer array pk[16]
        effect array pe[16]
        real array px[16]
        real array py[16]
        real array pdir[16]
        real array pspd[16]
        real array ptrav[16]
        real array pmax[16]
        real array prad[16]
        real array pdmg[16]
        boolean array pstun[16]
        party array phit[16]

        effect array tele[24]
        real array teleEnd[24]
        effect array fxe[32]
        real array fxEnd[32]
        lightning array lz[6]
        real array lzEnd[6]

        method arenaCX takes nothing returns real
            return GetRectCenterX(MapRectReturn(this.rect))
        endmethod
        method arenaCY takes nothing returns real
            return GetRectCenterY(MapRectReturn(this.rect))
        endmethod
    endstruct

    // ======================================================================
    // 공용 도우미
    // ======================================================================
    private function AngDiff takes real a, real b returns real
        local real d = ModuloReal(a - b + 540.0, 360.0) - 180.0
        if d < 0 then
            return -d
        endif
        return d
    endfunction

    private function SegDist takes real x, real y, real x1, real y1, real x2, real y2 returns real
        local real dx = x2 - x1
        local real dy = y2 - y1
        local real l2 = dx * dx + dy * dy
        local real k = 0
        if l2 > 0.01 then
            set k = ((x - x1) * dx + (y - y1) * dy) / l2
            if k < 0 then
                set k = 0
            elseif k > 1 then
                set k = 1
            endif
        endif
        return SquareRoot((x - x1 - k * dx) * (x - x1 - k * dx) + (y - y1 - k * dy) * (y - y1 - k * dy))
    endfunction

    private function MemAlive takes unit u returns boolean
        return u != null and not IsUnitDeadVJ(u)
    endfunction

    private function AliveCount takes RemiliaFight f returns integer
        local integer i = 0
        local integer n = 0
        loop
            exitwhen i >= f.memN
            if MemAlive(f.mem[i]) then
                set n = n + 1
            endif
            set i = i + 1
        endloop
        return n
    endfunction

    private function RestFill takes nothing returns real
        return GetRandomReal(REST_FILL_MIN, REST_FILL_MAX)
    endfunction

    private function RestBig takes nothing returns real
        return GetRandomReal(REST_BIG_MIN, REST_BIG_MAX)
    endfunction

    private function Anim takes RemiliaFight f, integer idx, real speed returns nothing
        set f.downFreeze = 0
        set f.animNext = -1
        call AnimationStart3(f.boss, idx, speed)
        if AnimLoop[idx] then
            set f.animEnd = 0
        else
            set f.animEnd = f.now + AnimDur[idx] / speed
        endif
    endfunction

    // 한 번 동작 뒤 다른 동작(보통 그 자세를 유지하는 반복 동작)으로 잇는다
    private function AnimThen takes RemiliaFight f, integer idx, real speed, integer next returns nothing
        call Anim(f, idx, speed)
        set f.animNext = next
    endfunction

    // 그로기 자세: Death 를 틀고 날개·고개가 처진 DOWN_FREEZE_AT 에서 멈춘다 (다음 Anim 이 배속을 되돌린다)
    private function AnimDown takes RemiliaFight f returns nothing
        local effect e
        call Anim(f, AN_DEATH, 1.0)
        set e = AddSpecialEffect(FX_FLASH_WHITE, GetUnitX(f.boss), GetUnitY(f.boss))
        call EXSetEffectSize(e, 4.0)
        call DestroyEffect(e)
        set e = AddSpecialEffect(FX_SPARKS, GetUnitX(f.boss), GetUnitY(f.boss))
        call EXSetEffectSize(e, 1.2)
        call DestroyEffect(e)
        set e = null
        set f.animEnd = 0
        set f.downFreeze = f.now + 0.01 + DOWN_FREEZE_AT
    endfunction

    private function AnimIdle takes RemiliaFight f returns nothing
        call Anim(f, AN_READY, 1.0)
    endfunction

    private function ApplyFacing takes RemiliaFight f returns nothing
        call SetUnitFacing(f.boss, f.face)
        call EXSetUnitFacing(f.boss, f.face)
        call SetUnitPosition(f.boss, GetUnitX(f.boss), GetUnitY(f.boss))
    endfunction

    // 바라보는 방향 고정 (헤드·백·카운터 판정 기준). 0.5도 이상 바뀔 때만 적용
    private function Face takes RemiliaFight f, real a returns nothing
        if AngDiff(ModuloReal(a, 360.0), f.face) < 0.5 and AngDiff(GetUnitFacing(f.boss), f.face) < 1.0 then
            return
        endif
        set f.face = ModuloReal(a, 360.0)
        call ApplyFacing(f)
    endfunction

    private function TurnToward takes RemiliaFight f, real a, real maxStep returns nothing
        local real d = ModuloReal(a - f.face + 540.0, 360.0) - 180.0
        if d > maxStep then
            set d = maxStep
        elseif d < -maxStep then
            set d = -maxStep
        endif
        call Face(f, f.face + d)
    endfunction

    private function HoldFacing takes RemiliaFight f returns nothing
        if ModuloInteger(R2I(f.now / TICK + 0.5), 5) != 0 then
            return
        endif
        if AngDiff(GetUnitFacing(f.boss), f.face) > 1.0 then
            call SetUnitFacing(f.boss, f.face)
            call EXSetUnitFacing(f.boss, f.face)
        endif
    endfunction

    // ======================================================================
    // 음성: 위치 없는 2D (아쳐와 같음). 다른 대사가 재생 중이면 건너뛴다
    // ======================================================================
    private function PlaySnd takes string path returns nothing
        local sound snd
        if path == null or path == "" then
            return
        endif
        set snd = CreateSound(path, false, false, false, 10, 10, "DefaultEAXON")
        call SetSoundVolume(snd, 127)
        call StartSound(snd)
        call KillSoundWhenDone(snd)
        set snd = null
    endfunction

    // 칸 id 의 대사 중 하나를 무작위로. now 면 재생 중인 대사가 있어도 튼다 (그로기·카운터 당함)
    private function VoiceSlot takes RemiliaFight f, integer id, boolean now returns nothing
        local integer k
        if VoN[id] <= 0 then
            return
        endif
        if not now and f.now < f.voiceUntil then
            return
        endif
        set k = VoStart[id] + GetRandomInt(0, VoN[id] - 1)
        set f.voiceUntil = f.now + VoDur[k] + 0.2
        call PlaySnd(SND_DIR + VoFile[k])
    endfunction

    // 공격 기합: 대사가 없고 마지막 기합 뒤 GRUNT_GAP 이 지났을 때만
    private function Grunt takes RemiliaFight f returns nothing
        if f.now < f.voiceUntil or f.now < f.gruntAt then
            return
        endif
        set f.gruntAt = f.now + GRUNT_GAP
        call VoiceSlot(f, VO_CLAW, false)
    endfunction

    // ======================================================================
    // 이펙트
    // ======================================================================
    private function FxAt takes string model, real x, real y, real size, real yaw returns nothing
        local effect e = AddSpecialEffect(model, x, y)
        call EXSetEffectSize(e, size)
        call EXEffectMatRotateZ(e, yaw)
        call DestroyEffect(e)
        set e = null
    endfunction

    private function FxKeep takes RemiliaFight f, string model, real x, real y, real size, real yaw, real dur returns nothing
        local integer i = 0
        local effect e = AddSpecialEffect(model, x, y)
        call EXSetEffectSize(e, size)
        call EXEffectMatRotateZ(e, yaw)
        loop
            exitwhen i >= 32
            if f.fxe[i] == null then
                set f.fxe[i] = e
                set f.fxEnd[i] = f.now + dur
                set e = null
                return
            endif
            set i = i + 1
        endloop
        call DestroyEffect(e)
        set e = null
    endfunction

    private function FxUpdate takes RemiliaFight f, boolean all returns nothing
        local integer i = 0
        loop
            exitwhen i >= 32
            if f.fxe[i] != null and (all or f.now >= f.fxEnd[i]) then
                call DestroyEffect(f.fxe[i])
                set f.fxe[i] = null
            endif
            set i = i + 1
        endloop
    endfunction

    private function FxWindup takes RemiliaFight f returns nothing
        call DestroyEffect(AddSpecialEffectTarget(FX_GATHER, f.boss, "chest"))
    endfunction

    private function FxHitSmall takes real x, real y, real a returns nothing
        call FxAt(FX_FLASH_RED, x, y, 1.2, a)
        call FxAt(FX_SPARKS, x, y, 0.8, a)
    endfunction

    private function FxHitBig takes RemiliaFight f, real x, real y, real a, real size returns nothing
        call FxAt(FX_FLASH_WHITE, x, y, 5.0 * size, a)
        call FxAt(FX_SPARKS, x, y, 1.2 * size, a)
        call FxAt(FX_STOMP, x, y, size, a)
        call FxKeep(f, FX_CRACK, x, y, 0.9 * size, GetRandomReal(0, 360), 1.5)
        call CameraShaker.setShake(6)
    endfunction

    // 할퀴기 궤적: (x, y) 에서 a 방향, 반경 reach 의 붉은 초승달
    private function FxClaw takes real x, real y, real a, real tilt, real reach returns nothing
        local effect e = AddSpecialEffect(FX_CLAW, x, y)
        call EXSetEffectSize(e, reach / FX_CLAW_R)
        call EXEffectMatRotateZ(e, a + tilt)
        call DestroyEffect(e)
        set e = null
    endfunction

    // 붉은 레이저 (번개) dur 초
    private function LzAdd takes RemiliaFight f, real x1, real y1, real x2, real y2, real dur returns nothing
        local integer i = 0
        loop
            exitwhen i >= 6
            if f.lz[i] == null then
                set f.lz[i] = AddLightningEx(LZ_LASER, true, x1, y1, 60, x2, y2, 60)
                set f.lzEnd[i] = f.now + dur
                return
            endif
            set i = i + 1
        endloop
    endfunction

    private function LzUpdate takes RemiliaFight f, boolean all returns nothing
        local integer i = 0
        loop
            exitwhen i >= 6
            if f.lz[i] != null and (all or f.now >= f.lzEnd[i]) then
                call DestroyLightning(f.lz[i])
                set f.lz[i] = null
            endif
            set i = i + 1
        endloop
    endfunction

    // ======================================================================
    // 전장·대상
    // ======================================================================
    private function ClampX takes RemiliaFight f, real x returns real
        local rect r = MapRectReturn(f.rect)
        local real lo = GetRectMinX(r) + 150
        local real hi = GetRectMaxX(r) - 150
        set r = null
        if x < lo then
            return lo
        elseif x > hi then
            return hi
        endif
        return x
    endfunction

    private function ClampY takes RemiliaFight f, real y returns real
        local rect r = MapRectReturn(f.rect)
        local real lo = GetRectMinY(r) + 150
        local real hi = GetRectMaxY(r) - 150
        set r = null
        if y < lo then
            return lo
        elseif y > hi then
            return hi
        endif
        return y
    endfunction

    // (x, y) 에서 a 방향으로 전장 끝까지의 거리
    private function EdgeDist takes RemiliaFight f, real x, real y, real a returns real
        local rect r = MapRectReturn(f.rect)
        local real c = Cos(a * bj_DEGTORAD)
        local real sn = Sin(a * bj_DEGTORAD)
        local real d = 99999
        if c > 0.001 then
            set d = RMinBJ(d, (GetRectMaxX(r) - x) / c)
        elseif c < -0.001 then
            set d = RMinBJ(d, (GetRectMinX(r) - x) / c)
        endif
        if sn > 0.001 then
            set d = RMinBJ(d, (GetRectMaxY(r) - y) / sn)
        elseif sn < -0.001 then
            set d = RMinBJ(d, (GetRectMinY(r) - y) / sn)
        endif
        set r = null
        return RMaxBJ(300, d)
    endfunction

    private function MsgAll takes RemiliaFight f, string s, real dur returns nothing
        local integer i = 0
        loop
            exitwhen i >= f.memN
            if f.mem[i] != null then
                call DisplayTimedTextToPlayer(GetOwningPlayer(f.mem[i]), 0, 0, dur, s)
            endif
            set i = i + 1
        endloop
    endfunction

    private function PickTarget takes RemiliaFight f returns unit
        local unit u = BossAggroTarget(f.boss)
        local integer i = 0
        if MemAlive(u) and IsUnitInGroup(u, f.ul.super) then
            return u
        endif
        loop
            exitwhen i >= f.memN
            if MemAlive(f.mem[i]) then
                return f.mem[i]
            endif
            set i = i + 1
        endloop
        return null
    endfunction

    private function NearestMem takes RemiliaFight f returns unit
        local integer i = 0
        local unit best = null
        local real bd = 999999
        local real d
        loop
            exitwhen i >= f.memN
            if MemAlive(f.mem[i]) then
                set d = DistancePBP(GetUnitX(f.boss), GetUnitY(f.boss), GetUnitX(f.mem[i]), GetUnitY(f.mem[i]))
                if d < bd then
                    set bd = d
                    set best = f.mem[i]
                endif
            endif
            set i = i + 1
        endloop
        return best
    endfunction

    // ======================================================================
    // 예고 (원형 데칼: types 0 빨강, 2 노랑)
    // ======================================================================
    private function Decal takes RemiliaFight f, real x, real y, real radius, real time, integer types returns nothing
        local unit d = CreateUnit(GetOwningPlayer(f.boss), DECAL_ID, x, y, 270)
        local real s = radius * 0.01
        call SetUnitScalePercent(d, 100 * s, 100 * s, 100)
        if types == 2 then
            call SetUnitVertexColor(d, 255, 215, 40, 255)
        elseif types == 4 then
            // 흐린 붉은색 (운명 예지의 미리 보기)
            call SetUnitVertexColor(d, 255, 40, 40, 100)
        else
            call SetUnitVertexColor(d, 255, 10, 10, 255)
        endif
        call SetUnitTimeScale(d, 1 / time)
        call UnitApplyTimedLife(d, 'BHwe', time)
        call GroupAddUnit(f.decals, d)
        set d = null
    endfunction

    // 패턴 정리(ClearDecals)에 지워지지 않는 원형 예고 (홍색의 명계처럼 패턴과 따로 터지는 것)
    private function DecalFree takes RemiliaFight f, real x, real y, real radius, real time returns nothing
        local unit d = CreateUnit(GetOwningPlayer(f.boss), DECAL_ID, x, y, 270)
        local real s = radius * 0.01
        call SetUnitScalePercent(d, 100 * s, 100 * s, 100)
        call SetUnitVertexColor(d, 255, 10, 10, 255)
        call SetUnitTimeScale(d, 1 / time)
        call UnitApplyTimedLife(d, 'BHwe', time)
        set d = null
    endfunction

    // 직선 위에 원형 데칼을 이어 붙인다 (from ~ to 구간)
    private function DecalSeg takes RemiliaFight f, real x, real y, real a, real from, real to, real width, real time, integer types returns nothing
        local real r = width * 0.5
        local real step = width * 0.8
        local real d = from + r
        if to - from <= width then
            set d = (from + to) * 0.5
            call Decal(f, x + PolarX(d, a), y + PolarY(d, a), r, time, types)
            return
        endif
        loop
            exitwhen d > to - r
            call Decal(f, x + PolarX(d, a), y + PolarY(d, a), r, time, types)
            set d = d + step
        endloop
        // 끝까지 덮도록 마지막 하나
        set d = to - r
        call Decal(f, x + PolarX(d, a), y + PolarY(d, a), r, time, types)
    endfunction

    private function ClearDecalsEnum takes nothing returns nothing
        local unit u = GetEnumUnit()
        if not IsUnitDeadVJ(u) then
            call ShowUnit(u, false)
            call KillUnit(u)
        endif
        set u = null
    endfunction

    // 직선 범위 예고: (x, y) 에서 a 방향으로 길이 len, 폭 width. 모델 축으로 먼저 늘린 뒤 돌린다
    private function TeleLine takes RemiliaFight f, real x, real y, real a, real len, real width, real time returns nothing
        local integer i = 0
        local effect e = AddSpecialEffect(TELE_LINE, x, y)
        call EXEffectMatScale(e, len / TELE_LEN, width / TELE_LINE_W, 1)
        call EXEffectMatRotateZ(e, a)
        loop
            exitwhen i >= 24
            if f.tele[i] == null then
                set f.tele[i] = e
                set f.teleEnd[i] = f.now + time
                set e = null
                return
            endif
            set i = i + 1
        endloop
        call DestroyEffect(e)
        set e = null
    endfunction

    // 부채꼴 예고 (판정 HitFan 과 같은 반경·반각): 직선 예고를 20도 간격으로 편다
    private function TeleFan takes RemiliaFight f, real x, real y, real a, real r, real half, real time returns nothing
        local integer n = R2I((2 * half) / 20.0 + 0.5)
        local integer k = 0
        local real w = 2 * r * Sin(10.0 * bj_DEGTORAD)
        local real s = -(n - 1) * 10.0
        loop
            exitwhen k >= n
            call TeleLine(f, x, y, a + s + 20.0 * k, r, w, time)
            set k = k + 1
        endloop
    endfunction

    private function TeleUpdate takes RemiliaFight f, boolean all returns nothing
        local integer i = 0
        loop
            exitwhen i >= 24
            if f.tele[i] != null and (all or f.now >= f.teleEnd[i]) then
                call DestroyEffect(f.tele[i])
                set f.tele[i] = null
            endif
            set i = i + 1
        endloop
    endfunction

    private function CradleTeleClear takes RemiliaFight f returns nothing
        if f.cTele != null then
            call DestroyEffect(f.cTele)
            set f.cTele = null
        endif
        set f.cTeleAng = -1
    endfunction

    private function ClearDecals takes RemiliaFight f returns nothing
        call ForGroup(f.decals, function ClearDecalsEnum)
        call GroupClear(f.decals)
        call TeleUpdate(f, true)
        call CradleTeleClear(f)
    endfunction

    // ======================================================================
    // 피해 판정 (이 전투 참가자만)
    // ======================================================================
    private function Deal takes RemiliaFight f, unit u, real dmg, boolean stun returns nothing
        call BossDeal(f.boss, u, dmg, stun)
        // 2페이즈: 영웅이 맞을 때마다 안개가 조금 다시 찬다 (게이지 갱신은 틱에서)
        if f.state == REMILIA_PHASE2 and dmg > 0 then
            set f.fog = RMinBJ(100, f.fog + FOG_HIT)
        endif
    endfunction

    // 안개 농도 바꾸기 (0~100). 햇빛 줄 수는 틱에서 맞춘다
    private function FogAdd takes RemiliaFight f, real d returns nothing
        set f.fog = RMaxBJ(0, RMinBJ(100, f.fog + d))
    endfunction

    // 최대 체력의 rate 만큼 피해 (기믹)
    private function DealPct takes RemiliaFight f, unit u, real rate, boolean stun returns nothing
        call Deal(f, u, GetUnitState(u, UNIT_STATE_MAX_LIFE) * rate, stun)
    endfunction

    private function HitCircle takes RemiliaFight f, real x, real y, real r, real dmg, boolean stun, party g returns nothing
        local integer i = 0
        local unit u
        loop
            exitwhen i >= f.memN
            set u = f.mem[i]
            if MemAlive(u) and IsUnitInRangeXY(u, x, y, r) then
                if g == 0 then
                    call Deal(f, u, dmg, stun)
                elseif not IsUnitInGroup(u, g.super) then
                    call GroupAddUnit(g.super, u)
                    call Deal(f, u, dmg, stun)
                endif
            endif
            set i = i + 1
        endloop
        set u = null
    endfunction

    private function HitFan takes RemiliaFight f, real x, real y, real a, real range, real half, real dmg, boolean stun returns nothing
        local integer i = 0
        local unit u
        loop
            exitwhen i >= f.memN
            set u = f.mem[i]
            if MemAlive(u) and IsUnitInRangeXY(u, x, y, range) then
                if AngDiff(AnglePBP(x, y, GetUnitX(u), GetUnitY(u)), a) <= half or IsUnitInRangeXY(u, x, y, 100) then
                    call Deal(f, u, dmg, stun)
                endif
            endif
            set i = i + 1
        endloop
        set u = null
    endfunction

    // 부채꼴, 피해는 최대 체력 비율 (기믹 일격)
    private function HitFanPct takes RemiliaFight f, real x, real y, real a, real range, real half, real rate returns nothing
        local integer i = 0
        local unit u
        loop
            exitwhen i >= f.memN
            set u = f.mem[i]
            if MemAlive(u) and IsUnitInRangeXY(u, x, y, range) then
                if AngDiff(AnglePBP(x, y, GetUnitX(u), GetUnitY(u)), a) <= half or IsUnitInRangeXY(u, x, y, 100) then
                    call DealPct(f, u, rate, true)
                endif
            endif
            set i = i + 1
        endloop
        set u = null
    endfunction

    // 선분 휩쓸기 (빠른 이동). knock > 0 이면 선분 옆으로 밀어낸다
    private function HitSweep takes RemiliaFight f, real x1, real y1, real x2, real y2, real width, real dmg, boolean stun, party g, real knock returns nothing
        local integer i = 0
        local unit u
        local real a
        local real side
        loop
            exitwhen i >= f.memN
            set u = f.mem[i]
            if MemAlive(u) and not IsUnitInGroup(u, g.super) then
                if SegDist(GetUnitX(u), GetUnitY(u), x1, y1, x2, y2) <= width then
                    call GroupAddUnit(g.super, u)
                    call Deal(f, u, dmg, stun)
                    if knock > 0 then
                        set a = AnglePBP(x1, y1, x2, y2)
                        // 선분의 왼쪽이면 왼쪽으로, 오른쪽이면 오른쪽으로
                        set side = (x2 - x1) * (GetUnitY(u) - y1) - (y2 - y1) * (GetUnitX(u) - x1)
                        if side >= 0 then
                            call Knockback(u, a + 90, knock, 0.3)
                        else
                            call Knockback(u, a - 90, knock, 0.3)
                        endif
                    endif
                endif
            endif
            set i = i + 1
        endloop
        set u = null
    endfunction

    // 사각형: (x, y) 에서 a 방향 길이 len, 폭 width. stunT > 0 이면 그 시간만큼 기절 (기본 기절 대신)
    private function HitRect takes RemiliaFight f, real x, real y, real a, real len, real width, real dmg, boolean stun, party g, real stunT returns nothing
        local integer i = 0
        local unit u
        local real c = Cos(a * bj_DEGTORAD)
        local real sn = Sin(a * bj_DEGTORAD)
        local real dx
        local real dy
        local real along
        local real side
        loop
            exitwhen i >= f.memN
            set u = f.mem[i]
            if MemAlive(u) and (g == 0 or not IsUnitInGroup(u, g.super)) then
                set dx = GetUnitX(u) - x
                set dy = GetUnitY(u) - y
                set along = dx * c + dy * sn
                set side = RAbsBJ(dx * sn - dy * c)
                if along >= 0 and along <= len and side <= width * 0.5 then
                    if g != 0 then
                        call GroupAddUnit(g.super, u)
                    endif
                    call Deal(f, u, dmg, stun)
                    if stunT > 0 then
                        call CustomStun.Stun2(u, stunT)
                    endif
                endif
            endif
            set i = i + 1
        endloop
        set u = null
    endfunction

    // ======================================================================
    // 투사체
    // ======================================================================
    private function FreeSlot takes RemiliaFight f returns integer
        local integer i = 0
        loop
            exitwhen i >= MAXP
            if f.pk[i] == 0 then
                return i
            endif
            set i = i + 1
        endloop
        return -1
    endfunction

    private function ProjKill takes RemiliaFight f, integer i returns nothing
        if f.pe[i] != null then
            call DestroyEffect(f.pe[i])
            set f.pe[i] = null
        endif
        if f.phit[i] != 0 then
            call f.phit[i].destroy()
            set f.phit[i] = 0
        endif
        set f.pk[i] = 0
    endfunction

    private function ProjSpawn takes RemiliaFight f, integer kind, string model, real x, real y, real a, real spd, real maxd, real rad, real dmg, real size returns integer
        local integer i = FreeSlot(f)
        if i < 0 then
            return -1
        endif
        set f.pk[i] = kind
        set f.pe[i] = MakeMissile(model, x, y, 90, a, size, null)
        set f.px[i] = x
        set f.py[i] = y
        set f.pdir[i] = a
        set f.pspd[i] = spd
        set f.ptrav[i] = 0
        set f.pmax[i] = maxd
        set f.prad[i] = rad
        set f.pdmg[i] = dmg
        set f.phit[i] = party.create()
        set f.pstun[i] = false
        return i
    endfunction

    private function ProjUpdate takes RemiliaFight f returns nothing
        local integer i = 0
        local real ox
        local real oy
        local real step
        loop
            exitwhen i >= MAXP
            if f.pk[i] != 0 then
                set ox = f.px[i]
                set oy = f.py[i]
                set step = f.pspd[i] * TICK
                if f.ptrav[i] + step > f.pmax[i] then
                    set step = f.pmax[i] - f.ptrav[i]
                endif
                set f.px[i] = ox + PolarX(step, f.pdir[i])
                set f.py[i] = oy + PolarY(step, f.pdir[i])
                set f.ptrav[i] = f.ptrav[i] + step
                call EXSetEffectXY(f.pe[i], f.px[i], f.py[i])
                if f.pdmg[i] > 0 then
                    call HitSweep(f, ox, oy, f.px[i], f.py[i], f.prad[i], f.pdmg[i], f.pstun[i], f.phit[i], 0)
                endif
                if f.ptrav[i] >= f.pmax[i] - 0.01 then
                    if f.pk[i] != 3 then
                        call FxAt(FX_SPARKS, f.px[i], f.py[i], 0.8, f.pdir[i])
                    endif
                    call ProjKill(f, i)
                endif
            endif
            set i = i + 1
        endloop
    endfunction

    // ======================================================================
    // 햇빛 띠
    // ======================================================================
    // (x, y) 가 띠 k 안에 있는지 (margin 만큼 넓혀서)
    private function InStrip takes RemiliaFight f, integer k, real x, real y, real margin returns boolean
        local real c
        local real sn
        local real dx
        local real dy
        if f.sbState[k] == 0 then
            return false
        endif
        set c = Cos(f.sbA[k] * bj_DEGTORAD)
        set sn = Sin(f.sbA[k] * bj_DEGTORAD)
        set dx = x - f.sbX[k]
        set dy = y - f.sbY[k]
        return RAbsBJ(dx * c + dy * sn) <= SB_HALF_LEN + margin and RAbsBJ(-dx * sn + dy * c) <= f.sbW[k] + margin
    endfunction

    // 어느 띠 안이면 그 번호, 아니면 -1
    private function InAnyStrip takes RemiliaFight f, real x, real y, real margin returns integer
        local integer k = 0
        loop
            exitwhen k >= SB_MAX
            if InStrip(f, k, x, y, margin) then
                return k
            endif
            set k = k + 1
        endloop
        return -1
    endfunction

    // (x, y) 에서 a 방향 len 거리 안에서 처음 햇빛에 닿는 거리 (몸 반경 포함). 없으면 -1.
    // f.tx = 그 띠를 빠져나가는 거리 (금색 예고 끝)
    private function PathBeam takes RemiliaFight f, real x, real y, real a, real len returns real
        local real d = 0
        local real hit = -1
        local real px
        local real py
        local integer k = -1
        set f.tx = -1
        loop
            exitwhen d > len
            set px = x + PolarX(d, a)
            set py = y + PolarY(d, a)
            if hit < 0 then
                set k = InAnyStrip(f, px, py, BOSS_R)
                if k >= 0 then
                    set hit = d
                endif
            elseif not InStrip(f, k, px, py, BOSS_R) then
                set f.tx = d
                return hit
            endif
            set d = d + 15
        endloop
        if hit >= 0 then
            set f.tx = len
        endif
        return hit
    endfunction

    private function StripDecalsRemove takes RemiliaFight f, integer k returns nothing
        local integer j = 0
        loop
            exitwhen j >= SB_DEC
            if f.sbU[k * SB_DEC + j] != null then
                call ShowUnit(f.sbU[k * SB_DEC + j], false)
                call KillUnit(f.sbU[k * SB_DEC + j])
                set f.sbU[k * SB_DEC + j] = null
            endif
            set j = j + 1
        endloop
    endfunction

    // 노란 데칼 8개로 띠를 덮는다. stand(1초)를 SB_FADE 초에 걸쳐 채우고 다 채우면 멈춘다
    private function StripDecalsCreate takes RemiliaFight f, integer k returns nothing
        local integer j = 0
        local real d
        local unit u
        local real s = f.sbW[k] * 0.01
        loop
            exitwhen j >= SB_DEC
            set d = -SB_HALF_LEN + f.sbW[k] + (2 * SB_HALF_LEN - 2 * f.sbW[k]) * j / (SB_DEC - 1)
            set u = CreateUnit(GetOwningPlayer(f.boss), DECAL_ID, f.sbX[k] + PolarX(d, f.sbA[k]), f.sbY[k] + PolarY(d, f.sbA[k]), 270)
            call SetUnitScalePercent(u, 100 * s, 100 * s, 100)
            call SetUnitVertexColor(u, 255, 225, 70, 210)
            call SetUnitTimeScale(u, 1 / SB_FADE)
            set f.sbU[k * SB_DEC + j] = u
            set j = j + 1
        endloop
        set u = null
        // 햇빛 줄기 (임시): 띠 위 세 곳
        call FxKeep(f, FX_SUN_SHAFT, f.sbX[k], f.sbY[k], 1.2, 0, 2.5)
        call FxKeep(f, FX_SUN_SHAFT, f.sbX[k] + PolarX(SB_HALF_LEN * 0.6, f.sbA[k]), f.sbY[k] + PolarY(SB_HALF_LEN * 0.6, f.sbA[k]), 1.0, 0, 2.5)
        call FxKeep(f, FX_SUN_SHAFT, f.sbX[k] - PolarX(SB_HALF_LEN * 0.6, f.sbA[k]), f.sbY[k] - PolarY(SB_HALF_LEN * 0.6, f.sbA[k]), 1.0, 0, 2.5)
    endfunction

    // 새 띠 자리: 전장 안, 다른 띠와 떨어지고, 레밀리아·지정 띠(old) 자리와 겹치지 않게. 40번 시도
    private function StripPick takes RemiliaFight f, integer k, integer old returns nothing
        local rect r = MapRectReturn(f.rect)
        local integer n = 0
        local integer j
        local real a
        local real hx
        local real hy
        local real x
        local real y
        local boolean ok
        loop
            exitwhen n >= 40
            set a = GetRandomInt(0, 3) * 45.0 + GetRandomReal(-10, 10)
            set hx = SB_HALF_LEN * RAbsBJ(Cos(a * bj_DEGTORAD)) + SB_HALF_W * RAbsBJ(Sin(a * bj_DEGTORAD)) + 60
            set hy = SB_HALF_LEN * RAbsBJ(Sin(a * bj_DEGTORAD)) + SB_HALF_W * RAbsBJ(Cos(a * bj_DEGTORAD)) + 60
            if GetRectMaxX(r) - GetRectMinX(r) > 2 * hx and GetRectMaxY(r) - GetRectMinY(r) > 2 * hy then
                set x = GetRandomReal(GetRectMinX(r) + hx, GetRectMaxX(r) - hx)
                set y = GetRandomReal(GetRectMinY(r) + hy, GetRectMaxY(r) - hy)
                set ok = true
                set j = 0
                loop
                    exitwhen j >= SB_MAX
                    if j != k and f.sbState[j] != 0 and DistancePBP(x, y, f.sbX[j], f.sbY[j]) < 550 then
                        set ok = false
                    endif
                    set j = j + 1
                endloop
                if old >= 0 and DistancePBP(x, y, f.sbX[old], f.sbY[old]) < 400 then
                    set ok = false
                endif
                if ok or n == 39 then
                    set f.sbX[k] = x
                    set f.sbY[k] = y
                    set f.sbA[k] = a
                    // 레밀리아가 있는 자리에는 띠를 놓지 않는다 (상태를 잠깐 켜서 확인)
                    set f.sbState[k] = 1
                    if (not InStrip(f, k, GetUnitX(f.boss), GetUnitY(f.boss), BOSS_R + 150)) or n == 39 then
                        set r = null
                        return
                    endif
                    set f.sbState[k] = 0
                endif
            endif
            set n = n + 1
        endloop
        // 전장이 너무 좁으면 가운데 가로
        set f.sbX[k] = f.arenaCX()
        set f.sbY[k] = f.arenaCY()
        set f.sbA[k] = 0
        set f.sbState[k] = 1
        set r = null
    endfunction

    // 반폭 w 의 띠를 새로 놓는다 (보통 SB_HALF_W)
    private function StripSpawnW takes RemiliaFight f, integer k, integer old, real w returns nothing
        set f.sbW[k] = w
        call StripPick(f, k, old)
        set f.sbState[k] = 1
        set f.sbT[k] = f.now
        call StripDecalsCreate(f, k)
    endfunction

    private function StripSpawn takes RemiliaFight f, integer k, integer old returns nothing
        call StripSpawnW(f, k, old, SB_HALF_W)
    endfunction

    // 켜져 있거나 나타나는 중인 띠 수
    private function SunCount takes RemiliaFight f returns integer
        local integer k = 0
        local integer n = 0
        loop
            exitwhen k >= SB_MAX
            if f.sbState[k] == 1 or f.sbState[k] == 2 then
                set n = n + 1
            endif
            set k = k + 1
        endloop
        return n
    endfunction

    // 띠 하나를 사라지게 한다 (2초)
    private function StripFade takes RemiliaFight f, integer k returns nothing
        if f.sbState[k] == 1 or f.sbState[k] == 2 then
            set f.sbState[k] = 3
            set f.sbT[k] = f.now
        endif
    endfunction

    // 띠 상태 진행: 다 나타나면 멈춤, 사라지는 중이면 투명해지다 제거, 20초마다 한 줄 이동
    private function SunUpdate takes RemiliaFight f returns nothing
        local integer k = 0
        local integer j
        local integer alpha
        local integer old
        local integer n
        loop
            exitwhen k >= SB_MAX
            // 데칼 stand(1초)를 SB_FADE 초에 걸쳐 재생하므로 끝나기 직전에 멈춘다
            if f.sbState[k] == 1 and f.now >= f.sbT[k] + SB_FADE - 0.06 then
                // 다 채운 데칼을 그대로 멈춘다 (stand 가 끝나 처음부터 다시 채워지지 않게)
                set j = 0
                loop
                    exitwhen j >= SB_DEC
                    if f.sbU[k * SB_DEC + j] != null then
                        call SetUnitTimeScale(f.sbU[k * SB_DEC + j], 0)
                    endif
                    set j = j + 1
                endloop
                set f.sbState[k] = 2
            elseif f.sbState[k] == 3 then
                if f.now >= f.sbT[k] + SB_FADE then
                    call StripDecalsRemove(f, k)
                    set f.sbState[k] = 0
                elseif ModuloInteger(R2I(f.now / TICK + 0.5), 5) == 0 then
                    set alpha = R2I(210 * (1 - (f.now - f.sbT[k]) / SB_FADE))
                    set j = 0
                    loop
                        exitwhen j >= SB_DEC
                        if f.sbU[k * SB_DEC + j] != null then
                            call SetUnitVertexColor(f.sbU[k * SB_DEC + j], 255, 225, 70, alpha)
                        endif
                        set j = j + 1
                    endloop
                endif
            endif
            set k = k + 1
        endloop
        if f.now >= f.sbMoveAt then
            set f.sbMoveAt = f.now + SB_MOVE_EVERY
            // 켜져 있는 띠 중 하나(돌아가며)를 사라지게 하고, 동시에 빈 칸에 새 띠를 나타나게 한다
            set n = 0
            set old = -1
            loop
                exitwhen n >= SB_MAX
                set k = ModuloInteger(f.sbNext + n, SB_MAX)
                if f.sbState[k] == 2 and old < 0 then
                    set old = k
                endif
                set n = n + 1
            endloop
            if old >= 0 then
                set f.sbNext = old + 1
                set k = 0
                set n = -1
                loop
                    exitwhen k >= SB_MAX
                    if f.sbState[k] == 0 and n < 0 then
                        set n = k
                    endif
                    set k = k + 1
                endloop
                if n >= 0 then
                    set f.sbState[old] = 3
                    set f.sbT[old] = f.now
                    call StripSpawn(f, n, old)
                endif
            endif
        endif
    endfunction

    // 안개 농도에 맞는 햇빛 줄 수 (70 이하 1, 40 이하 2, 10 이하 3)
    private function FogSun takes RemiliaFight f returns integer
        if f.fog <= 10 then
            return 3
        elseif f.fog <= 40 then
            return 2
        elseif f.fog <= 70 then
            return 1
        endif
        return 0
    endfunction

    // 켜진 띠 수를 맞춘다 (1페이즈: 시작 2줄, 체력 85% 부터 3줄 / 2페이즈: 안개 농도). 많으면 사라지게 한다
    private function SunRefill takes RemiliaFight f returns nothing
        local integer k = 0
        local integer on = SunCount(f)
        local integer want = 2
        if f.state == REMILIA_PHASE2 then
            set want = FogSun(f)
        elseif f.third then
            set want = 3
        endif
        loop
            exitwhen k >= SB_MAX or on >= want
            if f.sbState[k] == 0 then
                call StripSpawn(f, k, -1)
                set on = on + 1
            endif
            set k = k + 1
        endloop
        set k = SB_MAX - 1
        loop
            exitwhen k < 0 or on <= want
            if f.sbState[k] == 1 or f.sbState[k] == 2 then
                call StripFade(f, k)
                set on = on - 1
            endif
            set k = k - 1
        endloop
    endfunction

    private function SunClear takes RemiliaFight f returns nothing
        local integer k = 0
        loop
            exitwhen k >= SB_MAX
            call StripDecalsRemove(f, k)
            set f.sbState[k] = 0
            set k = k + 1
        endloop
    endfunction

    // ======================================================================
    // 취소·정리
    // ======================================================================
    private function CueClear takes RemiliaFight f returns nothing
        local integer i = 0
        loop
            exitwhen i >= 3
            if f.cue[i] != null then
                call KillUnit(f.cue[i])
                call ShowUnit(f.cue[i], false)
                set f.cue[i] = null
            endif
            set i = i + 1
        endloop
        if f.eyeFx != null then
            call DestroyEffect(f.eyeFx)
            set f.eyeFx = null
        endif
    endfunction

    private function BurnClear takes RemiliaFight f returns nothing
        if f.burnFx != null then
            call DestroyEffect(f.burnFx)
            set f.burnFx = null
        endif
    endfunction

    // 피해 잠금: 박쥐로 흩어진 동안, 1페이즈 끝 연출 중
    private function UpdateLock takes RemiliaFight f returns nothing
        set UnitDamageLock[IndexUnit(f.boss)] = f.hidden or f.invuln or f.state == REMILIA_PHASE_END or f.state == REMILIA_TRANSITION
    endfunction

    private function ShowBoss takes RemiliaFight f, boolean on returns nothing
        set f.hidden = not on
        if on then
            call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
        else
            call SetUnitVertexColor(f.boss, 255, 255, 255, 0)
        endif
        call UpdateLock(f)
    endfunction

    private function CancelAttacks takes RemiliaFight f returns nothing
        local integer i = 0
        loop
            exitwhen i >= MAXP
            if f.pk[i] != 0 then
                call ProjKill(f, i)
            endif
            set i = i + 1
        endloop
        call ClearDecals(f)
        call CueClear(f)
        call BurnClear(f)
        call LzUpdate(f, true)
        if f.boss != null then
            call UnitRemoveAbility(f.boss, 'A00V')
            if f.hidden then
                call ShowBoss(f, true)
            endif
            call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
        endif
        set f.pat = 0
        set f.step = 0
        set f.dashLeft = 0
        set f.burn = false
        set f.target = null
    endfunction

    // ======================================================================
    // 패턴 시작·종료
    // ======================================================================
    private function IsBig takes integer id returns boolean
        return id == PAT_CRADLE or id == PAT_QUEEN or id == PAT_STAR or id == PAT_GUNGNIR or id == PAT_MISERY or id == PAT_DRACULA
    endfunction

    private function IsGimmick takes integer id returns boolean
        return id == PAT_FATE or id == PAT_NIGHT or id == PAT_GENSO
    endfunction

    private function PatternEnd takes RemiliaFight f, real rest returns nothing
        call ClearDecals(f)
        call CueClear(f)
        call UnitRemoveAbility(f.boss, 'A00V')
        call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
        set f.pat = 0
        set f.step = 0
        set f.target = null
        set f.nextSelect = f.now + rest
        call AnimIdle(f)
    endfunction

    // 패턴 하나가 끝났을 때: 기본 패턴 수를 세고 (큰 패턴 2~3번에 한 번), 휴식
    private function PatternDone takes RemiliaFight f, real rest returns nothing
        if IsBig(f.pat) then
            set f.fillN = 0
            set f.bigEvery = GetRandomInt(2, 3)
            // 2페이즈 10% 아래 마지막 발악: 대형 패턴 간격이 짧아진다
            if f.lastStruggle then
                set f.bigEvery = 1
            endif
        elseif IsGimmick(f.pat) then
            set f.fillN = 0
        elseif f.pat != PAT_BAT then
            set f.fillN = f.fillN + 1
        endif
        call PatternEnd(f, rest)
    endfunction

    private function PatName takes integer id returns string
        if id == PAT_CLAW then
            return "뱀파이어 클로"
        elseif id == PAT_HEART then
            return "하트 브레이크"
        elseif id == PAT_SHOOT then
            return "스칼렛 슛"
        elseif id == PAT_FLAP then
            return "날갯짓"
        elseif id == PAT_CRADLE then
            return "마왕의 요람"
        elseif id == PAT_QUEEN then
            return "퀸 오브 미드나이트"
        elseif id == PAT_STAR then
            return "다윗의 별"
        elseif id == PAT_HEART2 then
            return "하트 브레이크"
        elseif id == PAT_SCRAMBLE then
            return "배드 레이디 스크램블"
        elseif id == PAT_MEIKAI then
            return "홍색의 명계"
        elseif id == PAT_SWARM then
            return "박쥐 떼"
        elseif id == PAT_GUNGNIR then
            return "스피어 더 궁니르"
        elseif id == PAT_MISERY then
            return "미저러블 페이트"
        elseif id == PAT_DRACULA then
            return "드라큘라 크레이들"
        elseif id == PAT_FATE then
            return "운명 예지"
        elseif id == PAT_NIGHT then
            return "퀸 오브 미드나이트"
        elseif id == PAT_GENSO then
            return "홍색의 환상향"
        endif
        return ""
    endfunction

    // 보스 머리 위 패턴 이름: 기본 흰색, 큰 패턴 주황, 체력 기믹 붉은색·크게. 1.8초, 보스를 따라감
    private function ShowName takes RemiliaFight f, string n, integer kind returns nothing
        if n == "" or f.boss == null then
            return
        endif
        if f.patTag != null and f.now < f.patTagEnd then
            call DestroyTextTag(f.patTag)
        endif
        set f.patTag = CreateTextTag()
        if kind == 2 then
            call SetTextTagText(f.patTag, n, 0.036)
            call SetTextTagColor(f.patTag, 255, 60, 60, 255)
        elseif kind == 1 then
            call SetTextTagText(f.patTag, n, 0.030)
            call SetTextTagColor(f.patTag, 255, 150, 40, 255)
            call MsgAll(f, "|cFFFF9628" + n + "|r", 2.0)
        else
            call SetTextTagText(f.patTag, n, 0.026)
            call SetTextTagColor(f.patTag, 255, 255, 255, 255)
        endif
        call SetTextTagPos(f.patTag, GetUnitX(f.boss) - 60, GetUnitY(f.boss), 300)
        call SetTextTagPermanent(f.patTag, false)
        call SetTextTagFadepoint(f.patTag, 1.3)
        call SetTextTagLifespan(f.patTag, 1.8)
        call SetTextTagVisibility(f.patTag, true)
        set f.patTagEnd = f.now + 1.8
    endfunction

    private function PatNameFollow takes RemiliaFight f returns nothing
        if f.patTag == null then
            return
        endif
        if f.now >= f.patTagEnd then
            set f.patTag = null
            return
        endif
        call SetTextTagPos(f.patTag, GetUnitX(f.boss) - 60, GetUnitY(f.boss), 300 + 30 * (1.8 - (f.patTagEnd - f.now)))
    endfunction

    private function StartPattern takes RemiliaFight f, integer id returns nothing
        local real a
        set f.pat = id
        set f.step = 0
        set f.patStart = f.now
        if IsGimmick(id) then
            call ShowName(f, PatName(id), 2)
            call MsgAll(f, "|cFFFF4040" + PatName(id) + "|r", 3.0)
        elseif IsBig(id) then
            call ShowName(f, PatName(id), 1)
        else
            call ShowName(f, PatName(id), 0)
        endif
        set f.readyAt[id] = f.now + PatCool[id]
        if IsBig(id) then
            set f.lastBig = id
        elseif id != PAT_BAT and not IsGimmick(id) then
            set f.lastFill = id
        endif
        if f.hit == 0 then
            set f.hit = party.create()
        endif
        call GroupClear(f.hit.super)
        set f.target = PickTarget(f)
        if f.target != null then
            set a = AngleWBW(f.boss, f.target)
            call Face(f, a)
            set f.ang = a
        endif
    endfunction

    // ======================================================================
    // 박쥐 흩어짐 (걷기 대신): 0.4초에 사라짐 → 박쥐 0.8초 이동 → 대상 300~450 햇빛 밖에서 다시 모임 (예고 0.7초)
    // ======================================================================
    private function BatSpot takes RemiliaFight f returns boolean
        local integer n = 0
        local real a
        local real d
        local real x
        local real y
        local real cx = GetUnitX(f.boss)
        local real cy = GetUnitY(f.boss)
        if MemAlive(f.target) then
            set cx = GetUnitX(f.target)
            set cy = GetUnitY(f.target)
        endif
        loop
            exitwhen n >= 24
            set a = GetRandomReal(0, 360)
            set d = GetRandomReal(BAT_NEAR, BAT_FAR)
            set x = ClampX(f, cx + PolarX(d, a))
            set y = ClampY(f, cy + PolarY(d, a))
            if InAnyStrip(f, x, y, BOSS_R + 40) < 0 and DistancePBP(x, y, cx, cy) >= BAT_NEAR * 0.7 then
                set f.tx = x
                set f.ty = y
                return true
            endif
            set n = n + 1
        endloop
        // 못 찾으면 전장 가운데 (햇빛 밖일 때만)
        if InAnyStrip(f, f.arenaCX(), f.arenaCY(), BOSS_R + 40) < 0 then
            set f.tx = f.arenaCX()
            set f.ty = f.arenaCY()
            return true
        endif
        return false
    endfunction

    private function RunBat takes RemiliaFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local real d
        local real a
        if f.step == 0 then
            if not BatSpot(f) then
                // 갈 곳이 없으면 잠깐 쉬었다 다시
                set f.batAt = f.now + 1.0
                call PatternEnd(f, 0.5)
                return
            endif
            set f.batAt = f.now + BAT_COOL
            call Anim(f, AN_BAT_OUT, 1.0)
            call VoiceSlot(f, VO_BAT, false)
            set f.step = 1
        elseif f.step == 1 and el >= BAT_HIDE then
            call ShowBoss(f, false)
            set d = DistancePBP(bx, by, f.tx, f.ty)
            set a = AnglePBP(bx, by, f.tx, f.ty)
            call FxAt(FX_BATS_HIT, bx, by, 1.0, a)
            call ProjSpawn(f, 3, FX_BATS, bx, by, a, RMaxBJ(1, d) / BAT_TRAVEL, d, 0, 0, 1.2)
            call ProjSpawn(f, 3, FX_BATS, bx, by, a - 10, RMaxBJ(1, d) / BAT_TRAVEL, d, 0, 0, 0.9)
            call ProjSpawn(f, 3, FX_BATS, bx, by, a + 10, RMaxBJ(1, d) / BAT_TRAVEL, d, 0, 0, 0.9)
            set f.step = 2
        elseif f.step == 2 and el >= BAT_HIDE + BAT_TRAVEL - BAT_TELL then
            call Decal(f, f.tx, f.ty, BAT_RADIUS, BAT_TELL, 0)
            set f.step = 3
        elseif f.step == 3 and el >= BAT_HIDE + BAT_TRAVEL then
            call SetUnitPosition(f.boss, f.tx, f.ty)
            call ShowBoss(f, true)
            if MemAlive(f.target) then
                set f.face = AngleWBW(f.boss, f.target) + 10
                call Face(f, AngleWBW(f.boss, f.target))
            endif
            call Anim(f, AN_BAT_IN, 1.0)
            call FxAt(FX_BATS_HIT, f.tx, f.ty, 1.5, 0)
            call FxHitSmall(f.tx, f.ty, f.face)
            call HitCircle(f, f.tx, f.ty, BAT_RADIUS, DMG_BAT, false, 0)
            set f.step = 4
        elseif f.step == 4 and el >= BAT_HIDE + BAT_TRAVEL + 0.6 then
            call PatternDone(f, 0.3)
        endif
    endfunction

    // ======================================================================
    // 기본 1. 뱀파이어 클로: 앞쪽 2연타 (r350, ±70도, 예고 0.9초)
    // ======================================================================
    private function RunClaw takes RemiliaFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        if f.step == 0 then
            // 한 팔 할퀴기: 휘두름(약 0.45초)이 0.9초 판정에 맞도록 절반 속도
            call Anim(f, AN_ATTACK, 0.45 / CLAW_TELL)
            call FxWindup(f)
            call TeleFan(f, bx, by, f.ang, CLAW_R, CLAW_HALF, CLAW_TELL)
            set f.step = 1
        elseif f.step == 1 and el >= CLAW_TELL then
            call HitFan(f, bx, by, f.ang, CLAW_R, CLAW_HALF, DMG_CLAW, false)
            call Grunt(f)
            call FxClaw(bx, by, f.ang, 15, CLAW_R)
            call FxHitSmall(bx + PolarX(200, f.ang), by + PolarY(200, f.ang), f.ang)
            // 두 번째: 대상을 다시 보고 몸을 돌리며 손등 베기
            if MemAlive(f.target) then
                set f.ang = AngleWBW(f.boss, f.target)
                call Face(f, f.ang)
            endif
            call Anim(f, AN_SPELL1, 0.55 / CLAW_TELL2)
            call TeleFan(f, bx, by, f.ang, CLAW_R, CLAW_HALF, CLAW_TELL2)
            set f.step = 2
        elseif f.step == 2 and el >= CLAW_TELL + CLAW_TELL2 then
            call HitFan(f, bx, by, f.ang, CLAW_R, CLAW_HALF, DMG_CLAW, false)
            call FxClaw(bx, by, f.ang, -15, CLAW_R)
            call FxHitSmall(bx + PolarX(200, f.ang), by + PolarY(200, f.ang), f.ang)
            set f.step = 3
        elseif f.step == 3 and el >= CLAW_TELL + CLAW_TELL2 + 0.4 then
            call PatternDone(f, RestFill())
        endif
    endfunction

    // ======================================================================
    // 기본 2. 하트 브레이크: 창 직선 (폭 120, 예고 0.9초). 햇빛 안의 영웅을 우선 노린다
    // ======================================================================
    private function SunTarget takes RemiliaFight f returns unit
        local integer i = 0
        local integer n = 0
        local unit best = null
        loop
            exitwhen i >= f.memN
            if MemAlive(f.mem[i]) and InAnyStrip(f, GetUnitX(f.mem[i]), GetUnitY(f.mem[i]), 0) >= 0 then
                set n = n + 1
                if GetRandomInt(1, n) == 1 then
                    set best = f.mem[i]
                endif
            endif
            set i = i + 1
        endloop
        return best
    endfunction

    private function RunHeart takes RemiliaFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local unit u
        if f.step == 0 then
            set u = SunTarget(f)
            if u != null then
                set f.target = u
                set f.ang = AngleWBW(f.boss, u)
                call Face(f, f.ang)
            endif
            set u = null
            set f.dashLen = RMinBJ(HEART_LEN, EdgeDist(f, bx, by, f.ang))
            // 창을 꺼내 (0.3초) 든 채로 유지 → 던지기
            call AnimThen(f, AN_SPEAR_SUMMON, 1.0, AN_SPEAR_HOLD)
            call FxWindup(f)
            call TeleLine(f, bx, by, f.ang, f.dashLen, HEART_W, HEART_TELL)
            set f.step = 2
        elseif f.step == 2 and el >= HEART_TELL - 0.15 then
            call Anim(f, AN_SPEAR_THROW, 1.0)
            call VoiceSlot(f, VO_HEART, false)
            set f.step = 3
        elseif f.step == 3 and el >= HEART_TELL then
            call ProjSpawn(f, 2, FX_SPEAR, bx + PolarX(40, f.ang), by + PolarY(40, f.ang), f.ang, HEART_SPEED, f.dashLen - 40, HEART_W * 0.5, DMG_HEART, 1.2)
            call FxAt(FX_FLASH_RED, bx + PolarX(80, f.ang), by + PolarY(80, f.ang), 1.2, f.ang)
            call FxAt(FX_BURST, bx + PolarX(80, f.ang), by + PolarY(80, f.ang), 0.7, f.ang)
            set f.step = 4
        elseif f.step == 4 and el >= HEART_TELL + 0.5 then
            call PatternDone(f, RestFill())
        endif
    endfunction

    // ======================================================================
    // 기본 3. 스칼렛 슛: 큰 탄 5발 부채꼴 2파. 두 번째 파는 간격의 절반만큼 어긋난다
    // ======================================================================
    private function ShootWave takes RemiliaFight f, real off, boolean fire returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local integer k = 0
        local real a
        loop
            exitwhen k >= SHOOT_N
            set a = f.ang + (k - (SHOOT_N - 1) * 0.5) * SHOOT_GAP + off
            if fire then
                call ProjSpawn(f, 1, FX_ORB, bx + PolarX(60, a), by + PolarY(60, a), a, SHOOT_SPEED, SHOOT_RANGE, SHOOT_R, DMG_SHOOT, FX_ORB_SIZE)
            else
                call TeleLine(f, bx, by, a, 700, SHOOT_R * 2, 0.6)
            endif
            set k = k + 1
        endloop
        if fire then
            call FxAt(FX_FLASH_RED, bx + PolarX(80, f.ang), by + PolarY(80, f.ang), 1.5, f.ang)
        endif
    endfunction

    private function RunShoot takes RemiliaFight f, real el returns nothing
        if f.step == 0 then
            call Anim(f, AN_CAST, 1.0)
            call FxWindup(f)
            call VoiceSlot(f, VO_SHOOT, false)
            call ShootWave(f, 0, false)
            set f.step = 1
        elseif f.step == 1 and el >= 0.6 then
            call ShootWave(f, 0, true)
            set f.step = 2
        elseif f.step == 2 and el >= 0.8 then
            call Anim(f, AN_CAST, 1.0)
            call ShootWave(f, SHOOT_GAP * 0.5, false)
            set f.step = 3
        elseif f.step == 3 and el >= 1.4 then
            call ShootWave(f, SHOOT_GAP * 0.5, true)
            set f.step = 4
        elseif f.step == 4 and el >= 2.0 then
            call PatternDone(f, RestFill())
        endif
    endfunction

    // ======================================================================
    // 기본 4. 날갯짓: 등 뒤에 2초 넘게 있는 영웅이 있으면 (r300 밀어내기)
    // ======================================================================
    private function RunFlap takes RemiliaFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local integer i = 0
        local unit u
        if f.step == 0 then
            // 등 뒤를 노리는 공격이라 몸을 돌리지 않는다
            call Face(f, f.face)
            call Decal(f, bx, by, FLAP_R, FLAP_TELL, 0)
            call FxWindup(f)
            call Anim(f, AN_WINDUP, 1.0)
            set f.step = 1
        elseif f.step == 1 and el >= FLAP_TELL - 0.25 then
            call Anim(f, AN_WING_BURST, 1.0)
            call Grunt(f)
            set f.step = 2
        elseif f.step == 2 and el >= FLAP_TELL then
            loop
                exitwhen i >= f.memN
                set u = f.mem[i]
                if MemAlive(u) and IsUnitInRangeXY(u, bx, by, FLAP_R) then
                    call Deal(f, u, DMG_FLAP, false)
                    call Knockback(u, AnglePBP(bx, by, GetUnitX(u), GetUnitY(u)), FLAP_KNOCK, 0.3)
                endif
                set f.behindT[i] = 0
                set i = i + 1
            endloop
            set u = null
            set f.flapWant = false
            call FxAt(FX_BURST, bx, by, 2.0, f.face + 180)
            call FxAt(FX_STOMP, bx, by, 0.8, 0)
            set f.step = 3
        elseif f.step == 3 and el >= FLAP_TELL + 0.6 then
            call PatternDone(f, RestFill())
        endif
    endfunction

    // ======================================================================
    // 큰 1. 마왕의 요람: 1.2초 조준 (대상을 따라가다 돌진 0.4초 전 고정) → 회전 돌진 1100.
    //  경로가 햇빛을 지나면 띠 가장자리에서 멈춰 불타고 4.5초 그로기. 햇빛과 겹치는 예고 부분은 금색.
    //  햇빛이 없으면 끝에서 2.5초 머문다
    // ======================================================================
    private function CradleTele takes RemiliaFight f, real len returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        if f.cTele == null then
            set f.cTele = AddSpecialEffect(TELE_LINE, bx, by)
            set f.cTeleAng = -1
        endif
        if f.cTeleAng < 0 or AngDiff(f.cTeleAng, f.ang) > 0.8 then
            call EXEffectMatReset(f.cTele)
            call EXEffectMatScale(f.cTele, len / TELE_LEN, f.cTeleW / TELE_LINE_W, 1)
            call EXEffectMatRotateZ(f.cTele, f.ang)
            call EXSetEffectXY(f.cTele, bx, by)
            set f.cTeleAng = f.ang
        endif
    endfunction

    // 금색 예고: 경로가 햇빛과 겹치는 구간 (time 초 유지)
    private function CradleGold takes RemiliaFight f, real len, real time returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local real hit = PathBeam(f, bx, by, f.ang, len)
        if hit >= 0 then
            call DecalSeg(f, bx, by, f.ang, hit, RMaxBJ(hit + 1, f.tx), CRADLE_W, time, 2)
        endif
    endfunction

    private function RunCradle takes RemiliaFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local real nx
        local real ny
        local real step
        local real len
        if f.step == 0 then
            // 팔·날개를 뒤로 젖히고 그 자세로 조준
            call AnimThen(f, AN_WINDUP, 1.0, AN_WINDUP_HOLD)
            call FxWindup(f)
            set f.cGoldAt = 0
            set f.cTeleW = CRADLE_W
            set f.step = 1
        elseif f.step == 1 then
            set len = EdgeDist(f, bx, by, f.ang)
            if el < CRADLE_AIM - CRADLE_LOCK then
                // 대상을 따라 돈다 (빠르게)
                if MemAlive(f.target) then
                    call TurnToward(f, AngleWBW(f.boss, f.target), 540 * TICK)
                    set f.ang = f.face
                endif
                call CradleTele(f, len)
                if f.now >= f.cGoldAt then
                    set f.cGoldAt = f.now + 0.2
                    call CradleGold(f, len, 0.22)
                endif
            else
                // 고정: 마지막 금색 예고는 돌진이 끝날 때까지
                call CradleTele(f, len)
                call CradleGold(f, len, CRADLE_LOCK + 0.6)
                call FxAt(FX_FLASH_RED, bx, by, 2.0, f.ang)
                set f.step = 2
            endif
        elseif f.step == 2 and el >= CRADLE_AIM then
            set f.ax = bx
            set f.ay = by
            set f.dashLen = RMinBJ(CRADLE_LEN, EdgeDist(f, bx, by, f.ang) - 150)
            set len = PathBeam(f, bx, by, f.ang, f.dashLen)
            set f.burn = len >= 0
            if f.burn then
                set f.dashLen = RMaxBJ(0, len)
            endif
            set f.dashLeft = f.dashLen
            set f.dashSpeed = CRADLE_SPEED
            set f.nextFx = 0
            // 몸을 앞으로 눕혀 (0.3초) 엎드려 나는 자세로 돌진
            call AnimThen(f, AN_FLY_START, 1.0, AN_FLY_LOOP)
            if f.pat == PAT_DRACULA then
                call VoiceSlot(f, VO_DRACULA, false)
            else
                call VoiceSlot(f, VO_CRADLE, false)
            endif
            call FxAt(FX_BURST, bx, by, 1.2, f.ang)
            set f.step = 3
        elseif f.step == 3 then
            set step = RMinBJ(f.dashLeft, f.dashSpeed * TICK)
            set nx = ClampX(f, bx + PolarX(step, f.ang))
            set ny = ClampY(f, by + PolarY(step, f.ang))
            call SetUnitPosition(f.boss, nx, ny)
            call HitSweep(f, bx, by, nx, ny, CRADLE_W * 0.5, DMG_CRADLE, true, f.hit, CRADLE_KNOCK)
            set f.dashLeft = f.dashLeft - step
            if f.now >= f.nextFx then
                set f.nextFx = f.now + 0.08
                call FxAt(FX_SPIN, nx, ny, 1.0, f.ang)
                call FxAt(FX_FLASH_RED, nx, ny, 0.8, f.ang)
            endif
            if f.dashLeft <= 0 or (nx == bx and ny == by) then
                call CradleTeleClear(f)
                set f.patStart = f.now
                if f.burn then
                    // 햇빛: 띠 가장자리에서 멈추고 불탄다 → 공중에서 구르다 그로기
                    set f.burnFx = AddSpecialEffectTarget(FX_BURN, f.boss, "chest")
                    call FxAt(FX_BURN_HIT, nx, ny, 1.0, 0)
                    call FxHitBig(f, nx, ny, f.ang, 0.8)
                    call Anim(f, AN_FLY_TUMBLE, 1.0)
                    call VoiceSlot(f, VO_GROGGY, true)
                    call MsgAll(f, "|cFFFFD040레밀리아가 햇빛에 닿았다!|r", 2.5)
                    if f.pat == PAT_DRACULA then
                        call FogAdd(f, -FOG_DRACULA)
                    endif
                    set f.step = 5
                elseif f.pat == PAT_DRACULA then
                    // 드라큘라 크레이들: 끝에서 뛰어올랐다 1.0초 뒤 반경 300 내리찍기
                    call Anim(f, AN_LEAP, AnimDur[AN_LEAP] / DRACULA_SLAM_TELL)
                    call Decal(f, nx, ny, DRACULA_SLAM_R, DRACULA_SLAM_TELL, 0)
                    set f.tx = nx
                    set f.ty = ny
                    set f.step = 7
                else
                    call Anim(f, AN_FLY_LAND, 1.0)
                    call FxAt(FX_STOMP, nx, ny, 0.8, 0)
                    set f.step = 4
                endif
            endif
        elseif f.step == 7 and el >= DRACULA_SLAM_TELL then
            call Anim(f, AN_PLUNGE, 1.0)
            call HitCircle(f, f.tx, f.ty, DRACULA_SLAM_R, DMG_DRACULA_SLAM, true, 0)
            call FxHitBig(f, f.tx, f.ty, 0, 1.2)
            set f.holdUntil = f.now + 1.2
            set f.step = 8
        elseif f.step == 8 and el >= DRACULA_SLAM_TELL + 0.8 then
            call PatternDone(f, RestBig())
        elseif f.step == 4 and el >= AnimDur[AN_FLY_LAND] then
            // 햇빛 없음: 착지한 자리에서 2.5초 머문다 (큰 패턴 뒤 휴식을 겸함, 돌아서지도 않음)
            set f.holdUntil = f.now + CRADLE_STAY
            call PatternDone(f, CRADLE_STAY)
        elseif f.step == 5 and el >= 0.35 then
            call AnimDown(f)
            set f.step = 6
        elseif f.step == 6 and el >= BURN_GROGGY then
            call BurnClear(f)
            call PatternDone(f, RestBig())
        endif
    endfunction

    // ======================================================================
    // 큰 2. 퀸 오브 미드나이트: 300 물러남 → 눈빛(카운터 신호) 2.0초 → 할퀴며 돌진.
    //  카운터 성공: 4.5초 그로기 / 실패: 350 피해 + 1초 기절
    // ======================================================================
    private function RunQueen takes RemiliaFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local real nx
        local real ny
        local real step
        local real a
        local real away
        local integer k
        if f.step == 0 then
            // 물러날 곳: 대상 반대쪽부터 ±30·60·90 도. 전장 안이고 햇빛 밖인 곳 (스스로 햇빛에 서지 않는다)
            set away = f.ang + 180
            set f.dashLen = 0
            set k = 0
            loop
                exitwhen k >= 7
                if k == 0 then
                    set a = away
                elseif ModuloInteger(k, 2) == 1 then
                    set a = away + 30 * ((k + 1) / 2)
                else
                    set a = away - 30 * (k / 2)
                endif
                set nx = ClampX(f, bx + PolarX(QUEEN_BACK, a))
                set ny = ClampY(f, by + PolarY(QUEEN_BACK, a))
                if DistancePBP(bx, by, nx, ny) >= 150 and InAnyStrip(f, nx, ny, BOSS_R + 40) < 0 and PathBeam(f, bx, by, a, DistancePBP(bx, by, nx, ny)) < 0 then
                    set f.tx = nx
                    set f.ty = ny
                    set f.dashLen = DistancePBP(bx, by, nx, ny)
                    set f.dashSpeed = f.dashLen / 0.5
                    set f.ax = a
                    set k = 7
                endif
                set k = k + 1
            endloop
            set f.dashLeft = f.dashLen
            call Anim(f, AN_BACKFLIP, 1.0)
            set f.step = 1
        elseif f.step == 1 then
            if f.dashLeft > 0 then
                set step = RMinBJ(f.dashLeft, f.dashSpeed * TICK)
                call SetUnitPosition(f.boss, ClampX(f, bx + PolarX(step, f.ax)), ClampY(f, by + PolarY(step, f.ax)))
                set f.dashLeft = f.dashLeft - step
            endif
            if el >= 0.75 then
                // 카운터 창: 대상을 정면으로 보고 방향 고정, 눈이 빛남 (아쳐와 같은 신호·판정)
                if not MemAlive(f.target) then
                    set f.target = NearestMem(f)
                endif
                if MemAlive(f.target) then
                    set f.ang = AngleWBW(f.boss, f.target)
                endif
                call Face(f, f.ang)
                // 팔·날개를 뒤로 젖힌 자세로 창 동안 버틴다
                call AnimThen(f, AN_WINDUP, 1.0, AN_WINDUP_HOLD)
                call UnitAddAbility(f.boss, 'A00V')
                call SetUnitVertexColorBJ(f.boss, 70, 70, 100, 0)
                set f.cue[0] = UnitEffectTimeEX('e00F', bx, by, 0, 3)
                set f.cue[1] = UnitEffectTimeEX('e00G', bx, by, 0, 3)
                set f.cue[2] = UnitEffectTimeEX('e01S', bx, by, 0, 3)
                call DestroyEffect(AddSpecialEffectTarget(FX_COUNTER_READY, f.boss, "origin"))
                set f.eyeFx = AddSpecialEffectTarget(FX_EYES, f.boss, "head")
                call FxWindup(f)
                call VoiceSlot(f, VO_QUEEN, false)
                // 돌진 거리: 햇빛 앞에서 멈춘다 (스스로 햇빛에 들어가지 않음)
                set f.dashLen = RMinBJ(QUEEN_LUNGE, EdgeDist(f, bx, by, f.ang) - 150)
                set a = PathBeam(f, bx, by, f.ang, f.dashLen)
                if a >= 0 then
                    set f.dashLen = RMaxBJ(0, a - 10)
                endif
                call TeleLine(f, bx, by, f.ang, f.dashLen + QUEEN_REACH, QUEEN_W, QUEEN_WINDOW + 0.25)
                set f.patStart = f.now
                set f.step = 2
            endif
        elseif f.step == 2 then
            if GetUnitAbilityLevel(f.boss, 'A00V') == 0 then
                // 카운터 성공
                call ClearDecals(f)
                call CueClear(f)
                call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
                call Sound3D(f.boss, 'A00U')
                call VoiceSlot(f, VO_COUNTERHIT, true)
                call AnimDown(f)
                set f.patStart = f.now
                set f.step = 6
            elseif el >= QUEEN_WINDOW then
                // 실패: 빠르게 찌르며 돌진
                call UnitRemoveAbility(f.boss, 'A00V')
                call CueClear(f)
                call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
                call Anim(f, AN_LUNGE, 1.0)
                set f.ax = bx
                set f.ay = by
                set f.dashLeft = f.dashLen
                set f.dashSpeed = RMaxBJ(1, f.dashLen) / 0.25
                call FxAt(FX_BURST, bx, by, 1.0, f.ang)
                set f.patStart = f.now
                set f.step = 3
            endif
        elseif f.step == 3 then
            set step = RMinBJ(f.dashLeft, f.dashSpeed * TICK)
            set nx = ClampX(f, bx + PolarX(step, f.ang))
            set ny = ClampY(f, by + PolarY(step, f.ang))
            if step > 0 then
                call SetUnitPosition(f.boss, nx, ny)
            endif
            set f.dashLeft = f.dashLeft - step
            if f.dashLeft <= 0 or el >= 0.3 then
                call HitRect(f, f.ax, f.ay, f.ang, DistancePBP(f.ax, f.ay, nx, ny) + QUEEN_REACH, QUEEN_W, DMG_QUEEN, false, 0, QUEEN_STUN)
                call FxClaw(nx, ny, f.ang, 20, QUEEN_REACH + 150)
                call FxClaw(nx, ny, f.ang, -20, QUEEN_REACH + 150)
                call FxHitBig(f, nx + PolarX(150, f.ang), ny + PolarY(150, f.ang), f.ang, 1.0)
                set f.patStart = f.now
                set f.step = 4
            endif
        elseif f.step == 4 and el >= 0.6 then
            call PatternDone(f, RestBig())
        elseif f.step == 6 and el >= QUEEN_GROGGY then
            call PatternDone(f, RestBig())
        endif
    endfunction

    // ======================================================================
    // 큰 3. 다윗의 별: 대상 둘레 삼각형 레이저 3줄 (예고 1.5초), 1초 뒤 60도 돌린 삼각형.
    //  가운데는 두 번 모두 안전, 마지막에 가운데 r200 폭발
    // ======================================================================
    private function StarSet takes RemiliaFight f, integer base, real rot returns nothing
        local integer k = 0
        local real a1
        local real a2
        local real x1
        local real y1
        local real x2
        local real y2
        local real ea
        loop
            exitwhen k >= 3
            set a1 = rot + 120 * k
            set a2 = rot + 120 * (k + 1)
            set x1 = f.tx + PolarX(STAR_R, a1)
            set y1 = f.ty + PolarY(STAR_R, a1)
            set x2 = f.tx + PolarX(STAR_R, a2)
            set y2 = f.ty + PolarY(STAR_R, a2)
            set ea = AnglePBP(x1, y1, x2, y2)
            // 변의 가운데에서 양쪽으로 STAR_LEN/2 씩 늘린 직선
            set f.lx[base + k] = (x1 + x2) * 0.5 - PolarX(STAR_LEN * 0.5, ea)
            set f.ly[base + k] = (y1 + y2) * 0.5 - PolarY(STAR_LEN * 0.5, ea)
            set f.la[base + k] = ea
            call TeleLine(f, f.lx[base + k], f.ly[base + k], ea, STAR_LEN, STAR_W, STAR_TELL)
            set k = k + 1
        endloop
    endfunction

    private function StarFire takes RemiliaFight f, integer base returns nothing
        local integer k = 0
        local real x2
        local real y2
        call GroupClear(f.hit.super)
        loop
            exitwhen k >= 3
            set x2 = f.lx[base + k] + PolarX(STAR_LEN, f.la[base + k])
            set y2 = f.ly[base + k] + PolarY(STAR_LEN, f.la[base + k])
            call HitRect(f, f.lx[base + k], f.ly[base + k], f.la[base + k], STAR_LEN, STAR_W, DMG_LASER, false, f.hit, 0)
            call LzAdd(f, f.lx[base + k], f.ly[base + k], x2, y2, 0.35)
            call FxAt(FX_FLASH_RED, (f.lx[base + k] + x2) * 0.5, (f.ly[base + k] + y2) * 0.5, 2.0, f.la[base + k])
            set k = k + 1
        endloop
        call CameraShaker.setShake(5)
    endfunction

    private function RunStar takes RemiliaFight f, real el returns nothing
        if f.step == 0 then
            set f.tx = GetUnitX(f.boss)
            set f.ty = GetUnitY(f.boss)
            if MemAlive(f.target) then
                set f.tx = GetUnitX(f.target)
                set f.ty = GetUnitY(f.target)
            endif
            set f.dashLen = GetRandomReal(0, 120)
            call Anim(f, AN_BIG_CAST, 1.0)
            call FxWindup(f)
            call VoiceSlot(f, VO_STAR, false)
            call StarSet(f, 0, f.dashLen)
            set f.step = 1
        elseif f.step == 1 and el >= STAR_SECOND then
            call Anim(f, AN_CAST, 1.0)
            call StarSet(f, 3, f.dashLen + 60)
            set f.step = 2
        elseif f.step == 2 and el >= STAR_TELL then
            call StarFire(f, 0)
            set f.step = 3
        elseif f.step == 3 and el >= STAR_SECOND + STAR_TELL then
            call StarFire(f, 3)
            call Anim(f, AN_WINDUP, 1.0)
            call Decal(f, f.tx, f.ty, STAR_CORE_R, STAR_CORE_TELL, 0)
            set f.step = 4
        elseif f.step == 4 and el >= STAR_SECOND + STAR_TELL + STAR_CORE_TELL then
            call HitCircle(f, f.tx, f.ty, STAR_CORE_R, DMG_STAR_CORE, true, 0)
            call FxHitBig(f, f.tx, f.ty, 0, 1.2)
            call FxAt(FX_FLASH_RED, f.tx, f.ty, 3.0, 0)
            set f.step = 5
        elseif f.step == 5 and el >= STAR_SECOND + STAR_TELL + STAR_CORE_TELL + 0.3 then
            call PatternDone(f, RestBig())
        endif
    endfunction

    // ======================================================================
    // 패턴 선택
    // ======================================================================
    // (2페이즈 패턴은 아래 「2페이즈」 묶음, 선택은 그 뒤)

    // ======================================================================
    // 2페이즈 공용: 화면 필터, 안개 게이지, 홍색의 명계 원
    // ======================================================================
    // 참가자 화면에만: 0 끔, 1 붉은 달빛(엷게), 2 어둠, 3 붉은 빛 차오름(진하게)
    private function PlayerFilter takes RemiliaFight f, integer mode returns nothing
        local integer i = 0
        set f.filter = mode
        loop
            exitwhen i >= f.memN
            if f.mem[i] != null and GetLocalPlayer() == GetOwningPlayer(f.mem[i]) then
                if mode == 0 then
                    call DisplayCineFilter(false)
                else
                    call SetCineFilterTexture("ReplaceableTextures\\CameraMasks\\White_mask.blp")
                    call SetCineFilterBlendMode(BLEND_MODE_BLEND)
                    call SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
                    call SetCineFilterStartUV(0, 0, 1, 1)
                    call SetCineFilterEndUV(0, 0, 1, 1)
                    call SetCineFilterDuration(1.0)
                    if mode == 1 then
                        call SetCineFilterStartColor(255, 40, 40, 0)
                        call SetCineFilterEndColor(255, 30, 30, 45)
                    elseif mode == 2 then
                        call SetCineFilterStartColor(0, 0, 0, 60)
                        call SetCineFilterEndColor(10, 0, 0, 175)
                    else
                        call SetCineFilterStartColor(255, 30, 30, 45)
                        call SetCineFilterEndColor(255, 20, 20, 110)
                    endif
                    call DisplayCineFilter(true)
                endif
            endif
            set i = i + 1
        endloop
    endfunction

    // 안개 게이지: 체력바 바로 아래 붉은 막대 + 숫자. 처음 쓸 때 한 번 만든다 (모든 플레이어에게 같은 프레임)
    private function FogUiInit takes nothing returns nothing
        if FogBack != 0 then
            return
        endif
        set FogBack = DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetTexture(FogBack, "Textures\\Black32.blp", 0)
        call DzFrameSetSize(FogBack, FOG_UI_W / 1280.00, FOG_UI_H / 1280.00)
        call DzFrameSetPoint(FogBack, 0, DzGetGameUI(), 6, FOG_UI_X / 1280.00, FOG_UI_Y / 1280.00)
        set FogFill = DzCreateFrameByTagName("BACKDROP", "", FogBack, "template", FrameCount())
        call DzFrameSetTexture(FogFill, "ReplaceableTextures\\TeamColor\\TeamColor00.blp", 0)
        call DzFrameSetSize(FogFill, FOG_UI_W / 1280.00, FOG_UI_H / 1280.00)
        call DzFrameSetPoint(FogFill, 0, DzGetGameUI(), 6, FOG_UI_X / 1280.00, FOG_UI_Y / 1280.00)
        set FogText = DzCreateFrameByTagName("TEXT", "", FogBack, "template", FrameCount())
        call DzFrameSetFont(FogText, "Fonts\\DFHeiMd.ttf", 0.010, 0)
        call DzFrameSetSize(FogText, 200.0 / 1280.00, 20.0 / 1280.00)
        call DzFrameSetPoint(FogText, 0, DzGetGameUI(), 6, FOG_UI_X / 1280.00, (FOG_UI_Y - 12.0) / 1280.00)
        call DzFrameShow(FogBack, false)
    endfunction

    private function FogUiShow takes RemiliaFight f, boolean on returns nothing
        local integer i = 0
        call FogUiInit()
        loop
            exitwhen i >= f.memN
            if f.mem[i] != null and GetLocalPlayer() == GetOwningPlayer(f.mem[i]) then
                call DzFrameShow(FogBack, on)
            endif
            set i = i + 1
        endloop
    endfunction

    private function FogUiUpdate takes RemiliaFight f returns nothing
        local integer i = 0
        local real w = RMaxBJ(1, FOG_UI_W * f.fog / 100.0)
        loop
            exitwhen i >= f.memN
            if f.mem[i] != null and GetLocalPlayer() == GetOwningPlayer(f.mem[i]) then
                call DzFrameSetSize(FogFill, w / 1280.00, FOG_UI_H / 1280.00)
                call DzFrameSetText(FogText, "|cFFFF6060붉은 안개|r " + I2S(R2I(f.fog + 0.5)) + "   햇빛 " + I2S(FogSun(f)) + "줄")
            endif
            set i = i + 1
        endloop
    endfunction

    // 홍색의 명계: 각 영웅 주위에 붉은 원(반경 150) 6개. 발밑 하나 + 주변(350 안) 다섯. tell 초 뒤 터짐
    private function MeikaiWave takes RemiliaFight f, real tell returns nothing
        local integer i = 0
        local integer k
        local real x
        local real y
        loop
            exitwhen i >= f.memN
            if MemAlive(f.mem[i]) then
                set k = 0
                loop
                    exitwhen k >= MEIKAI_N or f.mkN >= 48
                    if k == 0 then
                        set x = GetUnitX(f.mem[i])
                        set y = GetUnitY(f.mem[i])
                    else
                        set x = ClampX(f, GetUnitX(f.mem[i]) + PolarX(GetRandomReal(160, 350), GetRandomReal(0, 360)))
                        set y = ClampY(f, GetUnitY(f.mem[i]) + PolarY(GetRandomReal(160, 350), GetRandomReal(0, 360)))
                    endif
                    set f.mkX[f.mkN] = x
                    set f.mkY[f.mkN] = y
                    set f.mkAt[f.mkN] = f.now + tell
                    set f.mkN = f.mkN + 1
                    call DecalFree(f, x, y, MEIKAI_R, tell)
                    set k = k + 1
                endloop
            endif
            set i = i + 1
        endloop
    endfunction

    // 패턴과 따로 돈다 (미저러블 페이트 중에도 떨어짐). 같은 틱에 터지는 원끼리는 한 사람 한 번
    private function MeikaiUpdate takes RemiliaFight f returns nothing
        local integer k = 0
        local boolean cleared = false
        loop
            exitwhen k >= f.mkN
            if f.now >= f.mkAt[k] then
                if not cleared then
                    if f.mkHit == 0 then
                        set f.mkHit = party.create()
                    endif
                    call GroupClear(f.mkHit.super)
                    set cleared = true
                endif
                call HitCircle(f, f.mkX[k], f.mkY[k], MEIKAI_R, DMG_MEIKAI, false, f.mkHit)
                call FxAt(FX_FLASH_RED, f.mkX[k], f.mkY[k], 1.5, 0)
                call FxAt(FX_BATS_HIT, f.mkX[k], f.mkY[k], 0.6, 0)
                // 마지막 것을 이 자리로 옮기고 다시 본다
                set f.mkN = f.mkN - 1
                set f.mkX[k] = f.mkX[f.mkN]
                set f.mkY[k] = f.mkY[f.mkN]
                set f.mkAt[k] = f.mkAt[f.mkN]
            else
                set k = k + 1
            endif
        endloop
    endfunction

    // ======================================================================
    // 2페이즈 짤패턴
    // ======================================================================
    // 하트브레이크 2연: 창 2개를 0.6초 간격으로, 각각 0.9초 예고
    private function RunHeart2 takes RemiliaFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local unit u
        if f.step == 0 then
            set u = SunTarget(f)
            if u != null then
                set f.target = u
            endif
            set u = null
            if MemAlive(f.target) then
                set f.ang = AngleWBW(f.boss, f.target)
                call Face(f, f.ang)
            endif
            set f.dashLen = RMinBJ(HEART_LEN, EdgeDist(f, bx, by, f.ang))
            set f.ax = f.ang
            call AnimThen(f, AN_SPEAR_SUMMON, 1.0, AN_SPEAR_HOLD)
            call FxWindup(f)
            call TeleLine(f, bx, by, f.ax, f.dashLen, HEART_W, HEART_TELL)
            set f.step = 1
        elseif f.step == 1 and el >= HEART2_GAP then
            // 두 번째 창: 대상을 다시 겨눈다
            if MemAlive(f.target) then
                set f.ay = AngleWBW(f.boss, f.target)
            else
                set f.ay = f.ax + 25
            endif
            set f.tx = RMinBJ(HEART_LEN, EdgeDist(f, bx, by, f.ay))
            call TeleLine(f, bx, by, f.ay, f.tx, HEART_W, HEART_TELL)
            set f.step = 2
        elseif f.step == 2 and el >= HEART_TELL - 0.15 then
            call Anim(f, AN_SPEAR_THROW, 1.0)
            call VoiceSlot(f, VO_HEART, false)
            set f.step = 3
        elseif f.step == 3 and el >= HEART_TELL then
            call ProjSpawn(f, 2, FX_SPEAR, bx + PolarX(40, f.ax), by + PolarY(40, f.ax), f.ax, HEART_SPEED, f.dashLen - 40, HEART_W * 0.5, DMG_HEART2, 1.2)
            call FxAt(FX_FLASH_RED, bx + PolarX(80, f.ax), by + PolarY(80, f.ax), 1.2, f.ax)
            call Face(f, f.ay)
            call AnimThen(f, AN_SPEAR_SUMMON, 1.0, AN_SPEAR_HOLD)
            set f.step = 4
        elseif f.step == 4 and el >= HEART2_GAP + HEART_TELL - 0.15 then
            call Anim(f, AN_SPEAR_THROW, 1.0)
            set f.step = 5
        elseif f.step == 5 and el >= HEART2_GAP + HEART_TELL then
            call ProjSpawn(f, 2, FX_SPEAR, bx + PolarX(40, f.ay), by + PolarY(40, f.ay), f.ay, HEART_SPEED, f.tx - 40, HEART_W * 0.5, DMG_HEART2, 1.2)
            call FxAt(FX_FLASH_RED, bx + PolarX(80, f.ay), by + PolarY(80, f.ay), 1.2, f.ay)
            set f.step = 6
        elseif f.step == 6 and el >= HEART2_GAP + HEART_TELL + 0.5 then
            call PatternDone(f, RestFill())
        endif
    endfunction

    // 배드 레이디 스크램블: 회전하며 대상을 관통해 700 돌진(폭 220, 예고 0.9초), 끝난 뒤 등을 보인 채 1.5초 멈춤.
    // 스스로 햇빛에 들어가지 않으므로 경로에 햇빛이 있으면 그 앞에서 멈춘다 (작열 없음)
    private function RunScramble takes RemiliaFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local real nx
        local real ny
        local real step
        local real hit
        if f.step == 0 then
            set f.dashLen = RMinBJ(SCRAMBLE_LEN, EdgeDist(f, bx, by, f.ang) - 150)
            set hit = PathBeam(f, bx, by, f.ang, f.dashLen)
            if hit >= 0 then
                set f.dashLen = RMaxBJ(0, hit - 10)
            endif
            call AnimThen(f, AN_WINDUP, 1.0, AN_WINDUP_HOLD)
            call TeleLine(f, bx, by, f.ang, f.dashLen + SCRAMBLE_W * 0.5, SCRAMBLE_W, SCRAMBLE_TELL)
            call FxWindup(f)
            set f.step = 1
        elseif f.step == 1 and el >= SCRAMBLE_TELL then
            set f.dashLeft = f.dashLen
            set f.nextFx = 0
            call AnimThen(f, AN_FLY_START, 1.0, AN_FLY_LOOP)
            call VoiceSlot(f, VO_NIGHTMARE, false)
            call FxAt(FX_BURST, bx, by, 1.0, f.ang)
            set f.step = 2
        elseif f.step == 2 then
            set step = RMinBJ(f.dashLeft, CRADLE_SPEED * TICK)
            set nx = ClampX(f, bx + PolarX(step, f.ang))
            set ny = ClampY(f, by + PolarY(step, f.ang))
            if step > 0 then
                call SetUnitPosition(f.boss, nx, ny)
            endif
            call HitSweep(f, bx, by, nx, ny, SCRAMBLE_W * 0.5, DMG_SCRAMBLE, true, f.hit, CRADLE_KNOCK)
            set f.dashLeft = f.dashLeft - step
            if f.now >= f.nextFx then
                set f.nextFx = f.now + 0.08
                call FxAt(FX_SPIN, nx, ny, 1.0, f.ang)
            endif
            if f.dashLeft <= 0 or (nx == bx and ny == by) then
                // 등을 보인 채 멈춘다 (돌아서지 않음)
                call Anim(f, AN_FLY_LAND, 1.0)
                set f.holdUntil = f.now + SCRAMBLE_STAY
                set f.patStart = f.now
                set f.step = 3
            endif
        elseif f.step == 3 and el >= SCRAMBLE_STAY then
            call PatternDone(f, RestFill())
        endif
    endfunction

    // 홍색의 명계: 각 영웅 주위 원 6개, 2파, 예고 1.0초
    private function RunMeikai takes RemiliaFight f, real el returns nothing
        if f.step == 0 then
            call Anim(f, AN_CAST, 1.0)
            call FxWindup(f)
            call MeikaiWave(f, MEIKAI_TELL)
            set f.step = 1
        elseif f.step == 1 and el >= MEIKAI_TELL then
            call Anim(f, AN_CAST, 1.0)
            call MeikaiWave(f, MEIKAI_TELL)
            set f.step = 2
        elseif f.step == 2 and el >= MEIKAI_TELL * 2 + 0.3 then
            call PatternDone(f, RestFill())
        endif
    endfunction

    // 박쥐 떼: 레밀리아에게서 대상 쪽으로 직선(폭 200) 돌진, 예고 1.0초. 본체는 제자리
    private function RunSwarm takes RemiliaFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        if f.step == 0 then
            set f.dashLen = RMinBJ(SWARM_LEN, EdgeDist(f, bx, by, f.ang))
            call Anim(f, AN_WINDUP, 1.0)
            call TeleLine(f, bx, by, f.ang, f.dashLen, SWARM_W, SWARM_TELL)
            set f.step = 1
        elseif f.step == 1 and el >= SWARM_TELL then
            call Anim(f, AN_CAST, 1.0)
            call VoiceSlot(f, VO_BAT, false)
            call ProjSpawn(f, 4, FX_BATS, bx, by, f.ang, 1800, f.dashLen, SWARM_W * 0.5, DMG_SWARM, 1.6)
            call ProjSpawn(f, 3, FX_BATS, bx + PolarX(60, f.ang + 90), by + PolarY(60, f.ang + 90), f.ang, 1800, f.dashLen, 0, 0, 1.0)
            call ProjSpawn(f, 3, FX_BATS, bx + PolarX(60, f.ang - 90), by + PolarY(60, f.ang - 90), f.ang, 1800, f.dashLen, 0, 0, 1.0)
            set f.step = 2
        elseif f.step == 2 and el >= SWARM_TELL + 0.8 then
            call PatternDone(f, RestFill())
        endif
    endfunction

    // ======================================================================
    // 2페이즈 대형 패턴
    // ======================================================================
    // 스피어 더 궁니르: 2.0초 모음(폭 260 선 예고, 던지기 0.8초 전 고정), 마지막 1.0초 카운터.
    // 카운터하면 창이 부서지고 그로기 4.5초·안개 -15. 아니면 던진 창이 끝에 꽂혀 1초 뒤 반경 300 폭발
    private function RunGungnir takes RemiliaFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local real len
        if f.step == 0 then
            call AnimThen(f, AN_SPEAR_SUMMON, 1.0, AN_SPEAR_HOLD)
            call VoiceSlot(f, VO_GUNGNIR, false)
            call FxWindup(f)
            call DestroyEffect(AddSpecialEffectTarget(FX_GATHER, f.boss, "hand right"))
            set f.cTeleW = GUNGNIR_W
            set f.step = 1
        elseif f.step == 1 or f.step == 2 then
            set len = EdgeDist(f, bx, by, f.ang)
            if el < GUNGNIR_CHARGE - GUNGNIR_LOCK then
                if MemAlive(f.target) then
                    call TurnToward(f, AngleWBW(f.boss, f.target), 360 * TICK)
                    set f.ang = f.face
                endif
            endif
            call CradleTele(f, len)
            if f.step == 1 and el >= GUNGNIR_CHARGE - GUNGNIR_COUNTER then
                // 카운터 구간 (마지막 1.0초): 아쳐와 같은 신호·판정
                call UnitAddAbility(f.boss, 'A00V')
                call SetUnitVertexColorBJ(f.boss, 70, 70, 100, 0)
                set f.cue[0] = UnitEffectTimeEX('e00F', bx, by, 0, 3)
                set f.cue[1] = UnitEffectTimeEX('e00G', bx, by, 0, 3)
                set f.cue[2] = UnitEffectTimeEX('e01S', bx, by, 0, 3)
                call DestroyEffect(AddSpecialEffectTarget(FX_COUNTER_READY, f.boss, "origin"))
                set f.step = 2
            elseif f.step == 2 and GetUnitAbilityLevel(f.boss, 'A00V') == 0 then
                // 카운터 성공: 창이 부서진다
                call CradleTeleClear(f)
                call ClearDecals(f)
                call CueClear(f)
                call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
                call Sound3D(f.boss, 'A00U')
                call FxAt(FX_SPARKS, bx + PolarX(80, f.ang), by + PolarY(80, f.ang), 1.5, f.ang)
                call FxAt(FX_FLASH_WHITE, bx + PolarX(80, f.ang), by + PolarY(80, f.ang), 4.0, f.ang)
                call VoiceSlot(f, VO_COUNTERHIT, true)
                call AnimDown(f)
                call FogAdd(f, -FOG_COUNTER)
                call MsgAll(f, "|cFFFFD040창이 부서졌다! 붉은 안개가 걷힌다|r", 2.5)
                set f.patStart = f.now
                set f.step = 6
            elseif f.step == 2 and el >= GUNGNIR_CHARGE - 0.15 then
                call UnitRemoveAbility(f.boss, 'A00V')
                call CueClear(f)
                call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
                call Anim(f, AN_SPEAR_THROW, 1.0)
                set f.step = 3
            endif
        elseif f.step == 3 and el >= GUNGNIR_CHARGE then
            set len = EdgeDist(f, bx, by, f.ang) - 60
            call CradleTeleClear(f)
            set f.tx = bx + PolarX(len, f.ang)
            set f.ty = by + PolarY(len, f.ang)
            set f.dashLen = len / HEART_SPEED
            set f.ax = ProjSpawn(f, 2, FX_SPEAR, bx + PolarX(40, f.ang), by + PolarY(40, f.ang), f.ang, HEART_SPEED, len - 40, GUNGNIR_W * 0.5, DMG_GUNGNIR, 2.4)
            if f.ax >= 0 then
                set f.pstun[R2I(f.ax)] = true
            endif
            call FxAt(FX_FLASH_RED, bx + PolarX(80, f.ang), by + PolarY(80, f.ang), 2.0, f.ang)
            call FxAt(FX_BURST, bx + PolarX(80, f.ang), by + PolarY(80, f.ang), 1.2, f.ang)
            call CameraShaker.setShake(5)
            set f.step = 4
        elseif f.step == 4 and el >= GUNGNIR_CHARGE + f.dashLen then
            // 끝에 꽂힘 → 1초 뒤 반경 300 폭발
            call FxKeep(f, FX_SPEAR, f.tx, f.ty, 2.0, f.ang, 1.0)
            call Decal(f, f.tx, f.ty, GUNGNIR_BOOM_R, 1.0, 0)
            set f.step = 5
        elseif f.step == 5 and el >= GUNGNIR_CHARGE + f.dashLen + 1.0 then
            call HitCircle(f, f.tx, f.ty, GUNGNIR_BOOM_R, DMG_GUNGNIR_BOOM, true, 0)
            call FxHitBig(f, f.tx, f.ty, f.ang, 1.3)
            call PatternDone(f, RestBig())
        elseif f.step == 6 and el >= GUNGNIR_GROGGY then
            call PatternDone(f, RestBig())
        endif
    endfunction

    // 미저러블 페이트: 각 영웅에게서 300 떨어진 곳에 말뚝 + 붉은 사슬(400). 6초 동안 홍색의 명계 2번.
    // 말뚝은 아무 공격 3타에 부서진다. 다 부수면 기절 3초·안개 -15, 못 부수면 말뚝으로 끌려가 반경 250 폭발
    private function StakeClear takes RemiliaFight f, integer i returns nothing
        if f.chain[i] != null then
            call DestroyLightning(f.chain[i])
            set f.chain[i] = null
        endif
        if f.stakeFx[i] != null then
            call DestroyEffect(f.stakeFx[i])
            set f.stakeFx[i] = null
        endif
        if f.stake[i] != null then
            call ShowUnit(f.stake[i], false)
            call KillUnit(f.stake[i])
            call RemoveUnit(f.stake[i])
            set f.stake[i] = null
        endif
    endfunction

    private function StakesClear takes RemiliaFight f returns nothing
        local integer i = 0
        loop
            exitwhen i >= 6
            call StakeClear(f, i)
            set i = i + 1
        endloop
    endfunction

    // 말뚝이 맞은 횟수 (체력이 줄어든 틱마다 1타), 사슬 길이 제한, 사슬 그리기
    private function StakesUpdate takes RemiliaFight f returns integer
        local integer i = 0
        local integer left = 0
        local integer idx
        local real d
        local real a
        local unit u
        loop
            exitwhen i >= f.memN
            set u = f.mem[i]
            if f.stake[i] != null then
                set idx = IndexUnit(f.stake[i])
                if UnitHP[idx] < f.stakeHP[i] - 0.5 then
                    set f.stakeHits[i] = f.stakeHits[i] + 1
                    call FxAt(FX_SPARKS, GetUnitX(f.stake[i]), GetUnitY(f.stake[i]), 0.7, 0)
                endif
                set UnitHP[idx] = 1000000
                set f.stakeHP[i] = 1000000
                if f.stakeHits[i] >= MISERY_HITS then
                    call FxAt(FX_FLASH_WHITE, GetUnitX(f.stake[i]), GetUnitY(f.stake[i]), 3.0, 0)
                    call FxAt(FX_SPARKS, GetUnitX(f.stake[i]), GetUnitY(f.stake[i]), 1.4, 0)
                    call StakeClear(f, i)
                elseif MemAlive(u) then
                    set left = left + 1
                    set d = DistancePBP(GetUnitX(f.stake[i]), GetUnitY(f.stake[i]), GetUnitX(u), GetUnitY(u))
                    if d > MISERY_CHAIN then
                        // 사슬 끝으로 끌어당긴다 (영웅 이동이라 SetUnitX/Y)
                        set a = AnglePBP(GetUnitX(f.stake[i]), GetUnitY(f.stake[i]), GetUnitX(u), GetUnitY(u))
                        call SetUnitX(u, GetUnitX(f.stake[i]) + PolarX(MISERY_CHAIN, a))
                        call SetUnitY(u, GetUnitY(f.stake[i]) + PolarY(MISERY_CHAIN, a))
                    endif
                    if f.chain[i] != null then
                        call MoveLightningEx(f.chain[i], true, GetUnitX(f.stake[i]), GetUnitY(f.stake[i]), 60, GetUnitX(u), GetUnitY(u), 60)
                    endif
                else
                    call StakeClear(f, i)
                endif
            endif
            set i = i + 1
        endloop
        set u = null
        return left
    endfunction

    private function RunMisery takes RemiliaFight f, real el returns nothing
        local integer i = 0
        local integer idx
        local real a
        local real x
        local real y
        local integer left
        if f.step == 0 then
            call Anim(f, AN_BIG_CAST, 1.0)
            call FxWindup(f)
            loop
                exitwhen i >= f.memN
                set f.stake[i] = null
                set f.stakeFx[i] = null
                set f.chain[i] = null
                set f.stakeHits[i] = 0
                if MemAlive(f.mem[i]) then
                    set a = GetRandomReal(0, 360)
                    set x = ClampX(f, GetUnitX(f.mem[i]) + PolarX(MISERY_DIST, a))
                    set y = ClampY(f, GetUnitY(f.mem[i]) + PolarY(MISERY_DIST, a))
                    // 맞힐 수 있는 보이지 않는 유닛 + 붉은 창 모양 말뚝 이펙트
                    set f.stake[i] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), REMILIA_UNIT_ID, x, y, 270)
                    call UnitRemoveAbility(f.stake[i], 'Amov')
                    call SetUnitPathing(f.stake[i], false)
                    call PauseUnit(f.stake[i], true)
                    call SetUnitVertexColor(f.stake[i], 255, 255, 255, 0)
                    call SetUnitScale(f.stake[i], 0.4, 0.4, 0.4)
                    set idx = IndexUnit(f.stake[i])
                    set UnitHPMAX[idx] = 1000000
                    set UnitHP[idx] = 1000000
                    set UnitHPFloorOn[idx] = false
                    set UnitDamageLock[idx] = false
                    set f.stakeHP[i] = 1000000
                    set f.stakeFx[i] = AddSpecialEffect(FX_STAKE, x, y)
                    call EXSetEffectSize(f.stakeFx[i], 1.6)
                    call EXEffectMatRotateY(f.stakeFx[i], -90)
                    call EXSetEffectZ(f.stakeFx[i], 60)
                    set f.chain[i] = AddLightningEx(LZ_CHAIN, true, x, y, 60, GetUnitX(f.mem[i]), GetUnitY(f.mem[i]), 60)
                    call FxAt(FX_FLASH_RED, x, y, 2.0, 0)
                endif
                set i = i + 1
            endloop
            call MsgAll(f, "|cFFFF9628말뚝을 3번 때려 부수세요!|r", 3.0)
            set f.step = 1
        elseif f.step >= 1 and f.step <= 3 then
            set left = StakesUpdate(f)
            if f.step == 1 and el >= 1.0 then
                call MeikaiWave(f, MEIKAI_TELL)
                set f.step = 2
            elseif f.step == 2 and el >= 3.5 then
                call MeikaiWave(f, MEIKAI_TELL)
                set f.step = 3
            endif
            if left == 0 and el >= 0.5 then
                // 모두 부숨: 운명 역류
                call StakesClear(f)
                call MsgAll(f, "|cFFFFD040운명 역류! 붉은 안개가 걷힌다|r", 2.5)
                call FogAdd(f, -FOG_BIG)
                call VoiceSlot(f, VO_COUNTERHIT, true)
                call AnimDown(f)
                set f.patStart = f.now
                set f.step = 5
            elseif el >= MISERY_TIME then
                // 못 부순 말뚝으로 끌려가 폭발
                loop
                    exitwhen i >= f.memN
                    if f.stake[i] != null then
                        set x = GetUnitX(f.stake[i])
                        set y = GetUnitY(f.stake[i])
                        if MemAlive(f.mem[i]) then
                            call SetUnitX(f.mem[i], x)
                            call SetUnitY(f.mem[i], y)
                        endif
                        call HitCircle(f, x, y, MISERY_BOOM_R, DMG_MISERY_BOOM, true, 0)
                        call FxHitBig(f, x, y, 0, 1.0)
                        call StakeClear(f, i)
                    endif
                    set i = i + 1
                endloop
                set f.patStart = f.now
                set f.step = 4
            endif
        elseif f.step == 4 and el >= 0.8 then
            call PatternDone(f, RestBig())
        elseif f.step == 5 and el >= MISERY_STUN then
            call PatternDone(f, RestBig())
        endif
    endfunction

    // ======================================================================
    // 2페이즈 기믹
    // ======================================================================
    // 기믹이 끝났을 때: 진행 표시를 끝으로 바꾸고, 체력 하한을 다음 기믹 줄로 내린다
    private function GimmickEnd takes RemiliaFight f, integer id, real rest returns nothing
        local integer idx = IndexUnit(f.boss)
        if id == PAT_FATE then
            set f.g75 = 2
        elseif id == PAT_NIGHT then
            set f.g50 = 2
        elseif id == PAT_GENSO then
            set f.g25 = 2
        endif
        if f.g75 != 2 then
            set UnitHPFloor[idx] = UnitHPMAX[idx] * 0.75
        elseif f.g50 != 2 then
            set UnitHPFloor[idx] = UnitHPMAX[idx] * 0.50
        elseif f.g25 != 2 then
            set UnitHPFloor[idx] = UnitHPMAX[idx] * 0.25
        else
            set UnitHPFloorOn[idx] = false
        endif
        call PatternDone(f, rest)
    endfunction

    // 운명 예지 공격 하나 정하기: 0 십자 기둥, 1 영웅 발밑 원, 2 직선, 3 전장 절반
    private function FatePick takes RemiliaFight f, integer k returns nothing
        local integer kind = ModuloInteger(k + GetRandomInt(0, 3), 4)
        local unit u = PickTarget(f)
        local integer i = GetRandomInt(0, IMaxBJ(0, f.memN - 1))
        if MemAlive(f.mem[i]) then
            set u = f.mem[i]
        endif
        set f.fK[k] = kind
        set f.fX[k] = f.arenaCX()
        set f.fY[k] = f.arenaCY()
        set f.fA[k] = GetRandomInt(0, 1) * 45.0
        if u != null then
            set f.fX[k] = GetUnitX(u)
            set f.fY[k] = GetUnitY(u)
            if kind == 2 then
                set f.fA[k] = AnglePBP(GetUnitX(f.boss), GetUnitY(f.boss), GetUnitX(u), GetUnitY(u))
            endif
        endif
        if kind == 3 then
            // 0 왼쪽 절반, 1 오른쪽 절반
            set f.fA[k] = GetRandomInt(0, 1)
        endif
        set u = null
    endfunction

    // 운명 예지 공격 하나를 그린다 (dim 이면 흐린 미리 보기 FATE_SHOW 초, 아니면 0.6초 번쩍)
    private function FateDraw takes RemiliaFight f, integer k, boolean dim returns nothing
        local rect r = MapRectReturn(f.rect)
        local real t = FATE_FLASH
        local integer ty = 0
        local integer i
        local real x
        local real y
        local real len = 3000
        if dim then
            set t = FATE_SHOW
            set ty = 4
        endif
        if f.fK[k] == 0 then
            // 십자: 지점을 지나는 두 직선
            call DecalSeg(f, f.fX[k] - PolarX(len * 0.5, f.fA[k]), f.fY[k] - PolarY(len * 0.5, f.fA[k]), f.fA[k], 0, len, FATE_CROSS_W, t, ty)
            call DecalSeg(f, f.fX[k] - PolarX(len * 0.5, f.fA[k] + 90), f.fY[k] - PolarY(len * 0.5, f.fA[k] + 90), f.fA[k] + 90, 0, len, FATE_CROSS_W, t, ty)
        elseif f.fK[k] == 1 then
            // 모든 영웅의 발밑: 미리 보기는 지금 자리, 번쩍일 때는 그 순간의 자리를 기억해 그곳이 터진다
            set i = 0
            if not dim then
                set f.fcN = 0
            endif
            loop
                exitwhen i >= f.memN
                if MemAlive(f.mem[i]) then
                    call Decal(f, GetUnitX(f.mem[i]), GetUnitY(f.mem[i]), FATE_CIRCLE_R, t, ty)
                    if not dim and f.fcN < 6 then
                        set f.fcX[f.fcN] = GetUnitX(f.mem[i])
                        set f.fcY[f.fcN] = GetUnitY(f.mem[i])
                        set f.fcN = f.fcN + 1
                    endif
                endif
                set i = i + 1
            endloop
        elseif f.fK[k] == 2 then
            call DecalSeg(f, GetUnitX(f.boss), GetUnitY(f.boss), f.fA[k], 0, len * 0.5, FATE_LINE_W, t, ty)
        else
            // 전장 절반: 큰 원 여러 개로 덮는다
            set y = GetRectMinY(r) + 250
            loop
                exitwhen y > GetRectMaxY(r)
                if f.fA[k] < 0.5 then
                    set x = GetRectMinX(r) + 250
                else
                    set x = f.arenaCX() + 250
                endif
                loop
                    exitwhen (f.fA[k] < 0.5 and x > f.arenaCX()) or (f.fA[k] >= 0.5 and x > GetRectMaxX(r))
                    call Decal(f, x, y, 300, t, ty)
                    set x = x + 450
                endloop
                set y = y + 450
            endloop
        endif
        set r = null
    endfunction

    // 운명 예지 공격 하나가 터진다. 맞은 영웅: 최대 체력 25% + 안개 +5, 맞은 횟수 +1
    private function FateFire takes RemiliaFight f, integer k returns nothing
        local integer i = 0
        local integer j
        local unit u
        local boolean hit
        local real ux
        local real uy
        local real c
        local real s
        loop
            exitwhen i >= f.memN
            set u = f.mem[i]
            if MemAlive(u) then
                set ux = GetUnitX(u)
                set uy = GetUnitY(u)
                set hit = false
                if f.fK[k] == 0 then
                    set c = Cos(f.fA[k] * bj_DEGTORAD)
                    set s = Sin(f.fA[k] * bj_DEGTORAD)
                    set hit = RAbsBJ(-(ux - f.fX[k]) * s + (uy - f.fY[k]) * c) <= FATE_CROSS_W * 0.5 or RAbsBJ((ux - f.fX[k]) * c + (uy - f.fY[k]) * s) <= FATE_CROSS_W * 0.5
                elseif f.fK[k] == 1 then
                    set j = 0
                    loop
                        exitwhen j >= f.fcN or hit
                        set hit = IsUnitInRangeXY(u, f.fcX[j], f.fcY[j], FATE_CIRCLE_R)
                        set j = j + 1
                    endloop
                elseif f.fK[k] == 2 then
                    set hit = SegDist(ux, uy, GetUnitX(f.boss), GetUnitY(f.boss), GetUnitX(f.boss) + PolarX(3000, f.fA[k]), GetUnitY(f.boss) + PolarY(3000, f.fA[k])) <= FATE_LINE_W * 0.5
                else
                    set hit = (f.fA[k] < 0.5 and ux <= f.arenaCX()) or (f.fA[k] >= 0.5 and ux >= f.arenaCX())
                endif
                if hit then
                    call DealPct(f, u, FATE_DMG, false)
                    call FogAdd(f, FOG_FATE_HIT)
                    set f.memHits[i] = f.memHits[i] + 1
                    call FxHitSmall(ux, uy, 0)
                endif
            endif
            set i = i + 1
        endloop
        set u = null
        if f.fTag[k] != null then
            call DestroyTextTag(f.fTag[k])
            set f.fTag[k] = null
        endif
        if f.fK[k] == 1 then
            set j = 0
            loop
                exitwhen j >= f.fcN
                call FxAt(FX_FLASH_RED, f.fcX[j], f.fcY[j], 2.0, 0)
                set j = j + 1
            endloop
        else
            call FxAt(FX_FLASH_RED, f.fX[k], f.fY[k], 3.0, f.fA[k])
        endif
        call CameraShaker.setShake(3)
    endfunction

    private function FateTagsClear takes RemiliaFight f returns nothing
        local integer k = 0
        loop
            exitwhen k >= 8
            if f.fTag[k] != null then
                call DestroyTextTag(f.fTag[k])
                set f.fTag[k] = null
            endif
            set k = k + 1
        endloop
    endfunction

    // 한 라운드 시작: n 개 공격을 정하고 3초 동안 흐린 예고 + 큰 번호
    private function FateRound takes RemiliaFight f, integer n returns nothing
        local integer k = 0
        set f.fN = n
        set f.fDone = 0
        set f.fFlash = 0
        set f.fcN = 0
        set f.fRoundAt = f.now
        loop
            exitwhen k >= n
            call FatePick(f, k)
            call FateDraw(f, k, true)
            set f.fTag[k] = CreateTextTag()
            call SetTextTagText(f.fTag[k], I2S(k + 1), 0.06)
            call SetTextTagColor(f.fTag[k], 255, 70, 70, 255)
            call SetTextTagPos(f.fTag[k], f.fX[k] - 20, f.fY[k], 120)
            call SetTextTagPermanent(f.fTag[k], true)
            call SetTextTagVisibility(f.fTag[k], true)
            set k = k + 1
        endloop
    endfunction

    // 75% 운명 예지 (약 15초): 5개 → 4개. 모든 영웅이 2번 미만으로 맞으면 그로기 6초·안개 -25
    private function RunFate takes RemiliaFight f, real el returns nothing
        local integer i = 0
        local real t
        local boolean ok
        if f.step == 0 then
            // 중앙으로 박쥐처럼 옮겨 가서 멈춰 선다
            call FxAt(FX_BATS_HIT, GetUnitX(f.boss), GetUnitY(f.boss), 1.5, 0)
            call SetUnitPosition(f.boss, f.arenaCX(), f.arenaCY())
            call FxAt(FX_BATS_HIT, f.arenaCX(), f.arenaCY(), 1.5, 0)
            call AnimThen(f, AN_BIG_CAST, 1.0, AN_WINDUP_HOLD)
            call VoiceSlot(f, VO_FATE, true)
            loop
                exitwhen i >= 6
                set f.memHits[i] = 0
                set i = i + 1
            endloop
            set f.fRound = 1
            call FateRound(f, 5)
            set f.step = 1
        elseif f.step == 1 then
            // 0.6초 전 번쩍 → 1.2초 간격으로 순서대로 터짐
            set t = f.now - f.fRoundAt - FATE_SHOW
            if f.fFlash < f.fN and f.fFlash == f.fDone and t >= FATE_GAP * f.fFlash then
                call FateDraw(f, f.fFlash, false)
                set f.fFlash = f.fFlash + 1
            endif
            if f.fDone < f.fFlash and t >= FATE_GAP * f.fDone + FATE_FLASH then
                call FateFire(f, f.fDone)
                set f.fDone = f.fDone + 1
            endif
            if f.fDone >= f.fN and t >= FATE_GAP * f.fN then
                if f.fRound == 1 then
                    set f.fRound = 2
                    call Anim(f, AN_CAST, 1.0)
                    call FateRound(f, 4)
                else
                    set f.step = 2
                endif
            endif
        elseif f.step == 2 then
            set ok = true
            loop
                exitwhen i >= f.memN
                if MemAlive(f.mem[i]) and f.memHits[i] >= 2 then
                    set ok = false
                endif
                set i = i + 1
            endloop
            call FateTagsClear(f)
            set f.patStart = f.now
            if ok then
                call MsgAll(f, "|cFFFFD040운명을 거슬렀다! 붉은 안개가 걷힌다|r", 3.0)
                call FogAdd(f, -FOG_GIMMICK)
                call VoiceSlot(f, VO_COUNTERHIT, true)
                call AnimDown(f)
                set f.step = 3
            else
                call MsgAll(f, "|cFFFF4040운명대로 되었다|r", 2.5)
                call GimmickEnd(f, PAT_FATE, RestBig())
            endif
        elseif f.step == 3 and el >= GIMMICK_GROGGY then
            call GimmickEnd(f, PAT_FATE, RestBig())
        endif
    endfunction

    // 50% 퀸 오브 미드나잇 (어둠, 약 15초): 붉은 두 눈만 보이고 5번 달려든다. 매 돌진: 눈이 번쩍 + 붉은 선 1.0초 예고
    // (마지막 0.6초 카운터), 돌진 뒤 1.5초 모습을 드러냄. 카운터·작열 합쳐 3번이면 그로기 6초·안개 -25.
    // 실패: 안개 +20, 앞쪽 반원(반경 800, 예고 2초) 최대 체력 70%
    private function NightShow takes RemiliaFight f, boolean on returns nothing
        if on then
            call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
        else
            call SetUnitVertexColor(f.boss, 255, 255, 255, 25)
        endif
    endfunction

    private function NightEnd takes RemiliaFight f returns nothing
        call PlayerFilter(f, 1)
        call NightShow(f, true)
        call CueClear(f)
        call BurnClear(f)
        call UnitRemoveAbility(f.boss, 'A00V')
    endfunction

    private function RunNight takes RemiliaFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local real t
        local real nx
        local real ny
        local real step
        local real hit
        if f.step == 0 then
            call VoiceSlot(f, VO_QUEEN, true)
            call PlayerFilter(f, 2)
            call NightShow(f, false)
            set f.nDash = 0
            set f.nGood = 0
            set f.nAt = f.now + 1.5
            set f.step = 1
        elseif f.step == 1 and f.now >= f.nAt then
            // 돌진 하나 시작: 대상을 정하고 눈이 번쩍, 붉은 선 예고
            set f.target = PickTarget(f)
            if MemAlive(f.target) then
                set f.ang = AngleWBW(f.boss, f.target)
            endif
            call Face(f, f.ang)
            set f.dashLen = RMinBJ(CRADLE_LEN, EdgeDist(f, bx, by, f.ang) - 150)
            if MemAlive(f.target) then
                set f.dashLen = RMinBJ(f.dashLen, DistancePBP(bx, by, GetUnitX(f.target), GetUnitY(f.target)) + 250)
            endif
            set hit = PathBeam(f, bx, by, f.ang, f.dashLen)
            set f.burn = hit >= 0
            if f.burn then
                set f.dashLen = RMaxBJ(0, hit)
                call DecalSeg(f, bx, by, f.ang, hit, RMaxBJ(hit + 1, f.tx), CRADLE_W, NIGHT_TELL + 0.4, 2)
            endif
            set f.eyeFx = AddSpecialEffectTarget(FX_EYES, f.boss, "head")
            call AnimThen(f, AN_WINDUP, 1.0, AN_WINDUP_HOLD)
            call TeleLine(f, bx, by, f.ang, f.dashLen + 100, CRADLE_W, NIGHT_TELL)
            set f.nAt = f.now
            set f.step = 2
        elseif f.step == 2 then
            set t = f.now - f.nAt
            if t >= NIGHT_TELL - NIGHT_COUNTER and GetUnitAbilityLevel(f.boss, 'A00V') == 0 and f.cue[0] == null then
                call UnitAddAbility(f.boss, 'A00V')
                set f.cue[0] = UnitEffectTimeEX('e00F', bx, by, 0, 3)
                set f.cue[1] = UnitEffectTimeEX('e00G', bx, by, 0, 3)
                set f.cue[2] = UnitEffectTimeEX('e01S', bx, by, 0, 3)
            elseif f.cue[0] != null and GetUnitAbilityLevel(f.boss, 'A00V') == 0 then
                // 카운터 성공: 이번 돌진은 취소, 1.5초 모습을 드러냄
                call ClearDecals(f)
                call CueClear(f)
                call NightShow(f, true)
                call Sound3D(f.boss, 'A00U')
                call FxAt(FX_FLASH_WHITE, bx, by, 4.0, 0)
                set f.nGood = f.nGood + 1
                call MsgAll(f, "|cFFFFD040카운터! (" + I2S(f.nGood) + "/" + I2S(NIGHT_NEED) + ")|r", 1.5)
                set f.nAt = f.now
                set f.step = 4
            elseif t >= NIGHT_TELL then
                call UnitRemoveAbility(f.boss, 'A00V')
                call CueClear(f)
                call NightShow(f, true)
                call GroupClear(f.hit.super)
                set f.dashLeft = f.dashLen
                call AnimThen(f, AN_FLY_START, 1.5, AN_FLY_LOOP)
                set f.step = 3
            endif
        elseif f.step == 3 then
            set step = RMinBJ(f.dashLeft, CRADLE_SPEED * TICK)
            set nx = ClampX(f, bx + PolarX(step, f.ang))
            set ny = ClampY(f, by + PolarY(step, f.ang))
            if step > 0 then
                call SetUnitPosition(f.boss, nx, ny)
            endif
            call HitSweep(f, bx, by, nx, ny, CRADLE_W * 0.5, DMG_NIGHT_DASH, true, f.hit, CRADLE_KNOCK)
            set f.dashLeft = f.dashLeft - step
            if f.dashLeft <= 0 or (nx == bx and ny == by) then
                call Anim(f, AN_FLY_LAND, 1.0)
                if f.burn then
                    set f.nGood = f.nGood + 1
                    call FxAt(FX_BURN_HIT, nx, ny, 1.0, 0)
                    call DestroyEffect(AddSpecialEffectTarget(FX_BURN, f.boss, "chest"))
                    call MsgAll(f, "|cFFFFD040햇빛에 닿았다! (" + I2S(f.nGood) + "/" + I2S(NIGHT_NEED) + ")|r", 1.5)
                endif
                set f.nAt = f.now
                set f.step = 4
            endif
        elseif f.step == 4 and f.now >= f.nAt + NIGHT_SHOW then
            if f.eyeFx != null then
                call DestroyEffect(f.eyeFx)
                set f.eyeFx = null
            endif
            set f.nDash = f.nDash + 1
            if f.nGood >= NIGHT_NEED then
                // 성공: 어둠이 걷힌다
                call NightEnd(f)
                call MsgAll(f, "|cFFFFD040어둠이 걷혔다! 붉은 안개가 걷힌다|r", 3.0)
                call FogAdd(f, -FOG_GIMMICK)
                call VoiceSlot(f, VO_COUNTERHIT, true)
                call AnimDown(f)
                set f.patStart = f.now
                set f.step = 7
            elseif f.nDash >= NIGHT_DASHES then
                // 실패: 안개 +20, 앞쪽 반원 일격
                call NightEnd(f)
                call FogAdd(f, FOG_NIGHT_FAIL)
                if MemAlive(f.target) then
                    set f.ang = AngleWBW(f.boss, f.target)
                endif
                call Face(f, f.ang)
                call AnimThen(f, AN_WINDUP, 1.0, AN_WINDUP_HOLD)
                call TeleFan(f, GetUnitX(f.boss), GetUnitY(f.boss), f.ang, NIGHT_FINAL_R, 90, NIGHT_FINAL_TELL)
                call MsgAll(f, "|cFFFF4040어둠 속 일격이 온다! 뒤로 돌아가세요|r", 2.0)
                set f.patStart = f.now
                set f.step = 5
            else
                call NightShow(f, false)
                // 돌진 사이 3초 이상 (예고 1.0 + 돌진 + 1.5 보임 + 여유)
                set f.nAt = f.now + RMaxBJ(0.3, NIGHT_CYCLE - NIGHT_TELL - NIGHT_SHOW)
                set f.step = 1
            endif
        elseif f.step == 5 and el >= NIGHT_FINAL_TELL then
            call Anim(f, AN_ATTACK, 2.0)
            call HitFanPct(f, GetUnitX(f.boss), GetUnitY(f.boss), f.ang, NIGHT_FINAL_R, 90, NIGHT_FINAL_DMG)
            call FxClaw(GetUnitX(f.boss), GetUnitY(f.boss), f.ang - 40, 0, NIGHT_FINAL_R)
            call FxClaw(GetUnitX(f.boss), GetUnitY(f.boss), f.ang + 40, 0, NIGHT_FINAL_R)
            call FxHitBig(f, GetUnitX(f.boss) + PolarX(300, f.ang), GetUnitY(f.boss) + PolarY(300, f.ang), f.ang, 1.5)
            set f.patStart = f.now
            set f.step = 6
        elseif f.step == 6 and el >= 1.0 then
            call GimmickEnd(f, PAT_NIGHT, RestBig())
        elseif f.step == 7 and el >= GIMMICK_GROGGY then
            call GimmickEnd(f, PAT_NIGHT, RestBig())
        endif
    endfunction

    // 25% 홍색의 환상향 (전멸기, 약 14초): 붉은 달 아래로 올라가 무적 10초 시전. 붉은 빛이 가장자리에서 3단계로 차오르고
    // (단계마다 링 예고), 마지막에는 햇빛 안을 빼고 전부. 햇빛은 안개 농도로: 10 이하 3줄, 40 이하 2줄, 70 이하 1줄,
    // 그 위는 폭 120 좁은 빛줄 1줄. 시전 중 스칼렛 슛. 버티면 떨어져 그로기 6초, 안개 50
    private function GensoRadius takes RemiliaFight f returns real
        local rect r = MapRectReturn(f.rect)
        local real d = SquareRoot((GetRectMaxX(r) - GetRectMinX(r)) * (GetRectMaxX(r) - GetRectMinX(r)) + (GetRectMaxY(r) - GetRectMinY(r)) * (GetRectMaxY(r) - GetRectMinY(r))) * 0.5
        set r = null
        return d
    endfunction

    // 반지름 rad 의 원 둘레에 붉은 링 예고
    private function GensoRing takes RemiliaFight f, real rad returns nothing
        local integer k = 0
        local integer n = R2I(rad * 6.283 / 220) + 1
        loop
            exitwhen k >= n
            call Decal(f, ClampX(f, f.arenaCX() + PolarX(rad, 360.0 * k / n)), ClampY(f, f.arenaCY() + PolarY(rad, 360.0 * k / n)), 130, GENSO_RING_TELL, 0)
            set k = k + 1
        endloop
    endfunction

    private function GensoSun takes RemiliaFight f returns nothing
        local integer k = 0
        local integer want = FogSun(f)
        local integer i = 0
        // 지금 있는 빛을 걷고 새로 놓는다
        loop
            exitwhen k >= SB_MAX
            call StripFade(f, k)
            set k = k + 1
        endloop
        if want == 0 then
            set want = 1
        endif
        set k = 0
        loop
            exitwhen k >= SB_MAX or i >= want
            if f.sbState[k] == 0 then
                if FogSun(f) == 0 then
                    call StripSpawnW(f, k, -1, GENSO_NARROW_W)
                else
                    call StripSpawn(f, k, -1)
                endif
                set i = i + 1
            endif
            set k = k + 1
        endloop
        // 사라지는 칸이 다 차 있으면 나머지는 사라진 뒤 채운다
        if i < want then
            set f.gStage = -want + i
        endif
    endfunction

    private function RunGenso takes RemiliaFight f, real el returns nothing
        local real full = GensoRadius(f)
        local integer i = 0
        local unit u
        if f.step == 0 then
            call FxAt(FX_BATS_HIT, GetUnitX(f.boss), GetUnitY(f.boss), 1.5, 0)
            call SetUnitPosition(f.boss, f.arenaCX(), f.arenaCY())
            set f.invuln = true
            call UpdateLock(f)
            call AnimThen(f, AN_LEAP, 1.0, AN_HOVER)
            call VoiceSlot(f, VO_GENSOKYO, true)
            call PlayerFilter(f, 3)
            set f.gStage = 0
            call GensoSun(f)
            set f.gCover = full + 1000
            set f.gTickAt = f.now + 0.5
            set f.gShootAt = f.now + 1.5
            call GensoRing(f, full * 0.66)
            call MsgAll(f, "|cFFFF4040붉은 빛이 차오른다! 마지막엔 햇빛 안만 안전합니다|r", 4.0)
            set f.step = 1
        elseif f.step >= 1 and f.step <= 4 then
            // 단계: 2.5초 0.66, 5.0초 0.33, 7.5초 전부. 링 예고는 1.5초 앞
            if f.step == 1 and el >= 2.5 then
                set f.gCover = full * 0.66
                call GensoRing(f, full * 0.33)
                set f.step = 2
            elseif f.step == 2 and el >= 5.0 then
                set f.gCover = full * 0.33
                call GensoRing(f, 150)
                set f.step = 3
            elseif f.step == 3 and el >= 7.5 then
                set f.gCover = 0
                call FxAt(FX_FLASH_RED, f.arenaCX(), f.arenaCY(), 8.0, 0)
                set f.step = 4
            endif
            // 덮인 곳(중심에서 gCover 밖)에 있고 햇빛 밖이면 0.5초마다 최대 체력 10%
            if f.now >= f.gTickAt then
                set f.gTickAt = f.now + 0.5
                set i = 0
                loop
                    exitwhen i >= f.memN
                    set u = f.mem[i]
                    if MemAlive(u) and not IsUnitInRangeXY(u, f.arenaCX(), f.arenaCY(), f.gCover) and InAnyStrip(f, GetUnitX(u), GetUnitY(u), 0) < 0 then
                        call DealPct(f, u, GENSO_TICK_DMG, false)
                        call DestroyEffect(AddSpecialEffectTarget(FX_BURN_HIT, u, "origin"))
                    endif
                    set i = i + 1
                endloop
                set u = null
            endif
            // 시전 중에도 스칼렛 슛
            if f.now >= f.gShootAt and el < GENSO_CAST - 0.5 then
                set f.gShootAt = f.now + 1.6
                set u = PickTarget(f)
                if u != null then
                    set f.ang = AngleWBW(f.boss, u)
                    call ShootWave(f, GetRandomReal(-SHOOT_GAP * 0.5, SHOOT_GAP * 0.5), true)
                endif
                set u = null
            endif
            // 칸이 비어 미뤄 둔 빛줄 채우기
            if f.gStage < 0 then
                set i = 0
                loop
                    exitwhen i >= SB_MAX or f.gStage >= 0
                    if f.sbState[i] == 0 then
                        if FogSun(f) == 0 then
                            call StripSpawnW(f, i, -1, GENSO_NARROW_W)
                        else
                            call StripSpawn(f, i, -1)
                        endif
                        set f.gStage = f.gStage + 1
                    endif
                    set i = i + 1
                endloop
            endif
            if el >= GENSO_CAST then
                // 마지막: 햇빛 밖은 모두
                set i = 0
                loop
                    exitwhen i >= f.memN
                    set u = f.mem[i]
                    if MemAlive(u) and InAnyStrip(f, GetUnitX(u), GetUnitY(u), 0) < 0 then
                        call DealPct(f, u, 2.0, true)
                    endif
                    set i = i + 1
                endloop
                set u = null
                call FxHitBig(f, f.arenaCX(), f.arenaCY(), 0, 2.5)
                // 버텼다: 지쳐 떨어진다
                set f.invuln = false
                call UpdateLock(f)
                call PlayerFilter(f, 1)
                call Anim(f, AN_PLUNGE, 1.0)
                set f.fog = FOG_AFTER_GENSO
                call MsgAll(f, "|cFFFFD040버텼다! 레밀리아가 지쳐 떨어진다|r", 3.0)
                set f.patStart = f.now
                set f.step = 5
            endif
        elseif f.step == 5 and el >= AnimDur[AN_PLUNGE] then
            call AnimDown(f)
            set f.step = 6
        elseif f.step == 6 and el >= GIMMICK_GROGGY then
            // 띠 수는 틱에서 안개 50 에 맞춘다 (좁은 빛줄도 그때 정리)
            call GimmickEnd(f, PAT_GENSO, RestBig())
        endif
    endfunction

    // ======================================================================
    // 패턴 선택
    // ======================================================================
    private function Ready takes RemiliaFight f, integer id returns boolean
        return f.now >= f.readyAt[id]
    endfunction

    private function FillWeight takes RemiliaFight f, integer id, real d returns integer
        if not Ready(f, id) then
            return 0
        endif
        if id == PAT_CLAW then
            if d > 450 then
                return 0
            endif
            return PatWeight[id]
        elseif id == PAT_SHOOT and d < 200 then
            return PatWeight[id] / 2
        endif
        return PatWeight[id]
    endfunction

    // 2페이즈 가중치: 미저러블 페이트는 체력 87.5% 아래부터, 드라큘라 크레이들은 햇빛이 하나라도 있을 때만
    private function Weight2 takes RemiliaFight f, integer id, real d returns integer
        local integer idx = IndexUnit(f.boss)
        if id == PAT_MISERY and UnitHP[idx] > UnitHPMAX[idx] * MISERY_UNLOCK then
            return 0
        elseif id == PAT_DRACULA and SunCount(f) < 1 then
            return 0
        elseif id == PAT_SCRAMBLE and d > 900 then
            return PatWeight[id] / 3
        endif
        return PatWeight[id]
    endfunction

    // from~to 범위의 패턴 중 하나 (직전 last 제외, 쿨다운 반영. 쓸 것이 없으면 쿨다운 무시)
    private function Pick2 takes RemiliaFight f, integer from, integer to, integer last, real d returns integer
        local integer i = from
        local integer total = 0
        local integer roll
        local integer pass = 0
        loop
            exitwhen pass >= 3
            set total = 0
            set i = from
            loop
                exitwhen i > to
                if (pass >= 2 or i != last) and (pass >= 1 or Ready(f, i)) then
                    set total = total + Weight2(f, i, d)
                endif
                set i = i + 1
            endloop
            if total > 0 then
                set roll = GetRandomInt(1, total)
                set i = from
                loop
                    exitwhen i > to
                    if (pass >= 2 or i != last) and (pass >= 1 or Ready(f, i)) then
                        set roll = roll - Weight2(f, i, d)
                        if roll <= 0 and Weight2(f, i, d) > 0 then
                            return i
                        endif
                    endif
                    set i = i + 1
                endloop
            endif
            set pass = pass + 1
        endloop
        return from
    endfunction

    private function SelectPattern2 takes RemiliaFight f returns nothing
        local unit u = PickTarget(f)
        local real d
        if u == null then
            return
        endif
        set d = DistancePBP(GetUnitX(f.boss), GetUnitY(f.boss), GetUnitX(u), GetUnitY(u))
        set u = null
        if InAnyStrip(f, GetUnitX(f.boss), GetUnitY(f.boss), BOSS_R) >= 0 then
            call StartPattern(f, PAT_BAT)
            return
        endif
        if f.flapWant and Ready(f, PAT_FLAP) then
            call StartPattern(f, PAT_FLAP)
            return
        endif
        if f.fillN >= f.bigEvery then
            if d > 900 and f.now >= f.batAt then
                call StartPattern(f, PAT_BAT)
                return
            endif
            call StartPattern(f, Pick2(f, PAT_GUNGNIR, PAT_DRACULA, f.lastBig, d))
            return
        endif
        if d > BAT_GAP and f.now >= f.batAt then
            call StartPattern(f, PAT_BAT)
            return
        endif
        call StartPattern(f, Pick2(f, PAT_HEART2, PAT_SWARM, f.lastFill, d))
    endfunction

    private function SelectPattern takes RemiliaFight f returns nothing
        local unit u
        local real d
        local integer i
        local integer total
        local integer roll
        local integer last
        local integer w
        if f.pat != 0 then
            return
        endif
        if f.state == REMILIA_PHASE2 then
            call SelectPattern2(f)
            return
        endif
        if f.state != REMILIA_PHASE1 then
            return
        endif
        set u = PickTarget(f)
        if u == null then
            return
        endif
        set d = DistancePBP(GetUnitX(f.boss), GetUnitY(f.boss), GetUnitX(u), GetUnitY(u))
        set u = null
        // 햇빛 안에 서 있으면 먼저 박쥐로 빠져나간다
        if InAnyStrip(f, GetUnitX(f.boss), GetUnitY(f.boss), BOSS_R) >= 0 then
            call StartPattern(f, PAT_BAT)
            return
        endif
        // 등 뒤에 오래 있는 영웅
        if f.flapWant and Ready(f, PAT_FLAP) then
            call StartPattern(f, PAT_FLAP)
            return
        endif
        // 큰 패턴 차례 (기본 패턴 2~3번에 한 번)
        if f.fillN >= f.bigEvery then
            if d > 900 and f.now >= f.batAt then
                call StartPattern(f, PAT_BAT)
                return
            endif
            set total = 0
            set i = PAT_CRADLE
            loop
                exitwhen i > PAT_STAR
                if i != f.lastBig and Ready(f, i) then
                    set total = total + PatWeight[i]
                endif
                set i = i + 1
            endloop
            set last = f.lastBig
            if total == 0 then
                // 모두 대기 중이면 직전 것만 빼고 쿨다운 무시
                set i = PAT_CRADLE
                loop
                    exitwhen i > PAT_STAR
                    if i != last then
                        set f.readyAt[i] = 0
                        set total = total + PatWeight[i]
                    endif
                    set i = i + 1
                endloop
            endif
            set roll = GetRandomInt(1, total)
            set i = PAT_CRADLE
            loop
                exitwhen i > PAT_STAR
                if i != last and Ready(f, i) then
                    set roll = roll - PatWeight[i]
                    if roll <= 0 then
                        call StartPattern(f, i)
                        return
                    endif
                endif
                set i = i + 1
            endloop
            call StartPattern(f, PAT_STAR)
            return
        endif
        // 멀면 박쥐로 다가간다
        if d > BAT_GAP and f.now >= f.batAt then
            call StartPattern(f, PAT_BAT)
            return
        endif
        // 기본 패턴 (직전 패턴 제외, 거리 반영 가중치)
        set last = f.lastFill
        set total = 0
        set i = PAT_CLAW
        loop
            exitwhen i > PAT_SHOOT
            if i != last then
                set total = total + FillWeight(f, i, d)
            endif
            set i = i + 1
        endloop
        if total == 0 then
            set last = 0
            set i = PAT_CLAW
            loop
                exitwhen i > PAT_SHOOT
                set total = total + FillWeight(f, i, d)
                set i = i + 1
            endloop
        endif
        if total == 0 then
            // 붙어서 쓸 것도 없고 멀리 쓸 것도 대기 중: 하트 브레이크를 바로 쓴다
            call StartPattern(f, PAT_HEART)
            return
        endif
        set roll = GetRandomInt(1, total)
        set i = PAT_CLAW
        loop
            exitwhen i > PAT_SHOOT
            if i != last then
                set w = FillWeight(f, i, d)
                if w > 0 then
                    set roll = roll - w
                    if roll <= 0 then
                        call StartPattern(f, i)
                        return
                    endif
                endif
            endif
            set i = i + 1
        endloop
    endfunction

    private function RunPattern takes RemiliaFight f returns nothing
        local real el = f.now - f.patStart
        if f.pat == PAT_CLAW then
            call RunClaw(f, el)
        elseif f.pat == PAT_HEART then
            call RunHeart(f, el)
        elseif f.pat == PAT_SHOOT then
            call RunShoot(f, el)
        elseif f.pat == PAT_FLAP then
            call RunFlap(f, el)
        elseif f.pat == PAT_CRADLE then
            call RunCradle(f, el)
        elseif f.pat == PAT_QUEEN then
            call RunQueen(f, el)
        elseif f.pat == PAT_STAR then
            call RunStar(f, el)
        elseif f.pat == PAT_BAT then
            call RunBat(f, el)
        elseif f.pat == PAT_HEART2 then
            call RunHeart2(f, el)
        elseif f.pat == PAT_SCRAMBLE then
            call RunScramble(f, el)
        elseif f.pat == PAT_MEIKAI then
            call RunMeikai(f, el)
        elseif f.pat == PAT_SWARM then
            call RunSwarm(f, el)
        elseif f.pat == PAT_GUNGNIR then
            call RunGungnir(f, el)
        elseif f.pat == PAT_MISERY then
            call RunMisery(f, el)
        elseif f.pat == PAT_DRACULA then
            call RunCradle(f, el)
        elseif f.pat == PAT_FATE then
            call RunFate(f, el)
        elseif f.pat == PAT_NIGHT then
            call RunNight(f, el)
        elseif f.pat == PAT_GENSO then
            call RunGenso(f, el)
        endif
    endfunction

    // 진행 중인 모든 공격과 2페이즈 장치 정리 (기믹이 끼어들 때, 끝날 때)
    private function CancelAll takes RemiliaFight f returns nothing
        call CancelAttacks(f)
        call StakesClear(f)
        call FateTagsClear(f)
        set f.mkN = 0
        if f.invuln then
            set f.invuln = false
            call UpdateLock(f)
        endif
        if f.filter == 2 or f.filter == 3 then
            call PlayerFilter(f, 1)
        endif
    endfunction

    // ======================================================================
    // 체력 구간 (체력바 10줄 = 한 줄 10%)
    // ======================================================================
    // 1페이즈 70%·40% 기믹 자리 (이번 작업에서는 넣지 않음. 블라드 체페슈의 저주·불야성 레드는 나중에)
    private function GimmickHook takes RemiliaFight f, integer pct returns nothing
    endfunction

    // 10% 전환「붉은 안개 이변」: 무적 약 8초. 날개를 펼치고 대사 → 붉은 안개가 퍼지며 빛줄이 하나씩 꺼짐
    // → 붉은 달빛 필터 → 완전 회복, 안개 게이지(100) → 2페이즈 첫 패턴 스피어 더 궁니르
    private function StartTransition takes RemiliaFight f returns nothing
        call CancelAll(f)
        set f.state = REMILIA_TRANSITION
        set f.transStart = f.now
        set f.transStep = 0
        call UpdateLock(f)
        call FxAt(FX_BATS_HIT, GetUnitX(f.boss), GetUnitY(f.boss), 1.5, 0)
        call SetUnitPosition(f.boss, f.arenaCX(), f.arenaCY())
        call Face(f, 270)
        call AnimThen(f, AN_BIG_CAST, 1.0, AN_WINDUP_HOLD)
        call VoiceSlot(f, VO_TRANSITION, true)
        call ShowName(f, "붉은 안개 이변", 2)
        call MsgAll(f, "|cFFFF4040붉은 안개 이변|r", 4.0)
    endfunction

    private function UpdateTransition takes RemiliaFight f returns nothing
        local real el = f.now - f.transStart
        local integer idx = IndexUnit(f.boss)
        local integer k
        if f.transStep <= 2 and el >= 1.5 + f.transStep then
            // 안개가 퍼지고 빛줄이 하나씩 꺼진다
            call FxAt(FX_FOG, f.arenaCX() + GetRandomReal(-500, 500), f.arenaCY() + GetRandomReal(-500, 500), 1.5, 0)
            call FxAt(FX_FOG, f.arenaCX() + GetRandomReal(-500, 500), f.arenaCY() + GetRandomReal(-500, 500), 1.5, 0)
            set k = 0
            loop
                exitwhen k >= SB_MAX
                if f.sbState[k] == 1 or f.sbState[k] == 2 then
                    call StripFade(f, k)
                    set k = SB_MAX
                endif
                set k = k + 1
            endloop
            set f.transStep = f.transStep + 1
        elseif f.transStep == 3 and el >= 4.5 then
            // 하늘이 붉어지고 붉은 보름달 (화면 전체에 엷은 붉은 필터)
            call PlayerFilter(f, 1)
            call FxAt(FX_FLASH_RED, f.arenaCX(), f.arenaCY(), 10.0, 0)
            call CameraShaker.setShake(6)
            call MsgAll(f, "|cFFFF6060붉은 보름달이 떴다|r", 3.0)
            set f.transStep = 4
        elseif f.transStep == 4 and el >= 6.0 then
            // 완전 회복, 안개 농도 게이지
            set UnitHP[idx] = UnitHPMAX[idx]
            set f.fog = 100
            set f.fogAt = f.now + FOG_TIME_EVERY
            call FogUiShow(f, true)
            call FogUiUpdate(f)
            call DestroyEffect(AddSpecialEffectTarget(FX_GATHER, f.boss, "chest"))
            set f.transStep = 5
        elseif f.transStep == 5 and el >= TRANS_TIME then
            // 2페이즈 시작: 기믹 줄(75%)에서 체력이 멈춘다
            set f.state = REMILIA_PHASE2
            call UpdateLock(f)
            set UnitHPFloorOn[idx] = true
            set UnitHPFloor[idx] = UnitHPMAX[idx] * 0.75
            set f.fillN = 0
            set f.bigEvery = GetRandomInt(2, 3)
            set f.lastFill = 0
            set f.lastBig = 0
            set k = 0
            loop
                exitwhen k >= 20
                set f.readyAt[k] = 0
                set k = k + 1
            endloop
            call VoiceSlot(f, VO_PHASE2, true)
            // 첫 패턴은 스피어 더 궁니르 고정
            call StartPattern(f, PAT_GUNGNIR)
            set f.transStep = 6
        endif
    endfunction

    // 2페이즈 체력 줄: 75% 운명 예지, 50% 퀸 오브 미드나잇, 25% 홍색의 환상향(무엇을 하던 끼어든다), 10% 마지막 발악
    private function HpEvents2 takes RemiliaFight f returns nothing
        local integer idx = IndexUnit(f.boss)
        local real pct = UnitHP[idx] / UnitHPMAX[idx]
        if not IsGimmick(f.pat) then
            if f.g75 == 0 and pct <= 0.7505 then
                set f.g75 = 1
                call CancelAll(f)
                call StartPattern(f, PAT_FATE)
            elseif f.g75 == 2 and f.g50 == 0 and pct <= 0.5005 then
                set f.g50 = 1
                call CancelAll(f)
                call StartPattern(f, PAT_NIGHT)
            elseif f.g50 == 2 and f.g25 == 0 and pct <= 0.2505 then
                set f.g25 = 1
                call CancelAll(f)
                call StartPattern(f, PAT_GENSO)
            endif
        endif
        if not f.lastStruggle and f.g25 == 2 and pct <= LAST_STRUGGLE then
            set f.lastStruggle = true
            set f.bigEvery = 1
            call VoiceSlot(f, VO_SCARLETDEVIL, true)
            call MsgAll(f, "|cFFFF4040마지막 발악! 대형 패턴이 더 자주 온다|r", 3.0)
        endif
    endfunction

    private function HpEvents takes RemiliaFight f returns nothing
        local integer idx = IndexUnit(f.boss)
        local real pct = UnitHP[idx] / UnitHPMAX[idx]
        if f.state == REMILIA_PHASE2 then
            call HpEvents2(f)
            return
        endif
        if not f.third and pct <= SB_THIRD_HP then
            set f.third = true
            call SunRefill(f)
            call MsgAll(f, "|cFFFFE060햇빛이 한 줄기 더 들어온다|r", 2.5)
        endif
        if not f.g70 and pct <= 0.70 then
            set f.g70 = true
            call GimmickHook(f, 70)
        endif
        if not f.g40 and pct <= 0.40 then
            set f.g40 = true
            call GimmickHook(f, 40)
        endif
        if pct <= PHASE1_FLOOR + 0.0005 then
            call StartTransition(f)
        endif
    endfunction

    // ======================================================================
    // 종료
    // ======================================================================
    private function FinCancel takes RemiliaFight f returns nothing
        call CancelAll(f)
        set FinOk = true
    endfunction
    private function FinView takes RemiliaFight f returns nothing
        call FogUiShow(f, false)
        call PlayerFilter(f, 0)
        set FinOk = true
    endfunction
    private function FinSun takes RemiliaFight f returns nothing
        call SunClear(f)
        set FinOk = true
    endfunction
    private function FinFx takes RemiliaFight f returns nothing
        call FxUpdate(f, true)
        call TeleUpdate(f, true)
        call LzUpdate(f, true)
        call CameraShaker.stopShake()
        if f.patTag != null then
            call DestroyTextTag(f.patTag)
            set f.patTag = null
        endif
        set FinOk = true
    endfunction
    private function FinAggro takes RemiliaFight f returns nothing
        call BossAggroDestroy(f.boss)
        set FinOk = true
    endfunction

    private function FinCheck takes string step returns nothing
        if not FinOk then
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "|cFFFF4040[레밀리아] 종료 정리 중 멈춘 단계:|r " + step)
        endif
        set FinOk = false
    endfunction

    private function Finish takes RemiliaFight f, boolean win returns nothing
        local integer i = 0
        local integer idx = IndexUnit(f.boss)
        set f.state = REMILIA_ENDED
        set UnitHPFloorOn[idx] = false
        set UnitDamageLock[idx] = false
        set UnitCounterArc[idx] = 0
        if win then
            set UnitHP[idx] = 0
            call SetUnitTimeScale(f.boss, 1.0)
            call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
            call SetUnitAnimationByIndex(f.boss, AN_DEATH)
            call FxAt(FX_FLASH_WHITE, GetUnitX(f.boss), GetUnitY(f.boss), 8.0, 0)
            call FxAt(FX_BATS_HIT, GetUnitX(f.boss), GetUnitY(f.boss), 2.0, 0)
            call CameraShaker.setShake(8)
            call KillUnit(f.boss)
            call MsgAll(f, "|cFFFFD040레밀리아 스칼렛 격파!|r", 5.0)
            call VoiceSlot(f, VO_DEFEAT, true)
        else
            call VoiceSlot(f, VO_WIPE, true)
        endif
        loop
            exitwhen i >= f.memN
            if f.mem[i] != null then
                if win then
                    call SuccessStart(f.mem[i])
                else
                    call FailedStart(f.mem[i])
                endif
                call OverlayStop(GetPlayerId(GetOwningPlayer(f.mem[i])))
            endif
            set i = i + 1
        endloop
        set i = 0
        set FinOk = false
        call FinCancel.evaluate(f)
        call FinCheck("공격 취소")
        call FinSun.evaluate(f)
        call FinCheck("햇빛 띠 제거")
        call FinFx.evaluate(f)
        call FinCheck("효과·예고 제거")
        call FinView.evaluate(f)
        call FinCheck("안개 게이지·화면 필터")
        call FinAggro.evaluate(f)
        call FinCheck("어그로")
        if win then
            call BossMapReset(f.rect, ARENA_THEMA)
        else
            call KillUnit(f.boss)
            call RemoveUnit(f.boss)
            call MapReset(f.rect, ARENA_THEMA)
        endif
        set RemiliaFightAt[f.rect] = 0
        call f.t.destroy()
        if f.hit != 0 then
            call f.hit.destroy()
            set f.hit = 0
        endif
        if f.mkHit != 0 then
            call f.mkHit.destroy()
            set f.mkHit = 0
        endif
        call DestroyGroup(f.decals)
        set f.decals = null
        call f.ul.destroy()
        loop
            exitwhen i >= 6
            set f.mem[i] = null
            set i = i + 1
        endloop
        set f.boss = null
        set f.target = null
        call f.destroy()
    endfunction

    // ======================================================================
    // 패턴 사이: 대상을 향해 돌기만 한다 (걷지 않음. 이동은 박쥐 흩어짐)
    // ======================================================================
    private function IdleMove takes RemiliaFight f returns nothing
        local unit u
        if (f.state != REMILIA_PHASE1 and f.state != REMILIA_PHASE2) or f.now < f.holdUntil then
            return
        endif
        set u = PickTarget(f)
        if u != null then
            call TurnToward(f, AngleWBW(f.boss, u), IDLE_TURN * TICK)
        endif
        set u = null
    endfunction

    // 등 뒤(정면에서 120도 밖, 450 안)에 있는 시간을 잰다. 2초가 넘으면 날갯짓 예약
    private function BehindUpdate takes RemiliaFight f returns nothing
        local integer i = 0
        local unit u
        loop
            exitwhen i >= f.memN
            set u = f.mem[i]
            if MemAlive(u) and not f.hidden and IsUnitInRangeXY(u, GetUnitX(f.boss), GetUnitY(f.boss), FLAP_BEHIND_DIST) and AngDiff(AngleWBW(f.boss, u), f.face) > FLAP_BEHIND_ARC then
                set f.behindT[i] = f.behindT[i] + TICK
                if f.behindT[i] >= FLAP_BEHIND then
                    set f.flapWant = true
                endif
            else
                set f.behindT[i] = 0
            endif
            set i = i + 1
        endloop
        set u = null
    endfunction

    // ======================================================================
    // 전투 틱
    // ======================================================================
    private function BattleTick takes nothing returns nothing
        local tick t = tick.getExpired()
        local RemiliaFight f = t.data
        local integer idx
        if f.state == REMILIA_ENDED then
            return
        endif
        set f.now = f.now + TICK
        set idx = IndexUnit(f.boss)
        if AliveCount(f) == 0 then
            call Finish(f, false)
            return
        endif
        call FxUpdate(f, false)
        call TeleUpdate(f, false)
        call LzUpdate(f, false)
        call PatNameFollow(f)
        call SunUpdate(f)
        if f.state == REMILIA_PHASE_END then
            if f.now >= f.endAt then
                call Finish(f, true)
            endif
            return
        endif
        // 2페이즈 정상 처치
        if f.state == REMILIA_PHASE2 and UnitHP[idx] <= 0 then
            call Finish(f, true)
            return
        endif
        // 1페이즈·전환 하한 (피해 경로에서 이미 처리. 한 번 더 보정)
        if (f.state == REMILIA_PHASE1 or f.state == REMILIA_TRANSITION) and UnitHP[idx] < UnitHPMAX[idx] * PHASE1_FLOOR then
            set UnitHP[idx] = UnitHPMAX[idx] * PHASE1_FLOOR
        endif
        if f.animEnd > 0 and f.now >= f.animEnd then
            set f.animEnd = 0
            if f.animNext >= 0 then
                call Anim(f, f.animNext, 1.0)
            else
                call AnimIdle(f)
            endif
        endif
        if f.downFreeze > 0 and f.now >= f.downFreeze then
            set f.downFreeze = 0
            call SetUnitTimeScale(f.boss, 0)
        endif
        if f.state == REMILIA_TRANSITION then
            call UpdateTransition(f)
            call HoldFacing(f)
            return
        endif
        call HpEvents(f)
        if f.state != REMILIA_PHASE1 and f.state != REMILIA_PHASE2 then
            return
        endif
        call ProjUpdate(f)
        call BehindUpdate(f)
        if f.state == REMILIA_PHASE2 then
            call MeikaiUpdate(f)
            // 시간이 지나면 안개가 조금씩 다시 찬다 (기믹 중에는 멈춤)
            if f.now >= f.fogAt then
                set f.fogAt = f.now + FOG_TIME_EVERY
                if not IsGimmick(f.pat) then
                    call FogAdd(f, 1)
                endif
            endif
            // 0.5초마다: 햇빛 줄 수를 안개에 맞추고 게이지 갱신 (홍색의 환상향은 빛을 스스로 정한다)
            if ModuloInteger(R2I(f.now / TICK + 0.5), 25) == 0 then
                if f.pat != PAT_GENSO then
                    call SunRefill(f)
                endif
                call FogUiUpdate(f)
            endif
        endif
        if f.pat != 0 then
            call RunPattern(f)
        else
            if f.now >= f.nextSelect then
                call SelectPattern(f)
            endif
            if f.pat == 0 then
                call IdleMove(f)
            endif
        endif
        call HoldFacing(f)
    endfunction

    // ======================================================================
    // 입장
    // ======================================================================
    private function NoRemove takes nothing returns nothing
        local integer pid = GetPlayerId(GetOwningPlayer(GetEnumUnit()))
        local RemiliaFight f = CheckFight
        call ResetPlayerPotionCharges(pid)
        if GetLocalPlayer() == GetOwningPlayer(GetEnumUnit()) then
            call PlayersBossBarShow(GetLocalPlayer(), true)
            call DzFrameShow(BossTip, false)
        endif
        call BOSSHPSTART(f.boss, pid)
        call Overlay(pid)
        if f.memN < 6 then
            set f.mem[f.memN] = GetEnumUnit()
            set f.behindT[f.memN] = 0
            set f.memN = f.memN + 1
        endif
    endfunction

    private function StartBattle takes RemiliaFight f returns nothing
        local integer idx
        local integer n
        local real hpRate
        set f.boss = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), REMILIA_UNIT_ID, f.arenaCX(), f.arenaCY(), 270)
        call BossAggroInitialize(f.boss, f.ul.super)
        set idx = IndexUnit(f.boss)
        set Unitstate[idx] = 0
        call UnitRemoveAbility(f.boss, 'Amov')
        call SetUnitPathing(f.boss, false)
        call PauseUnit(f.boss, true)
        call SetUnitPosition(f.boss, f.arenaCX(), f.arenaCY())
        set f.face = 0
        call Face(f, 270)
        set UnitCounterArc[idx] = COUNTER_ARC
        set n = CountUnitsInGroup(f.ul.super)
        if n < 1 then
            set n = 1
        endif
        set hpRate = 1.0 + PARTY_HP_BONUS * (n - 1)
        set UnitHPMAX[idx] = UnitSetHP[REMILIA_DATA_INDEX] * hpRate
        set UnitHP[idx] = UnitHPMAX[idx]
        // 1페이즈: 체력 10% 아래로 내려가지 않음
        set UnitHPFloorOn[idx] = true
        set UnitHPFloor[idx] = UnitHPMAX[idx] * PHASE1_FLOOR
        set UnitDamageLock[idx] = false

        // 구조체 배열은 재사용 때 초기화되지 않으므로 직접 비운다
        set n = 0
        loop
            exitwhen n >= MAXP
            set f.pk[n] = 0
            set f.pe[n] = null
            set f.phit[n] = 0
            set n = n + 1
        endloop
        set n = 0
        loop
            exitwhen n >= 20
            set f.readyAt[n] = 0
            set n = n + 1
        endloop
        set n = 0
        loop
            exitwhen n >= 24
            set f.tele[n] = null
            set n = n + 1
        endloop
        set n = 0
        loop
            exitwhen n >= 32
            set f.fxe[n] = null
            set f.sbU[n] = null
            set n = n + 1
        endloop
        set n = 0
        loop
            exitwhen n >= 6
            set f.lz[n] = null
            set f.behindT[n] = 0
            set n = n + 1
        endloop
        set n = 0
        loop
            exitwhen n >= SB_MAX
            set f.sbState[n] = 0
            set f.sbW[n] = SB_HALF_W
            set n = n + 1
        endloop
        set n = 0
        loop
            exitwhen n >= 6
            set f.stake[n] = null
            set f.stakeFx[n] = null
            set f.chain[n] = null
            set f.stakeHP[n] = 0
            set f.stakeHits[n] = 0
            set f.memHits[n] = 0
            set n = n + 1
        endloop
        set n = 0
        loop
            exitwhen n >= 8
            set f.fTag[n] = null
            set n = n + 1
        endloop
        set f.fN = 0
        set f.fcN = 0
        set f.mkN = 0
        set f.mkHit = 0
        set f.fog = 100
        set f.fogAt = 0
        set f.g75 = 0
        set f.g50 = 0
        set f.g25 = 0
        set f.lastStruggle = false
        set f.invuln = false
        set f.filter = 0
        set f.transStep = 0
        set f.cTeleW = CRADLE_W
        set f.slam = false
        set f.cue[0] = null
        set f.cue[1] = null
        set f.cue[2] = null
        set f.cTele = null
        set f.cTeleAng = -1
        set f.burnFx = null
        set f.eyeFx = null
        set f.patTag = null
        set f.hidden = false
        set f.third = false
        set f.g70 = false
        set f.g40 = false
        set f.flapWant = false
        set f.fillN = 0
        set f.bigEvery = GetRandomInt(2, 3)
        set f.lastFill = 0
        set f.lastBig = 0
        set f.batAt = 0
        set f.holdUntil = 0
        set f.downFreeze = 0
        set f.animNext = -1
        set f.burn = false
        set f.pat = 0
        set f.step = 0

        set f.memN = 0
        set CheckFight = f
        call ForGroup(f.ul.super, function NoRemove)
        set CheckFight = 0

        set f.decals = CreateGroup()
        set f.state = REMILIA_PHASE1
        set f.now = 0
        set f.nextSelect = 3.0
        call Anim(f, AN_READY, 1.0)
        // 햇빛 2줄로 시작. 첫 이동은 20초 뒤
        call StripSpawn(f, 0, -1)
        call StripSpawn(f, 1, -1)
        set f.sbNext = 0
        set f.sbMoveAt = SB_MOVE_EVERY
        call MsgAll(f, "|cFFFFE060햇빛이 드는 곳에서는 레밀리아가 힘을 쓰지 못한다|r", 4.0)
        set f.voiceUntil = 0
        set f.gruntAt = 0
        call VoiceSlot(f, VO_START, true)

        set MapRectCheck[f.rect] = false
        set f.t = tick.create(f)
        call f.t.start(TICK, true, function BattleTick)
    endfunction

    private function EntranceTick takes nothing returns nothing
        local tick t = tick.getExpired()
        local RemiliaFight f = t.data
        if splash.range(splash.ALLY, f.entrance, GetWidgetX(f.entrance), GetWidgetY(f.entrance), 500, function SplashNothing) == 0 then
            call KillUnit(f.entrance)
            set f.entrance = null
            call t.destroy()
            call StartBattle(f)
        endif
    endfunction

    // 처음 쓰는 모델은 불러오는 순간 멈칫하므로 땅 아래에서 아주 작게 한 번 그려 둔다
    private function PreloadOne takes string model, real x, real y returns nothing
        local effect e = AddSpecialEffect(model, x, y)
        call EXSetEffectSize(e, 0.01)
        call EXSetEffectZ(e, -3000)
        call DestroyEffect(e)
        set e = null
    endfunction

    private function PreloadUnitsEnd takes nothing returns nothing
        call RemoveUnit(PreUnitA)
        call RemoveUnit(PreUnitB)
        set PreUnitA = null
        set PreUnitB = null
    endfunction

    // 맵 시작 뒤 0.05초마다 하나씩: 이펙트 → 사운드(음량 0, 첫 재생 무음 방지) → 레밀리아·장판 유닛 모델
    private function PreloadStep takes nothing returns nothing
        local real x = GetStartLocationX(0)
        local real y = GetStartLocationY(0)
        local effect e
        local sound snd
        if PreIdx < PreCount then
            set e = AddSpecialEffect(PreModel[PreIdx], x, y)
            call EXSetEffectSize(e, 0.01)
            call DestroyEffect(e)
            set e = null
            set PreIdx = PreIdx + 1
            call TimerStart(PreTimer, 0.05, false, function PreloadStep)
        elseif PreSndIdx < PreSndCount then
            set snd = CreateSound(PreSnd[PreSndIdx], false, false, false, 10, 10, "DefaultEAXON")
            call SetSoundVolume(snd, 0)
            call StartSound(snd)
            call KillSoundWhenDone(snd)
            set snd = null
            set PreSndIdx = PreSndIdx + 1
            call TimerStart(PreTimer, 0.05, false, function PreloadStep)
        elseif PreUnitA == null then
            set PreUnitA = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), REMILIA_UNIT_ID, x, y, 270)
            set PreUnitB = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), DECAL_ID, x, y, 270)
            call SetUnitScale(PreUnitA, 0.01, 0.01, 0.01)
            call SetUnitScale(PreUnitB, 0.01, 0.01, 0.01)
            call PauseUnit(PreUnitA, true)
            call TimerStart(PreTimer, 0.3, false, function PreloadUnitsEnd)
        endif
    endfunction

    private function PreloadAdd takes string model returns nothing
        call Preload(model)
        set PreModel[PreCount] = model
        set PreCount = PreCount + 1
    endfunction

    // 음성이 정해지면 여기에 넣는다 (지금은 없음)
    private function PreloadAddSnd takes string path returns nothing
        if path == null or path == "" then
            return
        endif
        call Preload(path)
        set PreSnd[PreSndCount] = path
        set PreSndCount = PreSndCount + 1
    endfunction

    // 음성 표에 한 줄 추가 (같은 칸은 이어서 넣는다) + 맵 시작 때 음량 0 으로 미리 틀기
    private function VoAdd takes integer id, string file, real dur returns nothing
        if VoN[id] == 0 then
            set VoStart[id] = VoCount
        endif
        set VoFile[VoCount] = file
        set VoDur[VoCount] = dur
        set VoN[id] = VoN[id] + 1
        set VoCount = VoCount + 1
        call PreloadAddSnd(SND_DIR + file)
    endfunction

    private function PreloadFx takes real x, real y returns nothing
        call PreloadOne(FX_FLASH_RED, x, y)
        call PreloadOne(FX_FLASH_WHITE, x, y)
        call PreloadOne(FX_SPARKS, x, y)
        call PreloadOne(FX_BURST, x, y)
        call PreloadOne(FX_GATHER, x, y)
        call PreloadOne(FX_CRACK, x, y)
        call PreloadOne(FX_COUNTER_READY, x, y)
        call PreloadOne(FX_CLAW, x, y)
        call PreloadOne(FX_SPEAR, x, y)
        call PreloadOne(FX_ORB, x, y)
        call PreloadOne(FX_BATS, x, y)
        call PreloadOne(FX_BATS_HIT, x, y)
        call PreloadOne(FX_SUN_SHAFT, x, y)
        call PreloadOne(FX_BURN, x, y)
        call PreloadOne(FX_SPIN, x, y)
        call PreloadOne(FX_EYES, x, y)
        call PreloadOne(TELE_LINE, x, y)
    endfunction

    function RemiliaBossStart takes unit source returns nothing
        local tick t
        local RemiliaFight f
        local integer pid = GetPlayerId(GetOwningPlayer(source))
        local integer mapNumber = GetMap(ARENA_THEMA)
        local rect r2
        if mapNumber == 0 then
            return
        endif
        set f = RemiliaFightAt[mapNumber]
        if f == 0 then
            set f = RemiliaFight.create()
            set f.rect = mapNumber
            set f.state = REMILIA_READY
            set f.ul = party.create()
            set f.hit = 0
            set RemiliaFightAt[mapNumber] = f
            call PreloadFx(GetRectCenterX(MapRectReturn(mapNumber)), GetRectCenterY(MapRectReturn(mapNumber)))
            set f.entrance = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), ENTRANCE_DUMMY, GetRectCenterX(MapRectReturn2(mapNumber)), GetRectCenterY(MapRectReturn2(mapNumber)), 270)
            call GroupAddUnit(f.ul.super, source)
            set t = tick.create(f)
            call t.start(1.00, true, function EntranceTick)
        elseif f.state == REMILIA_READY then
            call GroupAddUnit(f.ul.super, source)
        else
            return
        endif
        set r2 = MapRectReturn2(mapNumber)
        call SetUnitPosition(source, GetRectCenterX(r2), GetRectCenterY(r2))
        if GetLocalPlayer() == Player(pid) then
            call SetCameraBoundsToRectForPlayerBJ(Player(pid), MapRectReturn(mapNumber))
            call SetCameraPositionForPlayer(Player(pid), GetRectCenterX(r2), GetRectCenterY(r2))
            call DzFrameShow(BossTip, true)
        endif
        set r2 = null
    endfunction

    // 테스트 입장: 채팅 "-레밀"
    private function ChatEnter takes nothing returns nothing
        local integer pid = GetPlayerId(GetTriggerPlayer())
        if MainUnit[pid] != null and not IsUnitDeadVJ(MainUnit[pid]) then
            call RemiliaBossStart(MainUnit[pid])
        endif
    endfunction

    // ======================================================================
    // 데이터
    // ======================================================================
    private module RemiliaInit
        private static method onInit takes nothing returns nothing
            local integer i = 0
            local trigger t = CreateTrigger()
            loop
                exitwhen i >= 12
                call TriggerRegisterPlayerChatEvent(t, Player(i), "-레밀", true)
                set i = i + 1
            endloop
            call TriggerAddAction(t, function ChatEnter)
            set t = null

            // Hero-Model_Remilia.mdx 애니메이션 길이(초)와 반복 여부 (SEQS)
            set AnimDur[0] = 1.999
            set AnimDur[1] = 1.499
            set AnimDur[2] = 1.052
            set AnimDur[3] = 1.199
            set AnimDur[4] = 0.300
            set AnimDur[5] = 0.631
            set AnimDur[6] = 1.249
            set AnimDur[7] = 1.223
            set AnimDur[8] = 0.999
            set AnimDur[9] = 1.299
            set AnimDur[10] = 0.999
            set AnimDur[11] = 1.800
            set AnimDur[12] = 0.700
            set AnimDur[13] = 0.300
            set AnimDur[14] = 0.700
            set AnimDur[15] = 0.899
            set AnimDur[16] = 0.700
            set AnimDur[17] = 0.700
            set AnimDur[18] = 1.000
            set AnimDur[19] = 0.758
            set AnimDur[20] = 0.001
            set AnimDur[21] = 0.650
            set AnimDur[22] = 0.900
            set AnimDur[23] = 0.800
            set AnimDur[24] = 0.848
            set AnimDur[25] = 0.500
            set AnimDur[26] = 0.725
            set AnimDur[27] = 0.848
            set AnimDur[28] = 1.000
            set AnimDur[29] = 0.100
            set i = 0
            loop
                exitwhen i > 29
                set AnimLoop[i] = false
                set i = i + 1
            endloop
            set AnimLoop[0] = true
            set AnimLoop[1] = true
            set AnimLoop[5] = true
            set AnimLoop[8] = true
            set AnimLoop[10] = true
            set AnimLoop[14] = true
            set AnimLoop[20] = true
            set AnimLoop[29] = true

            // 쿨다운(초)과 가중치
            set PatCool[0] = 0
            set PatCool[PAT_CLAW] = 4
            set PatCool[PAT_HEART] = 6
            set PatCool[PAT_SHOOT] = 7
            set PatCool[PAT_FLAP] = 6
            set PatCool[PAT_CRADLE] = 14
            set PatCool[PAT_QUEEN] = 16
            set PatCool[PAT_STAR] = 16
            set PatCool[PAT_BAT] = 0
            set PatWeight[0] = 0
            set PatWeight[PAT_CLAW] = 50
            set PatWeight[PAT_HEART] = 25
            set PatWeight[PAT_SHOOT] = 25
            set PatWeight[PAT_FLAP] = 0
            set PatWeight[PAT_CRADLE] = 35
            set PatWeight[PAT_QUEEN] = 30
            set PatWeight[PAT_STAR] = 35
            set PatWeight[PAT_BAT] = 0
            // 2페이즈
            set PatCool[PAT_HEART2] = 5
            set PatCool[PAT_SCRAMBLE] = 6
            set PatCool[PAT_MEIKAI] = 7
            set PatCool[PAT_SWARM] = 6
            set PatCool[PAT_GUNGNIR] = 14
            set PatCool[PAT_MISERY] = 18
            set PatCool[PAT_DRACULA] = 14
            set PatCool[PAT_FATE] = 0
            set PatCool[PAT_NIGHT] = 0
            set PatCool[PAT_GENSO] = 0
            set PatWeight[PAT_HEART2] = 30
            set PatWeight[PAT_SCRAMBLE] = 25
            set PatWeight[PAT_MEIKAI] = 25
            set PatWeight[PAT_SWARM] = 25
            set PatWeight[PAT_GUNGNIR] = 35
            set PatWeight[PAT_MISERY] = 35
            set PatWeight[PAT_DRACULA] = 40
            set PatWeight[PAT_FATE] = 0
            set PatWeight[PAT_NIGHT] = 0
            set PatWeight[PAT_GENSO] = 0

            call PreloadAdd(FX_FLASH_RED)
            call PreloadAdd(FX_FLASH_WHITE)
            call PreloadAdd(FX_SPARKS)
            call PreloadAdd(FX_BURST)
            call PreloadAdd(FX_GATHER)
            call PreloadAdd(FX_CRACK)
            call PreloadAdd(FX_COUNTER_READY)
            call PreloadAdd(FX_CLAW)
            call PreloadAdd(FX_SPEAR)
            call PreloadAdd(FX_ORB)
            call PreloadAdd(FX_BATS)
            call PreloadAdd(FX_BATS_HIT)
            call PreloadAdd(FX_SUN_SHAFT)
            call PreloadAdd(FX_BURN)
            call PreloadAdd(FX_BURN_HIT)
            call PreloadAdd(FX_SPIN)
            call PreloadAdd(FX_EYES)
            call PreloadAdd(TELE_LINE)
            call PreloadAdd(FX_FOG)
            call PreloadAdd(FX_STAKE)
            call Preload(FX_STOMP)
            // 음성 표 (칸마다 무작위 하나). make_remilia_sounds.py 의 final.json 에서 만든 목록
            set i = 0
            loop
                exitwhen i >= VO_SLOTS
                set VoN[i] = 0
                set VoStart[i] = 0
                set i = i + 1
            endloop
            // 시작: ようこそ人間、我が紅魔城へ / 久しぶりに楽しい夜になるわ!
            call VoAdd(VO_START, "Remilia_Start1.mp3", 3.42)
            call VoAdd(VO_START, "Remilia_Start2.mp3", 3.08)
            // 박쥐 산개: アハハハハ! / 遊びましょう
            call VoAdd(VO_BAT, "Remilia_Bat1.mp3", 0.80)
            call VoAdd(VO_BAT, "Remilia_Bat4.mp3", 1.23)
            // 클로 기합: はっ! / ハッ! / それ!
            call VoAdd(VO_CLAW, "Remilia_Claw1.mp3", 0.41)
            call VoAdd(VO_CLAW, "Remilia_Claw2.mp3", 0.43)
            call VoAdd(VO_CLAW, "Remilia_Claw4.mp3", 0.54)
            // 하트브레이크: 貫け!
            call VoAdd(VO_HEART, "Remilia_Heart.mp3", 0.79)
            // 스칼렛 슛: 焼き払え! / 焼き払え!
            call VoAdd(VO_SHOOT, "Remilia_Shoot1.mp3", 0.98)
            call VoAdd(VO_SHOOT, "Remilia_Shoot2.mp3", 0.90)
            // 데몬로드 크레이들: はぁーっ!
            call VoAdd(VO_CRADLE, "Remilia_Cradle.mp3", 1.54)
            // 퀸 오브 미드나잇: 本気を出しなさい / 本気を出しなさい
            call VoAdd(VO_QUEEN, "Remilia_Queen1.mp3", 1.65)
            call VoAdd(VO_QUEEN, "Remilia_Queen2.mp3", 1.30)
            // 스타 오브 다비드: 導きの星よ! / 導きの星よ
            call VoAdd(VO_STAR, "Remilia_Star1.mp3", 1.57)
            call VoAdd(VO_STAR, "Remilia_Star2.mp3", 1.34)
            // 그로기: あ゛あ゛あ゛
            call VoAdd(VO_GROGGY, "Remilia_Groggy3.mp3", 0.67)
            // 카운터 당함: 馬鹿な / なに? / ううっ! / そ、そんなことは…
            call VoAdd(VO_COUNTERHIT, "Remilia_CounterHit1.mp3", 0.87)
            call VoAdd(VO_COUNTERHIT, "Remilia_CounterHit2.mp3", 0.60)
            call VoAdd(VO_COUNTERHIT, "Remilia_CounterHit3.mp3", 0.67)
            call VoAdd(VO_COUNTERHIT, "Remilia_CounterHit4.mp3", 1.54)
            // 70% 블라드 체페슈: 地獄の業火よ! / 地獄の業火よ!
            call VoAdd(VO_VLAD, "Remilia_Vlad1.mp3", 1.65)
            call VoAdd(VO_VLAD, "Remilia_Vlad2.mp3", 1.14)
            // 40% 불야성 레드: 真紅に染まれ! / 真紅に染まれ!
            call VoAdd(VO_FUYAJOU, "Remilia_Fuyajou1.mp3", 1.55)
            call VoAdd(VO_FUYAJOU, "Remilia_Fuyajou2.mp3", 1.43)
            // 10% 전환: 楽しんでいただけたかしら
            call VoAdd(VO_TRANSITION, "Remilia_PartyWipe.mp3", 2.13)
            // 2페이즈 시작: これで形勢逆転よ!
            call VoAdd(VO_PHASE2, "Remilia_Phase2_2.mp3", 2.52)
            // 궁니르: グングニル! / グングニル
            call VoAdd(VO_GUNGNIR, "Remilia_Gungnir1.mp3", 1.09)
            call VoAdd(VO_GUNGNIR, "Remilia_Gungnir2.mp3", 0.63)
            // 드라큘라 크레이들: 焼き尽くしてあげる
            call VoAdd(VO_DRACULA, "Remilia_Dracula.mp3", 1.35)
            // 운명 예지: 運命が動き出す / 運命が動き出す
            call VoAdd(VO_FATE, "Remilia_Fate1.mp3", 1.67)
            call VoAdd(VO_FATE, "Remilia_Fate2.mp3", 1.48)
            // 나이트메어: 誰も止められないわ
            call VoAdd(VO_NIGHTMARE, "Remilia_Nightmare.mp3", 1.54)
            // 홍색의 환상향: 楽しませなさい!
            call VoAdd(VO_GENSOKYO, "Remilia_Gensokyo.mp3", 1.47)
            // 스칼렛 데빌: まだまだ足りないわよ!
            call VoAdd(VO_SCARLETDEVIL, "Remilia_ScarletDevil.mp3", 2.06)
            // 전멸: やっぱりあなたたちと遊ぶと楽しいわ!ずーっとこのままにしてあげる!
            call VoAdd(VO_WIPE, "Remilia_Wipe.mp3", 6.55)
            // 격파: まさか…まさかこの私が…
            call VoAdd(VO_DEFEAT, "Remilia_Defeat.mp3", 3.57)
            // 아쳐의 미리 불러오기(1초 뒤 시작)와 겹치지 않게 조금 늦게
            call TimerStart(PreTimer, 4.0, false, function PreloadStep)
        endmethod
    endmodule

    private struct RemiliaInitSt extends array
        implement RemiliaInit
    endstruct
endlibrary
