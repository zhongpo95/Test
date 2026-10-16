-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local slk = require("jass.slk")
local OshinoTaboo = require("gameplay.var.advance.oshino_taboo")

function Zaomiao_xinyangzengjia(u, add)
  local sy = u.ownerid
  if add + u:getdata("东风谷早苗-信仰之力") >= 100 then
    add = 100 - u:getdata("东风谷早苗-信仰之力")
  end
  if 0 < add then
    u:changedata("东风谷早苗-信仰之力", add)
    local sj = GetRandomInt(1, 7)
    u:sendmessage("|cFF66FF99信仰之力增加了|r")
    if sj == 1 then
      ChangeValue(DamageSystem_Shjc, sy, 0.001)
    end
    if sj == 2 then
      ChangeValue(DamageSystem_Baoshang, sy, 0.01)
    end
    if sj == 3 then
      ChangeValue(DamageSystem_Shjc, sy, 0.001)
    end
    if sj == 4 then
      ChangeValue(DamageSystem_Shjc, sy, 0.001)
    end
    if sj == 5 then
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.99, 1)
    end
    if sj == 6 then
      u:addrandomstats(1)
    end
  end
  if u:hasdata("变异判定-奇迹の现人神") then
    local count = u:getdata("东风谷早苗-信仰之力")
    if not u:hasdata("东风谷早苗-风之祈愿") and 40 <= count then
      u:setdata("东风谷早苗-风之祈愿")
      u:sendmessage("|cFFFFFF33[风之祈愿]|r\n|cFF66FF99提升15%经验获取\n提升[66*信仰之力]弹幕伤害|r\n|cFFFFFF33[风之息]|r\n|cFF66FF99造成伤害时5%向前方吹起一阵风造成[5000+英雄等级*300]纯粹伤害 击退500码并眩晕1秒|r")
      ChangeValue(Correction_Exp, sy, 0.15)
      local dskill = S2ID("A0AF")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          local ewl = getunit(args.unit)
          if 2800 <= dis then
            b = false
            u:sendmessage("|cFF7DBEF1距离超过2800|r")
          end
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            local mj = u:createunit("u05F", x2, y2)
            local cs = 0
            ac.loop(100, function(timer)
              cs = cs + 1
              mj:setsize(1 + cs)
              if cs == 30 then
                mj:remove()
                timer:remove()
              end
            end)
            for _, xq in ac.selector():in_rangexy(x2, y2, 1500):ipairs() do
              xq = getunit(xq)
              if xq:is_enemy(u.handle) then
                xq:buffset(u.handle, 15, "破坏-伤害抗性")
                DamageUnit({
                  bj = "早苗风之息",
                  unit = xq.handle,
                  source = u.handle,
                  damage = 50000,
                  level = 1,
                  type = "灵力",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "风",
                  extradata = {""}
                })
              elseif xq:isingroup(Group_PlayHero) then
                local sy2 = xq.ownerid
                xq:effectadd("war3mapImported\\Area_Jinguangfuzhen.mdx", "origin", 15)
                ChangeTimeValue(DamageSystem_Ssjianshao, sy2, 0.5, 15, 1)
              end
            end
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
    end
    if not u:hasdata("东风谷早苗-诹访子的加护") and 55 <= count then
      u:setdata("东风谷早苗-诹访子的加护")
      u:sendmessage("|cFFFFFF33[诹访子的加护]|r\n|cFF66FF99每60秒随机发动以下一种效果：\n坤神招来 轮：向周围丢出两对铁轮，该铁轮可在单位之间弹射，弹射附带[10000+400x(英雄等级+信仰之力)]物理伤害,每次弹射提升5%伤害，最多弹射12下\n坤神招来 阱：每秒眩晕自身发动时位置周围1200范围单位1.5秒并破坏其伤害免疫抗性,持续10秒\n坤神招来 盾: 获得3秒绝对闪避状态并在30秒内提升25护甲与25%受伤减少|r")
      ac.loop(60000, function()
        if u:isalive() then
          local sj = GetRandomInt(1, 3)
          local x, y = u:getxy()
          if sj == 1 then
            u:sendmessage("|cFFFFFF33坤神招来 轮|r")
            Effectcreate("ATx\\[ATxNew]White_02.mdl", x, y, 0, 1.5)
            for i = 1, 2 do
              local mj = u:createunit("u091", x, y)
              mj:setguard(u.handle)
              mj:setdata("召唤物-坤轮")
              mj:groupadd(u:getdata("召唤物组"))
              mj:groupadd(Group_ZhaohuanwuAll)
              mj:setdata("附带伤害", 10000 + 400 * (u:getlevel() + count))
              ac.wait(5000, function()
                mj:groupremove(Group_ZhaohuanwuAll)
                mj:groupremove(u:getdata("召唤物组"))
                mj:remove()
              end)
            end
          end
          if sj == 2 then
            u:sendmessage("|cFFFFFF33坤神招来 阱|r")
            Effectcreate("ATx\\[ATxNew]Yellow_06.mdl", x, y, 0, 2)
            Effectcreate("ATx\\[ATxNew]Yellow_03.mdl", x, y, 10, 1.5)
            ac.timer(1000, 10, function()
              Effectcreate("ATx\\[ATxNew]White_02.mdl", x, y, 0, 3)
              for _, xq in ac.selector():in_rangexy(x, y, 1200):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:buffset(u.handle, 1.5, "眩晕")
                xq:buffset(u.handle, 1.5, "破坏-伤害抗性")
              end
            end)
          end
          if sj == 3 then
            u:sendmessage("|cFFFFFF33坤神招来 盾|r")
            Effectcreate("ATx\\[ATxNew]White_02.mdl", x, y, 0, 1.5)
            u:effectadd("Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl", "origin", 3)
            u:buffset(u.handle, 3, "绝对闪避")
            ChangeTimeValue(DamageSystem_Ssjianshao, sy, 0.75, 30, 1)
            u:changetimearmor(25, 30)
          end
        end
      end)
    end
    if not u:hasdata("东风谷早苗-神奈子的加护") and 70 <= count then
      u:setdata("东风谷早苗-神奈子的加护")
      u:sendmessage("|cFFFFFF33[神奈子的加护]|r\n|cFF66FF99乾神招来 风：使自身处于飞行状态并提升400额外移速,持续20秒\n乾神招来 突：提升3%近战伤害,并使位移技能绝对闪避时间提升0.15秒,持续20秒\n乾神招来 柱：在所处的位置召唤一根御柱，持续嘲讽1000范围内单位，同时每秒消除500码内的地方单位精英特性10秒,持续10秒|r")
      ac.loop(60000, function()
        if u:isalive() then
          local sj = GetRandomInt(1, 3)
          local x, y = u:getxy()
          if sj == 1 then
            u:sendmessage("|cFFFFFF33乾神招来 风|r")
            Effectcreate("ATx\\[ATxNew]White_02.mdl", x, y, 0, 1.5)
            u:buffset(u.handle, 20, "飞行")
            ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 200, 20)
          end
          if sj == 2 then
            u:sendmessage("|cFFFFFF33乾神招来 突|r")
            Effectcreate("ATx\\[ATxNew]White_02.mdl", x, y, 0, 1.5)
            u:effectadd("Abilities\\Spells\\Items\\ClarityPotion\\ClarityTarget.mdl", "chest", 20)
            u:settimedata("乾神招来突强化", 20)
          end
          if sj == 3 then
            u:sendmessage("|cFFFFFF33乾神招来 柱|r")
            Effectcreate("ATx\\[ATxNew]Dust_03.mdl", x, y, 0, 5)
            Effectcreate("ATx\\[ATxNew]Dust_33.mdl", x, y, 0, 5)
            Effectcreate("ATx\\[ATxNew]Dust_01.mdl", x, y, 0, 5)
            do
              local mj = u:createunit("o005", x, y)
              mj:timetoremove(10)
              for i = 1, 6 do
                Effectcreate("Abilities\\Spells\\Other\\Andt\\Andt.mdl", x, y, 10, 2, 0, i * 60)
              end
              ac.timer(1000, 10, function()
                for _, xq in ac.selector():in_rangexy(x, y, 1000):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  xq:removecharacteristics(10)
                end
              end)
            end
          end
        end
      end)
    end
    if not u:hasdata("东风谷早苗-风雨湖的神通者") and 85 <= count then
      u:setdata("东风谷早苗-风雨湖的神通者")
      u:sendmessage("|cFFFFFF33[神の风]|r\n|cFF66FF99提升3%伤害加成\n对BOSS提升25%论外减伤\n受到弹幕伤害减半\n每隔15秒清除一次自身负面状态|r\n|cFFFFFF33[风雨湖的神通者]|r\n|cFF66FF99在自身周围形成风场，触碰到敌方单位时，将其击飞350码并眩晕1秒，辀")
      ChangeValue(DamageSystem_Shjc, sy, 0.03)
      u:addskill("S06A")
      
      local function chattrg(args)
        if args.chat == "开" and u:isalive() and not u:hasdata("冷却中-早苗开水之日") then
          u:settimedata("冷却中-早苗开水之日", 480)
          ac.wait(480000, function()
            u:sendmessage("|cFF66FF99开海[海水分开之日]冷却完毕|r")
          end)
          local x, y = u:getxy()
          local jd = u:getface()
          ShowUnit(u.handle, false)
          local mj = u:createunit("u08M", x, y, jd)
          Effectcreate("ATx\\[ATxNew]Green_18.mdl", x, y, 0, 1.5)
          Effectcreate("war3mapImported\\spellcardcall.mdx", x, y, 0)
          mj:playsound(Sound_Sanae_04)
          mj:animeact("spell one")
          SendMsgAll("|cFF0099FF开|r|cFF09A2F6海|r|cFF13ACEC[|r|cFF1CB5E3海|r|cFF25BEDA水|r|cFF2EC7D1分|r|cFF38D1C7开|r|cFF41DABE之|r|cFF4AE3B5日|r|cFF53ECAC]|r")
          PlayGlobalSound(Fu)
          u:buffset(u.handle, 4, "暂停")
          u:buffset(u.handle, 4.5, "绝对闪避")
          ac.wait(500, function()
            Effectcreate("ATx\\[ATxNew]Magic_23.mdl", x, y, 0, 2, 0, jd)
            local a = GetRandomAngle()
            local mja = {}
            for i = 1, 5 do
              a = a + 72
              local dx, dy = PolarXY(x, y, 230, a)
              mja[i] = u:createunit("u08X", dx, dy, GetRandomAngle())
              mja[i]:setcolor(55, 55, 255, 0)
              mja[i]:timetoremove(2)
            end
            mja[6] = mja[1]
            mja[7] = mja[2]
            mja[1]:setcolor(55, 55, 255, 255)
            local dx, dy = mja[1]:getxy()
            Effectcreate("Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl", dx, dy)
            Effectcreate("ATx\\[ATxNew]Blue_10.mdl", dx, dy, 3)
            for i = 1, 5 do
              local dmj = mja[i]
              local dmj2 = mja[i + 2]
              ac.wait(200 * i, function()
                local dx, dy = dmj:getxy()
                local txmj = u:createunit("u08X", dx, dy)
                txmj:timetoremove(0.8)
                dx, dy = dmj2:getxy()
                dmj2:setcolor(55, 55, 255, 0)
                Effectcreate("Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl", dx, dy)
                Effectcreate("ATx\\[ATxNew]Blue_10.mdl", dx, dy, 3 - 0.2 * i)
              end)
            end
            ac.wait(1500, function()
              local jd = u:getface()
              u:playsound(Sound_Sanae_05)
              local txsh = 25 * u:getallattri()
              local cs = 0
              ac.loop(400, function(timer)
                cs = cs + 1
                u:playsound(Sound_Sanae_05)
                local dmj = u:createunit("u090", x, y, jd)
                dmj:timetoremove(1.5)
                local dmj = u:createunit("u08Z", x, y, jd)
                dmj:timetoremove(1)
                local dx, dy = PolarXY(x, y, 1900, jd)
                local dmj = u:createunit("u08Z", dx, dy, jd + 180)
                dmj:timetoremove(1)
                for i = 1, 5 do
                  local jd2 = jd + 90
                  local jl = 380 * i
                  local dx, dy = PolarXY(x, y, jl, jd)
                  local tx = Effectcreate("ATx\\[ATxNew]Water_02.mdl", dx, dy, -1, 2)
                  local cs2 = 0
                  ac.loop(33, function(timer2)
                    cs2 = cs2 + 1
                    dx, dy = PolarXY(dx, dy, 125, jd2)
                    SetEffectXY(tx, dx, dy)
                    for _, xq in ac.selector():in_rangexy(dx, dy, 275):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      xq:setxy(dx, dy)
                      DamageUnit({
                        bj = "早苗开水之日",
                        unit = xq.handle,
                        source = u.handle,
                        damage = txsh,
                        level = 1,
                        type = "灵力",
                        isvest = true,
                        isattack = false,
                        isnoarmor = false,
                        element = "水",
                        extradata = {""}
                      })
                    end
                    if cs2 == 10 then
                      DestroyEffectLua(tx)
                      timer2:remove()
                    end
                  end)
                end
                for i = 1, 5 do
                  local jd2 = jd - 90
                  local jl = 380 * i
                  local dx, dy = PolarXY(x, y, jl, jd)
                  local tx = Effectcreate("ATx\\[ATxNew]Water_02.mdl", dx, dy, -1, 2)
                  local cs2 = 0
                  ac.loop(33, function(timer2)
                    cs2 = cs2 + 1
                    dx, dy = PolarXY(dx, dy, 125, jd2)
                    SetEffectXY(tx, dx, dy)
                    for _, xq in ac.selector():in_rangexy(dx, dy, 275):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      xq:setxy(dx, dy)
                      DamageUnit({
                        bj = "早苗开水之日",
                        unit = xq.handle,
                        source = u.handle,
                        damage = txsh,
                        level = 1,
                        type = "灵力",
                        isvest = true,
                        isattack = false,
                        isnoarmor = false,
                        element = "水",
                        extradata = {""}
                      })
                    end
                    if cs2 == 10 then
                      DestroyEffectLua(tx)
                      timer2:remove()
                    end
                  end)
                end
                if cs == 5 then
                  local g = CreateGroupLua()
                  for i = 1, 10 do
                    local jl = 190 * i
                    local dx, dy = PolarXY(x, y, jl, jd)
                    for _, xq in ac.selector():in_rangexy(dx, dy, 400):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      xq:groupadd(g)
                    end
                    Effectcreate("ATx\\[ATxNew]White_09.mdl", dx, dy, 0, 3)
                    Effectcreate("war3mapImported\\[ake]war3ake.com - 5467718799163621931506138.mdl", dx, dy, 0, 3)
                    ForGroupLuaNew(g, function(xq)
                      xq:buffset(u.handle, 3, "眩晕")
                      DamageUnit({
                        bj = "早苗开水之日",
                        unit = xq.handle,
                        source = u.handle,
                        damage = txsh * 10,
                        level = 4,
                        type = "灵力",
                        isvest = true,
                        isattack = false,
                        isnoarmor = false,
                        element = "无",
                        extradata = {""}
                      })
                    end)
                  end
                  timer:remove()
                end
              end)
            end)
          end)
          ac.wait(4000, function()
            mj:remove()
            ShowUnit(u.handle, true)
            u:select()
            Effectcreate("ATx\\[ATxNew]Green_18.mdl", x, y, 0, 1.5)
          end)
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chattrg(args)
      end)
      ac.loop(15000, function()
        if u:isalive() then
          u:clearbuff()
        end
      end)
      ac.loop(500, function()
        if u:isalive() then
          local x, y = u:getxy()
          for _, xq in ac.selector():in_rangexy(x, y, 250):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            if not xq:hasdata("神的风伤害") then
              xq:setdata("神的风伤害")
              local txsh
              if xq:isnormal() then
                txsh = 5000 + 0.1 * xq:gethp()
              else
                txsh = 5000 + 0.01 * xq:gethp()
              end
              xq:buffset(u.handle, 1, "眩晕")
              DamageUnit({
                bj = "早苗神之风",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 4,
                type = "灵力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "风",
                extradata = {""}
              })
              u:effectadd("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x, y)
            end
          end
        end
      end)
    end
    if not u:hasdata("东风谷早苗-神乐祈舞") and 99 <= count and u:ishasshw() then
      u:setdata("东风谷早苗-信仰之力", 100)
      u:setdata("东风谷早苗-神乐祈舞")
      u:reduceshw()
      u:sendmessage("|cFFFFFF33[神乐祈舞]|r\n|cFF66FF99占用神化位\n满足条件时使用血坏药剂触发神乐|r")
    end
  end
end

Vars_Huiyi_Dz = {
  {
    name = "转生史莱姆",
    weight = 5,
    lv = 3,
    key = {"唯一"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I08Q") then
        add = add + 1200
      end
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("判定-利姆露") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:sendmessage("|cFF6699FF我叫利姆露，是可爱的史莱姆，绝对不是坏史莱姆哦~|r")
      u:playsound(Sound_Rimuru_21)
      ChangeValue(Correction_HealUp, sy, 0.25)
      local x, y = u:getxy()
      local by = u:createfogcorrector(x, y, 3000)
      local cs = 0
      ac.loop(1000, function(t)
        u:removefogcorrector(by)
        x, y = u:getxy()
        by = u:createfogcorrector(x, y, 3000)
        if not u:isalive() then
          u:closefogcorrector(by)
        end
      end)
      ChangeValue(DamageSystem_Shjc, sy, 0.02)
      local count = Group_Counts(Group_PlayHero)
      if Group_Counts(Group_PlayHero) <= 1 then
        ChangeValue(DamageSystem_Ssjianshao, sy, 0.7, 1)
        ChangeValue(DamageSystem_Shjc, sy, 0.06)
      else
        ChangeValue(DamageSystem_Ssjianshao, sy, 1.1 - count * 0.1, 1)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (0.15 * count))
      end
      for index, value in ipairs(Pools_Spe) do
        if value.name == "大贤者" then
          if not value.hasbeenget then
            local item = u:additem("I08Q")
            value.hasbeenget = true
          end
          break
        end
      end
      local g_limuru = CreateGroupLua()
      u:setdata("利姆露-命中组", g_limuru)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not tg:hasbuff("B09B") then
          local vest = getunit(System_SkillVestPlayer[sy])
          vest:addskill("A14M")
          IssueTargetOrder(vest.handle, "slow", tg.handle)
          vest:delskill("A14M")
        end
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(info.txgl * 10) then
          u:settimedata(var.name .. "-特效冷却", 1)
          tg:effectadd("war3mapImported\\[TX] (1337).mdl")
          local txsh
          local lv = 1
          if u:hasdata("利姆露-禁忌化") then
            txsh = 1 * info.yssh
            lv = 5
          else
            txsh = 0.75 * info.yssh
          end
          DamageUnit({
            bj = "利姆露附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = lv,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
          if not tg:isingroup(g_limuru) then
            tg:groupadd(g_limuru)
            tg:effectadd("war3mapImported\\[TX] (235).mdx", "chest", 5)
            ac.wait(5100, function()
              tg:groupremove(g_limuru)
            end)
          end
        end
        if (u:hasdata("大贤者-四阶段") or u:hasdata("利姆露-禁忌化")) and not u:hasdata(var.name .. "-特效2冷却") and u:getluckrandom(info.txgl * 25) then
          u:settimedata(var.name .. "-特效2冷却", 1)
          DamageUnit({
            bj = "大贤者附伤",
            unit = tg.handle,
            source = u.handle,
            damage = 1 * info.yssh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
          local x2, y2 = tg:getxy()
          Effectcreate("AATX\\[0TxNew]Rimuru01.mdl", x2, y2)
          Effectcreate("ATX\\[ATxNew]Light_22.mdl", x2, y2)
        end
      end)
    end,
    effectname = "|cFF99CCFF转生史莱姆|r",
    effecttext = "|cFF99CCFF友爱的恩宠|r\n|cFF7DBEF1[数据删除]|r\n|cFF99CCFF捕食者|r\n|cFF7DBEF1[数据删除]|r\n|cFF99CCFF感知|r\n|cFF7DBEF1[数据删除]|r",
    effectart = "war3mapImported\\BTNEwl_Rimuru_Chuanqi.blp",
    test = [[

    ]]
  },
  {
    name = "阿露希",
    clickfunc = function(u, var)
      local count1 = u:getdata("阿露希-CP点数")
      u:sendmessage("|cffe0abff[阿露希]CP点数:" .. count1 .. "|r")
      FlashUIVarGlobal(u, MWXSTR .. "阿露希天赋")
    end,
    weight = 1600,
    lv = 3,
    key = {"唯一", "魔导"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("阿露希-初始") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cffc8bdfe阿|r|cffe3b4fe露|r|cffffacff希|r|cffffaeff『|r|cfffaafff请|r|cfff5b1ff多|r|cfff0b2ff关|r|cffebb3ff照|r|cffe7b5fe~|r|cffe2b6fe我|r|cffddb7fe是|r|cffd8b9fe阿|r|cffd3bafe露|r|cffcebcfe希|r|cffc9bdfe，|r|cffc4befe属|r|cffc0c0fd性|r|cffbbc1fd是|r|cffb6c2fd元|r|cffb1c4fd』|r")
      u:become("魔法少女无宝石")
      local z = {
        "炎",
        "水",
        "风",
        "土",
        "光明",
        "黑暗"
      }
      for index, value in ipairs(z) do
        u:changedata(value .. "变异数量", 1)
      end
      u:changedata("魔导变异补正", 50)
      u:addint(25)
      local add = math.max(1, math.floor(u:getlevel() / 5))
      u:changedata("阿露希-CP点数", add)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        u:changedata("阿露希-CP点数计数", 1)
        if u:getdata("阿露希-CP点数计数") >= 5 then
          u:changedata("阿露希-CP点数计数", -5)
          u:changedata("阿露希-CP点数", 1)
        end
      end)
      local x, y = u:getxy()
      local a = u:getface()
      local tx = Effectcreate("cb_qiu.mdx", x, y, -1, 2, 90, a)
      u:setdata("阿露希-魔导核心", tx)
      
      local function angle_delta(new_angle, old_angle)
        local d = (new_angle - old_angle + 180) % 360 - 180
        return d
      end
      
      ac.loop(250, function()
        local x, y = u:getxy()
        local angle = u:getface()
        local da = angle_delta(angle, a)
        SetEffectAngle(tx, da)
        a = angle
        x, y = PolarXY(x, y, -10, angle)
        x, y = PolarXY(x, y, 75, angle + 90)
        local x2, y2 = GetEffectXY(tx)
        local dis = DistanceXY(x, y, x2, y2)
        if 50 <= dis and dis <= 2000 then
          effectmove({
            effect = tx,
            time = 0.3,
            distance = dis - 75,
            angle = AngleXY(x2, y2, x, y)
          })
        end
        if 2000 < dis then
          SetEffectXY(tx, x, y)
        end
      end)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      ChangeValue(DamageSplit_CountJzMax, sy, 0.25)
      ChangeValue(HeroMenu_MpCure_MaxMp, sy, 1)
      ChangeValue(Damage_Element_All, sy, 0.1)
      local sx = 0
      local fs = 0
      local jc = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Magic, sy, -fs)
        ChangeValue(Damage_Element_All, sy, -sx)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jc)
        fs = 0.001 * u:getint()
        sx = 0.005 * u:getdata("系统-累积等级")
        jc = 0.03 * u:getdata("元素变异数量")
        ChangeValue(Correction_Magic, sy, fs)
        ChangeValue(Damage_Element_All, sy, sx)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * jc)
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        if GetRandom100(10) then
          u:addint(1)
        end
        u:changedata("阿露希-CP点数", 0.01)
        if tg:isboss() then
          u:changedata("阿露希-CP点数", 0.99)
        elseif tg:iselite() then
          u:changedata("阿露希-CP点数", 0.09)
        end
      end)
      local dskill = S2ID("S0D6")
      local COLOR_ATTRS = {
        {
          name = "火",
          var = "炎变异补正"
        },
        {
          name = "水",
          var = "水变异补正"
        },
        {
          name = "冰",
          var = "冰变异补正"
        },
        {
          name = "风",
          var = "风变异补正"
        },
        {
          name = "土",
          var = "土变异补正"
        },
        {
          name = "光",
          var = "光明变异补正"
        },
        {
          name = "暗",
          var = "黑暗变异补正"
        },
        {name = "元"}
      }
      local YUAN_ATTR_INDEX = #COLOR_ATTRS
      
      local function change_aluxi_attr_bonus(attr, value)
        local info = COLOR_ATTRS[attr]
        if info and info.var then
          u:changedata(info.var, value)
        end
      end
      
      local function updatetip(u, cur_attr)
        local parts = {}
        for i, info in ipairs(COLOR_ATTRS) do
          if 1 < i then
            table.insert(parts, "|cFF99FFFF/|r")
          end
          if i == cur_attr then
            table.insert(parts, "|cFFFF9900" .. info.name .. "|r")
          else
            table.insert(parts, "|cFF99FFFF" .. info.name .. "|r")
          end
        end
        local str = "|cFF99FFFF将自身元属性切换为|n[|r" .. table.concat(parts) .. "|cFF99FFFF]|n冷却1秒|r"
        u:setskilldatastring(dskill, "提示拓展", str)
      end
      
      u:setdata("阿露希-元属性", YUAN_ATTR_INDEX)
      u:byladdskill(dskill, function(args)
        if args.skill ~= dskill then
          return
        end
        if not u:isalive() then
          u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          local ewl = getunit(args.unit)
          ewl:setskillcd(dskill, 1)
          return
        end
        local xt = u:getdata("阿露希-元属性") or 1
        change_aluxi_attr_bonus(xt, -25)
        xt = xt % #COLOR_ATTRS + 1
        u:setdata("阿露希-元属性", xt)
        change_aluxi_attr_bonus(xt, 25)
        updatetip(u, xt)
        u:sendmessage("|cFF99FFFF元素切换成功|r")
      end)
      local z2 = {
        "火",
        "水",
        "冰",
        "风",
        "土",
        "光",
        "暗"
      }
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效1冷却") and u:getluckrandom(info.txgl * 25) then
          u:settimedata(var.name .. "-特效1冷却", 1)
          local ele = z2[GetRandomInt(1, #z2)]
          if u:getdata("阿露希-元属性") ~= YUAN_ATTR_INDEX then
            ele = COLOR_ATTRS[u:getdata("阿露希-元属性")].name
          end
          DamageUnit({
            bj = "阿露希(元属性)",
            unit = tg.handle,
            source = u.handle,
            damage = 0.25 * info.yssh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = ele
          })
        end
      end)
      local cs = 0
      ac.loop(1000, function()
        if u:isalive() then
          cs = cs + 1
          if cs == 3 then
            cs = 0
            local x, y = u:getxy()
            local txsh = 5000 + 3 * u:getlevel() * u:getint()
            local g = CreateGroupLua()
            for _, xq in ac.selector():in_rangexy(x, y, 1800):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g)
            end
            if 0 < Group_Counts(g) then
              local mb = Group_Randomunit(g)
              local ax, ay = mb:getxy()
              Effectcreate("Tx_Aluxi2.mdl", ax, ay, 0, 4)
              for _, xq in ac.selector():in_rangexy(ax, ay, 300):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:buffset(u.handle, 0.7, "僵直")
                DamageUnit({
                  bj = "阿露希-魔导核心",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "魔力",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = z2[GetRandomInt(1, #z2)],
                  extradata = {""}
                })
              end
            end
          end
        end
      end)
      local dataz = {
        {
          name = "阿露希-火",
          text = "|cffff0000格|r|cff960000林|r|cffff0000（火）\n野兽之心|r\n|cff960000初始：消耗1点cp|r",
          icon = "Cq_Aluxi_Tfs_01",
          func = function(var)
            u:changedata("炎变异数量", 1)
            ChangeValue(Damage_Element_Fire, sy, 0.25)
            ChangeValue(DamageSystem_Shjc, sy, 0.05)
            u:addstexiao(var.name, "直接伤害特效", function(args)
              local u = args.u
              local tg = args.tg
              local info = args.damageinfo
              if not u:hasdata(var.name .. "-特效冷却") then
                u:settimedata(var.name .. "-特效冷却", 1)
                ChangeTimeValue(DamageSystem_Baoji, sy, 2, 5)
                ChangeTimeValue(DamageSystem_Baoshang, sy, 0.03, 5)
                ChangeTimeValue(Correction_RPM, sy, 0.03, 5)
              end
            end)
          end
        },
        {
          name = "阿露希-水",
          text = "|cff399cff尤|r|cff6aacff洛|r|cff9bbcff尼|r|cffccccff娅|r|cff399cff（水）\n极寒冻结\n|r|cffccccff初始：消耗1点cp|r",
          icon = "Cq_Aluxi_Tfs_02",
          func = function(var)
            u:changedata("水变异数量", 1)
            u:changedata("冰变异数量", 1)
            ChangeValue(Damage_Element_Water, sy, 0.125)
            ChangeValue(Damage_Element_Ice, sy, 0.125)
            ChangeValue(Hero_Tili_Huifu, sy, 0.1)
            u:changearmor(30)
            u:addstexiao(var.name, "直接伤害特效", function(args)
              local u = args.u
              local tg = args.tg
              local info = args.damageinfo
              if not u:hasdata(var.name .. "-特效冷却") then
                u:settimedata(var.name .. "-特效冷却", 3)
                local ax, ay = tg:getxy()
                local txsh = 5000 + 2500 * u:getlevel()
                for _, xq in ac.selector():in_rangexy(ax, ay, 300):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  DamageUnit({
                    bj = "阿露希-极寒冻结",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 1,
                    type = "魔力",
                    isvest = true,
                    isattack = false,
                    isnoarmor = false,
                    element = "冰",
                    extradata = {""}
                  })
                  DamageUnit({
                    bj = "阿露希-极寒冻结",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 1,
                    type = "魔力",
                    isvest = true,
                    isattack = false,
                    isnoarmor = false,
                    element = "水",
                    extradata = {""}
                  })
                end
              end
            end)
          end
        },
        {
          name = "阿露希-风",
          text = "|cff80ff80可|r|cffaad394萝|r|cffd3a7a7特|r|cff80ff80（风）\n风之翼\n|r|cffd3a7a7初始：消耗1点cp|r",
          icon = "Cq_Aluxi_Tfs_03",
          func = function(var)
            u:changedata("风变异数量", 1)
            ChangeValue(Damage_Element_Wind, sy, 0.25)
            ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 50)
            ChangeValue(HeroMenu_ExtraMoveSpeed_Bfb, sy, 0.1)
            u:addstexiao(var.name, "位移技能后效果", function(args)
              if not u:hasdata("阿露希-瞬移") then
                u:settimedata("阿露希-瞬移", 0.5)
              end
            end)
            u:addtrgevent("单位-指定点目标指令", function(args)
              if args.orderid == String2OrderIdBJ("smart") and u:hasdata("阿露希-瞬移") then
                u:deldata("阿露希-瞬移")
                local x, y = u:getxy()
                local x2 = args.x
                local y2 = args.y
                local angle = AngleXY(x, y, x2, y2)
                local dis = DistanceXY(x, y, x2, y2)
                if 500 <= dis then
                  dis = 500
                end
                x2, y2 = PolarXY(x, y, dis, angle)
                Effectcreate("ATX\\[ATxNew]Black_01.mdl", x, y)
                Effectcreate("ATX\\[ATxNew]Black_01.mdl", x2, y2)
                u:setxy(x2, y2)
              end
            end)
          end
        },
        {
          name = "阿露希-土",
          text = "|cffddca8a卡|r|cff804000莲|r|cffddca8a（土）\n完全分解\n|r|cff804000初始：消耗1点cp|r",
          icon = "Cq_Aluxi_Tfs_04",
          func = function(var)
            u:changedata("土变异数量", 1)
            ChangeValue(Damage_Element_Earth, sy, 0.25)
            u:changemaxhp(100 * u:getlevel())
            u:addstexiao(var.name, "英雄升级时效果", function(args)
              u:changemaxhp(100)
            end)
            u:setdata("阿露希-完全分解")
            u:addstexiao(var.name, "抗性破坏阶段", function(args)
              local u = args.u
              local tg = args.tg
              local info = args.damageinfo
              if u:hasdata("阿露希-完全分解") then
                info.wssb = true
                info.wsmy = true
              end
            end)
            u:addstexiao(var.name, "直接伤害特效", function(args)
              local u = args.u
              local tg = args.tg
              local info = args.damageinfo
              if u:hasdata("阿露希-完全分解") and not u:hasdata(var.name .. "-特效冷却") then
                u:settimedata(var.name .. "-特效冷却", 1)
                local txsh = 5000 + 2500 * u:getlevel()
                DamageUnit({
                  bj = "阿露希-完全分解",
                  unit = tg.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "魔力",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = "土",
                  extradata = {""}
                })
              end
            end)
          end
        },
        {
          name = "阿露希-暗",
          text = "|cff510051缇|r|cffffff00娜|r|cff510051（暗）\n分离\n|r|cffffff00初始：消耗1点cp",
          icon = "Cq_Aluxi_Tfs_05",
          func = function(var)
            u:changedata("黑暗变异数量", 1)
            ChangeValue(Damage_Element_Dark, sy, 0.25)
            ChangeValue(DamageSystem_Txgl, sy, 0.25)
            u:addstexiao(var.name, "直接伤害特效", function(args)
              local u = args.u
              local tg = args.tg
              local info = args.damageinfo
              if not tg:hasdata("阿露希-分离") and u:getluckrandom(20 * info.txgl) then
                tg:setdata("阿露希-分离")
                tg:changedata("怪物-额外受伤", 0.1)
                local txsh = 5000 + 2500 * u:getlevel()
                DamageUnit({
                  bj = "阿露希-分离",
                  unit = tg.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "魔力",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = "暗",
                  extradata = {""}
                })
              end
            end)
          end
        },
        {
          name = "阿露希-光",
          text = "萨|r|cfffdc542伊|r|cffffff00（光）\n处女主义\n|r|cfffdc542初始：消耗1点cp|r",
          icon = "Cq_Aluxi_Tfs_06",
          func = function(var)
            u:changedata("光明变异数量", 1)
            ChangeValue(Damage_Element_Light, sy, 0.25)
            u:changemaxmp(5 * u:getlevel())
            u:addstexiao(var.name, "英雄升级时效果", function(args)
              u:changemaxmp(5)
            end)
            ChangeValue(HeroMenu_HpForever_MaxHp, sy, 0.25)
            ChangeValue(HeroMenu_MpCure_MaxMp, sy, 1)
            u:addstexiao(var.name, "决死效果", function(args)
              if args.dt and not u:hasdata("阿露希-决死冷却") then
                args.dt = false
                u:settimedata("阿露希-决死冷却", 360)
                u:buffset(u.handle, 3, "无敌")
                u:sendmessage("|cfffffd7c[阿露希]处女主义|r")
                u:curehp(u.handle, 0, 50, 4)
              end
            end)
          end
        }
      }
      for index, value in ipairs(dataz) do
        u:uivar_add({
          keyname = value.name,
          keytype = "冥王栏",
          seckey = "阿露希天赋",
          text = value.text,
          icon = value.icon .. "DIS.tga",
          clickfunc = function(u, button)
            if u:getdata("阿露希-CP点数") > 0 then
              u:changedata("阿露希-CP点数", -1)
              value.func(value)
              u:uivar_change({
                keyname = value.name,
                keytype = "冥王栏",
                seckey = "阿露希天赋",
                text = value.text,
                icon = value.icon .. ".tga",
                isclearclick = true
              })
            else
              u:sendmessage("|cFF99FFFFCP点数不足")
            end
          end
        })
      end
      ac.wait(100, function()
        u:uivar_change({
          keyname = "阿露希",
          keytype = "传奇栏",
          ishasphoto = true,
          dx = 3
        })
      end)
    end,
    effectname = "|cffff80ff魔法|r|cffffd7ff少女|r|cffacc5fd-|r|cffc8bdfe阿|r|cffe3b4fe露|r|cffffacff希|r",
    effecttext = "|cffc7e1fcPower[I]|r\n|cffacc5fd魔导 元|r\n|cffffd7ff①魔法少女|r\n|cffc8bdfe②元属性|r\n|cffe3b4fe③魔导核心|r\n|cffffacff④祈愿诗篇[I]|r",
    effectart = "Cq_Aluxi_03",
    test = [[

    ]]
  },
  {
    name = "路西法",
    weight = 1200,
    lv = 3,
    key = {
      "唯一",
      "光明",
      "黑暗",
      "根源",
      "战士"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("路西法-初始") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      ac.wait(100, function()
        u:uivar_change({
          keyname = "路西法",
          keytype = "传奇栏",
          text = "|cFF666666『|r|cFF6E5555黑|r|cFF774444い|r|cFF803333翼|r|cFF882222』|r|cFF990000Lucifer|r\n\n|cFF666666「|r|cFF6D5757终|r|cFF754949焉|r|cFF7C3A3A」|r|cFF832C2C已|r|cFF8A1D1D定|r\n|cFF666666「|r|cFF734C4C现|r|cFF803333在」|r\n|cFF666666「我|r|cFF6C5959将|r|cFF734C4C毁|r|cFF794040灭|r|cFF803333一|r|cFF862626切|r|cFF8C1A1A」|r",
          icon = "Cq_Luxifa_02_Big.tga",
          ishasphoto = true,
          dx = 3.25,
          smallicon = "Cq_Luxifa_02.tga",
          jbtext = function()
            UIYNameCount = 4
            UIYName[1] = {
              method = 1,
              name = "『黑い翼』Lucifer",
              colors = {
                "666666",
                "774444",
                "990000",
                "774444",
                "666666"
              },
              length = 6,
              lengthcd = 15,
              math = 1,
              offsetspeed = 0.2,
              extratext = [[


]]
            }
            UIYName[2] = {
              method = 1,
              name = "「终焉」已定",
              colors = {
                "666666",
                "754949",
                "8A1D1D",
                "754949",
                "666666"
              },
              length = 6,
              lengthcd = 30,
              math = 1,
              offsetspeed = 0.3,
              extratext = "\n"
            }
            UIYName[3] = {
              method = 1,
              name = "「现在」",
              colors = {
                "666666",
                "734C4C",
                "803333",
                "734C4C",
                "666666"
              },
              length = 4,
              lengthcd = 30,
              math = 1,
              offsetspeed = 0.4,
              extratext = "\n"
            }
            UIYName[4] = {
              method = 1,
              name = "「我将毁灭一切」",
              colors = {
                "666666",
                "734C4C",
                "8C1A1A",
                "734C4C",
                "666666"
              },
              length = 8,
              lengthcd = 30,
              math = 1,
              offsetspeed = 0.5
            }
          end
        })
      end)
      u:setplayername("|cFF666666『|r|cFF6E5555黑|r|cFF774444い|r|cFF803333翼|r|cFF882222』|r|cFF990000Lucifer|r")
      PlayBGM({
        bgm = BGM_Luxifa_01,
        time = 360,
        ID = 250,
        unit = u.handle
      })
      PlayGlobalSound(Sound_Luxifa_02)
      NPCChat({
        name = "|cFF666666『|r|cFF6E5555黑|r|cFF774444い|r|cFF803333翼|r|cFF882222』|r|cFF990000Lucifer|r",
        chaticon = "Chat_Luxifa.tga",
        chattext = {
          {
            text = "|cff960000生命之流，对于神明来说不值一提。|r",
            time = 0.1
          },
          {
            text = "|cff960000舍弃肉体，轮回转世。|r",
            time = 4
          },
          {
            text = "|cff960000坠入混沌的深渊之中吧！|r",
            time = 8.1
          },
          {
            text = "|cff960000牢记于心吧，这份光景。|r",
            time = 11.1
          }
        }
      })
      u:adddivinity(1)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 0.25)
          local sx = {
            "光",
            "暗",
            "风",
            "雷",
            "火",
            "土",
            "水",
            "冰"
          }
          local txsh = 0.25 * info.yssh
          DamageUnit({
            bj = "路西法-启示录号角",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 5,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = sx[GetRandomInt(1, #sx)]
          })
        end
        if not u:hasdata(var.name .. "-特效2冷却") and u:getluckrandom(info.txgl * 15) then
          u:settimedata(var.name .. "-特效2冷却", 3.5)
          local txsh = 6666 * u:getlevel() + u:getmaxhp() * (5 + u:getstate("光明变异") + u:getstate("黑暗变异"))
          local x2, y2 = tg:getxy()
          for _, xq in ac.selector():in_rangexy(x2, y2, 333):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "路西法-天使之羽",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "光"
            })
            LossHpUnit({
              u = u,
              tg = xq,
              damage = 0,
              perhp = 3,
              maxhp = 0,
              bj = "[生命损耗]路西法-天使之羽"
            })
          end
        end
      end)
      u:addstexiao(var.name, "被施加Buff时效果-眩晕", function(args)
        if not Keyan_Guomintizhi then
          args.time = 0
        end
      end)
      u:setdata("系统-无视伤害免疫")
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        u:addallstats(6)
      end)
      local ewys = 0
      local all = 0
      local qsx = 0
      local cs = 0
      local add = 0
      ac.loop(1000, function()
        local sx = u:getallattri()
        ChangeValue(HeroMenu_ExtraMoveSpeed_Bfb, sy, -ewys)
        ChangeValue(Damage_Element_All, sy, -all)
        if u:getdata("战斗时间") > 0 then
          ewys = 0.4
          all = all + 0.001
        else
          ewys = 0
          all = 0
        end
        ChangeValue(HeroMenu_ExtraMoveSpeed_Bfb, sy, ewys)
        ChangeValue(Damage_Element_All, sy, all)
        ChangeValue(Correction_Magic, sy, -add)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        add = 5.0E-5 * sx
        ChangeValue(Correction_Magic, sy, add)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        if qsx ~= sx then
          local change = sx - qsx
          u:changemaxhp(5 * change)
          qsx = sx
        end
        if 0 < u:getdata("路西法-杀敌加成持续时间") then
          u:changedata("路西法-杀敌加成持续时间", -1)
        elseif 0 < u:getdata("路西法-杀敌叠加层数") then
          local cengshu = u:getdata("路西法-杀敌叠加层数")
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-0.6 * cengshu))
          ChangeValue(Damage_ElementRes_All, sy, -0.12 * cengshu)
          u:deldata("路西法-杀敌叠加层数")
        end
        if u:isalive() then
          cs = cs + 1
          if 30 <= cs then
            cs = 0
            local add = 0.3 * u:getmaxhp()
            hdzlinshiadd(u, add)
          end
        end
      end)
      u:addstexiao(var.name, "位移技能后效果", function(args)
        if not u:hasdata("路西法-瞬移") then
          u:settimedata("路西法-瞬移", 0.5)
        end
      end)
      local g = CreateGroupLua()
      u:addtrgevent("单位-指定点目标指令", function(args)
        if args.orderid == String2OrderIdBJ("smart") and u:hasdata("路西法-瞬移") then
          u:deldata("路西法-瞬移")
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          if 600 <= dis then
            dis = 600
          end
          x2, y2 = PolarXY(x, y, dis, angle)
          Effectcreate("ATX\\[ATxNew]Black_01.mdl", x, y)
          Effectcreate("ATX\\[ATxNew]Black_01.mdl", x2, y2)
          u:setxy(x2, y2)
        end
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        local add = 1 + 0.25 * (u:getstate("光明变异") + u:getstate("黑暗变异"))
        u:changemaxhp(add)
        u:setdata("路西法-杀敌加成持续时间", 20)
        if u:getdata("路西法-杀敌叠加层数") < 4 then
          u:changedata("路西法-杀敌叠加层数", 1)
          ChangeValue(DamageSystem_Shjc, sy, 0.06)
          ChangeValue(Damage_ElementRes_All, sy, 0.12)
        end
      end)
      u:addstexiao(var.name, "伤害格挡效果", function(args)
        local tg = args.tg
        if not u:hasdata("路西法-格挡生效冷却") and not args.b then
          args.b = true
          u:settimedata("路西法-格挡生效冷却", 20)
          u:effectadd("Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageCaster.mdl", "chest")
          u:effectadd("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", "chest")
        end
      end)
    end,
    effectname = "|cFF666666『|r|cFF6E5555黑|r|cFF774444い|r|cFF803333翼|r|cFF882222』|r|cFF990000Lucifer|r",
    effecttext = "|cFF666666「|r|cFF6D5757终|r|cFF754949焉|r|cFF7C3A3A」|r|cFF832C2C已|r|cFF8A1D1D定|r\n|cFF666666「|r|cFF734C4C现|r|cFF803333在」|r\n|cFF666666「我|r|cFF6C5959将|r|cFF734C4C毁|r|cFF794040灭|r|cFF803333一|r|cFF862626切|r|cFF8C1A1A」|r",
    effectart = "Cq_Luxifa_02",
    test = [[

    ]]
  },
  {
    name = "龙宫礼奈",
    weight = 5,
    key = {"唯一"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I08O") then
        add = add + 1500
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-礼奈") then
        b = true
      end
      if not u:ishasshw() then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:reduceshw()
      u:setplayername("|cFF7DBEF1[|r|cFFFF66CC龙宫礼奈|r|cFF7DBEF1]|r" .. NameID[sy])
      u:setdata("雏见泽候群症点数", 0)
      u:setdata("雏见泽候群症等级", 1)
      PlayBGM({
        bgm = 0,
        time = 110,
        ID = 54,
        unit = u.handle
      })
      PlayGlobalSound(Sound_Rena_Start)
      u:chat("人为了得到幸福究竟要付出多少努力呢")
      u:chat("我认为不幸是相互连锁的", 8.3)
      u:chat("一旦发生就难以摆脱", 12.7)
      u:chat("为了摆脱它 真的真的要拼命努力", 15.8)
      u:chat("要努力到这样的地步才终于能抓住的东西", 20.4)
      u:chat("这不就是幸福吗 礼奈我是这么认为的", 24.8)
      ac.wait(30000, function()
        PlayGlobalSound(BGM_Rena_02)
      end)
      local add = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        add = u:getdata("礼奈击杀队友强化")
        if u:getdata("雏见泽候群症等级") == 5 then
          add = add + 0.005 * u:getdata("雏见泽候群症点数")
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:isboss() and u:getdata("雏见泽候群症点数") < 100 then
          u:changedata("雏见泽候群症点数", 1)
        end
      end)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:getdata("雏见泽候群症等级") >= 3 and not u:hasdata(var.name .. "-特效2冷却") and u:getluckrandom(25 * info.txgl) then
          u:settimedata(var.name .. "-特效2冷却", 1)
          local x2, y2 = tg:getxy()
          local txsh = 350 * u:getstr()
          if tg:isboss() then
            tg:buffset(u.handle, 0.25, "眩晕")
            if GetRandom100(1) then
              tg:playsound(Sound_Rena_Attack)
              Effectcreate("war3mapImported\\[TxNew1]001.mdl", x2, y2)
              LossHpUnit({
                u = u,
                tg = tg,
                damage = 0,
                perhp = 0,
                maxhp = 10,
                bj = "[生命损耗]龙宫礼奈"
              })
            else
              LossHpUnit({
                u = u,
                tg = tg,
                damage = 0,
                perhp = 0,
                maxhp = 1,
                bj = "[生命损耗]龙宫礼奈"
              })
            end
          else
            tg:buffset(u.handle, 1.5, "眩晕")
            if GetRandom100(1) then
              tg:playsound(Sound_Rena_Attack)
              Effectcreate("war3mapImported\\[TxNew1]001.mdl", x2, y2)
              LossHpUnit({
                u = u,
                tg = tg,
                damage = 0,
                perhp = 0,
                maxhp = 100,
                bj = "[生命损耗]"
              })
            else
              LossHpUnit({
                u = u,
                tg = tg,
                damage = 0,
                perhp = 0,
                maxhp = 10,
                bj = "[生命损耗]"
              })
            end
          end
          DamageUnit({
            bj = "雏见泽候群症",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无",
            extradata = {}
          })
          tg:effectadd("war3mapImported\\texiao_xuebao.mdx")
        end
      end)
      u:addskill("A141")
      u:banskill("A141")
      u:setskillforever("A140")
      u:setskillforever("A141")
      u:addskill("A14G")
      u:banskill("A14G")
      u:setskillforever("A14F")
      u:setskillforever("A14G")
      
      local function skill(args)
        if args.skill == S2ID("A140") then
          if not u:hasdata("寻宝冷却") then
            u:settimedata("寻宝冷却", 180)
            ac.wait(180000, function()
              u:sendmessage("|cFF7DBEF1寻宝冷却完毕|r")
            end)
            local zu = {
              "I08N",
              "I08M",
              "I08L"
            }
            local x, y = u:getxy()
            Effectcreate("Abilities\\Spells\\Other\\Transmute\\PileofGold.mdl", x, y)
            CreateItemLua(zu[GetRandomInt(1, 3)], x, y)
          else
            u:setskillcd(args.skill, 1)
            u:sendmessage("|cFF7DBEF1[系统]冷却中|r")
          end
        end
        if args.skill == S2ID("A14F") then
          if not u:hasdata("西奈冷却") then
            u:settimedata("西奈冷却", 180)
            ac.wait(180000, function()
              u:sendmessage("|cFF7DBEF1西奈冷却完毕|r")
            end)
            local tg = getunit(args.target)
            local x, y = u:getxy()
            local x2, y2 = tg:getxy()
            local jd = AngleXY(x, y, x2, y2)
            local dis = DistanceXY(x, y, x2, y2)
            local tx = Effectcreate("Abilities\\Weapons\\RexxarMissile\\RexxarMissile.mdl", x, y, -1, 1, 50, jd, 0, 0, 2)
            u:playsound(Sound_Rena_Attack)
            u:buffset(u.handle, 14.9, "暂停")
            u:buffset(u.handle, 15, "绝对闪避")
            u:buffset(u.handle, 17, "无敌")
            tg:buffset(tg.handle, 13.2, "无敌")
            tg:buffset(tg.handle, 16, "暂停")
            tg:setdata("礼奈西奈杀")
            if tg:isingroup(Group_Monster) then
              tg:groupadd(HpGroup)
            end
            u:setface(jd)
            effectmove({
              effect = tx,
              time = 0.6,
              distance = dis,
              angle = jd,
              loops = {
                {
                  looptime = 0.06,
                  func = function(dx, dy)
                    Effectcreate("war3mapImported\\bbb.mdl", dx, dy, 0, 1, 50, jd + 90, -270, 0, 1)
                  end
                }
              },
              endfunc = function(dx, dy)
                DestroyEffectLua(tx)
                EffectcreateArgs({
                  effect = "war3mapImported\\texiao_xuebao.mdl",
                  x = dx,
                  y = dy,
                  time = 2,
                  height = 50,
                  zxz = jd,
                  xxz = 270
                })
                EffectcreateArgs({
                  effect = "Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl",
                  x = dx,
                  y = dy,
                  time = 2,
                  height = 50,
                  zxz = jd,
                  xxz = 270
                })
                EffectcreateArgs({
                  effect = "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl",
                  x = dx,
                  y = dy,
                  time = 2,
                  height = 50,
                  zxz = jd,
                  xxz = 270
                })
                tg:animeact("death")
                tg:playsound(MetalHeavySliceFlesh2)
                
                local function sunhao(tg)
                  if tg:isboss() then
                    LossHpUnit({
                      u = u,
                      tg = tg,
                      damage = 0,
                      perhp = 1,
                      maxhp = 0,
                      bj = "[生命损耗]礼奈西奈"
                    })
                  else
                    LossHpUnit({
                      u = u,
                      tg = tg,
                      damage = 0,
                      perhp = 10,
                      maxhp = 0,
                      bj = "[生命损耗]礼奈西奈"
                    })
                  end
                end
                
                sunhao(tg)
                unitmove({
                  unit = tg.handle,
                  time = 1,
                  distance = 400,
                  angle = jd,
                  isfly = true,
                  loops = {
                    {
                      looptime = 0.03,
                      func = function(dx, dy)
                        Effectcreate("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", dx, dy)
                      end
                    }
                  },
                  endfunc = function(dx, dy)
                    local x2, y2 = u:getxy()
                    Effectcreate("war3mapImported\\specialanimedustwave.mdx", x2, y2)
                    Effectcreate("war3mapImported\\bbb.mdx", x2, y2)
                    local jd = AngleXY(x2, y2, dx, dy)
                    local dis = DistanceXY(dx, dy, x2, y2)
                    u:setface(jd)
                    u:playsound(Sound_Rena_Death_02)
                    unitmove({
                      unit = u.handle,
                      time = 0.5,
                      distance = dis,
                      angle = jd,
                      isfly = true
                    })
                    local time = {
                      2,
                      2.8,
                      3.3,
                      4,
                      4.5
                    }
                    for index, value in ipairs(time) do
                      ac.wait(value * 1000, function()
                        tg:effectadd("war3mapImported\\texiao_xuebao.mdx", "origin")
                        tg:effectadd("Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl", "origin")
                        sunhao(tg)
                        local yxz = {
                          MetalHeavyChopFlesh1,
                          MetalHeavyChopFlesh2,
                          MetalHeavyChopFlesh3
                        }
                        tg:playsound(yxz[GetRandomInt(1, 3)])
                      end)
                    end
                    ac.wait(5500, function()
                      tg:playsound(Sound_Rena_Laugh_01)
                    end)
                    ac.wait(7500, function()
                      u:playsound(Sound_Rena_Skill)
                      local x1, y1 = tg:getxy()
                      Effectcreate("war3mapImported\\texiao_xuebao.mdx", x1, y1, 0, 2)
                      Effectcreate("Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl", x1, y1, 0, 2)
                      Effectcreate("war3mapImported\\[TxNew1]001.mdx", x1, y1, 0, 2)
                      sunhao(tg)
                      ac.wait(1300, function()
                        tg:effectadd("war3mapImported\\texiao_xuebao.mdx", "origin")
                        tg:effectadd("Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl", "origin")
                        sunhao(tg)
                      end)
                      ac.wait(3100, function()
                        tg:effectadd("war3mapImported\\texiao_xuebao.mdx", "origin")
                        tg:effectadd("Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl", "origin")
                        sunhao(tg)
                      end)
                      ac.wait(4800, function()
                        local x1, y1 = tg:getxy()
                        Effectcreate("war3mapImported\\texiao_xuebao.mdx", x1, y1, 0, 2)
                        Effectcreate("Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl", x1, y1, 0, 2)
                        Effectcreate("war3mapImported\\[TxNew1]001.mdx", x1, y1, 0, 2)
                        tg:buffset(u.handle, 5, "眩晕")
                        DamageUnit({
                          bj = "礼奈西奈杀",
                          unit = tg.handle,
                          source = u.handle,
                          damage = 50000 + 1000 * u:getstr(),
                          level = 1,
                          type = "物理",
                          isvest = false,
                          isattack = false,
                          isnoarmor = false,
                          element = "无",
                          extradata = {}
                        })
                        ac.wait(100, function()
                          tg:buffset(tg.handle, 2.5, "无敌")
                        end)
                      end)
                      ac.wait(5800, function()
                        u:playsound(Sound_Rena_Laugh_02)
                        tg:deldata("礼奈西奈杀")
                      end)
                    end)
                  end
                })
              end
            })
          else
            u:setskillcd(args.skill, 1)
            u:sendmessage("|cFF7DBEF1[系统]冷却中|r")
          end
        end
      end
      
      u:addtrgevent("单位-发动技能", function(args)
        skill(args)
      end)
      moveskillreplace({
        unit = u.handle,
        level = 1,
        skill_Q = "A14H",
        skill_W = "A14I",
        isforce = false,
        efunc = function()
          local function skill(args)
            if args.skill == S2ID("A14H") or args.skill == S2ID("A14I") then
              local tilixh = 1
              
              local dskill = args.skill
              if u:hasbuff("缠绕") then
                u:setskillcd(dskill, 0.01)
                u:sendmessage("|cFFFF3300缠绕中|r")
                return
              end
              if not u:hasdata("位移体力消耗标记") then
                if u:lossstamina(tilixh) then
                  u:settimedata("位移体力消耗标记", 0.001)
                else
                  u:setskillcd(dskill, 0.01)
                  u:sendmessage("|cFFFF3300体力值不足|r")
                  return
                end
              end
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local angle = AngleXY(x, y, x2, y2)
              local dis = DistanceXY(x, y, x2, y2)
              local mjl = 900
              if dis >= mjl then
                dis = mjl
              end
              u:settimedata("龙宫礼奈-鬼步飞行", 0.75)
              if not u:hasbuff("绝对闪避") then
                if args.skill == S2ID("A14I") then
                  u:setdata("刷新W时间", 0.15)
                else
                  u:setdata("刷新Q时间", 0.15)
                end
              end
              Effectcreate("war3mapImported\\blackblink.mdx", x, y)
              unitmove({
                unit = u.handle,
                time = 0.15,
                distance = dis,
                angle = angle,
                endfunc = function(dx, dy)
                  Effectcreate("war3mapImported\\blackblink.mdx", dx, dy)
                  u:setdata("位移点X", dx)
                  u:setdata("位移点Y", dy)
                end,
                isblink = true
              })
              if args.skill == S2ID("A14I") then
                movexg(u.handle, 0.75, "A14I", "W", "礼奈-W")
              else
                movexg(u.handle, 0.75, "A14H", "Q", "礼奈-Q")
              end
            end
          end
          
          u:addtrgevent("单位-发动技能", function(args)
            skill(args)
          end)
        end
      })
      ChangeValue(Correction_Exp, sy, 0.2)
      ac.loop(60000, function()
        ChangeValue(Correction_Exp, sy, 0.01)
        ChangeValue(Correction_Gold, sy, 0.005)
      end)
      local ds = 0
      local lt = 0
      local lt2 = 0
      local cf = 0
      ac.loop(250, function()
        if not u:hasdata("礼奈-黑化状态") and ds >= u:getdata("雏见泽候群症点数") and ds ~= 0 then
          lt = lt + 1
          local cfc = 0
          if 20 <= ds then
            cfc = ds / 20
            cf = math.max(cf, cfc)
          end
          if 80 <= ds then
            cf = 5
          end
          if 0 < cfc and lt >= 140 - 20 * cfc then
            if ds >= 20 * cfc then
              ds = 20 * cfc - 1
              u:setdata("雏见泽候群症点数", ds)
            end
            lt2 = lt2 + 1
            if lt2 == 10 then
              lt2 = 0
              ds = ds - 5
              u:setdata("雏见泽候群症点数", ds)
            end
          end
        else
          lt = 0
          lt2 = 0
          cf = 0
        end
        ds = u:getdata("雏见泽候群症点数")
        if 100 <= ds or u:hasdata("礼奈-黑化状态") or u:hasdata("礼奈-永久黑化") then
          ds = 100
        end
        if ds <= 0 or not u:isalive() then
          ds = 0
        end
        local lv = 1 + math.floor(ds / 20)
        lv = math.min(lv, 5)
        u:setdata("雏见泽候群症点数", ds)
        u:setdata("雏见泽候群症等级", lv)
      end)
      u:changedata("闪避值", 40)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.5, 1)
      ChangeValue(Correction_CureUp, sy, 0.25)
      local lv = 1
      local cs = 0
      ac.loop(1000, function()
        cs = cs + 1
        if lv <= 4 and GetRandom100(10) then
          local x1, y1 = u:getxy()
          for _, xq in ac.selector():in_rangexy(x1, y1, 450):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            u:useweapon()
            break
          end
        end
        if cs == 10 then
          cs = 0
          if lv <= 2 then
            local g = CreateGroupLua()
            ForGroupLuaNew(Group_PlayHero, function(xq)
              local dis = DistanceBetweenUnits(u.handle, xq.handle)
              if dis <= 900 then
                xq:groupadd(g)
              end
            end)
            if 0 < Group_Counts(g) then
              do
                local mb = Group_Randomunit(g)
                mb:effectadd("Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl", "overhead")
                mb:curehp(u.handle, 100 + 5 * u:getint(), 0, 1)
              end
            end
          else
            local jl = 5
            if 5 <= lv then
              jl = 10
            end
            if GetRandom100(jl) then
              if 5 <= lv then
                u:settimedata("礼奈-深度幻听症", 3)
              else
                u:buffset(u.handle, 3, "绝对闪避")
                u:settimedata("礼奈-幻听症", 3)
                u:clearselect()
              end
              ac.timer(500, 5, function()
                u:effectadd("Abilities\\Spells\\Undead\\Sleep\\SleepSpecialArt.mdl", "chest", 0.5)
              end)
            end
          end
        end
        if lv ~= u:getdata("雏见泽候群症等级") then
          if lv == 1 then
            u:changedata("闪避值", -40)
            ChangeValue(DamageSystem_Ssjianshao, sy, 0.5, 2)
            ChangeValue(Correction_CureUp, sy, -0.25)
          end
          if lv == 2 then
            u:changedata("闪避值", -20)
            ChangeValue(DamageSystem_Ssjianshao, sy, 0.75, 2)
            ChangeValue(Correction_CureUp, sy, -0.25)
            ChangeValue(DamageSystem_Shjc, sy, -0.05)
            ChangeValue(Correction_Jzsh, sy, -0.025)
          end
          if lv == 3 then
            ChangeValue(DamageSystem_Baoji, sy, -15)
            ChangeValue(DamageSystem_Baoshang, sy, -0.3)
            ChangeValue(DamageSystem_Shjc, sy, -0.1)
            ChangeValue(Correction_Jzsh, sy, -0.05)
          end
          if lv == 4 then
            ChangeValue(DamageSystem_Baoji, sy, -20)
            ChangeValue(DamageSystem_Baoshang, sy, -0.4)
            ChangeValue(DamageSystem_Shjc, sy, -0.15)
            ChangeValue(Correction_Jzsh, sy, -0.07500000000000001)
            ChangeValue(DamageSystem_EndSh, sy, -0.015)
            ChangeValue(DamageSystem_Sszengjia, sy, -0.3)
          end
          if lv == 5 then
            ChangeValue(DamageSystem_Baoji, sy, -25)
            ChangeValue(DamageSystem_Baoshang, sy, -0.5)
            ChangeValue(DamageSystem_Shjc, sy, -0.2)
            ChangeValue(Correction_Jzsh, sy, -0.1)
            ChangeValue(DamageSystem_EndSh, sy, -0.025)
            ChangeValue(DamageSystem_Sszengjia, sy, -0.3)
            ChangeValue(HeroMenu_HpRemove_MaxHp, sy, -0.5)
            ChangeValue(HeroMenu_HpRemove_CurHp, sy, -2)
            u:beunion()
          end
          lv = u:getdata("雏见泽候群症等级")
          if lv == 1 then
            u:changedata("闪避值", 40)
            ChangeValue(DamageSystem_Ssjianshao, sy, 0.5, 1)
            ChangeValue(Correction_CureUp, sy, 0.25)
          end
          if lv == 2 then
            u:changedata("闪避值", 20)
            ChangeValue(DamageSystem_Ssjianshao, sy, 0.75, 1)
            ChangeValue(Correction_CureUp, sy, 0.25)
            ChangeValue(DamageSystem_Shjc, sy, 0.05)
            ChangeValue(Correction_Jzsh, sy, 0.025)
          end
          if lv == 3 then
            ChangeValue(DamageSystem_Baoji, sy, 15)
            ChangeValue(DamageSystem_Baoshang, sy, 0.3)
            ChangeValue(DamageSystem_Shjc, sy, 0.1)
            ChangeValue(Correction_Jzsh, sy, 0.05)
          end
          if lv == 4 then
            ChangeValue(DamageSystem_Baoji, sy, 20)
            ChangeValue(DamageSystem_Baoshang, sy, 0.4)
            ChangeValue(DamageSystem_Shjc, sy, 0.15)
            ChangeValue(Correction_Jzsh, sy, 0.07500000000000001)
            ChangeValue(DamageSystem_EndSh, sy, 0.015)
            ChangeValue(DamageSystem_Sszengjia, sy, 0.3)
          end
          if lv == 5 then
            ChangeValue(DamageSystem_Baoji, sy, 25)
            ChangeValue(DamageSystem_Baoshang, sy, 0.5)
            ChangeValue(DamageSystem_Shjc, sy, 0.2)
            ChangeValue(Correction_Jzsh, sy, 0.1)
            ChangeValue(DamageSystem_EndSh, sy, 0.025)
            ChangeValue(DamageSystem_Sszengjia, sy, 0.3)
            ChangeValue(HeroMenu_HpRemove_MaxHp, sy, 0.5)
            ChangeValue(HeroMenu_HpRemove_CurHp, sy, 2)
            u:beenemy()
          end
        end
        lv = u:getdata("雏见泽候群症等级")
      end)
      local yx = {
        [1] = Sound_Rena_Kawai_01,
        [2] = Sound_Rena_Kawai_02,
        [3] = Sound_Rena_Kawai_03,
        [4] = Sound_Rena_Kawai_04,
        [5] = Sound_Rena_Kawai_05,
        [6] = Sound_Rena_Kawai_06,
        [7] = Sound_Rena_Kawai_07,
        [8] = Sound_Rena_Find_09,
        [9] = Sound_Rena_Find_10,
        [10] = Sound_Rena_Find_11,
        [11] = Sound_Rena_Find_12,
        [12] = Sound_Rena_Find_13,
        [13] = Sound_Rena_Find_14,
        [14] = Sound_Rena_Find_15,
        [15] = Sound_Rena_Find_16,
        [16] = Sound_Rena_Find_01,
        [17] = Sound_Rena_Find_02,
        [18] = Sound_Rena_Find_03,
        [19] = Sound_Rena_Find_04,
        [20] = Sound_Rena_Find_05,
        [21] = Sound_Rena_Find_06,
        [22] = Sound_Rena_Find_07,
        [23] = Sound_Rena_Find_08,
        [24] = Sound_Rena_Find_17,
        [25] = Sound_Rena_Why_01,
        [26] = Sound_Rena_Why_02,
        [27] = Sound_Rena_Why_03,
        [28] = Sound_Rena_Cheat_01,
        [29] = Sound_Rena_Cheat_02,
        [30] = Sound_Rena_Cheat_03,
        [31] = Sound_Rena_Cheat_04,
        [32] = Sound_Rena_Cheat_05,
        [33] = Sound_Rena_Laugh_01,
        [34] = Sound_Rena_Laugh_02,
        [35] = Sound_Rena_Laugh_03,
        [36] = Sound_Rena_Laugh_04,
        [37] = Sound_Rena_Laugh_05
      }
      ac.loop(1000, function()
        local lv = u:getdata("雏见泽候群症等级")
        local byx
        if lv == 1 then
          byx = yx[GetRandomInt(1, 7)]
        elseif lv == 2 then
          byx = yx[GetRandomInt(8, 24)]
        elseif lv == 3 then
          byx = yx[GetRandomInt(8, 32)]
        elseif lv == 4 then
          byx = yx[GetRandomInt(25, 37)]
        elseif lv == 5 then
          byx = yx[GetRandomInt(25, 37)]
        end
        local b = false
        local x1, y1 = u:getxy()
        for _, xq in ac.selector():in_rangexy(x1, y1, 1800):isingroup(Group_PlayHero):ipairs() do
          xq = getunit(xq)
          if xq ~= u then
            b = true
          end
        end
        if u:hasdata("礼奈语音冷却") then
          b = false
        end
        if GetRandom100(90) then
          b = false
        end
        if not u:isalive() then
          b = false
        end
        if b then
          u:playsound(byx)
          u:settimedata("礼奈语音冷却", 3)
        end
      end)
      
      local function chattrg(args)
        if args.chat == "黑化" and u:isalive() and not u:hasdata("黑化冷却") then
          u:settimedata("黑化冷却", 360)
          local x, y = u:getxy()
          Effectcreate("war3mapImported\\uberdarkwave.mdx", x, y)
          ac.wait(360000, function()
            u:sendmessage("|cFF990000黑化冷却完毕|r")
          end)
          u:settimedata("礼奈-黑化状态", 60)
          ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 100, 60)
          ChangeTimeValue(HeroMenu_ExtraMoveSpeed_Bfb, sy, 0.5, 60)
          local yxz = {
            Sound_Rena_Cheat_01,
            Sound_Rena_Cheat_02,
            Sound_Rena_Cheat_03,
            Sound_Rena_Cheat_04,
            Sound_Rena_Cheat_05
          }
          u:playsound(yxz[GetRandomInt(1, #yxz)])
        end
        if args.chat == "礼奈可爱么" and u:isalive() and not u:hasdata("礼奈-黑化状态") then
          u:setdata("雏见泽候群症点数", 0)
          u:sendmessage("|cFFFF66CC雏见泽候群症点数清零|r")
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chattrg(args)
      end)
      u:addtrgevent("单位-被攻击", function(args)
        local soc = args.soc
        local u = args.u
        local lv = u:getdata("雏见泽候群症等级")
        if lv <= 2 then
          local vest = getunit(System_SkillVest)
          vest:addskill("A142")
          if lv == 2 then
            vest:setskilllevel("A142", 2)
          end
          IssueTargetOrder(vest.handle, "slow", soc.handle)
          vest:delskill("A142")
        end
      end)
    end,
    effectname = "|cFFFF66CC龙宫礼奈|r",
    effecttext = "|cFFFF66CC性格模式|r\n|cFFCC3333[可爱么可爱么可爱么可爱么]|r\n|cFFFF66CC意想不到的名侦探|r\n|cFFCC3333[为什么为什么为什么为什么]|r\n|cFFFF66CC雏见泽候群症|r\n|cFFCC3333[骗人骗人骗人骗人骗人骗人]|r\n|cFFFF66CC鲜血淋漓|r\n|cFFCC3333[哈哈哈哈哈哈哈哈哈哈哈哈]|r\n|cFFFF66CC快速学习|r\n|cFFCC3333[吵死了吵死了吵死了吵死了]|r\n|cFFFF66CC奈落之花|r\n|cFFCC3333[数据删除]|r",
    effectart = "war3mapImported\\BTNEwl_Rena.blp",
    test = [[

    ]]
  },
  {
    name = "杨间",
    weight = 2500,
    lv = 5,
    key = {"唯一"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("杨间-初始") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:additem("I0Q2")
      if CIUC[sy] == "-1575679099" then
        ShowNameCount[sy] = 1
        Boolean_ColorName[sy] = true
        ColorName[sy][1] = {
          method = 1,
          name = "当灵异开始复苏，厉鬼再次出现",
          colors = {
            "000000",
            "FF0000",
            "FF0000",
            "FF0000",
            "000000"
          },
          length = 5,
          lengthcd = 25,
          math = 1,
          offsetspeed = 0.12
        }
        transition_phrases({
          name = {
            "当灵异开始复苏，厉鬼再次出现",
            "众生遭受苦难，世人呼喊此名的那一刻",
            "你将显化于世，驱鬼除恶 救人扬善",
            "「杨间」"
          },
          sy = sy,
          delay = 100,
          pause_time = 3000,
          restart_each_line = true
        })
        if u:hasdata("爱弥斯-初始") then
          u:setdata("判定-小小奇迹")
          u:additem("I0Z3")
        end
      end
      local x, y = u:getxy()
      local tx = Effectcreate("Yangjian_Huanrao.mdx", x, y, -1, 2, -25)
      ac.loop(50, function()
        local x, y = u:getxy()
        SetEffectXY(tx, x - 16, y - 16)
      end)
      ac.loop(330, function()
        if u:isalive() then
          local x, y = u:getxy()
          local ax, ay = PolarXY(x, y, GetRandomReal(50, 150), GetRandomAngle())
          Effectcreate("Yangjian_Huanrao2.mdx", ax, ay)
        end
      end)
      ac.wait(100, function()
        u:uivar_change({
          keyname = "杨间",
          keytype = "传奇栏",
          text = "|cFF666666鬼|r|cFF705C5C眼|r|cFF7A5252杨|r|cFF854747间|r\n\n|cFF999999我|r|cFF9B9494叫|r|cFF9D8E8E杨|r|cFF9E8989间|r|cFFA08484，|r\n|cFFA27F7F当|r|cFFA47979你|r|cFFA57474看|r|cFFA76F6F到|r|cFFA96A6A这|r|cFFAB6464句|r|cFFAC5F5F话|r|cFFAE5A5A的|r|cFFB05454时|r|cFFB24F4F候|r|cFFB34A4A我|r|cFFB54545已|r|cFFB73F3F经|r|cFFB93A3A死|r|cFFBA3535了|r|cFFBC2F2F.|r|cFFBE2A2A.|r|cFFC02525.|r|cFFC12020.|r|cFFC31A1A.|r|cFFC51515.|r\n\n|cFF999999一|r|cFF999797张|r|cFF999696灵|r|cFF999494异|r|cFF999393的|r|cFF999191纸|r\n|cFF998E8E一|r|cFF998C8C只|r|cFF998B8B窥|r|cFF998989视|r|cFF998787黑|r|cFF998686暗|r|cFF998484的|r|cFF998383眼|r|cFF998181睛|r\n|cFF997E7E这|r|cFF997C7C是|r|cFF997B7B一|r|cFF997979个|r|cFF997878活|r|cFF997676下|r|cFF997474来|r|cFF997373的|r|cFF997171人|r|cFF997070经|r|cFF996E6E历|r|cFF996C6C的|r|cFF996B6B故|r|cFF996969事|r",
          icon = "Cq_Yangjian_Chuanqi",
          ishasphoto = true
        })
      end)
      
      local function make_yangjian_ghost_text(title, intro)
        local owner = "|cFF666666鬼|r|cFF705C5C眼|r|cFF7A5252杨|r|cFF854747间|r"
        return "|cFF939393" .. title .. "|r\n|cFF939393【所属】" .. owner .. [[
|r
|cFF939393]] .. intro .. "|r"
      end
      
      local function update_yangjian_guiyan_ui()
        local layer = math.floor(u:getdata("杨间-鬼域层数"))
        local ghost_count = math.floor(u:getdata("杨间-鬼计数"))
        local fifth_state = u:hasdata("杨间-第五层鬼域开启") and "|cff750000开启|r" or "|cFFCC6666关闭|r"
        local fifth_line = ""
        if 5 <= layer then
          fifth_line = "\n\n五层鬼域：__FIFTH__"
        end
        local text = "|cFFCC0000鬼眼|r\n|cFF999999当前鬼域：第__LAYER__层\n\n鬼计数：__GHOST__\n\n点击进阶" .. fifth_line .. "|r\n\n|cFF990000有些事情总是要有人去做的，\n这个残酷的时代也总要有人去背负。\n不是命运选择了我，而是我选择了命运。|r"
        text = text:gsub("__LAYER__", tostring(layer))
        text = text:gsub("__GHOST__", tostring(ghost_count))
        text = text:gsub("__FIFTH__", fifth_state)
        u:uivar_change({
          keyname = "鬼眼",
          keytype = "传奇栏",
          text = text
        })
      end
      
      local function apply_yangjian_ghost_hooks()
        if u:hasdata("杨间-鬼影") and not u:hasdata("杨间-鬼影-回调") then
          u:setdata("杨间-鬼影-回调")
          u:setdata("系统-无视伤害免疫")
        end
        if u:hasdata("杨间-鬼手") and not u:hasdata("杨间-鬼手-回调") then
          u:setdata("杨间-鬼手-回调")
          ChangeValue(DamageSplit_CountJzHit, sy, 1)
          u:addstexiao("杨间-鬼手", "直接伤害特效", function(args)
            local tg = args.tg
            local u = args.u
            local info = args.damageinfo
            if u:hasdata("杨间-鬼手-生命损耗冷却") then
              return
            end
            if not u:getluckrandom(info.txgl * 20) then
              return
            end
            u:settimedata("杨间-鬼手-生命损耗冷却", 1)
            local damage = u:getdata("杨间-灵异计数") * 36 + u:getdata("杨间-鬼计数") * 3333
            LossHpUnit({
              u = u,
              tg = tg,
              damage = damage,
              perhp = 0,
              maxhp = 0,
              bj = "[生命损耗]杨间-鬼手"
            })
          end)
          u:addstexiao("杨间-鬼手", "近战伤害效果", function(args)
            local u = args.u
            local info = args.damageinfo
            local count = u:getdata("杨间-灵异计数")
            local bonus = 0
            if 900 <= count then
              bonus = 0.15
            elseif 600 <= count then
              bonus = 0.1
            elseif 300 <= count then
              bonus = 0.05
            end
            if 0 < bonus then
              info.damage = info.damage * (1 + bonus)
            end
          end)
        end
        if u:hasdata("杨间-鬼火") and not u:hasdata("杨间-鬼火-回调") then
          u:setdata("杨间-鬼火-回调")
          u:setdata("杨间-鬼火-转换属性", "无")
          local text = "|cFF939393鬼火·属性转换\n仅将无属性伤害转换为所选属性。\n当前模式：%s|r"
          AddUISkill({
            text = "杨间-鬼火-属性转换",
            u = u,
            cd = 1,
            icon = "Yangjian_Gui_Guihuo.tga",
            showtext = text:format("不转换"),
            func = function(args)
              local element = u:getdata("杨间-鬼火-转换属性")
              if element == "无" then
                element = "暗"
              elseif element == "暗" then
                element = "火"
              else
                element = "无"
              end
              u:setdata("杨间-鬼火-转换属性", element)
              local mode = element == "无" and "不转换" or element .. "属性"
              if u:islocal() then
                args.button.showtext = text:format(mode)
              end
              u:sendmessage("|cFF939393[鬼火]当前模式：" .. mode .. "|r")
            end
          })
          u:addstexiao("杨间-鬼火", "直接伤害变更", function(args)
            local tg = args.tg
            local info = args.damageinfo
            if tg:isboss() then
              return
            end
            if not tg:hasdata("精英特性-失效") then
              tg:settimedata("精英特性-失效", 3)
              tg:buffset(args.u.handle, 3, "精英特性失效")
            end
            if tg:iselite() then
            else
              args.shadd = args.shadd + 0.4
            end
          end)
        end
        if u:hasdata("杨间-鬼梦") and not u:hasdata("杨间-鬼梦-回调") then
          u:setdata("杨间-鬼梦-回调")
          u:addskill("S0E4")
          u:addskill("S0E5")
          u:addstexiao("杨间-鬼梦", "直接伤害特效", function(args)
            local tg = args.tg
            tg:settimedata("杨间-鬼梦抑制恢复", 1)
          end)
        end
        if u:hasdata("杨间-鬼湖") and not u:hasdata("杨间-鬼湖-回调") then
          u:setdata("杨间-鬼湖-回调")
          
          local function lake_reduce(args)
            local info = args.damageinfo
            local time = GetTimeOfDay()
            local night = 18 <= time or time < 6
            if night or u:hasdata("杨间-鬼血") then
              info.ewjs = 1
            end
          end
          
          u:addstexiao("杨间-鬼湖", "怪物减伤计算", lake_reduce)
        end
        if u:hasdata("杨间-鬼血") and not u:hasdata("杨间-鬼血-回调") then
          u:setdata("杨间-鬼血-回调")
          u:addstexiao("杨间-鬼血", "过波时效果", function(args)
            local add = u:getdata("杨间-灵异计数") * 0.03
            if 0 < add then
              u:changemaxhp(add)
            end
            local element_add = u:getdata("杨间-灵异计数") * 1.0E-5
            if 0 < element_add then
              ChangeValue(Damage_Element_Dark, sy, element_add)
              ChangeValue(Damage_Element_Fire, sy, element_add)
            end
          end)
        end
        if u:hasdata("杨间-静悄悄") and not u:hasdata("杨间-静悄悄-回调") then
          u:setdata("杨间-静悄悄-回调")
          u:addstexiao("杨间-静悄悄", "子弹创建时效果", function(args)
            if not args.mj then
              return
            end
            if GetRandom100(45) then
              args.mj:setdata("杨间-静悄悄-额外射击")
            end
          end)
          u:addstexiao("杨间-静悄悄", "子弹伤害后效果", function(args)
            local mj = args.mj
            if not mj or not mj:hasdata("杨间-静悄悄-额外射击") then
              return
            end
            if mj:hasdata("杨间-静悄悄-额外射击-已触发") then
              return
            end
            mj:setdata("杨间-静悄悄-额外射击-已触发")
            args.damage = args.damage * 2
          end)
          u:addstexiao("杨间-静悄悄", "近战伤害效果", function(args)
            if GetRandom100(45) then
              args.damageinfo.damage = args.damageinfo.damage * 2
            end
          end)
        end
      end
      
      local yangjian_ghost_icons = {
        ["杨间-鬼影"] = {
          text = make_yangjian_ghost_text("鬼影", "第二只鬼，于大昌市“商场失踪”事件首次遇见。"),
          icon = "Yangjian_Gui_Guiying.tga"
        },
        ["杨间-鬼手"] = {
          text = make_yangjian_ghost_text("鬼手", "第三只鬼，于飞机“鬼掐人”事件中关押。"),
          icon = "Yangjian_Gui_Guishou.tga"
        },
        ["杨间-鬼火"] = {
          text = make_yangjian_ghost_text("鬼火", "于“鬼画”事件中由杨间驾驭垂死的李军的鬼火。"),
          icon = "Yangjian_Gui_Guihuo.tga"
        },
        ["杨间-鬼梦"] = {
          text = make_yangjian_ghost_text("鬼梦", "顶级意识类厉鬼，最早由杨间父亲杨孝尝试驾驭。"),
          icon = "Yangjian_Gui_Guimeng.tga"
        },
        ["杨间-鬼湖"] = {
          text = make_yangjian_ghost_text("鬼湖", "太平古镇湖水里的神秘女尸。"),
          icon = "Yangjian_Gui_Guihu.tga"
        },
        ["杨间-许愿鬼"] = {
          text = make_yangjian_ghost_text("许愿鬼", "赵开明遗留的灵异拼图之一。"),
          icon = "Yangjian_Gui_Xuyuangui.tga"
        },
        ["杨间-鬼公交"] = {
          text = make_yangjian_ghost_text("鬼公交", "民国时期灵异拼图产物，初代由秦老掌控，后被杨间驾驭。"),
          icon = "Yangjian_Gui_Guigongjiao.tga"
        },
        ["杨间-静悄悄"] = {
          text = make_yangjian_ghost_text("静悄悄", "一种唯心的鬼，只要有人说出“鬼”这个字它就会出现。"),
          icon = "Yangjian_Gui_Jingqiaoqiao.tga"
        },
        ["杨间-鬼血"] = {
          text = make_yangjian_ghost_text("鬼血", "源自未知灵异血海，与血鬼相连，可接引血海力量。"),
          icon = "Yangjian_Gui_Guixue.tga"
        }
      }
      
      local function ensure_yangjian_ghost_icon(key)
        local info = yangjian_ghost_icons[key]
        if not (info and u:hasdata(key)) or u:hasdata(key .. "-ui") then
          return
        end
        u:setdata(key .. "-ui")
        u:uivar_add({
          keyname = key,
          keytype = "传奇栏",
          text = info.text,
          icon = info.icon
        })
      end
      
      local function apply_yangjian_kill_reward(base_add, allow_blood_chain, monster)
        local add = base_add
        if u:hasdata("杨间-棺材钉") then
          add = add * 1.5
        end
        if u:hasdata("杨间-鬼影") then
          add = add + 1
        end
        if monster and monster:hasdata("杨间-第五层鬼域击杀") then
          add = add + 1
          monster:deldata("杨间-第五层鬼域击杀")
        end
        u:changedata("杨间-灵异计数", add)
        if u:hasdata("杨间-鬼梦") then
          local hp_add = u:getdata("杨间-灵异计数") * 1.0E-4 + u:getdata("杨间-鬼计数") * 0.1
          if 0 < hp_add then
            u:changemaxhp(hp_add)
          end
        end
        if allow_blood_chain and u:hasdata("杨间-鬼血") and GetRandom100(20) then
          apply_yangjian_kill_reward(base_add, false)
        end
      end
      
      function YangjianUseWish(u, wish_index)
        if not u or not u:hasdata("杨间-许愿鬼") then
          return false
        end
        if wish_index < 1 or 5 < wish_index then
          return false
        end
        if u:hasdata("杨间-言出法随-冷却") then
          u:sendmessage("|cFF999999[言出法随]冷却中|r")
          return false
        end
        local wish_key = "杨间-许愿鬼-愿望" .. wish_index
        if u:hasdata(wish_key) then
          u:sendmessage("|cFF999999该愿望已经使用过了|r")
          return false
        end
        u:settimedata("杨间-言出法随-冷却", 180)
        ac.wait(180000, function()
          if u then
            u:sendmessage("|cFF66CCFF[言出法随]冷却完毕|r")
          end
        end)
        u:setdata(wish_key)
        if wish_index == 1 then
          local add = Time_M * 60 + Time_S
          if 0 < add then
            u:addgold(add)
          end
          u:sendmessage("|cFF66CCFF[言出法随]获得积分:" .. math.floor(add) .. "|r")
        elseif wish_index == 2 then
          u:setdata("杨间-决死次数", math.min(3, u:getdata("杨间-决死次数") + 1))
          u:sendmessage("|cFF66CCFF[言出法随]获得决死|r")
        elseif wish_index == 3 then
          local x, y = u:getxy()
          local pools = {
            Pools_SpeWeapon,
            Pools_SpeDzWeapon,
            Pools_SpeNormalWeapon
          }
          herogetitem(u.handle, pools, x, y)
          herogetitem(u.handle, pools, x, y)
          u:sendmessage("|cFF66CCFF[言出法随]获得特殊武器|r")
        elseif wish_index == 4 then
          u:additem(MEDICINE_XUEHUAI)
          u:additem(MEDICINE_MWX, 2)
          u:additem(MEDICINE_XINGYOU, 2)
          u:additem("I09D", 3)
          u:sendmessage("|cFF66CCFF[言出法随]获得物品|r")
        elseif wish_index == 5 then
          local add = math.ceil(u:getdata("杨间-灵异计数") * 0.25)
          if 0 < add then
            u:changedata("杨间-灵异计数", add)
          end
          u:sendmessage("|cFF66CCFF[言出法随]灵异计数提升|r")
        end
        return true
      end
      
      local function refresh_yangjian_ghost_unlocks()
        local unlocked = false
        local ly = u:getdata("杨间-灵异计数")
        local level = u:getlevel()
        local count = u:getdata("杨间-鬼计数")
        local total_lv = u:getdata("系统-累积等级")
        local layer = u:getdata("杨间-鬼域层数")
        
        local function unlock(key, msg, extra)
          if u:hasdata(key) then
            return false
          end
          u:setdata(key)
          u:changedata("杨间-鬼计数", 1)
          if extra then
            extra()
          end
          u:sendmessage(msg)
          unlocked = true
          return true
        end
        
        if 150 <= ly and unlock("杨间-鬼影", "|cFF666666解锁[杨间-鬼影]|r") then
          u:additem("I0Q1")
          ensure_yangjian_ghost_icon("杨间-鬼影")
          apply_yangjian_ghost_hooks()
        end
        if 500 <= ly and unlock("杨间-鬼手", "|cFF666666解锁[杨间-鬼手]|r") then
          ensure_yangjian_ghost_icon("杨间-鬼手")
          apply_yangjian_ghost_hooks()
        end
        if 25 <= level and unlock("杨间-鬼火", "|cFF666666解锁[杨间-鬼火]|r") then
          ensure_yangjian_ghost_icon("杨间-鬼火")
          apply_yangjian_ghost_hooks()
        end
        if 1000 <= ly and unlock("杨间-鬼梦", "|cFF666666解锁[杨间-鬼梦]|r") then
          ensure_yangjian_ghost_icon("杨间-鬼梦")
          apply_yangjian_ghost_hooks()
        end
        if u:getdata("杨间-魔力石使用次数") >= 6 and unlock("杨间-鬼湖", "|cFF666666解锁[杨间-鬼湖]|r") then
          ensure_yangjian_ghost_icon("杨间-鬼湖")
          apply_yangjian_ghost_hooks()
        end
        if 45 <= total_lv and unlock("杨间-许愿鬼", "|cFF666666解锁[杨间-许愿鬼]|r") then
          ensure_yangjian_ghost_icon("杨间-许愿鬼")
        end
        if 8 <= layer and unlock("杨间-鬼公交", "|cFF666666解锁[杨间-鬼公交]|r") then
          ensure_yangjian_ghost_icon("杨间-鬼公交")
        end
        if 2500 <= ly and unlock("杨间-静悄悄", "|cFF666666解锁[杨间-静悄悄]|r") then
          ChangeValue(Damage_ElementRes_All, sy, 20)
          ensure_yangjian_ghost_icon("杨间-静悄悄")
        end
        if 10 <= layer and u:hasdata("杨间-鬼影") and u:hasdata("杨间-鬼手") and u:hasdata("杨间-鬼火") and u:hasdata("杨间-鬼梦") and u:hasdata("杨间-鬼湖") and u:hasdata("杨间-许愿鬼") and u:hasdata("杨间-鬼公交") and u:hasdata("杨间-静悄悄") and unlock("杨间-鬼血", "|cFF666666解锁[杨间-鬼血]|r") then
          AbsorbYangjianBloodItems(u)
          ensure_yangjian_ghost_icon("杨间-鬼血")
        end
        for key, _ in pairs(yangjian_ghost_icons) do
          ensure_yangjian_ghost_icon(key)
        end
        return unlocked
      end
      
      local function start_yangjian_tenth_layer()
        if u:hasdata("杨间-第十层鬼域初始化") then
          return
        end
        u:setdata("杨间-第十层鬼域初始化")
        u:setdata("杨间-决死次数", math.max(1, u:getdata("杨间-决死次数")))
        u:sendmessage("|cFFAA5555[第十层鬼域]获得1次决死|r")
        ac.timer(60000, 3, function()
          local add = u:getdata("杨间-鬼计数") * 0.01
          ChangeValue(DamageSystem_EndSh, sy, 0.1 * add)
          u:sendmessage("|cFFAA5555[第十层鬼域]终结伤害提升|r")
        end)
        local elapsed = 0
        ac.loop(1000, function()
          if u:getdata("杨间-决死次数") >= 3 then
            elapsed = 0
            return
          end
          elapsed = elapsed + 1
          local cooldown = math.max(1, 600 - 10 * u:getdata("杨间-鬼计数"))
          if cooldown <= elapsed then
            elapsed = 0
            u:changedata("杨间-决死次数", 1)
            u:sendmessage("|cFFAA5555[第十层鬼域]决死次数恢复，当前：" .. math.floor(u:getdata("杨间-决死次数")) .. "|r")
          end
        end)
      end
      
      local function unlock_yangjian_domain(layer)
        u:setdata("杨间-鬼域层数", layer)
        u:changedata("杨间-鬼计数", 1)
        if layer == 3 then
          u:addskill("A0X6")
        elseif layer == 5 then
          u:setdata("杨间-第五层鬼域开启")
          local x, y = u:getxy()
          local tx = Effectcreate("Yangjian_Guiyu.mdx", x, y, -1, 1, -990)
          SetEffectAnimation(tx, "birth")
          SetEffectAlpha(tx, 155)
          ac.wait(2300, function()
            SetEffectAnimation(tx, "stand")
          end)
          ac.loop(30, function()
            if u:isalive() and u:hasdata("杨间-第五层鬼域开启") then
              local x, y = u:getxy()
              x = x - 16
              y = y - 16
              local loc = Location(x, y)
              local h = GetLocationZ(loc)
              RemoveLocation(loc)
              SetEffectHeight(tx, h - 990)
              SetEffectXY(tx, x, y)
            else
              SetEffectXY(tx, PX_X, PX_Y)
            end
          end)
        elseif layer == 9 then
          ChangeValue(Correction_Exp, sy, 0.5)
        elseif layer == 10 then
          start_yangjian_tenth_layer()
        end
        u:sendmessage("|cFFAA5555解锁[第" .. layer .. "层鬼域]，鬼计数提高1|r")
        update_yangjian_guiyan_ui()
      end
      
      local yangjian_domain_unlocks = {
        {layer = 3, need = 2},
        {layer = 5, need = 4},
        {layer = 6, need = 6},
        {layer = 7, need = 8},
        {layer = 8, need = 10},
        {layer = 9, need = 12},
        {layer = 10, need = 14}
      }
      
      local function click_yangjian_guiyan()
        local current_layer = u:getdata("杨间-鬼域层数")
        local ghost_count = u:getdata("杨间-鬼计数")
        local next_unlock
        for _, info in ipairs(yangjian_domain_unlocks) do
          if current_layer < info.layer then
            next_unlock = info
            break
          end
        end
        if next_unlock and ghost_count >= next_unlock.need then
          unlock_yangjian_domain(next_unlock.layer)
          return
        end
        if 5 <= current_layer then
          if u:hasdata("杨间-第五层鬼域开启") then
            u:deldata("杨间-第五层鬼域开启")
            u:sendmessage("|cFFCC6666第五层鬼域已关闭|r")
          else
            u:setdata("杨间-第五层鬼域开启")
            u:sendmessage("|cff911111第五层鬼域已开启|r")
          end
          update_yangjian_guiyan_ui()
          return
        end
        if next_unlock then
          u:sendmessage("|cFF999999解锁第" .. next_unlock.layer .. "层鬼域需要" .. next_unlock.need .. "点鬼计数|r")
        end
      end
      
      ac.wait(200, function()
        u:uivar_add({
          keyname = "鬼眼",
          keytype = "传奇栏",
          text = "|cFFCC0000鬼眼|r",
          icon = "Cq_Yangjian_Guiyan",
          cd = 0.2,
          ishasphoto = true,
          clickfunc = function()
            click_yangjian_guiyan()
          end
        })
        update_yangjian_guiyan_ui()
      end)
      SendJbMsgAll({
        strstart = "|cffbb4c4c『",
        strz = "我叫杨间，",
        strend = "』|r",
        time = 0.4,
        shunxu = 1,
        waittime = 0
      })
      SendJbMsgAll({
        strstart = "|cffbb4c4c『我叫杨间，",
        strz = "当你看到这句话的时候，",
        strend = "』|r",
        time = 0.9,
        shunxu = 1,
        waittime = 2
      })
      SendJbMsgAll({
        strstart = "|cffbb4c4c『我叫杨间，当你看到这句话的时候，",
        strz = "我已经",
        strend = "』|r",
        time = 0.2,
        shunxu = 1,
        waittime = 4.8
      })
      SendJbMsgAll({
        strstart = "|cffbb4c4c『我叫杨间，当你看到这句话的时候，我已经|r|cFF990000",
        strz = "死了",
        strend = "|r|cffbb4c4c』|r",
        time = 0.2,
        shunxu = 1,
        waittime = 5.2
      })
      PlayBGM({
        bgm = 0,
        time = 244,
        ID = 65,
        unit = u.handle
      })
      PlayGlobalSound(Sound_Yangjian_Cq)
      ac.wait(3000, function()
        PlayGlobalSound(BGM_Yangjian_Cq)
        SetSoundVolumeBJ(BGM_Yangjian_Cq, 40)
        ac.wait(2500, function()
          local snd = 40
          ac.timer(100, 30, function()
            snd = snd + 2
            SetSoundVolumeBJ(BGM_Yangjian_Cq, snd)
          end)
        end)
        songtext({
          text = {
            {
              starttime = 0,
              str = "然秉生天地 何敢退却"
            },
            {
              starttime = 6.5,
              str = "三尺微命也 留名一页"
            },
            {
              starttime = 13.9,
              str = "千峰丛云 泼墨里挥毫写"
            },
            {
              starttime = 20.1,
              str = "落笔肝胆语冰雪",
              time = 7.5
            },
            {
              starttime = 29.4,
              str = "且醉放北斗 点指天阙"
            },
            {
              starttime = 36,
              str = "身世寸微中 甲第名列"
            },
            {
              starttime = 43.5,
              str = "万尺河山 危仞千叠"
            },
            {
              starttime = 49.7,
              str = "风雨处 肝胆照冰雪",
              time = 7.6
            }
          },
          isjbcolor = true,
          color = {
            "FF610000",
            "FFDB4444",
            "FFDB4444",
            "FF610000"
          }
        })
      end)
      u:addskill("S0CV")
      u:adddivinity(1)
      local gj = 0
      local exp = 0
      local jz = 0
      local gold = 0
      local shjc = 0
      local endsh = 0
      local element = 0
      local conflict = 0
      local lake_magic = 0
      local lake_tili = 0
      local lake_hp = 0
      local bus_move = 0
      local bus_fixed = 0
      local guishou_bj = 0
      local guishou_bs = 0
      ChangeValue(Correction_Exp, sy, 0.15)
      ChangeValue(DamageSystem_EndSh, sy, 0.005)
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, -shjc)
        u:changedata("固定格挡", -gj)
        ChangeValue(Correction_Exp, sy, -2 * exp)
        ChangeValue(Correction_Jzsh, sy, -jz)
        ChangeValue(Correction_Gold, sy, -gold)
        ChangeValue(DamageSystem_EndSh, sy, -endsh)
        ChangeValue(Damage_Element_Fire, sy, -element)
        ChangeValue(Damage_Element_Dark, sy, -element)
        ChangeValue(Correction_Magic, sy, -lake_magic)
        ChangeValue(Hero_Tili_Huifu, sy, -lake_tili)
        ChangeValue(HeroMenu_HpForever_Inr, sy, -lake_hp)
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -bus_move)
        u:changedata("固定伤害", -bus_fixed)
        ChangeValue(DamageSystem_Baoji, sy, -guishou_bj)
        ChangeValue(DamageSystem_Baoshang, sy, -guishou_bs)
        local count = u:getdata("杨间-鬼计数") / 20
        local ly = u:getdata("杨间-灵异计数") / 30000
        local layer = u:getdata("杨间-鬼域层数")
        local level = u:getdata("系统-累积等级") / 50
        local night = IsTimeNight()
        local lake_active = night or u:hasdata("杨间-鬼血")
        lake_tili = count
        lake_hp = count
        lake_magic = 0
        if lake_active then
          lake_magic = 1 * ly + 1 * count * level
        end
        bus_move = 0
        bus_fixed = 0
        if u:hasdata("杨间-鬼公交") then
          bus_move = 1000 * ly
          bus_fixed = u:getdata("当前额外移速") * 15
        end
        guishou_bj = 0
        guishou_bs = 0
        if u:hasdata("杨间-鬼手") then
          guishou_bj = ly * 25
          guishou_bs = ly * 0.5
        end
        gj = 500 * count
        exp = 0.3 * count
        jz = 0
        if u:hasdata("杨间-棺材钉") then
          jz = 1.5 * ly
        end
        gold = 0
        if u:hasdata("杨间-人皮纸") then
          gold = 0.3 * count
        end
        shjc = 1 * count * level
        if u:hasdata("杨间-棺材钉") then
          shjc = shjc + 1 * ly
        end
        if u:hasdata("杨间-鬼血") then
          shjc = shjc + 1 * ly + 1 * count * level
        end
        if u:hasdata("杨间-鬼公交") then
          shjc = shjc + 1 * ly
        end
        endsh = 0
        if u:hasdata("杨间-人皮纸") then
          endsh = endsh + 0.1 * count
        end
        if 10 <= layer then
          endsh = endsh + 0.1 * count
        end
        local jisuan = 18 - Stage
        if jisuan <= 1 then
          jisuan = 1
        end
        element = count / jisuan
        if u:hasdata("杨间-鬼血") then
          element = element + 1 * ly
        end
        ChangeValue(Correction_Magic, sy, lake_magic)
        ChangeValue(Hero_Tili_Huifu, sy, lake_tili)
        ChangeValue(HeroMenu_HpForever_Inr, sy, lake_hp)
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, bus_move)
        u:changedata("固定伤害", bus_fixed)
        ChangeValue(DamageSystem_Baoji, sy, guishou_bj)
        ChangeValue(DamageSystem_Baoshang, sy, guishou_bs)
        ChangeValue(Correction_Jzsh, sy, jz)
        ChangeValue(Correction_Gold, sy, gold)
        ChangeValue(Correction_Exp, sy, 2 * exp)
        u:changedata("固定格挡", gj)
        ChangeValue(DamageSystem_Shjc, sy, shjc)
        ChangeValue(DamageSystem_EndSh, sy, endsh)
        ChangeValue(Damage_Element_Fire, sy, element)
        ChangeValue(Damage_Element_Dark, sy, element)
        local conflict_bonus = 0
        if 3 <= layer then
          conflict_bonus = 3 + 10 * count
        end
        if conflict_bonus - conflict ~= 0 then
          ChangeZhanzhengqiyue(conflict_bonus - conflict, nil)
          conflict = conflict_bonus
        end
        refresh_yangjian_ghost_unlocks()
      end)
      u:setdata("杨间-鬼计数", 2)
      u:setdata("杨间-鬼域层数", 2)
      u:setdata("杨间-灵异计数", 0)
      if u:islocal() then
        BuffUI.apply({
          id = "杨间-鬼计数"
        })
        BuffUI.apply({
          id = "杨间-灵异力量"
        })
      end
      u:addstexiao("杨间-第三层鬼域", "伤害格挡效果", function(args)
        if u:getdata("杨间-鬼域层数") >= 3 and not args.b and not u:hasdata("杨间-第三层鬼域格挡冷却") then
          args.b = true
          u:settimedata("杨间-第三层鬼域格挡冷却", 40)
          u:effectadd("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", "chest")
          u:sendmessage("|cFFAA5555[第三层鬼域]抵挡伤害|r")
        end
      end)
      u:addstexiao("杨间-鬼域决死", "决死效果", function(args)
        if not args.dt then
          return
        end
        if u:getdata("杨间-鬼域层数") >= 10 and u:getdata("杨间-决死次数") > 0 then
          args.dt = false
          u:changedata("杨间-决死次数", -1)
          u:sendmessage("|cFFAA5555[第十层鬼域]决死，剩余：" .. math.floor(u:getdata("杨间-决死次数")) .. "|r")
          return
        end
        local layer = u:getdata("杨间-鬼域层数")
        if 7 <= layer and not u:hasdata("杨间-第七层鬼域决死冷却") then
          args.dt = false
          local cooldown = 8 <= layer and 360 or 480
          u:settimedata("杨间-第七层鬼域决死冷却", cooldown)
          u:clearbuff()
          u:sethp(100, true)
          u:buffset(u.handle, 1, "无敌")
          if 8 <= layer then
            u:settimedata("杨间-死亡抗拒", 2)
          end
          u:sendmessage("|cFFAA5555[第七层鬼域]决死|r")
        end
      end)
      ac.loop(1000, function()
        if not (not (u:getdata("杨间-鬼域层数") < 5) and u:hasdata("杨间-第五层鬼域开启")) or not u:isalive() then
          return
        end
        local x, y = u:getxy()
        local damage = u:getdata("杨间-灵异计数") * 36 + u:getdata("杨间-鬼计数") * 10000
        local range = 600
        if u:hasdata("杨间-鬼火") then
          range = range + 300
        end
        for _, target in ac.selector():in_rangexy(x, y, range):is_enemy(u.handle):ipairs() do
          local tg = getunit(target)
          if tg:isalive() then
            DamageUnit({
              bj = "杨间第五层鬼域",
              unit = tg.handle,
              source = u.handle,
              damage = damage,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = true,
              element = "火"
            })
            tg:settimedata("杨间-第五层鬼域击杀", 0.05)
          end
        end
      end)
      u:addstexiao("杨间-传奇", "杀敌效果", function(args)
        local tg = args.tg
        local count = u:getdata("杨间-鬼计数")
        local add = 0
        if tg:isboss() then
          add = 100 + count * 30
        elseif tg:iselite() then
          add = 10 + count * 3
        else
          add = 1 + count * 0.3
        end
        apply_yangjian_kill_reward(add, true, args.mon or args.tg)
      end)
      u:addstexiao("杨间-传奇", "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:getdata("杨间-鬼域层数") >= 6 and not u:hasdata("杨间-第六层鬼域暂停冷却") then
          u:settimedata("杨间-第六层鬼域暂停冷却", 6)
          tg:buffset(u.handle, 1, "暂停")
        end
        if u:getluckrandom(10 * info.txgl) and not u:hasdata("杨间-传奇" .. "-特效冷却") then
          u:settimedata("杨间-传奇" .. "-特效冷却", 0.5)
          local txsh = 10000 * u:getdata("杨间-鬼计数") + 25 * u:getdata("杨间-灵异计数")
          DamageUnit({
            bj = "杨间传奇",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "灵力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "火"
          })
        end
        if u:getluckrandom(10 * info.txgl) and not u:hasdata("杨间-传奇" .. "-特效2冷却") then
          u:settimedata("杨间-传奇" .. "-特效2冷却", 0.5)
          local txsh = 10000 * u:getdata("杨间-鬼计数") + 0.04 * u:getdata("杨间-鬼计数") * u:gethp()
          DamageUnit({
            bj = "杨间传奇",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "灵力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "暗"
          })
        end
      end)
      u:addstexiao(var.name, "位移技能后效果", function(args)
        if not u:hasdata("杨间-瞬移") and not u:hasdata("杨间-瞬移冷却") then
          u:settimedata("杨间-瞬移", 0.8)
        end
      end)
      local g = CreateGroupLua()
      u:addtrgevent("单位-指定点目标指令", function(args)
        if args.orderid == String2OrderIdBJ("smart") and u:hasdata("杨间-瞬移") then
          u:deldata("杨间-瞬移")
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          if 800 <= dis then
            dis = 800
          end
          x2, y2 = PolarXY(x, y, dis, angle)
          Effectcreate("ATX\\[ATxNew]Black_01.mdl", x, y)
          Effectcreate("ATX\\[ATxNew]Black_01.mdl", x2, y2)
          u:setxy(x2, y2)
          if u:getdata("杨间-鬼域层数") >= 6 then
            u:buffset(u.handle, 0.15, "绝对闪避")
          end
        end
      end)
    end,
    effectname = "|cFF666666鬼|r|cFF705C5C眼|r|cFF7A5252杨|r|cFF854747间|r",
    effecttext = "|cFF999999我|r|cFF9B9494叫|r|cFF9D8E8E杨|r|cFF9E8989间|r|cFFA08484，|r\n|cFFA27F7F当|r|cFFA47979你|r|cFFA57474看|r|cFFA76F6F到|r|cFFA96A6A这|r|cFFAB6464句|r|cFFAC5F5F话|r|cFFAE5A5A的|r|cFFB05454时|r|cFFB24F4F候|r|cFFB34A4A我|r|cFFB54545已|r|cFFB73F3F经|r|cFFB93A3A死|r|cFFBA3535了|r|cFFBC2F2F.|r|cFFBE2A2A.|r|cFFC02525.|r|cFFC12020.|r|cFFC31A1A.|r|cFFC51515.|r\n\n|cFF999999一|r|cFF999797张|r|cFF999696灵|r|cFF999494异|r|cFF999393的|r|cFF999191纸|r\n|cFF998E8E一|r|cFF998C8C只|r|cFF998B8B窥|r|cFF998989视|r|cFF998787黑|r|cFF998686暗|r|cFF998484的|r|cFF998383眼|r|cFF998181睛|r\n|cFF997E7E这|r|cFF997C7C是|r|cFF997B7B一|r|cFF997979个|r|cFF997878活|r|cFF997676下|r|cFF997474来|r|cFF997373的|r|cFF997171人|r|cFF997070经|r|cFF996E6E历|r|cFF996C6C的|r|cFF996B6B故|r|cFF996969事|r",
    effectart = "Cq_Yangjian_Chuanqi",
    test = [[

    ]]
  },
  {
    name = "老男人",
    weight = 5,
    key = {
      "唯一",
      "魔导",
      "元素"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-老男人") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      Weiyi_New[20] = true
      u:playseensound(Sound_Lnr_Cqhq)
      u:chat("|cFFFFCC00嗨|r|cFFFF9900~|r")
      ac.wait(1500, function()
        u:chat("|cFFFFCC00我|r|cFFFFC500是|r|cFFFFBD00天|r|cFFFFB600才|r|cFFFFAF00美|r|cFFFFA800少|r|cFFFFA000女|r|cFFFF9900炼|r|cFFFF9200金|r|cFFFF8A00术|r|cFFFF8300士|r|cFFFF7C00—|r|cFFFF7500—|r|cFFFF6D00卡|r|cFFFF6600莉|r|cFFFF5F00奥|r|cFFFF5700斯|r|cFFFF5000特|r|cFFFF4900萝|r|cFFFF4200☆|r")
      end)
      ac.wait(5700, function()
        u:chat("|cFFFFCC00千|r|cFFFFC200万|r|cFFFFB900不|r|cFFFFAF00要|r|cFFFFA600被|r|cFFFF9C00本|r|cFFFF9300大|r|cFFFF8900爷|r|cFFFF8000的|r|cFFFF7600可|r|cFFFF6C00爱|r|cFFFF6300迷|r|cFFFF5900倒|r|cFFFF5000哦|r")
      end)
      ac.wait(8000, function()
        PlayBGM({
          bgm = BGM_Lnr_Cq,
          time = 220,
          ID = 212,
          unit = u.handle
        })
      end)
      ModelReplace({
        u = u,
        model = "Shio_Cagliostro_New.mdl",
        modelsize = 1.7,
        modelname = "|cFFFFCC00卡|r|cFFFFC524莉|r|cFFFFBD49奥|r|cFFFFB66D斯|r|cFFFFAF92特|r|cFFFFA8B6萝|r",
        modelicon = "Portrait_Laonanren.tga"
      })
      u:setdata("老男人-备用躯体", 1)
      ChangeValue(Correction_MEDCgl, sy, 0.2)
      ChangeValue(Correction_Exp, sy, 0.2)
      local cs = 0
      ac.loop(1000, function()
        cs = cs + 1
        if cs == 30 or cs == 60 then
          u:playseensound(Sound_Lnr_GH)
          local cure = 50 * u:getallattri()
          ForGroupLuaNew(Group_PlayHero, function(xq)
            local dis = DistanceBetweenUnits(xq.handle, u.handle)
            if dis <= 1800 then
              u:curehp(u.handle, cure, 0, 2)
            end
          end)
          local x, y = u:getxy()
          local txsh = 5000 + 3 * u:getlevel() * u:getint()
          Effectcreate("mfz_aflez.mdx", x, y, 10, 0.8)
          local cs = 0
          local dcs = 0
          ac.loop(200, function(timer)
            cs = cs + 1
            local g = CreateGroupLua()
            for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g)
            end
            ForGroupLuaNew(g, function(xq)
              xq:buffset(u.handle, 0.7, "僵直")
              DamageUnit({
                bj = "老男人附伤",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "魔力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "暗",
                extradata = {""}
              })
              xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
            end)
            if cs == 50 then
              timer:remove()
            end
          end)
        end
        if cs == 60 then
          cs = 0
          local add = Ewaishu[sy]
          u:addrandomstats(add)
          u:sendmessage("|cFFFFCC00提升属性" .. add .. "|r")
        end
      end)
      
      local function chattrg(args)
        if args.chat == "-mx" and u:isalive() then
          u:setdata("模型-变化", "Shio_Cagliostro_New.mdl")
          u:setdata("模型-大小", 1.7)
          u:setdata("模型-名字", "|cFFFFCC00卡|r|cFFFFC524莉|r|cFFFFBD49奥|r|cFFFFB66D斯|r|cFFFFAF92特|r|cFFFFA8B6萝|r")
          u:setdata("模型-大头像", "Portrait_Laonanren.tga")
          u:setdata("单位-大头像", u:getdata("模型-大头像"))
          japi.SetUnitModel(u.handle, u:getdata("模型-变化"))
          u:setsize(u:getdata("模型-大小"))
          japi.SetUnitName(u.handle, u:getdata("模型-名字"))
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chattrg(args)
      end)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:setdata("老男人-根源之术", u)
      end)
      u:deldata("老男人-根源之术")
      local mj = u:createunit("o00F", -28000, 2000)
      mj:animeact(4)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        u:changemaxhp(Time_M * 10)
        ChangeValue(Correction_MHp, sy, 0.001)
        u:changedata("老男人-黄金像计数", 1)
        if u:getdata("老男人-黄金像计数") == 5 then
          u:setdata("老男人-黄金像计数", 0)
          local x, y = u:getxy()
          mj:setxy(x, y)
          mj:setface(GetRandomReal(225, 315))
        end
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        ChangeValue(Damage_Element_All, sy, 8.0E-4)
        ChangeValue(Correction_Gun, sy, 8.0E-5)
        if tg:isboss() and not u:hasdata("老男人-雕像触发冷却") then
          u:settimedata("老男人-雕像触发冷却", 1)
          PlayGlobalSound(Sound_Lnr_KillBOSS)
          local x, y = tg:getxy()
          local mj = u:createunit("o00F", x, y, GetRandomAngle())
          mj:animeact(GetRandomInt(2, 3))
        end
      end)
      u:addstexiao(var.name, "受伤后效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if args.damage > 10 and u:getluckrandom(5) and not u:hasdata("老男人-回血冷却") then
          u:playseensound(Sound_Lnr_LB)
          u:settimedata("老男人-回血冷却", 15)
          u:curehp(u.handle, 0, 100, 2)
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        tg:setdata("破坏-伤害免疫")
        if not u:hasdata("老男人-控制冷却") and u:getluckrandom(25 * info.txgl) then
          u:settimedata("老男人-控制冷却", 0.5)
          local time = 1
          if tg:isboss() then
            time = 0.1
          end
          tg:buffset(u.handle, time, "僵直")
          tg:buffset(u.handle, time, "眩晕")
        end
        if not u:hasdata("老男人-斩杀冷却") and 1 >= tg:getperhp() then
          u:settimedata("老男人-斩杀冷却", 1)
          tg:zsdamage(u.handle)
        end
        if not u:hasdata("老男人-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata("老男人-特效冷却", 1)
          local x2, y2 = tg:getxy()
          Effectcreate("Lnr_Tx_Ls1.mdx", x2, y2)
          Effectcreate("Lnr_Tx_Ls2.mdx", x2, y2)
          local txsh = 3000 + 100 * u:getallattri()
          for _, xq in ac.selector():in_rangexy(x2, y2, 300):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "老男人附伤",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "土"
            })
          end
        end
      end)
      flashphoto({
        photo = "Ph_Lnr.tga",
        timeout = 2,
        timehold = 2,
        timein = 1
      })
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:buffset(u.handle, 5, "绝对闪避")
      end)
      u:setdata("老男人装甲护盾值", 0)
      u:setdata("老男人装甲再生时间", 0)
      ac.loop(250, function()
        if u:getdata("老男人装甲护盾值") <= 0 then
          if 0 >= u:getdata("老男人装甲再生时间") then
            u:setdata("老男人装甲再生时间", 0)
            local hd = 0.3 * u:getmaxhp()
            u:changedata("老男人装甲护盾值", hd)
            Hdzflash(u)
          else
            u:changedata("老男人装甲再生时间", -0.25)
          end
        end
      end)
      ac.wait(100, function()
        local ntext = "|cFFFFCC00卡|r|cFFFFC524莉|r|cFFFFBD49奥|r|cFFFFB66D斯|r|cFFFFAF92特|r|cFFFFA8B6萝|r\n\n|cFFFFCC00在|r|cFFFFCA0A这|r|cFFFFC814里|r|cFFFFC61F的|r|cFFFFC429是|r|cFFFFC233—|r|cFFFFC03D—|r|cFFFFBE47天|r|cFFFFBC52才|r|cFFFFBA5C美|r|cFFFFB866少|r|cFFFFB670女|r|cFFFFB47A炼|r|cFFFFB185金|r|cFFFFAF8F术|r|cFFFFAD99士|r|cFFFFABA3-|r|cFFFFA9AD卡|r|cFFFFA7B8莉|r|cFFFFA5C2奥|r|cFFFFA3CC斯|r|cFFFFA1D6特|r|cFFFF9FE0萝|r|cFFFF9DEB！|r"
        u:uivar_change({
          keyname = "老男人",
          keytype = "传奇栏",
          text = ntext,
          icon = "Lnr_04.tga",
          ishasphoto = true,
          jbtext = function()
            UIYNameCount = 2
            UIYName[1] = {
              method = 1,
              name = "卡莉奥斯特萝",
              colors = {
                "FFCC00",
                "FF99FF",
                "FF99FF",
                "FFCC00"
              },
              length = 5,
              lengthcd = 15,
              math = 1,
              offsetspeed = 0.5,
              extratext = [[


]]
            }
            UIYName[2] = {
              method = 1,
              name = "在这里的是——天才美少女炼金术士-卡莉奥斯特萝！",
              colors = {
                "FFCC00",
                "FF99FF",
                "FF99FF",
                "FFCC00"
              },
              length = 5,
              lengthcd = 20,
              math = 1,
              offsetspeed = 0.2
            }
          end
        })
      end)
    end,
    effectname = "|cFFFFCC00卡|r|cFFFFC524莉|r|cFFFFBD49奥|r|cFFFFB66D斯|r|cFFFFAF92特|r|cFFFFA8B6萝|r",
    effecttext = "|cFFFFCC00在|r|cFFFFCA0A这|r|cFFFFC814里|r|cFFFFC61F的|r|cFFFFC429是|r|cFFFFC233—|r|cFFFFC03D—|r|cFFFFBE47天|r|cFFFFBC52才|r|cFFFFBA5C美|r|cFFFFB866少|r|cFFFFB670女|r|cFFFFB47A炼|r|cFFFFB185金|r|cFFFFAF8F术|r|cFFFFAD99士|r|cFFFFABA3-|r|cFFFFA9AD卡|r|cFFFFA7B8莉|r|cFFFFA5C2奥|r|cFFFFA3CC斯|r|cFFFFA1D6特|r|cFFFF9FE0萝|r|cFFFF9DEB！|r",
    effectart = "Lnr_04.tga",
    test = [[

    ]]
  },
  {
    name = "愚者传奇",
    weight = 5,
    key = {"唯一"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-愚者") and u:hasdata("变异判定-愚者初始") then
        b = true
      end
      if not u:hasdata("系统-特殊获取中") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      NameID[sy] = "|cFF0066CC克|r|cFF0D73D2莱|r|cFF1A80D9恩|r|cFF268CDF.|r|cFF3399E6莫|r|cFF40A6EC雷|r|cFF4CB2F2蒂|r"
      u:setplayername(NameID[sy])
      Boolean_ColorName[sy] = true
      ColorName[sy][1] = {
        method = 1,
        name = "如果你我从不孤独，又怎会踏上渐行渐远的道路",
        colors = {
          "6699FF",
          "3366FF",
          "9966FF",
          "FF0000",
          "9966FF",
          "3366FF",
          "6699FF"
        },
        length = 10,
        lengthcd = 150,
        math = 1,
        offsetspeed = 0.5
      }
      transition_phrases({
        name = {
          "克莱恩.莫雷蒂",
          "夏洛克.莫里亚蒂",
          "格尔曼.斯帕罗",
          "道恩.唐泰斯",
          "梅林.赫尔墨斯"
        },
        sy = sy,
        delay = 10,
        pause_time = 3000
      })
      SendMsgAll("|cFF990000「|r|cFF960707所|r|cFF920E0E有|r|cFF8F1414人|r|cFF8B1B1B都|r|cFF882222会|r|cFF852929死|r|cFF813030，|r|cFF7E3636包|r|cFF7A3D3D括|r|cFF774444我|r|cFF744B4B…|r|cFF705252…|r|cFF6D5858」|r")
      PlayGlobalSound(Sound_Yuzhe_Chuanqi)
      u:setdata("愚者-序列阶级", 0)
      ChangeValue(Hero_Shenhua_Left, sy, -1)
      u:additem("I0L6")
      u:setdata("愚者-计算系数", 0)
      u:setdata("愚者-诡秘计数", 0)
      u:setdata("愚者-宿命计数", 0)
      u:setdata("愚者-外神计算系数", 0)
      ac.loop(3000, function()
        u:setdata("愚者-计算系数", u:getstate("外域变异") + u:getdata("愚者-诡秘计数"))
        if u:getdata("外神变异数量") == 0 then
          u:setdata("愚者-外神计算系数", 1)
        else
          u:setdata("愚者-外神计算系数", u:getdata("外神变异数量"))
        end
      end)
      u:uivar_add({
        keyname = "源堡",
        keytype = "血统栏",
        text = "|cFF6699FF源|r|cFF6688DD堡|r\n|cFF9999CC占|r|cFF9494C7卜|r|cFF9090C3家|r|cFF8B8BBE无|r|cFF8686B9法|r|cFF8282B5预|r|cFF7D7DB0知|r|cFF7979AC未|r|cFF7474A7来|r|cFF6F6FA2，|r|cFF9999CC小|r|cFF9494C7丑|r|cFF8F8FC2做|r|cFF8A8ABD不|r|cFF8585B8到|r|cFF8080B3笑|r|cFF7A7AAD对|r|cFF7575A8生|r|cFF7070A3活|r\n|cFF9999CC魔|r|cFF9595C8术|r|cFF9090C4师|r|cFF8C8CBF始|r|cFF8888BB终|r|cFF8484B7被|r|cFF8080B2蒙|r|cFF7B7BAE在|r|cFF7777AA鼓|r|cFF7373A6里|r|cFF6E6EA2，|r|cFF9999CC无|r|cFF9494C7面|r|cFF9090C3人|r|cFF8B8BBE却|r|cFF8686B9没|r|cFF8282B5能|r|cFF7D7DB0决|r|cFF7979AC弃|r|cFF7474A7感|r|cFF6F6FA2情|r\n|cFF9999CC秘|r|cFF9696C9偶|r|cFF9292C5大|r|cFF8F8FC2师|r|cFF8B8BBE只|r|cFF8888BB是|r|cFF8585B8作|r|cFF8181B4家|r|cFF7E7EB1手|r|cFF7A7AAD中|r|cFF7777AA的|r|cFF7474A7木|r|cFF7070A3偶|r|cFF6D6DA0，|r|cFF9999CC诡|r|cFF9595C8法|r|cFF9090C4师|r|cFF8C8CBF唯|r|cFF8888BB留|r|cFF8484B7下|r|cFF8080B2善|r|cFF7B7BAE良|r|cFF7777AA的|r|cFF7373A6传|r|cFF6E6EA2说|r\n|cFF9999CC历|r|cFF9696C9史|r|cFF9292C5学|r|cFF8F8FC2家|r|cFF8B8BBE只|r|cFF8888BB找|r|cFF8585B8到|r|cFF8181B4最|r|cFF7E7EB1惨|r|cFF7A7AAD痛|r|cFF7777AA的|r|cFF7474A7历|r|cFF7070A3史|r|cFF6D6DA0，|r|cFF9999CC奇|r|cFF9696C9迹|r|cFF9393C6师|r|cFF8F8FC2也|r|cFF8C8CBF做|r|cFF8989BC不|r|cFF8686B9到|r|cFF8383B6创|r|cFF8080B2造|r|cFF7C7CAF奇|r|cFF7979AC迹|r|cFF7676A9挽|r|cFF7373A6回|r|cFF7070A3过|r|cFF6C6C9F去|r\n|cFF9494C7满|r|cFF8F8FC2怀|r|cFF8A8ABD悲|r|cFF8585B8苦|r|cFF8080B3的|r|cFF7A7AAD前|r|cFF7575A8行|r|cFF7070A3，|r|cFF9999CC道|r|cFF9696C9路|r|cFF9494C7的|r|cFF9191C4终|r|cFF8F8FC2点|r|cFF8C8CBF却|r|cFF8A8ABD是|r|cFF8787BA饱|r|cFF8585B8含|r|cFF8282B5希|r|cFF7F7FB2望|r|cFF7D7DB0的|r|cFF7A7AAD首|r|cFF7878AB牌|r|cFF999999「|r|cFF7A85A3愚|r|cFF5C70AD者|r|cFF3D5CB8」|r|cFF6B6B9E。|r\n\n|cFF9999CC愿|r|cFF9494C7你|r|cFF9090C3如|r|cFF8B8BBE愿|r|cFF8686B9，|r|cFF8282B5愿|r|cFF7D7DB0你|r|cFF7979AC还|r|cFF7474A7乡|r|cFF6F6FA2。|r",
        icon = "Ewl_Yuzhe_03.tga"
      })
      u:setdata("变异判定-源堡")
      u:changedata("外域变异数量", 1)
      u:changedata("人" .. "血统补正浓度", 100)
      u:changedata("月" .. "血统补正浓度", 0)
      u:changedata("总血统补正浓度", 100)
      do
        local function getPotionSuccessBonus()
          local now = GetTimeOfDay()
          
          if 0.5 <= now and now < 6.0 then
            return 0.05
          elseif 6.0 <= now and now < 18.0 then
            return 0.1
          elseif 18.0 <= now and now < 22.0 then
            return 0.15
          elseif 22.0 <= now and now < 24.0 then
            return 0.25
          else
            return 0.0
          end
        end
        
        local gl = 0
        local bonus = 0
        ac.loop(3000, function()
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * -gl)
          gl = 0.2 * u:getbloodcd("月")
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * gl)
          ChangeValue(Correction_MEDCgl, sy, -bonus)
          bonus = getPotionSuccessBonus()
          ChangeValue(Correction_MEDCgl, sy, bonus)
        end)
        ChangeValue(DamageSystem_Ssjianshao, sy, 0.7, 1)
        u:addstexiao(var.name, "直接伤害特效", function(args)
          local tg = args.tg
          local u = args.u
          local info = args.damageinfo
          if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(20 * info.txgl) then
            u:settimedata(var.name .. "-特效冷却", 1)
            local txsh = 6666 * u:getlevel()
            DamageUnit({
              bj = "愚者附伤",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "暗"
            })
          end
        end)
        u:changedata("幸运", 1)
      end
      local jinjiezu
      do
        local ntext = "|cFF0066CC克|r|cFF0D73D2莱|r|cFF1A80D9恩|r|cFF268CDF.|r|cFF3399E6莫|r|cFF40A6EC雷|r|cFF4CB2F2蒂|r\n\n|cff990000「|r|cff990b0b所|r|cff991616有|r|cff992121人|r|cff992c2c都|r|cff993737会|r|cff994242死|r|cff994c4c，|r|cff995757也|r|cff996262包|r|cff996d6d括|r|cff997878我|r|cff998383」|r\n\n|cFFCC6600「|r|cFFCA680A也|r|cFFC86A14许|r|cFFC66C1F，|r|cFFC46E29我|r|cFFC27033从|r|cFFC0723D未|r|cFFBE7447离|r|cFFBC7652开|r|cFFBA785C过|r|cFFB87A66故|r|cFFB67C70乡|r|cFFB47E7A，|r|cFFB18185却|r|cFFAF838F永|r|cFFAD8599远|r|cFFAB87A3也|r|cFFA989AD不|r|cFFA78BB8可|r|cFFA58DC2能|r|cFFA38FCC回|r|cFFA191D6家|r|cFF9F93E0了|r|cFF9D95EB」|r"
        
        local function reset()
          UIYNameCount = 4
          UIYName[1] = {
            method = 1,
            name = "克莱恩.莫雷蒂",
            colors = {
              "0066CC",
              "4CB2F2",
              "4CB2F2",
              "0066CC"
            },
            length = 5,
            lengthcd = 15,
            math = 1,
            offsetspeed = 0.25
          }
          UIYName[3] = {
            method = 1,
            name = "「所有人都会死，也包括我」",
            colors = {
              "990000",
              "949596",
              "949596",
              "990000"
            },
            length = 5,
            lengthcd = 20,
            math = 1,
            offsetspeed = 0.1,
            extratext = [[


]]
          }
          UIYName[4] = {
            method = 1,
            name = "「也许，我从未离开过故乡，却永远也不可能回家了」",
            colors = {
              "FF9933",
              "9999FF",
              "9999FF",
              "FF9933"
            },
            length = 5,
            lengthcd = 40,
            math = 1,
            offsetspeed = 0.2,
            extratext = [[


]]
          }
        end
        
        ac.wait(100, function()
          u:uivar_change({
            keyname = "愚者传奇",
            keytype = "传奇栏",
            text = ntext,
            icon = "Ewl_Yuzhe_04.tga",
            ishasphoto = true,
            jbtext = function()
              reset()
              UIYName[1].extratext = ""
              UIYName[2] = {
                method = 1,
                name = "",
                colors = {},
                length = 5,
                lengthcd = 15,
                math = 1,
                offsetspeed = 0.25,
                extratext = [[


]]
              }
            end
          })
        end)
        
        local function shengjie()
          u:changedata("人" .. "血统补正浓度", -10)
          u:changedata("月" .. "血统补正浓度", 10)
          u:changedata("愚者-诡秘计数", 1)
          u:changedata("愚者-序列阶级", 1)
        end
        
        jinjiezu = {
          ["占卜师"] = function()
            flashphoto({
              photo = "Ph_Kle_01.tga",
              timeout = 4,
              timehold = 4,
              timein = 2
            })
            ForGroupLuaNew(Group_PlayHero, function(xq)
              xq:buffset(u.handle, 10, "绝对闪避")
            end)
            PlayGlobalSound(Sound_Yuzhe_Zhanbujia)
            SendDtimeMsgAll(0, "|cFF9999CC「 从现在开始，我就是|cFF3366FF克|r|cFF3D66E0莱|r|cFF4766C2恩|r|cFF5266A3了|r  |cFF9999CC」|r", 10)
            SendDtimeMsgAll(5, "|cFFFFCC99「|r|cFFFAC794 |r|cFFF6C390我|r|cFFF1BE8B们|r|cFFECB986是|r|cFFE8B582守|r|cFFE3B07D护|r|cFFDFAC79者|r|cFFDAA774 |r|cFFD5A26F」|r", 10)
            SendDtimeMsgAll(7.8, "|cFF999999「|r|cFF999393 |r|cFF998D8D—|r|cFF998787—|r|cFF998181也|r|cFF997A7A是|r|cFF997474一|r|cFF996E6E群|r|cFF996868时|r|cFF996262刻|r|cFF995C5C对|r|cFF995656抗|r|cFF995050着|r|cFF994949危|r|cFF994343险|r|cFF993D3D和|r|cFF993737疯|r|cFF993131狂|r|cFF992B2B的|r|cFF992525可|r|cFF991F1F怜|r|cFF991818虫|r|cFF991212 |r|cFF990C0C」|r", 10)
            u:setdata("愚者-占卜师")
            ac.wait(10000, function()
              PlayBGM({
                bgm = BGM_Yuzhe_Cq,
                time = 210,
                ID = 206,
                unit = u.handle
              })
              songtext({
                text = {
                  {
                    starttime = 9.8,
                    str = "当我双眼觉醒"
                  },
                  {
                    starttime = 12.8,
                    str = "天穹初显曙光"
                  },
                  {
                    starttime = 16.7,
                    str = "风暴汹涌来袭"
                  },
                  {
                    starttime = 20.1,
                    str = "时钟止住震响"
                  },
                  {
                    starttime = 23.9,
                    str = "漂泊无依，被遗弃"
                  },
                  {
                    starttime = 27.2,
                    str = "我将缔造梦境"
                  },
                  {
                    starttime = 31.1,
                    str = "烈焰铸就新生"
                  },
                  {
                    starttime = 34.2,
                    str = "命运由我亲手掌控"
                  },
                  {
                    starttime = 41,
                    str = "回响震彻四方"
                  },
                  {
                    starttime = 44.1,
                    str = "繁星无法挽狂"
                  },
                  {
                    starttime = 47.3,
                    str = "我们能否曲弄浪潮"
                  },
                  {
                    starttime = 51.2,
                    str = "虚空拓展我所见之界"
                  },
                  {
                    starttime = 54.8,
                    str = "猩红淹没月之诏令"
                  },
                  {
                    starttime = 58,
                    str = "光波穿透时光残骸"
                  },
                  {
                    starttime = 61.8,
                    str = "流淌着我的故事"
                  },
                  {
                    starttime = 65.1,
                    str = "何处有双手，写下我宿命的诗行？"
                  },
                  {
                    starttime = 69,
                    str = "何处有锁链，锁住我荣耀的锋芒？"
                  },
                  {
                    starttime = 72,
                    str = "何处有纹路，是我祈愿难违的命章？"
                  },
                  {
                    starttime = 75,
                    str = "谁能看透这灵魂的迷障？"
                  },
                  {
                    starttime = 79,
                    str = "何处有烈焰，在狂怒中灼穿昏茫？"
                  },
                  {
                    starttime = 82.1,
                    str = "何处有钥匙，从骨血里凿出真相？"
                  },
                  {
                    starttime = 86,
                    str = "堕入黑暗，且让梦与呐喊，在虚无中，刻下我未竟的名章。"
                  },
                  {
                    starttime = 91,
                    str = "惊叹抑或惶惑"
                  },
                  {
                    starttime = 95.1,
                    str = "癫狂还是腐朽"
                  },
                  {
                    starttime = 99.1,
                    str = "以微弱之光"
                  },
                  {
                    starttime = 101.4,
                    str = "我发誓守护我所留存的世界"
                  },
                  {
                    starttime = 105.1,
                    str = "搅动还是迟疑"
                  },
                  {
                    starttime = 109,
                    str = "重生抑或如故"
                  },
                  {
                    starttime = 112,
                    str = "暗灰低语"
                  },
                  {
                    starttime = 115,
                    str = "指引我阴影之路"
                  },
                  {
                    starttime = 118.2,
                    str = "渐行渐远",
                    time = 6
                  },
                  {
                    starttime = 134.1,
                    str = "焚毁破碎躯壳，铸就新视野"
                  },
                  {
                    starttime = 140,
                    str = "于迷雾中自由散步，手握光之杯盏"
                  },
                  {
                    starttime = 146.9,
                    str = "何处有烈焰，在狂怒中灼穿昏茫？"
                  },
                  {
                    starttime = 151.2,
                    str = "何处有钥匙，从骨血里凿出真相"
                  },
                  {
                    starttime = 155,
                    str = "堕入黑暗，且让梦与呐喊，在虚无中，刻下我未竟的名章。"
                  },
                  {
                    starttime = 160,
                    str = "惊叹抑或惶惑"
                  },
                  {
                    starttime = 164,
                    str = "癫狂还是腐朽"
                  },
                  {
                    starttime = 168,
                    str = "以微弱之光"
                  },
                  {
                    starttime = 170,
                    str = "我发誓守护我所留存的世界"
                  },
                  {
                    starttime = 174,
                    str = "搅动还是迟疑"
                  },
                  {
                    starttime = 177.1,
                    str = "重生抑或如故"
                  },
                  {
                    starttime = 181,
                    str = "暗灰低语"
                  },
                  {
                    starttime = 183.2,
                    str = "指引我阴影之路"
                  },
                  {
                    starttime = 186.9,
                    str = "渐行渐远",
                    time = 6
                  }
                },
                color = "FF5179FF"
              })
            end)
            u:effectadd("Tx_Yuzhe_O1.mdx", "origin", -1)
            u:effectadd("Tx_Yuzhe_O2.mdx", "origin", -1)
            u:effectadd("BTX\\[BTxNew]Halo0 (5).mdx", "origin", -1)
            u:effectadd("war3mapImported\\[ake]war3ake.com - 7346841038772226188179609.mdx", "origin", -1)
            shengjie()
            u:uivar_change({
              keyname = "愚者传奇",
              keytype = "传奇栏",
              jbtext = function()
                reset()
                UIYName[1].extratext = " - 「9」"
                UIYName[2] = {
                  method = 1,
                  name = "占卜师",
                  colors = {
                    "7DBEF1",
                    "949596",
                    "949596",
                    "7DBEF1"
                  },
                  length = 5,
                  lengthcd = 15,
                  math = 1,
                  offsetspeed = 0.25,
                  extratext = [[


]]
                }
              end
            })
            u:addskill("A151")
            local x, y = u:getxy()
            local by = u:createfogcorrector(x, y, 2600)
            local cs = 0
            ac.loop(1000, function(t)
              u:removefogcorrector(by)
              x, y = u:getxy()
              by = u:createfogcorrector(x, y, 2600)
              if not u:isalive() then
                u:closefogcorrector(by)
              end
            end)
            ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 66)
            ChangeValue(HeroMenu_ExtraMoveSpeed_Bfb, sy, 0.05)
            local jf = 0
            ac.loop(3000, function()
              ChangeValue(Correction_Gold, sy, -jf)
              jf = 0.0025 * u:getdata("愚者-计算系数")
              ChangeValue(Correction_Gold, sy, jf)
            end)
            ChangeValue(DamageSplit_CountMax, sy, 0.25)
            ChangeValue(DamageSplit_CountHit, sy, 2)
            local dskill = S2ID("A0IE")
            u:byladdskill(dskill, function(args)
              if args.skill == dskill then
                local b = true
                local ewl = getunit(args.unit)
                if not u:isalive() then
                  b = false
                  u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
                end
                if b then
                  local x, y = u:getxy()
                  local dis = 5000
                  local rect = Rect(x - dis, y - dis, x + dis, y + dis)
                  local cs = 0
                  EnumItemsInRectBJ(rect, function()
                    local wp = GetEnumItem()
                    local wptype = GetItemTypeId(wp)
                    local wplx = GetItemType(wp)
                    if GetItemLifeBJ(wp) > 0 and wptype == S2ID("I00X") and cs < 3 then
                      local ax = GetItemX(wp)
                      local ay = GetItemY(wp)
                      cs = cs + 1
                      if u:islocal() then
                        PingMinimapEx(ax, ay, 5, 102, 51, 255, false)
                      end
                    end
                  end)
                  RemoveRect(rect)
                  u:changedata("愚者-占卜使用次数", 1)
                  if u:getdata("愚者-占卜使用次数") == 4 then
                    jinjiezu["小丑"]()
                  end
                  u:changedata("愚者-占卜计数", 1)
                  if u:getdata("愚者-占卜计数") >= 3 then
                    u:setdata("愚者-占卜计数", 0)
                    u:addrandomstats(1)
                  end
                else
                  ewl:setskillcd(dskill, 1)
                end
              end
            end)
          end,
          ["小丑"] = function()
            ac.wait(15000, function()
              local dpools = {
                Vars_Ciyuan_Spe
              }
              u:setdata("系统-特殊获取中")
              local str = herogetvar(u.handle, dpools, "次元", "黑皇帝")
              u:deldata("系统-特殊获取中")
            end)
            PlayGlobalSound(Sound_Yuzhe_Xiaochou)
            SendDtimeMsgAll(0, "|cFF6666CC「|r|cFF6669CC |r|cFF666CCC欢|r|cFF666FCC迎|r|cFF6672CC归|r|cFF6675CC来|r|cFF6678CC |r|cFF667BCC |r|cFF667ECC我|r|cFF6681CC伟|r|cFF6684CC大|r|cFF6687CC的|r|cFF668ACC主|r|cFF668DCC人|r|cFF6690CC |r|cFF6693CC」|r", 10)
            SendDtimeMsgAll(3, "|cFF6666CC「|r|cFF6668CC |r|cFF666ACC您|r|cFF666BCC忠|r|cFF666DCC诚|r|cFF666FCC的|r|cFF6671CC仆|r|cFF6672CC人|r|cFF6674CC |r|cFF6676CC阿|r|cFF6678CC罗|r|cFF6679CC德|r|cFF667BCC斯|r|cFF667DCC见|r|cFF667FCC证|r|cFF6680CC您|r|cFF6682CC又|r|cFF6684CC拿|r|cFF6686CC回|r|cFF6687CC来|r|cFF6689CC了|r|cFF668BCC一|r|cFF668DCC部|r|cFF668ECC分|r|cFF6690CC权|r|cFF6692CC柄|r|cFF6694CC |r|cFF6695CC」|r", 10)
            SendDtimeMsgAll(8, "|cff6666cc「|r|cff6667cc 为|r|cff6668cc您|r|cff6669cc逐渐|r|cff666acc恢|r|cff666bcc复的|r|cff666ccc气|r|cff666dcc息感|r|cff666ecc到|r|cff666fcc颤栗|r\n|cff6683cc—|r|cff6684cc—您|r|cff6685cc终|r|cff6686cc将归|r|cff6687cc于|r|cff6688cc那至|r|cff6689cc高|r|cff668acc的位|r|cff668bcc置|r|cff668ccc，让|r|cff668dcc整|r|cff668ecc个世|r|cff668fcc界|r|cff6690cc在您|r|cff6691cc的|r|cff6692cc注视|r|cff6693cc下|r|cff6694cc变得|r|cff6695cc平|r|cff6696cc静 |r|cff6697cc」|r", 10)
            u:setdata("愚者-小丑")
            shengjie()
            u:uivar_change({
              keyname = "愚者传奇",
              keytype = "传奇栏",
              jbtext = function()
                reset()
                UIYName[1].extratext = " - 「8」"
                UIYName[2] = {
                  method = 1,
                  name = "小丑",
                  colors = {
                    "FF99FF",
                    "949596",
                    "949596",
                    "FF99FF"
                  },
                  length = 5,
                  lengthcd = 15,
                  math = 1,
                  offsetspeed = 0.25,
                  extratext = [[


]]
                }
              end
            })
            u:addstexiao(var.name .. "小丑", "杀敌效果", function(args)
              local tg = args.tg
              local add = 1.0E-5 * (u:getdata("外域变异数量") + u:getdata("愚者-诡秘计数"))
              ChangeValue(Damage_Element_Dark, sy, add)
              ChangeValue(Damage_Element_Light, sy, add)
              u:changedata("愚者-小丑杀敌", 1)
              if not u:hasdata("愚者-魔术师") and u:getdata("愚者-小丑杀敌") >= 300 then
                jinjiezu["魔术师"]()
              end
              if u:hasdata("愚者-魔术师") and GetRandom100(2) then
                u:addrandomstats(1)
              end
              if u:hasdata("愚者-无面人") then
                local addhp = u:getdata("愚者-计算系数") * 0.5
                u:changemaxhp(addhp)
              end
              if u:hasdata("愚者-奇迹师") then
                u:changedata("愚者-愿望之力", 1)
                if u:getdata("愚者-愿望之力") == 250 then
                  u:adddivinity(1)
                end
                if u:getdata("愚者-愿望之力") == 400 then
                  u:setdata("愚者-愿望之力暴击率")
                end
                if u:getdata("愚者-愿望之力") == 650 then
                  u:setdata("愚者-愿望之力暴击伤害")
                end
                if u:getdata("愚者-愿望之力") == 1000 then
                  u:setdata("愚者-愿望之力属性伤害")
                end
                if u:getdata("愚者-愿望之力") == 1500 then
                  u:adddivinity(1)
                  u:setdata("愚者-愿望之力效果翻倍")
                end
              end
              if u:hasdata("愚者-古代学者") then
                if GetRandom100(5) then
                  u:addrandomstats(1)
                end
                u:changemaxhp(GetRandomInt(1, 3))
              end
            end)
            u:setdata("系统-无视伤害免疫")
            u:addstexiao(var.name .. "2", "直接伤害特效", function(args)
              local tg = args.tg
              local u = args.u
              local info = args.damageinfo
              local x, y = u:getxy()
              local x2, y2 = tg:getxy()
              if not u:hasdata(var.name .. "-特效2冷却") then
                Effectcreate("Tx_Yuzhe_05.mdx", x2, y2, 0, 2, 90, GetRandomAngle(), GetRandomAngle(), GetRandomAngle())
                u:settimedata(var.name .. "-特效2冷却", 5)
                local dehp = 30
                if tg:isboss() then
                  dehp = 0.1
                end
                if tg:iselite() then
                  dehp = 5
                end
                if u:hasdata("愚者-奇迹师") then
                  tg:changemaxhp(-dehp * 0.01 * tg:getmaxhp())
                elseif u:hasdata("愚者-无面人") then
                  LossHpUnit({
                    u = u,
                    tg = tg,
                    damage = 0,
                    perhp = 0,
                    maxhp = dehp,
                    bj = "[生命损耗]愚者"
                  })
                else
                  LossHpUnit({
                    u = u,
                    tg = tg,
                    damage = 0,
                    perhp = dehp,
                    maxhp = 0,
                    bj = "[生命损耗]愚者"
                  })
                end
              end
              if u:hasdata("愚者-无面人") then
                local xs = 0.25
                if not info.ismeleedamage then
                  xs = 0.125
                end
                local txsh = xs * info.yssh
                DamageUnit({
                  bj = "愚者无面人附伤",
                  unit = tg.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "魔力",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = "暗"
                })
              end
              if u:hasdata("愚者-秘偶大师") and not tg:hasdata(var.name .. "-秘偶大师特效冷却") then
                tg:settimedata(var.name .. "-秘偶大师特效冷却", 3)
                tg:buffset(u.handle, 0.3, "僵直")
              end
              if u:hasdata("愚者-诡法师") and not u:hasdata(var.name .. "-特效3冷却") and u:getluckrandom(20 * info.txgl) then
                u:settimedata(var.name .. "-特效3冷却", 1.5)
                local txsh = 6666 * u:getdata("愚者-序列阶级") + info.yssh
                local jd = AngleBetweenUnits(u.handle, tg.handle)
                Effectcreate("Tx_Yuzhe_Kqp.mdx", x2, y2, 0, 1, 50, jd)
                DamageUnit({
                  bj = "愚者诡法师附伤",
                  unit = tg.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "反物质",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = "光"
                })
              end
            end)
          end,
          ["魔术师"] = function()
            PlayGlobalSound(Sound_Yuzhe_Moshushi)
            SendDtimeMsgAll(0, "|cFF999999「|r|cFF9B9997 |r|cFF9E9994一|r|cFFA09992年|r|cFFA3998F有|r|cFFA5998D1|r|cFFA8998A2|r|cFFAA9988个|r|cFFAC9986月|r|cFFAF9983、|r|cFFB199813|r|cFFB4997E6|r|cFFB6997C5|r|cFFB99979天|r|cFFBB9977、|r|cFFBD9975有|r|cFFC09972闰|r|cFFC29970年|r|cFFC5996D |r|cFFC7996B」|r", 10)
            SendDtimeMsgAll(3.8, "|cFF999999「|r|cFF9B9997 |r|cFF9D9995每|r|cFF9F9993天|r|cFFA199912|r|cFFA299904|r|cFFA4998E个|r|cFFA6998C小|r|cFFA8998A时|r|cFFAA9988、|r|cFFAC9986每|r|cFFAE9984小|r|cFFB09982时|r|cFFB299806|r|cFFB3997F0|r|cFFB5997D分|r|cFFB7997B钟|r|cFFB99979、|r|cFFBB9977每|r|cFFBD9975分|r|cFFBF9973钟|r|cFFC199716|r|cFFC3996F0|r|cFFC4996E秒|r|cFFC6996C |r|cFFC8996A」|r", 10)
            SendDtimeMsgAll(8.7, "|cFF6699FF「|r|cFF7099F0 |r|cFF7A99E0证|r|cFF8599D1实|r|cFF8F99C2是|r|cFF9999B2星|r|cFFA399A3球|r|cFFAD9994 |r|cFFB89985」|r", 10)
            SendDtimeMsgAll(10, "|cFFCC6633「|r|cFFCC6A3A |r|cFFCC6F40天|r|cFFCC7347空|r|cFFCC784E中|r|cFFCC7C54有|r|cFFCC815B且|r|cFFCC8562只|r|cFFCC8968有|r|cFFCC8E6F一|r|cFFCC9276个|r|cFFCC977C太|r|cFFCC9B83阳|r|cFFCCA089和|r|cFFCCA490一|r|cFFCCA997个|r|cFFCCAD9D月|r|cFFCCB1A4亮|r|cFFCCB6AB…|r|cFFCCBAB1…|r|cFFCCBFB8 |r|cFFCCC3BF」|r", 10)
            u:setdata("愚者-魔术师")
            shengjie()
            ChangeValue(Damage_ElementRes_All, sy, 20)
            u:uivar_change({
              keyname = "愚者传奇",
              keytype = "传奇栏",
              jbtext = function()
                reset()
                UIYName[1].extratext = " - 「7」"
                UIYName[2] = {
                  method = 1,
                  name = "魔术师",
                  colors = {
                    "3054A8",
                    "949596",
                    "949596",
                    "3054A8"
                  },
                  length = 5,
                  lengthcd = 15,
                  math = 1,
                  offsetspeed = 0.25,
                  extratext = [[


]]
                }
              end
            })
            u:addstexiao(var.name, "决死效果", function(args)
              if args.dt and not u:hasdata("愚者魔术师-决死冷却") then
                args.dt = false
                u:settimedata("愚者魔术师-决死冷却", 520)
                u:buffset(u.handle, 1, "无敌")
                u:sendmessage("|cFF3054A8魔术师-纸人替身|r")
              end
            end)
            u:setdata("愚者魔术师-火焰跳跃")
            u:addstexiao(var.name, "位移技能后效果", function(args)
              if u:hasdata("愚者魔术师-火焰跳跃") and not u:hasdata("火焰跳跃") then
                u:settimedata("火焰跳跃", 0.5)
              end
            end)
            u:addtrgevent("单位-指定点目标指令", function(args)
              if args.orderid == String2OrderIdBJ("smart") and u:hasdata("火焰跳跃") then
                u:deldata("火焰跳跃")
                local x, y = u:getxy()
                local x2 = args.x
                local y2 = args.y
                local angle = AngleXY(x, y, x2, y2)
                local dis = DistanceXY(x, y, x2, y2)
                local mjl = 450
                if dis >= mjl then
                  dis = mjl
                end
                x2, y2 = PolarXY(x, y, mjl, angle)
                Effectcreate("ATX\\[ATxNew]Black_01.mdl", x, y)
                Effectcreate("ATX\\[ATxNew]Black_01.mdl", x2, y2)
                u:setxy(x2, y2)
                ChangeValue(Hero_Tili, sy, -0.5)
                if u:hasdata("愚者-诡秘侍者") then
                  u:buffset(u.handle, 0.15, "绝对闪避")
                end
              end
            end)
            u:setdata("愚者-魔术师使用药水计数", 0)
            ac.loop(1000, function(timer)
              if u:getdata("愚者-魔术师使用药水计数") >= 6 then
                jinjiezu["无面人"]()
                timer:remove()
              end
            end)
          end,
          ["无面人"] = function()
            flashphoto({
              photo = "Ph_Kle_05.tga",
              timeout = 4,
              timehold = 1,
              timein = 2
            })
            ForGroupLuaNew(Group_PlayHero, function(xq)
              xq:buffset(u.handle, 7, "绝对闪避")
            end)
            PlayGlobalSound(Sound_Yuzhe_Wumianren)
            SendDtimeMsgAll(0, "|cFFCC9966「|r|cFFCC9C6C |r|cFFCC9F73每|r|cFFCCA379一|r|cFFCCA680段|r|cFFCCA986旅|r|cFFCCAC8C行|r|cFFCCAF93都|r|cFFCCB299有|r|cFFCCB69F终|r|cFFCCB9A6点|r|cFFCCBCAC…|r|cFFCCBFB2…|r|cFFCCC2B9 |r|cFFCCC6BF」|r", 10)
            u:setdata("愚者-无面人")
            shengjie()
            u:uivar_change({
              keyname = "愚者传奇",
              keytype = "传奇栏",
              jbtext = function()
                reset()
                UIYName[1].extratext = " - 「6」"
                UIYName[2] = {
                  method = 1,
                  name = "无面人",
                  colors = {
                    "BF8F00",
                    "949596",
                    "949596",
                    "BF8F00"
                  },
                  length = 5,
                  lengthcd = 15,
                  math = 1,
                  offsetspeed = 0.25,
                  extratext = [[


]]
                }
              end
            })
            local add = 0
            local js = 0
            local lw = 0
            local xy = 0
            local qsx = 0
            local gdxz = 0
            local gdxz2 = 0
            local cgl = 0
            local bjl = 0
            local bs = 0
            local sxsh = 0
            local hp = 0
            local tili = 0
            local cs = 0
            ac.loop(3000, function()
              local count = u:getdata("愚者-计算系数")
              ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
              ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
              ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
              ChangeValue(DamageSystem_Ssjianshao, sy, js, 1)
              ChangeValue(DamageSystem_Shjc, sy, 0.1 * -lw)
              ChangeValue(Correction_MEDCgl, sy, -cgl)
              ChangeValue(Damage_Element_Light, sy, -sxsh)
              ChangeValue(Damage_Element_Dark, sy, -sxsh)
              ChangeValue(HeroMenu_HpForever_MaxHp, sy, -hp)
              ChangeValue(Hero_Tili_Huifu, sy, -tili)
              u:changedata("幸运", -xy)
              u:changedata("全属性增幅", -qsx)
              if 1 >= Group_Counts(Group_Xingcunzu) then
                add = 0.25
                js = 0.85
              else
                add = 0
                js = 1
              end
              if u:hasdata("愚者-秘偶大师") then
                js = js - 0.1
                lw = 0.015 * count
                xy = 0.2 * count
              else
                xy = 0
                lw = 0
              end
              if u:hasdata("愚者-诡法师") then
                local now = GetTimeOfDay()
                if 6.0 <= now and now < 12.0 then
                  qsx = 0.08
                elseif 12.0 <= now and now < 18.0 then
                  qsx = 0.1
                else
                  qsx = 0.15
                end
              else
                qsx = 0
              end
              if u:hasdata("愚者-古代学者") then
                cgl = u:getdata("愚者-外神计算系数") * 0.0025 * count
              else
                cgl = 0
              end
              if u:hasdata("愚者-愿望之力暴击率") then
                bjl = 0.01 * count
                if u:hasdata("愚者-愿望之力效果翻倍") then
                  bjl = bjl * 2
                end
              else
                bjl = 0
              end
              if u:hasdata("愚者-愿望之力暴击伤害") then
                bs = 0.002 * count
                if u:hasdata("愚者-愿望之力效果翻倍") then
                  bs = bs * 2
                end
              else
                bs = 0
              end
              if u:hasdata("愚者-愿望之力属性伤害") then
                sxsh = 0.02 * count
                if u:hasdata("愚者-愿望之力属性伤害") then
                  sxsh = sxsh * 2
                end
              else
                sxsh = 0
              end
              if u:hasdata("愚者-诡秘侍者") then
                hp = 0.05 * count
                tili = 0.01 * count
              else
                hp = 0
                tili = 0
              end
              u:changedata("全属性增幅", qsx)
              u:changedata("幸运", xy)
              ChangeValue(DamageSystem_Ssjianshao, sy, js, 2)
              ChangeValue(Correction_MEDCgl, sy, cgl)
              ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
              ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
              ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
              ChangeValue(DamageSystem_Shjc, sy, 0.1 * lw)
              ChangeValue(Damage_Element_Light, sy, sxsh)
              ChangeValue(Damage_Element_Dark, sy, sxsh)
              ChangeValue(HeroMenu_HpForever_MaxHp, sy, hp)
              ChangeValue(Hero_Tili_Huifu, sy, tili)
              if u:hasdata("愚者-古代学者") then
                gdxz = gdxz + 1
                gdxz2 = gdxz2 + 1
                if 30 <= gdxz then
                  gdxz = 0
                  u:addallstats(10)
                end
                if 2 <= gdxz2 then
                  gdxz2 = 0
                  u:clearbuff()
                  u:clearbuff("眩晕")
                  u:clearbuff("僵直")
                  u:clearbuff("缠绕")
                end
              end
              cs = cs + 1
              local max = 180
              if Keyan_Weizhanshike then
                max = max * Weizhanxishu
              end
              if max <= cs then
                cs = 0
                if u:isalive() then
                  u:sethp(100, true)
                end
              end
            end)
            u:setdata("愚者-无面人使用药水计数", 0)
            ac.loop(1000, function(timer)
              if u:getdata("愚者-无面人使用药水计数") >= 8 then
                jinjiezu["秘偶大师"]()
                timer:remove()
              end
            end)
          end,
          ["秘偶大师"] = function()
            ac.wait(15000, function()
              local dpools = {
                Vars_Ciyuan_Spe
              }
              u:setdata("系统-特殊获取中")
              local str = herogetvar(u.handle, dpools, "次元", "黑夜女神")
              u:deldata("系统-特殊获取中")
            end)
            flashphoto({
              photo = "Ph_Kle_02.tga",
              timeout = 4,
              timehold = 4,
              timein = 2
            })
            ForGroupLuaNew(Group_PlayHero, function(xq)
              xq:buffset(u.handle, 10, "绝对闪避")
            end)
            PlayGlobalSound(Sound_Yuzhe_Mioudashi)
            SendDtimeMsgAll(0, "|cFF9999CC「|r|cFF9C9CCF |r|cFF9E9ED1就|r|cFFA1A1D4算|r|cFFA3A3D6没|r|cFFA6A6D9有|r|cFFA8A8DB意|r|cFFABABDE义|r|cFFADADE0 |r|cFFB0B0E3有|r|cFFB3B3E6些|r|cFFB5B5E8事|r|cFFB8B8EB还|r|cFFBABAED是|r|cFFBDBDF0得|r|cFFBFBFF2去|r|cFFC2C2F5做|r|cFFC4C4F7 |r|cFFC7C7FA」|r", 10)
            SendDtimeMsgAll(4.8, "|cFFCCCCFF「|r|cFFC9CAFE |r|cFFC6C9FC这|r|cFFC3C8FA个|r|cFFC0C6F9世|r|cFFBDC4F8界|r|cFFBAC3F6上|r|cFFB7C2F4，|r|cFFB4C0F3哪|r|cFFB1BEF2有|r|cFFAEBDF0那|r|cFFABBCEE么|r|cFFA8BAED多|r|cFFA5B8EC事|r|cFFA2B7EA情|r|cFF9FB6E8是|r|cFF9CB4E7一|r|cFF99B2E6定|r|cFF96B1E4成|r|cFF93B0E2功|r|cFF90AEE1 |r|cFF8DACE0一|r|cFF8AABDE定|r|cFF87AADC是|r|cFF84A8DB有|r|cFF81A6DA价|r|cFF7EA5D8值|r|cFF7BA4D6和|r|cFF78A2D5用|r|cFF75A0D4处|r|cFF729FD2的|r|cFF6F9ED0 |r|cFF6C9CCF」|r", 10)
            u:setdata("愚者-秘偶大师")
            shengjie()
            u:uivar_change({
              keyname = "愚者传奇",
              keytype = "传奇栏",
              jbtext = function()
                reset()
                UIYName[1].extratext = " - 「5」"
                UIYName[2] = {
                  method = 1,
                  name = "秘偶大师",
                  colors = {
                    "548235",
                    "949596",
                    "949596",
                    "548235"
                  },
                  length = 5,
                  lengthcd = 15,
                  math = 1,
                  offsetspeed = 0.25,
                  extratext = [[


]]
                }
              end
            })
            u:setdata("系统-无视伤害闪避")
            local count = 0
            ac.loop(1000, function(timer)
              if u:isalive() then
                count = count + 1
                if count == 240 then
                  jinjiezu["诡法师"]()
                  timer:remove()
                end
              end
            end)
          end,
          ["诡法师"] = function()
            PlayGlobalSound(Sound_Yuzhe_Guifashi)
            SendDtimeMsgAll(0, "|cFFCCCCFF「|r|cFFCACBFE |r|cFFC7CAFD今|r|cFFC5C8FB天|r|cFFC2C7FA之|r|cFFC0C6F9前|r|cFFBDC5F8，|r|cFFBBC3F6我|r|cFFB8C2F5也|r|cFFB6C1F4是|r|cFFB3C0F3像|r|cFFB1BEF1你|r|cFFAEBDF0这|r|cFFACBCEF么|r|cFFA9BBEE想|r|cFFA7B9EC的|r|cFFA4B8EB\n|r|cFF9FB6E9 |r|cFF9DB4E7 |r|cFF9AB3E6 |r|cFF98B2E5也|r|cFF95B1E4有|r|cFF93AFE2不|r|cFF90AEE1解|r|cFF8EADE0和|r|cFF8BACDF愤|r|cFF89AADD懑|r|cFF86A9DC |r|cFF84A8DB可|r|cFF81A7DA现|r|cFF7FA5D8在|r|cFF7CA4D7我|r|cFF7AA3D6有|r|cFF77A2D5点|r|cFF75A0D3迷|r|cFF729FD2茫|r|cFF709ED1了|r|cFF6D9DD0 |r|cFF6B9BCE」|r", 10)
            SendDtimeMsgAll(6.8, "|cFF3366CC「|r|cFF376ACC |r|cFF3A6DCC这|r|cFF3E71CC或|r|cFF4275CC许|r|cFF4578CC，|r|cFF497CCC是|r|cFF4C7FCC一|r|cFF5083CC种|r|cFF5487CC必|r|cFF578ACC须|r|cFF5B8ECC |r|cFF5F92CC」|r", 10)
            SendDtimeMsgAll(10.8, "|cFF999999「|r|cFF95999D |r|cFF9299A0但|r|cFF8E99A4这|r|cFF8A99A8不|r|cFF8799AB是|r|cFF8399AF荣|r|cFF8099B2耀|r|cFF7C99B6和|r|cFF7899BA力|r|cFF7599BD量|r|cFF7199C1 |r|cFF6D99C5」|r", 10)
            SendDtimeMsgAll(13, "|cFF999999「 而是|cFF996633痛|r|cFF936639苦|r|cFF8E663E、|r|cFF886644诅|r|cFF82664A咒|r|cFF7D664F和|r|cFF776655责|r|cFF71665B任|r|cFF999999 」|r", 10)
            SendDtimeMsgAll(17.5, "|cFFCC9966「|r|cFFC8996D |r|cFFC59975你|r|cFFC1997C应|r|cFFBD9983该|r|cFFBA998A还|r|cFFB69992记|r|cFFB39999得|r|cFFAF99A0那|r|cFFAB99A8句|r|cFFA899AF话|r|cFFA499B6 |r|cFFA099BD」|r", 10)
            SendDtimeMsgAll(20, "|cffcccccc「|r|cffccc7c2 |r|cffccc2b8我|r|cffccbdad们|r|cffccb8a3是|r|cffccb399守|r|cffccad8f护|r|cffcca885者|r|cffcca37a，|r|cffcccccc也|r|cffc9c1c1是|r|cffc7b7b7时|r|cffc4acac刻|r|cffc1a1a1对|r|cffbf9696抗|r|cffbc8c8c着|r|cffb98181危|r|cffb77676险|r|cffb46b6b和|r|cffb16161疯|r|cffae5656狂|r|cffac4b4b的|r|cffa94040可|r|cffa63636怜|r|cffa42b2b虫|r|cffa12020 |r|cff9e1515」|r", 10)
            u:setdata("愚者-诡法师")
            shengjie()
            u:uivar_change({
              keyname = "愚者传奇",
              keytype = "传奇栏",
              jbtext = function()
                reset()
                UIYName[1].extratext = " - 「4」"
                UIYName[2] = {
                  method = 1,
                  name = "诡法师",
                  colors = {
                    "375623",
                    "949596",
                    "949596",
                    "375623"
                  },
                  length = 5,
                  lengthcd = 15,
                  math = 1,
                  offsetspeed = 0.25,
                  extratext = [[


]]
                }
              end
            })
            ac.loop(1000, function(timer)
              if u:isalive() and u:getdata("击杀数量-精英") >= 15 then
                jinjiezu["古代学者"]()
                timer:remove()
              end
            end)
          end,
          ["古代学者"] = function()
            PlayGlobalSound(Sound_Yuzhe_Gudaixuezhe)
            SendDtimeMsgAll(0, "|cFF666699「 |r|cFF6B6B9E伟|r|cFF7171A4大|r|cFF7676A9的|r|cFF7B7BAE主|r|cFF8181B4人|r|cFF8686B9，|r|cFF8C8CBF我|r|cFF9191C4们|r|cFF9696C9接|r|cFF9C9CCF下|r|cFFA1A1D4来|r|cFFA6A6D9去|r|cFFACACDF哪|r|cFFB1B1E4里|r|cFFB7B7EA呢|r|cFFBCBCEF？|r|cFFC1C1F4 」|r", 10)
            SendDtimeMsgAll(4, "|cFF6699FF「 |r|cFF6A9BFF去|r|cFF6E9DFF哪|r|cFF719FFF里|r|cFF75A1FF\n|r|cFF7DA4FF |r|cFF80A6FF |r|cFF84A8FF |r|cFF88AAFF |r|cFF8CACFF |r|cFF90AEFF—|r|cFF93B0FF—|r|cFF97B2FF接|r|cFF9BB3FF下|r|cFF9FB5FF来|r|cFFA2B7FF，|r|cFFA6B9FF我|r|cFFAABBFF们|r|cFFAEBDFF一|r|cFFB2BFFF起|r|cFFB5C1FF去|r|cFFB9C3FF流|r|cFFBDC4FF浪|r|cFFC1C6FF吧|r|cFFC4C8FF 」|r", 10)
            SendDtimeMsgAll(10.1, "|cFF6699CC「|r|cFF6D9CCF |r|cFF74A0D3你|r|cFF7AA3D6有|r|cFF81A7DA什|r|cFF88AADD么|r|cFF8FADE0想|r|cFF96B1E4去|r|cFF9CB4E7的|r|cFFA3B8EB地|r|cFFAABBEE方|r|cFFB1BEF1吗|r|cFFB8C2F5 |r|cFFBEC5F8」|r", 10)
            SendDtimeMsgAll(13, "|cFF6666CC「|r|cFF6A6ACE |r|cFF6D6DD0特|r|cFF7171D1里|r|cFF7575D3尔|r|cFF7878D5，|r|cFF7C7CD7不|r|cFF7F7FD9不|r|cFF8383DB不|r|cFF8787DC不|r|cFF8A8ADE\n|r|cFF9292E2—|r|cFF9595E4—|r|cFF9999E6您|r|cFF9D9DE7想|r|cFFA0A0E9去|r|cFFA4A4EB哪|r|cFFA8A8ED里|r|cFFABABEF，|r|cFFAFAFF0我|r|cFFB2B2F2就|r|cFFB6B6F4去|r|cFFBABAF6哪|r|cFFBDBDF8里|r|cFFC1C1FA |r|cFFC5C5FB」|r", 10)
            u:setdata("愚者-古代学者")
            shengjie()
            u:uivar_change({
              keyname = "愚者传奇",
              keytype = "传奇栏",
              jbtext = function()
                reset()
                UIYName[1].extratext = " - 「3」"
                UIYName[2] = {
                  method = 1,
                  name = "古代学者",
                  colors = {
                    "FF0000",
                    "949596",
                    "949596",
                    "FF0000"
                  },
                  length = 5,
                  lengthcd = 15,
                  math = 1,
                  offsetspeed = 0.25,
                  extratext = [[


]]
                }
              end
            })
            u:adddivinity(1)
            u:changedata("全属性增幅", 0.05)
            u:adddivinity(1)
          end,
          ["奇迹师"] = function()
            flashphoto({
              photo = "Ph_Kle_04.tga",
              timeout = 4,
              timehold = 1,
              timein = 2
            })
            ForGroupLuaNew(Group_PlayHero, function(xq)
              xq:buffset(u.handle, 7, "绝对闪避")
            end)
            PlayGlobalSound(Sound_Yuzhe_Qijishi)
            SendDtimeMsgAll(0, "|cFF99CCCC「|r|cFF9ACBC9 |r|cFF9CC9C6奇|r|cFF9DC8C3迹|r|cFF9FC6C0只|r|cFFA0C5BD能|r|cFFA2C3BB一|r|cFFA3C2B8时|r|cFFA5C0B5\n|r|cFFA8BDAF |r|cFFA9BCAC |r|cFFAABBA9 |r|cFFACB9A6 |r|cFFADB8A3 |r|cFFAFB6A0 |r|cFFB0B59D |r|cFFB2B39A |r|cFFB3B298 |r|cFFB5B095 |r|cFFB6AF92 |r|cFFB8AD8F |r|cFFB9AC8C |r|cFFBBAA89 |r|cFFBCA986 |r|cFFBDA883命|r|cFFBFA680运|r|cFFC0A57D却|r|cFFC2A37A总|r|cFFC3A277是|r|cFFC5A075漫|r|cFFC69F72长|r|cFFC89D6F |r|cFFC99C6C」|r", 10)
            u:setdata("愚者-奇迹师")
            shengjie()
            u:uivar_change({
              keyname = "愚者传奇",
              keytype = "传奇栏",
              jbtext = function()
                reset()
                UIYName[1].extratext = " - 「2」"
                UIYName[2] = {
                  method = 1,
                  name = "奇迹师",
                  colors = {
                    "C00000",
                    "949596",
                    "949596",
                    "C00000"
                  },
                  length = 5,
                  lengthcd = 15,
                  math = 1,
                  offsetspeed = 0.25,
                  extratext = [[


]]
                }
              end
            })
            u:adddivinity(1)
            local RewardCooldowns = {}
            for i = 1, 7 do
              RewardCooldowns[i] = false
            end
            
            local function grantReward(u, index)
              local sy = u.ownerid
              local str = ""
              if index == 1 then
                str = "补给"
                for i = 1, 3 do
                  u:additem("I00X")
                end
              elseif index == 2 then
                str = "武器"
                local pools = {
                  Pools_SpeWeapon,
                  Pools_SpeDzWeapon
                }
                local x, y = u:getxy()
                local wp = herogetitem(u.handle, pools, x, y)
              elseif index == 3 then
                str = "伤害提升"
                ChangeValue(DamageSystem_Shjc, sy, 0.005)
                ChangeValue(DamageSystem_Shjc, sy, 0.005)
                ChangeValue(DamageSystem_Shjc, sy, 0.005)
              elseif index == 4 then
                str = "财富"
                local score = math.floor((Time_M * 60 + Time_S) * 0.5)
                u:addgold(score)
              elseif index == 5 then
                str = "诅咒"
                for i = 1, 2 do
                  if u:getluckrandom(50) then
                    local b1 = true
                    if b1 then
                      local pools = {
                        Vars_Fengmo
                      }
                      local str = herogetvar(u.handle, pools, "封魔壶")
                      if str == "失败" then
                        b1 = false
                      end
                    end
                    if b1 then
                      u:changedata("魔封数量", 1)
                    end
                  else
                    local b1 = true
                    if b1 then
                      local pools = {
                        Vars_Zhenyao
                      }
                      local str = herogetvar(u.handle, pools, "镇妖壶")
                      if str == "失败" then
                        b1 = false
                      end
                    end
                    if b1 then
                      u:changedata("妖咒数量", 1)
                    end
                  end
                end
              elseif index == 6 then
                str = "伤害降低"
                ChangeValue(DamageSystem_Shjc, sy, -0.005)
                ChangeValue(DamageSystem_Shjc, sy, -0.005)
                ChangeValue(DamageSystem_Shjc, sy, -0.005)
              elseif index == 7 then
                str = "特殊物品"
                local x, y = u:getxy()
                local pools = {
                  Pools_Spe,
                  Pools_SpeDzWeapon
                }
                local nwp = herogetitem(u.handle, pools, x, y)
                if GetItemTypeId(nwp) == S2ID("I0H1") then
                  local bb = getunit(Beibao[sy])
                  bb:addspeitem(nwp)
                else
                  u:addspeitem(nwp)
                end
              end
              u:sendmessage("|cFFC00000奇迹-" .. str .. "|r")
            end
            
            local dskill = S2ID("A0IV")
            u:byladdskill(dskill, function(args)
              if args.skill == dskill then
                local b = true
                local ewl = getunit(args.unit)
                if not u:isalive() then
                  b = false
                  u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
                end
                if b then
                  local candidates = {}
                  for i = 1, 7 do
                    if not RewardCooldowns[i] then
                      table.insert(candidates, i)
                    end
                  end
                  if #candidates == 0 then
                    u:sendmessage("|cFF7DBEF1没有可以释放的奇迹|r")
                    return
                  end
                  local index = candidates[GetRandomInt(1, #candidates)]
                  RewardCooldowns[index] = true
                  grantReward(u, index)
                  ac.wait(666000, function()
                    RewardCooldowns[index] = false
                  end)
                  if u:getperhp() <= 95 then
                    u:sethp(1)
                    u:kill()
                  else
                    u:losshp(u, 0, 0, 95)
                  end
                  ac.timer(100, 300, function()
                    if u:getperhp() >= 40 then
                      u:sethp(39, true)
                    end
                  end)
                else
                  ewl:setskillcd(dskill, 1)
                end
              end
            end)
          end,
          ["诡秘侍者"] = function()
            flashphoto({
              photo = "Ph_Kle_06.tga",
              timeout = 4,
              timehold = 4,
              timein = 2
            })
            ForGroupLuaNew(Group_PlayHero, function(xq)
              xq:buffset(u.handle, 10, "绝对闪避")
            end)
            PlayGlobalSound(Sound_Yuzhe_Guimishizhe)
            SendDtimeMsgAll(0, "|cFF6699CC「|r|cFF6A9BCC |r|cFF6E9DCC也|r|cFF729FCC许|r|cFF76A1CC我|r|cFF7AA3CC从|r|cFF7EA5CC未|r|cFF83A7CC离|r|cFF87A9CC开|r|cFF8BABCC故|r|cFF8FADCC乡|r|cFF93AFCC，|r|cFF97B1CC却|r|cFF9BB4CC永|r|cFF9FB6CC远|r|cFFA3B8CC回|r|cFFA7BACC不|r|cFFABBCCC到|r|cFFAFBECC家|r|cFFB4C0CC了|r|cFFB8C2CC…|r|cFFBCC4CC…|r|cFFC0C6CC |r|cFFC4C8CC」|r", 10)
            u:setdata("愚者-诡秘侍者")
            shengjie()
            u:uivar_change({
              keyname = "愚者传奇",
              keytype = "传奇栏",
              jbtext = function()
                reset()
                UIYName[1].extratext = " - 「1」"
                UIYName[2] = {
                  method = 1,
                  name = "诡秘侍者",
                  colors = {
                    "222B35",
                    "949596",
                    "949596",
                    "222B35"
                  },
                  length = 5,
                  lengthcd = 15,
                  math = 1,
                  offsetspeed = 0.25,
                  extratext = [[


]]
                }
              end
            })
            u:adddivinity(1)
            u:addstexiao(var.name .. "2", "决死效果", function(args)
              if args.dt and not u:hasdata("愚者诡秘侍者-决死冷却") then
                args.dt = false
                u:setdata("愚者诡秘侍者-决死冷却", 400)
                u:settimedata("诡秘侍者-死亡抗拒", 5)
                u:sendmessage("|cFF222B35诡秘侍者-“再生”|r")
                ac.timer(1000, 20, function()
                  u:curehp(u.handle, 0, 10, 4)
                end)
              end
            end)
            ac.loop(1000, function()
              if not u:hasdata("愚者诡秘侍者-决死冷却") then
                if u:getperhp() <= 20 then
                  u:setdata("愚者诡秘侍者-决死冷却", 400)
                  u:settimedata("诡秘侍者-死亡抗拒", 5)
                  u:sendmessage("|cFF222B35诡秘侍者-“再生”|r")
                  ac.timer(1000, 20, function()
                    u:curehp(u.handle, 0, 10, 4)
                  end)
                end
              else
                u:changedata("愚者诡秘侍者-决死冷却", -1)
                if u:getdata("愚者诡秘侍者-决死冷却") <= 0 then
                  u:deldata("愚者诡秘侍者-决死冷却")
                end
              end
            end)
            u:addstexiao(var.name, "被施加Buff时效果-眩晕", function(args)
              if not Keyan_Guomintizhi then
                args.time = 0
              end
            end)
            u:addstexiao(var.name, "被施加Buff时效果-僵直", function(args)
              if not Keyan_Guomintizhi then
                args.time = 0
              end
            end)
          end,
          ["诡秘之主"] = function()
            PlayGlobalSound(Sound_Yuzhe_Jinji)
            SendDtimeMsgAll(2, "|cFF666666『|r|cFF808080你|r|cFF8C8C8C怕|r|cFF999999吗|r|cFFB2B2B2』|r", 10)
            SendDtimeMsgAll(4.6, "|cFF666666『|r|cFF838383不|r|cFF929292怕|r|cFFAFAFAF』|r", 10)
            SendDtimeMsgAll(5.5, "|cFF666666『|r|cFF7A7A7A伟|r|cFF858585大|r|cFF8F8F8F的|r|cFF999999主|r|cFFA3A3A3人|r|cFFB8B8B8』|r", 10)
            SendDtimeMsgAll(7.1, "|cFF666666『|r|cFF7D7D7D您|r|cFF939393怕|r|cFF9F9F9F吗|r|cFFB5B5B5』|r", 10)
            SendDtimeMsgAll(9.3, "|cFF999999『|r|cFF808080怕|r|cFF737373…|r|cFF666666…|r|cFF4C4C4C』|r", 10)
            musiccolortext({
              strz = {
                {
                  str = " 「 但 … … 」 ",
                  time = 12.3,
                  showtexttime = 0.5,
                  staytime = 3.5,
                  fadetime = 0.75,
                  sx = 250,
                  sy = 300,
                  dx = 35
                },
                {
                  str = " 「 總 有 些 事 」",
                  time = 12.600000000000001,
                  showtexttime = 0.5,
                  staytime = 3.5,
                  fadetime = 0.75,
                  sx = 350,
                  sy = 450,
                  dx = 35
                },
                {
                  str = " 「 高 于 其 他 」 ",
                  time = 14.3,
                  showtexttime = 0.5,
                  staytime = 3.5,
                  fadetime = 0.75,
                  sx = 450,
                  sy = 600,
                  dx = 35
                }
              },
              colorstart = "00FFFFFF",
              colorend = "FFFFBD30"
            })
            ac.wait(20000, function()
              PlayGlobalSound(Sound_Yuzhe_Jinji2)
              musiccolortext({
                strz = {
                  {
                    str = " 「 不 属 于 這 个 時 代 的 愚 者 」 ",
                    time = 0,
                    showtexttime = 2.5,
                    staytime = 5,
                    fadetime = 10,
                    sx = 250,
                    sy = 300,
                    dx = 35
                  },
                  {
                    str = " 「 灰 霧 之 上 的 神 秘 主 宰 」",
                    time = 3,
                    showtexttime = 2.5,
                    staytime = 5,
                    fadetime = 7.5,
                    sx = 350,
                    sy = 450,
                    dx = 35
                  },
                  {
                    str = " 「 執 掌 好 運 的 黄 黒 之 王 」 ",
                    time = 7.2,
                    showtexttime = 2.5,
                    staytime = 5,
                    fadetime = 5,
                    sx = 450,
                    sy = 600,
                    dx = 35
                  }
                },
                colorstart = "00FFFFFF",
                colorend = "FFFFBD30"
              })
              musiccolortext({
                strz = {
                  {
                    str = "The Fool that doesn’t belong to this era",
                    time = 0,
                    showtexttime = 2.5,
                    staytime = 5,
                    fadetime = 10,
                    sx = 150,
                    sy = 375,
                    dx = 35
                  },
                  {
                    str = "The Mysterious Ruler above the gray fog",
                    time = 3,
                    showtexttime = 2.5,
                    staytime = 5,
                    fadetime = 7.5,
                    sx = 150,
                    sy = 525,
                    dx = 35
                  },
                  {
                    str = "The King of Yellow and Black who wields good luck",
                    time = 7.2,
                    showtexttime = 2.5,
                    staytime = 5,
                    fadetime = 5,
                    sx = 150,
                    sy = 675,
                    dx = 35
                  }
                },
                colorstart = "00FFFFFF",
                colorend = "FF7E7E7E"
              })
              ac.wait(20300, function()
                local red = class.panel:builder({
                  parent = OriginPanel,
                  x = 0,
                  y = 0,
                  w = 1920,
                  h = 851,
                  normal_image = "Black.tga"
                })
                red:set_level(3)
                ac.wait(2000, function()
                  local a = 255
                  ac.timer(25, 100, function()
                    a = a - 2.5
                    red:set_alpha(a)
                  end)
                end)
                ac.wait(6000, function()
                  red:destroy()
                end)
                flashphoto({
                  photo = "Ph_Kle_07.tga",
                  timeout = 0,
                  timehold = 7,
                  timein = 3
                })
                ac.wait(2300, function()
                  musiccolortext({
                    strz = {
                      {
                        str = " 「 祢 們 可 以 称 呼 我 」 ",
                        time = 0,
                        showtexttime = 1,
                        staytime = 5,
                        fadetime = 5,
                        sx = 250,
                        sy = 300,
                        dx = 35
                      },
                      {
                        str = "             「 愚          者 」             ",
                        time = 2,
                        showtexttime = 0.5,
                        staytime = 5,
                        fadetime = 5,
                        sx = 200,
                        sy = 475,
                        dx = 35
                      }
                    },
                    colorstart = "00FFFFFF",
                    colorend = "FFFFBD30"
                  })
                  PlayBGM({
                    bgm = BGM_Yuzhe_Jinji,
                    time = 185,
                    ID = 236,
                    unit = u.handle
                  })
                end)
                ForGroupLuaNew(Group_PlayHero, function(xq)
                  xq:buffset(u.handle, 10, "绝对闪避")
                end)
              end)
            end)
            Boolean_ColorName[sy] = true
            ColorName[sy][1] = {
              method = 1,
              name = "「Lord of the Mysteries」",
              colors = {
                "6699FF",
                "3366FF",
                "9966FF",
                "FF0000",
                "9966FF",
                "3366FF",
                "6699FF"
              },
              length = 10,
              lengthcd = 150,
              math = 1,
              offsetspeed = 0.5
            }
            if TP_ID[sy] then
              TP_ID[sy]:remove()
            end
            u:setdata("愚者-诡秘之主")
            shengjie()
            u:uivar_change({
              keyname = "愚者传奇",
              keytype = "传奇栏",
              jbtext = function()
                reset()
                UIYName[1].extratext = " - 「0」"
                UIYName[2] = {
                  method = 1,
                  name = "诡秘之主",
                  colors = {
                    "222B35",
                    "949596",
                    "949596",
                    "222B35"
                  },
                  length = 5,
                  lengthcd = 15,
                  math = 1,
                  offsetspeed = 0.25,
                  extratext = [[


]]
                }
              end,
              clickfunc = function()
                if u:hasdata("愚者-命运值获取") and not u:hasdata("愚者-命运值已获取") then
                  u:setdata("愚者-命运值已获取")
                  u:setdata("愚者-命运值", 100)
                end
              end
            })
            SetTimeOfDay(0)
            DayNightRun = false
            ac.wait(60000, function()
              DayNightRun = true
            end)
            u:adddivinity(1)
            u:changedata("外神变异数量", 1)
            u:changedata("根源变异数量", 1)
            local tz = getunit(NPC_TIANZI)
            tz:setdata("环境变更")
            tz:setdata("诡秘之主天气切换")
            local add2 = 0.005 * u:getstate("外域变异") + 1.5E-4 * u:getstate("累积杀敌")
            ChangeValue(Damage_Element_Light, sy, add2)
            ChangeValue(Damage_Element_Dark, sy, add2)
            local zu = {
              Damage_Element_Thunder,
              Damage_Element_Water,
              Damage_Element_Fire,
              Damage_Element_Earth,
              Damage_Element_Heart,
              Damage_Element_Ice
            }
            local add = 0
            local armor = 0
            local endsh = 0
            local cs = 0
            ac.loop(2500, function()
              ChangeValue(Damage_Element_Light, sy, -add)
              ChangeValue(Damage_Element_Dark, sy, -add)
              add = 0
              for index, value in ipairs(zu) do
                add = add + 0.1 * value[sy]
              end
              ChangeValue(Damage_Element_Light, sy, add)
              ChangeValue(Damage_Element_Dark, sy, add)
              u:changearmor(armor)
              armor = u:getarmor()
              u:changearmor(-armor)
              ChangeValue(DamageSystem_EndSh, sy, 0.1 * -endsh)
              endsh = 0.0025 * u:getstate("外域变异") + 0.01 * u:getdata("愚者-诡秘计数")
              ChangeValue(DamageSystem_EndSh, sy, 0.1 * endsh)
              if u:isalive() then
                cs = cs + 1
                if 4 <= cs then
                  cs = 0
                  u:buffset(u.handle, 1.5, "无实体")
                end
              end
            end)
            local strname = "愚者诡秘之主"
            u:addstexiao(strname, "直接伤害特效", function(args)
              local tg = args.tg
              local u = args.u
              local info = args.damageinfo
              if not tg:hasdata(strname .. "-特效冷却") then
                tg:settimedata(strname .. "-特效冷却", 5)
                tg:buffset(u.handle, 1, "暂停")
                if not tg:hasdata("诡秘之主降抗") then
                  tg:setdata("诡秘之主降抗")
                  tg:changedata("光属性抗性", -31.4)
                  tg:changedata("暗属性抗性", -31.4)
                end
              end
              if not u:hasdata(strname .. "-特效1冷却") then
                u:settimedata(strname .. "-特效1冷却", 0.8)
                local txsh = 150 * u:getallattri() + 6280 * u:getstate("外域变异")
                DamageUnit({
                  bj = "诡秘之主附伤",
                  unit = tg.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "魔力",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = "光"
                })
                DamageUnit({
                  bj = "诡秘之主附伤",
                  unit = tg.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "魔力",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = "暗"
                })
              end
            end)
            u:addstexiao(strname, "伤害格挡效果", function(args)
              if not args.b and GetRandom100(33) then
                args.b = true
                u:effectadd("Abilities\\Spells\\Human\\ManaShield\\ManaShieldCaster.mdl", "chest")
              end
            end)
            u:addskill("S0CQ")
            local npc = getunit(NPC_Molijiedian)
            npc:delskill("A07A")
            npc:addskill("S0CO")
            local addzq = 0.004 * WAIYU_Count
            ForGroupLuaNew(Group_PlayHero, function(xq)
              xq:delskill("S02C")
              xq:addskill("S0CP")
              if xq:hasdata("阿比盖尔-虚伪之海") then
                xq:deldata("阿比盖尔-虚伪之海")
                xq:changedata("效果增强-外域", -0.25)
              end
              xq:setdata("愚者-诡秘神国")
              xq:changedata("效果增强-外域", addzq)
            end)
            u:setdata("愚者-命运值", 0)
            local smz = math.floor((u:getdata("外域变异数量") + 8) / 10 + u:getdata("残机剩余数量"))
            u:setdata("愚者-宿命计数", smz)
            local dcs = 0
            local dcs2 = 0
            local xg = 0
            local sl = 0
            ac.loop(3000, function()
              if u:isalive() then
                dcs = dcs + 1
                if 20 <= dcs then
                  dcs = 0
                  u:changedata("愚者-命运值", 1.5)
                end
                dcs2 = dcs2 + 1
                if 100 <= dcs2 then
                  dcs2 = 0
                  u:changedata("愚者-命运值", 2.5)
                end
              end
              if 100 <= u:getdata("愚者-命运值") then
                u:setdata("愚者-命运值", 100)
              end
              local myz = u:getdata("愚者-命运值")
              u:changedata("效果增强-外域", -xg)
              xg = 0.005 * myz
              u:changedata("效果增强-外域", xg)
              u:changedata("外域变异数量", -sl)
              sl = math.floor(myz / 20)
              u:changedata("外域变异数量", sl)
              if 50 <= myz and not u:hasdata("愚者-命运增强1") then
                u:setdata("愚者-命运增强1")
                ChangeValue(DamageSystem_EndSh, sy, 0.008)
                u:changedata("全属性增幅", 0.075)
              end
              if 75 <= myz and not u:hasdata("愚者-命运增强2") then
                u:setdata("愚者-命运增强2")
                local sxadd = (10 + u:getdata("外域变异数量")) * u:getdata("愚者-宿命计数") * 0.001
                ChangeValue(Damage_Element_Light, sy, sxadd)
                ChangeValue(Damage_Element_Dark, sy, sxadd)
              end
              if 100 <= myz and not u:hasdata("愚者-命运增强3") then
                u:setdata("愚者-命运增强3")
                PlayGlobalSound(Sound_Yuzhe_Tianzun)
                SendDtimeMsgAll(0.1, "|cFF999999对|r|cFF9999A0我|r|cFF9999A8个|r|cFF9999AF人|r|cFF9999B6来|r|cFF9999BD说|r", 10)
                SendDtimeMsgAll(1.5, "|cFF999999我|r|cFF99999E并|r|cFF9999A3不|r|cFF9999A8渴|r|cFF9999AD求|r|cFF9999B2成|r|cFF9999B8为|r|cFF9999BD旧|r|cFF9999C2日|r", 10)
                SendDtimeMsgAll(3.5, "|cFF999999但|r|cFF9999AA是|r", 10)
                SendDtimeMsgAll(4.6, "|cFF999999我|r|cFF99999C不|r|cFF99999E能|r|cFF9999A1辜|r|cFF9999A3负|r|cFF9999A6、|r|cFF9999A8背|r|cFF9999AB弃|r|cFF9999AD在|r|cFF9999B0我|r|cFF9999B3身|r|cFF9999B5上|r|cFF9999B8押|r|cFF9999BA注|r|cFF9999BD的|r|cFF9999BF那|r|cFF9999C2些|r|cFF9999C4存|r|cFF9999C7在|r", 10)
                SendDtimeMsgAll(8, "|cFF999999他|r|cFF99999D们|r|cFF9999A2或|r|cFF9999A6多|r|cFF9999AA或|r|cFF9999AE少|r|cFF9999B2都|r|cFF9999B7帮|r|cFF9999BB助|r|cFF9999BF过|r|cFF9999C4我|r", 10)
                ac.wait(8000, function()
                  PlayBGM({
                    bgm = BGM_Yuzhe_Tianzun,
                    time = 190,
                    ID = 237,
                    unit = u.handle
                  })
                end)
                u:setdata("愚者-天尊亡曲触发")
                u:setdata("愚者-亡曲复活次数", 10)
                ac.wait(198000, function()
                  u:setdata("愚者-亡曲删模判定")
                end)
                ac.loop(1000, function(timer)
                  if u:hasdata("愚者-亡曲删模判定") and not u:hasdata("系统-已删模") then
                    u:shanmo()
                  end
                end)
              end
            end)
            if u:islocal() then
              BuffUI.apply({
                id = "愚者-宿命计数",
                duration = 99999
              })
              BuffUI.apply({
                id = "愚者-命运值",
                duration = 99999
              })
            end
          end
        }
        
        local function chattrg(args)
          if args.chat == "队长，我要成为非凡者" and u:isalive() and not u:hasdata("愚者-占卜师") then
            jinjiezu["占卜师"]()
          end
          if args.chat == "总有些事，高于其他" and u:isalive() and u:hasdata("愚者-诡秘之主") and not u:hasdata("愚者-命运值获取") then
            u:settimedata("愚者-命运值获取", 10)
          end
        end
        
        u:addtrgevent("玩家-聊天", function(args)
          chattrg(args)
        end)
        u:setdata("愚者-进阶函数", jinjiezu)
      end
    end,
    effectname = "|cFF0066CC克|r|cFF0D73D2莱|r|cFF1A80D9恩|r|cFF268CDF.|r|cFF3399E6莫|r|cFF40A6EC雷|r|cFF4CB2F2蒂|r",
    effecttext = "|cff990000「|r|cff990b0b所|r|cff991616有|r|cff992121人|r|cff992c2c都|r|cff993737会|r|cff994242死|r|cff994c4c，|r|cff995757也|r|cff996262包|r|cff996d6d括|r|cff997878我|r|cff998383」|r\n\n|cFFCC6600「|r|cFFCA680A也|r|cFFC86A14许|r|cFFC66C1F，|r|cFFC46E29我|r|cFFC27033从|r|cFFC0723D未|r|cFFBE7447离|r|cFFBC7652开|r|cFFBA785C过|r|cFFB87A66故|r|cFFB67C70乡|r|cFFB47E7A，|r|cFFB18185却|r|cFFAF838F永|r|cFFAD8599远|r|cFFAB87A3也|r|cFFA989AD不|r|cFFA78BB8可|r|cFFA58DC2能|r|cFFA38FCC回|r|cFFA191D6家|r|cFF9F93E0了|r|cFF9D95EB」|r",
    effectart = "Ewl_Yuzhe_04.tga",
    test = [[

    ]]
  },
  {
    name = "夜夜",
    weight = 5,
    key = {"唯一", "机械"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I057") then
        add = add + 1000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-夜夜") then
        b = true
      end
      if not u:ishasshw() then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:reduceshw()
      u:setplayername("|cFF7DBEF1[|r|cFFFFFF00夜夜|r|cFF7DBEF1]|r" .. NameID[sy])
      u:setdata("夜夜力量增强", 0)
      u:playsound(Sound_Yeye_01)
      local lz = getunit(Beibao[sy])
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        local x, y = u:getxy()
        local x2, y2 = tg:getxy()
        if (u:hasdata("夜夜觉醒") or u:hasdata("夜夜-吹鸣")) and not u:hasdata(var.name .. "-吹鸣冷却") then
          u:settimedata(var.name .. "-吹鸣冷却", 0.1)
          if not tg:hasdata("吹鸣绝冲破抗") then
            if u:hasdata("夜夜神机") then
              tg:changedata("吹鸣绝冲叠加层数", 2)
            else
              tg:changedata("吹鸣绝冲叠加层数", 1)
            end
            if tg:getdata("吹鸣绝冲叠加层数") >= 10 and (lz:getpermp() >= 5 or u:hasdata("夜夜神机")) then
              tg:setdata("吹鸣绝冲叠加层数", 0)
              if not u:hasdata("夜夜神机") then
                lz:setmp(u:getpermp() - 5, true)
              end
              local txsh = 1000 + 500 * u:getlevel() + (250 * u:getstr() + 250 * u:getagi())
              local jd = AngleBetweenUnits(u.handle, tg.handle)
              Effectcreate("war3mapimported\\144.mdl", x, y, 0, 2, 0, jd)
              Effectcreate("Objects\\Spawnmodels\\NightElf\\NEDeathMedium\\NEDeath.mdl", x, y)
              if tg:isnormal() then
                unitmove({
                  unit = tg.handle,
                  time = 1,
                  distance = 800,
                  angle = jd,
                  isfly = false,
                  loops = {
                    {
                      looptime = 0.05,
                      func = function(dx, dy)
                        Effectcreate("Abilities\\Weapons\\BallistaMissile\\BallistaImpact.mdl", dx, dy)
                      end
                    }
                  }
                })
              end
              tg:buffset(u.handle, 1, "眩晕")
              tg:settimedata("吹鸣绝冲破抗", 1)
              if tg:hasdata("精英特性-迅捷") then
                tg:delskill("S00G")
                tg:deldata("精英特性-迅捷")
                ac.wait(5000, function()
                  tg:addskill("S00G")
                  tg:setdata("精英特性-迅捷")
                end)
              end
              for _, xq in ac.selector():in_rangexy(x2, y2, 300):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                DamageUnit({
                  bj = "夜夜吹鸣绝冲",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "物理",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = "无",
                  extradata = {""}
                })
              end
            end
          end
        end
        if (u:hasdata("夜夜觉醒") or u:hasdata("夜夜-光焰")) and not u:hasdata(var.name .. "-光焰冷却") and (u:hasdata("夜夜神机") or lz:getpermp() >= 3 and u:getluckrandom(15 * info.txgl)) then
          u:settimedata(var.name .. "-光焰冷却", 0.5)
          local count = 1
          local txsh = 0.5 * info.yssh
          if GetRandom100(10) then
            tg:playsound(Yeye_1)
          end
          if not u:hasdata("夜夜神机") then
            lz:setmp(u:getpermp() - 3, true)
            for i = 1, 2 do
              if u:getluckrandom(15 * info.txgl) then
                count = count + 1
              end
            end
          else
            txsh = 0.75 * info.yssh
          end
          tg:effectadd("Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl", "overhead")
          for i = 1, count do
            DamageUnit({
              bj = "夜夜光焰",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "物理",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无",
              extradata = {""}
            })
          end
        end
      end)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not tg:hasdata("夜夜-近战杀敌判定") then
          tg:settimedata("夜夜-近战杀敌判定", 0.05)
          ac.wait(50, function()
            if not tg:isalive() then
              ChangeValue(Correction_Jzsh, sy, 5.0E-5)
            end
          end)
        end
      end)
      u:addstexiao(var.name, "伤害判定前变更", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("夜夜觉醒") or u:hasdata("月影红莲") then
          info.level = 5
        end
      end)
      u:changearmor(5 + 0.5 * u:getlevel())
      u:addstr(20)
      u:addagi(20)
      local bb = getunit(Beibao[sy])
      bb:addskill("A0F0")
      bb:delskill("A0F0")
      japi.SetUnitModel(bb.handle, "war3mapImported\\raishin.mdx")
      bb:setmaxmp(1000)
      bb:setmp(100, true)
      Leizhen = Beibao[sy]
      local cs = 0
      ac.loop(1000, function()
        cs = cs + 1
        if cs == 120 then
          cs = 0
          if GetRandom100(50) then
            u:addstr(1)
          else
            u:addagi(1)
          end
        end
        local lv = 2
        if u:ishasitem("I057") then
          lv = 4
          lz:setmp(lz:getpermp() + 1.5, true)
        else
          lz:setmp(lz:getpermp() + 1, true)
        end
        if u:hasdata("夜夜-森闲") then
          lz:sethp(lz:getperhp() + 0.0066, true)
        end
        local hp1 = u:getperhp()
        local hp2 = lz:getperhp()
        if hp1 <= 50 and 50 <= hp2 then
          lz:sethp(lz:getperhp() - 1, true)
          u:curehp(u.handle, 0, 2, lv)
        end
        if hp2 <= 5 and not u:hasdata("夜夜-虚弱") then
          u:setdata("夜夜-虚弱")
          u:addskill("S04C")
          ChangeValue(DamageSystem_Ysshjd, sy, 0.5, 1)
        end
        if 5 <= hp2 and u:hasdata("夜夜-虚弱") then
          u:deldata("夜夜-虚弱")
          u:delskill("S04C")
          ChangeValue(DamageSystem_Ysshjd, sy, 0.5, 2)
        end
        local mp2 = lz:getpermp()
        if 50 <= mp2 then
          u:curemp(0.3)
        else
          u:curemp(-0.1)
        end
      end)
      u:setdata("夜夜觉醒次数", 0)
      ac.loop(100, function()
        local count = u:getdata("夜夜觉醒次数")
        if lz:getperhp() >= 100 - 5 * count then
          if 20 <= count then
            lz:sethp(1, true)
          else
            lz:sethp(100 - 5 * count, true)
          end
        end
      end)
      ChangeValue(DamageSystem_Baoji, sy, 18)
      ChangeValue(DamageSystem_Baoshang, sy, 0.36)
      ChangeValue(DamageSystem_Shjc, sy, 0.06)
      ChangeValue(DamageSystem_Shjc, sy, 0.06)
      local zs = 0
      local sj = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -zs)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -sj)
        zs = 3.0E-4 * u:getstr()
        sj = 6.0E-4 * u:getagi()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * sj)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * zs)
      end)
      moveskillreplace({
        unit = u.handle,
        level = 2,
        skill_Q = "A13A",
        skill_W = "A17R",
        isforce = false,
        efunc = function()
          local function skill(args)
            if args.skill == S2ID("A13A") then
              local tilixh = 1
              
              local dskill = args.skill
              if u:hasbuff("缠绕") then
                u:setskillcd(dskill, 0.01)
                u:sendmessage("|cFFFF3300缠绕中|r")
                return
              end
              if not u:hasdata("位移体力消耗标记") then
                if u:lossstamina(tilixh) then
                  u:settimedata("位移体力消耗标记", 0.001)
                else
                  u:setskillcd(dskill, 0.01)
                  u:sendmessage("|cFFFF3300体力值不足|r")
                  return
                end
              end
              local x, y = u:getxy()
              u:playsound(bac54)
              local a = u:getface()
              local r = 100
              local x2, y2 = PolarXY(x, y, r, a)
              Effectcreate("AATX\\[AATxNew]Hit02.mdl", x2, y2, 0, 2.5, 100, 180 + a)
              Effectcreate("AATX\\[AATxNew]Dust09.mdl", x2, y2, 0, 3, 100)
              Effectcreate("war3mapImported\\bbb.mdl", x, y, 0, 5)
              Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
              x2, y2 = PolarXY(x, y, 180, a)
              local txsh = 40 * (u:getagi() + u:getstr())
              for _, xq in ac.selector():in_rangexy(x2, y2, 220):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                unitmove({
                  unit = xq.handle,
                  time = 0.2,
                  distance = 350,
                  angle = a
                })
                local x3, y3 = xq:getxy()
                Effectcreate("war3mapImported\\bbb.mdl", x3, y3)
                local t = 1.8
                if not xq:isnormal() then
                  t = 0.5
                end
                xq:buffset(u.handle, t, "眩晕")
                DamageUnit({
                  bj = "夜夜位移",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "物理",
                  isvest = false,
                  isattack = true,
                  isnoarmor = false,
                  element = "无",
                  extradata = {""}
                })
              end
              if not u:hasbuff("绝对闪避") then
                u:setdata("刷新Q时间", 0.15)
              end
              unitmove({
                unit = u.handle,
                time = 0.2,
                distance = 450,
                angle = a + 180,
                loops = {
                  {
                    looptime = 0.04,
                    func = function(dx, dy)
                      Effectcreate("war3mapImported\\nitu.mdl", dx, dy, 0, 1.5, 0, 180 + a)
                    end
                  }
                }
              })
              movexg(u.handle, 0.2, "A13A", "Q", "夜夜-Q")
            end
            if args.skill == S2ID("A17R") then
              local tilixh = 1
              local dskill = args.skill
              if u:hasbuff("缠绕") then
                u:setskillcd(dskill, 0.01)
                u:sendmessage("|cFFFF3300缠绕中|r")
                return
              end
              if not u:hasdata("位移体力消耗标记") then
                if u:lossstamina(tilixh) then
                  u:settimedata("位移体力消耗标记", 0.001)
                else
                  u:setskillcd(dskill, 0.01)
                  u:sendmessage("|cFFFF3300体力值不足|r")
                  return
                end
              end
              local x, y = u:getxy()
              u:playsound(bac64)
              local a = u:getface()
              local sh = 60 * u:getstr()
              local sh2 = 40 * u:getagi()
              u:effectadd("ATX\\[ATxNew]Daoguang_19.mdl", "origin")
              Effectcreate("war3mapImported\\nitu.mdl", x, y, 0, 1.5, 0, a)
              if not u:hasbuff("绝对闪避") then
                u:setdata("刷新W时间", 0.15)
              end
              local g = CreateGroupLua()
              unitmove({
                unit = u.handle,
                time = 0.2,
                distance = 400,
                angle = a,
                loops = {
                  {
                    looptime = 0.04,
                    func = function(dx, dy)
                      Effectcreate("war3mapImported\\nitu.mdl", dx, dy, 0, 1.5, 0, 180 + a)
                      Effectcreate("AATX\\[AATxNew]Dust07.mdl", dx, dy, 0, 0.5, 0, a)
                      for _, xq in ac.selector():in_rangexy(dx, dy, 300):is_enemy(u.handle):isnotingroup(g):ipairs() do
                        xq = getunit(xq)
                        xq:groupadd(g)
                        local t = 1
                        if not xq:isnormal() then
                          t = 0.5
                        end
                        xq:buffset(u.handle, t, "僵直")
                        DamageUnit({
                          bj = "夜夜位移",
                          unit = xq.handle,
                          source = u.handle,
                          damage = sh,
                          level = 1,
                          type = "物理",
                          isvest = false,
                          isattack = true,
                          isnoarmor = false,
                          element = "无",
                          extradata = {""}
                        })
                      end
                    end
                  }
                },
                endfunc = function(dx, dy)
                  u:setdata("位移点X", dx)
                  u:setdata("位移点Y", dy)
                  u:playsound(bac70)
                  Effectcreate("AATX\\[AATxNew]Dust15.mdl", dx, dy, 0, 2)
                  Effectcreate("AATX\\[AATxNew]Dust05.mdl", dx, dy, 0, 0.5)
                  Effectcreate("AATX\\[AATxNew]Dust08.mdl", dx, dy)
                  Effectcreate("war3mapImported\\bbb.mdl", dx, dy, 0, 3)
                  for _, xq in ac.selector():in_rangexy(dx, dy, 300):is_enemy(u.handle):ipairs() do
                    xq = getunit(xq)
                    xq:groupadd(g)
                    local t = 0.5
                    if not xq:isnormal() then
                      t = 0.1
                    end
                    xq:buffset(u.handle, t, "眩晕")
                    DamageUnit({
                      bj = "夜夜位移",
                      unit = xq.handle,
                      source = u.handle,
                      damage = sh2,
                      level = 1,
                      type = "物理",
                      isvest = false,
                      isattack = true,
                      isnoarmor = false,
                      element = "无",
                      extradata = {""}
                    })
                  end
                end
              })
              movexg(u.handle, 0.2, "A17R", "W", "夜夜-W")
            end
          end
          
          u:addtrgevent("单位-发动技能", function(args)
            skill(args)
          end)
        end
      })
      
      local function cleardata()
        if u:hasdata("夜夜-吹鸣") then
          u:deldata("夜夜-吹鸣")
          u:delskill("S04D")
          ChangeValue(Correction_RPM, sy, -0.15)
          u:changedata("闪避值", -25)
        end
        if u:hasdata("夜夜-森闲") then
          u:deldata("夜夜-森闲")
        end
        if u:hasdata("夜夜-光焰") then
          u:deldata("夜夜-光焰")
          ChangeValue(DamageSystem_Shjc, sy, -0.015)
        end
        if u:hasdata("夜夜-天险") then
          u:deldata("夜夜-天险")
          ChangeValue(DamageSystem_Ssjianshao, sy, 0.85, 2)
        end
      end
      
      local function trg(args)
        local chat = args.chat
        if chat == "吹鸣" then
          if u:hasdata("夜夜神机") or not u:hasdata("夜夜切换冷却") then
            if not u:hasdata("夜夜-吹鸣") then
              cleardata()
              u:setdata("夜夜-吹鸣")
              u:addskill("S04D")
              ChangeValue(Correction_RPM, sy, 0.15)
              u:changedata("闪避值", 25)
              u:sendmessage("|cFF7DBEF1切换至吹鸣模式|r")
              if not u:hasdata("夜夜神机") then
                u:settimedata("夜夜切换冷却", 30)
                ac.wait(30000, function()
                  u:sendmessage("|cFF7DBEF1战斗模式切换冷却完毕|r")
                end)
              end
            end
          else
            u:sendmessage("|cFF7DBEF1冷却中|r")
          end
        end
        if chat == "森闲" then
          if u:hasdata("夜夜神机") or not u:hasdata("夜夜切换冷却") then
            if not u:hasdata("夜夜-森闲") then
              cleardata()
              u:setdata("夜夜-森闲")
              u:sendmessage("|cFF7DBEF1切换至森闲模式|r")
              if not u:hasdata("夜夜神机") then
                u:settimedata("夜夜切换冷却", 30)
                ac.wait(30000, function()
                  u:sendmessage("|cFF7DBEF1战斗模式切换冷却完毕|r")
                end)
              end
            end
          else
            u:sendmessage("|cFF7DBEF1冷却中|r")
          end
        end
        if chat == "光焰" then
          if u:hasdata("夜夜神机") or not u:hasdata("夜夜切换冷却") then
            if not u:hasdata("夜夜-光焰") then
              if u:hasdata("夜夜-吹鸣") then
                u:settimedata("夜樱乱舞时间", 5)
                u:effectadd("war3mapimported\\area_honglian.mdl", "origin", 5)
              end
              cleardata()
              u:sendmessage("|cFF7DBEF1切换至光焰模式|r")
              u:setdata("夜夜-光焰")
              ChangeValue(DamageSystem_Shjc, sy, 0.015)
              if not u:hasdata("夜夜神机") then
                u:settimedata("夜夜切换冷却", 30)
                ac.wait(30000, function()
                  u:sendmessage("|cFF7DBEF1战斗模式切换冷却完毕|r")
                end)
              end
            end
          else
            u:sendmessage("|cFF7DBEF1冷却中|r")
          end
        end
        if chat == "天险" then
          if u:hasdata("夜夜神机") or not u:hasdata("夜夜切换冷却") then
            if not u:hasdata("夜夜-天险") then
              cleardata()
              u:setdata("夜夜-天险")
              u:sendmessage("|cFF7DBEF1切换至天险模式|r")
              ChangeValue(DamageSystem_Ssjianshao, sy, 0.85, 1)
              if not u:hasdata("夜夜神机") then
                u:settimedata("夜夜切换冷却", 30)
                ac.wait(30000, function()
                  u:sendmessage("|cFF7DBEF1战斗模式切换冷却完毕|r")
                end)
              end
            end
          else
            u:sendmessage("|cFF7DBEF1冷却中|r")
          end
        end
        if chat == "夜樱乱舞" and u:hasdata("夜樱乱舞时间") then
          if not u:hasdata("月影红莲冷却") then
            if lz:getpermp() >= 50 then
              u:playsound(Yeye_3)
              lz:setmp(lz:getpermp() - 50, true)
              u:effectadd("war3mapimported\\[ake]war3ake.com - 9920271026864216149596155.mdl", "origin", 15)
              u:effectadd("war3mapimported\\[ake]war3ake.com - 7144121232703075945564515.mdl", "origin", 15)
              u:effectadd("war3mapimported\\1527.mdl")
              u:effectadd("Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl")
              u:settimedata("月影红莲", 15)
              ChangeTimeValue(DamageSystem_Shjc, sy, 0.05, 15)
              u:settimedata("月影红莲冷却", 480)
              u:sendmessage("|cFF7DBEF1480秒后可以再次尝试释放月影红莲|r")
              ac.wait(480000, function()
                u:sendmessage("|cFF7DBEF1月影红莲冷却完毕|r")
              end)
            else
              u:sendmessage("|cFF7DBEF1雷真魔力不足|r")
            end
          else
            u:sendmessage("|cFF7DBEF1冷却中|r")
          end
        end
        if chat == "神机启" then
          if not u:hasdata("神机冷却") and not u:hasdata("夜夜神机") and not u:hasdata("夜夜觉醒") then
            u:setdata("夜夜神机")
            u:addskill("S04G")
            u:settimedata("神机冷却", 60)
            ChangeValue(DamageSystem_Shjc, sy, 0.03)
            u:sendmessage("|cFF7DBEF1神机开启|r")
            ac.loop(1000, function(timer)
              if u:isalive() and lz:getperhp() >= 5 and not u:hasdata("夜夜觉醒") and u:hasdata("夜夜神机") then
                lz:sethp(lz:getperhp() - 2.5, true)
              else
                u:delskill("S04G")
                u:deldata("夜夜神机")
                ChangeValue(DamageSystem_Shjc, sy, -0.03)
                timer:remove()
              end
            end)
            ac.wait(60000, function()
              u:sendmessage("|cFF7DBEF1神机冷却完毕|r")
            end)
          else
            u:sendmessage("|cFF7DBEF1无法释放|r")
          end
        end
        if chat == "月影红莲" and u:hasdata("夜夜神机") and not u:hasdata("夜夜觉醒") then
          u:playsound(Yeye_4)
          local x, y = u:getxy()
          Effectcreate("war3mapimported\\skybigbang.mdl", x, y)
          Effectcreate("war3mapimported\\meteorstrike.mdx", x, y)
          local tx1 = u:effectadd("war3mapimported\\41.mdl", "origin", -1)
          u:setdata("夜夜觉醒")
          u:changedata("夜夜觉醒次数", 1)
          ChangeValue(DamageSystem_Shjc, sy, 0.05)
          ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 125)
          lz:sethp(100, true)
          local dcs = 0
          local cs2 = 0
          local cs3 = 0
          local cs4 = 0
          ac.loop(20, function(timer)
            dcs = dcs + 1
            dcs = dcs + 1
            cs2 = cs2 + 1
            cs3 = cs3 + 1
            cs4 = cs4 + 1
            if cs2 == 25 then
              cs2 = 0
              local x, y = u:getxy()
              Effectcreate("war3mapimported\\k3_tx (2).mdl", x, y)
            end
            if cs4 == 15 then
              cs4 = 0
              u:effectadd("war3mapImported\\[TX] (757).mdl", "origin")
            end
            if cs3 == 5 then
              cs3 = 0
              u:changemaxhp(-1)
              u:changedata("夜夜觉醒狂暴度", 1)
              ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 1)
            end
            if u:isalive() and dcs <= 9000 then
              lz:setmp(100, true)
              u:clearbuff()
            else
              ChangeValue(DamageSystem_Shjc, sy, -0.05)
              ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -125 - u:getdata("夜夜觉醒狂暴度"))
              u:deldata("夜夜觉醒")
              u:deldata("夜夜觉醒狂暴度")
              u:addstr(-1 * u:getdata("夜夜觉醒力量增强"))
              u:addagi(-1 * u:getdata("夜夜觉醒敏捷增强"))
              u:deldata("夜夜觉醒力量增强")
              u:deldata("夜夜觉醒敏捷增强")
              DestroyEffectLua(tx1)
              timer:remove()
            end
          end)
        end
        if chat == "神机闭" then
          u:deldata("夜夜神机")
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        trg(args)
      end)
    end,
    effectname = "|cFFFFFF00机|r|cFFFFCC00巧|r|cFFFF9900少|r|cFFFF6600女|r",
    effecttext = "|cFFFFFF00机械 唯一\n金|r|cFFFFBF00刚|r|cFFFF8000力|r\n|cFFFFFF33夜夜的魔术回路|r|cFFFFCC29是被称为世界上最坚硬的|r|cFFFF991F魔术回路|r|cFFFF6614「金刚力」|r\n|cFFFFFF00禁|r|cFFFFCC00忌|r|cFFFF9900人|r|cFFFF6600偶|r\n|cFFFFFF33夜夜|r|cFFFFCC29有着|r|cFFFF991F不同的|r|cFFFF6614战斗模式|r\n|cFFFFFF00神|r|cFFFFAA00机|r\n|cFFFFFF00[|r|cFFFFDB00数|r|cFFFFB600据|r|cFFFF9200删|r|cFFFF6D00除|r|cFFFF4900]|r",
    effectart = "war3mapImported\\BTNYeye_2.blp",
    test = [[

    ]]
  },
  {
    name = "卫宫士郎",
    weight = 5,
    key = {
      "唯一",
      "战士",
      "光明"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("圣杯残片已使用过") then
        add = add + 1200
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-卫宫士郎") or u:hasdata("圣杯残片已使用过") and (u:hasdata("变异判定-正义的伙伴") or u:hasdata("切嗣的继承")) then
        b = true
      end
      if not u:ishasshw() or u:hasdata("特殊判定-天之杯") or u:hasdata("变异判定-恶兆之花") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:reduceshw()
      NameID[sy] = "|cFFFF0000卫|r|cFFFF1F00宫|r|cFFFF3D00士|r|cFFFF5C00郎|r"
      u:setplayername(NameID[sy])
      PlayGlobalSound(BGM_Shirou_01)
      PlayBGM({
        bgm = 0,
        time = 155,
        ID = 60,
        unit = u.handle
      })
      u:chat("即使我的人生")
      ac.wait(1800, function()
        u:chat("充满伪善")
      end)
      ac.wait(7900, function()
        u:chat("我也要——")
      end)
      ac.wait(9200, function()
        u:chat("坚持成为正义的伙伴")
      end)
      ChangeValue(Correction_Gun, sy, 0.125)
      ChangeValue(Correction_Jzsh, sy, 0.125)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 50)
      ChangeValue(DamageSystem_LwSs, sy, 1.2, 1)
      if CIUC[sy] == "-762434993" then
        local bb = getunit(Beibao[sy])
        bb:additem("I08Y")
      end
      ac.loop(1000, function(timer)
        if u:hasdata("圣杯残片已使用过") then
          table.insert(u:getdata("士郎-投影列表"), S2ID("I0A5"))
          timer:remove()
        end
      end)
      ac.loop(1000, function(timer)
        if u:isalive() and u:hasdata("士郎-圣骸布进阶标记") and not u:hasdata("士郎-圣骸布") then
          u:setdata("士郎-圣骸布")
          u:deldata("士郎-圣骸布进阶标记")
          ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
          ChangeValue(DamageSystem_LwSs, sy, 1.2, 2)
          ChangeValue(DamageSystem_Ssjianshao, sy, 0.8, 1)
          ChangeValue(DamageSystem_Baoji, sy, 15)
          ChangeValue(DamageSystem_Baoshang, sy, 0.3)
          ChangeValue(DamageSystem_Shjc, sy, 0.1)
          u:setdata("|cFF33CCCC圣骸布进阶|r")
          u:uivar_change({
            keyname = "卫宫士郎",
            keytype = "传奇栏",
            text = "|cFFFF0000卫|r|cFFFF1F00宫|r|cFFFF3D00士|r|cFFFF5C00郎|r\n|cFFFF3300唯一 战士 光明\n魔术回路-士郎|r\n|cFFFF7000提升125%枪械修正\n提升125%近战修正|r\n|cFFFF3300起源-剑|r\n|cFFFF7000提升50%剑类武器伤害\n提升30%剑类武器攻击范围|r\n|cFFFF3300料理达人|r\n|cFFFF7000提升食物100%恢复效果\n食用食物后180S内提升0.1体力恢复与5%力量（不叠加，重复使用刷新计时）|r\n|cFFFF3300强化魔术|r\n|cFFFF7000允许使用[强化魔术]|r\n|cFFFF3300圣马丁的圣骸布|r\n|cFFFF7000杀死单位时5%提升1点力量 5%提升1点敏捷\n提升15%暴击率与30%暴击伤害\n提升10%伤害加成\n提升30%所有武器伤害\n提升3%近战伤害\n提升20%论外减伤\n提升75额外移速\n杀敌时在18秒内提升0.1%伤害加成，可叠加，分立计时|r|r\n|cFFFF3300投影魔术|r\n|cFFFF7000允许使用[投影魔术]|r"
          })
          timer:remove()
        end
      end)
      u:setdata("士郎-强化魔术冷却", 60)
      local dskill = S2ID("A19A")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local target = args.target
          local wptype = GetItemTypeId(target)
          local prio = tonumber(slk.item[ID2S(wptype)].prio)
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if 1 <= prio and prio <= 11 then
          else
            b = false
            u:sendmessage("|cFF7DBEF1目标不为武器|r")
          end
          if b then
            u:changedata("士郎-强化魔术冷却", 10)
            ewl:setskilldatareal("A19A", "施法间隔", u:getdata("士郎-强化魔术冷却"))
            ewl:setskillcd("A19A", u:getdata("士郎-强化魔术冷却"))
            local add = u:getdata("士郎-物品强化次数")
            u:chat("同调 开始")
            local yxz = {
              Sound_Shirou_01,
              Sound_Shirou_06,
              Sound_Shirou_08
            }
            local jl = 50 - 5 * add
            if HasData(target, "士郎-投影武器") then
              jl = jl * 2
            end
            if GetRandom100(jl) then
              u:sendmessage("|cFF7DBEF1强化成功|r")
              u:changedata("士郎-物品强化次数", 1)
              if HasData(target, "士郎-投影武器") then
                ChangeData(target, "士郎-物品强化属性", 0.1)
              else
                ChangeData(target, "士郎-物品强化属性", 0.05)
              end
            else
              u:sendmessage("|cFF7DBEF1强化失败|r")
            end
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      u:setdata("士郎-投影列表", {})
      u:setdata("士郎-投影武器", 0)
      
      local function trg(args)
        if u:hasdata("投影状态") then
          u:deldata("投影状态")
          local count = tonumber(args.chat)
          local zu = u:getdata("士郎-投影列表")
          if zu[count] then
            local wptype = zu[count]
            if u:getdata("士郎-投影武器") ~= 0 then
              ForGroupLuaNew(Group_AllHero, function(xq)
                local sy2 = xq.ownerid
                local wq = xq:getdata("装备武器")
                if wq == u:getdata("士郎-投影武器") then
                  weapondown(xq.handle, false, true)
                end
                if xq:ishasspeitem(wq) then
                  xq:dropitem(wq)
                end
              end)
              RemoveItemLua(u:getdata("士郎-投影武器"))
            end
            local nwp = u:additem(wptype)
            u:setdata("士郎-投影武器", nwp)
            SetData(nwp, "士郎-投影武器")
            u:sendmessage("|cFF7DBEF1投影成功|r" .. slk.item[ID2S(wptype)].Name)
          else
            u:sendmessage("|cFF7DBEF1不存在的序号|r")
          end
        end
        if args.chat == "投影 开始" then
          local b = true
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if u:hasdata("投影冷却") then
            b = false
            u:sendmessage("|cFF7DBEF1冷却中|r")
          end
          if b then
            if 0 < #u:getdata("士郎-投影列表") then
              u:sendmessage("|cFF6699FF可投影武器列表:")
              local cs = 0
              local i = 0
              local str = ""
              for index, value in ipairs(u:getdata("士郎-投影列表")) do
                i = i + 1
                cs = cs + 1
                str = str .. i .. "." .. slk.item[value].Name .. " "
                if cs == 5 then
                  cs = 0
                  str = str .. "\r"
                end
              end
              u:sendmessage(str)
              u:sendmessage("|cFF6699FF投影开始后输入武器序列投影")
            else
              u:sendmessage("|cFF7DBEF1无可投影神兵|r")
            end
            local yxz = {
              Sound_Shirou_01,
              Sound_Shirou_06,
              Sound_Shirou_08,
              Sound_Shirou_02,
              Sound_Shirou_03,
              Sound_Shirou_04,
              Sound_Shirou_05
            }
            if u:getperhp() <= 25 then
              u:playsound(yxz[GetRandomInt(1, 7)])
            else
              u:playsound(yxz[GetRandomInt(1, 3)])
            end
            u:settimedata("投影冷却", 30)
            local x, y = u:getxy()
            Effectcreate("ATX\\[ATxNew]Red_23.mdl", x, y, 0, 2)
            ac.wait(1000, function()
              u:settimedata("投影状态", 10)
              u:setdata("投影特效", u:effectadd("ATX\\[ATxNew]Fire_01.mdl", "origin", -1))
              ac.wait(10000, function()
                if u:hasdata("投影特效") then
                  DestroyEffectLua(u:getdata("投影特效"))
                  u:deldata("投影特效")
                end
              end)
            end)
          end
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        trg(args)
      end)
      local dskill = S2ID("A19B")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            if #u:getdata("士郎-投影列表") > 0 then
              u:sendmessage("|cFF6699FF可投影武器列表:")
              local cs = 0
              local i = 0
              local str = ""
              for index, value in ipairs(u:getdata("士郎-投影列表")) do
                i = i + 1
                cs = cs + 1
                str = str .. i .. "." .. slk.item[value].Name .. " "
                if cs == 5 then
                  cs = 0
                  str = str .. "\r"
                end
              end
              u:sendmessage(str)
              u:sendmessage("|cFF6699FF投影开始后输入武器序列投影")
            else
              u:sendmessage("|cFF7DBEF1无可投影神兵|r")
            end
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
    end,
    effectname = "|cFFFF0000卫|r|cFFFF1F00宫|r|cFFFF3D00士|r|cFFFF5C00郎|r",
    effecttext = "|cFFFF3300唯一 战士 光明\n魔术回路-士郎|r\n|cFFFF7000提升125%枪械修正\n提升125%近战修正|r\n|cFFFF3300起源-剑|r\n|cFFFF7000提升25%剑类武器伤害\n提升15%剑类武器攻击范围|r\n|cFFFF3300料理达人|r\n|cFFFF7000提升食物100%恢复效果\n食用食物后180S内提升0.1体力恢复与5%力量（不叠加，重复使用刷新计时）|r\n|cFFFF3300强化魔术|r\n|cFFFF7000允许使用[强化魔术]|r\n|cFFFF3300圣马丁的圣骸布 - [获取后杀敌200进阶]|r\n|cFFFF7000杀死单位时5%提升1点力量 5%提升1点敏捷\n提升20%所有武器伤害\n提升2%近战伤害\n提升20%论外受伤\n提升50额外移速|r\n|cFFFF3300投影魔术|r\n|cFFFF7000允许使用[投影魔术]|r",
    effectart = "war3mapImported\\BTNEwl_Shirou.blp",
    test = [[

        ]]
  },
  {
    name = "流氓巨星",
    weight = 5,
    key = {
      "唯一",
      "战士",
      "光明",
      "替身使者",
      "黄金精神"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I04N") then
        add = add + 5000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:ishasitem("I04N") and u:hasdata("判定-茸茸") then
        b = true
      end
      if not u:hasdata("系统-特殊获取中") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_RR_101)
      SendDtimeMsgAll(1, "|cFFFFFF66『我乔鲁诺·乔巴纳有一个梦想！』|r")
      SendDtimeMsgAll(4.7, "|cFFFFFF66『我』|r")
      SendDtimeMsgAll(6, "|cFFFFFF66『要成为「Gang Star」』|r")
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 1)
          local txsh = 0.75 * info.yssh
          if u:hasdata("变异判定-黄金体验") then
            txsh = txsh * 2
          end
          local dx, dy = tg:getxy()
          for _, xq in ac.selector():in_rangexy(dx, dy, 600):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "茸茸附伤",
              unit = tg.handle,
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
      end)
      u:addstexiao(var.name, "受伤后效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if args.damage >= 100 and tg.handle ~= u.handle and not u:hasdata(var.name .. "-黄金体验冷却") then
          local gl = 20
          local dtime = 1000
          local cd = 1
          if u:hasdata("变异判定-黄金体验镇魂曲") then
            gl = 75
            cd = 0.5
            dtime = 333
            u:playsound(Sound_Touma_01)
            local yxz = {
              Sound_Rongrong_N02,
              Sound_Rongrong_N06,
              Sound_Rongrong_N08,
              Sound_Rongrong_N14
            }
            u:playsound(yxz[GetRandomInt(1, #yxz)])
          elseif u:hasdata("变异判定-黄金体验") then
            gl = gl * 2
          end
          if u:getluckrandom(gl) then
            u:settimedata(var.name .. "-黄金体验冷却", cd)
            local curehp = 0.333 * args.damage
            local cs = 0
            ac.loop(dtime, function(timer)
              cs = cs + 1
              u:curehp(u.handle, curehp, 0, 2)
              if cs == 3 then
                timer:remove()
              end
            end)
          end
        end
      end)
      u:changedata("闪避值", 10)
      ChangeValue(Hero_Tili_Huifu, sy, 0.1)
      ChangeValue(DamageSystem_Baoji, sy, 10)
      ChangeValue(DamageSystem_Baoshang, sy, 0.1)
      local ewys = 0
      local add = 0
      ac.loop(3000, function()
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -ewys)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        ewys = 3 * u:getlevel()
        add = 0.01 * u:getlevel() + 0.002 * u:getstr()
        if u:hasdata("变异判定-黄金体验镇魂曲") then
          add = add * 3
          ewys = ewys * 3
        elseif u:hasdata("变异判定-黄金体验") then
          add = 0.02 * u:getlevel() + 0.006 * u:getstr()
          ewys = ewys * 2
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, ewys)
      end)
    end,
    effectname = "|cFFFF66CC替身.流氓巨星|r",
    effecttext = "|cFFFF66CC唯一 战士 光明 替身使者 黄金精神\n速度A|r\n|cFFFF66CC成长A|r\n|cFFFF66CC破坏力C|r\n|cFFFF66CC持久力D|r\n|cFFFF66CC射程C|r\n|cFFFF66CC精密度C|r\n|cFFFF66CC黄金体验|r\n|cFFFF99CC乔鲁诺能够利用制造生命的能力将物体变成身体元件，\n透过将制造出的元件补在伤口上来进行治疗|r",
    effectart = "war3mapImported\\BTNEwl_Qiaolunuo1.blp",
    test = [[

    ]]
  },
  {
    name = "刀仕禰宜",
    weight = 5,
    key = {
      "唯一",
      "战士",
      "白毛",
      "炎"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:ishasitem("I0GW") and u:hasdata("判定-椿") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Chun_01)
      SendJbMsgAll({
        strstart = "|cFFCCFFFF『",
        strz = "对被朱雀院家名束缚的人而言，",
        strend = "』|r",
        time = 2,
        shunxu = 1,
        waittime = 0
      })
      SendJbMsgAll({
        strstart = "|cFFCCFFFF『对被朱雀院家名束缚的人而言，",
        strz = "活着就是修行刃道，",
        strend = "』|r",
        time = 3.7,
        shunxu = 1,
        waittime = 2.3
      })
      SendJbMsgAll({
        strstart = "|cFFCCFFFF『对被朱雀院家名束缚的人而言，活着就是修行刃道，",
        strz = "没有其他的道路。",
        strend = "』|r",
        time = 1.6,
        shunxu = 1,
        waittime = 6.3
      })
      PlayBGM({
        bgm = 0,
        time = 263,
        ID = 194,
        unit = u.handle
      })
      ac.wait(8000, function()
        PlayGlobalSound(BGM_Chun_100)
      end)
      ChangeValue(Correction_Jzsh, sy, 0.010000000000000002)
      ChangeValue(DamageSystem_Baoji, sy, 10)
      ChangeValue(DamageSystem_Baoshang, sy, 0.1)
      u:addskill("S07H")
      local g = CreateGroupLua()
      local gl = 0
      local jz = 0
      local gs = 0
      local jzsh = 0
      local zs = 0
      local bs = 0
      ac.loop(500, function()
        ChangeValue(Correction_Jzsh, sy, 0.1 * -jz)
        ChangeValue(DamageSystem_Baoshang, sy, -jz)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -zs)
        ChangeValue(Correction_Jzsh, sy, 0.1 * -jzsh)
        u:changedata("固定伤害", 0.1 * -gs)
        jz = 0.03 * u:getstate("战士变异")
        jzsh = 5.0E-4 * KillCount[sy]
        zs = 0.1 * u:getstate("战士变异")
        gs = 1000 * u:getstate("战士变异")
        if u:hasdata("朱雀院椿-禁忌化") then
          jz = jz * 3
          jzsh = jzsh * 3
          zs = zs * 3
          gs = gs * 3
        elseif u:hasdata("变异判定-朱雀院椿") then
          jz = jz * 2
          jzsh = jzsh * 2
          zs = zs * 2
          gs = gs * 2
        end
        if u:hasdata("变异判定-朱雀院红叶") then
          jzsh = jzsh + 5.0E-4 * KillCount[sy]
          zs = zs + 0.1 * u:getstate("战士变异")
        end
        ChangeValue(Correction_Jzsh, sy, 0.1 * jzsh)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * zs)
        ChangeValue(Correction_Jzsh, sy, 0.1 * jz)
        ChangeValue(DamageSystem_Baoshang, sy, jz)
        u:changedata("固定伤害", 0.1 * gs)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * -gl)
        gl = 0
        if u:hasdata("朱雀院椿-BOSS战") then
          gl = gl + 0.2
        end
        if u:hasdata("椿-折纸浴火鸟") and u:hasdata("环境-怒炎") then
          gl = gl + 0.1
        end
        if u:hasdata("朱雀院椿-禁忌化") then
          gl = gl + 0.36 - 0.03 * Group_Counts(Group_Xingcunzu)
        end
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * gl)
        local txsh = u:getallattri() * (100 + u:getlevel())
        if u:hasdata("朱雀院椿-禁忌化") then
          txsh = txsh * 3
        elseif u:hasdata("变异判定-朱雀院椿") then
          txsh = txsh * 2
        end
        ForGroupLuaNew(g, function(xq)
          if xq:hasdata("椿-炎姬灼烧") then
            if u:hasdata("变异判定-朱雀院椿") then
              u:setdata("系统-本次伤害无视伤害免疫")
            end
            DamageUnit({
              bj = "椿灼烧",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "灵力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "火",
              extradata = {""}
            })
            if u:hasdata("变异判定-朱雀院椿") then
              u:deldata("系统-本次伤害无视伤害免疫")
            end
          else
            xq:groupremove(g)
          end
        end)
      end)
      u:addstexiao(var.name, "近战伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not tg:hasdata("椿-近战杀敌判定") then
          tg:setdata("椿-近战杀敌判定")
          ac.wait(30, function()
            tg:deldata("椿-近战杀敌判定")
            if not tg:isalive() then
              if u:hasdata("变异判定-朱雀院椿") then
                ChangeValue(DamageSystem_Shjc, sy, 1.0E-4)
                if tg:isboss() then
                  u:changemaxhp(300)
                elseif tg:iselite() then
                  u:changemaxhp(50)
                else
                  u:changemaxhp(1)
                end
              else
                ChangeValue(DamageSystem_Shjc, sy, 5.0E-5)
                u:changemaxhp(1)
              end
              if u:hasdata("朱雀院椿-禁忌化") and GetRandom100(5) then
                ChangeValue(DamageSystem_Shjc, sy, 0.001)
                u:addallstats(1)
              end
            end
          end)
        end
        if not info.isvestdamage then
          local x, y = tg:getxy()
          if not u:hasdata("椿-二刀流冷却") then
            u:settimedata("椿-二刀流冷却", 1)
            modelchange({
              unit = u.handle,
              model = "Hero\\Hero_Chun.mdl",
              modelsize = 1.03,
              modelact = 11,
              modelactspeed = 1,
              time = 0.5,
              sfunc = function(mj)
                Effectcreate("war3mapImported\\blackblink.mdx", x, y)
              end,
              efunc = function(mj)
                local x, y = tg:getxy()
                Effectcreate("war3mapImported\\blackblink.mdx", x, y)
              end
            })
            local txsh = u:getstate("战士变异") * u:getlevel() * u:getallattri()
            if u:hasdata("朱雀院椿-禁忌化") then
              txsh = txsh * 3
            elseif u:hasdata("变异判定-朱雀院椿") then
              txsh = txsh * 2
            end
            if u:hasdata("变异判定-朱雀院椿") then
              u:playsound(bac139)
              local x2, y2 = u:getxy()
              local a = AngleXY(x2, y2, x, y)
              local a2 = a + 183
              local a3 = a - 90
              local x3, y3 = PolarXY(x2, y2, 40, a3)
              Effectcreate("0Tx\\0Tx_Chun (16).mdl", x3, y3, 0, 1, 50, a2)
              local a2 = a + 177
              local a3 = a + 90
              local x3, y3 = PolarXY(x2, y2, 40, a3)
              Effectcreate("0Tx\\0Tx_Chun (16).mdl", x3, y3, 0, 1, 50, a2)
              local g2 = CreateGroupLua()
              for i = 1, 20 do
                local jl = 50 * i
                local x4, y4 = PolarXY(x2, y2, jl, a)
                for _, xq in ac.selector():in_rangexy(x4, y4, 120):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  xq:buffset(u.handle, 0.5, "暂停")
                  xq:animespeed(0)
                  xq:groupadd(g2)
                end
              end
              ac.wait(500, function()
                u:playsound(bac73)
                ForGroupLuaNew(g2, function(xq)
                  xq:animespeed(1)
                  xq:buffset(u.handle, 0.5, "眩晕")
                  xq:effectadd("0Tx\\0Tx_Chun (13).mdl")
                  DamageUnit({
                    bj = "椿附伤",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 1,
                    type = "物理",
                    isvest = true,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {
                      "系统-本次伤害无视伤害免疫",
                      "近战"
                    }
                  })
                end)
              end)
            else
              Effectcreate("0Tx\\0Tx_Chun (13).mdl", x, y, 0, 1.5)
              u:playsound(bac73)
              DamageUnit({
                bj = "椿附伤",
                unit = tg.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "物理",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "无",
                extradata = {""}
              })
            end
          end
          if not tg:hasdata("椿-炎姬灼烧") then
            do
              local jl
              if u:hasdata("变异判定-朱雀院椿") then
                jl = 20
              else
                jl = 10
              end
              if u:hasdata("椿-折纸无铭") then
                jl = jl * 2
              end
              if u:hasdata("椿-里炎姬") then
                jl = jl * 2
              end
              if GetRandom100(jl) then
                tg:groupadd(g)
                tg:effectadd("0Tx\\0Tx_Chun (3).mdl")
                tg:effectadd("0Tx\\0Tx_Chun (1).mdl", "chest", 3)
                if not u:hasdata("椿-炎姬音效冷却") then
                  u:playsound(Sound_Chun_02)
                  u:settimedata("椿-炎姬音效冷却", 5)
                end
                tg:playsound(bac80)
                tg:settimedata("椿-炎姬灼烧", 3)
                if u:hasdata("朱雀院椿-禁忌化") then
                  tg:changetimedata("火属性抗性", -3, 3)
                elseif u:hasdata("变异判定-朱雀院椿") then
                  tg:changetimedata("火属性抗性", -2, 3)
                else
                  tg:changetimedata("火属性抗性", -1, 3)
                end
              end
            end
          end
        end
      end)
    end,
    effectname = "|cFFCCFFFF刀|r|cFFD6CCCC仕|r|cFFE09999襧|r|cFFEB6666宜|r",
    effecttext = "|cFFEB6666唯一 炎 战士 白毛\n武艺者|r\n|cFFD6CCCC[数据删除]|r\n|cFFEB6666心眼(伪)|r\n|cFFD6CCCC[数据删除]|r\n|cFFEB6666二刀流|r\n|cFFD6CCCC[数据删除]|r\n|cFFEB6666炎姬|r\n|cFFD6CCCC[数据删除]|r",
    effectart = "war3mapImported\\BTNEwl_Chun_03",
    test = [[

    ]]
  },
  {
    name = "特里诺",
    weight = 5,
    key = {
      "唯一",
      "白毛",
      "光明"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I0AC") then
        add = add + 1000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-特里诺") and u:ishasitem("I0AC") then
        b = true
      end
      if not u:ishasshw() then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cFFFFCC33将希望引导向未来……|r")
      u:reduceshw()
      ChangeValue(Damage_ElementRes_All, sy, 15)
      u:setplayername("|cFF7DBEF1[|r|cFFFFCC33トリノライン|r|cFF7DBEF1]|r" .. NameID[sy])
      ChangeValue(Correction_HealUp, sy, 0.25)
      ChangeValue(KillReward_MHp, sy, 1)
      Qiyue_Troline_Zishen = u.handle
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        local x, y = u:getxy()
        local x2, y2 = tg:getxy()
        if not u:hasdata("特效冷却-特里诺") and Group_Counts(Group_Xingcunzu) <= 1 then
          u:settimedata("特效冷却-特里诺", 0.25)
          tg:effectadd("AATX\\[AATxNew]White10.mdl", "origin")
          DamageUnit({
            bj = "特里诺附伤",
            unit = tg.handle,
            source = u.handle,
            damage = 0.5 * u:getmaxhp(),
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无",
            extradata = {""}
          })
        end
        if u:getluckrandom(5 * info.txgl) and not u:hasdata("特效2冷却-特里诺") then
          Effectcreate("war3mapImported\\ancientexplodeb.mdx", x2, y2)
          local txsh = 10 * u:getmaxhp()
          u:settimedata("特效2冷却-特里诺", 0.5)
          for _, xq in ac.selector():in_rangexy(x2, y2, 250):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "特里诺附伤",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
          end
        end
      end)
      local exp = 0
      local up = 0
      local hp = 0
      local bb = getunit(Beibao[sy])
      ac.loop(3000, function()
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, -hp)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -up)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -up)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -up)
        ChangeValue(Correction_Exp, sy, -2 * exp)
        hp = 0.5 + 0.03 * u:getlevel()
        up = u:getmaxhp() / 100000
        exp = 0.015 * (Group_Counts(Group_Xingcunzu) - 1)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * up)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * up)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * up)
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, hp)
        ChangeValue(Correction_Exp, sy, 2 * exp)
      end)
      
      local function trg(args)
        local chat = string.sub(args.chat, 1, 2)
        if chat == "-t" then
          if string.len(args.chat) >= 3 then
            local sy2 = tonumber(string.sub(args.chat, 3, 3))
            if Hero[sy2] ~= 0 and Hero[sy2] ~= u.handle and getunit(Hero[sy2]):isalive() and not u:hasdata("特里诺-契约对象") then
              local tg = getunit(Hero[sy2])
              tg:sendmessage("|cFFF7C295你成为了契约对象|r")
              tg:setdata("特里诺-契约对象")
              u:setdata("特里诺-契约自身")
              Qiyue_Troline_Duixiang = tg.handle
              Qiyue_Troline_Zishen = u.handle
              u:addskill("S004")
              tg:addskill("S00W")
              u:changearmor(15)
              u:changedata("幸运", 2)
              tg:changedata("幸运", 2)
              tg:changearmor(15)
              ChangeValue(DamageSystem_Shjc, sy, 0.015)
              ChangeValue(DamageSystem_Shjc, sy, 0.015)
              ChangeValue(DamageSystem_Ssjianshao, sy, 0.85, 1)
              ChangeValue(DamageSystem_Baoji, sy, 5)
              ChangeValue(DamageSystem_Baoshang, sy, 0.15)
              ChangeValue(DamageSystem_Shjc, sy2, 0.015)
              ChangeValue(DamageSystem_Shjc, sy2, 0.015)
              ChangeValue(DamageSystem_Ssjianshao, sy2, 0.85, 1)
              ChangeValue(DamageSystem_Baoji, sy2, 5)
              ChangeValue(DamageSystem_Baoshang, sy2, 0.15)
            else
              u:sendmessage("目标不合法")
            end
          else
            u:sendmessage("指令错误")
          end
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        trg(args)
      end)
    end,
    effectname = "|cFFFFFF00Trinoline|r",
    effecttext = "|cFF1FBF00光明 白毛 唯一\nアンドロイド三原则|r\n|cFFFFFF00[数据删除]|r\n|cFF1FBF00アンドロイドの誓言|r\n|cFFFFFF00[数据删除]|r\n|cFF1FBF00希望の未来|r\n|cFFFFFF00[数据删除]|r\n|cFF1FBF00未知的心情|r\n|cFFFFFF00[数据删除]|r\n|cFF1FBF00宛若小鸟般的灵魂|r\n|cFFFFFF00[数据删除]|r",
    effectart = "war3mapImported\\BTNEwl_Trinoline.blp",
    test = "    "
  },
  {
    name = "虹猫",
    clickfunc = function(u, button)
      if not u:hasdata("虹猫-火舞旋风关闭") then
        u:sendmessage("|cFFCC0000火舞旋风关闭|r")
        u:setdata("虹猫-火舞旋风关闭")
      else
        u:sendmessage("|cFFCC0000火舞旋风开启|r")
        u:deldata("虹猫-火舞旋风关闭")
      end
    end,
    weight = 5,
    key = {
      "唯一",
      "战士",
      "光明"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("物品-灵鸽小七") then
        add = add + 3000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-虹猫") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      for index, value in ipairs(Pools_Spe) do
        if value.name == "灵鸽小七" then
          if not value.hasbeenget then
            u:additem("I0L3")
            value.hasbeenget = true
          end
          break
        end
      end
      for index, value in ipairs(Pools_SpeDzWeapon) do
        if value.name == "长虹剑" then
          if not value.hasbeenget then
            local item = u:additem("I0KK")
            System_Count_Weapon = System_Count_Weapon + 1
            SetData(item, "物品判定-神兵")
            SetData(item, "神兵-获取")
            value.hasbeenget = true
          end
          break
        end
      end
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效2冷却") then
          u:settimedata(var.name .. "-特效2冷却", 0.6)
          local x, y = tg:getxy()
          local txsh = 10000 * u:getdata("虹猫-七剑数量")
          for _, xq in ac.selector():in_rangexy(x, y, 325):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "虹猫附伤",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "灵力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "火"
            })
          end
        end
        if not u:hasdata("虹猫-火舞旋风关闭") and not u:hasdata(var.name .. "-特效冷却") then
          local x, y = tg:getxy()
          Effectcreate("Hongmao_01.mdx", x, y, 2, 4)
          local down = 0.9 * u:gethp()
          local txsh = down + u:getlevel() * 500 + u:getstate("光明变异") * 5000
          u:settimedata(var.name .. "-特效冷却", 360)
          u:sethp(1, true)
          u:setmp(1, true)
          Hero_Tili[sy] = 0.01 * Hero_Tili_Max[sy]
          u:effectadd("Hongmao_2.mdx", "origin", 10)
          u:settimedata("虹猫-死亡抗拒", 10)
          for _, xq in ac.selector():in_rangexy(x, y, 600):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "虹猫火舞旋风",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "物理",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "火"
            })
          end
        end
        if u:hasdata("虹猫-冰魄剑") then
          if not u:hasdata("冰魄剑-特效冷却") then
            u:settimedata("冰魄剑-特效冷却", 0.3)
            local txsh = 10000 * u:getdata("虹猫-七剑数量")
            DamageUnit({
              bj = "虹猫冰魄剑附伤",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "灵力",
              isvest = true,
              isattack = true,
              isnoarmor = false,
              element = "冰"
            })
          end
          if not u:hasdata("冰魄剑-特效2冷却") then
            u:settimedata("冰魄剑-特效2冷却", 1)
            tg:buffset(u.handle, 1, "冰冻")
          end
        end
        if u:hasdata("虹猫-青光剑") and not tg:hasdata("青光剑-已伤害") then
          tg:setdata("青光剑-已伤害")
          local de = 10
          if not tg:isnormal() then
            de = 3
          end
          LossHpUnit({
            u = u,
            tg = tg,
            damage = 0,
            perhp = de,
            maxhp = 0,
            bj = "[生命损耗]青光剑"
          })
        end
        if u:hasdata("虹猫-雨花剑") and not tg:hasdata("雨花剑-已伤害") then
          tg:setdata("雨花剑-已伤害")
          tg:changedata("怪物-额外受伤", 0.1)
        end
        if u:hasdata("虹猫-奔雷剑") and not u:hasdata("奔雷剑-冷却") then
          u:settimedata("奔雷剑-冷却", 0.1)
          ChangeTimeValue(DamageSystem_Baoshang, sy, 0.01, 5)
        end
      end)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        u:changemaxhp(500)
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        if tg:iselite() then
          ChangeValue(Correction_Jzsh, sy, 0.002)
        end
        if not u:hasdata("神化判定-虹猫") and u:getperhp() <= 10 and u:ishasshw() then
          local jl = 0.25 + (10 - u:getperhp()) / 10
          if GetRandom100(jl) then
            AdvanceGet["虹猫神化"](u)
          end
        end
      end)
      u:setdata("系统-无视伤害免疫")
      ChangeValue(DamageSystem_Baoji, sy, 10)
      ChangeValue(DamageSystem_Baoshang, sy, 0.2)
      ChangeValue(Correction_Jzsh, sy, 0.05)
      local jz = 0
      local jc = 0
      local tili = 0
      local lw = 0
      local cgl = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Jzsh, sy, 0.1 * -jz)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jc)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -lw)
        ChangeValue(Hero_Tili_Huifu, sy, -tili)
        ChangeValue(Correction_MEDCgl, sy, -cgl)
        if u:hasdata("神化判定-虹猫") then
          jz = 0.2 * u:getstate("光明变异")
        else
          jz = 0.1 * u:getstate("光明变异")
        end
        if u:hasdata("虹猫-青光剑") then
          jc = 0.1 * u:getdata("虹猫-七剑数量")
          jz = jz + 0.05 * (Correction_Magic[sy] - 1)
        else
          jc = 0
        end
        if u:hasdata("虹猫-旋风剑") then
          tili = 0.02 * u:getdata("虹猫-七剑数量")
        else
          tili = 0
        end
        if u:hasdata("虹猫-奔雷剑") then
          if u:hasdata("环境-雷鸣") then
            lw = 0.5
          else
            lw = 0
          end
        else
          lw = 0
        end
        if u:hasdata("虹猫-紫云剑") then
          cgl = 0.02 * u:getdata("虹猫-七剑数量")
        else
          cgl = 0
        end
        ChangeValue(Correction_MEDCgl, sy, cgl)
        ChangeValue(Hero_Tili_Huifu, sy, tili)
        ChangeValue(Correction_Jzsh, sy, 0.1 * jz)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * lw)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * jc)
      end)
      local sjz = {
        1,
        2,
        3,
        4,
        5,
        6
      }
      
      local function jiesuojian()
        if 0 < #sjz then
          u:changedata("虹猫-七剑数量", 1)
          local index = GetRandomInt(1, #sjz)
          local sjs = sjz[index]
          if sjs == 1 then
            u:sendmessage("|cFFE8443D解锁[青光剑]|r")
            u:setdata("虹猫-青光剑")
            u:changedata("固定伤害", 1000.0)
            PlayGlobalSound(Sound_Hongmao_Qingguangjian)
            SendMsgAll("|cFF99CCFF护法使者跳跳，谨听教主差遣|r")
            u:uivar_add({
              keyname = "青光剑",
              keytype = "传奇栏",
              text = "|cFF99CCFF青光剑|r",
              icon = "BTNHongmao_Qijian_02"
            })
          end
          if sjs == 2 then
            u:sendmessage("|cFFE8443D解锁[旋风剑]|r")
            u:setdata("虹猫-旋风剑")
            ChangeValue(HeroMenu_ExtraMoveSpeed_Bfb, sy, 0.1)
            PlayGlobalSound(Sound_Hongmao_Xuanfengjian)
            SendMsgAll("|cFFCCCCFF百草谷乃武林禁地，不许破坏它的平静|r")
            u:uivar_add({
              keyname = "旋风剑",
              keytype = "传奇栏",
              text = "|cFFCCCCFF旋风剑|r",
              icon = "BTNHongmao_Qijian_03"
            })
          end
          if sjs == 3 then
            u:sendmessage("|cFFE8443D解锁[奔雷剑]|r")
            u:setdata("虹猫-奔雷剑")
            ChangeValue(Correction_Cbxs, sy, 0.05)
            ChangeValue(DamageSystem_Baoji, sy, 10)
            ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
            PlayGlobalSound(Sound_Hongmao_Benleijian)
            SendMsgAll("|cFFE8443D我混世魔王要上山，拜见我的偶像|r")
          end
          if sjs == 4 then
            u:sendmessage("|cFFE8443D解锁[雨花剑]|r")
            u:setdata("虹猫-雨花剑")
            ChangeValue(Hero_Tili_Huifu, sy, 0.05)
            PlayGlobalSound(Sound_Hongmao_Yuhuajian)
            SendMsgAll("|cFF99FFFF当然，鸡腿也是给他治病用的|r")
            u:uivar_add({
              keyname = "雨花剑",
              keytype = "传奇栏",
              text = "|cFF99FFFF雨花剑|r",
              icon = "BTNHongmao_Qijian_04"
            })
          end
          if sjs == 5 then
            u:sendmessage("|cFFE8443D解锁[紫云剑]|r")
            u:setdata("虹猫-紫云剑")
            u:changedata("幸运", 2)
            PlayGlobalSound(Sound_Hongmao_Ziyunjian)
            SendMsgAll("|cFF9999FF灵鸽传书，七剑待命，虹猫他们也要来了吧|r")
            u:uivar_add({
              keyname = "紫云剑",
              keytype = "传奇栏",
              text = "|cFF9999FF旋风剑|r",
              icon = "BTNHongmao_Qijian_05"
            })
          end
          if sjs == 6 then
            u:sendmessage("|cFFE8443D解锁[冰魄剑]|r")
            u:setdata("虹猫-冰魄剑")
            PlayGlobalSound(Sound_Hongmao_Bingpojian)
            SendMsgAll("|cFF99CCFF我是玉蟾宫宫主，我的名字叫蓝兔|r")
            u:uivar_add({
              keyname = "冰魄剑",
              keytype = "传奇栏",
              text = "|cFF99CCFF冰魄剑|r",
              icon = "BTNHongmao_Qijian_01"
            })
          end
          table.remove(sjz, index)
        end
        if #sjz == 0 and not u:hasdata("神化判定-虹猫") then
          AdvanceGet["虹猫神化"](u)
        end
      end
      
      u:setdata("虹猫-解锁七剑", jiesuojian)
      u:setdata("虹猫-七剑数量", 1)
    end,
    effectname = "|cFFE8443D白|r|cFFED6964衣|r|cFFF18F8B少|r|cFFF6B4B1侠|r",
    effecttext = "|cFFE8443D唯一 战士 光明\n消灭魔教|r\n|cFFF6B4B1[数据删除]|r\n|cFFE8443D火舞旋风|r\n|cFFF6B4B1[数据删除]|r\n|cFFE8443D至阳至刚|r\n|cFFF6B4B1[数据删除]|r\n|cFFE8443D长虹剑法|r\n|cFFF6B4B1[数据删除]|r\n|cFFE8443D火舞旋风心法|r\n|cFFF6B4B1[数据删除]|r\n|cFFE8443D七剑合璧|r\n|cFFF6B4B1[数据删除]|r",
    effectart = "Ewl_Cq_Hongmao",
    test = [[

    ]]
  },
  {
    name = "恶兆之花",
    weight = 5,
    key = {
      "唯一",
      "影",
      "黑暗",
      "魔导"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("特殊判定-天之杯") or u:hasdata("判定-间桐樱") then
        b = true
      end
      if not u:ishasshw() or u:hasdata("变异判定-卫宫士郎") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:reduceshw()
      u:setplayername("|cFF7DBEF1[|r|cFFFF33FF恶兆之花|r|cFF7DBEF1]|r" .. NameID[sy])
      SendMsgAll("|cFFCC66FF如果我成为坏人，你会原谅我么|r")
      u:playsound(Sound_Sakura_10)
      if not u:hasdata("御主判定-间桐樱") then
        u:additem("I08Y")
      end
      local dskill = S2ID("A179")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          local ewl = getunit(args.unit)
          if u:hasbuff("眩晕") or u:hasbuff("暂停") then
            b = false
            u:sendmessage("|cFF7DBEF1暂停或眩晕状态无法释放|r")
          end
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            u:buffset(u.handle, 2, "绝对闪避")
            u:effectadd("ATX\\[ATxNew]Black_08.mdl", "origin", 2)
            u:playsound(AbominationAlternateDeath1)
            local tx = Effectcreate("Objects\\Spawnmodels\\NightElf\\NightElfLargeDeathExplode\\NightElfLargeDeathExplode.mdl", x, y, 2, 1)
            SetEffectColor(tx, 0, 0, 0)
            local ys = 255
            local tm = 0
            ac.loop(10, function(timer)
              ys = ys - 2.55
              tm = tm + 1.275
              u:setcolor(ys, ys, ys, tm)
              if ys <= 25 then
                u:setxy(x2, y2)
                Effectcreate("ATX\\[ATxNew]Black_08.mdl", x2, y2)
                local ys = 25
                ac.loop(10, function(timer2)
                  ys = ys + 2.55
                  u:setcolor(ys, ys, ys, 255)
                  if 255 <= ys then
                    timer2:remove()
                  end
                end)
                timer:remove()
              end
            end)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      
      local function trg(args)
        if args.chat == "活化" and u:getdata("污染值") >= 600 then
          u:setdata("活化开关")
          u:sendmessage("|cFF530080活化开关打开|r")
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        trg(args)
      end)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 50)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.9, 1)
      ChangeValue(HeroMenu_HpCure_MaxHp, sy, 0.2)
      u:changemaxmp(20)
      ChangeValue(HeroMenu_MpCure_Inr, sy, -1)
      u:addstexiao(var.name, "伤害系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("间桐樱-魔力解放") and u:getpermp() >= 25 then
          u:curemp(0, -5)
          info.gs = info.gs + u:getdata("魔力值")
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("间桐樱-此世之恶") and not u:hasdata("此世之恶冷却") then
          u:settimedata("此世之恶冷却", 1)
          local txsh
          if tg:isnormal() then
            txsh = 0.05 * tg:getmaxhp()
            tg:buffset(u.handle, 1, "暂停")
            DamageUnit({
              bj = "间桐樱此世之恶",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 5,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "暗"
            })
          else
            LossHpUnit({
              u = u,
              tg = tg,
              damage = 0,
              perhp = 0.5,
              maxhp = 0,
              bj = "[生命损耗]间桐樱此世之恶"
            })
          end
          local dx, dy = tg:getxy()
          Effectcreate("ATX\\[ATxNew]Purple_19.mdl", dx, dy)
          Effectcreate("Abilities\\Spells\\Items\\AIso\\AIsoTarget.mdl", dx, dy)
        end
        if tg:isnormal() then
          local jl = 2
          if u:hasdata("隐藏职业-天谴之子") then
            jl = jl * 2
          end
          if u:getluckrandom(jl) then
            u:setdata("间桐樱-虚数双倍吸收")
            tg:kill()
            local dx, dy = tg:getxy()
            Effectcreate("ATX\\[ATxNew]Black_10.mdl", dx, dy, 0, 0.5)
            Effectcreate("ATX\\[ATxNew]Blue_12.mdl", dx, dy)
            if u:hasdata("间桐樱-此世之恶") then
              u:changedata("污染值", 5)
            else
              u:changedata("污染值", 10)
            end
          end
        end
      end)
      local gs = 0
      local cs = 0
      local cs2 = 0
      local wrz = 0
      ac.loop(1000, function()
        u:changedata("固定伤害", 0.1 * -gs)
        if u:hasdata("变异判定-迷失之蝶") then
          gs = u:getdata("污染值")
        else
          gs = 0
        end
        u:changedata("固定伤害", 0.1 * gs)
        if u:isalive() then
          cs = cs + 1
          if u:hasdata("变异判定-迷失之蝶") then
            cs2 = cs2 + 1
            u:losshp(u, 0, 0, 1)
          end
        end
        if cs2 == 3 then
          cs2 = 0
          u:changedata("魔力值", 1)
        end
        if cs == 60 then
          cs = 0
          if u:hasdata("变异判定-迷失之蝶") then
            ChangeValue(Correction_Magic, sy, 1.5000000000000001E-4)
            u:addint(2)
            u:changemaxhp(-30)
          else
            ChangeValue(Correction_Magic, sy, 5.0E-5)
            u:changemaxhp(-15)
          end
          local cha = u:getdata("污染值") - wrz
          if (60 <= cha or u:hasdata("间桐樱-活化开启") or u:getdata("污染值") >= 1000) and not u:hasdata("活化冷却") and not u:hasdata("变异判定-迷失之蝶") then
            u:sendmessage("|cFF530080刻印活化|r")
            local x, y = u:getxy()
            Effectcreate("ATX\\[ATxNew]Purple_29.mdl", x, y)
            u:uivar_change({
              keyname = "恶兆之花",
              keytype = "传奇栏",
              text = "|cFF530080迷|r|cFF75148F失|r|cFF98299E之|r|cFFBA3DAE蝶|r\n|cFF530080刻印.活化|r\n|cFFBA3DAE每60秒降低30点生命上限\n每60秒提升0.15%法术修正与2点智力\n每3秒提升1点魔力值\n每秒损耗1%最大生命值\n提升50点魔力值上限\n降低3魔力恢复\n降低50%生命恢复效果\n自身额外移速失效\n伤害闪避失效|r\n|cFF530080Angra Mainyu|r\n|cFFBA3DAE视野范围扩大至全图\n弹幕变为虚数弹\n提升50%暴击率与暴击伤害\n直接伤害时2%即死目标并增加10点污染值|r\n|cFF530080诞生的渴望|r\n|cFFBA3DAE杀死单位时提升0.03%伤害加成修正\n杀死单位时提升2~6点生命上限与4~8点魔力值\n杀死单位时恢复15%魔力与3%最大生命值|r\n|cFF530080恶兆之花|r\n|cFFBA3DAE无视伤害免疫\n提升[污染值*0.1]固定伤害\n根据污染值解锁额外效果|r",
              icon = "war3mapImported\\BTNEwl_Sakura_06"
            })
            u:setdata("变异判定-迷失之蝶")
            u:changemaxmp(30)
            ChangeValue(HeroMenu_MpCure_Inr, sy, -2)
            ChangeValue(DamageSystem_Baoji, sy, 25)
            ChangeValue(DamageSystem_Baoshang, sy, 0.25)
            ChangeValue(Correction_HealDown, sy, 0.5, 1)
            if u:getdata("污染值") >= 100 then
              u:setdata("间桐樱-黑色阴影")
              local mj = u:createunit("h02B", -24454, -20978)
              ac.loop(1000, function(timer)
                if not u:hasdata("间桐樱-黑色阴影") then
                  mj:remove()
                  timer:remove()
                end
              end)
            end
            if u:getdata("污染值") >= 250 then
              u:setdata("间桐樱-暗潮漩涡")
              u:addskill("S06G")
              local dcs = 0
              local dx, dy = u:getxy()
              local mj = u:createunit("u09S", dx, dy)
              ac.loop(40, function(timer)
                dcs = dcs + 1
                dx, dy = u:getxy()
                mj:setxy(dx, dy)
                if dcs == 25 then
                  dcs = 0
                  if u:isalive() then
                    for _, xq in ac.selector():in_rangexy(dx, dy, 1500):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      local txsh
                      if xq:isnormal() then
                        txsh = 2000 + 0.01 * xq:getmaxhp()
                      else
                        txsh = 2000 + 0.001 * xq:gethp()
                      end
                      xq:groupadd(HpGroup)
                      DamageUnit({
                        bj = "间桐樱暗潮漩涡",
                        unit = xq.handle,
                        source = u.handle,
                        damage = txsh,
                        level = 4,
                        type = "魔力",
                        isvest = true,
                        isattack = false,
                        isnoarmor = false,
                        element = "暗",
                        extradata = {""}
                      })
                    end
                  end
                end
                if not u:hasdata("间桐樱-暗潮漩涡") then
                  u:delskill("S06G")
                  mj:remove()
                  timer:remove()
                end
              end)
            end
            if u:getdata("污染值") >= 400 then
              u:setdata("间桐樱-魔力解放")
              ChangeValue(HeroMenu_MpCure_Inr, sy, 5)
              ChangeValue(HeroMenu_MpCure_MaxMp, sy, 1)
              u:addskill("A17B")
              local ad = 0
              ac.loop(3000, function(timer2)
                ChangeValue(DamageSystem_Shjc, sy, 0.1 * -ad)
                ad = 0.01 * u:getlevel()
                ChangeValue(DamageSystem_Shjc, sy, 0.1 * ad)
                if not u:hasdata("间桐樱-魔力解放") then
                  ChangeValue(DamageSystem_Shjc, sy, 0.1 * -ad)
                  u:delskill("A17B")
                  timer2:remove()
                end
              end)
            end
            if u:getdata("污染值") <= 600 then
              u:setdata("活化冷却")
              ac.wait((100 + cha) * 1000, function()
                u:deldata("活化冷却")
                u:sendmessage("|cFF6633FF魔力再次混乱了起来……|r")
                ac.wait(cha * 1000, function()
                  u:deldata("变异判定-迷失之蝶")
                  u:deldata("变异判定-黑色阴影")
                  u:deldata("变异判定-暗潮漩涡")
                  if u:hasdata("间桐樱-魔力解放") then
                    u:deldata("间桐樱-魔力解放")
                    ChangeValue(HeroMenu_MpCure_Inr, sy, -5)
                    ChangeValue(HeroMenu_MpCure_MaxMp, sy, -1)
                  end
                  u:changemaxmp(-30)
                  ChangeValue(HeroMenu_MpCure_Inr, sy, 2)
                  ChangeValue(DamageSystem_Baoji, sy, -25)
                  ChangeValue(DamageSystem_Baoshang, sy, -0.25)
                  ChangeValue(Correction_HealDown, sy, 0.5, 2)
                  u:uivar_change({
                    keyname = "恶兆之花",
                    keytype = "传奇栏",
                    text = "|cFFCC33FF恶|r|cFFD63DF5兆|r|cFFE047EB之|r|cFFEB52E0花|r\n|cFFCC33FF刻印|r\n|cFFEB52E0降低1魔力恢复\n每60秒降低15点生命上限\n每60秒提升0.05%法术修正\n提升20点魔力值上限|r\n|cFFCC33FF虚数魔术|r\n|cFFEB52E0[回路抑制]|r\n|cFFCC33FF魔术回路-水|r\n|cFFEB52E0提升50额外移速\n提升0.2%最大生命值生命恢复\n提升10%受伤减少|r\n|cFFCC33FF吸收|r\n|cFFEB52E0杀死单位时提升1~3点生命上限与2~4点魔力值\n杀死单位时恢复5%魔力与1%最大生命值|r\n|cFFCC33FF虚弱体质|r\n|cFFEB52E0提升[污染值*0.5]固定受伤|r",
                    icon = "war3mapImported\\BTNEwl_Sakura_04"
                  })
                end)
              end)
            elseif not u:hasdata("间桐樱-此世之恶") then
              u:changedata("外域变异数量", 1)
              if Boolean_CallofCthulhu or u:hasdata("神器判定-旧印") and Morihuanjing_String == "交错次元" then
                MovieAct["克苏鲁的呼唤"](u)
              end
              u:buffset(u.handle, 10, "暂停")
              u:buffset(u.handle, 11, "绝对闪避")
              PlayGlobalSound(TempleOfTheDamnedWhat01)
              Effectcreate("ATX\\[ATxNew]Purple_21.mdl", x, y, 0, 5)
              do
                local mj = u:createunit("u09U", x, y)
                mj:animespeed(0.2)
                mj:animeact("stand")
                mj:timetoremove(10)
                local mj = u:createunit("u09W", x, y)
                mj:timetoremove(13)
                ac.wait(7500, function()
                  local dx = 1
                  ac.loop(500, function(timer)
                    dx = dx + 1
                    Effectcreate("ATX\\[ATxNew]Purple_23.mdl", x, y, 0, dx)
                    local mj = u:createunit("u09V", x, y)
                    mj:timetoremove(1)
                    u:playsound(UndeadDissipate2)
                    if 5 <= dx then
                      timer:remove()
                    end
                  end)
                end)
                ac.wait(10000, function()
                  Effectcreate("ATX\\[ATxNew]Purple_38.mdl", x, y, 5, 5)
                  u:playsound(BuildingDeathLargeHuman)
                end)
                u:uivar_change({
                  keyname = "恶兆之花",
                  keytype = "传奇栏",
                  text = "|cFF530080迷|r|cFF75148F失|r|cFF98299E之|r|cFFBA3DAE蝶|r\n|cFF530080刻印.活化|r\n|cFFBA3DAE每60秒降低30点生命上限\n每60秒提升0.15%法术修正与2点智力\n每3秒提升1点魔力值\n每秒损耗1%最大生命值\n提升50点魔力值上限\n降低3魔力恢复\n降低50%生命恢复效果\n自身额外移速失效\n伤害闪避失效|r\n|cFF530080Angra Mainyu|r\n|cFFBA3DAE视野范围扩大至全图\n弹幕变为虚数弹\n提升50%暴击率与暴击伤害\n直接伤害时2%即死目标并增加10点污染值|r\n|cFF530080诞生的渴望|r\n|cFFBA3DAE杀死单位时提升0.03%伤害加成修正\n杀死单位时提升2~6点生命上限与4~8点魔力值\n杀死单位时恢复15%魔力与3%最大生命值|r\n|cFF530080恶兆之花|r\n|cFFBA3DAE无视伤害免疫\n提升[污染值*0.1]固定伤害\n根据污染值解锁额外效果|r",
                  icon = "war3mapImported\\PASBTNEwl_Sakura_10"
                })
                u:getgoddessforce(1)
                u:setdata("间桐樱-此世之恶")
                local dlv = u:getlevel() - 1
                local s1 = GetRandomReal(0.5, 1.5) * dlv
                local s2 = GetRandomReal(0.5, 1.5) * dlv
                local s3 = GetRandomReal(0.5, 1.5) * dlv
                u:addstats(s1, s2, s3)
                u:setdata("暗涌杀敌", 0)
                u:setdata("暗涌点数", 0)
              end
            end
          end
          wrz = u:getdata("污染值")
        end
      end)
    end,
    effectname = "|cFFCC33FF恶|r|cFFD63DF5兆|r|cFFE047EB之|r|cFFEB52E0花|r",
    effecttext = "|cFFCC33FF刻印|r\n|cFFEB52E0降低1魔力恢复\n每60秒降低15点生命上限\n每60秒提升0.05%法术修正\n提升20点魔力值上限|r\n|cFFCC33FF虚数魔术|r\n|cFFEB52E0[回路抑制]|r\n|cFFCC33FF魔术回路-水|r\n|cFFEB52E0提升50额外移速\n提升0.2%最大生命值生命恢复\n提升10%受伤减少|r\n|cFFCC33FF吸收|r\n|cFFEB52E0杀死单位时提升1~3点生命上限与2~4点魔力值\n杀死单位时恢复5%魔力与1%最大生命值|r\n|cFFCC33FF虚弱体质|r\n|cFFEB52E0提升[污染值*0.5]固定受伤|r",
    effectart = "war3mapImported\\BTNEwl_Sakura_04.blp",
    test = [[

    ]]
  },
  {
    name = "暗之书",
    weight = 5,
    key = {
      "唯一",
      "白毛",
      "黑暗",
      "魔导"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("血统判定-深海") then
        add = add + 2000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-暗之书") then
        b = true
      end
      if not u:ishasshw() then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:changedata("原罪值", 1)
      u:become("噩梦具现化")
      u:reduceshw()
      Weiyi_New[15] = true
      u:setplayername("|cFF7DBEF1[|r|cFF6666CCリインフォース|r|cFF7DBEF1]|r" .. NameID[sy])
      u:chat("|cFF9999FF又一次，全都结束了……|r")
      PlayGlobalSound(Sound_Azs_21)
      u:addskill("S049")
      u:additem("I051")
      u:setdata("暗书书页数", 0)
      u:setdata("暗书特性数", 0)
      ChangeValue(DamageSystem_Sszengjia, sy, 0.3)
      local dskill = S2ID("A0G7")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          local ewl = getunit(args.unit)
          if 4000 <= dis then
            b = false
            u:sendmessage("|cFF7DBEF1距离超过4000|r")
          end
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            Effectcreate("Abilities\\Spells\\Other\\Charm\\CharmTarget.mdl", x2, y2, 0, 5)
            u:playsound(Azs_1)
            ac.timer(250, 10, function()
              Effectcreate("Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeTarget.mdl", x2, y2, 1.5)
            end)
            u:buffset(u.handle, 3, "绝对闪避")
            u:buffset(u.handle, 3, "无敌")
            u:buffset(u.handle, 3, "暂停")
            ac.wait(750, function()
              Effectcreate("war3mapimported\\blackhole.mdl", x2, y2, 2.25, 2)
              ac.timer(33, 44, function()
                for _, xq in ac.selector():in_rangexy(x2, y2, 750):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  local dx, dy = xq:getxy()
                  local a = AngleXY(dx, dy, x2, y2)
                  dx, dy = PolarXY(dx, dy, 20, a)
                  xq:setxy(dx, dy)
                end
              end)
            end)
            ac.wait(3000, function()
              Effectcreate("war3mapimported\\meteorstrike.mdl", x2, y2, 0, 5)
              for i = 1, 6 do
                local a = 60 * i
                local dx, dy = PolarXY(x2, y2, 225, a)
                Effectcreate("war3mapimported\\meteorstrike.mdl", dx, dy, 0, 5)
              end
              for i = 1, 12 do
                local a = 30 * i
                local dx, dy = PolarXY(x2, y2, 450, a)
                Effectcreate("war3mapimported\\meteorstrike.mdl", dx, dy, 0, 5)
              end
              local txsh = 50000
              for _, xq in ac.selector():in_rangexy(x2, y2, 650):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:buffset(u.handle, 15, "破坏-伤害抗性")
                xq:buffset(u.handle, 2, "眩晕")
                xq:removecharacteristics(15)
                DamageUnit({
                  bj = "暗之书灭却",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "魔力",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "暗",
                  extradata = {""}
                })
              end
            end)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      
      local function skill(args)
        local chat = string.sub(args.chat, 1, 3)
        if chat == "-qx" then
          if string.len(args.chat) >= 4 then
            local sy2 = tonumber(string.sub(args.chat, 4, 4))
            if Hero[sy2] ~= 0 and Hero[sy2] ~= u.handle and getunit(Hero[sy2]):isalive() and not u:hasdata("暗之书-暗之契约") then
              local tg = getunit(Hero[sy2])
              tg:sendmessage("|cFFF7C295你成为了暗书契约者|r")
              tg:setdata("暗之书-暗之契约")
              u:setdata("暗之书-暗之契约")
              Qiyue_Anzhishu_Zishen = tg.handle
              Qiyue_Anzhishu_Duixiang = u.handle
              u:addskill("S00M")
              tg:addskill("S00M")
              ChangeValue(DamageSystem_Shjc, sy, 0.025)
              ChangeValue(DamageSystem_Shjc, sy2, 0.025)
              ChangeValue(HeroMenu_MpCure_Inr, sy, 0.5)
              ChangeValue(HeroMenu_MpCure_Inr, sy2, 0.5)
            else
              u:sendmessage("目标不合法")
            end
          else
            u:sendmessage("指令错误")
          end
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        skill(args)
      end)
      local sjz = {
        1,
        2,
        3,
        4,
        5
      }
      local fs = 0
      local cs = 0
      ac.loop(2500, function()
        cs = cs + 1
        ChangeValue(Correction_Magic, sy, -fs)
        if u:hasdata("变异判定-夜铭") then
          fs = 0.0035 * u:getdata("暗书书页数")
        else
          fs = 2.0E-4 * u:getdata("暗书书页数")
        end
        ChangeValue(Correction_Magic, sy, fs)
        u:losshp(u, 0, 2.5)
        if cs == 4 then
          cs = 0
          if u:getluckrandom(15, false) then
            u:effectadd("war3mapImported\\effect_by_wood_effect_d2_shadowfiend_shadowraze_1.mdl", "origin")
            u:effectadd("Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl", "origin")
            ChangeTimeValue(DamageSystem_Sszengjia, sy, 0.75, 5)
            u:buffset(u.handle, 0.5, "眩晕")
            u:buffset(u.handle, 10, "伤害限制")
          end
        end
        if u:isalive() and u:getdata("暗书书页数") >= 111 * (u:getdata("暗书特性数") + 1) and 0 < #sjz then
          u:changedata("暗书特性数", 1)
          local index = GetRandomInt(1, #sjz)
          local sjs = sjz[index]
          if sjs == 1 then
            u:sendmessage("|cFF9999FF解锁-迅风天马|r")
            u:setdata("暗之书-迅风天马")
            ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 90)
          end
          if sjs == 2 then
            u:sendmessage("|cFF9999FF解锁-精钢圣盾|r")
            u:setdata("暗之书-精钢圣盾")
            ChangeValue(DamageSystem_Ssjianshao, sy, 0.88, 1)
            u:changedata("固定格挡", 12)
          end
          if sjs == 3 then
            u:sendmessage("|cFF9999FF解锁-嗜血飞刃|r")
            u:setdata("暗之书-嗜血飞刃")
            ChangeValue(DamageSystem_Shjc, sy, 0.015)
            ChangeValue(DamageSystem_Shjc, sy, 0.015)
            ChangeValue(DamageSystem_Shjc, sy, 0.015)
          end
          if sjs == 4 then
            u:sendmessage("|cFF9999FF解锁-暗黑裁决|r")
            u:setdata("暗之书-暗黑裁决")
          end
          if sjs == 5 then
            u:sendmessage("|cFF9999FF解锁-吸收|r")
            u:setdata("暗之书-吸收")
          end
          table.remove(sjz, index)
        end
      end)
      if u:getdata("瞳变异数量") == 0 then
        u:changedata("瞳变异数量", 1)
        u:setdata("变异判定-夜铭")
        local zs = 0
        ac.loop(3000, function()
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * -zs)
          zs = 0.1 * (Correction_Magic[sy] - 1)
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * zs)
        end)
        u:uivar_add({
          keyname = "夜铭",
          keytype = "传奇栏",
          text = "|cFF6633CC夜铭|r\n|cFF9966FF①暗之书书页获取量翻倍\n②暗之书书页法术加成提升至0.35%\n③提升[0.1%当前法术修正]伤害加成\n免疫疯狂特性|r",
          icon = "war3mapImported\\BTNEwl_Azs_Anyezhitong.blp"
        })
      end
      if u:getdata("血统浓度") <= 50 then
        u:changedata("血统浓度", 50)
        u:changedata("魔导变异数量", 1)
        u:changedata("黑暗变异数量", 1)
        u:setdata("变异判定-人格管制系统")
        local hp = 0
        ac.loop(3000, function()
          ChangeValue(HeroMenu_HpChange_Inr, sy, -hp)
          hp = 10 * (1 + 2 * u:getmissperhp() / 100)
          ChangeValue(HeroMenu_HpChange_Inr, sy, hp)
        end)
        local cs = 0
        local cs2 = 0
        ac.loop(1000, function()
          if u:isalive() then
            cs = cs + 1
            if not u:hasdata("暗之书-护盾特效") then
              cs2 = cs2 + 1
            end
            if cs2 == 60 then
              cs2 = 0
              if not u:hasdata("暗之书-护盾特效") then
                u:setdata("暗之书-护盾特效", u:effectadd("Abilities\\Spells\\Undead\\AntiMagicShell\\AntiMagicShell.mdl", "chest", -1))
              end
              u:setdata("暗之书-护盾值", 0.15 * u:getmaxhp())
              Hdzflash(u)
            end
          end
        end)
        u:uivar_add({
          keyname = "人格管制系统",
          keytype = "血统栏",
          text = "|cFF9900CC人格管制系统|r\n|cFFCC33FF①提升10生命回复(生命每降低1%提升2%效果)\n②直接伤害时附带[10%*原始伤害]暗魔力伤害,触发冷却0.25秒\n③获得最大生命值15%护盾,破碎后60秒复原|r",
          icon = "war3mapImported\\BTNEwl_Azs_Rengeguanzhixitong.blp"
        })
      end
    end,
    effectname = "|cFF9933CCリインフォース|r",
    effecttext = "|cFF9933CC暗之契约|r\n|cFF6666FF[数据删除]|r\n|cFF9933CC暗之书|r\n|cFF6666FF[数据删除]|r\n|cFF9933CC封锁领域|r\n|cFF6666FF[数据删除]|r\n|cFF9933CC侵蚀|r\n|cFF6666FF[数据删除]|r",
    effectart = "war3mapImported\\BTNEwl_As_Azs.blp",
    test = [[

    ]]
  },
  {
    name = "祸灵梦",
    clickfunc = function(u, var)
      if u:hasdata("神化判定-灾祸魔神") then
        u:sendmessage("|cFFCC0000已神化为灾祸魔神|r")
        return
      end
      if not u:ishasitem("I01Q") then
        u:sendmessage("|cFFCC0000需要消耗1瓶血坏药剂|r")
        return
      end
      if not u:ishasshw() then
        u:sendmessage("|cFFCC0000需要消耗1个神化位|r")
        return
      end
      u:removeitem("I01Q")
      AdvanceGet["神化灾祸魔神"](u)
    end,
    weight = 5,
    key = {
      "唯一",
      "战士",
      "黑暗",
      "巫女"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-祸灵梦") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:changedata("原罪值", 1)
      u:become("噩梦具现化")
      u:setdata("血统判定-人类")
      ac.wait(6500, function()
        PlayGlobalSound(Sound_Hlm_Hq)
        NPCChat({
          name = "|cFF990000魔|r|cFF660000神|r",
          chaticon = "Chat_Hlm.tga",
          chattext = {
            {
              text = "|cFFCC0000『|r|cFFC60202想|r|cFFC10404要|r|cFFBB0606和|r|cFFB50808我|r|cFFB00909战|r|cFFAA0B0B斗|r|cFFA40D0D吗|r|cFF9F0F0F』|r",
              time = 0.17
            },
            {
              text = "|cFF8E1515『|r|cFF881717很|r|cFF821919好|r|cFF7D1A1A』|r",
              time = 2.5
            },
            {
              text = "|cFF6C2020『|r|cFF662222就|r|cFF602424在|r|cFF5B2626这|r|cFF552828里|r|cFF4F2A2A杀|r|cFF4A2B2B了|r|cFF442D2D你|r|cFF3E2F2F』|r",
              time = 3.4
            }
          }
        })
      end)
      u:setdata("传奇灾祸之力成长加成倍率", 1)
      ChangeValue(Correction_Exp, sy, 0.1)
      ChangeValue(DamageSystem_Baoji, sy, 15)
      ChangeValue(DamageSystem_Baoshang, sy, 0.25)
      ChangeValue(Correction_Jzsh, sy, 0.04000000000000001)
      u:addstexiao(var.name, "杀敌效果", function(args)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (8.0E-4 * u:getdata("传奇灾祸之力成长加成倍率")))
      end)
      AddUISkill({
        text = var.name,
        u = u,
        cd = 0.1,
        icon = "Ewl_Hlm_Cq.tga",
        func = function(args)
          if not u:hasdata("祸灵梦-瞬移关闭") then
            u:sendmessage("|cFFCC0000祸灵梦-瞬移关闭|r")
            u:setdata("祸灵梦-瞬移关闭")
          else
            u:sendmessage("|cFFCC0000祸灵梦-瞬移开启|r")
            u:deldata("祸灵梦-瞬移关闭")
          end
        end
      })
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local tg = args.tg
        if not tg:hasdata("祸灵梦-杀敌判定") then
          ac.wait(10, function()
            tg:deldata("祸灵梦-杀敌判定")
            if not tg:isalive() then
              ChangeValue(Correction_Jzsh, sy, 0.1 * (8.0E-4 * u:getdata("传奇灾祸之力成长加成倍率")))
            end
          end)
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not tg:hasdata(var.name .. "-特效冷却") then
          tg:settimedata(var.name .. "-特效冷却", 5)
          tg:buffset(u.handle, 1, "破坏-伤害免疫")
          tg:buffset(u.handle, 1, "破坏-伤害抗性")
          tg:effectadd("Hlm (5).mdx", "origin")
        end
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          local x, y = tg:getxy()
          u:settimedata(var.name .. "-特效冷却", 2)
          local txsh = 5000 + 300 * u:getstr()
          Effectcreate("Hlm (3).mdx", x, y, 0, 3)
          Effectcreate("Hlm (4).mdx", x, y)
          for _, xq in ac.selector():in_rangexy(x, y, 225):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "祸灵梦附伤",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
          end
        end
      end)
      u:addstexiao(var.name, "脱离战斗状态时", function(args)
        local u = args.u
        if not u:hasdata(var.name .. "-脱战音效冷却") then
          u:settimedata(var.name .. "-脱战音效冷却", 60)
          u:playsound(Sound_Hlm_Shadi)
        end
      end)
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and not u:hasdata(var.name .. "-决死冷却") then
          args.dt = false
          u:sendmessage("|cFFCC0000六道拳「天上道」|r")
          u:settimedata("祸灵梦-决死冷却", 240)
          u:buffset(u.handle, 1, "绝对闪避")
          u:playsound(Sound_Hlm_Ldq)
          u:effectadd("Hlm (1).mdx", "origin")
        end
      end)
      u:effectadd("Hlm (2).mdx", "origin", -1)
      u:setdata("系统-常驻飞行")
      u:addtrgevent("单位-指定点目标指令", function(args)
        if args.orderid == String2OrderIdBJ("smart") and not u:hasdata("祸灵梦-瞬移关闭") and not u:hasdata("间隙冷却") then
          local x = args.x
          local y = args.y
          mapmove(u.handle, "祸灵梦-境界操控", x, y)
        end
      end)
    end,
    effectname = "|cFFCC0000祸|r|cFF990000灵|r|cFF660000梦|r",
    effecttext = "|cFFCC0000我|r|cFFBC0000没|r|cFFAD0000有|r|cFF9D0000被|r|cFF8D0000原|r|cFF7E0000谅|r|cFF6E0000.|r|cFF5E0000.|r|cFF4E0000.|r|cFF3F0000.|r|cFF2F0000.|r|cFF1F0000.|r\n|cFF990000…|r|cFF920000…|r|cFF8C0000…|r|cFF850000ど|r|cFF7E0000う|r|cFF780000し|r|cFF710000て|r|cFF6A0000…|r|cFF640000こ|r|cFF5D0000の|r|cFF560000ま|r|cFF500000ま|r|cFF490000じ|r|cFF430000ゃ|r|cFF3C0000…|r|cFF350000…|r|cFF2F0000死|r|cFF280000ん|r|cFF210000じ|r|cFF1B0000ゃ|r|cFF140000う|r|cFF0D0000…|r",
    effectart = "Ewl_Hlm_Cq",
    test = [[

    ]]
  },
  {
    name = "幼小的魔王",
    clickfunc = function(u, button)
      if not u:hasdata("阿米娅-暴虐关闭") then
        u:sendmessage("|cFFCC9966幼小的魔王-暴虐关闭|r")
        u:setdata("阿米娅-暴虐关闭")
      else
        u:sendmessage("|cFFCC9966幼小的魔王-暴虐开启|r")
        u:deldata("阿米娅-暴虐关闭")
      end
    end,
    weight = 5,
    key = {"唯一", "源石"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-阿米娅") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cFFCC9966我们失去了很多才走到今天。有的时候我会问自己，这一切都值得吗？|r")
      PlayGlobalSound(Sound_MwAmiya_01)
      u:changeysnd(1)
      u:become("噩梦具现化")
      ChangeValue(KillReward_MHp, sy, 1)
      for index, value in ipairs(Pools_SpeDzWeapon) do
        if value.name == "青色怒火" then
          if not value.hasbeenget then
            local item = u:additem("I0JJ")
            System_Count_Weapon = System_Count_Weapon + 1
            SetData(item, "物品判定-神兵")
            SetData(item, "神兵-获取")
            value.hasbeenget = true
          end
          break
        end
      end
      local sjz = {
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9
      }
      local endsh = 0
      local hp = 0
      local fs = 0
      local bs = 0
      local gl = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -gl)
        if u:hasdata("幼小的魔王-罗德岛") then
          gl = 0.015 * u:getstate("源石变异") * u:getdata("系统-血液源石结晶密度") / 100
        else
          gl = 0
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * gl)
        ChangeValue(Correction_Magic, sy, -fs)
        if u:hasdata("幼小的魔王-魔王") then
          fs = 0.02 * u:getdata("阿米娅-累积魔王值")
        else
          fs = 0
        end
        ChangeValue(Correction_Magic, sy, fs)
        ChangeValue(DamageSystem_Baoshang, sy, -bs)
        if u:hasdata("幼小的魔王-魔王") then
          bs = 0.0025 * u:getlevel() + 0.05 * Correction_Magic[sy]
        else
          bs = 0
        end
        ChangeValue(DamageSystem_Baoshang, sy, bs)
        local perhp = u:getperhp()
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, -hp)
        if u:hasdata("幼小的魔王-火种") then
          if u:hasdata("神化判定-阿米娅") then
            hp = 3 * (100 - perhp) / 100
          else
            hp = 1.5 * (100 - perhp) / 100
          end
        else
          hp = 0
        end
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, hp)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * -endsh)
        if u:hasdata("幼小的魔王-理智") then
          if 80 <= perhp then
            endsh = 0.16
          elseif 50 <= perhp then
            endsh = 0.08
          else
            endsh = 0
          end
        else
          endsh = 0
        end
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * endsh)
        if u:isalive() then
          if u:getdata("阿米娅-减少生命上限") >= 20 then
            local add = math.floor(u:getdata("阿米娅-减少生命上限") / 20)
            local max = 40
            if u:hasdata("神化判定-阿米娅") then
              max = 80
            end
            if add >= max then
              add = max
            end
            u:addrandomstats(add)
            u:setdata("阿米娅-减少生命上限", 0)
          end
          if u:getdata("阿米娅-魔王值") >= 10 and 0 < #sjz then
            u:changedata("阿米娅-魔王值", -10)
            local index = GetRandomInt(1, #sjz)
            local sjs = sjz[index]
            if sjs == 1 then
              u:sendmessage("|cFFCC9966解锁[情绪：愤怒]|r")
              u:setdata("幼小的魔王-愤怒")
              u:setdata("阿米娅-情绪值", 0)
              u:addstexiao(var.name, "直接伤害特效", function(args)
                local tg = args.tg
                local u = args.u
                local info = args.damageinfo
                u:changedata("阿米娅-情绪值", 1)
                if not u:hasdata("阿米娅-附伤冷却") then
                  local cd = 0
                  local txsh
                  local lv = 1
                  if u:hasdata("神化判定-阿米娅") then
                    lv = 5
                    txsh = u:getdata("阿米娅-情绪值") * 4
                    u:settimedata("阿米娅-附伤冷却", 0.05)
                  else
                    txsh = u:getdata("阿米娅-情绪值")
                    u:settimedata("阿米娅-附伤冷却", 0.25)
                  end
                  if not u:hasdata("阿米娅-附伤特效冷却") then
                    u:settimedata("阿米娅-附伤特效冷却", 0.25)
                    local x2, y2 = tg:getxy()
                    Effectcreate("Shio_Amiya_Tx_Sg.mdx", x2, y2, 0, 2, 100)
                  end
                  DamageUnit({
                    bj = "阿米娅附伤",
                    unit = tg.handle,
                    source = u.handle,
                    damage = txsh,
                    level = lv,
                    type = "魔力",
                    isvest = true,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {""}
                  })
                end
              end)
            end
            if sjs == 2 then
              u:sendmessage("|cFFCC9966解锁[情绪：绝望]|r")
              u:setdata("幼小的魔王-绝望")
              u:addstexiao(var.name, "受伤后效果", function(args)
                local u = args.u
                local tg = args.tg
                if not u:hasdata(var.name .. "-受伤特效冷却") then
                  u:settimedata(var.name .. "-受伤特效冷却", 1)
                  local add = 0.05 * u:getallattri()
                  if u:hasdata("神化判定-阿米娅") then
                    add = add * 2
                  end
                  ChangeTimeValue(HeroMenu_HpChange_Inr, sy, add, 8)
                  ChangeTimeValue(DamageSystem_Ssjianshao, sy, 0.95, 8, 1)
                end
              end)
            end
            if sjs == 3 then
              u:sendmessage("|cFFCC9966解锁[情绪：希望]|r")
              u:setdata("幼小的魔王-希望")
              u:addstexiao(var.name, "决死效果", function(args)
                if args.dt and not u:hasdata("幼小的魔王-决死冷却") then
                  args.dt = false
                  u:settimedata("幼小的魔王-决死冷却", 222)
                  u:sendmessage("|cFFCC9966幼小的魔王-情绪：希望|r")
                  local add
                  if u:hasdata("神化判定-阿米娅") then
                    add = 1 * u:getmaxhp() + 100 * u:getlevel()
                  else
                    add = 0.5 * u:getmaxhp() + 100 * u:getlevel()
                  end
                  hdzlinshiadd(u, add)
                end
              end)
            end
            if sjs == 4 then
              u:sendmessage("|cFFCC9966解锁[情绪：理智]|r")
              u:setdata("幼小的魔王-理智")
            end
            if sjs == 5 then
              u:sendmessage("|cFFCC9966解锁[记忆：暴虐]|r")
              u:setdata("幼小的魔王-暴虐")
              ac.loop(10000, function()
                if not u:hasdata("阿米娅-暴虐关闭") then
                  local x, y = u:getxy()
                  local g = CreateGroupLua()
                  for _, xq in ac.selector():in_rangexy(x, y, 2000):is_enemy(u.handle):ipairs() do
                    xq = getunit(xq)
                    xq:groupadd(g)
                  end
                  local txsh = 5000 + 50 * u:getallattri() * (1 + u:getdata("系统-血液源石结晶密度") / 100)
                  if Group_Counts(g) > 0 then
                    for i = 1, 10 do
                      local tg = Group_Randomunit(g)
                      DamageUnit({
                        bj = "阿米娅暴虐附伤",
                        unit = tg.handle,
                        source = u.handle,
                        damage = txsh,
                        level = 1,
                        type = "物理",
                        isvest = true,
                        isattack = false,
                        isnoarmor = false,
                        element = "无",
                        extradata = {""}
                      })
                    end
                  end
                end
              end)
              u:addstexiao(var.name .. "剑气", "直接伤害特效", function(args)
                local tg = args.tg
                local u = args.u
                local info = args.damageinfo
                if not u:hasdata("阿米娅-剑气附伤冷却") and u:getluckrandom(10) then
                  u:settimedata("阿米娅-剑气附伤冷却", 3)
                  local txsh = 10000 + (1 + 100 * u:getallattri() * u:getdata("系统-血液源石结晶密度") / 100)
                  local x, y = u:getxy()
                  local x2, y2 = tg:getxy()
                  local angle = AngleXY(x, y, x2, y2)
                  unifycreate({
                    owner = u.handle,
                    model = "Texiao_Amiya_01.mdx",
                    modelname = "剑气",
                    modelsize = 1,
                    height = 90,
                    damage = txsh,
                    damagetype = 2,
                    x = x,
                    y = y,
                    range = 1800,
                    speed = 4000,
                    volume = 175,
                    angle = angle,
                    angleoffset = 0,
                    attenua = 1,
                    attenuacount = 999,
                    life = 10,
                    isbullet = false,
                    isvest = true,
                    isignorearmor = false,
                    startfunc = function(mj)
                      mj:setdata("循环计数", 0)
                    end,
                    loopfunc = function(mj)
                      mj:changedata("循环计数", UnifyDT)
                      if mj:getdata("循环计数") >= 0.03 then
                        mj:setdata("循环计数", 0)
                      end
                    end,
                    hitfunc = function(mj, damage)
                      return damage
                    end,
                    hitbeforefunc = function(mj, xq, damage2)
                    end,
                    hitafterfunc = function(mj, xq, damage2)
                    end,
                    endfunc = function(mj)
                    end
                  })
                end
              end)
            end
            if sjs == 6 then
              u:sendmessage("|cFFCC9966解锁[记忆：火种]|r")
              u:setdata("幼小的魔王-火种")
              ChangeValue(HeroMenu_HpChange_MaxHp, sy, 0.5)
            end
            if sjs == 7 then
              u:sendmessage("|cFFCC9966解锁[记忆：奴役-理论中的大统一]|r")
              u:setdata("幼小的魔王-奴役")
              ForGroupLuaNew(Group_PlayHero, function(xq)
                local sy2 = xq.ownerid
                ChangeValue(Correction_MEDCgl, sy2, 0.1)
              end)
            end
            if sjs == 8 then
              u:sendmessage("|cFFCC9966解锁[记忆：魔王]|r")
              u:setdata("幼小的魔王-魔王")
            end
            if sjs == 9 then
              u:sendmessage("|cFFCC9966解锁[记忆：罗德岛]|r")
              u:setdata("幼小的魔王-罗德岛")
            end
            table.remove(sjz, index)
          end
        end
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        if tg:isboss() then
          if u:hasdata("神化判定-阿米娅") then
            u:chat("|cFFCCCCCC重|r|cFFB2B2B2现|r|cFF999999.|r|cFF808080.|r|cFF666666.|r|cFF4C4C4C.|r|cFF333333.|r")
            ac.wait(3000, function()
              u:chat(tg:getname() .. "|cFF949596已|r|cFF858687被|r|cFF767778记|r|cFF686869录|r|cFF59595A.|r|cFF4A4A4B.|r|cFF3B3C3C.|r|cFF2C2D2D.|r|cFF1E1E1E.|r")
            end)
          end
          u:changedata("阿米娅-魔王值", 10)
          if u:hasdata("幼小的魔王-愤怒") then
            u:changedata("阿米娅-情绪值", 1000)
          end
          u:changedata("阿米娅-累积魔王值", 10)
        elseif tg:iselite() then
          u:changedata("阿米娅-魔王值", 1)
          if u:hasdata("幼小的魔王-愤怒") then
            u:changedata("阿米娅-情绪值", 100)
          end
          u:changedata("阿米娅-累积魔王值", 1)
        else
          if u:hasdata("幼小的魔王-愤怒") then
            u:changedata("阿米娅-情绪值", 10)
          end
          if GetRandom100(5) then
            u:changedata("阿米娅-魔王值", 1)
            u:changedata("阿米娅-累积魔王值", 1)
          end
        end
      end)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        u:changedata("阿米娅-魔王值", 1)
        u:changedata("阿米娅-累积魔王值", 1)
      end)
      
      local function chattrg(args)
        if args.chat == "我始终如一" then
          if #sjz == 0 then
            if u:ishasshw() then
              AdvanceGet["阿米娅"](u)
            else
              u:sendmessage("|cFFCCCCCC神|r|cFFB2B2B2化|r|cFF999999位|r|cFF808080不|r|cFF666666足|r")
            end
          else
            u:sendmessage("|cFFCCCCCC未|r|cFFB9B9B9完|r|cFFA6A6A6全|r|cFF939393解|r|cFF808080锁|r|cFF6C6C6C能|r|cFF595959力|r")
          end
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chattrg(args)
      end)
    end,
    effectname = "|cFFCC9966幼|r|cFFAA8055小|r|cFF886644的|r|cFF664C33魔|r|cFF443322王|r",
    effecttext = "|cFFCC9966源石 唯一 噩梦具现化\n记忆:叹息|r\n|cFF443322自身不会在从属性中获取生命上限，杀敌获取生命上限翻倍\n每永久减少20生命上限随机获得1点属性(单次获取上限40点)\n杀敌时提升1点生命上限|r\n|cFFCC9966本能？|r\n|cFF443322击杀单位5%几率获得1点魔王值\n击杀精英特性单位必定获得1点魔王值\n升级时获得1点魔王值，击杀BOSS获得10点魔王值\n每获得10点魔王值随机解锁一项能力|r",
    effectart = "Ewl_Cq_Amiya_Mowang.tga",
    test = [[

    ]]
  },
  {
    name = "见习魔女",
    clickfunc = function(u, button)
      if not u:hasdata("变异判定-伊蕾娜") and u:hasdata("伊蕾娜-神化时间达标") and u:ishasshw() and u:getdata("当前额外移速") >= 200 then
        AdvanceGet["伊蕾娜"](u)
      end
    end,
    weight = 5,
    key = {
      "唯一",
      "魔导",
      "冰",
      "炎",
      "雷",
      "白毛"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-伊蕾娜") then
        b = true
      end
      if not u:hasdata("系统-特殊获取中") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      Weiyi_New[12] = true
      SendMsgAll("|cFFFF99FF『啊|r|cFFF69BFE啦|r|cFFEE9EFD |r|cFFE5A0FC在|r|cFFDCA3FB这|r|cFFD4A5FA种|r|cFFCBA8F9地|r|cFFC2AAF8方|r|cFFBAADF8有|r|cFFB1AFF7这|r|cFFA8B2F6种|r|cFFA0B4F5东|r|cFF97B7F4西|r|cFF8EB9F3么』|r")
      PlayGlobalSound(Sound_Yln_02)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
      u:addskill("S07E")
      u:changearmor(30)
      u:addallstats(20)
      local ss1 = 0
      local ss2 = 0
      ac.loop(3000, function()
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, -ss1)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -ss2)
        ss1 = 0.25 * u:getstate("魔导变异")
        ss1 = 0.1 * (Correction_Magic[sy] - 1)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * ss2)
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, ss1)
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:getluckrandom(20 * info.txgl) and not u:hasdata(var.name .. "-特效冷却") then
          local dx, dy = tg:getxy()
          Effectcreate("0Tx\\0Tx_Yln (3).mdl", dx, dy, 0.5)
          u:settimedata(var.name .. "-特效冷却", 0.5)
          local shlx = {
            "冰",
            "炎",
            "雷"
          }
          local txsh = info.yssh * 0.25
          DamageUnit({
            bj = "见习魔女附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = shlx[GetRandomInt(1, #shlx)]
          })
        end
      end)
      local cs = 0
      ac.loop(1000, function(timer)
        if u:isalive() then
          cs = cs + 1
          if 300 <= cs then
            u:setdata("伊蕾娜-神化时间达标")
            timer:remove()
          end
        end
      end)
    end,
    effectname = "|cFF99FFFF见|r|cFF7AD9FF习|r|cFF5CB3FF魔|r|cFF3D8DFF女|r",
    effecttext = "|cFF7AD9FF灰色的长发在太阳的照耀下散发出耀眼的光芒，\n琉璃色的双瞳看似朝向前方，实际上却是眺望着远方的某处，\n黑长袍，三角帽，象征星辰的胸针，这身像是魔女的装扮说\n是为了凸显她的魅力而存在也毫不为过，\n这位任谁都只能以惹人怜爱形容的她究竟是谁呢？|r\n|cFF99FFFF没|r|cFF83E4FF错|r|cFF6DC9FF，|r|cFF57AEFF就|r|cFF4292FF是|r|cFF2C77FF我|r",
    effectart = "war3mapImported\\BTNEwl_Yln_Chuanqi",
    test = [[

    ]]
  },
  {
    name = "狂乱者",
    weight = 5,
    key = {"唯一"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I0C6") then
        add = add + 3000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-狂乱者") then
        b = true
      end
      if not u:ishasitem("I0C6") then
        b = false
      end
      if not u:ishasshw() then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:setplayername("|cFF990000狂|r|cFF730000乱|r|cFF4C0000者|r")
      SendMsgAll("|cFFB27373『不需要言语，不需要理解。』|r")
      ac.wait(3000, function()
        SendMsgAll("|cFFBF6060『这是一场永无止尽的杀戮。』|r")
      end)
      ac.wait(6000, function()
        SendMsgAll("|cFFCC4C4C『你所拥有的一切不再有任何意义』|r")
      end)
      ac.wait(9000, function()
        SendMsgAll("|cFFD93939『从此，没有任何事物能改变你』|r")
      end)
      ac.wait(12000, function()
        SendMsgAll("|cFFE62626『人类，最终会成为自己所讨厌的样子。』|r")
      end)
      u:reduceshw()
      u:become("噩梦具现化")
      local dskill = S2ID("A1GQ")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if b then
            PlayBGM({
              bgm = BGM_Klz_04,
              time = 245,
              ID = 121,
              unit = u.handle
            })
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      local dskill = S2ID("A1HW")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if b then
            PlayBGM({
              bgm = BGM_Kuangluangzhe_11,
              time = 280,
              ID = 121,
              unit = u.handle
            })
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      PlayBGM({
        bgm = BGM_Klz_03,
        time = 215,
        ID = 122,
        unit = u.handle
      })
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata("狂乱者-回血冷却") then
          u:settimedata("狂乱者-回血冷却", 0.2)
          local add = 0.5
          if u:getperhp() <= 30 then
            add = 1
          end
          u:curehp(u.handle, 0, add, 4)
        end
      end)
      ChangeValue(HeroMenu_HpForever_Inr, sy, 25)
      ChangeValue(HeroMenu_HpForever_MaxHp, sy, 0.1)
      local jz = 0
      local tl = 0
      local hf = 0
      local gs = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Jzsh, sy, 0.1 * -jz)
        ChangeValue(Hero_Tili_Huifu, sy, -tl)
        ChangeValue(HeroMenu_HpForever_Inr, sy, -hf)
        local hp = u:getperhp()
        if hp <= 20 then
          u:clearbuff("眩晕")
          u:clearbuff("僵直")
          u:clearbuff()
        end
        if hp <= 30 then
          hf = 25
        else
          hf = 0
        end
        if hp <= 10 then
          tl = 0.5
        elseif hp <= 25 then
          tl = 0.4
        elseif hp <= 50 then
          tl = 0.3
        elseif hp <= 75 then
          tl = 0.2
        else
          tl = 0
        end
        jz = (100 - hp) / 100
        ChangeValue(Correction_Jzsh, sy, 0.1 * jz)
        ChangeValue(Hero_Tili_Huifu, sy, tl)
        ChangeValue(HeroMenu_HpForever_Inr, sy, hf)
        u:changedata("固定伤害", 0.1 * -gs)
        gs = 2.5 * (u:getmaxhp() - u:gethp())
        u:changedata("固定伤害", 0.1 * gs)
      end)
    end,
    effectname = "|cFF990000狂|r|cFF730000乱|r|cFF4C0000者|r",
    effecttext = "|cFF990000虚妄破碎 |r|cFF4C0000- 猩红|r\n|cFF730000[数据删除]|r\n|cFF990000杀戮|r|cFF4C0000本能|r\n|cFF730000[数据删除]|r\n|cFF990000衰亡|r|cFF4C0000抑制|r\n|cFF730000[数据删除]|r",
    effectart = "war3mapImported\\PASBTNEwl_Klz.tga",
    test = [[

    ]]
  },
  {
    name = "鹿目圆",
    weight = 5,
    key = {"唯一", "光明"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I073") then
        add = add + 3000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-鹿目圆") then
        b = true
      end
      if not u:ishasshw() then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:playsound(Lumuyuan_Get)
      u:sendmessage("|cFFFF66FF我|r")
      ac.wait(1250, function()
        u:sendmessage("|cFFFF66FF决定成为魔法少女了|r")
      end)
      u:reduceshw()
      for index, value in ipairs(Pools_Spe) do
        if value.name == "蔷薇花开" then
          if not value.hasbeenget then
            local item = u:additem("I073")
            value.hasbeenget = true
          end
          break
        end
      end
      u:become("魔法少女")
      u:setplayername("|cFF7DBEF1[|r|cFFFF66FF鹿目圆香|r|cFF7DBEF1]|r" .. NameID[sy])
      u:getgoddessforce(2, false)
      ChangeValue(Correction_CureUp, sy, 0.25)
      ChangeValue(HeroMenu_HpCure_MaxHp, sy, 0.25)
      local cs = 0
      ac.loop(3000, function()
        cs = cs + 1
        if cs == 20 then
          cs = 0
          u:changemaxhp(100 * u:getstate("光明变异"))
        end
      end)
      local dskill = S2ID("A0G4")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          local target = args.target
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            local tg = getunit(args.target)
            tg:playsound(Lumuyuan_Skill)
            tg:effectadd("Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl", "overhead")
            tg:effectadd("Abilities\\Spells\\NightElf\\Rejuvenation\\RejuvenationTarget.mdl", "chest", 25)
            if tg:hasdata("属性-魔法少女") then
              tg:changedata("污染度", -5)
            end
            ac.timer(250, 100, function()
              tg:curehp(u.handle, 25, 0.5, 1)
            end)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      local dskill = S2ID("A0C5")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if Group_Counts(Group_DeathHero) == 0 then
            b = false
            u:sendmessage("|cFF7DBEF1没有死亡英雄|r")
          end
          if b then
            local mb = Group_Randomunit(Group_DeathHero)
            local x, y = u:getxy()
            local dx, dy = PolarXY(x, y, 300, u:getface())
            HeroRelive(mb.handle, dx, dy, 3)
            if mb.handle ~= u.handle and mb:hasdata("属性-魔法少女") then
              mb:changedata("污染度", -5)
            end
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not info.ismeleedamage and not info.isvestdamage and not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(5 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 3)
          local txsh = 10000 + 250 * u:getint()
          ChangeTimeValue(DamageSystem_Shjc, sy, 0.025, 10)
          unifycreate({
            owner = u.handle,
            model = "war3mapImported\\spiritarrow_byepsilon.mdl",
            modelname = "光辉魔箭",
            modelsize = 2,
            height = 25,
            damage = txsh,
            damagetype = 4,
            range = 2500,
            speed = 4000,
            volume = 150,
            angle = AngleBetweenUnits(u.handle, tg.handle),
            isvest = true,
            isnoarmor = false,
            hitbeforefunc = function(mj, xq, damage2)
              u:setdata("属性伤害", "光")
              xq:effectadd("Objects\\Spawnmodels\\NightElf\\NEDeathSmall\\NEDeathSmall.mdl")
              if not xq:hasdata("光辉魔箭失效") then
                xq:effectadd("war3mapImported\\e_nedpink.mdx")
                xq:removecharacteristics(3)
                xq:settimedata("光辉魔箭失效", 3)
              end
              if xq:isnormal() then
                damage2 = xq:getmaxhp() * 0.1
              else
                damage2 = xq:getmaxhp() * 0.001
              end
              LossHpUnit({
                u = u,
                tg = xq,
                damage = damage2,
                perhp = 0,
                maxhp = 0,
                bj = "[生命损耗]光辉魔箭"
              })
            end
          })
        end
      end)
    end,
    effectname = "|cFFFF66FF鹿|r|cFFFF80FF目|r|cFFFF99FF圆|r",
    effecttext = "|cFFFF66FF女神力 2\n魔法少女 光明 唯一\n转生之福音|r\n|cFFFF99FF每60秒提升[100*光明变异]生命上限\n解锁技能[转生之福音]|r\n|cFFFF66FF天上之祈祷|r\n|cFFFF99FF提升0.25%医疗恢复\n提升25%医疗修正\n解锁技能[天上之祈祷]|r\n|cFFFF66FF光辉魔箭|r\n|cFFFF99FF非近战直接伤害5%发射光辉魔箭(10000+智力*250)并在10秒内提升2.5%伤害加成,\n命中时使精英特性失效3秒并附带1%(0.1%)最大生命值生命损耗,触发冷却3秒|r\n|cFFFF66FF希望之所在|r\n|cFFFF99FF[数据删除]|r\n|cFF949596不论是谁的祈愿，都不想让她是以绝望终结！|r",
    effectart = "Ewl_Dz_Lumuyuan",
    test = [[

    ]]
  },
  {
    name = "祢豆子",
    weight = 5,
    key = {"唯一"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I016") then
        add = add + 3000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-祢豆子") and u:ishasitem("I016") then
        b = true
      end
      if not u:ishasshw() then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:sendmessage("|cFFFF99FF唔……|r")
      u:reduceshw()
      Midouzi = u.handle
      u:setplayername("|cFFFF66FF灶门祢豆子|r")
      local g = CreateGroupLua()
      local hp = 0
      local add = 0
      ac.loop(3000, function()
        ChangeValue(HeroMenu_HpCure_MaxHp, sy, -hp)
        hp = 0
        if IsTimeNight() then
          hp = hp + 1
        end
        if u:getoriginstr() >= 100 then
          hp = hp + 1
        end
        ChangeValue(HeroMenu_HpCure_MaxHp, sy, hp)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        add = 0.001 * u:getstr()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        ForGroupLuaNew(g, function(xq)
          if not xq:hasdata("鬼血术破抗") then
            xq:groupremove(g)
          end
        end)
      end)
      u:effectadd("Abilities\\Spells\\Human\\Polymorph\\PolyMorphDoneGround.mdl")
      u:addskill("S006")
      u:addskill("S044")
      u:addstr(20 + u:getlevel())
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        u:addstr(1)
      end)
      moveskillreplace({
        unit = u.handle,
        level = 2,
        skill_Q = "A0X1",
        skill_W = "A0X0",
        isforce = false,
        efunc = function()
          u:addskill("A0X2")
          
          local function skill(args)
            if args.skill == S2ID("A0X1") or args.skill == S2ID("A0X0") then
              local tilixh = 1
              if u:getdata("祢豆子-形态") == 1 then
                tilixh = tilixh + 1
              end
              local dskill = args.skill
              if u:hasbuff("缠绕") then
                u:setskillcd(dskill, 0.01)
                u:sendmessage("|cFFFF3300缠绕中|r")
                return
              end
              if not u:hasdata("位移体力消耗标记") then
                if u:lossstamina(tilixh) then
                  u:settimedata("位移体力消耗标记", 0.001)
                else
                  u:setskillcd(dskill, 0.01)
                  u:sendmessage("|cFFFF3300体力值不足|r")
                  return
                end
              end
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local angle = AngleXY(x, y, x2, y2)
              local dis = DistanceXY(x, y, x2, y2)
              local mjl = 600
              if u:getdata("祢豆子-形态") == 2 then
                mjl = 800
              end
              if dis >= mjl then
                dis = mjl
              end
              local key = "Q"
              if args.skill == S2ID("A0X0") then
                key = "W"
              end
              if not u:hasbuff("绝对闪避") then
                u:setdata("刷新" .. key .. "时间", 0.2)
              end
              Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
              Effectcreate(" war3mapImported\\nitu.mdl", x, y, 0.8, 1, 0, u:getface() + 180)
              Effectcreate("war3mapImported\\bbb.mdx", x, y)
              movexg(u.handle, 0.2, args.skill, key, "祢豆子-" .. key)
              local txsh = 50 * u:getstr()
              if u:getdata("祢豆子-形态") == 1 then
                txsh = txsh * 2
              end
              unitmove({
                unit = u.handle,
                time = 0.2,
                distance = dis,
                angle = angle,
                loops = {
                  {
                    looptime = 0.04,
                    func = function()
                      local x, y = u:getxy()
                      Effectcreate("war3mapImported\\blackblink.mdx", x, y)
                      for _, xq in ac.selector():in_rangexy(x, y, 200):is_enemy(u.handle):ipairs() do
                        xq = getunit(xq)
                        xq:buffset(u.handle, 0.3, "僵直")
                        DamageUnit({
                          bj = "祢豆子位移",
                          unit = xq.handle,
                          source = u.handle,
                          damage = txsh,
                          level = 1,
                          type = "物理",
                          isvest = false,
                          isattack = true,
                          isnoarmor = false,
                          element = "无",
                          extradata = {"近战"}
                        })
                        unitmove({
                          unit = xq.handle,
                          time = 0.3,
                          distance = 200,
                          angle = angle
                        })
                      end
                    end
                  }
                }
              })
            end
            if args.skill == S2ID("A0X2") then
              local tilixh = 2
              if u:getdata("祢豆子-形态") == 1 then
                tilixh = tilixh + 2
              end
              local dskill = args.skill
              if not u:hasdata("位移体力消耗标记") then
                if u:lossstamina(tilixh) then
                  u:settimedata("位移体力消耗标记", 0.001)
                else
                  u:setskillcd(dskill, 0.01)
                  u:sendmessage("|cFFFF3300体力值不足|r")
                  return
                end
              end
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local angle = AngleXY(x, y, x2, y2)
              local dis = DistanceXY(x, y, x2, y2)
              Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
              u:buffset(u.handle, 0.5, "暂停")
              u:buffset(u.handle, 0.5, "无敌")
              u:playsound(Midouzi_1)
              unitjump({
                unit = u.handle,
                time = 0.5,
                distance = dis,
                height = 300,
                angle = angle,
                isfly = true,
                endfunc = function()
                  u:playsound(Midouzi_2)
                  x, y = u:getxy()
                  Effectcreate("war3mapImported\\fuzzystomp.mdl", x, y)
                  Effectcreate("war3mapImported\\effect_by_wood_effect_d2_shadowfiend_shadowraze_1.mdl", x, y)
                  local txsh = 5000 + 110 * u:getstr()
                  if u:getdata("祢豆子-形态") == 1 then
                    txsh = txsh * 2
                  end
                  for _, xq in ac.selector():in_rangexy(x, y, 350):is_enemy(u.handle):ipairs() do
                    xq = getunit(xq)
                    xq:buffset(u.handle, 1.5, "僵直")
                    xq:effectadd("Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl", "origin")
                    DamageUnit({
                      bj = "祢豆子位移",
                      unit = xq.handle,
                      source = u.handle,
                      damage = txsh,
                      level = 1,
                      type = "物理",
                      isvest = false,
                      isattack = true,
                      isnoarmor = false,
                      element = "无",
                      extradata = {"近战"}
                    })
                    if u:getdata("祢豆子-形态") == 1 then
                      unitmove({
                        unit = xq.handle,
                        time = 0.5,
                        distance = 350,
                        angle = AngleBetweenUnits(u.handle, xq.handle)
                      })
                    end
                  end
                end
              })
            end
          end
          
          u:addtrgevent("单位-发动技能", function(args)
            skill(args)
          end)
        end
      })
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not tg:hasdata("鬼血术破抗") then
          tg:settimedata("鬼血术破抗", 5)
          tg:buffset(u.handle, 5, "破坏-伤害抗性")
          tg:groupadd(HpGroup)
          tg:groupadd(g)
          tg:effectadd("war3mapImported\\K3_Tx (1).mdl", "overhead", 5)
        end
      end)
      u:setdata("祢豆子-形态", 1)
      u:changedata("力量增幅", 0.125)
      ChangeValue(Hero_Tili_Huifu, sy, 0.1)
      u:banweaponskill()
      local size = tonumber(slk.unit[ID2S(u.type)].modelScale)
      local mbsize = size * 1.3
      local startsize = size
      local dsize = (mbsize - startsize) / 40
      u:setsize(startsize)
      ac.timer(30, 40, function()
        startsize = startsize + dsize
        u:setsize(startsize)
      end)
      
      local function chattrg(args)
        if args.chat == "形态切换" and u:isalive() then
          u:effectadd("Abilities\\Spells\\Human\\Polymorph\\PolyMorphDoneGround.mdl")
          if u:getdata("祢豆子-形态") == 1 then
            u:uivar_change({
              keyname = "祢豆子",
              keytype = "传奇栏",
              text = "|cFFFF66FF灶门祢豆子|r\n|CffFF66FF鬼|r\n|Cffff99ff提升20点力量与1点力量成长\n夜晚提升1%生命恢复\n力量大于100时提升1%生命恢复\n提升20%移速\n每次饮用血统药剂提升2~6点力量\n提升[力量*0.01%]伤害加成|r\n|Cffff66ff身体控制|r\n|Cffff99ff输入'形态切换'来切换形态\n能改变身体大小获得不同能力\n当前形态-[小]:\n提升50额外移速\n提升25闪避值\n提升2.5%伤害加成|r\n|Cffff66ff怪力|r\n|Cffff99ff基础位移技能改变\n无法再装备近战武器|r\n|Cffff66ff鬼血术|r\n|Cffff99ff自身直接伤害过的单位沾染鬼血破坏抗性5秒|r\n|Cffffa8ff允许使用[鬼血术]|r\n|Cffff66ff守护|r\n|Cffff99ff[数据删除]|r"
            })
            u:banskill("A0X2")
            u:changedata("力量增幅", -0.125)
            ChangeValue(Hero_Tili_Huifu, sy, -0.1)
            u:banweaponskill(true)
            u:setdata("祢豆子-形态", 2)
            ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 50)
            ChangeValue(DamageSystem_Shjc, sy, 0.025)
            u:changedata("闪避值", 25)
            local size = tonumber(slk.unit[ID2S(u.type)].modelScale)
            local mbsize = size * 0.7
            local startsize = size * 1.3
            local dsize = (mbsize - startsize) / 40
            u:setsize(startsize)
            ac.timer(30, 40, function()
              startsize = startsize + dsize
              u:setsize(startsize)
            end)
          else
            u:uivar_change({
              keyname = "祢豆子",
              keytype = "传奇栏",
              text = "|cFFFF66FF灶门祢豆子|r\n|CffFF66FF鬼|r\n|Cffff99ff提升20点力量与1点力量成长\n夜晚提升1%生命恢复\n力量大于100时提升1%生命恢复\n提升20%移速\n每次饮用血统药剂提升2~6点力量\n提升[力量*0.01%]伤害加成|r\n|Cffff66ff身体控制|r\n|Cffff99ff输入'形态切换'来切换形态\n能改变身体大小获得不同能力\n当前形态-[大]:\n提升12.5%力量\n提升0.1体力恢复\n允许使用[闪击]\n飞踢伤害翻倍,体力消耗翻倍|r\n|Cffff66ff怪力|r\n|Cffff99ff基础位移技能改变\n无法再装备近战武器|r\n|Cffff66ff鬼血术|r\n|Cffff99ff自身直接伤害过的单位沾染鬼血破坏抗性5秒|r\n|Cffffa8ff允许使用[鬼血术]|r\n|Cffff66ff守护|r\n|Cffff99ff[数据删除]|r"
            })
            ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -50)
            ChangeValue(DamageSystem_Shjc, sy, -0.025)
            u:changedata("闪避值", -25)
            u:banweaponskill()
            u:setdata("祢豆子-形态", 1)
            u:changedata("力量增幅", 0.125)
            ChangeValue(Hero_Tili_Huifu, sy, 0.1)
            u:banskill("A0X2", false)
            local size = tonumber(slk.unit[ID2S(u.type)].modelScale)
            local mbsize = size * 1.3
            local startsize = size * 0.7
            local dsize = (mbsize - startsize) / 40
            u:setsize(startsize)
            ac.timer(30, 40, function()
              startsize = startsize + dsize
              u:setsize(startsize)
            end)
          end
        end
        if args.chat == "爆血" and u:isalive() then
          if 25 >= u:getperhp() then
            u:sethp(1)
            u:kill()
          else
            u:losshp(u, 0.25 * (u:gethp() + u:getmaxhp()))
          end
          u:playsound(Midouzi_101)
          local x, y = u:getxy()
          local txsh = 400 * u:getlevel() + 200 * u:getstr()
          Effectcreate("war3mapImported\\[AKE]war3AKE.com - 4164979330353287516582371.mdl", x, y)
          Effectcreate("war3mapImported\\120.mdl", x, y)
          Effectcreate("war3mapImported\\effect_by_wood_effect_d2_shadowfiend_shadowraze_1.mdl", x, y)
          local g2 = CreateGroupLua()
          ForGroupLuaNew(g, function(xq)
            xq:groupadd(g2)
            local x2, y2 = xq:getxy()
            for _, xq2 in ac.selector():in_rangexy(x2, y2, 325):is_enemy(u.handle):isnotingroup(g):ipairs() do
              xq2 = getunit(xq2)
              xq2:groupadd(g2)
              xq2:settimedata("鬼血术破抗", 5)
              xq2:buffset(u.handle, 5, "破坏-伤害抗性")
              xq2:groupadd(HpGroup)
              xq2:groupadd(g)
              xq2:effectadd("war3mapImported\\K3_Tx (1).mdl", "overhead", 5)
            end
          end)
          for _, xq in ac.selector():in_rangexy(x, y, 900):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:groupadd(g2)
          end
          ForGroupLuaNew(g2, function(xq)
            xq:effectadd("war3mapImported\\Texiao_Xuebao.mdx", "overhead")
            xq:buffset(u.handle, 3, "眩晕")
            DamageUnit({
              bj = "祢豆子血鬼术",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "灵力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无",
              extradata = {""}
            })
          end)
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chattrg(args)
      end)
    end,
    effectname = "|cFFFF66FF灶门祢豆子|r",
    effecttext = "|CffFF66FF鬼|r\n|Cffff99ff提升20点力量与1点力量成长\n夜晚提升1%生命恢复\n力量大于100时提升1%生命恢复\n提升20%移速\n每次饮用血统药剂提升2~6点力量\n提升[力量*0.01%]伤害加成|r\n|Cffff66ff身体控制|r\n|Cffff99ff输入'形态切换'来切换形态\n能改变身体大小获得不同能力\n当前形态-[大]:\n提升12.5%力量\n提升0.1体力恢复\n允许使用[闪击]\n飞踢伤害翻倍,体力消耗翻倍|r\n|Cffff66ff怪力|r\n|Cffff99ff基础位移技能改变\n无法再装备近战武器|r\n|Cffff66ff鬼血术|r\n|Cffff99ff自身直接伤害过的单位沾染鬼血破坏抗性5秒|r\n|Cffffa8ff允许使用[鬼血术]|r\n|Cffff66ff守护|r\n|Cffff99ff[数据删除]|r",
    effectart = "war3mapImported\\BTNEwl_Midouzi.blp",
    test = [[

    ]]
  },
  {
    name = "八云紫",
    weight = 5,
    key = {
      "唯一",
      "东方",
      "外域"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I06F") then
        add = add + 3000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-八云紫") then
        b = true
      end
      if not u:ishasshw() then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:sendmessage("|cFF6633FF美少女出现了喔~|r")
      u:reduceshw()
      u:setdata("魔力毁坏概率", 4)
      u:setplayername("|cFF7DBEF1[|r|cFF6633FF八云紫|r|cFF7DBEF1]|r" .. NameID[sy])
      u:getgoddessforce(2, true)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        local gl = 5
        local fw = 300
        if u:ishasitem("I06F") then
          gl = 10
          fw = 350
        end
        if u:getluckrandom(gl * info.txgl) and not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 1)
          local txsh = 1000 * (u:getlevel() + 1)
          local dx, dy = tg:getxy()
          local gl2 = 10
          if u:hasdata("隐藏职业-天谴之子") then
            gl2 = gl2 * 2
          end
          Effectcreate("war3mapimported\\blackhole.mdx", dx, dy)
          for _, xq in ac.selector():in_rangexy(dx, dy, fw):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:buffset(u.handle, 3, "僵直")
            DamageUnit({
              bj = "八云紫附伤",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "灵力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
            if xq:isnormal() and u:getluckrandom(gl2) then
              xq:kill(u.handle)
            end
          end
        end
        tg:changedata("八云紫-魔力层数", 1)
        local need = 10
        if not tg:isnormal() then
          need = 25
        end
        if need <= tg:getdata("八云紫-魔力层数") then
          tg:setdata("八云紫-魔力层数", 0)
          tg:eliteschange(-1)
        end
      end)
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:getluckrandom(20) then
          info.wsmy = true
          info.wssb = true
        end
      end)
      u:addtrgevent("单位-指定点目标指令", function(args)
        if args.orderid == String2OrderIdBJ("smart") and not u:hasdata("间隙冷却") then
          local x = args.x
          local y = args.y
          mapmove(u.handle, "八云紫-境界操控", x, y)
        end
      end)
    end,
    effectname = "|cFF6633FF八云紫|r",
    effecttext = "|cFF6633FF唯一 东方 外域\n境界操控.限|r\n|cFF9999FF发布移动指令时瞬移至目标点并在0.8秒内极限闪避(触发冷却7秒)\n直接伤害时5%造成局部空间塌陷对300范围单位造成[1000+1000*等级]生命移除伤害同时僵直3秒且有10%即死普通单位|r\n|cFF6633FF境界线.限|r\n|cFF9999FF受到非时限伤害时12%免疫该次伤害并将目标随机传送，暂停目标3秒(对B0SS与强敌无效)|r\n|cFF6633FF灵力转换|r\n|cFF9999FF喝下变异药水时获得属性提升\n每次提升0.5%~0.1%伤害加成修正\n每次提升0.25%~0.5%受伤减少修正\n每次提升0.25%~0.5%魔力毁环触发概率|r\n|cFF6633FF魔力毁坏|r\n|cFF9999FF造成伤害时20%无视目标伤害免疫与伤害闪避\n对同一普通单位累积造成10次(精英25次BOSS无效)直接伤害时移除一个精英特性|r\n|cFF6633FF隙间亲和|r\n|cFF9999FF触发[隙间亲和]时不再发生位移改为隐身并提升300额外移速|r",
    effectart = "war3mapImported\\BTNEwl_Bayunzi.blp",
    test = [[

    ]]
  },
  {
    name = "奇迹の现人神",
    weight = 5,
    key = {"唯一", "巫女"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I02B") then
        add = add + 3000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-早苗") and u:getdata("东风谷早苗-信仰之力") >= 25 then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:sendmessage("|cFFFFFF33[祭祀风的人类]|r\n|cFF66FF99直接伤害时10%附带[400*信仰之力+800*等级]命运灵力伤害\n提升50额外移速\n提升8%额外移速|r")
      u:adddivinity(1)
      u:getgoddessforce(1)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 50)
      ChangeValue(HeroMenu_ExtraMoveSpeed_Bfb, sy, 0.08)
      if u:hasdata("东风谷早苗-风祝的巫女") then
        local x, y = u:getxy()
        local mj = u:createunit("h027", x, y)
        mj:setguard(u.handle)
      end
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效2冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效2冷却", 0.5)
          local x, y = tg:getxy()
          Effectcreate("ATx\\[ATxNew]Light_08.mdl", x, y)
          local txsh = 400 * u:getdata("东风谷早苗-信仰之力") + 800 * u:getlevel()
          DamageUnit({
            bj = "奇迹的现人神附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "灵力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "风",
            extradata = {""}
          })
        end
        if u:hasdata("东风谷早苗-风之祈愿") and not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(5 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 0.5)
          local x, y = u:getxy()
          local txsh = 300 * u:getlevel() + 5000
          local angle = AngleBetweenUnits(u.handle, tg.handle)
          unifycreate({
            owner = u.handle,
            model = "war3mapImported\\[TX] (278).mdl",
            modelname = "风之息",
            modelsize = 1,
            height = 75,
            damage = txsh,
            damagetype = 1,
            x = x,
            y = y,
            range = 1600,
            speed = 2000,
            volume = 250,
            angle = angle,
            angleoffset = 0,
            attenua = 1,
            attenuacount = 999,
            life = 10,
            isbullet = false,
            isvest = true,
            isignorearmor = false,
            startfunc = function(mj)
              mj:setdata("循环计数", 0)
            end,
            loopfunc = function(mj)
              mj:changedata("循环计数", UnifyDT)
              if mj:getdata("循环计数") >= 0.03 then
                mj:setdata("循环计数", 0)
                local dx, dy = mj:getxy()
                Effectcreate("Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl", dx, dy)
              end
            end,
            hitfunc = function(mj, damage)
              return damage
            end,
            hitbeforefunc = function(mj, xq, damage2)
            end,
            hitafterfunc = function(mj, xq, damage2)
              xq:buffset(u.handle, 1, "眩晕")
            end,
            endfunc = function(mj)
            end
          })
        end
      end)
    end,
    effectname = "|cFF66FF99奇迹の现人神|r",
    effecttext = "|cFF66FF99唯一 巫女\n根据累积的信仰之力解锁效果|r\n|cFF66FF9925点：|r|cFFFFFF33[祭祀风的人类]|r\n|cFF66FF9940点：|r|cFFFFFF33[风之祈愿]、[风之息]|r\n|cFF66FF9955点：|r|cFFFFFF33[诹访子的加护]|r\n|cFF66FF9970点：|r|cFFFFFF33[神奈子的加护]|r\n|cFF66FF9985点：|r|cFFFFFF33[神の风]、[风雨湖的神通者]|r\n|cFF66FF99100点：|r|cFFFFFF33[神乐祈舞]|r",
    effectart = "war3mapImported\\BTNEwl_Sanae_Qijidexianrenshen.blp",
    test = [[

    ]]
  },
  {
    name = "奇迹の祝福",
    weight = 5,
    key = {"唯一", "光明"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I02B") then
        add = add + 3000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:ishasitem("I02B") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:sendmessage("|cFFFFFF00你仿佛听到了奇迹的呼唤|r")
      u:adddivinity(1)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
      ChangeValue(Damage_ElementRes_Wind, sy, 15)
      ChangeValue(Damage_ElementRes_Water, sy, 15)
      ac.loop(250, function()
        if u:isalive() then
          local x, y = u:getxy()
          for _, xq in ac.selector():in_rangexy(x, y, 1200):is_enemy(u.handle):of_unify():ipairs() do
            xq = getunit(xq)
            if GetRandom100(10) then
              xq:sendmessage("|cFF66FF99奇迹の祝福-风之殇|r")
              xq:setdata("弹幕-生命值", 0)
            end
          end
        end
      end)
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("早苗-破抗") then
          info.wssb = true
          info.wsmy = true
        end
      end)
      ac.loop(60000, function()
        if u:isalive() then
          local skilladd
          local sj = GetRandomInt(1, 6)
          if sj == 1 then
            u:sendmessage("|cFFFFFF00奇迹「神の风」\n医疗回复最大生命值30%的血量\n持续时间内增加10%移动速度|r")
            u:curehp(u.handle, 0, 30, 1)
            skilladd = "S02P"
          end
          if sj == 2 then
            u:sendmessage("|cFFFFFF00奇迹「ミラクルフルーツ」\n持续时间内增加1.5%伤害加成,伤害加成\n持续时间内增加15%RPM,15%暴击率和暴击伤害|r")
            u:curehp(u.handle, 0, 30, 1)
            skilladd = "S02P"
            ChangeTimeValue(DamageSystem_Shjc, sy, 0.015, 45)
            ChangeTimeValue(DamageSystem_Shjc, sy, 0.015, 45)
            ChangeTimeValue(DamageSystem_Shjc, sy, 0.015, 45)
            ChangeTimeValue(Correction_RPM, sy, 0.15, 45)
            ChangeTimeValue(DamageSystem_Baoshang, sy, 0.15, 45)
            ChangeTimeValue(DamageSystem_Baoji, sy, 15, 45)
          end
          if sj == 3 then
            u:sendmessage("|cFFFFFF00奇迹「ファフロッキーズの奇迹」\n获得两个特殊补给箱的物品|r")
            u:additem("I00X")
            u:additem("I00X")
          end
          if sj == 4 then
            u:sendmessage("|cFFFFFF00奇迹「弘安の神风」\n持续时间内提升150点固伤减少|r")
            u:changetimedata("固定格挡", 150, 45)
          end
          if sj == 5 then
            u:sendmessage("|cFFFFFF00奇迹「客星の明るすぎる夜」\n持续时间内幸运加3,增加0.2体力恢复,增加2点固有回复,提升自身30%医疗修正|r")
            u:changetimedata("幸运", 3, 45)
            ChangeTimeValue(Hero_Tili_Huifu, sy, 0.2, 45)
            ChangeTimeValue(HeroMenu_HpCure_Inr, sy, 2, 45)
            ChangeTimeValue(Correction_CureUp, sy, 0.3, 45)
          end
          if sj == 6 then
            u:sendmessage("|cFFFFFF00奇迹「白昼の客星」\n持续时间内造成的伤害无视敌人抗性|r")
            u:settimedata("早苗-破抗", 45)
          end
          if skilladd then
            u:addskill(skilladd)
            ac.wait(45000, function()
              u:delskill(skilladd)
            end)
          end
        end
      end)
      if u:hasdata("东风谷早苗-风祝的巫女") or u:hasdata("判定-早苗") then
        u:setdata("早苗-信仰之力获取")
        Zaomiao_xinyangzengjia(u, 10)
        local cs = 0
        ac.loop(1000, function()
          if u:isalive() then
            cs = cs + 1
            if 90 <= cs then
              cs = 0
              Zaomiao_xinyangzengjia(u, 1)
            end
            if not u:hasdata("早苗-奇迹的现人神触发") and u:hasdata("东风谷早苗-风祝的巫女") and u:hasdata("血统判定-风神") and u:hasdata("变异判定-奇迹の祝福") then
              u:setdata("早苗-奇迹的现人神触发")
              NameID[sy] = "|cFF00FF99奇迹の现人神|r"
              u:setplayername(NameID[sy])
              PlayBGM({
                bgm = BGM_Sanae_03,
                time = 190,
                ID = 58,
                unit = u.handle
              })
            end
          end
        end)
      end
    end,
    effectname = "|cFFFFFF33奇迹の祝福|r",
    effecttext = "|cFFFFFF33神性 1\n唯一 光明\n奇迹の洗礼|r\n|cFF66FF99强化信仰之力获取|r\n|cFFFFFF33奇迹の加护|r\n|cFF66FF99自身额外受伤修正仅判定时减半|r\n|cFFFFFF33风之殇|r\n|cFF66FF99提升25额外移速\n提升15%水抗与风抗\n自身周围300范围敌对弹幕概率消除|r\n|cFFFFFF33奇迹の音|r\n|cFF66FF99杀敌时提升1点生命上限\n杀敌时4%提升1点体力上限\n杀敌时4%提升1点智力|r\n|cFFFFFF33奇迹の恩惠|r\n|cFF66FF99每60秒获得一次随机效果持续45秒|r\n|cFFFFFF33祀られる风の人间|r",
    effectart = "war3mapImported\\BTNEwl_Qijidezhufu.blp",
    test = [[

    ]]
  },
  {
    name = "圣大人",
    clickfunc = function(u)
      if u:isalive() and u:ishasshw() then
        AdvanceGet["桔梗"](u)
      end
    end,
    weight = 5,
    key = {"唯一", "巫女"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-桔梗") then
        b = true
      end
      if not u:hasdata("系统-特殊获取中") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:sendmessage("|cFF9999FF只|r|cFFA394F5是|r|cFFAD8FEB一|r|cFFB88AE0名|r|cFFC285D6普|r|cFFCC80CC通|r|cFFD67AC2的|r|cFFE075B8巫|r|cFFEB70AD女|r")
      ChangeValue(DamageSystem_Shjc, sy, 0.02)
      u:additem("I0CF")
      local g = CreateGroupLua()
      ac.loop(200, function()
        ForGroupLuaNew(g, function(xq)
          DamageUnit({
            bj = "圣大人附伤",
            unit = xq.handle,
            source = u.handle,
            damage = xq:getdata("桔梗-流血伤害") * (1 + 0.01 * xq:getdata("桔梗-流血层数")) * 0.4,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无",
            extradata = {""}
          })
          if GetRandom100(33) then
            xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
          end
          if xq:getdata("桔梗-流血层数") <= 0 then
            xq:groupremove(g)
            xq:deldata("桔梗-流血层数")
            xq:deldata("桔梗-流血伤害")
          end
        end)
      end)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not info.isvestdamage then
          tg:groupadd(g)
          if tg:getdata("桔梗-流血层数") < 20 then
            tg:changetimedata("桔梗-流血层数", 1, 10)
            tg:changetimedata("桔梗-流血伤害", 0.5 * info.yssh, 10)
          end
        end
      end)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.8, 1)
      ChangeValue(HeroMenu_HpForever_MaxHp, sy, 1.25)
      local dskill = S2ID("A038")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            local x, y = u:getxy()
            EnumItemsInRectBJ(RECT_PlayArea, function()
              local wp = GetEnumItem()
              local wptype = GetItemTypeId(wp)
              if GetItemLifeBJ(wp) > 0 and (wptype == S2ID("I05J") or wptype == S2ID("I0BR") or wptype == S2ID("I0BQ")) then
                SetItemPosition(wp, x, y)
                u:addspeitem(wp)
              end
            end)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
    end,
    effectname = "|cFF9999FF圣|r|cFFB2B2FF大|r|cFFCCCCFF人|r",
    effecttext = "|cFF9999FF只|r|cFFA394F5是|r|cFFAD8FEB一|r|cFFB88AE0名|r|cFFC285D6普|r|cFFCC80CC通|r|cFFD67AC2的|r|cFFE075B8巫|r|cFFEB70AD女|r",
    effectart = "war3mapImported\\BTNEwl_Jg_40",
    test = [[

    ]]
  },
  {
    name = "千子村正",
    clickfunc = function(u)
      if u:isalive() then
        local sy = u.ownerid
        if System_Count_Weapon >= 3 and u:ishasshw() then
          AdvanceGet["千子村正神化"](u)
        else
          u:sendmessage("|cFF7DBEF1神兵现世数量不足/无神化位|r")
          u:sendmessage("|cFF7DBEF1累积现世神兵：" .. System_Count_Weapon)
        end
      end
    end,
    weight = 5,
    key = {
      "唯一",
      "光明",
      "战士"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I0A7") then
        add = add + 3000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-千子村正") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:playsound(Sound_Senji_10)
      u:sendmessage("|cFFFF0000我|r|cFFFF0400不|r|cFFFF0700过|r|cFFFF0B00是|r|cFFFF0F00个|r|cFFFF1200很|r|cFFFF1600久|r|cFFFF1A00以|r|cFFFF1D00前|r|cFFFF2100的|r|cFFFF2400武|r|cFFFF2800器|r|cFFFF2C00贩|r|cFFFF2F00子|r|cFFFF3300…|r|cFFFF3700…|r|cFFFF3A00为|r|cFFFF3E00了|r|cFFFF4200不|r|cFFFF4500愧|r|cFFFF4900于|r|cFFFF4D00你|r|cFFFF5000和|r|cFFFF5400这|r|cFFFF5700具|r|cFFFF5B00身|r|cFFFF5F00体|r|cFFFF6200，|r|cFFFF6600就|r|cFFFF6A00让|r|cFFFF6D00我|r|cFFFF7100挥|r|cFFFF7500起|r|cFFFF7800这|r|cFFFF7C00把|r|cFFFF7F00救|r|cFFFF8300人|r|cFFFF8700之|r|cFFFF8A00剑|r|cFFFF8E00吧|r|cFFFF9200。|r")
      u:become("从者")
      Weiyi_Dz[25] = true
      u:addskill("S06S")
      u:addskill("S06O")
      u:addskill("S06Q")
      ChangeValue(DamageSystem_Baoji, sy, 12)
      local js1 = 0
      local js2 = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Baoshang, sy, -js2)
        js2 = 0.02 * System_Count_Weapon
        ChangeValue(DamageSystem_Baoshang, sy, js2)
      end)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        local add = 25 * u:getallattri() + 300 * u:getlevel()
        if add >= 0.5 * info.damage then
          add = 0.5 * info.damage
        end
        if u:getluckrandom(15) then
          info.damage = info.damage * 1.5
        end
        info.damage = info.damage + add
        if u:hasdata("神化判定-千子村正") then
          u:setdata("业之眼破抗")
        end
      end)
      u:addstexiao(var.name, "怪物减伤计算", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:setdata("业之眼破抗") then
          info.ewjs = 1
          u:deldata("业之眼破抗")
        end
      end)
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        info.wsmy = true
      end)
    end,
    effectname = "|cFFFF0000桑名|r|cFFFF3D00的|r|cFFFF5C00刀匠|r",
    effecttext = "|cFFFF0000战士 光明\n试剑术|r\n|cFFFF3D00提升25%近战范围\n提升25%近战武器伤害\n近战伤害15%造成150%伤害\n近战伤害增加[全属性*25+等级*300],不会超过伤害值的50%\n使用近战武器时附带一次同范围伤害(触发冷却3秒)|r\n|cFFFF0000冶炼阵地|r\n|cFFFF3D00提升全队12%移速\n降低全队30%锻造消耗\n提升全队25%当前锻造成功率|r\n|cFFFF0000刀剑审美|r\n|cFFFF3D00无视伤害免疫\n提升12%暴击率\n提升[累计神兵数*2%]暴击伤害|r\n|cFFFF0000当代不吉|r\n|cFFFF3D00杀敌时提升1生命上限\n杀敌时10%提升1点属性\n所有带有『王』属性的单位提升25%额外受伤|r",
    effectart = "war3mapImported\\BTNEwl_Senji_01.blp",
    test = [[

    ]]
  },
  {
    name = "浮士德",
    clickfunc = function(u, var)
      local sy = u.ownerid
      if not u:hasdata("浮士德-瞬移关闭") then
        u:setdata("浮士德-瞬移关闭")
        u:sendmessage("|cFFDCDBCD[浮士德]瞬移关闭")
      else
        u:deldata("浮士德-瞬移关闭")
        u:sendmessage("|cFFDCDBCD[浮士德]瞬移关闭")
      end
    end,
    weight = 1200,
    lv = 3,
    key = {"唯一", "罪人"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if CIUC[sy] == "-565684037" and not ModeSelect_Difficult then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Fsd_Cq)
      NPCChat({
        name = "|cFFDCDBCD浮|r|cFFACACA2士|r|cFF7D7C76德|r",
        chaticon = "Chat_Fsd.blp",
        chattext = {
          {
            text = "|cFFE0DFD3这里是|r|cFFFEB0B4Faust|r",
            time = 0
          },
          {
            text = "|cFFE0DFD3一位你这一生有幸遇到哪怕只有一次的天才",
            time = 2
          },
          {
            text = "|cFFE0DFD3我知道你有很多疑问，|r|cFF9C2C2CDante|r",
            time = 7
          },
          {
            text = "|cFFE0DFD3我可以为你大多数的好奇心提供|r|cFFFEB0B4答案|r",
            time = 9.3
          },
          {
            text = "|cFFE0DFD3如果你正在寻找一个能回答你疑问的人，那就来找我吧|r",
            time = 13.2
          },
          {
            text = "|cFFE0DFD3.....不，让我订正一下|r",
            time = 17.3
          },
          {
            text = "|cFFE0DFD3不是大多数的疑问|r",
            time = 21.4
          },
          {
            text = "|cFFE0DFD3----而是|r|cFF9C2C2C全部|r",
            time = 23.4
          }
        }
      })
      ac.wait(24500, function()
        PlayBGM({
          bgm = Baoming_BGM_05,
          time = 225,
          ID = 243,
          unit = u.handle
        })
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        ChangeValue(Correction_Jzsh, sy, 5.0E-5)
        ChangeValue(Correction_Magic, sy, 5.0E-6)
        u:changemaxhp(GetRandomInt(1, 3))
      end)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      do
        local cloak_effect_hidden_key = "浮士德-环绕特效关闭"
        u:addtrgevent("玩家-聊天", function(args)
          if args.chat ~= "-cl" then
            return
          end
          if u:hasdata(cloak_effect_hidden_key) then
            u:deldata(cloak_effect_hidden_key)
            u:sendmessage("|cFFDCDBCD[浮士德]环绕特效已显示|r")
          else
            u:setdata(cloak_effect_hidden_key)
            u:sendmessage("|cFFDCDBCD[浮士德]环绕特效已隐藏|r")
          end
        end)
        for i = 1, 3 do
          local x, y = u:getxy()
          local tx = EffectcreateArgs({
            effect = "Encrypt\\ZK_YHSZ_Cl.mdx",
            x = x - 16,
            y = y - 16,
            time = -1,
            size = 0.7,
            height = 0,
            zxz = 120 * i
          })
          ac.loop(30, function()
            if u:isalive() and not u:hasdata(cloak_effect_hidden_key) then
              local x, y = u:getxy()
              x = x - 16
              y = y - 16
              local loc = Location(x, y)
              local h = GetLocationZ(loc)
              RemoveLocation(loc)
              SetEffectHeight(tx, h)
              SetEffectXY(tx, x, y)
            else
              SetEffectXY(tx, PX_X, PX_Y)
            end
          end)
        end
        local cloak_effect2_hidden_key = "浮士德-环绕特效2关闭"
        u:addtrgevent("玩家-聊天", function(args)
          if args.chat ~= "-cl2" then
            return
          end
          if u:hasdata(cloak_effect2_hidden_key) then
            u:deldata(cloak_effect2_hidden_key)
            u:sendmessage("|cFFDCDBCD[浮士德]环绕特效2已显示|r")
          else
            u:setdata(cloak_effect2_hidden_key)
            u:sendmessage("|cFFDCDBCD[浮士德]环绕特效2已隐藏|r")
          end
        end)
        local x, y = u:getxy()
        local tx = EffectcreateArgs({
          effect = "Encrypt\\ZK_YHSZ_Cl1.mdx",
          x = x - 16,
          y = y - 16,
          time = -1,
          size = 0.7,
          height = 0
        })
        ac.loop(30, function()
          if u:isalive() and not u:hasdata(cloak_effect2_hidden_key) then
            local x, y = u:getxy()
            x = x - 16
            y = y - 16
            local loc = Location(x, y)
            local h = GetLocationZ(loc)
            RemoveLocation(loc)
            SetEffectHeight(tx, h)
            SetEffectXY(tx, x, y)
          else
            SetEffectXY(tx, PX_X, PX_Y)
          end
        end)
        local cloak_effect3_hidden_key = "浮士德-环绕特效3关闭"
        u:addtrgevent("玩家-聊天", function(args)
          if args.chat ~= "-cl3" then
            return
          end
          if u:hasdata(cloak_effect3_hidden_key) then
            u:deldata(cloak_effect3_hidden_key)
            u:sendmessage("|cFFDCDBCD[浮士德]环绕特效3已显示|r")
          else
            u:setdata(cloak_effect3_hidden_key)
            u:sendmessage("|cFFDCDBCD[浮士德]环绕特效3已隐藏|r")
          end
        end)
        local x, y = u:getxy()
        local tx = EffectcreateArgs({
          effect = "Encrypt\\ZK_YHSZ_Wcl.mdx",
          x = x - 16,
          y = y - 16,
          time = -1,
          size = 0.7,
          height = 0
        })
        ac.loop(30, function()
          if u:isalive() and not u:hasdata(cloak_effect3_hidden_key) then
            local x, y = u:getxy()
            x = x - 16
            y = y - 16
            local loc = Location(x, y)
            local h = GetLocationZ(loc)
            RemoveLocation(loc)
            SetEffectHeight(tx, h)
            SetEffectXY(tx, x, y)
          else
            SetEffectXY(tx, PX_X, PX_Y)
          end
        end)
      end
      do
        local head_frame = 1
        local head_frame_direction = 1
        local head_image = PlayerImageHeadUI.set_texture(u, "HeadPh\\HeadPh_Fsd (" .. head_frame .. ").blp", 300, 384, -15, 105)
        if head_image then
          ac.loop(66, function()
            head_frame = head_frame + head_frame_direction
            if 30 <= head_frame then
              head_frame = 30
              head_frame_direction = -1
            elseif head_frame <= 1 then
              head_frame = 1
              head_frame_direction = 1
            end
            PlayerImageHeadUI.set_texture(u, "HeadPh\\HeadPh_Fsd (" .. head_frame .. ").blp")
          end)
          do
            local head_alpha = 255
            local head_alpha_direction = -2
            japi.DzFrameSetAlpha(head_image, head_alpha)
            ac.loop(30, function()
              head_alpha = head_alpha + head_alpha_direction
              if head_alpha <= 55 then
                head_alpha = 55
                head_alpha_direction = 2
              elseif 255 <= head_alpha then
                head_alpha = 255
                head_alpha_direction = -2
              end
              japi.DzFrameSetAlpha(head_image, head_alpha)
            end)
          end
        end
      end
      ChangeValue(HeroMenu_HpForever_Inr, sy, 10)
      local fhp = 0
      local cs = 0
      local jzmax = 0
      ac.loop(3000, function()
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, -fhp)
        ChangeValue(DamageSplit_CountJzMax, sy, -jzmax)
        fhp = 0.01 * u:getdata("系统-累积等级")
        jzmax = 0.005 * u:getdata("系统-累积等级")
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, fhp)
        ChangeValue(DamageSplit_CountJzMax, sy, jzmax)
        if u:isalive() then
          cs = cs + 1
          if u:getdata("战斗时间") == 0 and u:getdata("浮士德-硬化屏障层数") < 10 then
            u:changedata("浮士德-硬化屏障层数", 1)
          end
          if 5 <= cs then
            cs = 0
            local add = u:getdata("浮士德-硬化屏障层数") + u:getdata("浮士德-硬化重构层数")
            local hp = add * 1
            local dhp = u:getmissperhp()
            local tili = 0
            if hp > dhp then
              tili = hp - dhp
              hp = hp - tili
            end
            u:curehp(u.handle, 0, hp, 1)
            if 0 < tili then
              u:curetili(tili)
            end
          end
        end
      end)
      ac.loop(1000, function()
        if u:isalive() and u:getdata("浮士德-天究星刀层数") < 20 then
          u:changedata("浮士德-天究星刀层数", 1)
        end
      end)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        info.damage = info.damage * (1 + 0.01 * u:getdata("浮士德-天究星刀层数"))
        if not info.isvestdamage and not u:hasdata(var.name .. "-特效3冷却") then
          u:settimedata(var.name .. "-特效3冷却", 1.5)
          tg:buffset(u.handle, 1, "灼烧")
        end
      end)
      u:addskill("S0CT")
      ChangeValue(DamageSystem_Baoji, sy, 10)
      ChangeValue(DamageSystem_Baoshang, sy, 0.3)
      ChangeValue(DamageSystem_Shjc, sy, 0.05)
      ChangeValue(Correction_Gun, sy, 0.05)
      ChangeValue(Correction_Jzsh, sy, 0.05)
      u:setdata("系统-无视伤害免疫")
      if u:islocal() then
        BuffUI.apply({
          id = "浮士德-硬化屏障"
        })
        BuffUI.apply({
          id = "浮士德-天究星刀"
        })
      end
      u:addstexiao(var.name, "受伤后效果", function(args)
        local u = args.u
        local tg = args.tg
        if not u:hasdata(var.name .. "-受伤特效冷却") then
          u:settimedata(var.name .. "-受伤特效冷却", 1)
          u:changedata("浮士德-天究星刀层数", 5)
          if u:getdata("浮士德-天究星刀层数") >= 20 then
            u:setdata("浮士德-天究星刀层数", 20)
          end
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:getdata("浮士德-硬化屏障层数") < 10 and not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 2)
          u:changedata("浮士德-硬化屏障层数", 1)
        end
        if not tg:isnormal() and not u:hasdata(var.name .. "-特效2冷却") and u:getluckrandom(info.txgl * 5) then
          u:settimedata(var.name .. "-特效2冷却", 1)
          local txsh = 55555 + 120 * u:getallattri()
          if 10 <= u:getdata("浮士德-天究星刀层数") then
            txsh = txsh * 2
            u:changedata("浮士德-天究星刀层数", -10)
            LossHpUnit({
              u = u,
              tg = tg,
              damage = txsh,
              perhp = 1,
              maxhp = 0,
              bj = "[生命损耗]天究星刀"
            })
          else
            LossHpUnit({
              u = u,
              tg = tg,
              damage = 0,
              perhp = 0.5,
              maxhp = 0,
              bj = "[生命损耗]天究星刀"
            })
            DamageUnit({
              bj = "[浮士德]天究星刀",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 5,
              type = "物理",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无",
              extradata = {}
            })
          end
        end
      end)
      u:addstexiao(var.name, "位移技能后效果", function(args)
        if not u:hasdata("浮士德-瞬移") and not u:hasdata("浮士德-瞬移关闭") and not u:hasdata("浮士德-瞬移冷却") then
          u:settimedata("浮士德-瞬移", 0.5)
        end
      end)
      u:addtrgevent("单位-指定点目标指令", function(args)
        if args.orderid == String2OrderIdBJ("smart") and u:hasdata("浮士德-瞬移") then
          u:deldata("浮士德-瞬移")
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          if 500 <= dis then
            dis = 500
          end
          x2, y2 = PolarXY(x, y, dis, angle)
          Effectcreate("ATX\\[ATxNew]Black_01.mdl", x, y)
          Effectcreate("ATX\\[ATxNew]Black_01.mdl", x2, y2)
          u:setxy(x2, y2)
        end
      end)
    end,
    effectname = "|cFFDCDBCD浮|r|cFFACACA2士|r|cFF7D7C76德|r",
    effecttext = "|cFFDCDBCD你人生中绝无仅有的天才。|r",
    effectart = "Cq_Fsd_01",
    test = [[

    ]]
  },
  {
    name = "朝武芳乃",
    weight = 5,
    key = {
      "唯一",
      "光明",
      "巫女"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-朝武芳乃") then
        b = true
      end
      if not u:hasdata("系统-特殊获取中") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Fangnai_02)
      PlayBGM({
        bgm = 0,
        time = 220,
        ID = 183,
        unit = u.handle
      })
      SendMsgAll("|cFFFF99FF『|r|cFFFCA0FB早|r|cFFF8A8F8上|r|cFFF5AFF4好|r|cFFF1B6F1~|r|cFFEEBDED』|r")
      SendDtimeMsgAll(3.4, "|cFFFF99FF『|r|cFFFBA2FB不|r|cFFF7AAF7要|r|cFFF3B2F3紧|r|cFFEFBBEE』|r")
      SendDtimeMsgAll(5, "|cFFFF99FF『|r|cFFFE9BFE而|r|cFFFD9DFD且|r|cFFFC9FFC请|r|cFFFBA1FB放|r|cFFFBA2FA心|r|cFFFAA4F9，|r|cFFF9A6F9我|r|cFFF8A8F8昨|r|cFFF7AAF7天|r|cFFF6ACF6已|r|cFFF5AEF5经|r|cFFF4B0F4认|r|cFFF3B2F3真|r|cFFF3B3F2查|r|cFFF2B5F1过|r|cFFF1B7F0朋|r|cFFF0B9EF友|r|cFFEFBBEE之|r|cFFEEBDED间|r|cFFEDBFEC的|r|cFFECC1EC问|r|cFFEBC3EB候|r|cFFEBC4EA语|r|cFFEAC6E9了|r|cFFE9C8E8』|r")
      SendDtimeMsgAll(11.7, "|cFFFF99FF『|r|cFFFD9EFC咳|r|cFFFAA3FA…|r|cFFF8A8F8…|r|cFFF5ADF5要|r|cFFF3B2F2说|r|cFFF1B8F0了|r|cFFEEBDEE噢|r|cFFECC2EB』|r")
      SendDtimeMsgAll(15, "|cFFFF99FF『|r|cFFFE9CFEC|r|cFFFC9EFCi|r|cFFFBA1FBa|r|cFFFAA4FAl|r|cFFF9A6F8l|r|cFFF7A9F7o|r|cFFF6ACF6～|r|cFFF5AEF4(|r|cFFF4B1F3∠|r|cFFF2B4F2・|r|cFFF1B7F1ω|r|cFFF0B9EF<|r|cFFEFBCEE |r|cFFEDBFED)|r|cFFECC1EB⌒|r|cFFEBC4EA☆|r|cFFEAC7E9』|r")
      ac.wait(17000, function()
        PlayGlobalSound(BGM_Fangnai_01)
        songtext({
          text = {
            {
              starttime = 14.1,
              str = "骤雨描绘出心中的光景 在那刹那间的邂逅"
            },
            {
              starttime = 20.2,
              str = "让蜿蜒曲折的命运 转瞬之间 消逝如烟"
            },
            {
              starttime = 26.6,
              str = "未能触及音容姿颜 却还指引着你我相见"
            },
            {
              starttime = 33.3,
              str = "无法抗拒这份对你的思念 不知为何胸口火热"
            },
            {
              starttime = 40.9,
              str = "红潮泛起的脸颊 藏不住我的思恋"
            },
            {
              starttime = 44,
              str = "不想被你察觉才移开了视线"
            },
            {
              starttime = 47.3,
              str = "不知不觉来到了梦之湖畔"
            },
            {
              starttime = 50.4,
              str = "始起的清风拂遍这世界"
            },
            {
              starttime = 53.6,
              str = "请尽情享用这恋情的花蕾",
              time = 3.4
            },
            {
              starttime = 69,
              str = "那一轮红月 点缀了冰冷寂灭"
            },
            {
              starttime = 72.7,
              str = "平淡无奇的每一天 此去经年 悄然消失不见"
            },
            {
              starttime = 81.9,
              str = "只求这份思念紧紧与他相连 即使未能看见他的容颜"
            },
            {
              starttime = 88.4,
              str = "在这七彩斑斓的彩虹桥上 解开束缚命运的锁链"
            },
            {
              starttime = 96.7,
              str = "定格了赤足独步的瞬间"
            },
            {
              starttime = 101,
              str = "把所有谎言和戏言都丢到天边"
            },
            {
              starttime = 104,
              str = "红着眼流着泪来到了梦之湖畔"
            },
            {
              starttime = 107.3,
              str = "第一次知晓恋爱的香甜"
            },
            {
              starttime = 110,
              str = "请尽情品尝这绯色之花",
              time = 4
            },
            {
              starttime = 139.2,
              str = "拥入怀中 把天空完全遮掩"
            },
            {
              starttime = 145.5,
              str = "两人共度的时间里 香甜蔓延",
              time = 6.7
            },
            {
              starttime = 153.2,
              str = "红潮泛起的脸颊 藏不住我的思恋"
            },
            {
              starttime = 156.2,
              str = "不想被你察觉才移开了视线"
            },
            {
              starttime = 159.4,
              str = "不知不觉来到了梦之湖滨"
            },
            {
              starttime = 162.5,
              str = "始起的清风拂遍这世界"
            },
            {
              starttime = 165.7,
              str = "定格了赤足独步的瞬间"
            },
            {
              starttime = 168.8,
              str = "把一切谎言和欺骗都丢到天边"
            },
            {
              starttime = 172,
              str = "红着眼流着泪来到了梦之湖滨"
            },
            {
              starttime = 175.2,
              str = "第一次尝到恋爱的甘甜"
            },
            {
              starttime = 178.3,
              str = "品尝这 恋爱吧 品尝这 恋爱吧"
            },
            {
              starttime = 181.5,
              str = "请尽情品尝这恋爱的花蕾吧",
              time = 3.3
            }
          },
          color = "FFFF99FF"
        })
      end)
      ChangeValue(Correction_Exp, sy, 0.15)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        u:changearmor(3)
        u:changemaxhp(200)
        if u:hasdata("神乐铃-持有") then
          u:changearmor(3)
          u:changemaxhp(200)
        end
      end)
      u:addskill("S0BK")
      ForGroupLuaNew(Group_PlayHero, function(xq)
        local sy2 = xq.ownerid
        ChangeValue(Correction_Exp, sy2, 0.1)
        ChangeValue(DamageSystem_Ssjianshao, sy2, 0.9, 1)
        xq:addskill("S0BJ")
      end)
      ChangeValue(KillReward_MHp, sy, 2)
      u:addstexiao(var.name, "杀敌效果", function(args)
        u:changedata("朝武芳乃-巫女层数", 1)
        ChangeValue(DamageSystem_Shjc, sy, 8.0E-5)
        ChangeValue(Damage_Element_Light, sy, 5.0E-4)
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:getluckrandom(10 * info.txgl) and not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 2.5)
          local dx, dy = tg:getxy()
          Effectcreate("Tx_Fangnai_01.mdx", dx, dy)
          Effectcreate("Tx_Cwfn_01.mdx", dx, dy, 0.1)
          if GetRandomReal(25) then
            u:playsound(Sound_Fangnai_01)
          end
          local txsh = 30000 + u:getmaxhp() * 10
          DamageUnit({
            bj = "朝武芳乃附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "灵力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "光"
          })
        end
      end)
      u:setdata("朝武芳乃-药水成功率降低", 0.3)
      local sszj = 0
      local hp = 0
      ac.loop(3000, function()
        ChangeValue(Correction_MHp, sy, 0.1 * -hp)
        ChangeValue(DamageSystem_Sszengjia, sy, -sszj)
        if u:hasdata("神乐铃-持有") then
          hp = -0.15
          sszj = 0.15
          u:setdata("朝武芳乃-药水成功率降低", 0.15)
        else
          hp = -0.3
          sszj = 0.3
          u:setdata("朝武芳乃-药水成功率降低", 0.3)
        end
        ChangeValue(Correction_MHp, sy, 0.1 * hp)
        ChangeValue(DamageSystem_Sszengjia, sy, sszj)
      end)
    end,
    effectname = "|cFFFF99FF巫|r|cFFFCA0FB女|r|cFFF1B6F1姬|r",
    effecttext = "|cFFFFCCFF芳乃，神之集芳也。|r\n|cFFFFBBFF称其真神，则黜斥万伪矣。|r\n|cFFFFAAFF信者存真神于心，后寻芳之本也。|r\n|cFFFF99FF芳之不可颓，信之不可背。|r\n|cFFFF88FF芳乃始遂为一物，无以纳异之故也。|r ",
    effectart = "Ewl_Cwfn_Cq",
    test = [[

    ]]
  },
  {
    name = "百百",
    rightclickfunc = function(u)
      local sy = u.ownerid
      if not u:hasdata("变异判定-死神之眼") then
        u:setdata("变异判定-死神之眼")
        u:changedata("瞳变异数量", 1)
        jibingpanding_tong(u)
        u:addskill("A151")
        u:changedata("根源变异数量", 1)
        ChangeValue(DamageSystem_Baoji, sy, 8)
        ChangeValue(DamageSystem_Shjc, sy, 0.014)
        PlayGlobalSound(Sound_Momo_03)
        u:chat("|cFFD9453F没错 我就是基拉|r")
        ac.wait(2600, function()
          u:chat("|cFFD9453F而且……|r")
        end)
        ac.wait(4000, function()
          u:chat("|cFFD9453F是新世界の神|r")
        end)
        u:addstexiao("死神之眼", "终结伤害计算效果", function(args)
          local tg = args.tg
          local u = args.u
          local info = args.damageinfo
          if tg:isnormal() then
            info.end3 = info.end3 + 0.14
          end
        end)
        u:addstexiao("死神之眼", "抗性破坏阶段", function(args)
          local u = args.u
          local tg = args.tg
          local info = args.damageinfo
          info.pk_benyuan = true
          info.pk_mohu = true
        end)
        u:uivar_add({
          keyname = "死神之眼",
          keytype = "传奇栏",
          text = "|cFFD9453F死神之眼|r\n|cFFD9453F根源\n神性 0\n所谓规则，自古以来就是身处神的位置的人定下的\n人是注定要死的\n是我赢了\n永别了\n[死神只吃苹果]|r",
          icon = "Ewl_Momo_tong_2"
        })
      end
    end,
    weight = 5,
    key = {
      "唯一",
      "光明",
      "黑暗",
      "灵魂",
      "白毛"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-百百") then
        b = true
      end
      if not u:hasdata("系统-特殊获取中") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:adddivinity(1)
      u:getgoddessforce(1)
      PlayGlobalSound(Sound_Momo_01)
      SendMsgAll("『|cffeaeaea纯|r|cffd5d5d5白|r|cffbfbfbfの|r|cffaaaaaa死|r|cff959595神|r|cff808080』|r|cffc0c0c0百百：『死神   A-100100号』|r")
      SendDtimeMsgAll(3.8, "『|cffeaeaea纯|r|cffd5d5d5白|r|cffbfbfbfの|r|cffaaaaaa死|r|cff959595神|r|cff808080』|r|cffc0c0c0百百：『叫我小百就行了』|r")
      SendDtimeMsgAll(8.1, "『|cffeaeaea纯|r|cffd5d5d5白|r|cffbfbfbfの|r|cffaaaaaa死|r|cff959595神|r|cff808080』|r|cffc0c0c0百百：『赐予死亡之人』|r")
      SendDtimeMsgAll(11.8, "『|cffeaeaea纯|r|cffd5d5d5白|r|cffbfbfbfの|r|cffaaaaaa死|r|cff959595神|r|cff808080』|r|cffc0c0c0百百：『换句话说  也就是『夺取生命之人』的意思吧』|r")
      ChangeValue(DamageSystem_Baoji, sy, 10)
      ChangeValue(DamageSystem_Baoshang, sy, 0.1)
      ChangeValue(DamageSystem_Shjc, sy, 0.044)
      ChangeValue(DamageSystem_EndSh, sy, 0.009)
      ChangeValue(Damage_ElementRes_Heart, sy, 25)
      ChangeValue(Correction_Jzsh, sy, 0.011000000000000001)
      u:changedata("灵魂变异补正", 25)
      ModelReplace({
        u = u,
        model = "mr.war3_momo1.mdx",
        modelsize = 1,
        modelname = "『|cffeaeaea纯|r|cffd5d5d5白|r|cffbfbfbfの|r|cffaaaaaa死|r|cff959595神|r|cff808080』|r|cffc0c0c0百百|r",
        modelicon = "Portrait_momo.tga",
        isforce = true
      })
      if u:islocal() then
        BuffUI.apply({
          id = "百百-累积灵魂计数"
        })
      end
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if tg:isnormal() then
          local jl = 1.4
          if u:hasdata("隐藏职业-天谴之子") then
            jl = jl * 2
          end
          if u:hasdata("瓦拉齐亚之夜-夜晚强化") then
            jl = jl * 2
          end
          if u:getluckrandom(jl) then
            tg:kill(u.handle)
          end
        end
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        u:curehp(u.handle, 0, 1, 5)
        u:curetili(1)
        local add = 1
        if tg:isboss() then
          add = 250
        elseif tg:iselite() then
          add = 10
        else
          add = 1
        end
        if u:hasdata("物品-死神镰刀") then
          add = add * 1.25
        end
        u:changedata("百百-灵魂计数", add)
        u:changedata("百百-累积灵魂计数", add)
        if u:getdata("百百-灵魂计数") >= 25 then
          local sxadd = math.floor(u:getdata("百百-灵魂计数") / 25)
          u:addallstats(sxadd)
          u:changedata("百百-灵魂计数", -25 * sxadd)
        end
      end)
      u:changedata("精灵力", 1)
      u:addint(u:getlevel())
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        u:addint(1)
      end)
      u:changedata("魔导变异数量", 1)
      u:changedata("冰变异数量", 1)
      u:uivar_add({
        keyname = "神的守墓人",
        keytype = "传奇栏",
        text = "|cFF7DBEF1神|r|cFF68A9F3の|r|cFF5394F6守|r|cFF3F7FF8墓|r|cFF2A6BFA人|r\n|cFF7DBEF1冰 魔导\n神性0 精灵力1\n精灵王的女儿|r\n|cFF2A6BFA[数据被篡改]|r\n|cFF7DBEF1失忆的少女|r\n|cFF2A6BFA[最后的秘密]|r",
        icon = "Ewl_Momo_Cq_01"
      })
      for index, value in ipairs(Pools_SpeDzWeapon) do
        if value.name == "死神镰刀" then
          if not value.hasbeenget then
            local item = u:additem("I0JT")
            System_Count_Weapon = System_Count_Weapon + 1
            SetData(item, "物品判定-神兵")
            SetData(item, "神兵-获取")
            value.hasbeenget = true
          end
          break
        end
      end
      ac.loop(3000, function()
        if GetRandom100(0.12) then
          u:setdata("百百-爱哭鬼判定")
        end
        if u:hasdata("百百-爱哭鬼判定") and u:getdata("百百-爱哭鬼触发次数") < 2 and not u:hasdata("百百-爱哭鬼触发中") then
          u:deldata("百百-爱哭鬼判定")
          u:changedata("百百-爱哭鬼触发次数", 1)
          if u:getdata("百百-爱哭鬼触发次数") == 1 then
            local add = 444
            if u:hasdata("物品-死神镰刀") then
              add = add * 1.25
            end
            u:changedata("百百-灵魂计数", add)
            PlayBGM({
              bgm = 0,
              time = 20,
              ID = 0
            })
            PlayGlobalSound(Sound_Momo_05)
            u:settimedata("百百-爱哭鬼触发中", 20)
            SendMsgAll("|cff565656『|r|cff5c4a4a黑|r|cff623d3d猫|r|cff683131』|r|cff6e2525丹|r|cff741919尼|r|cff7a0c0c尔|r|cff800000：『小百你真是个爱哭鬼呢』|r")
            SendDtimeMsgAll(4.1, "『|cffeaeaea纯|r|cffd5d5d5白|r|cffbfbfbfの|r|cffaaaaaa死|r|cff959595神|r|cff808080』|r|cffc0c0c0百百：『因为死去的人是不会哭泣的』|r")
            SendDtimeMsgAll(7.7, "『|cffeaeaea纯|r|cffd5d5d5白|r|cffbfbfbfの|r|cffaaaaaa死|r|cff959595神|r|cff808080』|r|cffc0c0c0百百：『所以就由我来代替他们哭泣』|r")
          end
          if u:getdata("百百-爱哭鬼触发次数") == 2 then
            local add = 444
            if u:hasdata("物品-死神镰刀") then
              add = add * 1.25
            end
            u:changedata("百百-灵魂计数", add)
            PlayBGM({
              bgm = 0,
              time = 25,
              ID = 0
            })
            PlayGlobalSound(Sound_Momo_04)
            u:settimedata("百百-爱哭鬼触发中", 25)
            SendMsgAll("|cff565656『|r|cff5c4a4a黑|r|cff623d3d猫|r|cff683131』|r|cff6e2525丹|r|cff741919尼|r|cff7a0c0c尔|r|cff800000：『又不由自主地流泪了？』|r")
            SendDtimeMsgAll(2.2, "|cff565656『|r|cff5c4a4a黑|r|cff623d3d猫|r|cff683131』|r|cff6e2525丹|r|cff741919尼|r|cff7a0c0c尔|r|cff800000：『小百也真是的 永远都是那么的爱哭』|r")
            SendDtimeMsgAll(6.9, "『|cffeaeaea纯|r|cffd5d5d5白|r|cffbfbfbfの|r|cffaaaaaa死|r|cff959595神|r|cff808080』|r|cffc0c0c0百百：『你还真烦呢』|r")
            SendDtimeMsgAll(8.3, "|cff565656『|r|cff5c4a4a黑|r|cff623d3d猫|r|cff683131』|r|cff6e2525丹|r|cff741919尼|r|cff7a0c0c尔|r|cff800000：『在还没有预定要死的人面前出现好几次』|r")
            SendDtimeMsgAll(14, "『|cffeaeaea纯|r|cffd5d5d5白|r|cffbfbfbfの|r|cffaaaaaa死|r|cff959595神|r|cff808080』|r|cffc0c0c0百百：『有什么关系』|r")
            SendDtimeMsgAll(16, "|cff565656『|r|cff5c4a4a黑|r|cff623d3d猫|r|cff683131』|r|cff6e2525丹|r|cff741919尼|r|cff7a0c0c尔|r|cff800000：『我觉得你闲事管得太多了』|r")
            SendDtimeMsgAll(19.5, "『|cffeaeaea纯|r|cffd5d5d5白|r|cffbfbfbfの|r|cffaaaaaa死|r|cff959595神|r|cff808080』|r|cffc0c0c0百百：『是啊』|r")
            SendDtimeMsgAll(21.6, "『|cffeaeaea纯|r|cffd5d5d5白|r|cffbfbfbfの|r|cffaaaaaa死|r|cff959595神|r|cff808080』|r|cffc0c0c0百百：『不过 那就是我』|r")
          end
        end
      end)
      ac.wait(20000, function()
        ac.loop(10000, function(timer)
          if u:hasdata("变异判定-黑猫") then
            u:changedata("外域变异数量", -1)
            ChangeValue(Correction_Exp, sy, 0.05)
            u:addskill("S0BF")
            PlayGlobalSound(Sound_Momo_02)
            SendMsgAll("|cff565656『|r|cff5c4a4a黑|r|cff623d3d猫|r|cff683131』|r|cff6e2525丹|r|cff741919尼|r|cff7a0c0c尔|r|cff800000：『我知道你很爱哭』|r")
            SendDtimeMsgAll(1.8, "|cff565656『|r|cff5c4a4a黑|r|cff623d3d猫|r|cff683131』|r|cff6e2525丹|r|cff741919尼|r|cff7a0c0c尔|r|cff800000：『不过爱撒娇 又任性这两点你具备么』|r")
            SendDtimeMsgAll(4.1, "『|cffeaeaea纯|r|cffd5d5d5白|r|cffbfbfbfの|r|cffaaaaaa死|r|cff959595神|r|cff808080』|r|cffc0c0c0百百：『喵呜~』|r")
            SendDtimeMsgAll(4.8, "|cff565656『|r|cff5c4a4a黑|r|cff623d3d猫|r|cff683131』|r|cff6e2525丹|r|cff741919尼|r|cff7a0c0c尔|r|cff800000：『你又不是猫』|r")
            u:uivar_change({
              keyname = "黑猫",
              keytype = "冥王栏",
              text = "|cFF5B3233丹尼尔|r\n|cFF5B3233兽 唯一\n提升10%经验获取\n提升20%移速\n杀敌时5%使杀敌数+1(不触发杀敌效果)|r",
              icon = "Ewl_Momo_Cq_03"
            })
            timer:remove()
          end
        end)
        ac.wait(20000, function()
          if u:getdata("瞳变异数量") == 0 then
            u:setdata("变异判定-死神之眼")
            u:changedata("瞳变异数量", 1)
            u:addskill("A151")
            u:changedata("根源变异数量", 1)
            ChangeValue(DamageSystem_Baoji, sy, 8)
            ChangeValue(DamageSystem_Shjc, sy, 0.014)
            PlayGlobalSound(Sound_Momo_03)
            u:chat("|cFFD9453F没错 我就是基拉|r")
            ac.wait(2600, function()
              u:chat("|cFFD9453F而且……|r")
            end)
            ac.wait(4000, function()
              u:chat("|cFFD9453F是新世界の神|r")
            end)
            u:addstexiao("死神之眼", "终结伤害计算效果", function(args)
              local tg = args.tg
              local u = args.u
              local info = args.damageinfo
              if tg:isnormal() then
                info.end3 = info.end3 + 0.14
              end
            end)
            u:addstexiao("死神之眼", "抗性破坏阶段", function(args)
              local u = args.u
              local tg = args.tg
              local info = args.damageinfo
              info.pk_benyuan = true
              info.pk_mohu = true
            end)
            u:uivar_add({
              keyname = "死神之眼",
              keytype = "传奇栏",
              text = "|cFFD9453F死神之眼|r\n|cFFD9453F根源\n神性 0\n所谓规则，自古以来就是身处神的位置的人定下的\n人是注定要死的\n是我赢了\n永别了\n[死神只吃苹果]|r",
              icon = "Ewl_Momo_tong_2"
            })
          end
        end)
      end)
    end,
    effectname = "|cFFCCCCCC死|r|cFFC2C2C2神の|r|cFFB8B8B8歌|r|cFFADADAD谣|r",
    effecttext = "|cFF999999传奇 唯一 光明 黑暗 灵魂 白毛\n神性1 女神力1\n死神|r\n|cFFCCCCCC[数据无权限阅览]|r\n|cFF999999死亡宣告|r\n|cFFCCCCCC[数据无权限阅览]|r\n|cFF999999灵魂收集|r\n|cFFCCCCCC[数据无权限阅览]|r\n|cFF999999爱哭鬼|r\n|cFFCCCCCC[为已死之人哭泣]|r",
    effectart = "Ewl_Momo_Cq_02",
    test = [[

    ]]
  },
  {
    name = "纳西妲",
    clickfunc = function(u, ewl)
      if u:isalive() then
        local sy = u.ownerid
        if u:ishasitem("I0JC") and not u:hasdata("变异判定-纳西妲神化") and u:getdata("灭诤草蔓使用数量") >= 9 and u:ishasshw() then
          AdvanceGet["纳西妲神化"](u)
        end
      end
    end,
    weight = 1,
    key = {
      "唯一",
      "光明",
      "自然",
      "风"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if not u:hasdata("系统-特殊获取中") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayBGM({
        bgm = BGM_Naxida_02,
        time = 60,
        ID = 176,
        unit = u.handle
      })
      PlayGlobalSound(Sound_Naxida_01)
      local str = "『初次见面，我已经关注你很久了。』"
      str = ColorfulMsg(str, {
        "|cFF66FF99",
        "|cFF99FF99",
        "|cFFCCFF99",
        "|cFFCCFFCC",
        "|cFF66FF66"
      })
      SendMsgAll(str)
      ac.wait(4800, function()
        local str = "『我叫纳西妲，别看我像个孩子，我比任何一位大人都了解这个世界。』"
        str = ColorfulMsg(str, {
          "|cFF66FF99",
          "|cFF99FF99",
          "|cFFCCFF99",
          "|cFFCCFFCC",
          "|cFF66FF66"
        })
        SendMsgAll(str)
      end)
      ac.wait(12000, function()
        local str = "『所以，我可以用我的知识，换取你路上的见闻吗？』"
        str = ColorfulMsg(str, {
          "|cFF66FF99",
          "|cFF99FF99",
          "|cFFCCFF99",
          "|cFFCCFFCC",
          "|cFF66FF66"
        })
        SendMsgAll(str)
      end)
      u:adddivinity(1)
      ChangeValue(Correction_Exp, sy, 0.2)
      local add = 0
      local sx = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        ChangeValue(Damage_Element_Wind, sy, -sx)
        local zd = u:returnmaxvar()
        add = 0.1 * u:getdata(zd .. "变异数量")
        sx = 0.01 * u:getdata(zd .. "变异数量")
        if u:hasdata("变异判定-纳西妲神化") then
          add = add * 2
          sx = sx * 2
          add = add + 0.25 * (u:getstate("自然变异") + u:getstate("风变异"))
        end
        ChangeValue(Damage_Element_Wind, sy, sx)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      end)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        u:addallstats(5)
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        ChangeValue(DamageSystem_Shjc, sy, 5.0E-5)
        ChangeValue(Damage_Element_Wind, sy, 5.0E-4)
        if GetRandom100(25) then
          ChangeValue(Damage_Element_Wind, sy, 5.0E-4)
          if u:getdata("大慈树王的诅咒-额外受伤") >= 0.001 then
            u:changedata("大慈树王的诅咒-额外受伤", -0.001)
            ChangeValue(DamageSystem_Sszengjia, sy, -0.001)
          end
        end
        if GetRandom100(5) then
          u:additem("I0JB")
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 1)
          local ds = 1
          if not u:hasdata(var.name .. "-特效2冷却") or u:getluckrandom(10 * info.txgl) then
            u:settimedata(var.name .. "-特效2冷却", 5)
            ds = 4
          end
          local txsh = 2500 * u:getlevel() + (50 + 10 * u:getdata("灭诤草蔓使用数量")) * u:getallattri()
          local dx, dy = tg:getxy()
          Effectcreate("Naxida_07.mdx", dx, dy, 1.5)
          for i = 1, ds do
            DamageUnit({
              bj = "纳西妲附伤",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "风"
            })
          end
        end
      end)
      ac.loop(10000, function()
        u:changedata("大慈树王的诅咒-额外受伤", 1.0E-4)
        ChangeValue(DamageSystem_Sszengjia, sy, 1.0E-4)
      end)
      u:uivar_add({
        keyname = "大慈树王的诅咒",
        keytype = "疾病栏",
        text = "|cFF66FF99大慈|r|cFF8CFFB2树王|r|cFFB2FFCC的诅咒|r\n|cFF66FF99诅咒每时每刻都在扰乱你的意志|r\n|cFFB2FFCC每秒增加0.01%额外受伤,杀敌时25%掉落散失的草神瞳|r",
        icon = "Ewl_Naxida_Zuzhou_2"
      })
      local dskill
      if u:ishasskill("A1AM") and u.type ~= HeroType["C呆"] and u.type ~= HeroType["莲华"] then
        dskill = "A09X"
      else
        dskill = "A09R"
      end
      Fskillreplace({
        unit = u.handle,
        level = 2,
        skill_F = dskill,
        skill_X = dskill,
        isforce = false,
        efunc = function()
          local function skill(args)
            if args.skill == S2ID(dskill) then
              local x, y = u:getxy()
              
              local x2 = args.x
              local y2 = args.y
              Effectcreate("Naxida_01.mdx", x2, y2, 1, 2.5)
              Effectcreate("Naxida_04.mdx", x2, y2, 0, 2.5)
              local by = u:createfogcorrector(x2, y2, 1200)
              ac.wait(8000, function()
                u:removefogcorrector(by)
              end)
              local rect = Rect(x2 - 750, y2 - 750, x2 + 750, y2 + 750)
              EnumItemsInRectBJ(rect, function()
                local wp = GetEnumItem()
                local wptype = GetItemTypeId(wp)
                if GetItemLifeBJ(wp) > 0 and (wptype == Materials["世界树之种"] or wptype == Materials["永远结冰"] or wptype == Materials["紫阳花"] or wptype == Materials["火灵草"] or wptype == Materials["海晶体"] or wptype == S2ID("I0GY") or wptype == S2ID("I08D") or wptype == S2ID("I0GX") or wptype == S2ID("I0GZ") or wptype == S2ID("I07N")) then
                  SetItemPosition(wp, x, y)
                  u:addspeitem(wp)
                end
              end)
              RemoveRect(rect)
              local txsh = 50000 + 25 * KillCount[sy]
              for _, xq in ac.selector():in_rangexy(x2, y2, 750):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:buffset(u.handle, 2, "僵直")
                xq:buffset(u.handle, 2, "缠绕")
                if u:hasdata("变异判定-纳西妲神化") then
                  xq:setdata("纳西妲-无视抗性")
                  DamageUnit({
                    bj = "纳西妲技能",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 4,
                    type = "魔力",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "风"
                  })
                end
              end
            end
          end
          
          u:addtrgevent("单位-发动技能", function(args)
            skill(args)
          end)
        end
      })
    end,
    effectname = "|cFF66FF99纳|r|cFF8CFFB2西|r|cFFB2FFCC妲|r",
    effecttext = "|cFF66FF99神性 1\n唯一 自然 光明 风\n【行相】|r\n|cFFB2FFCC提升[1%*主变异数量]伤害加成\n提升[1%*主变异数量]风属性伤害\n直接伤害时10%附带风魔力伤害,冷却1秒;触发时10%附带四段,冷却5秒\n无属性伤害转换为风伤害|r\n|cFF66FF99【净善摄受明论】|r\n|cFFB2FFCC升级时提升5点全属性\n提升20%经验获取\n杀敌时提升0.005%伤害加成与0.05%风属性伤害|r\n|cFF66FF99【诸相随念净行】|r\n|cFFB2FFCC替换F技能|r\n|cFF66FF99【熏习成就之芽】|r\n|cFFB2FFCC飞行|r",
    effectart = "Ewl_Naxida_10_10",
    test = [[

        ]]
  },
  {
    name = "朱雀院红叶",
    weight = 5,
    key = {
      "唯一",
      "白毛",
      "战士",
      "影"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-朱雀院红叶") and u:hasdata("变异判定-刀仕禰宜") and u:ishasshw() then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:reduceshw()
      ciyuanget(u, var)
      local str = "|cffd80e1e「|r|cffc22a44神|r|cffad466a眼|r|cff976291极|r|cff827eb7手|r|cff6c9add」|r|cffff0e11朱|r|cffff4218雀|r|cffff7620院|r|cffffaa28红|r|cffffde2f叶|r"
      NameID[sy] = str
      u:setplayername(NameID[sy])
      PlayGlobalSound(Sound_Hongye_Shenhua)
      SendDtimeMsgAll(0, str .. ":|cff5adce8我是特立独行的剑士，没有必要的话，就不需要老师|r", 10)
      SendDtimeMsgAll(5, str .. ":|cff47b2e8为了变强，我渴望更强大的对手，这对剑士而言是当然的|r", 10)
      SendDtimeMsgAll(12, str .. ":|cff479ae8我并不需要粉丝|r", 10)
      SendDtimeMsgAll(15, str .. ":|cffe08358不过，如果赢了朱雀院家的大小姐的话，就意味着要对她出手|r", 10)
      SendDtimeMsgAll(23, str .. ":|cff9867ff到,到那时,就得以结婚为前提，和我|r|cfff1b6f6交往|r|cff2acaff！|r", 10)
      SendDtimeMsgAll(30, str .. ":|cffbddde9你有那样的觉悟吗|r", 10)
      PlayBGM({
        bgm = 0,
        time = 365,
        ID = 184,
        unit = u.handle
      })
      ac.wait(28000, function()
        flashphoto({
          photo = "Ph_Hongye_End.tga",
          timeout = 2,
          timehold = 4,
          timein = 2
        })
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:buffset(u.handle, 8, "绝对闪避")
        end)
      end)
      ac.wait(35000, function()
        PlayGlobalSound(BGM_Hongye_01)
      end)
      flashphoto({
        photo = "Ph_Hongye_Start.tga",
        timeout = 2,
        timehold = 4,
        timein = 2
      })
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:buffset(u.handle, 8, "绝对闪避")
      end)
      u:adddivinity(3)
      ChangeValue(DamageSystem_EndSh, sy, 0.1 * (0.02 * u:getdata("白毛变异数量")))
      u:changedata("全属性增幅", 0.05)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.9, 1)
      ChangeValue(Correction_Jzsh, sy, 0.03)
      
      local function hongye_jingjiedianshuadd(add, addss)
        addss = addss or 0
        u:changedata("红叶-境界点数", add)
        if u:getdata("红叶-境界点数") >= 100 then
          u:setdata("红叶-境界点数", 100)
        else
          u:changedata("红叶-境界受伤", addss)
        end
        local chengshu = u:getdata("红叶-境界点数")
        if 10 <= chengshu and not u:hasdata("红叶-贯通的加护") then
          u:sendmessage("|cFFFF6666贯通の加护解锁|r")
          u:setdata("红叶-贯通的加护")
          u:setdata("系统-无视伤害闪避")
          u:addstexiao(var.name, "伤害系统计算效果", function(args)
            local tg = args.tg
            local info = args.damageinfo
            info.ewss = info.ewss + 0.02 * tg:getdata("神性")
          end)
        end
        if 25 <= chengshu and not u:hasdata("红叶-神速的加护") then
          u:sendmessage("|cFFFF6666神速の加护解锁|r")
          u:setdata("红叶-神速的加护")
          u:setdata("红叶-无视地形")
          ac.loop(500, function()
            if u:isalive() then
              local g = CreateGroupLua()
              local x, y = u:getxy()
              for _, xq in ac.selector():in_rangexy(x, y, 1500):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g)
              end
              if Group_Counts(g) > 0 then
                local tg = Group_Randomunit(g)
                local dx, dy = tg:getxy()
                local txsh = 5000 + 1000 * u:getlevel()
                for _, xq in ac.selector():in_rangexy(dx, dy, 250):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  DamageUnit({
                    bj = "红叶附伤",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 1,
                    type = "物理",
                    isvest = true,
                    isattack = true,
                    isnoarmor = false,
                    element = "无",
                    extradata = {""}
                  })
                end
              end
            end
          end)
        end
        if 50 <= chengshu and not u:hasdata("红叶-不灭的加护") then
          u:sendmessage("|cFFFF6666不灭の加护解锁|r")
          u:setdata("红叶-不灭的加护")
          u:addstexiao(var.name, "决死效果", function(args)
            if args.dt and not u:hasdata("红叶-决死冷却") then
              args.dt = false
              u:sendmessage("|cFFFF6600红叶-不灭の加护|r")
              u:settimedata("红叶-决死冷却", 360)
              u:buffset(u.handle, 1, "无敌")
              local cs = 0
              ac.loop(250, function(timer)
                cs = cs + 1
                u:sethp(100, true)
                if cs == 20 then
                  timer:remove()
                end
              end)
            end
          end)
        end
        if 75 <= chengshu and not u:hasdata("红叶-剑士的加护") then
          u:sendmessage("|cFFFF6666剑士の加护解锁|r")
          u:setdata("红叶-剑士的加护")
        end
        if 100 <= chengshu and not u:hasdata("红叶-天咒的加护") then
          u:sendmessage("|cFFFF6666天咒の加护解锁|r")
          u:setdata("红叶-天咒的加护")
        end
      end
      
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        ChangeValue(DamageSystem_Shjc, sy, 1.5E-4)
        if tg:isboss() then
          hongye_jingjiedianshuadd(25)
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          local txsh = info.yssh * (6 - Group_Counts(Group_Xingcunzu)) * 0.05
          u:settimedata(var.name .. "-特效冷却", 0.1)
          LossHpUnit({
            u = u,
            tg = tg,
            damage = txsh,
            perhp = 0,
            maxhp = 0,
            bj = "[生命损耗]朱雀院红叶"
          })
        end
      end)
      u:addstexiao(var.name, "近战伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          local yx = {
            Sound_Hongye_Tx01,
            Sound_Hongye_Tx02,
            Sound_Hongye_Tx03
          }
          u:playsound(yx[GetRandomInt(1, #yx)])
          u:settimedata(var.name .. "-特效冷却", 3)
          DamageUnit({
            bj = "红叶近战附伤",
            unit = tg.handle,
            source = u.handle,
            damage = info.yssh * 0.5,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = true,
            isnoarmor = false,
            element = "无",
            extradata = {
              "红叶-必暴"
            }
          })
        end
      end)
      u:addstexiao(var.name, "暴击系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("红叶-必暴") then
          info.iscbcrit = true
        end
      end)
      ChangeValue(DamageSplit_CountJzMax, sy, 0.5)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      local jz = 0
      local lwss = 1
      local hp = 0
      local gs = 0
      local cbxs = 0
      local yssh = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Jzsh, sy, 0.1 * -jz)
        ChangeValue(DamageSystem_Ssjianshao, sy, lwss, 2)
        ChangeValue(HeroMenu_HpCure_MaxHp, sy, -hp)
        u:changedata("固定伤害", 0.1 * -gs)
        ChangeValue(Correction_Cbxs, sy, -cbxs)
        jz = 0.05 * u:getstate("战士变异")
        if u:hasdata("红叶-天咒的加护") then
          lwss = 1
          yssh = 0.5 * u:getdata("红叶-境界受伤")
        else
          lwss = 1 + u:getdata("红叶-境界受伤")
          yssh = 0
        end
        if u:hasdata("红叶-不灭的加护") then
          hp = 0.002 * u:getshenxing()
        else
          hp = 0
        end
        if u:hasdata("红叶-剑士的加护") then
          gs = 10000 * u:getdata("传奇数量")
          cbxs = u:getdata("显示-暴击率") / 100 * 0.08
        else
          gs = 0
          cbxs = 0
        end
        ChangeValue(Correction_Cbxs, sy, cbxs)
        u:changedata("固定伤害", 0.1 * gs)
        ChangeValue(Correction_Jzsh, sy, 0.1 * jz)
        ChangeValue(DamageSystem_Ssjianshao, sy, lwss, 1)
        ChangeValue(HeroMenu_HpCure_MaxHp, sy, hp)
      end)
      u:setdata("红叶-境界增加函数", hongye_jingjiedianshuadd)
    end,
    effectname = "|cFFFFFFFF朱|r|cFFFFD4D4雀|r|cFFFFAAAA院|r|cFFFF8080红|r|cFFFF5555叶|r",
    effecttext = "|cFFFFD4D4白毛 战士 影 唯一\n刀仕襧宜|r\n|cFFFF5555[数据删除]|r\n|cFFFFD4D4独立独行|r\n|cFFFF5555[数据删除]|r\n|cFFFFD4D4万象天咒|r\n|cFFFF5555[贯通の加护]\n[神速の加护]\n[不灭の加护]\n[剑士の加护]\n[天咒の加护]|r\n|cFFFFD4D4秘剑燕返|r\n|cFFFF5555[数据删除]|r",
    effectart = "Ewl_Hongye_01",
    test = [[

        ]]
  },
  {
    name = "克萝蒂亚",
    weight = 5,
    key = {
      "唯一",
      "光明",
      "魔导",
      "黑暗",
      "星"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-克萝蒂亚") and u:ishasshw() and u:hasdata("变异判定-帝国的公主") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:reduceshw()
      ciyuanget(u, var)
      u:setdata("变异判定-伊芙")
      u:addskill("A1OJ")
      ChangeValue(DamageSystem_Shjc, sy, 0.02)
      ChangeValue(DamageSystem_Shjc, sy, 0.02)
      ChangeValue(Correction_Magic, sy, 0.005000000000000001)
      ChangeValue(DamageSystem_Shjc, sy, 0.03)
      ChangeValue(Hero_Tili_Huifu_Zq, sy, -0.3)
      ChangeValue(Hero_Tili_Max, sy, -10)
      ChangeValue(HeroMenu_ExtraMoveSpeed_Bfb, sy, -0.3)
      u:addskill("S09L")
      u:uivar_add({
        keyname = "伊芙",
        keytype = "传奇栏",
        text = "|cFF9999FF伊芙.|r|cFF6699FF阿斯托罗艾尔|r\n|cFF9999FF甜食 喜欢|r\n|cFF6699FF[数据删除]|r\n|cFF9999FFロエ.メランルージュ|r\n|cFF6699FF[数据删除]|r\n|cFF9999FF里表人格|r\n|cFF6699FF[数据删除]|r\n|cFF9999FF星辰|r\n|cFF6699FF[数据删除]|r\n|cFF9999FF最信赖的朋友|r\n|cFF6699FF[数据删除]|r",
        icon = "war3mapImported\\BTNEwl_Kldy_05"
      })
      local dskill = S2ID("A1OE")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if Qiyue_Kldy_Mb == 0 then
            b = false
            u:sendmessage("|cFF7DBEF1朋友不存在|r")
            ewl:setskillcd(dskill, 1)
            return
          end
          local tg = getunit(Qiyue_Kldy_Mb)
          local dis = DistanceBetweenUnits(u.handle, tg.handle)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if not tg:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1朋友死亡状态无法释放|r")
          end
          if 1800 <= dis then
            b = false
            u:sendmessage("|cFF7DBEF1超过1800码|r")
          end
          if u:hasdata("伊芙-公主抱加成") then
            b = false
            u:sendmessage("|cFF7DBEF1加成已存在|r")
          end
          if b then
            local sy2 = tg.ownerid
            u:setdata("伊芙-公主抱加成")
            tg:setdata("伊芙-公主抱加成")
            ChangeValue(DamageSystem_Shjc, sy, 0.02)
            ChangeValue(DamageSystem_Ssjianshao, sy, 0.8, 1)
            ChangeValue(Correction_Exp, sy, 0.1)
            ChangeValue(DamageSystem_Shjc, sy2, 0.02)
            ChangeValue(DamageSystem_Ssjianshao, sy2, 0.8, 1)
            ChangeValue(Correction_Exp, sy2, 0.1)
            u:sendmessage("|cFFFF99FF伊芙-公主抱加成|r")
            tg:sendmessage("|cFFFF99FF伊芙-公主抱加成|r")
            ac.loop(1000, function(timer)
              local dis = DistanceBetweenUnits(u.handle, tg.handle)
              if u:isalive() and tg:isalive() and dis <= 4800 then
              else
                ChangeValue(DamageSystem_Shjc, sy, -0.02)
                ChangeValue(DamageSystem_Ssjianshao, sy, 0.8, 2)
                ChangeValue(Correction_Exp, sy, -0.1)
                ChangeValue(DamageSystem_Shjc, sy2, -0.02)
                ChangeValue(DamageSystem_Ssjianshao, sy2, 0.8, 2)
                ChangeValue(Correction_Exp, sy2, -0.1)
                u:sendmessage("|cFFFF99FF失去伊芙-公主抱加成|r")
                tg:sendmessage("|cFFFF99FF失去伊芙-公主抱加成|r")
                timer:remove()
              end
            end)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      do
        local g = {}
        local cs = 0
        for i = 1, 5 do
          local x, y = u:getxy()
          local xcmj = u:createunit("n00M", x, y)
          xcmj:setflyheight(90)
          japi.SetUnitModel(xcmj.handle, "Kldy_100.mdl")
          g[#g + 1] = xcmj
        end
        local g2 = {}
        local cs = 0
        for i = 1, 5 do
          local x, y = u:getxy()
          local xcmj = u:createunit("n00M", x, y)
          g2[#g2 + 1] = xcmj
        end
        local dangle = GetRandomAngle()
        local x, y = u:getxy()
        local a = dangle
        local xh = 0
        local xhmax = 100
        local wx = {}
        local wy = {}
        for i = 1, 5 do
          a = a + 72
          wx[i], wy[i] = PolarXY(x, y, 300, a)
        end
        local dis = DistanceXY(wx[1], wy[1], wx[3], wy[3])
        ac.loop(30, function()
          local x, y = u:getxy()
          a = a + 0.1
          for i = 1, 5 do
            a = a + 72
            wx[i], wy[i] = PolarXY(x, y, 300, a)
            g2[i]:setxy(wx[i], wy[i])
          end
          xh = xh + 1
          for i = 1, 5 do
            a = a + 72
            local djd
            if i <= 3 then
              djd = AngleXY(wx[i], wy[i], wx[i + 2], wy[i + 2])
            else
              djd = AngleXY(wx[i], wy[i], wx[i - 3], wy[i - 3])
            end
            local dx, dy = PolarXY(wx[i], wy[i], dis * xh / xhmax, djd)
            g[i]:setxy(dx, dy)
            g[i]:setface(djd)
          end
          if xh >= xhmax then
            xh = 0
            local dg = g[1]
            for i = 1, #g - 1 do
              g[i] = g[i + 1]
            end
            g[#g] = dg
            for i = 1, #g do
              local dx, dy = g[i]:getxy()
              Effectcreate("Kldy_102.mdx", dx, dy)
            end
          end
        end)
      end
      local wpz = {
        "I0FY",
        "I0FX",
        "I0FZ",
        "I0G0",
        "I0G2",
        "I0G1"
      }
      ac.loop(45000, function()
        u:additem(wpz[GetRandomInt(1, 6)])
        u:effectadd("Tx_Kldy_Yw.mdx", "origin")
      end)
      local wpz = {"I0G4", "I0G3"}
      ac.loop(240000, function()
        u:additem(wpz[GetRandomInt(1, 2)])
        u:effectadd("Tx_Kldy_Yw.mdx", "origin")
      end)
      local cs = 0
      local lw = 0
      local jc = 0
      ac.loop(1000, function()
        cs = cs + 1
        if cs == 15 then
          cs = 0
          u:addrandomstats(1)
          u:addrandomdamage(1)
        end
        if u:getperhp() <= 50 and not u:hasdata("伊芙-恢复生命值冷却") then
          u:settimedata("伊芙-恢复生命值冷却", 20)
          u:curehp(u.handle, 0, 20, 4)
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jc)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -lw)
        lw = 0.01 * u:getlevel()
        jc = 0.02 * u:getlevel()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * jc)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * lw)
      end)
      Qiyue_Kldy_Zs = u.handle
      
      local function chattrg(args)
        if args.chat == "fx" then
          if u:hasdata("伊芙-飞行模式") then
            u:deldata("伊芙-飞行模式")
            u:sendmessage("|cFF6633FF翅膀关闭|r")
            u:delskill("A1OD")
          else
            u:setdata("伊芙-飞行模式")
            u:sendmessage("|cFF6633FF翅膀开启|r")
            u:addskill("A1OD")
          end
        end
        if args.chat == "杀戮" then
          if u:getmaxhp() <= 1000 then
            u:sendmessage("|cFF990000生命上限不足|r")
            return
          end
          if 1000 >= u:getdata("魔力值") then
            u:sendmessage("|cFF990000魔力值不足|r")
            return
          end
          if not u:isalive() then
            u:sendmessage("|cFF990000死亡状态|r")
            return
          end
          if not u:hasdata("克萝蒂亚-杀戮冷却") then
            u:settimedata("克萝蒂亚-杀戮冷却", 600)
            ac.wait(600000, function()
              u:sendmessage("|cFF990000杀戮冷却完毕|r")
            end)
            ChangeTimeValue(Correction_Gun, sy, 0.05, 60)
            ChangeTimeValue(DamageSystem_Shjc, sy, 0.1, 60)
            ChangeTimeValue(DamageSystem_Shjc, sy, 0.1, 60)
            ChangeTimeValue(DamageSystem_Shjc, sy, 0.05, 60)
            ChangeTimeValue(DamageSystem_Shjc, sy, 0.025, 60)
            u:changetimedata("固定伤害", 2000.0, 60)
            ChangeTimeValue(DamageSystem_Baoshang, sy, 0.5, 60)
            ac.wait(60000, function()
              u:settimedata("克萝蒂亚-杀戮惩罚", 120)
              u:changemaxhp(-1000)
              u:changedata("魔力值", -1000)
              u:sendmessage("|cFF990000进入杀戮虚弱状态|r")
              ac.wait(120000, function()
                u:sendmessage("|cFF990000脱离杀戮虚弱状态|r")
              end)
            end)
          else
            u:sendmessage("|cFF990000杀戮状态冷却中|r")
          end
        end
        if Qiyue_Kldy_Mb == 0 then
          local chat = string.sub(args.chat, 1, 3)
          if chat == "-xl" then
            if string.len(args.chat) >= 4 then
              local sy2 = tonumber(string.sub(args.chat, 4, 4))
              if Hero[sy2] ~= 0 and Hero[sy2] ~= u.handle and getunit(Hero[sy2]):isalive() and Hero[sy2] ~= Qiyue_Kldy_Mb then
                local tg = getunit(Hero[sy2])
                tg:sendmessage("|cFFF7C295你成为了克萝蒂亚最信赖的朋友|r")
                u:sendmessage("|cFFF7C295契约成立|r")
                tg:setdata("克萝蒂亚-契约加成")
                u:setdata("克萝蒂亚-契约加成")
                u:additem("I0G5")
                Qiyue_Kldy_Mb = tg.handle
                u:addskill("A1OL")
                tg:addskill("A1OL")
              else
                u:sendmessage("目标不合法")
              end
            else
              u:sendmessage("指令错误")
            end
          end
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chattrg(args)
      end)
    end,
    effectname = "|cFF6699FF爱丽丝.|r|cFFFF6666克萝蒂亚|r",
    effecttext = "|cFF6699FF杀手兔|r\n|cFFFF6666[数据删除]|r\n|cFF6699FF魔女|r\n|cFFFF6666[数据删除]|r\n|cFF6699FF最信赖的朋友|r\n|cFFFF6666[数据删除]|r",
    effectart = "war3mapImported\\BTNEwl_Kldy_03",
    test = [[

        ]]
  },
  {
    name = "隐匿者",
    clickfunc = function(u, ewl)
      if u:isalive() then
        local sy = u.ownerid
      end
    end,
    weight = 5,
    key = {
      "唯一",
      "光明",
      "魔导"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I0EF") then
        add = add + 5000
      end
      return add
    end,
    condition = function(u)
      local b = false
      local x, y = u:getxy()
      if u:hasdata("判定-队长") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:setdata("血统判定-人类")
      u:addskill("A1J6")
      u:addskill("S089")
      ChangeValue(HeroMenu_HpChange_MaxHp, sy, 1)
      u:adddivinity(1)
      u:changearmor(20)
      for index, value in ipairs(Pools_Spe) do
        if value.name == "星之奇迹" then
          if not value.hasbeenget then
            u:additem("I0EF")
            value.hasbeenget = true
          end
          break
        end
      end
      u:addstexiao(var.name, "伤害系统计算效果", function(args)
        local tg = args.tg
        local info = args.damageinfo
        if tg:isboss() then
          info.lw = info.lw + 0.5
        end
      end)
      SendDtimeMsgAll(0, "|cFFFFCC33『我们向全人类通告，』|r", 10)
      SendDtimeMsgAll(5, "|cFFFFCC33『这个古老的行星即将获得新生。』|r", 10)
      SendDtimeMsgAll(12.1, "|cFFFFCC33『空想之根已经坠落，』|r", 10)
      SendDtimeMsgAll(14.5, "|cFFFFCC33『创造之树遍布大地。』|r", 10)
      SendDtimeMsgAll(19.0, "|cFFFFCC33『我是沃戴姆，』|r", 10)
      SendDtimeMsgAll(21.3, "|cFFFFCC33『基尔什塔利亚·沃戴姆。』|r", 10)
      SendDtimeMsgAll(24.2, "|cFFFFCC33『作为七个隐匿者的代表，』|r", 10)
      SendDtimeMsgAll(27.1, "|cFFFFCC33『向你们发出通告。』|r", 10)
      SendDtimeMsgAll(30.0, "|cFFFFCC33『这颗行星的历史，』|r", 10)
      SendDtimeMsgAll(33.1, "|cFFFFCC33『将由吾等来继承。』|r", 10)
      PlayGlobalSound(Sound_Duizhang_01)
      ac.wait(37000, function()
        PlayGlobalSound(BGM_Duizhang_01)
      end)
      PlayBGM({
        bgm = 0,
        time = 127,
        ID = 128,
        unit = u.handle
      })
      local cs = 0
      local cs2 = 0
      ac.loop(1000, function()
        if u:isalive() then
          cs = cs + 1
          if not u:hasdata("隐匿者-护盾特效") then
            cs2 = cs2 + 1
          end
          if cs2 == 90 then
            cs2 = 0
            if not u:hasdata("隐匿者-护盾特效") then
              u:setdata("隐匿者-护盾特效", u:effectadd("war3mapImported\\2.26.831 (8).mdl", "chest", -1))
            end
            if u:hasdata("人理之光-星之修复") and u:getdata("人理之光-累积伤害") >= 0.1 * u:getmaxhp() then
              u:setdata("隐匿者-护盾值", 0.4 * u:getmaxhp())
              u:setdata("人理之光-累积伤害", 0)
              Hdzflash(u)
            else
              u:setdata("隐匿者-护盾值", 0.3 * u:getmaxhp())
              Hdzflash(u)
            end
          end
          if cs == 20 then
            cs = 0
            u:curehp(u.handle, 0, 30, 2)
            u:clearbuff("眩晕")
            u:clearbuff("僵直")
            u:clearbuff()
            u:effectadd("war3mapImported\\2.26.831 (2).mdl", "origin")
          end
        end
      end)
      
      local function chattrg(args)
        if args.chat == "照耀大地 高悬苍穹" and u:isalive() and u:ishasshw() and u:ishasitem("I0EF") and not u:hasdata("变异判定-人理之光") and GetItemCharges(u:getitem("I0EF")) >= 200 then
          AdvanceGet["队长神化"](u)
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chattrg(args)
      end)
    end,
    effectname = "|cFFFFFF33隐匿者|r",
    effecttext = "|cFFFFCC33魔导 光明\n最后的人类|r\n|cFFFFFF99[数据删除]|r\n|cFF3366FF奥尔良的堑壕|r\n|cFF6699FF[数据删除]|r\n|cFFFF6633七丘之城的黄昏|r\n|cFFFFCC99[数据删除]|r\n|cFFFF0066俄刻阿诺斯的干杯|r\n|cFFFF6699[数据删除]|r\n|cFF990000伦蒂尼恩的灭亡|r\n|cFFCC0000[数据删除]|r\n|cFFFF6633阿特拉斯的契约|r\n|cFFFF9966[数据删除]|r",
    effectart = "war3mapImported\\BTNEwl_Duizhang_06",
    test = [[

        ]]
  },
  {
    name = "玉藻前",
    clickfunc = function(u, ewl)
      if u:isalive() then
        local sy = u.ownerid
      end
    end,
    weight = 5,
    key = {"唯一", "魔导"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I039") then
        add = add + 5000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-玉藻前") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Yuzaoqian_Get)
      u:getgoddessforce(2)
      u:setdata("灵基突破次数", 0)
      u:become("从者")
      SendMsgAll("|cFFCC0099御用とあらば即参上！ あなたの頼れる巫女狐！ キャスター降っ臨っ！ で?す?|r")
      u:addskill("S02U")
      u:addstr(-20)
      u:changemaxmp(5)
      ChangeValue(DamageSystem_Shjc, sy, 0.005)
      ChangeValue(DamageSystem_Shjc, sy, 0.005)
      ChangeValue(DamageSystem_Shjc, sy, 0.005)
      local fq = 0
      ac.loop(3000, function()
        local add = 1.0E-5 * (2 + u:getdata("灵基突破次数")) * 3
        ChangeValue(Correction_Magic, sy, add)
        ChangeValue(Correction_Magic, sy, -fq)
        fq = (Correction_Magic[sy] - 1) * 0.05 * u:getdata("灵基突破次数")
        ChangeValue(Correction_Magic, sy, fq)
      end)
      for index, value in ipairs(Pools_Spe) do
        if value.name == "杀生石" then
          if not value.hasbeenget then
            local item = u:additem("I039")
            value.hasbeenget = true
          end
          break
        end
      end
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        u:addstr(-1)
      end)
      u:addstexiao(var.name, "伤害系统计算效果", function(args)
        local tg = args.tg
        local info = args.damageinfo
        if tg:hasbuff("冰冻") then
          info.zj = info.zj + 0.25
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        local x, y = u:getxy()
        local x2, y2 = tg:getxy()
        if u:hasdata("玉藻前-咒术") and u:getmp() >= 2 then
          if u:getluckrandom(15 * info.txgl) and not u:hasdata("炎天冷却") then
            Effectcreate("war3mapImported\\[TX] (327).mdl", x2, y2)
            if not u:hasdata("玉藻前-宝具释放中") then
              u:curemp(-2)
            end
            local txsh = u:getmp() * u:getdata("灵基突破次数") * u:getlevel()
            u:settimedata("炎天冷却", 1)
            for _, xq in ac.selector():in_rangexy(x2, y2, 400):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              local sunhao = 0
              if xq:isnormal() then
                sunhao = u:getdata("灵基突破次数") * 0.005 * xq:getmaxhp()
              else
                sunhao = u:getdata("灵基突破次数") * 5.0E-4 * xq:getmaxhp()
              end
              LossHpUnit({
                u = u,
                tg = xq,
                damage = sunhao,
                perhp = 0,
                maxhp = 0,
                bj = "[生命损耗]玉藻前咒术"
              })
              DamageUnit({
                bj = "玉藻前咒术附伤",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "魔力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "火"
              })
            end
          end
          if u:getluckrandom(15 * info.txgl) and not u:hasdata("霜天冷却") then
            Effectcreate("war3mapImported\\112.mdl", x2, y2)
            if not u:hasdata("玉藻前-宝具释放中") then
              u:curemp(-2)
            end
            if tg:isnormal() then
              tg:buffset(u.handle, 3, "冰冻")
            else
              tg:buffset(u.handle, 1, "冰冻")
            end
            u:settimedata("霜天冷却", 1)
          end
          if u:getluckrandom(15 * info.txgl) and not tg:hasdata("风天冷却") then
            Effectcreate("war3mapImported\\112.mdl", x2, y2)
            if not u:hasdata("玉藻前-宝具释放中") then
              u:curemp(-2)
            end
            tg:buffset(u.handle, 3, "僵直")
            if tg:isnormal() then
              tg:settimedata("风天冷却", 1)
            else
              tg:settimedata("风天冷却", 15)
            end
            if not u:hasdata("风天冷却") then
              u:settimedata("风天冷却", 1)
              u:changetimedata("风天层数", 1, 9)
              ChangeTimeValue(Correction_RPM, sy, 0.09, 9)
              ChangeTimeValue(DamageSystem_Baoji, sy, 9, 9)
              ChangeTimeValue(DamageSystem_Baoshang, sy, 0.09, 9)
            end
          end
        end
      end)
      
      local function chattrg2(args)
        if args.chat == "靡靡之音" then
          local xq = args.u
          xq:sendmessage("|cFFCC3366靡|r|cFFC22952靡|r|cFFB81F3D之|r|cFFAD1429音|r")
          if xq:isingroup(Group_DeathHero) then
            do
              local cs = 0
              ac.loop(1000, function(timer)
                if xq:isalive() then
                  xq:sendmessage("|cFF7DBEF1靡靡之音复活中断|r")
                  timer:remove()
                else
                  cs = cs + 1
                  if cs == 180 then
                    local x, y = u:getxy()
                    HeroRelive(xq.handle, x, y, 3)
                    xq:groupadd(Group_Yzq_Mimizhiyin)
                    xq:effectadd("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl")
                    timer:remove()
                  end
                end
              end)
            end
          end
        end
      end
      
      local function chattrg(args)
        if args.chat == "灵基突破" then
          if not u:isalive() then
            return
          end
          local lv = u:getdata("灵基突破次数")
          if 5 <= lv then
            return
          end
          local b1 = false
          local b2 = false
          local b3 = false
          local b4 = false
          if u:ishasitem("I039") then
            local wp = u:getitem("I039")
            local itemcount = GetItemCharges(wp)
            if 2 < lv then
              if 150 <= itemcount then
                b4 = true
              end
            elseif 100 <= itemcount then
              b4 = true
            end
          end
          if not b4 then
            b1 = CountedMedicine.has(u, MEDICINE_HUIYI, 1)
            b2 = CountedMedicine.has(u, MEDICINE_BLOOD, 1)
            if 2 < lv then
              b3 = CountedMedicine.has(u, MEDICINE_HUIYI, 2)
            else
              b3 = true
            end
          end
          if b1 and b2 and b3 or b4 then
            if b4 then
              local wp = u:getitem("I039")
              if 2 < lv then
                ChangeItemCount(wp, -150)
              else
                ChangeItemCount(wp, -100)
              end
            else
              CountedMedicine.consume(u, MEDICINE_HUIYI, 2 < lv and 2 or 1)
              CountedMedicine.consume(u, MEDICINE_BLOOD, 1)
            end
            u:changedata("灵基突破次数", 1)
            u:sendmessage("|cFF6600FF灵基突破成功 当前次数：" .. u:getdata("灵基突破次数"))
            IncUnitAbilityLevel(u.handle, S2ID("S02U"))
            u:changemaxmp(5)
            ChangeValue(DamageSystem_Shjc, sy, 0.005)
            ChangeValue(DamageSystem_Shjc, sy, 0.005)
            ChangeValue(DamageSystem_Shjc, sy, 0.005)
            local dlv = u:getdata("灵基突破次数")
            if dlv == 1 then
              u:setdata("玉藻前-神性")
              u:adddivinity(1)
              ChangeValue(DamageSystem_EndSh, sy, 0.002)
              u:uivar_change({
                keyname = "玉藻前",
                keytype = "传奇栏",
                text = "|cFFFF66FF玉藻前 - [1]次灵基突破|r\n|cFFFF66FF从者灵基|r\n|cFFCC99FF降低20点力量\n降低1点力量成长\n提升[5*(灵基突破层数+1)]魔力上限\n提升[5%*(灵基突破层数+1)]移速\n提升[0.5%当前法术修正*(灵基突破层数+1)]法术修正\n每秒提升[0.002%*(灵基突破层数+1)]法术修正\n提升[0.2%*灵基突破层数]终结伤害\n提升[5%*(灵基突破层数+1)]基础伤害\n提升[0.5%*(灵基突破层数+1)]伤害加成\n提升[0.5%*(灵基突破层数+1)]伤害加成|r\n|cFFFF66FF神性A|r\n|cFFCC99FF[10%+2%*灵基突破层数]使受到的伤害无效化|r\n|cFFFF66FF灵基突破|r\n|cFFCC99FF输入指令“灵基突破”消耗100点杀生石能量或(1瓶血统+1瓶回忆)来进行灵基突破|r\n|cFF949596「不不，其实我就是神哦？」|r"
              })
            end
            if dlv == 2 then
              u:playsound(Yuzaoqian_1d2)
              u:setdata("风天层数", 0)
              ChangeValue(DamageSystem_EndSh, sy, 0.002)
              u:uivar_change({
                keyname = "玉藻前",
                keytype = "传奇栏",
                text = "|cFFFF66FF玉藻前 - [2]次灵基突破|r\n|cFFFF66FF从者灵基|r\n|cFFCC99FF降低20点力量\n降低1点力量成长\n提升[5*(灵基突破层数+1)]魔力上限\n提升[5%*(灵基突破层数+1)]移速\n提升[0.5%当前法术修正*(灵基突破层数+1)]法术修正\n每秒提升[0.002%*(灵基突破层数+1)]法术修正\n提升[0.2%*灵基突破层数]终结伤害\n提升[5%*(灵基突破层数+1)]基础伤害\n提升[0.5%*(灵基突破层数+1)]伤害加成\n提升[0.5%*(灵基突破层数+1)]伤害加成|r\n|cFFFF66FF神性A|r\n|cFFCC99FF[10%+2%*灵基突破层数]使受到的伤害无效化|r\n|cFFFF66FF荼吉尼天法咒术EX|r\n|cFFCC99FF输入“荼吉尼天法咒术”来开启或关闭咒术触发,默认关闭\n开启时每秒削减1点生命上限 每次咒术触发消耗1点体力值\n不同咒术可以同时触发「炎天」「霜天」「风天」|r\n|cFFFF66FF灵基突破|r\n|cFFCC99FF输入指令“灵基突破”消耗150点杀生石能量或(2瓶回忆+1瓶血统)来进行灵基突破|r\n|cFF949596「给老娘忏悔吧！」|r"
              })
            end
            if dlv == 3 then
              u:setplayername("|cFF7DBEF1[|r|cFFFF66FF良妻贤狐|r|cFF7DBEF1]|r" .. NameID[sy])
              u:playsound(Yuzaoqian_2d3)
              u:setdata("玉藻前-变化")
              ChangeValue(HeroMenu_Sbxs, sy, 0.06)
              ChangeValue(DamageSystem_Ssjianshao, sy, 0.7, 1)
              ChangeValue(DamageSystem_EndSh, sy, 0.002)
              local dskill = S2ID("A09N")
              u:byladdskill(dskill, function(args)
                if args.skill == dskill then
                  local b = true
                  local tg = getunit(args.target)
                  local ewl = getunit(args.unit)
                  if not u:isalive() then
                    b = false
                    u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
                  end
                  if not tg:isingroup(Group_PlayHero) then
                    b = false
                    u:sendmessage("|cFF7DBEF1无法对非英雄释放|r")
                  end
                  if tg.handle == u.handle then
                    b = false
                    u:sendmessage("|cFF7DBEF1无法对自身释放|r")
                  end
                  if b then
                    local wp
                    local jg = 0
                    for i = 1, 6 do
                      wp = u:getcountitem(i)
                      local tpyeid = GetItemTypeId(wp)
                      if tpyeid == MEDICINE_JINGHUA then
                        jg = 1
                      end
                      if tpyeid == MEDICINE_YITAI then
                        jg = 2
                      end
                      if tpyeid == MEDICINE_LNS then
                        jg = 3
                      end
                      if tpyeid == MEDICINE_MWX then
                        jg = 4
                      end
                      if tpyeid == MEDICINE_BLOOD then
                        jg = 5
                      end
                      if tpyeid == MEDICINE_NIUQU then
                        jg = 6
                      end
                      if tpyeid == MEDICINE_HUIYI then
                        if u:hasdata("花嫁回忆冷却") then
                          jg = 0
                        else
                          jg = 7
                        end
                      end
                      if jg ~= 0 then
                        break
                      end
                    end
                    if jg ~= 0 then
                      u:changemaxmp(1)
                      u:addstr(1)
                      u:playsound(Yuzaoqian_HuajiaEX)
                      u:settimedata("狐之花嫁冷却", 45)
                      tg:effectadd("Abilities\\Spells\\Items\\AIim\\AIimTarget.mdl", "origin")
                      ChangeItemCount(wp, -1)
                      local sy2 = tg.ownerid
                      if jg ~= 7 then
                        if jg == 1 then
                          ChangeTimeValue(HeroMenu_HpCure_Inr, sy2, 20, 45)
                          ChangeTimeValue(Hero_Tili_Huifu, sy2, 1, 45)
                        end
                        if jg == 2 then
                          ChangeTimeValue(DamageSystem_Ssjianshao, sy2, 0.84, 45, 1)
                        end
                        if jg == 3 then
                          ChangeTimeValue(DamageSystem_Shjc, sy2, 0.016, 45)
                          ChangeTimeValue(Correction_RPM, sy2, 0.12, 45)
                        end
                        if jg == 5 then
                          tg:setdata("狐之花嫁-决死")
                        end
                        if jg == 6 then
                          tg:setdata("狐之花嫁-决死")
                          ChangeTimeValue(HeroMenu_HpCure_Inr, sy2, 20, 45)
                          ChangeTimeValue(Hero_Tili_Huifu, sy2, 1, 45)
                          ChangeTimeValue(DamageSystem_Ssjianshao, sy2, 0.84, 45, 1)
                          ChangeTimeValue(DamageSystem_Shjc, sy2, 0.016, 45)
                          ChangeTimeValue(Correction_RPM, sy2, 0.12, 45)
                        end
                      else
                        MedicineActHuiyi(tg, MEDICINE_HUIYI, nil)
                        local cd = 100 + 100 * tg:getdata("传奇数量")
                        u:settimedata("花嫁回忆冷却", cd)
                        ac.wait(cd * 1000, function()
                          u:sendmessage("|cFF7DBEF1狐之花嫁回忆冷却完毕|r")
                        end)
                      end
                    else
                      ewl:setskillcd(dskill, 1)
                      u:sendmessage("|cFF7DBEF1没有可用药剂|r")
                    end
                  else
                    ewl:setskillcd(dskill, 1)
                  end
                end
              end)
              u:uivar_change({
                keyname = "玉藻前",
                keytype = "传奇栏",
                text = "|cFFFF66FF玉藻前 - [3]次灵基突破|r\n|cFFFF66FF从者灵基|r\n|cFFCC99FF降低20点力量\n降低1点力量成长\n提升[5*(灵基突破层数+1)]魔力上限\n提升[5%*(灵基突破层数+1)]移速\n提升[0.5%当前法术修正*(灵基突破层数+1)]法术修正\n每秒提升[0.002%*(灵基突破层数+1)]法术修正\n提升[0.2%*灵基突破层数]终结伤害\n提升[5%*(灵基突破层数+1)]基础伤害\n提升[0.5%*(灵基突破层数+1)]伤害加成\n提升[0.5%*(灵基突破层数+1)]伤害加成|r\n|cFFFF66FF神性A|r\n|cFFCC99FF[10%+2%*灵基突破层数]使受到的伤害无效化|r\n|cFFFF66FF荼吉尼天法咒术EX|r\n|cFFCC99FF输入“荼吉尼天法咒术”来开启或关闭咒术触发,默认关闭\n开启时每秒削减1点生命上限 每次咒术触发消耗1点体力值\n不同咒术可以同时触发「炎天」「霜天」「风天」|r\n|cFFFF66FF变化A|r\n|cFFCC99FF提升30%论外减伤\n提升0.15闪避系数|r\n|cFFFF66FF狐之婚嫁EX|r\n|cFFCC99FF获得拓展技能[狐之婚嫁]|r\n|cFFFF66FF灵基突破|r\n|cFFCC99FF输入指令“灵基突破”消耗150点杀生石能量或(2瓶回忆+1瓶血统)来进行灵基突破|r\n|cFF949596「原来如此～。想撒娇时就要挑老公有空的时候，想被老公撒娇时就要找他心情低落时吧～。\n嗯，我知道，我都知道。玉藻我可是很懂这种套路的哦?」|r"
              })
            end
            if dlv == 4 then
              u:playsound(Yuzaoqian_3d4)
              ChangeValue(DamageSystem_EndSh, sy, 0.002)
              moveskillreplace({
                unit = u.handle,
                level = 1,
                skill_Q = "A0RS",
                skill_W = "A0RR",
                efunc = function()
                end
              })
              u:uivar_change({
                keyname = "玉藻前",
                keytype = "传奇栏",
                text = "|cFFFF66FF玉藻前 - [4]次灵基突破|r\n|cFFFF66FF从者灵基|r\n|cFFCC99FF降低20点力量\n降低1点力量成长\n提升[5*(灵基突破层数+1)]魔力上限\n提升[5%*(灵基突破层数+1)]移速\n提升[0.5%当前法术修正*(灵基突破层数+1)]法术修正\n每秒提升[0.002%*(灵基突破层数+1)]法术修正\n提升[0.2%*灵基突破层数]终结伤害\n提升[5%*(灵基突破层数+1)]基础伤害\n提升[0.5%*(灵基突破层数+1)]伤害加成\n提升[0.5%*(灵基突破层数+1)]伤害加成|r\n|cFFFF66FF神性A|r\n|cFFCC99FF[10%+2%*灵基突破层数]使受到的伤害无效化|r\n|cFFFF66FF荼吉尼天法咒术EX|r\n|cFFCC99FF输入“荼吉尼天法咒术”来开启或关闭咒术触发,默认关闭\n开启时每秒削减1点生命上限 每次咒术触发消耗1点体力值\n不同咒术可以同时触发「炎天」「霜天」「风天」|r\n|cFFFF66FF变化A|r\n|cFFCC99FF提升30%论外减伤\n提升0.15闪避系数|r\n|cFFFF66FF狐之婚嫁EX|r\n|cFFCC99FF获得拓展技能[狐之婚嫁]|r\n|cFFFF66FF小玉藻今天也是元气满满喔~|r\n|cFFCC99FF位移技能变更|r\n|cFFFF66FF灵基突破|r\n|cFFCC99FF输入指令“灵基突破”消耗150点杀生石能量或(2瓶回忆+1瓶血统)来进行灵基突破|r\n|cFF949596「开放后宫之类的事情，就算神允许，我也不会允许的！」|r"
              })
            end
            if dlv == 5 then
              u:playsound(Yuzaoqian_4d5)
              ChangeValue(DamageSystem_EndSh, sy, 0.002)
              u:uivar_change({
                keyname = "玉藻前",
                keytype = "传奇栏",
                text = "|cFFFF66FF玉藻前 - [5]次灵基突破|r\n|cFFFF66FF从者灵基|r\n|cFFCC99FF降低20点力量\n降低1点力量成长\n提升[5*(灵基突破层数+1)]魔力上限\n提升[5%*(灵基突破层数+1)]移速\n提升[0.5%当前法术修正*(灵基突破层数+1)]法术修正\n每秒提升[0.002%*(灵基突破层数+1)]法术修正\n提升[0.2%*灵基突破层数]终结伤害\n提升[5%*(灵基突破层数+1)]基础伤害\n提升[0.5%*(灵基突破层数+1)]伤害加成\n提升[0.5%*(灵基突破层数+1)]伤害加成|r\n|cFFFF66FF神性A|r\n|cFFCC99FF[10%+2%*灵基突破层数]使受到的伤害无效化|r\n|cFFFF66FF荼吉尼天法咒术EX|r\n|cFFCC99FF输入“荼吉尼天法咒术”来开启或关闭咒术触发,默认关闭\n开启时每秒削减1点生命上限 每次咒术触发消耗1点体力值\n不同咒术可以同时触发「炎天」「霜天」「风天」|r\n|cFFFF66FF变化A|r\n|cFFCC99FF提升30%论外减伤\n提升0.15闪避系数|r\n|cFFFF66FF狐之婚嫁EX|r\n|cFFCC99FF获得拓展技能[狐之婚嫁]|r\n|cFFFF66FF小玉藻今天也是元气满满喔~|r\n|cFFCC99FF位移技能变更|r\n|cFFFF66FF神宝宇迦之镜|r\n|cFFCC99FF输入指令“水天日光天照八野镇石”来发动宝具\n宝具持续30秒宝具释放后自身进入虚弱状态 降低30%移动速度 提升50%额外受伤修正|r\n|cFFFF66FF人理忘却|r\n|cFFCC99FF输入指令“彼岸花现”消耗200点杀生石能量或1瓶血坏来进行\"灵基异化\"(视为灵基突破)|r\n|cFF949596「天照山河水天 乃自在禊之证」|r"
              })
            end
          end
        end
        if args.chat == "荼吉尼天法咒术" and u:getdata("灵基突破次数") >= 2 then
          if u:hasdata("玉藻前-咒术") then
            u:deldata("玉藻前-咒术")
            u:sendmessage("|cFF7DBEF1咒术关闭|r")
            u:playsound(Yuzaoqian_Zhoushuoff)
          else
            u:playsound(Yuzaoqian_Zhoushuon)
            u:sendmessage("|cFF7DBEF1咒术开启|r")
            u:setdata("玉藻前-咒术")
            ac.loop(1000, function(timer)
              if u:isalive() and u:hasdata("玉藻前-咒术") then
                if not u:hasdata("玉藻前-宝具释放中") then
                  u:changemaxhp(-1 * u:getdata("灵基突破次数"))
                end
              else
                u:deldata("玉藻前-咒术")
                timer:remove()
              end
            end)
          end
        end
        if args.chat == "水天日光天照八野镇石" and 5 <= u:getdata("灵基突破次数") then
          if not u:isalive() then
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
            return
          end
          if u:hasbuff("暂停") then
            u:sendmessage("|cFF7DBEF1暂停状态无法释放|r")
            return
          end
          if u:hasdata("玉藻前-宝具冷却") then
            u:sendmessage("|cFF7DBEF1冷却中|r")
            return
          end
          PlayGlobalSound(Yuzaoqian_Baoju1)
          u:setdata("玉藻前-宝具释放中")
          u:changedata("宝具释放次数", 1)
          u:settimedata("玉藻前-宝具冷却", 600)
          ac.wait(600000, function()
            u:sendmessage("|cFF7DBEF1宝具冷却完毕|r")
          end)
          u:buffset(u.handle, 22, "暂停")
          u:buffset(u.handle, 22, "绝对闪避")
          u:buffset(u.handle, 25, "无敌")
          PlayBGM({
            bgm = 0,
            time = 25,
            ID = 7,
            unit = u.handle
          })
          ac.wait(3200, function()
            SendMsgAll("|cFF0066FF『|r|cFF0C57ED神|r|cFF1849DB在|r|cFF243AC9出|r|cFF2F2CB6云|r|cFF3B1DA4』|r")
          end)
          ac.wait(4800, function()
            SendMsgAll("|cFF0066FF『|r|cFF085DF3自|r|cFF0F53E8由|r|cFF174ADC操|r|cFF1E41D1控|r|cFF2638C5净|r|cFF2D2EBA仪|r|cFF3525AE之|r|cFF3C1CA3证|r|cFF441397』|r")
          end)
          ac.wait(7300, function()
            SendMsgAll("|cFF0066FF『|r|cFF065EF5神|r|cFF0D56EB宝|r|cFF134EE2宇|r|cFF1A47D8迦|r|cFF203FCE之|r|cFF2637C4镜|r|cFF2D2FBB是|r|cFF3327B1也|r|cFF391FA7—|r|cFF40189D—|r|cFF461094』|r")
          end)
          ac.wait(11500, function()
            SendMsgAll("|cFF0000FF「|r|cFF0600F5水|r|cFF0D00EB天|r|cFF1300E2日|r|cFF1A00D8光|r|cFF2000CE天|r|cFF2600C4照|r|cFF2D00BB八|r|cFF3300B1野|r|cFF3900A7镇|r|cFF40009D石|r|cFF460094」|r")
          end)
          ac.wait(17500, function()
            SendMsgAll("|cFFE55AAF『|r|cFFE7699F随|r|cFFEA788F便|r|cFFEC877F说|r|cFFEE966F说|r|cFFF1A55F的|r|cFFF3B450啦|r|cFFF6C340☆|r|cFFF8D230~|r|cFFFAE120』|r")
          end)
          local x, y = u:getxy()
          ac.wait(3500, function()
            local jd = 45
            local jl = 75
            local x2, y2 = PolarXY(x, y, jl, jd)
            Effectcreate("war3mapImported\\tsukoyomi black water.mdl", x2, y2, 19, 3)
            local mj = u:createunit("u052", x, y)
            ac.wait(9000, function()
              mj:kill()
            end)
            mj:timetoremove(11)
          end)
          ac.wait(4500, function()
            local mj = u:createunit("u052", x, y)
            ac.wait(9000, function()
              mj:kill()
            end)
            mj:timetoremove(10)
          end)
          ac.wait(9000, function()
            for i = 1, 8 do
              local jd = 45 * i
              local jl = 900
              local x2, y2 = PolarXY(x, y, jl, jd)
              local tx = Effectcreate("war3mapImported\\[AKE]war3AKE.com - 3089005175819055203953915.mdl", x2, y2, 9, 0.01)
              ac.wait(500, function()
                SetEffectSize(tx, 1.5)
              end)
            end
            Effectcreate("war3mapImported\\AK002.mdl", x, y, 10, 2)
          end)
          ac.wait(15500, function()
            Effectcreate("war3mapImported\\Ak005.mdl", x, y, 10, 1.5)
          end)
          ac.wait(18000, function()
            Effectcreate("war3mapImported\\22.mdl", x, y, 10, 0.6)
            for i = 1, 8 do
              local jd = 45 * i
              local jl = 900
              local x2, y2 = PolarXY(x, y, jl, jd)
              Effectcreate("war3mapImported\\arcaneburst.mdl", x2, y2, 4, 2)
            end
          end)
          ac.wait(22000, function()
            u:addskill("S033")
            ForGroupLuaNew(Group_PlayHero, function(xq)
              local sy2 = xq.ownerid
              UnitResetCooldown(xq.handle)
              xq:effectadd("war3mapImported\\Jiujizhiyu.mdx", "origin")
              xq:changemaxhp(333)
              ChangeTimeValue(HeroMenu_HpCure_Inr, sy2, 33, 33)
              ChangeTimeValue(Hero_Tili_Huifu, sy2, 3, 33)
              xq:changetimearmor(6, 33)
              ChangeTimeValue(Correction_RPM, sy2, 0.12, 33)
              ChangeTimeValue(DamageSystem_Shjc, sy2, 0.016, 33)
              ChangeTimeValue(DamageSystem_Ssjianshao, sy2, 0.84, 33, 1)
              ChangeTimeValue(DamageSystem_Shjc, sy2, 0.032, 33)
            end)
            ac.wait(33000, function()
              u:addskill("S034")
              ChangeTimeValue(DamageSystem_Sszengjia, sy, 0.5, 60)
              ac.wait(60000, function()
                u:delskill("S034")
              end)
              u:delskill("S033")
              ForGroupLuaNew(Group_PlayHero, function(xq)
                local sy2 = xq.ownerid
                xq:changemaxhp(-333)
              end)
            end)
          end)
          ac.wait(22500, function()
            ForGroupLuaNew(Group_PlayHero, function(xq)
              xq:effectadd("war3mapImported\\Jiujizhiyu.mdx", "origin")
            end)
          end)
          ac.wait(23000, function()
            ForGroupLuaNew(Group_PlayHero, function(xq)
              xq:effectadd("war3mapImported\\Jiujizhiyu.mdx", "origin")
            end)
          end)
        end
        if args.chat == "彼岸花现" and u:getdata("灵基突破次数") == 5 then
          local b1 = false
          local b4 = false
          if u:ishasitem("I039") then
            local wp = u:getitem("I039")
            local itemcount = GetItemCharges(wp)
            if 200 <= itemcount then
              b4 = true
            end
          end
          local wp1
          if not b4 then
            for i = 1, 6 do
              if GetItemTypeId(u:getcountitem(i)) == MEDICINE_XUEHUAI and 1 <= GetItemCharges(u:getcountitem(i)) then
                b1 = true
                wp1 = u:getcountitem(i)
              end
            end
          end
          if b1 or b4 then
            if b4 then
              local wp = u:getitem("I039")
              ChangeItemCount(wp, -200)
            else
              ChangeItemCount(wp1, -1)
            end
            u:changedata("灵基突破次数", 1)
            u:setdata("玉藻前-彼岸花开")
            u:sendmessage("|cFFFF99FF『|r|cFFF990F4彼|r|cFFF488E8岸|r|cFFEE80DD花|r|cFFE877D2开|r|cFFE36EC6开|r|cFFDD66BB彼|r|cFFD75EB0岸|r|cFFD255A4 |r|cFFCC4C99忘|r|cFFC6448E川|r|cFFC13C82河|r|cFFBB3377畔|r|cFFB52A6C亦|r|cFFB02260忘|r|cFFAA1A55川|r|cFFA4114A』|r")
            u:playsound(Yuzaoqian_5d6)
            u:effectadd("Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl", "origin")
            IncUnitAbilityLevel(u.handle, S2ID("S02U"))
            u:changemaxmp(5)
            ChangeValue(DamageSystem_Shjc, sy, 0.005)
            ChangeValue(DamageSystem_Shjc, sy, 0.005)
            ChangeValue(DamageSystem_Shjc, sy, 0.005)
            ChangeValue(DamageSystem_EndSh, sy, 0.002)
            u:addskill("S03Q")
            ac.loop(1000, function()
              local x, y = u:getxy()
              local txsh = 5000 + 500 * u:getlevel()
              if u:isalive() then
                for _, xq in ac.selector():in_rangexy(x, y, 750):is_not(u.handle):ipairs() do
                  xq = getunit(xq)
                  xq:effectadd("Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl", "origin")
                  local hp = 0.07 * xq:gethp() + 0.01 * xq:getmaxhp()
                  if xq:isingroup(Group_PlayHero) then
                    hp = hp * 0.25
                  elseif xq:is_enemy(u.handle) then
                    xq:groupadd(HpGroup)
                    if xq:isboss() then
                      hp = hp * 0.05
                    elseif xq:iselite() then
                      hp = hp * 0.25
                    end
                  end
                  if u:hasdata("玉藻前-杀生界额外伤害") then
                    DamageUnit({
                      bj = "玉藻前杀生界",
                      unit = xq.handle,
                      source = u.handle,
                      damage = txsh,
                      level = 1,
                      type = "魔力",
                      isvest = true,
                      isattack = false,
                      isnoarmor = false,
                      element = "暗"
                    })
                  end
                  if hp >= xq:gethp() then
                    u:setdata("允许伤害友军")
                    xq:kill(u.handle)
                    u:deldata("允许伤害友军")
                    local mhp = 5.0E-4 * xq:getmaxhp()
                    if not xq:isboss() then
                      u:changemaxhp(mhp)
                    end
                    ChangeValue(DamageSystem_Shjc, sy, 1.0E-4)
                  else
                    LossHpUnit({
                      u = u,
                      tg = xq,
                      damage = hp,
                      perhp = 0,
                      maxhp = 0,
                      bj = "[生命损耗]玉藻前杀生界"
                    })
                  end
                end
              end
            end)
            ac.loop(90000, function()
              if u:isalive() then
                local mpd = 0.5 * u:getmaxmp()
                if mpd <= u:getmp() then
                  u:curemp(-mpd)
                  u:effectadd("Abilities\\Spells\\NightElf\\ManaBurn\\ManaBurnTarget.mdl", "chest")
                else
                  mpd = mpd - u:getmp()
                  u:setmp(0)
                  local hpd = 0.01 * u:getmaxhp() * mpd
                  u:effectadd("war3mapImported\\dead spirit by deckai2.mdx", "origin")
                  if hpd >= u:gethp() then
                    u:setdata("允许伤害友军")
                    u:kill()
                    u:deldata("允许伤害友军")
                  else
                    u:losshp(u, hpd)
                  end
                end
              end
            end)
            u:uivar_change({
              keyname = "玉藻前",
              keytype = "传奇栏",
              text = "|cFFFF66FF玉藻前 - |r|cFFFF6699彼|r|cFFF05783岸|r|cFFE2496D花|r|cFFD33A57杀|r|cFFC52C42生|r|cFFB61D2C石|r\n|cFFFF66FF从者灵基|r\n|cFFCC99FF降低20点力量\n降低1点力量成长\n提升[5*(灵基突破层数+1)]魔力上限\n提升[5%*(灵基突破层数+1)]移速\n提升[0.5%当前法术修正*(灵基突破层数+1)]法术修正\n每秒提升[0.002%*(灵基突破层数+1)]法术修正\n提升[0.2%*灵基突破层数]终结伤害\n提升[5%*(灵基突破层数+1)]基础伤害\n提升[0.5%*(灵基突破层数+1)]伤害加成\n提升[0.5%*(灵基突破层数+1)]伤害加成|r\n|cFFFF66FF神性A|r\n|cFFCC99FF[10%+2%*灵基突破层数]使受到的伤害无效化|r\n|cFFFF66FF荼吉尼天法咒术EX|r\n|cFFCC99FF输入“荼吉尼天法咒术”来开启或关闭咒术触发,默认关闭\n开启时每秒削减1点生命上限 每次咒术触发消耗1点体力值\n不同咒术可以同时触发「炎天」「霜天」「风天」|r\n|cFFFF66FF变化A|r\n|cFFCC99FF提升30%论外减伤\n提升0.15闪避系数|r\n|cFFFF66FF狐之婚嫁EX|r\n|cFFCC99FF获得拓展技能[狐之婚嫁]|r\n|cFFFF66FF小玉藻今天也是元气满满喔~|r\n|cFFCC99FF位移技能变更|r\n|cFFFF66FF神宝宇迦之镜|r\n|cFFCC99FF输入指令“水天日光天照八野镇石”来发动宝具\n宝具持续30秒宝具释放后自身进入虚弱状态 降低30%移动速度 提升50%额外受伤修正|r\n|cFFB61D2C常世开裂大杀界|r\n|cFFFF6699自身除[常世开裂大杀界]外所有常规生命恢复效果降低50%(生命恢复效果至低生效50%)\n自身周围出现咒毒之地\n每秒移除范围内除自身外所有人生命值且每当有单位死于该效果\n恢复自身2%最大生命值同时永久提升生命上限\n每个死在范围内的单位提升0.1%该效果|r\n|cFFB61D2C现世吞噬|r\n|cFFFF6699每杀死一定数量单位提升自身体力上限\n每隔一定时间受到魔力反馈|r\n|cFFB61D2C神石契|r\n|cFFFF6699输入指令“镇石碎”消耗300点杀生石能量来吸收进化杀生石的力量(视为灵基突破)|r\n|cFF949596「为什么会如此悲伤呢……」\n「明明早就忘却了不是么……」|r"
            })
          end
        end
        if args.chat == "镇石碎" and u:getdata("灵基突破次数") == 6 then
          local b4 = false
          if u:ishasitem("I039") then
            local wp = u:getitem("I039")
            local itemcount = GetItemCharges(wp)
            if 300 <= itemcount then
              b4 = true
            end
          end
          if b4 then
            u:removeitem(u:getitem("I039"))
            u:additem("I067")
            u:getgoddessforce(1, true)
            u:changedata("灵基突破次数", 1)
            u:setdata("玉藻前-镇石碎")
            u:sendmessage("|cFFFF6699 |r|cFFFA6194 |r|cFFF45B8E「|r|cFFEF5689轩|r|cFFEA5184辕|r|cFFE44B7E陵|r|cFFDF4679墓|r|cFFD94073，|r|cFFD43B6E自|r|cFFCF3669冥|r|cFFC93063府|r|cFFC42B5E源|r|cFFBF2659源|r|cFFB92053不|r|cFFB41B4E绝|r|cFFAE1548…|r|cFFA91043…|r|cFFA40B3E」|r")
            u:effectadd("Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl", "origin")
            IncUnitAbilityLevel(u.handle, S2ID("S02U"))
            u:changemaxmp(5)
            ChangeValue(DamageSystem_Shjc, sy, 0.005)
            ChangeValue(DamageSystem_Shjc, sy, 0.005)
            ChangeValue(DamageSystem_Shjc, sy, 0.005)
            ChangeValue(DamageSystem_EndSh, sy, 0.002)
            u:become("噩梦具现化")
            local hp1 = 0
            local hp2 = 0
            local mp1 = 0
            ac.loop(1000, function()
              ChangeValue(HeroMenu_HpForever_MaxHp, sy, -hp1)
              ChangeValue(HeroMenu_HpRemove_MaxHp, sy, -hp2)
              ChangeValue(HeroMenu_MpCure_MaxMp, sy, -mp1)
              local hp = u:gethp() / u:getmaxhp()
              local mp = u:getmp() / u:getmaxmp()
              if hp > mp then
                hp1 = 0
                hp2 = 1
                mp1 = 2
              else
                hp1 = 2
                hp2 = 0
                mp1 = -1
              end
              ChangeValue(HeroMenu_MpCure_MaxMp, sy, mp1)
              ChangeValue(HeroMenu_HpForever_MaxHp, sy, hp1)
              ChangeValue(HeroMenu_HpRemove_MaxHp, sy, hp2)
            end)
            u:setdata("空天洞护盾", 4 * u:getmaxmp())
            ac.loop(250, function()
              local mp = 4 * u:getmaxmp()
              if mp <= u:getdata("空天洞护盾") then
                u:setdata("空天洞护盾", mp)
              end
              if u:getdata("空天洞护盾") > 0 and not u:hasdata("空天洞特效") then
                u:setdata("空天洞特效", u:effectadd("Abilities\\Spells\\Undead\\AntiMagicShell\\AntiMagicShell.mdl", "origin", -1))
              end
            end)
            u:uivar_change({
              keyname = "玉藻前",
              keytype = "传奇栏",
              text = "|cFFFF66FF玉藻前 - |r|cFFFF6699破|r|cFFEB527A碎|r|cFFD63D5C之|r|cFFC2293D境|r\n|cFFFF66FF从者灵基|r\n|cFFFF66FF神性A|r\n|cFFCC99FF[10%+2%*灵基突破层数]使受到的伤害无效化|r\n|cFFFF66FF荼吉尼天法咒术EX|r\n|cFFCC99FF输入“荼吉尼天法咒术”来开启或关闭咒术触发,默认关闭\n开启时每秒削减1点生命上限 每次咒术触发消耗1点体力值\n不同咒术可以同时触发「炎天」「霜天」「风天」|r\n|cFFFF66FF变化A|r\n|cFFCC99FF提升30%论外减伤\n提升0.15闪避系数|r\n|cFFFF66FF狐之婚嫁EX|r\n|cFFCC99FF获得拓展技能[狐之婚嫁]|r\n|cFFFF66FF小玉藻今天也是元气满满喔~|r\n|cFFCC99FF位移技能变更|r\n|cFFFF66FF神宝宇迦之镜|r\n|cFFCC99FF输入指令“水天日光天照八野镇石”来发动宝具\n宝具持续30秒宝具释放后自身进入虚弱状态 降低30%移动速度 提升50%额外受伤修正|r\n|cFFB61D2C常世开裂大杀界|r\n|cFFFF6699自身除[常世开裂大杀界]外所有常规生命恢复效果降低50%(生命恢复效果至低生效50%)\n自身周围出现咒毒之地\n每秒移除范围内除自身外所有人生命值且每当有单位死于该效果\n恢复自身2%最大生命值同时永久提升生命上限\n每个死在范围内的单位提升0.1%该效果|r\n|cFFB61D2C现世吞噬|r\n|cFFFF6699每杀死一定数量单位提升自身体力上限\n每隔一定时间受到魔力反馈|r\n|cFFB61D2C『空天洞』|r\n|cFFFF6699获得护盾,上限(体力上限*4永恒抗性)\n每次杀敌恢复10点护盾值\n受到致死伤害时免疫该次致死伤害并使护盾回复至上限(触发冷却600秒)|r\n|cFFB61D2C『怨天咒祭』|r\n|cFFFF6699自身HP百分比低于MP百分比,每秒消耗1%MP回复2%HP「生命修改」\n自身MP百分比低于HP百分比,每秒消耗1%HP回复2%MP「生命修改」|r\n|cFFB61D2C『曼珠沙华』|r\n|cFFFF6699输入“轩辕改墓冥府轮换” 消耗四瓶血坏突破现世法则,未满足时会受到惩罚|r\n|cFF949596『彼岸花开开彼岸 花开叶落永不见』|r"
            })
          end
        end
        if args.chat == "轩辕改墓冥府轮换" and u:getdata("灵基突破次数") == 7 then
          local b4 = false
          local wp1
          for i = 1, 6 do
            if GetItemTypeId(u:getcountitem(i)) == MEDICINE_XUEHUAI and GetItemCharges(u:getcountitem(i)) >= 4 then
              b4 = true
              wp1 = u:getcountitem(i)
            end
          end
          if b4 then
            ChangeItemCount(wp1, -4)
            u:changedata("灵基突破次数", 1)
            u:setdata("玉藻前-轩辕冥府")
            u:setplayername("|cFFFF6699「玉|r|cFFEB527A藻|r|cFFD63D5Cの|r|cFFC2293D前」|r")
            ac.wait(1000, function()
              SendMsgAll("|cFF6633CC『|r|cFF6A2FBB没|r|cFF6E2AAA事|r|cFF732699的|r|cFF772288喔|r|cFF7B1E77…|r|cFF801A66小|r|cFF841555玉|r|cFF881144藻|r|cFF8C0D33…|r|cFF900822』|r")
            end)
            ac.wait(4000, function()
              SendMsgAll("|cFF6633CC『|r|cFF6831C3没|r|cFF6B2EB9关|r|cFF6D2CB0系|r|cFF6F2AA7的|r|cFF72279E…|r|cFF742594只|r|cFF76238B要|r|cFF792082再|r|cFF7B1E79努|r|cFF7D1C6F力|r|cFF7F1966一|r|cFF82175D下|r|cFF841553下|r|cFF86134A就|r|cFF891041可|r|cFF8B0E38以|r|cFF8D0C2E了|r|cFF900925喔|r|cFF92071C…|r|cFF940513』|r")
            end)
            ac.wait(7000, function()
              SendMsgAll("|cFF6633CC『|r|cFF6930C1就|r|cFF6B2EB7不|r|cFF6E2BAC会|r|cFF7128A1再|r|cFF732696因|r|cFF76238C为|r|cFF792081大|r|cFF7B1E76家|r|cFF7E1B6B死|r|cFF811861去|r|cFF841556而|r|cFF86134B悲|r|cFF891040伤|r|cFF8C0D36了|r|cFF8E0B2B喔|r|cFF910820…|r|cFF940515』|r")
            end)
            u:effectadd("Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl", "origin")
            IncUnitAbilityLevel(u.handle, S2ID("S02U"))
            u:changemaxmp(5)
            u:addstr(u:getoriginstr())
            ChangeValue(DamageSystem_Shjc, sy, 0.005)
            ChangeValue(DamageSystem_Shjc, sy, 0.005)
            ChangeValue(DamageSystem_Shjc, sy, 0.005)
            ChangeValue(DamageSystem_EndSh, sy, 0.002)
            u:adddivinity(2)
            u:addskill("S04X")
            u:additem("I06E")
            ChangeValue(DamageSystem_EndSh, sy, 0.010000000000000002)
            Danwei_Yuzaoqian = u.handle
            u:playsound(TempleOfTheDamnedWhat)
            ForGroupLuaNew(Group_PlayHero, function(xq)
              if xq.handle ~= u.handle then
                xq:addtrgevent("玩家-聊天", function(args)
                  chattrg2(args)
                end)
              end
            end)
            ac.loop(1000, function()
              if u:isalive() then
                u:clearbuff()
                local b = false
                ForGroupLuaNew(Group_PlayHero, function(xq)
                  if xq.handle ~= u.handle and xq:isalive() then
                    local dis = DistanceBetweenUnits(u.handle, xq.handle)
                    if dis <= 1200 then
                      b = true
                    end
                  end
                end)
                if b and GetRandom100(5) and not u:hasdata("玉藻前-狂暴化") then
                  u:buffset(u.handle, 1, "暂停")
                  u:settimedata("玉藻前-狂暴化", 4.5)
                  do
                    local cs = 0
                    ac.loop(250, function(timer)
                      cs = cs + 1
                      local x, y = u:getxy()
                      if 5 <= cs then
                        local sh3 = u:getmp() * 250
                        Effectcreate("war3mapImported\\[TX] (143).mdx", x, y, 0, 5)
                        for _, xq in ac.selector():in_rangexy(x, y, 1200):is_not(u.handle):ipairs() do
                          xq = getunit(xq)
                          xq:setdata("允许伤害友军")
                          DamageUnit({
                            bj = "玉藻前杀生界",
                            unit = xq.handle,
                            source = u.handle,
                            damage = sh3,
                            level = 5,
                            type = "魔力",
                            isvest = false,
                            isattack = false,
                            isnoarmor = false,
                            element = "暗"
                          })
                          xq:deldata("允许伤害友军")
                          xq:buffset(u.handle, 1.5, "眩晕")
                        end
                      else
                        Effectcreate("war3mapImported\\[TX] (1234).mdl", x, y)
                      end
                      if cs == 8 then
                        timer:remove()
                      end
                    end)
                  end
                end
              end
            end)
            u:settimedata("血坏清除", 4.5)
            u:uivar_change({
              keyname = "玉藻前",
              keytype = "传奇栏",
              text = "|cFF7029CC玉藻前 - |r|cFF6633FF轩|r|cFF7029CC辕|r|cFF7A1F99冥|r|cFF851466府|r\n|cFF7029CC从者灵基|r\n|cFF7A1F99[人理忘却]|r\n|cFF7029CC神性A|r\n|cFF7A1F99[人理忘却]|r\n|cFF7029CC荼吉尼天法咒术EX|r\n|cFF7A1F99[人理忘却]|r\n|cFF7029CC变化A|r\n|cFF7A1F99[人理忘却]|r\n|cFF7029CC狐之婚嫁EX|r\n|cFF7A1F99[人理忘却]|r\n|cFF7029CC小玉藻今天也是元气满满喔~|r\n|cFF7A1F99[人理忘却]|r\n|cFF7029CC神宝宇迦之镜|r\n|cFF7A1F99[人理忘却]|r\n|cFF7029CC常世开裂大杀界|r\n|cFF7A1F99[人理忘却]|r\n|cFF7029CC现世吞噬|r\n|cFF7A1F99[人理忘却]|r\n|cFF7029CC『空天洞』|r\n|cFF7A1F99[人理忘却]|r\n|cFF7029CC『怨天咒祭』|r\n|cFF7A1F99[人理忘却]|r\n|cFF7029CC『逆天命』|r\n|cFF7A1F99获得时提升50%力量\n移速极限化且免疫任何负面状态(包括僵直与眩晕 不包括暂停)\n单次受伤不会超过13%最大生命值|r\n|cFF7029CC『轩辕墓』|r\n|cFF7A1F99每次杀死单位时提升1点力量并降低12生命上限\n每次杀死单位时恢复1%最大生命值(生命修改)\n每次杀死单位时提升0.05%伤害加成|r\n|cFF7029CC『冥府音』|r\n|cFF7A1F99每次队友死亡时提升自身50生命上限 每次队友常规复活时提升其1点力量\n死亡状态的队友输入“靡靡之音”后在180秒后复活在玉藻前处并提升5点力量|r\n|cFF7029CC『魔都兆』|r\n|cFF7A1F99杀死队友时提升自身10点力量与2.5%伤害加成修正同时降低队友200生命上限|r\n|cFF7029CC『神权千年』|r\n|cFF7A1F99[人理忘却]|r\n|cFF949596『嗯哼哼~只要听小玉藻就可以了哦~为了小玉藻的话什么都做得到吧~~那么~请去死吧~』|r"
            })
          elseif not u:hasdata("玉藻前-轩辕改墓") then
            u:setdata("玉藻前-轩辕改墓")
            ac.wait(10000, function()
              u:effectadd("war3mapimported\\texiao_xuebao.mdx", "origin")
              u:losshp(u, 0, 99, 0)
              u:buffset(u.handle, 3, "眩晕")
              u:deldata("玉藻前-轩辕改墓")
            end)
          end
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chattrg(args)
      end)
    end,
    effectname = "|cFFFF66FF玉藻前 - [0]次灵基突破|r",
    effecttext = "|cFFFF66FF从者灵基|r\n|cFFCC99FF降低20点力量\n降低1点力量成长\n提升[5*(灵基突破层数+1)]魔力上限\n提升[5%*(灵基突破层数+1)]移速\n提升[0.5%当前法术修正*(灵基突破层数+1)]法术修正\n每秒提升[0.002%*(灵基突破层数+1)]法术修正\n提升[0.2%*灵基突破层数]终结伤害\n提升[5%*(灵基突破层数+1)]基础伤害\n提升[0.5%*(灵基突破层数+1)]伤害加成\n提升[0.5%*(灵基突破层数+1)]伤害加成|r\n|cFFFF66FF灵基突破|r\n|cFFCC99FF输入指令“灵基突破”消耗100点杀生石能量或(1瓶血统+1瓶力量)来进行灵基突破|r\n|cFF949596「Caster也好，小玉也罢，当然叫我甜心也是可以的哟不过嘛，仅限主人就是了」|r",
    effectart = "war3mapImported\\BTNEwl_Yuzaoqian.blp",
    test = [[

        ]]
  },
  {
    name = "古明地恋",
    weight = 5,
    lv = 3,
    key = {"唯一", "东方"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("初始判定-古明地恋") then
        b = true
      end
      if u:hasdata("判定-古明地恋") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      ac.wait(10, function()
        u:uivar_change({
          keyname = "古明地恋",
          keytype = "传奇栏",
          icon = "Lianlian_Cq.tga",
          ishasphoto = true
        })
      end)
      PlayBGM({
        bgm = 0,
        time = 35,
        ID = 0,
        unit = u.handle
      })
      PlayGlobalSound(Sound_Lianlian_Get)
      SendDtimeMsgAll(0.6, "|cFF66FF99『|r|cFF61F6A2我|r|cFF5DECAC就|r|cFF58E3B5是|r|cFF53DABE古|r|cFF4FD1C7明|r|cFF4AC7D1地|r|cFF46BEDA恋|r|cFF41B5E3！|r|cFF3CACEC』|r")
      SendDtimeMsgAll(3.3, "|cFF66FF99『|r|cFF64FB9D是|r|cFF62F6A2觉|r|cFF5FF2A6姐|r|cFF5DEDAB姐|r|cFF5BE9AF的|r|cFF59E4B4妹|r|cFF56E0B8妹|r|cFF54DCBC，|r|cFF52D7C1平|r|cFF50D3C5常|r|cFF4ECECA喜|r|cFF4BCACE欢|r|cFF49C5D3在|r|cFF47C1D7幻|r|cFF45BCDC想|r|cFF43B8E0乡|r|cFF40B4E4散|r|cFF3EAFE9步|r|cFF3CABED哦|r|cFF3AA6F2！|r|cFF37A2F6』|r")
      SendDtimeMsgAll(7.9, "|cFF66FF99『|r|cFF62F7A1我|r|cFF5EEFA9突|r|cFF5AE7B1然|r|cFF56E0B8出|r|cFF52D8C0现|r|cFF4ED0C8吓|r|cFF4BC8D0到|r|cFF47C0D8你|r|cFF43B8E0了|r|cFF3FB1E7？|r|cFF3BA9EF』|r")
      SendDtimeMsgAll(9.9, "|cFF66FF99『|r|cFF64FA9E哎|r|cFF61F6A2嘿|r|cFF5FF1A7嘿|r|cFF5DECAC~|r|cFF5AE8B0其|r|cFF58E3B5实|r|cFF56DFB9从|r|cFF53DABE刚|r|cFF51D5C3才|r|cFF4FD1C7开|r|cFF4DCCCC始|r|cFF4AC7D1就|r|cFF48C3D5一|r|cFF46BEDA直|r|cFF43B9DF在|r|cFF41B5E3你|r|cFF3FB0E8边|r|cFF3CACEC上|r|cFF3AA7F1哦|r|cFF38A2F6』|r")
      SendDtimeMsgAll(13.8, "|cFF66FF99『|r|cFF64FB9D完|r|cFF62F7A1全|r|cFF60F3A5没|r|cFF5EEFA9发|r|cFF5CEBAD现|r|cFF5AE7B1吧|r|cFF58E4B4？|r|cFF56E0B8不|r|cFF54DCBC过|r|cFF52D8C0，|r|cFF50D4C4你|r|cFF4ED0C8比|r|cFF4CCCCC我|r|cFF4BC8D0预|r|cFF49C4D4想|r|cFF47C0D8的|r|cFF45BCDC还|r|cFF43B8E0要|r|cFF41B4E4早|r|cFF3FB1E7发|r|cFF3DADEB现|r|cFF3BA9EF我|r|cFF39A5F3呢|r|cFF37A1F7』|r")
      SendDtimeMsgAll(18.7, "|cFF66FF99『|r|cFF63FA9E为|r|cFF61F4A4什|r|cFF5EEFA9么|r|cFF5BEAAE呢|r|cFF59E4B4？|r|cFF56DFB9是|r|cFF53D9BF因|r|cFF51D4C4为|r|cFF4ECFC9我|r|cFF4BC9CF们|r|cFF48C4D4比|r|cFF46BFD9较|r|cFF43B9DF相|r|cFF40B4E4似|r|cFF3EAEEA吗|r|cFF3BA9EF？|r|cFF38A4F4』|r")
      SendDtimeMsgAll(23.4, "|cFF66FF99『|r|cFF63F99F是|r|cFF60F2A6这|r|cFF5CECAC样|r|cFF59E6B2的|r|cFF56DFB9话|r|cFF53D9BF—|r|cFF50D2C6—|r|cFF4CCCCC那|r|cFF49C6D2就|r|cFF46BFD9太|r|cFF43B9DF好|r|cFF40B2E6了|r|cFF3DACEC！|r|cFF39A6F2』|r")
      SendDtimeMsgAll(27.3, "|cFF66FF99『|r|cFF64FB9D今|r|cFF62F7A1后|r|cFF60F3A5也|r|cFF5EEFA9一|r|cFF5CEBAD起|r|cFF5AE7B1找|r|cFF58E4B4些|r|cFF56E0B8有|r|cFF54DCBC意|r|cFF52D8C0思|r|cFF50D4C4的|r|cFF4ED0C8事|r|cFF4CCCCC情|r|cFF4BC8D0做|r|cFF49C4D4吧|r|cFF47C0D8—|r|cFF45BCDC！|r|cFF43B8E0请|r|cFF41B4E4多|r|cFF3FB1E7关|r|cFF3DADEB照|r|cFF3BA9EF哦|r|cFF39A5F3！|r|cFF37A1F7』|r")
      local strname = "古明地恋传奇"
      ac.loop(3000, function(timer)
        if u:hasdata("变异判定-幻想乡") and u:hasdata("古明地恋-初始进阶") then
          AdvanceGet["地灵殿"](u)
          timer:remove()
        end
      end)
      ModelReplace({
        u = u,
        model = "lianlian.mdx",
        modelsize = 0.9,
        modelname = "|cFF4CDF95古|r|cFF47BDA0明|r|cFF429AAB地|r|cFF3D78B6恋|r",
        modelicon = "Portrait_Lianlian.tga",
        isforce = true
      })
      ChangeValue(DamageSystem_Baoshang, sy, 0.25)
      u:setdata("古明地恋-无意识层数", 2)
      if u:islocal() then
        BuffUI.apply({
          id = "古明地恋-无意识层数",
          duration = 99999
        })
      end
      local bs = 0
      local cs = 0
      local hp = 0
      ac.loop(1500, function()
        if u:getdata("古明地恋-无意识时间") > 0 then
          u:changedata("古明地恋-无意识时间", -1.5)
          if u:getdata("古明地恋-无意识时间") <= 0 then
            u:deldata("古明地恋-无意识时间")
          end
        end
        if u:isalive() then
          local max2 = 5
          if u:hasdata("神化判定-古明地恋") then
            max2 = 8
          end
          if max2 > u:getdata("古明地恋-无意识层数") then
            cs = cs + 1
            local max = 40
            if u:hasdata("神化判定-古明地恋") then
              max = 30
            end
            if max <= cs then
              cs = 0
              u:changedata("古明地恋-无意识层数", 1)
            end
          end
        end
        ChangeValue(DamageSystem_Baoshang, sy, -bs)
        bs = 0.01 * u:getlevel()
        ChangeValue(DamageSystem_Baoshang, sy, bs)
        ChangeValue(Correction_MHp, sy, 0.1 * -hp)
        if u:getdata("东方变异数量") >= 15 then
          hp = 0.0075 * u:getstate("东方变异") * (1 + u:getdata("古明地恋-击杀BOSS数量"))
        else
          hp = 0
        end
        ChangeValue(Correction_MHp, sy, 0.1 * hp)
      end)
      ac.loop(3000, function(timer)
        if u:getdata("东方变异数量") >= 15 then
          ChangeValue(HeroMenu_HpForever_MaxHp, sy, 0.25)
          ChangeValue(DamageSystem_Ssjianshao, sy, 0.75, 1)
          u:changedata("效果增强-东方", 0.25)
          timer:remove()
        end
      end)
      ChangeValue(DamageSplit_CountHit, sy, 1)
      ChangeValue(DamageSplit_CountMax, sy, 0.2)
      u:addstexiao(strname, "英雄升级时效果", function(args)
        u:addallstats(5)
      end)
      ChangeValue(Damage_Type_Wuli, sy, 0.4)
      u:addstexiao(var.name, "杀敌效果", function(args)
        local add = 1 + u:getstate("东方变异") * 0.5
        u:changemaxhp(add)
        local tg = args.tg
        if tg:isboss() then
          u:changedata("古明地恋-击杀BOSS数量", 1)
        end
      end)
      u:addstexiao(strname, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:hasbuff("混乱") then
          info.end2 = info.end2 + 0.1
        end
        if u:getdata("古明地恋-无意识时间") > 0 then
          if u:hasdata("神化判定-古明地恋") then
            info.endup = info.endup + 0.25
          else
            info.endup = info.endup + 0.15
          end
        end
      end)
      u:addstexiao(strname, "暴击系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:hasbuff("混乱") then
          if u:hasdata("神化判定-古明地恋") then
            info.bjl = info.bjl + 100
          else
            info.bjl = info.bjl + 50
          end
        end
      end)
      u:addstexiao(strname, "暴击系统触发效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata("古明地恋暴击混乱冷却") and tg:isnormal() then
          u:settimedata("古明地恋暴击混乱冷却", 7)
          tg:buffset(u.handle, 5, "混乱")
        end
        if not tg:hasdata("古明地恋-暴击减甲") then
          tg:setdata("古明地恋-暴击减甲")
          tg:changearmor(-33)
        end
      end)
      u:addstexiao(strname, "受伤后效果", function(args)
        local tg = args.tg
        local u = args.u
        if not u:hasdata(strname .. "-无意识冷却") then
          u:settimedata(strname .. "-无意识冷却", 10)
          u:setdata("古明地恋-无意识时间", 10)
          u:buffset(u.handle, 9.9, "隐身")
          if u:hasdata("神化判定-古明地恋") then
            local hdz = 0.1 * u:getmaxhp()
            if u:getdata("古明地恋-临时护盾值") >= 1 * u:getmaxhp() then
              hdz = 0
            end
            u:changedata("古明地恋-临时护盾值", hdz)
            hdzlinshiadd(u, hdz)
          end
          local x, y = u:getxy()
          for _, xq in ac.selector():in_rangexy(x, y, 600):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:buffset(u.handle, 3, "混乱")
          end
          u:changedata("古明地恋-无意识触发次数", 1)
          if not u:hasdata("神化判定-古明地恋") and u:getdata("古明地恋-无意识触发次数") >= 20 and (u:ishasshw() or u:hasdata("恋恋-神化位使用")) then
            AdvanceGet["古明地恋神化1"](u)
          end
        end
      end)
      u:addstexiao(strname, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(strname .. "-特效冷却") then
          u:settimedata(strname .. "-特效冷却", 4)
          local x, y = u:getxy()
          local x2, y2 = tg:getxy()
          local angle = AngleXY(x, y, x2, y2)
          local txsh = 15000 + 100 * u:getallattri()
          unifycreate({
            owner = u.handle,
            model = "Lianlian_Tx_Dm.mdx",
            modelname = "恋恋-心之弹幕",
            modelsize = 1,
            height = 0,
            damage = txsh,
            damagetype = 2,
            x = x,
            y = y,
            range = 3000,
            time = 1,
            volume = 100,
            angle = angle,
            angleoffset = 0,
            attenua = 1,
            attenuacount = 1,
            life = 10,
            isbullet = false,
            isvest = true,
            isignorearmor = false,
            startfunc = function(mj)
            end,
            loopfunc = function(mj)
            end,
            hitfunc = function(mj, damage)
              return damage
            end,
            hitbeforefunc = function(mj, xq, damage2)
              xq:buffset(u.handle, 1, "混乱")
              return damage2
            end,
            hitafterfunc = function(mj, xq, damage2)
            end,
            endfunc = function(mj)
            end
          })
        end
      end)
    end,
    effectname = "|cFF006C82古明地恋|r",
    effecttext = "|cFF006C82察觉到了读心所导致的他人的厌恶和恐惧，\n所以闭上可以读心的第三只眼，\n这样便不会遭到地底居民们的厌恶、恐惧，\n但也不会被他人所喜欢了。|r",
    effectart = "Lianlian_Cq",
    test = [[

        ]]
  },
  {
    name = "忍野忍",
    weight = 5,
    lv = 3,
    key = {
      "唯一",
      "光明",
      "吸血鬼",
      "魅魔"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-忍野忍") then
        b = true
      end
      if not u:hasdata("忍野忍-获取判定") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      Weiyi_New[8] = true
      ciyuanget(u, var)
      SendDtimeMsgAll(0.4, "|cFFFF0000忍|r|cFFFF801A野|r|cFFFFAA22忍|r|cFFFF2A08：『吾乃|r|cFFFF5511忍野忍』|r")
      SendDtimeMsgAll(2.4, "|cFFFF0000忍|r|cFFFF801A野|r|cFFFFAA22忍|r|cFFFF2A08：『原名姬丝秀忒·雅赛劳|r|cFFFF5511拉莉昂·刃下心』|r")
      SendDtimeMsgAll(8.3, "|cFFFF0000忍|r|cFFFF801A野|r|cFFFFAA22忍|r|cFFFF2A08：『活在传说中的|r|cFFFF5511吸血鬼』|r")
      PlayGlobalSound(Sound_Ryr_Get_Word)
      PlayGlobalSound(Sound_Ryr_Get_BGM)
      for index, value in ipairs(Pools_Spe) do
        if value.name == "甜甜圈礼盒" then
          if not value.hasbeenget then
            local item = u:additem("I0GK")
            value.hasbeenget = true
          end
          break
        end
      end
      local bb = getunit(Beibao[sy])
      bb:addskill("A1RF")
      bb:delskill("A1RF")
      AddUnitAnimationProperties(bb.handle, "alternate", true)
      ac.wait(20000, function()
        local count = GetRandomInt(1, 5)
        local zu = {
          {
            bgm = BGM_Ryr_01,
            time = 280
          },
          {
            bgm = BGM_Ryr_02,
            time = 95
          },
          {
            bgm = BGM_Ryr_03,
            time = 260
          },
          {
            bgm = BGM_Ryr_04,
            time = 250
          },
          {
            bgm = BGM_Ryr_05,
            time = 345
          }
        }
        PlayBGM({
          bgm = zu[count].bgm,
          time = zu[count].time,
          ID = 163,
          unit = u.handle
        })
      end)
      ac.wait(1000, function()
        local count = tostring(GetRandomInt(1, 9))
        if count == "1" then
          count = ""
        end
        u:uivar_change({
          keyname = "忍野忍",
          keytype = "传奇栏",
          icon = "war3mapImported\\BTNEwl_Ryr_Cq" .. count
        })
      end)
      if u:islocal() then
        BuffUI.apply({
          id = "忍野忍-甜食值计数",
          duration = 99999
        })
      end
      u:setdata("血统判定-人类")
      u:adddivinity(1)
      u:setdata("忍野忍-怪异杀手累积数量", 0)
      u:setdata("忍野忍-甜甜圈使用次数", 0)
      u:setdata("忍野忍-甜食值", 0)
      u:setdata("忍野忍-甜腻层数上限", 50)
      ac.loop(1000, function(timer)
        if u:hasdata(OshinoTaboo.LIGHT_FLAG) or u:hasdata(OshinoTaboo.DARK_FLAG) then
          timer:remove()
          return
        end
        local branch = OshinoTaboo.determine_branch({
          is_deified = u:hasdata("变异判定-忍野忍神化"),
          has_light_bloodline = u:hasdata("忍野忍血统进阶-金发幼女"),
          has_dark_bloodline = u:hasdata("忍野忍血统进阶-始祖吸血鬼"),
          has_donut_gift_box = u:ishasitem(OshinoTaboo.DONUT_GIFT_BOX_ITEM),
          has_kokorowatari = u:ishasitem(OshinoTaboo.KOKOROWATARI_ITEM) or u:hasdata("武器判定-妖刀心渡"),
          has_yumewatari = u:ishasitem(OshinoTaboo.YUMEWATARI_ITEM),
          has_left_leg = u:hasdata("忍野忍-左腿"),
          has_right_leg = u:hasdata("忍野忍-右腿"),
          has_both_arms = u:hasdata("忍野忍-双臂"),
          has_advanced_eyes = u:hasdata("变异判定-金色的梦幻之瞳")
        })
        if branch then
          AdvanceGet[branch](u)
          timer:remove()
        end
      end)
      ChangeValue(Correction_Exp, sy, 0.2)
      ChangeValue(Correction_MEDCgl, sy, 0.1)
      ChangeValue(DamageSystem_Baoji, sy, 18)
      ChangeValue(DamageSystem_Baoshang, sy, 0.36)
      ChangeValue(Correction_Jzsh, sy, 0.5)
      ChangeValue(DamageSystem_Shjc, sy, 1)
      u:changedata("固定伤害", 50000)
      u:addskill("S09T")
      u:setdata("忍野忍-无视地形")
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        info.pk_shouhu = true
        info.pk_tiebi = true
        info.wsmy = true
      end)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        u:changemaxhp(150)
        u:changeoriginmaxhp(15.0)
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        if GetRandom100(5) then
          u:addallstats(1)
        end
        local tg = args.tg
        local addz = 0
        if tg:isboss() then
          addz = 1000
        elseif tg:iselite() then
          addz = 100
        else
          addz = 10
        end
        u:changedata("忍野忍-甜食值", addz)
      end)
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and not u:hasdata("忍野忍-决死冷却") then
          args.dt = false
          u:settimedata("忍野忍-决死冷却", 360)
          u:sendmessage("|cFFFFFF00[忍野忍]500岁的吸血鬼|r")
          local add = u:getdata("忍野忍-甜食值")
          hdzlinshiadd(u, add)
        end
      end)
      local g = CreateGroupLua()
      
      local function ryr_tianniadd(tg, add)
        add = add or 1
        local max = u:getdata("忍野忍-甜腻层数上限")
        local cengshu = tg:getdata("忍野忍-甜腻层数")
        if max > cengshu + add then
          if u:hasdata("武器判定-妖刀心渡") and cengshu < 20 then
            add = add + 20 - cengshu
          end
          add = max - cengshu
          if not tg:hasdata("忍野忍-甜腻负面") and u.handle ~= tg.handle then
            tg:groupadd(g)
            tg:setdata("忍野忍-甜腻负面")
          end
        end
        if u:hasdata("变异判定-忍野忍神化") and 0 < add then
          tg:changedata("怪物-额外受伤", add * 0.005)
          tg:changearmor(-add)
        end
        tg:changedata("忍野忍-甜腻层数", add)
      end
      
      u:setdata("忍野忍-甜腻施加", ryr_tianniadd)
      u:setdata("忍野忍-甜腻施加组", g)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:getdata("忍野忍-甜腻层数") > 0 then
          info.end2 = info.end2 + 0.005 * tg:getdata("忍野忍-甜腻层数")
        end
      end)
      local cs = 0
      local add = 0
      local gs = 0
      ac.loop(3000, function(timer)
        if u:isalive() then
          cs = cs + 1
          if 20 <= cs then
            cs = 0
            bb:additem("I0GL")
          end
        end
        ChangeValue(Correction_Jzsh, sy, 0.1 * -add)
        ChangeValue(Correction_Gun, sy, 0.1 * -add)
        ChangeValue(DamageSystem_Shjc, sy, 0.2 * -add)
        u:changedata("固定伤害", -gs)
        local zd = u:returnmaxvar()
        local count = u:getdata("忍野忍-甜食值")
        gs = 1 * count
        add = 1.0E-4 * count
        add = add + 0.15 * u:getdata(zd .. "变异数量")
        if u:hasdata("变异判定-忍野忍神化") then
          add = add * 2
          gs = gs * 2
        end
        u:changedata("固定伤害", gs)
        ChangeValue(Correction_Jzsh, sy, 0.1 * add)
        ChangeValue(Correction_Gun, sy, 0.1 * add)
        ChangeValue(DamageSystem_Shjc, sy, 0.2 * add)
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 1)
          local x, y = tg:getxy()
          local txsh = 20000 + 2000 * u:getlevel() + u:getallattri() * 100
          Effectcreate("ZK_TTQ2.mdl", x, y, 0, 1, 90, GetRandomAngle())
          local dh = 0.005
          if u:hasdata("忍野忍-怪异杀手进阶") then
            txsh = txsh * 2
            dh = dh * 2
            for _, xq in ac.selector():in_rangexy(x, y, 225):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              DamageUnit({
                bj = "忍野忍怪异杀手附伤",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "魔力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "无"
              })
            end
          else
            DamageUnit({
              bj = "忍野忍怪异杀手附伤",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
          end
          LossHpUnit({
            u = u,
            tg = tg,
            damage = dh * tg:gethp(),
            perhp = 0,
            maxhp = 0,
            bj = "[生命损耗]忍野忍怪异杀手"
          })
        end
        if not u:hasdata(var.name .. "-特效2冷却") and u:getluckrandom(5 * info.txgl) then
          u:settimedata(var.name .. "-特效2冷却", 1)
          local x, y = tg:getxy()
          local txsh = 25 * u:getdata("忍野忍-甜食值")
          Effectcreate("ZK_TTQ2.mdl", x, y, 0, 1, 90, GetRandomAngle())
          DamageUnit({
            bj = "忍野忍甜甜圈附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
        end
        if not u:hasdata(var.name .. "-甜腻施加冷却") and u:getluckrandom(5 * info.txgl) then
          local cooldown = 1
          if u:hasdata(OshinoTaboo.LIGHT_FLAG) then
            cooldown = OshinoTaboo.SWEET_APPLICATION_COOLDOWN
          end
          u:settimedata(var.name .. "-甜腻施加冷却", cooldown)
          ryr_tianniadd(tg, 1)
        end
      end)
      u:setdata("变异判定-微弱的鬼")
      u:changedata("吸血鬼变异数量", 1)
      u:changedata("唯一变异数量", 1)
      ChangeValue(DamageSystem_EndSh, sy, 0.005000000000000001)
      ChangeValue(HeroMenu_ExtraMoveSpeed_Bfb, sy, 0.1)
      u:uivar_add({
        keyname = "微弱的鬼",
        keytype = "血统栏",
        text = "|cFFFFFF00微|r|cFFFFCC00弱|r|cFFFF9900的|r|cFFFF6600鬼|r\n|cFFFFFF00咔|r|cFFFBFD0A咔|r|cFFF7FB14 |r|cFFF3F91D是|r|cFFEFF727这|r|cFFEBF531样|r|cFFE7F33B啊|r|cFFE4F145 |r|cFFE0EF4E是|r|cFFDCED58吾|r|cFFD8EB62保|r|cFFD4E96C护|r|cFFD0E776了|r|cFFCCE680汝|r|cFFC8E489 |r|cFFC4E293所|r|cFFC0E09D以|r|cFFBCDEA7汝|r|cFFB8DCB1要|r|cFFB4DABA对|r|cFFB1D8C4吾|r|cFFADD6CE加|r|cFFA9D4D8倍|r|cFFA5D2E2宠|r|cFFA1D0EB爱|r",
        icon = "Ryr_Xt_Wrdg.tga",
        ishasphoto = false,
        clickfunc = function(u)
          local sy = u.ownerid
          if u:hasdata("微弱的鬼-禁止进阶") or u:hasdata("血坏血统") then
            return
          end
          if u:getlevel() >= 35 then
            u:setdata("忍野忍血统进阶-始祖吸血鬼")
            u:uivar_change({
              keyname = "微弱的鬼",
              keytype = "血统栏",
              text = "|cFFFF9999始|r|cFFEE8080祖|r|cFFDD6666吸|r|cFFCC4C4C血|r|cFFBB3333鬼|r\n|cFFFF9999没|r|cFFFB9292有|r|cFFF68C8C汝|r|cFFF28585的|r|cFFED7E7E世|r|cFFE97878界|r|cFFE47171毁|r|cFFE06A6A掉|r|cFFDC6464又|r|cFFD75D5D如|r|cFFD35656何|r|cFFCE5050 |r|cFFCA4949破|r|cFFC54343碎|r|cFFC13C3C吧|r|cFFBC3535这|r|cFFB82F2F个|r|cFFB42828无|r|cFFAF2121用|r|cFFAB1B1B的|r|cFFA61414世|r|cFFA20D0D界|r",
              icon = "Ryr_Xt_Szxxg.tga",
              isclearclick = true
            })
            u:changedata("魅魔变异数量", 1)
            u:changedata("黑暗变异数量", 1)
            u:become("女神")
            u:changedata("吸血鬼变异补正", 50)
            u:addlevel(5)
            u:addstexiao("忍野忍血统", "直接伤害特效", function(args)
              local tg = args.tg
              local u = args.u
              local info = args.damageinfo
              if not u:hasdata("忍野忍血统-特效冷却") then
                u:settimedata("忍野忍血统-特效冷却", 1)
                DamageUnit({
                  bj = "忍野忍始祖吸血鬼",
                  unit = tg.handle,
                  source = u.handle,
                  damage = 0.35 * info.yssh,
                  level = 1,
                  type = "魔力",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = "暗"
                })
              end
              if not u:hasdata("忍野忍血统-特效2冷却") and tg:isboss() then
                u:settimedata("忍野忍血统-特效2冷却", 1)
                local txsh = 30000 + u:getdata("忍野忍-甜食值") * 5
                DamageUnit({
                  bj = "忍野忍始祖吸血鬼",
                  unit = tg.handle,
                  source = u.handle,
                  damage = 0.35 * info.yssh,
                  level = 1,
                  type = "魔力",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = "暗"
                })
              end
            end)
            PlayBGM({time = 85})
            PlayGlobalSound(Sound_Ryr_Xt_01)
            local strz = {
              {
                rw = 1,
                time = 39.1,
                str = "原来如此 居然真的存在 那样的未来 那样的世界"
              },
              {
                rw = 1,
                time = 47.8,
                str = "吾与汝如此亲近的可能性还是存在的嘛"
              },
              {
                rw = 1,
                time = 56.8,
                str = "这真是杰作"
              },
              {
                rw = 1,
                time = 58.8,
                str = "可吾却为了自己无聊的嫉妒毁掉了一切"
              },
              {
                rw = 1,
                time = 64.9,
                str = "因为吾的离家出走而失去汝时"
              },
              {
                rw = 1,
                time = 69.4,
                str = "那真是如同被夺走了单翼 被夺走了半身的感觉"
              },
              {
                rw = 1,
                time = 72,
                str = "可是那都没有像现在这样心痛过"
              }
            }
            for index, value in ipairs(strz) do
              local namestr, colorstr
              if value.rw == 1 then
                namestr = "|cFFFFAA22忍|r"
                colorstr = "|cFFFF0000"
              else
                namestr = "|cFF999999历|r"
                colorstr = "|cFFCCCCCC"
              end
              local showstr = "：『" .. value.str .. "』"
              SendDtimeMsgAll(value.time, namestr .. colorstr .. showstr, 10)
            end
          end
        end,
        rightclickfunc = function(u)
          if u:hasdata("微弱的鬼-禁止进阶") or u:hasdata("血坏血统") then
            return
          end
          if u:getlevel() >= 35 then
            u:setdata("忍野忍血统进阶-金发幼女")
            u:uivar_change({
              keyname = "微弱的鬼",
              keytype = "血统栏",
              text = "|cFFFFFF00金|r|cFFFFCC00发|r|cFFFF9900幼|r|cFFFF6600女|r\n|cFFFFFF66是|r|cFFFEFF66甜|r|cFFFCFF66甜|r|cFFFBFF66圈|r|cFFFAFF66吗|r|cFFF8FF66？|r|cFFF7FF66是|r|cFFF6FF66甜|r|cFFF4FF66甜|r|cFFF3FF66圈|r|cFFF2FF66吧|r|cFFF0FF66 |r|cFFEFFF66肯|r|cFFEEFF66定|r|cFFECFF66是|r|cFFEBFF66甜|r|cFFEAFF66甜|r|cFFE8FF66圈|r|cFFE7FF66 |r|cFFE6FF66 |r|cFFE4FF66吾|r|cFFE3FF66之|r|cFFE1FF66主|r|cFFE0FF66人|r|cFFDFFF66哟|r|cFFDDFF66 |r|cFFDCFF66赶|r|cFFDBFF66快|r|cFFD9FF66把|r|cFFD8FF66那|r|cFFD7FF66甜|r|cFFD5FF66甜|r|cFFD4FF66圈|r|cFFD3FF66献|r|cFFD1FF66给|r|cFFD0FF66吾|r|cFFCFFF66吧|r",
              icon = "Ryr_Xt_Jfyn.tga",
              ishasphoto = true,
              isclearclick = true
            })
            u:changedata("魅魔变异数量", 1)
            u:changedata("光明变异数量", 1)
            u:changedata("光明变异补正", 50)
            u:addlevel(-5)
            u:addstexiao("忍野忍血统", "直接伤害特效", function(args)
              local tg = args.tg
              local u = args.u
              local info = args.damageinfo
              if not u:hasdata("忍野忍血统-特效冷却") then
                u:settimedata("忍野忍血统-特效冷却", 1)
                DamageUnit({
                  bj = "忍野忍金发幼女",
                  unit = tg.handle,
                  source = u.handle,
                  damage = 0.35 * info.yssh,
                  level = 1,
                  type = "魔力",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = "光"
                })
              end
              if not u:hasdata("忍野忍血统-特效2冷却") and tg:isboss() then
                u:settimedata("忍野忍血统-特效2冷却", 1)
                local txsh = 30000 + u:getdata("忍野忍-甜食值") * 5
                DamageUnit({
                  bj = "忍野忍金发幼女",
                  unit = tg.handle,
                  source = u.handle,
                  damage = 0.35 * info.yssh,
                  level = 1,
                  type = "魔力",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = "光"
                })
              end
            end)
            PlayBGM({time = 150})
            PlayGlobalSound(Sound_Ryr_Xt_02)
            local strz = {
              {
                rw = 2,
                time = 1.3,
                str = "互相伤害的我们互相舔舐着对方的伤口"
              },
              {
                rw = 2,
                time = 8.6,
                str = "伤口累累的我们 相互慰籍"
              },
              {
                rw = 2,
                time = 14.9,
                str = "你若明日死 那我的性命也将止于明日"
              },
              {
                rw = 2,
                time = 20.8,
                str = "你若活过今日 那我也将陪你度过今日"
              },
              {
                rw = 2,
                time = 108.5,
                str = "就这样我们的物语就此开始"
              },
              {
                rw = 2,
                time = 112.2,
                str = "这是一段血之物语 濡血而赤 血涸而黑"
              },
              {
                rw = 2,
                time = 119.1,
                str = "它讲述着我们宝贵而永世不愈之伤"
              },
              {
                rw = 2,
                time = 123.5,
                str = "这段物语 我将不会像任何人提起"
              }
            }
            for index, value in ipairs(strz) do
              local namestr, colorstr
              if value.rw == 1 then
                namestr = "|cFFFFAA22忍|r"
                colorstr = "|cFFFF0000"
              else
                namestr = "|cFF999999历|r"
                colorstr = "|cFFCCCCCC"
              end
              local showstr = "：『" .. value.str .. "』"
              SendDtimeMsgAll(value.time, namestr .. colorstr .. showstr, 10)
            end
          end
        end
      })
    end,
    effectname = "|cFFFFFF00爱吃甜|r|cFFFFF240食的|r|cFFFFE680少女|r",
    effecttext = "|cFFFFF240曾经的她是美丽高贵的人类公主,拥有柔顺的金发，瓜子脸加上大大的双眼，\n鲜红的嘴唇，柔细的颈子，清透的肌肤，白皙的手指，柳腰的位置比常人高，\n窈窕的曲线就这么延伸到修长的双腿。直到有一天....|r",
    effectart = "war3mapImported\\BTNEwl_Ryr_Cq",
    test = [[

        ]]
  },
  {
    name = "破晓",
    clickfunc = function(u, ewl)
      if u:isalive() then
        local sy = u.ownerid
        if u.handle == Danwei_Baoming and u:isalive() and not Boolean_BaomingIng and Boolean_BaomingTip[1] and Boolean_BaomingTip[2] and Boolean_BaomingTip[3] and Boolean_BaomingTip[4] and not Boolean_BaomingTip[5] and u:ishasshw() then
          AdvanceGet["终末鸟"](u)
        end
      end
    end,
    weight = 5,
    key = {"唯一", "光明"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I0KL") then
        add = add + 5000
      end
      if u:ishasitem("I0AQ") then
        add = add + 5000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-薄暝") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cFFFF9933人们最终战胜了黄昏的黑暗，准备面对黎明的光辉。|r")
      ac.wait(3000, function()
        SendMsgAll("|cFFFF9933而在那片昏暗的森林中，鸟儿的叽喳鸣唱依旧响彻着吗?|r")
      end)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        u:changemaxhp(200)
      end)
      ChangeValue(DamageSplit_CountJzMax, sy, 0.4)
      ChangeValue(Correction_Jzsh, sy, 0.025)
      u:changedata("固定伤害", 333.3)
      ChangeValue(DamageSystem_GushangBeilv, sy, 0.03)
      for index, value in ipairs(Pools_SpeWeapon) do
        if value.name == "薄暝" then
          if not value.hasbeenget then
            local item = u:additem("I0AQ")
            System_Count_Weapon = System_Count_Weapon + 1
            SetData(item, "物品判定-神兵")
            SetData(item, "神兵-获取")
            value.hasbeenget = true
          end
          break
        end
      end
      if u:hasdata("判定-王女") then
        for index, value in ipairs(Pools_Spe) do
          if value.name == "无名众神的王女" then
            if not value.hasbeenget then
              local item = u:additem("I0PM")
              value.hasbeenget = true
            end
            break
          end
        end
      end
      Fskillreplace({
        unit = u.handle,
        level = 2,
        skill_F = "S0D8",
        skill_X = "S0D9",
        isforce = false,
        efunc = function()
          local function skill(args)
            if args.skill == S2ID("S0D8") or args.skill == S2ID("S0D9") then
              local tilixh = 2
              
              if not u:hasdata("位移体力消耗标记") then
                if u:lossstamina(tilixh) then
                  u:settimedata("位移体力消耗标记", 0.001)
                else
                  u:setskillcd(args.skill, 0.01)
                  u:sendmessage("|cFFFF3300体力值不足|r")
                  return
                end
              end
              do
                local target
                local target_x = args.x
                local target_y = args.y
                if args.target and args.target ~= 0 then
                  target = getunit(args.target)
                  if target then
                    target_x, target_y = target:getxy()
                  end
                end
                local is_point_cast = not target
                if not target_x or not target_y then
                  return
                end
                local x, y = u:getxy()
                if is_point_cast then
                  local cast_dis = DistanceXY(x, y, target_x, target_y)
                  if 4500 < cast_dis then
                    local cast_angle = AngleXY(x, y, target_x, target_y)
                    target_x, target_y = PolarXY(x, y, 4500, cast_angle)
                  end
                end
                local x1, y1 = target_x, target_y
                local jd = AngleXY(x, y, x1, y1)
                local dis = DistanceXY(x, y, x1, y1)
                local g = CreateGroupLua()
                local txsh = 5000
                if Hero_Equip_WeaponBoolean[sy] then
                  local skill = GetData(Hero_Equip_WeaponType[sy], "绑定技能")
                  u:setdata("诺登斯-计算伤害")
                  weaponuse(u.handle, skill, x, y)
                  u:deldata("诺登斯-计算伤害")
                  txsh = u:getdata("诺登斯-武器基础伤害")
                end
                local txsh1 = 0.5 * txsh
                local txsh2 = 0.1 * txsh + 100 * u:getallattri()
                ac.wait(1, function()
                  u:animeact(20)
                  u:animespeed(1)
                end)
                u:buffset(u.handle, 0.7, "暂停")
                u:buffset(u.handle, 0.7, "无敌")
                u:buffset(u.handle, 0.7, "绝对闪避")
                u:setface(jd)
                u:playseensound(Sound_Sjcj_01)
                ac.wait(1, function()
                  local ax, ay = PolarXY(x, y, 100, jd)
                  local tx = EffectcreateArgs({
                    effect = "war3mapImported\\sjcf6.mdx",
                    x = ax,
                    y = ay,
                    time = 0.5,
                    size = 1,
                    height = 0,
                    zxz = jd + 180,
                    animespeed = 50
                  })
                  ac.wait(500, function()
                    japi.EXSetEffectSize(tx, 5)
                    japi.EXSetEffectZ(tx, -600)
                    japi.EXSetEffectSpeed(tx, 3)
                  end)
                end)
                if is_point_cast and 1500 <= dis then
                  local ax, ay = PolarXY(x1, y1, 1500, jd + 180)
                  ac.wait(1, function()
                    local ax, ay = PolarXY(ax, ay, 100, jd)
                    local tx = EffectcreateArgs({
                      effect = "war3mapImported\\sjcf6.mdx",
                      x = ax,
                      y = ay,
                      time = 0.5,
                      size = 1,
                      height = 0,
                      zxz = jd + 180,
                      animespeed = 50
                    })
                    ac.wait(500, function()
                      japi.EXSetEffectSize(tx, 5)
                      japi.EXSetEffectZ(tx, -600)
                      japi.EXSetEffectSpeed(tx, 3)
                    end)
                  end)
                  ac.wait(500, function()
                    u:playseensound(Sound_Sjcj_02)
                    EffectcreateArgs({
                      effect = "war3mapImported\\sjcf5.mdx",
                      x = ax,
                      y = ay,
                      size = 7,
                      height = 200,
                      zxz = jd,
                      animespeed = 1
                    })
                    for i = 1, 10 do
                      EffectcreateArgs({
                        effect = "war3mapImported\\sjcf1.mdx",
                        x = ax,
                        y = ay,
                        size = GetRandomReal(3, 5),
                        height = 0,
                        zxz = jd,
                        animespeed = 1
                      })
                    end
                  end)
                  ac.wait(490, function()
                    u:setxy(ax, ay)
                  end)
                else
                  ac.wait(500, function()
                    u:playseensound(Sound_Sjcj_02)
                    EffectcreateArgs({
                      effect = "war3mapImported\\sjcf5.mdx",
                      x = x,
                      y = y,
                      size = 7,
                      height = 200,
                      zxz = jd,
                      animespeed = 1
                    })
                    for i = 1, 10 do
                      EffectcreateArgs({
                        effect = "war3mapImported\\sjcf1.mdx",
                        x = x,
                        y = y,
                        size = GetRandomReal(3, 5),
                        height = 0,
                        zxz = jd,
                        animespeed = 1
                      })
                    end
                  end)
                end
                ac.wait(500, function()
                  x, y = u:getxy()
                  if target then
                    x1, y1 = target:getxy()
                  else
                    x1, y1 = target_x, target_y
                  end
                  jd = AngleXY(x, y, x1, y1)
                  local loop_time = 30
                  local dash_speed = (GetUnitMoveSpeed(u.handle) + u:getdata("当前额外移速")) * 8
                  if dash_speed < 1000 then
                    dash_speed = 1000
                  elseif 6000 < dash_speed then
                    dash_speed = 6000
                  end
                  local dash_step = dash_speed * loop_time / 1000
                  local dash_time = 0
                  local cs1 = 2
                  local g2 = CreateGroupLua()
                  ac.loop(loop_time, function(t)
                    dash_time = dash_time + loop_time
                    u:buffset(u.handle, 0.1, "暂停")
                    u:buffset(u.handle, 0.1, "无敌")
                    u:buffset(u.handle, 0.1, "绝对闪避")
                    if 2000 <= dash_time then
                      t:remove()
                      return
                    end
                    cs1 = cs1 + 1
                    local dx, dy = u:getxy()
                    dx, dy = PolarXY(dx, dy, dash_step, jd - 90)
                    for _, xq in ac.selector():in_rangexy(dx, dy, 300):is_enemy(u.handle):isnotingroup(g2):ipairs() do
                      xq = getunit(xq)
                      xq:groupadd(g2)
                      DamageUnit({
                        unit = xq.handle,
                        source = u.handle,
                        damage = txsh1,
                        level = 1,
                        type = "物理",
                        isvest = false,
                        isattack = true,
                        isnoarmor = false,
                        element = "无",
                        extradata = {""}
                      })
                    end
                    if cs1 == 2 then
                      cs1 = 0
                      EffectcreateArgs({
                        effect = "war3mapImported\\sjcf7.mdx",
                        x = dx,
                        y = dy,
                        size = GetRandomReal(1, 3),
                        height = 0,
                        zxz = GetRandomAngle(),
                        animespeed = 4
                      })
                      EffectcreateArgs({
                        effect = "war3mapImported\\sjcf1.mdx",
                        x = dx,
                        y = dy,
                        size = 1,
                        height = 0,
                        zxz = jd,
                        animespeed = 1
                      })
                    end
                    local dx1, dy1 = u:getxy()
                    local dx2, dy2
                    if target then
                      dx2, dy2 = target:getxy()
                    else
                      dx2, dy2 = target_x, target_y
                    end
                    local jd1 = AngleXY(dx1, dy1, dx2, dy2)
                    local jl1 = DistanceXY(dx1, dy1, dx2, dy2)
                    if is_point_cast and jl1 <= dash_step + 500 then
                      local jump_x, jump_y = PolarXY(dx2, dy2, 500, jd1 + 180)
                      u:setxy(jump_x, jump_y)
                      u:shockcamera(100, 0.1)
                      EffectcreateArgs({
                        effect = "war3mapImported\\chongci_Bo.mdx",
                        x = dx2,
                        y = dy2,
                        size = 3,
                        height = 0,
                        zxz = jd1 + 180,
                        animespeed = 1
                      })
                      EffectcreateArgs({
                        effect = "war3mapImported\\chongci_Bo.mdx",
                        x = dx2,
                        y = dy2,
                        size = 3,
                        height = 0,
                        zxz = jd1 + 180,
                        animespeed = 1
                      })
                      EffectcreateArgs({
                        effect = "war3mapImported\\sjcf2.mdx",
                        x = dx2,
                        y = dy2,
                        time = 0.5,
                        size = 5,
                        height = 0,
                        zxz = jd1,
                        yxz = -90,
                        animespeed = 2
                      })
                      EffectcreateArgs({
                        effect = "war3mapImported\\sjcf1.mdx",
                        x = dx2,
                        y = dy2,
                        size = 6,
                        height = 0,
                        zxz = jd1,
                        animespeed = 1
                      })
                      unitjump({
                        unit = u.handle,
                        time = 0.5,
                        distance = 500,
                        height = 1000,
                        angle = jd1,
                        isfly = true
                      })
                      u:buffset(u.handle, 0.5, "暂停")
                      u:buffset(u.handle, 0.7, "无敌")
                      ac.wait(500, function()
                        u:playseensound(Sound_Sjcj_03)
                        local dx3, dy3 = PolarXY(dx2, dy2, 500, jd1)
                        for i = 1, 5 do
                          EffectcreateArgs({
                            effect = "war3mapImported\\sjcf3.mdx",
                            x = dx3,
                            y = dy3,
                            size = GetRandomReal(1, 6),
                            height = -100,
                            zxz = GetRandomAngle(),
                            animespeed = 5
                          })
                        end
                        EffectcreateArgs({
                          effect = "war3mapImported\\sjcf2.mdx",
                          x = dx3,
                          y = dy3,
                          time = 0.5,
                          size = 2,
                          height = 0,
                          zxz = GetRandomAngle(),
                          animespeed = 2
                        })
                        for i = 1, 10 do
                          ac.wait(i * 50, function()
                            u:shockcamera(100, 0.02)
                            EffectcreateArgs({
                              effect = "war3mapImported\\sjcf4.mdx",
                              x = dx3,
                              y = dy3,
                              time = 0.5,
                              size = 1.5,
                              height = GetRandomReal(200, 400),
                              zxz = GetRandomAngle(),
                              xxz = GetRandomAngle(),
                              yxz = GetRandomAngle(),
                              animespeed = GetRandomReal(3, 6)
                            })
                            for _, xq in ac.selector():in_rangexy(dx3, dy3, 500):is_enemy(u.handle):ipairs() do
                              xq = getunit(xq)
                              local dxx, dyy = xq:getxy()
                              local dx5, dy5 = PolarXY(dxx, dyy, GetRandomReal(0, 50), GetRandomAngle())
                              xq:setxy(dx5, dy5)
                              xq:animeact("Death")
                              xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
                              DamageUnit({
                                unit = xq.handle,
                                source = u.handle,
                                damage = txsh2,
                                level = 1,
                                type = "物理",
                                isvest = false,
                                isattack = true,
                                isnoarmor = false,
                                element = "无",
                                extradata = {""}
                              })
                            end
                          end)
                        end
                      end)
                      t:remove()
                      return
                    end
                    dx1, dy1 = PolarXY(dx1, dy1, dash_step, jd1)
                    u:setxy(dx1, dy1)
                    if not is_point_cast then
                      for _, xq in ac.selector():in_rangexy(dx1, dy1, 300):is_enemy(u.handle):ipairs() do
                        xq = getunit(xq)
                        if not xq:isingroup(g) then
                          xq:groupadd(g)
                          xq:animeact("Death")
                          unitjump({
                            unit = xq.handle,
                            time = 0.2,
                            distance = 100,
                            height = 500,
                            angle = jd1,
                            isfly = true
                          })
                          DamageUnit({
                            unit = xq.handle,
                            source = u.handle,
                            damage = txsh2,
                            level = 1,
                            type = "物理",
                            isvest = false,
                            isattack = true,
                            isnoarmor = false,
                            element = "无",
                            extradata = {""}
                          })
                        end
                      end
                    end
                    if not is_point_cast and jl1 <= 250 then
                      local dx3, dy3 = dx2, dy2
                      dx3, dy3 = PolarXY(dx3, dy3, 500, jd1)
                      u:shockcamera(100, 0.1)
                      EffectcreateArgs({
                        effect = "war3mapImported\\chongci_Bo.mdx",
                        x = dx,
                        y = dy,
                        size = 3,
                        height = 0,
                        zxz = jd + 180,
                        animespeed = 1
                      })
                      EffectcreateArgs({
                        effect = "war3mapImported\\chongci_Bo.mdx",
                        x = dx,
                        y = dy,
                        size = 3,
                        height = 0,
                        zxz = jd + 180,
                        animespeed = 1
                      })
                      EffectcreateArgs({
                        effect = "war3mapImported\\sjcf2.mdx",
                        x = dx,
                        y = dy,
                        time = 0.5,
                        size = 5,
                        height = 0,
                        zxz = jd,
                        yxz = -90,
                        animespeed = 2
                      })
                      EffectcreateArgs({
                        effect = "war3mapImported\\sjcf1.mdx",
                        x = dx,
                        y = dy,
                        size = 6,
                        height = 0,
                        zxz = jd,
                        animespeed = 1
                      })
                      if target then
                        unitjump({
                          unit = target.handle,
                          time = 0.2,
                          distance = 500,
                          height = 300,
                          angle = jd1,
                          isfly = true
                        })
                        target:animeact("Death")
                      end
                      unitjump({
                        unit = u.handle,
                        time = 0.5,
                        distance = 500,
                        height = 1000,
                        angle = jd1,
                        isfly = true
                      })
                      u:buffset(u.handle, 0.5, "暂停")
                      u:buffset(u.handle, 0.7, "无敌")
                      ac.wait(500, function()
                        u:playseensound(Sound_Sjcj_03)
                        if target then
                          unitjump({
                            unit = target.handle,
                            time = 0.2,
                            distance = 100,
                            height = 500,
                            angle = jd1,
                            isfly = true
                          })
                        end
                        for i = 1, 5 do
                          EffectcreateArgs({
                            effect = "war3mapImported\\sjcf3.mdx",
                            x = dx3,
                            y = dy3,
                            size = GetRandomReal(1, 6),
                            height = -100,
                            zxz = GetRandomAngle(),
                            animespeed = 5
                          })
                        end
                        EffectcreateArgs({
                          effect = "war3mapImported\\sjcf2.mdx",
                          x = dx3,
                          y = dy3,
                          time = 0.5,
                          size = 2,
                          height = 0,
                          zxz = GetRandomAngle(),
                          animespeed = 2
                        })
                        local dx4, dy4 = dx2, dy2
                        if target then
                          dx4, dy4 = target:getxy()
                        end
                        for i = 1, 10 do
                          ac.wait(i * 50, function()
                            u:shockcamera(100, 0.02)
                            EffectcreateArgs({
                              effect = "war3mapImported\\sjcf4.mdx",
                              x = dx3,
                              y = dy3,
                              time = 0.5,
                              size = 1.5,
                              height = GetRandomReal(200, 400),
                              zxz = GetRandomAngle(),
                              xxz = GetRandomAngle(),
                              yxz = GetRandomAngle(),
                              animespeed = GetRandomReal(3, 6)
                            })
                            for _, xq in ac.selector():in_rangexy(dx3, dy3, 500):is_enemy(u.handle):ipairs() do
                              xq = getunit(xq)
                              local dxx, dyy = xq:getxy()
                              local dx5, dy5 = PolarXY(dxx, dyy, GetRandomReal(0, 50), GetRandomAngle())
                              xq:setxy(dx5, dy5)
                              xq:animeact("Death")
                              xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
                              DamageUnit({
                                unit = xq.handle,
                                source = u.handle,
                                damage = txsh2,
                                level = 1,
                                type = "物理",
                                isvest = false,
                                isattack = true,
                                isnoarmor = false,
                                element = "无",
                                extradata = {""}
                              })
                            end
                          end)
                        end
                      end)
                      t:remove()
                    end
                  end)
                end)
              end
            end
          end
          
          u:addtrgevent("单位-发动技能", function(args)
            skill(args)
          end)
        end
      })
    end,
    effectname = "|cFFFF9933破晓|r",
    effecttext = "|cFFFF9933它能避免无辜的人遇害，但在那之前，你必须做好万无一失的准备，去踏入那片黑暗而又绝望的森林。|r",
    effectart = "war3mapImported\\BTNBaoming_ICON",
    test = [[

        ]]
  },
  {
    name = "天翼种",
    clickfunc = function(u, ewl)
      if u:isalive() then
        local sy = u.ownerid
        if not u:hasdata("吉普利露-非天使化") and u:getdata("天翼种-杀敌计数") >= 200 and u:ishasshw() then
          AdvanceGet["吉普利露"](u)
        end
      end
    end,
    weight = 5,
    key = {"唯一", "魔导"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I0C7") then
        add = add + 5000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-吉普利露") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Jpll_001)
      SendMsgAll("|cFFCC33FF嗨~————欢迎光临|r")
      for index, value in ipairs(Pools_SpeDzWeapon) do
        if value.name == "天翼种之镰" then
          if not value.hasbeenget then
            local wp = u:additem("I0C7")
            System_Count_Weapon = System_Count_Weapon + 1
            SetData(wp, "物品判定-神兵")
            SetData(wp, "神兵-获取")
            value.hasbeenget = true
          end
          break
        end
      end
      u:setdata("系统-无视伤害闪避")
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        info.pk_shouhu = true
      end)
      u:addstexiao(var.name .. "2", "近战伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("吉普利露-精灵回廊近战强化") and not info.isvestdamage and not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 0.5)
          local mpxh = 1 + 0.06 * u:getmaxmp()
          if mpxh <= u:getmp() then
            u:curemp(-mpxh)
            local tx = u:getdata("吉普利露-精灵回廊近战强化")
            DestroyEffectLua(tx)
            u:deldata("吉普利露-精灵回廊近战强化")
            local txsh = info.yssh * 0.2
            local level = 4
            if u:hasdata("变异判定-吉普利露") then
              level = 5
            end
            DamageUnit({
              bj = "吉普利露精灵回廊附伤",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = level,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
          end
        end
      end)
      u:addstexiao(var.name, "伤害系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        info.gl = info.gl + 0.1 * (Correction_Magic[sy] - 1)
        if u:hasdata("吉普利露-禁忌化二") then
          info.gl = info.gl + 0.3
        end
        if u:hasdata("变异判定-吉普利露") then
          info.gl = info.gl + 0.03 * u:getshenxing()
        end
      end)
      u:addskill("A1CZ")
      ChangeValue(Correction_Magic, sy, 0.003)
      ChangeValue(HeroMenu_MpCure_MaxMp, sy, 1)
      ChangeValue(HeroMenu_MpCure_Inr, sy, 1)
      ac.loop(250, function(timer)
        if u:isalive() and not u:hasdata("天翼种-加速冷却") and GetUnitMoveSpeed(u.handle) <= 300 then
          u:sendmessage("|cFFCC33FF天翼种-加速|r")
          u:settimedata("天翼种-加速冷却", 30)
          u:addskill("S07A")
          ac.wait(30000, function()
            u:delskill("S07A")
          end)
        end
      end)
      u:setdata("天翼种-杀敌回蓝值", 1)
      u:addstexiao(var.name, "杀敌效果", function(args)
        if u:hasdata("变异判定-吉普利露") then
          ChangeValue(Correction_Magic, sy, 1.0E-5)
        else
          ChangeValue(Correction_Magic, sy, 5.0E-6)
          u:changedata("天翼种-杀敌计数", 1)
        end
        ChangeValue(DamageSystem_Shjc, sy, 5.0E-5)
        if u:getdata("天翼种-杀敌回蓝值") < 5 then
          u:changetimedata("天翼种-杀敌回蓝值", 0.5, 10)
        end
        u:curemp(0, u:getdata("天翼种-杀敌回蓝值"))
        if not u:hasdata("吉普利露-杀戮天使冷却") then
          u:sendmessage("|cFFCC66FF吉普利露-杀戮天使|r")
          local t2 = 50
          if u:hasdata("吉普利露-禁忌化") then
            t2 = 600
          end
          u:settimedata("吉普利露-杀戮天使冷却", t2)
          local t = 20
          if u:hasdata("变异判定-吉普利露") then
            if u:hasdata("吉普利露-禁忌化") then
              t = 600
            else
              t = 30
            end
          end
          u:settimedata("吉普利露-杀戮天使", t)
          ChangeTimeValue(HeroMenu_MpCure_MaxMp, sy, 3, t)
          ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 100, t)
          ChangeTimeValue(DamageSystem_Shjc, sy, 0.025, t)
          local x, y = u:getxy()
          local mj = u:createunit("u0C5", x, y)
          mj:timetoremove(2.5)
          ac.wait(1, function()
            mj:animeact("birth")
          end)
          u:playsound(bac277)
          ForGroupLuaNew(u:getdata("吉普利露-羽毛组"), function(xq)
            local dx, dy = xq:getxy()
            Effectcreate("0Tx\\0Tx_Jpll_07.mdl", dx, dy)
          end)
          ac.wait(1000, function()
            u:effectadd("0Tx\\0Tx_Jpll_06.mdl", "origin", 19)
            u:effectadd("0Tx\\0Tx_Jpll_08.mdl", "origin", 19)
          end)
          ac.wait(2000, function()
            u:playsound(bac278)
          end)
        end
      end)
      
      local function chat(args)
        if args.chat == "-ymqh" then
          if not u:hasdata("吉普利露-羽毛伤害关闭") then
            u:setdata("吉普利露-羽毛伤害关闭")
            u:sendmessage("|cFF7DBEF1关闭羽毛弹幕|r")
          else
            u:deldata("吉普利露-羽毛伤害关闭")
            u:sendmessage("|cFF7DBEF1开启羽毛弹幕|r")
          end
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chat(args)
      end)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        u:addint(2)
        u:changemaxmp(1)
        ChangeValue(Correction_Magic, sy, 1.0E-4)
        if u:hasdata("变异判定-吉普利露") then
          ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 0.2)
          ChangeValue(DamageSystem_Baoshang, sy, 0.01)
          u:changemaxmp(1)
          u:addallstats(1)
          u:changedata("吉普利露-番外个体计数", 1)
          if u:getdata("吉普利露-番外个体计数") >= 15 then
            u:changedata("吉普利露-番外个体计数", -15)
            u:changedata("残机剩余数量", 1)
            u:setusedfodd(u:getdata("残机剩余数量"))
          end
        end
      end)
      local g = CreateGroupLua()
      u:setdata("吉普利露-羽毛组", g)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.88, 1)
      u:setdata("天翼种-羽毛数量", 0)
      local cs = 0
      local cs2 = 0
      local cs3 = 0
      ac.loop(500, function()
        cs = cs + 1
        local csmax = 10
        if u:hasdata("变异判定-吉普利露") then
          if u:hasdata("吉普利露-禁忌化") then
            csmax = math.floor((3 - 0.005 * u:getdata("吉普利露-羽毛加速")) / 0.5)
            if csmax <= 2 then
              csmax = 2
            end
          else
            csmax = 6
          end
        end
        if csmax <= cs then
          cs = 0
          local max = math.floor(3 + u:getlevel() / 20)
          local mpxh = 1 + 0.1 * u:getmaxmp()
          if u:hasdata("变异判定-吉普利露") then
            mpxh = 1 + 0.05 * u:getmaxmp()
          end
          if mpxh <= u:getmp() and max > u:getdata("天翼种-羽毛数量") then
            u:changedata("天翼种-羽毛数量", 1)
            local x, y = u:getxy()
            u:curemp(-mpxh)
            local mj = u:createunit("u0C4", x, y)
            mj:setguard(u.handle, 1000)
            mj:setdata("吉普利露-羽毛")
            mj:groupadd(g)
            Effectcreate("0Tx\\0Tx_Jpll_02.mdx", x, y)
          end
        end
        if u:isalive() then
          if not u:hasdata("吉普利露-精灵回廊近战强化") then
            cs2 = cs2 + 1
            if cs2 == 12 then
              cs2 = 0
              u:setdata("吉普利露-精灵回廊近战强化", u:effectadd("Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl", "hand left", -1))
            end
          end
          if u:hasdata("吉普利露-精灵回廊护盾值") then
            cs3 = 0
            local mpxh = 1 + 0.007 * u:getmaxmp()
            if mpxh <= u:getmp() then
              u:curemp(-mpxh)
              local max2, hf
              if u:hasdata("变异判定-吉普利露") then
                max2 = 0.2 * u:getmaxhp() + (10 + 0.2 * u:getdata("吉普利露-回廊计数")) * u:getint()
                hf = 0.01 + 0.005 * u:getdata("吉普利露-回廊计数")
              else
                max2 = 0.2 * u:getmaxhp() + 10 * u:getint()
                hf = 0.01
              end
              u:changedata("吉普利露-精灵回廊护盾值", hf * max2)
              if max2 <= u:getdata("吉普利露-精灵回廊护盾值") then
                u:setdata("吉普利露-精灵回廊护盾值", max2)
              end
              Hdzflash(u)
            end
          else
            cs3 = cs3 + 1
            if 40 <= cs3 then
              cs3 = 0
              u:setdata("吉普利露-精灵回廊护盾值", 0.2 * u:getmaxhp() + 10 * u:getint())
              Hdzflash(u)
            end
          end
        end
      end)
      ac.loop(500, function()
        ForGroupLuaNew(g, function(xq)
          local dis = DistanceBetweenUnits(xq.handle, u.handle)
          if 1500 <= dis then
            unitmove({
              unit = xq.handle,
              time = 0.5,
              distance = 1000,
              angle = AngleBetweenUnits(xq.handle, u.handle),
              isfly = true
            })
          end
        end)
      end)
    end,
    effectname = "|cFFCC33FF幼小的天翼种|r",
    effecttext = "|cFFCC33FF天翼种|r\n|cFFFF66FF[]|r\n|cFFCC33FF番外个体|r\n|cFFFF66FF[]|r\n|cFFCC33FF精灵回廊|r\n|cFFFF66FF[]|r\n|cFFCC33FF杀戮中诞生的天使|r\n|cFFFF66FF[]|r",
    effectart = "war3mapImported\\BTNEwl_Jpll_Chuanqi",
    test = [[

        ]]
  },
  {
    name = "露娜",
    clickfunc = function(u, ewl)
      if u:isalive() then
        local sy = u.ownerid
        if not u:hasdata("变异判定-露娜神化") and u:getdata("露娜-杀敌数量") >= 200 and u:ishasshw() and GetTimeOfDay() <= 2 and GetTimeOfDay() >= 0 then
          AdvanceGet["露娜神化"](u)
        end
      end
    end,
    weight = 5,
    key = {
      "唯一",
      "白毛",
      "星"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I0GJ") then
        add = add + 5000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-露娜") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Chuanqi_Chufa)
      SendMsgAll("|cFFFFCCFF樱|r|cFFFFCFFC小|r|cFFFFD1FA路|r|cFFFFD4F7ル|r|cFFFFD6F5ナ:|cFFCCCCFF把|r|cFFCFC4FF那|r|cFFD1BCFF天|r|cFFD4B4FF的|r|cFFD7ACFF事|r|cFFD9A4FF情|r|cFFDC9CFF作|r|cFFDF94FF为|r|cFFE18CFF教|r|cFFE484FF训|r|cFFE77BFF，|r|cFFEA73FF不|r|cFFEC6BFF再|r|cFFEF63FF依|r|cFFF25BFF靠|r|cFFF453FF任|r|cFFF74BFF何|r|cFFFA43FF人|r")
      ac.wait(3000, function()
        SendMsgAll("|cFFFFCCFF樱|r|cFFFFCFFC小|r|cFFFFD1FA路|r|cFFFFD4F7ル|r|cFFFFD6F5ナ:|cFF00FFFF一|r|cFF20E6FF个|r|cFF40CCFF人|r|cFF60B2FF生|r|cFF8099FF存|r|cFF9F80FF下|r|cFFBF66FF去|r")
      end)
      ac.wait(5000, function()
        SendMsgAll("|cFFFFCCFF樱|r|cFFFFCFFC小|r|cFFFFD1FA路|r|cFFFFD4F7ル|r|cFFFFD6F5ナ:|cFFCC3399作|r|cFFCE389C出|r|cFFCF3C9F这|r|cFFD040A2种|r|cFFD245A5决|r|cFFD44AA8定|r|cFFD54EAB的|r|cFFD652AE我|r|cFFD857B1，|r|cFFDA5CB4被|r|cFFDB60B7她|r|cFFDC64BA认|r|cFFDE69BD为|r|cFFE06EC0只|r|cFFE172C3要|r|cFFE276C6纠|r|cFFE47BC9缠|r|cFFE680CC一|r|cFFE784CF下|r|cFFE888D2就|r|cFFEA8DD5会|r|cFFEC92D8毫|r|cFFED96DB无|r|cFFEE9ADE反|r|cFFF09FE1抗|r|cFFF2A4E4的|r|cFFF3A8E7露|r|cFFF4ACEA出|r|cFFF6B1ED天|r|cFFF8B6F0真|r|cFFF9BAF3的|r|cFFFABEF6表|r|cFFFCC3F9情|r")
      end)
      ac.wait(12000, function()
        SendMsgAll("|cFFFFCCFF樱|r|cFFFFCFFC小|r|cFFFFD1FA路|r|cFFFFD4F7ル|r|cFFFFD6F5ナ:|cFFCC3399真|r|cFFD246A6是|r|cFFD959B2太|r|cFFDF6CBF不|r|cFFE680CC甘|r|cFFEC93D9心|r|cFFF2A6E6了|r")
      end)
      ac.wait(13000, function()
        SendMsgAll("|cFFFFCCFF樱|r|cFFFFCFFC小|r|cFFFFD1FA路|r|cFFFFD4F7ル|r|cFFFFD6F5ナ:|cFFFFCCFF我|r|cFFFFCEFD不|r|cFFFFD0FB想|r|cFFFFD2F9再|r|cFFFFD4F7体|r|cFFFFD6F5会|r|cFFFFD8F3这|r|cFFFFDAF1种|r|cFFFFDCEF心|r|cFFFFDEED情|r|cFFFFE0EB，|r|cFFFFE2E9为|r|cFFFFE4E7此|r|cFFFFE7E4再|r|cFFFFE9E2也|r|cFFFFEBE0不|r|cFFFFEDDE会|r|cFFFFEFDC从|r|cFFFFF1DA心|r|cFFFFF3D8里|r|cFFFFF5D6信|r|cFFFFF7D4赖|r|cFFFFF9D2别|r|cFFFFFBD0人|r")
      end)
      ac.wait(21000, function()
        SendMsgAll("|cFFFFCCFF樱|r|cFFFFCFFC小|r|cFFFFD1FA路|r|cFFFFD4F7ル|r|cFFFFD6F5ナ:|cFFFFCCFF这|r|cFFFFCFFC样|r|cFFFFD3F8.|r|cFFFFD6F5.|r|cFFFFDAF1.|r|cFFFFDDEE.|r|cFFFFE0EB.|r|cFFFFE4E7.|r|cFFFFE7E4就|r|cFFFFEBE0明|r|cFFFFEEDD白|r|cFFFFF1DA了|r|cFFFFF5D6吧|r|cFFFFF8D3？|r")
      end)
      for index, value in ipairs(Pools_Spe) do
        if value.name == "露娜酱玩偶" then
          if not value.hasbeenget then
            u:additem("I0GJ")
            value.hasbeenget = true
          end
          break
        end
      end
      ChangeValue(Correction_Exp, sy, 0.15)
      ChangeValue(Correction_Gold, sy, 0.075)
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        info.pk_lichang = true
        info.pk_zhiyuan = true
        info.pk_mohu = true
      end)
      local cs = 0
      ac.loop(1000, function(t)
        if u:isalive() then
          u:changedata("露娜-未受伤时间", -1)
        end
        if u:getdata("露娜-未受伤时间") <= 0 and not u:hasdata("露娜-护盾值") then
          local hd = 0.15327 * u:getmaxhp() + 3.27 * u:getint()
          if u:hasdata("变异判定-露娜神化") then
            hd = 0.327 * u:getmaxhp() + 3.27 * u:getint()
          end
          u:setdata("露娜-护盾值", hd)
          Hdzflash(u)
          u:setdata("露娜-未受伤时间", 33)
        end
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        ChangeValue(DamageSystem_Shjc, sy, 5.0E-5)
        ChangeValue(DamageSystem_Shjc, sy, 5.0E-5)
        u:changedata("露娜-杀敌数量", 1)
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(32.7 * info.txgl) then
          local x, y = u:getxy()
          local x2, y2 = tg:getxy()
          local angle = AngleXY(x, y, x2, y2)
          u:settimedata(var.name .. "-特效冷却", 2)
          local txsh = 175 * u:getint()
          if u:hasdata("变异判定-露娜神化") then
            txsh = txsh + 2000 * u:getlevel()
          end
          local tx = Effectcreate("luna_texiao-fen.mdl", x, y)
          DamageUnit({
            bj = "露娜附伤",
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
          unifycreate({
            owner = u.handle,
            model = "luna_zidan.mdl",
            modelname = "露娜-百合弹幕",
            modelsize = 1,
            height = 90,
            damage = txsh,
            damagetype = 6,
            x = x,
            y = y,
            range = 3000,
            speed = 1500,
            volume = 90,
            angle = angle,
            angleoffset = 0,
            attenua = 1,
            attenuacount = 999,
            life = 10,
            isbullet = false,
            isvest = false,
            isignorearmor = false,
            startfunc = function(mj)
              mj:setdata("循环计数", 0)
            end,
            loopfunc = function(mj)
              mj:changedata("循环计数", UnifyDT)
              if mj:getdata("循环计数") >= 0.03 then
                mj:setdata("循环计数", 0)
              end
            end,
            hitfunc = function(mj, damage)
              return damage
            end,
            hitbeforefunc = function(mj, xq, damage2)
              u:setdata("系统-本次伤害无视伤害抗性")
            end,
            hitafterfunc = function(mj, xq, damage2)
              u:deldata("系统-本次伤害无视伤害抗性")
            end,
            endfunc = function(mj)
            end
          })
        end
      end)
    end,
    effectname = "|cFFFFCCFF依|r|cFFECD2FF月|r|cFFD9D9FF佳|r|cFFC6DFFF人|r|cFFB2E6FF之|r|cFF9FECFF贞淑|r",
    effecttext = "|cffacffff[高山雪绒]\n身为露娜的下人居然敢羞辱我。作为惩罚，来伺候我吧。|r\n|cfffffbb1[向日葵]\n我很擅长搬东西的哦。你看，我家不是开运输公司的嘛。|r\n|cffe5f9ff[百合]\n你叫朝日吗？真是个好名字。就像是旭日旗的象征一样，很适合我国女性的身份。|r\n|cfffae1ff[扁桃]\n我坚决反对近亲结婚，绝对，不行。亲戚间结婚什么的，仅仅想想就要吐了|r\n|cffff96ff[染井吉野樱]\n心情大好~|r\n|cffffc9f4“我的快乐是让她的梦想在这个世界上成为现实，所以屈居幕后也好，描绘梦想的只有她也罢，这并非约束我的规则，而是我对她的礼仪|r",
    effectart = "war3mapImported\\BTNEwl_Luna_Cq",
    test = [[

        ]]
  }
}
