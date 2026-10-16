-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local slk = require("jass.slk")
local skill = {
  {
    name = "瞄准弱点",
    skill = "A1P6",
    func = function(self, args)
      local u = getunit(args.unit)
      local skill = self.skill
      local x, y = u:getxy()
      local x2 = args.x
      local y2 = args.y
      local function trace(stage)
        local dx, dy = u:getxy()
        require("hera_boot").note("AZUSA Z " .. tostring(ac.clock()) .. " " .. stage .. " unit=" .. tostring(u.handle) .. " x=" .. tostring(dx) .. " y=" .. tostring(dy) .. " target=" .. tostring(x2) .. "," .. tostring(y2) .. " gun=" .. tostring(u:getdata("装备枪支")), true)
      end
      trace("BEGIN")
      local sy = u.ownerid
      local angle = AngleXY(x, y, x2, y2)
      local dis = DistanceXY(x, y, x2, y2)
      if u:hasbuff("缠绕") then
        u:setskillcd(self.skill, 0.01)
        u:sendmessage("|cFFFF3300缠绕中|r")
        return
      end
      local tl = 1
      if u:lossstamina(tl) then
      else
        u:setskillcd(self.skill, 0.01)
        u:sendmessage("|cFFFF3300体力值不足|r")
        if not u:hasdata("技能释放失败") then
          u:settimedata("技能释放失败", 0.05)
        end
        return
      end
      u:buffset(u.handle, 0.2, "绝对闪避")
      local gun = u:getdata("装备枪支")
      local guntype = GetItemTypeId(gun)
      local lx = GetData(guntype, "枪械类型")
      if u:hasdata("白洲梓-战略整装") then
        local str = "换弹"
        if lx == 1 then
          str = "双持"
        end
        if lx == 4 then
          str = "霰弹"
        end
        u:setdata("系统-立刻装填")
        reloadGun(u.handle, str)
        u:deldata("系统-立刻装填")
      end
      ac.wait(1, function()
        trace("MOVE BEGIN")
        u:animeact(4)
        u:animespeed(5)
        ac.timer(50, 6, function()
          local dx, dy = u:getxy()
          Effectcreate("war3mapImported\\specialanimedustwave.mdx", dx, dy)
          for _, xq in ac.selector():in_rangexy(dx, dy, 225):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:buffset(u.handle, 1.5, "眩晕")
            xq:effectadd("Abilities\\Weapons\\BallistaMissile\\BallistaImpact.mdl")
            unitmove({
              unit = xq.handle,
              time = 0.8,
              distance = 200,
              angle = AngleBetweenUnits(u.handle, xq.handle)
            })
          end
        end)
        unitmove({
          unit = u.handle,
          time = 0.2,
          distance = 450,
          angle = angle + 180
        })
      end)
      ac.wait(150, function()
        trace("SHOT PREPARE")
        u:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "hand", 2)
        u:settimedata("白洲梓-瞄准弱点伤害提升", 2)
        local b = true
        local dskill = S2ID("A008")
        if lx == 1 or lx == 2 or lx == 5 then
          b = false
        end
        if lx == 3 then
          dskill = S2ID("A034")
        end
        if lx == 4 then
          dskill = S2ID("A02J")
        end
        trace("GUNSHOT BEGIN")
        gunshoot(u.handle, dskill, x2, y2, b)
        trace("GUNSHOT END")
      end)
      ac.wait(300, function()
        u:animespeed(1)
        trace("END")
      end)
    end
  },
  {
    name = "Sagitta",
    skill = "A1P7",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local x2, y2
      x2 = args.x
      y2 = args.y
      ac.wait(1, function()
        u:animeact("attack")
      end)
      if u:hasdata("语音-白洲梓") and not u:hasdata("白洲梓-技能语音冷却") then
        u:settimedata("白洲梓-技能语音冷却", 5)
        local yxz = {
          Sound_Bzz_Skill_1,
          Sound_Bzz_Skill_2,
          Sound_Bzz_Skill_3
        }
        local snd = yxz[GetRandomInt(1, #yxz)]
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
      u:playsound(QS_R)
      local x1, y1 = u:getxy()
      local jd = AngleXY(x1, y1, x2, y2)
      local txsh = 2500 * u:getlevel()
      unifycreate({
        owner = u.handle,
        model = "war3mapImported\\Sinon01_32.mdl",
        modelname = "白洲梓-射手弹",
        modelsize = 2,
        height = 120,
        damage = txsh,
        damagetype = 1,
        x = x1,
        y = y1,
        range = 2800,
        speed = 4500,
        volume = 110,
        angle = jd,
        angleoffset = 0,
        attenua = 1,
        attenuacount = 999,
        life = 10,
        isbullet = true,
        isvest = false,
        isignorearmor = false,
        startfunc = function(mj)
          ammuadd(u.handle, u:getdata("装备枪支"), mj.handle)
          mj:setdata("循环计数", 0)
        end,
        loopfunc = function(mj)
          mj:changedata("循环计数", UnifyDT)
          if mj:getdata("循环计数") >= 0.03 then
            mj:setdata("循环计数", 0)
            Bulletloopfunc(mj)
          end
        end
      })
    end
  },
  {
    name = "严苛训练",
    skill = "A09O",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      if u:hasdata("语音-白洲梓") and not u:hasdata("白洲梓-技能语音冷却") then
        u:settimedata("白洲梓-技能语音冷却", 5)
        local yxz = {
          Sound_Bzz_Skill_1,
          Sound_Bzz_Skill_2,
          Sound_Bzz_Skill_3
        }
        local snd = yxz[GetRandomInt(1, #yxz)]
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
      ac.wait(1, function()
        u:animeact(16)
        u:animespeed(5)
      end)
      ac.wait(100, function()
        u:animespeed(1)
      end)
      if u:hasdata("白洲梓-战场技艺") then
        u:setskillcd("A1P6", 0)
      end
      local x, y = u:getxy()
      local x2 = args.x
      local y2 = args.y
      local angle = AngleXY(x, y, x2, y2)
      local distance = DistanceXY(x, y, x2, y2)
      local time = 1
      if u:hasdata("烫手山芋-爆炸立即") then
        time = 0.02
      end
      effectjump({
        effect = Effectcreate("war3mapImported\\Thing_Shoulei.mdl", x, y, 1),
        time = time,
        distance = distance,
        height = 500,
        angle = angle,
        endfunc = function()
          for i = 1, 8 do
            local x2, y2 = PolarXY(x2, y2, 150, i * 45)
            Effectcreate("Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl", x2, y2)
          end
          local txsh = 15000
          local dxs = Damage_Touzhiwu[sy]
          local fw = 375
          for _, xq in ac.selector():in_rangexy(x2, y2, fw):ipairs() do
            xq = getunit(xq)
            local dx, dy = xq:getxy()
            local xs = dxs + (fw - DistanceXY(dx, dy, x2, y2)) / fw
            if xq:is_enemy(u.handle) then
              local dtxsh
              if xq:isnormal() then
                dtxsh = 0.1 * xq:getmaxhp()
              else
                dtxsh = 0.01 * xq:gethp()
              end
              DamageUnit({
                bj = "白洲梓(机体)",
                unit = xq.handle,
                source = u.handle,
                damage = txsh * xs + dtxsh,
                type = "震荡"
              })
              xq:buffset(u.handle, 1, "眩晕")
              if u:hasdata("隐藏职业-无貌之人揭露") or u:hasdata("变异判定-奈亚子") then
                xq:buffset(u.handle, 1, "混乱")
              end
            else
              local dtxsh = 10 * xs
              LossHpUnit({
                u = u,
                tg = xq,
                damage = dtxsh,
                perhp = 0,
                maxhp = 0,
                bj = "[生命损耗]白洲梓手雷"
              })
              xq:buffset(u.handle, 0.5 * xs, "眩晕")
              flytext({
                unit = xq.handle,
                text = "-" .. math.floor(dtxsh) .. "%",
                size = 10,
                time = 0.5,
                r = 255,
                g = 0,
                b = 0
              })
            end
          end
        end
      })
    end
  },
  {
    name = "Intulit",
    skill = "A1PF",
    func = function(self, args)
      local u = getunit(args.unit)
      local sy = u.ownerid
      local tg
      local x, y = u:getxy()
      local x1 = args.x
      local y1 = args.y
      local angle = AngleXY(x, y, x1, y1)
      ac.wait(1, function()
        u:animeact(14)
        u:animespeed(2)
      end)
      u:buffset(u.handle, 0.2, "绝对闪避")
      local sh2 = 0
      local zbqz = u:getdata("装备枪支")
      local damagetype = "物理"
      if zbqz ~= ITEM_KONG and 0 < GetItemCharges(zbqz) then
        local guntype = GetItemTypeId(zbqz)
        local shxz = GetData(guntype, "伤害修正")
        local dylx = GetData(zbqz, "装备弹药")
        sh2 = GetData(guntype, "伤害")
        local count = GetData(dylx, "伤害阶级")
        if count == 4 or count == 0 then
          damagetype = "魔力"
        end
        if count == 6 then
          damagetype = "灵力"
        end
        if count == 5 then
          damagetype = "反物质"
        end
        if count == 1 then
          damagetype = "能量"
        end
        if count == 3 then
          damagetype = "震荡"
        end
        local lx = GetData(guntype, "枪械类型")
        sh2 = 5 * sh2 * shxz
        if lx == 3 then
          ChangeItemCount(zbqz, -5)
        else
          ChangeItemCount(zbqz, -1)
        end
        gunshowrefreesh(u.handle)
      end
      local sh = 5000 * u:getlevel() + sh2
      local sh3 = 2500 * u:getlevel()
      if u:hasdata("枪械-白洲梓-虚无步枪") then
        sh = sh * 1.5
        sh3 = sh3 * 1.5
      end
      if u:hasdata("语音-白洲梓") then
        local yxz = {
          Sound_Bzz_V_1,
          Sound_Bzz_V_2,
          Sound_Bzz_V_3
        }
        local snd = yxz[GetRandomInt(1, #yxz)]
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
          isallpeople = true,
          isneedseen = true
        })
      end
      u:playsound(bac1)
      do
        local x2, y2 = PolarXY(x, y, 900, angle)
        Effectcreate("war3mapImported\\bzx_bo2.mdx", x, y, 0, 2, 0, angle, 0, 0, 2)
        unitmove({
          unit = u.handle,
          time = 0.1,
          distance = 1000,
          angle = angle,
          isfly = true,
          loops = {
            {
              looptime = 0.01,
              func = function(dx, dy, args)
                for _, xq in ac.selector():in_rangexy(dx, dy, 200):is_enemy(u.handle):ipairs() do
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
              u:buffset(u.handle, 1.1, "暂停")
              u:buffset(u.handle, 1.1, "绝对闪避")
              u:buffset(u.handle, 1.5, "无敌")
              tg:buffset(u.handle, 3, "眩晕")
              u:playsound(bac149)
              u:shockcamera(70, 0.15)
              local x1, y1 = tg:getxy()
              Effectcreate("war3mapImported\\qiye_chongji1.mdl", x1, y1, 0, 2, 0, angle, 0, 0, 1)
              Effectcreate("war3mapImported\\chongci_Bo.mdl", x1, y1, 0, 1.5, 0, angle, 0, 0, 2)
              Effectcreate("war3mapImported\\bzx_bo1.mdl", x1, y1, 0, 5, 0, angle, 0, 0, 1)
              unitmove({
                unit = tg.handle,
                time = 0.1,
                distance = 500,
                angle = angle,
                isfly = true,
                endfunc = function(dx, dy)
                  unitmove({
                    unit = tg.handle,
                    time = 0.2,
                    distance = 100,
                    angle = angle,
                    isfly = true
                  })
                end
              })
              unitmove({
                unit = u.handle,
                time = 0.7,
                distance = 350,
                angle = angle + 180,
                isfly = true
              })
              ac.wait(1, function()
                u:animeact(11)
                u:animespeed(2)
              end)
              ac.wait(600, function()
                local dis = DistanceBetweenUnits(u.handle, tg.handle)
                local jd = AngleBetweenUnits(u.handle, tg.handle)
                local x, y = u:getxy()
                local dx, dy = PolarXY(x, y, 50, angle)
                local zy = 90 + math.atan(400 / dis)
                Effectcreate("war3mapImported\\bzx_xuli.mdl", dx, dy, 0, 0.4, 400, angle, 0, zy, 4)
              end)
              ac.wait(700, function()
                u:playsound(bac114)
                local dis = DistanceBetweenUnits(u.handle, tg.handle)
                local jd = AngleBetweenUnits(u.handle, tg.handle)
                local x, y = u:getxy()
                x = x + 100 * math.cos(angle + 180)
                u:setxy(x, y)
                u:shockcamera(100, 0.15)
                x, y = u:getxy()
                local dx, dy = PolarXY(x, y, dis * 0.7, angle)
                EffectcreateArgs({
                  effect = "war3mapImported\\bzx_zidan.mdl",
                  x = dx,
                  y = dy,
                  size = 2,
                  height = 180,
                  zxz = angle,
                  yxz = math.atan(400 / dis),
                  animespeed = 2
                })
                dx, dy = PolarXY(x, y, 50, angle)
                EffectcreateArgs({
                  effect = "war3mapImported\\bzx_chongci.mdl",
                  x = dx,
                  y = dy,
                  size = 1,
                  height = 400,
                  zxz = angle,
                  yxz = math.atan(400 / dis),
                  animespeed = 1
                })
                EffectcreateArgs({
                  effect = "war3mapImported\\qiye_chongji1.mdl",
                  x = dx,
                  y = dy,
                  size = 2,
                  height = 400,
                  zxz = angle,
                  yxz = math.atan(400 / dis),
                  animespeed = 2
                })
                EffectcreateArgs({
                  effect = "war3mapImported\\bzx_zidan1.mdl",
                  x = dx,
                  y = dy,
                  size = 2,
                  height = 400,
                  zxz = angle,
                  yxz = 90 + math.atan(400 / dis),
                  animespeed = 4
                })
                local x2, y2 = tg:getxy()
                EffectcreateArgs({
                  effect = "war3mapImported\\Daji_Hong1.mdl",
                  x = x2,
                  y = y2,
                  size = 10,
                  height = 200,
                  zxz = angle
                })
                EffectcreateArgs({
                  effect = "war3mapImported\\Daji_Hong1.mdl",
                  x = x2,
                  y = y2,
                  size = 10,
                  height = 200,
                  zxz = angle
                })
                EffectcreateArgs({
                  effect = "war3mapImported\\qiye_baoxue2.mdl",
                  x = x2,
                  y = y2,
                  size = 1,
                  zxz = angle
                })
                dx, dy = PolarXY(x2, y2, 50, angle)
                tg:setxy(dx, dy)
                EffectcreateArgs({
                  effect = "war3mapImported\\qiye_nanaya_xue1.mdl",
                  x = dx,
                  y = dy,
                  size = 1,
                  zxz = angle
                })
                DamageUnit({
                  bj = "白洲梓(一切都是虚无)",
                  unit = tg.handle,
                  source = u.handle,
                  damage = sh,
                  level = 1,
                  type = damagetype,
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "无",
                  extradata = {
                    "白洲梓-死亡弹"
                  }
                })
                ac.wait(500, function()
                  ac.wait(100, function()
                    u:playseensound(bac186_C)
                  end)
                  ac.timer(100, 5, function()
                    u:shockcamera(100, 0.05)
                    local x2, y2 = tg:getxy()
                    local dx, dy = PolarXY(x2, y2, 10, angle)
                    Effectcreate("war3mapImported\\zhigui_daji5.mdl", dx, dy, 0, GetRandomReal(3, 5), -100, GetRandomAngle())
                    local b = true
                    if u:hasdata("白洲梓-死亡天使") then
                      b = false
                    end
                    DamageUnit({
                      bj = "白洲梓(一切都是虚无)",
                      unit = tg.handle,
                      source = u.handle,
                      damage = sh3,
                      level = 1,
                      type = "物理",
                      isvest = b,
                      isattack = false,
                      isnoarmor = false,
                      element = "无"
                    })
                  end)
                end)
              end)
            end
          end
        })
      end
    end
  }
}
return skill
