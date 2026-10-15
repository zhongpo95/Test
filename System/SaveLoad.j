// 서버 저장 요청과 완료 상태 및 재시도 대기열을 관리한다.
library PlayerSave initializer onInit requires UIItem, JNStashNet, ArcanaSaveConfig, ArcanaStashNet

    globals
        trigger DOWNLOAD_CALLBACK = CreateTrigger( )
        trigger UPLOAD_CALLBACK = CreateTrigger( )
        
        stash array PLAYER_DATA
        boolean array PLAYER_DATA_SERVER_READY
        boolean array PLAYER_DATA_UPLOAD_BUSY
        private boolean array SaveQueued
        // 0 미요청, 1 저장 중, 2 저장 완료, 3 실패, 4 서버 로드 미완료.
        integer array PlayerSaveStatus
        private trigger SAVE_REQUEST_CALLBACK = CreateTrigger()
        // Arcana 판 저장 시점(2026-10-15 사용자 지정): 게임 시작 로드, 원정 종료 저장, 마을에서 -save(게임당 2회),
        // 강화·승급·카드 부여(재료 사용) 저장. 영웅 선택·도감 획득 때의 즉시 저장은 하지 않는다(멀티_끊김_조사 13절).
        constant integer ARCANA_MANUAL_SAVE_LIMIT = 2
        integer array ARCANA_MANUAL_SAVE_USED
        // 재료 사용 저장: 장착 동기화(StatsSet 의 "장착")가 새 장비를 반영한 뒤 저장한다. 장착이 오지 않으면 대기 시간 뒤 저장한다.
        constant real ARCANA_MATERIAL_SAVE_FALLBACK = 3.0
        boolean array ARCANA_MATERIAL_SAVE_PENDING
        timer array ARCANA_MATERIAL_SAVE_TIMER
        trigger ARCANA_EQUIP_SAVE_HOOK = null
        integer ARCANA_EQUIP_SAVE_PID = -1
    endglobals

    // 단계 5-3. ARCANA_SAVE_BACKEND(ArcanaSaveConfig)가 참이면 JNStashNet 대신 ArcanaStashNet 을 쓴다. 거짓 판은 아래 static if 의 else 쪽이 원래 코드 그대로다.
    // Arcana 판의 PLAYER_DATA_SERVER_READY 는 로드 성공(상태 1·2)에만 참이 되고, 충돌·임대 상실·결과 불명(4·5·6)은 READY 를 유지한 채 어댑터가 저장만 막는다(06 11.1).

    // Arcana 판에서 어댑터가 저장을 막은 상태면 소유자에게 이유를 보여 주고 참을 돌려준다. JN 판에서는 항상 거짓이다. 동기 경로에서 부른다.
    private function ArcanaSaveBlockedNotice takes integer pid returns boolean
        local integer st
        static if ARCANA_SAVE_BACKEND then
            set st = ArcanaStashNetGetState(pid)
            if st == ARCANA_STASH_CONFLICT then
                call DisplayTimedTextToPlayer(Player(pid), 0, 0, 15, "다른 곳에 더 최신 저장이 있어 이 게임의 저장이 막혔습니다. 다시 접속하면 최신 데이터를 불러옵니다.")
                return true
            elseif st == ARCANA_STASH_LEASE_LOST then
                call DisplayTimedTextToPlayer(Player(pid), 0, 0, 15, "다른 게임에서 같은 계정으로 접속했습니다. 이 게임의 이후 진행은 저장되지 않습니다.")
                return true
            elseif st == ARCANA_STASH_RESULT_UNKNOWN then
                call DisplayTimedTextToPlayer(Player(pid), 0, 0, 15, "저장 결과를 확인하지 못했습니다. 다시 접속해야 저장할 수 있습니다.")
                return true
            endif
        endif
        return false
    endfunction

    private function IsValidPickHeroNumber takes integer heroNumber returns boolean
        return heroNumber >= 1
    endfunction

    private function SaveEquippedItems takes integer pid, integer heroNumber returns nothing
        local integer i = 0
        loop
            if Eitem[pid][i] == null or Eitem[pid][i] == "" then
                call StashSave(PLAYER_DATA[pid], "영웅"+I2S(heroNumber)+".E"+I2S(i), "0")
            else
                call StashSave(PLAYER_DATA[pid], "영웅"+I2S(heroNumber)+".E"+I2S(i), Eitem[pid][i])
            endif
            exitwhen i == EQUIP_SLOT_MAX
            set i = i + 1
        endloop
    endfunction

    private function downloadCallback takes nothing returns nothing
        static if ARCANA_SAVE_BACKEND then
        // 어댑터는 완료 때만 이벤트를 내고 신규 계정도 빈 Stash 성공으로 낸다. JNObjectMapInit 은 소비자가 없어 부르지 않는다(06 15절).
        local player user = ArcanaStashNetGetPlayer()
        local integer pid = GetPlayerId(user)
        local integer j = 0
        local string str = null
        if ArcanaStashNetGetFinished( ) then
            if ArcanaStashNetGetResult( ) then
                set PLAYER_DATA[pid] = ArcanaStashNetGetStash( )
                set PLAYER_DATA_SERVER_READY[pid] = true
                // 로그인 뒤 로드가 끝났다: 그 플레이어 화면에 영웅 선택 창을 연다(UIPick)
                set ARCANA_PICK_SHOW_PID = pid
                call TriggerExecute(ARCANA_PICK_SHOW)
                //빅휠 카운트
                set str = StashLoad(PLAYER_DATA[pid], "BigWheelCount", "0" )
                set j = 0
                loop
                    set str = StashLoad(PLAYER_DATA[pid], "창고"+I2S(j), "없음")
                    if str != "없음" and str != null then
                        call AddStItem(pid,j, str)
                        set str = null
                    endif
                    set j = j + 1
                exitwhen j == 100
                endloop
            else
                // 로드 실패를 성공으로 바꾸지 않는다. 빈 Stash 는 화면용이고 READY 가 거짓이라 어떤 경로로도 저장되지 않는다.
                set PLAYER_DATA_SERVER_READY[pid] = false
                set PLAYER_DATA[pid] = CreateStash()
                // 로그인을 풀어 입력칸을 다시 연다(다시 로그인하면 다시 불러온다)
                set ARCANA_LOGIN_DONE[pid] = false
                call DisplayTimedTextToPlayer(user, 0, 0, 20, "서버 데이터를 불러오지 못했습니다. 다시 로그인하세요. (" + ArcanaStashNetGetMessage( ) + ")")
            endif
        endif
        set user = null
        else
        local player user = JNStashNetGetPlayer()
        local integer pid
        local integer j = 0
        local string str = null
        
        if JNStashNetGetFinished( ) then
            if JNStashNetGetResult( ) then
                set pid = GetPlayerId(user)
                set PLAYER_DATA[pid] = JNStashNetGetStash( )
                set PLAYER_DATA_SERVER_READY[pid] = true
                call JNObjectMapInit(MapName,MapApi)
                
                //빅휠 카운트
                set str = StashLoad(PLAYER_DATA[pid], "BigWheelCount", "0" )
                set j = 0
                loop
                    set str = StashLoad(PLAYER_DATA[pid], "창고"+I2S(j), "없음")
                    if str != "없음" and str != null then
                        call AddStItem(pid,j, str)
                        set str = null
                    else
                    endif
                    set j = j + 1
                exitwhen j == 100
                endloop
                
                
            else
                set pid =GetPlayerId(user)
                set PLAYER_DATA_SERVER_READY[pid] = false
                set PLAYER_DATA[pid] = CreateStash()
            /*
                set pid = 0
                set PLAYER_DATA[pid] = CreateStash()
                set pid = 1
                set PLAYER_DATA[pid] = CreateStash()
                set pid = 2
                set PLAYER_DATA[pid] = CreateStash()
                set pid = 3
                set PLAYER_DATA[pid] = CreateStash()
                */
            endif
        else
            //call VJDebugMsg( "로드 중 : " + I2S(JNStashNetGetProgress()) + "/" + I2S(JNStashNetGetMaximum()) )
        endif
        endif
    endfunction
    
    private function uploadCallback takes nothing returns nothing
        static if ARCANA_SAVE_BACKEND then
        if ArcanaStashNetGetFinished( ) then
            if ArcanaStashNetGetResult( ) then
                call VJDebugMsg( "저장 성공!" )
            else
                call VJDebugMsg( "저장 실패! 이유 : " + ArcanaStashNetGetMessage( ) )
            endif
        endif
        else
        if JNStashNetGetFinished( ) then
            if JNStashNetGetResult( ) then
                call VJDebugMsg( "저장 성공!" )
            else
                call VJDebugMsg( "저장 실패! 이유 : " + JNStashNetGetMessage( ) )
            endif
        else
            //call VJDebugMsg( JNStashNetGetMessage( ) )
        endif
        endif
    endfunction


    function RequestPlayerSave takes integer pid returns boolean
        if not PLAYER_DATA_SERVER_READY[pid] or not IsValidPickHeroNumber(PlayerSlotNumber[pid]) then
            set PlayerSaveStatus[pid] = 4
            return false
        endif
        if PLAYER_DATA_UPLOAD_BUSY[pid] then
            set SaveQueued[pid] = true
            return true
        endif
        call SaveEquippedItems(pid, PlayerSlotNumber[pid])
        set SaveQueued[pid] = false
        set PLAYER_DATA_UPLOAD_BUSY[pid] = true
        set PlayerSaveStatus[pid] = 1
        static if ARCANA_SAVE_BACKEND then
            // 어댑터는 상태 1·2 이고 진행 중 작업이 없을 때만 받는다. 충돌·임대 상실·결과 불명이면 여기서 막힌다.
            if not ArcanaStashNetUploadUser(Player(pid), PLAYER_DATA[pid], SAVE_REQUEST_CALLBACK) then
                set PLAYER_DATA_UPLOAD_BUSY[pid] = false
                set PlayerSaveStatus[pid] = 3
                call ArcanaSaveBlockedNotice(pid)
                return false
            endif
        else
            if not JNStashNetUploadUser(Player(pid), MapName, GetPlayerName(Player(pid)), MapApi, PLAYER_DATA[pid], SAVE_REQUEST_CALLBACK) then
                set PLAYER_DATA_UPLOAD_BUSY[pid] = false
                set PlayerSaveStatus[pid] = 3
                return false
            endif
        endif
        return true
    endfunction

    // 재료 사용 저장 대기분을 내보낸다(동기 경로).
    function ArcanaSaveFlushMaterial takes integer pid, string why returns nothing
        if pid >= 0 and pid < bj_MAX_PLAYERS and ARCANA_MATERIAL_SAVE_PENDING[pid] then
            set ARCANA_MATERIAL_SAVE_PENDING[pid] = false
            // 장착 동기화로 저장했으면 대기 시간 저장은 취소한다(강화 한 번에 저장 한 번)
            if ARCANA_MATERIAL_SAVE_TIMER[pid] != null then
                call PauseTimer(ARCANA_MATERIAL_SAVE_TIMER[pid])
            endif
            call JNWriteLog("[ARC-SAVE] request why=" + why + " pid=" + I2S(pid))
            call RequestPlayerSave(pid)
        endif
    endfunction

    function ArcanaSaveMaterialFire takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local integer pid = 0
        loop
            exitwhen pid >= bj_MAX_PLAYERS
            if ARCANA_MATERIAL_SAVE_TIMER[pid] == t then
                call ArcanaSaveFlushMaterial(pid, "material-timer")
            endif
            set pid = pid + 1
        endloop
        set t = null
    endfunction

    function ArcanaSaveEquipHook takes nothing returns boolean
        call ArcanaSaveFlushMaterial(ARCANA_EQUIP_SAVE_PID, "material-equip")
        return false
    endfunction

    // 강화·승급·카드 부여 처리(동기 수신부) 끝에서 부른다. 재료 소비는 소유자 로컬에서 끝났고, 장비 변경은 뒤따르는 "장착" 동기화로 온다.
    function ArcanaSaveAfterMaterialUse takes integer pid returns nothing
        if pid < 0 or pid >= bj_MAX_PLAYERS then
            return
        endif
        call JNWriteLog("[ARC-SAVE] material use pid=" + I2S(pid) + " pending=" + I2S(IntegerTertiaryOp(ARCANA_MATERIAL_SAVE_PENDING[pid], 1, 0)))
        set ARCANA_MATERIAL_SAVE_PENDING[pid] = true
        if ARCANA_MATERIAL_SAVE_TIMER[pid] == null then
            set ARCANA_MATERIAL_SAVE_TIMER[pid] = CreateTimer()
        endif
        call TimerStart(ARCANA_MATERIAL_SAVE_TIMER[pid], ARCANA_MATERIAL_SAVE_FALLBACK, false, function ArcanaSaveMaterialFire)
    endfunction

    private function upload takes nothing returns nothing
        local integer pid = GetPlayerId(GetTriggerPlayer())
        local integer heroNumber = PlayerSlotNumber[pid]
        static if ARCANA_SAVE_BACKEND then
        // -save 는 마을에서만, 게임당 ARCANA_MANUAL_SAVE_LIMIT 회. 원정 중에는 원정 종료 때 저장된다.
        if ExpMember[pid] or MainUnit[pid] == null or not RectContainsUnit(gg_rct_Home, MainUnit[pid]) then
            call DisplayTimedTextToPlayer(Player(pid), 0, 0, 6, "-save 는 마을에서만 할 수 있습니다. 원정은 끝날 때 저장됩니다.")
            return
        endif
        if ARCANA_MANUAL_SAVE_USED[pid] >= ARCANA_MANUAL_SAVE_LIMIT then
            call DisplayTimedTextToPlayer(Player(pid), 0, 0, 6, "이번 게임의 -save 횟수(" + I2S(ARCANA_MANUAL_SAVE_LIMIT) + "회)를 모두 사용했습니다.")
            return
        endif
        call JNWriteLog("[ARC-SAVE] request why=manual pid=" + I2S(pid))
        if RequestPlayerSave(pid) then
            set ARCANA_MANUAL_SAVE_USED[pid] = ARCANA_MANUAL_SAVE_USED[pid] + 1
            call DisplayTimedTextToPlayer(Player(pid), 0, 0, 6, "저장을 요청했습니다. (이번 게임 " + I2S(ARCANA_MANUAL_SAVE_USED[pid]) + "/" + I2S(ARCANA_MANUAL_SAVE_LIMIT) + "회)")
        endif
        return
        endif
        /*
        if JNGetConnectionState() == 1280266064 then
            call BJDebugMsg("현재 싱글 플레이중입니다.")
        elseif JNGetConnectionState() == 1413697614 then
            call BJDebugMsg("현재 LAN에서 중입니다.")
        elseif JNGetConnectionState() == 1112425812 then
            call BJDebugMsg("현재 배틀넷에서 플레이중입니다.")
        */
        call RequestPlayerSave(pid)
    endfunction

    private function requestedSaveFinished takes nothing returns nothing
        static if ARCANA_SAVE_BACKEND then
        local integer pid = GetPlayerId(ArcanaStashNetGetPlayer())
        if not ArcanaStashNetGetFinished() then
            return
        endif
        set PLAYER_DATA_UPLOAD_BUSY[pid] = false
        call JNWriteLog("[ARC-SAVE] finished pid=" + I2S(pid) + " ok=" + I2S(IntegerTertiaryOp(ArcanaStashNetGetResult(), 1, 0)) + " queued=" + I2S(IntegerTertiaryOp(SaveQueued[pid], 1, 0)) + " rev=" + I2S(ArcanaStashNetGetRevision(pid)))
        if ArcanaStashNetGetResult() then
            set PlayerSaveStatus[pid] = 2
            call DisplayTimedTextToPlayer(Player(pid), 0, 0, 5, "|cff40ff40저장 완료|r")
            if SaveQueued[pid] then
                call JNWriteLog("[ARC-SAVE] request why=queued pid=" + I2S(pid))
                call RequestPlayerSave(pid)
            endif
        else
            set PlayerSaveStatus[pid] = 3
            // 충돌·임대 상실·결과 불명은 다시 저장해도 막히므로 그 이유를 보여 준다. 그 밖의 실패(예: 로드 불가 거절)는 데이터가 그대로라 기존 문구를 쓴다.
            if not ArcanaSaveBlockedNotice(pid) then
                call DisplayTimedTextToPlayer(Player(pid), 0, 0, 10, "저장 실패. -save로 같은 데이터를 다시 저장할 수 있습니다.")
            endif
        endif
        else
        local integer pid = GetPlayerId(JNStashNetGetPlayer())
        if not JNStashNetGetFinished() then
            return
        endif
        set PLAYER_DATA_UPLOAD_BUSY[pid] = false
        if JNStashNetGetResult() then
            set PlayerSaveStatus[pid] = 2
            if SaveQueued[pid] then
                call RequestPlayerSave(pid)
            endif
        else
            set PlayerSaveStatus[pid] = 3
            call DisplayTimedTextToPlayer(Player(pid), 0, 0, 10, "저장 실패. -save로 같은 데이터를 다시 저장할 수 있습니다.")
        endif
        endif
    endfunction

    private function download takes nothing returns nothing
        local integer i = 0
        local integer j = 0
        
        loop
            if GetPlayerController(Player(i)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
                static if ARCANA_SAVE_BACKEND then
                    // 로그인한 뒤에 불러온다(ArcanaSaveLogin → ArcanaSaveLoginLoad). 그 전에는 화면용 빈 Stash, READY 거짓(저장 안 됨).
                    // 모든 클라이언트에서 같은 순서로 만든다.
                    set PLAYER_DATA_SERVER_READY[i] = false
                    set PLAYER_DATA[i] = CreateStash()
                else
                    call JNStashNetDownloadUser( Player(i), MapName, GetPlayerName(Player(i)), MapApi, DOWNLOAD_CALLBACK )
                endif
                set j = 0
                loop
                    set Eitem[i][j] = null
                    set j = j + 1
                exitwhen j > EQUIP_SLOT_MAX
                endloop
            endif
            set i = i + 1
        exitwhen i == bj_MAX_PLAYERS
        endloop
    endfunction
    
    // Arcana 판: 로그인 성공(동기) 뒤 그 플레이어 데이터를 불러온다. 이미 불러왔으면(READY) 다시 불러오지 않는다.
    function ArcanaSaveLoginLoad takes nothing returns nothing
        local integer pid = ARCANA_LOGIN_OK_PID
        if pid < 0 or pid >= bj_MAX_PLAYERS or PLAYER_DATA_SERVER_READY[pid] then
            return
        endif
        if not ArcanaStashNetDownloadUser(Player(pid), DOWNLOAD_CALLBACK) then
            call JNWriteLog("[ARC-SAVE] login load refused (busy) pid=" + I2S(pid))
        endif
    endfunction

    private function onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer index = 0
        
        call TriggerRegisterTimerEventSingle( t, 3.00 )
        call TriggerAddAction( t, function download )
        
        set t = CreateTrigger()
        
        loop
            set PlayerName[index] = GetPlayerName(Player(index))
            call TriggerRegisterPlayerChatEvent(t, Player(index), "-save", false)
            set index = index + 1
            exitwhen index == bj_MAX_PLAYERS
        endloop
        call TriggerAddAction(t, function upload)
        
        call TriggerAddAction( DOWNLOAD_CALLBACK, function downloadCallback )
        call TriggerAddAction( UPLOAD_CALLBACK, function uploadCallback )
        call TriggerAddAction(SAVE_REQUEST_CALLBACK, function requestedSaveFinished)
        static if ARCANA_SAVE_BACKEND then
            call TriggerAddAction(ARCANA_LOGIN_OK, function ArcanaSaveLoginLoad)
            set ARCANA_EQUIP_SAVE_HOOK = CreateTrigger()
            call TriggerAddCondition(ARCANA_EQUIP_SAVE_HOOK, Condition(function ArcanaSaveEquipHook))
        endif
        
        set t = null
    endfunction

endlibrary
