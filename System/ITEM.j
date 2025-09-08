library ITEM requires DataItem
    globals
    endglobals

        //0보조무기무기, 1상의, 2하의, 3장갑, 4견갑, 5무기, 6목걸이, 7귀걸이, 8반지, 9팔찌, 10카드
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
        return S2I(EXExecuteScript("(require'jass.slk').item["+I2S(LoadInteger(ItemData, StringHash("ITEMID"), GetItemIDs(items)))+"].Tip"))
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

endlibrary