-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local anshen_skillloop, anshen_jieduan3skillloop, AnshenSkill
local fwzg = CreateGroupLua()

local function FsAngle(x1, y1, z1, x2, y2, z2)
  local dx = x2 - x1
  local dy = y2 - y1
  local dz = z2 - z1
  local jdz = math.sqrt(dx * dx + dy * dy)
  local z = -math.atan(dz, jdz)
  return z
end

local function IsInLaserRectUnit(x, y, angle, length, width, xq)
  local tx, ty = xq:getxy()
  local dx, dy = tx - x, ty - y
  local lx = math.cos(360 - angle) * dx - math.sin(360 - angle) * dy
  local ly = math.sin(360 - angle) * dx + math.cos(360 - angle) * dy
  return 0 <= lx and length >= lx and math.abs(ly) <= width / 2
end

local function AnshenFailPanding(u)
  local count = 0
  ForGroupLuaNew(Group_PlayHero, function(xq)
    if xq:isalive() or xq:hasdata("莲华-即死判定") then
      count = count + 1
    end
  end)
  if count == 0 then
    PlayGlobalSound(BOSS_4D_Playerkill)
    flashphoto({
      photo = "war3mapImported\\Black.blp",
      timeout = 0.5,
      timehold = 3,
      timein = 1
    })
    local dtext = class.text:builder({
      parent = OriginPanel,
      x = 960,
      y = 480,
      w = 1,
      h = 1,
      text = "",
      align = "center"
    })
    dtext:set_color(4287303439)
    local text = "You have perished"
    local a = #text
    local cs = 0
    local alpha = 0
    local max_alpha = 255
    ac.loop(100, function(timer)
      cs = cs + 1
      local substr = string.sub(text, 1, cs)
      dtext:set_text(substr)
      local target_alpha = math.floor(max_alpha * cs / #text)
      if target_alpha > alpha then
        alpha = target_alpha
        dtext:set_alpha(alpha)
      end
      if cs >= #text then
        dtext:set_alpha(max_alpha)
        timer:remove()
      end
    end)
    ac.wait(3500, function()
      local fade_time = 1000
      local step_interval = 50
      local steps = math.floor(fade_time / step_interval)
      local fade_step = max_alpha / steps
      local current_alpha = max_alpha
      ac.loop(step_interval, function(fade_timer)
        current_alpha = current_alpha - fade_step
        if current_alpha <= 0 then
          dtext:set_alpha(0)
          fade_timer:remove()
          dtext:destroy()
        else
          dtext:set_alpha(math.floor(current_alpha))
        end
      end)
    end)
    DayNightRun = true
    u:groupremove(Group_Monster)
    u:groupremove(HellGroup)
    u:setdata("暗神-失败结束标记")
    u:setdata("暗神-非首次挑战")
    u:changedata("暗神-挑战失败次数", 1)
    u:setdata("暗神永恒")
    u:sethp(100, true)
    u.owner = Player(PLAYER_NEUTRAL_PASSIVE)
    u:changeowner(Player(PLAYER_NEUTRAL_PASSIVE))
    ForGroupLuaNew(fwzg, function(xq)
      xq:groupremove(fwzg)
      xq:remove()
    end)
    u:deldata("暗神-二阶段尾杀")
    u:deldata("一阶段尾杀释放中")
    u:deldata("技能中断")
    u:deldata("尾杀释放中")
    u:deldata("反物质状态")
    ForGroupLuaNew(Group_AllHero, function(xq)
      local sy = xq.ownerid
      xq:buffset(u.handle, 5, "绝对闪避")
      xq:deldata("暗神-无光之视")
      xq:deldata("暗神-禁用复活")
      xq:deldata("暗神-旧日凝视")
      xq:deldata("黑曜物质层数")
      xq:deldata("梦魇之核时间")
    end)
    BuffUI.remove("梦魇之核")
    BuffUI.remove("反物质悖流")
    BuffUI.remove("旧日凝视")
    BuffUI.remove("理智值")
    BuffUI.remove("黑曜物质")
    BuffUI.remove("无光之视")
    BuffUI.remove("湮灭物质")
    DestroyEffectLua(u:getdata("星蚀界域"))
    if u:hasdata("逆反物质计时器1") then
      local ti = u:getdata("逆反物质计时器1")
      ti:remove()
      u:deldata("逆反物质计时器1")
    end
    if u:hasdata("逆反物质计时器2") then
      local ti = u:getdata("逆反物质计时器2")
      ti:remove()
      u:deldata("逆反物质计时器2")
    end
    if u:hasdata("恐惧核心再生计时器") then
      local ti = u:getdata("恐惧核心再生计时器")
      ti:remove()
      u:deldata("恐惧核心再生计时器")
      BuffUI.remove("星渊恐惧再生")
    end
    if u:hasdata("恐惧核心") then
      local mjtx = u:getdata("恐惧核心")
      DestroyEffectLua(mjtx)
      u:deldata("恐惧核心")
    end
    ExtraBattle = false
    BossBattle = false
    ExBossBattle = false
    Boolean_Anshen_Sanjieduan = false
    ShowUnit(u.handle, false)
    Boolean_AnshenBattle = false
    Boolean_Fog_Change = false
    FogEnable(true)
    FogMaskEnable(true)
    StopSoundBJ(Sound_Anshen_feng1, true)
    StopSoundBJ(Sound_Anshen_1, true)
    StopSoundBJ(Sound_Anshen_2, true)
    Boolean_AnshenBattle = false
    ac.wait(3000, function()
      local x, y = GetRandomXYInRect(RECT_Chushidanwei)
      u:setxy(x, y)
      Nofail_Biaoji = false
      ForGroupLuaNew(Group_PlayHero, function(xq)
        local ax, ay = xq:getxy()
        HeroRelive(xq.handle, ax, ay, 3)
      end)
    end)
    local npc2 = getunit(NPC_TIANZI)
    npc2:deldata("暗神天气切换")
    SendMsgAll("|cFF9966CC等待一段时间后可以重新召唤噬星灾神|r")
    local dc = 0
    ac.loop(1000, function(timer)
      dc = dc + 1
      if dc == 20 or not u:hasdata("暗神-失败结束标记") then
        u:deldata("暗神-失败结束标记")
        SendMsgAll("|cFF9966CC现在可以重新召唤噬星灾神了|r")
        local npc = getunit(NPC_Molijiedian)
        local x, y = npc:getxy()
        CreateItemLua("I0LF", x, y - 450)
        ShowUnit(npc.handle, true)
        timer:remove()
      end
    end)
  end
end

local function BOSS_Sxzs_sx(u)
  u:setdata("双星1速率控制", 0)
  u:setdata("双星2速率控制", 0)
  ForGroupLuaNew(Group_PlayHero, function(xq)
    if xq:isalive() then
      local x, y = xq:getxy()
      local x1, y1 = u:getdata("双星1X"), u:getdata("双星1Y")
      local x2, y2 = u:getdata("双星2X"), u:getdata("双星2Y")
      local jl1 = DistanceXY(x, y, x1, y1)
      local jl2 = DistanceXY(x, y, x2, y2)
      if jl1 <= 500 then
        u:changedata("双星1速率控制", 1)
      end
      if jl2 <= 500 then
        u:changedata("双星2速率控制", 1)
      end
    end
  end)
  if PlayerCount == 1 then
    ForGroupLuaNew(Group_PlayHero, function(xq)
      if xq:isalive() then
        local sy = xq.ownerid
        local bb = getunit(Beibao[sy])
        local x, y = bb:getxy()
        local x1, y1 = u:getdata("双星1X"), u:getdata("双星1Y")
        local x2, y2 = u:getdata("双星2X"), u:getdata("双星2Y")
        local jl1 = DistanceXY(x, y, x1, y1)
        local jl2 = DistanceXY(x, y, x2, y2)
        if jl1 <= 500 then
          u:changedata("双星1速率控制", 1)
        end
        if jl2 <= 500 then
          u:changedata("双星2速率控制", 1)
        end
      end
    end)
  end
end

local function GetPlayerQuadrant(u_boss, u_player)
  local x, y = u_boss:getxy()
  local x2, y2 = u_player:getxy()
  local angle = AngleXY(x, y, x2, y2) % 360
  if 0 <= angle and angle < 90 then
    return 4
  elseif 90 <= angle and angle < 180 then
    return 3
  elseif 180 <= angle and angle < 270 then
    return 2
  else
    return 1
  end
end

local function AnshenJisi(u, xq)
  if xq:hasbuff("永恒") or xq:hasbuff("停滞") or xq:hasdata("青空的加护特效") then
  else
    local xh = 8
    if not xq:hasdata("暗神即死击杀冷却") then
      if xh <= xq:getdata("黑曜物质层数") and not xq:hasdata("黑曜物质格挡冷却") then
        xq:sendmessage("|cFF9966FF黑曜物质-抵挡|r")
        xq:changedata("黑曜物质层数", -xh)
        xq:settimedata("黑曜物质格挡冷却", 3)
      else
        xq:kill(u.handle, false)
        xq:settimedata("暗神即死击杀冷却", 1)
      end
    end
  end
end

local function AnshenHeiyaojisi(u, xq, boolean)
  local hp = u:getperhp()
  if boolean == nil then
    boolean = false
  end
  local xh = 1
  if 75 <= hp then
    xh = 4
  elseif 50 <= hp then
    xh = 3
  elseif 25 <= hp then
    xh = 2
  end
  if boolean then
    DamageUnit({
      unit = xq.handle,
      source = u.handle,
      damage = 10000,
      level = 5,
      type = "反物质",
      isvest = false,
      isattack = false,
      isnoarmor = false,
      element = "无",
      extradata = {""}
    })
    if xq:hasbuff("绝对闪避") or xq:hasbuff("永恒") or xq:hasbuff("停滞") then
    elseif xh <= xq:getdata("黑曜物质层数") then
      xq:changedata("黑曜物质层数", -xh)
    elseif xq:getdata("残机剩余数量") > 0 then
      xq:changedata("残机剩余数量", -1)
      xq:setusedfodd(u:getdata("残机剩余数量"))
      xq:changedata("黑曜物质层数", 5 - xh)
    else
      xq:kill(u.handle, false)
    end
  elseif xh <= xq:getdata("黑曜物质层数") then
    xq:changedata("黑曜物质层数", -xh)
  elseif xq:getdata("残机剩余数量") > 0 then
    xq:changedata("残机剩余数量", -1)
    xq:setusedfodd(u:getdata("残机剩余数量"))
    xq:changedata("黑曜物质层数", 5 - xh)
  else
    xq:kill(u.handle, false)
  end
end

local function AnshenDamage(u, xq, txsh, boolean)
  if boolean == nil then
    boolean = false
  end
  if xq:hasdata("青空的加护特效") or xq:hasdata("暗神-复活无敌") then
    return
  end
  DamageUnit({
    unit = xq.handle,
    source = u.handle,
    damage = txsh,
    level = 5,
    type = "反物质",
    isvest = false,
    isattack = false,
    isnoarmor = false,
    element = "无",
    extradata = {""}
  })
  if boolean and (xq:hasbuff("绝对闪避") or xq:hasbuff("永恒") or xq:hasbuff("停滞")) then
    return
  end
  local down = -2
  if Nandu_Choose <= 4 then
    down = -1
  end
  xq:changedata("理智值", down)
  xq:setdata("理智值损失时间", 10)
  if xq:getdata("理智值") < 0 then
    xq:setdata("理智值", 0)
    if not xq:hasdata("理智值击杀冷却") then
      xq:settimedata("理智值击杀冷却", 3)
      xq:sendmessage("|cFF9966FF你的理智崩溃了……|r")
      xq:kill(u.handle)
      if Nandu_Choose <= 4 then
        xq:setdata("理智值", 50)
      else
        xq:setdata("理智值", 25)
      end
    end
  end
  xq:changetimedata("湮灭物质叠加层数", 1, 30)
  if xq:islocal() then
    BuffUI.apply({
      id = "湮灭物质",
      duration = 30
    })
  end
  if u:getdata("噬星灾神阶段") == 3 then
    local xh = 1
    if not xq:hasdata("黑曜物质损失冷却") then
      xq:settimedata("黑曜物质损失冷却", 1)
      if xh <= xq:getdata("黑曜物质层数") then
        xq:changedata("黑曜物质层数", -xh)
      end
    end
  end
end

local function Jiguanghanshu(u, x, y, txsh)
  local dx, dy = PolarXY(x, y, 1800, GetRandomAngle())
  local jd1 = AngleXY(dx, dy, x, y) + GetRandomReal(-45, 45)
  EffectcreateArgs({
    effect = "war3mapImported\\BOSS_4D_zhishixian2.mdx",
    x = dx,
    y = dy,
    size = 2,
    height = 100,
    zxz = jd1,
    animespeed = 1
  })
  ac.wait(500, function()
    ac.wait(1, function()
      local sjsound = GetRandomInt(1, 8)
      if sjsound == 1 then
        PlayGlobalSound(Sound_Anshen_xiaojiguang1)
        SetSoundVolumeBJ(Sound_Anshen_xiaojiguang1, 80)
      end
      if sjsound == 2 then
        PlayGlobalSound(Sound_Anshen_xiaojiguang2)
        SetSoundVolumeBJ(Sound_Anshen_xiaojiguang2, 80)
      end
      if sjsound == 3 then
        PlayGlobalSound(Sound_Anshen_xiaojiguang3)
        SetSoundVolumeBJ(Sound_Anshen_xiaojiguang3, 80)
      end
      if sjsound == 4 then
        PlayGlobalSound(Sound_Anshen_xiaojiguang4)
        SetSoundVolumeBJ(Sound_Anshen_xiaojiguang4, 80)
      end
      if sjsound == 5 then
        PlayGlobalSound(Sound_Anshen_xiaojiguang5)
        SetSoundVolumeBJ(Sound_Anshen_xiaojiguang5, 80)
      end
      if sjsound == 6 then
        PlayGlobalSound(Sound_Anshen_xiaojiguang6)
        SetSoundVolumeBJ(Sound_Anshen_xiaojiguang6, 80)
      end
      if sjsound == 7 then
        PlayGlobalSound(Sound_Anshen_xiaojiguang7)
        SetSoundVolumeBJ(Sound_Anshen_xiaojiguang7, 80)
      end
      if sjsound == 8 then
        PlayGlobalSound(Sound_Anshen_xiaojiguang8)
        SetSoundVolumeBJ(Sound_Anshen_xiaojiguang8, 80)
      end
    end)
    EffectcreateArgs({
      effect = "war3mapImported\\BOSS_4D_jiguang4.mdx",
      x = dx,
      y = dy,
      size = 1,
      height = 0,
      zxz = jd1,
      animespeed = 2
    })
    EffectcreateArgs({
      effect = "war3mapImported\\BOSS_4D_jiguang6.mdx",
      x = dx,
      y = dy,
      size = 5,
      height = 100,
      zxz = jd1,
      animespeed = 2
    })
    EffectcreateArgs({
      effect = "war3mapImported\\BOSS_4D_jiguang5.mdx",
      x = dx,
      y = dy,
      size = 2,
      height = 0,
      zxz = jd1,
      animespeed = 3
    })
    ac.wait(100, function()
      local angle = jd1
      local length = 3800
      local width = 150
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() and IsInLaserRectUnit(dx, dy, angle, length, width, xq) then
          AnshenDamage(u, xq, txsh, true)
        end
      end)
    end)
  end)
end

local function Jiguanghanshu2(u, x, y, txsh, jd1, cansb, canjisi)
  if canjisi == nil then
    canjisi = false
  end
  local dx, dy = PolarXY(x, y, 1800, jd1)
  local jd2 = AngleXY(x, y, dx, dy)
  local jd3 = jd2 + 180
  EffectcreateArgs({
    effect = "war3mapImported\\BOSS_4D_zhishixian2.mdx",
    x = x,
    y = y,
    size = 1,
    height = 100,
    zxz = jd2,
    animespeed = 1
  })
  EffectcreateArgs({
    effect = "war3mapImported\\BOSS_4D_zhishixian2.mdx",
    x = x,
    y = y,
    size = 1,
    height = 100,
    zxz = jd3,
    animespeed = 1
  })
  ac.wait(500, function()
    EffectcreateArgs({
      effect = "war3mapImported\\BOSS_4D_jiguang4.mdx",
      x = x,
      y = y,
      size = 1,
      height = 0,
      zxz = jd2,
      animespeed = 2
    })
    EffectcreateArgs({
      effect = "war3mapImported\\BOSS_4D_jiguang4.mdx",
      x = x,
      y = y,
      size = 1,
      height = 0,
      zxz = jd3,
      animespeed = 2
    })
    ac.wait(100, function()
      local angle = jd1
      local length = 3800
      local width = 180
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() and (IsInLaserRectUnit(x, y, angle, length, width, xq) or IsInLaserRectUnit(x, y, angle + 180, length, width, xq)) then
          AnshenDamage(u, xq, txsh, cansb)
          if canjisi then
            AnshenJisi(u, xq)
          end
        end
      end)
    end)
  end)
end

AnshenSkill = {
  ["双星"] = function(u)
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFF9966FF逆旋双星|r", 30)
      SendMsgAll("|cFF9966FF[召唤双星环绕场地旋转;双星触碰时秒杀全场;玩家靠近双星时使双星恒速]|r", 30)
    end
    local x, y = u:getdata("星蚀界域X"), u:getdata("星蚀界域Y")
    local x1, y1 = PolarXY(x, y, u:getdata("暗神-界域大小"), 0)
    local x2, y2 = PolarXY(x, y, u:getdata("暗神-界域大小"), 180)
    local tx1 = EffectcreateArgs({
      effect = "war3mapImported\\BOSS_4D_heidong4.mdx",
      x = x1,
      y = y1,
      time = -1,
      size = 4,
      height = -400,
      zxz = GetRandomAngle(),
      animespeed = 2
    })
    local tx2 = EffectcreateArgs({
      effect = "war3mapImported\\BOSS_4D_heidong4.mdx",
      x = x2,
      y = y2,
      time = -1,
      size = 4,
      height = -400,
      zxz = GetRandomAngle(),
      animespeed = 2
    })
    if type(japi.EXSetEffectFogVisible) == "function" then
      japi.EXSetEffectFogVisible(tx1, true)
    end
    if type(japi.EXSetEffectMaskVisible) == "function" then
      japi.EXSetEffectMaskVisible(tx1, true)
    end
    if type(japi.EXSetEffectFogVisible) == "function" then
      japi.EXSetEffectFogVisible(tx2, true)
    end
    if type(japi.EXSetEffectMaskVisible) == "function" then
      japi.EXSetEffectMaskVisible(tx2, true)
    end
    u:setdata("双星1", tx1)
    u:setdata("双星2", tx2)
    u:setdata("双星1角度", 0)
    u:setdata("双星2角度", 180)
    u:setdata("双星1模式", 1)
    u:setdata("双星2模式", 1)
    u:setdata("双星1X", x1)
    u:setdata("双星1Y", y1)
    u:setdata("双星2X", x2)
    u:setdata("双星2Y", y2)
    local cs = 0
    local cs1 = 0
    local vs = 0.1
    
    local function get_base_increment(mode)
      if mode == 2 then
        return 0.17
      elseif mode == 3 then
        return 0.08
      else
        return 0.1
      end
    end
    
    local function get_adjusted_increment(mode, rate)
      local base = 0.1
      local offset = 0.05 * rate
      if mode == 2 then
        return math.max(base - offset, 0.01)
      else
        return math.max(base + offset, 0.01)
      end
    end
    
    ac.loop(10, function(t)
      local dis = u:getdata("暗神-界域大小")
      cs = cs + 1
      cs1 = cs1 + 1
      BOSS_Sxzs_sx(u)
      local mode1 = u:getdata("双星1模式")
      local mode2 = u:getdata("双星2模式")
      local angle1 = u:getdata("双星1角度")
      local angle2 = u:getdata("双星2角度")
      local rate1 = u:getdata("双星1速率控制")
      local rate2 = u:getdata("双星2速率控制")
      local jd1 = angle1 + (0 < rate1 and get_adjusted_increment(mode1, rate1) or get_base_increment(mode1))
      local jd2 = angle2 + (0 < rate2 and get_adjusted_increment(mode2, rate2) or get_base_increment(mode2))
      if u:hasdata("双星爆炸冷却") then
        jd1 = angle1
      end
      if 3000 <= cs then
        cs = 0
        if Nandu_Choose <= 4 then
          SendMsgAll("|cFF9966FF双星转换模式|r")
        end
        local sj = GetRandomInt(1, 2)
        if sj == 1 then
          u:setdata("双星1模式", 2)
        end
        if sj == 2 then
          u:setdata("双星1模式", 3)
        end
        local sj2 = GetRandomInt(1, 2)
        if sj2 == 1 then
          u:setdata("双星2模式", 2)
        end
        if sj2 == 2 then
          u:setdata("双星2模式", 3)
        end
      end
      u:setdata("双星1角度", jd1)
      u:setdata("双星2角度", jd2)
      local dx1, dy1 = PolarXY(x, y, dis, jd1)
      local dx2, dy2 = PolarXY(x, y, dis, jd2)
      local jl = DistanceXY(dx1, dy1, dx2, dy2)
      japi.EXSetEffectXY(tx1, dx1, dy1)
      japi.EXSetEffectXY(tx2, dx2, dy2)
      u:setdata("双星1X", dx1)
      u:setdata("双星1Y", dy1)
      u:setdata("双星2X", dx2)
      u:setdata("双星2Y", dy2)
      if jl <= 200 and 100 <= cs1 and not u:hasdata("双星爆炸冷却") then
        cs1 = 0
        u:settimedata("双星爆炸冷却", 5)
        PlayGlobalSound(Sound_Anshen_baozha5)
        PlayGlobalSound(Sound_Anshen_baozha7)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() then
            AnshenJisi(u, xq)
          end
        end)
        for i = 1, 4 do
          EffectcreateArgs({
            effect = "war3mapImported\\BOSS_4D_guangzhu1.mdx",
            x = x,
            y = y,
            size = 20,
            height = -400,
            zxz = GetRandomAngle(),
            animespeed = 1
          })
          EffectcreateArgs({
            effect = "war3mapImported\\BOSS_4D_shandian1.mdx",
            x = x,
            y = y,
            time = 0.1,
            size = 30,
            zxz = GetRandomAngle(),
            animespeed = 0.2
          })
        end
      end
      if u:hasdata("暗神-二阶段尾杀") or u:hasdata("暗神-失败结束标记") then
        DestroyEffectLua(u:getdata("双星1"))
        DestroyEffectLua(u:getdata("双星2"))
        t:remove()
      end
    end)
  end,
  ["暗矢"] = function(u)
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFF9966FF暗矢|r")
    end
    local x, y = u:getxy()
    local jd = u:getface()
    local damage = 500 * u:getdata("怪物强度")
    u:buffset(u.handle, 3, "暂停")
    local sj = GetRandomInt(1, 4)
    if u:getdata("噬星灾神阶段") == 1 then
      sj = GetRandomInt(1, 2)
    end
    if u:getdata("噬星灾神阶段") == 2 then
      sj = GetRandomInt(1, 3)
    end
    if u:getdata("噬星灾神阶段") == 3 then
      sj = GetRandomInt(1, 4)
    end
    local waittime
    if sj == 1 or sj == 2 then
      waittime = 0.6
      u:animeact(GetRandomInt(1, 2))
      u:animespeed(2)
    end
    if waittime then
      ac.wait(waittime * 1000, function()
        u:animeact("stand")
        u:animespeed(1)
      end)
    end
    if sj == 1 then
      anshen_skillloop(u, 2)
      local g = CreateGroupLua()
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() then
          xq:groupadd(g)
        end
      end)
      local mb = Group_Randomunit(g)
      if mb == 0 then
        mb = u
      end
      local cs = 0
      ac.loop(100, function(t)
        cs = cs + 1
        x, y = u:getxy()
        local x1, y1 = mb:getxy()
        local jd1 = AngleXY(x, y, x1, y1)
        u:setface(jd1)
        EffectcreateArgs({
          effect = "war3mapImported\\BOSS_4D_zhishixian2.mdx",
          x = x,
          y = y,
          size = 2,
          height = 100,
          zxz = jd1,
          animespeed = 1
        })
        ac.wait(300, function()
          unifycreate({
            owner = u.handle,
            model = "war3mapImported\\BOSS_4D_danmu1.mdl",
            modelname = "暗矢",
            modelsize = 1.5,
            height = 100,
            damage = 0,
            damagetype = 5,
            x = x,
            y = y,
            time = 1,
            speed = 4800,
            volume = 70,
            angle = jd1,
            angleoffset = 0,
            attenua = 1,
            attenuacount = 1,
            life = 10,
            isbullet = false,
            isvest = false,
            isignorearmor = false,
            hitafterfunc = function(mj, xq, damage2)
              AnshenDamage(u, xq, damage, true)
            end
          })
        end)
        if 10 <= cs then
          t:remove()
        end
      end)
    end
    if sj == 2 then
      anshen_skillloop(u, 2)
      x, y = u:getxy()
      for i = 1, 9 do
        local jd1 = u:getface() - 112.5 + i * 22.5
        EffectcreateArgs({
          effect = "war3mapImported\\BOSS_4D_zhishixian2.mdx",
          x = x,
          y = y,
          size = 2,
          height = 100,
          zxz = jd1,
          animespeed = 1
        })
      end
      ac.wait(300, function()
        local cs = 0
        ac.loop(100, function(t)
          cs = cs + 1
          x, y = u:getxy()
          for i = 1, 9 do
            local jd1 = u:getface() - 112.5 + i * 22.5
            unifycreate({
              owner = u.handle,
              model = "war3mapImported\\BOSS_4D_danmu1.mdl",
              modelname = "暗矢",
              modelsize = 1.5,
              height = 100,
              damage = 0,
              damagetype = 5,
              x = x,
              y = y,
              time = 1,
              speed = 3800,
              volume = 70,
              angle = jd1,
              angleoffset = 0,
              attenua = 1,
              attenuacount = 1,
              life = 10,
              isbullet = false,
              isvest = false,
              isignorearmor = false,
              hitafterfunc = function(mj, xq, damage2)
                AnshenDamage(u, xq, damage, true)
              end
            })
          end
          if 5 <= cs then
            t:remove()
          end
        end)
      end)
    end
    if sj == 3 then
      anshen_skillloop(u, 2)
      local x1, y1 = PolarXY(x, y, 1500, jd)
      u:setxy(x1, y1)
      u:setface(jd + 180)
      if u:getdata("噬星灾神阶段") == 3 then
        u:setdata("暗神-寂灭之心停止")
      end
      ac.wait(250, function()
        local cs = 0
        ac.loop(20, function(t)
          cs = cs + 1
          local jd1 = jd + 15 * cs
          local dx, dy = PolarXY(x, y, 1500, jd1)
          local dx2, dy2 = PolarXY(x, y, 1600, jd1)
          u:setxy(dx2, dy2)
          u:setface(jd1 + 180)
          u:animeact(GetRandomInt(1, 2))
          u:animespeed(10)
          EffectcreateArgs({
            effect = "war3mapImported\\BOSS_4D_danmu1.mdl",
            x = dx,
            y = dy,
            time = 1.5,
            size = 1.5,
            height = 100,
            zxz = jd1 + 180,
            animespeed = 1
          })
          EffectcreateArgs({
            effect = "Anshen_New_01.mdl",
            x = dx2,
            y = dy2,
            time = 0,
            size = 1,
            animespeed = 3
          })
          ac.wait(1500, function()
            unifycreate({
              owner = u.handle,
              model = "war3mapImported\\BOSS_4D_danmu1.mdl",
              modelname = "暗矢",
              modelsize = 1.5,
              height = 100,
              damage = 0,
              damagetype = 5,
              x = dx,
              y = dy,
              time = 1,
              speed = 4800,
              volume = 70,
              angle = jd1 + 180,
              angleoffset = 0,
              attenua = 1,
              attenuacount = 1,
              life = 10,
              isbullet = false,
              isvest = false,
              isignorearmor = false,
              hitafterfunc = function(mj, xq, damage2)
                AnshenDamage(u, xq, damage, true)
              end
            })
          end)
          if 24 <= cs then
            if u:getdata("噬星灾神阶段") == 3 then
              u:deldata("暗神-寂灭之心停止")
            end
            u:setxy(x, y)
            u:animespeed(1)
            u:animeact("stand")
            u:setface(270)
            EffectcreateArgs({
              effect = "Anshen_New_01.mdx",
              x = x,
              y = y,
              time = 0,
              size = 1.5,
              animespeed = 3
            })
            t:remove()
          end
        end)
      end)
    end
    if sj == 4 then
      anshen_skillloop(u, 4)
      local phase_config_list = {
        {delay = 1, move_angle = -90},
        {delay = 1000, move_angle = 0},
        {delay = 2000, move_angle = -135},
        {delay = 2500, move_angle = 315},
        {delay = 3000, move_angle = 0},
        {delay = 3500, move_angle = 45}
      }
      local start = {
        270,
        90,
        180,
        0
      }
      local dmoveangle = start[GetRandomInt(1, 4)]
      if u:getdata("噬星灾神阶段") == 3 then
        u:setdata("暗神-寂灭之心停止")
      end
      
      local function process_phase(cfg)
        local change = {
          45,
          90,
          135
        }
        dmoveangle = dmoveangle + change[GetRandomInt(1, 3)]
        local moveangle = dmoveangle
        ac.wait(cfg.delay, function()
          local x1, y1 = PolarXY(x, y, 2000, moveangle + 225)
          u:setface(moveangle + 90)
          u:setxy(x1, y1)
          u:animeact(GetRandomInt(1, 2))
          u:animespeed(2)
          u:deldata("免疫击退效果")
          unitmove({
            unit = u.handle,
            time = 0.2,
            distance = 2750,
            angle = moveangle,
            isfly = true,
            endfunc = function(dx, dy)
              u:setdata("免疫击退效果")
              EffectcreateArgs({
                effect = "Anshen_New_01.mdl",
                x = dx,
                y = dy,
                time = 0,
                size = 1,
                animespeed = 3
              })
            end
          })
          local cs = 0
          ac.loop(40, function(t)
            cs = cs + 1
            local dx, dy = PolarXY(x1, y1, 250 * cs, moveangle)
            local bx, by = PolarXY(dx, dy, 1000, moveangle + 90)
            local jd = u:getface()
            local time1 = 1000 - cs * 40
            EffectcreateArgs({
              effect = "Anshen_New_01.mdl",
              x = dx,
              y = dy,
              time = 0,
              size = 1,
              animespeed = 3
            })
            EffectcreateArgs({
              effect = "war3mapImported\\BOSS_4D_zhishixian.mdx",
              x = bx,
              y = by,
              time = 0.01,
              size = 0.5,
              height = 100,
              zxz = jd,
              animespeed = 1
            })
            ac.wait(time1, function()
              unifycreate({
                owner = u.handle,
                model = "war3mapImported\\BOSS_4D_danmu1.mdl",
                modelname = "暗矢",
                modelsize = 1.0,
                height = 100,
                damage = 0,
                damagetype = 5,
                x = dx,
                y = dy,
                time = 1,
                speed = 4800,
                volume = 50,
                angle = jd,
                angleoffset = 0,
                attenua = 1,
                attenuacount = 1,
                life = 10,
                isbullet = false,
                isvest = false,
                isignorearmor = false,
                hitafterfunc = function(mj, xq, damage2)
                  AnshenDamage(u, xq, damage, true)
                end
              })
            end)
            if 10 <= cs then
              if cfg == phase_config_list[#phase_config_list] then
                if u:getdata("噬星灾神阶段") == 3 then
                  u:deldata("暗神-寂灭之心停止")
                end
                u:setxy(x, y)
                u:animespeed(1)
                u:animeact("stand")
                u:setface(270)
                EffectcreateArgs({
                  effect = "Anshen_New_01.mdl",
                  x = x,
                  y = y,
                  time = 0,
                  size = 1,
                  animespeed = 3
                })
              end
              t:remove()
            end
          end)
        end)
      end
      
      for _, cfg in ipairs(phase_config_list) do
        process_phase(cfg)
      end
    end
  end,
  ["暗耀"] = function(u)
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFF9966FF暗耀|r")
    end
    anshen_skillloop(u, 3)
    local x, y = u:getxy()
    local jd = u:getface()
    u:animespeed(0.5)
    u:animeact(8)
    local damage = 400 * u:getdata("怪物强度")
    ac.wait(600, function()
      u:animespeed(0)
    end)
    ac.wait(1000, function()
      u:animespeed(0.5)
    end)
    ac.wait(3000, function()
      u:animespeed(1)
      u:animeact("stand")
    end)
    ForGroupLuaNew(Group_PlayHero, function(xq)
      local cs = 0
      ac.loop(500, function(t)
        if u:hasdata("暗神-失败结束标记") then
          t:remove()
          return
        end
        cs = cs + 1
        if xq:isalive() then
          local x1, y1 = xq:getxy()
          local jd = xq:getface()
          EffectcreateArgs({
            effect = "war3mapImported\\BOSS_4D_zhishixian.mdx",
            x = x1,
            y = y1,
            time = 0.01,
            size = 0.5,
            height = 100,
            zxz = jd,
            yxz = 90,
            animespeed = 1
          })
          ac.wait(1000, function()
            local tx = EffectcreateArgs({
              effect = "war3mapImported\\BOSS_4D_guangzhu1.mdx",
              x = x1,
              y = y1,
              time = 10,
              size = 3,
              height = 0,
              zxz = jd,
              animespeed = 0.05
            })
            local cs1 = 0
            ac.loop(100, function(t1)
              if u:hasdata("暗神-失败结束标记") then
                t1:remove()
                return
              end
              cs1 = cs1 + 1
              for _, xq1 in ac.selector():in_rangexy(x1, y1, 200):is_enemy(u.handle):ipairs() do
                xq1 = getunit(xq1)
                AnshenDamage(u, xq1, damage)
              end
              if 100 <= cs1 then
                t1:remove()
              end
            end)
            ac.wait(9000, function()
              japi.EXSetEffectSpeed(tx, 1.0)
            end)
          end)
        end
        if 5 <= cs then
          t:remove()
        end
      end)
    end)
  end,
  ["寂灭"] = function(u)
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFF9966FF寂灭|r", 30)
      SendMsgAll("|cFF9966FF[生成寂灭之心向BOSS移动;触碰BOSS时即死全场;触碰玩家时消耗体力值抵消]|r", 30)
    end
    anshen_skillloop(u, 3)
    u:animeact(GetRandomInt(1, 2))
    ac.wait(1000, function()
      u:animeact("stand")
    end)
    local x, y = u:getdata("星蚀界域X"), u:getdata("星蚀界域Y")
    local jd = u:getface()
    local x1, y1 = PolarXY(x, y, GetRandomReal(u:getdata("暗神-界域大小") - 200, u:getdata("暗神-界域大小")), GetRandomAngle())
    EffectcreateArgs({
      effect = "war3mapImported\\BOSS_4D_heiqiu1.mdx",
      x = x1,
      y = y1,
      time = 10,
      size = 0.5,
      height = 100,
      zxz = jd,
      animespeed = 1
    })
    local tx2
    ac.wait(8000, function()
      if u:getdata("噬星灾神阶段") < 3 then
        tx2 = EffectcreateArgs({
          effect = "BOSS_Anshen_NTX05.mdx",
          x = x,
          y = y,
          time = -1,
          size = 1.5,
          height = 10,
          animespeed = 1
        })
      end
    end)
    ac.wait(10000, function()
      local tx = EffectcreateArgs({
        effect = "BOSS_Anshen_NTX03.mdx",
        x = x1,
        y = y1,
        time = -1,
        size = 0.5,
        height = 10,
        zxz = jd,
        animespeed = 1
      })
      local cs = 0
      local x3, y3 = u:getdata("星蚀界域X"), u:getdata("星蚀界域Y")
      local dismax = u:getdata("暗神-界域大小")
      local vadd = 0.005
      if Nandu_Choose >= 5 then
        vadd = 0.02
      end
      ac.loop(10, function(t)
        if u:hasdata("暗神-失败结束标记") then
          DestroyEffectLua(tx)
          if tx2 then
            DestroyEffectLua(tx2)
          end
          t:remove()
          return
        end
        if not u:hasdata("暗神-三阶段转场中") and not u:hasdata("暗神-寂灭之心停止") and not u:hasdata("暗神-寂灭暂停计时") then
          cs = cs + 1
          local x2, y2
          if u:getdata("噬星灾神阶段") == 3 then
            x2, y2 = u:getxy()
          else
            x2, y2 = x, y
          end
          local jd1 = AngleXY(x1, y1, x2, y2)
          local dis = DistanceXY(x2, y2, x3, y3)
          local dis2 = DistanceXY(x, y, x1, y1)
          x1, y1 = PolarXY(x1, y1, 2 + vadd * cs, jd1)
          japi.EXSetEffectXY(tx, x1, y1)
          local bz = false
          ForGroupLuaNew(Group_AllHero, function(xq)
            if xq:isalive() then
              local ax, ay = xq:getxy()
              local dis3 = DistanceXY(x1, y1, ax, ay)
              if dis3 <= 100 then
                xq:curetili(-0.5 * Hero_Tili_Max[xq.ownerid])
                DestroyEffectLua(tx)
                if tx2 then
                  DestroyEffectLua(tx2)
                end
                bz = true
                t:remove()
              end
            end
          end)
          if not bz then
            if u:getdata("噬星灾神阶段") == 3 then
              local bx, by = u:getxy()
              local dis3 = DistanceXY(x1, y1, bx, by)
              if dis3 <= dismax then
                PlayGlobalSound(Sound_Anshen_baozha5)
                PlayGlobalSound(Sound_Anshen_baozha7)
                ForGroupLuaNew(Group_PlayHero, function(xq2)
                  if xq2:isalive() then
                    AnshenJisi(u, xq2)
                  end
                end)
                local cs1 = 0
                ac.loop(100, function(t1)
                  cs1 = cs1 + 1
                  u:shockcamera(500, 0.05)
                  EffectcreateArgs({
                    effect = "war3mapImported\\BOSS_4D_guangzhu1.mdx",
                    x = x1,
                    y = y1,
                    size = 20,
                    height = -400,
                    zxz = GetRandomAngle(),
                    animespeed = 1
                  })
                  EffectcreateArgs({
                    effect = "war3mapImported\\BOSS_4D_shandian1.mdx",
                    x = x1,
                    y = y1,
                    time = 0.1,
                    size = 30,
                    zxz = GetRandomAngle(),
                    animespeed = 0.2
                  })
                  if 10 <= cs1 then
                    t1:remove()
                  end
                end)
                DestroyEffectLua(tx)
                t:remove()
              end
            elseif dis2 <= 100 then
              PlayGlobalSound(Sound_Anshen_baozha5)
              PlayGlobalSound(Sound_Anshen_baozha7)
              ForGroupLuaNew(Group_PlayHero, function(xq2)
                if xq2:isalive() then
                  AnshenJisi(u, xq2)
                end
              end)
              do
                local cs1 = 0
                ac.loop(100, function(t1)
                  cs1 = cs1 + 1
                  u:shockcamera(500, 0.05)
                  EffectcreateArgs({
                    effect = "war3mapImported\\BOSS_4D_guangzhu1.mdx",
                    x = x1,
                    y = y1,
                    size = 20,
                    height = -400,
                    zxz = GetRandomAngle(),
                    animespeed = 1
                  })
                  EffectcreateArgs({
                    effect = "war3mapImported\\BOSS_4D_shandian1.mdx",
                    x = x1,
                    y = y1,
                    time = 0.1,
                    size = 30,
                    zxz = GetRandomAngle(),
                    animespeed = 0.2
                  })
                  if 10 <= cs1 then
                    t1:remove()
                  end
                end)
                DestroyEffectLua(tx)
                if tx2 then
                  DestroyEffectLua(tx2)
                end
                t:remove()
              end
            end
          end
        else
          for _, xq in ac.selector():in_rangexy(x1, y1, 100):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            if xq.handle ~= u.handle then
              xq:curetili(-0.5 * Hero_Tili_Max[xq.ownerid])
              DestroyEffectLua(tx)
              if tx2 then
                DestroyEffectLua(tx2)
              end
              t:remove()
            end
          end
        end
      end)
    end)
  end,
  ["暗蚀飞星"] = function(u)
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFF9966FF暗蚀飞星|r")
    end
    anshen_skillloop(u, 8)
    u:animeact(3)
    u:animespeed(0.25)
    local x, y = u:getxy()
    local jd = u:getface()
    u:addskill("A00N")
    ac.wait(9000, function()
      u:delskill("A00N")
    end)
    local cs = 0
    local cs1 = 0
    local txsh1 = 500 * u:getdata("怪物强度")
    local txsh2 = 1000 * u:getdata("怪物强度")
    u:setflyheight(0)
    local wt1 = 2
    local wt2 = 0.5
    if u:getdata("噬星灾神阶段") == 3 then
      wt1 = 2
      wt2 = 0.3
    end
    u:buffset(u.handle, 9, "暂停")
    local dt = wt1 + wt2 * 5 + 1
    u:buffset(u.handle, dt, "无敌")
    u:settimedata("暗神永恒", dt)
    ac.loop(10, function(t)
      if u:hasdata("暗神-失败结束标记") then
        u:setflyheight(0)
        t:remove()
        return
      end
      cs = cs + 1
      cs1 = cs1 + 1
      u:setflyheight(cs * 5)
      if 10 <= cs1 then
        cs1 = 0
        EffectcreateArgs({
          effect = "war3mapImported\\BOSS_4D_guangzhu1.mdx",
          x = x,
          y = y,
          size = 30,
          height = -700 + cs * 5,
          zxz = GetRandomAngle(),
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "war3mapImported\\BOSS_4D_guangzhu1.mdx",
          x = x,
          y = y,
          size = 3,
          zxz = GetRandomAngle(),
          animespeed = 1
        })
      end
      if 200 <= cs then
        t:remove()
      end
    end)
    ac.wait(wt1 * 1000, function()
      local cs2 = 0
      ac.loop(wt2 * 1000, function(t)
        if u:hasdata("暗神-失败结束标记") then
          t:remove()
          return
        end
        cs2 = cs2 + 1
        ac.wait(1000, function()
          u:animeact(GetRandomInt(1, 2))
          u:animespeed(2)
        end)
        local jdc = false
        local yxb = false
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() then
            x, y = u:getxy()
            local x1, y1 = xq:getxy()
            local jd1 = AngleXY(x, y, x1, y1)
            local jl = DistanceXY(x, y, x1, y1)
            if not jdc then
              jdc = true
              u:setface(jd1)
            end
            local z1 = FsAngle(x, y, 1000, x1, y1, 0)
            EffectcreateArgs({
              effect = "war3mapImported\\BOSS_4D_zhishixian.mdx",
              x = x1,
              y = y1,
              size = 0.5,
              height = 0,
              zxz = jd1,
              yxz = z1,
              animespeed = 1.3
            })
            local dx, dy = x, y
            ac.wait(1000, function()
              local tx = EffectcreateArgs({
                effect = "war3mapImported\\BOSS_4D_danmu2.mdx",
                x = x,
                y = y,
                time = -1,
                size = 3,
                height = 1000,
                zxz = jd1,
                yxz = z1,
                animespeed = 1
              })
              local cs3 = 0
              ac.loop(10, function(t1)
                cs3 = cs3 + 1
                dx, dy = PolarXY(dx, dy, jl / 40, jd1)
                japi.EXSetEffectXY(tx, dx, dy)
                japi.EXSetEffectZ(tx, 1000 - 25.0 * cs3)
                if 40 <= cs3 then
                  if not yxb then
                    yxb = true
                    PlayGlobalSound(Sound_Anshen_baozha9)
                  end
                  xq:shockcamera(10, 0.15)
                  DestroyEffectLua(tx)
                  EffectcreateArgs({
                    effect = "war3mapImported\\BOSS_4D_guangzhu2.mdx",
                    x = x1,
                    y = y1,
                    time = 0.1,
                    size = 4,
                    height = 0,
                    zxz = jd1,
                    animespeed = 8
                  })
                  EffectcreateArgs({
                    effect = "BOSS_Anshen_NTX02.mdx",
                    x = x1,
                    y = y1,
                    time = 10,
                    size = 3.5,
                    height = 0,
                    zxz = jd1,
                    animespeed = 1
                  })
                  local cs4 = 0
                  ac.loop(100, function(t2)
                    cs4 = cs4 + 1
                    for _, xq1 in ac.selector():in_rangexy(x1, y1, 300):is_enemy(u.handle):ipairs() do
                      xq1 = getunit(xq1)
                      AnshenDamage(u, xq1, txsh1)
                    end
                    if 100 <= cs4 then
                      t2:remove()
                    end
                  end)
                  t1:remove()
                end
              end)
            end)
          end
        end)
        if 5 <= cs2 then
          ac.wait(1000, function()
            local g = CreateGroupLua()
            ForGroupLuaNew(Group_PlayHero, function(xq)
              if xq:isalive() then
                xq:groupadd(g)
              end
            end)
            local mb = Group_Randomunit(g)
            if mb == 0 then
              mb = u
            end
            local x1, y1 = mb:getxy()
            local jd = AngleXY(x, y, x1, y1)
            u:setface(jd)
            local dx, dy = PolarXY(x, y, 1000, jd)
            local jd2 = FsAngle(x, y, 1000, dx, dy, 0)
            EffectcreateArgs({
              effect = "war3mapImported\\BOSS_4D_guangzhu1.mdx",
              x = x,
              y = y,
              size = 2,
              height = 1000,
              zxz = jd,
              yxz = 90 + jd2,
              animespeed = 1
            })
            EffectcreateArgs({
              effect = "war3mapImported\\BOSS_4D_guangzhu1.mdx",
              x = x,
              y = y,
              size = 30,
              height = 1000,
              zxz = jd,
              yxz = 90 + jd2,
              animespeed = 1
            })
            u:setxy(dx, dy)
            u:setflyheight(0)
            u:deldata("免疫击退效果")
            u:animeact(10)
            unitmove({
              unit = u.handle,
              time = 2,
              distance = 2000,
              angle = jd,
              isfly = true,
              loops = {
                {
                  looptime = 0.1,
                  func = function(dx, dy)
                    for _, xq in ac.selector():in_rangexy(dx, dy, 400):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      AnshenDamage(u, xq, txsh2, true)
                    end
                  end
                },
                {
                  looptime = 0.2,
                  func = function(dx, dy)
                    EffectcreateArgs({
                      effect = "Anshen_New_02.mdl",
                      x = dx,
                      y = dy,
                      size = 3,
                      zxz = jd,
                      animespeed = 3
                    })
                    EffectcreateArgs({
                      effect = "Anshen_New_03.mdl",
                      x = dx,
                      y = dy,
                      size = 3,
                      zxz = jd,
                      animespeed = 3
                    })
                  end
                }
              },
              endfunc = function(dx, dy)
                u:setdata("免疫击退效果")
                u:animeact("stand")
              end
            })
          end)
          t:remove()
        end
      end)
    end)
  end,
  ["瞬移"] = function(u)
    if u:hasdata("暗神-失败结束标记") then
      return
    end
    local x, y = u:getxy()
    PlayGlobalSound(Sound_Anshen_chuansong3)
    local g = CreateGroupLua()
    ForGroupLuaNew(Group_PlayHero, function(xq)
      if xq:isalive() then
        xq:groupadd(g)
      end
    end)
    local mb = Group_Randomunit(g)
    if mb == 0 then
      mb = u
    end
    local x1, y1 = mb:getxy()
    local dx, dy = PolarXY(x1, y1, GetRandomReal(300, 800), GetRandomAngle())
    local jd = AngleXY(x, y, dx, dy)
    if u:hasdata("尾杀释放中") then
      dx, dy = u:getdata("星蚀界域X"), u:getdata("星蚀界域Y")
    end
    if u:getdata("噬星灾神阶段") == 3 then
      u:settimedata("暗神-寂灭暂停计时", 1)
    end
    u:animeact(4)
    u:animespeed(2)
    EffectcreateArgs({
      effect = "war3mapImported\\BOSS_4D_heidong4.mdx",
      x = x,
      y = y,
      time = 0.5,
      size = 3,
      height = -200,
      zxz = jd,
      animespeed = 1
    })
    ac.wait(200, function()
      u:animeact("stand")
      u:animespeed(1)
      EffectcreateArgs({
        effect = "war3mapImported\\BOSS_4D_heidong4.mdx",
        x = dx,
        y = dy,
        time = 0.5,
        size = 3,
        height = -200,
        zxz = jd,
        animespeed = 1
      })
      u:setxy(dx, dy)
      IssueImmediateOrder(u.handle, "stop")
      x, y = u:getxy()
      x1, y1 = mb:getxy()
      local jd = AngleXY(x, y, x1, y1)
      if u:hasdata("尾杀释放中") then
        jd = 90
      end
      u:setface(jd)
    end)
  end,
  ["蚀灭星陨"] = function(u, x, y)
    local txsh = 500 * u:getdata("怪物强度")
    local cs = 0
    ac.loop(100, function(t)
      if u:hasdata("暗神-失败结束标记") then
        t:remove()
        return
      end
      cs = cs + 1
      local jd = GetRandomAngle()
      local tx = EffectcreateArgs({
        effect = "war3mapImported\\BOSS_4D_zijian.mdx",
        x = x,
        y = y,
        time = -1,
        size = 3,
        height = 800,
        zxz = jd,
        yxz = -90,
        animespeed = 1
      })
      PlayGlobalSound(Anshen_zijian1)
      local cs1 = 0
      ac.loop(10, function(t1)
        cs1 = cs1 + 1
        japi.EXSetEffectZ(tx, 800 + 200 * cs1)
        if 10 <= cs1 then
          DestroyEffectLua(tx)
          t1:remove()
        end
      end)
      ac.wait(1100, function()
        PlayGlobalSound(Anshen_zijian2)
      end)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() then
          local x1, y1 = xq:getxy()
          EffectcreateArgs({
            effect = "war3mapImported\\BOSS_4D_zhishixian.mdx",
            x = x1,
            y = y1,
            size = 1,
            zxz = GetRandomAngle(),
            yxz = 90,
            animespeed = 1
          })
          ac.wait(1000, function()
            local tx1 = EffectcreateArgs({
              effect = "war3mapImported\\BOSS_4D_zijian.mdx",
              x = x1,
              y = y1,
              time = -1,
              size = 7,
              height = 2000,
              zxz = jd,
              yxz = 90,
              animespeed = 1
            })
            local cs2 = 0
            ac.loop(10, function(t1)
              cs2 = cs2 + 1
              japi.EXSetEffectZ(tx1, 2000 - 200 * cs2)
              if 10 <= cs2 then
                DestroyEffectLua(tx1)
                EffectcreateArgs({
                  effect = "war3mapImported\\BOSS_4D_guangzhu1.mdx",
                  x = x1,
                  y = y1,
                  size = 15,
                  height = -200,
                  zxz = GetRandomAngle(),
                  animespeed = 1
                })
                for _, xq1 in ac.selector():in_rangexy(x1, y1, 500):is_enemy(u.handle):ipairs() do
                  xq1 = getunit(xq1)
                  if Nandu_Choose >= 5 then
                    xq1:changedata("理智值", -20)
                    xq1:setdata("理智值损失时间", 10)
                    if xq1:getdata("理智值") < 0 then
                      xq1:setdata("理智值", 0)
                    end
                  end
                  AnshenDamage(u, xq1, txsh)
                end
                t1:remove()
              end
            end)
          end)
        end
      end)
      if 5 <= cs then
        t:remove()
      end
    end)
  end,
  ["渊咒蚀界"] = function(u, x, y)
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFF9966FF渊咒蚀界|r")
    else
      SendMsgAll("|cFFCC0000【暗星碰撞与蚀灭星陨撞击附带降低大量理智】|r")
    end
    local txsh1 = 500 * u:getdata("怪物强度")
    local txsh2 = 9999 * u:getdata("怪物强度")
    local txsh3 = 1000 * u:getdata("怪物强度")
    PlayGlobalSound(Sound_Anshen_feng1)
    local jd = GetRandomAngle()
    EffectcreateArgs({
      effect = "war3mapImported\\BOSS_4D_heidong4.mdx",
      x = x,
      y = y,
      time = 9,
      size = 5,
      height = -200,
      zxz = jd,
      animespeed = 1
    })
    local tx = EffectcreateArgs({
      effect = "war3mapImported\\BOSS_4D_heidong3.mdx",
      x = x,
      y = y,
      time = 9,
      size = 0.1,
      height = 500,
      zxz = jd,
      animespeed = 1
    })
    local cs = 0
    ac.loop(100, function(t)
      if u:hasdata("暗神-失败结束标记") then
        t:remove()
        return
      end
      cs = cs + 1
      if cs < 30 then
        japi.EXSetEffectSize(tx, cs / 15)
        japi.EXSetEffectZ(tx, 500 - cs * 13.3)
      end
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() then
          local x1, y1 = xq:getxy()
          local jd1 = AngleXY(x1, y1, x, y)
          unitmove({
            unit = xq.handle,
            time = 0.1,
            distance = 50,
            angle = jd1,
            isfly = false
          })
        end
      end)
      local dx, dy = PolarXY(x, y, 3600, GetRandomAngle())
      local jd2 = AngleXY(dx, dy, x, y)
      unifycreate({
        owner = u.handle,
        model = "war3mapImported\\BOSS_4D_danmu1.mdl",
        modelname = "暗矢",
        modelsize = 1.5,
        height = 100,
        damage = 0,
        damagetype = 5,
        x = dx,
        y = dy,
        time = 2,
        speed = 1800,
        volume = 60,
        angle = jd2,
        angleoffset = 0,
        attenua = 1,
        attenuacount = 1,
        life = 10,
        isbullet = false,
        isvest = false,
        isignorearmor = false,
        hitafterfunc = function(mj, xq, damage2)
          if Nandu_Choose >= 5 then
            xq:changedata("理智值", -20)
            xq:setdata("理智值损失时间", 10)
            if xq:getdata("理智值") < 0 then
              xq:setdata("理智值", 0)
            end
          end
          AnshenDamage(u, xq, txsh1)
        end
      })
      for _, xq in ac.selector():in_rangexy(x, y, 500):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        AnshenDamage(u, xq, txsh2)
      end
      if 70 <= cs then
        AnshenSkill["蚀灭星陨"](u, x, y)
        ac.wait(2000, function()
          StopSoundBJ(Sound_Anshen_feng1, true)
        end)
        t:remove()
      end
    end)
    local cs1 = 0
    ac.loop(100, function(t1)
      if u:hasdata("暗神-失败结束标记") then
        t1:remove()
        return
      end
      cs1 = cs1 + 1
      local dx, dy = PolarXY(x, y, GetRandomReal(0, 6000), GetRandomAngle())
      EffectcreateArgs({
        effect = "war3mapImported\\BOSS_4D_zhishixian.mdx",
        x = dx,
        y = dy,
        size = 1,
        zxz = GetRandomAngle(),
        yxz = 90,
        animespeed = 1
      })
      ac.wait(500, function()
        if u:hasdata("暗神-失败结束标记") then
          return
        end
        EffectcreateArgs({
          effect = "war3mapImported\\BOSS_4D_guangzhu1.mdx",
          x = dx,
          y = dy,
          size = 5,
          zxz = GetRandomAngle(),
          animespeed = 1
        })
        for _, xq in ac.selector():in_rangexy(dx, dy, 200):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          AnshenDamage(u, xq, txsh3)
        end
      end)
      if 70 <= cs1 then
        t1:remove()
      end
    end)
  end,
  ["逆反物质"] = function(u)
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFF9966FF逆反物质|r", 30)
      SendMsgAll("|cFF9966FF[不断召唤反物质黑洞(上限10个),击破后产生2秒黑曜物质(可以拾取);反物质黑洞达到6个时BOSS获得[反物质悖流]]|r", 30)
    end
    local x, y = u:getdata("星蚀界域X"), u:getdata("星蚀界域Y")
    local jd = u:getface()
    local boss = u
    local jishi = 0
    local time1 = ac.loop(500, function(t)
      if u:hasdata("暗神-失败结束标记") then
        t:remove()
        return
      end
      jishi = jishi + 0.5
      ForGroupLuaNew(fwzg, function(xq)
        xq:animeact("stand")
      end)
      local count = Group_Counts(fwzg)
      if 6 <= count then
        if not u:hasdata("反物质状态") and not u:hasdata("暗神-二阶段尾杀") then
          u:setdata("反物质状态")
          BuffUI.apply({
            id = "反物质悖流",
            duration = 99999
          })
        end
      elseif u:hasdata("反物质状态") then
        u:deldata("反物质状态")
        BuffUI.remove("反物质悖流")
      end
      if count < 10 then
        local add = 3
        if count <= 2 then
          add = 1
        end
        if jishi >= add + count then
          jishi = 0
          local dx, dy = PolarXY(x, y, GetRandomReal(300, 1400), GetRandomAngle())
          local mj = u:createunit("u04O", dx, dy, jd)
          mj:groupadd(HellGroup)
          mj:groupadd(fwzg)
          SetUnitState(mj.handle, UNIT_STATE_MAX_LIFE, 10000)
          mj:setmaxhp(8)
          TriggerRegisterUnitEvent(DamageSystemTrg, mj.handle, EVENT_UNIT_DAMAGED)
          mj:setdata("系统-免疫特效伤害")
          mj:setdata("免疫生命损耗")
          mj:setdata("免疫击退效果")
          mj:setdata("免疫生命修改")
          mj:setdata("免疫抑制恢复")
          mj:setdata("免疫负面效果")
          mj:setdata("系统-单次受伤1")
          mj:setdata("暗神-反物质黑洞")
          mj:setdata("免疫即死效果")
          mj:setdata("免疫混乱改变所属")
          mj:addstexiao("暗神-反物质黑洞", "伤害显示后效果", function(args)
            local tg = args.tg
            local u = args.u
            local info = args.damageinfo
            if info.damage >= tg:gethp() then
              info.damage = 0
              tg:setdata("暗神永恒")
              local dx, dy = tg:getxy()
              tg:groupremove(fwzg)
              tg:groupremove(HellGroup)
              SetUnitInvulnerable(tg.handle, true)
              tg:addskill("Aloc")
              tg:animeact("death")
              tg:timetoremove(2)
              ac.wait(1, function()
                local tx = EffectcreateArgs({
                  effect = "war3mapImported\\BOSS_4D_heiqiu2.mdx",
                  x = dx,
                  y = dy,
                  time = -1,
                  size = 1,
                  height = 100,
                  zxz = GetRandomAngle(),
                  animespeed = 1
                })
                local cs = 0
                local maxtime = 30
                if Nandu_Choose <= 4 or PlayerCount == 1 then
                  maxtime = 40
                end
                ac.loop(100, function(t1)
                  local b = false
                  cs = cs + 1
                  ForGroupLuaNew(Group_PlayHero, function(xq)
                    if xq:isalive() then
                      local ax, ay = xq:getxy()
                      local dis = DistanceXY(dx, dy, ax, ay)
                      if dis <= 125 then
                        local add = 3
                        if Nandu_Choose <= 4 then
                          add = 5
                        end
                        xq:changedata("理智值", add)
                        if xq:getdata("理智值") >= 100 then
                          xq:setdata("理智值", 100)
                        end
                        if xq:hasdata("暗神-复活时间") and xq:getdata("暗神-复活时间") > 10 then
                          xq:changedata("暗神-复活时间", -1)
                        end
                        DestroyEffectLua(tx)
                        b = true
                        EffectcreateArgs({
                          effect = "war3mapImported\\BOSS_4D_guangzhu1.mdx",
                          x = dx,
                          y = dy,
                          size = 3,
                          zxz = GetRandomAngle(),
                          animespeed = 1
                        })
                      end
                    end
                  end)
                  if b then
                    if boss:getdata("噬星灾神阶段") == 1 and not boss:hasdata("尾杀释放中") then
                      boss:losshp(u, 0, 0, 2)
                    end
                    ForGroupLuaNew(Group_AllHero, function(xq)
                      if xq:isalive() then
                        xq:changedata("黑曜物质层数", 1)
                      end
                    end)
                    t1:remove()
                  end
                  if cs >= maxtime then
                    DestroyEffectLua(tx)
                    t1:remove()
                  end
                end)
              end)
            end
          end)
          SendMsgAll("|cFF9966FF当前反物质黑洞数量:" .. Group_Counts(fwzg))
        end
      else
        jishi = 0
      end
    end)
    local time2 = ac.loop(5000, function(t2)
    end)
    u:setdata("逆反物质计时器1", time1)
    u:setdata("逆反物质计时器2", time2)
  end,
  ["噬星"] = function(u)
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFF9966FF噬星|r", 30)
      SendMsgAll("|cFF9966FF[双星持续向BOSS发射正负能量;正负能量之和大于250且正负能量都大于0时爆炸即死全场;英雄可以抵挡能量流]|r", 30)
    end
    local x, y = u:getdata("星蚀界域X"), u:getdata("星蚀界域Y")
    local jd = u:getface()
    u:setxy(x, y)
    u:setdata("一阶段尾杀释放中")
    u:setdata("噬星正能量", 0)
    u:setdata("噬星负能量", 0)
    local ttR = flytext({
      text = "",
      size = 13,
      time = 30,
      x = x + 40,
      y = y,
      r = 255,
      g = 0,
      b = 0,
      height = 200,
      xspeed = 0,
      yspeed = 0
    })
    local ttP = flytext({
      text = "",
      size = 13,
      time = 30,
      x = x - 140,
      y = y,
      r = 153,
      g = 102,
      b = 255,
      height = 200,
      xspeed = 0,
      yspeed = 0
    })
    local max = 75
    local max2 = 300
    local pengzhuang = 95
    if Nandu_Choose >= 5 then
      max = 25
      max2 = 250
    end
    
    local function baozha()
      local x1, y1 = u:getxy()
      if u:getdata("噬星正能量") + u:getdata("噬星负能量") >= max2 and u:getdata("噬星正能量") > max and u:getdata("噬星负能量") > max then
        u:setdata("噬星正能量", 0)
        u:setdata("噬星负能量", 0)
        SetTextTagText(ttR, "0", TextTagSize2Height(13))
        SetTextTagText(ttP, "0", TextTagSize2Height(13))
        PlayGlobalSound(Sound_Anshen_baozha5)
        PlayGlobalSound(Sound_Anshen_baozha7)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() then
            AnshenJisi(u, xq)
          end
        end)
        local cs2 = 0
        ac.loop(100, function(t2)
          cs2 = cs2 + 1
          EffectcreateArgs({
            effect = "war3mapImported\\BOSS_4D_guangzhu1.mdx",
            x = x1,
            y = y1,
            size = 20,
            height = -400,
            zxz = GetRandomAngle(),
            animespeed = 1
          })
          EffectcreateArgs({
            effect = "war3mapImported\\BOSS_4D_shandian1.mdx",
            x = x1,
            y = y1,
            time = 0.1,
            size = 30,
            zxz = GetRandomAngle(),
            animespeed = 0.2
          })
          if 10 <= cs2 then
            t2:remove()
          end
        end)
      end
    end
    
    local cs = 0
    ac.loop(100, function(t)
      if u:hasdata("暗神-失败结束标记") then
        SetTextTagText(ttR, "", TextTagSize2Height(13))
        SetTextTagText(ttP, "", TextTagSize2Height(13))
        t:remove()
        return
      end
      cs = cs + 1
      u:sethp(u:getperhp() + 0.33, true)
      local x1, y1 = u:getdata("双星1X"), u:getdata("双星1Y")
      local x3, y3 = u:getdata("双星2X"), u:getdata("双星2Y")
      ac.wait(1, function()
        local tx = EffectcreateArgs({
          effect = "war3mapImported\\BOSS_4D_danmu1.mdx",
          x = x1,
          y = y1,
          time = -1,
          size = 1,
          height = 100,
          zxz = jd,
          animespeed = 1
        })
        local tx1 = EffectcreateArgs({
          effect = "BOSS_4D_danmu3.mdx",
          x = x3,
          y = y3,
          time = -1,
          size = 1,
          height = 100,
          zxz = jd,
          animespeed = 1
        })
        local cs1 = 0
        ac.loop(10, function(t1)
          cs1 = cs1 + 1
          local x2, y2 = u:getxy()
          local jd1 = AngleXY(x1, y1, x2, y2)
          x1, y1 = PolarXY(x1, y1, 20, jd1)
          japi.EXSetEffectXY(tx, x1, y1)
          for _, xq in ac.selector():in_rangexy(x1, y1, pengzhuang):ipairs() do
            xq = getunit(xq)
            if xq.handle == u.handle then
              u:setdata("噬星正能量", u:getdata("噬星正能量") + 3)
              baozha()
              DestroyEffectLua(tx)
              t1:remove()
            end
            if xq.handle ~= u.handle and xq:is_enemy(u.handle) then
              DestroyEffectLua(tx)
              t1:remove()
            end
          end
          if 500 <= cs1 then
            DestroyEffectLua(tx)
            t1:remove()
          end
        end)
        local cs2 = 0
        ac.loop(10, function(t2)
          cs2 = cs2 + 1
          local x4, y4 = u:getxy()
          local jd2 = AngleXY(x3, y3, x4, y4)
          x3, y3 = PolarXY(x3, y3, 20, jd2)
          japi.EXSetEffectXY(tx1, x3, y3)
          for _, xq in ac.selector():in_rangexy(x3, y3, pengzhuang):ipairs() do
            xq = getunit(xq)
            if xq.handle == u.handle then
              u:setdata("噬星负能量", u:getdata("噬星负能量") + 3)
              baozha()
              DestroyEffectLua(tx1)
              t2:remove()
            end
            if xq.handle ~= u.handle and xq:is_enemy(u.handle) then
              DestroyEffectLua(tx1)
              t2:remove()
            end
          end
          if 500 <= cs2 then
            DestroyEffectLua(tx1)
            t2:remove()
          end
        end)
      end)
      SetTextTagText(ttR, tostring(math.floor(u:getdata("噬星负能量"))), TextTagSize2Height(13))
      SetTextTagText(ttP, tostring(math.floor(u:getdata("噬星正能量"))), TextTagSize2Height(13))
      if 300 <= cs then
        ac.wait(3000, function()
          japi.EXSetEffectSize(u:getdata("星蚀界域"), 1.17)
          u:setdata("暗神-界域大小", 1750)
          u:deldata("暗神永恒")
          u:deldata("一阶段尾杀释放中")
          u:deldata("尾杀释放中")
          u:setdata("噬星灾神阶段", 2)
          u:setdata("循环次数", 0)
          u:setmaxhp(2000000000)
          anshen_skillloop(u, 1)
          ac.wait(3000, function()
            AnshenSkill["旧日恐惧"](u)
          end)
        end)
        t:remove()
      end
    end)
  end,
  ["旧日恐惧"] = function(u)
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFF9966FF旧日恐惧|r", 30)
      SendMsgAll("|cFF9966FF[场地中央召唤恐惧核心,英雄靠近时降低全队星渊恐惧层数;星渊恐惧存在时BOSS获得[超维晶域];星渊恐惧每秒自然降低1层]|r", 30)
    end
    local x, y = u:getdata("星蚀界域X"), u:getdata("星蚀界域Y")
    local jd = u:getface()
    local mjtx = Effectcreate("war3mapImported\\BOSS_4D_heiqiu3.mdl", x, y, -1)
    u:setdata("恐惧核心", mjtx)
    u:setdata("星渊恐惧层数", 50)
    BuffUI.apply({
      id = "超维晶域",
      duration = 99999
    })
    BuffUI.apply({
      id = "星渊恐惧"
    })
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:setdata("星渊恐惧层数", 50)
      xq:setdata("超维晶域")
    end)
    local dcs = 0
    ac.loop(500, function(t)
      if not u:hasdata("恐惧核心") then
        BuffUI.remove("超维晶域")
        BuffUI.remove("星渊恐惧")
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:deldata("超维晶域")
        end)
        t:remove()
      else
        dcs = dcs + 1
        if dcs == 2 then
          dcs = 0
          u:changedata("星渊恐惧层数", -1)
        end
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() then
            local x1, y1 = xq:getxy()
            local jl = DistanceXY(x1, y1, x, y)
            if jl <= 375 then
              local jd1 = AngleXY(x1, y1, x, y)
              u:changedata("星渊恐惧层数", -1)
              ForGroupLuaNew(Group_PlayHero, function(xq2)
                if xq2:isalive() then
                  xq2:changedata("理智值", 0.5)
                  if xq2:getdata("理智值") >= 100 then
                    xq2:setdata("理智值", 100)
                  end
                end
              end)
              local tx = EffectcreateArgs({
                effect = "war3mapImported\\BOSS_4D_danmu1.mdx",
                x = x1,
                y = y1,
                time = 0.2,
                size = 1,
                height = 150,
                zxz = jd1,
                animespeed = 1
              })
              effectmove({
                effect = tx,
                time = 0.2,
                distance = jl,
                angle = jd1
              })
            end
          end
        end)
        local cs = u:getdata("星渊恐惧层数")
        if cs <= 0 then
          cs = 0
        end
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:setdata("星渊恐惧层数", cs)
          xq:setdata("超维晶域")
        end)
        if 0 >= u:getdata("星渊恐惧层数") then
          BuffUI.remove("超维晶域")
          BuffUI.remove("星渊恐惧")
          DestroyEffectLua(mjtx)
          BuffUI.apply({
            id = "星渊恐惧再生",
            duration = 50
          })
          ForGroupLuaNew(Group_PlayHero, function(xq)
            xq:deldata("超维晶域")
          end)
          do
            local dcs2 = 0
            local ti = ac.loop(1000, function(timer)
              dcs2 = dcs2 + 1
              if dcs2 == 50 then
                AnshenSkill["旧日恐惧"](u)
                timer:remove()
              end
            end)
            u:setdata("恐惧核心再生计时器", ti)
            t:remove()
          end
        end
      end
    end)
  end,
  ["陨星降临"] = function(u)
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFF9966FF陨星降临|r")
    end
    anshen_skillloop(u, 10)
    local x, y = u:getxy()
    local jd = u:getface()
    local txsh = 500 * u:getdata("怪物强度")
    local sj = GetRandomInt(10, 100)
    local cs = 0
    local g = CreateGroupLua()
    ForGroupLuaNew(Group_PlayHero, function(xq)
      if xq:isalive() then
        xq:groupadd(g)
      end
    end)
    local mb = Group_Randomunit(g)
    if mb == 0 then
      mb = u
    end
    ac.loop(100, function(t)
      cs = cs + 1
      if cs <= sj - 8 then
        x, y = mb:getxy()
      end
      EffectcreateArgs({
        effect = "war3mapImported\\BOSS_4D_guangzhu1.mdx",
        x = x,
        y = y,
        size = 2,
        height = 0,
        zxz = GetRandomAngle(),
        animespeed = 1
      })
      if cs >= sj then
        ac.wait(100, function()
          PlayGlobalSound(Sound_Anshen_baozha8)
          PlayGlobalSound(Sound_Anshen_baozha5)
          EffectcreateArgs({
            effect = "war3mapImported\\BOSS_4D_zhendangbo2.mdx",
            x = x,
            y = y,
            size = 3,
            height = 10,
            zxz = GetRandomAngle(),
            animespeed = GetRandomReal(3, 5)
          })
          for _, xq in ac.selector():in_rangexy(x, y, 1200):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            AnshenDamage(u, xq, txsh)
          end
          ac.wait(1, function()
            AnshenSkill["陨星降临扩散"](u, x, y, true)
          end)
        end)
        t:remove()
      end
    end)
  end,
  ["陨星降临扩散"] = function(u, x, y, boolean, string)
    string = string or ""
    local txsh = 500 * u:getdata("怪物强度")
    local dx, dy = x, y
    if string == "双星1" then
      x, y = u:getdata("双星1X"), u:getdata("双星1Y")
      dx, dy = u:getdata("双星1X"), u:getdata("双星1Y")
    end
    if string == "双星2" then
      x, y = u:getdata("双星2X"), u:getdata("双星2Y")
      dx, dy = u:getdata("双星2X"), u:getdata("双星2Y")
    end
    local b = boolean
    if boolean == nil then
      b = false
    end
    local size = 1
    ac.timer(200, 5, function()
      size = size + 0.5
      EffectcreateArgs({
        effect = "BOSS_4D_quan123.mdx",
        x = x,
        y = y,
        time = 0,
        size = size,
        height = 0,
        zxz = 0,
        animespeed = 4
      })
    end)
    local cs = 0
    local b1 = false
    local b2 = false
    ac.loop(100, function(t)
      cs = cs + 1
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() and not xq:hasdata("原点寄生-免疫陨星降临") then
          local dx1, dy1 = xq:getxy()
          local jl = DistanceXY(dx, dy, dx1, dy1)
          if jl <= 200 + 55 * cs then
            AnshenDamage(u, xq, txsh)
          end
        end
      end)
      if b == true then
        local dx2, dy2 = u:getdata("双星1X"), u:getdata("双星1Y")
        local dx3, dy3 = u:getdata("双星2X"), u:getdata("双星2Y")
        local jl1 = DistanceXY(dx, dy, dx2, dy2)
        local jl2 = DistanceXY(dx, dy, dx3, dy3)
        if jl1 <= 200 + 55 * cs and b1 == false then
          b1 = true
          local cs1 = 0
          ac.loop(2000, function(t1)
            cs1 = cs1 + 1
            ac.wait(1000, function()
              AnshenSkill["陨星降临扩散"](u, dx2, dy2, false, "双星1")
            end)
            if 5 <= cs1 then
              t1:remove()
            end
          end)
        end
        if jl2 <= 200 + 55 * cs and b2 == false then
          b2 = true
          do
            local cs2 = 0
            ac.loop(2000, function(t1)
              cs2 = cs2 + 1
              ac.wait(1000, function()
                AnshenSkill["陨星降临扩散"](u, dx3, dy3, false, "双星2")
              end)
              if 5 <= cs2 then
                t1:remove()
              end
            end)
          end
        end
      end
      if 10 <= cs then
        t:remove()
      end
    end)
  end,
  ["原点寄生"] = function(u)
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFF9966FF原点寄生|r")
    end
    anshen_skillloop(u, 3)
    local g = CreateGroupLua()
    ForGroupLuaNew(Group_PlayHero, function(xq)
      if xq:isalive() then
        xq:groupadd(g)
      end
    end)
    local mb = Group_Randomunit(g)
    if mb == 0 then
      mb = u
    end
    mb:effectadd("war3mapImported\\BOSS_4D_heidong.mdx", "head", 10)
    ac.timer(2000, 5, function()
      if u:hasdata("暗神-失败结束标记") then
        return
      end
      local dx, dy = mb:getxy()
      mb:settimedata("原点寄生-免疫陨星降临", 1.8)
      AnshenSkill["陨星降临扩散"](u, dx, dy, false)
    end)
  end,
  ["神诉"] = function(u)
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFF9966FF神诉|r")
    end
    anshen_skillloop(u, 10)
    local txsh = 500 * u:getdata("怪物强度")
    local x, y = u:getxy()
    local jd = u:getface()
    local g = CreateGroupLua()
    ForGroupLuaNew(Group_PlayHero, function(xq)
      if xq:isalive() then
        xq:groupadd(g)
      end
    end)
    local mb = Group_Randomunit(g)
    if mb == 0 then
      mb = u
    end
    local dx, dy = mb:getxy()
    local sj = GetRandomInt(10, 100)
    if u:getdata("噬星灾神阶段") == 3 then
      sj = GetRandomInt(35, 50)
    end
    local cs = 0
    ac.loop(100, function(t)
      if u:hasdata("暗神-失败结束标记") then
        t:remove()
        return
      end
      cs = cs + 1
      if cs <= sj - 8 then
        dx, dy = mb:getxy()
      end
      EffectcreateArgs({
        effect = "war3mapImported\\BOSS_4D_shenchi1.mdx",
        x = dx,
        y = dy,
        size = 1.5,
        height = 100,
        zxz = GetRandomAngle(),
        animespeed = 1
      })
      if cs >= sj then
        ac.wait(100, function()
          PlayGlobalSound(Sound_Anshen_baozha5)
          PlayGlobalSound(Sound_Anshen_baozha7)
          mb:shockcamera(300, 0.2)
          EffectcreateArgs({
            effect = "war3mapImported\\BOSS_4D_shenchi2.mdx",
            x = dx,
            y = dy,
            time = 60,
            size = 0.7,
            height = 10,
            zxz = GetRandomAngle(),
            animespeed = 1
          })
          EffectcreateArgs({
            effect = "war3mapImported\\BOSS_4D_shenchi3.mdx",
            x = dx,
            y = dy,
            time = 60,
            size = 4,
            height = 10,
            zxz = GetRandomAngle(),
            animespeed = 1
          })
          EffectcreateArgs({
            effect = "war3mapImported\\BOSS_4D_heiwu3.mdx",
            x = dx,
            y = dy,
            time = 60,
            size = 1,
            height = 10,
            zxz = GetRandomAngle(),
            animespeed = 1
          })
          EffectcreateArgs({
            effect = "war3mapImported\\BOSS_4D_zhendangbo2.mdx",
            x = x,
            y = y,
            size = 1,
            height = 10,
            zxz = GetRandomAngle(),
            animespeed = 3
          })
          local cs1 = 0
          ac.loop(100, function(t1)
            if u:hasdata("暗神-失败结束标记") then
              t1:remove()
              return
            end
            cs1 = cs1 + 1
            for _, xq1 in ac.selector():in_rangexy(dx, dy, 700):is_enemy(u.handle):ipairs() do
              xq1 = getunit(xq1)
              AnshenDamage(u, xq1, txsh)
              if xq1:isingroup(Group_AllHero) then
                xq1:curetili(-1)
              end
            end
            if 600 <= cs1 then
              t1:remove()
            end
          end)
        end)
        t:remove()
      end
    end)
  end,
  ["坠魇"] = function(u)
    local txsh = 500 * u:getdata("怪物强度")
    local x, y = u:getdata("星蚀界域X"), u:getdata("星蚀界域Y")
    u:setxy(x, y)
    japi.EXSetEffectSize(u:getdata("星蚀界域"), 1)
    u:setdata("暗神-界域大小", 1500)
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFF9966FF坠魇|r", 30)
      SendMsgAll("|cFF9966FF[BOSS不断恢复生命值,超量恢复转换为10倍生命上限;星蚀界域覆盖全场,并在场内不断生成梦魇之核,英雄拾取时获得3秒梦魇之核状态(免疫场地效果)]|r", 30)
    end
    u:deldata("暗神永恒")
    local x, y = u:getxy()
    local jd = u:getface()
    if u:hasdata("逆反物质计时器1") then
      local ti = u:getdata("逆反物质计时器1")
      ti:remove()
      u:deldata("逆反物质计时器1")
    end
    if u:hasdata("逆反物质计时器2") then
      local ti = u:getdata("逆反物质计时器2")
      ti:remove()
      u:deldata("逆反物质计时器2")
    end
    if u:hasdata("恐惧核心再生计时器") then
      local ti = u:getdata("恐惧核心再生计时器")
      ti:remove()
      u:deldata("恐惧核心再生计时器")
      BuffUI.remove("星渊恐惧再生")
    end
    if u:hasdata("恐惧核心") then
      local mjtx = u:getdata("恐惧核心")
      DestroyEffectLua(mjtx)
      u:deldata("恐惧核心")
    end
    if u:hasdata("反物质状态") then
      u:deldata("反物质状态")
      BuffUI.remove("反物质悖流")
    end
    BuffUI.remove("超维晶域")
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:deldata("超维晶域")
    end)
    ForGroupLuaNew(fwzg, function(xq)
      xq:groupremove(fwzg)
      xq:remove()
    end)
    u:setdata("暗神-二阶段尾杀")
    for i = 1, 10 do
      EffectcreateArgs({
        effect = "war3mapImported\\BOSS_4D_guangzhu1.mdx",
        x = x,
        y = y,
        size = GetRandomReal(10, 30),
        height = -400,
        zxz = GetRandomAngle(),
        animespeed = GetRandomReal(1, 3)
      })
    end
    EffectcreateArgs({
      effect = "war3mapImported\\BOSS_4D_heiwu2.mdx",
      x = x,
      y = y,
      time = 30,
      size = 3,
      height = 10,
      zxz = GetRandomAngle(),
      animespeed = 1
    })
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:setdata("梦魇之核时间", 3)
    end)
    BuffUI.apply({
      id = "梦魇之核",
      duration = 3
    })
    local cs = 0
    local cs1 = 0
    local time = 25
    local xs = 10
    if Nandu_Choose <= 4 then
      time = 35
      xs = 5
    end
    if PlayerCount == 1 then
      time = time + 5
    end
    if Group_Counts(Group_PlayHero) == 1 then
      xs = xs * 0.5
    end
    ac.loop(100, function(t)
      if u:hasdata("暗神-失败结束标记") then
        t:remove()
        return
      end
      if u:getperhp() >= 99 then
        u:changemaxhp(5000000 * xs)
      else
        u:sethp(u:getperhp() + 1, true)
      end
      cs = cs + 1
      cs1 = cs1 + 1
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() and xq:getdata("梦魇之核时间") <= 0 then
          AnshenDamage(u, xq, txsh)
          if xq:getdata("黑曜物质层数") >= 1 then
            xq:changedata("黑曜物质层数", -1)
          end
        end
        if xq:getdata("梦魇之核时间") > 0 then
          xq:changedata("梦魇之核时间", -0.1)
        end
      end)
      EffectcreateArgs({
        effect = "war3mapImported\\BOSS_4D_xuli1.mdx",
        x = x,
        y = y,
        size = 5,
        height = 200,
        zxz = GetRandomAngle(),
        animespeed = 3
      })
      if 2 <= cs1 then
        cs1 = 0
        local dx, dy = PolarXY(x, y, GetRandomReal(300, 1600), GetRandomAngle())
        local tx = EffectcreateArgs({
          effect = "war3mapImported\\BOSS_4D_heiqiu2.mdx",
          x = dx,
          y = dy,
          time = time * 0.1,
          size = 1,
          height = 100,
          zxz = GetRandomAngle(),
          animespeed = 1
        })
        local cs2 = 0
        local b = false
        ac.loop(100, function(t1)
          cs2 = cs2 + 1
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if xq:isalive() then
              local ax, ay = xq:getxy()
              local dis = DistanceXY(dx, dy, ax, ay)
              if dis <= 125 then
                b = true
                ForGroupLuaNew(Group_PlayHero, function(xq2)
                  xq2:setdata("梦魇之核时间", 3)
                  if xq2:isalive() then
                    if PlayerCount == 1 then
                      xq2:changedata("黑曜物质层数", 2)
                    else
                      xq2:changedata("黑曜物质层数", 1)
                    end
                  end
                end)
                BuffUI.apply({
                  id = "梦魇之核",
                  duration = 3
                })
              end
            end
          end)
          if b then
            DestroyEffectLua(tx)
            EffectcreateArgs({
              effect = "war3mapImported\\BOSS_4D_guangzhu1.mdx",
              x = dx,
              y = dy,
              size = 3,
              zxz = GetRandomAngle(),
              animespeed = 1
            })
            t1:remove()
          end
          if cs2 >= time then
            t1:remove()
          end
        end)
      end
      if 300 <= cs then
        Boolean_Anshen_Sanjieduan = true
        StopSoundBJ(Sound_Anshen_1, true)
        AnshenSkill["三阶段转场"](u)
        ac.wait(3000, function()
          ForGroupLuaNew(Group_AllHero, function(xq)
            local sy = xq.ownerid
            xq:setdata("暗神-无光之视")
            xq:deldata("暗神-旧日凝视")
          end)
          BuffUI.apply({
            id = "无光之视",
            duration = 99999
          })
          BuffUI.remove("旧日凝视")
          u:sethp(100, true)
          u:deldata("暗神永恒")
          u:deldata("尾杀释放中")
          u:setdata("噬星灾神阶段", 3)
          anshen_jieduan3skillloop(u)
        end)
        t:remove()
      end
    end)
  end,
  ["三阶段转场"] = function(u)
    local x, y = u:getxy()
    local jd = u:getface()
    if Nandu_Choose >= 5 then
      u:setdata("暗神永恒")
    end
    PlayGlobalSound(Sound_Anshen_heidong2)
    for i = 1, 3 do
      local tx = EffectcreateArgs({
        effect = "war3mapImported\\BOSS_4D_heiwu4.mdx",
        x = x,
        y = y,
        time = 1.5,
        size = 10,
        height = 100,
        zxz = jd,
        animespeed = 4
      })
      local cs = 0
      ac.loop(10, function(t)
        cs = cs + 1
        x, y = u:getxy()
        japi.EXSetEffectXY(tx, x, y)
        if 150 <= cs then
          t:remove()
        end
      end)
    end
    local tx = EffectcreateArgs({
      effect = "war3mapImported\\BOSS_4D_heidong3.mdx",
      x = x,
      y = y,
      time = 2,
      size = 5,
      height = 100,
      zxz = jd,
      animespeed = 4
    })
    local cs = 0
    ac.loop(10, function(t)
      cs = cs + 1
      x, y = u:getxy()
      japi.EXSetEffectXY(tx, x, y)
      if cs <= 100 then
        japi.EXSetEffectSize(tx, cs / 15)
      end
      if 200 <= cs then
        t:remove()
      end
    end)
    u:animeact("stand")
    u:setdata("暗神-三阶段转场中")
    ForGroupLuaNew(Group_PlayHero, function(xq)
      local p = getplayer(xq.owner)
      p:setcameraheight(1000, 0.4)
      SetCameraTargetControllerNoZForPlayer(xq.owner, u.handle, 0, 0, false)
      ac.wait(400, function()
        p:setcameraheight(2000, 0.4)
      end)
      ac.wait(1200, function()
        p:setcameraheight(-800, 0.6)
      end)
      ac.wait(2900, function()
        local dx, dy = u:getdata("星蚀界域X"), u:getdata("星蚀界域Y")
        local camheight = 2850
        if u:hasdata("星渊") then
          camheight = 3250
          SetCameraTargetControllerNoZForPlayer(xq.owner, xq.handle, 0, 0, false)
        else
          SetCameraTargetControllerNoZForPlayer(xq.owner, u.handle, 0, 0, false)
        end
        xq:setxy(dx, dy)
        IssueImmediateOrder(xq.handle, "stop")
        xq:setdata("位移点X", dx)
        xq:setdata("位移点Y", dy)
        ac.wait(40, function()
          ResetToGameCamera(0.0)
          ac.wait(10, function()
            p:setcameraheight(camheight, 0)
          end)
        end)
        ac.wait(100, function()
          p:setcameraheight(camheight, 0)
        end)
        ac.wait(750, function()
          p:setcameraheight(camheight, 0)
        end)
      end)
    end)
    SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, -90, 0.9)
    ac.wait(1200, function()
      CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 0.6, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 10.0, 0.0, 0.0, 0.0)
    end)
    ac.wait(2899, function()
      CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 1, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 10.0, 0.0, 0.0, 0.0)
      local dx, dy = u:getdata("星蚀界域X"), u:getdata("星蚀界域Y")
      local dx1, dy1 = u:getdata("星蚀界域X"), u:getdata("星蚀界域Y")
      dx1, dy1 = PolarXY(dx1, dy1, 1800, 90)
      IssueImmediateOrder(u.handle, "stop")
      if u:hasdata("星渊") then
        ac.wait(300, function()
          u:deldata("星渊")
        end)
        u:setxy(dx1, dy1)
      else
        u:setxy(dx, dy)
      end
      u:setface(-90)
      ac.wait(40, function()
        ac.wait(500, function()
          u:deldata("暗神永恒")
          u:deldata("暗神-三阶段转场中")
          u:settimedata("暗神-寂灭暂停计时", 1)
        end)
      end)
    end)
  end,
  ["万象呓语"] = function(u)
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFF9966FF万象呓语|r", 30)
    end
    local txsh = 500 * u:getdata("怪物强度")
    local x, y = u:getxy()
    local jd = u:getface()
    PlayGlobalSound(Sound_Anshen_xuli1)
    local cs = 0
    u:animeact(3)
    u:animespeed(0.5)
    ac.loop(100, function(t)
      cs = cs + 1
      EffectcreateArgs({
        effect = "war3mapImported\\BOSS_4D_xuli1.mdx",
        x = x,
        y = y,
        size = cs,
        height = 200,
        zxz = GetRandomAngle(),
        animespeed = 3
      })
      if 20 <= cs then
        u:animespeed(1)
        ac.wait(500, function()
          PlayGlobalSound(Sound_Anshen_baozha6)
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if xq:isalive() then
              xq:shockcamera(100, 0.5)
            end
          end)
          local cs1 = 0
          ac.loop(5, function(t1)
            cs1 = cs1 + 1
            unifycreate({
              owner = u.handle,
              model = "war3mapImported\\BOSS_4D_danmu1.mdl",
              modelname = "暗矢",
              modelsize = 1.5,
              height = 100,
              damage = 0,
              damagetype = 5,
              x = x,
              y = y,
              time = 2,
              speed = 6000,
              volume = 90,
              angle = GetRandomAngle(),
              angleoffset = 0,
              attenua = 1,
              attenuacount = 1,
              life = 10,
              isbullet = false,
              isvest = false,
              isignorearmor = false,
              hitafterfunc = function(mj, xq, damage2)
                AnshenDamage(u, xq, txsh, true)
              end
            })
            if 50 <= cs1 then
              t1:remove()
            end
          end)
        end)
        ac.wait(2000, function()
          u:animeact(12)
          AnshenSkill["渊咒蚀界"](u, x, y)
        end)
        t:remove()
      end
    end)
  end,
  ["黯蚀棱镜"] = function(u)
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFF9966FF黯蚀棱镜|r")
    end
    local txsh = 1000 * u:getdata("怪物强度")
    local x, y = u:getxy()
    local jd = u:getface()
    local g = CreateGroupLua()
    ForGroupLuaNew(Group_PlayHero, function(xq)
      if xq:isalive() then
        xq:groupadd(g)
      end
    end)
    local mb = Group_Randomunit(g)
    if mb == 0 then
      mb = u
    end
    PlayGlobalSound(Sound_Anshen_xuli1)
    ac.wait(1, function()
      u:animeact(6)
      local cs = 0
      ac.loop(100, function(t)
        cs = cs + 1
        local x1, y1 = mb:getxy()
        local jd = AngleXY(x, y, x1, y1)
        u:setface(jd)
        EffectcreateArgs({
          effect = "war3mapImported\\BOSS_4D_xuli1.mdx",
          x = x,
          y = y,
          size = cs,
          height = 200,
          zxz = GetRandomAngle(),
          animespeed = 3
        })
        if 20 <= cs then
          t:remove()
        end
      end)
    end)
    ac.wait(2500, function()
      if u:hasdata("暗神-失败结束标记") then
        return
      end
      u:animeact(7)
      PlayGlobalSound(Sound_Anshen_baozha5)
      mb:shockcamera(300, 0.15)
      local tx = EffectcreateArgs({
        effect = "war3mapImported\\BOSSS_4D_jiguang3.mdx",
        x = x,
        y = y,
        time = -1,
        size = 1,
        height = 200,
        zxz = u:getface(),
        animespeed = 3
      })
      local tx1 = EffectcreateArgs({
        effect = "war3mapImported\\BOSSS_4D_jiguang3.mdx",
        x = x,
        y = y,
        time = -1,
        size = 30,
        height = 200,
        zxz = u:getface(),
        animespeed = 3
      })
      local cs1 = 0
      ac.loop(100, function(t1)
        if u:hasdata("暗神-失败结束标记") then
          DestroyEffectLua(tx)
          DestroyEffectLua(tx1)
          t1:remove()
          return
        end
        if not mb:isalive() then
          local g = CreateGroupLua()
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if xq:isalive() then
              xq:groupadd(g)
            end
          end)
          mb = Group_Randomunit(g)
          if mb == 0 then
            mb = u
          end
        end
        local x1, y1 = mb:getxy()
        local targetJd = AngleXY(x, y, x1, y1)
        local currentJd = u:getface()
        mb:shockcamera(100, 0.1)
        local delta = (targetJd - currentJd + 360) % 360
        if 180 < delta then
          delta = delta - 360
        end
        local absDelta = math.abs(delta)
        local step = math.floor(3 + absDelta / 180 * 12)
        step = math.min(15, math.max(3, step))
        step = step * (0 < delta and 1 or -1)
        local newJd = (currentJd + step) % 360
        EffectcreateArgs({
          effect = "war3mapImported\\BOSS_4D_jiguang2.mdx",
          x = x,
          y = y,
          size = 5,
          height = -500,
          zxz = newJd,
          animespeed = 2
        })
        u:setface(newJd)
        japi.EXEffectMatReset(tx)
        japi.EXEffectMatRotateZ(tx, newJd)
        japi.EXEffectMatReset(tx1)
        japi.EXEffectMatRotateZ(tx1, newJd)
        cs1 = cs1 + 1
        local width = 90
        local angle = newJd
        local ux, uy = u:getxy()
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() then
            local mz = false
            local ax, ay = xq:getxy()
            local angToTarget = AngleXY(ux, uy, ax, ay)
            local dis = DistanceXY(ux, uy, ax, ay)
            local delta2 = math.abs((angToTarget - angle + 360) % 360)
            if 180 < delta2 then
              delta2 = 360 - delta2
            end
            if delta2 <= width / 2 then
              mz = true
            end
            if dis <= 180 then
              mz = true
            end
            if mz then
              AnshenDamage(u, xq, txsh)
            end
          end
        end)
        if 130 <= cs1 then
          DestroyEffectLua(tx)
          DestroyEffectLua(tx1)
          t1:remove()
        end
      end)
    end)
  end,
  ["终末棱镜"] = function(u)
    local js = false
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFF9966FF终末棱镜|r")
      SendMsgAll("|cFFCC0000【一字型悖理星线无法闪避】|r")
    else
      js = true
      SendMsgAll("|cFFCC0000【一字型悖理星线附带即死效果】|r")
    end
    local x, y = u:getxy()
    local txsh = 500 * u:getdata("怪物强度")
    local jd = u:getface()
    u:animeact(12)
    ac.wait(1, function()
      local cs = 0
      ac.loop(100, function(t)
        if u:hasdata("暗神-失败结束标记") then
          t:remove()
          return
        end
        cs = cs + 1
        Jiguanghanshu(u, x, y, txsh)
        if 10 <= cs then
          t:remove()
        end
      end)
    end)
    ac.wait(2000, function()
      local cs = 0
      ac.loop(100, function(t)
        if u:hasdata("暗神-失败结束标记") then
          t:remove()
          return
        end
        cs = cs + 1
        Jiguanghanshu(u, x, y, txsh)
        if 100 <= cs then
          t:remove()
        end
      end)
    end)
    ac.wait(13000, function()
      ac.wait(1, function()
        ac.wait(500, function()
          PlayGlobalSound(Sound_Anshen_jiguang2)
          SetSoundVolumeBJ(Sound_Anshen_jiguang2, 65)
          PlayGlobalSound(Sound_Anshen_jiguang3)
          SetSoundVolumeBJ(Sound_Anshen_jiguang3, 65)
        end)
        local cs1 = 0
        ac.loop(50, function(t1)
          if u:hasdata("暗神-失败结束标记") then
            t1:remove()
            return
          end
          cs1 = cs1 + 1
          local jd1 = 5 * cs1
          Jiguanghanshu2(u, x, y, txsh, jd1, false, js)
          if 72 <= cs1 then
            t1:remove()
          end
        end)
      end)
      ac.wait(4000, function()
        ac.wait(500, function()
          PlayGlobalSound(Sound_Anshen_jiguang2)
          SetSoundVolumeBJ(Sound_Anshen_jiguang2, 65)
          PlayGlobalSound(Sound_Anshen_jiguang3)
          SetSoundVolumeBJ(Sound_Anshen_jiguang3, 65)
        end)
        local cs1 = 0
        ac.loop(50, function(t1)
          if u:hasdata("暗神-失败结束标记") then
            t1:remove()
            return
          end
          cs1 = cs1 + 1
          local jd1 = 90 + 5 * cs1
          Jiguanghanshu2(u, x, y, txsh, jd1, false, js)
          if 72 <= cs1 then
            t1:remove()
          end
        end)
      end)
      local sj = GetRandomReal(0, 90)
      ac.wait(8000, function()
        ac.wait(500, function()
          PlayGlobalSound(Sound_Anshen_jiguang2)
          SetSoundVolumeBJ(Sound_Anshen_jiguang2, 65)
          PlayGlobalSound(Sound_Anshen_jiguang3)
          SetSoundVolumeBJ(Sound_Anshen_jiguang3, 65)
        end)
        local cs1 = 0
        ac.loop(45, function(t1)
          if u:hasdata("暗神-失败结束标记") then
            t1:remove()
            return
          end
          cs1 = cs1 + 1
          local jd1 = sj + 90 + 5 * cs1
          Jiguanghanshu2(u, x, y, txsh, jd1, true)
          if 72 <= cs1 then
            t1:remove()
          end
        end)
      end)
      ac.wait(8000, function()
        local cs1 = 0
        ac.loop(45, function(t1)
          if u:hasdata("暗神-失败结束标记") then
            t1:remove()
            return
          end
          cs1 = cs1 + 1
          local jd1 = sj + 5 * cs1
          Jiguanghanshu2(u, x, y, txsh, jd1, true)
          if 72 <= cs1 then
            t1:remove()
          end
        end)
      end)
    end)
  end,
  ["湮灭棱镜"] = function(u)
    if Nandu_Choose <= 4 then
      SendMsgAll("|cFF9966FF湮灭棱镜|r")
    end
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:deldata("暗神-湮灭棱镜标记")
    end)
    local x, y = u:getdata("星蚀界域X"), u:getdata("星蚀界域Y")
    local jd = u:getface()
    local cs = 0
    local tx1 = EffectcreateArgs({
      effect = "war3mapImported\\BOSS_4D_zhishixian.mdx",
      x = x,
      y = y,
      time = 12,
      size = 0.7,
      height = 100,
      zxz = 0,
      animespeed = 1
    })
    local tx2 = EffectcreateArgs({
      effect = "war3mapImported\\BOSS_4D_zhishixian.mdx",
      x = x,
      y = y,
      time = 12,
      size = 0.7,
      height = 100,
      zxz = 90,
      animespeed = 1
    })
    ac.wait(500, function()
      japi.EXSetEffectSpeed(tx1, 0)
      japi.EXSetEffectSpeed(tx2, 0)
    end)
    ac.wait(12000, function()
      japi.EXSetEffectSpeed(tx1, 1)
      japi.EXSetEffectSpeed(tx2, 1)
    end)
    ac.loop(500, function(t)
      if u:hasdata("暗神-失败结束标记") then
        t:remove()
        return
      end
      cs = cs + 1
      local sj = GetRandomInt(1, 4)
      local dx, dy = u:getxy()
      local jd1 = 0
      if sj == 1 then
        dx, dy = PolarXY(x, y, 1500, 30)
        jd1 = 180
      end
      if sj == 2 then
        dx, dy = PolarXY(x, y, 1500, 120)
        jd1 = -90
      end
      if sj == 3 then
        dx, dy = PolarXY(x, y, 1500, 210)
        jd1 = 0
      end
      if sj == 4 then
        dx, dy = PolarXY(x, y, 1500, 300)
        jd1 = 90
      end
      EffectcreateArgs({
        effect = "war3mapImported\\BOSS_4D_zhishixian2.mdx",
        x = dx,
        y = dy,
        size = 2,
        height = 100,
        zxz = jd1,
        animespeed = 1
      })
      PlayGlobalSound(Sound_Anshen_yujing1)
      ac.wait(3000 + cs * 800, function()
        if u:hasdata("暗神-失败结束标记") then
          return
        end
        PlayGlobalSound(Sound_Anshen_jiguang1)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() then
            xq:shockcamera(150, 0.6)
            local quadrant = GetPlayerQuadrant(u, xq)
            if sj == 1 and (quadrant == 3 or quadrant == 4) or sj == 2 and (quadrant == 2 or quadrant == 3) or sj == 3 and (quadrant == 1 or quadrant == 2) or sj == 4 and (quadrant == 1 or quadrant == 4) then
              AnshenJisi(u, xq)
            end
          end
        end)
        local cs1 = 0
        ac.loop(100, function(t1)
          cs1 = cs1 + 1
          EffectcreateArgs({
            effect = "war3mapImported\\BOSS_4D_jiguang2.mdx",
            x = dx,
            y = dy,
            size = 5,
            height = -500,
            zxz = jd1,
            animespeed = 2
          })
          if 5 <= cs1 then
            t1:remove()
          end
        end)
      end)
      if 6 <= cs then
        t:remove()
      end
    end)
  end,
  ["星渊"] = function(u)
    SendMsgAll("|cFF9966FF星渊破灭|r", 30)
    SendMsgAll("|cFFCC0000【只能通过黑曜物质抵挡攻击,不足时即死;最后阶段禁用复活】|r")
    local x, y = u:getxy()
    local txsh = 500 * u:getdata("怪物强度")
    local jd = -90
    u:setface(jd)
    local x1, y1 = PolarXY(x, y, 400, jd + 90)
    local x2, y2 = PolarXY(x, y, 400, jd - 90)
    EffectcreateArgs({
      effect = "war3mapImported\\BOSS_4D_heidong4.mdx",
      x = x1,
      y = y1,
      time = 14,
      size = 2,
      height = 100,
      zxz = 90,
      animespeed = 1
    })
    EffectcreateArgs({
      effect = "war3mapImported\\BOSS_4D_heidong4.mdx",
      x = x2,
      y = y2,
      time = 14,
      size = 2,
      height = 100,
      zxz = 90,
      animespeed = 1
    })
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:setdata("暗神-禁用复活")
    end)
    ac.wait(1000, function()
      u:animeact(12)
      local cs = 0
      ac.loop(100, function(t)
        if u:hasdata("暗神-失败结束标记") then
          t:remove()
          return
        end
        cs = cs + 1
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() then
            local dx, dy = xq:getxy()
            local jd1 = AngleXY(x1, y1, dx, dy)
            local jd2 = AngleXY(x2, y2, dx, dy)
            if cs <= 25 then
              EffectcreateArgs({
                effect = "war3mapImported\\BOSS_4D_zhishixian2.mdx",
                x = x1,
                y = y1,
                size = 1,
                height = 100,
                zxz = jd1,
                animespeed = 1
              })
              EffectcreateArgs({
                effect = "war3mapImported\\BOSS_4D_zhishixian2.mdx",
                x = x2,
                y = y2,
                size = 1,
                height = 100,
                zxz = jd2,
                animespeed = 1
              })
            end
            ac.wait(200, function()
              unifycreate({
                owner = u.handle,
                model = "war3mapImported\\BOSS_4D_danmu1.mdl",
                modelname = "暗矢",
                modelsize = 1.5,
                height = 100,
                damage = 0,
                damagetype = 5,
                x = x1,
                y = y1,
                time = 1,
                speed = 4800,
                volume = 90,
                angle = jd1,
                angleoffset = 0,
                attenua = 1,
                attenuacount = 1,
                life = 10,
                isbullet = false,
                isvest = false,
                isignorearmor = false,
                hitafterfunc = function(mj, xq, damage2)
                  AnshenHeiyaojisi(u, xq)
                end
              })
              unifycreate({
                owner = u.handle,
                model = "war3mapImported\\BOSS_4D_danmu1.mdl",
                modelname = "暗矢",
                modelsize = 1.5,
                height = 100,
                damage = 0,
                damagetype = 5,
                x = x2,
                y = y2,
                time = 1,
                speed = 4800,
                volume = 90,
                angle = jd2,
                angleoffset = 0,
                attenua = 1,
                attenuacount = 1,
                life = 10,
                isbullet = false,
                isvest = false,
                isignorearmor = false,
                hitafterfunc = function(mj, xq, damage2)
                  AnshenHeiyaojisi(u, xq)
                end
              })
            end)
          end
        end)
        if 50 <= cs then
          t:remove()
        end
      end)
    end)
    ac.wait(6000, function()
      local cs = 0
      ac.loop(50, function(t)
        if u:hasdata("暗神-失败结束标记") then
          t:remove()
          return
        end
        cs = cs + 1
        local jd1 = jd + GetRandomReal(-70, 70)
        local jd2 = jd + GetRandomReal(-70, 70)
        ac.wait(200, function()
          unifycreate({
            owner = u.handle,
            model = "war3mapImported\\BOSS_4D_danmu1.mdl",
            modelname = "暗矢",
            modelsize = 1.5,
            height = 100,
            damage = 0,
            damagetype = 5,
            x = x1,
            y = y1,
            time = 1,
            speed = 4800,
            volume = 90,
            angle = jd1,
            angleoffset = 0,
            attenua = 1,
            attenuacount = 1,
            life = 10,
            isbullet = false,
            isvest = false,
            isignorearmor = false,
            hitafterfunc = function(mj, xq, damage2)
              AnshenHeiyaojisi(u, xq, true)
            end
          })
          unifycreate({
            owner = u.handle,
            model = "war3mapImported\\BOSS_4D_danmu1.mdl",
            modelname = "暗矢",
            modelsize = 1.5,
            height = 100,
            damage = 0,
            damagetype = 5,
            x = x2,
            y = y2,
            time = 1,
            speed = 4800,
            volume = 90,
            angle = jd2,
            angleoffset = 0,
            attenua = 1,
            attenuacount = 1,
            life = 10,
            isbullet = false,
            isvest = false,
            isignorearmor = false,
            hitafterfunc = function(mj, xq, damage2)
              AnshenHeiyaojisi(u, xq, true)
            end
          })
        end)
        if 100 <= cs then
          t:remove()
        end
      end)
    end)
    ac.wait(10000, function()
      u:animeact(6)
      PlayGlobalSound(Sound_Anshen_xuli1)
      local cs = 0
      ac.loop(200, function(t)
        if u:hasdata("暗神-失败结束标记") then
          t:remove()
          return
        end
        cs = cs + 1
        local x3, y3 = u:getxy()
        EffectcreateArgs({
          effect = "war3mapImported\\BOSS_4D_xuli1.mdx",
          x = x3,
          y = y3,
          size = cs,
          height = 200,
          zxz = GetRandomAngle(),
          animespeed = 3
        })
        if 10 <= cs then
          t:remove()
        end
      end)
    end)
    ac.wait(12000, function()
      if u:hasdata("暗神-失败结束标记") then
        return
      end
      u:animeact(7)
      PlayGlobalSound(Sound_Anshen_baozha5)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:isalive() then
          xq:shockcamera(300, 0.15)
          ac.wait(200, function()
            xq:shockcamera(50, 5.2)
          end)
          ac.wait(5600, function()
            xq:shockcamera(300, 0.15)
          end)
          ac.wait(5900, function()
            xq:shockcamera(100, 8)
          end)
        end
      end)
      local tx = EffectcreateArgs({
        effect = "war3mapImported\\BOSSS_4D_jiguang3.mdx",
        x = x,
        y = y,
        time = -1,
        size = 1,
        height = 200,
        zxz = -90,
        animespeed = 3
      })
      local tx1 = EffectcreateArgs({
        effect = "war3mapImported\\BOSSS_4D_jiguang3.mdx",
        x = x,
        y = y,
        time = -1,
        size = 30,
        height = 200,
        zxz = -90,
        animespeed = 3
      })
      local count = math.floor(22.0)
      ac.loop(250, function(t)
        if u:hasdata("暗神-失败结束标记") then
          DestroyEffectLua(tx)
          DestroyEffectLua(tx1)
          t:remove()
          return
        end
        count = count - 1
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() then
            AnshenHeiyaojisi(u, xq, true)
          end
        end)
        if count == 0 then
          t:remove()
        end
      end)
      ac.wait(5500, function()
        if u:hasdata("暗神-失败结束标记") then
          DestroyEffectLua(tx)
          DestroyEffectLua(tx1)
          return
        end
        SendMsgAll("|cFF9966FF终焉星线|r", 10)
        PlayGlobalSound(Sound_Anshen_baozha6)
        if u:getperhp() >= 20 then
          u:sethp(10, true)
        end
        u:setdata("暗神-场地禁用判定")
        local cs = 0
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() then
            unitmove({
              unit = xq.handle,
              time = 8,
              distance = 400,
              angle = 270,
              isfly = true
            })
          end
        end)
        local acount = 60
        if Nandu_Choose >= 5 then
          acount = 80
        end
        ac.loop(8000 / acount, function(t2)
          if u:hasdata("暗神-失败结束标记") then
            t2:remove()
            return
          end
          acount = acount - 1
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if xq:isalive() then
              xq:buffset(u.handle, 5, "暂停")
              AnshenHeiyaojisi(u, xq)
            end
          end)
          if acount == 0 then
            t2:remove()
          end
        end)
        ac.loop(150, function(t)
          if u:hasdata("暗神-失败结束标记") then
            t:remove()
            return
          end
          cs = cs + 1
          EffectcreateArgs({
            effect = "war3mapImported\\BOSS_4D_jiguang7.mdx",
            x = x,
            y = y,
            size = GetRandomReal(1, 20),
            height = 200,
            zxz = -90,
            xxz = GetRandomAngle(),
            animespeed = 1
          })
          EffectcreateArgs({
            effect = "war3mapImported\\BOSS_4D_shandian1.mdx",
            x = x,
            y = y,
            time = 0.2,
            size = GetRandomReal(1, 30),
            zxz = -90,
            yxz = 90,
            animespeed = 0.2
          })
          if 53 <= cs then
            t:remove()
          end
        end)
      end)
      ac.wait(12000, function()
        if u:hasdata("暗神-失败结束标记") then
          DestroyEffectLua(tx)
          DestroyEffectLua(tx1)
          return
        end
        local mj = u:getdata("尾杀演出-真红模型")
        EffectcreateArgs({
          effect = "war3mapImported\\Anshen_zhenhongjiuchang1.mdx",
          x = x + 4000,
          y = y + 4000,
          size = 0.01
        })
        ac.wait(250, function()
          EffectcreateArgs({
            effect = "war3mapImported\\Anshen_zhenhongjiuchang2.mdx",
            x = x + 4000,
            y = y + 4000,
            size = 0.01
          })
        end)
        ac.wait(500, function()
          mj:setxy(x, y)
          mj:setface(-90)
          mj:setcolor(255, 255, 255, 0)
        end)
        ac.wait(1000, function()
          if u:hasdata("暗神-失败结束标记") then
            DestroyEffectLua(tx)
            DestroyEffectLua(tx1)
            mj:remove()
            return
          end
          u:animeact(9)
          EffectcreateArgs({
            effect = "war3mapImported\\BOSS_4D_zhishixian.mdx",
            x = x,
            y = y,
            size = 5,
            height = 10,
            zxz = 180,
            yxz = 45,
            animespeed = 0.5
          })
          ac.wait(1000, function()
            ForGroupLuaNew(Group_PlayHero, function(xq)
              xq:deldata("暗神-禁用复活")
              local p = getplayer(xq.owner)
              p:shockcamera(150, 0.3)
            end)
            PlayGlobalSound(Sound_Anshen_baozha7)
            local dx, dy = PolarXY(x, y, 0, 0)
            for i = 1, 5 do
              local tx3 = EffectcreateArgs({
                effect = "war3mapImported\\Anshen_zhenhongjiuchang2.mdx",
                x = dx + 800,
                y = dy,
                size = 10,
                height = 0,
                zxz = 180,
                yxz = 45,
                animespeed = GetRandomReal(0.7, 1.2)
              })
              ac.wait(500, function()
                japi.EXSetEffectSpeed(tx3, 0.3)
              end)
            end
            ac.wait(200, function()
              flashphoto({
                photo = "ReplaceableTextures\\CameraMasks\\White_mask.blp",
                timeout = 0.5,
                timehold = 0,
                timein = 0.5
              })
              u:deldata("免疫击退效果")
              unitmove({
                unit = u.handle,
                time = 0.2,
                distance = 300,
                angle = 90,
                isfly = true
              })
              mj:setcolor(255, 255, 255, 255)
              ac.wait(2000, function()
                mj:animeact(6)
              end)
              for i = 1, 5 do
                local tx2 = EffectcreateArgs({
                  effect = "war3mapImported\\Anshen_zhenhongjiuchang1.mdx",
                  x = x,
                  y = y,
                  size = GetRandomReal(1, 10),
                  height = 10,
                  zxz = GetRandomAngle(),
                  animespeed = 1
                })
                ac.wait(500, function()
                  japi.EXSetEffectSpeed(tx2, 0.3)
                end)
              end
              ac.wait(3000, function()
                mj:remove()
                local cs = 0
                PlayGlobalSound(Sound_Anshen_zhenhongjiuchang3)
                ac.wait(500, function()
                  PlayGlobalSound(Sound_Anshen_zhenhongjiuchang2)
                end)
                ac.loop(60, function(t)
                  cs = cs + 1
                  EffectcreateArgs({
                    effect = "war3mapImported\\Anshen_zhenhongjiuchang1.mdx",
                    x = x,
                    y = y,
                    time = 2,
                    size = cs,
                    height = 100,
                    zxz = GetRandomAngle(),
                    animespeed = 0.1
                  })
                  if 5 <= cs then
                    ac.wait(4500, function()
                      PlayGlobalSound(Sound_Anshen_zhenhongjiuchang1)
                      flashphoto({
                        photo = "ReplaceableTextures\\CameraMasks\\White_mask.blp",
                        timeout = 1,
                        timehold = 0,
                        timein = 0
                      })
                    end)
                    ac.wait(7500, function()
                      flashphoto({
                        photo = "ReplaceableTextures\\CameraMasks\\White_mask.blp",
                        timeout = 0,
                        timehold = 0,
                        timein = 3
                      })
                    end)
                    t:remove()
                  end
                end)
              end)
            end)
          end)
        end)
      end)
      ac.wait(14000, function()
        if u:hasdata("暗神-失败结束标记") then
          DestroyEffectLua(tx)
          DestroyEffectLua(tx1)
          return
        end
        u:setdata("暗神永恒")
        u:setdata("暗神-结束判定")
        DayNightRun = true
        BuffUI.remove("理智值")
        BuffUI.remove("黑曜物质")
        BuffUI.remove("无光之视")
        BuffUI.remove("湮灭物质")
        DestroyEffectLua(u:getdata("星蚀界域"))
        ExtraBattle = false
        BossBattle = false
        ExBossBattle = false
        Boolean_Anshen_Sanjieduan = false
        Boolean_AnshenBattleEnd = true
        Boolean_Fog_Change = false
        FogEnable(true)
        FogMaskEnable(true)
        DestroyEffectLua(tx)
        DestroyEffectLua(tx1)
        if not u:hasdata("暗神-三阶段击败者") then
          u:setdata("暗神-三阶段击败者", Group_Randomunit(Group_PlayHero))
        end
        bossdeath(u.handle, u:getdata("暗神-三阶段击败者"))
        ac.wait(3000, function()
          Nofail_Biaoji = false
          ForGroupLuaNew(Group_PlayHero, function(xq)
            local ax, ay = xq:getxy()
            HeroRelive(xq.handle, ax, ay, 3)
          end)
        end)
        ac.wait(6000, function()
          ShowUnit(u.handle, false)
        end)
        ac.wait(10000, function()
          StopSoundBJ(Sound_Anshen_2, true)
          Boolean_AnshenBattle = false
          u:remove()
        end)
      end)
    end)
  end
}

function anshen_jieduan3skillloop(u)
  if u:hasdata("暗神-失败结束标记") then
    return
  end
  PlayGlobalSound(Sound_Anshen_2)
  u:deldata("尾杀释放中")
  u:deldata("技能中断")
  local cs = 0
  local dcs = 0
  local hfmax = 0
  ac.loop(100, function(timer)
    if u:hasdata("暗神-失败结束标记") then
      timer:remove()
      return
    end
    if hfmax < 2700 then
      hfmax = hfmax + 1
      dcs = dcs + 1
      if 30 <= dcs then
        dcs = 0
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() then
            xq:changedata("黑曜物质层数", 1)
          end
        end)
      end
    end
    cs = cs + 1
    if cs == 15 then
      SetTerrainFogExBJ(0, 1000, 8000, 1, 0.0, 0.0, 0.0)
    end
    if cs == 30 then
      AnshenSkill["湮灭棱镜"](u)
    end
    if cs == 150 then
      AnshenSkill["三阶段转场"](u)
      ac.wait(1500, function()
        SetTerrainFogExBJ(0, 1000, 8000, 1, 50.0, 30.0, 100.0)
      end)
      ac.wait(5000, function()
        AnshenSkill["终末棱镜"](u)
      end)
    end
    if cs == 450 then
      AnshenSkill["三阶段转场"](u)
      ac.wait(1500, function()
        SetTerrainFogExBJ(0, 1000, 8000, 1, 60.0, 10.0, 10.0)
      end)
      ac.wait(3000, function()
        AnshenSkill["暗蚀飞星"](u)
      end)
    end
    if cs == 660 then
      u:setdata("技能中断")
      ac.wait(2000, function()
        AnshenSkill["三阶段转场"](u)
        ac.wait(1500, function()
          SetTerrainFogExBJ(0, 1000, 8000, 1, 0.0, 0.0, 0.0)
        end)
      end)
      ac.wait(5000, function()
        AnshenSkill["万象呓语"](u)
      end)
    end
    if cs == 840 then
      AnshenSkill["三阶段转场"](u)
      ac.wait(1500, function()
        SetTerrainFogExBJ(0, 1000, 8000, 1, 60.0, 10.0, 10.0)
      end)
      ac.wait(3000, function()
        anshen_skillloop(u, 1)
      end)
    end
    if cs == 1090 then
      u:setdata("技能中断")
    end
    if cs == 1130 then
      AnshenSkill["三阶段转场"](u)
      ac.wait(1500, function()
        SetTerrainFogExBJ(0, 1000, 8000, 1, 0.0, 0.0, 0.0)
      end)
      ac.wait(3000, function()
        AnshenSkill["黯蚀棱镜"](u)
      end)
    end
    if cs == 1320 then
      AnshenSkill["三阶段转场"](u)
      ac.wait(1500, function()
        SetTerrainFogExBJ(0, 1000, 8000, 1, 50.0, 30.0, 100.0)
      end)
      ac.wait(3000, function()
        AnshenSkill["湮灭棱镜"](u)
      end)
    end
    if cs == 1470 then
      AnshenSkill["三阶段转场"](u)
      ac.wait(1500, function()
        SetTerrainFogExBJ(0, 1000, 8000, 1, 60.0, 10.0, 10.0)
      end)
      ac.wait(3000, function()
        anshen_skillloop(u, 1)
      end)
    end
    if cs == 1530 then
      u:setdata("技能中断")
    end
    if cs == 1560 then
      ac.wait(2000, function()
        AnshenSkill["三阶段转场"](u)
        ac.wait(1500, function()
          SetTerrainFogExBJ(0, 1000, 8000, 1, 0.0, 0.0, 0.0)
        end)
      end)
      ac.wait(5000, function()
        AnshenSkill["万象呓语"](u)
      end)
    end
    if cs == 1740 then
      u:setdata("技能中断")
      AnshenSkill["三阶段转场"](u)
      ac.wait(1500, function()
        SetTerrainFogExBJ(0, 1000, 8000, 1, 60.0, 10.0, 10.0)
      end)
      ac.wait(3000, function()
        AnshenSkill["神诉"](u)
      end)
    end
    if cs == 1860 then
      AnshenSkill["三阶段转场"](u)
      ac.wait(1500, function()
        SetTerrainFogExBJ(0, 1000, 8000, 1, 50.0, 30.0, 100.0)
      end)
      ac.wait(5000, function()
        AnshenSkill["终末棱镜"](u)
      end)
    end
    if cs == 2160 then
      u:setdata("技能中断")
      AnshenSkill["三阶段转场"](u)
      ac.wait(1500, function()
        SetTerrainFogExBJ(0, 1000, 8000, 1, 60.0, 10.0, 10.0)
      end)
      ac.wait(3000, function()
        AnshenSkill["陨星降临"](u)
      end)
    end
    if cs == 2240 then
      u:setdata("技能中断")
      ac.wait(3000, function()
        AnshenSkill["暗蚀飞星"](u)
      end)
    end
    if cs == 2340 then
      u:setdata("技能中断")
      AnshenSkill["三阶段转场"](u)
      ac.wait(1500, function()
        SetTerrainFogExBJ(0, 1000, 8000, 1, 0.0, 0.0, 0.0)
      end)
      ac.wait(3000, function()
        AnshenSkill["黯蚀棱镜"](u)
      end)
    end
    if cs == 2530 then
      AnshenSkill["三阶段转场"](u)
      ac.wait(1500, function()
        SetTerrainFogExBJ(0, 1000, 8000, 1, 60.0, 10.0, 10.0)
      end)
      ac.wait(3000, function()
        AnshenSkill["湮灭棱镜"](u)
      end)
    end
    if cs == 2680 then
      u:setdata("星渊")
      AnshenSkill["三阶段转场"](u)
      ac.wait(1500, function()
        SetTerrainFogExBJ(0, 1000, 8000, 1, 50.0, 30.0, 100.0)
      end)
      ac.wait(10600, function()
        AnshenSkill["星渊"](u)
      end)
      timer:remove()
    end
  end)
end

function anshen_skillloop(u, time)
  ac.wait(time * 1000, function()
    if u:hasdata("暗神-失败结束标记") then
      return
    end
    local sj = 0
    if u:getdata("噬星灾神阶段") == 1 then
      sj = GetRandomInt(1, 4)
    end
    if u:getdata("噬星灾神阶段") == 2 then
      sj = GetRandomInt(1, 7)
    end
    if u:getdata("噬星灾神阶段") == 3 then
      sj = GetRandomInt(1, 3)
    end
    if u:getdata("循环次数") <= u:getdata("弹幕循环随机次数") then
      u:setdata("循环次数", u:getdata("循环次数") + 1)
      sj = 1
    else
      u:setdata("循环次数", 0)
      u:getdata("弹幕循环随机次数", GetRandomInt(1, 3))
    end
    if not u:hasdata("尾杀释放中") and not u:hasdata("技能中断") then
      AnshenSkill["瞬移"](u)
      ac.wait(1000, function()
        if sj == 1 then
          AnshenSkill["暗矢"](u)
        end
        if sj == 2 then
          AnshenSkill["寂灭"](u)
        end
        if sj == 3 then
          AnshenSkill["暗耀"](u)
        end
        if sj == 4 then
          AnshenSkill["暗蚀飞星"](u)
        end
        if sj == 5 then
          AnshenSkill["陨星降临"](u)
        end
        if sj == 6 then
          AnshenSkill["原点寄生"](u)
        end
        if sj == 7 then
          if not u:hasdata("暗神-神诉冷却") then
            u:settimedata("暗神-神诉冷却", 30)
            AnshenSkill["神诉"](u)
          else
            AnshenSkill["暗矢"](u)
          end
        end
      end)
    end
    if u:hasdata("尾杀释放中") then
      print("尾杀阶段")
      if u:getdata("噬星灾神阶段") == 1 then
        AnshenSkill["瞬移"](u)
        ac.wait(2000, function()
          AnshenSkill["噬星"](u)
        end)
      end
      if u:getdata("噬星灾神阶段") == 2 then
        AnshenSkill["瞬移"](u)
        ac.wait(2000, function()
          AnshenSkill["坠魇"](u)
        end)
      end
      if u:getdata("噬星灾神阶段") == 3 then
        AnshenSkill["瞬移"](u)
        ac.wait(2000, function()
          AnshenSkill["星渊"](u)
        end)
      end
    end
    u:deldata("技能中断")
    u:deldata("尾杀释放中")
  end)
end

function boss_anshen(unit)
  RewardStop = true
  ForGroupLuaNew(Group_PlayHero, function(xq)
    if xq:hasdata("背包-艾露猫") then
      AilumaoSnd(xq, "挑战BOSS")
    end
  end)
  ForGroupLuaNew(Group_Monster, function(xq)
    if not xq:isboss() then
      xq:kill(BOSS_DEATH, true)
      if xq:isnotingroup(HellGroup) then
        LeftNumofMonster = LeftNumofMonster + 1
      end
    end
  end)
  RewardStop = false
  local u = getunit(unit)
  local anshen = u
  u.owner = Player(9)
  u:changeowner(Player(9))
  u:setplayername("|cFF9966CC『噬星灾神』|r")
  BOSS_Anshen = u.handle
  BOSS = u.handle
  local dx = -5000
  local dy = 12089
  local npc = getunit(NPC_Molijiedian)
  japi.SetUnitModel(NPC_Molijiedian, "Star_Blue.mdx")
  npc:setxy(dx, dy)
  npc:setsize(0.5)
  npc:setflyheight(175)
  npc:setcolor(0, 0, 0, 155)
  ShowUnit(npc.handle, true)
  u:deldata("暗神-失败结束标记")
  ac.loop(100, function(t)
    if u:hasdata("暗神-失败结束标记") then
      t:remove()
      return
    end
    AnshenFailPanding(u)
  end)
  u:buffset(u.handle, 3600, "暂停")
  u:buffset(u.handle, 3600, "无敌")
  u:setxy(dx, dy)
  MonsterSetXingcunzuAttackTarget(u)
  u:groupadd(Group_Monster)
  u:groupadd(HellGroup)
  u:setface(270)
  u:addskill("A020")
  u:setdata("系统-BOSS")
  u:addskill("A11G")
  SetUnitPathing(u.handle, false)
  for i = 1, 8 do
    UnitShareVision(u.handle, Player(i - 1), true)
  end
  if Nandu_Choose >= 5 then
    u:setdata("爆伤抗性", 0.4)
  else
    u:setdata("爆伤抗性", 0.6)
  end
  local addatk = 0.85 + 0.15 * Nandu_Level
  addatk = addatk * MWTQ_AtkBOSS
  addatk = addatk * NanduJc_Atk
  u:setdata("怪物强度", addatk)
  u:setdata("怪物-伤害修正", 1)
  SetUnitState(u.handle, UNIT_STATE_MAX_LIFE, 10000)
  u:setmaxhp(1000000000)
  u:setdata("怪物基础生命上限", u:getmaxhp())
  u:setmaxmp(1000)
  if Keyan_Zhongzhuanghujia and not u:hasdata("科研模式-重装护甲提升") then
    local add = 1 * Nandu_Level
    u:changearmor(add)
    u:setdata("科研模式-重装护甲提升")
  end
  u:setdata("光属性抗性", 50)
  u:setdata("暗属性抗性", 50)
  u:setdata("风属性抗性", 50)
  u:setdata("雷属性抗性", 50)
  u:setdata("冰属性抗性", 50)
  u:setdata("水属性抗性", 50)
  u:setdata("火属性抗性", 50)
  u:setdata("心灵属性抗性", 50)
  u:setdata("神性", 5)
  u:setdata("BOSS-暗神")
  u:setdata("暗神永恒")
  u:setdata("免疫击退效果")
  u:setdata("免疫混乱改变所属")
  Movie_Boolean = true
  Boolean_AnshenBattle = true
  local npc2 = getunit(NPC_TIANZI)
  if Morihuanjing_String ~= "交错次元" then
    npc2:setdata("环境变更")
    npc2:setdata("暗神天气切换")
  end
  Nofail_Biaoji = true
  Boolean_Fog_Change = true
  FogEnable(false)
  FogMaskEnable(false)
  local x, y = npc:getxy()
  local jd = u:getface()
  PlayGlobalSound(Sound_Anshen_1)
  SetSoundVolumeBJ(Sound_Anshen_1, 85)
  StopSoundBJ(BGM_Start, false)
  SetSoundVolumeBJ(BGM, 0.0)
  for i = 1, 6 do
    BGMBoolean[i] = false
  end
  for index, value in ipairs(NowBGM) do
    value:set_volume(0)
  end
  local jcsh = 0.01
  u:setdata("噬星灾神阶段", 1)
  if not u:hasdata("暗神-已注册伤害触发") then
    u:setdata("暗神-已注册伤害触发")
    TriggerRegisterUnitEvent(DamageSystemTrg, u.handle, EVENT_UNIT_DAMAGED)
    TriggerRegisterUnitEvent(MonsterDead, u.handle, EVENT_UNIT_DEATH)
    u:addstexiao("BOSS-暗神", "BOSS减伤计算", function(args)
      local u = args.tg
      local soc = args.u
      local info = args.damageinfo
      local sh = info.damage
      local yssh = info.yssh
      local xs = 1
      local cxsx = 1.0E-4
      if Nandu_Choose >= 5 then
        xs = 0.5
        cxsx = 5.0E-5
      end
      if 1 >= PlayerCount then
        xs = xs * 2
      end
      local jm = false
      if info.isvestdamage or soc:hasdata("不拆分伤害") then
        jm = true
      end
      if u:getdata("噬星灾神阶段") == 1 then
        local max = 500000 * xs
        if jm then
          max = max * 0.05
        end
        if sh >= max then
          sh = max + (sh - max) * cxsx
        end
      end
      if u:getdata("噬星灾神阶段") == 2 then
        local max = 500000 * xs
        if jm then
          max = max * 0.05
        end
        if sh >= max then
          sh = max + (sh - max) * cxsx
        end
      end
      if u:getdata("噬星灾神阶段") == 3 then
        local max = 1000000 * xs
        if jm then
          max = max * 0.05
        end
        if sh >= max then
          sh = max + (sh - max) * cxsx
        end
      end
      if u:hasdata("反物质状态") then
        if not u:hasdata("反物质反伤中") then
          u:setdata("反物质反伤中")
          AnshenDamage(u, soc, 100)
          u:deldata("反物质反伤中")
        end
        sh = 0
      end
      if soc:hasdata("超维晶域") then
        sh = sh * 0.01
      end
      local cengshu = soc:getdata("黑曜物质层数")
      if 0 < cengshu then
        sh = sh * (jcsh + 0.01 * cengshu)
        local add = 100000 * cengshu
        if jm then
          add = add * 0.1
        end
        sh = sh + add
      end
      info.damage = sh
    end)
    u:addstexiao("BOSS-暗神", "伤害显示后效果", function(args)
      local u = args.tg
      local soc = args.u
      local info = args.damageinfo
      local llz = soc:getdata("理智值")
      local down = 0.1 + 0.009 * soc:getdata("理智值")
      info.damage = info.damage * down
      if u:getdata("噬星灾神阶段") == 1 and (info.damage >= u:gethp() - 1000 or u:getperhp() <= 5) then
        info.damage = 0
        u:setdata("暗神-一阶段击败者", soc)
        u:setdata("暗神永恒")
        u:sethp(5, true)
        u:setdata("尾杀释放中")
      end
      if u:getdata("噬星灾神阶段") == 2 and (info.damage >= u:gethp() - 1000 or u:getperhp() <= 5) then
        info.damage = 0
        u:setdata("暗神-二阶段击败者", soc)
        u:sethp(5, true)
        if not u:hasdata("尾杀释放中") then
          u:setdata("暗神永恒")
          u:setdata("尾杀释放中")
        end
      end
      if u:getdata("噬星灾神阶段") == 3 and (info.damage >= u:gethp() - 1000 or u:getperhp() <= 5) then
        info.damage = 0
        u:setdata("暗神-三阶段击败者", soc)
        u:setdata("暗神永恒")
        u:sethp(5, true)
      end
    end)
  end
  if u:hasdata("暗神-非首次挑战") then
    local add = u:getdata("暗神-挑战失败次数")
    SendMsgAll("|cFF9966FF噬星灾神挑战次数:" .. add .. "|r")
  end
  DayNightRun = false
  SetDayNightModels("Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdx", "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdx")
  u:setdata("单位-大头像", "Portrait_Shixingzaishen.tga")
  ShowUnit(BOSS_Anshen, false)
  ForGroupLuaNew(Group_AllHero, function(xq)
    local sy = xq.ownerid
    xq:setdata("理智值", 100)
    xq:setdata("暗神-无光之视")
    local p = getplayer(xq.owner)
    p:setcameraheight(2000, 0)
    p:setcameraheight(800, 7)
    SetCameraTargetControllerNoZForPlayer(xq.owner, npc.handle, 0, 0, false)
    xq:setxy(x + GetRandomReal(200, 500), y + GetRandomReal(200, 500))
    if Nandu_Choose <= 4 and u:hasdata("暗神-非首次挑战") then
      local add = u:getdata("暗神-挑战失败次数")
      if 3 <= add then
        add = 3
      end
      xq:setdata("噬星灾神复活次数", add)
    end
  end)
  ac.loop(1000, function(timer)
    ForGroupLuaNew(Group_AllHero, function(xq)
      local cure = 0.5 + 0.01 * u:getdata("外域变异数量")
      if u:getdata("理智值损失时间") <= 0 then
        cure = cure + 0.5
      else
        u:changedata("理智值损失时间", -0.1)
      end
      if u:hasdata("变异判定-特莉波卡") then
        cure = cure + 0.2
      end
      if u:hasdata("变异判定-阿比盖尔") then
        cure = cure + 0.2
      end
      if u:hasdata("妖梦皮肤-渎白之渊") then
        cure = cure + 0.2
      end
      if u:hasdata("变异判定-尤格索托斯") then
        cure = cure + 0.2
      end
      if not xq:isalive() then
        cure = 0
      end
      xq:changedata("理智值", cure)
      if xq:getdata("理智值") >= 100 then
        xq:setdata("理智值", 100)
      end
    end)
    if u:hasdata("暗神-结束判定") or u:hasdata("暗神-失败结束标记") then
      timer:remove()
    end
  end)
  BuffUI.apply({id = "理智值"})
  BuffUI.apply({
    id = "黑曜物质"
  })
  BuffUI.apply({
    id = "无光之视",
    duration = 99999
  })
  if Nandu_Choose <= 4 then
    SendMsgAll("|cFF9966FF思维临界|r", 30)
    SendMsgAll("|cFF9966FF[显示理智值,每秒自然恢复,受伤时降低,复活时恢复部分理智值]|r", 30)
    SendMsgAll("|cFF9966FF星蚀界域|r", 30)
    SendMsgAll("|cFF9966FF[离开场地区域时受到伤害]|r", 30)
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:changedata("黑曜物质层数", 20)
    end)
  end
  local cs = 0
  ac.loop(30, function(timer)
    cs = cs + 1
    local r = 50 - 0.05 * cs
    local g = 75 - 0.375 * cs
    local b = 70 + 0.15 * cs
    SetTerrainFogExBJ(0, 1000, 4000, 2.0, r, g, b)
    if cs == 200 then
      timer:remove()
    end
  end)
  ac.wait(1, function()
    local cs = 0
    ac.loop(100, function(t)
      cs = cs + 1
      EffectcreateArgs({
        effect = "war3mapImported\\BOSS_4D_xuli1.mdx",
        x = x,
        y = y,
        size = cs / 10,
        height = 200,
        zxz = GetRandomAngle(),
        animespeed = 3
      })
      if cs == 50 then
        PlayGlobalSound(Sound_Anshen_chuchang2)
      end
      if 70 <= cs then
        t:remove()
      end
    end)
  end)
  ac.wait(7000, function()
    SetCameraTargetController(npc.handle, 0, 800, false)
    ForGroupLuaNew(Group_PlayHero, function(xq)
      local p = getplayer(xq.owner)
      xq:shockcamera(100, 7)
      p:setcameraheight(2000, 0)
    end)
    PlayGlobalSound(Sound_Anshen_chuchang1)
    local cs = 0
    local size = 1
    ac.loop(100, function(t)
      cs = cs + 1
      if cs == 60 then
        PlayGlobalSound(Sound_Anshen_chuchang3)
        PlayGlobalSound(Sound_Anshen_chuchang4)
      end
      if 60 < cs then
        size = size + 1
      end
      EffectcreateArgs({
        effect = "war3mapImported\\BOSS_4D_jiguang7.mdx",
        x = x,
        y = y,
        size = size,
        height = 200,
        zxz = GetRandomAngle(),
        yxz = -90,
        animespeed = 1
      })
      EffectcreateArgs({
        effect = "war3mapImported\\BOSS_4D_shandian1.mdx",
        x = x,
        y = y,
        time = 0.1,
        size = GetRandomReal(1, 30),
        zxz = jd,
        yxz = 90,
        animespeed = 0.2
      })
      if 70 <= cs then
        Movie_Boolean = false
        SetTerrainFogExBJ(0, 1000, 16000, 2.0, 40, 0, 100)
        ShowUnit(npc.handle, false)
        ResetToGameCamera(0.0)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          local p = getplayer(xq.owner)
          p:setcameraheight(3000, 0)
          xq:setcamera(x, y, 0)
        end)
        ac.wait(1000, function()
          EffectcreateArgs({
            effect = "war3mapImported\\BOSS_4D_heidong4.mdx",
            x = x,
            y = y,
            time = 61,
            size = 5,
            height = -200,
            zxz = jd,
            animespeed = 1
          })
        end)
        t:remove()
      end
    end)
  end)
  ac.wait(15000, function()
    if PlayerCount ~= 1 then
      local max = 30
      if Nandu_Choose >= 5 then
        max = 60
      end
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:setdata("暗神-复活时间", 10)
        local t = 0
        local tt2 = flytext({
          unit = u.handle,
          text = "",
          size = 6,
          time = -1,
          r = 153,
          g = 153,
          b = 255,
          height = 0,
          xspeed = 0,
          yspeed = 0
        })
        ac.loop(100, function(timer)
          local bx, by = xq:getxy()
          if xq:isalive() then
            SetTextTagText(tt2, "", TextTagSize2Height(10))
            t = 0
            if xq:hasdata("暗神复活特效") then
              DestroyEffectLua(xq:getdata("暗神复活特效"))
              xq:deldata("暗神复活特效")
            end
          else
            if not xq:hasdata("暗神复活特效") then
              local tx = Effectcreate("war3mapImported\\Texiao_jinggao2.mdx", bx, by, -1, 1.25)
              xq:setdata("暗神复活特效", tx)
            end
            t = t + 0.1
            SetTextTagText(tt2, math.floor(xq:getdata("暗神-复活时间") - t), TextTagSize2Height(10))
            SetTextTagPosUnit(tt2, xq.handle, 0)
            ForGroupLuaNew(Group_PlayHero, function(xq2)
              if xq2 ~= xq and xq2:isalive() then
                local cx, cy = xq2:getxy()
                local dis = DistanceXY(bx, by, cx, cy)
                if dis <= 140 then
                  t = t + 0.1
                end
              end
            end)
            if t >= xq:getdata("暗神-复活时间") then
              if not Boolean_AnshenBattleBanFuhuo then
                t = 0
                xq:changedata("暗神-复活时间", 5)
                if xq:getdata("暗神-复活时间") >= max then
                  xq:setdata("暗神-复活时间", max)
                end
                HeroRelive(xq.handle, bx, by)
                xq:settimedata("暗神-复活无敌", 2)
              else
                t = xq:getdata("暗神-复活时间")
              end
            end
          end
          if u:hasdata("暗神-二阶段尾杀") or u:hasdata("暗神-失败结束标记") then
            if xq:hasdata("暗神复活特效") then
              DestroyEffectLua(xq:getdata("暗神复活特效"))
              xq:deldata("暗神复活特效")
            end
            xq:deldata("暗神-复活时间")
            TimerDestroyTextTag(0, tt2)
            timer:remove()
          end
        end)
      end)
    end
    local tx1 = EffectcreateArgs({
      effect = "war3mapImported\\BOSS_4D_changdi.mdx",
      x = x,
      y = y,
      time = -1,
      size = 2,
      height = 100,
      zxz = jd,
      animespeed = 1
    })
    u:setdata("星蚀界域", tx1)
    if type(japi.EXSetEffectVisible) == "function" then
      japi.EXSetEffectVisible(tx1, true)
    end
    if type(japi.EXSetEffectFogVisible) == "function" then
      japi.EXSetEffectFogVisible(tx1, true)
    end
    if type(japi.EXSetEffectMaskVisible) == "function" then
      japi.EXSetEffectMaskVisible(tx1, true)
    end
    u:setdata("暗神-界域大小", 3000)
    local txsh = 500 * u:getdata("怪物强度")
    local dis = 3000
    local v = 0.1
    for i = 1, 18 do
      local a = i * 20
      local dx, dy = PolarXY(x, y, dis, a)
      local tx = Effectcreate("Anshen_Huanrao2.mdx", dx, dy, -1, 1, 90)
      local cs = 0
      ac.loop(30, function(timer)
        cs = cs + 1
        a = a + v
        local dis = u:getdata("暗神-界域大小")
        dx, dy = PolarXY(x, y, dis, a)
        SetEffectXY(tx, dx, dy)
        if u:hasdata("暗神-结束判定") or u:hasdata("暗神-失败结束标记") then
          DestroyEffectLua(tx)
          timer:remove()
        end
      end)
    end
    local ax, ay = x, y
    local cs = 0
    local amax = 30
    if Nandu_Choose >= 5 then
      amax = 0
    end
    ac.loop(200, function(timer)
      local fanwei = u:getdata("暗神-界域大小")
      if not u:hasdata("暗神-场地禁用判定") then
        if Nandu_Choose >= 5 then
          cs = cs + 1
          if cs == 5 then
            cs = 0
            ForGroupLuaNew(Group_PlayHero, function(xq)
              if xq:isalive() then
                xq:setdata("暗神-死亡惩罚时间", 0)
              else
                xq:changedata("暗神-死亡惩罚时间", 1)
                if xq:getdata("暗神-死亡惩罚时间") >= amax and 1 <= xq:getdata("黑曜物质层数") then
                  xq:changedata("黑曜物质层数", -1)
                end
              end
            end)
          end
        end
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() then
            local x2, y2 = xq:getxy()
            local juli = DistanceXY(ax, ay, x2, y2)
            if juli > fanwei then
              AnshenDamage(u, xq, txsh)
              if u:getdata("噬星灾神阶段") >= 3 and xq:getdata("黑曜物质层数") >= 1 then
                xq:changedata("黑曜物质层数", -1)
              end
            end
          end
        end)
      end
      if u:hasdata("暗神-结束判定") or u:hasdata("暗神-失败结束标记") then
        timer:remove()
      end
    end)
    local dcs = 0
    ac.loop(100, function(t)
      if u:hasdata("暗神-失败结束标记") then
        t:remove()
        return
      end
      dcs = dcs + 1
      local dx, dy = PolarXY(x, y, GetRandomReal(0, 6000), GetRandomAngle())
      EffectcreateArgs({
        effect = "war3mapImported\\BOSS_4D_zhishixian.mdx",
        x = dx,
        y = dy,
        size = 1,
        zxz = GetRandomAngle(),
        yxz = 90,
        animespeed = 1
      })
      ac.wait(500, function()
        EffectcreateArgs({
          effect = "war3mapImported\\BOSS_4D_guangzhu1.mdx",
          x = dx,
          y = dy,
          size = 5,
          zxz = GetRandomAngle(),
          animespeed = 1
        })
        for _, xq in ac.selector():in_rangexy(dx, dy, 200):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          AnshenDamage(u, xq, txsh)
        end
      end)
      if 610 <= dcs then
        SendMsgAll("|cFF9966CC『噬星灾神』|r|cFFCC99FF.赫|r|cFFAA77FF尔|r|cFF9966FF泽|r|cFF8855FF斯|r")
        ShowUnit(u.handle, true)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() then
            xq:shockcamera(100, 1)
          end
        end)
        local tx = EffectcreateArgs({
          effect = "war3mapImported\\BOSS_4D_heidong3.mdx",
          x = x,
          y = y,
          time = 10,
          size = 10,
          zxz = jd,
          animespeed = 1
        })
        ac.wait(9000, function()
          if u:hasdata("暗神-失败结束标记") then
            return
          end
          local cs1 = 0
          ac.loop(100, function(t1)
            if u:hasdata("暗神-失败结束标记") then
              t1:remove()
              return
            end
            cs1 = cs1 + 1
            japi.EXSetEffectSize(tx, 10 - cs1 / 10)
            EffectcreateArgs({
              effect = "war3mapImported\\BOSS_4D_jiguang7.mdx",
              x = x,
              y = y,
              size = cs1,
              height = 200,
              zxz = jd,
              yxz = -90,
              animespeed = 1
            })
            if 10 <= cs1 then
              japi.EXSetEffectSize(tx1, 1.33)
              u:setdata("暗神-界域大小", 2000)
              u:setdata("噬星灾神阶段", 1)
              u:deldata("暗神永恒")
              ac.wait(5000, function()
                u:clearbuff("无敌")
              end)
              u:setdata("循环次数", 0)
              u:setdata("星蚀界域X", x)
              u:setdata("星蚀界域Y", y)
              anshen_skillloop(u, 1)
              AnshenSkill["双星"](u)
              ac.wait(3000, function()
                AnshenSkill["逆反物质"](u)
              end)
              ForGroupLuaNew(Group_AllHero, function(xq)
                local sy = xq.ownerid
                xq:deldata("暗神-无光之视")
                xq:setdata("暗神-旧日凝视")
              end)
              BuffUI.apply({
                id = "旧日凝视",
                duration = 99999
              })
              BuffUI.remove("无光之视")
              if PlayerCount == 1 then
                local hero
                ForGroupLuaNew(Group_PlayHero, function(xq)
                  hero = xq
                end)
                if hero then
                  do
                    local ax, ay = x, y
                    local x2, y2 = u:getdata("星蚀界域X"), u:getdata("星蚀界域Y")
                    ax, ay = PolarXY(x2, y2, GetRandomReal(300, 900), GetRandomAngle())
                    local angel = AngleXY(ax, ay, x2, y2)
                    local qk = CreateUnitLua(ConvertedPlayer(7), S2ID("u03J"), ax, ay, angel)
                    qk = getunit(qk)
                    local b = false
                    local t = 0
                    local t2 = 0
                    local tmax = 3
                    local flashtime = 30
                    if Nandu_Choose <= 4 then
                      tmax = 10
                      flashtime = 20
                    end
                    local tt = flytext({
                      unit = u.handle,
                      text = "",
                      size = 10,
                      time = -1,
                      r = 255,
                      g = 204,
                      b = 102,
                      height = 0,
                      xspeed = 0,
                      yspeed = 0
                    })
                    local tt2 = flytext({
                      unit = u.handle,
                      text = "",
                      size = 6,
                      time = -1,
                      r = 102,
                      g = 153,
                      b = 255,
                      height = 0,
                      xspeed = 0,
                      yspeed = 0
                    })
                    local nlq = Effectcreate("war3mapImported\\Texiao_jinggao2.mdx", ax, ay, -1, 1.25)
                    SetEffectSize(nlq, 1.25)
                    local run = true
                    ac.loop(100, function(timer)
                      local ux, uy = hero:getxy()
                      local dis = DistanceXY(ux, uy, ax, ay)
                      if run then
                        if dis <= 125 and not u:hasdata("一阶段尾杀释放中") then
                          if not b then
                            b = true
                            hero:sendmessage("|cFFFFCC66青空的加护|r")
                          end
                          if not hero:hasdata("青空的加护特效") then
                            hero:setdata("青空的加护特效", hero:effectadd("BOSS_Anshen_Qingkong.mdx", "overhead", -1))
                          end
                        elseif hero:hasdata("青空的加护特效") then
                          DestroyEffectLua(hero:getdata("青空的加护特效"))
                          hero:deldata("青空的加护特效")
                        end
                        if b then
                          t = t + 0.1
                          SetTextTagText(tt, string.format("%.1f", tmax - t), TextTagSize2Height(10))
                          SetTextTagPosUnit(tt, qk.handle, 0)
                          if t >= tmax then
                            t = 0
                            b = false
                            run = false
                            SetTextTagText(tt, "", TextTagSize2Height(10))
                            SetEffectSize(nlq, 0.01)
                            if hero:hasdata("青空的加护特效") then
                              DestroyEffectLua(hero:getdata("青空的加护特效"))
                              hero:deldata("青空的加护特效")
                            end
                          end
                        end
                      else
                        t2 = t2 + 0.1
                        SetTextTagText(tt2, math.floor(flashtime - t2), TextTagSize2Height(10))
                        SetTextTagPosUnit(tt2, qk.handle, 0)
                        if t2 >= flashtime then
                          t2 = 0
                          run = true
                          SetTextTagText(tt2, "", TextTagSize2Height(10))
                          hero:playseensound(BOSS_Zhenhong_Chuansong)
                          local dx, dy = qk:getxy()
                          EffectcreateArgs({
                            effect = "war3mapImported\\Texiao_zhenhongchuansong1.mdx",
                            x = dx,
                            y = dy
                          })
                          dx, dy = PolarXY(x2, y2, GetRandomReal(300, 900), GetRandomAngle())
                          EffectcreateArgs({
                            effect = "war3mapImported\\Texiao_zhenhongchuansong1.mdx",
                            x = dx,
                            y = dy
                          })
                          angel = AngleXY(dx, dy, x2, y2)
                          qk:setface(angel)
                          qk:setxy(dx, dy)
                          ax, ay = dx, dy
                          SetEffectSize(nlq, 1.25)
                          SetEffectXY(nlq, dx, dy)
                        end
                      end
                      if u:hasdata("暗神-二阶段尾杀") or u:hasdata("暗神-失败结束标记") then
                        local dx, dy = qk:getxy()
                        EffectcreateArgs({
                          effect = "war3mapImported\\Texiao_zhenhongchuansong1.mdx",
                          x = dx,
                          y = dy
                        })
                        if hero:hasdata("青空的加护特效") then
                          DestroyEffectLua(hero:getdata("青空的加护特效"))
                          hero:deldata("青空的加护特效")
                        end
                        DestroyEffectLua(nlq)
                        TimerDestroyTextTag(0, tt)
                        TimerDestroyTextTag(0, tt2)
                        qk:remove()
                        timer:remove()
                      end
                    end)
                  end
                end
              end
              t1:remove()
            end
          end)
        end)
        t:remove()
      end
    end)
    local cs1 = 0
    ac.loop(10500, function(t1)
      if u:hasdata("暗神-失败结束标记") then
        t1:remove()
        return
      end
      cs1 = cs1 + 1
      AnshenSkill["渊咒蚀界"](u, x, y)
      if 5 <= cs1 then
        t1:remove()
      end
    end)
  end)
end
