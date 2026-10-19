library UIOverlay initializer init requires UnitIndexer, DataUnit, FrameCount, Sort, UIInputGate
    globals
        boolean array OverlayShow
        integer Overlay_BackDrop
        integer array OverlayBar
        integer array OverlayText
        integer array OverlayValue
        integer array OverlayAv
        integer OverlayTimer
        integer OverlayTitle
        integer array OverlayRow
        integer array OverlayLine
        integer array OverlayLabel
        constant string METER_PANEL_TEX = "war3mapImported\\HUD_MeterPanel.tga"
        constant string METER_PANEL_L_TEX = "war3mapImported\\HUD_MeterPanelL.tga"
        constant string METER_TRACK_TEX = "war3mapImported\\HUD_MeterTrack.tga"
        constant string METER_LINE_TEX = "war3mapImported\\HUD_MeterLine.tga"
        constant string METER_BAR_TEX = "war3mapImported\\HUD_MeterBar.tga"
        constant real METER_ROW_W = 0.184
        constant real METER_ROW_H = 0.0190
        integer array OverlayTimerValue
        integer OverlayDamage
        integer array OverlayDamageValue
        integer OverlayDPS
        integer array OverlayDPSValue
        real array OverlayPlayerValue
        integer array OverlayPlayerID
        boolean array PlayerOverlayStop
        integer array OverlayTime

        boolean array Overlay2_InfoOnOff
        integer Overlay2_BackDrop
        integer Overlay2_ImageText
        integer array Overlay2_Bar
        //프레임
        //스킬이름
        integer array Overlay2_SkillName
        //스킬 총 피해량
        integer array Overlay2_Damage
        //DPS
        integer array Overlay2_DPS
        //치명타적중률
        integer array Overlay2_Cri
        //사용횟수
        integer array Overlay2_Count
        //타격수
        integer array Overlay2_HitCount
        //피해량지분
        integer array Overlay2_share
        //값
        //스킬이름
        integer array Overlay2Velue_SkillName
        //스킬 총 피해량
        real array Overlay2Velue_Damage
        //DPS
        real array Overlay2Velue_DPS
        //치명타적중횟수
        integer array Overlay2Velue_Cri
        //사용횟수
        integer array Overlay2Velue_Count
        //타격수
        integer array Overlay2Velue_HitCount
        //피해량지분
        real array Overlay2Velue_share

        integer Overlay2_NoShow
        integer Overlay2_Shade
        integer Overlay2_Title
        integer Overlay2_Hint
        // 마을 허수아비 측정 중인지, 갱신 타이머가 돌고 있는지
        boolean array OverlayTown
        boolean array OverlayTickA
        boolean array OverlayTickB

        hashtable OverlayData = InitHashtable()
    endglobals

    //pid,스킬,피해량,크리
    //call Overlay2(pid, SkillCode,dmg,CriBoolean)
    function Overlay2 takes integer pid, integer SkillCode, real damage, boolean Cri returns nothing
        local integer i = 0
        local integer id = 0
        local boolean bool = false
        if GetLocalPlayer() == Player(pid) then
            //이미있음
            loop
                exitwhen i > 14 or bool == true
                if Overlay2Velue_SkillName[i] == SkillCode then
                    set Overlay2Velue_SkillName[i] = SkillCode
                    debug call VJDebugMsg("있음 "+"i : "+  I2S(SkillCode) + " /ID : "+ I2S(i))
                    set id = i
                    set bool = true
                endif
                set i = i + 1
            endloop
            //없음
            if bool == false then
                set i = 0
                loop
                    exitwhen i > 14 or bool == true
                    if SkillCode != 0 and Overlay2Velue_SkillName[i] == 0 then
                        set Overlay2Velue_SkillName[i] = SkillCode
                        debug call VJDebugMsg("없음 "+"i : "+  I2S(SkillCode) + " /ID : "+ I2S(i))
                        set id = i
                        set bool = true
                    endif
                    set i = i + 1
                endloop
            endif
            
            debug call VJDebugMsg( I2S(Overlay2Velue_SkillName[0])+"/"+I2S(Overlay2Velue_SkillName[1])+"/"+I2S(Overlay2Velue_SkillName[2])+"/"+I2S(Overlay2Velue_SkillName[3]) )

            set Overlay2Velue_Damage[id] = Overlay2Velue_Damage[id] + damage
            set Overlay2Velue_HitCount[id] = Overlay2Velue_HitCount[id] + 1
            if Cri == true then
                set Overlay2Velue_Cri[id] = Overlay2Velue_Cri[id] + 1
            endif
            debug call VJDebugMsg("오버레이2 대미지값: "+ R2S(Overlay2Velue_Damage[id]))
            debug call VJDebugMsg("오버레이2 I 값: "+ I2S(id))
        endif
    endfunction
    function Overlay2Count takes integer pid, integer SkillCode returns nothing
        local integer i = 0
        local integer id = 0
        local boolean bool = false
        if GetLocalPlayer() == Player(pid) then
            //이미있음
            loop
                exitwhen i > 14 or bool == true
                if Overlay2Velue_SkillName[i] == SkillCode then
                    set Overlay2Velue_SkillName[i] = SkillCode
                    set id = i
                    set bool = true
                endif
                set i = i + 1
            endloop
            //없음
            if bool == false then
                set i = 0
                loop
                    exitwhen i > 14 or bool == true
                    if SkillCode != 0 and Overlay2Velue_SkillName[i] == 0 then
                        set Overlay2Velue_SkillName[i] = SkillCode
                        set id = i
                        set bool = true
                    endif
                    set i = i + 1
                endloop
            endif

            set Overlay2Velue_Count[id] = Overlay2Velue_Count[id] + 1
        endif
    endfunction
    function Overlay2Reset takes integer pid returns nothing
        local integer i = 0
        if GetLocalPlayer() == Player(pid) then
            loop
                exitwhen i > 14
                set Overlay2Velue_SkillName[i] = 0
                set Overlay2Velue_Damage[i] = 0
                set Overlay2Velue_DPS[i] = 0
                set Overlay2Velue_Cri[i] = 0
                set Overlay2Velue_Count[i] = 0
                set Overlay2Velue_HitCount[i] = 0
                set Overlay2Velue_share[i] = 0
                call DzFrameShow(Overlay2_Bar[i], false)
                set i = i + 1
            endloop
        endif
    endfunction


    function FormatSecondsToTime takes integer totalSeconds returns string
        local integer hours = totalSeconds / 3600
        local integer remainingSeconds = ModuloInteger(totalSeconds, 3600)
        local integer minutes = remainingSeconds / 60
        local integer seconds = ModuloInteger(remainingSeconds, 60)
        local string timeString = ""

        // 시간, 분, 초를 두 자리 숫자로 맞추기
        if hours < 10 then
            set timeString = timeString + "0" + I2S(hours)
        else
            set timeString = timeString + I2S(hours)
        endif

        set timeString = timeString + ":"

        if minutes < 10 then
            set timeString = timeString + "0" + I2S(minutes)
        else
            set timeString = timeString + I2S(minutes)
        endif

        set timeString = timeString + ":"

        if seconds < 10 then
            set timeString = timeString + "0" + I2S(seconds)
        else
            set timeString = timeString + I2S(seconds)
        endif

        return timeString
    endfunction

    // 게임에 들어와 있는 사람 슬롯인지 (빈 슬롯·나간 사람은 미터기에서 숨긴다)
    function OverlayInGame takes integer p returns boolean
        return GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(p)) == MAP_CONTROL_USER
    endfunction

    // 정렬 키: 없는 슬롯은 -1로 맨 아래로 보낸다
    function OverlaySortKey takes integer i returns real
        if OverlayInGame(OverlayPlayerID[i]) then
            return OverlayPlayerValue[i]
        endif
        return -1.0
    endfunction

    // 높은 순으로 정렬
    function CompareOverlay takes nothing returns nothing
        set Sort_isCompare = OverlaySortKey(Sort_indexA) <= OverlaySortKey(Sort_indexB)
    endfunction
    
    // 교체
    function SwapOverlay takes nothing returns nothing
        local real PlayerValue = OverlayPlayerValue[Sort_indexA]
        local integer PlayerID = OverlayPlayerID[Sort_indexA]

        set OverlayPlayerValue[Sort_indexA] = OverlayPlayerValue[Sort_indexB]
        set OverlayPlayerID[Sort_indexA] = OverlayPlayerID[Sort_indexB]
        set OverlayPlayerValue[Sort_indexB] = PlayerValue
        set OverlayPlayerID[Sort_indexB] = PlayerID
    endfunction

    private function TextChange takes string s returns string
        local integer sl = 0
        set sl = JNStringLength(s)
        //10만 미만: "12345.0" -> "12345"
        if sl <= 7 then
            if sl >= 3 and JNStringSub(s,sl-2,1) == "." then
                return JNStringSub(s,0,sl-2)
            endif
            return s
        endif
        //10조
        if sl == 16 then
            set s = JNStringSub(s,0,2) + "." + JNStringSub(s,2,2) + "조"
        //1조
        elseif sl == 15 then
            set s = JNStringSub(s,0,1) + "." + JNStringSub(s,1,2) + "조"
        //1000억
        elseif sl == 14 then
            set s = JNStringSub(s,0,4) + "." + JNStringSub(s,4,2) + "억"
        //100억
        elseif sl == 13 then
            set s = JNStringSub(s,0,3) + "." + JNStringSub(s,3,2) + "억"
        //10억
        elseif sl == 12 then
            set s = JNStringSub(s,0,2) + "." + JNStringSub(s,2,2) + "억"
        //1억
        elseif sl == 11 then
            set s = JNStringSub(s,0,1) + "." + JNStringSub(s,1,2) + "억"
        //1000만
        elseif sl == 10 then
            set s = JNStringSub(s,0,4) + "." + JNStringSub(s,4,2) + "만"
        //100만
        elseif sl == 9 then
            set s = JNStringSub(s,0,3) + "." + JNStringSub(s,3,2) + "만"
        //10만
        elseif sl == 8 then
            set s = JNStringSub(s,0,2) + "." + JNStringSub(s,2,2) + "만"
        endif

        return s
    endfunction
    
    //오버레이 갱신
    function OverlayEffect takes nothing returns nothing
        local tick t = tick.getExpired()
        local real r = 0
        local real top = 0
        local integer i = 0
        local integer i2 = -1
        local integer sec = 0

        if GetLocalPlayer() == Player(t.data) then
            call Sort_Run(0, 3, "CompareOverlay", "SwapOverlay")
            set r = OverlayPlayerValue[0] + OverlayPlayerValue[1] + OverlayPlayerValue[2] + OverlayPlayerValue[3]
            set top = OverlayPlayerValue[0]
            set sec = IMaxBJ(OverlayTime[t.data], 1)
            loop
                exitwhen i > 3
                if t.data == OverlayPlayerID[i] then
                    set i2 = i
                endif
                if OverlayInGame(OverlayPlayerID[i]) then
                    call DzFrameSetTexture(OverlayBar[i],"M_Player"+I2S(OverlayPlayerID[i]+1)+".tga",0)
                    call DzFrameSetText(OverlayText[i], GetPlayerName(Player(OverlayPlayerID[i])))
                    call DzFrameSetText(OverlayValue[i], TextChange(R2SW(OverlayPlayerValue[i],1,1)))
                    if top > 0 then
                        call DzFrameSetSize(OverlayBar[i], RMaxBJ(0.002, METER_ROW_W * (OverlayPlayerValue[i]/top)), METER_ROW_H)
                    else
                        call DzFrameSetSize(OverlayBar[i], 0.002, METER_ROW_H)
                    endif
                    if r > 0 then
                        call DzFrameSetText(OverlayAv[i], "|cffd2e1f5"+R2SW((OverlayPlayerValue[i] / r) * 100 ,1,1) + "%|r" )
                    else
                        call DzFrameSetText(OverlayAv[i], "|cffd2e1f50.0%|r")
                    endif
                    call DzFrameShow(OverlayRow[i], true)
                else
                    call DzFrameShow(OverlayRow[i], false)
                endif
                set i = i + 1
            endloop
            call DzFrameSetText(OverlayTimer, "|cff96c8ff"+FormatSecondsToTime(OverlayTime[t.data])+"|r")
            if i2 >= 0 then
                call DzFrameSetText(OverlayDamage, "|cffffe68c"+TextChange(R2SW(OverlayPlayerValue[i2],1,1))+"|r")
                call DzFrameSetText(OverlayDPS, "|cffffe68c"+TextChange(R2SW(OverlayPlayerValue[i2]/sec,1,1))+"|r")
            endif
        endif
        if PlayerOverlayStop[t.data] == true then
            set OverlayTickA[t.data] = false
            call t.destroy()
        endif

    endfunction

    function OverlayTimeCheck takes nothing returns nothing
        local tick t = tick.getExpired()

        if PlayerOverlayStop[t.data] == true then
            set OverlayTickB[t.data] = false
            call t.destroy()
            return
        endif
        set OverlayTime[t.data] = OverlayTime[t.data] + 1
    endfunction

    function Overlay takes integer pid returns nothing
        local integer i = 0
        local tick t
        local tick t2

        set PlayerOverlayStop[pid] = false
        set OverlayTown[pid] = false
        set OverlayTime[pid] = 0

        call Overlay2Reset(pid)

        if GetLocalPlayer() == Player(pid) then
            call DzFrameShow(Overlay2_NoShow, true)
            call DzFrameSetText(Overlay2_Title, "|cffdcecff스킬별 피해|r")
            loop
                exitwhen i > 3
                set OverlayPlayerValue[i] = 0
                set OverlayPlayerID[i] = i
                call DzFrameSetSize(OverlayBar[i], 0.002, METER_ROW_H)
                call DzFrameSetText(OverlayValue[i], "0")
                call DzFrameSetText(OverlayAv[i], "|cffd2e1f50.0%|r")
                call DzFrameShow(OverlayRow[i], OverlayInGame(i))
                set i = i + 1
            endloop
            call DzFrameSetText(OverlayDamage, "|cffffe68c0|r")
            call DzFrameSetText(OverlayDPS, "|cffffe68c0|r")
        endif

        // 이미 돌고 있는 갱신 타이머는 그대로 쓴다 (허수아비 측정 중 보스전이 시작돼도 시간이 두 배로 가지 않게)
        if not OverlayTickA[pid] then
            set OverlayTickA[pid] = true
            set t = tick.create(pid)
            call t.start( 0.05, true, function OverlayEffect )
        endif
        if not OverlayTickB[pid] then
            set OverlayTickB[pid] = true
            set t2 = tick.create(pid)
            call t2.start( 1.00, true, function OverlayTimeCheck )
        endif
    endfunction

    // 높은 순으로 정렬
    function CompareOverlay2 takes nothing returns nothing
        set Sort_isCompare = Overlay2Velue_Damage[Sort_indexA] <= Overlay2Velue_Damage[Sort_indexB]
    endfunction

    // 교체
    function SwapOverlay2 takes nothing returns nothing
        local integer ASkillName = Overlay2Velue_SkillName[Sort_indexA]
        local real ADamage = Overlay2Velue_Damage[Sort_indexA]
        local integer ACri = Overlay2Velue_Cri[Sort_indexA]
        local integer ACount = Overlay2Velue_Count[Sort_indexA]
        local integer AHitCount = Overlay2Velue_HitCount[Sort_indexA]

        set Overlay2Velue_SkillName[Sort_indexA] = Overlay2Velue_SkillName[Sort_indexB]
        set Overlay2Velue_Damage[Sort_indexA] = Overlay2Velue_Damage[Sort_indexB]
        set Overlay2Velue_Cri[Sort_indexA] = Overlay2Velue_Cri[Sort_indexB]
        set Overlay2Velue_Count[Sort_indexA] = Overlay2Velue_Count[Sort_indexB]
        set Overlay2Velue_HitCount[Sort_indexA] = Overlay2Velue_HitCount[Sort_indexB]

        set Overlay2Velue_SkillName[Sort_indexB] = ASkillName
        set Overlay2Velue_Damage[Sort_indexB] = ADamage
        set Overlay2Velue_Cri[Sort_indexB] = ACri
        set Overlay2Velue_Count[Sort_indexB] = ACount
        set Overlay2Velue_HitCount[Sort_indexB] = AHitCount
    endfunction

    // 상세창(. 키) 내용을 지금까지 쌓인 값으로 그린다
    function OverlayRender takes integer pid returns nothing
        local integer i = 0
        local integer n = 0
        local string s = ""
        local real r = 0
        local string head = "스킬별 피해"

        if OverlayTown[pid] then
            set head = "허수아비 측정"
        endif
        if GetLocalPlayer() == Player(pid) then
            call DzFrameShow(Overlay2_NoShow, false)
            call Sort_Run(0, 14, "CompareOverlay2", "SwapOverlay2")
            
            set i = 0
            loop
                exitwhen i > 14
                set r = r + Overlay2Velue_Damage[i]
                set i = i + 1
            endloop
            set i = 0

            if Overlay2Velue_Damage[0] != 0 then
                call DzFrameSetTexture(Overlay2_Bar[0],METER_BAR_TEX,0)
                call DzFrameSetSize(Overlay2_Bar[0], 0.590, 0.0200)
                
                if Overlay2Velue_SkillName[0] == 1 then
                    call DzFrameSetText(Overlay2_SkillName[0], "기타") 
                elseif Overlay2Velue_SkillName[0] == 2 then
                    call DzFrameSetText(Overlay2_SkillName[0], "기본 공격") 
                else
                    call DzFrameSetText(Overlay2_SkillName[0], EXExecuteScript("(require'jass.slk').ability[" + I2S(Overlay2Velue_SkillName[i])+"].EditorSuffix"))
                endif
                
                set s = R2SW(Overlay2Velue_Damage[0],1,1)
                call DzFrameSetText(Overlay2_Damage[0], TextChange(s))
                
                set s = R2SW(Overlay2Velue_Damage[0]/IMaxBJ(OverlayTime[pid],1),1,1)
                call DzFrameSetText(Overlay2_DPS[0], TextChange(s))
                
                set s = R2SW(I2R(Overlay2Velue_Cri[0])/I2R(IMaxBJ(Overlay2Velue_HitCount[0],1)) * 100,1,1)
                call DzFrameSetText(Overlay2_Cri[0], s+"%")
                
                call DzFrameSetText(Overlay2_Count[0], I2S(Overlay2Velue_Count[0]) )

                set s = R2SW(Overlay2Velue_Damage[0]/r * 100,1,1)
                call DzFrameSetText(Overlay2_share[0], s+"%")
                
                call DzFrameShow(Overlay2_Bar[0], true)
                set n = 1
            endif
            
            set i = 1
            loop
                exitwhen i > 14
                if Overlay2Velue_Damage[i] != 0 then
                    call DzFrameSetTexture(Overlay2_Bar[i],METER_BAR_TEX,0)
                    
                    if Overlay2Velue_SkillName[i] == 1 then
                        call DzFrameSetText(Overlay2_SkillName[i], "기타") 
                    elseif Overlay2Velue_SkillName[i] == 2 then
                        call DzFrameSetText(Overlay2_SkillName[i], "기본 공격") 
                    else
                        call DzFrameSetText(Overlay2_SkillName[i], EXExecuteScript("(require'jass.slk').ability[" + I2S(Overlay2Velue_SkillName[i])+"].EditorSuffix"))
                    endif
                    //EXGetAbilityString(Overlay2_SkillName[i],1,ABILITY_DATA_TIP))
                    //EXExecuteScript("(require'jass.slk').ability[" + I2S(Overlay2_SkillName[i])+"].EditorSuffix"))
                    
                    set s = R2SW(Overlay2Velue_Damage[i],1,1)
                    call DzFrameSetText(Overlay2_Damage[i], TextChange(s))
                    
                    set s = R2SW(Overlay2Velue_Damage[i]/IMaxBJ(OverlayTime[pid],1),1,1)
                    call DzFrameSetText(Overlay2_DPS[i], TextChange(s))
                    
                    set s = R2SW(I2R(Overlay2Velue_Cri[i])/I2R(IMaxBJ(Overlay2Velue_HitCount[i],1)) * 100,1,1)
                    call DzFrameSetText(Overlay2_Cri[i], s+"%")
                    
                    call DzFrameSetText(Overlay2_Count[i], I2S(Overlay2Velue_Count[i]) )
    
                    set s = R2SW(Overlay2Velue_Damage[i]/r * 100,1,1)
                    call DzFrameSetText(Overlay2_share[i], s+"%")
                    call DzFrameSetSize(Overlay2_Bar[i], RMaxBJ(0.004, 0.590 * (Overlay2Velue_Damage[i]/ Overlay2Velue_Damage[0] )), 0.0200)
                    set n = n + 1

                    call DzFrameShow(Overlay2_Bar[i], true)
                endif
                set i = i + 1
            endloop
            set i = 0
            call DzFrameSetText(Overlay2_Title, "|cffdcecff" + head + "|r    |cff96c8ff전투 시간 " + FormatSecondsToTime(OverlayTime[pid]) + "   총 피해 " + TextChange(R2SW(r,1,1)) + "|r")
        endif
    endfunction

    function OverlayStop takes integer pid returns nothing
        set PlayerOverlayStop[pid] = true
        set OverlayTown[pid] = false
        call OverlayRender(pid)
    endfunction

    // 마을 허수아비: 1초마다 상세창을 다시 그린다 (측정은 멈추지 않고 계속 쌓는다)
    function OverlayTownTick takes nothing returns nothing
        local tick t = tick.getExpired()
        if not OverlayTown[t.data] then
            call t.destroy()
            return
        endif
        call OverlayRender(t.data)
    endfunction

    // HeroDeal에서 피해 기록 직전에 부른다. 마을 허수아비를 처음 치면 측정을 시작한다.
    function OverlaySandbagHit takes integer pid, unit target returns nothing
        local tick t
        if target == null or target != TownSandbag or pid < 0 or pid > 3 then
            return
        endif
        if OverlayTown[pid] then
            return
        endif
        // 보스전 측정 중에는 건드리지 않는다
        if PlayerOverlayStop[pid] == false and OverlayTickA[pid] then
            return
        endif
        call Overlay(pid)
        set OverlayTown[pid] = true
        set t = tick.create(pid)
        call t.start( 1.00, true, function OverlayTownTick )
    endfunction

    //private function Command2 takes nothing returns nothing
        //local string s = GetEventPlayerChatString()
        //local string temp = JNStringSplit(s, " ", 1)
        //local real a = S2R(JNStringSplit(temp, "/", 0))
        //local real b = S2R(JNStringSplit(temp, "/", 1))
        //debug call VJDebugMsg(R2S(a) + " " + R2S(b))
        //call DzFrameSetAbsolutePoint(Overlay_BackDrop, JN_FRAMEPOINT_CENTER, a, b)
    //endfunction

    /*
    function Overlay takes integer pid, integer SkillCode, real SkillDamage, boolean CriBoolean returns nothing
        local string str = LoadStr( OverlayData, pid, SkillCode )
        local real TotalDamage = S2R(JNStringSplit(temp, "/", 0))
        local real TotalHit = S2R(JNStringSplit(temp, "/", 1))
        local real TotalCriHit = S2R(JNStringSplit(temp, "/", 2))


        call SaveStr(OverlayData, pid, SkillCode, ""+"/"+"")
        //set SkillDamage 
    endfunction
    */

    private function Main2 takes nothing returns nothing
        //메뉴 배경
        set Overlay2_BackDrop=DzCreateFrameByTagName("BACKDROP", "", GetGameplayUI(), "template", FrameCount())
        call DzFrameSetTexture(Overlay2_BackDrop, METER_PANEL_L_TEX, 0)
        // 창 크기는 고정 (스킬 15줄이 다 들어가는 크기)
        call DzFrameSetAbsolutePoint(Overlay2_BackDrop, JN_FRAMEPOINT_TOP, 0.400, 0.560)
        call DzFrameSetSize(Overlay2_BackDrop, 0.650, 0.457)
        call DzFrameSetAlpha(Overlay2_BackDrop, 255)
        call DzFrameSetPriority(Overlay2_BackDrop, 5)

        // 같은 유리 판을 한 장 더 겹쳐 뒤 배경이 덜 비치게 한다
        set Overlay2_Shade=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetTexture(Overlay2_Shade, METER_PANEL_L_TEX, 0)
        call DzFrameSetPoint(Overlay2_Shade, JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0, 0)
        call DzFrameSetPoint(Overlay2_Shade, JN_FRAMEPOINT_BOTTOMRIGHT, Overlay2_BackDrop, JN_FRAMEPOINT_BOTTOMRIGHT, 0, 0)

        set Overlay2_Title=JNCreateFrameByType("TEXT","",Overlay2_BackDrop,"", FrameCount())
        call DzFrameSetSize(Overlay2_Title,0.450,0.00)
        call DzFrameSetPoint(Overlay2_Title, JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.0150)
        call DzFrameSetText(Overlay2_Title,"|cffdcecff스킬별 피해|r")
        call DzFrameSetFont(Overlay2_Title, "Fonts\\DFHeiMd.ttf", 0.0110, 0)

        set Overlay2_Hint=JNCreateFrameByType("TEXT","",Overlay2_BackDrop,"", FrameCount())
        call DzFrameSetSize(Overlay2_Hint,0.080,0.00)
        call DzFrameSetPoint(Overlay2_Hint, JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.570, -0.0170)
        call DzFrameSetText(Overlay2_Hint,"|cff7f9cc0[.] 닫기|r")
        call DzFrameSetFont(Overlay2_Hint, "Fonts\\DFHeiMd.ttf", 0.0088, 0)

        set Overlay2_ImageText=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(Overlay2_ImageText, "Overlay2.tga", 0)
        call DzFrameSetPoint(Overlay2_ImageText, JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.0360)
        call DzFrameSetSize(Overlay2_ImageText, 0.590, 0.0250)

        set Overlay2_Bar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.068)
        call DzFrameSetTexture(Overlay2_Bar[0],METER_BAR_TEX,0)
        call DzFrameSetSize(Overlay2_Bar[0], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[0], true)
        set Overlay2_SkillName[0]=JNCreateFrameByType("TEXT","",Overlay2_Bar[0],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[0],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0045)
        call DzFrameSetText(Overlay2_SkillName[0],"")
        call DzFrameSetFont(Overlay2_SkillName[0], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_SkillName[0],true)
        set Overlay2_Damage[0]=JNCreateFrameByType("TEXT","",Overlay2_Bar[0],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[0],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0045)
        call DzFrameSetText(Overlay2_Damage[0],"")
        call DzFrameSetFont(Overlay2_Damage[0], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Damage[0],true)
        set Overlay2_DPS[0]=JNCreateFrameByType("TEXT","",Overlay2_Bar[0],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[0],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0045)
        call DzFrameSetText(Overlay2_DPS[0],"")
        call DzFrameSetFont(Overlay2_DPS[0], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_DPS[0],true)
        set Overlay2_Cri[0]=JNCreateFrameByType("TEXT","",Overlay2_Bar[0],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[0],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0045)
        call DzFrameSetText(Overlay2_Cri[0],"")
        call DzFrameSetFont(Overlay2_Cri[0], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Cri[0],true)
        set Overlay2_Count[0]=JNCreateFrameByType("TEXT","",Overlay2_Bar[0],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[0],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0045)
        call DzFrameSetText(Overlay2_Count[0],"")
        call DzFrameSetFont(Overlay2_Count[0], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Count[0],true)
        set Overlay2_share[0]=JNCreateFrameByType("TEXT","",Overlay2_Bar[0],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[0],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0045)
        call DzFrameSetText(Overlay2_share[0],"")
        call DzFrameSetFont(Overlay2_share[0], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_share[0],true)


        set Overlay2_Bar[1]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[1], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.093)
        call DzFrameSetTexture(Overlay2_Bar[1],METER_BAR_TEX,0)
        call DzFrameSetSize(Overlay2_Bar[1], 0.295, 0.0200)
        call DzFrameShow(Overlay2_Bar[1], true)
        set Overlay2_SkillName[1]=JNCreateFrameByType("TEXT","",Overlay2_Bar[1],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[1],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[1], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[1], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0045)
        call DzFrameSetText(Overlay2_SkillName[1],"")
        call DzFrameSetFont(Overlay2_SkillName[1], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_SkillName[1],true)
        set Overlay2_Damage[1]=JNCreateFrameByType("TEXT","",Overlay2_Bar[1],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[1],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[1], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[1], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0045)
        call DzFrameSetText(Overlay2_Damage[1],"")
        call DzFrameSetFont(Overlay2_Damage[1], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Damage[1],true)
        set Overlay2_DPS[1]=JNCreateFrameByType("TEXT","",Overlay2_Bar[1],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[1],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[1], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[1], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0045)
        call DzFrameSetText(Overlay2_DPS[1],"")
        call DzFrameSetFont(Overlay2_DPS[1], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_DPS[1],true)
        set Overlay2_Cri[1]=JNCreateFrameByType("TEXT","",Overlay2_Bar[1],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[1],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[1], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[1], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0045)
        call DzFrameSetText(Overlay2_Cri[1],"")
        call DzFrameSetFont(Overlay2_Cri[1], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Cri[1],true)
        set Overlay2_Count[1]=JNCreateFrameByType("TEXT","",Overlay2_Bar[1],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[1],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[1], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[1], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0045)
        call DzFrameSetText(Overlay2_Count[1],"")
        call DzFrameSetFont(Overlay2_Count[1], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Count[1],true)
        set Overlay2_share[1]=JNCreateFrameByType("TEXT","",Overlay2_Bar[1],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[1],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[1], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[1], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0045)
        call DzFrameSetText(Overlay2_share[1],"")
        call DzFrameSetFont(Overlay2_share[1], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_share[1],true)

        set Overlay2_Bar[2]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[2], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.118)
        call DzFrameSetTexture(Overlay2_Bar[2],METER_BAR_TEX,0)
        call DzFrameSetSize(Overlay2_Bar[2], 0.295, 0.0200)
        call DzFrameShow(Overlay2_Bar[2], true)
        set Overlay2_SkillName[2]=JNCreateFrameByType("TEXT","",Overlay2_Bar[2],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[2],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[2], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[2], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0045)
        call DzFrameSetText(Overlay2_SkillName[2],"")
        call DzFrameSetFont(Overlay2_SkillName[2], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_SkillName[2],true)
        set Overlay2_Damage[2]=JNCreateFrameByType("TEXT","",Overlay2_Bar[2],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[2],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[2], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[2], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0045)
        call DzFrameSetText(Overlay2_Damage[2],"")
        call DzFrameSetFont(Overlay2_Damage[2], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Damage[2],true)
        set Overlay2_DPS[2]=JNCreateFrameByType("TEXT","",Overlay2_Bar[2],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[2],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[2], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[2], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0045)
        call DzFrameSetText(Overlay2_DPS[2],"")
        call DzFrameSetFont(Overlay2_DPS[2], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_DPS[2],true)
        set Overlay2_Cri[2]=JNCreateFrameByType("TEXT","",Overlay2_Bar[2],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[2],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[2], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[2], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0045)
        call DzFrameSetText(Overlay2_Cri[2],"")
        call DzFrameSetFont(Overlay2_Cri[2], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Cri[2],true)
        set Overlay2_Count[2]=JNCreateFrameByType("TEXT","",Overlay2_Bar[2],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[2],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[2], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[2], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0045)
        call DzFrameSetText(Overlay2_Count[2],"")
        call DzFrameSetFont(Overlay2_Count[2], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Count[2],true)
        set Overlay2_share[2]=JNCreateFrameByType("TEXT","",Overlay2_Bar[2],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[2],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[2], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[2], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0045)
        call DzFrameSetText(Overlay2_share[2],"")
        call DzFrameSetFont(Overlay2_share[2], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_share[2],true)

        set Overlay2_Bar[3]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[3], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.143)
        call DzFrameSetTexture(Overlay2_Bar[3],METER_BAR_TEX,0)
        call DzFrameSetSize(Overlay2_Bar[3], 0.059, 0.0200)
        call DzFrameShow(Overlay2_Bar[3], true)
        set Overlay2_SkillName[3]=JNCreateFrameByType("TEXT","",Overlay2_Bar[3],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[3],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[3], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[3], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0045)
        call DzFrameSetText(Overlay2_SkillName[3],"")
        call DzFrameSetFont(Overlay2_SkillName[3], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_SkillName[3],true)
        set Overlay2_Damage[3]=JNCreateFrameByType("TEXT","",Overlay2_Bar[3],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[3],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[3], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[3], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0045)
        call DzFrameSetText(Overlay2_Damage[3],"")
        call DzFrameSetFont(Overlay2_Damage[3], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Damage[3],true)
        set Overlay2_DPS[3]=JNCreateFrameByType("TEXT","",Overlay2_Bar[3],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[3],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[3], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[3], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0045)
        call DzFrameSetText(Overlay2_DPS[3],"")
        call DzFrameSetFont(Overlay2_DPS[3], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_DPS[3],true)
        set Overlay2_Cri[3]=JNCreateFrameByType("TEXT","",Overlay2_Bar[3],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[3],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[3], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[3], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0045)
        call DzFrameSetText(Overlay2_Cri[3],"")
        call DzFrameSetFont(Overlay2_Cri[3], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Cri[3],true)
        set Overlay2_Count[3]=JNCreateFrameByType("TEXT","",Overlay2_Bar[3],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[3],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[3], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[3], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0045)
        call DzFrameSetText(Overlay2_Count[3],"")
        call DzFrameSetFont(Overlay2_Count[3], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Count[3],true)
        set Overlay2_share[3]=JNCreateFrameByType("TEXT","",Overlay2_Bar[3],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[3],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[3], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[3], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0045)
        call DzFrameSetText(Overlay2_share[3],"")
        call DzFrameSetFont(Overlay2_share[3], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_share[3],true)

        set Overlay2_Bar[4]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[4], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.168)
        call DzFrameSetTexture(Overlay2_Bar[4],METER_BAR_TEX,0)
        call DzFrameSetSize(Overlay2_Bar[4], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[4], true)
        set Overlay2_SkillName[4]=JNCreateFrameByType("TEXT","",Overlay2_Bar[4],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[4],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[4], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[4], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0045)
        call DzFrameSetText(Overlay2_SkillName[4],"")
        call DzFrameSetFont(Overlay2_SkillName[4], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_SkillName[4],true)
        set Overlay2_Damage[4]=JNCreateFrameByType("TEXT","",Overlay2_Bar[4],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[4],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[4], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[4], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0045)
        call DzFrameSetText(Overlay2_Damage[4],"")
        call DzFrameSetFont(Overlay2_Damage[4], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Damage[4],true)
        set Overlay2_DPS[4]=JNCreateFrameByType("TEXT","",Overlay2_Bar[4],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[4],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[4], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[4], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0045)
        call DzFrameSetText(Overlay2_DPS[4],"")
        call DzFrameSetFont(Overlay2_DPS[4], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_DPS[4],true)
        set Overlay2_Cri[4]=JNCreateFrameByType("TEXT","",Overlay2_Bar[4],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[4],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[4], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[4], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0045)
        call DzFrameSetText(Overlay2_Cri[4],"")
        call DzFrameSetFont(Overlay2_Cri[4], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Cri[4],true)
        set Overlay2_Count[4]=JNCreateFrameByType("TEXT","",Overlay2_Bar[4],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[4],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[4], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[4], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0045)
        call DzFrameSetText(Overlay2_Count[4],"")
        call DzFrameSetFont(Overlay2_Count[4], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Count[4],true)
        set Overlay2_share[4]=JNCreateFrameByType("TEXT","",Overlay2_Bar[4],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[4],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[4], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[4], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0045)
        call DzFrameSetText(Overlay2_share[4],"")
        call DzFrameSetFont(Overlay2_share[4], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_share[4],true)

        set Overlay2_Bar[5]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[5], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.193)
        call DzFrameSetTexture(Overlay2_Bar[5],METER_BAR_TEX,0)
        call DzFrameSetSize(Overlay2_Bar[5], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[5], true)
        set Overlay2_SkillName[5]=JNCreateFrameByType("TEXT","",Overlay2_Bar[5],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[5],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[5], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[5], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0045)
        call DzFrameSetText(Overlay2_SkillName[5],"")
        call DzFrameSetFont(Overlay2_SkillName[5], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_SkillName[5],true)
        set Overlay2_Damage[5]=JNCreateFrameByType("TEXT","",Overlay2_Bar[5],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[5],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[5], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[5], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0045)
        call DzFrameSetText(Overlay2_Damage[5],"")
        call DzFrameSetFont(Overlay2_Damage[5], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Damage[5],true)
        set Overlay2_DPS[5]=JNCreateFrameByType("TEXT","",Overlay2_Bar[5],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[5],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[5], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[5], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0045)
        call DzFrameSetText(Overlay2_DPS[5],"")
        call DzFrameSetFont(Overlay2_DPS[5], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_DPS[5],true)
        set Overlay2_Cri[5]=JNCreateFrameByType("TEXT","",Overlay2_Bar[5],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[5],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[5], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[5], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0045)
        call DzFrameSetText(Overlay2_Cri[5],"")
        call DzFrameSetFont(Overlay2_Cri[5], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Cri[5],true)
        set Overlay2_Count[5]=JNCreateFrameByType("TEXT","",Overlay2_Bar[5],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[5],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[5], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[5], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0045)
        call DzFrameSetText(Overlay2_Count[5],"")
        call DzFrameSetFont(Overlay2_Count[5], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Count[5],true)
        set Overlay2_share[5]=JNCreateFrameByType("TEXT","",Overlay2_Bar[5],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[5],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[5], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[5], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0045)
        call DzFrameSetText(Overlay2_share[5],"")
        call DzFrameSetFont(Overlay2_share[5], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_share[5],true)

        set Overlay2_Bar[6]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[6], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.218)
        call DzFrameSetTexture(Overlay2_Bar[6],METER_BAR_TEX,0)
        call DzFrameSetSize(Overlay2_Bar[6], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[6], true)
        set Overlay2_SkillName[6]=JNCreateFrameByType("TEXT","",Overlay2_Bar[6],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[6],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[6], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[6], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0045)
        call DzFrameSetText(Overlay2_SkillName[6],"")
        call DzFrameSetFont(Overlay2_SkillName[6], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_SkillName[6],true)
        set Overlay2_Damage[6]=JNCreateFrameByType("TEXT","",Overlay2_Bar[6],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[6],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[6], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[6], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0045)
        call DzFrameSetText(Overlay2_Damage[6],"")
        call DzFrameSetFont(Overlay2_Damage[6], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Damage[6],true)
        set Overlay2_DPS[6]=JNCreateFrameByType("TEXT","",Overlay2_Bar[6],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[6],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[6], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[6], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0045)
        call DzFrameSetText(Overlay2_DPS[6],"")
        call DzFrameSetFont(Overlay2_DPS[6], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_DPS[6],true)
        set Overlay2_Cri[6]=JNCreateFrameByType("TEXT","",Overlay2_Bar[6],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[6],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[6], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[6], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0045)
        call DzFrameSetText(Overlay2_Cri[6],"")
        call DzFrameSetFont(Overlay2_Cri[6], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Cri[6],true)
        set Overlay2_Count[6]=JNCreateFrameByType("TEXT","",Overlay2_Bar[6],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[6],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[6], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[6], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0045)
        call DzFrameSetText(Overlay2_Count[6],"")
        call DzFrameSetFont(Overlay2_Count[6], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Count[6],true)
        set Overlay2_share[6]=JNCreateFrameByType("TEXT","",Overlay2_Bar[6],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[6],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[6], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[6], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0045)
        call DzFrameSetText(Overlay2_share[6],"")
        call DzFrameSetFont(Overlay2_share[6], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_share[6],true)

        set Overlay2_Bar[7]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[7], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.243)
        call DzFrameSetTexture(Overlay2_Bar[7],METER_BAR_TEX,0)
        call DzFrameSetSize(Overlay2_Bar[7], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[7], true)
        set Overlay2_SkillName[7]=JNCreateFrameByType("TEXT","",Overlay2_Bar[7],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[7],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[7], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[7], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0045)
        call DzFrameSetText(Overlay2_SkillName[7],"")
        call DzFrameSetFont(Overlay2_SkillName[7], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_SkillName[7],true)
        set Overlay2_Damage[7]=JNCreateFrameByType("TEXT","",Overlay2_Bar[7],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[7],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[7], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[7], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0045)
        call DzFrameSetText(Overlay2_Damage[7],"")
        call DzFrameSetFont(Overlay2_Damage[7], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Damage[7],true)
        set Overlay2_DPS[7]=JNCreateFrameByType("TEXT","",Overlay2_Bar[7],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[7],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[7], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[7], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0045)
        call DzFrameSetText(Overlay2_DPS[7],"")
        call DzFrameSetFont(Overlay2_DPS[7], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_DPS[7],true)
        set Overlay2_Cri[7]=JNCreateFrameByType("TEXT","",Overlay2_Bar[7],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[7],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[7], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[7], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0045)
        call DzFrameSetText(Overlay2_Cri[7],"")
        call DzFrameSetFont(Overlay2_Cri[7], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Cri[7],true)
        set Overlay2_Count[7]=JNCreateFrameByType("TEXT","",Overlay2_Bar[7],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[7],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[7], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[7], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0045)
        call DzFrameSetText(Overlay2_Count[7],"")
        call DzFrameSetFont(Overlay2_Count[7], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Count[7],true)
        set Overlay2_share[7]=JNCreateFrameByType("TEXT","",Overlay2_Bar[7],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[7],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[7], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[7], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0045)
        call DzFrameSetText(Overlay2_share[7],"")
        call DzFrameSetFont(Overlay2_share[7], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_share[7],true)

        set Overlay2_Bar[8]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[8], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.268)
        call DzFrameSetTexture(Overlay2_Bar[8],METER_BAR_TEX,0)
        call DzFrameSetSize(Overlay2_Bar[8], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[8], true)
        set Overlay2_SkillName[8]=JNCreateFrameByType("TEXT","",Overlay2_Bar[8],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[8],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[8], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[8], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0045)
        call DzFrameSetText(Overlay2_SkillName[8],"")
        call DzFrameSetFont(Overlay2_SkillName[8], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_SkillName[8],true)
        set Overlay2_Damage[8]=JNCreateFrameByType("TEXT","",Overlay2_Bar[8],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[8],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[8], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[8], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0045)
        call DzFrameSetText(Overlay2_Damage[8],"")
        call DzFrameSetFont(Overlay2_Damage[8], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Damage[8],true)
        set Overlay2_DPS[8]=JNCreateFrameByType("TEXT","",Overlay2_Bar[8],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[8],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[8], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[8], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0045)
        call DzFrameSetText(Overlay2_DPS[8],"")
        call DzFrameSetFont(Overlay2_DPS[8], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_DPS[8],true)
        set Overlay2_Cri[8]=JNCreateFrameByType("TEXT","",Overlay2_Bar[8],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[8],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[8], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[8], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0045)
        call DzFrameSetText(Overlay2_Cri[8],"")
        call DzFrameSetFont(Overlay2_Cri[8], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Cri[8],true)
        set Overlay2_Count[8]=JNCreateFrameByType("TEXT","",Overlay2_Bar[8],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[8],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[8], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[8], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0045)
        call DzFrameSetText(Overlay2_Count[8],"")
        call DzFrameSetFont(Overlay2_Count[8], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Count[8],true)
        set Overlay2_share[8]=JNCreateFrameByType("TEXT","",Overlay2_Bar[8],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[8],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[8], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[8], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0045)
        call DzFrameSetText(Overlay2_share[8],"")
        call DzFrameSetFont(Overlay2_share[8], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_share[8],true)

        set Overlay2_Bar[9]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[9], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.293)
        call DzFrameSetTexture(Overlay2_Bar[9],METER_BAR_TEX,0)
        call DzFrameSetSize(Overlay2_Bar[9], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[9], true)
        set Overlay2_SkillName[9]=JNCreateFrameByType("TEXT","",Overlay2_Bar[9],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[9],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[9], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[9], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0045)
        call DzFrameSetText(Overlay2_SkillName[9],"")
        call DzFrameSetFont(Overlay2_SkillName[9], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_SkillName[9],true)
        set Overlay2_Damage[9]=JNCreateFrameByType("TEXT","",Overlay2_Bar[9],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[9],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[9], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[9], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0045)
        call DzFrameSetText(Overlay2_Damage[9],"")
        call DzFrameSetFont(Overlay2_Damage[9], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Damage[9],true)
        set Overlay2_DPS[9]=JNCreateFrameByType("TEXT","",Overlay2_Bar[9],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[9],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[9], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[9], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0045)
        call DzFrameSetText(Overlay2_DPS[9],"")
        call DzFrameSetFont(Overlay2_DPS[9], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_DPS[9],true)
        set Overlay2_Cri[9]=JNCreateFrameByType("TEXT","",Overlay2_Bar[9],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[9],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[9], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[9], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0045)
        call DzFrameSetText(Overlay2_Cri[9],"")
        call DzFrameSetFont(Overlay2_Cri[9], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Cri[9],true)
        set Overlay2_Count[9]=JNCreateFrameByType("TEXT","",Overlay2_Bar[9],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[9],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[9], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[9], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0045)
        call DzFrameSetText(Overlay2_Count[9],"")
        call DzFrameSetFont(Overlay2_Count[9], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Count[9],true)
        set Overlay2_share[9]=JNCreateFrameByType("TEXT","",Overlay2_Bar[9],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[9],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[9], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[9], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0045)
        call DzFrameSetText(Overlay2_share[9],"")
        call DzFrameSetFont(Overlay2_share[9], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_share[9],true)

        set Overlay2_Bar[10]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[10], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.318)
        call DzFrameSetTexture(Overlay2_Bar[10],METER_BAR_TEX,0)
        call DzFrameSetSize(Overlay2_Bar[10], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[10], true)
        set Overlay2_SkillName[10]=JNCreateFrameByType("TEXT","",Overlay2_Bar[10],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[10],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[10], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[10], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0045)
        call DzFrameSetText(Overlay2_SkillName[10],"")
        call DzFrameSetFont(Overlay2_SkillName[10], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_SkillName[10],true)
        set Overlay2_Damage[10]=JNCreateFrameByType("TEXT","",Overlay2_Bar[10],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[10],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[10], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[10], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0045)
        call DzFrameSetText(Overlay2_Damage[10],"")
        call DzFrameSetFont(Overlay2_Damage[10], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Damage[10],true)
        set Overlay2_DPS[10]=JNCreateFrameByType("TEXT","",Overlay2_Bar[10],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[10],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[10], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[10], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0045)
        call DzFrameSetText(Overlay2_DPS[10],"")
        call DzFrameSetFont(Overlay2_DPS[10], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_DPS[10],true)
        set Overlay2_Cri[10]=JNCreateFrameByType("TEXT","",Overlay2_Bar[10],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[10],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[10], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[10], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0045)
        call DzFrameSetText(Overlay2_Cri[10],"")
        call DzFrameSetFont(Overlay2_Cri[10], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Cri[10],true)
        set Overlay2_Count[10]=JNCreateFrameByType("TEXT","",Overlay2_Bar[10],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[10],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[10], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[10], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0045)
        call DzFrameSetText(Overlay2_Count[10],"")
        call DzFrameSetFont(Overlay2_Count[10], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Count[10],true)
        set Overlay2_share[10]=JNCreateFrameByType("TEXT","",Overlay2_Bar[10],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[10],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[10], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[10], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0045)
        call DzFrameSetText(Overlay2_share[10],"")
        call DzFrameSetFont(Overlay2_share[10], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_share[10],true)

        set Overlay2_Bar[11]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[11], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.343)
        call DzFrameSetTexture(Overlay2_Bar[11],METER_BAR_TEX,0)
        call DzFrameSetSize(Overlay2_Bar[11], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[11], true)
        set Overlay2_SkillName[11]=JNCreateFrameByType("TEXT","",Overlay2_Bar[11],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[11],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[11], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[11], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0045)
        call DzFrameSetText(Overlay2_SkillName[11],"")
        call DzFrameSetFont(Overlay2_SkillName[11], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_SkillName[11],true)
        set Overlay2_Damage[11]=JNCreateFrameByType("TEXT","",Overlay2_Bar[11],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[11],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[11], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[11], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0045)
        call DzFrameSetText(Overlay2_Damage[11],"")
        call DzFrameSetFont(Overlay2_Damage[11], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Damage[11],true)
        set Overlay2_DPS[11]=JNCreateFrameByType("TEXT","",Overlay2_Bar[11],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[11],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[11], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[11], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0045)
        call DzFrameSetText(Overlay2_DPS[11],"")
        call DzFrameSetFont(Overlay2_DPS[11], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_DPS[11],true)
        set Overlay2_Cri[11]=JNCreateFrameByType("TEXT","",Overlay2_Bar[11],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[11],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[11], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[11], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0045)
        call DzFrameSetText(Overlay2_Cri[11],"")
        call DzFrameSetFont(Overlay2_Cri[11], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Cri[11],true)
        set Overlay2_Count[11]=JNCreateFrameByType("TEXT","",Overlay2_Bar[11],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[11],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[11], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[11], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0045)
        call DzFrameSetText(Overlay2_Count[11],"")
        call DzFrameSetFont(Overlay2_Count[11], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Count[11],true)
        set Overlay2_share[11]=JNCreateFrameByType("TEXT","",Overlay2_Bar[11],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[11],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[11], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[11], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0045)
        call DzFrameSetText(Overlay2_share[11],"")
        call DzFrameSetFont(Overlay2_share[11], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_share[11],true)

        set Overlay2_Bar[12]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[12], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.368)
        call DzFrameSetTexture(Overlay2_Bar[12],METER_BAR_TEX,0)
        call DzFrameSetSize(Overlay2_Bar[12], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[12], true)
        set Overlay2_SkillName[12]=JNCreateFrameByType("TEXT","",Overlay2_Bar[12],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[12],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[12], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[12], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0045)
        call DzFrameSetText(Overlay2_SkillName[12],"")
        call DzFrameSetFont(Overlay2_SkillName[12], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_SkillName[12],true)
        set Overlay2_Damage[12]=JNCreateFrameByType("TEXT","",Overlay2_Bar[12],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[12],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[12], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[12], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0045)
        call DzFrameSetText(Overlay2_Damage[12],"")
        call DzFrameSetFont(Overlay2_Damage[12], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Damage[12],true)
        set Overlay2_DPS[12]=JNCreateFrameByType("TEXT","",Overlay2_Bar[12],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[12],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[12], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[12], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0045)
        call DzFrameSetText(Overlay2_DPS[12],"")
        call DzFrameSetFont(Overlay2_DPS[12], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_DPS[12],true)
        set Overlay2_Cri[12]=JNCreateFrameByType("TEXT","",Overlay2_Bar[12],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[12],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[12], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[12], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0045)
        call DzFrameSetText(Overlay2_Cri[12],"")
        call DzFrameSetFont(Overlay2_Cri[12], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Cri[12],true)
        set Overlay2_Count[12]=JNCreateFrameByType("TEXT","",Overlay2_Bar[12],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[12],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[12], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[12], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0045)
        call DzFrameSetText(Overlay2_Count[12],"")
        call DzFrameSetFont(Overlay2_Count[12], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Count[12],true)
        set Overlay2_share[12]=JNCreateFrameByType("TEXT","",Overlay2_Bar[12],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[12],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[12], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[12], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0045)
        call DzFrameSetText(Overlay2_share[12],"")
        call DzFrameSetFont(Overlay2_share[12], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_share[12],true)

        set Overlay2_Bar[13]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[13], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.393)
        call DzFrameSetTexture(Overlay2_Bar[13],METER_BAR_TEX,0)
        call DzFrameSetSize(Overlay2_Bar[13], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[13], true)
        set Overlay2_SkillName[13]=JNCreateFrameByType("TEXT","",Overlay2_Bar[13],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[13],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[13], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[13], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0045)
        call DzFrameSetText(Overlay2_SkillName[13],"")
        call DzFrameSetFont(Overlay2_SkillName[13], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_SkillName[13],true)
        set Overlay2_Damage[13]=JNCreateFrameByType("TEXT","",Overlay2_Bar[13],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[13],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[13], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[13], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0045)
        call DzFrameSetText(Overlay2_Damage[13],"")
        call DzFrameSetFont(Overlay2_Damage[13], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Damage[13],true)
        set Overlay2_DPS[13]=JNCreateFrameByType("TEXT","",Overlay2_Bar[13],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[13],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[13], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[13], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0045)
        call DzFrameSetText(Overlay2_DPS[13],"")
        call DzFrameSetFont(Overlay2_DPS[13], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_DPS[13],true)
        set Overlay2_Cri[13]=JNCreateFrameByType("TEXT","",Overlay2_Bar[13],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[13],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[13], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[13], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0045)
        call DzFrameSetText(Overlay2_Cri[13],"")
        call DzFrameSetFont(Overlay2_Cri[13], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Cri[13],true)
        set Overlay2_Count[13]=JNCreateFrameByType("TEXT","",Overlay2_Bar[13],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[13],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[13], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[13], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0045)
        call DzFrameSetText(Overlay2_Count[13],"")
        call DzFrameSetFont(Overlay2_Count[13], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Count[13],true)
        set Overlay2_share[13]=JNCreateFrameByType("TEXT","",Overlay2_Bar[13],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[13],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[13], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[13], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0045)
        call DzFrameSetText(Overlay2_share[13],"")
        call DzFrameSetFont(Overlay2_share[13], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_share[13],true)

        set Overlay2_Bar[14]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[14], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.418)
        call DzFrameSetTexture(Overlay2_Bar[14],METER_BAR_TEX,0)
        call DzFrameSetSize(Overlay2_Bar[14], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[14], true)
        set Overlay2_SkillName[14]=JNCreateFrameByType("TEXT","",Overlay2_Bar[14],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[14],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[14], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[14], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0045)
        call DzFrameSetText(Overlay2_SkillName[14],"")
        call DzFrameSetFont(Overlay2_SkillName[14], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_SkillName[14],true)
        set Overlay2_Damage[14]=JNCreateFrameByType("TEXT","",Overlay2_Bar[14],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[14],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[14], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[14], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0045)
        call DzFrameSetText(Overlay2_Damage[14],"")
        call DzFrameSetFont(Overlay2_Damage[14], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Damage[14],true)
        set Overlay2_DPS[14]=JNCreateFrameByType("TEXT","",Overlay2_Bar[14],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[14],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[14], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[14], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0045)
        call DzFrameSetText(Overlay2_DPS[14],"")
        call DzFrameSetFont(Overlay2_DPS[14], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_DPS[14],true)
        set Overlay2_Cri[14]=JNCreateFrameByType("TEXT","",Overlay2_Bar[14],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[14],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[14], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[14], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0045)
        call DzFrameSetText(Overlay2_Cri[14],"")
        call DzFrameSetFont(Overlay2_Cri[14], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Cri[14],true)
        set Overlay2_Count[14]=JNCreateFrameByType("TEXT","",Overlay2_Bar[14],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[14],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[14], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[14], JN_FRAMEPOINT_TOPLEFT, 0.442, -0.0045)
        call DzFrameSetText(Overlay2_Count[14],"")
        call DzFrameSetFont(Overlay2_Count[14], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_Count[14],true)
        set Overlay2_share[14]=JNCreateFrameByType("TEXT","",Overlay2_Bar[14],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[14],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[14], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[14], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0045)
        call DzFrameSetText(Overlay2_share[14],"")
        call DzFrameSetFont(Overlay2_share[14], "Fonts\\DFHeiMd.ttf", 0.0088, 0)
        call DzFrameShow(Overlay2_share[14],true)


        set Overlay2_NoShow=JNCreateFrameByType("TEXT","",Overlay2_BackDrop,"", FrameCount())
        call DzFrameSetSize(Overlay2_NoShow,0.145,0.00)
        call DzFrameSetPoint(Overlay2_NoShow, JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.255, -0.2200)
        call DzFrameSetText(Overlay2_NoShow,"|cff96c8ff전투가 끝나면 집계돼요|r")
        call DzFrameSetFont(Overlay2_NoShow, "Fonts\\DFHeiMd.ttf", 0.0100, 0)

        call DzFrameShow(Overlay2_NoShow, true)

        
        call DzFrameShow(Overlay2_Bar[0], false)
        call DzFrameShow(Overlay2_Bar[1], false)
        call DzFrameShow(Overlay2_Bar[2], false)
        call DzFrameShow(Overlay2_Bar[3], false)
        call DzFrameShow(Overlay2_Bar[4], false)
        call DzFrameShow(Overlay2_Bar[5], false)
        call DzFrameShow(Overlay2_Bar[6], false)
        call DzFrameShow(Overlay2_Bar[7], false)
        call DzFrameShow(Overlay2_Bar[8], false)
        call DzFrameShow(Overlay2_Bar[9], false)
        call DzFrameShow(Overlay2_Bar[10], false)
        call DzFrameShow(Overlay2_Bar[11], false)
        call DzFrameShow(Overlay2_Bar[12], false)
        call DzFrameShow(Overlay2_Bar[13], false)
        call DzFrameShow(Overlay2_Bar[14], false)
        
        call DzFrameShow(Overlay2_BackDrop, false)
    endfunction
    
    private function Main takes nothing returns nothing
        //set Overlay_BackDrop=DzCreateFrameByTagName("BACKDROP","",DzGetGameUI(),"", FrameCount())
        //call DzFrameSetTexture(Overlay_BackDrop,"File00005255.tga",0)
        //call DzFrameSetAbsolutePoint(Overlay_BackDrop, JN_FRAMEPOINT_CENTER, 0.08, 0.35)
        //call DzFrameSetSize(Overlay_BackDrop, 0.165, 0.140)

        //set Overlay_BackDrop=DzCreateFrameByTagName("SIMPLESTATUSBAR","",DzFrameFindByName("InfoPanelIconBackdrop",0),"", FrameCount())
        //call DzFrameSetAbsolutePoint(Overlay_BackDrop,JN_FRAMEPOINT_TOPLEFT,.150,.0900)
        //call DzFrameSetAbsolutePoint(Overlay_BackDrop,JN_FRAMEPOINT_BOTTOMRIGHT,.305,.0740)
        //call DzFrameSetTexture(Overlay_BackDrop,"File00005255.tga",0)
        //call DzFrameSetMinMaxValue(Overlay_BackDrop,0,1)
        //call DzFrameSetValue(Overlay_BackDrop,1)
        //call DzFrameSetAlpha(Overlay_BackDrop, 100)
        
        // A안 글래스 패널 (스킬 HUD와 같은 남색 유리 + 하늘색 테두리)
        // 글자가 0.007 이하이면 DFHeiMd가 깨져서 0.0084 이상으로 쓴다
        set Overlay_BackDrop=DzCreateFrameByTagName("BACKDROP","",GetGameplayUI(),"", FrameCount())
        call DzFrameSetTexture(Overlay_BackDrop,METER_PANEL_TEX,0)
        call DzFrameSetAbsolutePoint(Overlay_BackDrop, JN_FRAMEPOINT_CENTER, 0.10, 0.35)
        call DzFrameSetSize(Overlay_BackDrop, 0.200, 0.142)

        set OverlayTitle=JNCreateFrameByType("TEXT","",Overlay_BackDrop,"", FrameCount())
        call DzFrameSetSize(OverlayTitle,0.090,0.00)
        call DzFrameSetPoint(OverlayTitle, JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.011, -0.0080)
        call DzFrameSetText(OverlayTitle,"|cffdcecff피해 미터기|r")
        call DzFrameSetFont(OverlayTitle, "Fonts\\DFHeiMd.ttf", 0.0096, 0)
        call DzFrameShow(OverlayTitle,true)
        set OverlayTimer=JNCreateFrameByType("TEXT","",Overlay_BackDrop,"", FrameCount())
        call DzFrameSetSize(OverlayTimer,0.050,0.00)
        call DzFrameSetPoint(OverlayTimer, JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.146, -0.0080)
        call DzFrameSetText(OverlayTimer,"|cff96c8ff00:00:00|r")
        call DzFrameSetFont(OverlayTimer, "Fonts\\DFHeiMd.ttf", 0.0086, 0)
        call DzFrameShow(OverlayTimer,true)
        set OverlayLine[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay_BackDrop, "", FrameCount())
        call DzFrameSetTexture(OverlayLine[0],METER_LINE_TEX,0)
        call DzFrameSetPoint(OverlayLine[0], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.008, -0.0225)
        call DzFrameSetSize(OverlayLine[0], METER_ROW_W, 0.0008)

        set OverlayRow[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay_BackDrop, "", FrameCount())
        call DzFrameSetTexture(OverlayRow[0],METER_TRACK_TEX,0)
        call DzFrameSetPoint(OverlayRow[0], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.008, -0.0270)
        call DzFrameSetSize(OverlayRow[0], METER_ROW_W, METER_ROW_H)

        set OverlayBar[0]=DzCreateFrameByTagName("BACKDROP", "", OverlayRow[0], "", FrameCount())
        call DzFrameSetPoint(OverlayBar[0], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.008, -0.0270)
        call DzFrameSetSize(OverlayBar[0], 0.002, METER_ROW_H)
        call DzFrameSetTexture(OverlayBar[0],"M_Player1.tga",0)
        call DzFrameSetAlpha(OverlayBar[0], 165)
        call DzFrameShow(OverlayBar[0], true)

        set OverlayText[0]=JNCreateFrameByType("TEXT","",OverlayBar[0],"", FrameCount())
        call DzFrameSetSize(OverlayText[0],0.085,0.00)
        call DzFrameSetPoint(OverlayText[0], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.013, -0.0315)
        call DzFrameSetText(OverlayText[0],"")
        call DzFrameSetFont(OverlayText[0], "Fonts\\DFHeiMd.ttf", 0.0090, 0)
        call DzFrameShow(OverlayText[0],true)
        set OverlayValue[0]=JNCreateFrameByType("TEXT","",OverlayBar[0],"", FrameCount())
        call DzFrameSetSize(OverlayValue[0],0.055,0.00)
        call DzFrameSetPoint(OverlayValue[0], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.098, -0.0315)
        call DzFrameSetText(OverlayValue[0],"")
        call DzFrameSetFont(OverlayValue[0], "Fonts\\DFHeiMd.ttf", 0.0090, 0)
        call DzFrameShow(OverlayValue[0],true)
        set OverlayAv[0]=JNCreateFrameByType("TEXT","",OverlayBar[0],"", FrameCount())
        call DzFrameSetSize(OverlayAv[0],0.040,0.00)
        call DzFrameSetPoint(OverlayAv[0], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.152, -0.0315)
        call DzFrameSetText(OverlayAv[0],"")
        call DzFrameSetFont(OverlayAv[0], "Fonts\\DFHeiMd.ttf", 0.0084, 0)
        call DzFrameShow(OverlayAv[0],true)

        set OverlayRow[1]=DzCreateFrameByTagName("BACKDROP", "", Overlay_BackDrop, "", FrameCount())
        call DzFrameSetTexture(OverlayRow[1],METER_TRACK_TEX,0)
        call DzFrameSetPoint(OverlayRow[1], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.008, -0.0490)
        call DzFrameSetSize(OverlayRow[1], METER_ROW_W, METER_ROW_H)

        set OverlayBar[1]=DzCreateFrameByTagName("BACKDROP", "", OverlayRow[1], "", FrameCount())
        call DzFrameSetPoint(OverlayBar[1], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.008, -0.0490)
        call DzFrameSetSize(OverlayBar[1], 0.002, METER_ROW_H)
        call DzFrameSetTexture(OverlayBar[1],"M_Player2.tga",0)
        call DzFrameSetAlpha(OverlayBar[1], 165)
        call DzFrameShow(OverlayBar[1], true)

        set OverlayText[1]=JNCreateFrameByType("TEXT","",OverlayBar[1],"", FrameCount())
        call DzFrameSetSize(OverlayText[1],0.085,0.00)
        call DzFrameSetPoint(OverlayText[1], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.013, -0.0535)
        call DzFrameSetText(OverlayText[1],"")
        call DzFrameSetFont(OverlayText[1], "Fonts\\DFHeiMd.ttf", 0.0090, 0)
        call DzFrameShow(OverlayText[1],true)
        set OverlayValue[1]=JNCreateFrameByType("TEXT","",OverlayBar[1],"", FrameCount())
        call DzFrameSetSize(OverlayValue[1],0.055,0.00)
        call DzFrameSetPoint(OverlayValue[1], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.098, -0.0535)
        call DzFrameSetText(OverlayValue[1],"")
        call DzFrameSetFont(OverlayValue[1], "Fonts\\DFHeiMd.ttf", 0.0090, 0)
        call DzFrameShow(OverlayValue[1],true)
        set OverlayAv[1]=JNCreateFrameByType("TEXT","",OverlayBar[1],"", FrameCount())
        call DzFrameSetSize(OverlayAv[1],0.040,0.00)
        call DzFrameSetPoint(OverlayAv[1], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.152, -0.0535)
        call DzFrameSetText(OverlayAv[1],"")
        call DzFrameSetFont(OverlayAv[1], "Fonts\\DFHeiMd.ttf", 0.0084, 0)
        call DzFrameShow(OverlayAv[1],true)

        set OverlayRow[2]=DzCreateFrameByTagName("BACKDROP", "", Overlay_BackDrop, "", FrameCount())
        call DzFrameSetTexture(OverlayRow[2],METER_TRACK_TEX,0)
        call DzFrameSetPoint(OverlayRow[2], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.008, -0.0710)
        call DzFrameSetSize(OverlayRow[2], METER_ROW_W, METER_ROW_H)

        set OverlayBar[2]=DzCreateFrameByTagName("BACKDROP", "", OverlayRow[2], "", FrameCount())
        call DzFrameSetPoint(OverlayBar[2], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.008, -0.0710)
        call DzFrameSetSize(OverlayBar[2], 0.002, METER_ROW_H)
        call DzFrameSetTexture(OverlayBar[2],"M_Player3.tga",0)
        call DzFrameSetAlpha(OverlayBar[2], 165)
        call DzFrameShow(OverlayBar[2], true)

        set OverlayText[2]=JNCreateFrameByType("TEXT","",OverlayBar[2],"", FrameCount())
        call DzFrameSetSize(OverlayText[2],0.085,0.00)
        call DzFrameSetPoint(OverlayText[2], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.013, -0.0755)
        call DzFrameSetText(OverlayText[2],"")
        call DzFrameSetFont(OverlayText[2], "Fonts\\DFHeiMd.ttf", 0.0090, 0)
        call DzFrameShow(OverlayText[2],true)
        set OverlayValue[2]=JNCreateFrameByType("TEXT","",OverlayBar[2],"", FrameCount())
        call DzFrameSetSize(OverlayValue[2],0.055,0.00)
        call DzFrameSetPoint(OverlayValue[2], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.098, -0.0755)
        call DzFrameSetText(OverlayValue[2],"")
        call DzFrameSetFont(OverlayValue[2], "Fonts\\DFHeiMd.ttf", 0.0090, 0)
        call DzFrameShow(OverlayValue[2],true)
        set OverlayAv[2]=JNCreateFrameByType("TEXT","",OverlayBar[2],"", FrameCount())
        call DzFrameSetSize(OverlayAv[2],0.040,0.00)
        call DzFrameSetPoint(OverlayAv[2], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.152, -0.0755)
        call DzFrameSetText(OverlayAv[2],"")
        call DzFrameSetFont(OverlayAv[2], "Fonts\\DFHeiMd.ttf", 0.0084, 0)
        call DzFrameShow(OverlayAv[2],true)

        set OverlayRow[3]=DzCreateFrameByTagName("BACKDROP", "", Overlay_BackDrop, "", FrameCount())
        call DzFrameSetTexture(OverlayRow[3],METER_TRACK_TEX,0)
        call DzFrameSetPoint(OverlayRow[3], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.008, -0.0930)
        call DzFrameSetSize(OverlayRow[3], METER_ROW_W, METER_ROW_H)

        set OverlayBar[3]=DzCreateFrameByTagName("BACKDROP", "", OverlayRow[3], "", FrameCount())
        call DzFrameSetPoint(OverlayBar[3], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.008, -0.0930)
        call DzFrameSetSize(OverlayBar[3], 0.002, METER_ROW_H)
        call DzFrameSetTexture(OverlayBar[3],"M_Player4.tga",0)
        call DzFrameSetAlpha(OverlayBar[3], 165)
        call DzFrameShow(OverlayBar[3], true)

        set OverlayText[3]=JNCreateFrameByType("TEXT","",OverlayBar[3],"", FrameCount())
        call DzFrameSetSize(OverlayText[3],0.085,0.00)
        call DzFrameSetPoint(OverlayText[3], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.013, -0.0975)
        call DzFrameSetText(OverlayText[3],"")
        call DzFrameSetFont(OverlayText[3], "Fonts\\DFHeiMd.ttf", 0.0090, 0)
        call DzFrameShow(OverlayText[3],true)
        set OverlayValue[3]=JNCreateFrameByType("TEXT","",OverlayBar[3],"", FrameCount())
        call DzFrameSetSize(OverlayValue[3],0.055,0.00)
        call DzFrameSetPoint(OverlayValue[3], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.098, -0.0975)
        call DzFrameSetText(OverlayValue[3],"")
        call DzFrameSetFont(OverlayValue[3], "Fonts\\DFHeiMd.ttf", 0.0090, 0)
        call DzFrameShow(OverlayValue[3],true)
        set OverlayAv[3]=JNCreateFrameByType("TEXT","",OverlayBar[3],"", FrameCount())
        call DzFrameSetSize(OverlayAv[3],0.040,0.00)
        call DzFrameSetPoint(OverlayAv[3], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.152, -0.0975)
        call DzFrameSetText(OverlayAv[3],"")
        call DzFrameSetFont(OverlayAv[3], "Fonts\\DFHeiMd.ttf", 0.0084, 0)
        call DzFrameShow(OverlayAv[3],true)

        set OverlayLine[1]=DzCreateFrameByTagName("BACKDROP", "", Overlay_BackDrop, "", FrameCount())
        call DzFrameSetTexture(OverlayLine[1],METER_LINE_TEX,0)
        call DzFrameSetPoint(OverlayLine[1], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.008, -0.1170)
        call DzFrameSetSize(OverlayLine[1], METER_ROW_W, 0.0006)
        call DzFrameSetAlpha(OverlayLine[1], 150)

        set OverlayLabel[0]=JNCreateFrameByType("TEXT","",Overlay_BackDrop,"", FrameCount())
        call DzFrameSetSize(OverlayLabel[0],0.040,0.00)
        call DzFrameSetPoint(OverlayLabel[0], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.011, -0.1225)
        call DzFrameSetText(OverlayLabel[0],"|cff96bee8내 피해|r")
        call DzFrameSetFont(OverlayLabel[0], "Fonts\\DFHeiMd.ttf", 0.0086, 0)
        call DzFrameShow(OverlayLabel[0],true)
        set OverlayDamage=JNCreateFrameByType("TEXT","",Overlay_BackDrop,"", FrameCount())
        call DzFrameSetSize(OverlayDamage,0.060,0.00)
        call DzFrameSetPoint(OverlayDamage, JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.048, -0.1222)
        call DzFrameSetText(OverlayDamage,"|cffffe68c0|r")
        call DzFrameSetFont(OverlayDamage, "Fonts\\DFHeiMd.ttf", 0.0092, 0)
        call DzFrameShow(OverlayDamage,true)
        set OverlayLabel[1]=JNCreateFrameByType("TEXT","",Overlay_BackDrop,"", FrameCount())
        call DzFrameSetSize(OverlayLabel[1],0.025,0.00)
        call DzFrameSetPoint(OverlayLabel[1], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.112, -0.1225)
        call DzFrameSetText(OverlayLabel[1],"|cff96bee8DPS|r")
        call DzFrameSetFont(OverlayLabel[1], "Fonts\\DFHeiMd.ttf", 0.0086, 0)
        call DzFrameShow(OverlayLabel[1],true)
        set OverlayDPS=JNCreateFrameByType("TEXT","",Overlay_BackDrop,"", FrameCount())
        call DzFrameSetSize(OverlayDPS,0.060,0.00)
        call DzFrameSetPoint(OverlayDPS, JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.134, -0.1222)
        call DzFrameSetText(OverlayDPS,"|cffffe68c0|r")
        call DzFrameSetFont(OverlayDPS, "Fonts\\DFHeiMd.ttf", 0.0092, 0)
        call DzFrameShow(OverlayDPS,true)

        call DzFrameShow(OverlayRow[0],false)
        call DzFrameShow(OverlayRow[1],false)
        call DzFrameShow(OverlayRow[2],false)
        call DzFrameShow(OverlayRow[3],false)
        call DzFrameShow(Overlay_BackDrop,false)
    endfunction

    private function Key takes nothing returns nothing
        local integer key = DzGetTriggerKey()
        local integer i = 0
        local integer j = GetPlayerId(DzGetTriggerKeyPlayer())
        
        if DzGetTriggerKeyPlayer()==GetLocalPlayer() then
            set i = JNMemoryGetByte(JNGetModuleHandle("Game.dll")+0xD04FEC)
        endif
        
        if i==1 then
        else
            if PickCheck[j] == true then
                if key == JN_OSKEY_OEM_PERIOD then
                    if Overlay2_InfoOnOff[j] == true then
                        call DzFrameShow(Overlay2_BackDrop, false)
                        set Overlay2_InfoOnOff[j] = false
                    else
                        if F_ArcanaOnOff[j] == true then
                            call DzFrameShow(F_ArcanaBackDrop, false)
                            set F_ArcanaOnOff[j] = false
                        endif
                        if F_Info2OnOff[j] == true then
                            call DzFrameShow(F_InfoBackDrop2, false)
                            set F_Info2OnOff[j] = false
                        endif
                        call DzFrameShow(Overlay2_BackDrop, true)
                        set Overlay2_InfoOnOff[j] = true
                    endif
                endif
            endif
        endif
    endfunction


    private function Command takes nothing returns nothing
        if OverlayShow[GetPlayerId(GetTriggerPlayer())] == false then
            if GetLocalPlayer() == GetTriggerPlayer() then
                call DzFrameShow(Overlay_BackDrop,true)
            endif
            set OverlayShow[GetPlayerId(GetTriggerPlayer())] = true
        elseif OverlayShow[GetPlayerId(GetTriggerPlayer())] == true then
            if GetLocalPlayer() == GetTriggerPlayer() then
                call DzFrameShow(Overlay_BackDrop,false)
            endif
            set OverlayShow[GetPlayerId(GetTriggerPlayer())] = false
        endif
    endfunction

    // -미터기리셋: 지금까지 쌓인 값을 지운다. 마을에서는 허수아비를 다시 치면 0부터 측정한다.
    private function CommandReset takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pid = GetPlayerId(p)
        local integer i = 0
        if PlayerOverlayStop[pid] == false and not OverlayTown[pid] then
            call DisplayTimedTextToPlayer(p, 0, 0, 3, "보스전 중에는 미터기를 초기화할 수 없어요.")
            set p = null
            return
        endif
        set OverlayTown[pid] = false
        set PlayerOverlayStop[pid] = true
        set OverlayTime[pid] = 0
        call Overlay2Reset(pid)
        if GetLocalPlayer() == p then
            loop
                exitwhen i > 3
                set OverlayPlayerValue[i] = 0
                set OverlayPlayerID[i] = i
                call DzFrameSetSize(OverlayBar[i], 0.002, METER_ROW_H)
                call DzFrameSetText(OverlayValue[i], "0")
                call DzFrameSetText(OverlayAv[i], "|cffd2e1f50.0%|r")
                set i = i + 1
            endloop
            call DzFrameSetText(OverlayTimer, "|cff96c8ff00:00:00|r")
            call DzFrameSetText(OverlayDamage, "|cffffe68c0|r")
            call DzFrameSetText(OverlayDPS, "|cffffe68c0|r")
            call DzFrameShow(Overlay2_NoShow, true)
            call DzFrameSetText(Overlay2_Title, "|cffdcecff스킬별 피해|r")
        endif
        call DisplayTimedTextToPlayer(p, 0, 0, 3, "미터기를 초기화했어요. 허수아비를 치면 다시 측정해요.")
        set p = null
    endfunction

    private function BindInput takes nothing returns boolean
        if Overlay2_BackDrop == 0 then
            return false
        endif
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_OEM_PERIOD, 0, false, function Key)
        return true
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger(  )
        local integer i = 0
        call TriggerRegisterTimerEvent(t, 0.10, false)
        call TriggerAddAction( t, function Main )
        
        set t = CreateTrigger(  )
        loop
            exitwhen i > 4
            call TriggerRegisterPlayerChatEvent( t, Player(i), "-미터기", true )
            set OverlayShow[i] = false
            set i = i + 1
        endloop
        call TriggerAddAction( t, function Command )

        set t = CreateTrigger(  )
        set i = 0
        loop
            exitwhen i > 3
            call TriggerRegisterPlayerChatEvent( t, Player(i), "-미터기리셋", true )
            set i = i + 1
        endloop
        call TriggerAddAction( t, function CommandReset )

        set t = CreateTrigger(  )
        call TriggerRegisterTimerEvent(t, 0.10, false)
        call TriggerAddAction( t, function Main2 )
        
        set i = 0
        loop
            set Overlay2_InfoOnOff[i] = false
            set i = i + 1
            exitwhen i == 4
        endloop
        
        set OverlayPlayerValue[0] = 0
        set OverlayPlayerID[0] = 0
        set OverlayPlayerValue[1] = 0
        set OverlayPlayerID[1] = 1
        set OverlayPlayerValue[2] = 0
        set OverlayPlayerID[2] = 2
        set OverlayPlayerValue[3] = 0
        set OverlayPlayerID[3] = 3

        set i = 0
        loop
            exitwhen i > 14
            set Overlay2Velue_SkillName[i] = 0
            set Overlay2Velue_Damage[i] = 0
            set Overlay2Velue_DPS[i] = 0
            set Overlay2Velue_Cri[i] = 0
            set  Overlay2Velue_Count[i] = 0
            set Overlay2Velue_HitCount[i] = 0
            set Overlay2Velue_share[i] = 0
            set i = i + 1
        endloop

        //.버튼으로 인포창 열기 및 닫기

        set t = null
        call UIInputAfterPick(function BindInput)
    endfunction
endlibrary
