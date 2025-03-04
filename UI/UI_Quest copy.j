library UIQuest initializer init requires Stash, FrameCount

    globals
        integer QuestMain
        integer QuestMainBD
        integer array Quest
        integer array QuestText
        integer array QuestText2
        boolean array Quest_OnOff
        integer QuestNumber = 0
    endglobals
    
    private function Show takes nothing returns nothing
        if Quest_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] == true then
            call DzFrameShow(Quest[0], false)
            call DzFrameShow(Quest[1], false)
            call DzFrameShow(Quest[2], false)
            set Quest_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = false
        else
            if QuestNumber == 3 then
                call DzFrameShow(Quest[0], true)
                call DzFrameShow(Quest[1], true)
                call DzFrameShow(Quest[2], true)
            elseif QuestNumber == 2 then
                call DzFrameShow(Quest[0], true)
                call DzFrameShow(Quest[1], true)
            elseif QuestNumber == 1 then
                call DzFrameShow(Quest[0], true)
            elseif QuestNumber == 0 then
            endif
            set Quest_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
        endif
    endfunction

    function TodayReset takes integer pid returns nothing
        if GetLocalPlayer() == Player(pid) then
            set QuestNumber = 3
            call DzFrameSetText( QuestText[0], "일일 보스 처치" )
            call DzFrameSetText( QuestText2[0], "보스 처치 0/7" )
            call DzFrameSetText( QuestText[1], "일일 보스 처치" )
            call DzFrameSetText( QuestText2[1], "보스 처치 0/5" )
            call DzFrameSetText( QuestText[2], "일일 보스 처치" )
            call DzFrameSetText( QuestText2[2], "보스 처치 0/3" )
            call DzFrameShow(Quest[0], true)
            call DzFrameShow(Quest[1], true)
            call DzFrameShow(Quest[2], true)
            set Quest_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
            call StashSave(pid:PLAYER_DATA, "슬롯"+ I2S(PlayerSlotNumber[pid]) + ".TQuest", "0")
        endif
    endfunction

    function TodaySet takes integer pid returns nothing
        local integer q
        if GetLocalPlayer() == Player(pid) then
            if JNUse( ) then
                set q = S2I(StashLoad(pid:PLAYER_DATA, "슬롯"+ I2S(PlayerSlotNumber[pid]) + ".TQuest", "0"))
                if q >= 7 then
                    set QuestNumber = 0
                elseif q >= 5 then
                    call DzFrameSetText( QuestText[0], "일일 보스 처치" )
                    call DzFrameSetText( QuestText2[0], "보스 처치 "+I2S(q)+"/7" )
                    call DzFrameShow(Quest[0], true)
                    set QuestNumber = 1
                elseif q >= 3 then
                    call DzFrameSetText( QuestText[0], "일일 보스 처치" )
                    call DzFrameSetText( QuestText2[0], "보스 처치 "+I2S(q)+"/7" )
                    call DzFrameSetText( QuestText[1], "일일 보스 처치" )
                    call DzFrameSetText( QuestText2[1], "보스 처치 "+I2S(q)+"/5" )
                    call DzFrameShow(Quest[0], true)
                    call DzFrameShow(Quest[1], true)
                    set QuestNumber = 2
                else
                    call DzFrameSetText( QuestText[0], "일일 보스 처치" )
                    call DzFrameSetText( QuestText2[0], "보스 처치 "+I2S(q)+"/7" )
                    call DzFrameSetText( QuestText[1], "일일 보스 처치" )
                    call DzFrameSetText( QuestText2[1], "보스 처치 "+I2S(q)+"/5" )
                    call DzFrameSetText( QuestText[2], "일일 보스 처치" )
                    call DzFrameSetText( QuestText2[2], "보스 처치 "+I2S(q)+"/3" )
                    call DzFrameShow(Quest[0], true)
                    call DzFrameShow(Quest[1], true)
                    call DzFrameShow(Quest[2], true)
                    set QuestNumber = 3
                endif
                set Quest_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
            else
                call BJDebugMsg("서버에 연결되어 있지 않아 퀘스트를 갱신할 수 없습니다.")
            endif
        endif
    endfunction

    function QuestRemove takes integer pid returns nothing
        if GetLocalPlayer() == Player(pid) then
            set QuestNumber = QuestNumber - 1

            call DzFrameSetText( QuestText[QuestNumber], "" )
            call DzFrameSetText( QuestText2[QuestNumber], "" )

            call DzFrameShow(Quest[QuestNumber], false)
        endif
    endfunction
    
    function TodayQuestPlus takes integer pid returns nothing
        local integer q
        if GetLocalPlayer() == Player(pid) then
            set q = S2I(StashLoad(pid:PLAYER_DATA, "슬롯"+ I2S(PlayerSlotNumber[pid]) + ".TQuest", "0")) + 1
            call BJDebugMsg(I2S(q))
            call StashSave(pid:PLAYER_DATA, "슬롯"+ I2S(PlayerSlotNumber[pid]) + ".TQuest", I2S(q))

            if q >= 7 then
                if q == 7 then
                    call QuestRemove(pid)
                    call BJDebugMsg("7킬 보상주셈")
                endif
            elseif q >= 5 then
                call DzFrameSetText( QuestText[0], "일일 보스 처치" )
                call DzFrameSetText( QuestText2[0], "보스 처치 "+I2S(q)+"/7" )
                call DzFrameShow(Quest[0], true)
                if q == 5 then
                    call QuestRemove(pid)
                    call BJDebugMsg("5킬 보상주셈")
                endif
            elseif q >= 3 then
                call DzFrameSetText( QuestText[0], "일일 보스 처치" )
                call DzFrameSetText( QuestText2[0], "보스 처치 "+I2S(q)+"/7" )
                call DzFrameSetText( QuestText[1], "일일 보스 처치" )
                call DzFrameSetText( QuestText2[1], "보스 처치 "+I2S(q)+"/5" )
                call DzFrameShow(Quest[0], true)
                call DzFrameShow(Quest[1], true)
                if q == 3 then
                    call QuestRemove(pid)
                    call BJDebugMsg("3킬 보상주셈")
                endif
            else
                call DzFrameSetText( QuestText[0], "일일 보스 처치" )
                call DzFrameSetText( QuestText2[0], "보스 처치 "+I2S(q)+"/7" )
                call DzFrameSetText( QuestText[1], "일일 보스 처치" )
                call DzFrameSetText( QuestText2[1], "보스 처치 "+I2S(q)+"/5" )
                call DzFrameSetText( QuestText[2], "일일 보스 처치" )
                call DzFrameSetText( QuestText2[2], "보스 처치 "+I2S(q)+"/3" )
                call DzFrameShow(Quest[0], true)
                call DzFrameShow(Quest[1], true)
                call DzFrameShow(Quest[2], true)
            endif
            set Quest_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
        endif
    endfunction


    private function QuestFrame takes integer i, real x, real y returns nothing
        set Quest[i] = DzCreateFrameByTagName("BACKDROP", "", QuestMain, "template", FrameCount())
        call DzFrameSetAbsolutePoint(Quest[i], 4, x, y)
        call DzFrameSetSize(Quest[i],0.2,0.05)
        call DzFrameSetTexture(Quest[i],"QuestT.blp",0)
        call DzFrameShow(Quest[i],true)

        set QuestText[i] = DzCreateFrameByTagName("TEXT", "", Quest[i], "template", FrameCount())
        call DzFrameSetAbsolutePoint(QuestText[i], JN_FRAMEPOINT_TOPRIGHT, x + 0.08, y + 0.024 )
        call DzFrameSetAbsolutePoint(QuestText[i], JN_FRAMEPOINT_TOPLEFT, x - 0.09,  y + 0.024 )
        call DzFrameSetAbsolutePoint(QuestText[i], JN_FRAMEPOINT_BOTTOMRIGHT, x + 0.08, y + 0.010 )
        call DzFrameSetAbsolutePoint(QuestText[i], JN_FRAMEPOINT_BOTTOMLEFT, x - 0.09, y + 0.010 )
        call JNFrameSetTextAlignment(QuestText[i], JN_TEXT_JUSTIFY_MIDDLE, JN_TEXT_JUSTIFY_CENTER)
        call DzFrameSetFont(QuestText[i], "Fonts\\DFHeiMd.ttf", 0.008, 0)
        call DzFrameSetText( QuestText[i], "퀘스트이름" )

        set QuestText2[i] = DzCreateFrameByTagName("TEXT", "", Quest[i], "template", FrameCount())
        call DzFrameSetAbsolutePoint(QuestText2[i], JN_FRAMEPOINT_TOPRIGHT, x + 0.08, y + 0.010)
        call DzFrameSetAbsolutePoint(QuestText2[i], JN_FRAMEPOINT_TOPLEFT, x - 0.09, y + 0.010)
        call DzFrameSetAbsolutePoint(QuestText2[i], JN_FRAMEPOINT_BOTTOMRIGHT, x + 0.08, y - 0.023)
        call DzFrameSetAbsolutePoint(QuestText2[i], JN_FRAMEPOINT_BOTTOMLEFT, x - 0.09, y - 0.023)
        call DzFrameSetFont(QuestText2[i], "Fonts\\DFHeiMd.ttf", 0.008, 0)
        call JNFrameSetTextAlignment(QuestText2[i], JN_TEXT_JUSTIFY_MIDDLE, JN_TEXT_JUSTIFY_CENTER)
        call DzFrameSetText( QuestText2[i], "퀘스트설명" )
    endfunction

    private function Main takes nothing returns nothing
        local real x = 0.70
        local real y = 0.37
        
        set QuestMain = DzCreateFrameByTagName("GLUETEXTBUTTON", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetAbsolutePoint(QuestMain, 4, 0.78, 0.405)
        call DzFrameSetSize(QuestMain, 0.020, 0.020)
        call DzFrameSetScriptByCode(QuestMain, JN_FRAMEEVENT_MOUSE_UP, function Show, false)

        set QuestMainBD=DzCreateFrameByTagName("BACKDROP", "", QuestMain, "template", FrameCount())
        call DzFrameSetTexture(QuestMainBD, "UI_M.blp", 0)
        call DzFrameSetSize(QuestMainBD, 0.020, 0.020)
        call DzFrameSetAbsolutePoint(QuestMainBD, 4, 0.78, 0.405)

        call QuestFrame(0, x, y)
        set y = y - 0.055
        call QuestFrame(1, x, y)
        set y = y - 0.055
        call QuestFrame(2, x, y)

        call DzFrameShow(Quest[0], false)
        call DzFrameShow(Quest[1], false)
        call DzFrameShow(Quest[2], false)
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
		local integer index
        call TriggerRegisterTimerEventSingle( t, 0.05 )
        call TriggerAddAction( t, function Main )

		set index = 0
		loop
			set Quest_OnOff[index] = false
			set index = index + 1
		exitwhen index == 6
		endloop

        set t = null
    endfunction

endlibrary
