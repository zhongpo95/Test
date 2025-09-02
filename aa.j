
function StarOther__anon__0 takes nothing returns nothing
    local integer i=LoadInteger(StarBaseHT, GetHandleId(GetExpiredTimer()), 0xA707D18B)
    local player p=Player(i)
    call PauseTimer(s__CFG_timers[i])
    if ( GetLocalPlayer() == p ) then
        call DisplayCineFilter(false)
    endif
    set p=null
endfunction

function SO_CinematicFilterGenerictakes takes player p,real duration,blendmode bmode,string tex,real red0,real green0,real blue0,real trans0,real red1,real green1,real blue1,real trans1 returns nothing
    local integer pid=GetPlayerId(p)
    if ( GetLocalPlayer() == p ) then
        call SetCineFilterTexture(tex)
        call SetCineFilterBlendMode(bmode)
        call SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
        call SetCineFilterStartUV(0, 0, 1, 1)
        call SetCineFilterEndUV(0, 0, 1, 1)
        call SetCineFilterStartColor(PercentTo255(red0), PercentTo255(green0), PercentTo255(blue0), PercentTo255(100 - trans0))
        call SetCineFilterEndColor(PercentTo255(red1), PercentTo255(green1), PercentTo255(blue1), PercentTo255(100 - trans1))
        call SetCineFilterDuration(duration)
        call DisplayCineFilter(true)
    endif
    
    if ( GetLocalPlayer() == p ) then
        call DisplayCineFilter(false)
    endif
endfunction



function Trig_J_Firefly____________000_fzFunc013Func006T takes nothing returns nothing
    if ( ( mh_stpd2(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)) == 0 ) ) then
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x6B54C545, LoadReal(YDHT, GetHandleId(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946)), 0xA75A98EB))
    if ( ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x6B54C545) <= 0.50 ) and ( ( UnitHasBuffBJ(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2), 'B003') == true ) or ( IsUnitPausedBJ(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)) == true ) ) ) then
    else
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x6B54C545, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x6B54C545) - 0.03 ))
    call SaveInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x5F75F1D9, LoadInteger(YDHT, GetHandleId(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946)), 0x61ECAD39))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x37DA1528, LoadReal(YDHT, GetHandleId(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946)), 0xA75A98EB))
    if ( ( GetLocalPlayer() == LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946) ) ) then
    call DzFrameSetText(udg_UI__jsfzxs[1], ( ( "|cFFA7FEC8萤火值充能\\变身结束时间：|r" ) + ( ( ( "|cFFBCEEFE" ) + ( I2S(LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x5F75F1D9)) ) + ( "|r|cFFFFEFD6\\|r" ) ) ) + ( ( ( "|cFFFFEFCD[" ) + ( R2S(LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x37DA1528)) ) + ( "]|r" ) ) ) ))
    else
    endif
    endif
    call SaveReal(YDHT, GetHandleId(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946)), 0xA75A98EB, LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x6B54C545))
    if ( ( ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x6B54C545) <= 0.00 ) or ( IsUnitType(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2), UNIT_TYPE_DEAD) == true ) ) ) then
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA, GetUnitX(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382, GetUnitY(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)))
    call SaveReal(YDHT, GetHandleId(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946)), 0xA75A98EB, 0.00)
    call SetPlayerAbilityAvailable(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946), 'A0SR', true)
    call SetPlayerAbilityAvailable(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946), 'A0SS', true)
    call SetPlayerAbilityAvailable(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946), 'A0ST', true)
    call SetPlayerAbilityAvailable(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946), 'A0SU', true)
    call SetPlayerAbilityAvailable(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946), 'A0SY', false)
    call SetPlayerAbilityAvailable(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946), 'A0SZ', false)
    call SetPlayerAbilityAvailable(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946), 'A0T0', false)
    call SetPlayerAbilityAvailable(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946), 'A0T1', false)
    call SetPlayerAbilityAvailable(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946), 'A0SV', false)
    call SetPlayerAbilityAvailable(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946), 'A0SW', false)
    call SetPlayerAbilityAvailable(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946), 'A0SX', false)
    if ( ( GetUnitTypeId(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)) == 'O016' ) ) then
        call DzSetUnitModel(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2), "[Hero]\\mh_Firefly_yz.mdl")
    else
    call DzSetUnitModel(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2), "[Hero]\\mh_Firefly.mdl")
    endif
    ConvertSubAnimType
    call SetUnitPortrait(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2) , "[Hero]\\mh_Firefly_portrait.mdx")
    call SetUnitScale(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2), 1.10, 1.10, 1.10)
    if ( ( LoadInteger(YDHT, GetHandleId(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946)), 0x0BEC2D78) == 1 ) ) then
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffect("chun-yanji-6.mdl", LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382)))
    call EXSetEffectSize(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 2.00)
    call SetPariticle2Size(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 2)
    call EXEffectMatRotateZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , GetRandomDirectionDeg())
    call EXSetEffectColor(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 0xff000000 + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(0) + PercentTo255(0))
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffect("fire-boom-new.mdl", LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382)))
    call EXEffectMatRotateZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , GetRandomDirectionDeg())
    call EXSetEffectSize(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 1.50)
    call SetPariticle2Size(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 2)
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffect("1671355440.mdx", LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382)))
    call EXEffectMatRotateZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , GetRandomDirectionDeg())
    call EXSetEffectSize(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 1.00)
    call EXSetEffectColor(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 0xff000000 * PercentTo255(0) + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(0) + PercentTo255(0))
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffect("-904338158.mdx", LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382)))
    call EXEffectMatRotateZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , GetRandomDirectionDeg())
    call EXSetEffectSize(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 1.00)
    call EXSetEffectSpeed(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 3.00)
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    else
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffect("[tx][z]zhuanzhi1.mdl", LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382)))
    call EXSetEffectSize(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 3.00)
    call SetPariticle2Size(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 0.01)
    call EXEffectMatRotateZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , GetRandomDirectionDeg())
    call EXSetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , ( EXGetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6)) - 150.00 ))
    call EXSetEffectColor(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 0xff000000 + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(80))
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffect("-318710672.mdx", LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382)))
    call EXEffectMatRotateZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , GetRandomDirectionDeg())
    call EXSetEffectSize(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 1.80)
    call EXSetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , ( EXGetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6)) - 150.00 ))
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffect("-950557588.mdx", LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382)))
    call EXEffectMatRotateZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , GetRandomDirectionDeg())
    call EXSetEffectSize(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 1.80)
    call EXSetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , ( EXGetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6)) + 150.00 ))
    call EXSetEffectSpeed(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 3.00)
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    endif
    call SaveInteger(YDHT, GetHandleId(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946)), 0x0BEC2D78, 0)
    call SaveInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x5F75F1D9, LoadInteger(YDHT, GetHandleId(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946)), 0x61ECAD39))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x37DA1528, LoadReal(YDHT, GetHandleId(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946)), 0xA75A98EB))
    call SaveReal(YDHT, GetHandleId(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946)), 0x839904C5, ( LoadReal(YDHT, GetHandleId(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946)), 0x839904C5) - LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x322FCF24) ))
    call SaveReal(YDHT, GetHandleId(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946)), 0x3ABF7C9B, ( LoadReal(YDHT, GetHandleId(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946)), 0x3ABF7C9B) + LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x5EC6A3B9) ))
    if ( ( GetLocalPlayer() == LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946) ) ) then
    call DzFrameSetText(udg_UI__jsfzxs[1], ( ( "|cFFA7FEC8萤火值充能\\变身结束时间：|r" ) + ( ( ( "|cFFBCEEFE" ) + ( I2S(LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x5F75F1D9)) ) + ( "|r|cFFFFEFD6\\|r" ) ) ) + ( ( ( "|cFFFFEFCD[" ) + ( R2S(LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x37DA1528)) ) + ( "]|r" ) ) ) ))
    else
    endif
    call FlushChildHashtable(YDLOC, GetHandleId(GetExpiredTimer()))
    call DestroyTimer(GetExpiredTimer())
    else
    endif
    else
    endif
    endfunction



    //===========================================================================
// Trigger: J-Firefly萨姆大招001
//===========================================================================
function Trig_J_Firefly____________001jn2 takes nothing returns nothing
    local timer jsq2
    local integer jsq2id
    local integer a= 0
    local integer jsqid= GetHandleId(GetExpiredTimer())
    local unit dw= LoadUnitHandle(hsb, jsqid, StringHash("dw"))
    local player wj= LoadPlayerHandle(hsb, jsqid, StringHash("wj"))
    local real x= LoadReal(hsb, jsqid, StringHash("x"))
    local real y= LoadReal(hsb, jsqid, StringHash("y"))
    local real x2= LoadReal(hsb, jsqid, StringHash("x2"))
    local real y2= LoadReal(hsb, jsqid, StringHash("y2"))
    local real jd= LoadReal(hsb, jsqid, StringHash("jd"))
    local string zfc
    local effect tx
    local effect tx2
    local real time= LoadReal(hsb, jsqid, StringHash("逝去时间"))
    local integer timezs= LoadInteger(hsb, jsqid, StringHash("逝去时间zs"))
    
    local group ydl_group
    local group dwz= LoadGroupHandle(hsb, jsqid, StringHash("dwz"))
    local unit ydl_unit
    local real jd3= LoadReal(hsb, jsqid, StringHash("jd3"))
    local real sjss= 0
    local integer sjzs= 0
    local real sz= 0
    local real x3= 0
    local real y3= 0
    local real x4= LoadReal(hsb, jsqid, StringHash("x4"))
    local real y4= LoadReal(hsb, jsqid, StringHash("y4"))
    local real gd= LoadReal(hsb, jsqid, StringHash("高度"))
    local real gdsd= LoadReal(hsb, jsqid, StringHash("高度速度"))
    local real sh= LoadReal(hsb, jsqid, StringHash("伤害"))
    local real sh2= LoadReal(hsb, jsqid, StringHash("伤害2"))
    local unit mj3= LoadUnitHandle(hsb, jsqid, StringHash("mj3"))
    local integer jnzs= LoadInteger(hsb, jsqid, StringHash("jnzs"))
    local integer jnzs0= LoadInteger(hsb, jsqid, StringHash("jnzs0"))
    local integer jnzs1= LoadInteger(hsb, jsqid, StringHash("jnzs1"))
    local integer jnzs2= LoadInteger(hsb, jsqid, StringHash("jnzs2"))
    local integer jnzs3= LoadInteger(hsb, jsqid, StringHash("jnzs3"))
    local integer jnzs4= LoadInteger(hsb, jsqid, StringHash("jnzs4"))
    local effect array tstx
    set a=0
    loop
    set tstx[a]=LoadEffectHandle(hsb, jsqid, StringHash("特效" + I2S(a)))
    set a=a + 1
    exitwhen a >= 15
    endloop
    if ( ( ( mh_stpd2(dw) == 0 ) ) ) then //判断该单位是否处于时停
    set time=time + 0.02
    call SaveReal(hsb, jsqid, StringHash("逝去时间"), time)
    if time == 0.02 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call UnitAddAbility(dw, 'Amrf')
    call UnitRemoveAbility(dw, 'Amrf')
    call SetUnitFlyHeight(dw, 0.00, 0.00)
    set mj3=CreateUnit(wj, 'e002', x, y, 0) //全能技能马甲zhan
    call UnitAddAbility(mj3, 'A0CF') //眩晕2s
    call SaveUnitHandle(hsb, jsqid, StringHash("mj3"), mj3)
    set sh=( 100.00 + ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, dw, true)) * 20 ) )
    set sh2=( 100.00 + ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, dw, true)) * 1 ) )
    set sjss=1
    if ( ( GetUnitAbilityLevel(dw, 'A0TK') >= 1 ) ) then
    set sjss=sjss + 0.1
    endif
    if ( GetUnitAbilityLevel(udg_danwei_WJ_ysjgnfz[GetConvertedPlayerId(wj)], 'A0TW') >= 1 ) then
    set sjss=sjss + 0.15
    endif
    set sh=sh * sjss
    set sh2=sh2 * sjss
    call SaveReal(hsb, jsqid, StringHash("伤害"), sh)
    call SaveReal(hsb, jsqid, StringHash("伤害2"), sh2)
    if ( ( GetPlayerTechCountSimple('R00V', wj) >= 1 ) ) then
    call mh_buffkq(dw , 8 , 16 , 1) //大招无敌帧
    endif
    endif
    if time == 0.3 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call dsound("m_skill10.wav" , dw)
    //火焰喷射特效
    set zfc="chun-yanji-6.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , 270) //角度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 100.00 )) //高度
    call EXSetEffectSize(tx , 2) //大小
    call SetPariticle2Size(tx , 2) //内置api调大小
    call DestroyEffect(tx)
    //火焰喷射特效3
    set zfc="-834687343.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , 270) //角度
    call EXSetEffectSpeed(tx , 0.6) //动画速度
    call EXSetEffectSize(tx , 2) //大小
    call SetPariticle2Size(tx , 2) //内置api调大小
    call DestroyEffect(tx)
    //火焰喷射特效2
    set zfc="fire-boom-new.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , GetRandomReal(0, 360)) //角度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) - 100.00 )) //高度
    call EXSetEffectSize(tx , 3) //大小
    call SetPariticle2Size(tx , 3) //内置api调大小
    call EXSetEffectColor(tstx[7] , 0xff000000 + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(60) + PercentTo255(20))
    call DestroyEffect(tx)
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , GetRandomReal(0, 360)) //角度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) - 120.00 )) //高度
    call EXSetEffectSize(tx , 4) //大小
    call EXSetEffectSpeed(tx , 0.6) //动画速度
    call SetPariticle2Size(tx , 1.5) //内置api调大小
    call DestroyEffect(tx)
    //az红色氛围感特效
    set zfc="chun-yanji-5.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) - 50.00 )) //高度
    call DestroyEffect(tx)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 3.00)
    endif
    if time == 0.82 then
    call PlaySoundOnUnitBJ(gg_snd_mh_Sam_R, 100, dw) //语音
    call SetUnitTimeScale(dw, 0.06)
    endif
    if time == 1.3 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    //火焰喷射特效
    set zfc="chun-yanji-6.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , 270) //角度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 100.00 )) //高度
    call EXSetEffectSpeed(tx , 2) //动画速度
    call EXSetEffectSize(tx , 2) //大小
    call SetPariticle2Size(tx , 2) //内置api调大小
    call DestroyEffect(tx)
    //az红色氛围感特效
    set zfc="chun-yanji-5.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXSetEffectSpeed(tx , 2) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) - 50.00 )) //高度
    call DestroyEffect(tx)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 20.00)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.2, false, function mh__jtzdhs1)
    call SetCameraFieldForPlayer(wj, CAMERA_FIELD_TARGET_DISTANCE, ( 3400.00 + 1000.00 ), 1.00) //玩家镜头
    endif
    if time == 1.4 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call SetUnitTimeScale(dw, 1)
    //火焰爆炸特效
    set zfc="34-2.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , GetRandomInt(0, 360)) //角度
    call EXSetEffectSize(tx , 1.25) //大小
    call EXSetEffectSpeed(tx , 1.2) //动画速度
    call SetPariticle2Size(tx , 1.25) //内置api调大小
    call DestroyEffect(tx)
    //火焰爆炸特效2
    set zfc="chun-yanji-6.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , GetRandomInt(0, 360)) //角度
    call EXSetEffectSize(tx , 1.25) //大小
    call EXSetEffectSpeed(tx , 1.2) //动画速度
    call SetPariticle2Size(tx , 1.25) //内置api调大小
    call DestroyEffect(tx)
    //火焰竖线特效
    set zfc="chun-yanji-10.mdl"
    set tx=AddSpecialEffect(zfc, x, y + 10)
    call EXEffectMatRotateZ(tx , GetRandomInt(0, 360)) //角度
    call EXSetEffectSize(tx , 0.3) //大小
    call SetPariticle2Size(tx , 0.2) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) - 100.00 )) //高度
    call DestroyEffect(tx)
    //火焰竖线特效2
    set zfc="-1530947416.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , 255) //角度
    call EXEffectMatScale(tx , 0.3 , 0.3 , 0.5) //s缩放
    call SetPariticle2Size(tx , 0.3) //内置api调大小
    call EXSetEffectSpeed(tx , 0.8) //动画速度
    call DestroyEffect(tx)
    //哈利姆大高光
    set zfc="-575870305.mdx"
    set tstx[6]=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tstx[6] , jd) //角度
    call EXSetEffectSize(tstx[6] , 1.5) //大小
    call SetPariticle2Size(tstx[6] , 1.5) //内置api调大小
    call EXSetEffectSpeed(tstx[6] , 1.5) //动画速度
    call EXSetEffectZ(tstx[6] , ( EXGetEffectZ(tstx[6]) + 1000.00 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(6)), tstx[6])
    //哈利姆大高光
    set zfc="-1381101979.mdx"
    set tstx[7]=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tstx[7] , - 90) //角度
    call EXEffectMatRotateZ(tstx[7] , 270) //角度
    call EXSetEffectSize(tstx[7] , 3) //大小
    call SetPariticle2Size(tstx[7] , 3) //内置api调大小
    call EXSetEffectZ(tstx[7] , ( EXGetEffectZ(tstx[7]) + GetUnitFlyHeight(dw) + 150 )) //高度
    call EXSetEffectSpeed(tstx[7] , 0.6) //动画速度
    call EXSetEffectColor(tstx[7] , 0xff000000 + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(60) + PercentTo255(20))
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(7)), tstx[7])
    set tstx[8]=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tstx[8] , - 90) //角度
    call EXEffectMatRotateZ(tstx[8] , 180) //角度
    call EXSetEffectSize(tstx[8] , 3) //大小
    call SetPariticle2Size(tstx[8] , 3) //内置api调大小
    call EXSetEffectSpeed(tstx[8] , 0.6) //动画速度
    call EXSetEffectZ(tstx[8] , ( EXGetEffectZ(tstx[8]) + GetUnitFlyHeight(dw) + 150 )) //高度
    call EXSetEffectColor(tstx[8] , 0xff000000 + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(60) + PercentTo255(20))
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(8)), tstx[8])
    endif
    if time >= 1.4 and time <= 1.7 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set sz=RMaxBJ(( 300.00 - ( ( time - 1.4 ) * 200.00 ) ), 100.00)
    set gd=gd + sz
    call EXSetEffectXY(tstx[7] , x , y)
    call EXSetEffectXY(tstx[8] , x , y)
    if time <= 1.54 then
    call EXSetEffectZ(tstx[7] , ( EXGetEffectZ(tstx[7]) + sz )) //高度
    call EXSetEffectZ(tstx[8] , ( EXGetEffectZ(tstx[8]) + sz )) //高度
    endif
    call SetUnitFlyHeight(dw, gd, ( sz / 0.02 ))
    call SaveReal(hsb, jsqid, StringHash("高度"), gd)
    endif
    if time == 1.7 then
    call DestroyEffect(tstx[7])
    call DestroyEffect(tstx[8])
    call ShowUnit(dw, false) //隐藏单位
    endif
    if time == 2.4 then
    call DestroyEffect(tstx[6])
    endif
    if time == 3.3 or time == 4.4 then //气流炸
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    if time == 4.4 then
    call PlaySoundOnUnitBJ(gg_snd_mh_Fireflysam_R0, 100, dw) //语音
    set jd=Atan2BJ(( y2 - y ), ( x2 - x ))
    set jd3=jd - 180
    set sjss=1500
    set x3=( x2 + sjss * CosBJ(jd3) )
    set y3=( y2 + sjss * SinBJ(jd3) )
    call SetUnitX(dw, x3)
    call SetUnitY(dw, y3)
    call ShowUnit(dw, true) //隐藏单位
    call SetUnitVertexColor(dw, 255, 255, 255, 0)
    call SetUnitFacingTimed(dw, jd, 0)
    call EXSetUnitFacing(dw , jd)
    set gd=4500
    call SetUnitFlyHeight(dw, gd, 0)
    call SaveReal(hsb, jsqid, StringHash("高度"), gd)
    call SaveReal(hsb, jsqid, StringHash("jd"), jd)
    //马甲
    set zfc=LoadStr(hsb, jsqid, StringHash("模型"))
    set tstx[0]=AddSpecialEffect(zfc, x3, y3)
    // call EXEffectMatRotateX(tstx[0], jd) //角度
    call EXEffectMatRotateY(tstx[0] , - 335) //角度
    call EXEffectMatRotateZ(tstx[0] , jd) //角度
    call EXSetEffectAnimation(tstx[0] , 0)
    call EXSetEffectSize(tstx[0] , LoadReal(hsb, jsqid, StringHash("模型大小"))) //大小
    call EXSetEffectSpeed(tstx[0] , 0.5) //动画速度
    call EXSetEffectZ(tstx[0] , ( EXGetEffectZ(tstx[0]) + gd )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(0)), tstx[0])
    //气息炸裂特效
    set zfc="[tutx]312.mdl"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 60) //角度
    call EXEffectMatRotateZ(tx , jd + 45) //角度
    call EXSetEffectSize(tx , 14) //大小
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(50) + PercentTo255(20))
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 1000 )) //高度
    call DestroyEffect(tx)
    set jd3=jd - 180
    set sjss=1400
    set x3=( x2 + sjss * CosBJ(jd3) )
    set y3=( y2 + sjss * SinBJ(jd3) )
    //哈利姆大滑翔
    set zfc="1423578375.mdx"
    set tstx[10]=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tstx[10] , 70) //角度
    call EXEffectMatRotateZ(tstx[10] , jd) //角度
    call EXSetEffectSize(tstx[10] , 1.6) //大小
    call SetPariticle2Size(tstx[10] , 1.5) //内置api调大小
    call EXSetEffectZ(tstx[10] , ( EXGetEffectZ(tstx[10]) + gd - 0 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(10)), tstx[10])
    set a=0
    loop
    set a=a + 1
    set jd3=jd - GetRandomReal(170, 190)
    set sjss=GetRandomReal(800, 1500)
    set x3=( x2 + sjss * CosBJ(jd3) )
    set y3=( y2 + sjss * SinBJ(jd3) )
    //哈利姆大滑翔
    set zfc="1423578375.mdx"
    set tstx[10 + a]=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tstx[10 + a] , GetRandomReal(65, 75)) //角度
    call EXEffectMatRotateZ(tstx[10 + a] , jd + GetRandomReal(- 5, 5)) //角度
    call EXSetEffectSize(tstx[10 + a] , GetRandomReal(0.75, 1)) //大小
    call SetPariticle2Size(tstx[10 + a] , GetRandomReal(0.75, 1)) //内置api调大小
    call EXSetEffectZ(tstx[10 + a] , ( EXGetEffectZ(tstx[10 + a]) + gd - GetRandomReal(100, 500) )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(10 + a)), tstx[10 + a])
    exitwhen a >= 5
    endloop
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 20.00)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.2, false, function mh__jtzdhs1)
    else
    set jd=Atan2BJ(( y2 - y ), ( x2 - x ))
    set jd3=jd - 180
    set sjss=1500
    set x3=( x2 + sjss * CosBJ(jd3) )
    set y3=( y2 + sjss * SinBJ(jd3) )
    //气息炸裂特效
    set zfc="[tutx]312.mdl"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 50) //角度
    call EXEffectMatRotateZ(tx , jd + 45) //角度
    call EXSetEffectSize(tx , 10) //大小
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(80) + PercentTo255(60))
    call EXSetEffectSpeed(tx , 0.8) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 2000 )) //高度
    call DestroyEffect(tx)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 5.00)
    endif
    endif
    if time >= 4.4 and time <= 5.9 then //飞行
    set jd3=jd - 180
    if time >= 5.5 and time <= 5.7 then
    set sz=RMaxBJ(1500 - ( 55 * 15.3 ) - ( time - 5.5 ) * 10, 0)
    else
    set sz=RMaxBJ(1500 - ( time - 4.4 ) / 0.02 * 15.3, 0)
    endif
    if time <= 5.5 then
    set sjss=40
    elseif time <= 5.7 then
    set sjss=RMaxBJ(( 15 - ( ( time - 5.5 ) * 100.00 ) ), 5.00)
    elseif time <= 5.9 then
    call EXSetEffectColor(tstx[0] , 0xff000000 + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(100))
    set sjss=gdsd
    endif
    set x3=( x2 + sz * CosBJ(jd3) )
    set y3=( y2 + sz * SinBJ(jd3) )
    call SetUnitX(dw, x3)
    call SetUnitY(dw, y3)
    call EXSetEffectXY(tstx[0] , x3 , y3)
    set gd=RMaxBJ(gd - sjss, 0)
    call SaveReal(hsb, jsqid, StringHash("高度"), gd)
    call EXSetEffectZ(tstx[0] , ( EXGetEffectZ(tstx[0]) - sjss )) //高度
    call EXSetEffectXY(tstx[10] , x3 , y3)
    call EXSetEffectZ(tstx[10] , ( EXGetEffectZ(tstx[10]) - sjss )) //高度
    // call VJDebugMsg("高度" + R2S(gd))
    if time >= 5.5 and time <= 5.7 then
    set sz=( time - 5.5 ) * 10
    else
    set sz=15.3
    endif
    set a=0
    loop
    set a=a + 1
    set jd3=jd
    set x3=EXGetEffectX(tstx[10 + a])
    set y3=EXGetEffectY(tstx[10 + a])
    set x3=( x3 + sz * CosBJ(jd3) )
    set y3=( y3 + sz * SinBJ(jd3) )
    call EXSetEffectXY(tstx[10 + a] , x3 , y3)
    call EXSetEffectZ(tstx[10 + a] , ( EXGetEffectZ(tstx[10 + a]) - sjss )) //高度
    exitwhen a >= 5
    endloop
    endif
    if time == 5.5 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    //橙色高光特效
    set zfc="94.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXSetEffectSize(tx , 20) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 1000 )) //高度
    call DestroyEffect(tx)
    // //气息特效
    // set zfc = "-1359748949.mdx"
    // set tx = AddSpecialEffect(zfc, x, y)
    // call EXEffectMatRotateX(tx, -65) //角度
    // call EXEffectMatRotateZ(tx, jd-90) //角度
    // call EXSetEffectSize(tx, 3) //大小
    // call EXSetEffectColor(tstx[0], 0xff000000 * PercentTo255(10) + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(90) + PercentTo255(90))
    // call EXSetEffectZ(tx, (EXGetEffectZ(tx) + 1800)) //高度
    // call DestroyEffect(tx)
    endif
    if time == 5.7 then
    set gdsd=gd / 10
    call SaveReal(hsb, jsqid, StringHash("高度速度"), gdsd)
    call SelectUnitForPlayerSingle(dw, wj)
    call EXSetEffectColor(tstx[0] , 0xff000000 + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(0) + PercentTo255(0))
    //灰色底盘
    set zfc="999422576.mdx"
    set tstx[1]=AddSpecialEffect(zfc, x2, y2)
    call EXEffectMatRotateZ(tstx[1] , jd) //角度
    call EXSetEffectSize(tstx[1] , 4) //大小
    call EXSetEffectSpeed(tstx[1] , 0.5) //动画速度
    call EXSetEffectColor(tstx[1] , 0xff000000 + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(0) + PercentTo255(0))
    call EXSetEffectZ(tstx[1] , ( EXGetEffectZ(tstx[1]) - 10.00 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(1)), tstx[1])
    endif
    if time == 5.9 then
    call mh_tm1(dw , 0.3 , 0.02 , 0 , 100 , 5)
    call EXSetEffectSpeed(tstx[0] , 0.1) //动画速度
    call EXSetEffectColor(tstx[1] , 0xff000000 * PercentTo255(10) + 0x10000 * PercentTo255(40) + 0x100 * PercentTo255(25) + PercentTo255(0))
    //萨姆爆炸蓄力特效
    set zfc="847903613.mdx"
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXEffectMatRotateZ(tx , 263) //角度
    call EXSetEffectSize(tx , 4) //大小
    call SetPariticle2Size(tx , 3.5) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) - 80 )) //高度
    call DestroyEffect(tx)
    call SetCameraFieldForPlayer(wj, CAMERA_FIELD_TARGET_DISTANCE, ( 2800.00 ), 0.08) //玩家镜头
    set a=- 1
    loop
    set a=a + 1
    call DestroyEffect(tstx[10 + a])
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(10 + a)), tstx[1])
    exitwhen a >= 5
    endloop
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 20.00)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.2, false, function mh__jtzdhs1)
    endif
    if time >= 5.9 then
    if time <= 6.5 then //引爆相关预热特效
    if time == 6.0 then
    call EXSetEffectColor(tstx[0] , 0xff000000 + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(0) + PercentTo255(0))
    endif
    if time == 6.3 then
    call DestroyEffect(tstx[0])
    call EXSetEffectXY(tstx[0] , - 3400 , 28000)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 10.00)
    //白色底盘
    set zfc="-307615899.mdx"
    set tstx[2]=AddSpecialEffect(zfc, x2, y2)
    call EXSetEffectColor(tstx[2] , 0xff000000 + 0x10000 * PercentTo255(90) + 0x100 * PercentTo255(90) + PercentTo255(90))
    call EXEffectMatRotateZ(tstx[2] , jd) //角度
    call EXSetEffectSize(tstx[2] , 6) //大小
    call EXSetEffectSpeed(tstx[2] , 2.5) //动画速度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(2)), tstx[2])
    set ydl_group=CreateGroup() //造成伤害
    call GroupEnumUnitsInRange(ydl_group, x2, y2, 4000, null)
    loop EnumItemsInRectBJ
    set ydl_unit=FirstOfGroup(ydl_group)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(ydl_group, ydl_unit)
    //查询防御状态和是否拥有无法选取 以及通用的选取条件
    if ( ( IsUnitEnemy(ydl_unit, wj) == true ) and ( GetUnitPointValue(ydl_unit) != 233 ) and ( IsUnitType(ydl_unit, UNIT_TYPE_DEAD) == false ) ) then
    call SetUnitVertexColorBJ(ydl_unit, 0, 0, 0, 0)
    call GroupAddUnit(dwz, ydl_unit)
    endif
    endloop
    call DestroyGroup(ydl_group)
    endif
    if time >= 6.2 then
    set sjss=GetRandomReal(0, 1500)
    set jd3=GetRandomReal(0, 360)
    set x3=( x2 + sjss * CosBJ(jd3) )
    set y3=( y2 + sjss * SinBJ(jd3) )
    set zfc="-680558139.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(80) + PercentTo255(20))
    call EXSetEffectSize(tx , GetRandomReal(1, 2)) //大小
    call SetPariticle2Size(tx , GetRandomReal(1, 2)) //内置api调大小
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.5)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(100, 1200) )) //高度
    call DestroyEffect(tx)
    set sjss=GetRandomReal(0, 800)
    set jd3=GetRandomReal(0, 360)
    set x3=( x2 + sjss * CosBJ(jd3) )
    set y3=( y2 + sjss * SinBJ(jd3) )
    //黑白闪十字
    set zfc="-436872007.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(0) + PercentTo255(0))
    call EXSetEffectSize(tx , GetRandomReal(1, 2.5)) //大小
    call SetPariticle2Size(tx , GetRandomReal(1, 1.5)) //内置api调大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.5, 2)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(400, 1500) )) //高度
    call DestroyEffect(tx)
    if ModuloReal(time, 0.1) == 0.1 then
    //黑丝线
    set zfc="1497826160.mdx"
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXSetEffectSize(tx , GetRandomReal(9, 12)) //大小
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(0) + PercentTo255(0))
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.5)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(0, 500) )) //高度
    call DestroyEffect(tx)
    endif
    endif
    endif
    if time >= 6.5 then
    if ModuloReal(time, 0.2) == 0.2 then
    //气浪特效
    set zfc="-1359748949.mdx"
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXEffectMatRotateY(tx , - 15 * I2R(GetRandomInt(4, 6))) //角度
    call EXEffectMatRotateZ(tx , GetRandomReal(0, 360)) //角度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(70, 90)) + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(90) + PercentTo255(90))
    call EXSetEffectSize(tx , GetRandomReal(5, 8)) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(0.75, 1)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(300, 1500) )) //高度
    call DestroyEffect(tx)
    endif
    if ModuloReal(time, 0.4) == 0.4 then
    //冷色气场特效3
    set zfc="-865519883.mdx"
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXEffectMatRotateY(tx , - 90)
    call EXSetEffectSize(tx , 10 + ( time - 6.5 )) //大小
    call EXSetEffectSpeed(tx , 0.5) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 1200.00 )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(60, 82)) + 0x10000 * PercentTo255(GetRandomReal(40, 60)) + 0x100 * PercentTo255(30) + PercentTo255(10))
    call DestroyEffect(tx)
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXEffectMatRotateY(tx , - 90)
    call EXSetEffectSize(tx , 8 + ( time - 6.5 )) //大小
    call EXSetEffectSpeed(tx , 0.65) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 800.00 )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(60, 82)) + 0x10000 * PercentTo255(GetRandomReal(40, 60)) + 0x100 * PercentTo255(30) + PercentTo255(10))
    call DestroyEffect(tx)
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXEffectMatRotateY(tx , - 90)
    call EXSetEffectSize(tx , 6 + ( time - 6.5 )) //大小
    call EXSetEffectSpeed(tx , 0.8) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 400.00 )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(60, 82)) + 0x10000 * PercentTo255(GetRandomReal(40, 60)) + 0x100 * PercentTo255(30) + PercentTo255(10))
    call DestroyEffect(tx)
    endif
    if ModuloReal(time, 0.1) == 0.1 then
    set ydl_group=CreateGroup() //造成伤害dwz
    call GroupEnumUnitsInRange(ydl_group, x2, y2, 1000.00, null)
    loop
    set ydl_unit=FirstOfGroup(ydl_group)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(ydl_group, ydl_unit)
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 1 ) and ( IsUnitEnemy(ydl_unit, wj) == true ) ) then // INLINED!!
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 4 ) ) then // INLINED!!
    call mh_zzfycfxt1(ydl_unit , null , 0)
    endif
    endif
    //查询防御状态和是否拥有无法选取 以及通用的选取条件  不判断重复
    if ( ( IsUnitEnemy(ydl_unit, wj) == true ) and ( GetUnitPointValue(ydl_unit) != 233 ) and ( mh_tjfz6(ydl_unit , 0) == true ) and ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) and ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 3, 3)) == 0) == true ) and ( IsUnitType(ydl_unit, UNIT_TYPE_DEAD) == false ) ) then // INLINED!!
    //英雄攻击类型 强化伤害类型
    if time == 6.5 then
    call mh_sh1(dw , ydl_unit , sh , 4 , 0 , true , false , ATTACK_TYPE_HERO , DAMAGE_TYPE_ENHANCED , WEAPON_TYPE_WHOKNOWS)
    set udg_wndanwei_jndw[1]=dw
    set udg_wndanwei_jndw[2]=ydl_unit
    set udg_wnzhengshu__zs[1]=4
    set udg_wnzhengshu__zs[2]=100
    call TriggerExecute(gg_trg_J_Firefly____________000_fz)
    else
    call mh_sh1(dw , ydl_unit , sh2 , 4 , 0 , true , false , ATTACK_TYPE_HERO , DAMAGE_TYPE_ENHANCED , WEAPON_TYPE_WHOKNOWS)
    set udg_wndanwei_jndw[1]=dw
    set udg_wndanwei_jndw[2]=ydl_unit
    set udg_wnzhengshu__zs[1]=4
    set udg_wnzhengshu__zs[2]=20
    call TriggerExecute(gg_trg_J_Firefly____________000_fz)
    endif
    call IssueTargetOrder(mj3, "thunderbolt", ydl_unit)
    if IsUnitInGroup(ydl_unit, dwz) == false and time >= 6.8 then
    set zfc="2003202463.mdx"
    set tx2=AddSpecialEffect(zfc, GetUnitX(ydl_unit), GetUnitY(ydl_unit)) //爱丽丝受击特效
    call EXEffectMatRotateZ(tx2 , ( ( 25.00 ) * ( I2R(GetRandomInt(1, 14)) ) )) //角度
    call EXSetEffectSize(tx2 , ( GetRandomReal(0.4, 0.6) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.40 ) )) //大小
    call SetPariticle2Size(tx2 , GetRandomReal(0.4, 0.6) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.40 )) //内置api调大小
    call EXSetEffectSpeed(tx2 , GetRandomReal(1.5, 2)) //特效动画速度
    call EXSetEffectZ(tx2 , ( EXGetEffectZ(tx2) + ( GetUnitFlyHeight(ydl_unit) + 50 ) )) //高度
    call DestroyEffect(tx2)
    set zfc="199706486.mdx"
    set tx2=AddSpecialEffect(zfc, GetUnitX(ydl_unit), GetUnitY(ydl_unit)) //爱丽丝受击特效
    call EXEffectMatRotateY(tx2 , - 25 * I2R(GetRandomInt(1, 14))) //角度
    call EXEffectMatRotateZ(tx2 , ( ( 25.00 ) * ( I2R(GetRandomInt(1, 14)) ) )) //角度
    call EXSetEffectSize(tx2 , ( GetRandomReal(0.4, 0.6) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.40 ) )) //大小
    call EXSetEffectSpeed(tx2 , GetRandomReal(1.5, 2)) //特效动画速度
    call EXSetEffectZ(tx2 , ( EXGetEffectZ(tx2) + ( GetUnitFlyHeight(ydl_unit) + 100 ) )) //高度
    call DestroyEffect(tx2)
    call GroupAddUnit(dwz, ydl_unit)
    endif
    endif
    endloop
    call DestroyGroup(ydl_group)
    endif
    endif
    endif
    if time == 6.5 then
    call dsound("tsubaki-hit15.mp3" , dw)
    call SetCameraFieldForPlayer(wj, CAMERA_FIELD_TARGET_DISTANCE, ( 3400.00 ), 1.4) //玩家镜头
    //哈利路大旋风
    set zfc="-391118009.mdx"
    set tstx[3]=AddSpecialEffect(zfc, x2, y2 + 400)
    call EXSetEffectColor(tstx[3] , 0xff000000 + 0x10000 * PercentTo255(4) + 0x100 * PercentTo255(4) + PercentTo255(4))
    call EXEffectMatRotateZ(tstx[3] , 270) //角度
    call EXEffectMatScale(tstx[3] , 3 , 3 , 4) //s缩放
    call SetPariticle2Size(tstx[3] , 3) //内置api调大小
    call EXSetEffectSpeed(tstx[3] , 0.4) //动画速度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(3)), tstx[3])
    //哈利路大旋风2
    set zfc="1671355440.mdx"
    set tstx[5]=AddSpecialEffect(zfc, x2, y2)
    call EXSetEffectColor(tstx[5] , 0xff000000 + 0x10000 * PercentTo255(4) + 0x100 * PercentTo255(4) + PercentTo255(4))
    call EXEffectMatRotateZ(tstx[5] , jd) //角度
    call EXEffectMatScale(tstx[5] , 4 , 4 , 4) //s缩放
    call SetPariticle2Size(tstx[5] , 4) //内置api调大小
    call EXSetEffectSpeed(tstx[5] , 0.2) //动画速度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(5)), tstx[5])
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 100.00)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.8, false, function mh__jtzdhs1)
    endif
    if time == 6.6 then
    call EXSetEffectColor(tstx[5] , 0xff000000 + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(100))
    call EXSetEffectSpeed(tstx[5] , 0.75) //动画速度
    call DestroyEffect(tstx[2])
    call DestroyEffect(tstx[5])
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(0)), tstx[1])
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(2)), tstx[1])
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(5)), tstx[1])
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(6)), tstx[1])
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(7)), tstx[1])
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(8)), tstx[1])
    loop
    set ydl_unit=FirstOfGroup(dwz)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(dwz, ydl_unit)
    call SetUnitVertexColorBJ(ydl_unit, 100, 100, 100, 0)
    endloop
    call GroupClear(dwz)
    endif
    if time == 6.7 then
    call EXSetEffectColor(tstx[3] , 0xff000000 + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(100))
    call EXSetEffectSpeed(tstx[3] , 1) //动画速度
    //火焰爆炸特效1
    set zfc="759959238.mdx"
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXSetEffectSize(tx , 5) //大小
    call SetPariticle2Size(tx , 2.5) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) - 100 )) //高度
    call DestroyEffect(tx)
    //哈利路大旋风附件
    set zfc="tx_boss45_3.mdl"
    set tstx[4]=AddSpecialEffect(zfc, x2, y2)
    call EXEffectMatRotateZ(tstx[4] , jd) //角度
    call EXEffectMatScale(tstx[4] , 4 , 4 , 4) //s缩放
    call SetPariticle2Size(tstx[4] , 4) //内置api调大小
    call EXSetEffectZ(tstx[4] , ( EXGetEffectZ(tstx[4]) + 10 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(4)), tstx[4])
    //哈利路大旋风地面
    set zfc="chun-yanji-14_dm2.mdl"
    set tstx[9]=AddSpecialEffect(zfc, x2, y2)
    call EXEffectMatRotateZ(tstx[9] , jd) //角度
    call EXSetEffectSize(tstx[9] , 2) //大小
    call EXSetEffectSpeed(tstx[9] , 1.2) //动画速度
    call SetPariticle2Size(tstx[9] , 2) //内置api调大小
    call EXSetEffectZ(tstx[4] , ( EXGetEffectZ(tstx[4]) + 5 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(9)), tstx[9])
    //火焰喷射特效
    set zfc="chun-yanji-6.mdl"
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXEffectMatRotateZ(tx , 270) //角度
    call EXSetEffectSpeed(tx , 1.5) //动画速度
    call EXSetEffectSize(tx , 3) //大小
    call SetPariticle2Size(tx , 3) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) - 100 )) //高度
    call DestroyEffect(tx)
    endif
    if time == 7.8 then
    call PauseUnit(dw, false)
    call SetUnitFlyHeight(dw, 0, 0)
    call mh_tm1(dw , 0.8 , 0.02 , 0 , 100 , 6)
    //哈利路大旋风2
    set zfc="1671355440.mdx"
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXSetEffectSize(tx , 4) //大小
    call SetPariticle2Size(tx , 4) //内置api调大小
    call EXSetEffectSpeed(tx , 0.75) //动画速度
    call DestroyEffect(tx)
    //火焰竖线特效
    set zfc="chun-yanji-10.mdl"
    set tx=AddSpecialEffect(zfc, x2, y2 + 10)
    call EXEffectMatRotateZ(tx , GetRandomInt(0, 360)) //角度
    call EXSetEffectSize(tx , 2) //大小
    call SetPariticle2Size(tx , 2) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) - 100.00 )) //高度
    call DestroyEffect(tx)
    endif
    if time >= 8 then //代码结束
    call EXSetEffectSpeed(tstx[3] , 0.5) //动画速度
    call SetUnitTimeScale(dw, 1)
    call RemoveUnit(mj3)
    call GroupClear(dwz)
    call DestroyGroup(dwz)
    call FlushChildHashtable(hsb, jsqid)
    call DestroyTimer(GetExpiredTimer())
    set a=0
    loop
    if GetHandleId(tstx[a]) != 0 then
    call DestroyEffect(tstx[a])
    endif
    set a=a + 1
    exitwhen a >= 15
    endloop
    endif
    endif
    set dw=null
    set mj3=null
    set wj=null
    set jsq2=null
    set tx=null
    set tx2=null
    set zfc=null
    set a=0
    loop
    set tstx[a]=null
    set a=a + 1
    exitwhen a >= 15
    endloop
    set dwz=null
    set ydl_group=null
    set ydl_unit=null
    endfunction



    //===========================================================================
// Trigger: J-Firefly萨姆飞踢002
//===========================================================================
function Trig_J_Firefly____________002jn2 takes nothing returns nothing
    local timer jsq2
    local integer jsq2id
    local integer a= 0
    local integer jsqid= GetHandleId(GetExpiredTimer())
    local unit dw= LoadUnitHandle(hsb, jsqid, StringHash("dw"))
    local unit dw2= LoadUnitHandle(hsb, jsqid, StringHash("dw2"))
    local player wj= LoadPlayerHandle(hsb, jsqid, StringHash("wj"))
    local real x= LoadReal(hsb, jsqid, StringHash("x"))
    local real y= LoadReal(hsb, jsqid, StringHash("y"))
    local real x2= LoadReal(hsb, jsqid, StringHash("x2"))
    local real y2= LoadReal(hsb, jsqid, StringHash("y2"))
    local real jd= LoadReal(hsb, jsqid, StringHash("jd"))
    local string zfc
    local effect tx
    local effect tx2
    local real time= LoadReal(hsb, jsqid, StringHash("逝去时间"))
    
    local group ydl_group
    local group dwz= LoadGroupHandle(hsb, jsqid, StringHash("dwz"))
    local unit ydl_unit
    local unit mj= LoadUnitHandle(hsb, jsqid, StringHash("mj"))
    local unit mj3= LoadUnitHandle(hsb, jsqid, StringHash("mj3"))
    local real jd2= LoadReal(hsb, jsqid, StringHash("jd2"))
    local real jd3= LoadReal(hsb, jsqid, StringHash("jd3"))
    local real sd= LoadReal(hsb, jsqid, StringHash("速度"))
    local real gd= LoadReal(hsb, jsqid, StringHash("高度"))
    local real gdsd= LoadReal(hsb, jsqid, StringHash("高度速度"))
    local real sjss= 0
    local real sz= 0
    local integer pd= LoadInteger(hsb, jsqid, StringHash("判断"))
    local integer dz1= LoadInteger(hsb, jsqid, StringHash("开头动作1"))
    local integer dz2= LoadInteger(hsb, jsqid, StringHash("开头动作2"))
    local integer dz3= LoadInteger(hsb, jsqid, StringHash("开头动作3"))
    local integer dz4= LoadInteger(hsb, jsqid, StringHash("开头动作4"))
    local real dzsd1= LoadReal(hsb, jsqid, StringHash("开头动作动画速度1"))
    local real dzsd2= LoadReal(hsb, jsqid, StringHash("开头动作动画速度2"))
    local real dzsd3= LoadReal(hsb, jsqid, StringHash("开头动作动画速度3"))
    local real dzsd4= LoadReal(hsb, jsqid, StringHash("开头动作动画速度4"))
    local real sh1= LoadReal(hsb, jsqid, StringHash("伤害"))
    local real sh2= LoadReal(hsb, jsqid, StringHash("伤害2"))
    local real sh3= LoadReal(hsb, jsqid, StringHash("伤害3"))
    local real x3= 0
    local real y3= 0
    local real x4= 0
    local real y4= 0
    local integer jnzs= LoadInteger(hsb, jsqid, StringHash("jnzs"))
    local integer jnzs2= LoadInteger(hsb, jsqid, StringHash("jnzs2"))
    local effect array tstx
    set tstx[0]=LoadEffectHandle(hsb, jsqid, StringHash("特效" + I2S(0)))
    if mh_stpd2(dw) == 0 then //判断该单位是否处于时停
    set time=time + 0.02
    call SaveReal(hsb, jsqid, StringHash("逝去时间"), time)
    if time == 0.02 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set mj3=CreateUnit(wj, 'e002', x, y, 0) //全能技能马甲zhan
    call UnitAddAbility(mj3, 'A00J') //眩晕1s
    call SaveUnitHandle(hsb, jsqid, StringHash("mj3"), mj3)
    call SetUnitAnimationByIndex(dw, dz1)
    call SetUnitTimeScale(dw, dzsd1)
    call UnitAddAbility(dw, 'Amrf')
    call UnitRemoveAbility(dw, 'Amrf')
    call SetUnitFlyHeight(dw, 0.00, 0.00)
    set sh1=( 75.00 + ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, dw, true)) * 2 ) )
    set sh2=( 75.00 + ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, dw, true)) * 3 ) )
    call mh_buffkq(dw , 2.2 , 2 , 1) //假无敌
    
    set sjss=1
    if ( ( GetUnitAbilityLevel(dw, 'A0TK') >= 1 ) ) then
    set sjss=sjss + 0.1
    endif
    set sh1=sh1 * sjss
    set sh2=sh2 * sjss
    call SaveReal(hsb, jsqid, StringHash("伤害"), sh1)
    call SaveReal(hsb, jsqid, StringHash("伤害2"), sh2)
    call dsound("mh_Firefly_form1_jn4.mp3" , dw)
    endif
    if time == 0.3 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    if dw2 != null and IsUnitType(dw2, UNIT_TYPE_DEAD) == false then
    set x2=GetUnitX(dw2)
    set y2=GetUnitY(dw2)
    set jd=Atan2BJ(( y2 - y ), ( x2 - x ))
    call SetUnitFacingTimed(dw, jd, 0)
    call EXSetUnitFacing(dw , jd)
    call SaveReal(hsb, jsqid, StringHash("jd"), jd)
    endif
    set sd=SquareRoot(( Pow(( x - x2 ), 2.00) + Pow(( y - y2 ), 2.00) )) * 0.08
    call SaveReal(hsb, jsqid, StringHash("速度"), sd)
    if GetRandomInt(1, 2) == 1 then
    call dsound("mh_Firefly_form1_jn5.mp3" , dw)
    else
    call dsound("mh_Firefly_form1_jn6.mp3" , dw)
    endif
    call SetUnitTimeScale(dw, dzsd2)
    call PlaySoundOnUnitBJ(LoadSoundHandle(hsb, jsqid, StringHash("语音" + I2S(1))), 100, dw) //语音
    //气场特效
    set zfc="-672674974.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 1.5) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.2, 1.5)) //动画速度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(20, 40)) + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(100))
    call DestroyEffect(tx)
    //气场特效2
    set zfc="1577588603.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 270) //角度
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 3) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.5, 2)) //动画速度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(70, 80)) + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(100))
    call DestroyEffect(tx)
    //沙尘气息特效
    set zfc="t7_zhendi-qiquan-boom.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 3) //大小
    call SetPariticle2Size(tx , 2) //内置api调大小
    call DestroyEffect(tx)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 10.00)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.1, false, function mh__jtzdhs1)
    endif
    if time == 1.4 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call SetUnitVertexColor(dw, 255, 0, 0, 255)
    //火焰腿特效
    set zfc="chun-yanji-4.mdl"
    set tx=AddSpecialEffectTargetUnitBJ("foot right", dw, zfc)
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(0)), tx)
    //火焰爆炸特效1
    set zfc="fire-boom-new.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 40) //角度
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSpeed(tx , 3) //动画速度
    call EXSetEffectSize(tx , 2) //大小
    call SetPariticle2Size(tx , 1.5) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 500.00 )) //高度
    call DestroyEffect(tx)
    endif
    if time == 1.5 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call SetUnitVertexColor(dw, 255, 255, 255, 255)
    set sd=SquareRoot(( Pow(( x - x2 ), 2.00) + Pow(( y - y2 ), 2.00) )) / 5
    set sz=0
    if dw2 != null and IsUnitType(dw2, UNIT_TYPE_DEAD) == false then
    set sz=GetUnitFlyHeight(dw2)
    endif
    set gdsd=( GetUnitFlyHeight(dw) - sz ) / 5
    call SaveReal(hsb, jsqid, StringHash("速度"), sd)
    call SaveReal(hsb, jsqid, StringHash("高度速度"), gdsd)
    //冲刺特效1
    set zfc="[tutx]312.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , 50) //角度
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1.1, 1.3)) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(1.4, 1.8)) //大小
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(80))
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 400.00 )) //高度
    call DestroyEffect(tx)
    //气息特效
    set zfc="117448227.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 40) //角度
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.2)) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(2.5, 3)) //大小
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(60, 80)) + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(100))
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 300.00 )) //高度
    call DestroyEffect(tx)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 20)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.1, false, function mh__jtzdhs1)
    endif
    if time >= 0.3 and time <= 1.6 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    if dw2 != null and IsUnitType(dw2, UNIT_TYPE_DEAD) == false then
    set x2=GetUnitX(dw2)
    set y2=GetUnitY(dw2)
    set jd=Atan2BJ(( y2 - y ), ( x2 - x ))
    call SetUnitFacingTimed(dw, jd, 0)
    call EXSetUnitFacing(dw , jd)
    call SaveReal(hsb, jsqid, StringHash("jd"), jd)
    endif
    set jd3=jd
    if time <= 1.44 then
    set sjss=( 0.00 + RMaxBJ(( sd - ( ( time - 0.3 ) * 500.00 ) ), 2.00) )
    set sz=( 0.00 + RMaxBJ(( 80 - ( ( time - 0.3 ) * 400.00 ) ), 1.00) )
    set gd=gd + sz
    endif
    if time >= 1.5 then
    set sjss=( 0.00 + RMaxBJ(( sd - ( ( time - 1.44 ) * 100.00 ) ), 5.00) )
    set sz=gdsd
    set gd=gd - sz
    endif
    set x=( x + sjss * CosBJ(jd3) )
    set y=( y + sjss * SinBJ(jd3) )
    call SaveReal(hsb, jsqid, StringHash("高度"), gd)
    call SetUnitFlyHeight(dw, gd, ( sz / 0.02 ))
    if mh_jcdwxy(x , y) == true then
    call SetUnitX(dw, x)
    call SetUnitY(dw, y)
    endif
    endif
    if time == 1.6 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set jd3=jd
    set x3=( x + 150 * CosBJ(jd3) )
    set y3=( y + 150 * SinBJ(jd3) )
    call SetUnitVertexColor(dw, 255, 150, 0, 255)
    //火焰踹击特效
    set zfc="-834687343.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 40) //角度
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSpeed(tx , 1.8) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(2.5, 3)) //大小
    call SetPariticle2Size(tx , 2.75) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 150.00 )) //高度
    call DestroyEffect(tx)
    set ydl_group=CreateGroup() //造成伤害dwz
    call GroupEnumUnitsInRange(ydl_group, x3, y3, 200.00, null)
    loop
    set ydl_unit=FirstOfGroup(ydl_group)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(ydl_group, ydl_unit)
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 1 ) and ( IsUnitEnemy(ydl_unit, wj) == true ) ) then // INLINED!!
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) ) then // INLINED!!
    call mh_zzfycfxt1(ydl_unit , null , 0)
    endif
    endif
    //查询防御状态和是否拥有无法选取 以及通用的选取条件  不判断重复
    if ( ( IsUnitEnemy(ydl_unit, wj) == true ) and ( GetUnitPointValue(ydl_unit) != 233 ) and ( mh_tjfz6(ydl_unit , 0) == true ) and ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) and ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 3, 3)) == 0) == true ) and ( IsUnitType(ydl_unit, UNIT_TYPE_DEAD) == false ) ) and IsUnitInGroup(ydl_unit, dwz) == false then // INLINED!!
    //英雄攻击类型 强化伤害类型
    call mh_sh1(dw , ydl_unit , sh1 , 4 , 0 , true , false , ATTACK_TYPE_HERO , DAMAGE_TYPE_ENHANCED , WEAPON_TYPE_WHOKNOWS)
    call IssueTargetOrder(mj3, "thunderbolt", ydl_unit)
    set zfc="impact2.mdx"
    set tx2=AddSpecialEffect(zfc, GetUnitX(ydl_unit), GetUnitY(ydl_unit)) //随机受击特效
    call EXEffectMatRotateZ(tx2 , ( ( 25.00 ) * ( I2R(GetRandomInt(1, 14)) ) )) //角度
    call EXSetEffectSize(tx2 , ( GetRandomReal(0.6, 0.8) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.40 ) )) //大小
    call EXSetEffectSpeed(tx2 , GetRandomReal(1.5, 2)) //特效动画速度
    call EXSetEffectZ(tx2 , ( EXGetEffectZ(tx2) + ( GetUnitFlyHeight(ydl_unit) + 50 ) )) //高度
    call DestroyEffect(tx2)
    set udg_wndanwei_jndw[1]=dw
    set udg_wndanwei_jndw[2]=ydl_unit
    set udg_wnzhengshu__zs[1]=4
    set udg_wnzhengshu__zs[2]=20
    call TriggerExecute(gg_trg_J_Firefly____________000_fz)
    endif
    endloop
    call DestroyGroup(ydl_group)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 30.00)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.08, false, function mh__jtzdhs1)
    endif
    if time == 1.7 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set jd3=jd
    set x=( x + 50 * CosBJ(jd3) )
    set y=( y + 50 * SinBJ(jd3) )
    call SetUnitX(dw, x)
    call SetUnitY(dw, y)
    set x3=( x + 150 * CosBJ(jd3) )
    set y3=( y + 150 * SinBJ(jd3) )
    call SetUnitVertexColor(dw, 255, 255, 255, 255)
    //火焰踹击特效2
    set zfc="974319856.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 40) //角度
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(0.8, 1)) //动画速度
    call EXSetEffectSize(tx , 1.5) //大小
    call SetPariticle2Size(tx , 1.5) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 100.00 )) //高度
    call DestroyEffect(tx)
    //气场特效3
    set zfc="-1359748949.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 50) //角度
    call EXEffectMatRotateZ(tx , jd - 180) //角度
    call EXSetEffectSize(tx , 1.5) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(0.75, 1)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 150.00 )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(10) + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(50) + PercentTo255(50))
    call DestroyEffect(tx)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 50.00)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.4, false, function mh__jtzdhs1)
    endif
    if time == 1.7 or time == 1.8 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set x3=( x + 150 * CosBJ(jd3) )
    set y3=( y + 150 * SinBJ(jd3) )
    if time == 1.8 then
    //火焰爆炸特效1
    set zfc="fire-boom-new.mdl"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 3) //大小
    call SetPariticle2Size(tx , 2) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) - 100.00 )) //高度
    call DestroyEffect(tx)
    //火焰爆炸特效1
    set zfc="chun-yanji-16.mdl"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(100) + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(100))
    call EXSetEffectSize(tx , 3) //大小
    call SetPariticle2Size(tx , 3) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) - 50.00 )) //高度
    call DestroyEffect(tx)
    endif
    set ydl_group=CreateGroup() //造成伤害dwz
    call GroupEnumUnitsInRange(ydl_group, x3, y3, 500.00, null)
    loop
    set ydl_unit=FirstOfGroup(ydl_group)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(ydl_group, ydl_unit)
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 1 ) and ( IsUnitEnemy(ydl_unit, wj) == true ) ) then // INLINED!!
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) ) then // INLINED!!
    call mh_zzfycfxt1(ydl_unit , null , 0)
    endif
    endif
    if mh_tjfz1(ydl_unit , wj) == true and time == 1.8 then //位移
    set x3=GetUnitX(ydl_unit) //位移
    set y3=GetUnitY(ydl_unit)
    set sz=GetRandomReal(80, 150)
    if ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 15, 15)) == 0) == false ) then // INLINED!!
    set sz=sz * 0.05
    endif
    set jd3=jd
    set x3=( x3 + sz * CosBJ(jd3) )
    set y3=( y3 + sz * SinBJ(jd3) )
    call SetUnitX(ydl_unit, x3)
    call SetUnitY(ydl_unit, y3)
    endif
    //查询防御状态和是否拥有无法选取 以及通用的选取条件  不判断重复
    if ( ( IsUnitEnemy(ydl_unit, wj) == true ) and ( GetUnitPointValue(ydl_unit) != 233 ) and ( mh_tjfz6(ydl_unit , 0) == true ) and ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) and ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 3, 3)) == 0) == true ) and ( IsUnitType(ydl_unit, UNIT_TYPE_DEAD) == false ) ) and IsUnitInGroup(ydl_unit, dwz) == false then // INLINED!!
    //英雄攻击类型 强化伤害类型
    call mh_sh1(dw , ydl_unit , sh2 , 4 , 0 , true , false , ATTACK_TYPE_HERO , DAMAGE_TYPE_ENHANCED , WEAPON_TYPE_WHOKNOWS)
    call IssueTargetOrder(mj3, "thunderbolt", ydl_unit)
    set zfc="chun-yanji-13.mdx"
    set tx2=AddSpecialEffect(zfc, GetUnitX(ydl_unit), GetUnitY(ydl_unit)) //随机受击特效
    call EXEffectMatRotateZ(tx2 , ( ( 25.00 ) * ( I2R(GetRandomInt(1, 14)) ) )) //角度
    call EXSetEffectSize(tx2 , ( GetRandomReal(0.6, 0.8) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.40 ) )) //大小
    call EXSetEffectSpeed(tx2 , GetRandomReal(1.5, 2)) //特效动画速度
    call EXSetEffectZ(tx2 , ( EXGetEffectZ(tx2) + ( GetUnitFlyHeight(ydl_unit) + 80 ) )) //高度
    call DestroyEffect(tx2)
    set udg_wndanwei_jndw[1]=dw
    set udg_wndanwei_jndw[2]=ydl_unit
    set udg_wnzhengshu__zs[1]=4
    set udg_wnzhengshu__zs[2]=50
    call TriggerExecute(gg_trg_J_Firefly____________000_fz)
    if IsUnitType(ydl_unit, UNIT_TYPE_HERO) == true then
    endif
    endif
    endloop
    call DestroyGroup(ydl_group)
    endif
    if time == 2.0 then
    call IssueImmediateOrder(mj, "stop")
    call DestroyEffect(tstx[0])
    call SetUnitTimeScale(dw, 1)
    endif
    if time >= 2.0 and time <= 2.4 then //sam落地
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    if time <= 2.1 then
    set sjss=RMaxBJ(( 80.00 - ( time - 2 ) * 600.00 ), 5.00)
    set gdsd=RMaxBJ(( 50.00 - ( time - 2.1 ) * 500.00 ), 5.00)
    endif
    if time == 2.2 then
    set gd=GetUnitFlyHeight(dw)
    set gdsd=gd / 10
    call SaveReal(hsb, jsqid, StringHash("高度速度"), gdsd)
    endif
    if time >= 2.2 then
    set sjss=RMaxBJ(( 30.00 - ( time - 2.2 ) * 200.00 ), 5.00)
    set gd=gd - gdsd
    endif
    call SaveReal(hsb, jsqid, StringHash("高度"), gd)
    set jd3=jd - 180
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    call SetUnitX(dw, x3)
    call SetUnitY(dw, y3)
    if GetUnitFlyHeight(dw) >= 0 then
    if time <= 2.1 then
    call SetUnitFlyHeight(dw, GetUnitFlyHeight(dw) + gdsd, gdsd / 0.02)
    else
    call SetUnitFlyHeight(dw, GetUnitFlyHeight(dw) - gdsd, gdsd / 0.02)
    endif
    else
    call SetUnitFlyHeight(dw, gd, 0.00)
    endif
    endif
    if time >= 2.4 then //代码结束
    call SetUnitVertexColor(dw, 255, 255, 255, 255)
    call RemoveUnit(mj)
    call RemoveUnit(mj3)
    call GroupClear(dwz)
    call DestroyGroup(dwz)
    call DestroyEffect(tstx[0])
    call FlushChildHashtable(hsb, jsqid)
    call DestroyTimer(GetExpiredTimer())
    endif
    endif
    set dw=null
    set dw2=null
    set mj=null
    set mj3=null
    set wj=null
    set jsq2=null
    set tx=null
    set tx2=null
    set zfc=null
    set dwz=null
    set ydl_group=null
    set ydl_unit=null
    set tstx[0]=null
    endfunction
    function Trig_J_Firefly____________002Actions takes nothing returns nothing
    local timer jsq= CreateTimer()
    local integer jsqid= GetHandleId(jsq)
    local unit dw= udg_wndanwei_jndw[1]
    local unit dw2= udg_wndanwei_jndw[2]
    local unit mj
    local player wj= GetOwningPlayer(dw)
    local real x= GetUnitX(dw)
    local real y= GetUnitY(dw)
    local real x2= udg_wnshishu_shishu[0]
    local real y2= udg_wnshishu_shishu[1]
    local real jd= Atan2BJ(( y2 - y ), ( x2 - x ))
    local integer array dz
    local real array dzsd
    call IssueImmediateOrder(dw, "stop")
    set mj=CreateUnit(wj, 'e002', x, y, 0) //施法控制马甲
    call UnitAddAbility(mj, 'A00F') //技能释放中
    call IssueTargetOrder(mj, "magicleash", dw)
    call SaveUnitHandle(hsb, jsqid, StringHash("mj"), mj)
    call mh_buffkq(dw , 0.5 , 2 , 1) //假无敌
    // if (GetUnitTypeId(dw) == 'O00U') then
    set dz[1]=2
    set dzsd[1]=2.66
    set dzsd[2]=1.05
    // endif
    //保存数据准备开始代码
    call SaveUnitHandle(hsb, jsqid, StringHash("dw"), dw)
    call SaveUnitHandle(hsb, jsqid, StringHash("dw2"), dw2)
    call SavePlayerHandle(hsb, jsqid, StringHash("wj"), wj)
    call SaveReal(hsb, jsqid, StringHash("x"), x)
    call SaveReal(hsb, jsqid, StringHash("y"), y)
    call SaveReal(hsb, jsqid, StringHash("x2"), x2)
    call SaveReal(hsb, jsqid, StringHash("y2"), y2)
    call SaveReal(hsb, jsqid, StringHash("jd"), jd)
    call SaveInteger(hsb, jsqid, StringHash("jnzs2"), 0)
    if GetRandomInt(1, 2) == 1 then
    call SaveSoundHandle(hsb, jsqid, StringHash("语音1"), gg_snd_mh_Fireflysam_jn3_1)
    else
    call SaveSoundHandle(hsb, jsqid, StringHash("语音1"), gg_snd_mh_Fireflysam_jn3_2)
    endif
    call SaveInteger(hsb, jsqid, StringHash("开头动作1"), dz[1])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度1"), dzsd[1])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度2"), dzsd[2])
    call SaveGroupHandle(hsb, jsqid, StringHash("dwz"), CreateGroup())
    call SaveStr(hsb, jsqid, StringHash("模型"), ( EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(dw)) + "].file") ))
    call SaveReal(hsb, jsqid, StringHash("模型大小"), S2R(( EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(dw)) + "].modelScale") )))
    call TimerStart(jsq, 0.02, TRUE, function Trig_J_Firefly____________002jn2) //开始执行
    set jsq=null
    set dw=null
    set dw2=null
    set mj=null
    set wj=null
    endfunction
    //===========================================================================
    function InitTrig_J_Firefly____________002 takes nothing returns nothing
    set gg_trg_J_Firefly____________002=CreateTrigger()
    call TriggerAddAction(gg_trg_J_Firefly____________002, function Trig_J_Firefly____________002Actions)
    endfunction
    //TESH.scrollpos=80
    //TESH.alwaysfold=0

//===========================================================================
// Trigger: J-Firefly萨姆点燃003
//===========================================================================
function Trig_J_Firefly____________003jn2 takes nothing returns nothing
    local timer jsq2
    local integer jsq2id
    local integer a= 0
    local integer jsqid= GetHandleId(GetExpiredTimer())
    local unit dw= LoadUnitHandle(hsb, jsqid, StringHash("dw"))
    local player wj= LoadPlayerHandle(hsb, jsqid, StringHash("wj"))
    local real x= LoadReal(hsb, jsqid, StringHash("x"))
    local real y= LoadReal(hsb, jsqid, StringHash("y"))
    local real x2= LoadReal(hsb, jsqid, StringHash("x2"))
    local real y2= LoadReal(hsb, jsqid, StringHash("y2"))
    local real jd= LoadReal(hsb, jsqid, StringHash("jd"))
    local string zfc
    local effect tx
    local effect tx2
    local real time= LoadReal(hsb, jsqid, StringHash("逝去时间"))
    local integer timezs= LoadInteger(hsb, jsqid, StringHash("逝去时间zs"))
    
    local group ydl_group
    local group dwz= LoadGroupHandle(hsb, jsqid, StringHash("dwz"))
    local unit ydl_unit
    local unit mj3= LoadUnitHandle(hsb, jsqid, StringHash("mj3"))
    local real jd3= LoadReal(hsb, jsqid, StringHash("jd3"))
    local real sjss= 0
    local integer sjzs= 0
    local real sz= 0
    local real x3= 0
    local real y3= 0
    local real x4= 0
    local real y4= 0
    local real sd= LoadReal(hsb, jsqid, StringHash("速度"))
    local real gd= LoadReal(hsb, jsqid, StringHash("高度"))
    local real gdsd= LoadReal(hsb, jsqid, StringHash("高度速度"))
    local real sh
    local real sh1= LoadReal(hsb, jsqid, StringHash("伤害1"))
    local real sh2= LoadReal(hsb, jsqid, StringHash("伤害2"))
    local real sh3= LoadReal(hsb, jsqid, StringHash("伤害3"))
    local integer jnzs= LoadInteger(hsb, jsqid, StringHash("jnzs"))
    local integer jnzs0= LoadInteger(hsb, jsqid, StringHash("jnzs0"))
    local integer jnzs1= LoadInteger(hsb, jsqid, StringHash("jnzs1"))
    local integer jnzs2= LoadInteger(hsb, jsqid, StringHash("jnzs2"))
    local integer jnzs3= LoadInteger(hsb, jsqid, StringHash("jnzs3"))
    local integer jnzs4= LoadInteger(hsb, jsqid, StringHash("jnzs4"))
    local effect array tstx
    set a=0
    loop
    set tstx[a]=LoadEffectHandle(hsb, jsqid, StringHash("特效" + I2S(a)))
    set a=a + 1
    exitwhen a >= 15
    endloop
    if ( ( ( mh_stpd2(dw) == 0 ) ) ) then //判断该单位是否处于时停
    set time=time + 0.02
    call SaveReal(hsb, jsqid, StringHash("逝去时间"), time)
    if time == 0.02 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set jd3=jd - 50
    set sjss=300
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    call SetUnitX(dw, x3)
    call SetUnitY(dw, y3)
    call UnitAddAbility(dw, 'Amrf')
    call UnitRemoveAbility(dw, 'Amrf')
    call SetUnitFlyHeight(dw, 0.00, 0.00)
    call SetUnitAnimationByIndex(dw, 3)
    call SetUnitTimeScale(dw, 2)
    set mj3=CreateUnit(wj, 'e002', x, y, 0) //全能技能马甲zhan
    call UnitAddAbility(mj3, 'A0CF') //眩晕2s
    call SaveUnitHandle(hsb, jsqid, StringHash("mj3"), mj3)
    call PlaySoundOnUnitBJ(LoadSoundHandle(hsb, jsqid, StringHash("语音" + I2S(1))), 100, dw) //语音
    call dsound("mh_Firefly_form2_R1.mp3" , dw)
    set sh1=( 100.00 + ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, dw, true)) * 0.8 ) )
    set sh2=( 100.00 + ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, dw, true)) * 20 ) )
    set sh3=( 100.00 + ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, dw, true)) * 1 ) )
    set sjss=1
    if ( ( GetUnitAbilityLevel(dw, 'A0TK') >= 1 ) ) then
    set sjss=sjss + 0.1
    endif
    if ( GetUnitAbilityLevel(udg_danwei_WJ_ysjgnfz[GetConvertedPlayerId(wj)], 'A0TW') >= 1 ) then
    set sjss=sjss + 0.15
    endif
    set sh1=sh1 * sjss
    set sh2=sh2 * sjss
    set sh3=sh3 * sjss
    call SaveReal(hsb, jsqid, StringHash("伤害1"), sh1)
    call SaveReal(hsb, jsqid, StringHash("伤害2"), sh2)
    call SaveReal(hsb, jsqid, StringHash("伤害3"), sh3)
    if ( ( GetPlayerTechCountSimple('R00V', wj) >= 1 ) ) then
    call mh_buffkq(dw , 2.2 , 6 , 1) //特殊无敌帧
    call mh_buffkq(dw , 6 , 16 , 1) //大招无敌帧
    endif
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 10.00)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.1, false, function mh__jtzdhs1)
    call SetCameraFieldForPlayer(wj, CAMERA_FIELD_TARGET_DISTANCE, ( 3400.00 + 1000.00 ), 1.00) //玩家镜头
    endif
    if time == 0.7 then //准备爆发
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call SetUnitTimeScale(dw, 1.4)
    //爆点特效
    set zfc="t7_wood_bashenan_juqi_1_2.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 5) //大小
    call SetPariticle2Size(tx , 4) //内置api调大小
    call EXSetEffectSpeed(tx , 1.5) //动画速度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(100) + PercentTo255(60))
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 100.00 )) //高度
    call DestroyEffect(tx)
    endif
    if time == 1.0 then //光翼展开
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call SetUnitAnimationByIndex(dw, 4)
    call SetUnitTimeScale(dw, 1.5)
    //爆点特效3
    set zfc="-1307095562.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 5) //大小
    call SetPariticle2Size(tx , 5) //内置api调大小
    call EXSetEffectSpeed(tx , 1.5) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 100.00 )) //高度
    call DestroyEffect(tx)
    //爆点特效
    set zfc="291568352.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 8) //大小
    call SetPariticle2Size(tx , 5) //内置api调大小
    call EXSetEffectSpeed(tx , 2) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 100.00 )) //高度
    call DestroyEffect(tx)
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 8) //大小
    call SetPariticle2Size(tx , 3) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 100.00 )) //高度
    call DestroyEffect(tx)
    //爆点特效2
    set zfc="1180814843.mdx"
    set tstx[4]=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tstx[4] , jd) //角度
    call EXSetEffectSize(tstx[4] , 2.5) //大小
    call SetPariticle2Size(tstx[4] , 2.5) //内置api调大小
    call EXSetEffectSpeed(tstx[4] , 1.25) //动画速度
    call EXSetEffectZ(tstx[4] , ( EXGetEffectZ(tstx[4]) + GetUnitFlyHeight(dw) + 100.00 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(4)), tstx[4])
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 30.00)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.3, false, function mh__jtzdhs1)
    endif
    if time == 2.0 then //冲刺  冲
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call SetUnitAnimationByIndex(dw, 5)
    call SetUnitTimeScale(dw, 2.5)
    set jd=Atan2BJ(( y2 - y ), ( x2 - x ))
    call SetUnitFacingTimed(dw, jd, 0)
    call EXSetUnitFacing(dw , jd)
    call SaveReal(hsb, jsqid, StringHash("jd"), jd)
    set sd=SquareRoot(( Pow(( x - x2 ), 2.00) + Pow(( y - y2 ), 2.00) )) / 10
    set gdsd=( GetUnitFlyHeight(dw) ) / 11
    call SaveReal(hsb, jsqid, StringHash("速度"), sd)
    call SaveReal(hsb, jsqid, StringHash("高度速度"), gdsd)
    // call mh_tm1(dw, 0.2, 0.02, 0, 100, 5)
    //星空底盘特效
    set zfc="1917564014.mdx"
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 10) //大小
    call SetPariticle2Size(tx , 4) //内置api调大小
    call EXSetEffectSpeed(tx , 0.8) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 5 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(1)), tx)
    //灰色底盘
    set zfc="999422576.mdx"
    set tstx[2]=AddSpecialEffect(zfc, x2, y2)
    call EXSetEffectColor(tstx[2] , 0xff000000 + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(0) + PercentTo255(0))
    call EXEffectMatRotateZ(tstx[2] , jd) //角度
    call EXSetEffectSize(tstx[2] , 6) //大小
    call EXSetEffectSpeed(tstx[2] , 2.5) //动画速度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(2)), tstx[2])
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 20.00)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.1, false, function mh__jtzdhs1)
    call SetCameraFieldForPlayer(wj, CAMERA_FIELD_TARGET_DISTANCE, 3200, 0.1) //玩家镜头
    endif
    if time >= 0.00 and time <= 2.2 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    if time <= 1.3 then //前期飞行
    set sjss=RMaxBJ(( 150 - ( ( time - 0.5 ) * 400.00 ) ), 2.00)
    set sz=RMaxBJ(( 70 - ( ( time - 0.5 ) * 400.00 ) ), 1.00)
    set jd3=jd - 180
    if time <= 0.5 then
    set jd3=jd - 50 + ( time * 50 * 12 )
    set sjss=RMinBJ(( 50 + ( ( time ) * 200.00 ) ), 150.00)
    set sz=RMinBJ(( 25 + ( ( time ) * 80.00 ) ), 60.00)
    endif
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    if mh_jcdwxy(x3 , y3) == true then
    call SetUnitX(dw, x3)
    call SetUnitY(dw, y3)
    endif
    set gd=gd + sz
    call SaveReal(hsb, jsqid, StringHash("高度"), gd)
    call SetUnitFlyHeight(dw, gd, ( sz / 0.02 ))
    endif
    if time >= 2 and time <= 2.2 then //突进到目标点
    set sjss=sd
    set sz=gdsd
    set gd=gd - sz
    set jd3=jd
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    if mh_jcdwxy(x3 , y3) == true then
    call SetUnitX(dw, x3)
    call SetUnitY(dw, y3)
    endif
    call SetUnitFlyHeight(dw, gd, ( sz / 0.02 ))
    call SaveReal(hsb, jsqid, StringHash("高度"), gd)
    if ModuloReal(time, 0.06) == 0.06 then
    //气息特效
    set zfc="e_poisonbomb_qichang.mdl"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 40) //角度
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 4 - ( ( time - 2 ) * 10 )) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.25)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 0.00 )) //高度
    call DestroyEffect(tx)
    endif
    endif
    endif
    if time == 1.46 then //休息一下
    call PlaySoundOnUnitBJ(LoadSoundHandle(hsb, jsqid, StringHash("语音" + I2S(2))), 100, dw) //语音
    endif
    if time == 2.24 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call SetUnitVertexColor(dw, 255, 255, 255, 0)
    call SetUnitFlyHeight(dw, - 999, 0)
    call DestroyEffect(tstx[4])
    // call mh_tm1(dw, 0.1, 0.02, 0, 100, 5)
    endif
    if time >= 2.24 and time <= 3.78 then
    set sjss=GetRandomReal(0, 500)
    set jd3=GetRandomReal(0, 360)
    set x3=( x2 + sjss * CosBJ(jd3) )
    set y3=( y2 + sjss * SinBJ(jd3) )
    call SetUnitX(dw, x3)
    call SetUnitY(dw, y3)
    call SetUnitAnimationByIndex(dw, GetRandomInt(7, 8))
    call SetUnitVertexColor(dw, 255, 255, 255, 0)
    call SetUnitFlyHeight(dw, - 999, 0)
    set jd3=GetRandomReal(0, 360)
    call SetUnitFacingTimed(dw, jd3, 0)
    call EXSetUnitFacing(dw , jd3)
    endif
    if time == 3.8 then //摆pose
    call SetUnitAnimationByIndex(dw, 6)
    call SetUnitTimeScale(dw, 1)
    call SetUnitFlyHeight(dw, 0, 0)
    call mh_tm1(dw , 0.2 , 0.02 , 0 , 100 , 6)
    set sjss=700
    set jd3=jd
    set x3=( x2 + sjss * CosBJ(jd3) )
    set y3=( y2 + sjss * SinBJ(jd3) )
    call SetUnitX(dw, x3)
    call SetUnitY(dw, y3)
    call SetUnitFacingTimed(dw, jd3, 0)
    call EXSetUnitFacing(dw , jd3)
    endif
    if time == 3.9 then
    //刀光1
    set zfc="-173761042.mdx"
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXEffectMatRotateZ(tx , jd + 180 - 25) //角度
    call EXSetEffectSize(tx , 3) //大小
    call SetPariticle2Size(tx , 2) //内置api调大小
    call EXSetEffectSpeed(tx , 1.8) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 200 )) //高度
    call DestroyEffect(tx)
    endif
    if time == 4.0 then
    // call EXSetEffectColor(tstx[1], 0xff000000 * PercentTo255(100) + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(0) + PercentTo255(0))
    call EXSetEffectXY(tstx[1] , - 3200 , 27500)
    //白色旋转刀光2
    set zfc="tx-04 (8)-bhy.mdl"
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXEffectMatRotateY(tx , - 180) //角度
    call EXEffectMatRotateZ(tx , jd + 50) //角度
    call EXSetEffectSize(tx , 7) //大小
    call EXSetEffectSpeed(tx , 0.85) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 160 )) //高度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(100) + PercentTo255(80))
    call DestroyEffect(tx)
    //白色底盘
    set zfc="-307615899.mdx"
    set tstx[3]=AddSpecialEffect(zfc, x2, y2)
    call EXSetEffectColor(tstx[3] , 0xff000000 + 0x10000 * PercentTo255(90) + 0x100 * PercentTo255(90) + PercentTo255(90))
    call EXEffectMatRotateZ(tstx[3] , jd) //角度
    call EXSetEffectSize(tstx[3] , 6) //大小
    call EXSetEffectSpeed(tstx[3] , 2.5) //动画速度
    call EXSetEffectZ(tstx[3] , ( EXGetEffectZ(tstx[3]) + 10.00 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(3)), tstx[3])
    set ydl_group=CreateGroup() //造成伤害
    call GroupEnumUnitsInRange(ydl_group, x2, y2, 4000, null)
    loop
    set ydl_unit=FirstOfGroup(ydl_group)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(ydl_group, ydl_unit)
    //查询防御状态和是否拥有无法选取 以及通用的选取条件
    if ( ( IsUnitEnemy(ydl_unit, wj) == true ) and ( GetUnitPointValue(ydl_unit) != 233 ) and ( IsUnitType(ydl_unit, UNIT_TYPE_DEAD) == false ) ) then
    call SetUnitVertexColorBJ(ydl_unit, 0, 0, 0, 0)
    call GroupAddUnit(dwz, ydl_unit)
    endif
    endloop
    call DestroyGroup(ydl_group)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 10.00)
    endif
    if time == 4.14 then
    //刀光特效
    set zfc="-1413746522.mdx"
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(80) + 0x100 * PercentTo255(40) + PercentTo255(20))
    call EXEffectMatRotateZ(tx , 270) //角度
    call EXSetEffectSize(tx , 2) //大小
    call EXSetEffectSpeed(tx , 2) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 100 )) //高度
    call DestroyEffect(tx)
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(80) + 0x100 * PercentTo255(40) + PercentTo255(20))
    call EXEffectMatRotateX(tx , - 90) //角度
    call EXEffectMatRotateZ(tx , 270) //角度
    call EXSetEffectSize(tx , 4) //大小
    call EXSetEffectSpeed(tx , 2.5) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 300 )) //高度
    call DestroyEffect(tx)
    //炸开特效
    set zfc="-950557588.mdx"
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(0) + PercentTo255(0))
    call EXSetEffectSize(tx , GetRandomReal(4, 6)) //大小
    call SetPariticle2Size(tx , 0.01) //内置api调大小
    call EXSetEffectSpeed(tx , 2.5) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 200 )) //高度
    call DestroyEffect(tx)
    endif
    if time == 4.2 then
    // call EXSetEffectColor(tstx[1], 0xff000000 * PercentTo255(0) + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(100))
    call EXSetEffectXY(tstx[1] , x2 , y2)
    call DestroyEffect(tstx[3])
    loop
    set ydl_unit=FirstOfGroup(dwz)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(dwz, ydl_unit)
    call SetUnitVertexColorBJ(ydl_unit, 100, 100, 100, 0)
    endloop
    call GroupClear(dwz)
    //炸开特效
    set zfc="-950557588.mdx"
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXSetEffectSize(tx , GetRandomReal(8, 10)) //大小
    call SetPariticle2Size(tx , GetRandomReal(8, 10)) //内置api调大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.75, 2)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 200 )) //高度
    call DestroyEffect(tx)
    //白色光柱
    set zfc="light4whitethick.mdl"
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXSetEffectSize(tx , 4) //大小
    call SetPariticle2Size(tx , 2) //内置api调大小
    call EXSetEffectSpeed(tx , 0.6) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) - 200 )) //高度
    call DestroyEffect(tx)
    set a=0
    loop
    set sjss=GetRandomReal(0, 200)
    set jd3=GetRandomReal(0, 360)
    set x3=( x2 + sjss * CosBJ(jd3) )
    set y3=( y2 + sjss * SinBJ(jd3) )
    //炸开特效
    set zfc="908196484.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateZ(tx , GetRandomReal(0, 360)) //角度
    call EXSetEffectSize(tx , GetRandomReal(8, 10)) //大小
    call SetPariticle2Size(tx , GetRandomReal(8, 10)) //内置api调大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.75, 2)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(400, 800) )) //高度
    call DestroyEffect(tx)
    set sjss=GetRandomReal(0, 200)
    set jd3=GetRandomReal(0, 360)
    set x3=( x2 + sjss * CosBJ(jd3) )
    set y3=( y2 + sjss * SinBJ(jd3) )
    //炸开特效
    set zfc="tx-299-orange.mdl"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateZ(tx , GetRandomReal(0, 360)) //角度
    call EXSetEffectSize(tx , GetRandomReal(6, 8)) //大小
    call SetPariticle2Size(tx , GetRandomReal(3, 4)) //内置api调大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.25, 1.5)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(400, 800) )) //高度
    call DestroyEffect(tx)
    set a=a + 1
    exitwhen a >= 3
    endloop
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 80.00)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.8, false, function mh__jtzdhs1)
    endif
    if time == 4.4 then
    //炸开特效
    set zfc="-301512626.mdx"
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 4) //大小
    call SetPariticle2Size(tx , GetRandomReal(2, 3)) //内置api调大小
    call EXSetEffectSpeed(tx , 1.5) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 10 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(0)), tx)
    call SO_CinematicFilterGenerictakes(wj , 0.10 , BLEND_MODE_BLEND , "ReplaceableTextures\\CameraMasks\\White_mask.blp" , 50.00 , 100 , 100 , 0.00 , 50.00 , 100.00 , 100.00 , 100.00)
    endif
    if time == 4.5 then
    call EXSetEffectSpeed(tstx[0] , 1) //动画速度
    endif
    if time >= 2.3 and time <= 6.0 then //特效和伤害
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    if time <= 3.8 then
    if ModuloReal(time, 0.1) == 0.1 then
    set sh=sh1
    set sjss=GetRandomReal(0, 200)
    set jd3=GetRandomReal(0, 360)
    set x3=( x2 + sjss * CosBJ(jd3) )
    set y3=( y2 + sjss * SinBJ(jd3) )
    //白色旋转刀光2
    if GetRandomReal(0, 2) <= 0.5 then
    set zfc="-124382725.mdx"
    else
    set zfc="tx-04 (8)-bhy.mdl"
    endif
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 10 * I2R(GetRandomInt(0, 7)))
    call EXEffectMatRotateZ(tx , GetRandomReal(0, 360)) //角度
    call EXSetEffectSize(tx , GetRandomReal(4, 5)) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.25)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(200, 400) )) //高度
    // if GetRandomReal(0, 2) <= 0.5 then
    // 	call EXSetEffectColor(tx, 0xff000000 + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(80) + PercentTo255(0))
    // else
    // 	call EXSetEffectColor(tx, 0xff000000 + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(100) + PercentTo255(80))
    // endif
    if GetRandomReal(0, 2) <= 0.5 then
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(60) + PercentTo255(20))
    else
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(100) + PercentTo255(70))
    endif
    call DestroyEffect(tx)
    set a=0
    loop
    set sjss=GetRandomReal(0, 200)
    set jd3=GetRandomReal(0, 360)
    set x3=( x2 + sjss * CosBJ(jd3) )
    set y3=( y2 + sjss * SinBJ(jd3) )
    //受击特效刀光特效
    if GetRandomInt(1, 3) == 1 then
    set zfc="tx-mh_tx_Firefly_hit4.mdl"
    else
    set zfc="impact2.mdl"
    endif
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateZ(tx , GetRandomReal(0, 360)) //角度
    call EXSetEffectSize(tx , GetRandomReal(3, 5)) //大小
    call SetPariticle2Size(tx , GetRandomReal(1, 2)) //内置api调大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.2, 1.4)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(150, 400) )) //高度
    call DestroyEffect(tx)
    set a=a + 1
    exitwhen a >= 3
    endloop
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 20.00)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.08, false, function mh__jtzdhs1)
    endif
    if ModuloReal(time, 0.06) == 0.06 then
    set sjss=GetRandomReal(0, 800)
    set jd3=GetRandomReal(0, 360)
    set x3=( x2 + sjss * CosBJ(jd3) )
    set y3=( y2 + sjss * SinBJ(jd3) )
    set sz=GetRandomReal(0.75, 1)
    set sjss=GetRandomReal(200, 500)
    //青色序列刀光特效
    if GetRandomReal(0, 2) <= 0.5 then
    set zfc="-1839660434.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    else
    set zfc="-1413746522.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(20) + 0x100 * PercentTo255(GetRandomReal(70, 80)) + PercentTo255(GetRandomReal(50, 60)))
    endif
    call EXEffectMatRotateY(tx , - 10 * I2R(GetRandomInt(0, 8)))
    call EXEffectMatRotateZ(tx , 15 * I2R(GetRandomInt(0, 12))) //角度
    call EXSetEffectSize(tx , sz) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.5, 2)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + sjss )) //高度
    call DestroyEffect(tx)
    endif
    if ModuloReal(time, 0.08) == 0.08 then
    set sjss=GetRandomReal(0, 300)
    set jd3=GetRandomReal(0, 360)
    set x3=( x2 + sjss * CosBJ(jd3) )
    set y3=( y2 + sjss * SinBJ(jd3) )
    endif
    if ModuloReal(time, 0.24) == 0.24 then
    set jd3=GetRandomReal(0, 360)
    set sjss=GetRandomInt(0, 200)
    set x3=( x2 + sjss * CosBJ(jd3) )
    set y3=( y2 + sjss * SinBJ(jd3) )
    //风格化气浪特效
    set zfc="117448227.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateX(tx , - 20 * I2R(GetRandomInt(0, 18)))
    call EXEffectMatRotateZ(tx , jd + 4 * I2R(GetRandomInt(- 5, 5))) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.5)) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(4, 6)) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(50, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(20, 80)) + 0x10000 * PercentTo255(50) + 0x100 * PercentTo255(50) + PercentTo255(50))
    call DestroyEffect(tx)
    set jd3=jd - 60 + GetRandomInt(0, 120)
    set sjss=GetRandomInt(0, 200)
    set x3=( x2 + sjss * CosBJ(jd3) )
    set y3=( y2 + sjss * SinBJ(jd3) )
    //风格化气浪特效2
    set zfc="animewind.mdl"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 20 * I2R(GetRandomInt(0, 9)))
    call EXEffectMatRotateZ(tx , jd + 4 * I2R(GetRandomInt(- 5, 5))) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1.2, 1.7)) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(1.5, 2)) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(50, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(30, 80)) + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(100))
    call DestroyEffect(tx)
    set jd3=GetRandomReal(0, 360)
    set sjss=GetRandomInt(0, 200)
    set x3=( x2 + sjss * CosBJ(jd3) )
    set y3=( y2 + sjss * SinBJ(jd3) )
    //风格化气浪特效3
    set zfc="1577588603.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 2 * I2R(GetRandomInt(0, 9)))
    call EXEffectMatRotateZ(tx , jd + 4 * I2R(GetRandomInt(- 5, 5))) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1.2, 1.7)) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(3, 5)) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(0, 30) )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(30, 80)) + 0x10000 * PercentTo255(50) + 0x100 * PercentTo255(50) + PercentTo255(50))
    call DestroyEffect(tx)
    endif
    endif
    if time >= 3.9 and time <= 4.2 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    if time <= 4.1 then //旋转
    set jd3=jd - ( ( time - 3.88 ) * 50 * 18 )
    set sjss=700 - ( ( time - 3.88 ) * 500.00 )
    set x=( x2 + sjss * CosBJ(jd3) )
    set y=( y2 + sjss * SinBJ(jd3) )
    set jd3=jd - 90 - ( ( time - 3.88 ) * 50 * 9 )
    call SetUnitX(dw, x)
    call SetUnitY(dw, y)
    call SetUnitFacingTimed(dw, jd3, 0)
    call EXSetUnitFacing(dw , jd3)
    endif
    endif
    if time >= 4.2 then
    if ModuloReal(time, 0.1) == 0.1 then
    set sh=sh3
    endif
    if ModuloReal(time, 0.4) == 0.4 then
    //冷色气场特效3
    set zfc="-865519883.mdx"
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXEffectMatRotateY(tx , - 90)
    call EXSetEffectSize(tx , 8 + ( time - 4 )) //大小
    call EXSetEffectSpeed(tx , 0.5) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 1200.00 )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(70, 88)) + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(GetRandomReal(80, 100)) + PercentTo255(GetRandomReal(60, 80)))
    call DestroyEffect(tx)
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXEffectMatRotateY(tx , - 90)
    call EXSetEffectSize(tx , 6 + ( time - 4.2 )) //大小
    call EXSetEffectSpeed(tx , 0.65) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 800.00 )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(70, 88)) + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(GetRandomReal(80, 100)) + PercentTo255(GetRandomReal(60, 80)))
    call DestroyEffect(tx)
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXEffectMatRotateY(tx , - 90)
    call EXSetEffectSize(tx , 4 + ( time - 4.2 )) //大小
    call EXSetEffectSpeed(tx , 0.8) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 400.00 )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(70, 88)) + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(GetRandomReal(80, 100)) + PercentTo255(GetRandomReal(60, 80)))
    call DestroyEffect(tx)
    endif
    endif
    if ModuloReal(time, 0.1) == 0.1 and sh != 0 then
    set ydl_group=CreateGroup() //造成伤害dwz
    call GroupEnumUnitsInRange(ydl_group, x2, y2, 1000.00, null)
    loop
    set ydl_unit=FirstOfGroup(ydl_group)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(ydl_group, ydl_unit)
    if ( ( IsUnitType(ydl_unit, UNIT_TYPE_DEAD) == false ) and ( IsUnitEnemy(ydl_unit, wj) == true ) ) then
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 1 ) and ( IsUnitEnemy(ydl_unit, wj) == true ) ) then // INLINED!!
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 4 ) ) then // INLINED!!
    call mh_zzfycfxt1(ydl_unit , null , 0)
    endif
    endif
    if GetUnitPointValue(ydl_unit) != 233 and time <= 3.8 then //前半段斩击牵引
    set x4=GetUnitX(ydl_unit)
    set y4=GetUnitY(ydl_unit)
    set sjss=GetRandomReal(80, 100)
    set sz=SquareRoot(( Pow(( x4 - x2 ), 2.00) + Pow(( y4 - y2 ), 2.00) ))
    set sjss=sjss * ( 1.00 + ( sz / 1000.00 ) )
    if ( ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 15, 15)) == 0) == false ) ) then // INLINED!!
    set sjss=sjss * 0.05
    endif
    set jd3=Atan2BJ(( y2 - y4 ), ( x2 - x4 ))
    set x4=( x4 + sjss * CosBJ(jd3) )
    set y4=( y4 + sjss * SinBJ(jd3) )
    call SetUnitX(ydl_unit, x4)
    call SetUnitY(ydl_unit, y4)
    endif
    //查询防御状态和是否拥有无法选取 以及通用的选取条件  不判断重复
    if ( ( GetUnitPointValue(ydl_unit) != 233 ) and ( mh_tjfz6(ydl_unit , 0) == true ) and ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 4 ) and ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 3, 3)) == 0) == true ) ) then // INLINED!!
    //英雄攻击类型 强化伤害类型
    call mh_sh1(dw , ydl_unit , sh , 4 , 0 , true , false , ATTACK_TYPE_HERO , DAMAGE_TYPE_ENHANCED , WEAPON_TYPE_WHOKNOWS)
    call IssueTargetOrder(mj3, "thunderbolt", ydl_unit)
    if IsUnitType(ydl_unit, UNIT_TYPE_HERO) == true and ModuloReal(time, 0.3) == 0.3 and time <= 3.8 then
    set tx2=AddSpecialEffect("908196484.mdx", GetUnitX(ydl_unit), GetUnitY(ydl_unit)) //受击刀光粒子特效
    call EXEffectMatRotateY(tx2 , - 10 * I2R(GetRandomInt(0, 18))) //角度
    call EXEffectMatRotateZ(tx2 , - 25 * I2R(GetRandomInt(1, 14))) //角度
    set sh=( GetRandomReal(0.6, 0.8) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.4 ) )
    call EXSetEffectSize(tx2 , sh) //大小
    call SetPariticle2Size(tx , sh) //内置api调大小
    call EXSetEffectSpeed(tx2 , GetRandomReal(1, 1.5)) //特效动画速度
    call EXSetEffectZ(tx2 , ( EXGetEffectZ(tx2) + ( GetUnitFlyHeight(ydl_unit) + GetRandomReal(40, 75) ) )) //高度
    call DestroyEffect(tx2)
    endif
    if IsUnitInGroup(ydl_unit, dwz) == false then
    call GroupAddUnit(dwz, ydl_unit)
    endif
    set udg_wndanwei_jndw[1]=dw
    set udg_wndanwei_jndw[2]=ydl_unit
    set udg_wnzhengshu__zs[1]=4
    set udg_wnzhengshu__zs[2]=50
    call TriggerExecute(gg_trg_J_Firefly____________000_fz)
    endif
    endif
    endloop
    call DestroyGroup(ydl_group)
    endif
    endif
    if time >= 6 then //代码结束
    call EXSetEffectSpeed(tstx[0] , 0.3) //动画速度
    call SetUnitTimeScale(dw, 1)
    call PauseUnit(dw, false)
    call RemoveUnit(mj3)
    call GroupClear(dwz)
    call DestroyGroup(dwz)
    set a=0
    loop
    if GetHandleId(tstx[a]) != 0 then
    call DestroyEffect(tstx[a])
    endif
    set a=a + 1
    exitwhen a >= 15
    endloop
    call FlushChildHashtable(hsb, jsqid)
    call DestroyTimer(GetExpiredTimer())
    endif
    endif
    set dw=null
    set mj3=null
    set wj=null
    set jsq2=null
    set tx=null
    set tx2=null
    set zfc=null
    set a=0
    loop
    set tstx[a]=null
    set a=a + 1
    exitwhen a >= 15
    endloop
    set dwz=null
    set ydl_group=null
    set ydl_unit=null
    endfunction
    function Trig_J_Firefly____________003Actions takes nothing returns nothing
    local timer jsq= CreateTimer()
    local integer jsqid= GetHandleId(jsq)
    local unit dw= udg_wndanwei_jndw[1]
    local player wj= GetOwningPlayer(dw)
    local real x= GetUnitX(dw)
    local real y= GetUnitY(dw)
    local real x2= udg_wnshishu_shishu[0]
    local real y2= udg_wnshishu_shishu[1]
    local real jd= Atan2BJ(( y2 - y ), ( x2 - x ))
    call IssueImmediateOrder(dw, "stop")
    call PauseUnit(dw, true)
    call SetUnitTimeScale(dw, 3)
    call SetUnitAnimationByIndex(dw, 2)
    //保存数据准备开始代码
    if GetRandomInt(1, 2) == 1 then
    call SaveSoundHandle(hsb, jsqid, StringHash("语音1"), gg_snd_mh_Firefly_R1_1)
    call SaveSoundHandle(hsb, jsqid, StringHash("语音2"), gg_snd_mh_Firefly_R1_2)
    else
    call SaveSoundHandle(hsb, jsqid, StringHash("语音1"), gg_snd_mh_Firefly_R2_1)
    call SaveSoundHandle(hsb, jsqid, StringHash("语音2"), gg_snd_mh_Firefly_R2_2)
    endif
    call SaveUnitHandle(hsb, jsqid, StringHash("dw"), dw)
    call SavePlayerHandle(hsb, jsqid, StringHash("wj"), wj)
    call SaveReal(hsb, jsqid, StringHash("x"), x)
    call SaveReal(hsb, jsqid, StringHash("y"), y)
    call SaveReal(hsb, jsqid, StringHash("x2"), x2)
    call SaveReal(hsb, jsqid, StringHash("y2"), y2)
    call SaveReal(hsb, jsqid, StringHash("jd"), jd)
    call SaveInteger(hsb, jsqid, StringHash("jnzs2"), 0)
    call SaveGroupHandle(hsb, jsqid, StringHash("dwz"), CreateGroup())
    call SaveStr(hsb, jsqid, StringHash("模型"), ( EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(dw)) + "].file") ))
    call SaveReal(hsb, jsqid, StringHash("模型大小"), S2R(( EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(dw)) + "].modelScale") )))
    call TimerStart(jsq, 0.02, TRUE, function Trig_J_Firefly____________003jn2) //开始执行
    set jsq=null
    set dw=null
    set wj=null
    endfunction
    //===========================================================================
    function InitTrig_J_Firefly____________003 takes nothing returns nothing
    set gg_trg_J_Firefly____________003=CreateTrigger()
    call TriggerAddAction(gg_trg_J_Firefly____________003, function Trig_J_Firefly____________003Actions)
    endfunction
    //TESH.scrollpos=123
    //TESH.alwaysfold=0

//===========================================================================
// Trigger: J-Firefly流萤变身004
//===========================================================================】
function Trig_J_Firefly____________004jn2 takes nothing returns nothing
    local timer jsq2
    local integer jsq2id
    local integer a= 0
    local integer jsqid= GetHandleId(GetExpiredTimer())
    local unit dw= LoadUnitHandle(hsb, jsqid, StringHash("dw"))
    local player wj= LoadPlayerHandle(hsb, jsqid, StringHash("wj"))
    local real x= LoadReal(hsb, jsqid, StringHash("x"))
    local real y= LoadReal(hsb, jsqid, StringHash("y"))
    local real x2= LoadReal(hsb, jsqid, StringHash("x2"))
    local real y2= LoadReal(hsb, jsqid, StringHash("y2"))
    local real jd= LoadReal(hsb, jsqid, StringHash("jd"))
    local string zfc
    local effect tx
    local effect tx2
    local real time= LoadReal(hsb, jsqid, StringHash("逝去时间"))
    local real time2= LoadReal(hsb, jsqid, StringHash("逝去时间2"))
    
    local group ydl_group
    local group dwz= LoadGroupHandle(hsb, jsqid, StringHash("dwz"))
    local unit ydl_unit
    local unit mj= LoadUnitHandle(hsb, jsqid, StringHash("mj"))
    local unit mj3= LoadUnitHandle(hsb, jsqid, StringHash("mj3"))
    local real jd2= LoadReal(hsb, jsqid, StringHash("jd2"))
    local real jd3= LoadReal(hsb, jsqid, StringHash("jd3"))
    local real sjss= 0
    local real sz= 0
    local integer pd= LoadInteger(hsb, jsqid, StringHash("判断"))
    local integer dz1= LoadInteger(hsb, jsqid, StringHash("开头动作1"))
    local integer dz2= LoadInteger(hsb, jsqid, StringHash("开头动作2"))
    local integer dz3= LoadInteger(hsb, jsqid, StringHash("开头动作3"))
    local integer dz4= LoadInteger(hsb, jsqid, StringHash("开头动作4"))
    local real sd= LoadReal(hsb, jsqid, StringHash("速度"))
    local real gd= LoadReal(hsb, jsqid, StringHash("高度"))
    local real gdsd= LoadReal(hsb, jsqid, StringHash("高度速度"))
    local real dzsd1= LoadReal(hsb, jsqid, StringHash("开头动作动画速度1"))
    local real dzsd2= LoadReal(hsb, jsqid, StringHash("开头动作动画速度2"))
    local real dzsd3= LoadReal(hsb, jsqid, StringHash("开头动作动画速度3"))
    local real dzsd4= LoadReal(hsb, jsqid, StringHash("开头动作动画速度4"))
    local real sh
    local real sh1= LoadReal(hsb, jsqid, StringHash("伤害"))
    local real sh2= LoadReal(hsb, jsqid, StringHash("伤害2"))
    local real sh3= LoadReal(hsb, jsqid, StringHash("伤害3"))
    local real mxdx= LoadReal(hsb, jsqid, StringHash("模型大小"))
    local string mx= LoadStr(hsb, jsqid, StringHash("模型"))
    local real x3= 0
    local real y3= 0
    local real x4= 0
    local real y4= 0
    local effect array tstx
    local unit array hxdw
    local real array dgjd
    set dgjd[1]=- 75
    set dgjd[2]=- 80
    set dgjd[3]=- 85
    set dgjd[4]=- 70
    set a=0
    loop
    exitwhen a > 10
    set tstx[a]=LoadEffectHandle(hsb, jsqid, StringHash("特效" + I2S(a)))
    set a=a + 1
    endloop
    if mh_stpd2(dw) == 0 then //判断该单位是否处于时停
    set time=time + 0.02
    call SaveReal(hsb, jsqid, StringHash("逝去时间"), time)
    if time == 0.02 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set mj3=CreateUnit(wj, 'e002', x, y, 0) //全能技能马甲zhan
    call UnitAddAbility(mj3, 'A00J') //眩晕1s
    call SaveUnitHandle(hsb, jsqid, StringHash("mj3"), mj3)
    call UnitAddAbility(dw, 'Amrf')
    call UnitRemoveAbility(dw, 'Amrf')
    call SetUnitFlyHeight(dw, 0.00, 0.00)
    call SetUnitAnimationByIndex(dw, dz1)
    call SetUnitTimeScale(dw, dzsd1)
    call SaveInteger(YDHT, GetHandleId(dw), 0xE2C1E539, 1)
    call PlaySoundOnUnitBJ(LoadSoundHandle(hsb, jsqid, StringHash("语音" + I2S(1))), 100, dw) //语音
    set sh1=( 100 + ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, dw, true)) * 2 ) )
    set sh2=( 100.00 + ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, dw, true)) * 4 ) )
    set sh3=( 100.00 + ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, dw, true)) * 1 ) )
    set sjss=1
    if ( ( GetUnitAbilityLevel(dw, 'A0TK') >= 1 ) ) then
    set sjss=sjss + 0.1
    endif
    set sh1=sh1 * sjss
    set sh2=sh2 * sjss
    set sh3=sh3 * sjss
    call SaveReal(hsb, jsqid, StringHash("伤害"), sh1)
    call SaveReal(hsb, jsqid, StringHash("伤害2"), sh2)
    call SaveReal(hsb, jsqid, StringHash("伤害3"), sh3)
    call PlaySoundOnUnitBJ(LoadSoundHandle(hsb, jsqid, StringHash("语音" + I2S(0))), 100, dw) //语音
    
    //青色圣歌特效
    set zfc="[tx][z]zhuanzhi1.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSpeed(tx , 1.5) //动画速度
    call EXSetEffectSize(tx , 3) //大小
    call SetPariticle2Size(tx , 0.01) //内置api调大小
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(80))
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) - 150 )) //高度
    call DestroyEffect(tx)
    //青色圣歌特效3
    set zfc="-318710672.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSpeed(tx , 1.25) //动画速度
    call EXSetEffectSize(tx , 1.8) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) - 150 )) //高度
    call DestroyEffect(tx)
    //青色圣歌特效2
    set zfc="[tx][jn]daosuizhiliao_GreenCary.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 5) //大小
    call SetPariticle2Size(tx , 1.5) //内置api调大小
    call EXSetEffectSpeed(tx , 1.5) //动画速度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(100) + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(0) + PercentTo255(0))
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) - 100 )) //高度
    call DestroyEffect(tx)
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 5) //大小
    call SetPariticle2Size(tx , 2) //内置api调大小
    call EXSetEffectSpeed(tx , 1.5) //动画速度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(100) + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(0) + PercentTo255(0))
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) - 100 )) //高度
    call DestroyEffect(tx)
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 8) //大小
    call SetPariticle2Size(tx , 1) //内置api调大小
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(100) + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(0) + PercentTo255(0))
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) - 150 )) //高度
    call DestroyEffect(tx)
    //青色圣歌特效
    set zfc="-950557588.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSpeed(tx , 2) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 200 )) //高度
    call DestroyEffect(tx)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 20)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.1, false, function mh__jtzdhs1)
    if ( ( GetPlayerTechCountSimple('R00V', wj) >= 1 ) ) then
    call mh_buffkq(dw , 0.5 , 16 , 1) //大招无敌帧
    endif
    endif
    if time >= 0.1 and time <= 0.4 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set sz=( 0.00 + RMaxBJ(( 200 - ( ( time - 0.1 ) * 200.00 ) ), 1.00) )
    set gd=gd + sz
    call SaveReal(hsb, jsqid, StringHash("高度"), gd)
    call SetUnitFlyHeight(dw, gd, ( sz / 0.02 ))
    endif
    if time == 0.3 then
    call mh_tm1(dw , 0.1 , 0.02 , 0 , 100 , 5)
    endif
    if time == 0.40 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call IssueImmediateOrder(mj, "stop")
    call SaveReal(YDHT, GetHandleId(wj), 0xCE7FD5C5, ( LoadReal(YDHT, GetHandleId(wj), 0xCE7FD5C5) + 2000.00 ))
    //乌鸦坐飞机
    set zfc="-1086393348.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , 270) //角度
    call EXSetEffectSize(tx , 1.5) //大小
    call SetPariticle2Size(tx , 1.5) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 5 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(0)), tx)
    endif
    if time == 0.5 then
    call EXSetEffectSpeed(tstx[0] , 0.5) //动画速度
    endif
    if time == time2 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set x2=GetUnitX(dw)
    set y2=GetUnitY(dw)
    call EXSetEffectSpeed(tstx[0] , 1) //动画速度
    call DestroyEffect(tstx[0])
    call SaveReal(hsb, jsqid, StringHash("x2"), x2)
    call SaveReal(hsb, jsqid, StringHash("y2"), y2)
    set jd3=GetRandomReal(0, 360)
    set sjss=GetRandomReal(300, 400)
    set x=( x + sjss * CosBJ(jd3) )
    set y=( y + sjss * SinBJ(jd3) )
    call SetUnitX(dw, x)
    call SetUnitY(dw, y)
    set jd=Atan2BJ(( y2 - y ), ( x2 - x ))
    call SaveReal(hsb, jsqid, StringHash("jd"), jd)
    call SetUnitFacingTimed(dw, jd, 0)
    call EXSetUnitFacing(dw , jd)
    set sd=SquareRoot(( Pow(( x - x2 ), 2.00) + Pow(( y - y2 ), 2.00) )) / 5
    set gdsd=( GetUnitFlyHeight(dw) ) / 5
    call SaveReal(hsb, jsqid, StringHash("速度"), sd)
    call SaveReal(hsb, jsqid, StringHash("高度速度"), gdsd)
    set udg_wndanwei_jndw[1]=dw
    set udg_wnzhengshu__zs[1]=1
    call TriggerExecute(gg_trg_J_Firefly____________000_fz)
    call IssueTargetOrder(mj, "magicleash", dw)
    call IssueImmediateOrder(dw, "stop")
    call SetUnitAnimationByIndex(dw, dz2)
    call SetUnitTimeScale(dw, dzsd2)
    call YDWESetUnitAbilityState(dw , 'A0SU' , 1 , 50.00)
    call SaveReal(YDHT, GetHandleId(wj), 0xCE7FD5C5, ( LoadReal(YDHT, GetHandleId(wj), 0xCE7FD5C5) - 2000.00 ))
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 10)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.08, false, function mh__jtzdhs1)
    endif
    if time == time2 + 0.02 then
    call dsound("mh_Firefly_jn2.mp3" , dw)
    //冲天火柱特效
    set zfc="1671355440.mdx"
    set tx=AddSpecialEffect(zfc, x2, y2)
    call EXEffectMatRotateY(tx , - 15) //角度
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 1.75) //大小
    call EXSetEffectSpeed(tx , 1.6) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) - 300 )) //高度
    call DestroyEffect(tx)
    endif
    if time >= 0.4 and time <= time2 + 0.16 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call mh_buffkq(dw , 0.04 , 16 , 1) //大招无敌帧
    
    if ( time <= time2 and LoadInteger(YDHT, GetHandleId(dw), 0xE2C1E539) == 2 ) or time == time2 - 0.02 then
    set time=time2 - 0.02
    call SaveReal(hsb, jsqid, StringHash("逝去时间"), time)
    call SetUnitAnimationByIndex(dw, dz2)
    set sz=RMaxBJ(( ( time - time2 + 1.5 ) ) / 0.04 + 0.5, 0)
    call SetUnitTimeScale(dw, sz)
    call SaveInteger(YDHT, GetHandleId(dw), 0xE2C1E539, 0)
    endif
    if time <= time2 - 0.02 then
    call EXSetEffectXY(tstx[0] , x , y)
    call SaveReal(YDHT, GetHandleId(dw), 0x94EB8839, ( LoadReal(YDHT, GetHandleId(dw), 0x94EB8839) + 0.03 ))
    endif
    if time >= time2 and time <= time2 + 0.1 then
    set sjss=sd
    set jd3=jd
    set x=( x + sjss * CosBJ(jd3) )
    set y=( y + sjss * SinBJ(jd3) )
    call SetUnitX(dw, x)
    call SetUnitY(dw, y)
    set sz=gdsd
    set gd=gd - sz
    call SaveReal(hsb, jsqid, StringHash("高度"), gd)
    call SetUnitFlyHeight(dw, gd, ( sz / 0.02 ))
    endif
    if time >= time2 + 0.14 then
    set ydl_group=CreateGroup() //造成伤害dwz
    call GroupEnumUnitsInRange(ydl_group, x2, y2, 750.00, null)
    loop
    set ydl_unit=FirstOfGroup(ydl_group)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(ydl_group, ydl_unit)
    if ( ( IsUnitType(ydl_unit, UNIT_TYPE_DEAD) == false ) and ( IsUnitEnemy(ydl_unit, wj) == true ) ) then
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 1 ) and ( IsUnitEnemy(ydl_unit, wj) == true ) ) then // INLINED!!
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 4 ) ) then // INLINED!!
    call mh_zzfycfxt1(ydl_unit , null , 0)
    endif
    endif
    //查询防御状态和是否拥有无法选取 以及通用的选取条件  不判断重复
    if ( ( GetUnitPointValue(ydl_unit) != 233 ) and ( mh_tjfz6(ydl_unit , 0) == true ) and ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 4 ) and ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 3, 3)) == 0) == true ) ) then // INLINED!!
    //英雄攻击类型 强化伤害类型
    call mh_sh1(dw , ydl_unit , sh2 , 4 , 0 , true , false , ATTACK_TYPE_HERO , DAMAGE_TYPE_ENHANCED , WEAPON_TYPE_WHOKNOWS)
    call IssueTargetOrder(mj3, "thunderbolt", ydl_unit)
    set udg_wndanwei_jndw[1]=dw
    set udg_wndanwei_jndw[2]=ydl_unit
    set udg_wnzhengshu__zs[1]=4
    set udg_wnzhengshu__zs[2]=30
    call TriggerExecute(gg_trg_J_Firefly____________000_fz)
    endif
    endif
    endloop
    call DestroyGroup(ydl_group)
    endif
    endif
    if time == time2 + 0.1 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call SetUnitTimeScale(dw, 1)
    call StopSoundBJ(gg_snd_mh_Firefly_jn1, false)
    //冲天火柱特效
    set zfc="1671355440.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 2) //大小
    call SetPariticle2Size(tx , 2) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 2 )) //高度
    call DestroyEffect(tx)
    //火气息特效
    set zfc="fire-boom-new.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 2.5) //大小
    call SetPariticle2Size(tx , 2.5) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) - 150 )) //高度
    call DestroyEffect(tx)
    //火气息特效2
    set zfc="chun-yanji-16.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 4) //大小
    call SetPariticle2Size(tx , 2) //内置api调大小
    call DestroyEffect(tx)
    //地面裂痕特效
    set zfc="t7_by_wood_effect_order_dange_daoguang_baozha_1_2.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(0) + PercentTo255(0))
    call EXSetEffectSize(tx , 2.5) //大小
    call EXSetEffectSpeed(tx , 0.3) //动画速度
    call SetPariticle2Size(tx , 0.01) //内置api调大小
    call DestroyEffect(tx)
    //地面气息特效
    set zfc="WindCirclefaster.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(30) + 0x100 * PercentTo255(10) + PercentTo255(0))
    call EXSetEffectSize(tx , 2.5) //大小
    call EXSetEffectSpeed(tx , 0.75) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) - 100.00 )) //高度
    call DestroyEffect(tx)
    //气场特效1
    set zfc="117448227.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXEffectMatScale(tx , 8.00 , 8.00 , 4.00)
    call EXSetEffectSpeed(tx , 0.8) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 10.00 )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(40) + 0x10000 * PercentTo255(80) + 0x100 * PercentTo255(80) + PercentTo255(80))
    call DestroyEffect(tx)
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXEffectMatScale(tx , 4.00 , 4.00 , 4.00)
    call EXSetEffectSpeed(tx , 0.5) //动画速度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(60) + 0x10000 * PercentTo255(80) + 0x100 * PercentTo255(80) + PercentTo255(80))
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(0)), tx)
    call DestroyEffect(tx)
    set ydl_group=CreateGroup() //造成伤害dwz
    call GroupEnumUnitsInRange(ydl_group, x, y, 750.00, null)
    loop
    set ydl_unit=FirstOfGroup(ydl_group)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(ydl_group, ydl_unit)
    if ( ( IsUnitType(ydl_unit, UNIT_TYPE_DEAD) == false ) and ( IsUnitEnemy(ydl_unit, wj) == true ) ) then
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 1 ) and ( IsUnitEnemy(ydl_unit, wj) == true ) ) then // INLINED!!
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 4 ) ) then // INLINED!!
    call mh_zzfycfxt1(ydl_unit , null , 0)
    endif
    endif
    //查询防御状态和是否拥有无法选取 以及通用的选取条件  不判断重复
    if ( ( GetUnitPointValue(ydl_unit) != 233 ) and ( mh_tjfz6(ydl_unit , 0) == true ) and ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 4 ) and ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 3, 3)) == 0) == true ) ) then // INLINED!!
    //英雄攻击类型 强化伤害类型
    call mh_sh1(dw , ydl_unit , sh1 , 4 , 0 , true , false , ATTACK_TYPE_HERO , DAMAGE_TYPE_ENHANCED , WEAPON_TYPE_WHOKNOWS)
    call IssueTargetOrder(mj3, "thunderbolt", ydl_unit)
    if IsUnitType(ydl_unit, UNIT_TYPE_HERO) == true then
    set tx2=AddSpecialEffect("1058689001.mdx", GetUnitX(ydl_unit), GetUnitY(ydl_unit)) //受击刀光粒子特效
    call EXEffectMatRotateY(tx2 , - 10 * I2R(GetRandomInt(0, 18))) //角度
    call EXEffectMatRotateZ(tx2 , - 25 * I2R(GetRandomInt(1, 14))) //角度
    set sh=( GetRandomReal(0.6, 0.8) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.4 ) )
    call EXSetEffectSize(tx2 , sh) //大小
    call SetPariticle2Size(tx , sh) //内置api调大小
    call EXSetEffectSpeed(tx2 , GetRandomReal(1, 1.5)) //特效动画速度
    call EXSetEffectZ(tx2 , ( EXGetEffectZ(tx2) + ( GetUnitFlyHeight(ydl_unit) + GetRandomReal(40, 75) ) )) //高度
    call DestroyEffect(tx2)
    endif
    set udg_wndanwei_jndw[1]=dw
    set udg_wndanwei_jndw[2]=ydl_unit
    set udg_wnzhengshu__zs[1]=4
    set udg_wnzhengshu__zs[2]=200
    call TriggerExecute(gg_trg_J_Firefly____________000_fz)
    endif
    endif
    endloop
    call DestroyGroup(ydl_group)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 30)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.2, false, function mh__jtzdhs1)
    endif
    if time == time2 + 0.16 then //代码结束
    call SetUnitTimeScale(dw, 1)
    call DestroyEffect(tstx[0])
    call RemoveUnit(mj)
    call RemoveUnit(mj3)
    call GroupClear(dwz)
    call DestroyGroup(dwz)
    call FlushChildHashtable(hsb, jsqid)
    call DestroyTimer(GetExpiredTimer())
    endif
    endif
    set dw=null
    set mj=null
    set mj3=null
    set wj=null
    set jsq2=null
    set tx=null
    set tx2=null
    set zfc=null
    set mx=null
    set hxdw[1]=null
    set tstx[0]=null
    set dwz=null
    set ydl_group=null
    endfunction
    function Trig_J_Firefly____________004Actions takes nothing returns nothing
    local timer jsq= CreateTimer()
    local integer jsqid= GetHandleId(jsq)
    local unit dw= udg_wndanwei_jndw[1]
    local unit mj
    local player wj= GetOwningPlayer(dw)
    local real x= GetUnitX(dw)
    local real y= GetUnitY(dw)
    local real x2= udg_wnshishu_shishu[0]
    local real y2= udg_wnshishu_shishu[1]
    local real jd= Atan2BJ(( y2 - y ), ( x2 - x ))
    local integer array dz
    local real array dzsd
    set mj=CreateUnit(wj, 'e002', x, y, 0) //施法控制马甲
    call UnitAddAbility(mj, 'A00F') //技能释放中
    call IssueTargetOrder(mj, "magicleash", dw)
    call SaveUnitHandle(hsb, jsqid, StringHash("mj"), mj)
    call IssueImmediateOrder(dw, "stop")
    call IssueImmediateOrder(dw, "stop")
    if ( GetUnitTypeId(dw) == 'O001' ) then
    set dz[1]=4
    set dzsd[1]=3
    set dz[2]=3
    set dzsd[2]=3
    endif
    if GetRandomReal(1, 2) == 1 then
    call SaveSoundHandle(hsb, jsqid, StringHash("语音1"), gg_snd_mh_Firefly_Stand1)
    else
    call SaveSoundHandle(hsb, jsqid, StringHash("语音1"), gg_snd_mh_Firefly_ready3)
    endif
    //保存数据准备开始代码
    call SaveUnitHandle(hsb, jsqid, StringHash("dw"), dw)
    call SavePlayerHandle(hsb, jsqid, StringHash("wj"), wj)
    call SaveReal(hsb, jsqid, StringHash("x"), x)
    call SaveReal(hsb, jsqid, StringHash("y"), y)
    call SaveReal(hsb, jsqid, StringHash("x2"), x2)
    call SaveReal(hsb, jsqid, StringHash("y2"), y2)
    call SaveReal(hsb, jsqid, StringHash("jd"), jd)
    call SaveReal(hsb, jsqid, StringHash("逝去时间2"), 5)
    call SaveSoundHandle(hsb, jsqid, StringHash("语音0"), gg_snd_mh_Firefly_jn1)
    call SaveInteger(hsb, jsqid, StringHash("开头动作1"), dz[1])
    call SaveInteger(hsb, jsqid, StringHash("开头动作2"), dz[2])
    call SaveInteger(hsb, jsqid, StringHash("开头动作3"), dz[3])
    call SaveInteger(hsb, jsqid, StringHash("开头动作4"), dz[4])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度1"), dzsd[1])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度2"), dzsd[2])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度3"), dzsd[3])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度4"), dzsd[4])
    call SaveGroupHandle(hsb, jsqid, StringHash("dwz"), CreateGroup())
    call SaveStr(hsb, jsqid, StringHash("模型"), ( EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(dw)) + "].file") ))
    call SaveStr(hsb, jsqid, StringHash("模型2"), "[Hero]\\Sam.mdl")
    call SaveReal(hsb, jsqid, StringHash("模型大小"), S2R(( EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(dw)) + "].modelScale") )))
    call TimerStart(jsq, 0.02, TRUE, function Trig_J_Firefly____________004jn2) //开始执行
    set jsq=null
    set dw=null
    set mj=null
    set wj=null
    endfunction
    //===========================================================================
    function InitTrig_J_Firefly____________004 takes nothing returns nothing
    set gg_trg_J_Firefly____________004=CreateTrigger()
    call TriggerAddAction(gg_trg_J_Firefly____________004, function Trig_J_Firefly____________004Actions)
    endfunction
    //TESH.scrollpos=371
    //TESH.alwaysfold=0

//===========================================================================
// Trigger: J-Firefly流萤燃烧005
//===========================================================================
function Trig_J_Firefly____________005jn2 takes nothing returns nothing
    local timer jsq2
    local integer jsq2id
    local integer a= 0
    local integer jsqid= GetHandleId(GetExpiredTimer())
    local unit dw= LoadUnitHandle(hsb, jsqid, StringHash("dw"))
    local player wj= LoadPlayerHandle(hsb, jsqid, StringHash("wj"))
    local real x= LoadReal(hsb, jsqid, StringHash("x"))
    local real y= LoadReal(hsb, jsqid, StringHash("y"))
    local real x2= LoadReal(hsb, jsqid, StringHash("x2"))
    local real y2= LoadReal(hsb, jsqid, StringHash("y2"))
    local real jd= LoadReal(hsb, jsqid, StringHash("jd"))
    local string zfc
    local effect tx
    local effect tx2
    local real time= LoadReal(hsb, jsqid, StringHash("逝去时间"))
    local integer timezs= LoadInteger(hsb, jsqid, StringHash("逝去时间zs"))
    
    local real jd3= LoadReal(hsb, jsqid, StringHash("jd3"))
    local real sjss= 0
    local integer sjzs= 0
    local real sz= 0
    local real x3= 0
    local real y3= 0
    local real x4= 0
    local real y4= 0
    local real sd= LoadReal(hsb, jsqid, StringHash("速度"))
    local real gd= LoadReal(hsb, jsqid, StringHash("高度"))
    local real gdsd= LoadReal(hsb, jsqid, StringHash("高度速度"))
    local effect array tstx
    set a=0
    loop
    set tstx[a]=LoadEffectHandle(hsb, jsqid, StringHash("特效" + I2S(a)))
    set a=a + 1
    exitwhen a >= 2
    endloop
    if ( ( ( mh_stpd2(dw) == 0 ) ) ) then //判断该单位是否处于时停
    set time=time + 0.02
    call SaveReal(hsb, jsqid, StringHash("逝去时间"), time)
    if time == 0.02 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call UnitAddAbility(dw, 'Amrf')
    call UnitRemoveAbility(dw, 'Amrf')
    call SetUnitFlyHeight(dw, 0.00, 0.00)
    call SetUnitAnimationByIndex(dw, 4)
    call SetUnitTimeScale(dw, 1)
    call PlaySoundOnUnitBJ(LoadSoundHandle(hsb, jsqid, StringHash("语音" + I2S(1))), 100, dw) //语音
    call dsound("mh_Firefly_form1_R2.mp3" , dw)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 10.00)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.1, false, function mh__jtzdhs1)
    call SetCameraFieldForPlayer(wj, CAMERA_FIELD_TARGET_DISTANCE, ( 3400.00 + 1000.00 ), 1.00) //玩家镜头
    endif
    if time == 0.02 or time == 0.5 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    //气息特效
    set zfc="e_poisonbomb_qichang.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 2) //大小
    call DestroyEffect(tx)
    //风格化气浪特效
    set zfc="117448227.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , GetRandomReal(0, 360)) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.5)) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(3, 4)) //大小
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(20, 40)) + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(100))
    call DestroyEffect(tx)
    endif
    if time == 1 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    //气息特效
    set zfc="-950557588.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 4) //大小
    call SetPariticle2Size(tx , 4) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 200.00 )) //高度
    call DestroyEffect(tx)
    endif
    if time == 1.2 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set udg_wndanwei_jndw[1]=dw
    set udg_wnzhengshu__zs[1]=2
    call TriggerExecute(gg_trg_J_Firefly____________000_fz)
    call IssueImmediateOrder(dw, "stop")
    call SetUnitAnimationByIndex(dw, 12)
    call SetUnitTimeScale(dw, 1)
    //气息特效
    set zfc="869602743.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 2) //大小
    call SetPariticle2Size(tx , 2) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 5.00 )) //高度
    call DestroyEffect(tx)
    //气息特效2
    set zfc="-1307095562.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 1.5) //大小
    call SetPariticle2Size(tx , 1.5) //内置api调大小
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.2)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 200.00 )) //高度
    call DestroyEffect(tx)
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateX(tx , - 90) //角度
    call EXEffectMatRotateZ(tx , 45) //角度
    call EXSetEffectSize(tx , GetRandomReal(1.2, 1.5)) //大小
    call SetPariticle2Size(tx , GetRandomReal(1.2, 1.5)) //内置api调大小
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.2)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 150.00 )) //高度
    call DestroyEffect(tx)
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateX(tx , - 90) //角度
    call EXEffectMatRotateZ(tx , 315) //角度
    call EXSetEffectSize(tx , GetRandomReal(1.2, 1.5)) //大小
    call SetPariticle2Size(tx , GetRandomReal(1.2, 1.5)) //内置api调大小
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.2)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 150.00 )) //高度
    call DestroyEffect(tx)
    //风格化气浪特效
    set zfc="117448227.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , GetRandomReal(0, 360)) //角度
    call EXSetEffectSpeed(tx , 1.25) //动画速度
    call EXSetEffectSize(tx , 4) //大小
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(30, 40)) + 0x10000 * PercentTo255(50) + 0x100 * PercentTo255(50) + PercentTo255(50))
    call DestroyEffect(tx)
    //青色圣歌特效
    set zfc="[tx][z]zhuanzhi1.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSpeed(tx , 1.5) //动画速度
    call EXSetEffectSize(tx , 3) //大小
    call SetPariticle2Size(tx , 0.01) //内置api调大小
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(80))
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) - 150 )) //高度
    call DestroyEffect(tx)
    endif
    if time == 2.1 then
    call SetUnitAnimationByIndex(dw, 3)
    call SetUnitTimeScale(dw, 0.56)
    endif
    if time == 4.6 then
    call SetUnitTimeScale(dw, 1)
    endif
    if time >= 2.1 and time <= 5 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    if time <= 4.6 then //前期飞行
    set sjss=RMaxBJ(( 40 - ( ( time - 3.5 ) * 200.00 ) ), 2.00)
    set sz=RMaxBJ(( 30 - ( ( time - 3.5 ) * 100.00 ) ), 1.00)
    set jd3=jd - 180
    if time <= 3.5 then
    set jd3=jd - 60 - ( ( time - 2.1 ) * 50 * 2.91 )
    set sjss=RMinBJ(( 0 + ( ( ( time - 2.1 ) ) * 150.00 ) ), 50.00)
    set sz=RMinBJ(( 0 + ( ( ( time - 2.1 ) ) * 50.00 ) ), 30.00)
    endif
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    if mh_jcdwxy(x3 , y3) == true then
    call SetUnitX(dw, x3)
    call SetUnitY(dw, y3)
    endif
    set gd=gd + sz
    call SaveReal(hsb, jsqid, StringHash("高度"), gd)
    call SetUnitFlyHeight(dw, gd, ( sz / 0.02 ))
    if ModuloReal(time, 0.24) == 0.24 then
    set jd3=GetRandomReal(0, 360)
    set sjss=GetRandomInt(0, 100)
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    if GetRandomInt(1, 3) == 1 then
    //风格化气浪特效
    set zfc="117448227.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateX(tx , - 20 * I2R(GetRandomInt(0, 18)))
    call EXEffectMatRotateZ(tx , GetRandomReal(0, 360)) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.5)) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(4, 6)) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + gd + GetRandomReal(50, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(70, 90)) + 0x10000 * PercentTo255(50) + 0x100 * PercentTo255(50) + PercentTo255(50))
    call DestroyEffect(tx)
    elseif GetRandomInt(1, 3) == 1 then
    //风格化气浪特效2
    set zfc="animewind.mdl"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 20 * I2R(GetRandomInt(0, 9)))
    call EXEffectMatRotateZ(tx , GetRandomReal(0, 360)) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1.2, 1.7)) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(1.5, 2)) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + gd + GetRandomReal(50, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(70, 90)) + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(100))
    call DestroyEffect(tx)
    else
    //风格化气浪特效3
    set zfc="1577588603.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 2 * I2R(GetRandomInt(0, 9)))
    call EXEffectMatRotateZ(tx , GetRandomReal(0, 360)) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1.2, 1.7)) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(3, 5)) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + gd + GetRandomReal(50, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(70, 90)) + 0x10000 * PercentTo255(50) + 0x100 * PercentTo255(50) + PercentTo255(50))
    call DestroyEffect(tx)
    endif
    endif
    endif
    endif
    if time == 5 then //准备爆发
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call SetUnitAnimationByIndex(dw, 12)
    call SetUnitTimeScale(dw, 2.5)
    //爆点特效
    set zfc="908196484.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 5) //大小
    call SetPariticle2Size(tx , 4) //内置api调大小
    call EXSetEffectSpeed(tx , 1.5) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 100.00 )) //高度
    call DestroyEffect(tx)
    endif
    if time == 5.1 then //光翼展开
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call SetUnitTimeScale(dw, 1)
    call YDWETimerDestroyEffect(20.00 , AddSpecialEffectTarget("-1481767919.mdx", dw, "origin"))
    //爆点特效3
    set zfc="-1307095562.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 5) //大小
    call SetPariticle2Size(tx , 5) //内置api调大小
    call EXSetEffectSpeed(tx , 1.5) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 100.00 )) //高度
    call DestroyEffect(tx)
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 6) //大小
    call SetPariticle2Size(tx , 3) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 100.00 )) //高度
    call DestroyEffect(tx)
    //爆点特效2
    set zfc="1180814843.mdx"
    set tstx[1]=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tstx[1] , jd) //角度
    call EXSetEffectSize(tstx[1] , 2) //大小
    call SetPariticle2Size(tstx[1] , 2) //内置api调大小
    call EXSetEffectSpeed(tstx[1] , 1.25) //动画速度
    call EXSetEffectZ(tstx[1] , ( EXGetEffectZ(tstx[1]) + GetUnitFlyHeight(dw) + 100.00 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(1)), tstx[1])
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 30.00)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.3, false, function mh__jtzdhs1)
    endif
    if time == 5.9 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call SetUnitTimeScale(dw, 1)
    //气息特效
    set zfc="-950557588.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 3) //大小
    call SetPariticle2Size(tx , 3) //内置api调大小
    call EXSetEffectSpeed(tx , 1.8) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 100.00 )) //高度
    call DestroyEffect(tx)
    call mh_tm1(dw , 0.08 , 0.02 , 0 , 100 , 5)
    endif
    if time >= 6 then //代码结束
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    //气息特效
    set zfc="-950557588.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 3) //大小
    call SetPariticle2Size(tx , 3) //内置api调大小
    call EXSetEffectSpeed(tx , 1.8) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 100.00 )) //高度
    call DestroyEffect(tx)
    //气息特效
    set zfc="869602743.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 2) //大小
    call SetPariticle2Size(tx , 2) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 5.00 )) //高度
    call DestroyEffect(tx)
    call SetUnitFlyHeight(dw, 0.00, 0.00)
    call mh_tm1(dw , 0.2 , 0.02 , 0 , 100 , 6)
    call SetUnitTimeScale(dw, 1)
    call PauseUnit(dw, false)
    set a=0
    loop
    if GetHandleId(tstx[a]) != 0 then
    call DestroyEffect(tstx[a])
    endif
    set a=a + 1
    exitwhen a >= 2
    endloop
    call FlushChildHashtable(hsb, jsqid)
    call DestroyTimer(GetExpiredTimer())
    endif
    endif
    set dw=null
    set wj=null
    set jsq2=null
    set tx=null
    set tx2=null
    set zfc=null
    set a=0
    loop
    set tstx[a]=null
    set a=a + 1
    exitwhen a >= 2
    endloop
    endfunction
    function Trig_J_Firefly____________005Actions takes nothing returns nothing
    local timer jsq= CreateTimer()
    local integer jsqid= GetHandleId(jsq)
    local unit dw= udg_wndanwei_jndw[1]
    local player wj= GetOwningPlayer(dw)
    local real x= GetUnitX(dw)
    local real y= GetUnitY(dw)
    local real x2
    local real y2
    local real jd
    local integer array dz
    local real array dzsd
    set jd=GetUnitFacing(dw)
    set x2=( x + 10 * CosBJ(jd) )
    set y2=( y + 10 * SinBJ(jd) )
    set jd=Atan2BJ(( y2 - y ), ( x2 - x ))
    call IssueImmediateOrder(dw, "stop")
    call PauseUnit(dw, true)
    if ( GetUnitTypeId(dw) == 'O001' ) then
    set dz[1]=3
    set dzsd[1]=1
    endif
    call SaveSoundHandle(hsb, jsqid, StringHash("语音1"), gg_snd_mh_Firefly_R0_2)
    //保存数据准备开始代码
    call SaveUnitHandle(hsb, jsqid, StringHash("dw"), dw)
    call SavePlayerHandle(hsb, jsqid, StringHash("wj"), wj)
    call SaveReal(hsb, jsqid, StringHash("x"), x)
    call SaveReal(hsb, jsqid, StringHash("y"), y)
    call SaveReal(hsb, jsqid, StringHash("x2"), x2)
    call SaveReal(hsb, jsqid, StringHash("y2"), y2)
    call SaveReal(hsb, jsqid, StringHash("jd"), jd)
    call SaveReal(hsb, jsqid, StringHash("逝去时间2"), 5)
    call SaveInteger(hsb, jsqid, StringHash("开头动作1"), dz[1])
    call SaveInteger(hsb, jsqid, StringHash("开头动作2"), dz[2])
    call SaveInteger(hsb, jsqid, StringHash("开头动作3"), dz[3])
    call SaveInteger(hsb, jsqid, StringHash("开头动作4"), dz[4])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度1"), dzsd[1])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度2"), dzsd[2])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度3"), dzsd[3])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度4"), dzsd[4])
    call SaveStr(hsb, jsqid, StringHash("模型"), ( EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(dw)) + "].file") ))
    call SaveStr(hsb, jsqid, StringHash("模型2"), "[Hero]\\SAM_firefly.mdl")
    call SaveReal(hsb, jsqid, StringHash("模型大小"), S2R(( EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(dw)) + "].modelScale") )))
    call TimerStart(jsq, 0.02, TRUE, function Trig_J_Firefly____________005jn2) //开始执行
    if ( ( GetPlayerTechCountSimple('R00V', wj) >= 1 ) ) then
    call mh_buffkq(dw , 6 , 6 , 1) //特殊无敌帧
    endif
    set jsq=null
    set dw=null
    set wj=null
    endfunction
    //===========================================================================
    function InitTrig_J_Firefly____________005 takes nothing returns nothing
    set gg_trg_J_Firefly____________005=CreateTrigger()
    call TriggerAddAction(gg_trg_J_Firefly____________005, function Trig_J_Firefly____________005Actions)
    endfunction
    //TESH.scrollpos=0
    //TESH.alwaysfold=0


    //===========================================================================
// Trigger: J-Firefly流萤蓄力006
//===========================================================================
function Trig_J_Firefly____________006jn2 takes nothing returns nothing
    local timer jsq2
    local integer jsq2id
    local integer a= 0
    local integer jsqid= GetHandleId(GetExpiredTimer())
    local unit dw= LoadUnitHandle(hsb, jsqid, StringHash("dw"))
    local player wj= LoadPlayerHandle(hsb, jsqid, StringHash("wj"))
    local real x= LoadReal(hsb, jsqid, StringHash("x"))
    local real y= LoadReal(hsb, jsqid, StringHash("y"))
    local real x2= LoadReal(hsb, jsqid, StringHash("x2"))
    local real y2= LoadReal(hsb, jsqid, StringHash("y2"))
    local real jd= LoadReal(hsb, jsqid, StringHash("jd"))
    local string zfc
    local effect tx
    local effect tx2
    local real time= LoadReal(hsb, jsqid, StringHash("逝去时间"))
    
    local group ydl_group
    local unit ydl_unit
    local unit mj= LoadUnitHandle(hsb, jsqid, StringHash("mj"))
    local real jd2= LoadReal(hsb, jsqid, StringHash("jd2"))
    local real jd3= LoadReal(hsb, jsqid, StringHash("jd3"))
    local real sd= LoadReal(hsb, jsqid, StringHash("速度"))
    local real gd= LoadReal(hsb, jsqid, StringHash("高度"))
    local real gdsd= LoadReal(hsb, jsqid, StringHash("高度速度"))
    local real sjss= 0
    local real sz= 0
    local integer pd= LoadInteger(hsb, jsqid, StringHash("判断"))
    local integer dz1= LoadInteger(hsb, jsqid, StringHash("开头动作1"))
    local integer dz2= LoadInteger(hsb, jsqid, StringHash("开头动作2"))
    local integer dz3= LoadInteger(hsb, jsqid, StringHash("开头动作3"))
    local integer dz4= LoadInteger(hsb, jsqid, StringHash("开头动作4"))
    local real dzsd1= LoadReal(hsb, jsqid, StringHash("开头动作动画速度1"))
    local real dzsd2= LoadReal(hsb, jsqid, StringHash("开头动作动画速度2"))
    local real dzsd3= LoadReal(hsb, jsqid, StringHash("开头动作动画速度3"))
    local real dzsd4= LoadReal(hsb, jsqid, StringHash("开头动作动画速度4"))
    local real sh1= LoadReal(hsb, jsqid, StringHash("伤害"))
    local real sh2= LoadReal(hsb, jsqid, StringHash("伤害2"))
    local real sh3= LoadReal(hsb, jsqid, StringHash("伤害3"))
    local real x3= 0
    local real y3= 0
    local real x4= 0
    local real y4= 0
    local integer jnzs= LoadInteger(hsb, jsqid, StringHash("jnzs"))
    local integer jnzs2= LoadInteger(hsb, jsqid, StringHash("jnzs2"))
    local effect array tstx
    set tstx[0]=LoadEffectHandle(hsb, jsqid, StringHash("特效" + I2S(0)))
    set tstx[1]=LoadEffectHandle(hsb, jsqid, StringHash("特效" + I2S(1)))
    if mh_stpd2(dw) == 0 then //判断该单位是否处于时停
    set time=time + 0.02
    call SaveReal(hsb, jsqid, StringHash("逝去时间"), time)
    if time == 0.02 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call SetUnitAnimationByIndex(dw, dz1)
    call SetUnitTimeScale(dw, dzsd1)
    call PlaySoundOnUnitBJ(LoadSoundHandle(hsb, jsqid, StringHash("语音" + I2S(1))), 100, dw) //语音
    call dsound("mh_yln_jn19.mp3" , dw)
    //气息特效
    set zfc="-1848283099.mdx"
    set tx=AddSpecialEffectTargetUnitBJ("origin", dw, zfc)
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(1)), tx)
    call YDWETimerDestroyEffect(2.50 , tx)
    if ( ( GetPlayerTechCountSimple('R000', wj) >= 1 ) ) then
    call mh_buffkq(dw , 2.5 , 2 , 1) //假无敌
    endif
    endif
    if time == 1 then
    //气息特效
    set zfc="-1481767919.mdx"
    set tx=AddSpecialEffectTargetUnitBJ("origin", dw, zfc)
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(0)), tx)
    endif
    if time == 2.5 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call IssueImmediateOrder(mj, "stop")
    call DestroyEffect(tstx[0])
    call SetUnitTimeScale(dw, 1)
    call dsound("m_skill22.wav" , dw)
    // //火焰爆炸特效1
    // set zfc = "fire-boom-new.mdl"
    // set tx = AddSpecialEffect(zfc, x, y)
    // call EXEffectMatRotateY(tx, -40) //角度
    // call EXEffectMatRotateZ(tx, jd) //角度
    // call EXSetEffectSpeed(tx, 3) //动画速度
    // call EXSetEffectSize(tx, 2) //大小
    // call SetPariticle2Size(tx, 1.5) //内置api调大小
    // call EXSetEffectZ(tx, (EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 500.00)) //高度
    // call DestroyEffect(tx)
    set ydl_group=CreateGroup() //造成伤害dwz
    call GroupEnumUnitsInRange(ydl_group, x, y, 1000.00, null)
    loop
    set ydl_unit=FirstOfGroup(ydl_group)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(ydl_group, ydl_unit)
    //查询友军
    if ( ( IsUnitType(ydl_unit, UNIT_TYPE_DEAD) == false ) ) and ( ( IsUnitAlly(ydl_unit, wj) == true ) ) then
    set sz=( GetUnitState(ydl_unit, UNIT_STATE_MAX_LIFE) - GetUnitState(ydl_unit, UNIT_STATE_LIFE) ) * 0.2 + GetHeroStatBJ(bj_HEROSTAT_AGI, dw, true) * 0.1
    call mh_hf1(ydl_unit , dw , sz , 0)
    set zfc="e_buffgreen2a.mdx"
    set tx2=AddSpecialEffectTarget(zfc, ydl_unit, "origin") //回血特效
    call DestroyEffect(tx2)
    endif
    endloop
    call DestroyGroup(ydl_group)
    endif
    if time >= 2.5 or IsUnitType(dw, UNIT_TYPE_DEAD) == true then //代码结束
    call RemoveUnit(mj)
    call DestroyEffect(tx)
    call DestroyEffect(tstx[0])
    call DestroyEffect(tstx[1])
    call FlushChildHashtable(hsb, jsqid)
    call DestroyTimer(GetExpiredTimer())
    endif
    endif
    set dw=null
    set mj=null
    set wj=null
    set jsq2=null
    set tx=null
    set tx2=null
    set zfc=null
    set ydl_group=null
    set ydl_unit=null
    set tstx[0]=null
    set tstx[1]=null
    endfunction
    function Trig_J_Firefly____________006Actions takes nothing returns nothing
    local timer jsq= CreateTimer()
    local integer jsqid= GetHandleId(jsq)
    local unit dw= udg_wndanwei_jndw[1]
    local unit mj
    local player wj= GetOwningPlayer(dw)
    local real x= GetUnitX(dw)
    local real y= GetUnitY(dw)
    local real x2= udg_wnshishu_shishu[1]
    local real y2= udg_wnshishu_shishu[2]
    local real jd= Atan2BJ(( y2 - y ), ( x2 - x ))
    local integer array dz
    local real array dzsd
    call IssueImmediateOrder(dw, "stop")
    set mj=CreateUnit(wj, 'e002', x, y, 0) //施法控制马甲
    call UnitAddAbility(mj, 'A00F') //技能释放中
    call IssueTargetOrder(mj, "magicleash", dw)
    call SaveUnitHandle(hsb, jsqid, StringHash("mj"), mj)
    call mh_buffkq(dw , 0.5 , 2 , 1) //假无敌
    // if (GetUnitTypeId(dw) == 'O00U') then
    set dz[1]=1
    set dzsd[1]=3.08
    // endif
    //保存数据准备开始代码
    call SaveUnitHandle(hsb, jsqid, StringHash("dw"), dw)
    call SavePlayerHandle(hsb, jsqid, StringHash("wj"), wj)
    call SaveReal(hsb, jsqid, StringHash("x"), x)
    call SaveReal(hsb, jsqid, StringHash("y"), y)
    call SaveReal(hsb, jsqid, StringHash("x2"), x2)
    call SaveReal(hsb, jsqid, StringHash("y2"), y2)
    call SaveReal(hsb, jsqid, StringHash("jd"), jd)
    call SaveInteger(hsb, jsqid, StringHash("jnzs2"), 0)
    if GetRandomInt(1, 2) == 1 then
    call SaveSoundHandle(hsb, jsqid, StringHash("语音1"), gg_snd_mh_Firefly_Stand2)
    else
    call SaveSoundHandle(hsb, jsqid, StringHash("语音1"), gg_snd_mh_Firefly_jn6)
    endif
    call SaveInteger(hsb, jsqid, StringHash("开头动作1"), dz[1])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度1"), dzsd[1])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度2"), dzsd[2])
    call SaveStr(hsb, jsqid, StringHash("模型"), ( EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(dw)) + "].file") ))
    call SaveReal(hsb, jsqid, StringHash("模型大小"), S2R(( EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(dw)) + "].modelScale") )))
    call TimerStart(jsq, 0.02, TRUE, function Trig_J_Firefly____________006jn2) //开始执行
    set jsq=null
    set dw=null
    set mj=null
    set wj=null
    endfunction
    //===========================================================================
    function InitTrig_J_Firefly____________006 takes nothing returns nothing
    set gg_trg_J_Firefly____________006=CreateTrigger()
    call TriggerAddAction(gg_trg_J_Firefly____________006, function Trig_J_Firefly____________006Actions)
    endfunction
    //TESH.scrollpos=140
    //TESH.alwaysfold=0

    //===========================================================================
// Trigger: J-Firefly流萤突进007
//===========================================================================
function Trig_J_Firefly____________007jn2 takes nothing returns nothing
    local timer jsq2
    local integer jsq2id
    local integer a= 0
    local integer jsqid= GetHandleId(GetExpiredTimer())
    local unit dw= LoadUnitHandle(hsb, jsqid, StringHash("dw"))
    local player wj= LoadPlayerHandle(hsb, jsqid, StringHash("wj"))
    local real x= LoadReal(hsb, jsqid, StringHash("x"))
    local real y= LoadReal(hsb, jsqid, StringHash("y"))
    local real x2= LoadReal(hsb, jsqid, StringHash("x2"))
    local real y2= LoadReal(hsb, jsqid, StringHash("y2"))
    local real jd= LoadReal(hsb, jsqid, StringHash("jd"))
    local string zfc
    local effect tx
    local effect tx2
    local real time= LoadReal(hsb, jsqid, StringHash("逝去时间"))
    
    local group ydl_group
    local group dwz= LoadGroupHandle(hsb, jsqid, StringHash("dwz"))
    local unit ydl_unit
    local unit mj= LoadUnitHandle(hsb, jsqid, StringHash("mj"))
    local unit mj3= LoadUnitHandle(hsb, jsqid, StringHash("mj3"))
    local real jd2= LoadReal(hsb, jsqid, StringHash("jd2"))
    local real jd3= LoadReal(hsb, jsqid, StringHash("jd3"))
    local real sd= LoadReal(hsb, jsqid, StringHash("速度"))
    local real gd= LoadReal(hsb, jsqid, StringHash("高度"))
    local real gdsd= LoadReal(hsb, jsqid, StringHash("高度速度"))
    local real sjss= 0
    local real sz= 0
    local integer pd= LoadInteger(hsb, jsqid, StringHash("判断"))
    local integer zzpd= LoadInteger(hsb, jsqid, StringHash("中止判断"))
    local integer dz1= LoadInteger(hsb, jsqid, StringHash("开头动作1"))
    local integer dz2= LoadInteger(hsb, jsqid, StringHash("开头动作2"))
    local integer dz3= LoadInteger(hsb, jsqid, StringHash("开头动作3"))
    local integer dz4= LoadInteger(hsb, jsqid, StringHash("开头动作4"))
    local real dzsd1= LoadReal(hsb, jsqid, StringHash("开头动作动画速度1"))
    local real dzsd2= LoadReal(hsb, jsqid, StringHash("开头动作动画速度2"))
    local real dzsd3= LoadReal(hsb, jsqid, StringHash("开头动作动画速度3"))
    local real dzsd4= LoadReal(hsb, jsqid, StringHash("开头动作动画速度4"))
    local real sh1= LoadReal(hsb, jsqid, StringHash("伤害"))
    local real sh2= LoadReal(hsb, jsqid, StringHash("伤害2"))
    local real x3= 0
    local real y3= 0
    local real x4= 0
    local real y4= 0
    local integer jnzs= LoadInteger(hsb, jsqid, StringHash("jnzs"))
    local integer jnzs2= LoadInteger(hsb, jsqid, StringHash("jnzs2"))
    local effect array tstx
    set a=0
    loop
    set tstx[a]=LoadEffectHandle(hsb, jsqid, StringHash("特效" + I2S(a)))
    set a=a + 1
    exitwhen a >= 3
    endloop
    if mh_stpd2(dw) == 0 then //判断该单位是否处于时停
    set time=time + 0.02
    call SaveReal(hsb, jsqid, StringHash("逝去时间"), time)
    if time == 0.02 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set x2=x
    set y2=y
    call SaveReal(hsb, jsqid, StringHash("x2"), x2)
    call SaveReal(hsb, jsqid, StringHash("y2"), y2)
    set mj3=CreateUnit(wj, 'e002', x, y, 0) //全能技能马甲zhan
    call UnitAddAbility(mj3, 'A00J') //眩晕1s
    call SaveUnitHandle(hsb, jsqid, StringHash("mj3"), mj3)
    call SetUnitAnimationByIndex(dw, dz1)
    call SetUnitTimeScale(dw, dzsd1)
    call UnitAddAbility(dw, 'Amrf')
    call UnitRemoveAbility(dw, 'Amrf')
    call SetUnitFlyHeight(dw, 0.00, 0.00)
    set sh1=( 25.00 + ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, dw, true)) * 1 ) )
    set sh2=( 25.00 + ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, dw, true)) * 0.3 ) )
    set sjss=1
    if ( ( GetUnitAbilityLevel(dw, 'A0TK') >= 1 ) ) then
    set sjss=sjss + 0.1
    endif
    set sh1=sh1 * sjss
    set sh2=sh2 * sjss
    call SaveReal(hsb, jsqid, StringHash("伤害"), sh1)
    call SaveReal(hsb, jsqid, StringHash("伤害2"), sh2)
    call dsound(LoadStr(hsb, jsqid, StringHash("音效" + I2S(GetRandomInt(1, 5)))) , dw)
    call mh_tm1(dw , 0.05 , 0.01 , 0 , 100 , 5)
    call mh_cfty(dw , x , y , jd , 1200 , 240 , 0 , 5 , 0 , 0 , "流萤Q" , 1 , 5 , 250 , 2 , 0)
    call PlaySoundOnUnitBJ(LoadSoundHandle(hsb, jsqid, StringHash("语音" + I2S(1))), 100, dw) //语音
    if ( ( GetPlayerTechCountSimple('R00X', wj) >= 1 ) ) then
    call mh_buffkq(dw , 0.6 , 2 , 1) //假无敌
    endif
    //手部丝带
    set zfc="stardust.mdl"
    set tstx[0]=AddSpecialEffectTarget(zfc, dw, "right hand")
    call YDWETimerDestroyEffect(1 , tstx[0])
    //冲刺沙尘特效
    set zfc="t_cf2.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd - 180) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.25)) //动画速度
    call DestroyEffect(tx)
    //星见雅蓄力冲锋特效
    set zfc="1334797401.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd - 180) //角度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 100 )) //高度
    call EXSetEffectSpeed(tx , 2) //动画速度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(40) + 0x10000 * PercentTo255(20) + 0x100 * PercentTo255(80) + PercentTo255(60))
    call DestroyEffect(tx)
    //气场特效1
    set zfc="117448227.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 3) //大小
    call EXSetEffectSpeed(tx , 1.2) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 10.00 )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(40) + 0x10000 * PercentTo255(80) + 0x100 * PercentTo255(80) + PercentTo255(80))
    call DestroyEffect(tx)
    //风格化气浪特效2
    set zfc="894093513.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 90)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1.2, 1.5)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(50, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(20) + 0x10000 * PercentTo255(20) + 0x100 * PercentTo255(80) + PercentTo255(60))
    call DestroyEffect(tx)
    //蓝青色地面气场特效
    set zfc="869602743.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 90) //角度
    call EXEffectMatRotateZ(tx , jd) //角度
    call DestroyEffect(tx)
    endif
    if time == 0.24 then
    call SetUnitAnimationByIndex(dw, dz2)
    call SetUnitTimeScale(dw, dzsd2)
    endif
    if time == 0.3 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call mh_cfty(dw , x , y , jd - 180 , 1200 , 240 , 0 , 5 , 0 , 0 , "流萤Q" , 1 , 5 , 250 , 2 , 0)
    call dsound(LoadStr(hsb, jsqid, StringHash("音效" + I2S(GetRandomInt(1, 5)))) , dw)
    call SetUnitFacingTimed(dw, jd - 180, 0)
    call EXSetUnitFacing(dw , jd - 180)
    endif
    if time == 0.34 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call mh_tm1(dw , 0.1 , 0.01 , 0 , 100 , 6)
    //冲刺沙尘特效
    set zfc="t_cf2.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd - 180) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.25)) //动画速度
    call DestroyEffect(tx)
    //星见雅蓄力冲锋特效
    set zfc="1334797401.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 2.5) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 150 )) //高度
    call EXSetEffectSpeed(tx , 1.5) //动画速度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(90) + 0x10000 * PercentTo255(20) + 0x100 * PercentTo255(80) + PercentTo255(60))
    call DestroyEffect(tx)
    endif
    if time >= 0.0 and time <= 0.6 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    if time <= 0.1 then
    set ydl_group=CreateGroup() //造成伤害dwz
    call GroupClear(ydl_group)
    call GroupEnumUnitsInRange(ydl_group, x, y, 250.00, null)
    loop
    set ydl_unit=FirstOfGroup(ydl_group)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(ydl_group, ydl_unit)
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 1 ) and ( IsUnitEnemy(ydl_unit, wj) == true ) ) then // INLINED!!
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) ) then // INLINED!!
    call mh_zzfycfxt1(ydl_unit , null , 0)
    endif
    if (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 3 then // INLINED!!
    call mh_zzfycfxt1(dw , null , 0)
    call SaveInteger(hsb, jsqid, StringHash("中止判断"), 1)
    endif
    endif
    if mh_tjfz1(ydl_unit , wj) == true then //位移
    set x3=GetUnitX(ydl_unit) //位移
    set y3=GetUnitY(ydl_unit)
    set sz=GetRandomReal(40, 80)
    if ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 15, 15)) == 0) == false ) then // INLINED!!
    set sz=sz * 0.05
    set pd=1
    call SaveInteger(hsb, jsqid, StringHash("判断"), pd)
    endif
    set jd3=jd
    set x3=( x3 + sz * CosBJ(jd3) )
    set y3=( y3 + sz * SinBJ(jd3) )
    call SetUnitX(ydl_unit, x3)
    call SetUnitY(ydl_unit, y3)
    endif
    //查询防御状态和是否拥有无法选取 以及通用的选取条件  不判断重复
    if ( ( IsUnitEnemy(ydl_unit, wj) == true ) and ( GetUnitPointValue(ydl_unit) != 233 ) and ( mh_tjfz6(ydl_unit , 0) == true ) and ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) and ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 3, 3)) == 0) == true ) and ( IsUnitType(ydl_unit, UNIT_TYPE_DEAD) == false ) ) and IsUnitInGroup(ydl_unit, dwz) == false then // INLINED!!
    //英雄攻击类型 强化伤害类型
    call mh_sh1(dw , ydl_unit , sh1 , 4 , 0 , true , false , ATTACK_TYPE_HERO , DAMAGE_TYPE_ENHANCED , WEAPON_TYPE_WHOKNOWS)
    call IssueTargetOrder(mj3, "thunderbolt", ydl_unit)
    call GroupAddUnit(dwz, ydl_unit)
    if GetRandomInt(1, 2) == 1 then
    set zfc="908196484.mdx"
    else
    set zfc="impact" + I2S(GetRandomInt(1, 2)) + ".mdx"
    endif
    set tx2=AddSpecialEffect(zfc, GetUnitX(ydl_unit), GetUnitY(ydl_unit)) //星见雅受击特效
    call EXEffectMatRotateZ(tx2 , ( ( 25.00 ) * ( I2R(GetRandomInt(1, 14)) ) )) //角度
    call EXSetEffectSize(tx2 , ( GetRandomReal(0.6, 0.8) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.40 ) )) //大小
    call EXSetEffectSpeed(tx2 , GetRandomReal(1.5, 2)) //特效动画速度
    call EXSetEffectZ(tx2 , ( EXGetEffectZ(tx2) + ( GetUnitFlyHeight(ydl_unit) + 50 ) )) //高度
    call DestroyEffect(tx2)
    if IsUnitType(ydl_unit, UNIT_TYPE_HERO) == true then
    set tx2=AddSpecialEffect("-850098650.mdx", GetUnitX(ydl_unit), GetUnitY(ydl_unit)) //受击刀光粒子特效
    call EXEffectMatRotateY(tx2 , - 10 * I2R(GetRandomInt(0, 18))) //角度
    call EXEffectMatRotateZ(tx2 , - 25 * I2R(GetRandomInt(1, 14))) //角度
    call EXSetEffectSize(tx2 , ( GetRandomReal(0.2, 0.4) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.10 ) )) //大小
    call EXSetEffectSpeed(tx2 , GetRandomReal(1.4, 2)) //特效动画速度
    call EXSetEffectZ(tx2 , ( EXGetEffectZ(tx2) + ( GetUnitFlyHeight(ydl_unit) + GetRandomReal(40, 75) ) )) //高度
    call DestroyEffect(tx2)
    endif
    endif
    endloop
    call DestroyGroup(ydl_group)
    endif
    if time >= 0.3 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set jd3=jd
    if time >= 0.4 then
    set sjss=RMaxBJ(( 80 - ( ( time - 0.4 ) * 500.00 ) ), 4.00)
    set x=( x + sjss * CosBJ(jd3 - 180) )
    set y=( y + sjss * SinBJ(jd3 - 180) )
    if mh_jcdwxy(x , y) == true then
    call SetUnitX(dw, x)
    call SetUnitY(dw, y)
    endif
    endif
    set sjss=RMaxBJ(1200 - ( time - 0.3 ) * 50 * 80, 0)
    set x3=( x2 + sjss * CosBJ(jd3) )
    set y3=( y2 + sjss * SinBJ(jd3) )
    set x4=x3
    set y4=y3
    if ModuloReal(time, 0.02) == 0.02 then
    //直线刀光
    set zfc="1956614739.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 2.5 * I2R(GetRandomInt(1, 3))) //角度
    if ModuloReal(time, 0.04) == 0.04 then
    call EXEffectMatRotateZ(tx , jd3 + 30) //角度
    else
    call EXEffectMatRotateZ(tx , jd3 - 30) //角度
    endif
    call EXSetEffectSize(tx , 1.5) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.4, 1.5)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(50, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(40) + 0x100 * PercentTo255(100) + PercentTo255(80))
    call DestroyEffect(tx)
    endif
    if ModuloReal(time, 0.06) == 0.06 then
    //白色旋转刀光2
    set zfc="-124382725.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 5 * I2R(GetRandomInt(1, 3))) //角度
    call EXEffectMatRotateZ(tx , jd3 - 180 - 5 * I2R(GetRandomInt(1, 5))) //角度
    call EXSetEffectSize(tx , GetRandomReal(2.5, 3.5)) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.4, 1.8)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(100, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(40) + 0x100 * PercentTo255(100) + PercentTo255(40))
    call DestroyEffect(tx)
    //风格化气浪特效
    set zfc="117448227.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateX(tx , - 20 * I2R(GetRandomInt(0, 18)))
    call EXEffectMatRotateZ(tx , jd + 4 * I2R(GetRandomInt(- 5, 5))) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.5)) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(4, 6)) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(50, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(85, 95)) + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(100))
    call DestroyEffect(tx)
    //风格化气浪特效3
    set zfc="1577588603.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 2 * I2R(GetRandomInt(0, 9)))
    call EXEffectMatRotateZ(tx , jd + 4 * I2R(GetRandomInt(- 5, 5))) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1.2, 1.7)) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(2, 3)) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(0, 30) )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(85, 95)) + 0x10000 * PercentTo255(80) + 0x100 * PercentTo255(80) + PercentTo255(80))
    call DestroyEffect(tx)
    //蓝青色地面气场特效
    set zfc="869602743.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 90) //角度
    call EXEffectMatRotateZ(tx , jd3 - 180 + 4 * I2R(GetRandomInt(- 5, 5))) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.2)) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(0.75, 1)) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 25 )) //高度
    call SetPariticle2Size(tx , GetRandomReal(0.75, 1)) //内置api调大小
    call DestroyEffect(tx)
    endif
    if ModuloReal(time, 0.04) == 0.04 then
    set jd3=jd - GetRandomReal(80, 100)
    set sjss=GetRandomInt(200, 240)
    set x3=( x4 + sjss * CosBJ(jd3) )
    set y3=( y4 + sjss * SinBJ(jd3) )
    //直线刀光
    set zfc="-1413746522.mdx"
    set zfc="1956614739.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 2.5 * I2R(GetRandomInt(32, 36))) //角度
    call EXEffectMatRotateZ(tx , GetRandomReal(0, 360)) //角度
    call EXSetEffectSize(tx , GetRandomReal(2, 2.5)) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.2, 1.5)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(50, 100) )) //高度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(20) + 0x100 * PercentTo255(GetRandomReal(80, 90)) + PercentTo255(GetRandomReal(60, 80)))
    call DestroyEffect(tx)
    set jd3=jd + GetRandomReal(80, 100)
    set sjss=GetRandomInt(200, 240)
    set x3=( x4 + sjss * CosBJ(jd3) )
    set y3=( y4 + sjss * SinBJ(jd3) )
    //直线刀光
    set zfc="-1413746522.mdx"
    set zfc="1956614739.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 2.5 * I2R(GetRandomInt(32, 36))) //角度
    call EXEffectMatRotateZ(tx , GetRandomReal(0, 360)) //角度
    call EXSetEffectSize(tx , GetRandomReal(2, 2.5)) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.2, 1.5)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(50, 100) )) //高度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(20) + 0x100 * PercentTo255(GetRandomReal(80, 90)) + PercentTo255(GetRandomReal(60, 80)))
    call DestroyEffect(tx)
    endif
    set ydl_group=CreateGroup() //造成伤害dwz
    call GroupClear(ydl_group)
    call GroupEnumUnitsInRange(ydl_group, x4, y4, 280.00, null)
    loop
    set ydl_unit=FirstOfGroup(ydl_group)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(ydl_group, ydl_unit)
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 1 ) and ( IsUnitEnemy(ydl_unit, wj) == true ) ) then // INLINED!!
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) ) then // INLINED!!
    call mh_zzfycfxt1(ydl_unit , null , 0)
    endif
    if (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 3 then // INLINED!!
    call mh_zzfycfxt1(dw , null , 0)
    call SaveInteger(hsb, jsqid, StringHash("中止判断"), 1)
    endif
    endif
    if mh_tjfz1(ydl_unit , wj) == true then //位移
    set x3=GetUnitX(ydl_unit) //位移
    set y3=GetUnitY(ydl_unit)
    set sz=GetRandomReal(10, 20)
    if ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 15, 15)) == 0) == false ) then // INLINED!!
    set sz=sz * 0.05
    set pd=1
    call SaveInteger(hsb, jsqid, StringHash("判断"), pd)
    endif
    set jd3=jd - 180
    set x3=( x3 + sz * CosBJ(jd3) )
    set y3=( y3 + sz * SinBJ(jd3) )
    call SetUnitX(ydl_unit, x3)
    call SetUnitY(ydl_unit, y3)
    endif
    //查询防御状态和是否拥有无法选取 以及通用的选取条件  不判断重复
    if ( ( IsUnitEnemy(ydl_unit, wj) == true ) and ( GetUnitPointValue(ydl_unit) != 233 ) and ( mh_tjfz6(ydl_unit , 0) == true ) and ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) and ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 3, 3)) == 0) == true ) and ( IsUnitType(ydl_unit, UNIT_TYPE_DEAD) == false ) ) then // INLINED!!
    //英雄攻击类型 强化伤害类型
    call mh_sh1(dw , ydl_unit , sh2 , 4 , 0 , true , false , ATTACK_TYPE_HERO , DAMAGE_TYPE_ENHANCED , WEAPON_TYPE_WHOKNOWS)
    call IssueTargetOrder(mj3, "thunderbolt", ydl_unit)
    if GetRandomInt(1, 2) == 1 then
    set zfc="908196484.mdx"
    else
    set zfc="impact" + I2S(GetRandomInt(1, 2)) + ".mdx"
    endif
    set tx2=AddSpecialEffect(zfc, GetUnitX(ydl_unit), GetUnitY(ydl_unit)) //星见雅受击特效
    call EXEffectMatRotateZ(tx2 , ( ( 25.00 ) * ( I2R(GetRandomInt(1, 14)) ) )) //角度
    call EXSetEffectSize(tx2 , ( GetRandomReal(0.6, 0.8) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.40 ) )) //大小
    call EXSetEffectSpeed(tx2 , GetRandomReal(1.5, 2)) //特效动画速度
    call EXSetEffectZ(tx2 , ( EXGetEffectZ(tx2) + ( GetUnitFlyHeight(ydl_unit) + 50 ) )) //高度
    call DestroyEffect(tx2)
    if GetRandomReal(1, 2) <= 1.5 then
    call GroupAddUnit(dwz, ydl_unit)
    endif
    if IsUnitType(ydl_unit, UNIT_TYPE_HERO) == true then
    set tx2=AddSpecialEffect("-850098650.mdx", GetUnitX(ydl_unit), GetUnitY(ydl_unit)) //受击刀光粒子特效
    call EXEffectMatRotateY(tx2 , - 10 * I2R(GetRandomInt(0, 18))) //角度
    call EXEffectMatRotateZ(tx2 , - 25 * I2R(GetRandomInt(1, 14))) //角度
    call EXSetEffectSize(tx2 , ( GetRandomReal(0.2, 0.4) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.10 ) )) //大小
    call EXSetEffectSpeed(tx2 , GetRandomReal(1.4, 2)) //特效动画速度
    call EXSetEffectZ(tx2 , ( EXGetEffectZ(tx2) + ( GetUnitFlyHeight(ydl_unit) + GetRandomReal(40, 75) ) )) //高度
    call DestroyEffect(tx2)
    endif
    endif
    endloop
    call DestroyGroup(ydl_group)
    endif
    endif
    if time == 0.1 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set jd3=jd
    set sjss=200
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    //白色旋转刀光2
    set zfc="-124382725.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 20) //角度
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 3) //大小
    call EXSetEffectSpeed(tx , 1) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 160 )) //高度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(40) + 0x100 * PercentTo255(100) + PercentTo255(40))
    call DestroyEffect(tx)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 20)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.08, false, function mh__jtzdhs1)
    endif
    if time == 0.4 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call SetUnitTimeScale(dw, 1)
    call IssueImmediateOrder(mj, "stop")
    set sjss=200
    set x3=( x + sjss * CosBJ(jd - 180) )
    set y3=( y + sjss * SinBJ(jd - 180) )
    //白色旋转刀光2
    set zfc="-124382725.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 160) //角度
    call EXEffectMatRotateZ(tx , jd + 10) //角度
    call EXSetEffectSize(tx , 3.5) //大小
    call EXSetEffectSpeed(tx , 0.85) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 200 )) //高度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(100) + PercentTo255(80))
    call DestroyEffect(tx)
    //刀光特效
    set zfc="-173761042.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 20) //角度
    call EXEffectMatRotateZ(tx , jd + 10) //角度
    call EXSetEffectSize(tx , 1.75) //大小
    call EXSetEffectSpeed(tx , 2.2) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 200 )) //高度
    call DestroyEffect(tx)
    //蓝青色地面气场特效
    set zfc="869602743.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateZ(tx , jd + 4 * I2R(GetRandomInt(- 5, 5))) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(0.8, 1)) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(1.2, 2)) //大小
    call SetPariticle2Size(tx , GetRandomReal(1, 1.5)) //内置api调大小
    call DestroyEffect(tx)
    //风格化气浪特效
    set zfc="621819663.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 20 * I2R(GetRandomInt(0, 18)))
    call EXEffectMatRotateZ(tx , jd - 180 + 4 * I2R(GetRandomInt(- 5, 5))) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1.5, 2)) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(1, 1.5)) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(50, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(30) + 0x100 * PercentTo255(40) + PercentTo255(60))
    call DestroyEffect(tx)
    //风格化气浪特效3
    set zfc="1577588603.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 20 * I2R(GetRandomInt(0, 9)))
    call EXEffectMatRotateZ(tx , jd - 180 + 4 * I2R(GetRandomInt(- 5, 5))) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1.5, 2)) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(2, 3)) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(50, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(70, 90)) + 0x10000 * PercentTo255(80) + 0x100 * PercentTo255(80) + PercentTo255(80))
    call DestroyEffect(tx)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 50)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.1, false, function mh__jtzdhs1)
    endif
    if time >= 0.6 or IsUnitType(dw, UNIT_TYPE_DEAD) == true or zzpd == 1 then //代码结束
    if IsUnitType(dw, UNIT_TYPE_DEAD) == true or zzpd == 1 then
    call mh_tm1(dw , 0.1 , 0.01 , 0 , 100 , 6)
    endif
    call RemoveUnit(mj)
    call RemoveUnit(mj3)
    call GroupClear(dwz)
    call DestroyGroup(dwz)
    set a=0
    loop
    call DestroyEffect(tstx[a])
    set a=a + 1
    exitwhen a >= 3
    endloop
    call FlushChildHashtable(hsb, jsqid)
    call DestroyTimer(GetExpiredTimer())
    endif
    endif
    set dw=null
    set mj=null
    set mj3=null
    set wj=null
    set jsq2=null
    set tx=null
    set tx2=null
    set zfc=null
    set dwz=null
    set ydl_group=null
    set ydl_unit=null
    set a=0
    loop
    set tstx[a]=null
    set a=a + 1
    exitwhen a >= 3
    endloop
    endfunction
    function Trig_J_Firefly____________007Actions takes nothing returns nothing
    local timer jsq= CreateTimer()
    local integer jsqid= GetHandleId(jsq)
    local unit dw= udg_wndanwei_jndw[1]
    local unit mj
    local player wj= GetOwningPlayer(dw)
    local real x= GetUnitX(dw)
    local real y= GetUnitY(dw)
    local real x2= udg_wnshishu_shishu[0]
    local real y2= udg_wnshishu_shishu[1]
    local real jd= Atan2BJ(( y2 - y ), ( x2 - x ))
    local integer array dz
    local real array dzsd
    call IssueImmediateOrder(dw, "stop")
    set mj=CreateUnit(wj, 'e002', x, y, 0) //施法控制马甲
    call UnitAddAbility(mj, 'A00F') //技能释放中
    call IssueTargetOrder(mj, "magicleash", dw)
    call SaveUnitHandle(hsb, jsqid, StringHash("mj"), mj)
    call mh_buffkq(dw , 0.5 , 2 , 1) //假无敌
    // if (GetUnitTypeId(dw) == 'O00U') then
    set dz[1]=5
    set dz[2]=8
    set dzsd[1]=4
    set dzsd[2]=2.5
    // endif
    //保存数据准备开始代码
    call SaveUnitHandle(hsb, jsqid, StringHash("dw"), dw)
    call SavePlayerHandle(hsb, jsqid, StringHash("wj"), wj)
    call SaveReal(hsb, jsqid, StringHash("x"), x)
    call SaveReal(hsb, jsqid, StringHash("y"), y)
    call SaveReal(hsb, jsqid, StringHash("x2"), x2)
    call SaveReal(hsb, jsqid, StringHash("y2"), y2)
    call SaveReal(hsb, jsqid, StringHash("jd"), jd)
    call SaveInteger(hsb, jsqid, StringHash("jnzs2"), 0)
    if GetRandomInt(1, 3) == 1 then
    call SaveSoundHandle(hsb, jsqid, StringHash("语音1"), gg_snd_mh_Firefly_ready1)
    endif
    call SaveInteger(hsb, jsqid, StringHash("开头动作1"), dz[1])
    call SaveInteger(hsb, jsqid, StringHash("开头动作1"), dz[2])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度1"), dzsd[1])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度2"), dzsd[2])
    call SaveGroupHandle(hsb, jsqid, StringHash("dwz"), CreateGroup())
    call SaveStr(hsb, jsqid, StringHash("音效1"), "mh_Firefly_Attack1.mp3")
    call SaveStr(hsb, jsqid, StringHash("音效2"), "mh_Firefly_Attack2.mp3")
    call SaveStr(hsb, jsqid, StringHash("音效3"), "mh_Firefly_Attack3.mp3")
    call SaveStr(hsb, jsqid, StringHash("音效4"), "mh_Firefly_Attack4.mp3")
    call SaveStr(hsb, jsqid, StringHash("音效5"), "mh_Firefly_Attack5.mp3")
    call SaveStr(hsb, jsqid, StringHash("模型"), ( EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(dw)) + "].file") ))
    call SaveReal(hsb, jsqid, StringHash("模型大小"), S2R(( EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(dw)) + "].modelScale") )))
    call TimerStart(jsq, 0.02, TRUE, function Trig_J_Firefly____________007jn2) //开始执行
    set jsq=null
    set dw=null
    set mj=null
    set wj=null
    endfunction
    //===========================================================================
    function InitTrig_J_Firefly____________007 takes nothing returns nothing
    set gg_trg_J_Firefly____________007=CreateTrigger()
    call TriggerAddAction(gg_trg_J_Firefly____________007, function Trig_J_Firefly____________007Actions)
    endfunction
    //TESH.scrollpos=178
    //TESH.alwaysfold=0

    //===========================================================================
// Trigger: J-Firefly流萤三连008
//===========================================================================
function Trig_J_Firefly____________008jn2 takes nothing returns nothing
    local timer jsq2
    local integer jsq2id
    local integer a= 0
    local integer jsqid= GetHandleId(GetExpiredTimer())
    local unit dw= LoadUnitHandle(hsb, jsqid, StringHash("dw"))
    local player wj= LoadPlayerHandle(hsb, jsqid, StringHash("wj"))
    local real x= LoadReal(hsb, jsqid, StringHash("x"))
    local real y= LoadReal(hsb, jsqid, StringHash("y"))
    local real x2= LoadReal(hsb, jsqid, StringHash("x2"))
    local real y2= LoadReal(hsb, jsqid, StringHash("y2"))
    local real jd= LoadReal(hsb, jsqid, StringHash("jd"))
    local string zfc
    local effect tx
    local effect tx2
    local real time= LoadReal(hsb, jsqid, StringHash("逝去时间"))
    
    local group ydl_group
    local group dwz= LoadGroupHandle(hsb, jsqid, StringHash("dwz"))
    local unit ydl_unit
    local unit mj= LoadUnitHandle(hsb, jsqid, StringHash("mj"))
    local unit mj3= LoadUnitHandle(hsb, jsqid, StringHash("mj3"))
    local real jd2= LoadReal(hsb, jsqid, StringHash("jd2"))
    local real jd3= LoadReal(hsb, jsqid, StringHash("jd3"))
    local real sd= LoadReal(hsb, jsqid, StringHash("速度"))
    local real gd= LoadReal(hsb, jsqid, StringHash("高度"))
    local real gdsd= LoadReal(hsb, jsqid, StringHash("高度速度"))
    local real sjss= 0
    local real sz= 0
    local integer pd= LoadInteger(hsb, jsqid, StringHash("判断"))
    local integer zzpd= LoadInteger(hsb, jsqid, StringHash("中止判断"))
    local integer dz1= LoadInteger(hsb, jsqid, StringHash("开头动作1"))
    local integer dz2= LoadInteger(hsb, jsqid, StringHash("开头动作2"))
    local integer dz3= LoadInteger(hsb, jsqid, StringHash("开头动作3"))
    local integer dz4= LoadInteger(hsb, jsqid, StringHash("开头动作4"))
    local real dzsd1= LoadReal(hsb, jsqid, StringHash("开头动作动画速度1"))
    local real dzsd2= LoadReal(hsb, jsqid, StringHash("开头动作动画速度2"))
    local real dzsd3= LoadReal(hsb, jsqid, StringHash("开头动作动画速度3"))
    local real dzsd4= LoadReal(hsb, jsqid, StringHash("开头动作动画速度4"))
    local real sh1= LoadReal(hsb, jsqid, StringHash("伤害"))
    local real sh2= LoadReal(hsb, jsqid, StringHash("伤害2"))
    local real x3= 0
    local real y3= 0
    local real x4= 0
    local real y4= 0
    local integer jnzs= LoadInteger(hsb, jsqid, StringHash("jnzs"))
    local integer jnzs2= LoadInteger(hsb, jsqid, StringHash("jnzs2"))
    local effect array tstx
    set a=0
    loop
    set tstx[a]=LoadEffectHandle(hsb, jsqid, StringHash("特效" + I2S(a)))
    set a=a + 1
    exitwhen a >= 3
    endloop
    if mh_stpd2(dw) == 0 then //判断该单位是否处于时停
    set time=time + 0.02
    call SaveReal(hsb, jsqid, StringHash("逝去时间"), time)
    if time == 0.02 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set jd3=jd
    set sjss=200
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    set mj3=CreateUnit(wj, 'e002', x, y, 0) //全能技能马甲zhan
    call UnitAddAbility(mj3, 'A00J') //眩晕1s
    call SaveUnitHandle(hsb, jsqid, StringHash("mj3"), mj3)
    call SetUnitAnimationByIndex(dw, dz1)
    call SetUnitTimeScale(dw, dzsd1)
    call UnitAddAbility(dw, 'Amrf')
    call UnitRemoveAbility(dw, 'Amrf')
    call SetUnitFlyHeight(dw, 0.00, 0.00)
    set sh1=( 75.00 + ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, dw, true)) * 1.5 ) )
    set sh2=( 75.00 + ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, dw, true)) * 3 ) )
    set sjss=1
    if ( ( GetUnitAbilityLevel(dw, 'A0TK') >= 1 ) ) then
    set sjss=sjss + 0.1
    endif
    if ( ( GetPlayerTechCountSimple('R000', wj) >= 1 ) ) then
    call mh_buffkq(dw , 1.2 , 2 , 1) //假无敌
    endif
    set sh1=sh1 * sjss
    set sh2=sh2 * sjss
    call SaveReal(hsb, jsqid, StringHash("伤害"), sh1)
    call SaveReal(hsb, jsqid, StringHash("伤害2"), sh2)
    call PlaySoundOnUnitBJ(LoadSoundHandle(hsb, jsqid, StringHash("语音" + I2S(1))), 100, dw) //语音
    call dsound(LoadStr(hsb, jsqid, StringHash("音效" + I2S(GetRandomInt(1, 5)))) , dw)
    call mh_cfty(dw , x , y , jd , 1200 , 240 , 20 , 10 , 0 , 0 , "流萤E" , 1 , 3 , 250 , 2 , 0)
    //冲刺沙尘特效
    set zfc="tx-smoke1.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.25)) //动画速度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(50) + 0x100 * PercentTo255(100) + PercentTo255(80))
    call DestroyEffect(tx)
    //星见雅蓄力冲锋特效
    set zfc="1334797401.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateZ(tx , jd - 180) //角度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 100 )) //高度
    call EXSetEffectSpeed(tx , 2) //动画速度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(40) + 0x10000 * PercentTo255(20) + 0x100 * PercentTo255(80) + PercentTo255(60))
    call DestroyEffect(tx)
    //气场特效1
    set zfc="117448227.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 90) //角度
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 3) //大小
    call EXSetEffectSpeed(tx , 1.2) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 10.00 )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(40) + 0x10000 * PercentTo255(80) + 0x100 * PercentTo255(80) + PercentTo255(80))
    call DestroyEffect(tx)
    //风格化气浪特效2
    set zfc="894093513.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 90)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1.2, 1.5)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(50, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(20) + 0x10000 * PercentTo255(20) + 0x100 * PercentTo255(80) + PercentTo255(60))
    call DestroyEffect(tx)
    //蓝青色地面气场特效
    set zfc="869602743.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 90) //角度
    call EXEffectMatRotateZ(tx , jd) //角度
    call DestroyEffect(tx)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 15)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.1, false, function mh__jtzdhs1)
    endif
    if time == 0.08 or time == 0.32 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    if time == 0.08 then
    set jd3=jd
    else
    set jd3=jd - 180
    call mh_tm1(dw , 0.3 , 0.01 , 0 , 100 , 6)
    endif
    //白色刀光特效
    set zfc="-1413746522.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 90)
    call EXEffectMatRotateZ(tx , jd3 - 90) //角度
    call EXSetEffectSpeed(tx , 1.5) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 100 )) //高度
    if time == 0.08 then
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(15) + 0x100 * PercentTo255(80) + PercentTo255(60))
    else
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(15) + 0x100 * PercentTo255(60) + PercentTo255(80))
    endif
    call DestroyEffect(tx)
    //星见雅蓄力冲锋特效
    set zfc="1334797401.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd3 - 180) //角度
    call EXSetEffectSize(tx , 3) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 150 )) //高度
    call EXSetEffectSpeed(tx , 1.8) //动画速度
    if time == 0.08 then
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(95) + 0x10000 * PercentTo255(20) + 0x100 * PercentTo255(80) + PercentTo255(60))
    else
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(95) + 0x10000 * PercentTo255(20) + 0x100 * PercentTo255(60) + PercentTo255(80))
    endif
    call DestroyEffect(tx)
    endif
    if time == 0.24 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call GroupClear(dwz)
    call SetUnitAnimationByIndex(dw, dz2)
    call SetUnitTimeScale(dw, dzsd2)
    call mh_cfty(dw , x , y , jd - 180 , 1000 , 180 , 20 , 10 , 0 , 0 , "流萤E" , 1 , 3 , 250 , 2 , 0)
    call mh_tm1(dw , 0.06 , 0.01 , 0 , 100 , 5)
    call dsound(LoadStr(hsb, jsqid, StringHash("音效" + I2S(GetRandomInt(1, 5)))) , dw)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 20)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.1, false, function mh__jtzdhs1)
    endif
    if time == 0.44 then
    call SetUnitTimeScale(dw, 1)
    endif
    if time == 0.76 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call GroupClear(dwz)
    call SetUnitAnimationByIndex(dw, dz3)
    call SetUnitTimeScale(dw, dzsd3)
    //蓄力特效
    set zfc="t7_wood_bashenan_juqi_1_2.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXSetEffectSpeed(tx , GetRandomReal(1.2, 1.5)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 150 )) //高度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(100) + PercentTo255(0))
    call DestroyEffect(tx)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 10)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.08, false, function mh__jtzdhs1)
    endif
    if time == 0.9 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call dsound("mh_Firefly_Attack4.mp3" , dw)
    call dsound("mh_nanaya_zj24.mp3" , dw)
    call dsound("jb-qe.mp3" , dw)
    call mh_cfty(dw , x , y , jd , 1800 , 280 , 10 , 6 , 0 , 0 , "流萤E" , 1 , 3 , 300 , 2 , 0)
    //冲刺沙尘特效
    set zfc="t_cf2.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.25)) //动画速度
    call DestroyEffect(tx)
    //气场特效1
    set zfc="117448227.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 3) //大小
    call EXSetEffectSpeed(tx , 1.2) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 10.00 )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(40) + 0x10000 * PercentTo255(80) + 0x100 * PercentTo255(80) + PercentTo255(80))
    call DestroyEffect(tx)
    //风格化气浪特效2
    set zfc="894093513.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 90)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 1.5) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.2, 1.5)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(50, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(20) + 0x10000 * PercentTo255(20) + 0x100 * PercentTo255(80) + PercentTo255(60))
    call DestroyEffect(tx)
    //蓝青色地面气场特效
    set zfc="869602743.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 90) //角度
    call EXSetEffectSize(tx , 1.5) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 10.00 )) //高度
    call EXEffectMatRotateZ(tx , jd) //角度
    call DestroyEffect(tx)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 40)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.2, false, function mh__jtzdhs1)
    endif
    if time == 0.96 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call SetUnitTimeScale(dw, 1)
    //星见雅蓄力冲锋特效
    set zfc="1334797401.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd - 180) //角度
    call EXSetEffectSize(tx , 3) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 150 )) //高度
    call EXSetEffectSpeed(tx , 1.8) //动画速度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(90) + 0x10000 * PercentTo255(20) + 0x100 * PercentTo255(80) + PercentTo255(60))
    call DestroyEffect(tx)
    endif
    if time == 1.02 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    //白色旋转刀光2
    set zfc="-124382725.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , 160) //角度
    call EXEffectMatRotateZ(tx , jd + 190) //角度
    call EXSetEffectSize(tx , 3.5) //大小
    call EXSetEffectSpeed(tx , 0.70) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 200 )) //高度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(100) + PercentTo255(80))
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(0)), tx)
    //刀光特效
    set zfc="-173761042.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 20) //角度
    call EXEffectMatRotateZ(tx , jd + 190) //角度
    call EXSetEffectSize(tx , 1.75) //大小
    call EXSetEffectSpeed(tx , 1.8) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 200 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(1)), tx)
    endif
    if time >= 0 and time <= 1.2 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    if time >= 0.44 and time <= 0.7 then
    set jd3=jd - 180
    set sjss=RMaxBJ(( 60 - ( ( time - 0.44 ) * 200.00 ) ), 4.00)
    set x=( x + sjss * CosBJ(jd3) )
    set y=( y + sjss * SinBJ(jd3) )
    if mh_jcdwxy(x , y) == true then
    call SetUnitX(dw, x)
    call SetUnitY(dw, y)
    endif
    endif
    if time >= 1.02 then
    set jd3=jd
    set sjss=RMaxBJ(( 60 - ( ( time - 1.02 ) * 300.00 ) ), 4.00)
    set x=( x + sjss * CosBJ(jd3) )
    set y=( y + sjss * SinBJ(jd3) )
    if mh_jcdwxy(x , y) == true then
    call SetUnitX(dw, x)
    call SetUnitY(dw, y)
    call EXSetEffectXY(tstx[0] , x , y)
    call EXSetEffectXY(tstx[1] , x , y)
    endif
    endif
    if time <= 0.2 or ( time >= 0.24 and time <= 0.44 ) then
    if time <= 0.2 then
    set jd3=jd
    else
    set jd3=jd - 180
    endif
    if ModuloReal(time, 0.04) == 0.04 then
    //白色旋转刀光2
    set zfc="-124382725.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 5 * I2R(GetRandomInt(1, 3))) //角度
    call EXEffectMatRotateZ(tx , jd3 - 5 * I2R(GetRandomInt(1, 5))) //角度
    call EXSetEffectSize(tx , GetRandomReal(2.5, 3.5)) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.4, 1.8)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(100, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(40) + 0x100 * PercentTo255(100) + PercentTo255(40))
    call DestroyEffect(tx)
    //冲刺沙尘特效
    set zfc="894093513.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 90)
    call EXEffectMatRotateZ(tx , jd3) //角度
    call EXSetEffectSize(tx , GetRandomReal(1, 1.2)) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.5, 2)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(0, 20) )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(60) + 0x10000 * PercentTo255(20) + 0x100 * PercentTo255(80) + PercentTo255(60))
    call DestroyEffect(tx)
    endif
    set ydl_group=CreateGroup() //造成伤害dwz
    call GroupEnumUnitsInRange(ydl_group, x, y, 300.00, null)
    loop
    set ydl_unit=FirstOfGroup(ydl_group)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(ydl_group, ydl_unit)
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 1 ) and ( IsUnitEnemy(ydl_unit, wj) == true ) ) then // INLINED!!
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) ) then // INLINED!!
    call mh_zzfycfxt1(ydl_unit , null , 0)
    endif
    if (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 3 then // INLINED!!
    call mh_zzfycfxt1(dw , null , 0)
    call SaveInteger(hsb, jsqid, StringHash("中止判断"), 1)
    endif
    endif
    //查询防御状态和是否拥有无法选取 以及通用的选取条件  不判断重复
    if ( ( IsUnitEnemy(ydl_unit, wj) == true ) and ( GetUnitPointValue(ydl_unit) != 233 ) and ( mh_tjfz6(ydl_unit , 0) == true ) and ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) and ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 3, 3)) == 0) == true ) and ( IsUnitType(ydl_unit, UNIT_TYPE_DEAD) == false ) ) and IsUnitInGroup(ydl_unit, dwz) == false then // INLINED!!
    //英雄攻击类型 强化伤害类型
    call mh_sh1(dw , ydl_unit , sh1 , 4 , 0 , true , false , ATTACK_TYPE_HERO , DAMAGE_TYPE_ENHANCED , WEAPON_TYPE_WHOKNOWS)
    call IssueTargetOrder(mj3, "thunderbolt", ydl_unit)
    call GroupAddUnit(dwz, ydl_unit)
    if GetRandomInt(1, 2) == 1 then
    set zfc="908196484.mdx"
    else
    set zfc="impact" + I2S(GetRandomInt(1, 2)) + ".mdx"
    endif
    set tx2=AddSpecialEffect(zfc, GetUnitX(ydl_unit), GetUnitY(ydl_unit)) //星见雅受击特效
    call EXEffectMatRotateZ(tx2 , ( ( 25.00 ) * ( I2R(GetRandomInt(1, 14)) ) )) //角度
    call EXSetEffectSize(tx2 , ( GetRandomReal(0.6, 0.8) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.40 ) )) //大小
    call EXSetEffectSpeed(tx2 , GetRandomReal(1.5, 2)) //特效动画速度
    call EXSetEffectZ(tx2 , ( EXGetEffectZ(tx2) + ( GetUnitFlyHeight(ydl_unit) + 50 ) )) //高度
    call DestroyEffect(tx2)
    if IsUnitType(ydl_unit, UNIT_TYPE_HERO) == true then
    set tx2=AddSpecialEffect("-850098650.mdx", GetUnitX(ydl_unit), GetUnitY(ydl_unit)) //受击刀光粒子特效
    call EXEffectMatRotateY(tx2 , - 10 * I2R(GetRandomInt(0, 18))) //角度
    call EXEffectMatRotateZ(tx2 , - 25 * I2R(GetRandomInt(1, 14))) //角度
    call EXSetEffectSize(tx2 , ( GetRandomReal(0.2, 0.4) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.10 ) )) //大小
    call EXSetEffectSpeed(tx2 , GetRandomReal(1.4, 2)) //特效动画速度
    call EXSetEffectZ(tx2 , ( EXGetEffectZ(tx2) + ( GetUnitFlyHeight(ydl_unit) + GetRandomReal(40, 75) ) )) //高度
    call DestroyEffect(tx2)
    endif
    endif
    endloop
    call DestroyGroup(ydl_group)
    endif
    if time >= 0.9 and time <= 1.02 then
    set jd3=jd
    //直线刀光
    set zfc="1956614739.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 2.5 * I2R(GetRandomInt(1, 3))) //角度
    call EXEffectMatRotateZ(tx , jd3 + 30) //角度
    call EXSetEffectSize(tx , 2) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.4, 1.5)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(50, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(40) + 0x100 * PercentTo255(100) + PercentTo255(80))
    call DestroyEffect(tx)
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 2.5 * I2R(GetRandomInt(1, 3))) //角度
    call EXEffectMatRotateZ(tx , jd3 - 30) //角度
    call EXSetEffectSize(tx , 2) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.4, 1.5)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(50, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(40) + 0x100 * PercentTo255(100) + PercentTo255(80))
    call DestroyEffect(tx)
    if ModuloReal(time, 0.04) == 0.04 then
    //旋转刀光3
    set zfc="-173761042.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    if ModuloReal(time, 0.08) == 0.08 then
    call EXEffectMatRotateY(tx , - 180 - 5 * I2R(GetRandomInt(1, 3))) //角度
    call EXEffectMatRotateZ(tx , jd3 + 90 - 5 * I2R(GetRandomInt(1, 5))) //角度
    else
    call EXEffectMatRotateY(tx , - 5 * I2R(GetRandomInt(1, 3))) //角度
    call EXEffectMatRotateZ(tx , jd3 - 180 - 5 * I2R(GetRandomInt(1, 5))) //角度
    endif
    call EXSetEffectSize(tx , GetRandomReal(1.2, 1.5)) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.8, 2)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(100, 200) )) //高度
    call DestroyEffect(tx)
    //风格化气浪特效
    set zfc="117448227.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateX(tx , - 20 * I2R(GetRandomInt(0, 18)))
    call EXEffectMatRotateZ(tx , jd + 4 * I2R(GetRandomInt(- 5, 5))) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.5)) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(4, 6)) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(50, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(90, 95)) + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(100))
    call DestroyEffect(tx)
    //风格化气浪特效3
    set zfc="1577588603.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 2 * I2R(GetRandomInt(0, 9)))
    call EXEffectMatRotateZ(tx , jd + 4 * I2R(GetRandomInt(- 5, 5))) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1.2, 1.7)) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(2, 3)) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(0, 30) )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(GetRandomReal(90, 95)) + 0x10000 * PercentTo255(80) + 0x100 * PercentTo255(80) + PercentTo255(80))
    call DestroyEffect(tx)
    //蓝青色地面气场特效
    set zfc="869602743.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 90) //角度
    call EXEffectMatRotateZ(tx , jd3 + 4 * I2R(GetRandomInt(- 5, 5))) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.2)) //动画速度
    call EXSetEffectSize(tx , GetRandomReal(1, 1.25)) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 25 )) //高度
    call SetPariticle2Size(tx , GetRandomReal(1, 1.25)) //内置api调大小
    call DestroyEffect(tx)
    endif
    set jd3=jd - GetRandomReal(80, 100)
    set sjss=GetRandomInt(250, 300)
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    //直线刀光
    set zfc="-1413746522.mdx"
    set zfc="1956614739.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 2.5 * I2R(GetRandomInt(32, 36))) //角度
    call EXEffectMatRotateZ(tx , GetRandomReal(0, 360)) //角度
    call EXSetEffectSize(tx , GetRandomReal(2, 2.5)) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.2, 1.5)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(50, 100) )) //高度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(20) + 0x100 * PercentTo255(GetRandomReal(80, 90)) + PercentTo255(GetRandomReal(60, 80)))
    call DestroyEffect(tx)
    set jd3=jd + GetRandomReal(80, 100)
    set sjss=GetRandomInt(250, 300)
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    //直线刀光
    set zfc="-1413746522.mdx"
    set zfc="1956614739.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 2.5 * I2R(GetRandomInt(32, 36))) //角度
    call EXEffectMatRotateZ(tx , GetRandomReal(0, 360)) //角度
    call EXSetEffectSize(tx , GetRandomReal(2, 2.5)) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.2, 1.5)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(50, 100) )) //高度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(20) + 0x100 * PercentTo255(GetRandomReal(80, 90)) + PercentTo255(GetRandomReal(60, 80)))
    call DestroyEffect(tx)
    set ydl_group=CreateGroup() //造成伤害dwz
    call GroupEnumUnitsInRange(ydl_group, x, y, 300.00, null)
    loop
    set ydl_unit=FirstOfGroup(ydl_group)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(ydl_group, ydl_unit)
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 1 ) and ( IsUnitEnemy(ydl_unit, wj) == true ) ) then // INLINED!!
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) ) then // INLINED!!
    call mh_zzfycfxt1(ydl_unit , null , 0)
    endif
    if (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 3 then // INLINED!!
    call mh_zzfycfxt1(dw , null , 0)
    call SaveInteger(hsb, jsqid, StringHash("中止判断"), 1)
    endif
    endif
    if mh_tjfz1(ydl_unit , wj) == true then //位移
    set x3=GetUnitX(ydl_unit) //位移
    set y3=GetUnitY(ydl_unit)
    set sz=GetRandomReal(40, 80)
    if ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 15, 15)) == 0) == false ) then // INLINED!!
    set sz=sz * 0.05
    set pd=1
    call SaveInteger(hsb, jsqid, StringHash("判断"), pd)
    endif
    set jd3=jd
    set x3=( x3 + sz * CosBJ(jd3) )
    set y3=( y3 + sz * SinBJ(jd3) )
    call SetUnitX(ydl_unit, x3)
    call SetUnitY(ydl_unit, y3)
    endif
    //查询防御状态和是否拥有无法选取 以及通用的选取条件  不判断重复
    if ( ( IsUnitEnemy(ydl_unit, wj) == true ) and ( GetUnitPointValue(ydl_unit) != 233 ) and ( mh_tjfz6(ydl_unit , 0) == true ) and ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) and ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 3, 3)) == 0) == true ) and ( IsUnitType(ydl_unit, UNIT_TYPE_DEAD) == false ) ) and IsUnitInGroup(ydl_unit, dwz) == false then // INLINED!!
    //英雄攻击类型 强化伤害类型
    call mh_sh1(dw , ydl_unit , sh2 , 4 , 0 , true , false , ATTACK_TYPE_HERO , DAMAGE_TYPE_ENHANCED , WEAPON_TYPE_WHOKNOWS)
    call IssueTargetOrder(mj3, "thunderbolt", ydl_unit)
    call GroupAddUnit(dwz, ydl_unit)
    if GetRandomInt(1, 2) == 1 then
    set zfc="908196484.mdx"
    else
    set zfc="impact" + I2S(GetRandomInt(1, 2)) + ".mdx"
    endif
    set tx2=AddSpecialEffect(zfc, GetUnitX(ydl_unit), GetUnitY(ydl_unit)) //星见雅受击特效
    call EXEffectMatRotateZ(tx2 , ( ( 25.00 ) * ( I2R(GetRandomInt(1, 14)) ) )) //角度
    call EXSetEffectSize(tx2 , ( GetRandomReal(0.6, 0.8) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.40 ) )) //大小
    call EXSetEffectSpeed(tx2 , GetRandomReal(1.5, 2)) //特效动画速度
    call EXSetEffectZ(tx2 , ( EXGetEffectZ(tx2) + ( GetUnitFlyHeight(ydl_unit) + 50 ) )) //高度
    call DestroyEffect(tx2)
    if IsUnitType(ydl_unit, UNIT_TYPE_HERO) == true then
    set tx2=AddSpecialEffect("-850098650.mdx", GetUnitX(ydl_unit), GetUnitY(ydl_unit)) //受击刀光粒子特效
    call EXEffectMatRotateY(tx2 , - 10 * I2R(GetRandomInt(0, 18))) //角度
    call EXEffectMatRotateZ(tx2 , - 25 * I2R(GetRandomInt(1, 14))) //角度
    call EXSetEffectSize(tx2 , ( GetRandomReal(0.2, 0.4) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.10 ) )) //大小
    call EXSetEffectSpeed(tx2 , GetRandomReal(1.4, 2)) //特效动画速度
    call EXSetEffectZ(tx2 , ( EXGetEffectZ(tx2) + ( GetUnitFlyHeight(ydl_unit) + GetRandomReal(40, 75) ) )) //高度
    call DestroyEffect(tx2)
    endif
    endif
    endloop
    call DestroyGroup(ydl_group)
    endif
    endif
    if time >= 1.2 or IsUnitType(dw, UNIT_TYPE_DEAD) == true or zzpd == 1 then //代码结束
    if IsUnitType(dw, UNIT_TYPE_DEAD) == true or zzpd == 1 then
    endif
    call RemoveUnit(mj)
    call RemoveUnit(mj3)
    call GroupClear(dwz)
    call DestroyGroup(dwz)
    set a=0
    loop
    call DestroyEffect(tstx[a])
    set a=a + 1
    exitwhen a >= 3
    endloop
    call FlushChildHashtable(hsb, jsqid)
    call DestroyTimer(GetExpiredTimer())
    endif
    endif
    set dw=null
    set mj=null
    set mj3=null
    set wj=null
    set jsq2=null
    set tx=null
    set tx2=null
    set zfc=null
    set dwz=null
    set ydl_group=null
    set ydl_unit=null
    set a=0
    loop
    set tstx[a]=null
    set a=a + 1
    exitwhen a >= 3
    endloop
    endfunction
    function Trig_J_Firefly____________008Actions takes nothing returns nothing
    local timer jsq= CreateTimer()
    local integer jsqid= GetHandleId(jsq)
    local unit dw= udg_wndanwei_jndw[1]
    local unit mj
    local player wj= GetOwningPlayer(dw)
    local real x= GetUnitX(dw)
    local real y= GetUnitY(dw)
    local real x2= udg_wnshishu_shishu[0]
    local real y2= udg_wnshishu_shishu[1]
    local real jd= Atan2BJ(( y2 - y ), ( x2 - x ))
    local integer array dz
    local real array dzsd
    call IssueImmediateOrder(dw, "stop")
    set mj=CreateUnit(wj, 'e002', x, y, 0) //施法控制马甲
    call UnitAddAbility(mj, 'A00F') //技能释放中
    call IssueTargetOrder(mj, "magicleash", dw)
    call SaveUnitHandle(hsb, jsqid, StringHash("mj"), mj)
    call mh_buffkq(dw , 0.5 , 2 , 1) //假无敌
    // if (GetUnitTypeId(dw) == 'O00U') then
    set dz[1]=5
    set dz[2]=8
    set dz[3]=9
    set dzsd[1]=4
    set dzsd[2]=2.5
    set dzsd[3]=2.5
    // endif
    //保存数据准备开始代码
    call SaveUnitHandle(hsb, jsqid, StringHash("dw"), dw)
    call SavePlayerHandle(hsb, jsqid, StringHash("wj"), wj)
    call SaveReal(hsb, jsqid, StringHash("x"), x)
    call SaveReal(hsb, jsqid, StringHash("y"), y)
    call SaveReal(hsb, jsqid, StringHash("x2"), x2)
    call SaveReal(hsb, jsqid, StringHash("y2"), y2)
    call SaveReal(hsb, jsqid, StringHash("jd"), jd)
    call SaveInteger(hsb, jsqid, StringHash("jnzs2"), 0)
    if GetRandomInt(1, 2) == 1 then
    call SaveSoundHandle(hsb, jsqid, StringHash("语音1"), gg_snd_mh_Firefly_jn201)
    else
    call SaveSoundHandle(hsb, jsqid, StringHash("语音1"), gg_snd_mh_Firefly_ready4)
    endif
    call SaveInteger(hsb, jsqid, StringHash("开头动作1"), dz[1])
    call SaveInteger(hsb, jsqid, StringHash("开头动作2"), dz[2])
    call SaveInteger(hsb, jsqid, StringHash("开头动作3"), dz[3])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度1"), dzsd[1])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度2"), dzsd[2])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度3"), dzsd[3])
    call SaveStr(hsb, jsqid, StringHash("音效1"), "mh_Firefly_Attack1.mp3")
    call SaveStr(hsb, jsqid, StringHash("音效2"), "mh_Firefly_Attack2.mp3")
    call SaveStr(hsb, jsqid, StringHash("音效3"), "mh_Firefly_Attack3.mp3")
    call SaveStr(hsb, jsqid, StringHash("音效4"), "mh_Firefly_Attack4.mp3")
    call SaveStr(hsb, jsqid, StringHash("音效5"), "mh_Firefly_Attack5.mp3")
    call SaveGroupHandle(hsb, jsqid, StringHash("dwz"), CreateGroup())
    call SaveStr(hsb, jsqid, StringHash("模型"), ( EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(dw)) + "].file") ))
    call SaveReal(hsb, jsqid, StringHash("模型大小"), S2R(( EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(dw)) + "].modelScale") )))
    call TimerStart(jsq, 0.02, TRUE, function Trig_J_Firefly____________008jn2) //开始执行
    set jsq=null
    set dw=null
    set mj=null
    set wj=null
    endfunction
    //===========================================================================
    function InitTrig_J_Firefly____________008 takes nothing returns nothing
    set gg_trg_J_Firefly____________008=CreateTrigger()
    call TriggerAddAction(gg_trg_J_Firefly____________008, function Trig_J_Firefly____________008Actions)
    endfunction
    //TESH.scrollpos=735
    //TESH.alwaysfold=0
    //===========================================================================
    // Trigger: J-Firefly萨姆三连009
    //===========================================================================
    function Trig_J_Firefly____________009jn2 takes nothing returns nothing
    local timer jsq2
    local integer jsq2id
    local integer a= 0
    local integer jsqid= GetHandleId(GetExpiredTimer())
    local unit dw= LoadUnitHandle(hsb, jsqid, StringHash("dw"))
    local unit dw2= LoadUnitHandle(hsb, jsqid, StringHash("dw2"))
    local player wj= LoadPlayerHandle(hsb, jsqid, StringHash("wj"))
    local real x= LoadReal(hsb, jsqid, StringHash("x"))
    local real y= LoadReal(hsb, jsqid, StringHash("y"))
    local real x2= LoadReal(hsb, jsqid, StringHash("x2"))
    local real y2= LoadReal(hsb, jsqid, StringHash("y2"))
    local real jd= LoadReal(hsb, jsqid, StringHash("jd"))
    local string zfc
    local effect tx
    local effect tx2
    local real time= LoadReal(hsb, jsqid, StringHash("逝去时间"))
    
    local group ydl_group
    local group dwz= LoadGroupHandle(hsb, jsqid, StringHash("dwz"))
    local unit ydl_unit
    local unit mj= LoadUnitHandle(hsb, jsqid, StringHash("mj"))
    local unit mj3= LoadUnitHandle(hsb, jsqid, StringHash("mj3"))
    local real jd2= LoadReal(hsb, jsqid, StringHash("jd2"))
    local real jd3= LoadReal(hsb, jsqid, StringHash("jd3"))
    local real sd= LoadReal(hsb, jsqid, StringHash("速度"))
    local real gd= LoadReal(hsb, jsqid, StringHash("高度"))
    local real gdsd= LoadReal(hsb, jsqid, StringHash("高度速度"))
    local real sjss= 0
    local real sz= 0
    local integer pd= LoadInteger(hsb, jsqid, StringHash("判断"))
    local integer zzpd= LoadInteger(hsb, jsqid, StringHash("中止判断"))
    local integer dz1= LoadInteger(hsb, jsqid, StringHash("开头动作1"))
    local integer dz2= LoadInteger(hsb, jsqid, StringHash("开头动作2"))
    local integer dz3= LoadInteger(hsb, jsqid, StringHash("开头动作3"))
    local integer dz4= LoadInteger(hsb, jsqid, StringHash("开头动作4"))
    local real dzsd1= LoadReal(hsb, jsqid, StringHash("开头动作动画速度1"))
    local real dzsd2= LoadReal(hsb, jsqid, StringHash("开头动作动画速度2"))
    local real dzsd3= LoadReal(hsb, jsqid, StringHash("开头动作动画速度3"))
    local real dzsd4= LoadReal(hsb, jsqid, StringHash("开头动作动画速度4"))
    local real sh1= LoadReal(hsb, jsqid, StringHash("伤害"))
    local real sh2= LoadReal(hsb, jsqid, StringHash("伤害2"))
    local real x3= 0
    local real y3= 0
    local real x4= 0
    local real y4= 0
    local integer jnzs= LoadInteger(hsb, jsqid, StringHash("jnzs"))
    local integer jnzs2= LoadInteger(hsb, jsqid, StringHash("jnzs2"))
    local effect array tstx
    set a=0
    loop
    set tstx[a]=LoadEffectHandle(hsb, jsqid, StringHash("特效" + I2S(a)))
    set a=a + 1
    exitwhen a >= 10
    endloop
    if mh_stpd2(dw) == 0 then //判断该单位是否处于时停
    set time=time + 0.02
    call SaveReal(hsb, jsqid, StringHash("逝去时间"), time)
    if ( GetUnitAbilityLevel(udg_danwei_WJ_ysjgnfz[GetConvertedPlayerId(wj)], 'A0TW') >= 1 ) and dw2 != null and IsUnitType(dw2, UNIT_TYPE_DEAD) == false and time <= 1.6 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set x2=GetUnitX(dw2)
    set y2=GetUnitY(dw2)
    set jd=Atan2BJ(( y2 - y ), ( x2 - x ))
    call SaveReal(hsb, jsqid, StringHash("jd"), jd)
    call SetUnitFacingTimed(dw, jd, 0)
    call EXSetUnitFacing(dw , jd)
    endif
    if time == 0.02 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set jd3=jd
    set sjss=200
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    set mj3=CreateUnit(wj, 'e002', x, y, 0) //全能技能马甲zhan
    call UnitAddAbility(mj3, 'A00J') //眩晕1s
    call SaveUnitHandle(hsb, jsqid, StringHash("mj3"), mj3)
    call SetUnitAnimationByIndex(dw, dz1)
    call SetUnitTimeScale(dw, dzsd1)
    call UnitAddAbility(dw, 'Amrf')
    call UnitRemoveAbility(dw, 'Amrf')
    call SetUnitFlyHeight(dw, 0.00, 0.00)
    set sh1=( 75.00 + ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, dw, true)) * 1 ) )
    set sh2=( 75.00 + ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, dw, true)) * 4 ) )
    set sjss=1
    if ( ( GetUnitAbilityLevel(dw, 'A0TK') >= 1 ) ) then
    set sjss=sjss + 0.1
    endif
    if ( GetUnitAbilityLevel(udg_danwei_WJ_ysjgnfz[GetConvertedPlayerId(wj)], 'A0TV') >= 1 ) then
    set sjss=sjss + 0.08
    endif
    set sh1=sh1 * sjss
    set sh2=sh2 * sjss
    call SaveReal(hsb, jsqid, StringHash("伤害"), sh1)
    call SaveReal(hsb, jsqid, StringHash("伤害2"), sh2)
    call PlaySoundOnUnitBJ(LoadSoundHandle(hsb, jsqid, StringHash("语音" + I2S(1))), 100, dw) //语音
    //冲刺沙尘特效
    set zfc="tx-smoke1.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , GetRandomReal(1.2, 1.5)) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.25)) //动画速度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(50) + 0x100 * PercentTo255(100) + PercentTo255(80))
    call DestroyEffect(tx)
    //气场特效1
    set zfc="117448227.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateY(tx , - 90) //角度
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 3) //大小
    call EXSetEffectSpeed(tx , 1.2) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 10.00 )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(40) + 0x10000 * PercentTo255(80) + 0x100 * PercentTo255(80) + PercentTo255(80))
    call DestroyEffect(tx)
    //风格化气浪特效2
    set zfc="894093513.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 90)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(1.2, 1.5)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(50, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(85) + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(100))
    call DestroyEffect(tx)
    endif
    if time == 0.2 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call dsound("mh_Firefly_form2_jn1.mp3" , dw)
    //刀光斩击特效
    set zfc="-173761042.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 220)
    call EXEffectMatRotateZ(tx , jd - 90) //角度
    call EXSetEffectSpeed(tx , 3) //动画速度
    call EXSetEffectSize(tx , 2.4) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 350 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(0)), tx)
    set sjss=400
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    //直线刀光斩击特效
    set zfc="-1839660434.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateX(tx , - 70)
    call EXEffectMatRotateZ(tx , jd + 180) //角度
    call EXSetEffectSpeed(tx , 1.5) //动画速度
    call EXSetEffectSize(tx , 1.5) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 100 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(1)), tx)
    //刀光斩击特效气息
    set zfc="-1770500848.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateX(tx , - 70)
    call EXEffectMatRotateZ(tx , jd + 180) //角度
    call EXSetEffectSpeed(tx , 1.5) //动画速度
    call EXSetEffectSize(tx , 1.5) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 100 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(2)), tx)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 20)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.1, false, function mh__jtzdhs1)
    endif
    if time == 0.26 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set jd3=jd
    set sjss=200
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    call SetUnitTimeScale(dw, dzsd2)
    //刀光斩击特效
    set zfc="-173761042.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd + 200) //角度
    call EXSetEffectSpeed(tx , 2.2) //动画速度
    call EXSetEffectSize(tx , 2.4) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 200 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(3)), tx)
    set sjss=400
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    //直线刀光斩击特效
    set zfc="-1413746522.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateX(tx , - 5)
    call EXEffectMatRotateZ(tx , jd + 180) //角度
    call EXSetEffectSpeed(tx , 1.5) //动画速度
    call EXSetEffectSize(tx , 1) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 200 )) //高度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(20) + 0x100 * PercentTo255(60) + PercentTo255(80))
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(4)), tx)
    //刀光斩击特效气息
    set zfc="-1770500848.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateX(tx , - 5)
    call EXEffectMatRotateZ(tx , jd + 180) //角度
    call EXSetEffectSpeed(tx , 1.5) //动画速度
    call EXSetEffectSize(tx , 1.5) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 100 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(5)), tx)
    endif
    if time == 0.34 or time == 0.72 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call SetUnitTimeScale(dw, 0.5)
    //冲刺沙尘特效
    set zfc="tx-smoke1.mdl"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , GetRandomReal(1.2, 1.5)) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1, 1.25)) //动画速度
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(50) + 0x100 * PercentTo255(100) + PercentTo255(80))
    call DestroyEffect(tx)
    //风格化气浪特效2
    set zfc="894093513.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 90)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , GetRandomReal(1.2, 1.5)) //大小
    call EXSetEffectSpeed(tx , GetRandomReal(1.2, 1.5)) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetRandomReal(50, 200) )) //高度
    call EXSetEffectColor(tx , 0xff000000 * PercentTo255(85) + 0x10000 * PercentTo255(50) + 0x100 * PercentTo255(100) + PercentTo255(80))
    call DestroyEffect(tx)
    call SaveInteger(hsb, jsqid, StringHash("判断"), 0)
    endif
    if time == 0.58 or time == 0.7 or time == 1 then
    set a=0
    loop
    call DestroyEffect(tstx[a])
    set a=a + 1
    exitwhen a >= 5
    endloop
    endif
    if time == 0.6 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set jd3=jd
    set sjss=200
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    call SetUnitTimeScale(dw, 1)
    call GroupClear(dwz)
    //刀光斩击特效
    set zfc="-173761042.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , 45)
    call EXEffectMatRotateZ(tx , jd + 180) //角度
    call EXSetEffectSpeed(tx , 2.5) //动画速度
    call EXSetEffectSize(tx , 2.4) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 350 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(0)), tx)
    set sjss=400
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    //直线刀光斩击特效
    set zfc="-1839660434.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateX(tx , - 45)
    call EXEffectMatRotateZ(tx , jd + 0) //角度
    call EXSetEffectSpeed(tx , 1.2) //动画速度
    call EXSetEffectSize(tx , 1.5) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 100 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(1)), tx)
    //刀光斩击特效气息
    set zfc="-1770500848.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateX(tx , - 45)
    call EXEffectMatRotateZ(tx , jd + 0) //角度
    call EXSetEffectSpeed(tx , 1.2) //动画速度
    call EXSetEffectSize(tx , 1.8) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 100 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(2)), tx)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 30)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.2, false, function mh__jtzdhs1)
    endif
    if time == 0.66 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set jd3=jd
    set sjss=400
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    //直线刀光斩击特效
    set zfc="-1839660434.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateX(tx , - 80)
    call EXEffectMatRotateZ(tx , jd + 0) //角度
    call EXSetEffectSize(tx , 1.4) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 200 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(5)), tx)
    //刀光斩击特效气息
    set zfc="-1770500848.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateX(tx , - 80)
    call EXEffectMatRotateZ(tx , jd + 0) //角度
    call EXSetEffectSize(tx , 2) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 100 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(4)), tx)
    endif
    if time == 0.8 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    call GroupClear(dwz)
    call SetUnitTimeScale(dw, 1)
    //刀光斩击特效
    set zfc="-173761042.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , 75)
    call EXEffectMatRotateZ(tx , jd + 90) //角度
    call EXSetEffectSpeed(tx , 2) //动画速度
    call EXSetEffectSize(tx , 2.4) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 350 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(0)), tx)
    set jd3=jd
    set sjss=400
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    //直线刀光斩击特效
    set zfc="-1839660434.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateX(tx , - 80)
    call EXEffectMatRotateZ(tx , jd + 0) //角度
    call EXSetEffectSize(tx , 1.4) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 200 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(5)), tx)
    //刀光斩击特效气息
    set zfc="-1770500848.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateX(tx , - 80)
    call EXEffectMatRotateZ(tx , jd + 0) //角度
    call EXSetEffectSize(tx , 2) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 100 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(4)), tx)
    endif
    if time == 1.0 then
    call SetUnitTimeScale(dw, 0.1)
    call SetUnitFlyHeight(dw, GetUnitFlyHeight(dw) + 300, 3000)
    call SaveInteger(hsb, jsqid, StringHash("判断"), 0)
    endif
    if time == 1.2 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    //蓄力特效
    set zfc="-950557588.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXSetEffectSize(tx , 4) //大小
    call SetPariticle2Size(tx , 4) //内置api调大小
    call EXSetEffectSpeed(tx , 2) //动画速度
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 450 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(3)), tx)
    endif
    if time == 1.4 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set jd3=jd + 170
    set sjss=20
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    //直线刀光斩击特效
    set zfc="1581201338.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(90) + PercentTo255(40))
    call EXEffectMatRotateZ(tx , 90) //角度
    call EXSetEffectSpeed(tx , 2) //动画速度
    call EXSetEffectSize(tx , 2) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 450 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(0)), tx)
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(90) + PercentTo255(40))
    call EXEffectMatRotateX(tx , - 90) //角度
    call EXSetEffectSpeed(tx , 2) //动画速度
    call EXSetEffectSize(tx , 2) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + GetUnitFlyHeight(dw) + 500 )) //高度
    call SaveEffectHandle(hsb, jsqid, StringHash("特效" + I2S(1)), tx)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 30)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.08, false, function mh__jtzdhs1)
    endif
    if time == 1.56 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set jd3=jd
    set sjss=600
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    call SetUnitTimeScale(dw, 2)
    call SetUnitFlyHeight(dw, GetUnitFlyHeight(dw) - 300, 4000)
    //刀光斩击特效
    set zfc="-173761042.mdx"
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 200)
    call EXEffectMatRotateZ(tx , jd - 90) //角度
    call EXSetEffectSpeed(tx , 1.6) //动画速度
    call EXSetEffectSize(tx , 2.6) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 350 )) //高度
    call DestroyEffect(tx)
    set tx=AddSpecialEffect(zfc, x, y)
    call EXEffectMatRotateY(tx , - 340)
    call EXEffectMatRotateZ(tx , jd - 90) //角度
    call EXSetEffectSpeed(tx , 1.6) //动画速度
    call EXSetEffectSize(tx , 2.6) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 350 )) //高度
    call DestroyEffect(tx)
    endif
    if time == 1.6 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set jd3=jd
    set x=( x + 200 * CosBJ(jd3) )
    set y=( y + 200 * SinBJ(jd3) )
    set sjss=400
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    call SetUnitX(dw, x)
    call SetUnitY(dw, y)
    call GroupClear(dwz)
    //蓝青色地面气场特效
    set zfc="869602743.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateZ(tx , jd3 + 4 * I2R(GetRandomInt(- 5, 5))) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(0.75, 1)) //动画速度
    call EXSetEffectSize(tx , 2) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 10 )) //高度
    call SetPariticle2Size(tx , 2.5) //内置api调大小
    call DestroyEffect(tx)
    //蓝青色地面气场特效
    set zfc="1996579960.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateZ(tx , jd3 + 4 * I2R(GetRandomInt(- 5, 5))) //角度
    call EXSetEffectSpeed(tx , GetRandomReal(0.75, 1)) //动画速度
    call EXSetEffectSize(tx , 3) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 10 )) //高度
    call SetPariticle2Size(tx , 3) //内置api调大小
    call DestroyEffect(tx)
    //X字刀光特效
    set zfc="1022987242.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 2) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 300 )) //高度
    call DestroyEffect(tx)
    //中心受击刀光
    effect
    set zfc="908196484.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSize(tx , 2) //大小
    call SetPariticle2Size(tx , 2) //内置api调大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 300 )) //高度
    call DestroyEffect(tx)
    //中心受击刀光
    set zfc="-1307095562.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSpeed(tx , 0.5) //动画速度
    call EXSetEffectSize(tx , 2) //大小
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 300 )) //高度
    call DestroyEffect(tx)
    //镜头抖动
    call CameraSetEQNoiseForPlayer(wj, 50)
    set jsq2=CreateTimer()
    set jsq2id=GetHandleId(jsq2)
    call SavePlayerHandle(hsb, jsq2id, StringHash("wj"), wj)
    call TimerStart(jsq2, 0.3, false, function mh__jtzdhs1)
    endif
    if time == 1.66 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set jd3=jd
    set sjss=400
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    call SetUnitTimeScale(dw, 1)
    //中心受击刀光
    set zfc="1581201338.mdx"
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateX(tx , - 20) //角度
    call EXEffectMatRotateZ(tx , jd) //角度
    call EXSetEffectSpeed(tx , 0.6) //动画速度
    call EXSetEffectSize(tx , 3.5) //大小
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(20) + 0x100 * PercentTo255(90) + PercentTo255(60))
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 300 )) //高度
    call DestroyEffect(tx)
    set tx=AddSpecialEffect(zfc, x3, y3)
    call EXEffectMatRotateX(tx , - 20) //角度
    call EXEffectMatRotateZ(tx , jd + 180) //角度
    call EXSetEffectSpeed(tx , 0.6) //动画速度
    call EXSetEffectSize(tx , 3.5) //大小
    call EXSetEffectColor(tx , 0xff000000 + 0x10000 * PercentTo255(20) + 0x100 * PercentTo255(90) + PercentTo255(60))
    call EXSetEffectZ(tx , ( EXGetEffectZ(tx) + 300 )) //高度
    call DestroyEffect(tx)
    endif
    if time >= 1.6 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set jd3=jd
    set sjss=10
    set x=( x + sjss * CosBJ(jd3) )
    set y=( y + sjss * SinBJ(jd3) )
    call SetUnitX(dw, x)
    call SetUnitY(dw, y)
    set jd3=jd
    set sjss=300
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    set ydl_group=CreateGroup() //造成伤害
    call GroupEnumUnitsInRange(ydl_group, x3, y3, 500, null)
    set sz=150
    loop
    set ydl_unit=FirstOfGroup(ydl_group)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(ydl_group, ydl_unit)
    if mh_tjfz1(ydl_unit , wj) == true then //存活 敌人
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 1 ) and ( IsUnitEnemy(ydl_unit, wj) == true ) ) then // INLINED!!
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 4 ) ) then // INLINED!!
    call mh_zzfycfxt1(ydl_unit , null , 0)
    endif
    endif
    //查询防御状态和是否拥有无法选取 以及通用的选取条件
    if ( ( GetUnitPointValue(ydl_unit) != 233 ) and ( mh_tjfz6(ydl_unit , 0) == true ) and ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 4 ) and ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 3, 3)) == 0) == true ) ) then // INLINED!!
    //英雄攻击类型 强化伤害类型
    call mh_sh1(dw , ydl_unit , sh2 , 4 , 0 , true , false , ATTACK_TYPE_HERO , DAMAGE_TYPE_ENHANCED , WEAPON_TYPE_WHOKNOWS)
    call IssueTargetOrder(mj3, "thunderbolt", ydl_unit)
    if time >= 1.66 then
    set x4=GetUnitX(ydl_unit) //位移
    set y4=GetUnitY(ydl_unit)
    set jd3=jd
    set x4=( x4 + sz * CosBJ(jd3) )
    set y4=( y4 + sz * SinBJ(jd3) )
    call SetUnitX(ydl_unit, x4)
    call SetUnitY(ydl_unit, y4)
    endif
    set zfc="908196484.mdx"
    set tx2=AddSpecialEffect(zfc, GetUnitX(ydl_unit), GetUnitY(ydl_unit)) //受击特效
    call EXEffectMatRotateZ(tx2 , ( ( 25.00 ) * ( I2R(GetRandomInt(1, 14)) ) )) //角度
    call EXSetEffectSize(tx2 , ( GetRandomReal(0.3, 0.5) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.3 ) )) //大小
    call EXSetEffectSpeed(tx2 , GetRandomReal(1.5, 2)) //特效动画速度
    call EXSetEffectZ(tx2 , ( EXGetEffectZ(tx2) + ( GetUnitFlyHeight(ydl_unit) + 50 ) )) //高度
    call DestroyEffect(tx2)
    if IsUnitType(ydl_unit, UNIT_TYPE_HERO) == true then
    set tx2=AddSpecialEffect("Suzakuin-17-white2.mdl", GetUnitX(ydl_unit), GetUnitY(ydl_unit)) //受击刀光粒子特效
    call EXEffectMatRotateY(tx2 , - 10 * I2R(GetRandomInt(0, 18))) //角度
    call EXEffectMatRotateZ(tx2 , - 25 * I2R(GetRandomInt(1, 14))) //角度
    call EXSetEffectSize(tx2 , ( GetRandomReal(0.3, 0.5) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.10 ) )) //大小
    call EXSetEffectSpeed(tx2 , GetRandomReal(1, 1.5)) //特效动画速度
    call EXSetEffectZ(tx2 , ( EXGetEffectZ(tx2) + ( GetUnitFlyHeight(ydl_unit) + GetRandomReal(40, 75) ) )) //高度
    call DestroyEffect(tx2)
    endif
    set udg_wndanwei_jndw[1]=dw
    set udg_wndanwei_jndw[2]=ydl_unit
    set udg_wnzhengshu__zs[1]=4
    set udg_wnzhengshu__zs[2]=100
    call TriggerExecute(gg_trg_J_Firefly____________000_fz)
    endif
    endif
    endloop
    call DestroyGroup(ydl_group)
    endif
    if time >= 0 and time <= 1.58 then
    set x=GetUnitX(dw)
    set y=GetUnitY(dw)
    set sjss=5
    if time <= 0.2 or ( time >= 0.34 and time <= 0.6 ) or ( time >= 0.72 and time <= 0.96 ) then
    set jd3=jd
    if time <= 0.2 then
    set sjss=RMaxBJ(( 80 - ( ( time - 0 ) * 300.00 ) ), 4.00)
    elseif ( time >= 0.34 and time <= 0.6 ) then
    set sjss=RMaxBJ(( 80 - ( ( time - 0.34 ) * 300.00 ) ), 4.00)
    else
    set sjss=RMaxBJ(( 70 - ( ( time - 0.72 ) * 300.00 ) ), 4.00)
    endif
    if pd == 1 then
    set sjss=sjss * 0.1
    endif
    set x=( x + sjss * CosBJ(jd3) )
    set y=( y + sjss * SinBJ(jd3) )
    if mh_jcdwxy(x , y) == true then
    call SetUnitX(dw, x)
    call SetUnitY(dw, y)
    endif
    endif
    set ydl_group=CreateGroup() //造成伤害
    set sz=300
    set sjss=sjss
    if ( ( time >= 0.2 and time <= 0.3 ) or ( time >= 0.6 and time <= 0.7 ) or ( time >= 0.72 and time <= 0.8 ) ) then
    set sz=400
    endif
    set jd3=jd
    call GroupEnumUnitsInRange(ydl_group, x, y, sz, null)
    set sz=100
    if time >= 0.6 then
    set sz=150
    endif
    loop
    set ydl_unit=FirstOfGroup(ydl_group)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(ydl_group, ydl_unit)
    if mh_tjfz1(ydl_unit , wj) == true then //存活 敌人
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 1 ) and ( IsUnitEnemy(ydl_unit, wj) == true ) ) then // INLINED!!
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 4 ) ) then // INLINED!!
    call mh_zzfycfxt1(ydl_unit , null , 0)
    endif
    endif
    if true then //位移
    set x4=GetUnitX(ydl_unit) //位移
    set y4=GetUnitY(ydl_unit)
    if ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 15, 15)) == 0) == false or IsUnitType(ydl_unit, UNIT_TYPE_HERO) == true ) then // INLINED!!
    set pd=1
    call SaveInteger(hsb, jsqid, StringHash("判断"), pd)
    endif
    set jd3=jd
    set x4=( x4 + sjss * CosBJ(jd3) )
    set y4=( y4 + sjss * SinBJ(jd3) )
    call SetUnitX(ydl_unit, x4)
    call SetUnitY(ydl_unit, y4)
    endif
    //查询防御状态和是否拥有无法选取 以及通用的选取条件
    if ( ( GetUnitPointValue(ydl_unit) != 233 ) and ( mh_tjfz6(ydl_unit , 0) == true ) and ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 4 ) and ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 3, 3)) == 0) == true ) ) and IsUnitInGroup(ydl_unit, dwz) == false and ( ( time >= 0.2 and time <= 0.3 ) or ( time >= 0.6 and time <= 0.7 ) or ( time >= 0.72 and time <= 0.8 ) ) then // INLINED!!
    //英雄攻击类型 强化伤害类型
    call mh_sh1(dw , ydl_unit , sh1 , 4 , 0 , true , false , ATTACK_TYPE_HERO , DAMAGE_TYPE_ENHANCED , WEAPON_TYPE_WHOKNOWS)
    call IssueTargetOrder(mj3, "thunderbolt", ydl_unit)
    call GroupAddUnit(dwz, ydl_unit)
    set x4=GetUnitX(ydl_unit) //位移
    set y4=GetUnitY(ydl_unit)
    set jd3=jd
    set x4=( x4 + sz * CosBJ(jd3) )
    set y4=( y4 + sz * SinBJ(jd3) )
    call SetUnitX(ydl_unit, x4)
    call SetUnitY(ydl_unit, y4)
    set zfc="908196484.mdx"
    set tx2=AddSpecialEffect(zfc, GetUnitX(ydl_unit), GetUnitY(ydl_unit)) //受击特效
    call EXEffectMatRotateZ(tx2 , ( ( 25.00 ) * ( I2R(GetRandomInt(1, 14)) ) )) //角度
    call EXSetEffectSize(tx2 , ( GetRandomReal(0.3, 0.5) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.3 ) )) //大小
    call EXSetEffectSpeed(tx2 , GetRandomReal(1.5, 2)) //特效动画速度
    call EXSetEffectZ(tx2 , ( EXGetEffectZ(tx2) + ( GetUnitFlyHeight(ydl_unit) + 50 ) )) //高度
    call DestroyEffect(tx2)
    if IsUnitType(ydl_unit, UNIT_TYPE_HERO) == true then
    set tx2=AddSpecialEffect("Suzakuin-17-white2.mdl", GetUnitX(ydl_unit), GetUnitY(ydl_unit)) //受击刀光粒子特效
    call EXEffectMatRotateY(tx2 , - 10 * I2R(GetRandomInt(0, 18))) //角度
    call EXEffectMatRotateZ(tx2 , - 25 * I2R(GetRandomInt(1, 14))) //角度
    call EXSetEffectSize(tx2 , ( GetRandomReal(0.3, 0.5) + ( S2R(EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(ydl_unit)) + "].modelScale")) * 0.10 ) )) //大小
    call EXSetEffectSpeed(tx2 , GetRandomReal(1, 1.5)) //特效动画速度
    call EXSetEffectZ(tx2 , ( EXGetEffectZ(tx2) + ( GetUnitFlyHeight(ydl_unit) + GetRandomReal(40, 75) ) )) //高度
    call DestroyEffect(tx2)
    endif
    set udg_wndanwei_jndw[1]=dw
    set udg_wndanwei_jndw[2]=ydl_unit
    set udg_wnzhengshu__zs[1]=4
    set udg_wnzhengshu__zs[2]=150
    call TriggerExecute(gg_trg_J_Firefly____________000_fz)
    endif
    endif
    endloop
    call DestroyGroup(ydl_group)
    if time >= 1.04 then
    set jd3=jd + 170
    set sjss=20
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    call EXSetEffectXY(tstx[0] , x3 , y3)
    else
    call EXSetEffectXY(tstx[0] , x , y)
    call EXSetEffectXY(tstx[3] , x , y)
    set jd3=jd
    set sjss=400
    set x3=( x + sjss * CosBJ(jd3) )
    set y3=( y + sjss * SinBJ(jd3) )
    call EXSetEffectXY(tstx[1] , x3 , y3)
    call EXSetEffectXY(tstx[2] , x3 , y3)
    call EXSetEffectXY(tstx[4] , x3 , y3)
    call EXSetEffectXY(tstx[5] , x3 , y3)
    endif
    endif
    if time >= 1.68 then //代码结束
    call RemoveUnit(mj)
    call RemoveUnit(mj3)
    call GroupClear(dwz)
    call DestroyGroup(dwz)
    set a=0
    loop
    call DestroyEffect(tstx[a])
    set a=a + 1
    exitwhen a >= 10
    endloop
    call FlushChildHashtable(hsb, jsqid)
    call DestroyTimer(GetExpiredTimer())
    endif
    endif
    set dw=null
    set dw2=null
    set mj=null
    set mj3=null
    set wj=null
    set jsq2=null
    set tx=null
    set tx2=null
    set zfc=null
    set dwz=null
    set ydl_group=null
    set ydl_unit=null
    set a=0
    loop
    set tstx[a]=null
    set a=a + 1
    exitwhen a >= 10
    endloop
    endfunction
    function Trig_J_Firefly____________009Actions takes nothing returns nothing
    local timer jsq= CreateTimer()
    local integer jsqid= GetHandleId(jsq)
    local unit dw= udg_wndanwei_jndw[1]
    local unit dw2= udg_wndanwei_jndw[2]
    local unit mj
    local player wj= GetOwningPlayer(dw)
    local real x= GetUnitX(dw)
    local real y= GetUnitY(dw)
    local real x2= udg_wnshishu_shishu[0]
    local real y2= udg_wnshishu_shishu[1]
    local real jd= Atan2BJ(( y2 - y ), ( x2 - x ))
    local integer array dz
    local real array dzsd
    call IssueImmediateOrder(dw, "stop")
    set mj=CreateUnit(wj, 'e002', x, y, 0) //施法控制马甲
    call UnitAddAbility(mj, 'A00F') //技能释放中
    call IssueTargetOrder(mj, "magicleash", dw)
    call SaveUnitHandle(hsb, jsqid, StringHash("mj"), mj)
    call mh_buffkq(dw , 1.6 , 2 , 1) //假无敌
    // if (GetUnitTypeId(dw) == 'O00U') then
    set dz[1]=2
    set dzsd[1]=2
    set dzsd[2]=1.05
    // endif
    //保存数据准备开始代码
    call SaveUnitHandle(hsb, jsqid, StringHash("dw"), dw)
    call SaveUnitHandle(hsb, jsqid, StringHash("dw2"), dw2)
    call SavePlayerHandle(hsb, jsqid, StringHash("wj"), wj)
    call SaveReal(hsb, jsqid, StringHash("x"), x)
    call SaveReal(hsb, jsqid, StringHash("y"), y)
    call SaveReal(hsb, jsqid, StringHash("x2"), x2)
    call SaveReal(hsb, jsqid, StringHash("y2"), y2)
    call SaveReal(hsb, jsqid, StringHash("jd"), jd)
    call SaveInteger(hsb, jsqid, StringHash("jnzs2"), 0)
    call SaveSoundHandle(hsb, jsqid, StringHash("语音1"), gg_snd_mh_Firefly_jn101)
    call SaveInteger(hsb, jsqid, StringHash("开头动作1"), dz[1])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度1"), dzsd[1])
    call SaveReal(hsb, jsqid, StringHash("开头动作动画速度2"), dzsd[2])
    call SaveGroupHandle(hsb, jsqid, StringHash("dwz"), CreateGroup())
    call SaveStr(hsb, jsqid, StringHash("模型"), ( EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(dw)) + "].file") ))
    call SaveReal(hsb, jsqid, StringHash("模型大小"), S2R(( EXExecuteScript("(require'jass.slk').unit[" + I2S(GetUnitTypeId(dw)) + "].modelScale") )))
    call TimerStart(jsq, 0.02, TRUE, function Trig_J_Firefly____________009jn2) //开始执行
    set jsq=null
    set dw=null
    set dw2=null
    set mj=null
    set wj=null
    endfunction
    //===========================================================================
    function InitTrig_J_Firefly____________009 takes nothing returns nothing
    set gg_trg_J_Firefly____________009=CreateTrigger()
    call TriggerAddAction(gg_trg_J_Firefly____________009, function Trig_J_Firefly____________009Actions)
    endfunction
//===========================================================================
// Trigger: J-Firefly萨姆直拳010
//===========================================================================
function Trig_J_Firefly____________010Func016Func015Func004Func006T takes nothing returns nothing
    call CameraClearNoiseForPlayer(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946))
    call FlushChildHashtable(YDLOC, GetHandleId(GetExpiredTimer()))
    call DestroyTimer(GetExpiredTimer())
    endfunction
    function Trig_J_Firefly____________010Func016Func015Func005Func015Func001Func003Func001Func001A takes nothing returns nothing
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xBA396058, GetUnitX(GetEnumUnit()))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x5F2092C7, GetUnitY(GetEnumUnit()))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xBA396058, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xBA396058) + ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x6C5E960D) * CosBJ(LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2DC94E6E)) ) ))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x5F2092C7, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x5F2092C7) + ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x6C5E960D) * SinBJ(LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2DC94E6E)) ) ))
    call SetUnitX(GetEnumUnit(), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xBA396058))
    call SetUnitY(GetEnumUnit(), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x5F2092C7))
    endfunction
    function Trig_J_Firefly____________010Func016Func015Func005Func015Func001Func003T takes nothing returns nothing
    if ( ( mh_stpd2(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)) == 0 ) ) then
    call ForGroupBJ(LoadGroupHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC7D2BDC1 + ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0xDA903C9B) )), function Trig_J_Firefly____________010Func016Func015Func005Func015Func001Func003Func001Func001A)
    else
    endif
    call GroupClear(LoadGroupHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC7D2BDC1 + ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0xDA903C9B) )))
    call DestroyGroup(LoadGroupHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC7D2BDC1 + ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0xDA903C9B) )))
    call FlushChildHashtable(YDLOC, GetHandleId(GetExpiredTimer()))
    call DestroyTimer(GetExpiredTimer())
    endfunction
    function Trig_J_Firefly____________010Func016Func015Func005Func016Func002Func014T takes nothing returns nothing
    //↓在这停顿，然后开始做透明渐隐效果↓
    call SetUnitTimeScale(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x8703EBEE), 0.00)
    call SetUnitVertexColor(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x8703EBEE), 255, 255, 255, 51)
    call mh_tm1(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x8703EBEE) , 0.3 , 0.02 , 20 , 100 , 1)
    call FlushChildHashtable(YDLOC, GetHandleId(GetExpiredTimer()))
    call DestroyTimer(GetExpiredTimer())
    endfunction
    function Trig_J_Firefly____________010Func016Func015Func006Func007Func006T takes nothing returns nothing
    call CameraClearNoiseForPlayer(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946))
    call FlushChildHashtable(YDLOC, GetHandleId(GetExpiredTimer()))
    call DestroyTimer(GetExpiredTimer())
    endfunction
    function Trig_J_Firefly____________010Func016Func015Func007Func012T takes nothing returns nothing
    call CameraClearNoiseForPlayer(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946))
    call FlushChildHashtable(YDLOC, GetHandleId(GetExpiredTimer()))
    call DestroyTimer(GetExpiredTimer())
    endfunction
    function Trig_J_Firefly____________010Func016T takes nothing returns nothing
    local timer ydl_timer
    local group ydl_group
    local unit ydl_unit
    local integer ydul_c
    call SaveInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x8B1FFFFC, ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x8B1FFFFC) + 2 ))
    if ( ( ( mh_stpd2(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC303079D)) == 0 ) ) ) then
    if ( ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x8B1FFFFC) == 2 ) ) then
    call SaveUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xE052C95B, CreateUnit(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946), 'e002', LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382), 0))
    call UnitAddAbility(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xE052C95B), 'A00J')
    call SaveInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x347419F2, 5)
    call SetUnitAnimationByIndex(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC303079D), LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x347419F2))
    call SetUnitTimeScale(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC303079D), 3.00)
    call PlaySoundOnUnitBJ(gg_snd_mh_Fireflysam_jn1_1, 100, LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2))
    call SaveStr(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D1FF186, "chun-yanji-8.mdl")
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffect(LoadStr(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D1FF186), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382)))
    call EXSetEffectSize(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 1.00)
    call SetPariticle2Size(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 2)
    call EXSetEffectColor(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 0xff000000 + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(0) + PercentTo255(0))
    call EXEffectMatRotateZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , ( ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D345649) ) - ( 180.00 ) ))
    call EXSetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , ( EXGetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6)) + 150.00 ))
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    call SaveStr(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D1FF186, "chun-yanji-13.mdl")
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffect(LoadStr(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D1FF186), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382)))
    call EXSetEffectSize(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 0.60)
    call SetPariticle2Size(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 0.6)
    call EXEffectMatRotateZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , GetRandomDirectionDeg())
    call EXSetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , ( EXGetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6)) + 150.00 ))
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x6DD3A3AB, ( 75.00 + ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2), true)) * 1.00 ) ))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA9F6B5BA, ( 75.00 + ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2), true)) * 3.00 ) ))
    if ( ( GetRandomInt(1, 2) == 1 ) ) then
    call dsound("mh_Firefly_form1_jn1.mp3" , LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC303079D))
    else
    call dsound("mh_Firefly_form1_jn2.mp3" , LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC303079D))
    endif
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x91675E9D, 1.00)
    if ( ( GetUnitAbilityLevel(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2), 'A0TK') >= 1 ) ) then
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x91675E9D, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x91675E9D) + 0.10 ))
    else
    endif
    if ( ( GetUnitAbilityLevel(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x5B929F8B), 'A0TV') >= 1 ) ) then
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x91675E9D, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x91675E9D) + 0.08 ))
    else
    endif
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x6DD3A3AB, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x6DD3A3AB) * LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x91675E9D) ))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA9F6B5BA, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA9F6B5BA) * LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x91675E9D) ))
    else
    endif
    if ( ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x8B1FFFFC) == 20 ) ) then
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffectTarget("chun-yanji-4.mdl", LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2), "left hand"))
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x74FF4309, LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffectTarget("66_2.mdl", LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2), "left hand"))
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x83F114DE, LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    else
    endif
    if ( ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x8B1FFFFC) == 50 ) ) then
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA, GetUnitX(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC303079D)))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382, GetUnitY(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC303079D)))
    call mh_fyty(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC303079D) , 10 , 3 , 300 , 3 , 0 , 0 , "萨姆Q2")
    call CameraSetEQNoiseForPlayer(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946), 20.00)
    call SetUnitTimeScale(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC303079D), 3.00)
    set ydl_timer=CreateTimer()
    call SavePlayerHandle(YDLOC, GetHandleId(ydl_timer), 0x48656946, LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946))
    call TimerStart(ydl_timer, 0.10, false, function Trig_J_Firefly____________010Func016Func015Func004Func006T)
    else
    endif
    if ( ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x8B1FFFFC) >= 50 ) and ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x8B1FFFFC) <= 80 ) ) then
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA, GetUnitX(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382, GetUnitY(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x34D6230E, RMaxBJ(( 240.00 - ( I2R(( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x8B1FFFFC) - 50 )) * 10.00 ) ), 2.00))
    if ( ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x68377B19) == 1 ) ) then
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x34D6230E, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x34D6230E) * 0.25 ))
    else
    endif
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA) + ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x34D6230E) * CosBJ(LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D345649)) ) ))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382) + ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x34D6230E) * SinBJ(LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D345649)) ) ))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xD310CF7A, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA) + ( 100.00 * CosBJ(LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D345649)) ) ))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x7D73FF94, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382) + ( 100.00 * SinBJ(LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D345649)) ) ))
    call SaveInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x1763D202, ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x1763D202) + 1 ))
    call SetUnitX(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA))
    call SetUnitY(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x6C5E960D, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x34D6230E) - 0.00 ))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2DC94E6E, LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D345649))
    set ydl_group=CreateGroup()
    call GroupEnumUnitsInRange(ydl_group, LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xD310CF7A), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x7D73FF94), 300.00, null)
    loop
    set ydl_unit=FirstOfGroup(ydl_group)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(ydl_group, ydl_unit)
    if ( ( mh_tjfz1(ydl_unit , LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946)) == true ) ) then
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 1 ) ) then // INLINED!!
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) ) then // INLINED!!
    call mh_zzfycfxt1(ydl_unit , null , 0)
    else
    endif
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 3 ) ) then // INLINED!!
    call mh_zzfycfxt1(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2) , null , 0)
    else
    endif
    else
    endif
    if ( ( CountUnitsInGroup(LoadGroupHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x7B2D08E8)) >= 10 ) ) then
    call SaveInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0xDA903C9B, GetRandomInt(0, 1))
    if ( ( IsUnitGroupEmptyBJ(LoadGroupHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC7D2BDC1 + ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0xDA903C9B) ))) == true ) ) then
    call SaveGroupHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC7D2BDC1 + ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0xDA903C9B) ), CreateGroup())
    else
    endif
    call GroupAddUnit(LoadGroupHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC7D2BDC1 + ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0xDA903C9B) )), ydl_unit)
    else
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xBA396058, GetUnitX(ydl_unit))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x5F2092C7, GetUnitY(ydl_unit))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xBA396058, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xBA396058) + ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x6C5E960D) * CosBJ(LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2DC94E6E)) ) ))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x5F2092C7, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x5F2092C7) + ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x6C5E960D) * SinBJ(LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2DC94E6E)) ) ))
    call SetUnitX(ydl_unit, LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xBA396058))
    call SetUnitY(ydl_unit, LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x5F2092C7))
    endif
    //查询防御状态和是否拥有无法选取 以及通用的选取条件
    if ( ( mh_tjfz6(ydl_unit , 0) == true ) and ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) and ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 3, 3)) == 0) == true ) and ( IsUnitInGroup(ydl_unit, LoadGroupHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x7B2D08E8)) == false ) ) then // INLINED!!
    //物理伤害
    call mh_sh1(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2) , ydl_unit , LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x6DD3A3AB) , 4 , 0 , true , false , ATTACK_TYPE_HERO , DAMAGE_TYPE_ENHANCED , WEAPON_TYPE_WHOKNOWS)
    call GroupAddUnit(LoadGroupHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x7B2D08E8), ydl_unit)
    call IssueTargetOrder(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xE052C95B), "thunderbolt", ydl_unit)
    if ( ( IsUnitType(ydl_unit, UNIT_TYPE_HERO) == true ) and ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x68377B19) == 0 ) ) then
    call SaveInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x8B1FFFFC, 60)
    call SaveInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x68377B19, 1)
    else
    endif
    set udg_wndanwei_jndw[1]=LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)
    set udg_wndanwei_jndw[2]=ydl_unit
    set udg_wnzhengshu__zs[1]=4
    set udg_wnzhengshu__zs[2]=50
    call TriggerExecute(gg_trg_J_Firefly____________000_fz)
    else
    endif
    else
    endif
    endloop
    call DestroyGroup(ydl_group)
    set ydul_c=0
    loop
    exitwhen ydul_c > 1
    if ( ( IsUnitGroupEmptyBJ(LoadGroupHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC7D2BDC1 + ( ydul_c ))) == false ) ) then
    call SaveInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0xDA903C9B, ydul_c)
    set ydl_timer=CreateTimer()
    call SaveUnitHandle(YDLOC, GetHandleId(ydl_timer), 0x911D5DC2, LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0x6C5E960D, LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x6C5E960D))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0x2DC94E6E, LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2DC94E6E))
    call SaveInteger(YDLOC, GetHandleId(ydl_timer), 0xDA903C9B, LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0xDA903C9B))
    call SaveGroupHandle(YDLOC, GetHandleId(ydl_timer), 0xC7D2BDC1 + ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0xDA903C9B) ), LoadGroupHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC7D2BDC1 + ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0xDA903C9B) )))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0xBA396058, LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xBA396058))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0x5F2092C7, LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x5F2092C7))
    call TimerStart(ydl_timer, ( 0.01 + ( 0.005 * I2R(ydul_c) ) ), false, function Trig_J_Firefly____________010Func016Func015Func005Func015Func001Func003T)
    else
    endif
    set ydul_c=ydul_c + 1
    endloop
    if ( ( ModuloInteger(LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x8B1FFFFC), 4) == 0 ) ) then
    call SaveStr(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D1FF186, "animewind.mdl")
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffect(LoadStr(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D1FF186), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xD310CF7A), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x7D73FF94)))
    call EXSetEffectSize(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , GetRandomReal(2.00, 3.00))
    call EXEffectMatRotateY(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , ( ( - 5.00 ) * ( I2R(GetRandomInt(1, 18)) ) ))
    call EXEffectMatRotateZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , GetRandomDirectionDeg())
    call EXSetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , ( EXGetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6)) + ( 0.00 + GetRandomReal(0.00, 100.00) ) ))
    call EXSetEffectSpeed(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , GetRandomReal(1.20, 1.50))
    call EXSetEffectColor(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 0xff000000 * PercentTo255(GetRandomReal(80, 90)) + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(100))
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xADF78AF5, ( ( I2R(( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x8B1FFFFC) - 0 )) * 0.02 ) + 0.40 ))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x963008F4, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xADF78AF5) / 0.03 ))
    call SaveUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x8703EBEE, CreateUnit(GetOwningPlayer(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)), 'e00E', ( GetUnitX(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)) - 10.00 ), GetUnitY(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)), GetUnitFacing(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2))))
    call DzSetUnitModel(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x8703EBEE), LoadStr(YDLOC, GetHandleId(GetExpiredTimer()), 0xA8454FE5))
    call SetUnitScale(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x8703EBEE), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xD264ED37), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xD264ED37), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xD264ED37))
    call UnitAddAbility(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x8703EBEE), 'Amrf')
    call UnitRemoveAbility(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x8703EBEE), 'Amrf')
    call PauseUnit(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x8703EBEE), true)
    call SetUnitFlyHeight(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x8703EBEE), ( I2R(R2I(GetUnitFlyHeight(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)))) + 0.00 ), 0.00)
    call SetUnitTimeScale(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x8703EBEE), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x963008F4))
    call SetUnitVertexColor(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x8703EBEE), 255, 255, 255, 0)
    call SetUnitAnimationByIndex(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x8703EBEE), LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x347419F2))
    call YDWETimerRemoveUnit(0.38 , LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x8703EBEE))
    set ydl_timer=CreateTimer()
    call SaveUnitHandle(YDLOC, GetHandleId(ydl_timer), 0x8703EBEE, LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x8703EBEE))
    call TimerStart(ydl_timer, 0.03, false, function Trig_J_Firefly____________010Func016Func015Func005Func016Func002Func014T)
    call SaveStr(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D1FF186, "by_wood_effect_naruto_mingren_weishouyu_2.mdl")
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffect(LoadStr(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D1FF186), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382)))
    call EXSetEffectSize(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 1.00)
    call SetPariticle2Size(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 0.01)
    call EXEffectMatRotateZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , ( ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D345649) ) - ( 0.00 ) ))
    call EXSetEffectSpeed(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , GetRandomReal(1.00, 1.25))
    call EXSetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , ( EXGetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6)) + 2.00 ))
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    else
    endif
    else
    endif
    if ( ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x8B1FFFFC) == 70 ) ) then
    call SetUnitTimeScale(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC303079D), 1.00)
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA, GetUnitX(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382, GetUnitY(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xD310CF7A, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA) + ( 100.00 * CosBJ(LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D345649)) ) ))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x7D73FF94, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382) + ( 100.00 * SinBJ(LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D345649)) ) ))
    set ydl_group=CreateGroup()
    call GroupEnumUnitsInRange(ydl_group, LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xD310CF7A), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x7D73FF94), 400.00, null)
    loop
    set ydl_unit=FirstOfGroup(ydl_group)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(ydl_group, ydl_unit)
    if ( ( mh_tjfz1(ydl_unit , LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946)) == true ) ) then
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 1 ) ) then // INLINED!!
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) ) then // INLINED!!
    call mh_zzfycfxt1(ydl_unit , null , 0)
    else
    endif
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 3 ) ) then // INLINED!!
    call mh_zzfycfxt1(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2) , null , 0)
    else
    endif
    else
    endif
    //查询防御状态和是否拥有无法选取 以及通用的选取条件
    if ( ( mh_tjfz6(ydl_unit , 0) == true ) and ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) and ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 3, 3)) == 0) == true ) ) then // INLINED!!
    //物理伤害
    call mh_sh1(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2) , ydl_unit , LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA9F6B5BA) , 4 , 0 , true , false , ATTACK_TYPE_HERO , DAMAGE_TYPE_ENHANCED , WEAPON_TYPE_WHOKNOWS)
    call GroupAddUnit(LoadGroupHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x7B2D08E8), ydl_unit)
    call IssueTargetOrder(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xE052C95B), "thunderbolt", ydl_unit)
    set udg_wndanwei_jndw[1]=LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)
    set udg_wndanwei_jndw[2]=ydl_unit
    set udg_wnzhengshu__zs[1]=4
    set udg_wnzhengshu__zs[2]=50
    call TriggerExecute(gg_trg_J_Firefly____________000_fz)
    else
    endif
    else
    endif
    endloop
    call DestroyGroup(ydl_group)
    if ( true ) then
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffect("-672674974.mdx", LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xD310CF7A), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x7D73FF94)))
    call EXEffectMatRotateY(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , - 90.00)
    call EXEffectMatRotateZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D345649))
    call EXSetEffectSpeed(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 1.20)
    call EXSetEffectColor(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 0xff000000 * PercentTo255(80) + 0x10000 * PercentTo255(100) + 0x100 * PercentTo255(100) + PercentTo255(100))
    call EXSetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , ( EXGetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6)) + 150.00 ))
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    call SaveStr(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D1FF186, "chun-yanji-5.mdl")
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffect(LoadStr(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D1FF186), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xD310CF7A), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x7D73FF94)))
    call EXSetEffectSize(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 2.00)
    call SetPariticle2Size(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 2)
    call EXEffectMatRotateZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , GetRandomDirectionDeg())
    call EXSetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , ( EXGetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6)) + 10.00 ))
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffect("1058689001.mdx", LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xD310CF7A), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x7D73FF94)))
    call EXSetEffectSize(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 3.00)
    call EXEffectMatRotateZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D345649))
    call EXSetEffectSpeed(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 2.00)
    call SetPariticle2Size(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 2)
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffect("1058689001.mdx", LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xD310CF7A), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x7D73FF94)))
    call EXSetEffectSize(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 2.00)
    call EXEffectMatRotateZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D345649))
    call EXSetEffectSpeed(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 2.00)
    call SetPariticle2Size(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 2)
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    call CameraSetEQNoiseForPlayer(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946), 30.00)
    set ydl_timer=CreateTimer()
    call SavePlayerHandle(YDLOC, GetHandleId(ydl_timer), 0x48656946, LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946))
    call TimerStart(ydl_timer, 0.08, false, function Trig_J_Firefly____________010Func016Func015Func006Func007Func006T)
    else
    call IssueImmediateOrder(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2), "stop")
    endif
    else
    endif
    if ( ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x8B1FFFFC) == 80 ) ) then
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA, GetUnitX(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382, GetUnitY(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xD310CF7A, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA99320FA) + ( 100.00 * CosBJ(LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D345649)) ) ))
    call SaveReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x7D73FF94, ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xFDF65382) + ( 100.00 * SinBJ(LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D345649)) ) ))
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x74FF4309))
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x83F114DE))
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffect("chun-yanji-6.mdl", LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xD310CF7A), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x7D73FF94)))
    call EXSetEffectSize(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 2.00)
    call SetPariticle2Size(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 2)
    call EXEffectMatRotateZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , GetRandomDirectionDeg())
    call EXSetEffectColor(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 0xff000000 + 0x10000 * PercentTo255(0) + 0x100 * PercentTo255(0) + PercentTo255(0))
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffect("by_wood_eff_ord_dange_wav_kuosan_1_4_1s.mdl", LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xD310CF7A), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x7D73FF94)))
    call EXSetEffectSize(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 1.00)
    call EXEffectMatRotateX(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , - 90.00)
    call EXEffectMatRotateZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , ( ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D345649) ) - ( 90.00 ) ))
    call EXSetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , ( EXGetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6)) + 150.00 ))
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    call SaveEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6, AddSpecialEffect("fire-boom-new.mdl", LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xD310CF7A), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x7D73FF94)))
    call EXEffectMatRotateY(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , - 90.00)
    call EXEffectMatRotateZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , ( ( LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D345649) ) - ( 180.00 ) ))
    call EXSetEffectSize(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 1.50)
    call SetPariticle2Size(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , 2)
    call EXSetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6) , ( EXGetEffectZ(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6)) + 150.00 ))
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x62C50DE6))
    set ydl_group=CreateGroup()
    call GroupEnumUnitsInRange(ydl_group, LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xD310CF7A), LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x7D73FF94), 400.00, null)
    loop
    set ydl_unit=FirstOfGroup(ydl_group)
    exitwhen ydl_unit == null
    call GroupRemoveUnit(ydl_group, ydl_unit)
    if ( ( mh_tjfz1(ydl_unit , LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946)) == true ) ) then
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 1 ) ) then // INLINED!!
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) ) then // INLINED!!
    call mh_zzfycfxt1(ydl_unit , null , 0)
    else
    endif
    if ( ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) >= 3 ) ) then // INLINED!!
    call mh_zzfycfxt1(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2) , null , 0)
    else
    endif
    else
    endif
    //查询防御状态和是否拥有无法选取 以及通用的选取条件
    if ( ( mh_tjfz6(ydl_unit , 0) == true ) and ( (LoadInteger(hsb, (GetHandleId(((ydl_unit)))) + StringHash("防御系统"), StringHash("防御等级") + 0)) <= 3 ) and ( (S2I(SubStringBJ(LoadStr(hsb, StringHash("单位buff") + (GetHandleId(((ydl_unit)))), StringHash("buff1")), 3, 3)) == 0) == true ) ) then // INLINED!!
    call YDWETimerPatternRushSlide(ydl_unit , LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0x2D345649) , 150.00 , 0.05 , 0.02 , 0 , false , false , false , "" , "" , "")
    //物理伤害
    call mh_sh1(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2) , ydl_unit , LoadReal(YDLOC, GetHandleId(GetExpiredTimer()), 0xA9F6B5BA) , 4 , 0 , true , false , ATTACK_TYPE_HERO , DAMAGE_TYPE_ENHANCED , WEAPON_TYPE_WHOKNOWS)
    call GroupAddUnit(LoadGroupHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x7B2D08E8), ydl_unit)
    call IssueTargetOrder(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xE052C95B), "thunderbolt", ydl_unit)
    call DestroyEffect(AddSpecialEffectTarget("chun-yanji-7.mdl", ydl_unit, "origin"))
    set udg_wndanwei_jndw[1]=LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x911D5DC2)
    set udg_wndanwei_jndw[2]=ydl_unit
    set udg_wnzhengshu__zs[1]=4
    set udg_wnzhengshu__zs[2]=50
    call TriggerExecute(gg_trg_J_Firefly____________000_fz)
    else
    endif
    else
    endif
    endloop
    call DestroyGroup(ydl_group)
    call CameraSetEQNoiseForPlayer(LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946), 50.00)
    set ydl_timer=CreateTimer()
    call SavePlayerHandle(YDLOC, GetHandleId(ydl_timer), 0x48656946, LoadPlayerHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x48656946))
    call TimerStart(ydl_timer, 0.20, false, function Trig_J_Firefly____________010Func016Func015Func007Func012T)
    else
    endif
    if ( ( LoadInteger(YDLOC, GetHandleId(GetExpiredTimer()), 0x8B1FFFFC) >= 80 ) ) then
    call RemoveUnit(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x384C9D86))
    call RemoveUnit(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xE052C95B))
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x74FF4309))
    call DestroyEffect(LoadEffectHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x83F114DE))
    call GroupClear(LoadGroupHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x7B2D08E8))
    call DestroyGroup(LoadGroupHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0x7B2D08E8))
    call SetUnitTimeScale(LoadUnitHandle(YDLOC, GetHandleId(GetExpiredTimer()), 0xC303079D), 1.00)
    call FlushChildHashtable(YDLOC, GetHandleId(GetExpiredTimer()))
    call DestroyTimer(GetExpiredTimer())
    else
    endif
    else
    endif
    set ydl_timer=null
    set ydl_group=null
    set ydl_unit=null
    endfunction
    function Trig_J_Firefly____________010Actions takes nothing returns nothing
    local timer ydl_timer
    local integer ydl_localvar_step= LoadInteger(YDLOC, GetHandleId(GetTriggeringTrigger()), 0xCFDE6C76)
     set ydl_localvar_step=ydl_localvar_step + 3
     call SaveInteger(YDLOC, GetHandleId(GetTriggeringTrigger()), 0xCFDE6C76, ydl_localvar_step)
     call SaveInteger(YDLOC, GetHandleId(GetTriggeringTrigger()), 0xECE825E7, ydl_localvar_step)
    call SaveUnitHandle(YDLOC, D, udg_wndanwei_jndw[1])
    call SavePlayerHandle(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x48656946, GetOwningPlayer(LoadUnitHandle(YDLOC, D)))
    call SaveReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x324AE96A, udg_wnshishu_shishu[0])
    call SaveReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x058682B9, udg_wnshishu_shishu[1])
    call SaveReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0xA99320FA, GetUnitX(LoadUnitHandle(YDLOC, D)))
    call SaveReal(YDLOC, C, GetUnitY(LoadUnitHandle(YDLOC, D)))
    call SaveUnitHandle(YDLOC, B, LoadUnitHandle(YDLOC, D))
    call SaveReal(YDLOC, A, Atan2BJ(( LoadReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x058682B9) - GetUnitY(LoadUnitHandle(YDLOC, D)) ), ( LoadReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x324AE96A) - GetUnitX(LoadUnitHandle(YDLOC, D)) )))
    call SaveUnitHandle(YDLOC, E, CreateUnit(LoadPlayerHandle(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x48656946), 'e002', LoadReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0xA99320FA), LoadReal(YDLOC, C), 0))
    call UnitAddAbility(LoadUnitHandle(YDLOC, E), 'A00F')
    call IssueTargetOrder(LoadUnitHandle(YDLOC, E), "magicleash", LoadUnitHandle(YDLOC, B))
    call IssueImmediateOrder(LoadUnitHandle(YDLOC, B), "stop")
    call SetUnitFacing(LoadUnitHandle(YDLOC, D), LoadReal(YDLOC, A))
    call EXSetUnitFacing(LoadUnitHandle(YDLOC, D) , LoadReal(YDLOC, A))
    call mh_buffkq(LoadUnitHandle(YDLOC, B) , 0.7 , 2 , 1) //假无敌
    set ydl_timer=CreateTimer()
    call SaveUnitHandle(YDLOC, GetHandleId(ydl_timer), 0xC303079D, LoadUnitHandle(YDLOC, D))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0xC1B0964C, LoadReal(YDLOC, A))
    call SaveUnitHandle(YDLOC, GetHandleId(ydl_timer), 0x911D5DC2, LoadUnitHandle(YDLOC, D))
    call SaveUnitHandle(YDLOC, GetHandleId(ydl_timer), 0x5B929F8B, udg_danwei_WJ_ysjgnfz[GetConvertedPlayerId(LoadPlayerHandle(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x48656946))])
    call SavePlayerHandle(YDLOC, GetHandleId(ydl_timer), 0x48656946, LoadPlayerHandle(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x48656946))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0x576F92C1, Pow(( Pow(( LoadReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0xA99320FA) - LoadReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x324AE96A) ), 2.00) + Pow(( LoadReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x058682B9) - LoadReal(YDLOC, C) ), 2.00) ), 0.50))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0x2D345649, LoadReal(YDLOC, A))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0xA99320FA, GetUnitX(LoadUnitHandle(YDLOC, D)))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0xFDF65382, GetUnitY(LoadUnitHandle(YDLOC, D)))
    call SaveGroupHandle(YDLOC, GetHandleId(ydl_timer), 0x7B2D08E8, CreateGroup())
    call SaveStr(YDLOC, GetHandleId(ydl_timer), 0xA8454FE5, "[Hero]\\mh_Sam.mdl")
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0xD264ED37, 1.40)
    call SaveInteger(YDLOC, GetHandleId(ydl_timer), 0x8B1FFFFC, 0)
    call SaveInteger(YDLOC, GetHandleId(ydl_timer), 0x347419F2, LoadInteger(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x347419F2))
    call SaveUnitHandle(YDLOC, GetHandleId(ydl_timer), 0x8703EBEE, LoadUnitHandle(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x8703EBEE))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0x2DC94E6E, LoadReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x2DC94E6E))
    call SaveInteger(YDLOC, GetHandleId(ydl_timer), 0x1763D202, LoadInteger(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x1763D202))
    call SaveInteger(YDLOC, GetHandleId(ydl_timer), 0xDA903C9B, LoadInteger(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0xDA903C9B))
    call SaveUnitHandle(YDLOC, GetHandleId(ydl_timer), 0x384C9D86, LoadUnitHandle(YDLOC, E))
    call SaveUnitHandle(YDLOC, GetHandleId(ydl_timer), 0xE052C95B, LoadUnitHandle(YDLOC, G))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0x34D6230E, LoadReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x34D6230E))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0x6DD3A3AB, LoadReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x6DD3A3AB))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0xA9F6B5BA, LoadReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0xA9F6B5BA))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0x6C5E960D, LoadReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x6C5E960D))
    call SaveEffectHandle(YDLOC, GetHandleId(ydl_timer), 0x74FF4309, LoadEffectHandle(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x74FF4309))
    call SaveEffectHandle(YDLOC, GetHandleId(ydl_timer), 0x83F114DE, LoadEffectHandle(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x83F114DE))
    call SaveEffectHandle(YDLOC, GetHandleId(ydl_timer), 0x62C50DE6, LoadEffectHandle(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x62C50DE6))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0xD310CF7A, LoadReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0xD310CF7A))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0xBA396058, LoadReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0xBA396058))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0x7D73FF94, LoadReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x7D73FF94))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0x5F2092C7, LoadReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x5F2092C7))
    call SaveStr(YDLOC, GetHandleId(ydl_timer), 0x2D1FF186, LoadStr(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x2D1FF186))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0x91675E9D, LoadReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x91675E9D))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0x963008F4, LoadReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x963008F4))
    call SaveReal(YDLOC, GetHandleId(ydl_timer), 0xADF78AF5, LoadReal(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0xADF78AF5))
    call SaveInteger(YDLOC, GetHandleId(ydl_timer), 0x68377B19, LoadInteger(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step, 0x68377B19))
    call TimerStart(ydl_timer, 0.02, true, function Trig_J_Firefly____________010Func016T)
    call FlushChildHashtable(YDLOC, GetHandleId(GetTriggeringTrigger()) * ydl_localvar_step)
    set ydl_timer=null
    endfunction
    //===========================================================================
    function InitTrig_J_Firefly____________010 takes nothing returns nothing
    set gg_trg_J_Firefly____________010=CreateTrigger()
    call TriggerAddAction(gg_trg_J_Firefly____________010, function Trig_J_Firefly____________010Actions)
    endfunction








