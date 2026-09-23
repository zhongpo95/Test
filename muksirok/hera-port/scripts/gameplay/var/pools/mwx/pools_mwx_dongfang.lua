-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local keystring = "幻想乡"
Vars_Mwx_Dongfang_Lv1 = {}
Vars_Mwx_Dongfang_Lv2 = {
  {
    name = "小人族",
    clickfunc = function(u, ewl)
      if u:isalive() and u:getdata("幸运") >= 10 and u:ishasshw() and not Weiyi[20] then
        AdvanceGet["少名针妙丸"](u)
      end
    end,
    weight = 10,
    lv = 2,
    key = {"东方", "同奏"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:hasdata("变异判定-遗失之力") then
        b = false
      end
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("变异判定-" .. var.name)
      u:changedata(var.lv .. "阶精神变异数量", 1)
      MwxApplySpiritLoadByLv(u, var)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:sendmessage("|cFF1BE6B8你的身体变小了|r")
      ChangeValue(HeroMenu_Sbxs, sy, 0.03)
      u:addskill("S012")
      u:groupadd(Group_Xiaorenzu)
      local sl = 0
      ac.loop(3000, function()
        if u:isalive() then
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-0.12 * sl))
          ChangeValue(DamageSystem_Ssjianshao, sy, 1 - 0.06 * sl, 2)
          u:changedata("幸运", -1 * sl)
          if u:hasdata("变异判定-少名针妙丸") then
            sl = Group_Counts(Group_Xingcunzu)
          else
            sl = Group_Counts(Group_Xiaorenzu)
          end
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (0.12 * sl))
          ChangeValue(DamageSystem_Ssjianshao, sy, 1 - 0.06 * sl, 1)
          u:changedata("幸运", 1 * sl)
        end
      end)
      
      local function xuyuan(args)
        local text = args.chat
        if u:hasdata("万宝槌许愿") and u:isalive() then
          local b = false
          if text == "力量" then
            b = true
            u:sendmessage("你变强了！(提升0.5%+7力量 0.5%伤害加成 2%额外受伤)")
            local add = 0.01 * u:getoriginstr() + 7
            u:addstats(add, 0, 0)
            ChangeValue(DamageSystem_Shjc, sy, 0.005)
            ChangeValue(DamageSystem_Sszengjia, sy, 0.02)
          end
          if text == "速度" then
            b = true
            u:sendmessage("你变得更快了！(提升0.5%+7敏捷 10额外移速 1%暴击伤害 降低0.25体力上限)")
            local add = 0.01 * u:getoriginagi() + 7
            u:addstats(0, add, 0)
            ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 10)
            ChangeValue(DamageSystem_Baoshang, sy, 0.01)
            ChangeValue(Hero_Tili_Max, sy, -0.25)
          end
          if text == "智慧" then
            b = true
            u:sendmessage("你变得无比聪明！(提升0.5%+7智力 10%法术修正 100魔力值 降低2%生命上限)")
            local add = 0.01 * u:getoriginint() + 7
            u:addstats(0, 0, add)
            u:changedata("魔力值", 100)
            ChangeValue(Correction_Magic, sy, 0.001)
            u:changemaxhp(-0.02 * u:getmaxhp())
          end
          if b then
            u:deldata("万宝槌许愿")
          end
        end
      end
      
      local function daxuyuan(args)
        local text = args.chat
        if u:hasdata("万宝槌大许愿") and u:isalive() then
          local b = false
          local npc = getunit(NPC_BAYUNZI)
          local x, y = u:getxy()
          if text == "这就是最强的力量吗" and not npc:hasdata("万宝槌大许愿一") then
            b = true
            npc:setdata("万宝槌大许愿一")
            u:setdata("万宝槌-梦幻许愿")
            ChangeValue(DamageSystem_EndSh, sy, -0.03)
            u:sendmessage("|cFFFFCCFF你永远陷入了梦境之中\n①免疫时限伤害\n②挥动万宝槌不再消耗生命上限,同时使用时在15秒内获得一次护盾\n③提升30%终结减伤 降低3%终结伤害\n④自身伤害免疫与伤害闪避失效|r")
            PlayGlobalSound(Sound_WBCB_05)
            Effectcreate("ATx\\[ATxNew]Pink_06.mdl", x, y, 0, 4)
            ac.wait(1500, function()
              x, y = u:getxy()
              Effectcreate("ATx\\[ATxNew]Pink_01.mdl", x, y, 0, 2)
              ac.wait(500, function()
                for i = 1, 6 do
                  local x2, y2 = PolarXY(x, y, 225, 60 * i)
                  Effectcreate("ATx\\[ATxNew]Pink_01.mdl", x2, y2, 0, 2)
                end
              end)
            end)
          end
          if text == "我就是新世界的卡密" and not npc:hasdata("万宝槌大许愿一") then
            b = true
            npc:setdata("万宝槌大许愿二")
            u:setdata("万宝槌-新世界的卡密")
            u:become("王")
            u:uivar_add({
              keyname = "新世界的卡密",
              keytype = "传奇栏",
              text = "|cFFFFCC99新世界の卡密|r\n|cFFFFCC99神性 1\n提升[小人族数量*1.6%]伤害加成\n提升[小人族数量*8%]隔离减伤\n自身永久处于弱生命恢复抑制状态|r",
              icon = "war3mapImported\\BTNEwl_Wbc_Xinshijiedekami.blp"
            })
            ForGroupLuaNew(Group_Xiaorenzu, function(xq)
              local sy2 = xq.ownerid
              xq:setdata("新世界的卡密-减伤")
              ChangeValue(DamageSystem_Shjc, sy, 0.02)
            end)
            local gl = 0
            ac.loop(3000, function()
              ChangeValue(DamageSystem_Shjc, sy, 0.1 * -gl)
              gl = 0.16 * Group_Counts(Group_Xiaorenzu)
              ChangeValue(DamageSystem_Shjc, sy, 0.1 * gl)
            end)
            u:adddivinity(1)
            u:getgoddessforce(3, true)
            PlayGlobalSound(Sound_WBCB_01)
            u:additem("I08U")
            Effectcreate("ATx\\[ATxNew]White_08.mdl", x, y, 0, 4)
            ac.wait(1500, function()
              x, y = u:getxy()
              Effectcreate("ATx\\[ATxNew]White_15.mdl", x, y, 0, 2)
              ac.wait(500, function()
                for i = 1, 6 do
                  local x2, y2 = PolarXY(x, y, 225, 60 * i)
                  Effectcreate("ATx\\[ATxNew]White_15.mdl", x2, y2, 0, 1.5)
                end
              end)
            end)
          end
          if text == "这世上的财宝全都是本王的" and not npc:hasdata("万宝槌大许愿一") then
            b = true
            npc:setdata("万宝槌大许愿三")
            u:sendmessage("|cFFFFFF00你获得了无尽的财富,但是被黄金国度诅咒了\n①提升25%积分获取\n②翻倍当前可用积分与积分\n③降低99%药水成功率|r")
            Fenshu[sy] = Fenshu[sy] * 2
            u:addgold(u:getgold())
            u:setdata("万宝槌-财富许愿")
            PlayGlobalSound(Sound_WBCB_04)
            Effectcreate("ATx\\[ATxNew]Yellow_06.mdl", x, y, 0, 4)
            ac.wait(1500, function()
              x, y = u:getxy()
              Effectcreate("Abilities\\Spells\\Other\\Transmute\\PileofGold.mdl", x, y, 0, 2)
              ac.wait(500, function()
                for i = 1, 6 do
                  local x2, y2 = PolarXY(x, y, 225, 60 * i)
                  Effectcreate("Abilities\\Spells\\Other\\Transmute\\PileofGold.mdl", x2, y2, 0, 1.5)
                end
              end)
            end)
          end
          if text == "如梦一般的解决掉吧" and not npc:hasdata("万宝槌大许愿一") then
            b = true
            npc:setdata("万宝槌大许愿四")
            u:sendmessage("|cFFCC0000你的身体里涌出了一股前所未有的力量!同时你的戾气加重了！\n①单次提升当前暴击伤害的暴击伤害\n②单次提升4%伤害加成\n②单次提升40%终结受伤|r")
            if GetRandomInt(1, 2) == 1 then
              PlayGlobalSound(Sound_WBCB_02)
            else
              PlayGlobalSound(Sound_WBCB_03)
            end
            Effectcreate("ATx\\[ATxNew]Red_12.mdl", x, y, 0, 4)
            u:setdata("万宝槌-力量许愿")
            ChangeValue(DamageSystem_Shjc, sy, 0.04)
            ChangeValue(DamageSystem_Baoshang, sy, DamageSystem_Baoshang[sy] - 1)
            ac.wait(1500, function()
              x, y = u:getxy()
              Effectcreate("ATx\\[ATxNew]Red_02.mdl", x, y, 0, 2)
              ac.wait(500, function()
                for i = 1, 6 do
                  local x2, y2 = PolarXY(x, y, 225, 60 * i)
                  Effectcreate("ATx\\[ATxNew]Red_02.mdl", x2, y2, 0, 1.5)
                end
              end)
            end)
          end
          if b then
            u:deldata("万宝槌大许愿")
          end
        end
      end
      
      local p = getplayer(u.owner)
      p:addtrgevent("玩家-聊天", function(args)
        xuyuan(args)
        daxuyuan(args)
      end)
    end,
    effectname = "|cFFCC33FF小人族|r",
    effecttext = "|cFFCC33FF二阶\n东方 同奏\n万宝|r\n|cFFCC66FF开箱时几率获得万宝槌|r\n|cFFCC33FF小巧|r\n|cFFCC66FF提升20%移速\n提升0.06闪避系数|r\n|cFFCC33FF乐园|r\n|cFFCC66FF提升[在场小人族数量*2.5%]伤害加成\n提升[在场小人族数量*10%]追加减伤\n提升[在场小人族数量*1]幸运|r\n|cFF949596『来吧，让我们构筑起一个不会遗弃弱者的乐园吧！』|r",
    effectart = "war3mapImported\\BTNEwl_Xiaorenzheng.blp",
    test = [[
            18% 25% 10% = 53%
        ]]
  },
  {
    name = "遗失之力",
    weight = 10,
    lv = 2,
    key = {"战士", "东方"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:hasdata("变异判定-小人族") then
        b = false
      end
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      local x, y = u:getxy()
      u:setdata("变异判定-" .. var.name)
      u:changedata(var.lv .. "阶精神变异数量", 1)
      MwxApplySpiritLoadByLv(u, var)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:sendmessage("|cFF1BE6B8远古的遗失之力降临在了你身上|r")
      ChangeValue(Correction_Wineeffect, sy, 0.25)
      u:addstr(15)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local info = args.damageinfo
        if u:getluckrandom(5 * info.txgl) and not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 1)
          local txsh = 50 * u:getstr()
          if info.distance <= 300 then
            txsh = txsh * 2
          end
          if u:getdata("醉酒度") > 100 then
            txsh = txsh * 2
          end
          args.tg:effectadd("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl")
          args.tg:effectadd("war3mapImported\\fuzzystomp.mdx")
          DamageUnit({
            bj = "遗失之力(附伤)",
            unit = args.tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "震荡",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
        end
      end)
      AddUISkill({
        text = "遗失之力",
        unit = u.handle,
        cd = 100,
        icon = "war3mapImported\\BTNEwl_Missingpower.blp",
        func = function(args)
          local u = args.u
          if u:isalive() then
            local slk = require("jass.slk")
            u:effectadd("war3mapImported\\spellcardcall.mdx")
            u:playsound(MissingPower)
            u:changetimearmor(1000, 3)
            u:addstr(100)
            ac.wait(3000, function()
              u:addstr(-100)
            end)
            ac.wait(1000, function()
              local dx = slk.unit[u.type].modelscale
              local bs = 1
              local cs = 0
              local cs2 = 0
              local txsh = 50 * u:getstr()
              ac.loop(10, function(t)
                cs = cs + 1
                if cs <= 25 then
                  bs = bs + 0.12
                  u:setsize(dx * bs)
                end
                if 25 < cs and cs <= 100 then
                  cs2 = cs2 + 1
                  if cs2 == 3 then
                    cs2 = 0
                    local x, y = u:getxy()
                    for _, xq in ac.selector():in_rangexy(x, y, 250):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      xq:buffset(u.handle, 3, "眩晕")
                      unitmove({
                        unit = xq.handle,
                        time = 0.3,
                        distance = 25,
                        angle = AngleBetweenUnits(u.handle, xq.handle)
                      })
                      DamageUnit({
                        bj = "遗失之力(技能)",
                        unit = xq.handle,
                        source = u.handle,
                        damage = txsh,
                        level = 1,
                        type = "震荡",
                        isvest = true,
                        isattack = false,
                        isnoarmor = false,
                        element = "无"
                      })
                    end
                  end
                end
                if 100 <= cs then
                  bs = bs - 0.03
                  u:setsize(dx * bs)
                end
                if cs == 200 then
                  t:remove()
                  u:setsize(dx * 1)
                end
              end)
            end)
          end
        end
      })
    end,
    effectname = "|cFFCC3333遗失之力|r",
    effecttext = "|cFFCC3333二阶\n战士 东方\n酒鬼|r\n|cFF993333酒类伤害加成提升25%\n非酒类的食物体力恢复降低75%\n酒类的体力恢复提升50%\n醉酒惩罚降低50%|r\n|cFFCC3333怪力|r\n|cFF993333提升15点力量\n直接伤害时5%附加[力量*50]震荡伤害,300范围内时伤害翻倍,醉酒度大于100时伤害翻倍,冷却1秒|r\n|cFFCC3333巨化|r\n|cFF993333额外技能[巨化] 冷却100秒|r",
    effectart = "war3mapImported\\BTNEwl_Missingpower.blp",
    test = [[
            10% 10% 15% 10% = 45%
        ]]
  },
  {
    name = "酒之妖精",
    clickfunc = function(u)
      local sy = u.ownerid
      if u:isalive() and u:ishasshw() and u:getdata("ZUN-答题成功次数") >= 4 then
        AdvanceGet["神主ZUN"](u)
      end
    end,
    weight = 10,
    lv = 2,
    key = {"东方", "唯一"},
    unique = true,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("变异判定-" .. var.name)
      u:changedata(var.lv .. "阶精神变异数量", 1)
      MwxApplySpiritLoadByLv(u, var)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:chat("对对，虽然现在才说，告诉大家劫后传里的一个比较方便的小技巧")
      ac.wait(3000, function()
        u:chat("在暂停画面按下Q键，会直接回到标题画面的一个比较方便的小技巧")
      end)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:changedata("东方变异补正", 100)
        local sy2 = xq.ownerid
        ChangeValue(Correction_Exp, sy2, 0.05)
        local zs = 0
        ac.loop(10000, function()
          if xq:getdata("东方变异数量") > zs then
            local add3 = xq:getdata("东方变异数量") - zs
            if GetRandomInt(1, 2) == 1 then
              u:addrandomdamage(5 * add3)
            else
              u:addallstats(2 * add3)
            end
            zs = xq:getdata("东方变异数量")
          end
        end)
      end)
      AddAllSTexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if Boolean_Zun then
          if u:hasdata("变异判定-酒之妖精") then
            info.endup = info.endup - math.max(info.endup - 1, 0) * 0.9
          else
            info.endup = info.endup - math.max(info.endup - 1, 0) * 0.5
          end
        elseif Boolean_Zun2 then
          info.endup = info.endup + 0.2
        else
          info.endup = info.endup + 0.1
        end
      end)
      ac.loop(1000, function()
        u:changedata("酒豪-上瘾时间", -1)
        if not (not (u:getdata("酒豪-上瘾时间") > 0) and u:isingroup(Group_PlayHero)) or u.owner == Player(PLAYER_NEUTRAL_PASSIVE) or u:ishasskill("Aloc") then
          if Boolean_Zun == true then
            Boolean_Zun = false
            u:sendmessage("|cFF33CCCC酒瘾消退了|r")
          end
        elseif Boolean_Zun == false then
          Boolean_Zun = true
          u:sendmessage("|cFF33CCCC你酒瘾犯了|r")
        end
      end)
      u:setdata("酒豪-上瘾时间", 60)
      local zunquestion = require("gameplay.var.data.zun_wd")
      u:setdata("ZUN-问答时间", GetRandomInt(60, 240))
      ac.loop(1000, function(timer)
        u:changedata("ZUN-问答时间", -1)
        if u:hasdata("变异判定-神主ZUN") or u:getdata("ZUN-答题成功次数") >= 4 then
          timer:remove()
        end
        if u:getdata("ZUN-问答时间") <= 0 then
          u:setdata("ZUN-问答时间", GetRandomInt(60, 240))
          zunquestion(u, "神化")
        end
      end)
    end,
    effectname = "|cFF009999酒之妖精|r",
    effecttext = "|cFF009999二阶\n东方\n酒豪|r\n|cFF33CCCC酒使用冷却延长至10秒\n每使用一瓶酒50%提升1点属性,50%提升1%随机伤害修正|r\n|cFF009999替身.创造游戏程度的能力|r\n|cFF33CCCC提升全队100%东方变异补正\n提升全队5%经验获取\n全队获取东方变异时,其提升2点全属性或5%随机伤害修正|r\n|cFF009999无限续杯|r\n|cFF33CCCC每饮用一杯啤酒便立刻获得一杯啤酒|r\n|cFF009999适当、普通、完全|r\n|cFF33CCCC60秒饮过酒时提升全队10%终结伤害\n60秒内不饮酒便会降低自身90%、队友50%的额外终结增伤，不影响基础伤害|r\n|cFF009999神化条件:每隔一段时间,询问一个问题,答对四个后点击神化|r\n|cFF949596害人者终害己|r",
    effectart = "war3mapImported\\BTNEwl_Zun_01.tga"
  }
}

local function dongfangremove(u, var)
  u:deldata("变异判定-" .. var.name)
  if var.lv then
    u:changedata(var.lv .. "阶精神变异数量", -1)
  end
  MwxRemoveSpiritLoadByLv(u, var)
  if var.key then
    for index, value in ipairs(var.key) do
      u:changedata(value .. "变异数量", -1)
    end
  end
  var.uniqueact = false
  u:uivar_remove(var.name, "冥王栏")
  for index, value in ipairs(u.var["冥王星"]) do
    if value.name == var.name then
      table.remove(u.var["冥王星"], index)
    end
  end
end

local function suodingfangke(u, var)
  local xhz = {
    10,
    20,
    40,
    80
  }
  local xh = xhz[var.lv]
  local g = u:getdata("幻想乡-限时变异组")
  local run = false
  local index
  for i, value in ipairs(g) do
    if value == var.name then
      index = i
      run = true
      break
    end
  end
  if not run then
    return false
  end
  if xh <= u:getdata("幻想乡-P点") then
    u:changedata("幻想乡-住客数量", 1)
    MwxApplySpiritLoadByLv(u, var)
    u:changedata("幻想乡-P点", -xh)
    u:changedata("幻想乡-累积消耗P点", xh)
    local varbut = u:uivar_get(var.name, "冥王栏", "幻想乡")
    if u:islocal() and varbut.tubiao_xianshi then
      varbut.tubiao_xianshi:destroy()
    end
    table.remove(u:getdata("幻想乡-限时变异组"), index)
    u:sendmessage("|cFFFFCCFF[幻想乡]邀请了新住客:|r" .. var.effectname)
    return true
  else
    u:sendmessage("|cFFFFCCFFP点不足(所需" .. xh .. "点)|r")
    return false
  end
end

Vars_Mwx_Dongfang = {
  {
    name = "吃货",
    clickfunc = function(u, var)
      if u:getdata("返魂度") >= 1800 and u:ishasshw() and not u:hasdata("变异判定-西行寺幽幽子") and Weiyi[22] == false then
        AdvanceGet["西行寺幽幽子"](u)
      end
    end,
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"东方"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      u:setdata("返魂度", 0)
      ac.loop(1000, function(timer)
        if not u:isalive() then
          if u:hasdata("血统判定-幽灵") then
            u:changedata("返魂度", 2)
            u:changemaxhp(2)
            expget(u, u:getlevel() * 2)
          else
            u:changedata("返魂度", 1)
            u:changemaxhp(1)
            expget(u, u:getlevel() * 1)
          end
        end
        if u:getdata("返魂度") <= 0 then
          u:setdata("返魂度", 0)
        end
        if not u:hasdata("变异判定-" .. var.name) then
          timer:remove()
        end
      end)
      local add, gl
      ac.loop(10000, function(timer)
        if u:ishasitem("I06Z") then
          gl = 12
          add = 0.75
        else
          gl = 8
          add = 0.5
        end
        if u:isalive() and u:getluckrandom(gl) then
          local wp
          for i = 1, 6 do
            wp = u:getcountitem(i)
            if GetItemType(wp) == ITEM_TYPE_CHARGED and GetItemLevel(wp) ~= 3 then
              u:useitem(wp)
              ChangeValue(Correction_CureUp, sy, add)
              ac.wait(50, function()
                ChangeValue(Correction_CureUp, sy, -add)
              end)
              if u.type == HeroType["妖梦"] then
                u:changedata("返魂度", 100)
                u:changemaxhp(100)
                expget(u, u:getlevel() * 50)
                break
              end
              u:changedata("返魂度", 60)
              u:changemaxhp(60)
              expget(u, u:getlevel() * 30)
              break
            elseif i == 6 then
              u:sendmessage("|cFF1BE6B8你的肚子很饿……|r", 3)
              u:changedata("返魂度", -100)
            end
          end
        end
        if not u:hasdata("变异判定-" .. var.name) then
          timer:remove()
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
    end,
    effectname = "|cFFFF99FF吃货|r",
    effecttext = "|cFFFF99FF东方\n【阶级】1\n【所属】幻想乡\n【效果】\n获得返魂度时提升[获取值*1]生命上限与[获取值*等级/2]经验\n每10秒有8%几率自动吃掉身上的可以食用的任何消耗品且此次医疗修正提升50%\n每次成功自动吃到东西增加60点返魂度\n吃食物时提升1~20点返魂度\n死亡时每秒增加1点返魂度(拥有幽灵血统时翻倍)\n每饿一次肚子减少100点返魂度\n【额外】\n[左键]返魂度达到1800时点击神化\n[右键]如果是访客可以消耗P点邀请定居|r\n|cFF949596“早饭早饭早饭早饭早饭早饭早饭早饭早饭早饭早饭做好了没有”|r",
    effectart = "war3mapImported\\BTNEwl_Chihuo.blp"
  },
  {
    name = "抖M",
    weight = 100,
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    lv = 1,
    key = {"东方"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      if u:hasdata("变异判定-天子") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      local cs = 0
      ac.loop(1000, function(t)
        if u:isalive() then
          cs = cs + 1
          if cs == 30 then
            cs = 0
            u:curehp(u.handle, 0, 5, 1)
          end
        end
        if not u:hasdata("变异判定-抖M") then
          t:remove()
        end
      end)
      u:addstexiao(var.name, "受伤后效果", function(args)
        local sh = args.damage
        if 10 <= sh and u:hasdata("变异判定-抖M") then
          u:curehp(u.handle, 10, 0.1, 1)
          ChangeTimeValue(HeroMenu_HpChange_Inr, sy, 2, 15)
          u:changetimearmor(2, 30)
          u:addxp(1)
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
    end,
    effectname = "|cFF33FF33抖M|r",
    effecttext = "|cFF33FF33东方\n【阶级】1\n【所属】幻想乡\n【效果】\n受到大于10伤害时提升1点经验值\n受到大于10伤害时医疗恢复10+0.1%生命值并在15秒内提升2点护甲与2生命恢复\n每隔30秒恢复5%生命值\n【额外】\n[右键]如果是访客可以消耗P点邀请定居|r\n|cFF949596就算是抖M也好，变强吧。 |r",
    effectart = "war3mapImported\\BTNEwl_DouM.blp"
  },
  {
    name = "鸦天狗",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {
      "风",
      "东方",
      "天狗"
    },
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I0IL") then
        add = add + 2000
      end
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
      u:addskill("S0AJ")
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -25)
      u:deldata("S0AJ")
      dongfangremove(u, var)
    end,
    effectname = "|cFFADA198鸦天狗|r",
    effecttext = "|cFFADA198东方 风 天狗\n【阶级】1\n【所属】幻想乡\n【效果】\n提升25额外移速\n降低周围900范围单位25%移速\n【额外】\n[右键]如果是访客可以消耗P点邀请定居|r",
    effectart = "BTNEwl_Ytg.tga"
  },
  {
    name = "点线切割",
    rightclickfunc = function(u, var)
      if suodingfangke(u, var) then
        u:sendmessage("|cFF949596世间，黑白几何。|r", 3)
      end
    end,
    weight = 100,
    lv = 1,
    key = {
      "恶魔",
      "根源",
      "唯一"
    },
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("变异判定-芙兰酱") then
        add = add + 250
      end
      return add
    end,
    condition = function(u)
      local b = false
      if not Weiyi_Feishen[31] or u:hasdata("变异判定-芙兰酱") then
        b = true
      end
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      Weiyi_Feishen[31] = true
      coopjudge("超级厉害之歌", u)
      ChangeValue(DamageSystem_EndSh, sy, 0.003)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("变异判定-" .. var.name) and u:getluckrandom(5 * info.txgl) and (not tg:hasdata("点线切割-已伤害") or u:hasdata("羁绊-超级厉害之歌")) and not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 0.1)
          tg:setdata("点线切割-已伤害")
          tg:effectadd("AATX\\[AATxNew]Black08.mdl")
          tg:changearmor(-1000)
          DamageUnit({
            bj = "点线切割(附伤)",
            unit = tg.handle,
            source = u.handle,
            damage = info.yssh * 0.15,
            level = 5,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
          tg:changearmor(1000)
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      Weiyi_Feishen[31] = false
      ChangeValue(DamageSystem_EndSh, sy, -0.003)
    end,
    effectname = "|cFFFFFFFF点|r|cFFCCCCCC线|r|cFF999999切|r|cFF666666割|r",
    effecttext = "|cFFCCCCCC根源 唯一 恶魔\n【阶级】1\n【所属】幻想乡\n【效果】\n提升0.3%终结伤害\n直接伤害时5%对目标附带[伤害值*15%]物理抹除伤害\n(每个单位只触发一次,仅该次附伤计算时降低目标1000护甲)\n【额外】\n[右键]如果是访客可以消耗P点邀请定居|r",
    effectart = "war3mapImported\\btnewl_dianxianqiege.blp"
  },
  {
    name = "鲜红之月",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"吸血鬼", "黑暗"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      local xx = 0
      ac.loop(3000, function(timer)
        ChangeValue(DamageSystem_Xxzq, sy, -1 * xx)
        xx = 0.015 * u:getstate("吸血鬼变异")
        if IsTimeNight() then
          xx = xx * 2
        end
        ChangeValue(DamageSystem_Xxzq, sy, 1 * xx)
        if not u:hasdata("变异判定-" .. var.name) then
          ChangeValue(DamageSystem_Xxzq, sy, -1 * xx)
          timer:remove()
        end
      end)
      u:changedata("吸血鬼变异补正", 25)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      u:changedata("吸血鬼变异补正", -25)
    end,
    effectname = "|cFF990000鲜红之月|r",
    effecttext = "|cFF990000吸血鬼 黑暗\n【阶级】1\n【所属】幻想乡\n【效果】\n提升[1.5%*吸血鬼变异]伤害吸血效果\n夜晚效果翻倍\n提升25%吸血鬼变异补正\n【额外】\n[右键]如果是访客可以消耗P点邀请定居|r",
    effectart = "war3mapImported\\BTNEwl_Mwx_Xianhongzhiyue.blp"
  },
  {
    name = "铃兰花毒",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"毒", "东方"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(HeroMenu_HpChange_Inr, sy, 5)
      ChangeValue(Revise_PoisonResist, sy, 1)
      u:setdata("铃兰花毒组", CreateGroupLua())
      ac.loop(1000, function(timer)
        local g = u:getdata("铃兰花毒组")
        if type(g) ~= "table" or not g.list then
          print("[铃兰花毒] group 已失效，停止计时器")
          timer:remove()
          return
        end
        ForGroupLuaNew(g, function(xq)
          local cs = xq:getdata("花毒叠加层数")
          local txsh2 = 1000 * cs
          DamageUnit({
            bj = "铃兰花毒",
            unit = xq.handle,
            source = u.handle,
            damage = txsh2,
            level = 1,
            type = "灵力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "暗"
          })
          if cs <= 0 or not xq:isalive() then
            DestroyEffectLua(xq:getdata("花毒特效"))
            xq:deldata("花毒特效")
            xq:groupremove(g)
            xq:deldata("花毒叠加层数")
          end
        end)
        if not u:hasdata("变异判定-" .. var.name) then
          print("清除铃兰花毒组动作")
          u:deldata("铃兰花毒组")
          timer:remove()
        end
      end)
      u:addstexiao("铃兰花毒", "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("变异判定-" .. var.name) and not u:hasdata("铃蓝花毒-触发冷却") and u:getluckrandom(4 * info.txgl) then
          local g = u:getdata("铃兰花毒组")
          u:settimedata("铃蓝花毒-触发冷却", 1)
          local t = 7
          if tg:isnormal() then
            t = 15
          end
          tg:changetimedata("花毒叠加层数", 1, t)
          tg:groupadd(HpGroup)
          if not tg:isingroup(g) then
            tg:groupadd(g)
            tg:setdata("花毒特效", u:effectadd("Abilities\\Spells\\Other\\AcidBomb\\BottleImpact.mdl", "head", -1))
          end
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(HeroMenu_HpChange_Inr, sy, -5)
      ChangeValue(DamageSystem_Shjc, sy, -0.01)
    end,
    effectname = "|cFF1FBF00铃蓝花毒|r",
    effecttext = "|cFF1FBF00毒 东方\n【阶级】1\n【所属】幻想乡\n【效果】\n提升5生命恢复\n【甜蜜毒药】\n直接伤害时4%叠加目标一层花毒状态\n每秒附带[花毒层数*1000]暗属性灵力伤害\n抑制[花毒层数*10%]生命恢复效果,持续15(7.5)秒,可叠加,分立计时,触发冷却1秒\n【额外】\n[右键]如果是访客可以消耗P点邀请定居|r\n|cFF949596不仅是心充满了毒性,身体也会不断流溢出剧毒的气体,甚至能抗衡彼岸花|r",
    effectart = "war3mapImported\\BTNEwl_Linglanhuadu.blp"
  },
  {
    name = "瘟疫之体",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"毒", "东方"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      u:addskill("A0WT")
      u:addskill("S03R")
      ChangeValue(Revise_PoisonResist, sy, 1)
      ac.loop(1000, function()
        if u:isalive() then
          local x, y = u:getxy()
          for _, xq in ac.selector():in_rangexy(x, y, 600):is_enemy(u.handle):isingroup(Group_Monster):ipairs() do
            xq = getunit(xq)
            xq:groupadd(HpGroup)
          end
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
    end,
    effectname = "|cFF009933瘟疫之体|r",
    effecttext = "|cFF009933毒 东方\n【阶级】1\n【所属】幻想乡\n【效果】\n抑制周围600范围除自身外所有单位50%生命恢复\n【瘟疫散播】\n周围450范围除自身外所有单位会感染瘟疫,每秒受到1000点魔力伤害,持续2秒\n【额外】\n[右键]如果是访客可以消耗P点邀请定居|r\n|cFF949596能够操纵疾病的话,就用疾病来感染周围的人吧,当然是没有选择性的哦|r",
    effectart = "war3mapImported\\BTNEwl_Jibingzhiti.blp"
  },
  {
    name = "乐园的巫女",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"东方", "巫女"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(Correction_Gold, sy, 0.05)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(Correction_Gold, sy, -0.05)
    end,
    effectname = "|cFFFF9999乐园的巫女|r",
    effecttext = "|cFFFF9999东方 巫女\n【阶级】1\n【所属】幻想乡\n【效果】\n提升5%积分获取\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Lm_01"
  },
  {
    name = "普通的魔法使",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"东方", "魔导"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(Correction_Magic, sy, 0.0025000000000000005)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(Correction_Magic, sy, -0.0025000000000000005)
    end,
    effectname = "|cfffffc2e普通的魔法使|r",
    effecttext = "|cfffffc2e东方 魔导\n【阶级】1\n【所属】幻想乡\n【效果】\n提升25%法术伤害\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Molisha_01"
  },
  {
    name = "不动的大图书馆",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"东方", "魔导"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(Correction_Magic, sy, 0.0025000000000000005)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(Correction_Magic, sy, -0.0025000000000000005)
    end,
    effectname = "|cffcb47ff不动的大图书馆|r",
    effecttext = "|cffcb47ff东方 魔导\n【阶级】1\n【所属】幻想乡\n【效果】\n提升25%法术伤害\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Pql_01"
  },
  {
    name = "永远鲜红的幼月",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"东方", "吸血鬼"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(DamageSystem_Shjc, sy, 0.01)
      ChangeValue(DamageSystem_Xxz, sy, 2)
      local add = 0
      local xxz = 0
      ac.loop(3000, function(timer)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        ChangeValue(DamageSystem_Xxz, sy, -xxz)
        if IsTimeNight() then
          add = 0.1
          xxz = 2
        else
          add = 0
          xxz = 0
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        ChangeValue(DamageSystem_Xxz, sy, xxz)
        if not u:hasdata("变异判定-" .. var.name) then
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
          ChangeValue(DamageSystem_Xxz, sy, -xxz)
          timer:remove()
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(DamageSystem_Shjc, sy, -0.01)
      ChangeValue(DamageSystem_Xxz, sy, -2)
    end,
    effectname = "|cffff3838永远鲜红的幼月|r",
    effecttext = "|cffff3838东方 吸血鬼\n【阶级】1\n【所属】幻想乡\n【效果】\n提升1%伤害加成\n提升2伤害吸血\n夜晚以上效果翻倍\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Lmly_01"
  },
  {
    name = "完美而潇洒的女仆",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"东方", "女仆"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      u:addskill("S0CF")
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      u:delskill("S0CF")
    end,
    effectname = "|cff38a5ff完美而潇洒的女仆|r",
    effecttext = "|cff38a5ff东方 女仆\n【阶级】1\n【所属】幻想乡\n【效果】\n提升10%移速\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Xiaoye_01"
  },
  {
    name = "恶魔之妹",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"东方", "吸血鬼"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(DamageSystem_EndSh, sy, 0.0025000000000000005)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(DamageSystem_EndSh, sy, -0.0025000000000000005)
    end,
    effectname = "|cffac0000恶魔之妹|r",
    effecttext = "|cffac0000东方 吸血鬼\n【阶级】1\n【所属】幻想乡\n【效果】\n提升2.5%终结伤害\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Fldl_01"
  },
  {
    name = "半人半灵的亭师",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {
      "东方",
      "战士",
      "灵魂"
    },
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(Correction_Jzsh, sy, 0.015)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(Correction_Jzsh, sy, -0.015)
    end,
    effectname = "|cff36d30e半人半灵的亭师|r",
    effecttext = "|cff36d30e东方 战士 灵魂\n【阶级】1\n【所属】幻想乡\n【效果】\n提升1.5%近战伤害\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Ym_01"
  },
  {
    name = "华胥的亡灵",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"东方", "灵魂"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      u:changedata("闪避值", 15)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      u:changedata("闪避值", -15)
    end,
    effectname = "|cffdb5fdb华胥的亡灵|r",
    effecttext = "|cffdb5fdb东方 灵魂\n【阶级】1\n【所属】幻想乡\n【效果】\n提升15闪避值\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Yyz_01"
  },
  {
    name = "三途川的引渡人",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"东方", "灵魂"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(DamageSystem_Baoshang, sy, 0.1)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(DamageSystem_Baoshang, sy, -0.1)
    end,
    effectname = "|cffdb6478三途川的引渡人|r",
    effecttext = "|cffdb6478东方 灵魂\n【阶级】1\n【所属】幻想乡\n【效果】\n提升10%暴击伤害\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Xiaoting_01"
  },
  {
    name = "乐园的最高审判长",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"东方", "灵魂"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(DamageSystem_Baoji, sy, 5)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(DamageSystem_Baoji, sy, -5)
    end,
    effectname = "|cff21b351乐园的最高审判长|r",
    effecttext = "|cff21b351东方 灵魂\n【阶级】1\n【所属】幻想乡\n【效果】\n提升5%暴击率\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Sjyj_01"
  },
  {
    name = "蓬莱人之形",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"东方", "炎"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(HeroMenu_HpChange_MaxHp, sy, 0.25)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(HeroMenu_HpChange_MaxHp, sy, -0.25)
    end,
    effectname = "|cffff5227蓬莱人之形|r",
    effecttext = "|cffff5227东方 炎\n【阶级】1\n【所属】幻想乡\n【效果】\n提升0.25%生命恢复\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Mh_01"
  },
  {
    name = "知识与历史的半兽",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"东方", "兽"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(Correction_Exp, sy, 0.1)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(Correction_Exp, sy, -0.1)
    end,
    effectname = "|cffadffff知识与历史的半兽|r",
    effecttext = "|cffadffff东方 兽\n【阶级】1\n【所属】幻想乡\n【效果】\n提升10%经验获取\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Hy_01"
  },
  {
    name = "月之头脑",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"东方", "星"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      u:changedata("智力增幅", 0.025)
      u:addint(100)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      u:changedata("智力增幅", -0.025)
      u:addint(-100)
    end,
    effectname = "|cff828eff月之头脑|r",
    effecttext = "|cff828eff东方 星\n【阶级】1\n【所属】幻想乡\n【效果】\n提升2.5%智力\n提升100智力\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Byyl_01"
  },
  {
    name = "星弧破碎",
    rightclickfunc = function(u, var)
      local b = suodingfangke(u, var)
      if b then
        u:additem("I0HI")
      end
    end,
    weight = 100,
    lv = 2,
    key = {
      "东方",
      "唯一",
      "吸血鬼"
    },
    unique = true,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(DamageSystem_Baoji, sy, 5)
      ChangeValue(DamageSystem_Baoshang, sy, 0.25)
      u:addstexiao("星弧破碎特效", "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        if u:hasdata("变异判定-" .. var.name) and not tg:hasdata("星弧破碎减甲") then
          tg:setdata("星弧破碎减甲")
          tg:changearmor(-25)
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(DamageSystem_Baoji, sy, -5)
      ChangeValue(DamageSystem_Baoshang, sy, -0.25)
    end,
    effectname = "|cFFFF6699星弧破碎|r",
    effecttext = "|cFFFF6699唯一 吸血鬼\n【阶级】2\n【所属】幻想乡\n【效果】\n提升5%暴击率\n提升25%暴击伤害\n直接伤害时降低目标25点护甲,无法叠加\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Ewl_Xhps"
  },
  {
    name = "门番",
    clickfunc = function(u, var)
      local sy = u.ownerid
      local g = u:getdata("幻想乡-限时变异组")
      for i, value in ipairs(g) do
        if value == var.name then
          u:sendmessage("|cFFD86B63[门番]未定居")
          return
        end
      end
      if u:isalive() and u:getdata("红美铃-睡梦杀敌") >= 250 then
        AdvanceGet["红美铃"](u)
      end
    end,
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {
      "东方",
      "战士",
      "唯一"
    },
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(Correction_Jzsh, sy, 0.015)
      u:addstexiao(var.name, "杀敌效果", function(args)
        if u:hasdata("变异判定-" .. var.name) and u:hasbuff("睡眠") then
          ChangeValue(Correction_Jzsh, sy, 5.0E-5)
          u:addxp(5)
          u:changedata("红美铃-睡梦杀敌", 1)
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(Correction_Jzsh, sy, -0.015)
    end,
    effectname = "|cFFD86B63门番|r",
    effecttext = "|cFFD86B63东方 战士 唯一\n【阶级】2\n【所属】幻想乡\n【效果】\n提升1.5%近战伤害\n每10秒10%睡眠10秒\n【吾好梦中杀人】\n处于[睡眠]状态杀敌时提升0.005%近战伤害与5经验值\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "war3mapImported\\BTNEwl_Dakeshui.blp"
  },
  {
    name = "冥王" .. "八意永琳",
    clickfunc = function(u, var)
      local sy = u.ownerid
      if not u:hasdata("八意永琳-制药关闭") then
        u:sendmessage("|cff828eff[八意永琳]关闭制药")
        u:setdata("八意永琳-制药关闭")
      else
        u:sendmessage("|cff828eff[八意永琳]开启制药")
        u:deldata("八意永琳-制药关闭")
      end
    end,
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {"东方", "星"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      u:changedata("智力增幅", 0.05)
      u:addint(200)
      local zu = {
        "I0GO",
        "I02F",
        "I02H",
        "I02E",
        "I011",
        "I030",
        "I035",
        "I0J2",
        "I01Q",
        "I036",
        "I00J"
      }
      local cs = 0
      ac.loop(1000, function(timer)
        if u:isalive() and not u:hasdata("八意永琳-制药关闭") then
          cs = cs + 1
          if cs == 120 then
            cs = 0
            u:sendmessage("|cff828eff[八意永琳]制作所有药物程度的能力")
            u:additem(zu[GetRandomInt(1, #zu)])
          end
        end
        if not u:hasdata("变异判定-" .. var.name) then
          timer:remove()
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      u:changedata("智力增幅", -0.05)
      u:addint(-200)
    end,
    effectname = "|cff828eff八意永琳|r",
    effecttext = "|cff828eff东方 星\n【阶级】2\n【所属】幻想乡\n【效果】\n提升5%智力\n提升200智力\n【制作所有药物程度的能力】(点击切换开关)\n每120秒获得一瓶随机药剂\n【额外】\n[右键]如果是访客可以消耗P点邀请定居\n[左键]切换是否制药",
    effectart = "Th_Byyl_02"
  },
  {
    name = "冥王" .. "上白泽慧音",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {"东方", "兽"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(Correction_Exp, sy, 0.2)
      u:addstexiao(var.name, "过波时效果", function(args)
        if u:hasdata("变异判定-" .. var.name) then
          u:sendmessage("|cffadffff[上白泽慧音]吞噬历史程度的能力|r")
          ChangeValue(Correction_Exp, sy, 0.03)
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(Correction_Exp, sy, -0.2)
    end,
    effectname = "|cffadffff上白泽慧音|r",
    effecttext = "|cffadffff东方 兽\n【阶级】2\n【所属】幻想乡\n【效果】\n提升20%经验获取\n【吞噬历史程度的能力】\n过波时提升3%经验获取\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Hy_02"
  },
  {
    name = "冥王" .. "藤原妹红",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {"东方", "炎"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(HeroMenu_HpChange_MaxHp, sy, 0.5)
      u:changedata("系统-生命恢复增强", 0.1)
      ChangeValue(HeroMenu_HpForever_MaxHp, sy, 0.5)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(HeroMenu_HpChange_MaxHp, sy, -0.5)
      u:changedata("系统-生命恢复增强", -0.1)
      ChangeValue(HeroMenu_HpForever_MaxHp, sy, -0.5)
    end,
    effectname = "|cffff5227藤原妹红|r",
    effecttext = "|cffff5227东方 炎\n【阶级】2\n【所属】幻想乡\n【效果】\n提升0.5%生命恢复\n【不老不死的程度的能力】\n提升0.5%永恒恢复\n提升10%生命恢复效果\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Mh_02"
  },
  {
    name = "冥王" .. "四季映姬",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {"东方", "灵魂"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(DamageSystem_Baoji, sy, 10)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("变异判定-" .. var.name) and not u:hasdata(var.name .. "-特效冷却") and not tg:hasdata("四季-有罪") and u:getluckrandom(5 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 1)
          tg:setdata("四季-有罪")
        end
      end)
      u:addstexiao(var.name, "暴击系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("变异判定-" .. var.name) and tg:hasdata("诗乃-第一发暴击强化") then
          info.bjl = info.bjl + 10
        end
      end)
      u:addstexiao(var.name, "受伤后效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("变异判定-" .. var.name) and not tg:hasdata("四季-有罪") then
          tg:setdata("四季-有罪")
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(DamageSystem_Baoji, sy, -10)
    end,
    effectname = "|cff21b351四季映姬|r",
    effecttext = "|cff21b351东方 灵魂\n【阶级】1\n【所属】幻想乡\n【效果\n提升10%暴击率\n【判断是非黑白程度的能力】\n直接伤害时5%或自身受到伤害时,对目标施加[有罪]状态,冷却1秒\n[有罪]目标伤害能力降低10%\n自身对[有罪]目标提升10%暴击率\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Sjyj_02"
  },
  {
    name = "冥王" .. "小野塚小町",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {"东方", "灵魂"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(DamageSystem_Baoshang, sy, 0.25)
      u:changedata("系统-固有额外移速", 50)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(DamageSystem_Baoshang, sy, -0.25)
      u:changedata("系统-固有额外移速", -50)
    end,
    effectname = "|cffdb6478小野塚小町|r",
    effecttext = "|cffdb6478东方 灵魂\n【阶级】2\n【所属】幻想乡\n【效果】\n提升25%暴击伤害\n【操纵距离程度的能力】\n提升50固有额外移速\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Xiaoting_02"
  },
  {
    name = "冥王" .. "西行寺幽幽子",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {"东方", "灵魂"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      u:changedata("闪避值", 25)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("变异判定-" .. var.name) and not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(1 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 1)
          if tg:isboss() then
            LossHpUnit({
              u = u,
              tg = tg,
              damage = 0,
              perhp = 1,
              maxhp = 0,
              bj = "[生命损耗]幽幽子操纵死亡的能力"
            })
          elseif tg:iselite() then
            tg:losshp(u, 0, 0, 10)
          else
            tg:kill()
          end
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      u:changedata("闪避值", -25)
    end,
    effectname = "|cffdb5fdb西行寺幽幽子|r",
    effecttext = "|cffdb5fdb东方 灵魂\n【阶级】2\n【所属】幻想乡\n【效果】\n提升25闪避值\n【操纵死亡的能力】\n直接伤害时1%即死目标(精英10%最大生命值/BOSS1%当前生命值),冷却1秒\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Yyz_02"
  },
  {
    name = "冥王" .. "魂魄妖梦",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {
      "东方",
      "战士",
      "灵魂"
    },
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(Correction_Jzsh, sy, 0.025)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("变异判定-" .. var.name) then
          info.damage = info.damage * 1.04
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(Correction_Jzsh, sy, -0.025)
    end,
    effectname = "|cff36d30e魂魄妖梦|r",
    effecttext = "|cff36d30e东方 战士 灵魂\n【阶级】2\n【所属】幻想乡\n【效果】\n提升2.5%近战伤害\n【使用剑术程度的能力】\n提升4%近战伤害(独立)\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Ym_02"
  },
  {
    name = "冥王" .. "芙兰朵露",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {
      "东方",
      "吸血鬼",
      "恶魔"
    },
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(DamageSystem_EndSh, sy, 0.005000000000000001)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("变异判定-" .. var.name) and not tg:hasdata(var.name .. "-提升受伤") then
          tg:setdata(var.name .. "-提升受伤")
          tg:changedata("怪物-额外受伤", 0.08)
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(DamageSystem_EndSh, sy, -0.005000000000000001)
    end,
    effectname = "|cffac0000芙兰朵露|r",
    effecttext = "|cffac0000东方 吸血鬼 恶魔\n【阶级】2\n【所属】幻想乡\n【效果】\n提升0.5%终结伤害\n【把所有存在之物都破坏掉的程度的能力】\n直接伤害时提升目标8%额外受伤,无法叠加\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Fldl_02"
  },
  {
    name = "冥王" .. "十六夜咲夜",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {"东方", "吸血鬼"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      u:addskill("S0CG")
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("变异判定-" .. var.name) and not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 2)
          tg:buffset(u.handle, 1, "暂停")
        end
      end)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("变异判定-" .. var.name) and tg:hasbuff("暂停") then
          info.end2 = info.end2 + 0.06
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      u:delskill("S0CG")
    end,
    effectname = "|cff38a5ff十六夜|r",
    effecttext = "|cff38a5ff东方 女仆\n【阶级】2\n【所属】幻想乡\n【效果】\n提升20%移速\n【操纵时间程度的能力】\n直接伤害时10%时停目标1秒,冷却2秒\n对时停单位提升6%伤害\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Xiaoye_02"
  },
  {
    name = "冥王" .. "蕾米莉亚",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {"东方", "吸血鬼"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(DamageSystem_Xxz, sy, 5)
      local add = 0
      local xxz = 0
      ac.loop(3000, function(timer)
        ChangeValue(DamageSystem_Xxz, sy, -xxz)
        if IsTimeNight() then
          xxz = 5
        else
          xxz = 0
        end
        ChangeValue(DamageSystem_Xxz, sy, xxz)
        if not u:hasdata("变异判定-" .. var.name) then
          ChangeValue(DamageSystem_Xxz, sy, -xxz)
          timer:remove()
        end
      end)
      u:changedata("幸运", 1)
      u:changedata("幸运系数", 0.1)
      u:addstexiao(var.name, "暴击系统触发效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("变异判定-" .. var.name) and not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 1)
          ChangeTimeValue(DamageSystem_Baoji, sy, 1, 10)
          ChangeTimeValue(DamageSystem_Shjc, sy, 0.003, 10)
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(DamageSystem_Xxz, sy, -5)
      u:changedata("幸运", -1)
      u:changedata("幸运系数", -0.1)
    end,
    effectname = "|cffff3838蕾米莉亚|r",
    effecttext = "|cffff3838东方 吸血鬼\n【阶级】2\n【所属】幻想乡\n【效果】\n提升5伤害吸血\n夜晚以上效果翻倍\n【操纵命运程度的能力】\n提升1幸运\n提升0.1幸运系数\n暴击时提升1%暴击率与0.3%伤害加成,持续10秒,冷却1秒\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Lmly_02"
  },
  {
    name = "冥王" .. "博丽灵梦",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {"东方", "巫女"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(Correction_Gold, sy, 0.075)
      u:changedata("系统-飞行强度", 100)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("变异判定-" .. var.name) and u:getluckrandom(10 * info.txgl) and not u:hasdata(var.name .. "-特效冷却") then
          local txsh = 1000 * u:getlevel()
          u:settimedata(var.name .. "-特效冷却", 2)
          tg:buffset(u.handle, 1, "眩晕")
          DamageUnit({
            bj = "灵梦(附伤)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "灵力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(Correction_Gold, sy, -0.075)
      u:changedata("系统-飞行强度", -100)
    end,
    effectname = "|cFFFF9999博丽灵梦|r",
    effecttext = "|cFFFF9999东方 巫女\n【阶级】2\n【所属】幻想乡\n【效果】\n提升7.5%积分获取\n【空中飞行的程度能力】\n提升100飞行强度\n直接伤害时10%附带[等级*1000]灵力伤害与1秒眩晕,冷却2秒\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Lm_02"
  },
  {
    name = "冥王" .. "雾雨魔理沙",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {"东方", "魔导"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(Correction_Magic, sy, 0.005000000000000001)
      local jc = 0
      ac.loop(3000, function(timer)
        ChangeValue(Correction_Magic, sy, -jc)
        jc = 0.02 * u:getstate("魔导变异")
        ChangeValue(Correction_Magic, sy, jc)
        if not u:hasdata("变异判定-" .. var.name) then
          ChangeValue(Correction_Magic, sy, -jc)
          timer:remove()
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("变异判定-" .. var.name) and u:getluckrandom(10 * info.txgl) and not u:hasdata(var.name .. "-特效冷却") then
          local txsh = 1000 * u:getlevel()
          u:settimedata(var.name .. "-特效冷却", 1)
          DamageUnit({
            bj = "魔理沙(附伤)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "灵力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无",
            extradata = {"法术", "魔导"}
          })
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(Correction_Magic, sy, -0.005000000000000001)
    end,
    effectname = "|cfffffc2e雾雨魔理沙|r",
    effecttext = "|cfffffc2e东方 魔导\n【阶级】2\n【所属】幻想乡\n【效果】\n提升50%法术伤害\n【使用魔法程度的能力】\n提升[魔导变异*2%]法术伤害\n直接伤害时10%附带[等级*1000]灵力(法术,魔导)伤害,冷却1秒\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Molisha_02"
  },
  {
    name = "冥王" .. "帕秋莉",
    rightclickfunc = function(u, var)
      suodingfangke(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {"东方", "魔导"},
    unique = false,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(Correction_Magic, sy, 0.005000000000000001)
      u:addstexiao(var.name, "伤害系统计算效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("变异判定-" .. var.name) and info.xs_fs == 0 and (info.damagetype == "灵力" or info.damagetype == "魔力") then
          info.xs_fs = 0.1
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      dongfangremove(u, var)
      ChangeValue(Correction_Magic, sy, -0.005000000000000001)
    end,
    effectname = "|cffcb47ff帕秋莉.诺蕾姬|r",
    effecttext = "|cffcb47ff东方 魔导\n【阶级】2\n【所属】幻想乡\n【效果】\n提升50%法术伤害\n【使用魔法程度的能力】\n造成魔力或灵力伤害时如果未享受法术伤害,也会享受10%法术伤害\n【额外】\n[右键]如果是访客可以消耗P点邀请定居",
    effectart = "Th_Pql_02"
  }
}
