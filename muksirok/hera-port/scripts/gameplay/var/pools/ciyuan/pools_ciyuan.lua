-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local slk = require("jass.slk")

local function dwss(args)
  local tg = args.tg
  local u = args.u
  local info = args.damageinfo
  local sh = tg:getdata("凋亡损伤-叠加值")
  if 0 < sh and not info.isvestdamage then
    if u:hasdata("变异判定-阿尔图罗") then
      sh = sh * 1.33
    end
    LossHpUnit({
      u = u,
      tg = tg,
      damage = sh,
      perhp = 0,
      maxhp = 0,
      bj = "[生命损耗]凋亡损伤"
    })
  end
end

function shalujinjie(u, var, add)
  local szhx = false
  if var.key then
    for index, value in ipairs(var.key) do
      u:changedata(value .. "变异数量", 1)
      if value == "机械" then
        szhx = true
      end
    end
  end
  if szhx then
    if u:getdata("肃正核心-剩余神力") > 0 then
      local xh = add
      if add >= u:getdata("肃正核心-剩余神力") then
        xh = u:getdata("肃正核心-剩余神力")
        u:changedata("系统-机械传奇占用槽位", add - xh)
      end
      u:changedata("系统-神力承载上限", xh)
      u:changedata("肃正核心-剩余神力", -xh)
      u:sendmessage("|cFFF23333[肃正核心]提升" .. xh .. "神力承载上限")
    else
      u:changedata("系统-机械传奇占用槽位", add)
    end
  end
  u:changedata("系统-神力承载", add)
end

function ciyuanget(u, var, ignore_carry)
  u:setdata("变异判定-" .. var.name)
  local szhx = false
  local waiyu = false
  if var.key then
    for index, value in ipairs(var.key) do
      u:changedata(value .. "变异数量", 1)
      if value == "机械" then
        szhx = true
      end
      if value == "外域" then
        waiyu = true
      end
    end
  end
  local add = 3
  if var.lv then
    add = var.lv
  end
  if ignore_carry then
    return
  end
  if u:hasdata("灯笼-获取对应槽位") or u:hasdata("转生者-获取变异中") then
    u:changedata("系统-神力承载上限", add)
  end
  if szhx then
    if u:getdata("肃正核心-剩余神力") > 0 then
      local xh = add
      if add >= u:getdata("肃正核心-剩余神力") then
        xh = u:getdata("肃正核心-剩余神力")
        u:changedata("系统-机械传奇占用槽位", add - xh)
      end
      u:changedata("系统-神力承载上限", xh)
      u:changedata("肃正核心-剩余神力", -xh)
      u:sendmessage("|cFFF23333[肃正核心]提升" .. xh .. "神力承载上限")
    else
      u:changedata("系统-机械传奇占用槽位", add)
    end
  end
  u:changedata("系统-神力承载", add)
  local ignore_shenli_carry = false
  if u:hasdata("系统-神力觉醒不占神力承载") then
    u:changedata("系统-神力承载", -add)
    ignore_shenli_carry = true
  end
  if not ignore_shenli_carry and 0 < u:getdata("虚空形态-剩余次数") then
    u:changedata("虚空形态-剩余次数", -1)
    u:sendmessage("|cFFFF8040[虚空形态]不计入承载:" .. var.name)
    u:changedata("系统-神力承载", -add)
    ignore_shenli_carry = true
  end
  if not ignore_shenli_carry and waiyu and u:hasdata("宇宙联合-不消耗次数") then
    u:deldata("宇宙联合-不消耗次数")
    if 5 < add then
      u:sendmessage("|cff559fff[宇宙联合行星保护机构]降低承载消耗:" .. var.name)
      u:changedata("系统-神力承载", -5)
    else
      u:sendmessage("|cff559fff[宇宙联合行星保护机构]不计入承载:" .. var.name)
      u:changedata("系统-神力承载", -add)
    end
  end
end

local dlsxy, dlszj, dlsexp, dlstlmax, dlsqsx, dlsewys, dlssd = 0, 0, 0, 0, 0, 0, 0
local dlswskx, dlsfly = false, false
Danwei_Jinmuqianshu = 0
Danwei_Jingshanglongnai = 0
local sjz = {
  1,
  2,
  3
}
Vars_Ciyuan_ByLv = {}
Vars_Spe_Zhuleiaige = {
  {
    name = "塞壬人鱼",
    lv = 0,
    weight = 100,
    key = {
      "唯一",
      "水",
      "黑暗",
      "珠泪哀歌"
    },
    unique = true,
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
      ciyuanget(u, var)
      local add = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        add = 0.1 * u:getstate("水变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      end)
    end,
    effectname = "|cFF3366FF珠|r|cFF396CFF泪|r|cFF4073FF哀|r|cFF4679FF歌|r|cFF4C80FF.|r|cFF5386FF塞|r|cFF598CFF壬|r|cFF6093FF人|r|cFF6699FF鱼|r",
    effecttext = "|cFFFFBFBF[特殊]|r\n|cFF3366FF唯一 水 黑暗 珠泪哀歌|r\n|cFF6699FF提升[水变异*1%]伤害加成|r\n|cFF3366FF【一世坏】|r\n|cFF6699FF珠泪哀歌变异≥3时,传奇池添加新变异|r",
    effectart = "Cq_Zhulei_Sairen"
  },
  {
    name = "小美人鱼",
    lv = 0,
    weight = 100,
    key = {
      "唯一",
      "水",
      "黑暗",
      "珠泪哀歌"
    },
    unique = true,
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
      ciyuanget(u, var)
      local add = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Baoshang, sy, -add)
        add = 0.05 * u:getstate("水变异")
        ChangeValue(DamageSystem_Baoshang, sy, add)
      end)
    end,
    effectname = "|cFF3366FF珠|r|cFF396CFF泪|r|cFF4073FF哀|r|cFF4679FF歌|r|cFF4C80FF.|r|cFF5386FF小|r|cFF598CFF美|r|cFF6093FF人|r|cFF6699FF鱼|r",
    effecttext = "|cFFFFBFBF[特殊]|r\n|cFF3366FF唯一 水 黑暗 珠泪哀歌|r\n|cFF6699FF提升[水变异*5%]暴击伤害|r\n|cFF3366FF【一世坏】|r\n|cFF6699FF珠泪哀歌变异≥3时,传奇池加入新变异|r",
    effectart = "Cq_Zhulei_Xiaomei"
  },
  {
    name = "梅洛人鱼",
    lv = 0,
    weight = 100,
    key = {
      "唯一",
      "水",
      "黑暗",
      "珠泪哀歌"
    },
    unique = true,
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
      ciyuanget(u, var)
      local add = 0
      ac.loop(3000, function()
        ChangeValue(Damage_Element_Water, sy, -add)
        add = 0.01 * u:getstate("水变异")
        ChangeValue(Damage_Element_Water, sy, add)
      end)
    end,
    effectname = "|cFF3366FF珠|r|cFF396CFF泪|r|cFF4073FF哀|r|cFF4679FF歌|r|cFF4C80FF.|r|cFF5386FF梅|r|cFF598CFF洛|r|cFF6093FF人|r|cFF6699FF鱼|r",
    effecttext = "|cFFFFBFBF[特殊]|r\n|cFF3366FF唯一 水 黑暗 珠泪哀歌|r\n|cFF6699FF提升[水变异*1%]水属性伤害|r\n|cFF3366FF【一世坏】|r\n|cFF6699FF珠泪哀歌变异≥3时,传奇池加入新变异|r",
    effectart = "Cq_Zhulei_Meiluo"
  }
}
Vars_Ciyuan_Lv0 = {}
Vars_Ciyuan_Lv1 = {
  {
    name = "幽灵",
    weight = 500,
    lv = 1,
    key = {"唯一", "灵魂"},
    unique = true,
    addweight = function(u, var)
      return 0
    end,
    condition = function(u)
      return u.type == HeroType["妖梦"] or u:hasdata("变异判定-见习死神")
    end,
    effect = function(u, var)
      local is_youmu = u.type == HeroType["妖梦"]
      local has_apprentice_reaper = u:hasdata("变异判定-见习死神")
      ciyuanget(u, var)
      if is_youmu then
        u:changedata("妖梦-额外剑气恢复", 0.05)
        u:changedata("妖梦-超必杀冷却降低", 0.1)
      end
      if has_apprentice_reaper then
        u:changedata("生命损耗效果增强", 0.1)
        u:addstexiao("幽灵-见习死神效果", "杀敌效果", function()
          u:changedata("小死神-灵魂计数", 0.5)
        end)
      end
      u:addstexiao("幽灵-决死", "决死效果", function(args)
        if args.dt and not u:hasdata("幽灵传奇-决死冷却") then
          args.dt = false
          u:settimedata("幽灵传奇-决死冷却", 180)
          u:sendmessage("|cFFD7FFF2[幽灵]决死|r")
        end
      end)
      local x, y = u:getxy()
      local ls = u:createunit("h0GQ", x, y)
      ls:setsize(3)
      ls:setdata("系统-无敌")
      ac.loop(3000, function()
        local dx, dy = ls:getxy()
        local x2, y2 = u:getxy()
        if DistanceXY(dx, dy, x2, y2) >= 2000 then
          ls:setxy(x2, y2)
        else
          local orderName = GetUnitCurrentOrder(ls.handle)
          if orderName == 0 then
            IssueTargetOrder(ls.handle, "follow", u.handle)
          end
        end
      end)
      TriggerRegisterUnitEvent(Trg_ItemUse, ls.handle, EVENT_UNIT_USE_ITEM)
      TriggerRegisterUnitEvent(Trg_ItemGet, ls.handle, EVENT_UNIT_PICKUP_ITEM)
      TriggerRegisterUnitEvent(Trg_UnitSkill, ls.handle, EVENT_UNIT_SPELL_EFFECT)
      ls:addtrgevent("单位-发动技能", function(args)
        args.unit = u.handle
        itemskillTrg(args)
      end)
      ls:addtrgevent("单位-使用物品", function(args)
        MedicineAct(u.handle, args.item)
        itemuseTrg(u.handle, args.item)
        modelChangeTrg(u.handle, args.item)
      end)
      ac.wait(10, function()
        if is_youmu and has_apprentice_reaper then
          u:uivar_change({
            keyname = "幽灵",
            keytype = "传奇栏",
            text = "|cFFD7FFF2麻薯|r\n|cFFFFECC4[凡俗]|r\n|cFFD7FFF2唯一 灵魂\n提升0.5%剑气恢复\n降低10%超必杀冷却\n提升10%生命损耗效果\n提升0.5点杀敌灵魂计数获取\n受到致死伤害时抵挡,冷却180秒",
            icon = "Cq_Youling.tga"
          })
        elseif is_youmu then
          u:uivar_change({
            keyname = "幽灵",
            keytype = "传奇栏",
            text = "|cFFD7FFF2麻薯|r\n|cFFFFECC4[凡俗]|r\n|cFFD7FFF2唯一 灵魂\n提升0.5%剑气恢复\n降低10%超必杀冷却\n受到致死伤害时抵挡,冷却180秒",
            icon = "Cq_Youling.tga"
          })
        elseif has_apprentice_reaper then
          u:uivar_change({
            keyname = "幽灵",
            keytype = "传奇栏",
            text = "|cffa72126幽灵|r\n|cFFFFECC4[凡俗]|r\n|cffa72126唯一 灵魂\n提升10%生命损耗效果\n提升0.5点杀敌灵魂计数获取\n受到致死伤害时抵挡,冷却180秒",
            icon = "Cq_Youling_2.tga"
          })
        else
          u:uivar_change({
            keyname = "幽灵",
            keytype = "传奇栏",
            text = "|cFFD7FFF2幽灵|r\n|cFFFFECC4[凡俗]|r\n|cFFD7FFF2唯一 灵魂\n受到致死伤害时抵挡,冷却180秒",
            icon = "Cq_Youling.tga"
          })
        end
      end)
    end,
    effectname = "|cFFD7FFF2幽灵|r",
    effecttext = "|cFFFFECC4[凡俗]|r\n|cFFD7FFF2唯一 灵魂\n受到致死伤害时抵挡,冷却180秒\n是[妖梦机体]时:\n[提升0.5%剑气恢复\n降低10%超必杀冷却]|r\n|cffa72126拥有[见习死神]时:\n[提升10%生命损耗效果\n提升0.5点杀敌灵魂计数获取]|r",
    effectart = "Cq_Youling.tga"
  },
  {
    name = "八坂真寻",
    weight = 1000,
    lv = 1,
    key = {"唯一"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("变异判定-宇宙联合行星保护机构") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Zhenxun_01)
      u:chat("|cFFC3C0B9我平稳的日常生活……去哪了？")
      u:changedata("效果增强-外域", 0.15)
      u:changedata("外域变异补正", 100)
    end,
    effectname = "|cFFE6E7EC八|r|cFFD9DADD坂|r|cFFCDCDCF真|r|cFFC0C0C0寻|r",
    effecttext = "|cFFFFECC4[凡俗]|r\n|cFFE6E7EC唯一|r\n|cFFC0C0C0提升15%外域效果增强\n提升100%外域变异补正\n提升[宇宙联合行星保护机构]相关变异获取概率|r",
    effectart = "Cq_Yzlh_Babanzhenxun.tga",
    test = "    "
  },
  {
    name = "千矢",
    weight = 5,
    lv = 1,
    key = {
      "唯一",
      "白毛",
      "兽",
      "自然",
      "风",
      "魔导",
      "百合"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("乌拉拉-迷路帖") then
        add = add + 2000
      end
      if u:ishasitem("I06D") then
        add = add + 1000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("乌拉拉-迷路帖") then
        b = true
      end
      if u:getdata("传奇数量") < 4 and u:hasdata("权限-千矢") and u:ishasitem("I06D") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cFFCCFFFF「道|r|cFFBEF2FF歉|r|cFFB1E6FF的|r|cFFA3D9FF时|r|cFF96CCFF候|r|cFF88C0FF要|r|cFF7AB3FF把|r|cFF6DA6FF肚|r|cFF5F9AFF子|r|cFF528DFF露|r|cFF4480FF出|r|cFF3674FF来|r|cFF2967FF哦|r|cFF1B5AFF~」|r")
      u:playsound(Urara_3)
      ChangeValue(Correction_Jzsh, sy, 0.025)
      ChangeValue(DamageSystem_Shjc, sy, 0.025)
      ac.wait(10, function()
        u:uivar_change({
          keyname = "千矢",
          keytype = "传奇栏",
          icon = "Ewl_Qs_BigIcon.blp",
          ishasphoto = true,
          smallicon = "Ewl_Qs_SmallIcon.blp"
        })
      end)
      u:groupadd(Group_Wolf)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 0.1)
          local txsh = 0.13 * info.yssh
          DamageUnit({
            bj = "千矢(野性本能)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 4,
            type = "物理",
            isvest = true,
            isattack = true,
            isnoarmor = false,
            element = "无"
          })
        end
      end)
      u:uivar_add({
        keyname = "占卜师试炼",
        keytype = "冥王栏",
        text = "|cff6cfafa千矢的占卜师试炼|r",
        icon = "war3mapImported\\BTNEwl_Urara_Qianshi.blp",
        clickfunc = function(u, button)
          local count1 = u:getdata("千矢-占卜师等级")
          u:sendmessage(("|cff6cfafa[占卜师试炼]当前等级:%d|r"):format(count1))
          FlashUIVarGlobal(u, MWXSTR .. "占卜师试炼")
        end
      })
      u:setdata("千矢-占卜师等级", 0)
      u:setdata("千矢-当前阶级", 0)
      u:setdata("千矢-占卜师试炼可获取次数", 2)
      ac.wait(100, function()
        herogetvar(u.handle, {
          Vars_Mwx_Zhanbushishilian
        }, "冥王星")
      end)
      u:addstexiao(var.name, "过波时效果", function(args)
        u:setdata("千矢-占卜师试炼可获取次数", 2)
        herogetvar(u.handle, {
          Vars_Mwx_Zhanbushishilian
        }, "冥王星")
      end)
      u:setdata("千矢-占卜师系数", 0)
      local add = 0
      local hp = 0
      local add2 = 0
      local add3 = 0
      local cs = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, -hp)
        add = 0.2 * u:getdata("百合变异数量")
        hp = 0.3 * u:getdata("百合变异数量")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, hp)
        local lv = u:getdata("千矢-当前阶级")
        local count = u:getdata("千矢-占卜师等级")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add2)
        ChangeValue(Correction_Magic, sy, -add2)
        add2 = u:getdata("千矢-占卜师系数") * count
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add2)
        ChangeValue(Correction_Magic, sy, add2)
        ChangeValue(DamageSystem_Shjc, sy, -add3)
        add3 = u:getdata("千矢-占卜师系数") * (Correction_Magic[sy] - 1)
        ChangeValue(DamageSystem_Shjc, sy, add3)
        if 3 <= lv then
          cs = cs + 1
          if 30 <= cs then
            cs = 0
            local sxadd = count * (lv - 2)
            u:addallstats(sxadd)
            u:sendmessage("|cFFF2F7CE[千矢-占卜师试炼]提升" .. math.floor(sxadd) .. "点全属性|r")
          end
        end
        if lv == 0 and 3 <= count then
          u:sendmessage("|cFFF2F7CE[千矢]占卜师进阶|r")
          u:setdata("千矢-当前阶级", lv + 1)
          u:changedata("系统-神力承载", 1)
          u:setdata("千矢-占卜师系数", 0.05)
          u:setdata("系统-灵力结算法修")
          u:uivar_change({
            keyname = "千矢",
            keytype = "传奇栏",
            text = "|cFFF2F7CE千矢|r\n|cFF66CCFF[奇迹]|r\n|cFFCCFFFF唯一 白毛 兽 魔导 自然 风 同奏 百合|r\n|cFFF2F7CE提升2.5%近战伤害\n提升2.5%伤害加成|r\n|cFFCCFFFF【野性本能:嗷呜~!】|r\n|cFFF2F7CE视为狼群一员但是不会变狼\n无视地形\n直接伤害时附带[伤害值*13%]物理伤害,冷却0.1秒|r\n|cFFCCFFFF【占卜师试炼】|r\n|cFFF2F7CE灵力伤害享受法术加成\n提升[0.5%*占卜师等级]伤害加成\n提升[0.5%*占卜师等级]法术修正\n提升[5%*法术修正]伤害加成|r\n|cFFCCFFFF【大橘已定】|r\n|cFFF2F7CE提升[2%*百合变异]伤害加成\n提升[0.3%*百合变异]生命恢复|r"
          })
        end
        if lv == 1 and 6 <= count then
          u:sendmessage("|cFFF2F7CE[千矢]占卜师进阶|r")
          u:setdata("千矢-当前阶级", lv + 1)
          u:changedata("系统-神力承载", 1)
          u:setdata("千矢-占卜师系数", 0.1)
          u:uivar_change({
            keyname = "千矢",
            keytype = "传奇栏",
            text = "|cFFF2F7CE千矢|r\n|cFFFFAA00[传奇]|r\n|cFFCCFFFF唯一 白毛 兽 魔导 自然 风 同奏 百合|r\n|cFFF2F7CE提升2.5%近战伤害\n提升2.5%伤害加成|r\n|cFFCCFFFF【野性本能:嗷呜~!】|r\n|cFFF2F7CE视为狼群一员但是不会变狼\n无视地形\n直接伤害时附带[伤害值*13%]物理伤害,冷却0.1秒|r\n|cFFCCFFFF【占卜师试炼】|r\n|cFFF2F7CE灵力伤害享受法术加成\n提升10%法术加成继承\n提升[1%*占卜师等级]伤害加成\n提升[1%*占卜师等级]法术修正\n提升[10%*法术修正]伤害加成|r\n|cFFCCFFFF【大橘已定】|r\n|cFFF2F7CE提升[2%*百合变异]伤害加成\n提升[0.3%*百合变异]生命恢复|r"
          })
        end
        if lv == 2 and 9 <= count then
          u:sendmessage("|cFFF2F7CE[千矢]占卜师进阶|r")
          u:setdata("千矢-当前阶级", lv + 1)
          u:changedata("系统-神力承载", 2)
          u:setdata("千矢-占卜师系数", 0.2)
          ChangeValue(Correction_Magic_Count, sy, 0.2)
          u:uivar_change({
            keyname = "千矢",
            keytype = "传奇栏",
            text = "|cFFF2F7CE千矢|r\n|cFFCC66FF[超凡]|r\n|cFFCCFFFF唯一 白毛 兽 魔导 自然 风 同奏 百合|r\n|cFFF2F7CE提升2.5%近战伤害\n提升2.5%伤害加成|r\n|cFFCCFFFF【野性本能:嗷呜~!】|r\n|cFFF2F7CE视为狼群一员但是不会变狼\n无视地形\n直接伤害时附带[伤害值*13%]物理伤害,冷却0.1秒|r\n|cFFCCFFFF【占卜师试炼】|r\n|cFFF2F7CE灵力伤害享受法术加成\n提升20%法术加成继承\n提升[2%*占卜师等级]伤害加成\n提升[2%*占卜师等级]法术修正\n提升[20%*法术修正]伤害加成\n每90秒提升[占卜师等级*1]点全属性|r\n|cFFCCFFFF【大橘已定】|r\n|cFFF2F7CE提升[2%*百合变异]伤害加成\n提升[0.3%*百合变异]生命恢复|r"
          })
        end
        if lv == 3 and 12 <= count then
          u:sendmessage("|cFFF2F7CE[千矢]占卜师进阶|r")
          u:setdata("千矢-当前阶级", lv + 1)
          u:changedata("系统-神力承载", 2)
          u:setdata("千矢-占卜师系数", 0.4)
          ChangeValue(Correction_Magic_Count, sy, 0.2)
          u:uivar_change({
            keyname = "千矢",
            keytype = "传奇栏",
            text = "|cFFF2F7CE千矢|r\n|cFFFF3366[神话]|r\n|cFFCCFFFF唯一 白毛 兽 魔导 自然 风 同奏 百合|r\n|cFFF2F7CE提升2.5%近战伤害\n提升2.5%伤害加成|r\n|cFFCCFFFF【野性本能:嗷呜~!】|r\n|cFFF2F7CE视为狼群一员但是不会变狼\n无视地形\n直接伤害时附带[伤害值*13%]物理伤害,冷却0.1秒|r\n|cFFCCFFFF【占卜师试炼】|r\n|cFFF2F7CE灵力伤害享受法术加成\n提升40%法术加成继承\n提升[4%*占卜师等级]伤害加成\n提升[4%*占卜师等级]法术修正\n提升[40%*法术修正]伤害加成\n每90秒提升[占卜师等级*2]点全属性|r\n|cFFCCFFFF【大橘已定】|r\n|cFFF2F7CE提升[2%*百合变异]伤害加成\n提升[0.3%*百合变异]生命恢复|r"
          })
        end
      end)
    end,
    effectname = "|cFFF2F7CE千矢|r",
    effecttext = "|cFFFFECC4[凡俗]|r\n|cFFCCFFFF唯一 白毛 兽 魔导 自然 风 同奏 百合|r\n|cFFF2F7CE提升2.5%近战伤害\n提升2.5%伤害加成|r\n|cFFCCFFFF【野性本能:嗷呜~!】|r\n|cFFF2F7CE视为狼群一员但是不会变狼\n无视地形\n直接伤害时附带[伤害值*13%]物理伤害,冷却0.1秒|r\n|cFFCCFFFF【占卜师试炼】|r\n|cFFF2F7CE初始占卜师等级为0\n获取/过波时随机获取一个所属变异,每波至多获取2个\n占卜师等级达到指定数值时,自动进阶该变异\n3 - [奇迹]\n6 - [传奇]\n9 - [超凡]\n12 - [神话]|r\n|cFFCCFFFF【大橘已定】|r\n|cFFF2F7CE提升[2%*百合变异]伤害加成\n提升[0.3%*百合变异]生命恢复|r",
    effectart = "war3mapImported\\BTNEwl_Urara_Qianshi.blp",
    test = [[

            ]]
  },
  {
    name = "玉月",
    clickfunc = function(u, var)
      local sy = u.ownerid
      if not u:hasdata("玉月-关闭给予") then
        u:setdata("玉月-关闭给予")
        u:sendmessage("|cFFFFFF66[玉月]捣药关闭")
      else
        u:deldata("玉月-关闭给予")
        u:sendmessage("|cFFFFFF66[玉月]捣药开启")
      end
    end,
    weight = 100,
    lv = 1,
    key = {
      "唯一",
      "星",
      "根源"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("权限-玉月") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:sendmessage("|cFFFFFF33云|r|cFFFFFF4C破|r|cFFFFFF66月|r|cFFFFFF80来|r|cFFFFFF99花|r|cFFFFFFB2弄|r|cFFFFFFCC影|r")
      ac.loop(90000, function()
        if u:isalive() and not u:hasdata("玉月-关闭给予") then
          u:additem("I038")
        end
      end)
      local cs = 0
      local ewys = 0
      local jc = 0
      ac.loop(3000, function()
        if u:isalive() then
          cs = cs + 3
        end
        if 120 <= cs then
          cs = 0
          u:additem("I0JL")
        end
      end)
      if not u:hasdata("伊丝-过波奖励获取变异") then
        ac.wait(888000, function()
          u:changedata("传奇数量", -1)
          u:changedata("系统-神力承载上限", 3)
          u:sendmessage("|cFFFFFFCC玉月-阴晴圆缺|r")
        end)
      end
    end,
    effectname = "|cFFFFFF66玉|r|cFFFFFFCC月|r",
    effecttext = "|cFFFFECC4[凡俗]|r\n|cFFFFFF66唯一 星 根源\n【捣药】(点击切换开关)|r\n|cFFFFFFCC每90秒获得一个资源箱|r\n|cFFFFFF66【月饼】|r\n|cFFFFFFCC每360秒获得一个月饼|r\n|cFFFFFF66【阴晴圆缺】|r\n|cFFFFFFCC获得888秒后提升3神力承载上限|r",
    effectart = "Ewl_Yuyue_9",
    test = [[

            ]]
  },
  {
    name = "藤田琴音",
    weight = 100,
    lv = 1,
    key = {"唯一", "歌姬"},
    unique = true,
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
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Ttqy_01)
      SendMsgAll("|cFFF7DBA9『作为偶像的……工作？』|r")
      u:addgold(500)
      ChangeValue(Correction_Gold, sy, 0.05)
      u:addstexiao(var.name, "过波时效果", function(args)
        if u:hasdata("藤田琴音-进阶") then
          u:sendmessage("|cFFF7DBA9[藤田琴音]世界第一可爱的我")
          u:changedata("系统-神力承载上限", 1)
          u:addgold(100)
          u:addallstats(25)
        end
        if not u:hasdata("藤田琴音-进阶") then
          local jg = 1
          if GetRandom100(50) then
            jg = 1
          elseif GetRandom100(50) then
            jg = 2
          elseif GetRandom100(76) then
            jg = 3
          elseif GetRandom100(83) then
            jg = 4
          else
            jg = 5
          end
          if jg == 1 then
            u:changedata("藤田琴音-育成度", 10)
            u:sendmessage("|cFFF7DBA9[藤田琴音]偶像练习小有提升")
          end
          if jg == 2 then
            u:changedata("藤田琴音-育成度", -5)
            u:sendmessage("|cFFF7DBA9[藤田琴音]偶像练习搞砸了")
          end
          if jg == 3 then
            u:addgold(100)
            u:sendmessage("|cFFF7DBA9[藤田琴音]沉迷于打工")
          end
          if jg == 4 then
            u:changedata("藤田琴音-育成度", 20)
            u:sendmessage("|cFFF7DBA9[藤田琴音]偶像练习大有提升")
          end
          if jg == 5 then
            u:changedata("藤田琴音-育成度", 100)
            u:sendmessage("|cFFF7DBA9[藤田琴音]一夜爆红！")
          end
          if 100 <= u:getdata("藤田琴音-育成度") then
            u:setdata("藤田琴音-进阶")
            SendMsgAll("|cFFF7DBA9【BGM：自己肯定感爆上げ↑↑しゅきしゅきソング】")
            PlayBGM({
              bgm = BGM_Ttqy_01,
              time = 240,
              ID = 223,
              unit = u.handle
            })
            u:changedata("系统-神力承载", 1)
            u:addgold(1000)
            ChangeValue(Correction_Gold, sy, 0.05)
            u:uivar_change({
              keyname = "藤田琴音",
              keytype = "传奇栏",
              text = "|cFFF7DBA9藤|r|cFFE2E2B8田|r|cFFCDE9C8琴|r|cFFB8F0D7音|r\n|cFF66CCFF[奇迹]|r\n|cFFF7DBA9唯一 歌姬|r\n|cFFF7DBA9【赚到钱的偶像】|r\n|cFFB8F0D7获取时获得1000积分\n提升10%积分获取|r\n|cFFF7DBA9【世界第一可爱的我】|r\n|cFFB8F0D7过波时提升1神力承载上限\n过波时获得100积分\n过波时提升25全属性|r",
              icon = "Cq_Ttqy_02"
            })
          end
        end
      end)
    end,
    effectname = "|cFFF7DBA9藤|r|cFFE2E2B8田|r|cFFCDE9C8琴|r|cFFB8F0D7音|r",
    effecttext = "|cFFFFECC4[凡俗]|r\n|cFFF7DBA9唯一 歌姬|r\n|cFFF7DBA9【梦想是能赚钱的偶像】|r\n|cFFB8F0D7获取时获得500积分\n提升5%积分获取|r\n|cFFF7DBA9【世界第一可爱】|r\n|cFFB8F0D7过波时进行一次偶像练习来提升[育成度]\n[育成度]达到100时进阶为[奇迹]|r",
    effectart = "Cq_Ttqy",
    test = "            "
  },
  {
    name = "矢泽妮可",
    weight = 100,
    lv = 1,
    key = {
      "唯一",
      "歌姬",
      "同奏"
    },
    unique = true,
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
      ciyuanget(u, var)
      u:chat("|cFFFF537E你们只会令「偶像」蒙羞！")
      PlayGlobalSound(Sound_Shizenike_01)
      u:setdata("属性-歌姬传奇")
      local add = 0
      local js = 1
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, -add)
        ChangeValue(DamageSystem_Ssjianshao, sy, js, 2)
        add = 0.01 * u:getstate("歌姬变异")
        if BGMIsChange then
          add = add + 0.33
          js = 0.67
        else
          js = 1
        end
        ChangeValue(DamageSystem_Shjc, sy, add)
        ChangeValue(DamageSystem_Ssjianshao, sy, js, 1)
      end)
    end,
    effectname = "|cFFFF537E矢|r|cFFFF7195泽|r|cFFFF8FAB妮|r|cFFFFADC2可|r",
    effecttext = "|cFFFFECC4[凡俗]|r\n|cFFFF3366唯一 歌姬 同奏|r\n|cFFFFADC2提升[1%*歌姬变异]伤害加成|r\n|cFFFF3366【偶像宅】|r\n|cFFFFADC2处于BGM播放时:\n[提升33%伤害加成\n提升33%伤害减免]|r\n|cFFFF3366【niconiconi~】|r\n|cFFFFADC2偶尔带上口癖并激励队友(不包括自己)\n(在60秒内提升25%伤害加成,触发冷却10秒)|r",
    effectart = "Cq_Shizenike",
    test = "        "
  },
  {
    name = "战术少女",
    weight = 100,
    lv = 1,
    key = {"唯一"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:ishasskill(SKILL_TESHUYINGXIONG) then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("|cFFFF3366危难当前，唯有责任！|r")
      PlayGlobalSound(Sound_Nico_01)
      ChangeValue(Correction_Gun, sy, 0.1)
      u:setdata("Niko-夺冠概率", 1)
      local falcons_bonus = 0
      local independent_gun_bonus = 0
      
      local function refresh_falcons_bonus()
        ChangeValue(Correction_Gun, sy, 0.1 * -falcons_bonus)
        local main_var = u:returnmaxvar()
        falcons_bonus = 0.1 * u:getdata(main_var .. "变异数量")
        ChangeValue(Correction_Gun, sy, 0.1 * falcons_bonus)
      end
      
      local function refresh_agreement()
        if GetRandom100(50) then
          independent_gun_bonus = -0.5
          u:setdata("Niko-同意比赛")
          u:sendmessage("|cFFFFADC2[Niko同意了么]Niko本次比赛同意了|r")
        else
          independent_gun_bonus = 0.25
          u:deldata("Niko-同意比赛")
          u:sendmessage("|cFFFFADC2[Niko同意了么]Niko本次比赛不同意|r")
        end
      end
      
      local function advance_to_niko()
        if u:hasdata("Niko-进阶") then
          return false
        end
        u:setdata("Niko-进阶")
        u:setdata("变异判定-尼可拉科维奇")
        ChangeValue(Correction_Gun, sy, 0.4)
        independent_gun_bonus = 0.25
        refresh_falcons_bonus()
        u:addstexiao("尼可拉科维奇-独立枪械", "伤害判定前效果", function(args)
          local info = args.damageinfo
          if 0 < (info.xs_qx or 0) and independent_gun_bonus ~= 0 then
            info.damage = info.damage * (1 + independent_gun_bonus)
          end
        end)
        ac.loop(3000, function()
          if u:hasdata("Niko-进阶") then
            refresh_falcons_bonus()
          end
        end)
        u:uivar_change({
          keyname = var.name,
          keytype = "传奇栏",
          icon = "Cq_Xiaxianshaonv_Niko.tga",
          ishasphoto = true,
          text = "|cFF2F6FB0尼可拉.|r|cFFFFD447科维奇|r\n|cFFFFC800唯一|r\n|cFFEAF4FF提升50%枪械伤害|r\n|cFFFFC800【We are Falcons】|r\n|cFFEAF4FF提升[1%*主变异数量]枪械伤害|r\n|cFFFFC800【同意了么】|r\n|cFFEAF4FF过波时刷新该效果50%同意 50%不同意\n同意:降低50%枪械伤害(独立),必定不夺冠\n不同意:提升25%枪械伤害(独立)|r\n|cFFFFC800【我坐好了】|r\n|cFFEAF4FF过波时进行一次打比赛提升1.5%枪械伤害,同时:\n[5%获得Mojar冠军(首次提升10%枪械伤害)\n22%获得Mojar亚军(提升1%枪械伤害)]|r"
        })
        SendMsgAll("|cFFFFD447『THIS DAY! IS! HIS！』|r")
        local subtitles = {
          {
            time = 3500,
            text = "|cFF2F6FB0『TEN YEARS!』|r"
          },
          {
            time = 6300,
            text = "|cFFEAF4FF『In the 17 time of asking!』|r"
          },
          {
            time = 10000,
            text = "|cFFFFC800『Niko has his major!』|r"
          },
          {
            time = 14500,
            text = "|cFF2F6FB0『No longer will he be haunted by Boston!』|r"
          },
          {
            time = 18900,
            text = "|cFFEAF4FF『No longer tormented by Stockholm!』|r"
          },
          {
            time = 22400,
            text = "|cFFFFD447『Because he is forever a Major Champion in Cologne!』|r"
          },
          {
            time = 28900,
            text = "|cFF2F6FB0『An agonizing wait!』|r"
          },
          {
            time = 31200,
            text = "|cFFFFC800『But this,this is pure euphoria!』|r"
          },
          {
            time = 36100,
            text = "|cFFEAF4FF『The top of the Counter-Strike world!』|r"
          },
          {
            time = 39400,
            text = "|cFFFFD447『Dream!Finally realized!』|r"
          }
        }
        for _, subtitle in ipairs(subtitles) do
          local text = subtitle.text
          ac.wait(subtitle.time, function()
            SendMsgAll(text)
          end)
        end
        PlayBGM({
          bgm = BGM_Niko_02,
          time = 45,
          ID = 254,
          unit = u.handle
        })
        return true
      end
      
      local function run_match()
        local advanced = u:hasdata("Niko-进阶")
        if advanced then
          refresh_agreement()
          ChangeValue(Correction_Gun, sy, 0.015)
          refresh_falcons_bonus()
        else
          ChangeValue(Correction_Gun, sy, 0.005000000000000001)
        end
        local jg = 3
        local champion_chance = advanced and 5 or u:getdata("Niko-夺冠概率")
        if (not advanced or independent_gun_bonus ~= -0.5) and GetRandom100(champion_chance) then
          jg = 1
        elseif GetRandom100(22) then
          jg = 2
        end
        if jg == 2 then
          local strz = {
            "|cFF7DBEF1参加Mojar比赛发挥失误,痛失冠军",
            "|cFF7DBEF1参加Mojar比赛超常发挥带不动队友,痛失冠军",
            "|cFF7DBEF1参加Mojar比赛杀51个赢不了,痛失冠军",
            "|cFF7DBEF1参加Mojar比赛杀41个赢不了,痛失冠军"
          }
          SendMsgAll(u:getplayername() .. strz[GetRandomInt(1, #strz)])
          u:changedata("Niko-亚军数量", 1)
          ChangeValue(Correction_Gun, sy, 0.010000000000000002)
          u:sendmessage("|cFF7DBEF1[Mojar亚军]提升10%枪械修正")
          if not advanced and not u:hasdata("Niko-已获得冠军") and 5 > u:getdata("Niko-夺冠概率") then
            u:changedata("Niko-夺冠概率", 0.8)
          end
        end
        if jg == 3 then
          local strz = {
            "|cFF7DBEF1参加Mojar比赛淹死在海选",
            "|cFF7DBEF1参加Mojar比赛倒在八强",
            "|cFF7DBEF1参加Mojar比赛倒在四强"
          }
          SendMsgAll(u:getplayername() .. strz[GetRandomInt(1, #strz)])
          if not advanced and 5 > u:getdata("Niko-夺冠概率") then
            u:changedata("Niko-夺冠概率", 0.8)
          end
        end
        if jg == 1 then
          SendMsgAll(u:getplayername() .. "|cFFFFCC00参加Mojar比赛夺下了『冠军』！")
          local first_champion = not u:hasdata("Niko-已获得冠军")
          if first_champion then
            u:setdata("Niko-已获得冠军")
          end
          ChangeValue(Correction_Gun, sy, 0.1)
          u:sendmessage("|cFFFFCC00[Mojar冠军]提升100%枪械修正")
          if first_champion and not advanced then
            advance_to_niko()
          else
            PlayBGM({
              bgm = BGM_Niko_01,
              time = 50,
              ID = 219,
              unit = u.handle
            })
          end
        elseif not advanced then
          if GetRandom100(50) then
            if GetRandom100(10) then
              u:chat("|cFFFF3366和虫豸一起怎么能打好比赛呢！|r")
              PlayGlobalSound(Sound_Nico_02)
              u:additem("I0MM")
            else
              u:additem("I0MN")
            end
          else
            u:additem("I0MO")
          end
        end
      end
      
      u:addstexiao(var.name, "过波时效果", function(args)
        run_match()
      end)
    end,
    effectname = "|cFFFF3366虾线|r|cFFFF84A3少|r|cFFFFADC2女|r",
    effecttext = "|cFFFFECC4[凡俗]|r\n|cFFFF3366唯一|r\n|cFFFFADC2提升10%枪械伤害|r\n|cFFFF3366【红烧大虾】|r\n|cFFFFADC2过波时,如果自己没拿到冠军\n出大力了:获得一盘红烧大虾,10%获得碎裂的桌子\n没出大力:获得一盘冷冻龙虾|r\n|cFFFF3366【背身三发】|r\n|cFFFFADC2每射出3发子弹,25%下一发子弹会偏折45°|r\n|cFFFF3366【大赛软脚虾】|r\n|cFFFFADC2过波时进行一次打比赛提升0.5%枪械伤害,同时:\n[1%获得Mojar冠军(首次提升10%枪械伤害)\n22%获得Mojar亚军(提升1%枪械伤害)\n夺冠时进阶该变异\n未夺冠时提升0.8%夺冠概率(不会超过5%)]|r",
    effectart = "Ewl_Cq_Zhanshushaonv",
    test = "        "
  },
  {
    name = "黑虎阿福",
    weight = 100,
    lv = 1,
    key = {
      "唯一",
      "战士",
      "兽"
    },
    unique = true,
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
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Hhaf_01)
      u:chat("我叫黑虎阿福,你准备受死吧")
      u:setdata("阿福-特效基础伤害", 10600)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 8)
          local yxz = {
            {
              yx = Sound_Wbc_01,
              str = "大象踢腿"
            },
            {
              yx = Sound_Wbc_02,
              str = "猩猩折枝"
            },
            {
              yx = Sound_Wbc_03,
              str = "黑虎掠过秃鹰"
            },
            {
              yx = Sound_Wbc_04,
              str = "螳螂神拳"
            },
            {
              yx = Sound_Wbc_05,
              str = "黑虎掏心"
            },
            {
              yx = Sound_Wbc_06,
              str = "泰山压顶"
            },
            {
              yx = Sound_Wbc_07,
              str = "羚羊起跳"
            },
            {
              yx = Sound_Wbc_08,
              str = "乌鸦坐飞机"
            },
            {
              yx = Sound_Wbc_09,
              str = "龙卷风摧毁停车场"
            },
            {
              yx = Sound_Wbc_10,
              str = "骡子踢腿"
            }
          }
          local cs = 1
          while u:getluckrandom(44 * info.txgl) do
            if cs < 10 then
              cs = cs + 1
            else
              break
            end
          end
          local bbb = true
          ac.timer(800, cs, function()
            local sjs = GetRandomInt(1, 10)
            if not u:hasdata("系统-清净模式") then
              u:playsound(yxz[sjs].yx)
              if bbb then
                bbb = false
                u:chat(yxz[sjs].str)
              end
            end
            DamageUnit({
              bj = "黑虎阿福(武林高叟)",
              unit = tg.handle,
              source = u.handle,
              damage = u:getdata("阿福-特效基础伤害"),
              level = 1,
              type = "物理",
              isvest = true,
              isattack = true,
              isnoarmor = false,
              element = "无"
            })
            u:changedata("阿福-特效基础伤害", 1060)
            tg:effectadd("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl")
          end)
        end
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        if tg:isboss() then
          PlayGlobalSound(Sound_Hhaf_02)
          u:chat("阿福揍扁了" .. tg:getname())
          ChangeValue(Correction_Jzsh, sy, 0.05)
          ChangeValue(DamageSystem_Shjc, sy, 0.05)
        end
      end)
    end,
    effectname = "|cFF993300黑|r|cFFAE511E虎|r|cFFC46F3D阿|r|cFFD98D5B福|r",
    effecttext = "|cFFFFECC4[凡俗]|r\n|cFF993300唯一 战士 兽|r\n|cFF993300【武林高叟】|r\n|cFFD98D5B直接伤害时附带[10600]近战物理伤害,冷却8秒\n触发时有相同概率在0.8秒后再次触发(不会超过10次)\n每次触发永久提升1060该附伤基础伤害|r\n|cFF993300【阿福揍扁了成龙】|r\n|cFFD98D5B击杀BOSS时提升5%伤害加成与近战伤害|r",
    effectart = "Ewl_Cq_Heihuafu",
    test = "            "
  },
  {
    name = "文向",
    weight = 100,
    lv = 1,
    key = {"唯一", "水"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I0DI") then
        add = add + 3000
      end
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("|cFF3399FF破阵溃敌！")
      ac.wait(3200, function()
        u:chat("|cFF3399FF剑指中军！")
      end)
      PlayGlobalSound(Sound_Wenxiang_01)
      u:become("沉重")
      u:addstexiao(var.name, "伤害系统计算效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        info.jc = info.jc + tg:getperhp() * 0.01
      end)
      local add = 0
      ac.loop(1000, function()
        if u:getdata("文向-酒加成时间") > 0 then
          u:changedata("文向-酒加成时间", -1)
        end
      end)
    end,
    effectname = "|cFF3399FF文|r|cFF66AAFF向|r",
    effecttext = "|cFFFFECC4[凡俗]|r\n|cFF3399FF唯一 水|r\n|cFF3399FF【破军】|r\n|cFF66AAFF造成伤害时提升[目标当前生命百分比*100%]伤害加成|r",
    effectart = "war3mapImported\\BTNEwl_Xusheng_01.tga"
  },
  {
    name = "幻想杀手",
    weight = 100,
    lv = 1,
    key = {"唯一"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:getdata("魔导变异数量") > 0 then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("就让我用这只手，将你那无聊的幻想杀得片甲不留。")
      u:playsound(Sound_Tomu_02)
      u:changedata("魔导变异补正", -10000)
      ac.loop(3000, function()
        u:setdata("幸运", 0)
        u:setdata("魔力值", 0)
        Correction_Magic[sy] = 0
      end)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("神化判定-上条当麻") then
          info.damage = info.damage * (1.2 + 0.01 * u:getdata("系统-累积等级"))
        else
          info.damage = info.damage * (1.1 + 0.005 * u:getdata("系统-累积等级"))
        end
      end)
      if u:hasdata("权限-幻想杀手") then
        ac.wait(100, function()
          u:setdata("幻想杀手-神化可能")
          u:uivar_change({
            keyname = "幻想杀手",
            keytype = "传奇栏",
            text = "|cFF6666CC幻|r|cFF7777CC想|r|cFF8888CC杀|r|cFF9999CC手|r\n|cFFFFECC4[凡俗]|r\n|cFF6666CC唯一|r\n|cFF6666CC【异能消除】|r\n|cFF9999CC幸运锁定0\n魔力值锁定0\n法术修正锁定为0%\n降低10000%魔导补正\n提升[10%+0.5%*累积等级]近战伤害(独立)\n来自正面(180°)的非攻击伤害只造成5%伤害|r\n|cFF6666CC【你的幻想就由我来打破！】|r\n|cFF9999CC受到来自BOSS的伤害触发幻想杀手仍死亡时进阶|r"
          })
        end)
      end
    end,
    effectname = "|cFF6666CC幻|r|cFF7777CC想|r|cFF8888CC杀|r|cFF9999CC手|r",
    effecttext = "|cFFFFECC4[凡俗]|r\n|cFF6666CC唯一|r\n|cFF6666CC【异能消除】|r\n|cFF9999CC幸运锁定0\n魔力值锁定0\n法术修正锁定为0%\n降低10000%魔导补正\n提升[10%+0.5%*累积等级]近战伤害(独立)\n来自正面(180°)的非攻击伤害只造成5%伤害|r",
    effectart = "war3mapImported\\BTNEwl_Huanxiangyushou.blp"
  },
  {
    name = "植物学硕士",
    weight = 100,
    lv = 1,
    key = {
      "唯一",
      "自然",
      "影",
      "战士",
      "白毛"
    },
    unique = true,
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
      ciyuanget(u, var)
      SendMsgAll("|cFF66CC99道路已经打开了，接下来只要前进就好了。|r")
      PlayGlobalSound(Sound_Aoerjia_05)
      u:become("机动战士")
      Weiyi_New[5] = true
      u:addstexiao("植物学硕士", "被施加Buff时效果-暂停", function(args)
        if args.u:hasdata("奥尔加-卡其脱离太") and not Keyan_Guomintizhi then
          args.time = 0
        end
      end)
      u:addstexiao("植物学硕士", "被施加Buff时效果-僵直", function(args)
        if args.u:hasdata("奥尔加-卡其脱离太") and not Keyan_Guomintizhi then
          args.time = 0
        end
      end)
      ac.loop(30000, function()
        if u:isalive() and (u:hasdata("神器判定-卡其脱离太") or u:hasbuff("暂停") and u:getdata("暂停时间") <= 60) then
          u:settimedata("奥尔加-卡其脱离太", 20)
          ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 750, 20)
          u:clearbuff("暂停")
          u:clearbuff("僵直")
          u:sendmessage("|cFF009D00[奥尔加]卡其脱离太")
          if not u:hasdata("卡其脱离太播放冷却") then
            if u:hasdata("神器判定-卡其脱离太") then
              u:settimedata("卡其脱离太播放冷却", 180)
            else
              u:settimedata("卡其脱离太播放冷却", 60)
            end
            PlayBGM({
              bgm = Sound_Aoerjia_01,
              time = 20,
              ID = 50,
              unit = u.handle
            })
          end
        end
      end)
      u:setdata("奥尔加-伤害加成", 0)
      u:addstexiao(var.name, "过波时效果", function(args)
        u:setdata("奥尔加-伤害加成", 0)
      end)
      ac.wait(1, function()
        if u:hasdata("变异判定-赫德雷") and not u:hasdata("赫德雷-遇强则强") then
          u:setdata("赫德雷-遇强则强")
          u:addstexiao(var.name, "终结伤害计算效果", function(args)
            local tg = args.tg
            local u = args.u
            local info = args.damageinfo
            if tg:isboss() then
              info.end3 = info.end3 + 0.01 * u:getdata("怪物强度") * u:getstate("源石")
            elseif tg:iselite() then
              info.end3 = info.end3 + 0.25 * u:getstate("源石")
            else
              info.end3 = info.end3 - 0.85
              if info.end3 < 0 then
                info.end3 = 0.01
              end
            end
          end)
          u:uivar_change({
            keyname = "赫德雷",
            keytype = "传奇栏",
            text = "|cFF990000赫德雷|r\n|cFF990000[源石]\n恶魔 唯一 战士\n砺尘巨剑|r\n|cFF993333提升5%近战伤害\n近战伤害无视精英特性铁壁与坚硬|r\n|cFF990000及锋而试|r\n|cFF993333近战伤害对处于僵直或眩晕的单位提升[8%*源石]伤害|r\n|cFF990000余火之壁|r\n|cFF993333提升30点护甲\n受伤时使目标眩晕3秒,独立冷却10秒|r\n|cFF990000恶魔之血|r\n|cFF993333提升1%终结伤害\n提升3%原始伤害|r\n|cFF990000遇强则强实力不详|r\n|cFF993333对普通单位降低85%伤害\n对精英单位提升[25%]伤害\n对BOSS提升[目标怪物强度*1%]伤害|r"
          })
        end
      end)
    end,
    effectname = "|cFF009D00植|r|cFF2BB62B物|r|cFF56CE56学|r|cFF81E681硕|r|cFFACFFAC士|r",
    effecttext = "|cFFFFECC4[凡俗]|r\n|cFF009D00唯一 自然 影 战士|r\n|cFF009D00【卡其脱离太】|r\n|cFFACFFAC每隔30秒如果自身处于暂停状态(小于60秒)\n则立刻脱离暂停并在接下来的20秒内:\n[提升750额外移速并免疫暂停与僵直]|r\n|cFF009D00【刻在DNA里面的街道】|r\n|cFFACFFAC死亡时提升5%伤害加成(上限150%)\n过波时清空该加成|r\n|cFF009D00【！！！】|r\n|cFFACFFAC受到伤害时50%(触发时持续3秒后该效果进入10秒冷却):\n[闪避该次伤害并立刻随机瞬移至周围450码处\n提升该效果10%触发概率(上限90%)]\n(特殊BOSS战时只会在原地瞬移)|r",
    effectart = "war3mapImported\\BTNEwl_Aoerjia_Chuanqi.blp"
  },
  {
    name = "哭泣天使",
    weight = 25,
    lv = 1,
    key = {
      "唯一",
      "光明",
      "白毛",
      "根源"
    },
    unique = true,
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
      ciyuanget(u, var)
      u:sendmessage("|cFFEEECF9希|r|cFFE8E5F2望|r|cFFE1DFEB，|r|cFFDBD8E4只|r|cFFD4D2DE不|r|cFFCECBD7过|r|cFFC7C4D0是|r|cFFC1BEC9为|r|cFFBBB7C2了|r|cFFB4B0BB品|r|cFFAEAAB5尝|r|cFFA7A3AE绝|r|cFFA19DA7望|r|cFF9A96A0而|r|cFF948F99生|r|cFF8E8992的|r|cFF87828B，|r|cFF817C85愚|r|cFF7A757E蠢|r|cFF746E77的|r|cFF6E6870梦|r|cFF676169境|r|cFF615A62而|r|cFF5A545C已|r|cFF544D55。|r")
      u:addskill("A1Q6")
      u:addstexiao(var.name, "过波时效果", function(args)
        u:effectadd("kuqitianshi_qidao.mdx")
        u:effectadd("kuqitianshi_qidao2.mdx")
        u:sendmessage("|cFFF1EFFC哭|r|cFF776B75泣|r|cFFF1EFFC天|r|cFF776B75使|r|cFFF1EFFC-祈|r|cFF776B75祷|r")
        local del = 0.1 * u:getmaxhp() + 100
        if del >= u:getmaxhp() then
          del = u:getmaxhp() - 2
        end
        u:changeoriginmaxhp(-1 * del)
        u:sendmessage("|cFFF1EFFC降低" .. math.floor(del) .. "点基础生命上限|r")
        local b = false
        local jl = 17
        local jladd = 17
        if u:getluckrandom(jl) then
          b = true
          jl = 7
          jladd = 7
          local addz = 0.01 * del
          u:sendmessage("|cFFF1EFFC提升" .. math.floor(addz) .. "点属性|r")
          u:setdata("系统-力量不提升上限")
          u:addrandomstats(addz)
          u:deldata("系统-力量不提升上限")
        else
          jl = jl + jladd
        end
        if u:getluckrandom(jl) then
          b = true
          jl = 7
          jladd = 7
          local addz = 0.005 * del
          u:sendmessage("|cFFF1EFFC提升" .. math.floor(addz) .. "点属性|r")
          u:setdata("系统-力量不提升上限")
          u:addrandomstats(addz)
          u:deldata("系统-力量不提升上限")
        else
          jl = jl + jladd
        end
        if u:getluckrandom(jl) then
          b = true
          jl = 7
          jladd = 7
          local addz = 0.01 * del
          u:sendmessage("|cFFF1EFFC提升" .. math.floor(addz) .. "%伤害修正|r")
          u:addrandomdamage(addz)
        else
          jl = jl + jladd
        end
        if u:getluckrandom(jl) then
          b = true
          jl = 7
          jladd = 7
          local addz = 0.005 * del
          u:sendmessage("|cFFF1EFFC提升" .. math.floor(addz) .. "%伤害修正|r")
          u:addrandomdamage(addz)
        else
          jl = jl + jladd
        end
        if u:getluckrandom(jl) then
          b = true
          jl = 7
          jladd = 7
          u:sendmessage("|cFFF1EFFC该变异增加1个光明字段|r")
          u:changedata("光明变异数量", 1)
        else
          jl = jl + jladd
        end
        if u:getluckrandom(jl) or not b then
          b = true
          jl = 7
          jladd = 7
          u:sendmessage("|cFFF1EFFC该变异增加1个黑暗字段|r")
          u:changedata("黑暗变异数量", 1)
        else
          jl = jl + jladd
        end
        if GetRandom100(7) then
          local addz = 0.01 * del
          u:sendmessage("|cFFF1EFFC提升" .. math.floor(addz) .. "点全属性|r")
          u:setdata("系统-力量不提升上限")
          u:addallstats(addz)
          u:deldata("系统-力量不提升上限")
          u:sendmessage("|cFF776B75[哭泣|r|cFFA097A2天使]|r|cFFC8C3CF神|r|cFFF1EFFC泣-提升" .. math.floor(addz) .. "点全属性|r")
        end
      end)
    end,
    effectname = "|cFF776B75哭|r|cFFA097A2泣|r|cFFC8C3CF天|r|cFFF1EFFC使|r",
    effecttext = "|cFFFFECC4[凡俗]|r\n|cFF776B75唯一 光明 根源|r\n|cFF776B75【六翼哀歌】|r\n|cFFF1EFFC过波时,降低[10%+100]基础生命上限并随机触发至少一项：\n①提升[损失上限*0.01]点属性(不提升生命上限)\n②提升[损失上限*0.005]点属性(不提升生命上限)\n③提升[损失上限*0.001%]伤害加成\n④提升[损失上限*0.0005%]伤害加成\n⑤该变异增加1个光明字段\n⑥该变异增加1个黑暗字段\n极低概率提升[损失上限*0.01]点全属性(不提升生命上限)|r",
    effectart = "war3mapImported\\PASBTNEwl_Zx_Kuqitianshi"
  }
}

local function rwby_add_vitality_scaling(u, gun_scale, weapon_scale)
  local sy = u.ownerid
  local gun_bonus = 0
  local weapon_bonus = 0
  
  local function refresh()
    ChangeValue(Correction_Gun, sy, 0.1 * -gun_bonus)
    ChangeValue(Correction_Jzsh, sy, 0.1 * -weapon_bonus)
    local vitality = u:getdata("元气值")
    gun_bonus = gun_scale * vitality
    weapon_bonus = weapon_scale * vitality
    ChangeValue(Correction_Gun, sy, 0.1 * gun_bonus)
    ChangeValue(Correction_Jzsh, sy, 0.1 * weapon_bonus)
  end
  
  refresh()
  ac.loop(3000, refresh)
end

local function rwby_add_close_shot(u, name)
  u:addstexiao(name .. "-抵近射击", "近战伤害效果", function(args)
    local info = args.damageinfo
    local cooldown_key = name .. "-抵近射击冷却"
    local queued_key = name .. "-抵近射击排队中"
    if info and not info.isvestdamage and not u:hasdata(cooldown_key) and not u:hasdata(queued_key) then
      u:setdata(queued_key)
      local tg = args.tg
      
      local function fire()
        if u:hasdata("抵近射击-公共冷却") then
          ac.wait(100, fire)
          return
        end
        u:deldata(queued_key)
        u:settimedata(cooldown_key, 1)
        u:settimedata("抵近射击-公共冷却", 0.1)
        local x, y = tg:getxy()
        u:setdata("抵近射击-射击中")
        u:setdata(name .. "-抵近射击弹幕")
        gunshoot(u.handle, "A0ML", x, y, true)
        u:deldata(name .. "-抵近射击弹幕")
        u:deldata("抵近射击-射击中")
      end
      
      fire()
    end
  end)
end

local function weiss_remove_attribute_bonus(u)
  local sy = u.ownerid
  local attribute = u:getdata("柳叶白菀-属性")
  local bonus = u:getdata("柳叶白菀-属性加成")
  if attribute == "根源" then
    ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -bonus)
  elseif attribute == "冰" then
    ChangeValue(Damage_Element_Ice, sy, -bonus)
  elseif attribute == "炎" then
    ChangeValue(Damage_Element_Fire, sy, -bonus)
  elseif attribute == "风" then
    ChangeValue(Damage_Element_Wind, sy, -bonus)
  end
end

local function weiss_apply_attribute_bonus(u)
  local sy = u.ownerid
  local attribute = u:getdata("柳叶白菀-属性")
  local vitality = u:getdata("元气值")
  local bonus = 0.05 * vitality
  if attribute == "根源" then
    bonus = 10 * vitality
    ChangeValue(HeroMenu_ExtraMoveSpeed, sy, bonus)
  elseif attribute == "冰" then
    ChangeValue(Damage_Element_Ice, sy, bonus)
  elseif attribute == "炎" then
    ChangeValue(Damage_Element_Fire, sy, bonus)
  elseif attribute == "风" then
    ChangeValue(Damage_Element_Wind, sy, bonus)
  end
  u:setdata("柳叶白菀-属性加成", bonus)
end

Vars_Ciyuan_Lv2 = {
  {
    name = "猫头鹰因子",
    weight = 5,
    lv = 2,
    key = {"唯一", "影"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      if u:ishasitem("I05G") then
        local wp = u:getitem("I05G")
        if GetItemCharges(wp) >= 10 then
          add = add + 2000
        end
      end
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("判定-猫头鹰因子") then
        b = true
      end
      if u.type == HeroType["缇娜"] and u:ishasitem("I05G") then
        local wp = u:getitem("I05G")
        if GetItemCharges(wp) >= 10 then
          b = true
        end
      end
      if u:ishasskill(SKILL_TESHUYINGXIONG) then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Tina_Get_01)
      SendMsgAll("|cFF6666CC『我叫……缇娜』")
      SendDtimeMsgAll(2.3, "|cFF6666CC『缇娜.斯普朗特』")
      ChangeValue(Correction_Gun, sy, 0.025)
      ChangeValue(Correction_Gun_Bullet, sy, 0.1)
      u:addstexiao(var.name, "杀敌效果", function(args)
        ChangeValue(Correction_Gun, sy, 1.0E-4)
      end)
      ac.loop(250, function()
        if u:isalive() then
          if IsTimeNight() or u:getdata("咖啡持续时间") > 0 then
            if Group_Counts(Group_Xingcunzu) > 1 then
              u:buffset(u.handle, 0.5, "隐身")
            end
            if not u:hasdata("夜子夜晚判定") then
              u:setdata("夜子夜晚判定")
              ChangeValue(HeroMenu_HpChange_MaxHp, sy, 0.5)
            end
            if u:hasdata("夜子白天判定") then
              u:deldata("夜子白天判定")
              u:delskill("S04J")
            end
          else
            if u:hasdata("夜子夜晚判定") then
              u:deldata("夜子夜晚判定")
              ChangeValue(HeroMenu_HpChange_MaxHp, sy, -0.5)
            end
            if not u:hasdata("夜子白天判定") then
              u:setdata("夜子白天判定")
              u:addskill("S04J")
            end
          end
        end
      end)
    end,
    effectname = "|cFF6666CC猫|r|cFF7373CC头|r|cFF8080CC鹰|r|cFF8C8CCC因|r|cFF9999CC子|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF9999CC提升2.5%枪械伤害|r\n|cFF6666CC【武装狙击】|r\n|cFF9999CC提升10%子弹伤害\n提升[50*累积等级]子弹基础伤害\n杀敌时提升0.01%枪械伤害|r\n|cFF6666CC【夜子】|r\n|cFF9999CC白天降低50%移速\n夜晚提升0.5%生命恢复,有队友存活时隐身|r",
    effectart = "war3mapImported\\BTNEwl_Maotouying.blp",
    test = "    "
  },
  {
    name = "普利凯特",
    weight = 1200,
    lv = 2,
    key = {
      "唯一",
      "歌姬",
      "外域",
      "童话"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("普利凯特-获取可能") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("|cFFFF4B4B「去寻觅爱的浪漫吧~☆」|r")
      u:setdata("属性-歌姬传奇")
      u:changedata("爱丽丝-梦境值", 1)
      local exp = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Exp, sy, -2 * exp)
        exp = 0.025 * u:getstate("歌姬变异")
        ChangeValue(Correction_Exp, sy, 2 * exp)
        if BGMIsChange then
          if not u:hasdata("普利凯特-提升") then
            u:setdata("普利凯特-提升")
            ChangeValue(DamageSystem_EndSh, sy, 0.005000000000000001)
            ChangeValue(Hero_Tili_Huifu, sy, 0.2)
          end
        elseif u:hasdata("普利凯特-提升") then
          u:deldata("普利凯特-提升")
          ChangeValue(DamageSystem_EndSh, sy, -0.005000000000000001)
          ChangeValue(Hero_Tili_Huifu, sy, -0.2)
        end
      end)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        u:changemaxhp(100 * u:getstate("歌姬变异"))
        if GetRandom100(5) then
          u:addlevel(-1)
          u:sendmessage("|cFFFF4B4B「这种秘密的约会真实让人心跳不已呢ミ☆」|r")
        end
        if GetRandom100(5) then
          TalentCode[sy] = TalentCode[sy] + 1
          u:sendmessage("|cFFFF4B4B「普利凯特惊讶☆」|r")
        end
        if not u:hasdata("普利凯特-戒指已获取") and u:getlevel() >= 75 then
          u:setdata("普利凯特-戒指已获取")
          u:additem("I0KV")
          u:sendmessage("|cFFFF6699「今天真是愉快呢□\n    这就是所谓的仅此一夜的逃离尘世对吧？对吧？\n    嘻嘻☆」|r")
          ac.wait(3000, function()
            u:sendmessage("|cFFFF6699「不过，要当个普通的女孩子对我来说有点难呢。\n    ······下次我会展现更高的女子力的☆ミ拜拜！」 |r")
          end)
        end
      end)
      u:addstexiao(var.name, "受伤后效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if args.damage >= 0.1 * u:getmaxhp() and tg.handle ~= u.handle and not u:hasdata(var.name .. "-免疫冷却") then
          u:settimedata(var.name .. "-免疫冷却", 40)
          u:buffset(u.handle, 1, "伤害免疫")
          u:sendmessage("|cFF515100爱丽丝01-伤害免疫|r")
        end
      end)
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and not u:hasdata("普利凯特-决死冷却") then
          args.dt = false
          u:settimedata("普利凯特-决死冷却", 300)
          u:buffset(u.handle, 2, "无敌")
          u:sendmessage("|cFF515100爱丽丝01-决死|r")
          SetTimeOfDay(17.3)
        end
      end)
      ac.wait(10, function()
        u:uivar_change({
          keyname = "普利凯特",
          keytype = "传奇栏",
          icon = "NewIcon_Alice_Plkt_Ph.tga",
          ishasphoto = true,
          smallicon = "Ewl_Alice_Plkt.tga"
        })
        local AAA = class.model:builder({
          model = "wt_mb1.mdx",
          x = 0,
          y = 1050,
          w = 1,
          h = 1
        })
        AAA:set_alpha(200)
        AAA:set_scale(0.34, 0.38, 0.38)
        AAA:set_animation_by_index(0)
        AAA:set_speed(1)
        local aaa
        ac.wait(1300, function()
          AAA:set_speed(0)
        end)
        ac.wait(3300, function()
          AAA:set_speed(1)
          aaa = class.panel:builder({
            x = 400,
            y = 498,
            w = 455.0,
            h = 355.0,
            normal_image = "PhNew_Plkt.blp"
          })
          aaa:set_alpha(155)
        end)
        ac.wait(4700, function()
          AAA:set_speed(0)
        end)
        AAA:set_rotate_z(270)
        AAA:set_level(2)
        ac.wait(121000, function()
          AAA:destroy()
          aaa:destroy()
        end)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:buffset(u.handle, 6, "绝对闪避")
        end)
        songtext({
          text = {
            {
              starttime = 29,
              str = "向划过夜空的甜甜的流星"
            },
            {
              starttime = 36,
              str = "伸出双手许下愿望"
            },
            {
              starttime = 42,
              str = "想要跨越虹之桥,鲸之云"
            },
            {
              starttime = 48,
              str = "将双手都拿不下的心形糖果献给你"
            },
            {
              starttime = 55,
              str = "就算只是在梦里也好"
            },
            {
              starttime = 58,
              str = "我想要更加更加的感受你"
            },
            {
              starttime = 61,
              str = "就算只有一回"
            },
            {
              starttime = 64,
              str = "我会珍惜与你的每一秒"
            },
            {
              starttime = 67,
              str = "一起欢笑,互相拥抱,齐声哭泣"
            },
            {
              starttime = 75,
              str = "记录下每一页的崭新篇章"
            },
            {
              starttime = 77,
              str = "两人的互相誓约"
            },
            {
              starttime = 80,
              str = "一起散步,一起并肩"
            },
            {
              starttime = 85,
              str = "乘着星云的轨道"
            },
            {
              starttime = 87,
              str = "一同前往下一个银河",
              time = 5
            }
          },
          color = "FFFF4B4B"
        })
        PlayBGM({
          bgm = alice_plkt,
          time = 125,
          ID = 191,
          unit = u.handle
        })
        if u:hasdata("特殊判定-爱丽丝初始") or CIUC[sy] == "1932310753" then
          Boolean_ColorName[sy] = true
          ColorName[sy][1] = {
            method = 1,
            name = "☆☆赤之偶像「普利凯特」☆☆",
            colors = {
              "EB4747",
              "FFFFFF",
              "EB4747"
            },
            lengthcd = 30
          }
          local cs = 1
          ac.loop(6000, function()
            if cs == 0 then
              cs = 1
              ColorName[sy][1] = {
                method = 1,
                name = "☆☆赤之偶像「普利凯特」☆☆",
                colors = {
                  "EB4747",
                  "FFFFFF",
                  "EB4747"
                },
                lengthcd = 30
              }
            else
              cs = 0
              ColorName[sy][1] = {
                method = 1,
                name = "最初的爱丽丝「爱丽丝01」",
                colors = {
                  "FFCC00",
                  "515100",
                  "FFCC00"
                },
                lengthcd = 30
              }
            end
          end)
        end
      end)
    end,
    effectname = "|cFFF55D5C普|r|cFFED4A4A利|r|cFFE53837凯|r|cFFDC2525特|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFED4A4A童话 歌姬 外域 唯一|r\n|cFFE53837【赤之偶像】|r\n|cFFDC2525提升1点梦境值\n提升[歌姬变异*100]生命成长\n提升[歌姬变异*5%]经验获取\n提升50%过波奖励数值（向下取整）\n升级时5%降低1级\n升级时5%额外获取1点天赋点\n使用魔力药水时25%不消耗\n自身播放歌曲时提升3%当前生命上限,1%当前智力与0.5体力上限\n处于歌曲播放时提升0.5%终结伤害与0.2体力恢复|r\n|cFFFFCC00【爱|r|cFFE2B800丽|r|cFFC5A300丝|r|cFFA88E000|r|cFF8B7A001】|r\n|cFFFFCC00「|r|cFFE6BA00数|r|cFFCDA900据|r|cFFB49700删|r|cFF9C8600除|r|cFF837400」|r\n|cFF515100「对不起\n都是因为我才害你遭受了这么痛苦的经历」\n「我不该逃走的\n就应该像这样,陪在您的身边才对」|r",
    effectart = "Ewl_Alice_Plkt",
    test = [[

    ]]
  },
  {
    name = "光之理的盗窃者",
    weight = 25,
    lv = 2,
    key = {
      "唯一",
      "光明",
      "魔导"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:isgirl() then
        b = true
      end
      if u:getdata("传奇数量") > 0 then
        b = false
      end
      if 0 < u:getdata("系统-神力承载") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:sendmessage("|cFFBFA68F真是让人羡慕呢，你啊|r")
      Danwei_Gzl = u.handle
      ChangeValue(HeroMenu_HpForever_MaxHp, sy, 0.25)
      ChangeValue(Hero_Tili_Huifu, sy, 0.05)
      ChangeValue(DamageSystem_Shjc, sy, 0.025)
      ChangeValue(Correction_Magic, sy, 0.003)
      local add = 0
      local hp = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, -1 * add)
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, -1 * hp)
        add = 0.12 * (Correction_Magic[sy] - 1)
        if IsTimeDay() then
          hp = 0.25
          u:deldata("光之理-视野扩大")
        else
          hp = 0
          u:setdata("光之理-视野扩大")
        end
        ChangeValue(DamageSystem_Shjc, sy, 1 * add)
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, 1 * hp)
      end)
      u:addskill("A1SJ")
      u:addskill("A1SI")
      AddAllSTexiao(var.name, "伤害系统计算效果", function(args)
        local u = args.u
        local info = args.damageinfo
        if u:ishasbuff("B0E2") then
          info.lw = info.lw + 0.3
          info.zj = info.zj + 0.3
        end
      end)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:addtrgevent("单位-被攻击", function(args)
          local soc = args.soc
          local u = args.u
          if soc:ishasbuff("B0E3") and u:getluckrandom(30) then
            soc:buffset(u.handle, 1, "暂停")
          end
        end)
      end)
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and not u:hasdata("光之理-死体化冷却") then
          args.dt = false
          u:settimedata("光之理-死体化冷却", 600)
          ChangeTimeValue(HeroMenu_HpForever_MaxHp, sy, 3, 10)
          u:sendmessage("|cFFBFA68F光之理-死体化|r")
          ac.wait(10000, function()
            if u:getperhp() <= 50 then
              u:kill(u.handle)
            else
              u:losshp(u, 0, 0, 50)
            end
          end)
        end
      end)
    end,
    effectname = "|cFFB39579光|r|cFFB79C84之|r|cFFBBA48F理|r|cFFBFAC9A的|r|cFFC3B3A4盗|r|cFFC7BAAF窃|r|cFFCBC2BA者|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFB39579唯一 光明 魔导|r\n|cFFCBC2BA提升2.5%伤害加成|r\n|cFFB39579【魔石人类】|r\n|cFFCBC2BA提升0.25%永恒恢复\n提升0.05体力恢复\n提升3%法术修正\n提升[12%*法术修正]伤害加成|r\n|cFFB39579【光之御旗】|r\n|cFFCBC2BA提升900范围内友军20护甲与20%全属性抗性\n提升900范围内友军3%伤害加成\n900范围内友军受到的伤害时减少50%并由自身代为承受|r\n|cFFB39579【光之理】|r\n|cFFCBC2BA白天时提升0.25%永恒回复,夜晚时扩大视野范围\n900范围内敌军进行攻击时30%概率被暂停1秒\n900范围内敌军使用技能时30%概率被沉默1秒|r\n|cFFB39579【半死体化】|r\n|cFFCBC2BA受到致死伤害时抵挡该次伤害并进入10秒半死体化,期间提升3%永恒回复,时间结束时损耗50%最大生命值,不足则致死,触发冷却600秒|r\n|cFFB39579【真正的魔法】|r\n|cFFCBC2BA『反狱』六十，盈满产声。惟愿与君，同日降生。|r",
    effectart = "Ewl_Gzl_01",
    test = [[

            ]]
  },
  {
    name = "光荣女仆",
    weight = 100,
    lv = 2,
    key = {
      "机械",
      "战士",
      "光明"
    },
    unique = false,
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
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Ann_Get)
      SendMsgAll("|cFFFF9900『无|r|cFFFF9E07论|r|cFFFFA30F是|r|cFFFFA816早|r|cFFFFAC1D上|r|cFFFFB124，|r|cFFFFB62C午|r|cFFFFBB33间|r|cFFFFC03A，|r|cFFFFC542晚|r|cFFFFCA49上|r|cFFFFCE50，|r|cFFFFD357安|r|cFFFFD85F会|r|cFFFFDD66永|r|cFFFFE26D远|r|cFFFFE775陪|r|cFFFFEC7C着|r|cFFFFF083你|r|cFFFFF58A。』|r")
      u:changedata("女仆变异数量", 1)
      u:become("女仆")
      u:become("机械生命")
      local data1 = 0
      local data2 = 0
      
      local function refresh_saijier_bonus()
        ChangeValue(DamageSystem_Shjc, sy, -data1)
        ChangeValue(Correction_Jzsh, sy, -data2)
        local citiao1 = u:getstate("光明变异")
        data1 = 0.01 * citiao1
        data2 = 0.005 * citiao1
        ChangeValue(DamageSystem_Shjc, sy, data1)
        ChangeValue(Correction_Jzsh, sy, data2)
      end
      
      refresh_saijier_bonus()
      ac.loop(3000, refresh_saijier_bonus)
      local ewys = 0
      local cs = 0
      local cs2 = 0
      ac.loop(3000, function()
        if u:isalive() then
          cs2 = cs2 + 1
          local max = 30
          if Keyan_Weizhanshike then
            max = max * Weizhanxishu
          end
          if max <= cs2 then
            cs2 = 0
            u:sethp(100, true)
          end
        end
        if 1 > u:getdata("光荣女仆-时空之刃伤害") then
          u:changedata("光荣女仆-时空之刃伤害", 0.25)
          ChangeValue(Correction_Jzsh, sy, 0.25)
        end
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -ewys)
        ewys = 0.06 * u:getstate("光明变异")
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, ewys)
      end)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("光荣女仆-时空之刃伤害") and not info.isvestdamage then
          local down = u:getdata("光荣女仆-时空之刃伤害")
          ChangeValue(Correction_Jzsh, sy, -down)
          u:setdata("光荣女仆-时空之刃伤害", 0)
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not tg:hasdata(var.name .. "-特效冷却") then
          tg:settimedata(var.name .. "-特效冷却", 2)
          tg:buffset(u.handle, 1, "暂停")
        end
      end)
      u:addskill("S0BC")
    end,
    effectname = "|cFFFF9900光|r|cFFFFAD33荣|r|cFFFFC266女|r|cFFFFD699仆|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFFF9900机械 战士 光明|r\n|cFFFFD699提升[机械变异*1%]伤害加成\n提升[光明变异*0.5%]近战伤害|r\n|cFFFF9900【时空之刃】|r\n|cFFFFD699每3秒提升25%近战伤害\n最多叠加4层,直至下次近战直接伤害|r\n|cFFFF9900【秒针.瞬间加速】|r\n|cFFFFD699提升[6%*光明变异]额外移速\n直接伤害10%时停目标1秒,独立冷却2秒|r\n|cFFFF9900【时针.流逝缓慢】|r\n|cFFFFD699周围600范围敌军减速33%|r\n|cFFFF9900【时间回溯】|r\n|cFFFFD699每90秒修改生命值至100%|r",
    effectart = "Ewl_Chuanqi_Guangrongnvpu_8",
    test = [[

            ]]
  },
  {
    name = "艾拉",
    weight = 100,
    lv = 2,
    key = {
      "唯一",
      "白毛",
      "同奏",
      "机械"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if PlayerCount > 1 then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cFFD8BBD3『|r|cFFDABDD4执|r|cFFDBC0D5行|r|cFFDDC2D6任|r|cFFDFC5D7务|r|cFFE1C7D8时|r|cFFE2CADA…|r|cFFE4CCDB…|r|cFFE6CFDC我|r|cFFE8D1DD才|r|cFFE9D4DE能|r|cFFEBD6DF找|r|cFFEDD8E0到|r|cFFEEDBE1活|r|cFFF0DDE2着|r|cFFF2E0E3的|r|cFFF4E2E4意|r|cFFF5E5E6义|r|cFFF7E7E7…|r|cFFF9EAE8…|r|cFFFBECE9』|r")
      PlayGlobalSound(Sound_Aila_01)
      u:become("机械生命")
      ChangeValue(DamageSystem_Shjc, sy, 0.025)
      u:setdata("艾拉-记忆", 0)
      local gs = 0
      local add = 0
      ac.loop(1000, function()
        u:changedata("固定伤害", 0.1 * -gs)
        gs = TONGZOU_Count * u:getdata("艾拉-记忆")
        u:changedata("固定伤害", 0.1 * gs)
        if not u:isalive() then
          u:changedata("艾拉-记忆", -3)
        end
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq.handle ~= u.handle then
            local jyadd = 0
            if xq:isalive() then
              local dis = DistanceBetweenUnits(u.handle, xq.handle)
              if dis <= 1800 then
                jyadd = 4
              else
                jyadd = 2
              end
            else
              jyadd = 0
            end
            u:changedata("艾拉-记忆", jyadd)
          end
        end)
        for i = 1, 6 do
          ChangeValue(Correction_Exp, i, -2 * add)
          ChangeValue(Correction_Gold, i, -add)
          ChangeValue(DamageSystem_EndSh, i, 0.1 * (-add / 3))
          ChangeValue(DamageSystem_Baoji, i, -add * 100)
          ChangeValue(DamageSystem_Baoshang, i, -add)
          ChangeValue(DamageSystem_Shjc, i, 0.1 * (-add * 2))
        end
        if u:getdata("艾拉-记忆") >= 3600 then
          add = 0.075
        else
          add = 0
        end
        for i = 1, 6 do
          ChangeValue(Correction_Exp, i, 2 * add)
          ChangeValue(Correction_Gold, i, add)
          ChangeValue(DamageSystem_EndSh, i, 0.1 * (add / 3))
          ChangeValue(DamageSystem_Baoji, i, add * 100)
          ChangeValue(DamageSystem_Baoshang, i, add)
          ChangeValue(DamageSystem_Shjc, i, 0.1 * (add * 2))
        end
        if u:getdata("艾拉-记忆") <= 0 then
          u:setdata("艾拉-记忆", 0)
        end
      end)
    end,
    effectname = "|cFFD8BBD3艾|r|cFFFEF1EB拉|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFD8BBD3唯一 白毛 同奏 机械|r\n|cFFFEF1EB提升2.5%伤害加成\n提升[记忆*1*全队同奏变异]固定伤害|r\n|cFFD8BBD3【可塑性记忆】|r\n|cFFFEF1EB每秒提升[存活队友*2]记忆\n自身死亡时降低20%记忆\n自身处于死亡状态时每秒降低3点记忆\n自身1800范围内友军提供的记忆翻倍|r\n|cFFD8BBD3【治愈系记忆(记忆≥3600时激活):】|r\n|cFFFEF1EB[提升全队3%伤害加成\n提升全队7.5%积分获取\n提升全队15%经验获取\n提升全队15%暴击率\n提升全队15%暴击伤害\n提升全队5%终结伤害]|r",
    effectart = "Ewl_Cq_Aila",
    test = "                "
  },
  {
    name = "阿尔图罗",
    weight = 100,
    lv = 2,
    key = {
      "源石",
      "黑暗",
      "魔导"
    },
    unique = false,
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
      ciyuanget(u, var)
      SendMsgAll("|cFF8D807E『|r|cFF928684“|r|cFF978C8A塑|r|cFF9D9290心|r|cFFA29896”|r|cFFA79D9C，|r|cFFACA3A2您|r|cFFB1A9A8可|r|cFFB6AFAE以|r|cFFBCB5B3如|r|cFFC1BBB9此|r|cFFC6C1BF称|r|cFFCBC6C5呼|r|cFFD0CCCB我|r|cFFD6D2D1』|r")
      PlayGlobalSound(Sound_Aetl_01)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 5)
          tg:changetimedata("凋亡损伤-叠加值", 50000, 5)
        end
      end)
      AddAllSTexiao("凋亡损伤", "伤害判定后特效", function(args)
        dwss(args)
      end)
    end,
    effectname = "|cFF8D807E阿|r|cFFA99F9E尔|r|cFFC4BFBD图|r|cFFE0DEDD罗|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF8D807E黑暗 魔导 源石|r\n|cFF8D807E【无词哀歌】|r\n|cFFE0DEDD自身[凋亡损伤]效果提升33%\n直接伤害时施加[50000]凋亡损伤5秒,冷却5秒|r",
    effectart = "Cq_Aetl",
    test = "            "
  },
  {
    name = "RABBIT4",
    weight = 100,
    lv = 2,
    key = {"唯一", "学生"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:ishasskill(SKILL_TESHUYINGXIONG) then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Meiyou_01)
      SendMsgAll("|cFFACE0F6『霞泽美游……那个，我想先回去了……果然还是不行吧……』|r")
      u:become("学生")
      u:addstexiao(var.name, "子弹创建时效果", function(args)
        if args.lx == 3 then
          local mj = args.mj
          mj:setdata("霞泽美游-胆怯者的观测")
        end
      end)
      ChangeValue(Correction_Gun, sy, 0.05)
      ChangeValue(DamageSystem_Baoshang, sy, 0.25)
      u:addstexiao(var.name, "子弹伤害后效果", function(args)
        local tg = args.tg
        if args.mj:hasdata("霞泽美游-胆怯者的观测") and not args.tg:hasdata("霞泽美游-弱点把握") then
          tg:settimedata("霞泽美游-弱点把握", 10)
          tg:changetimearmor(-25, 10)
          tg:changetimedata("怪物-额外受伤", 0.1, 10)
        end
        u:changedata("霞泽美游-意料之外的一击计数", 1)
        if u:getdata("霞泽美游-意料之外的一击计数") >= 3 then
          u:changedata("霞泽美游-意料之外的一击计数", -3)
          args.damage = args.damage * 2
        end
        if tg:hasdata("霞泽美游-弱点把握") then
          local txsh = 1000 * u:getlevel()
          DamageUnit({
            bj = "霞泽美游(弱点把握)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
        end
      end)
      u:addstexiao(var.name, "枪械装弹时效果", function(args)
        if args.lx == 3 then
          if not u:hasdata("霞泽美游-狙击用特殊弹") then
            u:setdata("霞泽美游-狙击用特殊弹", 30)
            ChangeValue(DamageSystem_Baoshang, sy, 0.4)
            ac.loop(1000, function(t)
              u:changedata("霞泽美游-狙击用特殊弹", -1)
              if u:getdata("霞泽美游-狙击用特殊弹") <= 0 then
                u:deldata("霞泽美游-狙击用特殊弹")
                ChangeValue(DamageSystem_Baoshang, sy, -0.4)
                t:remove()
              end
            end)
          else
            u:setdata("霞泽美游-狙击用特殊弹", 30)
          end
        end
      end)
    end,
    effectname = "|cFFACE0F6RABBIT4|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFACE0F6唯一 学生|r\n|cFFEFE8EB提升5%枪械伤害|r\n|cFFACE0F6【胆怯者的观测】|r\n|cFFEFE8EB枪械伤害对拥有[弱点把握]单位附带[等级*1000]物理伤害\n狙击枪伤害附加10秒弱点把握(降低25护甲,提升10%额外受伤,无法叠加)|r\n|cFFACE0F6【意料之外的一击】|r\n|cFFEFE8EB子弹每命中3次,下一发子弹造成200%伤害(独立)|r\n|cFFACE0F6【深呼吸】|r\n|cFFEFE8EB提升25%暴击伤害|r\n|cFFACE0F6【狙击用特殊弹】|r\n|cFFEFE8EB狙击枪成功装弹后在30秒内提升40%暴击伤害,无法叠加,刷新计时|r",
    effectart = "war3mapImported\\BTNEwl_Cq_Meiyou"
  },
  {
    name = "病弱",
    clickfunc = function(u, ewl)
      local sy = u.ownerid
      if u:isalive() and Weiyi[2] == false and not u:hasdata("变异判定-冲田总司") and u:ishasshw() and u:getdata("咳血杀敌") >= 125 and u:isalive() then
        AdvanceGet["冲田总司"](u)
      end
    end,
    weight = 100,
    lv = 2,
    key = {"战士"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I020") then
        add = add + 500
      end
      if u:ishasitem("I021") then
        add = add + 500
      end
      if u:hasdata("隐藏职业-天才剑士") then
        add = add + 500
      end
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cFF3399FF『冲田总司参上！你就是我的御主么……』")
      PlayGlobalSound(Sound_Ctzs_01)
      ChangeValue(DamageSystem_Shjc, sy, 0.12)
      ChangeValue(Correction_Jzsh, sy, 0.12)
      ChangeValue(DamageSystem_Baoji, sy, 12)
      ChangeValue(DamageSystem_Baoshang, sy, 0.12)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata("总司-三段突冷却") then
          u:settimedata("总司-三段突冷却", 0.25)
          if u:hasdata("变异判定-冲田总司") then
            local zj = 0
            if u:hasdata("禁忌判定-樱总司") then
              zj = 3
            else
              local zs = 2
              if not u:ishasbuff("B034") then
                zs = 3
              end
              for i = 1, zs do
                if u:ishasitem("I020") then
                  if u:getluckrandom(44 * info.txgl) then
                    zj = zj + 1
                  end
                elseif u:getluckrandom(33 * info.txgl) then
                  zj = zj + 1
                end
              end
            end
            if 0 < zj then
              ac.timer(50, zj, function()
                tg:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
                local wshj = false
                if u:hasdata("禁忌判定-樱总司") then
                  wshj = true
                end
                DamageUnit({
                  bj = "冲田总司(三段突)",
                  unit = tg.handle,
                  source = u.handle,
                  damage = info.yssh,
                  level = 1,
                  type = "物理",
                  isvest = false,
                  isattack = false,
                  isnoarmor = wshj,
                  element = "无",
                  extradata = {
                    "系统-本次伤害无视伤害抗性"
                  }
                })
              end)
            end
          elseif u:getluckrandom(22) then
            tg:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
            DamageUnit({
              bj = "冲田总司(三段突)",
              unit = tg.handle,
              source = u.handle,
              damage = info.yssh,
              level = 1,
              type = "物理",
              isvest = false,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
          end
        end
      end)
      ac.loop(10000, function(timer)
        if u:isalive() then
          local jl = 12
          if u:ishasitem("I021") then
            jl = 0
          end
          if GetRandom100(jl) or 0 < u:getdata("魔君兴奋剂持续时间") then
            u:sendmessage("|cFFFF0000你咳血了！同时身体极度虚弱|r")
            u:playseensound(Sound_Ctzs_02)
            u:addskill("S007")
            u:setdata("冲田总司-咳血")
            if u:hasdata("变异判定-冲田总司") then
            else
              ChangeTimeValue(DamageSystem_Sszengjia, sy, 0.25, 10)
              ChangeTimeValue(DamageSystem_Baoji, sy, -1000, 10)
            end
            ac.wait(9900, function()
              u:deldata("冲田总司-咳血")
              u:sendmessage("|cFFFF0000你从虚弱中恢复过来……|r")
              u:delskill("S007")
            end)
          end
        end
        if u:hasdata("禁忌判定-樱总司") then
          timer:remove()
        end
      end)
    end,
    effectname = "|cFF3399FF病|r|cFFDFEFFF弱|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF3399FF战士|r\n|cFFDFEFFF提升12%伤害加成\n提升12%近战伤害|r\n|cFF3399FF【突刺】|r\n|cFFDFEFFF直接伤害时22%造成二次伤害(物理伤害 冷却0.25秒)|r\n|cFF3399FF【心眼(伪)】|r\n|cFFDFEFFF提升12%暴击率\n提升12%暴击伤害|r\n|cFF3399FF【咳血】|r\n|cFFDFEFFF每10秒12%触发咳血,持续10秒:\n[无法暴击\n提升25%额外受伤]|r",
    effectart = "war3mapImported\\BTNEwl_Bingruo2.blp"
  },
  {
    name = "白狼天狗",
    weight = 100,
    lv = 2,
    key = {
      "唯一",
      "白毛",
      "东方"
    },
    unique = true,
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
      ciyuanget(u, var)
      u:sendmessage("|cFFFFFF00你的感官变得非常灵敏|r")
      u:become("天狗")
      u:changearmor(25)
      local zj = 0
      local rectz = {
        RECT_Guangchang,
        RECT_Jiaoqu,
        RECT_Haian
      }
      local fogz = {}
      for i = 1, 3 do
        fogz[i] = u:createrectfogcorrector(rectz[i])
        FogModifierStop(fogz[i])
      end
      ac.loop(1000, function()
        if u:isalive() then
          Boolean_Qzh_Alive = true
          local b = false
          for i = 1, 3 do
            if u:isinrect(rectz[i]) then
              b = true
              FogModifierStart(fogz[i])
            end
          end
          if b then
            if not u:hasdata("犬走椛-处于野外") then
              u:setdata("犬走椛-处于野外")
              u:addskill("S09X")
              u:changedata("闪避值", 30)
              ChangeValue(HeroMenu_Sbxs, sy, 0.1)
            end
          elseif u:hasdata("犬走椛-处于野外") then
            u:deldata("犬走椛-处于野外")
            u:delskill("S09X")
            u:changedata("闪避值", -30)
            ChangeValue(HeroMenu_Sbxs, sy, -0.1)
          end
        else
          Boolean_Qzh_Alive = false
          for i = 1, 3 do
            FogModifierStop(fogz[i])
          end
        end
      end)
    end,
    effectname = "|cFFBD2313白|r|cFFCE5F4B狼|r|cFFDF9B83天|r|cFFF0D7BB狗|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFBD2313唯一 东方 战士 天狗|r\n|cFFBD2313【守山】|r\n|cFFF0D7BB提升25护甲\n存活时提升全队20%受伤减少|r\n|cFFBD2313【妖山哨戒】|r\n|cFFF0D7BB自身处于野外类型区域时:\n[提升30闪避值与0.1闪避系数\n提升100%移速\n提升100飞行强度\n扩大视野]|r",
    effectart = "BTNEwl_Cq_Bailangtiangou.tga"
  },
  {
    name = "太岁",
    weight = 100,
    lv = 2,
    key = {"兽", "召唤"},
    unique = false,
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
      ciyuanget(u, var)
      u:chat("|cFFC700DD猛虎潜深山,长啸自生风|r")
      PlayGlobalSound(Sound_Taisui_01)
      u:changedata("召唤物数量", 1)
      local x, y = u:getxy()
      local mj = u:createunit("n00N", x, y)
      mj:groupadd(u:getdata("召唤物组"))
      mj:groupadd(Group_ZhaohuanwuAll)
      mj:setdata("常规召唤物", "太岁")
      mj:setguard(u.handle)
      local add = 0
      ac.loop(1000, function()
        u:changemaxhp(1)
        ChangeValue(Correction_Summon, sy, -add)
        add = 0.05 * u:getdata("召唤物数量")
        ChangeValue(Correction_Summon, sy, add)
      end)
    end,
    effectname = "|cFFC700DD太|r|cFF78A9F4岁|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFC700DD兽 召唤|r\n|cFFC700DD【厉太岁】|r\n|cFF78A9F4召唤物[太岁]|r\n|cFFC700DD【岁星】|r\n|cFF78A9F4每秒提升1生命上限\n提升[召唤物数量*5%]召唤伤害|r",
    effectart = "war3mapImported\\BTNEwl_Cq_Ts"
  },
  {
    name = "琉紫",
    weight = 100,
    lv = 2,
    key = {"机械", "白毛"},
    unique = false,
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
      ciyuanget(u, var)
      u:chat("|cFFE2D5CB「我是自动人偶，时钟机关的人偶」|r")
      PlayGlobalSound(Sound_Liuzi_Get)
      u:become("机械生命")
      local lw = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, -lw)
        if u:hasdata("琉紫-时钟机关之星") then
          lw = 0.06 * u:getstate("机械变异")
        else
          lw = 0.02 * u:getstate("机械变异")
        end
        ChangeValue(DamageSystem_Shjc, sy, lw)
      end)
      ac.loop(3000, function(timer)
        if u:hasdata("遗物-亚历山大指针") then
          local x, y = u:getxy()
          Effectcreate("liuzi_xukong.mdl", x, y)
          u:setdata("琉紫-时钟机关之星")
          PlayGlobalSound(Sound_Liuzi_Jinjie)
          SendMsgAll("|cFFE2D5CB「这种垃圾不管有多少也赢不过姐妹中最弱的我」|r")
          ac.wait(7800, function()
            SendColorfulMsgAll("定义宣言", "|cFFE2D5CB", "|cFF9E93A3", "|cFFFFFFFF", "|cFF505194")
          end)
          ac.wait(9100, function()
            SendColorfulMsgAll("系列一号机随从琉紫", "|cFFE2D5CB", "|cFF9E93A3", "|cFFFFFFFF", "|cFF505194")
          end)
          ac.wait(14400, function()
            SendColorfulMsgAll("固有机能「双重时间」", "|cFFE2D5CB", "|cFF9E93A3", "|cFFFFFFFF", "|cFF505194")
          end)
          ac.wait(16700, function()
            SendColorfulMsgAll("启动序列开始", "|cFFE2D5CB", "|cFF9E93A3", "|cFFFFFFFF", "|cFF505194")
            PlayBGM({
              bgm = BGM_Liuzi_01,
              time = 100,
              ID = 159,
              unit = u.handle
            })
            ac.wait(7000, function()
              SendMsgAll("|cFFEFF9F1BGM：「アンチクロックワイズ」|r")
            end)
          end)
          ChangeValue(Hero_Tili_Huifu, sy, 1)
          ChangeValue(HeroMenu_HpForever_MaxHp, sy, 1.5)
          ChangeValue(DamageSystem_EndSh, sy, 0.03)
          local qsx = 0
          ac.loop(3000, function()
            u:changedata("全属性增幅", -1 * qsx)
            qsx = 0.05 * u:getstate("机械变异")
            u:changedata("全属性增幅", 1 * qsx)
          end)
          u:addstexiao(var.name, "进入战斗状态时", function(args)
            local u = args.u
            if not u:hasdata(var.name .. "-入战冷却") then
              u:settimedata(var.name .. "-入战冷却", 120)
              u:sendmessage("|cFF9E93A3[Y01]虚数运动机关|r")
              u:chat("虚数时间")
              u:playsound(Sound_Liuzi_Qidong)
              u:playsound(Sound_Liuzi_Skill)
              u:settimedata("琉紫-虚数时间", 15)
              local x, y = u:getxy()
              Effectcreate("liuzi_xusukongjian.mdl", x, y, 0, 1.5)
              u:effectadd("liuzi_xushukongjian.mdl", "origin", 15)
              Effectcreate("liuzi_xukong.mdl", x, y)
              ChangeTimeValue(DamageSystem_Shjc, sy, 1, 15)
              ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 250, 15)
            end
          end)
          u:uivar_change({
            keyname = "琉紫",
            keytype = "传奇栏",
            text = "|cFFE2D5CB琉紫|r\n|cFFFF3366[奇迹]|r\n|cFFE2D5CB唯一 机械 白毛|r\n|cFF9E93A3提升[机械变异*6%]伤害加成|r\n|cFFE2D5CB虚数运动机关[永恒]|r\n|cFF9E93A3提升2.5%永恒恢复\n提升2体力恢复\n入战时进入[虚数时间],持续15秒,冷却120秒|r\n|cFFE2D5CB时钟机关之星|r\n|cFF9E93A3提升3%终结伤害\n提升[机械变异*2.5%]全属性\n受到致死伤害时,抵挡该次伤害完全恢复并无视冷却触发[虚数时间],冷却480秒|r",
            icon = "war3mapImported\\BTNEwl_Cq_Y01"
          })
          timer:remove()
        end
      end)
      ChangeValue(Hero_Tili_Huifu, sy, 0.5)
      ChangeValue(HeroMenu_HpForever_MaxHp, sy, 1)
    end,
    effectname = "|cFF9E93A3Y|r|cFFC0B4B70|r|cFFE2D5CB1|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF9E93A3机械 白毛|r\n|cFFE2D5CB提升[机械变异*2%]伤害加成|r\n|cFF9E93A3【虚数运动机关】|r\n|cFFE2D5CB提升1%永恒恢复\n提升0.5体力恢复|r\n|cFF9E93A3【时钟机关之星】|r\n|cFFE2D5CB[拥有亚历山大指针时解锁]|r",
    effectart = "war3mapImported\\BTNEwl_Cq_Y01_0"
  },
  {
    name = "东云心菜",
    weight = 100,
    lv = 2,
    key = {
      "唯一",
      "机械",
      "歌姬"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if not u:isgirl() then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:sendmessage("|cFFB58C88「不要刺疼我……」|r")
      u:setdata("属性-歌姬传奇")
      ChangeValue(Hero_Tili_Huifu, sy, 0.14)
      local add = 0
      local add2 = 0
      ac.loop(3000, function()
        ChangeValue(Damage_Type_Nengliang, sy, -add2)
        ChangeValue(DamageSystem_Shjc, sy, -add)
        local ct = u:getstate("歌姬变异")
        add = 0.02 * ct
        add2 = 0.04 * ct
        ChangeValue(DamageSystem_Shjc, sy, add)
        ChangeValue(Damage_Type_Nengliang, sy, add2)
      end)
      if Group_Counts(Group_PlayHero) >= 3 then
        ac.loop(60000, function(t)
          local z = 0
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if xq:getdata("歌姬变异数量") > 0 then
              z = z + 1
            end
          end)
          if 4 <= z then
            u:sendmessage("|cFFEFF9F1量子海激活(提升全队25额外移速,25%伤害加成,25%能量伤害)|r")
            SendMsgAll("|cFFEFF9F1BGM：「魔法のたまご」|r")
            PlayBGM({
              bgm = BGM_Dyxc,
              time = 135,
              ID = 158
            })
            ForGroupLuaNew(Group_PlayHero, function(xq)
              local sy2 = xq.ownerid
              ChangeValue(HeroMenu_ExtraMoveSpeed, sy2, 25)
              ChangeValue(DamageSystem_Shjc, sy2, 0.25)
              ChangeValue(Damage_Type_Nengliang, sy2, 0.25)
            end)
            t:remove()
          end
        end)
      end
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and not u:hasdata("量子态-决死冷却") then
          args.dt = false
          u:settimedata("量子态-决死冷却", 150)
          u:chat("东云流变化术")
          u:settimedata("东云心菜-量子态", 5)
          u:setcolor(125, 125, 255, 125)
          ac.wait(5000, function()
            u:setcolor(255, 255, 255)
          end)
          local x, y = u:getxy()
          u:effectadd("huanrao.mdl", "origin", 5)
          Effectcreate("chufa.mdl", x, y, 0, 1.5)
        end
      end)
    end,
    effectname = "|cFF1BFFF9东|r|cFF62FDF6云|r|cFFA8FBF4心|r|cFFEFF9F1菜|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF1BFFF9唯一 歌姬 机械|r\n|cFFEFF9F1提升[歌姬变异*2%]伤害加成|r\n|cFF1BFFF9【东云流变化术】|r\n|cFFEFF9F1受到致死伤害时进入量子态5秒,冷却150秒|r\n|cFF1BFFF9【量子海】|r\n|cFFEFF9F1提升0.14体力恢复\n提升[歌姬变异*4%]能量伤害|r",
    effectart = "war3mapImported\\BTNEwl_Cq_Dyxc"
  },
  {
    name = "井上泷奈",
    weight = 100,
    lv = 2,
    key = {
      "唯一",
      "战士",
      "同奏",
      "百合"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:ishasskill(SKILL_TESHUYINGXIONG) then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("sa↓ka→na→~")
      PlayGlobalSound(Sound_Jsln_01)
      Danwei_Jingshanglongnai = u.handle
      ChangeValue(Correction_Gun, sy, 0.1)
      u:addstexiao(var.name, "过波时效果", function(args)
        ChangeValue(Correction_Gun, sy, 0.01)
        ChangeValue(DamageSystem_Shjc, sy, 0.01)
      end)
      if u:hasdata("变异判定-莉可莉丝") then
        ac.wait(1500, function()
          PlayBGM({
            bgm = BGM_Lkls_01,
            time = 170,
            ID = 207,
            unit = u.handle
          })
          SendMsgAll("|cFFFF3366BGM:《花の塔》|r")
          ChangeValue(Correction_Gun, sy, 0.15)
          u:addstexiao(var.name, "杀敌效果", function(args)
            ChangeValue(Correction_Gun, sy, 1.0E-4)
          end)
        end)
      end
      u:addstexiao(var.name, "子弹伤害后效果", function(args)
        local tg = args.tg
        if not tg:hasdata("泷奈-抑制恢复") then
          tg:settimedata("泷奈-抑制恢复", 1)
          tg:groupadd(HpGroup)
        end
      end)
    end,
    effectname = "|cFF47515F咖|r|cFF4F5865啡|r|cFF58606B厅|r|cFF606771的|r|cFF696E77莉|r|cFF71757D可|r|cFF7A7D83莉|r|cFF828489丝|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF47515F唯一 战士 同奏 百合|r\n|cFF828489提升10%枪械伤害|r\n|cFF47515F【火力镇压】|r\n|cFF828489过波时提升1%枪械伤害与1%伤害加成\n枪械伤害弱抑制恢复目标1秒,独立冷却1秒|r\n|cFF47515F【伴我同行】|r\n|cFF828489拥有[电波塔的莉可莉丝]时:\n杀敌时提升0.01%枪械伤害\n提升15%枪械伤害|r",
    effectart = "Ewl_Jingshanglongnai",
    test = "        "
  },
  {
    name = "A.A.",
    weight = 100,
    lv = 2,
    key = {"唯一", "机械"},
    unique = true,
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
      ciyuanget(u, var)
      u:chat("|cFFBBB3CA天空是蓝色的……")
      u:chat("|cFFBBB3CA为什么会透明呢？", 2.8)
      u:chat("|cFFBBB3CA好奇怪……", 6.5)
      PlayGlobalSound(Sound_MM_AA_01)
      ChangeValue(DamageSystem_Shjc, sy, 0.1)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.75, 1)
      ChangeValue(HeroMenu_HpChange_MaxHp, sy, 0.5)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 0.25)
          local sh = 5000
          DamageUnit({
            bj = "A.A.(锈铁剑芒)",
            unit = tg.handle,
            source = u.handle,
            damage = sh,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = true,
            isnoarmor = false,
            element = "无"
          })
        end
        if not u:hasdata(var.name .. "-特效2冷却") then
          u:settimedata(var.name .. "-特效2冷却", 4)
          local sh = 50000
          ac.timer(50, 3, function()
            DamageUnit({
              bj = "A.A.(锈铁剑芒)",
              unit = tg.handle,
              source = u.handle,
              damage = sh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
          end)
        end
      end)
    end,
    effectname = "|cFFBBB3CAA|r|cFFCDC4CF.|r|cFFE0D5D5A|r|cFFF2E6DA.|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFBBB3CA唯一 机械|r\n|cFFF2E6DA提升10%伤害加成|r\n|cFFBBB3CA【锈铁剑芒】|r\n|cFFF2E6DA直接伤害时附带[5000]物理近战伤害,冷却0.25秒\n直接伤害时附带3段[50000]魔力伤害,冷却4秒|r\n|cFFBBB3CA【爱的天使】|r\n|cFFF2E6DA提升0.5%生命恢复\n提升25%伤害减免|r",
    effectart = "Cq_MM_AA"
  },
  {
    name = "伊利亚",
    clickfunc = function(u, var)
      local sy = u.ownerid
      if u:hasdata("伊利亚-已吟唱") then
        return
      end
      if u:getdata("伊利亚-诅咒数量") < 11 then
        u:sendmessage("|cFFBBB3CA诅咒力量不足|r")
        return
      end
      if u:getdata("战士变异数量") < 12 then
        u:sendmessage("|cFFBBB3CA战士变异数量不足|r")
        return
      end
      if not BossBattle then
        u:sendmessage("|cFFBBB3CA非BOSS战|r")
        return
      end
      if Boolean_Wj_Xiuluolingyu or Boolean_Jinselingyu or Boolean_Anshen_Sanjieduan then
        u:sendmessage("|cFFBBB3CA处于BOSS战特殊阶段|r")
        return
      end
      ChangeValue(DamageSystem_Sszengjia, sy, -0.11)
      u:setdata("伊利亚-已吟唱")
      u:changedata("系统-神力承载", 5)
      MovieAct["伊利亚吟唱"](u)
    end,
    weight = 100,
    lv = 2,
    key = {"唯一", "战士"},
    unique = true,
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
      ciyuanget(u, var)
      PlayGlobalSound(Sound_MM_Yly_01)
      NPCChat({
        name = "|cFFBBB3CA伊|r|cFFD6CCD2利|r|cFFF2E6DA亚|r",
        chaticon = "Chat_MMT_Yiliya.blp",
        chattext = {
          {
            text = "|cFFBBB3CA那么…出发吧",
            time = 0
          },
          {
            text = "|cFFBBB3CA这次一定要……",
            time = 3.4
          },
          {
            text = "|cFFBBB3CA拯救这个世界……",
            time = 5.5
          }
        }
      })
      ChangeValue(Correction_Jzsh, sy, 0.1)
      ChangeValue(Damage_Element_Light, sy, 0.1)
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and not u:hasdata("伊利亚-决死冷却") and u:hasdata("变异判定-伊利亚") then
          args.dt = false
          u:setdata("伊利亚-决死冷却")
          u:buffset(u.handle, 0.1, "无敌")
          u:sendmessage("|cFFBBB3CA[伊利亚]不屈之心|r")
        end
      end)
      if Stage <= 1 then
        u:setdata("伊利亚-羁绊开始")
        u:setdata("伊利亚-羁绊波数", 1)
      end
      u:addstexiao(var.name, "过波时效果", function(args)
        u:deldata("伊利亚-决死冷却")
        if u:hasdata("伊利亚-羁绊开始") then
          u:changedata("伊利亚-羁绊波数", 1)
          if u:getdata("伊利亚-羁绊波数") >= 11 then
            u:setdata("伊利亚-羁绊达成")
          end
        end
        if u:getdata("伊利亚-诅咒可获取数量") > 0 then
          u:sendmessage("|cFFBBB3CA[伊利亚]获得1道诅咒力量|r")
          u:changedata("伊利亚-诅咒数量", 1)
          u:changedata("伊利亚-诅咒可获取数量", -1)
          ChangeValue(DamageSystem_Sszengjia, sy, 0.01)
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:hasdata("变异判定-伊利亚") then
          u:settimedata(var.name .. "-特效冷却", 1)
          local sh = 5000 * u:getstate("光明变异")
          DamageUnit({
            bj = "伊利亚(信念之刃)",
            unit = tg.handle,
            source = u.handle,
            damage = sh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "光"
          })
        end
      end)
      u:setdata("伊利亚-诅咒数量", 0)
      u:setdata("伊利亚-诅咒可获取数量", 11)
      ac.wait(1000, function()
        u:uivar_change({
          keyname = "伊利亚",
          keytype = "传奇栏",
          text = "|cFFBBB3CA伊|r|cFFD6CCD2利|r|cFFF2E6DA亚|r\n|cFF66CCFF[奇迹]|r\n|cFFBBB3CA唯一 战士|r\n|cFFF2E6DA提升10%近战伤害|r\n|cFFBBB3CA【信念之刃】|r\n|cFFF2E6DA提升10%光属性伤害\n直接伤害时附带[光明变异*5000]光魔力伤害,冷却1秒|r\n|cFFBBB3CA【不屈之心】|r\n|cFFF2E6DA受到致死伤害时抵挡该次伤害并死亡抗拒1秒,过波时刷新|r\n|cFFBBB3CA「献身」|r\n|cFFF2E6DA过波时或获得诅咒时积累1道诅咒力量\n每道诅咒力量提升1%额外受伤(上限11道)\n满足条件点击时|r|cFFCC0000低概率|r|cFFF2E6DA进阶为[神话]\n发动条件:\n[①11道诅咒力量\n②战士变异数量≥12\n③BOSS战且非结束阶段]\n进阶失败时:\n[自身死亡,复活所有队友\n完全失去该变异效果\n返还神力承载]|r"
        })
      end)
    end,
    effectname = "|cFFBBB3CA伊|r|cFFD6CCD2利|r|cFFF2E6DA亚|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFBBB3CA唯一 战士|r\n|cFFF2E6DA提升10%近战伤害|r\n|cFFBBB3CA【信念之刃】|r\n|cFFF2E6DA提升10%光属性伤害\n直接伤害时附带[光明变异*5000]光魔力伤害,冷却1秒|r\n|cFFBBB3CA【不屈之心】|r\n|cFFF2E6DA受到致死伤害时抵挡该次伤害并死亡抗拒1秒,过波时刷新|r",
    effectart = "Cq_MM_Yly"
  },
  {
    name = "Blake",
    clickfunc = function(u, var)
      local sy = u.ownerid
      if u:getdata("跃影飞绫-类型") == "镰刀" then
        u:setdata("跃影飞绫-类型", "武士刀")
      else
        u:setdata("跃影飞绫-类型", "镰刀")
      end
      u:sendmessage("|cFFA863E3[跃影飞绫-当前类型]" .. u:getdata("跃影飞绫-类型"))
    end,
    weight = 300,
    lv = 2,
    key = {
      "唯一",
      "影",
      "黑暗",
      "兽"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      return u:hasdata("变异判定-尘晶觉醒")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:changedata("元气值", 1)
      rwby_add_vitality_scaling(u, 0.05, 0.1)
      rwby_add_close_shot(u, var.name)
      coopjudge("RWBY", u)
      u:chat("|cFFF5D400如果不能战斗，就无法生存")
      PlayGlobalSound(Sound_Blake_01)
      u:setdata("跃影飞绫-类型", "武士刀")
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and u:hasdata("羁绊判定-RWBY") and not u:hasdata("Blake-决死冷却") then
          args.dt = false
          u:settimedata("Blake-决死冷却", 240)
          u:buffset(u.handle, 0.1, "无敌")
          u:sendmessage("|cFFA863E3[Blake-跃影飞绫]决死|r")
        end
      end)
      u:addstexiao(var.name .. "-跃影飞绫伤害减半", "伤害判定前变更", function(args)
        if args.u == u and u:hasdata("Blake-跃影飞绫伤害减半") then
          args.damage = args.damage * 0.5
        end
      end)
      u:addstexiao(var.name, "子弹伤害后效果", function(args)
        local tg = args.tg
        if not u:hasdata(var.name .. "-特效冷却") and not u:hasdata("Blake-决死冷却") then
          local weapon_type = Hero_Equip_WeaponType[sy]
          local melee_type = GetData(weapon_type, "近战武器类型")
          if melee_type == 6 or melee_type == 10 then
            u:settimedata(var.name .. "-特效冷却", 3)
            local x, y = tg:getxy()
            u:setdata("Blake-跃影飞绫伤害减半")
            weaponuse(u.handle, GetData(weapon_type, "绑定技能"), x, y)
            u:deldata("Blake-跃影飞绫伤害减半")
          end
        end
      end)
    end,
    effectname = "|cFFA863E3B|r|cFFB476EAl|r|cFFC08AF1a|r|cFFCC9DF8k|r|cFFD8B0FFe|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFA863E3唯一 影 兽 黑暗\n元气值 1|r\n|cFFD8B0FF提升[0.5%*元气值]枪械伤害\n提升[1%*元气值]近战伤害|r\n|cFFA863E3【抵近射击】|r\n|cFFD8B0FF造成近战直接伤害时发射子弹,冷却1秒\n子弹优先当前装备枪支,否则为[5000物理伤害]基础子弹\n不同[抵近射击]完美叠加,有0.1秒公共冷却|r\n|cFFA863E3【跃影飞绫】|r\n|cFFD8B0FF装备镰刀或武士刀时:\n[枪械伤害在目标位置发动一次全伤害减半的近战武器,冷却3秒]\n装备镰刀或武士刀时,强制覆盖武器类型为指定类型\n点击切换武器类型为[镰刀]或[武士刀]|r",
    effectart = "Cq_RWBY_B"
  },
  {
    name = "Yang",
    weight = 300,
    lv = 2,
    key = {
      "唯一",
      "战士",
      "炎"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      return u:hasdata("变异判定-尘晶觉醒")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:changedata("元气值", 1)
      rwby_add_vitality_scaling(u, 0.05, 0.1)
      rwby_add_close_shot(u, var.name)
      coopjudge("RWBY", u)
      u:chat("|cFFF5D400呵,你们碰不到我一点")
      PlayGlobalSound(Sound_Yang_01)
      u:setdata("Yang-受伤加伤", 0)
      u:addstexiao(var.name, "受伤后效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if args.damage > 10 and u:hasdata("羁绊判定-RWBY") then
          u:changedata("Yang-受伤加伤", 0.025)
        end
      end)
      local add = 0
      local layers = 0
      ac.loop(1000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        if u:getdata("战斗时间") > 0 then
          layers = math.min(100, layers + 1)
          add = layers * 0.01 * u:getdata("元气值") + u:getdata("Yang-受伤加伤")
        else
          layers = 0
          add = 0
          u:setdata("Yang-受伤加伤", 0)
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      end)
    end,
    effectname = "|cFFF5D400Y|r|cFFF7B30Da|r|cFFF89219n|r|cFFFA7126g|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFF5D400唯一 战士 炎\n元气值 1|r\n|cFFFA7126提升[0.5%*元气值]枪械伤害\n提升[1%*元气值]近战伤害|r\n|cFFF5D400【抵近射击】|r\n|cFFFA7126造成近战直接伤害时发射子弹,冷却1秒\n子弹优先当前装备枪支,否则为[5000物理伤害]基础子弹\n不同[抵近射击]完美叠加,有0.1秒公共冷却|r\n|cFFF5D400【灰烬天堂】|r\n|cFFFA7126入战时每秒提升[元气值*0.1%]伤害加成,至多100层,脱战时清空|r",
    effectart = "Cq_RWBY_Y"
  },
  {
    name = "Weiss",
    clickfunc = function(u, var)
      local str = u:getdata("柳叶白菀-属性")
      weiss_remove_attribute_bonus(u)
      u:changedata(str .. "变异数量", -1)
      local z = {
        "根源",
        "冰",
        "炎",
        "风"
      }
      for index, value in ipairs(z) do
        if value == str then
          if index == #z then
            str = z[1]
            break
          end
          str = z[index + 1]
          break
        end
      end
      u:changedata(str .. "变异数量", 1)
      u:setdata("柳叶白菀-属性", str)
      weiss_apply_attribute_bonus(u)
      u:sendmessage("|cFF77E2F5[柳叶白菀-当前属性]" .. u:getdata("柳叶白菀-属性"))
    end,
    weight = 300,
    lv = 2,
    key = {
      "唯一",
      "魔导",
      "冰",
      "白毛"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      return u:hasdata("变异判定-尘晶觉醒")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:changedata("元气值", 1)
      rwby_add_vitality_scaling(u, 0.1, 0.05)
      rwby_add_close_shot(u, var.name)
      coopjudge("RWBY", u)
      u:chat("|cFF77E2F5你真的想补偿我点什么？")
      u:chat("|cFF77E2F5看完然后别再和我说话", 2.1)
      PlayGlobalSound(Sound_Weiss_01)
      u:addgold(1000)
      u:setdata("柳叶白菀-属性", "根源")
      u:changedata(u:getdata("柳叶白菀-属性") .. "变异数量", 1)
      weiss_apply_attribute_bonus(u)
      local vitality = u:getdata("元气值")
      ac.loop(1000, function()
        local current_vitality = u:getdata("元气值")
        if current_vitality ~= vitality then
          weiss_remove_attribute_bonus(u)
          vitality = current_vitality
          weiss_apply_attribute_bonus(u)
        end
      end)
      u:addstexiao(var.name, "子弹伤害后效果", function(args)
        local tg = args.tg
        if not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 3)
          local b = false
          if u:hasdata("羁绊判定-RWBY") then
            b = true
          end
          local str = u:getdata("柳叶白菀-属性")
          local x2, y2 = tg:getxy()
          for _, xq in ac.selector():in_rangexy(x2, y2, 250):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            if b or str == "根源" then
              local mfsh = u:getdata("元气值") * u:getlevel() * 250
              DamageUnit({
                bj = "Weiss(柳叶白菀)",
                unit = xq.handle,
                source = u.handle,
                damage = mfsh,
                level = 1,
                type = "震荡",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "无"
              })
              xq:buffset(u.handle, 0.5, "暂停")
            end
            if b or str == "冰" then
              local mfsh = u:getdata("元气值") * u:getlevel() * 1000
              DamageUnit({
                bj = "Weiss(柳叶白菀)",
                unit = xq.handle,
                source = u.handle,
                damage = mfsh,
                level = 1,
                type = "魔力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "冰"
              })
              xq:buffset(u.handle, 1, "冰冻")
            end
            if b or str == "炎" then
              local mfsh = u:getdata("元气值") * u:getlevel() * 1500
              DamageUnit({
                bj = "Weiss(柳叶白菀)",
                unit = xq.handle,
                source = u.handle,
                damage = mfsh,
                level = 1,
                type = "魔力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "火"
              })
            end
            if b or str == "风" then
              local mfsh = u:getdata("元气值") * u:getlevel() * 500
              DamageUnit({
                bj = "Weiss(柳叶白菀)",
                unit = xq.handle,
                source = u.handle,
                damage = mfsh,
                level = 1,
                type = "物理",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "风"
              })
              xq:buffset(u.handle, 2, "僵直")
            end
          end
        end
      end)
    end,
    effectname = "|cFF77E2F5W|r|cFF8EE0F3e|r|cFFA6DEF2i|r|cFFBDDDF0s|r|cFFD4DBEEs|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF77E2F5唯一 魔导 冰 白毛\n元气值 1|r\n|cFFD4DBEE提升[1%*元气值]枪械伤害\n提升[0.5%*元气值]近战伤害\n获取时获得1000积分|r\n|cFF77E2F5【抵近射击】|r\n|cFFD4DBEE造成近战直接伤害时发射子弹,冷却1秒\n子弹优先当前装备枪支,否则为[5000物理伤害]基础子弹\n不同[抵近射击]完美叠加,有0.1秒公共冷却|r\n|cFF77E2F5【柳叶白菀(点击切换属性)】|r\n|cFFD4DBEE属性对应的变异词条+1,附带被动效果\n枪械伤害附带250范围特效与伤害,冷却3秒\n[根源](提升[10*元气值]额外移速):时停0.5秒与[元气值*等级*250]震荡伤害\n[冰](提升[5%*元气值]冰属性伤害):冰冻1秒与[元气值*等级*1000]冰魔力伤害\n[炎](提升[5%*元气值]火属性伤害):[元气值*等级*1500]火魔力伤害\n[风](提升[5%*元气值]风属性伤害):僵直2秒与[元气值*等级*500]风物理伤害|r",
    effectart = "Cq_RWBY_W"
  },
  {
    name = "Ruby",
    weight = 300,
    lv = 2,
    key = {
      "唯一",
      "战士",
      "影"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      return u:hasdata("变异判定-尘晶觉醒")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:changedata("元气值", 1)
      rwby_add_vitality_scaling(u, 0.1, 0.1)
      rwby_add_close_shot(u, var.name)
      coopjudge("RWBY", u)
      if GetRandom100(50) then
        u:chat("|cFFE10420哇哦，这名叫Ruby的女孩非常非常酷")
        PlayGlobalSound(Sound_Ruby_01)
      else
        u:chat("|cFFE10420嗯？很高兴认识你")
        PlayGlobalSound(Sound_Ruby_02)
      end
      ac.loop(1000, function()
        if u:getdata("战斗时间") > 0 then
          if not u:hasdata("Ruby-战斗状态") then
            u:setdata("Ruby-战斗状态")
            u:addskill("S0CD")
          end
        elseif u:hasdata("Ruby-战斗状态") then
          u:deldata("Ruby-战斗状态")
          u:delskill("S0CD")
        end
      end)
      u:addstexiao(var.name, "被施加Buff时效果-僵直", function(args)
        if u:hasdata("羁绊判定-RWBY") and not Keyan_Guomintizhi then
          args.time = 0
        end
      end)
      u:addstexiao(var.name, "子弹伤害后效果", function(args)
        local tg = args.tg
        if not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 3)
          LossHpUnit({
            u = u,
            tg = tg,
            damage = 0,
            perhp = 1,
            maxhp = 0,
            bj = "[生命损耗]Ruby新月玫瑰"
          })
        end
      end)
    end,
    effectname = "|cFFE10420R|r|cFFEB3B4Du|r|cFFF5717Bb|r|cFFFFA8A8y|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFE10420唯一 战士 影\n元气值 1|r\n|cFFFFA8A8提升[1%*元气值]枪械伤害\n提升[1%*元气值]近战伤害|r\n|cFFE10420【抵近射击】|r\n|cFFFFA8A8造成近战直接伤害时发射子弹,冷却1秒\n子弹优先当前装备枪支,否则为[5000物理伤害]基础子弹\n不同[抵近射击]完美叠加,有0.1秒公共冷却|r\n|cFFE10420【新月玫瑰】|r\n|cFFFFA8A8入战时极速\n枪械伤害附带1%当前生命损耗,冷却3秒|r",
    effectart = "Cq_RWBY_R"
  },
  {
    name = "芙兰酱",
    weight = 5,
    lv = 2,
    key = {"唯一", "吸血鬼"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("权限-芙兰酱") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:sendmessage("|cFFFF0000「|r|cFFFF0508そ|r|cFFFF0A11し|r|cFFFF0F1Aて|r|cFFFF1422い|r|cFFFF1A2Aま|r|cFFFF1F33全|r|cFFFF243Cて|r|cFFFF2944理|r|cFFFF2E4C解|r|cFFFF3355し|r|cFFFF385Eた|r|cFFFF3D66!|r|cFFFF426E理|r|cFFFF4777解|r|cFFFF4C80し|r|cFFFF5288て|r|cFFFF5790い|r|cFFFF5C99な|r|cFFFF61A2い|r|cFFFF66AAこ|r|cFFFF6BB2と|r|cFFFF70BBを|r|cFFFF75C4理|r|cFFFF7ACC解|r|cFFFF7FD4し|r|cFFFF85DDた|r|cFFFF8AE6!|r|cFFFF8FEE」|r")
      coopjudge("超级厉害之歌", u)
      ChangeValue(DamageSystem_EndSh, sy, 0.03)
      ChangeValue(KillReward_MHp, sy, 1)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          local shz
          if tg:isnormal() then
            shz = 0.1 * tg:gethp()
          elseif tg:iselite() then
            shz = 0.03 * tg:gethp()
          else
            shz = 0.008 * tg:gethp()
          end
          LossHpUnit({
            u = u,
            tg = tg,
            damage = shz,
            perhp = 0,
            maxhp = 0,
            bj = "[生命损耗]超级疯狂芙兰酱"
          })
          u:settimedata(var.name .. "-特效冷却", 1)
        end
      end)
      local b = false
      ac.loop(1000, function()
        if IsTimeNight() or BGMChangeTime > 0 then
          if not b then
            b = true
            ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 50)
            ChangeValue(DamageSystem_Shjc, sy, 0.5)
            ChangeValue(DamageSystem_GushangBeilv, sy, 0.25)
          end
        elseif b then
          b = false
          ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -50)
          ChangeValue(DamageSystem_Shjc, sy, -0.5)
          ChangeValue(DamageSystem_GushangBeilv, sy, -0.25)
        end
      end)
    end,
    effectname = "|cFFFF0000超|r|cFFFF0D16级|r|cFFFF1A2C疯|r|cFFFF2742狂|r|cFFFF3557的|r|cFFFF426D芙|r|cFFFF4F83兰|r|cFFFF5C99酱|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFFF0000唯一 吸血鬼|r\n|cFFFF5C99提升3%终结伤害|r\n|cFFFF0000【事物理解理解……理解了?】|r\n|cFFFF5C99直接伤害时10%损耗目标10%(3%/0.8%)当前生命(冷却1秒)|r\n|cFFFF0000【肚子饿了！】|r\n|cFFFF5C99杀敌时提升1生命上限|r\n|cFFFF0000【「Somebody's Scream!」】|r\n|cFFFF5C99夜晚或播放BGM时:\n[提升50额外移速\n提升50%伤害加成\n提升25%固定伤害]|r",
    effectart = "war3mapImported\\BTNEwl_Fulanjiang.tga"
  },
  {
    name = "小鸟游星野",
    weight = 100,
    lv = 2,
    key = {"唯一", "学生"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:ishasskill(SKILL_TESHUYINGXIONG) then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cFFFFCCFF『|r|cFFFFC6F9你|r|cFFFFC1F4说|r|cFFFFBBEE需|r|cFFFFB5E8要|r|cFFFFB0E3我|r|cFFFFAADD？|r|cFFFFA4D7』|r")
      ac.wait(3500, function()
        SendMsgAll("|cFFFFCCFF『|r|cFFFFC9FC哼|r|cFFFFC6F9哼|r|cFFFFC3F6~|r|cFFFFC1F4，|r|cFFFFBEF1就|r|cFFFFBBEE算|r|cFFFFB8EB是|r|cFFFFB5E8恭|r|cFFFFB2E5维|r|cFFFFB0E3也|r|cFFFFADE0谢|r|cFFFFAADD谢|r|cFFFFA7DA你|r|cFFFFA4D7啦|r|cFFFFA1D4~|r|cFFFF9FD2』|r")
      end)
      PlayGlobalSound(Sound_Xiaoniaoyouxingye_01)
      u:become("学生")
      u:addskill("S0CC")
      ChangeValue(Correction_Gun, sy, 0.05)
      ChangeValue(Correction_Gun_Pistol, sy, 0.1)
      ChangeValue(Correction_Gun_Xiandan, sy, 0.2)
      ChangeValue(DamageSystem_Baoshang, sy, 0.22)
      ChangeValue(Correction_Unify, sy, 0.1)
      u:addstexiao(var.name, "枪械装弹时效果", function(args)
        if args.lx == 4 or args.lx == 8 then
          local x, y = u:getxy()
          for _, xq in ac.selector():in_rangexy(x, y, 450):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:buffset(u.handle, 0.8, "眩晕")
          end
        end
      end)
    end,
    effectname = "|cFFFF99CC小|r|cFFFFA8D4鸟|r|cFFFFB8DC游|r|cFFFFC8E3星|r|cFFFFD7EB野|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFFF99CC唯一 学生|r\n|cFFFFD7EB提升10%移速\n提升5%枪械伤害|r\n|cFFFF99CC【临战武装】|r\n|cFFFFD7EB提升10%手枪伤害\n提升20%霰弹枪伤害\n手枪与霰弹枪的换弹速度提升50%\n换弹完成时对450范围敌军造成0.8秒眩晕|r\n|cFFFF99CC【荷鲁斯之眼】|r\n|cFFFFD7EB提升10%弹幕伤害\n提升22%暴击伤害|r",
    effectart = "Cq_Xiaoniaoyouxingye.tga"
  },
  {
    name = "洛琪希",
    clickfunc = function(u, ewl)
      local sy = u.ownerid
      if u:isalive() and u:ishasshw() and u:getdata("魔导变异数量") + u:getdata("水变异数量") >= 6 then
        AdvanceGet["洛琪希"](u)
      end
    end,
    weight = 100,
    lv = 2,
    key = {
      "唯一",
      "魔导",
      "水"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if not u:isgirl() then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cFF3366FF『|r|cFF3F6FFF洛|r|cFF4B78FF琪|r|cFF5781FF希|r|cFF638AFF·|r|cFF6F93FF米|r|cFF7B9CFF格|r|cFF87A5FF路|r|cFF93AEFF迪|r|cFF9FB7FF亚|r|cFFABC0FF，|r|cFFB7C9FF请|r|cFFC3D2FF多|r|cFFCFDBFF关|r|cFFDBE4FF照|r|cFFE7EDFF』|r")
      PlayGlobalSound(Sound_Lqx_01)
      Weiyi_Feishen[43] = true
      coopjudge("师德充沛")
      u:become("魔族")
      ChangeValue(DamageSystem_Shjc, sy, 0.025)
      ChangeValue(Hero_Tili_Huifu, sy, 0.1)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        local sy2 = xq.ownerid
        ChangeValue(Correction_Exp, sy2, 0.25)
      end)
      local add = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        add = 0.05 * u:getstate("水变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      end)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:addallstats(1)
        end)
      end)
    end,
    effectname = "|cFF3366FF小|r|cFF8099E6老|r|cFFCCCCCC师|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF3366FF唯一 魔导 水|r\n|cFFCCCCCC提升2.5%伤害加成|r\n|cFF3366FF【水王魔法】|r\n|cFFCCCCCC提升0.1体力恢复\n提升[水变异*0.5%]伤害加成|r\n|cFF3366FF【魔导教师】|r\n|cFFCCCCCC自身升级时提升全队1点全属性\n提升全队25%经验获取|r",
    effectart = "war3mapImported\\BTNEwl_Lqx_01.tga"
  },
  {
    name = "金毛脆脆鲨",
    weight = 100,
    lv = 2,
    key = {"唯一"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if not u:isboy() then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("你刚才说我可爱对吧")
      ac.wait(3200, function()
        u:chat("没想到你居然喜欢这样的啊，难怪对身边的女性都不感兴趣")
      end)
      PlayGlobalSound(Sound_Cuicuisha)
      Weiyi_Feishen[42] = true
      u:getgoddessforce(3)
      u:setdata("性别", "女")
      ChangeZhanzhengqiyue(1)
      local str = {}
      str[1] = "war3mapImported\\BTNEwl_Cuicuisha_01"
      str[2] = "war3mapImported\\BTNEwl_Cuicuisha_02"
      str[3] = "war3mapImported\\BTNEwl_Cuicuisha_03"
      str[4] = "war3mapImported\\BTNEwl_Cuicuisha_04"
      str[5] = "war3mapImported\\BTNEwl_Cuicuisha_05"
      ac.loop(60000, function()
        u:uivar_change({
          keyname = "金毛脆脆鲨",
          keytype = "传奇栏",
          icon = str[GetRandomInt(1, 5)]
        })
      end)
      u:addstexiao(var.name, "施加Buff时效果-混乱", function(args)
        args.time = args.time * 2
      end)
      u:changedata("幸运", 1)
      ChangeValue(Correction_Gold, sy, 0.05)
      local jc = 0
      local cs = 0
      ac.loop(3000, function()
        u:setdata("性别", "女")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * jc))
        jc = 0.1 * u:getdata("女神力")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * jc))
        cs = cs + 1
        if cs == 20 then
          cs = 0
          u:addallstats(u:getdata("女神力"))
          u:sendmessage("|cFFFFFF33[金毛脆脆鲨-爱与美女神的加护]提升" .. u:getdata("女神力") .. "点全属性")
        end
      end)
    end,
    effectname = "|cFFFFFF33金|r|cFFFFE852毛|r|cFFFFD170脆|r|cFFFFBA8E脆|r|cFFFFA3AD鲨|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFFFFF33唯一 女神力3|r\n|cFFFFA3AD提升5%积分获取|r\n|cFFFFFF33【爱与美女神的加护LvMax】|r\n|cFFFFA3AD提升1幸运\n提升[女神力*1%]伤害加成\n每60秒提升[女神力*1]全属性|r\n|cFFFFFF33【爱与美女神的诅咒】|r\n|cFFFFA3AD怪物精英特性出现概率提升|r\n|cFFFFFF33【绝世美貌】|r\n|cFFFFA3AD性别锁定为女\n自身施加混乱时间翻倍|r",
    effectart = "war3mapImported\\BTNEwl_Cuicuisha_05"
  },
  {
    name = "地狱歌姬",
    clickfunc = function(u, ewl)
      local sy = u.ownerid
      if u:isalive() and u:ishasshw() and (BGMLoadCount[sy] >= 3 or Qiyue_Langkepaidu_Kongming ~= 0) then
        AdvanceGet["月见英子"](u)
      end
    end,
    weight = 100,
    lv = 1,
    key = {"唯一", "歌姬"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if not u:isgirl() then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cFFFFFF99「|r|cFFFFFC96我|r|cFFFFF993叫|r|cFFFFF690月|r|cFFFFF38D见|r|cFFFFF08A英|r|cFFFFED87子|r|cFFFFEA84，|r|cFFFFE781叫|r|cFFFFE47E我|r|cFFFFE17B英|r|cFFFFDE78子|r|cFFFFDB75就|r|cFFFFD872好|r|cFFFFD56F。|r|cFFFFD26C」|r")
      PlayGlobalSound(Sound_Yingzi_01)
      u:setdata("属性-歌姬传奇")
      Weiyi_Feishen[41] = true
      ChangeValue(DamageSystem_Shjc, sy, 0.025)
      local add = 0
      local ewys = 0
      ac.loop(3000, function()
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -ewys)
        ChangeValue(DamageSystem_Shjc, sy, -add)
        local citiao1 = u:getstate("歌姬变异")
        if BGMIsChange then
          if u:hasdata("变异判定-月见英子") then
            add = 1
            ewys = 150
          else
            add = 0.5
            ewys = 100
          end
        else
          add = 0
          ewys = 0
        end
        add = add + 0.01 * citiao1
        ChangeValue(DamageSystem_Shjc, sy, add)
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, ewys)
      end)
    end,
    effectname = "|cFFFFFF99地狱歌姬|r",
    effecttext = "|cFFFFECC4[凡俗]|r\n|cFFFFFF99唯一 歌姬|r\n|cFFFFCC66提升[歌姬变异*1%]伤害加成\n处于BGM播放时:\n[提升50%伤害加成\n提升100额外移速]|r\n|cFFFFFF99【集智】|r\n|cFFFFCC66死亡不掉落物品\n使用非净化药剂时25%获取一瓶净化药剂|r",
    effectart = "war3mapImported\\BTNEwl_Yueying_01"
  },
  {
    name = "洗衣女仆",
    weight = 100,
    key = {
      "龙",
      "水",
      "唯一"
    },
    unique = true,
    lv = 2,
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
      ciyuanget(u, var)
      u:chat("|cFF3366FF小蓝降临我身边！|r")
      PlayGlobalSound(Sound_Xiyinvpu_01)
      u:become("女仆")
      u:changedata("女仆变异数量", 1)
      ChangeValue(Hero_Tili_Huifu, sy, 0.1)
      ChangeValue(DamageSystem_Shjc, sy, 0.025)
      u:changedata("幸运", 1)
      u:changedata("龙变异补正", -50)
      local dskill = S2ID("A1EL")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          local dis = DistanceBetweenUnits(u.handle, args.target)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            local tg = getunit(args.target)
            SendMsgAll("|cFF3366FF小蓝对|r" .. tg:getplayername() .. "|cFF3366FF使用了|r|cFFFFFF00[星星金币]|r")
            local wplx = {}
            wplx[1] = MEDICINE_YITAI
            wplx[2] = MEDICINE_LNS
            wplx[3] = MEDICINE_MWX
            wplx[4] = MEDICINE_BLOOD
            wplx[5] = MEDICINE_HUIYI
            wplx[6] = MEDICINE_JINGHUA
            local str1
            local b1 = false
            for i = 1, 6 do
              local wp = tg:getcountitem(i)
              for j = 1, 6 do
                if GetItemTypeId(wp) == wplx[j] then
                  str1 = GetItemName(wp)
                  ChangeItemCount(wp, -1)
                  b1 = true
                  break
                end
              end
              if b1 then
                break
              end
            end
            local str2
            local b2 = false
            for i = 1, 6 do
              local wp = tg:getcountitem(i)
              for j = 1, 6 do
                if GetItemTypeId(wp) == wplx[j] then
                  str2 = GetItemName(wp)
                  ChangeItemCount(wp, -1)
                  b2 = true
                  break
                end
              end
              if b2 then
                break
              end
            end
            if b1 then
              local wp = tg:additem(wplx[GetRandomInt(1, 6)])
              local str3 = GetItemName(wp) or ""
              if b2 then
                local x, y = u:getxy()
                local wp2 = CreateItemLua(wplx[GetRandomInt(1, 6)], x, y)
                local str4 = GetItemName(wp2) or ""
                tg:addspeitem(wp2)
                SendMsgAll("|cFF3366FF把|r" .. str1 .. "|cFF3366FF和|r" .. str2 .. "|cFF3366FF变成了|r" .. str3 .. "|cFF3366FF和|r" .. str4)
              else
                SendMsgAll("|cFF3366FF把|r" .. str1 .. "|cFF3366FF变成了|r" .. str3)
              end
            else
              SendMsgAll("|cFF3366FF然而什么事都没有发生|r")
            end
            if u:hasdata("变异判定-苍河龙女") then
              local t = 160 - 15 * u:getdata("水变异数量")
              if t <= 30 then
                t = 30
              end
              ewl:setskillcd(dskill, t)
            end
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      local cs = 0
      ac.loop(3000, function()
        if u:isalive() then
          cs = cs + 1
          if cs == 30 then
            cs = 0
            local zu = {
              "卡组废件",
              "卡组Key卡",
              "贪欲之壶"
            }
            if not Boolean_Huiliuli_Death and not u:hasdata("变异判定-灰流丽") and GetRandom100(25) then
              table.insert(zu, "灰流丽")
            end
            if u:getdata("珠泪哀歌变异数量") < 3 and GetRandom100(10) then
              table.insert(zu, "珠泪哀歌")
            end
            local str = zu[GetRandomInt(1, #zu)]
            local showstr = ""
            if str == "贪欲之壶" then
              showstr = "你获得资源箱x1,接下来60秒开启补给箱不会有任何效果"
              u:additem("I038")
              ac.wait(1000, function()
                u:settimedata("小蓝-贪欲之壶失效", 60)
                ac.wait(60000, function()
                  u:sendmessage("|cFF6699FF[洗衣女仆]贪欲之壶惩罚结束|r")
                end)
              end)
            end
            if str == "珠泪哀歌" then
              showstr = "你获得一个[珠泪哀歌]基础变异"
              local dpools = {
                Vars_Spe_Zhuleiaige
              }
              herogetvar(u.handle, dpools, "次元")
            end
            if str == "卡组废件" then
              showstr = "无任何效果"
            end
            if str == "灰流丽" then
              showstr = "无任何效果"
              Boolean_Huiliuli_Death = true
              u:chat("|cFF949596“你可还有话要说”|r")
              NPCChat({
                name = "|cFFFF6699灰|r|cFFE47298流|r|cFFCA7E98丽|r",
                chaticon = "Chat_Huiliuli.tga",
                chattext = {
                  {
                    text = "|cFF949596“再无话说，请速速动手”|r",
                    time = 3
                  }
                }
              })
              PlayBGM({
                bgm = BGM_Huiliuli_01,
                time = 30,
                ID = 220,
                unit = u.handle
              })
            end
            if str == "卡组Key卡" then
              showstr = "你红温了(提升0.5%伤害加成,燃烧自身60秒)"
              u:buffset(u.handle, 60, "燃烧")
              ChangeValue(DamageSystem_Shjc, sy, 0.005)
            end
            u:sendmessage("|cFF3366FF小蓝帮你堆到了[" .. str .. "]," .. showstr)
          end
        end
      end)
      u:setdata("小蓝-进修次数", 0)
      u:addstexiao(var.name, "过波时效果", function(args)
        if not u:hasdata("小蓝-进修完毕") then
          if u:getluckrandom(1) then
            u:setdata("小蓝-进修完毕")
            SendMsgAll(u:getplayername() .. "|cFF3366FF的小蓝天资聪慧！提前进修毕业！为她庆贺！")
            SendMsgAll("|cFF3366FF【BGM：DRAGONFLAME】")
            local zu = {
              "超洗衣骑士",
              "毁灭凤凰蓝",
              "未来蓝皇",
              "混沌魔龙"
            }
            AdvanceGet[zu[GetRandomInt(1, #zu)]](u)
          else
            u:changedata("小蓝-进修次数", 1)
            local sj = GetRandomInt(1, 5)
            if sj == 1 then
              u:sendmessage("|cFF3366FF你的小蓝捡回来了亮晶晶的东西……(获得一件特殊物品)")
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
            if sj == 2 then
              u:sendmessage("|cFF3366FF你的小蓝捡回来了一个盒子(获得次元匣*1)")
              u:additem("I00X")
            end
            if sj == 3 then
              u:sendmessage("|cFF3366FF你的小蓝进行了身体素质锻炼(提升0.5%伤害加成)")
              ChangeValue(DamageSystem_Shjc, sy, 0.005)
            end
            if sj == 4 then
              u:sendmessage("|cFF3366FF你的小蓝吃胖了……(提升250生命上限)")
              u:changemaxhp(250)
            end
            if sj == 5 then
              u:sendmessage("|cFF3366FF你的小蓝偷懒了一会……(无效果)")
            end
            if u:getdata("小蓝-进修次数") == 10 then
              u:setdata("小蓝-进修完毕")
              SendMsgAll(u:getplayername() .. "|cFF3366FF的小蓝成功毕业了！")
              AdvanceGet["苍河龙女"](u)
            end
          end
        end
      end)
    end,
    effectname = "|cFF3366FF洗|r|cFF4477FF衣|r|cFF5588FF女|r|cFF6699FF仆|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF3366FF唯一 龙 水|r\n|cFF6699FF提升0.1体力恢复\n提升2.5%伤害加成|r\n|cFF3366FF【星星金币】|r\n|cFF6699FF提升1幸运\n获得拓展技能[星星金币]|r\n|cFF3366FF【叶公好蓝】|r\n|cFF6699FF降低50%龙变异补正|r\n|cFF3366FF【清扫龙女的困境】|r\n|cFF6699FF每存活90秒自动进行一次堆墓,随机触发一项(概率不等):\n1.堆下去[贪欲之壶]\n2.堆下去[珠泪哀歌]\n3.堆下去[卡组废件]\n4.堆下去[灰流丽]\n5.堆下去[卡组Key卡]|r\n|cFF3366FF【三十年河东，三十年河西】|r\n|cFF6699FF小蓝过波时会进行一次进修,极低概率直接进修成功进阶\n累积10次进修也能毕业常规进阶|r",
    effectart = "war3mapImported\\BTNEwl_Longnvpu_1"
  },
  {
    name = "瑟莉亚",
    weight = 100,
    lv = 2,
    key = {
      "唯一",
      "魔导",
      "白毛"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if not u:isgirl() then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cFF3366FF『|r|cFF4471F9抱|r|cFF557DF4歉|r|cFF6688EE吓|r|cFF7793E8到|r|cFF889FE3你|r|cFF99AADD了|r|cFFAAB5D7』|r")
      ac.wait(2500, function()
        SendMsgAll("|cFF3366FF『|r|cFF406EFB请|r|cFF4C77F6问|r|cFF5980F2你|r|cFF6688EE叫|r|cFF7390EA什|r|cFF8099E6么|r|cFF8CA2E1名|r|cFF99AADD字|r|cFFA6B2D9呢|r|cFFB2BBD4』|r")
      end)
      ac.wait(5200, function()
        SendMsgAll("|cFF3366FF『|r|cFF4673F9我|r|cFF5980F2叫|r|cFF6C8CEC瑟|r|cFF8099E6莉|r|cFF93A6DF亚|r|cFFA6B2D9』|r")
      end)
      PlayGlobalSound(Sound_Seliya_01)
      Weiyi_Feishen[40] = true
      coopjudge("师德充沛")
      ChangeValue(Correction_Exp, sy, 0.5)
      local exp = 0
      local add = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * (-1 * add))
        u:changedata("全属性增幅", -0.5 * add)
        add = 0.02 * u:getdata("白毛变异数量")
        u:changedata("全属性增幅", 0.5 * add)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * (1 * add))
      end)
    end,
    effectname = "|cFF3366FF小|r|cFF8099E6老|r|cFFCCCCCC师|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF3366FF唯一 魔导 白毛|r\n|cFF3366FF【魔法天才】|r\n|cFFCCCCCC提升50%经验获取|r\n|cFF3366FF【你也是白毛控?】|r\n|cFFCCCCCC提升[0.25%*白毛变异]基础回忆成功率\n提升[0.2%*白毛变异]终结伤害\n提升[1%*白毛变异]全属性|r",
    effectart = "war3mapImported\\BTNEwl_Xiaolaoshi_1"
  },
  {
    name = "卧龙",
    clickfunc = function(u, ewl)
      local sy = u.ownerid
      if u:isalive() and u:ishasshw() and (u:hasdata("诸葛亮进阶标记") or u:getint() >= 200) then
        u:deldata("诸葛亮进阶标记")
        AdvanceGet["诸葛亮"](u)
      end
    end,
    weight = 100,
    lv = 2,
    key = {"唯一"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if not u:isgirl() then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cFFFFFF33『|r|cFFF5FF39一|r|cFFECFF40切|r|cFFE2FF46尽|r|cFFD9FF4C在|r|cFFCFFF53掌|r|cFFC6FF59握|r|cFFBCFF60之|r|cFFB2FF66中|r|cFFA9FF6C，|r|cFF9FFF73啊|r|cFF96FF79~|r|cFF8CFF80唔|r|cFF83FF86~|r|cFF79FF8C』|r")
      PlayGlobalSound(Sound_Kongming__1_u)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        if u:hasdata("卧龙-落樱状态") and not u:hasdata(var.name .. "-特效冷却") then
          tg:effectadd("AATX\\[AATxNew]Pink08.mdl", "origin", 0.1)
          local txsh = 50 * u:getint()
          if u:hasdata("变异判定-诸葛亮") then
            txsh = 50 * u:getallattri()
          end
          DamageUnit({
            bj = "卧龙(木牛流马)",
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
          u:settimedata(var.name .. "-特效冷却", 0.1)
        end
      end)
      u:addstexiao(var.name, "暴击系统触发效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:getluckrandom(4) and not u:hasdata("卧龙-木牛流马冷却") then
          u:changedata("卧龙-落樱点数", 1)
          u:sendmessage("|cFFFFCCFF落樱点数：" .. math.floor(u:getdata("卧龙-落樱点数")) .. "|r")
          tg:playsound(bac118)
          if 4 <= u:getdata("卧龙-落樱点数") then
            local x2, y2 = tg:getxy()
            u:setdata("卧龙-落樱点数", 0)
            u:playsound(bac126)
            u:settimedata("卧龙-落樱状态", 15)
            Effectcreate("AATX\\[AATxNew]Pink12.mdl", x2, y2)
            Effectcreate("AATX\\[AATxNew]Pink05.mdl", x2, y2)
            u:effectadd("AATX\\[Sakura]04.mdl", 15)
            u:settimedata("卧龙-木牛流马冷却", 90)
          end
        end
      end)
      if u:isgirl() then
        ac.loop(1000, function(timer)
          if u:hasdata("诸葛亮进阶标记") then
            timer:remove()
          end
          local gl = 0.02
          if u:hasdata("七罪-暴食") then
            gl = 0.04
          end
          if u:getint() >= 200 or u:getluckrandom(gl) and IsTimeDay() then
            u:setdata("诸葛亮进阶标记")
            u:sendmessage("|cFFFFFF00卧龙进阶解锁|r")
            timer:remove()
          end
        end)
      end
      u:addint(100)
    end,
    effectname = "|cFFFFFF00卧|r|cFFBBFF33龙|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFFFFF00唯一|r\n|cFFBBFF33提升100智力|r\n|cFFFFFF00【奇门遁甲】|r\n|cFFBBFF33受伤时格挡伤害,冷却8秒|r\n|cFFFFFF00【木牛流马】|r\n|cFFBBFF33暴击时4%积累1点落樱计数\n落樱计数达到4点时清空并进入樱落状态15秒(冷却90秒)\n持续期间:\n[直接伤害时附带[智力*50]灵力伤害(冷却0.1秒)]|r",
    effectart = "war3mapImported\\BTNEwl_Kongming_02"
  },
  {
    name = "立华奏",
    weight = 100,
    lv = 2,
    key = {"白毛", "光明"},
    unique = false,
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
      ciyuanget(u, var)
      SendMsgAll("|cFFFF66FF「|r|cFFFF6EFF活|r|cFFFF76FF着|r|cFFFF7EFF是|r|cFFFF85FF件|r|cFFFF8DFF很|r|cFFFF95FF美|r|cFFFF9DFF好|r|cFFFFA5FF的|r|cFFFFADFF事|r|cFFFFB4FF情|r|cFFFFBCFF」|r")
      PlayGlobalSound(Sound_Kanade_01)
      ChangeValue(Correction_Exp, sy, 0.2)
      ChangeValue(Correction_Gold, sy, 0.05)
      local gun_bonus = 0
      local damage_bonus = 0
      
      local function refresh_saijier_bonus()
        ChangeValue(DamageSystem_Shjc, sy, -damage_bonus)
        local dark_mutation = u:getstate("光明变异")
        damage_bonus = 0.01 * dark_mutation
        ChangeValue(DamageSystem_Shjc, sy, damage_bonus)
      end
      
      refresh_saijier_bonus()
      ac.loop(3000, refresh_saijier_bonus)
      u:addstexiao(var.name, "近战伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          local x, y = tg:getxy()
          u:settimedata(var.name .. "-特效冷却", 0.1)
          Effectcreate("AATX\\[AATxNew]White03.mdl", x, y, 0, 0.5, 90, u:getface(), 90)
          DamageUnit({
            bj = "立华奏(音速手刃)",
            unit = tg.handle,
            source = u.handle,
            damage = 0.1 * info.yssh,
            level = 1,
            type = "震荡",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
        end
      end)
    end,
    effectname = "|cFF9966FF天|r|cFFEF91FF使|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF9966FF光明 白毛|r\n|cFFEF91FF提升[光明变异*1%]伤害加成|r\n|cFF9966FF【ANGEL PLAYER】|r\n|cFFEF91FF提升20%经验获取\n提升5%积分获取|r\n|cFF9966FF【音速手刃】|r\n|cFFEF91FF近战伤害附带[10%伤害值]震荡伤害,冷却0.1秒|r\n|cFF9966FF【超频延迟】|r\n|cFFEF91FF受到致死伤害时抵挡该次伤害并在5秒内提升500额外移速且期间绝对闪避\n触发时使自身周围1800范围敌军时停10秒,触发冷却300秒|r",
    effectart = "war3mapImported\\BTNEwl_Lihuazou_Chuanqi.blp"
  },
  {
    name = "仰慕主人的小小引导者",
    weight = 100,
    lv = 2,
    key = {
      "唯一",
      "魔导",
      "同奏",
      "自然",
      "白毛"
    },
    unique = true,
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
      ciyuanget(u, var)
      SendMsgAll("|cFF66FF99「|r|cFF6AFF9B我|r|cFF6EFF9D是|r|cFF71FF9F伟|r|cFF75FFA1大|r|cFF79FFA2的|r|cFF7DFFA4爱|r|cFF80FFA6梅|r|cFF84FFA8斯|r|cFF88FFAA大|r|cFF8CFFAC人|r|cFF90FFAE派|r|cFF93FFB0来|r|cFF97FFB2的|r|cFF9BFFB3「|r|cFF9FFFB5向|r|cFFA2FFB7导|r|cFFA6FFB9」|r|cFFAAFFBB |r|cFFAEFFBD名|r|cFFB2FFBF字|r|cFFB5FFC1叫|r|cFFB9FFC3可|r|cFFBDFFC4可|r|cFFC1FFC6萝|r|cFFC4FFC8」|r")
      PlayGlobalSound(Sound_Kekeluo_01)
      u:addskill("S064")
      AddAllSTexiao(var.name, "伤害系统计算效果", function(args)
        local info = args.damageinfo
        if args.u:ishasbuff("B09F") then
          info.gs = info.gs + 10000
        end
      end)
      AddUISkill({
        text = "精灵的启示",
        u = u,
        showtext = "|cFF66FF99「精灵的启示」|r\n|cFF66FF99提升全队25000固定伤害与100%近战伤害\n持续25秒\n冷却90秒|r",
        cd = 90,
        icon = "war3mapImported\\BTNEwl_Kekeluo_Chuanqi.blp",
        func = function(args)
          local u = args.u
          if u:isalive() then
            local yx = {}
            yx[1] = Sound_Kekeluo_02
            yx[2] = Sound_Kekeluo_03
            u:playsound(yx[GetRandomInt(1, 2)])
            ForGroupLuaNew(Group_PlayHero, function(xq)
              local sy2 = xq.ownerid
              xq:effectadd("Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl")
              xq:effectadd("war3mapImported\\[TX] (837).mdl", "origin", 25)
              ChangeTimeValue(Correction_Jzsh, sy2, 1, 25)
              xq:changetimedata("固定伤害", 25000, 25)
            end)
          end
        end
      })
      ac.loop(45000, function()
        if u:isalive() then
          local yx = {}
          yx[1] = Sound_Kekeluo_02
          yx[2] = Sound_Kekeluo_03
          u:playsound(yx[GetRandomInt(1, 2)])
          local x, y = u:getxy()
          Effectcreate("war3mapImported\\[Murasame]01 (6).mdl", x, y, 2, 2)
          for _, xq in ac.selector():in_rangexy(x, y, 1800):isingroup(Group_PlayHero):ipairs() do
            xq = getunit(xq)
            xq:effectadd("Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl", "overhead")
            xq:curehp(u.handle, 0, 50, 1)
            local sy2 = xq.ownerid
            ChangeTimeValue(DamageSystem_Shjc, sy, 0.5, 18)
          end
        end
      end)
    end,
    effectname = "|cFF66FF99仰慕主人的小小引导者|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF66FF99唯一 同奏 自然 魔导|r\n|cFF66FF99【极光】|r\n|cFFCCFFCC每存活45秒对自身与1800范围友军施加效果:\n【医疗恢复50%生命值\n提升50%伤害加成,持续18秒】|r\n|cFF66FF99【精灵的启示】|r\n|cFFCCFFCC被动提升自身与900范围友军12%移速,4%额外移速与10000固定伤害\n获得拓展技能[精灵的启示]|r",
    effectart = "war3mapImported\\BTNEwl_Kekeluo_Chuanqi.blp"
  },
  {
    name = "百夜米迦尔",
    weight = 500,
    lv = 3,
    key = {
      "唯一",
      "吸血鬼",
      "战士"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      return u:hasdata("血统判定-默示录病毒")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      coopjudge("终结的炽天使", u)
      u:chat("|cFFFF0000我一个人就足够了|r")
      u:chat("|cFFFF0000我会让你后悔挑衅我|r", 1.8)
      PlayGlobalSound(Sound_Mje_01)
      local melee = 0
      local damage = 0
      local max_hp = 0
      
      local function refresh_vampire_bonus()
        ChangeValue(Correction_Jzsh, sy, 0.1 * -melee)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -damage)
        ChangeValue(Correction_MHp, sy, 0.1 * -max_hp)
        local vampire = u:getstate("吸血鬼变异")
        melee = 0.03 * vampire
        damage = 0.06 * vampire
        max_hp = 0.01 * vampire
        ChangeValue(Correction_Jzsh, sy, 0.1 * melee)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * damage)
        ChangeValue(Correction_MHp, sy, 0.1 * max_hp)
      end
      
      refresh_vampire_bonus()
      ac.loop(3000, refresh_vampire_bonus)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 1)
          local mfsh = u:getstate("吸血鬼变异") * 10000
          DamageUnit({
            bj = "百夜米迦尔(附伤)",
            unit = tg.handle,
            source = u.handle,
            damage = mfsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "光"
          })
        end
      end)
    end,
    effectname = "|cFFFF0000百|r|cFFFF4020夜|r|cFFFF8040米|r|cFFFFBF60迦|r|cFFFFFF80尔|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFFF0000唯一 吸血鬼 战士|r\n|cFFFFFF80提升[吸血鬼变异*0.3%]近战伤害\n提升[吸血鬼变异*0.6%]伤害加成|r\n|cFFFF0000【\"天使\"】|r\n|cFFFFFF80提升[吸血鬼变异*0.1%]生命上限\n直接伤害时10%附带[吸血鬼变异*10000]光魔力伤害,冷却1秒|r",
    effectart = "Cq_Bymje"
  },
  {
    name = "百夜优一郎",
    weight = 500,
    lv = 3,
    key = {
      "唯一",
      "恶魔",
      "战士"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      return u:hasdata("血统判定-默示录病毒")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      coopjudge("终结的炽天使", u)
      u:chat("|cFF00B700终于让我找到了，吸血鬼|r")
      PlayGlobalSound(Sound_Yyl_01)
      local melee = 0
      local damage = 0
      local end_damage = 0
      
      local function refresh_vampire_bonus()
        ChangeValue(Correction_Jzsh, sy, 0.1 * -melee)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -damage)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * -end_damage)
        local vampire = u:getstate("吸血鬼变异")
        melee = 0.03 * vampire
        damage = 0.06 * vampire
        end_damage = 0.01 * vampire
        ChangeValue(Correction_Jzsh, sy, 0.1 * melee)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * damage)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * end_damage)
      end
      
      refresh_vampire_bonus()
      ac.loop(3000, refresh_vampire_bonus)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      ChangeValue(DamageSplit_CountJzMax, sy, 0.25)
    end,
    effectname = "|cFF00B700百|r|cFF2AC92A夜|r|cFF53DB53优|r|cFF7CED7C一|r|cFFA6FFA6郎|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF00B700唯一 恶魔 战士|r\n|cFFA6FFA6提升[吸血鬼变异*0.3%]近战伤害\n提升[吸血鬼变异*0.6%]伤害加成|r\n|cFF00B700【阿朱罗丸】|r\n|cFFA6FFA6提升[吸血鬼变异*0.1%]终结伤害\n近战多段上限+1(暗物理)\n近战多段伤害+25%|r",
    effectart = "Cq_Byyyl"
  },
  {
    name = "柊筱娅",
    weight = 500,
    lv = 3,
    key = {
      "唯一",
      "恶魔",
      "吸血鬼"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      return u:hasdata("血统判定-默示录病毒")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      coopjudge("终结的炽天使", u)
      u:chat("|cFFA53C6D繁衍吧！|r")
      u:chat("|cFFA53C6D万岁！不纯洁异性交往！|r", 1.7)
      PlayGlobalSound(Sound_Zxy_01)
      local damage = 0
      local end_damage = 0
      local fixed_damage = 0
      
      local function refresh_vampire_bonus()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -damage)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * -end_damage)
        u:changedata("固定伤害", 0.1 * -fixed_damage)
        local vampire = u:getstate("吸血鬼变异")
        damage = 0.06 * vampire
        end_damage = 0.01 * vampire
        fixed_damage = 14444 * vampire
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * damage)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * end_damage)
        u:changedata("固定伤害", 0.1 * fixed_damage)
      end
      
      refresh_vampire_bonus()
      ac.loop(3000, refresh_vampire_bonus)
      ac.loop(6000, function()
        u:changemaxhp(u:getstate("吸血鬼变异"))
      end)
    end,
    effectname = "|cFFA53C6D柊筱娅|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFA53C6D唯一 恶魔 吸血鬼|r\n|cFFDE98C5提升[吸血鬼变异*0.6%]伤害加成\n提升[吸血鬼变异*0.1%]终结伤害|r\n|cFFA53C6D【四镰童子】|r\n|cFFDE98C5每6秒提升[吸血鬼变异*1]生命上限\n提升[吸血鬼变异*1444.4]固定伤害\n提升44%镰刀伤害|r",
    effectart = "Cq_Txy"
  },
  {
    name = "始祖吸血鬼",
    clickfunc = function(u, ewl)
      local sy = u.ownerid
      if not u:hasdata("变异判定-克鲁鲁") and u:isalive() and u:ishasshw() and u:getdata("吸血鬼变异数量") >= 9 then
        AdvanceGet["克鲁鲁"](u)
      end
    end,
    weight = 500,
    lv = 3,
    key = {"唯一", "吸血鬼"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      return u:hasdata("血统判定-默示录病毒")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      coopjudge("终结的炽天使", u)
      SendMsgAll("|cFFCC0000「|r|cFFCF060B我|r|cFFD20B17可|r|cFFD51122以|r|cFFD7172D赐|r|cFFDA1C39予|r|cFFDD2244你|r|cFFE0284F生|r|cFFE32D5B命|r|cFFE63366，|r|cFFE83971永|r|cFFEB3E7D恒|r|cFFEE4488的|r|cFFF14A93生|r|cFFF44F9F命|r|cFFF755AA。|r|cFFF95BB5」|r")
      PlayGlobalSound(Sound_Kelulu_01)
      u:changedata("吸血鬼变异补正", 100)
      u:changedata("效果增强-吸血鬼", 0.25)
      local damage = 0
      local health_regen = 0
      
      local function refresh_vampire_bonus()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -damage)
        ChangeValue(HeroMenu_HpChange_Inr, sy, -health_regen)
        local vampire = u:getstate("吸血鬼变异")
        damage = 0.06 * vampire
        health_regen = 5 * vampire
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * damage)
        ChangeValue(HeroMenu_HpChange_Inr, sy, health_regen)
      end
      
      refresh_vampire_bonus()
      ac.loop(3000, refresh_vampire_bonus)
    end,
    effectname = "|cFFFF0066始祖吸血鬼|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFFF0066唯一 吸血鬼|r\n|cFFFF6699提升[吸血鬼变异*0.6%]伤害加成\n提升[吸血鬼变异*5]生命恢复\n提升100%吸血鬼补正|r\n|cFFFF0066【艾尔卡努】|r\n|cFFFF6699提升25%吸血鬼效果增强\n受到致死伤害时抵挡该次伤害并转换为10秒内的生命恢复,冷却180秒|r\n|cFFFF0066【血之溯源】|r\n|cFFFF6699吸血鬼变异数量≥9时点击进阶|r",
    effectart = "war3mapImported\\BTNEwl_Kelulu_Chuanqi.blp"
  },
  {
    name = "意志宝具",
    weight = 100,
    lv = 2,
    key = {
      "唯一",
      "根源",
      "自然",
      "战士",
      "灵魂"
    },
    unique = true,
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
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Enqidu_01)
      SendMsgAll("|cFF66FF99『|r|cFF6DFF9D恩|r|cFF75FFA0奇|r|cFF7CFFA4都|r|cFF83FFA8，|r|cFF8AFFAB应|r|cFF92FFAF您|r|cFF99FFB2的|r|cFFA0FFB6呼|r|cFFA8FFBA唤|r|cFFAFFFBD而|r|cFFB6FFC1来|r|cFFBDFFC5』|r")
      u:become("从者")
      u:adddivinity(1)
      ChangeValue(Hero_Tili_Huifu, sy, 0.14)
      ChangeValue(HeroMenu_HpForever_Inr, sy, 14)
      u:changeoriginmaxhp(1444)
      local add = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        add = 0.07 * u:getstate("根源变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      end)
      u:setdata("系统-不受性别限制")
      u:addskill("S062")
      u:addskill("A14Y")
      u:banskill("A14Y")
      u:setskillforever("A14X")
      
      local function skill(args)
        if args.skill == S2ID("A14X") then
          local target = args.target
          local tg = getunit(target)
          u:banskill("A14X")
          u:deldata("恩奇都-变容中")
          u:sendmessage("|cFF66FF99变容中|r")
          ac.wait(3000, function()
            u:banskill("A14X", false)
            if u.handle == tg.handle then
              u:deldata("恩奇都-变容中")
              u:deldata("恩奇都-变容对象")
            else
              u:setdata("恩奇都-变容中")
              u:sendmessage("|cFF66FF99变容成功|r")
              local model, size, r, g, b
              if tg:hasdata("系统-怪物模板") then
                model = tg:getdata("模型-模型")
                size = tg:getdata("模型-模型大小")
                local color = tg:getdata("模型-色表")
                r = color[1]
                g = color[2]
                b = color[3]
              else
                local typeid = GetUnitTypeId(tg.handle)
                model = slk.unit[ID2S(typeid)].file
                size = tonumber(slk.unit[ID2S(typeid)].modelScale)
                r = tonumber(slk.unit[ID2S(typeid)].red)
                g = tonumber(slk.unit[ID2S(typeid)].green)
                b = tonumber(slk.unit[ID2S(typeid)].blue)
              end
              japi.SetUnitModel(u.handle, model)
              u:setsize(size)
              u:setcolor(r, g, b)
              u:setdata("恩奇都-变容模型", model)
              u:setdata("恩奇都-变容模型大小", size)
              if tg:isingroup(Group_PlayHero) then
                u:setdata("恩奇都-原始ID", u:getplayername())
                u:setplayername(tg:getplayername())
                u:setdata("恩奇都-变容对象", target)
                for index, value in ipairs(vartype) do
                  u:setdata("恩奇都-保存变异" .. value.name, u:getdata(value.name .. "变异数量"))
                  u:setdata("恩奇都-复制变异" .. value.name, tg:getdata(value.name .. "变异数量"))
                  u:setdata(value.name .. "变异数量", u:getdata("恩奇都-复制变异" .. value.name))
                end
                ac.loop(3000, function(timer)
                  for index, value in ipairs(vartype) do
                    if u:getdata(value.name .. "变异数量") ~= u:getdata("恩奇都-复制变异" .. value.name) then
                      u:changedata("恩奇都-保存变异" .. value.name, u:getdata(value.name .. "变异数量") - u:getdata("恩奇都-复制变异" .. value.name))
                      u:setdata("恩奇都-复制变异" .. value.name, tg:getdata(value.name .. "变异数量"))
                      u:setdata(value.name .. "变异数量", u:getdata("恩奇都-复制变异" .. value.name))
                    end
                  end
                  if not u:hasdata("恩奇都-变容中") then
                    u:sendmessage("|cFF66FF99变容解除|r")
                    u:setplayername(u:getdata("恩奇都-原始ID"))
                    for index, value in ipairs(vartype) do
                      u:setdata(value.name .. "变异数量", u:getdata("恩奇都-保存变异" .. value.name))
                    end
                    local typeid = GetUnitTypeId(u.handle)
                    japi.SetUnitModel(u.handle, slk.unit[ID2S(typeid)].file)
                    u:setsize(tonumber(slk.unit[ID2S(typeid)].modelScale))
                    local r = tonumber(slk.unit[ID2S(typeid)].red)
                    local g = tonumber(slk.unit[ID2S(typeid)].green)
                    local b = tonumber(slk.unit[ID2S(typeid)].blue)
                    u:setcolor(r, g, b)
                    timer:remove()
                  end
                end)
              else
                ac.loop(3000, function(timer)
                  if not u:hasdata("恩奇都-变容中") then
                    u:sendmessage("|cFF66FF99变容解除|r")
                    local typeid = GetUnitTypeId(u.handle)
                    japi.SetUnitModel(u.handle, slk.unit[ID2S(typeid)].file)
                    u:setsize(tonumber(slk.unit[ID2S(typeid)].modelScale))
                    local r = tonumber(slk.unit[ID2S(typeid)].red)
                    local g = tonumber(slk.unit[ID2S(typeid)].green)
                    local b = tonumber(slk.unit[ID2S(typeid)].blue)
                    u:setcolor(r, g, b)
                    timer:remove()
                  end
                end)
              end
            end
          end)
        end
      end
      
      u:addtrgevent("单位-发动技能", function(args)
        skill(args)
      end)
    end,
    effectname = "|cFF66FF99意|r|cFF88FFAA志|r|cFFAAFFBB宝|r|cFFCCFFCC具|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF66FF99神性1 唯一 根源 自然 战士 灵魂|r\n|cFFCCFFCC提升1444基础生命上限|r\n|cFF66FF99【大地之形】|r\n|cFFCCFFCC提升0.14体力恢复\n提升14永恒恢复\n提升[7%*根源变异]伤害加成|r\n|cFF66FF99【变容】|r\n|cFFCCFFCC获得拓展技能[变容]|r",
    effectart = "war3mapImported\\BTNEwl_Enqidu_Chuanqi.blp"
  },
  {
    name = "恶魔附体",
    weight = 100,
    lv = 2,
    key = {
      "黑暗",
      "唯一",
      "外域",
      "魔导"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:isgirl() then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("今天又要开启哪里的门呢？")
      PlayGlobalSound(Sound_Abigaier_01)
      u:become("从者")
      u:become("噩梦具现化")
      u:setdata("阿比盖尔-疯狂程度", 0)
      local data2 = 0
      
      local function refresh_abigaier_bonus()
        ChangeValue(Damage_Element_Heart, sy, -data2)
        local citiao1 = u:getstate("外域变异")
        data2 = 0.001 * citiao1
        ChangeValue(Damage_Element_Heart, sy, data2)
      end
      
      refresh_abigaier_bonus()
      ac.loop(3000, refresh_abigaier_bonus)
      local cs = 0
      ac.loop(3000, function()
        cs = cs + 1
        if 20 <= cs then
          cs = 0
          local sj = GetRandomInt(1, 4)
          if sj == 1 then
            u:changedata("外域变异数量", 1)
            u:changedata("阿比盖尔-疯狂程度", 2)
            u:sendmessage("|cFFFF8040[恶魔附体]信仰的祈祷-提升1外域词条与2疯狂计数|r")
          elseif sj == 2 then
            ChangeValue(Damage_Element_Heart, sy, 0.02)
            u:sendmessage("|cFFFF8040[恶魔附体]信仰的祈祷-提升2%心灵伤害|r")
          else
            if sj == 3 then
              ChangeValue(DamageSystem_Shjc, sy, 0.03)
              u:sendmessage("|cFFFF8040[恶魔附体]信仰的祈祷-提升3%伤害加成|r")
            else
            end
          end
          if u:isalive() then
            if GetRandom100(25) then
              u:chat("もっと~もっと~楽しませてね")
              PlayGlobalSound(Sound_Abigaier_04)
            end
            u:effectadd("ATx\\[ATxNew]Purple_24.mdl")
          end
        end
      end)
      ac.loop(10000, function(timer)
        if not Movie_Boolean then
          if u:hasdata("变异判定-阿比盖尔") then
            timer:remove()
          end
          if u:isalive() and u:getluckrandom(10) then
            u:sendmessage("|cFFFF8040[恶魔附体]进入疯狂状态……")
            u:settimedata("阿比盖尔-疯狂状态", 9.9)
            u:changedata("阿比盖尔-疯狂程度", 1)
            u:effectadd("Abilities\\Spells\\Other\\Parasite\\ParasiteTarget.mdl", "overhead", 10)
            local x, y = u:getxy()
            Effectcreate("ATx\\[ATxNew]Black_10.mdl", x, y, 0, 1.5)
            if GetRandom100(10) then
              u:playsound(Sound_Abigaier_04)
            end
            for _, xq in ac.selector():in_rangexy(x, y, 900):is_not(u.handle):ipairs() do
              xq = getunit(xq)
              if xq:is_enemy(u.handle) or xq:isingroup(Group_PlayHero) then
                xq:buffset(u.handle, 3, "混乱")
              end
            end
          end
        end
      end)
    end,
    effectname = "|cFFFF8040恶|r|cFFC87349魔|r|cFF916751附|r|cFF5A5A5A体|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFFF8040唯一 外域 魔导 黑暗|r\n|cFF5A5A5A提升[外域变异*1%]心灵伤害|r\n|cFFFF8040【信仰的祈祷】|r\n|cFF5A5A5A每60秒触发一条以下效果:\n1.提升1外域词条与2疯狂计数\n2.提升2%心灵伤害\n3.提升3%伤害加成\n4.无事发生|r\n|cFFFF8040【理智丧失】|r\n|cFF5A5A5A每10秒10%进入疯狂状态10秒:\n[提升1点疯狂计数\n触发时混乱3秒自身周围900范围内除自身所有单位\n持续期间直接伤害造成心灵伤害]|r\n|cFFFF8040【魔女审判】|r\n|cFF5A5A5A[数据删除]|r",
    effectart = "war3mapImported\\BTNEwl_Abigaier_Chuanqi.blp"
  },
  {
    name = "怪盗",
    cd = 3,
    weight = 100,
    lv = 2,
    key = {
      "影",
      "念力",
      "同奏"
    },
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      if CIUC[sy] == "1155201793" then
        add = add + 2500
      end
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:sendmessage("|cFFCC3366「|r|cFFC53A6D反|r|cFFBD4275抗|r|cFFB6497C命|r|cFFAF5083运|r|cFFA8578A |r|cFFA05F92渴|r|cFF996699望|r|cFF926DA0变|r|cFF8A75A8革|r|cFF837CAF之|r|cFF7C83B6人|r|cFF758ABD」|r")
      ac.wait(4800, function()
        u:sendmessage("|cFFCC3366「|r|cFFC23D70汝|r|cFFB8477A即|r|cFFAD5285“|r|cFFA35C8F奇|r|cFF996699术|r|cFF8F70A3师|r|cFF857AAD”|r|cFF7A85B8」|r")
      end)
      ac.wait(8800, function()
        u:sendmessage("|cFFCC3366「|r|cFFC7386B现|r|cFFC13E71在|r|cFFBC4376就|r|cFFB7487B去|r|cFFB14E81挑|r|cFFAC5386战|r|cFFA6598C这|r|cFFA15E91世|r|cFF9C6396间|r|cFF96699C的|r|cFF916EA1扭|r|cFF8C73A6曲|r|cFF8679AC的|r|cFF817EB1深|r|cFF7B84B7渊|r|cFF7689BC吧|r|cFF718EC1」|r")
      end)
      u:playseensound(Sound_Persona_01)
      if CIUC[sy] == "1155201793" then
        for index, value in ipairs(Pools_Spe) do
          if value.name == "假面" then
            if not value.hasbeenget then
              local item = u:additem("I0IO")
              value.hasbeenget = true
            end
            break
          end
        end
      end
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
      ChangeValue(Damage_Element_Heart, sy, 0.05)
      ChangeValue(DamageSystem_Baoji, sy, 5)
      u:groupadd(Group_Guaidaotuan)
      local zs = 0
      local add = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Baoshang, sy, -0.05 * zs)
        zs = Group_Counts(Group_Guaidaotuan)
        u:setdata("雨宫莲-怪盗数量", zs)
        ChangeValue(DamageSystem_Baoshang, sy, 0.05 * zs)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        add = 0.11 * TONGZOU_Count
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 3)
          local x, y = tg:getxy()
          Effectcreate("war3mapImported\\[TX] (948).mdl", x, y)
          local txsh = 120000
          DamageUnit({
            bj = "怪盗(心灵之力)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "震荡",
            isvest = false,
            isattack = false,
            isnoarmor = false,
            element = "心灵",
            extradata = {
              "系统-本次伤害无视伤害免疫"
            }
          })
        end
      end)
    end,
    effectname = "|cFF9F0004怪盗|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF9F0004影 念力 同奏|r\n|cFFC0C0C0提升25额外移速|r\n|cFFC0C0C0提升[1.1%*全队同奏数量]伤害加成|r\n|cFF9F0004【心灵之力】|r\n|cFFC0C0C0提升5%心灵伤害|r\n|cFFC0C0C0直接伤害时附带[120000]心灵震荡伤害,触发冷却3秒|r\n|cFF9F0004【怪盗团】|r\n|cFFC0C0C0提升5%暴击率|r\n|cFFC0C0C0提升[全队怪盗数量*5%]暴击伤害|r",
    effectart = "war3mapImported\\BTNEwl_Persona_Chuanqi.blp"
  },
  {
    name = "蒂雅",
    weight = 25,
    lv = 2,
    key = {
      "唯一",
      "白毛",
      "魔导",
      "炎"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if not u:isgirl() then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cFF99FFFF『|r|cFF9DFBFB我|r|cFFA0F8F8的|r|cFFA4F4F4名|r|cFFA8F0F0字|r|cFFABEDED是|r|cFFAFE9E9蒂|r|cFFB2E6E6雅|r|cFFB6E2E2.|r|cFFBADEDE维|r|cFFBDDBDB科|r|cFFC1D7D7尼|r|cFFC5D3D3』|r")
      ac.wait(3100, function()
        SendMsgAll("|cFF99FFFF『|r|cFF9FF9F9请|r|cFFA4F4F4多|r|cFFAAEEEE关|r|cFFB0E8E8照|r|cFFB5E3E3喔|r|cFFBBDDDD~|r|cFFC1D7D7』|r")
      end)
      PlayGlobalSound(Sound_Xiaolaoshi_2)
      Weiyi_Feishen[39] = true
      coopjudge("师德充沛")
      local add = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Magic, sy, -add)
        add = 0.001 * u:getint()
        ChangeValue(Correction_Magic, sy, add)
      end)
      local COLOR_ATTRS = {
        {
          key = "雷变异数量",
          name = "雷"
        },
        {
          key = "水变异数量",
          name = "水"
        },
        {
          key = "炎变异数量",
          name = "炎"
        },
        {
          key = "冰变异数量",
          name = "冰"
        },
        {
          key = "风变异数量",
          name = "风"
        },
        {
          key = "土变异数量",
          name = "土"
        }
      }
      u:setdata("蒂雅-虹色魔法士属性", 3)
      local last_attr = 3
      local last_vals = {
        0,
        0,
        0,
        0,
        0,
        0
      }
      local last_total = 0
      ac.loop(1000, function()
        if last_total ~= 0 then
          local last_key = COLOR_ATTRS[last_attr].key
          u:changedata(last_key, -last_total)
        end
        for i, info in ipairs(COLOR_ATTRS) do
          local v = last_vals[i]
          if v ~= 0 then
            u:changedata(info.key, v)
          end
        end
        local total = 0
        for i, info in ipairs(COLOR_ATTRS) do
          local v = u:getdata(info.key)
          last_vals[i] = v
          total = total + v
          u:setdata(info.key, 0)
        end
        local cur_attr = u:getdata("蒂雅-虹色魔法士属性")
        if cur_attr < 1 or cur_attr > #COLOR_ATTRS then
          cur_attr = 1
          u:setdata("蒂雅-虹色魔法士属性", cur_attr)
        end
        local cur_key = COLOR_ATTRS[cur_attr].key
        u:setdata(cur_key, total)
        last_attr = cur_attr
        last_total = total
      end)
      local dskill = S2ID("A1EN")
      
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
        local str = "|cFF99FFFF将自身元素变异切换属性|n[|r" .. table.concat(parts) .. "|cFF99FFFF]|n冷却1秒|r"
        u:setskilldatastring(dskill, "提示拓展", str)
      end
      
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
        local xt = u:getdata("蒂雅-虹色魔法士属性") or 1
        xt = xt % #COLOR_ATTRS + 1
        u:setdata("蒂雅-虹色魔法士属性", xt)
        updatetip(u, xt)
        u:sendmessage("|cFF99FFFF元素切换成功|r")
      end)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        if GetRandom100(25) then
          u:addlevel(-1)
          u:sendmessage("|cFF99FFFF[蒂雅]抗老化|r")
        end
      end)
    end,
    effectname = "|cFF99FFFF小|r|cFFB2E6E6老|r|cFFCCCCCC师|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF99FFFF唯一 魔导 炎|r\n|cFFCCCCCC提升[智力*0.01%]法术修正|r\n|cFF99FFFF【虹色魔法士】|r\n|cFFCCCCCC自身[雷/炎/冰/水/风/土]变异数量将会相加且只计入一种\n获得拓展技能[元素切换]|r\n|cFF99FFFF【抗老化】|r\n|cFFCCCCCC升级时25%降低1级|r",
    effectart = "war3mapImported\\BTNEwl_Xiaolaoshi_2"
  },
  {
    name = "刘焉",
    weight = 100,
    lv = 2,
    key = {"唯一", "三国"},
    unique = true,
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
      ciyuanget(u, var)
      if GetRandomInt(1, 2) == 1 then
        u:chat("|cFFBA6B33『拒险以图进，备策而施为。』|r")
        PlayGlobalSound(Sound_Liuyan_01)
      else
        u:chat("|cFFBA6B33『夫战者，可施以奇险之策而图常谋！』|r")
        PlayGlobalSound(Sound_Liuyan_02)
      end
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata("刘焉-特效失效") and not u:hasdata(var.name .. "-特效冷却") then
          if GetRandom100(98) then
            if not u:hasdata("系统-清净模式") and not u:hasdata(var.name .. "-音效冷却") then
              u:settimedata(var.name .. "-音效冷却", 8)
              if GetRandomInt(1, 2) == 1 then
                u:chat("|cFFBA6B33『拒险以图进，备策而施为。』|r")
                u:playseensound(Sound_Liuyan_01)
              else
                u:chat("|cFFBA6B33『夫战者，可施以奇险之策而图常谋！』|r")
                u:playseensound(Sound_Liuyan_02)
              end
            end
            u:settimedata(var.name .. "-特效冷却", 0.4)
            local txsh = 50000
            DamageUnit({
              bj = "刘焉(图射)",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "物理",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
            u:changedata("刘焉-伤害加成", 0.01)
            ChangeValue(DamageSystem_Shjc, sy, 0.01)
          else
            u:setdata("刘焉-特效失效", 60)
            if not u:hasdata("系统-清净模式") then
              u:chat("|cFFBA6B33我怎会有…图谋不轨之心……|r")
              u:playseensound(Sound_Liuyan_N_01)
            end
            if GetRandom100(50) then
              u:sendmessage("|cFFBA6B33[刘焉]图射卡闪|r")
            else
              u:sendmessage("|cFFBA6B33[刘焉]图射卡桃|r")
            end
            local down = u:getdata("刘焉-伤害加成")
            ChangeValue(DamageSystem_Shjc, sy, -down)
            u:setdata("刘焉-伤害加成", 0)
          end
        end
      end)
      ac.loop(1000, function()
        if u:hasdata("刘焉-特效失效") then
          u:changedata("刘焉-特效失效", -1)
          if u:getdata("刘焉-特效失效") <= 0 then
            u:deldata("刘焉-特效失效")
            u:sendmessage("|cFFBA6B33[刘焉]图射恢复|r")
          end
        end
      end)
      u:addstexiao(var.name, "脱离战斗状态时", function(args)
        local u = args.u
        if u:hasdata("刘焉-乐不思蜀") then
          u:deldata("刘焉-乐不思蜀")
          if GetRandom100(25) then
            u:sendmessage("|cFFBA6B33[刘焉-立牧]判定结果-红桃|r")
          else
            local strz = {
              "|cFFBA6B33[刘焉-立牧]判定结果-梅花|r",
              "|cFFBA6B33[刘焉-立牧]判定结果-黑桃|r",
              "|cFFBA6B33[刘焉-立牧]判定结果-方片|r"
            }
            u:sendmessage(strz[GetRandomInt(1, #strz)])
            u:buffset(u.handle, 5, "眩晕")
            u:buffset(u.handle, 5, "缠绕")
          end
        end
      end)
      AddUISkill({
        text = "立牧",
        u = u,
        cd = 150,
        icon = "war3mapImported\\BTNEwl_Cq_Liuyan.tga",
        showtext = "|cFFBA6B33立牧|r\n|cFFFFB38E恢复25%生命值与体力值\n如果[图射]处于冷却则立刻刷新其冷却\n使用立牧后首次脱战时进行判定,75%使自己被眩晕且缠绕5秒\n冷却150秒|r",
        func = function(args)
          local u = args.u
          local sy = u.ownerid
          local yx
          if GetRandomInt(1, 2) == 1 then
            yx = Sound_Liuyan_03
            u:chat("|cFFBA6B33『今诸州纷乱，当立牧以定！』|r")
          else
            yx = Sound_Liuyan_04
            u:chat("|cFFBA6B33『此非为偏安一隅，但求一方百姓安宁！』|r")
          end
          u:playsound(yx)
          u:setdata("刘焉-乐不思蜀")
          u:curetili(0.25 * Hero_Tili_Max[sy])
          u:curehp(u.handle, 0, 25, 2)
          if u:hasdata("刘焉-特效失效") then
            u:setdata("刘焉-特效失效", 0)
          end
        end
      })
    end,
    effectname = "|cFFBA6B33刘|r|cFFFFB38E焉|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFBA6B33唯一 三国 天子气1|r\n|cFFBA6B33【图射】|r\n|cFFFFB38E直接伤害时98%(不享受幸运)附带[50000]物理伤害,冷却0.4秒\n触发成功时,提升1%伤害加成直到触发失败\n触发失败时,进入60秒冷却|r\n|cFFBA6B33【立牧】|r\n|cFFFFB38E获得拓展技能[立牧]|r",
    effectart = "war3mapImported\\BTNEwl_Cq_Liuyan"
  },
  {
    name = "威吕布",
    weight = 100,
    lv = 2,
    key = {"三国"},
    unique = false,
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
      ciyuanget(u, var)
      u:chat("|cFFB86147『颅献白骨观，血祭黄沙场！』|r")
      PlayGlobalSound(Sound_Sgs_Weilvbu_Get)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          local dis = DistanceBetweenUnits(tg.handle, u.handle)
          if dis <= 600 then
            if not u:hasdata("系统-清净模式") then
              if GetRandomInt(1, 2) == 1 then
                u:chat("|cFFB86147『烽烟既起，吾当独擎沙场！』|r")
                u:playseensound(Sound_Sgs_Weilvbu_01)
              else
                u:chat("|cFFB86147『百战生豪意，一戟破万军！』|r")
                u:playseensound(Sound_Sgs_Weilvbu_02)
              end
            end
            u:settimedata(var.name .. "-特效冷却", 2)
            u:changedata("威吕布-伤害加成", 0.05)
            ChangeValue(DamageSystem_Shjc, sy, 0.05)
            u:sendmessage("|cFFBA6B33[威吕布]骁武 当前加成:" .. math.floor(u:getdata("威吕布-伤害加成") * 100) .. "%")
          end
        end
      end)
      u:addstexiao(var.name, "受伤后效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if args.damage > 0 and not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 30)
          ChangeValue(DamageSystem_Shjc, sy, -u:getdata("威吕布-伤害加成"))
          u:setdata("威吕布-伤害加成", 0)
          u:sendmessage("|cFFBA6B33[威吕布]骁武进入冷却")
        end
      end)
    end,
    effectname = "|cFFBA6B33威吕布|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFBA6B33三国 战士|r\n|cFFBA6B33【骁武】|r\n|cFFB86147直接伤害600范围内单位时提升5%伤害加成直到下一次受伤,冷却2秒\n失去加成时进入冷却30秒|r",
    effectart = "Mwx_Sgs_Cy_Weilvbu"
  }
}
Vars_Ciyuan_Lv3 = {
  {
    name = "崔悲伤",
    weight = 2500,
    lv = 3,
    key = {"唯一", "战士"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = u:getdata("遗物-悲伤雕像数量") >= 1
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Cbs_01)
      ChatIcon[sy] = "Chat_Cbs.tga"
      u:chat("让我们开始吧，悲伤的歌曲")
      u:addskill("S0E2")
      local moon = 0
      local crit = 0
      local finish = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * (-moon - finish))
        ChangeValue(DamageSystem_Baoji, sy, -crit)
        local moon_count = u:getdata("遗物数量-月面")
        local statue_count = u:getdata("遗物-悲伤雕像数量")
        moon = moon_count * 0.1
        crit = statue_count * 5
        finish = statue_count * 0.1
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * (moon + finish))
        ChangeValue(DamageSystem_Baoji, sy, crit)
      end)
      u:addstexiao(var.name, "被施加Buff时效果-僵直", function(args)
        if not u:hasdata(var.name .. "-高声颂爱冷却") then
          u:settimedata(var.name .. "-高声颂爱冷却", 6)
          args.time = 0
          u:clearbuff("僵直")
          u:curehp(u.handle, 0, 10, 2)
        end
      end)
      u:addstexiao(var.name, "被施加Buff时效果-缠绕", function(args)
        if not u:hasdata(var.name .. "-高声颂爱冷却") then
          u:settimedata(var.name .. "-高声颂爱冷却", 6)
          args.time = 0
          u:clearbuff("缠绕")
          u:curehp(u.handle, 0, 10, 2)
        end
      end)
      local teammates = {}
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq.handle ~= u.handle and not xq:hasdata("属性-王") then
          teammates[#teammates + 1] = xq
        end
      end)
      if 0 < #teammates then
        teammates[GetRandomInt(1, #teammates)]:become("王")
      end
      local kings = {}
      ac.loop(3000, function()
        ForGroupLuaNew(Group_PlayHero, function(xq)
          local sy2 = xq.ownerid
          if xq:hasdata("属性-王") and not kings[sy2] then
            kings[sy2] = true
            ChangeValue(DamageSystem_Baoshang, sy2, 1)
            ChangeValue(DamageSystem_Shjc, sy2, 0.2)
          end
        end)
      end)
    end,
    effectname = "|cFF8B0000崔|r|cFFC57F7F悲|r|cFFCCCCCC伤|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF8B0000唯一 战士|r\n|cFF8B0000【悲伤之子】|r\n|cFFCCCCCC提升100%移速\n每使用一个遗物提升1%伤害加成\n每拥有一个月面遗物提升1%终结伤害\n每拥有一个悲伤雕像提升5%暴击率与10%终结伤害|r\n|cFF8B0000【高声颂爱】|r\n|cFFCCCCCC被施加僵直或缠绕时立刻解除并立刻恢复10%生命值,冷却6秒|r\n|cFF8B0000【王不懂人心】|r\n|cFFCCCCCC获取时随机给予一个未拥有[王]特性的队友[王]特性(不包括自己)\n拥有[王]特性的玩家提升100%爆伤与20%伤害加成|r",
    effectart = "Cq_Cbs"
  },
  {
    name = "巨魔战将",
    weight = 1000,
    lv = 3,
    key = {"兽", "战士"},
    condition = function(u)
      return u:hasdata("血统判定-狂战士之血") or u:isinmaxvar("兽")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:changearmor(25)
      u:addskill("S0E3")
      u:changedata("效果增强-背水", 0.25)
      local fervor_target
      local fervor_stacks = 0
      local high_ancestor_active = false
      
      local function set_high_ancestor_active(active)
        if active == high_ancestor_active then
          return
        end
        high_ancestor_active = active
        u:changedata("效果增强-背水", active and 1 or -1)
      end
      
      local function advance_to_lou()
        if u:hasdata("变异判定-Lou") or Weiyi_New[27] then
          return false
        end
        Weiyi_New[27] = true
        u:setdata("变异判定-Lou")
        u:changedata("唯一变异数量", 1)
        u:changearmor(15)
        u:changedata("效果增强-背水", 0.15)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (0.1 * fervor_stacks))
        if 10 <= fervor_stacks then
          set_high_ancestor_active(true)
        end
        u:uivar_change({
          keyname = var.name,
          keytype = "传奇栏",
          icon = "Cq_Jumozhanjiang_Lou.tga",
          text = "|cFFFF9C1BL|r|cFFFFC266o|r|cFFFFFFFFu|r\n|cFFFF9C1B兽 战士 唯一|r\n|cFFFF9C1B【热血战魂】|r\n|cFFFFE6CC直接伤害时同一个单位时提升4%伤害加成,最大10层|r\n|cFFFF9C1B【狂战士之怒】|r\n|cFFFFE6CC提升25%移速\n提升40护甲\n提升40%背水效果|r\n|cFFFF9C1B【旋风飞斧】|r\n|cFFFFE6CC直接伤害时2%投掷飞斧造成一直线1秒僵直与100000伤害,冷却0.5秒|r\n|cFFFF9C1B【战斗专注】|r\n|cFFFFE6CC解锁额外技能[战斗专注]|r\n|cFFFF9C1B【高祖望龙】|r\n|cFFFFE6CC[热血战魂]叠加10层时:\n[提升100%背水效果\n旋风飞斧触发概率提升至10%]|r\n|cFF888888大丈夫当如是也|r"
        })
        u:sendmessage("|cFFFF9C1B[巨魔战将]进阶为[Lou]|r")
        return true
      end
      
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local info = args.damageinfo
        if info.isvestdamage then
          return
        end
        if fervor_target == tg.handle then
          if fervor_stacks < 10 then
            fervor_stacks = fervor_stacks + 1
            if u:hasdata("变异判定-Lou") then
              ChangeValue(DamageSystem_Shjc, sy, 0.04)
              if fervor_stacks == 10 then
                set_high_ancestor_active(true)
              end
            else
              ChangeValue(DamageSystem_Shjc, sy, 0.03)
            end
          end
        else
          set_high_ancestor_active(false)
          if 0 < fervor_stacks then
            local stack_bonus = u:hasdata("变异判定-Lou") and 0.4 or 0.3
            ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-stack_bonus * fervor_stacks))
          end
          fervor_target = tg.handle
          fervor_stacks = 0
        end
        local is_lou = u:hasdata("变异判定-Lou")
        local axe_chance = is_lou and 10 <= fervor_stacks and 10 or 2
        if not u:hasdata(var.name .. "-旋风飞斧冷却") and u:getluckrandom(axe_chance * info.txgl) then
          u:settimedata(var.name .. "-旋风飞斧冷却", is_lou and 0.5 or 1)
          local x, y = u:getxy()
          local x2, y2 = tg:getxy()
          unifycreate({
            owner = u.handle,
            model = "Abilities\\Weapons\\BatTrollMissile\\BatTrollMissile.mdl",
            modelname = "巨魔战将-旋风飞斧",
            modelsize = 1.5,
            height = 80,
            damage = is_lou and 100000 or 10000,
            damagetype = 1,
            x = x,
            y = y,
            range = 2000,
            time = 0.5,
            volume = 125,
            angle = AngleXY(x, y, x2, y2),
            attenua = 1,
            attenuacount = 999,
            life = 10,
            isbullet = false,
            isvest = true,
            isnoarmor = false,
            hitafterfunc = function(mj, xq)
              xq:buffset(u.handle, 1, "僵直")
            end
          })
        end
      end)
      AddUISkill({
        text = "战斗专注",
        u = u,
        cd = 70,
        icon = "Cq_Jumozhanjiang_Zdzz.tga",
        showtext = "|cFFFF9C1B战斗专注|r\n|cFFFFE6CC立刻解除自身负面状态并在6.5秒内死亡抗拒\n冷却70秒|r",
        func = function(args)
          local u = args.u
          local advanced_now = false
          u:playsound(Sound_Jmzj_Lou)
          if u:hasdata("变异判定-Lou") then
            u:playsound(Sound_Jmzj_Lou2)
            ac.wait(2900, function()
              u:playsound(Sound_Jmzj_Lou3)
            end)
          else
            local advance_chance = 1 + 0.05 * u:getmissperhp()
            if not Weiyi_New[27] and GetRandom100(advance_chance) then
              advanced_now = advance_to_lou()
              if advanced_now then
                u:playsound(Sound_Jmzj_Lou2)
                ac.wait(2900, function()
                  u:playsound(Sound_Jmzj_Lou3)
                end)
              end
            end
          end
          local duration = advanced_now and 9.5 or 6.5
          u:clearbuff()
          local negative_states = {
            "冰冻",
            "缠绕",
            "沉默",
            "混乱",
            "僵直",
            "麻痹",
            "燃烧",
            "石化",
            "睡眠",
            "眩晕"
          }
          for _, state in ipairs(negative_states) do
            u:clearbuff(state)
          end
          u:settimedata("巨魔战将-死亡抗拒", duration)
          u:setcolor(80, 140, 255)
          BuffUI.apply({
            id = "战斗专注",
            duration = duration,
            u = u
          })
          ac.wait(duration * 1000, function()
            u:setcolor(255, 255, 255)
          end)
        end
      })
    end,
    effectname = "|cFFFF9C1B巨|r|cFFFFC266魔|r|cFFFFE6CC蘸|r|cFFFFFFFF酱|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFFF9C1B兽 战士|r\n|cFFFF9C1B【热血战魂】|r\n|cFFFFE6CC连续对同一个单位造成直接伤害时提升3%伤害加成,最大10层\n对其他单位造成直接伤害时立刻重置层数|r\n|cFFFF9C1B【狂战士之怒】|r\n|cFFFFE6CC提升25护甲\n提升25%移速\n提升25%背水效果|r\n|cFFFF9C1B【旋风飞斧】|r\n|cFFFFE6CC直接伤害时有2%概率投掷飞斧,对一直线上的敌人造成10000物理伤害与1秒僵直\n冷却1秒|r\n|cFFFF9C1B【战斗专注】|r\n|cFFFFE6CC解锁额外技能[战斗专注]|r",
    effectart = "Cq_Jumozhanjiang.tga"
  },
  {
    name = "美狄亚Lily",
    clickfunc = function(u, var)
      if u:hasdata("变异判定-美狄亚Lily神化") then
        u:sendmessage("|cFFCCB2FF已经完成神化|r")
        return
      end
      if not u:isalive() then
        u:sendmessage("|cFFCCB2FF死亡状态无法神化|r")
        return
      end
      if u:getdata("女神力") < 9 then
        u:sendmessage("|cFFCCB2FF女神力不足9点|r")
        return
      end
      if not u:ishasshw() then
        u:sendmessage("|cFFCCB2FF神化位不足|r")
        return
      end
      AdvanceGet["美狄亚Lily神化"](u)
    end,
    weight = 0,
    key = {
      "唯一",
      "魔导",
      "同奏"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I09F") then
        add = add + 2500
      end
      return add
    end,
    condition = function(u)
      if not u:ishasitem("I09F") then
        return false
      end
      return true
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("Servant，Caster，美狄亚……那个，还请多多指教！")
      PlayGlobalSound(Sound_Meidiya_04)
      local g = CreateGroupLua()
      u:become("从者")
      u:adddivinity(1)
      u:getgoddessforce(2)
      ChangeValue(Correction_Magic, sy, 0.010000000000000002)
      for i = 1, 6 do
        ChangeValue(DamageSystem_Shjc, i, 0.05)
      end
      local cs = 0
      ac.loop(3000, function()
        cs = cs + 1
        if 20 <= cs then
          cs = 0
          if u:isalive() then
            u:effectadd("ATX\\[ATxNew]Colour_05.mdl")
            u:effectadd("ATX\\[ATxNew]Magic_41.mdl")
            u:sendmessage("|cFF6699FF[科尔基斯的公主]友好的魔女")
            if GetRandom100(33) then
              if GetRandom100(50) then
                u:playsound(Sound_Meidiya_02)
              else
                u:playsound(Sound_Meidiya_01)
              end
            end
            ForGroupLuaNew(Group_PlayHero, function(xq)
              if u:hasdata("变异判定-美狄亚Lily神化") then
                xq:changekyx(-3)
              else
                xq:changekyx(-2)
              end
            end)
          end
        end
      end)
    end,
    effectname = "|cFF9966FF科尔|r|cFFB28CFF基斯的|r|cFFCCB2FF公主|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF9966FF神性1 女神力2\n唯一 魔导 同奏|r\n|cFFCCB2FF提升10%法术修正|r\n|cFF9966FF【友好的魔女】|r\n|cFFCCB2FF提升全队5%伤害加成\n每60秒降低全队2%抗药性|r\n|cFF9966FF【泡影之恋】|r\n|cFFCCB2FF女神力达到9时[左键]神化|r",
    effectart = "war3mapImported\\BTNEwl_Shenhua_MeidiyaLily.blp"
  },
  {
    name = "露西",
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "光明",
      "战士",
      "灵魂"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      ChangeValue(Correction_Jzsh, sy, 0.15)
      ChangeValue(Correction_Exp, sy, 0.2)
      u:setdata("露西-方舟剑圣加成", 0)
      local add = 0
      ac.loop(3000, function()
        add = 0.05 * u:getdata("系统-累积等级")
        u:setdata("露西-方舟剑圣加成", add)
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        if GetRandom100(50) then
          ChangeValue(DamageSystem_Shjc, sy, 1.0E-4)
        else
          ChangeValue(Correction_Jzsh, sy, 1.0E-4)
        end
      end)
      u:addstexiao(var.name, "位移技能后效果", function(args)
        if not u:hasdata("露西-位移效果冷却" .. args.jw) then
          u:settimedata("露西-位移效果冷却" .. args.jw, 3)
          local g = CreateGroupLua()
          local x, y = u:getxy()
          for _, xq in ac.selector():in_rangexy(x, y, 1000):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:groupadd(g)
          end
          if Group_Counts(g) > 0 then
            local tg = Group_Randomunit(g)
            local txsh = 1500 * u:getlevel()
            DamageUnit({
              bj = "[露西]放风筝",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "物理",
              isvest = false,
              isattack = true,
              isnoarmor = false,
              element = "无"
            })
            tg:buffset(u.handle, 0.5, "僵直")
          end
        end
      end)
      u:addstexiao(var.name, "近战伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata("露西-迅捷位移冷却") then
          u:settimedata("露西-迅捷位移冷却", 15)
          u:playseensound(Sound_Luxi_01)
          local wq = getunit(System_ZbBeibao[sy]):getcountitem(1)
          local wqlx = Hero_Equip_WeaponType[sy]
          local skill = GetData(wqlx, "绑定技能")
          ac.timer(100, 4, function()
            local add = 2000 * u:getlevel()
            local x, y = u:getxy()
            u:changedata("近战机体-基础伤害提升", add)
            weaponuse(u.handle, skill, x, y)
            u:changedata("近战机体-基础伤害提升", -add)
          end)
        end
      end)
    end,
    effectname = "|cFFF0B953露|r|cFFEFA9C5西|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFF0B953唯一 光明 战士 灵魂|r\n|cFFEFA9C5提升15%近战伤害\n提升20%经验获取|r\n|cFFF0B953【方舟剑圣】|r\n|cFFEFA9C5提升[5%*累积等级]剑类武器基础伤害\n杀敌时提升0.01%近战伤害或0.01%伤害加成|r\n|cFFF0B953【放风筝】|r\n|cFFEFA9C5使用基础位移技能时,对1000范围内随机一个敌人造成[等级*1500]近战物理伤害并僵直0.5秒\n冷却3秒(每个按键的基础位移技能冷却独立)|r\n|cFFF0B953【迅捷位移】|r\n|cFFEFA9C5造成近战伤害时,立刻释放4次(间隔0.1秒)基础伤害提升[等级*2000]的近战武器\n冷却15秒|r",
    effectart = "Cq_Luxi_01.tga",
    test = "    "
  },
  {
    name = "雷克西斯",
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "黑暗",
      "兽"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      local g = CreateGroupLua()
      ac.loop(1000, function()
        if u:hasdata("雷克西斯-分析解锁") and u:isalive() then
          local ax, ay = u:getxy()
          for _, xq in ac.selector():in_rangexy(ax, ay, 1200):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            if not xq:hasdata("雷克西斯-分析完毕") then
              xq:changedata("雷克西斯-分析时间", 1)
              local dtime = 3
              if xq:isboss() then
                dtime = 30
              end
              if dtime <= xq:getdata("雷克西斯-分析时间") then
                xq:setdata("雷克西斯-分析完毕")
              end
            end
          end
        end
        ForGroupLuaNew(g, function(xq)
          if xq:isboss() then
            LossHpUnit({
              u = u,
              tg = xq,
              damage = 0,
              perhp = 0.4,
              maxhp = 0,
              bj = "[生命损耗]内脏切除"
            })
          else
            LossHpUnit({
              u = u,
              tg = xq,
              damage = 0,
              perhp = 5,
              maxhp = 0,
              bj = "[生命损耗]内脏切除"
            })
          end
        end)
      end)
      u:addstexiao(var.name, "暴击系统计算效果", function(args)
        local tg = args.tg
        local info = args.damageinfo
        if tg:hasdata("雷克西斯-分析完毕") then
          info.bjl = (info.bjl or 0) + 10
        end
      end)
      u:addstexiao(var.name, "怪物减伤计算", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if tg:hasdata("雷克西斯-分析完毕") then
          info.ewss = info.ewss + 0.3
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("雷克西斯-祈祷") and not tg:hasdata("雷克西斯-内脏切除") then
          tg:setdata("雷克西斯-内脏切除")
          tg:groupadd(g)
          if tg:isboss() then
            u:playseensound(Sound_Leikexisi_01)
            tg:effectadd("war3mapImported\\texiao_xuebao.mdx")
          end
        end
      end)
      u:addstexiao(var.name, "近战伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not tg:hasdata(var.name .. "-特效冷却") and u:getluckrandom(info.txgl * 10) then
          tg:settimedata(var.name .. "-特效冷却", 1)
          local txsh = 5000 * u:getdata("系统-累积等级")
          DamageUnit({
            bj = "雷克西斯-神经切断",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
          if not tg:hasdata(var.name .. "-特效2冷却") then
            tg:settimedata(var.name .. "-特效2冷却", 10)
            tg:buffset(u.handle, 3, "僵直")
            tg:buffset(u.handle, 3, "破坏-伤害抗性")
          end
        end
      end)
      u:addstexiao(var.name, "子弹伤害后效果", function(args)
        local tg = args.tg
        local u = args.u
        if not tg:hasdata(var.name .. "-子弹名字") then
          tg:setdata(var.name .. "-子弹名字")
          tg:buffset(u.handle, 3, "眩晕")
        end
      end)
      ac.loop(10000, function(timer)
        if u:isalive() then
          local jl = 11
          if GetRandom100(jl) or u:getdata("魔君兴奋剂持续时间") > 0 then
            u:sendmessage("|cFF6F8593[雷克西斯]祈祷|r")
            u:setdata("雷克西斯-祈祷")
            ac.wait(9900, function()
              u:deldata("雷克西斯-祈祷")
              u:sendmessage("|cFF6F8593[雷克西斯]祈祷结束|r")
            end)
          end
        end
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        if not u:hasdata("雷克西斯-分析解锁") and tg:isboss() then
          u:setdata("雷克西斯-分析解锁")
          u:sendmessage("|cFF6F8593[雷克西斯]结构分析解锁|r")
        end
      end)
    end,
    effectname = "|cFF6F8593雷|r|cFF92AAB7克|r|cFFB4D0DB西|r|cFFD7F5FF斯|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF6F8593唯一 黑暗 兽|r\n|cFF6F8593【神经切断&破阵】|r\n|cFFD7F5FF近战伤害10%附带[5000*累积等级]物理伤害,独立冷却1秒\n触发时僵直目标并破坏抗性3秒,独立冷却10秒|r\n|cFF6F8593【枪械射击】|r\n|cFFD7F5FF造成枪械伤害时眩晕目标3秒,每个单位只触发一次|r\n|cFF6F8593【祈祷&内脏切除】|r\n|cFFD7F5FF每10秒11%进入[祈祷]10秒,持续期间:\n[直接伤害时施加[内脏切除]永续负面状态(每秒损耗5%(0.4%)当前生命值)]|r\n|cFF6F8593【齿间秘药】|r\n|cFFD7F5FF死亡时清空魔力并复活,冷却600秒|r\n|cFF6F8593【结构分析(击杀BOSS时解锁)】|r\n|cFFD7F5FF分析进入自身周围1200范围内敌人,累积3秒后分析完毕(BOSS为30秒)\n对分析完毕的敌人提升10%暴击率,仅伤害时使其提升30%额外受伤|r",
    effectart = "Cq_Lkxs_01.tga",
    test = "    "
  },
  {
    name = "莲太",
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "外域",
      "星",
      "风",
      "根源"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("变异判定-八坂真寻") then
        add = add + 300
      end
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("变异判定-宇宙联合行星保护机构") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("|cFFFFFF00我叫八坂哈斯塔")
      u:chat("|cFFFFFF00请叫我莲太就好", 1.4)
      PlayGlobalSound(Sound_Liantai_01)
      u:adddivinity(1)
      local ewys = 0
      local sxsh = 0
      local endsh = 0
      ac.loop(3000, function()
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -ewys)
        ChangeValue(Damage_Element_All, sy, -sxsh)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * -endsh)
        ewys = 2 * u:getdata("元素变异数量")
        sxsh = 0.01 * u:getdata("元素变异数量")
        endsh = 0.0025 * u:getstate("外域变异")
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, ewys)
        ChangeValue(Damage_Element_All, sy, sxsh)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * endsh)
      end)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:hasbuff("混乱") then
          info.end3 = info.end3 + 0.09
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        local txsh = u:getlevel() * 2500
        if u:getluckrandom(info.txgl * 10) and not u:hasdata(var.name .. "-特效1冷却") then
          u:settimedata(var.name .. "-特效1冷却", 1)
          DamageUnit({
            bj = "莲太(大气操控)",
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
        if u:getluckrandom(info.txgl * 10) and not u:hasdata(var.name .. "-特效2冷却") then
          u:settimedata(var.name .. "-特效2冷却", 1)
          DamageUnit({
            bj = "莲太(大气操控)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "雷"
          })
        end
        if u:getluckrandom(info.txgl * 10) and not u:hasdata(var.name .. "-特效3冷却") then
          u:settimedata(var.name .. "-特效3冷却", 1)
          DamageUnit({
            bj = "莲太(大气操控)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "冰"
          })
        end
        if u:getluckrandom(info.txgl * 10) and not u:hasdata(var.name .. "-特效4冷却") then
          u:settimedata(var.name .. "-特效4冷却", 1)
          DamageUnit({
            bj = "莲太(大气操控)",
            unit = tg.handle,
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
        if u:getluckrandom(info.txgl * 10) and not u:hasdata(var.name .. "-特效5冷却") then
          u:settimedata(var.name .. "-特效5冷却", 1)
          DamageUnit({
            bj = "莲太(大气操控)",
            unit = tg.handle,
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
      end)
    end,
    effectname = "|cFFFFFF00莲|r|cFFB7EDFF太|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFFFFF00神性 1\n唯一 外域 星 风 根源|r\n|cFFFFFF00【大气操控】|r\n|cFFB7EDFF提升[元素变异*2]额外移速\n提升[元素变异*1%]全属性伤害\n直接伤害时10%附带[等级*2500]随机属性魔力伤害(风,雷,冰,土,火)\n特效冷却1秒(每种属性冷却独立)|r\n|cFFFFFF00【黄衣之印】|r\n|cFFB7EDFF免疫混乱失控\n对混乱单位提升9%伤害\n提升[外域变异*0.025%]终结伤害|r",
    effectart = "Cq_Yzlh_Liantai.tga",
    test = "    "
  },
  {
    name = "克子",
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "外域",
      "星",
      "炎",
      "根源",
      "百合"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("变异判定-八坂真寻") then
        add = add + 300
      end
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("变异判定-宇宙联合行星保护机构") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("|cFFFF0000奈亚子是我的")
      u:chat("|cFFFF0000绝不会让你和少年双宿双飞", 2.3)
      PlayGlobalSound(Sound_Kezi_01)
      u:adddivinity(1)
      ChangeValue(Damage_Element_Fire, sy, 0.1)
      local jz = 0
      local jc = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jc)
        ChangeValue(Correction_Jzsh, sy, 0.1 * -jz)
        jc = 0.1 * u:getstate("炎变异")
        jz = 0.05 * u:getstate("外域变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * jc)
        ChangeValue(Correction_Jzsh, sy, 0.1 * jz)
      end)
      u:addstexiao(var.name, "近战伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if info.element == "无" then
          info.element = "火"
        end
        if info.element == "火" and not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(info.txgl * 5) then
          local time = 4
          if u:hasdata("克子-交叉炽焰") then
            time = 1
          end
          u:settimedata(var.name .. "-特效冷却", time)
          local txsh = 10000 + 10000 * u:getstate("炎变异")
          local x2, y2 = tg:getxy()
          for _, xq in ac.selector():in_rangexy(x2, y2, 275):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "克子-宇宙CQC神焰",
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
      end)
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("克子-交叉炽焰") then
          info.wsmy = true
        end
      end)
      local dskill
      if u:ishasskill("A1AM") and u.type ~= HeroType["C呆"] and u.type ~= HeroType["莲华"] then
        dskill = "S0D4"
      else
        dskill = "S0D3"
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
              u:playseensound(Sound_Kezi_02)
              
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local angle = AngleXY(x, y, x2, y2)
              local dis = DistanceXY(x, y, x2, y2)
              u:setxy(x2, y2)
              Effectcreate("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl", x, y, 0, 10)
              Effectcreate("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl", x2, y2, 0, 10)
              for _, xq in ac.selector():in_rangexy(x, y, 900):ipairs() do
                xq = getunit(xq)
                if xq ~= u then
                  xq:buffset(u.handle, 3, "眩晕")
                  local ax, ay = xq:getxy()
                  ax, ay = PolarXY(ax, ay, dis, angle)
                  xq:setxy(ax, ay)
                end
              end
              u:settimedata("克子-交叉炽焰", 8)
              local add = 0.05 * u:getstate("炎变异")
              ChangeTimeValue(Damage_Element_Fire, sy, add, 8)
              ChangeTimeValue(HeroMenu_HpForever_MaxHp, sy, 1, 8)
            end
          end
          
          u:addtrgevent("单位-发动技能", function(args)
            skill(args)
          end)
        end
      })
    end,
    effectname = "|cFFFF0000克|r|cFFF88607子|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFFF0000神性 1\n唯一 外域 星 炎 根源 百合|r\n|cFFFF0000【宇宙CQC神焰】|r\n|cFFF88607提升10%火属性伤害\n近战无属性伤害转换为火属性\n近战火属性伤害5%附带275范围[10000+10000*炎变异]魔力炎伤害,冷却4秒|r\n|cFFFF0000【无式百式】|r\n|cFFF88607提升[1%*炎变异]伤害加成\n提升[0.5%*外域变异]近战伤害|r\n|cFFFF0000【交叉炽焰机制】|r\n|cFFF88607火把技能变为[交叉炽焰]|r",
    effectart = "Cq_Yzlh_Kezi.tga",
    test = "    "
  },
  {
    name = "奈亚子",
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "外域",
      "星",
      "恶魔",
      "根源"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("变异判定-八坂真寻") then
        add = add + 300
      end
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("变异判定-宇宙联合行星保护机构") or u:hasdata("隐藏职业-无貌之人") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      coopjudge("CQC超人", u)
      PlayBGM({
        bgm = 0,
        time = 104,
        ID = 247,
        unit = u.handle
      })
      u:chat("|cFFC3C0B9我是始终面带微笑潜行到你身边的混沌")
      u:chat("|cFFC3C0B9奈亚拉托提普desu~", 4.1)
      PlayGlobalSound(Sound_Naiyazi_01)
      ac.wait(8500, function()
        PlayGlobalSound(BGM_Naiyaizi_01)
        songtext({
          text = {
            {
              starttime = 0,
              str = "我来我来撸 又来又来呀"
            },
            {
              starttime = 1.6,
              str = "世界已完蛋 搞基！"
            },
            {
              starttime = 3.4,
              str = "呜-！喵-！呜-！喵-！"
            },
            {
              starttime = 6.6,
              str = "呜-！喵-！Let’s喵-！"
            },
            {
              starttime = 10.3,
              str = "可口可乐 努努露露 一库哟 卡密干me"
            },
            {
              starttime = 13.7,
              str = "窝她吸魔 阿玛塔的可爱在摸螺丝钉"
            },
            {
              starttime = 17.1,
              str = "卡卡西姆鲁姆鲁 一库哟你累了吧？"
            },
            {
              starttime = 20.4,
              str = "窝她吸托 阿娜塔哇 沿天下得我得拖"
            },
            {
              starttime = 23.5,
              str = "她弄湿一脸 呀！GAY佬脱你就走"
            },
            {
              starttime = 28.4,
              str = "一起摸臣乃~!"
            },
            {
              starttime = 30.2,
              str = "木骷髅 喜呀喜呀 送了德玛一血得死"
            },
            {
              starttime = 33.6,
              str = "玩她膝 医技棒 后溪哟奶汹涌"
            },
            {
              starttime = 37.0,
              str = "400大码 拔牙拔牙 送了德玛一血得秀"
            },
            {
              starttime = 40.5,
              str = "玩她膝 医技棒 你要看她胡舅握力"
            },
            {
              starttime = 43.8,
              str = "尴尬腻腻哇 铛铛 dora多"
            },
            {
              starttime = 47,
              str = "五指弄那姨 多兰刀 雅达雅达"
            },
            {
              starttime = 50.4,
              str = "优酷薄多袜 氪多哇 你虚嘛酷架"
            },
            {
              starttime = 54.1,
              str = "呜——！厚啦——喵——！可以恰无得修？Let’s喵！"
            },
            {
              starttime = 57,
              str = "太阳バカ 抹布洗五天"
            },
            {
              starttime = 60.4,
              str = "要命的后宫无限大~！dokidoki！"
            },
            {
              starttime = 63.5,
              str = "太阳バカ 抹布洗五天"
            },
            {
              starttime = 67.0,
              str = "要命的后宫谁的基~娘哒~？"
            },
            {
              starttime = 70.5,
              str = "GAY佬！GAY佬！台湾的GAY佬！"
            },
            {
              starttime = 73.8,
              str = "我没游广东 不够GAY 哇库哇库！"
            },
            {
              starttime = 77.3,
              str = "GAY佬！GAY佬！福建的GAY佬！"
            },
            {
              starttime = 80.9,
              str = "我没游云南不算基 娘哒~？"
            },
            {
              starttime = 83.7,
              str = "我来我来撸 又来又来呀"
            },
            {
              starttime = 85.4,
              str = "世界已完蛋（万事灵~！）"
            },
            {
              starttime = 86.9,
              str = "呜-！喵-！呜-！喵-！"
            },
            {
              starttime = 90.1,
              str = "呜-！喵-！Let’s喵-！",
              time = 4.3
            }
          },
          isjbcolor = true,
          color = {
            "FFFF3737",
            "FFFFE138",
            "FFFFE138",
            "FFFF3737"
          }
        })
      end)
      u:adddivinity(1)
      ChangeValue(DamageSystem_Shjc, sy, 0.025)
      ChangeValue(Correction_Jzsh, sy, 0.025)
      u:additem("I00O")
      ChangeValue(DamageSystem_Baoji, sy, 10)
      ChangeValue(DamageSystem_Baoshang, sy, 0.15)
      ChangeValue(DamageSystem_EndSh, sy, 0.003)
      ChangeValue(Damage_Touzhiwu, sy, 1)
      u:addstexiao(var.name, "近战伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 1)
          local txsh = 10000 + 2500 * u:getstate("外域变异")
          if u:hasdata("奈亚子-强化") then
            txsh = txsh * 2
          end
          DamageUnit({
            bj = "奈亚子-宇宙CQC",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
        end
      end)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:hasbuff("混乱") then
          if u:hasdata("奈亚子-强化") then
            info.end3 = info.end3 + 0.16
          else
            info.end3 = info.end3 + 0.08
          end
        end
      end)
      AddUISkill({
        text = "四次元裙",
        u = u,
        cd = 30,
        icon = "Cq_Yzlh_Naiyazi_Skill.tga",
        showtext = "|cffb9b9b9四次元裙\n获得一组投掷物或一个武器箱\n冷却30秒|r",
        func = function(args)
          local u = args.u
          local sy = u.ownerid
          local wpz = {
            "I008",
            "I009",
            "I00N"
          }
          u:additem(wpz[GetRandomInt(1, #wpz)])
          local yxz = {
            Sound_Naiyazi_02,
            Sound_Naiyazi_03
          }
          u:playsound(yxz[GetRandomInt(1, #yxz)])
        end
      })
      if u:hasdata("隐藏职业-无貌之人") then
        u:setdata("奈亚子-强化")
        u:adddivinity(1)
        ChangeValue(DamageSystem_Shjc, sy, 0.025)
        ChangeValue(Correction_Jzsh, sy, 0.025)
        ChangeValue(DamageSystem_Baoji, sy, 10)
        ChangeValue(DamageSystem_Baoshang, sy, 0.15)
        ChangeValue(DamageSystem_EndSh, sy, 0.003)
        ChangeValue(Damage_Touzhiwu, sy, 1)
        ac.wait(100, function()
          u:uivar_change({
            keyname = "奈亚子",
            keytype = "传奇栏",
            text = "|cFFC3C0B9奈|r|cFF62C4AC亚|r|cFF00C89F子|r\n|cFFFFAA00[传奇]|r\n|cFFC3C0B9神性 2\n唯一 外域 星 恶魔 根源|r\n|cFF00C89F提升5%伤害加成\n提升5%近战伤害|r\n|cFFC3C0B9【宇宙CQC】|r\n|cFF00C89F获得[撬棍]\n提升200%撬棍类武器伤害\n近战伤害附带[20000+5000*外域变异]物理伤害,冷却1秒|r\n|cFFC3C0B9【四次元裙】|r\n|cFF00C89F解锁技能[四次元裙]|r\n|cFFC3C0B9【邪神雷达】|r\n|cFF00C89F提升20%暴击率\n提升30%暴击伤害\n提升0.6%终结伤害|r\n|cFFC3C0B9【亵渎之手榴弹】|r\n|cFF00C89F提升200%投掷物伤害\n手榴弹爆炸使目标混乱1秒\n对混乱单位提升16%伤害|r",
            icon = "Cq_Yzlh_Naiyazi.tga"
          })
        end)
      end
    end,
    effectname = "|cFFC3C0B9奈|r|cFF62C4AC亚|r|cFF00C89F子|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFC3C0B9神性 1\n唯一 外域 星 恶魔 根源|r\n|cFF00C89F提升2.5%伤害加成\n提升2.5%近战伤害|r\n|cFFC3C0B9【宇宙CQC】|r\n|cFF00C89F获得[撬棍]\n提升100%撬棍类武器伤害\n近战伤害附带[10000+2500*外域变异]物理伤害,冷却1秒|r\n|cFFC3C0B9【四次元裙】|r\n|cFF00C89F解锁技能[四次元裙]|r\n|cFFC3C0B9【邪神雷达】|r\n|cFF00C89F提升10%暴击率\n提升15%暴击伤害\n提升0.3%终结伤害|r\n|cFFC3C0B9【亵渎之手榴弹】|r\n|cFF00C89F提升100%投掷物伤害\n手榴弹爆炸使目标混乱1秒\n对混乱单位提升8%伤害|r",
    effectart = "Cq_Yzlh_Naiyazi.tga",
    test = "    "
  },
  {
    name = "月下初拥",
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "吸血鬼",
      "战士",
      "德丽莎"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      add = add + 10 * u:getdata("德丽莎变异数量") + 10 * u:getdata("吸血鬼变异数量")
      if u:hasdata("变异判定-环都市") then
        add = add + 250
      end
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:getdata("德丽莎变异数量") >= 6 or u:getdata("吸血鬼变异数量") >= 3 then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Delisha_yuexia_01)
      u:chat("|cFFEC2935Teriteri~")
      u:chat("|cFFEC2935我是吸血猫德丽莎", 1.6)
      u:chat("|cFFEC2935喵~", 4.3)
      ChangeValue(DamageSystem_Baoji, sy, 12)
      ChangeValue(Damage_ElementRes_All, sy, 12)
      local jz = 0
      local bs = 0
      local add = 0
      local endsh = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Baoshang, sy, -bs)
        ChangeValue(Correction_Jzsh, sy, 0.1 * -jz)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * -endsh)
        local xs = u:getstate("德丽莎变异")
        local xs2 = u:getstate("吸血鬼变异")
        if u:hasdata("变异判定-大月下") then
          jz = 0.02 * xs + 0.01 * xs2
          bs = 0.015 * xs + 0.0075 * xs2
          add = 0.1 * xs + 0.05 * xs2
          endsh = 0.002 * xs + 0.001 * xs2
        else
          jz = 0.01 * xs
          bs = 0.01 * xs
          add = 0.05 * xs
          endsh = 0.001 * xs
        end
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * endsh)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        ChangeValue(DamageSystem_Baoshang, sy, bs)
        ChangeValue(Correction_Jzsh, sy, 0.1 * jz)
      end)
      u:addstexiao(var.name, "近战伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not info.isvestdamage then
          if u:getdata("月下初拥-不洁双刃计数") >= 4 then
            local txsh, bj
            if u:hasdata("变异判定-大月下") then
              txsh = 0.2 * (u:getstate("德丽莎变异") + u:getstate("吸血鬼变异")) * info.yssh
              tg:buffset(u.handle, 1, "流血")
              Buff_LiuxueQiangdu(u, tg, 1)
              bj = "月下誓约(逾越命运的告白)"
            else
              txsh = 0.1 * (u:getstate("德丽莎变异") + u:getstate("吸血鬼变异")) * info.yssh
              bj = "月下初拥(不洁双刃)"
            end
            u:setdata("月下初拥-不洁双刃计数", 0)
            DamageUnit({
              bj = bj,
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "物理",
              isvest = true,
              isattack = true,
              isnoarmor = false,
              element = "无"
            })
          else
            u:changedata("月下初拥-不洁双刃计数", 1)
          end
        end
      end)
      u:setdata("大月下-童话书概率", 5)
      u:addstexiao(var.name, "过波时效果", function(args)
        if not u:hasdata("大月下-童话书解锁") then
          if GetRandom100(u:getdata("大月下-童话书概率")) then
            u:sendmessage("|cFFE96077[月下初拥]已翻开未来的童话书")
            u:setdata("大月下-童话书解锁")
            u:uivar_change({
              keyname = "月下初拥",
              keytype = "传奇栏",
              text = "|cFFEC2935月|r|cFFE96077下|r|cFFE798B8初|r|cFFE4CFFA拥|r\n|cFFFFAA00[传奇]|r\n|cFFEC2935吸血鬼 德丽莎 战士 唯一|r\n|cFFEC2935【不洁双刃】|r\n|cFFE4CFFA提升[德丽莎变异*0.1%]近战伤害\n每造成4次近战直接伤害,附带一次[1%*(德丽莎变异+吸血鬼变异)*伤害值]近战物理伤害|r\n|cFFEC2935【无形梦魇】|r\n|cFFE4CFFA提升12%暴击率\n提升[德丽莎变异*1%]暴击伤害\n降低25%基础位移技能冷却|r\n|cFFEC2935【该隐之印】|r\n|cFFE4CFFA提升[德丽莎变异*0.5%]伤害加成\n提升[德丽莎变异*0.1%]终结伤害\n提升12%全属性抗性|r\n|cFFEC2935【未来的童话书】|r\n|cFFE4CFFA[左键]在满足以下条件时点击进阶(消耗神化位):\n[德丽莎变异数量≥55或吸血鬼变异数量≥18]|r",
              icon = "Cq_Delishayuexia_02.tga",
              clickfunc = function(u, var)
                local sy = u.ownerid
                if u:hasdata("变异判定-大月下") then
                  return
                end
                if not u:hasdata("大月下-童话书解锁") then
                  u:sendmessage("|cFFBBB3CA동화책이 해금되지 않았습니다. (현재 해금 확률 " .. tostring(u:getdata("大月下-童话书概率")) .. "%)|r")
                  return
                end
                if u:getdata("德丽莎变异数量") < 55 and u:getdata("吸血鬼变异数量") < 18 then
                  u:sendmessage("|cFFBBB3CA变异数量不足|r")
                  return
                end
                AdvanceGet["大月下"](u)
              end
            })
          else
            u:changedata("大月下-童话书概率", 5)
          end
        end
      end)
      ac.wait(100, function()
        u:uivar_change({
          keyname = "月下初拥",
          keytype = "传奇栏",
          text = "|cFFEC2935月|r|cFFE96077下|r|cFFE798B8初|r|cFFE4CFFA拥|r\n|cFFFFAA00[传奇]|r\n|cFFEC2935吸血鬼 德丽莎 战士 唯一|r\n|cFFEC2935【不洁双刃】|r\n|cFFE4CFFA提升[德丽莎变异*0.1%]近战伤害\n每造成4次近战直接伤害,附带一次[1%*(德丽莎变异+吸血鬼变异)*伤害值]近战物理伤害|r\n|cFFEC2935【无形梦魇】|r\n|cFFE4CFFA提升12%暴击率\n提升[德丽莎变异*1%]暴击伤害\n降低25%基础位移技能冷却|r\n|cFFEC2935【该隐之印】|r\n|cFFE4CFFA提升[德丽莎变异*0.5%]伤害加成\n提升[德丽莎变异*0.1%]终结伤害\n提升12%全属性抗性|r\n|cFFEC2935【未来的童话书】|r\n|cFFE4CFFA过波时5%解锁进阶可能,未满足则提升这个概率5%\n[左键]在满足以下条件时点击进阶(消耗神化位):\n[①已经翻开童话书\n②德丽莎变异数量≥55或吸血鬼变异数量≥18]|r",
          icon = "Cq_Delishayuexia_01.tga",
          clickfunc = function(u, var)
            local sy = u.ownerid
            if u:hasdata("变异判定-大月下") then
              return
            end
            if not u:hasdata("大月下-童话书解锁") then
              u:sendmessage("|cFFBBB3CA동화책이 해금되지 않았습니다. (현재 해금 확률 " .. tostring(u:getdata("大月下-童话书概率")) .. "%)|r")
              return
            end
            if u:getdata("德丽莎变异数量") < 55 and u:getdata("吸血鬼变异数量") < 18 then
              u:sendmessage("|cFFBBB3CA变异数量不足|r")
              return
            end
            AdvanceGet["大月下"](u)
          end
        })
      end)
    end,
    effectname = "|cFFEC2935月|r|cFFE96077下|r|cFFE798B8初|r|cFFE4CFFA拥|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFEC2935吸血鬼 德丽莎 战士 唯一|r\n|cFFEC2935【不洁双刃】|r\n|cFFE4CFFA提升[德丽莎变异*0.1%]近战伤害\n每造成4次近战直接伤害,附带一次[1%*(德丽莎变异+吸血鬼变异)*伤害值]近战物理伤害|r\n|cFFEC2935【无形梦魇】|r\n|cFFE4CFFA提升12%暴击率\n提升[德丽莎变异*1%]暴击伤害\n降低25%基础位移技能冷却|r\n|cFFEC2935【该隐之印】|r\n|cFFE4CFFA提升[德丽莎变异*0.5%]伤害加成\n提升[德丽莎变异*0.1%]终结伤害\n提升12%全属性抗性|r",
    effectart = "Cq_Delishayuexia_01.tga",
    test = "    "
  },
  {
    name = "储君",
    clickfunc = function(u, var)
      local count1 = u:getdata("储君-铸造值")
      u:sendmessage("|cFFFF8040[储君]铸造值:" .. count1 .. "|r")
      FlashUIVarGlobal(u, MWXSTR .. "杀戮尖塔")
    end,
    rightclickfunc = function(u, var)
      local sy = u.ownerid
      if u:hasdata("变异判定-星国储君") or Weiyi_New[24] then
        return
      end
      if not u:hasdata("储君-击杀BOSS判定") then
        u:sendmessage("|cFFFF8040未在满足条件的情况下击杀BOSS|r")
        return
      end
      AdvanceGet["星国储君"](u)
    end,
    weight = 1500,
    lv = 3,
    key = {"星"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("变异判定-杀戮尖塔") and not u:hasdata(var.name .. "-获取权重加成") then
        add = add + 1500
        u:setdata(var.name .. "-获取权重加成")
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("变异判定-杀戮尖塔") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("|cFFFF8040我进塔！")
      u:become("王")
      ac.wait(100, function()
        local dpools = {
          Vars_Mwx_Shalujianta_Chujun_Chushi
        }
        local str = herogetvar(u.handle, dpools, "冥王星", "打击")
        local str = herogetvar(u.handle, dpools, "冥王星", "防御")
        local str = herogetvar(u.handle, dpools, "冥王星", "陨星")
        local str = herogetvar(u.handle, dpools, "冥王星", "崇拜")
      end)
      local x, y = u:getxy()
      local wp = CreateItemLua("I0PG", x, y)
      SetData(wp, "所属玩家", u.owner)
      u:addspeitem(wp)
      local wp = CreateItemLua("I0PI", x, y)
      SetData(wp, "所属玩家", u.owner)
      u:addspeitem(wp)
      u:changedata("储君-铸造值", 10)
      u:changedata("效果增强-星", 0.15)
      local add = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        add = 0.15 * u:getstate("星变异")
        if u:hasdata("变异判定-星国储君") then
          add = add * 2
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        if u:getdata("星变异数量") >= 11 and tg:isboss() and not u:hasdata("储君-击杀BOSS判定") then
          u:sendmessage("|cFFFF8040[储君]满足击杀BOSS条件|r")
          u:setdata("储君-击杀BOSS判定")
        end
      end)
      u:addstexiao(var.name, "过波时效果", function(args)
        local x, y = u:getxy()
        local wp = CreateItemLua("I0PG", x, y)
        SetData(wp, "所属玩家", u.owner)
        u:addspeitem(wp)
        if u:hasdata("变异判定-星国储君") then
          u:addlevel(-1)
          u:addlevel(1)
        else
          for i = 1, 15 do
            u:addexp(200)
          end
        end
      end)
    end,
    effectname = "|cFFFF8040储|r|cFFD8A575君|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFFF8040星|r\n|cFFFF8040【天赋君权】|r\n|cFFD8A575过波时获得3000经验值\n提升[1.5%*星变异]伤害加成\n提升15%星变异效果|r\n|cFFFF8040【我铸剑！】|r\n|cFFD8A575获得10点铸造值\n获得[君王之剑]|r\n|cFFFF8040【我选卡！】|r\n|cFFD8A575[点击]查看当前拥有的卡牌效果\n获得时选择一张卡牌奖励\n过波时选择一张卡牌奖励|r\n|cFFFF8040【再 努 力 一 点】|r\n|cFFD8A575星变异≥11时击败BOSS解锁进阶条件:\n[右键]消耗神化位进阶为[星国储君](唯一)|r",
    effectart = "Cq_Chujun_2"
  },
  {
    name = "正道骑士",
    weight = 1000,
    lv = 3,
    key = {
      "唯一",
      "黑暗",
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
      if u:hasdata("物品-奴隶头巾") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      if u:getdata("传奇数量") <= 1 then
        SendMsgAll("|cFF9966FF【|r|cFF9F71FF二|r|cFFA47DFF番|r|cFFAA88FF目|r|cFFB093FFの|r|cFFB59FFF记|r|cFFBBAAFF忆|r|cFFC1B5FF】|r")
        PlayBGM({
          bgm = BGM_Zdqs_01,
          time = 95,
          ID = 224,
          unit = u.handle
        })
        flashphoto({
          photo = "Ph_Zdqs_01.tga",
          timeout = 2,
          timehold = 2,
          timein = 2
        })
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:buffset(u.handle, 6, "绝对闪避")
        end)
        for index, value in ipairs(Pools_SpeNormalWeapon) do
          if value.name == "濡湿小镰刀" then
            if not value.hasbeenget then
              local item = u:additem("I0HC")
              System_Count_Weapon = System_Count_Weapon + 1
              SetData(item, "物品判定-神兵")
              SetData(item, "神兵-获取")
              value.hasbeenget = true
            end
            break
          end
        end
        for index, value in ipairs(Pools_SpeNormalWeapon) do
          if value.name == "环印骑士直剑" then
            if not value.hasbeenget then
              local item = u:additem("I0HD")
              System_Count_Weapon = System_Count_Weapon + 1
              SetData(item, "物品判定-神兵")
              SetData(item, "神兵-获取")
              value.hasbeenget = true
            end
            break
          end
        end
      end
      ciyuanget(u, var)
      if GetRandom100(33) then
        u:chat("|cFF6633CC血液里流淌的是对胜利的渴望。")
        ac.wait(5000, function()
          u:chat("|cFF6633CC嘻嘻，我一定要赢。")
        end)
        PlayGlobalSound(Sound_Zdqs_01)
      elseif GetRandom100(50) then
        u:chat("|cFF6633CC背负着踹哈之名，我不能输！")
        PlayGlobalSound(Sound_Zdqs_02)
      else
        u:chat("|cFF6633CC你的太阳落山了！")
        PlayGlobalSound(Sound_Zdqs_03)
      end
      ChangeValue(DamageSystem_Shjc, sy, 0.04)
      ChangeValue(Correction_Jzsh, sy, 0.04000000000000001)
      u:addstexiao(var.name, "位移技能后效果", function(args)
        ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 100, 1)
      end)
      local ewys = 0
      local cs = 0
      ac.loop(250, function()
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -ewys)
        if u:getdata("战斗时间") == 0 then
          ewys = 200
        else
          ewys = 0
        end
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, ewys)
        cs = cs + 1
        local max = 16
        if u:hasdata("正道骑士-我一定要活下去") then
          max = 1
        end
        if max <= cs then
          cs = 0
          if u:hasdata("物品-宠爱戒指") then
            u:sethp(u:getperhp() + 4, true)
            ChangeValue(Hero_Tili, sy, 4)
            u:changedata("宠爱戒指触发次数", 1)
            u:playseensound(Sound_Chongaijiezhi)
          end
        end
      end)
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and not u:hasdata("正道骑士-决死冷却") then
          args.dt = false
          u:settimedata("正道骑士-决死冷却", 480)
          u:settimedata("正道骑士-我一定要活下去", 10)
          u:chat("嘻嘻，我一定要活下去")
          if u:getdata("战斗时间") > 0 then
            u:setdata("战斗时间", 0.1)
          end
          u:clearbuff()
          u:clearbuff("眩晕")
          u:clearbuff("缠绕")
          u:clearbuff("僵直")
          u:clearbuff("混乱")
          u:buffset(u.handle, 1, "无敌")
          ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 250, 10)
        end
      end)
    end,
    effectname = "|cFF6633CC正|r|cFF7047C2道|r|cFF7B5CB7骑|r|cFF8570AD士|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF6633CC唯一 光明 战士|r\n|cFF8570AD提升4%伤害加成\n提升4%近战伤害|r\n|cFF6633CC【我一定要活下去】|r\n|cFF8570AD使用位移技能后1秒内提升100额外移速\n脱战时提升200额外移速\n携带宠爱戒指时,脱战时每4秒触发一次宠爱戒指效果\n受到致死伤害时,清除所有负面,立刻脱战并无敌1秒,10秒内\n提升250额外移速,宠爱触发间隔降低至0.25秒,触发冷却480秒|r\n|cFF6633CC【我的环直不会输】|r\n|cFF8570AD环印骑士直剑基础伤害提升[10%*等级]\n环印骑士直剑命中时附带5秒提升10%额外受伤效果,可叠加,刷新计时|r\n|cFF6633CC【你的太阳落山了】|r\n|cFF8570AD濡湿小镰刀基础伤害提升[1000*等级]\n濡湿小镰刀沉默效果不会失效,附带0.1%最大生命值损耗|r\n|cFF6633CC【诀别黑水晶】|r\n|cFF8570AD死亡时,立刻复活并立刻脱战,瞬移至地图上随机处(BOSS战时不会瞬移),无敌3秒,冷却480秒|r",
    effectart = "Ewl_Zhengdaoqishi.tga",
    test = "    "
  },
  {
    name = "梅比乌斯",
    weight = 200,
    lv = 3,
    key = {
      "唯一",
      "蛇",
      "雷",
      "机械",
      "根源"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("变异判定-觉醒之殿") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Mbws_01)
      u:chat("进化总是伴随着牺牲....这是必然，但有人就是不懂。")
      ChangeValue(DamageSystem_Shjc, sy, 0.04)
      ChangeValue(Damage_Element_Thunder, sy, 0.05)
      u:setdata("梅比乌斯-噬界之影附伤", 10000)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        u:changedata("全属性增幅", 0.0025)
        ChangeValue(Correction_MHp, sy, 5.0E-4)
        u:changedata("梅比乌斯-噬界之影附伤", 10000)
      end)
      u:setdata("梅比乌斯-起源之种数量", 0)
      local cs = 0
      local cs2 = 0
      ac.loop(1000, function()
        if u:getdata("梅比乌斯-起源之种数量") < 3 then
          cs = cs + 1
          if cs == 3 then
            cs = 0
            u:changedata("梅比乌斯-起源之种数量", 1)
          end
        end
        cs2 = cs2 + 1
        if cs2 == 99 then
          cs2 = 0
          u:addallstats(11)
          u:changemaxhp(222)
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if info.element == "雷" and u:getdata("梅比乌斯-起源之种数量") > 0 then
          u:changedata("梅比乌斯-起源之种数量", -1)
          ChangeTimeValue(Damage_Element_Thunder, sy, 0.01, 60)
          local g = CreateGroupLua()
          local dx, dy = tg:getxy()
          for _, xq in ac.selector():in_rangexy(dx, dy, 500):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:groupadd(g)
          end
          tg:groupremove(g)
          for i = 1, 2 do
            if 0 < Group_Counts(g) then
              local mb = Group_Randomunit(g)
              mb:groupremove(g)
              DamageUnit({
                bj = "梅比乌斯(起源之种)",
                unit = mb.handle,
                source = u.handle,
                damage = info.yssh,
                level = 1,
                type = "魔力",
                isvest = false,
                isattack = false,
                isnoarmor = false,
                element = "雷",
                extradata = {""}
              })
            end
          end
        end
        if not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 1)
          local txsh = u:getdata("梅比乌斯-噬界之影附伤")
          tg:buffset(u.handle, 1, "僵直")
          DamageUnit({
            bj = "梅比乌斯(噬界之影)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "雷",
            extradata = {""}
          })
        end
      end)
      u:addstexiao(var.name, "施加Buff时效果-僵直", function(args)
        local u = args.u
        local tg = args.tg
        if not u:hasdata(var.name .. "-特效2冷却") then
          u:settimedata(var.name .. "-特效2冷却", 0.5)
          tg:changetimedata("雷属性抗性", -1, 8)
          ChangeTimeValue(Damage_Element_Thunder, sy, 0.01, 8)
        end
      end)
    end,
    effectname = "|cFF00CC33梅|r|cFF29D652比|r|cFF51E170乌|r|cFF7AEB8F斯|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF00CC33唯一 蛇 雷 机械 根源|r\n|cFF7AEB8F提升4%伤害加成\n提升5%雷属性伤害|r\n|cFF00CC33【起源之种】|r\n|cFF7AEB8F每3秒获得一颗起源之种,上限3颗\n造成雷属性直接伤害时,消耗1颗起源之种使\n该伤害在500范围内传导2次并在60秒内提升1%雷属性伤害|r\n|cFF00CC33【噬界之影】|r\n|cFF7AEB8F直接伤害时僵直目标1秒并附带[10000]雷魔力伤害,触发冷却1秒\n升级时提升该附伤[10000]点数值\n施加僵直时,使目标雷抗降低1%持续8秒并提升自身1%雷属性伤害,冷却0.5秒|r\n|cFF00CC33【无限之蛇】|r\n|cFF7AEB8F升级时提升0.25%全属性与0.5%生命上限\n每99秒提升11点全属性与222生命上限|r",
    effectart = "Ewl_Cq_Mbws",
    test = "    "
  },
  {
    name = "天子",
    clickfunc = function(u, var)
      if u:hasdata("变异判定-天子") and not u:hasdata("变异判定-神化天子") and u:getdata("天子累积伤害") >= 15000 and not Weiyi_Dz[6] and u:ishasshw() and u:isalive() and u:hasdata("判定-大天子") then
        AdvanceGet["神化天子"](u)
      end
    end,
    weight = 5,
    lv = 3,
    key = {
      "唯一",
      "东方",
      "土"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      if u:hasdata("绯想天-天子") then
        add = add + 2000
      end
      if u:ishasitem("I09L") then
        add = add + 2000
      end
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("判定-小天子") or u:hasdata("判定-大天子") or u:hasdata("绯想天-天子") or u:hasdata("变异判定-抖M") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      if u:hasdata("变异判定-抖M") then
        u:deldata("变异判定-抖M")
        u:uivar_remove("抖M", "冥王栏")
      end
      SendMsgAll("|cFF3366FF『|r|cFF3669FE能|r|cFF3A6CFD和|r|cFF3D6FFD我|r|cFF4073FC这|r|cFF4476FB样|r|cFF4779FA的|r|cFF4A7CFA高|r|cFF4D7FF9贵|r|cFF5182F8存|r|cFF5485F7在|r|cFF5788F6相|r|cFF5B8CF6遇|r|cFF5E8FF5是|r|cFF6192F4你|r|cFF6595F3八|r|cFF6898F2辈|r|cFF6B9BF2子|r|cFF6E9EF1的|r|cFF72A1F0福|r|cFF75A5EF分|r|cFF78A8EF』|r")
      SendDtimeMsgAll(3.8, "|cFF3366FF『|r|cFF396CFE所|r|cFF3F71FC以|r|cFF4577FB别|r|cFF4A7CF9愣|r|cFF5082F8着|r|cFF5687F7赶|r|cFF5C8DF5紧|r|cFF6292F4下|r|cFF6898F3跪|r|cFF6D9DF1！|r|cFF73A3F0』|r")
      PlayGlobalSound(Sound_Tenshi_Get_01)
      u:setdata("天子-免疫环境")
      ChangeValue(DamageSystem_Shjc, sy, 0.04)
      ChangeValue(Damage_Element_Earth, sy, 0.05)
      ChangeValue(HeroMenu_HpCure_MaxHp, sy, 0.5)
      ChangeValue(Correction_Exp, sy, 0.2)
      u:changearmor(25)
      u:addstexiao(var.name, "受伤后效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if args.damage >= 10 and tg.handle ~= u.handle and not u:hasdata(var.name .. "-恢复冷却") then
          u:settimedata(var.name .. "-恢复冷却", 1)
          u:changetimearmor(5, 20)
          ChangeTimeValue(HeroMenu_HpChange_MaxHp, sy, 1, 20)
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:getluckrandom(5 * info.txgl) and not u:hasdata(var.name .. "-特效2冷却") then
          u:settimedata(var.name .. "-特效2冷却", 2)
          local txsh = 0.1 * u:getmaxhp()
          DamageUnit({
            bj = "天子(附伤)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "震荡",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "土"
          })
          tg:buffset(u.handle, 1, "眩晕")
        end
      end)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        u:changearmor(1)
      end)
      u:addskill("A0XB")
      u:banskill("A0XB")
      u:setskillforever("A0XA")
      ac.loop(60000, function()
        u:changemaxhp(250)
      end)
      
      local function skill(args)
        if args.skill == S2ID("A0XA") then
          local dskill = args.skill
          if u:hasdata("天子剑冷却") then
            u:setskillcd(dskill, 3)
            u:sendmessage("|cFFFF3300冷却中|r")
            return
          end
          u:settimedata("天子剑冷却", 270)
          ac.wait(270000, function()
            u:sendmessage("|cFF7DBEF1不让土壤裂开之剑冷却完毕|r")
          end)
          u:effectadd("war3mapImported\\spellcardcall.mdx", "origin", 1)
          PlayGlobalSound(Fu)
          u:playsound(Tz_1)
          ac.wait(1000, function()
            local x, y = u:getxy()
            Effectcreate("war3mapImported\\great lightning.mdl", x, y, 0, 3)
            local txsh = 5000 + 1000 * u:getlevel()
            ac.timer(500, 20, function()
              Effectcreate("34.mdl", x, y, 0, 3)
              Effectcreate("war3mapImported\\fuzzystomp.mdx", x, y, 0, 3)
              for _, xq in ac.selector():in_rangexy(x, y, 1200):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:buffset(u.handle, 1.5, "僵直")
                if u:hasdata("变异判定-神化天子") then
                  u:setdata("系统-本次伤害无视伤害抗性")
                end
                DamageUnit({
                  bj = "天子(天子剑)",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "灵力",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "无",
                  extradata = {""}
                })
                if u:hasdata("变异判定-神化天子") then
                  u:deldata("系统-本次伤害无视伤害抗性")
                end
              end
            end)
          end)
        end
      end
      
      u:addtrgevent("单位-发动技能", function(args)
        skill(args)
      end)
    end,
    effectname = "|cFF3E84E3操|r|cFF4A8CE5纵|r|cFF5693E6大|r|cFF619AE8地|r|cFF6DA2EA程|r|cFF79AAEC度|r|cFF84B1EE的|r|cFF90B8EF能|r|cFF9CC0F1力|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF3E84E3唯一 东方 土|r\n|cFF9CC0F1提升4%伤害加成\n提升5%土属性伤害|r\n|cFF3E84E3【天】|r\n|cFF9CC0F1免疫天气\n直接伤害时5%附带[生命上限*0.1]土震荡伤害与1秒眩晕,冷却2秒|r\n|cFF3E84E3【地】|r\n|cFF9CC0F1提升1护甲成长\n提升25护甲\n受伤时提升5护甲与1%生命恢复,持续20秒,冷却1秒\n解锁地符「不让土壤の剑」|r\n|cFF3E84E3【人】|r\n|cFF9CC0F1提升20%经验获取\n提升0.5%生命恢复\n每60秒提升250生命上限|r",
    effectart = "war3mapImported\\BTNEwl_Tianzi.blp",
    test = "    "
  },
  {
    name = "格里菲",
    clickfunc = function(u, button)
      if u:hasdata("变异判定-红心女王") then
        if not u:hasdata("格里菲-守护开启") then
          u:sendmessage("|cFFFFCC66格里菲-守护开启|r")
          u:setdata("格里菲-守护开启")
        else
          u:sendmessage("|cFFFFCC66格里菲-守护关闭|r")
          u:deldata("格里菲-守护开启")
        end
      end
    end,
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "黑暗",
      "战士",
      "童话",
      "兽"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      add = add + 100 * u:getdata("童话变异数量")
      if u:hasdata("红城的律令-无上王权解锁") then
        add = add + 5000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:getdata("童话变异数量") >= 1 and 1 <= u:getdata("黑暗变异数量") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("|cFFFF4B4B「与友人并肩作战正是骑士的梦想」|r")
      ac.wait(3000, function()
        u:chat("|cFFFF4B4B「好 一起上吧!」|r")
      end)
      u:changedata("系统-飞行强度", 100)
      u:setdata("格里菲-守护开启")
      ChangeValue(Correction_Jzsh, sy, 0.025)
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if tg:hasdata("格里菲-方块领域中") then
          info.wsmy = true
        end
      end)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:hasdata("格里菲-方块领域中") then
          info.endup = info.endup + 0.09
        end
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        if tg:hasdata("格里菲-方块领域中") then
          u:changedata("魔力值", GetRandomInt(1, 3))
        end
        if u:hasdata("格里菲-黑暗加成") then
          ChangeValue(Correction_Jzsh, sy, 1.0E-4)
        end
        if u:hasdata("格里菲-童话加成") then
          u:changemaxhp(1)
        end
      end)
      local cs = 0
      local jz = 0
      local gl = 0
      ac.loop(2500, function()
        if not u:hasdata("格里菲-梦境值获取") and u:hasdata("变异判定-红心女王") then
          u:setdata("格里菲-梦境值获取")
          u:changedata("爱丽丝-梦境值", 1)
        end
        if u:isalive() then
          cs = cs + 1
          if cs == 4 then
            cs = 0
            local dx, dy = u:getxy()
            local wqlx = Hero_Equip_WeaponType[sy]
            Effectcreate("fangkuai_pk.mdx", dx, dy, 0, 1.5)
            local txsh = 0.1 * u:getdata("魔力值") + 0.1 * GetData(wqlx, "基础伤害")
            local g = CreateGroupLua()
            local dtime = 0
            ac.loop(250, function(timer)
              dtime = dtime + 1
              ForGroupLuaNew(g, function(xq)
                xq:deldata("格里菲-方块领域中")
              end)
              for _, xq in ac.selector():in_rangexy(dx, dy, 575):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                DamageUnit({
                  bj = "格里菲(附伤)",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "魔力",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = "心灵",
                  extradata = {""}
                })
              end
              if dtime == 20 then
                ForGroupLuaNew(g, function(xq)
                  xq:deldata("格里菲-方块领域中")
                end)
                timer:remove()
              end
            end)
          end
        end
        if 0 < u:getdata("战斗时间") then
          if u:hasdata("格里菲-脱战加成") then
            u:deldata("格里菲-脱战加成")
            u:delskill("S0BU")
          end
        elseif not u:hasdata("格里菲-脱战加成") then
          u:setdata("格里菲-脱战加成")
          u:addskill("S0BU")
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -gl)
        ChangeValue(Correction_Jzsh, sy, 0.1 * -jz)
        jz = 0.1 * u:getstate("黑暗变异")
        gl = 0.05 * u:getstate("童话变异")
        ChangeValue(Correction_Jzsh, sy, 0.1 * jz)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * gl)
        if u:isonlymaxvar("黑暗") then
          if not u:hasdata("格里菲-黑暗加成") then
            u:setdata("格里菲-黑暗加成")
            u:changedata("黑暗变异补正", 25)
          end
        elseif u:hasdata("格里菲-黑暗加成") then
          u:deldata("格里菲-黑暗加成")
          u:changedata("黑暗变异补正", -25)
        end
        if u:isonlymaxvar("童话") then
          if not u:hasdata("格里菲-童话加成") then
            u:setdata("格里菲-童话加成")
            u:changedata("童话变异补正", 25)
            ChangeValue(DamageSystem_EndSh, sy, 0.005000000000000001)
          end
        elseif u:hasdata("格里菲-童话加成") then
          u:deldata("格里菲-童话加成")
          u:changedata("童话变异补正", -25)
          ChangeValue(DamageSystem_EndSh, sy, -0.005000000000000001)
        end
      end)
      u:addstexiao(var.name, "进入战斗状态时", function(args)
        local u = args.u
        u:sendmessage("|cFFFF9900格里菲-入战|r")
        ChangeTimeValue(Correction_Jzsh, sy, 0.1, 3)
        ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 200, 3)
      end)
      u:addstexiao(var.name, "位移技能后效果", function(args)
        if u:getluckrandom(5) then
          u:setdata("战斗时间", 0)
        end
      end)
      u:changedata("效果增强-背水", 0.25)
    end,
    effectname = "|cFFFF9900格里菲|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFFF9900黑暗 战士 唯一 童话 兽|r\n|cFFBF5C00【鹫狮子骑士】\n提升100飞行强度\n提升2.5%近战伤害\n使用位移技能后5%直接进入脱战状态\n脱战时提升20%移速\n入战时增加10%近战伤害并提升200额外移速 持续3秒|r\n|cFFAF0069方块骑士\n每10秒在自身创建一个方块领域575范围，每0.25秒\n附带当前魔力值10%+近战武器伤害基础值10%心灵魔力伤害，持续5秒\n对于领域内的敌人伤害增加9%\n对于领域内的敌人无视伤害免疫\n杀死领域内的敌人时魔力值增加1~3|r\n|cFFFF4B4B【红城「弗里塞尔」の|r|cFF0000C9律法】\n提升25%背水效果\n提升[1%*黑暗变异]近战伤害\n提升[0.5%*童话变异]伤害加成\n唯一主变异为黑暗时:\n【黑暗变异补正增加25%\n杀敌时增加0.1%的近战伤害】\n唯一主变异为童话时:\n【提升0.5%终结伤害\n杀敌时增加1点生命值上限\n增加25%童话变异补正】|r\n|cFFF38784【女王の骑士】|r\n|cFFFF4B4B「数据删除」\n「无法留下任何名誉,就这么被他人所束缚,直到死去的人生,我无法忍受」\n「没错,就这么抱着你,踏上私奔之旅吧。只要有这双翅膀无论何处我都能飞过去」|r",
    effectart = "Mwx_Alice_07.tga",
    test = [[

        ]]
  },
  {
    name = "吸血剑鬼",
    weight = 5,
    lv = 3,
    key = {
      "唯一",
      "黑暗",
      "战士",
      "吸血鬼",
      "恶魔",
      "魅魔"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if not u:hasdata("权限-吸血剑鬼") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      if GetRandom100(50) then
        PlayGlobalSound(Sound_Xierti_01)
        SendMsgAll("|cFFFE0070『|r|cFFF6087B万|r|cFFEE1086…|r|cFFE71891…|r|cFFDF1F9C万|r|cFFD727A7圣|r|cFFCF2FB2节|r|cFFC837BD快|r|cFFC03FC8乐|r|cFFB847D3…|r|cFFB04EDE…|r|cFFA956E9』|r")
        ac.wait(4000, function()
          SendMsgAll("|cFFFE0070『|r|cFFF80679请|r|cFFF10D82…|r|cFFEB138B…|r|cFFE51A94请|r|cFFDE209D你|r|cFFD826A6要|r|cFFD22DAF一|r|cFFCC33B8直|r|cFFC539C0盯|r|cFFBF40C9着|r|cFFB946D2我|r|cFFB24CDB看|r|cFFAC53E4！|r|cFFA659ED』|r")
        end)
      else
        PlayGlobalSound(Sound_Xierti_02)
        SendMsgAll("|cFFFE0070『|r|cFFF80678T|r|cFFF30B80r|r|cFFED1188i|r|cFFE81790c|r|cFFE21C98k|r|cFFDC22A0 |r|cFFD728A8o|r|cFFD12DB0r|r|cFFCB33B8 |r|cFFC639BFT|r|cFFC03EC7r|r|cFFBB44CFe|r|cFFB54AD7a|r|cFFAF4FDFt|r|cFFAA55E7~|r|cFFA45BEF』|r")
      end
      u:addskill("S0BH")
      ChangeValue(DamageSystem_Shjc, sy, 0.025)
      ChangeValue(Correction_Jzsh, sy, 0.025)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        info.damage = info.damage * 1.04
      end)
      u:setdata("希尔缇-吸血鬼强化")
      ChangeValue(DamageSystem_Xxz, sy, 3)
      ChangeValue(DamageSystem_Xxzq, sy, 0.25)
      u:changedata("吸血鬼变异补正", 25)
      u:setdata("希尔缇-黑暗强化")
      ChangeValue(Damage_Element_Dark, sy, 0.05)
      u:changedata("黑暗变异补正", 25)
      u:setdata("希尔缇-恶魔强化")
      ChangeValue(DamageSystem_EndSh, sy, 0.003)
      u:changedata("恶魔变异补正", 25)
      local jz = 0
      local jc = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Jzsh, sy, 0.1 * -jz)
        jz = 0.05 * u:getstate("战士变异")
        ChangeValue(Correction_Jzsh, sy, 0.1 * jz)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jc)
        jc = 0.05 * (u:getstate("吸血鬼变异") + u:getstate("黑暗变异") + u:getstate("恶魔变异"))
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * jc)
      end)
      u:addstexiao(var.name, "进入战斗状态时", function(args)
        local u = args.u
        if not u:hasdata(var.name .. "-入战冷却") then
          u:settimedata(var.name .. "-入战冷却", 10)
          u:sendmessage("|cFFFE496D吸血剑鬼-剑风解放|r")
          u:addskill("S0BI")
          ac.wait(3000, function()
            u:delskill("S0BI")
            u:clearbuff("B0FP")
          end)
        end
      end)
    end,
    effectname = "|cFFFE496D吸|r|cFFFE6D6C血|r|cFFFF926A剑|r|cFFFFB669鬼|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFFE496D唯一 黑暗 战士 吸血鬼 恶魔 魅魔|r\n|cFFFE496D【剑风解放】|r\n|cFFFFB669提升5%近战伤害(独立)\n提升15%移速\n提升[2.5%+0.5%*战士变异]近战伤害\n入战时获得3秒极速,冷却10秒|r\n|cFFFE496D【恋爱剑鬼】|r\n|cFFFFB669提升[2.5%+0.5%*吸血鬼变异]伤害加成\n使用糖果时提升1点属性与1%伤害修正\n提升3伤害吸血\n提升15%伤害吸血效果\n提升25%吸血鬼变异补正|r\n|cFFFE496D【暗夜之力】|r\n|cFFFFB669提升[0.5%*黑暗变异+0.5%*恶魔变异]伤害加成\n提升0.3%终结伤害\n提升5%暗属性伤害\n提升25%黑暗变异补正\n提升25%恶魔变异补正|r",
    effectart = "Ewl_Cq_Xierti",
    test = [[

            ]]
  },
  {
    name = "狼",
    clickfunc = function(u)
      local sy = u.ownerid
      if u:isalive() and u:ishasshw() and u:getdata("只狼-杀敌计数") >= 250 and Hero_Shenhua_Now[sy] == 0 then
        AdvanceGet["只狼"](u)
      end
    end,
    weight = 5,
    lv = 3,
    key = {
      "唯一",
      "战士",
      "影"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I0FO") then
        add = add + 2500
      end
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("权限-只狼") and u:ishasitem("I0FO") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Zhilang_Get_01)
      u:sendmessage("|cFFFFFF00「狼，和我的血一起活下去吧……」|r")
      ChangeValue(DamageSystem_Shjc, sy, 0.03)
      ChangeValue(Correction_Jzsh, sy, 0.03)
      u:setdata("战斗记忆", 0)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        if not tg:hasdata("只狼-破势判定") then
          local hs
          if u:isnormal() then
            hs = GetRandomReal(1, 10)
          else
            hs = GetRandomReal(1, 3)
          end
          if tg:hasdata("只狼-不死斩抗性破坏") then
            hs = hs * 2
          end
          tg:changedata("破势", hs)
          if tg:getdata("破势") >= 100 then
            tg:deldata("破势")
            tg:effectadd("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl")
            tg:buffset(u.handle, 3, "暂停")
            if tg:isnormal() then
              tg:settimedata("只狼-破势判定", 3)
              tg:buffset(u.handle, 3, "破坏-伤害抗性")
            else
              tg:settimedata("只狼-破势判定", 10)
              tg:buffset(u.handle, 10, "破坏-伤害抗性")
            end
          end
        end
      end)
      u:addstexiao(var.name, "伤害系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:isnormal() and not u:hasdata(var.name .. "-特效冷却") and (tg:hasbuff("僵直") or tg:hasbuff("暂停") or tg:hasbuff("眩晕")) then
          u:settimedata(var.name .. "-特效冷却", 0.5)
          tg:effectadd("war3mapImported\\Texiao_Xuebao.mdx")
          info.damage = info.damage + tg:gethp()
        end
      end)
      
      local function skill(args)
        if args.skill == S2ID("A1M9") then
          u:effectadd("Abilities\\Spells\\Human\\ControlMagic\\ControlMagicTarget.mdl", "overhead", 1)
          if Boolean_Jinselingyu then
            u:setdata("楔丸-格挡判定时间", 0.3)
          else
            u:setdata("楔丸-格挡判定时间", 0.4)
          end
        end
      end
      
      u:addtrgevent("单位-发动技能", function(args)
        skill(args)
      end)
    end,
    effectname = "|cFFFFFF00狼|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF1FBF00唯一 战士 影|r\n|cFFFFFF00提升3%伤害加成\n提升3%近战伤害|r\n|cFF1FBF00【龙咳】|r\n|cFFFFFF00彻底死亡时对随机一名队友施加一层龙咳,每层增加8%额外受伤;达到五层时即死目标并清空层数|r\n|cFF1FBF00【忍杀】|r\n|cFFFFFF00对[僵直、暂停、眩晕]中普通单位造成伤害时,提升[目标100%最大生命值]固定伤害,触发冷却0.5秒|r\n|cFF1FBF00【衡势】|r\n|cFFFFFF00直接伤害时对目标叠加破势;达到100%时清空累积值,暂停目标单位并破坏抗性3(10)秒|r\n|cFF1FBF00【战斗记忆】|r\n|cFFFFFF00杀敌时提升0.005%伤害加成,杀敌计数会保留,神化后根据杀敌计数提升额外近战伤害与伤害加成\n杀死BOSS时提升5%伤害加成\n杀敌计数达到250后点击神化,只能作为首发神化|r",
    effectart = "BTNEwl_Zhilang_Chuanqi"
  },
  {
    name = "大阿阇黎",
    weight = 5,
    lv = 3,
    key = {
      "唯一",
      "光明",
      "东方"
    },
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      if u:ishasitem("I07C") then
        add = add + 1000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("权限-大阿阇黎") or u:hasdata("判定-大阿阇黎特殊权限") or u.type == HeroType["圣白莲"] then
        b = true
      end
      if Weiyi_New[14] == true and not u:hasdata("判定-大阿阇黎特殊权限") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("|cFFFF9933一念愚即般若绝，一念智即般若生|r")
      PlayGlobalSound(Sound_Daasheli_Get)
      u:adddivinity(2)
      Weiyi_New[14] = true
      Weiyi_Dz[13] = true
      u:changedata("闪避值", 10)
      ChangeValue(DamageSystem_Shjc, sy, 0.1)
      ChangeValue(Correction_Jzsh, sy, 0.1)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.9, 1)
      ChangeValue(DamageSystem_Baoji, sy, 10)
      ChangeValue(DamageSystem_Baoshang, sy, 0.1)
      ChangeValue(HeroMenu_HpChange_Inr, sy, 10)
      u:addskill("S01R")
    end,
    effectname = "|cFFFF8928大|r|cFFFF9942阿|r|cFFFFAA5B阇|r|cFFFFBA75黎|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFFF8928唯一 光明 神性2 东方|r\n|cFFFF8928【婆娑】|r\n|cFFFFBA75提升10%伤害加成\n提升10%近战伤害\n提升10%受伤减少\n提升10闪避值\n提升10%暴击率\n提升10%暴击伤害\n提升10%移速\n提升10生命恢复\n生命值降低至10%时,无敌3秒,冷却600秒|r\n|cFFFF8928【袈裟】|r\n|cFFFFBA75[圣白莲]超人持续期间造成伤害无视伤害免疫\n[圣白莲]紫云之兆效果对自身效果提升50%\n[圣白莲]铁拳提升1秒控制时间|r\n|cFFFF8928【星莲华】|r\n|cFFFFBA75击杀BOSS或持有魔人经卷时进阶为[神话]|r\n|cFF949596一花一世界，一佛一如来|r",
    effectart = "war3mapImported\\BTNEwl_Asheli.blp",
    test = [[
    60%+20% = 80%
            ]]
  },
  {
    name = "白银城主",
    clickfunc = function(u)
      local sy = u.ownerid
      if u:isalive() and not u:hasdata("变异判定-拉比琳丝") and u:ishasshw() and u:hasdata("拉比琳丝进阶标记") then
        AdvanceGet["拉比琳丝"](u)
      end
    end,
    weight = 5,
    lv = 3,
    key = {
      "唯一",
      "光明",
      "白毛",
      "恶魔"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if (u:isinrect(RECT_Feichengqu) or u:isinrect(RECT_Feichezhan) or u:isinrect(RECT_Feichangqu)) and u:hasdata("权限-白银城主") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("|cFF6699CC当灾难从天而降时，我会为你们抵挡一切！")
      PlayGlobalSound(Sound_Bycz_Get)
      u:become("沉重")
      u:addstexiao("白银城主", "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:ishasskill("A1DM") then
          info.end1 = info.end1 + 0.09
        end
      end)
      ChangeValue(DamageSystem_Shjc, sy, 0.04)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.8, 1)
      ChangeValue(DamageSystem_EndSh, sy, 0.004)
      u:setdata("白银城主-城内时间", 0)
      local zs = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * zs))
        zs = 0.1 * u:getstate("恶魔变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * zs))
        if u:isinrect(RECT_Feichengqu) or u:isinrect(RECT_Feichezhan) or u:isinrect(RECT_Feichangqu) then
          if not u:hasdata("拉比琳丝进阶标记") and u:isalive() then
            u:changedata("白银城主-城内时间", 3)
            if u:getdata("白银城主-城内时间") >= 720 then
              u:setdata("拉比琳丝进阶标记")
              u:sendmessage("|cFF7DBEF1白银城主进阶解锁|r")
            end
          end
          if not u:hasdata("拉比琳丝-城主") then
            u:setdata("拉比琳丝-城主")
            u:addskill("S07F")
            u:changedata("系统-飞行强度", 100)
            ChangeValue(DamageSystem_Shjc, sy, 0.075)
            ChangeValue(DamageSystem_Ssjianshao, sy, 0.8, 1)
          end
        elseif u:hasdata("拉比琳丝-城主") then
          u:deldata("拉比琳丝-城主")
          u:delskill("S07F")
          u:changedata("系统-飞行强度", -100)
          ChangeValue(DamageSystem_Shjc, sy, -0.075)
          ChangeValue(DamageSystem_Ssjianshao, sy, 0.8, 2)
        end
      end)
    end,
    effectname = "|cFF6699CC白|r|cFF77BBDD银|r|cFF88DDEE城|r|cFF99FFFF主|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF6699CC唯一 恶魔 光明|r\n|cFF99FFFF提升4%伤害加成\n提升20%受伤减少|r\n|cFF6699CC【恶魔领】|r\n|cFF99FFFF提升0.4%终结伤害\n对恶魔伤害提升9%\n受到来自恶魔伤害降低20%\n提升[恶魔变异*1%]伤害加成|r\n|cFF6699CC【城城城主】|r\n|cFF99FFFF处于[城区,车站,厂区]时获得提升:\n[提升100飞行强度\n提升7.5%伤害加成\n提升20%药水成功率\n提升20%移动速度\n提升20%受伤减少]\n在城市区域内累积存活720秒点击进阶为[神话]|r",
    effectart = "war3mapImported\\BTNEwl_Lbls_01",
    test = [[
                10%+20%
            ]]
  },
  {
    name = "鬼灭之刃",
    clickfunc = function(u, ewl)
      local sy = u.ownerid
      if u:isalive() and u:ishasshw() and Weiyi_Dz[15] == false and u:getdata("鬼灭之刃杀敌") >= 200 and (u:ishasitem("I03V") or TID[sy] == "1585218680") then
        AdvanceGet["炭治郎"](u)
      end
    end,
    weight = 5,
    lv = 3,
    key = {
      "唯一",
      "战士",
      "水"
    },
    unique = false,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem(Weapons["日轮刀"]) then
        add = add + 1000
      end
      if u:hasdata("判定-鬼灭之刃本人") then
        add = add + 5000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("权限-鬼灭之刃") and (KillCount_Katana[u.ownerid] >= 50 or u:ishasitem("I03V")) then
        b = true
      end
      if u:hasdata("判定-鬼灭权限") then
        b = true
      end
      if Weiyi_New[13] == true and not u:hasdata("判定-鬼灭之刃本人") then
        b = false
      end
      if u:hasdata("变异判定-炎之呼吸") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      Weiyi_New[13] = true
      u:chat("|cFF0041FF全集中！水之呼吸！|r")
      PlayGlobalSound(Sound_Tzl_Get)
      ChangeValue(DamageSystem_Baoji, sy, 5)
      ChangeValue(Hero_Tili_Huifu, sy, 0.1)
      ChangeValue(DamageSystem_Baoshang, sy, 0.12)
      ChangeValue(Correction_Jzsh, sy, 0.05)
      ChangeValue(DamageSystem_Shjc, sy, 0.025)
      u:changedata("闪避值", 15)
      u:changedata("固定格挡", 44)
      u:addstexiao(var.name, "暴击系统计算效果", function(args)
        local info = args.damageinfo
        if info.ismeleedamage then
          info.bjl = info.bjl + 10
          info.isguimiezhirencrit = true
        end
      end)
      u:addstexiao(var.name, "暴击系统触发效果", function(args)
        local tg = args.tg
        local info = args.damageinfo
        if info.isguimiezhirencrit and info.ismeleedamage and not u:hasdata("鬼灭之刃横水车冷却") then
          u:settimedata("鬼灭之刃横水车冷却", 1)
          local txsh
          if u:isnormal() then
            txsh = 0.25 * u:gethp()
          else
            txsh = 0.005 * u:gethp()
          end
          LossHpUnit({
            u = u,
            tg = tg,
            damage = txsh,
            bj = "鬼灭之刃(横水车损耗)"
          })
          tg:effectadd("Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl")
        end
      end)
      local zj = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Jzsh, sy, 0.1 * (-1 * zj))
        zj = 0.05 * u:getstate("水变异")
        ChangeValue(Correction_Jzsh, sy, 0.1 * (1 * zj))
      end)
      local x, y = u:getxy()
      local hp = 0
      ac.loop(1000, function()
        local x2, y2 = u:getxy()
        ChangeValue(HeroMenu_HpCure_MaxHp, sy, -1 * hp)
        if x2 == x and y2 == y then
          hp = 0
        elseif u:hasdata("变异判定-炭治郎") then
          hp = 0.5
        else
          hp = 0.25
        end
        x, y = u:getxy()
        ChangeValue(HeroMenu_HpCure_MaxHp, sy, 1 * hp)
      end)
      u:addstexiao(var.name, "位移技能后效果", function(args)
        if not u:hasdata("炭治郎-流转之舞") and not u:hasdata("流转之舞冷却") and not u:hasdata("流转之舞使用冷却") and u:hasdata("炭治郎-流转之舞开启") then
          u:settimedata("炭治郎-流转之舞", 0.5)
        end
      end)
      u:setdata("炭治郎-流转之舞开启")
      AddUISkill({
        text = "流转之舞",
        u = u,
        cd = 3,
        icon = "war3mapImported\\BTNEwl_Guimiezhiren.blp",
        func = function(args)
          local u = args.u
          if u:isalive() then
            if u:hasdata("炭治郎-流转之舞开启") then
              u:deldata("炭治郎-流转之舞开启")
              u:sendmessage("|cFF7DBEF1关闭流转之舞|r")
            else
              u:setdata("炭治郎-流转之舞开启")
              u:sendmessage("|cFF7DBEF1开启流转之舞|r")
            end
          end
        end
      })
      local g = CreateGroupLua()
      u:addtrgevent("单位-指定点目标指令", function(args)
        if args.orderid == String2OrderIdBJ("smart") and u:hasdata("炭治郎-流转之舞") then
          if not u:hasdata("位移体力消耗标记") then
            if u:lossstamina(1) then
              u:settimedata("位移体力消耗标记", 0.001)
            else
              u:sendmessage("|cFFFF3300体力值不足|r")
              return
            end
          end
          u:deldata("炭治郎-流转之舞")
          u:setdata("流转之舞冷却")
          if not u:hasdata("变异判定-炭治郎") then
            u:settimedata("流转之舞使用冷却", 3)
          end
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          local fx = GetRandomInt(1, 2)
          local mjl = 1800
          if dis <= 100 then
            dis = 100
          end
          if mjl <= dis then
            dis = mjl
          end
          local txsh = u:getallattri() * 15
          local cs2 = math.floor(dis / 100)
          u:effectadd("war3mapimported\\[ake]war3ake.com - 6284107988548473846665750.mdl", "chest", 0.02 * cs2)
          local a1 = GetRandomReal(90, 150)
          local l1 = dis / 4
          local l2 = l1 / math.tan(a1 / 2)
          local r1 = l1 / math.sin(a1 / 2)
          local xx, yy = PolarXY(x, y, l1, angle)
          if fx == 1 then
            xx, yy = PolarXY(xx, yy, l2, angle + 90)
          else
            xx, yy = PolarXY(xx, yy, l2, angle - 90)
          end
          local jd2 = AngleXY(xx, yy, x, y)
          local cs = cs2
          ac.loop(10, function(timer)
            cs = cs - 1
            if fx == 1 then
              jd2 = jd2 + a1 / cs2
            else
              jd2 = jd2 - a1 / cs2
            end
            local xxx, yyy = PolarXY(xx, yy, r1, jd2)
            local dx, dy = u:getxy()
            Effectcreate("Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl", xxx, yyy)
            for _, xq in ac.selector():in_rangexy(dx, dy, 250):is_enemy(u.handle):isnotingroup(g):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g)
              DamageUnit({
                bj = "鬼灭之刃(流转之舞)",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 4,
                type = "灵力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "水"
              })
            end
            if cs == 0 then
              cs = cs2
              local x, y = PolarXY(x, y, dis / 2, angle)
              local xx, yy = PolarXY(x, y, l1, angle)
              if fx == 1 then
                xx, yy = PolarXY(xx, yy, l2, angle - 90)
              else
                xx, yy = PolarXY(xx, yy, l2, angle + 90)
              end
              local jd2 = AngleXY(xx, yy, x, y)
              ac.loop(10, function(timer2)
                cs = cs - 1
                if fx == 1 then
                  jd2 = jd2 - a1 / cs2
                else
                  jd2 = jd2 + a1 / cs2
                end
                local xxx, yyy = PolarXY(xx, yy, r1, jd2)
                u:setxy(xxx, yyy)
                local dx, dy = u:getxy()
                Effectcreate("Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl", xxx, yyy)
                for _, xq in ac.selector():in_rangexy(dx, dy, 250):is_enemy(u.handle):isnotingroup(g):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(g)
                  DamageUnit({
                    bj = "鬼灭之刃(流转之舞)",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 4,
                    type = "灵力",
                    isvest = true,
                    isattack = false,
                    isnoarmor = false,
                    element = "水"
                  })
                end
                if cs == 0 then
                  u:setdata("位移点X", xxx)
                  u:setdata("位移点Y", yyy)
                  GroupClearLua(g)
                  u:deldata("流转之舞冷却")
                  timer2:remove()
                end
              end)
              timer:remove()
            end
          end)
        end
      end)
    end,
    effectname = "|cFF1AAEFF鬼|r|cFF44B6FF灭|r|cFF6FBFFF之|r|cFF99C7FF刃|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF1AAEFF唯一 战士 水|r\n|cFF99C7FF提升5%近战伤害|r\n|cFF1AAEFF【水之呼吸.全集中】|r\n|cFF99C7FF提升5%暴击率\n提升12%暴击伤害\n提升15闪避值\n提升44固减\n提升0.1点体力恢复\n移动时提升0.25%医疗恢复|r\n|cFF1AAEFF【参之型.流流舞】|r\n|cFF99C7FF提升2.5%伤害加成\n提升[0.5%*水变异]近战伤害\n近战伤害杀敌时提升0.01%近战伤害|r\n|cFF1AAEFF【贰之型改.横水车】|r\n|cFF99C7FF提升10%近战伤害暴击率\n近战伤害暴击附带[25%当前(0.5%当前)]损耗,冷却1秒|r\n|cFF1AAEFF【拾之型.生生流转(点击拓展栏切换开关)】|r\n|cFF99C7FF位移技能后0.5秒内可发动[流转之舞],冷却3秒|r",
    effectart = "war3mapImported\\BTNEwl_Guimiezhiren.blp",
    test = [[
                10% + 10% + 10% 10% 10% 20% 25% = 95%
            ]]
  },
  {
    name = "德丽莎观星",
    clickfunc = function(u)
      local sy = u.ownerid
      if u:hasdata("白羽扇-持有") then
        u:uivar_setcd({
          keyname = "德丽莎观星",
          keytype = "传奇栏",
          cd = 300
        })
      else
        u:uivar_setcd({
          keyname = "德丽莎观星",
          keytype = "传奇栏",
          cd = 360
        })
      end
      if u:isalive() then
        u:changedata("幸运", -1 * dlsxy)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * dlszj))
        ChangeValue(Correction_Exp, sy, -2 * dlsexp)
        ChangeValue(Hero_Tili_Max, sy, -1 * dlstlmax)
        u:changedata("全属性增幅", -1 * dlsqsx)
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -1 * dlsewys)
        u:deldata("德丽莎观星-杀敌成长")
        u:deldata("德丽莎观星-破抗")
        u:deldata("德丽莎观星-飞行")
        dlsxy, dlszj, dlsexp, dlstlmax, dlsqsx, dlsewys, dlssd = 0, 0, 0, 0, 0, 0, 0
        dlswskx, dlsfly = false, false
        u:changedata("德丽莎观星-观星计数", 1)
        if u:getdata("德丽莎观星-观星计数") >= 9 then
          u:setdata("德丽莎观星-观星计数", 9)
        end
        u:sendmessage("|cFFB0C0D6当前观星计数:" .. u:getdata("德丽莎观星-观星计数") .. "|r")
        
        local function getRandomItems(options, n)
          local selectedItems = {}
          local selectedIndices = {}
          while n > #selectedItems do
            local index
            index = GetRandomInt(1, #options)
            if not selectedIndices[index] then
              table.insert(selectedItems, options[index])
              selectedIndices[index] = true
            end
          end
          return selectedItems
        end
        
        local options = {
          {
            name = "幸运",
            min = -3,
            max = 5
          },
          {
            name = "伤害加成",
            min = -0.5,
            max = 1
          },
          {
            name = "经验获取",
            min = -0.075,
            max = 0.15
          },
          {
            name = "体力上限",
            min = -5,
            max = 10
          },
          {
            name = "全属性",
            min = -0.05,
            max = 0.2
          },
          {
            name = "额外移速",
            min = -50,
            max = 100
          },
          {
            name = "法术伤害",
            min = 0.05,
            max = 0.15
          },
          {
            name = "无视伤害闪避与伤害免疫",
            value = true
          },
          {name = "飞行", value = true}
        }
        local xgcount = GetRandomInt(1, 4)
        if u:hasdata("白羽扇-持有") then
          xgcount = xgcount + 1
        end
        local result = getRandomItems(options, xgcount)
        u:sendmessage("|cFFB0C0D6德丽莎观星效果:|r")
        for _, item in ipairs(result) do
          local value = GetRandomReal(item.min, item.max)
          if item.name == "幸运" then
            dlsxy = value
            u:changedata("幸运", value)
            u:sendmessage("|cFFB0C0D6幸运:" .. math.floor(value) .. "|r")
          elseif item.name == "伤害加成" then
            dlszj = value
            ChangeValue(DamageSystem_Shjc, sy, 0.1 * value)
            u:sendmessage("|cFFB0C0D6伤害加成:" .. math.floor(value * 10) .. "%|r")
          elseif item.name == "经验获取" then
            dlsexp = value
            ChangeValue(Correction_Exp, sy, 2 * value)
            u:sendmessage("|cFFB0C0D6经验获取:" .. math.floor(value * 200) .. "%|r")
          elseif item.name == "体力上限" then
            dlstlmax = value
            ChangeValue(Hero_Tili_Max, sy, value)
            u:sendmessage("|cFFB0C0D6体力上限:" .. math.floor(value) .. "|r")
          elseif item.name == "全属性" then
            dlsqsx = value
            u:changedata("全属性增幅", value)
            u:sendmessage("|cFFB0C0D6全属性增幅:" .. math.floor(value * 100) .. "%|r")
          elseif item.name == "额外移速" then
            dlsewys = value
            ChangeValue(HeroMenu_ExtraMoveSpeed, sy, value)
            u:sendmessage("|cFFB0C0D6额外移速:" .. math.floor(value) .. "|r")
          elseif item.name == "法术伤害" then
            dlssd = value
            u:setdata("德丽莎观星-杀敌成长", value)
            u:sendmessage("|cFFB0C0D6杀敌成长:" .. string.format("%.2f", value) .. "%|r")
          elseif item.name == "无视伤害闪避与伤害免疫" then
            dlswskx = value
            u:setdata("德丽莎观星-破抗")
            u:sendmessage("|cFFB0C0D6无视伤害闪避与伤害免疫|r")
          elseif item.name == "飞行" then
            dlsfly = value
            u:setdata("德丽莎观星-飞行")
            u:sendmessage("|cFFB0C0D6飞行|r")
          end
        end
      else
        u:sendmessage("|cFFB0C0D6死亡状态无效|r")
        u:uivar_setcd({
          keyname = "德丽莎观星",
          keytype = "传奇栏",
          nowcd = 1
        })
      end
    end,
    cd = 360,
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "德丽莎",
      "星"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I0H3") then
        add = add + 1000
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("变异判定-环都市") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendColorfulMsgAll("白栖星好风，毕星好雨。闲来无事，我教你些观天象之术吧", "|cFFCCFFFF", "|cFFB0C0D6", "|cFF3C61A5")
      PlayGlobalSound(Sound_Dlsgx_01)
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("德丽莎观星-破抗") then
          info.wssb = true
          info.wsmy = true
        end
      end)
      ChangeValue(DamageSystem_Shjc, sy, 0.025)
      ChangeValue(DamageSystem_Baoshang, sy, 0.25)
      u:setdata("德丽莎观星-观星计数", 0)
      local bj = 0
      local bs = 0
      local jc = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Baoji, sy, -1 * bj)
        ChangeValue(DamageSystem_Baoshang, sy, -1 * bs)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * jc))
        bj = 2 * u:getdata("德丽莎观星-观星计数")
        bs = 0.05 * u:getdata("德丽莎观星-观星计数") + 0.03 * u:getstate("德丽莎变异")
        jc = 0.09 * u:getstate("德丽莎变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * jc))
        ChangeValue(DamageSystem_Baoji, sy, 1 * bj)
        ChangeValue(DamageSystem_Baoshang, sy, 1 * bs)
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        if u:getdata("德丽莎观星-杀敌成长") ~= 0 then
          ChangeValue(Correction_Magic, sy, 0.01 * u:getdata("德丽莎观星-杀敌成长"))
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        if not u:hasdata(var.name .. "-特效冷却") then
          local txsh = 22222 * u:getdata("德丽莎观星-观星计数")
          u:settimedata(var.name .. "-特效冷却", 10 - 0.5 * u:getdata("德丽莎观星-观星计数"))
          DamageUnit({
            bj = "德丽莎观星(玄武)",
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
      end)
      local dskill = S2ID("A1SK")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if u:getdata("德丽莎观星-观星计数") == 0 then
            b = false
            u:sendmessage("|cFF7DBEF1观星计数不足|r")
          end
          if b then
            u:changedata("德丽莎观星-观星计数", -1)
            SendColorfulMsgAll("北斗诸邪，除凶去妖", "|cFFCCFFFF", "|cFFB0C0D6", "|cFF3C61A5")
            PlayGlobalSound(Sound_Dlsgx_02)
            u:changetimedata("固定伤害", 0.1 * (4444 * u:getdata("德丽莎观星-观星计数")), 15)
            ForGroupLuaNew(Group_PlayHero, function(xq)
              local sy2 = xq.ownerid
              ChangeTimeValue(DamageSystem_Baoji, sy2, 100, 15)
              xq:effectadd("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", "origin", 15)
            end)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
    end,
    effectname = "|cFF3C61A5德|r|cFF5374AF丽|r|cFF6A87B9莎|r|cFF829AC2.|r|cFF99ADCC观|r|cFFB0C0D6星|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF3C61A5唯一 星 德丽莎|r\n|cFFB0C0D6提升2.5%伤害加成\n提升25%暴击伤害|r\n|cFF3C61A5【九宫天】|r\n|cFFB0C0D6可以获得观星计数(上限9)\n提升[0.9%*德丽莎变异]伤害加成\n提升[3%*德丽莎变异]暴击伤害\n提升[2%*观星数]暴击率\n提升[5%*观星数]暴击伤害|r\n|cFF3C61A5【观星】|r\n|cFFB0C0D6点击使用,冷却360秒\n每次使用随机获得以下1~4条效果持续至下一次观星\n1.提升[-3~5]幸运\n2.提升[-5%~10%]伤害加成\n3.提升[-15%~30%]经验获取\n4.提升[-5~10]体力上限\n5.提升[-2.5%~10%]全属性\n6.提升[-50~100]额外移速\n7.持续时间内杀敌提升0.005%~0.015%法术修正\n8.无视伤害闪避与伤害免疫\n9.飞行|r\n|cFF3C61A5【玄武】|r\n|cFFB0C0D6直接伤害附带[22222*观星数]灵力(法术)伤害，冷却[10-0.5*观星数]秒|r\n|cFF3C61A5【白虎】|r\n|cFFB0C0D6触发位移闪避时2秒内位移无使用冷却,冷却60秒|r\n|cFF3C61A5【八阵】|r\n|cFFB0C0D6解锁额外技能[八阵]|r",
    effectart = "Ewl_Dlsgx_01",
    test = [[

            ]]
  },
  {
    name = "炎之呼吸",
    clickfunc = function(u, var)
      local sy = u.ownerid
      if u:isalive() then
        local count = 0
        if not BossBattle then
          u:sendmessage("|cFFF95C24非BOSS战|r")
          return
        end
        if not u:ishasitem("I0MY") then
          u:sendmessage("|cFFF95C24未持有日轮刀[赤炎]|r")
          return
        end
        AdvanceGet["炼狱杏寿郎"](u)
      end
    end,
    weight = 5,
    key = {
      "唯一",
      "战士",
      "炎"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I0MY") then
        add = add + 500
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:getdata("水变异数量") == 0 and KillCount_Katana[u.ownerid] >= 50 then
        b = true
      end
      if u:ishasitem("I0MY") then
        b = true
      end
      if not u:hasdata("权限-炎之呼吸") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Dage_Get_02)
      u:chat("|cFFF95C24把他和鬼一起斩首！|r")
      ac.wait(1000, function()
        u:uivar_change({
          keyname = "炎之呼吸",
          keytype = "传奇栏",
          text = "|cFFF95C24炎|r|cFFF67C31之|r|cFFF49C3F呼|r|cFFF1BC4C吸|r\n|cFFFFAA00[传奇]|r\n|cFFF95C24唯一 战士 炎|r\n|cFFF1BC4C提升50%火属性伤害\n提升5%近战伤害\n提升[1%*背水]生命恢复|r\n|cFFF95C24【全集中.常中】|r\n|cFFF1BC4C提升0.1体力恢复\n杀敌时提升0.01%近战伤害\n直接伤害时恢复2%体力值,冷却0.5秒|r\n|cFFF95C24【一之型.不知火】|r\n|cFFF1BC4C提升[0.5%*炎变异]近战伤害\n免疫灼烧负面\n免疫燃烧抑制恢复\n直接伤害时对目标与自身施加一层灼烧,冷却1秒\n受到伤害时对目标与自身施加两层灼烧,冷却1秒\n对灼烧中目标,目标每层灼烧伤害提升0.5%,护甲效果降低[1+1%]\n自身每有一层灼烧所受伤害降低1%(上限25%)\n自身灼烧达到10层时,直接伤害时附带[10%*原始伤害值]火灵力伤害,触发冷却0.5秒\n自身灼烧达到15层时,无属性伤害变为炎属性伤害|r\n|cFFF95C24【贰之型.上升炎天】|r\n|cFFF1BC4C①主变异与次变异为战士或炎\n②持有日轮刀[赤炎]\n③BOSS战\n点击进阶为[神话]|r"
        })
      end)
      ChangeValue(Damage_Element_Fire, sy, 0.05)
      ChangeValue(Correction_Jzsh, sy, 0.05)
      ChangeValue(Hero_Tili_Huifu, sy, 0.1)
      local jz = 0
      u:addhealthrefresh(function(set_value, bs)
        set_value(HeroMenu_HpChange_MaxHp, sy, bs)
      end)
      ac.loop(1000, function()
        ChangeValue(Correction_Jzsh, sy, 0.1 * (-1 * jz))
        jz = 0.05 * u:getstate("炎变异")
        ChangeValue(Correction_Jzsh, sy, 0.1 * (1 * jz))
      end)
      u:setdata("系统-无视伤害闪避")
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        info.pk_jiaocuo = true
      end)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:getdata("灼烧层数") > 0 then
          info.end2 = info.end2 + 0.003 * tg:getdata("灼烧层数")
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效3冷却") then
          u:settimedata(var.name .. "-特效3冷却", 0.5)
          u:curetili(0.02 * Hero_Tili_Max[sy])
        end
        if not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 1)
          u:buffset(u.handle, 1, "灼烧")
          tg:buffset(u.handle, 1, "灼烧")
        end
        if u:getdata("灼烧层数") >= 10 and not u:hasdata(var.name .. "-特效2冷却") then
          u:settimedata(var.name .. "-特效2冷却", 0.5)
          local txsh = 0.1 * info.yssh
          DamageUnit({
            bj = "炎之呼吸(不知火)",
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
      end)
      u:addstexiao(var.name, "受伤后效果", function(args)
        local u = args.u
        local tg = args.tg
        if not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 1)
          u:buffset(u.handle, 2, "灼烧")
          tg:buffset(u.handle, 2, "灼烧")
        end
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        ChangeValue(Correction_Jzsh, sy, 1.0E-4)
      end)
    end,
    effectname = "|cFFF95C24炎|r|cFFF67C31之|r|cFFF49C3F呼|r|cFFF1BC4C吸|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFF95C24唯一 战士 炎|r\n|cFFF1BC4C提升5%火属性伤害\n提升5%近战伤害\n提升[1%*背水]生命恢复|r\n|cFFF95C24【全集中.常中】|r\n|cFFF1BC4C提升0.1体力恢复\n杀敌时提升0.01%近战伤害\n直接伤害时恢复2%体力值,冷却0.5秒|r\n|cFFF95C24【一之型.不知火】|r\n|cFFF1BC4C提升[0.5%*炎变异]近战伤害\n免疫灼烧负面\n免疫燃烧抑制恢复\n直接伤害时对目标与自身施加一层灼烧,冷却1秒\n受到伤害时对目标与自身施加两层灼烧,冷却1秒\n对灼烧中目标,目标每层灼烧伤害提升0.3%,护甲效果降低[1+1%]\n自身每有一层灼烧所受伤害降低1%(上限25%)\n自身灼烧达到10层时,直接伤害时附带[10%*原始伤害值]火灵力伤害,触发冷却0.5秒\n自身灼烧达到15层时,无属性伤害变为炎属性伤害|r",
    effectart = "Ewl_Chuanqi_Yanzhihuxi.tga",
    test = [[

            ]]
  },
  {
    name = "孤狼",
    clickfunc = function(u)
      local sy = u.ownerid
      if u:isalive() and not u:hasdata("孤狼-流浪客") and BossBattle then
        u:buffset(u.handle, 3, "绝对闪避")
        PlayBGM({
          bgm = BGM_Gulang,
          time = 300,
          ID = 81,
          unit = u.handle
        })
        u:chat("一直以来承蒙照顾，十分感谢")
        ac.wait(3000, function()
          u:chat("在下是流浪人")
        end)
        ac.wait(6000, function()
          u:chat("又要，再次上路了。")
        end)
        u:setdata("孤狼-流浪客")
        ChangeValue(Correction_Jzsh, sy, 0.1 * (-1 * u:getdata("孤狼-伤逝近战提升")))
        local add1 = 1.75 * u:getdata("孤狼-伤逝近战提升")
        local add2 = 5 * u:getdata("孤狼-伤逝生命降低")
        u:setdata("孤狼-伤逝近战提升", 0)
        u:setdata("孤狼-伤逝生命降低", 0)
        ChangeValue(Correction_Jzsh, sy, 0.1 * (1 * add1))
        u:changeoriginmaxhp(0.1 * (10 * add2))
        ac.wait(300000, function()
          u:deldata("孤狼-流浪客")
          ChangeValue(Correction_Jzsh, sy, 0.1 * (-1 * add1))
          u:changeoriginmaxhp(0.1 * (-10 * add2))
        end)
      else
        u:uivar_setcd({
          keyname = "孤狼",
          keytype = "传奇栏",
          nowcd = 1
        })
      end
    end,
    cd = 303,
    weight = 5,
    key = {"唯一"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I09H") then
        add = add + 2500
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("权限-孤狼") and u:ishasitem("I09H") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:sendmessage("|cFFC5B6B7漫长的堕落与无尽的空虚|r")
      local zj = 0
      local ys = 0
      ac.loop(250, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * zj))
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -1 * ys)
        if u:getdata("战斗时间") > 0 then
          ys = 0
          zj = 0.25
        else
          ys = 75
          zj = 0
        end
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 1 * ys)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * zj))
      end)
    end,
    effectname = "|cFFC5B6B7孤狼|r",
    effecttext = "|cFFC5B6B7坠影|r\n|cFFF2E2C6脱战时提升75额外移速\n战斗时提升2.5%伤害加成|r\n|cFFC5B6B7伤逝|r\n|cFFF2E2C6进入战斗后脱战时,提升[0.005%*本次战斗期间武士刀杀敌数的1.1次方]近战伤害并降低[本次战斗期间杀敌数*1]生命上限|r\n|cFFC5B6B7斩击格挡|r\n|cFFF2E2C6使用武士刀时获得0.12秒绝对闪避|r\n|cFFC5B6B7流浪客|r\n|cFFF2E2C6BOSS战时点击,消耗所有伤逝加成,提升[消耗值*1.75]武士刀伤害与[消耗生命上限*5]基础生命上限,持续300秒|r\n|cFF949596终曲方知回首\nby【零食】|r",
    effectart = "war3mapImported\\BTNEwl_Gulang_02"
  },
  {
    name = "美杜莎",
    weight = 100,
    key = {
      "唯一",
      "战士",
      "光明"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("物品-粉色墨镜") then
        add = add + 500
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("变异判定-Lily安娜") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Mds_03)
      SendMsgAll("|cFFA42960『|r|cFFA52A61S|r|cFFA52B63e|r|cFFA62C64r|r|cFFA72D65v|r|cFFA82F67a|r|cFFA83068n|r|cFFA9316At|r|cFFAA326B,|r|cFFAB336C |r|cFFAB346ES|r|cFFAC356Fa|r|cFFAD3670b|r|cFFAE3872e|r|cFFAE3973r|r|cFFAF3A75.|r|cFFB03B76我|r|cFFB13C77是|r|cFFB13D79美|r|cFFB23E7A杜|r|cFFB33F7B莎|r|cFFB4407D。|r|cFFB4427E…|r|cFFB54380…|r|cFFB64481哈|r|cFFB74582？|r|cFFB74684已|r|cFFB84785经|r|cFFB94886有|r|cFFBA4988不|r|cFFBA4B89少|r|cFFBB4C8B不|r|cFFBC4D8C是|r|cFFBD4E8D我|r|cFFBD4F8F的|r|cFFBE5090我|r|cFFBF5191在|r|cFFC05293这|r|cFFC05494里|r|cFFC15596了|r|cFFC25697？|r|cFFC35798为|r|cFFC3589A什|r|cFFC4599B么|r|cFFC55A9C？|r|cFFC65B9E…|r|cFFC65C9F…|r|cFFC75EA1实|r|cFFC85FA2话|r|cFFC960A3说|r|cFFC961A5很|r|cFFCA62A6麻|r|cFFCB63A7烦|r|cFFCC64A9啊|r|cFFCC65AA这|r|cFFCD67AC种|r|cFFCE68AD。|r|cFFCF69AE』|r", 30)
      u:adddivinity(1)
      u:getgoddessforce(2)
      local bs = 0
      local zj = 0
      local gl = 0
      local jz = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Baoshang, sy, -1 * bs)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * (-1 * zj))
        bs = 0.025 * u:getshenxing()
        zj = 0.02 * u:getdata("女神力")
        ChangeValue(DamageSystem_Baoshang, sy, 1 * bs)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * (1 * zj))
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * gl))
        ChangeValue(Correction_Jzsh, sy, 0.1 * (-1 * jz))
        if u:getdata("神性属性") == "原罪" then
          gl = 2.5
          jz = 2.5
        else
          gl = 0
          jz = 0
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * gl))
        ChangeValue(Correction_Jzsh, sy, 0.1 * (1 * jz))
      end)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        local sy2 = xq.ownerid
        ChangeValue(DamageSystem_Shjc, sy2, 0.02)
      end)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not tg:isnormal() then
          info.end3 = info.end3 + 0.09
        end
      end)
      AddAllSTexiao(var.name, "暴击系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:getdata("神性属性") == "原罪" then
          info.bjsh = info.bjsh + 0.5
        end
      end)
    end,
    effectname = "|cFFA62F65美|r|cFFAE3A74杜|r|cFFBE5193莎|r",
    effecttext = "|cFFA62F65唯一 战士 光明\n神性 1 女神力 2\n战争女神|r\n|cFFBE5193提升[女神力*0.2%]终结伤害\n提升[神性*2.5%]暴击伤害|r\n|cFFA62F65怪物的黄金剑|r\n|cFFBE5193对BOSS与精英提升9%伤害\n自身如果是[原罪]属性(原罪>神性),提升25%伤害加成与25%近战伤害|r\n|cFFA62F65魔之血脉|r\n|cFFBE5193提升全队2%伤害加成\n提升全队拥有[原罪值]单位50%暴击伤害|r",
    effectart = "BTNEwl_Mds_By.tga",
    test = [[
                15% + 30% 10% 20% 50% = 125%
            ]]
  },
  {
    name = "李逍遥",
    weight = 10,
    key = {"唯一"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("系统-特殊获取中") or Stage <= 1 then
        b = true
      end
      if not u:hasdata("隐藏职业-十里坡剑神") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cFFCCFFCC剑神|r" .. u:getplayername() .. "|cFFCCFFCC出山了！|r", 60)
      local add = 0.05 * Time_M
      ChangeValue(Correction_Jzsh, sy, 0.1 * add)
      ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      PlayBGM({
        bgm = BGM_Lixiaoyao,
        time = 160,
        ID = 201,
        unit = u.handle
      })
      SendMsgAll("|cFFCCFFCCBGM:仙剑奇缘|r")
      local cs = 0
      local jc = 0
      local xs = 2 + 0.075 * Time_M
      ac.loop(3000, function(timer)
        cs = cs + 1
        if cs == 20 then
          cs = 0
          ChangeValue(Correction_Jzsh, sy, 0.010000000000000002)
          ChangeValue(DamageSystem_Shjc, sy, 0.01)
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jc)
        jc = (DamageSystem_Shjc[sy] - 1) * xs
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * jc)
      end)
    end,
    effectname = "|cFF666666李|r|cFF808080逍|r|cFF999999遥|r",
    effecttext = "|cFF808080唯一|r\n|cFF999999提升[获取时游戏分钟数*5%]基础伤害\n提升[获取时游戏分钟数*0.5%]近战伤害\n伤害加成倍率结算为[200%+7.5%*获取时游戏分钟数]\n每60秒提升1%伤害加成与1%近战伤害|r",
    effectart = "Ewl_Cq_Lixiaoyao",
    test = "        "
  },
  {
    name = "加藤惠",
    weight = 1,
    key = {"唯一"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      add = add + 10 * (Stage - 1)
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("隐藏职业-路人女主") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("一起加油吧")
      PlayGlobalSound(Sound_Jiatenghui_01)
      if not u:hasdata("隐藏职业-路人女主揭露") then
        u:setdata("隐藏职业-路人女主揭露")
        hideproshow(u.handle)
      end
      if not u:hasdata("伊丝-过波奖励获取变异") then
        u:changedata("传奇数量", -1)
      end
      ac.loop(1000, function(timer)
        if Stage >= 12 then
          u:sendmessage("|cFFFFCCFF路人女主-获得神化位|r")
          ChangeValue(Hero_Shenhua_Left, sy, 1)
          timer:remove()
        end
      end)
    end,
    effectname = "|cFFFF6699加|r|cFFFF80B2藤|r|cFFFF99CC惠|r",
    effecttext = "|cFFFF6699唯一|r\n|cFFFF99CC不占用传奇位\n12波时获得一个神化位\n过波时触发以下任一效果:\n1.提升2神力承载上限\n2.提升1启动变异上限\n3.提升1一阶精神承载力\n4.提升1二阶精神承载力\n5.提升1局部身体变异上限\n6.提升1全身身体上限\n7.获得1点天赋点\n8.提升5级|r",
    effectart = "Ewl_Cq_Jiatinghui",
    test = "        "
  },
  {
    name = "喵露露",
    weight = 1,
    key = {
      "唯一",
      "兽",
      "白毛"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      add = add + 10 * u:getdata("兽变异数量")
      if TID[sy] == "1727559346" then
        add = add + 500
      end
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("隐藏职业-喵星人") then
        b = true
      end
      if TID[sy] == "1727559346" then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:sendmessage("|cFFFF99FF获得喵露露|r")
      if not u:hasdata("隐藏职业-喵星人已揭露") then
        u:setdata("隐藏职业-喵星人已揭露")
        hideproshow(u.handle)
      end
      u:changedata("敏捷增幅", 0.125)
      ChangeValue(DamageSystem_Baoji, sy, 22)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 100)
      ChangeValue(Correction_Jzsh, sy, 0.05)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        local add = 4 * u:getdata("兽变异数量")
        u:addagi(add)
        local add2 = 0.02 * u:getdata("兽变异数量")
        ChangeValue(Correction_Jzsh, sy, 0.1 * add2)
      end)
      local lw = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -lw)
        lw = 0.1 * u:getstate("兽变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * lw)
      end)
      if u:hasdata("变异判定-莉莉娅") and not u:hasdata("伊丝-过波奖励获取变异") then
        u:changedata("传奇数量", -1)
      end
      u:addstexiao(var.name, "位移技能后效果", function(args)
        if not u:hasdata("喵露露-猫翻滚") and not u:hasdata("喵露露-猫翻滚冷却") then
          u:settimedata("喵露露-猫翻滚", 1)
        end
      end)
      u:addtrgevent("单位-指定点目标指令", function(args)
        if args.orderid == String2OrderIdBJ("smart") and u:hasdata("喵露露-猫翻滚") and not u:hasdata("莉莉娅-猫翻滚") then
          u:deldata("喵露露-猫翻滚")
          u:settimedata("喵露露-猫翻滚冷却", 1)
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          local mjl = 500
          if dis >= mjl then
            dis = mjl
          end
          Effectcreate("Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl", x, y)
          Effectcreate("war3mapImported\\blackblink.mdx", x, y)
          Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
          Effectcreate("war3mapImported\\bbb.mdx", x, y)
          u:buffset(u.handle, 0.15, "绝对闪避")
          unitmove({
            unit = u.handle,
            time = 0.15,
            distance = dis,
            angle = angle,
            endfunc = function(dx, dy)
              Effectcreate("Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl", dx, dy)
              Effectcreate("war3mapImported\\blackblink.mdx", dx, dy)
              u:setdata("位移点X", dx)
              u:setdata("位移点Y", dy)
            end,
            isblink = true
          })
        end
      end)
    end,
    effectname = "|cFFFF99FF喵|r|cFFFFB2FF露|r|cFFFFCCFF露|r",
    effecttext = "|cFFFFCCFF兽 白毛 唯一\n升级时提升[4*兽变异数量]点敏捷与[0.2%*兽变异数量]近战伤害\n提升12.5%敏捷\n提升22%暴击率\n提升5%近战伤害\n提升[1%*兽变异]伤害加成\n提升100额外移速|r\n|cFFFF99FF猫翻滚|r\n|cFFFFCCFF位移技能结束0.5秒内可以进行一次500码的位移\n并获得0.15秒绝对闪避,冷却1秒;装备咸鱼时会发动拔鱼斩|r\n|cFFFF99FF咸鱼喵喵|r\n|cFFFFCCFF与[莉莉娅]共用传奇位|r",
    effectart = "war3mapImported\\BTNYcPro_08_02",
    test = [[

        ]]
  },
  {
    name = "莉莉娅",
    weight = 1,
    key = {"唯一", "兽"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      add = add + 10 * u:getdata("兽变异数量")
      if TID[sy] == "1727559346" then
        add = add + 500
      end
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("隐藏职业-喵星人") then
        b = true
      end
      if TID[sy] == "1727559346" then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:sendmessage("|cFFFFFF99获得莉莉娅|r")
      if not u:hasdata("隐藏职业-喵星人已揭露") then
        u:setdata("隐藏职业-喵星人已揭露")
        hideproshow(u.handle)
      end
      u:changedata("力量增幅", 0.125)
      u:changedata("敏捷增幅", 0.125)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 200)
      ChangeValue(Damage_Touzhiwu, sy, 10)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        local add = 2 * u:getdata("兽变异数量")
        u:addstr(add)
        u:addagi(add)
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        if not u:hasdata(var.name .. "-特效冷却") then
          local u = args.u
          local tg = args.tg
          local txsh = (u:getstr() + u:getagi()) * 100 * u:getstate("兽变异")
          u:settimedata(var.name .. "-特效冷却", 0.5)
          DamageUnit({
            bj = "莉莉娅(附伤)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
        end
      end)
      if u:hasdata("变异判定-喵露露") and not u:hasdata("伊丝-过波奖励获取变异") then
        u:changedata("传奇数量", -1)
      end
      u:addstexiao(var.name, "位移技能后效果", function(args)
        if not u:hasdata("莉莉娅-猫翻滚") and not u:hasdata("莉莉娅-猫翻滚冷却") then
          u:settimedata("莉莉娅-猫翻滚", 1)
        end
      end)
      u:addtrgevent("单位-指定点目标指令", function(args)
        if args.orderid == String2OrderIdBJ("smart") and u:hasdata("莉莉娅-猫翻滚") then
          u:deldata("莉莉娅-猫翻滚")
          u:settimedata("莉莉娅-猫翻滚冷却", 5)
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          local mjl = 1200
          if dis >= mjl then
            dis = mjl
          end
          Effectcreate("Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl", x, y)
          Effectcreate("war3mapImported\\blackblink.mdx", x, y)
          Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
          Effectcreate("war3mapImported\\bbb.mdx", x, y)
          u:buffset(u.handle, 0.15, "绝对闪避")
          unitmove({
            unit = u.handle,
            time = 0.15,
            distance = dis,
            angle = angle,
            endfunc = function(dx, dy)
              u:setdata("莉莉娅-近战加强")
              u:useweapon()
              u:deldata("莉莉娅-近战加强")
              Effectcreate("Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl", dx, dy)
              Effectcreate("war3mapImported\\blackblink.mdx", dx, dy)
              u:setdata("位移点X", dx)
              u:setdata("位移点Y", dy)
            end,
            isblink = true
          })
        end
      end)
    end,
    effectname = "|cFFFFFF99莉|r|cFFFFBF8C莉|r|cFFFF8080娅|r",
    effecttext = "|cFFFF8080兽 唯一\n升级时提升[2*兽变异数量]点敏捷与力量\n提升12.5%力量\n提升12.5%敏捷\n投掷物伤害提升1000%\n提升200额外移速\n直接伤害时附带[(力量+敏捷)*100*兽变异]物理伤害，触发冷却0.5秒|r\n|cFFFFFF99猫翻滚|r\n|cFFFF8080位移技能结束1秒内可以进行一次1200码的位移并获得0.15秒绝对闪避\n,在落点处发动一次近战攻击,并提升该次近战攻击15%近战伤害,冷却5秒|r\n|cFFFFFF99咸鱼喵喵|r\n|cFFFF8080与[喵露露]共用传奇位|r",
    effectart = "war3mapImported\\BTNYcPro_08_01",
    test = [[

        ]]
  },
  {
    name = "比斯莫克",
    weight = 500,
    key = {"唯一"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("变异判定-白银城主") and u:hasdata("隐藏职业-都市之子") and (u:isinrect(RECT_Feichengqu) or u:isinrect(RECT_Feichezhan) or u:isinrect(RECT_Feichangqu)) then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:sendmessage("|cFF95929D您|r|cFF9B98A2好|r|cFFA29EA6…|r|cFFA8A4AB…|r|cFFAEAAB0这|r|cFFB4B0B4是|r|cFFBAB7B9您|r|cFFC1BDBE的|r|cFFC7C3C2指|r|cFFCDC9C7令|r|cFFD4CFCC。|r")
      u:playselfsound(Sound_Dushizhizi)
      hideproshow(u.handle)
      u:setdata("都市之子-飞行")
      u:createrectfogcorrector(RECT_Feichengqu)
      u:createrectfogcorrector(RECT_Feichezhan)
      u:createrectfogcorrector(RECT_Feichangqu)
      ac.loop(1000, function()
        if u:isinrect(RECT_Feichengqu) or u:isinrect(RECT_Feichezhan) or u:isinrect(RECT_Feichangqu) then
          u:setdata("比斯莫克-处于城区")
        else
          u:deldata("比斯莫克-处于城区")
        end
      end)
      local st = 0
      ac.loop(3000, function()
        if st ~= Stage then
          ForGroupLuaNew(Group_PlayHero, function(xq)
            local sy2 = xq.ownerid
            local count = xq:getdata("比斯莫克-传令效果")
            if count == 1 then
              ChangeValue(DamageSystem_Shjc, sy2, -0.1)
            end
            if count == 2 then
              ChangeValue(DamageSystem_Ssjianshao, sy2, 0.5, 2)
            end
            if count == 3 then
              xq:deldata("传令员-降低抗药性获取")
            end
            if count == 4 then
              ChangeValue(Hero_Tili_Huifu, sy2, -0.25)
            end
          end)
          ForGroupLuaNew(Group_PlayHero, function(xq)
            local sy2 = xq.ownerid
            local count = GetRandomInt(1, 4)
            xq:setdata("比斯莫克-传令效果", count)
            if count == 1 then
              xq:sendmessage("|cFF9997A4传令员-提升10%伤害加成|r")
              ChangeValue(DamageSystem_Shjc, sy2, 0.1)
            end
            if count == 2 then
              xq:sendmessage("|cFF9997A4传令员-提升50%论外减伤|r")
              ChangeValue(DamageSystem_Ssjianshao, sy2, 0.5, 1)
            end
            if count == 3 then
              xq:sendmessage("|cFF9997A4传令员-降低25%抗药性获取|r")
              xq:setdata("传令员-降低抗药性获取")
            end
            if count == 4 then
              xq:sendmessage("|cFF9997A4传令员-提升0.25体力恢复|r")
              ChangeValue(Hero_Tili_Huifu, sy2, 0.25)
            end
          end)
          st = Stage
        end
      end)
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and u:hasdata("比斯莫克-处于城区") and not u:hasdata("比斯莫克-决死冷却") then
          args.dt = false
          u:settimedata("比斯莫克-决死冷却", 180)
          u:buffset(u.handle, 0.5, "绝对闪避")
          u:sendmessage("|cFF9997A4比斯莫克-都市之子|r")
        end
      end)
    end,
    effectname = "|cFF9997A4比斯|r|cFFF4EBE6莫克|r",
    effecttext = "|cFF9997A4传令员|r\n|cFFF4EBE6每波开始清除已给予Buff并随机施加给所有玩家随机一种下列效果:\n①提升10%伤害加成\n②提升50%论外减伤\n③降低25%抗药性获取\n④提升0.25体力恢复|r\n|cFF9997A4都市之子|r\n|cFFF4EBE6获得城市区域的视野\n飞行\n处于城市区域时：\n每隔180秒抵挡一次致死伤害并获得0.5秒绝对闪避\n提升20%药水成功率\n33%物品获取数量+1|r",
    effectart = "BTNEwl_Chuanqi_Dushizhizi",
    test = [[

            ]]
  },
  {
    name = "以实玛利黑云",
    weight = 100,
    lv = 2,
    key = {"唯一", "战士"},
    unique = true,
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
      ciyuanget(u, var)
      PlayGlobalSound(Sound_YsmlHy_01)
      u:chat("|cFFEA9950有事找我的话请过会再来吧")
      u:chat("|cFFEA9950我清洁刀刃时不想被人打扰", 4.1)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata("以实玛利-纳刀冷却") then
          if not u:hasdata("以实玛利-纳刀切换") then
            u:setdata("以实玛利-纳刀切换")
            tg:buffset(u.handle, 3, "流血")
            Buff_LiuxueQiangdu(u, tg, 1)
          else
            Buff_LiuxueQiangdu(u, tg, 2)
            u:deldata("以实玛利-纳刀切换")
            u:settimedata("以实玛利-纳刀冷却", 3)
          end
        end
      end)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not info.isvestdamage and not u:hasdata("以实玛利-锋芒毕露冷却") then
          u:settimedata("以实玛利-锋芒毕露冷却", 4)
          tg:buffset(u.handle, 2, "流血")
          Buff_LiuxueQiangdu(u, tg, 2)
        end
        if not u:hasdata("以实玛利-黑云翻墨冷却") and u:getluckrandom(3 * info.txgl) then
          u:settimedata("以实玛利-黑云翻墨冷却", 6)
          Buff_LiuxueRun(u, tg, 3)
        end
      end)
    end,
    effectname = "|cFFEA9950以|r|cFFD89254实|r|cFFC58B57玛|r|cFFB3845B利|r|cFFA07E5E(|r|cFF8E7762黑|r|cFF7B7065云|r|cFF696969)|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFFEA9950唯一 战士|r\n|cFFEA9950【血振纳刀】|r\n|cFF696969直接伤害时施加1级[流血强度]与3层[流血层数]并\n使下一次直接伤害施加2级[流血强度],\n触发二段效果后该效果进入冷却3秒|r\n|cFFEA9950【锋芒毕现】|r\n|cFF696969近战直接伤害施加2级[流血强度]与2层[流血层数],冷却4秒|r\n|cFFEA9950【黑云翻墨】|r\n|cFF696969近战武器或近战伤害(30%/3%)使目标[流血]触发3次且不消耗层数,冷却6秒|r",
    effectart = "Cq_Ysml_Heiyun",
    test = "            "
  },
  {
    name = "重岳",
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "龙",
      "土"
    },
    unique = true,
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
      ciyuanget(u, var)
      u:become("岁")
      PlayGlobalSound(Sound_Chongyue_01)
      SendMsgAll("|cFF977E5D『你称呼我“重岳”便好......是位故人取的名字』|r")
      ChangeValue(Damage_Type_Wuli, sy, 0.1)
      u:changearmor(25)
      u:changemaxhp(1500)
      u:addstexiao(var.name, "进入战斗状态时", function(args)
        local u = args.u
        if not u:hasdata(var.name .. "-入战语音冷却") then
          u:settimedata(var.name .. "-入战语音冷却", 60)
          local zu = {
            {
              text = "城头的烽火，总是这样熄了又燃。",
              sound = Sound_Chongyue_Rz_01
            },
            {
              text = "日落飞锦绣长河，天地壮我行色。",
              sound = Sound_Chongyue_Rz_02
            },
            {
              text = "征蓬未定，甲胄在身。",
              sound = Sound_Chongyue_Rz_03
            },
            {
              text = "看看这眼前，风光无限，可惜作了战场",
              sound = Sound_Chongyue_Rz_04
            },
            {
              text = "多少迁客骚人，直到身临沙场，才能写出好句子",
              sound = Sound_Chongyue_Rz_05
            }
          }
          local sj = GetRandomInt(1, #zu)
          u:playseensound(zu[sj].sound)
          u:chat("|cFF977E5D" .. zu[sj].text)
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        u:changedata("重岳-我无计数", 1)
        if u:getdata("重岳-我无计数") > 5 and not u:hasdata(var.name .. "-特效冷却") then
          u:setdata("重岳-我无计数", 0)
          u:settimedata(var.name .. "-特效冷却", 0.25)
          if not u:hasdata("系统-清净模式") then
            local zu = {
              Sound_Chongyue_Ww_01,
              Sound_Chongyue_Ww_02,
              Sound_Chongyue_Ww_03,
              Sound_Chongyue_Ww_04
            }
            for index, value in ipairs(zu) do
              StopSoundBJ(value, false)
            end
            u:playseensound(zu[GetRandomInt(1, #zu)])
          end
          local txsh = 2000 * u:getlevel()
          DamageUnit({
            bj = "重岳(我无)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "土",
            extradata = {}
          })
          tg:effectadd("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl")
        end
        if not tg:hasdata(var.name .. "-特效3冷却") and u:getluckrandom(5 * info.txgl) then
          tg:settimedata(var.name .. "-特效3冷却", 1.5)
          tg:buffset(u.handle, 1, "僵直")
        end
      end)
      u:addstexiao(var.name, "伤害判定后特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效2冷却") and tg:getperhp() >= 90 then
          u:settimedata(var.name .. "-特效2冷却", 3)
          DamageUnit({
            bj = "重岳(冲盈)",
            unit = tg.handle,
            source = u.handle,
            damage = info.yssh * 2,
            level = 1,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
        end
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        u:curetili(1)
        if tg:isboss() then
          local zu = {
            {
              text = "从容落子，布局谋胜",
              sound = Sound_Chongyue_KB_01
            },
            {
              text = "征鼓一声千军动，掬罢黄沙浣铁衣",
              sound = Sound_Chongyue_KB_02
            },
            {
              text = "兵戈相向，伐谋利好，从来就没有真正的输赢，更难断真正的功过，无愧于心就好",
              sound = Sound_Chongyue_KB_03
            }
          }
          local sj = GetRandomInt(1, #zu)
          PlayGlobalSound(zu[sj].sound)
          u:chat("|cFF977E5D" .. zu[sj].text)
        end
      end)
    end,
    effectname = "|cFF977E5D重|r|cFFE7DFD6岳|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF977E5D唯一 龙 土|r\n|cFF977E5D【冲盈】|r\n|cFFE7DFD6对生命值≥90%单位造成伤害时附带[200%]物理伤害,冷却3秒|r\n|cFF977E5D【拂尘】|r\n|cFFE7DFD6直接伤害时5%僵直目标1秒(独立冷却1.5秒)|r\n|cFF977E5D【我无】|r\n|cFFE7DFD6每5次直接伤害,下一次直接伤害附带[等级*2000]土物理伤害\n(最小冷却0.25秒)|r\n|cFF977E5D【自晦及明】|r\n|cFFE7DFD6提升10%物理伤害\n提升25护甲\n提升1500生命上限\n杀敌时恢复1体力值|r",
    effectart = "Cq_Chongyue",
    test = "            "
  },
  {
    name = "烟雾镜",
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "光明",
      "战士",
      "同奏"
    },
    unique = true,
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
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Ywj_Hq)
      SendMsgAll("|cFFE8D9B0『|r|cFFDED3B2哟|r|cFFD4CDB4！|r|cFFC9C7B7』|r")
      SendDtimeMsgAll(1.2, "|cFFE8D9B0『|r|cFFE4D7B1你|r|cFFE1D5B2就|r|cFFDDD3B2是|r|cFFD9D0B3御|r|cFFD6CEB4主|r|cFFD2CCB5？|r|cFFCFCAB5请|r|cFFCBC8B6多|r|cFFC7C6B7关|r|cFFC4C4B8照|r|cFFC0C1B9。|r|cFFBCBFB9』|r")
      SendDtimeMsgAll(5.3, "|cFFE8D9B0『|r|cFFE6D8B0从|r|cFFE3D6B1者|r|cFFE1D5B2，|r|cFFDFD4B2A|r|cFFDCD2B2s|r|cFFDAD1B3s|r|cFFD8CFB4a|r|cFFD5CEB4s|r|cFFD3CDB4s|r|cFFD1CBB5i|r|cFFCFCAB6n|r|cFFCCC9B6，|r|cFFCAC7B6特|r|cFFC8C6B7斯|r|cFFC5C5B8卡|r|cFFC3C3B8特|r|cFFC1C2B8利|r|cFFBEC0B9波|r|cFFBCBFBA卡|r|cFFBABEBA』|r")
      u:become("从者")
      u:adddivinity(1)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        local sy2 = xq.ownerid
        ChangeValue(DamageSystem_Shjc, sy2, 0.1)
      end)
      u:addstexiao(var.name, "进入战斗状态时", function(args)
        local u = args.u
        if not u:hasdata(var.name .. "-入战冷却") then
          u:settimedata(var.name .. "-入战冷却", 60)
          SendMsgAll("|cFFE8D9B0[烟雾镜]黑之太阳|r")
          local zu = {
            Sound_Ywj_2_01,
            Sound_Ywj_2_02
          }
          u:settimedata("烟雾镜-黑之太阳加成", 15)
          PlayGlobalSound(zu[GetRandomInt(1, #zu)])
          ForGroupLuaNew(Group_PlayHero, function(xq)
            local sy2 = xq.ownerid
            xq:buffset(u.handle, 2, "绝对闪避")
            ChangeTimeValue(DamageSystem_Shjc, sy2, 0.25, 15)
          end)
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          if u:hasdata("烟雾镜-黑之太阳加成") then
            u:settimedata(var.name .. "-特效冷却", 0.5)
          else
            u:settimedata(var.name .. "-特效冷却", 3)
          end
          if not u:hasdata("系统-清净模式") then
            local zu = {
              Sound_Ywj_1_01,
              Sound_Ywj_1_02,
              Sound_Ywj_1_03,
              Sound_Ywj_1_04,
              Sound_Ywj_1_05,
              Sound_Ywj_1_06,
              Sound_Ywj_1_07,
              Sound_Ywj_1_08,
              Sound_Ywj_1_09,
              Sound_Ywj_1_10,
              Sound_Ywj_1_11,
              Sound_Ywj_1_12,
              Sound_Ywj_1_13
            }
            u:playseensound(zu[GetRandomInt(1, #zu)])
          end
          local txsh = 100000
          DamageUnit({
            bj = "烟雾镜(斗争魅力)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "震荡",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无",
            extradata = {}
          })
          tg:effectadd("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl")
          tg:buffset(u.handle, 1, "眩晕")
        end
      end)
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and not u:hasdata(var.name .. "-决死冷却") then
          args.dt = false
          u:sendmessage("|cFFE8D9B0[烟雾镜]山之心脏决死|r")
          u:settimedata(var.name .. "-决死冷却", 360)
          u:settimedata("烟雾镜-死亡抗拒", 3)
        end
      end)
    end,
    effectname = "|cFFE8D9B0特|r|cFFE0D4B2斯|r|cFFD7CFB4卡|r|cFFCECAB6特|r|cFFC6C5B7利|r|cFFBEC0B9波|r|cFFB5BBBB卡|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFE8D9B0唯一 光明 战士 同奏\n神性 1|r\n|cFFB5BBBB提升全队10%伤害加成|r\n|cFFE8D9B0【斗争魅力】|r\n|cFFB5BBBB直接伤害时10%附带[100000]震荡伤害与1秒眩晕,冷却3秒\n如果处于[黑之太阳]加成状态,则只有0.5秒冷却|r\n|cFFE8D9B0【黑之太阳】|r\n|cFFB5BBBB入战时:\n[提升全队25%伤害加成与2秒绝对闪避\n持续15秒\n冷却60秒]|r\n|cFFE8D9B0【山之心脏】|r\n|cFFB5BBBB受到致死伤害时抵挡该次伤害并死亡抗拒3秒,冷却360秒|r",
    effectart = "Cq_Ywj",
    test = "            "
  },
  {
    name = "莉贝尔",
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "黑暗",
      "魔导",
      "龙"
    },
    unique = true,
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
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Lbe_01)
      SendMsgAll("|cFF61D1DE『|r|cFF60CFDF莉|r|cFF5FCCDF贝|r|cFF5ECAE0尔|r|cFF5DC8E0·|r|cFF5CC5E1碧|r|cFF5BC3E2布|r|cFF5BC0E2里|r|cFF5ABEE3欧|r|cFF59BCE4提|r|cFF58B9E4克|r|cFF57B7E5，|r|cFF56B4E6是|r|cFF55B2E6深|r|cFF54B0E7渊|r|cFF53ADE7书|r|cFF52ABE8库|r|cFF51A9E9的|r|cFF50A6E9管|r|cFF50A4EA理|r|cFF4FA2EA系|r|cFF4E9FEB统|r|cFF4D9DEC』|r")
      ChangeValue(Damage_Element_Dark, sy, 0.25)
      ac.loop(30000, function()
        if not Movie_Boolean and u:isalive() and u:getluckrandom(10) then
          u:sendmessage("|cFF61D1DE[莉贝尔]深渊状态")
          local snd = {
            Sound_Lbe_04,
            Sound_Lbe_02,
            Sound_Lbe_03
          }
          u:playseensound(snd[GetRandomInt(1, #snd)])
          u:settimedata("莉贝尔-深渊状态", 29.9)
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("莉贝尔-深渊状态") and not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 0.1)
          local txsh = 1000 * u:getlevel()
          DamageUnit({
            bj = "莉贝尔(深渊书库)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "暗",
            extradata = {"法术", "魔导"}
          })
        end
      end)
      u:addstexiao(var.name, "伤害判定后效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if info.damagetype == "魔力" and not u:hasdata(var.name .. "-魔障冷却") then
          u:settimedata(var.name .. "-魔障冷却", 10)
          tg:settimedata("莉贝尔-魔障", 10)
          local snd = {
            Sound_Lbe_06
          }
          if GetRandom100(25) then
            u:playseensound(snd[GetRandomInt(1, #snd)])
          end
        end
      end)
      AddAllSTexiao(var.name, "直接伤害变更", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if info.damagetype == "魔力" and tg:hasdata("莉贝尔-魔障") then
          args.shadd = args.shadd + 0.1
        end
      end)
      u:addstexiao(var.name, "过波时效果", function(args)
        ChangeValue(DamageSystem_Shjc, sy, 0.07)
        ChangeValue(Damage_Element_Dark, sy, 0.07)
      end)
    end,
    effectname = "|cFF61D1DE莉|r|cFF56B4E6贝|r|cFF4B98ED尔|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF61D1DE唯一 龙 黑暗 魔导|r\n|cFF4B98ED提升25%暗属性伤害|r\n|cFF61D1DE【深渊书库管理者】|r\n|cFF4B98ED每30秒10%进入[深渊状态]持续30秒:\n[无属性伤害造成暗属性伤害\n直接伤害时附带[等级*1000]暗魔力(法术,魔导)伤害,冷却0.1秒]|r\n|cFF61D1DE【禁断索引】|r\n|cFF4B98ED造成魔力伤害时,施加10秒[魔障]状态,冷却10秒|r\n|cFF61D1DE【七罪灾厄】|r\n|cFF4B98ED过波时提升7%暗属性伤害与7%伤害加成|r",
    effectart = "Cq_Libeier",
    test = "            "
  },
  {
    name = "贝尔赛蒂亚",
    weight = 100,
    lv = 3,
    key = {
      "黑暗",
      "外域",
      "星"
    },
    unique = false,
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
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Anmonv_01)
      u:chat("|cFF6633FF即使是在黑暗中，也有只伸手一摸就能理解的事物。|r")
      ac.wait(6100, function()
        u:chat("|cFF6633FF所以……不要害怕黑暗哦？|r")
      end)
      u:changedata("效果增强-背水", 0.13)
      ac.loop(6000, function()
        if u:isalive() then
          hdzlinshiadd(u, 0.01 * u:getmaxhp())
        end
      end)
      local data1 = 0
      local data2 = 0
      
      local function refresh_saijier_bonus()
        ChangeValue(Damage_Element_Dark, sy, -data2)
        local citiao1 = u:getstate("黑暗变异")
        data2 = 0.005 * citiao1
        ChangeValue(Damage_Element_Dark, sy, data2)
      end
      
      refresh_saijier_bonus()
      ac.loop(3000, refresh_saijier_bonus)
      u:addhealthrefresh(function(set_value, bs)
        set_value(DamageSystem_Shjc, sy, 0.03 * u:getstate("黑暗变异") * bs)
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 8)
          local txsh = 10000 * u:getstate("背水") * u:getstate("黑暗变异")
          local g = CreateGroupLua()
          local x, y = u:getxy()
          local angle = u:getface()
          for i = 1, 10 do
            local dx, dy = PolarXY(x, y, i * 100, angle)
            for _, xq in ac.selector():in_rangexy(dx, dy, 300):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g)
            end
          end
          ForGroupLuaNew(g, function(xq)
            DamageUnit({
              bj = "贝尔赛蒂亚(宙域穿刺)",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "反物质",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "暗"
            })
          end)
        end
      end)
    end,
    effectname = "|cFF6633FF贝|r|cFF6653FF尔|r|cFF6572FE赛|r|cFF6492FE蒂|r|cFF64B2FE亚|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF6633FF黑暗 外域 星|r\n|cFF64B2FE提升[黑暗变异*背水*3%]伤害加成\n提升[黑暗变异*0.5%]暗属性伤害|r\n|cFF6633FF【次元魔女】|r\n|cFF64B2FE提升13%背水效果\n每6秒获得[最大生命值*1%]临时护盾值|r\n|cFF6633FF【宙域穿刺】|r\n|cFF64B2FE直接伤害时附带[10000*黑暗变异*背水]暗反物质直线伤害,冷却8秒|r",
    effectart = "Ewl_Chuanqi_Besdy_13",
    test = "            "
  },
  {
    name = "阿尔法",
    weight = 100,
    lv = 3,
    key = {
      "机械",
      "战士",
      "影"
    },
    unique = false,
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
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Shenhongzhiyuan_01)
      SendMsgAll("|cFFCC0000『|r|cFFC80404强|r|cFFC50707制|r|cFFC10B0B连|r|cFFBE0E0E接|r|cFFBA1212成|r|cFFB71515功|r|cFFB31919—|r|cFFB01C1C—|r|cFFAC2020从|r|cFFA92323现|r|cFFA52727在|r|cFFA22A2A开|r|cFF9E2E2E始|r|cFF9B3131，|r|cFF973535你|r|cFF943838会|r|cFF903C3C一|r|cFF8D3F3F直|r|cFF894343在|r|cFF864646我|r|cFF824A4A的|r|cFF7F4D4D视|r|cFF7B5151线|r|cFF785454之|r|cFF745858中|r|cFF715B5B。|r|cFF6D5F5F』|r")
      u:addskill("S0BD")
      ChangeValue(DamageSystem_Baoji, sy, 10)
      ChangeValue(DamageSystem_EndSh, sy, 0.01)
      local jz_bonus = 0
      local damage_bonus = 0
      
      local function refresh_saijier_bonus()
        ChangeValue(DamageSystem_Shjc, sy, -damage_bonus)
        ChangeValue(Correction_Jzsh, sy, -jz_bonus)
        damage_bonus = 0.01 * u:getstate("机械变异")
        jz_bonus = 0.005 * u:getstate("战士变异")
        ChangeValue(Correction_Jzsh, sy, jz_bonus)
        ChangeValue(DamageSystem_Shjc, sy, damage_bonus)
      end
      
      refresh_saijier_bonus()
      ac.loop(3000, refresh_saijier_bonus)
      u:addstexiao(var.name, "近战伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not info.isvestdamage then
          if not u:hasdata("阿尔法-缭乱冷却") then
            if u:getdata("阿尔法-缭乱计数") >= 3 then
              u:settimedata("阿尔法-缭乱冷却", 1)
              u:setdata("阿尔法-缭乱计数", 0)
              DamageUnit({
                bj = "阿尔法(缭乱)",
                unit = tg.handle,
                source = u.handle,
                damage = 1 * info.yssh,
                level = 1,
                type = "物理",
                isvest = true,
                isattack = true,
                isnoarmor = false,
                element = "无"
              })
            else
              u:changedata("阿尔法-缭乱计数", 1)
            end
          end
          if not u:hasdata("阿尔法-特效冷却") then
            u:settimedata("阿尔法-特效冷却", 0.25)
            for i = 1, 2 do
              DamageUnit({
                bj = "阿尔法(碎光散)",
                unit = tg.handle,
                source = u.handle,
                damage = 0.1 * info.yssh,
                level = 1,
                type = "物理",
                isvest = true,
                isattack = true,
                isnoarmor = false,
                element = "无"
              })
            end
          end
        end
      end)
      u:setdata("阿尔法-剩余近战加成", 1)
      u:addstexiao(var.name, "过波时效果", function(args)
        if u:getdata("阿尔法-剩余近战加成") > 0 then
          u:changedata("阿尔法-剩余近战加成", -0.1)
          ChangeValue(Correction_Jzsh, sy, 0.010000000000000002)
          u:sendmessage("|cFFCC0000[阿尔法-心剑]提升1%近战伤害")
        end
      end)
    end,
    effectname = "|cFFCC0000阿|r|cFFCC3333尔|r|cFFCC6666法|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFCC0000影 机械 战士|r\n|cFFCC6666提升[战士变异*0.5%]近战伤害\n提升[机械变异*1%]伤害加成|r\n|cFFCC0000【烁华·缭乱·碎光散】|r\n|cFFCC6666提升13%移速\n每3段近战直接伤害附带一次[100%]近战物理伤害,冷却1秒\n近战直接伤害附带2次[10%]近战物理伤害,冷却0.25秒|r\n|cFFCC0000【居合意】|r\n|cFFCC6666装备武士刀时:\n【绝对闪避成功时立刻使用当前近战武器,触发冷却3秒】|r\n|cFFCC0000【深渊共鸣】|r\n|cFFCC6666提升10%暴击率\n提升1%终结伤害|r",
    effectart = "Ewl_Chuanqi_Aerfa_7",
    test = "            "
  },
  {
    name = "赛吉尔",
    weight = 100,
    lv = 3,
    key = {"黑暗"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:ishasskill(SKILL_TESHUYINGXIONG) then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Saijier_01)
      u:chat("|cFF846496现在的我能做到的并不多|r")
      ac.wait(3300, function()
        u:chat("|cFF846496所以必须一点一点去积累才行|r")
      end)
      local gun_bonus = 0
      local damage_bonus = 0
      
      local function refresh_saijier_bonus()
        ChangeValue(Correction_Gun, sy, 0.1 * -gun_bonus)
        ChangeValue(DamageSystem_Shjc, sy, -damage_bonus)
        local dark_mutation = u:getstate("黑暗变异")
        gun_bonus = 0.05 * dark_mutation
        damage_bonus = 0.01 * dark_mutation
        ChangeValue(Correction_Gun, sy, 0.1 * gun_bonus)
        ChangeValue(DamageSystem_Shjc, sy, damage_bonus)
      end
      
      refresh_saijier_bonus()
      ac.loop(3000, refresh_saijier_bonus)
      u:addstexiao(var.name, "暴击系统触发效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        info.damage = info.damage * 1.07
        if u:hasdata("赛吉尔-暴击加强") then
          info.bjsh = info.bjsh + 0.5
        end
      end)
      local z = 0
      ac.loop(3000, function()
        z = 555 * u:getstate("黑暗变异")
      end)
      u:addstexiao(var.name, "子弹伤害前效果", function(args)
        u:setdata("赛吉尔-暴击加强")
        args.damage = args.damage + z
      end)
      u:addstexiao(var.name, "子弹伤害后效果", function(args)
        u:deldata("赛吉尔-暴击加强")
        local tg = args.tg
        local u = args.u
        local txsh = 122 * u:getlevel()
        DamageUnit({
          bj = "赛吉尔(黑色子弹)",
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
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        if not tg:isnormal() then
          ChangeValue(Correction_Gun, sy, 0.005000000000000001)
        end
      end)
    end,
    effectname = "|cFF643A7C赛|r|cFF846496吉|r|cFFA58FB1尔|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF643A7C黑暗|r\n|cFFA58FB1提升[黑暗变异*0.5%]枪械伤害\n提升[黑暗变异*1%]伤害加成|r\n|cFF643A7C【黑色子弹】|r\n|cFFA58FB1提升[555*黑暗变异]子弹基础伤害\n枪械伤害附带[等级*122]暗魔力伤害|r\n|cFF643A7C【死线之鹰眼】|r\n|cFFA58FB1提升7%暴击伤害(独立)\n枪械伤害提升50%暴击伤害|r",
    effectart = "Ewl_Chuanqi_Saijier_13",
    test = [[

            ]]
  },
  {
    name = "凯露",
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "魔导",
      "兽",
      "黑暗"
    },
    unique = true,
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
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Kailu_01)
      SendMsgAll("|cFF9977FF『本小姐就帮你一把！还不快谢谢我！』|r")
      local data1 = 0
      local data2 = 0
      
      local function refresh_saijier_bonus()
        ChangeValue(Damage_Element_Dark, sy, -data1)
        ChangeValue(Correction_Magic, sy, -data2)
        local citiao1 = u:getstate("魔导变异")
        data1 = 0.005 * citiao1
        data2 = 0.01 * citiao1
        ChangeValue(Correction_Magic, sy, data2)
        ChangeValue(Damage_Element_Dark, sy, data1)
      end
      
      refresh_saijier_bonus()
      ac.loop(3000, refresh_saijier_bonus)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:getluckrandom(10 * info.txgl) and not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 1)
          local txsh = 100000
          u:curemp(-1)
          local dx, dy = tg:getxy()
          for _, xq in ac.selector():in_rangexy(dx, dy, 225):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "凯露(格林炸裂)",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "暗",
              extradata = {"法术", "魔导"}
            })
          end
        end
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        ChangeValue(Damage_Element_Dark, sy, 2.0E-4)
        u:curemp(1)
        ChangeTimeValue(Damage_Element_Dark, sy, 0.005, 60)
        ChangeTimeValue(DamageSystem_Shjc, sy, 0.005, 60)
      end)
    end,
    effectname = "|cFF6633FF凯|r|cFF9977FF露|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF6633FF唯一 魔导 黑暗 兽|r\n|cFF9977FF提升[魔导变异*0.5%]暗属性伤害\n提升[魔导变异*1%]法术伤害|r\n|cFF6633FF【格林炸裂】|r\n|cFF9977FF直接伤害10%消耗1魔法值附带225范围\n[100000]伤害(暗魔力,法术,魔导),冷却1秒|r\n|cFF6633FF【黑暗之蚀】|r\n|cFF9977FF杀敌时提升0.02%暗属性伤害并恢复1魔法值\n杀敌时在60秒内提升0.5%暗属性伤害与0.5%伤害加成\n可叠加,分立计时|r",
    effectart = "Ewl_Chuanqi_Kailu_13",
    test = "            "
  },
  {
    name = "阿鲁多",
    weight = 100,
    lv = 5,
    key = {
      "唯一",
      "战士",
      "龙",
      "光明"
    },
    unique = true,
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
      ciyuanget(u, var)
      u:chat("|cFFE5D675要|r|cFFE0AB5E上|r|cFFDB8046了|r|cFFD6562F！|r")
      PlayGlobalSound(Sound_Aluduo_01)
      u:addstexiao(var.name, "英雄升级时效果", function(args)
        u:addstr(5)
        u:changemaxhp(200)
      end)
      u:changedata("龙变异补正", 200)
      local data1 = 0
      local data2 = 0
      
      local function refresh_saijier_bonus()
        ChangeValue(DamageSystem_Shjc, sy, -data1)
        ChangeValue(Correction_Jzsh, sy, -data2)
        local citiao1 = u:getstate("战士变异")
        data1 = 0.02 * citiao1
        data2 = 0.01 * citiao1
        ChangeValue(DamageSystem_Shjc, sy, data1)
        ChangeValue(Correction_Jzsh, sy, data2)
      end
      
      refresh_saijier_bonus()
      ac.loop(3000, refresh_saijier_bonus)
      u:additem("I0JU")
      ac.loop(3000, function()
        if u:hasdata("武器判定-巨魔贝恩") then
          if not u:hasdata("阿鲁多-巨魔贝恩强化") then
            u:setdata("阿鲁多-巨魔贝恩强化")
            ChangeValue(DamageSplit_CountJzMax, sy, 0.25)
            ChangeValue(DamageSplit_CountJzHit, sy, 1)
            ChangeValue(DamageSystem_Shjc, sy, 0.25)
            ChangeValue(Correction_Jzsh, sy, 0.25)
            ChangeValue(DamageSystem_Ssjianshao, sy, 0.75, 1)
          end
        elseif u:hasdata("阿鲁多-巨魔贝恩强化") then
          u:deldata("阿鲁多-巨魔贝恩强化")
          ChangeValue(DamageSplit_CountJzMax, sy, -0.25)
          ChangeValue(DamageSplit_CountJzHit, sy, -1)
          ChangeValue(DamageSystem_Shjc, sy, -0.25)
          ChangeValue(Correction_Jzsh, sy, -0.25)
          ChangeValue(DamageSystem_Ssjianshao, sy, 0.75, 2)
        end
      end)
      u:addstexiao(var.name, "伤害格挡效果", function(args)
        if u:hasdata("阿鲁多-巨魔贝恩强化") and not args.b and not u:hasdata("阿鲁多-格挡冷却") then
          local u = args.u
          local gl = 25
          if u:getgedangrandom(gl) then
            u:settimedata("阿鲁多-格挡冷却", 5)
            args.b = true
            u:effectadd("Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageCaster.mdl", "chest")
            u:effectadd("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", "chest")
          end
        end
      end)
    end,
    effectname = "|cFFE5D675阿|r|cFFD09562鲁|r|cFFBB544F多|r",
    effecttext = "|cFFCC66FF[超凡]|r\n|cFFE5D675唯一 战士 光明 龙|r\n|cFFBB544F提升[战士变异*2%]伤害加成\n提升[战士变异*1%]近战伤害|r\n|cFFE5D675【正义の剑士】|r\n|cFFBB544F提升5力量成长\n提升200生命上限成长\n提升200%龙变异补正|r\n|cFFE5D675【被魔剑选中之人】|r\n|cFFBB544F获得[巨魔贝恩.天]\n装备[巨魔贝恩.天]时:\n[近战伤害段数+1(物理)\n近战伤害上限+25%\n提升25%伤害加成\n提升25%近战伤害\n提升25%受伤减少\n受伤时25%格挡(冷却5秒)]|r\n|cFFE5D675【穿越时空的猫】|r\n|cFFBB544F离开地图边界不会被暂停\n[混沌传送权杖]惩罚时间减半\n[Move指令]冷却时间减半|r",
    effectart = "Ewl_Cq_Aluduo",
    test = "            "
  },
  {
    name = "达尔米尔",
    weight = 100,
    lv = 3,
    key = {"唯一", "星"},
    unique = true,
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
      ciyuanget(u, var)
      SendMsgAll("|cFF6600CC『|r|cFF6B09CC汝|r|cFF6F13CC所|r|cFF741CCC求|r|cFF7925CC愿|r|cFF7D2ECC望|r|cFF8238CC为|r|cFF8641CC何|r|cFF8B4ACC？|r|cFF9053CC』|r")
      PlayGlobalSound(Sound_Daermier_01)
      u:adddivinity(1)
      u:getgoddessforce(2, true)
      u:changedata("幸运", 1)
      u:changeoriginmaxhp(100.0)
      u:changedata("全属性增幅", 0.05)
      u:addallstats(100)
      u:changedata("星变异补正", 100)
      local jc = 0
      ac.loop(3000, function(timer)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jc)
        jc = 0.1 * u:getstate("星变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * jc)
        if not u:hasdata("变异判定-达尔米尔") then
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jc)
          timer:remove()
        end
      end)
      local cs = 0
      ac.loop(10000, function(timer)
        if not u:hasdata("变异判定-达尔米尔") then
          timer:remove()
        else
          cs = cs + 1
          if cs == 6 then
            cs = 0
            local add = u:getdata("女神力")
            SendMsgAll("|cFF9966CC[萝莉神]提升" .. add .. "属性|r")
            ForGroupLuaNew(Group_PlayHero, function(xq)
              xq:addallstats(add)
            end)
          end
          if u:isalive() and u:getluckrandom(4, false) then
            u:sendmessage("|cFF9966CC达尔米尔-星噬|r")
            u:settimedata("达尔米尔-星噬", 9.9)
            ac.timer(1000, 10, function()
              u:losshp(u, 0, 8)
            end)
          end
        end
      end)
      if u:hasdata("伊丝-过波奖励获取变异") then
        u:setdata("达尔米尔-过波获取")
      end
      u:settimedata("达尔米尔-倒计时", 60)
      
      local function chattrg(args)
        if args.chat == "让我回到以前的世界" and u:hasdata("变异判定-达尔米尔") and u:hasdata("达尔米尔-倒计时") then
          u:deldata("变异判定-达尔米尔")
          u:adddivinity(-1)
          u:getgoddessforce(-2)
          u:changedata("幸运", -1)
          u:changeoriginmaxhp(-100.0)
          if not u:hasdata("达尔米尔-过波获取") then
            u:changedata("传奇数量", -1)
          end
          u:changedata("全属性增幅", -0.05)
          u:addallstats(-100)
          u:changedata("系统-神力承载", -3)
          u:changedata("星变异数量", -1)
          u:changedata("唯一变异数量", -1)
          u:uivar_remove("达尔米尔", "传奇栏")
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chattrg(args)
      end)
    end,
    effectname = "|cFF704881达|r|cFF8E68A3尔|r|cFFAD89C6米|r|cFFCBA9E8尔|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF704881唯一 星 神性1 女神力2|r\n|cFFCBA9E8提升1幸运\n提升5%全属性\n提升100全属性|r\n|cFF704881【神啊(陨星)】|r\n|cFFCBA9E8获得星变异时提升100基础生命上限\n提升[星变异*1%]伤害加成\n提升100%星获取补正|r\n|cFF704881【萝莉神】|r\n|cFFCBA9E8每60秒提升全队[女神力*1]全属性|r\n|cFF704881【星噬】|r\n|cFFCBA9E8获取[达尔米尔]60秒内输入'让我回到以前的世界'来失去该变异(不可逆)\n每10秒4%在接下来10秒内每秒损耗8%当前生命值,额外移速失效|r",
    effectart = "Ewl_Cq_Daermier",
    test = [[

            ]]
  },
  {
    name = "大日女之御巫",
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "光明",
      "巫女",
      "战士"
    },
    unique = true,
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
      ciyuanget(u, var)
      u:chat("|cFFFFCC66请予以祓除，赐予净化——")
      u:chat("|cFFFFCC66太阳于此照耀！", 2.3)
      PlayGlobalSound(Sound_Yuwu_01)
      u:changedata("系统-飞行强度", 100)
      u:addskill("S0CE")
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and not u:hasdata("大日女之御巫-决死冷却") then
          args.dt = false
          u:sendmessage("|cFFFFCC66大日女之御巫-御巫神隐|r")
          u:settimedata("大日女之御巫-决死冷却", 400)
          u:settimedata("大日女之御巫-死亡抗拒", 3)
          u:buffset(u.handle, 3, "隐身")
        end
      end)
    end,
    effectname = "|cFFFFCC66大|r|cFFFFD670日|r|cFFFFE07A女|r|cFFFFEB85之|r|cFFFFF58F御|r|cFFFFFF99巫|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFFFCC66唯一 光明 巫女 战士|r\n|cFFFFCC66【御巫的水舞蹈】|r\n|cFFFFFF99获得变异时提升3全属性与0.01体力恢复\n受到普通攻击时反击[全属性*100]近战物理伤害,冷却0.25秒|r\n|cFFFFCC66【御巫舞踊-迷途鸟】|r\n|cFFFFFF99提升25%移速\n提升100飞行强度|r\n|cFFFFCC66【御巫神隐】|r\n|cFFFFFF99受到致死伤害时格挡并在3秒内死亡抗拒且隐身,冷却400秒|r",
    effectart = "Ewl_Cq_Darizhiyuwu",
    test = "            "
  },
  {
    name = "指引明路的苍蓝星",
    weight = 100,
    lv = 3,
    key = {"战士"},
    unique = false,
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
      ciyuanget(u, var)
      SendMsgAll("|cFF3366FF『|r|cFF3B6EFF我|r|cFF4376FF看|r|cFF4B7EFF着|r|cFF5285FF伙|r|cFF5A8DFF伴|r|cFF6295FF一|r|cFF6A9DFF路|r|cFF72A5FF走|r|cFF7AADFF来|r|cFF81B4FF。|r|cFF89BCFF』|r")
      SendDtimeMsgAll(1.7, "|cFF3366FF『|r|cFF3A6DFF那|r|cFF4275FF个|r|cFF497CFF人|r|cFF5083FF一|r|cFF578AFF定|r|cFF5F92FF能|r|cFF6699FF做|r|cFF6DA0FF得|r|cFF75A8FF到|r|cFF7CAFFF的|r|cFF83B6FF。|r|cFF8ABDFF』|r")
      SendDtimeMsgAll(3.8, "|cFF3366FF『|r|cFF396CFF不|r|cFF3F72FF对|r|cFF4578FF，|r|cFF4B7EFF是|r|cFF5184FF只|r|cFF578AFF有|r|cFF5D90FF伙|r|cFF6396FF伴|r|cFF699CFF才|r|cFF6FA2FF能|r|cFF75A8FF做|r|cFF7BAEFF到|r|cFF81B4FF的|r|cFF87BAFF！|r|cFF8DC0FF』|r")
      SendDtimeMsgAll(6.3, "|cFF3366FF『|r|cFF386BFF像|r|cFF3E71FF星|r|cFF4376FF星|r|cFF487BFF般|r|cFF4E81FF闪|r|cFF5386FF耀|r|cFF598CFF光|r|cFF5E91FF芒|r|cFF6396FF的|r|cFF699CFF「|r|cFF6EA1FF最|r|cFF73A6FF强|r|cFF79ACFF猎|r|cFF7EB1FF人|r|cFF84B7FF」|r" .. u:getplayername() .. "|cFF8EC1FF』|r")
      PlayGlobalSound(Sound_Alm_01)
      ChangeValue(Correction_Jzsh, sy, 0.1)
      ChangeValue(Correction_Gun, sy, 0.1)
      ChangeValue(DamageSystem_Baoji, sy, 7)
      ac.loop(3000, function()
        local boss = getunit(BOSS)
        if u:hasdata("指引明路的苍蓝星-进入boss战状态") then
          if not u:hasdata("苍蓝星-享受加成中") then
            u:sendmessage("|cFF3399FF苍蓝星-挑战者效果激活|r")
            u:chat("嘻,【挑战者】Lv7已发动")
            ChangeValue(DamageSystem_Baoji, sy, 14)
            ChangeValue(DamageSystem_EndSh, sy, 0.010000000000000002)
            u:setdata("苍蓝星-享受加成中")
          end
        elseif u:hasdata("苍蓝星-享受加成中") then
          u:sendmessage("|cFF3399FF苍蓝星-挑战者效果结束|r")
          ChangeValue(DamageSystem_Baoji, sy, -14)
          ChangeValue(DamageSystem_EndSh, sy, -0.010000000000000002)
          u:deldata("苍蓝星-享受加成中")
        end
        if BossBattle and (boss:hasdata("狂暴度-无穷") or boss:hasdata("翁斯坦-金石之誓") or boss:hasdata("破戒-狂暴") or boss:hasdata("无极-狂暴状态") or boss:hasdata("格斯-狂暴")) and not u:hasdata("指引明路的苍蓝星-进入boss战状态") then
          u:chat("对不起，别吼了！我害怕")
          u:setdata("指引明路的苍蓝星-进入boss战状态")
        end
      end)
    end,
    effectname = "|cFF3366FF指|r|cFF406EFA引|r|cFF4D76F4明|r|cFF5A7EEF路|r|cFF6886E9的|r|cFF758EE4苍|r|cFF8296DE蓝|r|cFF8F9ED9星|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF3366FF战士|r\n|cFF3366FF【帝皇太刀虾】|r\n|cFF8F9ED9提升10%近战伤害\n提升10%枪械伤害|r\n|cFF949596为什么会提升子弹伤害？折叠太刀怎么就不是太刀了！|r\n|cFF3366FF【挑战者Lv7】|r\n|cFF8F9ED9BOSS战时,如果BOSS进入过狂暴状态\n获得加成直到BOSS战结束:\n[提升14%暴击率\n提升1%终结伤害]|r\n|cFF949596对不起，别吼了！我害怕\n已发动技能【挑战者】Lv7\n嘻|r\n|cFF3366FF【看破Lv7】|r\n|cFF8F9ED9提升7%暴击率|r\n|cFF3366FF【广域化Lv1】|r\n|cFF8F9ED9使用变异药水时,周围1800范围友军50%也视为使用该药水\n受到医疗恢复时,周围1800范围友军也享受50%效果|r\n|cFF949596兄弟，我带了广域化，包有你福享的|r\n|cFF3366FF【猫的报酬金】|r\n|cFF8F9ED9受到致死伤害时抵挡该次伤害并无敌2秒,过波刷新|r\n|cFF949596别怕，我吃了报酬金，猫就猫了|r",
    effectart = "Ewl_Cq_Canglanxing",
    test = [[

            ]]
  },
  {
    name = "残影的菲奥雷托",
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "黑暗",
      "影",
      "战士"
    },
    unique = true,
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
      ciyuanget(u, var)
      u:chat("|cFF333333你的存在是否必要……我会亲自判断|r")
      PlayGlobalSound(Sound_Falt_01)
      u:addstexiao(var.name, "伤害判定前变更", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("菲奥雷托-歇逼") then
          info.damage = info.damage * 0.5
        end
      end)
      local cs = 0
      ac.loop(1000, function(timer)
        if u:isalive() then
          cs = cs + 1
          if cs == 10 then
            cs = 0
            if GetRandom100(10) then
              u:playsound(Sound_Falt_Sb_04)
              u:sendmessage("|cFFFFCC66菲奥雷托歇逼了|r")
              u:setdata("菲奥雷托-歇逼")
              ac.wait(9900, function()
                u:deldata("菲奥雷托-歇逼")
                u:sendmessage("|cFFFFCC66菲奥雷托脱离歇逼状态|r")
              end)
            end
          end
        end
      end)
      u:addstexiao(var.name, "进入战斗状态时", function(args)
        local u = args.u
        local yx = {
          Sound_Falt_Sb_01,
          Sound_Falt_Sb_02,
          Sound_Falt_Sb_03
        }
        u:playsound(yx[GetRandomInt(1, 3)])
        u:settimedata("菲奥雷托-集中力", 10)
      end)
      u:addstexiao(var.name, "伤害格挡效果", function(args)
        if not u:hasdata("菲奥雷托-歇逼") and u:hasdata("菲奥雷托-集中力") and not args.b and u:getgedangrandom(70) then
          args.b = true
          u:effectadd("Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageCaster.mdl", "chest")
          u:effectadd("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", "chest")
        end
      end)
    end,
    effectname = "|cFF62667B残|r|cFF7C7873影|r|cFF968A6B的|r|cFFB09C62菲|r|cFFCBAE5A奥|r|cFFE5C052雷|r|cFFFFD24A托|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF8D807E唯一 影 黑暗 战士|r\n|cFF8D807E【集中力】|r\n|cFFFFD24A入战10秒内,受到伤害时70%格挡|r\n|cFF8D807E【虐杀】|r\n|cFFFFD24A主动格挡技能或被动格挡效果格挡成功时,获得1点专注力(处于[虐杀]状态则不获得)\n如果专注力为5点及以上则消耗所有专注力并在30秒内:\n[无视50%护甲\n提升130%伤害加成]|r\n|cFF8D807E【！？歇逼？！】|r\n|cFFFFD24A每10秒10%概率使自身进入10秒[歇逼]状态:\n[伤害能力降低50%\n[集中力]与[虐杀]失效]|r",
    effectart = "Ewl_Cq_Feiaotuosi",
    test = [[

            ]]
  },
  {
    name = "波风水门青年",
    weight = 100,
    lv = 3,
    key = {"战士", "影"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("神器判定-飞雷神苦无") then
        add = add + 1500
      end
      return add
    end,
    condition = function(u)
      local b = true
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("虽然是对手……但是你还不赖嘛")
      PlayGlobalSound(Sound_Bfsmqn_04)
      if u.type == HeroType["波风水门"] then
        u:setdata("波风水门-专属传奇强化")
      end
      u:addstexiao(var.name, "近战伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          local txsh = 30000
          u:settimedata(var.name .. "-特效冷却", 6)
          local sz = {
            Sound_Bfsmqn_01,
            Sound_Bfsmqn_02,
            Sound_Bfsmqn_03
          }
          u:playsound(sz[GetRandomInt(1, #sz)])
          u:playseensound(Bfsm_fls_shunyi2)
          u:playseensound(Bfsm_Lxw)
          local x1, y1 = tg:getxy()
          local jd = GetRandomAngle()
          local tx = EffectcreateArgs({
            effect = "Bfsmtx\\bfsm_luoxuanwan4.mdx",
            x = x1,
            y = y1,
            time = 0.5,
            size = 0.5,
            height = 400,
            zxz = jd,
            animespeed = GetRandomReal(0.5, 3)
          })
          local tx1 = EffectcreateArgs({
            effect = "Bfsmtx\\bfsm_xiazha4.mdx",
            x = x1,
            y = y1,
            time = 0.5,
            size = 0.1,
            height = 0,
            zxz = jd,
            yxz = 90,
            animespeed = 4
          })
          local cs1 = 0
          ac.loop(10, function(t1)
            cs1 = cs1 + 1
            japi.EXSetEffectSize(tx, cs1 * 0.4)
            japi.EXSetEffectZ(tx, 100 + cs1 * 1.5)
            japi.EXSetEffectSize(tx1, cs1 * 0.012)
            if 25 <= cs1 then
              t1:remove()
            end
          end)
          ac.timer(250, 6, function()
            for _, xq in ac.selector():in_rangexy(x1, y1, 350):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              DamageUnit({
                bj = "青水(螺旋丸)",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "灵力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "风"
              })
              xq:buffset(u.handle, 0.5, "僵直")
            end
          end)
        end
      end)
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and not u:hasdata("波风水门-决死冷却") then
          args.dt = false
          u:settimedata("波风水门-决死冷却", 360)
          u:sendmessage("|cFFE0C545波风水门-动物伙伴|r")
          local x2, y2 = u:getxy()
          local txsh = 100000
          for _, xq in ac.selector():in_rangexy(x2, y2, 500):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "青水(动物之力)",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "震荡",
              isvest = false,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
            xq:buffset(u.handle, 3, "眩晕")
          end
        end
      end)
    end,
    effectname = "|cFFE0C545波|r|cFFDABF58风|r|cFFD5BA6A水|r|cFFCFB47D门|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFE0C545影 战士|r\n|cFFE0C545【禁术阴愈伤灭】|r\n|cFFCFB47D受到负面状态时立刻解除并在3秒内免疫负面状态,冷却30秒|r\n|cFFE0C545【疾风超级闪光裂空螺旋丸】|r\n|cFFCFB47D近战直接伤害时发动螺旋丸:\n[对350范围敌军造成\n每0.25秒[30000]风灵力伤害与0.5秒僵直\n持续1.5秒\n冷却6秒]|r\n|cFFE0C545【动物伙伴】|r\n|cFFCFB47D受到致死伤害时,抵挡该次伤害\n并对周围500范围单位造成[100000]震荡伤害与3秒眩晕\n冷却360秒|r\n|cFF949596开局走两步，先霸体\n我直接打出防反\n霸体螺旋丸，我们青水玩家真是太有操作辣\n技能全黑，我直接呼叫我的动物伙伴\n拉满了，真的拉满了|r",
    effectart = "BTNEwl_Chuanqi_Bofengshuimen",
    test = "            "
  },
  {
    name = "艾斯德斯",
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "冰",
      "恶魔"
    },
    unique = true,
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
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Asds_01)
      u:chat("|cFF4D4DFF『难道就没有能让我满足的对手么』")
      u:become("王")
      if u:hasdata("遗物-魔神显现") then
        ChangeValue(DamageSystem_LwSs, sy, 2, 2)
      end
      ChangeValue(DamageSystem_EndSh, sy, 0.02)
      local data1 = 0
      local data2 = 0
      
      local function refresh_saijier_bonus()
        ChangeValue(DamageSystem_Shjc, sy, -data1)
        ChangeValue(Damage_Element_Ice, sy, -data2)
        local citiao1 = u:getstate("冰变异")
        data1 = 0.01 * citiao1
        data2 = 0.005 * citiao1
        ChangeValue(DamageSystem_Shjc, sy, data1)
        ChangeValue(Damage_Element_Ice, sy, data2)
      end
      
      refresh_saijier_bonus()
      ac.loop(3000, refresh_saijier_bonus)
      u:addskill("S00Y")
      AddAllSTexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        local sy = u.ownerid
        ChangeTimeValue(DamageSystem_Shjc, sy, 0.0025, 7)
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          tg:buffset(u.handle, 1, "冰冻")
          u:settimedata(var.name .. "-特效冷却", 0.5)
        end
        if not u:hasdata(var.name .. "-特效伤害冷却") and tg:hasbuff("冰冻") then
          u:settimedata(var.name .. "-特效伤害冷却", 0.5)
          local txsh = 50000
          DamageUnit({
            bj = "艾斯德斯(摩珂钵特摩)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "冰"
          })
        end
      end)
      u:addstexiao(var.name, "伤害判定后效果", function(args)
        if not args.tg:hasdata("艾斯德斯-拷问酷刑") then
          args.tg:setdata("艾斯德斯-拷问酷刑")
          args.tg:changedata("怪物-额外受伤", 0.15)
        end
      end)
    end,
    effectname = "|cFF4D4DFF艾|r|cFF5F69FF斯|r|cFF7086FF德|r|cFF82A2FF斯|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF4D4DFF冰 恶魔|r\n|cFF82A2FF提升2%终结伤害\n提升[冰变异*1%]伤害加成\n提升[冰变异*0.5%]冰属性伤害|r\n|cFF4D4DFF【恶魔之粹】|r\n|cFF82A2FF降低500范围所有单位15%移速,50%额外移速与30%攻速|r\n|cFF4D4DFF【摩珂钵特摩】|r\n|cFF82A2FF直接伤害时10%冰冻目标1秒,冷却0.5秒\n直接伤害冰冻单位时附带[50000]冰魔力伤害,冷却0.5秒|r\n|cFF4D4DFF【S女王】|r\n|cFF82A2FF直接伤害时提升0.25%伤害加成,持续7秒,可叠加,分立计时\n自身伤害过的单位提升15%额外受伤,无法叠加|r\n|cFF949596用你死前最后的挣扎来取悦我吧。|r",
    effectart = "war3mapImported\\BTNEwl_Nvwang.blp"
  },
  {
    name = "史黛拉",
    weight = 100,
    lv = 3,
    key = {
      "白毛",
      "光明",
      "同奏"
    },
    unique = false,
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
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Sdl_01)
      u:chat("在梦里我也和大家一起战斗了")
      ac.wait(4100, function()
        u:chat("这是桶。")
      end)
      ac.wait(5700, function()
        u:chat("你觉得怎么样呢？")
      end)
      u:getgoddessforce(2, false)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          local x, y = u:getxy()
          local x2, y2 = tg:getxy()
          local angle = AngleXY(x, y, x2, y2)
          u:settimedata(var.name .. "-特效冷却", 1.5)
          local txsh = 10 * u:getmaxhp()
          local tx = Effectcreate("Units\\Other\\TNTBarrel\\TNTBarrel.mdl", x, y, -1)
          local time = 0.3
          if u:hasdata("烫手山芋-爆炸立即") then
            time = 0.02
          end
          effectjump({
            effect = tx,
            time = time,
            distance = info.distance,
            height = 400,
            angle = angle,
            endfunc = function(dargs)
              local dx = dargs.x
              local dy = dargs.y
              DestroyEffectLua(tx)
              Effectcreate("Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl", dx, dy)
              for _, xq in ac.selector():in_rangexy(dx, dy, 350):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                DamageUnit({
                  bj = "史黛拉(镇压用桶型开心炸弹)",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "震荡",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = "光"
                })
              end
            end
          })
        end
      end)
      u:addstexiao(var.name, "伤害判定后效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if info.damagetype == "震荡" and not u:hasdata(var.name .. "-提升伤害冷却") then
          ChangeTimeValue(DamageSystem_Shjc, sy, 0.025, 15)
          u:settimedata(var.name .. "-提升伤害冷却", 5)
        end
      end)
      local data1 = 0
      local data2 = 0
      
      local function refresh_saijier_bonus()
        ChangeValue(DamageSystem_Shjc, sy, -data1)
        ChangeValue(Damage_Element_Light, sy, -data2)
        local citiao1 = u:getstate("光明变异")
        data1 = 0.01 * citiao1
        data2 = 0.005 * citiao1
        ChangeValue(DamageSystem_Shjc, sy, data1)
        ChangeValue(Damage_Element_Light, sy, data2)
      end
      
      refresh_saijier_bonus()
      ac.loop(3000, refresh_saijier_bonus)
      for i = 1, 6 do
        ChangeValue(Correction_MHp, i, 0.05)
      end
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:changeoriginmaxhp(250)
      end)
    end,
    effectname = "|cFFF5DFD1史|r|cFFF4EEE8黛|r|cFFF2FEFF拉|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFF5DFD1白毛 光明 同奏 女神力2|r\n|cFFF2FEFF提升[光明变异*1%]伤害加成\n提升[光明变异*0.5%]光属性伤害|r\n|cFFF5DFD1【觅见的宝物】|r\n|cFFF2FEFF提升全队5%生命上限\n提升全队250基础生命上限|r\n|cFFF5DFD1【镇压用桶型开心炸弹】|r\n|cFFF2FEFF直接伤害时10%投掷炸药桶,附带350范围[生命上限*10]光震荡伤害,冷却1.5秒|r",
    effectart = "war3mapImported\\BTNEwl_Cq_Shidaila"
  },
  {
    name = "戈登",
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "白毛",
      "战士"
    },
    unique = true,
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
      ciyuanget(u, var)
      coopjudge("CQC超人", u)
      PlayGlobalSound(Sound_Gedeng_01)
      SendMsgAll("|cFFD28744“该醒来了, 弗里曼先生, 该醒来了。”|r")
      u:additem("I0GA")
      u:additem("I00O")
      ChangeValue(Revise_PoisonResist, sy, 1)
      u:changearmor(25)
      u:addskill("S09Q")
      SetUnitState(u.handle, ConvertUnitState(80), 2)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:isboss() then
          info.end3 = info.end3 + 0.16
        end
      end)
      u:setdata("戈登-HEV护盾值", u:getmaxhp())
      Hdzflash(u)
    end,
    effectname = "|cFFD28744戈|r|cFFA4ABB3登|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFD28744唯一 战士 白毛|r\n|cFFD28744【物理学圣剑】|r\n|cFF4F565E获得[撬棍]\n允许装备撬棍类武器\n提升100%撬棍类武器伤害\n装备撬棍时,视为拥有撬锁工具|r\n|cFFD28744【H.E.V】|r\n|cFF4F565E免疫毒素\n提升25护甲\n提升25%移速\n护甲类型变为合金\n获得生命上限等量的额外临时护盾值,不会自然恢复\n拾取或使用医疗包时将消耗来充能护盾;过波时恢复全部护盾|r\n|cFFD28744【静寂的救世主】|r\n|cFF4F565E对BOSS提升16%伤害\n提升转职[救世主]概率|r",
    effectart = "war3mapImported\\BTNEwl_Cq_gengdeng"
  },
  {
    name = "白鹭公主",
    clickfunc = function(u, var)
      local sy = u.ownerid
      if not u:hasdata("神里绫华-冰华霞步关闭") then
        u:setdata("神里绫华-冰华霞步关闭")
        u:sendmessage("|cFF84FFFF[神里绫华]冰华霞步关闭")
      else
        u:deldata("神里绫华-冰华霞步关闭")
        u:sendmessage("|cFF84FFFF[神里绫华]冰华霞步开启")
      end
    end,
    weight = 100,
    lv = 3,
    key = {
      "白毛",
      "战士",
      "冰"
    },
    unique = false,
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
      ciyuanget(u, var)
      if GetRandom100(50) then
        SendColorfulMsgAll("稻妻神里流太刀术皆传---神里绫华，参上！", "|cFFC2C1E5", "|cFFC07398", "|cFFF2D6FE", "|cFFE2DCE2")
        PlayGlobalSound(Sound_Linghua_Get_Jp)
      else
        SendColorfulMsgAll("稻妻神里流太刀术皆传---神里绫华，参上！请多指教哦~~~", "|cFFC2C1E5", "|cFFC07398", "|cFFF2D6FE", "|cFFE2DCE2")
        PlayGlobalSound(Sound_Linghua_Get_Cn)
      end
      ChangeValue(DamageSplit_CountJzMax, sy, 0.3)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      local melee_bonus = 0
      local ice_bonus = 0
      
      local function refresh_bailugongzhu_bonus()
        ChangeValue(Correction_Jzsh, sy, 0.1 * -melee_bonus)
        ChangeValue(Damage_Element_Ice, sy, -ice_bonus)
        local ice_mutation = u:getstate("冰变异")
        melee_bonus = 0.05 * ice_mutation
        ice_bonus = 0.01 * ice_mutation
        ChangeValue(Correction_Jzsh, sy, 0.1 * melee_bonus)
        ChangeValue(Damage_Element_Ice, sy, ice_bonus)
      end
      
      refresh_bailugongzhu_bonus()
      ac.loop(3000, refresh_bailugongzhu_bonus)
      ac.loop(1000, function()
        if u:hasdata("白鹭公主-冰华时间") then
          u:changedata("白鹭公主-冰华时间", -1)
          if u:getdata("白鹭公主-冰华时间") <= 0 then
            u:deldata("白鹭公主-冰华时间")
          end
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local info = args.damageinfo
        if u:hasdata("白鹭公主-冰华时间") and info.element == "冰" then
          u:curetili(0.1)
        end
      end)
    end,
    effectname = "|cFF84FFFF白|r|cFFA0FFFF鹭|r|cFFBBFFFF公|r|cFFD7FFFF主|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF84FFFF战士 冰|r\n|cFFD7FFFF提升[冰变异*0.5%]近战伤害\n提升[冰变异*1%]冰属性伤害|r\n|cFF84FFFF【神里流.倾】|r\n|cFFD7FFFF近战伤害多击段数+1(冰灵力)\n近战伤害多击上限+30%|r\n|cFF84FFFF【神里流.冰华霞步】(点击切换效果开关)|r\n|cFFD7FFFF发动位移技能时:\n[冰冻沿途250范围1秒\n5秒内近战伤害造成冰属性伤害\n5秒内造成冰属性直接伤害时恢复0.1体力值]|r",
    effectart = "war3mapImported\\BTNEwl_Cq_Bailugongzhu"
  },
  {
    name = "咲恋",
    weight = 100,
    lv = 3,
    key = {"战士", "炎"},
    unique = false,
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
      ciyuanget(u, var)
      SendColorfulMsgAll("虽然钱也很重要，可我只是想要看到大家的笑容，当然，也包括你的哦~~~", "|cFFFCCE9C", "|cFFFF0000", "|cFFF05F5F", "|cFF62757B")
      PlayGlobalSound(Sound_Xiaolian_01)
      local data1 = 0
      local data2 = 0
      
      local function refresh_saijier_bonus()
        ChangeValue(Correction_Jzsh, sy, -data1)
        ChangeValue(Damage_Element_Fire, sy, -data2)
        local citiao1 = u:getstate("炎变异")
        data1 = 0.01 * citiao1
        data2 = 0.005 * citiao1
        ChangeValue(Correction_Jzsh, sy, data1)
        ChangeValue(Damage_Element_Fire, sy, data2)
      end
      
      refresh_saijier_bonus()
      ac.loop(3000, refresh_saijier_bonus)
      u:changedata("近战机体-基础伤害提升", 5000)
      u:addskill("A1PZ")
      u:addhealthrefresh(function(set_value, bs)
        set_value(DamageSystem_Shjc, sy, 0.5 * bs)
      end)
    end,
    effectname = "|cFFFF0000咲|r|cFFFF9866恋|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFFF0000战士 炎|r\n|cFFFF0000【凤凰之剑】|r\n|cFFFF9866提升[炎变异*1%]近战伤害\n提升[炎变异*0.5%]火属性伤害\n提升[背水*50%]伤害加成|r\n|cFFFF0000【优雅声援】|r\n|cFFFF9866提升自身与900范围友军0.1体力恢复|r\n|cFFFF0000【优雅高贵之魂】|r\n|cFFFF9866提升5000近战角色基础伤害或近战武器基础伤害|r",
    effectart = "war3mapImported\\BTNEwl_Cq_Zuozuomuxiaolian"
  },
  {
    name = "黑兔",
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "机械",
      "白毛"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:getdata("机械变异数量") > 0 then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cFFCCCCCC「你好，我是亚尔缇娜·奥莱恩……代号是|r|cFF333333「黑兔」|r|cFFCCCCCC，请多指教。」|r")
      ChangeValue(Correction_Jzsh, sy, 0.010000000000000002)
      u:addskill("A1LC")
      u:addskill("A1LD")
      u:setdata("黑兔-黑色障壁次数", 3)
      local cs = 0
      local jc = 0
      ac.loop(1000, function()
        if u:getdata("黑兔-黑色障壁次数") < 3 then
          cs = cs + 1
          if cs == 60 then
            cs = 0
            u:changedata("黑兔-黑色障壁次数", 1)
            u:sendmessage("|cFF330099黑色障壁剩余次数：" .. math.floor(u:getdata("黑兔-黑色障壁次数")) .. "|r")
          end
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * jc))
        jc = 2 - 0.1 * Stage
        if jc <= 0 then
          jc = 0
        end
        jc = jc + 0.1 * u:getstate("机械变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * jc))
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if info.damagetype == "能量" and not u:hasdata("黑兔-太阳神之枪强化冷却") then
          u:settimedata("黑兔-太阳神之枪强化冷却", 1)
          tg:changetimearmor(-5, 5)
          tg:settimedata("怪物-额外受伤", 0.05, 5)
        end
      end)
      ac.loop(1000, function()
        if u:isalive() then
          local dx, dy = u:getxy()
          for _, xq in ac.selector():in_rangexy(dx, dy, 900):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            u:changetimedata("全属性抗性", -6, 0.99)
          end
        end
      end)
    end,
    effectname = "|cFF666666黑|r|cFFCCCCCC兔|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF666666唯一 机械|r\n|cFFCCCCCC提升2.5%近战伤害\n提升[1%*机械变异]伤害加成|r\n|cFF666666【太阳神之枪】|r\n|cFFCCCCCC能量伤害降低目标5护甲并提升5%额外受伤,持续5秒,冷却1秒|r\n|cFF666666【激微波刃臂】|r\n|cFFCCCCCC近战武器附带[等级*1000]能量伤害|r\n|cFF666666【情报分析】|r\n|cFFCCCCCC提升900范围友军10护甲与25%属性抗性\n降低900范围敌军10护甲与6%全属性抗性|r\n|cFF666666【黑色障壁】|r\n|cFFCCCCCC每隔45秒获得1次格挡伤害效果(上限3次)|r\n|cFF666666【末日之剑】|r\n|cFFCCCCCC提升[200%-10%*波数](至低0%)伤害加成|r",
    effectart = "war3mapImported\\BTNEwl_Yaertina"
  },
  {
    name = "Tevi",
    clickfunc = function(u, var)
      local sy = u.ownerid
      if u:getdata("Tevi-魔粹使用次数") >= 200 then
        u:changedata("Tevi-魔粹使用次数", -200)
        if 0 < #sjz then
          local index = GetRandomInt(1, #sjz)
          local sjs = sjz[index]
          if sjs == 1 then
            u:sendmessage("|cFF6D7CCD解锁[十字炸弹]|r")
            u:setdata("Tevi-十字炸弹")
          end
          if sjs == 2 then
            u:sendmessage("|cFF6D7CCD解锁[强化扳手]|r")
            u:setdata("Tevi-强化扳手")
            ChangeValue(Correction_Jzsh, sy, 0.025)
          end
          if sjs == 3 then
            u:sendmessage("|cFF6D7CCD解锁[喷气背包]|r")
            u:setdata("Tevi-喷气背包")
            u:changedata("系统-飞行强度", 100)
            ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
          end
          table.remove(sjz, index)
        end
        if #sjz == 0 and not u:hasdata("Tevi-进阶语音触发") then
          u:setdata("Tevi-进阶语音触发")
          u:changedata("全属性增幅", 0.05)
          ChangeValue(DamageSystem_Shjc, sy, 0.05)
          PlayGlobalSound(Sound_Tevi_Jinjie)
          PlayBGM({
            bgm = BGM_Tevi_01,
            time = 105,
            ID = 173,
            unit = u.handle
          })
          u:chat("|cFF6D7CCD『|r|cFF7885CD我|r|cFF828ECD会|r|cFF8D97CD继|r|cFF97A0CD续|r|cFFA2A8CC前|r|cFFACB1CC进|r|cFFB7BACC』|r")
          ac.wait(2200, function()
            u:chat("|cFF6D7CCD『|r|cFF7381CD未|r|cFF7A87CD来|r|cFF808CCD究|r|cFF8691CD竟|r|cFF8D97CD有|r|cFF939CCD什|r|cFF99A1CD么|r|cFFA0A7CC在|r|cFFA6ACCC等|r|cFFACB1CC待|r|cFFB3B7CC着|r|cFFB9BCCC我|r|cFFBFC1CC』|r")
          end)
          ac.wait(4600, function()
            u:chat("|cFF6D7CCD『|r|cFF7583CD只|r|cFF7D89CD有|r|cFF8590CD时|r|cFF8D97CD间|r|cFF959DCD能|r|cFF9CA4CC揭|r|cFFA4ABCC晓|r|cFFACB1CC答|r|cFFB4B8CC案|r|cFFBCBFCC』|r")
          end)
        end
      else
        u:sendmessage("|cFF6D7CCD魔粹数量不足")
      end
    end,
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "星",
      "兽",
      "机械",
      "白毛"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      if CIUC[sy] == "1269671895" then
        add = add + 1000
      end
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:getdata("兽变异数量") >= 1 and 1 <= u:getdata("机械变异数量") then
        b = true
      end
      if CIUC[sy] == "1269671895" then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("|cFF6D7CCD什么什么，我的耳朵怎么了")
      PlayGlobalSound(Sound_Tevi_Get)
      u:additem("I0IW")
      ChangeValue(DamageSystem_Baoji, sy, 20)
      ChangeValue(DamageSystem_Shjc, sy, 0.03)
      ChangeValue(Correction_Magic, sy, 0.003)
      local endsh = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * -endsh)
        endsh = 0.02 * u:getdata("Tevi-星辰齿轮使用次数") * u:getstate("机械")
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * endsh)
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("Tevi-十字炸弹") and not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 5)
          u:playsound(Sound_Tevi_Boom1)
          ac.wait(500, function()
            tg:playsound(Sound_Tevi_Boom2)
            local x, y = tg:getxy()
            local txsh = 4500 * u:getlevel()
            Effectcreate("Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl", x, y)
            for _, xq in ac.selector():in_rangexy(x, y, 325):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              DamageUnit({
                bj = "Tevi(十字炸弹)",
                unit = tg.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "震荡",
                isvest = false,
                isattack = false,
                isnoarmor = false,
                element = "无"
              })
            end
          end)
        end
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        local x, y = tg:getxy()
        u:changedata("Tevi-魔粹使用次数", 1)
        local tx = Effectcreate("Objects\\InventoryItems\\runicobject\\runicobject.mdl", x, y, 0.5)
        SetEffectColor(tx, 0, 104, 104)
        effectmove({
          effect = tx,
          time = 0.5,
          distance = DistanceBetweenUnits(tg.handle, u.handle),
          angle = AngleBetweenUnits(tg.handle, u.handle)
        })
        if tg:isboss() then
          CreateItemLua("I0IV", x, y)
          u:setdata("Tevi-决死次数", 2)
        end
      end)
      u:setdata("Tevi-决死次数", 2)
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and u:getdata("Tevi-决死次数") > 0 then
          args.dt = false
          u:changedata("Tevi-决死次数", -1)
          u:sendmessage("|cFF6D7CCDTevi-决死|r")
          u:buffset(u.handle, 1, "无敌")
          u:buffset(u.handle, 1, "绝对闪避")
        end
      end)
      local dskill = S2ID("A090")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            if GetRandom100(50) then
              u:playsound(Sound_Tevi_Skill1)
            else
              u:playsound(Sound_Tevi_Skill2)
            end
            u:settimedata("Tevi-核心展开", 10)
            local x, y = u:getxy()
            Effectcreate("AATX\\[AATxNew]Blue13.mdl", x, y, 0, 1.5)
            local tx = Effectcreate("AATX\\[AATxNew]Blue10.mdl", x, y, -1, 1)
            ac.loop(30, function(timer)
              local x, y = u:getxy()
              SetEffectXY(tx, x, y)
              if not u:hasdata("Tevi-核心展开") then
                DestroyEffectLua(tx)
                timer:remove()
              end
            end)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      local x, y = u:getxy()
      local tx = Effectcreate("Tevi_01.mdx", x, y, -1, 1, 90)
      u:setdata("Tevi-红浮游", tx)
      ac.loop(250, function()
        local x, y = u:getxy()
        local angle = u:getface()
        x, y = PolarXY(x, y, -50, angle)
        x, y = PolarXY(x, y, 100, angle + 90)
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
      local tx = Effectcreate("Tevi_03.mdx", x, y, -1, 1, 90)
      u:setdata("Tevi-蓝浮游", tx)
      ac.loop(250, function()
        local x, y = u:getxy()
        local angle = u:getface()
        x, y = PolarXY(x, y, -50, angle)
        x, y = PolarXY(x, y, 100, angle - 90)
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
    end,
    effectname = "|cFF6D7CCDT|r|cFF8590D4e|r|cFF9DA4DAv|r|cFFB4B9E1i|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF6D7CCD唯一 星 兽 机械 白毛|r\n|cFFB4B9E1提升20%暴击率\n提升3%伤害加成\n提升30%法术伤害|r\n|cFF6D7CCD【采薇】|r\n|cFFB4B9E1仇恨权重降低\n杀敌时提升1魔粹计数\n获得拓展技能[核心展开]|r\n|cFF6D7CCD【远古齿轮】|r\n|cFFB4B9E1击败BOSS时掉落[星辰齿轮]\n提升[0.2%*机械*星辰齿轮使用次数]终结伤害|r\n|cFF6D7CCD【工具包(点击消耗200点魔粹解锁一项)】|r\n|cFFB4B9E1[十字炸弹]:直接伤害附带325范围[等级*1500]震荡伤害,冷却1.5秒\n[强化扳手]:提升2.5%近战伤害,近战武器附带击退与1秒僵直\n[喷气背包]:提升100飞行强度与25额外移速\n全部解锁时获得[古代传承]:\n[提升5%全属性\n提升5%伤害加成]|r",
    effectart = "Ewl_Tevi_01",
    test = "            "
  },
  {
    name = "魔术师杀手",
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "战士",
      "影"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("英雄-卫宫切嗣") then
        add = add + 500
      end
      return add
    end,
    condition = function(u)
      local b = true
      if u:ishasskill(SKILL_TESHUYINGXIONG) then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      ChangeValue(Correction_Gun, sy, 0.1)
      u:addstexiao(var.name, "过波时效果", function(args)
        ChangeValue(Correction_Gun, sy, 0.025)
      end)
      if u.type == HeroType["切嗣"] then
        PlayGlobalSound(Sound_Kirits_49)
        SendMsgAll("|cFF669999『卫宫切嗣』|r")
        SendDtimeMsgAll(2.5, "|cFF669999『你才是真正的Angra Mainyu』|r")
        SendDtimeMsgAll(5.6, "|cFF669999『是背负「世间的一切罪恶」的最佳人选』|r")
        u:setdata("魔术师杀手-切嗣强化")
        ac.wait(10, function()
          u:uivar_change({
            keyname = "魔术师杀手",
            keytype = "传奇栏",
            text = "|cFF669999魔术师杀手|r\n|cFF669999战士 影\n固有时制御|r\n|cFF666666[移动射击]消耗生命值降低至0.5%\n[固有时制御]消耗生命值降低至4%\n位移结束后5秒内提升1000额外移速,触发冷却8秒\n受到致死伤害时,清除所有负面状态并抵挡该次伤害后在10秒提升1000额外移速,触发冷却360秒|r\n|cFF669999起源弹|r\n|cFF666666子弹命中单位提升25%额外受伤\n子弹命中时,弹幕伤害提升[5%*目标精英特性数量]\n[起源弹]基础伤害提升100%,命中英雄单位时即死|r\n|cFF669999高效的正义|r\n|cFF666666杀死友军或精英时提升1%枪械伤害与0.5%伤害加成\n杀敌时提升0.015%枪械伤害,如果只剩自身一人则提升0.05%|r",
            icon = "Ewl_Qiesi_Change"
          })
        end)
        flashphoto({
          photo = "Ph_Kirits.tga",
          timeout = 0,
          timehold = 1,
          timein = 2
        })
      else
        u:chat("冥冥中这是我，唯一要走的路啊。")
      end
      u:addtrgevent("单位-指定点目标指令", function(args)
        if args.orderid == String2OrderIdBJ("smart") then
          u:setdata("播放动作", "walk")
        end
      end)
      u:addstexiao(var.name, "位移技能后效果", function(args)
        if not u:hasdata("魔术师杀手-固有时制御冷却") then
          local max = 30
          if u:hasdata("魔术师杀手-切嗣强化") then
            max = 50
            u:settimedata("魔术师杀手-固有时制御冷却", 8)
            ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 1000, 5)
            u:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "chest", 5)
          else
            u:settimedata("魔术师杀手-固有时制御冷却", 10)
            ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 1000, 3)
            u:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "chest", 3)
          end
          do
            local dz = 0
            local x, y = u:getxy()
            local x2, y2 = u:getxy()
            local cs = 0
            ac.loop(100, function(timer)
              max = max - 1
              if max <= 0 then
                timer:remove()
                return
              end
              local origin = "walk"
              local run = true
              x, y = u:getxy()
              if dz ~= u:getdata("播放动作") then
                dz = u:getdata("播放动作")
              elseif DistanceXY(x, y, x2, y2) < 10 then
                u:setdata("播放动作", "stand")
                run = false
              else
                u:setdata("播放动作", origin)
              end
              if run then
                if 0 < cs then
                  cs = cs - 1
                else
                  cs = 3
                  play_shadow_slow_series(u, {
                    act = u:getdata("播放动作"),
                    count = 6,
                    interval = 0.05,
                    main_speed = u:getdata("动画速度"),
                    wait_time = 0,
                    r = 255,
                    g = 0,
                    b = 0,
                    fade_sub = 5,
                    noact = true
                  })
                end
              end
              x2, y2 = u:getxy()
            end)
          end
        end
      end)
    end,
    effectname = "|cFF669999魔|r|cFF668C8C术|r|cFF668080师|r|cFF667373杀|r|cFF666666手|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF669999唯一 战士 影|r\n|cFF666666提升10%枪械伤害|r\n|cFF669999【固有时制御】|r\n|cFF666666位移结束后3秒内提升1000额外移速,触发冷却10秒\n受到致死伤害时,清除所有负面状态并抵挡该次伤害\n并在10秒提升1000额外移速,触发冷却360秒|r\n|cFF669999【起源弹】|r\n|cFF666666子弹基础伤害提升[4444+1111*根源变异]\n子弹命中时弹幕伤害提升[5%*根源变异]|r\n|cFF669999【高效的正义】|r\n|cFF666666杀死友军或精英时提升1%枪械伤害\n过波时提升2.5%枪械伤害|r",
    effectart = "war3mapImported\\BTNEwl_Moshushishashou"
  },
  {
    name = "冰之狙击手",
    weight = 100,
    lv = 2,
    key = {"唯一", "影"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:ishasskill(SKILL_TESHUYINGXIONG) then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Shinai_01)
      u:chat("|cFF6FFFFF我的这一击，你们躲得开么")
      u:addstexiao(var.name, "暴击系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("诗乃-第一发暴击强化") then
          info.bjl = info.bjl + 25
        end
        if u:hasdata("诗乃-第一发爆伤强化") then
          info.bjsh = info.bjsh * 2
        end
      end)
      ChangeValue(Correction_Gun, sy, 0.05)
      ChangeValue(Correction_Gun_Pistol, sy, 0.1)
      local cs = 0
      ac.loop(3000, function()
        if u:isalive() then
          u:setdata("诗乃-第一发")
        end
      end)
    end,
    effectname = "|cFF6FFFFF冰|r|cFF6DF2FF之|r|cFF6AE6FF狙|r|cFF68D9FF击|r|cFF66CCFF手|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF6FFFFF唯一 影|r\n|cFF66CCFF提升5%枪械伤害|r\n|cFF6FFFFF【First Shot】|r\n|cFF66CCFF每隔3秒,使下一次枪械射击提升10%伤害加成与25%暴击率\n如果[枪械修正≥150%],则使暴击伤害翻倍|r\n|cFF6FFFFF【幽灵子弹】|r\n|cFF66CCFF提升10%手枪伤害\n提升750手枪射程\n手枪子弹命中时,僵直目标0.5秒并提升[2500+100*等级]弹幕伤害\n子弹命中时,如果距离超过2000码则提升50%弹幕伤害|r",
    effectart = "war3mapImported\\BTNEwl_Shinai"
  },
  {
    name = "剪舌麻雀",
    weight = 10,
    lv = 3,
    key = {
      "唯一",
      "兽",
      "自然",
      "光明"
    },
    unique = true,
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
      ciyuanget(u, var)
      if GetRandomInt(1, 2) == 1 then
        PlayGlobalSound(Sound_Enma_01)
        u:chat("哎呀，轮到我出场啾？那么开始制作料理啾。")
      else
        PlayGlobalSound(Sound_Enma_02)
        u:chat("啾啾啾！剪舌麻雀红阎魔，要履行为人处世的情义啾！")
      end
      ChangeValue(DamageSystem_Baoji, sy, 12)
      ChangeValue(DamageSystem_Baoshang, sy, 0.22)
      ChangeValue(DamageSystem_Shjc, sy, 0.25)
      ChangeValue(Correction_Jzsh, sy, 0.25)
      u:addskill("A1A3")
      u:become("从者")
      u:addstexiao(var.name, "暴击系统触发效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata("裁缝术冷却") then
          u:settimedata("裁缝术冷却", 3)
          tg:effectadd("AATX\\[AATxNew]Blood03.mdl", "chest")
          local dh = 0.008
          if tg:isnormal() then
            dh = 0.1
          elseif tg:iselite() then
            dh = 0.03
          end
          LossHpUnit({
            u = u,
            tg = tg,
            damage = dh * tg:gethp(),
            perhp = 0,
            maxhp = 0,
            bj = "[生命损耗]红阎魔裁缝术"
          })
        end
      end)
      ac.loop(30000, function()
        if u:isalive() then
          u:clearbuff("眩晕")
          u:clearbuff("僵直")
          u:clearbuff("缠绕")
          u:clearbuff()
          u:effectadd("AATX\\[AATxNew]Colour07.mdl")
          u:curehp(u.handle, 0, 10, 2)
        end
      end)
    end,
    effectname = "|cFFFF0000剪|r|cFFFF2214舌|r|cFFFF4429麻|r|cFFFF663D雀|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFFF0000唯一 光明 兽 自然|r\n|cFFFF663D提升25%近战伤害\n提升25%伤害加成|r\n|cFFFF0000【心眼(伪)】|r\n|cFFFF663D提升12%暴击率\n提升25%暴击伤害|r\n|cFFFF0000【裁缝术】|r\n|cFFFF663D暴击时损耗目标10%(3%/0.8%)当前生命值(冷却3秒)|r\n|cFFFF0000【星之笼】|r\n|cFFFF663D每隔30秒清除自身负面状态并恢复10%最大生命值\n降低周围900范围敌军10护甲与25%伤害能力|r",
    effectart = "war3mapImported\\BTNEwl_Enma_01.blp"
  },
  {
    name = "安克雷奇",
    weight = 100,
    lv = 3,
    key = {"唯一", "水"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:ishasskill(SKILL_TESHUYINGXIONG) then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cFFB58C88「安克雷奇…是白鹰重巡。和巴尔的摩她们…是朋友！和老师也是…嗯！最好的…！」|r")
      PlayGlobalSound(Sound_Aklq)
      u:setdata("安克雷奇-专属弹幕伤害", 1)
      local data1 = 0
      local data2 = 0
      
      local function refresh_saijier_bonus()
        ChangeValue(Damage_Element_Water, sy, -data1)
        ChangeValue(Correction_Gun, sy, -data2)
        local citiao1 = u:getstate("水变异")
        data1 = 0.01 * citiao1
        data2 = 0.01 * citiao1
        ChangeValue(Damage_Element_Water, sy, data1)
        ChangeValue(Correction_Gun, sy, data2)
      end
      
      refresh_saijier_bonus()
      ac.loop(3000, refresh_saijier_bonus)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not info.ismeleedamage and not info.isvestdamage and not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 1)
          local x, y = u:getxy()
          local a = AngleBetweenUnits(u.handle, tg.handle)
          local txsh = 500 * u:getdata("安克雷奇-专属弹幕伤害") * u:getlevel()
          ac.timer(100, 3, function()
            unifycreate({
              owner = u.handle,
              model = "zidan1.mdl",
              modelname = "安克雷奇弹幕",
              modelsize = 0.5,
              height = 90,
              damage = txsh,
              damagetype = 2,
              x = x,
              y = y,
              time = 1,
              speed = 3000,
              volume = 90,
              angle = a,
              angleoffset = 6,
              attenua = 1,
              attenuacount = 3,
              life = 10,
              isbullet = false,
              isvest = false,
              isignorearmor = false,
              startfunc = function(mj)
                mj:setdata("安克雷奇-专属弹幕")
              end
            })
          end)
        end
      end)
    end,
    effectname = "|cFFF2D4C7安克|r|cFFD8D5E0雷奇|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFF2D4C7水 唯一\nRiddle a riddle|r\n|cFFD8D5E0提升[水变异*1%]水属性伤害\n提升[水变异*1%]枪械伤害\n每波开始时获得持续120秒的极速状态\n子弹50%附带一次水属性范围特效伤害,冷却3秒|r\n|cFFF2D4C7Hide and seek|r\n|cFFD8D5E0受到致死伤害时抵挡该次伤害并2秒内无敌,过波刷新|r\n|cFFF2D4C7专属弹幕|r\n|cFFD8D5E0直接伤害时10%发动一次特殊弹幕,触发冷却1秒|r",
    effectart = "war3mapImported\\BTNEwl_Cq_Aklq"
  },
  {
    name = "穿刺伯爵",
    clickfunc = function(u, ewl)
      local sy = u.ownerid
      if u:isalive() and u:ishasshw() and u:getdata("阿卡多-永恒之命") >= 2 and u:getdata("吸血鬼变异数量") >= 6 then
        AdvanceGet["阿卡多"](u)
      end
    end,
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "吸血鬼",
      "黑暗"
    },
    unique = true,
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
      ciyuanget(u, var)
      u:chat("|cFFCC0000那么，现在是战争的时间了|r")
      PlayGlobalSound(Sound_Akaduo_N_01)
      u:become("噩梦具现化")
      ChangeValue(Correction_Gun_Pistol, sy, 0.1)
      ChangeValue(Correction_Gun, sy, 0.025)
      u:setdata("阿卡多-血液储量", 0)
      u:setdata("阿卡多-吸血鬼恢复", 0)
      u:setdata("阿卡多-生命吞噬数量", 0)
      u:setdata("阿卡多-永恒之命", 0)
      local gun = 0
      local bull = 0
      local lw = 0
      local jc = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Gun, sy, 0.1 * (-1 * gun))
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * jc))
        gun = 0.25 * u:getdata("阿卡多-永恒之命")
        if u:hasdata("变异判定-阿卡多") then
          lw = 0.25 * u:getdata("阿卡多-永恒之命")
          jc = 0.1 * u:getdata("阿卡多-血液储量") / 100
        else
          lw = 0
          jc = 0
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * jc))
        ChangeValue(Correction_Gun, sy, 0.1 * (1 * gun))
      end)
      local hp = 0
      local max = 0
      ac.loop(1000, function()
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, -1 * hp)
        u:changedata("阿卡多-血液储量", -1 * u:getdata("阿卡多-吸血鬼恢复"))
        if u:getdata("阿卡多-血液储量") < 0 then
          u:setdata("阿卡多-血液储量", 0)
        end
        if IsTimeNight() then
          if u:hasdata("变异判定-阿卡多") then
            max = 3
            u:changedata("阿卡多-血液储量", 0.2)
          else
            max = 2
            u:changedata("阿卡多-血液储量", 0.1)
          end
        elseif u:hasdata("变异判定-阿卡多") then
          max = 1.6
        else
          max = 0.8
        end
        local dhp = 100 - u:getperhp()
        hp = u:getdata("阿卡多-血液储量") / 10
        if hp >= max then
          hp = max
        end
        if dhp <= hp then
          hp = dhp
        end
        u:setdata("阿卡多-吸血鬼恢复", hp)
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, 1 * hp)
      end)
    end,
    effectname = "|cFFA60000穿|r|cFFC41010刺|r|cFFE12121伯|r|cFFFF3131爵|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFA60000唯一 吸血鬼 黑暗|r\n|cFFA60000【王牌死神】|r\n|cFFFF3131提升10%手枪伤害\n提升[2.5%+2.5%*永恒之命]枪械伤害|r\n|cFFA60000【生命储存】|r\n|cFFFF3131夜晚血液储量每秒恢复0.1%\n生命值缺失时消耗等量血液储量恢复生命值\n每秒恢复[血液储量上限/10]\n白天上限0.8%,夜晚上限2%|r\n|cFFA60000【生命吞噬】|r\n|cFFFF3131杀敌时提升1生命上限与1%当前血液储量\n每杀死500个单位获得1点永恒之命\n杀死BOSS时获得1点永恒之命|r\n|cFFA60000【生命解放】|r\n|cFFFF3131永恒之命≥2,吸血鬼变异≥6时点击进阶|r",
    effectart = "war3mapImported\\BTNEwl_Akaduo_Chuanqi.blp"
  },
  {
    name = "血液操控",
    weight = 100,
    lv = 3,
    key = {"唯一", "灵魂"},
    unique = true,
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
      ciyuanget(u, var)
      SendMsgAll("|cFFFF2424『|r|cFFFF2B2A到|r|cFFFF3330此|r|cFFFF3A36为|r|cFFFF423C止|r|cFFFF4942吧|r|cFFFF5148…|r|cFFFF584E…|r|cFFFF5F54请|r|cFFFF675A不|r|cFFFF6E60要|r|cFFFF7666再|r|cFFFF7D6C和|r|cFFFF8572我|r|cFFFF8C78接|r|cFFFF937E触|r|cFFFF9B84了|r|cFFFFA28A…|r|cFFFFAA90…|r|cFFFFB196』|r")
      PlayGlobalSound(Sound_Lswl_01)
      u:addhealthrefresh(function(set_value, bs)
        set_value(DamageSystem_Xxzq, sy, bs)
      end)
      ChangeValue(Correction_Jzsh, sy, 0.15)
      ChangeValue(KillReward_MHp, sy, 1)
      ac.loop(10000, function()
        if not Movie_Boolean and u:isalive() and u:getdata("战斗时间") > 0 and u:getluckrandom(10) then
          u:sendmessage("|cFFFF2424[血液操纵]进入不高兴状态……")
          local snd = {
            Sound_Lswl_bgx_01,
            Sound_Lswl_bgx_02,
            Sound_Lswl_bgx_03
          }
          u:playseensound(snd[GetRandomInt(1, #snd)])
          u:settimedata("栗山未来-不高兴状态", 9.5)
          ChangeValue(DamageSystem_Shjc, sy, 0.5)
          ChangeValue(Correction_Jzsh, sy, 0.5)
          ChangeValue(DamageSystem_Xxz, sy, 5)
          ChangeValue(DamageSystem_XxzJz, sy, 10)
          ac.loop(300, function(timer)
            u:effectadd("war3mapImported\\texiao_xuebao.mdx")
            if not u:hasdata("栗山未来-不高兴状态") then
              ChangeValue(DamageSystem_Shjc, sy, -0.5)
              ChangeValue(Correction_Jzsh, sy, -0.5)
              ChangeValue(DamageSystem_Xxz, sy, -5)
              ChangeValue(DamageSystem_XxzJz, sy, -10)
              timer:remove()
            end
          end)
        end
      end)
      u:addstexiao(var.name, "近战伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 0.25)
          local mfsh = 0.1 * u:getmaxhp()
          u:curehp(u.handle, 0, 0.25, 2)
          DamageUnit({
            bj = "栗山未来(血太刀)",
            unit = tg.handle,
            source = u.handle,
            damage = mfsh,
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
    effectname = "|cFFFF2424血|r|cFFFF584E液|r|cFFFF8C78操|r|cFFFFC0A2控|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFFF2424唯一 灵魂|r\n|cFFFFC0A2提升15%近战伤害|r\n|cFFFF2424【贫血】|r\n|cFFFFC0A2提升[背水*100%]伤害吸血效果\n入战时,每10秒10%进入不高兴状态10秒:\n[提升10近战吸血\n提升5伤害吸血\n提升50%伤害加成\n提升50%近战伤害]|r\n|cFFFF2424【血太刀】|r\n|cFFFFC0A2杀敌提升1生命上限\n近战伤害附带[生命上限*0.1]灵力伤害并恢复0.25%生命值,冷却0.25秒|r",
    effectart = "Cq_Lishanweilai.tga"
  },
  {
    name = "圣火女神",
    clickfunc = function(u, var)
      local sy = u.ownerid
      if not u:hasdata("圣火女神-关闭给予") then
        u:setdata("圣火女神-关闭给予")
        u:sendmessage("|cFF80FFFF[圣火女神]繁荣之力关闭")
      else
        u:deldata("圣火女神-关闭给予")
        u:sendmessage("|cFF80FFFF[圣火女神]繁荣之力开启")
      end
    end,
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "光明",
      "同奏"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if not u:isgirl() then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cFF66FFFF「|r|cFF77FFFF封|r|cFF88FFFF印|r|cFF99FFFF神|r|cFFAAFFFF的|r|cFFBBFFFF力|r|cFFCCFFFF量|r|cFFDDFFFF」|r")
      ac.wait(2400, function()
        SendMsgAll("|cFF66FFFF「|r|cFF74FFFF忍|r|cFF82FFFF受|r|cFF90FFFF着|r|cFF9EFFFF限|r|cFFACFFFF制|r|cFFB9FFFF与|r|cFFC7FFFF不|r|cFFD5FFFF便|r|cFFE3FFFF」|r")
      end)
      ac.wait(5300, function()
        SendMsgAll("|cFF66FFFF「|r|cFF75FFFF快|r|cFF85FFFF乐|r|cFF94FFFF地|r|cFFA3FFFF生|r|cFFB3FFFF活|r|cFFC2FFFF下|r|cFFD1FFFF去|r|cFFE0FFFF」|r")
      end)
      PlayGlobalSound(Sound_Hesitiya_01)
      Danwei_Hesitiya = u.handle
      u:getgoddessforce(3, true)
      u:adddivinity(2)
      u:become("沉重")
      u:changedata("幸运", 5)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        local sy2 = xq.ownerid
        xq:changedata("幸运", 1)
        xq:changedata("全属性增幅", 0.05)
        ChangeValue(DamageSystem_Shjc, sy2, 0.25)
      end)
      local add = 0
      local cs = 0
      local cs2 = 0
      ac.loop(3000, function()
        cs = cs + 1
        if cs == 20 then
          cs = 0
          local sj = u:getdata("女神力")
          u:addallstats(sj)
          u:sendmessage("|cFF80FFFF[圣火女神]女神之力-提升" .. sj .. "点全属性|r")
        end
        if u:isalive() and not u:hasdata("圣火女神-关闭给予") then
          cs2 = cs2 + 1
          if cs2 == 20 then
            cs2 = 0
            ForGroupLuaNew(Group_PlayHero, function(xq)
              if xq:isalive() then
                xq:additem("I038")
                xq:sendmessage("|cFF80FFFF[圣火女神]繁荣之力-获得资源箱")
              end
            end)
          end
        end
      end)
    end,
    effectname = "|cFF80FFFF圣|r|cFF98FFFF火|r|cFFB0FFFF女|r|cFFC8FFFF神|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF80FFFF神性2 女神力3 唯一 同奏 光明|r\n|cFFC8FFFF提升5点幸运|r\n|cFF80FFFF【神之眷族】|r\n|cFFC8FFFF提升全队1点幸运\n提升全队5%全属性\n提升全队25%伤害加成|r\n|cFF80FFFF【繁荣之力】(点击切换开关)|r\n|cFFC8FFFF自身每存活60秒,所有存活玩家获得一份资源箱物品|r\n|cFF80FFFF【女神之力】|r\n|cFFC8FFFF每60秒提升[女神力*1]点全属性|r",
    effectart = "war3mapImported\\BTNEwl_Hesitiya_Chuanqi.blp"
  },
  {
    name = "征服王",
    weight = 100,
    lv = 3,
    key = {
      "战士",
      "雷",
      "同奏"
    },
    unique = false,
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
      ciyuanget(u, var)
      u:chat("征服王伊斯坎达尔,将为你开辟道路！")
      u:playsound(Sound_Iskandar_01)
      u:become("从者")
      u:become("王")
      u:adddivinity(1)
      ChangeValue(DamageSystem_Baoshang, sy, 0.1)
      u:addskill("S066")
      u:addskill("S067")
      local data1 = 0
      local data2 = 0
      
      local function refresh_saijier_bonus()
        ChangeValue(DamageSystem_Shjc, sy, -data1)
        ChangeValue(Damage_Element_Thunder, sy, -data2)
        data1 = 0.01 * u:getstate("战士变异")
        data2 = 0.005 * u:getstate("雷变异")
        ChangeValue(DamageSystem_Shjc, sy, data1)
        ChangeValue(Damage_Element_Thunder, sy, data2)
      end
      
      refresh_saijier_bonus()
      ac.loop(3000, refresh_saijier_bonus)
      AddAllSTexiao(var.name, "伤害系统计算效果", function(args)
        local info = args.damageinfo
        if args.u:ishasbuff("B09I") then
          info.jc = info.jc + 0.25
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 3)
          local x, y = tg:getxy()
          u:playsound(ThunderClapCaster)
          Effectcreate("ATx\\[ATxNew]Thunder_02.mdl", x, y, 0, 1.8)
          local mfsh = 50000
          for _, xq in ac.selector():in_rangexy(x, y, 375):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "征服王(雷之征服者)",
              unit = xq.handle,
              source = u.handle,
              damage = mfsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "雷"
            })
            xq:buffset(u.handle, 1, "眩晕")
          end
        end
      end)
    end,
    effectname = "|cFFFF8040征服王|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFFFF8040神性1 战士 雷 同奏|r\n|cFFFFFF84提升10%移速\n提升10%暴击伤害\n提升[战士变异*1%]伤害加成\n提升[雷变异*0.5%]雷属性伤害|r\n|cFFFF8040【领袖气质】|r\n|cFFFFFF84提升自身与1800范围友军25%伤害加成|r\n|cFFFF8040【雷之征服者】|r\n|cFFFFFF84直接伤害时10%附带375范围[50000]雷魔力伤害与1秒眩晕,冷却3秒|r",
    effectart = "war3mapImported\\BTNEwl_Zhengfuwang.blp"
  },
  {
    name = "孤高的独行者",
    clickfunc = function(u, ewl)
      local sy = u.ownerid
      if u:hasdata("变异判定-Bloo") then
        if not u:hasdata("Bloo-了结你") and BossBattle and u:isalive() and Group_Counts(Group_Xingcunzu) <= 1 and u:isexist() then
          u:buffset(u.handle, 3, "暂停")
          u:buffset(u.handle, 3, "绝对闪避")
          u:buffset(u.handle, 4.5, "无敌")
          StopSoundBJ(BGM, false)
          ac.wait(3000, function()
            ChangeBGM(BGM_Bloo)
            SendMsgAll("|cFF0041FFBGM:Beautiful Lies|r")
          end)
          if GetRandomInt(1, 2) == 1 then
            PlayGlobalSound(Sound_Bloo_14)
            u:chat("结束了")
          else
            PlayGlobalSound(Bloo_EX)
            u:chat("我一个人")
            ac.wait(1900, function()
              u:chat("足够了。")
            end)
          end
          u:setdata("Bloo-了结你")
          ac.wait(3000, function()
            if GetRandomInt(1, 2) == 1 then
              PlayGlobalSound(Bloo_Bao)
            else
              PlayGlobalSound(Sound_Bloo_12)
            end
            u:addskill("A0B0")
            u:addskill("S00C")
            ChangeValue(DamageSystem_Shjc, sy, 0.05)
            ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 125)
            ChangeValue(DamageSystem_Ssjianshao, sy, 0.75, 1)
            u:effectadd("war3mapImported\\blue_fire_explosion.mdx")
          end)
        end
      elseif u:isalive() and BossBattle and u:ishasshw() and Group_Counts(Group_Xingcunzu) <= 1 then
        AdvanceGet.Bloo(u)
      end
    end,
    weight = 100,
    lv = 3,
    key = {
      "唯一",
      "影",
      "战士",
      "炎"
    },
    unique = true,
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
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Bloo_N_01)
      u:chat("|cFF0159FE剁一只猫烤一只猫|r")
      Weiyi_New[18] = true
      u:addskill("S06I")
      ChangeValue(DamageSystem_Baoji, sy, 12)
      ChangeValue(DamageSystem_Baoshang, sy, 0.12)
      ChangeValue(DamageSystem_Shjc, sy, 0.12)
      ChangeValue(Damage_Element_Fire, sy, 0.12)
    end,
    effectname = "|cFF0159FE孤高的独行者|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF0159FE唯一 战士 影 炎|r\n|cFFB5CFFF提升12%移速|r\n|cFFB5CFFF提升12%暴击率|r\n|cFFB5CFFF提升12%暴击伤害|r\n|cFF0159FE【蓝炎驱动】|r\n|cFFB5CFFF提升12%火属性伤害|r\n|cFFB5CFFF提升12%伤害加成|r\n|cFF0159FE【我一个人就足够了】|r\n|cFFB5CFFFBOSS战时仅剩自己时点击进阶|r",
    effectart = "war3mapImported\\BTNEwl_Gugaozhe.blp"
  }
}
Vars_Ciyuan_Lv4 = {}
Vars_Ciyuan_Lv5 = {
  {
    name = "塞缪尔",
    weight = 600,
    lv = 5,
    key = {
      "唯一",
      "机械",
      "战士"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:ishasitem("I05C") or u:hasdata("武器判定-高频村雨刀") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("OK Let's dance")
      PlayGlobalSound(Sound_Sam_01)
      ChangeValue(Correction_MHp, sy, 0.010000000000000002)
      ChangeValue(Correction_Jzsh, sy, 0.1)
      ChangeValue(WeaponCount_Katana, sy, 0.5)
      ChangeValue(DamageSystem_Shjc, sy, 0.12)
      u:addhealthrefresh(function(set_value, bs)
        set_value(DamageSystem_Baoshang, sy, 1.5 * bs)
      end)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local tg = args.tg
        if not tg:hasdata("塞缪尔-杀敌判定") then
          ac.wait(10, function()
            tg:deldata("塞缪尔-杀敌判定")
            if not tg:isalive() then
              ChangeValue(Correction_Jzsh, sy, 1.0E-4)
            end
          end)
        end
      end)
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and not u:hasdata("塞缪尔-决死冷却") then
          args.dt = false
          u:settimedata("塞缪尔-决死冷却", 240)
          u:buffset(u.handle, 0.1, "绝对闪避")
          u:sendmessage("|cFFFF0000塞缪尔-亡命徒|r")
        end
      end)
    end,
    effectname = "|cFFFF0000塞|r|cFFCC0D0D缪|r|cFF991A1A尔|r",
    effecttext = "|cFFCC66FF[超凡]|r\n|cFFFF0000唯一 机械 战士|r\n|cFF991A1A提升12%伤害加成|r\n|cFFFF0000【亡命徒】|r\n|cFF991A1A提升1%生命上限\n提升[背水*150%]暴击伤害\n受到致死伤害时抵挡该次伤害,触发冷却240秒|r\n|cFFFF0000【罗德里格斯新阴流】|r\n|cFF991A1A提升50%武士刀伤害\n提升10%近战伤害\n近战伤害杀敌提升0.01%近战伤害|r\n|cFFFF0000【激流山姆】|r\n|cFF991A1A位移冷却时间降低25%\n对[无极]提升100%伤害\n受到[无极]的伤害提升100%\n[高频村雨刀]获得以下加成:\n[基础伤害提升100%\n激流发动时获得0.3秒绝对闪避\n激流充能时间降低至14秒]|r",
    effectart = "Ewl_Cq_Saimiuer",
    test = [[

        ]]
  },
  {
    name = "肃正协议",
    weight = 100,
    lv = 5,
    key = {"唯一", "机械"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("神器判定-独立的肃正核心") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cFFD83C48『|r|cFFDA424D软|r|cFFDC4852弱|r|cFFDE4D58不|r|cFFE0535D堪|r|cFFE35962的|r|cFFE55F67肮|r|cFFE7646D脏|r|cFFE96A72异|r|cFFEB7077物|r|cFFED767C，|r|cFFEF7B82你|r|cFFF18187们|r|cFFF4878C…|r|cFFF68D91…|r|cFFF89297』|r")
      ac.wait(3000, function()
        SendMsgAll("|cFFD83C48『|r|cFFDA414C有|r|cFFDC4651机|r|cFFDD4B55体|r|cFFDF505A！|r|cFFE1555E本|r|cFFE35963小|r|cFFE55E67姐|r|cFFE6636C绝|r|cFFE86870对|r|cFFEA6D75…|r|cFFEC7279绝|r|cFFEE777D对|r|cFFEF7C82不|r|cFFF18186会|r|cFFF3868B怕|r|cFFF58A8F你|r|cFFF78F94的|r|cFFF89498』|r")
      end)
      ChangeValue(DamageSystem_Shjc, sy, 0.1)
      u:changedata("效果增强-机械", 0.25)
      local add = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        add = 0.1 * u:getstate("机械变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 3)
          ForGroupLuaNew(Group_Monster, function(xq)
            xq:changearmor(-1)
            xq:changedata("怪物-额外受伤", 0.01)
            if xq:hasdata("系统-机械单位") then
              xq:buffset(u.handle, 2.5, "眩晕")
            end
          end)
        end
      end)
    end,
    effectname = "|cFFD83C48肃|r|cFFE45D66正|r|cFFF07D83协|r|cFFFC9EA1议|r",
    effecttext = "|cFFCC66FF[超凡]|r\n|cFFD83C48唯一 机械|r\n|cFFFC9EA1提升10%伤害加成|r\n|cFFD83C48【幽灵信号】|r\n|cFFFC9EA1直接伤害时使全图怪物降低1护甲并提升1%额外受伤\n如果是机械单位会眩晕2.5秒\n(冷却3秒)|r\n|cFFD83C48【肃正之心】|r\n|cFFFC9EA1提升25%机械效果增强\n提升[1%*机械变异]伤害加成|r",
    effectart = "Cq_Suzhenghexin",
    test = "            "
  },
  {
    name = "或守鞠亚",
    weight = 10,
    lv = 5,
    key = {
      "唯一",
      "精灵",
      "机械"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:isinmaxvar("机械") then
        add = add + 500
      end
      return add
    end,
    condition = function(u)
      local b = false
      if (u:hasdata("变异判定-奥秘修女") or u:hasdata("变异判定-全知天使")) and u:hasdata("变异判定-佛拉克西纳斯") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      ChangeValue(DamageSystem_Shjc, sy, 0.1)
      u:changedata("精灵变异补正", 100)
      local add = 0
      local jx = 0
      local sx = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        add = 1 * u:getstate("精灵变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jx)
        ChangeValue(Damage_Element_All, sy, -sx)
        jx = 0.1 * u:getstate("机械变异")
        sx = 0.01 * u:getstate("机械变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * jx)
        ChangeValue(Damage_Element_All, sy, sx)
      end)
      ac.wait(100, function()
        u:uivar_change({
          keyname = "或守鞠亚",
          keytype = "传奇栏",
          text = "|cFFC9CBCD或|r|cFFB6B9D9守|r|cFFA2A6E6鞠|r|cFF8F94F2亚|r\n|cFFCC66FF[超凡]|r\n|cFFC9CBCD唯一 精灵 机械|r\n|cFF8F94F2提升10%伤害加成|r\n|cFFC9CBCD【Irregular】|r\n|cFF8F94F2提升[机械变异*1%]伤害加成\n提升[机械变异*1%]全属性伤害|r\n|cFFC9CBCD【恋爱吧，士道！】|r\n|cFF8F94F2提升[10%*精灵传奇]伤害加成\n提升100%精灵变异获取补正|r",
          icon = "Cq_Huoshoujuya",
          dx = 2.75,
          ishasphoto = true
        })
      end)
    end,
    effectname = "|cFFC9CBCD或|r|cFFB6B9D9守|r|cFFA2A6E6鞠|r|cFF8F94F2亚|r",
    effecttext = "|cFFCC66FF[超凡]|r\n|cFFC9CBCD唯一 精灵 机械|r\n|cFF8F94F2提升10%伤害加成|r\n|cFFC9CBCD【Irregular】|r\n|cFF8F94F2提升[机械变异*1%]伤害加成\n提升[机械变异*1%]全属性伤害|r\n|cFFC9CBCD【恋爱吧，士道！】|r\n|cFF8F94F2提升[10%*精灵传奇]伤害加成\n提升100%精灵变异获取补正|r",
    effectart = "Cq_Huoshoujuya"
  },
  {
    name = "水仙女人鱼",
    weight = 500,
    lv = 5,
    key = {
      "唯一",
      "水",
      "黑暗",
      "珠泪哀歌"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:getdata("珠泪哀歌变异数量") >= 3 then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("|cFF3366FF静静哭泣吧，蔚蓝海中的花啊----|r")
      ac.wait(3200, function()
        u:chat("|cFF3366FF化作珍珠，吟唱哀伤的歌----|r")
      end)
      PlayGlobalSound(Sound_Zhulei_Shuixian)
      ChangeValue(Hero_Tili_Huifu, sy, 0.5)
      ChangeValue(DamageSystem_Shjc, sy, 0.05)
      ChangeValue(Damage_Element_Water, sy, 0.05)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 125)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.5, 1)
      local add = 0
      local add2 = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        ChangeValue(Damage_Element_Water, sy, -add2)
        add = 0.1 * u:getstate("水变异")
        add2 = 0.01 * u:getstate("水变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        ChangeValue(Damage_Element_Water, sy, add2)
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          u:settimedata(var.name .. "-特效冷却", 2)
          local mfsh = u:getlevel() * 2500
          DamageUnit({
            bj = "水仙女人鱼(奏响哀唱)",
            unit = tg.handle,
            source = u.handle,
            damage = mfsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "水"
          })
          tg:changearmor(-1)
          tg:changedata("怪物-额外受伤", 0.01)
        end
      end)
    end,
    effectname = "|cFF3366FF珠|r|cFF396CFF泪|r|cFF3E71FF哀|r|cFF4477FF歌|r|cFF4A7DFF.|r|cFF4F82FF水|r|cFF5588FF仙|r|cFF5B8EFF女|r|cFF6093FF人|r|cFF6699FF鱼|r",
    effecttext = "|cFFCC66FF[超凡]|r\n|cFF3366FF唯一 水 黑暗 珠泪哀歌|r\n|cFF6699FF提升0.5体力恢复\n提升[5%+1%*水变异]伤害加成\n提升[5%+1%*水变异]水属性伤害|r\n|cFF3366FF【奏响哀唱】|r\n|cFF6699FF直接伤害时附带[等级*2500]水魔力伤害,冷却2秒\n触发时使目标永久降低1护甲并提升1%额外受伤|r\n|cFF3366FF【珍珠世界】|r\n|cFF6699FF自身视为处于水域\n自身处于水域时:\n[直接伤害时造成水属性伤害\n提升125额外移速\n提升50%伤害减免]|r",
    effectart = "Cq_Zhulei_Shuixian"
  },
  {
    name = "莉可莉丝",
    weight = 25,
    lv = 5,
    key = {
      "唯一",
      "战士",
      "同奏",
      "百合"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("变异判定-井上泷奈") then
        add = add + 100
      end
      return add
    end,
    condition = function(u)
      local b = true
      if u:ishasskill(SKILL_TESHUYINGXIONG) then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:chat("|cFFFF3333想做的事最优先！")
      PlayGlobalSound(Sound_Qianshu_01)
      local add1 = 0
      local add2 = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add1)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * -add2)
        local z = 0
        if u:isgirl() then
          z = u:getdata("百合变异数量")
        end
        add1 = 0.1 * z
        add2 = 0.01 * z
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add1)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * add2)
      end)
      Weiyi_New[19] = true
      Danwei_Jinmuqianshu = u.handle
      if u:hasdata("变异判定-井上泷奈") then
        ac.wait(2500, function()
          PlayBGM({
            bgm = BGM_Lkls_01,
            time = 170,
            ID = 207,
            unit = u.handle
          })
          SendMsgAll("|cFFFF3366BGM:《花の塔》|r")
          ChangeValue(Correction_Gun, sy, 0.1)
          u:addstexiao(var.name, "杀敌效果", function(args)
            ChangeValue(Correction_Gun, sy, 1.0E-4)
          end)
        end)
      end
      u:setdata("千束-Q体力消耗", 0)
      u:setdata("千束-W体力消耗", 0)
      u:addstexiao(var.name, "过波时效果", function(args)
        ChangeValue(Correction_Gun, sy, 0.005000000000000001)
        ChangeValue(DamageSystem_Shjc, sy, 0.005)
      end)
      u:addstexiao(var.name, "伤害显示后效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("千束-和平主义者生效时间") and not info.sk and info.damage >= tg:gethp() and not tg:isboss() and not tg:hasdata("千束-已饶恕单位") and not tg:hasdata("暗神-反物质黑洞") then
          tg:setdata("千束-已饶恕单位")
          info.sk = true
          info.damage = 0
          tg:effectadd("Abilities\\Spells\\Human\\Polymorph\\PolyMorphTarget.mdl", "overhead")
          tg:settimedata("千束-饶恕时间", 3)
          tg:buffset(u.handle, 2, "眩晕")
        end
      end)
      u:addstexiao(var.name, "被施加Buff时效果-暂停", function(args)
        if args.u:hasdata("千束-子弹时间") and not Keyan_Guomintizhi then
          args.time = 0
        end
      end)
      
      local function func2()
        if not u:hasdata("千束-子弹时间剩余时间") then
          u:setdata("千束-子弹时间")
          local tt = flytext({
            unit = u.handle,
            text = "5.0",
            size = 10,
            time = -1,
            r = 255,
            g = 100,
            b = 100,
            height = 0,
            xspeed = 0,
            yspeed = 0
          })
          ac.loop(50, function(timer)
            u:setdata("千束-子弹时间")
            local time = u:getdata("千束-子弹时间剩余时间")
            u:changedata("千束-子弹时间剩余时间", -0.05)
            SetTextTagText(tt, string.format("%.1f", time), TextTagSize2Height(10))
            SetTextTagPosUnit(tt, u.handle, 0)
            if not u:isalive() or u:getdata("千束-子弹时间剩余时间") < 0 then
              TimerDestroyTextTag(0, tt)
              u:curetili(-u:getdata("千束-子弹时间体力消耗"))
              u:deldata("千束-子弹时间")
              u:deldata("千束-子弹时间剩余时间")
              u:deldata("千束-子弹时间体力消耗")
              timer:remove()
            end
          end)
        end
        u:playseensound(Sound_Qianshu_02)
        u:clearbuff("暂停")
        u:buffset(u.handle, 1, "绝对闪避")
        u:setdata("千束-子弹时间剩余时间", 8)
      end
      
      u:addstexiao(var.name, "进入战斗状态时", function(args)
        local u = args.u
        if not u:hasdata(var.name .. "-入战冷却") then
          u:settimedata(var.name .. "-入战冷却", 60)
          u:sendmessage("|cFFFF3333[锦木千束]子弹时间")
          func2()
        end
      end)
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and not u:hasdata("千束-子弹时间决死冷却") then
          args.dt = false
          func2()
          u:settimedata("锦木千束-死亡抗拒", 3)
          u:settimedata("千束-和平主义者生效时间", 8)
          u:sendmessage("|cFFFF3333[锦木千束]和平主义者")
          u:settimedata("千束-子弹时间决死冷却", 360)
        end
      end)
    end,
    effectname = "|cFFFF3333电|r|cFFFF4942波|r|cFFFF5F50塔|r|cFFFF755F的|r|cFFFF8A6D莉|r|cFFFFA07C可|r|cFFFFB68A莉|r|cFFFFCC99丝|r",
    effecttext = "|cFFCC66FF[超凡]|r\n|cFFFF3333唯一 战士 同奏 百合|r\n|cFFFF3333【子弹时间】|r\n|cFFFFCC99入战时进入8秒[子弹时间]:\n[触发时获得1秒绝对闪避\n免疫暂停\n装弹时间减少90%\n体力消耗滞后到子弹时间结束]\n冷却60秒|r\n|cFFFF3333【和平主义者】|r\n|cFFFFCC99受到致死伤害时:\n[进入8秒[子弹时间]\n进入3秒死亡抗拒\n8秒内自身伤害会饶恕目标]\n冷却360秒|r\n|cFFFF3333【杀人天才】|r\n|cFFFFCC99杀敌时提升0.01%枪械伤害(近战机体为近战伤害)与0.01%伤害加成\n过波时提升0.5%枪械伤害(近战机体为近战伤害)与0.5%伤害加成\n使用位移技能时,刷新另一位移技能并在[2+已叠加体力消耗]秒内提升其1体力消耗,可叠加\n触发位移刷新时降低该位移1体力消耗(不会低于基础值)|r\n|cFFFF3333【千束的卫矛花】(限女性)|r\n|cFFFFCC99提升[百合变异*1%]伤害加成\n提升[百合变异*0.1%]终结伤害|r",
    effectart = "war3mapImported\\BTNEwl_JInmuqianshu"
  }
}
local KongTaoluo_RevengeTargets = {
  ["樟贾宝"] = {
    lv = 2,
    key = {
      "机械",
      "战士",
      "黑暗",
      "复仇目标"
    },
    condition = function(u)
      return u:getdata("战士变异数量") >= 12
    end
  },
  ["朱笑嫣"] = {
    lv = 2,
    key = {
      "机械",
      "影",
      "黑暗",
      "复仇目标"
    },
    condition = function(u)
      return u:getdata("影变异数量") >= 5
    end
  },
  ["吴荣成"] = {
    lv = 2,
    key = {
      "机械",
      "黑暗",
      "复仇目标"
    },
    condition = function(u)
      return u:getdata("机械变异数量") >= 12
    end
  },
  ["斌伟信"] = {
    lv = 2,
    key = {
      "机械",
      "黑暗",
      "复仇目标"
    },
    condition = function(u)
      return u:getdata("光明变异数量") + u:getdata("黑暗变异数量") >= 20
    end
  },
  ["刘豪军"] = {
    lv = 3,
    key = {
      "机械",
      "战士",
      "光明",
      "黑暗",
      "复仇目标"
    },
    islast = true,
    condition = function(u)
      return true
    end
  }
}

local function kongruili_refresh_soul_attr(u)
  local sy = u.ownerid
  local old_attr = u:getdata("孔瑞丽-灵魂碎片全属性加成")
  if old_attr ~= 0 then
    u:changedata("全属性增幅", -old_attr)
  end
  local old_jz = u:getdata("孔瑞丽-灵魂碎片近战加成")
  if old_jz ~= 0 then
    ChangeValue(Correction_Jzsh, sy, 0.1 * -old_jz)
  end
  local soul = u:getdata("孔瑞丽-灵魂碎片")
  local add_attr = 0.025 * soul
  local add_jz = 0.01 * u:getdata("机械变异数量") * soul
  u:setdata("孔瑞丽-灵魂碎片全属性加成", add_attr)
  u:setdata("孔瑞丽-灵魂碎片近战加成", add_jz)
  u:changedata("全属性增幅", add_attr)
  ChangeValue(Correction_Jzsh, sy, 0.1 * add_jz)
end

local function kongruili_add_soul(u, count)
  u:changedata("孔瑞丽-灵魂碎片", count)
  kongruili_refresh_soul_attr(u)
  u:sendmessage("|cff5689b3[孔瑞丽]灵魂碎片+" .. count .. " 当前:" .. u:getdata("孔瑞丽-灵魂碎片") .. "|r")
  if u:getdata("孔瑞丽-灵魂碎片") >= 5 then
    u:uivar_change({
      keyname = "孔瑞丽",
      keytype = "传奇栏",
      icon = "Cq_Kongruili.tga"
    })
  end
end

local function kongtaoluo_add_dead_mark(u, name)
  local varbutton = u:uivar_get(name, "传奇栏")
  if varbutton and u:islocal() then
    if varbutton.revengeadd then
      varbutton.revengeadd:destroy()
    end
    varbutton.revengeadd = class.panel:builder({
      parent = varbutton,
      x = 0,
      y = 0,
      w = varbutton:get_width(),
      h = varbutton:get_height(),
      normal_image = "UIButton_Mwx_AliceSh.blp"
    })
  end
end

local function kongtaoluo_release_revenge_slot(u, name, data)
  u:changedata("系统-神力承载", -data.lv)
  u:changedata("传奇数量", -1)
  kongtaoluo_add_dead_mark(u, name)
  u:uivar_change({
    keyname = name,
    keytype = "传奇栏",
    text = "|cFF616368" .. name .. "\n|cFF999999死亡|r"
  })
end

local function kongtaoluo_revenge_target(u, name)
  if u:hasdata("孔涛罗-复仇终结") or u:hasdata("孔涛罗-已复仇-" .. name) then
    return false
  end
  if not u:hasdata("变异判定-" .. name) then
    return false
  end
  local data = KongTaoluo_RevengeTargets[name]
  if not data then
    return false
  end
  if data.islast then
    local soul_enough = u:getdata("孔瑞丽-灵魂碎片") >= 5
    u:setdata("孔涛罗-复仇终结")
    u:setdata("孔涛罗-八回合事件完成")
    u:setdata("孔涛罗-已复仇-" .. name)
    if soul_enough or GetRandom100(1 * u:getdata("孔瑞丽-灵魂碎片")) then
      u:setdata("孔涛罗-复仇成功")
      kongtaoluo_release_revenge_slot(u, name, data)
      u:sendmessage("|cFF616368[孔涛罗]与[" .. name .. "]同归于尽,无法继续复仇|r")
    else
    end
    kongtaoluo_add_dead_mark(u, "孔涛罗")
    u:uivar_change({
      keyname = "孔涛罗",
      keytype = "传奇栏",
      text = "|cFF3F3F49孔|r|cFF696C6F涛|r|cFF939896罗|r\n|cFF999999死亡|r"
    })
    u:changedata("传奇数量", -1)
    MovieAct["爱憎之园"](u)
    return true
  end
  local success = data.condition(u)
  success = success or GetRandom100(50)
  if success then
    u:setdata("孔涛罗-已复仇-" .. name)
    kongtaoluo_release_revenge_slot(u, name, data)
    kongruili_add_soul(u, 1)
    u:sendmessage("|cFF616368[孔涛罗]复仇成功:" .. name .. "|r")
    if name ~= "刘豪军" and not u:hasdata("孔涛罗-第一次复仇完成") then
      u:setdata("孔涛罗-第一次复仇完成")
      MovieAct["孔涛罗第一次复仇"](u)
    end
    return true
  end
  u:sendmessage("|cFF616368[孔涛罗]复仇失败:" .. name .. "|r")
  return false
end

local function kongtaoluo_try_revenge(u)
  local order = {
    "樟贾宝",
    "朱笑嫣",
    "吴荣成",
    "斌伟信"
  }
  for _, name in ipairs(order) do
    if not u:hasdata("孔涛罗-已复仇-" .. name) and u:hasdata("变异判定-" .. name) then
      kongtaoluo_revenge_target(u, name)
      return true
    end
  end
  return false
end

Vars_Ciyuan_Kongtaoluo = {
  {
    name = "孔瑞丽",
    clickfunc = function(u, ewl)
      if not u:hasdata("孔涛罗-获取解锁") then
        kongruili_add_soul(u, 1)
        u:setdata("孔涛罗-获取解锁")
        u:sendmessage("|cFF444A6E[鬼哭雨夜]解锁[孔涛罗]获取|r")
        PlayGlobalSound(Sound_Ktl_N01)
        u:uivar_change({
          keyname = "孔瑞丽",
          keytype = "传奇栏",
          text = "|cff5689b3孔瑞丽|r\n|cFFFFECC4[凡俗]|r\n|cff5689b3唯一 机械 灵魂\n【鬼哭雨夜】\n提升[灵魂碎片数量*2.5%]全属性\n提升[机械变异*0.1%*灵魂碎片数量]近战伤害|r",
          isclearclick = true
        })
        NPCChat({
          name = "|cff5689b3孔瑞丽|r",
          chaticon = "Chat_Krl.tga",
          chattext = {
            {
              text = "|cff7A7A7A……|r",
              time = 0
            }
          }
        })
      end
    end,
    weight = 25,
    lv = 1,
    key = {
      "唯一",
      "机械",
      "灵魂"
    },
    unique = true,
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
      ciyuanget(u, var)
      ac.loop(3000, function()
        kongruili_refresh_soul_attr(u)
      end)
    end,
    effectname = "|cff5689b3孔瑞丽|r",
    effecttext = "|cFFFFECC4[凡俗]|r\n|cff5689b3唯一 机械 灵魂\n提升[灵魂碎片数量*2.5%]全属性\n提升[机械变异*0.1%*灵魂碎片数量]近战伤害\n【鬼哭雨夜】\n[左键]后触发以下效果:\n[获取1枚灵魂碎片\n解锁[孔涛罗]获取]|r",
    effectart = "Cq_Ktl_Ruili"
  },
  {
    name = "孔涛罗",
    weight = 2500,
    lv = 3,
    key = {
      "唯一",
      "黑暗",
      "战士",
      "光明",
      "机械"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("孔涛罗-获取解锁") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Ktl_N02)
      ac.wait(2000, function()
        PlayGlobalSound(Sound_Ktl_N03)
      end)
      NPCChat({
        name = "|cFF3F3F49孔|r|cFF696C6F涛|r|cFF939896罗|r",
        chaticon = "Chat_Ktl.tga",
        chattext = {
          {
            text = "|cFF696C6F你也把我忘记了吗？|r",
            time = 0
          },
          {
            text = "|cFF696C6F我还记得。绝对不会忘记|r",
            time = 2
          }
        }
      })
      ac.wait(5700, function()
        PlayBGM({
          bgm = BGM_Ktl_N01,
          time = 90,
          ID = 253,
          unit = u.handle
        })
        SendMsgAll("|cFF3F3F49BGM:《Acid rain》|r")
        flashphoto({
          photo = "Ph_Ktl_01.tga",
          timeout = 3,
          timehold = 1,
          timein = 3
        })
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:buffset(u.handle, 7, "绝对闪避")
        end)
      end)
      NameID[sy] = "|cFF3F3F49孔|r|cFF696C6F涛|r|cFF939896罗|r"
      u:setplayername(NameID[sy])
      ModelReplace({
        u = u,
        model = "kongtaoluo.mdx",
        modelsize = 1,
        modelname = "|cFF3F3F49孔|r|cFF696C6F涛|r|cFF939896罗|r",
        modelicon = "kongtaoluo_portrait.tga"
      })
      u:effectadd("Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl", "hand left", -1)
      u:effectadd("Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl", "hand right", -1)
      ChangeValue(DamageSplit_CountJzMax, sy, 0.4)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      ChangeValue(HeroMenu_ExtraMoveSpeed_Bfb, sy, 0.25)
      ChangeValue(Hero_Tili_Huifu, sy, 0.1)
      u:addstexiao(var.name, "过波时效果", function(args)
        local forced = false
        if not u:hasdata("孔涛罗-八回合事件完成") then
          u:changedata("孔涛罗-获取后回合数", 1)
          if u:getdata("孔涛罗-获取后回合数") >= 8 then
            if not u:hasdata("变异判定-刘豪军") then
              herogetvar(u.handle, {
                Vars_Ciyuan_Kongtaoluo
              }, "次元", "刘豪军")
              if u:hasdata("变异判定-刘豪军") then
                u:changedata("传奇数量", 1)
              end
            end
            if u:hasdata("变异判定-刘豪军") then
              u:setdata("孔涛罗-八回合事件完成")
              ac.wait(10000, function()
                kongtaoluo_revenge_target(u, "刘豪军")
                forced = true
              end)
            end
          end
        end
        if not forced then
          kongtaoluo_try_revenge(u)
        end
      end)
      local add = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Jzsh, sy, 0.1 * -add)
        add = u:getdata("战士变异数量") * 0.05
        ChangeValue(Correction_Jzsh, sy, 0.1 * add)
      end)
      local tu = u
      Fskillreplace({
        unit = tu.handle,
        level = 2,
        skill_F = "S0DC",
        skill_X = "S0DD",
        name = "紫电掌",
        icon = "ReplaceableTextures\\CommandButtons\\BTNMonsoon.blp",
        isforce = true,
        efunc = function()
          if tu:hasdata("紫电掌-测试事件已注册") then
            return
          end
          tu:setdata("紫电掌-测试事件已注册")
          tu:addtrgevent("单位-发动技能", function(args)
            if args.skill ~= S2ID("S0DC") and args.skill ~= S2ID("S0DD") then
              return
            end
            local x, y = tu:getxy()
            local tx, ty = args.x, args.y
            local target
            if args.target and args.target ~= 0 then
              target = getunit(args.target)
              if target then
                tx, ty = target:getxy()
              end
            end
            local txsh = u:getagi() * 500 + 10000 * u:getlevel()
            local angle = tu:getface()
            if tx and ty and DistanceXY(x, y, tx, ty) > 1 then
              angle = AngleXY(x, y, tx, ty)
            end
            tu:setface(angle)
            u:playseensound(Sound_Zidianzhang_01)
            if GetRandom100(25) and not u:hasdata("紫电掌-音效冷却") then
              u:playseensound(Sound_Zidianzhang_02)
              u:settimedata("紫电掌-音效冷却", 5)
            end
            if not target and tx and ty then
              ForGroupLuaNew(Group_PlayHero, function(xq)
                if target then
                  return
                end
                if xq.handle ~= tu.handle and xq:isalive() and DistanceXY(tx, ty, xq:getxy()) <= 90 then
                  target = xq
                  tx, ty = target:getxy()
                end
              end)
            end
            if not target and tx and ty then
              for _, xq in ac.selector():in_rangexy(tx, ty, 90):is_enemy(tu.handle):ipairs() do
                xq = getunit(xq)
                if xq.handle ~= tu.handle and not xq:hasdata("免疫击退效果") then
                  target = xq
                  tx, ty = target:getxy()
                  break
                end
              end
            end
            local grabbed_friend
            if target then
              if target:hasdata("免疫击退效果") then
                target = nil
              elseif DistanceXY(x, y, tx, ty) > 600 then
                target = nil
              else
                local dx, dy = PolarXY(x, y, 150, angle)
                target:setxy(dx, dy)
                target:setface(angle + 180)
                if target:isingroup(Group_PlayHero) then
                  grabbed_friend = target
                end
              end
            end
            tu:settimedata("紫电掌格挡时间", 0.25)
            tu:settimedata("紫电掌格挡方向", 0.25, angle)
            EffectcreateArgs({
              effect = "Tx_Zidianzhang.mdx",
              x = x,
              y = y,
              size = 1.5,
              height = 100,
              zxz = angle,
              animespeed = 2
            })
            if grabbed_friend then
              u:playseensound(Sound_Zidianzhang_03)
              grabbed_friend:buffset(tu.handle, 4, "麻痹")
              grabbed_friend:buffset(tu.handle, 1, "僵直")
              LossHpUnit({
                u = tu,
                tg = grabbed_friend,
                maxhp = 50,
                bj = "紫电掌电击队友"
              })
            end
            local g = CreateGroupLua()
            for i = 1, 9 do
              local ddx, ddy = PolarXY(x, y, i * 100, angle)
              for _, xq in ac.selector():in_rangexy(ddx, ddy, 180):is_enemy(tu.handle):isnotingroup(g):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g)
                xq:buffset(tu.handle, 4, "麻痹")
                xq:buffset(tu.handle, 1, "僵直")
                DamageUnit({
                  bj = "紫电掌",
                  unit = xq.handle,
                  source = tu.handle,
                  damage = txsh,
                  level = 1,
                  type = "能量",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "雷"
                })
              end
            end
          end)
        end
      })
      ac.wait(100, function()
        u:uivar_change({
          keyname = "孔瑞丽",
          keytype = "传奇栏",
          icon = "Cq_Ktl_Ruili2.tga"
        })
        u:uivar_change({
          keyname = "孔涛罗",
          keytype = "传奇栏",
          text = "|cFF3F3F49孔|r|cFF696C6F涛|r|cFF939896罗|r\n|cFFFFAA00[传奇]|r\n|cFF616368唯一 战士 机械 黑暗 光明|r\n|cFF616368【藏天流刀法】|r\n|cFFA4AAA5提升[战士变异*0.5%]近战伤害\n近战伤害段数+1\n近战伤害上限+40%|r\n|cFF616368【义肢气功术】|r\n|cFFA4AAA5提升25%移速\n提升0.1体力恢复|r\n|cFF616368【电磁発劲】|r\n|cFFA4AAA5变化F技能|r\n|cFF616368【复仇剑鬼】|r\n|cFFA4AAA5过波时如果拥有[复仇目标]相关变异,将会进行复仇\n复仇成功时保留目标变异效果,不再占用槽位\n复仇成功时[孔瑞丽]灵魂碎片+1\n未满足条件时50%复仇成功,满足时则100%成功:\n[樟贾宝]:战士变异数量≥12\n[朱笑嫣]:影变异数量≥5\n[吴荣成]:机械变异数量≥12\n[斌伟信]:(光明变异+黑暗变异)数量≥20\n[刘豪军]:需主动点击复仇,不获得灵魂碎片\n获取[孔涛罗]8回合后必定强制获取[刘豪军]同时触发对刘豪军的复仇\n满足目标复仇条件时大幅提升获取概率|r"
        })
      end)
    end,
    effectname = "|cFF3F3F49孔|r|cFF696C6F涛|r|cFF939896罗|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF616368唯一 战士 机械 黑暗 光明|r\n|cFF616368【藏天流刀法】|r\n|cFFA4AAA5提升[战士变异*0.5%]近战伤害\n近战伤害段数+1\n近战伤害上限+40%|r\n|cFF616368【义肢气功术】|r\n|cFFA4AAA5提升25%移速\n提升0.1体力恢复|r\n|cFF616368【电磁発劲】|r\n|cFFA4AAA5变化F技能|r",
    effectart = "Ewl_Cq_Kongtaoluo",
    test = "            "
  },
  {
    name = "刘豪军",
    clickfunc = function(u, var)
      if not u:hasdata("孔涛罗-八回合事件完成") then
        kongtaoluo_revenge_target(u, var.name)
      end
    end,
    weight = 10,
    lv = 3,
    key = {
      "机械",
      "战士",
      "光明",
      "黑暗",
      "复仇目标"
    },
    addweight = function(u, var)
      local add = 0
      if u:getdata("孔瑞丽-灵魂碎片") >= 5 then
        add = add + 2500
      end
      return add
    end,
    condition = function(u)
      return u:hasdata("变异判定-孔涛罗")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      ChangeValue(DamageSystem_Shjc, sy, 0.075)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      ChangeValue(DamageSplit_CountJzMax, sy, 0.4)
      local add = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Jzsh, sy, 0.1 * -add)
        add = u:getdata("战士变异数量") * 0.05
        ChangeValue(Correction_Jzsh, sy, 0.1 * add)
      end)
      PlayGlobalSound(Sound_Ktl_Lhj01)
      NPCChat({
        name = "|cFF3F3F49孔|r|cFF696C6F涛|r|cFF939896罗|r",
        chaticon = "Chat_Ktl2.tga",
        chattext = {
          {
            text = "|cFF696C6F我也一样……|r",
            time = 7.8
          }
        }
      })
      NPCChat({
        name = "|cFF616368刘|r|cFF777B7C豪|r|cFF8E9291军|r",
        chaticon = "Chat_Lhj.tga",
        chattext = {
          {
            text = "|cFF777B7C总算回来了，涛罗|r",
            time = 0
          },
          {
            text = "|cFF777B7C我等这一天已经很久了|r",
            time = 3.5
          }
        }
      })
    end,
    effectname = "|cFF616368刘|r|cFF777B7C豪|r|cFF8E9291军|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF616368机械 战士 光明 黑暗 复仇目标|r\n|cFFA4AAA5提升7.5%伤害加成|r\n|cFF616368【鬼眼丽人】|r\n|cFFA4AAA5近战伤害段数+1\n近战伤害上限+40%\n提升[战士变异*0.5%]近战伤害\n[孔涛罗]左键点击复仇\n[孔涛罗]复仇失败将被杀死|r",
    effectart = "Cq_Ktl_Lhj"
  },
  {
    name = "樟贾宝",
    weight = 200,
    lv = 2,
    key = {
      "机械",
      "战士",
      "黑暗",
      "复仇目标"
    },
    addweight = function(u, var)
      local add = 0
      if u:getdata("战士变异数量") >= 12 then
        add = add + 2000
      end
      return add
    end,
    condition = function(u)
      return u:hasdata("变异判定-孔涛罗") and not u:hasdata("孔涛罗-复仇终结")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      ChangeValue(DamageSystem_Shjc, sy, 0.04)
      u:changedata("力量增幅", 0.05)
      u:addstr(150)
    end,
    effectname = "|cFF616368樟|r|cFF777B7C贾|r|cFF8E9291宝|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF616368机械 战士 黑暗 复仇目标|r\n|cFFA4AAA5提升4%伤害加成|r\n|cFF616368【六臂金刚】|r\n|cFFA4AAA5提升5%力量\n提升150力量\n[孔涛罗]复仇成功条件:战士变异数量≥12|r",
    effectart = "Cq_Ktl_Zjb"
  },
  {
    name = "吴荣成",
    weight = 200,
    lv = 2,
    key = {
      "机械",
      "黑暗",
      "复仇目标"
    },
    addweight = function(u, var)
      local add = 0
      if u:getdata("机械变异数量") >= 12 then
        add = add + 2000
      end
      return add
    end,
    condition = function(u)
      return u:hasdata("变异判定-孔涛罗") and not u:hasdata("孔涛罗-复仇终结")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      ChangeValue(DamageSystem_Shjc, sy, 0.04)
      u:changedata("智力增幅", 0.05)
      u:addint(150)
    end,
    effectname = "|cFF616368吴|r|cFF777B7C荣|r|cFF8E9291成|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF616368机械 黑暗 复仇目标|r\n|cFFA4AAA5提升4%伤害加成|r\n|cFF616368【网络蛊毒】|r\n|cFFA4AAA5提升5%智力\n提升150智力\n[孔涛罗]复仇成功条件:机械变异数量≥12|r",
    effectart = "Cq_Ktl_Wrc"
  },
  {
    name = "朱笑嫣",
    weight = 200,
    lv = 2,
    key = {
      "机械",
      "影",
      "黑暗",
      "复仇目标"
    },
    addweight = function(u, var)
      local add = 0
      if u:getdata("影变异数量") >= 5 then
        add = add + 2000
      end
      return add
    end,
    condition = function(u)
      return u:hasdata("变异判定-孔涛罗") and not u:hasdata("孔涛罗-复仇终结")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      ChangeValue(DamageSystem_Shjc, sy, 0.04)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local info = args.damageinfo
        if not info.isvestdamage and not u:hasdata(var.name .. "-流血冷却") then
          u:settimedata(var.name .. "-流血冷却", 1)
          tg:buffset(u.handle, 1, "流血")
          Buff_LiuxueQiangdu(u, tg, 1)
        end
      end)
    end,
    effectname = "|cFF616368朱|r|cFF777B7C笑|r|cFF8E9291嫣|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF616368机械 影 黑暗 复仇目标|r\n|cFFA4AAA5提升4%伤害加成|r\n|cFF616368【罗刹太后】|r\n|cFFA4AAA5提升25%流血伤害\n直接伤害时施加1级[流血强度]与1层[流血层数],冷却1秒\n[孔涛罗]复仇成功条件:影变异数量≥5|r",
    effectart = "Cq_Ktl_Zxy"
  },
  {
    name = "斌伟信",
    weight = 200,
    lv = 2,
    key = {
      "机械",
      "黑暗",
      "复仇目标"
    },
    addweight = function(u, var)
      local add = 0
      if u:getdata("光明变异数量") + u:getdata("黑暗变异数量") >= 20 then
        add = add + 2000
      end
      return add
    end,
    condition = function(u)
      return u:hasdata("变异判定-孔涛罗") and not u:hasdata("孔涛罗-复仇终结")
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      ChangeValue(DamageSystem_Shjc, sy, 0.04)
      u:changedata("敏捷增幅", 0.05)
      u:addagi(150)
    end,
    effectname = "|cFF616368斌|r|cFF777B7C伟|r|cFF8E9291信|r",
    effecttext = "|cFF66CCFF[奇迹]|r\n|cFF616368机械 黑暗 复仇目标|r\n|cFFA4AAA5提升4%伤害加成|r\n|cFF616368【百综手】|r\n|cFFA4AAA5提升5%敏捷\n提升150敏捷\n[孔涛罗]复仇成功条件:(光明变异+黑暗变异)数量≥20|r",
    effectart = "Cq_Ktl_Bwx"
  }
}
local apocalypse_legend_names = {
  ["百夜米迦尔"] = true,
  ["百夜优一郎"] = true,
  ["柊筱娅"] = true,
  ["始祖吸血鬼"] = true
}
local apocalypse_legends = {}
for i = #Vars_Ciyuan_Lv2, 1, -1 do
  local var = Vars_Ciyuan_Lv2[i]
  if apocalypse_legend_names[var.name] then
    table.remove(Vars_Ciyuan_Lv2, i)
    table.insert(apocalypse_legends, 1, var)
  end
end
for _, var in ipairs(apocalypse_legends) do
  table.insert(Vars_Ciyuan_Lv3, var)
end
for lv, pool in pairs({
  [0] = Vars_Ciyuan_Lv0,
  [1] = Vars_Ciyuan_Lv1,
  [2] = Vars_Ciyuan_Lv2,
  [3] = Vars_Ciyuan_Lv3,
  [4] = Vars_Ciyuan_Lv4,
  [5] = Vars_Ciyuan_Lv5
}) do
  Vars_Ciyuan_ByLv[lv] = pool
end
for _, var in ipairs(Vars_Ciyuan_Kongtaoluo) do
  local pool = Vars_Ciyuan_ByLv[var.lv]
  if pool then
    table.insert(pool, var)
  end
end
Vars_Ciyuan_LvPools = {
  Vars_Ciyuan_Lv0,
  Vars_Ciyuan_Lv1,
  Vars_Ciyuan_Lv2,
  Vars_Ciyuan_Lv3,
  Vars_Ciyuan_Lv4,
  Vars_Ciyuan_Lv5
}
Vars_Ciyuan = {}

local function rebuild_vars_ciyuan()
  for i = #Vars_Ciyuan, 1, -1 do
    Vars_Ciyuan[i] = nil
  end
  for _, pool in ipairs(Vars_Ciyuan_LvPools) do
    for _, var in ipairs(pool) do
      table.insert(Vars_Ciyuan, var)
    end
  end
end

rebuild_vars_ciyuan()

function VarsCiyuanPools(...)
  local pools = {}
  for _, pool in ipairs(Vars_Ciyuan_LvPools) do
    if 0 < #pool then
      table.insert(pools, pool)
    end
  end
  for i = 1, select("#", ...) do
    local pool = select(i, ...)
    table.insert(pools, pool)
  end
  return pools
end
