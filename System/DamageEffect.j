library DamageEffect requires DataUnit,UIBossHP,AttackAngle,BuffData,Shield,BossAggro
    globals
        constant real HeadBounsDamage = 1.20
        constant real BackBounsDamage = 1.20

        private unit array TestUnit
    endglobals

    private function Reset takes nothing returns nothing
        local tick t = tick.getExpired()
        call SetUnitVertexColorBJ( TestUnit[t.data], 100, 100, 100, 0 )
        set TestUnit[t.data] = null
        call t.destroy()
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
        local integer index = DataUnitIndex(target)
        local integer UnitIndex = GetUnitIndex(target)
        local integer HPvalue = UnitHPValue[index]
        local string HPString = UnitHPString[index]
        local texttag ttag
        local real dmg
        local string s
        local integer sl
        
        set dmg = UnitHPMAX[UnitIndex] * rate

        set UnitHP[UnitIndex] = UnitHP[UnitIndex] - dmg
        set ttag = CreateTextTag()
        set s = I2S(R2I(dmg)) + HPString
        set sl = JNStringLength(s)
        if sl == 10 then
            set s = JNStringSub(s,0,1) + "," + JNStringSub(s,2,3)+ "," + JNStringSub(s,5,3)+ "," + JNStringSub(s,8,3)
        elseif sl == 9 then
            set s = JNStringSub(s,0,3) + "," + JNStringSub(s,3,3)+ "," + JNStringSub(s,6,3)
        elseif sl == 8 then
            set s = JNStringSub(s,0,2) + "," + JNStringSub(s,2,3)+ "," + JNStringSub(s,5,3)
        elseif sl == 7 then
            set s = JNStringSub(s,0,1) + "," + JNStringSub(s,1,3)+ "," + JNStringSub(s,4,3)
        elseif sl == 6 then
            set s = JNStringSub(s,0,3) + "," + JNStringSub(s,3,3)
        elseif sl == 5 then
            set s = JNStringSub(s,0,2) + "," + JNStringSub(s,2,3)
        elseif sl == 4 then
            set s = JNStringSub(s,0,1) + "," + JNStringSub(s,1,3)
        endif
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
        local integer index = DataUnitIndex(target)
        local integer sourceindex = IndexUnit(source)
        local integer UnitIndex = GetUnitIndex(target)
        local integer HPvalue = UnitHPValue[index]
        local string HPString = UnitHPString[index]
        local real CriRandom = GetRandomReal(0,100)
        local boolean CriBoolean = false
        local real ad = R2I( Equip_Damage[pid] + Hero_Damage[pid] + (Equip_Damage[pid] * (Equip_DamageP[pid] / 100.0)) )
        local real cri = Stats_Crit[pid]
        local texttag ttag
        local real dmg
        local real DMGRate = 1.0
        local real crirate = Hero_CriDeal[pid] + Equip_CriDeal[pid] + Arcana_CriDeal[pid]
        local real ArmVelue
        local real Arm
        local real WDP = (1.0 + ((Equip_ED[pid] + Arcana_DP[pid] + Equip_WDP[pid]) / 100.0))
        local real DP = Equip_DP[pid]
        local real LastDamage = (1.0 + Equip_LastDamage[pid] / 100.0)
        local string s
        local integer sl
        local boolean CounterBoolean = false
        local real SD = 1
        local real ArcanaRate = 1
        local integer ArcanaLv = 0
        local integer i = 0
    
        //방어력10000
        set ArmVelue = UnitArm[UnitIndex]

        //방깍
        if DeBuffMArm.Exists( target ) then
            set ArmVelue = UnitArm[UnitIndex] * 0.88
        endif
        //관통
        set ArmVelue = (ArmVelue * (1 - Penetration[pid]))
        set ArmVelue = (ArmVelue * (1 - Equip_Penetration[pid]))

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
                if HeadTrue(AngleWBW(source,target), GetUnitFacing(target)) == true then
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
        
        set dmg = ad * rate / HPvalue * DMGRate * DP * WDP * LastDamage * ArcanaRate

        //미터기
        loop
            exitwhen i > 3
            if pid == OverlayPlayerID[i] then
                set OverlayPlayerValue[i] = OverlayPlayerValue[i] + (dmg * HPvalue)
            endif
            set i = i + 1
        endloop
        if PlayerOverlayStop[pid] == false then
            //스킬,피해량,크리
            call Overlay2(pid, SkillCode,(dmg * HPvalue), CriBoolean)
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
                set s = I2S(R2I(dmg)) + HPString
                set sl = JNStringLength(s)
                if sl == 10 then
                    set s = JNStringSub(s,0,1) + "," + JNStringSub(s,2,3)+ "," + JNStringSub(s,5,3)+ "," + JNStringSub(s,8,3)
                elseif sl == 9 then
                    set s = JNStringSub(s,0,3) + "," + JNStringSub(s,3,3)+ "," + JNStringSub(s,6,3)
                elseif sl == 8 then
                    set s = JNStringSub(s,0,2) + "," + JNStringSub(s,2,3)+ "," + JNStringSub(s,5,3)
                elseif sl == 7 then
                    set s = JNStringSub(s,0,1) + "," + JNStringSub(s,1,3)+ "," + JNStringSub(s,4,3)
                elseif sl == 6 then
                    set s = JNStringSub(s,0,3) + "," + JNStringSub(s,3,3)
                elseif sl == 5 then
                    set s = JNStringSub(s,0,2) + "," + JNStringSub(s,2,3)
                elseif sl == 4 then
                    set s = JNStringSub(s,0,1) + "," + JNStringSub(s,1,3)
                endif
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
                set s = I2S(R2I(dmg)) + HPString
                set sl = JNStringLength(s)
                if sl == 10 then
                    set s = JNStringSub(s,0,1) + "," + JNStringSub(s,2,3)+ "," + JNStringSub(s,5,3)+ "," + JNStringSub(s,8,3)
                elseif sl == 9 then
                    set s = JNStringSub(s,0,3) + "," + JNStringSub(s,3,3)+ "," + JNStringSub(s,6,3)
                elseif sl == 8 then
                    set s = JNStringSub(s,0,2) + "," + JNStringSub(s,2,3)+ "," + JNStringSub(s,5,3)
                elseif sl == 7 then
                    set s = JNStringSub(s,0,1) + "," + JNStringSub(s,1,3)+ "," + JNStringSub(s,4,3)
                elseif sl == 6 then
                    set s = JNStringSub(s,0,3) + "," + JNStringSub(s,3,3)
                elseif sl == 5 then
                    set s = JNStringSub(s,0,2) + "," + JNStringSub(s,2,3)
                elseif sl == 4 then
                    set s = JNStringSub(s,0,1) + "," + JNStringSub(s,1,3)
                endif
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
                set UnitHP[UnitIndex] = UnitHP[UnitIndex] - (1 * HPvalue)
                set ttag=CreateTextTag()
                set s = I2S(R2I(1)) + HPString
                set sl = JNStringLength(s)
                if sl == 10 then
                    set s = JNStringSub(s,0,1) + "," + JNStringSub(s,2,3)+ "," + JNStringSub(s,5,3)+ "," + JNStringSub(s,8,3)
                elseif sl == 9 then
                    set s = JNStringSub(s,0,3)+ "," + JNStringSub(s,3,3)+ "," + JNStringSub(s,6,3)
                elseif sl == 8 then
                    set s = JNStringSub(s,0,2)+ "," + JNStringSub(s,2,3)+ "," + JNStringSub(s,5,3)
                elseif sl == 7 then
                    set s = JNStringSub(s,0,1)+ "," + JNStringSub(s,1,3)+ "," + JNStringSub(s,4,3)
                elseif sl == 6 then
                    set s = JNStringSub(s,0,3)+ "," + JNStringSub(s,3,3)
                elseif sl == 5 then
                    set s = JNStringSub(s,0,2)+ "," + JNStringSub(s,2,3)
                elseif sl == 4 then
                    set s = JNStringSub(s,0,1)+ "," + JNStringSub(s,1,3)
                endif
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
                set UnitHP[UnitIndex] = UnitHP[UnitIndex] - (1 * HPvalue)
                set ttag=CreateTextTag()
                set s = I2S(R2I(1)) + HPString
                set sl = JNStringLength(s)
                if sl == 10 then
                    set s = JNStringSub(s,0,1) + "," + JNStringSub(s,2,3)+ "," + JNStringSub(s,5,3)+ "," + JNStringSub(s,8,3)
                elseif sl == 9 then
                    set s = JNStringSub(s,0,3)+ "," + JNStringSub(s,3,3)+ "," + JNStringSub(s,6,3)
                elseif sl == 8 then
                    set s = JNStringSub(s,0,2)+ "," + JNStringSub(s,2,3)+ "," + JNStringSub(s,5,3)
                elseif sl == 7 then
                    set s = JNStringSub(s,0,1)+ "," + JNStringSub(s,1,3)+ "," + JNStringSub(s,4,3)
                elseif sl == 6 then
                    set s = JNStringSub(s,0,3)+ "," + JNStringSub(s,3,3)
                elseif sl == 5 then
                    set s = JNStringSub(s,0,2)+ "," + JNStringSub(s,2,3)
                elseif sl == 4 then
                    set s = JNStringSub(s,0,1)+ "," + JNStringSub(s,1,3)
                endif
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
        
        //어그로 시스템
        call PlayerBossAttack(source, target, dmg)
        return CounterBoolean
    endfunction
endlibrary