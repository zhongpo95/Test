library UIAchievement initializer init requires DataUnit, FrameCount

    
    private function Main takes nothing returns nothing
        local string s
        local integer i
        
        set FS_BackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "StandardEditBoxBackdropTemplate", 0)
        call DzFrameSetAbsolutePoint(FS_BackDrop, JN_FRAMEPOINT_CENTER, 0.40, 0.30)
        call DzFrameSetSize(FS_BackDrop, 0.50, 0.39)
        
        //메뉴 배경
        set F_InfoBackDrop2=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetTexture(F_InfoBackDrop2, "File00005255.blp", 0)
        call DzFrameSetAbsolutePoint(F_InfoBackDrop2, JN_FRAMEPOINT_CENTER, 0.225, 0.315)
        call DzFrameSetSize(F_InfoBackDrop2, 0.40, 0.43)

        call DzFrameShow(FS_BackDrop, false)
    endfunction
    
    private function Command takes nothing returns nothing
        local integer pid = GetPlayerId(GetTriggerPlayer())
        if OverlayShow[pid] == false then
            if GetLocalPlayer() == GetTriggerPlayer() then
                call DzFrameShow(Overlay_BackDrop,true)
            endif
            set OverlayShow[pid] = true
        elseif OverlayShow[pid] == true then
            if GetLocalPlayer() == GetTriggerPlayer() then
                call DzFrameShow(Overlay_BackDrop,false)
            endif
            set OverlayShow[pid] = false
        endif
    endfunction
    
    private function init takes nothing returns nothing
        local trigger t=CreateTrigger()
        local integer index
        
        set t = CreateTrigger()
        call TriggerAddAction( t, function Main )
        call TriggerRegisterTimerEvent(t, 0.10, false)
        
        set t = CreateTrigger()
        loop
            exitwhen i > 4
            call TriggerRegisterPlayerChatEvent( t, Player(i), "-업적", false )
            set OverlayShow[i] = false
            set i = i + 1
        endloop
        call TriggerAddAction( t, function Command )
        set t = null
        
    endfunction
endlibrary