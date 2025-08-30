library UIBigWheel initializer init requires DataUnit, FrameCount

    globals
        integer BW_BackDrop
        boolean array BWShow
        integer BW_Money = 10000
        integer array BW_Icon
        integer BW_BackDrop2
        integer BW_x20
        integer BW_x51
        integer BW_x52
        integer BW_x53
        integer BW_x2
        integer BW_x20_Button
        integer BW_x51_Button
        integer BW_x52_Button
        integer BW_x53_Button
        integer BW_x2_Button
        integer BW_NowIcon
        integer BW_x1
        integer BW_x10
        integer BW_x100
        integer BW_x1000
        integer BW_x10000
        integer BW_x1_Button
        integer BW_x10_Button
        integer BW_x100_Button
        integer BW_x1000_Button
        integer BW_x10000_Button
        integer BW_Reset
        integer BW_Start
        integer BW_Reset_Button
        integer BW_Start_Button
        integer BW_Sprite
        integer BW_Leverage
        integer BW_BetAmount
        integer BW_Seed
        integer BW_TodayCount
        integer BW_NowValue
        integer BW_NowBetAmount
        integer array BW_MySeed
        boolean array BW_PlayerStart
        // 초기 타이머 간격 (1초에 2바퀴)
        private real CurrentInterval = 0.015625
        // 간격이 늘어나는 비율
        private real Acceleration = 1.02
    endglobals

    globals
        // 휠의 발판 수를 정의합니다.
        private integer array Wheel_Layout[32]
    endglobals

    //---------------------------------------------------------------------------------------
    // 스핀을 시뮬레이션하고 결과를 반환합니다.
    //---------------------------------------------------------------------------------------
    private function GetSpinResult takes nothing returns integer
        local integer spin_index = GetRandomInt(1, 32)
        return spin_index
    endfunction

    private function GetValueName takes integer value returns string
        if value == 20 then
            return "20배"
        elseif value == 51 then
            return "5배A"
        elseif value == 52 then
            return "5배B"
        elseif value == 53 then
            return "5배C"
        elseif value == 2 then
            return "2배"
        elseif value == 0 then
            return "꽝"
        endif
        return "알 수 없음"
    endfunction

    private function GetPayout takes integer value returns integer
        if value == 20 then
            return 20
        elseif value >= 51 and value <= 53 then
            return 5
        elseif value == 2 then
            return 2
        endif
        return 0
    endfunction

    private function Command222 takes nothing returns nothing
        local integer winnings = 0
        local integer spin_index
        local integer spin_value
        
        // -------------------------------------------------------------
        // 베팅할 발판을 여기서 선택하세요.-
        // 베팅할 배당값을 직접 입력합니다. (20, 51, 52, 53, 2, 0)
        // -------------------------------------------------------------
        
        set BW_Money = BW_Money - 100
        set spin_index = GetSpinResult()
        set spin_value = Wheel_Layout[spin_index]
        
        //call BJDebugMsg("--- 시뮬레이션 결과 ---")
        call BJDebugMsg("내가 베팅한 발판: " + GetValueName(BW_NowValue) + " / 이번 당첨 발판 위치: " + I2S(spin_index) + "번" + " / 이번 당첨 발판: " + GetValueName(spin_value))
        
        if spin_value == BW_NowValue then
            set winnings = BW_NowBetAmount * GetPayout(spin_value)
            call BJDebugMsg("당첨! 돌려받은 금액: " + I2S(winnings))
            set BW_Money = BW_Money + winnings
            call BJDebugMsg("보유금액: " + I2S(BW_Money))
        else
            call BJDebugMsg("아쉽지만 꽝입니다. 돌려받은 금액: 0")
            call BJDebugMsg("보유금액: " + I2S(BW_Money))
        endif
        //call BJDebugMsg("-----------------------")
    endfunction

    //20배 마리 ReplaceableTextures\\CommandButtons\\BTNArcana19.blp
    //5배A 아루 ReplaceableTextures\\CommandButtons\\BTNArcana04.blp
    //5배B 히나 ReplaceableTextures\\CommandButtons\\BTNArcana15.blp
    //5배C 네루 ReplaceableTextures\\CommandButtons\\BTNArcana08.blp
    //1배 아로나 ReplaceableTextures\\CommandButtons\\BTNArcana21.blp
    //0배 미카 ReplaceableTextures\\CommandButtons\\BTNArcana03.blp

    //얼마,배율,
    //call DzSyncData(("SpinStart"),I2S(BW_NowBetAmount)+"\t"+I2S(BW_NowValue) )
        /*
        //local tick t = tick.getExpired()
        local SkillFx fx = t.data
        call fx.Stop()
        call t.destroy()
        call t.start( 0.02, false, function EffectFunction )\
        Wheel_Layout[i]
        */
        
    private struct SpinStruct
        integer pid
        integer SpinCount
        integer BetAmount
        integer Value
        integer FinalSpinIndex
        integer MaxSpins
        integer Spinindex
        real Speed
    endstruct
    
    private function SpinStartEffect takes nothing returns nothing
        local tick t = tick.getExpired()
        local SpinStruct st = t.data
        local integer currentSpin = 0
        
        set st.SpinCount = st.SpinCount + 1

        call BJDebugMsg( I2S(st.SpinCount)+ ":" + I2S(st.MaxSpins))
        if st.SpinCount >= st.MaxSpins then
            set currentSpin = ModuloInteger(st.SpinCount, 32)
            if currentSpin == 0 then
                set currentSpin = 32
            endif
            if st.Value == Wheel_Layout[currentSpin] then
                set BW_MySeed[st.pid] = BW_MySeed[st.pid] + st.BetAmount * GetPayout(st.Value)
                call BJDebugMsg("당첨! 돌려받은 금액: " + I2S(st.BetAmount * GetPayout(st.Value)))
            else
                call BJDebugMsg("아쉽지만 꽝입니다. 돌려받은 금액: 0")
            endif
            if GetLocalPlayer() == Player(st.pid) then
                set BW_NowBetAmount = 0
                call DzFrameSetText(BW_BetAmount,I2S(BW_NowBetAmount))
                call DzFrameSetText(BW_Seed,I2S(BW_MySeed[st.pid]))
                call DzFrameSetPoint(BW_Sprite, JN_FRAMEPOINT_BOTTOMLEFT, BW_Icon[currentSpin] , JN_FRAMEPOINT_BOTTOMLEFT, -0.005 , -0.005 )
            endif
            //call BJDebugMsg(I2S(currentSpin) + "번 발판인 " + GetValueName(Wheel_Layout[currentSpin]) + " 입니다!")
            set BW_PlayerStart[st.pid] = false
            set st.Speed = 0
            set st.pid = 0
            set st.SpinCount = 0
            set st.BetAmount = 0
            set st.Value = 0
            set st.MaxSpins = 0
            set st.Spinindex = 0
            call st.destroy()
            call t.destroy()
        else
            set currentSpin = ModuloInteger(st.SpinCount, 32)
            if currentSpin == 0 then
                set currentSpin = 32
            endif

            if GetLocalPlayer() == Player(st.pid) then
                call DzFrameSetPoint(BW_Sprite, JN_FRAMEPOINT_BOTTOMLEFT, BW_Icon[currentSpin] , JN_FRAMEPOINT_BOTTOMLEFT, -0.005 , -0.005 )
            endif
    
            // 멈추기 전 마지막 2칸의 속도 조절
            if st.MaxSpins - st.SpinCount <= 8 then
                set st.Speed = 0.75
            else
                if st.Speed < 0.5 then
                    set st.Speed = st.Speed * Acceleration
                endif
            endif
            
            call t.start( st.Speed, false, function SpinStartEffect )
        endif

    endfunction

    private function SpinStart takes nothing returns nothing
        local string s = DzGetTriggerSyncData()
        local integer pid = GetPlayerId(DzGetTriggerSyncPlayer())
        local integer finalOffset = 0
        local integer randomFullSpins = 0
        local tick t
        local SpinStruct st
        if BW_PlayerStart[pid] == false then
            set BW_PlayerStart[pid] = true
            //마지막멈춤 랜덤조절
            set finalOffset = GetRandomInt(0, 8)

            set t = tick.create(0) 
            set st = SpinStruct.create()
            set st.pid = pid
            set st.Spinindex = GetRandomInt(1,32)
            set st.SpinCount = 0
            set st.BetAmount = S2I(JNStringSplit(DzGetTriggerSyncData(), "\t", 0))
            set st.Value = S2I(JNStringSplit(DzGetTriggerSyncData(), "\t", 1))
            set st.Speed = 0.015
            set t.data = st
            set randomFullSpins = GetRandomInt(3, 4) * 32
            set st.MaxSpins = randomFullSpins + st.Spinindex
            call t.start( st.Speed, false, function SpinStartEffect )
            set BW_MySeed[pid] = BW_MySeed[pid] - st.BetAmount
            if GetLocalPlayer() == Player(st.pid) then
                call DzFrameSetText(BW_Seed, I2S(BW_MySeed[st.pid]))
            endif
            //call BJDebugMsg("랜덤값 : " + I2S(st.Spinindex) +" 베팅액 : " + I2S(BetAmount) +" 남은돈 : " + I2S(BW_MySeed[pid]) )
        else
        endif
    endfunction
    //각플타이머
        

    private function ClickRLButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        
        if f == BW_x20_Button then
            call DzFrameSetTexture(BW_NowIcon, "ReplaceableTextures\\CommandButtons\\BTNArcana19.blp", 0)
            call DzFrameSetText(BW_Leverage,"x"+"20")
            set BW_NowValue = 20
        elseif f == BW_x51_Button then
            call DzFrameSetTexture(BW_NowIcon, "ReplaceableTextures\\CommandButtons\\BTNArcana04.blp", 0)
            call DzFrameSetText(BW_Leverage,"x"+"5")
            set BW_NowValue = 51
        elseif f == BW_x52_Button then
            call DzFrameSetTexture(BW_NowIcon, "ReplaceableTextures\\CommandButtons\\BTNArcana15.blp", 0)
            call DzFrameSetText(BW_Leverage,"x"+"5")
            set BW_NowValue = 52
        elseif f == BW_x53_Button then
            call DzFrameSetTexture(BW_NowIcon, "ReplaceableTextures\\CommandButtons\\BTNArcana08.blp", 0)
            call DzFrameSetText(BW_Leverage,"x"+"5")
            set BW_NowValue = 53
        elseif f == BW_x2_Button then
            call DzFrameSetTexture(BW_NowIcon, "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)
            call DzFrameSetText(BW_Leverage,"x"+"2")
            set BW_NowValue = 2
        endif
        if f == BW_x1_Button then
            if 1 <= ( BW_MySeed[pid] - BW_NowBetAmount ) then
                set BW_NowBetAmount = BW_NowBetAmount + 1
                call DzFrameSetText(BW_BetAmount,I2S(BW_NowBetAmount))
            endif
        elseif f == BW_x10_Button then
            if 10 <= ( BW_MySeed[pid] - BW_NowBetAmount ) then
                set BW_NowBetAmount = BW_NowBetAmount + 10
                call DzFrameSetText(BW_BetAmount,I2S(BW_NowBetAmount))
            endif
        elseif f == BW_x100_Button then
            if 100 <= ( BW_MySeed[pid] - BW_NowBetAmount ) then
                set BW_NowBetAmount = BW_NowBetAmount + 100
                call DzFrameSetText(BW_BetAmount,I2S(BW_NowBetAmount))
            endif
        elseif f == BW_x1000_Button then
            if 1000 <= ( BW_MySeed[pid] - BW_NowBetAmount ) then
                set BW_NowBetAmount = BW_NowBetAmount + 1000
                call DzFrameSetText(BW_BetAmount,I2S(BW_NowBetAmount))
            endif
        elseif f == BW_x10000_Button then
            if 10000 <= ( BW_MySeed[pid] - BW_NowBetAmount ) then
                set BW_NowBetAmount = BW_NowBetAmount + 10000
                call DzFrameSetText(BW_BetAmount,I2S(BW_NowBetAmount))
            endif
        endif
        if f == BW_Reset_Button then
            set BW_NowBetAmount = 0
            call DzFrameSetText(BW_BetAmount,I2S(BW_NowBetAmount))
        elseif f == BW_Start_Button then
            //베팅액, 배율 오늘시도가능횟수가 0이아님
            if BW_NowBetAmount != 0 and BW_NowValue != 0 and true then
                call DzSyncData(("SpinStart"),I2S(BW_NowBetAmount)+"\t"+I2S(BW_NowValue) )
            endif
        endif
    endfunction
    
    private function Main takes nothing returns nothing
        local string s
        local integer i
        
        //메뉴 배경
        set BW_BackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetTexture(BW_BackDrop, "File00005255.blp", 0)
        call DzFrameSetAbsolutePoint(BW_BackDrop, JN_FRAMEPOINT_CENTER, 0.400, 0.300)
        call DzFrameSetSize(BW_BackDrop, 0.650, 0.450)
        //call DzFrameSetAlpha(BW_BackDrop, 225)
        call DzFrameSetPriority(BW_BackDrop, 5)

        //윗줄
        set BW_Icon[1]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[1], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.075 , 0.380 )
        call DzFrameSetSize(BW_Icon[1], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[1], "ReplaceableTextures\\CommandButtons\\BTNArcana19.blp", 0)

        set BW_Icon[2]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[2], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.125 , 0.380 )
        call DzFrameSetSize(BW_Icon[2], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[2], "ReplaceableTextures\\CommandButtons\\BTNArcana04.blp", 0)

        set BW_Icon[3]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[3], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.175 , 0.380 )
        call DzFrameSetSize(BW_Icon[3], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[3], "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)

        set BW_Icon[4]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[4], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.225 , 0.380 )
        call DzFrameSetSize(BW_Icon[4], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[4], "ReplaceableTextures\\CommandButtons\\BTNArcana15.blp", 0)

        set BW_Icon[5]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[5], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.275 , 0.380 )
        call DzFrameSetSize(BW_Icon[5], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[5], "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)

        set BW_Icon[6]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[6], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.325 , 0.380 )
        call DzFrameSetSize(BW_Icon[6], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[6], "ReplaceableTextures\\CommandButtons\\BTNArcana08.blp", 0)

        set BW_Icon[7]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[7], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.375 , 0.380 )
        call DzFrameSetSize(BW_Icon[7], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[7], "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)

        set BW_Icon[8]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[8], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.425 , 0.380 )
        call DzFrameSetSize(BW_Icon[8], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[8], "ReplaceableTextures\\CommandButtons\\BTNArcana04.blp", 0)

        set BW_Icon[9]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[9], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.475 , 0.380 )
        call DzFrameSetSize(BW_Icon[9], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[9], "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)

        set BW_Icon[10]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[10], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.525 , 0.380 )
        call DzFrameSetSize(BW_Icon[10], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[10], "ReplaceableTextures\\CommandButtons\\BTNArcana15.blp", 0)

        set BW_Icon[11]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[11], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.575 , 0.3800 )
        call DzFrameSetSize(BW_Icon[11], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[11], "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)


        //오른쪽줄
        set BW_Icon[12]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[12], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.575 , 0.3275 )
        call DzFrameSetSize(BW_Icon[12], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[12], "ReplaceableTextures\\CommandButtons\\BTNArcana08.blp", 0)
        
        set BW_Icon[13]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[13], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.575 , 0.2750 )
        call DzFrameSetSize(BW_Icon[13], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[13], "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)
        
        set BW_Icon[14]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[14], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.575 , 0.2225 )
        call DzFrameSetSize(BW_Icon[14], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[14], "ReplaceableTextures\\CommandButtons\\BTNArcana04.blp", 0)
        
        set BW_Icon[15]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[15], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.575 , 0.1700 )
        call DzFrameSetSize(BW_Icon[15], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[15], "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)
        
        set BW_Icon[16]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[16], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.575 , 0.1175 )
        call DzFrameSetSize(BW_Icon[16], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[16], "ReplaceableTextures\\CommandButtons\\BTNArcana15.blp", 0)

        //아랫줄
        set BW_Icon[27]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[27], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.075 , 0.0650 )
        call DzFrameSetSize(BW_Icon[27], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[27], "ReplaceableTextures\\CommandButtons\\BTNArcana04.blp", 0)

        set BW_Icon[26]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[26], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.125 , 0.065 )
        call DzFrameSetSize(BW_Icon[26], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[26], "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)

        set BW_Icon[25]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[25], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.175 , 0.065 )
        call DzFrameSetSize(BW_Icon[25], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[25], "ReplaceableTextures\\CommandButtons\\BTNArcana08.blp", 0)

        set BW_Icon[24]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[24], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.225 , 0.065 )
        call DzFrameSetSize(BW_Icon[24], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[24], "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)

        set BW_Icon[23]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[23], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.275 , 0.065 )
        call DzFrameSetSize(BW_Icon[23], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[23], "ReplaceableTextures\\CommandButtons\\BTNArcana15.blp", 0)

        set BW_Icon[22]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[22], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.325 , 0.065 )
        call DzFrameSetSize(BW_Icon[22], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[22], "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)

        set BW_Icon[21]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[21], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.375 , 0.065 )
        call DzFrameSetSize(BW_Icon[21], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[21], "ReplaceableTextures\\CommandButtons\\BTNArcana04.blp", 0)

        set BW_Icon[20]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[20], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.425 , 0.065 )
        call DzFrameSetSize(BW_Icon[20], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[20], "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)

        set BW_Icon[19]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[19], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.475 , 0.065 )
        call DzFrameSetSize(BW_Icon[19], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[19], "ReplaceableTextures\\CommandButtons\\BTNArcana08.blp", 0)

        set BW_Icon[18]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[18], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.525 , 0.065 )
        call DzFrameSetSize(BW_Icon[18], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[18], "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)

        set BW_Icon[17]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[17], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.575 , 0.065 )
        call DzFrameSetSize(BW_Icon[17], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[17], "ReplaceableTextures\\CommandButtons\\BTNArcana03.blp", 0)

        
        //왼쪽줄
        set BW_Icon[32]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[32], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.075 , 0.3275 )
        call DzFrameSetSize(BW_Icon[32], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[32], "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)
        
        set BW_Icon[31]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[31], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.075 , 0.2750 )
        call DzFrameSetSize(BW_Icon[31], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[31], "ReplaceableTextures\\CommandButtons\\BTNArcana08.blp", 0)
        
        set BW_Icon[30]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[30], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.075 , 0.2225 )
        call DzFrameSetSize(BW_Icon[30], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[30], "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)
        
        set BW_Icon[29]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[29], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.075 , 0.1700 )
        call DzFrameSetSize(BW_Icon[29], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[29], "ReplaceableTextures\\CommandButtons\\BTNArcana15.blp", 0)
        
        set BW_Icon[28]=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Icon[28], JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.075 , 0.1175 )
        call DzFrameSetSize(BW_Icon[28], 0.04 , 0.04)
        call DzFrameSetTexture(BW_Icon[28], "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)


        set BW_BackDrop2=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_BackDrop2, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.310 , 0.2900 )
        call DzFrameSetSize(BW_BackDrop2, 0.12 , 0.12)
        call DzFrameSetTexture(BW_BackDrop2, "Sannyo.tga", 0)


        set BW_BackDrop2=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_BackDrop2, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.140 , 0.3000 )
        call DzFrameSetSize(BW_BackDrop2, 0.04 , 0.04)
        call DzFrameSetTexture(BW_BackDrop2, "ReplaceableTextures\\CommandButtons\\BTNArcana19.blp", 0)
        //20
        set BW_x20=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_x20, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.140 , 0.2650 )
        call DzFrameSetSize(BW_x20, 0.04 , 0.02)
        call DzFrameSetTexture(BW_x20, "x20.tga", 0)
        set BW_x20_Button=DzCreateFrameByTagName("BUTTON", "", BW_x20, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(BW_x20_Button, JN_FRAMEPOINT_BOTTOMLEFT, BW_x20 , JN_FRAMEPOINT_BOTTOMLEFT, 0.0 , 0.0 )
        call DzFrameSetSize(BW_x20_Button, 0.04, 0.02)
        call DzFrameSetScriptByCode(BW_x20_Button, JN_FRAMEEVENT_MOUSE_UP, function ClickRLButton, false)

        set BW_BackDrop2=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_BackDrop2, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.140 , 0.2225 )
        call DzFrameSetSize(BW_BackDrop2, 0.04 , 0.04)
        call DzFrameSetTexture(BW_BackDrop2, "ReplaceableTextures\\CommandButtons\\BTNArcana04.blp", 0)
        //5
        set BW_x51=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_x51, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.140 , 0.1875 )
        call DzFrameSetSize(BW_x51, 0.04 , 0.02)
        call DzFrameSetTexture(BW_x51, "x5.tga", 0)
        set BW_x51_Button=DzCreateFrameByTagName("BUTTON", "", BW_x51, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(BW_x51_Button, JN_FRAMEPOINT_BOTTOMLEFT, BW_x51 , JN_FRAMEPOINT_BOTTOMLEFT, 0.0 , 0.0 )
        call DzFrameSetSize(BW_x51_Button, 0.04, 0.02)
        call DzFrameSetScriptByCode(BW_x51_Button, JN_FRAMEEVENT_MOUSE_UP, function ClickRLButton, false)

        set BW_BackDrop2=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_BackDrop2, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.190 , 0.2225 )
        call DzFrameSetSize(BW_BackDrop2, 0.04 , 0.04)
        call DzFrameSetTexture(BW_BackDrop2, "ReplaceableTextures\\CommandButtons\\BTNArcana15.blp", 0)
        //5
        set BW_x52=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_x52, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.190 , 0.1875 )
        call DzFrameSetSize(BW_x52, 0.04 , 0.02)
        call DzFrameSetTexture(BW_x52, "x5.tga", 0)
        set BW_x52_Button=DzCreateFrameByTagName("BUTTON", "", BW_x52, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(BW_x52_Button, JN_FRAMEPOINT_BOTTOMLEFT, BW_x52 , JN_FRAMEPOINT_BOTTOMLEFT, 0.0 , 0.0 )
        call DzFrameSetSize(BW_x52_Button, 0.04, 0.02)
        call DzFrameSetScriptByCode(BW_x52_Button, JN_FRAMEEVENT_MOUSE_UP, function ClickRLButton, false)

        set BW_BackDrop2=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_BackDrop2, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.240 , 0.2225 )
        call DzFrameSetSize(BW_BackDrop2, 0.04 , 0.04)
        call DzFrameSetTexture(BW_BackDrop2, "ReplaceableTextures\\CommandButtons\\BTNArcana08.blp", 0)
        //5
        set BW_x53=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_x53, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.240 , 0.1875 )
        call DzFrameSetSize(BW_x53, 0.04 , 0.02)
        call DzFrameSetTexture(BW_x53, "x5.tga", 0)
        set BW_x53_Button=DzCreateFrameByTagName("BUTTON", "", BW_x53, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(BW_x53_Button, JN_FRAMEPOINT_BOTTOMLEFT, BW_x53 , JN_FRAMEPOINT_BOTTOMLEFT, 0.0 , 0.0 )
        call DzFrameSetSize(BW_x53_Button, 0.04, 0.02)
        call DzFrameSetScriptByCode(BW_x53_Button, JN_FRAMEEVENT_MOUSE_UP, function ClickRLButton, false)
        
        set BW_BackDrop2=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_BackDrop2, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.140 , 0.1450 )
        call DzFrameSetSize(BW_BackDrop2, 0.04 , 0.04)
        call DzFrameSetTexture(BW_BackDrop2, "ReplaceableTextures\\CommandButtons\\BTNArcana21.blp", 0)
        //2
        set BW_x2=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_x2, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.140 , 0.1100 )
        call DzFrameSetSize(BW_x2, 0.04 , 0.02)
        call DzFrameSetTexture(BW_x2, "x2.tga", 0)
        set BW_x2_Button=DzCreateFrameByTagName("BUTTON", "", BW_x2, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(BW_x2_Button, JN_FRAMEPOINT_BOTTOMLEFT, BW_x2 , JN_FRAMEPOINT_BOTTOMLEFT, 0.0 , 0.0 )
        call DzFrameSetSize(BW_x2_Button, 0.04, 0.02)
        call DzFrameSetScriptByCode(BW_x2_Button, JN_FRAMEEVENT_MOUSE_UP, function ClickRLButton, false)
        
        set BW_BackDrop2=JNCreateFrameByType("TEXT","",BW_BackDrop,"", FrameCount())
        call DzFrameSetSize(BW_BackDrop2,0.145,0.00)
        call DzFrameSetPoint(BW_BackDrop2, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.4700 , 0.3000 )
        call DzFrameSetText(BW_BackDrop2,"선 택")
        call DzFrameSetFont(BW_BackDrop2, "Fonts\\DFHeiMd.ttf", 0.016, 0)
        call DzFrameShow(BW_BackDrop2,true)

        //현재아이콘
        set BW_NowIcon=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_NowIcon, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.4850 , 0.3000 )
        call DzFrameSetSize(BW_NowIcon, 0.05 , 0.05)
        call DzFrameSetTexture(BW_NowIcon, "ReplaceableTextures\\CommandButtons\\BTNArcana03.blp", 0)
        
        set BW_BackDrop2=JNCreateFrameByType("TEXT","",BW_BackDrop,"", FrameCount())
        call DzFrameSetSize(BW_BackDrop2,0.145,0.00)
        call DzFrameSetPoint(BW_BackDrop2, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.4700 , 0.2500 )
        call DzFrameSetText(BW_BackDrop2,"배 율")
        call DzFrameSetFont(BW_BackDrop2, "Fonts\\DFHeiMd.ttf", 0.016, 0)
        call DzFrameShow(BW_BackDrop2,true)

        set BW_Leverage=JNCreateFrameByType("TEXT","",BW_BackDrop,"", FrameCount())
        call DzFrameSetSize(BW_Leverage,0.145,0.00)
        call DzFrameSetPoint(BW_Leverage, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.5350 , 0.2500 )
        call DzFrameSetText(BW_Leverage,"x"+"0")
        call DzFrameSetFont(BW_Leverage, "Fonts\\DFHeiMd.ttf", 0.016, 0)
        call DzFrameShow(BW_Leverage,true)
        
        set BW_BackDrop2=JNCreateFrameByType("TEXT","",BW_BackDrop,"", FrameCount())
        call DzFrameSetSize(BW_BackDrop2,0.145,0.00)
        call DzFrameSetPoint(BW_BackDrop2, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.4700 , 0.2200 )
        call DzFrameSetText(BW_BackDrop2,"베팅액")
        call DzFrameSetFont(BW_BackDrop2, "Fonts\\DFHeiMd.ttf", 0.016, 0)
        call DzFrameShow(BW_BackDrop2,true)

        set BW_BetAmount=JNCreateFrameByType("TEXT","",BW_BackDrop,"", FrameCount())
        call DzFrameSetSize(BW_BetAmount,0.145,0.00)
        call DzFrameSetPoint(BW_BetAmount, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.5350 , 0.2200 )
        call DzFrameSetText(BW_BetAmount,"0")
        call DzFrameSetFont(BW_BetAmount, "Fonts\\DFHeiMd.ttf", 0.016, 0)
        call DzFrameShow(BW_BetAmount,true)

        //1
        set BW_x1=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_x1, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.310 , 0.1875 )
        call DzFrameSetSize(BW_x1, 0.04 , 0.02)
        call DzFrameSetTexture(BW_x1, "BW1.tga", 0)
        set BW_x1_Button=DzCreateFrameByTagName("BUTTON", "", BW_x1, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(BW_x1_Button, JN_FRAMEPOINT_BOTTOMLEFT, BW_x1 , JN_FRAMEPOINT_BOTTOMLEFT, 0.0 , 0.0 )
        call DzFrameSetSize(BW_x1_Button, 0.04, 0.02)
        call DzFrameSetScriptByCode(BW_x1_Button, JN_FRAMEEVENT_MOUSE_UP, function ClickRLButton, false)
        //10
        set BW_x10=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_x10, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.360 , 0.1875 )
        call DzFrameSetSize(BW_x10, 0.04 , 0.02)
        call DzFrameSetTexture(BW_x10, "BW10.tga", 0)
        set BW_x10_Button=DzCreateFrameByTagName("BUTTON", "", BW_x10, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(BW_x10_Button, JN_FRAMEPOINT_BOTTOMLEFT, BW_x10 , JN_FRAMEPOINT_BOTTOMLEFT, 0.0 , 0.0 )
        call DzFrameSetSize(BW_x10_Button, 0.04, 0.02)
        call DzFrameSetScriptByCode(BW_x10_Button, JN_FRAMEEVENT_MOUSE_UP, function ClickRLButton, false)
        //100
        set BW_x100=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_x100, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.410 , 0.1875 )
        call DzFrameSetSize(BW_x100, 0.04 , 0.02)
        call DzFrameSetTexture(BW_x100, "BW100.tga", 0)
        set BW_x100_Button=DzCreateFrameByTagName("BUTTON", "", BW_x100, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(BW_x100_Button, JN_FRAMEPOINT_BOTTOMLEFT, BW_x100 , JN_FRAMEPOINT_BOTTOMLEFT, 0.0 , 0.0 )
        call DzFrameSetSize(BW_x100_Button, 0.04, 0.02)
        call DzFrameSetScriptByCode(BW_x100_Button, JN_FRAMEEVENT_MOUSE_UP, function ClickRLButton, false)
        //1000
        set BW_x1000=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_x1000, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.460 , 0.1875 )
        call DzFrameSetSize(BW_x1000, 0.04 , 0.02)
        call DzFrameSetTexture(BW_x1000, "BW1000.tga", 0)
        set BW_x1000_Button=DzCreateFrameByTagName("BUTTON", "", BW_x1000, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(BW_x1000_Button, JN_FRAMEPOINT_BOTTOMLEFT, BW_x1000 , JN_FRAMEPOINT_BOTTOMLEFT, 0.0 , 0.0 )
        call DzFrameSetSize(BW_x1000_Button, 0.04, 0.02)
        call DzFrameSetScriptByCode(BW_x1000_Button, JN_FRAMEEVENT_MOUSE_UP, function ClickRLButton, false)
        //10000
        set BW_x10000=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_x10000, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.510 , 0.1875 )
        call DzFrameSetSize(BW_x10000, 0.04 , 0.02)
        call DzFrameSetTexture(BW_x10000, "BW10000.tga", 0)
        set BW_x10000_Button=DzCreateFrameByTagName("BUTTON", "", BW_x10000, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(BW_x10000_Button, JN_FRAMEPOINT_BOTTOMLEFT, BW_x10000 , JN_FRAMEPOINT_BOTTOMLEFT, 0.0 , 0.0 )
        call DzFrameSetSize(BW_x10000_Button, 0.04, 0.02)
        call DzFrameSetScriptByCode(BW_x10000_Button, JN_FRAMEEVENT_MOUSE_UP, function ClickRLButton, false)
        
        //reset
        set BW_Reset=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Reset, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.385 , 0.1575 )
        call DzFrameSetSize(BW_Reset, 0.04 , 0.02)
        call DzFrameSetTexture(BW_Reset, "BWreset.tga", 0)
        set BW_Reset_Button=DzCreateFrameByTagName("BUTTON", "", BW_Reset, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(BW_Reset_Button, JN_FRAMEPOINT_BOTTOMLEFT, BW_Reset , JN_FRAMEPOINT_BOTTOMLEFT, 0.0 , 0.0 )
        call DzFrameSetSize(BW_Reset_Button, 0.04, 0.02)
        call DzFrameSetScriptByCode(BW_Reset_Button, JN_FRAMEEVENT_MOUSE_UP, function ClickRLButton, false)
        
        //start
        set BW_Start=DzCreateFrameByTagName("BACKDROP", "", BW_BackDrop, "template", FrameCount())
        call DzFrameSetPoint(BW_Start, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.435 , 0.1575 )
        call DzFrameSetSize(BW_Start, 0.04 , 0.02)
        call DzFrameSetTexture(BW_Start, "BWstart.tga", 0)
        set BW_Start_Button=DzCreateFrameByTagName("BUTTON", "", BW_Start, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetPoint(BW_Start_Button, JN_FRAMEPOINT_BOTTOMLEFT, BW_Start , JN_FRAMEPOINT_BOTTOMLEFT, 0.0 , 0.0 )
        call DzFrameSetSize(BW_Start_Button, 0.04, 0.02)
        call DzFrameSetScriptByCode(BW_Start_Button, JN_FRAMEEVENT_MOUSE_UP, function ClickRLButton, false)
        
        set BW_BackDrop2=JNCreateFrameByType("TEXT","",BW_BackDrop,"", FrameCount())
        call DzFrameSetSize(BW_BackDrop2,0.145,0.00)
        call DzFrameSetPoint(BW_BackDrop2, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.4700 , 0.1175 )
        call DzFrameSetText(BW_BackDrop2,"보유")
        call DzFrameSetFont(BW_BackDrop2, "Fonts\\DFHeiMd.ttf", 0.016, 0)
        call DzFrameShow(BW_BackDrop2,true)
        
        set BW_Seed=JNCreateFrameByType("TEXT","",BW_BackDrop,"", FrameCount())
        call DzFrameSetSize(BW_Seed,0.145,0.00)
        call DzFrameSetPoint(BW_Seed, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.5350 , 0.1175 )
        call DzFrameSetText(BW_Seed,I2S(BW_MySeed[GetPlayerId(GetLocalPlayer())]))
        call DzFrameSetFont(BW_Seed, "Fonts\\DFHeiMd.ttf", 0.016, 0)
        call DzFrameShow(BW_Seed,true)

        
        set BW_BackDrop2=JNCreateFrameByType("TEXT","",BW_BackDrop,"", FrameCount())
        call DzFrameSetSize(BW_BackDrop2,0.145,0.00)
        call DzFrameSetPoint(BW_BackDrop2, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.4500 , 0.0325 )
        call DzFrameSetText(BW_BackDrop2,"오늘 남은 횟수")
        call DzFrameSetFont(BW_BackDrop2, "Fonts\\DFHeiMd.ttf", 0.016, 0)
        call DzFrameShow(BW_BackDrop2,true)
        
        set BW_TodayCount=JNCreateFrameByType("TEXT","",BW_BackDrop,"", FrameCount())
        call DzFrameSetSize(BW_TodayCount, 0.145, 0.00)
        call DzFrameSetPoint(BW_TodayCount, JN_FRAMEPOINT_CENTER, BW_BackDrop , JN_FRAMEPOINT_BOTTOMLEFT, 0.5850 , 0.0325 )
        call DzFrameSetText(BW_TodayCount,"3")
        call DzFrameSetFont(BW_TodayCount, "Fonts\\DFHeiMd.ttf", 0.016, 0)
        call DzFrameShow(BW_TodayCount,true)


        set BW_Sprite=DzCreateFrameByTagName("SPRITE", "", BW_BackDrop, "", FrameCount())
        call DzFrameSetPoint(BW_Sprite, JN_FRAMEPOINT_BOTTOMLEFT, BW_Icon[1] , JN_FRAMEPOINT_BOTTOMLEFT, -0.005 , -0.005 )
        call DzFrameSetModel(BW_Sprite, "neon_sprite.mdx", 0, 0)
        call DzFrameShow(BW_Sprite, true)
        //call DzFrameSetPoint(BW_Sprite, JN_FRAMEPOINT_BOTTOMLEFT, BW_Icon[2] , JN_FRAMEPOINT_BOTTOMLEFT, -0.005 , -0.005 )

        call DzFrameShow(BW_BackDrop, false)
    endfunction

    
    private function Command takes nothing returns nothing
        local integer pid = GetPlayerId(GetTriggerPlayer())
        if BWShow[pid] == false then
            if GetLocalPlayer() == GetTriggerPlayer() then
                call DzFrameShow(BW_BackDrop,true)
            endif
            set BWShow[pid] = true
        elseif BWShow[pid] == true then
            if GetLocalPlayer() == GetTriggerPlayer() then
                call DzFrameShow(BW_BackDrop,false)
            endif
            set BWShow[pid] = false
        endif
    endfunction
    
    //20배 마리 ReplaceableTextures\\CommandButtons\\BTNArcana19.blp
    //5배A 아루 ReplaceableTextures\\CommandButtons\\BTNArcana04.blp
    //5배B 히나 ReplaceableTextures\\CommandButtons\\BTNArcana15.blp
    //5배C 네루 ReplaceableTextures\\CommandButtons\\BTNArcana08.blp
    //1배 아로나 ReplaceableTextures\\CommandButtons\\BTNArcana21.blp
    //0배 미카 ReplaceableTextures\\CommandButtons\\BTNArcana03.blp

    private function init takes nothing returns nothing
        local trigger t
        local integer i = 0
        
        set t = CreateTrigger()
        call TriggerAddAction( t, function Main )
        call TriggerRegisterTimerEvent(t, 0.10, false)
        
        set i = 0
        set t = CreateTrigger()
        loop
            exitwhen i > 4
            call TriggerRegisterPlayerChatEvent( t, Player(i), "-빅휠", false )
            set BWShow[i] = false
            set BW_MySeed[i] = 10000
            set BW_PlayerStart[i] = false
            set i = i + 1
        endloop
        call TriggerAddAction( t, function Command )
        set t = null

        set BW_NowValue = 0
        set BW_NowBetAmount = 0
        // 각 배당에 해당하는 구간 수 설정
        // 20배 배당 (20)
        set Wheel_Layout[1] = 20

        // 5배A 배당 (51)
        set Wheel_Layout[2] = 51
        set Wheel_Layout[8] = 51
        set Wheel_Layout[14] = 51
        set Wheel_Layout[21] = 51
        set Wheel_Layout[27] = 51

        // 5배B 배당 (52)
        set Wheel_Layout[4] = 52
        set Wheel_Layout[10] = 52
        set Wheel_Layout[16] = 52
        set Wheel_Layout[23] = 52
        set Wheel_Layout[29] = 52

        // 5배C 배당 (53)
        set Wheel_Layout[6] = 53
        set Wheel_Layout[12] = 53
        set Wheel_Layout[19] = 53
        set Wheel_Layout[25] = 53
        set Wheel_Layout[31] = 53
        
        // 꽝(0) 배당 (0)
        set Wheel_Layout[17] = 0

        // 2배 배당 (2)
        set Wheel_Layout[3] = 2
        set Wheel_Layout[5] = 2
        set Wheel_Layout[7] = 2
        set Wheel_Layout[9] = 2
        set Wheel_Layout[11] = 2
        set Wheel_Layout[13] = 2
        set Wheel_Layout[15] = 2
        set Wheel_Layout[18] = 2
        set Wheel_Layout[20] = 2
        set Wheel_Layout[22] = 2
        set Wheel_Layout[24] = 2
        set Wheel_Layout[26] = 2
        set Wheel_Layout[28] = 2
        set Wheel_Layout[30] = 2
        set Wheel_Layout[32] = 2

        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("SpinStart"),(false))
        call TriggerAddAction(t,function SpinStart)
        set t = null
    endfunction
endlibrary