

function GetUISimpleConsole takes nothing returns integer
    if pGameUI != 0 then
        return JNMemoryGetInteger(pGameUI + 0x428)
    endif

    return 0
endfunction

function SetConsoleRaceUI takes string name returns nothing
    local string ConsoleTexture01 = "UI\\Console\\" + name + "\\" + name + "UITile01.blp"
    local string ConsoleTexture02 = "UI\\Console\\" + name + "\\" + name + "UITile02.blp"
    local string ConsoleTexture03 = "UI\\Console\\" + name + "\\" + name + "UITile03.blp"
    local string ConsoleTexture04 = "UI\\Console\\" + name + "\\" + name + "UITile04.blp"
    local string InventoryCoverFile = "UI\\Console\\" + name + "\\" + name + "UITile-InventoryCover.blp"
    local string TimeOfDayIndicatorFile = "UI\\Console\\" + name + "\\" + name + "UI-TimeIndicator.mdl"
    local string UpperMenuButtonTexture = "UI\\Widgets\\Console\\" + name + "\\" + name + "-console-buttonstates2.blp"
    local string CursorFile = "UI\\Cursor\\" + name + "Cursor.mdl"

    call SetCSimpleTextureTexture(GetSimpleConsoleTextureByIndex(0), ConsoleTexture01, false)
    call SetCSimpleTextureTexture(GetSimpleConsoleTextureByIndex(1), ConsoleTexture02, false)
    call SetCSimpleTextureTexture(GetSimpleConsoleTextureByIndex(2), ConsoleTexture02, false)
    call SetCSimpleTextureTexture(GetSimpleConsoleTextureByIndex(3), ConsoleTexture03, false)
    call SetCSimpleTextureTexture(GetSimpleConsoleTextureByIndex(4), ConsoleTexture04, false)
    call SetCSimpleTextureTexture(GetSimpleConsoleTextureByIndex(5), ConsoleTexture01, false)
    call SetCSimpleTextureTexture(GetSimpleConsoleTextureByIndex(6), ConsoleTexture02, false)
    call SetCSimpleTextureTexture(GetSimpleConsoleTextureByIndex(7), ConsoleTexture03, false)
    call SetCSimpleTextureTexture(GetSimpleConsoleTextureByIndex(8), ConsoleTexture04, false)
    call SetTimeOfDayIndicatorModel(TimeOfDayIndicatorFile)
    call SetCSimpleTextureTexture(GetInventoryCoverTexture(), InventoryCoverFile, false)
endfunction
//Human

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









