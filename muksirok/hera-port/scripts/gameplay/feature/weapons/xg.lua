-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local japi = require("jass.japi")
local message = require("jass.message")

function weaponxg1(unit, skill, sh, fw, bs, wqlx, wq)
  local u = getunit(unit)
  local sy = u.ownerid
  local mj
  local x, y = u:getxy()
  local lx = GetData(wqlx, "近战武器类型")
  if u:hasdata("变异判定-Blake") and (lx == 6 or lx == 10) then
    if u:getdata("跃影飞绫-类型") == "镰刀" then
      lx = 6
    else
      lx = 10
    end
  end
  if u:hasdata("蔷薇之刃-远程释放中") then
    x = u:getdata("蔷薇之刃-X")
    y = u:getdata("蔷薇之刃-Y")
  end
  if u:hasdata("绯村剑心-飞龙闪释放中") then
    mj = u:getdata("绯村剑心-飞龙闪释放中")
    x = GetUnitX(mj)
    y = GetUnitY(mj)
  end
  if skill == GetWpSkill("雷霆长枪") then
    x = u:getdata("雷霆长枪-X")
    y = u:getdata("雷霆长枪-Y")
  end
  if skill == GetWpSkill("万宝槌") then
    x = u:getdata("万宝槌-X")
    y = u:getdata("万宝槌-Y")
  end
  if u:hasdata("蛇百心流-蛇斩") then
    x = u:getdata("蛇斩-X")
    y = u:getdata("蛇斩-Y")
  end
  if skill == GetWpSkill("涤罪七雷") then
    x = u:getdata("涤罪七雷-X")
    y = u:getdata("涤罪七雷-Y")
  end
  if skill == GetWpSkill("潮枯") then
    x = u:getdata("潮枯-X")
    y = u:getdata("潮枯-Y")
  end
  local jd = u:getface()
  local dx = fw / GetData(wqlx, "攻击范围")
  if skill == GetWpSkill("薄暝") then
    local yx = {}
    yx[1] = EGO_Weapon_02
    yx[2] = EGO_Weapon_03
    yx[3] = EGO_Weapon_04
    u:playsound(yx[GetRandomInt(1, 3)])
    Effectcreate("5Tx\\[555]Baoming_Tx2.mdx", x, y, 1, 0.6 * dx, 0, jd + 180)
    Effectcreate("0Tx\\0Tx_Baoming (1).mdl", x, y, 1, 0.7 * dx, 0, jd)
    Effectcreate("AATX\\[AATxNew]Blood12.mdl", x, y)
    for i = 1, 6 do
      local a = 60 * i
      local jl = 200 * dx
      local x2, y2 = PolarXY(x, y, jl, a)
      Effectcreate("0Tx\\0Tx_Baoming (4).mdl", x2, y2, 0, dx)
    end
  end
  if skill == GetWpSkill("拟态") then
    u:playseensound(Sound_Nitai_01)
    Effectcreate("0Tx_Baoming111hs.mdx", x, y, 1, 0.7, 0, jd)
    Effectcreate("daoguang221.mdx", x, y, 1, 0.65, 10, jd + 180)
    Effectcreate("AATX\\[AATxNew]Blood12.mdl", x, y)
  end
  if skill == GetWpSkill("蔷薇之刃") then
    local yx = {}
    yx[1] = Sound_Weapon_01
    yx[2] = Sound_Weapon_02
    yx[3] = Sound_Weapon_03
    u:playsound(yx[GetRandomInt(1, 3)])
    for i = 1, 3 do
      local a = 120 * i
      local jl = 25 * dx
      local x2, y2 = PolarXY(x, y, jl, a)
      local tx = "Encrypt\\zk_bhxqtd_xd_dg2.mdl"
      local dtx = Effectcreate(tx, x2, y2, 0, 0.5 * dx, 80, a)
    end
  end
  if lx == 9 and skill ~= GetWpSkill("蔷薇之刃") then
    local yx = {}
    yx[1] = Sound_Weapon_01
    yx[2] = Sound_Weapon_02
    yx[3] = Sound_Weapon_03
    if skill == GetWpSkill("星辰短剑") then
      u:playsound(Sound_Tevi_Weapon)
      if u:hasdata("Tevi-强化扳手") then
        u:playsound(Sound_Tevi_Banshou)
      end
    else
      u:playsound(yx[GetRandomInt(1, 3)])
    end
    for i = 1, 6 do
      local a = 60 * i
      local jl = 50 * dx
      local x2, y2 = PolarXY(x, y, jl, a)
      local tx = "war3mapImported\\e_basicstrike_blue.mdl"
      if skill == GetWpSkill("七夜") then
        tx = "war3mapImported\\[TxNew]Sword01 (5).mdl"
      end
      local dtx = Effectcreate(tx, x2, y2, -1, dx, 80, a)
      if skill == GetWpSkill("濡湿小镰刀") then
        SetEffectColor(dtx, 102, 102, 204)
      end
      DestroyEffectLua(dtx)
    end
    if skill == GetWpSkill("业物") then
      u:changetimedata("业物增伤", 0.07, 5)
    end
  end
  if lx == 10 or skill == GetWpSkill("妖刀心渡") then
    if skill ~= GetWpSkill("涤罪七雷") and skill ~= GetWpSkill("高频村雨刀") then
      u:playsound(Sound_Katana_04)
      for i = 1, 6 do
        local a = 60 * i
        local tx = "war3mapImported\\[TxNew]Sword01 (6).mdl"
        Effectcreate(tx, x, y, 0, 1.5 * dx, 100, a)
      end
    end
    if skill == GetWpSkill("高频村雨刀") then
      u:playseensound(Wj_Yx2)
      u:effectadd("war3mapImported\\blink_1.mdx", "overhead")
      ac.wait(300, function()
        u:playseensound(Wj_Yx3)
        local x, y = u:getxy()
        Effectcreate("war3mapImported\\120.mdx", x, y, 0, 3, 1, 0, 0, 0, 0.7)
        local txsh = 0.5 * sh
        local cs = 0
        ac.loop(100, function(timer)
          cs = cs + 1
          x, y = u:getxy()
          for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            if cs == 1 then
              xq:buffset(u.handle, 1, "僵直")
              xq:effectadd("war3mapImported\\texiao_xuebao.mdx")
            end
            DamageUnit({
              bj = "高频村雨刀(额外)",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "物理",
              isvest = true,
              isattack = true,
              isnoarmor = false,
              element = "无"
            })
            xq:buffset(u.handle, 0.1, "眩晕")
          end
          if 9 <= cs then
            timer:remove()
          end
        end)
      end)
    end
    if skill == GetWpSkill("涤罪七雷") then
      u:playseensound(Sound_Thunder_02)
      u:playsound(Sound_Katana_Qilei)
      if u:hasdata("武器判定-鸣雷见") then
        local tx = Effectcreate("Abilities\\Spells\\Orc\\LightningShield\\LightningShieldTarget.mdl", x, y, 1, 2, 0, GetRandomAngle())
        SetEffectColor(tx, 158, 71, 186)
        Effectcreate("ATx\\[ATxNew]Thunder_14.mdl", x, y, 0, 1)
        Effectcreate("LeilvTx_01 (1).mdx", x, y, 2, 3, 150, GetRandomAngle())
        Effectcreate("LeilvTx_01 (2).mdx", x, y, 2, 3, 150, GetRandomAngle())
        local tx = Effectcreate("ATx\\[ATxNew]Thunder_03.mdl", x, y, -1, 2, 150, GetRandomAngle())
        SetEffectColor(tx, 158, 71, 186)
        DestroyEffectLua(tx)
        Effectcreate("ATx\\[ATxNew]Thunder_18.mdl", x, y, 0, 1)
      else
        Effectcreate("Abilities\\Spells\\Orc\\LightningShield\\LightningShieldTarget.mdl", x, y, 1, 2, 0, GetRandomAngle())
        Effectcreate("ATx\\[ATxNew]Thunder_14.mdl", x, y, 0, 1)
        Effectcreate("ATx\\[ATxNew]Daoguang_07.mdl", x, y, 2, 3, 150, GetRandomAngle())
        Effectcreate("ATx\\[ATxNew]Daoguang_07.mdl", x, y, 2, 3, 150, GetRandomAngle())
        Effectcreate("ATx\\[ATxNew]Thunder_03.mdl", x, y, 0, 2, 150, GetRandomAngle())
        Effectcreate("ATx\\[ATxNew]Thunder_18.mdl", x, y, 0, 1)
      end
    end
    if skill == GetWpSkill("都牟刈村正") then
      Effectcreate("AATX\\[AATxNew]Fire32.mdl", x, y, 0, 2 * dx)
      Effectcreate("AATX\\[AATxNew]Red07.mdl", x, y, 0)
      Effectcreate("AATX\\[AATxNew]Fire11.mdl", x, y, 0, 1, 90)
    end
    if skill == GetWpSkill("神刀-丛雨丸") then
      Effectcreate("war3mapImported\\[Murasame]01 (5).mdl", x, y, 0, 1.5 * dx)
    end
    if skill == GetWpSkill("白楼剑") then
      Effectcreate("war3mapImported\\36.mdl", x, y, 0, 1.5 * dx)
    end
    if skill == GetWpSkill("村正") then
      for i = 1, 6 do
        local a = 60 * i
        local tx = "war3mapImported\\[TxNew]Sword01 (7).mdl"
        Effectcreate(tx, x, y, 0, dx, 100, a)
      end
    end
    if skill == GetWpSkill("草薙剑") or skill == GetWpSkill("布都御魂") then
      u:playsound(LightningBolt01)
      Effectcreate("sasigay_lei.mdl", x, y, 0, 1 * dx)
      local cs = 0
      local tx = {}
      tx[1] = "war3mapImported\\[TxNew]Misaka (1).mdl"
      tx[2] = "war3mapImported\\[TxNew]Misaka (2).mdl"
      tx[3] = "war3mapImported\\[TxNew]Misaka (3).mdl"
      ac.loop(100, function(t)
        cs = cs + 1
        local a = GetRandomReal(0, 360)
        local x2, y2 = PolarXY(x, y, GetRandomReal(0, 150 * dx + 250), a)
        Effectcreate(tx[GetRandomInt(1, 3)], x2, y2, 0, 0.75 * dx)
        if cs == 10 then
          t:remove()
        end
      end)
    end
    if skill == GetWpSkill("童子切安纲") then
      u:playsound(LightningBolt01)
      Effectcreate("sasigay_lei.mdl", x, y, 0, 1 * dx)
      Effectcreate("war3mapImported\\171.mdl", x, y, 0, 1 * dx)
      for i = 1, 6 do
        local a = 60 * i
        local tx = "war3mapImported\\great lightning.mdl"
        local x2, y2 = PolarXY(x, y, 150 * dx, a)
        Effectcreate(tx, x2, y2, 0, 0.75 * dx)
      end
    end
    if skill == GetWpSkill("和泉守兼定") then
      u:playsound(Youmu_D)
      Effectcreate("war3mapImported\\[TxNew]331 (8).mdl", x, y, 0, 1 * dx)
      u:buffset(unit, 0.25, "绝对闪避")
    end
    if skill == GetWpSkill("压切长谷部") then
      Effectcreate("war3mapImported\\[TxNew]Sword01 (15).mdl", x, y, 0, 1 * dx)
      Effectcreate("war3mapImported\\[TX] (327).mdx", x, y, 0, 1 * dx)
      Effectcreate("war3mapImported\\[TxNew]Sword01 (23).mdl", x, y, 0, 1 * dx)
      u:changemaxhp(GetRandomReal(-3, -1))
    end
    if skill == GetWpSkill("鬼丸国纲") then
      Effectcreate("war3mapImported\\[TX] (1234).mdl", x, y, 0, 1 * dx)
      Effectcreate("war3mapImported\\[TxNew]Sword01 (11).mdl", x, y, 0, 0.75 * dx)
      ac.wait(300, function()
        for i = 1, 6 do
          local a = 60 * i
          local tx = "Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl"
          local x2, y2 = PolarXY(x, y, 125, a)
          Effectcreate(tx, x2, y2)
        end
      end)
      ac.wait(600, function()
        for i = 1, 12 do
          local tx = "Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl"
          local x2, y2 = PolarXY(x, y, 250, 30 * i)
          Effectcreate(tx, x2, y2)
        end
      end)
    end
    if skill == GetWpSkill("绯") then
      Effectcreate("war3mapImported\\[TxNew]Sword01 (10).mdx", x, y, 0, 2)
      Effectcreate("war3mapImported\\[TxNew]Sword01 (12).mdl", x, y, 0, 1 * dx)
    end
    if skill == GetWpSkill("邪神剑") then
      Effectcreate("war3mapImported\\[TxNew]Sword01 (13).mdl", x, y, 0, 1 * dx)
      for i = 1, 6 do
        local tx = "war3mapImported\\Texiao_Xuebao.mdx"
        local x2, y2 = PolarXY(x, y, 120, 60 * i)
        Effectcreate(tx, x2, y2)
      end
    end
    if u:hasdata("变异判定-孤狼") then
      u:playsound(Youmu_D)
      u:buffset(unit, 0.12, "绝对闪避")
    end
  end
  if lx == 11 and skill ~= GetWpSkill("史莱姆剑") and skill ~= GetWpSkill("青色怒火") and skill ~= GetWpSkill("空间之刃") and skill ~= GetWpSkill("光之剑超新星") then
    u:playsound(Sound_Katana_16)
    Effectcreate("war3mapImported\\[TxNew]Sword01 (25).mdl", x, y, 0, 1.25 * dx)
    if skill == GetWpSkill("长虹剑") then
      local a = GetRandomAngle()
      for i = 1, 4 do
        Effectcreate("Hongmao_03.mdx", x, y, 0, 2, 50, a + i * 90)
      end
      Effectcreate("Hongmao_04.mdx", x, y, 0, 1, 50)
    end
    if skill == GetWpSkill("权力之刃") then
      for i = 1, 6 do
        local x2, y2 = PolarXY(x, y, 120, 60 * i)
        Effectcreate("Abilities\\Spells\\Other\\BreathOfFrost\\BreathOfFrostMissile.mdl", x2, y2, 0.5, 1.25 * dx, 0, 60 * i)
      end
      if GetRandom100(14) then
        local x1, y1 = x, y
        local a = jd
        local tx = Effectcreate("war3mapImported\\[TX] (1348).mdl", x1, y1, -1, 3, 0, a)
        local g = CreateGroupLua()
        local cs = 0
        local cs2 = 0
        local lj = 0
        local v = 40
        ac.loop(10, function(t)
          lj = lj + v
          cs = cs + 1
          cs2 = cs2 + 1
          x1, y1 = PolarXY(x1, y1, v, a)
          japi.EXSetEffectXY(tx, x1, y1)
          if 800 <= lj then
            lj = 0
            Effectcreate("war3mapImported\\[TX] (1365).mdl", x1, y1, 0, 3)
          end
          for _, xq in ac.selector():in_rangexy(x1, y1, 325):is_enemy(unit):isnotingroup(g):ipairs() do
            xq = getunit(xq)
            xq:groupadd(g)
            DamageUnit({
              bj = "权力之刃(天斩)",
              unit = xq.handle,
              source = u.handle,
              level = 5,
              damage = 14444 + 22 * KillCount[sy],
              type = "魔力",
              isvest = true
            })
            xq:effectadd("Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl")
          end
          if not IsXYinAnyPlayRect(x1, y1) then
            DestroyEffectLua(tx)
            t:remove()
          end
        end)
      end
    end
    if skill == GetWpSkill("潮汐") then
      Effectcreate("war3mapImported\\[TxNew]Sword01 (18).mdl", x, y, 0, 1.5)
      Effectcreate("war3mapImported\\ancientexplode(blue).mdx", x, y, 0, 1.5)
      Effectcreate("war3mapImported\\[TxNew]Sword01 (22).mdl", x, y, 0, 1.5 * dx)
      for i = 1, 12 do
        local a = 30 * i
        local tx = "war3mapImported\\[ake]war3ake.com - 5467718799163621931506138.mdl"
        local x2, y2 = PolarXY(x, y, 200 * dx, a)
        Effectcreate(tx, x2, y2)
      end
    end
    if skill == GetWpSkill("轩辕剑(封)") then
      Effectcreate("war3mapImported\\[TxNew]Sword01 (20).mdl", x, y, 1, 1.5 * dx)
      Effectcreate("Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl", x, y, 0, 2)
      for i = 1, 6 do
        Effectcreate("war3mapImported\\[TxNew]Sword01 (8).mdl", x, y, 0, 2.5 * dx, 0, 60 * i)
      end
      if HeroMenu_Shenxing[sy] < 9 then
        u:losshp(u, 0, 36 - 4 * HeroMenu_Shenxing[sy])
      end
    end
    if skill == GetWpSkill("光剑") then
      Effectcreate("war3mapImported\\[TX] (945).mdl", x, y, 0, 1.5 * dx)
      Effectcreate("war3mapImported\\[TX] (967).mdl", x, y, 0, 2.5 * dx)
    end
  end
  if lx == 2 and skill ~= GetWpSkill("忴") then
    if skill ~= GetWpSkill("黑刀-夜") then
      u:playsound(Sound_Katana_17)
    end
    if skill == GetWpSkill("红城的律令") then
      u:playsound(hongxin10)
      Effectcreate("hx_daogang2.mdx", x, y, 1)
    end
    Effectcreate("war3mapImported\\[TxNew]Sword01 (25).mdl", x, y, 0, 1.25 * dx)
    if skill == GetWpSkill("黑刀-夜") then
      u:playsound(Yinxiao_Yingyan2)
      Effectcreate("war3mapImported\\[TX] (988).mdl", x, y, 0, 3.5)
      Effectcreate("war3mapImported\\[TX] (948).mdx", x, y, 0, 1 * dx)
      local gl
      if u:hasdata("变异判定-米霍克") then
        gl = 100
        u:setskillcd(skill, 2.5)
      else
        gl = 25
        u:setskillcd(skill, 5)
      end
      if u:getluckrandom(gl) then
        ac.wait(250, function()
          u:playsound(Yinxiao_Yingyan3)
          local g = CreateGroupLua()
          local cs = 0
          local x2, y2 = x, y
          ac.loop(20, function(t)
            cs = cs + 1
            x2, y2 = PolarXY(x2, y2, 180, jd)
            Effectcreate("war3mapImported\\[TX] (988).mdl", x2, y2, 0, 3.5)
            Effectcreate("war3mapImported\\[TX] (948).mdx", x2, y2, 0, 1 * dx)
            for _, xq in ac.selector():in_rangexy(x2, y2, 1200):is_enemy(unit):isnotingroup(g):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g)
              DamageUnit({
                bj = "黑刀夜(斩击)",
                unit = xq.handle,
                source = u.handle,
                damage = 1000 * u:getlevel(),
                isattack = true
              })
              xq:effectadd("war3mapimported\\texiao_xuebao.mdx")
              xq:buffset(unit, 1, "僵直")
            end
            if cs == 10 then
              t:remove()
            end
          end)
        end)
      end
    end
    if skill == GetWpSkill("诡异柴刀") then
      u:playsound(Youmu_D)
      Effectcreate("war3mapImported\\[TxNew]331 (8).mdl", x, y, 0, 1 * dx)
      Effectcreate("war3mapImported\\[TxNew]Sword01 (13).mdl", x, y, 0, 1 * dx)
      u:buffset(unit, 0.2, "绝对闪避")
      for i = 1, 6 do
        local tx = "war3mapImported\\Texiao_Xuebao.mdx"
        local x2, y2 = PolarXY(x, y, 120, 60 * i)
        Effectcreate(tx, x2, y2)
      end
      u:setdata("诡异柴刀-二段伤害", sh)
      u:changedata("诡异柴刀-切换序号", 1)
      local token = u:getdata("诡异柴刀-切换序号")
      u:banskill("S0D0")
      u:banskill("S0F9", false)
      ac.wait(2000, function()
        if u:hasdata("武器装备中判定-诡异柴刀") and token == u:getdata("诡异柴刀-切换序号") then
          u:banskill("S0F9")
          u:banskill("S0D0", false)
        end
      end)
    end
    if skill == GetWpSkill("斩机刀-那由他") then
      Effectcreate("war3mapImported\\[TxNew]Sword002 (1).mdx", x, y, 0, 1 * dx)
      Effectcreate("war3mapImported\\[TxNew]Sword002 (2).mdx", x, y, 0, 2 * dx)
      Effectcreate("war3mapImported\\[TxNew]Sword01 (23).mdl", x, y, 0, 1 * dx)
    end
    if skill == GetWpSkill("灰狐刀") then
    end
  end
  if skill == GetWpSkill("天翼种之镰") then
    u:playsound(Sound_Katana_16)
    Effectcreate("effect\\e3b59cb56b103304.mdl", x, y, 0, 3.5 * dx, 0, jd)
  end
  if skill == GetWpSkill("青色怒火") then
    u:banskill("A0AL", false)
    u:banskill("A0AJ")
    ac.wait(500, function()
      u:banskill("A0AL")
      u:banskill("A0AJ", false)
    end)
    u:playsound(bac394)
    local dangle = GetRandomAngle()
    local height = GetRandomReal(100, 200)
    EffectcreateArgs({
      effect = "Texiao_Amiya_07.mdx",
      x = x,
      y = y,
      time = 0.5,
      height = height - 25,
      zxz = dangle + 28,
      xxz = GetRandomReal(0, 50),
      animespeed = 1
    })
    EffectcreateArgs({
      effect = "Texiao_Amiya_07.mdx",
      x = x,
      y = y,
      time = 0.5,
      height = height - 25,
      zxz = dangle - 28,
      xxz = GetRandomReal(-100, 0),
      animespeed = 1
    })
    EffectcreateArgs({
      effect = "Texiao_Amiya_04.mdx",
      x = x,
      y = y,
      time = 0.5,
      height = height,
      zxz = dangle + 28,
      xxz = GetRandomReal(0, 50),
      animespeed = 1
    })
    EffectcreateArgs({
      effect = "Texiao_Amiya_04.mdx",
      x = x,
      y = y,
      time = 0.5,
      height = height,
      zxz = dangle - 28,
      xxz = GetRandomReal(0, 50),
      animespeed = 1
    })
    Effectcreate("Texiao_Amiya_09.mdx", x, y, 0, 2, 150, dangle, 0, 0, 2)
    Effectcreate("Dust_001.mdx", x, y, 0, 2, 0, GetRandomAngle())
  end
  if skill == GetWpSkill("空间之刃") or skill == GetWpSkill("光之剑超新星") then
    u:playsound(SE036)
    Effectcreate("war3mapImported\\[TX] (945).mdl", x, y, 0, 1.5 * dx)
    Effectcreate("war3mapImported\\[TX] (967).mdl", x, y, 0, 2.5 * dx)
    local max = fw / 150
    if max <= 1 then
      max = 1
    end
    for i = 1, max do
      local a = GetRandomReal(0, 360)
      for j = 1, 2 do
        a = a + 180
        local x2, y2 = PolarXY(x, y, 150 * i, a)
        local tx = Effectcreate("war3mapImported\\Big_ICM_Blue.mdl", x2, y2, -1, 2.5)
        local cs = 0
        ac.loop(10, function(t)
          cs = cs + 1
          a = a + 10
          x2, y2 = PolarXY(x, y, 150 * i, a)
          japi.EXSetEffectXY(tx, x2, y2)
          if cs == 24 then
            DestroyEffectLua(tx)
            t:remove()
          end
        end)
      end
    end
  end
  if skill == GetWpSkill("史莱姆剑") then
    u:buffset(unit, 0.3, "绝对闪避")
    u:playsound(Sound_Katana_16)
    for i = 1, 4 do
      local tx = "A (72).mdx"
      Effectcreate(tx, x, y, 0, 6.4125000000000005, -375, i * 90)
    end
    u:changedata("史莱姆剑-切换序号", 1)
    local token = u:getdata("史莱姆剑-切换序号")
    u:banskill("S0E0")
    u:banskill("S0E1", false)
    ac.wait(2000, function()
      if u:hasdata("武器判定-史莱姆剑") and token == u:getdata("史莱姆剑-切换序号") then
        u:banskill("S0E1")
        u:banskill("S0E0", false)
      end
    end)
  end
  if skill == GetWpSkill("潮枯") then
    u:buffset(unit, 0.25, "绝对闪避")
    local x2, y2 = u:getxy()
    Effectcreate("Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl", x, y)
    Effectcreate("Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl", x2, y2)
    u:setxy(x, y)
    Effectcreate("war3mapImported\\3.26.130 (9).mdl", x, y, 0, 1.25 * dx)
    Effectcreate("war3mapImported\\3.26.130 (11).mdl", x, y, 0, 1.25 * dx)
    Effectcreate("war3mapImported\\3.26.130 (12).mdl", x, y, 0, 1.25)
  end
  if skill == GetWpSkill("铁碎牙") then
    if GetRandom100(30) then
      local txsh = 12222 + 1111 * u:getlevel()
      Effectcreate("Abilities\\Spells\\Other\\Tornado\\TornadoElementalSmall.mdl", x, y, 0, 2)
      local tx = Effectcreate("effect\\2212\\Tx_Jg_30 (9).mdl", x, y)
      local a3 = jd - 22.5
      for i = 1, 5 do
        a3 = a3 + 7.5
        local a2 = a3
        local x2, y2 = x, y
        local g = CreateGroupLua()
        local cs = 0
        local cs2 = 0
        ac.loop(30, function(t)
          cs = cs + 1
          cs2 = cs2 + 1
          x2, y2 = PolarXY(x2, y2, 100, a2)
          if cs2 == 2 then
            cs2 = 0
            local tx2 = Effectcreate("war3mapImported\\az_jugg_e1.mdx", x2, y2, 0.6, 1, 0, a2, 0, -60)
            SetEffectSize(tx2, cs * 0.2, 1, 1)
            ac.wait(500, function()
              SetEffectActSpeed(tx2, 10)
            end)
          end
          for _, xq in ac.selector():in_rangexy(x2, y2, 150):is_enemy(unit):isnotingroup(g):ipairs() do
            xq = getunit(xq)
            xq:groupadd(g)
            DamageUnit({
              bj = "铁碎牙",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              isattack = true
            })
          end
          if cs == 30 then
            DestroyEffectLua(tx)
            t:remove()
          end
        end)
      end
    end
    if GetRandom100(25) then
      local a2 = GetRandomReal(0, 360)
      local cs = 0
      local cs2 = 0
      local x2, y2 = x, y
      local g = CreateGroupLua()
      local jl = 100
      local jl2 = 100
      local x3, y3
      ac.loop(30, function(t)
        cs = cs + 1
        cs2 = cs2 + 1
        jl = jl + 75
        x2, y2 = PolarXY(x, y, jl, jd)
        if cs2 == 3 then
          cs2 = 0
          Effectcreate("effect\\2212\\Tx_Jg_30 (3).mdl", x2, y2, 0, 3)
        end
        a2 = a2 + 30
        jl2 = jl2 + 12
        x3, y3 = PolarXY(x2, y2, jl2, a2)
        Effectcreate("effect\\2212\\Tx_Jg_30 (6).mdl", x3, y3)
        for _, xq in ac.selector():in_rangexy(x3, y3, 250):is_enemy(unit):isnotingroup(g):ipairs() do
          xq = getunit(xq)
          xq:groupadd(g)
          DamageUnit({
            bj = "铁碎牙",
            unit = xq.handle,
            source = u.handle,
            damage = sh,
            isattack = true
          })
        end
        if cs == 50 then
          t:remove()
        end
      end)
    end
    if GetRandom100(15) then
      local txsh = 24444 + 2222 * u:getlevel()
      Effectcreate("effect\\2212\\Tx_Jg_30 (7).mdl", x, y, 0, 2)
      local a2 = u:getface()
      local a3 = a2 + 90
      ac.timer(20, 20, function()
        local jl2 = GetRandomReal(-600, 600)
        local x2, y2 = PolarXY(x, y, jl2, a3)
        local jl3 = GetRandomReal(-600, 0)
        local x3, y3 = PolarXY(x2, y2, jl3, a2)
        unifycreate({
          owner = u.handle,
          model = "effect\\2212\\Tx_Jg_30 (15).mdl",
          modelname = "金刚枪破",
          modelsize = 1,
          height = 0,
          damage = txsh,
          damagetype = 1,
          x = x3,
          y = y3,
          time = 0.9,
          speed = 300,
          volume = 125,
          angle = a2,
          angleoffset = 0,
          attenua = 1,
          attenuacount = 1,
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
              mj:changedata("弹幕-射速", 300)
            end
          end,
          hitfunc = function(mj, damage)
            return damage
          end,
          hitbeforefunc = function(mj, xq, damage2)
          end,
          hitafterfunc = function(mj, xq, damage2)
            if xq:getdata("金刚枪破叠加层数") < 10 then
              xq:changetimedata("怪物-额外受伤", 0.02, 10)
              xq:changetimedata("金刚枪破叠加层数", 1, 10)
            end
          end,
          endfunc = function(mj)
            local dx, dy = mj:getxy()
            Effectcreate("effect\\2212\\Tx_Jg_30 (13).mdl", dx, dy, 0, 1, 0, a2)
          end
        })
      end)
    end
    if GetRandom100(10) then
      local a = u:getface()
      local txsh = 24444 + 2222 * u:getlevel()
      local jl = 100
      local cs3 = 0
      ac.loop(20, function(timer)
        cs3 = cs3 + 1
        local a2 = a + GetRandomReal(-15, 15)
        local dx, dy = PolarXY(x, y, 800, a2)
        local tx = Effectcreate("war3mapImported\\zhanji-black.mdx", dx, dy, -1, 1, 0, a2)
        SetEffectSize(tx, 3, 1.5, 1)
        DestroyEffectLua(tx)
        local tx = Effectcreate("war3mapImported\\47.mdl", x, y, -1, 1.5, 200, a2, -90)
        SetEffectSize(tx, 1.5, 1, 1)
        local x2 = x
        local y2 = y
        local cs = 0
        local cs2 = 0
        local g = CreateGroupLua()
        ac.loop(20, function(timer2)
          cs = cs + 1
          cs2 = cs2 + 1
          x2, y2 = PolarXY(x2, y2, jl, a2)
          SetEffectXY(tx, x2, y2)
          if cs2 == 3 then
            GroupClearLua(g)
            cs2 = 0
            if GetRandom100(25) then
              EffectcreateArgs({
                effect = "war3mapImported\\zhanji-black.mdx",
                x = x2,
                y = y2,
                size = GetRandomReal(1, 3),
                height = GetRandomReal(500, 1500),
                zxz = GetRandomAngle(),
                xxz = GetRandomAngle(),
                yxz = GetRandomAngle(),
                animespeed = GetRandomReal(1, 2)
              })
            end
            if GetRandom100(4) then
              EffectcreateArgs({
                effect = "war3mapImported\\176.mdl",
                x = x2,
                y = y2,
                time = 7,
                size = GetRandomReal(0.5, 1),
                zxz = GetRandomAngle()
              })
              if GetRandom100(50) then
                EffectcreateArgs({
                  effect = "war3mapImported\\176.mdl",
                  x = x2,
                  y = y2,
                  time = 7,
                  size = GetRandomReal(0.5, 1),
                  zxz = GetRandomAngle()
                })
              end
            end
          end
          for _, xq in ac.selector():in_rangexy(x2, y2, 200):is_enemy(u.handle):isnotingroup(g):ipairs() do
            xq = getunit(xq)
            xq:groupadd(g)
            DamageUnit({
              bj = "铁碎牙",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "灵力",
              isvest = false,
              isattack = true,
              isnoarmor = false,
              element = "暗",
              extradata = {""}
            })
          end
          if cs == 60 then
            DestroyEffectLua(tx)
            timer2:remove()
          end
        end)
        if cs3 == 5 then
          timer:remove()
        end
      end)
    end
  end
  if skill == GetWpSkill("撬棍") or skill == GetWpSkill("物理学圣剑") then
    local size = 1
    if skill == GetWpSkill("物理学圣剑") then
      size = 2
    end
    Effectcreate("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x, y, 0, size)
    if u:hasdata("羁绊判定-CQC超人") then
      u:buffset(u.handle, 0.25, "绝对闪避")
      u:setskillcd("A1IR", 1.5)
      u:setskillcd("A08H", 2)
      if not u:hasdata("CQC超人-位移") then
        u:effectadd("Abilities\\Spells\\Undead\\OrbOfDeath\\AnnihilationMissile.mdl", "chest", 0.5)
        if not u:hasdata("CQC超人-位移冷却") then
          u:settimedata("CQC超人-位移冷却", 1)
          u:settimedata("CQC超人-位移", 0.5)
        end
      end
    end
  end
  if skill == GetWpSkill("雷霆长枪") then
    Effectcreate("effect\\BOSS\\BOSS_Wst (7).mdl", x, y, 0, 3)
    PlayGlobalSound(BOSS_Wst_12)
  end
  if skill == GetWpSkill("万宝槌") then
    local ddx, ddy = u:getxy()
    u:buffset(u.handle, 0.5, "暂停")
    u:buffset(u.handle, 0.5, "无敌")
    u:buffset(u.handle, 0.5, "伤害免疫")
    Effectcreate("war3mapImported\\bbb.mdl", ddx, ddy)
    Effectcreate("Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl", ddx, ddy)
    unitjump({
      unit = u.handle,
      time = 0.5,
      distance = DistanceXY(ddx, ddy, x, y),
      height = 300,
      angle = AngleXY(ddx, ddy, x, y),
      isfly = true
    })
    u:losshp(u, 0, 7)
    if not u:hasdata("万宝槌-梦幻许愿") then
      u:changemaxhp(-(1 + GetRandomReal(0, 0.01) * u:getmaxhp()))
    else
      u:setdata("万宝槌-梦幻格挡")
      local cs = 0
      ac.loop(1000, function(timer)
        cs = cs + 1
        if not u:hasdata("万宝槌-梦幻格挡") or 15 <= cs then
          u:deldata("万宝槌-梦幻格挡")
          timer:remove()
        end
      end)
    end
    ac.wait(500, function()
      u:setdata("位移点X", x)
      u:setdata("位移点Y", y)
      Effectcreate("war3mapImported\\qiu_wbctx.mdx", x, y, 0, 1)
    end)
    if not u:hasdata("万宝槌许愿冷却") and u:getluckrandom(0.5 * u:getdata("幸运")) then
      u:sendmessage("|cFFFFFF33万宝槌轻轻晃动了起来似乎想倾听你的愿望 你决定对它许愿?(20秒内输入相应文本)\n①力量  ②速度  ③智慧|r")
      u:settimedata("万宝槌许愿冷却", 60)
      u:settimedata("万宝槌许愿", 20)
    end
    if not u:hasdata("万宝槌大许愿冷却") and u:getluckrandom(1) and u:getdata("幸运") >= 22 then
      u:sendmessage("|cFFFFFF66万宝槌突然脱离了你的手心漂浮在空中开始剧烈的摇晃了起来!\n你有一种强烈的预感你的愿望即将实现!\n你决定许愿(60秒内输入以下其一 每个事件唯一):\n①这就是最强的力量吗\n②我就是新世界的卡密\n③这世上的财宝")
      u:settimedata("万宝槌大许愿冷却", 600)
      u:settimedata("万宝槌大许愿", 60)
    end
    if GetRandom100(2) then
      u:chat("盖亚——！！！！！！！！")
      if GetRandom100(50) then
        PlayGlobalSound(Sound_Wbc_11)
      else
        PlayGlobalSound(Sound_Wbc_12)
      end
      ac.wait(2000, function()
        PlayBGM({
          bgm = BGM_Wbc_1,
          time = 90,
          ID = 66,
          unit = u.handle
        })
        songtext({
          text = {
            {
              starttime = 4.7,
              str = "努力拼搏 直至极限"
            },
            {
              starttime = 10.2,
              str = "坚持不懈 直到最后"
            },
            {
              starttime = 15.9,
              str = "当危机接着危机"
            },
            {
              starttime = 18.6,
              str = "危机接踵而至之时"
            },
            {
              starttime = 22.8,
              str = "希望奥特曼在这里！",
              time = 4.4
            },
            {
              starttime = 28.8,
              str = "只要相信自己的力量 勇往直前"
            },
            {
              starttime = 34.2,
              str = "你定能把握勇气之光"
            },
            {
              starttime = 39.5,
              str = "切勿骄傲自满 这是不好的念头"
            },
            {
              starttime = 45.3,
              str = "直到用尽最后一丝力量"
            },
            {
              starttime = 50.4,
              str = "绝不由此后退一步"
            },
            {
              starttime = 56.8,
              str = "努力拼搏 直到极限"
            },
            {
              starttime = 62.8,
              str = "坚持不懈 直至最后"
            },
            {
              starttime = 68.4,
              str = "当竭尽全力 疲惫不堪"
            },
            {
              starttime = 71,
              str = "终究还是束手无策之际"
            },
            {
              starttime = 75.1,
              str = "希望奥特曼在这里！"
            },
            {
              starttime = 79.6,
              str = "盖亚奥特曼！",
              time = 5
            }
          },
          color = {"FF3366FF", "FFCC0000"}
        })
      end)
    else
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
      local sjs = GetRandomInt(1, 10)
      u:playsound(yxz[sjs].yx)
      u:chat(yxz[sjs].str)
    end
  end
  if skill == GetWpSkill("破戒刀") then
    u:playsound(Sound_Katana_04)
    for i = 1, 6 do
      local tx = "war3mapImported\\[TxNew]Sword01 (6).mdl"
      Effectcreate(tx, x, y, 0, 1.5 * dx, 100, 60 * i)
      tx = "war3mapImported\\specialanimedustwave.mdx"
      Effectcreate(tx, x, y, 0, 3 * dx, 100, 60 * i)
    end
    if GetRandom100(33) then
      u:setskillcd(skill, 0.1)
    end
  end
  if skill == GetWpSkill("辉煌耀世") then
    u:playsound(Sound_Katana_20)
    if u:isgirl() then
      u:playsound(Sound_Huihuangyaoshi)
    end
    local max = fw / 200
    local a = GetRandomReal(0, 360)
    for i = 1, max do
      Effectcreate("war3mapImported\\effect_[spell]xinzhao_r2.mdl", x, y, 0, 0.5 * i, 0, a)
    end
  end
  if skill == S2ID("A0AG") then
    u:playsound(bac265)
    local max = 3.0
    local a = GetRandomReal(0, 360)
    local tx = Effectcreate("Angela_Shao05.mdx", x, y, -1, 2)
    SetEffectColor(tx, 255, 0, 0)
    DestroyEffectLua(tx)
    for i = 1, max do
      local tx = Effectcreate("war3mapImported\\effect_[spell]xinzhao_r2.mdl", x, y, -1, 0.5 * i, 0, a, 0, 0, 0.5)
      SetEffectColor(tx, 255, 0, 0)
      DestroyEffectLua(tx)
    end
  end
  if skill == GetWpSkill("雪霞狼") then
    Effectcreate("war3mapimported\\aquaspike.mdl", x, y, 0, 1 * dx)
    Effectcreate("war3mapImported\\[TxNew]Sword01 (17).mdl", x, y, 0, 2 * dx)
    ac.wait(500, function()
      Effectcreate("Tx_Jzxc_Dalei.mdl", x, y, 0, 2)
      for _, xq in ac.selector():in_rangexy(x, y, 1200):is_enemy(unit):ipairs() do
        xq = getunit(xq)
        DamageUnit({
          bj = "雪霞狼",
          unit = xq.handle,
          source = u.handle,
          damage = 0.4 * sh,
          type = "魔力",
          isvest = true,
          element = "雷",
          isnoarmor = false
        })
      end
    end)
  end
  if skill == GetWpSkill("地狱の轮祸") then
    Effectcreate("AATX\\[AATxNew]Fire07.mdl", x, y, 0, 1 * dx)
    Effectcreate("AATX\\[AATxNew]Katana38.mdl", x, y, 0, 6 * dx, 0, GetRandomReal(0, 360))
    u:playsound(Sound_AA__11_u)
  end
  if skill == GetWpSkill("银冰之枪") then
    Effectcreate("AATX\\[AATxNew]Ice01_C.mdl", x, y)
    Effectcreate("ATX\\[ATxNew]Ice_02_C.mdl", x, y, 0, 2 * dx, 0, GetRandomReal(0, 360))
    u:playsound(Sound_AA__11_u)
  end
  if skill == GetWpSkill("棒球棍") then
    if u:hasdata("变异判定-全垒打") then
      u:setskillcd(skill, 1.5)
    else
      u:setskillcd(skill, 3)
    end
  end
  if skill == GetWpSkill("镰刀") then
    local hp = 0
    for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(unit):ipairs() do
      hp = hp + 1
    end
    u:curehp(unit, hp, 0, 2)
  end
  if u:hasdata("变异判定-忍野忍") and not u:hasdata("忍野忍-E语音冷却") then
    u:settimedata("忍野忍-E语音冷却", 3)
    local yx = {}
    yx[1] = Sound_Ryr_E1
    yx[2] = Sound_Ryr_E2
    yx[3] = Sound_Ryr_E3
    u:playsound(yx[GetRandomInt(1, 3)])
  end
  if u:hasdata("武器判定-妖刀心渡") then
    local bsrfw = 650
    local dx2 = bsrfw / 250
    local txdw = u:createunit("u04U", x, y, GetRandomAngle())
    SetUnitScale(txdw.handle, dx2, dx2, dx2)
    txdw:timetoremove(2)
    local bsr = 0.5 * sh
    for _, xq in ac.selector():in_rangexy(x, y, bsrfw):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      DamageUnit({
        bj = "妖刀心渡",
        unit = xq.handle,
        source = u.handle,
        damage = bsr,
        level = 4,
        type = "物理",
        isvest = true,
        isattack = true
      })
    end
    if not u:hasdata("妖刀心渡-特效冷却") then
      u:settimedata("妖刀心渡-特效冷却", 5)
      local txsh = u:getdata("甜食值") + 25 * u:getallattri()
      for _, xq in ac.selector():in_rangexy(x, y, bsrfw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        for i = 1, 12 do
          DamageUnit({
            bj = "妖刀心渡附伤",
            unit = xq.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "物理",
            isvest = true
          })
        end
      end
    end
  end
  if u:hasdata("变异判定-蛇百心流") and lx == 10 and not u:hasdata("蛇百心流-蛇斩") and not u:hasdata("苦行僧客-刀影释放中") then
    ac.wait(1, function()
      if u:islocal() then
        local ddx, ddy = message.mouse()
        message.order_point(YDWEAbilityId2OrderId("A1P2"), ddx, ddy)
      end
    end)
  end
  if u:hasdata("变异判定-苦行僧客") and (lx == 2 or lx == 10 or lx == 11) and not u:hasdata("苦行僧客-刀影") and not u:hasdata("苦行僧客-刀影释放中") and not u:hasdata("蛇百心流-蛇斩") then
    u:setdata("苦行僧客-刀影")
    ac.wait(500, function()
      if u:hasdata("苦行僧客-刀影") then
        GroupClearLua(Group_Daoying)
      end
      u:deldata("苦行僧客-刀影")
    end)
  end
  if HasData(wq, "法琦尔-恶魔制造") then
    Effectcreate("war3mapImported\\Tx_Niuqu_Fqe_02.mdl", x, y, 0, 2, 0, GetRandomReal(0, 360))
  end
  if u:hasdata("变异判定-终末鸟") then
    if (not u:hasdata("终末鸟-惩戒冷却") or u:hasdata("终末鸟-小鸟形态")) and not u:hasdata("终末鸟-小鸟形态") then
      u:settimedata("终末鸟-惩戒冷却", 8)
    end
    local bsrfw = 1000
    local bsr = 15 * u:getallattri()
    Effectcreate("0Tx\\0Tx_Baoming (7).mdl", x, y, 0, 2.2)
    for _, xq in ac.selector():in_rangexy(x, y, bsrfw):is_enemy(unit):allow_unify():ipairs() do
      xq = getunit(xq)
      if not xq:hasdata("系统-弹幕") then
        DamageUnit({
          bj = "终末鸟(近战武器附伤)",
          unit = xq.handle,
          source = u.handle,
          damage = bsr,
          type = "物理",
          isvest = true
        })
        xq:effectadd("war3mapImported\\texiao_xuebao.mdx")
        xq:buffset(unit, 1, "眩晕")
      else
        xq:setdata("弹幕-生命值", 0)
      end
    end
  end
  if u:hasdata("变异判定-千子村正") and not u:hasdata("千子村正-试剑术冷却") then
    local dx2 = fw / 400
    if dx2 <= 1 then
      dx2 = 1
    end
    Effectcreate("AATX\\[AATxNew]Fire07.mdl", x, y, 0, dx2)
    Effectcreate("AATX\\[AATxNew]Fire12.mdl", x, y)
    for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(unit):ipairs() do
      xq = getunit(xq)
      local lv
      if GetRandom100(10) then
        lv = 5
      else
        lv = GetRandomInt(1, 4)
      end
      DamageUnit({
        bj = "千子村正(试剑术)",
        unit = xq.handle,
        source = u.handle,
        damage = sh,
        level = lv,
        type = "魔力",
        isvest = true,
        isnoarmor = false
      })
    end
    u:settimedata("千子村正-试剑术冷却", 3)
  end
  if u:hasdata("神化判定-千子村正") and lx == 10 then
    if not u:hasdata("千子村正-二天一流") then
      u:effectadd("Abilities\\Spells\\Undead\\OrbOfDeath\\AnnihilationMissile.mdl", "chest", 0.75)
      u:settimedata("千子村正-二天一流", 0.5)
    end
    ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 200)
    ac.wait(750, function()
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -200)
    end)
  end
  if u:hasdata("变异判定-拔刀斋") and not u:hasdata("绯村剑心-飞龙闪释放中") and lx == 10 then
    if not u:hasdata("绯村剑心-飞龙闪") then
      u:effectadd("Abilities\\Spells\\Undead\\OrbOfDeath\\AnnihilationMissile.mdl", "chest", 0.5)
      if not u:hasdata("绯村剑心-双龙闪") and not u:hasdata("绯村剑心-双龙闪冷却") then
        u:settimedata("绯村剑心-双龙闪", 0.5)
      end
    end
    ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 3, 75)
    local cs = 0
    ac.loop(50, function(t)
      cs = cs + 1
      u:clearbuff("僵直")
      if cs == 15 then
        t:remove()
      end
    end)
  end
  if u:hasdata("栗山未来-拟态武器中") then
    Effectcreate("war3mapImported\\[TX] (1335).mdl", x, y, 0, 1 * dx)
    for i = 1, 6 do
      local x2, y2 = PolarXY(x, y, 120, 60 * i)
      Effectcreate("war3mapImported\\Texiao_Xuebao.mdx", x2, y2)
    end
  end
  if u:hasdata("变异判定-龙宫礼奈") then
    u:changedata("雏见泽候群症点数", 1)
  end
  if u:hasdata("变异判定-Lily安娜") and not u:hasdata("Lily安娜-不死之刃关闭") then
    local bsrfw = fw * 2
    if bsrfw <= 400 then
      bsrfw = 400
    elseif bsrfw >= 1200 then
      bsrfw = 1200
    end
    local dx2 = bsrfw / 250
    local txdw = u:createunit("u04U", x, y, GetRandomAngle())
    SetUnitScale(txdw.handle, dx2, dx2, dx2)
    txdw:timetoremove(2)
    for _, xq in ac.selector():in_rangexy(x, y, bsrfw):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      local bsr
      if xq:isnormal() then
        bsr = 0.1 * xq:getmaxhp()
      else
        bsr = 0.01 * xq:gethp()
      end
      bsr = bsr + 0.75 * sh
      DamageUnit({
        bj = "Lily安娜(屠戮不死之刃)",
        unit = xq.handle,
        source = u.handle,
        damage = bsr,
        level = 4,
        type = "物理",
        isvest = true,
        isattack = true
      })
      if GetRandom100(25) then
        xq:effectadd("Abilities\\Spells\\Orc\\EtherealForm\\SpiritWalkerChange.mdl", "origin", 1)
        xq:buffset(unit, 1, "石化")
      end
    end
  end
  if u:hasdata("炭治郎-通透世界") then
    Effectcreate("war3mapImported\\[TX] (327).mdl", x, y, 0.5, 2)
    local a = GetRandomReal(0, 360)
    local a3 = a
    local a2, a4
    local cs = 0
    local x2, y2
    ac.loop(50, function(t)
      cs = cs + 1
      a = a + 15
      a2 = a
      for i = 1, 6 do
        a2 = a2 + 60
        x2, y2 = PolarXY(x, y, 650, a2)
        Effectcreate("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl", x2, y2, 0.5, 2)
      end
      a3 = a3 - 15
      a4 = a3
      for i = 1, 6 do
        a4 = a4 + 60
        x2, y2 = PolarXY(x, y, 650, a2)
        Effectcreate("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl", x2, y2, 0.5, 2)
      end
      if cs == 6 then
        t:remove()
      end
    end)
    local txsh = 15 * u:getallattri()
    for _, xq in ac.selector():in_rangexy(x, y, 800):is_enemy(unit):ipairs() do
      xq = getunit(xq)
      DamageUnit({
        bj = "炭治郎(通透世界)",
        unit = xq.handle,
        source = u.handle,
        damage = txsh,
        type = "物理",
        isvest = true,
        isattack = true
      })
    end
  end
  if u:hasdata("遗物-雨中提琴") and lx == 11 and u:hasdata("星爆气流斩状态") then
    u:setskillcd(skill, 0.1)
  end
  if u:hasdata("十二星弹-双子座激活") and GetRandom100(10) then
    u:setskillcd(skill, 0.01)
  end
  if u:hasdata("变异判定-波风水门青年") then
    u:buffset(u.handle, 0.2, "绝对闪避")
  end
  if u:hasdata("语音-白洲梓") and not u:hasdata("近战语音播放冷却") then
    u:settimedata("近战语音播放冷却", 10)
    local yx = {}
    yx[1] = Sound_Bzz_Jz_1
    yx[2] = Sound_Bzz_Jz_2
    yx[3] = Sound_Bzz_Jz_3
    local snd = yx[GetRandomInt(1, 3)]
    u:playsndmsg({
      str = GetData(snd, "绑定台词"),
      snd = snd,
      time = GetData(snd, "语音长度"),
      colors = {
        "F3D9F0",
        "FFFEFF",
        "8A6CAE"
      },
      isignorecd = true,
      isneedseen = true
    })
  end
end

function weaponxg2(unit, skill, sh, fw, wqlx, wq, waittime)
  local u = getunit(unit)
  local sy = u.ownerid
  local mj
  local x, y = u:getxy()
  local lx = GetData(wqlx, "近战武器类型")
  if u:hasdata("变异判定-Blake") and (lx == 6 or lx == 10) then
    if u:getdata("跃影飞绫-类型") == "镰刀" then
      lx = 6
    else
      lx = 10
    end
  end
  if u:hasdata("绯村剑心-飞龙闪释放中") then
    mj = u:getdata("绯村剑心-飞龙闪释放中")
    x = GetUnitX(mj)
    y = GetUnitY(mj)
  end
  if u:hasdata("蔷薇之刃-远程释放中") then
    x = u:getdata("蔷薇之刃-X")
    y = u:getdata("蔷薇之刃-Y")
  end
  if skill == GetWpSkill("雷霆长枪") then
    x = u:getdata("雷霆长枪-X")
    y = u:getdata("雷霆长枪-Y")
  end
  if skill == GetWpSkill("万宝槌") then
    x = u:getdata("万宝槌-X")
    y = u:getdata("万宝槌-Y")
  end
  if skill == GetWpSkill("涤罪七雷") then
    x = u:getdata("涤罪七雷-X")
    y = u:getdata("涤罪七雷-Y")
  end
  if u:hasdata("蛇百心流-蛇斩") then
    x = u:getdata("蛇斩-X")
    y = u:getdata("蛇斩-Y")
  end
  local jd = u:getface()
  local kzlx = GetData(wqlx, "控制类型")
  local kz = GetData(wqlx, "控制时间")
  local dx = fw / GetData(wqlx, "攻击范围")
  waittime = waittime or 0
  if 1 < fw then
    ac.wait(waittime * 1000, function()
      if u:getdata("雏见泽候群症等级") >= 4 then
        u:setdata("礼奈失控")
        u:beenemy()
      end
      if skill == GetWpSkill("地狱の轮祸") and GetRandom100(15) and u:lossstamina(2) then
        Effectcreate("AATX\\[AATxNew]Fire16.mdl", x, y, 0, 3 * dx)
        fw = fw * 2
        sh = sh * 1.5
        u:setdata("地狱轮祸强化")
      end
      if u:hasdata("龙剑-居合强化") then
        sh = sh * 2
      end
      if u:hasdata("变异判定-流氓巨星") and not u:hasdata("流氓巨星-近战冷却") then
        u:setdata("流氓巨星-近战强化")
        if u:hasdata("变异判定-黄金体验镇魂曲") then
          u:settimedata("流氓巨星-近战冷却", 2)
        else
          u:settimedata("流氓巨星-近战冷却", 5)
        end
      end
      local g = CreateGroupLua()
      for _, mb in ac.selector():in_rangexy(x, y, fw):ipairs() do
        mb = getunit(mb)
        if (not u:hasdata("苦行僧客-刀影释放中") or not mb:isingroup(Group_Daoying)) and (not u:hasdata("蛇百心流-蛇斩") or not mb:isingroup(Group_Shezhan)) and (u:is_enemy(mb.handle) or mb:hasdata("血统判定-海豹") and unit ~= mb.handle) then
          mb:groupadd(g)
          if u:hasdata("变异判定-苦行僧客") then
            mb:groupadd(Group_Daoying)
          end
          if u:hasdata("变异判定-蛇百心流") then
            mb:groupadd(Group_Shezhan)
          end
        end
      end
      if 0 < Group_Counts(g) then
        if u:hasdata("变异判定-史朵巾") and Group_Counts(g) == 1 then
          sh = sh * 1.33
        end
        if u:hasdata("武器判定-拟态") then
          if u:getdata("拟态-血雾计数") >= 20 and not u:hasdata("尸横遍野冷却") then
            u:settimedata("尸横遍野冷却", 15)
            u:setdata("拟态-血雾计数", 0)
            sh = sh * 5
          end
          u:getdata("拟态-血雾计数获取")(3)
        end
        if HasData(wq, "法琦尔-恶魔制造") then
          sh = sh * (1 + (Correction_Magic[sy] - 1) * (0.1 + 0.01 * u:getdata("黑暗变异数量")))
        end
        if u:hasdata("德克萨斯-德克萨斯剑术") and lx == 11 then
          ac.wait(30, function()
            for i = 1, 6 do
              if GetData(u:getcountitem(i), "近战武器类型") == 11 then
                u:setskillcd("A01U", 0)
                UnitUseItem(u.handle, u:getcountitem(i))
                break
              end
            end
          end)
        end
        ForGroupLuaNew(g, function(mb)
          local sh2 = sh
          mb:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
          if skill == GetWpSkill("辉煌耀世") then
            mb:effectadd("Abilities\\Spells\\Items\\StaffOfPurification\\PurificationCaster.mdl")
          end
          if skill == GetWpSkill("薄暝") then
            mb:effectadd("0Tx\\0Tx_Baoming (5).mdl", "chest")
          end
          if skill == GetWpSkill("天翼种之镰") then
            mb:effectadd("effect\\78061ac646450b87.mdl", "chest")
          end
          if skill == GetWpSkill("潮枯") then
            local sh3 = sh * (1 + 0.01 * GetData(wq, "潮枯-悲歌计数"))
            for i = 1, 3 do
              if GetRandom100(33) then
                sh2 = sh2 + sh3
              end
            end
          end
          if skill == GetWpSkill("潮汐") then
            for i = 1, 3 do
              if GetRandom100(33) then
                sh2 = sh2 + sh
              end
            end
          end
          if skill == GetWpSkill("武士刀") and GetRandom100(50) then
            sh2 = 2 * sh2
            mb:effectadd("Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl", "chest")
          end
          if u:hasdata("变异判定-龙宫礼奈") then
            local max = 1 + 0.02 * u:getlevel()
            if lx == 2 or lx == 3 then
              max = max + 1 + 0.02 * u:getlevel()
            end
            if u:ishasitem(Weapons["柴刀"]) then
              max = max + 1 + 0.01 * u:getlevel()
            end
            sh2 = sh2 + GetRandomReal(0, max) * sh
          end
          if skill == GetWpSkill("邪神剑") and GetRandom100(50) then
            sh2 = sh2 * (3.5 + 0.0025 * KillCount[sy])
            mb:effectadd("Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl", "chest")
          end
          if skill == GetWpSkill("战斧") then
            local z = 2
            if mb:isnormal() then
              z = 5
            elseif mb:isboss() then
              z = 0.5
            end
            LossHpUnit({
              u = u,
              tg = mb,
              damage = 0,
              perhp = 0,
              maxhp = z,
              bj = "[生命损耗]战斧"
            })
          end
          if skill == GetWpSkill("撬棍") then
            if GetRandom100(5) then
              local z = 8
              if mb:isnormal() then
                z = 100
              elseif mb:isboss() then
                z = 2
              end
              LossHpUnit({
                u = u,
                tg = mb,
                damage = 0,
                perhp = 0,
                maxhp = z,
                bj = "[生命损耗]撬棍"
              })
            end
            if u:hasdata("羁绊判定-CQC超人") then
              LossHpUnit({
                u = u,
                tg = mb,
                damage = 0,
                perhp = 0,
                maxhp = 1,
                bj = "[生命损耗]CQC超人"
              })
            end
          end
          if skill == GetWpSkill("物理学圣剑") then
            if GetRandom100(13) then
              local z = 8
              if mb:isnormal() then
                z = 100
              elseif mb:isboss() then
                z = 2
              end
              LossHpUnit({
                u = u,
                tg = mb,
                damage = 0,
                perhp = 0,
                maxhp = z,
                bj = "[生命损耗]物理学圣剑"
              })
            end
            if u:hasdata("羁绊判定-CQC超人") then
              LossHpUnit({
                u = u,
                tg = mb,
                damage = 0,
                perhp = 0,
                maxhp = 1,
                bj = "[生命损耗]CQC超人"
              })
            end
          end
          if skill == GetWpSkill("万宝槌") then
            u:setdata("系统-本次伤害无视伤害抗性")
            local dis = DistanceBetweenUnits(mb.handle, u.handle)
            if 300 <= dis then
              sh2 = sh2 * 0.5
              mb:buffset(u.handle, 0.5, "眩晕")
            else
              mb:buffset(u.handle, 3, "眩晕")
              unitmove({
                unit = mb.handle,
                time = 0.5,
                distance = 400,
                angle = AngleBetweenUnits(u.handle, mb.handle)
              })
            end
            mb:effectadd("Abilities\\Spells\\Items\\StaffOfPurification\\PurificationCaster.mdl", "origin")
            ac.wait(10, function()
              if not mb:isalive() and u:getluckrandom(4) then
                local ddx, ddy = mb:getxy()
                CreateItemLua("I00X", ddx, ddy)
              end
            end)
          end
          if lx == 8 and u:hasdata("圣白莲-只是兴趣使然") and not mb:hasdata("系统-拳杀敌判定") then
            mb:settimedata("系统-拳杀敌判定", 0.1)
            ac.wait(100, function()
              if not mb:isalive() then
                u:changedata("系统-杀敌数量-拳系", 1)
                ChangeValue(Correction_Jzsh, sy, 1.0E-4)
                ChangeValue(Correction_Weapon_Quan, sy, 0.002)
              end
            end)
          end
          if lx == 10 then
            if u:hasdata("变异判定-龙剑") then
              u:setdata("龙剑-破抗强化")
            end
            if u:hasdata("变异判定-蛇百心流") then
              u:setdata("蛇百心流-蛇斩破抗")
            end
          end
          if skill == GetWpSkill("天翼种之镰") and not u:hasdata("天翼镰刀判定") then
            u:settimedata("天翼镰刀判定", 0.03)
          end
          if u:hasdata("变异判定-鬼灭之刃") then
            ac.wait(100, function()
              if not mb:isalive() then
                u:changedata("鬼灭之刃杀敌", 1)
                if u:hasdata("变异判定-炭治郎") then
                  ChangeValue(DamageSystem_Shjc, sy, 1.0E-4)
                end
              end
            end)
          end
          if skill == GetWpSkill("压切长谷部") then
            local change = 0
            if mb:isnormal() then
              change = -0.1 * mb:getmaxhp()
            elseif mb:isboss() then
              change = -0.01 * mb:getmaxhp()
            else
              change = -0.05 * mb:getmaxhp()
            end
            mb:changemaxhp(change)
            if 5 >= mb:getperhp() and mb:isboss() and not mb:hasdata("天下布武已经释放") then
              mb:setdata("天下布武已经释放")
              MovieAct["天下布武"](u, mb)
            end
          end
          if skill == GetWpSkill("空间之刃") then
            mb:effectadd("war3mapImported\\[TX] (1122).mdl")
            local change = 0
            if mb:isboss() then
              change = 0.011 * mb:gethp()
            else
              change = 0.11 * mb:gethp()
            end
            LossHpUnit({
              u = u,
              tg = mb,
              damage = change,
              perhp = 0,
              maxhp = 0,
              bj = "[生命损耗]空间之刃"
            })
          end
          if skill == GetWpSkill("潮枯") then
            u:setdata("属性伤害", "水")
          end
          if skill == GetWpSkill("雷霆长枪") or skill == GetWpSkill("涤罪七雷") or skill == GetWpSkill("布都御魂") or skill == GetWpSkill("童子切安纲") then
            u:setdata("属性伤害", "雷")
          end
          if skill == GetWpSkill("地狱の轮祸") or skill == S2ID("A0AG") or u:hasdata("环直-余火持续时间") then
            u:setdata("属性伤害", "火")
          end
          if HasData(wq, "法琦尔-恶魔制造") then
            u:setdata("属性伤害", "暗")
          end
          if u:hasdata("琪露诺-极地冰刃") or skill == GetWpSkill("银冰之枪") then
            u:setdata("属性伤害", "冰")
          end
          if skill == GetWpSkill("灰狐刀") or skill == GetWpSkill("黑刀-夜") then
            u:setdata("伤害阶级", 2)
          end
          if skill == GetWpSkill("斩机刀-那由他") then
            u:setdata("伤害阶级", 4)
          end
          if skill == GetWpSkill("量子机神剑") or u:hasdata("地狱轮祸强化") then
            u:setdata("伤害阶级", 5)
          end
          if u:hasdata("栗山未来-拟态武器中") then
            u:setdata("栗山未来拟态武器吸血")
            mb:effectadd("war3mapImported\\[TxNew1]001.mdl")
          end
          if skill == GetWpSkill("镰刀") then
            u:setdata("镰刀武器吸血")
          end
          if u:hasdata("变异判定-立华奏") then
            u:setdata("系统-本次伤害无视伤害闪避")
          end
          if skill == GetWpSkill("绯") then
            u:setdata("绯双重最终")
          end
          local type = "物理"
          local atk = true
          local noarm = false
          if skill == GetWpSkill("权力之刃") or skill == GetWpSkill("潮枯") or u:hasdata("栗山未来-拟态武器中") then
            type = "魔力"
          end
          if skill == GetWpSkill("量子机神剑") or skill == GetWpSkill("光之剑超新星") then
            type = "能量"
          end
          if skill == GetWpSkill("空间之刃") then
            type = "反物质"
            if GetRandom100(33) then
              noarm = true
            end
          end
          if skill == GetWpSkill("童子切安纲") then
            type = "灵力"
          end
          if skill == GetWpSkill("万宝槌") then
            type = "震荡"
          end
          u:setdata("伤害系统-近战继承", 2)
          if skill == GetWpSkill("史莱姆剑") then
            noarm = true
          end
          local damage = sh2
          if skill == GetWpSkill("史莱姆剑") then
            damage = damage * 0.5
          end
          DamageUnit({
            bj = "近战武器伤害",
            unit = mb.handle,
            source = u.handle,
            damage = damage,
            type = type,
            isattack = atk,
            isnoarmor = noarm
          })
          if skill == GetWpSkill("史莱姆剑") then
            DamageUnit({
              bj = "近战武器伤害",
              unit = mb.handle,
              source = u.handle,
              damage = damage,
              type = "魔力",
              isattack = atk,
              isnoarmor = noarm
            })
          end
          if skill == GetWpSkill("君王之剑") and u:hasdata("变异判定-剑圣") then
            DamageUnit({
              bj = "近战武器伤害",
              unit = mb.handle,
              source = u.handle,
              damage = sh2,
              type = type,
              isattack = atk,
              isnoarmor = noarm
            })
          end
          if u:hasdata("栗山未来-拟态武器中") then
            u:deldata("栗山未来拟态武器吸血")
          end
          if skill == GetWpSkill("镰刀") then
            u:deldata("镰刀武器吸血")
          end
          if u:hasdata("变异判定-立华奏") then
            u:deldata("系统-本次伤害无视伤害闪避")
          end
          if skill == GetWpSkill("绯") then
            u:deldata("绯双重最终")
          end
          if u:hasdata("变异判定-龙剑") then
            u:deldata("龙剑-破抗强化")
          end
          if u:hasdata("变异判定-蛇百心流") then
            u:deldata("蛇百心流-蛇斩破抗")
          end
          mb:buffset(unit, kz, kzlx)
          if u:hasdata("变异判定-以实玛利") and not u:hasdata("以实玛利-黑云翻墨冷却") and u:getluckrandom(30) then
            u:settimedata("以实玛利-黑云翻墨冷却", 6)
            Buff_LiuxueRun(u, mb, 3)
          end
          if skill == GetWpSkill("拟态") then
            u:getdata("拟态-伤口施加")(mb, 3)
            local txsh = 15000 + 10 * mb:getdata("拟态-伤口层数") * u:getallattri()
            DamageUnit({
              bj = "拟态(伤口)",
              unit = mb.handle,
              source = u.handle,
              damage = txsh,
              type = "反物质",
              isvest = true
            })
            if 10 <= mb:getdata("拟态-伤口层数") then
              LossHpUnit({
                u = u,
                tg = mb,
                damage = 0,
                perhp = 0,
                maxhp = 0.1,
                bj = "拟态[生命损耗]"
              })
            end
          end
          if u:hasdata("变异判定-戈登") and mb:isnormal() and GetRandom100(5) then
            mb:kill(unit)
          end
          if u:hasdata("变异判定-蛇百心流") and GetRandom100(44) then
            DamageUnit({
              bj = "蛇百心流(近战武器附伤)",
              unit = mb.handle,
              source = u.handle,
              damage = 500 * u:getlevel(),
              type = "物理",
              isvest = true
            })
          end
          if skill == GetWpSkill("潮枯") and GetRandom100(33) then
            local skd = getunit(Danwei_Skd)
            local sy3 = skd.ownerid
            local txsh = 5 * skd:getmaxhp()
            DamageUnit({
              bj = "潮枯(近战武器附伤)",
              unit = mb.handle,
              source = skd.handle,
              damage = txsh,
              type = "魔力",
              isvest = true,
              isnoarmor = false,
              element = "水"
            })
          end
          if skill == GetWpSkill("雷霆长枪") then
            mb:buffset(unit, 2, "麻痹")
          end
          if skill == GetWpSkill("环印骑士直剑") and u:hasdata("变异判定-正道骑士") then
            if not mb:hasdata("环印骑士直剑-额外受伤") then
              mb:changedata("环印骑士直剑-额外受伤", 0.1)
              mb:changedata("怪物-额外受伤", 0.08)
              ac.loop(1000, function(t)
                mb:changedata("环印骑士直剑-额外受伤时间", -1)
                if mb:getdata("环印骑士直剑-额外受伤时间") <= 0 then
                  mb:changedata("怪物-额外受伤", -1 * mb:getdata("环印骑士直剑-额外受伤"))
                  mb:deldata("环印骑士直剑-额外受伤")
                  mb:deldata("环印骑士直剑-额外受伤时间")
                  t:remove()
                end
              end)
            end
            mb:setdata("环印骑士直剑-额外受伤时间", 5)
          end
          if skill == GetWpSkill("濡湿小镰刀") then
            mb:buffset(unit, 1.5, "僵直")
            if mb:isboss() and not mb:hasdata("濡湿小镰刀-沉默禁用") then
              mb:effectadd("Abilities\\Spells\\Other\\Silence\\SilenceTarget.mdl", "overhead", 1)
              mb:buffset(u.handle, 1, "沉默")
              if not u:hasdata("变异判定-正道骑士") then
                mb:changedata("濡湿小镰刀-沉默时间", 1)
                if 10 <= mb:getdata("濡湿小镰刀-沉默时间") then
                  mb:setdata("濡湿小镰刀-沉默时间", 0)
                  mb:settimedata("濡湿小镰刀-沉默禁用", 60)
                  u:sendmessage("|cFF9999FF濡湿小镰刀-失效|r")
                end
              else
                LossHpUnit({
                  u = u,
                  tg = mb,
                  damage = 0,
                  perhp = 0,
                  maxhp = 0.1,
                  bj = "[生命损耗]濡湿小镰刀"
                })
              end
            end
            if mb:isingroup(Group_PlayHero) then
              mb:buffset(unit, 1, "缠绕")
            end
          end
          if skill == GetWpSkill("天翼种之镰") and not mb:hasdata("天翼减甲") then
            mb:settimedata("天翼减甲", 5)
            mb:changearmor(-20)
            ac.wait(5000, function()
              mb:changearmor(20)
            end)
          end
          if skill == GetWpSkill("量子机神剑") then
            if u:hasdata("羁绊-量子机神王") and mb:isboss() then
              LossHpUnit({
                u = u,
                tg = mb,
                damage = 0,
                perhp = 0,
                maxhp = 0.33,
                bj = "[生命损耗]量子机神剑"
              })
            end
            ac.wait(10, function()
              u:setdata("伤害阶级", 5)
              DamageUnit({
                bj = "量子机神剑(近战武器附伤)",
                unit = mb.handle,
                source = u.handle,
                damage = sh2,
                type = type,
                isattack = atk,
                isnoarmor = noarm
              })
              if u:hasdata("羁绊-量子机神王") and mb:isboss() then
                LossHpUnit({
                  u = u,
                  tg = mb,
                  damage = 0,
                  perhp = 0,
                  maxhp = 0.33,
                  bj = "[生命损耗]量子机神剑"
                })
              end
            end)
            ac.wait(20, function()
              u:setdata("伤害阶级", 5)
              DamageUnit({
                bj = "量子机神剑(近战武器附伤)",
                unit = mb.handle,
                source = u.handle,
                damage = sh2,
                type = type,
                isattack = atk,
                isnoarmor = noarm
              })
              if u:hasdata("羁绊-量子机神王") and mb:isboss() then
                LossHpUnit({
                  u = u,
                  tg = mb,
                  damage = 0,
                  perhp = 0,
                  maxhp = 0.33,
                  bj = "[生命损耗]量子机神剑"
                })
              end
            end)
          end
          if skill == GetWpSkill("地狱の轮祸") then
            if not u:hasdata("武器击打音效冷却") then
              u:settimedata("武器击打音效冷却", 1)
              u:playsound(Sound_AA__103_u)
            end
            if GetRandom100(10) then
              mb:effectadd("AATX\\[AATxNew]Fire13.mdl", "chest")
              local txsh = 150 * GetData(wq, "地狱轮祸-灵魂数")
              mb:setdata("地狱轮祸-业火")
              DamageUnit({
                bj = "地狱の轮祸(近战武器附伤)",
                unit = mb.handle,
                source = u.handle,
                damage = txsh,
                type = "灵力",
                isvest = true,
                isnoarmor = false,
                element = "火"
              })
            end
          end
          if lx == 10 then
            ac.wait(10, function()
              if not mb:isalive() then
                KillCount_Katana[sy] = KillCount_Katana[sy] + 1
                if not Boolean_Murasame[2] and KillCount_Katana[sy] >= 250 and u:hasdata("丛雨结缘") then
                  Boolean_Murasame[2] = true
                  SendMsgAll("|cFF66FF99「盯——」|r")
                end
              end
            end)
          end
          if skill == GetWpSkill("轩辕剑(封)") then
            mb:removecharacteristics(5)
            if not mb:hasdata("轩辕印") then
              mb:settimedata("轩辕印", 5)
              mb:groupadd(HpGroup)
              mb:effectadd("Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl", "overhead")
              mb:effectadd("Abilities\\Spells\\Human\\HolyBolt\\HolyBoltMissile.mdl", "head", 5)
            end
          end
          if skill == GetWpSkill("神刀-丛雨丸") then
            mb:removecharacteristics(5)
            if not mb:hasdata("丛雨丸印记") then
              mb:settimedata("丛雨丸印记", 5)
              mb:groupadd(HpGroup)
              mb:effectadd("Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl", "overhead")
              mb:effectadd("Abilities\\Spells\\Items\\OrbVenom\\OrbVenom.mdl", "head", 5)
            end
          end
          if skill == GetWpSkill("长虹剑") and not mb:hasdata("长虹剑移除冷却") then
            mb:settimedata("长虹剑移除冷却", 5)
            local sl = mb:eliteschange()
            mb:removecharacteristics(2)
            DamageUnit({
              bj = "长虹剑(近战武器附伤)",
              unit = mb.handle,
              source = u.handle,
              damage = 1000 * sl,
              level = 1,
              type = "灵力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "火",
              extradata = {""}
            })
          end
          if skill == GetWpSkill("七夜") then
            mb:removecharacteristics(1.7)
            mb:clearbuff()
            if GetRandom100(13) and mb:isnormal() then
              mb:kill(unit, true)
            end
          end
          if skill == GetWpSkill("雪霞狼") then
            DamageUnit({
              bj = "雪霞狼(近战武器附伤)",
              unit = mb.handle,
              source = u.handle,
              damage = 0.5 * sh2,
              type = "灵力",
              isvest = true
            })
            if u:hasdata("雪菜-天使化") then
              LossHpUnit({
                u = u,
                tg = mb,
                damage = 0,
                perhp = 0,
                maxhp = 1,
                bj = "[生命损耗]雪霞狼(天使化)"
              })
            end
            ac.wait(10, function()
              if not mb:isalive() then
                u:changedata("雪霞狼杀敌", 1)
              end
            end)
            if not mb:isboss() then
              local jl = 50
              if mb:iselite() then
                jl = 25
              end
              if GetRandom100(jl) then
                mb:removecharacteristics(3)
                mb:effectadd("war3mapimported\\112.mdl", "origin", 0.8)
              end
            elseif not mb:hasdata("雪霞狼增伤") and GetRandom100(5) then
              mb:settimedata("雪霞狼增伤", 30)
              mb:effectadd("war3mapimported\\112.mdl", "origin", 0.8)
            end
          end
          if skill == GetWpSkill("业物") then
            DamageUnit({
              bj = "业物(近战武器附伤)",
              unit = mb.handle,
              source = u.handle,
              damage = 5000,
              type = "灵力",
              isvest = true
            })
          end
          if skill == S2ID("A0AG") then
            mb:buffset(u.handle, 1, "灼烧")
          end
          if skill == GetWpSkill("邪神剑") and not mb:hasdata("邪神剑抗性破坏") then
            mb:settimedata("邪神剑抗性破坏", 1.5)
            mb:buffset(u.handle, 1.5, "破坏-伤害抗性")
          end
          if skill == GetWpSkill("村正") and mb:isingroup(Group_Monster) and not mb:hasdata("妖刀村正-命中") then
            mb:groupadd(HpGroup)
            mb:setdata("妖刀村正-命中")
          end
          if skill == GetWpSkill("潮汐") then
            unitmove({
              unit = mb.handle,
              time = 0.8,
              distance = 400,
              angle = AngleBetweenUnits(u.handle, mb.handle)
            })
          end
          if skill == GetWpSkill("撬棍") or skill == GetWpSkill("物理学圣剑") then
            unitmove({
              unit = mb.handle,
              time = 0.2,
              distance = 400,
              angle = AngleBetweenUnits(u.handle, mb.handle)
            })
          end
          if skill == GetWpSkill("棒球棍") then
            local qld = 0
            local qldsh = 0
            if u:hasdata("变异判定-全垒打") then
              qld = 25
            else
              qld = 1
            end
            if mb:isnormal() then
              qldsh = GetRandomReal(0.25, 1) * mb:getmaxhp()
            elseif mb:iselite() then
              qldsh = GetRandomReal(0.25, 0.5) * mb:gethp()
            else
              qldsh = GetRandomReal(0.01, 0.05) * mb:gethp()
            end
            qldsh = qldsh + 10000 + 0.01 * mb:getmaxhp() + 0.04 * mb:gethp()
            if GetRandom100(qld) then
              mb:effectadd("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", "chest")
              mb:animeact("death")
              LossHpUnit({
                u = u,
                tg = mb,
                damage = qldsh,
                perhp = 0,
                maxhp = 0,
                bj = "[生命损耗]全垒打"
              })
              unitjump({
                unit = mb.handle,
                time = 2,
                distance = 1000,
                height = 500,
                angle = AngleBetweenUnits(u.handle, mb.handle)
              })
              mb:buffset(unit, 2, "暂停")
            end
          end
          if skill == GetWpSkill("灰狐刀") and not mb:hasdata("灰狐刀强破甲") then
            mb:settimedata("灰狐刀强破甲", 3)
            mb:changearmor(-66)
            ac.wait(3000, function()
              mb:changearmor(66)
            end)
          end
          if skill == GetWpSkill("光之剑超新星") and not mb:hasdata("光之剑超新星-瓦解") then
            mb:settimedata("光之剑超新星-瓦解", 5)
            local change = mb:getarmor()
            mb:changearmor(-1 * change)
            ac.wait(5000, function()
              mb:changearmor(change)
            end)
          end
          if u:hasdata("但丁-咿呀剑法开启") and (lx == 2 or lx == 11) then
            unitmove({
              unit = mb.handle,
              time = 0.12,
              distance = 120,
              angle = jd
            })
          end
          if (u:hasdata("雪菜-第六眷兽强化") or u:hasdata("雪菜-天使化")) and GetRandom100(10) then
            if mb:isnormal() then
              mb:kill(unit)
            elseif not u:hasdata("雪菜-第六眷兽附伤冷却") then
              u:settimedata("雪菜-第六眷兽附伤冷却", 2)
              local bb = false
              if skill == GetWpSkill("雪霞狼") then
                bb = true
              end
              local cs = 0
              ac.loop(200, function(t)
                cs = cs + 1
                local txsh = 0.005 * mb:gethp()
                if bb and mb:getdata("雪霞狼削减值") <= 0.1 * mb:getmaxhp() then
                  mb:changedata("雪霞狼削减值", txsh)
                  mb:changemaxhp(-1 * txsh)
                end
                DamageUnit({
                  bj = "雪霞狼(第六眷兽)",
                  unit = mb.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 4,
                  type = "灵力",
                  isvest = true,
                  isnoarmor = false
                })
                if cs == 5 then
                  t:remove()
                end
              end)
            end
          end
          if skill == GetWpSkill("星辰短剑") and mb:isboss() then
            mb:changedata("星辰短剑-沉默计数", 1)
            if 10 <= mb:getdata("星辰短剑-沉默计数") then
              mb:changedata("星辰短剑-沉默计数", -10)
              mb:buffset(u.handle, 3, "沉默")
              mb:buffset(u.handle, 3, "眩晕")
            end
          end
          if u:hasdata("Tevi-强化扳手") and lx == 9 then
            mb:buffset(u.handle, 1, "僵直")
            unitmove({
              unit = mb.handle,
              time = 0.5,
              distance = 200,
              angle = AngleBetweenUnits(u.handle, mb.handle)
            })
          end
          if u:hasdata("流氓巨星-近战强化") then
            local txsh = sh
            if u:hasdata("变异判定-黄金体验") then
              txsh = txsh * 2
            end
            DamageUnit({
              bj = "流氓巨星(近战武器附伤)",
              unit = mb.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "物理",
              isvest = true,
              element = "无"
            })
          end
          if u:hasdata("变异判定-见习剑巫") and GetRandom100(10) then
            local txsh = 8888 + 200 * u:getlevel()
            DamageUnit({
              bj = "见习剑巫(近战武器附伤)",
              unit = mb.handle,
              source = u.handle,
              damage = txsh,
              level = 4,
              type = "灵力",
              isvest = true,
              isnoarmor = false,
              element = "雷"
            })
            mb:effectadd("Tx_Jzxc2_Daiyong.mdl")
            mb:buffset(unit, 1, "僵直")
          end
          if u:hasdata("龙剑-居合强化") then
            DamageUnit({
              bj = "龙剑(近战武器附伤)",
              unit = mb.handle,
              source = u.handle,
              damage = sh2,
              type = "物理",
              isvest = true,
              extradata = {"龙属性"}
            })
          end
          if u:hasdata("变异判定-黑兔") then
            local txsh = 1000 * u:getlevel()
            DamageUnit({
              bj = "黑兔(近战武器附伤)",
              unit = mb.handle,
              source = u.handle,
              damage = txsh,
              type = "能量",
              isvest = true
            })
          end
          if u:hasdata("变异判定-法琦尔") then
            local txsh = 125 * u:getdata("魔力值") + 25 * u:getstate("黑暗变异") * u:getint()
            DamageUnit({
              bj = "法琦尔(近战武器附伤)",
              unit = mb.handle,
              source = u.handle,
              damage = txsh,
              type = "魔力",
              isvest = true,
              element = "暗"
            })
          end
          if u:hasdata("变异判定-终末鸟") and not mb:hasdata("终末鸟-审判") then
            mb:effectadd("0Tx\\0Tx_Baoming (2).mdl", "head", 15)
            mb:playsound(EGO_Bird_04)
            mb:settimedata("终末鸟-审判", 15)
            local hj = 10 + 0.1 * u:getdata("薄暝-罪痕层数")
            mb:changearmor(-1 * hj)
            ac.wait(15000, function()
              mb:changearmor(hj)
            end)
            mb:eliteschange(-100)
          end
          if not u:hasdata("暗之书-暗黑裁决") or u:hasdata("暗黑裁决冷却") or GetRandom100(25) then
          end
          if u:hasdata("神化判定-红A") and not u:hasdata("鹤翼三连冷却") then
            local txsh = 0.25 * sh2
            mb:effectadd("AATX\\[AATxNew]Katana26.mdl", "chset")
            mb:effectadd("AATX\\[AATxNew]Red50.mdl", "chset")
            DamageUnit({
              bj = "红A(近战武器附伤)",
              unit = mb.handle,
              source = u.handle,
              damage = txsh,
              type = "物理",
              isvest = true
            })
            ac.wait(50, function()
              DamageUnit({
                bj = "红A(近战武器附伤)",
                unit = mb.handle,
                source = u.handle,
                damage = txsh,
                type = "物理",
                isvest = true
              })
            end)
            ac.wait(100, function()
              DamageUnit({
                bj = "红A(近战武器附伤)",
                unit = mb.handle,
                source = u.handle,
                damage = txsh,
                type = "物理",
                isvest = true
              })
            end)
            u:settimedata("鹤翼三连冷却", 0.25)
          end
          if u:ishasskill("S03G") then
            if not mb:hasdata("流血层数") then
              ac.loop(1000, function(t)
                if mb:getdata("流血时间") > 0 then
                  mb:changedata("流血时间", -1)
                else
                  mb:deldata("流血时间")
                  mb:deldata("流血层数")
                  mb:delskill("S03H")
                  mb:delskill("A0UO")
                  t:remove()
                end
              end)
            end
            mb:setdata("流血时间", 7)
            mb:addskill("A0UO")
            if 3 <= mb:getdata("流血层数") then
              mb:setdata("流血层数", 3)
            else
              mb:changedata("流血层数", 1)
            end
            if mb:getdata("流血层数") >= 2 and not mb:ishasskill("S03H") then
              if mb:isnormal() and mb:gethp() <= 0.085 * mb:getmaxhp() then
                mb:addskill("S03H")
              elseif mb:gethp() <= 0.85 * mb:getmaxhp() then
                mb:addskill("S03H")
              end
            end
          end
        end)
      end
      if u:hasdata("蛇百心流-蛇斩") then
        GroupClearLua(Group_Shezhan)
        u:deldata("蛇百心流-蛇斩")
      end
      if u:getdata("雏见泽候群症等级") == 4 then
        u:deldata("礼奈失控")
        u:beunion()
      end
      if u:hasdata("变异判定-流氓巨星") then
        u:deldata("流氓巨星-近战强化")
      end
      if u:hasdata("地狱轮祸强化") then
        u:deldata("地狱轮祸强化")
      end
      if u:hasdata("龙剑-居合强化") then
        u:deldata("龙剑-居合强化")
      end
    end)
  end
end
