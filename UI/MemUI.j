
library MemUI initializer Init requires optional Typecast

    globals
        private integer pGameDll
        private integer pGameUI

        private integer array BuffIndicator
    endglobals

    function GetGameUI2 takes integer bInit, integer bRelease returns integer
        local integer addr = pGameDll + 0x3A0B70

        call SaveStr(JNProc_ht, JNProc_key, 0, "(II)I")
        call SaveInteger(JNProc_ht, JNProc_key, 1, bInit)        
        call SaveInteger(JNProc_ht, JNProc_key, 2, bRelease)
        if JNProcCall(JNProc__fastcall, addr, JNProc_ht) then
            return LoadInteger(JNProc_ht, JNProc_key, 0)
        endif

        return 0
    endfunction
    
    function IsFrameLayout takes integer pFrame returns boolean
        local integer addr
        if pFrame != 0 then
            set addr = JNMemoryGetInteger(JNMemoryGetInteger(pFrame) + 0x1C)
            return addr == ( pGameDll + 0x13F170 ) or addr == ( pGameDll + 0x1428A0 )
        endif
 
        return false
    endfunction

    function GetFrameLayout takes integer pFrame returns integer
        if pFrame != 0 then
            if not IsFrameLayout(pFrame) then
                return pFrame + 0xB4 // if 1.29+ 0xBC
            else
                return pFrame
            endif
        endif

        return 0
    endfunction

    // unknown
    function GetTooltip takes nothing returns integer
        local integer pData

        if pGameUI != 0 then
            return JNMemoryGetInteger(pGameUI + 0x1C8)
        endif
        
        return 0
    endfunction
    // = 
    function GetUberTooltip takes nothing returns integer
        local integer pData

        if pGameUI != 0 then
            return JNMemoryGetInteger(pGameUI + 0x1CC)
        endif
        
        return 0
    endfunction

    // buttonType: 0 = left lick; 1 = right click
    function ClickCSimpleButton takes integer pFrame, integer buttonType returns integer
        local integer addr = pGameDll + 0x13D7F0

        if pFrame != 0 then
            call SaveStr(JNProc_ht, JNProc_key, 0, "(II)I")
            call SaveInteger(JNProc_ht, JNProc_key, 1, pFrame)        
            call SaveInteger(JNProc_ht, JNProc_key, 2, buttonType)
            if JNProcCall(JNProc__thiscall, addr, JNProc_ht) then
                return LoadInteger(JNProc_ht, JNProc_key, 0)
            endif
        endif

        return 0
    endfunction
    function ClickCControl takes integer pFrame, integer buttonType returns integer
        local integer addr = pGameDll + 0x1407B0

        if pFrame != 0 then
            call SaveStr(JNProc_ht, JNProc_key, 0, "(II)I")
            call SaveInteger(JNProc_ht, JNProc_key, 1, pFrame)        
            call SaveInteger(JNProc_ht, JNProc_key, 2, buttonType)
            if JNProcCall(JNProc__thiscall, addr, JNProc_ht) then
                return LoadInteger(JNProc_ht, JNProc_key, 0)
            endif
        endif

        return 0
    endfunction

    // = DzFrameGetPortrait
    function GetPortraitButton takes nothing returns integer
        local integer pData

        if pGameUI != 0 then
            return JNMemoryGetInteger(pGameUI + 0x3F4)
        endif
        
        return 0
    endfunction

    // SimpleFontString
    function GetPortraitButtonHPText takes nothing returns integer
        local integer pData = GetPortraitButton()

        if pData != 0 then
            return JNMemoryGetInteger(pData + 0x240)
        endif
        
        return 0
    endfunction
    // SimpleFontString
    function GetPortraitButtonManaText takes nothing returns integer
        local integer pData = GetPortraitButton()

        if pData != 0 then
            return JNMemoryGetInteger(pData + 0x244)
        endif
        
        return 0
    endfunction

    static if LIBRARY_Typecast then
        private function ObjectToUnit takes integer pUnit returns unit
            local integer addr  = pGameDll + 0x96F2E0
    
            if pUnit > 0 then
                call SaveStr(JNProc_ht, JNProc_key, 0, "(I)I")
                call SaveInteger(JNProc_ht, JNProc_key, 1, pUnit)
                if JNProcCall(JNProc__fastcall, addr, JNProc_ht) then
                    set pUnit = LoadInteger(JNProc_ht, JNProc_key, 0)
                endif
                if pUnit > 0x100000 then
                    return I2U( pUnit )
                endif
            endif
    
            return null
        endfunction
        
        // This function is asynchronous.
        function GetPortraitButtonUnit takes nothing returns unit
            local integer pData = GetPortraitButton()

            if pData != 0 then
                return ObjectToUnit(JNMemoryGetInteger(pData + 0x238))
            endif
            
            return null
        endfunction
    endif
    // This function is asynchronous.
    function GetPortraitButtonUnitId takes nothing returns integer
        local integer pData = GetPortraitButton()

        if pData != 0 then
            return JNMemoryGetInteger(pGameUI + 0x23C)
        endif
        
        return 0
    endfunction

    function GetInfoBar takes nothing returns integer
        local integer pData

        if pGameUI != 0 then
            return JNMemoryGetInteger(pGameUI + 0x3C4)
        endif
        
        return 0
    endfunction
    function GetInfoPanelUnitDetail takes nothing returns integer
        local integer pData = GetInfoBar()

        if pData != 0 then
            return JNMemoryGetInteger(pData + 0x130)
        endif

        return 0
    endfunction
    
    function GetBuffBarFrame takes nothing returns integer
        local integer pData = GetInfoPanelUnitDetail()

        if pData != 0 then
            return JNMemoryGetInteger(pData + 0x16C) // CBuffBar
        endif

        return 0
    endfunction
    // CSimpleFontString
    function GetBuffBarText takes nothing returns integer
        local integer pData = GetBuffBarFrame()

        if pData != 0 then
            return JNMemoryGetInteger(pData + 0x15C)
        endif

        return 0
    endfunction

    // index 0 ~ 7
    function GetBuffIndicator takes integer index returns integer
        local integer pData
        local integer j

        if index >= 0 and index <= 7 then
            if BuffIndicator[index] == 0 then
                set j     = 0
                set pData = GetBuffBarFrame()
                if pData > 0 then
                    set pData = JNMemoryGetInteger(pData + 0x120)
                    if pData >= 0 then
                        loop
                            exitwhen j >= index
                            set pData = JNMemoryGetInteger(pData + 0x4)
                            if pData <= 0 then
                                return 0
                            endif
                            set j = j + 1
                        endloop
                        if pData > 0 then
                            set BuffIndicator[index] = JNMemoryGetInteger(pData + 0x8)
                        endif
                    endif
                endif
            endif

            return BuffIndicator[index]
        endif
        return 0
    endfunction
    function GetBuffIndicatorId takes integer index returns integer
        if index >= 0 and index <= 7 then
            if BuffIndicator[index] != 0 then
                return JNMemoryGetInteger(BuffIndicator[index] + 0x134)
            else
                return JNMemoryGetInteger(GetBuffIndicator(index) + 0x134)
            endif
        endif
        return 0
    endfunction
    
    function GetUISimpleConsole takes nothing returns integer
        if pGameUI != 0 then
            return JNMemoryGetInteger(pGameUI + 0x428)
        endif

        return 0
    endfunction
    function GetUIPeonBar takes nothing returns integer
        if pGameUI != 0 then
            return JNMemoryGetInteger(pGameUI + 0x3E0)
        endif

        return 0
    endfunction
    function GetIdlePeonButton takes nothing returns integer           
        local integer pData = GetUIPeonBar()
           
        if pData != 0 then
            return JNMemoryGetInteger(pData + 0x134)
        endif

        return 0
    endfunction
    function GetSimpleConsoleTextureByIndex takes integer index returns integer
        local integer pData = GetUISimpleConsole()
        local integer j = 0

        if pData == 0 then
            return 0
        endif

        if index >= 0 and index <= 8 then
            set pData = JNMemoryGetInteger(pData + 0xD8)
            if pData >= 0 then
                loop
                    exitwhen j >= index
                    set pData = JNMemoryGetInteger(pData + 0x4)
                    if pData <= 0 then
                        return 0
                    endif
                    set j = j + 1
                endloop
                if pData > 0 then
                    return JNMemoryGetInteger(pData + 0x8) // CSimpleTexture
                endif
            endif
        endif
        return 0
    endfunction
    function GetUIInfoBar takes nothing returns integer
        if pGameUI != 0 then
            return JNMemoryGetInteger(pGameUI + 0x3C4)
        endif

        return 0
    endfunction
    function GetInventoryCoverTexture takes nothing returns integer
        local integer pData = JNMemoryGetInteger(GetUIInfoBar() + 0x14C)
        if pData > 0 then

            set pData = JNMemoryGetInteger(pData + 0x40)
            if pData > 0 then
                return JNMemoryGetInteger(pData + 0x0C) // CSimpleTexture
            endif
        endif
       
        return 0
    endfunction
    
    // state:
    // 0 == DISABLE 
    // 1 == ENABLE
    // 2 == PUSHAED
    function SetCSimpleButtonStateTexture takes integer pButton, integer state, string texturepath returns boolean
        local integer addr = pGameDll + 0x13DCD0

        if addr != 0 and pButton != 0 then
            call SaveStr(JNProc_ht, JNProc_key, 0, "(IIS)I")
            call SaveInteger(JNProc_ht, JNProc_key, 1, pButton)        
            call SaveInteger(JNProc_ht, JNProc_key, 2, state)
            call SaveStr(JNProc_ht, JNProc_key, 3, texturepath)
            if JNProcCall(JNProc__thiscall, addr, JNProc_ht) then
                return LoadInteger(JNProc_ht, JNProc_key, 0) > 0
            endif
        endif

        return false
    endfunction
    function SetSpriteModeal takes integer pFrame, string model, integer modeltype, boolean flag returns integer
        local integer addr

        if pFrame != 0 then
            set addr = JNMemoryGetInteger(JNMemoryGetInteger(pFrame) + 0xE8)
            if addr != 0 then
            
                call SaveStr(JNProc_ht, JNProc_key, 0, "(ISIB)I")
                call SaveInteger(JNProc_ht, JNProc_key, 1, pFrame)        
                call SaveStr(JNProc_ht, JNProc_key, 2, model)
                call SaveInteger(JNProc_ht, JNProc_key, 3, modeltype)
                call SaveBoolean(JNProc_ht, JNProc_key, 4, flag)
                if JNProcCall(JNProc__thiscall, addr, JNProc_ht) then
                    return LoadInteger(JNProc_ht, JNProc_key, 0)
                endif
                
            endif
        endif

        return 0
    endfunction
    function SetSpriteFrameScale takes integer pFrame, real scale returns integer
        local integer addr = pGameDll + 0x125D70
        
        if addr != 0 and pFrame != 0 then
        
            call SaveStr(JNProc_ht, JNProc_key, 0, "(IR)I")
            call SaveInteger(JNProc_ht, JNProc_key, 1, pFrame)        
            call SaveReal(JNProc_ht, JNProc_key, 2, scale)
            if JNProcCall(JNProc__thiscall, addr, JNProc_ht) then
                return LoadInteger(JNProc_ht, JNProc_key, 0)
            endif
            
        endif

        return 0
    endfunction
    
    function GetUITimeOfDayIndicator takes nothing returns integer
        if pGameUI != 0 then
            return JNMemoryGetInteger(pGameUI + 0x3F8)
        endif

        return 0
    endfunction
    function GetTimeOfDayIndicatorSpriteUber takes nothing returns integer
        local integer pData = GetUITimeOfDayIndicator()

        if pData != 0 then
            return JNMemoryGetInteger(JNMemoryGetInteger(pData + 0x178))
        endif

        return 0
    endfunction
    function SetTimeOfDayIndicatorModel takes string model returns integer
        local integer pData = GetUITimeOfDayIndicator()
        local integer addr1 = pGameDll + 0x1DF320
        local integer addr2 = pGameDll + 0x4076F0
        local integer spriteUber
        
        call SetSpriteModeal(pData, model, 0xFFFFFFFF, false)
        set spriteUber = GetTimeOfDayIndicatorSpriteUber()

        call SaveStr(JNProc_ht, JNProc_key, 0, "(IIIII)I")
        call SaveInteger(JNProc_ht, JNProc_key, 1, spriteUber)        
        call SaveInteger(JNProc_ht, JNProc_key, 2, 0)
        call SaveInteger(JNProc_ht, JNProc_key, 3, addr2)
        call SaveInteger(JNProc_ht, JNProc_key, 4, pData)
        call SaveInteger(JNProc_ht, JNProc_key, 5, 1)
        if JNProcCall(JNProc__fastcall, addr1, JNProc_ht) then
            return LoadInteger(JNProc_ht, JNProc_key, 0)
        endif
        
        return 0
    endfunction
    
    function SetCLayoutFrameAbsolutePoint takes integer pFrame, integer point, real offsetX, real offsetY returns integer
        local integer addr = pGameDll + 0x13FBB0

        if pFrame != 0 then
            call SaveStr(JNProc_ht, JNProc_key, 0, "(IIRRI)I")
            call SaveInteger(JNProc_ht, JNProc_key, 1, pFrame)        
            call SaveInteger(JNProc_ht, JNProc_key, 2, point)
            call SaveReal(JNProc_ht, JNProc_key, 3, (offsetX))
            call SaveReal(JNProc_ht, JNProc_key, 4, (offsetY))
            call SaveInteger(JNProc_ht, JNProc_key, 5, 1)
            if JNProcCall(JNProc__thiscall, addr, JNProc_ht) then
                return LoadInteger(JNProc_ht, JNProc_key, 0)
            endif
        endif

        return 0
    endfunction
    function SetCLayoutFramePoint takes integer pFrame, integer point, integer pParentFrame, integer relativePoint, real x, real y returns integer
        local integer addr = pGameDll + 0x13FC20

        if pFrame != 0 then
            call SaveStr(JNProc_ht, JNProc_key, 0, "(IIIIRR)I")
            call SaveInteger(JNProc_ht, JNProc_key, 1, pFrame)        
            call SaveInteger(JNProc_ht, JNProc_key, 2, point)
            call SaveInteger(JNProc_ht, JNProc_key, 3, pParentFrame)
            call SaveInteger(JNProc_ht, JNProc_key, 4, relativePoint)
            call SaveReal(JNProc_ht, JNProc_key, 5, x)
            call SaveReal(JNProc_ht, JNProc_key, 6, y)
            call SaveInteger(JNProc_ht, JNProc_key, 7, 1)
            if JNProcCall(JNProc__thiscall, addr, JNProc_ht) then
                return LoadInteger(JNProc_ht, JNProc_key, 0)
            endif
        endif

        return 0
    endfunction

    function ClearCLayoutFrameAllPoints takes integer pFrame returns integer
        local integer addr = pGameDll + 0x13EE90

        if addr != 0 and pFrame != 0 then
            call SaveStr(JNProc_ht, JNProc_key, 0, "(II)I")
            call SaveInteger(JNProc_ht, JNProc_key, 1, pFrame)        
            call SaveInteger(JNProc_ht, JNProc_key, 2, 1)
            if JNProcCall(JNProc__thiscall, addr, JNProc_ht) then
                return LoadInteger(JNProc_ht, JNProc_key, 0)
            endif
        endif

        return 0
    endfunction

    function ClearSimpleFontsAllPoints takes integer pFrame returns integer
        local integer addr = pGameDll + 0x13F9B0

        if addr != 0 and pFrame != 0 then
            call SaveStr(JNProc_ht, JNProc_key, 0, "(II)I")
            call SaveInteger(JNProc_ht, JNProc_key, 1, pFrame)        
            call SaveInteger(JNProc_ht, JNProc_key, 2, 0)
            if JNProcCall(JNProc__thiscall, addr, JNProc_ht) then
                return LoadInteger(JNProc_ht, JNProc_key, 0)
            endif
        endif

        return 0
    endfunction

    function SetCLayoutFrameWidth takes integer pFrame, real width returns integer
        local integer addr = pGameDll + 0x13FCE0
        local integer fid = 0

        if addr != 0 and pFrame != 0 then
            call SaveStr(JNProc_ht, JNProc_key, 0, "(IR)I")
            call SaveInteger(JNProc_ht, JNProc_key, 1, pFrame)        
            call SaveReal(JNProc_ht, JNProc_key, 2, width)
            if JNProcCall(JNProc__thiscall, addr, JNProc_ht) then
                return LoadInteger(JNProc_ht, JNProc_key, 0)
            endif
        endif

        return 0
    endfunction
    function SetCLayoutFrameHeight takes integer pFrame, real height returns integer
        local integer addr = pGameDll + 0x13FB40
        local integer fid = 0

        if addr != 0 and pFrame != 0 then
            call SaveStr(JNProc_ht, JNProc_key, 0, "(IR)I")
            call SaveInteger(JNProc_ht, JNProc_key, 1, pFrame)        
            call SaveReal(JNProc_ht, JNProc_key, 2, height)
            if JNProcCall(JNProc__thiscall, addr, JNProc_ht) then
                return LoadInteger(JNProc_ht, JNProc_key, 0)
            endif
        endif

        return 0
    endfunction
    function SetCLayoutFrameSize takes integer pFrame, real width, real height returns integer
        if pFrame != 0 then
            call SetCLayoutFrameWidth(pFrame, width)
            call SetCLayoutFrameHeight(pFrame, height)
            return 1
        endif

        return 0
    endfunction
    
    function SetCSimpleTextureTexture takes integer pFrame, string texturepath, boolean flag returns integer
        local integer addr = pGameDll + 0x1435F0
        
        if addr != 0 and pFrame != 0 then
        
            call SaveStr(JNProc_ht, JNProc_key, 0, "(ISB)I")
            call SaveInteger(JNProc_ht, JNProc_key, 1, pFrame)        
            call SaveStr(JNProc_ht, JNProc_key, 2, texturepath)
            call SaveBoolean(JNProc_ht, JNProc_key, 3, false)     
            if JNProcCall(JNProc__thiscall, addr, JNProc_ht) then
                return LoadInteger(JNProc_ht, JNProc_key, 0)
            endif
        endif

        return 0
    endfunction

    function SetFrameAbsolutePoint takes integer pFrame, integer point, real offsetX, real offsetY returns integer
        if pFrame != 0 then
            return SetCLayoutFrameAbsolutePoint( GetFrameLayout(pFrame), point, offsetX, offsetY )
        endif

        return 0
    endfunction
    function SetFramePoint takes integer pFrame, integer point, integer pParentFrame, integer relativePoint, real x, real y returns integer
        if pFrame > 0 and pParentFrame > 0 then
            return SetCLayoutFramePoint( GetFrameLayout(pFrame), point, GetFrameLayout(pParentFrame), relativePoint, x, y )
        endif

        return 0
    endfunction

    function ClearFrameAllPoints takes integer pFrame returns integer
        return ClearCLayoutFrameAllPoints( GetFrameLayout(pFrame) )
    endfunction
    function SetFrameSize takes integer pFrame, real width, real height returns integer
        return SetCLayoutFrameSize( GetFrameLayout(pFrame), width, height )
    endfunction
    
    function SetConsoleRaceUI takes nothing returns nothing
        local string ConsoleTexture01 = "MyUITile01.blp"//"UI\\Console\\" + name + "\\" + name + "UITile01.blp"
        local string ConsoleTexture02 = "MyUITile02.blp"//"UI\\Console\\" + name + "\\" + name + "UITile02.blp"
        local string ConsoleTexture03 = "MyUITile03.blp" //"File00005271.blp" //"UI\\Console\\" + name + "\\" + name + "UITile03.blp"
        local string ConsoleTexture04 = "Empty.blp"  //"UI\\Console\\" + name + "\\" + name + "UITile04.blp"
        local string InventoryCoverFile = "Empty.blp"//"UI\\Console\\" + name + "\\" + name + "UITile-InventoryCover.blp"
        local string TimeOfDayIndicatorFile = "Empty.blp"//"UI\\Console\\" + name + "\\" + name + "UI-TimeIndicator.mdl"
        local string UpperMenuButtonTexture = "Empty.blp"//"UI\\Widgets\\Console\\" + name + "\\" + name + "-console-buttonstates2.blp"
        local string CursorFile = "Empty.blp"//"UI\\Cursor\\" + name + "Cursor.mdl"
        local integer frame
        local integer frame2
        
        call SetCSimpleTextureTexture(GetSimpleConsoleTextureByIndex(5), ConsoleTexture01, false)
        call SetCSimpleTextureTexture(GetSimpleConsoleTextureByIndex(6), ConsoleTexture02, false)
        call SetCSimpleTextureTexture(GetSimpleConsoleTextureByIndex(7), ConsoleTexture03, false)
        call SetTimeOfDayIndicatorModel(TimeOfDayIndicatorFile)
        call SetCSimpleTextureTexture(GetInventoryCoverTexture(), InventoryCoverFile, false)
        call ClearFrameAllPoints(GetSimpleConsoleTextureByIndex(5))
        call ClearFrameAllPoints(GetSimpleConsoleTextureByIndex(6))
        call ClearFrameAllPoints(GetSimpleConsoleTextureByIndex(7))
        call DzFrameShow(GetSimpleConsoleTextureByIndex(5),true)
        call DzFrameShow(GetSimpleConsoleTextureByIndex(6),true)
        call DzFrameShow(GetSimpleConsoleTextureByIndex(7),true)
    
        call DzFrameHideInterface()
        call DzFrameEditBlackBorders(0, 0)
        
        set frame=DzFrameGetMinimap()
        call DzFrameClearAllPoints(frame)
        call DzFrameSetPoint(frame, JN_FRAMEPOINT_BOTTOMLEFT, DzGetGameUI(), JN_FRAMEPOINT_BOTTOMLEFT, 0.015,0.015)
        call DzFrameSetPoint(frame, JN_FRAMEPOINT_TOPRIGHT, DzGetGameUI(), JN_FRAMEPOINT_BOTTOMLEFT, 0.145,0.14)
        call DzFrameShow(frame,true)
    endfunction
    
    private function BtnIconConversionDisabledIcon takes string s returns string
        return "ReplaceableTextures\\CommandButtonsDisabled\\DIS" + SubString(s, 35, StringLength(s))
    endfunction
    function SetIdlePeonButtonTexture takes string peonIconFile returns nothing
        call SetCSimpleButtonStateTexture(GetIdlePeonButton(), 1, peonIconFile)
        call SetCSimpleButtonStateTexture(GetIdlePeonButton(), 0, BtnIconConversionDisabledIcon(peonIconFile))
    endfunction

    private function Main takes nothing returns nothing
        call SetConsoleRaceUI()
    endfunction
    //인터페이스를 숨기기전에 인터페이스를 교체해놔야함
    //스킬아이콘 위치이동은 DzFrameEditBlackBorders(0,0) 이후에 세션에서 해야함
    private function Init takes nothing returns nothing
        local integer frame
        local trigger t = CreateTrigger()
        set pGameDll = JNGetModuleHandle("Game.dll")
        set pGameUI  = GetGameUI2(0, 0)
        set frame = DzFrameGetMinimap()
        call DzFrameClearAllPoints(frame)
        call DzFrameSetPoint(frame, JN_FRAMEPOINT_BOTTOMLEFT, DzGetGameUI(), JN_FRAMEPOINT_BOTTOMLEFT, 0.015,0.015)
        call DzFrameSetPoint(frame, JN_FRAMEPOINT_TOPRIGHT, DzGetGameUI(), JN_FRAMEPOINT_BOTTOMLEFT, 0.145,0.14)

        call TriggerRegisterTimerEventSingle( t, 0.15 )
        call TriggerAddAction( t, function Main )
        set t = null
    endfunction
endlibrary
