function SaveLoad__SLAbiliSyncEnd takes nothing returns nothing
    local player p=JNGetTriggerSyncPlayer()
    local integer pid=GetPlayerId(p)
    local integer playerarray=8*pid
    local integer i=0
    call AddState(p,AbilityState_ActiveAbilityName[playerarray],AbilityState_ActiveAbilityValue[playerarray])
    call AddState(p,AbilityState_ActiveAbilityName[playerarray+1],AbilityState_ActiveAbilityValue[playerarray+1])
    call AddState(p,AbilityState_ActiveAbilityName[playerarray+2],AbilityState_ActiveAbilityValue[playerarray+2])
    call AddState(p,AbilityState_ActiveAbilityName[playerarray+3],AbilityState_ActiveAbilityValue[playerarray+3])
    if GetLocalPlayer()==p then
    call AbilityState_AbilityFrameText(0,AbilityState_ActiveAbilityName[playerarray],AbilityState_ActiveAbilityValue[playerarray])
    call AbilityState_AbilityFrameText(1,AbilityState_ActiveAbilityName[playerarray+1],AbilityState_ActiveAbilityValue[playerarray+1])
    call AbilityState_AbilityFrameText(2,AbilityState_ActiveAbilityName[playerarray+2],AbilityState_ActiveAbilityValue[playerarray+2])
    call AbilityState_AbilityFrameText(3,AbilityState_ActiveAbilityName[playerarray+3],AbilityState_ActiveAbilityValue[playerarray+3])
    endif
    endfunction
    function SaveLoad_CharacterStart takes integer pid,integer ucode returns nothing
    local string str=LoadStr(CharacterSlot_CharacterInfoHash,ucode,CharacterSlot_CharacterName)
    local string str2
    local string abili
    local string abili2
    local integer i=0
    set str=JNStringReplace(str,"|n"," ")
    call JNObjectCharacterInit(MapId,SaveLoad_PlayerName[pid],SecretKey,str)
    if JNObjectCharacterGetBoolean(SaveLoad_PlayerName[pid],"LoadBol")then
    call DzSyncData("JNGetData","Silver_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Silver")))
    call DzSyncData("JNGetData","Gold_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Gold")))
    call DzSyncData("JNGetData","Crystal_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Crystal")))
    call DzSyncData("JNGetData","Challenge1_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Challenge1")))
    call DzSyncData("JNGetData","Challenge2_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Challenge2")))
    call DzSyncData("JNGetData","Mines_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Mines")))
    call DzSyncData("JNGetData","Crops_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Crops")))
    call DzSyncData("JNGetData","LiveLV_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"LiveLV")))
    call DzSyncData("JNGetData","LiveEXP_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"LiveEXP")))
    call DzSyncData("JNGetData","HeroLV_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"HeroLV")))
    call DzSyncData("JNGetData","HeroEX_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"HeroEX")))
    call DzSyncData("JNGetData","IMS_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"IMS")))
    call DzSyncData("JNGetData","ITS_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"ITS")))
    call DzSyncData("JNGetData","IGS_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"IGS")))
    call DzSyncData("JNGetData","IAS_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"IAS")))
    call DzSyncData("JNGetData","IHS_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"IHS")))
    call DzSyncData("JNGetData","IRS_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"IRS")))
    call DzSyncData("JNGetData","HeroHP_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"HeroHP")))
    call DzSyncData("JNGetData","pauto_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"pauto")))
    call DzSyncData("JNGetDatS","Achieve_"+JNObjectCharacterGetString(SaveLoad_PlayerName[pid],"업적"))
    set str2=JNObjectCharacterGetString(SaveLoad_PlayerName[pid],"PT")
    set PH=S2I(JNStringSplit(str2," : ",0))
    set PM=S2I(JNStringSplit(str2," : ",1))
    set PS=S2I(JNStringSplit(str2," : ",2))
    set PotionSystem_PotionData=JNObjectCharacterGetString(SaveLoad_PlayerName[pid],"PotionData")
    set PotionSystem_PotionTimeValue=JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"PotionVlaue")
    set PotionSystem_PotionCouPonData=JNObjectCharacterGetString(SaveLoad_PlayerName[pid],"PotionCoupon")
    call JNWriteLog("========================================================")
    call JNWriteLog("======================SaveLoad==========================")
    set abili=JNObjectCharacterGetString(SaveLoad_PlayerName[pid],"Abil1")
    call JNWriteLog("Abili1 - "+abili)
    if abili!=null or abili!="" then
    set abili2=R2S(JNObjectCharacterGetReal(SaveLoad_PlayerName[pid],"Abil1Value"))
    call JNWriteLog("Abili1V - "+abili2)
    call DzSyncData("SLAbili","0|"+abili+"|"+abili2)
    endif
    set abili=JNObjectCharacterGetString(SaveLoad_PlayerName[pid],"Abil2")
    call JNWriteLog("Abili2 - "+abili)
    if abili!=null or abili!="" then
    set abili2=R2S(JNObjectCharacterGetReal(SaveLoad_PlayerName[pid],"Abil2Value"))
    call JNWriteLog("Abili2V - "+abili2)
    call DzSyncData("SLAbili","1|"+abili+"|"+abili2)
    endif
    set abili=JNObjectCharacterGetString(SaveLoad_PlayerName[pid],"Abil3")
    call JNWriteLog("Abili3 - "+abili)
    if abili!=null or abili!="" then
    set abili2=R2S(JNObjectCharacterGetReal(SaveLoad_PlayerName[pid],"Abil3Value"))
    call JNWriteLog("Abili3V - "+abili2)
    call DzSyncData("SLAbili","2|"+abili+"|"+abili2)
    endif
    set abili=JNObjectCharacterGetString(SaveLoad_PlayerName[pid],"Abil4")
    call JNWriteLog("Abili4 - "+abili)
    if abili!=null or abili!="" then
    set abili2=R2S(JNObjectCharacterGetReal(SaveLoad_PlayerName[pid],"Abil4Value"))
    call JNWriteLog("Abili4V - "+abili2)
    call DzSyncData("SLAbili","3|"+abili+"|"+abili2)
    endif
    call JNWriteLog("========================================================")
    loop
    exitwhen i==6
    call DzSyncData("JNGetData","CharacterItem"+I2S(i)+"_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"CharacterItem"+I2S(i))))
    call DzSyncData("JNGetData","CharacterItem"+I2S(i)+"Char_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"CharacterItem"+I2S(i)+"Char")))
    set i=i+1
    endloop
    set i=0
    loop
    exitwhen i==6
    call DzSyncData("JNGetData","Bag1Item"+I2S(i)+"_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Bag1Item"+I2S(i))))
    call DzSyncData("JNGetData","Bag1Item"+I2S(i)+"Char_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Bag1Item"+I2S(i)+"Char")))
    set i=i+1
    endloop
    set i=0
    loop
    exitwhen i==6
    call DzSyncData("JNGetData","Bag2Item"+I2S(i)+"_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Bag2Item"+I2S(i))))
    call DzSyncData("JNGetData","Bag2Item"+I2S(i)+"Char_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Bag2Item"+I2S(i)+"Char")))
    set i=i+1
    endloop
    set i=0
    loop
    exitwhen i==6
    call DzSyncData("JNGetData","Bag3Item"+I2S(i)+"_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Bag3Item"+I2S(i))))
    call DzSyncData("JNGetData","Bag3Item"+I2S(i)+"Char_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Bag3Item"+I2S(i)+"Char")))
    set i=i+1
    endloop
    set i=0
    loop
    exitwhen i==6
    call DzSyncData("JNGetData","Bag4Item"+I2S(i)+"_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Bag4Item"+I2S(i))))
    call DzSyncData("JNGetData","Bag4Item"+I2S(i)+"Char_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Bag4Item"+I2S(i)+"Char")))
    set i=i+1
    endloop
    set i=0
    loop
    exitwhen i==6
    call DzSyncData("JNGetData","Bag5Item"+I2S(i)+"_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Bag5Item"+I2S(i))))
    call DzSyncData("JNGetData","Bag5Item"+I2S(i)+"Char_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Bag5Item"+I2S(i)+"Char")))
    set i=i+1
    endloop
    set i=0
    loop
    exitwhen i==6
    call DzSyncData("JNGetData","Bag6Item"+I2S(i)+"_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Bag6Item"+I2S(i))))
    call DzSyncData("JNGetData","Bag6Item"+I2S(i)+"Char_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Bag6Item"+I2S(i)+"Char")))
    set i=i+1
    endloop
    set i=0
    loop
    exitwhen i==6
    call DzSyncData("JNGetData","Bag7Item"+I2S(i)+"_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Bag7Item"+I2S(i))))
    call DzSyncData("JNGetData","Bag7Item"+I2S(i)+"Char_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Bag7Item"+I2S(i)+"Char")))
    set i=i+1
    endloop
    set i=0
    loop
    exitwhen i==6
    call DzSyncData("JNGetData","Bag8Item"+I2S(i)+"_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Bag8Item"+I2S(i))))
    call DzSyncData("JNGetData","Bag8Item"+I2S(i)+"Char_"+I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Bag8Item"+I2S(i)+"Char")))
    set i=i+1
    endloop
    call DzSyncData("JNGetDato",JNObjectCharacterGetString(SaveLoad_PlayerName[pid],"Decorate"))
    call DzSyncData("LoadStart",I2S(JNObjectCharacterGetInt(SaveLoad_PlayerName[pid],"Character")))
    call DzSyncData("EmSync","날개|"+JNObjectCharacterGetString(SaveLoad_PlayerName[pid],"Wing"))
    call DzSyncData("EmSync","탈것|"+JNObjectCharacterGetString(SaveLoad_PlayerName[pid],"Bike"))
    call DzSyncData("EmSync","폰트|"+JNObjectCharacterGetString(SaveLoad_PlayerName[pid],"Font"))
    call DzSyncData("EmSync","가방|"+JNObjectCharacterGetString(SaveLoad_PlayerName[pid],"Bag"))
    else
    call DzSyncData("NewStart",I2S(ucode))
    endif
    call DzSyncData("SyncCode",I2S(pid))
    endfunction

    function ui takes integer Lp,string TY returns nothing
        local integer GN=0
        local integer Tf=0
        local integer Td=0
        set TZ[Lp]=TY
        set Mf[Lp]=0
        call FlushChildHashtable(BJ,Lp)
        if GetLocalPlayer()==Player(Lp) then
        set GN=JNObjectCharacterInit(Ta,TY,Tb,Tc)
        if GN!=0 then
        call DzSyncData(Me,"로드실패 : JN 연결 실패")
        return
        endif
        set Td=JNObjectCharacterGetInt(TY,Te)
        if Td<0 then
        call DzSyncData(Me,"로드실패 : 데이터 손상됨")
        return
        endif
        loop
        exitwhen Tf>=Td
        if GetLocalPlayer()==Player(Lp) then
        call DzSyncData(Mg,JNObjectCharacterGetString(TY,Tg+"."+I2S(Tf)))
        endif
        set Tf=Tf+1
        endloop
        call DzSyncData(Me,"로드가 성공적으로 되었습니다.")
        endif
        endfunction