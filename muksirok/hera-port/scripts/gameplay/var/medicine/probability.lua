-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local function medicineprobability_show_rate(u, cgl)
  if u:hasdata("变异判定-全知天使") or u:hasdata("变化天使-全知天使") then
    local cglstr = cgl
    
    if 100 <= cglstr then
      cglstr = 100
    end
    if cglstr <= 0 then
      cglstr = 0
    end
    u:sendmessage("|cFF69738C当前药水成功率:" .. math.floor(cglstr) .. "%|r")
  end
end

local function resolve_medicine_unit(unit)
  if type(unit) == "table" and unit.hasdata then
    return unit
  end
  return getunit(unit)
end

local function medicineprobability_context(unit, skill, wplx)
  local u = resolve_medicine_unit(unit)
  if type(skill) == "string" then
    skill = S2ID(skill)
  end
  if type(wplx) == "string" then
    wplx = S2ID(wplx)
  end
  return {
    u = u,
    skill = skill,
    wplx = wplx,
    sy = u.ownerid
  }
end

local function applyMedicineAfterRollCost(u, wplx)
  local add = 0
  if wplx == MEDICINE_MWX then
    add = GetRandomReal(0.5, 2.5)
    if u:hasdata("变异判定-爱丽丝") then
      add = add * 0.5
    end
  end
  if wplx == MEDICINE_YITAI_JJ or wplx == MEDICINE_YITAI then
    add = GetRandomReal(0.5, 2.5)
  end
  if wplx == MEDICINE_LNS then
    add = GetRandomReal(-4, -1)
    if ModeSelect_Infinite then
      add = add * 1.5
    end
  end
  if wplx == MEDICINE_HUIYI or wplx == MEDICINE_LINGJIEJING or wplx == MEDICINE_SHALUJIEJING or wplx == MEDICINE_Longmenshi or wplx == MEDICINE_Yuanshishenjingji or wplx == MEDICINE_NIUQU then
    add = GetRandomReal(0.5, 2.5) * 1.5
  end
  if wplx == MEDICINE_BLOOD or wplx == MEDICINE_BLOOD_TC then
    add = GetRandomReal(0.5, 2.5)
    if u:hasdata("变异判定-黑龙") then
      add = add * 0.5
    end
  end
  if Nandu_Choose <= 4 then
    add = add * 0.75
  end
  return add
end

function medicineprobability(unit, skill, wplx)
  local ctx = medicineprobability_context(unit, skill, wplx)
  local u = ctx.u
  skill = ctx.skill
  wplx = ctx.wplx
  local b = false
  local sy = ctx.sy
  local cgl = 100
  if wplx == MEDICINE_YITAI_JJ or wplx == MEDICINE_YITAI then
    cgl = 100 - 1.5 * u:getdata("身体负载")
    if u:hasdata("特典-魔歇拉刻印") then
      cgl = cgl + 100
    end
    if u:hasdata("神器判定-神印") then
      cgl = cgl + 100
    end
    if cgl <= 5 then
      cgl = 5
    end
    if u:hasdata("神器判定-灵能档案") then
      cgl = 0
    end
  end
  if wplx == MEDICINE_MWX then
    cgl = 100 - 0.75 * u:getdata("系统-精神负载力")
    if u:hasdata("变异判定-爱丽丝") then
      cgl = cgl + 25
    end
    if u:hasdata("神器判定-灵能档案") then
      cgl = cgl + 50
    end
    if Boolean_CallofCthulhu then
      cgl = cgl * 2
    end
    if u:hasdata("神器判定-神印") or u:hasdata("特典-魔歇拉刻印") then
      cgl = 0
    end
  end
  if wplx == MEDICINE_LNS then
    cgl = 100
    if u:getdata("瞳变异数量") >= u:getdata("瞳承载上限") then
      cgl = cgl * 0.2
    end
  end
  if wplx == MEDICINE_HUIYI or wplx == MEDICINE_LINGJIEJING or wplx == MEDICINE_SHALUJIEJING or wplx == MEDICINE_Longmenshi or wplx == MEDICINE_Yuanshishenjingji or wplx == MEDICINE_NIUQU then
    do
      local excgl = 0
      local base = 150
      if wplx == MEDICINE_HUIYI then
        base = 200
        if u:hasdata("隐藏职业-Galgame女主强化") then
          base = base + 50
        end
        if u:hasdata("狐仙女友") then
          excgl = excgl + 0.5
        end
        if u:hasdata("变异判定-瑟莉亚") then
          excgl = excgl + 0.25 * u:getdata("白毛变异数量")
        end
      end
      if wplx == MEDICINE_LINGJIEJING and u:hasdata("隐藏职业-始源精灵") then
        base = base * 2
      end
      if wplx == MEDICINE_SHALUJIEJING and u:hasdata("隐藏职业-职业杀手") then
        base = base * 1.5
      end
      if wplx == MEDICINE_HUIYI then
        if u:hasdata("血统判定-妖魔之子") then
          base = base * 0.5
        end
        if u:hasdata("克萝蒂亚-契约加成") then
          base = base * 1.05
        end
        if u:hasdata("羁绊-师德充沛") then
          base = base * 1.25
        end
        if u:hasdata("狐仙女友") then
          base = base * 1.5
        end
      end
      if u:hasdata("环境-交错次元") then
        excgl = excgl + 5
      end
      local cz = (u:getdata("系统-神力承载") - u:getdata("系统-神力承载上限")) / 3
      if cz <= 0 then
        cz = 0
      end
      cgl = excgl + base / 1.5 ^ cz
    end
    if u:hasdata("变异判定-健次郎") or u:hasdata("变异判定-朱雀院红叶") then
      cgl = 0
    end
  end
  if wplx == MEDICINE_BLOOD or wplx == MEDICINE_BLOOD_TC then
    cgl = 100
    if 0 < u:getdata("黑龙血统阶级") then
      cgl = -1000
    end
  end
  if cgl ~= 0 then
    if u:hasdata("花瓣-集齐") then
      if 5 <= u:getdata("传奇数量") then
        cgl = cgl + 1
      else
        cgl = cgl + 5 - 1 * u:getdata("传奇数量")
      end
    end
    if u:hasdata("隐藏职业-都市之子") and (u:isinrect(RECT_Feichengqu) or u:isinrect(RECT_Feichezhan) or u:isinrect(RECT_Feichangqu)) then
      cgl = cgl + 5
    end
    if u:hasdata("赝造女巫-赝造药水") then
      cgl = cgl * 0.5
    end
    if u:hasdata("星幽-概率提升") then
      cgl = cgl + 1
    end
  end
  local kyx = u:getdata("抗药性")
  local kyxxs = 1
  do
    local kyxdata = {
      ["变异判定-适应者"] = 0.85,
      ["血统判定-妖魔之子"] = 0.85,
      ["伊蕾娜-禁忌化二"] = 0.9,
      ["愚者-古代学者"] = 0.9
    }
    for key, value in pairs(kyxdata) do
      if u:hasdata(key) then
        kyxxs = math.min(kyxxs, value)
      end
    end
    if not u:hasdata("邪王真眼-圣人之躯") and not u:hasdata("特典-魔歇拉刻印") then
      local cf = 0.01 * u:getdata("身体负载")
      kyxxs = kyxxs * (1 + cf)
    end
  end
  local cgladd = Correction_MEDCgl[sy]
  cgladd = cgladd + 0.03 * u:getdata("幸运")
  if u:hasdata("往世乐土-变异获取中") then
    if u:hasdata("变异判定-粉色妖精小姐") then
      cgladd = cgladd + 0.05
    end
    if 0 < u:getdata("无暇之钥-往世乐土补正次数") then
      u:changedata("无暇之钥-往世乐土补正次数", -1)
      cgladd = cgladd + 1
    end
  end
  if 0 < u:getdata("无暇之钥-补正次数") then
    u:changedata("无暇之钥-补正次数", -1)
    cgladd = cgladd + 1
  end
  if u:hasdata("花瓣-别西卜") and 1 >= Ewaishu[sy] then
    cgladd = cgladd + 1
  end
  if u:hasdata("变异判定-钥匙天使") or u:hasdata("变化天使-钥匙天使") then
    cgladd = cgladd + math.min(0.1, 0.01 * u:getstate("外域变异"))
  end
  if u:hasdata("莲华-献给曾经是少女的你成功率提升") then
    cgladd = cgladd + u:getdata("莲华-献给曾经是少女的你成功率提升") / 100
  end
  if u:hasdata("幸运药剂-成功率提升") then
    cgladd = cgladd + 0.5
  end
  if u:hasdata("莲华-幻恋之观者") then
    cgladd = cgladd + u:getdata("莲华-幻恋之观者成功率")
  end
  if u:hasdata("海豹-成功率提升") then
    cgladd = cgladd + u:getdata("海豹-成功率提升")
  end
  if u:hasdata("变异判定-万华镜") then
    cgladd = cgladd + u:getdata("万华镜-万华成功率")
  end
  if u:hasdata("隐藏职业-都市之子") and (u:isinrect(RECT_Feichengqu) or u:isinrect(RECT_Feichezhan) or u:isinrect(RECT_Feichangqu)) then
    cgladd = cgladd + 0.25
  end
  if u:hasdata("变异判定-星虹之眸") then
    if u:hasdata("变异判定-星神之嗣") then
      cgladd = cgladd + 0.12
    else
      cgladd = cgladd + 0.06
    end
  end
  if u:hasdata("变异判定-星野爱") then
    cgladd = cgladd + 0.02 * u:getstate("歌姬变异")
  end
  if u:hasdata("星野爱-闪耀无比的此刻") then
    cgladd = cgladd + 0.25
    if u:hasdata("变异判定-星野爱") then
      cgladd = cgladd + 0.25
    end
  end
  if u:hasdata("星野爱-药水成功率提升") then
    cgladd = cgladd + u:getdata("星野爱-药水成功率提升")
  end
  if u:hasdata("物品-儿童节棒棒糖") or u:hasdata("变异判定-儿童节棒棒糖") then
    cgladd = cgladd + 0.08
  end
  if u:ishasitem("I0C0") then
    local add = 0.0
    for i = 1, 6 do
      if u:getcountitem(i) == S2ID("I0C0") then
        add = add + 0.06
      end
    end
    if u:hasdata("变异判定-伊芙利特") and 2 <= u:getdata("伊芙利特-精灵阶级") then
      if 5 <= u:getdata("伊芙利特-精灵阶级") then
        add = add + 0.12
      else
        add = add + 0.1
      end
    end
    cgladd = cgladd + add
  end
  if u:hasdata("遗物-四叶草数量") then
    cgladd = cgladd + 0.03 * u:getdata("遗物-四叶草数量")
  end
  if u:hasdata("血统判定-海豹") then
    cgladd = cgladd + 0.0015 * u:getdata("唯一变异数量")
  end
  if u:hasdata("变异判定-隐匿者") then
    if u:hasdata("变异判定-人理之光") then
      cgladd = cgladd + 0.16
    else
      cgladd = cgladd + 0.08
    end
  end
  if u:hasdata("妮芙-药水成功率") then
    cgladd = cgladd + u:getdata("妮芙-药水成功率")
  end
  do
    local data = {
      {
        "拉比琳丝-城主",
        0.2
      },
      {
        "神主ZUN-强化",
        0.5
      },
      {
        "属性-女神",
        0.12
      },
      {
        "露娜-玩偶物品",
        0.0327
      },
      {
        "雪女-春告",
        0.08
      },
      {
        "莲华-勿忘草提升成功率",
        0.1
      },
      {
        "白洲梓-冰山魔女",
        0.1
      },
      {
        "Abraxas-持有",
        0.25
      },
      {
        "燕-被厌恶的此身-脱战",
        0.12
      },
      {
        "神树之果-食用",
        0.12
      },
      {
        "达摩克利斯之剑-持有",
        0.1
      },
      {
        "辅助模组-幸运模组",
        0.08
      },
      {
        "隐藏职业-Galgame女主强化",
        0.5
      },
      {
        "伊蕾娜-禁忌化二",
        0.12
      },
      {
        "灵梦-信仰心增加祈愿之仪",
        0.12
      },
      {
        "量子妖精-持有",
        0.04
      },
      {
        "变异判定-量子妖精",
        0.05
      },
      {
        "丛雨-神力解放主",
        0.25
      },
      {
        "新年礼药水成功率",
        0.05
      },
      {
        "金苹果提升成功率",
        0.5
      },
      {
        "比斯莫克-处于城区",
        0.2
      },
      {
        "变异判定-空",
        0.08
      },
      {
        "血统判定-人类",
        0.1
      },
      {
        "夜猫子-药水成功率提升",
        0.2
      },
      {
        "闻鸡起舞-药水成功率提升",
        0.2
      }
    }
    for _, value in ipairs(data) do
      if u:hasdata(value[1]) then
        cgladd = cgladd + value[2]
      end
    end
    local buffdata = {
      {"B0FY", 0.2},
      {"B07N", 0.1},
      {"B08X", 0.1}
    }
    for _, value in ipairs(buffdata) do
      if u:ishasbuff(value[1]) then
        cgladd = cgladd + value[2]
      end
    end
    local itemdata = {
      {"I0AR", 0.5}
    }
    for _, value in ipairs(itemdata) do
      if u:ishasitem(value[1]) then
        cgladd = cgladd + value[2]
      end
    end
  end
  cgl = cgl * (1 + cgladd)
  if u:hasdata("朝武芳乃-药水成功率降低") then
    cgl = cgl * (1 - u:getdata("朝武芳乃-药水成功率降低"))
  end
  if u:hasdata("厄运药剂-厄运") then
    cgl = cgl * 0.5
  end
  if u:hasdata("智慧树的枝条-持有") then
    cgl = cgl * (1 - 0.02 * u:getdata("智慧树的枝条-使用次数"))
  end
  if u:hasdata("达摩克利斯之剑-惩罚值") then
    cgl = cgl * (1 - u:getdata("达摩克利斯之剑-惩罚值"))
  end
  if u:hasdata("爱丽丝-蛇神的诅咒") then
    cgl = cgl * 0.75
  end
  if u:hasdata("隐藏职业-天谴之子") then
    cgl = cgl * 0.75
  end
  if u:hasdata("万宝槌-财富许愿") then
    cgl = cgl * 0.01
  end
  if u:hasdata("环境-无星暗夜") then
    cgl = cgl * 0.8
  end
  if u:hasdata("物品-艾哲诅咒") or u:hasdata("物品-艾哲诅咒2") or u:hasdata("物品-艾哲诅咒3") then
    cgl = cgl * (1 - u:getdata("艾哲诅咒-惩罚值"))
  end
  if u:hasdata("变异判定-雪怨") then
    cgl = cgl * 0.9
  end
  medicineprobability_show_rate(u, cgl)
  if GetRandom100(cgl) then
    b = true
  end
  if u:hasdata("系统-无法获取变异") or u:hasdata("神主ZUN-回答问题中") or u:hasdata("神主ZUN-回答问题失败") then
    b = false
    cgl = 0
  end
  local add = applyMedicineAfterRollCost(u, wplx)
  if 0 < add then
    if not b then
      add = add * 0.5
    end
    if u:hasdata("变异判定-钥匙天使") or u:hasdata("变化天使-钥匙天使") then
      add = add * (1 - math.min(0.1, 0.01 * u:getstate("外域变异")))
    end
    if u:hasdata("神树之果-食用") then
      add = add * 0.88
    end
    if u:hasdata("伊蕾娜-禁忌化二") then
      add = add * 0.9
    end
    if u:hasdata("变异判定-桔梗") then
      add = add * 0.9
    end
    if u:hasdata("变异判定-西行寺幽幽子") then
      add = add * 0.8
    end
    if u:hasdata("血统判定-人类") then
      add = add * 0.88
    end
    if u:hasdata("传令员-降低抗药性获取") then
      add = add * 0.75
    end
    if u:hasdata("变异判定-虞美人") then
      add = add * 0.88
    end
    if u:hasdata("利姆露-禁忌化") then
      add = add * 0.8
    end
    if u:hasdata("变异判定-适应者") then
      add = add * 0.88
    end
    if u:hasdata("赝造女巫-赝造药水") then
      add = add * 3
    end
    if not u:hasdata("邪王真眼-圣人之躯") and not u:hasdata("特典-魔歇拉刻印") then
      add = add * (1 + 0.01 * u:getdata("身体负载"))
    end
    if u:hasdata("物品-艾哲诅咒") or u:hasdata("物品-艾哲诅咒2") or u:hasdata("物品-艾哲诅咒3") then
      add = add * (1 + u:getdata("艾哲诅咒-惩罚值"))
    end
  end
  if u:hasdata("药水判定-往世乐土") then
    add = 0
  end
  if add ~= 0 then
    u:changekyx(add)
  end
  if b then
    if u:hasdata("金苹果提升成功率") then
      u:deldata("金苹果提升成功率")
    end
    if u:hasdata("幸运药剂-成功率提升") then
      u:deldata("幸运药剂-成功率提升")
    end
  end
  return cgl, b
end
