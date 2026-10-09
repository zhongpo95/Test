library DamageEffect requires DataUnit,UIBossHP,AttackAngle,BuffData,Shield,BossAggro,ExpeditionEffects,CardRecovery
    globals
        constant real HeadBounsDamage = 1.20
        constant real BackBounsDamage = 1.20
        // 다음 HeroDeal 호출들의 무력화 추가량 (지크프리트 W 강화 등). 호출한 쪽에서 바로 0으로 되돌린다.
        real HeroDealBonusSD = 0.0
        // 지금 넣는 피해가 저스트 공격(지크프리트 C 저스트)인지. 호출한 쪽에서 바로 false 로 되돌린다
        boolean HeroDealJust = false

        private unit array TestUnit
        // 정면 방패 꽃잎: 스킬 한 번 = 꽃잎 한 장. 같은 플레이어의 같은 스킬 코드가 이어서 막히는 동안(간격 GUARD_SAME 초 이내)은 한 번만 센다.
        // 능력 코드가 아닌 번호(1000 미만: 저스트 공격 등)는 GUARD_BASIC 초 안의 연타를 한 번으로 센다
        private constant real GUARD_SAME = 1.0
        private constant real GUARD_BASIC = 0.3
        private timer GuardClock = CreateTimer()
        private boolean GuardClockOn = false
        private integer array GuardLastCode
        private real array GuardLastAt
    endglobals

    // 방패에 막힌 타격이 새 스킬 사용인지 (꽃잎 한 장으로 셀지)
    private function GuardNewUse takes integer pid, integer skill returns boolean
        local real now
        local real gap = GUARD_SAME
        local boolean fresh
        if not GuardClockOn then
            set GuardClockOn = true
            call TimerStart(GuardClock, 1000000.0, false, null)
        endif
        if pid < 0 or pid >= 12 then
            return true
        endif
        set now = TimerGetElapsed(GuardClock)
        if skill < 1000 then
            set gap = GUARD_BASIC
        endif
        set fresh = skill != GuardLastCode[pid] or now - GuardLastAt[pid] > gap
        set GuardLastCode[pid] = skill
        // 다단 히트가 계속되는 동안은 창을 늘린다 (한 스킬 = 한 장)
        set GuardLastAt[pid] = now
        return fresh
    endfunction

    private function Reset takes nothing returns nothing
        local tick t = tick.getExpired()
        call SetUnitVertexColorBJ( TestUnit[t.data], 100, 100, 100, 0 )
        set TestUnit[t.data] = null
        call t.destroy()
    endfunction

    private function FormatDamageText takes real damage returns string
        local string s = I2S(R2I(damage))
        local string result = ""
        local integer sl = JNStringLength(s)

        loop
            exitwhen sl <= 3
            set result = "," + JNStringSub(s, sl - 3, 3) + result
            set sl = sl - 3
        endloop

        return JNStringSub(s, 0, sl) + result
    endfunction

    // 정면 방패: 공격자가 대상이 보는 방향 기준 앞쪽 반원(±90도)에 있는지
    private function GuardFront takes unit source, unit target returns boolean
        local real d = ModuloReal(AngleWBW(source, target) - GetUnitFacing(target) - 180.0 + 540.0, 360.0) - 180.0
        return RAbsBJ(d) <= 90.0
    endfunction

    // 공격자가 대상 정면 ±arc 안에 있는지 (보스별 카운터 각도)
    private function CounterFront takes unit source, unit target, real arc returns boolean
        local real d = ModuloReal(AngleWBW(source, target) - GetUnitFacing(target) - 180.0 + 540.0, 360.0) - 180.0
        return RAbsBJ(d) <= arc
    endfunction

    private function GuardTag takes unit u returns nothing
        local texttag ttag = CreateTextTag()
        call SetTextTagText(ttag, "막힘", 0.022)
        call SetTextTagPos(ttag, GetWidgetX(u), GetWidgetY(u), 120)
        call SetTextTagColor(ttag, 200, 200, 255, 229)
        call SetTextTagVelocityBJ(ttag, 60.00, GetRandomReal(60.00, 120.00))
        call SetTextTagFadepoint(ttag, 0.4)
        call SetTextTagLifespan(ttag, 0.6)
        call SetTextTagPermanent(ttag, false)
        call SetTextTagVisibility(ttag, true)
        set ttag = null
    endfunction

    //때린유닛,맞은유닛
    function TestDeal takes unit target returns nothing
        local tick t = tick.create(0)
        set t.data = IndexUnit(target)
        set TestUnit[t.data] = target
        call SetUnitVertexColorBJ( target, 50, 50, 100, 0 )
        //call VJDebugMsg("맞음")
        call t.start(1.0, false, function Reset)
    endfunction

    //컷인딜 대상, 체력계수 ex)13% 0.13
    function CutInDeal takes unit target, real rate returns nothing
        local integer UnitIndex = GetUnitIndex(target)
        local texttag ttag
        local real dmg
        local string s
        
        if UnitDamageLock[UnitIndex] then
            return
        endif

        set dmg = UnitHPMAX[UnitIndex] * rate

        set UnitHP[UnitIndex] = UnitHP[UnitIndex] - dmg
        if UnitHPFloorOn[UnitIndex] and UnitHP[UnitIndex] < UnitHPFloor[UnitIndex] then
            set UnitHP[UnitIndex] = UnitHPFloor[UnitIndex]
        endif
        call ExpSyncEnemyLife(target)
        set ttag = CreateTextTag()
        set s = FormatDamageText(dmg)
        call SetTextTagText(ttag, s + " !", 0.030)
        call SetTextTagPosUnit(ttag, target, 5.00)
        call SetTextTagColor(ttag, 255, 255, 0, 229)
        call SetTextTagVelocityBJ(ttag, 60.00, GetRandomReal(60.00, 120.00))
        call SetTextTagFadepoint(ttag, 0.8)
        call SetTextTagLifespan(ttag, 1.0)
        call SetTextTagPermanent(ttag, false)
        call SetTextTagVisibility(ttag, true)
        set ttag=null

    endfunction
    
    //때린유닛,맞은유닛,계수,헤드판정,백판정,카운터,차지
    function HeroDeal takes integer SkillCode, unit source, unit target, real rate, boolean head, boolean back, boolean counter, boolean charge returns boolean
        local integer pid = GetPlayerId(GetOwningPlayer(source))
        local integer sourceindex = IndexUnit(source)
        local integer UnitIndex = GetUnitIndex(target)
        local real CriRandom = GetRandomReal(0,100)
        local boolean CriBoolean = false
        local real ad = AttackPower(pid)
        local real cri = Stats_Crit[pid]
        local texttag ttag
        local real dmg
        local real DMGRate = 1.0
        local real crirate = Hero_CriDeal[pid] + Equip_CriDeal[pid] + Arcana_CriDeal[pid] + ProtoStat(pid, PROTO_STAT_CRIT_DAMAGE)
        local real ArmVelue
        local real Arm
        local real WDP = (1.0 + ((Equip_ED[pid] + Arcana_DP[pid] + Equip_WDP[pid]) / 100.0))
        local real DP = Equip_DP[pid]
        local real LastDamage = (1.0 + FinalDamageBonus(pid) / 100.0)
        local string s
        local boolean CounterBoolean = false
        local real SD = 1 + HeroDealBonusSD
        local real ArcanaRate = 1
        local integer ArcanaLv = 0
        local integer i = 0
        local real healthBefore = UnitHP[UnitIndex]
    
        if not ProtoCanHit(pid, UnitIndex) then
            return false
        endif
        //피해 잠금 (보스 페이즈 전환 연출 중): 피해·카운터·무력화 모두 무시
        if UnitDamageLock[UnitIndex] then
            return false
        endif
        //뽑은 검(아쳐 무한의 검제): 들고 있는 동안 피해 ×1.2, 무력화 +2. 일반 공격으로는 검이 줄지 않는다
        //(다단 히트마다 검이 사라지던 문제). 검은 보스 쪽 기믹(로 아이아스 꽃잎, 전검 사출 방어)에서만 쓴다
        if UnitPullTarget[UnitIndex] and pid >= 0 and pid < 12 and HeroPulledSword[pid] > 0 then
            set HeroPullHit[pid] = true
            set DMGRate = DMGRate * 1.2
            set SD = SD + 2.0
        endif
        //정면 방패: 앞쪽 반원에서 온 공격은 막는다
        if UnitFrontGuard[UnitIndex] and GuardFront(source, target) then
            // 스킬 한 번에 꽃잎 한 장 (다단 히트는 한 번만). 기본 공격(코드 2)은 꽃잎을 깨지 못한다.
            // 예외: 지크프리트의 저스트 공격(강한 기본 공격)은 한 번에 한 장
            if (SkillCode != 2 or HeroDealJust) and GuardNewUse(pid, SkillCode) then
                set UnitGuardFrontHits[UnitIndex] = UnitGuardFrontHits[UnitIndex] + 1
            endif
            call GuardTag(target)
            return false
        endif
        if ExpEnemy[UnitIndex] and ((ExpState != EXP_BATTLE and ExpState != EXP_HUNT) or UnitHP[UnitIndex] <= 0.0) then
            return false
        endif

        //방어력10000
        set ArmVelue = UnitArm[UnitIndex]

        //방깍
        if DeBuffMArm.Exists( target ) then
            set ArmVelue = UnitArm[UnitIndex] * 0.88
        endif
        //관통
        if ExpMember[pid] then
            if ArmVelue > 0.0 then
                set ArmVelue = ArmVelue * (1.0 - RMinBJ(0.60, RMaxBJ(0.0, Penetration[pid] + Equip_Penetration[pid] + ExpCardPenetration(pid))))
            endif
        else
            set ArmVelue = (ArmVelue * (1 - Penetration[pid]))
            set ArmVelue = (ArmVelue * (1 - Equip_Penetration[pid]))
        endif

        set Arm = ArmVelue / (ArmVelue + 10000)
        set DMGRate = DMGRate * (1-Arm)
        
        //아르카나
        if true then
            //저받
            set ArcanaLv = 0
            set ArcanaLv = LoadInteger(ArcanaData, 0, pid)
            if ArcanaLv >= 3 then
                set ArcanaLv = 3
            endif
            if ArcanaLv == 1 then
                set ArcanaRate = ArcanaRate * 1.11
            elseif ArcanaLv == 2 then
                set ArcanaRate = ArcanaRate * 1.14
            elseif ArcanaLv == 3 then
                set ArcanaRate = ArcanaRate * 1.17
            endif
            //돌대
            set ArcanaLv = 0
            set ArcanaLv = LoadInteger(ArcanaData, 1, pid)
            if ArcanaLv >= 3 then
                set ArcanaLv = 3
            endif
            if ArcanaLv == 1 then
                set ArcanaRate = ArcanaRate * ((GetUnitMoveSpeed(MainUnit[pid]) / 4) - 100) * 0.32
            elseif ArcanaLv == 2 then
                set ArcanaRate = ArcanaRate * ((GetUnitMoveSpeed(MainUnit[pid]) / 4) - 100) * 0.40
            elseif ArcanaLv == 3 then
                set ArcanaRate = ArcanaRate * ((GetUnitMoveSpeed(MainUnit[pid]) / 4) - 100) * 0.48
            endif
            //바리
            set ArcanaLv = 0
            set ArcanaLv = LoadInteger(ArcanaData, 4, pid)
            if ArcanaLv >= 3 then
                set ArcanaLv = 3
            endif
            if USDT[sourceindex] != 0 then
                if ArcanaLv == 1 then
                    set ArcanaRate = ArcanaRate * 1.11
                elseif ArcanaLv == 2 then
                    set ArcanaRate = ArcanaRate * 1.14
                elseif ArcanaLv == 3 then
                    set ArcanaRate = ArcanaRate * 1.17
                endif
            endif

            //슈차
            set ArcanaLv = 0
            set ArcanaLv = LoadInteger(ArcanaData, 5, pid)
            if ArcanaLv >= 3 then
                set ArcanaLv = 3
            endif
            if charge == true then
                if ArcanaLv == 1 then
                    set ArcanaRate = ArcanaRate * 1.16
                elseif ArcanaLv == 2 then
                    set ArcanaRate = ArcanaRate * 1.18
                elseif ArcanaLv == 3 then
                    set ArcanaRate = ArcanaRate * 1.21
                endif
            endif

            //질증
            set ArcanaLv = 0
            set ArcanaLv = LoadInteger(ArcanaData, 6, pid)
            if ArcanaLv >= 3 then
                set ArcanaLv = 3
            endif
            if ArcanaLv == 1 then
                set ArcanaRate = ArcanaRate * 1.13
            elseif ArcanaLv == 2 then
                set ArcanaRate = ArcanaRate * 1.16
            elseif ArcanaLv == 3 then
                set ArcanaRate = ArcanaRate * 1.19
            endif

            //안상
            set ArcanaLv = 0
            set ArcanaLv = LoadInteger(ArcanaData, 8, pid)
            if ArcanaLv >= 3 then
                set ArcanaLv = 3
            endif
            if GetUnitStatePercent(source,UNIT_STATE_LIFE,UNIT_STATE_MAX_LIFE) >= 65 then
                if ArcanaLv == 1 then
                    set ArcanaRate = ArcanaRate * 1.11
                elseif ArcanaLv == 2 then
                    set ArcanaRate = ArcanaRate * 1.14
                elseif ArcanaLv == 3 then
                    set ArcanaRate = ArcanaRate * 1.17
                endif
            endif

            //원한
            set ArcanaLv = 0
            set ArcanaLv = LoadInteger(ArcanaData, 9, pid)
            if ArcanaLv >= 3 then
                set ArcanaLv = 3
            endif
            if ArcanaLv == 1 then
                set ArcanaRate = ArcanaRate * 1.15
            elseif ArcanaLv == 2 then
                set ArcanaRate = ArcanaRate * 1.18
            elseif ArcanaLv == 3 then
                set ArcanaRate = ArcanaRate * 1.21
            endif
        endif
        //사멸
        set ArcanaLv = 0
        set ArcanaLv = LoadInteger(ArcanaData, 2, pid)
        if ArcanaLv >= 3 then
            set ArcanaLv = 3
        endif

        //헤드 체크
        if head == true then
            if HeadTrue(AngleWBW(source,target), GetUnitFacing(target)) == true then
                if DeBuffMBackHead.Exists( target ) then
                    set DMGRate = DMGRate * 1.12
                endif
                if ArcanaLv == 1 then
                    set ArcanaRate = ArcanaRate * 1.160
                elseif ArcanaLv == 2 then
                    set ArcanaRate = ArcanaRate * 1.198
                elseif ArcanaLv == 3 then
                    set ArcanaRate = ArcanaRate * 1.226
                endif
                set DMGRate = DMGRate * HeadBounsDamage
                call HeadTag(target)
            else
                if ArcanaLv == 1 then
                    set ArcanaRate = ArcanaRate * 1.040
                elseif ArcanaLv == 2 then
                    set ArcanaRate = ArcanaRate * 1.048
                elseif ArcanaLv == 3 then
                    set ArcanaRate = ArcanaRate * 1.076
                endif
            endif
        endif
        
        //백어택 체크
        if back == true then
            if BackTrue(AngleWBW(source,target), GetUnitFacing(target)) == true then
                if DeBuffMBackHead.Exists( target ) then
                    set DMGRate = DMGRate * 1.12
                endif
                if ArcanaLv == 1 then
                    set ArcanaRate = ArcanaRate * 1.160
                elseif ArcanaLv == 2 then
                    set ArcanaRate = ArcanaRate * 1.198
                elseif ArcanaLv == 3 then
                    set ArcanaRate = ArcanaRate * 1.226
                endif
                set DMGRate = DMGRate * BackBounsDamage
                call BackTag(target)
            else
                if ArcanaLv == 1 then
                    set ArcanaRate = ArcanaRate * 1.040
                elseif ArcanaLv == 2 then
                    set ArcanaRate = ArcanaRate * 1.048
                elseif ArcanaLv == 3 then
                    set ArcanaRate = ArcanaRate * 1.076
                endif
            endif
        endif
        
        //타대
        set ArcanaLv = 0
        set ArcanaLv = LoadInteger(ArcanaData, 3, pid)
        if ArcanaLv >= 3 then
            set ArcanaLv = 3
        endif
        if back == false and head == false then
            if ArcanaLv == 1 then
                set ArcanaRate = ArcanaRate * 1.110
            elseif ArcanaLv == 2 then
                set ArcanaRate = ArcanaRate * 1.140
            elseif ArcanaLv == 3 then
                set ArcanaRate = ArcanaRate * 1.170
            endif
        endif

        //카운터 체크
        if counter == true then
            if GetUnitAbilityLevel(target, 'A00V') == 1 then
                if (UnitCounterArc[UnitIndex] <= 0 and HeadTrue(AngleWBW(source,target), GetUnitFacing(target))) or (UnitCounterArc[UnitIndex] > 0 and CounterFront(source, target, UnitCounterArc[UnitIndex])) then
                    call UnitRemoveAbility(target,'A00V')
                    call CounterTag(target)
                    set CounterBoolean = true
                endif
            endif
        endif
        
        if DeBuffCri.Exists( target ) then
            set cri = cri + 10.0
        endif
        
        //set cri = cri + 100.0
        
        if CriRandom <= cri then
            set DMGRate = DMGRate * (1+(crirate/100))
            set CriBoolean = true
        endif
        
        if ExpPrototypeActive and ExpMember[pid] then
            // 무기 추가 피해, 대미지, 최종 대미지와 대상별 피해는 각각 곱한다.
            set WDP = RMaxBJ(0.0, 1.0 + (Equip_ED[pid] + Equip_WDP[pid]) / 100.0)
            set DP = RMaxBJ(0.0, Equip_DP[pid] + (ExpCardDamage(pid, source, target) + ExpArcanaDamage(pid, source, target, head, back, charge)) / 100.0)
            set LastDamage = LastDamage * ProtoTargetDamageRate(pid, UnitIndex)
            set ArcanaRate = 1.0
        elseif ExpMember[pid] then
            set WDP = WDP + (ExpCardDamage(pid, source, target) + ExpArcanaDamage(pid, source, target, head, back, charge)) / 100.0
            set ArcanaRate = 1.0
        endif
        set dmg = ad * rate * DMGRate * DP * WDP * LastDamage * ArcanaRate

        //미터기
        loop
            exitwhen i > 3
            if pid == OverlayPlayerID[i] then
                set OverlayPlayerValue[i] = OverlayPlayerValue[i] + dmg
            endif
            set i = i + 1
        endloop
        if PlayerOverlayStop[pid] == false then
            //스킬,피해량,크리
            call Overlay2(pid, SkillCode, dmg, CriBoolean)
        endif

        //call VJDebugMsg(R2S(dmg))
        if UnitCasting[UnitIndex] == true then
            //게이지깎
            if ( UnitCastingSD[UnitIndex] - SD ) <= 0 then
                set UnitCastingSD[UnitIndex] = 0
                set UnitCastingSDMAX[UnitIndex] = 0
                set UnitCasting[UnitIndex] = false
                call KillUnit(UnitCastingDummy[UnitIndex])
                set UnitCastingDummy[UnitIndex] = null
                call Sound3D(target,'A00U')
                call SetUnitAnimation(target,"death")
            else
                set UnitCastingSD[UnitIndex] = UnitCastingSD[UnitIndex] - SD
                call SetUnitAnimationByIndex(UnitCastingDummy[UnitIndex], (R2I((UnitCastingSD[UnitIndex] / UnitCastingSDMAX[UnitIndex]) * 100)-1) )
            endif
        //else
            //if ( UnitSD[UnitIndex] - SD ) < 0 then
                //if UnitSD[UnitIndex] == 0 then
                    //이미 0임
                //else
                    //찐무력화
                    //call Sound3D(target,'A00U')
                    //set UnitSD[UnitIndex] = 0
                //endif
            //else
                //set UnitSD[UnitIndex] = UnitSD[UnitIndex] - SD
            //endif
        endif
        
        if dmg > 1 then
            if CriBoolean then
                set UnitHP[UnitIndex] = UnitHP[UnitIndex] - dmg
                set ttag=CreateTextTag()
                set s = FormatDamageText(dmg)
                call SetTextTagText(ttag, s + " !", 0.024)
                call SetTextTagPosUnit(ttag, target, 5.00)
                call SetTextTagColor(ttag, 255, 255, 0, 229)
                call SetTextTagVelocityBJ(ttag, 60.00, GetRandomReal(60.00, 120.00))
                call SetTextTagFadepoint(ttag, 0.8)
                call SetTextTagLifespan(ttag, 1.0)
                call SetTextTagPermanent(ttag, false)
                if Player(pid) == GetLocalPlayer() then
                    call SetTextTagVisibility(ttag, true)
                endif
                set ttag=null
            else
                set UnitHP[UnitIndex] = UnitHP[UnitIndex] - dmg
                set ttag=CreateTextTag()
                set s = FormatDamageText(dmg)
                call SetTextTagText(ttag, s, 0.022)
                call SetTextTagPosUnit(ttag, target, 5.00)
                call SetTextTagColor(ttag, 255, 255, 255, 229)
                call SetTextTagVelocityBJ(ttag, 60.00, GetRandomReal(60.00, 120.00))
                call SetTextTagFadepoint(ttag, 0.8)
                call SetTextTagLifespan(ttag, 1.0)
                call SetTextTagPermanent(ttag, false)
                if Player(pid) == GetLocalPlayer() then
                    call SetTextTagVisibility(ttag, true)
                endif
                set ttag=null
            endif
        else
            if CriBoolean then
                set UnitHP[UnitIndex] = UnitHP[UnitIndex] - 1.00
                set ttag=CreateTextTag()
                set s = FormatDamageText(1.00)
                call SetTextTagText(ttag, s + " !", 0.024)
                call SetTextTagPosUnit(ttag, target, 5.00)
                call SetTextTagColor(ttag, 255, 255, 0, 229)
                call SetTextTagVelocityBJ(ttag, 60.00, GetRandomReal(60.00, 120.00))
                call SetTextTagFadepoint(ttag, 0.8)
                call SetTextTagLifespan(ttag, 1.0)
                call SetTextTagPermanent(ttag, false)
                if Player(pid) == GetLocalPlayer() then
                    call SetTextTagVisibility(ttag, true)
                endif
                set ttag=null
            else
                set UnitHP[UnitIndex] = UnitHP[UnitIndex] - 1.00
                set ttag=CreateTextTag()
                set s = FormatDamageText(1.00)
                call SetTextTagText(ttag, s, 0.022)
                call SetTextTagPosUnit(ttag, target, 5.00)
                call SetTextTagColor(ttag, 255, 255, 255, 229)
                call SetTextTagVelocityBJ(ttag, 60.00, GetRandomReal(60.00, 120.00))
                call SetTextTagFadepoint(ttag, 0.8)
                call SetTextTagLifespan(ttag, 1.0)
                call SetTextTagPermanent(ttag, false)
                if Player(pid) == GetLocalPlayer() then
                    call SetTextTagVisibility(ttag, true)
                endif
                set ttag = null
            endif
        endif
        
        //체력 하한 보호 (아쳐 1페이즈: HP 1 아래로 내려가지 않음). 집계보다 먼저 적용
        if UnitHPFloorOn[UnitIndex] and UnitHP[UnitIndex] < UnitHPFloor[UnitIndex] then
            set UnitHP[UnitIndex] = UnitHPFloor[UnitIndex]
        endif
        //정면 방패 중 옆·뒤에서 넣은 피해 (방패 파괴 조건)
        if UnitFrontGuard[UnitIndex] then
            set UnitGuardBackDmg[UnitIndex] = UnitGuardBackDmg[UnitIndex] + RMaxBJ(0.0, healthBefore - RMaxBJ(0.0, UnitHP[UnitIndex]))
        endif
        call ProtoRecordDamage(pid, UnitIndex, RMaxBJ(0.0, healthBefore - RMaxBJ(0.0, UnitHP[UnitIndex])))
        call ProtoLeechHit(pid, source, RMaxBJ(0.0, healthBefore - RMaxBJ(0.0, UnitHP[UnitIndex])))
        call ExpSyncEnemyLife(target)
        //어그로 시스템
        call PlayerBossAttack(source, target, dmg)
        return CounterBoolean
    endfunction
endlibrary
