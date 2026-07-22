// 메인퀘스트 초반 안내와 짧은 저장 키 관리
library UIMainQuest initializer Init requires FrameCount, UIItem
    globals
        private integer F_MQBackDrop
        private integer F_MQTitleText
        private integer F_MQBodyText
        private constant integer MQ_STEP_INHERIT = 1
        private constant integer MQ_STEP_BOSS1 = 2
        private constant integer MQ_STEP_ENCHANT = 3
        private constant integer MQ_STEP_WAIT = 4
        private constant integer MQ_BOSS1_GOLD = 100
    endglobals

    // Q = 메인퀘스트 단계, QB = 첫 보스 처치 카운터.
    private function MainQuestKey takes integer heroNumber, string key returns string
        return "영웅"+I2S(heroNumber)+"."+key
    endfunction

    function MainQuestBoss1Gold takes nothing returns integer
        return MQ_BOSS1_GOLD
    endfunction

    function MainQuestGetStep takes integer pid, integer heroNumber returns integer
        return S2I(StashLoad(PLAYER_DATA[pid], MainQuestKey(heroNumber, "Q"), "0"))
    endfunction

    private function MainQuestSetStep takes integer pid, integer heroNumber, integer step returns nothing
        call StashSave(PLAYER_DATA[pid], MainQuestKey(heroNumber, "Q"), I2S(step))
    endfunction

    private function MainQuestSetBossCount takes integer pid, integer heroNumber, integer count returns nothing
        call StashSave(PLAYER_DATA[pid], MainQuestKey(heroNumber, "QB"), I2S(count))
    endfunction

    function MainQuestRefresh takes integer pid, integer heroNumber returns nothing
        local integer step = MainQuestGetStep(pid, heroNumber)
        if GetLocalPlayer() == Player(pid) then
            if step == MQ_STEP_INHERIT then
                call DzFrameSetText(F_MQTitleText, "|cFFFFE400목표|r")
                call DzFrameSetText(F_MQBodyText, "강화 NPC에게 가서 시작 무기를 계승하세요.")
                call DzFrameShow(F_MQBackDrop, true)
            elseif step == MQ_STEP_BOSS1 then
                call DzFrameSetText(F_MQTitleText, "|cFFFFE400목표|r")
                call DzFrameSetText(F_MQBodyText, "첫 보스를 처치하고 다음 강화에 쓸 골드를 얻으세요.")
                call DzFrameShow(F_MQBackDrop, true)
            elseif step == MQ_STEP_ENCHANT then
                call DzFrameSetText(F_MQTitleText, "|cFFFFE400목표|r")
                call DzFrameSetText(F_MQBodyText, "첫 보스 보상 골드로 무기를 한 번 강화하세요.")
                call DzFrameShow(F_MQBackDrop, true)
            elseif step == MQ_STEP_WAIT then
                call DzFrameSetText(F_MQTitleText, "|cFFFFE400목표|r")
                call DzFrameSetText(F_MQBodyText, "초반 강화가 완료되었습니다.|n다음 안내는 이후 보스 보상 작업에서 이어집니다.")
                call DzFrameShow(F_MQBackDrop, true)
            else
                call DzFrameShow(F_MQBackDrop, false)
            endif
        endif
    endfunction

    function MainQuestNew takes integer pid, integer heroNumber returns nothing
        call MainQuestSetStep(pid, heroNumber, MQ_STEP_INHERIT)
        call MainQuestSetBossCount(pid, heroNumber, 0)
        call MainQuestRefresh(pid, heroNumber)
    endfunction

    function MainQuestLoad takes integer pid, integer heroNumber, integer weaponId, integer weaponUp returns nothing
        local integer step = MainQuestGetStep(pid, heroNumber)
        if step == 0 then
            if weaponId == 10 then
                set step = MQ_STEP_INHERIT
            elseif weaponId == 3 and weaponUp == 0 then
                set step = MQ_STEP_BOSS1
            elseif weaponId == 3 and weaponUp > 0 then
                set step = MQ_STEP_WAIT
            else
                set step = MQ_STEP_BOSS1
            endif
            call MainQuestSetStep(pid, heroNumber, step)
            call MainQuestSetBossCount(pid, heroNumber, 0)
        endif
        call MainQuestRefresh(pid, heroNumber)
    endfunction

    function MainQuestAfterFirstSuccess takes integer pid, integer heroNumber returns nothing
        if MainQuestGetStep(pid, heroNumber) == MQ_STEP_INHERIT then
            call MainQuestSetStep(pid, heroNumber, MQ_STEP_BOSS1)
            call MainQuestRefresh(pid, heroNumber)
        endif
    endfunction

    function MainQuestAfterGoldEnchant takes integer pid, integer heroNumber, integer tier, integer up returns nothing
        if MainQuestGetStep(pid, heroNumber) == MQ_STEP_ENCHANT and tier == 2 and up >= 1 then
            call MainQuestSetStep(pid, heroNumber, MQ_STEP_WAIT)
            call MainQuestRefresh(pid, heroNumber)
        endif
    endfunction

    function MainQuestAddGold takes player p, integer amount returns nothing
        local integer pid = GetPlayerId(p)
        local integer gold = 0
        if GetLocalPlayer() == p then
            set gold = S2I(StashLoad(PLAYER_DATA[pid], "골드", "0")) + amount
            call StashSave(PLAYER_DATA[pid], "골드", I2S(gold))
            call DzFrameSetText(F_GoldText, I2S(gold))
            call VJDebugMsg("골드 "+I2S(amount)+" 획득")
        endif
    endfunction

    function MainQuestAfterBoss1 takes player p, integer heroNumber returns nothing
        local integer pid = GetPlayerId(p)
        local integer count = 0
        if GetLocalPlayer() == p then
            set count = S2I(StashLoad(PLAYER_DATA[pid], MainQuestKey(heroNumber, "QB"), "0")) + 1
            call MainQuestSetBossCount(pid, heroNumber, count)
            if MainQuestGetStep(pid, heroNumber) == MQ_STEP_BOSS1 then
                call MainQuestSetStep(pid, heroNumber, MQ_STEP_ENCHANT)
            endif
            call MainQuestRefresh(pid, heroNumber)
        endif
    endfunction

    private function Init takes nothing returns nothing
        set F_MQBackDrop = DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetTexture(F_MQBackDrop, "QuestT.blp", 0)
        call DzFrameSetAbsolutePoint(F_MQBackDrop, JN_FRAMEPOINT_TOPLEFT, 0.000, 0.540)
        call DzFrameSetSize(F_MQBackDrop, 0.250, 0.060)
        call DzFrameSetAlpha(F_MQBackDrop, 220)
        set F_MQTitleText = DzCreateFrameByTagName("TEXT", "", F_MQBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_MQTitleText, JN_FRAMEPOINT_TOPLEFT, F_MQBackDrop, JN_FRAMEPOINT_TOPLEFT, 0.010, -0.014)
        call DzFrameSetSize(F_MQTitleText, 0.230, 0.014)
        call DzFrameSetFont(F_MQTitleText, "Fonts\\DFHeiMd.ttf", 0.010, 0)
        call DzFrameSetText(F_MQTitleText, "|cFFFFE400목표|r")
        set F_MQBodyText = DzCreateFrameByTagName("TEXT", "", F_MQBackDrop, "", FrameCount())
        call DzFrameSetPoint(F_MQBodyText, JN_FRAMEPOINT_TOPLEFT, F_MQBackDrop, JN_FRAMEPOINT_TOPLEFT, 0.010, -0.030)
        call DzFrameSetSize(F_MQBodyText, 0.230, 0.030)
        call DzFrameSetFont(F_MQBodyText, "Fonts\\DFHeiMd.ttf", 0.009, 0)
        call DzFrameSetText(F_MQBodyText, "")
        call DzFrameShow(F_MQBackDrop, false)
    endfunction
endlibrary
