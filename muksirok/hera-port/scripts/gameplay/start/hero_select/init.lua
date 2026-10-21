-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local player = require("jh.ac.player")
local PermissionHash = require("gameplay.permission.permission_hash")
local PermissionRead = require("gameplay.permission.permission_read")
local PermissionSelect = require("gameplay.permission.permission_select")
local PermissionStore = require("gameplay.permission.permission_store")
local PlayerNameHeadUI = require("gameplay.interface.ui.player_name_head")

local function random_hero(group)
  local hero = Group_Randomunit(group)
  if type(hero) ~= "table" then
    error("随机英雄池为空")
  end
  return hero
end

Player_Select = {}
Player_Selectunit = {}
Xuanze = Player_Select
for i = 1, 6 do
  Player_Select[i] = false
end
require("gameplay.start.hero_select.setup")
require("gameplay.start.hero_select.runtime")
require("gameplay.start.hero_select.finalize")
require("gameplay.interface.varbar.init")
HeroSelect1 = war3.CreateTrigger(function()
  ShowUnit(HeroAll["缇娜"], true)
  table.insert(HeroZu.random, HeroAll["缇娜"])
  war3.DestroyTrigger(GetTriggeringTrigger())
end)
HeroSelect2 = war3.CreateTrigger(function()
  ShowUnit(HeroAll["切嗣"], true)
  table.insert(HeroZu.random, HeroAll["切嗣"])
  war3.DestroyTrigger(GetTriggeringTrigger())
end)
HeroSelect3 = war3.CreateTrigger(function()
  ShowUnit(HeroAll["八重樱"], true)
  PlaySoundBJ(Sound_BCY_28)
  table.insert(HeroZu.random, HeroAll["八重樱"])
  war3.DestroyTrigger(GetTriggeringTrigger())
end)
HeroSelect4 = war3.CreateTrigger(function()
  ShowUnit(HeroAll["志贵"], true)
  PlaySoundBJ(ZG_G2_Words)
  table.insert(HeroZu.random, HeroAll["志贵"])
  war3.DestroyTrigger(GetTriggeringTrigger())
end)
HeroSelect5 = war3.CreateTrigger(function()
  ShowUnit(HeroAll["白洲梓"], true)
  table.insert(HeroZu.random, HeroAll["白洲梓"])
  war3.DestroyTrigger(GetTriggeringTrigger())
end)
HeroSelect6 = war3.CreateTrigger(function()
  ShowUnit(HeroAll["莲华"], true)
  table.insert(HeroZu.random, HeroAll["莲华"])
  war3.DestroyTrigger(GetTriggeringTrigger())
end)
HdHeroSelect1 = war3.CreateTrigger(function()
  ShowUnit(HeroAll["秦心"], true)
  getunit(HeroAll["秦心"]):groupadd(HeroZu_RareRandom)
  getunit(HeroAll["秦心"]):groupadd(Group_HeroZu)
  war3.DestroyTrigger(GetTriggeringTrigger())
end)
HdHeroSelect2 = war3.CreateTrigger(function()
  ShowUnit(HeroAll["贝洛妮卡"], true)
  getunit(HeroAll["贝洛妮卡"]):groupadd(HeroZu_RareRandom)
  getunit(HeroAll["贝洛妮卡"]):groupadd(Group_HeroZu)
  war3.DestroyTrigger(GetTriggeringTrigger())
end)
HdHeroSelect3 = war3.CreateTrigger(function()
  ShowUnit(HeroAll["里三"], true)
  getunit(HeroAll["里三"]):groupadd(Group_HeroZu)
  war3.DestroyTrigger(GetTriggeringTrigger())
end)

function HeroSelectAdd()
  for _, name in ipairs({"秦心", "贝洛妮卡", "里三"}) do
    local hero = getunit(HeroAll[name])
    ShowUnit(hero.handle, true)
    hero:groupadd(Group_HeroZu)
    if name ~= "里三" then
      hero:groupadd(HeroZu_RareRandom)
    end
  end
  for i = 1, 6 do
    local player = player[i]
    if player:isplayer() then
      player:chatmsg(HdHeroSelect1, "-코코로")
      player:chatmsg(HdHeroSelect1, "和我赌上最强的称号战斗吧")
      player:chatmsg(HdHeroSelect1, "私と最强の称号を赌けて斗え")
      player:chatmsg(HdHeroSelect1, "私と最強の称号を賭けて闘え")
      player:chatmsg(HdHeroSelect2, "-베로니카")
      player:chatmsg(HdHeroSelect2, "欢迎使用芙萝拉女仆服务")
      player:chatmsg(HdHeroSelect3, "k3")
      player:unitselect(TrgHeroSelect)
      CreateFogModifierRectBJ(true, player.handle, FOG_OF_WAR_VISIBLE, Glo.gg_rct_HeroSelect)
    end
  end
  ac.wait(10000, function()
    attack_next:resume()
    Time_TenSecond = true
  end)
  ac.wait(90000, function()
    for i = 1, 6 do
      if Player_Select[i] == false then
        player[i]:sendMsg("|cFFFF0000[警告]|r|cFF7DBEF160秒后关闭英雄选择|r")
      end
    end
  end)
  ac.wait(140000, function()
    for i = 1, 6 do
      if Player_Select[i] == false then
        player[i]:sendMsg("|cFFFF0000[警告]|r|cFF7DBEF110秒后关闭英雄选择|r")
      end
    end
  end)
  ac.wait(150000, function()
    SendMsgAll("关闭英雄选择")
    require("gameplay.permission.permission_read").release()
    GCreturn()
    war3.DestroyTrigger(TrgHeroSelect)
  end)
end

function HeroSelectConfirm(unit, wj)
  local u = getunit(unit)
  local sy = GetConvertedPlayerId(wj)
  if IsUnitOwnedByPlayer(unit, Player(PLAYER_NEUTRAL_PASSIVE)) and (u:isingroup(Group_HeroZu) or u.type == HeroType["随机征召"] or u.type == HeroType["随机征召全英雄"] or u.type == HeroType["随机征召仅近战"]) and not Player_Select[sy] then
  else
    return false
  end
  if unit == Player_Selectunit[sy] and not Player_Select[sy] then
    local rd = false
    if u.type == HeroType["随机征召"] then
      rd = true
      u = random_hero(HeroZu_NormalRandom)
      if GetRandom100(2) and Group_Counts(HeroZu_RareRandom) > 0 then
        u = random_hero(HeroZu_RareRandom)
      end
    end
    if u.type == HeroType["随机征召全英雄"] then
      rd = true
      u = random_hero(HeroZu_AllRandom)
      if GetRandom100(2) and Group_Counts(HeroZu_RareRandom) > 0 then
        u = random_hero(HeroZu_RareRandom)
      end
    end
    if u.type == HeroType["随机征召仅近战"] then
      rd = true
      u = random_hero(HeroZu_SpeRandom)
      if GetRandom100(2) and Group_Counts(HeroZu_RareRandom) > 0 then
        u = random_hero(HeroZu_RareRandom)
      end
    end
    ShowUnit(u.handle, true)
    unit = u.handle
    local x, y = u:getxy()
    if u.type ~= HeroType["莲华"] and u.type ~= HeroType["铃仙"] and ModeSelect_Infinite then
      local dtx = u:getdata("单位-大头像")
      u = u:createunit(u.type, x, y)
      SetUnitState(u.handle, UNIT_STATE_MAX_LIFE, 10000)
      u:setmaxhp(825)
      u:setmaxmp(30)
      unit = u.handle
      if dtx ~= 0 then
        u:setdata("单位-大头像", dtx)
      end
    else
      u:groupremove(HeroZu_NormalRandom)
      u:groupremove(HeroZu_RareRandom)
      u:groupremove(HeroZu_AllRandom)
      u:groupremove(HeroZu_SpeRandom)
    end
    u:changeowner(wj)
    Player_Select[sy] = true
    require("hera_boot").note("HERO SELECT p=" .. sy .. " BEGIN heroselect2", true)
    heroselect2(unit)
    require("hera_boot").note("HERO SELECT p=" .. sy .. " END heroselect2", true)
    require("hera_boot").note("HERO SELECT p=" .. sy .. " BEGIN heroselect3", true)
    heroselect3(unit)
    require("hera_boot").note("HERO SELECT p=" .. sy .. " END heroselect3", true)
    require("hera_boot").note("HERO SELECT p=" .. sy .. " BEGIN heroselect4", true)
    local initial_weapon = heroselect4(unit)
    require("hera_boot").note("HERO SELECT p=" .. sy .. " END heroselect4", true)
    if rd then
      local a = GetRandomReal(0, 100)
      if a <= 36 then
        u:additem("I02F")
      elseif a <= 72 then
        u:additem("I02H")
      elseif a <= 81 then
        u:additem("I02E")
      elseif a <= 90 then
        u:additem("I011")
      else
        u:additem("I030")
      end
    end
    ac.wait(100, function()
      require("hera_boot").note("HERO SELECT p=" .. sy .. " BEGIN heroselect5(unit)", true)
      heroselect5(unit)
      require("hera_boot").note("HERO SELECT p=" .. sy .. " END heroselect5(unit)", true)
      if initial_weapon and initial_weapon ~= 0 then
        UnitUseItem(unit, initial_weapon)
      end
      Player_Select[sy] = true
      require("hera_boot").note("HERO SELECT p=" .. sy .. " BEGIN u:groupadd(Group_AllHero)", true)
      u:groupadd(Group_AllHero)
      require("hera_boot").note("HERO SELECT p=" .. sy .. " END u:groupadd(Group_AllHero)", true)
      require("hera_boot").note("HERO SELECT p=" .. sy .. " BEGIN PermissionRead.Itemd(u)", true)
      PermissionRead.Itemd(u)
      require("hera_boot").note("HERO SELECT p=" .. sy .. " END PermissionRead.Itemd(u)", true)
      require("hera_boot").note("HERO SELECT p=" .. sy .. " BEGIN PermissionRead.Iteme(u)", true)
      PermissionRead.Iteme(u)
      require("hera_boot").note("HERO SELECT p=" .. sy .. " END PermissionRead.Iteme(u)", true)
      require("hera_boot").note("HERO SELECT p=" .. sy .. " BEGIN PermissionSelect.heroselect6(u)", true)
      PermissionSelect.heroselect6(u)
      require("hera_boot").note("HERO SELECT p=" .. sy .. " END PermissionSelect.heroselect6(u)", true)
      require("hera_boot").note("HERO SELECT p=" .. sy .. " BEGIN PermissionStore.on_hero_selected(u)", true)
      PermissionStore.on_hero_selected(u)
      require("hera_boot").note("HERO SELECT p=" .. sy .. " END PermissionStore.on_hero_selected(u)", true)
      require("hera_boot").note("HERO SELECT p=" .. sy .. " BEGIN YisiStory[英雄选择完毕](u)", true)
      YisiStory["英雄选择完毕"](u)
      require("hera_boot").note("HERO SELECT p=" .. sy .. " END YisiStory[英雄选择完毕](u)", true)
      require("hera_boot").note("HERO SELECT p=" .. sy .. " BEGIN FskillSwitchInit(u)", true)
      FskillSwitchInit(u)
      require("hera_boot").note("HERO SELECT p=" .. sy .. " END FskillSwitchInit(u)", true)
      require("hera_boot").note("HERO SELECT p=" .. sy .. " BEGIN PlayerNameHeadUI.init(u)", true)
      PlayerNameHeadUI.init(u)
      require("hera_boot").note("HERO SELECT p=" .. sy .. " END PlayerNameHeadUI.init(u)", true)
      if TID[sy] == 735899554 or TID[sy] == 1039830281 then
        Caber_Select = false
      end
      require("hera_boot").note("HERO SELECT p=" .. sy .. " BEGIN PermissionHash.apply(u)", true)
      PermissionHash.apply(u)
      require("hera_boot").note("HERO SELECT p=" .. sy .. " END PermissionHash.apply(u)", true)
    end)
    return true
  end
  Player_Selectunit[sy] = unit
  HeroSelectString(wj, unit)
  return false
end

TrgHeroSelect = war3.CreateTrigger(function()
  HeroSelectConfirm(GetTriggerUnit(), GetTriggerPlayer())
end)
ac.loop(800, function(t)
  for i = 1, 6 do
    Player_Selectunit[i] = nil
  end
  ac.wait(160000, function()
    t:remove()
  end)
end)

function HeroSelectString(player, unit)
  player = getplayer(player)
  player:clearMsg()
  local u = getunit(unit)
  if u.type == HeroType["志贵"] then
    player:sendMsg("|cFF003399志|r|cFF990000贵|r\n|cFF3366FF我乃不用添灯油的暖炉|r")
    return
  end
  if u.type == HeroType["圣白莲"] then
    player:sendMsg("|cFF7DBEF1圣白莲\n防御型英雄|r\n|cFFFF9900模型归属：本图|r")
    return
  end
  if u.type == HeroType["里三"] then
    player:sendMsg("|cFF7DBEF1토키사키 쿠루미 (이면)\n직접 선택 가능. 빠르게 두 번 클릭하세요.|r")
    return
  end
  if u.type == HeroType["秦心"] then
    player:sendMsg("|cFF7DBEF1하타노 코코로\n직접 선택 가능. 빠르게 두 번 클릭하세요.\n|cFFFF9900모델 출처. 본 맵|r")
    return
  end
  if u.type == HeroType["贝洛妮卡"] then
    player:sendMsg("|cFF7DBEF1베로니카\n직접 선택 가능. 빠르게 두 번 클릭하세요.\n|cFFFF9900모델 출처. 링모|r")
    return
  end
  if u.type == HeroType["C呆"] then
    if HasHero_C(player.handle) or Mode_Dabamoshi then
    else
      Player_Selectunit[player.id] = nil
    end
    player:sendMsg("|cFF3399FF阿|r|cFF55A2FF尔|r|cFF77AAFF托|r|cFF99B2FF莉|r|cFFBBBBFF雅\n随机概率选取|r")
    return
  end
  if u.type == HeroType["史尔特尔"] then
    local b = HasHero_42(player.handle) or false
    if b or Mode_Dabamoshi then
    else
      Player_Selectunit[player.id] = nil
    end
    player:sendMsg("|cFF990000史|r|cFFAD0000尔|r|cFFC20000特|r|cFFD60000尔\n随机概率选取|r")
    return
  end
  if u.type == HeroType["千咲"] then
    local b = HasHero_Qianxiao(player.handle) or false
    if b or Mode_Dabamoshi then
    else
      Player_Selectunit[player.id] = nil
    end
    player:sendMsg("|cFFAF1D1D朽|r|cFFA02C2C叶|r|cFF923A3A千|r|cFF834949口关|r\n|cFFAF1D1D随机概率选取|r")
    return
  end
  if u.type == HeroType["八重樱"] then
    player:sendMsg("|cFF7DBEF1八重樱|r")
    return
  end
  if u.type == HeroType["妖梦"] then
    player:sendMsg("|cFF7DBEF1妖梦\n基础伤害难度相关\n无法使用枪械\n|cFFFF9900模型归属：ACGの竞技场|r\n|cFFFF0000特殊操作系统 不推荐新手使用|r")
    return
  end
  if u.type == HeroType["十六夜"] then
    player:sendMsg("|cFF7DBEF1十六夜\n完美潇洒女仆")
    u:animeact("spell")
    ac.wait(1000, function()
      u:animeact("stand")
    end)
    return
  end
  if u.type == HeroType["琪露诺"] then
    player:sendMsg("|cFF7DBEF1琪露诺\n幻想乡最强\n世界第一可爱|r")
    u:animeact("spell")
    ac.wait(1000, function()
      u:animeact("stand")
    end)
    return
  end
  if u.type == HeroType["魔理沙"] then
    player:sendMsg("|cFF7DBEF1魔理沙\n死亡不掉落物品 可以获得额外的补给与积分|r\n|cFFFF9900模型归属：蓬莱之旅|r")
    u:animeact("spell")
    ac.wait(1000, function()
      u:animeact("stand")
    end)
    return
  end
  if u.type == HeroType["灵梦"] then
    player:sendMsg("|cFF7DBEF1灵梦\n全能型英雄 拥有额外的力量成长与护甲|r\n|cFFFF9900模型归属：本图|r")
    u:animeact("spell")
    return
  end
  if u.type == HeroType["爱丽丝"] then
    player:sendMsg("|cFF7DBEF1爱丽丝\n输出型英雄|r\n|cFFFF9900模型归属：本图|r")
    u:animeact("spell")
    ac.wait(1000, function()
      u:animeact("stand")
    end)
    return
  end
  if u.type == HeroType["铃仙"] then
    player:sendMsg("|cFF7DBEF1铃仙\n初始伤害较低 发育型英雄\n拥有自身特殊的枪械射击系统与一把自己的专属武器|r\n|cFFFF9900模型归属：黎明幻想|r")
    u:animeact("attack")
    return
  end
  if u.type == HeroType["蕾米"] then
    player:sendMsg("|cFF7DBEF1蕾米莉亚\n高难特化型英雄|r\n|cFFFF9900模型归属：蓬莱之旅|r")
    u:animeact("attack")
    return
  end
  if u.type == HeroType["缇娜"] then
    if math.random(2) == 1 then
      player:sendMsg("|cFFFF99FF缇娜：お兄ちゃんこんばんは~|r")
    else
      player:sendMsg("|cFFFF99FF缇娜：空帮哇欧尼酱~|r")
    end
    return
  end
  if u.type == HeroType["切嗣"] then
    player:sendMsg("卫宫切嗣")
    return
  end
end
