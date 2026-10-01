// 획득한 카드와 각성의 추가 능력치만 누적하여 전투에서 재사용한다.
library DataPrototypeStats initializer ProtoStatsInit requires DataExpedition
    globals
        constant integer PROTO_STAT_ATTACK = 1
        constant integer PROTO_STAT_DAMAGE = 2
        constant integer PROTO_STAT_FINAL = 3
        constant integer PROTO_STAT_BOSS = 4
        constant integer PROTO_STAT_NORMAL = 5
        constant integer PROTO_STAT_CRIT = 6
        constant integer PROTO_STAT_CRIT_DAMAGE = 7
        constant integer PROTO_STAT_SWIFT = 8
        constant integer PROTO_STAT_ACTION = 9
        constant integer PROTO_STAT_MOVE = 10
        constant integer PROTO_STAT_CHARGE_SPEED = 11
        constant integer PROTO_STAT_PENETRATION = 12
        constant integer PROTO_STAT_HEALTH = 13
        constant integer PROTO_STAT_REDUCTION = 14
        constant integer PROTO_STAT_LEECH = 15
        constant integer PROTO_STAT_REGEN = 16
        constant integer PROTO_STAT_GOLD = 17
        constant integer PROTO_STAT_CHOICES = 18
        constant integer PROTO_STAT_MOVING = 19
        constant integer PROTO_STAT_DIRECTION = 20
        constant integer PROTO_STAT_NONDIRECTION = 21
        constant integer PROTO_STAT_SHIELDED = 22
        constant integer PROTO_STAT_CHARGE_DAMAGE = 23
        constant integer PROTO_STAT_HEALTHY = 24
        constant integer PROTO_STAT_CAPACITY = 25
        constant integer PROTO_STAT_LAST = 25
        hashtable ProtoEffectData = InitHashtable()
        hashtable ProtoHeadEffectData = InitHashtable()
        real array ProtoStatValues
        string array ProtoStatNames
    endglobals

    function ProtoStat takes integer pid, integer kind returns real
        if not ExpPrototypeActive or not ExpMember[pid] then
            return 0.0
        endif
        return ProtoStatValues[pid * 32 + kind]
    endfunction

    function ProtoSetEffect takes integer card, integer kind, real value, boolean evolved returns nothing
        if evolved then
            call SaveReal(ProtoEffectData, card, kind + 32, value)
        else
            call SaveReal(ProtoEffectData, card, kind, value)
        endif
    endfunction

    function ProtoEffectText takes integer kind, real value returns string
        local string sign = "+"
        local string unitText = "%"
        if value < 0.0 then
            set sign = ""
        endif
        if kind == PROTO_STAT_SWIFT then
            set unitText = ""
        elseif kind == PROTO_STAT_GOLD then
            set unitText = "골드"
        elseif kind == PROTO_STAT_CHOICES then
            set unitText = " (최대 4개)"
        elseif kind == PROTO_STAT_CAPACITY then
            set unitText = " (증가분 행동력 지급)"
        elseif kind == PROTO_STAT_REGEN then
            set unitText = "%/초"
        endif
        return ProtoStatNames[kind] + " " + sign + R2SW(value, 0, 1) + unitText
    endfunction

    function ProtoCardEffectsText takes integer card, boolean evolved returns string
        local integer kind = 1
        local real value
        local string result = ""
        loop
            exitwhen kind > PROTO_STAT_LAST
            set value = LoadReal(ProtoEffectData, card, kind)
            if evolved then
                set value = value + LoadReal(ProtoEffectData, card, kind + 32)
            endif
            if value != 0.0 then
                if result != "" then
                    set result = result + "|n"
                endif
                set result = result + ProtoEffectText(kind, value)
            endif
            set kind = kind + 1
        endloop
        return result
    endfunction

    function ProtoHeadEffectText takes integer head returns string
        local integer kind = 1
        local real value
        local string result = ""
        loop
            exitwhen kind > PROTO_STAT_LAST
            set value = LoadReal(ProtoHeadEffectData, head, kind)
            if value != 0.0 then
                if result != "" then
                    set result = result + " · "
                endif
                set result = result + ProtoEffectText(kind, value)
            endif
            set kind = kind + 1
        endloop
        return result
    endfunction

    function ProtoStatReset takes integer pid returns nothing
        local integer kind = 1
        loop
            exitwhen kind > PROTO_STAT_LAST
            set ProtoStatValues[pid * 32 + kind] = 0.0
            set kind = kind + 1
        endloop
    endfunction

    // 기본 효과는 최초 획득 때, 각성 추가 효과는 최초 각성 때만 더한다.
    function ProtoStatAddCard takes integer pid, integer card, boolean evolved returns nothing
        local integer kind = 1
        local integer offset = 0
        if evolved then
            set offset = 32
        endif
        loop
            exitwhen kind > PROTO_STAT_LAST
            set ProtoStatValues[pid * 32 + kind] = ProtoStatValues[pid * 32 + kind] + LoadReal(ProtoEffectData, card, kind + offset)
            set kind = kind + 1
        endloop
    endfunction

    function ProtoStatAddHead takes integer pid, integer head returns nothing
        local integer kind = 1
        loop
            exitwhen kind > PROTO_STAT_LAST
            set ProtoStatValues[pid * 32 + kind] = ProtoStatValues[pid * 32 + kind] + LoadReal(ProtoHeadEffectData, head, kind)
            set kind = kind + 1
        endloop
    endfunction

    function ProtoStatRefreshDerived takes integer pid returns nothing
        local integer previousMax = IMaxBJ(10, ProtoAPMax[pid])
        local integer nextMax
        set ProtoGoldBonus[pid] = R2I(ProtoStatValues[pid * 32 + PROTO_STAT_GOLD])
        set ProtoChoices[pid] = IMinBJ(4, IMaxBJ(3, 3 + R2I(ProtoStatValues[pid * 32 + PROTO_STAT_CHOICES])))
        set nextMax = 10 + IMaxBJ(0, R2I(ProtoStatValues[pid * 32 + PROTO_STAT_CAPACITY]))
        // 화면과 유닛 능력치 갱신으로 행동력을 다시 충전하지 않는다.
        if ExpPrototypeActive and ExpMember[pid] then
            set ProtoAP[pid] = IMinBJ(nextMax, IMaxBJ(0, ProtoAP[pid] + IMaxBJ(0, nextMax - previousMax)))
        endif
        set ProtoAPMax[pid] = nextMax
    endfunction

    function ProtoStatsInit takes nothing returns nothing
        set ProtoStatNames[PROTO_STAT_ATTACK] = "공격력 증가"
        set ProtoStatNames[PROTO_STAT_DAMAGE] = "대미지 증가"
        set ProtoStatNames[PROTO_STAT_FINAL] = "최종 대미지 증가"
        set ProtoStatNames[PROTO_STAT_BOSS] = "보스에게 가하는 피해"
        set ProtoStatNames[PROTO_STAT_NORMAL] = "일반 몬스터에게 가하는 피해"
        set ProtoStatNames[PROTO_STAT_CRIT] = "치명타 확률"
        set ProtoStatNames[PROTO_STAT_CRIT_DAMAGE] = "치명타 피해 보너스"
        set ProtoStatNames[PROTO_STAT_SWIFT] = "고정 신속"
        set ProtoStatNames[PROTO_STAT_ACTION] = "행동 속도"
        set ProtoStatNames[PROTO_STAT_MOVE] = "이동 속도"
        set ProtoStatNames[PROTO_STAT_CHARGE_SPEED] = "차지 속도"
        set ProtoStatNames[PROTO_STAT_PENETRATION] = "방어력 관통"
        set ProtoStatNames[PROTO_STAT_HEALTH] = "최대 체력"
        set ProtoStatNames[PROTO_STAT_REDUCTION] = "받는 피해 감소"
        set ProtoStatNames[PROTO_STAT_LEECH] = "실제 피해 흡수"
        set ProtoStatNames[PROTO_STAT_REGEN] = "최대 체력 재생"
        set ProtoStatNames[PROTO_STAT_GOLD] = "사냥 처치 보상"
        set ProtoStatNames[PROTO_STAT_CHOICES] = "사건 후보"
        set ProtoStatNames[PROTO_STAT_MOVING] = "추가 이동속도 40%에서 대미지 증가"
        set ProtoStatNames[PROTO_STAT_DIRECTION] = "헤드·백 적중 대미지 증가"
        set ProtoStatNames[PROTO_STAT_NONDIRECTION] = "비방향 공격 대미지 증가"
        set ProtoStatNames[PROTO_STAT_SHIELDED] = "보호막 유지 중 대미지 증가"
        set ProtoStatNames[PROTO_STAT_CHARGE_DAMAGE] = "차지 공격 대미지 증가"
        set ProtoStatNames[PROTO_STAT_HEALTHY] = "체력 65% 이상에서 대미지 증가"
        set ProtoStatNames[PROTO_STAT_CAPACITY] = "행동력 최대치"
    endfunction
endlibrary
