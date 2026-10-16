-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local keystring = "环都市"

local function delishahuoqu(u, var)
  MwxTongyong(u, var)
  if u:hasdata("变异判定-环都市") then
    u:changedata("环都市-病毒点数", 1)
  end
end

Vars_Mwx_Delisha_Lv1 = {
  {
    name = "德丽莎起源上",
    weight = 100,
    lv = 1,
    key = {"德丽莎"},
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
      delishahuoqu(u, var)
      ChangeValue(DamageSystem_EndSh, sy, 0.002)
      local jc = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jc)
        jc = 0.01 * u:getstate("德丽莎变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * jc)
      end)
      if not u:hasdata("德丽莎-迷途修女判定") then
        u:setdata("德丽莎-迷途修女判定")
        ac.loop(3000, function(t)
          if u:hasdata("变异判定-德丽莎起源上") and u:hasdata("变异判定-德丽莎起源中") and u:hasdata("变异判定-德丽莎起源下") then
            u:sendmessage("|cFFC6C0D1解锁效果[德丽莎-迷途修女]|r")
            u:changedata("系统-启动承载上限", 1)
            u:changedata("根源变异数量", 1)
            u:changedata("幸运", 1)
            t:remove()
          end
        end)
      end
    end,
    effectname = "|cFFC6C0D1德丽莎.起源(上)|r",
    effecttext = "|cFFC6C0D1德丽莎\n【阶级】1\n【所属】环都市\n【效果】\n提升0.2%终结伤害\n提升[0.1%*德丽莎变异]伤害加成\n【迷途修女】\n同拥有起源(上)(中)(下)时:\n[提升1幸运\n提升1根源变异数量\n启动承载上限+1]|r",
    effectart = "Ewl_Mwx_Delisha01"
  },
  {
    name = "德丽莎起源中",
    weight = 100,
    lv = 1,
    key = {"德丽莎"},
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
      delishahuoqu(u, var)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.8, 1)
      local jc = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jc)
        jc = 0.01 * u:getstate("德丽莎变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * jc)
      end)
      if not u:hasdata("德丽莎-迷途修女判定") then
        u:setdata("德丽莎-迷途修女判定")
        ac.loop(3000, function(t)
          if u:hasdata("变异判定-德丽莎起源上") and u:hasdata("变异判定-德丽莎起源中") and u:hasdata("变异判定-德丽莎起源下") then
            u:sendmessage("|cFFC6C0D1解锁效果[德丽莎-迷途修女]|r")
            u:changedata("系统-启动承载上限", 1)
            u:changedata("根源变异数量", 1)
            u:changedata("幸运", 1)
            t:remove()
          end
        end)
      end
    end,
    effectname = "|cFFC6C0D1德丽莎.起源(中)|r",
    effecttext = "|cFFC6C0D1德丽莎\n【阶级】1\n【所属】环都市\n【效果】\n提升10%受伤减少\n提升[0.1%*德丽莎变异]伤害加成\n【迷途修女】\n同拥有起源(上)(中)(下)时:\n[提升1幸运\n提升1根源变异数量\n启动承载上限+1]|r",
    effectart = "Ewl_Mwx_Delisha02"
  },
  {
    name = "德丽莎起源下",
    weight = 100,
    lv = 1,
    key = {"德丽莎"},
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
      delishahuoqu(u, var)
      local jc = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Jzsh, sy, 0.1 * -jc)
        jc = 0.01 * u:getstate("德丽莎变异")
        ChangeValue(Correction_Jzsh, sy, 0.1 * jc)
      end)
      if not u:hasdata("德丽莎-迷途修女判定") then
        u:setdata("德丽莎-迷途修女判定")
        ac.loop(3000, function(t)
          if u:hasdata("变异判定-德丽莎起源上") and u:hasdata("变异判定-德丽莎起源中") and u:hasdata("变异判定-德丽莎起源下") then
            u:sendmessage("|cFFC6C0D1解锁效果[德丽莎-迷途修女]|r")
            u:changedata("系统-启动承载上限", 1)
            u:changedata("根源变异数量", 1)
            u:changedata("幸运", 1)
            t:remove()
          end
        end)
      end
    end,
    effectname = "|cFFC6C0D1德丽莎.起源(下)|r",
    effecttext = "|cFFC6C0D1德丽莎\n【阶级】1\n【所属】环都市\n【效果】\n提升[0.1%*德丽莎变异]近战伤害\n【迷途修女】\n同拥有起源(上)(中)(下)时:\n[提升1幸运\n提升1根源变异数量\n启动承载上限+1]|r",
    effectart = "Ewl_Mwx_Delisha03"
  },
  {
    name = "德丽莎魔王",
    weight = 100,
    lv = 1,
    key = {
      "德丽莎",
      "恶魔",
      "黑暗"
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
      delishahuoqu(u, var)
      ChangeValue(DamageSystem_Baoji, sy, 5)
      local jc = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Baoshang, sy, -jc)
        jc = 0.01 * u:getstate("德丽莎变异")
        ChangeValue(DamageSystem_Baoshang, sy, jc)
      end)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not tg:isboss() then
          info.end3 = info.end3 + 0.09
        end
      end)
    end,
    effectname = "|cFFC6C0D1德丽莎·魔王|r",
    effecttext = "|cFFC6C0D1德丽莎 恶魔 黑暗\n【阶级】1\n【所属】环都市\n【效果】\n提升5%暴击率\n提升[1%*德丽莎变异]暴击伤害\n对非BOSS单位提升9%伤害|r",
    effectart = "Ewl_Mwx_Delisha04"
  },
  {
    name = "德丽莎梅雨",
    weight = 100,
    lv = 1,
    key = {"德丽莎", "水"},
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
      delishahuoqu(u, var)
      u:addskill("S0C0")
      local jc = 0
      ac.loop(3000, function()
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -jc)
        jc = 3 * u:getstate("德丽莎变异")
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, jc)
      end)
      local x, y = u:getxy()
      local hp = 0
      ac.loop(1000, function()
        local x2, y2 = u:getxy()
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, -1 * hp)
        if x2 == x and y2 == y then
          hp = 0
        else
          hp = 0.25
        end
        x, y = u:getxy()
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, 1 * hp)
      end)
    end,
    effectname = "|cFFC6C0D1德丽莎·梅雨|r",
    effecttext = "|cFFC6C0D1德丽莎 水\n【阶级】1\n【所属】环都市\n【效果】\n提升25%移速\n提升[3*德丽莎变异]额外移速\n移动状态下提升0.25%生命恢复|r",
    effectart = "Ewl_Mwx_Delisha05"
  },
  {
    name = "德丽莎降生",
    weight = 100,
    lv = 1,
    key = {"德丽莎", "星"},
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
      delishahuoqu(u, var)
      ChangeValue(Correction_Exp, sy, 0.12)
      ChangeValue(Correction_Gold, sy, 0.06)
      u:addstexiao(var.name, "过波时效果", function(args)
        local add = 0.001 * u:getstate("德丽莎变异")
        u:sendmessage("|cFFC6C0D1德丽莎·降生|r")
        ChangeValue(Damage_ElementRes_All, sy, add)
      end)
    end,
    effectname = "|cFFC6C0D1德丽莎·降生|r",
    effecttext = "|cFFC6C0D1德丽莎 星\n【阶级】1\n【所属】环都市\n【效果】\n提升12%经验获取\n提升6%积分获取\n过波时提升[1%*德丽莎变异]全属性伤害|r",
    effectart = "Ewl_Mwx_Delisha06"
  },
  {
    name = "德丽莎庆典",
    weight = 100,
    lv = 1,
    key = {"德丽莎"},
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
      delishahuoqu(u, var)
      ChangeValue(Correction_MEDCgl, sy, 0.05)
      ChangeValue(Revise_FoodHeal, sy, 0.25)
      u:changedata("幸运", 1)
      u:changedata("效果增强-德丽莎", 0.05)
    end,
    effectname = "|cFFC6C0D1德丽莎·庆典|r",
    effecttext = "|cFFC6C0D1德丽莎\n【阶级】1\n【所属】环都市\n【效果】\n提升1点幸运\n提升5%药水成功率\n提升5%德丽莎变异效果\n食物恢复效果提升25%\n食用食物时提升1点全属性|r",
    effectart = "Ewl_Mwx_Delisha07"
  },
  {
    name = "德丽莎暴食",
    weight = 100,
    lv = 1,
    key = {"德丽莎"},
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
      delishahuoqu(u, var)
      ChangeValue(KillReward_MHp, sy, 1)
      ChangeValue(Correction_CureUp, sy, 0.25)
    end,
    effectname = "|cFFC6C0D1德丽莎·暴食|r",
    effecttext = "|cFFC6C0D1德丽莎\n【阶级】1\n【所属】环都市\n【效果】\n杀敌时提升1点生命上限\n提升25%医疗修正\n每次饮用药水或食用食物时提升[1*德丽莎变异]生命上限|r",
    effectart = "Ewl_Mwx_Delisha08"
  },
  {
    name = "德丽莎夏日",
    weight = 100,
    lv = 1,
    key = {
      "德丽莎",
      "水",
      "冰"
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
      delishahuoqu(u, var)
      local jc = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Gun, sy, 0.1 * -jc)
        jc = 0.015 * u:getstate("德丽莎变异")
        ChangeValue(Correction_Gun, sy, 0.1 * jc)
      end)
      ChangeValue(Correction_Gun_Bullet, sy, 0.03)
      if not u:hasdata("德丽莎-清凉夏日判定") then
        u:setdata("德丽莎-清凉夏日判定")
        ac.loop(3000, function(t)
          if u:hasdata("变异判定-德丽莎夏日") and u:hasdata("变异判定-德丽莎沙滩") then
            u:sendmessage("|cFFC6C0D1解锁效果[德丽莎-清凉夏日]|r")
            u:setdata("德丽莎-清凉夏日")
            u:addstexiao("德丽莎-清凉夏日", "伤害判定后特效", function(args)
              local u = args.u
              local tg = args.tg
              local info = args.damageinfo
              if not u:hasdata("清凉夏日-特效冷却") and info.element == "火" and u:getluckrandom(1 * info.txgl) then
                u:curehp(u.handle, 0, 1)
                u:settimedata("清凉夏日-特效冷却", 0.1)
              end
              if not u:hasdata("清凉夏日-特效2冷却") and info.element == "水" and u:getluckrandom(1 * info.txgl) then
                u:curetili(1)
                u:settimedata("清凉夏日-特效2冷却", 0.1)
              end
            end)
            t:remove()
          end
        end)
      end
    end,
    effectname = "|cFFC6C0D1德丽莎·夏日|r",
    effecttext = "|cFFC6C0D1德丽莎 水 冰\n【阶级】1\n【所属】环都市\n【效果】\n提升3%子弹伤害\n提升[0.15%*德丽莎变异]枪械伤害\n【清凉夏日】\n同时持有德丽莎[夏日][沙滩]时:\n[火属性伤害1%恢复1%生命值,触发冷却0.1秒\n水属性伤害1%恢复1点体力值,触发冷却0.1秒]|r",
    effectart = "Ewl_Mwx_Delisha09"
  },
  {
    name = "德丽莎沙滩",
    weight = 100,
    lv = 1,
    key = {"德丽莎", "炎"},
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
      delishahuoqu(u, var)
      local jc = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Gun, sy, 0.1 * -jc)
        jc = 0.015 * u:getstate("德丽莎变异")
        ChangeValue(Correction_Gun, sy, 0.1 * jc)
      end)
      ChangeValue(Correction_Gun_Bullet, sy, 0.03)
      if not u:hasdata("德丽莎-清凉夏日判定") then
        u:setdata("德丽莎-清凉夏日判定")
        ac.loop(3000, function(t)
          if u:hasdata("变异判定-德丽莎夏日") and u:hasdata("变异判定-德丽莎沙滩") then
            u:sendmessage("|cFFC6C0D1解锁效果[德丽莎-清凉夏日]|r")
            u:setdata("德丽莎-清凉夏日")
            u:addstexiao("德丽莎-清凉夏日", "伤害判定后特效", function(args)
              local u = args.u
              local tg = args.tg
              local info = args.damageinfo
              if not u:hasdata("清凉夏日-特效冷却") and info.element == "火" and u:getluckrandom(1 * info.txgl) then
                u:curehp(u.handle, 0, 1)
                u:settimedata("清凉夏日-特效冷却", 0.1)
              end
              if not u:hasdata("清凉夏日-特效2冷却") and info.element == "水" and u:getluckrandom(1 * info.txgl) then
                u:curetili(1)
                u:settimedata("清凉夏日-特效2冷却", 0.1)
              end
            end)
            t:remove()
          end
        end)
      end
    end,
    effectname = "|cFFC6C0D1德丽莎·沙滩|r",
    effecttext = "|cFFC6C0D1德丽莎 炎\n【阶级】1\n【所属】环都市\n【效果】\n提升3%子弹伤害\n提升[0.15%*德丽莎变异]枪械伤害\n【清凉夏日】\n同时持有德丽莎[夏日][沙滩]时:\n[火属性伤害1%恢复1%生命值,触发冷却0.1秒\n水属性伤害1%恢复1点体力值,触发冷却0.1秒]|r",
    effectart = "Ewl_Mwx_Delisha10"
  },
  {
    name = "德丽莎生日",
    weight = 100,
    lv = 1,
    key = {"德丽莎"},
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
      delishahuoqu(u, var)
      u:changedata("幸运", 1)
      ChangeValue(Correction_Exp, sy, 0.05)
      u:addstexiao(var.name, "过波时效果", function(args)
        u:sendmessage("|cFFC6C0D1德丽莎·生日|r")
        u:addallstats(1 * u:getstate("德丽莎变异"))
      end)
    end,
    effectname = "|cFFC6C0D1德丽莎·生日|r",
    effecttext = "|cFFC6C0D1德丽莎\n【阶级】1\n【所属】环都市\n【效果】\n提升1幸运\n提升5%经验获取\n15%物品获取数量+1\n过波时提升[德丽莎变异*1]点全属性|r",
    effectart = "Ewl_Mwx_Delisha12"
  },
  {
    name = "德丽莎魔法少女",
    weight = 100,
    lv = 1,
    key = {"德丽莎", "魔导"},
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
      delishahuoqu(u, var)
      ChangeValue(HeroMenu_MpCure_Inr, sy, 1)
      ChangeValue(Correction_Magic, sy, 0.0025000000000000005)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        local add = 0.001 * u:getstate("德丽莎变异")
        ChangeValue(Correction_Magic, sy, add)
      end)
    end,
    effectname = "|cFFC6C0D1魔法少女TeRiRi|r",
    effecttext = "|cFFC6C0D1德丽莎 魔导\n【阶级】1\n【所属】环都市\n【效果】\n提升1点魔力恢复\n提升2.5%法术修正\n升级时提升[0.1%*德丽莎变异]法术修正|r",
    effectart = "Ewl_Mwx_Delisha14"
  },
  {
    name = "德丽莎暮光骑士",
    weight = 100,
    lv = 1,
    key = {"德丽莎", "战士"},
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
      delishahuoqu(u, var)
      local jz = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Jzsh, sy, 0.1 * -jz)
        jz = 0.02 * u:getstate("德丽莎变异")
        ChangeValue(Correction_Jzsh, sy, 0.1 * jz)
      end)
      u:addstexiao(var.name, "暴击系统触发效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata("暮光骑士-冷却") then
          u:settimedata("暮光骑士-冷却", 8)
          ChangeTimeValue(DamageSystem_Baoji, sy, 12, 8)
        end
      end)
    end,
    effectname = "|cFFC6C0D1德丽莎·暮光骑士|r",
    effecttext = "|cFFC6C0D1德丽莎 战士\n【阶级】1\n【所属】环都市\n【效果】\n提升[德丽莎变异*0.2%]近战伤害\n暴击时提升12%暴击率,持续8秒,触发冷却8秒|r",
    effectart = "Ewl_Mwx_Delisha13"
  },
  {
    name = "德丽莎新年",
    weight = 100,
    lv = 1,
    key = {"德丽莎"},
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
      delishahuoqu(u, var)
      ChangeValue(Correction_Exp, sy, 0.05)
      local filtered_vartype = {}
      for _, v in ipairs(vartype) do
        if v.name ~= "唯一" and v.name ~= "巫女" then
          table.insert(filtered_vartype, v.name)
        end
      end
      local selected_names = {}
      while #selected_names < 3 do
        local rand_index = math.random(#filtered_vartype)
        local selected_name = filtered_vartype[rand_index]
        local exists = false
        for _, v in ipairs(selected_names) do
          if v == selected_name then
            exists = true
            break
          end
        end
        if not exists then
          table.insert(selected_names, selected_name)
        end
      end
      local str = ""
      for _, name in ipairs(selected_names) do
        str = str .. (require('hera_korean_commands').labels[name] or name) .. ','
      end
      u:setdata("德丽莎新年-未选择")
      ac.wait(1000, function()
        local function chattrg(args)
          if u:hasdata("德丽莎新年-未选择") then
            for _, name in ipairs(selected_names) do
              if args.chat == "德丽莎" .. name then
                u:deldata("德丽莎新年-未选择")
                
                u:setdata("德丽莎新年选择", name)
                u:changedata(name .. "变异补正", 10)
                u:sendmessage('|cFFC6C0D1테레사·신년 선택 완료 - ' .. (require('hera_korean_commands').labels[name] or name) .. '|r')
                u:uivar_change({
                  keyname = "德丽莎新年",
                  keytype = "冥王栏",
                  text = "|cFFC6C0D1테레사·신년|r\n|cFFC6C0D1테레사\n【등급】1\n【소속】환도시\n【효과】\n경험치 획득량 5% 증가\n무작위 특성 세 개 중 하나를 채팅에 [테레사+특성명]으로 입력하여 선택(예. 테레사별). 선택 후 변경 불가\n선택한 특성 보정 10% 증가. 라운드를 넘길 때마다 해당 보정 5% 증가\n선택한 특성\n[" .. (require('hera_korean_commands').labels[name] or name) .. "]|r"
                })
                break
              end
            end
          end
        end
        
        u:addtrgevent("玩家-聊天", function(args)
          chattrg(args)
        end)
        u:uivar_change({
          keyname = "德丽莎新年",
          keytype = "冥王栏",
          text = "|cFFC6C0D1테레사·신년|r\n|cFFC6C0D1테레사\n【등급】1\n【소속】환도시\n【효과】\n경험치 획득량 5% 증가\n무작위 특성 세 개 중 하나를 채팅에 [테레사+특성명]으로 입력하여 선택(예. 테레사별). 선택 후 변경 불가\n선택한 특성 보정 10% 증가. 라운드를 넘길 때마다 해당 보정 5% 증가\n선택 가능한 특성\n[" .. str .. "]|r"
        })
      end)
    end,
    effectname = "|cFFC6C0D1德丽莎·新年|r",
    effecttext = "|cFFC6C0D1德丽莎\n【阶级】1\n【所属】环都市\n【效果】\n提升5%经验获取\n获得三个随机词条,输入\"德丽莎\"+\"词条\"来(例如德丽莎星)选择其中一种(无法变更),\n提升该词条补正10%,每次过波时提升该词条补正5%|r",
    effectart = "Ewl_Mwx_Delisha11"
  }
}
Vars_Mwx_Delisha_Lv2 = {}
Vars_Mwx_DDDD_Lv3 = {}
