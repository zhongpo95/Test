library UISkillLevel initializer init requires DataUnit, FrameCount
    globals
        integer FS_OpenButton                       //스킬창 여는 버튼
        integer FS_OpenButtonBD                     //스킬창 여는 버튼 백드롭
        integer FS_BackDrop                         //스킬창 배경
        integer FS_CombinationText                  //스킬창 텍스트
        integer FS_SPTEXT                           //구 스킬포인트 텍스트 호환용
        integer FS_SPTEXTV                          //구 스킬포인트 값 호환용
        integer FS_TemplateBackDrop                 //스킬창 스킬공간
        integer FS_TemplateText                     //스킬창 스킬설명
        integer FS_CancelButton                     //스킬창 취소버튼
        integer array FS_Button                     //스킬버튼
        integer array FS_ButtonBackDrop             //스킬버튼 백드롭
        integer array FS_ButtonTEXT                 //스킬버튼 텍스트

        boolean array FS_OnOff                      //플레이어 온오프

        //전역변수
        integer array HeroSkillLevel[13][8]
        integer array HeroSkillPoint[13]
    endglobals

    private function F_OFF_Actions takes nothing returns nothing
        call DzFrameShow(UI_Tip, false)
    endfunction

        //call DzFrameSetText(FS_ButtonTEXT[0], EXGetAbilityString(HeroSkillID0[index],1,ABILITY_DATA_TIP) )

    private function F_ON_Actions takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer index = DataUnitIndex(MainUnit[pid])
        local string str = ""
        local string items = ""
        local integer itemid = 0
        local integer i = 99999
        local integer quality = 0
        local integer up = 0
        local integer cts = 0
        local integer tier = 0
        local item tem
        if f ==  FS_Button[0] then
            call DzFrameSetText(UI_Tip_Text[1], EXGetAbilityString(HeroSkillID0[index],1,ABILITY_DATA_TIP) )
            if JNStringContains(HeroSkillTpye0[index], "버프") then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye0[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr0[index]
                set str = str + "|r|n|n|n  |cFFB9E2FA수치|r : "+I2S(R2I(HeroSkillVelue0[index]*100))+" %"
            elseif HeroSkillVCount0[index] == 1 then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye0[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr0[index]
                set str = str + "|r|n|n  |cFFB9E2FA피해량|r : "+I2S( R2I( HeroSkillVelue0[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
            elseif HeroSkillVCount0[index] == 2 then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye0[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr0[index]
                set str = str + "|r|n|n  |cFFB9E2FA피해량|r : "+I2S( R2I( HeroSkillVelue0[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
                set str = str + "|r|n  |cFFB9E2FA피해량2|r : "+I2S( R2I( HeroSkillVelue20[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
            endif
            call DzFrameSetText(UI_Tip_Text[2], str )
            call DzFrameShow(UI_Tip, true)
            set i = 0
        elseif f == FS_Button[1] then
            call DzFrameSetText(UI_Tip_Text[1], EXGetAbilityString(HeroSkillID1[index],1,ABILITY_DATA_TIP) )
            if JNStringContains(HeroSkillTpye1[index], "버프") then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye1[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr1[index]
                set str = str + "|r|n|n|n  |cFFB9E2FA수치|r : "+I2S(R2I(HeroSkillVelue1[index]*100))+" %"
            elseif HeroSkillVCount1[index] == 1 then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye1[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr1[index]
                set str = str + "|r|n|n  |cFFB9E2FA피해량|r : "+I2S( R2I( HeroSkillVelue1[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
            elseif HeroSkillVCount1[index] == 2 then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye1[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr1[index]
                set str = str + "|r|n|n  |cFFB9E2FA피해량|r : "+I2S( R2I( HeroSkillVelue1[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
                set str = str + "|r|n  |cFFB9E2FA피해량2|r : "+I2S( R2I( HeroSkillVelue21[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
            endif
            call DzFrameSetText(UI_Tip_Text[2], str )
            call DzFrameShow(UI_Tip, true)
            set i = 1
        elseif f ==  FS_Button[2] then
            call DzFrameSetText(UI_Tip_Text[1], EXGetAbilityString(HeroSkillID2[index],1,ABILITY_DATA_TIP) )
            if JNStringContains(HeroSkillTpye2[index], "버프") then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye2[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr2[index]
                set str = str + "|r|n|n|n  |cFFB9E2FA수치|r : "+I2S(R2I(HeroSkillVelue2[index]*100))+" %"
            elseif HeroSkillVCount2[index] == 1 then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye2[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr2[index]
                set str = str + "|r|n|n  |cFFB9E2FA피해량|r : "+I2S( R2I( HeroSkillVelue2[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
            elseif HeroSkillVCount2[index] == 2 then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye2[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr2[index]
                set str = str + "|r|n|n  |cFFB9E2FA피해량|r : "+I2S( R2I( HeroSkillVelue2[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
                set str = str + "|r|n  |cFFB9E2FA피해량2|r : "+I2S( R2I( HeroSkillVelue22[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
            endif
            call DzFrameSetText(UI_Tip_Text[2], str )
            call DzFrameShow(UI_Tip, true)
            set i = 2
        elseif f ==  FS_Button[3] then
            call DzFrameSetText(UI_Tip_Text[1], EXGetAbilityString(HeroSkillID3[index],1,ABILITY_DATA_TIP) )
            if JNStringContains(HeroSkillTpye3[index], "버프") then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye3[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr3[index]
                set str = str + "|r|n|n|n  |cFFB9E2FA수치|r : "+I2S(R2I(HeroSkillVelue3[index]*100))+" %"
            elseif HeroSkillVCount3[index] == 1 then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye3[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr3[index]
                set str = str + "|r|n|n  |cFFB9E2FA피해량|r : "+I2S( R2I( HeroSkillVelue3[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
            elseif HeroSkillVCount3[index] == 2 then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye3[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr3[index]
                set str = str + "|r|n|n  |cFFB9E2FA피해량|r : "+I2S( R2I( HeroSkillVelue3[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
                set str = str + "|r|n  |cFFB9E2FA피해량2|r : "+I2S( R2I( HeroSkillVelue23[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
            endif
            call DzFrameSetText(UI_Tip_Text[2], str )
            call DzFrameShow(UI_Tip, true)
            set i = 3
        elseif f ==  FS_Button[4] then
            call DzFrameSetText(UI_Tip_Text[1], EXGetAbilityString(HeroSkillID4[index],1,ABILITY_DATA_TIP) )
            if JNStringContains(HeroSkillTpye4[index], "버프") then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye4[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr4[index]
                set str = str + "|r|n|n|n  |cFFB9E2FA수치|r : "+I2S(R2I(HeroSkillVelue4[index]*100))+" %"
            elseif HeroSkillVCount4[index] == 1 then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye4[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr1[index]
                set str = str + "|r|n|n  |cFFB9E2FA피해량|r : "+I2S( R2I( HeroSkillVelue4[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
            elseif HeroSkillVCount4[index] == 2 then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye4[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr4[index]
                set str = str + "|r|n|n  |cFFB9E2FA피해량|r : "+I2S( R2I( HeroSkillVelue4[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
                set str = str + "|r|n  |cFFB9E2FA피해량2|r : "+I2S( R2I( HeroSkillVelue24[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
            endif
            call DzFrameSetText(UI_Tip_Text[2], str )
            call DzFrameShow(UI_Tip, true)
            set i = 4
        elseif f ==  FS_Button[5] then
            call DzFrameSetText(UI_Tip_Text[1], EXGetAbilityString(HeroSkillID5[index],1,ABILITY_DATA_TIP) )
            if JNStringContains(HeroSkillTpye5[index], "버프") then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye5[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr5[index]
                set str = str + "|r|n|n|n  |cFFB9E2FA수치|r : "+I2S(R2I(HeroSkillVelue5[index]*100))+" %"
            elseif HeroSkillVCount5[index] == 1 then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye5[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr5[index]
                set str = str + "|r|n|n  |cFFB9E2FA피해량|r : "+I2S( R2I( HeroSkillVelue5[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
            elseif HeroSkillVCount5[index] == 2 then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye5[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr5[index]
                set str = str + "|r|n|n  |cFFB9E2FA피해량|r : "+I2S( R2I( HeroSkillVelue5[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
                set str = str + "|r|n  |cFFB9E2FA피해량2|r : "+I2S( R2I( HeroSkillVelue25[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
            endif
            call DzFrameSetText(UI_Tip_Text[2], str )
            call DzFrameShow(UI_Tip, true)
            set i = 5
        elseif f ==  FS_Button[6] then
            call DzFrameSetText(UI_Tip_Text[1], EXGetAbilityString(HeroSkillID6[index],1,ABILITY_DATA_TIP) )
            if JNStringContains(HeroSkillTpye6[index], "버프") then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye6[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr6[index]
                set str = str + "|r|n|n|n  |cFFB9E2FA수치|r : "+I2S(R2I(HeroSkillVelue6[index]*100))+" %"
            elseif HeroSkillVCount6[index] == 1 then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye6[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr6[index]
                set str = str + "|r|n|n  |cFFB9E2FA피해량|r : "+I2S( R2I( HeroSkillVelue6[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
            elseif HeroSkillVCount6[index] == 2 then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye6[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr6[index]
                set str = str + "|r|n|n  |cFFB9E2FA피해량|r : "+I2S( R2I( HeroSkillVelue6[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
                set str = str + "|r|n  |cFFB9E2FA피해량2|r : "+I2S( R2I( HeroSkillVelue26[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
            endif
            call DzFrameSetText(UI_Tip_Text[2], str )
            call DzFrameShow(UI_Tip, true)
            set i = 6
        elseif f ==  FS_Button[7] then
            call DzFrameSetText(UI_Tip_Text[1], EXGetAbilityString(HeroSkillID7[index],1,ABILITY_DATA_TIP) )
            if JNStringContains(HeroSkillTpye7[index], "버프") then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye7[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr7[index]
                set str = str + "|r|n|n|n  |cFFB9E2FA수치|r : "+I2S(R2I(HeroSkillVelue7[index]*100))+" %"
            elseif HeroSkillVCount7[index] == 1 then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye7[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr7[index]
                set str = str + "|r|n|n  |cFFB9E2FA피해량|r : "+I2S( R2I( HeroSkillVelue7[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
            elseif HeroSkillVCount7[index] == 2 then
                set str = "|cFFA5FA7D[ 타입 ]|r "+HeroSkillTpye7[index]+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"
                set str = str + HeroSkillStr7[index]
                set str = str + "|r|n|n  |cFFB9E2FA피해량|r : "+I2S( R2I( HeroSkillVelue7[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
                set str = str + "|r|n  |cFFB9E2FA피해량2|r : "+I2S( R2I( HeroSkillVelue27[index] * ( Equip_Damage[pid] + Hero_Damage[pid]  ) ))
            endif
            call DzFrameSetText(UI_Tip_Text[2], str )
            call DzFrameShow(UI_Tip, true)
            set i = 7
        endif
           /*
        if itemid != 0 then
            call DzFrameShow(UI_Tip, true)
            set i = GetItemTypes(items)
            set up = GetItemUp(items)
            set quality = GetItemQuality(items)
            set cts = GetItemCombatStats(items)
            set tier = GetItemTier(items)

            if i >= 6 or tier == 1 then
                call DzFrameSetText(UI_Tip_Text[1], GetItemNames(items) )
            else
                call DzFrameSetText(UI_Tip_Text[1], "+" + I2S(up) + " " + GetItemNames(items) )
            endif
            set str = "|cFFA5FA7D[ 종류 ]|r "

            if i == 0 then
                set str = str + "보조무기|n|n"
                set str = str + "  |cFFB9E2FA방어 등급|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
            elseif i == 5 then
                set str = str + "무기|n|n"
                set str = str + "  |cFFB9E2FA무기 공격력|r +"
                set str = str + JNStringSplit(ItemStats[i][tier],";", up )
                set str = str + "|n|n|cff5AD2FF[ 품질 "+ I2S(quality*5) + "% ]|r|n"
                set str = str + "  |cFFB9E2FA추가 피해|r +"
                set str = str + R2S(ItemWeaponQuality[quality]) + "%"
            endif
            call DzFrameSetText(UI_Tip_Text[2], str)
        endif
        */
    endfunction

    private function SkillFrameAbilityId takes integer index, integer types returns integer
        if types == 0 then
            return HeroSkillID0[index]
        elseif types == 1 then
            return HeroSkillID1[index]
        elseif types == 2 then
            return HeroSkillID2[index]
        elseif types == 3 then
            return HeroSkillID3[index]
        elseif types == 4 then
            return HeroSkillID4[index]
        elseif types == 5 then
            return HeroSkillID5[index]
        elseif types == 6 then
            return HeroSkillID6[index]
        elseif types == 7 then
            return HeroSkillID7[index]
        elseif types == 8 then
            return HeroSkillID10[index]
        elseif types == 9 then
            return 'A002'
        elseif types == 10 then
            return HeroSkillID9[index]
        elseif types == 11 then
            return HeroSkillID8[index]
        endif

        return 0
    endfunction

    private function SkillFrameBaseDescription takes integer pid, string skillType, string skillDesc, integer valueCount, real value1, real value2 returns string
        local real damage = Equip_Damage[pid] + Hero_Damage[pid]
        local string str = "|cFFA5FA7D[ 타입 ]|r "+skillType+"|n|n|cff5AD2FF[ 효과 ]|r|n  |cFFB9E2FA"+skillDesc+"|r"

        if JNStringContains(skillType, "버프") then
            set str = str + "|n|n|n  |cFFB9E2FA수치|r : "+I2S(R2I(value1*100))+" %"
        elseif valueCount == 1 then
            set str = str + "|n|n  |cFFB9E2FA피해량|r : "+I2S(R2I(value1 * damage))
        elseif valueCount == 2 then
            set str = str + "|n|n  |cFFB9E2FA피해량|r : "+I2S(R2I(value1 * damage))
            set str = str + "|r|n  |cFFB9E2FA피해량2|r : "+I2S(R2I(value2 * damage))
        endif

        return str
    endfunction

    private function SkillFrameExtraDescription takes string text1, string text2, string text3 returns string
        local string str = ""
        local boolean added = false

        if text1 != "" then
            set str = str + "|n|n|cff5AD2FF[ 추가 효과 ]|r|n  |cFFB9E2FA" + text1 + "|r"
            set added = true
        endif
        if text2 != "" then
            if not added then
                set str = str + "|n|n|cff5AD2FF[ 추가 효과 ]|r"
                set added = true
            endif
            set str = str + "|n  |cFFB9E2FA" + text2 + "|r"
        endif
        if text3 != "" then
            if not added then
                set str = str + "|n|n|cff5AD2FF[ 추가 효과 ]|r"
            endif
            set str = str + "|n  |cFFB9E2FA" + text3 + "|r"
        endif

        return str
    endfunction

    private function SkillFrameDataDescription takes integer pid, integer index, integer types returns string
        if types == 0 then
            return SkillFrameBaseDescription(pid, HeroSkillTpye0[index], HeroSkillStr0[index], HeroSkillVCount0[index], HeroSkillVelue0[index], HeroSkillVelue20[index]) + SkillFrameExtraDescription(HeroSkill0Text1[index], HeroSkill0Text2[index], HeroSkill0Text3[index])
        elseif types == 1 then
            return SkillFrameBaseDescription(pid, HeroSkillTpye1[index], HeroSkillStr1[index], HeroSkillVCount1[index], HeroSkillVelue1[index], HeroSkillVelue21[index]) + SkillFrameExtraDescription(HeroSkill1Text1[index], HeroSkill1Text2[index], HeroSkill1Text3[index])
        elseif types == 2 then
            return SkillFrameBaseDescription(pid, HeroSkillTpye2[index], HeroSkillStr2[index], HeroSkillVCount2[index], HeroSkillVelue2[index], HeroSkillVelue22[index]) + SkillFrameExtraDescription(HeroSkill2Text1[index], HeroSkill2Text2[index], HeroSkill2Text3[index])
        elseif types == 3 then
            return SkillFrameBaseDescription(pid, HeroSkillTpye3[index], HeroSkillStr3[index], HeroSkillVCount3[index], HeroSkillVelue3[index], HeroSkillVelue23[index]) + SkillFrameExtraDescription(HeroSkill3Text1[index], HeroSkill3Text2[index], HeroSkill3Text3[index])
        elseif types == 4 then
            return SkillFrameBaseDescription(pid, HeroSkillTpye4[index], HeroSkillStr4[index], HeroSkillVCount4[index], HeroSkillVelue4[index], HeroSkillVelue24[index]) + SkillFrameExtraDescription(HeroSkill4Text1[index], HeroSkill4Text2[index], HeroSkill4Text3[index])
        elseif types == 5 then
            return SkillFrameBaseDescription(pid, HeroSkillTpye5[index], HeroSkillStr5[index], HeroSkillVCount5[index], HeroSkillVelue5[index], HeroSkillVelue25[index]) + SkillFrameExtraDescription(HeroSkill5Text1[index], HeroSkill5Text2[index], HeroSkill5Text3[index])
        elseif types == 6 then
            return SkillFrameBaseDescription(pid, HeroSkillTpye6[index], HeroSkillStr6[index], HeroSkillVCount6[index], HeroSkillVelue6[index], HeroSkillVelue26[index]) + SkillFrameExtraDescription(HeroSkill6Text1[index], HeroSkill6Text2[index], HeroSkill6Text3[index])
        elseif types == 7 then
            return SkillFrameBaseDescription(pid, HeroSkillTpye7[index], HeroSkillStr7[index], HeroSkillVCount7[index], HeroSkillVelue7[index], HeroSkillVelue27[index]) + SkillFrameExtraDescription(HeroSkill7Text1[index], HeroSkill7Text2[index], HeroSkill7Text3[index])
        endif

        return "Data_Unit.j에 등록된 스킬 설명이 없습니다."
    endfunction

    private function SkillFrameDescription takes integer pid, integer index, integer types returns string
        local integer abilId = SkillFrameAbilityId(index, types)
        local string title
        local string desc

        if abilId == 0 then
            return ""
        endif

        set title = EXGetAbilityString(abilId, 1, ABILITY_DATA_TIP)
        if types < 8 then
            set desc = SkillFrameDataDescription(pid, index, types)
        elseif abilId == 'A002' then
            set desc = "마우스 방향으로 짧게 이동합니다.|n쿨타임 7.0초, 최대 3회까지 충전됩니다."
        else
            set desc = "Data_Unit.j에 등록된 스킬 설명이 없습니다."
        endif

        if abilId == 'A002' and title == "" then
            set title = "회피(X)"
        endif
        if title == "" then
            return desc
        endif

        return title + "|n|n" + desc
    endfunction

    private function SetSubSkillButton takes integer types, integer abilId, integer pos returns boolean
        local string title

        if abilId == 0 then
            call DzFrameShow(FS_Button[types], false)
            return false
        endif

        set title = EXGetAbilityString(abilId, 1, ABILITY_DATA_TIP)
        if abilId == 'A002' and title == "" then
            set title = "회피(X)"
        endif

        call DzFrameClearAllPoints(FS_Button[types])
        call DzFrameSetPoint(FS_Button[types], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.165, -0.080 +(-0.038*pos))
        call DzFrameSetTexture(FS_ButtonBackDrop[types], EXExecuteScript("(require'jass.slk').ability[" +I2S(abilId)+"].Art"), 0)
        call DzFrameSetText(FS_ButtonTEXT[types], title)
        call DzFrameShow(FS_Button[types], true)

        return true
    endfunction

    function SkillSetting takes unit u returns nothing
        local integer index = DataUnitIndex(u)
        local player p = GetOwningPlayer(u)
        local integer pid = GetPlayerId(p)
        local integer subIndex = 0

        if p == GetLocalPlayer() then

            call DzFrameSetText(FS_ButtonTEXT[0], EXGetAbilityString(HeroSkillID0[index],1,ABILITY_DATA_TIP) )
            call DzFrameSetText(FS_ButtonTEXT[1], EXGetAbilityString(HeroSkillID1[index],1,ABILITY_DATA_TIP) )
            call DzFrameSetText(FS_ButtonTEXT[2], EXGetAbilityString(HeroSkillID2[index],1,ABILITY_DATA_TIP) )
            call DzFrameSetText(FS_ButtonTEXT[3], EXGetAbilityString(HeroSkillID3[index],1,ABILITY_DATA_TIP) )
            call DzFrameSetText(FS_ButtonTEXT[4], EXGetAbilityString(HeroSkillID4[index],1,ABILITY_DATA_TIP) )
            call DzFrameSetText(FS_ButtonTEXT[5], EXGetAbilityString(HeroSkillID5[index],1,ABILITY_DATA_TIP) )
            call DzFrameSetText(FS_ButtonTEXT[6], EXGetAbilityString(HeroSkillID6[index],1,ABILITY_DATA_TIP) )
            call DzFrameSetText(FS_ButtonTEXT[7], EXGetAbilityString(HeroSkillID7[index],1,ABILITY_DATA_TIP) )

            call DzFrameSetTexture(FS_ButtonBackDrop[0], EXExecuteScript("(require'jass.slk').ability[" +I2S(HeroSkillID0[index])+"].Art"), 0)
            call DzFrameSetTexture(FS_ButtonBackDrop[1], EXExecuteScript("(require'jass.slk').ability[" +I2S(HeroSkillID1[index])+"].Art"), 0)
            call DzFrameSetTexture(FS_ButtonBackDrop[2], EXExecuteScript("(require'jass.slk').ability[" +I2S(HeroSkillID2[index])+"].Art"), 0)
            call DzFrameSetTexture(FS_ButtonBackDrop[3], EXExecuteScript("(require'jass.slk').ability[" +I2S(HeroSkillID3[index])+"].Art"), 0)
            call DzFrameSetTexture(FS_ButtonBackDrop[4], EXExecuteScript("(require'jass.slk').ability[" +I2S(HeroSkillID4[index])+"].Art"), 0)
            call DzFrameSetTexture(FS_ButtonBackDrop[5], EXExecuteScript("(require'jass.slk').ability[" +I2S(HeroSkillID5[index])+"].Art"), 0)
            call DzFrameSetTexture(FS_ButtonBackDrop[6], EXExecuteScript("(require'jass.slk').ability[" +I2S(HeroSkillID6[index])+"].Art"), 0)
            call DzFrameSetTexture(FS_ButtonBackDrop[7], EXExecuteScript("(require'jass.slk').ability[" +I2S(HeroSkillID7[index])+"].Art"), 0)

            call DzFrameShow(FS_Button[0], true)
            call DzFrameShow(FS_Button[1], true)
            call DzFrameShow(FS_Button[2], true)
            call DzFrameShow(FS_Button[3], true)
            call DzFrameShow(FS_Button[4], true)
            call DzFrameShow(FS_Button[5], true)
            call DzFrameShow(FS_Button[6], true)
            call DzFrameShow(FS_Button[7], true)

            if SetSubSkillButton(8, HeroSkillID10[index], subIndex) then
                set subIndex = subIndex + 1
            endif
            if SetSubSkillButton(9, 'A002', subIndex) then
                set subIndex = subIndex + 1
            endif
            if SetSubSkillButton(10, HeroSkillID9[index], subIndex) then
                set subIndex = subIndex + 1
            endif
            if SetSubSkillButton(11, HeroSkillID8[index], subIndex) then
                set subIndex = subIndex + 1
            endif

            call DzFrameSetText(FS_TemplateText, SkillFrameDescription(pid, index, 0))

            if index == 0 then
            endif
        endif

        set p = null
    endfunction

    private function ShowMenu takes nothing returns nothing
        //메뉴 버튼을 누르면 메뉴 버튼 비활설화 + 메뉴 배경 표시
        //다시 메뉴 버튼을 누르면 메뉴버튼 활성화 + 메뉴 배경 숨김
        if FS_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] == true then
            call DzFrameShow(FS_BackDrop, false)
            set FS_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = false
        else
            call DzFrameShow(FS_BackDrop, true)
            set FS_OnOff[GetPlayerId(DzGetTriggerUIEventPlayer())] = true
        endif
    endfunction

    private function SelectSkill takes nothing returns nothing
        local integer f = DzGetTriggerUIEventFrame()
        local integer i = 0
        local integer pid = GetPlayerId(DzGetTriggerUIEventPlayer())
        local integer index = DataUnitIndex(MainUnit[pid])
        local integer abilId

        set i = 0
        loop
            if f == FS_Button[i] then
                set abilId = SkillFrameAbilityId(index, i)
                if abilId != 0 then
                    call DzFrameSetText(FS_TemplateText, SkillFrameDescription(pid, index, i))
                endif
            endif
            exitwhen i == 11
            set i = i + 1
        endloop
    endfunction

    //
    private function CreateSkillButton takes integer types returns nothing
        set FS_Button[types]=DzCreateFrameByTagName("BUTTON", "", FS_BackDrop, "ScoreScreenTabButtonTemplate",  FrameCount())
        if types < 8 then
            call DzFrameSetPoint(FS_Button[types], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.040, -0.080 +(-0.038*types))
        else
            call DzFrameSetPoint(FS_Button[types], JN_FRAMEPOINT_CENTER, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.165, -0.080 +(-0.038*(types - 8)))
        endif
        call DzFrameSetSize(FS_Button[types], 0.030, 0.030)
        call DzFrameSetScriptByCode(FS_Button[types], JN_FRAMEEVENT_MOUSE_ENTER, function F_ON_Actions, false)
        call DzFrameSetScriptByCode(FS_Button[types], JN_FRAMEEVENT_MOUSE_LEAVE, function F_OFF_Actions, false)
        call DzFrameSetScriptByCode(FS_Button[types], JN_FRAMEEVENT_MOUSE_UP, function SelectSkill, false)

        set FS_ButtonBackDrop[types]=DzCreateFrameByTagName("BACKDROP", "", FS_Button[types], "", FrameCount())
        call DzFrameSetAllPoints(FS_ButtonBackDrop[types], FS_Button[types])
        call DzFrameSetTexture(FS_ButtonBackDrop[types],"ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp", 0)

        set FS_ButtonTEXT[types]=DzCreateFrameByTagName("TEXT", "", FS_Button[types], "", FrameCount())
        call DzFrameSetPoint(FS_ButtonTEXT[types], JN_FRAMEPOINT_TOPLEFT, FS_Button[types] , JN_FRAMEPOINT_TOPLEFT, 0.035, -0.010)
        call DzFrameSetText(FS_ButtonTEXT[types], "스킬이름스킬이름스킬이")
        call DzFrameSetSize(FS_ButtonTEXT[types], 0.110, 0.00)
        call DzFrameShow(FS_Button[types], false)
    endfunction

    private function Main takes nothing returns nothing
        local string s
        local integer i

        /********************************** 스킬 버튼 생성 **********************************************
        set FS_OpenButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetAbsolutePoint(FS_OpenButton, JN_FRAMEPOINT_CENTER, 0.700, 0.020)
        call DzFrameSetSize(FS_OpenButton, 0.020, 0.020)
        call DzFrameSetScriptByCode(FS_OpenButton, JN_FRAMEEVENT_MOUSE_UP, function ShowMenu, false)
        set FS_OpenButtonBD=DzCreateFrameByTagName("BACKDROP", "", FS_OpenButton, "template", FrameCount())
        call DzFrameSetTexture(FS_OpenButtonBD, "skill.blp", 0)
        call DzFrameSetSize(FS_OpenButtonBD, 0.020, 0.020)
        call DzFrameSetAbsolutePoint(FS_OpenButtonBD, JN_FRAMEPOINT_CENTER, 0.700, 0.020)
        call DzFrameShow(FS_OpenButton, false)
        */

        /********************************** 메뉴 배경 생성 **********************************************
        set FS_BackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "StandardEditBoxBackdropTemplate", 0)
        call DzFrameSetAbsolutePoint(FS_BackDrop, JN_FRAMEPOINT_CENTER, 0.40, 0.30)
        call DzFrameSetSize(FS_BackDrop, 0.50, 0.39)
        */
        set FS_BackDrop=DzCreateFrameByTagName("BACKDROP", "", DzGetGameUI(), "template", FrameCount())
        call DzFrameSetTexture(FS_BackDrop, "Filenemo.blp", 0)
        call DzFrameSetAbsolutePoint(FS_BackDrop, JN_FRAMEPOINT_CENTER, 0.40, 0.30)
        call DzFrameSetSize(FS_BackDrop, 0.50, 0.39)

        /********************************** 프레임 이름 설명 생성 **********************************************/
        set FS_CombinationText=DzCreateFrameByTagName("TEXT", "", FS_BackDrop, "", FrameCount())
        call DzFrameSetPoint(FS_CombinationText, JN_FRAMEPOINT_TOPLEFT, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.025, -0.025)
        call DzFrameSetText(FS_CombinationText, "스킬")

        set FS_SPTEXT=DzCreateFrameByTagName("TEXT", "", FS_BackDrop, "", FrameCount())
        call DzFrameSetPoint(FS_SPTEXT, JN_FRAMEPOINT_TOPLEFT, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.170, -0.050)
        call DzFrameSetText(FS_SPTEXT, "")
        call DzFrameShow(FS_SPTEXT, false)

        set FS_SPTEXTV=DzCreateFrameByTagName("TEXT", "", FS_BackDrop, "", FrameCount())
        call DzFrameSetPoint(FS_SPTEXTV, JN_FRAMEPOINT_TOPLEFT, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.245, -0.050)
        call DzFrameSetText(FS_SPTEXTV, "0")
        call DzFrameShow(FS_SPTEXTV, false)

        call CreateSkillButton(0)
        call CreateSkillButton(1)
        call CreateSkillButton(2)
        call CreateSkillButton(3)
        call CreateSkillButton(4)
        call CreateSkillButton(5)
        call CreateSkillButton(6)
        call CreateSkillButton(7)
        call CreateSkillButton(8)
        call CreateSkillButton(9)
        call CreateSkillButton(10)
        call CreateSkillButton(11)

        set FS_TemplateBackDrop=DzCreateFrameByTagName("BACKDROP", "", FS_BackDrop, "template", FrameCount())
        call DzFrameSetTexture(FS_TemplateBackDrop, "war3mapImported\\UI_Pick_Panel.tga", 0)
        call DzFrameSetPoint(FS_TemplateBackDrop, JN_FRAMEPOINT_TOPLEFT, FS_BackDrop , JN_FRAMEPOINT_TOPLEFT, 0.275, -0.055)
        call DzFrameSetSize(FS_TemplateBackDrop, 0.190, 0.300)

        set FS_TemplateText=DzCreateFrameByTagName("TEXT", "", FS_TemplateBackDrop, "", FrameCount())
        call DzFrameSetPoint(FS_TemplateText, JN_FRAMEPOINT_TOPLEFT, FS_TemplateBackDrop , JN_FRAMEPOINT_TOPLEFT, 0.020, -0.025)
        call DzFrameSetSize(FS_TemplateText, 0.160, 0.250)
        call DzFrameSetFont(FS_TemplateText, "Fonts\\DFHeiMd.ttf", 0.010, 0)
        call DzFrameSetText(FS_TemplateText, "스킬을 선택하면 설명이 표시됩니다.")

        /********************************** 메뉴 취소 버튼 **********************************************/
        set FS_CancelButton = DzCreateFrameByTagName("GLUETEXTBUTTON", "", FS_BackDrop, "ScriptDialogButton", 0)
        call DzFrameSetPoint(FS_CancelButton, JN_FRAMEPOINT_TOPRIGHT, FS_BackDrop , JN_FRAMEPOINT_TOPRIGHT, -0.015, -0.015)
        call DzFrameSetText(FS_CancelButton, "X")
        call DzFrameSetSize(FS_CancelButton, 0.03, 0.03)
        call DzFrameSetScriptByCode(FS_CancelButton, JN_FRAMEEVENT_MOUSE_UP, function ShowMenu, false)


        call DzFrameShow(FS_BackDrop, false)
    endfunction

    private function ESCAction takes nothing returns nothing
        if FS_OnOff[GetPlayerId(GetTriggerPlayer())] == true then
            if ( GetTriggerPlayer() == GetLocalPlayer() ) then
                call DzFrameShow(FS_BackDrop, false)
            endif
            set FS_OnOff[GetPlayerId(GetTriggerPlayer())] = false
        endif
    endfunction


    private function KKey takes nothing returns nothing
        local integer key = DzGetTriggerKey()
        local integer i = 0
        local integer j = GetPlayerId(DzGetTriggerKeyPlayer())

        if DzGetTriggerKeyPlayer()==GetLocalPlayer() then
            set i = JNMemoryGetByte(JNGetModuleHandle("Game.dll")+0xD04FEC)
        endif

        if i==1 then
        else
            if PickCheck[j] == true then
                if key == 'K' then
                    if FS_OnOff[j] == true then
                        call DzFrameShow(FS_BackDrop, false)
                        set FS_OnOff[j] = false
                    else
                        call DzFrameShow(FS_BackDrop, true)
                        set FS_OnOff[j] = true
                    endif
                endif
            endif
        endif
    endfunction

    private function init takes nothing returns nothing
        local trigger t=CreateTrigger()
        local integer index

        set t = CreateTrigger()
        call TriggerAddAction( t, function Main )
        call TriggerRegisterTimerEventSingle( t, 0.1 )


        //esc버튼으로 인벤토리 닫기
        set t = CreateTrigger()

        set index = 0
        loop
            call TriggerRegisterPlayerEvent(t, Player(index), EVENT_PLAYER_END_CINEMATIC)
            set index = index + 1
            exitwhen index == bj_MAX_PLAYER_SLOTS
        endloop
        call TriggerAddAction( t, function ESCAction )

        set index = 0
        loop
            set HeroSkillLevel[index][0] = 0
            set HeroSkillLevel[index][1] = 0
            set HeroSkillLevel[index][2] = 0
            set HeroSkillLevel[index][3] = 0
            set HeroSkillLevel[index][4] = 0
            set HeroSkillLevel[index][5] = 0
            set HeroSkillLevel[index][6] = 0
            set HeroSkillLevel[index][7] = 0
            set HeroSkillPoint[index] = 0
            set index = index + 1
            exitwhen index == 13
        endloop

        //I버튼으로 인벤토리 열기 및 닫기
        call DzTriggerRegisterKeyEventByCode(null, 'K', 0, false, function KKey)

        set t = null

    endfunction
endlibrary
