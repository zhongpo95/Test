library UIArcana initializer Init requires DataItem, StatsSet, UIItem, ITEM
    globals
        integer F_ArcanaBackDrop                   //인포 배경
        integer F_ArcanaCancelButton               //X버튼
        
        boolean array F_ArcanaOnOff                //인포 온오프
    endglobals
    
    private function ArcanaOpen takes nothing returns nothing
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        //메뉴 버튼을 누르면 메뉴 버튼 비활설화 + 메뉴 배경 표시
        //다시 메뉴 버튼을 누르면 메뉴버튼 활성화 + 메뉴 배경 숨김
        if F_ArcanaOnOff[pid] == true then
            call DzFrameShow(F_ArcanaBackDrop, false)
            set F_ArcanaOnOff[pid] = false
        else
            call DzFrameShow(F_ArcanaBackDrop, true)
            set F_ArcanaOnOff[pid] = true
        endif
    endfunction
    
    private function Main takes nothing returns nothing
        local string s
        local integer i
        call DzLoadToc("war3mapImported\\Templates.toc")

        set i = 0
        loop
            call SaveInteger(ArcanaData, 0, i, 0)
            call SaveInteger(ArcanaData, 1, i, 0)
            call SaveInteger(ArcanaData, 2, i, 0)
            call SaveInteger(ArcanaData, 3, i, 0)
            call SaveInteger(ArcanaData, 4, i, 0)
            call SaveInteger(ArcanaData, 5, i, 0)
            set i  = i + 1
        exitwhen i == 54
        endloop

        //메뉴 배경
        set F_ArcanaBackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "StandardEditBoxBackdropTemplate", 0)
        call DzFrameSetAbsolutePoint(F_ArcanaBackDrop, JN_FRAMEPOINT_CENTER, 0.225, 0.315)
        call DzFrameSetSize(F_ArcanaBackDrop, 0.40, 0.27)
        
        //메뉴 취소 버튼
        set F_ArcanaCancelButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", F_ArcanaBackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(F_ArcanaCancelButton, JN_FRAMEPOINT_TOPRIGHT, F_ArcanaBackDrop , JN_FRAMEPOINT_TOPRIGHT, -0.010, -0.010)
        call DzFrameSetText(F_ArcanaCancelButton, "X")
        call DzFrameSetSize(F_ArcanaCancelButton, 0.03, 0.03)
        call DzFrameSetScriptByCode(F_ArcanaCancelButton, JN_FRAMEEVENT_MOUSE_UP, function ArcanaOpen, false)
        
        call DzFrameShow(F_ArcanaBackDrop, false)
    endfunction
    
    private function OKey takes nothing returns nothing
        local integer key = DzGetTriggerKey()
        local integer i = 0
        local integer j = GetPlayerId(DzGetTriggerKeyPlayer())
        
        if DzGetTriggerKeyPlayer()==GetLocalPlayer() then
            set i = JNMemoryGetByte(JNGetModuleHandle("Game.dll")+0xD04FEC)
        endif
        
        if i==1 then
        else
            if PickCheck[j] == true then
                if key == 'O' then
                    if F_ArcanaOnOff[j] == true then
                        call DzFrameShow(F_ArcanaBackDrop, false)
                        set F_ArcanaOnOff[j] = false
                    else
                        call DzFrameShow(F_ArcanaBackDrop, true)
                        set F_ArcanaOnOff[j] = true
                    endif
                endif
            endif
        endif
    endfunction
    
    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer index
        
        call TriggerRegisterTimerEventSingle( t, 3.0 )
        call TriggerAddAction( t, function Main )
        call DzLoadToc("war3mapimported\\BoxedText.toc")
        
        set F_ArcanaOnOff[0] = false
        set F_ArcanaOnOff[1] = false
        set F_ArcanaOnOff[2] = false
        set F_ArcanaOnOff[3] = false
        set F_ArcanaOnOff[4] = false
        set F_ArcanaOnOff[5] = false
        
        //P버튼으로 인포창 열기 및 닫기
        call DzTriggerRegisterKeyEventByCode(null, 'O', 0, false, function OKey)
        
        set t = null
    endfunction
endlibrary