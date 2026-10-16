-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
function jibingpanding_tong(u)
  if u:getdata("瞳变异数量") > u:getdata("瞳承载上限") and not u:hasdata("变异判定-复瞳症") then
    if u:getdata("御守-剩余次数") > 0 then
      u:changedata("御守-剩余次数", -1)
      
      u:sendmessage("|cFFFF0066御守-抵挡疾病|r")
      return
    end
    AdvanceGet["复瞳症"](u)
  end
end

local function has_advanced_bloodline(u)
  return u:hasdata("忍野忍血统进阶-始祖吸血鬼") or u:hasdata("忍野忍血统进阶-金发幼女")
end

local function advance_yingmou(u)
  if not u:isalive() or u:hasdata("变异判定-金色的梦幻之瞳") then
    return
  end
  local sy = u.ownerid
  if not has_advanced_bloodline(u) then
    u:sendmessage("|cFFFFCC33血统未进阶|r")
    return
  end
  if (TalentCode[sy] or 0) < 5 then
    u:sendmessage("|cFFFFCC33天赋点不足|r")
    return
  end
  if u:getdata("忍野忍-甜食值") < 20000 then
    u:sendmessage("|cFFFFCC33甜食值不足|r")
    return
  end
  if not u:hasdata("变异判定-忍野忍神化") then
    u:sendmessage("|cFFFFCC33未神话|r")
    return
  end
  u:changedata("系统-神力承载", 3)
  TalentCode[sy] = TalentCode[sy] - 5
  AdvanceGet["金色的梦幻之瞳"](u)
end

local function advance_six_eyes_challenger(u)
  if u:hasdata("变异判定-五条悟") then
    return
  end
  if not u:isalive() then
    u:sendmessage("|cFFCCCCCC死亡状态|r")
    return
  end
  if not BossBattle or BOSS == 0 or BOSS == BOSS_DEATH then
    u:sendmessage("|cFFCCCCCC只能在BOSS战中进行|r")
    return
  end
  local boss = getunit(BOSS)
  if not boss:isalive() or not boss:isboss() then
    u:sendmessage("|cFFCCCCCC当前不存在可挑战的BOSS|r")
    return
  end
  ForGroupLuaNew(Group_PlayHero, function(xq)
    xq:buffset(u.handle, 11, "绝对闪避")
  end)
  PlayGlobalSound(Sound_5t5xs_06)
  flashphoto({
    photo = "Ph_5t5_Tzz.tga",
    timeout = 5,
    timehold = 3,
    timein = 3
  })
  NPCChat({
    name = "|cFF6699FF五|r|cFF80A6F2条|r|cFF99B2E6悟|r",
    chaticon = "Chat_5t5.tga",
    chattext = {
      {
        text = "|cFF99B2E6别误会了所以声明一下|r",
        time = 0
      },
      {
        text = "|cFF99B2E6你才是挑战者|r",
        time = 4.8
      }
    }
  })
  local sy = u.ownerid
  u:setdata("六眼-你才是挑战者")
  boss:setdata("六眼-挑战者")
  u:setdata("变异判定-五条悟")
  u:reduceshw()
  u:setplayername("|cFF3366FF[现|r|cFF4770FF代|r|cFF5C7AFF最|r|cFF7085FF强]|r" .. NameID[sy])
  u:changedata("黑暗变异数量", 1)
  u:changedata("光明变异数量", 1)
  local shjc_bonus = 0
  local endsh_bonus = 0
  
  local function refresh_strongest_bonus()
    ChangeValue(DamageSystem_Shjc, u.ownerid, 0.1 * -shjc_bonus)
    ChangeValue(DamageSystem_EndSh, u.ownerid, 0.1 * -endsh_bonus)
    shjc_bonus = 0.25 * (u:getstate("光明变异") + u:getstate("黑暗变异"))
    endsh_bonus = 0.08 * u:getstate("根源变异")
    ChangeValue(DamageSystem_Shjc, u.ownerid, 0.1 * shjc_bonus)
    ChangeValue(DamageSystem_EndSh, u.ownerid, 0.1 * endsh_bonus)
  end
  
  refresh_strongest_bonus()
  ac.loop(3000, refresh_strongest_bonus)
  u:addstexiao("五条悟-挑战者伤害", "伤害系统计算效果", function(args)
    local info = args.damageinfo
    local tg = args.tg
    if tg:hasdata("六眼-挑战者") then
      info.damage = info.damage * 2
    end
  end)
  u:addstexiao("五条悟-挑战者受伤", "受伤后效果", function(args)
    local u = args.u
    local tg = args.tg
    if tg:hasdata("六眼-挑战者") then
      args.damage = args.damage * 2
    end
  end)
  u:addstexiao("五条悟-会赢的", "杀敌效果", function(args)
    if args.tg:isboss() then
      ChangeValue(DamageSystem_Shjc, u.ownerid, 0.25)
    end
  end)
  local xushi_skill = S2ID("A5T5")
  u:byladdskill(xushi_skill, function(args)
    if args.skill ~= xushi_skill then
      return
    end
    local skill_unit = getunit(args.unit)
    if not u:isalive() then
      u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
      skill_unit:setskillcd(xushi_skill, 1)
      return
    end
    if MovieAct["虚式茈"] then
      local x, y = u:getxy()
      local x2 = args.x
      local y2 = args.y
      local angle = AngleXY(x, y, x2, y2)
      u:setface(angle)
      MovieAct["虚式茈"](u)
    else
      skill_unit:setskillcd(xushi_skill, 1)
    end
  end)
  local max_hp = boss:getmaxhp()
  boss:setmaxhp(max_hp * 10)
  boss:sethp(100, true)
  boss:elitesextrachange(true)
  u:uivar_change({
    keyname = "六眼",
    keytype = "传奇栏",
    text = "|cFF999999五条悟|r\n|cFF999999黑暗 光明 根源 唯一|r\n|cFF999999现代最强|r\n|cFFCCCCCC提升[2.5%*(光明变异+黑暗变异)]伤害加成\n提升[0.8%*根源变异]终结伤害|r\n|cFF999999无量|r\n|cFFCCCCCC不会受到0.9秒内进入自身周围350范围单位的伤害,对BOSS冷却3秒\n自身伤害闪避不会失效\n允许使用[瞬移]|r\n|cFF999999空处|r\n|cFFCCCCCC无视伤害闪避与根性\n无视拥有神性抗性单位的伤害抗性|r\n|cFF999999顺转术式|r\n|cFFCCCCCC解锁[顺转术式],在10秒内除自身外周围500范围内的弹幕与敌人将会暂停直至持续时间结束,冷却90秒\n解锁技能栏技能[虚式「茈」]|r\n|cFF999999你才是挑战者|r\n|cFFCCCCCC对[挑战者]伤害提升100%\n受到[挑战者]伤害提升100%\n被[挑战者]杀死时删模|r\n|cFF999999苏醒后的胜利宣言「会赢的」|r\n|cFFCCCCCC击杀BOSS时提升25%伤害加成\n被BOSS杀死时降低10%伤害加成|r",
    icon = "Cq_5t5_Jinjie.tga"
  })
end

Vars_Lns = {
  {
    name = "见习剑巫",
    clickfunc = function(u)
      local sy = u.ownerid
      if u:isalive() and u:ishasshw() and u:getdata("雪霞狼杀敌") >= 125 then
        AdvanceGet["姬柊雪菜"](u)
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
      local sy = u.ownerid
      if u:ishasitem(Weapons["雪霞狼"]) or Hero_Equip_WeaponType[sy] == Weapons["雪霞狼"] then
        add = add + 3000
      end
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("判定-雪菜") and (u:ishasitem(Weapons["雪霞狼"]) or Hero_Equip_WeaponType[sy] == Weapons["雪霞狼"]) then
        b = true
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
      u:changedata("瞳变异数量", 1)
      jibingpanding_tong(u)
      u:sendmessage("|cFF3D47FF我是狮子王机关的见习女巫，姬柊雪菜，请多指教。|r")
      u:changedata("传奇数量", 1)
      u:addskill("S04F")
      u:changeoriginmaxhp(10.0)
      u:addallstats(5)
      ChangeValue(Correction_Exp, sy, 0.15)
      u:changedata("闪避值", 15)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
      ChangeValue(DamageSystem_Shjc, sy, 0.01)
      ChangeValue(DamageSystem_Shjc, sy, 0.005)
      ChangeValue(DamageSystem_EndSh, sy, 0.005000000000000001)
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not tg:hasdata("雪菜-击杀判定") then
          tg:setdata("雪菜-击杀判定")
          ac.wait(30, function()
            tg:deldata("雪菜-击杀判定")
            if not tg:isalive() then
              ChangeValue(Correction_Jzsh, sy, 1.0E-4)
            end
          end)
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        local t = 2
        if u:hasdata("变异判定-姬柊雪菜") then
          t = 1
        end
        if u:getluckrandom(33 * info.txgl) and not u:hasdata(var.name .. "-火雷特效冷却") then
          local txsh = 8888 + 200 * tg:getlevel()
          u:settimedata(var.name .. "-火雷特效冷却", t)
          local dx, dy = tg:getxy()
          Effectcreate("Tx_Jzxc_Huolei.mdx", dx, dy, 1, 2)
          DamageUnit({
            bj = "雪菜火雷",
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
        if u:getluckrandom(33 * info.txgl) and not u:hasdata(var.name .. "-拆雷特效冷却") then
          local txsh = 0.5 * info.yssh
          u:settimedata(var.name .. "-拆雷特效冷却", t)
          local dx, dy = tg:getxy()
          Effectcreate("Tx_Jzxc2_Chailei.mdl", dx, dy, 1)
          DamageUnit({
            bj = "雪菜拆雷",
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
      u:addtrgevent("单位-被攻击", function(args)
        local soc = args.soc
        local u = args.u
        local jl = 6
        if not u:hasdata("鸣雷冷却") and u:getluckrandom(jl) then
          local t = 6
          if u:hasdata("变异判定-姬柊雪菜") then
            t = 3
          end
          u:settimedata("鸣雷冷却", t)
          soc:buffset(u.handle, 1, "眩晕")
          soc:effectadd("war3mapimported\\98.mdl")
          u:playsound(Jianwu_3)
          local txsh = 8888 + 200 * u:getlevel()
          DamageUnit({
            bj = "雪菜鸣雷",
            unit = soc.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = false,
            isattack = false,
            isnoarmor = false,
            element = "雷",
            extradata = {""}
          })
        end
      end)
    end,
    effectname = "|cFF3366FF狮子王机关所属见习“剑巫”|r",
    effecttext = "|cFF3366FF光明 魔导\n见习剑巫|r\n|cFF6699FF[数据删除]|r\n|cFF3366FF八雷神法|r\n|cFF6699FF[数据删除]|r\n|cFF3366FF未来视|r\n|cFF6699FF[数据删除]|r",
    effectart = "war3mapImported\\BTNEwl_Jtxc_01"
  },
  {
    name = "星虹之眸",
    weight = 5,
    key = {
      "唯一",
      "战士",
      "星"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      if u:hasdata("判定-星神之嗣") then
        b = true
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
      u:sendmessage("|cFF0000FF你|r|cFF1200F0的|r|cFF2400E2眼|r|cFF3700D3睛|r|cFF4900C5变|r|cFF5B00B6得|r|cFF6D00A8如|r|cFF800099同|r|cFF92008A水|r|cFFA4007C晶|r|cFFB6006D般|r|cFFC8005F透|r|cFFDB0050彻|r")
      u:adddivinity(1)
      u:changedata("幸运", 2)
      u:getgoddessforce(1)
      ChangeValue(HeroMenu_HpChange_MaxHp, sy, 0.6)
      ac.loop(6000, function()
        u:changemaxhp(1)
      end)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 24)
      u:addskill("S04B")
      ChangeValue(DamageSystem_Shjc, sy, 0.006)
      ChangeValue(DamageSystem_Shjc, sy, 0.006)
      ChangeValue(DamageSystem_Shjc, sy, 0.006)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.94, 1)
      ChangeValue(DamageSystem_Baoji, sy, 12)
      ChangeValue(DamageSystem_Baoshang, sy, 0.12)
      ChangeValue(KillReward_MHp, sy, 1)
      for index, value in ipairs(Pools_Spe) do
        if value.name == "星之泪" then
          if not value.hasbeenget then
            u:additem("I0CB")
            value.hasbeenget = true
          end
          break
        end
      end
    end,
    effectname = "|cFFFF0066星虹之眸|r",
    effecttext = "|cFFCC0033神性1 女神力1\n唯一 战士 星\n【彤の璎】|r\n|cFFFF0066【星河涌动】|r\n|cFF0000FF【岚の溟】|r\n|cFFFF0066【银河阔长】|r",
    effectart = "war3mapImported\\PASBTNXszs_05"
  },
  {
    name = "解弦之眼",
    clickfunc = function(u)
      local sy = u.ownerid
      if u:isalive() then
        local b = true
        if not u:ishasshw() then
          b = false
          u:sendmessage("|cFFEC2935神化位不足")
        end
        if not u:hasdata("邪王真眼-进阶满足") and u:getdata("解弦之眼杀敌数量") < 250 then
          b = false
          u:sendmessage("|cFFEC2935杀敌数量不满足")
        end
        if b and Weiyi_New[23] == false then
          u:deldata("邪王真眼-进阶满足")
          AdvanceGet["千咲神化"](u)
        end
      end
    end,
    weight = 100,
    key = {"根源"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:getdata("瞳变异数量") >= u:getdata("瞳承载上限") and not u:ishasitem("I0IY") then
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
      u:changedata("瞳变异数量", 1)
      jibingpanding_tong(u)
      ChangeValue(DamageSystem_Baoshang, sy, 0.18)
      local max = 0
      if u:hasdata("英雄-千咲") then
        max = 18
      end
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        if tg:getarmor() < max then
          u:changedata("解弦之眼杀敌数量", 1)
        end
      end)
    end,
    effectname = "|cFFFA818E解弦之眼|r",
    effecttext = "|cFFFA818E根源\n无视目标18护甲\n提升18%暴击伤害\n满足条件后【点击】图标消耗神化位进阶为神化【唯一】\n进阶条件：【累积击杀负护甲单位250个】|r\n|cFF949596“瞳中隐约散溢出斑斓的光。于是万事万物的结构于视野里渐次明晰，\n她微微眯起眼睛，从中辨认出牵引着性命的那一根弦。”|r",
    effectart = "Tong_Jiexianzhiyan.tga"
  },
  {
    name = "虚空瞳",
    weight = 100,
    key = {"唯一", "根源"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:getdata("瞳变异数量") >= u:getdata("瞳承载上限") and not u:ishasitem("I0IY") then
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
      u:changedata("瞳变异数量", 1)
      jibingpanding_tong(u)
      u:sendmessage("|cFF9999FF万|r|cFFA38FFF古|r|cFFAD85FF一|r|cFFB87AFF空|r")
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        if not tg:hasdata(var.name .. "-特效冷却") and GetUnitMoveSpeed(tg.handle) >= 500 then
          local cd
          if tg:isnormal() then
            cd = 5
          else
            cd = 15
          end
          if u:hasdata("物品-粉色墨镜") then
            cd = 1
          end
          tg:settimedata(var.name .. "-特效冷却", cd)
          tg:buffset(u.handle, 1, "僵直")
          if tg:hasdata("精英特性-迅捷") then
            tg:delskill("S00G")
            tg:deldata("精英特性-迅捷")
          end
        end
      end)
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if GetUnitMoveSpeed(u.handle) >= GetUnitMoveSpeed(tg.handle) then
          info.wssb = true
          info.wsmy = true
        end
      end)
      u:adddxdstats("幻想", 1)
      u:addskill("A1EA")
    end,
    effectname = "|cFF9999FF虚|r|cFFA68CFF空|r|cFFB280FF瞳|r",
    effecttext = "|cFFA68CFF根源/幻想+1\n无视移动速度低于自身单位的伤害免疫与伤害闪避\n直接伤害时移除目标迅捷特性|r\n|cFFB280FF直接伤害时如果目标移动速度超过500,则僵直其1秒,独立冷却5(15)秒|r",
    effectart = "war3mapImported\\BTNEwailan_Xukongtong.blp"
  },
  {
    name = "六眼",
    weight = 25,
    key = {"唯一", "根源"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:getdata("瞳变异数量") >= u:getdata("瞳承载上限") and not u:ishasitem("I0IY") then
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
      u:changedata("瞳变异数量", 1)
      jibingpanding_tong(u)
      u:chat("不用担心，我是最强的。")
      PlayGlobalSound(Sound_5t5_Get)
      local group = CreateGroupLua()
      ac.loop(150, function()
        if u:isalive() then
          local x, y = u:getxy()
          for _, xq in ac.selector():in_rangexy(x, y, 350):is_not(u.handle):ipairs() do
            xq = getunit(xq)
            xq:groupadd(group)
            if xq:getdata("六眼-无量计数") < 6 then
              xq:changedata("六眼-无量计数", 1)
            end
          end
          ForGroupLuaNew(group, function(xq)
            if not xq:isalive() or DistanceBetweenUnits(xq.handle, u.handle) > 350 then
              xq:groupremove(group)
              xq:deldata("六眼-无量计数")
            end
          end)
        end
      end)
      local g = CreateGroupLua()
      local g2 = CreateGroupLua()
      AddUISkill({
        text = var.name,
        u = u,
        cd = 90,
        icon = "war3mapImported\\BTNEwl_5t5_02.blp",
        func = function(args)
          local u = args.u
          if u:isalive() then
            u:playsound(Sound_5t5_Skill)
            u:settimedata("六眼-顺转术式", 10)
            local x, y = u:getxy()
            Effectcreate("AATX\\[AATxNew]Blue13.mdl", x, y, 0, 1.5)
            local tx = Effectcreate("AATX\\[AATxNew]Blue10.mdl", x, y, -1, 2.3)
            ac.loop(30, function(timer)
              local x, y = u:getxy()
              SetEffectXY(tx, x, y)
              if not u:hasdata("六眼-顺转术式") then
                DestroyEffectLua(tx)
                timer:remove()
              end
            end)
            ac.loop(50, function(timer)
              local x, y = u:getxy()
              ForGroupLuaNew(g, function(xq)
                xq:animespeed(0)
                xq:buffset(u.handle, 0.5, "暂停")
              end)
              ForGroupLuaNew(g2, function(xq)
                xq:setdata("弹幕-是否暂停", true)
              end)
              for _, xq in ac.selector():in_rangexy(x, y, 500):allow_unify():ipairs() do
                xq = getunit(xq)
                if not xq:hasdata("系统-弹幕") then
                  if xq:is_enemy(u.handle) and not xq:isingroup(g) then
                    xq:groupadd(g)
                    xq:animespeed(0)
                    xq:buffset(u.handle, 0.5, "暂停")
                  end
                elseif xq.owner ~= u.owner and not xq:isingroup(g2) then
                  xq:groupadd(g2)
                  xq:setdata("弹幕-是否暂停", true)
                end
              end
              if not u:hasdata("六眼-顺转术式") then
                ForGroupLuaNew(g, function(xq)
                  xq:animespeed(1)
                end)
                ForGroupLuaNew(g2, function(xq)
                  xq:setdata("弹幕-是否暂停", false)
                end)
                GroupClearLua(g)
                GroupClearLua(g2)
                timer:remove()
              end
            end)
          end
        end
      })
      local dskill
      if u:ishasskill("A1AM") and u.type ~= HeroType["C呆"] and u.type ~= HeroType["莲华"] then
        dskill = "A1S8"
      else
        dskill = "A19U"
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
              local b = true
              
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              if u:hasbuff("暂停") then
                b = false
                u:sendmessage("|cFF7DBEF1处于暂停无法释放|r")
              end
              if not IsVisibleToPlayer(x2, y2, u.owner) then
                b = false
                u:sendmessage("|cFF7DBEF1目标点不可见|r")
              end
              if b then
                Effectcreate("AATX\\[AATxNew]Blue01.mdl", x, y, 0, 2)
                Effectcreate("AATX\\[AATxNew]Blue01.mdl", x2, y2, 0, 2)
                Effectcreate("ATX\\[ATxNew]Black_01.mdl", x, y)
                Effectcreate("ATX\\[ATxNew]Black_01.mdl", x2, y2)
                u:setxy(x2, y2)
              else
                u:setskillcd(dskill, 0.1)
              end
            end
          end
          
          u:addtrgevent("单位-发动技能", function(args)
            skill(args)
          end)
        end
      })
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("变异判定-五条悟") or u:getluckrandom(25) then
          info.wssb = true
        end
      end)
      u:addtrgevent("玩家-聊天", function(args)
        if args.chat == "你才是挑战者" then
          advance_six_eyes_challenger(u)
        end
      end)
      ac.wait(100, function()
        u:uivar_change({
          keyname = "六眼",
          keytype = "传奇栏",
          text = "|cFF999999六眼|r\n|cFF999999根源\n无量|r\n|cFFCCCCCC不会受到0.9秒内进入自身周围350范围单位的伤害,对BOSS冷却3秒\n自身伤害闪避不会失效\n允许使用[瞬移]|r\n|cFF999999空处|r\n|cFFCCCCCC25%无视伤害闪避\n无视根性\n无视拥有神性抗性单位的伤害抗性|r\n|cFF999999顺转术式|r\n|cFFCCCCCC解锁[顺转术式],在10秒内除自身外周围500范围内的弹幕与敌人将会暂停直至持续时间结束,冷却90秒|r\n|cFF999999你才是挑战者|r\n|cFFCCCCCCBOSS战时输入“你才是挑战者”进阶,强制消耗1个神化位(无需拥有神化位)\n使BOSS血量提升10倍并获得魔王特性\n进阶后被[挑战者]杀死时删模|r"
        })
      end)
    end,
    effectname = "|cFF999999六眼|r",
    effecttext = "|cFF999999根源\n无量|r\n|cFFCCCCCC不会受到0.9秒内进入自身周围350范围单位的伤害,对BOSS冷却3秒\n自身伤害闪避不会失效\n允许使用[瞬移]|r\n|cFF999999空处|r\n|cFFCCCCCC25%无视伤害闪避\n无视根性\n无视拥有神性抗性单位的伤害抗性|r\n|cFF999999顺转术式|r\n|cFFCCCCCC解锁[顺转术式],在10秒内除自身外周围500范围内的弹幕与敌人将会暂停直至持续时间结束,冷却90秒|r",
    effectart = "war3mapImported\\BTNEwl_5t5_02.blp"
  },
  {
    name = "萤眸",
    clickfunc = function(u)
      advance_yingmou(u)
    end,
    weight = 10000,
    key = {
      "唯一",
      "吸血鬼",
      "光明"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("变异判定-忍野忍") then
        b = true
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
      u:changedata("幸运", 2)
      ChangeValue(DamageSystem_Baoji, sy, 10)
      ChangeValue(DamageSystem_Baoshang, sy, 0.1)
      ac.wait(10, function()
        u:uivar_change({
          keyname = "萤眸",
          keytype = "传奇栏",
          icon = "Ryr_Tong.tga",
          ishasphoto = true,
          clickfunc = function(unit)
            advance_yingmou(unit)
          end,
          size = 2
        })
      end)
      PlayGlobalSound(Sound_Ryr_ThingGet)
      SendMsgAll("|cFFFF0000忍|r|cFFFF801A野|r|cFFFFAA22忍|r|cFFFF2A08：『撒，|r|cFFFF5511让我们去打到太阳吧！』|r")
    end,
    effectname = "|cFFFFFF00萤|r|cFFFFAA00眸|r",
    effecttext = "|cFFCC99FF那|r|cFFCE9EF3如|r|cFFD1A2E8同|r|cFFD3A7DC碎|r|cFFD5ACD1星|r|cFFD8B0C5流|r|cFFDAB5B9动|r|cFFDCB9AE的|r|cFFDFBEA2眼|r|cFFE1C397眸|r|cFFE3C78B，|r|cFFE5CC7F眼|r|cFFE8D174波|r|cFFEAD568流|r|cFFECDA5D转|r|cFFEFDF51，|r|cFFF1E346泛|r|cFFF3E83A起|r|cFFF6EC2E涟|r|cFFF8F123漪|r|cFFFAF617。|r",
    effectart = "Ryr_Tong.tga"
  },
  {
    name = "水月",
    weight = 100,
    key = {
      "唯一",
      "冰",
      "白毛"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      if Ewaishu[sy] > 5 then
        b = false
      end
      if GetRandom100(80) then
        b = false
      end
      if u:getdata("瞳变异数量") > 0 then
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
      u:sendmessage("|cFF99FFFF始终对现实无法忘怀的话，可是会被天狼追上捉到的哦。|r")
    end,
    effectname = "|cFFCCFFFF水|r|cFFAACCCC月|r",
    effecttext = "|cFFCCFFFF冰\n自身复活时如果有死亡队友则会随机复活一名队友|r\n|cFFAACCCC触发冷却300秒|r",
    effectart = "war3mapImported\\PASBTNEwl_Teshu_Shuiyue.blp"
  },
  {
    name = "邪王真眼",
    weight = 100,
    key = {"唯一"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("变异判定-花园百合铃") then
        add = add + 200
      end
      return add
    end,
    condition = function(u)
      local b = true
      if u:getdata("瞳变异数量") > 0 then
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
      u:adddxdstats("幻想", 1)
      DXDTEXT = "|cFFFFFF66真|r|cFFFFFF85名|r|cFFFFFFA3邪|r|cFFFFFFC2王|r"
      local add = "无"
      if 1 <= Ewaishu[sy] then
        add = "劣势"
      end
      if u:judgedxdstats("幻想", 30, add) then
        u:changedata("瞳承载上限", 99)
        u:deldata("变异判定-邪王真眼")
        u:setdata("邪王真眼-真名解放")
        u:adddxdstats("幻想", 2)
        u:changedata("根源变异数量", 1)
        u:become("王")
        ChangeValue(Damage_ElementRes_All, sy, 40)
        u:addstexiao(var.name, "直接伤害特效", function(args)
          local jl = 1
          local u = args.u
          local tg = args.tg
          if u:hasdata("隐藏职业-天谴之子") then
            jl = jl * 2
          end
          if u:hasdata("瓦拉齐亚之夜-夜晚强化") then
            jl = jl * 2
          end
          tg:eliteschange(-100)
          if tg:isnormal() and u:getluckrandom(jl) then
            tg:effectadd("war3mapImported\\texiao_xukongtongyizhi.mdl")
            tg:kill(u.handle, true)
          end
        end)
        NameID[sy] = "|cFF9999FF小|r|cFFAAAAFF鸟|r|cFFBBBBFF游|r|cFFCCCCFF六|r|cFFDDDDFF花|r"
        u:setplayername(NameID[sy])
        ac.loop(1000, function()
          if u:isalive() then
            u:clearbuff()
          end
        end)
        var.effectname = "|cFFFFFF66真|r|cFFFFFF85名|r|cFFFFFFA3邪|r|cFFFFFFC2王|r"
        var.effecttext = "|cFFFFFF00神性 3|r\n|cFFFFFF00不可视境界线|r\n|cFFFFCC00每秒清除自身魔法效果影响/幻想+3|r\n|cFFFFFF00永恒之枪|r\n|cFFFFCC00直接伤害时破除所有精英特性\n直接伤害1%抹除普通单位|r\n|cFFFFFF00漆黑之盾|r\n|cFFFFCC00提升40%全属抗|r\n|cFFFFFF00真名解放|r\n|cFFFFCC00瞳变异无数量限制\n以下效果只能生效一种且只生效一次：\n①输入“血界突破”使血统浓度上限提升100%,无视血统阶级惩罚\n②输入“真名解放”获得一个神化位\n③输入“圣人之躯”获得[圣人之躯]|r"
        var.effectart = "war3mapImported\\btnewl_tong_xiewangzhenyan_zhen.blp"
        u:effectadd("war3mapImported\\texiao_xukongtongkaiqi.mdl", "origin", -1)
        
        local function chattrg(args)
          local text = args.chat
          if not u:hasdata("真名邪王-已赐福") then
            local b = false
            if text == "血界突破" then
              b = true
              u:setdata("血统浓度上限", 100)
              u:setdata("邪王真眼-血界突破")
              u:effectadd("war3mapImported\\texiao_xuebao.mdx")
            end
            if text == "真名解放" then
              b = true
              ChangeValue(Hero_Shenhua_Left, sy, 1)
              u:effectadd("war3mapImported\\132.mdx")
            end
            if text == "圣人之躯" then
              b = true
              u:setdata("邪王真眼-圣人之躯")
              u:changedata("心脏承载上限", 1)
              u:changedata("以太三阶上限", 3)
              u:uivar_add({
                keyname = "圣人之躯",
                keytype = "传奇栏",
                text = "|cFFFFCC00圣人之躯\n心脏承载上限+1\n三阶通用以太槽+3\n免疫身体带来的抗药性惩罚\n[崩坏躯壳]负面效果减半|r",
                icon = "Ewl_Zhenmingxiewang_Srzq_2"
              })
              u:effectadd("Abilities\\Spells\\Human\\ReviveHuman\\ReviveHuman.mdl")
            end
            if b then
              u:setdata("真名邪王-已赐福")
              u:sendmessage("|cFFFFFF00已选择真名解放效果|r")
            end
          end
        end
        
        local p = getplayer(u.owner)
        p:addtrgevent("玩家-聊天", function(args)
          chattrg(args)
        end)
        u:adddivinity(3)
        u:getgoddessforce(3, true)
        u:settimedata("邪王永恒", 10)
        PlayBGM({
          bgm = BGM_Liuhua_01,
          time = 105,
          ID = 102,
          unit = u.handle
        })
        u:chat("呐——")
        ac.wait(2500, function()
          u:chat("我说你——")
        end)
        ac.wait(5000, function()
          u:chat("看到了对吧——")
        end)
        ac.wait(7500, function()
          u:chat("那么——")
        end)
        ac.wait(10000, function()
          u:chat("消失吧——")
        end)
        local zs = 100
        local x, y = u:getxy()
        local g = CreateGroupLua()
        TheWorld = true
        ac.loop(100, function(t)
          zs = zs - 1
          for _, xq in ac.selector():in_rangexy(x, y, 100000):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            if not xq:isingroup(g) then
              xq:groupadd(g)
              xq:addskill("A03O")
              xq:setanimerate(0)
              xq:buffset(u.handle, 0.1 + 0.1 * zs, "暂停")
            end
          end
          if zs == 0 then
            ForGroupLuaNew(g, function(xq)
              xq:setanimerate(1)
              xq:delskill("A03O")
            end)
            TheWorld = false
            PlaySoundBJ(BGM)
            t:remove()
          end
        end)
      else
        u:changedata("瞳承载上限", 1)
        u:setdata("邪王真眼-进阶满足")
        u:getgoddessforce(1)
        PlayGlobalSound(Sound_Liuhua_01)
        u:chat("爆裂吧 现实！")
        ac.wait(1200, function()
          u:chat("粉碎吧 精神！")
        end)
        ac.wait(2800, function()
          u:chat("Banishiment this world!")
        end)
      end
    end,
    effectname = "|cFF6633FF邪王真眼|r",
    effecttext = "|cFF6633FF现实规制|r\n|cFF9999FF[邪王真眼]本身不视为瞳变异|r\n|cFF6633FF理想放逐|r\n|cFF9999FF幻想+1\n瞳承载上限+1\n瞳变异进化时默认满足条件(限1次)|r",
    effectart = "war3mapImported\\btnewl_tong_xiewangzhenyan.blp"
  },
  {
    name = "鹰眼",
    clickfunc = function(u)
      local sy = u.ownerid
      if u:isalive() then
        if u:getdata("鹰眼暴击杀敌") >= 125 and u:ishasshw() and not Weiyi[14] then
          AdvanceGet["米霍克"](u)
        elseif u:hasdata("邪王真眼-进阶满足") and u:ishasshw() and not Weiyi[14] then
          u:deldata("邪王真眼-进阶满足")
          AdvanceGet["米霍克"](u)
        end
      end
    end,
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:getdata("瞳变异数量") >= u:getdata("瞳承载上限") and not u:ishasitem("I0IY") then
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
      u:changedata("瞳变异数量", 1)
      jibingpanding_tong(u)
      u:sendmessage("|cFF1BE6B8你的眼睛变得锐利无比|r")
      u:setdata("变异判定-鹰眼破抗")
      ChangeValue(Correction_Angle, sy, -0.4)
      ChangeValue(Correction_Gun, sy, 0.012)
      ChangeValue(Correction_Range, sy, 0.12)
      ChangeValue(DamageSystem_Baoji, sy, 12)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local u = args.u
        if not u:hasdata("鹰眼暴击判定") then
          u:setdata("鹰眼暴击判定")
        end
      end)
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        info.pk_mohu = true
      end)
      u:addstexiao(var.name, "伤害判定后效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("鹰眼暴击判定") and not u:hasdata("鹰眼暴击判定间隔") then
          u:deldata("鹰眼暴击判定")
          if not info.iscrit then
            ChangeTimeValue(DamageSystem_Baoji, sy, 1, 5)
          end
          u:settimedata("鹰眼暴击判定间隔", 0.1)
        end
        if info.iscrit then
          ac.wait(1, function()
            if not tg:isalive() then
              u:changedata("鹰眼暴击杀敌", 1)
            end
          end)
        end
      end)
    end,
    effectname = "|cFF1BE6B8鹰眼|r",
    effecttext = "|cFF1BE6B8①角度修正-40%\n②射击射程+12%\n③枪械修正+12%\n④提升12%暴击率\n⑤直接伤害没有暴击时在5秒内提升1%暴击率 分立计时 可叠加\n⑥无视精英特性制远与模糊|r\n\n|cFFFFFF00神化条件：通过暴击伤害杀死125个单位后点击神化|r\n|cFF949596我站在世界的顶点等你。|r",
    effectart = "war3mapImported\\BTNEwl_Yingyan.blp"
  },
  {
    name = "写轮眼",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:getdata("瞳变异数量") >= u:getdata("瞳承载上限") and not u:ishasitem("I0IY") then
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
      u:changedata("瞳变异数量", 1)
      jibingpanding_tong(u)
      u:sendmessage("|cFF1BE6B8获得写轮眼|r")
      u:changedata("闪避值", 15)
      u:setdata("复写对象", S2ID("hpea"))
      u:setdata("复写时间", 0)
      ChangeValue(DamageSystem_Baoji, sy, 9)
      ac.loop(100, function(t)
        if u:getdata("复写时间") > 0 then
          u:changedata("复写时间", -0.1)
        end
        if u:getdata("复写对象") ~= S2ID("hpea") and u:getdata("复写时间") <= 0 then
          u:setdata("复写时间", 0)
          u:setdata("复写对象", S2ID("hpea"))
          u:sendmessage("复写效果结束")
        end
        if not u:hasdata("变异判定-写轮眼") then
          t:remove()
        end
      end)
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        info.pk_mohu = true
        info.pk_jiaocuo = true
      end)
    end,
    effectname = "|cFFCC3333写轮眼|r",
    effecttext = "|cFFCC3333观察|r\n|cFFCC6666无视交错与模糊\n提升9%暴击率\n提升15闪避值\n反弹普通弹幕(触发冷却3秒)|r\n|cFFCC3333复写|r\n|cFFCC6666受到来自某种单位类型伤害时,在10秒内不会再次受到该单位类型伤害\n期间每受到来自该类型单位伤害时降低0.5秒该效果持续时间(强敌降低5秒 BOSS清零)\n处于复写状态时不会再次触发复写效果|r\n\n|cFFFFFF00神化条件：队友在视野内死亡时2%觉醒,视野外0.5%|r",
    effectart = "war3mapImported\\BTNEwl_Xielunyan.blp"
  },
  {
    name = "退魔眼",
    clickfunc = function(u)
      local sy = u.ownerid
      if u:isalive() and u:ishasshw() and not u:hasdata("变异判定-水月") then
        if u:hasdata("退魔眼-反转冲动") then
          if Weiyi[25] == false and (u:hasdata("邪王真眼-进阶满足") or u:getdata("退魔冲动杀敌") >= 150) then
            u:deldata("邪王真眼-进阶满足")
            AdvanceGet["七夜志贵"](u)
          end
        elseif Weiyi[4] == false and (u:hasdata("邪王真眼-进阶满足") or u:getdata("退魔杀敌") >= 200) then
          u:deldata("邪王真眼-进阶满足")
          AdvanceGet["远野志贵"](u)
        end
      end
    end,
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      if u:hasdata("神器判定-七夜小刀") then
        add = add + 10000
      end
      return add
    end,
    condition = function(u)
      local b = true
      if u:getdata("瞳变异数量") >= u:getdata("瞳承载上限") and not u:ishasitem("I0IY") then
        b = false
      end
      if u:hasdata("神器判定-七夜小刀") then
        b = true
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
      if not u:hasdata("神器判定-七夜小刀") then
        u:changedata("瞳变异数量", 1)
        jibingpanding_tong(u)
      end
      u:sendmessage("|cFF1BE6B8获得退魔眼|r")
      u:become("退魔家族")
      u:setdata("奈落杀可能")
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:isnormal() then
          info.end3 = info.end3 + 0.1
          if not tg:isingroup(HellGroup) and u:hasdata("免疫击退效果") then
            u:deldata("免疫击退效果")
            u:changedata("固定格挡", -1 * u:getdata("固定格挡增加值"))
          end
        end
      end)
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if tg:isnormal() then
          info.pk_shouhu = true
          info.pk_jiaocuo = true
        end
        if u:hasdata("退魔眼-反转冲动") then
          info.pk_mohu = true
          info.pk_tiebi = true
          info.pk_genxing = true
        end
      end)
      ac.loop(10000, function(t)
        if u:hasdata("变异判定-退魔眼") then
          if u:isalive() then
            local gl = 10
            if u:hasdata("神器判定-七夜小刀") then
              gl = gl * 2
            end
            if GetRandom100(10) or u:getdata("魔君兴奋剂持续时间") > 0 then
              u:settimedata("退魔眼-反转冲动", 10)
              u:sendmessage("|cFFFF0000你陷入了反转冲动|r")
              u:addskill("S02Z")
              ac.wait(9900, function()
                u:sendmessage("|cFFFF0000你平静了下来|r")
                u:delskill("S02Z")
              end)
            end
          end
        else
          t:remove()
        end
      end)
    end,
    effectname = "|cFF1BE6B8退魔眼|r",
    effecttext = "|cFF1BE6B8对普通敌人提升10%伤害\n无视普通单位精英特性守护与交错\n无视坚硬\n有概率使自身陷入反转冲动|r\n|cFFFFFF00神化条件：连续杀死200个敌人且未死亡时点击神化|r",
    effectart = "war3mapImported\\BTNEwl_Tuimoyan.blp"
  },
  {
    name = "魔眼",
    weight = 100,
    key = {"唯一"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I02D") then
        add = add + 500
      end
      return add
    end,
    condition = function(u)
      local b = true
      if not u:isgirl() then
        b = false
      end
      if u:getdata("瞳变异数量") >= u:getdata("瞳承载上限") and not u:ishasitem("I0IY") then
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
      u:changedata("瞳变异数量", 1)
      jibingpanding_tong(u)
      u:sendmessage("|cFF1BE6B8我被憧憬着么……？(回答不或是)|r")
      u:setdata("变异判定-魔眼")
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:hasbuff("石化") then
          info.end2 = info.end2 + 0.125
          if u:hasdata("物品-粉色墨镜") then
            info.end2 = info.end2 + 0.125
          end
        end
      end)
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if tg:hasbuff("石化") then
          info.wssb = true
          info.wsmy = true
        end
      end)
      u:setdata("魔眼", false)
      
      local function chattrg(args)
        if args.chat == "是" or args.chat == "Yes" then
          u:setdata("魔眼", true)
          if u:hasdata("邪王真眼-进阶满足") then
            for _, value in ipairs(Pools_Spe) do
              if value.name == "无名长裙" then
                if not value.hasbeenget then
                  u:additem("I02D")
                  u:deldata("邪王真眼-进阶满足")
                  value.hasbeenget = true
                end
                break
              end
            end
          end
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chattrg(args)
      end)
      u:getgoddessforce(1)
      ac.loop(50, function()
        if u:isalive() and (u:hasdata("物品-粉色墨镜") or u:hasdata("瓦拉齐亚之夜-夜晚强化") or u:hasdata("变异判定-Lily安娜") and u:ishasitem("I02C")) then
          u:clearbuff("B00I")
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        if tg:ishasskill("S00R") or tg:ishasskill("S090") then
          if tg:ishasskill("S00R") then
            tg:delskill("S00R")
          end
          tg:delskill("S090")
          tg:clearbuff("B011")
          tg:clearbuff("B0CQ")
        end
      end)
      ac.wait(10000, function()
        if u:getdata("魔眼") == true then
          u:setdata("魔眼神化允许")
          u:sendmessage("|cFF1BE6B8……|r")
        else
          u:sendmessage("|cFF1BE6B8果然是这样么……|r")
        end
      end)
      u:addskill("S008")
      u:addskill("S053")
      u:addskill("S051")
      u:addskill("S052")
      ac.loop(1000, function()
        if u:isalive() then
          local x, y = u:getxy()
          for _, xq in ac.selector():in_rangexy(x, y, 1200):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            local a1 = xq:getface()
            local a2 = AngleBetweenUnits(xq.handle, u.handle)
            local a = a1 - a2
            if 340 <= a then
              a = a - 360
            end
            if a <= -340 then
              a = a + 360
            end
            local j4 = 8
            local t = 2
            local jl = 1200 - DistanceBetweenUnits(xq.handle, u.handle)
            for i = 1, 3 do
              if jl > 300 * i then
                j4 = j4 + 4
                t = t + 3
              end
            end
            if u:hasdata("变异判定-Lily安娜") then
              j4 = j4 * 1.5
            end
            if u:hasdata("瓦拉齐亚之夜-夜晚强化") then
              j4 = j4 * 2
            end
            if u:hasdata("物品-粉色墨镜") then
              t = t * 2
            end
            if a <= 20 and -20 <= a and u:getluckrandom(j4) then
              xq:effectadd("Abilities\\Spells\\Orc\\EtherealForm\\SpiritWalkerChange.mdl", "origin", 2)
              if xq:isnormal() then
                xq:buffset(u.handle, t, "石化")
              else
                xq:buffset(u.handle, t * 0.25, "石化")
              end
            end
            local jl2 = DistanceBetweenUnits(u.handle, xq.handle)
            local shb = false
            if jl2 <= 900 and u:getluckrandom(11) then
              shb = true
            end
            if jl2 <= 600 and u:getluckrandom(22) then
              shb = true
            end
            if jl2 <= 300 and u:getluckrandom(33) then
              shb = true
            end
            if shb then
              if u:hasdata("变异判定-Lily安娜") then
                xq:effectadd("Abilities\\Spells\\Orc\\EtherealForm\\SpiritWalkerChange.mdl", "origin", 1)
                xq:buffset(u.handle, 1, "石化")
              else
                xq:buffset(u.handle, 1, "僵直")
              end
            end
          end
        end
      end)
    end,
    effectname = "|cFF1BE6B8魔眼「Cybele」|r",
    effecttext = "|cFF1FBF00石化魔眼|r\n|cFF1BE6B8每秒看向自己的单位有几率被石化\n1200~900距离8%石化2(0.5)秒\n900~600距离12%石化3(0.75)秒\n600~300距离16%石化4(1)秒\n300距离内20%石化5(1.25)秒\n对石化单位提升12.5%伤害|r\n|cFF1FBF00女神的加护|r\n|cFF1BE6B8降低自身16%移速\n降低周围900范围10%移速,每秒11%僵直1秒\n降低周围600范围20%移速,每秒22%僵直1秒\n降低周围300范围30%移速,每秒33%僵直1秒\n周围900范围敌军精英特性免疫失效|r",
    effectart = "war3mapImported\\BTNEwl_Moyan.blp"
  },
  {
    name = "两仪式净眼",
    weight = 100,
    key = {"根源"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:getdata("瞳变异数量") >= u:getdata("瞳承载上限") and not u:ishasitem("I0IY") then
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
      u:changedata("瞳变异数量", 1)
      jibingpanding_tong(u)
      u:sendmessage("|cFFFFFF00你的视线中隐约开始出现奇怪的事物|r")
      u:setdata("系统-无视伤害免疫")
      u:setdata("变异判定-净眼破抗")
      u:become("退魔家族")
      ChangeValue(DamageSystem_Baoji, sy, 10)
      ChangeValue(DamageSystem_Baoshang, sy, 0.1)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local jl = 1
        local u = args.u
        local tg = args.tg
        if u:hasdata("隐藏职业-天谴之子") then
          jl = jl * 2
        end
        if u:hasdata("瓦拉齐亚之夜-夜晚强化") then
          jl = jl * 2
        end
        if u:getluckrandom(jl) then
          tg:effectadd("Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl")
          if tg:isnormal() then
            tg:kill(u.handle)
          else
            local txsh = 0.1 * u:getmaxhp()
            if tg:isboss() then
              txsh = 0.01 * u:gethp()
            end
            DamageUnit({
              bj = "净眼斩杀附伤",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 4,
              type = "物理",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
          end
        end
      end)
    end,
    effectname = "|cFFFFCCFF净眼|r",
    effecttext = "|cFFFFCC66【起始】|r\n|cFFFFCCFF根源\n事物理解|r\n|cFFFFFFCC无视本源|r\n|cFFFFCCFF致命斩击|r\n|cFFFFFFCC提升10%暴击率与10%暴击伤害|r\n|cFFFFCC66【继承】|r\n|cFFFFCCFF根源之痕|r\n|cFFFFFFCC濒死状态下杀敌时提升0.01%伤害加成|r\n|cFFFFCC66【神格化】根源接续\n濒死状态下死亡或杀敌时极低概率觉醒|r\n|cFF949596所谓的|r|cFFCC0000\"死\"|r|cFF949596的概念……|r",
    effectart = "war3mapImported\\BTNEwl_Jingyan.blp"
  },
  {
    name = "白眼",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = true
      if u:getdata("瞳变异数量") >= u:getdata("瞳承载上限") and not u:ishasitem("I0IY") then
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
      u:changedata("瞳变异数量", 1)
      jibingpanding_tong(u)
      u:sendmessage("|cFF1BE6B8获得白眼|r")
      
      local function chattrg(args)
        if (args.chat == "白眼" or args.chat == "Byakugan") and u:isalive() and not u:hasdata("白眼") then
          u:setdata("白眼")
          u:playsound(Baiyan)
          u:changedata("闪避值", 100)
          ChangeValue(Hero_Tili_Huifu, sy, -0.5)
          ac.loop(1000, function(t)
            if not (not (Hero_Tili[sy] < 3) and u:hasdata("白眼")) or not u:isalive() then
              u:sendmessage("|cFF7DBEF1白眼关闭|r")
              u:changedata("闪避值", -100)
              ChangeValue(Hero_Tili_Huifu, sy, 0.5)
              u:deldata("白眼")
              t:remove()
            end
          end)
        end
        if (args.chat == "闭" or args.chat == "Heigan") and u:hasdata("白眼") then
          u:deldata("白眼")
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chattrg(args)
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        if not u:hasdata(var.name .. "-特效冷却") and not tg:hasdata("六十四掌效果") then
          u:settimedata(var.name .. "-特效冷却", 1)
          tg:settimedata("六十四掌效果", 3)
          tg:buffset(u.handle, 3, "精英特性失效")
          tg:removecharacteristics(3)
          tg:effectadd("war3mapImported\\bbb.mdl")
          local txsh = u:getlevel() * 5 * u:getstr()
          DamageUnit({
            bj = "白眼六十四掌",
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
      end)
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
        if u:hasdata("白眼净") then
          u:removefogcorrector(by)
          t:remove()
        end
      end)
    end,
    effectname = "|cFF1BE6B8白眼|r",
    effecttext = "|cFF1BE6B8血继限界-白眼|r\n|cFF00FF99视野范围扩大至3000\n输入“白眼”开启白眼 输入“闭”关闭\n受到来自除自身身后5°的伤害判定时提升100闪避值\n每秒消耗0.5点体力值 体力值不足时强行关闭|r\n|cFF1BE6B8柔拳法.八卦掌回天|r\n|cFF00FF99开启白眼时受到伤害时12%免疫并反弹该次伤害(抹除伤害) 如果是致死伤害则几率提升至24%|r\n|cFF1BE6B8柔拳法.八卦六十四掌|r\n|cFF00FF99开启白眼时无视近守\n直接伤害时造成[自身等级*力量*5]震荡伤害并使精英特性失效 持续3秒(触发冷却1秒)|r\n|cFF1BE6B8咒印|r\n|cFF00FF99开启白眼时来自背后5°的伤害无法闪避或免疫(普通伤害免疫)且必定造成200%伤害|r\n|cFF1BE6B8神化：回天抵挡或绝对闪避咒印额外伤害15次|r",
    effectart = "war3mapImported\\BTNEwl_Baiyan.blp"
  }
}
