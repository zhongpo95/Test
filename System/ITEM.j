library ITEM requires DataItem
    globals
        // 아이템 타입: 0엘릭서, 1무기, 2목걸이, 3귀걸이, 4반지, 5팔찌, 6카드, 7보석
        constant integer ITEM_TYPE_ELIXIR = 0
        constant integer ITEM_TYPE_WEAPON = 1
        constant integer ITEM_TYPE_NECKLACE = 2
        constant integer ITEM_TYPE_EARRING = 3
        constant integer ITEM_TYPE_RING = 4
        constant integer ITEM_TYPE_BRACELET = 5
        constant integer ITEM_TYPE_CARD = 6
        constant integer ITEM_TYPE_GEM = 7

        // 장착 슬롯: 0엘릭서, 1무기, 2목걸이, 3귀걸이1, 4귀걸이2, 5반지1, 6반지2, 7팔찌, 8카드, 9보석
        constant integer EQUIP_SLOT_ELIXIR = 0
        constant integer EQUIP_SLOT_WEAPON = 1
        constant integer EQUIP_SLOT_NECKLACE = 2
        constant integer EQUIP_SLOT_EARRING_1 = 3
        constant integer EQUIP_SLOT_EARRING_2 = 4
        constant integer EQUIP_SLOT_RING_1 = 5
        constant integer EQUIP_SLOT_RING_2 = 6
        constant integer EQUIP_SLOT_BRACELET = 7
        constant integer EQUIP_SLOT_CARD = 8
        constant integer EQUIP_SLOT_GEM = 9
        constant integer EQUIP_SLOT_MAX = 9
    endglobals

        //아이템 타입: 0엘릭서, 1무기, 2목걸이, 3귀걸이, 4반지, 5팔찌, 6카드, 7보석
        //장착 슬롯: 0엘릭서, 1무기, 2목걸이, 3귀걸이1, 4귀걸이2, 5반지1, 6반지2, 7팔찌, 8카드, 9보석
        //장비 0아이템아이디, 1강화수치, 2품질, 3트라이횟수, 4장인의기운
        //악세 0아이템아이디, 1강화수치, 2품질, 3특성, 4각인1, 5각인수치, 6각인2, 7각인수치, 8각인P, 9각인P수치, 10잠금
        //목걸이 0스탯, 1체력, 2품0, 3품질 5당 추가량
        //기타 0아이템아이디, 1중첩수

    //아이디
    function GetItemIDs takes string items returns integer
        local string s = JNStringRegex(items, "ID\\d+;", 0)
        set s = JNStringRegex(s, "\\d+", 0)
        return S2I(s)
    endfunction
    //아이디문자열
    function GetItemIDs2 takes string items returns string
        local string s = JNStringRegex(items, "ID\\d+;", 0)
        set s = JNStringRegex(s, "\\d+", 0)
        return s
    endfunction
    //빈 장비 슬롯 판정
    function IsEmptyItem takes string items returns boolean
        if items == null or items == "" or items == "0" then
            return true
        endif
        return GetItemIDs(items) == 0
    endfunction

    //단일 장착 슬롯 아이템의 슬롯 번호
    function GetEquipSlotByItemType takes integer itemType returns integer
        if itemType == ITEM_TYPE_ELIXIR then
            return EQUIP_SLOT_ELIXIR
        elseif itemType == ITEM_TYPE_WEAPON then
            return EQUIP_SLOT_WEAPON
        elseif itemType == ITEM_TYPE_NECKLACE then
            return EQUIP_SLOT_NECKLACE
        elseif itemType == ITEM_TYPE_BRACELET then
            return EQUIP_SLOT_BRACELET
        elseif itemType == ITEM_TYPE_CARD then
            return EQUIP_SLOT_CARD
        elseif itemType == ITEM_TYPE_GEM then
            return EQUIP_SLOT_GEM
        endif
        return -1
    endfunction

    function GetEquipSlotName takes integer slot returns string
        if slot == EQUIP_SLOT_ELIXIR then
            return "엘릭서"
        elseif slot == EQUIP_SLOT_WEAPON then
            return "무기"
        elseif slot == EQUIP_SLOT_NECKLACE then
            return "목걸이"
        elseif slot == EQUIP_SLOT_EARRING_1 then
            return "귀걸이"
        elseif slot == EQUIP_SLOT_EARRING_2 then
            return "귀걸이"
        elseif slot == EQUIP_SLOT_RING_1 then
            return "반지"
        elseif slot == EQUIP_SLOT_RING_2 then
            return "반지"
        elseif slot == EQUIP_SLOT_BRACELET then
            return "팔찌"
        elseif slot == EQUIP_SLOT_CARD then
            return "카드"
        elseif slot == EQUIP_SLOT_GEM then
            return "보석"
        endif
        return ""
    endfunction

    function GetEquipSlotEmptyArt takes integer slot returns string
        return "UI_Inventory.blp"
    endfunction
    //아이디
    //function GetItemIDs takes string items returns integer
        //return S2I(JNStringSplit(items, ";", 0))
    //endfunction
    //아이디문자열
    //function GetItemIDs2 takes string items returns string
        //return JNStringSplit(items, ";", 0)
    //endfunction
    
    //클래스
    function GetItemClass takes string items returns string
        return EXExecuteScript("(require'jass.slk').item["+I2S(LoadInteger(ItemData, StringHash("ITEMID"), GetItemIDs(items)))+"].class")
    endfunction

    //타입
    function GetItemTypes takes string items returns integer
        local integer raw = -1
        if IsEmptyItem(items) then
            return -1
        endif
        set raw = S2I(EXExecuteScript("(require'jass.slk').item["+I2S(LoadInteger(ItemData, StringHash("ITEMID"), GetItemIDs(items)))+"].Tip"))
        if raw >= ITEM_TYPE_ELIXIR and raw <= ITEM_TYPE_GEM then
            return raw
        endif
        return -1
    endfunction

    //티어
    function GetItemTier takes string items returns integer
        return S2I(EXExecuteScript("(require'jass.slk').item["+I2S(LoadInteger(ItemData, StringHash("ITEMID"), GetItemIDs(items)))+"].Level"))
    endfunction

    //이미지
    function GetItemArt takes string items returns string
        return EXExecuteScript("(require'jass.slk').item["+I2S(LoadInteger(ItemData, StringHash("ITEMID"), GetItemIDs(items)))+"].Art")
    endfunction

    //이미지 번호로 찾기
    function GetItemNumberArt takes integer items returns string
        return EXExecuteScript("(require'jass.slk').item["+I2S(LoadInteger(ItemData, StringHash("ITEMID"), items ))+"].Art")
    endfunction

    //아이템 이름
    function GetItemNames takes string items returns string
        return EXExecuteScript("(require'jass.slk').item["+I2S(LoadInteger(ItemData, StringHash("ITEMID"), GetItemIDs(items)))+"].Name")
    endfunction

    //설명
    function GetItemTip takes string items returns string
        return EXExecuteScript("(require'jass.slk').item["+I2S(LoadInteger(ItemData, StringHash("ITEMID"), GetItemIDs(items)))+"].Ubertip")
    endfunction

    //특성
    function GetItemCombatStats takes string items returns integer
        local string s = JNStringRegex(items, "특성\\d+;", 0)
        set s = JNStringRegex(s, "\\d+", 0)
        return S2I(s)
    endfunction

    //특성변경 set items = SetItemCombatStats(items, 변경할수치(정수))
    function SetItemCombatStats takes string items, integer i returns string
        local string s = JNStringRegex(items, "특성\\d+;", 0)
        if s == "" then
            return items + "특성"+I2S(i)+";"
        endif
        return JNStringReplace(items, JNStringRegex(items, "특성\\d+;", 0), "특성"+I2S(i)+";")
    endfunction

    //강화
    function GetItemUp takes string items returns integer
        local string s = JNStringRegex(items, "강화\\d+;", 0)
        set s = JNStringRegex(s, "\\d+", 0)
        return S2I(s)
    endfunction

    //강화 수치 변경 set items = SetItemUp(items, 변경할수치(정수))
    function SetItemUp takes string items, integer i returns string
        local string s = JNStringRegex(items, "강화\\d+;", 0)
        if s == "" then
            return items + "강화"+I2S(i)+";"
        endif
        return JNStringReplace(items, JNStringRegex(items, "강화\\d+;", 0), "강화"+I2S(i)+";")
    endfunction

    //중첩수
    function GetItemCharge takes string items returns integer
        local string s = JNStringRegex(items, "중첩수\\d+;", 0)
        set s = JNStringRegex(s, "\\d+", 0)
        return S2I(s)
    endfunction

    //중첩수변경 set items = SetItemQuality(items, 변경할수치(정수))
    function SetItemCharge takes string items, integer i returns string
        local string s = JNStringRegex(items, "중첩수\\d+;", 0)
        if s == "" then
            return items + "중첩수"+I2S(i)+";"
        endif
        return JNStringReplace(items, JNStringRegex(items, "중첩수\\d+;", 0), "중첩수"+I2S(i)+";")
    endfunction

    //품질 
    function GetItemQuality takes string items returns integer
        local string s = JNStringRegex(items, "품질\\d+;", 0)
        set s = JNStringRegex(s, "\\d+", 0)
        return S2I(s)
    endfunction

    //품질변경 set items = SetItemQuality(items, 변경할수치(정수))
    function SetItemQuality takes string items, integer i returns string
        local string s = JNStringRegex(items, "품질\\d+;", 0)
        if s == "" then
            return items + "품질"+I2S(i)+";"
        endif
        return JNStringReplace(items, JNStringRegex(items, "품질\\d+;", 0), "품질"+I2S(i)+";")
    endfunction

    //트라이 횟수
    function GetItemTrycount takes string items returns integer
        local string s = JNStringRegex(items, "트라이\\d+;", 0)
        set s = JNStringRegex(s, "\\d+", 0)
        return S2I(s)
    endfunction

    //트라이 횟수 변경 set items = SetItemTrycount(items, 변경할수치(정수))
    function SetItemTrycount takes string items, integer i returns string
        local string s = JNStringRegex(items, "트라이\\d+;", 0)
        if s == "" then
            return items + "트라이"+I2S(i)+";"
        endif
        return JNStringReplace(items, JNStringRegex(items, "트라이\\d+;", 0), "트라이"+I2S(i)+";")
    endfunction

    //장기
    function GetItemFate takes string items returns integer
        local string s = JNStringRegex(items, "장기\\d+;", 0)
        set s = JNStringRegex(s, "\\d+", 0)
        return S2I(s)
    endfunction

    //장기변경 set items = SetItemFate(items, 변경할수치(정수))
    function SetItemFate takes string items, integer i returns string
        local string s = JNStringRegex(items, "장기\\d+;", 0)
        if s == "" then
            return items + "장기"+I2S(i)+";"
        endif
        return JNStringReplace(items, JNStringRegex(items, "장기\\d+;", 0), "장기"+I2S(i)+";")
    endfunction

    //각인
    function GetItemCombatBonus1 takes string items returns integer
        local string s = JNStringRegex(items, "각인\\d+;", 0)
        set s = JNStringRegex(s, "\\d+", 0)
        return S2I(s)
    endfunction
    
    //각인 변경 set items = SetItemCombatBonus1(items, 변경할수치(정수))
    function SetItemCombatBonus1 takes string items, integer i returns string
        local string s = JNStringRegex(items, "각인\\d+;", 0)
        if s == "" then
            return items + "각인"+I2S(i)+";"
        endif
        return JNStringReplace(items, JNStringRegex(items, "각인\\d+;", 0), "각인"+I2S(i)+";")
    endfunction
    
    //각인 수치
    function GetItemCombatBonus2 takes string items returns integer
        local string s = JNStringRegex(items, "각인수치\\d+;", 0)
        set s = JNStringRegex(s, "\\d+", 0)
        return S2I(s)
    endfunction

    //각인 수치 변경 set items = SetItemCombatBonus2(items, 변경할수치(정수))
    function SetItemCombatBonus2 takes string items, integer i returns string
        local string s = JNStringRegex(items, "각인수치\\d+;", 0)
        if s == "" then
            return items + "각인수치"+I2S(i)+";"
        endif
        return JNStringReplace(items, JNStringRegex(items, "각인수치\\d+;", 0), "각인수치"+I2S(i)+";")
    endfunction

    //각인패널티
    function GetItemCombatPenalty takes string items returns integer
        local string s = JNStringRegex(items, "각인P\\d+;", 0)
        set s = JNStringRegex(s, "\\d+", 0)
        return S2I(s)
    endfunction

    //각인패널티 변경 set items = SetItemCombatPenalty(items, 변경할수치(정수))
    function SetItemCombatPenalty takes string items, integer i returns string
        local string s = JNStringRegex(items, "각인P\\d+;", 0)
        if s == "" then
            return items + "각인P"+I2S(i)+";"
        endif
        return JNStringReplace(items, JNStringRegex(items, "각인P\\d+;", 0), "각인P"+I2S(i)+";")
    endfunction

    //각인패널티 수치
    function GetItemCombatPenalty2 takes string items returns integer
        local string s = JNStringRegex(items, "각인P수치\\d+;", 0)
        set s = JNStringRegex(s, "\\d+", 0)
        return S2I(s)
    endfunction

    //각인패널티 수치 변경 set items = SetItemCombatPenalty2(items, 변경할수치(정수))
    function SetItemCombatPenalty2 takes string items, integer i returns string
        local string s = JNStringRegex(items, "각인P수치\\d+;", 0)
        if s == "" then
            return items + "각인P수치"+I2S(i)+";"
        endif
        return JNStringReplace(items, JNStringRegex(items, "각인P수치\\d+;", 0), "각인P수치"+I2S(i)+";")
    endfunction

    //잠금 확인
    function GetItemLock takes string items returns integer
        local string s = JNStringRegex(items, "잠금\\d+;", 0)
        set s = JNStringRegex(s, "\\d+", 0)
        return S2I(s)
    endfunction

    //잠금 변경 set items = SetItemLock(items, 변경할수치(정수)) 
    function SetItemLock takes string items, integer i returns string
        local string s = JNStringRegex(items, "잠금\\d+;", 0)
        if s == "" then
            return items + "잠금"+I2S(i)+";"
        endif
        return JNStringReplace(items, JNStringRegex(items, "잠금\\d+;", 0), "잠금"+I2S(i)+";")
    endfunction

    //카드 앞수치
    function GetItemCardBonus1 takes string items returns integer
        local string s = JNStringRegex(items, "A\\d+;", 0)
        set s = JNStringRegex(s, "\\d+", 0)
        return S2I(s)
    endfunction

    //카드 앞수치 변경 set items = SetItemCombatBonus2(items, 변경할수치(정수))
    function SetItemCardBonus1 takes string items, integer i returns string
        local string s = JNStringRegex(items, "A\\d+;", 0)
        if s == "" then
            return items + "A"+I2S(i)+";"
        endif
        return JNStringReplace(items, JNStringRegex(items, "A\\d+;", 0), "A"+I2S(i)+";")
    endfunction

    //카드 뒷수치
    function GetItemCardBonus2 takes string items returns integer
        local string s = JNStringRegex(items, "B\\d+;", 0)
        set s = JNStringRegex(s, "\\d+", 0)
        return S2I(s)
    endfunction

    //카드 뒷수치 변경 set items = SetItemCombatBonus2(items, 변경할수치(정수))
    function SetItemCardBonus2 takes string items, integer i returns string
        local string s = JNStringRegex(items, "B\\d+;", 0)
        if s == "" then
            return items + "B"+I2S(i)+";"
        endif
        return JNStringReplace(items, JNStringRegex(items, "B\\d+;", 0), "B"+I2S(i)+";")
    endfunction

    //카드 패널티수치
    function GetItemCardBonus3 takes string items returns integer
        local string s = JNStringRegex(items, "C\\d+;", 0)
        set s = JNStringRegex(s, "\\d+", 0)
        return S2I(s)
    endfunction

    //카드 패널티수치 변경 set items = SetItemCombatBonus2(items, 변경할수치(정수))
    function SetItemCardBonus3 takes string items, integer i returns string
        local string s = JNStringRegex(items, "C\\d+;", 0)
        if s == "" then
            return items + "C"+I2S(i)+";"
        endif
        return JNStringReplace(items, JNStringRegex(items, "C\\d+;", 0), "C"+I2S(i)+";")
    endfunction


    
    //엘릭서1 수치
    function GetItemElixirLevel1 takes string items returns integer
        local string s = JNStringRegex(items, "A\\d+;", 0)
        set s = JNStringRegex(s, "\\d+", 0)
        return S2I(s)
    endfunction

    //엘릭서1 수치 변경 set items = SetItemElixirLevel1(items, 변경할수치(정수))
    function SetItemElixirLevel1 takes string items, integer i returns string
        local string s = JNStringRegex(items, "A\\d+;", 0)
        if s == "" then
            return items + "A"+I2S(i)+";"
        endif
        return JNStringReplace(items, JNStringRegex(items, "A\\d+;", 0), "A"+I2S(i)+";")
    endfunction

    //엘릭서2 수치
    function GetItemElixirLevel2 takes string items returns integer
        local string s = JNStringRegex(items, "B\\d+;", 0)
        set s = JNStringRegex(s, "\\d+", 0)
        return S2I(s)
    endfunction

    //엘릭서2 수치 변경 set items = SetItemElixirLevel2(items, 변경할수치(정수))
    function SetItemElixirLevel2 takes string items, integer i returns string
        local string s = JNStringRegex(items, "B\\d+;", 0)
        if s == "" then
            return items + "B"+I2S(i)+";"
        endif
        return JNStringReplace(items, JNStringRegex(items, "B\\d+;", 0), "B"+I2S(i)+";")
    endfunction

    //보석 레벨
    function GetItemGemLevel takes string items returns integer
        local string s = JNStringRegex(items, "G\\d+;", 0)
        local integer level = 0
        set s = JNStringRegex(s, "\\d+", 0)
        set level = S2I(s)
        if level > 10 then
            return 10
        elseif level < 1 then
            return 1
        endif
        return level
    endfunction

    //보석 레벨 변경 set items = SetItemGemLevel(items, 변경할수치(1~10))
    function SetItemGemLevel takes string items, integer i returns string
        local string s = JNStringRegex(items, "G\\d+;", 0)
        if i > 10 then
            set i = 10
        elseif i < 1 then
            set i = 1
        endif
        if s == "" then
            return items + "G"+I2S(i)+";"
        endif
        return JNStringReplace(items, JNStringRegex(items, "G\\d+;", 0), "G"+I2S(i)+";")
    endfunction

endlibrary
