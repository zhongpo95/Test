library UIOverlay initializer init requires UnitIndexer, DataUnit, FrameCount, Sort
    globals
        boolean array OverlayShow
        integer Overlay_BackDrop
        integer array OverlayBar
        integer array OverlayText
        integer array OverlayValue
        integer array OverlayAv
        integer OverlayTimer
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

        hashtable OverlayData = InitHashtable()
    endglobals

    //pid,스킬,피해량,크리
    //call Overlay2(pid, SkillCode,(dmg * HPvalue),CriBoolean)
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
                    call BJDebugMsg("있음 "+"i : "+  I2S(SkillCode) + " /ID : "+ I2S(i))
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
                        call BJDebugMsg("없음 "+"i : "+  I2S(SkillCode) + " /ID : "+ I2S(i))
                        set id = i
                        set bool = true
                    endif
                    set i = i + 1
                endloop
            endif
            
            call BJDebugMsg( I2S(Overlay2Velue_SkillName[0])+"/"+I2S(Overlay2Velue_SkillName[1])+"/"+I2S(Overlay2Velue_SkillName[2])+"/"+I2S(Overlay2Velue_SkillName[3]) )

            set Overlay2Velue_Damage[id] = Overlay2Velue_Damage[id] + damage
            set Overlay2Velue_HitCount[id] = Overlay2Velue_HitCount[id] + 1
            if Cri == true then
                set Overlay2Velue_Cri[id] = Overlay2Velue_Cri[id] + 1
            endif
            call BJDebugMsg("오버레이2 대미지값: "+ R2S(Overlay2Velue_Damage[id]))
            call BJDebugMsg("오버레이2 I 값: "+ I2S(id))
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

    // 높은 순으로 정렬
    function CompareOverlay takes nothing returns nothing
        set Sort_isCompare = OverlayPlayerValue[Sort_indexA] <= OverlayPlayerValue[Sort_indexB]
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
        local string s = ""
        local string s1 = ""
        local string s2 = ""
        local string s3 = ""
        local string s4 = ""
        local integer sl = 0
        local integer i = 0
        local integer i2 = 0

        if GetLocalPlayer() == Player(t.data) then
            call Sort_Run(0, 3, "CompareOverlay", "SwapOverlay")
            set r = OverlayPlayerValue[0] + OverlayPlayerValue[1] + OverlayPlayerValue[2] + OverlayPlayerValue[3]
            if r != 0 then
                loop
                    exitwhen i > 3
                    if t.data == OverlayPlayerID[i] then
                        set i2 = i
                    endif
                    set i = i + 1
                endloop
            endif
            call DzFrameSetTexture(OverlayBar[0],"M_Player"+I2S(OverlayPlayerID[0]+1)+".tga",0)
            call DzFrameSetTexture(OverlayBar[1],"M_Player"+I2S(OverlayPlayerID[1]+1)+".tga",0)
            call DzFrameSetTexture(OverlayBar[2],"M_Player"+I2S(OverlayPlayerID[2]+1)+".tga",0)
            call DzFrameSetTexture(OverlayBar[3],"M_Player"+I2S(OverlayPlayerID[3]+1)+".tga",0)
            call DzFrameSetText(OverlayText[0], GetPlayerName(Player(OverlayPlayerID[0])))
            call DzFrameSetText(OverlayText[1], GetPlayerName(Player(OverlayPlayerID[1])))
            call DzFrameSetText(OverlayText[2], GetPlayerName(Player(OverlayPlayerID[2])))
            call DzFrameSetText(OverlayText[3], GetPlayerName(Player(OverlayPlayerID[3])))

            set s = R2SW(OverlayPlayerValue[0],1,1)
            set s1 = TextChange(s)
            call DzFrameSetText(OverlayValue[0], s1)

            if OverlayPlayerValue[0] != 0 then
                call DzFrameShow(OverlayBar[0],true)
                call DzFrameSetSize(OverlayBar[0], 0.145, 0.0130)
            endif
            
            set s = R2SW(OverlayPlayerValue[1],1,1)
            set s2 = TextChange(s)
            call DzFrameSetText(OverlayValue[1], s2)

            if OverlayPlayerValue[1] != 0 then
                call DzFrameShow(OverlayBar[1],true)
                call DzFrameSetSize(OverlayBar[1], 0.145 * (OverlayPlayerValue[1]/OverlayPlayerValue[0]), 0.0130)
            endif

            set s = R2SW(OverlayPlayerValue[2],1,1)
            set s2 = TextChange(s)
            call DzFrameSetText(OverlayValue[2], s3)

            if OverlayPlayerValue[2] != 0 then
                call DzFrameShow(OverlayBar[2],true)
                call DzFrameSetSize(OverlayBar[2], 0.145 * (OverlayPlayerValue[2]/OverlayPlayerValue[0]), 0.0130)
            endif

            set s = R2SW(OverlayPlayerValue[3],1,1)
            set s2 = TextChange(s)
            call DzFrameSetText(OverlayValue[3], s4)

            if OverlayPlayerValue[3] != 0 then
                call DzFrameShow(OverlayBar[3],true)
                call DzFrameSetSize(OverlayBar[3], 0.145 * (OverlayPlayerValue[3]/OverlayPlayerValue[0]), 0.0130)
            endif
            if r != 0 then
                call DzFrameSetText(OverlayAv[0], "("+R2SW((OverlayPlayerValue[0] / r) * 100 ,1,1) + "%)" )
                call DzFrameSetText(OverlayAv[1], "("+R2SW((OverlayPlayerValue[1] / r) * 100 ,1,1) + "%)" )
                call DzFrameSetText(OverlayAv[2], "("+R2SW((OverlayPlayerValue[2] / r) * 100 ,1,1) + "%)" )
                call DzFrameSetText(OverlayAv[3], "("+R2SW((OverlayPlayerValue[3] / r) * 100 ,1,1) + "%)" )
            endif
            call DzFrameSetText(OverlayTimer, FormatSecondsToTime(OverlayTime[t.data]))
            if r != 0 then
                if OverlayPlayerID[i2] == 0 then
                    call DzFrameSetText(OverlayDamage,s1)
                    call DzFrameSetText(OverlayDPS, TextChange(R2SW( OverlayPlayerValue[i2]/OverlayTime[t.data],1,1)) )
                elseif OverlayPlayerID[i2] == 1 then
                    call DzFrameSetText(OverlayDamage,s2)
                    call DzFrameSetText(OverlayDPS, TextChange(R2SW( OverlayPlayerValue[i2]/OverlayTime[t.data],1,1)) )
                elseif OverlayPlayerID[i2] == 2 then
                    call DzFrameSetText(OverlayDamage,s3)
                    call DzFrameSetText(OverlayDPS, TextChange(R2SW( OverlayPlayerValue[i2]/OverlayTime[t.data],1,1)) )
                elseif OverlayPlayerID[i2] == 3 then
                    call DzFrameSetText(OverlayDamage,s4)
                    call DzFrameSetText(OverlayDPS, TextChange(R2SW( OverlayPlayerValue[i2]/OverlayTime[t.data],1,1)) )
                endif
            endif
        endif
        if PlayerOverlayStop[t.data] == true then
            call t.destroy()
        endif

    endfunction

    function OverlayTimeCheck takes nothing returns nothing
        local tick t = tick.getExpired()

        set OverlayTime[t.data] = OverlayTime[t.data] + 1
        
        if PlayerOverlayStop[t.data] == true then
            call t.destroy()
        endif
    endfunction

    function Overlay takes integer pid returns nothing
        local integer i = 0
        local tick t = tick.create(pid)
        local tick t2 = tick.create(pid)

        set PlayerOverlayStop[pid] = false

        call Overlay2Reset(pid)
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

        if GetLocalPlayer() == Player(pid) then
            set OverlayPlayerValue[0] = 0
            set OverlayPlayerID[0] = 0
            set OverlayPlayerValue[1] = 0
            set OverlayPlayerID[1] = 1
            set OverlayPlayerValue[2] = 0
            set OverlayPlayerID[2] = 2
            set OverlayPlayerValue[3] = 0
            set OverlayPlayerID[3] = 3
        endif
        
        //call Sort_Run(0, 3, "CompareOverlay", "SwapOverlay")
        /*
        if GetLocalPlayer() then
            call DzFrameSetTexture(OverlayBar[0],"M_Player1.tga",0)
        endif
        */
        
        call t.start( 0.05, true, function OverlayEffect )
        call t2.start( 1.00, true, function OverlayTimeCheck )
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

    function OverlayStop takes integer pid returns nothing
        local integer i = 0
        local string s = ""
        local real r = 0

        set PlayerOverlayStop[pid] = true
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
                call DzFrameSetTexture(Overlay2_Bar[0],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
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
                
                set s = R2SW(Overlay2Velue_Damage[0]/OverlayTime[pid],1,1)
                call DzFrameSetText(Overlay2_DPS[0], TextChange(s))
                
                set s = R2SW(Overlay2Velue_Cri[0]/Overlay2Velue_HitCount[0] * 100,1,1)
                call DzFrameSetText(Overlay2_Cri[0], s+"%")
                
                call DzFrameSetText(Overlay2_Count[0], I2S(Overlay2Velue_Count[0]) )

                set s = R2SW(Overlay2Velue_Damage[0]/r * 100,1,1)
                call DzFrameSetText(Overlay2_share[0], s+"%")
                
                call DzFrameShow(Overlay2_Bar[0], true)
            endif
            
            set i = 1
            loop
                exitwhen i > 14
                if Overlay2Velue_Damage[i] != 0 then
                    call DzFrameSetTexture(Overlay2_Bar[i],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
                    
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
                    
                    set s = R2SW(Overlay2Velue_Damage[i]/OverlayTime[pid],1,1)
                    call DzFrameSetText(Overlay2_DPS[i], TextChange(s))
                    
                    set s = R2SW(Overlay2Velue_Cri[i]/Overlay2Velue_HitCount[i] * 100,1,1)
                    call DzFrameSetText(Overlay2_Cri[i], s+"%")
                    
                    call DzFrameSetText(Overlay2_Count[i], I2S(Overlay2Velue_Count[i]) )
    
                    set s = R2SW(Overlay2Velue_Damage[i]/r * 100,1,1)
                    call DzFrameSetText(Overlay2_share[i], s+"%")
                    call DzFrameSetSize(Overlay2_Bar[i], 0.590 * (Overlay2Velue_Damage[i]/ r ), 0.0200)

                    call DzFrameShow(Overlay2_Bar[i], true)
                endif
                set i = i + 1
            endloop
            set i = 0

        endif
    endfunction

    //private function Command2 takes nothing returns nothing
        //local string s = GetEventPlayerChatString()
        //local string temp = JNStringSplit(s, " ", 1)
        //local real a = S2R(JNStringSplit(temp, "/", 0))
        //local real b = S2R(JNStringSplit(temp, "/", 1))
        //call BJDebugMsg(R2S(a) + " " + R2S(b))
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
        set Overlay2_BackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetTexture(Overlay2_BackDrop, "File00005255.blp", 0)
        call DzFrameSetAbsolutePoint(Overlay2_BackDrop, JN_FRAMEPOINT_CENTER, 0.400, 0.300)
        call DzFrameSetSize(Overlay2_BackDrop, 0.650, 0.450)
        call DzFrameSetAlpha(Overlay2_BackDrop, 225)
        call DzFrameSetPriority(Overlay2_BackDrop, 5)

        set Overlay2_ImageText=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(Overlay2_ImageText, "Overlay2.tga", 0)
        call DzFrameSetAbsolutePoint(Overlay2_ImageText, JN_FRAMEPOINT_CENTER, 0.400, 0.450)
        call DzFrameSetSize(Overlay2_ImageText, 0.590, 0.0250)

        set Overlay2_Bar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.095)
        call DzFrameSetTexture(Overlay2_Bar[0],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[0], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[0], true)
        set Overlay2_SkillName[0]=JNCreateFrameByType("TEXT","",Overlay2_Bar[0],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[0],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0050)
        call DzFrameSetText(Overlay2_SkillName[0],"")
        call DzFrameSetFont(Overlay2_SkillName[0], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_SkillName[0],true)
        set Overlay2_Damage[0]=JNCreateFrameByType("TEXT","",Overlay2_Bar[0],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[0],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0050)
        call DzFrameSetText(Overlay2_Damage[0],"")
        call DzFrameSetFont(Overlay2_Damage[0], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Damage[0],true)
        set Overlay2_DPS[0]=JNCreateFrameByType("TEXT","",Overlay2_Bar[0],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[0],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0050)
        call DzFrameSetText(Overlay2_DPS[0],"")
        call DzFrameSetFont(Overlay2_DPS[0], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_DPS[0],true)
        set Overlay2_Cri[0]=JNCreateFrameByType("TEXT","",Overlay2_Bar[0],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[0],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0050)
        call DzFrameSetText(Overlay2_Cri[0],"")
        call DzFrameSetFont(Overlay2_Cri[0], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Cri[0],true)
        set Overlay2_Count[0]=JNCreateFrameByType("TEXT","",Overlay2_Bar[0],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[0],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0050)
        call DzFrameSetText(Overlay2_Count[0],"")
        call DzFrameSetFont(Overlay2_Count[0], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Count[0],true)
        set Overlay2_share[0]=JNCreateFrameByType("TEXT","",Overlay2_Bar[0],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[0],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[0], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[0], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0050)
        call DzFrameSetText(Overlay2_share[0],"")
        call DzFrameSetFont(Overlay2_share[0], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_share[0],true)


        set Overlay2_Bar[1]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[1], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.120 )
        call DzFrameSetTexture(Overlay2_Bar[1],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[1], 0.295, 0.0200)
        call DzFrameShow(Overlay2_Bar[1], true)
        set Overlay2_SkillName[1]=JNCreateFrameByType("TEXT","",Overlay2_Bar[1],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[1],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[1], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[1], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0050)
        call DzFrameSetText(Overlay2_SkillName[1],"")
        call DzFrameSetFont(Overlay2_SkillName[1], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_SkillName[1],true)
        set Overlay2_Damage[1]=JNCreateFrameByType("TEXT","",Overlay2_Bar[1],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[1],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[1], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[1], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0050)
        call DzFrameSetText(Overlay2_Damage[1],"")
        call DzFrameSetFont(Overlay2_Damage[1], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Damage[1],true)
        set Overlay2_DPS[1]=JNCreateFrameByType("TEXT","",Overlay2_Bar[1],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[1],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[1], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[1], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0050)
        call DzFrameSetText(Overlay2_DPS[1],"")
        call DzFrameSetFont(Overlay2_DPS[1], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_DPS[1],true)
        set Overlay2_Cri[1]=JNCreateFrameByType("TEXT","",Overlay2_Bar[1],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[1],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[1], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[1], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0050)
        call DzFrameSetText(Overlay2_Cri[1],"")
        call DzFrameSetFont(Overlay2_Cri[1], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Cri[1],true)
        set Overlay2_Count[1]=JNCreateFrameByType("TEXT","",Overlay2_Bar[1],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[1],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[1], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[1], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0050)
        call DzFrameSetText(Overlay2_Count[1],"")
        call DzFrameSetFont(Overlay2_Count[1], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Count[1],true)
        set Overlay2_share[1]=JNCreateFrameByType("TEXT","",Overlay2_Bar[1],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[1],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[1], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[1], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0050)
        call DzFrameSetText(Overlay2_share[1],"")
        call DzFrameSetFont(Overlay2_share[1], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_share[1],true)

        set Overlay2_Bar[2]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[2], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.145 )
        call DzFrameSetTexture(Overlay2_Bar[2],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[2], 0.295, 0.0200)
        call DzFrameShow(Overlay2_Bar[2], true)
        set Overlay2_SkillName[2]=JNCreateFrameByType("TEXT","",Overlay2_Bar[2],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[2],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[2], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[2], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0050)
        call DzFrameSetText(Overlay2_SkillName[2],"")
        call DzFrameSetFont(Overlay2_SkillName[2], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_SkillName[2],true)
        set Overlay2_Damage[2]=JNCreateFrameByType("TEXT","",Overlay2_Bar[2],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[2],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[2], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[2], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0050)
        call DzFrameSetText(Overlay2_Damage[2],"")
        call DzFrameSetFont(Overlay2_Damage[2], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Damage[2],true)
        set Overlay2_DPS[2]=JNCreateFrameByType("TEXT","",Overlay2_Bar[2],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[2],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[2], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[2], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0050)
        call DzFrameSetText(Overlay2_DPS[2],"")
        call DzFrameSetFont(Overlay2_DPS[2], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_DPS[2],true)
        set Overlay2_Cri[2]=JNCreateFrameByType("TEXT","",Overlay2_Bar[2],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[2],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[2], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[2], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0050)
        call DzFrameSetText(Overlay2_Cri[2],"")
        call DzFrameSetFont(Overlay2_Cri[2], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Cri[2],true)
        set Overlay2_Count[2]=JNCreateFrameByType("TEXT","",Overlay2_Bar[2],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[2],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[2], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[2], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0050)
        call DzFrameSetText(Overlay2_Count[2],"")
        call DzFrameSetFont(Overlay2_Count[2], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Count[2],true)
        set Overlay2_share[2]=JNCreateFrameByType("TEXT","",Overlay2_Bar[2],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[2],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[2], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[2], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0050)
        call DzFrameSetText(Overlay2_share[2],"")
        call DzFrameSetFont(Overlay2_share[2], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_share[2],true)

        set Overlay2_Bar[3]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[3], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.170 )
        call DzFrameSetTexture(Overlay2_Bar[3],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[3], 0.059, 0.0200)
        call DzFrameShow(Overlay2_Bar[3], true)
        set Overlay2_SkillName[3]=JNCreateFrameByType("TEXT","",Overlay2_Bar[3],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[3],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[3], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[3], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0050)
        call DzFrameSetText(Overlay2_SkillName[3],"")
        call DzFrameSetFont(Overlay2_SkillName[3], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_SkillName[3],true)
        set Overlay2_Damage[3]=JNCreateFrameByType("TEXT","",Overlay2_Bar[3],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[3],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[3], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[3], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0050)
        call DzFrameSetText(Overlay2_Damage[3],"")
        call DzFrameSetFont(Overlay2_Damage[3], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Damage[3],true)
        set Overlay2_DPS[3]=JNCreateFrameByType("TEXT","",Overlay2_Bar[3],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[3],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[3], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[3], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0050)
        call DzFrameSetText(Overlay2_DPS[3],"")
        call DzFrameSetFont(Overlay2_DPS[3], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_DPS[3],true)
        set Overlay2_Cri[3]=JNCreateFrameByType("TEXT","",Overlay2_Bar[3],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[3],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[3], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[3], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0050)
        call DzFrameSetText(Overlay2_Cri[3],"")
        call DzFrameSetFont(Overlay2_Cri[3], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Cri[3],true)
        set Overlay2_Count[3]=JNCreateFrameByType("TEXT","",Overlay2_Bar[3],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[3],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[3], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[3], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0050)
        call DzFrameSetText(Overlay2_Count[3],"")
        call DzFrameSetFont(Overlay2_Count[3], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Count[3],true)
        set Overlay2_share[3]=JNCreateFrameByType("TEXT","",Overlay2_Bar[3],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[3],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[3], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[3], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0050)
        call DzFrameSetText(Overlay2_share[3],"")
        call DzFrameSetFont(Overlay2_share[3], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_share[3],true)

        set Overlay2_Bar[4]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[4], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.195)
        call DzFrameSetTexture(Overlay2_Bar[4],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[4], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[4], true)
        set Overlay2_SkillName[4]=JNCreateFrameByType("TEXT","",Overlay2_Bar[4],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[4],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[4], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[4], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0050)
        call DzFrameSetText(Overlay2_SkillName[4],"")
        call DzFrameSetFont(Overlay2_SkillName[4], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_SkillName[4],true)
        set Overlay2_Damage[4]=JNCreateFrameByType("TEXT","",Overlay2_Bar[4],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[4],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[4], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[4], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0050)
        call DzFrameSetText(Overlay2_Damage[4],"")
        call DzFrameSetFont(Overlay2_Damage[4], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Damage[4],true)
        set Overlay2_DPS[4]=JNCreateFrameByType("TEXT","",Overlay2_Bar[4],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[4],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[4], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[4], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0050)
        call DzFrameSetText(Overlay2_DPS[4],"")
        call DzFrameSetFont(Overlay2_DPS[4], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_DPS[4],true)
        set Overlay2_Cri[4]=JNCreateFrameByType("TEXT","",Overlay2_Bar[4],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[4],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[4], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[4], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0050)
        call DzFrameSetText(Overlay2_Cri[4],"")
        call DzFrameSetFont(Overlay2_Cri[4], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Cri[4],true)
        set Overlay2_Count[4]=JNCreateFrameByType("TEXT","",Overlay2_Bar[4],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[4],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[4], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[4], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0050)
        call DzFrameSetText(Overlay2_Count[4],"")
        call DzFrameSetFont(Overlay2_Count[4], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Count[4],true)
        set Overlay2_share[4]=JNCreateFrameByType("TEXT","",Overlay2_Bar[4],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[4],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[4], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[4], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0050)
        call DzFrameSetText(Overlay2_share[4],"")
        call DzFrameSetFont(Overlay2_share[4], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_share[4],true)

        set Overlay2_Bar[5]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[5], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.220)
        call DzFrameSetTexture(Overlay2_Bar[5],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[5], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[5], true)
        set Overlay2_SkillName[5]=JNCreateFrameByType("TEXT","",Overlay2_Bar[5],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[5],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[5], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[5], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0050)
        call DzFrameSetText(Overlay2_SkillName[5],"")
        call DzFrameSetFont(Overlay2_SkillName[5], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_SkillName[5],true)
        set Overlay2_Damage[5]=JNCreateFrameByType("TEXT","",Overlay2_Bar[5],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[5],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[5], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[5], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0050)
        call DzFrameSetText(Overlay2_Damage[5],"")
        call DzFrameSetFont(Overlay2_Damage[5], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Damage[5],true)
        set Overlay2_DPS[5]=JNCreateFrameByType("TEXT","",Overlay2_Bar[5],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[5],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[5], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[5], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0050)
        call DzFrameSetText(Overlay2_DPS[5],"")
        call DzFrameSetFont(Overlay2_DPS[5], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_DPS[5],true)
        set Overlay2_Cri[5]=JNCreateFrameByType("TEXT","",Overlay2_Bar[5],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[5],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[5], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[5], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0050)
        call DzFrameSetText(Overlay2_Cri[5],"")
        call DzFrameSetFont(Overlay2_Cri[5], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Cri[5],true)
        set Overlay2_Count[5]=JNCreateFrameByType("TEXT","",Overlay2_Bar[5],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[5],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[5], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[5], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0050)
        call DzFrameSetText(Overlay2_Count[5],"")
        call DzFrameSetFont(Overlay2_Count[5], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Count[5],true)
        set Overlay2_share[5]=JNCreateFrameByType("TEXT","",Overlay2_Bar[5],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[5],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[5], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[5], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0050)
        call DzFrameSetText(Overlay2_share[5],"")
        call DzFrameSetFont(Overlay2_share[5], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_share[5],true)

        set Overlay2_Bar[6]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[6], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.245)
        call DzFrameSetTexture(Overlay2_Bar[6],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[6], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[6], true)
        set Overlay2_SkillName[6]=JNCreateFrameByType("TEXT","",Overlay2_Bar[6],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[6],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[6], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[6], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0050)
        call DzFrameSetText(Overlay2_SkillName[6],"")
        call DzFrameSetFont(Overlay2_SkillName[6], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_SkillName[6],true)
        set Overlay2_Damage[6]=JNCreateFrameByType("TEXT","",Overlay2_Bar[6],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[6],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[6], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[6], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0050)
        call DzFrameSetText(Overlay2_Damage[6],"")
        call DzFrameSetFont(Overlay2_Damage[6], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Damage[6],true)
        set Overlay2_DPS[6]=JNCreateFrameByType("TEXT","",Overlay2_Bar[6],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[6],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[6], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[6], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0050)
        call DzFrameSetText(Overlay2_DPS[6],"")
        call DzFrameSetFont(Overlay2_DPS[6], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_DPS[6],true)
        set Overlay2_Cri[6]=JNCreateFrameByType("TEXT","",Overlay2_Bar[6],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[6],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[6], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[6], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0050)
        call DzFrameSetText(Overlay2_Cri[6],"")
        call DzFrameSetFont(Overlay2_Cri[6], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Cri[6],true)
        set Overlay2_Count[6]=JNCreateFrameByType("TEXT","",Overlay2_Bar[6],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[6],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[6], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[6], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0050)
        call DzFrameSetText(Overlay2_Count[6],"")
        call DzFrameSetFont(Overlay2_Count[6], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Count[6],true)
        set Overlay2_share[6]=JNCreateFrameByType("TEXT","",Overlay2_Bar[6],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[6],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[6], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[6], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0050)
        call DzFrameSetText(Overlay2_share[6],"")
        call DzFrameSetFont(Overlay2_share[6], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_share[6],true)

        set Overlay2_Bar[7]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[7], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.270)
        call DzFrameSetTexture(Overlay2_Bar[7],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[7], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[7], true)
        set Overlay2_SkillName[7]=JNCreateFrameByType("TEXT","",Overlay2_Bar[7],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[7],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[7], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[7], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0050)
        call DzFrameSetText(Overlay2_SkillName[7],"")
        call DzFrameSetFont(Overlay2_SkillName[7], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_SkillName[7],true)
        set Overlay2_Damage[7]=JNCreateFrameByType("TEXT","",Overlay2_Bar[7],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[7],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[7], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[7], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0050)
        call DzFrameSetText(Overlay2_Damage[7],"")
        call DzFrameSetFont(Overlay2_Damage[7], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Damage[7],true)
        set Overlay2_DPS[7]=JNCreateFrameByType("TEXT","",Overlay2_Bar[7],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[7],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[7], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[7], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0050)
        call DzFrameSetText(Overlay2_DPS[7],"")
        call DzFrameSetFont(Overlay2_DPS[7], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_DPS[7],true)
        set Overlay2_Cri[7]=JNCreateFrameByType("TEXT","",Overlay2_Bar[7],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[7],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[7], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[7], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0050)
        call DzFrameSetText(Overlay2_Cri[7],"")
        call DzFrameSetFont(Overlay2_Cri[7], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Cri[7],true)
        set Overlay2_Count[7]=JNCreateFrameByType("TEXT","",Overlay2_Bar[7],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[7],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[7], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[7], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0050)
        call DzFrameSetText(Overlay2_Count[7],"")
        call DzFrameSetFont(Overlay2_Count[7], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Count[7],true)
        set Overlay2_share[7]=JNCreateFrameByType("TEXT","",Overlay2_Bar[7],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[7],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[7], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[7], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0050)
        call DzFrameSetText(Overlay2_share[7],"")
        call DzFrameSetFont(Overlay2_share[7], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_share[7],true)

        set Overlay2_Bar[8]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[8], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.295)
        call DzFrameSetTexture(Overlay2_Bar[8],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[8], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[8], true)
        set Overlay2_SkillName[8]=JNCreateFrameByType("TEXT","",Overlay2_Bar[8],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[8],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[8], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[8], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0050)
        call DzFrameSetText(Overlay2_SkillName[8],"")
        call DzFrameSetFont(Overlay2_SkillName[8], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_SkillName[8],true)
        set Overlay2_Damage[8]=JNCreateFrameByType("TEXT","",Overlay2_Bar[8],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[8],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[8], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[8], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0050)
        call DzFrameSetText(Overlay2_Damage[8],"")
        call DzFrameSetFont(Overlay2_Damage[8], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Damage[8],true)
        set Overlay2_DPS[8]=JNCreateFrameByType("TEXT","",Overlay2_Bar[8],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[8],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[8], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[8], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0050)
        call DzFrameSetText(Overlay2_DPS[8],"")
        call DzFrameSetFont(Overlay2_DPS[8], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_DPS[8],true)
        set Overlay2_Cri[8]=JNCreateFrameByType("TEXT","",Overlay2_Bar[8],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[8],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[8], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[8], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0050)
        call DzFrameSetText(Overlay2_Cri[8],"")
        call DzFrameSetFont(Overlay2_Cri[8], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Cri[8],true)
        set Overlay2_Count[8]=JNCreateFrameByType("TEXT","",Overlay2_Bar[8],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[8],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[8], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[8], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0050)
        call DzFrameSetText(Overlay2_Count[8],"")
        call DzFrameSetFont(Overlay2_Count[8], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Count[8],true)
        set Overlay2_share[8]=JNCreateFrameByType("TEXT","",Overlay2_Bar[8],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[8],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[8], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[8], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0050)
        call DzFrameSetText(Overlay2_share[8],"")
        call DzFrameSetFont(Overlay2_share[8], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_share[8],true)

        set Overlay2_Bar[9]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[9], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.320)
        call DzFrameSetTexture(Overlay2_Bar[9],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[9], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[9], true)
        set Overlay2_SkillName[9]=JNCreateFrameByType("TEXT","",Overlay2_Bar[9],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[9],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[9], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[9], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0050)
        call DzFrameSetText(Overlay2_SkillName[9],"")
        call DzFrameSetFont(Overlay2_SkillName[9], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_SkillName[9],true)
        set Overlay2_Damage[9]=JNCreateFrameByType("TEXT","",Overlay2_Bar[9],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[9],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[9], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[9], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0050)
        call DzFrameSetText(Overlay2_Damage[9],"")
        call DzFrameSetFont(Overlay2_Damage[9], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Damage[9],true)
        set Overlay2_DPS[9]=JNCreateFrameByType("TEXT","",Overlay2_Bar[9],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[9],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[9], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[9], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0050)
        call DzFrameSetText(Overlay2_DPS[9],"")
        call DzFrameSetFont(Overlay2_DPS[9], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_DPS[9],true)
        set Overlay2_Cri[9]=JNCreateFrameByType("TEXT","",Overlay2_Bar[9],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[9],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[9], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[9], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0050)
        call DzFrameSetText(Overlay2_Cri[9],"")
        call DzFrameSetFont(Overlay2_Cri[9], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Cri[9],true)
        set Overlay2_Count[9]=JNCreateFrameByType("TEXT","",Overlay2_Bar[9],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[9],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[9], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[9], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0050)
        call DzFrameSetText(Overlay2_Count[9],"")
        call DzFrameSetFont(Overlay2_Count[9], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Count[9],true)
        set Overlay2_share[9]=JNCreateFrameByType("TEXT","",Overlay2_Bar[9],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[9],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[9], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[9], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0050)
        call DzFrameSetText(Overlay2_share[9],"")
        call DzFrameSetFont(Overlay2_share[9], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_share[9],true)

        set Overlay2_Bar[10]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[10], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.345)
        call DzFrameSetTexture(Overlay2_Bar[10],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[10], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[10], true)
        set Overlay2_SkillName[10]=JNCreateFrameByType("TEXT","",Overlay2_Bar[10],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[10],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[10], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[10], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0050)
        call DzFrameSetText(Overlay2_SkillName[10],"")
        call DzFrameSetFont(Overlay2_SkillName[10], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_SkillName[10],true)
        set Overlay2_Damage[10]=JNCreateFrameByType("TEXT","",Overlay2_Bar[10],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[10],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[10], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[10], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0050)
        call DzFrameSetText(Overlay2_Damage[10],"")
        call DzFrameSetFont(Overlay2_Damage[10], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Damage[10],true)
        set Overlay2_DPS[10]=JNCreateFrameByType("TEXT","",Overlay2_Bar[10],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[10],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[10], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[10], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0050)
        call DzFrameSetText(Overlay2_DPS[10],"")
        call DzFrameSetFont(Overlay2_DPS[10], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_DPS[10],true)
        set Overlay2_Cri[10]=JNCreateFrameByType("TEXT","",Overlay2_Bar[10],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[10],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[10], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[10], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0050)
        call DzFrameSetText(Overlay2_Cri[10],"")
        call DzFrameSetFont(Overlay2_Cri[10], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Cri[10],true)
        set Overlay2_Count[10]=JNCreateFrameByType("TEXT","",Overlay2_Bar[10],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[10],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[10], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[10], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0050)
        call DzFrameSetText(Overlay2_Count[10],"")
        call DzFrameSetFont(Overlay2_Count[10], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Count[10],true)
        set Overlay2_share[10]=JNCreateFrameByType("TEXT","",Overlay2_Bar[10],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[10],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[10], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[10], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0050)
        call DzFrameSetText(Overlay2_share[10],"")
        call DzFrameSetFont(Overlay2_share[10], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_share[10],true)

        set Overlay2_Bar[11]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[11], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.370)
        call DzFrameSetTexture(Overlay2_Bar[11],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[11], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[11], true)
        set Overlay2_SkillName[11]=JNCreateFrameByType("TEXT","",Overlay2_Bar[11],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[11],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[11], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[11], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0050)
        call DzFrameSetText(Overlay2_SkillName[11],"")
        call DzFrameSetFont(Overlay2_SkillName[11], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_SkillName[11],true)
        set Overlay2_Damage[11]=JNCreateFrameByType("TEXT","",Overlay2_Bar[11],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[11],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[11], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[11], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0050)
        call DzFrameSetText(Overlay2_Damage[11],"")
        call DzFrameSetFont(Overlay2_Damage[11], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Damage[11],true)
        set Overlay2_DPS[11]=JNCreateFrameByType("TEXT","",Overlay2_Bar[11],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[11],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[11], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[11], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0050)
        call DzFrameSetText(Overlay2_DPS[11],"")
        call DzFrameSetFont(Overlay2_DPS[11], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_DPS[11],true)
        set Overlay2_Cri[11]=JNCreateFrameByType("TEXT","",Overlay2_Bar[11],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[11],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[11], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[11], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0050)
        call DzFrameSetText(Overlay2_Cri[11],"")
        call DzFrameSetFont(Overlay2_Cri[11], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Cri[11],true)
        set Overlay2_Count[11]=JNCreateFrameByType("TEXT","",Overlay2_Bar[11],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[11],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[11], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[11], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0050)
        call DzFrameSetText(Overlay2_Count[11],"")
        call DzFrameSetFont(Overlay2_Count[11], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Count[11],true)
        set Overlay2_share[11]=JNCreateFrameByType("TEXT","",Overlay2_Bar[11],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[11],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[11], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[11], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0050)
        call DzFrameSetText(Overlay2_share[11],"")
        call DzFrameSetFont(Overlay2_share[11], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_share[11],true)

        set Overlay2_Bar[12]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[12], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.395)
        call DzFrameSetTexture(Overlay2_Bar[12],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[12], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[12], true)
        set Overlay2_SkillName[12]=JNCreateFrameByType("TEXT","",Overlay2_Bar[12],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[12],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[12], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[12], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0050)
        call DzFrameSetText(Overlay2_SkillName[12],"")
        call DzFrameSetFont(Overlay2_SkillName[12], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_SkillName[12],true)
        set Overlay2_Damage[12]=JNCreateFrameByType("TEXT","",Overlay2_Bar[12],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[12],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[12], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[12], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0050)
        call DzFrameSetText(Overlay2_Damage[12],"")
        call DzFrameSetFont(Overlay2_Damage[12], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Damage[12],true)
        set Overlay2_DPS[12]=JNCreateFrameByType("TEXT","",Overlay2_Bar[12],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[12],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[12], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[12], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0050)
        call DzFrameSetText(Overlay2_DPS[12],"")
        call DzFrameSetFont(Overlay2_DPS[12], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_DPS[12],true)
        set Overlay2_Cri[12]=JNCreateFrameByType("TEXT","",Overlay2_Bar[12],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[12],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[12], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[12], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0050)
        call DzFrameSetText(Overlay2_Cri[12],"")
        call DzFrameSetFont(Overlay2_Cri[12], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Cri[12],true)
        set Overlay2_Count[12]=JNCreateFrameByType("TEXT","",Overlay2_Bar[12],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[12],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[12], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[12], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0050)
        call DzFrameSetText(Overlay2_Count[12],"")
        call DzFrameSetFont(Overlay2_Count[12], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Count[12],true)
        set Overlay2_share[12]=JNCreateFrameByType("TEXT","",Overlay2_Bar[12],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[12],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[12], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[12], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0050)
        call DzFrameSetText(Overlay2_share[12],"")
        call DzFrameSetFont(Overlay2_share[12], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_share[12],true)

        set Overlay2_Bar[13]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[13], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.320)
        call DzFrameSetTexture(Overlay2_Bar[13],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[13], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[13], true)
        set Overlay2_SkillName[13]=JNCreateFrameByType("TEXT","",Overlay2_Bar[13],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[13],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[13], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[13], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0050)
        call DzFrameSetText(Overlay2_SkillName[13],"")
        call DzFrameSetFont(Overlay2_SkillName[13], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_SkillName[13],true)
        set Overlay2_Damage[13]=JNCreateFrameByType("TEXT","",Overlay2_Bar[13],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[13],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[13], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[13], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0050)
        call DzFrameSetText(Overlay2_Damage[13],"")
        call DzFrameSetFont(Overlay2_Damage[13], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Damage[13],true)
        set Overlay2_DPS[13]=JNCreateFrameByType("TEXT","",Overlay2_Bar[13],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[13],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[13], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[13], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0050)
        call DzFrameSetText(Overlay2_DPS[13],"")
        call DzFrameSetFont(Overlay2_DPS[13], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_DPS[13],true)
        set Overlay2_Cri[13]=JNCreateFrameByType("TEXT","",Overlay2_Bar[13],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[13],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[13], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[13], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0050)
        call DzFrameSetText(Overlay2_Cri[13],"")
        call DzFrameSetFont(Overlay2_Cri[13], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Cri[13],true)
        set Overlay2_Count[13]=JNCreateFrameByType("TEXT","",Overlay2_Bar[13],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[13],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[13], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[13], JN_FRAMEPOINT_TOPLEFT, 0.440, -0.0050)
        call DzFrameSetText(Overlay2_Count[13],"")
        call DzFrameSetFont(Overlay2_Count[13], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Count[13],true)
        set Overlay2_share[13]=JNCreateFrameByType("TEXT","",Overlay2_Bar[13],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[13],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[13], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[13], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0050)
        call DzFrameSetText(Overlay2_share[13],"")
        call DzFrameSetFont(Overlay2_share[13], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_share[13],true)

        set Overlay2_Bar[14]=DzCreateFrameByTagName("BACKDROP", "", Overlay2_BackDrop, "", FrameCount())
        call DzFrameSetPoint(Overlay2_Bar[14], JN_FRAMEPOINT_TOPLEFT, Overlay2_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.030, -0.345)
        call DzFrameSetTexture(Overlay2_Bar[14],"war3mapImported\\ZT-[BOSS]-B7.blp",0)
        call DzFrameSetSize(Overlay2_Bar[14], 0.590, 0.0200)
        call DzFrameShow(Overlay2_Bar[14], true)
        set Overlay2_SkillName[14]=JNCreateFrameByType("TEXT","",Overlay2_Bar[14],"", FrameCount())
        call DzFrameSetSize(Overlay2_SkillName[14],0.145,0.00)
        call DzFrameSetPoint(Overlay2_SkillName[14], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[14], JN_FRAMEPOINT_TOPLEFT, 0.005, -0.0050)
        call DzFrameSetText(Overlay2_SkillName[14],"")
        call DzFrameSetFont(Overlay2_SkillName[14], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_SkillName[14],true)
        set Overlay2_Damage[14]=JNCreateFrameByType("TEXT","",Overlay2_Bar[14],"", FrameCount())
        call DzFrameSetSize(Overlay2_Damage[14],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Damage[14], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[14], JN_FRAMEPOINT_TOPLEFT, 0.160, -0.0050)
        call DzFrameSetText(Overlay2_Damage[14],"")
        call DzFrameSetFont(Overlay2_Damage[14], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Damage[14],true)
        set Overlay2_DPS[14]=JNCreateFrameByType("TEXT","",Overlay2_Bar[14],"", FrameCount())
        call DzFrameSetSize(Overlay2_DPS[14],0.145,0.00)
        call DzFrameSetPoint(Overlay2_DPS[14], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[14], JN_FRAMEPOINT_TOPLEFT, 0.250, -0.0050)
        call DzFrameSetText(Overlay2_DPS[14],"")
        call DzFrameSetFont(Overlay2_DPS[14], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_DPS[14],true)
        set Overlay2_Cri[14]=JNCreateFrameByType("TEXT","",Overlay2_Bar[14],"", FrameCount())
        call DzFrameSetSize(Overlay2_Cri[14],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Cri[14], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[14], JN_FRAMEPOINT_TOPLEFT, 0.345, -0.0050)
        call DzFrameSetText(Overlay2_Cri[14],"")
        call DzFrameSetFont(Overlay2_Cri[14], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Cri[14],true)
        set Overlay2_Count[14]=JNCreateFrameByType("TEXT","",Overlay2_Bar[14],"", FrameCount())
        call DzFrameSetSize(Overlay2_Count[14],0.145,0.00)
        call DzFrameSetPoint(Overlay2_Count[14], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[14], JN_FRAMEPOINT_TOPLEFT, 0.442, -0.0050)
        call DzFrameSetText(Overlay2_Count[14],"")
        call DzFrameSetFont(Overlay2_Count[14], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_Count[14],true)
        set Overlay2_share[14]=JNCreateFrameByType("TEXT","",Overlay2_Bar[14],"", FrameCount())
        call DzFrameSetSize(Overlay2_share[14],0.145,0.00)
        call DzFrameSetPoint(Overlay2_share[14], JN_FRAMEPOINT_TOPLEFT, Overlay2_Bar[14], JN_FRAMEPOINT_TOPLEFT, 0.528, -0.0050)
        call DzFrameSetText(Overlay2_share[14],"")
        call DzFrameSetFont(Overlay2_share[14], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(Overlay2_share[14],true)


        set Overlay2_NoShow=JNCreateFrameByType("TEXT","",Overlay2_BackDrop,"", FrameCount())
        call DzFrameSetSize(Overlay2_NoShow,0.145,0.00)
        call DzFrameSetAbsolutePoint(Overlay2_NoShow, JN_FRAMEPOINT_CENTER, 0.450, 0.300)
        call DzFrameSetText(Overlay2_NoShow,"집 계 중")
        call DzFrameSetFont(Overlay2_NoShow, "Fonts\\DFHeiMd.ttf", 0.012, 0)

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
        
        set Overlay_BackDrop=DzCreateFrameByTagName("BACKDROP","",DzGetGameUI(),"", FrameCount())
        call DzFrameSetTexture(Overlay_BackDrop,"Overlay.tga",0)
        call DzFrameSetAbsolutePoint(Overlay_BackDrop, JN_FRAMEPOINT_CENTER, 0.08, 0.35)
        call DzFrameSetSize(Overlay_BackDrop, 0.165, 0.140)
        call DzFrameSetAlpha(Overlay_BackDrop, 200)

        set OverlayBar[0]=DzCreateFrameByTagName("BACKDROP", "", Overlay_BackDrop, "", FrameCount())
        call DzFrameSetPoint(OverlayBar[0], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.010, -0.025)
        call DzFrameSetSize(OverlayBar[0], 0.145, 0.0130)
        call DzFrameSetTexture(OverlayBar[0],"M_Player1.tga",0)
        call DzFrameSetAlpha(OverlayBar[0], 200)
        call DzFrameShow(OverlayBar[0], true)

        set OverlayText[0]=JNCreateFrameByType("TEXT","",OverlayBar[0],"", FrameCount())
        call DzFrameSetSize(OverlayText[0],0.145,0.00)
        call DzFrameSetPoint(OverlayText[0], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.010, -0.0275)
        call DzFrameSetText(OverlayText[0],"")
        call DzFrameSetFont(OverlayText[0], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayText[0],true)

        set OverlayValue[0]=JNCreateFrameByType("TEXT","",OverlayBar[0],"", FrameCount())
        call DzFrameSetSize(OverlayValue[0],0.145,0.00)
        call DzFrameSetPoint(OverlayValue[0], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.085, -0.0275)
        call DzFrameSetText(OverlayValue[0],"")
        call DzFrameSetFont(OverlayValue[0], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayValue[0],true)

        set OverlayAv[0]=JNCreateFrameByType("TEXT","",OverlayBar[0],"", FrameCount())
        call DzFrameSetSize(OverlayAv[0],0.145,0.00)
        call DzFrameSetPoint(OverlayAv[0], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.121, -0.0275)
        call DzFrameSetText(OverlayAv[0],"(" + "00.00" + "%)")
        call DzFrameSetFont(OverlayAv[0], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayAv[0],true)

        set OverlayBar[1]=DzCreateFrameByTagName("BACKDROP", "", Overlay_BackDrop, "", FrameCount())
        call DzFrameSetPoint(OverlayBar[1], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.010, -0.045)
        call DzFrameSetSize(OverlayBar[1], 0.145, 0.0130)
        call DzFrameSetTexture(OverlayBar[1],"M_Player2.tga",0)
        call DzFrameSetAlpha(OverlayBar[1], 200)
        call DzFrameShow(OverlayBar[1], true)

        set OverlayText[1]=JNCreateFrameByType("TEXT","",OverlayBar[1],"", FrameCount())
        call DzFrameSetSize(OverlayText[1],0.145,0.00)
        call DzFrameSetPoint(OverlayText[1], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.010, -0.0475)
        call DzFrameSetText(OverlayText[1],"")
        call DzFrameSetFont(OverlayText[1], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayText[1],true)

        set OverlayValue[1]=JNCreateFrameByType("TEXT","",OverlayBar[1],"", FrameCount())
        call DzFrameSetSize(OverlayValue[1],0.145,0.00)
        call DzFrameSetPoint(OverlayValue[1], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.085, -0.0475)
        call DzFrameSetText(OverlayValue[1],""+"")
        call DzFrameSetFont(OverlayValue[1], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayValue[1],true)

        set OverlayAv[1]=JNCreateFrameByType("TEXT","",OverlayBar[1],"", FrameCount())
        call DzFrameSetSize(OverlayAv[1],0.145,0.00)
        call DzFrameSetPoint(OverlayAv[1], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.121, -0.0475)
        call DzFrameSetText(OverlayAv[1],"(" + "00.00" + "%)")
        call DzFrameSetFont(OverlayAv[1], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayAv[1],true)

        set OverlayBar[2]=DzCreateFrameByTagName("BACKDROP", "", Overlay_BackDrop, "", FrameCount())
        call DzFrameSetPoint(OverlayBar[2], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.010, -0.065)
        call DzFrameSetSize(OverlayBar[2], 0.145, 0.0130)
        call DzFrameSetTexture(OverlayBar[2],"M_Player3.tga",0)
        call DzFrameSetAlpha(OverlayBar[2], 200)
        call DzFrameShow(OverlayBar[2], true)

        set OverlayText[2]=JNCreateFrameByType("TEXT","",OverlayBar[2],"", FrameCount())
        call DzFrameSetSize(OverlayText[2],0.145,0.00)
        call DzFrameSetPoint(OverlayText[2], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.010, -0.0675)
        call DzFrameSetText(OverlayText[2],"")
        call DzFrameSetFont(OverlayText[2], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayText[2],true)

        set OverlayValue[2]=JNCreateFrameByType("TEXT","",OverlayBar[2],"", FrameCount())
        call DzFrameSetSize(OverlayValue[2],0.145,0.00)
        call DzFrameSetPoint(OverlayValue[2], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.085, -0.0675)
        call DzFrameSetText(OverlayValue[2],""+"")
        call DzFrameSetFont(OverlayValue[2], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayValue[2],true)

        set OverlayAv[2]=JNCreateFrameByType("TEXT","",OverlayBar[2],"", FrameCount())
        call DzFrameSetSize(OverlayAv[2],0.145,0.00)
        call DzFrameSetPoint(OverlayAv[2], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.121, -0.0675)
        call DzFrameSetText(OverlayAv[2],"(" + "00.00" + "%)")
        call DzFrameSetFont(OverlayAv[2], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayAv[2],true)

        set OverlayBar[3]=DzCreateFrameByTagName("BACKDROP", "", Overlay_BackDrop, "", FrameCount())
        call DzFrameSetPoint(OverlayBar[3], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.010, -0.085)
        call DzFrameSetSize(OverlayBar[3], 0.145, 0.0130)
        call DzFrameSetTexture(OverlayBar[3],"M_Player4.tga",0)
        call DzFrameSetAlpha(OverlayBar[3], 200)
        call DzFrameShow(OverlayBar[3], true)

        set OverlayText[3]=JNCreateFrameByType("TEXT","",OverlayBar[3],"", FrameCount())
        call DzFrameSetSize(OverlayText[3],0.145,0.00)
        call DzFrameSetPoint(OverlayText[3], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.010, -0.0875)
        call DzFrameSetText(OverlayText[3],"")
        call DzFrameSetFont(OverlayText[3], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayText[3],true)

        set OverlayValue[3]=JNCreateFrameByType("TEXT","",OverlayBar[3],"", FrameCount())
        call DzFrameSetSize(OverlayValue[3],0.145,0.00)
        call DzFrameSetPoint(OverlayValue[3], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.085, -0.0875)
        call DzFrameSetText(OverlayValue[3],""+"")
        call DzFrameSetFont(OverlayValue[3], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayValue[3],true)

        set OverlayAv[3]=JNCreateFrameByType("TEXT","",OverlayBar[3],"", FrameCount())
        call DzFrameSetSize(OverlayAv[3],0.145,0.00)
        call DzFrameSetPoint(OverlayAv[3], JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.121, -0.0875)
        call DzFrameSetText(OverlayAv[3],"(" + "00.00" + "%)")
        call DzFrameSetFont(OverlayAv[3], "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayAv[3],true)

        set OverlayTimer=JNCreateFrameByType("TEXT","",Overlay_BackDrop,"", FrameCount())
        call DzFrameSetSize(OverlayTimer,0.145,0.00)
        call DzFrameSetPoint(OverlayTimer, JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.121, -0.1000)
        call DzFrameSetText(OverlayTimer,"00"+":"+"00"+":"+"00")
        call DzFrameSetFont(OverlayTimer, "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayTimer,true)

        set OverlayDamage=JNCreateFrameByType("TEXT","",Overlay_BackDrop,"", FrameCount())
        call DzFrameSetSize(OverlayDamage,0.145,0.00)
        call DzFrameSetPoint(OverlayDamage, JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.0375, -0.1100)
        call DzFrameSetText(OverlayDamage,"피해량")
        call DzFrameSetFont(OverlayDamage, "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayDamage,true)
        set OverlayDamage=JNCreateFrameByType("TEXT","",Overlay_BackDrop,"", FrameCount())
        call DzFrameSetSize(OverlayDamage,0.145,0.00)
        call DzFrameSetPoint(OverlayDamage, JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.0350, -0.1225)
        call DzFrameSetText(OverlayDamage,""+"")
        call DzFrameSetFont(OverlayDamage, "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayDamage,true)

        set OverlayDPS=JNCreateFrameByType("TEXT","",Overlay_BackDrop,"", FrameCount())
        call DzFrameSetSize(OverlayDPS,0.145,0.00)
        call DzFrameSetPoint(OverlayDPS, JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.1100, -0.1100)
        call DzFrameSetText(OverlayDPS,"DPS")
        call DzFrameSetFont(OverlayDPS, "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayDPS,true)
        set OverlayDPS=JNCreateFrameByType("TEXT","",Overlay_BackDrop,"", FrameCount())
        call DzFrameSetSize(OverlayDPS,0.145,0.00)
        call DzFrameSetPoint(OverlayDPS, JN_FRAMEPOINT_TOPLEFT, Overlay_BackDrop, JN_FRAMEPOINT_TOPLEFT, 0.1050, -0.1225)
        call DzFrameSetText(OverlayDPS,""+"")
        call DzFrameSetFont(OverlayDPS, "Fonts\\DFHeiMd.ttf", 0.007, 0)
        call DzFrameShow(OverlayDPS,true)

        call DzFrameShow(OverlayBar[0],false)
        call DzFrameShow(OverlayBar[1],false)
        call DzFrameShow(OverlayBar[2],false)
        call DzFrameShow(OverlayBar[3],false)
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
            call DzFrameShow(Overlay_BackDrop,true)
            set OverlayShow[GetPlayerId(GetTriggerPlayer())] = true
        elseif OverlayShow[GetPlayerId(GetTriggerPlayer())] == true then
            call DzFrameShow(Overlay_BackDrop,false)
            set OverlayShow[GetPlayerId(GetTriggerPlayer())] = false
        endif
    endfunction

    private function Command2 takes nothing returns nothing
        local string s = GetEventPlayerChatString()
        local string temp = JNStringSplit(s, " ", 1)
        local integer a = S2I(JNStringSplit(temp, "/", 0))
        local real b = S2R(JNStringSplit(temp, "/", 1))
        local integer i = 0
        //call BJDebugMsg(R2S(a) + " " + R2S(b))
        loop
            exitwhen i > 3
            if a == OverlayPlayerID[i] then
                set OverlayPlayerValue[i] = OverlayPlayerValue[i] + b
            endif
            set i = i + 1
        endloop
    endfunction

    private function init takes nothing returns nothing
        local trigger t = CreateTrigger(  )
        local integer i = 0
        call TriggerRegisterTimerEvent(t, 0.10, false)
        call TriggerAddAction( t, function Main )
        
        set t = CreateTrigger(  )
        loop
            exitwhen i > 4
            call TriggerRegisterPlayerChatEvent( t, Player(i), "-미터기", false )
            set OverlayShow[GetPlayerId(GetTriggerPlayer())] = false
            set i = i + 1
        endloop
        call TriggerAddAction( t, function Command )

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
        call DzTriggerRegisterKeyEventByCode(null, JN_OSKEY_OEM_PERIOD, 0, false, function Key)

        set t = CreateTrigger(  )
        set i = 0
        loop
            exitwhen i > 4
            call TriggerRegisterPlayerChatEvent( t, Player(i), "-딜 ", false )
            set i = i + 1
        endloop
        call TriggerAddAction( t, function Command2 )
        
        set t = null
    endfunction
endlibrary