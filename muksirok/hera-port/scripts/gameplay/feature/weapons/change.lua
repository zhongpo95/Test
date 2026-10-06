-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local message = require("jass.message")
local fszd1, fszd2, fszd3, fszd4

function weaponchangetrg(unit, wp)
  if GetItemType(wp) == ITEM_TYPE_PURCHASABLE and GetItemLevel(wp) == 1 then
    weaponchange(unit, wp)
  end
end

function weaponusetrg(unit, skill)
  local b = false
  for index, value in ipairs(Wpski) do
    if skill == GetData(value, "绑定技能") or skill == value then
      b = true
    end
  end
  if b then
    local u = getunit(unit)
    local x, y = u:getxy()
    local x2 = GetSpellTargetX() or x
    local y2 = GetSpellTargetY() or y
    weaponuse(unit, skill, x2, y2)
  end
end

function weapondowntrg(unit, skill)
  local u = getunit(unit)
  if skill == S2ID("A00C") then
    weapondown(unit)
  end
end

function weaponchange(unit, wp)
  local u = getunit(unit)
  local wplx = GetItemTypeId(wp)
  local sy = u.ownerid
  local had_equipped_weapon = Hero_Equip_WeaponBoolean[sy]
  local unequipped_weapon_type
  if had_equipped_weapon then
    unequipped_weapon_type = Hero_Equip_WeaponType[sy]
  end
  local x, y = u:getxy()
  local lx = GetData(wplx, "近战武器类型")
  SetItemPosition(wp, x, y)
  weapondown(unit, false)
  if Hero_Equip_WeaponBoolean[sy] then
    u:addspeitem(wp)
    return
  end
  local b = true
  if (wplx == Weapons["高频村雨刀"] or wplx == Weapons["高频村雨刀(锁定)"]) and WujiStart and GetUnitTypeId(BOSS) == S2ID("u05E") then
    Wuji_ShayiStart = true
    RemoveItemLua(wp)
    SendMsgAll("|cffff0000【 |r" .. u:getplayername() .. "|cffff0000 】|r|cffff0000已将村雨归还无极|r")
    return
  end
  if wplx == Weapons["高频村雨刀(锁定)"] then
    u:sendmessage("|cFFCC0000无法装备-村雨的ID权限被锁定了|r")
    return
  end
  if (wplx == Weapons["七夜"] or wplx == Weapons["业物"]) and not u:hasdata("属性-退魔家族") then
    b = false
    u:sendmessage("|cFFCC0000无法装备-非退魔家族|r")
  end
  if wplx == Weapons["楔丸"] and not u:hasdata("变异判定-狼") then
    b = false
    u:sendmessage("|cFFCC0000无法装备-非只狼|r")
  end
  if wplx == Weapons["万宝槌"] and not u:hasdata("变异判定-小人族") and not u:hasdata("变异判定-少名针妙丸") and not u:hasdata("最强的两人-天子") then
    b = false
    u:sendmessage("|cFFCC0000无法装备-非小人族|r")
  end
  if wplx == Weapons["轩辕剑(封)"] and u:hasdata("变异判定-玉藻前") then
    b = false
    u:sendmessage("|cFFCC0000玉藻前无法使用轩辕剑|r")
  end
  if wplx == Weapons["缠魇丸"] and not u:hasdata("判定-缠魇丸") then
    b = false
    u:sendmessage("|cFF990000\"你没有被它所认可\"|r")
  end
  if wplx == Weapons["青色怒火"] and not u:hasdata("判定-阿米娅") then
    b = false
    u:sendmessage("|cFF666666这不值得|r")
  end
  if wplx == Weapons["蔷薇之刃"] and not u:hasdata("初始判定-古明地恋") then
    b = false
    u:sendmessage("|cFF666666要一起玩么~|r")
  end
  if wplx == Weapons["薄暝"] and u:getallattri() < 110 and not u:hasdata("特殊判定-翼") and not u:hasdata("判定-薄暝") then
    b = false
    u:sendmessage("|cFFFF9900这把武器彰显着它的荣耀，\n它正在寻求着、渴望着能为所有人带来和平与公正。\n只有最公正无私之人能拿起它。|r")
  end
  if wplx == Weapons["草薙剑"] and not u:hasdata("变异判定-宇智波佐助") then
    b = false
  end
  if wplx == Weapons["星辰短剑"] and not u:hasdata("变异判定-Tevi") then
    b = false
    u:sendmessage("|cFFCC0000只有Tevi能使用|r")
  end
  if wplx ~= Weapons["长虹剑"] or u:hasdata("判定-虹猫") then
  else
    b = false
  end
  if wplx ~= Weapons["都牟刈村正"] or u:hasdata("神化判定-千子村正") or u:hasdata("变异判定-卫宫士郎") then
  else
    b = false
  end
  if wplx == Weapons["神刀-丛雨丸"] and not u:hasdata("丛雨结缘") then
    b = false
    if u:hasdata("丛雨") then
      u:sendmessage("|cFF66FF99「阿拉，吾怎么可以用自己呢」|r")
    else
      u:sendmessage("|cFF66FF99「汝可不是吾的主人！」|r")
    end
  end
  if wplx == Weapons["压切长谷部"] and u:hasdata("本能寺变") then
    b = false
    u:sendmessage("|cFFCC0000「任人生一度，入减随即当年。」|r")
  end
  if u:ishasskill(SKILL_TESHUYINGXIONG) and u.type ~= HeroType["C呆"] and u.type ~= HeroType["志贵"] and u.type ~= HeroType["两仪式"] and u.type ~= HeroType["史尔特尔"] and u.type ~= HeroType["千咲"] and u.type ~= HeroType["波风水门"] and u.type ~= HeroType["莲华"] and lx ~= 12 and lx ~= 11 and lx ~= 10 and lx ~= 2 then
    if u:hasdata("变异判定-戈登") then
      if wplx == Weapons["撬棍"] or wplx == Weapons["物理学圣剑"] then
      else
        b = false
        u:sendmessage("|cFFCC0000无法装备该类型武器|r")
      end
    else
      b = false
      u:sendmessage("|cFFCC0000无法装备该类型武器|r")
    end
  end
  if u.type == HeroType["千咲"] then
  end
  if u.type ~= HeroType["史尔特尔"] or lx == 12 or lx == 10 or wplx == Weapons["青色怒火"] then
  elseif u:hasdata("变异判定-戈登") then
    if wplx == Weapons["撬棍"] or wplx == Weapons["物理学圣剑"] then
    else
      b = false
      u:sendmessage("|cFFCC0000无法装备该类型武器|r")
    end
  else
    b = false
    u:sendmessage("|cFFCC0000无法装备该类型武器|r")
  end
  if (u.type == HeroType["志贵"] or u.type == HeroType["波风水门"] or u.type == HeroType["两仪式"]) and lx ~= 12 and lx ~= 9 then
    if u:hasdata("变异判定-戈登") then
      if wplx == Weapons["撬棍"] or wplx == Weapons["物理学圣剑"] then
      else
        b = false
        u:sendmessage("|cFFCC0000无法装备该类型武器|r")
      end
    else
      b = false
      u:sendmessage("|cFFCC0000无法装备该类型武器|r")
    end
  end
  if wplx == Weapons["君王之剑"] or wplx == Weapons["史莱姆剑"] then
    b = true
  end
  if wplx == Weapons["史莱姆剑"] and not u:hasdata("暗影-初始") then
    b = false
  end
  if b then
    if not UnitAddItem(System_ZbBeibao[sy], wp) then
      u:addspeitem(wp)
      u:sendmessage("|cFFCC0000装备失败，物品无法移入装备背包|r")
      return
    end
    if lx == 7 and u:hasdata("隐藏职业-龙骑士") then
      hideproshow(u.handle)
    end
    if u:hasdata("变异判定-德克萨斯") and lx == 11 then
      Effectcreate("dkss_qiehuan.mdl", x, y)
      u:sendmessage("|cFF3D63F1德克萨斯-德克萨斯传统|r")
      ChangeValue(Correction_Magic, sy, 0.0025000000000000005)
      ChangeValue(Correction_Jzsh, sy, 0.025)
      ac.wait(10000, function()
        ChangeValue(Correction_Magic, sy, -0.0025000000000000005)
        ChangeValue(Correction_Jzsh, sy, -0.025)
      end)
      if not u:hasdata("德克萨斯-德克萨斯剑术冷却") and not u:hasdata("德克萨斯-德克萨斯剑术") then
        for _, xq in ac.selector():in_rangexy(x, y, 600):is_enemy(unit):ipairs() do
          xq = getunit(xq)
          xq:buffset(unit, 3, "眩晕")
        end
        Effectcreate("dkss_fanweizhanji.mdl", x, y)
        Effectcreate("dkss_luodi.mdl", x, y)
        u:playsound(Sound_Dkss_02)
        u:sendmessage("|cFF3D63F1德克萨斯-德克萨斯剑术|r")
        u:setdata("德克萨斯-德克萨斯剑术")
        u:setdata("德克萨斯-德克萨斯剑术时间", 15)
        u:settimedata("德克萨斯-德克萨斯剑术冷却", 60)
      end
    end
    if not u:ishasskill(SKILL_TESHUYINGXIONG) or u.type == HeroType["C呆"] or u.type == HeroType["莲华"] then
      u:addskill(GetData(wplx, "绑定技能"))
    end
    if lx == 10 then
      local yx = {}
      yx[1] = Sound_Mugen_01__2_u
      yx[2] = Sound_Katana_19
      u:playsound(yx[GetRandomInt(1, 2)])
    end
    if wplx == Weapons["布都御魂"] then
      ChangeValue(DamageSplit_CountJzMax, sy, 0.5)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      ac.loop(1000, function(t)
        if Hero_Equip_WeaponType[sy] ~= Weapons["布都御魂"] then
          ChangeValue(DamageSplit_CountJzMax, sy, -0.5)
          ChangeValue(DamageSplit_CountJzHit, sy, -1)
          t:remove()
        end
      end)
    end
    if wplx == Weapons["蔷薇之刃"] then
      u:setdata("武器判定-蔷薇之刃")
    end
    if wplx == Weapons["君王之剑"] and not u:hasdata("武器判定-君王之剑") then
      u:setdata("武器判定-君王之剑")
      local add = 0
      ac.loop(1000, function(t)
        u:changedata("近战机体-基础伤害提升", -add)
        local bl = 1
        if u:hasdata("变异判定-剑圣") then
          bl = bl + u:getdata("剑圣-倍率强化") * 0.5
        end
        if u:hasdata("变异判定-星国储君") then
          bl = bl + 0.5
        end
        add = 500 * u:getdata("储君-铸造值") * bl
        u:changedata("近战机体-基础伤害提升", add)
        if Hero_Equip_WeaponType[sy] ~= Weapons["君王之剑"] then
          u:deldata("武器判定-君王之剑")
          u:changedata("近战机体-基础伤害提升", -add)
          t:remove()
        end
      end)
    end
    if wplx == Weapons["濡湿小镰刀"] then
      if u:hasdata("变异判定-正道骑士") then
        u:chat("将我的繁文缛节，弃置于此！")
      end
      u:setdata("武器判定-濡湿小镰刀")
      ChangeValue(Damage_Element_Dark, sy, 0.1)
      if u.type == HeroType["志贵"] or u.type == HeroType["两仪式"] then
        u:addstexiao("濡湿小镰刀", "近战伤害效果", function(args)
          local tg = args.tg
          if u:hasdata("武器判定-濡湿小镰刀") then
            if args.element == "无" then
              args.element = "暗"
            end
            if u:getluckrandom(10) then
              tg:buffset(u.handle, 0.15, "沉默")
              tg:buffset(u.handle, 0.3, "僵直")
            end
          end
        end)
      end
    end
    if wplx == Weapons["镰刀"] then
      u:addstexiao("镰刀", "伤害吸血效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("镰刀武器吸血") then
          info.jzxxz = info.jzxxz + 5
          info.jzlvxxz = info.jzlvxxz + 2
        end
      end)
    end
    if wplx == Weapons["草薙剑"] and not u:hasdata("武器判定-布都御魂") then
      u:setdata("武器判定-布都御魂")
      ChangeValue(DamageSplit_CountJzMax, sy, 1)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      ChangeValue(DamageSystem_Baoji, sy, 10)
      ChangeValue(DamageSystem_Baoshang, sy, 0.1)
      ChangeValue(Damage_Element_Thunder, sy, 0.1)
      u:changedata("全属性增幅", 0.05)
      ac.loop(1000, function(t)
        if Hero_Equip_WeaponType[sy] ~= Weapons["草薙剑"] then
          u:deldata("武器判定-布都御魂")
          u:changedata("全属性增幅", -0.05)
          ChangeValue(DamageSplit_CountJzMax, sy, -1)
          ChangeValue(DamageSplit_CountJzHit, sy, -1)
          ChangeValue(DamageSystem_Baoji, sy, -10)
          ChangeValue(DamageSystem_Baoshang, sy, -0.1)
          ChangeValue(Damage_Element_Thunder, sy, -0.1)
          t:remove()
        end
      end)
    end
    if wplx == Weapons["巨魔贝恩"] and not u:hasdata("武器判定-巨魔贝恩") then
      u:setdata("武器判定-巨魔贝恩")
      u:addstexiao("巨魔贝恩", "近战伤害效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("武器判定-巨魔贝恩") and not info.isvestdamage then
          if not u:hasdata("巨魔贝恩-冷却") then
            u:settimedata("巨魔贝恩-冷却", 1)
            ChangeTimeValue(Correction_Jzsh, sy, 0.010000000000000002, 15)
          end
          if not tg:hasdata("巨魔贝恩-额外受伤") then
            tg:settimedata("巨魔贝恩-额外受伤", 15)
            tg:changetimedata("怪物-额外受伤", 0.1, 15)
          end
        end
      end)
      u:addstexiao("巨魔贝恩", "暴击系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("武器判定-巨魔贝恩") and info.ismeleedamage then
          info.bjl = info.bjl + 25
          info.bjsh = info.bjsh + 0.6
        end
      end)
      ac.loop(1000, function(t)
        if Hero_Equip_WeaponType[sy] ~= Weapons["巨魔贝恩"] then
          u:deldata("武器判定-巨魔贝恩")
          t:remove()
        end
      end)
    end
    if wplx == Weapons["长虹剑"] then
      ac.wait(1500, function()
        if not u:hasdata("武器判定-长虹剑") then
          u:setdata("武器判定-长虹剑")
          u:addskill("A0MI")
          u:addskill("A0MJ")
          u:addstexiao("长虹剑", "杀敌效果", function(args)
            if u:hasdata("武器判定-长虹剑") then
              ChangeValue(DamageSystem_Shjc, sy, 8.0E-5)
            end
          end)
          u:addstexiao("长虹剑", "近战伤害特效", function(args)
            local u = args.u
            local tg = args.tg
            local info = args.damageinfo
            if not u:hasdata("武器判定-长虹剑") and not info.isvestdamage then
              local txsh = info.yssh * 0.3
              DamageUnit({
                bj = "虹猫(长虹剑附伤)",
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
          end)
          ac.loop(1000, function(t)
            if Hero_Equip_WeaponType[sy] ~= Weapons["长虹剑"] then
              u:deldata("武器判定-长虹剑")
              t:remove()
            end
          end)
        end
      end)
    end
    if wplx == Weapons["诡异柴刀"] then
      u:setdata("武器装备中判定-诡异柴刀")
      u:addskill("S0F9")
      u:banskill("S0D0", false)
      u:banskill("S0F9")
      if not u:hasdata("诡异柴刀-技能注册") then
        u:setdata("诡异柴刀-技能注册")
        u:addtrgevent("单位-发动技能", function(args)
          if args.skill == S2ID("S0F9") and u:hasdata("武器装备中判定-诡异柴刀") then
            u:changedata("诡异柴刀-切换序号", 1)
            local token = u:getdata("诡异柴刀-切换序号")
            u:banskill("S0F9")
            local x, y = u:getxy()
            local target_x = args.x or x
            local target_y = args.y or y
            local angle = AngleXY(x, y, target_x, target_y)
            local distance = DistanceXY(x, y, target_x, target_y)
            if 1000 < distance then
              distance = 1000
            end
            local x3, y3 = PolarXY(x, y, distance / 2, angle)
            local hit_group = CreateGroupLua()
            local hit_sound_played = false
            local hit_effect_count = 0
            u:buffset(u.handle, 0.6, "无敌")
            u:setface(angle)
            u:playsound(bac395)
            Effectcreate("war3mapImported\\176.mdl", x3, y3, 0, 1, 20, angle)
            Effectcreate("war3mapImported\\bbb.mdx", x, y, 0, 1)
            unitmove({
              unit = u.handle,
              time = 0.25 * distance / 1000,
              distance = distance,
              angle = angle,
              isfly = true,
              loops = {
                {
                  looptime = 0.01,
                  func = function(dx, dy)
                    for _, xq in ac.selector():in_rangexy(dx, dy, 125):is_enemy(u.handle):isnotingroup(hit_group):ipairs() do
                      xq = getunit(xq)
                      xq:groupadd(hit_group)
                      if not hit_sound_played then
                        hit_sound_played = true
                        u:playsound(Youmu_D)
                      end
                      if hit_effect_count <= 5 then
                        local x2, y2 = xq:getxy()
                        hit_effect_count = hit_effect_count + 1
                        Effectcreate("war3mapImported\\Texiao_Xuebao.mdx", x2, y2)
                      end
                      DamageUnit({
                        bj = "诡异柴刀(E2)",
                        unit = xq.handle,
                        source = u.handle,
                        damage = u:getdata("诡异柴刀-二段伤害"),
                        level = 1,
                        type = "物理",
                        isvest = false,
                        isattack = true,
                        isnoarmor = false,
                        element = "无",
                        extradata = {"近战"}
                      })
                      xq:buffset(u.handle, 1, "僵直")
                    end
                  end
                }
              },
              endfunc = function()
                DestroyGroupLua(hit_group)
                if u:hasdata("武器装备中判定-诡异柴刀") and token == u:getdata("诡异柴刀-切换序号") then
                  u:banskill("S0F9")
                  u:banskill("S0D0", false)
                  u:setskillcd("S0D0", 1.5)
                end
              end
            })
          end
        end)
      end
    end
    if wplx == Weapons["铁碎牙"] and not u:hasdata("武器判定-铁碎牙") then
      u:setdata("武器判定-铁碎牙")
      ChangeValue(DamageSystem_Baoshang, sy, 0.1)
      ac.loop(1000, function(t)
        if Hero_Equip_WeaponType[sy] ~= Weapons["铁碎牙"] then
          u:deldata("武器判定-铁碎牙")
          ChangeValue(DamageSystem_Baoshang, sy, -0.1)
          t:remove()
        end
      end)
    end
    if wplx == Weapons["潮枯"] and not u:hasdata("武器判定-潮枯") then
      local skd = getunit(Danwei_Skd)
      skd:changeowner(skd:getdata("系统-所有者"))
      skd:setdata("斯卡蒂-血亲", u.handle)
      skd:setdata("暂停时间", 0.1)
      ShowUnit(skd.handle, true)
      local sy2 = skd.ownerid
      u:setdata("武器判定-潮枯")
      u:playsound(Sound_Zxskd_Equ)
      u:addskill("S08E")
      u:addskill("S05J")
      local z = GetData(wp, "潮枯-悲歌计数")
      local s = "|cFF0066FF潮|r|cFF0066CC枯|r|cFF3399FF(E) - 悲歌计数[" .. z .. "]|r"
      ChangeValue(DamageSystem_Shjc, sy, 0.1 * (5.0E-4 * KillCount[sy]))
      u:changedata("水变异数量", 1)
      u:changedata("全属性增幅", 0.0025 * z)
      local lw = 0
      local hpm = 0
      local sxsh = 0
      local ewys = 0
      ac.loop(1000, function()
        SetPlayerAllianceStateBJ(ConvertedPlayer(sy), ConvertedPlayer(sy2), bj_ALLIANCE_ALLIED_UNITS)
        SetPlayerAllianceStateBJ(ConvertedPlayer(sy2), ConvertedPlayer(sy), bj_ALLIANCE_ALLIED_UNITS)
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -1 * ewys)
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, -1 * hpm)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * lw))
        ChangeValue(Damage_Element_Water, sy, -1 * sxsh)
        ewys = 0
        hpm = 0.02 * u:getstate("水变异")
        lw = 0.25 * u:getstate("水变异")
        if Group_Counts(Group_Xingcunzu) <= 1 then
          ewys = ewys + 100
          lw = lw + 1
          u:setdata("潮枯-孤海彷徨")
        else
          u:deldata("潮枯-孤海彷徨")
        end
        if not u:isingroup(SystemGroup_Battle) then
          if u:hasdata("潮枯-孤海彷徨") then
            u:changedata("潮枯-护盾值", 0.02 * u:getmaxhp())
          else
            u:changedata("潮枯-护盾值", 0.01 * u:getmaxhp())
          end
          local max = 0.1 * u:getmaxhp() * u:getstate("水变异")
          if max <= u:getdata("潮枯-护盾值") then
            u:setdata("潮枯-护盾值")
          end
          if not u:hasdata("潮枯-护盾特效") then
            u:setdata("潮枯-护盾特效", u:effectadd("Abilities\\Spells\\Human\\ManaShield\\ManaShieldCaster.mdl", "origin", -1))
          end
        end
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 1 * ewys)
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, 1 * hpm)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * lw))
        ChangeValue(Damage_Element_Water, sy, 1 * sxsh)
      end)
      Effectcreate("Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl", x, y)
      for i = 1, 2 do
        local mj = CreateUnitLua(GetOwningPlayer(Danwei_Skd), S2ID("n00I"), x, y, 0)
        mj = getunit(mj)
        mj:setguard(u.handle)
        u:changedata("召唤物数量", 1)
        mj:groupadd(u:getdata("召唤物组"))
        mj:setdata("常规召唤物", "海嗣")
        mj:groupadd(Group_ZhaohuanwuAll)
      end
    end
    if wplx == Weapons["忴"] then
      u:setdata("武器判定-忴")
      u:setskillcd("A0LD", 4)
      u:addskill("A0LG")
      u:banskill("A0LG")
      if not u:hasdata("忴-技能注册") then
        u:setdata("忴-技能注册")
        local g = CreateGroupLua()
        
        local function skill(args)
          if args.skill == S2ID("A0LD") then
            ForGroupLuaNew(g, function(xq)
              if xq:hasdata("忴-标记") then
                DestroyEffectLua(xq:getdata("忴-标记"))
                xq:deldata("忴-标记")
              end
            end)
            local x, y = u:getxy()
            ac.wait(1, function()
              u:banskill("A0LD")
              u:banskill("A0LG", false)
            end)
            ac.wait(3000, function()
              u:banskill("A0LD", false)
              u:banskill("A0LG")
            end)
            Effectcreate("war3mapImported\\ring_1.mdx", x, y)
            for _, xq in ac.selector():in_rangexy(x, y, 1000):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g)
              xq:setdata("忴-标记", xq:effectadd("war3mapimported\\file00000868.mdl", "overhead", -1))
              xq:buffset(u.handle, 5, "破坏-伤害免疫")
              xq:buffset(u.handle, 1, "僵直")
            end
          end
          if args.skill == S2ID("A0LG") then
            local txsh = 25000 + 1000 * u:getlevel() + 100 * u:getallattri()
            u:banskill("A0LD", false)
            u:banskill("A0LG")
            u:buffset(u.handle, 0.15, "无敌")
            u:buffset(u.handle, 0.15, "绝对闪避")
            local ox, oy = u:getxy()
            local a = u:getface()
            u:setcolor(255, 255, 255, 125)
            local cs = 0
            local tx1 = u:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "hand left", -1)
            local tx2 = u:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "hand right", -1)
            ac.loop(100, function(timer)
              if Group_Counts(g) > 0 then
                u:setskillcd("A0LD", 4)
                cs = cs + 1
                local tg = Group_Randomunit(g)
                if type(tg) ~= "table" then
                  error("忴目标组计数与内容不一致")
                end
                if 3 < cs then
                  tg:groupremove(g)
                end
                u:buffset(u.handle, 0.2, "无敌")
                u:buffset(u.handle, 0.2, "绝对闪避")
                u:buffset(u.handle, 0.2, "暂停")
                DamageUnit({
                  bj = "忴(怜)",
                  unit = tg.handle,
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
                tg:effectadd("Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl", "origin")
                local dx, dy = tg:getxy()
                local x3, y3 = PolarXY(dx, dy, 100, GetRandomAngle())
                u:setxy(x3, y3)
                local angle = AngleXY(x3, y3, dx, dy)
                u:setface(angle)
                Effectcreate("war3mapimported\\texiao_xukongtongyizhi.mdl", x3, y3)
                if 3 < cs and tg:hasdata("忴-标记") then
                  DestroyEffectLua(tg:getdata("忴-标记"))
                  tg:deldata("忴-标记")
                end
              else
                u:buffset(u.handle, 0.5, "无敌")
                ac.wait(100, function()
                  DestroyEffectLua(tx1)
                  DestroyEffectLua(tx2)
                end)
                u:setxy(ox, oy)
                u:setcolor(255, 255, 255, 255)
                u:setface(a)
                timer:remove()
              end
            end)
          end
        end
        
        u:addtrgevent("单位-发动技能", function(args)
          skill(args)
        end)
      end
    end
    if wplx == Weapons["缠魇丸"] then
      u:setdata("武器判定-缠魇丸")
      ChangeValue(Correction_Jzsh, sy, 0.010000000000000002)
      ChangeValue(Correction_Jzsh, sy, 0.010000000000000002)
      u:addskill("A1KW")
      u:addskill("A1KY")
      u:addskill("A1KX")
      u:banskill("A1KW")
      u:banskill("A1KX")
      if not u:hasdata("缠魇丸-技能注册") then
        u:setdata("缠魇丸-技能注册")
        
        local function skill(args)
          if args.skill == S2ID("A1KV") then
            local x, y = u:getxy()
            local jd = u:getface()
            local x2, y2 = PolarXY(x, y, 400, jd)
            local txsh = 6000 + 35 * u:getstate("累积杀敌")
            ac.wait(100, function()
              u:banskill("A1KV")
              u:banskill("A1KW", false)
            end)
            ac.wait(700, function()
              if u:hasdata("缠魇丸-二段释放") then
                u:deldata("缠魇丸-二段释放")
                ac.wait(700, function()
                  u:banskill("A1KV", false)
                  u:banskill("A1KW")
                  u:banskill("A1KX")
                end)
              else
                u:banskill("A1KV", false)
                u:banskill("A1KW")
                u:banskill("A1KX")
              end
            end)
            local cs = 0
            ac.loop(150, function(timer)
              cs = cs + 1
              x, y = u:getxy()
              Effectcreate("ZK_JSGF.mdl", x, y, 1, 1, 100, GetRandomAngle())
              u:playsound(bac63)
              local jd3 = GetRandomAngle()
              Effectcreate("war3mapImported\\3.30.341 (2).mdl", x, y, 0, 1, 0, GetRandomAngle())
              local vest = getunit(System_SkillVest)
              vest:addskill("A1LA")
              for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                DamageUnit({
                  bj = "缠魇丸",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "物理",
                  isvest = true,
                  isattack = true,
                  isnoarmor = false,
                  element = "无",
                  extradata = {"近战"}
                })
                xq:buffset(u.handle, 0.5, "僵直")
                IssueTargetOrder(vest.handle, "curse", xq.handle)
                xq:setdata("缠魇丸-斩灭时间", 3)
                xq:groupadd(Group_Cyw)
                if u:hasdata("变异判定-鬼灭之刃") and not xq:hasdata("缠魇丸杀敌判定") then
                  xq:setdata("缠魇丸杀敌判定")
                  ac.wait(100, function()
                    xq:deldata("缠魇丸杀敌判定")
                    if not xq:isalive() then
                      u:changedata("鬼灭之刃杀敌", 1)
                    end
                  end)
                end
              end
              vest:delskill("A1LA")
              if cs == 3 then
                timer:remove()
              end
            end)
          end
          if args.skill == S2ID("A1KW") then
            local x, y = u:getxy()
            local jd = u:getface()
            local x2, y2 = PolarXY(x, y, 200, jd)
            u:playsound(bac67)
            local jd2 = GetRandomAngle()
            Effectcreate("ZK_SJDLDE.mdl", x, y, 1, 2, 100, jd2, 0, 0, 2)
            Effectcreate("ZK_SJDLDE.mdl", x, y, 1, 2, 100, jd2 + 180, 0, 0, 2)
            local txsh = 5000 + 25 * u:getstate("累积杀敌")
            u:setdata("缠魇丸-二段释放")
            u:setskillcd("A1KV", 5)
            ac.wait(100, function()
              u:banskill("A1KW")
              u:banskill("A1KX", false)
            end)
            local vest = getunit(System_SkillVest)
            vest:addskill("A1LA")
            for _, xq in ac.selector():in_rangexy(x, y, 450):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              DamageUnit({
                bj = "缠魇丸",
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
              xq:setxy(x, y)
              xq:effectadd("Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl", "chest")
              xq:buffset(u.handle, 0.5, "僵直")
              IssueTargetOrder(vest.handle, "curse", xq.handle)
              xq:setdata("缠魇丸-斩灭时间", 3)
              xq:groupadd(Group_Cyw)
              if u:hasdata("变异判定-鬼灭之刃") and not xq:hasdata("缠魇丸杀敌判定") then
                xq:setdata("缠魇丸杀敌判定")
                ac.wait(100, function()
                  xq:deldata("缠魇丸杀敌判定")
                  if not xq:isalive() then
                    u:changedata("鬼灭之刃杀敌", 1)
                  end
                end)
              end
            end
            vest:delskill("A1LA")
          end
          if args.skill == S2ID("A1KX") then
            local x, y = u:getxy()
            local x2 = args.x or x
            local y2 = args.y or y
            local jd = AngleXY(x, y, x2, y2)
            u:playsound(bac1)
            Effectcreate("war3mapImported\\nitu.mdl", x, y, 0, 1, 0, jd)
            u:curetili(-1)
            local txsh = 5000 + 25 * u:getstate("累积杀敌")
            u:setskillcd("A1KV", 5)
            u:banskill("A1KX")
            u:banskill("A1KV", false)
            u:buffset(u.handle, 0.35, "暂停")
            local cs = 0
            local cs2 = 0
            local cs3 = 0
            local jl = 35
            local g = CreateGroupLua()
            local txn = {}
            ac.loop(10, function(timer)
              cs = cs + 1
              cs2 = cs2 + 1
              x, y = u:getxy()
              local x2, y2 = PolarXY(x, y, jl, jd)
              local x3, y3 = PolarXY(x, y, 100, jd)
              u:setxy(x2, y2)
              for _, xq in ac.selector():in_rangexy(x2, y2, 150):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:buffset(u.handle, 0.5, "暂停")
                xq:groupadd(g)
              end
              ForGroupLuaNew(g, function(xq)
                xq:setxy(x3, y3)
              end)
              if cs == 5 or cs == 20 or cs == 35 then
                u:playsound(bac80)
              end
              if cs <= 20 and 5 <= cs2 then
                cs3 = cs3 + 1
                cs2 = 0
                local ox = cs * 2.5 * math.cos(jd)
                local oy = cs * 2.5 * math.sin(jd)
                local dx, dy = PolarXY(x, y, cs * 2.5, jd)
                txn[cs3] = Effectcreate("ZK_KLSTGZS8.mdx", dx, dy, -1, 1, 125, jd, GetRandomAngle())
                SetData(txn[cs3], "绑定X", ox)
                SetData(txn[cs3], "绑定Y", oy)
                Effectcreate("war3mapImported\\3.30.341 (3).mdl", x2, y2, 0, 1, 0, GetRandomAngle(), GetRandomAngle())
              end
              if 0 < cs3 then
                for i = 1, cs3 do
                  local ox = GetData(txn[i], "绑定X")
                  local oy = GetData(txn[i], "绑定Y")
                  local x4 = x + ox
                  local y4 = y + oy
                  SetEffectXY(txn[i], x4, y4)
                end
              end
              if cs == 35 then
                for i = 1, cs3 do
                  SetEffectSize(txn[i], 0)
                  DestroyEffectLua(txn[i])
                end
                ForGroupLuaNew(g, function(xq)
                  xq:effectadd("war3mapImported\\texiao_xuebao.mdx")
                  xq:buffset(u.handle, 0.8, "眩晕")
                  if u:hasdata("变异判定-鬼灭之刃") and not xq:hasdata("缠魇丸杀敌判定") then
                    xq:setdata("缠魇丸杀敌判定")
                    ac.wait(100, function()
                      xq:deldata("缠魇丸杀敌判定")
                      if not xq:isalive() then
                        u:changedata("鬼灭之刃杀敌", 1)
                      end
                    end)
                  end
                end)
                Effectcreate("ZK_MGF.mdx", x2, y2, 1, 1.5, 0, GetRandomAngle())
                local dcs = 0
                ac.loop(200, function(timer2)
                  dcs = dcs + 1
                  Effectcreate("war3mapImported\\3.30.341 (8).mdl", x2, y2, 0, 1.5, 0, GetRandomAngle())
                  Effectcreate("ZK_KLST.mdx", x2, y2, 1, 1.5, GetRandomReal(50, 150), GetRandomAngle())
                  if dcs == 5 then
                    local ddx, ddy = PolarXY(x2, y2, -350, jd)
                    local tx = Effectcreate("ZK_LPZG.mdx", ddx, ddy, 1, 3, 50, jd, 0, 0, 3)
                    ac.wait(1000, function()
                      SetEffectSize(tx, 0.01)
                    end)
                  end
                  u:playsound(bac81)
                  local vest = getunit(System_SkillVest)
                  vest:addskill("A1LA")
                  ForGroupLuaNew(g, function(xq)
                    xq:animeact("death")
                    DamageUnit({
                      bj = "缠魇丸",
                      unit = xq.handle,
                      source = u.handle,
                      damage = txsh,
                      level = 1,
                      type = "物理",
                      isvest = true,
                      isattack = true,
                      isnoarmor = false,
                      element = "无",
                      extradata = {"近战"}
                    })
                    xq:buffset(u.handle, 0.5, "僵直")
                    IssueTargetOrder(vest.handle, "curse", xq.handle)
                    xq:setdata("缠魇丸-斩灭时间", 3)
                    xq:groupadd(Group_Cyw)
                    if u:hasdata("变异判定-鬼灭之刃") and not xq:hasdata("缠魇丸杀敌判定") then
                      xq:setdata("缠魇丸杀敌判定")
                      ac.wait(100, function()
                        xq:deldata("缠魇丸杀敌判定")
                        if not xq:isalive() then
                          u:changedata("鬼灭之刃杀敌", 1)
                        end
                      end)
                    end
                  end)
                  vest:delskill("A1LA")
                  if dcs == 5 then
                    timer2:remove()
                  end
                end)
                timer:remove()
              end
            end)
          end
        end
        
        u:addtrgevent("单位-发动技能", function(args)
          skill(args)
        end)
      end
      local add = 0
      ac.loop(1000, function(t)
        ForGroupLuaNew(Group_Cyw, function(xq)
          xq:changedata("缠魇丸-斩灭时间", -1)
          if xq:getdata("缠魇丸-斩灭时间") <= 0 then
            xq:deldata("缠魇丸-斩灭时间")
            xq:groupremove(Group_Cyw)
          end
        end)
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -1 * add)
        add = 5 * Group_Counts(Group_Cyw)
        if 150 <= add then
          add = 150
        end
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 1 * add)
        if Hero_Equip_WeaponType[sy] ~= Weapons["缠魇丸"] then
          ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -1 * add)
          ChangeValue(Correction_Jzsh, sy, -0.010000000000000002)
          ChangeValue(Correction_Jzsh, sy, -0.010000000000000002)
          t:remove()
        end
      end)
    end
    if wplx == Weapons["薄暝"] and not u:hasdata("武器判定-薄暝") then
      u:addstexiao("武器-薄暝", "暴击系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("薄暝-必暴") then
          info.iscbcrit = true
        end
      end)
      u:setdata("武器判定-薄暝")
      u:addskill("S076")
      ChangeValue(DamageSplit_CountJzMax, sy, 0.6)
      ChangeValue(DamageSplit_CountJzHit, sy, 3)
      if not Boolean_BaomingTip[1] and not Boolean_BaomingIng and u:hasdata("判定-薄暝") then
        Danwei_Baoming = u.handle
        Boolean_BaomingTip[1] = true
        Boolean_BaomingIng = true
        PlayGlobalSound(EGO_Bird_03)
        SendMsgAll("|cFFFF9900很久很久以前，在一片温暖又繁茂的森林里住着三只快乐的鸟儿。|r")
        DayNightRun = false
        ac.wait(2000, function()
          SetDayNightModels("Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdx", "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdx")
          SetTimeOfDay(12)
          CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 2.0, "war3mapImported\\Baoming_Ph_01.tga", 100.0, 100.0, 100.0, 0)
        end)
        ac.wait(3000, function()
          SendMsgAll("|cFFFF9900在一个晴朗的午后，一位陌生人想进入这片宁静的森林却被拦下，陌生人愤怒了，在离开前向鸟儿们扔下一段话：|r")
        end)
        ac.wait(6000, function()
          PlayGlobalSound(EGO_Weapon_01)
          CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 2.0, "war3mapImported\\Baoming_Ph_01.tga", 100.0, 100.0, 100.0, 0)
        end)
        ac.wait(7000, function()
          SendMsgAll("|cFF3366FF“很快，灾难就会降临这片森林。|r")
          DayNightRun = true
        end)
        ac.wait(10000, function()
          SendMsgAll("|cFF3366FF这里将被邪恶与罪孽所浸染，|r")
        end)
        ac.wait(13000, function()
          SendMsgAll("|cFF3366FF处处都会充满血腥可怖的争斗，|r")
        end)
        ac.wait(16000, function()
          SendMsgAll("|cFF3366FF直到一个恐怖的怪物吞噬掉一切！|r")
        end)
        ac.wait(19000, function()
          SendMsgAll("|cFF3366FF日月星辰再也不会照耀你们，|r")
        end)
        ac.wait(22000, function()
          SendMsgAll("|cFF3366FF森林永远不会恢复往日的和谐！”|r")
          Boolean_BaomingIng = false
        end)
      else
        SendMsgAll("|cFFFFCC00永不闭合的眼睛、|r|cFF1BE6B8衡量罪孽的天平、|r|cFFFF0000吞噬万物的巨口，|r|cFF530080三者守护着黑森林的和平。\n而那位能够同时驾驭这三者的人也能带来永远的和平。|r")
      end
      local add = 0
      ac.loop(1000, function(t)
        u:changedata("固定伤害", 0.1 * (-1 * add))
        if u:hasdata("终末鸟-高鸟形态") then
          add = 30 * u:getdata("薄暝-罪痕层数")
        else
          add = 10 * u:getdata("薄暝-罪痕层数")
        end
        u:changedata("固定伤害", 0.1 * (1 * add))
        if Hero_Equip_WeaponType[sy] ~= Weapons["薄暝"] then
          ChangeValue(DamageSplit_CountJzMax, sy, -0.6)
          ChangeValue(DamageSplit_CountJzHit, sy, -3)
          u:sendmessage("|cFFFF9900薄暝-解除|r")
          u:changedata("固定伤害", 0.1 * (-1 * add))
          u:delskill("S076")
          u:deldata("武器判定-薄暝")
          t:remove()
        end
      end)
    end
    if wplx == Weapons["雪霞狼"] and not u:hasdata("武器判定-雪霞狼") then
      u:setdata("武器判定-雪霞狼")
      ChangeValue(Correction_Jzsh, sy, 0.010000000000000002)
      ChangeValue(DamageSystem_Baoji, sy, 5)
      ChangeValue(DamageSystem_Baoshang, sy, 0.12)
      ac.loop(2000, function(t)
        if Hero_Equip_WeaponType[sy] ~= Weapons["雪霞狼"] then
          u:deldata("武器判定-雪霞狼")
          ChangeValue(Correction_Jzsh, sy, -0.010000000000000002)
          ChangeValue(DamageSystem_Baoji, sy, -5)
          ChangeValue(DamageSystem_Baoshang, sy, -0.12)
          t:remove()
        end
      end)
    end
    if wplx == Weapons["银冰之枪"] then
      u:setdata("武器判定-银冰之枪")
      local add = 0
      local cs = 0
      u:addstexiao("银冰之枪", "近战伤害效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("武器判定-银冰之枪") and not tg:hasdata("银冰之枪-冰河") then
          tg:settimedata("银冰之枪-冰河", 6)
          tg:changetimearmor(-25, 6)
        end
      end)
      u:addstexiao("银冰之枪", "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("武器判定-银冰之枪") and tg:hasbuff("冰冻") then
          info.wsmy = true
        end
      end)
      ac.loop(1000, function(t)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * add))
        add = 0.15 * u:getdata("冰变异数量")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * add))
        cs = cs + 1
        if cs == 60 then
          cs = 0
          u:changearmor(100)
          ac.wait(30000, function()
            u:changearmor(-100)
          end)
        end
        if Hero_Equip_WeaponType[sy] ~= Weapons["银冰之枪"] then
          u:deldata("武器判定-银冰之枪")
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * add))
          t:remove()
        end
      end)
    end
    if wplx == Weapons["雷霆长枪"] then
      u:setdata("武器判定-雷霆长枪")
      u:addstexiao("雷霆长枪", "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:hasbuff("麻痹") then
          info.end2 = info.end2 + 0.05
        end
      end)
    end
    if wplx == Weapons["涤罪七雷"] and not u:hasdata("武器判定-涤罪七雷") then
      u:setdata("武器判定-涤罪七雷")
      u:changedata("雷变异数量", 1)
      ChangeValue(Damage_Element_Thunder, sy, 0.1)
      ChangeValue(Damage_Element_All, sy, 0.05)
      ChangeValue(Damage_ElementRes_Thunder, sy, 20)
      if not u:hasdata("武器判定-鸣雷见") then
        ac.loop(3000, function(t)
          if u:hasdata("变异判定-雷之律者") then
            local skill = S2ID("A000")
            u:setskilldatastring(skill, "提示", "|cFF9E47BA涤|r|cFF9F3EA6罪|r|cFF9F3593七雷|r|cFFA21A58.鸣雷见(E)|r")
            u:setskilldatastring(skill, "图标", "Ewl_LeilvNew_04")
            local effecttext = "|cFF9E47BA雷属性物理伤害-375范围-僵直1秒|r\n|cFF9F3EA6①鸣雷神|r\n|cFF963E9A②诛愆尤|r\n|cFF9F3593③伏逆戈|r\n|cFFA1236C④裁决之键|r\n|cFFA21A58冷却1.5秒|r"
            u:setskilldatastring(skill, "提示拓展", effecttext)
            ChangeValue(Damage_Element_All, sy, 0.05)
            u:setdata("武器判定-鸣雷见")
            u:addskill("S026")
            local dskill = S2ID("A1SU")
            local ewl = getunit(Ewl_Skill[sy])
            ewl:setskilldatastring(dskill, "提示", "|cFF9E47BA狂|r|cFF9F3EA6风，|r|cFF9F3593臣|r|cFFA02C7F服|r|cFFA1236C于|r|cFFA21A58我！|r")
            ewl:setskilldatastring(dskill, "图标", "Ewl_LeilvNew_01")
            local effecttext = "|cFF9E47BABOSS战时进入律者化状态|r\n|cFF9F3593如果已经处于律者化状态则切换天气至雷鸣并刷新剑现天照神冷却\n每次BOSS战只能使用一次|r\n|cFFA21A58冷却720秒|r"
            ewl:setskilldatastring(dskill, "提示拓展", effecttext)
            u:byladdskill(dskill, function(args)
              if args.skill == dskill then
                local b = true
                if not u:isalive() then
                  b = false
                  u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
                end
                if u:hasdata("涤罪七雷-已发动") then
                  b = false
                  u:sendmessage("|cFF7DBEF1当前BOSS战已发动|r")
                end
                if not BossBattle then
                  b = false
                  u:sendmessage("|cFF7DBEF1未处于BOSS战|r")
                end
                if b then
                  u:setdata("涤罪七雷-已发动")
                  if not u:hasdata("特殊判定-律者形态") then
                    u:getdata("雷之律者-律者化函数")()
                  else
                    ewl:setskillcd("A15J", 1)
                    local npc = getunit(NPC_TIANZI)
                    if Morihuanjing_String ~= "雷鸣" then
                      npc:setdata("环境变更")
                      npc:setdata("雷律天气切换")
                    end
                  end
                  ewl:banskill(dskill)
                  ac.wait(720000, function()
                    ewl:banskill(dskill, false)
                    u:sendmessage("|cFF7DBEF1冷却完毕-狂风，臣服于我！|r")
                  end)
                else
                  ewl:setskillcd(dskill, 1)
                end
              end
            end)
            t:remove()
          end
          if not u:hasdata("武器判定-涤罪七雷") then
            t:remove()
          end
        end)
      end
    end
    if wplx == Weapons["龙刃"] and not u:hasdata("武器判定-龙刃") then
      u:setdata("武器判定-龙刃")
      u:setdata("武器判定-特殊近战武器")
      local tt = flytext({
        unit = u.handle,
        text = "",
        size = 8,
        time = -1,
        height = 0,
        xspeed = 0,
        yspeed = 0
      })
      ac.loop(30, function(t)
        local text
        if u:hasdata("龙刃-E持续效果") then
          u:changedata("龙刃-E持续效果", -0.03)
          text = "|cFF99FF99" .. string.format("%.1f", u:getdata("龙刃-E持续效果"))
          if u:getdata("龙刃-E持续效果") <= 0 then
            u:deldata("龙刃-E持续效果")
          end
        else
          text = "|cFF99FF99" .. u:getdata("龙刃-镖命中次数") .. "/50"
        end
        SetTextTagText(tt, text, TextTagSize2Height(8))
        SetTextTagPosUnit(tt, u.handle, 0)
        if not u:hasdata("武器判定-龙刃") then
          TimerDestroyTextTag(0, tt)
          t:remove()
        end
      end)
      ARskillreplace({
        unit = u.handle,
        level = -1,
        skill_A = "A00K",
        skill_R = "A00S",
        isforce = false,
        efunc = function()
          gunskilltrg({
            unit = u.handle,
            skill = S2ID("A1N1")
          })
          if not u:hasdata("龙刃-技能注册") then
            u:setdata("龙刃-技能注册")
            u:addstexiao("龙刃", "位移技能后效果", function(args)
              if u:hasdata("龙刃-E持续效果") and not u:hasdata("龙刃-E碰撞效果判定中") then
                u:setdata("龙刃-E碰撞效果判定中")
                local g = CreateGroupLua()
                local cs = 0
                ac.loop(100, function(t)
                  cs = cs + 1
                  local x, y = u:getxy()
                  local txsh = 10000 + 500 * u:getlevel()
                  for _, xq in ac.selector():in_rangexy(x, y, 225):is_enemy(u.handle):isnotingroup(g):ipairs() do
                    xq = getunit(xq)
                    xq:groupadd(g)
                    DamageUnit({
                      bj = "龙刃(碰撞)",
                      unit = xq.handle,
                      source = u.handle,
                      damage = txsh,
                      level = 1,
                      type = "物理",
                      isvest = false,
                      isattack = true,
                      isnoarmor = false,
                      element = "无"
                    })
                    xq:buffset(u.handle, 1, "眩晕")
                    xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
                  end
                  if cs == 3 then
                    u:deldata("龙刃-E碰撞效果判定中")
                    t:remove()
                  end
                end)
              end
            end)
            
            local function feibiao(u, angle)
              local x, y = u:getxy()
              unifycreate({
                owner = u.handle,
                model = "Abilities\\Weapons\\SentinelMissile\\SentinelMissile.mdl",
                modelname = "飞镖",
                modelsize = 0.75,
                height = 50,
                damage = 0,
                damagetype = 1,
                x = x,
                y = y,
                range = 2500,
                speed = 4000,
                volume = 90,
                angle = angle,
                angleoffset = 0,
                attenua = 1,
                attenuacount = 2,
                life = 10,
                isbullet = false,
                isvest = false,
                isignorearmor = false,
                hitafterfunc = function(mj, xq, damage2)
                  DamageUnit({
                    bj = "龙刃(飞镖)",
                    unit = xq.handle,
                    source = u.handle,
                    damage = 10000 + 500 * u:getlevel(),
                    level = 1,
                    type = "物理",
                    isvest = false,
                    isattack = true,
                    isnoarmor = false,
                    element = "无"
                  })
                  xq:buffset(u.handle, 0.5, "僵直")
                  if not u:hasdata("龙刃-E持续效果") and not u:hasdata("龙刃-E变化") then
                    u:changedata("龙刃-镖命中次数", 1)
                    if u:getdata("龙刃-镖命中次数") >= 50 then
                      u:setdata("龙刃-E变化")
                      local skill = S2ID("A00U")
                      u:setskilldatastring(skill, "图标", "BTNWeapon_Longren_02")
                      local effecttext = "|cFF66FF996秒内获得以下加成:\n极限移速\n位移技能碰撞225范围附带[10000+500*等级]物理近战伤害与1秒眩晕\n[斩]冷却时间降低至0.75秒\n[斩]基础伤害提升100%\n[斩]发动时刷新位移技能冷却\n持续期间镖不会计入命中|r"
                      u:setskilldatastring(skill, "提示拓展", effecttext)
                    end
                  end
                end,
                endfunc = function(mj)
                end
              })
            end
            
            local function skill(args)
              if args.skill == S2ID("A00K") then
                local x, y = u:getxy()
                local x2 = args.x
                local y2 = args.y
                local angle = AngleXY(x, y, x2, y2)
                feibiao(u, angle)
                ac.timer(200, 2, function()
                  local x, y = u:getxy()
                  local angle = AngleXY(x, y, x2, y2)
                  feibiao(u, angle)
                end)
              end
              if args.skill == S2ID("A00S") then
                u:effectadd("Abilities\\Spells\\Human\\ControlMagic\\ControlMagicTarget.mdl", "overhead", 2)
                local str = "龙刃格挡判定时间"
                if Boolean_Jinselingyu then
                  u:setdata(str, 0.3)
                else
                  u:setdata(str, 2)
                end
              end
              if args.skill == S2ID("A00U") then
                if u:hasdata("龙刃-E变化") then
                  u:deldata("龙刃-E变化")
                  u:setdata("龙刃-镖命中次数", 0)
                  u:playsound(Sound_Yuanshi_01)
                  u:setdata("龙刃-E持续效果", 6)
                  u:addskill("S027")
                  local skill = S2ID("A00U")
                  u:setskilldatastring(skill, "提示", "|cFF99FF99斩(E)|r")
                  u:setskilldatastring(skill, "图标", "BTNWeapon_Longren_04")
                  local effecttext = "|cFF99FF99[20000+1000*等级]物理伤害-325范围-僵直0.75秒|r\n|cFF66FF99使用时刷新位移技能冷却\n冷却0.75秒|r"
                  u:setskilldatastring(skill, "提示拓展", effecttext)
                  ac.wait(6000, function()
                    u:delskill("S027")
                    u:clearbuff("B0ED")
                    u:setskilldatastring(skill, "提示", "|cFF99FF99龙|r|cFF66FF99刃(E)|r")
                    u:setskilldatastring(skill, "图标", "BTNWeapon_Longren_03")
                    local effecttext = "|cFF99FF99[10000+500*等级]物理伤害-325范围-僵直0.75秒|r\n|cFF66FF99冷却1.5秒|r"
                    u:setskilldatastring(skill, "提示拓展", effecttext)
                  end)
                end
                if u:hasdata("龙刃-E持续效果") then
                  u:setskillcd(args.skill, 0.75)
                  local skill = u:getdata("位移技能-W")
                  u:setskillcd(skill, 0)
                  local skill = u:getdata("位移技能-Q")
                  u:setskillcd(skill, 0)
                end
              end
            end
            
            u:addtrgevent("单位-发动技能", function(args)
              skill(args)
            end)
          end
        end
      })
    end
    if wplx == Weapons["环印骑士直剑"] then
      if u:hasdata("变异判定-正道骑士") then
        u:chat("我想起来了……其实我一直都是一名骑士啊！")
      end
      if not u:hasdata("武器判定-环印骑士直剑") then
        u:setdata("武器判定-环印骑士直剑")
        u:setdata("武器判定-特殊近战武器")
        ac.loop(50, function(t)
          if u:hasdata("环直-刷新时间") then
            u:changedata("环直-刷新时间", -0.05)
            if u:getdata("环直-刷新时间") <= 0 then
              u:deldata("环直-刷新时间")
            end
          end
          if not u:hasdata("武器判定-环印骑士直剑") then
            t:remove()
          end
        end)
        ARskillreplace({
          unit = u.handle,
          level = -1,
          skill_A = "A01Z",
          skill_R = "A026",
          isforce = false,
          efunc = function()
            gunskilltrg({
              unit = u.handle,
              skill = S2ID("A1N1")
            })
            if not u:hasdata("环印骑士直剑-技能注册") then
              u:setdata("环印骑士直剑-技能注册")
              
              local function skill(args)
                if args.skill == S2ID("A01Z") then
                  u:lossstamina(3)
                  u:settimedata("环直-格挡效果", 0.8)
                  u:effectadd("Abilities\\Spells\\Human\\ControlMagic\\ControlMagicTarget.mdl", "overhead", 0.8)
                end
                if args.skill == S2ID("A026") and u:hasdata("环直-刷新时间") then
                  u:setskillcd("A01K", 0)
                end
                if args.skill == S2ID("A01K") then
                  u:lossstamina(1)
                  ac.wait(250, function()
                    u:setdata("环直-刷新时间", 0.25)
                  end)
                end
              end
              
              u:addtrgevent("单位-发动技能", function(args)
                skill(args)
              end)
              u:addtrgevent("单位-发动技能结束", function(args)
                if args.skill == S2ID("A026") then
                  u:effectadd("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl")
                  u:effectadd("Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl", "hand left", 30)
                  if not u:hasdata("环直-余火持续时间") then
                    u:setdata("环直-余火持续时间", 30)
                    ac.loop(1000, function(t)
                      u:changedata("环直-余火持续时间", -1)
                      if u:getdata("环直-余火持续时间") <= 0 then
                        u:deldata("环直-余火持续时间")
                        t:remove()
                      end
                    end)
                  else
                    u:setdata("环直-余火持续时间", 30)
                  end
                end
              end)
            end
          end
        })
      end
    end
    if wplx == Weapons["红城的律令"] and not u:hasdata("武器判定-红城的律令") then
      u:setdata("武器判定-红城的律令")
      u:setdata("武器判定-特殊近战武器")
      ARskillreplace({
        unit = u.handle,
        level = -1,
        skill_A = "A0FN",
        skill_R = "A0FM",
        isforce = false,
        efunc = function()
          gunskilltrg({
            unit = u.handle,
            skill = S2ID("A1N1")
          })
          if not u:hasdata("红城的律令-技能注册") then
            u:setdata("红城的律令-技能注册")
            
            local function skill(args)
              if args.skill == S2ID("A0FM") then
                u:settimedata("红城的律令-反击效果", 0.15)
                ac.wait(149, function()
                  if u:hasdata("红城的律令-反击效果") then
                    u:losshp(u, 0, 50)
                    u:buffset(u.handle, 2, "暂停")
                    u:sendmessage("|cFFCC0000失败|r")
                  end
                end)
                u:effectadd("Abilities\\Spells\\Human\\ControlMagic\\ControlMagicTarget.mdl", "overhead", 0.15)
              end
              if args.skill == S2ID("A0FN") then
                if u:getdata("红城的律令-处刑值") > 0 then
                else
                  u:setskillcd(args.skill, 0.01)
                  u:sendmessage("|cFFCC0000处刑值不足|r")
                  return
                end
                local tilixh = 2
                if u:lossstamina(tilixh) then
                else
                  u:setskillcd(args.skill, 0.01)
                  u:sendmessage("|cFFFF3300体力值不足|r")
                  return
                end
                if GetRandom100(25) then
                  u:playsound(hongxin11)
                end
                u:changedata("红城的律令-处刑值", -1)
                u:sendmessage("|cFFCC0000处刑值：" .. u:getdata("红城的律令-处刑值") .. "|r")
                u:playseensound(Wj_Yx1)
                u:playseensound(Wj_Yx3)
                local x, y = u:getxy()
                local x2 = args.x
                local y2 = args.y
                local angle = AngleXY(x, y, x2, y2)
                local x3, y3 = PolarXY(x, y, 1250, angle)
                local mzg = CreateGroupLua()
                Effectcreate("176_a.mdl", x3, y3, 7, 3, 100, angle)
                local txsh = 8000 + u:getdata("显示-固定伤害") + u:getdata("魔力值")
                ac.wait(250, function()
                  u:buffset(u.handle, 0.12, "绝对闪避")
                  unitmove({
                    unit = u.handle,
                    time = 0.12,
                    distance = 2500,
                    angle = angle,
                    isfly = true,
                    loops = {
                      {
                        looptime = 0.01,
                        func = function(dx, dy)
                          for _, xq in ac.selector():in_rangexy(dx, dy, 375):is_enemy(u.handle):isnotingroup(mzg):ipairs() do
                            xq = getunit(xq)
                            xq:groupadd(mzg)
                            DamageUnit({
                              bj = "红城的律令",
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
                            xq:buffset(u.handle, 1, "僵直")
                            unitmove({
                              unit = xq.handle,
                              time = 0.1,
                              distance = 100,
                              angle = angle
                            })
                          end
                        end
                      }
                    }
                  })
                end)
              end
            end
            
            u:addtrgevent("单位-发动技能", function(args)
              skill(args)
            end)
          end
        end
      })
    end
    if wplx == Weapons["星辰短剑"] and not u:hasdata("武器判定-星辰短剑") then
      u:setdata("武器判定-星辰短剑")
      u:setdata("武器判定-特殊近战武器")
      u:setdata("星辰短剑-射击模式", 1)
      ARskillreplace({
        unit = u.handle,
        level = -1,
        skill_A = "A099",
        skill_R = "A09A",
        isforce = false,
        efunc = function()
          gunskilltrg({
            unit = u.handle,
            skill = S2ID("A1N1")
          })
          if not u:hasdata("星辰短剑-技能注册") then
            u:setdata("星辰短剑-技能注册")
            
            function fszd1(txsh, angle, x, y)
              unifycreate({
                owner = u.handle,
                model = "Tevi_02.mdl",
                modelname = "星辰短剑-弹幕",
                modelsize = 1,
                height = 90,
                damage = txsh,
                damagetype = 1,
                x = x,
                y = y,
                range = 3000,
                speed = 4000,
                volume = 90,
                angle = angle,
                angleoffset = 0,
                attenua = 1,
                attenuacount = 3,
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
                  u:setdata("属性伤害", "雷")
                end,
                hitafterfunc = function(mj, xq, damage2)
                end,
                endfunc = function(mj)
                end
              })
            end
            
            function fszd2(txsh, angle, x, y, frequency)
              local cs = 0
              local amplitude = 45
              unifycreate({
                owner = u.handle,
                model = "Tevi_02.mdl",
                modelname = "星辰短剑-弹幕",
                modelsize = 1,
                height = 90,
                damage = txsh,
                damagetype = 1,
                x = x,
                y = y,
                range = 3000,
                speed = 1800,
                volume = 90,
                angle = angle,
                angleoffset = 0,
                attenua = 1,
                attenuacount = 3,
                life = 10,
                isbullet = false,
                isvest = false,
                isignorearmor = false,
                startfunc = function(mj)
                end,
                loopfunc = function(mj)
                  cs = cs + frequency
                  local sinAngle = amplitude * math.sin(cs)
                  mj:setface(angle + sinAngle)
                end,
                hitfunc = function(mj, damage)
                  return damage
                end,
                hitbeforefunc = function(mj, xq, damage2)
                  u:setdata("属性伤害", "雷")
                end,
                hitafterfunc = function(mj, xq, damage2)
                end,
                endfunc = function(mj)
                end
              })
            end
            
            function fszd3(txsh, angle, x, y)
              unifycreate({
                owner = u.handle,
                model = "Tevi_02.mdl",
                modelname = "星辰短剑-弹幕",
                modelsize = 1,
                height = 90,
                damage = txsh,
                damagetype = 1,
                x = x,
                y = y,
                range = 3000,
                speed = 4000,
                volume = 90,
                angle = angle,
                angleoffset = 0,
                attenua = 1,
                attenuacount = 1,
                life = 10,
                isbullet = false,
                isvest = false,
                isignorearmor = false,
                startfunc = function(mj)
                end,
                loopfunc = function(mj)
                  if mj:hasdata("弹幕-追踪单位") then
                    local dangle = AngleBetweenUnits(mj.handle, mj:getdata("弹幕-追踪单位"))
                    local angleDelta = dangle - mj:getface()
                    if 180.0 <= angleDelta then
                      angleDelta = angleDelta - 360.0
                    elseif angleDelta <= -180.0 then
                      angleDelta = angleDelta + 360.0
                    end
                    if 60.0 < angleDelta then
                      angleDelta = 60.0
                    elseif angleDelta < -60.0 then
                      angleDelta = -60.0
                    end
                    mj:setface(mj:getface() + angleDelta)
                  else
                    mj:setdata("弹幕-穿透次数", 1)
                    local x, y = mj:getxy()
                    for _, xq in ac.selector():in_rangexy(x, y, 500):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      mj:setdata("弹幕-追踪单位", xq.handle)
                      break
                    end
                  end
                end,
                hitfunc = function(mj, damage)
                  return damage
                end,
                hitbeforefunc = function(mj, xq, damage2)
                  u:setdata("属性伤害", "雷")
                end,
                hitafterfunc = function(mj, xq, damage2)
                end,
                endfunc = function(mj)
                end
              })
            end
            
            function fszd4(txsh, angle, x, y)
              unifycreate({
                owner = u.handle,
                model = "Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl",
                modelname = "星辰短剑-弹幕",
                modelsize = 2,
                height = 90,
                damage = 0,
                damagetype = 1,
                x = x,
                y = y,
                range = 2500,
                speed = 1500,
                volume = 225,
                angle = angle,
                angleoffset = 0,
                attenua = 1,
                attenuacount = 1,
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
                end,
                hitafterfunc = function(mj, xq, damage2)
                end,
                endfunc = function(mj)
                  local x, y = mj:getxy()
                  Effectcreate("war3mapImported\\ThunderclapCaster.mdl", x, y, 0, 2)
                  for _, xq in ac.selector():in_rangexy(x, y, 600):is_enemy(u.handle):ipairs() do
                    xq = getunit(xq)
                    DamageUnit({
                      bj = "星辰短剑(弹幕)",
                      unit = xq.handle,
                      source = u.handle,
                      damage = txsh,
                      level = 1,
                      type = "魔力",
                      isvest = false,
                      isattack = false,
                      isnoarmor = false,
                      element = "雷"
                    })
                  end
                end
              })
            end
            
            local function skill(args)
              if args.skill == S2ID("A099") then
                local count = u:getdata("星辰短剑-射击模式")
                local x, y = u:getxy()
                local x2 = args.x or 0
                local y2 = args.y or 0
                local angle = AngleXY(x, y, x2, y2)
                local skill = args.skill
                local cd = 0.5
                local txsh = 10000 + 500 * u:getlevel()
                if count == 1 or u:hasdata("Tevi-核心展开") then
                  u:playsound(Sound_Tevi_Danmu)
                  fszd1(txsh, angle, x, y)
                  ac.timer(200, 2, function()
                    u:playsound(Sound_Tevi_Danmu)
                    fszd1(txsh, angle, x, y)
                  end)
                  cd = 0.6
                end
                if count == 2 or u:hasdata("Tevi-核心展开") then
                  u:playsound(Sound_Tevi_Danmu)
                  fszd2(txsh, angle, x, y, 5)
                  fszd2(txsh, angle, x, y, -5)
                  ac.timer(200, 2, function()
                    u:playsound(Sound_Tevi_Danmu)
                    fszd2(txsh, angle, x, y, 5)
                    fszd2(txsh, angle, x, y, -5)
                  end)
                  cd = 0.6
                end
                if count == 3 or u:hasdata("Tevi-核心展开") then
                  u:playsound(Sound_Tevi_Danmu)
                  fszd4(txsh, angle, x, y)
                  cd = 0.9
                end
                if count == 4 or u:hasdata("Tevi-核心展开") then
                  u:playsound(Sound_Tevi_Danmu)
                  angle = angle - 30
                  for i = 1, 5 do
                    angle = angle + 10
                    fszd1(txsh, angle, x, y)
                  end
                end
                if count == 5 or u:hasdata("Tevi-核心展开") then
                  u:playsound(Sound_Tevi_Danmu)
                  fszd3(txsh, angle, x, y)
                  ac.timer(200, 2, function()
                    u:playsound(Sound_Tevi_Danmu)
                    fszd3(txsh, angle, x, y)
                  end)
                  cd = 0.6
                end
                u:setskillcd(skill, cd)
              end
              if args.skill == S2ID("A09A") then
                if GetRandom100(50) then
                  u:playsound(Sound_Tevi_Switch1)
                else
                  u:playsound(Sound_Tevi_Swtich2)
                end
                u:changedata("星辰短剑-射击模式", 1)
                if u:getdata("星辰短剑-射击模式") >= 6 then
                  u:setdata("星辰短剑-射击模式", 1)
                end
                local count = u:getdata("星辰短剑-射击模式")
                u:sendmessage("|cFF6D7CCD射击模式-" .. count .. "|r")
              end
            end
            
            u:addtrgevent("单位-发动技能", function(args)
              skill(args)
            end)
          end
          local cs = 0
          ac.loop(250, function(t)
            if u:isalive() then
              cs = cs + 1
            end
            local max = 3
            local count = u:getdata("星辰短剑-射击模式")
            if count == 2 or count == 5 then
              max = 6
            end
            if count == 3 then
              max = 9
            end
            if max <= cs then
              cs = 0
              u:mousexyflash()
              ac.wait(300, function()
                local x, y
                if count <= 3 then
                  x, y = GetEffectXY(u:getdata("Tevi-红浮游"))
                else
                  x, y = GetEffectXY(u:getdata("Tevi-蓝浮游"))
                end
                local angle = u:getface()
                local x2, y2 = u:getmousexy()
                angle = AngleXY(x, y, x2, y2)
                local txsh = 5000 + 250 * u:getlevel()
                if count == 1 then
                  fszd1(txsh, angle, x, y)
                  ac.timer(200, 2, function()
                    fszd1(txsh, angle, x, y)
                  end)
                end
                if count == 2 then
                  fszd2(txsh, angle, x, y, 5)
                  fszd2(txsh, angle, x, y, -5)
                  ac.timer(200, 2, function()
                    fszd2(txsh, angle, x, y, 5)
                    fszd2(txsh, angle, x, y, -5)
                  end)
                end
                if count == 3 then
                  fszd4(txsh, angle, x, y)
                end
                if count == 4 then
                  angle = angle - 30
                  for i = 1, 5 do
                    angle = angle + 10
                    fszd1(txsh, angle, x, y)
                  end
                end
                if count == 5 then
                  fszd3(txsh, angle, x, y)
                  ac.timer(200, 2, function()
                    fszd3(txsh, angle, x, y)
                  end)
                end
              end)
            end
            if not u:hasdata("武器判定-星辰短剑") then
              t:remove()
            end
          end)
        end
      })
    end
    if wplx == Weapons["高频村雨刀"] and not u:hasdata("武器判定-高频村雨刀") then
      u:setdata("武器判定-高频村雨刀")
      u:setdata("武器判定-特殊近战武器")
      ARskillreplace({
        unit = u.handle,
        level = -1,
        skill_A = "A03G",
        skill_R = "A03K",
        isforce = false,
        efunc = function()
          gunskilltrg({
            unit = u.handle,
            skill = S2ID("A1N1")
          })
          if not u:hasdata("高频村雨刀-技能注册") then
            u:setdata("高频村雨刀-技能注册")
            u:setdata("高频村雨刀-激流次数", 2)
            
            local function skill(args)
              if args.skill == S2ID("A03G") then
                u:settimedata("高频村雨刀-格挡效果", 0.5)
                u:effectadd("Abilities\\Spells\\Human\\ControlMagic\\ControlMagicTarget.mdl", "overhead", 0.5)
              end
              if args.skill == S2ID("A03K") then
                u:playseensound(Wj_Yx1)
                u:playseensound(Wj_Yx3)
                local x, y = u:getxy()
                local x2 = args.x
                local y2 = args.y
                local angle = AngleXY(x, y, x2, y2)
                local x3, y3 = PolarXY(x, y, 1250, angle)
                local mzg = CreateGroupLua()
                Effectcreate("war3mapImported\\176.mdl", x3, y3, 7, 3, 100, angle)
                local txsh = 10000 + 400 * u:getlevel()
                if u:hasdata("变异判定-塞缪尔") then
                  txsh = txsh * 2
                  u:buffset(u.handle, 0.3, "绝对闪避")
                end
                local xz = WeaponCount_Katana[sy]
                txsh = txsh * xz
                unitmove({
                  unit = u.handle,
                  time = 0.3,
                  distance = 2500,
                  angle = angle,
                  isfly = true,
                  loops = {
                    {
                      looptime = 0.01,
                      func = function(dx, dy)
                        for _, xq in ac.selector():in_rangexy(dx, dy, 375):is_enemy(u.handle):isnotingroup(mzg):ipairs() do
                          xq = getunit(xq)
                          xq:groupadd(mzg)
                          DamageUnit({
                            bj = "高频村雨刀(激流)",
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
                          xq:buffset(u.handle, 1, "僵直")
                          unitmove({
                            unit = xq.handle,
                            time = 0.1,
                            distance = 100,
                            angle = angle
                          })
                        end
                      end
                    }
                  },
                  endfunc = function(dx, dy)
                    if u:getdata("高频村雨刀-激流次数") > 0 then
                      u:setskillcd("A03K", 0)
                      u:changedata("高频村雨刀-激流次数", -1)
                      if u:getdata("高频村雨刀-激流次数") == 0 then
                        local time = 17
                        if u:hasdata("变异判定-塞缪尔") then
                          time = 14
                        end
                        ac.wait(time * 1000, function()
                          u:changedata("高频村雨刀-激流次数", 2)
                        end)
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
        end
      })
    end
    if (wplx == Weapons["破碎的刀刃"] or wplx == Weapons["妖刀心渡"]) and not u:hasdata("武器判定-破碎的刀刃") then
      u:setdata("武器判定-破碎的刀刃")
      if wplx == Weapons["妖刀心渡"] then
        u:setdata("武器判定-妖刀心渡")
        ChangeValue(DamageSplit_CountJzHit, sy, 2)
        ChangeValue(DamageSplit_CountJzMax, sy, 0.6)
      end
      if not u:hasdata("破碎的刀刃-触发注册") then
        u:setdata("破碎的刀刃-触发注册")
        u:addstexiao("破碎的刀刃", "杀敌效果", function(args)
          if u:hasdata("武器判定-破碎的刀刃") then
            local tg = args.tg
            u:changedata("忍野忍-破碎刀刃杀敌", 1)
            if not tg:isnormal() then
              u:addallstats(10)
              u:changedata("忍野忍-破碎刀刃杀敌", 9)
            end
          end
        end)
        u:addstexiao("破碎的刀刃", "直接伤害特效", function(args)
          local u = args.u
          local tg = args.tg
          local info = args.damageinfo
          if u:hasdata("武器判定-破碎的刀刃") then
            tg:banrelive()
          end
        end)
      end
    end
    if wplx == Weapons["青色怒火"] and not u:hasdata("武器判定-青色怒火") then
      u:setdata("武器判定-青色怒火")
      u:setdata("武器判定-特殊近战武器")
      ChangeValue(DamageSplit_CountJzMax, sy, 0.5)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      u:addstexiao("青色怒火", "杀敌效果", function(args)
        if u:hasdata("武器判定-青色怒火") and u:getdata("青色怒火-绝影层数") < 3 then
          u:changetimedata("青色怒火-绝影层数", 1, 60)
          ChangeTimeValue(Correction_Jzsh, sy, 0.04000000000000001, 60)
          ChangeTimeValue(Damage_ElementRes_All, sy, 20, 60)
        end
      end)
      u:addskill("A0AL")
      u:banskill("A0AL")
      if not u:hasdata("青色怒火-技能注册") then
        u:setdata("青色怒火-技能注册")
        
        local function skill(args)
          if args.skill == S2ID("A0AK") then
            u:buffset(u.handle, 0.2, "绝对闪避")
            u:playsound(bac261)
            u:playsound(bac174)
            local x, y = u:getxy()
            local x2 = args.x
            local y2 = args.y
            local angle = AngleXY(x, y, x2, y2)
            local x3, y3 = PolarXY(x, y, 200, angle)
            local mzg = CreateGroupLua()
            Effectcreate("Texiao_Amiya_08.mdx", x, y, 0, 1, 0, angle, 0, 0, 2)
            Effectcreate("war3mapImported\\bbb.mdx", x, y, 0, 1)
            local txsh = 10000 + 100 * u:getallattri()
            unitmove({
              unit = u.handle,
              time = 0.2,
              distance = 500,
              angle = u:getface(),
              isfly = true,
              loops = {},
              endfunc = function(dx, dy)
                if u:getdata("青色怒火-使用次数") > 0 then
                  u:setskillcd("A0AL", 0)
                  u:changedata("青色怒火-使用次数", -1)
                  if u:getdata("青色怒火-使用次数") == 0 then
                    ac.wait(5000, function()
                      u:changedata("青色怒火-使用次数", 2)
                    end)
                  end
                end
              end
            })
            unifycreate({
              owner = u.handle,
              model = "Texiao_Amiya_01.mdx",
              modelname = "剑气",
              modelsize = 1,
              height = 90,
              damage = txsh,
              damagetype = 1,
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
                u:setdata("近战")
              end,
              hitafterfunc = function(mj, xq, damage2)
                unitmove({
                  unit = xq.handle,
                  time = 0.1,
                  distance = 100,
                  angle = angle
                })
                xq:buffset(u.handle, 3, "破坏-伤害免疫")
              end,
              endfunc = function(mj)
              end
            })
          end
          if args.skill == S2ID("A0AL") then
            u:buffset(u.handle, 0.2, "绝对闪避")
            u:playsound(bac395)
            local x, y = u:getxy()
            local x2 = args.x
            local y2 = args.y
            local angle = AngleXY(x, y, x2, y2)
            local x3, y3 = PolarXY(x, y, 400, angle)
            local mzg = CreateGroupLua()
            Effectcreate("war3mapImported\\176.mdl", x3, y3, 0, 1, 100, angle)
            Effectcreate("Texiao_Amiya_08.mdx", x, y, 0, 1, 0, angle, 0, 0, 2)
            Effectcreate("war3mapImported\\bbb.mdx", x, y, 0, 1)
            local txsh = 2500 + 25 * u:getallattri()
            local tg
            unitmove({
              unit = u.handle,
              time = 0.2,
              distance = 1600,
              angle = angle,
              isfly = true,
              loops = {
                {
                  looptime = 0.01,
                  func = function(dx, dy, args)
                    for _, xq in ac.selector():in_rangexy(dx, dy, 125):is_enemy(u.handle):isnotingroup(mzg):ipairs() do
                      xq = getunit(xq)
                      tg = xq
                      args.stop = true
                      break
                    end
                  end
                }
              },
              endfunc = function(dx, dy)
                if tg then
                  local yxz = {
                    bac358,
                    bac359,
                    bac360,
                    bac361
                  }
                  local cs = 0
                  local x2, y2 = tg:getxy()
                  local x3, y3 = PolarXY(x2, y2, 150, angle)
                  u:setxy(x3, y3)
                  u:setface(angle)
                  IssueImmediateOrder(u.handle, "stop")
                  ac.loop(50, function(timer)
                    tg:playsound(yxz[GetRandomInt(1, 4)])
                    local x2, y2 = tg:getxy()
                    EffectcreateArgs({
                      effect = "Texiao_Amiya_04.mdx",
                      x = x2,
                      y = y2,
                      height = GetRandomReal(100, 200),
                      zxz = GetRandomAngle(),
                      xxz = GetRandomAngle(),
                      yxz = GetRandomAngle(),
                      animespeed = 2
                    })
                    EffectcreateArgs({
                      effect = "Texiao_Amiya_07.mdx",
                      x = x2,
                      y = y2,
                      time = 0.5,
                      height = GetRandomReal(100, 200),
                      zxz = GetRandomAngle(),
                      xxz = GetRandomAngle(),
                      yxz = GetRandomAngle(),
                      animespeed = 1
                    })
                    cs = cs + 1
                    if cs == 10 then
                      Effectcreate("Texiao_Amiya_05.mdl", x2, y2, 0, 1)
                      Effectcreate("Texiao_Amiya_06.mdl", x2, y2, 0, 1)
                      Effectcreate("war3mapImported\\Texiao_Xuebao.mdx", x2, y2, 0, 1)
                      Effectcreate("war3mapImported\\fuzzystomp.mdx", x2, y2, 0, 0.5)
                      for _, xq in ac.selector():in_rangexy(x2, y2, 375):is_enemy(u.handle):ipairs() do
                        xq = getunit(xq)
                        xq:buffset(u.handle, 1.5, "僵直")
                        DamageUnit({
                          bj = "青色怒火(绝影)",
                          unit = xq.handle,
                          source = u.handle,
                          damage = txsh * 8,
                          level = 1,
                          type = "物理",
                          isvest = false,
                          isattack = true,
                          isnoarmor = false,
                          element = "无",
                          extradata = {"近战"}
                        })
                      end
                      timer:remove()
                    else
                      tg:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
                      tg:buffset(u.handle, 0.5, "暂停")
                      DamageUnit({
                        bj = "青色怒火(绝影)",
                        unit = tg.handle,
                        source = u.handle,
                        damage = txsh,
                        level = 1,
                        type = "物理",
                        isvest = true,
                        isattack = true,
                        isnoarmor = false,
                        element = "无",
                        extradata = {"近战"}
                      })
                    end
                  end)
                end
              end
            })
          end
        end
        
        u:addtrgevent("单位-发动技能", function(args)
          skill(args)
        end)
      end
    end
    if wplx == Weapons["史莱姆剑"] then
      u:setdata("武器判定-史莱姆剑")
      u:addskill("S0E1")
      u:banskill("S0E0", false)
      u:banskill("S0E1")
      if not u:hasdata("史莱姆剑-效果注册") then
        u:setdata("史莱姆剑-效果注册")
        u:addstexiao("史莱姆剑", "直接伤害特效", function(args)
          local info = args.damageinfo
          if u:hasdata("武器判定-史莱姆剑") and not u:hasdata("史莱姆剑-生命损耗冷却") then
            u:settimedata("史莱姆剑-生命损耗冷却", 0.15)
            LossHpUnit({
              u = u,
              tg = args.tg,
              damage = info.yssh * 0.4,
              perhp = 0,
              maxhp = 0,
              bj = "[生命损耗]史莱姆剑"
            })
          end
        end)
        u:addstexiao("史莱姆剑", "杀敌效果", function()
          if u:hasdata("武器判定-史莱姆剑") then
            u:changedata("魔力值", u:getdata("暗影计数"))
          end
        end)
        u:addtrgevent("单位-发动技能", function(args)
          if args.skill == S2ID("S0E1") then
            u:changedata("史莱姆剑-切换序号", 1)
            local token = u:getdata("史莱姆剑-切换序号")
            u:banskill("S0E1")
            local x, y = u:getxy()
            local target_x = args.x or x
            local target_y = args.y or y
            local angle = AngleXY(x, y, target_x, target_y)
            local distance = DistanceXY(x, y, target_x, target_y)
            if 2000 < distance then
              distance = 2000
            end
            local tg
            u:buffset(u.handle, 0.25, "绝对闪避")
            u:setface(angle)
            u:playsound(bac395)
            local x3, y3 = PolarXY(x, y, 400, angle)
            Effectcreate("war3mapImported\\bbb.mdx", x, y, 0, 1)
            unitmove({
              unit = u.handle,
              time = 0.25 * distance / 2000,
              distance = distance,
              angle = angle,
              isfly = true,
              loops = {
                {
                  looptime = 0.01,
                  func = function(dx, dy, move)
                    for _, xq in ac.selector():in_rangexy(dx, dy, 125):is_enemy(u.handle):ipairs() do
                      tg = getunit(xq)
                      move.stop = true
                      break
                    end
                  end
                }
              },
              endfunc = function()
                local function restore()
                  if u:hasdata("武器判定-史莱姆剑") and token == u:getdata("史莱姆剑-切换序号") then
                    u:banskill("S0E1")
                    
                    u:banskill("S0E0", false)
                    u:setskillcd("S0E0", 1.5)
                  end
                end
                
                if not tg then
                  restore()
                  return
                end
                local yxz = {
                  bac358,
                  bac359,
                  bac360,
                  bac361
                }
                local txsh = (u:getallattri() * 188 + u:getdata("暗影计数") * u:getdata("魔力值")) / 5
                if u:hasdata("暗影-史莱姆剑一阶") then
                  txsh = txsh * (1 + u:getdata("暗影计数") * 0.1)
                end
                IssueImmediateOrder(u.handle, "stop")
                local x2, y2 = tg:getxy()
                EffectcreateArgs({
                  effect = "9c2fffeb96f775ce.mdx",
                  x = x2,
                  y = y2,
                  time = 1,
                  size = 1,
                  animespeed = 2
                })
                for _, xq in ac.selector():in_rangexy(x2, y2, 450):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  xq:buffset(u.handle, 0.8, "眩晕")
                end
                local count = 0
                ac.loop(100, function(timer)
                  if not u:hasdata("武器判定-史莱姆剑") or not tg:isalive() then
                    timer:remove()
                    restore()
                    return
                  end
                  count = count + 1
                  local x2, y2 = tg:getxy()
                  tg:playsound(yxz[GetRandomInt(1, 4)])
                  EffectcreateArgs({
                    effect = "036ec33cf53b1b2e.mdx",
                    x = x2,
                    y = y2,
                    size = 5,
                    height = GetRandomReal(100, 300),
                    zxz = GetRandomAngle(),
                    xxz = GetRandomAngle(),
                    yxz = GetRandomAngle(),
                    animespeed = 1
                  })
                  for _, xq in ac.selector():in_rangexy(x2, y2, 375):is_enemy(u.handle):ipairs() do
                    xq = getunit(xq)
                    DamageUnit({
                      bj = "史莱姆剑(E2)",
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
                  end
                  if 5 <= count then
                    timer:remove()
                    restore()
                  end
                end)
              end
            })
          end
        end)
      end
    end
    if wplx == Weapons["无影剑"] and not u:hasdata("武器判定-无影剑") then
      u:setdata("武器判定-无影剑")
      if not u:hasdata("无影剑-触发注册") then
        u:setdata("无影剑-触发注册")
        local mj = getunit(Ewl_Moniskill[sy])
        mj:addskill("A017")
        mj:addskill("A019")
        mj:addtrgevent("单位-发动技能", function(args)
          if args.skill == S2ID("A017") and u:hasdata("武器判定-无影剑") then
            local x = args.x or 0
            local y = args.y or 0
            u:setdata("无影剑-X", x)
            u:setdata("无影剑-Y", y)
            if not u:hasdata("无影剑-释放中") and not u:hasdata("无影剑-结束标记") then
              u:setdata("无影剑-释放中")
              local cs = 0
              ac.loop(100, function(t)
                if not (u:isalive() and not u:hasdata("无影剑-结束标记") and u:hasdata("无影剑-释放中")) or not u:hasdata("武器判定-无影剑") then
                  u:deldata("无影剑-释放中")
                  u:settimedata("无影剑-禁用结束", 0.11)
                  ac.wait(100, function()
                    u:deldata("无影剑-结束标记")
                  end)
                  t:remove()
                else
                  cs = cs + 1
                  if cs == 5 then
                    cs = 0
                    if u:islocal() then
                      local mj = getunit(Ewl_Moniskill[sy])
                      ClearSelection()
                      SelectUnit(mj.handle, true)
                      local ddx, ddy = message.mouse()
                      message.order_point(YDWEAbilityId2OrderId("A017"), ddx, ddy)
                      ClearSelection()
                      SelectUnit(unit, true)
                    end
                    local x, y = u:getxy()
                    local x2 = u:getdata("无影剑-X")
                    local y2 = u:getdata("无影剑-Y")
                    local angle = AngleXY(x, y, x2, y2)
                    local dis = DistanceXY(x, y, x2, y2)
                    if 1000 <= dis then
                      x2, y2 = PolarXY(x, y, 1000, angle)
                    end
                    Effectcreate("war3mapImported\\[TX] (1365).mdl", x2, y2, 0, 1.5, 0, GetRandomAngle())
                    local txsh = 5000 + 200 * u:getlevel()
                    for _, xq in ac.selector():in_rangexy(x2, y2, 325):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      DamageUnit({
                        bj = "无影剑",
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
                    end
                  end
                end
              end)
            end
          end
          if args.skill == S2ID("A019") and not u:hasdata("无影剑-禁用结束") then
            u:setdata("无影剑-结束标记")
          end
        end)
      end
    end
    if wplx == Weapons["童子切安纲"] then
      ChangeValue(Correction_Cbxs, sy, 0.12)
      ChangeValue(DamageSystem_BaoshangBeilv, sy, 0.25)
    end
    if wplx == Weapons["七夜"] and not u:hasdata("变异判定-真夏的白雪") and u.type ~= HeroType["志贵"] then
      u:setdata("杀戮值", 0)
      local jl = 0
      ac.loop(1000, function(t)
        if u:hasdata("变异判定-七夜志贵") or u:hasdata("变异判定-噩梦志贵") then
          if not u:ishasskill("A0CG") then
            u:changedata("杀戮值", 1)
            if GetRandom100(0.005 * u:getdata("杀戮值")) then
              u:delskill("A0WG")
              u:addskill("A0CG")
            end
          else
            u:setdata("杀戮值", 0)
          end
        end
        if u:hasdata("变异判定-真夏的白雪") or Hero_Equip_WeaponType[sy] ~= Weapons["七夜"] then
          u:deldata("杀戮值")
          u:delskill("A0CG")
          t:remove()
        end
      end)
    end
    if wplx == Weapons["潮汐"] and not u:hasdata("潮汐之盾") then
      u:setdata("潮汐之盾")
      u:setdata("潮汐之盾护盾值", 0)
      u:setdata("潮汐之盾再生时间", 0)
      local hd = 0
      ac.loop(250, function(t)
        local max = 0.5 + 0.1 * u:getstate("水变异")
        hd = (10 + 2.5 * u:getstate("水变异")) * 0.25
        if u:ishasitem(Weapons["洋流"]) then
          hd = hd * 2.5
        end
        if u:getdata("潮汐之盾再生时间") <= 0 then
          u:setdata("潮汐之盾再生时间", 0)
          u:changedata("潮汐之盾护盾值", hd)
          Hdzflash(u)
        else
          u:changedata("潮汐之盾再生时间", -0.25)
        end
        if u:getdata("潮汐之盾护盾值") >= max * u:getmaxhp() then
          u:setdata("潮汐之盾护盾值", max * u:getmaxhp())
          Hdzflash(u)
        end
        if Hero_Equip_WeaponType[sy] ~= Weapons["潮汐"] then
          u:deldata("潮汐之盾")
          u:deldata("潮汐之盾护盾值")
          Hdzflash(u)
          t:remove()
        end
      end)
    end
    if wplx == Weapons["拟态"] and not u:hasdata("武器判定-拟态") then
      local str = "拟态"
      u:setdata("武器判定-拟态")
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      ChangeValue(DamageSplit_CountJzMax, sy, 0.25)
      u:addstexiao(str, "杀敌效果", function(args)
        if u:hasdata("武器判定-拟态") then
          u:changedata("拟态-杀敌数量", 1)
        end
      end)
      u:addstexiao(str, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("武器判定-拟态") then
          info.pk_genxing = true
          info.pk_tiebi = true
        end
      end)
      if not u:hasdata("拟态-函数注册") then
        u:setdata("拟态-函数注册")
        u:setdata("拟态-血雾计数", 0)
        if u:islocal() then
          BuffUI.apply({
            id = "拟态-血雾计数",
            duration = 99999
          })
        end
        
        local function bbb(add)
          if not u:hasdata("尸横遍野冷却") then
            u:changedata("拟态-血雾计数", add)
          end
        end
        
        local function aaa(tg, add)
          tg:changedata("拟态-伤口层数", add)
          if tg:getdata("拟态-伤口层数") >= 20 then
            tg:setdata("拟态-伤口层数", 20)
          end
          if not u:hasdata("血雾获取间隔") then
            u:settimedata("血雾获取间隔", 0.5)
            u:getdata("拟态-血雾计数获取")(1)
          end
        end
        
        u:setdata("拟态-伤口施加", aaa)
        u:setdata("拟态-血雾计数获取", bbb)
        if u:ishasskill(SKILL_TESHUYINGXIONG) and u.type ~= HeroType["C呆"] and u.type ~= HeroType["莲华"] then
          u:addstexiao(str .. "2", "近战伤害效果", function(args)
            local tg = args.tg
            local u = args.u
            local info = args.damageinfo
            if u:hasdata("武器判定-拟态") and u:getdata("拟态-血雾计数") >= 20 and not u:hasdata("尸横遍野冷却") then
              u:settimedata("尸横遍野冷却", 15)
              u:setdata("拟态-血雾计数", 0)
              args.shadd = args.shadd + 1
            end
          end)
          u:addstexiao(str .. "2", "近战伤害特效", function(args)
            local tg = args.tg
            local u = args.u
            local info = args.damageinfo
            if u:hasdata("武器判定-拟态") and not u:hasdata(str .. "-特效2冷却") then
              u:settimedata(str .. "-特效2冷却", 0.5)
              local txsh = 15000 + 10 * tg:getdata("拟态-伤口层数") * u:getallattri()
              DamageUnit({
                bj = "拟态(伤口)",
                unit = tg.handle,
                source = u.handle,
                damage = txsh,
                type = "反物质",
                isvest = true
              })
              if tg:getdata("拟态-伤口层数") >= 10 and not u:hasdata(str .. "-特效3冷却") then
                u:settimedata(str .. "-特效3冷却", 1)
                LossHpUnit({
                  u = u,
                  tg = tg,
                  damage = 0,
                  perhp = 0,
                  maxhp = 0.1,
                  bj = "拟态[生命损耗]"
                })
              end
            end
          end)
          u:addstexiao(str, "伤害显示后效果", function(args)
            local u = args.u
            local tg = args.tg
            local info = args.damageinfo
            if u:hasdata("武器判定-拟态") and tg:isboss() and not u:hasdata(str .. "-特效5冷却") and info.damage >= 0.01 * tg:getmaxhp() then
              u:settimedata(str .. "-特效5冷却", 1)
              u:getdata("拟态-血雾计数获取")(5)
            end
          end)
        end
      end
      u:addstexiao(str, "近战伤害效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("武器判定-拟态") and not u:hasdata(str .. "-特效冷却") and u:getluckrandom(20 * info.txgl) then
          u:settimedata(str .. "-特效冷却", 0.5)
          u:getdata("拟态-伤口施加")(tg, 1)
        end
      end)
      local jz = 0
      local jc = 0
      ac.loop(1000, function(ti)
        u:changedata("近战机体-基础伤害提升", -jc)
        ChangeValue(Correction_Jzsh, sy, 0.1 * -jz)
        local count = u:getdata("拟态-杀敌数量")
        jz = 0.001 * count
        jc = 15 * count
        u:changedata("近战机体-基础伤害提升", jc)
        ChangeValue(Correction_Jzsh, sy, 0.1 * jz)
        if u:getdata("拟态-血雾计数") >= 20 then
          u:setskilldatastring("S0D7", "图标", "Weapon_Nitai2.tga")
        else
          u:setskilldatastring("S0D7", "图标", "Weapon_Nitai.tga")
        end
        if Hero_Equip_WeaponType[sy] ~= Weapons["拟态"] then
          u:changedata("近战机体-基础伤害提升", -jc)
          ChangeValue(Correction_Jzsh, sy, 0.1 * -jz)
          ChangeValue(DamageSplit_CountJzHit, sy, -1)
          ChangeValue(DamageSplit_CountJzMax, sy, -0.25)
          u:deldata("武器判定-拟态")
          ti:remove()
        end
      end)
    end
    if wplx == Weapons["楔丸"] and not u:hasdata("武器判定-楔丸") then
      u:setdata("武器判定-楔丸")
      u:addstexiao("楔丸", "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("武器判定-楔丸") then
          if u:hasbuff("绝对闪避") then
            info.endup = info.endup + 0.25
          end
          if u:ispozhao() then
            info.endup4 = info.endup4 + 0.125
          end
        end
      end)
      if not u:ishasskill(SKILL_TESHUYINGXIONG) or u.type == HeroType["C呆"] then
        u:setdata("楔丸-格挡")
        Fskillban(u)
        u:addskill("A1M9")
      end
      ac.loop(10, function(ti)
        u:changedata("楔丸-格挡判定时间", -0.01)
        local t = u:getdata("楔丸-格挡判定时间")
        if not u:isalive() and 0 <= t then
          u:setdata("楔丸-格挡判定时间", 0)
        else
          u:setdata("楔丸-格挡判定时间", t)
        end
        if Hero_Equip_WeaponType[sy] ~= Weapons["楔丸"] then
          if not u:ishasskill(SKILL_TESHUYINGXIONG) or u.type == HeroType["C呆"] then
            Fskillban(u)
            if u:hasdata("系统-F技能") then
              u:addskill(u:getdata("系统-F技能"))
            else
              u:addskill("A08M")
            end
          end
          u:deldata("武器判定-楔丸")
          u:deldata("楔丸-格挡")
          u:deldata("楔丸-格挡判定时间")
          ti:remove()
        end
      end)
    end
    if wplx == Weapons["光之剑超新星"] and not u:hasdata("武器判定-光之剑超新星") then
      u:addstexiao("光之剑超新星", "枪械装弹时效果", function(args)
        if u:hasdata("枪械判定-光之剑超新星") then
          local x, y = u:getxy()
          u:effectadd("war3mapImported\\evilwave_blue.mdx", "origin")
          Effectcreate("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl", x, y, 0, 2)
          local txsh = 1000 * u:getlevel()
          for _, xq in ac.selector():in_rangexy(x, y, 500):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "光之剑超新星(装弹)",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "能量",
              isvest = false,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
            xq:buffset(u.handle, 1, "眩晕")
          end
        end
      end)
      u:setdata("武器判定-光之剑超新星")
      u:addskill("S029")
      ChangeValue(Damage_Type_Nengliang, sy, 1)
      ChangeValue(HeroMenu_ExtraMoveSpeed_Bfb, sy, -0.5)
      ac.loop(1000, function(t)
        if not u:hasdata("枪械判定-光之剑超新星") or not u:hasdata("武器判定-光之剑超新星") then
          weapondown(u.handle, false, true)
          gunchangedel(u.handle)
          u:delskill("S029")
          ChangeValue(HeroMenu_ExtraMoveSpeed_Bfb, sy, 0.5)
          ChangeValue(Damage_Type_Nengliang, sy, -1)
          t:remove()
        end
      end)
    end
    if wplx == Weapons["新月玫瑰"] and not u:hasdata("武器判定-新月玫瑰") then
      if not u:hasdata("新月玫瑰-技能注册") then
        u:setdata("新月玫瑰-技能注册")
        
        local function skill(args)
          if args.skill == S2ID("A01Z") then
          end
          if args.skill == S2ID("A05F") then
          end
          if args.skill == S2ID("A053") then
          end
        end
        
        u:addtrgevent("单位-发动技能", function(args)
          skill(args)
        end)
      end
      u:setdata("武器判定-新月玫瑰")
      u:setdata("新月玫瑰-形态", "枪械")
      u:addskill("A053")
      u:addskill("A04S")
      u:addskill("A04I")
      u:banskill("A053", false)
      u:banskill("A04S", false)
      u:banskill("A04I", false)
      u:addskill("A054")
      u:addskill("A05C")
      u:addskill("A05F")
      u:banskill("A054")
      u:banskill("A05C")
      u:banskill("A05F")
      local yssh = 0
      ac.loop(1000, function(t)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * (-1 * yssh))
        yssh = 1.0E-4 * u:getdata("当前额外移速")
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * (1 * yssh))
        if u:getdata("新月玫瑰-形态") == "枪械" then
          u:banskill("A053", false)
          u:banskill("A04S", false)
          u:banskill("A04I", false)
          u:banskill("A054")
          u:banskill("A05C")
          u:banskill("A05F")
        else
          u:banskill("A053")
          u:banskill("A04S")
          u:banskill("A04I")
          u:banskill("A054", false)
          u:banskill("A05C", false)
          u:banskill("A05F", false)
        end
        if not u:hasdata("枪械判定-新月玫瑰") or not u:hasdata("武器判定-新月玫瑰") then
          ChangeValue(DamageSystem_EndSh, sy, 0.1 * (-1 * yssh))
          weapondown(u.handle, false, true)
          gunchangedel(u.handle)
          u:delskill("A054")
          u:delskill("A05C")
          u:delskill("A05F")
          u:delskill("A053")
          u:delskill("A04S")
          u:delskill("A04I")
          t:remove()
        end
      end)
    end
    if wplx == Weapons["量子机神剑"] then
      coopjudge("量子机神王")
    end
    if wplx == Weapons["村正"] then
      u:setdata("近战武器-妖刀村正")
      AddAllSTexiao("妖刀村正", "伤害系统计算效果", function(args)
        local tg = args.tg
        local info = args.damageinfo
        if tg:hasdata("妖刀村正-命中") then
          info.ewss = info.ewss + 0.12
        end
      end)
    end
    if wplx == Weapons["和泉守兼定"] then
      u:changearmor(10)
    end
    if wplx == Weapons["万宝槌"] then
      u:changedata("幸运", 2)
      u:changedata("幸运系数", 0.05)
      ChangeValue(HeroMenu_Sbxs, sy, 0.05)
      ChangeValue(Correction_Cbxs, sy, 0.1)
      u:setdata("武器判定-万宝槌")
    end
    if wplx == Weapons["轩辕剑(封)"] then
      u:adddivinity(1)
    end
    if wplx == Weapons["都牟刈村正"] then
      if not u:hasdata("武器判定-都牟刈村正") then
        ChangeValue(Correction_Cbxs, sy, 0.1)
        u:setdata("武器判定-都牟刈村正")
        local lw = 0
        local bs = 0
        ac.loop(1000, function(t)
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * -lw)
          ChangeValue(DamageSystem_Baoshang, sy, -bs)
          lw = 0.05 * System_Count_Weapon
          bs = 0.005 * u:getlevel()
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * lw)
          ChangeValue(DamageSystem_Baoshang, sy, bs)
          if not u:hasdata("武器判定-都牟刈村正") then
            ChangeValue(DamageSystem_Baoshang, sy, -bs)
            ChangeValue(Correction_Cbxs, sy, -0.1)
            ChangeValue(DamageSystem_Shjc, sy, 0.1 * -lw)
            t:remove()
          end
        end)
      end
      if not u:hasdata("千子村正-无元剑制") and u:hasdata("神化判定-千子村正") then
        u:setdata("千子村正-无元剑制")
        local dskill = S2ID("A1AD")
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
            if u:hasdata("无元剑制冷却") then
              b = false
              u:sendmessage("|cFF7DBEF1冷却中|r")
            end
            if u:hasbuff("暂停") then
              b = false
              u:sendmessage("|cFF7DBEF1处于暂停状态|r")
            end
            if not u:isalive() then
              b = false
              u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
            end
            if b then
              u:settimedata("无元剑制冷却", 1050)
              MovieAct["无元剑制"](u, x2, y2)
            else
              ewl:setskillcd(dskill, 1)
            end
          end
        end)
      end
    end
    if wplx == Weapons["神刀-丛雨丸"] then
      u:adddivinity(1)
    end
    if wplx == Weapons["灰狐刀"] then
      u:addstexiao("灰狐刀", "近战伤害效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not tg:hasdata("灰狐刀减甲") then
          tg:settimedata("灰狐刀减甲", 3)
          tg:changetimearmor(-33, 3)
        end
      end)
    end
    if wplx == Weapons["辉煌耀世"] then
      ChangeValue(DamageSystem_Yssh, sy, 0.1)
      ChangeValue(DamageSystem_Baoji, sy, 2)
      u:addstexiao("辉煌耀世", "暴击系统触发效果", function(args)
        local info = args.damageinfo
        if info.wqlx == Weapons["辉煌耀世"] then
          info.damage = info.damage * 1.13
        end
      end)
    end
    if wplx == Weapons["鬼丸国纲"] then
      ChangeValue(KillReward_MHp, sy, 2)
      u:changeoriginmaxhp(GetData(wp, "鬼丸国纲-生命上限提升"))
      u:sendmessage("|cFFCC0000鬼丸国纲提升生命上限：" .. math.floor(GetData(wp, "鬼丸国纲-生命上限提升")) .. "点|r")
    end
    if wplx == Weapons["地狱の轮祸"] then
      u:setdata("地狱轮祸特效", u:effectadd("AATX\\[AATxNew]Fire02.mdl", "origin", -1))
      u:changeoriginmaxhp(GetData(wp, "地狱轮祸-生命上限提升"))
      ChangeValue(DamageSystem_Shjc, sy, 0.1 * GetData(wp, "地狱轮祸-伤害加成提升"))
      u:sendmessage("|cFFCC0000地狱の轮祸提升生命上限：" .. math.floor(GetData(wp, "地狱轮祸-生命上限提升")) .. "点|r")
      u:sendmessage("|cFFCC0000地狱の轮祸提升伤害加成：" .. math.floor(GetData(wp, "地狱轮祸-伤害加成提升") * 10) .. "%|r")
    end
    if wplx == Weapons["绯"] then
      ChangeValue(DamageSystem_Shjc, sy, 0.1 * GetData(wp, "绯-最终伤害提升"))
      u:sendmessage("|cFFCC0000绯提升伤害加成：" .. math.floor(GetData(wp, "绯-最终伤害提升") * 10) .. "%|r")
    end
    if wplx == Weapons["祟"] then
    end
    if wplx == Weapons["白楼剑"] then
      ChangeValue(Hero_Tili_Huifu, sy, 0.2)
    end
    if wplx == Weapons["业物"] then
      u:changedata("根源变异数量", 1)
    end
    local has_switch_effect = u:hasdata("变异判定-二刀流") or u:hasdata("变异判定-龙剑") or u:ishasitem(Weapons["逸龙剑-抉择"])
    if has_switch_effect then
      local excluded = wplx == Weapons["高频村雨刀"] or wplx == Weapons["水果刀"] or wplx == Weapons["忴"] or wplx == Weapons["祟"] or wplx == Weapons["冈格尼尔"] or wplx == Weapons["莱瓦汀"]
      if not excluded then
        local t = 10
        if u:hasdata("变异判定-龙剑") and GetData(wplx, "近战武器类型") == 10 then
          t = t * 0.5
        end
        if had_equipped_weapon and u:hasdata("变异判定-二刀流") then
          local old_cd = tonumber(GetData(unequipped_weapon_type, "冷却时间")) or 10
          t = old_cd * 0.5
          if unequipped_weapon_type == Weapons["黑刀-夜"] and u:hasdata("变异判定-米霍克") then
            t = 1.25
          end
        end
        if u:hasdata("变异判定-但丁") then
          t = t * 0.5
          u:buffset(u.handle, 0.25, "绝对闪避")
          ChangeTimeValue(Correction_Jzsh, sy, 0.010000000000000002, 15)
        end
        if u:ishasitem(Weapons["逸龙剑-抉择"]) then
          t = t * 0.5
        end
        if u:hasdata("史朵巾-天使化") and t >= 1 then
          t = 1
        end
        if t <= 0.5 then
          t = 0.5
        end
        u:setskillcd("A01U", t)
      else
        u:setskillcd("A01U", 10)
      end
      if u:hasdata("变异判定-二刀流") then
        if u:hasdata("变异判定-史朵巾") then
          ChangeTimeValue(DamageSystem_Shjc, sy, 0.05, 6)
        end
        Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
        for _, xq in ac.selector():in_rangexy(x, y, 450):is_enemy(unit):ipairs() do
          xq = getunit(xq)
          xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
          DamageUnit({
            bj = "二刀流(切换武器)",
            unit = xq.handle,
            source = u.handle,
            damage = 2500 + 500 * u:getlevel(),
            isattack = true
          })
        end
      end
    end
    Hero_Equip_WeaponBoolean[sy] = true
    Hero_Equip_WeaponType[sy] = wplx
    u:setdata("装备武器", wp)
    RefreshCritWeaponBonus(u.handle)
  else
    u:addspeitem(wp)
  end
end

function weapondown(unit, boolean, qzxiexia)
  local b3 = qzxiexia or false
  local u = getunit(unit)
  local b2
  if boolean == nil then
    b2 = true
  else
    b2 = boolean
  end
  local sy = u.ownerid
  local wq, wqlx
  local x, y = u:getxy()
  if Hero_Equip_WeaponBoolean[sy] then
    wq = u:getdata("装备武器")
    wqlx = GetItemTypeId(wq)
  else
    return
  end
  local b = true
  if wqlx == Weapons["鬼丸国纲"] and GetData(wq, "鬼丸国纲-生命上限提升") >= u:getmaxhp() then
    b = false
    u:sendmessage("|cFFCC0000无法卸下武器-鬼丸国纲提升生命上限大于现有生命上限|r")
  end
  if wqlx == Weapons["地狱の轮祸"] and GetData(wq, "地狱轮祸-生命上限提升") >= u:getmaxhp() then
    b = false
    u:sendmessage("|cFFCC0000无法卸下武器-地狱轮祸提升生命上限大于现有生命上限|r")
  end
  if wqlx == Weapons["绯"] and GetData(wq, "绯-最终伤害提升") >= DamageSystem_Shjc[sy] then
    b = false
    u:sendmessage("|cFFCC0000无法卸下武器-绯提升最终伤害大于现有最终伤害|r")
  end
  if u:hasdata("禁止切换近战武器") then
    b = false
    u:sendmessage("|cFFCC0000无法卸下武器-禁止切换近战武器|r")
  end
  if wqlx == Weapons["潮枯"] then
    b = false
    if b2 and not u:hasdata("斯卡蒂-删除按钮") then
      u:setdata("斯卡蒂-删除按钮")
      u:sendmessage("|cFF949596Dr.，如果再乱按的话，下次可就是其他按钮了|r")
      u:delskill("A00C")
    end
  end
  if wqlx == Weapons["涤罪七雷"] and u:hasdata("武器判定-鸣雷见") then
    b = false
  end
  if b2 == false and (wqlx == Weapons["涤罪七雷"] or wqlx == Weapons["神刀-丛雨丸"] or wqlx == Weapons["薄暝"] or GetData(wqlx, "近战武器类型") == 10 and u:hasdata("变异判定-蛇百心流")) then
    b = false
  end
  if b == true or b3 == true then
    u:delweaponskill()
    if wqlx == Weapons["缠魇丸"] then
      u:deldata("武器判定-缠魇丸")
      Correction_JzFw[sy] = Correction_JzFw[sy] - 0.1
      u:delskill("A1KY")
      u:delskill("A1KW")
      u:delskill("A1KX")
    end
    if wqlx == Weapons["忴"] then
      u:deldata("武器判定-忴")
      u:delskill("A0LD")
      u:delskill("A0LG")
    end
    if wqlx == Weapons["雷霆长枪"] then
      u:deldata("武器判定-雷霆长枪")
    end
    if wqlx == Weapons["都牟刈村正"] then
      u:deldata("武器判定-都牟刈村正")
    end
    if wqlx == Weapons["无影剑"] then
      u:deldata("武器判定-无影剑")
    end
    if wqlx == Weapons["光之剑超新星"] then
      u:deldata("武器判定-光之剑超新星")
    end
    if wqlx == Weapons["诡异柴刀"] then
      u:deldata("武器装备中判定-诡异柴刀")
      u:deldata("诡异柴刀-二段伤害")
      u:changedata("诡异柴刀-切换序号", 1)
      u:banskill("S0D0", false)
      u:banskill("S0F9", false)
    end
    if wqlx == Weapons["破碎的刀刃"] or wqlx == Weapons["妖刀心渡"] then
      u:deldata("武器判定-破碎的刀刃")
      if wqlx == Weapons["妖刀心渡"] then
        u:deldata("武器判定-妖刀心渡")
        ChangeValue(DamageSplit_CountJzHit, sy, -2)
        ChangeValue(DamageSplit_CountJzMax, sy, -0.6)
      end
    end
    if wqlx == Weapons["青色怒火"] then
      ChangeValue(DamageSplit_CountJzMax, sy, -0.5)
      ChangeValue(DamageSplit_CountJzHit, sy, -1)
      u:deldata("武器判定-青色怒火")
      u:deldata("武器判定-特殊近战武器")
      u:delskill("A0AK")
    end
    if wqlx == Weapons["史莱姆剑"] then
      u:deldata("武器判定-史莱姆剑")
      u:changedata("史莱姆剑-切换序号", 1)
      u:banskill("S0E0", false)
      u:banskill("S0E1", false)
    end
    if wqlx == Weapons["龙刃"] then
      u:deldata("武器判定-龙刃")
      u:deldata("武器判定-特殊近战武器")
      ARskillreplace({
        unit = u.handle,
        level = -2,
        skill_A = "A00K",
        skill_R = "A00S",
        isforce = false,
        efunc = function()
        end
      })
    end
    if wqlx == Weapons["环印骑士直剑"] then
      u:deldata("武器判定-环印骑士直剑")
      u:deldata("武器判定-特殊近战武器")
      ARskillreplace({
        unit = u.handle,
        level = -2,
        skill_A = "A01Z",
        skill_R = "A026",
        isforce = false,
        efunc = function()
        end
      })
    end
    if wqlx == Weapons["星辰短剑"] then
      u:deldata("武器判定-星辰短剑")
      u:deldata("武器判定-特殊近战武器")
      ARskillreplace({
        unit = u.handle,
        level = -2,
        skill_A = "A099",
        skill_R = "A09A",
        isforce = false,
        efunc = function()
        end
      })
    end
    if wqlx == Weapons["红城的律令"] then
      u:deldata("武器判定-红城的律令")
      u:deldata("武器判定-特殊近战武器")
      ARskillreplace({
        unit = u.handle,
        level = -2,
        skill_A = "A0FN",
        skill_R = "A0FM",
        isforce = false,
        efunc = function()
        end
      })
    end
    if wqlx == Weapons["高频村雨刀"] then
      u:deldata("武器判定-高频村雨刀")
      u:deldata("武器判定-特殊近战武器")
      ARskillreplace({
        unit = u.handle,
        level = -2,
        skill_A = "A03G",
        skill_R = "A03K",
        isforce = false,
        efunc = function()
        end
      })
    end
    if wqlx == Weapons["涤罪七雷"] then
      u:deldata("武器判定-涤罪七雷")
      u:changedata("雷变异数量", -1)
      ChangeValue(Damage_Element_Thunder, sy, -0.1)
      ChangeValue(Damage_Element_All, sy, -0.05)
      ChangeValue(Damage_ElementRes_Thunder, sy, -20)
    end
    if wqlx == Weapons["童子切安纲"] then
      ChangeValue(Correction_Cbxs, sy, -0.12)
      ChangeValue(DamageSystem_BaoshangBeilv, sy, -0.25)
    end
    if wqlx == Weapons["蔷薇之刃"] then
      u:deldata("武器判定-蔷薇之刃")
    end
    if wqlx == Weapons["濡湿小镰刀"] then
      u:deldata("武器判定-濡湿小镰刀")
      ChangeValue(Damage_Element_Dark, sy, -0.1)
    end
    if wqlx == Weapons["和泉守兼定"] then
      u:changearmor(-10)
    end
    if wqlx == Weapons["万宝槌"] then
      u:changedata("幸运", -2)
      u:changedata("幸运系数", -0.05)
      ChangeValue(HeroMenu_Sbxs, sy, -0.05)
      ChangeValue(Correction_Cbxs, sy, -0.1)
      u:deldata("武器判定-万宝槌")
    end
    if wqlx == Weapons["村正"] then
      u:deldata("近战武器-妖刀村正")
    end
    if wqlx == Weapons["轩辕剑(封)"] then
      u:adddivinity(-1)
    end
    if wqlx == Weapons["辉煌耀世"] then
      ChangeValue(DamageSystem_Yssh, sy, -0.1)
      ChangeValue(DamageSystem_Baoji, sy, -2)
    end
    if wqlx == Weapons["神刀-丛雨丸"] then
      u:adddivinity(-1)
    end
    if wqlx == Weapons["白楼剑"] then
      Hero_Tili_Huifu[sy] = Hero_Tili_Huifu[sy] - 0.2
    end
    if wqlx == Weapons["业物"] then
      u:changedata("根源变异数量", -1)
    end
    if wqlx == Weapons["鬼丸国纲"] then
      KillReward_MHp[sy] = KillReward_MHp[sy] - 2
      u:changeoriginmaxhp(-1 * GetData(wq, "鬼丸国纲-生命上限提升"))
    end
    if wqlx == Weapons["地狱の轮祸"] then
      DamageSystem_Shjc[sy] = DamageSystem_Shjc[sy] - 0.1 * GetData(wq, "地狱轮祸-伤害加成提升")
      u:changeoriginmaxhp(-1 * GetData(wq, "地狱轮祸-生命上限提升"))
      DestroyEffectLua(u:getdata("地狱轮祸特效"))
      u:deldata("地狱轮祸特效")
    end
    if wqlx == Weapons["绯"] then
      DamageSystem_Shjc[sy] = DamageSystem_Shjc[sy] - 0.1 * GetData(wq, "绯-最终伤害提升")
    end
    SetItemPosition(wq, x, y)
    u:addspeitem(wq)
    Hero_Equip_WeaponBoolean[sy] = false
    Hero_Equip_WeaponType[sy] = S2ID("ratf")
    RefreshCritWeaponBonus(u.handle)
  end
end
