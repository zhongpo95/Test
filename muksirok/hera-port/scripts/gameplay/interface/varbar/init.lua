-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local japi = require("jass.japi")
local PermissionToggle = require("gameplay.permission.permission_toggle")
local PermissionStore = require("gameplay.permission.permission_store")
require("gameplay.interface.ui.test_consume_item_bag")
Byltalentshow = war3.CreateTrigger(function()
  local byl = getunit(GetTriggerUnit())
  local sy = byl.ownerid
  local hero = getunit(Hero[sy])
  if hero:hasdata("千咲天赋-薛定谔的猫") then
    byl:sendmessage("|cFF6699FF剩余天赋点：" .. string.format("%.2f", TalentCode[sy] + 0.86))
  else
    byl:sendmessage("|cFF6699FF剩余天赋点：" .. math.floor(TalentCode[sy]))
  end
  if hero:hasdata("英雄-千咲") then
    byl:sendmessage("|cff942323输入-tfs来切换天赋树,共2页")
  end
end)
local boolean_alice = true
local trg = CreateTrigger()
japi.DzTriggerRegisterSyncData(trg, "Backpack", false)
TriggerAddAction(trg, function()
  local backpack = japi.DzGetTriggerSyncData()
  local player = japi.DzGetTriggerSyncPlayer()
  local sy = GetConvertedPlayerId(player)
  local u = getunit(Hero[sy])
  local bb = getunit(Beibao[sy])
  u:deldata("背包-艾露猫")
  bb:deldata("背包-波仔")
  bb:deldata("背包-艾露猫")
  bb:deldata("背包-圣诞尼禄")
  bb:deldata("背包-布丁背包")
  bb:delskill("A0HX")
  bb:delskill("A0HY")
  local b = false
  if backpack == "波仔" and HasHero_Qianxiao(u.owner) then
    b = true
    bb:setdata("背包-波仔")
    japi.SetUnitProperName(bb.handle, "|cFFCC9F80波仔|r")
    japi.SetUnitModel(bb.handle, "bozai_tss1.mdx")
    bb:setsize(1.25)
    bb:setflyheight(0)
  end
  if backpack == "艾露猫" and HasHero_42(u.owner) then
    b = true
    u:setdata("背包-艾露猫")
    bb:setdata("背包-艾露猫")
    japi.SetUnitProperName(bb.handle, "|cFF3366FF艾露猫|r")
    japi.SetUnitModel(bb.handle, "ailumao1.mdx")
    bb:setsize(2.5)
    bb:setflyheight(0)
  end
  if backpack == "圣诞尼禄" and u:hasdata("权限-圣诞尼禄") then
    b = true
    bb:setdata("背包-圣诞尼禄")
    japi.SetUnitProperName(bb.handle, "|cFFFF241C圣诞尼禄|r")
    japi.SetUnitModel(bb.handle, "padoru.mdx")
    bb:setsize(0.35)
    bb:setflyheight(0)
    bb:addskill("A0HV")
    bb:delskill("A0HV")
    bb:addskill("A0HX")
    bb:banskill("A0HX")
    bb:setskillforever("A0HY")
    bb:setskillforever("A0I1")
    bb:delskill("A0DA")
    bb:addskill("A0DA")
  end
  if backpack == "布丁背包" and u:hasdata("权限-布丁背包") then
    b = true
    bb:setdata("背包-布丁背包")
    local name = "|cFFFFCC00布|r|cFFFFD61F丁|r|cFFFFE03D酱|r"
    japi.SetUnitName(bb.handle, name)
    japi.SetUnitProperName(bb.handle, name)
    japi.SetUnitModel(bb.handle, "dhyc_1.mdx")
    bb:setsize(0.75)
    bb:setflyheight(0)
  end
  if not b then
    japi.SetUnitModel(bb.handle, "war3mapImported\\SpiritOfVengeanceMissile.mdx")
    bb:setsize(1)
    bb:setflyheight(150)
  end
end)

function heroselect5(unit)
  local u = getunit(unit)
  local p = getplayer(u.owner)
  local sy = u.ownerid
  local x, y = u:getxy()
  if u.type ~= HeroType["波风水门"] then
    local mj = CreateUnitLua(p.handle, S2ID("o000"), x, y, 0)
    DelayRemoveUnitLua(mj, 180000)
  end
  p:createrectfogcorrector(Glo.gg_rct_Bianyilanchushi)
  x, y = GetRandomXYInRect(Glo.gg_rct_Bianyilanchushi)
  Ewl_Skill[sy] = CreateUnitLua(Player(PLAYER_NEUTRAL_PASSIVE), S2ID("H02N"), x, y, 0)
  Ewl_Skill_Count[sy] = 0
  local ywl = Ewl_Skill[sy]
  ywl = getunit(ywl)
  ywl:changeowner(u.owner)
  ywl:setlevel(999)
  ywl:setdata("当前页数", 1)
  ywl:setdata("最大页数", 3)
  TriggerRegisterUnitEvent(Trg_UnitSkill, ywl.handle, EVENT_UNIT_SPELL_EFFECT)
  ywl:addtrgevent("单位-发动技能", function(args)
    bylskill_ChangeTrg(args.unit, args.skill)
  end)
  Yiwu_Zhanqi[sy] = CreateUnitLua(p.handle, S2ID("o008"), x, y, 0)
  mj = CreateUnitLua(Player(PLAYER_NEUTRAL_PASSIVE), S2ID("H020"), x, y, 0)
  Ewl_Shuxinglan[sy] = mj
  mj = getunit(mj)
  mj:changeowner(u.owner)
  mj:setlevel(999)
  TriggerRegisterUnitEvent(Trg_UnitSkill, mj.handle, EVENT_UNIT_SPELL_EFFECT)
  mj:addtrgevent("单位-发动技能", function(args)
    bylseeTrg(args.unit, args.skill)
  end)
  u:registeruivar()
  mj = CreateUnitLua(p.handle, S2ID("H02H"), x, y, 0)
  Ewl_Body[sy] = mj
  mj = getunit(mj)
  mj:changeowner(u.owner)
  mj:setdata("系统-变异栏")
  mj:setlevel(999)
  mj:setdata("绑定数值", 1)
  mj:setdata("当前数值", 0)
  mj:setdata("当前数量", 0)
  mj:setdata("最大页数", 6)
  TriggerRegisterUnitEvent(Trg_UnitSkill, mj.handle, EVENT_UNIT_SPELL_EFFECT)
  mj:addtrgevent("单位-发动技能", function(args)
    variationUpTrg(args.unit, args.skill)
  end)
  mj = CreateUnitLua(p.handle, S2ID("H02H"), x, y, 0)
  Ewl_Mind[sy] = mj
  mj = getunit(mj)
  mj:changeowner(u.owner)
  mj:setdata("系统-变异栏")
  mj:setlevel(999)
  mj:setdata("绑定数值", 2)
  mj:setdata("当前数值", 0)
  mj:setdata("当前数量", 0)
  mj:setdata("最大页数", 6)
  TriggerRegisterUnitEvent(Trg_UnitSkill, mj.handle, EVENT_UNIT_SPELL_EFFECT)
  mj:addtrgevent("单位-发动技能", function(args)
    variationUpTrg(args.unit, args.skill)
  end)
  mj = CreateUnitLua(p.handle, S2ID("H02H"), x, y, 0)
  Ewl_Third[sy] = mj
  mj = getunit(mj)
  mj:changeowner(u.owner)
  mj:setdata("系统-变异栏")
  mj:setlevel(999)
  mj:setdata("绑定数值", 3)
  mj:setdata("当前数值", 0)
  mj:setdata("当前数量", 0)
  mj:setdata("最大页数", 6)
  TriggerRegisterUnitEvent(Trg_UnitSkill, mj.handle, EVENT_UNIT_SPELL_EFFECT)
  mj:addtrgevent("单位-发动技能", function(args)
    variationUpTrg(args.unit, args.skill)
  end)
  mj = CreateUnitLua(p.handle, S2ID("H02H"), x, y, 0)
  Ewl_Blood[sy] = mj
  mj = getunit(mj)
  mj:changeowner(u.owner)
  mj:setdata("系统-变异栏")
  mj:setlevel(999)
  mj:setdata("绑定数值", 4)
  mj:setdata("当前数值", 0)
  mj:setdata("当前数量", 0)
  mj:setdata("最大页数", 6)
  TriggerRegisterUnitEvent(Trg_UnitSkill, mj.handle, EVENT_UNIT_SPELL_EFFECT)
  mj:addtrgevent("单位-发动技能", function(args)
    variationUpTrg(args.unit, args.skill)
  end)
  mj = CreateUnitLua(p.handle, S2ID("H02H"), x, y, 0)
  Ewl_Disease[sy] = mj
  mj = getunit(mj)
  mj:changeowner(u.owner)
  mj:setdata("系统-变异栏")
  mj:setlevel(999)
  mj:setdata("绑定数值", 5)
  mj:setdata("当前数值", 0)
  mj:setdata("当前数量", 0)
  mj:setdata("最大页数", 6)
  TriggerRegisterUnitEvent(Trg_UnitSkill, mj.handle, EVENT_UNIT_SPELL_EFFECT)
  mj:addtrgevent("单位-发动技能", function(args)
    variationUpTrg(args.unit, args.skill)
  end)
  mj = CreateUnitLua(p.handle, S2ID("H02H"), x, y, 0)
  Ewl_Coop[sy] = mj
  mj = getunit(mj)
  mj:changeowner(u.owner)
  mj:setdata("系统-变异栏")
  mj:setlevel(999)
  mj:setdata("绑定数值", 6)
  mj:setdata("当前数值", 0)
  mj:setdata("当前数量", 0)
  mj:setdata("最大页数", 1)
  TriggerRegisterUnitEvent(Trg_UnitSkill, mj.handle, EVENT_UNIT_SPELL_EFFECT)
  mj:addtrgevent("单位-发动技能", function(args)
    variationUpTrg(args.unit, args.skill)
  end)
  mj = CreateUnitLua(p.handle, S2ID("H02H"), x, y, 0)
  Ewl_State[sy] = mj
  mj = getunit(mj)
  mj:changeowner(u.owner)
  mj:setdata("系统-变异栏")
  mj:setlevel(999)
  mj:setdata("绑定数值", 7)
  mj:setdata("当前数值", 0)
  mj:setdata("当前数量", 0)
  mj:setdata("最大页数", 1)
  u:setdata("诅咒-灵体化")
  u:uivar_add({
    keyname = "灵体化",
    keytype = "传奇栏",
    text = "|cFF33CCFF永恒刻印|r\n|cFF33CCFF你的存在被记录在万象之书上,可以通过伊丝复活\n除非被抹除存在或生命形态改变|r",
    icon = "war3mapImported\\BTNEwl_Zuzhou_Lingtihua.blp"
  })
  u:uivar_add({
    keyname = "冥王公共池",
    keytype = "冥王栏",
    text = "|cFF2378EC通用精神变异|r",
    icon = "Ewl_Mwx_Tongyong",
    cd = 1,
    clickfunc = function(u)
      FlashUIVarGlobal(u, "冥王栏冥王公共池")
    end
  })
  local pid = u.ownerid * System_YiwulanCount - (System_YiwulanCount - 1)
  local pid2 = u.ownerid * System_YiwulanCount
  for i = pid, pid2 do
    System_Yiwulan[i] = CreateUnitLua(Player(PLAYER_NEUTRAL_PASSIVE), S2ID("H01G"), x, y, 0)
    ywl = getunit(System_Yiwulan[i])
    ywl:changeowner(u.owner)
    ywl:setlevel(999)
    TriggerRegisterUnitEvent(Trg_ItemUse, ywl.handle, EVENT_UNIT_USE_ITEM)
    ywl:addtrgevent("单位-使用物品", function(args)
      RemainsUse(args.unit, args.item)
    end)
    TriggerRegisterUnitEvent(Trg_UnitSkill, ywl.handle, EVENT_UNIT_SPELL_EFFECT)
    for j = 1, 6 do
      ywl:additem("I07Q")
    end
  end
  for i = 1, 6 do
    ywl = getunit(System_Yiwulan[pid])
    ywl:removecountitem(i)
  end
  for i = 1, 6 do
    ywl = getunit(System_Yiwulan[pid + 1])
    ywl:removecountitem(i)
  end
  Ewl_Yiwulan[sy] = CreateUnitLua(Player(PLAYER_NEUTRAL_PASSIVE), S2ID("H021"), x, y, 0)
  ywl = getunit(Ewl_Yiwulan[sy])
  ywl:changeowner(u.owner)
  TriggerRegisterUnitEvent(Trg_UnitSkill, ywl.handle, EVENT_UNIT_SPELL_EFFECT)
  ywl:addtrgevent("单位-发动技能", function(args)
    bylYiwulanTrg(args.unit, args.skill)
  end)
  mj = CreateUnitLua(u.owner, S2ID("H00B"), x, y, 0)
  Ewl_Moniskill[sy] = mj
  mj = getunit(mj)
  mj:setlevel(999)
  mj:changeowner(u.owner)
  TriggerRegisterUnitEvent(Trg_UnitSkill, mj.handle, EVENT_UNIT_SPELL_EFFECT)
  mj = CreateUnitLua(u.owner, S2ID("H00B"), x, y, 0)
  Ewl_Quanxianlan[sy] = mj
  mj = getunit(mj)
  mj:setlevel(999)
  mj:changeowner(u.owner)
  mj:setdata("当前页数", 1)
  mj:setdata("最大页数", 4)
  TriggerRegisterUnitEvent(Trg_UnitSkill, mj.handle, EVENT_UNIT_SPELL_EFFECT)
  mj:addtrgevent("单位-发动技能", function(args)
    bylqx_ChangeTrg(args.unit, args.skill)
  end)
  for i = 1, DDPCount do
    mj:addskill(Pwrshow[i])
    mj:banskill(Pwrshow[i])
  end
  for i = 1, 10 do
    mj:banskill(Pwrshow[i], false)
  end
  mj = CreateUnitLua(u.owner, S2ID("H02H"), x, y, 0)
  Ewl_Posuihuanxiang[sy] = mj
  mj = getunit(mj)
  mj:changeowner(u.owner)
  mj:setlevel(999)
  mj:addskill("A0BV")
  mj:addskill("A1S5")
  mj:addskill("A0JB")
  TriggerRegisterUnitEvent(Trg_UnitSkill, mj.handle, EVENT_UNIT_SPELL_EFFECT)
  mj:addtrgevent("单位-发动技能", function(args)
    bylKBLShuTrg(args.unit, args.skill)
  end)
  mj = CreateUnitLua(u.owner, S2ID("H02G"), x, y, 0)
  Ewl_KBLShu[sy] = mj
  mj = getunit(mj)
  mj:setlevel(999)
  mj = CreateUnitLua(u.owner, S2ID("H059"), x, y, 0)
  Ewl_ZKBLShu[sy] = mj
  mj = getunit(mj)
  mj:setlevel(999)
  mj = CreateUnitLua(u.owner, S2ID("H04F"), x, y, 0)
  QXL[sy] = mj
  mj = getunit(mj)
  mj:setlevel(999)
  mj:setdata("当前页数", 1)
  mj:setdata("最大页数", 6)
  TriggerRegisterUnitEvent(Trg_UnitSkill, mj.handle, EVENT_UNIT_SPELL_EFFECT)
  mj:addtrgevent("单位-发动技能", function(args)
    byldzqx_ChangeTrg(args.unit, args.skill)
    PermissionToggle.addl(getunit(args.unit), args.skill)
  end)
  Beibao[sy] = CreateUnitLua(Player(PLAYER_NEUTRAL_PASSIVE), S2ID("H006"), x, y, 0)
  local bb = getunit(Beibao[sy])
  bb:setdata("系统-背包")
  bb:changeowner(u.owner)
  if u.type == HeroType["波风水门"] then
    ShowUnit(bb.handle, false)
  end
  if ModeSelect_Muss then
    bb:setskilldatareal("A1NG", "施法间隔", 30)
  end
  bb:groupadd(BeibaoGroup)
  bb:additem("I0HH")
  ac.wait(500, function()
    if u:islocal() and PlayerConfig.UI_Settings then
      local back = PlayerConfig.UI_Settings.Backpack
      japi.DzSyncData("Backpack", back)
    end
  end)
  if Nandu_Choose ~= 1 and not Mode_Dabamoshi then
    do
      local wp = bb:additem("I0JQ")
      SetData(wp, "所属玩家", u.owner)
      u:addspeitem(wp)
      UnitUseItem(u.handle, wp)
    end
    do
      local wp = u:additem("I05H")
      UnitUseItem(u.handle, wp)
    end
    ac.wait(2, function()
      local wp = bb:additem("I0KG")
      SetData(wp, "所属玩家", u.owner)
      u:addspeitem(wp)
    end)
  end
  if u.type == HeroType["爱丽丝"] and boolean_alice then
    boolean_alice = false
    bb:additem("I0GC")
  end
  TriggerRegisterUnitEvent(Trg_UNIT_ISSUED_POINT_ORDER, bb.handle, EVENT_UNIT_ISSUED_POINT_ORDER)
  TriggerRegisterUnitEvent(Trg_UnitSkill, bb.handle, EVENT_UNIT_SPELL_EFFECT)
  TriggerRegisterUnitEvent(Trg_ItemGet, bb.handle, EVENT_UNIT_PICKUP_ITEM)
  TriggerRegisterUnitEvent(Trg_UNIT_ISSUED_TARGET_ORDER, bb.handle, EVENT_UNIT_ISSUED_TARGET_ORDER)
  bb:addtrgevent("单位-指定物体指令", function(args)
    local order = args.orderid
    if 852002 <= order and order <= 852007 then
      local u = getunit(args.unit)
      if RightGive[u.ownerid] then
        local item = args.item
        local wp = u:getcountitem(order - 852001)
        if item == wp then
          local sy = bb.ownerid
          local hero = getunit(Hero[sy])
          local wptype = GetItemTypeId(wp)
          if wptype ~= S2ID("I0C5") and wptype ~= S2ID("I0C6") and GetItemLifeBJ(wp) ~= 555 and wptype ~= S2ID("I0BJ") then
            for i = 1, 6 do
              if hero:getcountitem(i) == 0 then
                hero:addspeitem(wp)
                return
              end
            end
            hero:sendmessage("|cFF7DBEF1英雄物品栏已满|r")
          end
        end
      end
    end
  end)
  bb:addtrgevent("单位-指定点目标指令", function(args)
    if args.orderid == String2OrderIdBJ("smart") and GetRandom100(10) then
      AilumaoSnd(bb, "走路")
    end
  end)
  bb:addtrgevent("单位-获得物品", function(args)
    itemgetTrg(args.unit, args.item)
  end)
  bb:triggeraddevent(BeibaoSkill, EVENT_UNIT_SPELL_EFFECT)
  bb:setlevel(999)
  bb:setmaxhp(1000)
  local alm = 0
  local dx, dy = bb:getxy()
  ac.loop(250, function()
    local x, y = u:getxy()
    local x2, y2 = bb:getxy()
    local l = GetUnitAbilityLevel(bb.handle, S2ID("A0U7"))
    if not u:isalive() and bb:isalive() and not u:hasdata("莲华-美少女万华镜") then
      KillUnit(bb.handle)
      bb:sethp(0)
    end
    if (u:isalive() or u:hasdata("莲华-美少女万华镜")) and not bb:isalive() then
      ReviveHero(bb.handle, x, y, false)
      bb:setdata("生命值", 1000)
    end
    if bb:hasdata("背包-艾露猫") then
      local bdis = DistanceXY(x2, y2, dx, dy)
      if bdis <= 50 then
        if GetRandom100(25) then
          alm = alm + 1
        end
        if alm == 12 then
          alm = alm + 1
          bb:animeact(7)
        end
        if alm == 16 then
          alm = alm + 1
          bb:animeact(6)
        end
      else
        alm = 0
      end
      dx, dy = bb:getxy()
    end
    if bb:isalive() and not u:hasdata("变异判定-恶兆之花") then
      local dis = DistanceBetweenUnits(u.handle, bb.handle)
      if l == 1 and 225 <= dis and dis <= 2000 then
        unitmove({
          unit = bb.handle,
          time = 0.3,
          distance = dis - 200,
          angle = AngleBetweenUnits(bb.handle, u.handle),
          isfly = true
        })
      end
      if not (2000 < dis) or Boolean_AnshenBattle or bb:istype("H024") and IsTimeNight() then
      else
        bb:setxy(x, y)
      end
    end
  end)
  Beibao_Ew[sy] = CreateUnitLua(u.owner, S2ID("H01I"), x, y, 0)
  Beibao_Ew[sy + 6] = CreateUnitLua(u.owner, S2ID("H01I"), x, y, 0)
  Beibao_Ew[sy + 12] = CreateUnitLua(u.owner, S2ID("H01I"), x, y, 0)
  Beibao_Ew[sy + 18] = CreateUnitLua(u.owner, S2ID("H01I"), x, y, 0)
  System_ZbBeibao[sy] = CreateUnitLua(u.owner, S2ID("H02C"), x, y, 0)
  if u.type == HeroType["铃仙"] then
    local zbl = getunit(System_ZbBeibao[sy])
    zbl:addspeitem(u:getdata("专属枪支"))
  end
  u:setdata("职业选择")
  u:uivar_add({
    keyname = "职业选择",
    keytype = "传奇栏",
    text = "|cFF7DBEF1点击选择职业倾向|r",
    icon = "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp",
    clickfunc = function(u, button)
      u:deldata("职业选择")
      u:uivar_remove("职业选择", "传奇栏")
      local data = {
        {
          icon = "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp",
          title = "随机职业",
          text = "随机选择初始职业",
          func = function(u)
            Proact(u)
          end
        }
      }
      local zs = GetRandomInt(1, #HeroPro_Lv0)
      local rdpro = HeroPro_Lv0[zs]
      u:setdata("不出现随机", rdpro.name)
      table.insert(data, {
        icon = rdpro.effectart,
        title = rdpro.effectname,
        text = rdpro.effecttext,
        func = function(u)
          Proact(u, rdpro.name)
        end
      })
      local items = {
        noskip = true,
        desc = "|cFFFFCC66【选择初始职业】|r",
        options = data
      }
      RLChoose(u, items)
    end
  })
  hideprofession(u.handle)
  local max = 500
  System_Fuhuo_Linglizhi[sy] = 400
  if ModeSelect_Muss then
    System_Fuhuo_Linglizhi[sy] = 60
    max = 90
  end
  ac.loop(1000, function()
    System_Fuhuo_Linglizhi[sy] = System_Fuhuo_Linglizhi[sy] + 1
    if System_Fuhuo_Linglizhi[sy] >= max then
      System_Fuhuo_Linglizhi[sy] = max
    end
    if System_Fuhuo_Linglizhi[sy] < 0 then
      System_Fuhuo_Linglizhi[sy] = 0
    end
  end)
  local tfs = {}
  tfs["莲华"] = "H045"
  tfs["白洲梓"] = "H03Y"
  tfs["志贵"] = "H03O"
  tfs["琪露诺"] = "H013"
  tfs["爱丽丝"] = "H01D"
  tfs["灵梦"] = "H016"
  tfs["魔理沙"] = "H017"
  tfs["蕾米"] = "H00S"
  tfs["铃仙"] = "H014"
  tfs["十六夜"] = "H010"
  tfs["圣白莲"] = "H012"
  tfs["狂三"] = "H01M"
  tfs["八重樱"] = "H02M"
  tfs["秦心"] = "H01U"
  tfs["C呆"] = "H030"
  tfs["里三"] = "H032"
  tfs["贝洛妮卡"] = "H03B"
  tfs["切嗣"] = "H01S"
  tfs["妖梦"] = "H01A"
  tfs["两仪式"] = "H051"
  tfs["史尔特尔"] = "H056"
  tfs["波风水门"] = "H05D"
  tfs["千咲"] = "H05Z"
  local namestr = {
    "莲华",
    "白洲梓",
    "志贵",
    "琪露诺",
    "爱丽丝",
    "灵梦",
    "魔理沙",
    "蕾米",
    "铃仙",
    "十六夜",
    "圣白莲",
    "狂三",
    "八重樱",
    "秦心",
    "C呆",
    "里三",
    "贝洛妮卡",
    "两仪式",
    "波风水门",
    "切嗣",
    "妖梦",
    "史尔特尔",
    "千咲"
  }
  local lx = 0
  for index, str in ipairs(namestr) do
    if tfs[str] ~= nil and u.type == HeroType[str] then
      lx = S2ID(tfs[str])
    end
  end
  if lx ~= 0 then
    TalentDw[sy] = CreateUnitLua(Player(PLAYER_NEUTRAL_PASSIVE), lx, Talent_X, Talent_Y, 0)
    mj = getunit(TalentDw[sy])
    mj:changeowner(u.owner)
    mj:setlevel(999)
    mj:triggeraddevent(Byltalentshow, EVENT_UNIT_SELECTED)
  end
  ac.loop(3000, function()
    local x, y = u:getxy()
    local mj = getunit(Ewl_Skill[sy])
    mj:setxy(x, y)
    local sxl = getunit(Ewl_Shuxinglan[sy])
    sxl:setxy(x, y)
    if TalentDw[sy] ~= 0 then
      ModifyHeroSkillPoints(TalentDw[sy], bj_MODIFYMETHOD_SET, TalentCode[sy])
    end
  end)
  ac.wait(1100, function()
    TestConsumeItemBagUI(u)
  end)
end

function bylseeTrg(unit, skill)
  local u = getunit(unit)
  local sy = u.ownerid
  if skill == S2ID("A11K") then
    unit = Ewl_Body[sy]
  end
  if skill == S2ID("A11L") then
    unit = Ewl_Mind[sy]
  end
  if skill == S2ID("A11M") then
    unit = Ewl_Third[sy]
  end
  if skill == S2ID("A11N") then
    unit = Ewl_Blood[sy]
    local hero = getunit(Hero[sy])
    local str = ""
    for index, value in ipairs(BloodType) do
      if hero:getdata(value.name .. "血统补正浓度") ~= 0 then
        str = str .. value.color:sub(1, 10) .. require("hera_display_tag")(value.name) .. math.floor(100 * hero:getdata(value.name .. "血统补正浓度") / hero:getdata("总血统补正浓度")) .. "%|r/"
      end
    end
    str = string.sub(str, 1, -2)
    if str ~= "" then
      hero:sendmessage(str)
    else
      hero:sendmessage("|cFF7DBEF1纯净|r")
    end
    hero:sendmessage("|cFF7DBEF1总血统浓度:" .. string.format("%.0f", hero:getdata("总血统补正浓度")) .. "%/" .. string.format("%.0f", hero:getdata("血统浓度上限") + 1.0E-4) .. "%|r")
    if 0 < Race_Dragon_Nd[sy] then
      hero:sendmessage("|cFF7DBEF1龙血纯度:|r" .. Race_Dragon_Cdxs_Str[sy])
      hero:sendmessage("|cFF7DBEF1龙血浓度:" .. math.floor(Race_Dragon_Nd[sy] * 100) .. "%|r")
    end
  end
  if skill == S2ID("A11O") then
    unit = Ewl_Disease[sy]
  end
  if skill == S2ID("A11P") then
    unit = Ewl_Yiwulan[sy]
  end
  if skill == S2ID("A11Q") then
    unit = TalentDw[sy]
  end
  if skill == S2ID("A172") then
    unit = Ewl_Quanxianlan[sy]
  end
  if skill == S2ID("A01H") then
    unit = Ewl_Posuihuanxiang[sy]
  end
  if skill == S2ID("A1F2") then
    unit = Ewl_Coop[sy]
  end
  if skill == S2ID("A1RZ") then
    unit = Ewl_State[sy]
  end
  SelectUnitForPlayerSingle(unit, u.owner)
end

function bylKBLShuTrg(unit, skill)
  local u = getunit(unit)
  local sy = u.ownerid
  if skill == S2ID("A0BV") then
    unit = Ewl_KBLShu[sy]
    u:sendmessage("|cff7a87f7神之花瓣碎片：" .. PermissionStore.get_fragment_store(u, "pem_hbsp") .. "|r")
  end
  if skill == S2ID("A0JB") then
    unit = Ewl_ZKBLShu[sy]
    u:sendmessage("|cff9b2020魔之原质碎片：" .. PermissionStore.get_fragment_store(u, "pem_yzsp") .. "|r")
  end
  if skill == S2ID("A1S5") then
    unit = QXL[sy]
  end
  SelectUnitForPlayerSingle(unit, u.owner)
end

local slk = require("jass.slk")

function bylYiwulanTrg(unit, skill)
  local u = getunit(unit)
  local sy = u.ownerid
  local z = tonumber(slk.ability[ID2S(skill)].Area1)
  local pid = sy * System_YiwulanCount - (System_YiwulanCount - z)
  SelectUnitForPlayerSingle(System_Yiwulan[pid], u.owner)
end

function byldzqx_ChangeTrg(unit, skill)
  local u = getunit(unit)
  local sy = u.ownerid
  local dqys = u:getdata("当前页数")
  local zdys = u:getdata("最大页数")
  if skill == S2ID("A11J") or skill == S2ID("A11I") then
    if skill == S2ID("A11J") and 1 < dqys then
      dqys = dqys - 1
    end
    if skill == S2ID("A11I") and zdys > dqys then
      dqys = dqys + 1
    end
    if #Mtashow[sy] > 0 then
      for i = 1, #Mtashow[sy] do
        u:banskill(Mtashow[sy][i])
      end
      for i = (dqys - 1) * 10 + 1, (dqys - 1) * 10 + 10 do
        u:banskill(Mtashow[sy][i], false)
      end
    end
    u:setdata("当前页数", dqys)
    u:sendmessage("|cFF9999FF第" .. math.floor(u:getdata("当前页数")) .. "页")
  end
end

function bylqx_ChangeTrg(unit, skill)
  local u = getunit(unit)
  local sy = u.ownerid
  local dqys = u:getdata("当前页数")
  local zdys = u:getdata("最大页数")
  if skill == S2ID("A11J") or skill == S2ID("A11I") then
    if skill == S2ID("A11J") and 1 < dqys then
      dqys = dqys - 1
    end
    if skill == S2ID("A11I") and zdys > dqys then
      dqys = dqys + 1
    end
  end
  for i = 1, DDPCount do
    u:banskill(Pwrshow[i])
  end
  for i = (dqys - 1) * 10 + 1, (dqys - 1) * 10 + 10 do
    u:banskill(Pwrshow[i], false)
  end
  u:setdata("当前页数", dqys)
  u:sendmessage("第" .. math.floor(u:getdata("当前页数")) .. "页")
end

function bylskill_ChangeTrg(unit, skill)
  local u = getunit(unit)
  local sy = u.ownerid
  local bz = (sy - 1) * 30
  local dqys = u:getdata("当前页数")
  local zdys = u:getdata("最大页数")
  if skill == S2ID("A11J") or skill == S2ID("A11I") then
    if skill == S2ID("A11J") and 1 < dqys then
      dqys = dqys - 1
    end
    if skill == S2ID("A11I") and zdys > dqys then
      dqys = dqys + 1
    end
    for i = 1, Ewl_Skill_Count[sy] do
      u:banskill(Ewl_Skill_ID[i])
    end
    for i = (dqys - 1) * 10 + bz + 1, (dqys - 1) * 10 + bz + 10 do
      u:banskill(Ewl_Skill_ID[i], false)
    end
    u:setdata("当前页数", dqys)
    u:sendmessage("第" .. math.floor(u:getdata("当前页数")) .. "页")
  end
end

local variationskill = {}

function variationUpTrg(unit, skill)
  local u = getunit(unit)
  local sy = u.ownerid
  local hero = getunit(Hero[sy])
  if variationskill[skill] ~= nil then
    variationskill[skill](hero.handle)
  end
  if VarClickFunc[skill] then
    VarClickFunc[skill](hero, u)
  end
end
