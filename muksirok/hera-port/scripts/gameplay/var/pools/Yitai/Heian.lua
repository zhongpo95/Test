-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local function HeianDamage(u, tg, damage, damage_type, bj)
  DamageUnit({
    bj = bj,
    
    unit = tg.handle,
    source = u.handle,
    damage = damage,
    level = 1,
    type = damage_type,
    isvest = true,
    isattack = false,
    isnoarmor = false,
    element = "暗"
  })
end

local function IsDarkDirectDamage(info)
  return info.element == "暗" and not info.isvestdamage
end

Vars_Yitai_Lv1["黑暗"] = {
  {
    name = "活体肌肤",
    weight = 100,
    lv = 1,
    key = {"黑暗"},
    unique = false,
    addweight = function(u, var)
      return YitaiWeight(u, var)
    end,
    condition = function(u, var)
      return YitaiCondition(u, var)
    end,
    effect = function(u, var)
      local sy = u.ownerid
      YitaiGetAct(u, {
        name = var.name,
        lv = var.lv,
        key = var.key
      })
      u:changearmor(10)
      u:addstexiao(var.name, "受伤后效果", function(args)
        local u = args.u
        local tg = args.tg
        if not u or not tg or not u:isvalid() or not tg:isvalid() then return end
        if not u:hasdata(var.name .. "-反伤冷却") then
          u:settimedata(var.name .. "-反伤冷却", 1)
          local txsh = 1500 * u:getstate("黑暗变异")
          DamageUnit({
            bj = "活体肌肤(反伤)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = true,
            isnoarmor = false,
            element = "暗"
          })
        end
      end)
    end,
    effectname = "|cFFCC00FF活体肌肤|r",
    effecttext = "|cFFCC00FF一阶\n黑暗\n提升10护甲\n受到大于50伤害时反馈[1000*黑暗变异]暗物理近战伤害(冷却1秒)|r",
    effectart = "war3mapImported\\BTNEwl_Body_B_Huotipifeng.blp"
  },
  {
    name = "黑之壳",
    weight = 100,
    lv = 1,
    key = {"黑暗"},
    unique = false,
    addweight = function(u, var)
      return YitaiWeight(u, var)
    end,
    condition = function(u, var)
      return YitaiCondition(u, var)
    end,
    effect = function(u, var)
      local sy = u.ownerid
      YitaiGetAct(u, {
        name = var.name,
        lv = var.lv,
        key = var.key
      })
      local add = 0
      ac.loop(3000, function()
        ChangeValue(Hudun_Max, sy, -add)
        add = 200 * u:getstate("黑暗变异")
        ChangeValue(Hudun_Max, sy, add)
      end)
    end,
    effectname = "|cFF666666黑之壳|r",
    effecttext = "|cFF666666一阶\n黑暗\n提升[200*黑暗变异]护盾上限|r",
    effectart = "BTNYitai_Heian_03"
  },
  {
    name = "静默环",
    weight = 100,
    lv = 1,
    key = {"黑暗"},
    unique = false,
    addweight = function(u, var)
      return YitaiWeight(u, var)
    end,
    condition = function(u, var)
      return YitaiCondition(u, var)
    end,
    effect = function(u, var)
      local sy = u.ownerid
      YitaiGetAct(u, {
        name = var.name,
        lv = var.lv,
        key = var.key
      })
      u:addskill("S0AU")
      AddAllSTexiao(var.name, "伤害系统计算效果", function(args)
        local info = args.damageinfo
        if args.tg:ishasbuff("B0EX") then
          info.ewss = info.ewss + 0.05
        end
      end)
    end,
    effectname = "|cFF6633CC静默环|r",
    effecttext = "|cFF6633CC一阶\n黑暗\n周围450范围单位降低10%移速,提升5%额外受伤|r",
    effectart = "Yitai_Heian_01"
  },
  {
    name = "黑之躯",
    weight = 100,
    lv = 1,
    key = {"黑暗"},
    unique = false,
    addweight = function(u, var)
      return YitaiWeight(u, var)
    end,
    condition = function(u, var)
      return YitaiCondition(u, var)
    end,
    effect = function(u, var)
      local sy = u.ownerid
      YitaiGetAct(u, {
        name = var.name,
        lv = var.lv,
        key = var.key
      })
      u:addhealthrefresh(function(set_value, bs)
        set_value(DamageSystem_Shjc, sy, 0.1 * (0.2 * bs))
      end)
    end,
    effectname = "|cFF666666漆黑之手|r",
    effecttext = "|cFF666666一阶\n黑暗\n提升[2%*背水]伤害加成|r",
    effectart = "BTNYitai_Heian_02"
  },
  {
    name = "暗脉",
    weight = 100,
    lv = 1,
    key = {"黑暗"},
    unique = false,
    addweight = function(u, var)
      return YitaiWeight(u, var)
    end,
    condition = function(u, var)
      return YitaiCondition(u, var)
    end,
    effect = function(u, var)
      local sy = u.ownerid
      YitaiGetAct(u, {
        name = var.name,
        lv = var.lv,
        key = var.key
      })
      ChangeValue(Damage_Element_Dark, sy, 0.05)
      u:changedata("效果增强-背水", 0.1)
    end,
    effectname = "|cFF9966CC暗脉|r",
    effecttext = "|cFF9966CC一阶\n黑暗\n提升5%暗属性伤害\n提升10%背水效果增强|r",
    effectart = "Yitai_Heian_Anmai.tga"
  },
  {
    name = "失光",
    weight = 100,
    lv = 1,
    key = {"黑暗"},
    unique = false,
    addweight = function(u, var)
      return YitaiWeight(u, var)
    end,
    condition = function(u, var)
      return YitaiCondition(u, var)
    end,
    effect = function(u, var)
      local sy = u.ownerid
      YitaiGetAct(u, {
        name = var.name,
        lv = var.lv,
        key = var.key
      })
      u:addhealthrefresh(function(set_value, bs)
        set_value(Damage_Element_Dark, sy, 0.2 * bs)
      end)
    end,
    effectname = "|cFF9966CC失光|r",
    effecttext = "|cFF9966CC一阶\n黑暗\n提升[背水*20%]暗属性伤害|r",
    effectart = "Yitai_Heian_Shiguang.tga"
  },
  {
    name = "黑痕",
    weight = 100,
    lv = 1,
    key = {"黑暗"},
    unique = false,
    addweight = function(u, var)
      return YitaiWeight(u, var)
    end,
    condition = function(u, var)
      return YitaiCondition(u, var)
    end,
    effect = function(u, var)
      local sy = u.ownerid
      YitaiGetAct(u, {
        name = var.name,
        lv = var.lv,
        key = var.key
      })
      local mark = "黑痕-" .. sy
      u:addstexiao(var.name, "直接伤害特效", function(args)
        if args.u.handle == u.handle and IsDarkDirectDamage(args.damageinfo) then
          args.tg:settimedata(mark, 5)
        end
      end)
      u:addstexiao(var.name, "伤害系统计算效果", function(args)
        local info = args.damageinfo
        if args.u.handle == u.handle and info.element == "暗" and args.tg:hasdata(mark) then
          info.ewss = info.ewss + 0.15
        end
      end)
    end,
    effectname = "|cFF9966CC黑痕|r",
    effecttext = "|cFF9966CC一阶\n黑暗\n暗属性直接伤害为目标留下黑痕,持续5秒\n对黑痕目标造成的暗属性伤害提升15%额外受伤|r",
    effectart = "Yitai_Heian_Heihen.tga"
  },
  {
    name = "痛觉回流",
    weight = 100,
    lv = 1,
    key = {"黑暗"},
    unique = false,
    addweight = function(u, var)
      return YitaiWeight(u, var)
    end,
    condition = function(u, var)
      return YitaiCondition(u, var)
    end,
    effect = function(u, var)
      YitaiGetAct(u, {
        name = var.name,
        lv = var.lv,
        key = var.key
      })
      local active = false
      local serial = 0
      u:addstexiao(var.name, "受伤后效果", function(args)
        local info = args.damageinfo
        if args.u.handle == u.handle and not info.isvestdamage and args.damage > 0 and not u:hasdata("痛觉回流-冷却") then
          u:settimedata("痛觉回流-冷却", 3)
          active = true
          serial = serial + 1
          local current = serial
          ac.wait(5000, function()
            if current == serial then
              active = false
            end
          end)
        end
      end)
      u:addstexiao(var.name, "伤害系统计算效果", function(args)
        local info = args.damageinfo
        if args.u.handle == u.handle and active and IsDarkDirectDamage(info) then
          active = false
          info.ewss = info.ewss + 1 * u:getstate("背水")
        end
      end)
    end,
    effectname = "|cFF9966CC痛觉回流|r",
    effecttext = "|cFF9966CC一阶\n黑暗\n受到伤害后,下一次暗属性直接伤害提升[背水*100%]\n效果最多保留5秒,冷却3秒|r",
    effectart = "Yitai_Heian_Tongjuehuiliu.tga"
  },
  {
    name = "暮影爆裂",
    weight = 100,
    lv = 1,
    key = {"黑暗"},
    unique = false,
    addweight = function(u, var)
      return YitaiWeight(u, var)
    end,
    condition = function(u, var)
      return YitaiCondition(u, var)
    end,
    effect = function(u, var)
      YitaiGetAct(u, {
        name = var.name,
        lv = var.lv,
        key = var.key
      })
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local info = args.damageinfo
        if args.u.handle == u.handle and u:getperhp() < 50 and IsDarkDirectDamage(info) and not u:hasdata("暮影爆裂-冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata("暮影爆裂-冷却", 1)
          local x, y = tg:getxy()
          local damage = 4000 * u:getstate("黑暗变异")
          for _, xq in ac.selector():in_rangexy(x, y, 300):is_enemy(u.handle):ipairs() do
            HeianDamage(u, getunit(xq), damage, "魔力", "暮影爆裂附伤")
          end
        end
      end)
    end,
    effectname = "|cFF9966CC暮影爆裂|r",
    effecttext = "|cFF9966CC一阶\n黑暗\n生命值低于50%时,暗属性直接伤害10%对目标周围300范围附带[4000*黑暗变异]暗魔力伤害,冷却1秒|r",
    effectart = "Yitai_Heian_Muyingbaolie.tga"
  }
}
Vars_Yitai_Lv2["黑暗"] = {
  {
    name = "暗黑神召",
    clickfunc = function(u, ewl)
      if not u:hasdata("暗黑神召-特效关闭") then
        u:setdata("暗黑神召-特效关闭")
        u:sendmessage("|cFF6699FF暗黑神召附伤关闭|r")
      else
        u:deldata("暗黑神召-特效关闭")
        u:sendmessage("|cFF6699FF暗黑神召附伤开启|r")
      end
    end,
    weight = 100,
    lv = 2,
    key = {"黑暗"},
    unique = false,
    addweight = function(u, var)
      return YitaiWeight(u, var)
    end,
    condition = function(u, var)
      return YitaiCondition(u, var)
    end,
    effect = function(u, var)
      local sy = u.ownerid
      YitaiGetAct(u, {
        name = var.name,
        lv = var.lv,
        key = var.key
      })
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and not u:hasdata("暗黑神召-特效关闭") and u:getluckrandom(5 * info.txgl) then
          local txsh = 10 * u:getallattri() * u:getstate("黑暗变异") * u:getstate("背水")
          u:losshp(u, 0, 5)
          DamageUnit({
            bj = "暗黑神召(附伤)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "反物质",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "暗"
          })
          u:settimedata(var.name .. "-特效冷却", 1.5)
        end
      end)
    end,
    effectname = "|cFF6666FF暗黑神召|r",
    effecttext = "|cFF6666FF二阶\n黑暗\n直接伤害时5%附带[背水*黑暗变异*10*全属性]暗反物质伤害并损耗自身5%当前生命值,冷却1.5秒(点击切换特效触发开关)|r",
    effectart = "war3mapImported\\BTNEwl_Body_B_Anheishenzhao.blp"
  },
  {
    name = "黑翼",
    weight = 100,
    lv = 2,
    key = {"黑暗"},
    unique = false,
    addweight = function(u, var)
      return YitaiWeight(u, var)
    end,
    condition = function(u, var)
      return YitaiCondition(u, var)
    end,
    effect = function(u, var)
      local sy = u.ownerid
      YitaiGetAct(u, {
        name = var.name,
        lv = var.lv,
        key = var.key
      })
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
      u:changedata("系统-飞行强度", 25)
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and not u:hasdata("黑翼-决死冷却") then
          args.dt = false
          u:settimedata("黑翼-决死冷却", 360)
          u:sendmessage("|cFF9966CC决死效果-黑翼|r")
          hdzlinshiadd(u, 100 * u:getstate("黑暗变异"))
        end
      end)
    end,
    effectname = "|cFF9966CC黑翼|r",
    effecttext = "|cFF9966CC二阶\n黑暗\n提升25飞行强度\n提升25额外移速\n受到致死伤害时,抵挡该次伤害并立刻获得[100*黑暗变异]临时护盾值,触发冷却360秒|r",
    effectart = "Yitai_Heian_2_02"
  },
  {
    name = "魔幻之音",
    weight = 100,
    lv = 2,
    key = {"黑暗"},
    unique = false,
    addweight = function(u, var)
      return YitaiWeight(u, var)
    end,
    condition = function(u, var)
      return YitaiCondition(u, var)
    end,
    effect = function(u, var)
      local sy = u.ownerid
      YitaiGetAct(u, {
        name = var.name,
        lv = var.lv,
        key = var.key
      })
      ChangeValue(Damage_Element_Dark, sy, 0.1)
      u:addskill("A09D")
      AddAllSTexiao(var.name, "伤害系统计算效果", function(args)
        local info = args.damageinfo
        if args.tg:ishasbuff("B0F1") then
          info.ewss = info.ewss + 0.08
        end
      end)
    end,
    effectname = "|cFF9966CC魔幻之音|r",
    effecttext = "|cFF9966CC二阶\n黑暗\n提升10%暗属性伤害\n周围900范围单位降低10护甲,提升8%额外受伤|r",
    effectart = "Yitai_Heian_2_01"
  },
  {
    name = "深渊心",
    weight = 100,
    lv = 2,
    key = {"黑暗"},
    unique = false,
    addweight = function(u, var)
      return YitaiWeight(u, var)
    end,
    condition = function(u, var)
      return YitaiCondition(u, var)
    end,
    effect = function(u, var)
      local sy = u.ownerid
      YitaiGetAct(u, {
        name = var.name,
        lv = var.lv,
        key = var.key
      })
      u:changedata("效果增强-背水", 0.15)
      u:addhealthrefresh(function(set_value, bs)
        set_value(Damage_Element_Dark, sy, 0.4 * bs)
      end)
    end,
    effectname = "|cFF9966CC深渊心|r",
    effecttext = "|cFF9966CC二阶\n黑暗\n提升15%背水效果增强\n提升[背水*40%]暗属性伤害|r",
    effectart = "Yitai_Heian_Shenyuanxin.tga"
  },
  {
    name = "蚀命血契",
    weight = 100,
    lv = 2,
    key = {"黑暗"},
    unique = false,
    addweight = function(u, var)
      return YitaiWeight(u, var)
    end,
    condition = function(u, var)
      return YitaiCondition(u, var)
    end,
    effect = function(u, var)
      YitaiGetAct(u, {
        name = var.name,
        lv = var.lv,
        key = var.key
      })
      local count = 0
      u:addstexiao(var.name, "伤害系统计算效果", function(args)
        local info = args.damageinfo
        if args.u.handle == u.handle and IsDarkDirectDamage(info) then
          count = count + 1
          if 4 <= count then
            count = 0
            u:losshp(u, 0, 3)
            info.ewss = info.ewss + 0.3
          end
        end
      end)
    end,
    effectname = "|cFF9966CC蚀命血契|r",
    effecttext = "|cFF9966CC二阶\n黑暗\n每4次暗属性直接伤害损耗自身3%当前生命值,并使该次伤害判定时提升目标30%额外受伤|r",
    effectart = "Yitai_Heian_Shimingxuexie.tga"
  },
  {
    name = "暗影反溯",
    weight = 100,
    lv = 2,
    key = {"黑暗"},
    unique = false,
    addweight = function(u, var)
      return YitaiWeight(u, var)
    end,
    condition = function(u, var)
      return YitaiCondition(u, var)
    end,
    effect = function(u, var)
      local sy = u.ownerid
      YitaiGetAct(u, {
        name = var.name,
        lv = var.lv,
        key = var.key
      })
      local stacks = 0
      local total = 0
      local serial = 0
      u:addstexiao(var.name, "受伤后效果", function(args)
        local info = args.damageinfo
        if args.u.handle == u.handle and not info.isvestdamage and args.damage > 0 then
          ac.wait(1, function()
            if not u:isalive() then
              return
            end
            if stacks < 3 then
              local add = 0.05 * u:getstate("背水")
              stacks = stacks + 1
              total = total + add
              ChangeValue(Damage_Element_Dark, sy, add)
            end
            serial = serial + 1
            local current = serial
            ac.wait(6000, function()
              if current == serial then
                ChangeValue(Damage_Element_Dark, sy, -total)
                stacks = 0
                total = 0
              end
            end)
          end)
        end
      end)
    end,
    effectname = "|cFF9966CC暗影反溯|r",
    effecttext = "|cFF9966CC二阶\n黑暗\n受到伤害时提升[背水*15%]暗属性伤害,持续6秒,最多3层\n重复触发刷新持续时间|r",
    effectart = "Yitai_Heian_Anyingfansu.tga"
  },
  {
    name = "终夜回响",
    weight = 100,
    lv = 2,
    key = {"黑暗"},
    unique = false,
    addweight = function(u, var)
      return YitaiWeight(u, var)
    end,
    condition = function(u, var)
      return YitaiCondition(u, var)
    end,
    effect = function(u, var)
      YitaiGetAct(u, {
        name = var.name,
        lv = var.lv,
        key = var.key
      })
      local count = 0
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local info = args.damageinfo
        if args.u.handle == u.handle and IsDarkDirectDamage(info) then
          if u:getperhp() <= 30 then
            count = count + 1
            if 5 <= count then
              count = 0
              local x, y = tg:getxy()
              local damage = 10000 * u:getstate("黑暗变异")
              for _, xq in ac.selector():in_rangexy(x, y, 350):is_enemy(u.handle):ipairs() do
                HeianDamage(u, getunit(xq), damage, "反物质", "终夜回响附伤")
              end
            end
          else
            count = 0
          end
        end
      end)
    end,
    effectname = "|cFF9966CC终夜回响|r",
    effecttext = "|cFF9966CC二阶\n黑暗\n生命值不高于30%时,每5次暗属性直接伤害对目标周围350范围附带[10000*黑暗变异]暗反物质伤害|r",
    effectart = "Yitai_Heian_Zhongyehuixiang.tga"
  },
  {
    name = "深渊凝视",
    weight = 100,
    lv = 2,
    key = {"黑暗"},
    unique = false,
    addweight = function(u, var)
      return YitaiWeight(u, var)
    end,
    condition = function(u, var)
      return YitaiCondition(u, var)
    end,
    effect = function(u, var)
      YitaiGetAct(u, {
        name = var.name,
        lv = var.lv,
        key = var.key
      })
      u:addstexiao(var.name, "伤害系统计算效果", function(args)
        local tg = args.tg
        local info = args.damageinfo
        if args.u.handle == u.handle and info.element == "暗" and tg:getperhp() > u:getperhp() then
          info.ewss = info.ewss + 0.25
        end
      end)
    end,
    effectname = "|cFF9966CC深渊凝视|r",
    effecttext = "|cFF9966CC二阶\n黑暗\n对生命百分比高于自身的目标造成暗属性伤害时提升25%伤害|r",
    effectart = "Yitai_Heian_Shenyuanningshi.tga"
  }
}
Vars_Yitai_Lv3["黑暗"] = {}
