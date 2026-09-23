-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local slk = require("jass.slk")

function damagesystemre008(unit, source, damage, damagelevel, dis)
  local sh = damage
  local u = getunit(unit)
  local soc = getunit(source)
  local x, y = u:getxy()
  local x2, y2 = soc:getxy()
  local sy = u.ownerid
  local sy2 = soc.ownerid
  local shlx = damagelevel
  local dt = true
  local zu = StexiaoFunc({
    text = "决死效果",
    unit = u.handle,
    u = u,
    sy = sy,
    damage = sh,
    dt = dt,
    soc = soc
  })
  dt = zu.dt
  sh = zu.damage
  if dt and u:hasdata("莲华-勿忘草决死") and not u:hasdata("莲华-勿忘草决死冷却") then
    dt = false
    u:settimedata("莲华-勿忘草决死冷却", 600)
    u:sendmessage("|cFFFF99FF莲华-勿忘草与永远的少女|r")
    ac.wait(600000, function()
      u:sendmessage("|cFFFF99FF莲华-勿忘草与永远的少女冷却完毕|r")
    end)
    u:effectadd("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", "chest")
    local lh = u:getdata("莲华-勿忘草莲华")
    lh:sendmessage("|cFFFF99FF莲华-勿忘草与永远的少女|r")
    u:buffset(lh.handle, 3, "绝对闪避")
    u:sethp(100, true)
    lh:buffset(lh.handle, 15, "暂停")
    lh:buffset(lh.handle, 15, "无敌")
  end
  if dt and u:hasdata("变异判定-露娜") and not u:hasdata("露娜-免死冷却") then
    dt = false
    u:settimedata("露娜-免死冷却", 232.7)
    u:sendmessage("|cFFFF99FF露娜-扁桃|r")
    ac.wait(232700, function()
      u:sendmessage("|cFFFF99FF露娜-免死冷却完毕|r")
    end)
    u:buffset(unit, 3, "绝对闪避")
    u:effectadd("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", "chest")
  end
  if dt and u:hasdata("琉紫-时钟机关之星") and not u:hasdata("琉紫-时钟机关之星冷却") then
    dt = false
    u:settimedata("琉紫-时钟机关之星冷却", 480)
    u:sendmessage("|cFFE2D5CB琉紫-时钟机关之星|r")
    u:sethp(100, true)
    u:playsound(Sound_Liuzi_Fuhuo)
    local time = 15
    u:settimedata("琉紫-虚数时间", time)
    ChangeTimeValue(DamageSystem_Shjc, sy, 1, time)
    ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 250, time)
    u:effectadd("liuzi_xushukongjian.mdl", "origin", time)
    Effectcreate("liuzi_xukong.mdl", x, y)
  end
  if dt and u:hasdata("变异判定-安克雷奇") and not u:hasdata("安克雷奇-Hide and seek冷却") then
    dt = false
    u:setdata("安克雷奇-Hide and seek冷却")
    u:sendmessage("|cFFB58C88安克雷奇-Hide and seek|r")
    u:effectadd("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", "chest")
    u:buffset(unit, 2, "无敌")
  end
  if dt and u:hasdata("变异判定-指引明路的苍蓝星") and not u:hasdata("指引明路的苍蓝星-猫的报酬金冷却") then
    dt = false
    u:setdata("指引明路的苍蓝星-猫的报酬金冷却")
    u:sendmessage("|cFFB58C88指引明路的苍蓝星-猫的报酬金|r")
    u:effectadd("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", "chest")
    u:buffset(unit, 2, "无敌")
  end
  if dt and u:getdata("白洲梓-奇迹之花次数") > 0 then
    dt = false
    u:setdata("僵直时间", 0)
    u:setdata("眩晕时间", 0)
    u:changedata("白洲梓-奇迹之花次数", -1)
    u:sendmessage("|cFFF3D9F0奇迹|r|cFFFFFEFF之|r|cFF8A6CAE花|r|cFFF3D9F0剩余次数：" .. math.floor(u:getdata("白洲梓-奇迹之花次数")))
    u:buffset(unit, 1, "无敌")
  end
  if dt and u:hasdata("变异判定-姬柊雪菜") and not u:hasdata("雪菜-第十一眷兽冷却") then
    dt = false
    u:settimedata("雪菜-第十一眷兽冷却", 600)
    u:sendmessage("|cFFCCCCCC第十一眷兽-水精之白钢|r")
    ac.wait(600000, function()
      u:sendmessage("|cFFCCCCCC第十一眷兽-水精之白钢冷却完毕|r")
    end)
    Effectcreate("Tx_Jzxc2_shuijing.mdl", x, y, 2, 2)
    Effectcreate("Tx_Jzxc2_shuijing2.mdl", x, y, 0, 2)
    u:effectadd("Tx_Jzxc2_shuijing3.mdl", "origin", 10)
    u:effectadd("Abilities\\Spells\\Items\\AIvi\\AIviTarget.mdl")
    local cs = 0
    ac.loop(250, function(t)
      cs = cs + 1
      u:sethp(100, true)
      if cs == 40 then
        t:remove()
      end
    end)
  end
  if dt and u:hasdata("变异判定-帝国的公主") and not u:hasdata("帝国的公主-致死格挡冷却") then
    dt = false
    local t = 240
    if IsTimeDay() then
      t = 360
    end
    u:settimedata("帝国的公主-致死格挡冷却", t)
    u:sendmessage("|cFFFF6699帝国的公主-吸血鬼萝莉致死抵挡|r")
    ac.wait(t * 1000, function()
      u:sendmessage("|cFFFF6699帝国的公主-吸血鬼萝莉致死抵挡冷却完毕|r")
    end)
    u:buffset(unit, 1, "无敌")
    u:effectadd("Abilities\\Spells\\Items\\AIvi\\AIviTarget.mdl")
  end
  if dt and u:hasdata("妖梦天赋-人世剑") and not u:hasdata("妖梦天赋-人世剑冷却") then
    dt = false
    u:settimedata("妖梦天赋-人世剑冷却", 600)
    u:sendmessage("|cFF99FFFF人世剑「大悟显晦」|r")
    ac.wait(600000, function()
      u:sendmessage("|cFF99FFFF人世剑冷却完毕|r")
    end)
    u:buffset(unit, 1, "无敌")
    u:effectadd("Abilities\\Spells\\Items\\AIvi\\AIviTarget.mdl")
  end
  if dt and u:hasdata("犬夜叉-妖化") and 0 < u:getdata("犬夜叉-妖化格挡") then
    dt = false
    u:setdata("僵直时间", 0)
    u:setdata("眩晕时间", 0)
    u:changedata("犬夜叉-妖化格挡", -1)
    u:sendmessage("|cFF990000妖化剩余次数：" .. math.floor(u:getdata("犬夜叉-妖化格挡")))
    u:buffset(unit, 1, "无敌")
    u:effectadd("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl")
    u:effectadd("war3mapImported\\texiao_xuebao.mdx")
  end
  if dt and u:hasdata("柴郡猫戒指-持有") and not u:hasdata("柴郡猫戒指-决死冷却") then
    dt = false
    u:settimedata("柴郡猫戒指-决死冷却", 399)
    u:sendmessage("|cFFE633B2「消失」|r")
    u:buffset(unit, 2, "无敌")
    mapmove(unit, "柴郡猫戒指")
  end
  if dt and u:hasdata("阿卡多-零式死河") then
    local xh = sh / u:getmaxhp()
    if 100 <= xh then
      xh = 100
    end
    if xh <= 5 then
      xh = 5
    end
    if xh <= u:getdata("阿卡多-血液储量") then
      dt = false
      u:changedata("阿卡多-血液储量", -1 * xh)
      u:sendmessage("|cFF990000死河之力消耗血液：" .. math.floor(xh) .. "|r")
    end
  end
  if dt and u:hasdata("变异判定-阿波菲斯") and not u:hasdata("阿波菲斯-混沌罪孽冷却") then
    dt = false
    u:settimedata("阿波菲斯-混沌罪孽冷却", 220)
    u:buffset(unit, 10, "混乱")
    u:effectadd("war3mapImported\\3.28.344 (1).mdl")
  end
  if dt and u:hasdata("变异判定-始祖吸血鬼") and not u:hasdata("克鲁鲁-再生护盾冷却") then
    dt = false
    local hp = 0.1 * sh
    u:settimedata("克鲁鲁-再生护盾冷却", 180)
    SendMsgAll("|cFFCC0000「|r|cFFD41122无|r|cFFDD2244力|r|cFFE63366呐|r|cFFEE4488」|r")
    u:sendmessage("|cFFCC0000生命恢复提升了" .. math.floor(hp) .. "点|r")
    ChangeTimeValue(HeroMenu_HpChange_Inr, sy, hp, 10)
    u:playsound(Sound_Mugen_01__3_u)
    u:effectadd("war3mapImported\\k3_tx (3).mdl", "origin", 10)
    local cs = 0
    ac.loop(250, function(t)
      cs = cs + 1
      u:effectadd("war3mapImported\\texiao_xuebao.mdl")
      if cs == 4 then
        t:remove()
      end
    end)
    ac.wait(180000, function()
      u:sendmessage("|cFFCC0000吸血鬼再生护盾冷却完毕|r")
    end)
  end
  if dt and u:hasdata("变异判定-宇智波佐助") and not u:hasdata("宇智波佐助-须佐能乎冷却") then
    dt = false
    u:settimedata("宇智波佐助-须佐能乎冷却", 360)
    SendMsgAll("|cFF9999FF宇智|r|cFF6633FF波|r|cFF9999FF佐|r|cFF6633FF助：『|r|cFF990000绝|r|cFF9F0608望|r|cFFA40B11，|r|cFFAA111A愤|r|cFFB01722怒|r|cFFB51C2A |r|cFFBB2233让|r|cFFC1283C你|r|cFFC62D44见|r|cFFCC334C识|r|cFFD23955一|r|cFFD73E5E下|r|cFFDD4466我|r|cFFE34A6E的|r|cFFE84F77黑|r|cFFEE5580暗|r|cFFF45B88吧|r|cFF6633FF』|r")
    u:buffset(unit, 3, "无敌")
    PlayGlobalSound(Sound_Zz_102)
    u:effectadd("war3mapImported\\2.12 (6).mdl", "origin", 3)
    for _, xq in ac.selector():in_rangexy(x, y, 800):is_enemy(unit):ipairs() do
      xq = getunit(xq)
      xq:groupadd(Group_Zz_Tianzhaozu)
      local t = 10
      if t > xq:getdata("佐助-天照灼烧时间") then
        xq:setdata("佐助-天照灼烧时间", t)
      end
      if not xq:hasdata("佐助-天照特效") then
        xq:setdata("佐助-天照特效", xq:effectadd("war3mapImported\\2.11 (1).mdl"))
      end
    end
  end
  if dt and u:hasdata("贝洛妮卡-拉斯达普") and not u:hasdata("贝洛妮卡-拉斯达普冷却") then
    dt = false
    u:playsound(bac107)
    u:settimedata("贝洛妮卡-拉斯达普冷却", 300)
    ac.wait(300000, function()
      u:sendmessage("|cFF6699FF拉斯达普冷却完毕|r")
    end)
    local t = 7
    local add = 0.2
    if u:hasdata("贝洛妮卡-沙场老兵") then
      t = 12
      add = 0.3
      ChangeValue(DamageSystem_Shjc, sy, 0.0025)
      ChangeValue(DamageSystem_Shjc, sy, 0.0025)
    end
    u:settimedata("贝洛妮卡-拉斯达普死亡抗拒", t)
    ChangeTimeValue(DamageSystem_Shjc, sy, 0.1 * add, t)
    ChangeTimeValue(DamageSystem_Shjc, sy, 0.1 * add, t)
    ChangeTimeValue(DamageSystem_Shjc, sy, 0.1 * add, t)
    ChangeTimeValue(DamageSystem_Shjc, sy, 0.1 * add, t)
    Effectcreate("war3mapImported\\Tx_Blnk (9).mdl", x, y, 0, 1.25)
    Effectcreate("war3mapImported\\[TX] (945).mdl", x, y, 0, 1.5)
    Effectcreate("war3mapImported\\[TX] (967).mdl", x, y, 0, 2.5)
    local max = t / 0.02
    local cs = 0
    local tx = Effectcreate("war3mapImported\\Tx_Blnk (10).mdl", x, y, -1)
    ac.loop(20, function(timer)
      cs = cs + 1
      x, y = u:getxy()
      SetEffectXY(tx, x, y)
      if cs == max then
        DestroyEffectLua(tx)
        timer:remove()
      end
    end)
  end
  if dt and u:hasdata("变异判定-魔术师杀手") and not u:hasdata("变异判定-魔术师杀手致死冷却") then
    dt = false
    u:settimedata("变异判定-魔术师杀手致死冷却", 360)
    u:clearbuff()
    u:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile.mdl", "chest", 10)
    ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 1000, 10)
    local max = 100
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
    if u:hasbuff("眩晕") then
      u:setdata("眩晕时间", 0)
    end
    if u:hasbuff("僵直") then
      u:setdata("僵直时间", 0)
    end
    if u:hasbuff("缠绕") then
      u:setdata("缠绕时间", 0)
    end
  end
  if dt and u:hasdata("变异判定-桔梗") and not u:hasdata("变异判定-桔梗格挡冷却") then
    dt = false
    u:settimedata("变异判定-桔梗格挡冷却", 120)
    u:curehp(unit, 0, 30, 2)
  end
  if dt and u:hasdata("变异判定-奴良陆生") and not u:hasdata("变异判定-妖魔退散抵挡冷却") then
    dt = false
    u:settimedata("变异判定-妖魔退散抵挡冷却", 300)
    u:sendmessage("|cFF999999奴良陆生-妖魔退散|r")
    ac.wait(300000, function()
      u:sendmessage("|cFF999999奴良陆生-妖魔退散冷却完毕|r")
    end)
    u:buffset(unit, 3, "绝对闪避")
    u:curehp(unit, 0, 50, 2)
  end
  if dt and u:hasdata("里三天赋-物质恶德") and not u:hasdata("里三-物质恶德冷却") then
    dt = false
    u:settimedata("里三-物质恶德冷却", 360)
    u:sendmessage("|cFF6633FF里三-物质恶德|r")
    ac.wait(600000, function()
      u:sendmessage("|cFF6633FF里三-物质恶德冷却完毕|r")
    end)
    u:sethp(100, true)
    u:buffset(unit, 0.1, "无敌")
    for _, xq in ac.selector():in_rangexy(x, y, 1500):is_enemy(unit):ipairs() do
      xq = getunit(xq)
      xq:effectadd("effect\\Hero\\K3_2 (3).mdl", "origin")
      xq:buffset(unit, 5, "暂停")
    end
  end
  if dt and u:hasdata("里三-魔王武装") then
    local g = GetUnitsOfPlayerAndTypeIdLua(u.owner, S2ID("o007"))
    ForGroupLuaNew(g, function(xq)
      if DistanceBetweenUnits(xq.handle, unit) > 4000 or xq:getdata("梦魇之影-存活时间") <= 0 then
        xq:groupremove(g)
      end
    end)
    if Group_Counts(g) > 0 then
      do
        local mj = Group_Randomunit(g)
        if type(mj) ~= "table" then
          error("梦魇之影组计数与内容不一致")
        end
        mj:setdata("梦魇之影-存活时间", 0)
        dt = false
        u:buffset(unit, 0.1, "无敌")
        u:sendmessage("|cFF6699FF梦魇之影|r")
      end
    end
  end
  if dt and u:hasdata("变异判定-星神之嗣") and not u:hasdata("变异判定-星神之嗣免死冷却") then
    dt = false
    u:settimedata("变异判定-星神之嗣免死冷却", 90)
    u:sendmessage("|cFF800040星|r|cFF8F0033神|r|cFF9E0026之|r|cFFAE001A嗣|r")
    ac.wait(90000, function()
      u:sendmessage("|cFF800040星|r|cFF880039神|r|cFF910032之|r|cFF99002B嗣|r|cFFA20024冷|r|cFFAA001C却|r|cFFB30015完|r|cFFBB000E毕|r")
    end)
    u:buffset(unit, 1, "无敌")
    u:effectadd("Abilities\\Spells\\Other\\Charm\\CharmTarget.mdl")
    u:addskill("A04P")
    ac.wait(15000, function()
      u:delskill("A04P")
    end)
  end
  if dt and u:hasdata("变异判定-圣魔之血") and not u:hasdata("变异判定-圣魔之血免死冷却") then
    dt = false
    local t = 180 - 10 * u:getdata("吸血鬼变异数量")
    if t <= 90 then
      t = 90
    end
    u:settimedata("变异判定-圣魔之血免死冷却", t)
    u:sendmessage("|cFF666666圣|r|cFF7A7A7A魔|r|cFF8F8F8F之|r|cFFA3A3A3血|r")
    ac.wait(t * 1000, function()
      u:sendmessage("|cFF666666圣|r|cFF7A7A7A魔|r|cFF8F8F8F之|r|cFFA3A3A3血|r")
    end)
    u:buffset(unit, 5, "无敌")
  end
  if dt and u:hasdata("希望之星-持有") and not u:hasdata("希望之星-免死冷却") then
    dt = false
    u:settimedata("希望之星-免死冷却", 240)
    u:sendmessage("|cFF6699FF物品-希望之星|r")
    ac.wait(240000, function()
      u:sendmessage("|cFF6699FF物品-希望之星冷却完毕|r")
    end)
  end
  if dt and u:hasdata("朱红之瑰-持有") and not u:hasdata("朱红之瑰-免死冷却") then
    dt = false
    u:settimedata("朱红之瑰-免死冷却", 360)
    u:sendmessage("|cFFFF0000物品-朱红之瑰|r")
    ac.wait(360000, function()
      u:sendmessage("|cFFFF0000物品-朱红之瑰冷却完毕|r")
    end)
    local wp = u:getitem("I0C9")
    local cs = GetItemCharges(wp) / 2
    SetItemCharges(wp, cs)
    u:changemaxhp(cs)
  end
  if dt and u:hasdata("伊蕾娜-禁忌化三") and not u:hasdata("伊蕾娜-魔女之旅冷却") then
    dt = false
    u:settimedata("伊蕾娜-魔女之旅冷却", 150)
    u:sendmessage("|cFFCC99FF伊蕾娜-魔女之旅|r")
    ac.wait(150000, function()
      u:sendmessage("|cFFCC99FF伊蕾娜-魔女之旅|r")
    end)
    u:buffset(unit, 5, "无敌")
  end
  if dt and u:hasdata("卡斯特-蔚蓝之星") and not u:hasdata("卡斯特-蔚蓝之星冷却") then
    dt = false
    u:settimedata("卡斯特-蔚蓝之星冷却", 300)
    u:sendmessage("|cFF6699FFCaster-蔚蓝之星|r")
    ac.wait(300000, function()
      u:sendmessage("|cFF6699FFCaster-蔚蓝之星冷却完毕|r")
    end)
    u:buffset(unit, 1, "无敌")
  end
  if dt and u:hasdata("变异判定-量子核心") and not u:hasdata("量子核心-量子能源关闭") and not u:hasdata("量子核心-致死格挡冷却") and Hero_Tili[sy] >= 0.5 * Hero_Tili_Max[sy] then
    dt = false
    u:settimedata("量子核心-致死格挡冷却", 60)
    if u:hasdata("羁绊-量子机神王") then
      Hero_Tili[sy] = Hero_Tili[sy] - 0.4 * Hero_Tili_Max[sy]
    else
      Hero_Tili[sy] = Hero_Tili[sy] - 0.5 * Hero_Tili_Max[sy]
    end
    u:sendmessage("|cFF6699FF量子核心-致死格挡|r")
    ac.wait(60000, function()
      u:sendmessage("|cFF6699FF量子核心-致死格挡冷却完毕|r")
    end)
    u:buffset(unit, 1, "无敌")
  end
  if dt and u:hasdata("窥星-夜晚判定") and not u:hasdata("窥星-月之祝冷却") then
    dt = false
    u:setdata("窥星-月之祝冷却")
    u:sendmessage("|cFF3399FF月之祝|r")
    ac.wait(120000, function()
      ac.loop(1000, function(t)
        if GetTimeOfDay() >= 23.5 or GetTimeOfDay() <= 0.5 then
          u:sendmessage("|cFF3399FF月之祝冷却完毕|r")
          u:deldata("窥星-月之祝冷却")
          t:remove()
        end
      end)
    end)
    u:sethp(100, true)
    u:effectadd("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl")
    u:buffset(unit, 1, "绝对闪避")
  end
  if dt and u:hasdata("朱雀院椿-禁忌化") and not u:hasdata("朱雀院椿-浴火鸟冷却") then
    dt = false
    u:settimedata("朱雀院椿-浴火鸟冷却", 180)
    u:settimedata("朱雀院椿-浴火鸟", 15)
    SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『覆翼自守的朱雀可不是那么容易就能斩破的！』|r")
    ac.wait(180000, function()
      u:sendmessage("|cFFCC99FF浴火鸟冷却完毕|r")
    end)
    soc:settimedata("朱雀院椿-浴火鸟破抗", 10)
    PlayGlobalSound(Sound_Chun_22)
    u:buffset(unit, 3, "无敌")
    u:buffset(unit, 3, "绝对闪避")
    local cs = 0
    ac.loop(100, function(t)
      cs = cs + 1
      u:sethp(100, true)
      if cs == 100 then
        t:remove()
      end
    end)
  end
  if dt and u:ishasbuff("B06J") and not u:hasdata("祢豆子守护冷却") then
    dt = false
    u:settimedata("祢豆子守护冷却", 180)
    u:buffset(unit, 3, "伤害免疫")
    local mdz = getunit(Midouzi)
    local x3, y3 = mdz:getxy()
    Effectcreate("war3mapimported\\blackblink.mdx", x3, y3)
    mdz:setxy(x3, y3)
    x3, y3 = mdz:getxy()
    Effectcreate("war3mapimported\\blackblink.mdx", x3, y3)
  end
  if dt and u:hasdata("血统判定-风神") and not u:hasdata("风の祈愿冷却") then
    dt = false
    u:curehp(unit, 0, 40, 3)
    u:settimedata("风の祈愿冷却", 500)
    u:sendmessage("|cFF66FF99「风の祈愿」|r")
    ac.wait(500000, function()
      u:sendmessage("|cFF66FF99风の祈愿冷却|r")
    end)
    u:buffset(unit, 3, "绝对闪避")
    u:buffset(unit, 3, "无敌")
    ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 400, 3)
  end
  if dt and u:ishasbuff("B07T") and not getunit(NPC_BAYUNZI):hasdata("八云紫守护冷却") then
    dt = false
    getunit(NPC_BAYUNZI):settimedata("八云紫守护冷却", 900)
    u:buffset(unit, 3, "伤害免疫")
    local mdz
    ForGroupLuaNew(Group_PlayHero, function(xq)
      if xq:ishasitem("I06F") then
        mdz = xq
      end
    end)
    if mdz then
      u:sendmessage("|cFF6633FF某美少女救你一命|r")
      u:curehp(unit, 0, 25, 1)
      do
        local x3, y3 = mdz:getxy()
        Effectcreate("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdl", x3, y3)
        mdz:setxy(x3, y3)
        x3, y3 = mdz:getxy()
        Effectcreate("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdl", x3, y3)
      end
    end
  end
  if dt and u:hasdata("变异判定-蓬莱山辉夜") and not u:hasdata("刹那永恒冷却") then
    dt = false
    u:settimedata("刹那永恒冷却", 600)
  end
  if dt and u:hasdata("变异判定-立华奏") and not u:hasdata("立华奏-超频延迟冷却") then
    dt = false
    u:settimedata("立华奏-超频延迟冷却", 300)
    u:playsound(Sound_Kanade_02)
    u:buffset(unit, 5, "绝对闪避")
    ac.wait(300000, function()
      u:sendmessage("|cFFCC99FF超频延迟冷却完毕|r")
    end)
    for _, xq in ac.selector():in_rangexy(x, y, 1800):is_enemy(unit):ipairs() do
      xq = getunit(xq)
      xq:buffset(unit, 10, "暂停")
    end
    ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 500)
    Effectcreate("AATX\\[AATxNew]White22.mdl", x, y, 0, 2)
    u:effectadd("ATX\\[ATxNew]White_17.mdl", "origin", 5)
    local cs = 0
    ac.loop(250, function(t)
      cs = cs + 1
      x, y = u:getxy()
      Effectcreate("war3mapImported\\bbb.mdx", x, y)
      if cs == 20 then
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -500)
        t:remove()
      end
    end)
  end
  if dt and u:hasdata("血统判定-冥神") and not u:hasdata("冥神-冥行冷却") then
    dt = false
    u:settimedata("冥神-冥行冷却", 500)
    u:chat("存在的本身，就是潜在的死亡。")
    u:sendmessage("|cFF3366FF冥|r|cFF3357F0行|r")
    ac.wait(150000, function()
      u:sendmessage("|cFF3366FF冥|r|cFF3357F0行|r|cFF3349E2冷|r|cFF333AD3却|r|cFF332CC5完|r|cFF331DB6毕|r")
    end)
    ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 500)
    u:buffset(u.handle, 15, "无实体")
    local cs = 0
    ac.loop(250, function(t)
      cs = cs + 1
      u:setdata("冥神-冥行")
      x, y = u:getxy()
      Effectcreate("Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl", x, y)
      if cs == 60 then
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -500)
        u:deldata("冥神-冥行")
        t:remove()
      end
    end)
  end
  if dt and u:hasdata("雷电子-暴走") and Group_Counts(Group_Xingcunzu) <= 1 then
    dt = false
    u:deldata("雷电子-暴走")
    if getunit(BOSS):hasdata("第三阶段开始") then
    else
      u:buffset(unit, 8, "暂停")
    end
    u:buffset(unit, 8, "绝对闪避")
    u:buffset(unit, 10, "无敌")
    local cs = 0
    ac.loop(20, function(t)
      cs = cs + 1
      local jd = GetRandomReal(0, 360)
      local jl = GetRandomReal(0, 100 + cs)
      local x3, y3 = PolarXY(x, y, jl, jd)
      Effectcreate("Abilities\\Spells\\Orc\\LightningShield\\LightningShieldTarget.mdl", x3, y3, 0.5)
      if cs == 300 then
        t:remove()
      end
    end)
    u:chat("不好意思")
    ac.wait(1700, function()
      u:chat("从现在开始对你做的")
    end)
    ac.wait(3800, function()
      u:chat("全部都是出气罢了")
    end)
    ac.wait(7000, function()
      x, y = u:getxy()
      local jd = GetRandomReal(0, 360)
      local jl = 250
      for i = 1, 6 do
        jd = jd + 60
        local x3, y3 = PolarXY(x, y, jl, jd)
        Effectcreate("war3mapimported\\great lightning.mdl", x3, y3, 0, 2)
      end
    end)
    ac.wait(7800, function()
      x, y = u:getxy()
      local jd = GetRandomReal(0, 360)
      local jl = 500
      for i = 1, 12 do
        jd = jd + 30
        local x3, y3 = PolarXY(x, y, jl, jd)
        Effectcreate("war3mapimported\\great lightning.mdl", x3, y3, 0, 2)
      end
    end)
    ac.wait(10000, function()
      local cs2 = 0
      ac.loop(200, function(timer)
        cs2 = cs2 + 1
        local jd = GetRandomReal(0, 360)
        local jl = GetRandomReal(0, 1000)
        local x3, y3 = PolarXY(x, y, jl, jd)
        Effectcreate("war3mapimported\\great lightning.mdl", x3, y3, 0, 2.5)
        local txsh = 2500 + 250 * u:getlevel()
        for _, xq in ac.selector():in_rangexy(x3, y3, 300):is_enemy(unit):ipairs() do
          xq = getunit(xq)
          DamageUnit({
            bj = "雷电子暴走",
            unit = xq.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "灵力",
            isvest = true,
            isnoarmor = false
          })
          xq:buffset(unit, 1, "僵直")
        end
        if cs2 == 50 then
          timer:remove()
        end
      end)
    end)
    u:settimedata("雷电子-暴走形态", 20)
    ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 250, 20)
  end
  if dt and u:hasdata("遗物-百兽王化") and not u:hasdata("百兽王化冷却") and not u:hasdata("变身状态") then
    dt = false
    u:settimedata("百兽王化冷却", 600)
    u:buffset(unit, 1, "无敌")
    u:clearbuff("暂停")
    local dx = 1
    ac.loop(250, function(timer)
      x, y = u:getxy()
      dx = dx + 1
      Effectcreate("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", x, y, 0, dx)
      if 5 <= dx then
        timer:remove()
      end
    end)
    u:buffset(unit, 3, "绝对闪避")
    u:heshin("狮子王")
  end
  if dt and u:isingroup(Group_Wolf) and not u:hasdata("狼神庇护冷却") and Weiyi_Feishen[4] then
    dt = false
    u:setdata("狼神庇护冷却")
    u:effectadd("Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl", "chest", 3)
    u:buffset(unit, 3, "无敌")
  end
  if dt and u:getdata("黑龙血统阶级") >= 4 and not u:hasdata("宿命冷却") then
    dt = false
    u:settimedata("宿命冷却", 80)
    u:sethp(100, true)
    u:sendmessage("|cFF990000黑龙-宿命|r")
    ac.wait(80000, function()
      u:sendmessage("|cFF990000黑龙-宿命冷却完毕|r")
    end)
    u:buffset(unit, 3, "无敌")
    if u:getdata("黑龙血统阶级") >= 5 and not u:hasdata("黑龙-灾厄使者") then
      u:changedata("愤怒值", 20)
      u:sendmessage("|cFF990000愤怒值增加|r")
      if u:getdata("愤怒值") >= 100 then
        live = true
        PlayBGM({
          bgm = BGM_Heilong_02,
          time = 245,
          ID = 44,
          unit = u.handle
        })
        SendMsgAll("|cFFFF0000『|r|cFFE60000愤|r|cFFCC0000怒|r|cFFB20000吞|r|cFF990000噬|r|cFF800000了|r|cFF660000自|r|cFF4C0000我|r|cFF330000』|r")
        SendDtimeMsgAll(3, "|cFFFF0000『|r|cFFDB0000带|r|cFFB60000来|r|cFF920000灾|r|cFF6D0000祸|r|cFF490000』|r")
        SendDtimeMsgAll(6, "|cFFFF0000『|r|cFFEA0000将|r|cFFD40000世|r|cFFBF0000上|r|cFFAA0000天|r|cFF950000空|r|cFF800000尽|r|cFF6A0000染|r|cFF550000绯|r|cFF400000色|r|cFF2A0000』|r")
        SendDtimeMsgAll(9, "|cFFFF0000『|r|cFFE80000迎|r|cFFD10000来|r|cFFB90000“|r|cFFA20000终|r|cFF8B0000末|r|cFF740000之|r|cFF5D0000时|r|cFF460000”|r|cFF2E0000』|r")
        SendDtimeMsgAll(12, "|cFFFF0000『|r|cFFE30000一|r|cFFC60000切|r|cFFAA0000燃|r|cFF8E0000烧|r|cFF710000殆|r|cFF550000尽|r|cFF390000』|r")
        u:setdata("黑龙-灾厄使者")
        local dx = 1
        ac.timer(250, 16, function()
          dx = dx + 0.25
          local ax, ay = u:getxy()
          Effectcreate("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", ax, ay, 0, dx)
        end)
        local cs = 0
        local cs2 = 0
        ac.loop(1000, function()
          cs = cs + 1
          cs2 = cs2 + 1
          if cs == 6 then
            cs = 0
            u:changemaxhp(-0.01 * u:getmaxhp())
            u:changedata("固定伤害", 1500)
          end
          if cs2 == 6 then
            cs2 = 0
            local x, y = u:getxy()
            local txsh = 100000
            if Hero_Equip_WeaponBoolean[sy] then
              txsh = GetData(Hero_Equip_WeaponType[sy], "基础伤害")
            end
            ac.timer(100, 5, function()
              Effectcreate("war3mapImported\\[TXNew]021.mdl", x, y, 0, 8)
            end)
            for _, xq in ac.selector():in_rangexy(x, y, 600):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              DamageUnit({
                bj = "黑龙灾厄使者",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 4,
                type = "物理",
                isvest = false,
                isattack = false,
                isnoarmor = false,
                element = "无",
                extradata = {"近战"}
              })
              xq:settimedata("灾厄使者残废", 2)
            end
          end
        end)
      end
    end
  end
  if dt and u:hasdata("暗之书-吸收") and not u:hasdata("暗之书-吸收冷却") then
    dt = false
    u:settimedata("暗之书-吸收冷却", 240)
    ac.wait(240000, function()
      u:sendmessage("暗之书吸收冷却完毕")
    end)
    u:buffset(unit, 3, "无敌")
    u:effectadd("Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl", "chest", 3)
    ChangeTimeValue(Correction_Magic, sy, 0.005000000000000001, 60)
  end
  if dt and u:hasdata("狐之花嫁-决死") then
    dt = false
    u:buffset(unit, 3, "无敌")
    u:sethp(25, true)
    u:deldata("狐之花嫁-决死")
    u:effectadd("Abilities\\Spells\\Human\\ReviveHuman\\ReviveHuman.mdl")
    u:effectadd("Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl", "chest", 3)
  end
  if dt and u:hasdata("妖梦天赋-妄执剑") and not u:hasdata("妖梦-妄执剑冷却") then
    dt = false
    u:settimedata("妖梦-妄执剑冷却", 360)
    ac.wait(360000, function()
      u:sendmessage("|cFFCC0000妄执剑冷却结束|r")
    end)
    u:buffset(unit, 1, "无敌")
    u:sethp(1, true)
    u:addskill("A0HC")
    u:setcolor(102.0, 51.0, 51.0, 102.0)
    u:effectadd("Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl")
    u:effectadd("war3mapImported\\uberdarkwave.mdx")
    ac.wait(6000, function()
      u:sendmessage("|cFFCC0000妄执剑剩余三秒|r")
    end)
    ac.wait(9000, function()
      u:setcolor(255, 255, 255, 255)
      u:delskill("A0HC")
      u:sendmessage("|cFFCC0000妄执剑持续结束|r")
    end)
  end
  if dt and u:hasdata("变异判定-血武士") and not u:hasdata("血武士死抗冷却") then
    dt = false
    u:sethp(1, true)
    u:buffset(u.handle, 3, "伤害免疫")
    Effectcreate("war3mapImported\\[TX] (327).mdl", x, y)
    u:settimedata("血武士死抗冷却", 480)
    ac.wait(480000, function()
      u:sendmessage("血武士冷却完毕")
    end)
  end
  if dt and u:hasdata("轮回之廊无尽") and not u:hasdata("轮回之廊续行冷却") then
    dt = false
    u:sethp(100, true)
    u:setmp(100, true)
    u:clearbuff("all")
    u:buffset(unit, 3, "无敌")
    u:playsound(Yx_33_Alef)
    u:settimedata("轮回之廊续行冷却", 333)
    ac.wait(333000, function()
      u:sendmessage("轮回之廊续行冷却")
    end)
    u:effectadd("Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl", "chest", 3)
    u:changedata("时间点", 120)
    ChangeValue(DamageSystem_Shjc, sy, 0.0012)
    ChangeValue(DamageSystem_Shjc, sy, 0.0012)
    ChangeValue(DamageSystem_Shjc, sy, 0.0012)
    if u:getluckrandom(12) then
      ChangeValue(DamageSystem_Shjc, sy, 0.0012)
      ChangeValue(DamageSystem_Shjc, sy, 0.0012)
      ChangeValue(DamageSystem_Shjc, sy, 0.0012)
    end
  end
  if dt and u:hasdata("丛雨-神刀寄魂解放") and not u:hasdata("丛雨抵挡冷却") then
    dt = false
    u:settimedata("丛雨抵挡冷却", 360)
    ac.wait(360000, function()
      u:sendmessage("|cFF66FF99丛雨抵挡冷却完毕|r")
    end)
    PlayGlobalSound(Sound_Murasame_Skill_11)
    u:sethp(100, true)
    u:setmp(100, true)
    u:clearbuff("all")
    u:effectadd("Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl", "chest", 3)
    u:buffset(unit, 3, "无敌")
  end
  if dt and u:hasdata("索菲结缘") and not u:hasdata("索菲抵挡冷却") then
    dt = false
    local bb = getunit(Beibao[sy])
    bb:settimedata("索菲虚弱", 480)
    u:settimedata("索菲抵挡冷却", 480)
    u:sendmessage("|cFF999999索菲进入了虚弱状态|r")
    ac.wait(480000, function()
      u:sendmessage("|cFF999999索菲从虚弱中恢复过来|r")
    end)
    u:sethp(100, true)
    u:setmp(100, true)
    u:clearbuff("all")
    u:effectadd("Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl", "chest", 3)
    u:buffset(unit, 3, "无敌")
  end
  if dt and u:getdata("暗涌点数") > 0 then
    dt = false
    u:changedata("暗涌点数", -1)
    u:changedata("污染值", -100)
    u:sendmessage("|cFF6600FF暗涌|r")
    u:sethp(100, true)
    u:setmp(100, true)
    u:clearbuff("all")
    u:effectadd("Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl", "chest", 3)
    u:buffset(unit, 3, "无敌")
  end
  if dt and u:hasdata("蕾米莉亚-觉醒二") and not u:hasdata("夜王复苏冷却") and (IsTimeNight() or u:hasdata("蕾米莉亚-完全觉醒")) then
    dt = false
    u:playsound(Rmiliya_Swkj)
    if u:hasdata("变异判定-蕾米莉亚") then
      u:changedata("觉醒度", 1)
    end
    u:settimedata("夜王复苏冷却", 180)
    ac.wait(180000, function()
      if u:hasdata("蕾米莉亚-完全觉醒") then
        u:sendmessage("恶魔复苏冷却完毕")
      else
        u:sendmessage("夜王复苏冷却完毕")
      end
    end)
    u:settimedata("夜王复苏-飞行", 3)
    u:effectadd("Abilities\\Spells\\Human\\ReviveHuman\\ReviveHuman.mdl")
    u:effectadd("war3mapImported\\File00000868.mdx", "chest", 3)
    if u:hasdata("蕾米莉亚-完全觉醒") then
      u:sethp(100, true)
    else
      u:sethp(50, true)
    end
    u:setmp(100, true)
    u:clearbuff("all")
    u:effectadd("Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl", "chest", 3)
    u:buffset(unit, 3, "无敌")
  end
  if dt and u:ishasskill("A0LM") and shlx < 5 then
    u:delskill("A0LM")
    u:sethp(100, true)
    u:setmp(100, true)
    u:clearbuff("all")
    u:effectadd("Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl", "chest", 3)
    u:buffset(unit, 3, "无敌")
    u:sendmessage("|cFFB21AD9某美少女（老太婆）给你续了一条命！")
    local jl = GetRandomReal(0, 1000)
    local jd = GetRandomReal(0, 360)
    local msn = getunit(Danwei_Msn)
    x, y = msn:getxy()
    local x3, y3 = PolarXY(x, y, jl, jd)
    u:effectadd("Abilities\\Spells\\Human\\ReviveHuman\\ReviveHuman.mdl")
    u:setcolor(255, 255, 255, 155)
    SetUnitPathing(u.handle, false)
    ac.wait(3000, function()
      SetUnitPathing(u.handle, true)
      u:setcolor(255, 255, 255, 255)
    end)
  end
  if dt and u:hasdata("变异判定-见习剑巫") and not u:hasdata("神格觉醒冷却") and 3 > u:getdata("神格觉醒次数") and BossBattle then
    dt = false
    u:changedata("神格觉醒次数", 1)
    if u:getdata("神格觉醒次数") == 1 then
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 50)
    end
    u:addstr(10)
    ChangeValue(DamageSystem_Shjc, sy, 0.005)
    ChangeValue(DamageSystem_Shjc, sy, 0.005)
    ChangeValue(DamageSystem_Shjc, sy, 0.005)
    u:settimedata("神格觉醒冷却", 60)
    u:effectadd("Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl", "origin")
    u:buffset(unit, 3, "无敌")
  end
  if dt and u:hasdata("幽灵鲨-终焉之音") and u:getdata("肉斩骨断次数") > 0 then
    u:setdata("僵直时间", 0)
    u:setdata("眩晕时间", 0)
    dt = false
    u:changedata("肉斩骨断次数", -1)
    u:sendmessage("|cFF990000[幽灵鲨]肉斩骨断,剩余次数:" .. math.floor(u:getdata("肉斩骨断次数")))
    u:effectadd("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl")
    u:effectadd("war3mapImported\\texiao_xuebao.mdx")
    u:buffset(unit, 1, "无敌")
    hdzlinshiadd(u, 500 * u:getlevel())
  end
  local run = false
  if u:hasdata("变异判定-兵解之意") and sh >= u:gethp() then
    run = true
  end
  if not dt or run then
    StexiaoFunc({
      text = "决死效果触发后",
      unit = u.handle,
      u = u,
      sy = sy,
      damage = sh,
      soc = soc
    })
    if u:hasdata("变异判定-枪之恶魔") then
      u:sendmessage("|cFF990000枪之恶魔-决死规制|r")
      u:settimedata("枪之恶魔-决死限制", 360)
      ac.wait(360000, function()
        u:sendmessage("|cFF990000枪之恶魔-决死规制解除|r")
      end)
    end
    if u:hasdata("神话判定-孔瑞丽") then
      u:buffset(u.handle, 1, "绝对闪避")
    end
    if u:hasdata("变异判定-终末鸟") and u:hasdata("物品-薄暝甲") and not u:hasdata("小喙恢复冷却") then
      u:curehp(u.handle, 0, 30, 2)
      u:settimedata("小喙恢复冷却", 30)
    end
    if u:hasdata("变异判定-武神护佑") then
      u:curehp(unit, 0, 25, 3)
      u:addstr(16)
      ac.wait(60000, function()
        u:addstr(-15)
      end)
    end
    if u:hasdata("变异判定-诅咒的魔神眼") then
      u:addallstats(2)
    end
    if u:hasdata("里三天赋-永恒的梦魇") and not u:hasdata("里三-永恒的梦魇冷却") then
      u:settimedata("里三-永恒的梦魇冷却", 12)
      ChangeValue(DamageSystem_Shjc, sy, 0.012)
      u:addallstats(12)
      ChangeValue(Correction_Magic, sy, 0.0012000000000000001)
    end
    if u:hasdata("背包-艾露猫") then
      AilumaoSnd(u, "决死")
    end
    if Keyan_Yizhishuairuo then
      u:settimedata("科研模式-意志衰弱禁用决死", 180)
    end
  end
  return dt
end
