library UIBigWheel initializer init requires DataUnit, FrameCount

    globals
        integer BW_BackDrop
        boolean array BWShow
        integer BW_Money = 10000
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

    private function Command takes nothing returns nothing
        local integer bet_amount = 100
        local integer winnings = 0
        local integer spin_index
        local integer spin_value
        
        // -------------------------------------------------------------
        // 베팅할 발판을 여기서 선택하세요.-
        // 베팅할 배당값을 직접 입력합니다. (20, 51, 52, 53, 2, 0)
        local integer bet_on_value = 51 
        // -------------------------------------------------------------
        
        set BW_Money = BW_Money - 100
        set spin_index = GetSpinResult()
        set spin_value = Wheel_Layout[spin_index]
        
        //call BJDebugMsg("--- 시뮬레이션 결과 ---")
        call BJDebugMsg("내가 베팅한 발판: " + GetValueName(bet_on_value) + " / 이번 당첨 발판 위치: " + I2S(spin_index) + "번" + " / 이번 당첨 발판: " + GetValueName(spin_value))
        
        if spin_value == bet_on_value then
            set winnings = bet_amount * GetPayout(spin_value)
            call BJDebugMsg("당첨! 돌려받은 금액: " + I2S(winnings))
            set BW_Money = BW_Money + winnings
            call BJDebugMsg("보유금액: " + I2S(BW_Money))
        else
            call BJDebugMsg("아쉽지만 꽝입니다. 돌려받은 금액: 0")
            call BJDebugMsg("보유금액: " + I2S(BW_Money))
        endif
        //call BJDebugMsg("-----------------------")
    endfunction

    private function Main takes nothing returns nothing
        local string s
        local integer i
        
        //메뉴 배경
        set BW_BackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetTexture(BW_BackDrop, "File00005255.blp", 0)
        call DzFrameSetAbsolutePoint(BW_BackDrop, JN_FRAMEPOINT_CENTER, 0.400, 0.300)
        call DzFrameSetSize(BW_BackDrop, 0.650, 0.450)
        call DzFrameSetAlpha(BW_BackDrop, 225)
        call DzFrameSetPriority(BW_BackDrop, 5)

        call DzFrameShow(BW_BackDrop, false)
    endfunction

    /*
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
    */
    //20배 마리 ReplaceableTextures\CommandButtons\BTNArcana19.blp
    //5배A 아루 ReplaceableTextures\CommandButtons\BTNArcana04.blp
    //5배B 히나 ReplaceableTextures\CommandButtons\BTNArcana15.blp
    //5배C 네루 ReplaceableTextures\CommandButtons\BTNArcana08.blp
    //1배 아로나 ReplaceableTextures\CommandButtons\BTNArcana21.blp
    //0배 미카 ReplaceableTextures\CommandButtons\BTNArcana03.blp

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
            set i = i + 1
        endloop
        call TriggerAddAction( t, function Command )
        set t = null

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
    endfunction
endlibrary