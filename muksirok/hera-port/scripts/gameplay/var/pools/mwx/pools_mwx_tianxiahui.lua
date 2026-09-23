-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local keystring = "天下会"
Vars_Mwx_Tianxiahui_Lv1 = {
  {
    name = "刀鬼",
    weight = 100,
    lv = 1,
    key = {},
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
      u:setdata("刀鬼-提升刀伤害", 0.05 * u:getlevel())
      ChangeValue(DamageSystem_XxzJz, sy, 12)
    end,
    effectname = "|cFFCC0099刀鬼|r",
    effecttext = "|cFFCC33FF【阶级】1\n【效果】\n获取时提升[5%*等级]刀伤害\n获取时提升[5%*等级]小刀伤害\n提升12近战伤害吸血|r\n|cFF949596唯刀百辟，唯心不易|r",
    effectart = "war3mapImported\\BTNEwl_Daogui.blp"
  },
  {
    name = "全垒打",
    weight = 10,
    lv = 1,
    key = {"唯一"},
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
      u:sendmessage("|cFF1BE6B8你会打棒球了！|r", 3)
      u:addskill("A0Q8")
      u:banskill("A0Q8")
      u:additem("I027")
      u:setskillforever("A0Q5")
      
      local function skill(args)
        if args.skill == S2ID("A0Q5") then
          local wq = Hero_Equip_WeaponType[sy]
          if wq ~= Weapons["撬棍"] and wq ~= Weapons["棒球棍"] and wq ~= Weapons["辉煌耀世"] and wq ~= Weapons["物理学圣剑"] then
            u:sendmessage("|cFF7DBEF1武器不符合释放条件|r")
            u:setskillcd("A0Q5", 1)
            return
          end
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          Effectcreate("Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl", x, y)
          Effectcreate("Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl", x2, y2)
          u:setxy(x2, y2)
          if wq == Weapons["辉煌耀世"] then
            u:buffset(u.handle, 0.9, "暂停")
            u:buffset(u.handle, 0.9, "无敌")
            u:buffset(u.handle, 0.9, "绝对闪避")
            PlayGlobalSound(Qld_Zjd2)
            Effectcreate("war3mapImported\\[TX] (327).mdl", x2, y2, 0, 5)
            local g = CreateGroupLua()
            for _, xq in ac.selector():in_rangexy(x2, y2, 1100):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g)
              xq:buffset(u.handle, 1, "暂停")
            end
            ac.wait(900, function()
              for i = 1, 6 do
                Effectcreate("war3mapImported\\effect_[spell]xinzhao_r2.mdl", x2, y2, 0, 0.5 * i)
              end
              for _, xq in ac.selector():in_rangexy(x2, y2, 1100):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g)
                xq:buffset(u.handle, 10, "暂停")
              end
              local txsh = 100000 + 15000 * u:getlevel()
              ForGroupLuaNew(g, function(xq)
                if xq:isboss() then
                  u:setdata("全垒打固伤", 0.05)
                end
                DamageUnit({
                  bj = "全垒打(附伤)",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 5,
                  type = "物理",
                  isvest = false,
                  isattack = true,
                  isnoarmor = false,
                  element = "光"
                })
                u:deldata("全垒打固伤")
                xq:animeact("death")
                xq:effectadd("Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl", "origin", 10)
              end)
            end)
          end
          if wq == Weapons["物理学圣剑"] or wq == Weapons["撬棍"] then
            u:buffset(u.handle, 6.5, "暂停")
            u:buffset(u.handle, 10, "无敌")
            u:buffset(u.handle, 6.5, "绝对闪避")
            PlayGlobalSound(Qld_CQC)
            Effectcreate("war3mapImported\\effect_red-texiao-shandian.mdl", x2, y2, 0, 2)
            local g = CreateGroupLua()
            for _, xq in ac.selector():in_rangexy(x2, y2, 250):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g)
              xq:buffset(u.handle, 7, "暂停")
            end
            u:chat("那么请看好了")
            u:chat("宇宙CQC的可怕之处！", 2.2)
            ac.wait(6500, function()
              Effectcreate("war3mapimported\\effect_by_wood_effect_d2_shadowfiend_shadowraze_1.mdl", x2, y2, 0, 2)
              for _, xq in ac.selector():in_rangexy(x2, y2, 250):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g)
                xq:buffset(u.handle, 1.5, "暂停")
              end
              local jt = 600
              if u:hasdata("隐藏职业-无貌之人") then
                jt = 3000
              end
              ForGroupLuaNew(g, function(xq)
                local txsh
                if xq:isboss() then
                  u:setdata("全垒打固伤", 0.05)
                  txsh = 100000 + 0.01 * xq:getmaxhp() + 0.04 * xq:gethp()
                  if xq:getperhp() <= 5 then
                    txsh = txsh * 3
                  end
                  ac.wait(100, function()
                    if u:hasdata("隐藏职业-无貌之人") or u:hasdata("变异判定-奈亚子") then
                      PlayGlobalSound(Qld_CQC2)
                      local cs = 0
                      ac.loop(20, function(tiemr)
                        cs = cs + 1
                        DamageUnit({
                          bj = "宇宙CQC(附伤)",
                          unit = xq.handle,
                          source = u.handle,
                          damage = txsh,
                          level = 5,
                          type = "物理",
                          isvest = true,
                          isattack = true,
                          isnoarmor = false,
                          element = "心灵"
                        })
                        if cs == 10 then
                          flashphoto({
                            photo = "war3mapImported\\Ph_Nyz_01.tga",
                            timeout = 1,
                            timehold = 3,
                            timein = 5
                          })
                          u:chat("|cFF666666「|r|cFF999999オ|r|cFF333333ラ|r|cFF999999オ|r|cFF333333ラ！|r|cFF666666」|r", 0.2)
                          u:chat("|cFF666666「|r|cFF999999别|r|cFF333333以|r|cFF999999为|r|cFF333333我|r|cFF999999就|r|cFF333333会|r|cFF999999这|r|cFF333333么|r|cFF999999算|r|cFF333333了|r|cFF666666」|r", 1.8)
                          u:chat("|cFF666666「|r|cFF333333有|r|cFF402D2D所|r|cFF4C2626觉|r|cFF592020悟|r|cFF661A1A了|r|cFF731313么|r|cFF800D0D！|r|cFF666666」|r", 4.9)
                          ac.wait(6000, function()
                            local str1 = "|cFFCC0000「就|r|cFFCA0606凭|r|cFFC80D0D你|r|cFFC61313那|r|cFFC41A1A点|r|cFFC12020自|r|cFFBF2626以|r|cFFBD2D2D为|r|cFFBB3333是|r|cFFB93939的|r|cFFB74040三|r"
                            local str2 = "|cFFB54646脚|r|cFFB24C4C猫|r|cFFB05353的|r|cFFAE5959功|r|cFFAC6060夫|r|cFFAA6666可|r|cFFA86C6C是|r|cFFA67373赢|r|cFFA47979不|r|cFFA28080了|r|cFF9F8686我|r|cFF9D8C8C的」|r"
                            local str = str1 .. str2
                            u:chat(str)
                          end)
                          tiemr:remove()
                        end
                      end)
                    elseif not xq:isalive() then
                      PlayGlobalSound(Qld_CQC2)
                      u:chat("欧拉欧拉", 0.2)
                      u:chat("别以为我就会这么算了", 1.8)
                      u:chat("有所觉悟了么", 5.2)
                      u:chat("就凭你那点自以为是的三脚猫的功夫可是赢不了我的", 6)
                      u:buffset(u.handle, 10, "无敌")
                    end
                  end)
                else
                  if xq:iselite() then
                    txsh = 10 * (25000 + 0.01 * xq:getmaxhp() + 0.04 * xq:gethp())
                  else
                    txsh = 500000
                  end
                  if xq:hasdata("隐藏职业-无貌之人") then
                    xq:kill(u.handle, true)
                  end
                end
                DamageUnit({
                  bj = "全垒打(附伤)",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 5,
                  type = "物理",
                  isvest = true,
                  isattack = true,
                  isnoarmor = false,
                  element = "心灵"
                })
                u:deldata("全垒打固伤")
                xq:animeact("death")
                xq:effectadd("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", "chest")
                unitjump({
                  unit = xq.handle,
                  time = 1,
                  distance = jt,
                  height = 400,
                  angle = AngleBetweenUnits(u.handle, xq.handle),
                  isfly = true
                })
              end)
            end)
          end
          if wq == Weapons["棒球棍"] then
            u:buffset(u.handle, 1.5, "暂停")
            u:buffset(u.handle, 3, "无敌")
            u:buffset(u.handle, 1.5, "绝对闪避")
            u:playsound(Gaoyelian)
            do
              local g = CreateGroupLua()
              for _, xq in ac.selector():in_rangexy(x2, y2, 250):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g)
                xq:buffset(u.handle, 2.5, "暂停")
              end
              ac.wait(1000, function()
                for _, xq in ac.selector():in_rangexy(x2, y2, 1100):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(g)
                  xq:buffset(u.handle, 1.5, "暂停")
                end
                local txsh = 100000 + 15000 * u:getlevel()
                ForGroupLuaNew(g, function(xq)
                  if xq:isboss() then
                    txsh = 100000 + 0.01 * xq:getmaxhp() + 0.04 * xq:gethp()
                    if xq:getperhp() <= 8 then
                      u:setdata("全垒打固伤", 0.08)
                      txsh = txsh * 3
                    end
                    ac.wait(1, function()
                      if not xq:isalive() then
                        PlayBGM({
                          bgm = Gaoyelian_G,
                          time = 30,
                          ID = 4,
                          unit = u.handle
                        })
                        u:buffset(u.handle, 30, "无敌")
                      end
                    end)
                  elseif xq:iselite() then
                    txsh = 10 * (25000 + 0.01 * xq:getmaxhp() + 0.04 * xq:gethp())
                  else
                    txsh = 500000
                  end
                  DamageUnit({
                    bj = "全垒打(附伤)",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 5,
                    type = "物理",
                    isvest = true,
                    isattack = true,
                    isnoarmor = false,
                    element = "物理"
                  })
                  u:deldata("全垒打固伤")
                  xq:animeact("death")
                  xq:effectadd("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", "chest")
                  unitjump({
                    unit = xq.handle,
                    time = 1,
                    distance = GetRandomReal(2400, 4800),
                    height = 1000,
                    angle = AngleBetweenUnits(u.handle, xq.handle),
                    isfly = true
                  })
                end)
              end)
            end
          end
        end
      end
      
      u:addtrgevent("单位-发动技能", function(args)
        skill(args)
      end)
    end,
    effectname = "|cFF33FF33全垒打|r",
    effecttext = "|cFF33FF33唯一\n【阶级】1\n【效果】\n一起来打棒球吧！|r\n|cFF96FD96获取时获得[棒球棍]\n强化[棒球棍]:\n[提升100%基础伤害\n冷却时间减半\n击飞概率提升至25%]\n提升50%棍伤害\n获得技能[全垒打]|r\n|cFF33FF33再见本垒打|r\n|cFF96FD96[数据删除]|r",
    effectart = "war3mapImported\\BTNEwl_Quanleida.blp"
  },
  {
    name = "剑魔",
    weight = 100,
    lv = 1,
    key = {},
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
      u:setdata("剑魔-提升剑伤害", 0.05 * u:getlevel())
      if not u:ishasskill("A1AM") then
        ac.loop(1000, function()
          if u:isalive() then
            local b = false
            local x, y = u:getxy()
            for _, xq in ac.selector():in_rangexy(x, y, 275):is_enemy(u.handle):ipairs() do
              b = true
              break
            end
            if u:getluckrandom(20) and not u:ishasskill("A0CG") and b == true then
              u:useweapon()
            end
          end
        end)
      end
    end,
    effectname = "|cFFCC0099剑魔|r",
    effecttext = "|cFFCC33FF【阶级】1\n【效果】\n获取时提升[5%*等级]剑伤害\n275范围内存在敌人时可能会无视武器冷却自动使用近战武器(触发冷却1秒)|r\n|cFF949596为何一心向魔？只因无可奈何。|r",
    effectart = "war3mapImported\\BTNEwl_Gecaokuagnmo.blp"
  },
  {
    name = "二刀流",
    weight = 100,
    lv = 1,
    key = {},
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
    end,
    effectname = "|cFF33FF33二刀流|r",
    effecttext = "|cFF33FF33【阶级】1\n【效果】\n装备武器并切换时切换冷却时间变更为[卸下武器的使用冷却*50%]\n切换武器后对周围450范围单位造成[2500+等级*500]物理近战伤害|r\n|cFF949596仅仅因为双刀看起来更帅所以使用双刀流|r",
    effectart = "war3mapImported\\BTNEwl_Erdaoliu.blp"
  },
  {
    name = "闻鸡起舞",
    weight = 100,
    lv = 1,
    key = {},
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
      u:sendmessage("|cFF1BE6B8你变得喜欢早起|r", 3)
      local b = false
      ac.loop(3000, function()
        if u:isalive() then
          if GetTimeOfDay() >= 6 and GetTimeOfDay() <= 9 then
            if b == false then
              b = true
              u:addskill("S009")
              u:setdata("闻鸡起舞-药水成功率提升")
              u:changedata("幸运", 5)
            end
          elseif b == true then
            b = false
            u:delskill("S009")
            u:clearbuff("B00K")
            u:deldata("闻鸡起舞-药水成功率提升")
            u:changedata("幸运", -5)
          end
        end
      end)
    end,
    effectname = "|cFF33FF33闻鸡起舞|r",
    effecttext = "|cFF33FF33【阶级】1\n【效果】\n在6:00~9:00期间\n提升5幸运\n提升20%药水成功率\n提升50%暴击率\n增加25%移动速度|r\n|cFF949596天刚破晓，你呢？鸡呢？剑呢？闻鸡起舞了吗？|r",
    effectart = "ReplaceableTextures\\CommandButtons\\BTNCritterChicken.blp"
  },
  {
    name = "夜猫子",
    weight = 100,
    lv = 1,
    key = {},
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
      u:sendmessage("|cFF1BE6B8你变得喜欢熬夜|r", 3)
      local b2 = false
      ac.loop(1000, function()
        if u:isalive() then
          if GetTimeOfDay() >= 0 and GetTimeOfDay() <= 3 then
            if b2 == false then
              b2 = true
              u:addskill("S00A")
              u:setdata("夜猫子-药水成功率提升")
              u:changedata("幸运", 5)
            end
          elseif b2 == true then
            b2 = false
            u:delskill("S00A")
            u:clearbuff("B00J")
            u:deldata("夜猫子-药水成功率提升")
            u:changedata("幸运", -5)
          end
        end
      end)
    end,
    effectname = "|cFF33FF33夜猫子|r",
    effecttext = "|cFF33FF33【阶级】1\n【效果】\n在0:00~3:00期间\n提升5幸运\n提升20%药水成功率\n提升50%暴击率\n增加25%移动速度|r\n|cFF949596夜晚属于夜猫子与孤寂的灵魂。|r",
    effectart = "war3mapImported\\BTNEwl_Yemaozi.blp"
  },
  {
    name = "问卜人",
    weight = 25,
    lv = 1,
    key = {},
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
      u:sendmessage("|cFFBF7167「|r|cFFBA6A61官|r|cFFB6625B人|r|cFFB15B55是|r|cFFAD544F否|r|cFFA84D49求|r|cFFA34544一|r|cFF9F3E3E签|r|cFF9A3738」|r")
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:getdata("问卜人-最终伤害加成") > 0 then
          info.endup = info.endup + u:getdata("问卜人-最终伤害加成")
        else
          info.enddown = info.enddown * (1 + u:getdata("问卜人-最终伤害加成"))
        end
      end)
      local zu = {
        {
          name = "大吉",
          add = 0.3,
          text = "提升3%终结伤害"
        },
        {
          name = "吉",
          add = 0.2,
          text = "提升2%终结伤害"
        },
        {
          name = "小吉",
          add = 0.1,
          text = "提升1%终结伤害"
        },
        {
          name = "平",
          add = 0,
          text = "无效果"
        },
        {
          name = "小凶",
          add = -0.1,
          text = "降低1%终结伤害"
        },
        {
          name = "凶",
          add = -0.2,
          text = "降低2%终结伤害"
        },
        {
          name = "大凶",
          add = -0.3,
          text = "降低3%终结伤害"
        }
      }
      u:setdata("问卜人-最终伤害加成", 0)
      u:setdata("问卜人-下一次求签时间", 3)
      ac.loop(1000, function()
        u:changedata("问卜人-下一次求签时间", -1)
        if u:getdata("问卜人-下一次求签时间") <= 0 then
          u:setdata("问卜人-下一次求签时间", 240)
          local xh = GetRandomInt(1, #zu)
          local jg = zu[xh]
          if u:hasdata("变异判定-超高校级的幸运") and 5 <= xh then
            local xg = 0
            local text = ""
            if xh == 5 then
              xh = 3
              xg = 0.1
              text = "|cFFA84C4A问卜人-【小凶】|r"
            end
            if xh == 6 then
              xh = 2
              xg = 0.2
              text = "|cFFA84C4A问卜人-【凶】|r"
            end
            if xh == 7 then
              xh = 1
              xg = 0.3
              text = "|cFFA84C4A问卜人-【大凶】|r"
            end
            local g = CreateGroupLua()
            ForGroupLuaNew(Group_PlayHero, function(xq)
              if xq.handle ~= u.handle then
                xq:groupadd(g)
              end
            end)
            if 0 < Group_Counts(g) then
              local mb = Group_Randomunit(Group_PlayHero)
              local sy2 = mb.ownerid
              mb:sendmessage(text)
              ChangeTimeValue(DamageSystem_EndShDown, sy2, 1 - xg, 240, 1)
            elseif not u:hasdata("超高校级的幸运-问卜人怪物减伤") then
              u:settimedata("超高校级的幸运-问卜人怪物减伤", 240, xg)
            end
          end
          jg = zu[xh]
          u:sendmessage("|cFFBF7167「|r|cFFBC6C63官|r|cFFB8675F人|r|cFFB5615A你|r|cFFB25C56的|r|cFFAF5752求|r|cFFAB524E签|r|cFFA84D4A结|r|cFFA54745果|r|cFFA14241是|r|cFF9E3D3D【" .. jg.name .. "】|r|cFF983234」|r")
          u:setdata("问卜人-最终伤害加成", jg.add)
          local effecttext = "|cFFA84C4A当前效果:【" .. jg.name .. "】" .. jg.text .. "获取时抽取一枚御神签\n可以立刻重新抽取一枚御神签,冷却360秒\n每240秒抽取一枚御神签,随机获得以下一种效果直至下一次抽签:|r\n|cFFBF7167①提升3%终结伤害 大吉\n②提升2%终结伤害 吉\n③提升1%终结伤害 小吉\n④无效果 平\n⑤降低1%终结伤害 小凶\n⑥降低2%终结伤害 凶\n⑦降低3%终结伤害 大凶|r"
          u:uivar_change({
            keyname = "问卜人",
            keytype = "冥王栏",
            text = effecttext
          })
        end
      end)
      AddUISkill({
        text = var.name,
        u = u,
        cd = 360,
        icon = "Ewl_Wenburen.tga",
        func = function(args)
          local u = args.u
          local sy = u.owneri
          u:setdata("问卜人-下一次求签时间", 1)
        end
      })
    end,
    effectname = "|cFFBF7167问|r|cFFB45F58卜|r|cFFA84C4A人|r",
    effecttext = "|cFFA84C4A【阶级】1\n【效果】\n当前效果:【平】无效果\n获取时抽取一枚御神签\n可以立刻重新抽取一枚御神签,冷却360秒\n每240秒抽取一枚御神签,随机获得以下一种效果直至下一次抽签:|r\n|cFFBF7167①提升3%终结伤害 大吉\n②提升2%终结伤害 吉\n③提升1%终结伤害 小吉\n④无效果 平\n⑤降低1%终结伤害 小凶\n⑥降低2%终结伤害 凶\n⑦降低3%终结伤害 大凶|r",
    effectart = "Ewl_Wenburen.tga"
  }
}
Vars_Mwx_Tianxiahui_Lv2 = {
  {
    name = "龙剑",
    weight = 100,
    lv = 2,
    key = {"龙", "唯一"},
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
      MwxTongyong(u, var)
      u:sendmessage("|cFFE35444帝有命起伏司龙，龙尾不卷曳天东|r")
      u:changedata("龙血浓度", 20)
      local cs = 0
      local bs = 0
      local qsx = 0
      local z = 0
      local katana = 0
      ac.loop(3000, function()
        if not u:hasdata("龙剑-居合强化") then
          cs = cs + 1
          if 2 <= cs then
            cs = 0
            u:setdata("龙剑-居合强化")
          end
        end
        ChangeValue(DamageSystem_Baoshang, sy, -1 * bs)
        bs = 0.01 * u:getstate("龙变异")
        ChangeValue(DamageSystem_Baoshang, sy, 1 * bs)
        if z ~= u:getdata("龙变异数量") then
          u:addallstats(-1 * qsx)
          qsx = math.floor(5 * z)
          u:addallstats(qsx)
        end
      end)
    end,
    effectname = "|cFFE05043龙剑|r",
    effecttext = "|cFFE05043龙 唯一\n【阶级】2\n【效果】\n龙剑法|r\n|cFFF7D87B减少50%武士刀切换间隔|r\n|cFFE05043居合|r\n|cFFF7D87B每6秒下次武士刀挥刀伤害提升100%并附带一次等额龙属性伤害|r\n|cFFE05043龙血之力|r\n|cFFF7D87B提升[龙变异数量*5]全属性\n提升[龙变异*1%]暴击伤害|r",
    effectart = "war3mapImported\\BTNEwl_Mwx_Longjian.tga"
  },
  {
    name = "苦行僧客",
    weight = 100,
    lv = 2,
    key = {"影", "唯一"},
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
      MwxTongyong(u, var)
      u:chat("无所住，而生其心，即为禅")
      u:addstexiao(var.name, "伤害系统计算效果", function(args)
        local info = args.damageinfo
        if info.face == "正面" then
          info.jc = info.jc + 0.5
        end
      end)
      u:addstexiao(var.name, "暴击系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if info.face == "背面" then
          info.bjl = info.bjl + 50
        end
      end)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:ishasskill("A1MD") then
          info.end1 = info.end1 + 0.07
        end
      end)
      u:addtrgevent("单位-指定点目标指令", function(args)
        if args.orderid == String2OrderIdBJ("smart") and u:hasdata("苦行僧客-刀影") then
          u:deldata("苦行僧客-刀影")
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          local mjl = 800
          if dis >= mjl then
            dis = mjl
          end
          u:setdata("苦行僧客-刀影释放中")
          local v = 0
          unitmove({
            unit = u.handle,
            time = dis / 1400,
            distance = dis,
            angle = angle,
            loops = {
              {
                looptime = 0.03,
                func = function(dx, dy)
                  v = v + 40
                  if 200 <= v then
                    v = 0
                    u:useweapon()
                  end
                  Effectcreate("ATX\\[ATxNew]Black_01.mdl", dx, dy)
                end
              }
            },
            endfunc = function(dx, dy)
              GroupClearLua(Group_Daoying)
              u:deldata("苦行僧客-刀影释放中")
              u:setdata("位移点X", dx)
              u:setdata("位移点Y", dy)
            end
          })
        end
      end)
      local jz = 0
      local ys = 0
      local tl = 0
      ac.loop(100, function()
        ChangeValue(Hero_Tili_Huifu, sy, -1 * tl)
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -1 * ys)
        if IsTimeNight() then
          if u:getdata("战斗时间") > 0 then
            ys = 0
            jz = 0
            tl = 0.25
            u:delskill("S08N")
          else
            ys = 100
            jz = 0
            tl = 0
            u:addskill("S08N")
          end
        else
          ys = 0
          tl = 0
          jz = 0
          u:delskill("S08N")
        end
        ChangeValue(Hero_Tili_Huifu, sy, 1 * tl)
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 1 * ys)
      end)
    end,
    effectname = "|cFF71645E苦行僧客|r",
    effecttext = "|cFF71645E影 唯一\n【阶级】2\n【效果】\n夜月|r\n|cFF816638夜晚脱战时,极速并提升100额外移速\n夜晚战斗时,提升0.25体力恢复|r\n|cFF71645E刀影|r\n|cFF816638使用武士刀,剑,刀后0.5秒内点击地面将会向目标点冲刺\n冲刺视为命中沿途单位,最大距离800,不会重复命中|r\n|cFF71645E义|r\n|cFF816638伤害单位正面时提升5%伤害加成\n伤害单位背面时提升50%暴击率|r\n|cFF71645E佛孽|r\n|cFF816638对宗教相关敌人提升7%伤害|r\n|cFF949596见佛杀佛，见魔杀魔，杀尽天下神佛|r",
    effectart = "war3mapImported\\BTNEwl_Mwx_50.tga"
  },
  {
    name = "地底居民",
    weight = 100,
    lv = 2,
    key = {"唯一"},
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
      MwxTongyong(u, var)
      u:sendmessage("|cFFFF3300我用双手成就你的梦想|r", 3)
      if u:ishasskill("A1AM") and u.type ~= HeroType["C呆"] then
        u:addskill("A1A0")
        u:banskill("A1A0")
      else
        u:addskill("A19Z")
        u:banskill("A19Z")
      end
      u:addstexiao(var.name, "位移技能后效果", function(args)
        local u = args.u
        local sy = u.ownerid
        ChangeTimeValue(Correction_Jzsh, sy, 0.020000000000000004, 3)
      end)
      local hbskill = {
        S2ID("A00E"),
        S2ID("A08M"),
        S2ID("A0ET"),
        S2ID("A1DZ")
      }
      
      local function skill(args)
        if TableContains(hbskill, args.skill) then
          local t = 1
          for index, value in ipairs(hbskill) do
            u:banskill(value)
          end
          u:banskill("A19Z", false)
          u:banskill("A1A0", false)
          ac.wait(t * 1000, function()
            u:banskill("A19Z")
            u:banskill("A1A0")
            for index, value in ipairs(hbskill) do
              u:banskill(value, false)
            end
          end)
        end
        if args.skill == S2ID("A19Z") or args.skill == S2ID("A1A0") then
          local skill = args.skill
          local tilixh = 1
          if u:lossstamina(tilixh) then
          else
            u:setskillcd(skill, 0.01)
            u:sendmessage("|cFFFF3300体力值不足|r")
            return
          end
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local x3, y3, tg
          local g = GetUnitsOfTypeIdAllLua("o000")
          local g2 = GetUnitsOfTypeIdAllLua("o003")
          local g3 = GetUnitsOfTypeIdAllLua("o006")
          ForGroupLuaNew(g, function(xq)
            x3, y3 = xq:getxy()
            local dis = DistanceXY(x2, y2, x3, y3)
            if dis <= 90 then
              tg = xq
            end
          end)
          if not tg then
            ForGroupLuaNew(g2, function(xq)
              x3, y3 = xq:getxy()
              local dis = DistanceXY(x2, y2, x3, y3)
              if dis <= 90 then
                tg = xq
              end
            end)
          end
          if not tg then
            ForGroupLuaNew(g3, function(xq)
              x3, y3 = xq:getxy()
              local dis = DistanceXY(x2, y2, x3, y3)
              if dis <= 90 then
                tg = xq
              end
            end)
          end
          if tg then
            x3, y3 = tg:getxy()
            do
              local dis = DistanceXY(x, y, x3, y3)
              local angle = AngleXY(x, y, x3, y3)
              u:buffset(u.handle, 0.2, "绝对闪避")
              ChangeTimeValue(Correction_Jzsh, sy, 0.020000000000000004, 6)
              unitmove({
                unit = u.handle,
                time = 0.2,
                distance = dis,
                angle = angle,
                isfly = true,
                {
                  looptime = 0.04,
                  func = function(dx, dy)
                    Effectcreate("Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl", dx, dy, 1)
                  end
                }
              })
            end
          end
        end
      end
      
      u:addtrgevent("单位-发动技能", function(args)
        skill(args)
      end)
    end,
    effectname = "|cFFCC3300地底居民|r",
    effecttext = "|cFFFFCC99唯一\n【阶级】2\n【效果】\n疾风骤雨|r\n|cFFCC3300发动[金钟罩]或位移技能后在3秒内提升2%近战伤害,如果是[金钟罩]则持续时间翻倍|r\n|cFFFFCC99金钟罩|r\n|cFFCC3300使用火把技能后1秒内技能会变为[金钟罩]|r\n|cFF949596双眼失明丝毫不影响我追捕敌人，因为我能闻到他们身上的臭味|r",
    effectart = "war3mapImported\\btnewl_didijumin.blp"
  },
  {
    name = "黄金剑客",
    weight = 100,
    lv = 2,
    key = {"唯一"},
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
      MwxTongyong(u, var)
      u:sendmessage("|cFFFFFF33你感觉自己开始变得沉默寡言|r", 3)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:ispozhao() then
          info.end4 = info.end4 + 0.07
        end
      end)
      u:addstexiao(var.name, "暴击系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:ispozhao() then
          info.bjl = info.bjl + 25
        end
      end)
      local jc = 0
      local bjl = 0
      local dyjc = 0
      local dybjl = 0
      ac.loop(1000, function()
        ForGroupLuaNew(Group_PlayHero, function(xq)
          local sy2 = xq.ownerid
          if xq.handle ~= u.handle then
            ChangeValue(DamageSystem_Shjc, sy2, 0.1 * (-1 * dyjc))
            ChangeValue(DamageSystem_Baoji, sy2, -1 * dybjl)
          end
        end)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * jc))
        ChangeValue(DamageSystem_Baoji, sy, -1 * bjl)
        if u:isalive() then
          dyjc = 0
          dybjl = 0
          if Time_PlayerNotChatTime[sy] <= 10 then
            jc = 0.25
            bjl = 10
          else
            jc = 0
            bjl = 0
          end
        else
          jc = 0
          bjl = 0
          if Time_PlayerNotChatTime[sy] <= 10 then
            dyjc = -0.5
            dybjl = -25
          else
            dyjc = 0
            dybjl = 0
          end
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * jc))
        ChangeValue(DamageSystem_Baoji, sy, 1 * bjl)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          local sy2 = xq.ownerid
          if xq.handle ~= u.handle then
            ChangeValue(DamageSystem_Shjc, sy2, 0.1 * (1 * dyjc))
            ChangeValue(DamageSystem_Baoji, sy2, 1 * dybjl)
          end
        end)
      end)
    end,
    effectname = "|cFFFFFF33黄金剑客|r",
    effecttext = "|cFFFFFF33唯一\n【阶级】2\n【效果】\n机会主义者|r\n|cFFFFCC66提升7%破招伤害\n对破招中单位提升25%暴击率|r\n|cFFFFFF33话痨|r\n|cFFFFCC66提升2.5%伤害加成与10%暴击率,10秒内未说话或聊天时该效果失效\n自身死亡时,降低其他队友5%伤害加成与25%暴击率,10秒内说过话或聊天过该效果生效|r\n|cFF949596为什么不回我？是不是隐身了？哎，你们怎么都喜欢玩隐身？|r",
    effectart = "war3mapImported\\btnewl_jihuizhuyizhe.blp"
  },
  {
    name = "拔刀斋",
    weight = 100,
    lv = 2,
    key = {
      "唯一",
      "影",
      "战士"
    },
    unique = true,
    seckey = keystring,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      b = Chengzaishangxianpanding(u, 2, b)
      if u:getdata("角色基础伤害") > 0 then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      u:chat("在下一直认真行事，更不允许你行差踏错。")
      u:playsound(Sound_Jianxin_01)
      local g = CreateGroupLua()
      u:addtrgevent("单位-指定点目标指令", function(args)
        if args.orderid == String2OrderIdBJ("smart") and u:hasdata("绯村剑心-双龙闪") and not u:hasdata("绯村剑心-双龙闪冷却") and u:lossstamina(0.75) then
          u:deldata("绯村剑心-双龙闪")
          u:settimedata("绯村剑心-双龙闪冷却", 0.5)
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          if 900 <= dis then
            dis = 900
          end
          u:playsound(Sound_Katana_15)
          Effectcreate("war3mapImported\\blackblink.mdl", x, y)
          unitmove({
            unit = u.handle,
            time = 0.1,
            distance = dis,
            angle = angle,
            endfunc = function(dx, dy)
              GroupClearLua(g)
              Effectcreate("war3mapImported\\blackblink.mdl", dx, dy)
              u:useweapon()
            end,
            isblink = true
          })
        end
      end)
    end,
    effectname = "|cFFFF9933拔刀斋|r",
    effecttext = "|cFFFF9933战士 影 唯一\n【阶级】2\n【效果】\n双龙闪|r\n|cFFFF9966消耗体力 0.75\n使用武士刀系武器后0.5秒内点击地面向目标点冲刺并在落点处发动一次近战攻击\n最大距离900\n触发冷却0.5秒|r\n|cFFFF9933飞天御剑流|r\n|cFFFF9966使用武士刀系武器后在0.75秒内免疫僵直并在3秒内提升75额外移速,可叠加,分立计时|r",
    effectart = "war3mapImported\\BTNEwl_Feicunjianxin_Chuanqi.blp"
  },
  {
    name = "蛇百心流",
    weight = 10,
    lv = 2,
    key = {
      "蛇",
      "白毛",
      "唯一"
    },
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
      MwxTongyong(u, var)
      u:sendmessage("|cFFE9BFCB你的头发变长了，同时仿佛拥有了生命|r")
      ChangeValue(WeaponCountFw_Katana, sy, 0.05)
      ChangeValue(Correction_Jzsh, sy, 0.005000000000000001)
      ChangeValue(DamageSystem_Baoshang, sy, 0.05)
      ChangeValue(WeaponCount_Katana, sy, 0.05)
      u:addskill("A1P2")
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local tg = args.tg
        if not tg:hasdata(var.name .. "-抑制恢复") then
          tg:settimedata(var.name .. "-抑制恢复", 3)
          tg:groupadd(HpGroup)
        end
      end)
    end,
    effectname = "|cFFFFFFFF蛇百心流|r",
    effecttext = "|cFFFFFFFF蛇 唯一\n【阶级】2\n【效果】\n蛇御斩|r\n|cFFE9BFCB提升0.5%近战伤害\n提升5%暴击伤害\n装备武士刀时挥刀44%附带[等级*500]物理伤害\n近战伤害抑制目标恢复3秒\n死亡时装备的武士刀不会掉落|r\n|cFFFFFFFF百蛇发|r\n|cFFE9BFCB提升5%武士刀范围\n提升5%武士刀伤害\n装备武士刀时,挥刀时将会在鼠标点同时发动一次武士刀攻击,最大距离800,不会重复命中|r",
    effectart = "war3mapImported\\BTNEwl_Mwx_51.tga"
  }
}
Vars_Mwx_Tianxiahui_Lv3 = {}
