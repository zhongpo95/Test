/*
    아쳐 보스 (Fate/stay night)

    - 이동 능력과 일반 AI 없이 0.02초 전투 틱 하나가 모든 행동을 직접 제어한다.
    - 1페이즈: HP 1 아래로 내려가지 않음. HP 80·70·…·10%에서 영창 1~8을 순서대로 예약·재생.
    - 영창 8(10%): 진행 중 공격 취소, 피해 잠금, 전장 타일·배경 변경, 최대 체력까지 회복 후 2페이즈.
    - 2페이즈(무한의 검제): 검의 비·검의 포위·검제 연속 공격이 추가되고 정상 처치 가능.

    패턴, 투사체, 예고 장판이 모두 전투 틱 안에서 진행되므로 취소는 이 문맥의 배열을 비우는 것으로 끝난다.
    지연 콜백이 없어서 이전 페이즈·이전 시도의 공격이 다음 전투에 피해를 주지 않는다.

    ※ 아래 "확정 필요" 표시가 있는 값은 임시값이다. 맵에 맞춰 바꿔야 한다.
*/
library BossArcher requires Tick,DataUnit,UIBossHP,DamageEffect2,UIBossEnd,DataMap,Boss1,BossAggro,ItemPickUp,UIMainQuest,UIPick,AnimationTime,CameraShaker,Euclid,Splash,PSound,BGMSound,Missile,EffectDummy,FXKnockback
    globals
        // ===== 확정 필요: 오브젝트 =====
        // 아쳐 유닛 rawcode 는 Data_Unit.j 의 ARCHER_UNIT_ID (모델 Archer.mdx)
        // Data_Unit.j 의 DataUnitIndex 번호
        constant integer ARCHER_DATA_INDEX = 27
        // 전장 테마 번호 (GetMap). 1=카운터 훈련, 2=그 외 보스가 사용 중
        private constant integer ARENA_THEMA = 3
        // 입장 대기 표식 (다른 보스와 같은 더미)
        private constant integer ENTRANCE_DUMMY = 'e01I'
        // 예고 장판 더미 (AOE.j 와 같은 원형 데칼). 원형 판정에만 쓴다
        private constant integer DECAL_ID = 'h00H'
        // 직선 범위 예고 이펙트 (맵에 들어 있는 [I0]Attack 모델).
        // 모델 원점에서 +X 방향으로 길이 384, 폭은 아래 값. 방향으로 돌리고 길이·폭에 맞춰 늘려 쓴다
        private constant string TELE_LINE = "[I0]Attack2.mdx"
        private constant real TELE_LINE_W = 78
        private constant string TELE_WIDE = "[I0]Attack4.mdx"
        private constant real TELE_WIDE_W = 590
        private constant real TELE_LEN = 384
        // 돌진 베기 판정: 돌진 거리 + 앞쪽 베기 거리, 폭. 예고 사각형과 같은 값을 쓴다
        // 근접 범위 (넓힘: 베기 350→500·반각 60→70, 돌진 끝 베기 130→200, 돌진 폭 260→340, 역베기 길이 450→600)
        private constant real SLASH_RANGE = 500
        private constant real SLASH_HALF = 70
        private constant real DASH_REACH = 200
        private constant real DASH_WIDTH = 340
        // 역베기 판정·예고 사각형 (앞쪽 길이, 폭)
        private constant real COUNTER_LEN = 600
        private constant real COUNTER_WIDTH = 700
        // 카운터 창 길이(초). 보스1-4 1.5초 ~ 보스1-1·1-3 2.5초 사이
        private constant real COUNTER_WINDOW = 2.0
        // 창 동안 역베기 동작을 타격(0.35초) 직전인 이 지점까지만 느리게 재생하고,
        // 실패하면 원래 속도로 되돌려 남은 (0.35 - 이 값)초 뒤에 벤다
        private constant real COUNTER_WINDUP = 0.25
        // 심안 돌진은 대상 앞 이 거리에서 멈춘다 (최대 500). 대상을 지나쳐 등을 보이지 않게 한다
        private constant real COUNTER_DASH_STOP = 150
        // 학익삼련 마지막 돌진 X베기 전 카운터 창 (연속 공격 흐름을 끊지 않게 심안·역습 2.0초보다 짧게) / 성공 시 그로기
        private constant real KAKU_COUNTER_WINDOW = 1.2
        private constant real KAKU_COUNTER_GROGGY = 3.0
        // 패턴 사이 움직임: 대상 쪽으로 몸을 돌리고(초당 각도), 너무 멀면 다가가고 너무 붙으면 물러나며, 그 사이면 옆으로 돈다
        private constant real IDLE_TURN = 360
        // 패턴 사이 짧은 걸음 (계속 걷거나 옆걸음하지 않는다. 모델에 뒷걸음·대시 동작이 없음)
        //  1페이즈: 대상이 STEP_FAR1 보다 멀면 앞으로 한 번. 2페이즈(활): STEP_FAR2 보다 멀면 앞으로, STEP_NEAR2 보다 가까우면 뒤로 물러남
        private constant real STEP_FAR1 = 750
        private constant real STEP_FAR2 = 950
        private constant real STEP_NEAR2 = 220
        private constant real STEP_FWD = 300
        private constant real STEP_FWD_SPEED = 350
        // walk 동작(0.8초) 1배속에 맞는 이동 속도 (발 미끄러짐 방지용 추정치)
        private constant real STEP_WALK_SPEED = 270
        private constant real STEP_BACK = 500
        private constant real STEP_COOL = 2.5
        // 간장·막야 연격: 대상이 이보다 멀면 먼저 뛰어들어 붙는다 (베기 사거리 SLASH_RANGE)
        private constant real A1_GAP = 450
        private constant real A1_GAP_STOP = 300
        private constant real A1_GAP_SPEED = 1400
        // 첫 베기 0.9초 중 처음 0.5초는 대상을 따라 돈다. 마지막 0.4초는 방향 고정 (피할 시간)
        private constant real A1_TRACK = 0.5

        // ===== 이펙트 모델 (ArcanaFX\묶음ID.mdx = D:\Work\ARCANA\model 의 묶음) =====
        // 회귀 쌍검: 간장(흑)·막야(백) 투사체. Stand 0.4초 반복 동안 스스로 한 바퀴 돈다(Death 는 0.01초, 지우면 바로 사라짐).
        // 검 길이 약 96 + 바람 칼날 원반 지름 약 104. 판정 폭 180 에 맞춰 1.7배로 쓴다
        private constant string FX_THROW_KANSHOU = "E]Missile Kansyo.mdx"
        private constant string FX_THROW_BAKUYA = "E]Missile Bakuya.mdx"
        private constant real FX_THROW_SIZE = 1.7
        // archer_q: 붉은 나선 화살 (칼라드볼그)
        private constant string FX_SNIPE_BOLT = "ArcanaFX\\F4435.mdx"
        // effect_fate_jiujian_chongjibo: 붉은 충격파 (Death 2초)
        private constant string FX_SNIPE_BOOM = "ArcanaFX\\F5274.mdx"
        // Snipe Target: 주황 조준 표식 (빌보드, 반복)
        private constant string FX_SNIPE_MARK = "ArcanaFX\\F1178.mdx"
        // 쌍검 베기: 바닥에 눕는 초승달 모양 칼날 궤적. 모델 원점이 중심이고 둥근 바깥쪽이 +X(정면)를 향하며,
        // 재생하는 동안 Z축으로 돌며 휩쓴다. 둘 다 시퀀스 하나라 만들자마자 지워도 끝까지 재생된다 (이펙트 뷰어로 확인)
        // 간장(붉은색): Death 0.43초, 반경 416
        private constant string FX_SLASH_RED = "ArcanaFX\\F6773.mdx"
        private constant real FX_SLASH_RED_R = 416
        // 막야(흰색): AnimeSlash, Birth 0.5초, 반경 201
        private constant string FX_SLASH_WHITE = "ArcanaFX\\F8277.mdx"
        private constant real FX_SLASH_WHITE_R = 201
        // archer_UBW_jianyu_5: 검 여러 자루가 떨어져 꽂힘 (Birth 만 있음)
        private constant string FX_SWORD_FALL = "ArcanaFX\\F9949.mdx"
        // archer_UBW_weapon: 바닥에 꽂힌 검 두 자루 (Stand 반복)
        private constant string FX_SWORD_STUCK = "ArcanaFX\\F5109.mdx"
        // Energy Release: 푸른 고리 섬광
        private constant string FX_COUNTER_READY = "ArcanaFX\\F6321.mdx"
        // 刀光爆炸: 푸른 검광 폭발 (무한의 검제 전개)
        private constant string FX_TRANSITION = "ArcanaFX\\F6400.mdx"

        // ===== 2페이즈 신규 패턴 =====
        // 로 아이아스: 분홍 마법진(Birth 2초로 펼쳐짐 → Stand 1초 반복, Death 1.5초 사라짐, 반경 205, 양면).
        // 바닥 마법진을 세워(Y축 90도) 보스 앞에 벽처럼 둔다. 텍스처는 모두 기본 게임 파일
        private constant string FX_RHO_AIAS = "ArcanaFX\\F2284.mdx"
        private constant real RHO_SIZE = 0.9
        // 방패 유지 시간. 방향은 펼칠 때 고정되고 RHO_REAIM 초마다 한 번씩만 대상 쪽으로 돈다
        private constant real RHO_TIME = 6.0
        private constant real RHO_REAIM = 2.0
        // 재조준 신호(보스가 빛남) 뒤 실제로 돌아서기까지
        private constant real RHO_REAIM_DELAY = 0.8
        // 파훼 ①: 옆·뒤에서 이만큼(최대 체력 대비) 피해를 넣으면 방패가 깨진다
        private constant real RHO_BREAK_RATE = 0.03
        // 파훼 ②: 정면에서 꽃잎 7장을 깬다. 막힌 스킬 사용 한 번마다 한 장 (다단 히트는 한 번)
        private constant integer RHO_PETALS = 7
        // 꽃잎 한 장 = 정면에서 막힌 스킬 사용 1회 (다단 히트는 한 번만, DamageEffect.j GuardNewUse)
        private constant integer RHO_PETAL_HITS = 1
        private constant string FX_PETAL_BREAK = "Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl"
        private constant real RHO_GROGGY = 4.0
        // 못 깨면: 방패가 걷히고 앞쪽 충격파 (예고 2초 = 판정 사각형) + 넉백
        private constant real RHO_WAVE_TELL = 2.0
        private constant real RHO_WAVE_LEN = 600
        // 충격파는 앞쪽 반원 전체 (반지름). 옆 정확히 90도가 경계, 뒤는 안전
        private constant real RHO_WAVE_R = 800
        private constant real RHO_WAVE_WIDTH = 800
        private constant real RHO_KNOCKBACK = 300
        private constant real DMG_RHO_WAVE = 300
        // 부서진 환상: 바닥에 꽂힌 검이 폭발 (기본 건물 폭발 모델, 바로 지워도 끝까지 재생)
        private constant string FX_PHANTASM_BOOM = "Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl"
        
        // ===== 연출 레이어: 공격 하나를 준비 → 발동 → 타격 세 겹으로 쌓는다 (붉은·흰색 계열) =====
        // 아래 모델은 모두 시퀀스를 확인했다: "한 번" = 만들자마자 지워도 끝까지 재생, "유지" = 남겨 두었다가 지운다
        // 준비: 몸에 모이는 붉은 빛 (Death 0.63초 한 번, 빌보드, 반경 247)
        private constant string FX_GATHER = "ArcanaFX\\D0008-V001.mdx"
        // 준비(긴 조준): 발밑에서 빛이 모여 오름 (Death 3초 한 번, 바닥형, 반경 226)
        private constant string FX_CHARGE = "ArcanaFX\\F0968.mdx"
        // 발동·타격: 붉은 섬광 (Birth 0.27초 한 번, 빌보드, 반경 132)
        private constant string FX_FLASH_RED = "ArcanaFX\\F5202.mdx"
        // 타격: 흰 섬광 (Birth 0.4초 한 번, 반경 50 이라 크게 키워 쓴다)
        private constant string FX_FLASH_WHITE = "ArcanaFX\\F5291.mdx"
        // 타격: 튀어 오르는 파편·불꽃 (Birth 0.23초 한 번, 반경 183)
        private constant string FX_SPARKS = "ArcanaFX\\F9906.mdx"
        // 타격 후 남는 붉은 바닥 균열 (Birth 1초 반복 → 유지, Death 는 보이지 않음, 반경 300)
        private constant string FX_CRACK = "ArcanaFX\\F0681.mdx"
        // 돌진·발사 순간 퍼지는 고리 (Birth 0.27초 한 번, 모델 X축 방향으로 퍼짐)
        private constant string FX_BURST = "ArcanaFX\\F3099.mdx"
        // 흙먼지·지면 충격 (기본 게임 모델)
        private constant string FX_DUST = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
        private constant string FX_STOMP = "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl"
        // 무한의 검제 전개: 불꽃 고리 (Birth 1초 → 유지 후 지우면 Death 2.5초, 반경 1870)
        private constant string FX_FIRE_RING = "ArcanaFX\\F3774.mdx"
        // 결계·방패 파괴: 붉은 빛기둥과 파편 (Birth 0.5초, Death 1.6초)
        private constant string FX_SHATTER = "ArcanaFX\\F7255.mdx"
        // 하늘의 톱니바퀴 (Stand 13.3초 반복 회전, 녹슨 금속)
        private constant string FX_GEAR = "ArcanaFX\\O0188.mdx"
        // ===== 모델 묶음에서 장면별로 고른 모델 (태그·애니메이션·반경·파티클 수 확인, archer-fx-pass\candidates) =====
        // 부서진 환상 폭발: 주황 불꽃 방사 폭발 (Birth 1.27초 한 번, 반경 121, 바닥 자국 없음)
        private constant string FX_PHANTASM_FIRE = "ArcanaFX\\F4335.mdx"
        // 칼라드볼그 착탄: 흰·푸른 나선 섬광 (Birth 2초 + Death 2초, 반경 1186, 파티클 33 → 저격 끝에만)
        private constant string FX_CALAD_BURST = "ArcanaFX\\F17061.mdx"
        // 로 아이아스 꽃잎 한 장: 바닥에 눕는 분홍 초승달 (Birth 1초 → Death 1초, 1.5배 반경 134, 뷰어 캡처로 확인)
        // (처음 고른 F14606 파편 고리는 작게 줄이면 거의 보이지 않아 바꿨다)
        private constant string FX_PETAL_SHARD = "ArcanaFX\\F15364.mdx"
        // 로 아이아스 파괴: 분홍 섬광 뒤 솟는 빛기둥 (Birth 1초 → Death 1.8초, 0.5배 반경 90·높이 2400)
        private constant string FX_RHO_BREAK = "ArcanaFX\\F14304.mdx"
        // 투영 복제 시전: 발밑에 도는 푸른 별빛 (Birth 0.8초 한 번, 반경 407)
        private constant string FX_TRACE_CAST = "ArcanaFX\\F13615.mdx"
        // 활 조준 모으기: 붉은 빛이 감겨 모임 (Birth 1.77초 한 번, 반경 593)
        private constant string FX_BOW_CHARGE = "ArcanaFX\\F4313.mdx"
        // 결계 전개 불꽃: 바닥에서 솟는 불길과 균열 (Death 5초 한 번, 반경 1032, 파티클 25 → 전환 때 한 번만)
        private constant string FX_UBW_FIRE = "ArcanaFX\\F15417.mdx"
        // 활 발사 섬광: 붉은 칼날 섬광 (Stand 0.4초만 있어 0.4초 남겨 두었다가 지운다, 반경 237)
        private constant string FX_BOW_FLASH = "ArcanaFX\\F7585.mdx"
        private constant real PHANTASM_RADIUS = 200
        private constant real PHANTASM_WARN = 1.2
        private constant real DMG_PHANTASM = 220
        // 붉은 사냥개(흐룬팅): 표식 대상을 쫓는 유도 화살
        // 발사 후 5초: 4초 추적 + 멈춘 자리 1초 뒤 폭발 (이전 4초). 발사 전 조준 1.4초 (이전 1.0초)
        private constant real HRUNT_TIME = 5.0
        private constant real HRUNT_TELL = 1.4
        // 대상 이동 속도 대비 화살 속도 (스킬 사용 중에도 따돌릴 여지를 남긴다)
        // 화살 속도: 500 에서 시작해 초당 300 씩 빨라져 최대 1100 (이동기로 잠깐 떨어져도 따라잡는다). 회전은 초당 200도
        private constant real HRUNT_SPEED_START = 500
        private constant real HRUNT_ACCEL = 300
        private constant real HRUNT_SPEED_MAX = 1100
        private constant real HRUNT_TURN = 200
        private constant real HRUNT_RADIUS = 150
        private constant real DMG_HRUNT = 350
        // 학익삼련: 간장·막야 3쌍이 대상 위치로 모인 뒤 돌진 X 베기
        private constant real DMG_KAKU = 160
        // 2페이즈 연사 (A1 대체)
        private constant real DMG_VOLLEY = 140
        // 2페이즈 템포: 쿨다운·패턴 사이 휴식 배율
        private constant real PHASE2_COOL_RATE = 0.8
        // 패턴 사이 휴식은 영웅 스킬 묶임(1~3초)을 고려해 줄이지 않는다
        private constant real PHASE2_REST_RATE = 1.0
        // 패턴 뒤 휴식: 짧은 패턴 / 큰 패턴. 영웅이 0.4~0.8초 뒤 맞히고 1~3초 묶이는 것을 기준으로 잡았다
        private constant real REST_SHORT = 1.2
        private constant real REST_BIG = 2.5
        // 검제 연속 공격의 단계 사이 쉬는 시간
        private constant real COMBO_GAP = 1.5
        // 카운터 판정 정면 각도 (돌진형 카운터 스킬이 빗나가지 않게 기본 ±45 보다 넓힌다)
        private constant real COUNTER_ARC = 60
        private constant integer PAT_MAX = 14

        // ===== 무한의 검제: 고유 결계 규칙 =====
        // 결계는 2페이즈 내내 유지된다 (깨지는 기믹 없음)
        // 전검 사출: 체력 25% 에서 한 번. 남은 검 수만큼 날아오고, 뽑은 검 1개 = 1발 방어. 버티면 그로기
        private constant real ALLBLADE_HP = 0.25
        private constant real ALLBLADE_GROGGY = 6
        private constant real ALLBLADE_CHANT = 4
        private constant real DMG_ALLBLADE = 150
        // 검의 언덕 = 아쳐의 탄약. 일정 시간마다 하늘에서 다시 떨어뜨려 채운다
        private constant real RESTOCK_EVERY = 25
        private constant integer RESTOCK_COUNT = 6
        // 검의 강하 (재보급을 대신하는 2페이즈 위험 기믹): RESTOCK_EVERY ± DROP_JITTER 초마다 3파.
        //  파마다 플레이어마다 발밑 1 + 주변(250 안) 2, 전장 무작위 DROP_RANDOM 개. 예고 1.0초, 반경 160, 250 피해 + 기절.
        //  한 파에서 한 사람은 한 번만 맞는다. 떨어진 검은 빈 자리가 있으면 꽂힌 검(탄약)이 되고, 없으면 부서진다
        private constant integer DROP_WAVES = 3
        private constant real DROP_GAP = 0.7
        private constant real DROP_WARN = 1.0
        private constant real DROP_RADIUS = 160
        private constant real DROP_NEAR = 250
        private constant integer DROP_RANDOM = 6
        private constant real DMG_DROP = 250
        private constant real DROP_JITTER = 3.0
        private constant real RESTOCK_WARN = 1.2
        private constant real RESTOCK_RADIUS = 120
        private constant real DMG_RESTOCK = 150
        // 검 뽑기: 빛나는 검 위를 지나가면 자동으로 뽑는다 (최대 3개)
        // 들고 있는 동안 피해 ×1.2·무력화 +2 (DamageEffect.j). 일반 공격으로는 줄지 않고,
        // 로 아이아스 방패를 칠 때 0.5초에 1개씩 꽃잎 1장, 전검 사출 1발 방어에만 쓰인다
        private constant real GLOW_EVERY = 8
        private constant integer GLOW_COUNT = 3
        // 빛나는 검: 12초 (근처 400 안에 플레이어가 있으면 그동안은 꺼지지 않음), 줍는 거리 140
        private constant real GLOW_TIME = 12
        private constant real GLOW_KEEP = 400
        private constant real PULL_RADIUS = 140
        private constant integer PULL_MAX = 3
        // 빛나는 검 표시 (기본 게임 바닥 오라, 반복) / 뽑은 검 표시 (머리 위에서 도는 막야)
        private constant string FX_SWORD_GLOW = "Abilities\\Spells\\Human\\DevotionAura\\DevotionAura.mdl"
        // 검의 사출: 남은 검에서 플레이어 쪽으로 발사 (남은 검 3자루당 1발, 2~6발)
        private constant real DMG_LAUNCH = 160
        // 칼날의 숲: 검 벽 3줄(가운데 한 곳씩 열림), 8초. 닿으면 피해 + 밀려남
        private constant real FOREST_TIME = 8
        // 칼날의 숲 (우리): 플레이어마다 둘레 FOREST_HALF 의 네모 검 벽, 한 변에 폭 FOREST_GAP 의 출구 하나.
        // 예고 FOREST_TELL 초 뒤 벽이 서고, FOREST_RAIN_WARN 초 예고 뒤 우리 안에 검의 비. 벽은 화살·저격을 막는 엄폐물
        private constant real FOREST_HALF = 380
        private constant real FOREST_GAP = 200
        private constant real FOREST_TELL = 1.5
        private constant real FOREST_RAIN_WARN = 2.0
        private constant real DMG_FOREST_RAIN = 320
        private constant real WALL_HALF = 60
        private constant real DMG_WALL = 120
        private constant real WALL_GAP = 320
        // 투영 복제: 표식 대상 영웅의 대표기 모양으로 되돌려 준다. 누구나 카운터 가능
        private constant real TRACE_TELL = 1.5
        private constant real TRACE_GROGGY = 4.5
        private constant real DMG_TRACE = 320

        // ===== 확정 필요: 무한의 검제 전장 =====
        // 바꿀 타일. 0 이면 타일을 바꾸지 않는다. 맵 타일셋에 들어 있는 타일이어야 한다.
        private constant integer UBW_TILE = 'Ldrt'
        // 하늘 모델. "" 이면 바꾸지 않는다. 종료 시 UBW_SKY_RESTORE 로 되돌린다.
        private constant string UBW_SKY = ""
        private constant string UBW_SKY_RESTORE = ""
        // 바닥에 꽂힌 검 장식 수
        private constant integer UBW_STUCK_COUNT = 24

        // ===== 확정 필요: 음성 =====
        private string array ChantSound
        private real array ChantDur
        private string array ChantText
        // ===== 음성 (아처_에미야_사운드_20261009 를 faster-whisper 로 글로 옮겨 확인하고 배정) =====
        // 모두 44.1kHz 모노 mp3 로 다시 만들었다 (D:\Work\ARCANA\Claude outputs\archer-sound-check). 대사는 한 번에 하나만
        // 전환 마지막: "Unlimited Blade Works!" 6.0초 (유튜브 영상 1:23~1:29, 결계 전개 효과음·음악 포함, 음성 인식으로 확인)
        private constant string FINAL_SOUND = "war3mapImported\\ArcherSnd\\Archer_UBW_Final.mp3"
        private constant real FINAL_SOUND_T = 6.0
        // 결계 전환: 선언 대사가 끝나는 2.2초에 전장이 바뀐다
        private constant real TRANS_DEPLOY = 2.2
        // 전투 시작: "서번트 아처, 소환에 응해 참상했다" / 2페이즈 시작: "따라올 수 있겠나"
        private constant string VO_START = "war3mapImported\\ArcherSnd\\Archer_Summon.mp3"
        private constant real VO_START_T = 3.87
        private constant string VO_KEEPUP = "war3mapImported\\ArcherSnd\\Archer_KeepUp.mp3"
        private constant real VO_KEEPUP_T = 1.2
        // 로 아이아스! (두 가지 녹음 번갈아)
        private constant string VO_RHO = "war3mapImported\\ArcherSnd\\Archer_Rho"
        private constant real VO_RHO_T = 2.53
        // 저격: 조준 "나의 골자는 비틀려 미친다" → 발사 "칼라드볼그!" (두 가지 번갈아)
        private constant string VO_BONE = "war3mapImported\\ArcherSnd\\Archer_Bone.mp3"
        private constant real VO_BONE_T = 1.93
        private constant string VO_CALAD = "war3mapImported\\ArcherSnd\\Archer_Calad"
        private constant real VO_CALAD_T = 1.02
        // 흐룬팅: "적원을 달려라, 붉은 사냥개여!"
        private constant string VO_HRUNT = "war3mapImported\\ArcherSnd\\Archer_Hrunting.mp3"
        private constant real VO_HRUNT_T = 2.56
        // 투영 복제: "트레이스 온"
        private constant string VO_TRACE = "war3mapImported\\ArcherSnd\\Archer_TraceOn.mp3"
        private constant real VO_TRACE_T = 0.81
        // 연사: 기합 / 간장·막야 돌진: "비켜라!" / 학익삼련·카운터 역베기: "받았다!" / 검의 사출: "관통하라"(인식 불확실)
        private constant string VO_DODGE = "war3mapImported\\ArcherSnd\\Archer_Dodge.mp3"
        private constant real VO_DODGE_T = 0.78
        private constant string VO_ASIDE = "war3mapImported\\ArcherSnd\\Archer_StepAside.mp3"
        private constant real VO_ASIDE_T = 0.86
        private constant string VO_GOTYOU = "war3mapImported\\ArcherSnd\\Archer_GotYou.mp3"
        private constant real VO_GOTYOU_T = 0.81
        private constant string VO_PIERCE = "war3mapImported\\ArcherSnd\\Archer_Pierce.mp3"
        private constant real VO_PIERCE_T = 0.68
        // 전검 사출 시작: "피할 수 있겠나(かわせるか)" 0.78초 (결계 선언과 겹치지 않게 바꿈. 연사에서는 이 대사를 빼고 기합만)
        private constant string VO_ALLBLADE = "war3mapImported\\ArcherSnd\\Archer_Dodge.mp3"
        private constant real VO_ALLBLADE_T = 0.78
        // 그로기: 대사 없는 짧은 신음 1~3 / 공격 기합 0~4 (2.5초 간격)
        private constant string VO_HIT = "war3mapImported\\ArcherSnd\\Archer_Hurt"
        private constant string VO_GRUNT = "war3mapImported\\ArcherSnd\\Archer_Grunt"
        private constant real GRUNT_GAP = 2.5
        // 쓰러질 때: "아아… 이 몸이 무너지는 감각은… 나쁘지 않군…" / 전멸시켰을 때: "이름 없는 영웅이면 된다"
        private constant string VO_DEATH = "war3mapImported\\ArcherSnd\\Archer_Death.mp3"
        private constant string VO_WIPE = "war3mapImported\\ArcherSnd\\Archer_Nameless.mp3"
        // 무한의 검제 배경음악 (대사 없는 음악 41.8초, 반복). 전투 참가자에게만 틀고 끝나면 원래 음악으로 돌린다
        private constant string UBW_BGM = "war3mapImported\\ArcherSnd\\Archer_UBW_BGM.mp3"

        // ===== 전투 수치 (테스트용 초안) =====
        // 시작 인원 1명 기준 체력은 Data_Unit.j UnitSetHP[ARCHER_DATA_INDEX]. 1명 추가마다 +70%
        private constant real PARTY_HP_BONUS = 0.70
        private constant real TICK = 0.02

        private constant real DMG_SLASH = 150
        private constant real DMG_DASH = 250
        private constant real DMG_THROW = 120
        private constant real DMG_SNIPE = 350
        private constant real DMG_SNIPE_BOOM = 200
        private constant real DMG_COUNTER = 300
        private constant real DMG_RAIN = 220
        private constant real DMG_RING = 250
        private constant real DMG_CORE = 300

        // 패턴 쿨다운(초)과 가중치
        private real array PatCool
        private integer array PatWeight

        // 검의 비 안전 통로 이동 시간 (가장 느린 캐릭터가 한 칸 이동할 수 있게)
        private constant real RAIN_FIRST_WARN = 2.4
        private constant real RAIN_NEXT_WARN = 2.2
        private constant integer RAIN_LANES = 5

        // 투사체 슬롯
        private constant integer MAXP = 8

        // 상태
        constant integer ARCHER_READY = 0
        constant integer ARCHER_PHASE1 = 1
        constant integer ARCHER_TRANSITION_PENDING = 2
        constant integer ARCHER_TRANSITION = 3
        constant integer ARCHER_PHASE2 = 4
        constant integer ARCHER_ENDED = 5

        // 아쳐 모델 애니메이션 인덱스 (Archer.mdx SEQS 순서)
        // 모델이 애니메이션마다 보이는 무기를 바꾼다 (지오셋 알파 기준)
        //  쌍검: stand, stand ready, attack 1/2, spell three(한 자루 투척)
        //  활: morph 후반, *alternate 계열, spell alternate three, spell channel four/five
        //  빈손: stand slam, spell one, attack slam, spell alternate one
        // 타격 시점(재생 1배속 기준): attack 1 약 0.38초, attack 2 약 0.35초, spell three 투척 약 0.2초,
        //  spell channel five 발사 직후, spell alternate two 착지 약 0.65초
        private constant integer AN_STAND = 0
        // walk / walk alternate (반복, 0.8초)
        private constant integer AN_WALK = 1
        private constant integer AN_WALK_ALT = 15
        private constant integer AN_STAND_READY = 2
        private constant integer AN_ATTACK1 = 3
        private constant integer AN_ATTACK2 = 4
        private constant integer AN_SPELL_TWO = 6
        private constant integer AN_DEATH = 7
        private constant integer AN_SPELL_THREE = 8
        private constant integer AN_MORPH = 13
        private constant integer AN_STAND_ALT = 14
        private constant integer AN_STANDREADY_ALT = 16
        private constant integer AN_ATTACK_ALT = 17
        private constant integer AN_SPELL_ALT = 18
        private constant integer AN_SPELL_ALT_TWO = 19
        private constant integer AN_MORPH_ALT = 21
        private constant integer AN_STAND_SLAM = 22
        private constant integer AN_SPELL_ONE = 23
        private constant integer AN_ATTACK_SLAM = 24
        private constant integer AN_SPELL_ALT_ONE = 27
        private constant integer AN_SPELL_ALT_THREE = 28
        private constant integer AN_CHANNEL_FOUR = 29
        private constant integer AN_CHANNEL_FIVE = 30
        // 애니메이션 길이(초)와 반복 여부 (Archer.mdx)
        private real array AnimDur
        private boolean array AnimLoop

        integer array ArcherFightAt
        private hashtable TerrainSave = InitHashtable()
        private integer CheckFight = 0
        // 뽑은 검을 든 영웅 머리 위 표시 (플레이어 번호)
        private effect array PullFx
        // 뽑은 검 개수 글자 (머리 위 '검 ×2', 플레이어 번호)
        private texttag array PullTag
        private integer array PullTagN
        // 로 아이아스에서 검을 다시 쓸 수 있는 시각 (플레이어 번호). 한 사람 0.5초에 1개
        private real array PullUseAt
        private location TmpLoc = Location(0, 0)
        // 맵 시작 직후 이펙트 미리 불러오기 (한 틱에 하나씩, 시작 지점에서 아주 작게 한 번 그려 텍스처까지 올린다)
        private string array PreModel
        private integer PreCount = 0
        private integer PreIdx = 0
        private timer PreTimer = CreateTimer()
        private unit PreUnitA = null
        private unit PreUnitB = null
        // 사운드: 이 맵에서는 파일을 처음 재생할 때 소리가 나지 않는다 (지크프리트 코드와 같은 문제).
        // 맵 시작 직후 모든 파일을 음량 0 으로 한 번씩 틀어 두고(첫 재생 무음 방지), 실제 재생은 바로 한다
        private string array PreSnd
        private integer PreSndCount = 0
        private integer PreSndIdx = 0
        // null 이 아니면 Decal 이 만든 장판을 이 그룹에도 넣는다 (검의 비 통로 장판 교체용)
        private group DecalCapture = null
    endglobals

    // ======================================================================
    // 전투 문맥
    // ======================================================================
    struct ArcherFight
        unit boss = null
        unit entrance = null
        party ul
        integer rect = 0
        integer state = ARCHER_READY
        real now = 0
        tick t
        // 반복하지 않는 동작이 끝나는 시각. 지나면 대기 동작으로 돌아간다 (0 이면 없음)
        real animEnd = 0

        unit array mem[6]
        integer array markCount[6]
        integer memN = 0

        // 영창
        integer chantReserved = 0
        integer chantDone = 0
        boolean chantPlaying = false
        real chantEnd = 0
        // 음성: 재생 중인 대사가 끝나는 시각, 기합 다음 가능 시각
        real voiceUntil = 0
        real gruntAt = 0
        real transStart = 0
        integer transStep = 0

        // 패턴
        integer pat = 0
        integer step = 0
        real patStart = 0
        real nextSelect = 0
        integer lastPat = 0
        integer introIdx = 0
        integer combo = 0
        integer rainUsed = 0
        real array readyAt[18]
        // 무한의 검제 상태
        boolean ubw = false
        // 전검 사출을 이미 썼는지
        boolean ubwSecond = false
        boolean saidKeepUp = false
        // 무한의 검제 배경음악 (반복 2D 사운드)
        sound bgm = null
        // 보스 머리 위 패턴 이름
        texttag patTag = null
        real patTagEnd = 0
        // 패턴 사이 움직임
        boolean walking = false
        // 무력화 자세: 데스 동작 끝 무렵에 멈춘다 (0 이면 없음)
        real downFreeze = 0
        real stepLeft = 0
        real stepAng = 0
        real stepSpd = 0
        real nextStepAt = 0
        real holdUntil = 0
        real restockAt = 0
        // 검의 강하: 남은 파 수, 다음 파 시각, 떨어질 자리(최대 64) 와 파 번호, 파마다 맞은 사람
        integer dropWave = 0
        real dropNext = 0
        real array dX[64]
        real array dY[64]
        real array dAt[64]
        integer array dW[64]
        party array dHit[3]
        real glowAt = 0
        real groggy = 0
        effect array sGlow[24]
        real array sGlowEnd[24]
        real array sFall[24]
        effect array wallFx[96]
        real array wallHitAt[6]
        integer snipeLeft = 0
        integer wave = 0

        // 고정 좌표·방향
        unit target = null
        real ax = 0
        real ay = 0
        real ang = 0
        // 고정한 바라보는 방향. 헤드·백 판정(GetUnitFacing)이 이 값과 같도록 매 틱 유지한다
        real face = 270
        real tx = 0
        real ty = 0
        real dashLeft = 0
        real dashSpeed = 0
        real dashLen = 0
        // 카운터 신호 더미 (다른 보스와 같은 e00F·e00G·e01S)
        unit array cue[3]
        party hit
        group decals
        // 현재 검의 비 통로 장판. 다음 파동 예고 전에 지운다
        group rainDecals
        effect mark = null

        // 검의 비
        integer rainSafe = 0
        integer rainWave = 0
        integer rainWaves = 0
        real rainAng = 0
        real rainNext = 0
        boolean rainSnipe = false

        // 투사체: 1 회귀검, 2 저격탄
        integer array pk[8]
        effect array pe[8]
        real array px[8]
        real array py[8]
        real array pox[8]
        real array poy[8]
        real array pdir[8]
        real array pspd[8]
        real array ptrav[8]
        real array pmax[8]
        real array prad[8]
        real array pdmg[8]
        boolean array pback[8]
        party array phit[8]

        // 직선 범위 예고 이펙트 (패턴 취소·종료 시 같이 지운다)
        effect array tele[24]
        real array teleEnd[24]

        // 일정 시간 유지 후 지우는 이펙트 (베기 등 Stand 동작을 끝까지 보여 준다)
        effect array fxe[24]
        real array fxEnd[24]
        // 하늘의 톱니바퀴
        effect array gear[4]

        // 무한의 검제 장식 (위치와 부서진 환상 폭발 시각)
        effect array stuck[24]
        real array sx[24]
        real array sy[24]
        real array sExp[24]

        // 로 아이아스 방패 / 흐룬팅 화살
        effect rho = null
        integer petals = 0
        effect hEff = null
        lightning hLight = null
        real hx = 0
        real hy = 0
        real hdir = 0

        // 학익삼련 검 출발점·방향·거리
        real array kx[32]
        real array ky[32]
        real array ka[32]
        real array kl[32]
        // 칼날의 숲: 벽 조각 수, 우리 중심, 우리 수, 벽이 서 있는지 (화살이 막힘)
        integer kn = 0
        real array cgx[6]
        real array cgy[6]
        integer cgn = 0
        boolean forestOn = false
        boolean terrainChanged = false

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

    // 점 (x,y) 와 선분 (x1,y1)-(x2,y2) 사이 거리
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

    private function AliveCount takes ArcherFight f returns integer
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

    private function Anim takes ArcherFight f, integer idx, real speed returns nothing
        set f.downFreeze = 0
        call AnimationStart3(f.boss, idx, speed)
        if AnimLoop[idx] then
            set f.animEnd = 0
        else
            set f.animEnd = f.now + AnimDur[idx] / speed
        endif
    endfunction

    // 무력화: 데스 동작(1페이즈 death, 2페이즈 death alternate)을 틀고 쓰러진 자세에서 멈춘다.
    // 다음 Anim(그로기 뒤 AnimIdle 등)이 배속을 1 로 되돌린다
    private function AnimDown takes ArcherFight f returns nothing
        local integer idx = 7
        local effect e
        if f.state == ARCHER_PHASE2 then
            set idx = 20
        endif
        call Anim(f, idx, 1.0)
        // 무너지는 순간: 흰 섬광 + 파편 + 퍼지는 고리 (FxAt 보다 앞에 있는 함수라 직접 만든다)
        set e = AddSpecialEffect(FX_FLASH_WHITE, GetUnitX(f.boss), GetUnitY(f.boss))
        call EXSetEffectSize(e, 4.0)
        call DestroyEffect(e)
        set e = AddSpecialEffect(FX_SPARKS, GetUnitX(f.boss), GetUnitY(f.boss))
        call EXSetEffectSize(e, 1.2)
        call DestroyEffect(e)
        set e = AddSpecialEffect(FX_BURST, GetUnitX(f.boss), GetUnitY(f.boss))
        call EXEffectMatRotateZ(e, f.face)
        call DestroyEffect(e)
        set e = null
        // 끝나도 대기 동작으로 돌아가지 않게
        set f.animEnd = 0
        set f.downFreeze = f.now + 0.01 + AnimDur[idx] * 0.9
    endfunction

    // 현재 무기 자세에 맞는 대기 동작 (1페이즈 쌍검, 2페이즈 활)
    private function AnimIdle takes ArcherFight f returns nothing
        if f.state == ARCHER_PHASE2 or (f.state == ARCHER_TRANSITION and f.transStep >= 2) then
            call Anim(f, AN_STAND_ALT, 1.0)
        else
            call Anim(f, AN_STAND, 1.0)
        endif
    endfunction

    // 방향 고정: 다른 보스와 같이 SetUnitFacing + EXSetUnitFacing 뒤 제자리 SetUnitPosition 으로 반영한다
    private function ApplyFacing takes ArcherFight f returns nothing
        call SetUnitFacing(f.boss, f.face)
        call EXSetUnitFacing(f.boss, f.face)
        call SetUnitPosition(f.boss, GetUnitX(f.boss), GetUnitY(f.boss))
    endfunction

    private function Face takes ArcherFight f, real a returns nothing
        // 조준 중에는 매 틱 불리므로 0.5도 이상 바뀔 때만 적용한다 (매 틱 SetUnitPosition 방지)
        if AngDiff(ModuloReal(a, 360.0), f.face) < 0.5 and AngDiff(GetUnitFacing(f.boss), f.face) < 1.0 then
            return
        endif
        set f.face = ModuloReal(a, 360.0)
        call ApplyFacing(f)
    endfunction

    // 목표 방향으로 한 틱에 maxStep 도까지만 돈다 (휙 도는 대신 자연스럽게)
    private function TurnToward takes ArcherFight f, real a, real maxStep returns nothing
        local real d = ModuloReal(a - f.face + 540.0, 360.0) - 180.0
        if d > maxStep then
            set d = maxStep
        elseif d < -maxStep then
            set d = -maxStep
        endif
        call Face(f, f.face + d)
    endfunction

    // 일시정지 유닛은 방향이 어긋난 채 남을 수 있으므로 고정값과 다르면 다시 맞춘다
    private function HoldFacing takes ArcherFight f returns nothing
        // 0.1초마다 확인. 어긋났을 때만 방향만 다시 넣는다 (매 틱 SetUnitPosition 을 하지 않게)
        if ModuloInteger(R2I(f.now / TICK + 0.5), 5) != 0 then
            return
        endif
        if AngDiff(GetUnitFacing(f.boss), f.face) > 1.0 then
            call SetUnitFacing(f.boss, f.face)
            call EXSetUnitFacing(f.boss, f.face)
        endif
    endfunction

    // 대사 재생: 위치 없는 2D (게임 점검에서 3D 는 아쳐 파일이 무음이었다. 보스전 소리는 모두 들으면 되므로 2D).
    // 바로 재생한다
    private function PlaySoundAt takes string path, real x, real y returns nothing
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

    private function PlaySoundPath takes ArcherFight f, string path returns nothing
        if f.boss != null then
            call PlaySoundAt(path, GetUnitX(f.boss), GetUnitY(f.boss))
        else
            call PlaySoundAt(path, f.arenaCX(), f.arenaCY())
        endif
    endfunction

    // 대사: 다른 대사가 재생 중이면 건너뛴다 (겹침 방지)
    private function Voice takes ArcherFight f, string path, real dur returns nothing
        // 영창 중에는 어떤 대사도 끼우지 않는다 (강제 대사 voiceUntil = 0 도 막힘)
        if f.now < f.voiceUntil or (f.chantPlaying and f.now < f.chantEnd) then
            return
        endif
        set f.voiceUntil = f.now + dur + 0.2
        call PlaySoundPath(f, path)
    endfunction

    // 공격 기합: 대사가 없고 마지막 기합 후 GRUNT_GAP 이 지났을 때만
    private function Grunt takes ArcherFight f returns nothing
        if f.now < f.voiceUntil or f.now < f.gruntAt or (f.chantPlaying and f.now < f.chantEnd) then
            return
        endif
        set f.gruntAt = f.now + GRUNT_GAP
        set f.voiceUntil = f.now + 0.9
        call PlaySoundPath(f, VO_GRUNT + I2S(GetRandomInt(0, 4)) + ".mp3")
    endfunction

    // 저격 발사: "칼라드볼그!" (녹음 두 가지 중 하나)
    private function VoiceCalad takes ArcherFight f returns nothing
        call Voice(f, VO_CALAD + I2S(GetRandomInt(1, 2)) + ".mp3", VO_CALAD_T)
    endfunction

    // 그로기 비명
    private function VoiceHit takes ArcherFight f returns nothing
        set f.voiceUntil = 0
        call Voice(f, VO_HIT + I2S(GetRandomInt(1, 3)) + ".mp3", 1.1)
    endfunction

    // 위치가 있는 효과음 (모노 파일만)
    private function Sfx3D takes string path, real x, real y returns nothing
        local sound snd = CreateSound(path, false, true, true, 10, 10, "")
        call SetSoundDistances(snd, 600, 3000)
        call SetSoundDistanceCutoff(snd, 3000)
        call SetSoundVolume(snd, 110)
        call SetSoundPosition(snd, x, y, 50)
        call StartSound(snd)
        call KillSoundWhenDone(snd)
        set snd = null
    endfunction

    // 베기 궤적: (x, y) 에서 a 방향으로 dist 앞을 중심으로, 반경 reach 의 초승달을 정면(a + tilt)으로 눕힌다
    // white = 막야(흰색), 아니면 간장(붉은색)
    private function FxCut takes real x, real y, real a, real dist, real tilt, real reach, boolean white returns nothing
        local effect e
        if white then
            set e = AddSpecialEffect(FX_SLASH_WHITE, x + PolarX(dist, a), y + PolarY(dist, a))
            call EXSetEffectSize(e, reach / FX_SLASH_WHITE_R)
        else
            set e = AddSpecialEffect(FX_SLASH_RED, x + PolarX(dist, a), y + PolarY(dist, a))
            call EXSetEffectSize(e, reach / FX_SLASH_RED_R)
        endif
        call EXEffectMatRotateZ(e, a + tilt)
        call DestroyEffect(e)
        set e = null
    endfunction

    // 한 번 재생 이펙트 (크기·방향)
    private function FxAt takes string model, real x, real y, real size, real yaw returns nothing
        local effect e = AddSpecialEffect(model, x, y)
        call EXSetEffectSize(e, size)
        call EXEffectMatRotateZ(e, yaw)
        call DestroyEffect(e)
        set e = null
    endfunction

    // 꽂힌 검(F5109) 지우기: 이 모델은 Death 동작에서만 입자 방출기 2개가 켜져(초당 700개, 0.5초) 지울 때마다
    // 큰 입자 폭발이 난다. 검을 한꺼번에 많이 지우는 패턴(전검 사출·부서진 환상·칼날의 숲)에서 프레임이 떨어지므로
    // 크기를 0 으로 줄이고 땅 아래로 옮긴 뒤 지운다
    private function SwordFxRemove takes effect e returns nothing
        call EXSetEffectSize(e, 0.01)
        call EXSetEffectZ(e, -3000)
        call DestroyEffect(e)
    endfunction

    // dur 초 남겨 두는 이펙트 (바닥 균열, 불꽃 고리 등)
    private function FxKeep takes ArcherFight f, string model, real x, real y, real size, real yaw, real dur returns nothing
        local integer i = 0
        local effect e = AddSpecialEffect(model, x, y)
        call EXSetEffectSize(e, size)
        call EXEffectMatRotateZ(e, yaw)
        loop
            exitwhen i >= 24
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

    // 준비: 보스 몸에 모이는 빛
    private function FxWindup takes ArcherFight f returns nothing
        call Grunt(f)
        call DestroyEffect(AddSpecialEffectTarget(FX_GATHER, f.boss, "chest"))
    endfunction

    // 발동: 보스 앞 섬광 + 퍼지는 고리 (활 시위·투척·돌진 출발)
    private function FxMuzzle takes ArcherFight f, real a returns nothing
        local real x = GetUnitX(f.boss) + PolarX(80, a)
        local real y = GetUnitY(f.boss) + PolarY(80, a)
        call FxAt(FX_FLASH_RED, x, y, 1.0, a)
        call FxAt(FX_BURST, x, y, 0.6, a)
        call FxKeep(f, FX_BOW_FLASH, x, y, 0.8, a, 0.4)
    endfunction

    // 돌진 출발: 고리 + 흙먼지
    private function FxDash takes ArcherFight f returns nothing
        call FxAt(FX_BURST, GetUnitX(f.boss), GetUnitY(f.boss), 1.0, f.ang)
        call FxAt(FX_DUST, GetUnitX(f.boss), GetUnitY(f.boss), 1.0, f.ang)
    endfunction

    // 작은 타격: 붉은 섬광 + 파편
    private function FxHitSmall takes real x, real y, real a returns nothing
        call FxAt(FX_FLASH_RED, x, y, 1.2, a)
        call FxAt(FX_SPARKS, x, y, 0.8, a)
    endfunction

    // 큰 타격: 흰 섬광 + 파편 + 지면 충격 + 1.5초 남는 균열 + 화면 흔들림
    private function FxHitBig takes ArcherFight f, real x, real y, real a, real size returns nothing
        call FxAt(FX_FLASH_WHITE, x, y, 5.0 * size, a)
        call FxAt(FX_SPARKS, x, y, 1.2 * size, a)
        call FxAt(FX_STOMP, x, y, size, a)
        call FxKeep(f, FX_CRACK, x, y, 0.9 * size, GetRandomReal(0, 360), 1.5)
        call CameraShaker.setShake(6)
    endfunction

    // all 이면 남은 시간과 관계없이 모두 지운다
    private function FxUpdate takes ArcherFight f, boolean all returns nothing
        local integer i = 0
        loop
            exitwhen i >= 24
            if f.fxe[i] != null and (all or f.now >= f.fxEnd[i]) then
                call DestroyEffect(f.fxe[i])
                set f.fxe[i] = null
            endif
            set i = i + 1
        endloop
    endfunction

    private function ClampX takes ArcherFight f, real x returns real
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

    private function ClampY takes ArcherFight f, real y returns real
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

    private function MsgAll takes ArcherFight f, string s, real dur returns nothing
        local integer i = 0
        loop
            exitwhen i >= f.memN
            if f.mem[i] != null then
                call DisplayTimedTextToPlayer(GetOwningPlayer(f.mem[i]), 0, 0, dur, s)
            endif
            set i = i + 1
        endloop
    endfunction

    // 현재 어그로 대상. 살아 있지 않으면 살아 있는 참가자 중 하나
    private function PickTarget takes ArcherFight f returns unit
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

    // 저격 대상: 표식을 가장 적게 받은 생존자 (동률은 무작위)
    private function PickSnipeTarget takes ArcherFight f returns integer
        local integer i = 0
        local integer best = -1
        local integer bestCount = 999999
        local integer ties = 0
        loop
            exitwhen i >= f.memN
            if MemAlive(f.mem[i]) then
                if f.markCount[i] < bestCount then
                    set best = i
                    set bestCount = f.markCount[i]
                    set ties = 1
                elseif f.markCount[i] == bestCount then
                    set ties = ties + 1
                    if GetRandomInt(1, ties) == 1 then
                        set best = i
                    endif
                endif
            endif
            set i = i + 1
        endloop
        return best
    endfunction

    // ======================================================================
    // 예고 장판 (types 0 빨강, 2 노랑, 3 초록 - AOE.j 색 규칙)
    // ======================================================================
    private function Decal takes ArcherFight f, real x, real y, real radius, real time, integer types returns nothing
        local unit d = CreateUnit(GetOwningPlayer(f.boss), DECAL_ID, x, y, 270)
        local real s = radius * 0.01
        call SetUnitScalePercent(d, 100 * s, 100 * s, 100)
        if types == 0 then
            call SetUnitVertexColor(d, 255, 10, 10, 255)
        elseif types == 2 then
            call SetUnitVertexColor(d, 255, 255, 10, 255)
        elseif types == 3 then
            call SetUnitVertexColor(d, 10, 255, 10, 255)
        endif
        call SetUnitTimeScale(d, 1 / time)
        call UnitApplyTimedLife(d, 'BHwe', time)
        call GroupAddUnit(f.decals, d)
        if DecalCapture != null then
            call GroupAddUnit(DecalCapture, d)
        endif
        set d = null
    endfunction

    // 패턴 종료 정리(ClearDecals)에 지워지지 않는 원형 예고 (검의 강하처럼 패턴과 따로 도는 기믹용)
    private function DecalFree takes ArcherFight f, real x, real y, real radius, real time returns nothing
        local unit d = CreateUnit(GetOwningPlayer(f.boss), DECAL_ID, x, y, 270)
        local real s = radius * 0.01
        call SetUnitScalePercent(d, 100 * s, 100 * s, 100)
        call SetUnitVertexColor(d, 255, 10, 10, 255)
        call SetUnitTimeScale(d, 1 / time)
        call UnitApplyTimedLife(d, 'BHwe', time)
        set d = null
    endfunction

    // 직선 예고: 원형 데칼을 이어 붙인다
    private function DecalLine takes ArcherFight f, real x, real y, real a, real len, real width, real time, integer types returns nothing
        local real r = width * 0.5
        local real step = width * 0.8
        local real d = r
        loop
            exitwhen d > len
            call Decal(f, x + PolarX(d, a), y + PolarY(d, a), r, time, types)
            set d = d + step
        endloop
    endfunction

    private function ClearDecalsEnum takes nothing returns nothing
        local unit u = GetEnumUnit()
        if not IsUnitDeadVJ(u) then
            call ShowUnit(u, false)
            call KillUnit(u)
        endif
        set u = null
    endfunction

    // 직선 범위 예고: (x, y) 에서 a 방향으로 길이 len, 폭 width 의 사각형을 time 초 동안 보여 준다
    private function TeleRect takes ArcherFight f, string model, real baseW, real x, real y, real a, real len, real width, real time returns nothing
        local integer i = 0
        local effect e = AddSpecialEffect(model, x, y)
        // EXEffectMatScale 은 이미 돌린 뒤에 부르면 맵 X·Y축으로 늘어난다(남쪽 저격선이 길고 가늘게 나온 것으로 확인).
        // 그래서 모델 축(길이 X, 폭 Y)으로 먼저 늘린 뒤 공격 방향으로 돌린다
        call EXEffectMatScale(e, len / TELE_LEN, width / baseW, 1)
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

    private function TeleLine takes ArcherFight f, real x, real y, real a, real len, real width, real time returns nothing
        call TeleRect(f, TELE_LINE, TELE_LINE_W, x, y, a, len, width, time)
    endfunction

    // 앞쪽 반원 예고 (판정 HitFan 반각 90도와 같다): 직선 예고 8줄을 22.5도 간격 부채로 편다.
    // 줄 폭 = 끝에서 이웃 줄과 맞닿는 폭이라 반원 바깥 테두리까지 빈틈이 없다. 뒤쪽은 비어 있다(안전)
    private function TeleHalf takes ArcherFight f, real x, real y, real a, real r, real time returns nothing
        local integer k = 0
        local real w = 2 * r * Sin(11.25 * bj_DEGTORAD)
        loop
            exitwhen k >= 8
            call TeleRect(f, TELE_LINE, TELE_LINE_W, x, y, a - 78.75 + 22.5 * k, r, w, time)
            set k = k + 1
        endloop
    endfunction

    // all 이면 남은 시간과 관계없이 모두 지운다
    private function TeleUpdate takes ArcherFight f, boolean all returns nothing
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

    private function ClearDecals takes ArcherFight f returns nothing
        call ForGroup(f.decals, function ClearDecalsEnum)
        call GroupClear(f.decals)
        call GroupClear(f.rainDecals)
        call TeleUpdate(f, true)
    endfunction

    // ======================================================================
    // 피해 판정 (이 전투 참가자만 대상)
    // ======================================================================
    private function Deal takes ArcherFight f, unit u, real dmg, boolean stun returns nothing
        call BossDeal(f.boss, u, dmg, stun)
    endfunction

    // 원형. g 가 0 이 아니면 그 그룹에 이미 있는 대상은 건너뛴다
    private function HitCircle takes ArcherFight f, real x, real y, real r, real dmg, boolean stun, party g returns nothing
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

    // 고리: inner 보다 멀고 outer 안쪽
    private function HitRing takes ArcherFight f, real x, real y, real inner, real outer, real dmg returns nothing
        local integer i = 0
        local unit u
        loop
            exitwhen i >= f.memN
            set u = f.mem[i]
            if MemAlive(u) and IsUnitInRangeXY(u, x, y, outer) and not IsUnitInRangeXY(u, x, y, inner) then
                call Deal(f, u, dmg, true)
            endif
            set i = i + 1
        endloop
        set u = null
    endfunction

    // 부채꼴: 거리 range, 중심 방향 a 에서 ±half 도
    private function HitFan takes ArcherFight f, real x, real y, real a, real range, real half, real dmg, boolean stun returns nothing
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

    // 선분 휩쓸기: 이전 위치와 현재 위치 사이를 검사해서 빠른 이동에도 충돌을 놓치지 않는다
    private function HitSweep takes ArcherFight f, real x1, real y1, real x2, real y2, real width, real dmg, boolean stun, party g returns nothing
        local integer i = 0
        local unit u
        loop
            exitwhen i >= f.memN
            set u = f.mem[i]
            if MemAlive(u) and not IsUnitInGroup(u, g.super) then
                if SegDist(GetUnitX(u), GetUnitY(u), x1, y1, x2, y2) <= width then
                    call GroupAddUnit(g.super, u)
                    call Deal(f, u, dmg, stun)
                endif
            endif
            set i = i + 1
        endloop
        set u = null
    endfunction

    // 사각형: (x, y) 에서 a 방향으로 길이 len, 폭 width. 예고 사각형(TeleRect)과 같은 모양이다
    private function HitRect takes ArcherFight f, real x, real y, real a, real len, real width, real dmg, boolean stun, party g returns nothing
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
                endif
            endif
            set i = i + 1
        endloop
        set u = null
    endfunction

    // ======================================================================
    // 투사체
    // ======================================================================
    private function FreeSlot takes ArcherFight f returns integer
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

    private function ProjKill takes ArcherFight f, integer i returns nothing
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

    private function ProjSpawn takes ArcherFight f, integer kind, string model, real x, real y, real a, real spd, real maxd, real rad, real dmg, real size returns integer
        local integer i = FreeSlot(f)
        if i < 0 then
            return -1
        endif
        set f.pk[i] = kind
        set f.pe[i] = MakeMissile(model, x, y, 90, a, size, null)
        set f.px[i] = x
        set f.py[i] = y
        set f.pox[i] = x
        set f.poy[i] = y
        set f.pdir[i] = a
        set f.pspd[i] = spd
        set f.ptrav[i] = 0
        set f.pmax[i] = maxd
        set f.prad[i] = rad
        set f.pdmg[i] = dmg
        set f.pback[i] = false
        set f.phit[i] = party.create()
        return i
    endfunction

    private function ProjCount takes ArcherFight f, integer kind returns integer
        local integer i = 0
        local integer n = 0
        loop
            exitwhen i >= MAXP
            if f.pk[i] == kind then
                set n = n + 1
            endif
            set i = i + 1
        endloop
        return n
    endfunction

    private function ProjUpdate takes ArcherFight f returns nothing
        local integer i = 0
        local integer wi
        local real ox
        local real oy
        local real step
        local real d
        local real a
        loop
            exitwhen i >= MAXP
            if f.pk[i] != 0 then
                set ox = f.px[i]
                set oy = f.py[i]
                set step = f.pspd[i] * TICK
                if f.pk[i] == 1 and f.pback[i] then
                    // 돌아오는 검: 저장한 원점으로 회수
                    set d = DistancePBP(ox, oy, f.pox[i], f.poy[i])
                    set a = AnglePBP(ox, oy, f.pox[i], f.poy[i])
                    if d <= step then
                        set f.px[i] = f.pox[i]
                        set f.py[i] = f.poy[i]
                    else
                        set f.px[i] = ox + PolarX(step, a)
                        set f.py[i] = oy + PolarY(step, a)
                    endif
                    call EXSetEffectXY(f.pe[i], f.px[i], f.py[i])
                    call HitSweep(f, ox, oy, f.px[i], f.py[i], f.prad[i], f.pdmg[i], true, f.phit[i])
                    if d <= step then
                        // 돌아온 검을 받는 순간
                        call FxAt(FX_FLASH_RED, f.px[i], f.py[i], 0.8, a)
                        call ProjKill(f, i)
                    endif
                else
                    if f.ptrav[i] + step > f.pmax[i] then
                        set step = f.pmax[i] - f.ptrav[i]
                    endif
                    set f.px[i] = ox + PolarX(step, f.pdir[i])
                    set f.py[i] = oy + PolarY(step, f.pdir[i])
                    set f.ptrav[i] = f.ptrav[i] + step
                    call EXSetEffectXY(f.pe[i], f.px[i], f.py[i])
                    // 칼날의 숲 벽에 닿은 화살·저격탄은 막힌다 (벽 뒤에 숨기)
                    if f.forestOn and f.pk[i] != 1 then
                        set wi = 0
                        loop
                            exitwhen wi >= f.kn
                            if SegDist(f.px[i], f.py[i], f.kx[wi], f.ky[wi], f.kx[wi] + PolarX(f.kl[wi], f.ka[wi]), f.ky[wi] + PolarY(f.kl[wi], f.ka[wi])) <= WALL_HALF + 20 then
                                call FxAt(FX_SPARKS, f.px[i], f.py[i], 1.2, f.pdir[i])
                                call FxAt(FX_FLASH_WHITE, f.px[i], f.py[i], 3.0, f.pdir[i])
                                call ProjKill(f, i)
                                set wi = f.kn
                            endif
                            set wi = wi + 1
                        endloop
                    endif
                    if f.pk[i] == 0 then
                        // 막혀 사라짐
                    else
                    // 화살·저격탄·날아가는 검 꼬리: 0.1초마다 작은 붉은 섬광 (투사체마다 틱을 엇갈려 몰리지 않게)
                    if f.pk[i] != 1 and ModuloInteger(R2I(f.now / TICK + 0.5) + i, 5) == 0 then
                        call FxAt(FX_FLASH_RED, f.px[i], f.py[i], 0.5, f.pdir[i])
                    endif
                    call HitSweep(f, ox, oy, f.px[i], f.py[i], f.prad[i], f.pdmg[i], f.pk[i] == 1, f.phit[i])
                    if f.ptrav[i] >= f.pmax[i] - 0.01 then
                        if f.pk[i] == 1 then
                            // 나가는 구간과 돌아오는 구간은 별도 판정
                            set f.pback[i] = true
                            call GroupClear(f.phit[i].super)
                            call EXEffectMatRotateZ(f.pe[i], 180)
                        elseif f.pk[i] == 3 then
                            // 연사 화살·학익삼련 검: 끝까지 날아가면 파편을 튀기며 사라짐
                            call FxAt(FX_SPARKS, f.px[i], f.py[i], 0.7, f.pdir[i])
                            call ProjKill(f, i)
                        else
                            // 저격탄 끝 폭발: 직선과 같은 피격 기록 공유
                            // 충격파 모델은 X축 방향으로 뻗는다 → 화살이 날아온 방향으로 돌린다
                            call FxAt(FX_SNIPE_BOOM, f.px[i], f.py[i], 1.0, f.pdir[i])
                            call FxHitBig(f, f.px[i], f.py[i], f.pdir[i], 1.0)
                            call HitCircle(f, f.px[i], f.py[i], 250, DMG_SNIPE_BOOM, true, f.phit[i])
                            call CameraShaker.setShake(8)
                            call ProjKill(f, i)
                        endif
                    endif
                    endif
                endif
            endif
            set i = i + 1
        endloop
    endfunction

    // ======================================================================
    // 취소·정리
    // ======================================================================
    private function ClearMark takes ArcherFight f returns nothing
        if f.mark != null then
            call DestroyEffect(f.mark)
            set f.mark = null
        endif
    endfunction

    // 가장 가까운 생존 참가자
    private function NearestMem takes ArcherFight f returns unit
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

    private function CueClear takes ArcherFight f returns nothing
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
    endfunction

    private function RhoClear takes ArcherFight f returns nothing
        local integer idx = IndexUnit(f.boss)
        set UnitFrontGuard[idx] = false
        set UnitGuardBackDmg[idx] = 0
        set UnitGuardFrontHits[idx] = 0
        if f.rho != null then
            call DestroyEffect(f.rho)
            set f.rho = null
        endif
    endfunction

    private function HrClear takes ArcherFight f returns nothing
        if f.hEff != null then
            call DestroyEffect(f.hEff)
            set f.hEff = null
        endif
        if f.hLight != null then
            call DestroyLightning(f.hLight)
            set f.hLight = null
        endif
    endfunction

    // 진행 중인 공격 전부 취소 (패턴, 투사체, 장판, 표식, 카운터 창)
    private function CancelAttacks takes ArcherFight f returns nothing
        local integer i = 0
        loop
            exitwhen i >= MAXP
            if f.pk[i] != 0 then
                call ProjKill(f, i)
            endif
            set i = i + 1
        endloop
        call ClearDecals(f)
        call ClearMark(f)
        call CueClear(f)
        if f.boss != null then
            call UnitRemoveAbility(f.boss, 'A00V')
            call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
        endif
        set f.pat = 0
        set f.step = 0
        set f.combo = 0
        set f.dashLeft = 0
        set f.rainSnipe = false
        set f.forestOn = false
        set f.kn = 0
        set f.target = null
        if f.boss != null then
            call RhoClear(f)
        endif
        call HrClear(f)
        set i = 0
        loop
            exitwhen i >= UBW_STUCK_COUNT
            set f.sExp[i] = 0
            set i = i + 1
        endloop
        // 칼날의 숲 벽
        set i = 0
        loop
            exitwhen i >= 96
            if f.wallFx[i] != null then
                call SwordFxRemove(f.wallFx[i])
                set f.wallFx[i] = null
            endif
            set i = i + 1
        endloop
    endfunction

    // ======================================================================
    // 무한의 검제 전장
    // ======================================================================
    private function TerrainApply takes ArcherFight f returns nothing
        local rect r = MapRectReturn(f.rect)
        local real x
        local real y
        local integer k = 0
        if UBW_TILE == 0 or f.terrainChanged then
            set r = null
            return
        endif
        call FlushChildHashtable(TerrainSave, f.rect)
        set y = GetRectMinY(r)
        loop
            exitwhen y > GetRectMaxY(r)
            set x = GetRectMinX(r)
            loop
                exitwhen x > GetRectMaxX(r)
                call SaveInteger(TerrainSave, f.rect, k * 2, GetTerrainType(x, y))
                call SaveInteger(TerrainSave, f.rect, k * 2 + 1, GetTerrainVariance(x, y))
                call SetTerrainType(x, y, UBW_TILE, -1, 1, 0)
                set k = k + 1
                set x = x + 128
            endloop
            set y = y + 128
        endloop
        set f.terrainChanged = true
        set r = null
    endfunction

    private function TerrainRestore takes ArcherFight f returns nothing
        local rect r = MapRectReturn(f.rect)
        local real x
        local real y
        local integer k = 0
        if not f.terrainChanged then
            set r = null
            return
        endif
        set y = GetRectMinY(r)
        loop
            exitwhen y > GetRectMaxY(r)
            set x = GetRectMinX(r)
            loop
                exitwhen x > GetRectMaxX(r)
                call SetTerrainType(x, y, LoadInteger(TerrainSave, f.rect, k * 2), LoadInteger(TerrainSave, f.rect, k * 2 + 1), 1, 0)
                set k = k + 1
                set x = x + 128
            endloop
            set y = y + 128
        endloop
        call FlushChildHashtable(TerrainSave, f.rect)
        set f.terrainChanged = false
        set r = null
    endfunction

    private function StuckSwordRandomPos takes ArcherFight f, integer i returns nothing
        local rect r = MapRectReturn(f.rect)
        set f.sx[i] = GetRandomReal(GetRectMinX(r) + 200, GetRectMaxX(r) - 200)
        set f.sy[i] = GetRandomReal(GetRectMinY(r) + 200, GetRectMaxY(r) - 200)
        set r = null
    endfunction

    private function StuckSwordAt takes ArcherFight f, integer i returns nothing
        set f.sExp[i] = 0
        set f.stuck[i] = AddSpecialEffect(FX_SWORD_STUCK, f.sx[i], f.sy[i])
        call EXEffectMatRotateZ(f.stuck[i], GetRandomReal(0, 360))
    endfunction

    private function StuckSwordPlace takes ArcherFight f, integer i returns nothing
        call StuckSwordRandomPos(f, i)
        call StuckSwordAt(f, i)
    endfunction

    // 남은 검 수 = 아쳐의 탄약
    private function StockCount takes ArcherFight f returns integer
        local integer i = 0
        local integer n = 0
        loop
            exitwhen i >= UBW_STUCK_COUNT
            if f.stuck[i] != null then
                set n = n + 1
            endif
            set i = i + 1
        endloop
        return n
    endfunction

    // 검 하나를 없앤다 (빛 표시도 같이)
    private function StuckSwordRemove takes ArcherFight f, integer i returns nothing
        if f.stuck[i] != null then
            call SwordFxRemove(f.stuck[i])
            set f.stuck[i] = null
        endif
        if f.sGlow[i] != null then
            call DestroyEffect(f.sGlow[i])
            set f.sGlow[i] = null
        endif
    endfunction

    private function StuckSwordsCreate takes ArcherFight f returns nothing
        local integer i = 0
        loop
            exitwhen i >= UBW_STUCK_COUNT
            call StuckSwordPlace(f, i)
            set i = i + 1
        endloop
    endfunction

    // 부서진 검을 새 자리에 다시 꽂는다 (검이 떨어지는 연출과 함께)
    private function StuckSwordsRefill takes ArcherFight f returns nothing
        local integer i = 0
        loop
            exitwhen i >= UBW_STUCK_COUNT
            if f.stuck[i] == null then
                call StuckSwordPlace(f, i)
                call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, f.sx[i], f.sy[i]))
            endif
            set i = i + 1
        endloop
    endfunction

    // 하늘의 톱니바퀴 4개: 전장 네 귀퉁이 위 높이 900, 비스듬히 기울여 천천히 돈다
    private function GearsCreate takes ArcherFight f returns nothing
        local rect r = MapRectReturn(f.rect)
        local integer i = 0
        local real x
        local real y
        loop
            exitwhen i >= 4
            if f.gear[i] == null then
                set x = f.arenaCX() + PolarX((GetRectMaxX(r) - GetRectMinX(r)) * 0.35, 45 + 90 * i)
                set y = f.arenaCY() + PolarY((GetRectMaxY(r) - GetRectMinY(r)) * 0.35, 45 + 90 * i)
                set f.gear[i] = AddSpecialEffect(FX_GEAR, x, y)
                call EXSetEffectSize(f.gear[i], 6.0 + i)
                call EXEffectMatRotateX(f.gear[i], 60)
                call EXEffectMatRotateZ(f.gear[i], 45 + 90 * i)
                call MoveLocation(TmpLoc, x, y)
                call EXSetEffectZ(f.gear[i], GetLocationZ(TmpLoc) + 900)
            endif
            set i = i + 1
        endloop
        set r = null
    endfunction

    private function GearsDestroy takes ArcherFight f returns nothing
        local integer i = 0
        loop
            exitwhen i >= 4
            if f.gear[i] != null then
                call DestroyEffect(f.gear[i])
                set f.gear[i] = null
            endif
            set i = i + 1
        endloop
    endfunction

    private function StuckSwordsDestroy takes ArcherFight f returns nothing
        local integer i = 0
        call GearsDestroy(f)
        loop
            exitwhen i >= UBW_STUCK_COUNT
            call StuckSwordRemove(f, i)
            set f.sFall[i] = 0
            set f.sExp[i] = 0
            set i = i + 1
        endloop
    endfunction

    // 참가자 화면에만 적용 (색 변화·하늘). 게임 상태는 바꾸지 않는다
    private function LocalFilter takes ArcherFight f, boolean on, real dur returns nothing
        local integer i = 0
        loop
            exitwhen i >= f.memN
            if f.mem[i] != null and GetLocalPlayer() == GetOwningPlayer(f.mem[i]) then
                if on then
                    call SetCineFilterTexture("ReplaceableTextures\\CameraMasks\\White_mask.blp")
                    call SetCineFilterBlendMode(BLEND_MODE_BLEND)
                    call SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
                    call SetCineFilterStartUV(0, 0, 1, 1)
                    call SetCineFilterEndUV(0, 0, 1, 1)
                    call SetCineFilterStartColor(255, 255, 255, 0)
                    call SetCineFilterEndColor(255, 90, 40, 110)
                    call SetCineFilterDuration(dur)
                    call DisplayCineFilter(true)
                    if UBW_SKY != "" then
                        call SetSkyModel(UBW_SKY)
                    endif
                else
                    call DisplayCineFilter(false)
                    if UBW_SKY != "" then
                        call SetSkyModel(UBW_SKY_RESTORE)
                    endif
                endif
            endif
            set i = i + 1
        endloop
    endfunction

    // ======================================================================
    // 패턴 시작·종료
    // ======================================================================
    private function PatternEnd takes ArcherFight f, real rest returns nothing
        if f.state == ARCHER_PHASE2 then
            set rest = rest * PHASE2_REST_RATE
        endif
        call ClearDecals(f)
        call ClearMark(f)
        call UnitRemoveAbility(f.boss, 'A00V')
        call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
        set f.pat = 0
        set f.step = 0
        set f.target = null
        set f.nextSelect = f.now + rest
        call AnimIdle(f)
    endfunction

    // 패턴 이름 (보스 머리 위에 표시)
    private function PatName takes ArcherFight f, integer id returns string
        if id == 1 then
            if f.state == ARCHER_PHASE2 then
                return "연사"
            endif
            return "간장·막야 연격"
        elseif id == 2 then
            return "회귀하는 쌍검"
        elseif id == 3 then
            return "칼라드볼그"
        elseif id == 4 then
            return "심안·역습"
        elseif id == 5 then
            return "검의 비"
        elseif id == 6 then
            return "검의 포위"
        elseif id == 8 then
            return "로 아이아스"
        elseif id == 9 then
            return "부서진 환상"
        elseif id == 10 then
            return "붉은 사냥개"
        elseif id == 11 then
            return "학익삼련"
        elseif id == 12 then
            return "검의 사출"
        elseif id == 13 then
            return "칼날의 숲"
        elseif id == 14 then
            return "투영 복제"
        elseif id == 16 then
            return "전검 사출"
        elseif id == 20 then
            return "검의 강하"
        endif
        return ""
    endfunction

    // 보스 머리 위 패턴 이름: 기본 패턴 흰색, 큰 패턴 주황, 체력 기믹(전검 사출) 붉은색·크게. 1.8초, 보스를 따라감.
    // 한 번에 하나만 (새 이름이 나오면 앞의 것은 지움). 큰 패턴은 화면 가운데 안내도 (이미 안내 문구가 있는 패턴은 제외)
    private function ShowPatName takes ArcherFight f, integer id returns nothing
        local string n = PatName(f, id)
        if n == "" or f.boss == null then
            return
        endif
        if f.patTag != null and f.now < f.patTagEnd then
            call DestroyTextTag(f.patTag)
        endif
        set f.patTag = CreateTextTag()
        if id == 16 then
            call SetTextTagText(f.patTag, n, 0.036)
            call SetTextTagColor(f.patTag, 255, 60, 60, 255)
        elseif id == 4 or id == 5 or id == 6 or id >= 8 then
            call SetTextTagText(f.patTag, n, 0.030)
            call SetTextTagColor(f.patTag, 255, 150, 40, 255)
            if id == 4 or id == 6 or id == 11 or id == 12 or id == 14 then
                call MsgAll(f, "|cFFFF9628" + n + "|r", 2.0)
            endif
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

    // 이름이 보스를 따라가며 조금씩 올라간다
    private function PatNameFollow takes ArcherFight f returns nothing
        if f.patTag == null then
            return
        endif
        if f.now >= f.patTagEnd then
            set f.patTag = null
            return
        endif
        call SetTextTagPos(f.patTag, GetUnitX(f.boss) - 60, GetUnitY(f.boss), 300 + 30 * (1.8 - (f.patTagEnd - f.now)))
    endfunction

    private function StartPattern takes ArcherFight f, integer id returns nothing
        local real a
        if f.walking then
            set f.walking = false
            call AnimIdle(f)
        endif
        set f.pat = id
        set f.step = 0
        set f.patStart = f.now
        call ShowPatName(f, id)
        if f.combo == 0 then
            if f.state == ARCHER_PHASE2 then
                set f.readyAt[id] = f.now + PatCool[id] * PHASE2_COOL_RATE
            else
                set f.readyAt[id] = f.now + PatCool[id]
            endif
            set f.lastPat = id
        endif
        set f.snipeLeft = 0
        set f.wave = 0
        if f.state == ARCHER_PHASE2 and not f.saidKeepUp and f.now >= f.voiceUntil then
            set f.saidKeepUp = true
            call Voice(f, VO_KEEPUP, VO_KEEPUP_T)
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

    // 대상 거리에 맞춘 가중치: 바로 앞 대상에게 저격하거나, 아무도 없는 곳에 검의 포위를 펼치지 않게
    private function PatWeightAt takes ArcherFight f, integer i, real d returns integer
        local integer w = PatWeight[i]
        if i == 3 and d < 350 then
            // 칼라드볼그: 붙어 있으면 거의 쓰지 않는다
            return w / 4
        elseif i == 6 and d > 1100 then
            // 검의 포위(보스 중심 반경 1000): 대상이 범위 밖
            return w / 4
        elseif i == 1 and f.state == ARCHER_PHASE2 and d < 200 then
            // 연사: 코앞에서는 덜 쓴다
            return w / 2
        elseif i == 4 and d > 900 then
            // 심안·역습: 돌진 거리(500) 밖이면 덜 쓴다
            return w / 2
        endif
        return w
    endfunction

    // 다음 패턴 선택: 상태·전환 예약·쿨다운 확인 → 직전 패턴 제외 → 가중치 추첨 (대상 거리 반영)
    private function SelectPattern takes ArcherFight f returns nothing
        local integer i = 1
        local integer total = 0
        local integer n = 0
        local integer roll
        local integer last = f.lastPat
        local boolean ok
        local unit u
        local real d = 500

        if f.pat != 0 or (f.state != ARCHER_PHASE1 and f.state != ARCHER_PHASE2) then
            return
        endif
        set u = PickTarget(f)
        if u == null then
            return
        endif
        set d = DistancePBP(GetUnitX(f.boss), GetUnitY(f.boss), GetUnitX(u), GetUnitY(u))
        set u = null
        // 검제 연속 공격 진행 중: 다음 단계
        if f.combo == 2 then
            call StartPattern(f, 3)
            return
        elseif f.combo == 3 then
            call StartPattern(f, 4)
            return
        endif

        // 첫 전투 첫 바퀴는 A1 → A2 → A3 순서로 보여 준다
        if f.state == ARCHER_PHASE1 and f.introIdx < 3 then
            set f.introIdx = f.introIdx + 1
            call StartPattern(f, f.introIdx)
            return
        endif

        // 후보 수 (직전 패턴 제외 여부 판단용)
        loop
            exitwhen i > PAT_MAX
            set ok = f.now >= f.readyAt[i]
            if i >= 5 and f.state != ARCHER_PHASE2 then
                set ok = false
            endif
            // 결계가 있어야 쓰는 패턴 (검의 비, 검제 연속 공격, 부서진 환상, 학익삼련, 검의 사출, 칼날의 숲, 투영 복제)
            if not f.ubw and (i == 5 or i == 7 or i == 9 or i >= 11) then
                set ok = false
            endif
            if i == 7 and UnitHP[IndexUnit(f.boss)] > UnitHPMAX[IndexUnit(f.boss)] * 0.30 then
                set ok = false
            endif
            if ok then
                set n = n + 1
            endif
            set i = i + 1
        endloop
        if n <= 1 then
            set last = 0
        endif

        set i = 1
        loop
            exitwhen i > PAT_MAX
            set ok = f.now >= f.readyAt[i] and i != last
            if i >= 5 and f.state != ARCHER_PHASE2 then
                set ok = false
            endif
            // 결계가 있어야 쓰는 패턴 (검의 비, 검제 연속 공격, 부서진 환상, 학익삼련, 검의 사출, 칼날의 숲, 투영 복제)
            if not f.ubw and (i == 5 or i == 7 or i == 9 or i >= 11) then
                set ok = false
            endif
            if i == 7 and UnitHP[IndexUnit(f.boss)] > UnitHPMAX[IndexUnit(f.boss)] * 0.30 then
                set ok = false
            endif
            if ok then
                set total = total + PatWeightAt(f, i, d)
            endif
            set i = i + 1
        endloop
        if total <= 0 then
            return
        endif

        set roll = GetRandomInt(1, total)
        set i = 1
        loop
            exitwhen i > PAT_MAX
            set ok = f.now >= f.readyAt[i] and i != last
            if i >= 5 and f.state != ARCHER_PHASE2 then
                set ok = false
            endif
            // 결계가 있어야 쓰는 패턴 (검의 비, 검제 연속 공격, 부서진 환상, 학익삼련, 검의 사출, 칼날의 숲, 투영 복제)
            if not f.ubw and (i == 5 or i == 7 or i == 9 or i >= 11) then
                set ok = false
            endif
            if i == 7 and UnitHP[IndexUnit(f.boss)] > UnitHPMAX[IndexUnit(f.boss)] * 0.30 then
                set ok = false
            endif
            if ok and PatWeightAt(f, i, d) > 0 then
                set roll = roll - PatWeightAt(f, i, d)
                if roll <= 0 then
                    if i == 7 then
                        // A7 검제 연속 공격: 검의 비 → 저격 → 심안·역습 → 긴 후딜
                        set f.readyAt[7] = f.now + PatCool[7]
                        set f.lastPat = 7
                        set f.combo = 1
                        set f.rainWaves = 3
                        call MsgAll(f, "|cFFFF4040검제 연속 공격|r", 3.0)
                        call StartPattern(f, 5)
                    else
                        call StartPattern(f, i)
                    endif
                    return
                endif
            endif
            set i = i + 1
        endloop
    endfunction

    // 패턴 하나가 끝났을 때. A7 진행 중이면 다음 단계로 넘긴다
    private function PatternDone takes ArcherFight f, real rest returns nothing
        if f.combo == 1 then
            // 다음 단계(저격)는 COMBO_GAP 뒤 SelectPattern 에서 시작
            set f.combo = 2
            call PatternEnd(f, COMBO_GAP)
        elseif f.combo == 2 then
            set f.combo = 3
            call PatternEnd(f, COMBO_GAP)
        elseif f.combo == 3 then
            set f.combo = 0
            call PatternEnd(f, 3.0)
            // 집중 공격 기회: 제자리에서 움직이지 않는다
            call AnimDown(f)
            set f.holdUntil = f.now + 3.0
        else
            call PatternEnd(f, rest)
        endif
    endfunction

    // ======================================================================
    // A1. 간장·막야 연격
    // ======================================================================
    private function RunA1 takes ArcherFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local real nx
        local real ny
        local real step
        if f.step == 0 then
            // 대상이 베기 거리 밖이면 먼저 뛰어들어 붙는다 (붙은 뒤부터 원래 시간표)
            if f.wave == 0 and MemAlive(f.target) and DistancePBP(bx, by, GetUnitX(f.target), GetUnitY(f.target)) > A1_GAP then
                set f.wave = 1
                set f.ang = AngleWBW(f.boss, f.target)
                call Face(f, f.ang)
                set f.dashLeft = RMinBJ(700, DistancePBP(bx, by, GetUnitX(f.target), GetUnitY(f.target)) - A1_GAP_STOP)
                set f.dashSpeed = A1_GAP_SPEED
                call Anim(f, AN_STAND_READY, 1.0)
                call FxDash(f)
                set f.step = 10
                return
            endif
            // 첫 베기: attack 1 타격(0.38초)이 0.9초 판정에 맞도록 느리게 (동작이 예고 역할)
            call Anim(f, AN_ATTACK1, 0.38 / 0.9)
            call FxWindup(f)
            set f.step = 1
        elseif f.step == 10 then
            // 뛰어들기: 피해 없음. 끝나면 대상을 보고 원래 시간표를 처음부터
            set step = RMinBJ(f.dashLeft, f.dashSpeed * TICK)
            set nx = ClampX(f, bx + PolarX(step, f.ang))
            set ny = ClampY(f, by + PolarY(step, f.ang))
            call SetUnitPosition(f.boss, nx, ny)
            set f.dashLeft = f.dashLeft - step
            if f.dashLeft <= 0 or (nx == bx and ny == by) then
                if MemAlive(f.target) then
                    set f.ang = AngleWBW(f.boss, f.target)
                endif
                call Face(f, f.ang)
                set f.patStart = f.now
                set f.step = 0
            endif
        elseif f.step == 1 and el < A1_TRACK then
            // 준비 동작 앞부분: 대상을 따라 돈다
            if MemAlive(f.target) then
                call TurnToward(f, AngleWBW(f.boss, f.target), IDLE_TURN * TICK)
                set f.ang = f.face
            endif
        elseif f.step == 1 and el >= 0.9 then
            call HitFan(f, bx, by, f.ang, SLASH_RANGE, SLASH_HALF, DMG_SLASH, false)
            call FxCut(bx, by, f.ang, 0, 15, SLASH_RANGE, false)
            call FxHitSmall(bx + PolarX(260, f.ang), by + PolarY(260, f.ang), f.ang)
            // 두 번째 베기는 대상을 다시 바라본다
            if MemAlive(f.target) then
                set f.ang = AngleWBW(f.boss, f.target)
                call Face(f, f.ang)
            endif
            // 두 번째 베기: attack 2 타격(0.35초)이 0.9초 뒤 판정에 맞도록 느리게
            call Anim(f, AN_ATTACK2, 0.35 / 0.9)
            set f.step = 2
        elseif f.step == 2 and el >= 1.8 then
            call HitFan(f, bx, by, f.ang, SLASH_RANGE, SLASH_HALF, DMG_SLASH, false)
            call FxCut(bx, by, f.ang, 0, -15, SLASH_RANGE, true)
            call FxHitSmall(bx + PolarX(260, f.ang), by + PolarY(260, f.ang), f.ang)
            // 마지막 돌진 방향 고정. 이후 대상을 추적하지 않는다
            if MemAlive(f.target) then
                set f.ang = AngleWBW(f.boss, f.target)
            endif
            call Face(f, f.ang)
            call Anim(f, AN_STAND_READY, 1.0)
            // 돌진 시작점 고정: 예고와 판정이 같은 사각형을 쓴다
            set f.ax = bx
            set f.ay = by
            call TeleLine(f, bx, by, f.ang, 450 + DASH_REACH, DASH_WIDTH, 1.0)
            set f.step = 3
        elseif f.step == 3 and el >= 2.8 then
            // 돌진 베기: 쌍검 attack 1 을 1.5배속으로, 0.25초 돌진 끝에 베기가 닿는다
            call Anim(f, AN_ATTACK1, 1.5)
            set f.dashLeft = 450
            set f.dashSpeed = 450 / 0.25
            call Voice(f, VO_ASIDE, VO_ASIDE_T)
            call FxDash(f)
            set f.step = 4
        elseif f.step == 4 then
            set step = RMinBJ(f.dashLeft, f.dashSpeed * TICK)
            set nx = ClampX(f, bx + PolarX(step, f.ang))
            set ny = ClampY(f, by + PolarY(step, f.ang))
            call SetUnitPosition(f.boss, nx, ny)
            // 시작점부터 지금 위치 + 베기 거리까지 (뒤쪽은 맞지 않음)
            call HitRect(f, f.ax, f.ay, f.ang, DistancePBP(f.ax, f.ay, nx, ny) + DASH_REACH, DASH_WIDTH, DMG_DASH, true, f.hit)
            set f.dashLeft = f.dashLeft - step
            if f.dashLeft <= 0 then
                // 돌진 끝 베기 자국
                call FxCut(nx, ny, f.ang, 0, 20, SLASH_RANGE * 0.8, false)
                call FxHitSmall(nx + PolarX(DASH_REACH, f.ang), ny + PolarY(DASH_REACH, f.ang), f.ang)
                set f.step = 5
            endif
        elseif f.step == 5 and el >= 3.6 then
            call PatternDone(f, REST_SHORT)
        endif
    endfunction

    // ======================================================================
    // A2. 회귀하는 쌍검
    // ======================================================================
    private function RunA2 takes ArcherFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        if f.step == 0 then
            set f.ax = bx
            set f.ay = by
            // 예고 동안 쌍검 준비 자세
            call Anim(f, AN_STAND_READY, 1.0)
            // 검 비행 거리 900 + 판정 반경 90, 폭 = 반경 × 2
            call TeleLine(f, bx, by, f.ang - 20, 990, 180, 1.0)
            call TeleLine(f, bx, by, f.ang + 20, 990, 180, 1.0)
            if f.state == ARCHER_PHASE2 then
                // 2페이즈: 바깥쪽으로 한 쌍 더
                call TeleLine(f, bx, by, f.ang - 45, 990, 180, 1.0)
                call TeleLine(f, bx, by, f.ang + 45, 990, 180, 1.0)
            endif
            set f.step = 1
        elseif f.step == 1 and el >= 0.8 then
            // spell three: 검을 던지는 동작. 손을 떠나는 시점(약 0.2초)에 투사체 생성
            call Anim(f, AN_SPELL_THREE, 1.0)
            call FxWindup(f)
            set f.step = 2
        elseif f.step == 2 and el >= 1.0 then
            call ProjSpawn(f, 1, FX_THROW_KANSHOU, f.ax, f.ay, f.ang - 20, 1100, 900, 90, DMG_THROW, FX_THROW_SIZE)
            call FxMuzzle(f, f.ang)
            call ProjSpawn(f, 1, FX_THROW_BAKUYA, f.ax, f.ay, f.ang + 20, 1100, 900, 90, DMG_THROW, FX_THROW_SIZE)
            if f.state == ARCHER_PHASE2 then
                call ProjSpawn(f, 1, FX_THROW_KANSHOU, f.ax, f.ay, f.ang - 45, 1100, 900, 90, DMG_THROW, FX_THROW_SIZE)
                call ProjSpawn(f, 1, FX_THROW_BAKUYA, f.ax, f.ay, f.ang + 45, 1100, 900, 90, DMG_THROW, FX_THROW_SIZE)
            endif
            set f.step = 3
        elseif f.step == 3 and ProjCount(f, 1) == 0 then
            // 검 회수 후 접근해서 공격할 시간 (쌍검을 다시 쥔 대기 자세)
            set f.patStart = f.now
            call AnimIdle(f)
            set f.step = 4
        elseif f.step == 4 and el >= 1.2 then
            call PatternDone(f, REST_SHORT)
        endif
    endfunction

    // ======================================================================
    // A3. 위·나선검 저격
    // ======================================================================
    private function RunA3 takes ArcherFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local integer k
        if f.step == 0 then
            if f.snipeLeft == 0 then
                // 2페이즈는 두 번 연속 저격
                if f.state == ARCHER_PHASE2 then
                    set f.snipeLeft = 2
                else
                    set f.snipeLeft = 1
                endif
            endif
            set k = PickSnipeTarget(f)
            if k < 0 then
                call PatternDone(f, REST_SHORT)
                return
            endif
            set f.markCount[k] = f.markCount[k] + 1
            set f.target = f.mem[k]
            call ClearMark(f)
            set f.mark = AddSpecialEffectTarget(FX_SNIPE_MARK, f.target, "overhead")
            call Anim(f, AN_CHANNEL_FOUR, 1.0)
            call Voice(f, VO_BONE, VO_BONE_T)
            call DestroyEffect(AddSpecialEffect(FX_CHARGE, GetUnitX(f.boss), GetUnitY(f.boss)))
            // 활 조준: 붉은 빛이 활 쪽으로 감겨 모인다 (F4313, Birth 1.77초 한 번)
            call FxAt(FX_BOW_CHARGE, GetUnitX(f.boss), GetUnitY(f.boss), 0.6, f.ang)
            set f.step = 1
        elseif f.step == 1 then
            // 조준 중에는 대상을 바라본다
            if MemAlive(f.target) then
                set f.ang = AngleWBW(f.boss, f.target)
                set f.tx = GetUnitX(f.target)
                set f.ty = GetUnitY(f.target)
                call Face(f, f.ang)
            endif
            if el >= 1.0 then
                // 마지막 1.0초: 방향과 목표 좌표 고정 (회피 0.31초 + 반응 시간)
                call TeleLine(f, bx, by, f.ang, DistancePBP(bx, by, f.tx, f.ty), 180, 1.0)
                call Decal(f, f.tx, f.ty, 250, 1.0, 0)
                set f.step = 2
            endif
        elseif f.step == 2 and el >= 2.0 then
            call ClearMark(f)
            call Anim(f, AN_CHANNEL_FIVE, 1.0)
            call VoiceCalad(f)
            call FxMuzzle(f, f.ang)
            call ProjSpawn(f, 2, FX_SNIPE_BOLT, bx, by, f.ang, 3000, RMaxBJ(50, DistancePBP(bx, by, f.tx, f.ty)), 90, DMG_SNIPE, 1.4)
            set f.step = 3
        elseif f.step == 3 and ProjCount(f, 2) == 0 then
            set f.patStart = f.now
            set f.step = 4
        elseif f.step == 4 and f.snipeLeft > 1 and el >= 0.4 then
            // 다음 저격
            set f.snipeLeft = f.snipeLeft - 1
            set f.patStart = f.now
            set f.step = 0
        elseif f.step == 4 and el >= 1.0 then
            call PatternDone(f, REST_SHORT)
        endif
    endfunction

    // ======================================================================
    // A4. 심안·역습 (마지막 역베기에 정면 카운터 가능)
    // ======================================================================
    private function RunA4 takes ArcherFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local real nx
        local real ny
        local real step
        if f.step == 0 then
            // 방어 자세: 쌍검 준비 자세 + 푸른 빛
            call Anim(f, AN_STAND_READY, 1.0)
            call SetUnitVertexColor(f.boss, 200, 200, 255, 255)
            set f.step = 1
        elseif f.step == 1 and el >= 0.8 then
            if MemAlive(f.target) then
                set f.ang = AngleWBW(f.boss, f.target)
            endif
            call Face(f, f.ang)
            set f.ax = bx
            set f.ay = by
            // 대상 앞 COUNTER_DASH_STOP 에서 멈춘다 (0 ~ 500)
            set f.dashLen = 500
            if MemAlive(f.target) then
                set f.dashLen = RMaxBJ(0, RMinBJ(500, DistancePBP(bx, by, GetUnitX(f.target), GetUnitY(f.target)) - COUNTER_DASH_STOP))
            endif
            call TeleLine(f, bx, by, f.ang, f.dashLen + DASH_REACH, DASH_WIDTH, 1.0)
            set f.step = 2
        elseif f.step == 2 and el >= 1.8 then
            // 돌진 베기: attack 1 을 1.5배속으로, 돌진 끝에 베기가 닿는다
            call Anim(f, AN_ATTACK1, 1.5)
            set f.dashLeft = f.dashLen
            set f.dashSpeed = 500 / 0.25
            call FxDash(f)
            set f.step = 3
        elseif f.step == 3 then
            set step = RMinBJ(f.dashLeft, f.dashSpeed * TICK)
            set nx = ClampX(f, bx + PolarX(step, f.ang))
            set ny = ClampY(f, by + PolarY(step, f.ang))
            call SetUnitPosition(f.boss, nx, ny)
            // 카운터를 노릴 수 있도록 심안 돌진은 기절 없이 피해만 준다
            call HitRect(f, f.ax, f.ay, f.ang, DistancePBP(f.ax, f.ay, nx, ny) + DASH_REACH, DASH_WIDTH, DMG_DASH, false, f.hit)
            set f.dashLeft = f.dashLeft - step
            if f.dashLeft <= 0 then
                // 카운터 가능 구간 시작: 대상(없으면 가장 가까운 참가자)을 정면으로 본다
                set f.patStart = f.now
                if not MemAlive(f.target) then
                    set f.target = NearestMem(f)
                endif
                if MemAlive(f.target) then
                    set f.ang = AngleWBW(f.boss, f.target)
                endif
                call Face(f, f.ang)
                // 역베기 준비: attack 2 타격(0.35초)이 창 끝에 맞도록 느리게 재생
                // 느린 준비 동작: 창이 끝날 때 타격 직전(COUNTER_WINDUP)에 닿는다
                call Anim(f, AN_ATTACK2, COUNTER_WINDUP / COUNTER_WINDOW)
                call UnitAddAbility(f.boss, 'A00V')
                // 다른 보스와 같은 카운터 신호
                call SetUnitVertexColorBJ(f.boss, 70, 70, 100, 0)
                set f.cue[0] = UnitEffectTimeEX('e00F', nx, ny, 0, 3)
                set f.cue[1] = UnitEffectTimeEX('e00G', nx, ny, 0, 3)
                set f.cue[2] = UnitEffectTimeEX('e01S', nx, ny, 0, 3)
                call DestroyEffect(AddSpecialEffectTarget(FX_COUNTER_READY, f.boss, "origin"))
                call FxWindup(f)
                // 역베기: 바라보는 방향의 앞쪽 사각형. 판정도 같은 사각형(HitRect)이다
                // 역베기: 바라보는 방향의 앞쪽 반원 (판정도 같은 반원 HitFan 반각 90도)
                call TeleHalf(f, nx, ny, f.ang, COUNTER_LEN, COUNTER_WINDOW + 0.35 - COUNTER_WINDUP)
                set f.step = 4
            endif
        elseif f.step == 4 then
            if GetUnitAbilityLevel(f.boss, 'A00V') == 0 then
                // 카운터 성공: 공격 취소, 약 3초 그로기
                call ClearDecals(f)
                call CueClear(f)
                call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
                call Sound3D(f.boss, 'A00U')
                call VoiceHit(f)
                // 그로기: 무기를 놓친 빈손 자세 (stand slam 반복)
                call AnimDown(f)
                set f.patStart = f.now
                set f.step = 6
            elseif el >= COUNTER_WINDOW then
                // 카운터 실패: 동작을 원래 속도로 되돌려 빠르게 벤다
                call UnitRemoveAbility(f.boss, 'A00V')
                call CueClear(f)
                call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
                call SetUnitTimeScale(f.boss, 1.0)
                set f.animEnd = f.now + AnimDur[AN_ATTACK2] - COUNTER_WINDUP
                set f.patStart = f.now
                set f.step = 7
            endif
        elseif f.step == 7 and el >= 0.35 - COUNTER_WINDUP then
            // 원래 속도의 타격 프레임
            call Voice(f, VO_GOTYOU, VO_GOTYOU_T)
            call HitFan(f, bx, by, f.ang, COUNTER_LEN, 90, DMG_COUNTER, true)
            // 앞쪽 반원을 휩쓰는 베기: 왼쪽·가운데·오른쪽
            call FxCut(bx, by, f.ang - 55, 0, 12, COUNTER_LEN, false)
            call FxCut(bx, by, f.ang, 0, -12, COUNTER_LEN, true)
            call FxCut(bx, by, f.ang + 55, 0, 12, COUNTER_LEN, false)
            call FxHitBig(f, bx + PolarX(280, f.ang), by + PolarY(280, f.ang), f.ang, 1.2)
            set f.patStart = f.now
            set f.step = 5
        elseif f.step == 5 and el >= 1.5 then
            call PatternDone(f, REST_BIG)
        elseif f.step == 6 and el >= 3.0 then
            // 카운터 성공 그로기 뒤
            call PatternDone(f, REST_SHORT)
        endif
    endfunction

    // ======================================================================
    // A5. 검의 비 (2페이즈) - 전장을 통로로 나누고 안전 통로가 한 칸씩 이동
    // ======================================================================
    private function RainHalf takes ArcherFight f returns real
        local rect r = MapRectReturn(f.rect)
        local real h
        if ModuloReal(f.rainAng, 180) < 1 then
            // 통로가 동서로 길다 → 남북으로 나눈다
            set h = (GetRectMaxY(r) - GetRectMinY(r)) * 0.5
        else
            set h = (GetRectMaxX(r) - GetRectMinX(r)) * 0.5
        endif
        set r = null
        return h
    endfunction

    private function RainLen takes ArcherFight f returns real
        local rect r = MapRectReturn(f.rect)
        local real h
        if ModuloReal(f.rainAng, 180) < 1 then
            set h = (GetRectMaxX(r) - GetRectMinX(r)) * 0.5
        else
            set h = (GetRectMaxY(r) - GetRectMinY(r)) * 0.5
        endif
        set r = null
        return h
    endfunction

    // 통로 번호 lane 의 중심 좌표 (중심선 방향 rainAng, 폭 방향 rainAng+90)
    private function LaneOffset takes ArcherFight f, integer lane returns real
        local real w = RainHalf(f) * 2 / RAIN_LANES
        return -RainHalf(f) + w * (lane + 0.5)
    endfunction

    // 통로 예고: 안전 통로(초록)만 그린다. 나머지 전장 전체가 위험 구역이다.
    // 전장을 덮는 빨간 장판을 매 파동 다시 만들면 바닥 전체가 깜빡이므로 그리지 않고,
    // 이전 파동의 장판은 사라지는 동작 없이 먼저 지운 뒤 새로 그린다
    private function RainTelegraph takes ArcherFight f, real time returns nothing
        local real cx = f.arenaCX()
        local real cy = f.arenaCY()
        local real w = RainHalf(f) * 2 / RAIN_LANES
        local real len = RainLen(f)
        local real off = LaneOffset(f, f.rainSafe)
        local real sx = cx + PolarX(off, f.rainAng + 90) + PolarX(-len, f.rainAng)
        local real sy = cy + PolarY(off, f.rainAng + 90) + PolarY(-len, f.rainAng)
        call ForGroup(f.rainDecals, function ClearDecalsEnum)
        call GroupClear(f.rainDecals)
        set DecalCapture = f.rainDecals
        call DecalLine(f, sx, sy, f.rainAng, len * 2, w * 0.9, time, 3)
        set DecalCapture = null
    endfunction

    private function RainStrike takes ArcherFight f returns nothing
        local real cx = f.arenaCX()
        local real cy = f.arenaCY()
        local real half = RainHalf(f)
        local real w = half * 2 / RAIN_LANES
        local real len = RainLen(f)
        local integer i = 0
        local integer lane
        local real perp
        local unit u
        local real off
        local integer k
        local real fx
        local real fy
        // 낙하 연출
        set lane = 0
        loop
            exitwhen lane >= RAIN_LANES
            if lane != f.rainSafe then
                set off = LaneOffset(f, lane)
                set k = 0
                loop
                    exitwhen k >= 4
                    set fy = GetRandomReal(-len, len)
                    set fx = cx + PolarX(off, f.rainAng + 90) + PolarX(fy, f.rainAng)
                    set fy = cy + PolarY(off, f.rainAng + 90) + PolarY(fy, f.rainAng)
                    call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, fx, fy))
                    call FxAt(FX_DUST, fx, fy, 1.0, 0)
                    if k == 0 then
                        call FxAt(FX_SPARKS, fx, fy, 1.0, 0)
                        call FxAt(FX_FLASH_RED, fx, fy, 1.0, 0)
                    endif
                    set k = k + 1
                endloop
            endif
            set lane = lane + 1
        endloop
        // 판정: 안전 통로 밖이면 피해
        loop
            exitwhen i >= f.memN
            set u = f.mem[i]
            if MemAlive(u) then
                set perp = (GetUnitX(u) - cx) * Cos((f.rainAng + 90) * bj_DEGTORAD) + (GetUnitY(u) - cy) * Sin((f.rainAng + 90) * bj_DEGTORAD)
                set lane = R2I((perp + half) / w)
                if perp + half < 0 then
                    set lane = -1
                endif
                if lane != f.rainSafe then
                    call Deal(f, u, DMG_RAIN, true)
                endif
            endif
            set i = i + 1
        endloop
        call CameraShaker.setShake(6)
        set u = null
    endfunction

    private function RunA5 takes ArcherFight f, real el returns nothing
        local integer k
        if f.step == 0 then
            if f.rainWaves <= 0 then
                set f.rainWaves = 4
            endif
            if GetRandomInt(0, 1) == 0 then
                set f.rainAng = 0
            else
                set f.rainAng = 90
            endif
            set f.rainSafe = GetRandomInt(0, RAIN_LANES - 1)
            set f.rainWave = 0
            // 처음은 단독, 이후에는 저격 하나와 조합 (A7 진행 중 제외)
            set f.rainSnipe = f.rainUsed >= 1 and f.combo == 0
            set f.rainUsed = f.rainUsed + 1
            call Anim(f, AN_SPELL_ALT_THREE, 1.0)
            call MsgAll(f, "|cFFFF8040검의 비|r - 초록 통로로 이동하세요.", 3.0)
            call RainTelegraph(f, RAIN_FIRST_WARN)
            set f.rainNext = f.now + RAIN_FIRST_WARN
            set f.step = 1
        elseif f.step == 1 then
            if f.rainSnipe and f.rainWave == 1 and f.mark == null and f.now >= f.rainNext - RAIN_NEXT_WARN + 0.3 then
                set k = PickSnipeTarget(f)
                if k >= 0 then
                    set f.markCount[k] = f.markCount[k] + 1
                    set f.target = f.mem[k]
                    set f.tx = GetUnitX(f.target)
                    set f.ty = GetUnitY(f.target)
                    set f.mark = AddSpecialEffectTarget(FX_SNIPE_MARK, f.target, "overhead")
                    set f.ang = AnglePBP(GetUnitX(f.boss), GetUnitY(f.boss), f.tx, f.ty)
                    call Face(f, f.ang)
                    // 활 당기기 (spell channel four 반복)
                    call Anim(f, AN_CHANNEL_FOUR, 1.0)
                    call DestroyEffect(AddSpecialEffect(FX_CHARGE, GetUnitX(f.boss), GetUnitY(f.boss)))
                    call TeleLine(f, GetUnitX(f.boss), GetUnitY(f.boss), f.ang, DistancePBP(GetUnitX(f.boss), GetUnitY(f.boss), f.tx, f.ty), 180, 1.2)
                    call Decal(f, f.tx, f.ty, 250, 1.2, 0)
                    set f.ax = f.now + 1.2
                else
                    set f.rainSnipe = false
                endif
            endif
            if f.mark != null and f.now >= f.ax then
                call ClearMark(f)
                // 발사 (spell channel five 첫 프레임에 시위를 놓는다)
                call Anim(f, AN_CHANNEL_FIVE, 1.0)
                call VoiceCalad(f)
                call FxMuzzle(f, f.ang)
                call ProjSpawn(f, 2, FX_SNIPE_BOLT, GetUnitX(f.boss), GetUnitY(f.boss), f.ang, 3000, RMaxBJ(50, DistancePBP(GetUnitX(f.boss), GetUnitY(f.boss), f.tx, f.ty)), 90, DMG_SNIPE, 1.4)
                set f.rainSnipe = false
            endif
            if f.now >= f.rainNext then
                call RainStrike(f)
                set f.rainWave = f.rainWave + 1
                if f.rainWave >= f.rainWaves then
                    set f.patStart = f.now
                    set f.step = 2
                else
                    // 안전 통로는 한 칸씩 이동한다
                    if f.rainSafe == 0 then
                        set f.rainSafe = 1
                    elseif f.rainSafe == RAIN_LANES - 1 then
                        set f.rainSafe = RAIN_LANES - 2
                    elseif GetRandomInt(0, 1) == 0 then
                        set f.rainSafe = f.rainSafe - 1
                    else
                        set f.rainSafe = f.rainSafe + 1
                    endif
                    call RainTelegraph(f, RAIN_NEXT_WARN)
                    set f.rainNext = f.now + RAIN_NEXT_WARN
                    // 다음 낙하를 지휘하는 동작 (저격 조준 중이면 유지)
                    if f.mark == null then
                        call Anim(f, AN_SPELL_ALT_THREE, 1.0)
                    endif
                endif
            endif
        elseif f.step == 2 and el >= 1.2 and ProjCount(f, 2) == 0 then
            set f.rainWaves = 0
            call PatternDone(f, REST_BIG)
        endif
    endfunction

    // ======================================================================
    // A6. 검의 포위 (2페이즈) - 바깥 고리 → 안쪽 폭발
    // ======================================================================
    private function RunA6 takes ArcherFight f, real el returns nothing
        if f.step == 0 then
            set f.ax = GetUnitX(f.boss)
            set f.ay = GetUnitY(f.boss)
            call Anim(f, AN_SPELL_ALT_ONE, 1.0)
            // 바깥 고리 예고 (빨강) + 안전 안쪽 (초록)
            // 바깥 고리는 폭이 넓어(380~1000) 회피 한 번으로 못 빠져나가므로 2.0초 예고
            call Decal(f, f.ax, f.ay, 1000, 2.0, 0)
            call Decal(f, f.ax, f.ay, 380, 2.0, 3)
            set f.step = 1
        elseif f.step == 1 and el >= 2.0 then
            call HitRing(f, f.ax, f.ay, 380, 1000, DMG_RING)
            call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, f.ax + 700, f.ay))
            call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, f.ax - 700, f.ay))
            call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, f.ax, f.ay + 700))
            call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, f.ax, f.ay - 700))
            call FxAt(FX_STOMP, f.ax, f.ay, 2.0, 0)
            call FxAt(FX_SPARKS, f.ax + 700, f.ay, 1.0, 0)
            call FxAt(FX_SPARKS, f.ax - 700, f.ay, 1.0, 0)
            call FxAt(FX_SPARKS, f.ax, f.ay + 700, 1.0, 0)
            call FxAt(FX_SPARKS, f.ax, f.ay - 700, 1.0, 0)
            call ClearDecals(f)
            // 안쪽 폭발 별도 예고 → 바깥으로 이동. 활 준비 자세로 기다린다
            call Anim(f, AN_STANDREADY_ALT, 1.0)
            call Decal(f, f.ax, f.ay, 380, 1.3, 0)
            set f.step = 2
        elseif f.step == 2 and el >= 2.65 then
            // spell alternate two: 뛰어올랐다 내려찍는 동작. 착지(약 0.65초)가 3.3초 폭발에 맞는다
            call Anim(f, AN_SPELL_ALT_TWO, 1.0)
            set f.step = 3
        elseif f.step == 3 and el >= 3.3 then
            call HitCircle(f, f.ax, f.ay, 380, DMG_CORE, true, 0)
            call FxAt(FX_SNIPE_BOOM, f.ax, f.ay, 1.0, f.face)
            call FxHitBig(f, f.ax, f.ay, f.face, 1.4)
            call CameraShaker.setShake(8)
            set f.step = 4
        elseif f.step == 4 and el >= 4.8 then
            call PatternDone(f, REST_BIG)
        endif
    endfunction

    // (x,y) 에서 a 방향으로 전장 끝까지의 거리
    private function EdgeDist takes ArcherFight f, real x, real y, real a returns real
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

    // ======================================================================
    // 2페이즈 A1 대체. 연사: 부채꼴 3발을 0.3초 간격으로 왼쪽부터 쏜다
    // ======================================================================
    private function RunVolley takes ArcherFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        if f.step == 0 then
            call Anim(f, AN_CHANNEL_FOUR, 1.0)
            call Grunt(f)
            call DestroyEffect(AddSpecialEffect(FX_CHARGE, GetUnitX(f.boss), GetUnitY(f.boss)))
            // 활 조준: 붉은 빛이 활 쪽으로 감겨 모인다 (F4313, Birth 1.77초 한 번)
            call FxAt(FX_BOW_CHARGE, GetUnitX(f.boss), GetUnitY(f.boss), 0.6, f.ang)
            call DestroyEffect(AddSpecialEffectTarget(FX_GATHER, f.boss, "chest"))
            set f.ax = bx
            set f.ay = by
            // 화살은 전장 끝까지 날아간다 (판정 반경 60, 폭 120). 각 줄은 자기 화살이 나갈 때까지 보인다
            call TeleLine(f, bx, by, f.ang - 15, EdgeDist(f, bx, by, f.ang - 15), 120, 1.0)
            call TeleLine(f, bx, by, f.ang, EdgeDist(f, bx, by, f.ang), 120, 1.3)
            call TeleLine(f, bx, by, f.ang + 15, EdgeDist(f, bx, by, f.ang + 15), 120, 1.6)
            set f.step = 1
        elseif f.step == 1 and el >= 1.0 + 0.3 * f.wave then
            // spell channel five 첫 프레임에 시위를 놓는다
            call Anim(f, AN_CHANNEL_FIVE, 1.0)
            call FxMuzzle(f, f.ang)
            call ProjSpawn(f, 3, FX_SNIPE_BOLT, f.ax, f.ay, f.ang + (f.wave - 1) * 15, 2500, EdgeDist(f, f.ax, f.ay, f.ang + (f.wave - 1) * 15), 60, DMG_VOLLEY, 1.0)
            set f.wave = f.wave + 1
            if f.wave >= 3 then
                set f.step = 2
            endif
        elseif f.step == 2 and ProjCount(f, 3) == 0 and el >= 2.2 then
            call PatternDone(f, REST_SHORT)
        endif
    endfunction

    // ======================================================================
    // A8. 로 아이아스: 정면 방패. 앞쪽 반원 공격은 막힌다. 옆·뒤에서 피해를 넣어 깨야 한다
    // ======================================================================
    private function RhoPlace takes ArcherFight f returns nothing
        local real x = GetUnitX(f.boss) + PolarX(110, f.face)
        local real y = GetUnitY(f.boss) + PolarY(110, f.face)
        if f.rho == null then
            set f.rho = AddSpecialEffect(FX_RHO_AIAS, x, y)
        endif
        // 바닥 마법진을 세운 뒤(Y축) 보스 방향으로 돌린다. 크기는 행렬 초기화와 따로 유지된다
        call EXEffectMatReset(f.rho)
        // 남은 꽃잎만큼 방패가 작아진다 (7장 = 원래 크기, 1장 = 절반)
        call EXSetEffectSize(f.rho, RHO_SIZE * (0.5 + 0.5 * f.petals / RHO_PETALS))
        call EXEffectMatRotateY(f.rho, 90)
        call EXEffectMatRotateZ(f.rho, f.face)
        call EXSetEffectXY(f.rho, x, y)
        call MoveLocation(TmpLoc, x, y)
        call EXSetEffectZ(f.rho, GetLocationZ(TmpLoc) + 170)
    endfunction

    private function RhoBreak takes ArcherFight f returns nothing
        // 방패가 깨지는 자리: 빛기둥 파편 + 흰 섬광
        call FxAt(FX_SHATTER, GetUnitX(f.boss) + PolarX(110, f.face), GetUnitY(f.boss) + PolarY(110, f.face), 0.5, f.face)
        call FxKeep(f, FX_RHO_BREAK, GetUnitX(f.boss) + PolarX(110, f.face), GetUnitY(f.boss) + PolarY(110, f.face), 0.5, f.face, 0.9)
        call FxAt(FX_FLASH_WHITE, GetUnitX(f.boss) + PolarX(110, f.face), GetUnitY(f.boss) + PolarY(110, f.face), 6.0, f.face)
        call CameraShaker.setShake(6)
        call RhoClear(f)
        call ClearDecals(f)
        call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
        call Sound3D(f.boss, 'A00U')
        call AnimDown(f)
        call MsgAll(f, "|cFFFFD040방패 파괴!|r", 2.0)
        call VoiceHit(f)
        set f.patStart = f.now
        set f.step = 4
    endfunction

    // 로 아이아스 흐름 (el = 패턴 시작 후 초)
    //   0      대상 쪽으로 방패를 펼치고 방향 고정
    //   2.0    보스가 분홍으로 빛남 (재조준 신호) → 2.8 대상 쪽으로 한 번에 돌아섬
    //   4.0    두 번째 신호 → 4.8 돌아섬
    //   6.0    못 깼으면 방패가 걷히고 앞쪽 충격파 예고 2초 → 8.0 충격파 + 넉백
    //   파훼 ① 돌아서기 사이(약 2초)에 옆·뒤로 돌아가 최대 체력 3% 피해
    //   파훼 ② 정면에서 막힌 스킬 한 번마다 꽃잎 1장, 7장 모두 깨면 파괴 (혼자서도 가능)
    //   어느 쪽이든 깨면 4초 그로기
    private function RunRho takes ArcherFight f, real el returns nothing
        local integer idx = IndexUnit(f.boss)
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local integer i
        local unit u
        local real c
        local real sn
        local real dx
        local real dy
        local real along
        if f.step == 0 then
            // spell one: 빈손을 앞으로 내미는 동작을 방패 시간 동안 늘여 재생
            call Anim(f, AN_SPELL_ONE, 1.333 / RHO_TIME)
            set f.voiceUntil = 0
            call Voice(f, VO_RHO + I2S(GetRandomInt(1, 2)) + ".mp3", VO_RHO_T)
            call FxWindup(f)
            call FxAt(FX_FLASH_WHITE, GetUnitX(f.boss) + PolarX(110, f.face), GetUnitY(f.boss) + PolarY(110, f.face), 5.0, f.face)
            set f.petals = RHO_PETALS
            set UnitGuardBackDmg[idx] = 0
            set UnitGuardFrontHits[idx] = 0
            set UnitFrontGuard[idx] = true
            call RhoPlace(f)
            call MsgAll(f, "|cFFFF80C0로 아이아스|r - 정면은 막힙니다. 빛날 때 돌아서니 그 사이 뒤로 돌거나, 정면에서 꽃잎 7장을 깨세요.", 4.0)
            set f.step = 1
        elseif f.step == 1 then
            // 파훼 ①: 옆·뒤 피해
            if UnitGuardBackDmg[idx] >= UnitHPMAX[idx] * RHO_BREAK_RATE then
                call RhoBreak(f)
                return
            endif
            // 파훼 ②: 정면에서 막힌 스킬 사용 횟수로 꽃잎 깨기
            loop
                exitwhen UnitGuardFrontHits[idx] < RHO_PETAL_HITS or f.petals <= 0
                set UnitGuardFrontHits[idx] = UnitGuardFrontHits[idx] - RHO_PETAL_HITS
                set f.petals = f.petals - 1
                call DestroyEffect(AddSpecialEffect(FX_PETAL_BREAK, bx + PolarX(110, f.face), by + PolarY(110, f.face)))
                call FxKeep(f, FX_PETAL_SHARD, bx + PolarX(110, f.face), by + PolarY(110, f.face), 1.5, f.face, 0.6)
                call MsgAll(f, "|cFFFF80C0꽃잎|r " + I2S(f.petals) + " / " + I2S(RHO_PETALS), 1.0)
                if f.petals > 0 then
                    call RhoPlace(f)
                endif
            endloop
            if f.petals <= 0 then
                call RhoBreak(f)
                return
            endif
            // 재조준: 신호 → RHO_REAIM_DELAY 뒤 한 번에 돌아섬. 그 밖에는 방향 고정
            if ModuloInteger(f.wave, 2) == 0 and el >= RHO_REAIM * (f.wave / 2 + 1) and el < RHO_TIME then
                call SetUnitVertexColor(f.boss, 255, 150, 220, 255)
                call DestroyEffect(AddSpecialEffectTarget(FX_COUNTER_READY, f.boss, "origin"))
                set f.wave = f.wave + 1
            elseif ModuloInteger(f.wave, 2) == 1 and el >= RHO_REAIM * (f.wave / 2 + 1) + RHO_REAIM_DELAY then
                call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
                if MemAlive(f.target) then
                    set f.ang = AngleWBW(f.boss, f.target)
                    call Face(f, f.ang)
                    call RhoPlace(f)
                endif
                set f.wave = f.wave + 1
            endif
            if el >= RHO_TIME then
                // 못 깸: 방패가 걷히고 충격파 예고 (방향 고정, 예고 = 판정)
                call RhoClear(f)
                call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
                call TeleHalf(f, bx, by, f.ang, RHO_WAVE_R, RHO_WAVE_TELL)
                // 충격파 모으기: 발밑에서 빛이 오르고 몸에 빛이 모인다
                call DestroyEffect(AddSpecialEffect(FX_CHARGE, bx, by))
                call DestroyEffect(AddSpecialEffectTarget(FX_GATHER, f.boss, "chest"))
                set f.step = 2
            endif
        elseif f.step == 2 and el >= RHO_TIME + RHO_WAVE_TELL then
            call HitFan(f, bx, by, f.ang, RHO_WAVE_R, 90, DMG_RHO_WAVE, true)
            // 맞은 플레이어를 보스에게서 바깥으로 밀어낸다
            set c = Cos(f.ang * bj_DEGTORAD)
            set sn = Sin(f.ang * bj_DEGTORAD)
            set i = 0
            loop
                exitwhen i >= f.memN
                set u = f.mem[i]
                if MemAlive(u) then
                    set dx = GetUnitX(u) - bx
                    set dy = GetUnitY(u) - by
                    set along = dx * c + dy * sn
                    if along >= 0 and dx * dx + dy * dy <= RHO_WAVE_R * RHO_WAVE_R then
                        call Knockback(u, Atan2(dy, dx) * bj_RADTODEG, RHO_KNOCKBACK, 0.3)
                    endif
                endif
                set i = i + 1
            endloop
            set u = null
            // 앞쪽 반원 전체로 퍼지는 충격: 가운데와 양옆 45도
            call FxAt(FX_SNIPE_BOOM, bx + PolarX(150, f.ang), by + PolarY(150, f.ang), 1.0, f.ang)
            call FxAt(FX_SNIPE_BOOM, bx + PolarX(150, f.ang - 60), by + PolarY(150, f.ang - 60), 1.0, f.ang - 60)
            call FxAt(FX_SNIPE_BOOM, bx + PolarX(150, f.ang + 60), by + PolarY(150, f.ang + 60), 1.0, f.ang + 60)
            call FxHitBig(f, bx + PolarX(RHO_WAVE_R * 0.5, f.ang), by + PolarY(RHO_WAVE_R * 0.5, f.ang), f.ang, 1.5)
            call FxHitBig(f, bx + PolarX(RHO_WAVE_R * 0.5, f.ang - 60), by + PolarY(RHO_WAVE_R * 0.5, f.ang - 60), f.ang - 60, 1.2)
            call FxHitBig(f, bx + PolarX(RHO_WAVE_R * 0.5, f.ang + 60), by + PolarY(RHO_WAVE_R * 0.5, f.ang + 60), f.ang + 60, 1.2)
            call CameraShaker.setShake(8)
            set f.patStart = f.now
            set f.step = 3
        elseif f.step == 3 and el >= 1.0 then
            call PatternDone(f, REST_BIG)
        elseif f.step == 4 and el >= RHO_GROGGY then
            // 방패 파괴 그로기 뒤
            call PatternDone(f, REST_SHORT)
        endif
    endfunction

    // ======================================================================
    // A9. 부서진 환상: 바닥에 꽂힌 검 4자루씩 3번, 빛난 뒤 1.2초 후 폭발. 끝나면 새 자리에 다시 꽂힌다
    // ======================================================================
    private function PhantasmMark takes ArcherFight f, integer count returns nothing
        local integer tries = 0
        local integer n = 0
        local integer i
        loop
            exitwhen n >= count or tries >= 40
            set i = GetRandomInt(0, UBW_STUCK_COUNT - 1)
            // 빛나는 검(주울 수 있는 검)은 터뜨리지 않는다
            if f.stuck[i] != null and f.sExp[i] == 0 and f.sGlow[i] == null then
                set f.sExp[i] = f.now + PHANTASM_WARN
                call Decal(f, f.sx[i], f.sy[i], PHANTASM_RADIUS, PHANTASM_WARN, 0)
                call DestroyEffect(AddSpecialEffect(FX_COUNTER_READY, f.sx[i], f.sy[i]))
                set n = n + 1
            endif
            set tries = tries + 1
        endloop
    endfunction

    // 터질 시각이 된 검을 폭발시킨다. 남은 예약 수를 돌려준다
    private function PhantasmUpdate takes ArcherFight f returns integer
        local integer i = 0
        local integer left = 0
        loop
            exitwhen i >= UBW_STUCK_COUNT
            if f.sExp[i] > 0 then
                if f.now >= f.sExp[i] then
                    set f.sExp[i] = 0
                    call HitCircle(f, f.sx[i], f.sy[i], PHANTASM_RADIUS, DMG_PHANTASM, true, 0)
                    // 뷰어 확인: 1.2배에서 판정 반경 200 과 맞는다
                    call FxAt(FX_PHANTASM_FIRE, f.sx[i], f.sy[i], 1.2, GetRandomReal(0, 360))
                    call FxAt(FX_FLASH_WHITE, f.sx[i], f.sy[i], 4.0, 0)
                    call FxAt(FX_SPARKS, f.sx[i], f.sy[i], 1.2, 0)
                    call FxKeep(f, FX_CRACK, f.sx[i], f.sy[i], 0.7, GetRandomReal(0, 360), 1.5)
                    if f.stuck[i] != null then
                        call SwordFxRemove(f.stuck[i])
                        set f.stuck[i] = null
                    endif
                else
                    set left = left + 1
                endif
            endif
            set i = i + 1
        endloop
        return left
    endfunction

    private function RunPhantasm takes ArcherFight f, real el returns nothing
        local integer left = PhantasmUpdate(f)
        if f.step == 0 then
            call StuckSwordsRefill(f)
            call MsgAll(f, "|cFFFF8040부서진 환상|r - 빛나는 검에서 떨어지세요.", 3.0)
            set f.step = 1
        elseif f.step == 1 and el >= 0.3 + 1.0 * f.wave then
            // 다음 파동을 지휘하는 동작 + 몸에 모이는 빛
            call Anim(f, AN_SPELL_ALT_THREE, 1.0)
            call DestroyEffect(AddSpecialEffectTarget(FX_GATHER, f.boss, "chest"))
            // 남은 검 5자루당 1자루씩, 파동마다 2~4자루
            call PhantasmMark(f, IMaxBJ(2, IMinBJ(4, StockCount(f) / 5)))
            set f.wave = f.wave + 1
            if f.wave >= 3 then
                set f.step = 2
            endif
        elseif f.step == 2 and left == 0 then
            call CameraShaker.setShake(6)
            call StuckSwordsRefill(f)
            set f.patStart = f.now
            set f.step = 3
        elseif f.step == 3 and el >= 0.8 then
            call PatternDone(f, REST_BIG)
        endif
    endfunction

    // ======================================================================
    // A10. 붉은 사냥개(흐룬팅): 표식 대상을 3초 동안 쫓는 화살. 다른 플레이어가 막아 주거나 꽂힌 검에 걸리게 하면 된다
    // ======================================================================
    private function HrExplode takes ArcherFight f returns nothing
        call FxAt(FX_SNIPE_BOOM, f.hx, f.hy, 1.0, f.hdir)
        call FxHitBig(f, f.hx, f.hy, f.hdir, 1.0)
        call CameraShaker.setShake(6)
        call HrClear(f)
        call ClearMark(f)
        set f.patStart = f.now
        set f.step = 4
    endfunction

    private function RunHrunting takes ArcherFight f, real el returns nothing
        local integer k
        local integer i
        local real d
        local real spd
        local unit u
        if f.step == 0 then
            set k = PickSnipeTarget(f)
            if k < 0 then
                call PatternDone(f, REST_SHORT)
                return
            endif
            set f.markCount[k] = f.markCount[k] + 1
            set f.target = f.mem[k]
            call ClearMark(f)
            set f.mark = AddSpecialEffectTarget(FX_SNIPE_MARK, f.target, "overhead")
            set f.ang = AngleWBW(f.boss, f.target)
            call Face(f, f.ang)
            call Anim(f, AN_CHANNEL_FOUR, 1.0)
            call DestroyEffect(AddSpecialEffect(FX_CHARGE, GetUnitX(f.boss), GetUnitY(f.boss)))
            // 활 조준: 붉은 빛이 활 쪽으로 감겨 모인다 (F4313, Birth 1.77초 한 번)
            call FxAt(FX_BOW_CHARGE, GetUnitX(f.boss), GetUnitY(f.boss), 0.6, f.ang)
            set f.voiceUntil = 0
            call Voice(f, VO_HRUNT, VO_HRUNT_T)
            call MsgAll(f, "|cFFFF4040붉은 사냥개|r - 화살이 표식 대상을 쫓습니다. 대신 막거나 꽂힌 검으로 유도하세요.", 3.0)
            set f.step = 1
        elseif f.step == 1 then
            if MemAlive(f.target) then
                set f.ang = AngleWBW(f.boss, f.target)
                call Face(f, f.ang)
            endif
            if el >= HRUNT_TELL then
                call Anim(f, AN_CHANNEL_FIVE, 1.0)
                call FxMuzzle(f, f.ang)
                set f.hdir = f.ang
                set f.hx = GetUnitX(f.boss) + PolarX(80, f.hdir)
                set f.hy = GetUnitY(f.boss) + PolarY(80, f.hdir)
                set f.hEff = MakeMissile(FX_SNIPE_BOLT, f.hx, f.hy, 90, f.hdir, 1.4, null)
                set f.hLight = AddLightningEx("DRAL", true, f.hx, f.hy, 60, GetUnitX(f.target), GetUnitY(f.target), 60)
                set f.patStart = f.now
                set f.step = 2
            endif
        elseif f.step == 2 then
            // 회전 속도 제한 유도, 점점 빨라지는 화살
            if MemAlive(f.target) then
                set d = ModuloReal(AnglePBP(f.hx, f.hy, GetUnitX(f.target), GetUnitY(f.target)) - f.hdir + 540.0, 360.0) - 180.0
                if d > HRUNT_TURN * TICK then
                    set d = HRUNT_TURN * TICK
                elseif d < -HRUNT_TURN * TICK then
                    set d = -HRUNT_TURN * TICK
                endif
                set f.hdir = f.hdir + d
                call EXEffectMatRotateZ(f.hEff, d)
                set spd = RMinBJ(HRUNT_SPEED_MAX, HRUNT_SPEED_START + HRUNT_ACCEL * el)
                call MoveLightningEx(f.hLight, true, f.hx, f.hy, 60, GetUnitX(f.target), GetUnitY(f.target), 60)
            else
                set spd = 300
            endif
            set f.hx = ClampX(f, f.hx + PolarX(spd * TICK, f.hdir))
            set f.hy = ClampY(f, f.hy + PolarY(spd * TICK, f.hdir))
            call EXSetEffectXY(f.hEff, f.hx, f.hy)
            // 붉은 사냥개 꼬리: 0.1초마다 붉은 섬광
            if ModuloInteger(R2I(f.now / TICK + 0.5), 5) == 0 then
                call FxAt(FX_FLASH_RED, f.hx, f.hy, 0.7, f.hdir)
            endif
            // 꽂힌 검에 걸리면 막힌다 (검도 부서짐)
            set i = 0
            loop
                exitwhen i >= UBW_STUCK_COUNT
                if f.stuck[i] != null and DistancePBP(f.hx, f.hy, f.sx[i], f.sy[i]) <= 60 then
                    // 빛나는 검은 화살을 막아도 부서지지 않는다 (주울 수 있게 남김)
                    if f.sGlow[i] == null then
                        call SwordFxRemove(f.stuck[i])
                        set f.stuck[i] = null
                    endif
                    call HrExplode(f)
                    return
                endif
                set i = i + 1
            endloop
            // 처음 닿은 플레이어가 맞는다 (다른 플레이어가 몸으로 막을 수 있음)
            set i = 0
            loop
                exitwhen i >= f.memN
                set u = f.mem[i]
                if MemAlive(u) and IsUnitInRangeXY(u, f.hx, f.hy, 80) then
                    call Deal(f, u, DMG_HRUNT, true)
                    set u = null
                    call HrExplode(f)
                    return
                endif
                set i = i + 1
            endloop
            set u = null
            if el >= HRUNT_TIME - 1.0 then
                // 멈춘 자리에서 1.0초 뒤 폭발 (원형 예고 = 판정)
                call Decal(f, f.hx, f.hy, HRUNT_RADIUS, 1.0, 0)
                set f.step = 3
            endif
        elseif f.step == 3 and el >= HRUNT_TIME then
            call HitCircle(f, f.hx, f.hy, HRUNT_RADIUS, DMG_HRUNT, true, 0)
            call HrExplode(f)
        elseif f.step == 4 and el >= 0.8 then
            call PatternDone(f, REST_BIG)
        endif
    endfunction

    // ======================================================================
    // A11. 학익삼련: 간장·막야 3쌍이 양옆에서 대상 위치로 모이고, 그 자리를 돌진 X 베기
    // ======================================================================
    private function RunKakuyoku takes ArcherFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local real nx
        local real ny
        local real step
        local integer k
        local real off
        if f.step == 0 then
            if not MemAlive(f.target) then
                call PatternDone(f, REST_SHORT)
                return
            endif
            set f.tx = GetUnitX(f.target)
            set f.ty = GetUnitY(f.target)
            call Anim(f, AN_STAND_READY, 1.0)
            // 남은 검 8자루당 1쌍 (1~3쌍)
            set f.snipeLeft = IMaxBJ(1, IMinBJ(3, StockCount(f) / 8))
            // 보스 양옆 150·300·450 에서 출발해 대상 위치를 지나 200 더 날아간다. 판정 반경 70, 폭 140
            set k = 0
            loop
                exitwhen k >= f.snipeLeft * 2
                set off = 150 * (k / 2 + 1)
                if ModuloInteger(k, 2) == 0 then
                    set off = -off
                endif
                set f.kx[k] = bx + PolarX(off, f.ang + 90) + PolarX(-100, f.ang)
                set f.ky[k] = by + PolarY(off, f.ang + 90) + PolarY(-100, f.ang)
                set f.ka[k] = AnglePBP(f.kx[k], f.ky[k], f.tx, f.ty)
                set f.kl[k] = DistancePBP(f.kx[k], f.ky[k], f.tx, f.ty) + 200
                call TeleLine(f, f.kx[k], f.ky[k], f.ka[k], f.kl[k] + 70, 140, 1.0 + 0.25 * (k / 2))
                set k = k + 1
            endloop
            set f.step = 1
        elseif f.step == 1 and el >= 0.8 + 0.25 * f.wave then
            // spell three: 검을 던지는 동작 (손을 떠나는 약 0.2초에 발사)
            call Anim(f, AN_SPELL_THREE, 1.0)
            call FxWindup(f)
            set f.step = 2
        elseif f.step == 2 and el >= 1.0 + 0.25 * f.wave then
            set k = f.wave * 2
            call ProjSpawn(f, 3, FX_THROW_KANSHOU, f.kx[k], f.ky[k], f.ka[k], 1600, f.kl[k], 70, DMG_KAKU, 1.4)
            call ProjSpawn(f, 3, FX_THROW_BAKUYA, f.kx[k + 1], f.ky[k + 1], f.ka[k + 1], 1600, f.kl[k + 1], 70, DMG_KAKU, 1.4)
            set f.wave = f.wave + 1
            if f.wave >= f.snipeLeft then
                set f.step = 3
            else
                set f.step = 1
            endif
        elseif f.step == 3 and el >= 2.1 then
            // 모인 자리로 돌진 (예고 = 판정 사각형)
            set f.ang = AnglePBP(bx, by, f.tx, f.ty)
            call Face(f, f.ang)
            call Anim(f, AN_STAND_READY, 1.0)
            set f.ax = bx
            set f.ay = by
            set f.dashLen = RMinBJ(1200, DistancePBP(bx, by, f.tx, f.ty) + 200)
            // 예고는 카운터 창이 끝날 때까지 유지
            call TeleLine(f, bx, by, f.ang, f.dashLen + DASH_REACH, DASH_WIDTH, 1.0 + KAKU_COUNTER_WINDOW)
            set f.step = 4
        elseif f.step == 4 and el >= 3.1 then
            // 마지막 돌진 X베기 직전 카운터 창: 심안·역습과 같은 신호(더미 3종, 푸른 고리, 어두워짐)
            call UnitAddAbility(f.boss, 'A00V')
            call SetUnitVertexColorBJ(f.boss, 70, 70, 100, 0)
            set f.cue[0] = UnitEffectTimeEX('e00F', bx, by, 0, 3)
            set f.cue[1] = UnitEffectTimeEX('e00G', bx, by, 0, 3)
            set f.cue[2] = UnitEffectTimeEX('e01S', bx, by, 0, 3)
            call DestroyEffect(AddSpecialEffectTarget(FX_COUNTER_READY, f.boss, "origin"))
            call FxWindup(f)
            call Anim(f, AN_STAND_READY, 1.0)
            set f.patStart = f.now
            set f.step = 7
        elseif f.step == 7 and GetUnitAbilityLevel(f.boss, 'A00V') == 0 then
            // 카운터 성공: X베기 취소, 쓰러져 그로기
            call ClearDecals(f)
            call TeleUpdate(f, true)
            call CueClear(f)
            call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
            call Sound3D(f.boss, 'A00U')
            call VoiceHit(f)
            call AnimDown(f)
            set f.patStart = f.now
            set f.step = 8
        elseif f.step == 8 and el >= KAKU_COUNTER_GROGGY then
            call PatternDone(f, REST_SHORT)
        elseif f.step == 7 and el >= KAKU_COUNTER_WINDOW then
            // 카운터 실패: 그대로 돌진 X베기
            call UnitRemoveAbility(f.boss, 'A00V')
            call CueClear(f)
            call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
            call Anim(f, AN_ATTACK1, 1.5)
            call Voice(f, VO_GOTYOU, VO_GOTYOU_T)
            set f.dashLeft = f.dashLen
            set f.dashSpeed = 1600
            call FxDash(f)
            set f.step = 5
        elseif f.step == 5 then
            set step = RMinBJ(f.dashLeft, f.dashSpeed * TICK)
            set nx = ClampX(f, bx + PolarX(step, f.ang))
            set ny = ClampY(f, by + PolarY(step, f.ang))
            call SetUnitPosition(f.boss, nx, ny)
            call HitRect(f, f.ax, f.ay, f.ang, DistancePBP(f.ax, f.ay, nx, ny) + DASH_REACH, DASH_WIDTH, DMG_DASH, true, f.hit)
            set f.dashLeft = f.dashLeft - step
            if f.dashLeft <= 0 then
                // 끝에서 쌍검 X 베기 자국
                call FxCut(nx, ny, f.ang, 0, 35, SLASH_RANGE, false)
                call FxCut(nx, ny, f.ang, 0, -35, SLASH_RANGE, true)
                call FxHitBig(f, nx, ny, f.ang, 1.2)
                set f.patStart = f.now
                set f.step = 6
            endif
        elseif f.step == 6 and el >= 1.0 then
            call PatternDone(f, REST_BIG)
        endif
    endfunction

    // ======================================================================
    // 무한의 검제: 결계 상태
    // ======================================================================
    private function PullClear takes ArcherFight f returns nothing
        local integer i = 0
        local integer pid
        loop
            exitwhen i >= f.memN
            if f.mem[i] != null then
                set pid = GetPlayerId(GetOwningPlayer(f.mem[i]))
                set HeroPulledSword[pid] = 0
                if PullFx[pid] != null then
                    call DestroyEffect(PullFx[pid])
                    set PullFx[pid] = null
                endif
                if PullTag[pid] != null then
                    call DestroyTextTag(PullTag[pid])
                    set PullTag[pid] = null
                endif
            endif
            set i = i + 1
        endloop
    endfunction

    // 무한의 검제 배경음악: 전투 참가자 화면에서만 바꾼다 (on = false 면 원래 음악으로)
    // 이 화면의 플레이어가 전투 참가자인지
    private function LocalIsMember takes ArcherFight f returns boolean
        local integer i = 0
        loop
            exitwhen i >= f.memN
            if f.mem[i] != null and GetLocalPlayer() == GetOwningPlayer(f.mem[i]) then
                return true
            endif
            set i = i + 1
        endloop
        return false
    endfunction

    // 배경음악 첫 재생: 음량 0 으로 튼 뒤 0.2초 뒤 다시 틀어야 소리가 난다
    // 무한의 검제 배경음악: 반복 2D 사운드로, 전투 참가자 화면에서만 들리게 한다 (PlayMusic 은 들리지 않았다).
    // 켜져 있는 동안 원래 음악은 참가자 화면에서만 멈추고, 끝나면 다시 튼다
    private function UbwMusic takes ArcherFight f, boolean on returns nothing
        if on then
            if f.bgm == null then
                // 바로 재생 (맵 시작 때 음량 0 으로 미리 틀어 둠). 참가자가 아닌 화면은 음량 0
                set f.bgm = CreateSound(UBW_BGM, true, false, false, 10, 10, "DefaultEAXON")
                if LocalIsMember(f) then
                    call SetSoundVolume(f.bgm, 100)
                else
                    call SetSoundVolume(f.bgm, 0)
                endif
                call StartSound(f.bgm)
            endif
            if LocalIsMember(f) then
                call StopMusic(true)
            endif
        else
            if f.bgm != null then
                call StopSound(f.bgm, true, true)
                set f.bgm = null
            endif
            if LocalIsMember(f) and BGMSound != null and BGMSound != "" then
                call PlayMusic(BGMSound)
            endif
        endif
    endfunction

    private function UbwBegin takes ArcherFight f returns nothing
        call UbwMusic(f, true)
        set f.ubw = true
        set f.restockAt = f.now + RESTOCK_EVERY
        set f.glowAt = f.now + 3.0
        set f.dropWave = 0
    endfunction

    // 강제 패턴: 진행 중인 공격을 모두 취소하고 바로 시작
    private function ForcePattern takes ArcherFight f, integer id returns nothing
        call CancelAttacks(f)
        call ClearDecals(f)
        call PatternEnd(f, 0)
        call StartPattern(f, id)
    endfunction

    // 검의 강하: 떨어질 자리 하나 예약 (예고 원 = 판정)
    private function DropAdd takes ArcherFight f, real x, real y, integer w returns nothing
        local integer i = 0
        set x = ClampX(f, x)
        set y = ClampY(f, y)
        loop
            exitwhen i >= 64
            if f.dAt[i] == 0 then
                set f.dX[i] = x
                set f.dY[i] = y
                set f.dAt[i] = f.now + DROP_WARN
                set f.dW[i] = w
                call DecalFree(f, x, y, DROP_RADIUS, DROP_WARN)
                return
            endif
            set i = i + 1
        endloop
    endfunction

    // 한 파: 플레이어마다 발밑 1 + 주변 2 (그때 위치로 다시 조준), 전장 무작위
    private function DropWave takes ArcherFight f, integer w returns nothing
        local integer i = 0
        local integer k
        local unit u
        local real a
        local rect r = MapRectReturn(f.rect)
        if f.dHit[w] == 0 then
            set f.dHit[w] = party.create()
        endif
        call GroupClear(f.dHit[w].super)
        loop
            exitwhen i >= f.memN
            set u = f.mem[i]
            if MemAlive(u) then
                call DropAdd(f, GetUnitX(u), GetUnitY(u), w)
                // 주변 2개 중 하나는 바라보는 쪽(달아나는 쪽)으로
                set a = GetUnitFacing(u)
                call DropAdd(f, GetUnitX(u) + PolarX(DROP_NEAR * GetRandomReal(0.6, 1.0), a + GetRandomReal(-30, 30)), GetUnitY(u) + PolarY(DROP_NEAR * GetRandomReal(0.6, 1.0), a + GetRandomReal(-30, 30)), w)
                set a = GetRandomReal(0, 360)
                call DropAdd(f, GetUnitX(u) + PolarX(DROP_NEAR * GetRandomReal(0.6, 1.0), a), GetUnitY(u) + PolarY(DROP_NEAR * GetRandomReal(0.6, 1.0), a), w)
            endif
            set i = i + 1
        endloop
        set u = null
        set k = 0
        loop
            exitwhen k >= DROP_RANDOM
            call DropAdd(f, GetRandomReal(GetRectMinX(r) + 200, GetRectMaxX(r) - 200), GetRandomReal(GetRectMinY(r) + 200, GetRectMaxY(r) - 200), w)
            set k = k + 1
        endloop
        set r = null
        // 지휘 동작 (패턴 중이 아니면) + 몸에 모이는 빛, 첫 파에는 발밑 충전
        if f.pat == 0 then
            call Anim(f, AN_SPELL_ALT_THREE, 1.0)
        endif
        call DestroyEffect(AddSpecialEffectTarget(FX_GATHER, f.boss, "chest"))
        if w == 0 then
            call DestroyEffect(AddSpecialEffect(FX_CHARGE, GetUnitX(f.boss), GetUnitY(f.boss)))
        endif
    endfunction

    // 예고가 끝난 자리에 검이 떨어진다. 빈 자리가 있으면 꽂힌 검(탄약)이 된다
    private function DropUpdate takes ArcherFight f returns nothing
        local integer i = 0
        local integer j
        loop
            exitwhen i >= 64
            if f.dAt[i] > 0 and f.now >= f.dAt[i] then
                set f.dAt[i] = 0
                call HitCircle(f, f.dX[i], f.dY[i], DROP_RADIUS, DMG_DROP, true, f.dHit[f.dW[i]])
                call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, f.dX[i], f.dY[i]))
                call FxAt(FX_DUST, f.dX[i], f.dY[i], 1.0, 0)
                call FxAt(FX_SPARKS, f.dX[i], f.dY[i], 0.8, 0)
                call FxAt(FX_FLASH_RED, f.dX[i], f.dY[i], 0.9, 0)
                set j = 0
                loop
                    exitwhen j >= UBW_STUCK_COUNT
                    if f.stuck[j] == null and f.sFall[j] == 0 and f.sExp[j] == 0 then
                        set f.sx[j] = f.dX[i]
                        set f.sy[j] = f.dY[i]
                        call StuckSwordAt(f, j)
                        set j = UBW_STUCK_COUNT
                    endif
                    set j = j + 1
                endloop
            endif
            set i = i + 1
        endloop
    endfunction

    private function UbwTick takes ArcherFight f returns nothing
        local integer idx = IndexUnit(f.boss)
        local integer i
        local integer k
        local integer n
        local integer pid
        local unit u
        if not f.ubw then
            return
        endif
        // 검을 든 플레이어가 때림: 로 아이아스 방패가 있을 때만 검 1개로 꽃잎 1장 (한 사람 0.5초에 1개)
        set k = 0
        loop
            exitwhen k >= f.memN
            if f.mem[k] != null then
                set pid = GetPlayerId(GetOwningPlayer(f.mem[k]))
                if HeroPullHit[pid] then
                    set HeroPullHit[pid] = false
                    if f.rho != null and f.petals > 0 and HeroPulledSword[pid] > 0 and f.now >= PullUseAt[pid] then
                        set PullUseAt[pid] = f.now + 0.5
                        set HeroPulledSword[pid] = HeroPulledSword[pid] - 1
                        set f.petals = f.petals - 1
                        call FxAt(FX_FLASH_WHITE, GetUnitX(f.boss) + PolarX(110, f.face), GetUnitY(f.boss) + PolarY(110, f.face), 6.0, 0)
                        call FxAt(FX_SPARKS, GetUnitX(f.boss) + PolarX(110, f.face), GetUnitY(f.boss) + PolarY(110, f.face), 1.4, 0)
                        call FxKeep(f, FX_PETAL_SHARD, GetUnitX(f.boss) + PolarX(110, f.face), GetUnitY(f.boss) + PolarY(110, f.face), 1.5, f.face, 0.6)
                        if f.petals > 0 then
                            call RhoPlace(f)
                        endif
                    endif
                endif
            endif
            set k = k + 1
        endloop
        // 빛나는 검: 만료·줍기
        set i = 0
        loop
            exitwhen i >= UBW_STUCK_COUNT
            if f.sGlow[i] != null then
                // 주우러 오는 중이면(GLOW_KEEP 안에 플레이어) 빛을 끄지 않는다
                if f.stuck[i] != null and f.now >= f.sGlowEnd[i] then
                    set k = 0
                    loop
                        exitwhen k >= f.memN
                        if MemAlive(f.mem[k]) and IsUnitInRangeXY(f.mem[k], f.sx[i], f.sy[i], GLOW_KEEP) then
                            set f.sGlowEnd[i] = f.now + 0.5
                            set k = f.memN
                        endif
                        set k = k + 1
                    endloop
                endif
                if f.stuck[i] == null or f.now >= f.sGlowEnd[i] then
                    call DestroyEffect(f.sGlow[i])
                    set f.sGlow[i] = null
                else
                    set k = 0
                    loop
                        exitwhen k >= f.memN
                        set u = f.mem[k]
                        if MemAlive(u) and IsUnitInRangeXY(u, f.sx[i], f.sy[i], PULL_RADIUS) then
                            set pid = GetPlayerId(GetOwningPlayer(u))
                            if HeroPulledSword[pid] < PULL_MAX then
                                set HeroPulledSword[pid] = HeroPulledSword[pid] + 1
                                call FxAt(FX_FLASH_WHITE, f.sx[i], f.sy[i], 5.0, 0)
                                call StuckSwordRemove(f, i)
                                set k = f.memN
                            endif
                        endif
                        set k = k + 1
                    endloop
                endif
            endif
            set i = i + 1
        endloop
        set u = null
        // 뽑은 검 표시
        set k = 0
        loop
            exitwhen k >= f.memN
            if f.mem[k] != null then
                set pid = GetPlayerId(GetOwningPlayer(f.mem[k]))
                if HeroPulledSword[pid] > 0 and PullFx[pid] == null and MemAlive(f.mem[k]) then
                    set PullFx[pid] = AddSpecialEffectTarget(FX_THROW_BAKUYA, f.mem[k], "overhead")
                elseif (HeroPulledSword[pid] <= 0 or not MemAlive(f.mem[k])) and PullFx[pid] != null then
                    call DestroyEffect(PullFx[pid])
                    set PullFx[pid] = null
                endif
                // 개수 글자: 영웅을 따라다니고, 개수가 바뀌면 다시 쓰고, 0 이면 지운다
                if HeroPulledSword[pid] > 0 and MemAlive(f.mem[k]) then
                    if PullTag[pid] == null then
                        set PullTag[pid] = CreateTextTag()
                        call SetTextTagPermanent(PullTag[pid], true)
                        call SetTextTagVisibility(PullTag[pid], true)
                        set PullTagN[pid] = 0
                    endif
                    if PullTagN[pid] != HeroPulledSword[pid] then
                        set PullTagN[pid] = HeroPulledSword[pid]
                        call SetTextTagText(PullTag[pid], "|cFFFFFFFF검|r |cFFFF6060×" + I2S(HeroPulledSword[pid]) + "|r", 0.024)
                    endif
                    call SetTextTagPosUnit(PullTag[pid], f.mem[k], 230)
                elseif PullTag[pid] != null then
                    call DestroyTextTag(PullTag[pid])
                    set PullTag[pid] = null
                endif
            endif
            set k = k + 1
        endloop
        // 새로 빛나는 검
        if f.now >= f.glowAt then
            set f.glowAt = f.now + GLOW_EVERY
            set n = 0
            set k = 0
            loop
                exitwhen n >= GLOW_COUNT or k >= 40
                set i = GetRandomInt(0, UBW_STUCK_COUNT - 1)
                if f.stuck[i] != null and f.sGlow[i] == null and f.sExp[i] == 0 then
                    set f.sGlow[i] = AddSpecialEffect(FX_SWORD_GLOW, f.sx[i], f.sy[i])
                    set f.sGlowEnd[i] = f.now + GLOW_TIME
                    set n = n + 1
                endif
                set k = k + 1
            endloop
        endif
        // 검의 강하: 재보급 시각이 되면 시작 (로 아이아스·전검 사출·칼날의 숲·그로기 중에는 미룬다)
        if f.dropWave == 0 and f.now >= f.restockAt then
            if f.pat != 8 and f.pat != 13 and f.pat != 16 and f.now >= f.holdUntil and not (f.pat == 4 and f.step == 6) then
                set f.restockAt = f.now + RESTOCK_EVERY + GetRandomReal(-DROP_JITTER, DROP_JITTER)
                set f.dropWave = DROP_WAVES
                set f.dropNext = f.now
                call ShowPatName(f, 20)
                call MsgAll(f, "|cFFFF9628검의 강하|r - 발밑에 떨어지는 검을 피하세요.", 2.0)
                call Voice(f, VO_PIERCE, VO_PIERCE_T)
            endif
        endif
        if f.dropWave > 0 and f.now >= f.dropNext then
            call DropWave(f, DROP_WAVES - f.dropWave)
            set f.dropWave = f.dropWave - 1
            set f.dropNext = f.now + DROP_GAP
        endif
        call DropUpdate(f)
    endfunction

    // 체력 25% 에서 전검 사출 (한 번)
    private function AllBladeCheck takes ArcherFight f returns nothing
        local integer idx = IndexUnit(f.boss)
        if f.state == ARCHER_PHASE2 and f.ubw and not f.ubwSecond and f.pat != 16 and UnitHP[idx] <= UnitHPMAX[idx] * ALLBLADE_HP then
            set f.ubwSecond = true
            call ForcePattern(f, 16)
        endif
    endfunction

    // ======================================================================
    // A16. 전검 사출 (강제, 체력 25%): 남은 검이 모두 날아오른다. 그중 플레이어마다 '남은 검 6자루당 1발'(최대 3발)이
    // 그 플레이어를 노리고, 들고 있는 검 1개 = 1발 방어. 나머지는 전장에 쏟아지는 연출. 버티면 6초 그로기
    // (예전에는 남은 검 수만큼 전부 한 사람을 노려서, 3개를 들고 있어도 나머지에 맞았다)
    // ======================================================================
    private function RunAllBlade takes ArcherFight f, real el returns nothing
        local integer i
        local integer k
        local integer pid
        local unit u
        if f.step == 0 then
            call Anim(f, AN_SPELL_ALT_THREE, 1.0)
            call DestroyEffect(AddSpecialEffect(FX_CHARGE, GetUnitX(f.boss), GetUnitY(f.boss)))
            call FxWindup(f)
            set f.voiceUntil = 0
            call Voice(f, VO_ALLBLADE, VO_ALLBLADE_T)
            call MsgAll(f, "|cFFFF4040전검 사출|r - 결계의 모든 검이 날아옵니다. 뽑은 검 1개로 1발을 막을 수 있습니다.", 4.0)
            // 남은 검이 하나씩 빛난다
            set i = 0
            loop
                exitwhen i >= UBW_STUCK_COUNT
                if f.stuck[i] != null then
                    call DestroyEffect(AddSpecialEffect(FX_COUNTER_READY, f.sx[i], f.sy[i]))
                endif
                set i = i + 1
            endloop
            set f.wave = 0
            // 사람마다 노리는 발 수 = 남은 검 6자루당 1발, 1~3발 (뽑아 둔 검 3개면 모두 막을 수 있다)
            set f.snipeLeft = IMaxBJ(1, IMinBJ(PULL_MAX, (StockCount(f) + 5) / 6)) * AliveCount(f)
            call MsgAll(f, "노리는 검: 한 사람당 " + I2S(f.snipeLeft / IMaxBJ(1, AliveCount(f))) + "발", 4.0)
            set f.step = 1
        elseif f.step == 1 and el >= ALLBLADE_CHANT + 0.1 * f.wave then
            // 남은 검 하나를 날려 플레이어 한 명에게 (돌아가며)
            set i = 0
            loop
                exitwhen i >= UBW_STUCK_COUNT or f.stuck[i] != null
                set i = i + 1
            endloop
            if (i >= UBW_STUCK_COUNT and f.wave >= f.snipeLeft) or AliveCount(f) == 0 then
                // 다 쐈음: 아쳐가 지쳐 그로기 (결계는 남고, 검은 재보급으로 다시 채워진다)
                call FxAt(FX_FLASH_WHITE, GetUnitX(f.boss), GetUnitY(f.boss), 10.0, 0)
                call CameraShaker.setShake(8)
                call MsgAll(f, "|cFFFFD040전검 사출을 버텼습니다|r 지금이 기회입니다.", 2.0)
                call VoiceHit(f)
                call AnimDown(f)
                set f.groggy = ALLBLADE_GROGGY
                set f.patStart = f.now
                set f.step = 2
                return
            endif
            if i < UBW_STUCK_COUNT then
                // 검이 떠올라 날아감 (탄약 소모)
                call FxAt(FX_FLASH_RED, f.sx[i], f.sy[i], 1.0, 0)
                call StuckSwordRemove(f, i)
            endif
            // 노리는 발: 살아 있는 사람을 돌아가며. 다 쏜 뒤의 검은 연출로만 쏟아진다
            set u = null
            if f.wave < f.snipeLeft then
                set k = 0
                set i = ModuloInteger(f.wave, IMaxBJ(1, f.memN))
                loop
                    exitwhen k >= f.memN or MemAlive(f.mem[i])
                    set i = ModuloInteger(i + 1, IMaxBJ(1, f.memN))
                    set k = k + 1
                endloop
                set u = f.mem[i]
            else
                call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, f.arenaCX() + GetRandomReal(-900, 900), f.arenaCY() + GetRandomReal(-900, 900)))
            endif
            if MemAlive(u) then
                set pid = GetPlayerId(GetOwningPlayer(u))
                call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, GetUnitX(u), GetUnitY(u)))
                if HeroPulledSword[pid] > 0 then
                    // 뽑은 검으로 막음: 흰 섬광 + 파편 (빛기둥 F7255 는 입자가 많아 여러 번 겹치면 느려져서 쓰지 않는다)
                    set HeroPulledSword[pid] = HeroPulledSword[pid] - 1
                    call FxAt(FX_FLASH_WHITE, GetUnitX(u), GetUnitY(u), 6.0, 0)
                    call FxAt(FX_SPARKS, GetUnitX(u), GetUnitY(u), 1.2, 0)
                else
                    call FxHitSmall(GetUnitX(u), GetUnitY(u), GetRandomReal(0, 360))
                    call Deal(f, u, DMG_ALLBLADE, false)
                endif
            endif
            set u = null
            set f.wave = f.wave + 1
        elseif f.step == 2 and el >= f.groggy - 1.0 then
            call FxWindup(f)
            set f.step = 3
        elseif f.step == 3 and el >= f.groggy then
            call PatternDone(f, REST_SHORT)
        endif
    endfunction

    // ======================================================================
    // A12. 검의 사출: 남은 검이 차례로 떠올라 플레이어 쪽으로 날아온다 (검 3자루당 1발, 2~6발)
    // ======================================================================
    private function RunLaunch takes ArcherFight f, real el returns nothing
        local integer n
        local integer k
        local integer i
        local integer tries
        local unit u
        if f.step == 0 then
            set n = IMaxBJ(2, IMinBJ(6, StockCount(f) / 3))
            if StockCount(f) == 0 or AliveCount(f) == 0 then
                call PatternDone(f, REST_SHORT)
                return
            endif
            call Anim(f, AN_SPELL_ALT_THREE, 1.0)
            call FxWindup(f)
            call Voice(f, VO_PIERCE, VO_PIERCE_T)
            set k = 0
            set tries = 0
            loop
                exitwhen k >= n or tries >= 60
                set i = GetRandomInt(0, UBW_STUCK_COUNT - 1)
                // 빛나는 검(주울 수 있는 검)은 쏘지 않는다
                if f.stuck[i] != null and f.sExp[i] == 0 and f.sGlow[i] == null then
                    set u = f.mem[ModuloInteger(k, IMaxBJ(1, f.memN))]
                    if not MemAlive(u) then
                        set u = NearestMem(f)
                    endif
                    set f.kx[k] = f.sx[i]
                    set f.ky[k] = f.sy[i]
                    set f.ka[k] = AnglePBP(f.sx[i], f.sy[i], GetUnitX(u), GetUnitY(u))
                    set f.kl[k] = RMinBJ(1800, DistancePBP(f.sx[i], f.sy[i], GetUnitX(u), GetUnitY(u)) + 300)
                    // 검이 떠오르며 빛남 (탄약 소모)
                    call FxAt(FX_FLASH_RED, f.sx[i], f.sy[i], 1.2, f.ka[k])
                    call StuckSwordRemove(f, i)
                    call TeleLine(f, f.kx[k], f.ky[k], f.ka[k], f.kl[k] + 70, 140, 1.2 + 0.15 * k)
                    set k = k + 1
                endif
                set tries = tries + 1
            endloop
            set u = null
            set f.snipeLeft = k
            set f.step = 1
        elseif f.step == 1 and el >= 1.2 + 0.15 * f.wave then
            set k = f.wave
            if ModuloInteger(k, 2) == 0 then
                call ProjSpawn(f, 3, FX_THROW_KANSHOU, f.kx[k], f.ky[k], f.ka[k], 1800, f.kl[k], 70, DMG_LAUNCH, 1.4)
            else
                call ProjSpawn(f, 3, FX_THROW_BAKUYA, f.kx[k], f.ky[k], f.ka[k], 1800, f.kl[k], 70, DMG_LAUNCH, 1.4)
            endif
            call FxAt(FX_BURST, f.kx[k], f.ky[k], 0.7, f.ka[k])
            set f.wave = f.wave + 1
            if f.wave >= f.snipeLeft then
                set f.step = 2
            endif
        elseif f.step == 2 and ProjCount(f, 3) == 0 and el >= 2.6 then
            call PatternDone(f, REST_BIG)
        endif
    endfunction

    // ======================================================================
    // A13. 칼날의 숲 (우리): 플레이어마다 검 벽 네모 우리가 떨어진다. 출구는 한 곳.
    //   0     우리 벽 예고(직선) + 출구 초록 원 + 우리 안 위험 표시
    //   1.5   벽이 선다 (닿으면 피해·밀려남). 우리 안에 검의 비 예고(빨간 원)
    //   3.5   우리 안 검의 비 (안에 남아 있으면 큰 피해 + 기절)
    //   4.2   벽을 사이에 둔 저격 2번 (예고 1초). 벽이 화살을 막으니 벽 뒤로 숨는다
    //   8.0   벽이 무너진다
    // ======================================================================
    private function ForestSeg takes ArcherFight f, real x1, real y1, real x2, real y2 returns nothing
        if f.kn >= 32 then
            return
        endif
        if DistancePBP(x1, y1, x2, y2) < 40 then
            return
        endif
        set f.kx[f.kn] = x1
        set f.ky[f.kn] = y1
        set f.ka[f.kn] = AnglePBP(x1, y1, x2, y2)
        set f.kl[f.kn] = DistancePBP(x1, y1, x2, y2)
        call TeleLine(f, x1, y1, f.ka[f.kn], f.kl[f.kn], WALL_HALF * 2, FOREST_TELL)
        set f.kn = f.kn + 1
    endfunction

    // (cx, cy) 둘레 네모 우리. 출구는 전장 가장자리 쪽이 아닌 무작위 변의 가운데 근처
    private function ForestCage takes ArcherFight f, real cx, real cy returns nothing
        local rect r = MapRectReturn(f.rect)
        local real h = FOREST_HALF
        local real g = FOREST_GAP * 0.5
        local integer side = GetRandomInt(0, 3)
        local integer tries = 0
        local real mx
        local real my
        local real off
        local integer k
        local real x1
        local real y1
        local real x2
        local real y2
        // 출구가 전장 끝(250 안)을 향하면 다른 변
        loop
            exitwhen tries >= 4
            if side == 0 then
                set mx = cx + h
                set my = cy
            elseif side == 1 then
                set mx = cx
                set my = cy + h
            elseif side == 2 then
                set mx = cx - h
                set my = cy
            else
                set mx = cx
                set my = cy - h
            endif
            exitwhen mx > GetRectMinX(r) + 250 and mx < GetRectMaxX(r) - 250 and my > GetRectMinY(r) + 250 and my < GetRectMaxY(r) - 250
            set side = ModuloInteger(side + 1, 4)
            set tries = tries + 1
        endloop
        set off = GetRandomReal(-h * 0.4, h * 0.4)
        // 네 변: 0 동(아래→위), 1 북(오른→왼), 2 서(위→아래), 3 남(왼→오른)
        set k = 0
        loop
            exitwhen k >= 4
            if k == 0 then
                set x1 = cx + h
                set y1 = cy - h
                set x2 = cx + h
                set y2 = cy + h
            elseif k == 1 then
                set x1 = cx + h
                set y1 = cy + h
                set x2 = cx - h
                set y2 = cy + h
            elseif k == 2 then
                set x1 = cx - h
                set y1 = cy + h
                set x2 = cx - h
                set y2 = cy - h
            else
                set x1 = cx - h
                set y1 = cy - h
                set x2 = cx + h
                set y2 = cy - h
            endif
            if k == side then
                // 변 가운데(off 만큼 비킨 곳)에 출구: 두 조각으로 나눈다
                call ForestSeg(f, x1, y1, (x1 + x2) * 0.5 + PolarX(off - g, AnglePBP(x1, y1, x2, y2)), (y1 + y2) * 0.5 + PolarY(off - g, AnglePBP(x1, y1, x2, y2)))
                call ForestSeg(f, (x1 + x2) * 0.5 + PolarX(off + g, AnglePBP(x1, y1, x2, y2)), (y1 + y2) * 0.5 + PolarY(off + g, AnglePBP(x1, y1, x2, y2)), x2, y2)
                // 출구 표시 (초록)
                call Decal(f, (x1 + x2) * 0.5 + PolarX(off, AnglePBP(x1, y1, x2, y2)), (y1 + y2) * 0.5 + PolarY(off, AnglePBP(x1, y1, x2, y2)), g + 20, FOREST_TELL + FOREST_RAIN_WARN, 3)
            else
                call ForestSeg(f, x1, y1, x2, y2)
            endif
            set k = k + 1
        endloop
        set r = null
    endfunction

    private function ForestSnipe takes ArcherFight f, integer n returns nothing
        local integer k = PickSnipeTarget(f)
        if k < 0 then
            return
        endif
        set f.markCount[k] = f.markCount[k] + 1
        set f.target = f.mem[k]
        set f.ang = AngleWBW(f.boss, f.target)
        call Face(f, f.ang)
        set f.tx = GetUnitX(f.target)
        set f.ty = GetUnitY(f.target)
        call Anim(f, AN_CHANNEL_FOUR, 1.0)
        call FxAt(FX_BOW_CHARGE, GetUnitX(f.boss), GetUnitY(f.boss), 0.6, f.ang)
        call TeleLine(f, GetUnitX(f.boss), GetUnitY(f.boss), f.ang, DistancePBP(GetUnitX(f.boss), GetUnitY(f.boss), f.tx, f.ty), 180, 1.0)
        call Decal(f, f.tx, f.ty, 250, 1.0, 0)
    endfunction

    private function RunForest takes ArcherFight f, real el returns nothing
        local integer w
        local integer k
        local integer i
        local integer slot
        local real d
        local unit u
        local real ux
        local real uy
        if f.step == 0 then
            // 플레이어마다 우리 (최대 6), 전장 안으로 당겨 둔다
            set f.kn = 0
            set f.cgn = 0
            set i = 0
            loop
                exitwhen i >= f.memN
                if MemAlive(f.mem[i]) and f.cgn < 6 then
                    set ux = ClampX(f, GetUnitX(f.mem[i]))
                    set uy = ClampY(f, GetUnitY(f.mem[i]))
                    // 이미 있는 우리와 겹치면 그 우리를 같이 쓴다
                    set k = 0
                    set w = 0
                    loop
                        exitwhen k >= f.cgn
                        if DistancePBP(ux, uy, f.cgx[k], f.cgy[k]) < FOREST_HALF * 1.6 then
                            set w = 1
                        endif
                        set k = k + 1
                    endloop
                    if w == 0 then
                        set f.cgx[f.cgn] = ux
                        set f.cgy[f.cgn] = uy
                        set f.cgn = f.cgn + 1
                        call ForestCage(f, ux, uy)
                    endif
                endif
                set i = i + 1
            endloop
            call Anim(f, AN_SPELL_ALT_THREE, 1.0)
            call FxWindup(f)
            call MsgAll(f, "|cFFFF8040칼날의 숲|r - 검 우리에 갇힙니다! 초록 출구로 빠져나가세요. 벽은 화살을 막아 줍니다.", 4.0)
            set i = 0
            loop
                exitwhen i >= 6
                set f.wallHitAt[i] = 0
                set i = i + 1
            endloop
            set f.step = 1
        elseif f.step == 1 and el >= FOREST_TELL then
            // 검이 떨어져 벽이 선다 (조각마다 200 간격)
            set slot = 0
            set k = 0
            loop
                exitwhen k >= f.kn
                set d = 40
                loop
                    exitwhen d > f.kl[k] or slot >= 96
                    set ux = f.kx[k] + PolarX(d, f.ka[k])
                    set uy = f.ky[k] + PolarY(d, f.ka[k])
                    set f.wallFx[slot] = AddSpecialEffect(FX_SWORD_STUCK, ux, uy)
                    call EXEffectMatRotateZ(f.wallFx[slot], GetRandomReal(0, 360))
                    set slot = slot + 1
                    set d = d + 200
                endloop
                // 조각마다 낙하 연출 하나
                call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, f.kx[k] + PolarX(f.kl[k] * 0.5, f.ka[k]), f.ky[k] + PolarY(f.kl[k] * 0.5, f.ka[k])))
                set k = k + 1
            endloop
            set f.forestOn = true
            // 우리 안 검의 비 예고 (빨강)
            set k = 0
            loop
                exitwhen k >= f.cgn
                call Decal(f, f.cgx[k], f.cgy[k], FOREST_HALF - 40, FOREST_RAIN_WARN, 0)
                set k = k + 1
            endloop
            call CameraShaker.setShake(6)
            set f.step = 2
        elseif f.step >= 2 and f.step <= 4 then
            // 벽에 닿으면 피해 + 벽 바깥 쪽으로 밀려남 (사람마다 1초에 한 번)
            set i = 0
            loop
                exitwhen i >= f.memN
                set u = f.mem[i]
                if MemAlive(u) and f.now >= f.wallHitAt[i] then
                    set k = 0
                    loop
                        exitwhen k >= f.kn
                        if SegDist(GetUnitX(u), GetUnitY(u), f.kx[k], f.ky[k], f.kx[k] + PolarX(f.kl[k], f.ka[k]), f.ky[k] + PolarY(f.kl[k], f.ka[k])) <= WALL_HALF then
                            call Deal(f, u, DMG_WALL, false)
                            if (GetUnitX(u) - f.kx[k]) * Cos((f.ka[k] + 90) * bj_DEGTORAD) + (GetUnitY(u) - f.ky[k]) * Sin((f.ka[k] + 90) * bj_DEGTORAD) >= 0 then
                                call Knockback(u, f.ka[k] + 90, 200, 0.2)
                            else
                                call Knockback(u, f.ka[k] - 90, 200, 0.2)
                            endif
                            set f.wallHitAt[i] = f.now + 1.0
                            set k = f.kn
                        endif
                        set k = k + 1
                    endloop
                endif
                set i = i + 1
            endloop
            set u = null
            if f.step == 2 and el >= FOREST_TELL + FOREST_RAIN_WARN then
                // 우리 안 검의 비
                set k = 0
                loop
                    exitwhen k >= f.cgn
                    call HitCircle(f, f.cgx[k], f.cgy[k], FOREST_HALF - 40, DMG_FOREST_RAIN, true, 0)
                    set w = 0
                    loop
                        exitwhen w >= 4
                        set ux = f.cgx[k] + GetRandomReal(-FOREST_HALF * 0.6, FOREST_HALF * 0.6)
                        set uy = f.cgy[k] + GetRandomReal(-FOREST_HALF * 0.6, FOREST_HALF * 0.6)
                        call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, ux, uy))
                        call FxAt(FX_SPARKS, ux, uy, 1.0, 0)
                        set w = w + 1
                    endloop
                    call FxAt(FX_FLASH_RED, f.cgx[k], f.cgy[k], 3.0, 0)
                    set k = k + 1
                endloop
                call CameraShaker.setShake(8)
                set f.wave = 0
                set f.step = 3
            elseif f.step == 3 then
                // 벽 너머 저격 2번: 예고 1초 → 발사 (벽에 막힌다)
                if f.wave < 4 and el >= FOREST_TELL + FOREST_RAIN_WARN + 0.7 + 1.5 * (f.wave / 2) + ModuloInteger(f.wave, 2) * 1.0 then
                    if ModuloInteger(f.wave, 2) == 0 then
                        call ForestSnipe(f, f.wave)
                    else
                        call Anim(f, AN_CHANNEL_FIVE, 1.0)
                        call VoiceCalad(f)
                        call FxMuzzle(f, f.ang)
                        call ProjSpawn(f, 2, FX_SNIPE_BOLT, GetUnitX(f.boss), GetUnitY(f.boss), f.ang, 3000, RMaxBJ(50, DistancePBP(GetUnitX(f.boss), GetUnitY(f.boss), f.tx, f.ty)), 90, DMG_SNIPE, 1.4)
                    endif
                    set f.wave = f.wave + 1
                endif
                if el >= FOREST_TELL + FOREST_TIME * 0.8 then
                    set f.step = 4
                endif
            elseif f.step == 4 and ProjCount(f, 2) == 0 then
                // 벽이 무너진다
                set f.forestOn = false
                set i = 0
                loop
                    exitwhen i >= 96
                    if f.wallFx[i] != null then
                        if ModuloInteger(i, 4) == 0 then
                            call FxAt(FX_SPARKS, EXGetEffectX(f.wallFx[i]), EXGetEffectY(f.wallFx[i]), 0.8, 0)
                        endif
                        call SwordFxRemove(f.wallFx[i])
                        set f.wallFx[i] = null
                    endif
                    set i = i + 1
                endloop
                set f.kn = 0
                set f.patStart = f.now
                set f.step = 5
            endif
        elseif f.step == 5 and el >= 1.0 then
            call PatternDone(f, REST_BIG)
        endif
    endfunction

    // ======================================================================
    // A14. 투영 복제: 표식 대상 영웅의 대표기 모양을 복제해 되돌려 준다. 예고 중 누구나 카운터 가능
    //   지크프리트 = 직선 검기, 첸 = 돌진 베기, 루시아 = 돌진 찌르기, 나르메아 = 앞쪽 넓은 베기,
    //   모미지 = 대상 위치 원형, 반디 = 보스 주변 원형(반경 500 이라 예고 2초)
    // ======================================================================
    private function TraceShape takes unit u returns integer
        local integer id = GetUnitTypeId(u)
        if id == 'H01S' or id == 'H01T' then
            return 1
        elseif id == 'H004' then
            return 2
        elseif id == 'H00P' then
            return 3
        elseif id == 'H00I' then
            return 4
        elseif id == 'H003' then
            return 5
        elseif id == 'H00K' then
            return 6
        endif
        return 1
    endfunction

    private function TraceName takes integer shape returns string
        if shape == 1 then
            return "투영: 직선 검기"
        elseif shape == 2 then
            return "투영: 돌진 베기"
        elseif shape == 3 then
            return "투영: 돌진 찌르기"
        elseif shape == 4 then
            return "투영: 나비 부채"
        elseif shape == 5 then
            return "투영: 파동"
        endif
        return "투영: 폭쇄"
    endfunction

    private function TraceTell takes integer shape returns real
        if shape == 6 then
            return 2.0
        endif
        return TRACE_TELL
    endfunction

    private function RunTrace takes ArcherFight f, real el returns nothing
        local real bx = GetUnitX(f.boss)
        local real by = GetUnitY(f.boss)
        local real nx
        local real ny
        local real step
        local texttag tt
        if f.step == 0 then
            if not MemAlive(f.target) then
                call PatternDone(f, REST_SHORT)
                return
            endif
            set f.wave = TraceShape(f.target)
            set f.ang = AngleWBW(f.boss, f.target)
            call Face(f, f.ang)
            set f.tx = GetUnitX(f.target)
            set f.ty = GetUnitY(f.target)
            set f.ax = bx
            set f.ay = by
            call Anim(f, AN_STANDREADY_ALT, 1.0)
            call FxWindup(f)
            call FxAt(FX_FLASH_WHITE, bx, by, 8.0, 0)
            call FxAt(FX_TRACE_CAST, bx, by, 1.0, 0)
            set f.voiceUntil = 0
            call Voice(f, VO_TRACE, VO_TRACE_T)
            // 머리 위 '투영: 기술 이름'
            set tt = CreateTextTag()
            call SetTextTagText(tt, TraceName(f.wave), 0.026)
            call SetTextTagPos(tt, bx, by, 260)
            call SetTextTagColor(tt, 255, 120, 120, 255)
            call SetTextTagPermanent(tt, false)
            call SetTextTagLifespan(tt, TraceTell(f.wave) + 0.5)
            call SetTextTagFadepoint(tt, TraceTell(f.wave))
            call SetTextTagVisibility(tt, true)
            set tt = null
            // 예고 = 판정
            if f.wave == 1 then
                call TeleLine(f, bx, by, f.ang, 1100, 260, TraceTell(f.wave))
            elseif f.wave == 2 or f.wave == 3 then
                set f.dashLen = RMinBJ(900, DistancePBP(bx, by, f.tx, f.ty) + 200)
                call TeleLine(f, bx, by, f.ang, f.dashLen + DASH_REACH, DASH_WIDTH, TraceTell(f.wave))
            elseif f.wave == 4 then
                call TeleRect(f, TELE_WIDE, TELE_WIDE_W, bx, by, f.ang, 600, 700, TraceTell(f.wave))
            elseif f.wave == 5 then
                call Decal(f, f.tx, f.ty, 350, TraceTell(f.wave), 0)
            else
                call Decal(f, bx, by, 500, TraceTell(f.wave), 0)
            endif
            // 카운터 가능 (다른 보스와 같은 신호)
            call UnitAddAbility(f.boss, 'A00V')
            call SetUnitVertexColorBJ(f.boss, 70, 70, 100, 0)
            set f.cue[0] = UnitEffectTimeEX('e00F', bx, by, 0, 3)
            set f.cue[1] = UnitEffectTimeEX('e00G', bx, by, 0, 3)
            set f.cue[2] = UnitEffectTimeEX('e01S', bx, by, 0, 3)
            set f.step = 1
        elseif f.step == 1 then
            if GetUnitAbilityLevel(f.boss, 'A00V') == 0 then
                // 카운터 성공: 복제가 부서지고 그로기
                call VoiceHit(f)
                call ClearDecals(f)
                call CueClear(f)
                call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
                call Sound3D(f.boss, 'A00U')
                call FxAt(FX_SHATTER, bx, by, 0.6, f.ang)
                call AnimDown(f)
                set f.patStart = f.now
                set f.step = 4
            elseif el >= TraceTell(f.wave) then
                call UnitRemoveAbility(f.boss, 'A00V')
                call CueClear(f)
                call SetUnitVertexColor(f.boss, 255, 255, 255, 255)
                if f.wave == 2 or f.wave == 3 then
                    call Anim(f, AN_ATTACK1, 1.5)
                    set f.dashLeft = f.dashLen
                    set f.dashSpeed = 1600
                    call FxDash(f)
                    set f.step = 2
                else
                    call Anim(f, AN_ATTACK_ALT, 1.5)
                    if f.wave == 1 then
                        call HitRect(f, bx, by, f.ang, 1100, 260, DMG_TRACE, true, 0)
                        call FxAt(FX_SNIPE_BOOM, bx + PolarX(150, f.ang), by + PolarY(150, f.ang), 1.2, f.ang)
                        call FxHitBig(f, bx + PolarX(550, f.ang), by + PolarY(550, f.ang), f.ang, 1.2)
                    elseif f.wave == 4 then
                        call HitRect(f, bx, by, f.ang, 600, 700, DMG_TRACE, true, 0)
                        call FxCut(bx, by, f.ang, 0, 25, 600, false)
                        call FxCut(bx, by, f.ang, 0, -25, 600, true)
                        call FxHitBig(f, bx + PolarX(300, f.ang), by + PolarY(300, f.ang), f.ang, 1.2)
                    elseif f.wave == 5 then
                        call HitCircle(f, f.tx, f.ty, 350, DMG_TRACE, true, 0)
                        call FxHitBig(f, f.tx, f.ty, f.ang, 1.3)
                    else
                        call HitCircle(f, bx, by, 500, DMG_TRACE, true, 0)
                        call FxHitBig(f, bx, by, f.ang, 1.6)
                    endif
                    set f.patStart = f.now
                    set f.step = 3
                endif
            endif
        elseif f.step == 2 then
            set step = RMinBJ(f.dashLeft, f.dashSpeed * TICK)
            set nx = ClampX(f, bx + PolarX(step, f.ang))
            set ny = ClampY(f, by + PolarY(step, f.ang))
            call SetUnitPosition(f.boss, nx, ny)
            call HitRect(f, f.ax, f.ay, f.ang, DistancePBP(f.ax, f.ay, nx, ny) + DASH_REACH, DASH_WIDTH, DMG_TRACE, true, f.hit)
            set f.dashLeft = f.dashLeft - step
            if f.dashLeft <= 0 then
                call FxCut(nx, ny, f.ang, 0, 0, 400, true)
                call FxHitBig(f, nx, ny, f.ang, 1.0)
                set f.patStart = f.now
                set f.step = 3
            endif
        elseif f.step == 3 and el >= 1.0 then
            call PatternDone(f, REST_BIG)
        elseif f.step == 4 and el >= TRACE_GROGGY then
            call PatternDone(f, REST_SHORT)
        endif
    endfunction

    private function RunPattern takes ArcherFight f returns nothing
        local real el = f.now - f.patStart
        if f.pat == 1 then
            if f.state == ARCHER_PHASE2 then
                call RunVolley(f, el)
            else
                call RunA1(f, el)
            endif
        elseif f.pat == 2 then
            call RunA2(f, el)
        elseif f.pat == 3 then
            call RunA3(f, el)
        elseif f.pat == 4 then
            call RunA4(f, el)
        elseif f.pat == 5 then
            call RunA5(f, el)
        elseif f.pat == 6 then
            call RunA6(f, el)
        elseif f.pat == 8 then
            call RunRho(f, el)
        elseif f.pat == 9 then
            call RunPhantasm(f, el)
        elseif f.pat == 10 then
            call RunHrunting(f, el)
        elseif f.pat == 11 then
            call RunKakuyoku(f, el)
        elseif f.pat == 12 then
            call RunLaunch(f, el)
        elseif f.pat == 13 then
            call RunForest(f, el)
        elseif f.pat == 14 then
            call RunTrace(f, el)
        elseif f.pat == 16 then
            call RunAllBlade(f, el)
        endif
    endfunction

    // ======================================================================
    // 영창 예약·재생과 페이즈 전환
    // ======================================================================
    private function SetProtect takes ArcherFight f, boolean floorOn, boolean lock returns nothing
        local integer idx = IndexUnit(f.boss)
        set UnitHPFloorOn[idx] = floorOn
        set UnitHPFloor[idx] = 1.0
        set UnitDamageLock[idx] = lock
    endfunction

    // 피해 직후 HP 구간을 넘은 만큼 영창을 예약한다 (여러 구간을 한 번에 넘겨도 순서대로)
    private function ReserveChants takes ArcherFight f returns nothing
        local integer idx = IndexUnit(f.boss)
        local real pct = UnitHP[idx] / UnitHPMAX[idx]
        loop
            // 체력바 한 줄(1/8)을 다 깎을 때마다 영창 하나:
            //  1~6줄 → 영창 1~6, 7줄 → "So as I pray", 8줄(마지막 줄, 1페이즈 하한 HP 1) → "Unlimited Blade Works!" 와 결계 전개
            exitwhen f.chantReserved >= 8
            if f.chantReserved >= 7 then
                exitwhen UnitHP[idx] > 1.5
            else
                exitwhen pct > (7 - f.chantReserved) / 8.0
            endif
            set f.chantReserved = f.chantReserved + 1
        endloop
        if f.chantReserved >= 8 and f.state == ARCHER_PHASE1 then
            // 마지막 영창 예약: 새 패턴 선택 보류
            set f.state = ARCHER_TRANSITION_PENDING
        endif
    endfunction

    private function PlayChant takes ArcherFight f, integer k returns nothing
        set f.chantPlaying = true
        set f.chantEnd = f.now + ChantDur[k]
        // 영창 중에는 다른 대사를 끼우지 않는다
        set f.voiceUntil = f.chantEnd
        call PlaySoundPath(f, ChantSound[k])
        call MsgAll(f, "|cFFFFD080아쳐|r: " + ChantText[k], ChantDur[k] + 1.0)
    endfunction

    private function StartTransition takes ArcherFight f returns nothing
        set f.state = ARCHER_TRANSITION
        set f.transStart = f.now
        set f.transStep = 0
        // 공격 정리, 피해·카운터 잠금
        call CancelAttacks(f)
        call SetProtect(f, true, true)
        // 전장 중앙으로
        call SetUnitPosition(f.boss, f.arenaCX(), f.arenaCY())
        call Face(f, 270)
        // 선언: 빈손을 앞으로 내밀며 "Unlimited Blade Works!" (대사 0~2.2초, 뒤는 결계 전개 효과음)
        call Anim(f, AN_SPELL_ONE, 1.0)
        set f.chantPlaying = false
        set f.voiceUntil = 0
        call Voice(f, FINAL_SOUND, FINAL_SOUND_T)
        call MsgAll(f, "|cFFFFD080아쳐|r: Unlimited Blade Works! (무한의 검제)", 4.0)
        call DestroyEffect(AddSpecialEffectTarget(FX_TRANSITION, f.boss, "origin"))
        call DestroyEffect(AddSpecialEffectTarget(FX_GATHER, f.boss, "chest"))
        call DestroyEffect(AddSpecialEffect(FX_CHARGE, f.arenaCX(), f.arenaCY()))
        call LocalFilter(f, true, TRANS_DEPLOY * 0.5)
    endfunction

    private function UpdateTransition takes ArcherFight f returns nothing
        local real el = f.now - f.transStart
        local integer idx = IndexUnit(f.boss)
        if f.transStep == 0 and el >= 1.4 then
            // 선언 중 빈손 자세 유지 (stand slam 반복)
            call Anim(f, AN_STAND_SLAM, 1.0)
            set f.transStep = 1
        elseif f.transStep == 1 and el >= TRANS_DEPLOY then
            // 전장 타일·배경을 검의 황야로. morph: 쌍검이 사라지고 활이 나타난다
            call TerrainApply(f)
            call StuckSwordsCreate(f)
            // 전개 연출: 불꽃 고리가 전장 중심에서 퍼지고, 하늘에 톱니바퀴가 걸린다
            call FxKeep(f, FX_FIRE_RING, f.arenaCX(), f.arenaCY(), 1.2, 0, 1.0)
            call FxAt(FX_FLASH_WHITE, f.arenaCX(), f.arenaCY(), 12.0, 0)
            call FxAt(FX_BURST, f.arenaCX(), f.arenaCY(), 3.0, 0)
            call FxAt(FX_FLASH_RED, f.arenaCX(), f.arenaCY(), 4.0, 0)
            // 뷰어 확인: 1.6배는 높이 5000 으로 게임 화면을 다 덮었다 → 0.6배 (반경 약 350~800)
            call FxAt(FX_UBW_FIRE, f.arenaCX(), f.arenaCY(), 0.6, 0)
            // 보스 둘레에 검이 쏟아져 꽂힌다
            call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, f.arenaCX() + 500, f.arenaCY()))
            call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, f.arenaCX() - 500, f.arenaCY()))
            call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, f.arenaCX(), f.arenaCY() + 500))
            call DestroyEffect(AddSpecialEffect(FX_SWORD_FALL, f.arenaCX(), f.arenaCY() - 500))
            call GearsCreate(f)
            call CameraShaker.setShake(10)
            set f.transStep = 2
            call Anim(f, AN_MORPH, 1.0)
        elseif f.transStep == 2 and el >= TRANS_DEPLOY + 0.5 then
            // 결계 전개 완료: 최대 체력까지 회복
            set f.chantPlaying = false
            set f.chantDone = 8
            set UnitHP[idx] = UnitHPMAX[idx]
            call MsgAll(f, "|cFFFF4040무한의 검제|r", 4.0)
            call Anim(f, AN_STANDREADY_ALT, 1.0)
            set f.transStep = 3
        elseif f.transStep == 3 and el >= TRANS_DEPLOY + 2.0 then
            // 2페이즈 시작: 보호 해제, 쿨다운 초기화
            call LocalFilter(f, false, 0)
            call SetProtect(f, false, false)
            set f.readyAt[1] = f.now
            set f.readyAt[2] = f.now
            set f.readyAt[3] = f.now
            set f.readyAt[4] = f.now
            set f.readyAt[5] = f.now
            set f.readyAt[6] = f.now
            set f.readyAt[7] = f.now
            set f.readyAt[8] = f.now
            set f.readyAt[9] = f.now
            set f.readyAt[10] = f.now
            set f.readyAt[11] = f.now
            set f.readyAt[12] = f.now
            set f.readyAt[13] = f.now
            set f.readyAt[14] = f.now
            // 결계 규칙 시작 (전장 변경·검·톱니바퀴는 영창 중 이미 펼쳐짐). 결계는 끝까지 유지
            call UbwBegin(f)
            set f.lastPat = 0
            set f.nextSelect = f.now
            set f.state = ARCHER_PHASE2
            call Anim(f, AN_STAND_ALT, 1.0)
            // 첫 2페이즈 패턴은 검의 비
            call StartPattern(f, 5)
        endif
    endfunction

    private function UpdateChant takes ArcherFight f returns nothing
        local integer k
        if f.chantPlaying and f.now >= f.chantEnd then
            set f.chantPlaying = false
            set f.chantDone = f.chantDone + 1
        endif
        if not f.chantPlaying and f.chantDone < f.chantReserved and f.now >= f.voiceUntil then
            set k = f.chantDone + 1
            if k >= 8 then
                // HP 10%: "Unlimited Blade Works!" 선언과 결계 전개
                call StartTransition(f)
            elseif k == 7 then
                // HP 20%: 마지막 구절 "So as I pray..." (ChantSound[8] 녹음). 결계는 아직 펼치지 않는다
                // (예전 7번 자리의 "그런가. 그럼, 연철의 불을 밝히지."는 영창이 아니라서 뺐다)
                call PlayChant(f, 8)
            else
                call PlayChant(f, k)
            endif
        endif
    endfunction

    // ======================================================================
    // 종료
    // ======================================================================
    private function SuccessF takes nothing returns nothing
        call SuccessStart(GetEnumUnit())
        call OverlayStop(GetPlayerId(GetOwningPlayer(GetEnumUnit())))
    endfunction

    private function AllDie takes nothing returns nothing
        call FailedStart(GetEnumUnit())
        call OverlayStop(GetPlayerId(GetOwningPlayer(GetEnumUnit())))
    endfunction

    // 종료 정리 단계: 단계마다 새 스레드(.evaluate)로 돌려 한 단계가 멈춰도 나머지는 계속된다.
    // 스레드가 끝까지 가면 FinOk 가 true. 멈춘 단계는 이름을 화면에 남긴다 (원인 추적용)
    globals
        private boolean FinOk = false
    endglobals

    private function FinCancel takes ArcherFight f returns nothing
        call CancelAttacks(f)
        set FinOk = true
    endfunction
    private function FinTerrain takes ArcherFight f returns nothing
        call TerrainRestore(f)
        set FinOk = true
    endfunction
    private function FinSwords takes ArcherFight f returns nothing
        call StuckSwordsDestroy(f)
        set FinOk = true
    endfunction
    private function FinFx takes ArcherFight f returns nothing
        call FxUpdate(f, true)
        call TeleUpdate(f, true)
        set FinOk = true
    endfunction
    private function FinView takes ArcherFight f returns nothing
        call LocalFilter(f, false, 0)
        call CameraShaker.stopShake()
        set FinOk = true
    endfunction
    private function FinPull takes ArcherFight f returns nothing
        call PullClear(f)
        set FinOk = true
    endfunction
    private function FinAggro takes ArcherFight f returns nothing
        call BossAggroDestroy(f.boss)
        set FinOk = true
    endfunction
    private function FinMusic takes ArcherFight f returns nothing
        if f.ubw then
            call UbwMusic(f, false)
        endif
        set f.ubw = false
        if f.patTag != null then
            call DestroyTextTag(f.patTag)
            set f.patTag = null
        endif
        set FinOk = true
    endfunction

    private function FinCheck takes string step returns nothing
        if not FinOk then
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "|cFFFF4040[아쳐] 종료 정리 중 멈춘 단계:|r " + step)
        endif
        set FinOk = false
    endfunction

    // 종료: 보스 처치·대사를 먼저 하고, 무거운 정리(전장 타일 복구, 효과·검 제거)는 각각 새 스레드에서 한다.
    // 한 스레드에서 모두 하다 명령 수 한도에 걸려 중간에 멈추면 보스가 죽지 않고 HP 가 음수로 남았다
    private function Finish takes ArcherFight f, boolean win returns nothing
        local integer i = 0
        local integer idx = IndexUnit(f.boss)
        set f.state = ARCHER_ENDED
        call SetProtect(f, false, false)
        // 유닛 번호는 재사용되므로 보스별 판정 설정을 되돌린다
        set UnitCounterArc[idx] = 0
        set UnitPullTarget[idx] = false
        set UnitFrontGuard[idx] = false
        // 결과 처리(성공·실패 화면, 귀환 예약)를 정리보다 먼저 한다. 참가자 목록(f.mem)으로 처리해 파티 그룹이 비어 있어도 빠지지 않게
        if win then
            set UnitHP[idx] = 0
            call SetUnitTimeScale(f.boss, 1.0)
            call PlaySoundPath(f, VO_DEATH)
            call SetUnitAnimationByIndex(f.boss, 20)
            // 쓰러짐: 흰 섬광 + 빛기둥 파편 + 퍼지는 고리 + 파편 (한 번)
            call FxAt(FX_FLASH_WHITE, GetUnitX(f.boss), GetUnitY(f.boss), 8.0, 0)
            call FxAt(FX_SHATTER, GetUnitX(f.boss), GetUnitY(f.boss), 0.6, f.face)
            call FxAt(FX_BURST, GetUnitX(f.boss), GetUnitY(f.boss), 1.5, f.face)
            call FxAt(FX_SPARKS, GetUnitX(f.boss), GetUnitY(f.boss), 1.5, 0)
            call CameraShaker.setShake(8)
            call KillUnit(f.boss)
            call MsgAll(f, "|cFFFFD040아쳐 격파!|r", 5.0)
        else
            call PlaySoundPath(f, VO_WIPE)
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
        call FinTerrain.evaluate(f)
        call FinCheck("전장 타일 복구")
        call FinSwords.evaluate(f)
        call FinCheck("꽂힌 검 제거")
        call FinFx.evaluate(f)
        call FinCheck("효과·예고 제거")
        call FinView.evaluate(f)
        call FinCheck("화면 필터·흔들림")
        call FinPull.evaluate(f)
        call FinCheck("뽑은 검 표시")
        call FinAggro.evaluate(f)
        call FinCheck("어그로")
        call FinMusic.evaluate(f)
        call FinCheck("배경음악·글자")
        if win then
            call BossMapReset(f.rect, ARENA_THEMA)
        else
            call KillUnit(f.boss)
            call RemoveUnit(f.boss)
            call MapReset(f.rect, ARENA_THEMA)
        endif
        set ArcherFightAt[f.rect] = 0
        call f.t.destroy()
        if f.hit != 0 then
            call f.hit.destroy()
            set f.hit = 0
        endif
        call DestroyGroup(f.decals)
        call DestroyGroup(f.rainDecals)
        set f.rainDecals = null
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
    // 패턴 사이 움직임: 대상을 향해 돌고, 거리를 맞추며 옆으로 돈다 (멍하니 서 있지 않게)
    // ======================================================================
    private function IdleMove takes ArcherFight f returns nothing
        local unit u
        local real bx
        local real by
        local real d
        local real a
        local real nx
        local real ny
        local real step
        if f.state != ARCHER_PHASE1 and f.state != ARCHER_PHASE2 then
            return
        endif
        set bx = GetUnitX(f.boss)
        set by = GetUnitY(f.boss)
        // 짧은 걸음 진행 중 (방향은 걸음 전에 맞춰 둔다)
        if f.walking then
            set step = RMinBJ(f.stepLeft, f.stepSpd * TICK)
            set nx = ClampX(f, bx + PolarX(step, f.stepAng))
            set ny = ClampY(f, by + PolarY(step, f.stepAng))
            call SetUnitPosition(f.boss, nx, ny)
            set f.stepLeft = f.stepLeft - step
            if f.stepLeft <= 0 or (nx == bx and ny == by) then
                set f.walking = false
                call AnimIdle(f)
            endif
            return
        endif
        set u = PickTarget(f)
        if u == null then
            return
        endif
        set d = DistancePBP(bx, by, GetUnitX(u), GetUnitY(u))
        set a = AnglePBP(bx, by, GetUnitX(u), GetUnitY(u))
        set u = null
        // 쓰러져 있는 동안(집중 공격 기회)은 돌지도 않는다
        if f.now < f.holdUntil then
            return
        endif
        // 패턴 사이: 전투 대기 자세로 대상을 향해 돌아본다
        call TurnToward(f, a, IDLE_TURN * TICK)
        if f.now < f.nextStepAt or AngDiff(a, f.face) > 20 then
            return
        endif
        // 거리가 크게 어긋났을 때만 짧게 한 번 움직인다 (계속 걷지 않음)
        if f.state == ARCHER_PHASE2 and d < STEP_NEAR2 then
            // 활: 너무 붙으면 뒤로 물러난다 (뒷걸음 동작이 없으므로 대기 자세 + 잔상)
            set f.stepAng = a + 180
            set f.stepLeft = STEP_BACK
            set f.stepSpd = STEP_BACK / 0.4
            call FxDash(f)
        elseif (f.state == ARCHER_PHASE2 and d > STEP_FAR2) or (f.state == ARCHER_PHASE1 and d > STEP_FAR1) then
            // 멀면 앞으로 걷는다: 바라보는 방향 = 걷는 방향
            set f.stepAng = f.face
            set f.stepLeft = RMinBJ(STEP_FWD, d - STEP_FAR1 * 0.6)
            set f.stepSpd = STEP_FWD_SPEED
            if f.state == ARCHER_PHASE2 then
                call Anim(f, AN_WALK_ALT, STEP_FWD_SPEED / STEP_WALK_SPEED)
            else
                call Anim(f, AN_WALK, STEP_FWD_SPEED / STEP_WALK_SPEED)
            endif
        else
            return
        endif
        set f.walking = true
        set f.nextStepAt = f.now + STEP_COOL
    endfunction

    // ======================================================================
    // 전투 틱
    // ======================================================================
    private function BattleTick takes nothing returns nothing
        local tick t = tick.getExpired()
        local ArcherFight f = t.data
        local integer idx

        if f.state == ARCHER_ENDED then
            return
        endif
        set f.now = f.now + TICK
        set idx = IndexUnit(f.boss)
        // 2페이즈 정상 처치 (다른 처리보다 먼저)
        if f.state == ARCHER_PHASE2 and (UnitHP[idx] <= 0 or IsUnitDeadVJ(f.boss)) then
            call Finish(f, true)
            return
        endif
        // 전멸
        if AliveCount(f) == 0 then
            call Finish(f, false)
            return
        endif
        call FxUpdate(f, false)
        call TeleUpdate(f, false)
        call PatNameFollow(f)
        // 1페이즈 보호는 피해 경로(HeroDeal/CutInDeal)에서 즉시 처리. 여기서는 한 번 더 보정만 한다
        if (f.state == ARCHER_PHASE1 or f.state == ARCHER_TRANSITION_PENDING or f.state == ARCHER_TRANSITION) and UnitHP[idx] < 1 then
            set UnitHP[idx] = 1
        endif

        // 반복하지 않는 동작이 끝나면 현재 무기 자세의 대기 동작으로 돌아간다
        if f.animEnd > 0 and f.now >= f.animEnd then
            set f.animEnd = 0
            call AnimIdle(f)
        endif

        if f.state == ARCHER_PHASE1 or f.state == ARCHER_TRANSITION_PENDING then
            call ReserveChants(f)
            call UpdateChant(f)
        endif
        if f.state == ARCHER_TRANSITION then
            call UpdateTransition(f)
            call HoldFacing(f)
            return
        endif

        // 무력화 자세 고정
        if f.downFreeze > 0 and f.now >= f.downFreeze then
            set f.downFreeze = 0
            call SetUnitTimeScale(f.boss, 0)
        endif
        call ProjUpdate(f)
        if f.state == ARCHER_PHASE2 then
            call UbwTick(f)
            call AllBladeCheck(f)
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
        // 패턴 시작·재조준에서 정한 방향을 다음 Face 까지 유지 (헤드·백 판정 기준)
        call HoldFacing(f)
    endfunction

    // ======================================================================
    // 입장
    // ======================================================================
    private function NoRemove takes nothing returns nothing
        local integer pid = GetPlayerId(GetOwningPlayer(GetEnumUnit()))
        local ArcherFight f = CheckFight
        call ResetPlayerPotionCharges(pid)
        if GetLocalPlayer() == GetOwningPlayer(GetEnumUnit()) then
            call PlayersBossBarShow(GetLocalPlayer(), true)
            call DzFrameShow(BossTip, false)
        endif
        call BOSSHPSTART(f.boss, pid)
        call Overlay(pid)
        if f.memN < 6 then
            set f.mem[f.memN] = GetEnumUnit()
            set f.markCount[f.memN] = 0
            set f.memN = f.memN + 1
        endif
    endfunction

    private function StartBattle takes ArcherFight f returns nothing
        local integer idx
        local integer n
        local real hpRate

        set f.boss = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), ARCHER_UNIT_ID, f.arenaCX(), f.arenaCY(), 270)
        call BossAggroInitialize(f.boss, f.ul.super)
        set idx = IndexUnit(f.boss)
        set Unitstate[idx] = 0
        call UnitRemoveAbility(f.boss, 'Amov')
        call SetUnitPathing(f.boss, false)
        call PauseUnit(f.boss, true)
        call SetUnitPosition(f.boss, f.arenaCX(), f.arenaCY())
        call Face(f, 270)
        set UnitCounterArc[idx] = COUNTER_ARC
        // 뽑은 검 공격을 받는 보스
        set UnitPullTarget[idx] = true

        // 체력 배율: 전투 시작 인원 기준. 도중 사망으로 바꾸지 않는다
        set n = CountUnitsInGroup(f.ul.super)
        if n < 1 then
            set n = 1
        endif
        set hpRate = 1.0 + PARTY_HP_BONUS * (n - 1)
        set UnitHPMAX[idx] = UnitSetHP[ARCHER_DATA_INDEX] * hpRate
        set UnitHP[idx] = UnitHPMAX[idx]

        // 구조체 배열은 재사용 시 초기화되지 않으므로 직접 비운다
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
            exitwhen n >= 8
            set f.readyAt[n] = 0
            set n = n + 1
        endloop
        set n = 0
        loop
            exitwhen n >= 24
            set f.fxe[n] = null
            set n = n + 1
        endloop
        set f.gear[0] = null
        set f.gear[1] = null
        set f.gear[2] = null
        set f.gear[3] = null
        set f.cue[0] = null
        set f.cue[1] = null
        set f.cue[2] = null
        set f.readyAt[8] = 0
        set f.readyAt[9] = 0
        set f.readyAt[10] = 0
        set f.readyAt[11] = 0
        set f.readyAt[12] = 0
        set f.readyAt[13] = 0
        set f.readyAt[14] = 0
        set f.readyAt[15] = 0
        set f.readyAt[16] = 0
        set f.readyAt[17] = 0
        set f.ubw = false
        set f.ubwSecond = false
        set n = 0
        loop
            exitwhen n >= 24
            set f.sGlow[n] = null
            set f.sFall[n] = 0
            set n = n + 1
        endloop
        set n = 0
        loop
            exitwhen n >= 96
            set f.wallFx[n] = null
            set n = n + 1
        endloop
        set f.rho = null
        set f.hEff = null
        set f.hLight = null
        set n = 0
        loop
            exitwhen n >= 24
            set f.tele[n] = null
            set n = n + 1
        endloop

        set f.memN = 0
        set CheckFight = f
        call ForGroup(f.ul.super, function NoRemove)
        set CheckFight = 0

        call SetProtect(f, true, false)
        set f.decals = CreateGroup()
        set f.rainDecals = CreateGroup()
        set f.state = ARCHER_PHASE1
        set f.now = 0
        set f.nextSelect = 2.0
        call Anim(f, AN_STAND_READY, 1.0)
        set f.voiceUntil = 0
        set f.gruntAt = 0
        set f.saidKeepUp = false
        set f.bgm = null
        set f.patTag = null
        set f.walking = false
        set f.holdUntil = 0
        set f.downFreeze = 0
        set f.dropWave = 0
        set n = 0
        loop
            exitwhen n >= 64
            set f.dAt[n] = 0
            set n = n + 1
        endloop
        set f.nextStepAt = 0
        call Voice(f, VO_START, VO_START_T)

        set MapRectCheck[f.rect] = false
        set f.t = tick.create(f)
        call f.t.start(TICK, true, function BattleTick)
    endfunction

    private function EntranceTick takes nothing returns nothing
        local tick t = tick.getExpired()
        local ArcherFight f = t.data
        if splash.range(splash.ALLY, f.entrance, GetWidgetX(f.entrance), GetWidgetY(f.entrance), 500, function SplashNothing) == 0 then
            call KillUnit(f.entrance)
            set f.entrance = null
            call t.destroy()
            call StartBattle(f)
        endif
    endfunction

    // 처음 쓰는 모델·텍스처는 불러오는 순간 화면이 멈칫한다. 입장 대기 중에 보이지 않는 곳에서 한 번씩 만들어 미리 불러 둔다
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

    // 시작 지점에서 0.05초마다 하나씩: 크기 0.01 로 한 번 그렸다가 지운다. 마지막에 아쳐·장판 유닛도 잠깐 만들었다 지운다
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
            // 사운드는 음량 0 으로 한 번 틀어 둔다 (첫 재생 무음 방지)
            set snd = CreateSound(PreSnd[PreSndIdx], false, false, false, 10, 10, "DefaultEAXON")
            call SetSoundVolume(snd, 0)
            call StartSound(snd)
            call KillSoundWhenDone(snd)
            set snd = null
            set PreSndIdx = PreSndIdx + 1
            call TimerStart(PreTimer, 0.05, false, function PreloadStep)
        elseif PreUnitA == null then
            set PreUnitA = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), ARCHER_UNIT_ID, x, y, 270)
            set PreUnitB = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), DECAL_ID, x, y, 270)
            call SetUnitScale(PreUnitA, 0.01, 0.01, 0.01)
            call SetUnitScale(PreUnitB, 0.01, 0.01, 0.01)
            call PauseUnit(PreUnitA, true)
            call TimerStart(PreTimer, 0.3, false, function PreloadUnitsEnd)
        endif
    endfunction

    private function PreloadAddSnd takes string path returns nothing
        if path == null or path == "" then
            return
        endif
        call Preload(path)
        set PreSnd[PreSndCount] = path
        set PreSndCount = PreSndCount + 1
    endfunction

    private function PreloadAdd takes string model returns nothing
        call Preload(model)
        set PreModel[PreCount] = model
        set PreCount = PreCount + 1
    endfunction

    // 바닥 자국(스플랫)을 남기는 기본 모델(건물 폭발·전쟁 발구르기·먼지)은 그려서 불러오지 않는다
    // (크기·높이와 상관없이 땅에 구덩이 자국이 남아서 전장에 보였다). 기본 게임 모델이라 파일만 미리 읽는다
    private function PreloadFx takes real x, real y returns nothing
        call PreloadOne(FX_THROW_KANSHOU, x, y)
        call PreloadOne(FX_THROW_BAKUYA, x, y)
        call PreloadOne(FX_SNIPE_BOLT, x, y)
        call PreloadOne(FX_SNIPE_BOOM, x, y)
        call PreloadOne(FX_SNIPE_MARK, x, y)
        call PreloadOne(FX_SLASH_RED, x, y)
        call PreloadOne(FX_SLASH_WHITE, x, y)
        call PreloadOne(FX_SWORD_FALL, x, y)
        call PreloadOne(FX_SWORD_STUCK, x, y)
        call PreloadOne(FX_COUNTER_READY, x, y)
        call PreloadOne(FX_TRANSITION, x, y)
        call PreloadOne(FX_RHO_AIAS, x, y)
        call PreloadOne(FX_GATHER, x, y)
        call PreloadOne(FX_CHARGE, x, y)
        call PreloadOne(FX_FLASH_RED, x, y)
        call PreloadOne(FX_FLASH_WHITE, x, y)
        call PreloadOne(FX_SPARKS, x, y)
        call PreloadOne(FX_CRACK, x, y)
        call PreloadOne(FX_BURST, x, y)
        call PreloadOne(FX_FIRE_RING, x, y)
        call PreloadOne(FX_SHATTER, x, y)
        call PreloadOne(FX_GEAR, x, y)
        call PreloadOne(FX_PETAL_BREAK, x, y)
        call PreloadOne(FX_SWORD_GLOW, x, y)
        call PreloadOne(FX_PHANTASM_FIRE, x, y)
        call PreloadOne(FX_CALAD_BURST, x, y)
        call PreloadOne(FX_PETAL_SHARD, x, y)
        call PreloadOne(FX_TRACE_CAST, x, y)
        call PreloadOne(FX_RHO_BREAK, x, y)
        call PreloadOne(FX_BOW_CHARGE, x, y)
        call PreloadOne(FX_UBW_FIRE, x, y)
        call PreloadOne(FX_BOW_FLASH, x, y)
        call PreloadOne(TELE_LINE, x, y)
        call PreloadOne(TELE_WIDE, x, y)
    endfunction

    function ArcherBossStart takes unit source returns nothing
        local tick t
        local ArcherFight f
        local integer pid = GetPlayerId(GetOwningPlayer(source))
        local integer mapNumber = GetMap(ARENA_THEMA)
        local rect r2

        if mapNumber == 0 then
            return
        endif

        set f = ArcherFightAt[mapNumber]
        if f == 0 then
            set f = ArcherFight.create()
            set f.rect = mapNumber
            set f.state = ARCHER_READY
            set f.ul = party.create()
            set f.hit = 0
            set ArcherFightAt[mapNumber] = f
            // 전장(맵) 안, 땅 아래에서 미리 불러 둔다
            call PreloadFx(GetRectCenterX(MapRectReturn(mapNumber)), GetRectCenterY(MapRectReturn(mapNumber)))
            set f.entrance = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), ENTRANCE_DUMMY, GetRectCenterX(MapRectReturn2(mapNumber)), GetRectCenterY(MapRectReturn2(mapNumber)), 270)
            call GroupAddUnit(f.ul.super, source)
            set t = tick.create(f)
            call t.start(1.00, true, function EntranceTick)
        elseif f.state == ARCHER_READY then
            call GroupAddUnit(f.ul.super, source)
        else
            // 이미 시작한 전투에는 합류하지 않는다
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

    // 테스트 입장: 채팅 "-아처"
    private function ChatEnter takes nothing returns nothing
        local integer pid = GetPlayerId(GetTriggerPlayer())
        if MainUnit[pid] != null and not IsUnitDeadVJ(MainUnit[pid]) then
            call ArcherBossStart(MainUnit[pid])
        endif
    endfunction

    // ======================================================================
    // 데이터
    // ======================================================================
    private module ArcherInit
        private static method onInit takes nothing returns nothing
            local integer i = 0
            local trigger t = CreateTrigger()
            loop
                exitwhen i >= 12
                call TriggerRegisterPlayerChatEvent(t, Player(i), "-아처", true)
                set i = i + 1
            endloop
            call TriggerAddAction(t, function ChatEnter)
            set t = null

            // Archer.mdx 애니메이션 길이(초). 반복 동작은 AnimLoop
            set AnimDur[0] = 2.000
            set AnimDur[1] = 0.800
            set AnimDur[2] = 1.000
            set AnimDur[3] = 1.166
            set AnimDur[4] = 1.166
            set AnimDur[5] = 0.333
            set AnimDur[6] = 2.500
            set AnimDur[7] = 1.000
            set AnimDur[8] = 1.666
            set AnimDur[9] = 0.267
            set AnimDur[10] = 1.000
            set AnimDur[11] = 0.334
            set AnimDur[12] = 1.333
            set AnimDur[13] = 1.000
            set AnimDur[14] = 2.000
            set AnimDur[15] = 0.800
            set AnimDur[16] = 1.000
            set AnimDur[17] = 0.833
            set AnimDur[18] = 1.166
            set AnimDur[19] = 1.200
            set AnimDur[20] = 1.000
            set AnimDur[21] = 0.834
            set AnimDur[22] = 2.000
            set AnimDur[23] = 1.333
            set AnimDur[24] = 1.000
            set AnimDur[25] = 1.000
            set AnimDur[26] = 0.800
            set AnimDur[27] = 1.334
            set AnimDur[28] = 1.667
            set AnimDur[29] = 0.500
            set AnimDur[30] = 0.833
            set AnimLoop[0] = true
            set AnimLoop[1] = true
            set AnimLoop[2] = true
            set AnimLoop[9] = true
            set AnimLoop[14] = true
            set AnimLoop[15] = true
            set AnimLoop[16] = true
            set AnimLoop[22] = true
            set AnimLoop[26] = true
            set AnimLoop[29] = true

            set i = 1
            // 확정 필요: 영창 음성 경로와 실제 길이(초)
            loop
                exitwhen i > 8
                set ChantSound[i] = ""
                set ChantDur[i] = 3.5
                set ChantText[i] = "(영창 " + I2S(i) + "/8)"
                set i = i + 1
            endloop
            // 마지막 영창은 전환 연출 길이를 겸한다
            set ChantDur[8] = 7.0
            // 영창: 1~6·8 = T.mp3 를 구절별로 자른 것(영어 원문), 8 = 마지막 구절 (HP 20% 결계 전개). 7번 자리는 쓰지 않음
            set ChantSound[1] = "war3mapImported\\ArcherSnd\\Archer_Chant1.mp3"
            set ChantDur[1] = 3.87
            set ChantText[1] = "I am the bone of my sword. (몸은 검으로 이루어져 있다)"
            set ChantSound[2] = "war3mapImported\\ArcherSnd\\Archer_Chant2.mp3"
            set ChantDur[2] = 4.55
            set ChantText[2] = "Steel is my body, and fire is my blood. (피는 철이요, 마음은 유리)"
            set ChantSound[3] = "war3mapImported\\ArcherSnd\\Archer_Chant3.mp3"
            set ChantDur[3] = 4.68
            set ChantText[3] = "I have created over a thousand blades. (수많은 전장을 넘어 불패)"
            set ChantSound[4] = "war3mapImported\\ArcherSnd\\Archer_Chant4.mp3"
            set ChantDur[4] = 4.47
            set ChantText[4] = "Unknown to death, nor known to life. (단 한 번의 패주도, 단 한 번의 이해도 없다)"
            set ChantSound[5] = "war3mapImported\\ArcherSnd\\Archer_Chant5.mp3"
            set ChantDur[5] = 5.36
            set ChantText[5] = "Have withstood pain to create many weapons. (그 자는 언제나 홀로, 검의 언덕에서 승리에 취한다)"
            set ChantSound[6] = "war3mapImported\\ArcherSnd\\Archer_Chant6.mp3"
            set ChantDur[6] = 5.07
            set ChantText[6] = "Yet, those hands will never hold anything. (그렇기에 그 생애에 의미는 없으며)"
            set ChantSound[7] = ""
            set ChantDur[7] = 0
            set ChantText[7] = ""
            set ChantSound[8] = "war3mapImported\\ArcherSnd\\Archer_Chant8.mp3"
            set ChantDur[8] = 5.07
            set ChantText[8] = "So as I pray... (그 몸은 분명 검으로 이루어져 있었다)"
            // 첫 전투에서 이펙트가 처음 나올 때 멈칫하지 않게: 맵 시작 1초 뒤부터 한 틱에 하나씩 미리 그려 둔다
            // (보스 이펙트 전부 + 영웅 피격 피 이펙트, 마지막에 아쳐·장판 유닛 모델)
            call PreloadAdd(FX_THROW_KANSHOU)
            call PreloadAdd(FX_THROW_BAKUYA)
            call PreloadAdd(FX_SNIPE_BOLT)
            call PreloadAdd(FX_SNIPE_BOOM)
            call PreloadAdd(FX_SNIPE_MARK)
            call PreloadAdd(FX_SLASH_RED)
            call PreloadAdd(FX_SLASH_WHITE)
            call PreloadAdd(FX_SWORD_FALL)
            call PreloadAdd(FX_SWORD_STUCK)
            call PreloadAdd(FX_COUNTER_READY)
            call PreloadAdd(FX_TRANSITION)
            call PreloadAdd(FX_RHO_AIAS)
            call Preload(FX_PHANTASM_BOOM)
            call PreloadAdd(FX_GATHER)
            call PreloadAdd(FX_CHARGE)
            call PreloadAdd(FX_FLASH_RED)
            call PreloadAdd(FX_FLASH_WHITE)
            call PreloadAdd(FX_SPARKS)
            call PreloadAdd(FX_CRACK)
            call PreloadAdd(FX_BURST)
            call Preload(FX_DUST)
            call Preload(FX_STOMP)
            call PreloadAdd(FX_FIRE_RING)
            call PreloadAdd(FX_SHATTER)
            call PreloadAdd(FX_GEAR)
            call PreloadAdd(FX_PETAL_BREAK)
            call PreloadAdd(FX_SWORD_GLOW)
            call PreloadAdd(FX_PHANTASM_FIRE)
            call PreloadAdd(FX_CALAD_BURST)
            call PreloadAdd(FX_PETAL_SHARD)
            call PreloadAdd(FX_TRACE_CAST)
            call PreloadAdd(FX_RHO_BREAK)
            call PreloadAdd(FX_BOW_CHARGE)
            call PreloadAdd(FX_UBW_FIRE)
            call PreloadAdd(FX_BOW_FLASH)
            call PreloadAdd(TELE_LINE)
            call PreloadAdd(TELE_WIDE)
            call PreloadAdd("Objects\\Spawnmodels\\Human\\HumanBlood\\HumanBloodFootman.mdl")
            call TimerStart(PreTimer, 1.0, false, function PreloadStep)
            call PreloadAddSnd(FINAL_SOUND)
            call PreloadAddSnd(VO_START)
            call PreloadAddSnd(VO_KEEPUP)
            call PreloadAddSnd(VO_RHO + "1.mp3")
            call PreloadAddSnd(VO_RHO + "2.mp3")
            call PreloadAddSnd(VO_BONE)
            call PreloadAddSnd(VO_CALAD + "1.mp3")
            call PreloadAddSnd(VO_CALAD + "2.mp3")
            call PreloadAddSnd(VO_HRUNT)
            call PreloadAddSnd(VO_TRACE)
            call PreloadAddSnd(VO_DODGE)
            call PreloadAddSnd(VO_ASIDE)
            call PreloadAddSnd(VO_GOTYOU)
            call PreloadAddSnd(VO_PIERCE)
            call PreloadAddSnd(VO_ALLBLADE)
            call PreloadAddSnd(VO_DEATH)
            call PreloadAddSnd(VO_WIPE)
            call PreloadAddSnd(VO_HIT + "1.mp3")
            call PreloadAddSnd(VO_HIT + "2.mp3")
            call PreloadAddSnd(VO_HIT + "3.mp3")
            call PreloadAddSnd(VO_GRUNT + "0.mp3")
            call PreloadAddSnd(VO_GRUNT + "1.mp3")
            call PreloadAddSnd(VO_GRUNT + "2.mp3")
            call PreloadAddSnd(VO_GRUNT + "3.mp3")
            call PreloadAddSnd(VO_GRUNT + "4.mp3")
            call PreloadAddSnd(ChantSound[1])
            call PreloadAddSnd(ChantSound[2])
            call PreloadAddSnd(ChantSound[3])
            call PreloadAddSnd(ChantSound[4])
            call PreloadAddSnd(ChantSound[5])
            call PreloadAddSnd(ChantSound[6])
            call PreloadAddSnd(ChantSound[8])
            call PreloadAddSnd(UBW_BGM)

            set PatCool[1] = 5
            set PatCool[2] = 10
            set PatCool[3] = 14
            set PatCool[4] = 18
            set PatCool[5] = 12
            set PatCool[6] = 18
            set PatCool[7] = 30

            set PatWeight[1] = 40
            set PatWeight[2] = 25
            set PatWeight[3] = 20
            set PatWeight[4] = 15
            set PatWeight[5] = 20
            set PatWeight[6] = 20
            set PatWeight[7] = 25
            // 2페이즈 신규: 로 아이아스, 부서진 환상, 흐룬팅, 학익삼련
            set PatCool[8] = 16
            set PatCool[9] = 20
            set PatCool[10] = 18
            set PatCool[11] = 20
            set PatWeight[8] = 20
            set PatWeight[9] = 15
            set PatWeight[10] = 20
            set PatWeight[11] = 20
            // 결계 전용: 검의 사출, 칼날의 숲, 투영 복제
            set PatCool[12] = 14
            set PatCool[13] = 22
            set PatCool[14] = 20
            set PatWeight[12] = 20
            set PatWeight[13] = 15
            set PatWeight[14] = 20
            // 강제 패턴 (선택되지 않음)
            set PatCool[16] = 0
        endmethod
    endmodule

    private struct ArcherInitSt extends array
        implement ArcherInit
    endstruct
endlibrary
