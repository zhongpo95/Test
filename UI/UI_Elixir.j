library UIElixir initializer init requires DataUnit, FrameCount, ItemPickUp
    /*
        1
            1	1번이 봉인된 경우
            2	2번이 봉인된 경우
            3	3번이 봉인된 경우
            4	4번이 봉인된 경우
            5	5번이 봉인된 경우

        2
            6	1번의 연성 확률이 100%인 경우
            7	2번의 연성 확률이 100%인 경우
            8	3번의 연성 확률이 100%인 경우
            9	4번의 연성 확률이 100%인 경우
            10	5번의 연성 확률이 100%인 경우

        3
            11	1번의 연성 확률이 0%인 경우
            12	2번의 연성 확률이 0%인 경우
            13	3번의 연성 확률이 0%인 경우
            14	4번의 연성 확률이 0%인 경우
            15	5번의 연성 확률이 0%인 경우

        4
            16	1번의 연성 단계가 최대인 경우
            17	2번의 연성 단계가 최대인 경우
            18	3번의 연성 단계가 최대인 경우
            19	4번의 연성 단계가 최대인 경우
            20	5번의 연성 단계가 최대인 경우

        5
            21	연성 가능한 효과 (슬롯) 가 1개 이하인 경우

        6
            22	연성 가능한 효과 (슬롯) 가 2개 이하인 경우

        7
            23	연성 가능한 효과 (슬롯) 가 3개 이하인 경우

        8
            24	1번의 연성 대성공 확률이 100%인 경우
            25	1번의 연성 대성공 확률이 100%인 경우
            26	1번의 연성 대성공 확률이 100%인 경우
            27	1번의 연성 대성공 확률이 100%인 경우
            28	1번의 연성 대성공 확률이 100%인 경우

        9
            29	모든 번호의 연성 대성공 확률이 100%인 경우

        10
            30	모든 번호의 연성단계가 동일한 경우

        11
            31	최고 연성 단계가 연성 가능한 최대 단계인 경우

        12
            32	모든 연성 단계의 합이 0인 경우
    */
    globals
        hashtable ElixirGroupData = InitHashtable()
        
        integer El_BackDrop2
        integer EL_LevelA
        integer EL_LevelB
        integer EL_LevelTextA
        integer EL_LevelTextB
        integer EL_LevelTextC
        integer EL_LevelEffect1
        integer EL_LevelEffect2

        integer El_LB
        integer El_LBBD
        integer El_LBT

        integer El_BackDrop
        integer array El_Select
        integer array El_Button
        integer array El_SelectText
        integer El_B
        integer El_BBD
        integer El_BT

        integer array El_Main
        integer array El_MainB
        integer array El_MainR
        integer array El_MainR2

        integer array ResultLevel[5][3]

        //각번호 프레임
        integer array ElF_Level[6][11]
        //각 번호 레벨 정수, 연성가중치, 임시추가 연성확률, 대성공확률, 임시추가 대성공확률
        integer array El_Level[5][6]

        real array El_RateLucky[5][6]

        integer array El_Lock[5][6]
        integer array ElF_Lock

        integer El_Roll
        integer El_RollT
        integer El_RollB
        
        boolean array ElShow
        string array ElixirText
        string array Elixir2Text
        integer array ElixirEffect[6][11]

        private integer NowMainSelect = 0
        private integer NowSelect = 0
        private integer NowSelectNumber = 0
        private integer array NowSelectNumber2

        private integer Count
        private integer CountText
        private integer MyCount
        
        private integer array NowCount
        private integer array NowRollCount
        private real array Elixirweight
        private real array Elixir2weight

        private integer array i1
        private integer array i2
        private integer array i3
        private integer array i4
        private integer array i5
        private integer array i6
        private integer array i7
        private integer array i8
        /*
        IntegerPool ElixirSelect
        IntegerPool ElixirSelect2
        IntegerPool ElixirSelect3
        IntegerPool ElixirSelect4
        IntegerPool ElixirSelect5
        */

        private integer array path_ids[5][6]
        private real array path_weights[5][6]
        private boolean array path_active[5][6]
        private integer array path_count[5]
        //선택한 그룹
        private string array SelectString
        private integer si2 = 0
    endglobals
    
    private struct ElixirSt
        integer pid = 0
        integer i = 0
        integer j = 0
    endstruct

    // 확률을 정규화하여 총합이 1.0이 되도록 함
    private function NormalizeWeights takes integer pid returns nothing
        local real total_weight = 0.0
        local integer i = 1
        
        // 활성화된 길들의 가중치만 합산
        loop
            exitwhen i > path_count[pid]
            if path_active[pid][path_ids[pid][i]] then
                set total_weight = total_weight + path_weights[pid][path_ids[pid][i]]
            endif
            set i = i + 1
        endloop
        
        if total_weight == 0.0 then
            return
        endif
        
        // 활성화된 길들의 가중치만 재분배
        set i = 1
        loop
            exitwhen i > path_count[pid]
            if path_active[pid][path_ids[pid][i]] then
                set path_weights[pid][path_ids[pid][i]] = path_weights[pid][path_ids[pid][i]] / total_weight
            endif
            set i = i + 1
        endloop
    endfunction

    //---------------------------------------------------------------------------------------
    // 특정 플레이어의 길을 설정하는 함수
    //---------------------------------------------------------------------------------------
    private function SetupPaths takes integer pid returns nothing
        local integer i = 1
        
        set path_count[pid] = 5
        loop
            exitwhen i > 5
            set path_ids[pid][i] = i
            set path_weights[pid][i] = 1.0
            set path_active[pid][i] = true 
            // 모든 길을 활성화 상태로 초기화
            set i = i + 1
        endloop
        call NormalizeWeights(pid)
    endfunction
    //---------------------------------------------------------------------------------------
    // 특정 플레이어의 길 확률을 원하는 값으로 고정시키는 함수
    //---------------------------------------------------------------------------------------
    public function SetPathChance takes integer pid, integer path_id, real target_probability_percent returns nothing
        local real target_weight
        local real remaining_total_weight = 0.0
        local integer i = 1
        
        // 1. 입력된 확률값이 0~100 사이가 되도록 강제함 (중요!)
        if target_probability_percent < 0.0 then
            set target_probability_percent = 0.0
        elseif target_probability_percent > 100.0 then
            set target_probability_percent = 100.0
        endif
        set target_weight = target_probability_percent / 100.0
        
        // 2. 목표 길을 제외한 '활성화된' 길들의 가중치 총합을 구함
        loop
            exitwhen i > path_count[pid]
            if path_ids[pid][i] != path_id and path_active[pid][path_ids[pid][i]] then
                set remaining_total_weight = remaining_total_weight + path_weights[pid][path_ids[pid][i]]
            endif
            set i = i + 1
        endloop
        
        // 3. 목표 길의 새로운 가중치를 계산
        set path_weights[pid][path_id] = target_weight * 100.0
        
        // 4. 목표 길을 제외한 '활성화된' 길들의 가중치를 재분배
        set i = 1
        loop
            exitwhen i > path_count[pid]
            if path_ids[pid][i] != path_id and path_active[pid][path_ids[pid][i]] then
                if remaining_total_weight != 0.0 then 
                    // 0으로 나누는 오류 방지
                    set path_weights[pid][path_ids[pid][i]] = (path_weights[pid][path_ids[pid][i]] / remaining_total_weight) * (100.0 - target_probability_percent)
                else
                    set path_weights[pid][path_ids[pid][i]] = 0.0
                endif
            endif
            set i = i + 1
        endloop
        
        call NormalizeWeights(pid)
    endfunction
    //---------------------------------------------------------------------------------------
    // 특정 플레이어의 길 확률을 0%로 만드는 함수 (길은 제거되지 않음)
    //---------------------------------------------------------------------------------------
    public function ZeroPathChance takes integer pid, integer path_id returns nothing
        // 해당 길의 활성화 상태를 비활성으로 변경하고
        set path_active[pid][path_id] = false
        // 확률을 0으로 고정
        set path_weights[pid][path_id] = 0.0
        // 나머지 활성화된 길들의 확률을 재정규화
        call NormalizeWeights(pid)
    endfunction
    //---------------------------------------------------------------------------------------
    // 특정 플레이어의 길을 영구적으로 제거하는 함수
    //---------------------------------------------------------------------------------------
    public function RemovePath takes integer pid, integer path_id returns nothing
        local integer i = 1
        local integer found_index = -1

        set path_weights[pid][path_id] = 0.0
        
        loop
            exitwhen i > path_count[pid]
            if path_ids[pid][i] == path_id then
                set found_index = i
                exitwhen true
            endif
            set i = i + 1
        endloop
        
        if found_index != -1 then
            set i = found_index
            loop
                exitwhen i > path_count[pid] - 1
                set path_ids[pid][i] = path_ids[pid][i + 1]
                set i = i + 1
            endloop
            set path_count[pid] = path_count[pid] - 1
            call NormalizeWeights(pid)
        endif
    endfunction
    
    // 확률에 따라 길을 선택하는 함수
    public function GetRandomPath takes integer pid returns integer
        local real random_number = GetRandomReal(0.0, 1.0)
        local real cumulative_weight = 0.0
        local integer i = 1
        
        loop
            exitwhen i > path_count[pid]
            set cumulative_weight = cumulative_weight + path_weights[pid][path_ids[pid][i]]
            if random_number <= cumulative_weight then
                return path_ids[pid][i]
            endif
            set i = i + 1
        endloop
        
        return path_ids[pid][1]
    endfunction

    public function GetRandomPath2 takes integer pid returns integer
        local integer available_paths = path_count[pid]
        local integer random_index
        
        // 사용 가능한 길이 없으면 0을 반환 (에러 방지)
        if available_paths == 0 then
            return 0
        endif
        
        // 1부터 현재 등록된 길의 개수(available_paths)까지 무작위 정수 생성
        // GetRandomInt는 대부분의 환경에서 동기화되므로 안전합니다.
        set random_index = GetRandomInt(1, available_paths)
        
        // 무작위로 선택된 인덱스에 해당하는 길의 ID를 반환
        return path_ids[pid][random_index]
    endfunction
    
    /*
        ---
        
        ### **새로 추가된 함수**
        
        **`GetPathChance`**: 길의 ID를 입력받아 현재 확률(%)을 반환합니다.
        
        ```vjass
    */
    // 특정 길의 현재 확률을 가져오는 함수
    // path_id: 확률을 가져올 길의 ID (1~5)
    // 반환값: 해당 길의 현재 확률(%)
    public function GetPathChance takes integer pid, integer path_id returns real
        return path_weights[pid][path_id] * 100.0
    endfunction
    
    private function ClickLButton3 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string s = ""

        if GetLocalPlayer() == Player(pid) then
            set s = "ID49;"
            set s = SetItemElixirLevel1(s, ResultLevel[pid][1])
            set s = SetItemElixirLevel2(s, ResultLevel[pid][2])
            call additem(Player(pid), s)
            call DzFrameShow(El_BackDrop2,false)
        endif

    endfunction

    private function ClickLButton2 takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        if f == El_Button[1] then
            set NowSelect = 1
            set NowSelectNumber = NowSelectNumber2[1]
            //call VJDebugMsg("첫번째 버튼 클릭")
            
        elseif f == El_Button[2] then
            set NowSelect = 2
            set NowSelectNumber = NowSelectNumber2[2]
            //call VJDebugMsg("두번째 버튼 클릭")

        elseif f == El_Button[3] then
            set NowSelect = 3
            set NowSelectNumber = NowSelectNumber2[3]
            //call VJDebugMsg("세번째 버튼 클릭")
        endif
    endfunction

    private function ClickLButton takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local string s = ""
        local string s2 = ""
        local integer array i
        
        if f == El_MainB[1] then
            set NowMainSelect = 1
            //call VJDebugMsg("1번 클릭")
        elseif f == El_MainB[2] then
            set NowMainSelect = 2
            //call VJDebugMsg("2번 클릭")
        elseif f == El_MainB[3] then
            set NowMainSelect = 3
            //call VJDebugMsg("3번 클릭")
        elseif f == El_MainB[4] then
            set NowMainSelect = 4
            //call VJDebugMsg("4번 클릭")
        elseif f == El_MainB[5] then
            set NowMainSelect = 5
            //call VJDebugMsg("5번 클릭")
        endif

        if f == El_RollB then
            if NowCount[pid] != 0 then
                //봉인턴
                if NowCount[pid] <= 3 then
                    call DzSyncData(("ElRoll2"), SelectString[pid]+"\t" )
                else
                    if NowRollCount[pid] >= 1 then
                        call DzSyncData(("ElRoll"), SelectString[pid]+"\t" )
                    endif
                endif
            endif
        endif

        if f == El_B then
            if NowSelectNumber != 0 then
                //봉인턴
                if NowCount[pid] <= 3 then
                    //선택가능한 선택지를 골랐나?
                    if LoadInteger(ElixirGroupData, StringHash("Elixir3"), NowSelectNumber) == 1 then
                        if NowMainSelect != 0 and NowCount[pid] != 0 and El_Lock[pid][NowMainSelect] == 0 then
                            call DzSyncData(("ElSelect2"), I2S(NowSelectNumber)+"\t"+I2S(NowMainSelect))
                        endif
                    else
                        if NowCount[pid] != 0 then
                            call DzSyncData(("ElSelect2"), I2S(NowSelectNumber)+"\t"+I2S(NowMainSelect))
                        endif
                    endif
                else
                    //선택가능한 선택지를 골랐나?
                    if LoadInteger(ElixirGroupData, StringHash("Elixir2"), NowSelectNumber) == 1 then
                        if NowMainSelect != 0 and NowCount[pid] != 0 then
                            set s = SelectString[pid]
                            set i[0] = S2I(JNStringSplit(SelectString[pid], ";", 0))
                            set i[1] = S2I(JNStringSplit(SelectString[pid], ";", 1))
                            set i[2] = S2I(JNStringSplit(SelectString[pid], ";", 2))
                            set i[3] = S2I(JNStringSplit(SelectString[pid], ";", 3))
                            set i[4] = S2I(JNStringSplit(SelectString[pid], ";", 4))
                            set i[5] = S2I(JNStringSplit(SelectString[pid], ";", 5))
                            set i[6] = S2I(JNStringSplit(SelectString[pid], ";", 6))
                            set i[7] = S2I(JNStringSplit(SelectString[pid], ";", 7))
                            if i[0] == 0 then
                                set i[0] = NowSelectNumber
                            elseif i[1] == 0 then
                                set i[1] = NowSelectNumber
                            elseif i[2] == 0 then
                                set i[2] = NowSelectNumber
                            elseif i[3] == 0 then
                                set i[3] = NowSelectNumber
                            elseif i[4] == 0 then
                                set i[4] = NowSelectNumber
                            elseif i[5] == 0 then
                                set i[5] = NowSelectNumber
                            elseif i[6] == 0 then
                                set i[6] = NowSelectNumber
                            elseif i[7] == 0 then
                                set i[7] = NowSelectNumber
                            endif
                            set SelectString[pid] = I2S(i[0])+";"+I2S(i[1])+";"+I2S(i[2])+";"+I2S(i[3])+";"+I2S(i[4])+";"+I2S(i[5])+";"+I2S(i[6])+";"+I2S(i[7])+";"
                            //call VJDebugMsg(SelectString[pid])
                            call DzSyncData(("ElSelect"), I2S(NowSelectNumber)+"\t"+SelectString[pid]+"\t"+I2S(NowMainSelect))
                        endif
                    else
                        if NowCount[pid] != 0 then
                            //call VJDebugMsg("결정2")
                            set s = SelectString[pid]
                            set i[0] = S2I(JNStringSplit(SelectString[pid], ";", 0))
                            set i[1] = S2I(JNStringSplit(SelectString[pid], ";", 1))
                            set i[2] = S2I(JNStringSplit(SelectString[pid], ";", 2))
                            set i[3] = S2I(JNStringSplit(SelectString[pid], ";", 3))
                            set i[4] = S2I(JNStringSplit(SelectString[pid], ";", 4))
                            set i[5] = S2I(JNStringSplit(SelectString[pid], ";", 5))
                            set i[6] = S2I(JNStringSplit(SelectString[pid], ";", 6))
                            set i[7] = S2I(JNStringSplit(SelectString[pid], ";", 7))
                            if i[0] == 0 then
                                set i[0] = NowSelectNumber
                            elseif i[1] == 0 then
                                set i[1] = NowSelectNumber
                            elseif i[2] == 0 then
                                set i[2] = NowSelectNumber
                            elseif i[3] == 0 then
                                set i[3] = NowSelectNumber
                            elseif i[4] == 0 then
                                set i[4] = NowSelectNumber
                            elseif i[5] == 0 then
                                set i[5] = NowSelectNumber
                            elseif i[6] == 0 then
                                set i[6] = NowSelectNumber
                            elseif i[7] == 0 then
                                set i[7] = NowSelectNumber
                            endif
                            set SelectString[pid] = I2S(i[0])+";"+I2S(i[1])+";"+I2S(i[2])+";"+I2S(i[3])+";"+I2S(i[4])+";"+I2S(i[5])+";"+I2S(i[6])+";"+I2S(i[7])+";"
                            //call VJDebugMsg(SelectString[pid])

                            call DzSyncData(("ElSelect"), I2S(NowSelectNumber)+"\t"+SelectString[pid]+"\t"+I2S(NowMainSelect))
                        endif
                    endif
                endif
            endif
        endif
    endfunction

    private function Roll3 takes nothing returns nothing
        local string s = DzGetTriggerSyncData()
        local integer pid = GetPlayerId(DzGetTriggerSyncPlayer())
        local IntegerPool ElixirSelect = IntegerPool.Create()
        local integer array i
        local integer array l
        local real array m
        local integer j
        local integer k
        local boolean found
        local integer a
        local integer b
        local integer c
        local boolean array ElixirGroup
        local integer nonlockcount
        local integer Maxcount = 0
        local integer LuckCheck = 0
        local integer highlevel = 0

        set NowRollCount[pid] = NowRollCount[pid] - 1
        if GetLocalPlayer() == Player(pid) then
            call DzFrameSetText(El_RollT,"리롤("+I2S(NowRollCount[pid])+"회 남음)")
        endif

        //그룹 논리값 설정
        //봉인됨
        set nonlockcount = 5
        //그룹 논리값 설정
        //봉인됨
        if El_Lock[pid][1] == 1 then
            set ElixirGroup[1] = true
            set nonlockcount = nonlockcount - 1
        endif
        if El_Lock[pid][2] == 1 then
            set ElixirGroup[2] = true
            set nonlockcount = nonlockcount - 1
        endif
        if El_Lock[pid][3] == 1 then
            set ElixirGroup[3] = true
            set nonlockcount = nonlockcount - 1
        endif
        if El_Lock[pid][4] == 1 then
            set ElixirGroup[4] = true
            set nonlockcount = nonlockcount - 1
        endif
        if El_Lock[pid][5] == 1 then
            set ElixirGroup[5] = true
            set nonlockcount = nonlockcount - 1
        endif
        //연성가능한 슬롯 갯수
        if nonlockcount-Maxcount <= 1 then
            set ElixirGroup[21] = true
        endif

        if ElixirGroup[1] == false then
            call ElixirSelect.add(1, Elixir2weight[1])
        endif
        if ElixirGroup[2] == false then
            call ElixirSelect.add(2, Elixir2weight[2])
        endif
        if ElixirGroup[3] == false then
            call ElixirSelect.add(3, Elixir2weight[3])
        endif
        if ElixirGroup[4] == false then
            call ElixirSelect.add(4, Elixir2weight[4])
        endif
        if ElixirGroup[5] == false then
            call ElixirSelect.add(5, Elixir2weight[5])
        endif
        if ElixirGroup[21] == false then
            call ElixirSelect.add(6, Elixir2weight[6])
        endif
        call ElixirSelect.add(7, Elixir2weight[7])
        call ElixirSelect.add(8, Elixir2weight[8])
        
        set a = ElixirSelect.pick(true)
        set b = ElixirSelect.pick(true)
        set c = ElixirSelect.pick(true)
        call ElixirSelect.clear()
        
        if GetLocalPlayer() == Player(pid) then
            set NowSelectNumber2[1] = a
            call DzFrameSetText(El_SelectText[1], Elixir2Text[NowSelectNumber2[1]])
            set NowSelectNumber2[2] = b
            call DzFrameSetText(El_SelectText[2], Elixir2Text[NowSelectNumber2[2]])
            set NowSelectNumber2[3] = c
            call DzFrameSetText(El_SelectText[3], Elixir2Text[NowSelectNumber2[3]])
            
            call DzFrameSetText(El_MainR[1], R2SW(GetPathChance(pid,1),1,1)+"%")
            call DzFrameSetText(El_MainR[2], R2SW(GetPathChance(pid,2),1,1)+"%")
            call DzFrameSetText(El_MainR[3], R2SW(GetPathChance(pid,3),1,1)+"%")
            call DzFrameSetText(El_MainR[4], R2SW(GetPathChance(pid,4),1,1)+"%")
            call DzFrameSetText(El_MainR[5], R2SW(GetPathChance(pid,5),1,1)+"%")
            call DzFrameSetText(CountText, I2S(NowCount[pid])+"회 연성가능")
        endif
    endfunction

    private function Roll4 takes integer pid returns nothing
        local IntegerPool ElixirSelect = IntegerPool.Create()
        local integer array i
        local integer array l
        local real array m
        local integer j
        local integer k
        local boolean found
        local integer a
        local integer b
        local integer c
        local boolean array ElixirGroup
        local integer Maxcount = 0
        local integer LuckCheck = 0
        local integer highlevel = 0
        local integer nonlockcount

        //그룹 논리값 설정
        //봉인됨
        set nonlockcount = 5
        //그룹 논리값 설정
        //봉인됨
        if El_Lock[pid][1] == 1 then
            set ElixirGroup[1] = true
            set nonlockcount = nonlockcount - 1
        endif
        if El_Lock[pid][2] == 1 then
            set ElixirGroup[2] = true
            set nonlockcount = nonlockcount - 1
        endif
        if El_Lock[pid][3] == 1 then
            set ElixirGroup[3] = true
            set nonlockcount = nonlockcount - 1
        endif
        if El_Lock[pid][4] == 1 then
            set ElixirGroup[4] = true
            set nonlockcount = nonlockcount - 1
        endif
        if El_Lock[pid][5] == 1 then
            set ElixirGroup[5] = true
            set nonlockcount = nonlockcount - 1
        endif
        //연성가능한 슬롯 갯수
        if nonlockcount-Maxcount <= 1 then
            set ElixirGroup[21] = true
        endif

        if ElixirGroup[1] == false then
            call ElixirSelect.add(1, Elixir2weight[1])
        endif
        if ElixirGroup[2] == false then
            call ElixirSelect.add(2, Elixir2weight[2])
        endif
        if ElixirGroup[3] == false then
            call ElixirSelect.add(3, Elixir2weight[3])
        endif
        if ElixirGroup[4] == false then
            call ElixirSelect.add(4, Elixir2weight[4])
        endif
        if ElixirGroup[5] == false then
            call ElixirSelect.add(5, Elixir2weight[5])
        endif
        if ElixirGroup[21] == false then
            call ElixirSelect.add(6, Elixir2weight[6])
        endif
        call ElixirSelect.add(7, Elixir2weight[7])
        call ElixirSelect.add(8, Elixir2weight[8])
        
        set a = ElixirSelect.pick(true)
        set b = ElixirSelect.pick(true)
        set c = ElixirSelect.pick(true)
        call ElixirSelect.clear()
        
        if GetLocalPlayer() == Player(pid) then
            set NowSelectNumber2[1] = a
            call DzFrameSetText(El_SelectText[1], Elixir2Text[NowSelectNumber2[1]])
            set NowSelectNumber2[2] = b
            call DzFrameSetText(El_SelectText[2], Elixir2Text[NowSelectNumber2[2]])
            set NowSelectNumber2[3] = c
            call DzFrameSetText(El_SelectText[3], Elixir2Text[NowSelectNumber2[3]])
            
            call DzFrameSetText(El_MainR[1], R2SW(GetPathChance(pid,1),1,1)+"%")
            call DzFrameSetText(El_MainR[2], R2SW(GetPathChance(pid,2),1,1)+"%")
            call DzFrameSetText(El_MainR[3], R2SW(GetPathChance(pid,3),1,1)+"%")
            call DzFrameSetText(El_MainR[4], R2SW(GetPathChance(pid,4),1,1)+"%")
            call DzFrameSetText(El_MainR[5], R2SW(GetPathChance(pid,5),1,1)+"%")
            call DzFrameSetText(CountText, I2S(NowCount[pid])+"회 연성가능")
        endif
    endfunction

    private function Roll2 takes integer pid returns nothing
        local IntegerPool ElixirSelect = IntegerPool.Create()
        local integer array i
        local integer array l
        local real array m
        local integer j
        local integer k
        local boolean found
        local integer a
        local integer b
        local integer c
        local boolean array ElixirGroup
        local integer nonlockcount
        local integer Maxcount = 0
        local integer LuckCheck = 0
        local integer highlevel = 0

        set m[1] = El_RateLucky[pid][1]
        set m[2] = El_RateLucky[pid][2]
        set m[3] = El_RateLucky[pid][3]
        set m[4] = El_RateLucky[pid][4]
        set m[5] = El_RateLucky[pid][5]

        ///*
        set i1[pid] = S2I(JNStringSplit(SelectString[pid], ";", 0))
        set i2[pid] = S2I(JNStringSplit(SelectString[pid], ";", 1))
        set i3[pid] = S2I(JNStringSplit(SelectString[pid], ";", 2))
        set i4[pid] = S2I(JNStringSplit(SelectString[pid], ";", 3))
        set i5[pid] = S2I(JNStringSplit(SelectString[pid], ";", 4))
        set i6[pid] = S2I(JNStringSplit(SelectString[pid], ";", 5))
        set i7[pid] = S2I(JNStringSplit(SelectString[pid], ";", 6))
        set i8[pid] = S2I(JNStringSplit(SelectString[pid], ";", 7))
        //*/

        set i[0] = i1[pid]
        set i[1] = i2[pid]
        set i[2] = i3[pid]
        set i[3] = i4[pid]
        set i[4] = i5[pid]
        set i[5] = i6[pid]
        set i[6] = i7[pid]
        set i[7] = i8[pid]

        set nonlockcount = 5
        //그룹 논리값 설정
        //봉인됨
        if El_Lock[pid][1] == 1 then
            set ElixirGroup[1] = true
            set nonlockcount = nonlockcount - 1
        endif
        if El_Lock[pid][2] == 1 then
            set ElixirGroup[2] = true
            set nonlockcount = nonlockcount - 1
        endif
        if El_Lock[pid][3] == 1 then
            set ElixirGroup[3] = true
            set nonlockcount = nonlockcount - 1
        endif
        if El_Lock[pid][4] == 1 then
            set ElixirGroup[4] = true
            set nonlockcount = nonlockcount - 1
        endif
        if El_Lock[pid][5] == 1 then
            set ElixirGroup[5] = true
            set nonlockcount = nonlockcount - 1
        endif
        //확률이100퍼
        if GetPathChance(pid,1) >= 100 then
            set ElixirGroup[6] = true
        endif
        if GetPathChance(pid,2) >= 100 then
            set ElixirGroup[7] = true
        endif
        if GetPathChance(pid,3) >= 100 then
            set ElixirGroup[8] = true
        endif
        if GetPathChance(pid,4) >= 100 then
            set ElixirGroup[9] = true
        endif
        if GetPathChance(pid,5) >= 100 then
            set ElixirGroup[10] = true
        endif
        //확률이0퍼
        if GetPathChance(pid,1) == 0 then
            set ElixirGroup[11] = true
        endif
        if GetPathChance(pid,2) == 0 then
            set ElixirGroup[12] = true
        endif
        if GetPathChance(pid,3) == 0 then
            set ElixirGroup[13] = true
        endif
        if GetPathChance(pid,4) == 0 then
            set ElixirGroup[14] = true
        endif
        if GetPathChance(pid,5) == 0 then
            set ElixirGroup[15] = true
        endif
        //연성단계가 최대치
        if El_Level[pid][1] == 10 then
            set ElixirGroup[16] = true
            //최대치면서 봉인되지않음
            if El_Lock[pid][1] != 1 then
                set Maxcount = Maxcount + 1
            endif
        endif
        if El_Level[pid][2] == 10 then
            set ElixirGroup[17] = true
            //최대치면서 봉인되지않음
            if El_Lock[pid][2] != 1 then
                set Maxcount = Maxcount + 1
            endif
        endif
        if El_Level[pid][3] == 10 then
            set ElixirGroup[18] = true
            if El_Lock[pid][3] != 1 then
                set Maxcount = Maxcount + 1
            endif
        endif
        if El_Level[pid][4] == 10 then
            set ElixirGroup[19] = true
            if El_Lock[pid][4] != 1 then
                set Maxcount = Maxcount + 1
            endif
        endif
        if El_Level[pid][5] == 10 then
            set ElixirGroup[20] = true
            if El_Lock[pid][5] != 1 then
                set Maxcount = Maxcount + 1
            endif
        endif
        //연성가능한 슬롯 갯수
        if nonlockcount-Maxcount <= 1 then
            set ElixirGroup[21] = true
        endif
        if nonlockcount-Maxcount <= 2 then
            set ElixirGroup[22] = true
        endif
        if nonlockcount-Maxcount <= 3 then
            set ElixirGroup[23] = true
        endif
        //대성공 확률 100%
        if m[1] >= 100.0 then
            set ElixirGroup[24] = true
            set LuckCheck = LuckCheck + 1
        endif
        if m[2] >= 100.0 then
            set ElixirGroup[25] = true
            set LuckCheck = LuckCheck + 1
        endif
        if m[3] >= 100.0 then
            set ElixirGroup[26] = true
            set LuckCheck = LuckCheck + 1
        endif
        if m[4] >= 100.0 then
            set ElixirGroup[27] = true
            set LuckCheck = LuckCheck + 1
        endif
        if m[5] >= 100.0 then
            set ElixirGroup[28] = true
            set LuckCheck = LuckCheck + 1
        endif
        //모든 번호의 연성 대성공 확률이 100%
        if LuckCheck == 5 then
            set ElixirGroup[29] = true
        endif
        //모든 번호의 연성 단계가 동일한 경우
        if El_Level[pid][1] == El_Level[pid][2] and El_Level[pid][2] == El_Level[pid][3] and El_Level[pid][3] == El_Level[pid][4] and El_Level[pid][4] == El_Level[pid][5] then
            set ElixirGroup[30] = true
        endif
        //최고 연성 단계가 연성 가능한 최대 단계
        set highlevel = El_Level[pid][1]
        if El_Level[pid][2] > highlevel then
            set highlevel = El_Level[pid][2]
        endif
        if El_Level[pid][3] > highlevel then
            set highlevel = El_Level[pid][3]
        endif
        if El_Level[pid][4] > highlevel then
            set highlevel = El_Level[pid][4]
        endif
        if El_Level[pid][5] > highlevel then
            set highlevel = El_Level[pid][5]
        endif
        if highlevel != 10 then
            set ElixirGroup[31] = true
        endif
        //모든 연성 단계의 합이 0
        if El_Level[pid][1] + El_Level[pid][2] + El_Level[pid][3] + El_Level[pid][4] + El_Level[pid][5] == 0 then
            set ElixirGroup[32] = true
        endif


        if i[0] != 1 and i[1] != 1 then 
            if i[2] != 1 and i[3] != 1 then
                if i[4] != 1 and i[5] != 1 then 
                    if i[6] != 1 and i[7] != 1 then
                        if ElixirGroup[1] == false and ElixirGroup[6] == false and ElixirGroup[16] == false and ElixirGroup[21] == false then
                            call ElixirSelect.add(1, Elixirweight[1])
                        endif
                    endif
                endif
            endif
        endif
        
        if i[0] != 2 and i[1] != 2 then 
            if i[2] != 2 and i[3] != 2 then
                if i[4] != 2 and i[5] != 2 then 
                    if i[6] != 2 and i[7] != 2 then
                        if ElixirGroup[2] == false and ElixirGroup[7] == false and ElixirGroup[17] == false and ElixirGroup[21] == false then
                            call ElixirSelect.add(2, Elixirweight[2])
                        endif
                    endif
                endif
            endif
        endif
        
        if i[0] != 3 and i[1] != 3 then 
            if i[2] != 3 and i[3] != 3 then
                if i[4] != 3 and i[5] != 3 then 
                    if i[6] != 3 and i[7] != 3 then
                        if ElixirGroup[3] == false and ElixirGroup[8] == false and ElixirGroup[18] == false and ElixirGroup[21] == false then
                            call ElixirSelect.add(3, Elixirweight[3])
                        endif
                    endif
                endif
            endif
        endif
        
        if i[0] != 4 and i[1] != 4 then 
            if i[2] != 4 and i[3] != 4 then
                if i[4] != 4 and i[5] != 4 then 
                    if i[6] != 4 and i[7] != 4 then
                        if ElixirGroup[4] == false and ElixirGroup[9] == false and ElixirGroup[19] == false and ElixirGroup[21] == false then
                            call ElixirSelect.add(4, Elixirweight[4])
                        endif
                    endif
                endif
            endif
        endif
        
        if i[0] != 5 and i[1] != 5 then 
            if i[2] != 5 and i[3] != 5 then
                if i[4] != 5 and i[5] != 5 then 
                    if i[6] != 5 and i[7] != 5 then
                        if ElixirGroup[5] == false and ElixirGroup[10] == false and ElixirGroup[20] == false and ElixirGroup[21] == false then
                            call ElixirSelect.add(5, Elixirweight[5])
                        endif
                    endif
                endif
            endif
        endif
        
        if i[0] != 6 and i[1] != 6 then
            if i[2] != 6 and i[3] != 6 then
                if i[4] != 6 and i[5] != 6 then
                    if i[6] != 6 and i[7] != 6 then
                        if ElixirGroup[21] == false then
                            call ElixirSelect.add(6, Elixirweight[6])
                        endif
                    endif
                endif
            endif
        endif

        set i[0] = LoadInteger(ElixirGroupData, StringHash("Elixir"), i[0])
        set i[1] = LoadInteger(ElixirGroupData, StringHash("Elixir"), i[1])
        set i[2] = LoadInteger(ElixirGroupData, StringHash("Elixir"), i[2])
        set i[3] = LoadInteger(ElixirGroupData, StringHash("Elixir"), i[3])
        set i[4] = LoadInteger(ElixirGroupData, StringHash("Elixir"), i[4])
        set i[5] = LoadInteger(ElixirGroupData, StringHash("Elixir"), i[5])
        set i[6] = LoadInteger(ElixirGroupData, StringHash("Elixir"), i[6])
        set i[7] = LoadInteger(ElixirGroupData, StringHash("Elixir"), i[7])

        
        // 1부터 6까지의 값(체크할 값)에 대해 반복합니다.
        set j = 1
        loop
            exitwhen j > 56
            
            // 해당 값이 발견되었는지 여부를 체크하는 변수입니다.
            set found = false
            
            // 배열 i를 순회하며 j의 값이 있는지 확인합니다.
            set k = 0
            loop
                exitwhen k > 7
                if i[k] == j then
                    set found = true
                    // 값을 찾았으므로 내부 루프를 종료합니다.
                    exitwhen true
                endif
                set k = k + 1
            endloop
            
            // 만약 해당 값(j)이 배열 i에 없었다면, ElixirSelect에 추가합니다.
            if found == false then
                if j == 1 then
                    if ElixirGroup[1] == false and ElixirGroup[6] == false and ElixirGroup[16] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(7, Elixirweight[7])
                        call ElixirSelect.add(13, Elixirweight[13])
                    endif
                elseif j == 2 then
                    if ElixirGroup[2] == false and ElixirGroup[7] == false and ElixirGroup[17] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(8, Elixirweight[8])
                        call ElixirSelect.add(14, Elixirweight[14])
                    endif
                elseif j == 3 then
                    if ElixirGroup[3] == false and ElixirGroup[8] == false and ElixirGroup[18] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(9, Elixirweight[9])
                        call ElixirSelect.add(15, Elixirweight[15])
                    endif
                elseif j == 4 then
                    if ElixirGroup[4] == false and ElixirGroup[9] == false and ElixirGroup[19] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(10, Elixirweight[10])
                        call ElixirSelect.add(17, Elixirweight[17])
                    endif
                elseif j == 5 then
                    if ElixirGroup[5] == false and ElixirGroup[10] == false and ElixirGroup[20] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(11, Elixirweight[11])
                        call ElixirSelect.add(18, Elixirweight[18])
                    endif
                elseif j == 6 then
                    if ElixirGroup[21] == false then
                        call ElixirSelect.add(12, Elixirweight[12])
                        call ElixirSelect.add(18, Elixirweight[18])
                    endif
                elseif j == 7 then
                    if ElixirGroup[1] == false and ElixirGroup[11] == false and ElixirGroup[16] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(19, Elixirweight[19])
                        call ElixirSelect.add(25, Elixirweight[25])
                    endif
                elseif j == 8 then
                    if ElixirGroup[2] == false and ElixirGroup[12] == false and ElixirGroup[17] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(20, Elixirweight[20])
                        call ElixirSelect.add(26, Elixirweight[26])
                    endif
                elseif j == 9 then
                    if ElixirGroup[3] == false and ElixirGroup[13] == false and ElixirGroup[18] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(21, Elixirweight[21])
                        call ElixirSelect.add(27, Elixirweight[27])
                    endif
                elseif j == 10 then
                    if ElixirGroup[4] == false and ElixirGroup[14] == false and ElixirGroup[19] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(22, Elixirweight[22])
                        call ElixirSelect.add(28, Elixirweight[28])
                    endif
                elseif j == 11 then
                    if ElixirGroup[5] == false and ElixirGroup[15] == false and ElixirGroup[20] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(23, Elixirweight[23])
                        call ElixirSelect.add(29, Elixirweight[29])
                    endif
                elseif j == 12 then
                    if ElixirGroup[21] == false then
                        call ElixirSelect.add(24, Elixirweight[24])
                        call ElixirSelect.add(30, Elixirweight[30])
                    endif
                elseif j == 13 then
                    if ElixirGroup[1] == false and ElixirGroup[11] == false and ElixirGroup[16] == false and ElixirGroup[24] == false then
                        call ElixirSelect.add(31, Elixirweight[31])
                        call ElixirSelect.add(37, Elixirweight[37])
                        call ElixirSelect.add(43, Elixirweight[43])
                    endif
                elseif j == 14 then
                    if ElixirGroup[2] == false and ElixirGroup[12] == false and ElixirGroup[17] == false and ElixirGroup[25] == false then
                        call ElixirSelect.add(32, Elixirweight[32])
                        call ElixirSelect.add(38, Elixirweight[38])
                        call ElixirSelect.add(44, Elixirweight[44])
                    endif
                elseif j == 15 then
                    if ElixirGroup[3] == false and ElixirGroup[13] == false and ElixirGroup[18] == false and ElixirGroup[26] == false then
                        call ElixirSelect.add(33, Elixirweight[33])
                        call ElixirSelect.add(39, Elixirweight[39])
                        call ElixirSelect.add(45, Elixirweight[45])
                    endif
                elseif j == 16 then
                    if ElixirGroup[4] == false and ElixirGroup[14] == false and ElixirGroup[19] == false and ElixirGroup[27] == false then
                        call ElixirSelect.add(34, Elixirweight[34])
                        call ElixirSelect.add(40, Elixirweight[40])
                        call ElixirSelect.add(46, Elixirweight[46])
                    endif
                elseif j == 17 then
                    if ElixirGroup[5] == false and ElixirGroup[15] == false and ElixirGroup[20] == false and ElixirGroup[28] == false then
                        call ElixirSelect.add(35, Elixirweight[35])
                        call ElixirSelect.add(41, Elixirweight[41])
                        call ElixirSelect.add(47, Elixirweight[47])
                    endif
                elseif j == 18 then
                    if ElixirGroup[29] == false then
                        call ElixirSelect.add(36, Elixirweight[36])
                        call ElixirSelect.add(42, Elixirweight[42])
                        call ElixirSelect.add(48, Elixirweight[48])
                    endif
                elseif j == 19 then
                    if ElixirGroup[29] == false then
                        call ElixirSelect.add(49, Elixirweight[49])
                        call ElixirSelect.add(50, Elixirweight[50])
                        call ElixirSelect.add(51, Elixirweight[51])
                    endif
                elseif j == 20 then
                    if ElixirGroup[1] == false and ElixirGroup[6] == false and ElixirGroup[16] == false then
                        call ElixirSelect.add(52, Elixirweight[52])
                        call ElixirSelect.add(58, Elixirweight[58])
                    endif
                elseif j == 21 then
                    if ElixirGroup[2] == false and ElixirGroup[7] == false and ElixirGroup[17] == false then
                        call ElixirSelect.add(53, Elixirweight[53])
                        call ElixirSelect.add(59, Elixirweight[59])
                    endif
                elseif j == 22 then
                    if ElixirGroup[3] == false and ElixirGroup[8] == false and ElixirGroup[18] == false then
                        call ElixirSelect.add(54, Elixirweight[54])
                        call ElixirSelect.add(60, Elixirweight[60])
                    endif
                elseif j == 23 then
                    if ElixirGroup[4] == false and ElixirGroup[9] == false and ElixirGroup[19] == false then
                        call ElixirSelect.add(55, Elixirweight[55])
                        call ElixirSelect.add(61, Elixirweight[61])
                    endif
                elseif j == 24 then
                    if ElixirGroup[5] == false and ElixirGroup[10] == false and ElixirGroup[20] == false then
                        call ElixirSelect.add(56, Elixirweight[56])
                        call ElixirSelect.add(62, Elixirweight[62])
                    endif
                elseif j == 25 then
                    //선택연성
                    call ElixirSelect.add(57, Elixirweight[57])
                    call ElixirSelect.add(63, Elixirweight[63])
                elseif j == 26 then
                    if ElixirGroup[1] == false and ElixirGroup[16] == false then
                        call ElixirSelect.add(65, Elixirweight[65])
                        call ElixirSelect.add(71, Elixirweight[71])
                        call ElixirSelect.add(77, Elixirweight[77])
                    endif
                elseif j == 27 then
                    if ElixirGroup[2] == false and ElixirGroup[17] == false then
                        call ElixirSelect.add(66, Elixirweight[66])
                        call ElixirSelect.add(72, Elixirweight[72])
                        call ElixirSelect.add(78, Elixirweight[78])
                    endif
                elseif j == 28 then
                    if ElixirGroup[3] == false and ElixirGroup[18] == false then
                        call ElixirSelect.add(67, Elixirweight[67])
                        call ElixirSelect.add(73, Elixirweight[73])
                        call ElixirSelect.add(79, Elixirweight[79])
                    endif
                elseif j == 29 then
                    if ElixirGroup[4] == false and ElixirGroup[19] == false then
                        call ElixirSelect.add(68, Elixirweight[68])
                        call ElixirSelect.add(74, Elixirweight[74])
                        call ElixirSelect.add(80, Elixirweight[80])
                    endif
                elseif j == 30 then
                    if ElixirGroup[5] == false and ElixirGroup[20] == false then
                        call ElixirSelect.add(69, Elixirweight[69])
                        call ElixirSelect.add(75, Elixirweight[75])
                        call ElixirSelect.add(81, Elixirweight[81])
                    endif
                elseif j == 31 then
                    //선택 단계 상승
                    call ElixirSelect.add(70, Elixirweight[70])
                    call ElixirSelect.add(76, Elixirweight[76])
                    call ElixirSelect.add(82, Elixirweight[82])
                elseif j == 32 then
                    if ElixirGroup[1] == false and ElixirGroup[16] == false then
                        call ElixirSelect.add(83, Elixirweight[83])
                        call ElixirSelect.add(89, Elixirweight[89])
                    endif
                elseif j == 33 then
                    if ElixirGroup[2] == false and ElixirGroup[17] == false then
                        call ElixirSelect.add(84, Elixirweight[84])
                        call ElixirSelect.add(90, Elixirweight[90])
                    endif
                elseif j == 34 then
                    if ElixirGroup[3] == false and ElixirGroup[18] == false then
                        call ElixirSelect.add(85, Elixirweight[85])
                        call ElixirSelect.add(91, Elixirweight[91])
                    endif
                elseif j == 35 then
                    if ElixirGroup[4] == false and ElixirGroup[19] == false then
                        call ElixirSelect.add(86, Elixirweight[86])
                        call ElixirSelect.add(92, Elixirweight[92])
                    endif
                elseif j == 36 then
                    if ElixirGroup[5] == false and ElixirGroup[20] == false then
                        call ElixirSelect.add(87, Elixirweight[87])
                        call ElixirSelect.add(93, Elixirweight[93])
                    endif
                elseif j == 37 then
                    //선택효과 단계확률상승
                    call ElixirSelect.add(88, Elixirweight[88])
                    call ElixirSelect.add(94, Elixirweight[94])
                elseif j == 38 then
                    if ElixirGroup[1] == false and ElixirGroup[16] == false then
                        call ElixirSelect.add(95, Elixirweight[95])
                        call ElixirSelect.add(101, Elixirweight[101])
                    endif
                elseif j == 39 then
                    if ElixirGroup[2] == false and ElixirGroup[17] == false then
                        call ElixirSelect.add(96, Elixirweight[96])
                        call ElixirSelect.add(102, Elixirweight[102])
                    endif
                elseif j == 40 then
                    if ElixirGroup[3] == false and ElixirGroup[18] == false then
                        call ElixirSelect.add(97, Elixirweight[97])
                        call ElixirSelect.add(103, Elixirweight[103])
                    endif
                elseif j == 41 then
                    if ElixirGroup[4] == false and ElixirGroup[19] == false then
                        call ElixirSelect.add(98, Elixirweight[98])
                        call ElixirSelect.add(104, Elixirweight[104])
                    endif
                elseif j == 42 then
                    if ElixirGroup[5] == false and ElixirGroup[20] == false then
                        call ElixirSelect.add(99, Elixirweight[99])
                        call ElixirSelect.add(105, Elixirweight[105])
                    endif
                elseif j == 43 then
                    //선택효과 단계확률상승
                    call ElixirSelect.add(100, Elixirweight[100])
                    call ElixirSelect.add(106, Elixirweight[106])
                elseif j == 44 then
                    if ElixirGroup[1] == false and ElixirGroup[16] == false then
                        call ElixirSelect.add(107, Elixirweight[107])
                        call ElixirSelect.add(113, Elixirweight[113])
                    endif
                elseif j == 45 then
                    if ElixirGroup[2] == false and ElixirGroup[17] == false then
                        call ElixirSelect.add(108, Elixirweight[108])
                        call ElixirSelect.add(114, Elixirweight[114])
                    endif
                elseif j == 46 then
                    if ElixirGroup[3] == false and ElixirGroup[18] == false then
                        call ElixirSelect.add(109, Elixirweight[109])
                        call ElixirSelect.add(115, Elixirweight[115])
                    endif
                elseif j == 47 then
                    if ElixirGroup[4] == false and ElixirGroup[19] == false then
                        call ElixirSelect.add(110, Elixirweight[110])
                        call ElixirSelect.add(116, Elixirweight[116])
                    endif
                elseif j == 48 then
                    if ElixirGroup[5] == false and ElixirGroup[20] == false then
                        call ElixirSelect.add(111, Elixirweight[111])
                        call ElixirSelect.add(117, Elixirweight[117])
                    endif
                elseif j == 49 then
                    //선택효과 단계확률상승
                    call ElixirSelect.add(112, Elixirweight[112])
                    call ElixirSelect.add(118, Elixirweight[118])
                elseif j == 50 then
                    //임의 1개 단계 상승
                    call ElixirSelect.add(119, Elixirweight[119])
                    call ElixirSelect.add(120, Elixirweight[120])
                    call ElixirSelect.add(121, Elixirweight[121])
                elseif j == 51 then
                    //최하 단계 효과 1개의 단계 상승
                    if ElixirGroup[30] == false then
                        call ElixirSelect.add(122, Elixirweight[122])
                        call ElixirSelect.add(123, Elixirweight[123])
                        call ElixirSelect.add(124, Elixirweight[124])
                    endif
                elseif j == 52 then
                    //최고 단계 효과 1개의 단계 상승
                    if ElixirGroup[30] == false and ElixirGroup[31] == false then
                        call ElixirSelect.add(125, Elixirweight[125])
                        call ElixirSelect.add(126, Elixirweight[126])
                        call ElixirSelect.add(127, Elixirweight[127])
                    endif
                elseif j == 53 then
                    call ElixirSelect.add(129, Elixirweight[129])
                    call ElixirSelect.add(130, Elixirweight[130])
                    call ElixirSelect.add(131, Elixirweight[131])
                elseif j == 54 then
                    if ElixirGroup[21] == false then
                        call ElixirSelect.add(132, Elixirweight[132])
                    endif
                    if ElixirGroup[22] == false then
                        call ElixirSelect.add(133, Elixirweight[133])
                    endif
                    if ElixirGroup[23] == false then
                        call ElixirSelect.add(134, Elixirweight[134])
                    endif
                elseif j == 55 then
                    call ElixirSelect.add(135, Elixirweight[135])
                    call ElixirSelect.add(136, Elixirweight[136])
                elseif j == 56 then
                    if ElixirGroup[32] == false then
                        //call ElixirSelect.add(128, Elixirweight[128])
                    endif
                elseif j == 57 then
                    call ElixirSelect.add(64, Elixirweight[64])
                endif
            endif
            
            set j = j + 1
        endloop
///*
        //set NowCount[pid] = 10

        set a = ElixirSelect.pick(true)
        set b = ElixirSelect.pick(true)
        set c = ElixirSelect.pick(true)
        call ElixirSelect.clear()
        
        if GetLocalPlayer() == Player(pid) then
            set NowSelectNumber2[1] = a
            call DzFrameSetText(El_SelectText[1], ElixirText[NowSelectNumber2[1]])
            set NowSelectNumber2[2] = b
            call DzFrameSetText(El_SelectText[2], ElixirText[NowSelectNumber2[2]])
            set NowSelectNumber2[3] = c
            call DzFrameSetText(El_SelectText[3], ElixirText[NowSelectNumber2[3]])
            
            call DzFrameSetText(El_MainR[1], R2SW(GetPathChance(pid,1),1,1)+"%")
            call DzFrameSetText(El_MainR[2], R2SW(GetPathChance(pid,2),1,1)+"%")
            call DzFrameSetText(El_MainR[3], R2SW(GetPathChance(pid,3),1,1)+"%")
            call DzFrameSetText(El_MainR[4], R2SW(GetPathChance(pid,4),1,1)+"%")
            call DzFrameSetText(El_MainR[5], R2SW(GetPathChance(pid,5),1,1)+"%")
            call DzFrameSetText(El_MainR2[1], "대성공 "+R2SW(El_RateLucky[pid][1],1,1)+"%")
            call DzFrameSetText(El_MainR2[2], "대성공 "+R2SW(El_RateLucky[pid][2],1,1)+"%")
            call DzFrameSetText(El_MainR2[3], "대성공 "+R2SW(El_RateLucky[pid][3],1,1)+"%")
            call DzFrameSetText(El_MainR2[4], "대성공 "+R2SW(El_RateLucky[pid][4],1,1)+"%")
            call DzFrameSetText(El_MainR2[5], "대성공 "+R2SW(El_RateLucky[pid][5],1,1)+"%")
            call DzFrameSetText(CountText, I2S(NowCount[pid])+"회 연성가능")
        endif
    endfunction

    private function GetMappedValue takes integer input returns integer
        if input <= 2 then
            return 0
        elseif input <= 5 then
            return 1
        elseif input <= 7 then
            return 2
        elseif input == 8 then
            return 3
        elseif input == 9 then
            return 4
        elseif input == 10 then
            return 5
        else
            // 정의되지 않은 입력값에 대한 기본값
            return 0
        endif
    endfunction

    private function EffectFunction takes nothing returns nothing
        local tick t = tick.getExpired()
        local ElixirSt st = t.data

        if GetLocalPlayer() == Player(st.pid) then
            call DzFrameShow(El_BackDrop, false)
            call DzFrameShow(El_BackDrop2, true)

            call DzFrameSetText(EL_LevelTextA, I2S(GetMappedValue(st.i)) + " + " + I2S(GetMappedValue(st.j)))
            call DzFrameSetText(EL_LevelTextB, I2S(GetMappedValue(st.i)) + " + " + I2S(GetMappedValue(st.j)))
            set ResultLevel[st.pid][1] = GetMappedValue(st.i)
            set ResultLevel[st.pid][2] = GetMappedValue(st.j)

            set si2 = si2 + 1
            if si2 == 1 then
                call StartSound(gg_snd_ElEffectSound00)
                call DzFrameSetModel(EL_LevelEffect1, "blinknew180.mdx", 0, 0)
                call DzFrameSetModel(EL_LevelEffect2, "blinknew180.mdx", 0, 0)
            elseif si2 == 2 then
                call StartSound(gg_snd_ElEffectSound01)
                call DzFrameSetModel(EL_LevelEffect1, "blinknew180.mdx", 0, 0)
                call DzFrameSetModel(EL_LevelEffect2, "blinknew180.mdx", 0, 0)
            elseif si2 == 3 then
                call StartSound(gg_snd_ElEffectSound02)
                call DzFrameSetModel(EL_LevelEffect1, "blinknew180.mdx", 0, 0)
                call DzFrameSetModel(EL_LevelEffect2, "blinknew180.mdx", 0, 0)
                set si2 = 0
            endif
        endif

        call t.destroy()
        call st.destroy()
    endfunction
    
    private function Select2 takes nothing returns nothing
        local string s = DzGetTriggerSyncData()
        local integer pid = GetPlayerId(DzGetTriggerSyncPlayer())
        local integer path = 0
        local real r = GetRandomReal(0.0, 100.0)
        local integer i = 0
        local integer j = 0
        local integer k = 0
        //조언번호
        local integer SelectAdvice = S2I(JNStringSplit(s, "\t", 0))
        //몇번째 버튼
        local integer SelectNumber = S2I(JNStringSplit(s, "\t", 1))
        local tick t
        local ElixirSt st

        //두번클릭방지
        if GetLocalPlayer() == Player(pid) then
            set NowSelectNumber = 0 
            set NowMainSelect = 0
        endif

        //카운트감소
        set NowCount[pid] = NowCount[pid] - 1
        if GetLocalPlayer() == Player(pid) then
            //사운드재생
            set si2 = si2 + 1
            if si2 == 1 then
                call StartSound(gg_snd_ElEffectSound00)
            elseif si2 == 2 then
                call StartSound(gg_snd_ElEffectSound01)
            elseif si2 == 3 then
                call StartSound(gg_snd_ElEffectSound02)
                set si2 = 0
            endif
            call DzFrameSetText(CountText, I2S(NowCount[pid])+"회 연성가능")
        endif

        if SelectAdvice == 1 then
            call RemovePath(pid, 1)
            call DzFrameShow(ElF_Lock[1], true)
            set El_Lock[pid][1] = 1
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 2 then
            call RemovePath(pid, 2)
            call DzFrameShow(ElF_Lock[2], true)
            set El_Lock[pid][2] = 1
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 3 then
            call RemovePath(pid, 3)
            call DzFrameShow(ElF_Lock[3], true)
            set El_Lock[pid][3] = 1
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 4 then
            call RemovePath(pid, 4)
            call DzFrameShow(ElF_Lock[4], true)
            set El_Lock[pid][4] = 1
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 5 then
            call RemovePath(pid, 5)
            call DzFrameShow(ElF_Lock[5], true)
            set El_Lock[pid][5] = 1
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 6 then
            call RemovePath(pid, SelectNumber)
            call DzFrameShow(ElF_Lock[SelectNumber], true)
            set El_Lock[pid][SelectNumber] = 1
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 7 then
            call RemovePath(pid, SelectNumber)
            call DzFrameShow(ElF_Lock[SelectNumber], true)
            set El_Lock[pid][SelectNumber] = 1
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
            set path = GetRandomPath(pid)
            call DzFrameShow(ElF_Lock[SelectNumber], true)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 8 then
            call RemovePath(pid, SelectNumber)
            call DzFrameShow(ElF_Lock[SelectNumber], true)
            set El_Lock[pid][SelectNumber] = 1

            set i = 1
            set j = 100
            set k = 0
        
            loop 
                // i는 1부터 5까지 반복
                exitwhen i > 5
                if El_Level[pid][i] < j and El_Lock[pid][i] == 0 then
                    // 현재 값이 가장 낮으면 값과 인덱스를 갱신
                    set j = El_Level[pid][i]
                    set k = i
                endif
                set i = i + 1
            endloop

            set path = k
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif

            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        endif
        //갱신
        if GetLocalPlayer() == Player(pid) then
            call DzFrameSetText(El_MainR[1], R2SW(GetPathChance(pid,1),1,1)+"%")
            call DzFrameSetText(El_MainR[2], R2SW(GetPathChance(pid,2),1,1)+"%")
            call DzFrameSetText(El_MainR[3], R2SW(GetPathChance(pid,3),1,1)+"%")
            call DzFrameSetText(El_MainR[4], R2SW(GetPathChance(pid,4),1,1)+"%")
            call DzFrameSetText(El_MainR[5], R2SW(GetPathChance(pid,5),1,1)+"%")
        endif
        if NowCount[pid] != 0 then
            call Roll4(pid)
        else
            if El_Level[pid][1] > 10 then
                set El_Level[pid][1] = 10
            endif
            if El_Level[pid][2] > 10 then
                set El_Level[pid][2] = 10
            endif
            if El_Level[pid][3] > 10 then
                set El_Level[pid][3] = 10
            endif
            if El_Level[pid][4] > 10 then
                set El_Level[pid][4] = 10
            endif
            if El_Level[pid][5] > 10 then
                set El_Level[pid][5] = 10
            endif

            set t = tick.create(0)
            set st = ElixirSt.create()
            set st.i = GetRandomPath(pid)
            call RemovePath(pid, st.i)
            set st.i = El_Level[pid][st.i]

            set st.j = GetRandomPath(pid)
            call RemovePath(pid, st.j)
            set st.j = El_Level[pid][st.j]

            set t.data = st
            set st.pid = pid
            call t.start( 2.0, false, function EffectFunction )
        endif
    endfunction

    private function Select takes nothing returns nothing
        local string s = DzGetTriggerSyncData()
        local integer pid = GetPlayerId(DzGetTriggerSyncPlayer())
        local integer path = 0
        local real r = GetRandomReal(0.0, 100.0)
        local integer ri1 = GetRandomInt(0,2)
        local integer ri2 = GetRandomInt(0,3)
        local integer ri3 = GetRandomInt(0,4)
        local integer ri4 = GetRandomInt(1,5)
        local integer i = 0
        local integer j = 0
        local integer k = 0
        //조언번호
        local integer SelectAdvice = S2I(JNStringSplit(s, "\t", 0))
        //몇번째 버튼
        local integer SelectNumber = S2I(JNStringSplit(s, "\t", 2))
        //지금까지 고른 조언 갱신
        set SelectString[pid] = JNStringSplit(s, "\t", 1)

        //두번클릭방지
        if GetLocalPlayer() == Player(pid) then
            set NowSelectNumber = 0 
            set NowMainSelect = 0
        endif

        //카운트감소
        set NowCount[pid] = NowCount[pid] - 1
        if GetLocalPlayer() == Player(pid) then
            //사운드재생
            set si2 = si2 + 1
            if si2 == 1 then
                call StartSound(gg_snd_ElEffectSound00)
            elseif si2 == 2 then
                call StartSound(gg_snd_ElEffectSound01)
            elseif si2 == 3 then
                call StartSound(gg_snd_ElEffectSound02)
                set si2 = 0
            endif
            call DzFrameSetText(CountText, I2S(NowCount[pid])+"회 연성가능")
        endif

        if SelectAdvice == 1 then
            call SetPathChance(pid, 1, GetPathChance(pid,1) + 50.0 )
            set path = GetRandomPath(pid)
            call SetPathChance(pid, 1, GetPathChance(pid,1) - 50.0 )
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 2 then
            call SetPathChance(pid, 2, GetPathChance(pid,2) + 50.0 )
            set path = GetRandomPath(pid)
            call SetPathChance(pid, 2, GetPathChance(pid,2) - 50.0 )
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 3 then
            call SetPathChance(pid, 3, GetPathChance(pid,3) + 50.0 )
            set path = GetRandomPath(pid)
            call SetPathChance(pid, 3, GetPathChance(pid,3) - 50.0 )
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 4 then
            call SetPathChance(pid, 4, GetPathChance(pid,4) + 50.0 )
            set path = GetRandomPath(pid)
            call SetPathChance(pid, 4, GetPathChance(pid,4) - 50.0 )
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 5 then
            call SetPathChance(pid, 5, GetPathChance(pid,5) + 50.0 )
            set path = GetRandomPath(pid)
            call SetPathChance(pid, 5, GetPathChance(pid,5) - 50.0 )
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 6 then
            call SetPathChance(pid, SelectNumber, GetPathChance(pid,SelectNumber) + 50.0 )
            set path = GetRandomPath(pid)
            call SetPathChance(pid, SelectNumber, GetPathChance(pid,SelectNumber) - 50.0 )
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 7 then
            call SetPathChance(pid, 1, GetPathChance(pid,1) + 10.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 8 then
            call SetPathChance(pid, 2, GetPathChance(pid,2) + 10.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 9 then
            call SetPathChance(pid, 3, GetPathChance(pid,3) + 10.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 10 then
            call SetPathChance(pid, 4, GetPathChance(pid,4) + 10.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 11 then
            call SetPathChance(pid, 5, GetPathChance(pid,5) + 10.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 12 then
            call SetPathChance(pid, SelectNumber, GetPathChance(pid,SelectNumber) + 10.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 13 then
            call SetPathChance(pid, 1, GetPathChance(pid,1) + 20.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 14 then
            call SetPathChance(pid, 2, GetPathChance(pid,2) + 20.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 15 then
            call SetPathChance(pid, 3, GetPathChance(pid,3) + 20.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 16 then
            call SetPathChance(pid, 4, GetPathChance(pid,4) + 20.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 17 then
            call SetPathChance(pid, 5, GetPathChance(pid,5) + 20.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 18 then
            call SetPathChance(pid, SelectNumber, GetPathChance(pid,SelectNumber) + 20.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 19 then
            call SetPathChance(pid, 1, GetPathChance(pid,1) - 10.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 20 then
            call SetPathChance(pid, 2, GetPathChance(pid,2) - 10.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 21 then
            call SetPathChance(pid, 3, GetPathChance(pid,3) - 10.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 22 then
            call SetPathChance(pid, 4, GetPathChance(pid,4) - 10.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 23 then
            call SetPathChance(pid, 5, GetPathChance(pid,5) - 10.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 24 then
            call SetPathChance(pid, SelectNumber, GetPathChance(pid,SelectNumber) - 10.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 25 then
            call SetPathChance(pid, 1, GetPathChance(pid,1) - 20.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 26 then
            call SetPathChance(pid, 2, GetPathChance(pid,2) - 20.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 27 then
            call SetPathChance(pid, 3, GetPathChance(pid,3) - 20.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 28 then
            call SetPathChance(pid, 4, GetPathChance(pid,4) - 20.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 29 then
            call SetPathChance(pid, 5, GetPathChance(pid,5) - 20.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 30 then
            call SetPathChance(pid, SelectNumber, GetPathChance(pid,SelectNumber) - 20.0 )
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        endif

        if SelectAdvice == 31 then
            set El_RateLucky[pid][1] = El_RateLucky[pid][1] + 15
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 32 then
            set El_RateLucky[pid][2] = El_RateLucky[pid][2] + 15
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 33 then
            set El_RateLucky[pid][3] = El_RateLucky[pid][3] + 15
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 34 then
            set El_RateLucky[pid][4] = El_RateLucky[pid][4] + 15
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 35 then
            set El_RateLucky[pid][5] = El_RateLucky[pid][5] + 15
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 36 then
            set El_RateLucky[pid][SelectNumber] = El_RateLucky[pid][SelectNumber] + 15
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 37 then
            set El_RateLucky[pid][1] = El_RateLucky[pid][1] + 30
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 38 then
            set El_RateLucky[pid][2] = El_RateLucky[pid][2] + 30
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 39 then
            set El_RateLucky[pid][3] = El_RateLucky[pid][3] + 30
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 40 then
            set El_RateLucky[pid][4] = El_RateLucky[pid][4] + 30
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 41 then
            set El_RateLucky[pid][5] = El_RateLucky[pid][5] + 30
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 42 then
            set El_RateLucky[pid][SelectNumber] = El_RateLucky[pid][SelectNumber] + 30
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 43 then
            set El_RateLucky[pid][1] = El_RateLucky[pid][1] + 45
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 44 then
            set El_RateLucky[pid][2] = El_RateLucky[pid][2] + 45
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 45 then
            set El_RateLucky[pid][3] = El_RateLucky[pid][3] + 45
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 46 then
            set El_RateLucky[pid][4] = El_RateLucky[pid][4] + 45
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 47 then
            set El_RateLucky[pid][5] = El_RateLucky[pid][5] + 45
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 48 then
            set El_RateLucky[pid][SelectNumber] = El_RateLucky[pid][SelectNumber] + 45
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 49 then
            set El_RateLucky[pid][1] = El_RateLucky[pid][1] + 10
            set El_RateLucky[pid][2] = El_RateLucky[pid][2] + 10
            set El_RateLucky[pid][3] = El_RateLucky[pid][3] + 10
            set El_RateLucky[pid][4] = El_RateLucky[pid][4] + 10
            set El_RateLucky[pid][5] = El_RateLucky[pid][5] + 10
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 50 then
            set El_RateLucky[pid][1] = El_RateLucky[pid][1] + 20
            set El_RateLucky[pid][2] = El_RateLucky[pid][2] + 20
            set El_RateLucky[pid][3] = El_RateLucky[pid][3] + 20
            set El_RateLucky[pid][4] = El_RateLucky[pid][4] + 20
            set El_RateLucky[pid][5] = El_RateLucky[pid][5] + 20
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 51 then
            set El_RateLucky[pid][1] = El_RateLucky[pid][1] + 30
            set El_RateLucky[pid][2] = El_RateLucky[pid][2] + 30
            set El_RateLucky[pid][3] = El_RateLucky[pid][3] + 30
            set El_RateLucky[pid][4] = El_RateLucky[pid][4] + 30
            set El_RateLucky[pid][5] = El_RateLucky[pid][5] + 30
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 52 then
            set path = 1
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 53 then
            set path = 2
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 54 then
            set path = 3
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 55 then
            set path = 4
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 56 then
            set path = 5
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 57 then
            set path = SelectNumber
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 58 then
            set path = 1
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 59 then
            set path = 2
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 60 then
            set path = 3
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 61 then
            set path = 4
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 62 then
            set path = 5
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 63 then
            set path = SelectNumber
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        //기회소모X
        elseif SelectAdvice == 64 then
            set path = GetRandomPath(pid)
            set NowCount[pid] = NowCount[pid] + 1
            call DzFrameSetText(CountText, I2S(NowCount[pid])+"회 연성가능")
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        endif
        if SelectAdvice == 65 then
            set path = 1
            if ri1 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri1 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if El_Level[pid][path] == 11 then
                        set El_Level[pid][path] = 10
                    endif
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 66 then
            set path = 2
            if ri1 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri1 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if El_Level[pid][path] == 11 then
                        set El_Level[pid][path] = 10
                    endif
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 67 then
            set path = 3
            if ri1 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri1 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if El_Level[pid][path] == 11 then
                        set El_Level[pid][path] = 10
                    endif
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 68 then
            set path = 4
            if ri1 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri1 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if El_Level[pid][path] == 11 then
                        set El_Level[pid][path] = 10
                    endif
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 69 then
            set path = 5
            if ri1 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri1 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if El_Level[pid][path] == 11 then
                        set El_Level[pid][path] = 10
                    endif
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 70 then
            set path = SelectNumber
            if ri1 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri1 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if El_Level[pid][path] == 11 then
                        set El_Level[pid][path] = 10
                    endif
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 71 then
            set path = 1
            if ri2 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri2 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri2 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if El_Level[pid][path] == 11 then
                        set El_Level[pid][path] = 10
                    endif
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 72 then
            set path = 2
            if ri2 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri2 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri2 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 73 then
            set path = 3
            if ri2 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri2 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri2 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 74 then
            set path = 4
            if ri2 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri2 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri2 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 75 then
            set path = 5
            if ri2 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri2 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri2 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 76 then
            set path = SelectNumber
            if ri2 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri2 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri2 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        endif
        //0~4
        if SelectAdvice == 77 then
            set path = 1
            if ri3 == 4 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri3 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri3 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri3 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if El_Level[pid][path] == 11 then
                        set El_Level[pid][path] = 10
                    endif
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 78 then
            set path = 2
            if ri3 == 4 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri3 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri3 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri3 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 79 then
            set path = 3
            if ri3 == 4 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri3 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri3 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri3 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 80 then
            set path = 4
            if ri3 == 4 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri3 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri3 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri3 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 81 then
            set path = 5
            if ri3 == 4 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri3 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri3 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri3 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 82 then
            set path = SelectNumber
            if ri3 == 4 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri3 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri3 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            elseif ri3 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        //
        elseif SelectAdvice == 83 then
            set path = 1
            //0123중에 3 25%
            if ri2 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif

            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if El_Level[pid][path] == 11 then
                        set El_Level[pid][path] = 10
                    endif
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 84 then
            set path = 2
            if ri2 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 85 then
            set path = 3
            if ri2 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 86 then
            set path = 4
            if ri2 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 87 then
            set path = 5
            if ri2 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 88 then
            set path = SelectNumber
            if ri2 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 89 then
            set path = 1
            //0123중에 3 25%
            if ri2 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif

            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if El_Level[pid][path] == 11 then
                        set El_Level[pid][path] = 10
                    endif
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 90 then
            set path = 2
            if ri2 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 91 then
            set path = 3
            if ri2 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 92 then
            set path = 4
            if ri2 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 93 then
            set path = 5
            if ri2 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 94 then
            set path = SelectNumber
            if ri2 == 3 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 95 then
            set path = 1
            //0123중에 3 25%
            if ri2 == 0 or ri2 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif

            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if El_Level[pid][path] == 11 then
                        set El_Level[pid][path] = 10
                    endif
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 96 then
            set path = 2
            if ri2 == 0 or ri2 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 97 then
            set path = 3
            if ri2 == 0 or ri2 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 98 then
            set path = 4
            if ri2 == 0 or ri2 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 99 then
            set path = 5
            if ri2 == 0 or ri2 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 100 then
            set path = SelectNumber
            if ri2 == 0 or ri2 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 101 then
            set path = 1
            //0123중에 3 25%
            if ri2 == 0 or ri2 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif

            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if El_Level[pid][path] == 11 then
                        set El_Level[pid][path] = 10
                    endif
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 102 then
            set path = 2
            if ri2 == 0 or ri2 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 103 then
            set path = 3
            if ri2 == 0 or ri2 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 104 then
            set path = 4
            if ri2 == 0 or ri2 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 105 then
            set path = 5
            if ri2 == 0 or ri2 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 106 then
            set path = SelectNumber
            if ri2 == 0 or ri2 == 1 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 107 then
            set path = 1
            //0123중에 3 25%
            if ri2 == 0 or ri2 == 1 or ri2 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif

            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if El_Level[pid][path] == 11 then
                        set El_Level[pid][path] = 10
                    endif
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 108 then
            set path = 2
            if ri2 == 0 or ri2 == 1 or ri2 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 109 then
            set path = 3
            if ri2 == 0 or ri2 == 1 or ri2 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 110 then
            set path = 4
            if ri2 == 0 or ri2 == 1 or ri2 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 111 then
            set path = 5
            if ri2 == 0 or ri2 == 1 or ri2 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 112 then
            set path = SelectNumber
            if ri2 == 0 or ri2 == 1 or ri2 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 113 then
            set path = 1
            //0123중에 3 25%
            if ri2 == 0 or ri2 == 1 or ri2 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif

            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if El_Level[pid][path] == 11 then
                        set El_Level[pid][path] = 10
                    endif
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 114 then
            set path = 2
            if ri2 == 0 or ri2 == 1 or ri2 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 115 then
            set path = 3
            if ri2 == 0 or ri2 == 1 or ri2 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 116 then
            set path = 4
            if ri2 == 0 or ri2 == 1 or ri2 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 117 then
            set path = 5
            if ri2 == 0 or ri2 == 1 or ri2 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 118 then
            set path = SelectNumber
            if ri2 == 0 or ri2 == 1 or ri2 == 2 then
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
                set El_Level[pid][path] = El_Level[pid][path] + 1
                if El_Level[pid][path] == 11 then
                    set El_Level[pid][path] = 10
                endif
                if GetLocalPlayer() == Player(pid) then
                    call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                    call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
                endif
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 119 then
            set path = GetRandomPath2(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif

            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 120 then
            set path = GetRandomPath2(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 121 then
            set path = GetRandomPath2(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        //최하
        elseif SelectAdvice == 122 then
            set i = 1
            set j = 100
            set k = 0
        
            loop 
                // i는 1부터 5까지 반복
                exitwhen i > 5
                if El_Level[pid][i] < j then
                    // 현재 값이 가장 낮으면 값과 인덱스를 갱신
                    set j = El_Level[pid][i]
                    set k = i
                endif
                set i = i + 1
            endloop

            set path = k
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif

            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 123 then
            set i = 1
            set j = 100
            set k = 0
        
            loop 
                // i는 1부터 5까지 반복
                exitwhen i > 5
                if El_Level[pid][i] < j then
                    // 현재 값이 가장 낮으면 값과 인덱스를 갱신
                    set j = El_Level[pid][i]
                    set k = i
                endif
                set i = i + 1
            endloop

            set path = k
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 124 then
            set i = 1
            set j = 100
            set k = 0
        
            loop 
                // i는 1부터 5까지 반복
                exitwhen i > 5
                if El_Level[pid][i] < j then
                    // 현재 값이 가장 낮으면 값과 인덱스를 갱신
                    set j = El_Level[pid][i]
                    set k = i
                endif
                set i = i + 1
            endloop

            set path = k
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        //최고
        elseif SelectAdvice == 125 then
            set i = 1
            set j = -1
            set k = 0
        
            loop 
                // i는 1부터 5까지 반복
                exitwhen i > 5
                if El_Level[pid][i] < j and El_Level[pid][i] != 10 then
                    // 현재 값이 가장 높으면 값과 인덱스를 갱신
                    set j = El_Level[pid][i]
                    set k = i
                endif
                set i = i + 1
            endloop
    
            set path = k
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
    
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 126 then
            set i = 1
            set j = -1
            set k = 0
            
            loop 
                // i는 1부터 5까지 반복
                exitwhen i > 5
                if El_Level[pid][i] < j and El_Level[pid][i] != 10 then
                    // 현재 값이 가장 낮으면 값과 인덱스를 갱신
                    set j = El_Level[pid][i]
                    set k = i
                endif
                set i = i + 1
            endloop
    
            set path = k
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
         elseif SelectAdvice == 127 then
            set i = 1
            set j = -1
            set k = 0
            
            loop 
                // i는 1부터 5까지 반복
                exitwhen i > 5
                if El_Level[pid][i] < j and El_Level[pid][i] != 10 then
                    // 현재 값이 가장 낮으면 값과 인덱스를 갱신
                    set j = El_Level[pid][i]
                    set k = i
                endif
                set i = i + 1
            endloop
    
            set path = k
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 129 then
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 130 then
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 131 then
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if El_Level[pid][path] == 11 then
                set El_Level[pid][path] = 10
            endif
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 132 then
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
            if El_Level[pid][path] == 10 then
                call ZeroPathChance(pid,path)
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 133 then
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
            if El_Level[pid][path] == 10 then
                call ZeroPathChance(pid,path)
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
            if El_Level[pid][path] == 10 then
                call ZeroPathChance(pid,path)
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 134 then
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
            if El_Level[pid][path] == 10 then
                call ZeroPathChance(pid,path)
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
            if El_Level[pid][path] == 10 then
                call ZeroPathChance(pid,path)
            endif
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
            set NowRollCount[pid] = NowRollCount[pid] + 1
            call DzFrameSetText(El_RollT,"리롤("+I2S(NowRollCount[pid])+"회 남음)")
        endif

        if SelectAdvice == 135 then
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
        elseif SelectAdvice == 136 then
            set path = GetRandomPath(pid)
            set El_Level[pid][path] = El_Level[pid][path] + 1
            if GetLocalPlayer() == Player(pid) then
                call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew1800.mdx", 0, 0)
            endif
            if El_RateLucky[pid][path] >= r then
                if El_Level[pid][path] != 10 then
                    set El_Level[pid][path] = El_Level[pid][path] + 1
                    if GetLocalPlayer() == Player(pid) then
                        call DzFrameSetTexture(ElF_Level[path][El_Level[pid][path]], "UI_Arcana_Work2.blp", 0)
                        call DzFrameSetModel(ElixirEffect[path][El_Level[pid][path]], "blinknew18002.mdx", 0, 0)
                    endif
                endif
            endif
            set NowRollCount[pid] = NowRollCount[pid] + 2
            call DzFrameSetText(El_RollT,"리롤("+I2S(NowRollCount[pid])+"회 남음)")
        endif


        //10이면 확률0으로 세팅

        if El_Level[pid][1] == 10 then
            call ZeroPathChance(pid,1)
        endif
        if El_Level[pid][2] == 10 then
            call ZeroPathChance(pid,2)
        endif
        if El_Level[pid][3] == 10 then
            call ZeroPathChance(pid,3)
        endif
        if El_Level[pid][4] == 10 then
            call ZeroPathChance(pid,4)
        endif
        if El_Level[pid][5] == 10 then
            call ZeroPathChance(pid,5)
        endif
        
        //갱신
        if GetLocalPlayer() == Player(pid) then
            call DzFrameSetText(El_MainR[1], R2SW(GetPathChance(pid,1),1,1)+"%")
            call DzFrameSetText(El_MainR[2], R2SW(GetPathChance(pid,2),1,1)+"%")
            call DzFrameSetText(El_MainR[3], R2SW(GetPathChance(pid,3),1,1)+"%")
            call DzFrameSetText(El_MainR[4], R2SW(GetPathChance(pid,4),1,1)+"%")
            call DzFrameSetText(El_MainR[5], R2SW(GetPathChance(pid,5),1,1)+"%")
            call DzFrameSetText(El_MainR2[1], "대성공 "+R2SW(El_RateLucky[pid][1],1,1)+"%")
            call DzFrameSetText(El_MainR2[2], "대성공 "+R2SW(El_RateLucky[pid][2],1,1)+"%")
            call DzFrameSetText(El_MainR2[3], "대성공 "+R2SW(El_RateLucky[pid][3],1,1)+"%")
            call DzFrameSetText(El_MainR2[4], "대성공 "+R2SW(El_RateLucky[pid][4],1,1)+"%")
            call DzFrameSetText(El_MainR2[5], "대성공 "+R2SW(El_RateLucky[pid][5],1,1)+"%")
        endif
        if NowCount[pid] <= 3 then
            call Roll4(pid)
        else
            call Roll2(pid)
        endif
    endfunction

    private function Roll takes nothing returns nothing
        local string s = DzGetTriggerSyncData()
        local integer pid = GetPlayerId(DzGetTriggerSyncPlayer())
        local IntegerPool ElixirSelect = IntegerPool.Create()
        local integer array i
        local integer array l
        local real array m
        local integer j
        local integer k
        local boolean found
        local integer a
        local integer b
        local integer c
        local boolean array ElixirGroup
        local integer nonlockcount
        local integer Maxcount = 0
        local integer LuckCheck = 0
        local integer highlevel = 0

        set NowRollCount[pid] = NowRollCount[pid] - 1
        if GetLocalPlayer() == Player(pid) then
            call DzFrameSetText(El_RollT,"리롤("+I2S(NowRollCount[pid])+"회 남음)")
        endif

        set m[1] = El_RateLucky[pid][1]
        set m[2] = El_RateLucky[pid][2]
        set m[3] = El_RateLucky[pid][3]
        set m[4] = El_RateLucky[pid][4]
        set m[5] = El_RateLucky[pid][5]

        set SelectString[pid] = JNStringSplit(s, "\t", 0)

        ///*
        set i1[pid] = S2I(JNStringSplit(SelectString[pid], ";", 0))
        set i2[pid] = S2I(JNStringSplit(SelectString[pid], ";", 1))
        set i3[pid] = S2I(JNStringSplit(SelectString[pid], ";", 2))
        set i4[pid] = S2I(JNStringSplit(SelectString[pid], ";", 3))
        set i5[pid] = S2I(JNStringSplit(SelectString[pid], ";", 4))
        set i6[pid] = S2I(JNStringSplit(SelectString[pid], ";", 5))
        set i7[pid] = S2I(JNStringSplit(SelectString[pid], ";", 6))
        set i8[pid] = S2I(JNStringSplit(SelectString[pid], ";", 7))
        //*/

        set i[0] = i1[pid]
        set i[1] = i2[pid]
        set i[2] = i3[pid]
        set i[3] = i4[pid]
        set i[4] = i5[pid]
        set i[5] = i6[pid]
        set i[6] = i7[pid]
        set i[7] = i8[pid]

        set nonlockcount = 5
        //그룹 논리값 설정
        //봉인됨
        if El_Lock[pid][1] == 1 then
            set ElixirGroup[1] = true
            set nonlockcount = nonlockcount - 1
        endif
        if El_Lock[pid][2] == 1 then
            set ElixirGroup[2] = true
            set nonlockcount = nonlockcount - 1
        endif
        if El_Lock[pid][3] == 1 then
            set ElixirGroup[3] = true
            set nonlockcount = nonlockcount - 1
        endif
        if El_Lock[pid][4] == 1 then
            set ElixirGroup[4] = true
            set nonlockcount = nonlockcount - 1
        endif
        if El_Lock[pid][5] == 1 then
            set ElixirGroup[5] = true
            set nonlockcount = nonlockcount - 1
        endif
        //확률이100퍼
        if GetPathChance(pid,1) >= 100 then
            set ElixirGroup[6] = true
        endif
        if GetPathChance(pid,2) >= 100 then
            set ElixirGroup[7] = true
        endif
        if GetPathChance(pid,3) >= 100 then
            set ElixirGroup[8] = true
        endif
        if GetPathChance(pid,4) >= 100 then
            set ElixirGroup[9] = true
        endif
        if GetPathChance(pid,5) >= 100 then
            set ElixirGroup[10] = true
        endif
        //확률이0퍼
        if GetPathChance(pid,1) == 0 then
            set ElixirGroup[11] = true
        endif
        if GetPathChance(pid,2) == 0 then
            set ElixirGroup[12] = true
        endif
        if GetPathChance(pid,3) == 0 then
            set ElixirGroup[13] = true
        endif
        if GetPathChance(pid,4) == 0 then
            set ElixirGroup[14] = true
        endif
        if GetPathChance(pid,5) == 0 then
            set ElixirGroup[15] = true
        endif
        //연성단계가 최대치
        if El_Level[pid][1] == 10 then
            set ElixirGroup[16] = true
            //최대치면서 봉인되지않음
            if El_Lock[pid][1] != 1 then
                set Maxcount = Maxcount + 1
            endif
        endif
        if El_Level[pid][2] == 10 then
            set ElixirGroup[17] = true
            //최대치면서 봉인되지않음
            if El_Lock[pid][2] != 1 then
                set Maxcount = Maxcount + 1
            endif
        endif
        if El_Level[pid][3] == 10 then
            set ElixirGroup[18] = true
            if El_Lock[pid][3] != 1 then
                set Maxcount = Maxcount + 1
            endif
        endif
        if El_Level[pid][4] == 10 then
            set ElixirGroup[19] = true
            if El_Lock[pid][4] != 1 then
                set Maxcount = Maxcount + 1
            endif
        endif
        if El_Level[pid][5] == 10 then
            set ElixirGroup[20] = true
            if El_Lock[pid][5] != 1 then
                set Maxcount = Maxcount + 1
            endif
        endif
        //연성가능한 슬롯 갯수
        if nonlockcount-Maxcount <= 1 then
            set ElixirGroup[21] = true
        endif
        if nonlockcount-Maxcount <= 2 then
            set ElixirGroup[22] = true
        endif
        if nonlockcount-Maxcount <= 3 then
            set ElixirGroup[23] = true
        endif
        //대성공 확률 100%
        if m[1] >= 100.0 then
            set ElixirGroup[24] = true
            set LuckCheck = LuckCheck + 1
        endif
        if m[2] >= 100.0 then
            set ElixirGroup[25] = true
            set LuckCheck = LuckCheck + 1
        endif
        if m[3] >= 100.0 then
            set ElixirGroup[26] = true
            set LuckCheck = LuckCheck + 1
        endif
        if m[4] >= 100.0 then
            set ElixirGroup[27] = true
            set LuckCheck = LuckCheck + 1
        endif
        if m[5] >= 100.0 then
            set ElixirGroup[28] = true
            set LuckCheck = LuckCheck + 1
        endif
        //모든 번호의 연성 대성공 확률이 100%
        if LuckCheck == 5 then
            set ElixirGroup[29] = true
        endif
        //모든 번호의 연성 단계가 동일한 경우
        if El_Level[pid][1] == El_Level[pid][2] and El_Level[pid][2] == El_Level[pid][3] and El_Level[pid][3] == El_Level[pid][4] and El_Level[pid][4] == El_Level[pid][5] then
            set ElixirGroup[30] = true
        endif
        //최고 연성 단계가 연성 가능한 최대 단계
        set highlevel = El_Level[pid][1]
        if El_Level[pid][2] > highlevel then
            set highlevel = El_Level[pid][2]
        endif
        if El_Level[pid][3] > highlevel then
            set highlevel = El_Level[pid][3]
        endif
        if El_Level[pid][4] > highlevel then
            set highlevel = El_Level[pid][4]
        endif
        if El_Level[pid][5] > highlevel then
            set highlevel = El_Level[pid][5]
        endif
        if highlevel != 10 then
            set ElixirGroup[31] = true
        endif
        //모든 연성 단계의 합이 0
        if El_Level[pid][1] + El_Level[pid][2] + El_Level[pid][3] + El_Level[pid][4] + El_Level[pid][5] == 0 then
            set ElixirGroup[32] = true
        endif


        if i[0] != 1 and i[1] != 1 then 
            if i[2] != 1 and i[3] != 1 then
                if i[4] != 1 and i[5] != 1 then 
                    if i[6] != 1 and i[7] != 1 then
                        if ElixirGroup[1] == false and ElixirGroup[6] == false and ElixirGroup[16] == false and ElixirGroup[21] == false then
                            call ElixirSelect.add(1, Elixirweight[1])
                        endif
                    endif
                endif
            endif
        endif
        
        if i[0] != 2 and i[1] != 2 then 
            if i[2] != 2 and i[3] != 2 then
                if i[4] != 2 and i[5] != 2 then 
                    if i[6] != 2 and i[7] != 2 then
                        if ElixirGroup[2] == false and ElixirGroup[7] == false and ElixirGroup[17] == false and ElixirGroup[21] == false then
                            call ElixirSelect.add(2, Elixirweight[2])
                        endif
                    endif
                endif
            endif
        endif
        
        if i[0] != 3 and i[1] != 3 then 
            if i[2] != 3 and i[3] != 3 then
                if i[4] != 3 and i[5] != 3 then 
                    if i[6] != 3 and i[7] != 3 then
                        if ElixirGroup[3] == false and ElixirGroup[8] == false and ElixirGroup[18] == false and ElixirGroup[21] == false then
                            call ElixirSelect.add(3, Elixirweight[3])
                        endif
                    endif
                endif
            endif
        endif
        
        if i[0] != 4 and i[1] != 4 then 
            if i[2] != 4 and i[3] != 4 then
                if i[4] != 4 and i[5] != 4 then 
                    if i[6] != 4 and i[7] != 4 then
                        if ElixirGroup[4] == false and ElixirGroup[9] == false and ElixirGroup[19] == false and ElixirGroup[21] == false then
                            call ElixirSelect.add(4, Elixirweight[4])
                        endif
                    endif
                endif
            endif
        endif
        
        if i[0] != 5 and i[1] != 5 then 
            if i[2] != 5 and i[3] != 5 then
                if i[4] != 5 and i[5] != 5 then 
                    if i[6] != 5 and i[7] != 5 then
                        if ElixirGroup[5] == false and ElixirGroup[10] == false and ElixirGroup[20] == false and ElixirGroup[21] == false then
                            call ElixirSelect.add(5, Elixirweight[5])
                        endif
                    endif
                endif
            endif
        endif
        
        if i[0] != 6 and i[1] != 6 then
            if i[2] != 6 and i[3] != 6 then
                if i[4] != 6 and i[5] != 6 then
                    if i[6] != 6 and i[7] != 6 then
                        if ElixirGroup[21] == false then
                            call ElixirSelect.add(6, Elixirweight[6])
                        endif
                    endif
                endif
            endif
        endif

        set i[0] = LoadInteger(ElixirGroupData, StringHash("Elixir"), i[0])
        set i[1] = LoadInteger(ElixirGroupData, StringHash("Elixir"), i[1])
        set i[2] = LoadInteger(ElixirGroupData, StringHash("Elixir"), i[2])
        set i[3] = LoadInteger(ElixirGroupData, StringHash("Elixir"), i[3])
        set i[4] = LoadInteger(ElixirGroupData, StringHash("Elixir"), i[4])
        set i[5] = LoadInteger(ElixirGroupData, StringHash("Elixir"), i[5])
        set i[6] = LoadInteger(ElixirGroupData, StringHash("Elixir"), i[6])
        set i[7] = LoadInteger(ElixirGroupData, StringHash("Elixir"), i[7])

        
        // 1부터 6까지의 값(체크할 값)에 대해 반복합니다.
        set j = 1
        loop
            exitwhen j > 56
            
            // 해당 값이 발견되었는지 여부를 체크하는 변수입니다.
            set found = false
            
            // 배열 i를 순회하며 j의 값이 있는지 확인합니다.
            set k = 0
            loop
                exitwhen k > 7
                if i[k] == j then
                    set found = true
                    // 값을 찾았으므로 내부 루프를 종료합니다.
                    exitwhen true
                endif
                set k = k + 1
            endloop
            
            // 만약 해당 값(j)이 배열 i에 없었다면, ElixirSelect에 추가합니다.
            if found == false then
                if j == 1 then
                    if ElixirGroup[1] == false and ElixirGroup[6] == false and ElixirGroup[16] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(7, Elixirweight[7])
                        call ElixirSelect.add(13, Elixirweight[13])
                    endif
                elseif j == 2 then
                    if ElixirGroup[2] == false and ElixirGroup[7] == false and ElixirGroup[17] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(8, Elixirweight[8])
                        call ElixirSelect.add(14, Elixirweight[14])
                    endif
                elseif j == 3 then
                    if ElixirGroup[3] == false and ElixirGroup[8] == false and ElixirGroup[18] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(9, Elixirweight[9])
                        call ElixirSelect.add(15, Elixirweight[15])
                    endif
                elseif j == 4 then
                    if ElixirGroup[4] == false and ElixirGroup[9] == false and ElixirGroup[19] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(10, Elixirweight[10])
                        call ElixirSelect.add(17, Elixirweight[17])
                    endif
                elseif j == 5 then
                    if ElixirGroup[5] == false and ElixirGroup[10] == false and ElixirGroup[20] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(11, Elixirweight[11])
                        call ElixirSelect.add(18, Elixirweight[18])
                    endif
                elseif j == 6 then
                    if ElixirGroup[21] == false then
                        call ElixirSelect.add(12, Elixirweight[12])
                        call ElixirSelect.add(18, Elixirweight[18])
                    endif
                elseif j == 7 then
                    if ElixirGroup[1] == false and ElixirGroup[11] == false and ElixirGroup[16] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(19, Elixirweight[19])
                        call ElixirSelect.add(25, Elixirweight[25])
                    endif
                elseif j == 8 then
                    if ElixirGroup[2] == false and ElixirGroup[12] == false and ElixirGroup[17] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(20, Elixirweight[20])
                        call ElixirSelect.add(26, Elixirweight[26])
                    endif
                elseif j == 9 then
                    if ElixirGroup[3] == false and ElixirGroup[13] == false and ElixirGroup[18] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(21, Elixirweight[21])
                        call ElixirSelect.add(27, Elixirweight[27])
                    endif
                elseif j == 10 then
                    if ElixirGroup[4] == false and ElixirGroup[14] == false and ElixirGroup[19] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(22, Elixirweight[22])
                        call ElixirSelect.add(28, Elixirweight[28])
                    endif
                elseif j == 11 then
                    if ElixirGroup[5] == false and ElixirGroup[15] == false and ElixirGroup[20] == false and ElixirGroup[21] == false then
                        call ElixirSelect.add(23, Elixirweight[23])
                        call ElixirSelect.add(29, Elixirweight[29])
                    endif
                elseif j == 12 then
                    if ElixirGroup[21] == false then
                        call ElixirSelect.add(24, Elixirweight[24])
                        call ElixirSelect.add(30, Elixirweight[30])
                    endif
                elseif j == 13 then
                    if ElixirGroup[1] == false and ElixirGroup[11] == false and ElixirGroup[16] == false and ElixirGroup[24] == false then
                        call ElixirSelect.add(31, Elixirweight[31])
                        call ElixirSelect.add(37, Elixirweight[37])
                        call ElixirSelect.add(43, Elixirweight[43])
                    endif
                elseif j == 14 then
                    if ElixirGroup[2] == false and ElixirGroup[12] == false and ElixirGroup[17] == false and ElixirGroup[25] == false then
                        call ElixirSelect.add(32, Elixirweight[32])
                        call ElixirSelect.add(38, Elixirweight[38])
                        call ElixirSelect.add(44, Elixirweight[44])
                    endif
                elseif j == 15 then
                    if ElixirGroup[3] == false and ElixirGroup[13] == false and ElixirGroup[18] == false and ElixirGroup[26] == false then
                        call ElixirSelect.add(33, Elixirweight[33])
                        call ElixirSelect.add(39, Elixirweight[39])
                        call ElixirSelect.add(45, Elixirweight[45])
                    endif
                elseif j == 16 then
                    if ElixirGroup[4] == false and ElixirGroup[14] == false and ElixirGroup[19] == false and ElixirGroup[27] == false then
                        call ElixirSelect.add(34, Elixirweight[34])
                        call ElixirSelect.add(40, Elixirweight[40])
                        call ElixirSelect.add(46, Elixirweight[46])
                    endif
                elseif j == 17 then
                    if ElixirGroup[5] == false and ElixirGroup[15] == false and ElixirGroup[20] == false and ElixirGroup[28] == false then
                        call ElixirSelect.add(35, Elixirweight[35])
                        call ElixirSelect.add(41, Elixirweight[41])
                        call ElixirSelect.add(47, Elixirweight[47])
                    endif
                elseif j == 18 then
                    if ElixirGroup[29] == false then
                        call ElixirSelect.add(36, Elixirweight[36])
                        call ElixirSelect.add(42, Elixirweight[42])
                        call ElixirSelect.add(48, Elixirweight[48])
                    endif
                elseif j == 19 then
                    if ElixirGroup[29] == false then
                        call ElixirSelect.add(49, Elixirweight[49])
                        call ElixirSelect.add(50, Elixirweight[50])
                        call ElixirSelect.add(51, Elixirweight[51])
                    endif
                elseif j == 20 then
                    if ElixirGroup[1] == false and ElixirGroup[6] == false and ElixirGroup[16] == false then
                        call ElixirSelect.add(52, Elixirweight[52])
                        call ElixirSelect.add(58, Elixirweight[58])
                    endif
                elseif j == 21 then
                    if ElixirGroup[2] == false and ElixirGroup[7] == false and ElixirGroup[17] == false then
                        call ElixirSelect.add(53, Elixirweight[53])
                        call ElixirSelect.add(59, Elixirweight[59])
                    endif
                elseif j == 22 then
                    if ElixirGroup[3] == false and ElixirGroup[8] == false and ElixirGroup[18] == false then
                        call ElixirSelect.add(54, Elixirweight[54])
                        call ElixirSelect.add(60, Elixirweight[60])
                    endif
                elseif j == 23 then
                    if ElixirGroup[4] == false and ElixirGroup[9] == false and ElixirGroup[19] == false then
                        call ElixirSelect.add(55, Elixirweight[55])
                        call ElixirSelect.add(61, Elixirweight[61])
                    endif
                elseif j == 24 then
                    if ElixirGroup[5] == false and ElixirGroup[10] == false and ElixirGroup[20] == false then
                        call ElixirSelect.add(56, Elixirweight[56])
                        call ElixirSelect.add(62, Elixirweight[62])
                    endif
                elseif j == 25 then
                    //선택연성
                    call ElixirSelect.add(57, Elixirweight[57])
                    call ElixirSelect.add(63, Elixirweight[63])
                elseif j == 26 then
                    if ElixirGroup[1] == false and ElixirGroup[16] == false then
                        call ElixirSelect.add(65, Elixirweight[65])
                        call ElixirSelect.add(71, Elixirweight[71])
                        call ElixirSelect.add(77, Elixirweight[77])
                    endif
                elseif j == 27 then
                    if ElixirGroup[2] == false and ElixirGroup[17] == false then
                        call ElixirSelect.add(66, Elixirweight[66])
                        call ElixirSelect.add(72, Elixirweight[72])
                        call ElixirSelect.add(78, Elixirweight[78])
                    endif
                elseif j == 28 then
                    if ElixirGroup[3] == false and ElixirGroup[18] == false then
                        call ElixirSelect.add(67, Elixirweight[67])
                        call ElixirSelect.add(73, Elixirweight[73])
                        call ElixirSelect.add(79, Elixirweight[79])
                    endif
                elseif j == 29 then
                    if ElixirGroup[4] == false and ElixirGroup[19] == false then
                        call ElixirSelect.add(68, Elixirweight[68])
                        call ElixirSelect.add(74, Elixirweight[74])
                        call ElixirSelect.add(80, Elixirweight[80])
                    endif
                elseif j == 30 then
                    if ElixirGroup[5] == false and ElixirGroup[20] == false then
                        call ElixirSelect.add(69, Elixirweight[69])
                        call ElixirSelect.add(75, Elixirweight[75])
                        call ElixirSelect.add(81, Elixirweight[81])
                    endif
                elseif j == 31 then
                    //선택 단계 상승
                    call ElixirSelect.add(70, Elixirweight[70])
                    call ElixirSelect.add(76, Elixirweight[76])
                    call ElixirSelect.add(82, Elixirweight[82])
                elseif j == 32 then
                    if ElixirGroup[1] == false and ElixirGroup[16] == false then
                        call ElixirSelect.add(83, Elixirweight[83])
                        call ElixirSelect.add(89, Elixirweight[89])
                    endif
                elseif j == 33 then
                    if ElixirGroup[2] == false and ElixirGroup[17] == false then
                        call ElixirSelect.add(84, Elixirweight[84])
                        call ElixirSelect.add(90, Elixirweight[90])
                    endif
                elseif j == 34 then
                    if ElixirGroup[3] == false and ElixirGroup[18] == false then
                        call ElixirSelect.add(85, Elixirweight[85])
                        call ElixirSelect.add(91, Elixirweight[91])
                    endif
                elseif j == 35 then
                    if ElixirGroup[4] == false and ElixirGroup[19] == false then
                        call ElixirSelect.add(86, Elixirweight[86])
                        call ElixirSelect.add(92, Elixirweight[92])
                    endif
                elseif j == 36 then
                    if ElixirGroup[5] == false and ElixirGroup[20] == false then
                        call ElixirSelect.add(87, Elixirweight[87])
                        call ElixirSelect.add(93, Elixirweight[93])
                    endif
                elseif j == 37 then
                    //선택효과 단계확률상승
                    call ElixirSelect.add(88, Elixirweight[88])
                    call ElixirSelect.add(94, Elixirweight[94])
                elseif j == 38 then
                    if ElixirGroup[1] == false and ElixirGroup[16] == false then
                        call ElixirSelect.add(95, Elixirweight[95])
                        call ElixirSelect.add(101, Elixirweight[101])
                    endif
                elseif j == 39 then
                    if ElixirGroup[2] == false and ElixirGroup[17] == false then
                        call ElixirSelect.add(96, Elixirweight[96])
                        call ElixirSelect.add(102, Elixirweight[102])
                    endif
                elseif j == 40 then
                    if ElixirGroup[3] == false and ElixirGroup[18] == false then
                        call ElixirSelect.add(97, Elixirweight[97])
                        call ElixirSelect.add(103, Elixirweight[103])
                    endif
                elseif j == 41 then
                    if ElixirGroup[4] == false and ElixirGroup[19] == false then
                        call ElixirSelect.add(98, Elixirweight[98])
                        call ElixirSelect.add(104, Elixirweight[104])
                    endif
                elseif j == 42 then
                    if ElixirGroup[5] == false and ElixirGroup[20] == false then
                        call ElixirSelect.add(99, Elixirweight[99])
                        call ElixirSelect.add(105, Elixirweight[105])
                    endif
                elseif j == 43 then
                    //선택효과 단계확률상승
                    call ElixirSelect.add(100, Elixirweight[100])
                    call ElixirSelect.add(106, Elixirweight[106])
                elseif j == 44 then
                    if ElixirGroup[1] == false and ElixirGroup[16] == false then
                        call ElixirSelect.add(107, Elixirweight[107])
                        call ElixirSelect.add(113, Elixirweight[113])
                    endif
                elseif j == 45 then
                    if ElixirGroup[2] == false and ElixirGroup[17] == false then
                        call ElixirSelect.add(108, Elixirweight[108])
                        call ElixirSelect.add(114, Elixirweight[114])
                    endif
                elseif j == 46 then
                    if ElixirGroup[3] == false and ElixirGroup[18] == false then
                        call ElixirSelect.add(109, Elixirweight[109])
                        call ElixirSelect.add(115, Elixirweight[115])
                    endif
                elseif j == 47 then
                    if ElixirGroup[4] == false and ElixirGroup[19] == false then
                        call ElixirSelect.add(110, Elixirweight[110])
                        call ElixirSelect.add(116, Elixirweight[116])
                    endif
                elseif j == 48 then
                    if ElixirGroup[5] == false and ElixirGroup[20] == false then
                        call ElixirSelect.add(111, Elixirweight[111])
                        call ElixirSelect.add(117, Elixirweight[117])
                    endif
                elseif j == 49 then
                    //선택효과 단계확률상승
                    call ElixirSelect.add(112, Elixirweight[112])
                    call ElixirSelect.add(118, Elixirweight[118])
                elseif j == 50 then
                    //임의 1개 단계 상승
                    call ElixirSelect.add(119, Elixirweight[119])
                    call ElixirSelect.add(120, Elixirweight[120])
                    call ElixirSelect.add(121, Elixirweight[121])
                elseif j == 51 then
                    //최하 단계 효과 1개의 단계 상승
                    if ElixirGroup[30] == false then
                        call ElixirSelect.add(122, Elixirweight[122])
                        call ElixirSelect.add(123, Elixirweight[123])
                        call ElixirSelect.add(124, Elixirweight[124])
                    endif
                elseif j == 52 then
                    //최고 단계 효과 1개의 단계 상승
                    if ElixirGroup[30] == false and ElixirGroup[31] == false then
                        call ElixirSelect.add(125, Elixirweight[125])
                        call ElixirSelect.add(126, Elixirweight[126])
                        call ElixirSelect.add(127, Elixirweight[127])
                    endif
                elseif j == 53 then
                    call ElixirSelect.add(129, Elixirweight[129])
                    call ElixirSelect.add(130, Elixirweight[130])
                    call ElixirSelect.add(131, Elixirweight[131])
                elseif j == 54 then
                    if ElixirGroup[21] == false then
                        call ElixirSelect.add(132, Elixirweight[132])
                    endif
                    if ElixirGroup[22] == false then
                        call ElixirSelect.add(133, Elixirweight[133])
                    endif
                    if ElixirGroup[23] == false then
                        call ElixirSelect.add(134, Elixirweight[134])
                    endif
                elseif j == 55 then
                    call ElixirSelect.add(135, Elixirweight[135])
                    call ElixirSelect.add(136, Elixirweight[136])
                elseif j == 56 then
                    if ElixirGroup[32] == false then
                        //call ElixirSelect.add(128, Elixirweight[128])
                    endif
                elseif j == 57 then
                    call ElixirSelect.add(64, Elixirweight[64])
                endif
            endif
            
            set j = j + 1
        endloop

        set a = ElixirSelect.pick(true)
        set b = ElixirSelect.pick(true)
        set c = ElixirSelect.pick(true)
        call ElixirSelect.clear()
        
        if GetLocalPlayer() == Player(pid) then
            set NowSelectNumber2[1] = a
            call DzFrameSetText(El_SelectText[1], ElixirText[NowSelectNumber2[1]])
            set NowSelectNumber2[2] = b
            call DzFrameSetText(El_SelectText[2], ElixirText[NowSelectNumber2[2]])
            set NowSelectNumber2[3] = c
            call DzFrameSetText(El_SelectText[3], ElixirText[NowSelectNumber2[3]])
            
            call DzFrameSetText(El_MainR[1], R2SW(GetPathChance(pid,1),1,1)+"%")
            call DzFrameSetText(El_MainR[2], R2SW(GetPathChance(pid,2),1,1)+"%")
            call DzFrameSetText(El_MainR[3], R2SW(GetPathChance(pid,3),1,1)+"%")
            call DzFrameSetText(El_MainR[4], R2SW(GetPathChance(pid,4),1,1)+"%")
            call DzFrameSetText(El_MainR[5], R2SW(GetPathChance(pid,5),1,1)+"%")
            call DzFrameSetText(El_MainR2[1], "대성공 "+R2SW(El_RateLucky[pid][1],1,1)+"%")
            call DzFrameSetText(El_MainR2[2], "대성공 "+R2SW(El_RateLucky[pid][2],1,1)+"%")
            call DzFrameSetText(El_MainR2[3], "대성공 "+R2SW(El_RateLucky[pid][3],1,1)+"%")
            call DzFrameSetText(El_MainR2[4], "대성공 "+R2SW(El_RateLucky[pid][4],1,1)+"%")
            call DzFrameSetText(El_MainR2[5], "대성공 "+R2SW(El_RateLucky[pid][5],1,1)+"%")
            call DzFrameSetText(CountText, I2S(NowCount[pid])+"회 연성가능")
        endif
    endfunction

    private function Main takes nothing returns nothing
        local string s
        local integer i
        
        //메뉴 배경2
        set El_BackDrop2=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetTexture(El_BackDrop2, "Filenemo.blp", 0)
        call DzFrameSetAbsolutePoint(El_BackDrop2, JN_FRAMEPOINT_CENTER, 0.400, 0.300)
        call DzFrameSetSize(El_BackDrop2, 0.700, 0.450)
        call DzFrameSetPriority(El_BackDrop2, 5)
        call DzFrameShow(El_BackDrop2, false)

        set EL_LevelTextC=DzCreateFrameByTagName("TEXT","",El_BackDrop2,"",FrameCount())
        call DzFrameSetAbsolutePoint(EL_LevelTextC, JN_FRAMEPOINT_CENTER, 0.400, 0.4500)
        call DzFrameSetText(EL_LevelTextC,"연성 결과")
        call DzFrameSetFont(EL_LevelTextC, "Fonts\\DFHeiMd.ttf", 0.012, 0)
        
        //가능텍스트
        set EL_LevelA=DzCreateFrameByTagName("BACKDROP", "", El_BackDrop2, "template", FrameCount())
        call DzFrameSetTexture(EL_LevelA, "File00004591.blp", 0)
        call DzFrameSetSize(EL_LevelA, 0.300, 0.05)
        call DzFrameSetAbsolutePoint(EL_LevelA, JN_FRAMEPOINT_CENTER, 0.400, 0.3700)
        
        set EL_LevelTextA=DzCreateFrameByTagName("TEXT","",EL_LevelA,"",FrameCount())
        call DzFrameSetAbsolutePoint(EL_LevelTextA, JN_FRAMEPOINT_CENTER, 0.400, 0.3700)
        call DzFrameSetText(EL_LevelTextA,"공격력")
        set EL_LevelTextA=DzCreateFrameByTagName("TEXT","",EL_LevelA,"",FrameCount())
        call DzFrameSetAbsolutePoint(EL_LevelTextA, JN_FRAMEPOINT_CENTER, 0.400, 0.3200)
        call DzFrameSetText(EL_LevelTextA,"10000")

        //가능텍스트
        set EL_LevelB=DzCreateFrameByTagName("BACKDROP", "", El_BackDrop2, "template", FrameCount())
        call DzFrameSetTexture(EL_LevelB, "File00004591.blp", 0)
        call DzFrameSetSize(EL_LevelB, 0.300, 0.05)
        call DzFrameSetAbsolutePoint(EL_LevelB, JN_FRAMEPOINT_CENTER, 0.400, 0.2500)
        
        set EL_LevelTextB=DzCreateFrameByTagName("TEXT","",EL_LevelB,"",FrameCount())
        call DzFrameSetAbsolutePoint(EL_LevelTextB, JN_FRAMEPOINT_CENTER, 0.400, 0.2500)
        call DzFrameSetText(EL_LevelTextB,"공격력 %")
        set EL_LevelTextB=DzCreateFrameByTagName("TEXT","",EL_LevelB,"",FrameCount())
        call DzFrameSetAbsolutePoint(EL_LevelTextB, JN_FRAMEPOINT_CENTER, 0.400, 0.2000)
        call DzFrameSetText(EL_LevelTextB,"10 %")

        
        //결정
        set El_LBBD=DzCreateFrameByTagName("BACKDROP", "", El_BackDrop2, "template", FrameCount())
        call DzFrameSetTexture(El_LBBD, "UI_PickSelectButton.tga", 0)
        call DzFrameSetSize(El_LBBD, 0.06, 0.03)
        call DzFrameSetAbsolutePoint(El_LBBD, JN_FRAMEPOINT_CENTER, 0.4000, 0.1400)
        
        set El_LBT=DzCreateFrameByTagName("TEXT","",El_LBBD,"",0)
        call DzFrameSetAbsolutePoint(El_LBT, JN_FRAMEPOINT_CENTER, 0.4000, 0.1400)
        call DzFrameSetText(El_LBT,"확인")
        
        set El_LB=DzCreateFrameByTagName("BUTTON", "", El_LBBD, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAllPoints(El_LB, El_LBBD)
        call DzFrameSetSize(El_LB, 0.06, 0.03)
        call DzFrameSetScriptByCode(El_LB, JN_FRAMEEVENT_MOUSE_UP, function ClickLButton3, false)

        set EL_LevelEffect1=DzCreateFrameByTagName("SPRITE", "", El_BackDrop2, "", FrameCount())
        call DzFrameSetPoint(EL_LevelEffect1, JN_FRAMEPOINT_BOTTOMLEFT, EL_LevelTextB, JN_FRAMEPOINT_CENTER ,0, 0.0)
        set EL_LevelEffect2=DzCreateFrameByTagName("SPRITE", "", El_BackDrop2, "", FrameCount())
        call DzFrameSetPoint(EL_LevelEffect2, JN_FRAMEPOINT_BOTTOMLEFT, EL_LevelTextA, JN_FRAMEPOINT_CENTER ,0, 0.0)
        
        
        

        //메뉴 배경
        set El_BackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetTexture(El_BackDrop, "Filenemo.blp", 0)
        call DzFrameSetAbsolutePoint(El_BackDrop, JN_FRAMEPOINT_CENTER, 0.400, 0.300)
        call DzFrameSetSize(El_BackDrop, 0.700, 0.450)
        call DzFrameSetPriority(El_BackDrop, 5)

        set El_Main[1]=DzCreateFrameByTagName("BACKDROP", "", El_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(El_Main[1], "File00005254.blp", 0)
        call DzFrameSetSize(El_Main[1], 0.40, 0.05)
        call DzFrameSetAbsolutePoint(El_Main[1], JN_FRAMEPOINT_CENTER, 0.360, 0.4750)
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[1], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[1], JN_FRAMEPOINT_BOTTOMLEFT, 0.1910, 0.010)
        call DzFrameSetText(i, "1")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[1], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[1], JN_FRAMEPOINT_BOTTOMLEFT, 0.2695, 0.010)
        call DzFrameSetText(i, "2")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[1], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[1], JN_FRAMEPOINT_BOTTOMLEFT, 0.3220, 0.010)
        call DzFrameSetText(i, "3")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[1], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[1], JN_FRAMEPOINT_BOTTOMLEFT, 0.3485, 0.010)
        call DzFrameSetText(i, "4")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[1], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[1], JN_FRAMEPOINT_BOTTOMLEFT, 0.3750, 0.010)
        call DzFrameSetText(i, "5")
        set El_MainR[1]=DzCreateFrameByTagName("TEXT", "", El_Main[1], "", FrameCount())
        call DzFrameSetPoint(El_MainR[1], JN_FRAMEPOINT_CENTER, El_Main[1], JN_FRAMEPOINT_BOTTOMLEFT, 0.06, 0.026)
        call DzFrameSetText(El_MainR[1], "100%")
        set El_MainR2[1]=DzCreateFrameByTagName("TEXT", "", El_Main[1], "", FrameCount())
        call DzFrameSetPoint(El_MainR2[1], JN_FRAMEPOINT_CENTER, El_Main[1], JN_FRAMEPOINT_BOTTOMLEFT, 0.44, 0.026)
        call DzFrameSetText(El_MainR2[1], "대성공 100%")
        set El_MainB[1] = DzCreateFrameByTagName("BUTTON", "", El_Main[1], "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(El_MainB[1], JN_FRAMEPOINT_CENTER, 0.360, 0.4750)
        call DzFrameSetSize(El_MainB[1], 0.40, 0.05)
        call DzFrameSetScriptByCode(El_MainB[1], JN_FRAMEEVENT_MOUSE_UP, function ClickLButton, false)
        
        set El_Main[2]=DzCreateFrameByTagName("BACKDROP", "", El_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(El_Main[2], "File00005254.blp", 0)
        call DzFrameSetSize(El_Main[2], 0.40, 0.05)
        call DzFrameSetAbsolutePoint(El_Main[2], JN_FRAMEPOINT_CENTER, 0.360, 0.4200)
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[2], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[2], JN_FRAMEPOINT_BOTTOMLEFT, 0.1910, 0.010)
        call DzFrameSetText(i, "1")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[2], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[2], JN_FRAMEPOINT_BOTTOMLEFT, 0.2695, 0.010)
        call DzFrameSetText(i, "2")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[2], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[2], JN_FRAMEPOINT_BOTTOMLEFT, 0.3220, 0.010)
        call DzFrameSetText(i, "3")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[2], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[2], JN_FRAMEPOINT_BOTTOMLEFT, 0.3485, 0.010)
        call DzFrameSetText(i, "4")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[2], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[2], JN_FRAMEPOINT_BOTTOMLEFT, 0.3750, 0.010)
        call DzFrameSetText(i, "5")
        set El_MainR[2]=DzCreateFrameByTagName("TEXT", "", El_Main[2], "", FrameCount())
        call DzFrameSetPoint(El_MainR[2], JN_FRAMEPOINT_CENTER, El_Main[2], JN_FRAMEPOINT_BOTTOMLEFT, 0.06, 0.026)
        call DzFrameSetText(El_MainR[2], "100%")
        set El_MainR2[2]=DzCreateFrameByTagName("TEXT", "", El_Main[2], "", FrameCount())
        call DzFrameSetPoint(El_MainR2[2], JN_FRAMEPOINT_CENTER, El_Main[2], JN_FRAMEPOINT_BOTTOMLEFT, 0.44, 0.026)
        call DzFrameSetText(El_MainR2[2], "대성공 100%")
        set El_MainB[2] = DzCreateFrameByTagName("BUTTON", "", El_Main[2], "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(El_MainB[2], JN_FRAMEPOINT_CENTER, 0.360, 0.4200)
        call DzFrameSetSize(El_MainB[2], 0.40, 0.05)
        call DzFrameSetScriptByCode(El_MainB[2], JN_FRAMEEVENT_MOUSE_UP, function ClickLButton, false)
        
        set El_Main[3]=DzCreateFrameByTagName("BACKDROP", "", El_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(El_Main[3], "File00005254.blp", 0)
        call DzFrameSetSize(El_Main[3], 0.40, 0.05)
        call DzFrameSetAbsolutePoint(El_Main[3], JN_FRAMEPOINT_CENTER, 0.360, 0.3650)
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[3], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[3], JN_FRAMEPOINT_BOTTOMLEFT, 0.1910, 0.010)
        call DzFrameSetText(i, "1")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[3], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[3], JN_FRAMEPOINT_BOTTOMLEFT, 0.2695, 0.010)
        call DzFrameSetText(i, "2")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[3], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[3], JN_FRAMEPOINT_BOTTOMLEFT, 0.3220, 0.010)
        call DzFrameSetText(i, "3")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[3], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[3], JN_FRAMEPOINT_BOTTOMLEFT, 0.3485, 0.010)
        call DzFrameSetText(i, "4")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[3], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[3], JN_FRAMEPOINT_BOTTOMLEFT, 0.3750, 0.010)
        call DzFrameSetText(i, "5")
        set El_MainR[3]=DzCreateFrameByTagName("TEXT", "", El_Main[3], "", FrameCount())
        call DzFrameSetPoint(El_MainR[3], JN_FRAMEPOINT_CENTER, El_Main[3], JN_FRAMEPOINT_BOTTOMLEFT, 0.06, 0.026)
        call DzFrameSetText(El_MainR[3], "100%")
        set El_MainR2[3]=DzCreateFrameByTagName("TEXT", "", El_Main[3], "", FrameCount())
        call DzFrameSetPoint(El_MainR2[3], JN_FRAMEPOINT_CENTER, El_Main[3], JN_FRAMEPOINT_BOTTOMLEFT, 0.44, 0.026)
        call DzFrameSetText(El_MainR2[3], "대성공 100%")
        set El_MainB[3] = DzCreateFrameByTagName("BUTTON", "", El_Main[3], "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(El_MainB[3], JN_FRAMEPOINT_CENTER, 0.360, 0.3650)
        call DzFrameSetSize(El_MainB[3], 0.40, 0.05)
        call DzFrameSetScriptByCode(El_MainB[3], JN_FRAMEEVENT_MOUSE_UP, function ClickLButton, false)
        
        set El_Main[4]=DzCreateFrameByTagName("BACKDROP", "", El_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(El_Main[4], "File00005254.blp", 0)
        call DzFrameSetSize(El_Main[4], 0.40, 0.05)
        call DzFrameSetAbsolutePoint(El_Main[4], JN_FRAMEPOINT_CENTER, 0.360, 0.3100)
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[4], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[4], JN_FRAMEPOINT_BOTTOMLEFT, 0.1910, 0.010)
        call DzFrameSetText(i, "1")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[4], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[4], JN_FRAMEPOINT_BOTTOMLEFT, 0.2695, 0.010)
        call DzFrameSetText(i, "2")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[4], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[4], JN_FRAMEPOINT_BOTTOMLEFT, 0.3220, 0.010)
        call DzFrameSetText(i, "3")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[4], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[4], JN_FRAMEPOINT_BOTTOMLEFT, 0.3485, 0.010)
        call DzFrameSetText(i, "4")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[4], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[4], JN_FRAMEPOINT_BOTTOMLEFT, 0.3750, 0.010)
        call DzFrameSetText(i, "5")
        set El_MainR[4]=DzCreateFrameByTagName("TEXT", "", El_Main[4], "", FrameCount())
        call DzFrameSetPoint(El_MainR[4], JN_FRAMEPOINT_CENTER, El_Main[4], JN_FRAMEPOINT_BOTTOMLEFT, 0.06, 0.026)
        call DzFrameSetText(El_MainR[4], "100%")
        set El_MainR2[4]=DzCreateFrameByTagName("TEXT", "", El_Main[4], "", FrameCount())
        call DzFrameSetPoint(El_MainR2[4], JN_FRAMEPOINT_CENTER, El_Main[4], JN_FRAMEPOINT_BOTTOMLEFT, 0.44, 0.026)
        call DzFrameSetText(El_MainR2[4], "대성공 100%")
        set El_MainB[4] = DzCreateFrameByTagName("BUTTON", "", El_Main[4], "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(El_MainB[4], JN_FRAMEPOINT_CENTER, 0.360, 0.3100)
        call DzFrameSetSize(El_MainB[4], 0.40, 0.05)
        call DzFrameSetScriptByCode(El_MainB[4], JN_FRAMEEVENT_MOUSE_UP, function ClickLButton, false)
        
        set El_Main[5]=DzCreateFrameByTagName("BACKDROP", "", El_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(El_Main[5], "File00005254.blp", 0)
        call DzFrameSetSize(El_Main[5], 0.40, 0.05)
        call DzFrameSetAbsolutePoint(El_Main[5], JN_FRAMEPOINT_CENTER, 0.360, 0.2550)
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[5], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[5], JN_FRAMEPOINT_BOTTOMLEFT, 0.1910, 0.010)
        call DzFrameSetText(i, "1")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[5], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[5], JN_FRAMEPOINT_BOTTOMLEFT, 0.2695, 0.010)
        call DzFrameSetText(i, "2")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[5], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[5], JN_FRAMEPOINT_BOTTOMLEFT, 0.3220, 0.010)
        call DzFrameSetText(i, "3")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[5], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[5], JN_FRAMEPOINT_BOTTOMLEFT, 0.3485, 0.010)
        call DzFrameSetText(i, "4")
        set i = DzCreateFrameByTagName("TEXT", "", El_Main[5], "", FrameCount())
        call DzFrameSetPoint(i, JN_FRAMEPOINT_CENTER, El_Main[5], JN_FRAMEPOINT_BOTTOMLEFT, 0.3750, 0.010)
        call DzFrameSetText(i, "5")
        set El_MainR[5]=DzCreateFrameByTagName("TEXT", "", El_Main[5], "", FrameCount())
        call DzFrameSetPoint(El_MainR[5], JN_FRAMEPOINT_CENTER, El_Main[5], JN_FRAMEPOINT_BOTTOMLEFT, 0.06, 0.026)
        call DzFrameSetText(El_MainR[5], "100%")
        set El_MainR2[5]=DzCreateFrameByTagName("TEXT", "", El_Main[5], "", FrameCount())
        call DzFrameSetPoint(El_MainR2[5], JN_FRAMEPOINT_CENTER, El_Main[5], JN_FRAMEPOINT_BOTTOMLEFT, 0.44, 0.026)
        call DzFrameSetText(El_MainR2[5], "대성공 100%")
        set El_MainB[5] = DzCreateFrameByTagName("BUTTON", "", El_Main[5], "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(El_MainB[5], JN_FRAMEPOINT_CENTER, 0.360, 0.2550)
        call DzFrameSetSize(El_MainB[5], 0.40, 0.05)
        call DzFrameSetScriptByCode(El_MainB[5], JN_FRAMEEVENT_MOUSE_UP, function ClickLButton, false)


        set i = 1
        loop
            set ElF_Level[1][i]=DzCreateFrameByTagName("BACKDROP", "", El_Main[1], "StandardEditBoxBackdropTemplate", FrameCount())
            call DzFrameSetAbsolutePoint(ElF_Level[1][i], JN_FRAMEPOINT_CENTER, (0.026 * i) + 0.3000 - 0.026 , 0.4750 )
            call DzFrameSetSize(ElF_Level[1][i], 0.025 , 0.025)
            call DzFrameSetTexture(ElF_Level[1][i], "UI_Arcana_Work1.blp", 0)
            set ElixirEffect[1][i]=DzCreateFrameByTagName("SPRITE", "", El_Main[1], "", FrameCount())
            call DzFrameSetPoint(ElixirEffect[1][i],JN_FRAMEPOINT_BOTTOMLEFT, ElF_Level[1][i], JN_FRAMEPOINT_CENTER ,0,0)
            set ElF_Level[2][i]=DzCreateFrameByTagName("BACKDROP", "", El_Main[2], "StandardEditBoxBackdropTemplate", FrameCount())
            call DzFrameSetAbsolutePoint(ElF_Level[2][i], JN_FRAMEPOINT_CENTER, (0.026 * i) + 0.3000 - 0.026, 0.4200 )
            call DzFrameSetSize(ElF_Level[2][i], 0.025 , 0.025)
            call DzFrameSetTexture(ElF_Level[2][i], "UI_Arcana_Work1.blp", 0)
            set ElixirEffect[2][i]=DzCreateFrameByTagName("SPRITE", "", El_Main[2], "", FrameCount())
            call DzFrameSetPoint(ElixirEffect[2][i],JN_FRAMEPOINT_BOTTOMLEFT, ElF_Level[2][i], JN_FRAMEPOINT_CENTER ,0,0)
            set ElF_Level[3][i]=DzCreateFrameByTagName("BACKDROP", "", El_Main[3], "StandardEditBoxBackdropTemplate", FrameCount())
            call DzFrameSetAbsolutePoint(ElF_Level[3][i], JN_FRAMEPOINT_CENTER, (0.026 * i) + 0.3000 - 0.026, 0.3650 )
            call DzFrameSetSize(ElF_Level[3][i], 0.025 , 0.025)
            call DzFrameSetTexture(ElF_Level[3][i], "UI_Arcana_Work1.blp", 0)
            set ElixirEffect[3][i]=DzCreateFrameByTagName("SPRITE", "", El_Main[3], "", FrameCount())
            call DzFrameSetPoint(ElixirEffect[3][i],JN_FRAMEPOINT_BOTTOMLEFT, ElF_Level[3][i], JN_FRAMEPOINT_CENTER ,0,0)
            set ElF_Level[4][i]=DzCreateFrameByTagName("BACKDROP", "", El_Main[4], "StandardEditBoxBackdropTemplate", FrameCount())
            call DzFrameSetAbsolutePoint(ElF_Level[4][i], JN_FRAMEPOINT_CENTER, (0.026 * i) + 0.3000 - 0.026, 0.3100 )
            call DzFrameSetSize(ElF_Level[4][i], 0.025 , 0.025)
            call DzFrameSetTexture(ElF_Level[4][i], "UI_Arcana_Work1.blp", 0)
            set ElixirEffect[4][i]=DzCreateFrameByTagName("SPRITE", "", El_Main[4], "", FrameCount())
            call DzFrameSetPoint(ElixirEffect[4][i],JN_FRAMEPOINT_BOTTOMLEFT, ElF_Level[4][i], JN_FRAMEPOINT_CENTER ,0,0)
            set ElF_Level[5][i]=DzCreateFrameByTagName("BACKDROP", "", El_Main[5], "StandardEditBoxBackdropTemplate", FrameCount())
            call DzFrameSetAbsolutePoint(ElF_Level[5][i], JN_FRAMEPOINT_CENTER, (0.026 * i) + 0.3000 - 0.026, 0.2550 )
            call DzFrameSetSize(ElF_Level[5][i], 0.025 , 0.025)
            call DzFrameSetTexture(ElF_Level[5][i], "UI_Arcana_Work1.blp", 0)
            set ElixirEffect[5][i]=DzCreateFrameByTagName("SPRITE", "", El_Main[5], "", FrameCount())
            call DzFrameSetPoint(ElixirEffect[5][i],JN_FRAMEPOINT_BOTTOMLEFT, ElF_Level[5][i], JN_FRAMEPOINT_CENTER ,0,0)
        exitwhen i == 10
            set i = i + 1
        endloop
//
        set ElF_Lock[1]=DzCreateFrameByTagName("BACKDROP", "", El_Main[1], "template", FrameCount())
        call DzFrameSetSize(ElF_Lock[1], 0.04, (19.0/ 16.0) * 0.04 )
        call DzFrameSetAbsolutePoint(ElF_Lock[1], JN_FRAMEPOINT_CENTER, 0.400, 0.4750)
        call DzFrameSetTexture(ElF_Lock[1], "UI_EL_Lock.blp", 0)
        call DzFrameShow(ElF_Lock[1], false)
        set ElF_Lock[2]=DzCreateFrameByTagName("BACKDROP", "", El_Main[2], "template", FrameCount())
        call DzFrameSetSize(ElF_Lock[2], 0.04, (19.0/ 16.0) * 0.04 )
        call DzFrameSetAbsolutePoint(ElF_Lock[2], JN_FRAMEPOINT_CENTER, 0.400, 0.4200)
        call DzFrameSetTexture(ElF_Lock[2], "UI_EL_Lock.blp", 0)
        call DzFrameShow(ElF_Lock[2], false)
        set ElF_Lock[3]=DzCreateFrameByTagName("BACKDROP", "", El_Main[3], "template", FrameCount())
        call DzFrameSetSize(ElF_Lock[3], 0.04, (19.0/ 16.0) * 0.04 )
        call DzFrameSetAbsolutePoint(ElF_Lock[3], JN_FRAMEPOINT_CENTER, 0.400, 0.3650)
        call DzFrameSetTexture(ElF_Lock[3], "UI_EL_Lock.blp", 0)
        call DzFrameShow(ElF_Lock[3], false)
        set ElF_Lock[4]=DzCreateFrameByTagName("BACKDROP", "", El_Main[4], "template", FrameCount())
        call DzFrameSetSize(ElF_Lock[4], 0.04, (19.0/ 16.0) * 0.04 )
        call DzFrameSetAbsolutePoint(ElF_Lock[4], JN_FRAMEPOINT_CENTER, 0.400, 0.3100)
        call DzFrameSetTexture(ElF_Lock[4], "UI_EL_Lock.blp", 0)
        call DzFrameShow(ElF_Lock[4], false)
        set ElF_Lock[5]=DzCreateFrameByTagName("BACKDROP", "", El_Main[5], "template", FrameCount())
        call DzFrameSetSize(ElF_Lock[5], 0.04, (19.0/ 16.0) * 0.04 )
        call DzFrameSetAbsolutePoint(ElF_Lock[5], JN_FRAMEPOINT_CENTER, 0.400, 0.2550)
        call DzFrameSetTexture(ElF_Lock[5], "UI_EL_Lock.blp", 0)
        call DzFrameShow(ElF_Lock[5], false)

        

        set El_Select[1]=DzCreateFrameByTagName("BACKDROP", "", El_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(El_Select[1], "UI_PickSelect2.blp", 0)
        call DzFrameSetSize(El_Select[1], 0.14, 0.05)
        call DzFrameSetAbsolutePoint(El_Select[1], JN_FRAMEPOINT_CENTER, 0.2500, 0.1800)
        set El_SelectText[1]=DzCreateFrameByTagName("TEXT", "", El_Select[1], "", FrameCount())
        call DzFrameSetFont(El_SelectText[1], "Fonts\\DFHeiMd.ttf", 0.008, 0)
        call DzFrameSetTextAlignment(El_SelectText[1], JN_TEXT_JUSTIFY_MIDDLE)
        call DzFrameSetEnable(El_SelectText[1], true)
        call DzFrameSetAlpha(El_SelectText[1], 255)
        call DzFrameSetSize(El_SelectText[1], 0.12, 0.00)
        call DzFrameSetText(El_SelectText[1], "모든 효과의 단계를 아래로 1 슬롯 씩 이동 (마지막 효과의 단계는 첫번째 효과로 이동)")
        call DzFrameSetPoint(El_SelectText[1], JN_FRAMEPOINT_TOPLEFT, El_Select[1], JN_FRAMEPOINT_TOPLEFT, 0.01, -0.01)
        call DzFrameSetTextColor(El_SelectText[1], JNConvertColor(255, 0, 0, 0))
        set El_Button[1] = DzCreateFrameByTagName("BUTTON", "", El_Select[1], "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(El_Button[1], JN_FRAMEPOINT_CENTER, 0.2500, 0.1800)
        call DzFrameSetSize(El_Button[1], 0.14, 0.05)
        call DzFrameSetScriptByCode(El_Button[1], JN_FRAMEEVENT_MOUSE_UP, function ClickLButton2, false)

        set El_Select[2]=DzCreateFrameByTagName("BACKDROP", "", El_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(El_Select[2], "UI_PickSelect2.blp", 0)
        call DzFrameSetSize(El_Select[2], 0.14, 0.05)
        call DzFrameSetAbsolutePoint(El_Select[2], JN_FRAMEPOINT_CENTER, 0.4000, 0.1800)
        set El_SelectText[2]=DzCreateFrameByTagName("TEXT", "", El_Select[2], "", FrameCount())
        call DzFrameSetFont(El_SelectText[2], "Fonts\\DFHeiMd.ttf", 0.008, 0)
        call DzFrameSetTextAlignment(El_SelectText[2], JN_TEXT_JUSTIFY_MIDDLE)
        call DzFrameSetEnable(El_SelectText[2], true)
        call DzFrameSetAlpha(El_SelectText[2], 255)
        call DzFrameSetSize(El_SelectText[2], 0.12, 0.00)
        call DzFrameSetText(El_SelectText[2], "모든 효과의 단계를 아래로 1 슬롯 씩 이동 (마지막 효과의 단계는 첫번째 효과로 이동)")
        call DzFrameSetPoint(El_SelectText[2], JN_FRAMEPOINT_TOPLEFT, El_Select[2], JN_FRAMEPOINT_TOPLEFT, 0.01, -0.01)
        call DzFrameSetTextColor(El_SelectText[2], JNConvertColor(255, 0, 0, 0))
        set El_Button[2] = DzCreateFrameByTagName("BUTTON", "", El_Select[2], "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(El_Button[2], JN_FRAMEPOINT_CENTER, 0.4000, 0.1800)
        call DzFrameSetSize(El_Button[2], 0.14, 0.05)
        call DzFrameSetScriptByCode(El_Button[2], JN_FRAMEEVENT_MOUSE_UP, function ClickLButton2, false)

        set El_Select[3]=DzCreateFrameByTagName("BACKDROP", "", El_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(El_Select[3], "UI_PickSelect2.blp", 0)
        call DzFrameSetSize(El_Select[3], 0.14, 0.05)
        call DzFrameSetAbsolutePoint(El_Select[3], JN_FRAMEPOINT_CENTER, 0.5500, 0.1800)
        set El_SelectText[3]=DzCreateFrameByTagName("TEXT", "", El_Select[3], "", FrameCount())
        call DzFrameSetFont(El_SelectText[3], "Fonts\\DFHeiMd.ttf", 0.008, 0)
        call DzFrameSetTextAlignment(El_SelectText[3], JN_TEXT_JUSTIFY_MIDDLE)
        call DzFrameSetEnable(El_SelectText[3], true)
        call DzFrameSetAlpha(El_SelectText[3], 255)
        call DzFrameSetSize(El_SelectText[3], 0.12, 0.00)
        call DzFrameSetText(El_SelectText[3], "모든 효과의 단계를 아래로 1 슬롯 씩 이동 (마지막 효과의 단계는 첫번째 효과로 이동)")
        call DzFrameSetPoint(El_SelectText[3], JN_FRAMEPOINT_TOPLEFT, El_Select[3], JN_FRAMEPOINT_TOPLEFT, 0.01, -0.01)
        call DzFrameSetTextColor(El_SelectText[3], JNConvertColor(255, 0, 0, 0))
        set El_Button[3] = DzCreateFrameByTagName("BUTTON", "", El_Select[3], "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAbsolutePoint(El_Button[3], JN_FRAMEPOINT_CENTER, 0.5500, 0.1800)
        call DzFrameSetSize(El_Button[3], 0.14, 0.05)
        call DzFrameSetScriptByCode(El_Button[3], JN_FRAMEEVENT_MOUSE_UP, function ClickLButton2, false)

        //결정
        set El_BBD=DzCreateFrameByTagName("BACKDROP", "", El_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(El_BBD, "UI_PickSelectButton.tga", 0)
        call DzFrameSetSize(El_BBD, 0.06, 0.03)
        call DzFrameSetAbsolutePoint(El_BBD, JN_FRAMEPOINT_CENTER, 0.4000, 0.1250)
        
        set El_BT=DzCreateFrameByTagName("TEXT","",El_BBD,"",0)
        call DzFrameSetAbsolutePoint(El_BT, JN_FRAMEPOINT_CENTER, 0.4000, 0.1250)
        call DzFrameSetText(El_BT,"결정")
        
        set El_B=DzCreateFrameByTagName("BUTTON", "", El_BBD, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAllPoints(El_B, El_BBD)
        call DzFrameSetSize(El_B, 0.06, 0.03)
        call DzFrameSetScriptByCode(El_B, JN_FRAMEEVENT_MOUSE_UP, function ClickLButton, false)

        //리롤
        set El_Roll=DzCreateFrameByTagName("BACKDROP", "", El_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(El_Roll, "UI_PickSelectButton.tga", 0)
        call DzFrameSetSize(El_Roll, 0.09, 0.03)
        call DzFrameSetAbsolutePoint(El_Roll, JN_FRAMEPOINT_CENTER, 0.6750, 0.1800)
        
        set El_RollT=DzCreateFrameByTagName("TEXT","",El_Roll,"",0)
        call DzFrameSetAbsolutePoint(El_RollT, JN_FRAMEPOINT_CENTER, 0.6750, 0.1800)
        call DzFrameSetText(El_RollT,"리롤(1회 남음)")
        
        set El_RollB=DzCreateFrameByTagName("BUTTON", "", El_Roll, "ScoreScreenTabButtonTemplate",  FrameCount())
        call DzFrameSetAllPoints(El_RollB, El_Roll)
        call DzFrameSetSize(El_RollB, 0.09, 0.03)
        call DzFrameSetScriptByCode(El_RollB, JN_FRAMEEVENT_MOUSE_UP, function ClickLButton, false)

        //가능텍스트
        set Count=DzCreateFrameByTagName("BACKDROP", "", El_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(Count, "File00004591.blp", 0)
        call DzFrameSetSize(Count, 0.09, 0.03)
        call DzFrameSetAbsolutePoint(Count, JN_FRAMEPOINT_CENTER, 0.5500, 0.1250)
        
        set CountText=DzCreateFrameByTagName("TEXT","",Count,"",0)
        call DzFrameSetAbsolutePoint(CountText, JN_FRAMEPOINT_CENTER, 0.5500, 0.1250)
        call DzFrameSetText(CountText,"10회 연성가능")


        call DzFrameShow(El_BackDrop, false)
    endfunction
    
    private function Command takes nothing returns nothing
        local integer pid = GetPlayerId(GetTriggerPlayer())
        local integer i = 0
        local integer j = 0
        local integer a = 0
        local integer b = 0
        local integer c = 0
        local IntegerPool ElixirSelect

        if ElShow[pid] == false then
            if GetLocalPlayer() == GetTriggerPlayer() then
                call DzFrameShow(El_BackDrop,true)
            endif
            set ElShow[pid] = true
        elseif ElShow[pid] == true then
            if GetLocalPlayer() == GetTriggerPlayer() then
                call DzFrameShow(El_BackDrop,false)
            endif
            set ElShow[pid] = false
        endif
        
        //엘릭서 세팅
        if ElShow[pid] == true then
            set NowCount[pid] = 10
            set NowRollCount[pid] = 1
            set ElixirSelect = IntegerPool.Create()
            set i = 0
            loop
                set i = i + 1
                if i == 122 or i == 123 or i == 124 or i == 125 or i == 126 or i == 127 or i == 128 then
                else
                    call ElixirSelect.add(i,Elixirweight[i])
                endif
            exitwhen i == 136
            endloop

            set a = ElixirSelect.pick(true)
            set b = ElixirSelect.pick(true)
            set c = ElixirSelect.pick(true)
            call ElixirSelect.clear()
            set j = 1
        endif

        //길초기화
        call SetupPaths(pid)
        set SelectString[pid] = "0;0;0;0;0;0;0;0;0;"
        set El_Lock[pid][1] = 0
        set El_Lock[pid][2] = 0
        set El_Lock[pid][3] = 0
        set El_Lock[pid][4] = 0
        set El_Lock[pid][5] = 0
        set El_RateLucky[pid][1] = 40.00
        set El_RateLucky[pid][2] = 40.00
        set El_RateLucky[pid][3] = 40.00
        set El_RateLucky[pid][4] = 40.00
        set El_RateLucky[pid][5] = 40.00
        set El_Level[pid][1] = 0
        set El_Level[pid][2] = 0
        set El_Level[pid][3] = 0
        set El_Level[pid][4] = 0
        set El_Level[pid][5] = 0

        if j == 1 then
            if GetLocalPlayer() == GetTriggerPlayer() then
                set NowMainSelect = 0
                set NowSelectNumber= 0
                set NowSelectNumber2[1] = 0
                set NowSelectNumber2[2] = 0
                set NowSelectNumber2[3] = 0
                call DzFrameShow(ElF_Lock[1], false)
                call DzFrameShow(ElF_Lock[2], false)
                call DzFrameShow(ElF_Lock[3], false)
                call DzFrameShow(ElF_Lock[4], false)
                call DzFrameShow(ElF_Lock[5], false)

                set NowSelectNumber2[1] = a
                call DzFrameSetText(El_SelectText[1], ElixirText[NowSelectNumber2[1]])
                set NowSelectNumber2[2] = b
                call DzFrameSetText(El_SelectText[2], ElixirText[NowSelectNumber2[2]])
                set NowSelectNumber2[3] = c
                call DzFrameSetText(El_SelectText[3], ElixirText[NowSelectNumber2[3]])
                
                call NormalizeWeights(pid)
                
                call DzFrameSetText(El_MainR[1], R2SW(GetPathChance(pid,1),1,1)+"%")
                call DzFrameSetText(El_MainR[2], R2SW(GetPathChance(pid,2),1,1)+"%")
                call DzFrameSetText(El_MainR[3], R2SW(GetPathChance(pid,3),1,1)+"%")
                call DzFrameSetText(El_MainR[4], R2SW(GetPathChance(pid,4),1,1)+"%")
                call DzFrameSetText(El_MainR[5], R2SW(GetPathChance(pid,5),1,1)+"%")
                call DzFrameSetText(El_MainR2[1], "대성공 "+R2SW(El_RateLucky[pid][1],1,1)+"%")
                call DzFrameSetText(El_MainR2[2], "대성공 "+R2SW(El_RateLucky[pid][2],1,1)+"%")
                call DzFrameSetText(El_MainR2[3], "대성공 "+R2SW(El_RateLucky[pid][3],1,1)+"%")
                call DzFrameSetText(El_MainR2[4], "대성공 "+R2SW(El_RateLucky[pid][4],1,1)+"%")
                call DzFrameSetText(El_MainR2[5], "대성공 "+R2SW(El_RateLucky[pid][5],1,1)+"%")
                call DzFrameSetText(El_RollT,"리롤("+I2S(NowRollCount[pid])+"회 남음)")
                call DzFrameSetText(CountText, I2S(NowCount[pid])+"회 연성가능")
                set i = 0
                loop
                    set i = i + 1
                    set j = 0 
                    loop
                        set j = j + 1
                        call DzFrameSetTexture(ElF_Level[i][j], "UI_Arcana_Work1.blp", 0)
                        exitwhen j == 10
                    endloop
                    exitwhen i == 5
                endloop
            endif
        endif

    endfunction
    

    private function init takes nothing returns nothing
        local trigger t
        local integer i = 0
        
        set t = CreateTrigger()
        call TriggerAddAction( t, function Main )
        call TriggerRegisterTimerEvent(t, 0.10, false)
        
        set i = 0
        set t = CreateTrigger()
        loop
            exitwhen i > 4
            call TriggerRegisterPlayerChatEvent( t, Player(i), "-엘릭서", false )
            set ElShow[i] = false
            set i = i + 1
        endloop
        call TriggerAddAction( t, function Command )

        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("ElRoll"),(false))
        call TriggerAddAction(t,function Roll)
        set t = null
        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("ElSelect"),(false))
        call TriggerAddAction(t,function Select)
        set t = null
        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("ElSelect2"),(false))
        call TriggerAddAction(t,function Select2)
        set t = null
        set t=CreateTrigger()
        call DzTriggerRegisterSyncData(t,("ElRoll2"),(false))
        call TriggerAddAction(t,function Roll3)
        set t = null
    endfunction

    //! runtextmacro 이벤트_N초가_지나면_발동("A","1.0")
        set SelectString[0] = "0;0;0;0;0;0;0;0;0;"
        set SelectString[1] = "0;0;0;0;0;0;0;0;0;"
        set SelectString[2] = "0;0;0;0;0;0;0;0;0;"
        set SelectString[3] = "0;0;0;0;0;0;0;0;0;"
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 7, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 13, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 8, 2)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 14, 2)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 9, 3)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 15, 3)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 10, 4)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 16, 4)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 11, 5)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 17, 5)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 12, 6)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 18, 6)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 19, 7)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 25, 7)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 20, 8)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 26, 8)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 21, 9)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 27, 9)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 22, 10)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 28, 10)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 23, 11)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 29, 11)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 24, 12)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 30, 12)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 31, 13)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 37, 13)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 43, 13)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 32, 14)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 38, 14)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 44, 14)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 33, 15)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 39, 15)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 45, 15)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 34, 16)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 40, 16)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 46, 16)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 35, 17)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 41, 17)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 47, 17)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 36, 18)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 42, 18)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 48, 18)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 49, 19)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 50, 19)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 51, 19)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 52, 20)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 58, 20)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 53, 21)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 59, 21)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 54, 22)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 60, 22)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 55, 23)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 61, 23)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 56, 24)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 62, 24)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 57, 25)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 63, 25)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 65, 26)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 71, 26)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 77, 26)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 66, 27)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 72, 27)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 78, 27)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 67, 28)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 73, 28)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 79, 28)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 68, 29)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 74, 29)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 80, 29)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 69, 30)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 75, 30)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 81, 30)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 70, 31)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 76, 31)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 82, 31)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 83, 32)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 89, 32)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 84, 33)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 90, 33)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 85, 34)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 91, 34)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 86, 35)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 92, 35)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 87, 36)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 93, 36)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 88, 37)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 94, 37)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 95, 38)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 101, 38)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 96, 39)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 102, 39)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 97, 40)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 103, 40)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 98, 41)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 104, 41)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 99, 42)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 105, 42)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 100, 43)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 106, 43)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 107, 44)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 113, 44)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 108, 45)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 114, 45)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 109, 46)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 115, 46)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 110, 47)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 116, 47)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 111, 48)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 117, 48)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 112, 49)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 118, 49)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 119, 50)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 120, 50)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 121, 50)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 122, 51)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 123, 51)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 124, 51)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 125, 52)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 126, 52)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 127, 52)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 129, 53)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 130, 53)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 131, 53)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 132, 54)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 133, 54)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 134, 54)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 135, 55)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 136, 55)
        //call SaveInteger(ElixirGroupData, StringHash("Elixir"), 128, 56)
        call SaveInteger(ElixirGroupData, StringHash("Elixir"), 64, 57)
        
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 1, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 2, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 3, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 4, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 5, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 6, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 7, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 8, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 9, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 10, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 11, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 12, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 13, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 14, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 15, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 16, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 17, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 18, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 19, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 20, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 21, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 22, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 23, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 24, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 25, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 26, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 27, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 28, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 29, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 30, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 31, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 32, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 33, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 34, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 35, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 36, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 37, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 38, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 39, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 40, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 41, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 42, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 43, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 44, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 45, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 46, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 47, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 48, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 49, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 50, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 51, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 52, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 53, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 54, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 55, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 56, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 57, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 58, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 59, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 60, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 61, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 62, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 63, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 64, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 65, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 66, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 67, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 68, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 69, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 70, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 71, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 72, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 73, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 74, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 75, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 76, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 77, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 78, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 79, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 80, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 81, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 82, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 83, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 84, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 85, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 86, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 87, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 88, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 89, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 90, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 91, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 92, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 93, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 94, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 95, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 96, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 97, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 98, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 99, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 100, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 101, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 102, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 103, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 104, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 105, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 106, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 107, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 108, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 109, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 110, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 111, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 112, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 113, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 114, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 115, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 116, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 117, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 118, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 119, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 120, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 121, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 122, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 123, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 124, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 125, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 126, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 127, 0)
        //call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 128, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 129, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 130, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 131, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 132, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 133, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 134, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 135, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir2"), 136, 0)

        
        call SaveInteger(ElixirGroupData, StringHash("Elixir3"), 1, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir3"), 2, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir3"), 3, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir3"), 4, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir3"), 5, 0)
        call SaveInteger(ElixirGroupData, StringHash("Elixir3"), 6, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir3"), 7, 1)
        call SaveInteger(ElixirGroupData, StringHash("Elixir3"), 8, 1)

        set ElixirText[1]="이번 연성에서 1번 연성 확률 50% 상승"
        set ElixirText[2]="이번 연성에서 2번 연성 확률 50% 상승"
        set ElixirText[3]="이번 연성에서 3번 연성 확률 50% 상승"
        set ElixirText[4]="이번 연성에서 4번 연성 확률 50% 상승"
        set ElixirText[5]="이번 연성에서 5번 연성 확률 50% 상승"
        set ElixirText[6]="이번 연성에서 선택한 연성 확률 50% 상승"

        set ElixirText[7]="남은 모든 연성에서 1번 연성 확률 10% 상승"
        set ElixirText[8]="남은 모든 연성에서 2번 연성 확률 10% 상승"
        set ElixirText[9]="남은 모든 연성에서 3번 연성 확률 10% 상승"
        set ElixirText[10]="남은 모든 연성에서 4번 연성 확률 10% 상승"
        set ElixirText[11]="남은 모든 연성에서 5번 연성 확률 10% 상승"
        set ElixirText[12]="남은 모든 연성에서 선택한 연성 확률 10% 상승"

        set ElixirText[13]="남은 모든 연성에서 1번 연성 확률 20% 상승"
        set ElixirText[14]="남은 모든 연성에서 2번 연성 확률 20% 상승"
        set ElixirText[15]="남은 모든 연성에서 3번 연성 확률 20% 상승"
        set ElixirText[16]="남은 모든 연성에서 4번 연성 확률 20% 상승"
        set ElixirText[17]="남은 모든 연성에서 5번 연성 확률 20% 상승"
        set ElixirText[18]="남은 모든 연성에서 선택한 연성 확률 20% 상승"

        set ElixirText[19]="남은 모든 연성에서 1번 연성 확률 10% 하락"
        set ElixirText[20]="남은 모든 연성에서 2번 연성 확률 10% 하락"
        set ElixirText[21]="남은 모든 연성에서 3번 연성 확률 10% 하락"
        set ElixirText[22]="남은 모든 연성에서 4번 연성 확률 10% 하락"
        set ElixirText[23]="남은 모든 연성에서 5번 연성 확률 10% 하락"
        set ElixirText[24]="남은 모든 연성에서 선택한 연성 확률 10% 하락"

        set ElixirText[25]="남은 모든 연성에서 1번 연성 확률 20% 하락"
        set ElixirText[26]="남은 모든 연성에서 2번 연성 확률 20% 하락"
        set ElixirText[27]="남은 모든 연성에서 3번 연성 확률 20% 하락"
        set ElixirText[28]="남은 모든 연성에서 4번 연성 확률 20% 하락"
        set ElixirText[29]="남은 모든 연성에서 5번 연성 확률 20% 하락"
        set ElixirText[30]="남은 모든 연성에서 선택한 연성 확률 20% 하락"

        set ElixirText[31]="남은 모든 연성에서 1번 연성 대성공 확률 15% 상승"
        set ElixirText[32]="남은 모든 연성에서 2번 연성 대성공 확률 15% 상승"
        set ElixirText[33]="남은 모든 연성에서 3번 연성 대성공 확률 15% 상승"
        set ElixirText[34]="남은 모든 연성에서 4번 연성 대성공 확률 15% 상승"
        set ElixirText[35]="남은 모든 연성에서 5번 연성 대성공 확률 15% 상승"
        set ElixirText[36]="남은 모든 연성에서 선택한 연성 대성공 확률 15% 상승"

        set ElixirText[37]="남은 모든 연성에서 1번 연성 대성공 확률 30% 상승"
        set ElixirText[38]="남은 모든 연성에서 2번 연성 대성공 확률 30% 상승"
        set ElixirText[39]="남은 모든 연성에서 3번 연성 대성공 확률 30% 상승"
        set ElixirText[40]="남은 모든 연성에서 4번 연성 대성공 확률 30% 상승"
        set ElixirText[41]="남은 모든 연성에서 5번 연성 대성공 확률 30% 상승"
        set ElixirText[42]="남은 모든 연성에서 선택한 연성 대성공 확률 30% 상승"

        set ElixirText[43]="남은 모든 연성에서 1번 연성 대성공 확률 45% 상승"
        set ElixirText[44]="남은 모든 연성에서 2번 연성 대성공 확률 45% 상승"
        set ElixirText[45]="남은 모든 연성에서 3번 연성 대성공 확률 45% 상승"
        set ElixirText[46]="남은 모든 연성에서 4번 연성 대성공 확률 45% 상승"
        set ElixirText[47]="남은 모든 연성에서 5번 연성 대성공 확률 45% 상승"
        set ElixirText[48]="남은 모든 연성에서 선택한 연성 대성공 확률 45% 상승"

        set ElixirText[49]="남은 모든 연성에서 모든 연성 대성공 확률 10% 상승"
        set ElixirText[50]="남은 모든 연성에서 모든 연성 대성공 확률 20% 상승"
        set ElixirText[51]="남은 모든 연성에서 모든 연성 대성공 확률 30% 상승"

        set ElixirText[52]="이번 연성에서 1번 연성"
        set ElixirText[53]="이번 연성에서 2번 연성"
        set ElixirText[54]="이번 연성에서 3번 연성"
        set ElixirText[55]="이번 연성에서 4번 연성"
        set ElixirText[56]="이번 연성에서 5번 연성"
        set ElixirText[57]="이번 연성에서 선택한 대상 연성"
        
        set ElixirText[58]="이번 연성에서 1번 2단계 연성"
        set ElixirText[59]="이번 연성에서 2번 2단계 연성"
        set ElixirText[60]="이번 연성에서 3번 2단계 연성"
        set ElixirText[61]="이번 연성에서 4번 2단계 연성"
        set ElixirText[62]="이번 연성에서 5번 2단계 연성"
        set ElixirText[63]="이번 연성에서 선택한 대상 2단계 연성"

        set ElixirText[64]="이번 연성에서 기회를 소모하지 않고 연성"
        
        set ElixirText[65]="1번 단계 [0~+2]만큼 상승"
        set ElixirText[66]="2번 단계 [0~+2]만큼 상승"
        set ElixirText[67]="3번 단계 [0~+2]만큼 상승"
        set ElixirText[68]="4번 단계 [0~+2]만큼 상승"
        set ElixirText[69]="5번 단계 [0~+2]만큼 상승"
        set ElixirText[70]="선택한 대상 단계 [0~+2]만큼 상승"
        
        set ElixirText[71]="1번 단계 [0~+3]만큼 상승"
        set ElixirText[72]="2번 단계 [0~+3]만큼 상승"
        set ElixirText[73]="3번 단계 [0~+3]만큼 상승"
        set ElixirText[74]="4번 단계 [0~+3]만큼 상승"
        set ElixirText[75]="5번 단계 [0~+3]만큼 상승"
        set ElixirText[76]="선택한 대상 단계 [0~+3]만큼 상승"
        
        set ElixirText[77]="1번 단계 [0~+4]만큼 상승"
        set ElixirText[78]="2번 단계 [0~+4]만큼 상승"
        set ElixirText[79]="3번 단계 [0~+4]만큼 상승"
        set ElixirText[80]="4번 단계 [0~+4]만큼 상승"
        set ElixirText[81]="5번 단계 [0~+4]만큼 상승"
        set ElixirText[82]="선택한 대상 단계 [0~+4]만큼 상승"
        
        set ElixirText[83]="1번 단계 25% 확률로 3 상승"
        set ElixirText[84]="2번 단계 25% 확률로 3 상승"
        set ElixirText[85]="3번 단계 25% 확률로 3 상승"
        set ElixirText[86]="4번 단계 25% 확률로 3 상승"
        set ElixirText[87]="5번 단계 25% 확률로 3 상승"
        set ElixirText[88]="선택한 대상 단계 25% 확률로 3 상승"
        
        set ElixirText[89]="1번 단계 25% 확률로 4 상승"
        set ElixirText[90]="2번 단계 25% 확률로 4 상승"
        set ElixirText[91]="3번 단계 25% 확률로 4 상승"
        set ElixirText[92]="4번 단계 25% 확률로 4 상승"
        set ElixirText[93]="5번 단계 25% 확률로 4 상승"
        set ElixirText[94]="선택한 대상 단계 25% 확률로 4 상승"
        
        set ElixirText[95]="1번 단계 50% 확률로 2 상승"
        set ElixirText[96]="2번 단계 50% 확률로 2 상승"
        set ElixirText[97]="3번 단계 50% 확률로 2 상승"
        set ElixirText[98]="4번 단계 50% 확률로 2 상승"
        set ElixirText[99]="5번 단계 50% 확률로 2 상승"
        set ElixirText[100]="선택한 대상 단계 50% 확률로 2 상승"
        
        set ElixirText[101]="1번 단계 50% 확률로 3 상승"
        set ElixirText[102]="2번 단계 50% 확률로 3 상승"
        set ElixirText[103]="3번 단계 50% 확률로 3 상승"
        set ElixirText[104]="4번 단계 50% 확률로 3 상승"
        set ElixirText[105]="5번 단계 50% 확률로 3 상승"
        set ElixirText[106]="선택한 대상 단계 50% 확률로 3 상승"
        
        set ElixirText[107]="1번 단계 75% 확률로 1 상승"
        set ElixirText[108]="2번 단계 75% 확률로 1 상승"
        set ElixirText[109]="3번 단계 75% 확률로 1 상승"
        set ElixirText[110]="4번 단계 75% 확률로 1 상승"
        set ElixirText[111]="5번 단계 75% 확률로 1 상승"
        set ElixirText[112]="선택한 대상 단계 75% 확률로 1 상승"
        
        set ElixirText[113]="1번 단계 75% 확률로 2 상승"
        set ElixirText[114]="2번 단계 75% 확률로 2 상승"
        set ElixirText[115]="3번 단계 75% 확률로 2 상승"
        set ElixirText[116]="4번 단계 75% 확률로 2 상승"
        set ElixirText[117]="5번 단계 75% 확률로 2 상승"
        set ElixirText[118]="선택한 대상 단계 75% 확률로 2 상승"

        set ElixirText[119]="임의의 대상 1개의 단계 1 상승"
        set ElixirText[120]="임의의 대상 1개의 단계 2 상승"
        set ElixirText[121]="임의의 대상 1개의 단계 3 상승"

        set ElixirText[122]="최하 단계 대상 1개의 단계 1 상승"
        set ElixirText[123]="최하 단계 대상 1개의 단계 2 상승"
        set ElixirText[124]="최하 단계 대상 1개의 단계 3 상승"

        set ElixirText[125]="최고 단계 대상 1개의 단계 1 상승"
        set ElixirText[126]="최고 단계 대상 1개의 단계 2 상승"
        set ElixirText[127]="최고 단계 대상 1개의 단계 3 상승"

        //set ElixirText[128]="모든 단계 재분배"

        set ElixirText[129]="이번 연성은 2단계 상승"
        set ElixirText[130]="이번 연성은 3단계 상승"
        set ElixirText[131]="이번 연성은 4단계 상승"

        set ElixirText[132]="이번 연성에 한해 2회 연성"
        set ElixirText[133]="이번 연성에 한해 3회 연성"
        set ElixirText[134]="이번 연성에 한해 4회 연성"

        set ElixirText[135]="리롤 횟수 1회 증가"
        set ElixirText[136]="리롤 횟수 2회 증가"


        set Elixirweight[1]=0.8
        set Elixirweight[2]=0.8
        set Elixirweight[3]=0.8
        set Elixirweight[4]=0.8
        set Elixirweight[5]=0.8
        set Elixirweight[6]=0.3
        
        set Elixirweight[7]=1.12
        set Elixirweight[8]=1.12
        set Elixirweight[9]=1.12
        set Elixirweight[10]=1.12
        set Elixirweight[11]=1.12
        set Elixirweight[12]=0.42
        
        set Elixirweight[13]=0.48
        set Elixirweight[14]=0.48
        set Elixirweight[15]=0.48
        set Elixirweight[16]=0.48
        set Elixirweight[17]=0.48
        set Elixirweight[18]=0.18
        
        set Elixirweight[19]=1.12
        set Elixirweight[20]=1.12
        set Elixirweight[21]=1.12
        set Elixirweight[22]=1.12
        set Elixirweight[23]=1.12
        set Elixirweight[24]=0.42
        
        set Elixirweight[25]=0.48
        set Elixirweight[26]=0.48
        set Elixirweight[27]=0.48
        set Elixirweight[28]=0.48
        set Elixirweight[29]=0.48
        set Elixirweight[30]=0.18
        
        set Elixirweight[31]=1.30
        set Elixirweight[32]=1.30
        set Elixirweight[33]=1.30
        set Elixirweight[34]=1.30
        set Elixirweight[35]=1.30
        set Elixirweight[36]=0.49
        
        set Elixirweight[37]=0.91
        set Elixirweight[38]=0.91
        set Elixirweight[39]=0.91
        set Elixirweight[40]=0.91
        set Elixirweight[41]=0.91
        set Elixirweight[42]=0.34
        
        set Elixirweight[43]=0.39
        set Elixirweight[44]=0.39
        set Elixirweight[45]=0.39
        set Elixirweight[46]=0.39
        set Elixirweight[47]=0.39
        
        set Elixirweight[48]=0.14
        set Elixirweight[49]=1.24
        set Elixirweight[50]=0.86
        set Elixirweight[51]=0.37
        
        set Elixirweight[52]=0.91
        set Elixirweight[53]=0.91
        set Elixirweight[54]=0.91
        set Elixirweight[55]=0.91
        set Elixirweight[56]=0.91
        set Elixirweight[57]=0.34
        
        set Elixirweight[58]=0.39
        set Elixirweight[59]=0.39
        set Elixirweight[60]=0.39
        set Elixirweight[61]=0.39
        set Elixirweight[62]=0.39
        set Elixirweight[63]=0.15
        
        set Elixirweight[64]=0.60
        
        set Elixirweight[65]=0.70
        set Elixirweight[66]=0.70
        set Elixirweight[67]=0.70
        set Elixirweight[68]=0.70
        set Elixirweight[69]=0.70
        set Elixirweight[70]=0.26
        
        set Elixirweight[71]=0.49
        set Elixirweight[72]=0.49
        set Elixirweight[73]=0.49
        set Elixirweight[74]=0.49
        set Elixirweight[75]=0.49
        set Elixirweight[76]=0.18
        
        set Elixirweight[77]=0.21
        set Elixirweight[78]=0.21
        set Elixirweight[79]=0.21
        set Elixirweight[80]=0.21
        set Elixirweight[81]=0.21
        set Elixirweight[82]=0.08
        
        set Elixirweight[83]=0.98
        set Elixirweight[84]=0.98
        set Elixirweight[85]=0.98
        set Elixirweight[86]=0.98
        set Elixirweight[87]=0.98
        set Elixirweight[88]=0.37
        
        set Elixirweight[89]=0.42
        set Elixirweight[90]=0.42
        set Elixirweight[91]=0.42
        set Elixirweight[92]=0.42
        set Elixirweight[93]=0.42
        set Elixirweight[94]=0.16
        
        set Elixirweight[95]=0.70
        set Elixirweight[96]=0.70
        set Elixirweight[97]=0.70
        set Elixirweight[98]=0.70
        set Elixirweight[99]=0.70
        set Elixirweight[100]=0.26
        
        set Elixirweight[101]=0.30
        set Elixirweight[102]=0.30
        set Elixirweight[103]=0.30
        set Elixirweight[104]=0.30
        set Elixirweight[105]=0.30
        set Elixirweight[106]=0.11
        
        set Elixirweight[107]=0.70
        set Elixirweight[108]=0.70
        set Elixirweight[109]=0.70
        set Elixirweight[110]=0.70
        set Elixirweight[111]=0.70
        set Elixirweight[112]=0.26
        
        set Elixirweight[113]=0.30
        set Elixirweight[114]=0.30
        set Elixirweight[115]=0.30
        set Elixirweight[116]=0.30
        set Elixirweight[117]=0.30
        set Elixirweight[118]=0.11
        
        set Elixirweight[119]=0.94
        set Elixirweight[120]=0.66
        set Elixirweight[121]=0.28
        
        set Elixirweight[122]=0.94
        set Elixirweight[123]=0.66
        set Elixirweight[124]=0.28
        
        set Elixirweight[125]=0.70
        set Elixirweight[126]=0.49
        set Elixirweight[127]=0.21
        
        //set Elixirweight[128]=1.20
        
        set Elixirweight[129]=0.85
        set Elixirweight[130]=0.60
        set Elixirweight[131]=0.25
        
        set Elixirweight[132]=0.85
        set Elixirweight[133]=0.60
        set Elixirweight[134]=0.25
        
        set Elixirweight[135]=1.40
        set Elixirweight[136]=0.60


        //봉인
        set Elixir2Text[1]="1번 봉인"
        set Elixir2Text[2]="2번 봉인"
        set Elixir2Text[3]="3번 봉인"
        set Elixir2Text[4]="4번 봉인"
        set Elixir2Text[5]="5번 봉인"
        set Elixir2Text[6]="선택한 대상 봉인 후, 이번 연성에 한해 2회 연성"
        set Elixir2Text[7]="선택한 대상 봉인 후, 1개의 단계를 1 상승"
        set Elixir2Text[8]="선택한 대상 봉인 후, 최하 단계 1개의 단계를 1 상승"
        
        set Elixir2weight[1]=18.60
        set Elixir2weight[2]=18.60
        set Elixir2weight[3]=18.60
        set Elixir2weight[4]=18.60
        set Elixir2weight[5]=18.60
        set Elixir2weight[6]=2.333
        set Elixir2weight[7]=2.333
        set Elixir2weight[8]=2.333

    //! runtextmacro 이벤트_끝()
endlibrary