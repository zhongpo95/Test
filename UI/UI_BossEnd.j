library UIBossEnd initializer init requires TriggerSleepActionByTimer, DataMap
    globals
        private integer Failed
        private integer Success
        private integer RewardBD
        integer array RewardItemBD
    endglobals
    
    private struct Reward
        static string array RewardItem
        static integer i = 0
        integer j = 0
        integer pid = 0
    endstruct
    
    private function RewardReset takes integer j returns nothing
        local integer i = 1
        local Reward st = j
        set st.i = 0
        loop
            set st.RewardItem[i] = ""
            call DzFrameSetTexture(RewardItemBD[i], "UI_Inventory.blp", 0)
            exitwhen i == 20
            set i = i + 1
        endloop
    endfunction
            
    private function FailedFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        
        if Player(t.data) == GetLocalPlayer() then
            call DzFrameShow(Failed, false)
            call SetCameraBoundsToRectForPlayerBJ( GetLocalPlayer(), gg_rct_Home )
            call SetCameraPositionForPlayer(GetLocalPlayer(),GetRectCenterX(gg_rct_Home),GetRectCenterY(gg_rct_Home))
            call ClearSelection()
            call SelectUnit(MainUnit[t.data], true)
        endif
        
        call ReviveHero(MainUnit[t.data],GetRectCenterX(gg_rct_Home),GetRectCenterY(gg_rct_Home),true)
        
        call t.destroy()
    endfunction
    
    private function SuccessFunction2 takes nothing returns nothing
        local tick t = tick.getExpired()
        
        call SetUnitPosition(MainUnit[t.data],GetRectCenterX(gg_rct_Home),GetRectCenterY(gg_rct_Home))
        
        if Player(t.data) == GetLocalPlayer() then
            call DzFrameShow(Success, false)
            call SetCameraBoundsToRectForPlayerBJ( GetLocalPlayer(), gg_rct_Home )
            call SetCameraPositionForPlayer(GetLocalPlayer(),GetRectCenterX(gg_rct_Home),GetRectCenterY(gg_rct_Home))
            call ClearSelection()
            call SelectUnit(MainUnit[t.data], true)
        endif
        
        call t.destroy()
    endfunction
    
    private function SuccessFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        
        if Player(t.data) == GetLocalPlayer() then
            call DzFrameShow(Success, true)
        endif
        
        call t.start( 5.0, false, function SuccessFunction2 ) 
    endfunction
    
    private function RewardFunction3 takes nothing returns nothing
        local tick t = tick.getExpired()
        call DzDestroyFrame(t.data)
        set t.data = 0
        call t.destroy()
    endfunction
    
    private function RewardFunction2 takes nothing returns nothing
        local tick t = tick.getExpired()
        local Reward st = t.data
        local integer Effect
        local tick t2
            
        set st.j = st.j + 1
        
        if st.j == 22 then
            if Player(st.pid) == GetLocalPlayer() then
                call DzFrameShow(RewardBD, false)
                call RewardReset(t.data)
            endif
            set st.j = 0
            call t.destroy()
        elseif st.j == 21 then
            call t.start( 1.2, false, function RewardFunction2 )
        else
            if Player(st.pid) == GetLocalPlayer() then
                if st.RewardItem[st.j] != null and st.RewardItem[st.j] != "" and st.RewardItem[st.j] != "0" then
                    call DzFrameSetTexture(RewardItemBD[st.j], GetItemArt(st.RewardItem[st.j]), 0)
                    call additem(Player(st.pid), st.RewardItem[st.j])
                endif
            endif
            
            set Effect=DzCreateFrameByTagName("SPRITE", "", RewardItemBD[st.j], "template", 0)
            call DzFrameSetPoint(Effect, JN_FRAMEPOINT_CENTER, RewardItemBD[st.j] , JN_FRAMEPOINT_CENTER, 0.0110, 0.0090)
            call DzFrameSetModel(Effect, "f6102.mdx", 0, 0)
            call DzFrameSetSize(Effect, 0.02, 0.02)
            call DzFrameShow(Effect, false)
            set t2 = tick.create(Effect)
            call t2.start( 1.2, false, function RewardFunction3 )
            
            if Player(st.pid) == GetLocalPlayer() then
                if st.RewardItem[st.j] != null and st.RewardItem[st.j] != "" and st.RewardItem[st.j] != "0" then
                    call DzFrameShow(Effect, true)
                endif
            endif
            call t.start( 0.20, false, function RewardFunction2 )
        endif
    endfunction
    
    function AddReward takes player p, string items returns nothing
        local Reward st = Reward.create()
        
        if GetLocalPlayer() == p then
            set st.i = st.i + 1
            set st.RewardItem[st.i] = items
        endif
        
        call st.destroy()
    endfunction
    
    //ren 10000 = 100%  ren 100 = 1%
    function AddRandomReward takes player p, string items, integer ren returns nothing
        local Reward st
        //((100 + Equip_Drop[GetPlayerId(p)]) / 100)
        if ren * ((100 + Equip_Drop[GetPlayerId(p)]) / 100) >= GetRandomInt(1,10000) then
            set st = Reward.create()
            if GetLocalPlayer() == p then
                set st.i = st.i + 1
                set st.RewardItem[st.i] = items
            endif
            call st.destroy()
        endif
    endfunction
    
    private function RewardFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local Reward st = t.data
        
        if Player(st.pid) == GetLocalPlayer() then
            call DzFrameShow(RewardBD, true)
        endif
        
        call t.start( 0.20, false, function RewardFunction2 ) 
    endfunction
    
    function FailedStart takes unit caster returns nothing
        local tick t = tick.create(GetPlayerId(GetOwningPlayer(caster)))
        
        if Player(t.data) == GetLocalPlayer() then
            call DzFrameShow(Failed, true)
            call StartSound(gg_snd_Failed)
        endif
        
        call t.start( 10.0, false, function FailedFunction ) 
    endfunction
    function SuccessStart takes unit caster returns nothing
        local tick t = tick.create(GetPlayerId(GetOwningPlayer(caster)))
        
        if Player(t.data) == GetLocalPlayer() then
            call StartSound(gg_snd_Clear)
        endif
        
        call t.start( 1.0, false, function SuccessFunction ) 
    endfunction
    function RewardStart takes unit caster returns nothing
        local tick t = tick.create(0)
        local Reward st = Reward.create()
        set st.j = 0
        set st.pid = GetPlayerId(GetOwningPlayer(caster))
        set t.data = st
        call t.start( 5.0, false, function RewardFunction ) 
    endfunction
    
    private function BossMapReset2 takes nothing returns nothing
        local tick t = tick.getExpired()
        local Reward st = t.data
        call MapReset(st.j,st.pid)
        call t.destroy()
        call st.destroy()
    endfunction

    function BossMapReset takes integer i, integer j returns nothing
        local tick t = tick.create(0)
        local Reward st = Reward.create()
        set st.j = i
        set st.pid = j
        set t.data = st
        call t.start( 5.0, false, function BossMapReset2 ) 
    endfunction

    private function Main takes nothing returns nothing
        local integer i = 0
        set Failed=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", 0)
        call DzFrameSetPoint(Failed, 0, DzGetGameUI(), 6, ( 318.00 / 1280.00 ), ( 480.00 / 1280.00 ))
        call DzFrameSetSize(Failed, ( 388.00 / 1280.00 ), ( 100.00 / 1280.00 ))
        call DzFrameSetTexture(Failed, "UI_Failed.blp", 0)
        call DzFrameShow(Failed, false)
        set Success=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", 0)
        call DzFrameSetPoint(Success, 0, DzGetGameUI(), 6, ( 318.00 / 1280.00 ), ( 480.00 / 1280.00 ))
        call DzFrameSetSize(Success, ( 388.00 / 1280.00 ), ( 100.00 / 1280.00 ))
        call DzFrameSetTexture(Success, "UI_Success.blp", 0)
        call DzFrameShow(Success, false)
        set RewardBD=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", 0)
        call DzFrameSetAbsolutePoint(RewardBD, JN_FRAMEPOINT_CENTER, 0.4, 0.3)
        call DzFrameSetSize(RewardBD, 0.25, 0.25)
        call DzFrameSetTexture(RewardBD, "UI_PickSelectButton.tga", 0)
        
        set i = 1
        loop
            set RewardItemBD[i]=DzCreateFrameByTagName("BACKDROP", "", RewardBD, "", 0)
            call DzFrameSetAbsolutePoint(RewardItemBD[i], JN_FRAMEPOINT_CENTER, 0.330+(0.035*(i-1)), 0.34)
            call DzFrameSetSize(RewardItemBD[i], 0.035, 0.035)
            call DzFrameSetTexture(RewardItemBD[i], "UI_Inventory.blp", 0)
            set RewardItemBD[i+5]=DzCreateFrameByTagName("BACKDROP", "", RewardBD, "", 0)
            call DzFrameSetAbsolutePoint(RewardItemBD[i+5], JN_FRAMEPOINT_CENTER, 0.330+(0.035*(i-1)), 0.34-0.035)
            call DzFrameSetSize(RewardItemBD[i+5], 0.035, 0.035)
            call DzFrameSetTexture(RewardItemBD[i+5], "UI_Inventory.blp", 0)
            set RewardItemBD[i+10]=DzCreateFrameByTagName("BACKDROP", "", RewardBD, "", 0)
            call DzFrameSetAbsolutePoint(RewardItemBD[i+10], JN_FRAMEPOINT_CENTER, 0.330+(0.035*(i-1)), 0.34-0.070)
            call DzFrameSetSize(RewardItemBD[i+10], 0.035, 0.035)
            call DzFrameSetTexture(RewardItemBD[i+10], "UI_Inventory.blp", 0)
            set RewardItemBD[i+15]=DzCreateFrameByTagName("BACKDROP", "", RewardBD, "", 0)
            call DzFrameSetAbsolutePoint(RewardItemBD[i+15], JN_FRAMEPOINT_CENTER, 0.330+(0.035*(i-1)), 0.34-0.105)
            call DzFrameSetSize(RewardItemBD[i+15], 0.035, 0.035)
            call DzFrameSetTexture(RewardItemBD[i+15], "UI_Inventory.blp", 0)
            exitwhen i == 5
            set i = i + 1
        endloop
            
        call DzFrameShow(RewardBD, false)
    endfunction
            
    private function init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer index
        
        call TriggerRegisterTimerEventSingle( t, 0.10 )
        call TriggerAddAction( t, function Main )
    endfunction
    endlibrary
    