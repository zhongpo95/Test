
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