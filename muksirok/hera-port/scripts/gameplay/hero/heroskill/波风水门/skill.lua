-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local message = require("jass.message")

local function pick_nearest_kunai(u, ax, ay, dis2)
  local group = u:getdata("波风水门-飞雷神苦无组") or {}
  local ux, uy = ax, ay
  local dx, dy = ax, ay
  local tg = 0
  local ndis = dis2
  for i = #group, 1, -1 do
    local k = group[i]
    local x, y = GetEffectXY(k)
    local dis = DistanceXY(x, y, ux, uy)
    if ndis > dis then
      ndis = dis
      tg = k
      dx, dy = x, y
    end
  end
  if u:hasdata("波风水门天赋-我用双手成就梦想") then
    local group2 = u:getdata("波风水门-飞雷神苦无火把组")
    ForGroupLuaNew(group2, function(xq)
      local x, y = xq:getxy()
      local dis = DistanceXY(x, y, ux, uy)
      if dis < ndis then
        ndis = dis
        tg = xq
        dx, dy = x, y
      end
    end)
  end
  return tg, dx, dy
end

local function flsshow(tx1)
  -- 표시 전용 확장이 없는 JN 환경에서도 투사체 이동과 수명 처리를 계속한다.
  if type(japi.EXSetEffectVisible) == "function" then
    japi.EXSetEffectVisible(tx1, true)
  end
  if type(japi.EXSetEffectFogVisible) == "function" then
    japi.EXSetEffectFogVisible(tx1, true)
  end
  if type(japi.EXSetEffectMaskVisible) == "function" then
    japi.EXSetEffectMaskVisible(tx1, true)
  end
end

local function returntime(u, time)
  if u:hasdata("波风水门天赋-看来已经准备好了") then
    time = time + 10
  end
  return time
end

local function flashfls(u)
  local group = u:getdata("波风水门-飞雷神苦无组")
  for i = #group, 1, -1 do
    local value = group[i]
    if GetData(value, "飞雷神苦无-消失时间") <= 0 then
      table.remove(group, i)
      SetEffectSize(value, 0.01)
      DestroyEffectLua(value)
    end
  end
  if u:hasdata("波风水门天赋-我用双手成就梦想") then
    local group2 = u:getdata("波风水门-飞雷神苦无火把组")
    ForGroupLuaNew(group2, function(xq)
      if xq:getdata("飞雷神苦无火把-消失时间") <= 0 then
        xq:groupremove(group2)
        xq:deldata("飞雷神苦无火把-消失时间")
        xq:remove()
      end
    end)
  end
end

local function flscf(u)
  if u:hasdata("神器判定-飞雷神苦无") then
    u:buffset(u.handle, 0.05, "绝对闪避")
  end
  if u:hasdata("波风水门天赋-虽然是对手但是你还不赖嘛") then
    u:changetimedata("波风水门-一式伤害限时提升", 0.002, 15)
    u:changetimedata("波风水门-螺旋天光计数", 1, 15)
    if u:islocal() then
      if u:hasdata("青水皮肤-茉子") then
        BuffUI.apply({
          id = "波风水门-螺旋天光皮肤",
          duration = 15.1
        })
      else
        BuffUI.apply({
          id = "波风水门-螺旋天光",
          duration = 15.1
        })
      end
    end
  end
  if u:hasdata("波风水门天赋-背负着火影之名我不能输") then
    u:changetimedata("波风水门-基础伤害加成", 0.07, 10)
    u:changetimedata("波风水门-伤害生命损耗", 7.0E-5, 10)
    u:changetimedata("波风水门-火之意志层数", 1, 10)
    if u:islocal() then
      if u:hasdata("青水皮肤-茉子") then
        BuffUI.apply({
          id = "波风水门-火之意志皮肤",
          duration = 10.1
        })
      else
        BuffUI.apply({
          id = "波风水门-火之意志",
          duration = 10.1
        })
      end
    end
  end
end

local function flashflstime(u, fb)
  if fb ~= 0 or type(fb) == "table" then
    if u:hasdata("波风水门天赋-我来晚了么") then
      if type(fb) == "table" then
        fb:changedata("飞雷神苦无火把-消失时间", -10)
      else
        ChangeData(fb, "飞雷神苦无-消失时间", -10)
      end
    elseif type(fb) == "table" then
      fb:setdata("飞雷神苦无火把-消失时间", 0)
    else
      SetData(fb, "飞雷神苦无-消失时间", 0)
    end
    flashfls(u)
  end
end

local function Bezier(tx, x, y, x1, y1, x2, y2, jd, jl, sd)
  local startX, startY = x, y
  local endX, endY = x1, y1
  local ctrlX, ctrlY = x2, y2
  local cs = 0
  ac.loop(10, function(t1)
    cs = cs + 1
    if cs >= sd then
      japi.EXSetEffectXY(tx, endX, endY)
      DestroyEffectLua(tx)
      t1:remove()
    else
      local progress = cs / sd
      local t = progress
      local u = 1 - t
      local tt = t * t
      local uu = u * u
      local curX = uu * startX + 2 * u * t * ctrlX + tt * endX
      local curY = uu * startY + 2 * u * t * ctrlY + tt * endY
      japi.EXSetEffectXY(tx, curX, curY)
    end
  end)
end

local txcount = 0

local function bfsmdamage(args)
  local u = args.u
  local xq = args.xq
  local damage = args.damage or 0
  local time = args.bufftime or 0
  local damagetype = args.type or "物理"
  local isvest = args.isvest or false
  local bufftype = args.bufftype or "僵直"
  local jcsh = u:getdata("角色基础伤害")
  if txcount < 15 then
    txcount = txcount + 1
    local tx = "Bfsmtx\\bfsm_fls_shanguang1.mdx"
    if u:hasdata("青水皮肤-茉子") then
      tx = "Bfsmtx\\bfsm_fls_shanguang_fs.mdx"
    end
    xq:effectadd(tx, "chest")
    ac.wait(1000, function()
      txcount = txcount - 1
    end)
  end
  local ex = {""}
  if u:hasdata("波风水门-零式发动中") then
    ex = {
      "系统-本次伤害无视伤害抗性"
    }
  end
  if not xq:isnormal() then
    if u:hasdata("波风水门天赋-背负着火影之名我不能输") then
      local xh = u:getdata("波风水门-伤害生命损耗") * xq:gethp()
      LossHpUnit({
        u = u,
        tg = xq,
        damage = xh,
        bj = "波风水门(火影之名损耗)"
      })
    end
    if xq:isboss() then
      if u:hasdata("波风水门-一式附伤") then
        if u:hasdata("波风水门天赋-虽然是对手但是你还不赖嘛") then
          u:setdata("波风水门-固定附伤", 0.01)
        else
          u:setdata("波风水门-固定附伤", 0.005)
        end
        u:deldata("波风水门-一式附伤")
      end
      if u:hasdata("波风水门-一式斩杀附伤") then
        u:setdata("波风水门-斩杀附伤")
        u:deldata("波风水门-一式斩杀附伤")
      end
    else
      u:deldata("波风水门-一式附伤")
      u:deldata("波风水门-一式斩杀附伤")
    end
  else
    u:deldata("波风水门-一式附伤")
    u:deldata("波风水门-一式斩杀附伤")
  end
  DamageUnit({
    bj = "波风水门(机体)",
    unit = xq.handle,
    source = u.handle,
    damage = jcsh * damage,
    level = 1,
    type = damagetype,
    isvest = isvest,
    isattack = true,
    isnoarmor = false,
    element = "无",
    extradata = ex
  })
  if 0 < time then
    xq:buffset(u.handle, time, bufftype)
  end
end

local function mzhf(u, tg, str)
  local value = 1
  if str == "DR" then
    value = 4
  end
  if str == "DQ" then
    value = 2
  end
  if str == "DA" then
    value = 25
  end
  if tg:isboss() then
    value = value * 4
  end
  u:changedata("波风水门-奥义充能值", value)
  if u:getdata("波风水门-奥义充能值") >= u:getdata("波风水门-奥义充能上限") then
    u:setdata("波风水门-奥义充能值", u:getdata("波风水门-奥义充能上限"))
  end
end

local function FsAngle(x1, y1, z1, x2, y2, z2)
  local dx = x2 - x1
  local dy = y2 - y1
  local dz = z2 - z1
  local jdz = math.sqrt(dx * dx + dy * dy)
  local z = -math.atan(dz, jdz)
  return z
end

local function flssound(u)
  if not u:hasdata("波风水门-飞雷神音效冷却") then
    u:settimedata("波风水门-飞雷神音效冷却", 0.5)
    if u:hasdata("青水皮肤-茉子") then
      local yxz = {
        Mozi_Ikuzo_01,
        Mozi_Ikuzo_02,
        Mozi_Ikuzo_03,
        Mozi_osoyi_01,
        Mozi_osoyi_02,
        Mozi_osoyi_03,
        Mozi_osoyi_04,
        Mozi_Zheliyo_01,
        Mozi_Zheliyo_02,
        Mozi_Zheliyo_03,
        Mozi_Zheliyo_04,
        Mozi_Zheliyo_05
      }
      if u:hasdata("茉子-兽化状态") then
        yxz = {
          Mozi_Wang_01,
          Mozi_Wang_02,
          Mozi_Wang_03
        }
      end
      u:playseensound(yxz[GetRandomInt(1, #yxz)])
    else
      local count = u:getdata("波风水门-飞雷神音效循环")
      local yxz = {
        Bfsm_fls1,
        Bfsm_fls2,
        Bfsm_fls3,
        Bfsm_fls4,
        flx_d_01,
        flx_d_02
      }
      u:playseensound(yxz[count])
      if count >= #yxz then
        u:setdata("波风水门-飞雷神音效循环", 0)
      end
      u:changedata("波风水门-飞雷神音效循环", 1)
    end
  end
  if GetRandom100(50) then
    u:playseensound(Bfsm_fls_shunyi1)
  else
    u:playseensound(Bfsm_fls_shunyi2)
  end
end

local function quxian(u, fb, x1, y1, qu)
  local x, y = u:getxy()
  qu = qu or false
  if u:hasdata("波风水门天赋-多少了解金色闪光的由来了吧") then
    qu = false
  end
  if u:hasdata("波风水门-弹反瞬移") then
    local tg = u:getdata("波风水门-飞雷神弹反标记单位")
    local jd2 = tg:getface()
    u:setface(jd2)
    jd2 = jd2 + 180
    x1, y1 = tg:getxy()
    x1, y1 = PolarXY(x1, y1, 100, jd2)
  else
    flashflstime(u, fb)
  end
  u:setdata("波风水门-瞬影残中断")
  u:deldata("波风水门-弹反限制")
  local skillstr = "E"
  local dis = DistanceXY(x, y, x1, y1)
  local jd = AngleXY(x, y, x1, y1)
  local mz = false
  local x2, y2
  local j = 15
  if qu then
    j = 20
    x2, y2 = PolarXY(x, y, GetRandomReal(dis / 2, dis), jd + GetRandomAngle())
  else
    x2, y2 = PolarXY(x, y, 0, jd + GetRandomAngle())
  end
  local jl = DistanceXY(x, y, x1, y1)
  ac.wait(1, function()
    if u:hasdata("青水皮肤-茉子") then
      if qu then
        u:animeact(3)
        u:animespeed(2)
        ac.wait(500, function()
          u:animespeed(1)
        end)
      else
        u:animeact(3)
        u:animespeed(2)
        ac.wait(500, function()
          u:animespeed(1)
        end)
      end
    elseif qu then
      u:animeact(51)
      u:animespeed(1)
    else
      u:animeact(51)
      u:animespeed(1)
    end
  end)
  flssound(u)
  local zf = ""
  if u:hasdata("波风水门皮肤") then
    EffectcreateArgs({
      effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
      x = x,
      y = y,
      time = 0.5,
      size = 1,
      height = 0,
      zxz = jd,
      animespeed = 1
    })
    EffectcreateArgs({
      effect = "Bfsmtx\\bfsmpf_fls_shunyi1.mdx",
      x = x,
      y = y,
      size = 2,
      height = 0,
      zxz = jd,
      animespeed = 1
    })
    zf = "Bfsmtx\\bfsmpf_tuowei1.mdx"
  else
    EffectcreateArgs({
      effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
      x = x,
      y = y,
      size = 1.5,
      height = 25,
      zxz = jd,
      animespeed = 1
    })
    EffectcreateArgs({
      effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
      x = x,
      y = y,
      size = 0.75,
      height = 175,
      zxz = jd,
      animespeed = 1
    })
    zf = "Bfsmtx\\bfsm_fls_tuowei3.mdx"
  end
  local tx1 = EffectcreateArgs({
    effect = zf,
    x = x,
    y = y,
    time = -1,
    size = 3,
    height = 100,
    zxz = jd,
    animespeed = 3
  })
  if type(japi.EXSetEffectFogVisible) == "function" then
    japi.EXSetEffectFogVisible(tx1, true)
  end
  if type(japi.EXSetEffectMaskVisible) == "function" then
    japi.EXSetEffectMaskVisible(tx1, true)
  end
  Bezier(tx1, x, y, x1, y1, x2, y2, jd, jl, j)
  local bs = 1
  local kz = 0
  local fwadd = 0
  if u:hasdata("波风水门天赋-多少了解金色闪光的由来了吧") then
    bs = 2
    kz = 0.5
    fwadd = 20
  end
  if not qu then
    local dx, dy = u:getxy()
    local g = CreateGroupLua()
    local count = math.floor(dis / 90) + 1
    for i = 1, count do
      local ix, iy = PolarXY(dx, dy, i * 90, jd)
      for _, xq in ac.selector():in_rangexy(ix, iy, 140 + fwadd):is_enemy(u.handle):isnotingroup(g):ipairs() do
        xq = getunit(xq)
        xq:groupadd(g)
      end
    end
    ForGroupLuaNew(g, function(xq)
      if not mz then
        mz = true
        xq:playseensound(bfsm_hit_01)
        mzhf(u, xq, skillstr)
      end
      bfsmdamage({
        u = u,
        xq = xq,
        damage = 2 * bs,
        bufftime = 0.5
      })
    end)
  end
  for _, xq in ac.selector():in_rangexy(x, y, 300 + fwadd * 3):is_enemy(u.handle):ipairs() do
    xq = getunit(xq)
    bfsmdamage({
      u = u,
      xq = xq,
      damage = bs,
      bufftime = kz
    })
    if not mz then
      mz = true
      mzhf(u, xq, skillstr)
    end
  end
  for _, xq in ac.selector():in_rangexy(x1, y1, 300 + fwadd * 3):is_enemy(u.handle):ipairs() do
    xq = getunit(xq)
    bfsmdamage({
      u = u,
      xq = xq,
      damage = bs,
      bufftime = kz
    })
    if not mz then
      mz = true
      mzhf(u, xq, skillstr)
    end
  end
  if u:hasdata("波风水门-弹反瞬移") then
  else
    u:setface(jd)
  end
  ac.wait(1, function()
    u:setxy(x1, y1)
    IssueImmediateOrder(u.handle, "stop")
    u:setdata("位移点X", x1)
    u:setdata("位移点Y", y1)
  end)
  ac.wait(100, function()
    if u:hasdata("波风水门皮肤") then
      EffectcreateArgs({
        effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
        x = x1,
        y = y1,
        time = 0.5,
        size = 1,
        height = 0,
        zxz = jd,
        animespeed = 1
      })
      EffectcreateArgs({
        effect = "Bfsmtx\\bfsmpf_fls_shunyi1.mdx",
        x = x1,
        y = y1,
        size = 2,
        height = 0,
        zxz = jd,
        animespeed = 1
      })
    else
      EffectcreateArgs({
        effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
        x = x1,
        y = y1,
        size = 1.5,
        height = 25,
        zxz = jd,
        animespeed = 1
      })
      EffectcreateArgs({
        effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
        x = x1,
        y = y1,
        size = 0.75,
        height = 175,
        zxz = jd,
        animespeed = 1
      })
    end
  end)
end

local function syc(u, x, y, x2, y2, angle, tg)
  if u:hasdata("青水皮肤-茉子") then
    local yxz = {
      Mozi_Ikuzo_01,
      Mozi_Ikuzo_02,
      Mozi_Ikuzo_03
    }
    if u:hasdata("茉子-兽化状态") then
      yxz = {
        Mozi_Wang_01,
        Mozi_Wang_02,
        Mozi_Wang_03
      }
    end
    u:playseensound(yxz[GetRandomInt(1, #yxz)])
  else
    u:playseensound(Bfsm_fls3)
  end
  u:deldata("波风水门-弹反限制")
  u:setdata("波风水门-瞬影残连携时间", 0.8)
  u:buffset(u.handle, 0.6, "绝对闪避")
  if tg then
    flashflstime(u, tg)
    ac.wait(100, function()
      u:setdata("波风水门-瞬影残瞬移时间", 1)
      local zf1 = ""
      if u:hasdata("波风水门皮肤") then
        zf1 = "Bfsmtx\\bfsmpf_tuowei1.mdx"
      else
        zf1 = "Bfsmtx\\bfsm_fls_tuowei3change.mdx"
      end
      u:effectadd(zf1, "left hand", 1)
    end)
  end
  if u:hasdata("波风水门皮肤") then
    EffectcreateArgs({
      effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
      x = x,
      y = y,
      time = 0.5,
      size = 1,
      height = 0,
      zxz = angle,
      animespeed = 1
    })
    EffectcreateArgs({
      effect = "Bfsmtx\\bfsmpf_fls_shunyi1.mdx",
      x = x,
      y = y,
      size = 2,
      height = 0,
      zxz = angle,
      animespeed = 1
    })
  else
    EffectcreateArgs({
      effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
      x = x,
      y = y,
      size = 3,
      height = 0,
      zxz = angle,
      animespeed = 1
    })
    EffectcreateArgs({
      effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
      x = x,
      y = y,
      size = 1,
      height = 250,
      zxz = angle,
      animespeed = 1
    })
  end
  ac.wait(10, function(t)
    flscf(u)
    if u:hasdata("青水皮肤-茉子") then
      u:animeact(3)
      u:animespeed(2)
      ac.wait(500, function()
        u:animespeed(1)
      end)
    else
      u:animeact(51)
      u:animespeed(2)
      ac.wait(500, function()
        u:animespeed(1)
      end)
    end
    x, y = u:getxy()
    local x1, y1 = PolarXY(x, y, 1000, angle)
    local dx, dy = PolarXY(x1, y1, 400, angle + GetRandomAngle())
    dx, dy = x2, y2
    local dx2, dy2 = PolarXY(x1, y1, GetRandomReal(1000, 2000), angle + GetRandomAngle())
    local jd = AngleXY(x, y, x1, y1)
    local jd2 = AngleXY(x1, y1, dx, dy)
    local jl = DistanceXY(x1, y1, dx, dy)
    local zf = ""
    if u:hasdata("波风水门皮肤") then
      EffectcreateArgs({
        effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
        x = dx,
        y = dy,
        time = 0.5,
        size = 1,
        height = 0,
        zxz = jd,
        animespeed = 1
      })
      EffectcreateArgs({
        effect = "Bfsmtx\\bfsmpf_fls_shunyi1.mdx",
        x = dx,
        y = dy,
        size = 2,
        height = 0,
        zxz = jd,
        animespeed = 1
      })
      zf = "Bfsmtx\\bfsmpf_tuowei1.mdx"
    else
      EffectcreateArgs({
        effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
        x = dx,
        y = dy,
        size = 3,
        height = 0,
        zxz = jd,
        animespeed = 1
      })
      EffectcreateArgs({
        effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
        x = dx,
        y = dy,
        size = 1,
        height = 250,
        zxz = jd,
        animespeed = 1
      })
      zf = "Bfsmtx\\bfsm_fls_tuowei3.mdx"
    end
    local tx1 = EffectcreateArgs({
      effect = zf,
      x = x1,
      y = y1,
      time = -1,
      size = 3,
      height = 100,
      zxz = jd,
      animespeed = 3
    })
    if type(japi.EXSetEffectFogVisible) == "function" then
      japi.EXSetEffectFogVisible(tx1, true)
    end
    if type(japi.EXSetEffectMaskVisible) == "function" then
      japi.EXSetEffectMaskVisible(tx1, true)
    end
    Bezier(tx1, x, y, dx, dy, dx2, dy2, jd, jl, 20)
    u:setface(jd)
    local dis2 = DistanceXY(x, y, dx, dy)
    local djd = AngleXY(x, y, dx, dy)
    unitmove({
      unit = u.handle,
      time = 0.05,
      distance = dis2,
      angle = djd,
      isfly = true,
      loops = {
        {
          looptime = 0.01,
          func = function(dx, dy, args)
            if u:hasdata("波风水门-瞬影残中断") then
              args.stop = true
            end
          end
        }
      },
      endfunc = function(ax, ay)
        u:setdata("位移点X", ax)
        u:setdata("位移点Y", ay)
      end,
      isblink = true
    })
    local yxz = {
      Bfsm_fls_shunyi2,
      Bfsm_fls_shunyi3,
      Bfsm_fls_shunyi4
    }
    u:playseensound(yxz[GetRandomInt(1, #yxz)])
    if u:hasdata("青水皮肤-茉子") then
      local yxz = {
        Mozi_osoyi_01,
        Mozi_osoyi_02,
        Mozi_osoyi_03,
        Mozi_osoyi_04
      }
      if u:hasdata("茉子-兽化状态") then
        yxz = {
          Mozi_Wang_01,
          Mozi_Wang_02,
          Mozi_Wang_03
        }
      end
      u:playseensound(yxz[GetRandomInt(1, #yxz)])
    else
      u:playseensound(Bfsm_fls2)
    end
    local zf1 = ""
    if u:hasdata("波风水门皮肤") then
      zf1 = "Bfsmtx\\bfsmpf_tuowei1.mdx"
    else
      zf1 = "Bfsmtx\\bfsm_fls_tuowei3change.mdx"
    end
    u:effectadd(zf1, "chest", 0.1)
    IssueImmediateOrder(u.handle, "stop")
  end)
end

local zgskill
zgskill = {
  ["通灵之术改"] = function(u)
    local sy = u.ownerid
    local x, y = u:getxy()
    japi.SetUnitModel(u.handle, "units\\creeps\\WhiteWolf\\WhiteWolf.mdl")
    u:playseensound(bfsm_tss)
    local x, y = u:getxy()
    Effectcreate("Bfsmtx\\bfsm_tss.mdx", x, y)
    local bs = 1
    local time = 8
    if u:hasdata("波风水门天赋-老师的意志就交给我吧") then
      time = 12
      bs = 2
    end
    u:changeoriginmaxhp(0.1 * (5000 * bs))
    ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 250 * bs)
    u:addskill("S0CH")
    u:clearbuff("眩晕")
    u:clearbuff("僵直")
    u:clearbuff("缠绕")
    u:setdata("波风水门-通灵之术霸体", time)
    u:setdata("茉子-兽化状态")
    if u:islocal() then
      BuffUI.apply({
        id = "茉子-兽化",
        duration = time + 0.1
      })
    end
    ac.loop(100, function(timer)
      if u:hasbuff("暂停") and u:hasdata("波风水门天赋-老师的意志就交给我吧") then
        u:setdata("波风水门-通灵之术霸体", time)
        if u:islocal() then
          BuffUI.apply({
            id = "茉子-兽化",
            duration = time + 0.1
          })
        end
      else
        time = time - 0.1
      end
      if time <= 0 then
        u:deldata("茉子-兽化状态")
        ModelReSet({
          u = u,
          model = "HERO\\CLMZ.mdx",
          modelsize = 1.1
        })
        u:delskill("S0CH")
        u:clearbuff("B0GO")
        u:playseensound(bfsm_tss)
        u:changeoriginmaxhp(0.1 * (-5000 * bs))
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -250 * bs)
        local x, y = u:getxy()
        Effectcreate("Bfsmtx\\bfsm_tss.mdx", x, y)
        timer:remove()
      end
    end)
  end,
  ["通灵之术"] = function(u)
    u:setdata("波风水门-通灵之术霸体", 4)
    local x, y = u:getxy()
    local jd = u:getface()
    local size = 3
    local fw = 450
    local bs = 2
    if u:hasdata("波风水门天赋-老师的意志就交给我吧") then
      size = 5
      fw = 900
      bs = 4
    end
    local height = 1600
    local tx = Effectcreate("units\\creeps\\FurbolgPanda\\FurbolgPanda.mdx", x, y, -1, size, height, jd)
    ac.wait(1, function()
      SetEffectAnimation(tx, "attack spell")
      SetEffectActSpeed(tx, 2)
    end)
    ac.timer(20, 10, function()
      height = height - 160
      SetEffectHeight(tx, height)
    end)
    ac.wait(200, function()
      Effectcreate("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x, y, 0, size)
      for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        bfsmdamage({
          u = u,
          xq = xq,
          damage = bs,
          bufftime = bs,
          bufftype = "眩晕",
          type = "震荡"
        })
      end
    end)
    ac.wait(1000, function()
      SetEffectHeight(tx, 5000)
      SetEffectSize(tx, 0.01)
      DestroyEffectLua(tx)
    end)
  end,
  W = function(u)
    local skillstr = "W"
    local x, y = u:getxy()
    local jd = u:getface()
    local yxz = {
      minato4_atk1_01,
      minato4_atk1_02,
      minato4_atk1_03,
      minato4_atk1_04
    }
    if u:hasdata("青水皮肤-茉子") then
      yxz = {
        Mozi_Yuqici_01,
        Mozi_Yuqici_03,
        Mozi_Yuqici_04
      }
      if u:hasdata("茉子-兽化状态") then
        yxz = {
          Mozi_Wang_01,
          Mozi_Wang_02,
          Mozi_Wang_03
        }
      end
    end
    u:playsound(Sound_Bfsm_AFA2)
    u:playseensound(yxz[GetRandomInt(1, #yxz)])
    local zf1 = ""
    if u:hasdata("波风水门皮肤") then
      zf1 = "Bfsmtx\\bfsmpf_tuowei1.mdx"
    else
      zf1 = "Bfsmtx\\bfsm_fls_tuowei3change.mdx"
    end
    u:effectadd(zf1, "left hand", 0.3)
    ac.wait(1, function()
      if u:hasdata("青水皮肤-茉子") then
        u:animeact(2)
        u:animespeed(2)
        ac.wait(500, function()
          u:animespeed(1)
        end)
      else
        if GetRandom100(50) then
          u:animeact(13)
        else
          u:animeact(16)
        end
        u:animespeed(2)
      end
    end)
    u:setdata("波风水门-W连携时间", 0.8)
    if u:getdata("波风水门-弹反连携强化效果") > 0 then
      u:buffset(u.handle, 0.15, "绝对闪避")
      u:setdata("波风水门-弹反连携强化效果2", 0.8)
      u:setdata("波风水门-弹反连携强化效果", 0)
      u:setdata("波风水门-弹反瞬移")
      quxian(u, 0, x, y, false)
      u:deldata("波风水门-弹反瞬移")
      ac.wait(1, function()
        jd = u:getface()
        x, y = u:getxy()
        unitmove({
          unit = u.handle,
          time = 0.1,
          distance = 200,
          angle = jd,
          isfly = true
        })
      end)
    else
      unitmove({
        unit = u.handle,
        time = 0.1,
        distance = 400,
        angle = jd,
        isfly = true
      })
    end
    ac.wait(1, function()
      IssueImmediateOrder(u.handle, "stop")
    end)
    ac.wait(101, function()
      local dx, dy = u:getxy()
      u:setdata("位移点X", dx)
      u:setdata("位移点Y", dy)
      local zf2 = ""
      if u:hasdata("波风水门皮肤") then
        zf2 = "Bfsmtx\\bfsm_a2.mdx"
      else
        zf2 = "Bfsmtx\\bfsm_a.mdx"
      end
      local dxx, dyy = PolarXY(dx, dy, 25, jd)
      dxx, dyy = PolarXY(dxx, dyy, 75, jd - 90)
      EffectcreateArgs({
        effect = zf2,
        x = dxx,
        y = dyy,
        size = 1.75,
        height = -35,
        zxz = jd + 0,
        xxz = -20,
        animespeed = 1
      })
      local mz = false
      for _, xq in ac.selector():in_rangexy(dx, dy, 300):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        if not mz then
          mz = true
          xq:playseensound(bfsm_hit_01)
          mzhf(u, xq, skillstr)
        end
        bfsmdamage({
          u = u,
          xq = xq,
          damage = 1,
          bufftime = 0.5
        })
        unitmove({
          unit = xq.handle,
          time = 0.05,
          distance = 200,
          angle = jd,
          isfly = true
        })
      end
    end)
  end,
  WE = function(u)
    local skillstr = "WE"
    local x, y = u:getxy()
    local jd = u:getface()
    local zf1 = ""
    if u:hasdata("波风水门皮肤") then
      zf1 = "Bfsmtx\\bfsmpf_tuowei1.mdx"
    else
      zf1 = "Bfsmtx\\bfsm_fls_tuowei3change.mdx"
    end
    u:effectadd(zf1, "left hand", 0.3)
    local yxz = {
      minato4_atk2_01,
      minato4_atk2_02,
      minato4_atk2_03
    }
    if u:hasdata("青水皮肤-茉子") then
      yxz = {
        Mozi_Yuqici_01,
        Mozi_Yuqici_02,
        Mozi_Yuqici_03,
        Mozi_Yuqici_04
      }
      if u:hasdata("茉子-兽化状态") then
        yxz = {
          Mozi_Wang_01,
          Mozi_Wang_02,
          Mozi_Wang_03
        }
      end
    end
    u:playseensound(yxz[GetRandomInt(1, #yxz)])
    u:playsound(Sound_Bfsm_AFA2)
    u:buffset(u.handle, 0.3, "无敌")
    u:buffset(u.handle, 0.2, "暂停")
    if u:getdata("波风水门-弹反连携强化效果2") > 0 then
      u:buffset(u.handle, 0.3, "绝对闪避")
      u:setdata("波风水门-弹反连携强化效果2", 0)
      u:setdata("波风水门-弹反连携强化效果3", 0.6)
    end
    unitmove({
      unit = u.handle,
      time = 0.15,
      distance = 100,
      angle = u:getface(),
      isfly = true
    })
    ac.wait(1, function()
      if u:hasdata("青水皮肤-茉子") then
        u:animeact(3)
        u:animespeed(2)
        ac.wait(500, function()
          u:animespeed(1)
        end)
      else
        u:animeact(17)
        u:animespeed(2)
      end
    end)
    u:setdata("波风水门-W连携时间", 0)
    u:setdata("波风水门-WE连携时间", 0.6)
    ac.wait(1, function()
      IssueImmediateOrder(u.handle, "stop")
    end)
    ac.wait(151, function()
      local dx, dy = u:getxy()
      u:setdata("位移点X", dx)
      u:setdata("位移点Y", dy)
      local zf2 = ""
      if u:hasdata("波风水门皮肤") then
        zf2 = "Bfsmtx\\bfsm_a2.mdx"
      else
        zf2 = "Bfsmtx\\bfsm_a.mdx"
      end
      local dxx, dyy = PolarXY(dx, dy, -50, jd)
      dxx, dyy = PolarXY(dxx, dyy, 0, jd - 90)
      EffectcreateArgs({
        effect = zf2,
        x = dxx,
        y = dyy,
        size = 1.75,
        height = 200,
        zxz = jd + 0,
        xxz = 180,
        animespeed = 1
      })
      local mz = false
      for _, xq in ac.selector():in_rangexy(dx, dy, 300):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        if not mz then
          mz = true
          xq:playseensound(bfsm_hit_01)
          mzhf(u, xq, skillstr)
        end
        bfsmdamage({
          u = u,
          xq = xq,
          damage = 1,
          bufftime = 0.5
        })
        unitmove({
          unit = xq.handle,
          time = 0.05,
          distance = 200,
          angle = jd,
          isfly = true
        })
      end
    end)
  end,
  WEE = function(u)
    local skillstr = "WEE"
    local x, y = u:getxy()
    local zu = u:getdata("波风水门-飞雷神苦无组")
    local jd = u:getface()
    local yxz = {
      minato4_atk4_01,
      minato4_atk4_02
    }
    if u:hasdata("青水皮肤-茉子") then
      yxz = {
        Mozi_Ikuzo_01,
        Mozi_Ikuzo_02,
        Mozi_Ikuzo_03,
        Mozi_Yaoshangle
      }
      if u:hasdata("茉子-兽化状态") then
        yxz = {
          Mozi_Wang_01,
          Mozi_Wang_02,
          Mozi_Wang_03
        }
      end
    end
    u:playsound(Sound_Bfsm_AFA2)
    u:playseensound(yxz[GetRandomInt(1, #yxz)])
    local zf1 = ""
    if u:hasdata("波风水门皮肤") then
      zf1 = "Bfsmtx\\bfsmpf_tuowei1.mdx"
    else
      zf1 = "Bfsmtx\\bfsm_fls_tuowei3change.mdx"
    end
    ac.wait(1, function()
      IssueImmediateOrder(u.handle, "stop")
    end)
    u:effectadd(zf1, "left hand", 0.3)
    u:buffset(u.handle, 0.4, "无敌")
    u:buffset(u.handle, 0.3, "暂停")
    u:setdata("波风水门-WE连携时间", 0)
    if 0 < u:getdata("波风水门-弹反连携强化效果3") then
      u:buffset(u.handle, 0.4, "绝对闪避")
      u:setdata("波风水门-弹反连携强化效果3", 0)
    end
    unitjump({
      unit = u.handle,
      time = 0.3,
      height = 700,
      distance = 700,
      angle = u:getface() + 180,
      isfly = true
    })
    ac.wait(1, function()
      if u:hasdata("青水皮肤-茉子") then
        u:animeact(5)
        u:animespeed(2)
        ac.wait(400, function()
          u:animespeed(1)
        end)
      else
        u:animeact(9)
        u:animespeed(2)
        ac.wait(400, function()
          u:animeact(30)
          u:animespeed(1)
        end)
      end
    end)
    ac.wait(200, function()
      u:playsound(Sound_Bfsm_AA3)
      local dx, dy = u:getxy()
      local zf2 = ""
      if u:hasdata("波风水门皮肤") then
        zf2 = "Bfsmtx\\bfsm_a2.mdx"
      else
        zf2 = "Bfsmtx\\bfsm_a.mdx"
      end
      EffectcreateArgs({
        effect = zf2,
        x = dx,
        y = dy,
        size = 1.25,
        height = 700,
        zxz = jd + 65,
        animespeed = 1.5
      })
    end)
    local dis = GetRandomReal(0, 400)
    local mz = false
    for i = 1, 2 do
      x, y = u:getxy()
      local x1, y1 = PolarXY(x, y, dis + i * 250, jd)
      local jd1 = AngleXY(x, y, x1, y1)
      local jl = DistanceXY(x, y, x1, y1)
      local z1 = FsAngle(x, y, 1000, x1, y1, 0)
      local dx, dy = x, y
      ac.wait(200, function()
        local zf = ""
        zf = u:getdata("波风水门-飞镖模型2")
        local tx = EffectcreateArgs({
          effect = zf,
          x = x,
          y = y,
          time = -1,
          size = 1.75,
          height = 1000,
          zxz = jd1,
          yxz = z1,
          animespeed = 1
        })
        local cs3 = 0
        ac.loop(10, function(t1)
          cs3 = cs3 + 1
          dx, dy = PolarXY(dx, dy, jl / 10, jd1)
          japi.EXSetEffectXY(tx, dx, dy)
          japi.EXSetEffectZ(tx, 1000 - 100.0 * cs3)
          if 10 <= cs3 then
            u:shockcamera(10, 0.1)
            DestroyEffectLua(tx)
            for _, xq in ac.selector():in_rangexy(dx, dy, 135):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              bfsmdamage({
                u = u,
                xq = xq,
                damage = 1,
                bufftime = 0.5
              })
              if not mz then
                mz = true
                mzhf(u, xq, skillstr)
              end
            end
            local loc = Location(dx, dy)
            local heiadd = GetLocationZ(loc)
            RemoveLocation(loc)
            local fls = Effectcreate(u:getdata("波风水门-飞镖模型1"), dx, dy, -1, 1.75, 50 + heiadd, jd)
            flsshow(fls)
            SetData(fls, "飞雷神苦无-消失时间", returntime(u, 10))
            table.insert(zu, fls)
            t1:remove()
          end
        end)
      end)
    end
  end,
  E = function(u)
    local skillstr = "E"
    u:setdata("波风水门-DE中断标记")
    local zu = u:getdata("波风水门-飞雷神苦无组")
    local zu2 = u:getdata("波风水门-飞雷神标记组")
    local group2 = u:getdata("波风水门-飞雷神苦无火把组")
    local ux = u:getdata("波风水门-X")
    local uy = u:getdata("波风水门-Y")
    local dx, dy = u:getxy()
    local tg
    local ndis = 100
    ForGroupLuaNew(zu2, function(xq)
      local x, y = xq:getxy()
      local dis = DistanceXY(x, y, ux, uy)
      if dis < ndis then
        ndis = dis
        tg = xq
        dx, dy = x, y
      end
    end)
    local x, y = u:getxy()
    local jd = AngleXY(x, y, dx, dy)
    local mz2 = false
    if tg ~= nil then
      if u:hasdata("波风水门皮肤") then
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
          x = x,
          y = y,
          time = 0.5,
          size = 1,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsmpf_fls_shunyi1.mdx",
          x = x,
          y = y,
          size = 2,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
      else
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
          x = x,
          y = y,
          size = 3,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
          x = x,
          y = y,
          size = 1,
          height = 250,
          zxz = jd,
          animespeed = 1
        })
      end
      if u:hasdata("青水皮肤-茉子") then
        local yxz = {
          Mozi_Ikuzo_01,
          Mozi_Ikuzo_02,
          Mozi_Ikuzo_03
        }
        if u:hasdata("茉子-兽化状态") then
          yxz = {
            Mozi_Wang_01,
            Mozi_Wang_02,
            Mozi_Wang_03
          }
        end
        u:playseensound(yxz[GetRandomInt(1, #yxz)])
      else
        u:playseensound(Bfsm_fls3)
      end
      local x1, y1 = tg:getxy()
      local jd = AngleXY(x, y, x1, y1)
      local pdjl = 750
      local cs = 0
      local max = 10
      if u:hasdata("波风水门天赋-多少了解金色闪光的由来了吧") then
        pdjl = 1000
        max = 999
      end
      ForGroupLuaNew(zu2, function(xq)
        local x2, y2 = xq:getxy()
        local dis = DistanceXY(x2, y2, x1, y1)
        if dis <= pdjl and cs < max then
          cs = cs + 1
          xq:groupremove(zu2)
          xq:deldata("飞雷神标记-消失时间")
          DestroyEffectLua(xq:getdata("飞雷神标记-特效"))
          xq:deldata("飞雷神标记-特效")
        end
      end)
      if u:hasdata("波风水门天赋-我用双手成就梦想") then
        ForGroupLuaNew(group2, function(xq)
          local x2, y2 = xq:getxy()
          local dis = DistanceXY(x2, y2, x1, y1)
          if dis <= pdjl and cs < max then
            cs = cs + 1
            flashflstime(u, xq)
          end
        end)
      end
      for i = #zu, 1, -1 do
        local value = zu[i]
        local x2, y2 = GetEffectXY(value)
        local dis = DistanceXY(x2, y2, x1, y1)
        if pdjl >= dis and cs < max then
          cs = cs + 1
          flashflstime(u, value)
        end
      end
      flashfls(u)
      if cs ~= 0 then
        local time = 0.1 * cs
        local zf1 = ""
        if u:hasdata("波风水门皮肤") then
          zf1 = "Bfsmtx\\bfsmpf_tuowei1.mdx"
        else
          zf1 = "Bfsmtx\\bfsm_fls_tuowei3change.mdx"
        end
        u:buffset(u.handle, time, "暂停")
        u:buffset(u.handle, time + 0.2, "无敌")
        u:effectadd(zf1, "hand left", 0.3 + 0.1 * cs)
        u:effectadd(zf1, "hand right", 0.3 + 0.1 * cs)
        local ax, ay = x1, y1
        ac.loop(100, function(t)
          flscf(u)
          cs = cs - 1
          if u:hasdata("青水皮肤-茉子") then
            u:animeact(3)
            u:animespeed(2)
            ac.wait(500, function()
              u:animespeed(1)
            end)
          else
            u:animeact(19)
            u:animespeed(1)
          end
          x, y = u:getxy()
          x1, y1 = tg:getxy()
          local dis = DistanceXY(x, y, x1, y1)
          if 4000 <= dis then
            x1, y1 = ax, ay
          end
          local dx, dy = PolarXY(x1, y1, 400, GetRandomAngle())
          local dx2, dy2 = PolarXY(x1, y1, GetRandomReal(1000, 2000), jd + GetRandomAngle())
          local jd = AngleXY(x, y, x1, y1)
          local jd2 = AngleXY(x1, y1, dx, dy)
          local jl = DistanceXY(x1, y1, dx, dy)
          local zf = ""
          if u:hasdata("波风水门皮肤") then
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
              x = dx,
              y = dy,
              time = 0.5,
              size = 1,
              height = 0,
              zxz = jd,
              animespeed = 1
            })
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsmpf_fls_shunyi1.mdx",
              x = dx,
              y = dy,
              size = 2,
              height = 0,
              zxz = jd,
              animespeed = 1
            })
            zf = "Bfsmtx\\bfsmpf_tuowei1.mdx"
          else
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
              x = dx,
              y = dy,
              size = 3,
              height = 0,
              zxz = jd,
              animespeed = 1
            })
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
              x = dx,
              y = dy,
              size = 1,
              height = 250,
              zxz = jd,
              animespeed = 1
            })
            zf = "Bfsmtx\\bfsm_fls_tuowei3.mdx"
          end
          local tx1 = EffectcreateArgs({
            effect = zf,
            x = x1,
            y = y1,
            time = -1,
            size = 3,
            height = 100,
            zxz = jd,
            animespeed = 3
          })
          if type(japi.EXSetEffectFogVisible) == "function" then
            japi.EXSetEffectFogVisible(tx1, true)
          end
          if type(japi.EXSetEffectMaskVisible) == "function" then
            japi.EXSetEffectMaskVisible(tx1, true)
          end
          Bezier(tx1, x, y, dx, dy, dx2, dy2, jd, jl, 20)
          u:setxy(dx, dy)
          u:setface(jd2)
          unitmove({
            unit = u.handle,
            time = 0.1,
            distance = 800,
            angle = u:getface(),
            isfly = true
          })
          local sj = (cs - 1) % 3 + 1
          if sj == 1 then
            PlayGlobalSound(Bfsm_fls_shunyi2)
          elseif sj == 2 then
            PlayGlobalSound(Bfsm_fls_shunyi3)
          else
            PlayGlobalSound(Bfsm_fls_shunyi4)
          end
          local mz = false
          for _, xq in ac.selector():in_rangexy(x1, y1, pdjl - 200):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            if not mz then
              mz = true
              xq:playseensound(bfsm_hit_01)
            end
            if not mz2 then
              mz2 = true
              mzhf(u, xq, skillstr)
            end
            bfsmdamage({
              u = u,
              xq = xq,
              damage = 2,
              bufftime = 0.5
            })
          end
          if cs <= 0 then
            IssueImmediateOrder(u.handle, "stop")
            u:setdata("位移点X", dx)
            u:setdata("位移点Y", dy)
            if u:hasdata("青水皮肤-茉子") then
              local yxz = {
                Mozi_osoyi_01,
                Mozi_osoyi_02,
                Mozi_osoyi_03
              }
              if u:hasdata("茉子-兽化状态") then
                yxz = {
                  Mozi_Wang_01,
                  Mozi_Wang_02,
                  Mozi_Wang_03
                }
              end
              u:playseensound(yxz[GetRandomInt(1, #yxz)])
            else
              u:playseensound(Bfsm_fls2)
            end
            local zf1 = ""
            if u:hasdata("波风水门皮肤") then
              zf1 = "Bfsmtx\\bfsmpf_tuowei1.mdx"
            else
              zf1 = "Bfsmtx\\bfsm_fls_tuowei3.mdx"
            end
            t:remove()
          end
        end)
      end
      return
    end
    if 0 < #zu or 0 < Group_Counts(group2) then
      flscf(u)
      local ax = u:getdata("波风水门-X")
      local ay = u:getdata("波风水门-Y")
      local fb, x1, y1 = pick_nearest_kunai(u, ax, ay, 10000)
      if fb ~= 0 or type(fb) == "table" then
        if u:hasdata("波风水门天赋-看来已经准备好了") then
          local dis = DistanceXY(ux, uy, x, y)
          local dis2 = DistanceXY(x1, y1, ax, ay)
          if 300 <= dis and dis2 <= 200 then
            local loc = Location(x, y)
            local heiadd = GetLocationZ(loc)
            RemoveLocation(loc)
            local fls = Effectcreate(u:getdata("波风水门-飞镖模型1"), x, y, -1, 1.75, 50 + heiadd)
            flsshow(fls)
            SetData(fls, "飞雷神苦无-消失时间", 8)
            table.insert(zu, fls)
          end
        end
        quxian(u, fb, x1, y1, false)
      end
      return
    end
    zgskill.W(u)
  end,
  DE = function(u)
    if u:hasdata("波风水门-DE发动中") then
      return
    end
    local skillstr = "DE"
    local group = u:getdata("波风水门-飞雷神苦无组")
    local group2 = u:getdata("波风水门-飞雷神苦无火把组")
    local visited = {}
    u:deldata("波风水门-DE中断标记")
    u:setdata("波风水门-DE发动中")
    
    local function pick_from_array(arr)
      for i = #arr, 1, -1 do
        local v = arr[i]
        if v and not visited[v] then
          return v, "array"
        end
      end
      return nil
    end
    
    local function pick_from_native_group(g)
      if Group_Counts(g) == 0 then
        return nil
      end
      local found
      ForGroupLuaNew(g, function(xq)
        if not found and xq and not visited[xq] then
          found = xq
        end
      end)
      return found, "native"
    end
    
    local function pick_next_target()
      local v, kind = pick_from_array(group)
      if v then
        return v, kind
      end
      local u2, kind2 = pick_from_native_group(group2)
      if u2 then
        return u2, kind2
      end
      return nil
    end
    
    ac.loop(100, function(timer)
      if u:hasdata("波风水门-DE中断标记") then
        u:deldata("波风水门-DE发动中")
        timer:remove()
        return
      end
      local target, from_kind = pick_next_target()
      if not target then
        u:deldata("波风水门-DE发动中")
        timer:remove()
        return
      end
      u:buffset(u.handle, 0.11, "无敌")
      visited[target] = true
      flscf(u)
      if from_kind == "array" then
        local x1, y1 = GetEffectXY(target)
        quxian(u, target, x1, y1)
      else
        local x1, y1 = target:getxy()
        quxian(u, target, x1, y1)
      end
    end)
  end,
  S = function(u)
    local skillstr = "S"
    local zu = u:getdata("波风水门-飞雷神苦无组")
    local zu2 = u:getdata("波风水门-飞雷神标记组")
    local x, y = u:getxy()
    local x2 = u:getdata("波风水门-X")
    local y2 = u:getdata("波风水门-Y")
    local tg
    u:setdata("波风水门-DE中断标记")
    u:deldata("波风水门-瞬影残中断")
    tg, x2, y2 = pick_nearest_kunai(u, x2, y2, 100)
    local dis = DistanceXY(x, y, x2, y2)
    local angle = AngleXY(x, y, x2, y2)
    if tg ~= 0 or type(tg) == "table" then
      syc(u, x, y, x2, y2, angle, tg)
      return
    end
    local mjl = 900
    if dis >= mjl then
      x2, y2 = PolarXY(x, y, mjl, angle)
      dis = mjl
    end
    u:buffset(u.handle, 0.1, "绝对闪避")
    u:playsound(Sound_Bfsm_AFA1)
    flscf(u)
    ac.wait(1, function()
      if u:hasdata("波风水门天赋-看来已经准备好了") then
        local loc = Location(x, y)
        local heiadd = GetLocationZ(loc)
        RemoveLocation(loc)
        local fls = Effectcreate(u:getdata("波风水门-飞镖模型1"), x, y, -1, 1.75, 50 + heiadd, angle)
        flsshow(fls)
        SetData(fls, "飞雷神苦无-消失时间", 8)
        table.insert(zu, fls)
      end
      quxian(u, 0, x2, y2, true)
      local zf1 = ""
      zf1 = u:getdata("波风水门-飞镖模型2")
      local tx = EffectcreateArgs({
        effect = zf1,
        x = x,
        y = y,
        time = -1,
        size = 1.75,
        height = 50,
        zxz = angle,
        animespeed = 1
      })
      if type(japi.EXSetEffectFogVisible) == "function" then
        japi.EXSetEffectFogVisible(tx, true)
      end
      if type(japi.EXSetEffectMaskVisible) == "function" then
        japi.EXSetEffectMaskVisible(tx, true)
      end
      local dx, dy = x, y
      local cs = 0
      local v = dis / 10
      local b = false
      ac.loop(10, function(t)
        cs = cs + 1
        dx, dy = PolarXY(dx, dy, v, angle)
        japi.EXSetEffectXY(tx, dx, dy)
        if 10 <= cs then
          DestroyEffectLua(tx)
          t:remove()
        end
      end)
    end)
  end,
  SS = function(u)
    local x, y = u:getxy()
    local x2 = u:getdata("波风水门-X")
    local y2 = u:getdata("波风水门-Y")
    local angle = AngleXY(x, y, x2, y2)
    syc(u, x, y, x2, y2, angle)
  end,
  A = function(u)
    local skillstr = "A"
    local zu = u:getdata("波风水门-飞雷神苦无组")
    local zu2 = u:getdata("波风水门-飞雷神标记组")
    local x, y = u:getxy()
    local x1 = u:getdata("波风水门-X")
    local y1 = u:getdata("波风水门-Y")
    local jd = AngleXY(x, y, x1, y1)
    local dis = DistanceXY(x, y, x1, y1)
    local max = 1800
    local zt = false
    if u:hasdata("波风水门天赋-无论发生什么我都会保护你") then
      zt = true
      max = 2500
      ac.wait(1, function()
        u:setskillcd("A0KJ", 0.5)
      end)
    end
    if dis >= max then
      dis = max
    end
    ac.wait(1, function()
      if u:hasdata("青水皮肤-茉子") then
        u:animeact(2)
        u:animespeed(2)
        ac.wait(500, function()
          u:animespeed(1)
        end)
      else
        local zud = {
          13,
          33,
          34,
          47
        }
        u:animeact(zud[GetRandomInt(1, #zud)])
        u:animespeed(2)
      end
    end)
    local yxz = {
      fls_A_01,
      fls_a_02,
      fls_a_03,
      fls_a_04
    }
    if u:hasdata("青水皮肤-茉子") then
      yxz = {
        Mozi_fls_01,
        Mozi_fls_02,
        Mozi_fls_03
      }
      if u:hasdata("茉子-兽化状态") then
        yxz = {
          Mozi_Wang_01,
          Mozi_Wang_02,
          Mozi_Wang_03
        }
      end
    end
    u:playseensound(yxz[GetRandomInt(1, #yxz)])
    u:playsound(Sound_Bfsm_AFA1)
    local mz = false
    ac.wait(1, function()
      local zf1 = ""
      zf1 = u:getdata("波风水门-飞镖模型2")
      local tx = EffectcreateArgs({
        effect = zf1,
        x = x,
        y = y,
        time = -1,
        size = 1.75,
        height = 50,
        zxz = jd,
        animespeed = 1
      })
      if type(japi.EXSetEffectFogVisible) == "function" then
        japi.EXSetEffectFogVisible(tx, true)
      end
      if type(japi.EXSetEffectMaskVisible) == "function" then
        japi.EXSetEffectMaskVisible(tx, true)
      end
      local dx, dy = u:getxy()
      local g = CreateGroupLua()
      local cs = 0
      local v = dis / 15
      local bcount = 1
      if zt then
        bcount = 3
      end
      SetData(tx, "飞雷神苦无-消失时间", 3)
      table.insert(zu, tx)
      ac.loop(10, function(t)
        if GetData(tx, "飞雷神苦无-消失时间") <= 0 then
          t:remove()
          return
        end
        cs = cs + 1
        local ax, ay = dx, dy
        dx, dy = PolarXY(dx, dy, v, jd)
        if not IsXYInLimRECT(dx, dy) then
          dx, dy = ax, ay
        end
        japi.EXSetEffectXY(tx, dx, dy)
        for _, xq in ac.selector():in_rangexy(dx, dy, 110):is_enemy(u.handle):isnotingroup(g):ipairs() do
          xq = getunit(xq)
          xq:groupadd(g)
          bfsmdamage({
            u = u,
            xq = xq,
            damage = 1,
            bufftime = 0.5
          })
          if zt then
            xq:buffset(u.handle, 0.4, "暂停")
          end
          if not mz then
            mz = true
            mzhf(u, xq, skillstr)
          end
          if 0 < bcount then
            bcount = bcount - 1
            xq:groupadd(zu2)
            if not xq:hasdata("飞雷神标记-特效") then
              local ntx = xq:effectadd(u:getdata("波风水门-飞镖模型1"), "overhead", -1)
              xq:setdata("飞雷神标记-特效", ntx)
            end
            local time = returntime(u, 10)
            xq:setdata("飞雷神标记-消失时间", time)
            xq:buffset(u.handle, time, "破坏-伤害免疫")
          end
        end
        if 15 <= cs then
          SetData(tx, "飞雷神苦无-消失时间", 0)
          flashfls(u)
          local loc = Location(dx, dy)
          local heiadd = GetLocationZ(loc)
          RemoveLocation(loc)
          local fls = Effectcreate(u:getdata("波风水门-飞镖模型1"), dx, dy, -1, 1.75, 50 + heiadd, jd)
          flsshow(fls)
          SetData(fls, "飞雷神苦无-消失时间", returntime(u, 30))
          table.insert(zu, fls)
          t:remove()
        end
      end)
    end)
  end,
  R = function(u)
    local skillstr = "R"
    local x, y = u:getxy()
    local x1, y1 = u:getxy()
    local ax = u:getdata("波风水门-X")
    local ay = u:getdata("波风水门-Y")
    local jd = u:getface()
    local mz = false
    local tg, dx, dy = pick_nearest_kunai(u, ax, ay, 100)
    local bs = 1
    if u:hasdata("波风水门天赋-该做个了结了") then
      bs = 2
    end
    if u:hasdata("波风水门-专属传奇强化") then
      bs = bs + 1
    end
    if tg ~= 0 or type(tg) == "table" then
      flscf(u)
      flashflstime(u, tg)
      u:deldata("波风水门-弹反限制")
      local zf = ""
      if u:hasdata("波风水门皮肤") then
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
          x = x,
          y = y,
          time = 0.5,
          size = 1,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsmpf_fls_shunyi1.mdx",
          x = x,
          y = y,
          size = 2,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
        zf = "Bfsmtx\\bfsmpf_tuowei1.mdx"
      else
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
          x = x,
          y = y,
          size = 1.5,
          height = 25,
          zxz = jd,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
          x = x,
          y = y,
          size = 0.75,
          height = 175,
          zxz = jd,
          animespeed = 1
        })
        zf = "Bfsmtx\\bfsm_fls_tuowei3.mdx"
      end
      u:setxy(dx, dy)
      x1, y1 = dx, dy
      u:buffset(u.handle, 0.4, "暂停")
      u:buffset(u.handle, 0.5, "无敌")
      if u:hasdata("波风水门天赋-我来晚了么") then
        u:setdata("波风水门-R衔接时间", 0.9)
      end
      ac.wait(1, function()
        if u:hasdata("青水皮肤-茉子") then
          u:animeact(4)
        else
          u:animeact(46)
          u:animespeed(1.4)
        end
      end)
      u:setflyheight(500)
      u:effectadd("Bfsmtx\\bfsm_luoxuanwan4.mdx", "right hend", 1)
      u:playseensound(Bfsm_fls_shunyi2)
      u:playseensound(Bfsm_Lxw)
      if u:hasdata("青水皮肤-茉子") then
        local snd = Mozi_lwx_r_01
        if u:hasdata("茉子-兽化状态") then
          local yxz = {
            Mozi_Wang_01,
            Mozi_Wang_02,
            Mozi_Wang_03
          }
          snd = yxz[GetRandomInt(1, #yxz)]
        end
        u:playseensound(snd)
      else
        u:playseensound(Bfsm_lxw2)
      end
      local h = 750
      if u:hasdata("波风水门皮肤") then
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
          x = x1,
          y = y1,
          size = 1,
          height = h,
          zxz = GetRandomAngle(),
          animespeed = 1.3
        })
      else
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
          x = x1,
          y = y1,
          size = 0.5,
          height = h,
          zxz = GetRandomAngle(),
          animespeed = 1.3
        })
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
          x = x1,
          y = y1,
          size = 1.5,
          height = h - 120,
          zxz = jd,
          animespeed = 1
        })
      end
      ac.wait(200, function()
        local cs = 0
        local xtx = "Bfsmtx\\bfsm_xiazha1.mdx"
        if u:hasdata("青水皮肤-茉子") then
          xtx = "Bfsmtx\\bfsm_xiazha1fs.mdx"
        end
        ac.loop(100, function(t)
          cs = cs + 1
          EffectcreateArgs({
            effect = xtx,
            x = x1,
            y = y1,
            size = 1,
            height = -300,
            zxz = GetRandomAngle(),
            animespeed = 1
          })
          for _, xq in ac.selector():in_rangexy(x1, y1, 200 * cs):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            bfsmdamage({
              u = u,
              xq = xq,
              damage = 0.25 * bs,
              bufftime = 0.25 * bs,
              isvest = true,
              type = "灵力"
            })
            if not mz then
              mz = true
              mzhf(u, xq, skillstr)
            end
          end
          if 5 <= cs then
            t:remove()
          end
        end)
        local zf1 = ""
        local zf2 = ""
        if u:hasdata("波风水门皮肤") then
          zf1 = "Bfsmtx\\bfsmpf_luoxuanwan1.mdx"
          zf2 = "Bfsmtx\\bfsmpf_baozha2.mdx"
          local cs1 = 0
          ac.loop(100, function(t1)
            cs1 = cs1 + 1
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsmpf_luoxuanwan4.mdx",
              x = x1,
              y = y1,
              size = cs1 * 0.5,
              height = 200,
              zxz = jd,
              animespeed = 5
            })
            if 5 <= cs1 then
              t1:remove()
            end
          end)
        else
          zf1 = "Bfsmtx\\bfsm_luoxuanwan4.mdx"
          zf2 = "Bfsmtx\\bfsm_xiazha4.mdx"
        end
        local tx = EffectcreateArgs({
          effect = zf1,
          x = x1,
          y = y1,
          time = 0.5,
          size = 0.5,
          height = 400,
          zxz = jd,
          animespeed = GetRandomReal(0.5, 3)
        })
        local tx1 = EffectcreateArgs({
          effect = zf2,
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
          japi.EXSetEffectSize(tx, cs1 * 0.6)
          japi.EXSetEffectZ(tx, 100 + cs1 * 2)
          japi.EXSetEffectSize(tx1, cs1 * 0.02)
          if 25 <= cs1 then
            t1:remove()
          end
        end)
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_longjuan1.mdx",
          x = x1,
          y = y1,
          time = 0.5,
          size = 0.5,
          height = -800,
          zxz = GetRandomAngle(),
          animespeed = 5
        })
      end)
      ac.wait(400, function()
        u:shockcamera(50, 0.1)
        ac.wait(100, function()
          u:setflyheight(0)
          if u:hasdata("青水皮肤-茉子") then
            u:animeact(5)
            u:animespeed(2)
            unitmove({
              unit = u.handle,
              time = 0.1,
              distance = 25,
              angle = 180 + u:getface()
            })
            ac.wait(200, function()
              u:animespeed(1)
            end)
          else
            u:animeact(51)
            u:animespeed(1)
          end
        end)
        local zf = ""
        local size = 2
        local sd = 2
        if u:hasdata("波风水门皮肤") then
          zf = "Bfsmtx\\bfsmpf_baozha2.mdx"
          size = 1
          sd = 2
          EffectcreateArgs({
            effect = "Bfsmtx\\bfsmpf_baozha4_C.mdx",
            x = x1,
            y = y1,
            size = 0.75,
            height = 0,
            zxz = jd,
            animespeed = 15
          })
        else
          zf = "Bfsmtx\\bfsm_xiazha2.mdx"
        end
        EffectcreateArgs({
          effect = zf,
          x = x1,
          y = y1,
          size = size,
          height = 0,
          zxz = GetRandomAngle(),
          animespeed = sd
        })
        for _, xq in ac.selector():in_rangexy(x1, y1, 650):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          bfsmdamage({
            u = u,
            xq = xq,
            damage = 1.5 * bs,
            bufftime = 0.5 * bs,
            type = "灵力",
            bufftype = "眩晕"
          })
          if not mz then
            mz = true
            mzhf(u, xq, skillstr)
          end
        end
      end)
      return
    end
    u:effectadd("Bfsmtx\\bfsm_luoxuanwan4.mdx", "right hend", 1)
    u:playseensound(Bfsm_Lxw)
    if u:hasdata("青水皮肤-茉子") then
      local yxz = {
        Mozi_lxw_02,
        Mozi_lxw_03
      }
      if u:hasdata("茉子-兽化状态") then
        yxz = {
          Mozi_Wang_01,
          Mozi_Wang_02,
          Mozi_Wang_03
        }
      end
      u:playseensound(yxz[GetRandomInt(1, #yxz)])
    else
      u:playseensound(Bfsm_lxw1)
    end
    u:buffset(u.handle, 0.3, "暂停")
    u:buffset(u.handle, 0.4, "无敌")
    u:setdata("波风水门-R衔接时间", 0.8)
    local dis = u:getdata("波风水门-R位移距离")
    unitmove({
      unit = u.handle,
      time = 0.2,
      distance = dis - 200 - 150,
      angle = jd,
      isfly = true
    })
    unitmove({
      unit = u.handle,
      time = 0.4,
      distance = 150,
      angle = jd,
      isfly = false
    })
    ac.wait(1, function()
      if u:hasdata("青水皮肤-茉子") then
        u:animeact(8)
      else
        u:animeact(59)
        u:animespeed(1.4)
      end
    end)
    ac.wait(200, function()
      x, y = u:getxy()
      local cs = 0
      local xtx = "Bfsmtx\\bfsm_xiazha1.mdx"
      if u:hasdata("青水皮肤-茉子") then
        xtx = "Bfsmtx\\bfsm_xiazha1fs.mdx"
      end
      ac.loop(100, function(t)
        cs = cs + 1
        local dx, dy = PolarXY(x, y, 150, jd)
        if cs <= 3 then
          local dx1, dy1 = PolarXY(x, y, 300, jd)
          EffectcreateArgs({
            effect = xtx,
            x = dx1,
            y = dy1,
            size = 0.5,
            height = 100,
            zxz = jd,
            yxz = -90,
            animespeed = 1
          })
        end
        for _, xq in ac.selector():in_rangexy(dx, dy, 350):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          local dx1, dy1 = xq:getxy()
          local jd1 = AngleXY(dx1, dy1, dx, dy)
          bfsmdamage({
            u = u,
            xq = xq,
            damage = 0.25 * bs,
            bufftime = 0.25 * bs,
            isvest = true,
            type = "灵力"
          })
          if not mz then
            mz = true
            mzhf(u, xq, skillstr)
          end
        end
        if 5 <= cs then
          t:remove()
        end
      end)
      local dx, dy = PolarXY(x, y, 300, jd)
      local zf = ""
      local zf1 = ""
      if u:hasdata("波风水门皮肤") then
        zf = "Bfsmtx\\bfsmpf_luoxuanwan1.mdx"
        zf1 = "Bfsmtx\\bfsmpf_baozha2.mdx"
        local cs1 = 0
        ac.loop(100, function(t1)
          cs1 = cs1 + 1
          EffectcreateArgs({
            effect = "Bfsmtx\\bfsmpf_luoxuanwan4.mdx",
            x = dx,
            y = dy,
            size = cs1 * 0.5,
            height = 200,
            zxz = jd,
            animespeed = 5
          })
          if 5 <= cs1 then
            t1:remove()
          end
        end)
      else
        zf = "Bfsmtx\\bfsm_luoxuanwan4.mdx"
        zf1 = "Bfsmtx\\bfsm_xiazha4.mdx"
      end
      local tx = EffectcreateArgs({
        effect = zf,
        x = dx,
        y = dy,
        time = 0.5,
        size = 1,
        height = 100,
        zxz = jd,
        animespeed = GetRandomReal(0.5, 3)
      })
      local cs1 = 0
      ac.loop(10, function(t1)
        cs1 = cs1 + 1
        japi.EXSetEffectSize(tx, cs1 * 0.35)
        if 50 <= cs1 then
          t1:remove()
        end
      end)
    end)
    ac.wait(400, function()
      u:shockcamera(50, 0.1)
      local dx, dy = PolarXY(x, y, 300, jd)
      local zf = ""
      local size = 1.25
      local sd = 2
      if u:hasdata("波风水门皮肤") then
        zf = "Bfsmtx\\bfsmpf_baozha2.mdx"
        size = 0.75
        sd = 2
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsmpf_baozha4_C.mdx",
          x = dx,
          y = dy,
          size = 0.5,
          height = 0,
          zxz = jd,
          animespeed = 15
        })
      else
        zf = "Bfsmtx\\bfsm_xiazha2.mdx"
      end
      EffectcreateArgs({
        effect = zf,
        x = dx,
        y = dy,
        size = size,
        height = 0,
        zxz = jd,
        animespeed = sd
      })
      for _, xq in ac.selector():in_rangexy(dx, dy, 400):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        bfsmdamage({
          u = u,
          xq = xq,
          damage = 1.5 * bs,
          bufftime = 0.5 * bs,
          type = "灵力",
          bufftype = "眩晕"
        })
        if not mz then
          mz = true
          mzhf(u, xq, skillstr)
        end
      end
    end)
  end,
  DR = function(u)
    local skillstr = "DR"
    local x, y = u:getxy()
    local x1, y1 = u:getxy()
    local ax = u:getdata("波风水门-X")
    local ay = u:getdata("波风水门-Y")
    local jd = u:getface()
    local tg, dx, dy = pick_nearest_kunai(u, ax, ay, 100)
    local mz = false
    local bosshf = false
    local bs = 1
    if u:hasdata("波风水门天赋-该做个了结了") then
      bs = 2
    end
    if u:hasdata("波风水门-专属传奇强化") then
      bs = bs + 1
    end
    if tg ~= 0 or type(tg) == "table" or 0 < u:getdata("波风水门-弹反连携强化效果2") then
      flscf(u)
      if 0 < u:getdata("波风水门-弹反连携强化效果2") then
        local tg2 = u:getdata("波风水门-飞雷神弹反标记单位")
        dx, dy = tg2:getxy()
        u:buffset(u.handle, 1.0, "绝对闪避")
        u:setdata("波风水门-弹反连携强化效果2", 0)
      else
        flashflstime(u, tg)
        u:deldata("波风水门-弹反限制")
      end
      local zf = ""
      if u:hasdata("波风水门皮肤") then
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
          x = x,
          y = y,
          time = 0.5,
          size = 1,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsmpf_fls_shunyi1.mdx",
          x = x,
          y = y,
          size = 2,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
        zf = "Bfsmtx\\bfsmpf_tuowei1.mdx"
      else
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
          x = x,
          y = y,
          size = 1.5,
          height = 25,
          zxz = jd,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
          x = x,
          y = y,
          size = 0.75,
          height = 175,
          zxz = jd,
          animespeed = 1
        })
        zf = "Bfsmtx\\bfsm_fls_tuowei3.mdx"
      end
      x1, y1 = dx, dy
      ac.wait(1, function()
        if u:hasdata("青水皮肤-茉子") then
          u:animeact(4)
          u:animespeed(0.7)
        else
          u:animeact(46)
          u:animespeed(0.7)
        end
      end)
      u:setxy(x1, y1)
      u:setflyheight(800)
      u:buffset(u.handle, 0.9, "暂停")
      u:buffset(u.handle, 1.0, "无敌")
      if u:hasdata("波风水门天赋-我来晚了么") then
        u:setdata("波风水门-R衔接时间", 1.4)
      end
      u:effectadd("Bfsmtx\\bfsm_luoxuanwan4.mdx", "right hend", 1)
      u:playseensound(Bfsm_fls_shunyi2)
      u:playseensound(Bfsm_Lxw)
      if u:hasdata("青水皮肤-茉子") then
        local snd = Mozi_lwx_r_01
        if u:hasdata("茉子-兽化状态") then
          local yxz = {
            Mozi_Wang_01,
            Mozi_Wang_02,
            Mozi_Wang_03
          }
          snd = yxz[GetRandomInt(1, #yxz)]
        end
        u:playseensound(snd)
      else
        u:playseensound(Bfsm_lxw2)
      end
      if u:hasdata("波风水门皮肤") then
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
          x = x1,
          y = y1,
          size = 1,
          height = 1000,
          zxz = GetRandomAngle(),
          animespeed = 1.3
        })
      else
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
          x = x1,
          y = y1,
          size = 1,
          height = 1100,
          zxz = GetRandomAngle(),
          animespeed = 1.3
        })
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
          x = x1,
          y = y1,
          size = 3,
          height = 850,
          zxz = jd,
          animespeed = 1
        })
      end
      ac.wait(500, function()
        u:animespeed(0)
        local cs = 0
        local xtx = "Bfsmtx\\bfsm_xiazha1.mdx"
        if u:hasdata("青水皮肤-茉子") then
          xtx = "Bfsmtx\\bfsm_xiazha1fs.mdx"
        end
        ac.loop(100, function(t)
          cs = cs + 1
          EffectcreateArgs({
            effect = xtx,
            x = x1,
            y = y1,
            size = 5,
            height = -300,
            zxz = GetRandomAngle(),
            animespeed = 1
          })
          for _, xq in ac.selector():in_rangexy(x1, y1, 200 * cs):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            local dx1, dy1 = xq:getxy()
            local jd1 = AngleXY(dx1, dy1, x1, y1)
            unitmove({
              unit = xq.handle,
              time = 0.2,
              distance = 100,
              angle = jd1,
              isfly = true
            })
            bfsmdamage({
              u = u,
              xq = xq,
              damage = 0.5 * bs,
              bufftime = 0.25 * bs,
              isvest = true,
              type = "灵力"
            })
            if not mz then
              mz = true
              mzhf(u, xq, skillstr)
              if xq:isboss() then
                bosshf = true
              end
            elseif not bosshf and xq:isboss() then
              bosshf = true
              mzhf(u, xq, skillstr)
            end
          end
          if 5 <= cs then
            t:remove()
          end
        end)
        local zf1 = ""
        local zf2 = ""
        if u:hasdata("波风水门皮肤") then
          zf1 = "Bfsmtx\\Mz_New_01.mdx"
          zf2 = "Bfsmtx\\bfsmpf_baozha2.mdx"
          local cs1 = 0
          ac.loop(100, function(t1)
            cs1 = cs1 + 1
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsmpf_luoxuanwan4.mdx",
              x = x,
              y = y,
              size = cs1 * 0.75,
              height = 200,
              zxz = jd,
              animespeed = 5
            })
            if 5 <= cs1 then
              t1:remove()
            end
          end)
        else
          zf1 = "Bfsmtx\\bfsm_luoxuanwan4.mdx"
          zf2 = "Bfsmtx\\bfsm_xiazha4.mdx"
        end
        local tx = EffectcreateArgs({
          effect = zf1,
          x = x1,
          y = y1,
          time = 0.5,
          size = 1,
          height = 400,
          zxz = jd,
          animespeed = GetRandomReal(0.5, 3)
        })
        local tx1 = EffectcreateArgs({
          effect = zf2,
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
          if u:hasdata("青水皮肤-茉子") then
            japi.EXSetEffectSize(tx, 0.75 + cs1 * 0.05)
            japi.EXSetEffectZ(tx, 25 + cs1 * 8)
            japi.EXSetEffectSize(tx1, cs1 * 0.025)
          else
            japi.EXSetEffectSize(tx, cs1 * 0.5)
            japi.EXSetEffectZ(tx, 100 + cs1 * 5)
            japi.EXSetEffectSize(tx1, cs1 * 0.025)
          end
          if 50 <= cs1 then
            t1:remove()
          end
        end)
        local si
        if u:hasdata("青水皮肤-茉子") then
          si = GetRandomReal(2, 5)
        else
          si = GetRandomReal(1, 10)
        end
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_longjuan1.mdx",
          x = x1,
          y = y1,
          time = 0.5,
          size = si,
          height = -800,
          zxz = GetRandomAngle(),
          animespeed = 5
        })
      end)
      ac.wait(1000, function()
        u:animespeed(1)
        u:shockcamera(100, 0.2)
        ac.wait(200, function()
          u:setflyheight(0)
          if u:hasdata("青水皮肤-茉子") then
            u:animeact(5)
            u:animespeed(2)
            unitmove({
              unit = u.handle,
              time = 0.1,
              distance = 25,
              angle = 180 + u:getface()
            })
            ac.wait(200, function()
              u:animespeed(1)
            end)
          else
            u:animeact(51)
            u:animespeed(1)
          end
        end)
        local zf = ""
        local size = 3.5
        local sd = 2
        if u:hasdata("波风水门皮肤") then
          zf = "Bfsmtx\\bfsmpf_baozha2.mdx"
          size = 1.75
          sd = 2
          EffectcreateArgs({
            effect = "Bfsmtx\\bfsmpf_baozha4_C.mdx",
            x = x1,
            y = y1,
            size = 1.5,
            height = 0,
            zxz = jd,
            animespeed = 15
          })
        else
          zf = "Bfsmtx\\bfsm_xiazha2.mdx"
        end
        EffectcreateArgs({
          effect = zf,
          x = x1,
          y = y1,
          size = size,
          height = 0,
          zxz = GetRandomAngle(),
          animespeed = sd
        })
        for _, xq in ac.selector():in_rangexy(x1, y1, 1000):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          bfsmdamage({
            u = u,
            xq = xq,
            damage = 3 * bs,
            bufftime = 1 * bs,
            type = "灵力",
            bufftype = "眩晕"
          })
          if not mz then
            mz = true
            mzhf(u, xq, skillstr)
            if xq:isboss() then
              bosshf = true
            end
          elseif not bosshf and xq:isboss() then
            bosshf = true
            mzhf(u, xq, skillstr)
          end
        end
      end)
      return
    end
    u:effectadd("Bfsmtx\\bfsm_luoxuanwan4.mdx", "right hend", 1)
    u:playseensound(Bfsm_Lxw)
    if u:hasdata("青水皮肤-茉子") then
      local yxz = {
        Mozi_lxw_02,
        Mozi_lxw_03
      }
      if u:hasdata("茉子-兽化状态") then
        yxz = {
          Mozi_Wang_01,
          Mozi_Wang_02,
          Mozi_Wang_03
        }
      end
      u:playseensound(yxz[GetRandomInt(1, #yxz)])
    else
      u:playseensound(Bfsm_lxw1)
    end
    u:buffset(u.handle, 0.9, "暂停")
    u:buffset(u.handle, 1.0, "无敌")
    u:setdata("波风水门-R衔接时间", 1.4)
    local dis = u:getdata("波风水门-R位移距离")
    unitmove({
      unit = u.handle,
      time = 0.4,
      distance = dis - 200 - 150,
      angle = jd,
      isfly = true
    })
    unitmove({
      unit = u.handle,
      time = 0.8,
      distance = 150,
      angle = jd,
      isfly = false
    })
    ac.wait(1, function()
      if u:hasdata("青水皮肤-茉子") then
        u:animeact(8)
        u:animespeed(0.7)
      else
        u:animeact(59)
        u:animespeed(0.7)
      end
    end)
    ac.wait(500, function()
      x, y = u:getxy()
      local cs = 0
      local xtx = "Bfsmtx\\bfsm_xiazha1.mdx"
      if u:hasdata("青水皮肤-茉子") then
        xtx = "Bfsmtx\\bfsm_xiazha1fs.mdx"
      end
      ac.loop(100, function(t)
        cs = cs + 1
        local dx, dy = PolarXY(x, y, 200, jd)
        local dx1, dy1 = PolarXY(x, y, 600, jd)
        EffectcreateArgs({
          effect = xtx,
          x = dx1,
          y = dy1,
          size = 2.5,
          height = 100,
          zxz = jd,
          yxz = -90,
          animespeed = 1
        })
        for _, xq in ac.selector():in_rangexy(dx, dy, 700):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          local dx1, dy1 = xq:getxy()
          local jd1 = AngleXY(dx1, dy1, dx, dy)
          unitmove({
            unit = xq.handle,
            time = 0.2,
            distance = 100,
            angle = jd1,
            isfly = true
          })
          bfsmdamage({
            u = u,
            xq = xq,
            damage = 0.5 * bs,
            bufftime = 0.25 * bs,
            isvest = true,
            type = "灵力"
          })
          if not mz then
            mz = true
            mzhf(u, xq, skillstr)
            if xq:isboss() then
              bosshf = true
            end
          elseif not bosshf and xq:isboss() then
            bosshf = true
            mzhf(u, xq, skillstr)
          end
        end
        if 5 <= cs then
          t:remove()
        end
      end)
      for i = 1, 2 do
        local dx, dy = PolarXY(x, y, 300, jd)
        local zf = ""
        local zf1 = ""
        if u:hasdata("波风水门皮肤") then
          zf = "Bfsmtx\\Mz_New_01.mdx"
          zf1 = "Bfsmtx\\bfsmpf_baozha2.mdx"
          local cs1 = 0
          ac.loop(100, function(t1)
            cs1 = cs1 + 1
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsmpf_luoxuanwan4.mdx",
              x = dx,
              y = dy,
              size = cs1 * 0.75,
              height = 200,
              zxz = jd,
              animespeed = 5
            })
            if 5 <= cs1 then
              t1:remove()
            end
          end)
        else
          zf = "Bfsmtx\\bfsm_luoxuanwan4.mdx"
          zf1 = "Bfsmtx\\bfsm_xiazha4.mdx"
        end
        local tx = EffectcreateArgs({
          effect = zf,
          x = dx,
          y = dy,
          time = 0.5,
          size = 1,
          height = 300,
          zxz = jd,
          animespeed = GetRandomReal(0.5, 3)
        })
        local tx1 = EffectcreateArgs({
          effect = zf1,
          x = dx,
          y = dy,
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
          if u:hasdata("青水皮肤-茉子") then
            japi.EXSetEffectSize(tx, 0.75 + cs1 * 0.05)
            japi.EXSetEffectZ(tx, 25 + cs1 * 8)
            japi.EXSetEffectSize(tx1, cs1 * 0.02)
          else
            japi.EXSetEffectSize(tx, cs1 * 0.5)
            japi.EXSetEffectSize(tx1, cs1 * 0.02)
          end
          if 50 <= cs1 then
            t1:remove()
          end
        end)
      end
      local si
      if u:hasdata("青水皮肤-茉子") then
        si = GetRandomReal(2, 5)
      else
        si = GetRandomReal(1, 10)
      end
      local dx, dy = PolarXY(x, y, 800, jd)
      EffectcreateArgs({
        effect = "Bfsmtx\\bfsm_longjuan1.mdx",
        x = dx,
        y = dy,
        time = 0.5,
        size = si,
        height = 0,
        zxz = jd,
        yxz = -90,
        animespeed = 5
      })
    end)
    ac.wait(1000, function()
      u:shockcamera(100, 0.2)
      local dx, dy = PolarXY(x, y, 300, jd)
      local zf = ""
      local size = 3
      local sd = 2
      if u:hasdata("波风水门皮肤") then
        zf = "Bfsmtx\\bfsmpf_baozha2.mdx"
        size = 1.75
        sd = 2
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsmpf_baozha4_C.mdx",
          x = dx,
          y = dy,
          size = 1.5,
          height = 0,
          zxz = jd,
          animespeed = 15
        })
      else
        zf = "Bfsmtx\\bfsm_xiazha2.mdx"
      end
      EffectcreateArgs({
        effect = zf,
        x = dx,
        y = dy,
        size = size,
        height = 0,
        zxz = jd,
        animespeed = sd
      })
      for _, xq in ac.selector():in_rangexy(dx, dy, 700):is_enemy(u.handle):ipairs() do
        xq = getunit(xq)
        bfsmdamage({
          u = u,
          xq = xq,
          damage = 3 * bs,
          bufftime = 1 * bs,
          type = "灵力",
          bufftype = "眩晕"
        })
        if not mz then
          mz = true
          mzhf(u, xq, skillstr)
          if xq:isboss() then
            bosshf = true
          end
        elseif not bosshf and xq:isboss() then
          bosshf = true
          mzhf(u, xq, skillstr)
        end
      end
    end)
  end,
  RA = function(u)
    local skillstr = "RA"
    local zu = u:getdata("波风水门-飞雷神苦无组")
    local zu2 = u:getdata("波风水门-飞雷神标记组")
    local x, y = u:getxy()
    local x1, y1 = u:getxy()
    local jd = u:getface()
    ac.wait(1, function()
      u:playsound(Sound_Bfsm_AFA1)
      if u:hasdata("青水皮肤-茉子") then
        local yxz = {
          Mozi_Yaoshangle
        }
        if u:hasdata("茉子-兽化状态") then
          yxz = {
            Mozi_Wang_01,
            Mozi_Wang_02,
            Mozi_Wang_03
          }
        end
        u:playseensound(yxz[GetRandomInt(1, #yxz)])
      else
        u:playsound(Sound_Bfsm_atk2)
      end
      if u:hasdata("青水皮肤-茉子") then
        u:animeact(10)
        if u:hasdata("茉子-兽化状态") then
          u:animeact("attack")
        end
        u:animespeed(2)
        ac.wait(300, function()
          u:animespeed(1)
        end)
      else
        u:animeact(6)
        u:animespeed(1.5)
        ac.wait(300, function()
          u:animeact(25)
        end)
      end
    end)
    local mz = false
    local cs = 0
    ac.loop(50, function(t)
      cs = cs + 1
      local jd1 = jd + 60 * cs
      ac.wait(1, function()
        local zf1 = ""
        zf1 = u:getdata("波风水门-飞镖模型2")
        local tx = EffectcreateArgs({
          effect = zf1,
          x = x,
          y = y,
          time = -1,
          size = 1.75,
          height = 50,
          zxz = jd1,
          animespeed = 1
        })
        if type(japi.EXSetEffectFogVisible) == "function" then
          japi.EXSetEffectFogVisible(tx, true)
        end
        if type(japi.EXSetEffectMaskVisible) == "function" then
          japi.EXSetEffectMaskVisible(tx, true)
        end
        local dx, dy = u:getxy()
        local g = CreateGroupLua()
        local sj = GetRandomReal(1, 30)
        local b = false
        local cs1 = 0
        SetData(tx, "飞雷神苦无-消失时间", 3)
        table.insert(zu, tx)
        ac.loop(10, function(t1)
          if GetData(tx, "飞雷神苦无-消失时间") <= 0 then
            t1:remove()
            return
          end
          cs1 = cs1 + 1
          local ax, ay = dx, dy
          dx, dy = PolarXY(dx, dy, 50, jd1)
          if not IsXYInLimRECT(dx, dy) then
            dx, dy = ax, ay
          end
          japi.EXSetEffectXY(tx, dx, dy)
          for _, xq in ac.selector():in_rangexy(dx, dy, 110):is_enemy(u.handle):isnotingroup(g):ipairs() do
            xq = getunit(xq)
            xq:groupadd(g)
            bfsmdamage({
              u = u,
              xq = xq,
              damage = 1,
              bufftime = 0.5
            })
            if u:hasdata("波风水门天赋-无论发生什么我都会保护你") then
              xq:buffset(u.handle, 0.4, "暂停")
            end
            if not mz then
              mz = true
              mzhf(u, xq, skillstr)
            end
            if not b then
              b = true
              xq:groupadd(zu2)
              if not xq:hasdata("飞雷神标记-特效") then
                local ntx = xq:effectadd(u:getdata("波风水门-飞镖模型1"), "overhead", -1)
                xq:setdata("飞雷神标记-特效", ntx)
              end
              local time = returntime(u, 10)
              xq:setdata("飞雷神标记-消失时间", time)
              xq:buffset(u.handle, time, "破坏-伤害免疫")
            end
          end
          if cs1 >= sj then
            SetData(tx, "飞雷神苦无-消失时间", 0)
            flashfls(u)
            local loc = Location(dx, dy)
            local heiadd = GetLocationZ(loc)
            RemoveLocation(loc)
            local fls = Effectcreate(u:getdata("波风水门-飞镖模型1"), dx, dy, -1, 1.75, 50 + heiadd, jd)
            flsshow(fls)
            SetData(fls, "飞雷神苦无-消失时间", returntime(u, 10))
            table.insert(zu, fls)
            t1:remove()
          end
        end)
      end)
      if 6 <= cs then
        t:remove()
      end
    end)
  end,
  ["飞雷神位移"] = function(u, ax, ay)
    local zu = u:getdata("波风水门-飞雷神苦无组")
    local skillstr = "飞雷神位移"
    local tg, dx, dy = pick_nearest_kunai(u, ax, ay, 125)
    if tg ~= 0 or type(tg) == "table" then
      flscf(u)
      u:setdata("波风水门-DE中断标记")
      if u:hasdata("波风水门天赋-看来已经准备好了") then
        local x, y = u:getxy()
        local dis = DistanceXY(ax, ay, x, y)
        if 300 <= dis then
          local loc = Location(x, y)
          local heiadd = GetLocationZ(loc)
          RemoveLocation(loc)
          local fls = Effectcreate(u:getdata("波风水门-飞镖模型1"), x, y, -1, 1.75, 50 + heiadd)
          flsshow(fls)
          SetData(fls, "飞雷神苦无-消失时间", 8)
          table.insert(zu, fls)
        end
      end
      quxian(u, tg, dx, dy, true)
    end
  end,
  DDA = function(u)
    local skillstr = "DDA"
    local x, y = u:getxy()
    local jd = u:getface()
    ac.wait(1, function()
      if u:hasdata("青水皮肤-茉子") then
        u:animeact(3)
        u:animespeed(1)
      else
        u:animeact(8)
        u:animespeed(1)
      end
    end)
    u:shockcamera(150, 0.15)
    u:buffset(u.handle, 0.15, "暂停")
    u:buffset(u.handle, 0.25, "绝对闪避")
    u:buffset(u.handle, 0.25, "无敌")
    local g = CreateGroupLua()
    local mz = false
    if u:hasdata("波风水门皮肤") then
      EffectcreateArgs({
        effect = "Bfsmtx\\bfsmpf_baozha4_C.mdx",
        x = x,
        y = y,
        size = 1.25,
        height = -50,
        zxz = jd,
        animespeed = 20
      })
      EffectcreateArgs({
        effect = "Bfsmtx\\bfsmpf_baozha2.mdx",
        x = x,
        y = y,
        size = 2,
        height = 0,
        zxz = jd,
        animespeed = 2
      })
      EffectcreateArgs({
        effect = "Bfsmtx\\bfsm_dilie2.mdx",
        x = x,
        y = y,
        size = 1.25,
        height = 0,
        zxz = jd,
        animespeed = 3
      })
    else
      EffectcreateArgs({
        effect = "Bfsmtx\\bfsm_dilie1.mdx",
        x = x,
        y = y,
        size = 5,
        height = 0,
        zxz = jd,
        animespeed = 1
      })
      EffectcreateArgs({
        effect = "Bfsmtx\\bfsm_dilie2.mdx",
        x = x,
        y = y,
        size = 0.5,
        height = 0,
        zxz = jd,
        animespeed = 3
      })
    end
    for _, xq in ac.selector():in_rangexy(x, y, 600):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      xq:groupadd(g)
    end
    ForGroupLuaNew(g, function(xq)
      bfsmdamage({
        u = u,
        xq = xq,
        damage = 2,
        bufftime = 1,
        bufftype = "眩晕"
      })
      if not mz then
        mz = true
        mzhf(u, xq, skillstr)
      end
    end)
  end,
  DQ = function(u)
    local skillstr = "DQ"
    local zu = u:getdata("波风水门-飞雷神苦无组")
    local zu2 = u:getdata("波风水门-飞雷神标记组")
    local x, y = u:getxy()
    local mb = u:getdata("波风水门-飞雷神弹反标记单位")
    local x1, y1 = mb:getxy()
    local jd = AngleXY(x, y, x1, y1)
    local x2, y2 = PolarXY(x1, y1, 300, jd)
    local jl = DistanceXY(x, y, x2, y2)
    local djl = jl
    local mz = false
    if djl <= 500 then
      djl = 500
    end
    if 2000 <= djl then
      djl = 2000
    end
    u:setdata("波风水门-弹反连携时间", 0)
    u:deldata("波风水门-弹反限制")
    u:buffset(u.handle, 1.2, "暂停")
    u:buffset(u.handle, 0.4, "绝对闪避")
    u:buffset(u.handle, 1.4, "无敌")
    mb:buffset(u.handle, 2, "沉默")
    mb:buffset(u.handle, 2, "暂停")
    ac.wait(1, function()
      u:setface(jd)
      if u:hasdata("青水皮肤-茉子") then
        u:animeact(3)
        u:animespeed(2)
      else
        u:animeact(3)
        u:animespeed(2)
      end
    end)
    local zf1 = ""
    if u:hasdata("波风水门皮肤") then
      zf1 = "Bfsmtx\\bfsmpf_tuowei1.mdx"
    else
      zf1 = "Bfsmtx\\bfsm_fls_tuowei3.mdx"
    end
    u:effectadd(zf1, "left hand", 1)
    local g = CreateGroupLua()
    mb:groupadd(g)
    if u:hasdata("青水皮肤-茉子") then
      local yxz = {
        Mozi_fls_01,
        Mozi_fls_02,
        Mozi_fls_03
      }
      if u:hasdata("茉子-兽化状态") then
        yxz = {
          Mozi_Wang_01,
          Mozi_Wang_02,
          Mozi_Wang_03
        }
      end
      u:playseensound(yxz[GetRandomInt(1, #yxz)])
    else
      u:playseensound(Bfsm_fls4)
    end
    ac.wait(1, function()
      local loc = Location(x, y)
      local heiadd = GetLocationZ(loc)
      RemoveLocation(loc)
      local fls = Effectcreate(u:getdata("波风水门-飞镖模型1"), x, y, -1, 1.75, 50 + heiadd, jd)
      flsshow(fls)
      SetData(fls, "飞雷神苦无-消失时间", returntime(u, 10))
      table.insert(zu, fls)
      local zf1 = ""
      zf1 = u:getdata("波风水门-飞镖模型2")
      local tx = EffectcreateArgs({
        effect = zf1,
        x = x,
        y = y,
        time = -1,
        size = 1.75,
        height = 100,
        zxz = jd,
        animespeed = 1
      })
      if type(japi.EXSetEffectFogVisible) == "function" then
        japi.EXSetEffectFogVisible(tx, true)
      end
      if type(japi.EXSetEffectMaskVisible) == "function" then
        japi.EXSetEffectMaskVisible(tx, true)
      end
      local dx, dy = x, y
      local cs = 0
      ac.loop(10, function(t)
        cs = cs + 1
        dx, dy = PolarXY(dx, dy, jl / 30, jd)
        japi.EXSetEffectXY(tx, dx, dy)
        if 30 <= cs then
          DestroyEffectLua(tx)
          t:remove()
        end
      end)
    end)
    ac.wait(300, function()
      if u:hasdata("波风水门皮肤") then
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
          x = x,
          y = y,
          time = 0.5,
          size = 1,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsmpf_fls_shunyi1.mdx",
          x = x,
          y = y,
          size = 2,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
      else
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
          x = x,
          y = y,
          size = GetRandomReal(2, 3),
          height = 0,
          zxz = jd,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
          x = x,
          y = y,
          size = 1,
          height = 250,
          zxz = jd,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_fls_shanguang1.mdx",
          x = x,
          y = y,
          size = 8,
          height = -400,
          zxz = jd,
          animespeed = 1
        })
      end
      if u:hasdata("波风水门皮肤") then
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
          x = x2,
          y = y2,
          time = 0.5,
          size = 1,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsmpf_fls_shunyi1.mdx",
          x = x2,
          y = y2,
          size = 2,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
      else
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
          x = x2,
          y = y2,
          size = GetRandomReal(2, 3),
          height = 0,
          zxz = jd,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
          x = x2,
          y = y2,
          size = 1,
          height = 250,
          zxz = jd,
          animespeed = 1
        })
      end
      u:setxy(x2, y2)
      PlayGlobalSound(Bfsm_fls_shunyi2)
      u:setface(jd + 180)
      if u:hasdata("青水皮肤-茉子") then
        u:animeact(8)
        u:animespeed(3)
        ac.wait(200, function()
          u:animespeed(0.0)
        end)
      else
        u:animeact(6)
        u:animespeed(3)
        ac.wait(200, function()
          u:animespeed(0.0)
        end)
      end
      ForGroupLuaNew(g, function(xq)
        bfsmdamage({
          u = u,
          xq = xq,
          damage = 2,
          bufftime = 1,
          bufftype = "暂停"
        })
        if not mz then
          mz = true
          mzhf(u, xq, skillstr)
        end
      end)
      ac.wait(1, function()
        local zf1 = ""
        zf1 = u:getdata("波风水门-飞镖模型2")
        local tx = EffectcreateArgs({
          effect = zf1,
          x = x,
          y = y,
          time = -1,
          size = 1.75,
          height = 100,
          zxz = jd + 180,
          yxz = -33,
          animespeed = 1
        })
        if type(japi.EXSetEffectFogVisible) == "function" then
          japi.EXSetEffectFogVisible(tx, true)
        end
        if type(japi.EXSetEffectMaskVisible) == "function" then
          japi.EXSetEffectMaskVisible(tx, true)
        end
        local dx, dy = x2, y2
        local cs = 0
        ac.loop(10, function(t)
          cs = cs + 1
          local gd = 27 * cs
          dx, dy = PolarXY(dx, dy, djl / 30, jd + 180)
          japi.EXSetEffectXY(tx, dx, dy)
          japi.EXSetEffectZ(tx, gd)
          if 30 <= cs then
            ac.wait(300, function()
              DestroyEffectLua(tx)
            end)
            t:remove()
          end
        end)
      end)
      ac.wait(100, function()
        local dx, dy = PolarXY(x2, y2, djl / 2, jd + 180)
        u:setxy(dx, dy)
        unitmove({
          unit = u.handle,
          time = 0.5,
          distance = 100,
          angle = jd + 180,
          isfly = true,
          loops = {
            {
              looptime = 0.02,
              func = function(dx, dy)
                for _, xq in ac.selector():in_rangexy(dx, dy, 225):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(g)
                end
                local dx2, dy2 = PolarXY(dx, dy, 200, jd + 180)
                ForGroupLuaNew(g, function(xq)
                  xq:setxy(dx2, dy2)
                end)
              end
            }
          }
        })
        ac.wait(500, function()
          if u:hasdata("青水皮肤-茉子") then
            local snd = Mozi_lwx_r_01
            if u:hasdata("茉子-兽化状态") then
              local yxz = {
                Mozi_Wang_01,
                Mozi_Wang_02,
                Mozi_Wang_03
              }
              snd = yxz[GetRandomInt(1, #yxz)]
            end
            u:playseensound(snd)
          else
            u:playseensound(Bfsm_lxw2)
          end
          PlayGlobalSound(Bfsm_fls_shunyi3)
          if u:hasdata("波风水门皮肤") then
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
              x = dx,
              y = dy,
              time = 0.5,
              size = 1,
              height = 0,
              zxz = jd,
              animespeed = 1
            })
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsmpf_fls_shunyi1.mdx",
              x = dx,
              y = dy,
              size = 2,
              height = 0,
              zxz = jd,
              animespeed = 1
            })
          else
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
              x = dx,
              y = dy,
              size = GetRandomReal(2, 3),
              height = 0,
              zxz = jd,
              animespeed = 1
            })
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
              x = dx,
              y = dy,
              size = 1,
              height = 250,
              zxz = jd,
              animespeed = 1
            })
          end
          dx, dy = PolarXY(x2, y2, djl, jd + 180)
          u:setxy(dx, dy)
          if u:hasdata("青水皮肤-茉子") then
            u:animeact(2)
            u:animespeed(2)
            ac.wait(500, function()
              u:animespeed(1)
            end)
          else
            u:animeact(3)
            u:animespeed(1)
          end
          u:setflyheight(800)
          if u:hasdata("波风水门皮肤") then
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
              x = dx,
              y = dy,
              time = 0.5,
              size = 1,
              height = 800,
              zxz = jd,
              animespeed = 1
            })
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsmpf_fls_shunyi1.mdx",
              x = dx,
              y = dy,
              size = 2,
              height = 800,
              zxz = jd,
              animespeed = 1
            })
          else
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
              x = dx,
              y = dy,
              size = GetRandomReal(2, 3),
              height = 800,
              zxz = jd,
              animespeed = 1
            })
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
              x = dx,
              y = dy,
              size = 1,
              height = 1050,
              zxz = jd,
              animespeed = 1
            })
          end
          ForGroupLuaNew(g, function(xq)
            xq:setxy(dx, dy)
            xq:setflyheight(600)
            bfsmdamage({
              u = u,
              xq = xq,
              damage = 2,
              bufftime = 1,
              bufftype = "暂停"
            })
            if not mz then
              mz = true
              mzhf(u, xq, skillstr)
            end
          end)
        end)
        ac.wait(800, function()
          u:animespeed(2)
          u:setflyheight(0)
          local dx2, dy2 = PolarXY(dx, dy, 100, jd + 180)
          u:shockcamera(75, 0.15)
          if u:hasdata("波风水门皮肤") then
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsmpf_baozha3.mdx",
              x = dx2,
              y = dy2,
              size = 5,
              height = -500,
              zxz = jd,
              animespeed = 10
            })
          else
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsm_dilie1.mdx",
              x = dx2,
              y = dy2,
              size = 8,
              height = 0,
              zxz = jd,
              animespeed = 1
            })
          end
          ForGroupLuaNew(g, function(xq)
            xq:setxy(dx2, dy2)
            xq:setflyheight(0)
            bfsmdamage({
              u = u,
              xq = xq,
              damage = 2,
              bufftime = 1,
              bufftype = "暂停"
            })
            if not mz then
              mz = true
              mzhf(u, xq, skillstr)
            end
          end)
        end)
        ac.wait(1100, function()
          if u:hasdata("青水皮肤-茉子") then
            u:animeact(3)
            u:animespeed(2)
            ac.wait(500, function()
              u:animespeed(1)
            end)
          else
            u:animeact(8)
            u:animespeed(1)
          end
          u:shockcamera(150, 0.15)
          local dx2, dy2 = PolarXY(dx, dy, 100, jd + 180)
          if u:hasdata("波风水门皮肤") then
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsmpf_baozha4_C.mdx",
              x = dx2,
              y = dy2,
              size = 2,
              height = -50,
              zxz = jd,
              animespeed = 20
            })
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsmpf_baozha2.mdx",
              x = dx2,
              y = dy2,
              size = 3,
              height = 0,
              zxz = jd,
              animespeed = 2
            })
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsm_dilie2.mdx",
              x = dx2,
              y = dy2,
              size = 2,
              height = 0,
              zxz = jd,
              animespeed = 3
            })
          else
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsm_dilie1.mdx",
              x = dx2,
              y = dy2,
              size = 8,
              height = 0,
              zxz = jd,
              animespeed = 1
            })
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsm_dilie2.mdx",
              x = dx2,
              y = dy2,
              size = 1,
              height = 0,
              zxz = jd,
              animespeed = 3
            })
          end
          for _, xq in ac.selector():in_rangexy(dx2, dy2, 850):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:groupadd(g)
          end
          ForGroupLuaNew(g, function(xq)
            bfsmdamage({
              u = u,
              xq = xq,
              damage = 2,
              bufftime = 1,
              bufftype = "眩晕"
            })
          end)
        end)
      end)
    end)
  end,
  DA = function(u)
    local skillstr = "DA"
    local damage_multiplier = u:hasdata("神器判定-飞雷神苦无") and 2 or 1
    local cd = 60
    local bj = false
    if u:hasdata("波风水门天赋-背负着火影之名我不能输") then
      cd = 40
      bj = true
    end
    if u:hasdata("波风水门-专属传奇强化") then
      cd = cd - 10
      u:buffset(u.handle, 3.4, "绝对闪避")
    end
    u:setdata("波风水门-DA冷却", cd)
    if u:islocal() then
      if u:hasdata("青水皮肤-茉子") then
        BuffUI.apply({
          id = "波风水门-DA冷却皮肤"
        })
      else
        BuffUI.apply({
          id = "波风水门-DA冷却"
        })
      end
    end
    local zu2 = u:getdata("波风水门-飞雷神标记组")
    local x, y = u:getxy()
    local x1 = u:getdata("波风水门-X")
    local y1 = u:getdata("波风水门-Y")
    local jd = AngleXY(x, y, x1, y1)
    local dis = DistanceXY(x, y, x1, y1)
    ac.wait(1, function()
      if u:hasdata("青水皮肤-茉子") then
        u:animeact(7)
        u:animespeed(1)
        unitmove({
          unit = u.handle,
          time = 0.6,
          distance = 200,
          angle = 180 + u:getface()
        })
      else
        u:animeact(53)
        u:animespeed(3)
      end
    end)
    local mz = false
    u:buffset(u.handle, 3.1, "暂停")
    u:buffset(u.handle, 3.4, "无敌")
    if u:hasdata("青水皮肤-茉子") then
      local yxz = {
        Mozi_Ikuzo_01,
        Mozi_Ikuzo_02,
        Mozi_Ikuzo_03
      }
      if u:hasdata("茉子-兽化状态") then
        yxz = {
          Mozi_Wang_01,
          Mozi_Wang_02,
          Mozi_Wang_03
        }
      end
      u:playseensound(yxz[GetRandomInt(1, #yxz)])
    else
      u:playseensound(Bfsm_atk1)
    end
    local g1 = CreateGroupLua()
    ac.wait(600, function()
      if u:hasdata("青水皮肤-茉子") then
        local yxz = {
          Mozi_fls_01,
          Mozi_fls_02,
          Mozi_fls_03
        }
        if u:hasdata("茉子-兽化状态") then
          yxz = {
            Mozi_Wang_01,
            Mozi_Wang_02,
            Mozi_Wang_03
          }
        end
        u:playseensound(yxz[GetRandomInt(1, #yxz)])
      else
        u:playseensound(Bfsm_fls4)
      end
      if u:hasdata("波风水门皮肤") then
        ac.wait(200, function()
          EffectcreateArgs({
            effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
            x = x,
            y = y,
            size = 1,
            height = 0,
            zxz = jd,
            animespeed = 1
          })
        end)
      else
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
          x = x,
          y = y,
          size = 1,
          height = 100,
          zxz = jd,
          animespeed = 1
        })
      end
    end)
    for i = 1, 20 do
      local jd1 = jd + GetRandomReal(-45, 45)
      local sj1 = (i - 1) % 3 + 1
      ac.wait(200, function()
        local zf1 = ""
        zf1 = u:getdata("波风水门-飞镖模型2")
        local tx = EffectcreateArgs({
          effect = zf1,
          x = x,
          y = y,
          time = -1,
          size = GetRandomReal(2, 5),
          height = 100,
          zxz = jd1,
          animespeed = 1
        })
        if type(japi.EXSetEffectFogVisible) == "function" then
          japi.EXSetEffectFogVisible(tx, true)
        end
        if type(japi.EXSetEffectMaskVisible) == "function" then
          japi.EXSetEffectMaskVisible(tx, true)
        end
        local bosshf = false
        local dx, dy = u:getxy()
        local sj = GetRandomReal(15, 75)
        local cs = 0
        local zd = {
          55,
          1,
          2,
          3
        }
        if u:hasdata("青水皮肤-茉子") then
          zd = {2, 3}
        end
        ac.loop(10, function(t)
          cs = cs + 1
          if cs <= 30 then
            dx, dy = PolarXY(dx, dy, sj, jd1)
            for _, xq in ac.selector():in_rangexy(dx, dy, 100):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              if not xq:isingroup(g1) then
                xq:groupadd(g1)
                bfsmdamage({
                  u = u,
                  xq = xq,
                  damage = damage_multiplier,
                  bufftime = 1
                })
                if not mz then
                  mz = true
                  mzhf(u, xq, skillstr)
                  if xq:isboss() then
                    bosshf = true
                  end
                elseif not bosshf and xq:isboss() then
                  bosshf = true
                  mzhf(u, xq, skillstr)
                end
                if bj then
                  xq:groupadd(zu2)
                  if not xq:hasdata("飞雷神标记-特效") then
                    local ntx = xq:effectadd(u:getdata("波风水门-飞镖模型1"), "overhead", -1)
                    xq:setdata("飞雷神标记-特效", ntx)
                  end
                  local time = returntime(u, 10)
                  xq:setdata("飞雷神标记-消失时间", time)
                  xq:buffset(u.handle, time, "破坏-伤害免疫")
                else
                  xq:buffset(u.handle, 10, "破坏-伤害免疫")
                end
              end
            end
          else
            dx, dy = PolarXY(dx, dy, 0.2, jd1)
          end
          japi.EXSetEffectXY(tx, dx, dy)
          if cs >= 50 + i * 10 then
            local dx1, dy1 = u:getxy()
            local dx2, dy2 = PolarXY(dx1, dy1, GetRandomReal(1000, 2000), jd + GetRandomReal(90, 270))
            local jl = DistanceXY(dx, dy, dx1, dy1)
            local zf = ""
            if u:hasdata("波风水门皮肤") then
              zf = "Bfsmtx\\bfsmpf_tuowei1.mdx"
            else
              zf = "Bfsmtx\\bfsm_fls_tuowei3.mdx"
            end
            local tx1 = EffectcreateArgs({
              effect = zf,
              x = dx1,
              y = dy1,
              time = -1,
              size = 3,
              height = 100,
              zxz = jd,
              animespeed = 3
            })
            if type(japi.EXSetEffectFogVisible) == "function" then
              japi.EXSetEffectFogVisible(tx1, true)
            end
            if type(japi.EXSetEffectMaskVisible) == "function" then
              japi.EXSetEffectMaskVisible(tx1, true)
            end
            Bezier(tx1, dx1, dy1, dx, dy, dx2, dy2, jd, jl, 20)
            if sj1 == 1 then
              PlayGlobalSound(Bfsm_fls_shunyi2)
            elseif sj1 == 2 then
              PlayGlobalSound(Bfsm_fls_shunyi3)
            else
              PlayGlobalSound(Bfsm_fls_shunyi4)
            end
            u:animeact(zd[GetRandomInt(1, #zd)])
            u:animespeed(2)
            u:setxy(dx, dy)
            flscf(u)
            if u:hasdata("波风水门皮肤") then
              EffectcreateArgs({
                effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
                x = dx,
                y = dy,
                size = 1,
                height = 100,
                zxz = jd1,
                animespeed = 1
              })
              EffectcreateArgs({
                effect = "Bfsmtx\\bfsmpf_fls_shunyi1.mdx",
                x = dx,
                y = dy,
                size = 2,
                height = 0,
                zxz = jd1,
                animespeed = 1
              })
            else
              EffectcreateArgs({
                effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
                x = dx,
                y = dy,
                size = GetRandomReal(2, 3),
                height = 0,
                zxz = jd1,
                animespeed = 1
              })
              EffectcreateArgs({
                effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
                x = dx,
                y = dy,
                size = 1,
                height = 200,
                zxz = jd1,
                animespeed = 1
              })
            end
            DestroyEffectLua(tx)
            t:remove()
          end
        end)
      end)
    end
    ac.wait(3000, function()
      u:setxy(x, y)
      if u:hasdata("青水皮肤-茉子") then
        local yxz = {
          Mozi_osoyi_01,
          Mozi_osoyi_02,
          Mozi_osoyi_03,
          Mozi_osoyi_04
        }
        if u:hasdata("茉子-兽化状态") then
          yxz = {
            Mozi_Wang_01,
            Mozi_Wang_02,
            Mozi_Wang_03
          }
        end
        u:playseensound(yxz[GetRandomInt(1, #yxz)])
      else
        u:playseensound(Bfsm_fls2)
      end
      u:playseensound(Bfsm_A1)
      u:effectadd("Bfsmtx\\bfsm_fls_tuowei1.mdx", "chest", 0.3)
      if u:hasdata("波风水门皮肤") then
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
          x = x,
          y = y,
          size = 1,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
      else
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
          x = x,
          y = y,
          size = GetRandomReal(2, 3),
          height = 0,
          zxz = jd,
          animespeed = 1
        })
      end
      ac.wait(100, function()
        local dx, dy = PolarXY(x, y, 1250, jd)
        if u:hasdata("波风水门皮肤") then
          EffectcreateArgs({
            effect = "Bfsmtx\\bfsmpf_baozha5.mdx",
            x = dx,
            y = dy,
            size = 2,
            height = 0,
            zxz = GetRandomAngle(),
            animespeed = 1
          })
          for i = 1, 2 do
            EffectcreateArgs({
              effect = "Bfsmtx\\bfsmpf_baozha2.mdx",
              x = dx,
              y = dy,
              size = 3,
              height = 0,
              zxz = GetRandomAngle(),
              animespeed = 1
            })
          end
        else
          EffectcreateArgs({
            effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
            x = dx,
            y = dy,
            size = 3,
            height = 300,
            zxz = jd,
            animespeed = 1
          })
          EffectcreateArgs({
            effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
            x = dx,
            y = dy,
            size = 10,
            height = -300,
            zxz = jd,
            animespeed = 2
          })
        end
        if u:hasdata("青水皮肤-茉子") then
          u:animeact(3)
          u:animespeed(2)
          ac.wait(500, function()
            u:animespeed(1)
          end)
        else
          u:animeact(51)
          u:animespeed(2)
          ac.wait(500, function()
            u:animespeed(1)
          end)
        end
        u:shockcamera(100, 0.1)
        unitmove({
          unit = u.handle,
          time = 0.1,
          distance = 2500,
          angle = u:getface(),
          isfly = true
        })
      end)
    end)
    ac.wait(700, function()
      local dx, dy = PolarXY(x, y, 1250, jd)
      local cs = 0
      ac.loop(100, function(t)
        cs = cs + 1
        for _, xq in ac.selector():in_rangexy(dx, dy, 900):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          xq:groupadd(g1)
        end
        ForGroupLuaNew(g1, function(xq)
          local dx1, dy1 = xq:getxy()
          local jd1 = AngleXY(dx1, dy1, dx, dy)
          unitmove({
            unit = xq.handle,
            time = 0.1,
            distance = 20,
            angle = jd1,
            isfly = true
          })
          bfsmdamage({
            u = u,
            xq = xq,
            damage = 0.5 * damage_multiplier,
            bufftime = 1
          })
          if not mz then
            mz = true
            mzhf(u, xq, skillstr)
          end
        end)
        if 20 <= cs then
          t:remove()
        end
      end)
      ac.wait(2500, function()
        u:shockcamera(100, 0.2)
        for _, xq in ac.selector():in_rangexy(dx, dy, 1250):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          xq:groupadd(g1)
        end
        ForGroupLuaNew(g1, function(xq)
          bfsmdamage({
            u = u,
            xq = xq,
            damage = 4 * damage_multiplier,
            bufftime = 2,
            bufftype = "眩晕"
          })
          if not mz then
            mz = true
            mzhf(u, xq, skillstr)
          end
        end)
      end)
    end)
  end,
  SDR = function(u)
    local skillstr = "SDR"
    local x, y = u:getxy()
    local x1 = u:getdata("波风水门-X")
    local y1 = u:getdata("波风水门-Y")
    local jd = AngleXY(x, y, x1, y1)
    local g = CreateGroupLua()
    u:buffset(u.handle, 6.5, "暂停")
    u:buffset(u.handle, 6.7, "绝对闪避")
    u:buffset(u.handle, 6.7, "永恒")
    local zd
    ac.wait(1, function()
      if u:hasdata("青水皮肤-茉子") then
        u:animeact(7)
        u:animespeed(1)
        unitmove({
          unit = u.handle,
          time = 0.6,
          distance = 200,
          angle = 180 + u:getface()
        })
        zd = {2, 3}
      else
        u:animeact(53)
        u:animespeed(3)
        zd = {
          55,
          1,
          2,
          3
        }
      end
    end)
    u:setdata("波风水门-零式发动中")
    u:setdata("波风水门-奥义充能值", 0)
    local bs = 1
    local lxwbl = 0.5
    if u:hasdata("波风水门天赋-该做个了结了") then
      lxwbl = 1
    end
    if u:hasdata("波风水门天赋-虽然是对手但是你还不赖嘛") then
      if u:hasdata("波风水门-轮椅模式") then
        if u:hasdata("青水皮肤-茉子") then
          local nums = {}
          for i = 1, 11 do
            nums[i] = i
          end
          for i = #nums, 2, -1 do
            local j = GetRandomInt(1, i)
            nums[i], nums[j] = nums[j], nums[i]
          end
          local flashphotoclass4 = class.panel:builder({
            parent = OriginPanel,
            x = 0,
            y = 0,
            w = 1920,
            h = 1080,
            normal_image = "Mozi_Ly_01.blp"
          })
          StopSoundBJ(BGM_Mozi_Ly_02, false)
          PlayBGM({
            bgm = BGM_Mozi_Ly_01,
            time = 34,
            ID = 227,
            unit = u.handle
          })
          PlayGlobalSound(Mozi_Ly_02)
          local aplha = 255
          flashphotoclass4:set_alpha(aplha)
          ac.loop(30, function(timer2)
            aplha = aplha - 15
            flashphotoclass4:set_alpha(aplha)
            if aplha <= 0 then
              flashphotoclass4:hide()
              timer2:remove()
            end
          end)
          local cs = 1
          ac.wait(500, function()
            ac.loop(1500, function(timer3)
              PlayGlobalSound(Mozi_Ly_01)
              local aplha = 150
              local s = "Mozi_Ly_S_" .. string.format("%02d", nums[cs]) .. ".blp"
              flashphotoclass4:set_normal_image(s)
              flashphotoclass4:set_alpha(aplha)
              flashphotoclass4:show()
              cs = cs + 1
              ac.loop(30, function(timer2)
                aplha = aplha - 15
                flashphotoclass4:set_alpha(aplha)
                if aplha <= 0 then
                  flashphotoclass4:hide()
                  if cs == 5 then
                    flashphotoclass4:destroy()
                  end
                  timer2:remove()
                end
              end)
              if cs == 4 then
                timer3:remove()
              end
            end)
          end)
        elseif u:hasdata("查克拉秘卷使用") then
          PlayBGM({
            bgm = BGM_Bfsm_Zs_ly2,
            time = 35,
            ID = 213,
            unit = u.handle
          })
        else
          PlayBGM({
            bgm = BGM_Bfsm_Zs_ly,
            time = 55,
            ID = 213,
            unit = u.handle
          })
        end
      end
      u:setdata("波风水门-一式伤害提升", u:getdata("波风水门-一式伤害限时提升"))
      bs = 2
      local img = "Bfsm_AoyiZimu2.blp"
      local w = 600
      local h = 85
      if u:hasdata("青水皮肤-茉子") and GetRandom100(50) then
        img = "Bfsm_AoyiZimu3.blp"
        w = 384
        h = 216
      end
      local dy = 810 - h
      local dx = -1500
      local dxx = 1250 - w
      local exph = class.panel:builder({
        x = dx,
        y = dy,
        w = 1.4 * w / 0.71,
        h = 1.4 * h / 0.91,
        normal_image = img
      })
      ac.loop(20, function(timer)
        dx = dx + 75
        exph:set_position(dx, dy)
        if dx >= dxx then
          ac.wait(1000, function()
            exph:destroy()
          end)
          timer:remove()
        end
      end)
    end
    local yxz = {}
    local yxz2 = {
      Sound_Bfsm_tsR4_01,
      Sound_Bfsm_tsR4_02,
      Sound_Bfsm_tsR4_03,
      Sound_Bfsm_tsR4_04,
      Sound_Bfsm_tsR5_01,
      Sound_Bfsm_tsR5_02,
      Sound_Bfsm_tsR5_03,
      Sound_Bfsm_tsR6_01,
      Sound_Bfsm_tsR6_02,
      Sound_Bfsm_tsR6_03
    }
    local yysj = GetRandomInt(1, 2)
    if yysj == 1 then
      yxz = {
        Sound_Bfsm_tsR_01,
        Sound_Bfsm_tsR3_01,
        Sound_Bfsm_tsR7_01,
        Sound_Bfsm_tsR8_01
      }
    else
      yxz = {
        Sound_Bfsm_tsR_02,
        Sound_Bfsm_tsR3_01,
        Sound_Bfsm_tsR7_01,
        Sound_Bfsm_tsR8_01
      }
    end
    if u:hasdata("青水皮肤-茉子") then
      yxz = {
        Mozi_Aoyi_01,
        Mozi_Aoyi_02,
        Mozi_Aoyi_04,
        Mozi_Aoyi_05
      }
      yxz2 = {
        Mozi_Aoyi_03_01,
        Mozi_Aoyi_03_02,
        Mozi_Aoyi_03_03,
        Mozi_Aoyi_03_04,
        Mozi_Aoyi_03_05,
        Mozi_Aoyi_03_06,
        Mozi_Aoyi_03_07,
        Mozi_Aoyi_03_08,
        Mozi_Aoyi_03_09,
        Mozi_Aoyi_03_10
      }
      if u:hasdata("茉子-兽化状态") then
        yxz = {
          Mozi_Wang_01,
          Mozi_Wang_02,
          Mozi_Wang_03
        }
        yxz2 = {
          Mozi_Wang_01,
          Mozi_Wang_02,
          Mozi_Wang_03
        }
      end
    end
    PlayGlobalSound(yxz[1])
    SetCameraTargetControllerNoZForPlayer(u.owner, u.handle, 0, 0, false)
    ac.wait(600, function()
      if u:hasdata("青水皮肤-茉子") then
        PlayGlobalSound(yxz[2])
      else
        PlayGlobalSound(Sound_Bfsm_tsR2_01)
      end
      local zf = ""
      local gd = 0
      if u:hasdata("波风水门皮肤") then
        zf = "Bfsmtx\\bfsmpf_shunyi1.mdx"
        gd = 0
        EffectcreateArgs({
          effect = "Bfsmtx\\bfsmpf_fls_shunyi1.mdx",
          x = x,
          y = y,
          size = 2,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
      else
        zf = "Bfsmtx\\bfsm_fls_shanguang2.mdx"
        gd = 200
      end
      EffectcreateArgs({
        effect = zf,
        x = x,
        y = y,
        size = 1,
        height = gd,
        zxz = jd,
        animespeed = 1
      })
    end)
    for i = 1, 6 do
      local jd1 = jd + GetRandomReal(-20, 20)
      if i == 1 then
        jd1 = jd
      end
      local sj1 = (i - 1) % 3 + 1
      ac.wait(200, function()
        local zf1 = ""
        zf1 = u:getdata("波风水门-飞镖模型2")
        local tx = EffectcreateArgs({
          effect = zf1,
          x = x,
          y = y,
          time = -1,
          size = GetRandomReal(2, 5),
          height = 100,
          zxz = jd1,
          animespeed = 1
        })
        if type(japi.EXSetEffectFogVisible) == "function" then
          japi.EXSetEffectFogVisible(tx, true)
        end
        if type(japi.EXSetEffectMaskVisible) == "function" then
          japi.EXSetEffectMaskVisible(tx, true)
        end
        local dx, dy = u:getxy()
        local sj = GetRandomReal(15, 75)
        if i == 1 then
          sj = 75
        end
        local cs = 0
        ac.loop(10, function(t)
          cs = cs + 1
          if cs <= 30 then
            dx, dy = PolarXY(dx, dy, sj, jd1)
            for _, xq in ac.selector():in_rangexy(dx, dy, 140):is_enemy(u.handle):isnotingroup(g):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g)
              bfsmdamage({
                u = u,
                xq = xq,
                damage = 2 * bs,
                bufftime = 8,
                bufftype = "暂停"
              })
              xq:buffset(u.handle, 8, "沉默")
              if xq:isboss() then
                xq:setdata("波风水门-连招中")
              end
            end
          else
            dx, dy = PolarXY(dx, dy, 0.2, jd1)
          end
          japi.EXSetEffectXY(tx, dx, dy)
          if cs >= 50 + i * 10 then
            local dx1, dy1 = u:getxy()
            local dx2, dy2 = PolarXY(dx1, dy1, GetRandomReal(1000, 2000), jd + GetRandomReal(90, 270))
            local jl = DistanceXY(dx, dy, dx1, dy1)
            local zf = ""
            if u:hasdata("波风水门皮肤") then
              zf = "Bfsmtx\\bfsmpf_tuowei1.mdx"
            else
              zf = "Bfsmtx\\bfsm_fls_tuowei3.mdx"
            end
            local tx1 = EffectcreateArgs({
              effect = zf,
              x = dx1,
              y = dy1,
              time = -1,
              size = 3,
              height = 100,
              zxz = jd,
              animespeed = 3
            })
            if type(japi.EXSetEffectFogVisible) == "function" then
              japi.EXSetEffectFogVisible(tx1, true)
            end
            if type(japi.EXSetEffectMaskVisible) == "function" then
              japi.EXSetEffectMaskVisible(tx1, true)
            end
            Bezier(tx1, dx1, dy1, dx, dy, dx2, dy2, jd, jl, 20)
            if sj1 == 1 then
              PlayGlobalSound(Bfsm_fls_shunyi2)
            elseif sj1 == 2 then
              PlayGlobalSound(Bfsm_fls_shunyi3)
            else
              PlayGlobalSound(Bfsm_fls_shunyi4)
            end
            u:animeact(zd[GetRandomInt(1, #zd)])
            u:animespeed(3)
            u:setxy(dx, dy)
            u:setface(jd1)
            for _, xq in ac.selector():in_rangexy(dx, dy, 350):is_enemy(u.handle):isnotingroup(g):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g)
              if xq:isboss() then
                xq:setdata("波风水门-连招中")
              end
            end
            ForGroupLuaNew(g, function(xq)
              local ax, ay = PolarXY(dx, dy, GetRandomReal(0, 100), GetRandomAngle())
              xq:setxy(ax, ay)
              u:setdata("波风水门-一式附伤")
              bfsmdamage({
                u = u,
                xq = xq,
                damage = 2 * bs,
                bufftime = 7,
                bufftype = "暂停"
              })
              xq:buffset(u.handle, 8, "沉默")
            end)
            if u:hasdata("波风水门皮肤") then
              EffectcreateArgs({
                effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
                x = dx,
                y = dy,
                size = 1,
                height = 0,
                zxz = jd1,
                animespeed = 1
              })
              EffectcreateArgs({
                effect = "Bfsmtx\\bfsmpf_fls_shunyi1.mdx",
                x = dx,
                y = dy,
                size = 2,
                height = 0,
                zxz = jd1,
                animespeed = 1
              })
            else
              EffectcreateArgs({
                effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
                x = dx,
                y = dy,
                size = GetRandomReal(2, 3),
                height = 0,
                zxz = jd1,
                animespeed = 1
              })
              EffectcreateArgs({
                effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
                x = dx,
                y = dy,
                size = 1,
                height = 250,
                zxz = jd1,
                animespeed = 1
              })
            end
            DestroyEffectLua(tx)
            t:remove()
          end
        end)
      end)
    end
    ac.wait(1500, function()
      PlayGlobalSound(Bfsm_fls_shunyi2)
      u:setxy(x, y)
      if u:hasdata("青水皮肤-茉子") then
        u:animeact(3)
        u:animespeed(2)
      else
        u:animeact(8)
        u:animespeed(1)
        PlayGlobalSound(yxz[2])
      end
      u:setface(jd)
      u:effectadd("Bfsmtx\\bfsm_fls_tuowei1.mdx", "chest", 0.3)
      local zf = ""
      local gd = 0
      if u:hasdata("波风水门皮肤") then
        zf = "Bfsmtx\\bfsmpf_shunyi1.mdx"
      else
        zf = "Bfsmtx\\bfsm_fls_shanguang2.mdx"
        gd = 250
      end
      EffectcreateArgs({
        effect = zf,
        x = x,
        y = y,
        size = 1,
        height = gd,
        zxz = jd,
        animespeed = 1
      })
    end)
    ac.wait(1000, function()
      local cs = 0
      ac.loop(520, function(t)
        cs = cs + 1
        ac.wait(1, function()
          local dx, dy = u:getxy()
          local dx1, dy1 = PolarXY(dx, dy, 800, jd)
          local dx2, dy2 = PolarXY(dx, dy, GetRandomReal(1000, 5000), jd + GetRandomReal(0, 360))
          local jl = DistanceXY(dx, dy, dx1, dy1)
          local zf = ""
          if u:hasdata("波风水门皮肤") then
            zf = "Bfsmtx\\bfsmpf_tuowei1.mdx"
          else
            zf = "Bfsmtx\\bfsm_fls_tuowei3.mdx"
          end
          local tx1 = EffectcreateArgs({
            effect = zf,
            x = dx1,
            y = dy1,
            time = -1,
            size = 3,
            height = 100,
            zxz = jd,
            animespeed = 3
          })
          if type(japi.EXSetEffectFogVisible) == "function" then
            japi.EXSetEffectFogVisible(tx1, true)
          end
          if type(japi.EXSetEffectMaskVisible) == "function" then
            japi.EXSetEffectMaskVisible(tx1, true)
          end
          Bezier(tx1, dx, dy, dx1, dy1, dx2, dy2, jd, jl, 50)
          local sj = GetRandomInt(1, 3)
          if sj == 1 then
            PlayGlobalSound(Bfsm_fls_shunyi2)
          elseif sj == 2 then
            PlayGlobalSound(Bfsm_fls_shunyi3)
          else
            PlayGlobalSound(Bfsm_fls_shunyi4)
          end
          ac.wait(500, function()
            local yysj2 = GetRandomInt(1, 2)
            if 3 <= cs then
              yysj2 = GetRandomInt(1, 3)
            end
            if cs == 1 then
              if yysj2 == 1 then
                PlayGlobalSound(yxz2[1])
              else
                PlayGlobalSound(yxz2[2])
              end
            end
            if cs == 2 then
              if yysj2 == 1 then
                PlayGlobalSound(yxz2[3])
              else
                PlayGlobalSound(yxz2[4])
              end
            end
            if cs == 3 then
              if yysj2 == 1 then
                PlayGlobalSound(yxz2[5])
              elseif yysj2 == 2 then
                PlayGlobalSound(yxz2[6])
              else
                PlayGlobalSound(yxz2[7])
              end
            end
            if cs == 4 then
              PlayGlobalSound(Sound_Bfsm_R1)
              if yysj2 == 1 then
                PlayGlobalSound(yxz2[8])
              elseif yysj2 == 2 then
                PlayGlobalSound(yxz2[9])
              else
                PlayGlobalSound(yxz2[10])
              end
            end
            if cs < 4 then
              if u:hasdata("青水皮肤-茉子") then
                local zud = {2, 3}
                u:animeact(zud[GetRandomInt(1, #zud)])
                u:animespeed(1)
              else
                local zud = {
                  13,
                  16,
                  17
                }
                u:animeact(zud[GetRandomInt(1, #zud)])
                u:animespeed(1)
              end
            elseif u:hasdata("青水皮肤-茉子") then
              u:animeact(3)
              u:animespeed(2)
              u:effectadd("Bfsmtx\\bfsm_luoxuanwan4.mdx", "right hend", 3)
            else
              u:effectadd("Bfsmtx\\bfsm_luoxuanwan4.mdx", "right hend", 1)
              u:animeact(53)
              u:animespeed(2.2)
              ac.wait(750, function()
                u:animeact(52)
                u:animespeed(1)
              end)
            end
            u:shockcamera(100, 0.1)
            if u:hasdata("波风水门皮肤") then
              EffectcreateArgs({
                effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
                x = dx1,
                y = dy1,
                size = 1,
                height = 0,
                zxz = jd,
                animespeed = 1
              })
              EffectcreateArgs({
                effect = "Bfsmtx\\bfsmpf_fls_shunyi1.mdx",
                x = dx1,
                y = dy1,
                size = 2,
                height = 0,
                zxz = jd,
                animespeed = 1
              })
            else
              EffectcreateArgs({
                effect = "Bfsmtx\\bfsm_fls_shanguang3.mdx",
                x = dx1,
                y = dy1,
                size = GetRandomReal(2, 3),
                height = 0,
                zxz = jd,
                animespeed = 1
              })
              EffectcreateArgs({
                effect = "Bfsmtx\\bfsm_fls_shanguang2.mdx",
                x = dx1,
                y = dy1,
                size = 1,
                height = 250,
                zxz = jd,
                animespeed = 1
              })
            end
            unitmove({
              unit = u.handle,
              time = 0.1,
              distance = 800,
              angle = jd,
              isfly = true,
              endfunc = function(ax, ay)
                u:setdata("位移点X", ax)
                u:setdata("位移点Y", ay)
                IssueImmediateOrder(u.handle, "stop")
                for _, xq in ac.selector():in_rangexy(ax, ay, 350):is_enemy(u.handle):isnotingroup(g):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(g)
                  if xq:isboss() then
                    xq:setdata("波风水门-连招中")
                  end
                  xq:buffset(u.handle, 6, "沉默")
                end
                local jl1 = 500
                if cs < 4 then
                  jl1 = 200
                end
                ForGroupLuaNew(g, function(xq)
                  local dx3, dy3 = PolarXY(ax, ay, jl1, jd)
                  xq:setxy(dx3, dy3)
                  u:setdata("波风水门-一式附伤")
                  bfsmdamage({
                    u = u,
                    xq = xq,
                    damage = 4 * bs,
                    bufftime = 4,
                    bufftype = "暂停"
                  })
                end)
              end,
              isblink = true
            })
          end)
        end)
        if 4 <= cs then
          if u:hasdata("青水皮肤-茉子") then
            ac.wait(500, function()
              PlayGlobalSound(yxz[3])
              ac.wait(2000, function()
                PlayGlobalSound(yxz[4])
              end)
            end)
          end
          ac.wait(700, function()
            if u:hasdata("青水皮肤-茉子") then
              u:animeact(8)
              u:animespeed(0.25)
              ac.wait(2000, function()
                u:animespeed(1)
              end)
            end
          end)
          ac.wait(1200, function()
            if not u:hasdata("青水皮肤-茉子") then
              u:animespeed(1)
            end
            ac.wait(1250, function()
              if u:hasdata("青水皮肤-茉子") then
              else
                u:animeact(8)
                u:animespeed(1)
              end
            end)
            if not u:hasdata("青水皮肤-茉子") then
              PlayGlobalSound(yxz[3])
              ac.wait(2000, function()
                PlayGlobalSound(yxz[4])
              end)
            end
            u:shockcamera(100, 1.9)
            ac.wait(2100, function()
              u:shockcamera(300, 0.3)
            end)
            local dx, dy = u:getxy()
            local dx1, dy1 = PolarXY(dx, dy, 600, jd)
            dx, dy = PolarXY(dx, dy, 500, jd)
            local dx2, dy2 = PolarXY(dx, dy, 1000, GetRandomAngle())
            local zf = ""
            local zf1 = ""
            if u:hasdata("波风水门皮肤") then
              zf = "Bfsmtx\\Mz_New_01.mdx"
              zf1 = "Bfsmtx\\bfsmpf_baozha2.mdx"
              local cs1 = 0
              local cs = 0
              ac.loop(100, function(t1)
                cs = cs + 1
                cs1 = cs1 + 1
                EffectcreateArgs({
                  effect = "Bfsmtx\\bfsmpf_luoxuanwan3.mdx",
                  x = dx,
                  y = dy,
                  size = cs1 * 0.3,
                  height = -10 * cs1,
                  zxz = GetRandomAngle(),
                  animespeed = 4
                })
                if 20 <= cs then
                  t1:remove()
                end
              end)
            else
              zf = "Bfsmtx\\bfsm_luoxuanwan4.mdx"
              zf1 = "Bfsmtx\\bfsm_xiazha4.mdx"
            end
            for i = 1, 2 do
              local tx = EffectcreateArgs({
                effect = zf,
                x = dx,
                y = dy,
                time = 2,
                size = 1,
                height = 400,
                zxz = jd,
                animespeed = GetRandomReal(0.5, 3)
              })
              local tx1 = EffectcreateArgs({
                effect = zf1,
                x = dx,
                y = dy,
                time = 2,
                size = 0.1,
                height = 0,
                zxz = jd,
                yxz = 90,
                animespeed = 4
              })
              local cs1 = 0
              ac.loop(10, function(t1)
                cs1 = cs1 + 1
                if u:hasdata("青水皮肤-茉子") then
                  japi.EXSetEffectSize(tx, cs1 * 0.025)
                  japi.EXSetEffectZ(tx, cs1 * 3)
                  japi.EXSetEffectSize(tx1, cs1 * 0.02)
                else
                  japi.EXSetEffectSize(tx, cs1 * 0.3)
                  japi.EXSetEffectZ(tx, 400 + cs1 * 2)
                  japi.EXSetEffectSize(tx1, cs1 * 0.02)
                end
                if 200 <= cs1 then
                  if u:hasdata("波风水门皮肤") then
                    local tx2 = EffectcreateArgs({
                      effect = "Bfsmtx\\bfsmpf_baozha4_C.mdx",
                      x = dx,
                      y = dy,
                      time = 0,
                      size = 2.5,
                      height = 0,
                      zxz = jd,
                      animespeed = 3
                    })
                    EffectcreateArgs({
                      effect = "Bfsmtx\\bfsmpf_baozha3.mdx",
                      x = dx,
                      y = dy,
                      time = 1,
                      size = 7,
                      height = 0,
                      zxz = jd,
                      animespeed = 3
                    })
                    EffectcreateArgs({
                      effect = "Bfsmtx\\bfsmpf_baozha5.mdx",
                      x = dx,
                      y = dy,
                      size = 2,
                      height = 100,
                      zxz = jd,
                      animespeed = 3
                    })
                  else
                    EffectcreateArgs({
                      effect = "Bfsmtx\\bfsm_xiazha2.mdx",
                      x = dx,
                      y = dy,
                      size = 7,
                      height = 0,
                      zxz = jd,
                      animespeed = 3
                    })
                  end
                  t1:remove()
                end
              end)
            end
            ac.wait(100, function()
              ResetToGameCameraForPlayer(u.owner, 0)
              local p = getplayer(u.owner)
              p:setcameraheight(Cam_height[u.ownerid], 0)
            end)
            for _, xq in ac.selector():in_rangexy(dx, dy, 1500):is_enemy(u.handle):isnotingroup(g):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g)
              if xq:isboss() then
                xq:setdata("波风水门-连招中")
              end
              xq:buffset(u.handle, 3, "沉默")
            end
            local cs2 = 0
            ac.loop(100, function(t1)
              cs2 = cs2 + 1
              ForGroupLuaNew(g, function(xq)
                bfsmdamage({
                  u = u,
                  xq = xq,
                  damage = lxwbl * bs,
                  bufftime = 2,
                  bufftype = "暂停",
                  type = "灵力"
                })
              end)
              if 20 <= cs2 then
                ForGroupLuaNew(g, function(xq)
                  xq:deldata("波风水门-连招中")
                  u:setdata("波风水门-一式斩杀附伤")
                  bfsmdamage({
                    u = u,
                    xq = xq,
                    damage = 10 * bs,
                    bufftime = 2,
                    bufftype = "暂停"
                  })
                  xq:animeact("death")
                end)
                u:deldata("波风水门-零式发动中")
                t1:remove()
              end
            end)
            if u:hasdata("波风水门皮肤") then
            else
              local cs3 = 0
              local xtx = "Bfsmtx\\bfsm_xiazha1.mdx"
              if u:hasdata("青水皮肤-茉子") then
                xtx = "Bfsmtx\\bfsm_xiazha1fs.mdx"
              end
              ac.loop(100, function(t2)
                cs3 = cs3 + 1
                EffectcreateArgs({
                  effect = xtx,
                  x = dx1,
                  y = dy1,
                  size = 5,
                  height = 100,
                  zxz = jd,
                  yxz = -90,
                  animespeed = 1
                })
                if 2 <= cs3 then
                  t2:remove()
                end
              end)
            end
          end)
          t:remove()
        end
      end)
    end)
  end,
  SDR2 = function(u)
    local skillstr = "SDR"
    local x, y = u:getxy()
    local x1 = u:getdata("波风水门-X")
    local y1 = u:getdata("波风水门-Y")
    local jd = AngleXY(x, y, x1, y1)
    local g = CreateGroupLua()
    local bs = 1
    local zu = u:getdata("波风水门-飞雷神苦无组")
    u:buffset(u.handle, 0.6, "暂停")
    u:buffset(u.handle, 0.6, "永恒")
    u:buffset(u.handle, 0.6, "绝对闪避")
    u:setdata("波风水门-零式发动中")
    u:setdata("波风水门-奥义充能值", 0)
    ac.wait(1, function()
      u:animeact(11)
      if u:hasdata("茉子-兽化状态") then
        u:animeact("attack")
      end
      u:animespeed(1)
    end)
    unitjump({
      unit = u.handle,
      time = 0.7,
      distance = 500,
      height = 500,
      angle = jd + 180
    })
    u:playsound(Roland_Duralandal_Up)
    u:playsound(mzay_dg)
    local snd = Mozi_Aoyi_01
    if GetRandom100(50) then
      snd = Mozi_Aoyi_02
    end
    if u:hasdata("茉子-兽化状态") then
      local yxz = {
        Mozi_Wang_01,
        Mozi_Wang_02,
        Mozi_Wang_03
      }
      snd = yxz[GetRandomInt(1, #yxz)]
    end
    PlayGlobalSound(snd)
    local height = 800
    local flydis = 1800
    ac.wait(100, function()
      local tx = EffectcreateArgs({
        effect = "mz\\mzay_jq.mdx",
        x = x,
        y = y,
        time = 0.3,
        size = 3,
        height = 400,
        zxz = jd,
        animespeed = 1
      })
      effectmove({
        effect = tx,
        time = 0.3,
        distance = flydis,
        angle = jd,
        loops = {
          {
            looptime = 0.02,
            func = function(ax, ay)
              for _, xq in ac.selector():in_rangexy(ax, ay, 300):is_enemy(u.handle):isnotingroup(g):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g)
                bfsmdamage({
                  u = u,
                  xq = xq,
                  damage = 2 * bs,
                  bufftime = 8,
                  bufftype = "暂停"
                })
                xq:buffset(u.handle, 8, "沉默")
                if xq:isboss() then
                  xq:setdata("波风水门-连招中")
                end
              end
              ForGroupLuaNew(g, function(xq)
                xq:setxy(ax, ay)
              end)
            end
          }
        },
        endfunc = function(ax, ay)
          ForGroupLuaNew(g, function(xq)
            xq:setxy(ax, ay)
          end)
        end
      })
      ac.wait(300, function()
        if Group_Counts(g) > 0 then
          u:shockcamera(300, 0.2)
          u:playsound(mzay_baozha1)
          CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 3, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 0.0, 0.0, 0.0, 0.0)
        end
      end)
    end)
    ac.wait(400, function()
      if Group_Counts(g) == 0 then
        u:deldata("波风水门-零式发动中")
        return
      end
      SetCameraTargetControllerNoZForPlayer(u.owner, u.handle, 0, 0, false)
      local dt = 0.3
      local start_angle = 90
      local cs = 0
      local max = 7
      local dis = 1000
      local dtime = 1.35 + dt * max
      u:buffset(u.handle, dtime + 1.2, "暂停")
      u:buffset(u.handle, dtime + 2.2, "永恒")
      u:buffset(u.handle, dtime + 2.2, "绝对闪避")
      local dx, dy = PolarXY(x, y, flydis, jd)
      ac.wait(1, function()
        EffectcreateArgs({
          effect = "mz\\mzay_baozha4.mdx",
          x = dx,
          y = dy,
          size = 3,
          height = -10,
          zxz = jd,
          animespeed = 0.5
        })
        EffectcreateArgs({
          effect = "mz\\mzay_baozha3.mdx",
          x = dx,
          y = dy,
          size = 4,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "mz\\mzay_yhs.mdx",
          x = dx,
          y = dy,
          size = 5,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
        for i = 1, 3 do
          EffectcreateArgs({
            effect = "mz\\mzay_xl.mdx",
            x = dx,
            y = dy,
            time = dtime,
            size = 1,
            height = height,
            zxz = jd,
            animespeed = 1
          })
        end
      end)
      ac.wait(850, function()
        local tx = EffectcreateArgs({
          effect = "Bfsmtx\\bfsmpf_tuowei1.mdx",
          x = x,
          y = y,
          time = -1,
          size = 3,
          height = 100,
          zxz = jd,
          animespeed = 3
        })
        if type(japi.EXSetEffectFogVisible) == "function" then
          japi.EXSetEffectFogVisible(tx, true)
        end
        if type(japi.EXSetEffectMaskVisible) == "function" then
          japi.EXSetEffectMaskVisible(tx, true)
        end
        local musiccount = 0
        local step_angle = 720 / max
        ac.loop(dt * 1000, function(t)
          cs = cs + 1
          musiccount = musiccount + 1
          if musiccount == 6 then
            musiccount = 1
          end
          if cs > max then
            cs = 1
          end
          local jd2 = (start_angle + (cs - 1) * step_angle) % 360
          local snd = _G["mzay_cs" .. musiccount]
          if snd then
            u:playsound(snd)
          end
          local dx1, dy1 = PolarXY(dx, dy, 1000, jd2)
          japi.EXSetEffectXY(tx, dx1, dy1)
          u:setxy(dx1, dy1)
          for _, xq in ac.selector():in_rangexy(dx, dy, 800):is_enemy(u.handle):isnotingroup(g):ipairs() do
            xq = getunit(xq)
            xq:groupadd(g)
            if xq:isboss() then
              xq:setdata("波风水门-连招中")
            end
          end
          ForGroupLuaNew(g, function(xq)
            u:setdata("波风水门-一式附伤")
            bfsmdamage({
              u = u,
              xq = xq,
              damage = 2 * bs,
              bufftime = 7,
              bufftype = "暂停"
            })
            xq:buffset(u.handle, 5, "沉默")
          end)
          EffectcreateArgs({
            effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
            x = dx1,
            y = dy1,
            time = 0.5,
            size = 1,
            height = 0,
            zxz = jd,
            animespeed = 1
          })
          EffectcreateArgs({
            effect = "Bfsmtx\\bfsmpf_fls_shunyi1.mdx",
            x = dx1,
            y = dy1,
            size = 2,
            height = 0,
            zxz = jd,
            animespeed = 1
          })
          local loc = Location(dx1, dy1)
          local heiadd = GetLocationZ(loc)
          RemoveLocation(loc)
          local fls = Effectcreate(u:getdata("波风水门-飞镖模型1"), dx1, dy1, -1, 1.75, 50 + heiadd, jd)
          flsshow(fls)
          SetData(fls, "飞雷神苦无-消失时间", 60)
          table.insert(zu, fls)
          u:setface(jd2 + 180)
          if cs == max then
            ac.wait(dt * 1000, function()
              local fx, fy = dx, dy
              EffectcreateArgs({
                effect = "Bfsmtx\\bfsmpf_shunyi1.mdx",
                x = fx,
                y = fy,
                time = 0.5,
                size = 1,
                height = 0,
                zxz = jd,
                animespeed = 1
              })
              EffectcreateArgs({
                effect = "Bfsmtx\\bfsmpf_fls_shunyi1.mdx",
                x = fx,
                y = fy,
                size = 2,
                height = 0,
                zxz = jd,
                animespeed = 1
              })
              u:setxy(fx, fy)
              u:setface(jd)
              unitjump({
                unit = u.handle,
                time = 0.7,
                distance = 1000,
                height = 500,
                angle = jd + 180
              })
              u:animeact(5)
              DestroyEffectLua(tx)
            end)
            t:remove()
          end
        end)
      end)
      ac.wait(dtime * 1000, function()
        EffectcreateArgs({
          effect = "mz\\mzay_xl2.mdx",
          x = dx,
          y = dy,
          size = 10,
          height = height,
          zxz = jd,
          animespeed = 0.5
        })
        u:playsound(mzay_baozha1)
        local snd = Mozi_Aoyi_04
        if GetRandom100(50) then
          snd = Mozi_Aoyi_05
        end
        if u:hasdata("茉子-兽化状态") then
          local yxz = {
            Mozi_Wang_01,
            Mozi_Wang_02,
            Mozi_Wang_03
          }
          snd = yxz[GetRandomInt(1, #yxz)]
        end
        PlayGlobalSound(snd)
      end)
      ac.wait((dtime + 0.8) * 1000, function()
        u:playsound(mzay_baozha2)
        ac.wait(100, function()
          ResetToGameCameraForPlayer(u.owner, 0)
          local p = getplayer(u.owner)
          p:setcameraheight(Cam_height[u.ownerid], 0)
        end)
      end)
      ac.wait((dtime + 1) * 1000, function()
        u:playsound(mzay_baozha3)
        u:playsound(mzay_baozha4)
        EffectcreateArgs({
          effect = "mz\\mzay_baozha3.mdx",
          x = dx,
          y = dy,
          size = 10,
          height = height * 0.8,
          zxz = jd,
          animespeed = 0.5
        })
        EffectcreateArgs({
          effect = "mz\\mzay_baozha2.mdx",
          x = dx,
          y = dy,
          size = 3,
          height = height * 0.8,
          zxz = jd,
          animespeed = 1
        })
        EffectcreateArgs({
          effect = "mz\\mzay_baozha4.mdx",
          x = dx,
          y = dy,
          size = 2,
          height = 10,
          zxz = jd,
          animespeed = 0.5
        })
        for i = 1, 4 do
          EffectcreateArgs({
            effect = "mz\\mzay_yh2.mdx",
            x = dx,
            y = dy,
            size = 4,
            height = 0,
            zxz = GetRandomAngle(),
            animespeed = 0.4
          })
        end
        u:shockcamera(500, 0.2)
        u:settimedata("波风水门-茉子-奥义变招判定", 5)
        ForGroupLuaNew(g, function(xq)
          xq:deldata("波风水门-连招中")
          u:setdata("波风水门-一式斩杀附伤")
          bfsmdamage({
            u = u,
            xq = xq,
            damage = 10 * bs,
            bufftime = 2,
            bufftype = "暂停"
          })
          xq:animeact("death")
        end)
        u:deldata("波风水门-零式发动中")
      end)
    end)
  end
}
return zgskill
