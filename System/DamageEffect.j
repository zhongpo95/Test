library DamageEffect requires DataUnit,UIBossHP,AttackAngle,BuffData,Shield,BossAggro
    globals
        constant real HeadBounsDamage = 1.20
        constant real BackBounsDamage = 1.05
        constant real BackBounsCri = 10.00

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
        call BJDebugMsg("맞음")
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
    
    //때린유닛,맞은유닛,계수,헤드판정,백판정,무력화,카운터
    function HeroDeal takes unit source, unit target, real rate, boolean head, boolean back, real SD, boolean counter returns boolean
        local integer pid = GetPlayerId(GetOwningPlayer(source))
        local integer index = DataUnitIndex(target)
        local integer UnitIndex = GetUnitIndex(target)
        local integer HPvalue = UnitHPValue[index]
        local string HPString = UnitHPString[index]
        local real CriRandom = GetRandomReal(0,100)
        local boolean CriBoolean = false
        local real ad = R2I( Equip_Damage[pid] + Hero_Damage[pid]  )
        local real cri = Stats_Crit[pid]
        local texttag ttag
        local real dmg
        local real DMGRate = 1.0
        local real crirate = Hero_CriDeal[pid]
        local real ArmVelue
        local real Arm
        local string s
        local integer sl
        local boolean CounterBoolean = false
        
        set ArmVelue = UnitArm[UnitIndex]
        if DeBuffMArm.Exists( target ) then
            set ArmVelue = UnitArm[UnitIndex] * 0.88
        endif
        
        set Arm = ((ArmVelue * (1 - Penetration[pid])) / ((ArmVelue * (1 - Penetration[pid])) + 10000))
        set DMGRate = DMGRate * (1-Arm)
        
        //헤드 체크
        if head == true then
            if HeadTrue(AngleWBW(source,target), GetUnitFacing(target)) == true then
                if DeBuffMBackHead.Exists( target ) then
                    set DMGRate = DMGRate * 1.12
                endif
                set DMGRate = DMGRate * HeadBounsDamage
                call HeadTag(target)
            endif
        endif
        
        //백어택 체크
        if back == true then
            if BackTrue(AngleWBW(source,target), GetUnitFacing(target)) == true then
                if DeBuffMBackHead.Exists( target ) then
                    set DMGRate = DMGRate * 1.12
                endif
                set DMGRate = DMGRate * BackBounsDamage
                set cri = cri + BackBounsCri
                call BackTag(target)
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
        
        set dmg = ad * rate / HPvalue * DMGRate
        
        if UnitCasting[UnitIndex] == true then
            //게이지깎
            if ( UnitCastingSD[UnitIndex] - SD ) < 0 then
                if UnitCastingSD[UnitIndex] == 0 then
                    //
                else
                    //캐스팅 무력화
                    set UnitCastingSD[UnitIndex] = 0
                    set UnitCastingSDMAX[UnitIndex] = 0
                    set UnitCasting[UnitIndex] = false
                    call KillUnit(UnitCastingDummy[UnitIndex])
                    set UnitCastingDummy[UnitIndex] = null
                    call Sound3D(target,'A00U')
                    call SetUnitAnimation(target,"death")
                endif
            else
                set UnitCastingSD[UnitIndex] = UnitCastingSD[UnitIndex] - SD
                call SetUnitAnimationByIndex(UnitCastingDummy[UnitIndex], (R2I((UnitCastingSD[UnitIndex] / UnitCastingSDMAX[UnitIndex]) * 100)-1) )
            endif
        else
            if ( UnitSD[UnitIndex] - SD ) < 0 then
                if UnitSD[UnitIndex] == 0 then
                    //이미 0임
                else
                    //찐무력화
                    call Sound3D(target,'A00U')
                    set UnitSD[UnitIndex] = 0
                endif
            else
                set UnitSD[UnitIndex] = UnitSD[UnitIndex] - SD
            endif
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
        
        call PlayerBossAttack(source, target, dmg)
        return CounterBoolean
    endfunction
endlibrary