scope ESC initializer init
    globals
        integer i = 0
        string s = "12;1;1;2;3;45;1;3;45;6;1;각인A32;각인A수치99999;123123;"
    endglobals

    private function ESCAction2 takes nothing returns nothing
        call BJDebugMsg("ESC")

        set i = i + 1

        if i == 1 then
            call BJDebugMsg("이전가격 : "+I2S(Price[1]))
            call MarketDataDownload(GetPlayerId(GetTriggerPlayer()))
            call BJDebugMsg(I2S(Price[1]))
        elseif i == 2 then
            set Price[1] = Price[1] + 1
            call MarketDataUpload(GetPlayerId(GetTriggerPlayer()),1,Price[1])
            call BJDebugMsg("Price[1] : "+I2S(Price[1]))
            set i = 0
        endif

    endfunction
    
    private function ESCAction takes nothing returns nothing
        local integer i = 0

        set s = "7;"
        set s = SetItemGetItemCombatStats(s, GetRandomInt(1,3))
        set s = SetItemQuality(s, (Quality.pick(false)-1) )
        call additem(Player(0), s)
        //call BJDebugMsg(JNStringRegex(s, "품질\\d+;", 0))
        //set s = JNStringReplace(s, JNStringRegex(s, "품질\\d+;", 0), "품질22;")
        //call BJDebugMsg("바꾼후 : "+s)
        //call BJDebugMsg("ESC")
        //call TodayQuestPlus(0)
    endfunction

    private function init takes nothing returns nothing
        local trigger t=CreateTrigger()
        //esc버튼
        set t = CreateTrigger()
        call TriggerRegisterPlayerEvent(t, Player(0), EVENT_PLAYER_END_CINEMATIC)
        call TriggerAddAction( t, function ESCAction )
        set t = null
        set Price[1] = 10000
    endfunction

endscope