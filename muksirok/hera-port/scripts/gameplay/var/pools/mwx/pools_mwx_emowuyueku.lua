-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local keystring = "恶魔五月哭"
local color_main = "FF8BABEB"
local color_sub = "FFA5B2CC"
local DMC_FAMILIAR_CONFIG = {
  ["格里芬"] = {
    unit_id = "n01M",
    model = "units\\nightelf\\DruidoftheTalon\\DruidoftheTalon.mdl",
    size = 1.0
  },
  ["暗影"] = {
    unit_id = "n01K",
    model = "units\\orc\\Spiritwolf\\Spiritwolf.mdl",
    size = 0.9
  },
  ["梦魇"] = {
    unit_id = "n01L",
    model = "units\\creeps\\RockGolem\\RockGolem.mdl",
    size = 1.5
  }
}
local dmc_mechanical_hands = {
  ["电击手"] = true,
  ["离子手"] = true,
  ["时间手"] = true,
  ["钢铁手"] = true,
  ["洛克炮"] = true,
  ["钻头手"] = true
}

local function has_mutation(u, name)
  return u:hasdata("变异判定-" .. name)
end

local function dmc_name(name)
  return "|c" .. color_main .. name .. "|r"
end

local function dmc_text(text)
  return "|c" .. color_sub .. text .. "|r"
end

local function dmc_qidongweightchange(u, var, add)
  add = add or 0
  local start_count = u:getdata("系统-启动负载力")
  local target_weight = 10
  if start_count < 3 then
    target_weight = 1000
  elseif start_count < 6 then
    target_weight = 100
  end
  return add + target_weight - var.weight
end

local function add_dynamic_state_value(u, value, factor, state, var_name)
  local sy = u.ownerid
  local add = 0
  local timer
  timer = ac.loop(3000, function()
    if var_name and not has_mutation(u, var_name) then
      ChangeValue(value, sy, -add)
      timer:remove()
      return
    end
    ChangeValue(value, sy, -add)
    add = factor * u:getstate(state)
    ChangeValue(value, sy, add)
  end)
end

local function add_dynamic_nero_bonus(u, var_name)
  local sy = u.ownerid
  local add = 0.01 * u:getdata("鬼泣计数")
  ChangeValue(Correction_Gun, sy, add)
  ChangeValue(Correction_Jzsh, sy, add)
  ChangeValue(DamageSystem_Shjc, sy, add)
  local timer
  timer = ac.loop(3000, function()
    ChangeValue(Correction_Gun, sy, -add)
    ChangeValue(Correction_Jzsh, sy, -add)
    ChangeValue(DamageSystem_Shjc, sy, -add)
    if not has_mutation(u, var_name) then
      timer:remove()
      return
    end
    add = 0.01 * u:getdata("鬼泣计数")
    ChangeValue(Correction_Gun, sy, add)
    ChangeValue(Correction_Jzsh, sy, add)
    ChangeValue(DamageSystem_Shjc, sy, add)
  end)
end

local function dmc_add_blink_window(u, name, max_distance, toggle_key)
  local window_key = name .. "-位移瞬移窗口"
  u:addstexiao(name, "位移技能后效果", function(args)
    if args.u.handle == u.handle and u:hasdata(toggle_key) then
      u:settimedata(window_key, 1)
    end
  end)
  u:addtrgevent("单位-指定点目标指令", function(args)
    if not u:hasdata(toggle_key) or args.orderid ~= String2OrderIdBJ("smart") or not u:hasdata(window_key) then
      return
    end
    local x, y = u:getxy()
    local tx, ty = args.x, args.y
    local dis = DistanceXY(x, y, tx, ty)
    if dis > max_distance then
      return
    end
    u:deldata(window_key)
    u:buffset(u.handle, 0.2, "绝对闪避")
    unitmove({
      unit = u.handle,
      time = 0.01,
      distance = dis,
      angle = AngleXY(x, y, tx, ty),
      isblink = true
    })
  end)
end

local function dmc_common(u, var)
  MwxTongyong(u, var)
  u:setdata("恶魔五月哭-鬼泣计数-" .. var.name)
  u:changedata("鬼泣计数", 1)
end

local function dmc_try_grant_dante_vergil_reward(u)
  local reward_key = "恶魔五月哭-但丁维吉尔额外奖励"
  if not (not u:hasdata(reward_key) and has_mutation(u, "但丁")) or not has_mutation(u, "维吉尔") then
    return
  end
  u:setdata(reward_key)
  u:changedata("系统-启动负载力", -2)
  u:changedata("系统-精神负载力", -10)
end

local function dmc_remove_mwx_mutation(u, var)
  if not var or not has_mutation(u, var.name) then
    return
  end
  if var.removefunc then
    var.removefunc(u, var)
  end
  u:uivar_remove(var.name, "冥王栏")
  u:deldata("变异判定-" .. var.name)
  if var.lv then
    u:changedata(var.lv .. "阶精神变异数量", -1)
  end
  MwxRemoveSpiritLoadByLv(u, var)
  if var.key then
    for _, value in ipairs(var.key) do
      u:changedata(value .. "变异数量", -1)
    end
  end
  if u:hasdata("恶魔五月哭-鬼泣计数-" .. var.name) then
    u:changedata("鬼泣计数", -1)
    u:deldata("恶魔五月哭-鬼泣计数-" .. var.name)
  end
  var.uniqueact = false
  if u.var and u.var["冥王星"] then
    for index = #u.var["冥王星"], 1, -1 do
      if u.var["冥王星"][index].name == var.name then
        table.remove(u.var["冥王星"], index)
        break
      end
    end
  end
end

local function dmc_has_any_hand(u)
  for name in pairs(dmc_mechanical_hands) do
    if has_mutation(u, name) then
      return true
    end
  end
  return false
end

local function dmc_destroy_hand(u, var)
  dmc_remove_mwx_mutation(u, var)
  u:sendmessage("|cFFCC6666[机械手臂]已销毁:" .. var.name .. "|r")
end

local function dmc_hand_condition(u)
  return Chengzaishangxianpanding(u, 1) and has_mutation(u, "机械手臂") and not dmc_has_any_hand(u)
end

local function dmc_unlock_mechanical_arm(u)
  u:setdata("恶魔五月哭-机械手臂解锁")
  u:buffset(u.handle, 7, "暂停")
  u:buffset(u.handle, 7, "眩晕")
  u:buffset(u.handle, 8, "无敌")
  PlayGlobalSound(Sound_Dmc_Duanshou)
  ac.wait(1200, function()
    u:effectadd("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl")
  end)
  ac.wait(6000, function()
    SendMsgAll(u:getplayername() .. "|cFFCC6666的右手断了")
    u:effectadd("war3mapImported\\texiao_xuebao.mdx")
    if u:hasdata("变异判定-幻想杀手") and not u:hasdata("神化判定-上条当麻") and u:hasdata("幻想杀手-神化可能") then
      MovieAct["幻想杀手进阶"](u, u)
    end
  end)
  NPCChat({
    name = "|cFF6699FF神秘兜帽男|r",
    chaticon = "NPC_Chat_Vege1.blp",
    chattext = {
      {
        text = "|cFF6699FF我将会把它带回|r",
        time = 4.2
      }
    }
  })
end

local function dmc_summon_familiar(u, name)
  u:changedata("召唤物数量", 1)
  local x, y = u:getxy()
  local cfg = DMC_FAMILIAR_CONFIG[name] or {}
  local mj = u:createunit(cfg.unit_id or "n00N", x, y)
  mj = mj or u:createunit("n00N", x, y)
  if not mj then
    u:changedata("召唤物数量", -1)
    u:sendmessage("|cFFFF3333[" .. name .. "]使魔创建失败|r")
    return
  end
  if cfg.model and japi and japi.SetUnitModel then
    japi.SetUnitModel(mj.handle, cfg.model)
  end
  if name == "格里芬" then
    AddUnitAnimationProperties(mj.handle, "alternate", true)
  end
  if cfg.size then
    mj:setsize(cfg.size)
  end
  mj:setdata("召唤物-" .. name)
  mj:groupadd(u:getdata("召唤物组"))
  mj:groupadd(Group_ZhaohuanwuAll)
  mj:setguard(u.handle)
  mj:setdata("常规召唤物", name)
end

local function dmc_add_direct_damage(u, var, chance, cooldown, damage, damage_type, element, mode)
  local cooldown_key = var.name .. "-直接附伤冷却"
  u:addstexiao(var.name, "直接伤害特效", function(args)
    local info = args.damageinfo
    if not has_mutation(u, var.name) then
      return
    end
    local is_attack = info.isattack
    local pass = true
    if mode == "attack" then
      pass = is_attack
    elseif mode == "nonattack" then
      pass = not is_attack
    end
    if args.u.handle == u.handle and pass and not u:hasdata(cooldown_key) and u:getluckrandom(chance * (tonumber(info.txgl) or 1)) then
      u:settimedata(cooldown_key, cooldown)
      DamageUnit({
        bj = var.name .. "附伤",
        unit = args.tg.handle,
        source = u.handle,
        damage = damage,
        level = 1,
        type = damage_type,
        isvest = true,
        isattack = mode ~= "nonattack",
        isnoarmor = false,
        element = element
      })
    end
  end)
end

local function dmc_make_var(args)
  args.weight = args.weight or 100
  args.lv = args.lv or 1
  args.seckey = keystring
  if args.unique == nil then
  end
  args.unique = args.unique
  args.addweight = args.addweight or function()
    return 0
  end
  return args
end

local function dmc_base_condition(u, lv)
  return Chengzaishangxianpanding(u, lv)
end

Vars_Ciyuan_Emowuyueku = {
  {
    name = "尼禄",
    lv = 3,
    weight = 100,
    unique = true,
    key = {
      "白毛",
      "恶魔",
      "战士",
      "唯一"
    },
    condition = function(u)
      return has_mutation(u, "但丁") and has_mutation(u, "维吉尔")
    end,
    effect = function(u, var)
      ciyuanget(u, var)
      u:setdata("恶魔五月哭-鬼泣计数-" .. var.name)
      u:changedata("鬼泣计数", 1)
      add_dynamic_nero_bonus(u, var.name)
      u:addstexiao(var.name .. "-疾走获取", "直接伤害特效", function(args)
        local info = args.damageinfo
        if has_mutation(u, var.name) and args.u.handle == u.handle and not info.isvestdamage and 0 < (tonumber(info.xs_qx) or 0) and not u:hasdata(var.name .. "-疾走获取冷却") then
          u:settimedata(var.name .. "-疾走获取冷却", 0.5)
          local stacks = u:getdata(var.name .. "-疾走层数")
          if stacks < 3 then
            u:changedata(var.name .. "-疾走层数", 1)
          end
        end
      end)
      u:addstexiao(var.name .. "-疾走消耗", "伤害判定前变更", function(args)
        local info = args.damageinfo
        if not (has_mutation(u, var.name) and args.u.handle == u.handle and info.ismeleedamage) or info.isvestdamage then
          return
        end
        local stacks = u:getdata(var.name .. "-疾走层数")
        if stacks <= 0 then
          return
        end
        u:deldata(var.name .. "-疾走层数")
        args.shadd = args.shadd * (1 + 0.2 * stacks)
        if stacks < 3 or u:hasdata(var.name .. "-恶魔破坏者冷却") then
          return
        end
        u:settimedata(var.name .. "-恶魔破坏者冷却", 3)
        local x, y = args.tg:getxy()
        local damage = u:getdata("系统-累积等级") * (5000 + u:getdata("鬼泣计数") * 500)
        for _, target in ac.selector():in_rangexy(x, y, 300):is_enemy(u.handle):ipairs() do
          target = getunit(target)
          DamageUnit({
            bj = "尼禄(恶魔破坏者)",
            unit = target.handle,
            source = u.handle,
            damage = damage,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = true,
            isnoarmor = false,
            element = "无"
          })
          target:buffset(u.handle, 2, "眩晕")
        end
      end)
      dmc_unlock_mechanical_arm(u)
    end,
    effectname = dmc_name("尼禄"),
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFA5B2CC白毛 恶魔 战士\n鬼泣计数+1\n提升[鬼泣计数*1%]枪械伤害\n提升[鬼泣计数*1%]近战伤害\n提升[鬼泣计数*1%]伤害加成\n【疾走】\n枪械直接伤害命中获得1层疾走,获取冷却0.5秒,最多3层\n近战直接伤害命中消耗全部疾走,每层使本次伤害独立提升20%\n【恶魔破坏者】\n消耗3层疾走时对目标300范围造成[累积等级*(5000+鬼泣计数*500)]物理近战伤害与2秒眩晕\n该伤害不触发疾走,冷却3秒|r",
    effectart = "Mwx_Dmc_Nilu.tga"
  }
}
Vars_Mwx_Emowuyueku = {
  dmc_make_var({
    name = "但丁(少年)",
    lv = 1,
    key = {},
    condition = function(u)
      return dmc_base_condition(u, 1)
    end,
    effect = function(u, var)
      local sy = u.ownerid
      dmc_common(u, var)
      ChangeValue(Correction_Gun, sy, 0.05)
      ChangeValue(Correction_Gun_Bullet, sy, 0.02)
    end,
    effectname = dmc_name("但丁(少年)"),
    effecttext = dmc_text("【阶级】1\n【所属】恶魔五月哭\n鬼泣计数+1\n提升5%枪械伤害\n提升2%子弹伤害\n解锁获取[但丁(青年)] "),
    effectart = "Mwx_Dmc_Danding3.tga"
  }),
  dmc_make_var({
    name = "但丁(青年)",
    lv = 1,
    key = {},
    condition = function(u)
      return dmc_base_condition(u, 1) and has_mutation(u, "但丁(少年)")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      dmc_common(u, var)
      ChangeValue(Correction_Gun, sy, 0.05)
      ChangeValue(Correction_Jzsh, sy, 0.05)
    end,
    effectname = dmc_name("但丁(青年)"),
    effecttext = dmc_text("【阶级】1\n【所属】恶魔五月哭\n鬼泣计数+1\n提升5%枪械伤害\n提升5%近战伤害\n解锁获取[但丁(中年)] "),
    effectart = "Mwx_Dmc_Danding4.tga"
  }),
  dmc_make_var({
    name = "但丁(中年)",
    lv = 1,
    key = {},
    condition = function(u)
      return dmc_base_condition(u, 1) and has_mutation(u, "但丁(青年)")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      dmc_common(u, var)
      ChangeValue(Correction_Jzsh, sy, 0.05)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        if has_mutation(u, var.name) and args.u.handle == u.handle then
          args.damageinfo.damage = args.damageinfo.damage * 1.02
        end
      end)
    end,
    effectname = dmc_name("但丁(中年)"),
    effecttext = dmc_text("【阶级】1\n【所属】恶魔五月哭\n鬼泣计数+1\n提升5%近战伤害\n提升2%近战伤害(独立)\n解锁获取[但丁] "),
    effectart = "Mwx_Dmc_Danding5.tga"
  }),
  dmc_make_var({
    name = "但丁",
    weight = 100,
    lv = 3,
    key = {"战士", "恶魔"},
    clickfunc = function(u, var)
      if u:hasdata("但丁-咿呀剑法开启") then
        u:deldata("但丁-咿呀剑法开启")
        u:sendmessage("|cFFC9696A已关闭咿呀剑法|r")
      else
        u:setdata("但丁-咿呀剑法开启")
        u:sendmessage("|cFFC9696A已开启咿呀剑法|r")
      end
    end,
    condition = function(u)
      return dmc_base_condition(u, 5) and has_mutation(u, "但丁(少年)") and has_mutation(u, "但丁(青年)") and has_mutation(u, "但丁(中年)")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      if Danwei_Dante == 0 then
        Danwei_Dante = u.handle
        Weiyi_New[28] = true
        if Weiyi_New[29] then
          MovieAct["Hey维吉尔"]()
        end
      end
      dmc_common(u, var)
      dmc_try_grant_dante_vergil_reward(u)
      u:setdata("但丁-咿呀剑法开启")
      add_dynamic_state_value(u, DamageSystem_Shjc, 0.03, "恶魔变异", var.name)
      add_dynamic_state_value(u, Correction_Jzsh, 0.015, "恶魔变异", var.name)
      add_dynamic_state_value(u, DamageSystem_EndSh, 0.005, "恶魔变异", var.name)
      ChangeValue(HeroMenu_HpForever_Inr, sy, 16)
      ChangeValue(DamageSystem_EndSh, sy, 0.06)
      u:addstexiao(var.name, "武器使用后效果", function(args)
        local lx = GetData(args.wqlx, "近战武器类型")
        if u:hasdata("但丁-咿呀剑法开启") and (lx == 11 or lx == 2) then
          unitmove({
            unit = u.handle,
            time = 0.1,
            distance = 140,
            angle = args.angle
          })
          u:playseensound(Sound_Dmc_Yiya)
          local cd = tonumber(GetData(args.wqlx, "冷却时间")) or 0
          if 0 < cd then
            ac.wait(10, function()
              u:setskillcd(args.skill, 1)
            end)
          end
        end
      end)
    end,
    effectname = "|cFFC9696A但丁|r",
    effecttext = "|cFFC9696A战士 恶魔|r\n|cFFC9696A【阶级】3\n【所属】恶魔五月哭\n鬼泣计数+1\n提升[恶魔变异*3%]伤害加成\n提升[恶魔变异*1.5%]近战伤害\n提升[恶魔变异*0.5%]终结伤害|r\n|cFFF7A8B1【咿呀剑法】(点击切换开关)|r\n|cFFC9696A剑或刀类武器伤害附带击退效果\n使用剑或刀类武器时会向前冲刺一段距离\n剑或刀类武器冷却如果超过1秒会变为1秒|r\n|cFFF7A8B1【风格切换】|r\n|cFFC9696A切换武器冷却降低50%\n切换枪械冷却降低90%\n切换枪械或武器时获得0.25秒绝对闪避\n切换枪械时获得10%枪械伤害,持续15秒,可叠加,分立计时\n切换武器时提升10%近战伤害,持续15秒,可叠加,分立计时|r\n|cFFF7A8B1【半魔人】|r\n|cFFC9696A提升16永恒恢复\n提升6%终结伤害|r",
    effectart = "war3mapImported\\PASBTNYcPro_04.tga"
  }),
  dmc_make_var({
    name = "魔剑士",
    lv = 1,
    key = {},
    condition = function(u)
      return dmc_base_condition(u, 1)
    end,
    effect = function(u, var)
      local sy = u.ownerid
      dmc_common(u, var)
      ChangeValue(DamageSystem_Shjc, sy, 0.05)
      ChangeValue(Correction_Jzsh, sy, 0.05)
    end,
    effectname = dmc_name("魔剑士"),
    effecttext = dmc_text("【阶级】1\n【所属】恶魔五月哭\n鬼泣计数+1\n提升5%伤害加成\n提升5%近战伤害\n解锁[阎魔刀][幻影剑][贝奥武夫][抛瓦椅] "),
    effectart = "Mwx_Dmc_Weijier.tga"
  }),
  dmc_make_var({
    name = "阎魔刀",
    lv = 1,
    key = {},
    condition = function(u)
      return dmc_base_condition(u, 1) and has_mutation(u, "魔剑士")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      dmc_common(u, var)
      ChangeValue(Damage_Element_Dark, sy, 0.05)
      ChangeValue(Correction_Jzsh, sy, 0.05)
    end,
    effectname = dmc_name("阎魔刀"),
    effecttext = dmc_text("【阶级】1\n【所属】恶魔五月哭\n鬼泣计数+1\n提升5%暗属性伤害\n提升5%近战伤害\n解锁[V] "),
    effectart = "Mwx_Dmc_Yanmodao.tga"
  }),
  dmc_make_var({
    name = "贝奥武夫",
    lv = 1,
    key = {},
    condition = function(u)
      return dmc_base_condition(u, 1) and has_mutation(u, "魔剑士")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      dmc_common(u, var)
      ChangeValue(DamageSystem_Shjc, sy, 0.05)
      ChangeValue(Correction_Jzsh, sy, 0.05)
    end,
    effectname = dmc_name("贝奥武夫"),
    effecttext = dmc_text("【阶级】1\n【所属】恶魔五月哭\n鬼泣计数+1\n提升5%伤害加成\n提升5%近战伤害"),
    effectart = "Mwx_Dmc_Beiaowufu.tga"
  }),
  dmc_make_var({
    name = "幻影剑",
    lv = 1,
    key = {},
    condition = function(u)
      return dmc_base_condition(u, 1) and has_mutation(u, "魔剑士")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      dmc_common(u, var)
      ChangeValue(DamageSystem_Shjc, sy, 0.05)
      ChangeValue(Correction_Jzsh, sy, 0.05)
    end,
    effectname = dmc_name("幻影剑"),
    effecttext = dmc_text("【阶级】1\n【所属】恶魔五月哭\n鬼泣计数+1\n提升5%伤害加成\n提升5%近战伤害"),
    effectart = "Mwx_Dmc_Huanyingjian.tga"
  }),
  dmc_make_var({
    name = "V",
    lv = 1,
    key = {"召唤"},
    condition = function(u)
      return dmc_base_condition(u, 1) and has_mutation(u, "阎魔刀")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      dmc_common(u, var)
      ChangeValue(Correction_Summon, sy, 0.1)
      dmc_summon_familiar(u, "格里芬")
      dmc_summon_familiar(u, "暗影")
      dmc_summon_familiar(u, "梦魇")
    end,
    effectname = dmc_name("V"),
    effecttext = dmc_text("召唤\n【阶级】1\n【所属】恶魔五月哭\n鬼泣计数+1\n提升10%召唤伤害\n召唤三只使魔\n拥有[尤里曾]后解锁[维吉尔] "),
    effectart = "Mwx_Dmc_V.tga"
  }),
  dmc_make_var({
    name = "抛瓦椅",
    lv = 2,
    key = {"唯一"},
    unique = true,
    condition = function(u)
      return dmc_base_condition(u, 2) and has_mutation(u, "魔剑士")
    end,
    effect = function(u, var)
      dmc_common(u, var)
      u:sendmessage("|cFF6699CC你感觉充满了抛瓦|r")
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 3)
          local x, y = u:getxy()
          local x2, y2 = tg:getxy()
          local angle = AngleXY(x, y, x2, y2)
          u:playseensound(Sound_Bcy_CyzXiao)
          local txsh = 1000 * u:getlevel()
          unifycreate({
            owner = u.handle,
            model = "dpdyizi.mdl",
            modelname = "抛瓦椅",
            modelsize = 2.5,
            height = 0,
            damage = txsh,
            damagetype = 2,
            x = x,
            y = y,
            range = 2000,
            time = 0.5,
            volume = 125,
            angle = angle,
            angleoffset = 0,
            attenua = 1,
            attenuacount = 999,
            life = 10,
            isbullet = false,
            isvest = false,
            isignorearmor = false,
            startfunc = function(mj)
            end,
            loopfunc = function(mj)
            end,
            hitfunc = function(mj, damage)
              return damage
            end,
            hitbeforefunc = function(mj, xq, damage2)
              return damage2
            end,
            hitafterfunc = function(mj, xq, damage2)
            end,
            endfunc = function(mj)
            end
          })
        end
      end)
      AddUISkill({
        text = "抛瓦椅",
        u = u,
        cd = 180,
        showtext = "|cff659bff抛瓦剑阵\n每0.25秒对自身周围单位造成[1000*等级]物理近战伤害\n持续15秒\n发动时获得[等级*250]临时护盾\n冷却180秒|r",
        icon = "Ewl_Mwx_Erjie_01.tga",
        func = function(args)
          local u = args.u
          if u:isalive() then
            if not u:hasdata("抛瓦椅-音乐播放冷却") then
              PlayBGM({
                bgm = BGM_Burythelight,
                time = 430,
                ID = 200,
                unit = u.handle
              })
              u:settimedata("抛瓦椅-音乐播放冷却", 1800)
            end
            hdzlinshiadd(u, 250 * u:getlevel())
            local txsh = 100000
            ac.timer(250, 60, function()
              local x, y = u:getxy()
              for _, xq in ac.selector():in_rangexy(x, y, 600):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                DamageUnit({
                  bj = "抛瓦椅(技能)",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "物理",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "无",
                  extradata = {""}
                })
                xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
              end
            end)
            for i = 1, 12 do
              local jd = i * 30
              local dx, dy = PolarXY(u:getxy(), u:getxy(), 450, jd)
              local tx = EffectcreateArgs({
                effect = "dpdyizi.mdl",
                x = dx,
                y = dy,
                time = 15,
                size = 2.5,
                height = 50,
                zxz = jd
              })
              ac.timer(30, 500, function()
                jd = jd + 3
                local x, y = u:getxy()
                dx, dy = PolarXY(x, y, 450, jd)
                SetEffectXY(tx, dx, dy)
                SetEffectAngle(tx, 3)
              end)
            end
          end
        end
      })
    end,
    effectname = dmc_name("抛瓦椅"),
    effecttext = dmc_text("唯一\n【阶级】2\n鬼泣计数+1\n直接伤害时10%发射抛瓦椅对一直线单位造成[100000]物理伤害,冷却3秒\n提升100%次元斩类伤害\n解锁技能[抛瓦剑阵] "),
    effectart = "Ewl_Mwx_Erjie_01"
  }),
  dmc_make_var({
    name = "恶魔之树",
    lv = 1,
    key = {},
    condition = function(u)
      return dmc_base_condition(u, 1)
    end,
    effect = function(u, var)
      dmc_common(u, var)
    end,
    effectname = dmc_name("恶魔之树"),
    effecttext = dmc_text("【阶级】1\n【所属】恶魔五月哭\n鬼泣计数+1\n拥有[阎魔刀]后解锁[尤里曾] "),
    effectart = "Mwx_Dmc_Emozhishu.tga"
  }),
  dmc_make_var({
    name = "尤里曾",
    lv = 1,
    key = {"恶魔"},
    condition = function(u)
      return dmc_base_condition(u, 1) and has_mutation(u, "恶魔之树") and has_mutation(u, "阎魔刀")
    end,
    effect = function(u, var)
      dmc_common(u, var)
      add_dynamic_state_value(u, DamageSystem_Shjc, 0.01, "恶魔变异", var.name)
    end,
    effectname = dmc_name("尤里曾"),
    effecttext = dmc_text("恶魔\n【阶级】1\n【所属】恶魔五月哭\n鬼泣计数+1\n提升[恶魔变异*1%]伤害加成\n拥有[V]后解锁[维吉尔] "),
    effectart = "Mwx_Dmc_Youlizeng.tga"
  }),
  dmc_make_var({
    name = "维吉尔",
    weight = 100,
    lv = 3,
    key = {
      "战士",
      "恶魔",
      "影"
    },
    clickfunc = function(u, var)
      local toggle_key = var.name .. "-位移瞬移开启"
      if u:hasdata(toggle_key) then
        u:deldata(toggle_key)
        u:deldata(var.name .. "-位移瞬移窗口")
        u:sendmessage("|cff4198df已关闭黑暗杀手瞬移|r")
      else
        u:setdata(toggle_key)
        u:sendmessage("|cff4198df已开启黑暗杀手瞬移|r")
      end
    end,
    condition = function(u)
      return dmc_base_condition(u, 3) and has_mutation(u, "尤里曾") and has_mutation(u, "V")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      if Danwei_Vergil == 0 then
        Danwei_Vergil = u.handle
        Weiyi_New[29] = true
        if Weiyi_New[28] then
          MovieAct["Hey维吉尔"]()
        end
      end
      dmc_common(u, var)
      dmc_try_grant_dante_vergil_reward(u)
      add_dynamic_state_value(u, DamageSystem_Shjc, 0.03, "恶魔变异", var.name)
      add_dynamic_state_value(u, Correction_Jzsh, 0.015, "恶魔变异", var.name)
      add_dynamic_state_value(u, DamageSystem_EndSh, 0.005, "恶魔变异", var.name)
      ChangeValue(DamageSystem_Baoji, sy, 12)
      add_dynamic_state_value(u, DamageSystem_Baoshang, 0.03, "恶魔变异", var.name)
      local blink_toggle_key = var.name .. "-位移瞬移开启"
      u:setdata(blink_toggle_key)
      dmc_add_blink_window(u, var.name, 600, blink_toggle_key)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local info = args.damageinfo
        if args.u.handle == u.handle and info.isattack and not u:hasdata(var.name .. "-附伤冷却") and u:getluckrandom(5 * (tonumber(info.txgl) or 1)) then
          u:settimedata(var.name .. "-附伤冷却", 0.25)
          DamageUnit({
            bj = "维吉尔(幻影剑附伤)",
            unit = args.tg.handle,
            source = u.handle,
            damage = 200000,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = info.isattack,
            isnoarmor = false,
            element = "暗"
          })
        end
      end)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      ChangeValue(DamageSplit_CountJzMax, sy, 0.33)
      ChangeValue(DamageSystem_EndSh, sy, 0.06)
      ChangeValue(HeroMenu_HpForever_Inr, sy, 16)
    end,
    effectname = "|cff4198df维吉尔|r",
    effecttext = "|cff71b2e7战士 恶魔 影|r\n|cffa9c9ee【阶级】3\n【所属】恶魔五月哭\n鬼泣计数+1\n提升[恶魔变异*3%]伤害加成\n提升[恶魔变异*1.5%]近战伤害\n提升[恶魔变异*0.5%]终结伤害|r\n|cff4198df【黑暗杀手】(点击切换开关)|r\n|cffa9c9ee提升12%暴击率\n提升[恶魔变异*3%]暴击伤害\n位移后1秒内右击地面可瞬移并获得0.2秒绝对闪避|r\n|cff4198df【幻影剑】|r\n|cffa9c9ee近战段数+1(魔力)\n近战多段上限+33%\n近战直接伤害5%附带[200000]伤害,冷却0.25秒|r\n|cff4198df【半魔人】|r\n|cffa9c9ee提升16永恒恢复\n提升6%终结伤害|r",
    effectart = "war3mapImported\\PASBTNYcPro_03.tga"
  }),
  dmc_make_var({
    name = "力量之刃",
    lv = 1,
    key = {},
    condition = function(u)
      return dmc_base_condition(u, 1)
    end,
    effect = function(u, var)
      local sy = u.ownerid
      dmc_common(u, var)
      ChangeValue(DamageSystem_Shjc, sy, 0.05)
      ChangeValue(Correction_Jzsh, sy, 0.05)
    end,
    effectname = dmc_name("力量之刃"),
    effecttext = dmc_text("【阶级】1\n【所属】恶魔五月哭\n鬼泣计数+1\n提升5%伤害加成\n提升5%近战伤害"),
    effectart = "Mwx_Dmc_Liliangzhiren.tga"
  }),
  dmc_make_var({
    name = "蒙蒂斯",
    lv = 1,
    key = {"原罪"},
    condition = function(u)
      return dmc_base_condition(u, 1)
    end,
    effect = function(u, var)
      local sy = u.ownerid
      dmc_common(u, var)
      u:changedata("原罪值", 1)
      ChangeValue(DamageSystem_EndSh, sy, 0.02)
    end,
    effectname = dmc_name("蒙蒂斯"),
    effecttext = dmc_text("原罪 1\n【阶级】1\n【所属】恶魔五月哭\n鬼泣计数+1\n提升2%终结伤害\n解锁[黑色天使] "),
    effectart = "Mwx_Dmc_Mengdisi.tga"
  }),
  dmc_make_var({
    name = "黑色天使",
    lv = 1,
    key = {},
    condition = function(u)
      return dmc_base_condition(u, 1) and has_mutation(u, "蒙蒂斯")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      dmc_common(u, var)
      ChangeValue(Damage_Element_Dark, sy, 0.05)
    end,
    effectname = dmc_name("黑色天使"),
    effecttext = dmc_text("【阶级】1\n【所属】恶魔五月哭\n鬼泣计数+1\n提升5%暗属性伤害\n拥有[力量之刃]后解锁[斯巴达之剑] "),
    effectart = "Mwx_Dmc_Heisetianshi.tga"
  }),
  dmc_make_var({
    name = "斯巴达之剑",
    lv = 1,
    key = {},
    condition = function(u)
      return dmc_base_condition(u, 1) and has_mutation(u, "黑色天使") and has_mutation(u, "力量之刃")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      dmc_common(u, var)
      ChangeValue(DamageSystem_Shjc, sy, 0.1)
      ChangeValue(Correction_Jzsh, sy, 0.1)
    end,
    effectname = dmc_name("斯巴达之剑"),
    effecttext = dmc_text("【阶级】1\n【所属】恶魔五月哭\n鬼泣计数+1\n提升10%伤害加成\n提升10%近战伤害\n拥有[Eva]后解锁[斯巴达] "),
    effectart = "Mwx_Dmc_Sibadazhiren.tga"
  }),
  dmc_make_var({
    name = "Eva",
    lv = 1,
    key = {"光明"},
    condition = function(u)
      return dmc_base_condition(u, 1)
    end,
    effect = function(u, var)
      dmc_common(u, var)
      u:changeoriginmaxhp(2500)
    end,
    effectname = dmc_name("Eva"),
    effecttext = dmc_text("光明\n【阶级】1\n【所属】恶魔五月哭\n鬼泣计数+1\n提升250基础生命上限\n拥有[斯巴达之剑]后解锁[斯巴达] "),
    effectart = "Mwx_Dmc_Eva.tga"
  }),
  dmc_make_var({
    name = "斯巴达",
    lv = 2,
    key = {"恶魔", "战士"},
    condition = function(u)
      return dmc_base_condition(u, 2) and has_mutation(u, "Eva") and has_mutation(u, "斯巴达之剑")
    end,
    effect = function(u, var)
      dmc_common(u, var)
      add_dynamic_state_value(u, Correction_Jzsh, 0.01, "恶魔变异", var.name)
      add_dynamic_state_value(u, DamageSystem_Shjc, 0.01, "恶魔变异", var.name)
    end,
    effectname = dmc_name("斯巴达"),
    effecttext = dmc_text("恶魔 战士\n【阶级】2\n【所属】恶魔五月哭\n鬼泣计数+1\n提升[恶魔变异*1%]近战伤害\n提升[恶魔变异*1%]伤害加成 "),
    effectart = "Mwx_Dmc_Sibada.tga"
  }),
  dmc_make_var({
    name = "恶魔右手",
    lv = 1,
    key = {},
    condition = function(u)
      return dmc_base_condition(u, 1) and has_mutation(u, "尼禄")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      dmc_common(u, var)
      ChangeValue(Correction_Gun, sy, 0.1)
      ChangeValue(Correction_Jzsh, sy, 0.1)
      ChangeValue(DamageSystem_Shjc, sy, 0.1)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      ChangeValue(Correction_Gun, sy, -0.1)
      ChangeValue(Correction_Jzsh, sy, -0.1)
      ChangeValue(DamageSystem_Shjc, sy, -0.1)
    end,
    effectname = dmc_name("恶魔右手"),
    effecttext = dmc_text("【阶级】1\n【所属】恶魔五月哭\n鬼泣计数+1\n提升10%枪械伤害\n提升10%近战伤害\n提升10%伤害加成\n独立出现在拥有[尼禄]时的冥王传奇池"),
    effectart = "Mwx_Dmc_Emoyoubi.tga"
  }),
  dmc_make_var({
    name = "机械手臂",
    lv = 1,
    key = {"机械"},
    condition = function(u)
      return dmc_base_condition(u, 1) and u:hasdata("恶魔五月哭-机械手臂解锁")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      dmc_common(u, var)
      ChangeValue(Correction_Gun, sy, 0.1)
      ChangeValue(Correction_Jzsh, sy, 0.1)
      ChangeValue(DamageSystem_Shjc, sy, 0.1)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      ChangeValue(Correction_Gun, sy, -0.1)
      ChangeValue(Correction_Jzsh, sy, -0.1)
      ChangeValue(DamageSystem_Shjc, sy, -0.1)
    end,
    effectname = dmc_name("机械手臂"),
    effecttext = dmc_text("机械\n【阶级】1\n【所属】恶魔五月哭\n鬼泣计数+1\n提升10%枪械伤害\n提升10%近战伤害\n提升10%伤害加成\n解锁机械手相关变异\n同一时间只能拥有一个机械手相关变异"),
    effectart = "Mwx_Dmc_Jixieshoubi.tga"
  })
}
Vars_Mwx_Emowuyueku_Jixieshou = {
  dmc_make_var({
    name = "电击手",
    lv = 1,
    key = {"机械"},
    clickfunc = dmc_destroy_hand,
    condition = dmc_hand_condition,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(Damage_Element_Thunder, sy, 0.2)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local info = args.damageinfo
        if has_mutation(u, var.name) and args.u.handle == u.handle and info.isattack then
          info.element = "雷"
        end
      end)
    end,
    removefunc = function(u, var)
      ChangeValue(Damage_Element_Thunder, u.ownerid, -0.2)
    end,
    effectname = dmc_name("电击手"),
    effecttext = dmc_text("机械\n【阶级】1\n【所属】恶魔五月哭\n提升20%雷属性伤害\n近战直接伤害变为雷属性\n[左键]销毁该手臂] "),
    effectart = "Mwx_Dmc_Dianjishou.tga"
  }),
  dmc_make_var({
    name = "离子手",
    lv = 1,
    key = {"机械"},
    clickfunc = dmc_destroy_hand,
    condition = dmc_hand_condition,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(Damage_Type_Nengliang, sy, 0.3)
    end,
    removefunc = function(u, var)
      ChangeValue(Damage_Type_Nengliang, u.ownerid, -0.3)
    end,
    effectname = dmc_name("离子手"),
    effecttext = dmc_text("机械\n【阶级】1\n【所属】恶魔五月哭\n提升30%能量伤害\n近战以外的直接伤害类型变为能量\n[左键]销毁该手臂] "),
    effectart = "Mwx_Dmc_Lizishou.tga"
  }),
  dmc_make_var({
    name = "时间手",
    lv = 1,
    key = {"机械"},
    clickfunc = dmc_destroy_hand,
    condition = dmc_hand_condition,
    effect = function(u, var)
      MwxTongyong(u, var)
      if not u:ishasskill("A01A") then
        u:addskill("A01A")
      end
    end,
    removefunc = function(u, var)
      if u:ishasskill("A01A") then
        u:delskill("A01A")
      end
    end,
    effectname = dmc_name("时间手"),
    effecttext = dmc_text("机械\n【阶级】1\n【所属】恶魔五月哭\n降低周围50%速度\n[左键]销毁该手臂] "),
    effectart = "Mwx_Dmc_Shijianshou.tga"
  }),
  dmc_make_var({
    name = "钢铁手",
    lv = 1,
    key = {"机械"},
    clickfunc = dmc_destroy_hand,
    condition = dmc_hand_condition,
    effect = function(u, var)
      MwxTongyong(u, var)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        if has_mutation(u, var.name) and args.u.handle == u.handle then
          args.damageinfo.damage = args.damageinfo.damage * 1.2
        end
      end)
    end,
    effectname = dmc_name("钢铁手"),
    effecttext = dmc_text("机械\n【阶级】1\n【所属】恶魔五月哭\n提升20%近战伤害(独立)\n[左键]销毁该手臂] "),
    effectart = "Mwx_Dmc_Gangtieshou.tga"
  }),
  dmc_make_var({
    name = "洛克炮",
    lv = 1,
    key = {"机械"},
    clickfunc = dmc_destroy_hand,
    condition = dmc_hand_condition,
    effect = function(u, var)
      MwxTongyong(u, var)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local info = args.damageinfo
        if not has_mutation(u, var.name) or args.u.handle ~= u.handle or info.isattack or u:hasdata(var.name .. "-直接附伤冷却") then
          return
        end
        u:settimedata(var.name .. "-直接附伤冷却", 0.25)
        local x, y = u:getxy()
        local tx, ty = args.tg:getxy()
        unifycreate({
          owner = u.handle,
          model = "Abilities\\Weapons\\SpiritOfVengeanceMissile\\SpiritOfVengeanceMissile.mdl",
          modelname = "恶魔五月哭-洛克炮",
          modelsize = 1.2,
          height = 100,
          damage = 200000,
          damagetype = 2,
          x = x,
          y = y,
          range = 2400,
          speed = 4000,
          volume = 80,
          angle = AngleXY(x, y, tx, ty),
          attenua = 1,
          attenuacount = 1,
          life = 2,
          isbullet = false,
          isvest = true,
          isnoarmor = false
        })
      end)
    end,
    effectname = dmc_name("洛克炮"),
    effecttext = dmc_text("机械\n【阶级】1\n【所属】恶魔五月哭\n近战以外的直接伤害发射一发[200000]伤害的能量弹幕,冷却0.25秒\n[左键]销毁该手臂|r"),
    effectart = "Mwx_Dmc_Luokepao.tga"
  }),
  dmc_make_var({
    name = "钻头手",
    lv = 1,
    key = {"机械"},
    clickfunc = dmc_destroy_hand,
    condition = dmc_hand_condition,
    effect = function(u, var)
      MwxTongyong(u, var)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        if has_mutation(u, var.name) and args.u.handle == u.handle and tg and not tg:hasdata(var.name .. "-减甲") then
          tg:setdata(var.name .. "-减甲")
          tg:changearmor(-45)
        end
      end)
    end,
    effectname = dmc_name("钻头手"),
    effecttext = dmc_text("机械\n【阶级】1\n【所属】恶魔五月哭\n直接伤害降低目标45护甲,无法叠加\n[左键]销毁该手臂] "),
    effectart = "Mwx_Dmc_Zuantoushou.tga"
  })
}
