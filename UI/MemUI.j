// 참고 맵 방식의 네이티브 HUD 제거 및 필수 프레임 복원
library MemUI initializer Init
    globals
        private integer pGameDll
        private integer pGameUI
    endglobals

    private function GetGameUI2 takes integer bInit, integer bRelease returns integer
        local integer addr = pGameDll + 0x3A0B70
        call SaveStr(JNProc_ht, JNProc_key, 0, "(II)I")
        call SaveInteger(JNProc_ht, JNProc_key, 1, bInit)
        call SaveInteger(JNProc_ht, JNProc_key, 2, bRelease)
        if JNProcCall(JNProc__fastcall, addr, JNProc_ht) then
            return LoadInteger(JNProc_ht, JNProc_key, 0)
        endif
        return 0
    endfunction

    private function IsFrameLayout takes integer frame returns boolean
        local integer addr
        if frame != 0 then
            set addr = JNMemoryGetInteger(JNMemoryGetInteger(frame) + 0x1C)
            return addr == pGameDll + 0x13F170 or addr == pGameDll + 0x1428A0
        endif
        return false
    endfunction

    function GetFrameLayout takes integer frame returns integer
        if frame != 0 then
            if not IsFrameLayout(frame) then
                return frame + 0xB4
            endif
            return frame
        endif
        return 0
    endfunction

    function GetUISimpleConsole takes nothing returns integer
        if pGameUI != 0 then
            return JNMemoryGetInteger(pGameUI + 0x428)
        endif
        return 0
    endfunction

    private function GetUIPeonBar takes nothing returns integer
        if pGameUI != 0 then
            return JNMemoryGetInteger(pGameUI + 0x3E0)
        endif
        return 0
    endfunction

    function GetIdlePeonButton takes nothing returns integer
        local integer peonBar = GetUIPeonBar()
        if peonBar != 0 then
            return JNMemoryGetInteger(peonBar + 0x134)
        endif
        return 0
    endfunction

    private function SetCLayoutFrameAbsolutePoint takes integer frame, integer point, real x, real y returns integer
        local integer addr = pGameDll + 0x13FBB0
        if frame != 0 then
            call SaveStr(JNProc_ht, JNProc_key, 0, "(IIRRI)I")
            call SaveInteger(JNProc_ht, JNProc_key, 1, frame)
            call SaveInteger(JNProc_ht, JNProc_key, 2, point)
            call SaveReal(JNProc_ht, JNProc_key, 3, x)
            call SaveReal(JNProc_ht, JNProc_key, 4, y)
            call SaveInteger(JNProc_ht, JNProc_key, 5, 1)
            if JNProcCall(JNProc__thiscall, addr, JNProc_ht) then
                return LoadInteger(JNProc_ht, JNProc_key, 0)
            endif
        endif
        return 0
    endfunction

    function ClearCLayoutFrameAllPoints takes integer frame returns integer
        local integer addr = pGameDll + 0x13EE90
        if frame != 0 then
            call SaveStr(JNProc_ht, JNProc_key, 0, "(II)I")
            call SaveInteger(JNProc_ht, JNProc_key, 1, frame)
            call SaveInteger(JNProc_ht, JNProc_key, 2, 1)
            if JNProcCall(JNProc__thiscall, addr, JNProc_ht) then
                return LoadInteger(JNProc_ht, JNProc_key, 0)
            endif
        endif
        return 0
    endfunction

    function SetFrameAbsolutePoint takes integer frame, integer point, real x, real y returns integer
        return SetCLayoutFrameAbsolutePoint(GetFrameLayout(frame), point, x, y)
    endfunction

    private function HideNativeFrame takes integer frame returns nothing
        if frame != 0 then
            call DzFrameClearAllPoints(frame)
            call DzFrameSetAbsolutePoint(frame, JN_FRAMEPOINT_TOPLEFT, 2.0, 2.0)
            call DzFrameSetSize(frame, 0.001, 0.001)
            call DzFrameShow(frame, false)
        endif
    endfunction

    private function ConfigureHUD takes nothing returns nothing
        local integer frame = GetUISimpleConsole()
        local integer index = 0
        call DestroyTimer(GetExpiredTimer())

        if frame != 0 then
            call ClearCLayoutFrameAllPoints(GetFrameLayout(frame))
            call SetFrameAbsolutePoint(frame, 1, 2.0, 2.0)
        endif

        loop
            exitwhen index >= 5
            call HideNativeFrame(DzFrameGetMinimapButton(index))
            set index = index + 1
        endloop
        call HideNativeFrame(GetIdlePeonButton())

        set frame = DzFrameGetMinimap()
        if frame != 0 then
            call DzFrameShow(frame, true)
            call DzFrameClearAllPoints(frame)
            call DzFrameSetPoint(frame, JN_FRAMEPOINT_BOTTOMLEFT, DzGetGameUI(), JN_FRAMEPOINT_BOTTOMLEFT, 0.015, 0.015)
            call DzFrameSetPoint(frame, JN_FRAMEPOINT_TOPRIGHT, DzGetGameUI(), JN_FRAMEPOINT_BOTTOMLEFT, 0.145, 0.140)
        endif
    endfunction

    private function Init takes nothing returns nothing
        set pGameDll = JNGetModuleHandle("Game.dll")
        set pGameUI = GetGameUI2(0, 0)
        call DzFrameHideInterface()
        call DzFrameEditBlackBorders(0.0, 0.0)
        call TimerStart(CreateTimer(), 0.0, false, function ConfigureHUD)
    endfunction
endlibrary
