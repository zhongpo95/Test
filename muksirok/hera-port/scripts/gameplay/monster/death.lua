-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local player = require("jh.ac.player")
local Court = require("gameplay.var.pools.mwx.danwanlunpo_runtime")
require("gameplay.monster.reward")
require("gameplay.monster.reward2")

local memory_warning = false
local function release_memory_if_available()
  if type(japi.ReleaseMemory) == "function" then
    japi.ReleaseMemory()
    return true
  end
  if not memory_warning then
    memory_warning = true
    require("hera_boot").note("DEFERRED ReleaseMemory: host cache API unavailable")
  end
  return false
end

function Monsterdeadfunc(unit, murder)
  local u = getunit(unit)
  local soc
  if murder == 0 or not murder then
    if u:hasdata("系统-最后伤害单位") then
      murder = u:getdata("系统-最后伤害单位")
    else
      murder = BOSS_DEATH
    end
  end
  soc = getunit(murder)
  local sy = soc.ownerid
  if sy <= 6 then
    soc = getunit(Hero[soc.ownerid])
  end
  if u:hasdata("BOSS-翁斯坦") then
    RemoveItemLua(u:getcountitem(1))
    RemoveItemLua(u:getcountitem(2))
  end
  AllNumofMonster = AllNumofMonster - 1
  u:groupremove(Group_Monster)
  if u:hasdata("系统-怪物模板") then
    u:deldata("系统-已精英化")
    u:buffset(u.handle, 10, "暂停")
    ShowUnit(u.handle, false)
    if not u:hasdata("系统-清除单位") then
      local x, y = u:getxy()
      local z = u:getface()
      local color = u:getdata("模型-色表")
      local tx = Effectcreate(u:getdata("模型-模型"), x, y, -1, u:getdata("模型-模型大小"), 0, z)
      SetEffectAnimation(tx, "death")
      SetEffectColor(tx, color[1], color[2], color[3])
      DestroyEffectLua(tx)
    end
    ac.wait(3000, function()
      MonsterPool:release(u)
    end)
    u:delskill("S0AK")
    u:delskill("S0C4")
    u:delskill("S0BO")
  elseif IsUnitType(u.handle, UNIT_TYPE_HERO) == false then
    u:setdata("系统-无视弹幕")
    u:timetoremove(3)
  end
  if u:hasdata("系统-清除单位") then
    return
  end
  if u:hasdata("系统-非BOSS/BOSS判定") then
    u:delskill("A020")
    u:deldata("系统-BOSS")
  end
  if u:hasdata("尖塔模式-精英怪") then
    u:delskill("A020")
    u:deldata("系统-BOSS")
    u:groupremove(Jianta_Jingying)
    local tm = Time_M - u:getdata("伤害统计-分钟数")
    local ts = Time_S - u:getdata("伤害统计-秒钟数")
    if ts < 0 then
      tm = tm - 1
      ts = ts + 60
    end
    local bossname = GetUnitName(u.handle)
    if u:hasdata("模型-名字") then
      bossname = u:getdata("模型-名字")
    end
    local ddstr = bossname .. " |cFF7DBEF1时间:" .. tm .. "分" .. ts .. "秒|r" .. "|cFFCC0000[输出统计]:|r"
    SendMsgAll(ddstr, 10)
    local players = {}
    
    local function addPlayer(name, score)
      table.insert(players, {name = name, score = score})
    end
    
    local alldamage = u:getdata("伤害统计-来自玩家累积伤害总和")
    ForGroupLuaNew(Group_PlayHero, function(xq)
      local sy = xq.ownerid
      addPlayer(xq:getplayername(), u:getdata("伤害统计-来自玩家累积伤害" .. sy))
    end)
    table.sort(players, function(a, b)
      return a.score > b.score
    end)
    for i, player in ipairs(players) do
      SendMsgAll("|cFFCC0000" .. i .. ". |r" .. player.name .. "|cFFCC0000 - 输出: " .. math.floor(player.score) .. "(" .. math.floor(player.score / alldamage * 100 + 0.01) .. "%)|r", 10)
    end
  end
  if u:iselite() then
    KillCount_System_Jy = KillCount_System_Jy + 1
    soc:changedata("击杀数量-精英", 1)
  end
  if u:isboss() then
    KillCount_System_BOSS = KillCount_System_BOSS + 1
    soc:changedata("击杀数量-BOSS", 1)
  end
  if not RewardStop and soc:isingroup(Group_PlayHero) then
    Court.on_kill(soc)
    monsterreward(soc.handle, u.handle)
  end
  monsterdeadskill(soc.handle, u.handle)
  if u:isboss() then
    bossdeath(u.handle, soc.handle)
  end
end

MonsterDead = war3.CreateTrigger(function()
  Monsterdeadfunc(GetTriggerUnit(), GetKillingUnit())
end)
ac.loop(FalshTrgLooptime * 1000, function()
  print("清除缓存")
  release_memory_if_available()
end)

function clearmemory()
  release_memory_if_available()
end

function monsterreward(unit, monster)
  local u = getunit(unit)
  local mon = getunit(monster)
  local sy = u.ownerid
  local x2, y2 = mon:getxy()
  local x, y = u:getxy()
  if u:hasdata("变异判定-浊心斯卡蒂") then
    unit = u:getdata("斯卡蒂-血亲")
    u = getunit(unit)
    sy = u.ownerid
    x, y = u:getxy()
  end
  KillCount[sy] = KillCount[sy] + 1
  KillCumCount[sy] = KillCumCount[sy] + 1
  u:setdata("系统-真杀敌判定")
  if (not BossBattle or Boolean_TestMode) and JiangLiShengyu > 0 then
    JiangLiShengyu = JiangLiShengyu - 1
    ForGroupLuaNew(Group_AllHero, function(xq)
      xq:addwood(1)
    end)
  else
  end
  do
    local gxsd = true
    local qyz
    if gxsd and (unit == Kuixingzhe_Tianchengzuo[1] or unit == Kuixingzhe_Tianchengzuo[2]) and Kuixingzhe_Tianchengzuo[2] ~= 0 then
      gxsd = false
      if unit == Kuixingzhe_Tianchengzuo[1] then
        qyz = Kuixingzhe_Tianchengzuo[2]
      else
        qyz = Kuixingzhe_Tianchengzuo[1]
      end
      local sy3 = getunit(qyz).ownerid
      KillCount[sy3] = KillCount[sy3] + 1
    end
    if gxsd and (unit == Qiyue_Murasame_Self or unit == Qiyue_Murasame_Master) and getunit(Qiyue_Murasame_Self):hasdata("丛雨-神化") then
      gxsd = false
      if unit == Qiyue_Murasame_Self then
        qyz = Qiyue_Murasame_Master
      else
        qyz = Qiyue_Murasame_Self
      end
      local sy3 = getunit(qyz).ownerid
      KillCount[sy3] = KillCount[sy3] + 1
      local zr = getunit(Qiyue_Murasame_Master)
      zr:changedata("司命杀敌计数", 1)
    end
    if gxsd and (unit == Danwei_Blank_Kong or unit == Danwei_Blank_Bai) and Weiyi_Dz[27] and Weiyi_Dz[28] then
      gxsd = false
      if unit == Danwei_Blank_Kong then
        qyz = Danwei_Blank_Bai
      else
        qyz = Danwei_Blank_Kong
      end
      local sy3 = getunit(qyz).ownerid
      KillCount[sy3] = KillCount[sy3] + 1
    end
  end
  if u:ishasskill(SKILL_TESHUYINGXIONG) and u.type ~= HeroType["志贵"] and u.type ~= HeroType["两仪式"] and u.type ~= HeroType["波风水门"] and u.type ~= HeroType["C呆"] and u.type ~= HeroType["莲华"] then
    KillCount_Katana[sy] = KillCount_Katana[sy] + 1
  end
  if u:hasdata("丛雨结缘") and not Boolean_Murasame[2] and (KillCount_Katana[sy] >= 250 or KillCount[sy] >= 500) then
    Boolean_Murasame[2] = true
    SendMsgAll("|cFF66FF99「盯——」|r")
  end
  if mon:hasdata("怪物-携带P点") then
    mon:deldata("怪物-携带P点")
    local tx = Effectcreate("Objects\\InventoryItems\\PotofGold\\PotofGold.mdl", x2, y2, -1)
    SetEffectColor(tx, 255, 55, 55)
    table.insert(DataGroup_Pdian, tx)
  end
  if mon:hasbuff("冰冻") and GetRandom100(1) then
    CreateItemLua(S2ID("I0A3"), x2, y2)
  end
  if mon:hasdata("深渊怪物-维波") then
    CreateItemLua(S2ID("I0I8"), x2, y2)
    if GetRandom100(25) then
      remainget(mon.handle, {
        Remains_Lv3
      }, "冰魔石")
    end
  end
  if mon:hasdata("怪物-动力装甲海盗") and GetRandom100(50) then
    CreateItemLua(S2ID("I0MR"), x2, y2)
  end
  if mon:hasdata("怪物-星际海盗") and GetRandom100(10) then
    CreateItemLua(S2ID("I0PS"), x2, y2)
  end
  if mon:hasdata("怪物-红龙") and GetRandom100(50) then
    CreateItemLua(S2ID("I0MQ"), x2, y2)
  end
  if mon:hasdata("深渊怪物-布兰兹") then
    CreateItemLua(S2ID("I0IA"), x2, y2)
    if GetRandom100(25) then
      remainget(mon.handle, {
        Remains_Lv3
      }, "火魔石")
    end
  end
  if mon:hasdata("深渊怪物-斯狄尔") then
    CreateItemLua(S2ID("I0A4"), x2, y2)
    if GetRandom100(25) then
      remainget(mon.handle, {
        Remains_Lv3
      }, "暗魔石")
    end
  end
  if mon:hasdata("深渊怪物-欧格罗斯") then
    CreateItemLua(S2ID("I0I9"), x2, y2)
    if GetRandom100(25) then
      remainget(mon.handle, {
        Remains_Lv3
      }, "风魔石")
    end
  end
  if mon:hasdata("BOSS-伊莎玛拉") then
    CreateItemLua(S2ID("I0IK"), x2, y2)
    local count1 = GetRandomInt(1, 5)
    for i = 1, count1 do
      CreateItemLua(S2ID("I0IH"), x2, y2)
    end
    local count2 = GetRandomInt(1, 25)
    for i = 1, count2 do
      CreateItemLua(S2ID("I08C"), x2, y2)
    end
  end
  if mon:isboss() then
    local bp = 500
    for i = 1, 6 do
      if Xuanze[i] then
        player[i]:addgold(bp)
        if unit == Hero[i] then
          Fenshu[i] = Fenshu[i] + 500
        end
      end
    end
  else
    local bp = Nandu_Jiangli_Gold
    if BossBattle and not ExBossBattle and not Boolean_TestMode then
      bp = bp * 0.1
    end
    bpget(unit, monster, bp, true)
    for i = 1, 6 do
      if Xuanze[i] then
        local xq = getunit(Hero[i])
        if unit ~= xq.handle then
          bpget(unit, monster, bp, false)
        end
      end
    end
  end
  local exp = 15 + (15 + Nandu_Jiangli_Exp) * Nandu_Jiangli_Exp / 2
  exp = exp * 0.9
  if BossBattle and not ExBossBattle and not Boolean_TestMode then
    exp = exp * 0.1
  end
  for i = 1, 6 do
    if Xuanze[i] then
      local xq = getunit(Hero[i])
      expget(xq, exp, mon)
    end
  end
  if not u:ishasskill(SKILL_TESHUYINGXIONG) then
    local add
    if mon:isboss() then
      add = 600
    elseif mon:iselite() then
      add = 60
    else
      add = 3
    end
    System_Jungong[sy] = System_Jungong[sy] + add * Correction_Jungong[sy]
  end
  local need = 9999
  if need < Fenshu[sy] and u:hasdata("花瓣-撒旦") and not u:hasdata("撒旦-无神论再神化") then
    u:setdata("撒旦-无神论再神化")
    u:sendmessage("|cFF990000撒|r|cFF830924旦|r|cFF6D1349-|r|cFF571C6D无|r|cFF422592神|r|cFF2C2EB6论|r")
    Hero_Shenhua_Left[sy] = Hero_Shenhua_Left[sy] + 1
    u:changedata("系统-神力承载上限", 4)
  end
  if mon:isboss() then
    Count_BOSSjisha[sy] = Count_BOSSjisha[sy] + 1
  elseif mon:iselite() then
    Count_Jingyingjisha[sy] = Count_Jingyingjisha[sy] + 1
  end
  if mon:isingroup(HellGroup) then
    local npc = getunit(NPC_XIAOAI)
    if npc:hasdata("真红-任务中") then
      local boss = npc:getdata("真红-任务中")
      boss:changedata("击杀深渊怪数", 1)
    end
    local jl = 1 + 1 * Nandu_Jianglixishu
    if GetRandom100(jl) then
    end
    if mon:istype("u04C") then
      for i = 1, 2 do
        if GetRandom100(50) then
          CreateItemLua(S2ID("I09Y"), x2, y2)
        end
      end
    end
    if mon:istype("u04E") then
      for i = 1, 3 do
        if GetRandom100(30) then
          CreateItemLua(S2ID("I0A2"), x2, y2)
        end
      end
    end
    if mon:istype("u04F") then
      for i = 1, 2 do
        if GetRandom100(25) then
          CreateItemLua(S2ID("I0A4"), x2, y2)
        end
      end
    end
    if mon:istype("u04G") then
      for i = 1, 2 do
        if GetRandom100(50) then
          CreateItemLua(S2ID("I0A3"), x2, y2)
        end
      end
    end
  end
  if u:hasdata("环境-海风") and not u:hasdata("隐藏职业-园丁") then
    local xg = 0.01
    if 0 < u:getdata("系统-血肉同化度") then
      xg = xg * (100 - u:getdata("系统-血肉同化度")) / 100
      if xg <= 0 then
        xg = 0
      end
    end
    local d = 0.02 * Hero_Tili_Max[sy] + 2
    u:lossstamina(d * xg)
  end
  if u:hasdata("环境-怒炎") then
    u:curehp(u.handle, 0, 8, 4)
  end
  if mon:isnormal() and (not (not (BossBattle and 3 <= Nandu_Choose) or Boolean_TestMode) or Keyan_Sishenzuzhou) and GetRandom100(90) then
    u:deldata("系统-真杀敌判定")
    return
  end
  if not u:hasdata("变异判定-歼灭天使") then
    monsterrewardget1(unit, monster)
    monsterrewardget2(unit, monster)
  end
  u:deldata("系统-真杀敌判定")
  local b = false
  if u:hasdata("变异判定-大祸津日神") and mon:hasdata("祸津神-灾祸层数") then
    b = true
  end
  if u:hasdata("遗物-守夜灯笼数量") then
    u:changedata("遗物-守夜灯笼惩罚", 4.0E-4)
    ChangeValue(DamageSystem_Sszengjia, sy, 6.0E-4)
    local jl = 25 * u:getdata("遗物-守夜灯笼数量")
    if GetRandom100(jl) then
      b = true
    end
  end
  if u:hasdata("狂化值") and GetRandom100(1 * u:getdata("狂化值")) then
    b = true
  end
  if u:hasdata("变异判定-虹猫") and GetRandom100(10) then
    b = true
  end
  if u:hasdata("隐藏职业-职业杀手") and GetRandom100(25) then
    b = true
  end
  if 0 < mon:getdata("精英特性-拥有数量") then
    b = true
    local bp = Nandu_Jiangli_Gold
    for i = 1, 6 do
      if Xuanze[i] then
        local xq = getunit(Hero[i])
        xq:addgold(bp)
        if xq.handle == unit then
          Fenshu[i] = Fenshu[i] + bp
          xq:addgold(bp)
          if 0 < u:getdata("残机可获取数") then
            u:changedata("残机所需分", -1 * bp)
            if 0 >= u:getdata("残机所需分") then
              u:changedata("残机剩余数量", 1)
              u:setusedfodd(u:getdata("残机剩余数量"))
              u:changedata("残机可获取数", -1)
              u:setdata("残机所需分", 2000)
            end
          end
        end
      end
    end
  end
  if u:hasdata("神器判定-红色樱花") and GetRandom100(10) then
    b = true
  end
  if u:hasdata("杨间-鬼血") and GetRandom100(20) then
    b = true
  end
  if u:hasdata("变异判定-红心女王") and GetRandom100(5) then
    b = true
  end
  if u:hasdata("神化判定-灾祸魔神") then
    if mon:isboss() then
      if u:getdata("灾祸等级") == 2 then
        u:setdata("灾祸魔神-BOSS击杀进阶")
      end
      u:addallstats(50)
      ChangeValue(Correction_Jzsh, sy, 0.03)
    elseif mon:iselite() then
      u:addallstats(5)
      ChangeValue(Correction_Jzsh, sy, 0.003)
    end
    if GetRandom100(25) then
      if b then
        u:addstr(1)
      else
        b = true
      end
    end
  end
  if 0 < u:getdata("食物-圣代杀戮祝福次数") and not b then
    b = true
    u:changedata("食物-圣代杀戮祝福次数", -1)
  end
  if GetRandom100(u:getdata("泽塔-额外杀敌概率")) then
    b = true
  end
  if u:hasdata("变异判定-杀戮天使") then
    b = false
  end
  if b then
    KillCount[sy] = KillCount[sy] + 1
    monsterrewardget1(unit, monster)
    monsterrewardget2(unit, monster)
  end
  if u:hasdata("神器判定-死神之镰") and not u:hasdata("原罪值-额外杀敌判定") and GetRandom100(88) then
    KillCount[sy] = KillCount[sy] + 1
    monsterrewardget1(unit, monster)
    monsterrewardget2(unit, monster)
  end
  if u:hasdata("莲华-万华镜杀敌") and not u:hasdata("原罪值-额外杀敌判定") and mon:isnormal() then
    local lh = u:getdata("莲华-万华镜来源")
    monsterrewardget1(lh.handle, monster)
    monsterrewardget2(lh.handle, monster)
  end
  if 0 < u:getdata("原罪值") and GetRandom100(5 * u:getdata("原罪值")) then
    if u:hasdata("原罪值-额外杀敌判定") then
      u:deldata("原罪值-额外杀敌判定")
      return
    else
      u:setdata("原罪值-额外杀敌判定")
      monsterreward(unit, monster)
    end
  end
end

function expget(u, exp, mon)
  local sy = u.ownerid
  local ea = Correction_Exp[sy]
  if u:ishasbuff("B077") then
    ea = ea + 0.1
  end
  if u:hasdata("付丧缘") then
    ea = ea + 0.1
    if u:hasdata("变异判定-付丧神") then
      ea = ea + 0.1
    end
  end
  if u:hasdata("星野爱-经验获取提升") then
    ea = ea + u:getdata("星野爱-经验获取提升")
  end
  if u:hasdata("秋穰子-丰收季节") then
    ea = ea + 0.2
  end
  if u:hasdata("物品-艾哲诅咒") or u:hasdata("物品-艾哲诅咒2") or u:hasdata("物品-艾哲诅咒3") then
    ea = ea - u:getdata("艾哲诅咒-惩罚值")
  end
  if u:hasdata("秋穰子-谷物神的允诺") then
    ea = ea + 0.2
  end
  if u:hasdata("变异判定-闪耀新星") then
    ea = ea + 0.2
  end
  if u:hasdata("变异判定-世代之力") then
    ea = ea + Group_Counts(Group_Xingcunzu) * 0.03
  end
  if u:hasdata("变异判定-旧神刻印") then
    ea = ea + 0.005 * u:getstate("外域变异")
  end
  if u:hasdata("变异判定-芙兰朵露") then
    ea = ea + 0.2
  end
  if mon then
    if mon:hasdata("神灵武佑标记") and u:hasdata("秦心-神乐-神武灵佑") then
      ea = ea + 0.25
    end
    if u:ishasskill("S03G") and mon:ishasskill("A0UO") and mon:getdata("流血层数") >= 3 then
      ea = ea + 0.15
    end
  end
  if u:hasdata("变异判定-医生") then
    ea = ea + 0.2
  end
  if u:hasdata("东风谷早苗-风祝的巫女") and u:hasdata("血统判定-风神") and u:hasdata("变异判定-奇迹の祝福") then
    ea = ea + 0.2
  end
  if u:hasdata("沙海之晶-计数") then
    local add = 0.025 * u:getdata("沙海之晶-计数")
    if u:hasdata("利比亚碎片-持有") then
      add = add * 2
    end
    ea = ea + add
  end
  if u:ishasitem("I08B") then
    ea = ea + 0.1
  end
  if u:ishasitem("I08S") then
    ea = ea + 0.1
  end
  if u:ishasitem("I06Z") and u:hasdata("东方角色") then
    ea = ea + 0.25
  end
  if u:ishasitem("I05V") then
    ea = ea + 0.25
  end
  if u:ishasitem("I049") then
    ea = ea + 0.1
  end
  if u:ishasitem("I03H") then
    ea = ea + 0.1
  end
  if u:hasdata("吉普利露-禁忌化") then
    ea = 0
    exp = 0
  end
  if 0 <= ea and 0 < exp then
    if u:hasdata("判定-迈达斯之手") then
      exp = exp * 2.1
    end
    if u:hasdata("判定-魔王之触") then
      exp = exp * 4.2
    end
    if u:hasdata("吞世之殿-无限之蛇次数") then
      for i = 1, u:getdata("吞世之殿-无限之蛇次数") do
        exp = exp * 0.1
      end
    end
    u:addexp(exp * ea)
    if u:islocal() then
      flytext({
        unit = u.handle,
        text = "+" .. math.floor(exp * ea) .. " Exp",
        size = 8,
        time = 1.5,
        r = 51,
        g = 155,
        b = 255,
        height = -125,
        yspeed = 0.01
      })
    end
  end
  return ea
end

function bpget(unit, monster, bp, boolean)
  local u = getunit(unit)
  local mon = getunit(monster)
  local sy = u.ownerid
  local ebp = 0
  local jf = Correction_Gold[sy]
  local ejf = 0
  if boolean == nil then
    boolean = true
  end
  if u:hasdata("利比亚碎片-持有") then
    ebp = ebp + 1
  end
  if u:hasdata("沙海之晶-计数") then
    local add = 0.25 * u:getdata("沙海之晶-计数")
    if u:hasdata("利比亚碎片-持有") then
      add = add * 2
    end
    ebp = ebp + add
  end
  if u:hasdata("灵梦-信仰心增加祈愿之仪") then
    ebp = ebp + 1
  end
  if u:hasdata("八重樱-购物达人") then
    ebp = ebp + 1
  end
  if u:hasdata("变异判定-特里诺") then
    ebp = ebp + 1
  end
  if u:hasdata("变异判定-莉耶芙") then
    ebp = ebp + 3
  end
  if u:hasdata("小天鹅-炸鱼薯条") then
    ebp = ebp + 1
  end
  if u:ishasitem(Weapons["观世正宗"]) then
    jf = jf + 0.15
  end
  if u:ishasitem("I0CI") then
    jf = jf + 0.1
  end
  if u:hasdata("艾哲诅咒") then
    jf = jf - u:getdata("艾哲诅咒-惩罚值")
  end
  if u:hasdata("万宝槌-财富许愿") then
    jf = jf + 0.5
  end
  if u:hasdata("变异判定-闪耀新星") then
    ejf = ejf + 0.15
  end
  if u:ishasbuff("B077") then
    ejf = ejf + 0.15
  end
  if 0 < bp then
    local abp = bp * jf + ebp
    local bbp = bp * ejf + 0
    if u:hasdata("判定-迈达斯之手") then
      bbp = 160
    end
    if u:hasdata("判定-魔王之触") then
      bbp = 320
    end
    u:addgold(abp + bbp)
    if boolean then
      Fenshu[sy] = Fenshu[sy] + abp
      if u:islocal() then
        flytext({
          unit = mon.handle,
          text = "+" .. math.floor(abp + bbp) .. "",
          size = 8,
          time = 1.5,
          r = 255,
          g = 255,
          b = 0,
          height = -50,
          yspeed = 0.01
        })
      end
      if 0 < u:getdata("残机可获取数") then
        u:changedata("残机所需分", -1 * abp)
        if 0 >= u:getdata("残机所需分") then
          u:changedata("残机剩余数量", 1)
          u:setusedfodd(u:getdata("残机剩余数量"))
          u:changedata("残机可获取数", -1)
          u:setdata("残机所需分", 2000)
        end
      end
    end
  end
  return ebp, jf, ejf
end

function monsterdeadskill(unit, monster)
  local u = getunit(unit)
  local mon = getunit(monster)
  local sy = u.ownerid
  local x, y = mon:getxy()
  if mon:hasdata("蝙蝠骑士-自爆") then
    Effectcreate("Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl", x, y)
    local bzsh = 300 * Nandu_Choose
    local fw = 275
    if Nandu_Choose >= 4 then
      fw = 350
    end
    for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(monster):ipairs() do
      xq = getunit(xq)
      local bzsh2 = bzsh
      if Nandu_Choose >= 3 then
        bzsh2 = bzsh + 0.1 * xq:getmaxhp()
        if Nandu_Choose >= 4 then
          bzsh2 = bzsh + 0.25 * xq:getmaxhp()
        end
      end
      DamageUnit({
        unit = xq.handle,
        source = mon.handle,
        damage = bzsh2,
        type = "能量",
        isnoarmor = false
      })
      if Nandu_Choose >= 3 then
        xq:buffset(monster, 0.5, "眩晕")
      end
    end
  end
  if mon:hasdata("暴食信徒-恢复") then
    Effectcreate("Abilities\\Spells\\Other\\HowlOfTerror\\HowlCaster.mdl", x, y)
    for _, xq in ac.selector():in_rangexy(x, y, 600):is_ally(monster):ipairs() do
      xq = getunit(xq)
      if not xq:isboss() and xq.handle ~= monster then
        xq:sethp(100, true)
        xq:effectadd("Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl", "chest")
      end
    end
  end
  if mon:hasdata("活尸-自爆") and Nandu_Choose >= 3 then
    Effectcreate("Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl", x, y)
    mon:animeact("birth")
    SetUnitTimeScale(monster, 1.25)
    local zs = 100
    ac.loop(100, function(t)
      zs = zs - 5
      mon:setcolor(255 - zs, zs, zs)
      if zs <= 0 then
        Effectcreate("Units\\Undead\\Abomination\\AbominationExplosion.mdl", x, y)
        Effectcreate("Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl", x, y, 0, 3)
        for _, xq in ac.selector():in_rangexy(x, y, 225):is_enemy(monster):ipairs() do
          xq = getunit(xq)
          local sh = 0.15 * xq:gethp() + u:getdata("怪物强度")
          DamageUnit({
            unit = xq.handle,
            source = mon.handle,
            damage = sh,
            type = "能量",
            isnoarmor = false
          })
        end
        t:remove()
      end
    end)
  end
  if mon:hasdata("余烬-自爆") and Nandu_Choose >= 3 then
    Effectcreate("Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl", x, y)
    Effectcreate("ATX\\[ATxNew]Fire_01.mdl", x, y, 2, 1)
    mon:animeact("birth")
    SetUnitTimeScale(monster, 1.25)
    local zs = 100
    ac.loop(100, function(t)
      zs = zs - 5
      mon:setcolor(255 - zs, zs, zs)
      if zs <= 0 then
        Effectcreate("ATX\\[ATxNew]Fire_08.mdl", x, y, 1, 1.5)
        Effectcreate("Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl", x, y, 0, 3)
        for _, xq in ac.selector():in_rangexy(x, y, 225):is_enemy(monster):ipairs() do
          xq = getunit(xq)
          local sh = 0.2 * xq:gethp() + u:getdata("怪物强度")
          DamageUnit({
            unit = xq.handle,
            source = mon.handle,
            damage = sh,
            type = "能量",
            isnoarmor = false
          })
        end
        t:remove()
      end
    end)
  end
  if mon:hasdata("水生村民-毒") and Nandu_Choose >= 3 then
    local vest = getunit(System_SkillVest)
    Effectcreate("ATX\\[ATxNew]Green_11.mdl", x, y, 0, 1)
    Effectcreate("Objects\\Spawnmodels\\NightElf\\NEDeathSmall\\NEDeathSmall.mdl", x, y, 0, 1)
    vest:addskill("A19Y")
    for _, xq in ac.selector():in_rangexy(x, y, 250):is_enemy(monster):ipairs() do
      xq = getunit(xq)
      if 0 >= xq:getdata("绝对闪避时间") then
        IssueTargetOrder(System_SkillVest, "shadowstrike", xq.handle)
      end
    end
    vest:delskill("A19Y")
  end
end
