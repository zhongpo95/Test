-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local keystring = "神秘庭院"
Vars_Mwx_Tyzm = {
  {
    name = "外域视界",
    weight = 100,
    lv = 1,
    key = {"外域"},
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
      local exp = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Exp, sy, -2 * exp)
        exp = 0.0025 * u:getstate("外域变异")
        ChangeValue(Correction_Exp, sy, 2 * exp)
      end)
      u:addstexiao(var.name, "波数开始时效果", function(args)
        local sj = GetRandomInt(1, 5)
        local str = ""
        if sj == 1 then
          str = "提升1外域词条"
          u:changedata("外域变异数量", 1)
        end
        if sj == 2 then
          str = "什么都没有发生"
        end
        if sj == 3 then
          str = "提升2.5%伤害加成"
          ChangeValue(DamageSystem_Shjc, sy, 0.025)
        end
        if sj == 4 then
          str = "降低2.5%伤害加成"
          ChangeValue(DamageSystem_Shjc, sy, -0.025)
        end
        if sj == 5 then
          str = "降低250生命上限"
          u:changemaxhp(-250)
        end
        u:sendmessage("|cFF9999FF[外域启示]" .. str)
      end)
    end,
    effectname = "|cFF0099CC外域视界|r",
    effecttext = "|cFF0099CC外域\n【阶级】1\n【效果】\n提升[0.5%*外域变异]经验获取\n每波开始会获得一次外域启示|r",
    effectart = "war3mapImported\\BTNEwl_Mwx_Waiyushijie.blp"
  },
  {
    name = "旧神刻印",
    weight = 100,
    lv = 1,
    key = {"外域"},
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
      u:changedata("外域变异补正", 33)
      local exp = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Exp, sy, -2 * exp)
        exp = 0.0025 * u:getstate("外域变异")
        ChangeValue(Correction_Exp, sy, 2 * exp)
      end)
    end,
    effectname = "|cFF3399CC旧神刻印|r",
    effecttext = "|cFF3399CC外域\n【阶级】1\n【效果】\n提升[0.5%*外域变异]经验获取\n提升33%外域变异补正|r",
    effectart = "war3mapImported\\BTNEwl_Mwx_Jiushenkeyin.blp"
  },
  {
    name = "异度侵入",
    weight = 25,
    lv = 1,
    key = {
      "唯一",
      "外域",
      "影"
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
      u:chat("…还有什么好留恋的呢")
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
      u:playsound(Yinxiao_Ydqr)
      AddUISkill({
        text = var.name,
        u = u,
        showtext = "|cFF66CCCC[侵入井]\n获得2秒无实体\n冷却60秒|r",
        cd = 60,
        icon = "war3mapImported\\BTNEwl_Mwx_Yiduqinru.blp",
        func = function(args)
          local u = args.u
          if u:isalive() then
            u:setcolor(255, 255, 255, 125)
            u:effectadd("war3mapImported\\[TX] (1057).mdl")
            local tz = 2
            u:buffset(u.handle, tz, "无实体")
            ac.wait(tz * 1000, function()
              u:setcolor(255, 255, 255, 255)
            end)
          end
        end
      })
    end,
    effectname = "|cFF66CCCC异度侵入|r",
    effecttext = "|cFF66CCCC外域 影 唯一\n【阶级】1\n【效果】\n提升25额外移速\n主动技能:\n【使用时获得2秒无实体(冷却60秒)】\n【额外】\n稀有权重|r",
    effectart = "war3mapImported\\BTNEwl_Mwx_Yiduqinru.blp"
  },
  {
    name = "星之彩",
    weight = 10,
    lv = 1,
    key = {
      "外域",
      "星",
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
      b = Chengzaishangxianpanding(u, 1, b)
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      ChangeValue(Correction_Exp, sy, 0.025)
      u:changedata("全属性增幅", 0.025)
      u:addallstats(15)
      u:setdata("星之彩等级", 1)
    end,
    effectname = "|cFF339999星之彩|r",
    effecttext = "|cFF339999外域 星 唯一\n【阶级】1\n【效果】\n提升2.5%经验获取\n提升2.5%全属性\n提升15全属性\n【额外】\n极其稀有权重\n被注视时概率进阶|r",
    effectart = "Mwx_Tingyuanzhimen_05_15"
  }
}
Vars_Mwx_Tyzm_Spe = {
  {
    name = "黑猫",
    weight = 5,
    lv = 1,
    key = {
      "外域",
      "兽",
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
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      MwxTongyong(u, var)
      Weiyi_New[21] = true
      SendMsgAll(u:getplayername() .. "|cFFCCFFCC获得【|r" .. var.effectname .. "|cFFCCFFCC】(唯一)|r")
      u:changedata("神秘庭院-员工上限", 1)
    end,
    effectname = "|cFFCC0000黑猫|r",
    effecttext = "|cFFCC0000唯一\n【阶级】1\n【所属】神秘庭院\n【效果】\n[神秘庭院]提升1员工上限\n【额外】\n可获取传奇池中加入[见习死神]|r",
    effectart = "Mwx_Waiyu_Heimao_7"
  },
  {
    name = "尤格索托斯",
    weight = 100,
    lv = 3,
    key = {"外域", "唯一"},
    unique = true,
    seckey = keystring,
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
      u:setdata("变异判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      SendMsgAll(u:getplayername() .. "|cFFCC99FF被|r|cFFC390FF尤|r|cFFB986FF格|r|cFFB07DFF.|r|cFFA774FF索|r|cFF9E6BFF托|r|cFF9461FF斯|r|cFF8B58FF祝|r|cFF824FFF福|r|cFF7946FF了|r")
      Weiyi_New[9] = true
      u:adddivinity(2)
      ChangeValue(Correction_Exp, sy, 0.1)
      local cs = 0
      local gl = 0
      ac.loop(1000, function()
        cs = cs + 1
        if cs == 2 then
          cs = 0
          if u:getdata("尤格索托斯-聚合时空伤害") < 10 then
            u:changedata("尤格索托斯-聚合时空伤害", 2)
            if u:hasdata("妖梦皮肤-渎白之渊") then
              ChangeValue(Correction_Jzsh, sy, 0.2)
            end
          end
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -gl)
        gl = Correction_Exp[sy] - 1
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * gl)
      end)
      if u:hasdata("妖梦皮肤-渎白之渊") then
        u:setdata("尤格索托斯-多段伤害")
        ChangeValue(DamageSplit_CountJzHit, sy, 2)
        u:addstexiao(var.name, "近战伤害效果", function(args)
          local tg = args.tg
          local u = args.u
          local info = args.damageinfo
          if not info.isvestdamage then
            info.element = "心灵"
            if u:getdata("尤格索托斯-聚合时空伤害") > 0 then
              ChangeValue(Correction_Jzsh, sy, 0.1 * -u:getdata("尤格索托斯-聚合时空伤害"))
              u:setdata("尤格索托斯-聚合时空伤害", 0)
            end
          end
        end)
        ac.wait(100, function()
          u:uivar_change({
            keyname = "尤格索托斯",
            keytype = "冥王栏",
            text = "|cFF6633FF尤|r|cFF7549FF格|r|cFF835FFF.|r|cFF9275FF索|r|cFFA08AFF托|r|cFFAFA0FF斯|r\n|cFF6633FF外域 唯一\n三阶\n神性 2\n超越者|r\n|cFFAFA0FF不消耗精神承载力\n免疫外域注视负面\n提升10%经验获取\n提升[1*额外经验获取率]伤害加成\n提升1%剑气值恢复\n提升[200*等级]近战基础伤害|r\n|cFF6633FF聚合时空|r\n|cFFAFA0FF每2秒提升20%近战伤害,上限5次,直至下一次近战直接伤害|r\n|cFF6633FF门之主|r\n|cFFAFA0FF近战直接伤害造成心灵伤害\n近战伤害段数+2\n心灵伤害4%直接斩杀普通单位\n对混乱中单位提升20%伤害|r",
            icon = "NewIcon_Ppq",
            ishasphoto = true
          })
        end)
      else
        ac.wait(100, function()
          u:uivar_change({
            keyname = "尤格索托斯",
            keytype = "冥王栏",
            ishasphoto = true
          })
        end)
      end
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:hasbuff("混乱") then
          info.end2 = info.end2 + 0.12
        end
      end)
      u:addstexiao(var.name, "伤害判定后效果", function(args)
        local info = args.damageinfo
        local tg = args.tg
        if info.element == "心灵" and tg:isnormal() and u:getluckrandom(4) then
          tg:kill(u.handle)
        end
      end)
    end,
    effectname = "|cFF6633FF尤|r|cFF7549FF格|r|cFF835FFF.|r|cFF9275FF索|r|cFFA08AFF托|r|cFFAFA0FF斯|r",
    effecttext = "|cFF6633FF外域 唯一\n三阶\n神性 2\n超越者|r\n|cFFAFA0FF不消耗精神承载力\n免疫外域注视负面\n提升10%经验获取\n提升[1*额外经验获取率]伤害加成|r\n|cFF6633FF聚合时空|r\n|cFFAFA0FF每2秒提升20%枪械基础伤害,上限5次,直至下一次射击|r\n|cFF6633FF门之主|r\n|cFFAFA0FF枪械伤害造成心灵伤害\n子弹穿透次数+2\n心灵伤害4%直接斩杀普通单位\n对混乱中单位提升12%伤害|r",
    effectart = "NewIcon_Ppq"
  }
}
local addwzg = {
  10,
  20,
  40,
  80
}

local function addwz(u, add)
  if not u:hasdata("外域物质文本显示中") then
    local wz = u:getdata("庭院之门-外域物质")
    u:setdata("外域物质文本显示中")
    ac.wait(100, function()
      u:deldata("外域物质文本显示中")
      local change = u:getdata("庭院之门-外域物质") - wz
      u:sendmessage("|cFF9999FF[庭院之门]获得" .. change .. "点外域物质与" .. change * 4 .. "积分(当前" .. u:getdata("庭院之门-外域物质") .. "点)")
    end)
  end
  u:changedata("庭院之门-外域物质", add)
  u:addgold(4 * add)
end

local function flashvartext(u, var)
  local str = var.effectname .. "\n" .. var.effecttext .. "\n【收割概率】" .. u:getdata("庭院之门-" .. var.name .. "收割概率") .. "%(+" .. u:getdata("庭院之门-" .. var.name .. "收割概率提升") .. "%每波)" .. "\n【反抗概率】" .. u:getdata("庭院之门-" .. var.name .. "反抗概率") .. "%"
  u:uivar_change({
    keyname = var.name,
    keytype = "冥王栏",
    text = str
  })
end

local function tingyuanremove(u, var)
  u:changedata("神秘庭院-住客数量", -1)
  u:deldata("变异判定-" .. var.name)
  u:deldata("庭院之门-" .. var.name .. "收割概率")
  u:deldata("庭院之门-" .. var.name .. "收割概率提升")
  u:deldata("庭院之门-" .. var.name .. "反抗概率")
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

local function shougepanding(u, var, gladd)
  gladd = gladd or 0
  local name = "庭院之门-" .. var.name
  local fkgl = u:getdata(name .. "反抗概率")
  local sggl = u:getdata(name .. "收割概率") + gladd
  if u:hasdata("物品-罪之镰") then
    sggl = sggl + 5
  end
  local str = "失败"
  if GetRandom100(fkgl) then
    str = "反抗"
    if var.fankangfunc then
      var.fankangfunc(u, var)
    else
      u:changedata("庭院之门-" .. var.name .. "收割概率", 10)
      if u:getdata("庭院之门-" .. var.name .. "收割概率") >= 100 then
        u:setdata("庭院之门-" .. var.name .. "收割概率", 100)
      end
      if 0 > u:getdata("庭院之门-" .. var.name .. "收割概率") then
        u:setdata("庭院之门-" .. var.name .. "收割概率", 0)
      end
    end
    flashvartext(u, var)
    u:changedata("庭院之门统计-交流次数", 1)
  elseif GetRandom100(sggl) then
    str = "成功"
    if var.shougefunc then
      var.shougefunc(u, var)
    else
      addwz(u, addwzg[var.lv])
    end
    if var.removefunc then
      var.removefunc(u, var)
    else
      tingyuanremove(u, var)
    end
    u:changedata("神秘庭院-阴间住客数量", 1)
    u:changedata("庭院之门统计-好评数", 1)
    if u:hasdata("变异判定-死神契约") then
      u:changedata("小死神-灵魂计数", 75)
      u:sendmessage("|cFFCC0000[死神契约]提升75灵魂计数")
    end
  else
    if var.failfunc then
      var.failfunc(u, var)
    end
    u:changedata("庭院之门-" .. var.name .. "收割概率", 10)
    if u:getdata("庭院之门-" .. var.name .. "收割概率") >= 100 then
      u:setdata("庭院之门-" .. var.name .. "收割概率", 100)
    end
    if 0 > u:getdata("庭院之门-" .. var.name .. "收割概率") then
      u:setdata("庭院之门-" .. var.name .. "收割概率", 0)
    end
  end
  return str
end

function TingyuanShouge(u)
  local fail = {}
  local nameall = ""
  local nameall2 = ""
  local count = 0
  local count2 = 0
  for index, var in ipairs(Vars_Mwx_TyzmNew) do
    if u:hasdata("变异判定-" .. var.name) then
      if var.zhudongshouge then
        u:changedata("庭院之门-" .. var.name .. "收割概率", u:getdata("庭院之门-" .. var.name .. "收割概率提升"))
        flashvartext(u, var)
      else
        local str = shougepanding(u, var)
        if str == "失败" then
          u:changedata("庭院之门-" .. var.name .. "收割概率", u:getdata("庭院之门-" .. var.name .. "收割概率提升"))
          flashvartext(u, var)
        end
        if str == "成功" then
          count = count + 1
          nameall = nameall .. var.name .. "、"
        end
        if str == "反抗" then
          count2 = count2 + 1
          nameall2 = nameall2 .. var.name .. "、"
        end
      end
    end
  end
  if count2 ~= 0 then
    u:sendmessage("|cFF9999FF[庭院之门]昨晚反抗的住客:" .. (nameall2:gsub("、$", "")))
  end
  if count ~= 0 then
    u:sendmessage("|cFF9999FF[庭院之门]天亮了，昨晚" .. (nameall:gsub("、$", "")) .. " 被杀害了！")
  else
    u:sendmessage("|cFF9999FF[庭院之门]天亮了，昨晚是平安夜")
  end
end

local function tingyuanzhudongshouge(u, var)
  if u:getdata("庭院之门-主动收割次数") <= 0 then
    u:sendmessage("|cFFCC0000[庭院之门]主动收割次数不足|r")
    return
  end
  u:changedata("庭院之门-主动收割次数", -1)
  local add = 15
  if u:hasdata("变异判定-死神契约") then
    add = add + 5
  end
  if u:hasdata("变异判定-犹格庭院") then
    add = add + 10
  end
  local jg = shougepanding(u, var, add)
  if jg == "反抗" then
    u:sendmessage("|cFFCC0000[庭院之门]住客反抗激烈,收割" .. var.name .. "失败,提升下一次收割概率|r")
  elseif jg == "成功" then
    u:sendmessage("|cFFCC0000[庭院之门]收割" .. var.name .. "成功|r")
  else
    u:sendmessage("|cFFCC0000[庭院之门]收割" .. var.name .. "失败(" .. u:getdata("庭院之门-" .. var.name .. "收割概率") + add .. "%成功率)|r")
  end
end

local function tingyuantongyong(u, var)
  MwxTongyong(u, var)
  u:changedata("神秘庭院-住客数量", 1)
  local lv = var.lv
  local jcshouge = var.jcshouge or 40 - 8 * var.lv
  local jcshougeadd = var.jcshougeadd or 25 - 5 * var.lv
  local jcfail = var.jcfail or 5 * var.lv - 3
  if not (lv <= 2) or var.jcshouge then
  else
    jcshouge = 100
  end
  u:setdata("庭院之门-" .. var.name .. "收割概率", jcshouge)
  u:setdata("庭院之门-" .. var.name .. "收割概率提升", jcshougeadd)
  u:setdata("庭院之门-" .. var.name .. "反抗概率", jcfail)
  ac.wait(100, function()
    flashvartext(u, var)
  end)
end

Vars_Mwx_TyzmNew = {
  {
    name = "拜亚基",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"外域"},
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
      tingyuantongyong(u, var)
      ChangeValue(DamageSystem_Shjc, sy, 0.01)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      ChangeValue(DamageSystem_Shjc, sy, -0.01)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      ChangeValue(DamageSystem_Shjc, sy, 0.003)
      u:changedata("外域变异数量", 1)
    end,
    fankangfunc = function(u, var)
      local sy = u.ownerid
      local down = 10 * (var.lv or 1)
      u:changedata("庭院之门-" .. var.name .. "收割概率", -down)
      if u:getdata("庭院之门-" .. var.name .. "收割概率") < 0 then
        u:setdata("庭院之门-" .. var.name .. "收割概率", 0)
      end
    end,
    effectname = "|cFF339999拜亚基|r",
    effecttext = "|cFF339999外域\n【阶级】1\n【所属】神秘庭院\n【住客效果】\n提升1%伤害加成\n【收割效果】\n提升1外域词条\n提升0.3%伤害加成\n获得10外域物质",
    effectart = "Mwx_Tingyuanzhimen_07_1"
  },
  {
    name = "钻地魔虫",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"外域", "土"},
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
      tingyuantongyong(u, var)
      ChangeValue(Correction_Exp, sy, 0.15)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      ChangeValue(Correction_Exp, sy, -0.15)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      u:addexp(250)
      u:changedata("土变异数量", 1)
    end,
    effectname = "|cFF339999钻地魔虫|r",
    effecttext = "|cFF339999外域 土\n【阶级】1\n【所属】神秘庭院\n【住客效果】\n提升15%经验获取\n【收割效果】\n提升1土词条\n获得10外域物质\n获得250经验值",
    effectart = "Mwx_Tingyuanzhimen_06_1"
  },
  {
    name = "黑山羊幼仔",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"外域"},
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
      tingyuantongyong(u, var)
      u:changemaxhp(1000)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      u:changemaxhp(-1000)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      u:changemaxhp(250)
      u:changedata("外域变异数量", 1)
    end,
    effectname = "|cFF339999黑山羊幼仔|r",
    effecttext = "|cFF339999外域\n【阶级】1\n【所属】神秘庭院\n【住客效果】\n提升1000生命上限\n【收割效果】\n提升1外域词条\n获得10外域物质\n提升250生命上限",
    effectart = "Mwx_Tingyuanzhimen_04_1"
  },
  {
    name = "深潜者",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"外域", "水"},
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
      tingyuantongyong(u, var)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -25)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 5)
      u:changedata("水变异数量", 1)
    end,
    effectname = "|cFF339999深潜者|r",
    effecttext = "|cFF339999外域 水\n【阶级】1\n【所属】神秘庭院\n【住客效果】\n提升25额外移速\n【收割效果】\n提升1水词条\n提升5额外移速\n获得10外域物质",
    effectart = "Mwx_Tingyuanzhimen_03_1"
  },
  {
    name = "庭院僵尸",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"外域", "不死"},
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
      tingyuantongyong(u, var)
      ChangeValue(Hudun_Max, sy, 1000)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      ChangeValue(Hudun_Max, sy, -1000)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      ChangeValue(Hudun_Max, sy, 100)
      u:changedata("不死变异数量", 1)
    end,
    effectname = "|cFF339999僵尸|r",
    effecttext = "|cFF339999外域 不死\n【阶级】1\n【所属】神秘庭院\n【住客效果】\n提升1000护盾上限\n【收割效果】\n提升1不死词条\n获得10外域物质\n提升100护盾上限",
    effectart = "Tlbk_Jiangshi"
  },
  {
    name = "空鬼",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"外域"},
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
      tingyuantongyong(u, var)
      u:changedata("系统-飞行强度", 50)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      u:changedata("系统-飞行强度", -50)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      u:changedata("系统-飞行强度", 5)
      u:changedata("外域变异数量", 1)
    end,
    effectname = "|cFF339999空鬼|r",
    effecttext = "|cFF339999外域\n【阶级】1\n【所属】神秘庭院\n【住客效果】\n提升50飞行强度\n【收割效果】\n获得10外域物质\n提升1外域词条\n提升5飞行强度",
    effectart = "Mwx_Tingyuanzhimen_02_1"
  },
  {
    name = "炎之精",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"外域", "炎"},
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
      tingyuantongyong(u, var)
      ChangeValue(Damage_Element_Fire, sy, 0.04)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      ChangeValue(Damage_Element_Fire, sy, -0.04)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      ChangeValue(Damage_Element_Fire, sy, 0.01)
      u:changedata("炎变异数量", 1)
    end,
    effectname = "|cFF339999炎之精|r",
    effecttext = "|cFF339999外域 炎\n【阶级】1\n【所属】神秘庭院\n【住客效果】\n提升4%火属性伤害\n【收割效果】\n提升1炎词条\n获得10外域物质\n提升1%火属性伤害",
    effectart = "Mwx_Tingyuanzhimen_08_7"
  },
  {
    name = "冰元素",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"外域", "冰"},
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
      tingyuantongyong(u, var)
      ChangeValue(Damage_Element_Ice, sy, 0.04)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      ChangeValue(Damage_Element_Ice, sy, -0.04)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      ChangeValue(Damage_Element_Ice, sy, 0.01)
      u:changedata("冰变异数量", 1)
    end,
    effectname = "|cFF339999冰元素|r",
    effecttext = "|cFF339999外域 冰\n【阶级】1\n【所属】神秘庭院\n【住客效果】\n提升4%冰属性伤害\n【收割效果】\n获得10外域物质\n提升1冰词条\n提升1%冰属性伤害",
    effectart = "Tlbk_Bingyuansu"
  },
  {
    name = "风元素",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"外域", "风"},
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
      tingyuantongyong(u, var)
      ChangeValue(Damage_Element_Wind, sy, 0.04)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      ChangeValue(Damage_Element_Wind, sy, -0.04)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      ChangeValue(Damage_Element_Wind, sy, 0.01)
      u:changedata("风变异数量", 1)
    end,
    effectname = "|cFF339999风元素|r",
    effecttext = "|cFF339999外域 风\n【阶级】1\n【所属】神秘庭院\n【住客效果】\n提升4%风属性伤害\n【收割效果】\n获得10外域物质\n提升1风词条\n提升1%风属性伤害",
    effectart = "Tlbk_Fengyuansu"
  },
  {
    name = "雷元素",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"外域", "雷"},
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
      tingyuantongyong(u, var)
      ChangeValue(Damage_Element_Thunder, sy, 0.04)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      ChangeValue(Damage_Element_Thunder, sy, -0.04)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      ChangeValue(Damage_Element_Thunder, sy, 0.01)
      u:changedata("雷变异数量", 1)
    end,
    effectname = "|cFF339999雷元素|r",
    effecttext = "|cFF339999外域 雷\n【阶级】1\n【所属】神秘庭院\n【住客效果】\n提升4%雷属性伤害\n【收割效果】\n获得10外域物质\n提升1雷词条\n提升1%雷属性伤害",
    effectart = "Tlbk_Leiyuansu"
  },
  {
    name = "水元素",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"外域", "水"},
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
      tingyuantongyong(u, var)
      ChangeValue(Damage_Element_Water, sy, 0.04)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      ChangeValue(Damage_Element_Water, sy, -0.04)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      ChangeValue(Damage_Element_Water, sy, 0.01)
      u:changedata("水变异数量", 1)
    end,
    effectname = "|cFF339999水元素|r",
    effecttext = "|cFF339999外域 水\n【阶级】1\n【所属】神秘庭院\n【住客效果】\n提升4%水属性伤害\n【收割效果】\n获得10外域物质\n提升1水词条\n提升1%水属性伤害",
    effectart = "Tlbk_Shuiyuansu"
  },
  {
    name = "土元素",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {"外域", "土"},
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
      tingyuantongyong(u, var)
      ChangeValue(Damage_Element_Earth, sy, 0.04)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      ChangeValue(Damage_Element_Earth, sy, -0.04)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      ChangeValue(Damage_Element_Earth, sy, 0.01)
      u:changedata("土变异数量", 1)
    end,
    effectname = "|cFF339999土元素|r",
    effecttext = "|cFF339999外域 土\n【阶级】1\n【所属】神秘庭院\n【住客效果】\n提升4%土属性伤害\n【收割效果】\n获得10外域物质\n提升1土词条\n提升1%土属性伤害",
    effectart = "Tlbk_Tuyuansu"
  },
  {
    name = "古老者",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 25,
    lv = 1,
    key = {"外域", "根源"},
    unique = false,
    zhudongshouge = true,
    jcfail = 15,
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
      tingyuantongyong(u, var)
      ChangeValue(Correction_Exp, sy, 0.25)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      ChangeValue(Correction_Exp, sy, -0.25)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      u:addlevel(1)
      u:changedata("根源变异数量", 1)
    end,
    fankangfunc = function(u, var)
      local sy = u.ownerid
      local down = 10 * (var.lv or 1)
      u:changedata("庭院之门-" .. var.name .. "收割概率", -down)
      if u:getdata("庭院之门-" .. var.name .. "收割概率") < 0 then
        u:setdata("庭院之门-" .. var.name .. "收割概率", 0)
      end
      ChangeValue(DamageSystem_Shjc, sy, -0.005)
      ChangeValue(Correction_Exp, sy, -0.05)
    end,
    effectname = "|cFF339999古老者|r",
    effecttext = "|cFF339999外域 根源\n【阶级】1\n【所属】神秘庭院\n【住客效果】\n提升25%经验获取\n反抗时永久降低0.5%伤害加成与5%经验获取\n【收割效果】(只能主动收割)\n提升1级英雄等级\n获得10外域物质\n提升1根源词条",
    effectart = "Mwx_Tingyuanzhimen_01_1"
  },
  {
    name = "庭院住客1",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {},
    unique = false,
    jcfail = 1,
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
      tingyuantongyong(u, var)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      u:addwood(10)
      u:addgold(200)
    end,
    effectname = "|cFF339999庭院住客|r",
    effecttext = "|cFF339999【阶级】1\n【所属】神秘庭院\n【住客效果】\n纯饭桶,被收割概率大幅提升\n【收割效果】\n获得200积分与10追忆值",
    effectart = "Tlbk_Tyzk.tga"
  },
  {
    name = "庭院住客2",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {},
    unique = false,
    jcfail = 1,
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
      tingyuantongyong(u, var)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      u:addwood(10)
      u:addgold(200)
    end,
    effectname = "|cFF339999庭院住客|r",
    effecttext = "|cFF339999【阶级】1\n【所属】神秘庭院\n【住客效果】\n纯饭桶,被收割概率大幅提升\n【收割效果】\n获得200积分与10追忆值",
    effectart = "Tlbk_Tyzk2.tga"
  },
  {
    name = "庭院住客3",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {},
    unique = false,
    jcfail = 1,
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
      tingyuantongyong(u, var)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      u:addwood(10)
      u:addgold(200)
    end,
    effectname = "|cFF339999庭院住客|r",
    effecttext = "|cFF339999【阶级】1\n【所属】神秘庭院\n【住客效果】\n纯饭桶,被收割概率大幅提升\n【收割效果】\n获得200积分与10追忆值",
    effectart = "Tlbk_Tyzk3.tga"
  },
  {
    name = "庭院住客4",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {},
    unique = false,
    jcfail = 1,
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
      tingyuantongyong(u, var)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      u:addwood(10)
      u:addgold(200)
    end,
    effectname = "|cFF339999庭院住客|r",
    effecttext = "|cFF339999【阶级】1\n【所属】神秘庭院\n【住客效果】\n纯饭桶,被收割概率大幅提升\n【收割效果】\n获得200积分与10追忆值",
    effectart = "Tlbk_Tyzk4.tga"
  },
  {
    name = "社畜",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {},
    unique = false,
    jcfail = 0,
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
      tingyuantongyong(u, var)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      u:addwood(20)
      u:addgold(50)
    end,
    effectname = "|cFF339999社畜|r",
    effecttext = "|cFF339999【阶级】1\n【所属】神秘庭院\n【住客效果】\n纯牛马,被收割概率大幅提升\n【收割效果】\n获得50积分与20追忆值",
    effectart = "Tlbk_Shechu.tga"
  },
  {
    name = "植物收藏家",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
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
      tingyuantongyong(u, var)
      u:addstexiao(var.name, "过波时效果", function(args)
        if u:hasdata("变异判定-" .. var.name) then
          local itemz = {
            "I0GW",
            "I0A2",
            "I07D",
            "I0AG"
          }
          for i = 1, 2 do
            u:additem(itemz[GetRandomInt(1, #itemz)])
          end
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      u:addwood(10)
      u:addgold(150)
      local itemz = {
        "I0GW",
        "I0A2",
        "I07D",
        "I0AG"
      }
      for i = 1, 5 do
        u:additem(itemz[GetRandomInt(1, #itemz)])
      end
    end,
    effectname = "|cFF339999植物收藏家|r",
    effecttext = "|cFF339999【阶级】1\n【所属】神秘庭院\n【住客效果】\n过波时获得两株植物\n【收割效果】\n获得五株植物\n获得150积分与10追忆值",
    effectart = "Tlbk_Zwscj.tga"
  },
  {
    name = "清洁大师",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {},
    unique = false,
    zhudongshouge = true,
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
      tingyuantongyong(u, var)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      u:addwood(10)
      u:addgold(150)
    end,
    effectname = "|cFF339999清扫大师|r",
    effecttext = "|cFF339999【阶级】1\n【所属】神秘庭院\n【住客效果】\n[高效利用]效果提升[10*已被收割住客数量]\n【收割效果】(只能主动收割)\n获得150积分与10追忆值",
    effectart = "Tlbk_Qingsaodashi.tga"
  },
  {
    name = "富豪",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 1,
    key = {},
    unique = false,
    zhudongshouge = true,
    jcshouge = 40,
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
      tingyuantongyong(u, var)
      u:addstexiao(var.name, "过波时效果", function(args)
        if u:hasdata("变异判定-" .. var.name) then
          u:sendmessage("|cFF339999[富豪]获得100积分")
          u:addgold(100)
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      u:addwood(20)
      u:addgold(GetRandomInt(400, 800))
    end,
    failfunc = function(u, var)
      local sy = u.ownerid
      u:sendmessage("|cFF339999[富豪]逃跑了……")
      u:changedata("庭院之门统计-差评数", 1)
      tingyuanremove(u, var)
    end,
    effectname = "|cFF339999富豪|r",
    effecttext = "|cFF339999【阶级】1\n【所属】神秘庭院\n【住客效果】\n过波时获得100积分\n收割失败时会逃跑\n【收割效果】(只能主动收割)\n获得400~800积分与20追忆值",
    effectart = "Tlbk_Fuhao.tga"
  },
  {
    name = "宝箱怪",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 30,
    lv = 2,
    key = {"外域"},
    unique = false,
    zhudongshouge = true,
    jcshouge = 10,
    jcshougeadd = 10,
    jcfail = 0,
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
      tingyuantongyong(u, var)
      u:addstexiao(var.name, "过波时效果", function(args)
        if u:hasdata("变异判定-" .. var.name) then
          u:sendmessage("|cFF339999[宝箱怪]吞噬100积分")
          u:addgold(-100)
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      u:addwood(100)
      u:addgold(1000)
    end,
    failfunc = function(u, var)
      local sy = u.ownerid
      u:sendmessage("|cFF339999[宝箱怪]逃跑了……")
      u:changedata("庭院之门统计-差评数", 1)
      tingyuanremove(u, var)
    end,
    effectname = "|cFF339999宝箱怪|r",
    effecttext = "|cFF339999【阶级】2\n【所属】神秘庭院\n【住客效果】\n过波时吞噬100积分\n收割失败时会逃跑\n【收割效果】(只能主动收割)\n获得1000积分与100追忆值",
    effectart = "Weizhitubiao"
  },
  {
    name = "吱吱",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {"外域", "唯一"},
    unique = true,
    jcshouge = 50,
    jcshougeadd = 10,
    jcfail = 25,
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
      tingyuantongyong(u, var)
      u:changeoriginmaxhp(250.0)
      ChangeValue(Hero_Tili_Huifu, sy, 0.1)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      if u:isgirl() then
        u:setdata("庭院之门-" .. var.name .. "收割概率", 0)
        flashvartext(u, var)
      else
        u:changeoriginmaxhp(-250.0)
        ChangeValue(Hero_Tili_Huifu, sy, -0.1)
        tingyuanremove(u, var)
      end
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      u:changemaxhp(1000)
      u:changedata("外域" .. "变异数量", 1)
    end,
    fankangfunc = function(u, var)
      local sy = u.ownerid
      local down = 10 * (var.lv or 1)
      u:changedata("庭院之门-" .. var.name .. "收割概率", -down)
      if u:getdata("庭院之门-" .. var.name .. "收割概率") < 0 then
        u:setdata("庭院之门-" .. var.name .. "收割概率", 0)
      end
      if u:isgirl() then
        u:changemaxhp(500)
        ChangeValue(Hero_Tili_Max, sy, 1)
      else
        u:sendmessage("|cFFCC0000[吱吱]逃跑了……")
        u:changedata("庭院之门统计-差评数", 1)
        tingyuanremove(u, var)
      end
    end,
    effectname = "|cFFCC0000吱|r|cFFC21F1F吱|r",
    effecttext = "|cFFCC0000【阶级】2\n【所属】神秘庭院\n【住客效果】\n提升0.1体力恢复\n提升250基础生命上限\n房东是女性时:\n[免疫注视降低生命上限\n收割时不会消失,而是将收割概率归0\n反抗时提升500生命上限与1点体力上限]\n房东是男性时:\n[反抗时逃跑]\n【收割效果】\n提升1外域词条\n获得20外域物质\n提升1000生命上限",
    effectart = "Mwx_Waiyu_2_07_7"
  },
  {
    name = "幽魂蛾",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {"外域", "灵魂"},
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
      tingyuantongyong(u, var)
      ChangeValue(DamageSystem_Baoji, sy, 10)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      ChangeValue(DamageSystem_Baoji, sy, -10)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      u:addwood(10)
      ChangeValue(DamageSystem_Baoji, sy, 2)
      u:changedata("灵魂变异数量", 1)
    end,
    effectname = "|cFF339999幽魂蛾|r",
    effecttext = "|cFF339999外域 灵魂\n【阶级】2\n【所属】神秘庭院\n【住客效果】\n提升10%暴击率\n【收割效果】\n提升1灵魂词条\n获得20外域物质与10追忆值\n提升2%暴击率",
    effectart = "Tlbk_Youhune"
  },
  {
    name = "月兽",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {"外域", "星"},
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
      tingyuantongyong(u, var)
      ChangeValue(DamageSystem_Baoshang, sy, 0.25)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      ChangeValue(DamageSystem_Baoshang, sy, -0.25)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      u:addwood(10)
      ChangeValue(DamageSystem_Baoshang, sy, 0.04)
      u:changedata("星变异数量", 1)
    end,
    effectname = "|cFF339999月兽|r",
    effecttext = "|cFF339999外域 星\n【阶级】2\n【所属】神秘庭院\n【住客效果】\n提升25%暴击伤害\n【收割效果】\n提升1星词条\n获得20外域物质与10追忆值\n提升4%暴击伤害",
    effectart = "Tlbk_Yueshou"
  },
  {
    name = "廷达罗斯猎犬",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {"外域", "影"},
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
      tingyuantongyong(u, var)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
      u:changedata("系统-飞行强度", 100)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -25)
      u:changedata("系统-飞行强度", -100)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
      u:changedata("系统-飞行强度", 10)
      u:changedata("影变异数量", 1)
    end,
    effectname = "|cFF339999廷达罗斯猎犬|r",
    effecttext = "|cFF339999外域 影\n【阶级】2\n【所属】神秘庭院\n【住客效果】\n提升25额外移速\n提升100飞行强度\n提升[100*飞行强度]固定伤害\n【收割效果】\n提升1影词条\n获得20外域物质\n提升10飞行强度\n提升25额外移速",
    effectart = "Mwx_Waiyu_2_09_1"
  },
  {
    name = "夺心魔",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 100,
    lv = 2,
    key = {"外域"},
    unique = false,
    zhudongshouge = true,
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
      tingyuantongyong(u, var)
      ChangeValue(Damage_Element_Heart, sy, 0.1)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      ChangeValue(Damage_Element_Heart, sy, -0.1)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      ChangeValue(Damage_Element_Heart, sy, 0.02)
      u:changedata("外域变异数量", 1)
    end,
    effectname = "|cFF339999夺心魔|r",
    effecttext = "|cFF339999外域\n【阶级】2\n【所属】神秘庭院\n【住客效果】\n提升10%心灵伤害\n免疫混乱失控\n【收割效果】\n提升1外域词条\n获得20外域物质\n提升2%心灵伤害",
    effectart = "Mwx_Waiyu_2_08_1"
  },
  {
    name = "修格斯",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 25,
    lv = 3,
    key = {"外域"},
    unique = false,
    zhudongshouge = true,
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
      tingyuantongyong(u, var)
      ChangeValue(DamageSystem_Shjc, sy, 0.05)
      ChangeValue(Damage_Element_Heart, sy, 0.1)
      u:changemaxhp(5000)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      ChangeValue(DamageSystem_Shjc, sy, -0.05)
      ChangeValue(Damage_Element_Heart, sy, -0.1)
      u:changemaxhp(-5000)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      u:changemaxhp(1000)
      ChangeValue(DamageSystem_Shjc, sy, 0.01)
      ChangeValue(Damage_Element_Heart, sy, 0.04)
      u:changedata("外域变异数量", 1)
    end,
    fankangfunc = function(u, var)
      local sy = u.ownerid
      u:sendmessage("|cFF9966FF[修格斯]离开了……(降低1精神承载上限)")
      u:changedata("庭院之门统计-差评数", 1)
      u:changedata("系统-启动承载上限", -1)
      tingyuanremove(u, var)
    end,
    effectname = "|cFF9966FF修|r|cFFB28CE6格|r|cFFCCB2CC斯|r",
    effecttext = "|cFF9966FF【阶级】3\n【所属】神秘庭院\n【住客效果】\n提升5%伤害加成\n提升10%心灵伤害\n提升5000生命上限\n反抗时永久降低1启动承载上限并离开\n【收割效果】(只能主动收割)\n获得40外域物质\n提升1外域变异数量\n提升1%伤害加成\n提升4%心灵伤害\n提升1000生命上限",
    effectart = "Tlbk_Xiugesi"
  },
  {
    name = "犹格索托斯投影",
    rightclickfunc = function(u, var)
      tingyuanzhudongshouge(u, var)
    end,
    weight = 10,
    lv = 4,
    key = {"外域"},
    unique = false,
    jcshouge = 2,
    jcshougeadd = 2,
    zhudongshouge = true,
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
      tingyuantongyong(u, var)
      ChangeValue(DamageSystem_Shjc, sy, 0.1)
      ChangeValue(Damage_Element_Heart, sy, 0.25)
      ChangeValue(Correction_Exp, sy, 0.4)
      u:addstexiao(var.name, "过波时效果", function(args)
        if u:hasdata("变异判定-" .. var.name) then
          local sj = GetRandomInt(1, 6)
          if sj == 1 then
            u:sendmessage("|cFF9966FF[犹格索托斯投影]提升1外域变异数量")
            u:changedata("外域变异数量", 1)
          end
          if sj == 2 then
            u:sendmessage("|cFF9966FF[犹格索托斯投影]降低1启动承载上限")
            u:changedata("系统-启动承载上限", -1)
          end
          if sj == 3 then
            u:sendmessage("|cFF9966FF[犹格索托斯投影]降低2启动承载上限")
            u:changedata("系统-启动承载上限", -2)
          end
          if sj == 4 then
            u:sendmessage("|cFF9966FF[犹格索托斯投影]提升1等级")
            u:addlevel(1)
          end
          if sj == 5 then
            u:sendmessage("|cFF9966FF[犹格索托斯投影]降低1等级")
            u:addlevel(-1)
          end
          if sj == 6 then
            u:sendmessage("|cFF9966FF[犹格索托斯投影]提升25%经验获取")
            ChangeValue(Correction_Exp, sy, 0.25)
          end
        end
      end)
      local bs = Stage
      ac.loop(3000, function(timer)
        if not u:hasdata("变异判定-" .. var.name) then
          timer:remove()
        end
        if bs - Stage > 3 then
          tingyuanremove(u, var)
          u:sendmessage("|cFF9966FF[犹格索托斯投影]离开了……")
          timer:remove()
        end
      end)
    end,
    removefunc = function(u, var)
      local sy = u.ownerid
      tingyuanremove(u, var)
      ChangeValue(DamageSystem_Shjc, sy, -0.1)
      ChangeValue(Damage_Element_Heart, sy, -0.25)
      ChangeValue(Correction_Exp, sy, -0.4)
    end,
    shougefunc = function(u, var)
      local sy = u.ownerid
      addwz(u, addwzg[var.lv])
      u:adddivinity(1)
      u:changedata("系统-神力承载上限", 1)
      u:changedata("系统-启动承载上限", 1)
      ChangeValue(DamageSystem_Shjc, sy, 0.025)
      ChangeValue(Damage_Element_Heart, sy, 0.05)
      u:changedata("外域变异数量", 2)
    end,
    fankangfunc = function(u, var)
      local sy = u.ownerid
      u:sendmessage("|cFF9966FF[犹格索托斯投影]离开了……(降低1启动承载上限)")
      u:changedata("庭院之门统计-差评数", 1)
      u:changedata("系统-启动承载上限", -1)
      u:kill()
      tingyuanremove(u, var)
    end,
    effectname = "|cFF9966FF犹|r|cFF9C6FFB格|r|cFFA078F8索|r|cFFA381F4托|r|cFFA68AF0斯|r|cFFAA93ED投|r|cFFAD9CE9影|r",
    effecttext = "|cFF9966FF【阶级】4\n【所属】神秘庭院\n【住客效果】\n提升10%伤害加成\n提升25%心灵伤害\n提升40%经验获取\n反抗时降低1启动承载上限,使房东死亡并离开\n入住累积三回合时离开\n过波时触发以下一种效果:\n[1.提升1外域变异数量\n2.降低1精神负载\n3.降低2精神负载\n4.提升1等级\n5.降低1等级\n6.提升25%经验获取]\n【收割效果】(只能主动收割)\n获得80外域物质\n提升1神性\n提升1神力承载\n提升1精神承载\n提升2外域词条\n提升2.5%伤害加成\n提升5%心灵伤害",
    effectart = "Tlbk_Yougesuotuositouying"
  }
}
if false then
  Vars_Mwx_Tingyuanzhimen_Lv1 = {}
  Vars_Mwx_Tingyuanzhimen_Lv2 = {
    {
      name = "阿撒托斯之核",
      weight = 100,
      lv = 2,
      key = {"外域", "唯一"},
      unique = true,
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
        u:sendmessage("|cFF6633FF获得" .. var.name .. "|r")
        ChangeValue(Correction_Exp, sy, 0.05)
        AddUISkill({
          text = "阿撒托斯之核",
          u = u,
          cd = 3,
          icon = "Mwx_Waiyu_2_04_13.tga",
          func = function(args)
            local u = args.u
            if u:isalive() and not u:hasdata("阿撒托斯之核-激活中") then
              if not u:hasdata("阿撒托斯之核-腐蚀中") then
                u:setdata("阿撒托斯之核-腐蚀中")
                u:changedata("闪避值", -50)
                u:setdata("阿撒托斯之核-激活时间", 0)
                u:sendmessage("|cFF6633FF阿撒托斯之核-腐蚀中|r")
                local x, y = u:getxy()
                ac.loop(1000, function(timer)
                  local x2, y2 = u:getxy()
                  local dis = DistanceXY(x, y, x2, y2)
                  local dehp = (0.025 + 0.025 * dis / 1000) * u:gethp() + 0.01 * u:getmaxhp()
                  local b = true
                  if dehp >= u:gethp() then
                    b = false
                  end
                  u:losshp(u, dehp)
                  x, y = u:getxy()
                  u:changedata("阿撒托斯之核-激活时间", 1)
                  if not (b and u:isalive()) or not u:hasdata("阿撒托斯之核-腐蚀中") then
                    if u:hasdata("阿撒托斯之核-腐蚀中") then
                      u:deldata("阿撒托斯之核-腐蚀中")
                      u:changedata("闪避值", 50)
                      if u:getdata("阿撒托斯之核-激活时间") > 0 then
                        local t = 0.8 * u:getdata("阿撒托斯之核-激活时间")
                        if 30 <= t then
                          t = 30
                        end
                        u:sendmessage("|cFF6633FF阿撒托斯之核-激活:" .. math.floor(t) .. "秒|r")
                        u:setdata("阿撒托斯之核-激活时间", 0)
                        u:settimedata("阿撒托斯之核-激活中", t)
                        ChangeTimeValue(DamageSystem_Shjc, sy, 0.1, t)
                        ChangeTimeValue(DamageSystem_Baoji, sy, 40, t)
                        u:addskill("S0B8")
                        ac.wait(t * 1000, function()
                          u:delskill("S0B8")
                        end)
                      end
                    end
                    timer:remove()
                  end
                end)
              else
                u:deldata("阿撒托斯之核-腐蚀中")
              end
            end
          end
        })
      end,
      effectname = "|cFF6633FF阿撒托斯之核|r",
      effecttext = "|cFF6633FF二阶\n外域 唯一|r\n|cFF9999FF提升5%经验获取|r\n|cFF6633FF沸腾腐蚀|r\n|cFF9999FF激活后:\n【每秒损失[2.5%当前生命+1%最大生命],每位移1000码额外损耗2.5%当前生命值\n降低50闪避值\n降低50%护盾恢复速度】|r\n|cFF6633FF混沌狂热|r\n|cFF9999FF取消激活后,根据激活时间的80%(至多30秒),在持续时间内:\n【提升10%伤害加成\n提升40%暴击率\n提升25%移速】|r",
      effectart = "Mwx_Waiyu_2_04_13"
    },
    {
      name = "幻梦境之客",
      weight = 100,
      lv = 2,
      key = {"外域", "唯一"},
      unique = true,
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
        u:sendmessage("|cFF6633FF获得" .. var.name .. "|r")
        ChangeValue(Correction_Exp, sy, 0.05)
        ChangeValue(DamageSystem_Shjc, sy, 0.04)
        local add = 0
        ac.loop(3000, function()
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
          add = 0.05 * u:getstate("外域变异")
          if 0.75 <= add then
            add = 0.75
          end
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        end)
        u:addstexiao(var.name, "伤害判定前效果", function(args)
          local u = args.u
          local tg = args.tg
          if not tg:hasdata("幻梦境之客-造梦境") then
            tg:settimedata("幻梦境之客-造梦境", 0.1)
          end
        end)
      end,
      effectname = "|cFF6633FF幻梦境之客|r",
      effecttext = "|cFF6633FF二阶\n外域 唯一|r\n|cFF9999FF提升5%经验获取|r\n|cFF6633FF造梦者|r\n|cFF9999FF视为伤害目标永远处于以下符合的负面状态中:\n【僵直,眩晕,混乱,暂停】|r\n|cFF6633FF不可名状深渊|r\n|cFF9999FF提升4%伤害加成\n提升[0.5%*外域变异]伤害加成(上限75%)|r",
      effectart = "Mwx_Waiyu_2_03_13"
    },
    {
      name = "奈亚拉幻形",
      weight = 100,
      lv = 2,
      key = {"外域", "唯一"},
      unique = true,
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
        u:sendmessage("|cFF99FFFF获得" .. var.name .. "|r")
        ChangeValue(Correction_Exp, sy, 0.05)
        ChangeValue(DamageSystem_Shjc, sy, 0.04)
        u:setdata("奈亚拉幻形词条", "外域")
        u:setdata("奈亚拉幻形词条计数", 1)
        u:addstexiao(var.name, "直接伤害特效", function(args)
          local tg = args.tg
          local u = args.u
          local info = args.damageinfo
          if not tg:hasdata(var.name .. "-特效冷却") and u:getluckrandom(5 * info.txgl) then
            tg:settimedata(var.name .. "-特效冷却", 10)
            local lx = {
              "僵直",
              "混乱",
              "眩晕"
            }
            local sxlx = lx[GetRandomInt(1, #lx)]
            tg:buffset(u.handle, 3, sxlx)
          end
        end)
        u:addstexiao(var.name, "受伤后效果", function(args)
          local sh = args.damage
          local tg = args.tg
          local u = args.u
          if 10 <= sh and not tg:hasdata(var.name .. "-特效冷却") and u:getluckrandom(50) then
            tg:settimedata(var.name .. "-特效冷却", 10)
            local lx = {
              "僵直",
              "混乱",
              "眩晕"
            }
            local sxlx = lx[GetRandomInt(1, #lx)]
            tg:buffset(u.handle, 3, sxlx)
          end
        end)
      end,
      clickfunc = function(u, ewl)
        local sy = u.ownerid
        local zu = {
          "外域",
          "光明",
          "黑暗",
          "水",
          "炎",
          "冰",
          "雷",
          "影",
          "兽",
          "机械",
          "恶魔",
          "吸血鬼",
          "战士",
          "魔导",
          "同奏"
        }
        local str = u:getdata("奈亚拉幻形词条")
        u:changedata(str .. "变异数量", -1)
        u:changedata("奈亚拉幻形词条计数", 1)
        if u:getdata("奈亚拉幻形词条计数") > #zu then
          u:setdata("奈亚拉幻形词条计数", 1)
        end
        u:setdata("奈亚拉幻形词条", zu[u:getdata("奈亚拉幻形词条计数")])
        str = u:getdata("奈亚拉幻形词条")
        u:changedata(str .. "变异数量", 1)
        u:uivar_change({
          keyname = "奈亚拉幻形",
          keytype = "冥王栏",
          text = "|cFF99FFFF奈亚拉幻形|r\n|cFF99FFFF二阶\n" .. str .. " 唯一|r\n|cFFCCFFFF提升5%经验获取|r\n|cFF99FFFF伏行之混沌|r\n|cFFCCFFFF提升4%伤害加成\n点击切换,将该变异的词条从外域转换为任意其他通用词条|r\n|cFF99FFFF真实之貌|r\n|cFFCCFFFF直接伤害(5%)或受到伤害(50%)时,对目标施加以下一种负面状态3秒,独立冷却10秒:\n【僵直,眩晕,混乱】|r"
        })
      end,
      effectname = "|cFF99FFFF奈亚拉幻形|r",
      effecttext = "|cFF99FFFF二阶\n外域 唯一|r\n|cFFCCFFFF提升5%经验获取|r\n|cFF99FFFF伏行之混沌|r\n|cFFCCFFFF提升4%伤害加成\n点击切换,将该变异的词条从外域转换为任意其他通用词条|r\n|cFF99FFFF真实之貌|r\n|cFFCCFFFF直接伤害(5%)或受到伤害(50%)时,对目标施加以下一种负面状态3秒,独立冷却10秒:\n【僵直,眩晕,混乱】|r",
      effectart = "Mwx_Waiyu_2_01_11"
    },
    {
      name = "银之键",
      weight = 100,
      lv = 2,
      key = {"外域", "唯一"},
      unique = true,
      addweight = function(u, var)
        local add = 0
        if u:hasdata("妖梦皮肤-渎白之渊") then
          add = add + 300
        end
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
        u:sendmessage("|cFF6633FF获得" .. var.name .. "|r")
        ChangeValue(Correction_Exp, sy, 0.05)
        ChangeValue(DamageSystem_Baoji, sy, 5)
        ChangeValue(Correction_RPM, sy, 0.3)
        ChangeValue(Damage_Element_Heart, sy, 0.1)
        ChangeValue(Correction_Unify, sy, 0.3)
        AddUISkill({
          text = "银之键",
          u = u,
          cd = 30,
          icon = "Mwx_Waiyu_2_05_13.tga",
          func = function(args)
            local u = args.u
            if u:isalive() then
              u:sendmessage("|cFF6633FF银之键-万物归一|r")
              ChangeTimeValue(DamageSystem_Baoji, sy, 40, 10)
            end
          end
        })
      end,
      effectname = "|cFF6633FF银之键|r",
      effecttext = "|cFF6633FF二阶\n外域 唯一|r\n|cFF9999FF提升5%经验获取|r\n|cFF6633FF万物归一|r\n|cFF9999FF提升5%暴击率\n解锁技能[万物归一](10秒内提升40%暴击率,使用冷却30秒)|r\n|cFF6633FF门之匙|r\n|cFF9999FF提升30%RPM\n提升10%心灵属性伤害\n提升30%弹幕伤害|r",
      effectart = "Mwx_Waiyu_2_05_13"
    },
    {
      name = "诺登斯请柬",
      clickfunc = function(u, button)
        if not u:hasdata("诺登斯请柬-关闭") then
          u:sendmessage("|cff9c24ff诺登斯请柬关闭|r")
          u:setdata("诺登斯请柬-关闭")
        else
          u:sendmessage("|cff9c24ff诺登斯请柬开启|r")
          u:deldata("诺登斯请柬-关闭")
        end
      end,
      weight = 100,
      lv = 2,
      key = {"外域", "唯一"},
      unique = true,
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
        u:sendmessage("|cFF6633FF获得" .. var.name .. "|r")
        ChangeValue(Correction_Exp, sy, 0.05)
        local cs = 0
        ac.loop(1000, function()
          if u:isalive() and not u:hasdata("诺登斯请柬-关闭") then
            cs = cs + 1
          end
          if u:isinmaxvar("外域") then
            u:setdata("诺登斯-强化")
          else
            u:deldata("诺登斯-强化")
          end
          if 10 <= cs then
            cs = 0
            local fw = 200 + 10 * u:getstate("外域变异")
            local dx = fw / 440
            local x, y = u:getxy()
            Effectcreate("war3mapImported\\chronospher_fx_mediumq.mdx", x, y, 5, dx, 200)
            local txsh = 2500
            if Hero_Equip_WeaponBoolean[sy] then
              local skill = GetData(Hero_Equip_WeaponType[sy], "绑定技能")
              u:setdata("诺登斯-计算伤害")
              weaponuse(u.handle, skill, x, y)
              u:deldata("诺登斯-计算伤害")
              txsh = 0.25 * u:getdata("诺登斯-武器基础伤害")
            end
            if u:hasdata("诺登斯-强化") then
              for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                if GetRandom100(50) then
                  xq:eliteschange(-1)
                end
              end
            end
            local buffg = {
              "眩晕",
              "暂停",
              "混乱",
              "石化",
              "睡眠",
              "缠绕",
              "麻痹",
              "燃烧",
              "冰冻",
              "僵直"
            }
            ac.timer(250, 20, function()
              for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                local count = 1
                if u:hasdata("诺登斯-强化") then
                  for index, value in ipairs(buffg) do
                    if xq:hasbuff(value) then
                      count = count + 1
                    end
                  end
                  if 7 <= count then
                    count = 7
                  end
                end
                for i = 1, count do
                  DamageUnit({
                    bj = "诺登斯(附伤)",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 1,
                    type = "能量",
                    isvest = true,
                    isattack = false,
                    isnoarmor = false,
                    element = "心灵"
                  })
                end
              end
            end)
          end
        end)
      end,
      effectname = "|cFF6633FF诺登斯请柬|r",
      effecttext = "|cFF6633FF二阶\n外域 唯一|r\n|cFF9999FF提升5%经验获取|r\n|cFF6633FF沉眠百阶|r\n|cFF9999FF每10秒在自身周围创建200范围的幻梦境空间,每0.25秒附带[25%*装备近战武器基础伤害]心灵能量伤害,持续5秒(点击切换开关)|r\n|cFF6633FF深渊之主|r\n|cFF9999FF幻梦境空间提升[10*外域变异]范围\n主变异为外域时:\n【幻梦境空间创建时,范围内所有敌军50%移除一种精英特性\n幻梦空间内敌军每有一种负面状态,增加1次空间伤害次数,上限7次】|r",
      effectart = "Mwx_Waiyu_2_02_13"
    },
    {
      name = "见习死神",
      clickfunc = function(u, ewl)
        local sy = u.ownerid
        if u:isalive() and Hero_Shenhua_Now[sy] == 0 and not u:hasdata("变异判定-小死神") then
          AdvanceGet["小死神"](u)
        end
      end,
      weight = 5,
      lv = 2,
      key = {"外域", "唯一"},
      unique = true,
      addweight = function(u, var)
        local add = 0
        if u:hasdata("判定-小死神") then
          add = add + 500
        end
        return add
      end,
      condition = function(u)
        local b = true
        b = Chengzaishangxianpanding(u, 2, b)
        if not u:hasdata("变异判定-黑猫") then
          b = false
        end
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
        u:sendmessage("|cFFCC0000获得" .. var.name .. "|r")
        ChangeValue(Correction_Exp, sy, 0.05)
        local cs = 0
        local jc = 0
        ac.loop(3000, function()
          if not u:hasdata("小死神-屠杀") then
            cs = cs + 1
            if cs == 10 then
              cs = 0
              u:setdata("小死神-屠杀")
            end
          end
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jc)
          if u:hasdata("变异判定-小死神") then
            jc = 5.0E-4 * u:getstate("灵魂变异") * u:getdata("小死神-灵魂计数")
          else
            jc = 0.001 * u:getdata("小死神-灵魂计数")
          end
          if u:hasdata("变异判定-特莉波卡") then
            jc = jc * u:getstate("外域")
          end
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * jc)
        end)
        u:addstexiao(var.name, "杀敌效果", function(args)
          local tg = args.tg
          if u:hasdata("变异判定-小死神") then
            if tg:isnormal() then
              u:changedata("小死神-灵魂计数", 1)
            elseif tg:iselite() then
              u:changedata("小死神-灵魂计数", 10)
            else
              u:changedata("小死神-灵魂计数", 100)
            end
          else
            u:changedata("小死神-灵魂计数", 1)
          end
          if u:hasdata("物品-罪之镰") then
            u:changedata("小死神-灵魂计数", 0.5)
          end
        end)
        u:addstexiao(var.name, "终结伤害计算效果", function(args)
          local tg = args.tg
          local u = args.u
          local info = args.damageinfo
          if tg:isnormal() then
            if u:hasdata("变异判定-小死神") then
              info.end3 = info.end3 + 0.06 * u:getstate("灵魂变异")
            else
              info.end3 = info.end3 + 0.12
            end
          end
        end)
        u:addstexiao(var.name, "直接伤害特效", function(args)
          local tg = args.tg
          local u = args.u
          local info = args.damageinfo
          if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(5 * info.txgl) then
            u:settimedata(var.name .. "-特效冷却", 4)
            tg:buffset(u.handle, 2, "混乱")
          end
          if tg:isnormal() then
            if u:hasdata("小死神-屠杀") or u:hasdata("变异判定-特莉波卡") and u:getluckrandom(5) then
              u:deldata("小死神-屠杀")
              tg:kill(u.handle)
            end
          elseif not u:hasdata(var.name .. "-特效2冷却") then
            u:settimedata(var.name .. "-特效2冷却", 0.25)
            local sh = 250 * u:getdata("小死神-灵魂计数")
            if u:hasdata("变异判定-小死神") then
              sh = sh * u:getstate("灵魂")
            end
            if u:hasdata("变异判定-特莉波卡") then
              sh = sh * u:getstate("外域")
            end
            LossHpUnit({
              u = u,
              tg = tg,
              damage = sh,
              perhp = 0,
              maxhp = 0,
              bj = "[生命损耗]见习死神"
            })
          end
        end)
      end,
      effectname = "|cFFCC0000见|r|cFFC21F1F习|r|cFFB83D3D死|r|cFFAD5C5C神|r",
      effecttext = "|cFFCC0000二阶\n外域 唯一|r\n|cFFAD5C5C提升5%经验获取|r\n|cFFCC0000屠杀|r\n|cFFAD5C5C对普通单位提升12%伤害\n每30秒下一次直接伤害即死普通单位|r\n|cFFCC0000记忆修改|r\n|cFFAD5C5C直接伤害时5%使目标混乱2秒,触发冷却4秒|r\n|cFFCC0000灵魂收割|r\n|cFFAD5C5C直接伤害非普通单位时损耗目标[200*灵魂计数]生命值,冷却0.2秒\n杀敌时提升1点灵魂计数\n提升[0.1%*灵魂计数]基础伤害|r",
      effectart = "Mwx_Waiyu_2_06_7"
    }
  }
  Vars_Mwx_Tingyuanzhimen_Lv3 = {}
end
