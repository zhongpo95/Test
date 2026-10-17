// 세이브 v2 P2(10 4.7) 전용: ArcanaSaveData 와 같은 공개 함수를 지금 Stash(PLAYER_DATA)와 v1 키로 처리하는 얇은 판. P3 에서 Library\ArcanaSaveData.j(해시테이블)로 바꾼다.
library ArcanaSaveData requires Stash, ArcanaSaveNet3Natives, ArcanaSaveItemData

    // 이 판의 목적은 "접근 함수로 바꿔도 동작과 저장 문서가 그대로"를 2인 실게임으로 확인하는 것이다(10 4.7).
    // 그래서 쓰기는 예전 호출부가 쓰던 값을 그대로 쓴다(검사·빈 칸 정리 없음). 비운 칸(null)은 StashRemove.
    // Stash 읽기·쓰기(StashLoad/StashSave/StashRemove)는 ForForce 를 쓰지 않는다(멀티_끊김_조사 19절).

    globals
        constant integer ARCANA_SAVE_SCHEMA = 1
        constant integer ARCANA_SAVE_ITEM_MAX = 200
        constant integer ARCANA_SAVE_INT_MAX = 2000000000
        constant integer ARCANA_SF_GOLD = 0
        constant integer ARCANA_SF_BIGWHEEL = 1
        constant integer ARCANA_SF_TOTALDAILY = 2
        constant integer ARCANA_SF_DAILYLAST = 3
        constant integer ARCANA_HF_SKIN = 0
        constant integer ARCANA_HF_LOGINS = 1
        constant integer ARCANA_HF_Q = 2
        constant integer ARCANA_HF_QB = 3
        constant integer ARCANA_HF_TQUEST = 4
        constant integer ARCANA_HF_X_STORE = 5
        constant integer ARCANA_HF_X_WIN = 6
        constant integer ARCANA_HF_X_DONE = 7
        constant integer ARCANA_CODEX_CARD = 0
        constant integer ARCANA_CODEX_AWAKE = 1
        constant integer ARCANA_CODEX_HEAD = 2
    endglobals

    private function AccKey takes integer f returns string
        if f == ARCANA_SF_GOLD then
            return "골드"
        elseif f == ARCANA_SF_BIGWHEEL then
            return "BigWheelCount"
        elseif f == ARCANA_SF_TOTALDAILY then
            return "Totaldaily"
        endif
        return "daily.last"
    endfunction

    private function HeroIntKey takes integer h, integer f returns string
        if f == ARCANA_HF_SKIN then
            return "영웅" + I2S(h) + ".skin"
        elseif f == ARCANA_HF_LOGINS then
            return "영웅" + I2S(h) + ".logins"
        elseif f == ARCANA_HF_Q then
            return "영웅" + I2S(h) + ".Q"
        elseif f == ARCANA_HF_QB then
            return "영웅" + I2S(h) + ".QB"
        elseif f == ARCANA_HF_TQUEST then
            return "슬롯" + I2S(h) + ".TQuest"
        elseif f == ARCANA_HF_X_STORE then
            return "영웅" + I2S(h) + ".시험원정.보관재료"
        elseif f == ARCANA_HF_X_WIN then
            return "영웅" + I2S(h) + ".시험원정.전투승리"
        endif
        return "영웅" + I2S(h) + ".시험원정.완주"
    endfunction

    private function CodexKey takes integer kind, integer id returns string
        if kind == ARCANA_CODEX_HEAD then
            return PROTO_SAVE_PREFIX + "머리도감." + ProtoHeadKey[id]
        elseif kind == ARCANA_CODEX_AWAKE then
            return PROTO_SAVE_PREFIX + "카드각성도감." + ProtoCardKey[id]
        endif
        return PROTO_SAVE_PREFIX + "카드도감." + ProtoCardKey[id]
    endfunction

    private function Put takes integer pid, string k, string v returns nothing
        if v == null then
            call StashRemove(PLAYER_DATA[pid], k)
        else
            call StashSave(PLAYER_DATA[pid], k, v)
        endif
    endfunction

    function ArcanaSaveIsEmptyItem takes string v returns boolean
        return v == null or v == "" or v == "0" or v == "없음"
    endfunction

    function ArcanaSaveGetInt takes integer pid, integer f returns integer
        return S2I(StashLoad(PLAYER_DATA[pid], AccKey(f), "0"))
    endfunction

    function ArcanaSaveSetInt takes integer pid, integer f, integer v returns nothing
        call StashSave(PLAYER_DATA[pid], AccKey(f), I2S(v))
    endfunction

    function ArcanaSaveAddGold takes integer pid, integer d returns boolean
        call ArcanaSaveSetInt(pid, ARCANA_SF_GOLD, ArcanaSaveGetInt(pid, ARCANA_SF_GOLD) + d)
        return true
    endfunction

    function ArcanaSaveSkinOwned takes integer pid, integer hero, integer skin returns boolean
        local string v = StashLoad(PLAYER_DATA[pid], "계정.skin." + I2S(hero) + "." + I2S(skin), "0")
        return v != null and v != "" and v != "0"
    endfunction

    function ArcanaSaveSetSkinOwned takes integer pid, integer hero, integer skin returns nothing
        call StashSave(PLAYER_DATA[pid], "계정.skin." + I2S(hero) + "." + I2S(skin), "1")
    endfunction

    function ArcanaSaveHeroExists takes integer pid, integer h returns boolean
        local string v = StashLoad(PLAYER_DATA[pid], "영웅" + I2S(h), null)
        return not (v == null or v == "" or v == "없음")
    endfunction

    function ArcanaSaveHeroCreate takes integer pid, integer h, integer skin returns nothing
        call StashSave(PLAYER_DATA[pid], "영웅" + I2S(h), I2S(h))
        call StashSave(PLAYER_DATA[pid], "영웅" + I2S(h) + ".skin", I2S(skin))
    endfunction

    function ArcanaSaveHeroInt takes integer pid, integer h, integer f returns integer
        return S2I(StashLoad(PLAYER_DATA[pid], HeroIntKey(h, f), "0"))
    endfunction

    function ArcanaSaveSetHeroInt takes integer pid, integer h, integer f, integer v returns nothing
        call StashSave(PLAYER_DATA[pid], HeroIntKey(h, f), I2S(v))
    endfunction

    function ArcanaSaveEquip takes integer pid, integer h, integer s, string def returns string
        return StashLoad(PLAYER_DATA[pid], "영웅" + I2S(h) + ".E" + I2S(s), def)
    endfunction

    function ArcanaSaveSetEquip takes integer pid, integer h, integer s, string itemStr returns nothing
        call Put(pid, "영웅" + I2S(h) + ".E" + I2S(s), itemStr)
    endfunction

    function ArcanaSaveInv takes integer pid, integer h, integer s, string def returns string
        return StashLoad(PLAYER_DATA[pid], "영웅" + I2S(h) + ".아이템" + I2S(s), def)
    endfunction

    function ArcanaSaveSetInv takes integer pid, integer h, integer s, string itemStr returns nothing
        call Put(pid, "영웅" + I2S(h) + ".아이템" + I2S(s), itemStr)
    endfunction

    function ArcanaSaveStore takes integer pid, integer s, string def returns string
        return StashLoad(PLAYER_DATA[pid], "창고" + I2S(s), def)
    endfunction

    function ArcanaSaveSetStore takes integer pid, integer s, string itemStr returns nothing
        call Put(pid, "창고" + I2S(s), itemStr)
    endfunction

    function ArcanaSaveCodexHas takes integer pid, integer kind, integer id returns boolean
        return StashLoad(PLAYER_DATA[pid], CodexKey(kind, id), "0") == "1"
    endfunction

    // 머리 도감 동기화 패킷용("1"/"0")
    function ArcanaSaveCodexFlag takes integer pid, integer kind, integer id returns string
        return StashLoad(PLAYER_DATA[pid], CodexKey(kind, id), "0")
    endfunction

    function ArcanaSaveCodexAdd takes integer pid, integer kind, integer id returns nothing
        call StashSave(PLAYER_DATA[pid], CodexKey(kind, id), "1")
    endfunction

    // P2 판에서는 세지 않는다(게임 코드가 쓰지 않음, 개발 명령은 P3 판에서만)
    function ArcanaSaveCodexCount takes integer pid, integer kind returns integer
        return 0
    endfunction

endlibrary
