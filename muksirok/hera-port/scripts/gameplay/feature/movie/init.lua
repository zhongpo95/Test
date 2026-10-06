-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local slk = require("jass.slk")
local Shiki_Animation = {}
Shiki_Animation[0] = 1
Shiki_Animation[1] = 12
Shiki_Animation[2] = 2
Shiki_Animation[3] = 15
Shiki_Animation[4] = 1
Shiki_Animation[6] = 12
Shiki_Animation[7] = 2
Shiki_Animation[8] = 8
Shiki_Animation[9] = 15
Shiki_Animation[10] = 12
Shiki_Animation[11] = 2
Shiki_Animation[20] = 2
Shiki_Animation[21] = 9
Shiki_Animation[22] = 4
Shiki_Animation[23] = 8
Shiki_Animation[24] = 1
Shiki_Animation[25] = 7
Shiki_Animation[26] = 5
Shiki_Animation[27] = 14
Shiki_Animation[28] = 3
Shiki_Animation[29] = 15
Shiki_Animation[30] = 6
Shiki_Animation[31] = 4

local function ASound(s)
  PlaySoundByPath(s, 127)
end

function textjbchange(args)
  local text = args.text
  local strz = args.strz
  local strstart = args.strstart
  local strend = args.strend
  local time = args.time
  local wait = args.waittime or 0
  local shunxu = args.shunxu or 1
  local origintext = args.origintext
  local endtext = args.endtext
  local cs = 0
  local chars = {}
  for char, length in utf8Iter(strz) do
    table.insert(chars, char)
  end
  local len = #chars
  local dt = time / len
  ac.wait(wait * 1000, function()
    ac.timer(dt * 1000, len, function()
      cs = cs + 1
      ClearTextMessages()
      local dstr = ""
      if shunxu == 2 then
        for i = len - (cs - 1), len do
          dstr = dstr .. chars[i]
        end
      else
        for i = 1, cs do
          dstr = dstr .. chars[i]
        end
      end
      local az = ""
      if origintext then
        az = az .. origintext .. "\n"
      end
      az = az .. strstart .. dstr .. strend
      if endtext then
        az = az .. "\n" .. endtext
      end
      text:set_text(az)
      text:set_alpha(255)
    end)
  end)
end

local fadeOutTimer, fadeInTimer

local function stopFadeOut()
  if fadeOutTimer then
    fadeOutTimer:remove()
    fadeOutTimer = nil
  end
  if fadeInTimer then
    fadeInTimer:remove()
    fadeInTimer = nil
  end
end

function textjianyin(duration, text)
  duration = duration or 2
  stopFadeOut()
  local steps = 40
  local interval = duration / steps
  local alpha = 255
  local delta = alpha / steps
  fadeOutTimer = ac.loop(interval * 1000, function(timer)
    alpha = alpha - delta
    if alpha <= 0 then
      text:set_alpha(0)
      fadeOutTimer = nil
      timer:remove()
      return
    end
    text:set_alpha(math.floor(alpha))
  end)
end

function textjianxian(duration, text)
  duration = duration or 2
  stopFadeOut()
  local steps = 40
  local interval = duration / steps
  local alpha = 0
  local delta = 255 / steps
  text:set_alpha(0)
  fadeInTimer = ac.loop(interval * 1000, function(timer)
    alpha = alpha + delta
    if 255 <= alpha then
      text:set_alpha(255)
      fadeInTimer = nil
      timer:remove()
      return
    end
    text:set_alpha(math.floor(alpha))
  end)
end

local function hexToRGBA(hex)
  return {
    a = tonumber(hex:sub(1, 2), 16),
    r = tonumber(hex:sub(3, 4), 16),
    g = tonumber(hex:sub(5, 6), 16),
    b = tonumber(hex:sub(7, 8), 16)
  }
end

local function rgbaToHex(rgba)
  return string.format("%02X%02X%02X%02X", rgba.a, rgba.r, rgba.g, rgba.b)
end

local function lerp(a, b, t)
  return a + (b - a) * t
end

local function interpolateColor(from, to, alpha)
  return {
    a = math.floor(lerp(from.a, to.a, alpha)),
    r = math.floor(lerp(from.r, to.r, alpha)),
    g = math.floor(lerp(from.g, to.g, alpha)),
    b = math.floor(lerp(from.b, to.b, alpha))
  }
end

local currentColorTimer

local function stopColorGradient()
  if currentColorTimer then
    currentColorTimer:remove()
    currentColorTimer = nil
  end
end

function colorGradientText(textobj, colorList, duration, stepsPerSegment, loop)
  stopColorGradient()
  if #colorList < 2 then
    return
  end
  local rgbaList = {}
  for _, hex in ipairs(colorList) do
    table.insert(rgbaList, hexToRGBA(hex))
  end
  local segment = 1
  local step = 0
  local totalSegments = #rgbaList - 1
  local interval = duration / (stepsPerSegment * totalSegments)
  currentColorTimer = ac.loop(interval * 1000, function(timer)
    step = step + 1
    local t = step / stepsPerSegment
    local from = rgbaList[segment]
    local to = rgbaList[segment + 1]
    local col = interpolateColor(from, to, t)
    col.a = textobj:get_alpha() or 255
    local hexColor = rgbaToHex(col)
    textobj:set_color(hexColor)
    if step >= stepsPerSegment then
      step = 0
      segment = segment + 1
      if segment >= #rgbaList then
        if loop then
          segment = 1
        else
          timer:remove()
          currentColorTimer = nil
        end
      end
    end
  end)
end

MovieAct = {
  Atomic = function(u)
    local x, y = u:getxy()
    local jd = u:getface()
    local damage = 100000 + 1000 * u:getallattri()
    u:buffset(u.handle, 18, "暂停")
    u:buffset(u.handle, 18, "永恒")
    u:buffset(u.handle, 22, "无敌")
    u:buffset(u.handle, 22, "绝对闪避")
    local r = 50
    local g = 75
    local b = 75
    local h = 2200
    local nd = 12000
    local xs = 1
    SetTerrainFogExBJ(0, 2200, 12000, 1.0, r, g, b)
    Boolean_Fog_Change = true
    Movie_Boolean = true
    ForGroupLuaNew(Group_Monster, function(xq)
      xq:buffset(xq.handle, 22, "沉默")
      xq:buffset(xq.handle, 22, "暂停")
    end)
    ac.timer(30, 50, function()
      r = r + 0.2
      g = g - 1
      h = h - 20
      nd = nd - 80
      xs = xs + 0.02
      SetTerrainFogExBJ(0, h, nd, xs, r, g, b)
    end)
    ac.wait(1, function()
      u:animeact(1)
      u:animespeed(1)
    end)
    NPCChat({
      name = "|cFF9932CC希德·卡盖诺|r",
      chaticon = "Chat_Ay_Anying.tga",
      chattext = {
        {
          time = 0,
          text = "|cff821da1「将真正的最强 铭记于身吧」|r"
        },
        {
          time = 5.6,
          text = "|cff821da1「这即是我的最强之力」|r"
        },
        {
          time = 8.7,
          text = "|cff821da1「I……」|r"
        },
        {
          time = 10.3,
          text = "|cff821da1「Am……」|r"
        }
      }
    })
    musiccolortext({
      strz = {
        {
          str = "ATMOIC",
          time = 13.3,
          showtime = 1,
          fadetime = 1,
          staytime = 5,
          sx = 270,
          sy = 480,
          dx = 200
        }
      },
      colorstart = "FFFF1414",
      colorend = "FFA941DA"
    })
    PlaySoundByPath("Sound_Anying_Atmoic.mp3", 127)
    PlaySoundByPath("war3mapImported\\Sound_Atomic2.mp3", 127)
    ac.wait(0, function()
      local tx = EffectcreateArgs({
        effect = "war3mapImported\\anying_guangquan.mdx",
        x = x,
        y = y,
        time = 15.3,
        size = 1,
        height = 0,
        zxz = jd,
        animespeed = 0.5
      })
      local tx1 = EffectcreateArgs({
        effect = "war3mapImported\\anying_guangquan.mdx",
        x = x,
        y = y,
        time = 15.8,
        size = 1,
        height = 0,
        zxz = jd,
        animespeed = 0.5
      })
      local cs = 0
      ac.timer(10, 100, function()
        cs = cs + 1
        japi.EXSetEffectSize(tx, cs / 10)
        japi.EXSetEffectSize(tx1, cs / 10)
      end)
      for i = 1, 10 do
        ac.wait(5300, function()
          local tx2 = EffectcreateArgs({
            effect = "war3mapImported\\anying_guangquan.mdx",
            x = x,
            y = y,
            time = 10.5 + i * 0.04,
            size = 1,
            height = 0,
            zxz = GetRandomAngle(),
            animespeed = 0.5
          })
          local visibility = require("hera_effect_visibility").new(tx2, 1)
          visibility:set_visible(false)
          ac.wait(10000 + i * 40, function()
            visibility:set_visible(true)
          end)
          local cs1 = 0
          ac.timer(10, 100, function()
            cs1 = cs1 + 1
            visibility:set_size(cs1 / 10)
          end)
        end)
      end
    end)
    ac.wait(5300, function()
      PlaySoundByPath("war3mapImported\\Sound_Atomic.mp3", 127)
      ac.wait(3500, function()
        ac.timer(10, 5, function()
          EffectcreateArgs({
            effect = "war3mapImported\\anying_xuli.mdx",
            x = x,
            y = y,
            size = GetRandomReal(1, 10),
            height = 100,
            zxz = GetRandomAngle(),
            animespeed = GetRandomReal(1, 2)
          })
        end)
        ac.wait(1000, function()
          local cs = 0
          ac.timer(100, 25, function()
            cs = cs + 1
            EffectcreateArgs({
              effect = "war3mapImported\\anying_xuli.mdx",
              x = x,
              y = y,
              size = cs / 2,
              height = 100,
              zxz = GetRandomAngle(),
              animespeed = 1 + cs / 10
            })
          end)
        end)
      end)
      ac.wait(7000, function()
        ac.wait(0, function()
          local qxphoto = class.panel:builder({
            parent = OriginPanel,
            x = 0,
            y = 0,
            w = 1920,
            h = 850,
            normal_image = "Touming.tga"
          })
          local a = 155
          qxphoto:set_alpha(a)
          local c = 0
          ac.loop(70, function(timer)
            if c < 29 then
              c = c + 1
              qxphoto:set_normal_image("Ph_Anying (" .. c .. ").tga")
            else
              ac.loop(30, function(timer2)
                a = a - 2
                qxphoto:set_alpha(a)
                if a <= 10 then
                  qxphoto:destroy()
                  timer2:remove()
                end
              end)
              timer:remove()
            end
          end)
        end)
      end)
      ac.wait(11500, function()
        ac.timer(30, 50, function()
          r = r - 0.2
          g = g + 1
          h = h + 20
          nd = nd + 80
          xs = xs - 0.02
          SetTerrainFogExBJ(0, h, nd, xs, r, g, b)
        end)
        ac.wait(1500, function()
          Movie_Boolean = false
          Boolean_Fog_Change = false
          if GetRandomInt(1, 2) == 1 then
            PlayBGM({
              bgm = BGM_Ay_10,
              time = 215,
              ID = 270,
              unit = u.handle
            })
          else
            PlayBGM({
              bgm = BGM_Ay_11,
              time = 220,
              ID = 270,
              unit = u.handle
            })
          end
        end)
        EffectcreateArgs({
          effect = "war3mapImported\\anying_guangzhu3.mdx",
          x = x,
          y = y,
          size = 10,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
        local tx = EffectcreateArgs({
          effect = "war3mapImported\\anying_baozha3.mdx",
          x = x,
          y = y,
          time = 1,
          size = 4,
          height = 0,
          zxz = jd,
          animespeed = 1
        })
        ac.wait(300, function()
          japi.EXSetEffectSize(tx, 10)
          japi.EXSetEffectZ(tx, -600)
        end)
        ac.wait(500, function()
          EffectcreateArgs({
            effect = "war3mapImported\\anying_guangzhu3.mdx",
            x = x,
            y = y,
            size = 40,
            height = 0,
            zxz = jd,
            animespeed = 1
          })
          EffectcreateArgs({
            effect = "war3mapImported\\anying_baozha5.mdx",
            x = x,
            y = y,
            time = 0.6,
            size = 30,
            height = 1500,
            zxz = jd,
            animespeed = 1
          })
          EffectcreateArgs({
            effect = "war3mapImported\\anying_baozha8.mdx",
            x = x,
            y = y,
            time = 0.4,
            size = 30,
            height = 1000,
            zxz = jd,
            animespeed = 1
          })
        end)
        ac.wait(800, function()
          EffectcreateArgs({
            effect = "war3mapImported\\anying_guangzhu2.mdx",
            x = x,
            y = y,
            time = 3,
            size = 1,
            height = 0,
            zxz = jd,
            animespeed = 1
          })
          ac.wait(300, function()
            u:shockcamera(1000, 0.1)
            ac.wait(100, function()
              u:shockcamera(100, 3)
            end)
            EffectcreateArgs({
              effect = "war3mapImported\\anying_baozha6.mdx",
              x = x,
              y = y,
              size = 2,
              height = 0,
              zxz = jd,
              animespeed = 1
            })
            EffectcreateArgs({
              effect = "war3mapImported\\anying_guangzhu2.mdx",
              x = x,
              y = y,
              time = 3,
              size = 10,
              height = 0,
              zxz = jd,
              animespeed = 1
            })
            EffectcreateArgs({
              effect = "war3mapImported\\anying_baozha7.mdx",
              x = x,
              y = y,
              size = 4,
              height = 0,
              zxz = jd,
              animespeed = 1
            })
            EffectcreateArgs({
              effect = "war3mapImported\\anying_guangzhu4.mdx",
              x = x,
              y = y,
              time = 3,
              size = 10,
              height = 0,
              zxz = jd,
              animespeed = 1
            })
          end)
        end)
        ac.wait(800, function()
          ac.timer(100, 30, function()
            for _, xq in ac.selector():in_rangexy(x, y, 3500):is_not(u.handle):ipairs() do
              xq = getunit(xq)
              DamageUnit({
                bj = "Atmoic",
                unit = xq.handle,
                source = u.handle,
                damage = damage,
                level = 5,
                type = "反物质",
                isvest = false,
                isattack = false,
                isnoarmor = false,
                element = "无",
                extradata = {
                  "Atomic固定伤害"
                }
              })
            end
          end)
        end)
      end)
    end)
  end,
  ["Hey维吉尔"] = function()
    local dt = getunit(Danwei_Dante)
    local ve = getunit(Danwei_Vergil)
    PlayBGM({
      bgm = 0,
      time = 230,
      ID = 268
    })
    PlayGlobalSound(Sound_Dmc_Hey)
    SendMsgAll("|cFF6699FF15 JUNE pm 04:04|r", 30)
    dt:chat("|cffc22f2fHey, Vergil your portal-opening days is over.")
    dt:chat("|cffc22f2fGive me the Yamato.", 4.7)
    ve:chat("|cFF6699FFIf you want it, then you will have to take it.", 6.7)
    ve:chat("|cFF6699FFBut you already knew that.", 13.3)
    dt:chat("|cffc22f2fI had a feeling you had say that...", 16.3)
    ve:chat("|cFF6699FFHow many times have we fought?", 21.3)
    dt:chat("|cffc22f2fHard to say.", 25.7)
    dt:chat("|cffc22f2fIt is the only memory I have of us since we were kids.", 27.5)
    dt:chat("|cffc22f2fTime to finish this, Vergil.", 37.3)
    dt:chat("|cffc22f2fOnce and for all.", 40.6)
    ac.wait(47000, function()
      PlayGlobalSound(BGM_Dmc_Hey)
    end)
  end,
  ["虚式茈"] = function(u)
    local caster = u
    local start_x, start_y = caster:getxy()
    local direction = caster:getface()
    local damage = 1000000
    
    local function set_camera_noise(value)
      for i = 1, 6 do
        CameraSetEQNoiseForPlayer(Player(i - 1), value)
      end
    end
    
    local function clear_camera_noise()
      for i = 1, 6 do
        CameraClearNoiseForPlayer(Player(i - 1))
      end
    end
    
    local function create_lightning(model, effect_x, effect_y, args)
      return EffectcreateArgs({
        effect = model,
        x = effect_x,
        y = effect_y,
        time = args.time,
        size = args.size,
        height = args.height,
        zxz = args.zxz,
        xxz = args.xxz,
        yxz = args.yxz,
        animespeed = args.speed
      })
    end
    
    PlayBGM({
      bgm = 0,
      time = 85,
      ID = 267,
      unit = u.handle
    })
    PlayGlobalSound(Sound_5t5xs_01)
    NPCChat({
      name = "|cFF6699FF五|r|cFF80A6F2条|r|cFF99B2E6悟|r",
      chaticon = "Chat_5t5.tga",
      chattext = {
        {
          text = "|cFF99B2E6没办法了|r",
          time = 0.17
        },
        {
          text = "|cFF99B2E6稍微乱来一下吧|r",
          time = 2
        }
      }
    })
    u:buffset(u.handle, 27, "永恒")
    u:buffset(u.handle, 30, "无敌")
    u:buffset(u.handle, 30, "绝对闪避")
    u:buffset(u.handle, 27, "暂停")
    FogEnable(false)
    FogMaskEnable(false)
    Boolean_Quantushiye = true
    ac.wait(5000, function()
      PlayGlobalSound(Sound_5t5xs_02)
      NPCChat({
        name = "|cFF6699FF五|r|cFF80A6F2条|r|cFF99B2E6悟|r",
        chaticon = "Chat_5t5.tga",
        chattext = {
          {
            text = "|cFF99B2E6术式顺转|r|cFF3366FF「苍」|r",
            time = 0.5
          },
          {
            text = "|cFF99B2E6术式反转|r|cFFCC0000「赫」|r",
            time = 3.3
          }
        }
      })
      ac.wait(2000, function()
        local effect_x, effect_y = PolarXY(start_x, start_y, 282, direction + 180)
        effect_x, effect_y = PolarXY(effect_x, effect_y, 282, direction + 90)
        local main_effect = EffectcreateArgs({
          effect = "war3mapImported\\d36ae7ecb73a5644.mdl",
          x = effect_x,
          y = effect_y,
          time = -1,
          size = 1.5,
          height = 200,
          animespeed = 1
        })
        set_camera_noise(30)
        local lightning_count = 0
        ac.loop(250, function(timer)
          lightning_count = lightning_count + 1
          local x2, y2 = GetEffectXY(main_effect)
          create_lightning("war3mapImported\\xushishandian_lan.mdx", x2, y2, {
            time = 2,
            size = 30,
            height = 200,
            speed = 2,
            zxz = direction + GetRandomReal(-180, 0)
          })
          if 36 <= lightning_count then
            timer:remove()
          end
        end)
        ac.wait(5000, function()
          local move_count = 0
          ac.loop(100, function(timer)
            move_count = move_count + 1
            local x2, y2 = GetEffectXY(main_effect)
            x2 = x2 - 5 * math.cos(direction + 90)
            y2 = y2 - 5 * math.sin(direction + 90)
            SetEffectXY(main_effect, x2, y2)
            if 55 <= move_count then
              timer:remove()
              DestroyEffectLua(main_effect)
            end
          end)
        end)
      end)
      ac.wait(4800, function()
        local effect_x, effect_y = PolarXY(start_x, start_y, 282, direction + 180)
        effect_x, effect_y = PolarXY(effect_x, effect_y, 282, direction - 90)
        local main_effect = EffectcreateArgs({
          effect = "war3mapImported\\51d1632b7607842f.mdl",
          x = effect_x,
          y = effect_y,
          time = -1,
          size = 1.5,
          height = 200,
          animespeed = 1
        })
        set_camera_noise(30)
        local lightning_count = 0
        ac.loop(250, function(timer)
          lightning_count = lightning_count + 1
          local x2, y2 = GetEffectXY(main_effect)
          create_lightning("war3mapImported\\xushishandian_hong.mdx", x2, y2, {
            time = 2,
            size = 30,
            height = 200,
            speed = 2,
            zxz = direction + GetRandomReal(0, 180)
          })
          if 24 <= lightning_count then
            timer:remove()
          end
        end)
        ac.wait(3000, function()
          local move_count = 0
          ac.loop(100, function(timer)
            move_count = move_count + 1
            local x2, y2 = GetEffectXY(main_effect)
            x2 = x2 - 5 * math.cos(direction - 90)
            y2 = y2 - 5 * math.sin(direction - 90)
            SetEffectXY(main_effect, x2, y2)
            if 45 <= move_count then
              timer:remove()
              DestroyEffectLua(main_effect)
            end
          end)
        end)
      end)
      ac.wait(5500, function()
        PlayGlobalSound(Sound_5t5xs_03)
        local effect_x, effect_y = PolarXY(start_x, start_y, 250, direction - 180)
        local main_effect
        ac.wait(2500, function()
          main_effect = EffectcreateArgs({
            effect = "war3mapImported\\ad6eac5f3e03c4d4.mdl",
            x = effect_x,
            y = effect_y,
            time = 6,
            size = 1,
            height = 380,
            animespeed = 1
          })
          local main_size = 1
          local main_height = 380
          set_camera_noise(20)
          local charge_count = 0
          ac.wait(1500, function()
            ac.loop(50, function(timer)
              charge_count = charge_count + 1
              if charge_count <= 10 then
                main_size = main_size + 0.3
                main_height = main_height + 10
                japi.EXSetEffectSize(main_effect, main_size)
                SetEffectHeight(main_effect, main_height)
              end
              local x2, y2 = GetEffectXY(main_effect)
              create_lightning("war3mapImported\\xushishandian.mdx", x2, y2, {
                time = 2,
                size = 30,
                height = 200,
                speed = 1,
                zxz = GetRandomAngle()
              })
              if 20 <= charge_count then
                timer:remove()
              end
            end)
          end)
        end)
        ac.wait(5000, function()
          set_camera_noise(200)
          flashphoto({
            photo = "ReplaceableTextures\\CameraMasks\\Black_mask.blp",
            timeout = 4,
            timehold = 0,
            timein = 4.5
          })
          local burst_count = 0
          ac.loop(20, function(timer)
            burst_count = burst_count + 1
            local x2, y2 = GetEffectXY(main_effect)
            create_lightning("war3mapImported\\xushishandian.mdx", x2, y2, {
              time = 2,
              size = 10,
              height = 300,
              speed = 30,
              xxz = GetRandomAngle(),
              yxz = GetRandomAngle(),
              zxz = GetRandomAngle()
            })
            if 20 <= burst_count then
              timer:remove()
            end
          end)
          ac.wait(2700, clear_camera_noise)
        end)
      end)
      ac.wait(8500, function()
        PlayGlobalSound(Sound_5t5xs_04)
        NPCChat({
          name = "|cFF6699FF五|r|cFF80A6F2条|r|cFF99B2E6悟|r",
          chaticon = "Chat_5t5.tga",
          chattext = {
            {
              text = "|cFF9966FF虚式|r",
              time = 3.8
            },
            {
              text = "|cFF9966FF「茈」|r",
              time = 8.2
            }
          }
        })
        ac.wait(1200, function()
          local qxphoto = class.panel:builder({
            parent = OriginPanel,
            x = 0,
            y = 0,
            w = 1920,
            h = 850,
            normal_image = "Touming.tga"
          })
          local a = 155
          qxphoto:set_alpha(a)
          local c = 12
          ac.loop(100, function(timer)
            if c < 69 then
              c = c + 1
              qxphoto:set_normal_image("Ph_5t5Xs (" .. c .. ").blp")
            else
              ac.loop(30, function(timer2)
                a = a - 2
                qxphoto:set_alpha(a)
                if a <= 10 then
                  qxphoto:destroy()
                  timer2:remove()
                end
              end)
              timer:remove()
            end
          end)
        end)
        ac.wait(13000, function()
          PlayGlobalSound(Sound_5t5xs_05)
          ac.wait(2000, function()
            PlayGlobalSound(Sound_5t5xs_B2)
          end)
        end)
      end)
      ac.wait(13000, function()
        local effect_x, effect_y = PolarXY(start_x, start_y, 350, direction)
        EffectcreateArgs({
          effect = "war3mapImported\\Xiaoyuan_Guang4.mdl",
          x = effect_x,
          y = effect_y,
          time = 6,
          size = 10,
          height = 200,
          animespeed = 1
        })
        local projectile = EffectcreateArgs({
          effect = "war3mapImported\\ad6eac5f3e03c4d4.mdl",
          x = effect_x,
          y = effect_y,
          time = -1,
          height = 200,
          animespeed = 0.15
        })
        local projectile_size = 0
        local projectile_height = 200
        local projectile_alive = true
        local movement_timer
        japi.EXSetEffectSize(projectile, projectile_size)
        
        local function stop_projectile()
          if not projectile_alive then
            return
          end
          projectile_alive = false
          if movement_timer then
            movement_timer:remove()
          end
          ac.wait(1500, function()
            FogEnable(true)
            FogMaskEnable(true)
            Boolean_Quantushiye = false
          end)
          DestroyEffectLua(projectile)
          clear_camera_noise()
        end
        
        ac.wait(20000, stop_projectile)
        local charge_count = 0
        ac.loop(250, function(timer)
          charge_count = charge_count + 1
          projectile_size = projectile_size + 0.12
          projectile_height = projectile_height + 3.5
          japi.EXSetEffectSize(projectile, projectile_size)
          SetEffectHeight(projectile, projectile_height)
          local x2, y2 = GetEffectXY(projectile)
          create_lightning("war3mapImported\\xushishandian.mdx", x2, y2, {
            time = 0.5,
            size = 30,
            height = 200,
            speed = 1,
            zxz = GetRandomAngle()
          })
          if 28 <= charge_count then
            timer:remove()
          end
        end)
        ac.wait(6000, function()
          ForGroupLuaNew(Group_Monster, function(xq)
            xq:buffset(xq.handle, 12, "暂停")
            xq:buffset(xq.handle, 12, "沉默")
            xq:buffset(xq.handle, 12, "僵直")
            xq:buffset(xq.handle, 12, "眩晕")
          end)
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if xq.handle ~= u.handle then
              xq:buffset(xq.handle, 5, "僵直")
              xq:buffset(xq.handle, 5, "缠绕")
            end
          end)
          local release_effect = EffectcreateArgs({
            effect = "war3mapImported\\5e0828f9edf6c748.mdl",
            x = start_x,
            y = start_y,
            time = -1,
            size = 5,
            zxz = direction,
            animespeed = 1
          })
          DestroyEffectLua(release_effect)
        end)
        ac.wait(7000, function()
          local burst_count = 0
          ac.loop(20, function(timer)
            burst_count = burst_count + 1
            local x2, y2 = GetEffectXY(projectile)
            create_lightning("war3mapImported\\xushishandian.mdx", x2, y2, {
              time = 1.5,
              size = 10,
              height = 200,
              speed = 30,
              xxz = GetRandomAngle(),
              yxz = GetRandomAngle(),
              zxz = GetRandomAngle()
            })
            if 30 <= burst_count then
              timer:remove()
            end
          end)
          ac.wait(2000, function()
            set_camera_noise(50)
            local lightning_interval = 0
            local playable_rect = RECT_PlayArea
            local v = 10
            local size = 2.5
            local ax, ay = GetEffectXY(projectile)
            movement_timer = ac.loop(30, function(timer)
              if not projectile_alive then
                timer:remove()
                return
              end
              lightning_interval = lightning_interval + 1
              local x2, y2 = GetEffectXY(projectile)
              v = v * 1.04
              size = size * 1.02
              v = math.min(75, v)
              size = math.min(15, size)
              x2, y2 = PolarXY(x2, y2, v, direction)
              SetEffectXY(projectile, x2, y2)
              for _, xq in ac.selector():in_rangexy(x2, y2, 650):is_not(u.handle):ipairs() do
                xq = getunit(xq)
                if xq:isingroup(Group_PlayHero) then
                  if xq:getperhp() <= 20 then
                    xq:losshp(u, 0, 0, 20)
                    xq:kill()
                  else
                    xq:losshp(u, 0, 0, 20)
                  end
                else
                  DamageUnit({
                    bj = "虚式茈",
                    unit = xq.handle,
                    source = u.handle,
                    damage = damage,
                    level = 5,
                    type = "反物质",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {
                      "虚式茈固定伤害"
                    }
                  })
                end
              end
              if lightning_interval == 2 then
                Effectcreate("war3mapImported\\specialanimedustwave.mdx", x2, y2, 0, 1 + size / 2, 0, direction)
              end
              if 3 <= lightning_interval then
                ForGroupLuaNew(Group_Monster, function(xq)
                  xq:buffset(xq.handle, 1, "暂停")
                  xq:buffset(xq.handle, 1, "沉默")
                end)
                ForGroupLuaNew(Group_PlayHero, function(xq)
                  if xq.handle ~= u.handle then
                    xq:buffset(xq.handle, 1.5, "僵直")
                    xq:buffset(xq.handle, 1.5, "缠绕")
                  end
                end)
                lightning_interval = 0
                create_lightning("war3mapImported\\xushishandian.mdx", x2, y2, {
                  time = 1,
                  size = 15,
                  height = -500,
                  speed = 1,
                  zxz = direction
                })
              end
              local impact_x, impact_y = PolarXY(x2, y2, -100, direction)
              create_lightning("war3mapImported\\xushizhendi.mdl", impact_x, impact_y, {
                time = 2,
                size = 3,
                height = 200,
                speed = 0.4,
                yxz = 90,
                zxz = direction
              })
              if not IsXYinRect(impact_x, impact_y, playable_rect) then
                EffectcreateArgs({
                  effect = "5t5_01.mdx",
                  x = impact_x,
                  y = impact_y,
                  time = 0,
                  size = 2.5,
                  height = 0
                })
                stop_projectile()
              end
            end)
          end)
        end)
      end)
    end)
  end,
  ["吊带袜天使"] = function(u)
    local u = getunit(Qiyue_Angel_Panty)
    local mb = getunit(Qiyue_Angel_Stocking)
    local sy = u.ownerid
    local sy2 = mb.ownerid
    u:setdata("潘迪-天使化")
    mb:setdata("史朵巾-天使化")
    u:addskill("A15V")
    mb:addskill("A15V")
    u:getgoddessforce(1, true)
    mb:getgoddessforce(1, true)
    ac.wait(5000, function()
      u:effectadd("ATX\\[ATxNew]Light_12.mdl", "origin", -1)
      mb:effectadd("ATX\\[ATxNew]Light_12.mdl", "origin", -1)
    end)
    local endsh = 0
    ac.loop(3000, function()
      ChangeValue(DamageSystem_EndSh, sy, 0.1 * -endsh)
      ChangeValue(DamageSystem_EndSh, sy2, 0.1 * -endsh)
      if u:isalive() and mb:isalive() then
        endsh = 0.1
      else
        endsh = 0
      end
      ChangeValue(DamageSystem_EndSh, sy, 0.1 * endsh)
      ChangeValue(DamageSystem_EndSh, sy2, 0.1 * endsh)
    end)
    PlayGlobalSound(Sound_AngelSis_Start)
    ac.wait(34000, function()
      if GetRandom100(50) then
        PlayGlobalSound(Sound_AngelSis_Japan)
        SendMsgAll("|cFFFFFF66「|r|cFFF4F06D彷|r|cFFE9E275徨|r|cFFDED37C于|r|cFFD3C583天|r|cFFC8B68A地|r|cFFBDA892间|r|cFFB39999的|r|cFFA88AA0迷|r|cFF9D7CA8途|r|cFF926DAF之|r|cFF875FB6子|r|cFF7C50BD」|r", 10)
        SendDtimeMsgAll(2.7, "|cFFFFFF66「|r|cFFF3EF6E诞|r|cFFE7E076生|r|cFFDCD07E于|r|cFFD0C085汝|r|cFFC4B18D心|r|cFFB8A195的|r|cFFAD919D邪|r|cFFA181A5恶|r|cFF9572AD之|r|cFF8962B4灵|r|cFF7E52BC」|r", 10)
        SendDtimeMsgAll(5.5, "|cFFFFFF66「|r|cFFF6F46C以|r|cFFEEE871附|r|cFFE6DD77着|r|cFFDDD27D于|r|cFFD4C682少|r|cFFCCBB88女|r|cFFC4B08E贴|r|cFFBBA493身|r|cFFB29999衣|r|cFFAA8E9F物|r|cFFA282A4之|r|cFF9977AA上|r|cFF906CB0的|r|cFF8860B5雷|r|cFF8055BB电|r|cFF774AC1」|r", 10)
        SendDtimeMsgAll(13.5, "|cFFFFFF66「|r|cFFF9F66A将|r|cFFF2EE6E所|r|cFFECE673有|r|cFFE6DD77污|r|cFFDFD47B秽|r|cFFD9CC80、|r|cFFD2C484泥|r|cFFCCBB88淖|r|cFFC6B28C、|r|cFFBFAA90渣|r|cFFB9A295滓|r|cFFB29999、|r|cFFAC909D余|r|cFFA688A2烬|r|cFF9F80A6，|r|cFF9977AA化|r|cFF936EAE灰|r|cFF8C66B2归|r|cFF865EB7于|r|cFF8055BB天|r|cFF794CBF地|r|cFF7344C4」|r", 10)
        SendDtimeMsgAll(18.1, "|cFFFFFF66「|r|cFFE9E275忏|r|cFFD3C583悔|r|cFFBDA892吧|r|cFFA88AA0！|r|cFF926DAF」|r", 10)
      else
        PlayGlobalSound(Sound_AngelSis_English)
        SendMsgAll("|cFFFFFF66「|r|cFFFBFA68O|r|cFFF8F56Bh|r|cFFF4F06D |r|cFFF0EB70p|r|cFFECE672i|r|cFFE9E175t|r|cFFE5DC77i|r|cFFE1D77Af|r|cFFDDD27Cu|r|cFFDACD7Fl|r|cFFD6C881 |r|cFFD2C384s|r|cFFCEBE86h|r|cFFCBB989a|r|cFFC7B48Bd|r|cFFC3AF8Eo|r|cFFC0AA90w|r|cFFBCA593 |r|cFFB8A095l|r|cFFB49B98o|r|cFFB1979As|r|cFFAD929Dt|r|cFFA98D9F |r|cFFA588A2i|r|cFFA283A4n|r|cFF9E7EA7 |r|cFF9A79A9t|r|cFF9774ACh|r|cFF936FAEe|r|cFF8F6AB1 |r|cFF8B65B3d|r|cFF8860B6a|r|cFF845BB8r|r|cFF8056BBk|r|cFF7C51BDn|r|cFF794CC0e|r|cFF7547C2s|r|cFF7142C5s|r|cFF6D3DC7」|r", 10)
        SendDtimeMsgAll(2.5, "|cFFFFFF66「|r|cFFFDFC68O|r|cFFFAF969h|r|cFFF8F66B |r|cFFF6F26Ce|r|cFFF3EF6Ev|r|cFFF1EC6Fi|r|cFFEFE971l|r|cFFECE673 |r|cFFEAE374s|r|cFFE7E076p|r|cFFE5DC77i|r|cFFE3D979r|r|cFFE0D67Ai|r|cFFDED37Ct|r|cFFDCD07E |r|cFFD9CD7Fb|r|cFFD7CA81o|r|cFFD5C782r|r|cFFD2C384n|r|cFFD0C085 |r|cFFCEBD87o|r|cFFCBBA89f|r|cFFC9B78A |r|cFFC7B48Ct|r|cFFC4B18Dh|r|cFFC2AD8Fo|r|cFFBFAA90s|r|cFFBDA792e|r|cFFBBA494 |r|cFFB8A195d|r|cFFB69E97r|r|cFFB49B98i|r|cFFB1979Af|r|cFFAF949Bt|r|cFFAD919Di|r|cFFAA8E9En|r|cFFA88BA0g|r|cFFA688A2 |r|cFFA385A3b|r|cFFA181A5e|r|cFF9E7EA6t|r|cFF9C7BA8w|r|cFF9A78A9e|r|cFF9775ABe|r|cFF9572ADn|r|cFF936FAE |r|cFF906BB0h|r|cFF8E68B1e|r|cFF8C65B3a|r|cFF8962B4v|r|cFF875FB6e|r|cFF855CB8n|r|cFF8259B9 |r|cFF8056BBa|r|cFF7E52BCn|r|cFF7B4FBEd|r|cFF794CBF |r|cFF7649C1e|r|cFF7446C3a|r|cFF7243C4r|r|cFF6F40C6t|r|cFF6D3CC7h|r|cFF6B39C9」|r", 10)
        SendDtimeMsgAll(6.3, "|cFFFFFF66「|r|cFFFDFC67M|r|cFFFBFA69a|r|cFFF9F76Ay|r|cFFF7F46B |r|cFFF5F26Dt|r|cFFF3EF6Eh|r|cFFF1EC6Fe|r|cFFEFEA71 |r|cFFEDE772t|r|cFFEBE473h|r|cFFE9E175u|r|cFFE7DF76n|r|cFFE5DC77d|r|cFFE3D979e|r|cFFE1D77Ar|r|cFFDFD47Bo|r|cFFDDD17Du|r|cFFDBCF7Es|r|cFFD9CC7F |r|cFFD7C981p|r|cFFD5C782o|r|cFFD3C484w|r|cFFD1C185e|r|cFFCFBF86r|r|cFFCDBC88 |r|cFFCBB989f|r|cFFC9B78Ar|r|cFFC7B48Co|r|cFFC5B18Dm|r|cFFC3AE8E |r|cFFC1AC90t|r|cFFBFA991h|r|cFFBDA692e|r|cFFBBA494 |r|cFFB9A195g|r|cFFB79E96a|r|cFFB59C98r|r|cFFB29999m|r|cFFB0969Ae|r|cFFAE949Cn|r|cFFAC919Dt|r|cFFAA8E9Es|r|cFFA88CA0 |r|cFFA689A1o|r|cFFA486A2f|r|cFFA284A4 |r|cFFA081A5t|r|cFF9E7EA6h|r|cFF9C7BA8e|r|cFF9A79A9s|r|cFF9876AAe|r|cFF9673AC |r|cFF9471ADh|r|cFF926EAEo|r|cFF906BB0l|r|cFF8E69B1y|r|cFF8C66B2 |r|cFF8A63B4d|r|cFF8861B5e|r|cFF865EB7l|r|cFF845BB8i|r|cFF8259B9c|r|cFF8056BBa|r|cFF7E53BCt|r|cFF7C51BDe|r|cFF7A4EBF |r|cFF784BC0m|r|cFF7648C1a|r|cFF7446C3i|r|cFF7243C4d|r|cFF7040C5e|r|cFF6E3EC7n|r|cFF6C3BC8s|r|cFF6A38C9」|r", 10)
        SendDtimeMsgAll(9.9, "|cFFFFFF66「|r|cFFFDFC68S|r|cFFFAF869t|r|cFFF8F56Br|r|cFFF5F26Di|r|cFFF3EF6Ek|r|cFFF0EB70e|r|cFFEEE872 |r|cFFEBE573d|r|cFFE9E175o|r|cFFE6DE76w|r|cFFE4DB78n|r|cFFE1D87A |r|cFFDFD47Bu|r|cFFDCD17Dp|r|cFFDACE7Fo|r|cFFD8CA80n|r|cFFD5C782 |r|cFFD3C484y|r|cFFD0C085o|r|cFFCEBD87u|r|cFFCBBA89 |r|cFFC9B78Aw|r|cFFC6B38Ci|r|cFFC4B08Dt|r|cFFC1AD8Fh|r|cFFBFA991 |r|cFFBCA692g|r|cFFBAA394r|r|cFFB7A096e|r|cFFB59C97a|r|cFFB29999t|r|cFFB0969B |r|cFFAE929Cv|r|cFFAB8F9Ee|r|cFFA98CA0n|r|cFFA689A1g|r|cFFA485A3e|r|cFFA182A5a|r|cFF9F7FA6n|r|cFF9C7BA8c|r|cFF9A78A9e|r|cFF9775AB |r|cFF9572ADa|r|cFF926EAEn|r|cFF906BB0d|r|cFF8D68B2 |r|cFF8B64B3f|r|cFF8961B5u|r|cFF865EB7r|r|cFF845AB8i|r|cFF8157BAo|r|cFF7F54BCu|r|cFF7C51BDs|r|cFF7A4DBF |r|cFF774AC0a|r|cFF7547C2n|r|cFF7243C4g|r|cFF7040C5e|r|cFF6D3DC7r|r|cFF6B3AC9」|r", 10)
        SendDtimeMsgAll(13.1, "|cFFFFFF66「|r|cFFFDFC67S|r|cFFFBFA69h|r|cFFF9F76Aa|r|cFFF7F46Bt|r|cFFF5F26Dt|r|cFFF3EF6Ee|r|cFFF1EC6Fr|r|cFFEFEA71i|r|cFFEDE772n|r|cFFEBE473g|r|cFFE9E175 |r|cFFE7DF76y|r|cFFE5DC77o|r|cFFE3D979u|r|cFFE1D77Ar|r|cFFDFD47B |r|cFFDDD17Dl|r|cFFDBCF7Eo|r|cFFD9CC7Fa|r|cFFD7C981t|r|cFFD5C782h|r|cFFD3C484s|r|cFFD1C185o|r|cFFCFBF86m|r|cFFCDBC88e|r|cFFCBB989 |r|cFFC9B78Ai|r|cFFC7B48Cm|r|cFFC5B18Dp|r|cFFC3AE8Eu|r|cFFC1AC90r|r|cFFBFA991i|r|cFFBDA692t|r|cFFBBA494y|r|cFFB9A195 |r|cFFB79E96a|r|cFFB59C98n|r|cFFB29999d|r|cFFB0969A |r|cFFAE949Cr|r|cFFAC919De|r|cFFAA8E9Et|r|cFFA88CA0u|r|cFFA689A1r|r|cFFA486A2n|r|cFFA284A4i|r|cFFA081A5n|r|cFF9E7EA6g|r|cFF9C7BA8 |r|cFF9A79A9y|r|cFF9876AAo|r|cFF9673ACu|r|cFF9471AD |r|cFF926EAEf|r|cFF906BB0r|r|cFF8E69B1o|r|cFF8C66B2m|r|cFF8A63B4 |r|cFF8861B5w|r|cFF865EB7h|r|cFF845BB8e|r|cFF8259B9n|r|cFF8056BBc|r|cFF7E53BCe|r|cFF7C51BD |r|cFF7A4EBFy|r|cFF784BC0o|r|cFF7648C1u|r|cFF7446C3 |r|cFF7243C4c|r|cFF7040C5a|r|cFF6E3EC7m|r|cFF6C3BC8e|r|cFF6A38C9」|r", 10)
        SendDtimeMsgAll(18.1, "|cFFFFFF66「|r|cFFFAF86AR|r|cFFF4F16De|r|cFFEFEA71p|r|cFFEAE374e|r|cFFE5DC78n|r|cFFDFD57Bt|r|cFFDACE7F!|r|cFFD5C782Y|r|cFFD0C086o|r|cFFCAB989u|r|cFFC5B28D |r|cFFC0AB90M|r|cFFBAA494o|r|cFFB59D97t|r|cFFB0959Bh|r|cFFAB8E9Ee|r|cFFA587A2r|r|cFFA080A5f|r|cFF9B79A9u|r|cFF9572ACc|r|cFF906BB0k|r|cFF8B64B3e|r|cFF865DB7r|r|cFF8056BA!|r|cFF7B4FBE!|r|cFF7648C1!|r|cFF7141C5」|r", 10)
      end
    end)
    ac.wait(56000, function()
      PlayGlobalSound(Sound_AngelSis_End)
    end)
    PlayBGM({
      bgm = 0,
      time = 90,
      ID = 25,
      unit = u.handle
    })
    PlayBGM({
      bgm = 0,
      time = 90,
      ID = 25,
      unit = mb.handle
    })
    u:uivar_change({
      keyname = "恶灵附身",
      keytype = "冥王栏",
      text = "|cFFFFFF33潘迪-天使化|r\n|cFFFFFF33神性 2\n光明 黑暗\n天使|r\n|cFFFFCC99免疫疾病|r\n|cFFFFFF33狩猎者|r\n|cFFFFCC99对恶魔提升9%伤害\n每有一位男性队友提升0.5%终结伤害|r\n|cFFFFFF33物理驱魔|r\n|cFFFFCC99提升25%受伤减少\n提升5%力量\n提升2%近战伤害\n提升40%拳系伤害|r\n|cFFFFFF33嗜辣|r\n|cFFFFCC99食用辣属性食物时在60秒内提升8(16)%伤害加成，可叠加，分立计时|r\n|cFFFFFF33Back Lace|r\n|cFFFFCC99妹妹存活时提升1%终结伤害\n枪械子弹变为强化恶灵弹，伤害附加[10000+500*等级]魔力伤害，5%产生鬼影惊吓周围750码使其恐惧1秒(触发冷却3秒)|r",
      icon = "war3mapImported\\BTNEwl_Teshu_Panty.blp"
    })
    mb:uivar_change({
      keyname = "二刀流",
      keytype = "冥王栏",
      text = "|cFF9966CC史朵巾-天使化|r\n|cFF9966CC神性 2\n光明 黑暗\n天使|r\n|cFF9966FF免疫疾病|r\n|cFF9966CC双刀使|r\n|cFF9966FF装备武器并切换时切换冷却时间变更为[卸下武器的使用冷却*50%]\n切换武器后增加5%伤害加成 持续6秒 可叠加 分立计时\n切换武器后对周围350范围单位造成[2500+等级*500]物理近战伤害|r\n|cFF9966CC狩猎者|r\n|cFF9966FF提升2.8%近战伤害\n使用近战武器时如果目标只有一个则提升33%该次伤害|r\n|cFF9966CC甜点爱好者|r\n|cFF9966FF食用甜点时提升1点全属性|r\n|cFF9966CCSM|r\n|cFF9966FF直接伤害时在10秒内提升0.1%伤害加成\n近战伤害附带移除目标1/666生命上限(触发冷却0.25秒)|r\n|cFF9966CCStripeⅠ&Ⅱ|r\n|cFF9966FF姐姐存活时提升1%终结伤害\n武器切换冷却降低为[卸下武器冷却*50%],不会超过1秒|r",
      icon = "war3mapImported\\BTNEwl_Teshu_Stocking.blp"
    })
  end,
  ["礼奈黑化"] = function(u)
    Nofail_Biaoji = true
    Movie_Boolean = true
    do
      local tg = getunit(BOSS)
      local x, y = u:getxy()
      u:buffset(u.handle, 19, "暂停")
      u:buffset(u.handle, 22, "无敌")
      u:buffset(u.handle, 21, "绝对闪避")
      tg:buffset(tg.handle, 27, "暂停")
      u:settimedata("礼奈-奈落之花", 290)
      PlayBGM({
        bgm = 0,
        time = 290,
        ID = 34,
        unit = u.handle
      })
      u:setdata("礼奈-永久黑化")
      u:setplayername("|cFF990000杀|r|cFFAA111A人|r|cFFBB2233鬼|r|cFFCC334C礼|r|cFFDD4466奈|r")
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:buffset(u.handle, 21, "绝对闪避")
      end)
      local cs = 0
      ac.loop(500, function(timer)
        cs = cs + 1
        ForGroupLuaNew(Group_Monster, function(xq)
          xq:buffset(xq.handle, 1, "暂停")
        end)
        if cs == 50 then
          timer:remove()
        end
      end)
      local linai = class.panel:builder({
        parent = OriginPanel,
        x = 0,
        y = 0,
        w = 1920,
        h = 851,
        normal_image = "war3mapImported\\Pho_Rena (4).blp"
      })
      linai:set_alpha(3)
      local ahp = 3
      ac.timer(30, 100, function()
        ahp = ahp + 1
        linai:set_alpha(ahp)
      end)
      PlayGlobalSound(BGM_Rena_3)
      PlayGlobalSound(Sound_Rena_End04)
      ac.wait(5000, function()
        LossHpUnit({
          u = u,
          tg = tg,
          damage = 0,
          perhp = 10,
          maxhp = 0,
          bj = "[生命损耗]奈落之花"
        })
        PlayGlobalSound(Sound_Rena_End02)
        PlayGlobalSound(Sound_Rena_End01)
        flashphoto({
          photo = "war3mapImported\\Pho_Rena (1).blp",
          timeout = 0,
          timehold = 1,
          timein = 1
        })
        local jd = GetRandomAngle()
        local x2, y2 = tg:getxy()
        Effectcreate("war3mapImported\\176.mdl", x2, y2, 5, 1.5, 0, jd)
        unitmove({
          unit = tg.handle,
          time = 0.5,
          distance = 250,
          angle = jd,
          isfly = true
        })
        local x1, y1 = PolarXY(x2, y2, -250, jd)
        u:setxy(x1, y1)
        u:setface(jd)
        tg:animeact("death")
        Effectcreate("war3mapImported\\texiao_xuebao.mdx", x2, y2, 0, 2)
        Effectcreate("Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl", x2, y2, 0, 2)
        Effectcreate("war3mapImported\\[TxNew1]001.mdx", x2, y2, 0, 2)
      end)
      ac.wait(8000, function()
        LossHpUnit({
          u = u,
          tg = tg,
          damage = 0,
          perhp = 10,
          maxhp = 0,
          bj = "[生命损耗]奈落之花"
        })
        PlayGlobalSound(Sound_Rena_End02)
        PlayGlobalSound(Sound_Rena_End01)
        PlayGlobalSound(Sound_Rena_End05)
        flashphoto({
          photo = "war3mapImported\\Pho_Rena (2).blp",
          timeout = 0,
          timehold = 1,
          timein = 1
        })
        local jd = GetRandomAngle()
        local x2, y2 = tg:getxy()
        Effectcreate("war3mapImported\\176.mdl", x2, y2, 5, 1.5, 0, jd)
        unitmove({
          unit = tg.handle,
          time = 0.5,
          distance = 250,
          angle = jd,
          isfly = true
        })
        local x1, y1 = PolarXY(x2, y2, -250, jd)
        u:setxy(x1, y1)
        u:setface(jd)
        tg:animeact("death")
        Effectcreate("war3mapImported\\texiao_xuebao.mdx", x2, y2, 0, 2)
        Effectcreate("Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl", x2, y2, 0, 2)
        Effectcreate("war3mapImported\\[TxNew1]001.mdx", x2, y2, 0, 2)
      end)
      ac.wait(11000, function()
        LossHpUnit({
          u = u,
          tg = tg,
          damage = 0,
          perhp = 10,
          maxhp = 0,
          bj = "[生命损耗]奈落之花"
        })
        PlayGlobalSound(Sound_Rena_End02)
        PlayGlobalSound(Sound_Rena_End01)
        PlayGlobalSound(Sound_Rena_End06)
        flashphoto({
          photo = "war3mapImported\\Pho_Rena (2).blp",
          timeout = 0,
          timehold = 1,
          timein = 1
        })
        local jd = GetRandomAngle()
        local x2, y2 = tg:getxy()
        Effectcreate("war3mapImported\\176.mdl", x2, y2, 5, 1.5, 0, jd)
        unitmove({
          unit = tg.handle,
          time = 0.5,
          distance = 250,
          angle = jd,
          isfly = true
        })
        local x1, y1 = PolarXY(x2, y2, -250, jd)
        u:setxy(x1, y1)
        u:setface(jd)
        tg:animeact("death")
        Effectcreate("war3mapImported\\texiao_xuebao.mdx", x2, y2, 0, 2)
        Effectcreate("Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl", x2, y2, 0, 2)
        Effectcreate("war3mapImported\\[TxNew1]001.mdx", x2, y2, 0, 2)
      end)
      ac.wait(16000, function()
        LossHpUnit({
          u = u,
          tg = tg,
          damage = 0,
          perhp = 10,
          maxhp = 0,
          bj = "[生命损耗]奈落之花"
        })
        PlayGlobalSound(Sound_Rena_End02)
        PlayGlobalSound(Sound_Rena_End01)
        PlayGlobalSound(Sound_Rena_End07)
        flashphoto({
          photo = "war3mapImported\\Pho_Rena (5).blp",
          timeout = 0,
          timehold = 1,
          timein = 1
        })
        local jd = GetRandomAngle()
        local x2, y2 = tg:getxy()
        Effectcreate("war3mapImported\\176.mdl", x2, y2, 5, 1.5, 0, jd)
        unitmove({
          unit = tg.handle,
          time = 0.5,
          distance = 250,
          angle = jd,
          isfly = true
        })
        local x1, y1 = PolarXY(x2, y2, -250, jd)
        u:setxy(x1, y1)
        u:setface(jd)
        tg:animeact("death")
        Effectcreate("war3mapImported\\texiao_xuebao.mdx", x2, y2, 0, 2)
        Effectcreate("Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl", x2, y2, 0, 2)
        Effectcreate("war3mapImported\\[TxNew1]001.mdx", x2, y2, 0, 2)
      end)
      ac.wait(18000, function()
        LossHpUnit({
          u = u,
          tg = tg,
          damage = 0,
          perhp = 10,
          maxhp = 0,
          bj = "[生命损耗]奈落之花"
        })
        PlayGlobalSound(Sound_Rena_End02)
        PlayGlobalSound(Sound_Rena_End01)
        PlayGlobalSound(Sound_Rena_End03)
        flashphoto({
          photo = "war3mapImported\\Pho_Rena (3).blp",
          timeout = 0,
          timehold = 1,
          timein = 1
        })
        linai:set_normal_image("war3mapImported\\Pho_Rena (3).blp")
        local jd = GetRandomAngle()
        local x2, y2 = tg:getxy()
        Effectcreate("war3mapImported\\176.mdl", x2, y2, 5, 1.5, 0, jd)
        unitmove({
          unit = tg.handle,
          time = 0.5,
          distance = 250,
          angle = jd,
          isfly = true
        })
        local x1, y1 = PolarXY(x2, y2, -250, jd)
        u:setxy(x1, y1)
        u:setface(jd)
        tg:animeact("death")
        Effectcreate("war3mapImported\\texiao_xuebao.mdx", x2, y2, 0, 2)
        Effectcreate("Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl", x2, y2, 0, 2)
        Effectcreate("war3mapImported\\[TxNew1]001.mdx", x2, y2, 0, 2)
      end)
      ac.wait(19000, function()
        linai:destroy()
        Movie_Boolean = false
        Nofail_Biaoji = false
        PlayGlobalSound(Sound_Rena_End08)
        PlayGlobalSound(BGM_Rena_01)
      end)
    end
  end,
  ["队长删模"] = function(u)
    u:setdata("队长-已删模")
    PlayGlobalSound(Sound_Dz_01)
    NPCChat({
      name = "|cFFFFCC00基尔什塔利亚·沃戴姆",
      chaticon = "Chat_Duizhang.blp",
      chattext = {
        {
          time = 0,
          text = "|cFFFFCC00阿特拉斯空想树燃烧殆尽，异星之神降临"
        },
        {
          time = 8.8,
          text = "|cFFFFCC00真是完败，我已经没有逆转局势的可能性了"
        },
        {
          time = 16.4,
          text = "|cFFFFCC00但你们却不同"
        },
        {
          time = 20.6,
          text = "|cFFFFCC00对你们来说败北就意味着死亡，活下去就是胜利"
        },
        {
          time = 29.1,
          text = "|cFFFFCC00你们还有翻盘的可能性，你们还没有失败"
        },
        {
          time = 41,
          text = "|cFFFFCC00迦勒底的明灯"
        },
        {
          time = 43.4,
          text = "|cFFFFCC00请再一次，指引旅人前行的道路"
        }
      }
    })
    ac.wait(49000, function()
      PlayGlobalSound(BGM_Dz_01)
    end)
    u:effectadd("war3mapImported\\[ake]war3ake.com - 7346841038772226188179609.mdx", "origin", -1)
    u:shanmo(49)
    local cs = 0
    local a = 255
    ac.loop(1000, function(timer)
      cs = cs + 1
      a = a - 5 * cs
      u:setcolor(255, 255, 255, a)
      if cs == 50 then
        timer:remove()
      end
    end)
    PlayBGM({
      bgm = 0,
      time = 350,
      ID = 146,
      unit = u.handle
    })
  end,
  ["队长宝具"] = function(u)
    do
      local sy = u.ownerid
      local x, y = u:getxy()
      local gd = 5000
      u:setdata("演出-无限复活")
      Movie_Boolean = true
      FogEnable(false)
      FogMaskEnable(false)
      ac.wait(31750, function()
        Movie_Boolean = false
        FogEnable(true)
        FogMaskEnable(true)
      end)
      PlayBGM({
        bgm = BGM_Wdm_01,
        ID = 144,
        time = 100,
        unit = u.handle
      })
      u:buffset(u.handle, 26.5, "永恒")
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:buffset(u.handle, 26.5, "暂停")
        xq:buffset(u.handle, 35, "绝对闪避")
      end)
      ForGroupLuaNew(Group_Monster, function(xq)
        xq:buffset(u.handle, 35, "暂停")
        if xq:isboss() then
          xq:buffset(u.handle, 35, "沉默")
        end
      end)
      NPCChat({
        name = "|cFFFFCC00基尔什塔利亚·沃戴姆",
        chaticon = "Chat_Duizhang.blp",
        chattext = {
          {
            time = 1,
            text = "|cFFFFCC00『虚空之神啊！』|r"
          },
          {
            time = 2.8,
            text = "|cFFFFCC00『现宣告人智之败北。』|r"
          },
          {
            time = 5.8,
            text = "|cFFFFCC00『双眼过于古旧，手足尽显羸弱，知识更已凝滞。』|r"
          },
          {
            time = 11,
            text = "|cFFFFCC00『作为最后的|r|cFFFFFFCC人类|r|cFFFFCC00』|r"
          },
          {
            time = 13,
            text = "|cFFFFCC00『我于此将这无数的|r|cFF6699FF决断|r|cFFFFCC00、众多的|r|cFFFF6699挫折|r|cFFFFCC00、以及所有的|r|cFFFF9900繁荣|r|cFFFFCC00』|r"
          },
          {
            time = 18.6,
            text = "|cFFFFCC00『裁决为|r|cFF666666虚无|r|cFFFFCC00』|r"
          },
          {
            time = 21,
            text = "|cFFFFCC00『以此一击』|r"
          },
          {
            time = 23.1,
            text = "|cFFFFCC00『击坠神明』|r"
          },
          {
            time = 25.3,
            text = "|cFFFFCC00『令变革的钟声响彻吧！』|r"
          }
        }
      })
      PlayGlobalSound(duizhang_baojutaici)
      PlayGlobalSound(duizhang_baojuyingxiao)
      ac.wait(5200, function()
        StopSoundBJ(duizhang_baojutaici, false)
      end)
      ac.wait(5800, function()
        PlayGlobalSound(duizhang_baojutaici)
        SetSoundPlayPosition(duizhang_baojutaici, 5300)
      end)
      ac.wait(10400, function()
        StopSoundBJ(duizhang_baojutaici, false)
      end)
      ac.wait(11000, function()
        PlayGlobalSound(duizhang_baojutaici)
        SetSoundPlayPosition(duizhang_baojutaici, 9800)
      end)
      ac.wait(20300, function()
        StopSoundBJ(duizhang_baojutaici, false)
      end)
      ac.wait(21000, function()
        PlayGlobalSound(duizhang_baojutaici)
        SetSoundPlayPosition(duizhang_baojutaici, 19000)
      end)
      ac.wait(27100, function()
        StopSoundBJ(duizhang_baojutaici, false)
      end)
      ac.wait(27800, function()
        PlayGlobalSound(duizhang_baojutaici)
        SetSoundPlayPosition(duizhang_baojutaici, 25000)
        SendMsgAll("|cFFFFCC00『G|r|cFFFFD011r|r|cFFFFD422a|r|cFFFFD933n|r|cFFFFDD44d|r|cFFFFE155 |r|cFFFFE666O|r|cFFFFEA77r|r|cFFFFEE88d|r|cFFFFF299e|r|cFFFFF6AAr』|r", 30)
        SendDtimeMsgAll(2, "|cFFFFCC00『A|r|cFFFFCF0Bn|r|cFFFFD217i|r|cFFFFD522m|r|cFFFFD72Da|r|cFFFFDA39 |r|cFFFFDD44A|r|cFFFFE04Fn|r|cFFFFE35Bi|r|cFFFFE666m|r|cFFFFE871u|r|cFFFFEB7Ds|r|cFFFFEE88p|r|cFFFFF193h|r|cFFFFF49Fe|r|cFFFFF7AAr|r|cFFFFF9B5e』|r", 30)
      end)
      SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, 3500.0, 0)
      SetCameraTargetController(u.handle, 0, 0, false)
      ac.wait(3000, function()
        CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 1.0, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 0.0, 0, 0, 100.0)
        SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, 90.0, 10.0)
        SetCameraField(CAMERA_FIELD_ZOFFSET, 4000.0, 10.0)
      end)
      ac.wait(19000, function()
        CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 3.0, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 100.0, 100.0, 0.0)
      end)
      ac.wait(20500, function()
        ResetToGameCamera(0)
        SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, Cam_height[LocalPlayerID] or 3500, 0)
      end)
      ac.wait(21000, function()
        local cs = 0
        ac.timer(250, 25, function()
          cs = cs + 1
          ForGroupLuaNew(Group_PlayHero, function(xq)
            xq:shockcamera(cs * 1.5)
          end)
        end)
      end)
      Effectcreate("war3mapImported\\yx_xiaoyuanyinhe2.mdl", x, y, 26, 6, 4000)
      Effectcreate("war3mapImported\\yx_xiaoyuanyinhe2.mdl", x, y, 26, 4, 4000)
      Effectcreate("war3mapImported\\yx_xiaoyuanyinhe2.mdl", x, y, 26, 4, 4000)
      Effectcreate("war3mapImported\\yx_xiaoyuanyinhe2.mdl", x, y, 26, 3, 4000)
      ac.wait(1000, function()
        Effectcreate("war3mapImported\\95eba21ae7e7d1a8.mdl", x, y, 0, 7, 150, 0, 0, 0, 2)
      end)
      ac.wait(1500, function()
        CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.5, "ReplaceableTextures\\CameraMasks\\DreamFilter_Mask.blp", 100.0, 100.0, 100.0, 0.0)
        Effectcreate("war3mapImported\\iye_xialuo1.mdl", x, y, 0, 7, 0, 0, 0, 0, 1)
      end)
      ac.wait(1500, function()
        Effectcreate("war3mapImported\\qiye_xialuo1.mdl", x, y, 0, 7, 100)
        local tx1 = Effectcreate("war3mapImported\\az_goods_tp_target(1).mdl", x - 32, y - 32, -1, 10, 10, 0, 0, 0, 0.15)
        local dx = 1
        ac.loop(50, function(timer)
          dx = dx + 0.05
          SetEffectSize(tx1, dx)
          if 3 <= dx then
            ac.wait(6000, function()
              DestroyEffectLua(tx1)
            end)
            timer:remove()
          end
        end)
      end)
      ac.wait(13000, function()
        EffectcreateArgs({
          effect = "war3mapImported\\mfz-j11.mdl",
          x = x,
          y = y,
          time = 7.5,
          size = 20,
          height = gd,
          xxz = 180
        })
        EffectcreateArgs({
          effect = "war3mapImported\\mfz-j11.mdl",
          x = x,
          y = y,
          time = 7.5,
          size = 7,
          height = gd,
          zxz = 45,
          xxz = 180
        })
        local tx1 = EffectcreateArgs({
          effect = "war3mapImported\\buff-aura[z2].mdl",
          x = x,
          y = y,
          time = 0,
          size = 0,
          height = gd
        })
        local dx = 0
        ac.loop(20, function(timer)
          dx = dx + 5
          SetEffectSize(tx1, dx)
          if 250 <= dx then
            timer:remove()
          end
        end)
      end)
      ac.wait(13000, function()
        local tx1 = EffectcreateArgs({
          effect = "war3mapImported\\xing_mfz.mdx",
          x = x,
          y = y,
          time = 7.5,
          size = 0.5,
          height = gd
        })
        ac.wait(500, function()
          SetEffectActSpeed(tx1, 0)
        end)
        ac.wait(1000, function()
          SetEffectActSpeed(tx1, 1)
        end)
        local tx1 = EffectcreateArgs({
          effect = "war3mapImported\\xing_mfz.mdx",
          x = x,
          y = y,
          time = 7.5,
          size = 1,
          height = gd
        })
        ac.wait(500, function()
          SetEffectActSpeed(tx1, 0)
        end)
        ac.wait(1500, function()
          SetEffectActSpeed(tx1, 1)
        end)
        local tx1 = EffectcreateArgs({
          effect = "war3mapImported\\xing_mfz.mdx",
          x = x,
          y = y,
          time = 7.5,
          size = 2,
          height = gd
        })
        ac.wait(500, function()
          SetEffectActSpeed(tx1, 0)
        end)
        ac.wait(1500, function()
          SetEffectActSpeed(tx1, 1)
        end)
        local jdz1 = {
          45,
          70,
          160,
          240,
          280,
          320
        }
        local jdz2 = {
          30,
          120,
          180,
          220,
          320,
          0
        }
        local jdz3 = {
          20,
          60,
          160,
          200,
          335,
          0
        }
        local cs1 = 0
        ac.loop(10, function(timer)
          cs1 = cs1 + 1
          do
            local sj1 = 1 + 0.5 * GetRandomInt(1, 6)
            local x1, y1 = PolarXY(x, y, 800, jdz1[cs1])
            local tx3 = EffectcreateArgs({
              effect = "war3mapImported\\xing_mfz.mdx",
              x = x1,
              y = y1,
              time = 7.5,
              size = GetRandomReal(0.5, 1.5),
              height = gd,
              zxz = GetRandomAngle()
            })
            ac.wait(500, function()
              SetEffectActSpeed(tx3, 0)
            end)
            ac.wait(sj1 * 1000, function()
              SetEffectActSpeed(tx3, 1)
            end)
          end
          do
            local sj1 = 1 + 0.5 * GetRandomInt(1, 6)
            local x1, y1 = PolarXY(x, y, 1300, jdz2[cs1])
            local tx3 = EffectcreateArgs({
              effect = "war3mapImported\\xing_mfz.mdx",
              x = x1,
              y = y1,
              time = 7.5,
              size = GetRandomReal(0.5, 1.5),
              height = gd,
              zxz = GetRandomAngle()
            })
            ac.wait(500, function()
              SetEffectActSpeed(tx3, 0)
            end)
            ac.wait(sj1 * 1000, function()
              SetEffectActSpeed(tx3, 1)
              for i = 1, 7 do
                local dx, dy = PolarXY(x, y, GetRandomReal(100, 2200), GetRandomAngle())
                EffectcreateArgs({
                  effect = "war3mapImported\\xing_quan2.mdx",
                  x = dx,
                  y = dy,
                  time = 7.5 - sj1,
                  size = GetRandomReal(0.1, 0.5),
                  height = gd
                })
              end
            end)
          end
          do
            local sj1 = 1 + 0.5 * GetRandomInt(1, 6)
            local x1, y1 = PolarXY(x, y, 2000, jdz3[cs1])
            local tx3 = EffectcreateArgs({
              effect = "war3mapImported\\xing_mfz.mdx",
              x = x1,
              y = y1,
              time = 7.5,
              size = GetRandomReal(1.5, 4),
              height = gd,
              zxz = GetRandomAngle()
            })
            ac.wait(500, function()
              SetEffectActSpeed(tx3, 0)
            end)
            ac.wait(sj1 * 1000, function()
              SetEffectActSpeed(tx3, 1)
            end)
          end
          if 6 <= cs1 then
            timer:remove()
          end
        end)
      end)
      ac.wait(26500, function()
        local cs = 0
        ac.loop(150, function(timer)
          cs = cs + 1
          for i = 1, 2 do
            local dx = x + GetRandomReal(-2000, 2000)
            local dy = y + GetRandomReal(-2000, 2000)
            EffectcreateArgs({
              effect = "war3mapImported\\down-fire.mdl",
              x = dx,
              y = dy,
              time = 0,
              size = 3
            })
            ac.wait(1000, function()
              EffectcreateArgs({
                effect = "war3mapImported\\chushou_by_wood_effect_flame_explosion_2.mdl",
                x = dx,
                y = dy,
                time = 0,
                size = 6
              })
              EffectcreateArgs({
                effect = "Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl",
                x = dx,
                y = dy,
                time = 0,
                size = 6
              })
              ForGroupLuaNew(Group_PlayHero, function(xq)
                xq:shockcamera(200, 0.1)
              end)
            end)
          end
          if cs == 25 then
            ForGroupLuaNew(Group_Monster, function(xq)
              if xq:isboss() then
                u:setdata("系统-超限伤害", 0.4)
                DamageUnit({
                  bj = "人理保障天球",
                  unit = xq.handle,
                  source = u.handle,
                  damage = 500,
                  level = 5,
                  type = "魔力",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "无",
                  extradata = {}
                })
              else
                xq:kill(u.handle, true)
              end
            end)
          end
          if 7 <= cs then
            ForGroupLuaNew(Group_Monster, function(xq)
              if xq:isboss() then
                DamageUnit({
                  bj = "人理保障天球",
                  unit = xq.handle,
                  source = u.handle,
                  damage = 1000 * u:getallattri(),
                  level = 5,
                  type = "魔力",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "无",
                  extradata = {}
                })
              end
            end)
          end
          if 35 <= cs then
            timer:remove()
          end
        end)
      end)
      ac.wait(90000, function()
        u:deldata("演出-无限复活")
        u:setdata("队长-死亡删模")
      end)
    end
  end,
  ["玛丽小姐的电话"] = function(u, tg)
    if tg:isboss() and tg:getperhp() > 8 then
      PlayGlobalSound(Sound_Lianlian_Dianhua5)
      ac.wait(2000, function()
        PlayGlobalSound(Sound_Lianlian_Dianhua3)
        tg:buffset(u.handle, 10, "眩晕")
        tg:buffset(u.handle, 10, "暂停")
        ac.timer(100, 8, function()
          LossHpUnit({
            u = u,
            tg = tg,
            damage = 0,
            perhp = 0,
            maxhp = 1,
            bj = "[生命损耗]玛丽小姐的电话"
          })
          local txsh = 0.01 * tg:getmaxhp()
          DamageUnit({
            bj = "玛丽小姐的电话",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "灵力",
            isvest = false,
            isattack = false,
            isnoarmor = false,
            element = "无",
            extradata = {}
          })
          tg:effectadd("war3mapImported\\texiao_xuebao.mdx")
        end)
      end)
      return
    end
    
    local function shuffle(t)
      for i = #t, 2, -1 do
        local j = GetRandomInt(1, i)
        t[i], t[j] = t[j], t[i]
      end
    end
    
    local stra = "Ph_Test_"
    local red = class.panel:builder({
      parent = OriginPanel,
      x = 0,
      y = 0,
      w = 1920,
      h = 851,
      normal_image = "Touming.tga"
    })
    red:set_alpha(5)
    
    local function abc()
      u:buffset(u.handle, 13, "绝对闪避")
      u:buffset(u.handle, 13, "无敌")
      u:buffset(u.handle, 10, "暂停")
      if tg:isboss() then
        tg:buffset(u.handle, 13, "暂停")
        tg:buffset(u.handle, 13, "沉默")
        Movie_Boolean = true
      end
      do
        local jgt = 1
        local jgt2 = 0.5
        local dataz = {
          {
            text = "こ ん ば ん は"
          },
          {text = "ね ぇ"},
          {
            text = "知 っ て る ？"
          },
          {
            text = "私 の こ と"
          },
          {
            text = "気 付 い て く れ た ？"
          }
        }
        flashphoto({
          photo = "war3mapImported\\Black.blp",
          timeout = 0,
          timehold = jgt,
          timein = 0.1
        })
        local buttontext = class.text:builder({
          parent = OriginPanel,
          x = 960.0,
          y = 425,
          w = 1,
          h = 1,
          text = "",
          align = "center"
        })
        buttontext:set_size(2, "fontnm.ttf")
        buttontext:set_text("|cFF990000" .. dataz[1].text .. "|r")
        local b = ac.loop(30, function()
          buttontext:set_position(960.0 + GetRandomReal(-5, 5), 425 + GetRandomReal(-5, 5))
          if GetRandom100(5) then
            buttontext:set_position(960.0 + GetRandomReal(-5, 5), 425 + GetRandomReal(-50, 50))
          end
        end)
        local yxz = {
          Sound_Lianlian_Dadianhua09,
          Sound_Lianlian_Dadianhua13,
          Sound_Lianlian_Dadianhua14,
          Sound_Lianlian_Dadianhua15,
          Sound_Lianlian_Dadianhua16
        }
        local cs = 1
        local pz1 = {
          11,
          16,
          21
        }
        local pz2 = {
          9,
          10,
          14,
          15
        }
        shuffle(pz1)
        shuffle(pz2)
        local bb = 13
        PlayGlobalSound(Sound_Lianlian_Dianhua)
        PlayGlobalSound(yxz[cs])
        ac.wait(jgt * 1000, function()
          local pz = {
            11,
            16,
            21
          }
          red:set_alpha(155)
          red:set_normal_image(stra .. pz[1] .. ".blp")
          local a = 155
          ac.timer(30, 10, function()
            a = a - bb
            red:set_alpha(a)
          end)
          buttontext:destroy()
          b:remove()
        end)
        ac.timer((jgt + jgt2) * 1000, #dataz - 1, function()
          cs = cs + 1
          PlayGlobalSound(yxz[cs])
          flashphoto({
            photo = "war3mapImported\\Black.blp",
            timeout = 0,
            timehold = jgt,
            timein = 0.1
          })
          buttontext = class.text:builder({
            parent = OriginPanel,
            x = 960.0,
            y = 425,
            w = 1,
            h = 1,
            text = "",
            align = "center"
          })
          buttontext:set_size(2, "fontnm.ttf")
          buttontext:set_text("|cFF990000" .. dataz[cs].text .. "|r")
          local b = ac.loop(30, function()
            buttontext:set_position(960.0 + GetRandomReal(-5, 5), 425 + GetRandomReal(-5, 5))
            if GetRandom100(5) then
              buttontext:set_position(960.0 + GetRandomReal(-5, 5), 425 + GetRandomReal(-50, 50))
            end
          end)
          PlayGlobalSound(Sound_Lianlian_Dianhua)
          ac.wait(jgt * 1000, function()
            if 2 <= cs and cs <= 3 then
              red:set_alpha(155)
              red:set_normal_image(stra .. pz1[cs] .. ".blp")
              local a = 155
              ac.timer(30, 10, function()
                a = a - bb
                red:set_alpha(a)
              end)
            end
            if 3 < cs then
              red:set_alpha(155)
              red:set_normal_image(stra .. pz2[cs - 3] .. ".blp")
              local a = 155
              ac.timer(30, 10, function()
                a = a - bb
                red:set_alpha(a)
              end)
            end
            buttontext:destroy()
            b:remove()
          end)
        end)
        ac.wait((jgt + jgt2) * #dataz * 1000, function()
          PlayGlobalSound(Sound_Lianlian_Dadianhua18)
          flashphoto({
            photo = "war3mapImported\\Black.blp",
            timeout = 0,
            timehold = 0,
            timein = 0
          })
          buttontext = class.text:builder({
            parent = OriginPanel,
            x = 960.0,
            y = 425,
            w = 1,
            h = 1,
            text = "",
            align = "center"
          })
          buttontext:set_size(2, "fontnm.ttf")
          buttontext:set_text("|cFF990000ね ぇ|r")
          ac.wait(840, function()
            buttontext:set_text("|cFF990000私|r")
          end)
          ac.wait(1790, function()
            buttontext:set_text("|cFF990000今|r")
          end)
          ac.wait(2580, function()
            buttontext:set_text("|cFF990000あ な た の …|r")
          end)
          local bbb = ac.loop(30, function()
            buttontext:set_position(960.0 + GetRandomReal(-5, 5), 425 + GetRandomReal(-5, 5))
            if GetRandom100(5) then
              buttontext:set_position(960.0 + GetRandomReal(-5, 5), 425 + GetRandomReal(-50, 50))
            end
          end)
          PlayGlobalSound(Sound_Lianlian_Dianhua)
          ac.wait(3500, function()
            red:destroy()
            PlayGlobalSound(Sound_Lianlian_Dianhua2)
            buttontext:destroy()
            bbb:remove()
            do
              local size = 1.77
              local dx = 1900
              local dy = 0
              local red = class.panel:builder({
                parent = OriginPanel,
                x = 0,
                y = 0,
                w = 1920,
                h = 851,
                normal_image = "DarkRed.blp"
              })
              red:set_alpha(5)
              red:set_level(3)
              local exph = class.panel:builder({
                parent = OriginPanel,
                x = 1900,
                y = 0,
                w = 700 * size / 0.71,
                h = 437 * size / 0.91,
                normal_image = "Ph_Lianlianzhansha.blp"
              })
              exph:set_level(3)
              ac.loop(30, function(timer3)
                dx = dx - 360.0
                exph:set_position(dx, dy)
                if dx <= 100 then
                  local ap2 = 5
                  ac.loop(30, function(timer)
                    ap2 = ap2 + 20
                    if ap2 <= 255 then
                      red:set_alpha(ap2)
                    else
                      red:set_alpha(255)
                    end
                    if 600 <= ap2 then
                      flashphoto({
                        photo = "war3mapImported\\Black.blp",
                        timeout = 0,
                        timehold = 0,
                        timein = 0.1
                      })
                      PlayGlobalSound(Sound_Lianlian_Dadianhua17)
                      exph:destroy()
                      ap2 = 255
                      red:set_alpha(ap2)
                      if tg:isboss() then
                        ac.wait(1000, function()
                          Movie_Boolean = false
                        end)
                      end
                      u:animespeed(1)
                      PlayGlobalSound(Sound_Lianlian_Dianhua3)
                      ac.timer(100, 8, function()
                        tg:effectadd("war3mapImported\\texiao_xuebao.mdx")
                      end)
                      if tg:isboss() then
                        DamageUnit({
                          bj = "玛丽小姐的电话",
                          unit = tg.handle,
                          source = u.handle,
                          damage = 100,
                          level = 1,
                          type = "灵力",
                          isvest = false,
                          isattack = false,
                          isnoarmor = false,
                          element = "无",
                          extradata = {
                            "玛丽小姐电话斩杀"
                          }
                        })
                      elseif not tg:hasbuff("绝对闪避") then
                        tg:kill()
                      end
                      ac.loop(30, function(timer2)
                        ap2 = ap2 - 25
                        red:set_alpha(ap2)
                        if ap2 <= 5 then
                          red:destroy()
                          timer2:remove()
                        end
                      end)
                      ac.wait(16500, function()
                        PlayGlobalSound(Sound_Lianlian_Dianhua)
                        local bbbbb = class.panel:builder({
                          parent = OriginPanel,
                          x = 0,
                          y = 0,
                          w = 1920,
                          h = 851,
                          normal_image = "Ph_Test_17.blp"
                        })
                        bbbbb:set_level(3)
                        bbbbb:set_alpha(155)
                        ac.wait(500, function()
                          local a = 155
                          ac.timer(30, 10, function()
                            a = a - bb
                            bbbbb:set_alpha(a)
                          end)
                          ac.wait(301, function()
                            bbbbb:destroy()
                          end)
                        end)
                      end)
                      timer:remove()
                    end
                  end)
                  timer3:remove()
                end
              end)
            end
          end)
        end)
      end
    end
    
    if not u:hasdata("恋恋-打电话触发") then
      u:setdata("恋恋-打电话触发")
      u:buffset(u.handle, 22, "绝对闪避")
      u:buffset(u.handle, 22, "无敌")
      u:buffset(u.handle, 22, "暂停")
      if tg:isboss() then
        tg:buffset(u.handle, 22, "暂停")
        tg:buffset(u.handle, 22, "沉默")
        Movie_Boolean = true
      end
      do
        local count = 5
        local snds = 57
        PlayGlobalSound(Sound_Lianlian_Dianhua4)
        SetSoundVolume(Sound_Lianlian_Dianhua4, 57)
        ac.loop(3000, function(timer)
          snds = snds + 20
          count = count - 1
          if count == 0 then
            PlayGlobalSound(Sound_Lianlian_Dianhua5)
            timer:remove()
          else
            PlayGlobalSound(Sound_Lianlian_Dianhua4)
            SetSoundVolume(Sound_Lianlian_Dianhua4, snds)
          end
        end)
      end
      PlayGlobalSound(BGM_Lianlian_Shenhua2)
      flashphoto({
        photo = "Ph_Test_1.blp",
        timeout = 12,
        timehold = 0,
        timein = 0
      })
      local z = GetRandomInt(2, 4)
      local timez = {
        4,
        4.4,
        7.2,
        9,
        9.4,
        10.3,
        12.2
      }
      for index, value in ipairs(timez) do
        ac.wait((value - 0.1) * 1000, function()
          red:set_alpha(255)
          z = z + GetRandomInt(1, 2)
          if 4 < z then
            z = 2
          end
          red:set_normal_image(stra .. z .. ".blp")
          ac.wait(100, function()
            red:set_alpha(5)
          end)
        end)
      end
      ac.wait(15200, function()
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:buffset(u.handle, 10, "绝对闪避")
        end)
        flashphoto({
          photo = "Ph_Test_5.blp",
          timeout = 0,
          timehold = 0,
          timein = 0
        })
        ac.wait(300, function()
          flashphoto({
            photo = "war3mapImported\\Black.blp",
            timeout = 0,
            timehold = 0,
            timein = 0
          })
        end)
      end)
      ac.wait(17680, function()
        red:set_alpha(255)
        red:set_normal_image(stra .. 6 .. ".blp")
        local a = 255
        ac.timer(30, 10, function()
          a = a - 25
          red:set_alpha(a)
        end)
      end)
      ac.wait(19080, function()
        red:set_alpha(155)
        red:set_normal_image(stra .. 7 .. ".blp")
        local a = 155
        ac.timer(30, 10, function()
          a = a - 12
          red:set_alpha(a)
        end)
      end)
      ac.wait(21000, function()
        StopSoundBJ(BGM_Lianlian_Shenhua2, false)
        abc()
      end)
    else
      local count = GetRandomInt(3, 5)
      local snds = 57
      PlayGlobalSound(Sound_Lianlian_Dianhua4)
      SetSoundVolume(Sound_Lianlian_Dianhua4, 57)
      local snds2 = 57
      ac.timer(1000, count * 3, function(timer)
        snds2 = snds2 + 10
        PlayGlobalSound(Sound_Lianlian_Dadianhua11)
        SetSoundVolume(Sound_Lianlian_Dadianhua11, snds2)
      end)
      ac.loop(3000, function(timer)
        snds = snds + 20
        count = count - 1
        if count == 0 then
          PlayGlobalSound(Sound_Lianlian_Dianhua5)
          abc()
          timer:remove()
        else
          PlayGlobalSound(Sound_Lianlian_Dianhua4)
          SetSoundVolume(Sound_Lianlian_Dianhua4, snds)
        end
      end)
    end
  end,
  ["斩杀扰乱"] = function(u, tg)
    Movie_Boolean = true
    local time = GetTimeOfDay()
    SetTimeOfDay(12)
    DayNightRun = false
    local x, y = u:getxy()
    local x1, y1 = tg:getxy()
    local angle = AngleXY(x, y, x1, y1)
    Effectcreate("war3mapImported\\d95aed2944e02a85.mdl", x, y)
    ShowUnit(u.handle, false)
    u:buffset(u.handle, 9.5, "暂停")
    u:buffset(u.handle, 10.5, "绝对闪避")
    tg:buffset(u.handle, 3, "暂停")
    tg:buffset(u.handle, 10, "沉默")
    local mj = u:createunit("u0ED", x, y, angle)
    local x2, y2 = PolarXY(x1, y1, -200, angle)
    ac.wait(1, function()
      PlayGlobalSound(Yp_yuyin)
      mj:animeact(22)
    end)
    local g = CreateGroupLua()
    ac.wait(1000, function()
      mj:animeact(3)
      ac.wait(350, function()
        unitmove({
          unit = mj.handle,
          time = 0.06,
          distance = 300,
          angle = angle,
          isfly = true
        })
      end)
      ac.wait(450, function()
        FogEnable(false)
        x1, y1 = tg:getxy()
        PlayGlobalSound(Yp_yingxiao2)
        PlayGlobalSound(Yp_yingxiao1)
        u:playsound(Srtr_nadao_pre)
        flashphoto({
          photo = "war3mapImported\\Ph_Yedou_01.tga",
          timeout = 0,
          timehold = 0,
          timein = 1,
          notchangetime = true
        })
        u:setcamera(x1, y1)
        Effectcreate("war3mapImported\\Yp_heiqi1.mdx", x1, y1, 4.25, 1, -100, GetRandomReal(0, 360))
        Effectcreate("war3mapImported\\Yp_heiqi2.mdx", x1, y1, 1, 20, -500, GetRandomReal(0, 360))
        mj:setcolor(255, 255, 255, 0)
        mj:setxy(x2, y2)
        angle = AngleXY(x, y, x1, y1)
        mj:setface(angle)
        ac.wait(1000, function()
          x1, y1 = tg:getxy()
          Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, GetRandomReal(0, 360), 0, 0, 2)
          EffectcreateArgs({
            effect = "war3mapImported\\qiye_zhanji8.mdl",
            x = x1,
            y = y1,
            size = 20,
            height = -250,
            zxz = GetRandomReal(0, 360),
            yxz = 10
          })
          EffectcreateArgs({
            effect = "war3mapImported\\yp_jjianqi2.mdx",
            x = x1,
            y = y1,
            size = 5,
            zxz = GetRandomReal(0, 360)
          })
          EffectcreateArgs({
            effect = "war3mapImported\\5dab9b48c482691b.mdl",
            x = x1,
            y = y1,
            size = 20,
            height = -700,
            zxz = GetRandomReal(0, 360)
          })
          for _, xq in ac.selector():in_rangexy(x1, y1, 300):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:groupadd(g)
            xq:buffset(u.handle, 10, "暂停")
          end
          ForGroupLuaNew(g, function(xq)
            local dx, dy = xq:getxy()
            dx, dy = PolarXY(dx, dy, 50, GetRandomReal(0, 360))
            xq:setxy(dx, dy)
          end)
          u:setcamera(x1, y1)
          u:shockcamera(50, 0.15)
          u:playsound(Srtr_ktnhit_1)
        end)
        ac.wait(2000, function()
          x1, y1 = tg:getxy()
          Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, GetRandomReal(0, 360), 0, 0, 2)
          EffectcreateArgs({
            effect = "war3mapImported\\qiye_zhanji8.mdl",
            x = x1,
            y = y1,
            size = 20,
            height = -250,
            zxz = GetRandomReal(0, 360),
            yxz = 10
          })
          EffectcreateArgs({
            effect = "war3mapImported\\yp_jjianqi2.mdx",
            x = x1,
            y = y1,
            size = 5,
            zxz = GetRandomReal(0, 360)
          })
          EffectcreateArgs({
            effect = "war3mapImported\\5dab9b48c482691b.mdl",
            x = x1,
            y = y1,
            size = 20,
            height = -700,
            zxz = GetRandomReal(0, 360)
          })
          ForGroupLuaNew(g, function(xq)
            local dx, dy = xq:getxy()
            dx, dy = PolarXY(dx, dy, 50, GetRandomReal(0, 360))
            xq:setxy(dx, dy)
          end)
          u:setcamera(x1, y1)
          u:shockcamera(60, 0.15)
          u:playsound(Srtr_ktnhit_2)
        end)
        ac.wait(2250, function()
          x1, y1 = tg:getxy()
          Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, GetRandomReal(0, 360), 0, 0, 2)
          EffectcreateArgs({
            effect = "war3mapImported\\qiye_zhanji8.mdl",
            x = x1,
            y = y1,
            size = 20,
            height = -250,
            zxz = GetRandomReal(0, 360),
            yxz = 10
          })
          EffectcreateArgs({
            effect = "war3mapImported\\yp_jjianqi2.mdx",
            x = x1,
            y = y1,
            size = 5,
            zxz = GetRandomReal(0, 360)
          })
          EffectcreateArgs({
            effect = "war3mapImported\\5dab9b48c482691b.mdl",
            x = x1,
            y = y1,
            size = 20,
            height = -700,
            zxz = GetRandomReal(0, 360)
          })
          ForGroupLuaNew(g, function(xq)
            local dx, dy = xq:getxy()
            dx, dy = PolarXY(dx, dy, 50, GetRandomReal(0, 360))
            xq:setxy(dx, dy)
          end)
          u:setcamera(x1, y1)
          u:shockcamera(70, 0.15)
          u:playsound(Srtr_ktnhit_3)
        end)
        ac.wait(2500, function()
          CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 1, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0, 0, 0.0)
          mj:setcolor(255, 255, 255, 255)
          x, y = mj:getxy()
          x1, y1 = tg:getxy()
          Effectcreate("war3mapImported\\Daji_Hong1.mdl", x1, y1, 0, 40, 200, GetRandomReal(0, 360), 0, 0, 2)
          EffectcreateArgs({
            effect = "war3mapImported\\qiye_zhanji8.mdl",
            x = x1,
            y = y1,
            size = 20,
            height = -250,
            zxz = GetRandomReal(0, 360),
            yxz = 10
          })
          EffectcreateArgs({
            effect = "war3mapImported\\yp_jjianqi2.mdx",
            x = x1,
            y = y1,
            size = 5,
            zxz = GetRandomReal(0, 360)
          })
          EffectcreateArgs({
            effect = "war3mapImported\\5dab9b48c482691b.mdl",
            x = x1,
            y = y1,
            size = 20,
            height = -700,
            zxz = GetRandomReal(0, 360)
          })
          ForGroupLuaNew(g, function(xq)
            local dx, dy = xq:getxy()
            dx, dy = PolarXY(x, y, 200, angle)
            xq:setxy(dx, dy)
          end)
          u:setcamera(x1, y1)
          u:shockcamera(100, 0.15)
          u:playsound(Srtr_ktnhit_4)
          for i = 1, 15 do
            EffectcreateArgs({
              effect = "war3mapImported\\yp_jjianqi2.mdx",
              x = x1,
              y = y1,
              size = GetRandomReal(8, 10),
              height = GetRandomReal(0, 800),
              zxz = GetRandomReal(0, 360),
              xxz = GetRandomReal(0, 360),
              yxz = GetRandomReal(0, 360),
              animespeed = 4
            })
          end
        end)
        ac.wait(2750, function()
          u:playsound(Srtr_nadao_pre)
          mj:animeact(5)
          EffectcreateArgs({
            effect = "war3mapImported\\lh_hd3.mdx",
            x = x,
            y = y,
            time = 1,
            size = 0.5,
            zxz = GetRandomReal(0, 360)
          })
          ac.wait(1, function()
            unitmove({
              unit = mj.handle,
              time = 0.1,
              distance = 50,
              angle = angle,
              isfly = true
            })
            ac.wait(300, function()
              x, y = mj:getxy()
              x1, y1 = tg:getxy()
              x2, y2 = PolarXY(x, y, 150, angle)
              EffectcreateArgs({
                effect = "war3mapImported\\yp_daoguang1.mdx",
                x = x2,
                y = y2,
                size = 4,
                height = 150,
                zxz = GetRandomReal(0, 360),
                xxz = 15,
                animespeed = 1.5
              })
              EffectcreateArgs({
                effect = "war3mapImported\\5dab9b48c482691b.mdl",
                x = x1,
                y = y1,
                size = 4,
                zxz = GetRandomReal(0, 360)
              })
              ForGroupLuaNew(g, function(xq)
                local dx, dy = xq:getxy()
                dx, dy = PolarXY(x1, y1, 50, angle)
                xq:setxy(dx, dy)
              end)
              u:setcamera(x1, y1)
              u:shockcamera(10, 0.15)
              u:playsound(Srtr_ktnhit_1)
            end)
          end)
          ac.wait(750, function()
            mj:animeact(2)
            ac.wait(250, function()
              unitmove({
                unit = mj.handle,
                time = 0.1,
                distance = 25,
                angle = angle,
                isfly = true
              })
            end)
            ac.wait(300, function()
              x, y = mj:getxy()
              x1, y1 = tg:getxy()
              x2, y2 = PolarXY(x, y, 150, angle)
              EffectcreateArgs({
                effect = "war3mapImported\\yp_daoguang1.mdx",
                x = x2,
                y = y2,
                size = 6,
                height = 150,
                zxz = GetRandomReal(0, 360),
                xxz = 180,
                animespeed = 1.5
              })
              EffectcreateArgs({
                effect = "war3mapImported\\5dab9b48c482691b.mdl",
                x = x1,
                y = y1,
                size = 4,
                zxz = GetRandomReal(0, 360)
              })
              ForGroupLuaNew(g, function(xq)
                local dx, dy = xq:getxy()
                dx, dy = PolarXY(x1, y1, 50, angle)
                xq:setxy(dx, dy)
              end)
              u:setcamera(x1, y1)
              u:shockcamera(10, 0.15)
              u:playsound(Srtr_ktnhit_2)
            end)
          end)
          ac.wait(1000, function()
            mj:animeact(1)
            mj:animespeed(2)
            ac.wait(400, function()
              unitmove({
                unit = mj.handle,
                time = 0.1,
                distance = 75,
                angle = angle,
                isfly = true
              })
              ac.wait(100, function()
                x, y = mj:getxy()
                x1, y1 = tg:getxy()
                x2, y2 = PolarXY(x, y, 150, angle)
                EffectcreateArgs({
                  effect = "war3mapImported\\yp_daoguang1.mdx",
                  x = x2,
                  y = y2,
                  size = 6,
                  height = 500,
                  zxz = angle,
                  xxz = -20,
                  animespeed = 1.5
                })
                EffectcreateArgs({
                  effect = "war3mapImported\\5dab9b48c482691b.mdl",
                  x = x1,
                  y = y1,
                  size = 4,
                  zxz = GetRandomReal(0, 360)
                })
                ForGroupLuaNew(g, function(xq)
                  local dx, dy = xq:getxy()
                  dx, dy = PolarXY(x1, y1, 50, angle)
                  xq:setxy(dx, dy)
                end)
                u:setcamera(x1, y1)
                u:shockcamera(10, 0.15)
                u:playsound(Srtr_ktnhit_3)
              end)
            end)
          end)
          ac.wait(1250, function()
            mj:animeact(4)
            mj:animespeed(1)
            ac.wait(400, function()
              PlayGlobalSound(Yb_jianming1)
              unitmove({
                unit = mj.handle,
                time = 0.1,
                distance = 75,
                angle = angle,
                isfly = true
              })
              ac.wait(100, function()
                x, y = mj:getxy()
                x1, y1 = tg:getxy()
                x2, y2 = PolarXY(x, y, 150, angle)
                EffectcreateArgs({
                  effect = "war3mapImported\\yp_daoguang1.mdx",
                  x = x2,
                  y = y2,
                  size = 10,
                  height = 500,
                  zxz = angle,
                  xxz = 190,
                  animespeed = 1.5
                })
                EffectcreateArgs({
                  effect = "war3mapImported\\yp_daoguang1.mdx",
                  x = x2,
                  y = y2,
                  size = 6,
                  height = 500,
                  zxz = angle,
                  xxz = 190,
                  animespeed = 1.5
                })
                ForGroupLuaNew(g, function(xq)
                  local dx, dy = xq:getxy()
                  dx, dy = PolarXY(x, y, 700, angle)
                  xq:setxy(dx, dy)
                end)
                u:setcamera(x1, y1)
                u:shockcamera(30, 0.15)
              end)
            end)
          end)
          ac.wait(2000, function()
            mj:animeact(3)
            ac.wait(400, function()
              PlayGlobalSound(Yb_jianming3)
              unitmove({
                unit = mj.handle,
                time = 0.1,
                distance = 75,
                angle = angle,
                isfly = true
              })
              ac.wait(100, function()
                mj:setcolor(255, 255, 255, 0)
                x, y = mj:getxy()
                x1, y1 = tg:getxy()
                x2, y2 = PolarXY(x, y, 700, angle)
                local tx2 = EffectcreateArgs({
                  effect = "war3mapImported\\qiye_zhanji8.mdl",
                  x = x2,
                  y = y2,
                  time = 2,
                  size = 10,
                  height = -200,
                  zxz = angle - 85,
                  animespeed = 2
                })
                local tx3 = EffectcreateArgs({
                  effect = "war3mapImported\\yp_jjianqi2.mdx",
                  x = x2,
                  y = y2,
                  time = 5,
                  size = 10,
                  height = -200,
                  zxz = angle - 85,
                  animespeed = 0.5
                })
                ac.wait(150, function()
                  SetEffectActSpeed(tx2, 0.01)
                  SetEffectActSpeed(tx3, 0.1)
                  ac.wait(600, function()
                    SetEffectActSpeed(tx3, 0)
                  end)
                end)
                ac.wait(2700, function()
                  SetEffectActSpeed(tx2, 1)
                  SetEffectActSpeed(tx3, 1)
                  EffectcreateArgs({
                    effect = "war3mapImported\\5dab9b48c482691b.mdl",
                    x = x2,
                    y = y2,
                    size = 20,
                    height = -700,
                    zxz = GetRandomReal(0, 360)
                  })
                  CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.2, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0, 0, 0.0)
                  u:shockcamera(200, 0.15)
                  u:playsound(Srtr_ktnhit_3)
                  PlayGlobalSound(Yp_yingxiao1)
                  PlayGlobalSound(Yb_jianming4)
                end)
                CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 0.15, "ReplaceableTextures\\CameraMasks\\DiagonalSlash_mask.blp", 100.0, 0.0, 0.0, 70.0)
                u:setcamera(x1, y1)
                u:shockcamera(100, 0.15)
                u:playsound(Srtr_ktnhit_3)
                for _, xq in ac.selector():in_rangexy(x2, y2, 300):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  local dx, dy = xq:getxy()
                  dx, dy = PolarXY(dx, dy, 50, angle)
                  xq:setxy(dx, dy)
                  xq:groupadd(g)
                  xq:buffset(u.handle, 10, "暂停")
                  EffectcreateArgs({
                    effect = "war3mapImported\\5dab9b48c482691b.mdl",
                    x = dx,
                    y = dy,
                    size = 4,
                    zxz = GetRandomReal(0, 360)
                  })
                end
              end)
            end)
          end)
          ac.wait(2750, function()
            mj:setcolor(255, 255, 255, 255)
            mj:animeact(25)
            mj:animespeed(1.2)
            ac.wait(400, function()
              PlayGlobalSound(bac283)
              unitmove({
                unit = mj.handle,
                time = 0.1,
                distance = 1500,
                angle = angle,
                isfly = true
              })
              ac.wait(100, function()
                x, y = mj:getxy()
                x1, y1 = tg:getxy()
                x2, y2 = PolarXY(x, y, 150, angle)
                EffectcreateArgs({
                  effect = "war3mapImported\\yp_daoguang1.mdx",
                  x = x,
                  y = y,
                  size = 4,
                  height = 100,
                  zxz = angle,
                  xxz = 270,
                  animespeed = 1.2
                })
                EffectcreateArgs({
                  effect = "war3mapImported\\Daji_Hong1.mdl",
                  x = x2,
                  y = y2,
                  size = 40,
                  height = 200,
                  zxz = angle,
                  animespeed = 2
                })
                EffectcreateArgs({
                  effect = "war3mapImported\\qiye_zhanji8.mdl",
                  x = x2,
                  y = y2,
                  size = 20,
                  height = -250,
                  zxz = angle,
                  yxz = 10
                })
                EffectcreateArgs({
                  effect = "war3mapImported\\yp_jjianqi2.mdx",
                  x = x,
                  y = y,
                  time = 4,
                  size = 5,
                  zxz = angle
                })
                EffectcreateArgs({
                  effect = "war3mapImported\\5dab9b48c482691b.mdl",
                  x = x1,
                  y = y1,
                  size = 4,
                  zxz = GetRandomReal(0, 360)
                })
                ForGroupLuaNew(g, function(xq)
                  local dx, dy = xq:getxy()
                  dx, dy = PolarXY(x1, y1, 50, angle)
                  xq:setxy(dx, dy)
                end)
                CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.3, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0, 0, 0.0)
                u:setcamera(x1, y1)
                u:shockcamera(200, 0.15)
                u:playsound(Srtr_ktnhit_3)
              end)
            end)
            ac.wait(2500, function()
              ForGroupLuaNew(g, function(xq)
                xq:effectadd("war3mapImported\\Texiao_Xuebao.mdx")
                xq:buffset(u.handle, 5, "暂停")
                if xq:isboss() then
                  if not xq:hasdata("夜卜-影响单位") then
                    u:setdata("夜卜-斩杀扰乱世间之物")
                  end
                  DamageUnit({
                    bj = "祸津神(斩杀扰乱世间之物)",
                    unit = xq.handle,
                    source = u.handle,
                    damage = 0.1 * xq:gethp(),
                    level = 1,
                    type = "物理",
                    isvest = false,
                    isattack = true,
                    isnoarmor = false,
                    element = "无",
                    extradata = {
                      "系统-本次伤害无视伤害抗性"
                    }
                  })
                  xq:setdata("夜卜-影响单位")
                else
                  DamageUnit({
                    bj = "祸津神(斩杀扰乱世间之物)",
                    unit = xq.handle,
                    source = u.handle,
                    damage = 0.1 * xq:gethp(),
                    level = 1,
                    type = "物理",
                    isvest = false,
                    isattack = true,
                    isnoarmor = false,
                    element = "无",
                    extradata = {
                      "系统-本次伤害无视伤害抗性"
                    }
                  })
                end
              end)
              FogEnable(true)
              Movie_Boolean = false
              DayNightRun = true
              SetTimeOfDay(time)
              x, y = mj:getxy()
              Effectcreate("war3mapImported\\d95aed2944e02a85.mdl", x, y)
              u:setxy(x, y)
              ShowUnit(u.handle, true)
              u:setface(angle)
              getplayer(u.owner):select(u.handle)
              mj:remove()
            end)
          end)
        end)
      end)
    end)
  end,
  ["春秋蝉"] = function(u)
    local sy = u.ownerid
    u:animespeed(1)
    ShowUnit(u.handle, true)
    SendMsgAll(u:getplayername() .. "|cFF666666使用了春秋蝉逆转时空|r", 30)
    u:sendmessage("【逆转时空】\n阻止游戏失败或自身删模,并复活自身\n降低10幸运与0.1幸运系数\n提升5神力承载上限\n提升50%当前基础生命上限\n提升25%当前全属性\n提升5%当前伤害加成\n提升50%当前暴击伤害")
    u:changedata("春秋蝉-触发概率", 0.5, 1)
    u:buffset(u.handle, 18, "永恒")
    u:buffset(u.handle, 18, "绝对闪避")
    u:setdata("春秋蝉-已触发")
    u:clearbuff("暂停")
    u:clearbuff("无敌")
    StopSoundBJ(BGM_Fangyuan_01, false)
    PlayGlobalSound(Sound_Fangyuan_01)
    u:chat("岂不闻天无绝人之路")
    u:chat("只要我想走", 3.5)
    u:chat("路，就在脚下！", 5.2)
    ac.wait(7500, function()
      PlayGlobalSound(BGM_Fangyuan_01)
      SendMsgAll("|cFF5C5C5CB|r|cFF686868G|r|cFF737373M|r|cFF7F7F7F：|r|cFF8B8B8B《|r|cFF979797十|r|cFFA2A2A2年|r|cFFAEAEAE人|r|cFFBABABA间|r|cFFC6C6C6》|r")
      songtext({
        text = {
          {
            starttime = 0,
            str = "光是谁燃烛照亮"
          },
          {
            starttime = 3.8,
            str = "时间设下的迷藏"
          },
          {
            starttime = 7.6,
            str = "光置换明暗立场"
          },
          {
            starttime = 13.5,
            str = "肆意流淌"
          },
          {
            starttime = 15.4,
            str = "看谁站过的地方"
          },
          {
            starttime = 19.2,
            str = "棋局已百孔千疮"
          },
          {
            starttime = 23.4,
            str = "看眼前最真假相"
          },
          {
            starttime = 27.2,
            str = "假又何妨"
          },
          {
            starttime = 30.5,
            str = "怀揣着炽烈顽心走向最宽容刑场"
          },
          {
            starttime = 38.5,
            str = "裂过碎过都空洞地回响"
          },
          {
            starttime = 46.2,
            str = "到最后竟庆幸于夕阳仍留在身上"
          },
          {
            starttime = 54,
            str = "来不及讲故事多跌宕"
          },
          {
            starttime = 61,
            str = "有最奇崛的峰峦"
          },
          {
            starttime = 65.3,
            str = "成全过你我张狂"
          },
          {
            starttime = 69.1,
            str = "海上清辉与圆月 盛进杯光"
          },
          {
            starttime = 77.1,
            str = "有最孤傲的雪山 静听过你我诵章"
          },
          {
            starttime = 84.7,
            str = "世人惊羡的桥段 不过寻常",
            time = 7.3
          }
        },
        color = {"FF5C5C5C", "FFDDDDDD"},
        isjbcolor = true
      })
    end)
    flashphoto({
      photo = "Ph_Fangyuan.tga",
      timeout = 4,
      timehold = 4,
      timein = 4
    })
    u:changemaxhp(0.5 * Correction_MHpOrigin[sy])
    u:changedata("幸运", -10)
    u:changedata("幸运系数", -0.1)
    u:changedata("系统-神力承载上限", 5)
    ChangeValue(DamageSystem_Shjc, sy, 0.1 * (0.5 * u:getdata("显示-伤害加成")))
    ChangeValue(DamageSystem_Baoshang, sy, 0.5 * u:getdata("显示-暴击伤害"))
    u:addstr(0.5 * u:getoriginstr())
    u:addagi(0.5 * u:getoriginagi())
    u:addint(0.5 * u:getoriginint())
  end,
  ["天降之物"] = function(u)
    do
      local whitephoto = class.panel:builder({
        parent = OriginPanel,
        x = 0,
        y = 0,
        w = 1920,
        h = 850,
        normal_image = "White.tga"
      })
      whitephoto:set_alpha(0)
      ac.wait(100, function()
        u:sethp(1, true)
      end)
      u:setdata("伊卡洛斯-演出死亡抗拒")
      u:buffset(u.handle, 21, "暂停")
      u:buffset(u.handle, 21, "永恒")
      u:buffset(u.handle, 28, "绝对闪避")
      u:chat("我要平静地生活下去！")
      ac.wait(3400, function()
        u:chat("回家！看电视！睡大觉！")
      end)
      ac.wait(7400, function()
        u:chat("唔啊啊啊……！")
      end)
      ac.wait(7500, function()
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:buffset(u.handle, 18, "绝对闪避")
        end)
        local aplha = 0
        ac.loop(30, function(timer)
          aplha = aplha + 10
          whitephoto:set_alpha(aplha)
          if 250 <= aplha then
            ac.wait(3000, function()
              flashphoto({
                photo = "Ph_Ykls_01.tga",
                timeout = 0,
                timehold = 7,
                timein = 6
              })
              SendMsgAll("|cFFFF99FF【BGM:アルファ】", 30)
              ac.loop(30, function(timer2)
                aplha = aplha - 3
                if aplha <= 0 then
                  whitephoto:hide()
                  ac.wait(1000, function()
                    whitephoto:destroy()
                  end)
                  timer2:remove()
                elseif 5 <= aplha then
                  whitephoto:set_alpha(aplha)
                end
              end)
            end)
            timer:remove()
          end
        end)
      end)
      PlayGlobalSound(Sound_Ykls_Get_01)
      PlayBGM({
        bgm = 0,
        time = 51,
        ID = 0
      })
      NPCChat({
        name = "|cFFF4A3DB伊|r|cFFEEA8C9卡|r|cFFE9AEB8洛|r|cFFE3B3A6斯|r",
        chaticon = "Chat_Ykls.tga",
        chattext = {
          {
            text = "|cFFFF99FF『|r|cFFF2A6FF铭|r|cFFE6B2FF印|r|cFFD9BFFF,|r|cFFCCCCFF开|r|cFFBFD9FF始|r|cFFB2E6FF』|r",
            time = 23.6
          },
          {
            text = "|cFFFF99FF初次见面|r",
            time = 36.9
          },
          {
            text = "|cFFFF99FF我是玩赏用天使机器人|r",
            time = 38.9
          },
          {
            text = "|cFFFF99FF将满足您的一切愿望|r",
            time = 44.4
          },
          {
            text = "|cFFFF99FF我的|cff5bf4ff「主人」",
            time = 47.3
          }
        }
      })
      ac.wait(49000, function()
        PlayBGM({
          bgm = BGM_Ykls_01,
          time = 135,
          ID = 226,
          unit = u.handle
        })
      end)
      ac.wait(27000, function()
        u:deldata("伊卡洛斯-演出死亡抗拒")
        u:sethp(100, true)
        local dpools = {
          Vars_Ciyuan_EventOnly
        }
        u:setdata("系统-特殊获取中")
        local str = herogetvar(u.handle, dpools, "次元", "伊卡洛斯")
        u:deldata("系统-特殊获取中")
        local pools = {
          Guoboyiwu_Only
        }
        local poolsstr = "稀有过波遗物"
        u:setdata("系统-变异栏返回变异表")
        local bind = herogetvar(u.handle, pools, poolsstr, "伊卡洛斯之翼")
        u:deldata("系统-变异栏返回变异表")
        if bind then
          yiwuhuoqu(u, bind)
        end
      end)
    end
  end,
  ["伊利亚吟唱"] = function(u)
    u:effectadd("war3mapImported\\[ake]war3ake.com - 8938363897730084317466280.mdx", "origin", 64)
    PlayBGM({
      bgm = BGM_Yly_01,
      time = 65,
      ID = 221,
      unit = u.handle
    })
    SendDtimeMsgAll(0, "|cFFBBB3CA『|r|cFFBEB6CB拯|r|cFFC2B9CC救|r|cFFC5BDCD了|r|cFFC9C0CE被|r|cFFCCC3CF恶|r|cFFD0C6D0魔|r|cFFD3C9D1操|r|cFFD6CCD2控|r|cFFDAD0D3的|r|cFFDDD3D4教|r|cFFE1D6D5皇|r|cFFE4D9D6大|r|cFFE8DCD7人|r|cFFEBE0D8』|r")
    SendDtimeMsgAll(3.5, "|cFFBBB3CA『|r|cFFC1B9CC用|r|cFFC7BECE神|r|cFFCDC4CF杖|r|cFFD3CAD1的|r|cFFDACFD3力|r|cFFE0D5D5量|r|cFFE6DBD6』|r")
    SendDtimeMsgAll(5.1, "|cFFBBB3CA『|r|cFFC0B8CB扫|r|cFFC5BCCD除|r|cFFCAC1CE了|r|cFFCFC6D0最|r|cFFD4CAD1后|r|cFFD9CFD3的|r|cFFDED3D4诅|r|cFFE3D8D6咒|r|cFFE8DDD7』|r")
    SendDtimeMsgAll(11.7, "|cFFBBB3CA『|r|cFFC4BCCD好|r|cFFCDC4CF奇|r|cFFD6CCD2怪|r|cFFE0D5D5』|r")
    SendDtimeMsgAll(13.3, "|cFFBBB3CA『|r|cFFBFB7CB为|r|cFFC3BACC什|r|cFFC7BECD么|r|cFFCBC2CF一|r|cFFCFC5D0切|r|cFFD3C9D1都|r|cFFD6CCD2这|r|cFFDAD0D3么|r|cFFDED4D4简|r|cFFE2D7D5单|r|cFFE6DBD7呢|r|cFFEADFD8』|r")
    SendDtimeMsgAll(43.4, "|cFF990000『|r|cFF970803诅|r|cFF950F05咒|r|cFF921708并|r|cFF901F0A非|r|cFF8E260D被|r|cFF8C2E0F消|r|cFF8A3512除|r|cFF883D14了|r|cFF854517』|r")
    SendDtimeMsgAll(46.1, "|cFF990000『|r|cFF970602只|r|cFF960C04是|r|cFF941206被|r|cFF921808封|r|cFF901E0A印|r|cFF8F240C在|r|cFF8D2A0E了|r|cFF8B3010我|r|cFF8A3612的|r|cFF883C14体|r|cFF864216内|r|cFF844818』|r")
    SendDtimeMsgAll(50.2, "|cFF990000『|r|cFF970702集|r|cFF950E05齐|r|cFF931507了|r|cFF911C09一|r|cFF8F230C切|r|cFF8D2A0E诅|r|cFF8B3110咒|r|cFF893813之|r|cFF873F15后|r|cFF854617』|r")
    SendDtimeMsgAll(53.8, "|cFF990000『|r|cFF960A04最|r|cFF931507后|r|cFF90200A一|r|cFF8D2A0E定|r|cFF8A3412会|r|cFF873F15』|r")
    SendDtimeMsgAll(60, "|cFF990000『|r|cFF960C04将|r|cFF921808我|r|cFF8F240C…|r|cFF8B3010…|r|cFF883C14』|r")
    local cs = 0
    u:buffset(u.handle, 2, "永恒")
    u:buffset(u.handle, 2, "暂停")
    ac.loop(1000, function(timer)
      cs = cs + 1
      u:buffset(u.handle, 2, "永恒")
      u:buffset(u.handle, 2, "暂停")
      if cs == 60 then
        timer:remove()
      end
    end)
    songtext({
      text = {
        {
          starttime = 18,
          str = "黑暗就快将光芒吞没",
          time = 6.3
        },
        {
          starttime = 25.2,
          str = "记忆还保有原有的轮廓",
          time = 8.7
        },
        {
          starttime = 36.3,
          str = "没有了光就有自由",
          time = 5.9
        }
      },
      color = {"FFA31400", "FFEBA300"},
      isjbcolor = true
    })
    ac.wait(62000, function()
      u:buffset(u.handle, 3, "暂停")
      u:buffset(u.handle, 3, "绝对闪避")
      ac.wait(1500, function()
        local gl = 20 + 1 * u:getdata("伊利亚-羁绊波数")
        if GetRandom100(gl) then
          SendMsgAll("|cFF990000『|r" .. u:getplayername() .. "|cFFA31400唤|r|cFFAD2900起|r|cFFB83D00了|r|cFFC25200神|r|cFFCC6600迹|r|cFFD67A00…|r|cFFE08F00…|r|cFFEBA300』|r")
          AdvanceGet["伊利亚神化"](u)
        elseif u:hasdata("伊利亚-羁绊达成") then
          local whitephoto = class.panel:builder({
            parent = OriginPanel,
            x = 0,
            y = 0,
            w = 1920,
            h = 850,
            normal_image = "White.tga"
          })
          whitephoto:set_alpha(0)
          PlayGlobalSound(Sound_Yly_N50)
          NPCChat({
            name = "|cFFBBB3CA伊|r|cFFD6CCD2利|r|cFFF2E6DA亚|r",
            chaticon = "Chat_MMT_Yiliya.blp",
            chattext = {
              {
                text = "|cFFBBB3CA诶~~",
                time = 0.4
              },
              {
                text = "|cFFBBB3CA本来不应该变成这样的",
                time = 2
              },
              {
                text = "|cFFBBB3CA只是想保护大家而已",
                time = 4.5
              },
              {
                text = "|cFFBBB3CA我的心中只有我有的情感",
                time = 8.5
              },
              {
                text = "|cFFBBB3CA你给予的爱、勇气、正义、坚强",
                time = 11.9
              },
              {
                text = "|cFFBBB3CA都是我所没有的",
                time = 15.7
              },
              {
                text = "|cFFBBB3CA我用残存的|r|cFFFFFF99「勇气」|r|cFFBBB3CA伸出的手",
                time = 18.4
              }
            }
          })
          NPCChat({
            name = "|cFFBBB3CA伊|r|cFFD6CCD2利|r|cFFF2E6DA亚|r",
            chaticon = "Chat_MMT_Yiliya_Black.blp",
            chattext = {
              {
                text = "|cFF949596却|r|cFF7B7C7D也|r|cFF636364没|r|cFF4A4B4B赶|r|cFF313232上……|r",
                time = 21.8
              }
            }
          })
          do
            local time = 6.6
            musiccolortext({
              strz = {
                {
                  str = "なぜだ？",
                  time = time - 0.5,
                  showtime = 0.5,
                  staytime = 2,
                  fadetime = 2,
                  sx = 1450,
                  sy = 170,
                  dx = 60
                },
                {
                  str = "どこだ？",
                  time = time - 0.5 + 0.5,
                  showtime = 0.5,
                  staytime = 3,
                  fadetime = 2,
                  sx = 50,
                  sy = 370,
                  dx = 60
                },
                {
                  str = "間違えちゃったんだろう？",
                  time = time - 0.5 + 0.9,
                  showtime = 0.5,
                  staytime = 4,
                  fadetime = 2,
                  sx = 650,
                  sy = 570,
                  dx = 60
                }
              },
              colorstart = "00FFFFFF",
              colorend = "FF000000"
            })
            ac.wait(21800, function()
              flashphoto({
                photo = "Ph_Yly_01.tga",
                timeout = 0,
                timehold = 1,
                timein = 5
              })
            end)
            songtext({
              text = {
                {
                  starttime = 23.2,
                  str = "与古老相道别"
                },
                {
                  starttime = 28.3,
                  str = "重新开始"
                },
                {
                  starttime = 31.8,
                  str = "脚踏实地"
                },
                {
                  starttime = 35.1,
                  str = "与你手牵着手"
                },
                {
                  starttime = 40.4,
                  str = "结下牵绊"
                },
                {
                  starttime = 44.8,
                  str = "旅行途中",
                  time = 2.5
                },
                {
                  starttime = 58.8,
                  str = "花瓣之雪飞舞"
                },
                {
                  starttime = 64,
                  str = "向着月光所照之地"
                },
                {
                  starttime = 69,
                  str = "向着月光所照之地",
                  time = 9
                }
              },
              color = {"FFBBB3CA", "FFF8D6FF"},
              isjbcolor = true
            })
            local zm = {
              {
                time = 47.3,
                text = "|cFF9999CC我|r|cFFBBAADD呢|r"
              },
              {
                time = 48.4,
                text = "|cFF9999CC这|r|cFFA69FD2场|r|cFFB2A6D9旅|r|cFFBFACDF程|r|cFFCCB2E6结|r|cFFD9B9EC束|r|cFFE6BFF2后|r"
              },
              {
                time = 50.2,
                text = "|cFF9999CC想|r|cFFA29DD0再|r|cFFAAA2D4去|r|cFFB2A6D9看|r|cFFBBAADD看|r|cFFC4AEE1变|r|cFFCCB2E6和|r|cFFD4B7EA平|r|cFFDDBBEE的|r|cFFE6BFF2各|r|cFFEEC4F6国|r"
              },
              {
                time = 55,
                text = "|cFF9999CC看|r|cFFA29DD0看|r|cFFAAA2D4和|r|cFFB2A6D9你|r|cFFBBAADD一|r|cFFC4AEE1同|r|cFFCCB2E6守|r|cFFD4B7EA护|r|cFFDDBBEE的|r|cFFE6BFF2世|r|cFFEEC4F6界|r"
              },
              {
                time = 77,
                text = "|cFF9999CC温|r|cFFA8A0D3暖|r|cFFB6A8DB的|r|cFFC5AFE2光|r|cFFD3B6E9…|r|cFFE2BDF0…|r"
              },
              {
                time = 79.4,
                text = "|cFF9999CC终|r|cFFA69FD2于|r|cFFB2A6D9 |r|cFFBFACDF天|r|cFFCCB2E6要|r|cFFD9B9EC亮|r|cFFE6BFF2了|r"
              },
              {
                time = 83.2,
                text = "|cFF9999CC啊|r|cFFA49FD2啊|r|cFFB0A4D7…|r|cFFBBAADD…|r|cFFC6B0E3我|r|cFFD2B5E8也|r|cFFDDBBEE…|r|cFFE8C1F4…|r"
              },
              {
                time = 86.8,
                text = "|cFF9999CC好|r|cFFA69FD2想|r|cFFB2A6D9看|r|cFFBFACDF看|r|cFFCCB2E6啊|r|cFFD9B9EC…|r|cFFE6BFF2…|r"
              }
            }
            for index, value in ipairs(zm) do
              SendDtimeMsgAll(value.time, "|cFF9999CC『|r" .. value.text .. "|cFF9999CC』|r")
            end
            ac.wait(55000, function()
              local aplha = 0
              ac.loop(30, function(timer)
                aplha = aplha + 3
                whitephoto:set_alpha(aplha)
                if 250 <= aplha then
                  flashphoto({
                    photo = "Ph_Yly_02.tga",
                    timeout = 0,
                    timehold = 3,
                    timein = 4
                  })
                  ac.loop(30, function(timer2)
                    aplha = aplha - 5
                    whitephoto:set_alpha(aplha)
                    if aplha <= 0 then
                      whitephoto:hide()
                      timer2:remove()
                    end
                  end)
                  timer:remove()
                end
              end)
            end)
            ac.wait(86000, function()
              local aplha = 0
              whitephoto:set_alpha(0)
              whitephoto:show()
              ac.loop(30, function(timer)
                aplha = aplha + 10
                whitephoto:set_alpha(aplha)
                if 250 <= aplha then
                  flashphoto({
                    photo = "Ph_Yly_03.tga",
                    timeout = 0,
                    timehold = 2,
                    timein = 3
                  })
                  ac.loop(30, function(timer2)
                    aplha = aplha - 15
                    whitephoto:set_alpha(aplha)
                    if aplha <= 0 then
                      whitephoto:hide()
                      timer2:remove()
                    end
                  end)
                  timer:remove()
                end
              end)
            end)
            ac.wait(90000, function()
              whitephoto:destroy()
            end)
            ac.wait(55000, function()
              ForGroupLuaNew(Group_PlayHero, function(xq)
                if xq.handle ~= u.handle and xq:hasdata("变异判定-百百") then
                  xq:setdata("百百-爱哭鬼判定")
                end
              end)
              AdvanceGet["伊利亚神化失败2"](u)
            end)
          end
        else
          SendMsgAll("|cFF990000『|r" .. u:getplayername() .. "|cFF970B0A的|r|cFF961614诅|r|cFF94211E咒|r|cFF932C28爆|r|cFF913732发|r|cFF90433B了|r|cFF8E4E45…|r|cFF8D594F…|r|cFF8B6459』|r")
          AdvanceGet["伊利亚神化失败"](u)
        end
      end)
    end)
  end,
  ["青水斩杀"] = function(u)
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:buffset(u.handle, 6, "绝对闪避")
    end)
    do
      local texth = 100
      local size = 1200
      local yx = Sound_Bfsmqn_04
      local ph1 = "Ph_Bfsm_Zs.tga"
      local ph2 = "Ph_Bfsm_Zs2.tga"
      local zimu = "Ph_AoyituUIZimu.blp"
      local zimux = 650
      local zimuw = 600
      local dtime = 3
      local freq = 800
      local t = 0
      local base_amp = 25
      local amp = base_amp
      local amp_boost = 0
      local amp_boost_max = 45
      local boost_state = "idle"
      local boost_hold_time = 0
      local boost_hold_max = 1
      local boost_decay = 0.82
      local boost_cd = 2
      local hasc = false
      if u:hasdata("青水皮肤-茉子") then
        dtime = 4
        ph1 = "Ph_Bfsm_Mz_03.tga"
        ph2 = "Ph_Bfsm_Mz_032.tga"
        size = 1150
        if GetRandom100(10) then
          yx = Mozi_Tf_F
          zimu = "Bfsm_Aoyizimu_Mz04.blp"
          zimux = 725
          zimuw = 500
          texth = 95
        else
          yx = Mozi_Zhansha_03
          zimu = "Bfsm_Aoyizimu_Mz03.blp"
          zimux = 725
          zimuw = 500
          texth = 95
        end
        if u:hasdata("波风水门-茉子-奥义变招判定") then
          if u:hasdata("波风水门-轮椅模式") and not hasc then
            dtime = 3
            hasc = true
            yx = Mozi_Zhansha_02
            ph1 = "Ph_Bfsm_Mz_02.tga"
            ph2 = "Ph_Bfsm_Mz_022.tga"
            zimu = "Bfsm_Aoyizimu_Mz02.blp"
            zimux = 800
            zimuw = 400
            size = 1150
            texth = 95
          end
        elseif u:hasdata("波风水门天赋-虽然是对手但是你还不赖嘛") and not hasc and GetRandom100(50) then
          hasc = true
          yx = Mozi_Zhansha_04
          ph1 = "Ph_Bfsm_Pf_Zs.tga"
          ph2 = "Ph_Bfsm_Pf_Zs2.tga"
          zimu = "Ph_AoyituUIZimu.blp"
          zimux = 675
          zimuw = 600
          size = 1150
          texth = 100
        end
        if u:hasdata("波风水门天赋-背负着火影之名我不能输") and not hasc and GetRandom100(33) then
          hasc = true
          ph1 = "Ph_Bfsm_Mz_04.tga"
          ph2 = "Ph_Bfsm_Mz_042.tga"
          size = 1150
          if GetRandom100(20) then
            yx = Mozi_Tf_F
            zimu = "Bfsm_Aoyizimu_Mz04.blp"
            zimux = 725
            zimuw = 500
            texth = 95
          else
            yx = Mozi_Tf_W
            zimu = "Bfsm_Aoyizimu_Mz05.blp"
            zimux = 850
            zimuw = 300
            texth = 95
          end
        end
        if u:hasdata("波风水门天赋-无论发生什么我都会保护你") and not hasc and GetRandom100(33) then
          hasc = true
          yx = Mozi_Zhansha_01
          ph1 = "Ph_Bfsm_Mz_01.tga"
          ph2 = "Ph_Bfsm_Mz_012.tga"
          zimu = "Bfsm_Aoyizimu_Mz01.blp"
          zimux = 525
          zimuw = 900
          size = 1200
          texth = 100
          dtime = 5
        end
        if not u:hasdata("波风水门-轮椅模式") then
          if u:hasdata("波风水门天赋-背负着火影之名我不能输") then
            if GetRandom100(25) then
              StopSoundBJ(BGM_Mozi_Zhansha_01, false)
              StopSoundBJ(BGM_Mozi_Zhansha_02, false)
              PlayBGM({
                bgm = BGM_Mozi_Zhansha_02,
                time = 120,
                ID = 227,
                unit = u.handle
              })
            else
              ac.wait(2000, function()
                StopSoundBJ(BGM_Mozi_Zhansha_01, false)
                StopSoundBJ(BGM_Mozi_Zhansha_02, false)
                PlayBGM({
                  bgm = BGM_Mozi_Zhansha_01,
                  time = 90,
                  ID = 227,
                  unit = u.handle
                })
              end)
            end
          else
            ac.wait(2000, function()
              StopSoundBJ(BGM_Mozi_Zhansha_01, false)
              StopSoundBJ(BGM_Mozi_Zhansha_02, false)
              PlayBGM({
                bgm = BGM_Mozi_Zhansha_01,
                time = 90,
                ID = 227,
                unit = u.handle
              })
            end)
          end
        end
      else
        if GetRandom100(25) then
          yx = minato_aoyi_4
          ph1 = "Ph_Bfsm_Zsb.tga"
          ph2 = "Ph_Bfsm_Zsb2.tga"
          zimu = "Ph_AoyituUIZimu2.blp"
          zimux = 575
          zimuw = 800
          dtime = 4
          if u:hasdata("波风水门天赋-背负着火影之名我不能输") and GetRandom100(50) then
            yx = fou_19E
            ph1 = "Ph_Bfsm_Zsc.tga"
            ph2 = "Ph_Bfsm_Zsc2.tga"
            zimu = "Ph_AoyituUIZimu3.blp"
            zimux = 575
            zimuw = 800
            dtime = 4
          end
        end
        if not u:hasdata("波风水门-轮椅模式") then
          PlayBGM({
            bgm = BGM_Bfsm_Zs,
            time = 150,
            ID = 213,
            unit = u.handle
          })
        end
      end
      local dx = (1920 - size * 2.2) / 2 - 30
      local flashphotoclass2 = class.panel:builder({
        parent = OriginPanel,
        x = dx,
        y = -30,
        w = size * 2.2,
        h = size * 1,
        normal_image = ph1
      })
      local flashphotoclass = class.panel:builder({
        parent = OriginPanel,
        x = 0,
        y = 0,
        w = 1920,
        h = 1080,
        normal_image = "Ph_AoyituUI.tga"
      })
      local flashphotoclasstext = class.panel:builder({
        parent = flashphotoclass,
        x = zimux,
        y = 835,
        w = zimuw,
        h = texth,
        normal_image = zimu
      })
      local base_x, base_y = dx, -30
      ac.wait(GetRandomReal(500, 1000), function()
        flashphotoclass2:set_normal_image(ph2)
        ac.wait(GetRandomReal(150, 300), function()
          flashphotoclass2:set_normal_image(ph1)
        end)
      end)
      ac.wait(GetRandomReal(2000, 2500), function()
        flashphotoclass2:set_normal_image(ph2)
        ac.wait(GetRandomReal(250, 400), function()
          flashphotoclass2:set_normal_image(ph1)
        end)
      end)
      ac.loop(16, function(timer)
        t = t + 0.016
        boost_cd = boost_cd - 0.016
        if boost_cd <= 0 and boost_state == "idle" then
          amp_boost = amp_boost_max
          boost_state = "hold"
          boost_hold_time = boost_hold_max
          boost_cd = GetRandomReal(1.5, 2)
        end
        if boost_state == "hold" then
          amp_boost = amp_boost_max
          boost_hold_time = boost_hold_time - 0.016
          if boost_hold_time <= 0 then
            boost_state = "decay"
          end
        elseif boost_state == "decay" then
          amp_boost = amp_boost * boost_decay
          if amp_boost < 1 then
            amp_boost = 0
            boost_state = "idle"
          end
        end
        amp = base_amp + amp_boost
        local dx = base_amp * math.sin(t * freq)
        local dy = amp * 0.5 * math.cos(t * freq * 0.8)
        flashphotoclass2:set_position(base_x + dx, base_y + dy)
        if t >= dtime + 1 then
          timer:remove()
        end
      end)
      local flashphotoclass4 = class.panel:builder({
        parent = OriginPanel,
        x = 0,
        y = 0,
        w = 1920,
        h = 1080,
        normal_image = "White.tga"
      })
      flashphotoclass4:set_alpha(0)
      flashphotoclass:hide()
      flashphotoclass2:hide()
      local aplha = 0
      ac.loop(30, function(timer)
        aplha = aplha + 25
        flashphotoclass4:set_alpha(aplha)
        if 250 <= aplha then
          PlayGlobalSound(yx)
          flashphotoclass:show()
          flashphotoclass2:show()
          ac.loop(30, function(timer2)
            aplha = aplha - 25
            flashphotoclass4:set_alpha(aplha)
            if aplha <= 0 then
              flashphotoclass4:hide()
              timer2:remove()
            end
          end)
          timer:remove()
        end
      end)
      ac.wait(dtime * 1000, function()
        flashphotoclass4:show()
        local aplha = 0
        ac.loop(30, function(timer)
          aplha = aplha + 25
          flashphotoclass4:set_alpha(aplha)
          if 250 <= aplha then
            flashphotoclass:hide()
            flashphotoclass2:hide()
            ac.loop(30, function(timer2)
              aplha = aplha - 25
              flashphotoclass4:set_alpha(aplha)
              if aplha <= 0 then
                flashphotoclass4:destroy()
                timer2:remove()
              end
            end)
            timer:remove()
          end
        end)
      end)
    end
  end,
  ["妖梦斩杀"] = function(u)
    StopSoundBJ(BGM_Umzs, false)
    StopSoundBJ(BGM_Umzs2, false)
    StopSoundBJ(BGM_Youmu_01, false)
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:buffset(u.handle, 10, "绝对闪避")
    end)
    if u:getdata("妖梦-斩杀闪图") == 2 then
      ac.wait(500, function()
        PlayBGM({
          bgm = BGM_Umzs2,
          time = 45,
          ID = 209,
          unit = u.handle
        })
      end)
      flashphoto({
        photo = "Ph_Umzs3.tga",
        timeout = 1,
        timehold = 3,
        timein = 1
      })
      local strz = {}
      for i = 1, 100 do
        local add = {
          str = "myon",
          time = 0.01 * i,
          showtime = 1,
          staytime = 1,
          fadetime = 0.05 * i,
          sx = GetRandomReal(10, 1800),
          sy = GetRandomReal(10, 780),
          dx = 35
        }
        table.insert(strz, add)
      end
      musiccolortext({
        strz = strz,
        colorstart = "00FFFFFF",
        colorend = "FF983DFF"
      })
    else
      PlayBGM({
        bgm = BGM_Umzs,
        time = 32,
        ID = 209,
        unit = u.handle
      })
      flashphoto({
        photo = "Ph_Umzs.tga",
        timeout = 3,
        timehold = 3,
        timein = 3
      })
      musiccolortext({
        strz = {
          {
            str = "『 一 念 既 起 ，",
            time = 0,
            staytime = 8,
            fadetime = 3,
            sx = 150,
            sy = 250,
            dx = 35
          },
          {
            str = "諸 劫 皆 空 』",
            time = 1,
            staytime = 8,
            fadetime = 3,
            sx = 350,
            sy = 325,
            dx = 35
          },
          {
            str = "『 六 道 不 渡 ，",
            time = 0,
            staytime = 8,
            fadetime = 3,
            sx = 1150,
            sy = 550,
            dx = 35
          },
          {
            str = "万 象 歸 終 』",
            time = 1,
            staytime = 8,
            fadetime = 3,
            sx = 1350,
            sy = 625,
            dx = 35
          }
        },
        colorstart = "00FFFFFF",
        colorend = "FF3BE219"
      })
    end
  end,
  ["愿"] = function(u)
    PlayBGM({
      bgm = BGM_Yuanwang_01,
      time = 310,
      ID = 181,
      unit = u.handle
    })
    local text = class.text:builder({
      parent = OriginPanel,
      x = 800,
      y = 625,
      w = 300,
      h = 300,
      text = "",
      align = "center",
      font_size = 12,
      color = "FFFFFFFF"
    })
    ac.wait(300000, function()
      text:destroy()
    end)
    colorGradientText(text, {
      "FF3366FF",
      "FF99CCFF",
      "FF99CCFF",
      "FF3366FF"
    }, 4, 50, true)
    text:set_text("『当一花世界盛开』")
    textjianxian(2, text)
    textjbchange({
      text = text,
      strstart = "『当一花世界盛开 ",
      strz = "我饰",
      strend = "』|r",
      time = 0.5,
      shunxu = 1,
      waittime = 4.9
    })
    textjbchange({
      text = text,
      strstart = "『当一花世界盛开 我饰",
      strz = "以色彩",
      strend = "』|r",
      time = 0.8,
      shunxu = 1,
      waittime = 6.4
    })
    ac.wait(7500.0, function()
      textjianyin(0.5, text)
    end)
    musiccolortext({
      strz = {
        {
          str = " 『 睁 开 眼 睛 』 ",
          time = 2.8,
          showtexttime = 0.5,
          staytime = 3.5,
          fadetime = 0.75,
          sx = 750 - GetRandomReal(650, 700),
          sy = GetRandomReal(600, 750),
          dx = 35,
          font = "fontyt"
        },
        {
          str = " 『 我 是 谁 』 ",
          time = 9.1,
          showtexttime = 0.5,
          staytime = 3.5,
          fadetime = 0.75,
          sx = 750 + GetRandomReal(650, 700),
          sy = GetRandomReal(600, 750),
          dx = 35,
          font = "fontyt"
        },
        {
          str = " 『 何 人 赐 我 灵 魂 』 ",
          time = 12.5,
          showtexttime = 0.5,
          staytime = 3.5,
          fadetime = 0.75,
          sx = 750 - GetRandomReal(650, 700),
          sy = GetRandomReal(600, 750),
          dx = 35,
          font = "fontyt"
        }
      },
      colorstart = "00FFFFFF",
      colorend = "FFBB0000"
    })
    ac.wait(8200.0, function()
      text:set_text("『予它阳光雨露』")
      textjianxian(2, text)
    end)
    textjbchange({
      text = text,
      strstart = "『予它阳光雨露 ",
      strz = "予它",
      strend = "』|r",
      time = 0.6,
      shunxu = 1,
      waittime = 12.5
    })
    textjbchange({
      text = text,
      strstart = "『予它阳光雨露 予它",
      strz = "热烈的新生",
      strend = "』|r",
      time = 1.4000000000000008,
      shunxu = 1,
      waittime = 13.6
    })
    ac.wait(15500.0, function()
      textjianyin(0.5, text)
    end)
    do
      local downtime = 16
      local waittime = 16
      ac.wait(waittime * 1000, function()
        musiccolortext({
          strz = {
            {
              str = " 『 不 愿 遗 忘 』 ",
              time = 18.8 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 750 + GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = " 『 她 与 我 』 ",
              time = 25.3 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 750 - GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = " 『 彼 岸 花 开 新 生 』 ",
              time = 27.5 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 650 + GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FFBB0000"
        })
        text:set_text("『当一叶菩提凋零』")
        textjianxian(2, text)
        textjbchange({
          text = text,
          strstart = "『当一叶菩提凋零 ",
          strz = "我愿为它引渡魂灵",
          strend = "』|r",
          time = 1.3000000000000007,
          shunxu = 1,
          waittime = 20.9 - downtime
        })
        ac.wait((23.7 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
        ac.wait((24.2 - downtime) * 1000, function()
          text:set_text("『予它知晓归途』")
          textjianxian(1, text)
        end)
        textjbchange({
          text = text,
          strstart = "『予它知晓归途 ",
          strz = "予它",
          strend = "』|r",
          time = 0.6,
          shunxu = 1,
          waittime = 26.6 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『予它知晓归途 予它",
          strz = "羽翼升空",
          strend = "』|r",
          time = 1.2,
          shunxu = 1,
          waittime = 28 - downtime
        })
        ac.wait((29.9 - downtime) * 1000, function()
          textjianyin(2, text)
        end)
      end)
    end
    do
      local downtime = 32
      local waittime = 32
      ac.wait(waittime * 1000, function()
        ac.wait(800, function()
          text:set_text("『深海传来低吟』")
          textjianxian(2, text)
        end)
        ac.wait(3800.0, function()
          textjianyin(0.4, text)
        end)
        ac.wait(4200.0, function()
          text:set_text("『我们生于幽暗的海底』")
          textjianxian(2, text)
          ac.wait(4000, function()
            textjianyin(0.5, text)
          end)
        end)
        ac.wait((40.9 - downtime) * 1000, function()
          text:set_text("『我问经过的彩蝶』")
          textjianxian(1.5, text)
          ac.wait(3000, function()
            textjianyin(0.5, text)
          end)
        end)
        ac.wait((44.7 - downtime) * 1000, function()
          text:set_text("『你扇动的翅膀』")
          textjianxian(1, text)
        end)
        textjbchange({
          text = text,
          strstart = "『你扇动的翅膀 ",
          strz = "会掀起怎样的",
          strend = "』|r",
          time = 1.4000000000000015,
          shunxu = 1,
          waittime = 46.1 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『你扇动的翅膀 会掀起怎样的",
          strz = "涟漪",
          strend = "』|r",
          time = 0.5,
          shunxu = 1,
          waittime = 48.5 - downtime
        })
        ac.wait((49.9 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
        musiccolortext({
          strz = {
            {
              str = " 『 跟 我 走 』 ",
              time = 49.3 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 750 - GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = " 『 跟 我 走 吧 』 ",
              time = 49.8 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 750 + GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = " 『 就 这 样 』 ",
              time = 56 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 750 - GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FFBB0000"
        })
        ac.wait((50.9 - downtime) * 1000, function()
          text:set_text("『我游到海面之上』")
          textjianxian(1, text)
        end)
        textjbchange({
          text = text,
          strstart = "『我游到海面之上 ",
          strz = "我游向",
          strend = "』|r",
          time = 0.8,
          shunxu = 1,
          waittime = 53.6 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『我游到海面之上 我游向",
          strz = "幸福的天空",
          strend = "』|r",
          time = 1.2,
          shunxu = 1,
          waittime = 54.6 - downtime
        })
        ac.wait((56.5 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
        musiccolortext({
          strz = {
            {
              str = " 『 抛 下 伤 痛 』 ",
              time = 57.2 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 750 + GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FF3366FF"
        })
        ac.wait((57.2 - downtime) * 1000, function()
          colorGradientText(text, {
            "FFFF3333",
            "FFFFAAAA",
            "FFFFAAAA",
            "FFFF3333"
          }, 4, 50, true)
          text:set_text("『别回头』")
          textjianxian(0.5, text)
        end)
        textjbchange({
          text = text,
          strstart = "『别回头 ",
          strz = "再别回头",
          strend = "』|r",
          time = 0.3,
          shunxu = 1,
          waittime = 57.8 - downtime
        })
        ac.wait((58.8 - downtime) * 1000, function()
          textjianyin(0.3, text)
        end)
        ac.wait((59.1 - downtime) * 1000, function()
          colorGradientText(text, {
            "FF3366FF",
            "FFFFCC00",
            "FF3366FF"
          }, 7, 50, true)
          text:set_text("『金色的梦充盈了我的双瞳』")
          textjianxian(1, text)
        end)
        ac.wait((64.5 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
      end)
    end
    do
      local downtime = 64
      local waittime = 64
      ac.wait(waittime * 1000, function()
        ac.wait((65 - downtime) * 1000, function()
          colorGradientText(text, {
            "FF3366FF",
            "FF99CCFF",
            "FF3366FF"
          }, 3, 25, true)
          text:set_text("『跃』")
          textjianxian(1, text)
        end)
        textjbchange({
          text = text,
          strstart = "『跃",
          strz = "起吧",
          strend = "』|r",
          time = 2,
          shunxu = 1,
          waittime = 65 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『跃起吧 ",
          strz = "生命",
          strend = "』|r",
          time = 0.4,
          shunxu = 1,
          waittime = 68.4 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『跃起吧 生命",
          strz = "在此",
          strend = "』|r",
          time = 1.8,
          shunxu = 1,
          waittime = 68 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『跃起吧 生命在此",
          strz = "起舞",
          strend = "』|r",
          time = 0.6,
          shunxu = 1,
          waittime = 70.3 - downtime
        })
        ac.wait((72.4 - downtime) * 1000, function()
          textjianyin(0.4, text)
        end)
        ac.wait((72.9 - downtime) * 1000, function()
          text:set_text("『投』")
          textjianxian(0.5, text)
        end)
        textjbchange({
          text = text,
          strstart = "『投",
          strz = "身去",
          strend = "』|r",
          time = 2,
          shunxu = 1,
          waittime = 72.9 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『投身去 ",
          strz = "再不惧",
          strend = "』|r",
          time = 0.6,
          shunxu = 1,
          waittime = 76.4 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『投身去 再不惧",
          strz = "深海",
          strend = "』|r",
          time = 0.5,
          shunxu = 1,
          waittime = 77.5 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『投身去 再不惧深海",
          strz = "迷途",
          strend = "』|r",
          time = 0.6,
          shunxu = 1,
          waittime = 78.4 - downtime
        })
        ac.wait((80 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
        ac.wait((81.1 - downtime) * 1000, function()
          text:set_text("『我拨开了重影浓雾』")
          textjianxian(1, text)
        end)
        ac.wait((87.3 - downtime) * 1000, function()
          textjianyin(1, text)
        end)
        ac.wait((88.6 - downtime) * 1000, function()
          text:set_text("『我抵达那百花深处』")
          textjianxian(1, text)
        end)
        ac.wait((93.9 - downtime) * 1000, function()
          textjianyin(1, text)
        end)
        ac.wait((95 - downtime) * 1000, function()
          text:set_text("『我已不再孤独』")
          textjianxian(1, text)
        end)
        ac.wait((96.8 - downtime) * 1000, function()
          textjianyin(0.3, text)
        end)
        ac.wait((97.2 - downtime) * 1000, function()
          text:set_text("『我也不再啼哭』")
          textjianxian(1, text)
        end)
        ac.wait((98.8 - downtime) * 1000, function()
          textjianyin(0.3, text)
        end)
        ac.wait((99.3 - downtime) * 1000, function()
          text:set_text("『回望孩童时弱小的我』")
          textjianxian(1, text)
        end)
        ac.wait((102 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
        musiccolortext({
          strz = {
            {
              str = " 『 萤 火 向 你 聚 拢 』 ",
              time = 92.2 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 650 + GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = " 『 林 间 歌 声 如 风 』 ",
              time = 96.7 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 750 - GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = " 『 我 照 看 着 坚 强 的 她 』 ",
              time = 99.3 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 500 + GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = " 『 原 来 我 也 终 得 幸 福 』 ",
              time = 102.7 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 700 - GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FFBB0000"
        })
        ac.wait((102.7 - downtime) * 1000, function()
          text:set_text("『原来生命终得幸福』")
          textjianxian(1, text)
        end)
        ac.wait((108.5 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
      end)
    end
    do
      local downtime = 110
      local waittime = 110
      ac.wait(waittime * 1000, function()
        ac.wait((110.8 - downtime) * 1000, function()
          text:set_text("『愿望投入林中』")
          textjianxian(1, text)
        end)
        ac.wait((113.7 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
        ac.wait((114.3 - downtime) * 1000, function()
          text:set_text("『细雨救赎枯竭的灵魂』")
          textjianxian(1, text)
        end)
        ac.wait((118.2 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
        ac.wait((119 - downtime) * 1000, function()
          text:set_text("『我问同行的麋鹿』")
          textjianxian(1, text)
        end)
        ac.wait((122 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
        ac.wait((122.7 - downtime) * 1000, function()
          text:set_text("『你自生来便有尽时』")
          textjianxian(1, text)
        end)
        textjbchange({
          text = text,
          strstart = "『你自生来便有尽时 ",
          strz = "为何",
          strend = "』|r",
          time = 0.5,
          shunxu = 1,
          waittime = 124.5 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『你自生来便有尽时 为何",
          strz = "从不停脚步",
          strend = "』|r",
          time = 1,
          shunxu = 1,
          waittime = 125 - downtime
        })
        ac.wait((126.6 - downtime) * 1000, function()
          textjianyin(0.3, text)
        end)
        ac.wait((127 - downtime) * 1000, function()
          colorGradientText(text, {
            "FFFF3333",
            "FFFFAAAA",
            "FFFFAAAA",
            "FFFF3333"
          }, 4, 50, true)
          text:set_text("『向前跑』")
          textjianxian(0.5, text)
        end)
        textjbchange({
          text = text,
          strstart = "『向前跑 ",
          strz = "向前奔跑",
          strend = "』|r",
          time = 0.5,
          shunxu = 1,
          waittime = 127.8 - downtime
        })
        ac.wait((128.6 - downtime) * 1000, function()
          textjianyin(0.3, text)
        end)
        ac.wait((128.9 - downtime) * 1000, function()
          colorGradientText(text, {
            "FF3366FF",
            "FF99CCFF",
            "FF3366FF"
          }, 7, 50, true)
          text:set_text("『愿踏遍足下寰宇』")
          textjianxian(1, text)
        end)
        ac.wait((131.3 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
        ac.wait((131.8 - downtime) * 1000, function()
          text:set_text("『愿拥抱沸腾的自由』")
          textjianxian(1, text)
        end)
        ac.wait((134.5 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
        musiccolortext({
          strz = {
            {
              str = " 『 别 回 头 』 ",
              time = 134 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 750 + GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FFBB0000"
        })
        musiccolortext({
          strz = {
            {
              str = " 『 重 拾 苦 难 』 ",
              time = 135.5 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 750 - GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FF3366FF"
        })
        ac.wait((135.3 - downtime) * 1000, function()
          colorGradientText(text, {
            "FFFF3333",
            "FFFFAAAA",
            "FFFFAAAA",
            "FFFF3333"
          }, 4, 50, true)
          text:set_text("『去彼岸』")
          textjianxian(0.3, text)
        end)
        textjbchange({
          text = text,
          strstart = "『去彼岸 ",
          strz = "终抵彼岸",
          strend = "』|r",
          time = 0.6,
          shunxu = 1,
          waittime = 135.7 - downtime
        })
        ac.wait((136.5 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
        ac.wait((137 - downtime) * 1000, function()
          colorGradientText(text, {
            "FF3366FF",
            "FF99CCFF",
            "FF3366FF"
          }, 7, 50, true)
          text:set_text("『柔软的爱萌发在我的胸膛』")
          textjianxian(1, text)
        end)
        ac.wait((142 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
      end)
    end
    do
      local downtime = 142
      local waittime = 142
      ac.wait(waittime * 1000, function()
        ac.wait((143 - downtime) * 1000, function()
          text:set_text("『跃』")
          textjianxian(1, text)
        end)
        textjbchange({
          text = text,
          strstart = "『跃",
          strz = "起吧",
          strend = "』|r",
          time = 2,
          shunxu = 1,
          waittime = 143 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『跃起吧 ",
          strz = "生命",
          strend = "』|r",
          time = 0.4,
          shunxu = 1,
          waittime = 146.4 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『跃起吧 生命",
          strz = "在此",
          strend = "』|r",
          time = 1.8,
          shunxu = 1,
          waittime = 146 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『跃起吧 生命在此",
          strz = "起舞",
          strend = "』|r",
          time = 0.6,
          shunxu = 1,
          waittime = 148.3 - downtime
        })
        ac.wait((150.4 - downtime) * 1000, function()
          textjianyin(0.4, text)
        end)
        ac.wait((150.9 - downtime) * 1000, function()
          text:set_text("『投』")
          textjianxian(0.5, text)
        end)
        textjbchange({
          text = text,
          strstart = "『投",
          strz = "身去",
          strend = "』|r",
          time = 2,
          shunxu = 1,
          waittime = 150.9 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『投身去 ",
          strz = "再不惧",
          strend = "』|r",
          time = 0.6,
          shunxu = 1,
          waittime = 154.4 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『投身去 再不惧",
          strz = "深海",
          strend = "』|r",
          time = 0.5,
          shunxu = 1,
          waittime = 155.5 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『投身去 再不惧深海",
          strz = "迷途",
          strend = "』|r",
          time = 0.6,
          shunxu = 1,
          waittime = 156.4 - downtime
        })
        ac.wait((158 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
        ac.wait((159.1 - downtime) * 1000, function()
          text:set_text("『世界泡影不尽其数』")
          textjianxian(1, text)
        end)
        ac.wait((165.3 - downtime) * 1000, function()
          textjianyin(1, text)
        end)
        ac.wait((166.6 - downtime) * 1000, function()
          text:set_text("『我终寻见百花深处』")
          textjianxian(1, text)
        end)
        ac.wait((171.9 - downtime) * 1000, function()
          textjianyin(1, text)
        end)
        ac.wait((173 - downtime) * 1000, function()
          text:set_text("『我已不再孤独』")
          textjianxian(1, text)
        end)
        ac.wait((174.8 - downtime) * 1000, function()
          textjianyin(0.3, text)
        end)
        ac.wait((175.2 - downtime) * 1000, function()
          text:set_text("『我也不再啼哭』")
          textjianxian(1, text)
        end)
        ac.wait((176.8 - downtime) * 1000, function()
          textjianyin(0.3, text)
        end)
        ac.wait((177.3 - downtime) * 1000, function()
          text:set_text("『我倾听着白昼与黑夜』")
          textjianxian(1, text)
        end)
        ac.wait((180 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
        musiccolortext({
          strz = {
            {
              str = " 『 千 星 向 你 聚 拢 』 ",
              time = 170.2 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 650 + GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = " 『 银 河 掌 声 雷 动 』 ",
              time = 174.7 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 750 - GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = " 『 我 注 视 着 潮 汐 流 转 』 ",
              time = 177.3 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 500 + GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = " 『 祝 愿 我 也 终 得 幸 福 』 ",
              time = 180.7 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 700 - GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FFBB0000"
        })
        ac.wait((180.7 - downtime) * 1000, function()
          text:set_text("『祝愿生命终得幸福』")
          textjianxian(1, text)
        end)
        ac.wait((186.5 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
      end)
    end
    do
      local downtime = 188
      local waittime = 188
      ac.wait(waittime * 1000, function()
        ac.wait((189.1 - downtime) * 1000, function()
          text:set_text("『我曾一度迷失了方向』")
          textjianxian(1, text)
        end)
        ac.wait((192.3 - downtime) * 1000, function()
          textjianyin(0.3, text)
        end)
        ac.wait((192.7 - downtime) * 1000, function()
          colorGradientText(text, {
            "FFFF3333",
            "FFFFAAAA",
            "FFFFAAAA",
            "FFFF3333"
          }, 4, 50, true)
          text:set_text("『记不起你的名字』")
          textjianxian(1, text)
        end)
        ac.wait((195 - downtime) * 1000, function()
          textjianyin(0.3, text)
        end)
        musiccolortext({
          strz = {
            {
              str = " 『 将 被 遗 忘 』 ",
              time = 195 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 750 + GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FF3366FF"
        })
        ac.wait((195.3 - downtime) * 1000, function()
          text:set_text("『你的模样』")
          textjianxian(1, text)
        end)
        ac.wait((196.3 - downtime) * 1000, function()
          textjianyin(0.3, text)
        end)
        ac.wait((196.6 - downtime) * 1000, function()
          colorGradientText(text, {
            "FF3366FF",
            "FF99CCFF",
            "FF3366FF"
          }, 7, 50, true)
          text:set_text("『我想变得像你一样坚强』")
          textjianxian(1, text)
        end)
        ac.wait((200 - downtime) * 1000, function()
          textjianyin(0.3, text)
        end)
        ac.wait((200.5 - downtime) * 1000, function()
          text:set_text("『所以我微笑着』")
          textjianxian(1, text)
        end)
        textjbchange({
          text = text,
          strstart = "『所以我微笑着 ",
          strz = "坠入白光",
          strend = "』|r",
          time = 1,
          shunxu = 1,
          waittime = 202.7 - downtime
        })
        ac.wait((204.4 - downtime) * 1000, function()
          textjianyin(0.3, text)
        end)
        ac.wait((204.7 - downtime) * 1000, function()
          text:set_text("『等待你』")
          textjianxian(1, text)
        end)
        textjbchange({
          text = text,
          strstart = "『等待你 ",
          strz = "把我",
          strend = "』|r",
          time = 0.4,
          shunxu = 1,
          waittime = 206.7 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『等待你 把我",
          strz = "呼唤",
          strend = "』|r",
          time = 1.3,
          shunxu = 1,
          waittime = 207.5 - downtime
        })
        ac.wait((210.8 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
        musiccolortext({
          strz = {
            {
              str = " 『 为 了 你 我 变 得 坚 强 』 ",
              time = 197.4 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 750 - GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = " 『 咬 着 牙 冲 入 黑 暗 』 ",
              time = 202.3 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 600 + GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = " 『 等 着 我 』 ",
              time = 205.6 - downtime,
              showtexttime = 0.5,
              staytime = 2.5,
              fadetime = 0.75,
              sx = 750 - GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = " 『 将 你 呐 喊 』 ",
              time = 206.7 - downtime,
              showtexttime = 0.5,
              staytime = 1.2,
              fadetime = 0.75,
              sx = 750 + GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FFBB0000"
        })
      end)
    end
    do
      local downtime = 234
      local waittime = 234
      ac.wait(waittime * 1000, function()
        ac.wait((234.3 - downtime) * 1000, function()
          colorGradientText(text, {
            "FF3366FF",
            "FF99CCFF",
            "FF3366FF"
          }, 3, 25, true)
          text:set_text("『跃』")
          textjianxian(1, text)
        end)
        textjbchange({
          text = text,
          strstart = "『跃",
          strz = "起吧",
          strend = "』|r",
          time = 2,
          shunxu = 1,
          waittime = 234.3 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『跃起吧 ",
          strz = "生命",
          strend = "』|r",
          time = 0.4,
          shunxu = 1,
          waittime = 237.70000000000002 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『跃起吧 生命",
          strz = "在此",
          strend = "』|r",
          time = 1.8,
          shunxu = 1,
          waittime = 237.3 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『跃起吧 生命在此",
          strz = "起舞",
          strend = "』|r",
          time = 0.6,
          shunxu = 1,
          waittime = 239.60000000000002 - downtime
        })
        ac.wait((241.70000000000002 - downtime) * 1000, function()
          textjianyin(0.4, text)
        end)
        ac.wait((242.20000000000002 - downtime) * 1000, function()
          text:set_text("『投』")
          textjianxian(0.5, text)
        end)
        textjbchange({
          text = text,
          strstart = "『投",
          strz = "身去",
          strend = "』|r",
          time = 2,
          shunxu = 1,
          waittime = 242.20000000000002 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『投身去 ",
          strz = "再不惧",
          strend = "』|r",
          time = 0.6,
          shunxu = 1,
          waittime = 245.70000000000002 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『投身去 再不惧",
          strz = "深海",
          strend = "』|r",
          time = 0.5,
          shunxu = 1,
          waittime = 246.8 - downtime
        })
        textjbchange({
          text = text,
          strstart = "『投身去 再不惧深海",
          strz = "迷途",
          strend = "』|r",
          time = 0.6,
          shunxu = 1,
          waittime = 247.70000000000002 - downtime
        })
        ac.wait((249.3 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
        ac.wait((250.4 - downtime) * 1000, function()
          text:set_text("『我亲吻着指尖彩蝶』")
          textjianxian(1, text)
        end)
        ac.wait((256.6 - downtime) * 1000, function()
          textjianyin(1, text)
        end)
        ac.wait((257.9 - downtime) * 1000, function()
          text:set_text("『我早已在百花深处』")
          textjianxian(1, text)
        end)
        ac.wait((263.20000000000005 - downtime) * 1000, function()
          textjianyin(1, text)
        end)
        ac.wait((264.3 - downtime) * 1000, function()
          text:set_text("『不必感到孤独』")
          textjianxian(1, text)
        end)
        ac.wait((266.1 - downtime) * 1000, function()
          textjianyin(0.3, text)
        end)
        ac.wait((266.5 - downtime) * 1000, function()
          text:set_text("『不必逃离痛楚』")
          textjianxian(1, text)
        end)
        ac.wait((268.1 - downtime) * 1000, function()
          textjianyin(0.3, text)
        end)
        ac.wait((268.6 - downtime) * 1000, function()
          text:set_text("『我化身为蝶扇动翅膀』")
          textjianxian(1, text)
        end)
        ac.wait((271.3 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
        musiccolortext({
          strz = {
            {
              str = " 『 有 人 伴 你 身 旁 』 ",
              time = 261.5 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 650 + GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = " 『 经 历 使 人 成 长 』 ",
              time = 266.0 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 750 - GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = " 『 我 把 微 风 吹 向 远 方 』 ",
              time = 268.6 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 500 + GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = " 『 祝 愿 你 我 都 能 幸 福 』 ",
              time = 272.0 - downtime,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 700 - GetRandomReal(650, 700),
              sy = GetRandomReal(600, 750),
              dx = 35,
              font = "fontyt"
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FFBB0000"
        })
        ac.wait((272.0 - downtime) * 1000, function()
          text:set_text("『祝愿生命都能幸福』")
          textjianxian(1, text)
        end)
        ac.wait((277.8 - downtime) * 1000, function()
          textjianyin(0.5, text)
        end)
      end)
    end
    do
      local downtime = 210
      local waittime = 210
      ac.wait(waittime * 1000, function()
        musiccolortext({
          strz = {
            {
              str = "『希 儿！』",
              time = 211.3 - downtime,
              showtexttime = 0.1,
              staytime = 1,
              fadetime = 0.75,
              sx = 750 - GetRandomReal(650, 700),
              sy = GetRandomReal(500, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = "『希 儿』",
              time = 217.3 - downtime,
              showtexttime = 0.1,
              staytime = 1,
              fadetime = 0.75,
              sx = 750 - GetRandomReal(650, 700),
              sy = GetRandomReal(500, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = "『你 记 住 了』",
              time = 218.8 - downtime,
              showtexttime = 0.1,
              staytime = 1,
              fadetime = 0.75,
              sx = 750 - GetRandomReal(650, 700),
              sy = GetRandomReal(500, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = "『希 儿』",
              time = 223.5 - downtime,
              showtexttime = 0.1,
              staytime = 1,
              fadetime = 0.75,
              sx = 750 - GetRandomReal(650, 700),
              sy = GetRandomReal(500, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = "『你 做 到 了』",
              time = 224.9 - downtime,
              showtexttime = 0.1,
              staytime = 1,
              fadetime = 0.75,
              sx = 750 - GetRandomReal(650, 700),
              sy = GetRandomReal(500, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = "『但 你 不 必 成 为 我』",
              time = 226.4 - downtime,
              showtexttime = 0.1,
              staytime = 1,
              fadetime = 0.75,
              sx = 750 - GetRandomReal(650, 700),
              sy = GetRandomReal(500, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = "『我 们 都 有 着 独 一 无 二 的 灵 魂』",
              time = 229.3 - downtime,
              showtexttime = 0.1,
              staytime = 1,
              fadetime = 0.75,
              sx = 750 - GetRandomReal(650, 700),
              sy = GetRandomReal(500, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = "『谢 谢 你  希 儿』",
              time = 232.8 - downtime,
              showtexttime = 0.1,
              staytime = 1,
              fadetime = 0.75,
              sx = 750 - GetRandomReal(650, 700),
              sy = GetRandomReal(500, 750),
              dx = 35,
              font = "fontyt"
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FF3366FF"
        })
        musiccolortext({
          strz = {
            {
              str = "『希 儿！』",
              time = 211.3 - downtime,
              showtexttime = 0.1,
              staytime = 1,
              fadetime = 0.75,
              sx = 650 + GetRandomReal(650, 700),
              sy = GetRandomReal(500, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = "『我 想 记 住 你 的 名 字』",
              time = 213.2 - downtime,
              showtexttime = 0.1,
              staytime = 1,
              fadetime = 0.75,
              sx = 550 + GetRandomReal(650, 700),
              sy = GetRandomReal(500, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = "『你 的 面 容』",
              time = 215.4 - downtime,
              showtexttime = 0.1,
              staytime = 1,
              fadetime = 0.75,
              sx = 650 + GetRandomReal(650, 700),
              sy = GetRandomReal(500, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = "『我 想 攥 紧 你 的 心 愿』",
              time = 220 - downtime,
              showtexttime = 0.1,
              staytime = 1,
              fadetime = 0.75,
              sx = 550 + GetRandomReal(650, 700),
              sy = GetRandomReal(500, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = "『你 的 手』",
              time = 222.3 - downtime,
              showtexttime = 0.1,
              staytime = 1,
              fadetime = 0.75,
              sx = 650 + GetRandomReal(650, 700),
              sy = GetRandomReal(500, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = "『但 我 不 会 成 为 你』",
              time = 227.4 - downtime,
              showtexttime = 0.1,
              staytime = 1,
              fadetime = 0.75,
              sx = 550 + GetRandomReal(650, 700),
              sy = GetRandomReal(500, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = "『我 们 都 有 着 独 一 无 二 的 灵 魂』",
              time = 229.3 - downtime,
              showtexttime = 0.1,
              staytime = 1,
              fadetime = 0.75,
              sx = 300 + GetRandomReal(650, 700),
              sy = GetRandomReal(500, 750),
              dx = 35,
              font = "fontyt"
            },
            {
              str = "『谢 谢 你  希 儿』",
              time = 232.8 - downtime,
              showtexttime = 0.1,
              staytime = 1,
              fadetime = 0.75,
              sx = 650 + GetRandomReal(650, 700),
              sy = GetRandomReal(500, 750),
              dx = 35,
              font = "fontyt"
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FFBB0000"
        })
      end)
    end
  end,
  ["Grand Illussion"] = function(u, mb)
    do
      local sy = u.ownerid
      local x, y = mb:getxy()
      local dx, dy = PolarXY(x, y, 1400, 270)
      ShowUnit(u.handle, false)
      u:buffset(u.handle, 37, "无敌")
      u:buffset(u.handle, 37, "绝对闪避")
      u:buffset(u.handle, 32, "暂停")
      mb:setface(270)
      mb:buffset(mb.handle, 37, "暂停")
      mb:buffset(mb.handle, 37, "无敌")
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:buffset(u.handle, 37, "绝对闪避")
      end)
      u:setdata("暗之书-演出发动中")
      local mj = u:createunit("u0A9", dx, dy, 90)
      local x, y = mj:getxy()
      local x2, y2 = mb:getxy()
      local jd = u:getface()
      local jd2 = mb:getface()
      mj:setflyheight(0)
      FogEnable(false)
      FogMaskEnable(false)
      Effectcreate("ATX\\[ATxNew]Blue_12.mdl", x, y, 0, 2)
      SetDayNightModels("Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdx", "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdx")
      Movie_Boolean = true
      DayNightRun = true
      Boolean_Fog_Change = true
      ac.wait(600, function()
        local x3, y3 = PolarXY(x2, y2, 700, 270)
        PanCameraToTimed(x3, y3, 0)
      end)
      PlayBGM({
        bgm = BGM_LLY_10,
        time = 90,
        ID = 28,
        unit = u.handle
      })
      PlayGlobalSound(Sound_LLY__30000_4)
      ac.wait(1500, function()
        ac.wait(2500, function()
          PlayGlobalSound(Sound_LLY__30000_16)
          PlayGlobalSound(Sound_LLY_01)
          Effectcreate("war3mapImported\\spellcardcall.mdx", x, y, 0, 2)
          Effectcreate("ATX\\[ATxNew]Purple_24.mdl", x, y, 0, 2)
          Effectcreate("war3mapImported\\[ake]war3ake.com - 2799176621124903338904394.mdl", x, y, 3, 2)
          mj:animeact(2)
        end)
        ac.wait(3750, function()
          PlayGlobalSound(Sound_LLY_02)
          Effectcreate("ATX\\[ATxNew]ShockBoom_22.mdl", x, y, 0, 2)
          Effectcreate("CTX\\[CTxNew]llywb_gh.mdl", x, y, 3, 1)
          mj:animeact(3)
        end)
        ac.wait(5500, function()
          PlayGlobalSound(Sound_LLY__30000_12)
          PlayGlobalSound(Sound_LLY_03)
          mj:animeact(11)
        end)
        local zx = {}
        local zy = {}
        zx[#zx + 1], zy[#zy + 1] = PolarXY(x2, y2, 800, jd2 + 90)
        zx[#zx + 1], zy[#zy + 1] = PolarXY(zx[#zx], zy[#zy], 800, jd2)
        zx[#zx + 1], zy[#zy + 1] = PolarXY(zx[#zx - 1], zy[#zy - 1], -800, jd2)
        zx[#zx + 1], zy[#zy + 1] = PolarXY(x2, y2, 800, jd2 - 90)
        zx[#zx + 1], zy[#zy + 1] = PolarXY(zx[#zx], zy[#zy], 800, jd2)
        zx[#zx + 1], zy[#zy + 1] = PolarXY(zx[#zx - 1], zy[#zy - 1], -800, jd2)
        local a = jd2 + 180 - 84
        for i = 1, 6 do
          a = a + 24
          local ax, ay = PolarXY(x, y, 150, a)
          Effectcreate("ATX\\[ATxNew]Purple_21.mdl", ax, ay)
        end
        for i = 1, 6 do
          local xx = zx[i]
          local yy = zy[i]
          Effectcreate("ATX\\[ATxNew]Black_04.mdl", xx, yy, 1)
          local xm = xx
          local ym = yy
          local x3 = (x + xm) / 2
          local y3 = (y + ym) / 2
          local a1 = AngleXY(x, y, x3, y3)
          local jd3
          if i <= 3 then
            jd3 = a1 - 45
          else
            jd3 = a1 + 45
          end
          local l1 = DistanceXY(x, y, x3, y3)
          local jl1 = 1.4142135623730951 * l1
          local x4, y4 = PolarXY(x, y, jl1, jd3)
          local a2 = AngleXY(x4, y4, x3, y3)
          local ll = DistanceXY(x3, y3, x4, y4)
          local jl2 = 2 * ll
          local x5, y5 = PolarXY(x4, y4, jl2, a2)
          local a3 = AngleXY(x5, y5, xm, ym)
          local jl3 = DistanceXY(x5, y5, xm, ym)
          local tx = Effectcreate("ATX\\[ATxNew]Tile_04.mdl", x, y, -1, 1, 150)
          local jl1 = jl1 / 20
          local jl2 = jl2 / 40
          local jl3 = jl3 / 20
          local xx = x
          local yy = y
          local cs = 0
          ac.loop(10, function(timer)
            local jl, a
            cs = cs + 1
            if cs <= 20 then
              jl = jl1
              a = jd3
            end
            if 20 < cs and cs <= 60 then
              jl = jl2
              a = a2
            end
            if 60 < cs then
              jl = jl3
              a = a3
            end
            xx, yy = PolarXY(xx, yy, jl, a)
            SetEffectXY(tx, xx, yy)
            if cs == 80 then
              DestroyEffectLua(tx)
              Effectcreate("ATX\\[ATxNew]Blood_06.mdl", xx, yy, 1, 1)
              timer:remove()
            end
          end)
        end
        ac.wait(3000, function()
          PlayGlobalSound(Sound_LLY_04)
          local g = CreateGroupLua()
          ForGroupLuaNew(Group_PlayHero, function(xq)
            xq:groupadd(g)
          end)
          ForGroupLuaNew(Group_Monster, function(xq)
            xq:groupadd(g)
          end)
          u:groupremove(g)
          ForGroupLuaNew(g, function(xq)
            xq:animespeed(0)
            xq:buffset(u.handle, 30, "暂停")
            ac.wait(30000, function()
              xq:animespeed(1)
            end)
          end)
          SetTerrainFogExBJ(0, 1000, 10000, 2.0, 10.0, 0.0, 50.0)
          local dmj = u:createunit("u0AC", x2, y2, GetRandomReal(180, 360))
          dmj:timetoremove(20.5)
        end)
        for i = 1, 6 do
          local xx = zx[i]
          local yy = zy[i]
          ac.wait(3000, function()
            Effectcreate("ATX\\[ATxNew]Purple_10.mdl", x2, y2, 0, 2)
            Effectcreate("ATX\\[ATxNew]Purple_35.mdl", xx, yy, 0, 1, 150)
            local dmj = u:createunit("u0AD", xx, yy, GetRandomReal(180, 360))
            dmj:timetoremove(6)
            dmj:animespeed(0.5)
            ac.wait(10, function()
              dmj:animeact("birth")
            end)
            ac.wait(1800, function()
              dmj:animespeed(0)
            end)
            ac.wait(5000, function()
              Effectcreate("CTX\\[CTxNew]llywb_bz.mdl", xx, yy, 0, 2)
              local mj2 = u:createunit("u0AB", xx, yy, jd)
              mj2:animespeed(0.25)
              mj2:timetoremove(15.5)
            end)
          end)
        end
        ac.wait(5500, function()
          PlayGlobalSound(Sound_LLY__30000_14)
        end)
        ac.wait(8000, function()
          PlayGlobalSound(Sound_LLY_05)
          PlayGlobalSound(Sound_LLY_06)
          PlayGlobalSound(Sound_LLY_07)
          mb:setflyheight(350)
        end)
        ac.wait(10000, function()
          local h = 0
          ac.timer(30, 100, function()
            h = h + 3
            mj:setflyheight(h)
          end)
          local jl = DistanceBetweenUnits(mj.handle, mb.handle)
          jl = jl - 300
          local aa = AngleBetweenUnits(mj.handle, mb.handle)
          mj:animeact(9)
          PlayGlobalSound(Sound_LLY_08)
          local step = {
            Sound_Step_01,
            Sound_Step_02,
            Sound_Step_03,
            Sound_Step_04,
            Sound_Step_05
          }
          local jl = jl / 350
          local xx = x
          local yy = y
          local cs = 0
          local cs2 = 0
          ac.loop(20, function(timer)
            cs = cs + 1
            cs2 = cs2 + 1
            xx, yy = PolarXY(xx, yy, jl, aa)
            mj:setxy(xx, yy)
            if cs2 == 50 and cs ~= 350 then
              cs2 = 0
              mj:animeact(9)
              PlayGlobalSound(step[GetRandomInt(1, 5)])
            end
            if cs == 350 then
              mj:animeact("stand")
              local g2 = CreateGroupLua()
              ac.wait(1000, function()
                PlayGlobalSound(Sound_LLY__30000_6)
                PlayGlobalSound(Sound_LLY_10)
                Effectcreate("ATX\\[ATxNew]Purple_38.mdl", xx, yy, 0, 2)
                Effectcreate("Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl", xx, yy, 0, 2)
                ac.wait(1500, function()
                  PlayGlobalSound(Sound_LLY_09)
                  mb:animeact("death")
                  mb:animespeed(2)
                  u:chat("|cFF8533FF过|r|cFFA366FF去|r")
                  mj:animeact(11)
                  local mjn = u:createunit("u0AE", xx, yy, aa)
                  mjn:animespeed(2)
                  mjn:timetoremove(1.5)
                  ac.wait(500, function()
                    ResetUnitAnimation(mj.handle)
                    local cs3 = 0
                    ac.loop(100, function(timer2)
                      cs3 = cs3 + 1
                      PlayGlobalSound(Sound_LLY_11)
                      mb:animespeed(0)
                      local mjn = u:createunit("u0AF", x2, y2, GetRandomAngle())
                      mjn:groupadd(g2)
                      Effectcreate("ATX\\[ATxNew]Hit_15.mdl", x2, y2, 1, 2, 100)
                      LossHpUnit({
                        u = u,
                        tg = mb,
                        damage = 0,
                        perhp = 10,
                        maxhp = 0,
                        bj = "[生命损耗]Grand Illussion"
                      })
                      if cs3 == 5 then
                        timer2:remove()
                      end
                    end)
                  end)
                end)
                ac.wait(3500, function()
                  local xx, yy = mj:getxy()
                  PlayGlobalSound(Sound_LLY_09)
                  mb:animeact("death")
                  mb:animespeed(2)
                  ClearTextMessages()
                  u:chat("|cFFE0CCFF未|r|cFFC299FF来|r")
                  mj:animeact(11)
                  Effectcreate("ATX\\[ATxNew]Purple_24.mdl", xx, yy, 0, 3, 500)
                  local mjn = u:createunit("u0AE", xx, yy, aa)
                  mjn:animespeed(2)
                  mjn:timetoremove(1.5)
                  ac.wait(500, function()
                    ResetUnitAnimation(mj.handle)
                    local cs3 = 0
                    ac.loop(100, function(timer2)
                      cs3 = cs3 + 1
                      PlayGlobalSound(Sound_LLY_11)
                      mb:animespeed(0)
                      local mjn = u:createunit("u0AF", x2, y2, GetRandomAngle())
                      mjn:groupadd(g2)
                      Effectcreate("ATX\\[ATxNew]Hit_15.mdl", x2, y2, 1, 2, 100)
                      LossHpUnit({
                        u = u,
                        tg = mb,
                        damage = 0,
                        perhp = 10,
                        maxhp = 0,
                        bj = "[生命损耗]Grand Illussion"
                      })
                      if cs3 == 5 then
                        timer2:remove()
                      end
                    end)
                  end)
                end)
                ac.wait(5500, function()
                  mb:setflyheight(0)
                  PlayGlobalSound(Sound_LLY_04)
                  ForGroupLuaNew(g2, function(xq)
                    local xx, yy = xq:getxy()
                    local mjn = u:createunit("u0AA", xx, yy, xq:getface())
                    mjn:timetoremove(4)
                    xq:remove()
                  end)
                  mj:setflyheight(0)
                  mj:setxy(x, y)
                  Effectcreate("ATX\\[ATxNew]Hit_15.mdl", x2, y2, 0, 2)
                end)
                ac.wait(8000, function()
                  PlayGlobalSound(Sound_LLY__30000_18)
                  PlayGlobalSound(Sound_LLY_07)
                  ClearTextMessages()
                  u:chat("|cFF530080消|r|cFF4D0A71失|r|cFF461461吧|r|cFF401F52。|r")
                  local size = 1.8
                  local ok = class.panel:builder({
                    parent = OriginPanel,
                    x = 450,
                    y = 131,
                    w = 600 * size,
                    h = 400 * size,
                    normal_image = "war3mapImported\\Photo_LLY.blp"
                  })
                  local ok2 = class.panel:builder({
                    parent = OriginPanel,
                    x = 450,
                    y = 131,
                    w = 600 * size,
                    h = 400 * size,
                    normal_image = "war3mapImported\\Photo_LLY.blp"
                  })
                  ok2:set_alpha(200)
                  local bs = 1
                  local tm = 200
                  ac.loop(10, function(timer)
                    tm = tm - 3
                    bs = bs + 0.01
                    ok2:set_alpha(tm)
                    ok2:set_real_position(450 - 0.6 * (400 * size * (bs - 1)), 131 - 0.3 * (600 * size * (bs - 1)))
                    ok2:set_height(400 * size * bs)
                    ok2:set_width(600 * size * bs)
                    if tm <= 2 then
                      ok2:destroy()
                      timer:remove()
                    end
                  end)
                  ac.wait(1500, function()
                    ok:destroy()
                  end)
                end)
                ac.wait(9500, function()
                  PlayGlobalSound(Sound_LLY_12)
                  PlayGlobalSound(boom1)
                  mj:animeact(12)
                  mj:animespeed(2)
                  mb:animespeed(1)
                  Effectcreate("ATX\\[ATxNew]Purple_02.mdl", x2, y2, 0, 1.5)
                  mb:clearbuff("无敌")
                  mb:zsdamage(u.handle)
                  ForGroupLuaNew(Group_Monster, function(xq)
                    local dis = DistanceBetweenUnits(xq.handle, u.handle)
                    if dis <= 5000 and not xq:isboss() then
                      xq:kill(u.handle, true)
                    end
                  end)
                  ac.wait(3000, function()
                    u:deldata("暗之书-演出发动中")
                    Boolean_Fog_Change = false
                    Movie_Boolean = false
                    DayNightRun = false
                    FogEnable(true)
                    FogMaskEnable(true)
                    ShowUnit(u.handle, true)
                    u:select()
                    u:setxy(x, y)
                    u:setface(mj:getface())
                    Effectcreate("ATX\\[ATxNew]Blue_12.mdl", x, y, 0, 2)
                    mj:remove()
                  end)
                end)
              end)
              timer:remove()
            end
          end)
        end)
      end)
    end
  end,
  ["射杀百头"] = function(u)
    PlayGlobalSound(BGM_Shirou_Ssbt)
    do
      local mb = getunit(BOSS)
      local u = u
      local sy = u.ownerid
      local x2, y2 = mb:getxy()
      local jd = mb:getface()
      local xx, yy = PolarXY(x2, y2, 1500, jd)
      u:setdata("特殊判定-射杀百头触发")
      u:setdata("卫宫士郎-射杀百头演出")
      u:setxy(xx, yy)
      local x, y = u:getxy()
      ac.wait(500, function()
        ShowUnit(u.handle, false)
      end)
      local jd = AngleBetweenUnits(u.handle, mb.handle)
      local mj = u:createunit("u0BI", x, y, jd)
      local mj2 = u:createunit("u0BH", x, y, jd)
      mj:animeact(15)
      mj2:animeact(0)
      u:buffset(u.handle, 200, "无敌")
      u:buffset(u.handle, 195, "暂停")
      u:buffset(u.handle, 200, "绝对闪避")
      mb:buffset(u.handle, 200, "锁定")
      mb:buffset(u.handle, 200, "沉默")
      mb:buffset(u.handle, 200, "暂停")
      mb:buffset(u.handle, 200, "无敌")
      SetTimeOfDay(15)
      SetTimeOfDayScale(0)
      xx, yy = PolarXY(x, y, -200, jd)
      local bs = u:createunit("u0BJ", xx, yy, jd)
      mj:setcolor(255, 255, 255, 0)
      mj2:setcolor(255, 255, 255, 0)
      bs:setcolor(255, 255, 255, 0)
      Movie_Boolean = true
      FogEnable(false)
      FogMaskEnable(false)
      ac.wait(3000, function()
        xx, yy = PolarXY(x, y, 750, jd)
        PanCameraToTimed(xx, yy, 0)
      end)
      local text = class.text:builder({
        x = 800,
        y = 625,
        w = 300,
        h = 300,
        text = "",
        align = "center",
        font_size = 12,
        color = "FFFFFFFF"
      })
      local heimu = class.panel:builder({
        parent = OriginPanel,
        x = 0,
        y = 0,
        w = 1920,
        h = 850,
        normal_image = "war3mapImported\\Black.blp"
      })
      local heimu2 = class.panel:builder({
        parent = OriginPanel,
        x = 0,
        y = 0,
        w = 1920,
        h = 850,
        normal_image = "Touming.tga"
      })
      heimu:set_alpha(0)
      do
        local cs = 5
        local dtime = 8.0
        ac.timer(dtime, 250, function()
          cs = cs + 1
          heimu:set_alpha(cs)
        end)
        ac.wait(2500, function()
          local zs = 0
          local xs = 100
          ac.loop(30, function(timer)
            local zs2 = 0
            zs = zs + 1
            if 4 <= zs and zs < 9 then
              heimu:set_normal_image("Shirou\\Ph_Shirou_01 (" .. math.floor(zs - 3) .. ").blp")
            end
            if zs == 9 then
              heimu:set_normal_image("war3mapImported\\Black.blp")
              timer:remove()
            end
          end)
        end)
        ac.wait(4200, function()
          local zs = 0
          local zs3 = 0
          local xh1 = 0
          local b = true
          local xs = 0
          ac.loop(30, function(timer)
            zs = zs + 1
            if xh1 < 4 then
              local tz = 50
              if b then
                xs = xs + 1
                if 100 <= xs then
                  b = false
                end
              elseif zs3 == tz then
                xs = xs - 1
                if xs <= 0 then
                  zs3 = 0
                  xh1 = xh1 + 1
                  b = true
                end
              else
                zs3 = zs3 + 1
              end
              heimu2:set_normal_image("Shirou\\Ph_Shirou_02 (" .. math.floor(zs) .. ").blp")
              heimu2:set_alpha(math.floor(xs * 2.55))
              if zs == 54 then
                zs = 0
              end
            end
            if 4 <= xh1 then
              local zs = 1
              local zs2 = 0
              local zs3 = 0
              local zs4 = 0
              local b = true
              local xs = 0
              ac.loop(50, function(timer2)
                zs3 = zs3 + 1
                zs4 = zs4 + 1
                if zs3 == 5 then
                  zs3 = 0
                  zs = zs + 1
                end
                zs2 = 0
                if b then
                  xs = xs + 2
                  if 100 <= xs then
                    xs = 100
                    b = false
                  end
                end
                if 220 <= zs4 then
                  xs = xs - 2
                  if xs <= 0 then
                    timer2:remove()
                  end
                end
                heimu2:set_normal_image("Shirou\\Ph_Shirou_03 (" .. math.floor(zs) .. ").blp")
                heimu2:set_alpha(math.floor(xs * 2.55))
                if zs == 41 then
                  zs = 1
                end
              end)
              timer:remove()
            end
          end)
        end)
        ac.wait(48000, function()
          local zs = 1
          local zs2 = 0
          local zs3 = 0
          local zs4 = 0
          local zs5 = 0
          local b = true
          local xs = 0
          ac.loop(50, function(timer2)
            zs4 = zs4 + 1
            if zs3 == 10 then
              zs5 = zs5 + 1
              if zs5 == 3 then
                zs5 = 0
                zs = zs + 1
              end
            else
              zs3 = zs3 + 1
            end
            zs2 = 0
            if b then
              xs = xs + 4
              if 100 <= xs then
                xs = 100
                b = false
              end
            end
            if 140 <= zs4 then
              xs = xs - 10
              if xs <= 30 then
                timer2:remove()
              end
            end
            if 29 <= zs then
              zs = 29
            end
            heimu2:set_normal_image("Shirou\\Ph_Shirou_04 (" .. math.floor(zs) .. ").blp")
            heimu2:set_alpha(math.floor(xs * 2.55))
          end)
        end)
        ac.wait(55000, function()
          local zs = 1
          local zs2 = 0
          local zs3 = 0
          local zs4 = 0
          local b = true
          local xs = 0
          ac.loop(50, function(timer2)
            zs3 = zs3 + 1
            zs4 = zs4 + 1
            if zs3 == 5 then
              zs3 = 0
              zs = zs + 1
            end
            zs2 = 0
            if b then
              xs = xs + 5
              if 100 <= xs then
                xs = 100
                b = false
              end
            end
            if 350 <= zs4 then
              timer2:remove()
            end
            heimu2:set_normal_image("Shirou\\Ph_Shirou_03 (" .. math.floor(zs) .. ").blp")
            heimu2:set_alpha(math.floor(xs * 2.55))
            if 41 <= zs then
              zs = 1
            end
          end)
        end)
        ac.wait(72600.0, function()
          local zs = 1
          local zs2 = 0
          local zs3 = 0
          local zs4 = 0
          local zs5 = 0
          local b = true
          local xs = 100
          ac.loop(30, function(timer2)
            zs4 = zs4 + 1
            if zs3 == 50 then
              zs5 = zs5 + 1
              if zs5 == 2 then
                zs5 = 0
                zs = zs + 1
              end
            else
              zs3 = zs3 + 1
            end
            if zs == 1 or zs == 23 then
              heimu2:set_normal_image("war3mapImported\\Black.blp")
            end
            if 2 <= zs and zs <= 9 then
              heimu2:set_normal_image("Shirou\\Ph_Shirou_10 (" .. math.floor(zs - 1) .. ").blp")
            end
            if 10 <= zs and zs <= 22 then
              heimu2:set_normal_image("Shirou\\Ph_Shirou_05 (" .. math.floor(zs - 9) .. ").blp")
            end
            heimu2:set_alpha(math.floor(xs * 2.55))
            if 23 <= zs then
              timer2:remove()
            end
          end)
        end)
        ac.wait(79400.0, function()
          local zs = 1
          local zs3 = 0
          local zs4 = 0
          local zs5 = 0
          local b = true
          local xs = 0
          local xs2 = 100
          ac.loop(50, function(timer2)
            zs4 = zs4 + 1
            if zs3 == 102 then
              zs5 = zs5 + 1
              if zs5 == 3 then
                zs5 = 0
                zs = zs + 1
              end
            else
              zs3 = zs3 + 1
            end
            if b then
              xs = xs + 1
              if 100 <= xs then
                xs = 100
                b = false
              end
            end
            if 7 <= zs then
              zs = 7
            end
            if zs == 7 then
              xs2 = xs2 - 1
              heimu:set_alpha(math.floor(xs2 * 2.55))
              if xs2 <= 0 then
                xs2 = 0
                timer2:remove()
              end
            end
            heimu2:set_normal_image("Shirou\\Ph_Shirou_06 (" .. math.floor(zs) .. ").blp")
            if 7 <= zs then
              heimu2:set_alpha(math.floor(xs2 * 2.55))
            else
              heimu2:set_alpha(math.floor(xs * 2.55))
            end
          end)
        end)
        ac.wait(103310.0, function()
          local sjz = {
            103.31,
            104.07,
            104.81,
            105.6,
            105.94,
            106.45,
            107,
            107.3,
            107.7,
            108.12,
            108.37,
            108.65
          }
          local zs = 0
          for index, value in ipairs(sjz) do
            ac.wait((value - 103.31) * 1000, function()
              zs = zs + 1
              heimu2:set_normal_image("Shirou\\Ph_Shirou_07 (" .. math.floor(zs) .. ").blp")
              heimu2:set_alpha(255)
            end)
          end
          ac.wait(5579.999999999998, function()
            heimu2:set_alpha(0)
            heimu:set_alpha(255)
            local xs = 100
            ac.loop(50, function(timer2)
              xs = xs - 1
              heimu:set_alpha(math.floor(2.55 * xs))
              if xs <= 0 then
                timer2:remove()
              end
            end)
          end)
        end)
        ac.wait(176500.0, function()
          local sjz = {
            0,
            0.24,
            0.48,
            0.68,
            0.9,
            1.12,
            1.34,
            1.5
          }
          local hsjz = {
            0.15,
            0.39,
            0.59,
            0.81,
            1.03,
            1.25,
            1.41
          }
          local zs = 0
          for index, value in ipairs(sjz) do
            ac.wait(value * 1000, function()
              zs = zs + 1
              heimu2:set_normal_image("Shirou\\Ph_Shirou_08 (" .. math.floor(zs) .. ").blp")
              heimu2:set_alpha(255)
            end)
          end
          for index, value in ipairs(hsjz) do
            ac.wait(value * 1000, function()
              heimu2:set_normal_image("war3mapImported\\Black.blp")
              heimu2:set_alpha(255)
            end)
          end
          ac.wait(1700, function()
            heimu:set_alpha(0)
            heimu2:set_alpha(0)
          end)
        end)
      end
      ac.wait(84000, function()
        ac.wait(1000, function()
          local g = CreateGroupLua()
          local jd2 = GetRandomAngle()
          mj:setcolor(255, 255, 255, 255)
          for i = 1, 4 do
            jd2 = jd2 + 30
            local dx = 9 - 2 * i
            local dmj = u:createunit("u0BK", x, y, jd2)
            dmj:animeact(0)
            dmj:groupadd(g)
            dmj:setsize(dx)
            ac.wait(30, function()
              dmj:animespeed(0.05)
            end)
          end
          ac.wait(17500, function()
            ForGroupLuaNew(g, function(xq)
              xq:animespeed(2)
              xq:timetoremove(2.5)
            end)
          end)
          ac.wait(16600, function()
            Effectcreate("ATX\\[ATxNew]Green_18.mdl", x, y, 0, 4.5)
            Effectcreate("ATX\\[ATxNew]Light_25.mdl", x, y, 0, 5)
          end)
          Effectcreate("AATX\\[AATxNew]Colour04.mdl", x, y, 63.1, 8)
          Effectcreate("war3mapImported\\[ake]war3ake.com - 7346841038772226188179609.mdl", x, y, 63.1, 8)
          local xx, yy = PolarXY(x, y, 50, jd)
          local dmj = u:createunit("u0BL", xx, yy, GetRandomAngle())
          dmj:timetoremove(14)
          ac.wait(1500, function()
            ac.timer(250, 34, function()
              local jd3 = GetRandomAngle()
              local jl = GetRandomReal(0, 250)
              local xx, yy = PolarXY(x, y, jl, jd3)
              Effectcreate("ATX\\[ATxNew]Halo_11.mdl", xx, yy, 1, 6, 0, GetRandomAngle())
              if GetRandomInt(1, 2) == 1 then
                mj:effectadd("Abilities\\Spells\\Other\\Charm\\CharmTarget.mdl", "hand left")
              else
                mj:effectadd("Abilities\\Spells\\Other\\Charm\\CharmTarget.mdl", "hand right")
              end
            end)
          end)
          bs:animespeed(0)
          ac.wait(11300, function()
            local xx, yy = PolarXY(x, y, -200, jd)
            Effectcreate("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl", xx, yy, 0, 3)
            local cs = 0
            local xs = 0
            local x = xx
            local y = yy
            ac.timer(100, 30, function()
              xs = xs + 1.5
              bs:setcolor(255, 255, 255, math.floor(2.55 * xs))
              cs = cs + 1
              local jd3 = GetRandomAngle()
              local jl = GetRandomReal(0, 150)
              local h
              if GetRandomInt(1, 2) == 1 then
                h = GetRandomReal(0, 250)
              else
                h = GetRandomReal(250, 500)
              end
              xx, yy = PolarXY(x, y, jl, jd3)
              local ntx = EffectcreateArgs({
                effect = "ATX\\[ATxNew]Light_25.mdl",
                x = xx,
                y = yy,
                time = 1.01,
                height = h,
                zxz = GetRandomAngle(),
                xxz = 45
              })
              ac.wait(1000, function()
                SetEffectSize(ntx, 0.01)
              end)
            end)
          end)
        end)
        ac.wait(25000, function()
          mj:setcolor(255, 255, 255, 0)
          mj2:setcolor(255, 255, 255, 255)
          bs:animeact(6)
          bs:animespeed(1)
          ac.wait(9000, function()
            mj2:effectadd("AATX\\[AATxNew]Hit35.mdl", "hand right")
          end)
          ac.wait(10000, function()
            Effectcreate("AATX\\[AATxNew]Dust16.mdl", x, y, 0, 2)
          end)
          ac.wait(18750, function()
            Effectcreate("AATX\\[AATxNew]Blue22.mdl", x, y)
            Effectcreate("AATX\\[AATxNew]Dust11.mdl", x, y, 0, 5)
            Effectcreate("AATX\\[AATxNew]Green07.mdl", x, y, 0, 3)
            Effectcreate("AATX\\[AATxNew]Green02.mdl", x, y, 10, 2)
            Effectcreate("ATX\\[ATxNew]Animated_16.mdl", x, y, 10, 5)
          end)
          ac.wait(20900, function()
            bs:animeact(10)
            bs:animespeed(0.5)
          end)
          ac.wait(21400, function()
            local xx, yy = PolarXY(x, y, -200, jd)
            local dx = 2
            ac.timer(250, 6, function()
              dx = dx + 1.25
              Effectcreate("Abilities\\Spells\\Other\\HowlOfTerror\\HowlCaster.mdl", xx, yy, 0, dx)
            end)
          end)
          ac.wait(23500, function()
            ResetUnitAnimation(bs.handle)
          end)
          ac.wait(25420, function()
            mj2:animeact(1)
            mj2:animespeed(0.5)
          end)
          ac.wait(27200, function()
            Effectcreate("ETX\\[ETxNew]004.mdl", x, y, 11.9, 1, 225, 0, 0, 0, 0.3)
            local dmj = u:createunit("u0BO", x, y, GetRandomAngle())
            dmj:timetoremove(15)
          end)
          ac.wait(39100, function()
            mj2:animeact(3)
            Effectcreate("ETX\\[ETxNew]002.mdl", x, y)
            flashphoto({
              photo = "Shirou\\Ph_Shirou_09 (1).blp",
              timeout = 0,
              timehold = 0.5,
              timein = 0.5
            })
          end)
        end)
        ac.wait(67000, function()
          ac.wait(300, function()
            bs:animeact(10)
            bs:animespeed(0.5)
          end)
          ac.wait(600, function()
            local xx, yy = PolarXY(x, y, -200, jd)
            Effectcreate("AATX\\[AATxNew]Red07.mdl", xx, yy, 0, 3)
            local xs = 45
            local x = xx
            local y = yy
            ac.timer(100, 30, function()
              xs = xs - 1.5
              bs:setcolor(255, 255, 255, math.floor(xs * 2.55))
              local jl = GetRandomReal(0, 150)
              local h
              if GetRandomInt(1, 2) == 1 then
                h = GetRandomReal(0, 250)
              else
                h = GetRandomReal(250, 500)
              end
              xx, yy = PolarXY(x, y, jl, GetRandomAngle())
              Effectcreate("AATX\\[AATxNew]Red08.mdl", xx, yy, 0, 1, h)
            end)
          end)
          ac.wait(3600, function()
            Effectcreate("AATX\\[AATxNew]Red07.mdl", xx, yy, 0, 2)
            mj:animeact(18)
            mj:setcolor(255, 255, 255, 255)
            mj2:setcolor(255, 255, 255, 0)
          end)
          ac.wait(3900, function()
            Effectcreate("AATX\\[AATxNew]Black09.mdl", x, y)
          end)
          ac.wait(4000, function()
            mj:setcolor(255, 255, 255, 0)
            mj2:animeact(2)
          end)
          ac.wait(4600, function()
            Effectcreate("ATX\\[ATxNew]Dust_01.mdl", x, y, 0, 2)
            Effectcreate("ATX\\[ATxNew]Dust_02.mdl", x, y)
            local xx, yy = PolarXY(x, y, 150, jd)
            Effectcreate("AATX\\[AATxNew]Thunder13.mdl", xx, yy, 0, 5, 50, jd)
            Effectcreate("AATX\\[AATxNew]Dust07.mdl", xx, yy, 0, 5, 50, jd)
            local xx, yy = PolarXY(x2, y2, -250, jd)
            mj2:setcolor(255, 255, 255, 255)
            Effectcreate("AATX\\[AATxNew]Black09.mdl", xx, yy)
            mj2:setxy(xx, yy)
          end)
          ac.wait(4700, function()
            Effectcreate("AATX\\[AATxNew]Katana10.mdl", x2, y2, 0, 3, 0, 180 + jd)
          end)
          ac.wait(5500, function()
            Effectcreate("AATX\\[AATxNew]Katana61.mdl", x2, y2, 0, 1.5)
          end)
          ac.wait(7000, function()
            Effectcreate("AATX\\[AATxNew]Katana20.mdl", x2, y2, 0, 0.5)
            Effectcreate("ATX\\[ATxNew]Daoguang_20.mdl", x2, y2, 0, 2.5)
            Effectcreate("ATX\\[ATxNew]Daoguang_13.mdl", x2, y2, 0.5, 1)
            mb:animespeed(0)
          end)
          ac.wait(8800, function()
            local xx, yy = PolarXY(x2, y2, 750, jd)
            local tx = Effectcreate("war3mapImported\\176.mdl", xx, yy, 60, 5, 0, jd)
            ac.wait(500, function()
              SetEffectActSpeed(tx, 0.01)
            end)
            local xx, yy = PolarXY(xx, yy, -1000, jd)
            local cs = 0
            ac.timer(50, 10, function()
              cs = cs + 1
              xx, yy = PolarXY(xx, yy, 200, jd)
              Effectcreate("AATX\\[AATxNew]Dust04.mdl", xx, yy)
            end)
          end)
          ac.wait(12000, function()
            mb:animeact("death")
            mb:animespeed(1)
            Effectcreate("ATX\\[ATxNew]Blood_07.mdl", x2, y2, 2, 5)
            Effectcreate("ATX\\[ATxNew]Blood_04.mdl", x2, y2, 0, 3)
            Effectcreate("AATX\\[AATxNew]Blood16.mdl", x2, y2, 2, 5, 0, jd)
            Effectcreate("AATX\\[AATxNew]Blood23.mdl", x2, y2, 2, 5, 0, jd)
          end)
          ac.wait(12500, function()
            mb:animespeed(0)
          end)
          ac.wait(14700, function()
            local xx, yy = PolarXY(x2, y2, -250, jd)
            Effectcreate("AATX\\[AATxNew]Dust17.mdl", xx, yy, 0, 2)
            Effectcreate("AATX\\[AATxNew]Red11.mdl", xx, yy, 3, 5)
            ac.timer(100, 13, function()
              Effectcreate("AATX\\[AATxNew]Red07.mdl", xx, yy, 0, 1.5, 0, GetRandomAngle())
            end)
          end)
          ac.wait(16270, function()
            local xx, yy = PolarXY(x2, y2, -250, jd)
            Effectcreate("AATX\\[AATxNew]Red41.mdl", xx, yy, 0, 3, 150)
            Effectcreate("AATX\\[AATxNew]Red29.mdl", xx, yy)
            mj2:animeact(4)
            mj2:animespeed(0.5)
            local dx = 1
            ac.timer(200, 25, function()
              dx = dx + 0.2
              Effectcreate("war3mapImported\\specialanimedustwave.mdx", xx, yy, 0, dx, 0, GetRandomAngle())
            end)
          end)
          ac.wait(18160, function()
            local xx, yy = PolarXY(x2, y2, -250, jd)
            local dx = 1
            ac.timer(200, 25, function()
              dx = dx + 0.2
              Effectcreate("war3mapImported\\specialanimedustwave.mdx", xx, yy, 0, dx, 0, GetRandomAngle())
            end)
          end)
        end)
      end)
      ac.wait(178000, function()
        ac.wait(199.99999999998863, function()
          local jd2 = jd
          local cs2 = 0
          ac.timer(100, 4, function()
            jd2 = jd2 + 12
            mb:effectadd("ATX\\[ATxNew]Blood_04.mdl", "chest")
            mb:effectadd("ATX\\[ATxNew]Blood_17.mdl", "chest")
            local xx, yy = PolarXY(x2, y2, 750, jd2)
            local tx = Effectcreate("war3mapImported\\176.mdl", xx, yy, 60, 5, 0, jd2)
            ac.wait(500, function()
              SetEffectActSpeed(tx, 0.01)
            end)
            local xx, yy = PolarXY(xx, yy, -100, jd2)
            ac.timer(50, 10, function()
              xx, yy = PolarXY(xx, yy, 200, jd2)
              Effectcreate("AATX\\[AATxNew]Dust04.mdl", xx, yy, 0, 1)
            end)
          end)
          ac.wait(50, function()
            local jd2 = jd
            local cs2 = 0
            ac.timer(100, 4, function()
              jd2 = jd2 - 12
              mb:effectadd("ATX\\[ATxNew]Blood_04.mdl", "chest")
              mb:effectadd("ATX\\[ATxNew]Blood_17.mdl", "chest")
              local xx, yy = PolarXY(x2, y2, 750, jd2)
              local tx = Effectcreate("war3mapImported\\176.mdl", xx, yy, 60, 5, 0, jd2)
              ac.wait(500, function()
                SetEffectActSpeed(tx, 0.01)
              end)
              local xx, yy = PolarXY(xx, yy, -100, jd2)
              ac.timer(50, 10, function()
                xx, yy = PolarXY(xx, yy, 200, jd2)
                Effectcreate("AATX\\[AATxNew]Dust04.mdl", xx, yy, 0, 1)
              end)
            end)
          end)
        end)
        ac.wait(1099.9999999999943, function()
          local jd2 = jd
          mj2:animeact(5)
          mj2:animespeed(3)
          CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 1.0, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0.0, 0.0, 0)
          mb:effectadd("ATX\\[ATxNew]Blood_04.mdl", "chest")
          mb:effectadd("ATX\\[ATxNew]Blood_17.mdl", "chest")
          local xx, yy = PolarXY(x2, y2, 750, jd2)
          local tx = Effectcreate("war3mapImported\\176.mdl", xx, yy, 60, 5, 0, jd2)
          ac.wait(500, function()
            SetEffectActSpeed(tx, 0.01)
          end)
          local xx, yy = PolarXY(xx, yy, -100, jd2)
          ac.timer(50, 10, function()
            xx, yy = PolarXY(xx, yy, 200, jd2)
            Effectcreate("AATX\\[AATxNew]Dust04.mdl", xx, yy, 0, 1)
          end)
        end)
      end)
      ac.wait(12370, function()
        musiccolortext({
          strz = {
            {
              str = " 『 身 体 』 ",
              time = 0,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 250,
              sy = 300,
              dx = 35
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FFFF9900"
        })
        musiccolortext({
          strz = {
            {
              str = " 『 意 識 』 ",
              time = 0.53,
              showtexttime = 0.5,
              staytime = 3,
              fadetime = 0.75,
              sx = 1250,
              sy = 450,
              dx = 35
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FF99FFFF"
        })
        musiccolortext({
          strz = {
            {
              str = " 『 漸 漸 模 糊 崩 潰 』 ",
              time = 3.01,
              showtexttime = 0.5,
              staytime = 0.5,
              fadetime = 0.75,
              sx = 250,
              sy = 600,
              dx = 35
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FF949596"
        })
        musiccolortext({
          strz = {
            {
              str = " 『 我 究 竟 為 何 在 此 』 ",
              time = 7,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 250,
              sy = 300,
              dx = 35
            },
            {
              str = " 『 我 究 竟 為 何 這 般 』 ",
              time = 12,
              showtexttime = 0.5,
              staytime = 3.5,
              fadetime = 0.75,
              sx = 250,
              sy = 400,
              dx = 35
            },
            {
              str = " 『 我 究 竟 為 何 而 戰 』 ",
              time = 16.5,
              showtexttime = 0.5,
              staytime = 2.5,
              fadetime = 0.75,
              sx = 250,
              sy = 500,
              dx = 35
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FFFF9900"
        })
      end)
      ac.wait(52000, function()
        musiccolortext({
          strz = {
            {
              str = " 『 跟 得 上 來 麼 』 ",
              time = 1,
              showtexttime = 0.1,
              staytime = 3,
              fadetime = 0.75,
              sx = 600,
              sy = 700,
              dx = 35
            }
          },
          colorstart = "00FFFFFF",
          colorend = "FFFF3300"
        })
      end)
      ac.wait(55000, function()
        local strz = {}
        local a = 1
        for i = 1, 14 do
          local dx
          if a == 1 then
            a = 2
            dx = 600 - GetRandomReal(250, 450)
          else
            a = 1
            dx = 600 + GetRandomReal(600, 800)
          end
          local str
          if i <= 10 then
            str = "ピ"
          else
            str = "バ"
          end
          table.insert(strz, {
            str = str,
            time = i * 0.5,
            showtexttime = 0.5,
            showtime = 0.5,
            staytime = 0.5,
            fadetime = 0.5,
            sx = dx,
            sy = GetRandomReal(300, 550),
            dx = 35
          })
        end
        musiccolortext({
          strz = strz,
          colorstart = "00FFFFFF",
          colorend = "FF33FF33"
        })
      end)
      ac.wait(65300, function()
        textjbchange({
          text = text,
          strstart = "|cFFFF6633『",
          strz = "跟得上来吗",
          strend = "』|r",
          time = 1.5,
          shunxu = 1,
          waittime = 0
        })
        textjbchange({
          text = text,
          strstart = "|cFFFF6633『跟得上来吗",
          strz = "个鬼",
          strend = "』|r",
          time = 0.5,
          shunxu = 1,
          waittime = 2.7
        })
        textjbchange({
          text = text,
          strstart = "|cFFFF6633『",
          strz = "你这家伙",
          strend = "』|r",
          time = 0.5,
          shunxu = 1,
          waittime = 4.5
        })
        ac.wait(8500.0, function()
          textjianyin(2, text)
        end)
        textjbchange({
          text = text,
          strstart = "|cFFFF6633『",
          strz = "才应该跟上来啊！",
          strend = "』|r",
          time = 1.4,
          shunxu = 1,
          waittime = 16.1
        })
        ac.wait(18800.0, function()
          textjianyin(2, text)
        end)
        ac.wait(35800.0, function()
          textjbchange({
            text = text,
            strstart = "|cFF66FF99『",
            strz = "Trace",
            strend = "』|r",
            time = 0.4,
            shunxu = 1,
            waittime = 0
          })
          textjbchange({
            text = text,
            strstart = "|cFF66FF99『Trace",
            strz = " On",
            strend = "』|r",
            time = 0.4,
            shunxu = 1,
            waittime = 1.4
          })
          ac.wait(1810.0, function()
            textjianyin(2, text)
          end)
        end)
      end)
      ac.wait(124390, function()
        colorGradientText(text, {
          "FFFF3300",
          "FF00FF99",
          "FFFF3300"
        }, 3, 40, true)
        textjbchange({
          text = text,
          strstart = "『",
          strz = "Trigger",
          strend = "』",
          time = 1,
          shunxu = 1,
          waittime = 0
        })
        textjbchange({
          text = text,
          strstart = "『Trigger",
          strz = " off",
          strend = "』",
          time = 0.37,
          shunxu = 1,
          waittime = 1.95
        })
        ac.wait(2330.0, function()
          textjianyin(2.4, text)
        end)
        ac.wait(16860, function()
          colorGradientText(text, {
            "FFFF3300",
            "FF00FF99",
            "FF3366FF",
            "FF66FFFF",
            "FFFF3300"
          }, 5, 40, true)
          textjbchange({
            text = text,
            strstart = "『",
            strz = "Nine Lives",
            strend = "』",
            time = 0.37,
            shunxu = 1,
            waittime = 0
          })
          ac.wait(2400, function()
            textjbchange({
              text = text,
              strstart = "『Nine Lives",
              strz = " Blade Works",
              strend = "』",
              time = 1,
              shunxu = 1,
              waittime = 0
            })
          end)
          ac.wait(8000, function()
            textjianyin(2.4, text)
            ac.wait(3000, function()
              stopColorGradient()
              text:destroy()
            end)
          end)
        end)
        ac.wait(52110, function()
          PlayGlobalSound(Sound_Shirou_51)
        end)
      end)
      ac.wait(181000, function()
        mb:clearbuff("无敌")
        mb:zsdamage(u.handle)
        ac.wait(10, function()
          DamageUnit({
            bj = "射杀百头",
            unit = mb.handle,
            source = u.handle,
            damage = 1000,
            level = 5,
            type = "物理",
            isvest = false,
            isattack = false,
            isnoarmor = false,
            element = "无",
            extradata = {
              "士郎-固定伤害"
            }
          })
        end)
      end)
      ac.wait(195000, function()
        u:deldata("卫宫士郎-射杀百头演出")
        Nofail_Biaoji = false
        heimu:destroy()
        heimu2:destroy()
        Movie_Boolean = false
        FogEnable(true)
        FogMaskEnable(true)
        mb:animespeed(1)
        local x, y = mj2:getxy()
        local jd = mj2:getface()
        mj:remove()
        mj2:remove()
        bs:remove()
        ShowUnit(u.handle, true)
        u:setxy(x, y)
        u:setface(jd)
        u:select()
        u:changedata("力量增幅", 0.25)
        local sy = u.ownerid
        ChangeValue(Correction_Jzsh, sy, 0.033)
        u:setdata("特殊判定-士郎的正义")
        ChangeValue(DamageSystem_Shjc, sy, 0.05)
        ChangeValue(Correction_Jzsh, sy, 0.05)
        Effectcreate("AATX\\[AATxNew]Black09.mdx", x, y)
        ac.loop(1000, function()
          if u:isalive() and u:getmaxhp() >= 500 then
            ChangeValue(DamageSystem_Shjc, sy, 1.0E-4)
            local down = 0.0025 * Correction_MHpOrigin[sy] + 1
            u:changeoriginmaxhp(-down)
          end
        end)
        if u:hasdata("变异判定-正义的伙伴") then
          u:uivar_add({
            keyname = "士郎初始",
            keytype = "传奇栏",
            text = "|cFFFF0000士郎|r|cFFFF3300の|r|cFFFF6600正义|r\n|cFFFF3300提升25%力量\n提升5%伤害加成\n每秒削减[0.25%+1]生命上限并提升0.01%伤害加成修正，低于500时不会触发\n死亡时永久死亡，无视常规复活效果|r",
            icon = "war3mapImported\\PASBTNEwl_Shirou_90"
          })
        else
          u:uivar_add({
            keyname = "士郎初始",
            keytype = "传奇栏",
            text = "|cFFFF0000士郎|r|cFFFF3300の|r|cFFFF6600正义|r\n|cFFFF3300提升25%力量\n提升5%伤害加成\n每秒削减[0.25%+1]生命上限并提升0.01%伤害加成修正，低于500时不会触发\n死亡时永久死亡，无视常规复活效果|r",
            icon = "war3mapImported\\PASBTNEwl_Shirou_90"
          })
        end
        u:uivar_add({
          keyname = "士郎初始2",
          keytype = "传奇栏",
          text = "|cFFFF6600理想|r|cFFFF3300の|r|cFFFF0000映照|r\n|cFFFF3300强化魔术效果翻倍\n提升50%近战武器修正\n提升3.3%近战伤害\n受到单次伤害不会超过15%最大生命值|r",
          icon = "war3mapImported\\PASBTNEwl_Shirou_91"
        })
      end)
    end
  end,
  ["木大木大"] = function(u, mb)
    local huangzhen = u:getdata("茸茸-黄镇模型")
    u:playsound(Mudamudamuda)
    local x, y = u:getxy()
    local jd = AngleBetweenUnits(u.handle, mb.handle)
    u:setface(jd)
    local dx, dy = PolarXY(x, y, GetRandomReal(100, 400), jd)
    u:buffset(u.handle, 12, "暂停")
    u:buffset(u.handle, 12, "无敌")
    u:buffset(u.handle, 12, "绝对闪避")
    u:setdata("茸茸-木大释放中")
    mb:buffset(u.handle, 14, "暂停")
    mb:buffset(u.handle, 14, "沉默")
    mb:setdata("木大木大-死亡抗拒")
    mb:addstexiao("木大木大", "伤害显示后效果", function(args)
      local tg = args.tg
      local u = args.u
      local info = args.damageinfo
      if info.damage >= tg:gethp() and tg:hasdata("木大木大-死亡抗拒") then
        info.sk = true
        info.damage = 0
      end
    end)
    ac.wait(1, function()
      unitmove({
        unit = mb.handle,
        time = 0.1,
        distance = 400,
        angle = jd,
        isfly = true
      })
      ac.wait(500, function()
        unitmove({
          unit = mb.handle,
          time = 2,
          distance = 200,
          angle = jd,
          isfly = true
        })
      end)
      u:shockcamera(200, 0.1)
      EffectcreateArgs({
        effect = "war3mapImported\\tx_rongrong_chongjibo1.mdx",
        x = dx,
        y = dy,
        size = 2,
        height = -200,
        zxz = jd,
        animespeed = 1
      })
      for i = 1, 4 do
        EffectcreateArgs({
          effect = "war3mapImported\\tx_rongrong_wuqi1.mdx",
          x = dx,
          y = dy,
          size = 10,
          height = 100,
          zxz = jd + 180,
          xxz = GetRandomReal(-90, 90),
          yxz = 90,
          animespeed = GetRandomReal(3, 5)
        })
      end
    end)
    ac.wait(2200, function()
      local cs = 0
      local cs1 = 0
      local sj2 = 0
      local dcs = 0
      huangzhen:animeact("attack")
      huangzhen:setdata("黄镇-角度变化", 0)
      ac.loop(10, function(t)
        cs = cs + 1
        cs1 = cs1 + 1
        dcs = dcs + 1
        x, y = u:getxy()
        jd = u:getface()
        local x1, y1 = PolarXY(x, y, GetRandomReal(0, 300), jd + GetRandomReal(-30, 30))
        local sj1 = 100
        if dcs == 5 then
          dcs = 0
          local down = 100000 + 0.01 * mb:getmisshp()
          LossHpUnit({
            u = u,
            tg = mb,
            damage = down,
            perhp = 0,
            maxhp = 0,
            bj = "[生命损耗]木大木大"
          })
        end
        if cs < 350 then
          sj1 = GetRandomReal(0.5, 1.5)
          u:shockcamera(cs / 4, 0.1)
          sj2 = sj2 + 0.15
        end
        if 350 <= cs then
          sj1 = GetRandomReal(0.5, 3)
          if sj2 <= 30 then
            sj2 = sj2 + 1
          else
            sj2 = 30
          end
          if 10 <= cs1 then
            cs1 = 0
            local x2, y2 = PolarXY(x, y, GetRandomReal(500, 2000), jd + GetRandomReal(-30, 30))
            EffectcreateArgs({
              effect = "war3mapImported\\tx_rongrong_dizhen2.mdx",
              x = x2,
              y = y2,
              size = 0.5,
              height = 10,
              zxz = jd,
              yxz = 90,
              animespeed = GetRandomReal(1, 10)
            })
            if 600 <= cs then
              EffectcreateArgs({
                effect = "war3mapImported\\tx_rongrong_wuqi1.mdx",
                x = x1,
                y = y1,
                size = 10,
                height = 100,
                zxz = jd + 180,
                xxz = GetRandomReal(-90, 90),
                yxz = 90,
                animespeed = GetRandomReal(3, 5)
              })
            end
            u:shockcamera(cs / 4, 0.1)
          end
        end
        if cs <= 349 or 350 <= cs then
          EffectcreateArgs({
            effect = "war3mapImported\\tx_rongrong_chongjibo1.mdx",
            x = x1,
            y = y1,
            size = sj1,
            height = GetRandomReal(0, 500),
            zxz = jd + GetRandomReal(-sj2, sj2),
            xxz = GetRandomReal(-10, 10),
            yxz = GetRandomReal(-10, 10),
            animespeed = GetRandomReal(0.1, 4)
          })
          if cs < 300 or 350 < cs and cs < 600 then
            EffectcreateArgs({
              effect = "tx_rongrong_Text1.mdx",
              x = x1,
              y = y1,
              size = GetRandomReal(1, 2),
              height = 500,
              zxz = jd,
              animespeed = GetRandomReal(1, 3)
            })
          end
          if 600 < cs and cs < 900 then
            local x3, y3 = PolarXY(x1, y1, GetRandomReal(300, 1000), jd)
            EffectcreateArgs({
              effect = "tx_rongrong_Text1.mdx",
              x = x3,
              y = y3,
              size = GetRandomReal(1, 10),
              height = 300,
              zxz = jd,
              animespeed = GetRandomReal(1, 1)
            })
          end
        end
        if cs == 1 then
          unitmove({
            unit = u.handle,
            time = 3,
            distance = 500,
            angle = jd,
            isfly = true
          })
          unitmove({
            unit = mb.handle,
            time = 3,
            distance = 500,
            angle = jd,
            isfly = true
          })
        end
        if cs == 600 then
          unitmove({
            unit = u.handle,
            time = 4,
            distance = 500,
            angle = jd,
            isfly = true
          })
          unitmove({
            unit = mb.handle,
            time = 4,
            distance = 500,
            angle = jd,
            isfly = true
          })
        end
        if cs == 910 then
          huangzhen:animeact("stand")
          huangzhen:animespeed(1)
          huangzhen:setdata("黄镇-角度变化", -60)
          PlayGlobalSound(Sound_rongrong_Gold_muda1)
        end
        if 950 <= cs then
          u:deldata("茸茸-木大释放中")
          ac.wait(10, function()
            mb:deldata("木大木大-死亡抗拒")
            DamageUnit({
              bj = "木大木大",
              unit = mb.handle,
              source = u.handle,
              damage = 10000000,
              level = 5,
              type = "物理",
              isvest = false,
              isattack = true,
              isnoarmor = false,
              element = "无",
              extradata = {""}
            })
            for i = 1, 10 do
              local dx, dy = PolarXY(x, y, GetRandomReal(-1000, 1000), jd)
              EffectcreateArgs({
                effect = "war3mapImported\\tx_rongrong_chongjibo1.mdx",
                x = dx,
                y = dy,
                size = 5,
                height = -300,
                zxz = jd,
                xxz = GetRandomReal(-90, 90),
                animespeed = GetRandomReal(0.1, 0.3)
              })
              EffectcreateArgs({
                effect = "war3mapImported\\tx_rongrong_wuqi1.mdx",
                x = x1,
                y = y1,
                size = 10,
                height = 100,
                zxz = jd + 180,
                xxz = GetRandomReal(-90, 90),
                yxz = 90,
                animespeed = GetRandomReal(1, 3)
              })
            end
            local cs3 = 0
            ac.loop(10, function(t1)
              cs3 = cs3 + 1
              EffectcreateArgs({
                effect = "war3mapImported\\tx_rongrong_chongjibo1.mdx",
                x = x1,
                y = y1,
                size = 10,
                height = -300,
                zxz = jd,
                xxz = GetRandomReal(-90, 90),
                animespeed = GetRandomReal(0.1, 4)
              })
              if 10 <= cs3 then
                u:shockcamera(500, 0.3)
                t1:remove()
              end
            end)
          end)
          t:remove()
        end
      end)
    end)
  end,
  ["42斩杀"] = function(u)
    StopSoundBJ(Sound_42_Caidan, false)
    PlayGlobalSound(Sound_Srtr_K01)
    u:chat("哼")
    ac.wait(800, function()
      u:chat("不值一提")
    end)
    ac.wait(2500, function()
      u:chat("理所当然")
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:buffset(u.handle, 12, "绝对闪避")
      end)
    end)
    flashphoto({
      photo = "Ph_Srtr_01.tga",
      timeout = 4,
      timehold = 4,
      timein = 4
    })
    ac.wait(2000, function()
      PlayBGM({
        bgm = BGM_Srtr_K01,
        time = 45,
        ID = 193,
        unit = u.handle
      })
      musiccolortext({
        strz = {
          {
            str = "So loud the voice in head",
            time = 0,
            staytime = 3,
            fadetime = 3,
            sx = 50,
            sy = 170,
            dx = 35
          },
          {
            str = "Vigilante might not dead",
            time = 4,
            staytime = 3,
            fadetime = 3,
            sx = 60,
            sy = 220,
            dx = 35
          },
          {
            str = "Couldn't confess all heart",
            time = 7.7,
            staytime = 3,
            fadetime = 3,
            sx = 70,
            sy = 270,
            dx = 35
          },
          {
            str = "The rainbow it was just the start",
            time = 11.3,
            staytime = 3,
            fadetime = 3,
            sx = 80,
            sy = 320,
            dx = 35
          },
          {
            str = "Don't you know?",
            time = 16.1,
            staytime = 2,
            fadetime = 2,
            sx = 90,
            sy = 370,
            dx = 35
          },
          {
            str = "Don't you know?",
            time = 19.8,
            staytime = 2,
            fadetime = 2,
            sx = 100,
            sy = 420,
            dx = 35
          },
          {
            str = "Don't you know?",
            time = 23.5,
            staytime = 2,
            fadetime = 2,
            sx = 110,
            sy = 470,
            dx = 35
          },
          {
            str = "Don't you know?",
            time = 27.2,
            staytime = 2,
            fadetime = 2,
            sx = 120,
            sy = 520,
            dx = 35
          }
        },
        colorstart = "00FFFFFF",
        colorend = "FFFF0000"
      })
      musiccolortext({
        strz = {
          {
            str = "Loud the in my head",
            time = 0,
            staytime = 3,
            fadetime = 3,
            sx = 1075,
            sy = 205,
            dx = 35
          },
          {
            str = "She might not be dead",
            time = 4,
            staytime = 3,
            fadetime = 3,
            sx = 1085,
            sy = 255,
            dx = 35
          },
          {
            str = "Confess all my heart",
            time = 7.7,
            staytime = 3,
            fadetime = 3,
            sx = 1095,
            sy = 305,
            dx = 35
          },
          {
            str = "It was the start",
            time = 11.3,
            staytime = 3,
            fadetime = 3,
            sx = 1105,
            sy = 355,
            dx = 35
          },
          {
            str = "Is there heaven?",
            time = 16.1,
            staytime = 2,
            fadetime = 2,
            sx = 1115,
            sy = 405,
            dx = 35
          },
          {
            str = "Is there heaven?",
            time = 19.8,
            staytime = 2,
            fadetime = 2,
            sx = 1125,
            sy = 455,
            dx = 35
          },
          {
            str = "Is there heaven?",
            time = 23.5,
            staytime = 2,
            fadetime = 2,
            sx = 1135,
            sy = 505,
            dx = 35
          },
          {
            str = "Is there heaven?",
            time = 27.2,
            staytime = 2,
            fadetime = 2,
            sx = 1145,
            sy = 555,
            dx = 35
          }
        },
        colorstart = "00FFFFFF",
        colorend = "FFFF0066"
      })
    end)
    u:setdata("史尔特尔-斩杀奖励时间", 60)
    u:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "hand left", 60)
    u:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "hand right", 60)
    u:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile.mdl", "weapon", 60)
  end,
  ["绯想天"] = function(u)
    local sy = u.ownerid
    flashphoto({
      photo = "war3mapImported\\Tianzi_11.tga",
      timeout = 0.5,
      timehold = 2.5,
      timein = 2
    })
    PlayGlobalSound(BGM_Tianzi_1)
    PlayGlobalSound(Tz_3)
    PlayGlobalSound(Fu)
    NameID[sy] = "|cFF3399FF比那名居天子|r"
    u:setplayername(NameID[sy])
    u:effectadd("war3mapImported\\spellcardcall.mdx", "origin", 1)
    u:effectadd("war3mapImported\\[ake]war3ake.com - 3089005175819055203953915.mdx", "origin", 2)
    u:effectadd("war3mapImported\\[ake]war3ake.com - 4164979330353287516582371.mdx", "origin", 2)
    u:setdata("天子-绯想天")
    u:setdata("绯想天吸收伤害", 0)
    u:changemaxhp(2 * u:getmaxhp())
    ChangeValue(HeroMenu_HpForever_MaxHp, sy, 4)
    SendMsgAll("|cFFFF66FF----------有顶天变----------|r", 15)
    SendDtimeMsgAll(1, "|cFF3366FF「|r|cFF3370FF暗|r|cFF3379FFい|r|cFF3383FF顔|r|cFF338CFFし|r|cFF3396FFち|r|cFF339FFFゃ|r|cFF33A9FFて|r|cFF33B2FFっ|r|cFF33BCFFど|r|cFF33C6FFう|r|cFF33CFFFし|r|cFF33D9FFた|r|cFF33E2FFの|r|cFF33ECFF」|r", 15)
    SendDtimeMsgAll(6.5, "|cFF3366FF「|r|cFF3372FFこ|r|cFF337EFFん|r|cFF3389FFな|r|cFF3395FFに|r|cFF33A1FF空|r|cFF33ADFFは|r|cFF33B8FF蒼|r|cFF33C4FFい|r|cFF33D0FFの|r|cFF33DCFFに|r|cFF33E7FF」|r", 15)
    SendDtimeMsgAll(11, "|cFF3366FF「|r|cFF3375FFさ|r|cFF3385FFあ|r|cFF3394FF　|r|cFF33A3FF始|r|cFF33B3FFめ|r|cFF33C2FFよ|r|cFF33D1FFう|r|cFF33E0FF」|r", 15)
    SendDtimeMsgAll(56.5, "|cFF3366FF「|r|cFF336DFF悩|r|cFF3374FFみ|r|cFF337BFFひ|r|cFF3382FFと|r|cFF3389FFつ|r|cFF3390FFも|r|cFF3397FFな|r|cFF339EFFん|r|cFF33A5FFて|r|cFF33ACFFつ|r|cFF33B3FFま|r|cFF33B9FFら|r|cFF33C0FFな|r|cFF33C7FFい|r|cFF33CEFFじ|r|cFF33D5FFゃ|r|cFF33DCFFな|r|cFF33E3FFい|r|cFF33EAFF？|r|cFF33F1FF」|r", 15)
    SendDtimeMsgAll(63, "|cFF3366FF「|r|cFF336CFF乗|r|cFF3373FFり|r|cFF3379FF越|r|cFF3380FFえ|r|cFF3386FFる|r|cFF338CFF壁|r|cFF3393FFも|r|cFF3399FFな|r|cFF339FFFん|r|cFF33A6FFて|r|cFF33ACFF張|r|cFF33B2FFり|r|cFF33B9FF合|r|cFF33BFFFい|r|cFF33C6FFな|r|cFF33CCFFい|r|cFF33D2FFじ|r|cFF33D9FFゃ|r|cFF33DFFFな|r|cFF33E6FFい|r|cFF33ECFF？|r|cFF33F2FF」|r", 15)
    SendDtimeMsgAll(69, "|cFF3366FF「|r|cFF336EFFこ|r|cFF3376FFん|r|cFF337EFFな|r|cFF3386FF最|r|cFF338EFF高|r|cFF3396FFな|r|cFF339EFFの|r|cFF33A6FFて|r|cFF33AEFF有|r|cFF33B7FF頂|r|cFF33BFFF天|r|cFF33C7FFじ|r|cFF33CFFFゃ|r|cFF33D7FFな|r|cFF33DFFFい|r|cFF33E7FF？|r|cFF33EFFF」|r", 15)
    SendDtimeMsgAll(74.5, "|cFF3366FF「|r|cFF3370FF唯|r|cFF337AFF我|r|cFF3385FF独|r|cFF338FFF尊|r|cFF3399FF上|r|cFF33A3FF等|r|cFF33ADFFで|r|cFF33B8FF煩|r|cFF33C2FF悩|r|cFF33CCFFは|r|cFF33D6FF?|r|cFF33E0FF |r|cFF33EBFF」|r", 15)
    SendDtimeMsgAll(93.5, "|cFF3366FF「|r|cFF3372FF蒼|r|cFF337EFF天|r|cFF3389FFを|r|cFF3395FF抱|r|cFF33A1FFけ|r|cFF33ADFFハ|r|cFF33B8FFレ|r|cFF33C4FFル|r|cFF33D0FFヤ|r|cFF33DCFF！|r|cFF33E7FF」|r", 15)
    SendDtimeMsgAll(99.5, "|cFF3366FF「|r|cFF336EFF気|r|cFF3377FF持|r|cFF3380FFち|r|cFF3388FF良|r|cFF3390FFく|r|cFF3399FFな|r|cFF33A2FFら|r|cFF33AAFFな|r|cFF33B2FFき|r|cFF33BBFFゃ|r|cFF33C4FF意|r|cFF33CCFF味|r|cFF33D4FFが|r|cFF33DDFFな|r|cFF33E6FFい|r|cFF33EEFF」|r", 15)
    SendDtimeMsgAll(106, "|cFF3366FF「|r|cFF336DFFど|r|cFF3374FFう|r|cFF337BFFせ|r|cFF3382FF生|r|cFF3389FFき|r|cFF3390FFて|r|cFF3397FFく|r|cFF339EFFな|r|cFF33A5FFら|r|cFF33ACFF有|r|cFF33B3FF頂|r|cFF33B9FF天|r|cFF33C0FFで|r|cFF33C7FFい|r|cFF33CEFFき|r|cFF33D5FFま|r|cFF33DCFFし|r|cFF33E3FFょ|r|cFF33EAFFう|r|cFF33F1FF」|r", 15)
    SendDtimeMsgAll(118.5, "|cFF3366FF「|r|cFF336DFF紆|r|cFF3375FF余|r|cFF337CFF曲|r|cFF3383FF折|r|cFF338AFFも|r|cFF3392FFな|r|cFF3399FFい|r|cFF33A0FFな|r|cFF33A8FFん|r|cFF33AFFFて|r|cFF33B6FF悟|r|cFF33BDFFれ|r|cFF33C5FFな|r|cFF33CCFFい|r|cFF33D3FFじ|r|cFF33DBFFゃ|r|cFF33E2FFな|r|cFF33E9FFい|r|cFF33F0FF」|r", 15)
    SendDtimeMsgAll(125, "|cFF3366FF「|r|cFF3370FFや|r|cFF3379FFが|r|cFF3383FFて|r|cFF338CFF風|r|cFF3396FFに|r|cFF339FFF吹|r|cFF33A9FFか|r|cFF33B2FFれ|r|cFF33BCFF死|r|cFF33C6FFに|r|cFF33CFFF至|r|cFF33D9FFる|r|cFF33E2FF病|r|cFF33ECFF」|r", 15)
    SendDtimeMsgAll(131, "|cFF3366FF「|r|cFF336EFFこ|r|cFF3375FFん|r|cFF337DFFな|r|cFF3385FF退|r|cFF338CFF屈|r|cFF3394FFな|r|cFF339CFFの|r|cFF33A3FFっ|r|cFF33ABFFて|r|cFF33B3FF命|r|cFF33BAFF取|r|cFF33C2FFり|r|cFF33C9FFじ|r|cFF33D1FFゃ|r|cFF33D9FFな|r|cFF33E0FFい|r|cFF33E8FF？|r|cFF33F0FF」|r", 15)
    SendDtimeMsgAll(136.5, "|cFF3366FF「|r|cFF3373FF唯|r|cFF3380FF我|r|cFF338CFF独|r|cFF3399FF尊|r|cFF33A6FF上|r|cFF33B2FF等|r|cFF33BFFFの|r|cFF33CCFF我|r|cFF33D9FF儘|r|cFF33E6FF」|r", 15)
    SendDtimeMsgAll(155.5, "|cFF3366FF「|r|cFF3372FF蒼|r|cFF337EFF天|r|cFF3389FFを|r|cFF3395FF抱|r|cFF33A1FFけ|r|cFF33ADFFハ|r|cFF33B8FFレ|r|cFF33C4FFル|r|cFF33D0FFヤ|r|cFF33DCFF！|r|cFF33E7FF」|r", 15)
    SendDtimeMsgAll(161.5, "|cFF3366FF「|r|cFF336EFF気|r|cFF3377FF持|r|cFF3380FFち|r|cFF3388FF良|r|cFF3390FFく|r|cFF3399FFな|r|cFF33A2FFら|r|cFF33AAFFな|r|cFF33B2FFき|r|cFF33BBFFゃ|r|cFF33C4FF意|r|cFF33CCFF味|r|cFF33D4FFが|r|cFF33DDFFな|r|cFF33E6FFい|r|cFF33EEFF」|r", 15)
    SendDtimeMsgAll(168, "|cFF3366FF「|r|cFF336DFFど|r|cFF3374FFう|r|cFF337BFFせ|r|cFF3382FF生|r|cFF3389FFま|r|cFF3390FFれ|r|cFF3397FFた|r|cFF339EFFな|r|cFF33A5FFら|r|cFF33ACFF有|r|cFF33B3FF頂|r|cFF33B9FF天|r|cFF33C0FFで|r|cFF33C7FFい|r|cFF33CEFFき|r|cFF33D5FFま|r|cFF33DCFFし|r|cFF33E3FFょ|r|cFF33EAFFう|r|cFF33F1FF」|r", 15)
    SendDtimeMsgAll(193, "|cFF3366FF「|r|cFF3370FF地|r|cFF337AFF摇|r|cFF3385FFら|r|cFF338FFFぎ|r|cFF3399FFて|r|cFF33A3FF、|r|cFF33ADFF虹|r|cFF33B8FFよ|r|cFF33C2FF宙|r|cFF33CCFFを|r|cFF33D6FF渡|r|cFF33E0FFれ|r|cFF33EBFF」|r", 15)
    SendDtimeMsgAll(205, "|cFF3366FF「|r|cFF3371FF星|r|cFF337CFF燃|r|cFF3387FFえ|r|cFF3392FFて|r|cFF339DFF、|r|cFF33A8FF天|r|cFF33B2FFよ|r|cFF33BDFF人|r|cFF33C8FFを|r|cFF33D3FF創|r|cFF33DEFFれ|r|cFF33E9FF」|r", 15)
    SendDtimeMsgAll(217.5, "|cFF3366FF「|r|cFF3373FF蒼|r|cFF3380FF天|r|cFF338CFFを|r|cFF3399FF抱|r|cFF33A6FFけ|r|cFF33B2FFハ|r|cFF33BFFFレ|r|cFF33CCFFル|r|cFF33D9FFヤ|r|cFF33E6FF」|r", 15)
    SendDtimeMsgAll(223.5, "|cFF3366FF「|r|cFF336EFF楽|r|cFF3377FFし|r|cFF3380FFん|r|cFF3388FFで|r|cFF3390FFみ|r|cFF3399FFな|r|cFF33A2FFく|r|cFF33AAFFち|r|cFF33B2FFゃ|r|cFF33BBFFわ|r|cFF33C4FFか|r|cFF33CCFFら|r|cFF33D4FFな|r|cFF33DDFFい|r|cFF33E6FFの|r|cFF33EEFF」|r", 15)
    SendDtimeMsgAll(230, "|cFF3366FF「|r|cFF336DFFど|r|cFF3374FFう|r|cFF337BFFせ|r|cFF3382FF生|r|cFF3389FFき|r|cFF3390FFて|r|cFF3397FFく|r|cFF339EFFな|r|cFF33A5FFら|r|cFF33ACFF有|r|cFF33B3FF頂|r|cFF33B9FF天|r|cFF33C0FFで|r|cFF33C7FFい|r|cFF33CEFFき|r|cFF33D5FFま|r|cFF33DCFFし|r|cFF33E3FFょ|r|cFF33EAFFう|r|cFF33F1FF」|r", 15)
    PlayBGM({
      bgm = 0,
      time = 280,
      ID = 42,
      unit = u.handle
    })
    ac.wait(270000, function()
      flashphoto({
        photo = "war3mapImported\\Tianzi_22.tga",
        timeout = 0.5,
        timehold = 2.5,
        timein = 2
      })
      u:buffset(u.handle, 300, "暂停")
      u:buffset(u.handle, 300, "无敌")
      ac.wait(3500, function()
        u:shanmo()
        local x, y = u:getxy()
        Effectcreate("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdl", x, y, 0, 3)
        Effectcreate("war3mapImported\\[ake]war3ake.com - 1709800651073528605518801.mdl", x, y, 0, 3)
        ForGroupLuaNew(Group_DeathHero, function(xq)
          local xq2 = xq
          xq2:sendmessage("你已复活")
          HeroRelive(xq2.handle, x, y, 5)
        end)
        if BossBattle then
          local boss = getunit(BOSS)
          SendMsgAll("|cFFFF0000「这就是全人类的绯想天！」|r")
          PlayGlobalSound(Tz_4)
          PlayGlobalSound(Fu)
          u:effectadd("war3mapImported\\spellcardcall.mdx", "origin", 1)
          u:effectadd("war3mapImported\\[ake]war3ake.com - 2582828421786861605889534.mdl", "chest", 2)
          ac.wait(2000, function()
            local dx, dy = boss:getxy()
            Effectcreate("war3mapImported\\effect_by_wood_effect_d2_shadowfiend_shadowraze_1.mdx", x, y, 0, 3)
            Effectcreate("war3mapImported\\explotion_red.mdx", x, y, 0, 3)
            Effectcreate("war3mapImported\\texiao_taotaizhiren.mdx", x, y, 0, 3)
            PlayGlobalSound(boom1)
            local txsh = 10 * u:getdata("绯想天吸收伤害")
            DamageUnit({
              bj = "绯想天",
              unit = boss.handle,
              source = u.handle,
              damage = txsh,
              level = 4,
              type = "灵力",
              isvest = false,
              isattack = false,
              isnoarmor = false,
              element = "无",
              extradata = {""}
            })
          end)
        end
      end)
    end)
  end,
  ["红心Alice决"] = function(u, mb)
    local x, y = u:getxy()
    local jd = u:getface()
    local zjcs = GetRandomInt(4, 10)
    local sy = u.ownerid
    local txsh = 10000 + u:getdata("显示-固定伤害") + u:getdata("魔力值")
    local txsh2 = txsh * zjcs
    PlayGlobalSound(hongxin1)
    u:setface(jd)
    u:buffset(u.handle, 1.1, "暂停")
    u:buffset(u.handle, 1.5, "绝对闪避")
    u:buffset(u.handle, 1.5, "无敌")
    mb:buffset(u.handle, 1.1, "暂停")
    mb:buffset(u.handle, 1.1, "沉默")
    ShowUnitHide(u.handle)
    ac.wait(100, function()
      u:playsound(Sounds_Grab)
      u:shockcamera(100, 0.15)
      local dx, dy = mb:getxy()
      for i = 1, 20 do
        EffectcreateArgs({
          effect = "war3mapImported\\qiye_zhanji8.mdx",
          x = dx,
          y = dy,
          size = GetRandomReal(20, 40),
          height = GetRandomReal(0, 1000),
          zxz = GetRandomAngle(),
          xxz = GetRandomAngle(),
          yxz = GetRandomAngle(),
          animespeed = GetRandomReal(2, 4)
        })
        local tx = EffectcreateArgs({
          effect = "war3mapImported\\tx_cx_aixin.mdx",
          x = dx,
          y = dy,
          time = 0,
          size = 30,
          height = GetRandomReal(-1000, 1000),
          zxz = GetRandomAngle(),
          xxz = GetRandomAngle(),
          yxz = GetRandomAngle(),
          animespeed = 0.4
        })
        if type(japi.EXSetEffectColor) == "function" then
          japi.EXSetEffectColor(tx, 4294901760)
        end
      end
    end)
    ac.wait(500, function()
      u:playsound(Sounds_Grab)
      u:playsound(Sounds_Injection)
      u:shockcamera(100, 0.15)
      local dx, dy = mb:getxy()
      for i = 1, 10 do
        EffectcreateArgs({
          effect = "war3mapImported\\qiye_zhanji8.mdx",
          x = dx,
          y = dy,
          size = GetRandomReal(20, 40),
          height = GetRandomReal(0, 1000),
          zxz = GetRandomAngle(),
          xxz = GetRandomAngle(),
          yxz = GetRandomAngle(),
          animespeed = GetRandomReal(2, 4)
        })
      end
    end)
    ac.wait(500, function()
      local cs = 0
      ac.loop(100, function(t)
        cs = cs + 1
        local dx, dy = mb:getxy()
        for i = 1, cs do
          local tx = EffectcreateArgs({
            effect = "war3mapImported\\tx_cx_zhanji_1.mdx",
            x = dx,
            y = dy,
            size = GetRandomReal(5, 20),
            height = GetRandomReal(1000, 2000),
            zxz = GetRandomAngle(),
            xxz = GetRandomAngle(),
            yxz = GetRandomAngle(),
            animespeed = GetRandomReal(3, 6)
          })
          if type(japi.EXSetEffectColor) == "function" then
            japi.EXSetEffectColor(tx, 4294901760)
          end
        end
        local tx = EffectcreateArgs({
          effect = "war3mapImported\\tx_cx_aixin.mdx",
          x = dx,
          y = dy,
          time = 0,
          size = 30,
          height = GetRandomReal(-1000, 1000),
          zxz = GetRandomAngle(),
          xxz = GetRandomAngle(),
          yxz = GetRandomAngle(),
          animespeed = 1.0
        })
        if type(japi.EXSetEffectColor) == "function" then
          japi.EXSetEffectColor(tx, 4294901760)
        end
        u:shockcamera(300, 0.15)
        CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.5, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 10.0, 0.0, 0.0, 0.0)
        DamageUnit({
          bj = "红心Alice决",
          unit = mb.handle,
          source = u.handle,
          damage = txsh,
          level = 1,
          type = "物理",
          isvest = false,
          isattack = false,
          isnoarmor = false,
          element = "无",
          extradata = {"近战"}
        })
        if cs >= zjcs then
          u:playsound(Sounds_Final)
          local x1, y1 = mb:getxy()
          u:setxy(x1, y1)
          ShowUnitShow(u.handle)
          u:select()
          for i = 1, 10 do
            EffectcreateArgs({
              effect = "war3mapImported\\qiye_zhanji8.mdx",
              x = dx,
              y = dy,
              size = GetRandomReal(20, 40),
              height = GetRandomReal(0, 1000),
              zxz = GetRandomAngle(),
              xxz = GetRandomAngle(),
              yxz = GetRandomAngle(),
              animespeed = GetRandomReal(0.5, 2)
            })
            local tx = EffectcreateArgs({
              effect = "war3mapImported\\tx_cx_aixin.mdx",
              x = dx,
              y = dy,
              time = 0,
              size = 30,
              height = GetRandomReal(-1000, 1000),
              zxz = GetRandomAngle(),
              xxz = GetRandomAngle(),
              yxz = GetRandomAngle(),
              animespeed = 0.4
            })
            if type(japi.EXSetEffectColor) == "function" then
              japi.EXSetEffectColor(tx, 4294901760)
            end
          end
          ac.wait(150, function()
            u:shockcamera(500, 0.3)
            for i = 1, 10 do
              local tx = EffectcreateArgs({
                effect = "war3mapImported\\tx_cx_xuebao_3.mdx",
                x = dx,
                y = dy,
                time = 0.05,
                size = 10 * i,
                height = -150 * i,
                zxz = jd,
                animespeed = 1.0
              })
              if type(japi.EXSetEffectColor) == "function" then
                japi.EXSetEffectColor(tx, 4294901760)
              end
            end
          end)
          u:setdata("红心斩-附伤百分比", zjcs)
          DamageUnit({
            bj = "红心Alice决",
            unit = mb.handle,
            source = u.handle,
            damage = txsh2,
            level = 1,
            type = "物理",
            isvest = false,
            isattack = false,
            isnoarmor = false,
            element = "无",
            extradata = {"近战"}
          })
          t:remove()
        end
      end)
    end)
  end,
  ["沙海之晶"] = function(u)
    local sy = u.ownerid
    PlayBGM({
      bgm = BGM_Glass,
      time = 240,
      ID = 106,
      unit = u.handle
    })
    ac.wait(500, function()
      SendMsgAll("|cFFFF9900【|r|cFFFFA100世|r|cFFFFA900界|r|cFFFFB100的|r|cFFFFB800狭|r|cFFFFC000缝|r|cFFFFC800里|r|cFFFFD000有|r|cFFFFD800什|r|cFFFFE000么|r|cFFFFE700呢|r|cFFFFEF00】|r", 10)
    end)
    songtext({
      text = {
        {
          starttime = 10.5,
          str = "向着那询问的声音 少女莞尔一笑"
        },
        {
          starttime = 20,
          str = "金色的石头通透明亮"
        },
        {
          starttime = 27.5,
          str = "告诉我吧"
        },
        {
          starttime = 30,
          str = "寄居在天神居处的宝石"
        },
        {
          starttime = 40,
          str = "谁都没能亲眼目睹"
        },
        {
          starttime = 44.5,
          str = "古老国度里徘徊的沙漠之月"
        },
        {
          starttime = 49.5,
          str = "安静地侧耳倾听"
        },
        {
          starttime = 54.5,
          str = "那欺骗了少女的谎言"
        },
        {
          starttime = 64,
          str = "讲给孩子的温柔童话"
        },
        {
          starttime = 73,
          str = "已经被世人抛之脑后",
          time = 10
        },
        {
          starttime = 105.5,
          str = "既便如此我仍然记得"
        },
        {
          starttime = 110,
          str = "那个孩童捧在手中的"
        },
        {
          starttime = 114.5,
          str = "澄澈的金色石头"
        },
        {
          starttime = 120,
          str = "将它拾起"
        },
        {
          starttime = 125,
          str = "那是没有人见过的"
        },
        {
          starttime = 134.5,
          str = "璀璨夺目"
        },
        {
          starttime = 137,
          str = "可怜的人们 赋予了它宝石之名"
        },
        {
          starttime = 144.5,
          str = "从少女的手中"
        },
        {
          starttime = 149,
          str = "粗暴地夺去"
        },
        {
          starttime = 154,
          str = "却无法祈求逝去的万千生命 重新复苏"
        },
        {
          starttime = 169,
          str = "讲给孩子的温柔童话"
        },
        {
          starttime = 179,
          str = "已经被世人遗忘"
        },
        {
          starttime = 188.8,
          str = "如今世界的缝隙"
        },
        {
          starttime = 198.4,
          str = "就在少女的手心",
          time = 10
        }
      },
      color = {"FFFFCC00", "FFFFFFFF"},
      isjbcolor = true
    })
  end,
  ["神乐祈舞"] = function(u)
    do
      local sy = u.ownerid
      local x, y = u:getxy()
      local jd = u:getface()
      local mj = u:createunit("u08M", x, y, jd)
      ShowUnit(u.handle, false)
      Effectcreate("war3mapImported\\spellcardcall.mdx", x, y)
      Effectcreate("ATx\\[ATxNew]Green_18.mdl", x, y, 0, 1.5)
      SendMsgAll("|cFF66FF99「|r|cFF60AA91八|r|cFF5E8E8E岐|r|cFF5B718B神|r|cFF595588乐|r|cFF573986」|r")
      PlayBGM({
        bgm = Sound_Sanae_01,
        time = 170,
        ID = 22,
        unit = u.handle
      })
      mj:animeact("spell one")
      u:buffset(u.handle, 55, "绝对闪避")
      local cs = 0
      ac.loop(500, function(timer)
        cs = cs + 1
        mj:animeact("spell one")
        mj:animespeed(0.1)
        ac.wait(25, function()
          mj:animespeed(0.1)
        end)
        if cs == 49 then
          mj:animeact("stand")
          mj:animespeed(1)
          timer:remove()
        end
      end)
      u:buffset(u.handle, 20, "暂停")
      local cs2 = 0
      ac.loop(1000, function(timer)
        cs2 = cs2 + 1
        ForGroupLuaNew(Group_Monster, function(xq)
          xq:animespeed(0)
          xq:buffset(u.handle, 2, "暂停")
        end)
        if cs2 == 60 then
          ForGroupLuaNew(Group_Monster, function(xq)
            xq:animespeed(1)
            xq:buffset(u.handle, 1, "暂停")
          end)
          timer:remove()
        end
      end)
      ac.wait(1000, function()
        PlayGlobalSound(BGM_Sanae_01)
        local dx = 0
        local cs3 = 0
        local cf = {
          "|cFF66FF99「沉默的神风」|r",
          "|cFF66E3A4「自寂静渐破除沉眠」|r",
          "|cFF66C6B0「渺茫宇宙轮回几度」|r",
          "|cFF66AABB「结缘处乾坤定天象」|r",
          "|cFF668EC6「灵魂撼动不定」|r",
          "|cFF6671D2「交叠掌中唤醒奇迹」|r",
          "|cFF6655DD「海面亦为之洞开」|r",
          "|cFF6639E8「八岐招来——！」|r"
        }
        ac.loop(500, function(timer2)
          cs3 = cs3 + 1
          local dcount = cs3
          dx = dx + 0.2
          local mj2 = u:createunit("u08R", x, y, GetRandomAngle())
          Effectcreate("war3mapImported\\spellcardcall.mdx", x, y, 0, 1 + dx)
          mj2:setsize(dx)
          ac.wait(300, function()
            mj2:animespeed(0)
          end)
          ac.wait((6 - 0.5 * dcount) * 1000, function()
            mj2:animespeed(0.04)
          end)
          if cs3 <= 8 then
            ac.wait((3.5 + 2 * dcount) * 1000, function()
              SendMsgAll(cf[dcount], 10)
            end)
          end
          PlayGlobalSound(Fu)
          mj2:timetoremove(23.5 - 0.5 * dcount)
          if dcount == 10 then
            timer2:remove()
          end
        end)
        local jd2 = GetRandomAngle()
        local mjtx = {}
        for i = 1, 5 do
          jd2 = jd2 + 72
          local ddx, ddy = PolarXY(x, y, 100, jd2)
          mjtx[i] = u:createunit("u08U", ddx, ddy, jd2)
        end
        mjtx[6] = mjtx[1]
        mjtx[7] = mjtx[2]
        for i = 1, 5 do
          local jl = 100
          local cs4 = 0
          local dmj = mjtx[i]
          local dmj2 = mjtx[i + 1]
          local dmj3 = mjtx[i + 2]
          local djd = mjtx[i]:getface()
          local thu = AddLightning("CLPB", false, 0, 0, 0, 0)
          local thu2 = AddLightning("CLPB", false, 0, 0, 0, 0)
          ac.loop(50, function(timer3)
            cs4 = cs4 + 1
            jl = jl + 3
            djd = djd + 5
            local xx, yy = dmj:getxy()
            local xx2, yy2 = dmj2:getxy()
            local xx3, yy3 = dmj3:getxy()
            MoveLightningEx(thu, false, xx, yy, 0, xx2, yy2, 0)
            MoveLightningEx(thu2, false, xx, yy, 0, xx3, yy3, 0)
            xx, yy = PolarXY(x, y, jl, djd)
            dmj:setxy(xx, yy)
            if cs4 == 470 then
              DestroyLightning(thu)
              DestroyLightning(thu2)
              dmj:remove()
              Effectcreate("ATx\\[ATxNew]Thunder_16.mdl", xx, yy, 0, 5)
              Effectcreate("ATx\\[ATxNew]Thunder_18.mdl", xx, yy, 0, 3)
              timer3:remove()
            end
          end)
        end
        local g = CreateGroupLua()
        ac.wait(23500, function()
          PlayGlobalSound(Sound_Sanae_02)
          PlayGlobalSound(Sound_Sanae_03)
          local djd = mj:getface()
          local tq1 = u:createunit("u08V", x, y, djd)
          tq1:setcolor(0, 255, 255)
          local tq2 = u:createunit("u08V", x, y, djd + 15)
          tq2:setcolor(255, 0, 255)
          local tq3 = u:createunit("u08W", x, y, djd)
          local xx, yy = PolarXY(x, y, 750, djd)
          local tq4 = u:createunit("u08S", xx, yy, djd + 180)
          tq4:groupadd(g)
          tq4:animespeed(0.5)
          tq4:animeact("birth")
          ac.wait(1000, function()
            tq4:animeact("stand")
          end)
          Effectcreate("ATx\\[ATxNew]Dust_03.mdl", xx, yy, 0, 5)
          Effectcreate("ATx\\[ATxNew]Dust_33.mdl", xx, yy, 0, 5)
          Effectcreate("ATx\\[ATxNew]Dust_01.mdl", xx, yy, 0, 5)
          for i = 1, 7 do
            djd = djd + 45
            xx, yy = PolarXY(x, y, 750, djd)
            local newmj = u:createunit("u08T", xx, yy, djd + 180)
            newmj:animeact("birth")
            newmj:groupadd(g)
            newmj:animespeed(0.5)
            ac.wait(1000, function()
              newmj:animeact("stand")
            end)
            Effectcreate("ATx\\[ATxNew]Dust_03.mdl", xx, yy, 0, 3)
            Effectcreate("ATx\\[ATxNew]Dust_33.mdl", xx, yy, 0, 3)
            Effectcreate("ATx\\[ATxNew]Dust_01.mdl", xx, yy, 0, 3)
          end
          ac.wait(1000, function()
            SendMsgAll("|cFF999999八俣远吕智：|r|cFF990000「将吾唤醒的就是你么,神子」|r", 10)
          end)
          ac.wait(5000, function()
            SendMsgAll("|cFF999999八俣远吕智：|r|cFF990000「吾已知晓你的愿望」|r", 10)
          end)
          ac.wait(9000, function()
            SendMsgAll("|cFF999999八俣远吕智：|r|cFF990000「你已做好面对恐惧的觉悟了么？」|r", 10)
          end)
          ac.wait(13000, function()
            SendMsgAll("|cFF999999八俣远吕智：|r|cFF990000「很好」|r", 10)
          end)
          ac.wait(17000, function()
            SendMsgAll("|cFF999999八俣远吕智：|r|cFF990000「不屈之魂啊,终结吧」|r", 10)
            local tx = Effectcreate("ATx\\[ATxNew]Black_06.mdl", x, y, 7, 2)
            ac.wait(1500, function()
              SetEffectActSpeed(tx, 0)
            end)
          end)
          ac.wait(19000, function()
            local a = GetRandomAngle()
            for i = 1, 4 do
              a = a + 90
              local jl = 1200
              ac.timer(50, 40, function()
                jl = jl - 30
                a = a + 7
                local ddx, ddy = PolarXY(x, y, jl, a)
                Effectcreate("war3mapImported\\[TX] (1234).mdx", ddx, ddy, 0, 2)
              end)
            end
          end)
          ac.wait(21000, function()
            SendMsgAll("|cFF999999八俣远吕智：|r|cFF990000「在那之后——」|r", 10)
            mj:animeact("dissipate")
            Effectcreate("ATx\\[ATxNew]Cthulhu_19.mdl", x, y, 0, 2)
          end)
          ac.wait(22800, function()
            mj:animespeed(0)
          end)
          ac.wait(24000, function()
            ForGroupLuaNew(g, function(xq)
              xq:animeact("attack")
            end)
          end)
          ac.wait(25000, function()
            SendMsgAll("|cFF999999八俣远吕智：|r|cFF990000「开始吧」|r", 10)
            ForGroupLuaNew(g, function(xq)
              xq:remove()
            end)
            mj:remove()
            tq1:remove()
            tq2:remove()
            tq3:remove()
            Effectcreate("ATx\\[ATxNew]Black_11.mdl", x, y)
            ShowUnit(u.handle, true)
            Effectcreate("ATx\\[ATxNew]Green_18.mdl", x, y, 0, 1.5)
            u:select()
            AdvanceGet["神代の御神子"](u)
          end)
        end)
        local txlx = {
          "ATx\\[ATxNew]Wind_03.mdl",
          "ATx\\[ATxNew]Wind_05.mdl",
          "ATx\\[ATxNew]Wind_06.mdl"
        }
        local sjs = GetRandomInt(1, 3)
        for i = 1, 18 do
          local dcs = 0
          local fb = Effectcreate(txlx[sjs], x, y, 25, 3)
          local djd = jd + 20 * i
          local djl = 500
          local txdx = 0.2
          ac.loop(32, function(dtimer)
            dcs = dcs + 1
            djd = djd + 0.1
            djl = djl + 1
            txdx = txdx + 0.005
            local xx, yy = PolarXY(x, y, djl, djd)
            SetEffectXY(fb, xx, yy)
            SetEffectSize(fb, txdx)
            if dcs == 800 then
              dtimer:remove()
            end
          end)
        end
      end)
    end
  end,
  ["悲运的巫女"] = function(u)
    local sy = u.ownerid
    PlayGlobalSound(Sound_Jiegeng_10)
    local str1 = "|cFFFF0000犬|r|cFFFF3333夜|r|cFFFF6666叉|r|cFFFF9999：『"
    local str2 = "|cFF826DCA桔|r|cFF7A62C7梗|r|cFFC5B6E4：『"
    SendDtimeMsgAll(0.5, str1 .. "那时候我想要变成人类，和你一起生活" .. "』|r", 10)
    SendDtimeMsgAll(6.4, str2 .. "我终于...变成一个普通女人了" .. "』|r", 10)
    SendDtimeMsgAll(10.5, str1 .. "桔梗..." .. "』|r", 10)
    SendDtimeMsgAll(12.06, str1 .. "你是我生来喜欢上的第一个--重要的女人...结果...却没能为你做任何事..." .. "』|r", 10)
    SendDtimeMsgAll(24.37, str2 .. "第一次看见...犬夜叉,你哭泣时,会是这幅面孔啊..." .. "』|r", 10)
    SendDtimeMsgAll(31.06, str1 .. "桔梗...我,我没能救你..." .. "』|r", 10)
    SendDtimeMsgAll(36.33, str2 .. "你赶到了我身边...这样就足够了" .. "』|r", 10)
    SendDtimeMsgAll(44.8, str1 .. "桔梗..." .. "』|r", 10)
    SendDtimeMsgAll(54.98, str2 .. "犬夜叉..." .. "』|r", 10)
    SendDtimeMsgAll(64.4, str1 .. "桔梗..." .. "』|r", 10)
    ac.wait(47000, function()
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:buffset(u.handle, 10, "绝对闪避")
      end)
      flashphoto({
        photo = "war3mapImported\\Ph_Jiegeng.tga",
        timeout = 3,
        timehold = 1,
        timein = 3
      })
    end)
    ac.wait(75000, function()
      PlayGlobalSound(Sound_Jg_60)
      u:setplayername("|cFFFF0000犬|r|cFFFF3333夜|r|cFFFF6666叉|r")
      SendDtimeMsgAll(0, str1 .. "奈落，你纠结于尘世" .. "』|r", 10)
      SendDtimeMsgAll(3.7, str1 .. "如蛛丝般的触手和执念" .. "』|r", 10)
      SendDtimeMsgAll(6.8, str1 .. "还有与四魂之玉的因缘这所有的一切" .. "』|r", 10)
      SendDtimeMsgAll(9.9, str1 .. "由我一并斩断！" .. "』|r", 10)
      u:setdata("犬夜叉-连招时间", 0)
      u:setdata("变异判定-犬夜叉")
      NameAChange[sy] = "|cFFFF0000犬|r|cFFFF3333夜|r|cFFFF6666叉|r"
      u:additem("I0DU")
      u:additem("I0K0")
      ac.loop(100, function()
        if u:getdata("犬夜叉-连招时间") > 0 then
          u:changedata("犬夜叉-连招时间", -0.1)
          if u:getdata("犬夜叉-连招时间") <= 0 then
            u:setdata("犬夜叉-连招时间", 0)
          end
        end
      end)
      ModelReplace({
        u = u,
        model = "war3mapImported\\d3ace3e8a5a04330.mdl",
        modelsize = 2,
        modelname = "|cFFFF0000犬|r|cFFFF3333夜|r|cFFFF6666叉|r",
        modelicon = "Portrait_Qyc.tga",
        isforce = true
      })
      local dskill
      if u:ishasskill("A1AM") and u.type ~= HeroType["C呆"] and u.type ~= HeroType["莲华"] then
        dskill = "A1JU"
      else
        dskill = "A1JU"
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
              if not u:hasdata("犬夜叉-妖化") then
                local tilixh = 1
                
                if not u:hasdata("位移体力消耗标记") then
                  if u:lossstamina(tilixh) then
                    u:settimedata("位移体力消耗标记", 0.001)
                  else
                    u:setskillcd(args.skill, 0.01)
                    u:sendmessage("|cFFFF3300体力值不足|r")
                    return
                  end
                end
              end
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local angle = AngleXY(x, y, x2, y2)
              local dis = DistanceXY(x, y, x2, y2)
              u:setface(angle)
              if 600 <= dis then
                dis = 600
              end
              x2, y2 = PolarXY(x, y, dis, angle)
              Effectcreate("ATX\\[ATxNew]Black_01.mdl", x, y)
              Effectcreate("ATX\\[ATxNew]Black_01.mdl", x2, y2)
              u:setxy(x2, y2)
              if u:getdata("犬夜叉-连招时间") == 0 then
                u:setdata("犬夜叉-连招时间", 1)
                u:setdata("犬夜叉-连招F")
              end
              u:buffset(u.handle, 0.25, "绝对闪避")
              if not u:hasdata("犬夜叉-F刷新时间") then
                u:settimedata("犬夜叉-F刷新时间", 0.25)
              end
              if u:hasdata("犬夜叉-妖化") then
                ac.wait(1, function()
                  u:setskillcd("A1JU", 1)
                end)
              end
              if u:hasdata("犬夜叉-连招AEA") then
                u:deldata("犬夜叉-连招AEA")
                u:setdata("犬夜叉-连招AEAF")
                u:setdata("犬夜叉-连招时间", 1)
                u:banskill("A0CW")
                u:banskill("A1HN", false)
              end
            end
          end
          
          u:addtrgevent("单位-发动技能", function(args)
            skill(args)
          end)
        end
      })
      ARskillreplace({
        unit = u.handle,
        level = 2,
        skill_A = "A1HM",
        skill_R = "A1HN",
        isforce = false,
        efunc = function()
          u:addskill("A1JV")
          u:addskill("A1JW")
          u:addskill("A0CV")
          u:addskill("A0CW")
          u:addskill("A0CX")
          u:banskill("A1JV")
          u:banskill("A1JW")
          u:banskill("A0CV")
          u:banskill("A0CW")
          u:banskill("A0CX")
          gunban(u.handle)
          ac.loop(3000, function()
            gunban(u.handle)
          end)
          
          local function skill(args)
            if args.skill == S2ID("A0CX") then
              if u:hasdata("犬夜叉-狱龙破冷却") then
                u:sendmessage("|cFF663399冷却中|r")
                u:setskillcd("A0CX", 1)
                return
              end
              SendDtimeMsgAll(0, str1 .. "狱龙破！！！" .. "』|r", 10)
              u:settimedata("犬夜叉-狱龙破冷却", 150)
              ac.wait(150000, function()
                u:sendmessage("|cFF663399狱龙破冷却完毕|r")
              end)
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local jd = AngleXY(x, y, x2, y2)
              local txsh = 24444 + 2222 * u:getlevel()
              txsh = txsh * 1.5
              local txz = {}
              PlayGlobalSound(Qyc_Ylp_10)
              table.insert(txz, Effectcreate("Qyc_Ylp_01.mdx", x, y, 10, 0.01))
              table.insert(txz, Effectcreate("Qyc_Ylp_02.mdx", x, y, 10, 0.01))
              u:buffset(u.handle, 2.6, "绝对闪避")
              u:buffset(u.handle, 2.1, "暂停")
              local angleall = 0
              local size = 0.01
              local cs = 0
              ac.timer(30, 70, function()
                cs = cs + 1
                size = size + 0.02
                angleall = angleall + 10
                for index, value in ipairs(txz) do
                  SetEffectSize(value, size)
                  SetEffectAngle(value, 10)
                end
                if cs == 5 then
                  cs = 0
                  Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y, 0, 5 + size * 10, 0, GetRandomAngle())
                end
              end)
              local dx, dy = x, y
              ac.timer(2000, 4, function()
                table.insert(txz, Effectcreate("Qyc_Ylp_01.mdx", dx, dy, 10, size, 0, angleall))
                table.insert(txz, Effectcreate("Qyc_Ylp_02.mdx", dx, dy, 10, size, 0, angleall))
              end)
              ac.wait(2100, function()
                PlayGlobalSound(Qyc_Ylp_11)
                local tg = u
                for _, xq in ac.selector():in_rangexy(x, y, 1800):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  tg = xq
                  break
                end
                local dcs = 0
                local css = 0
                ac.loop(30, function(timer)
                  dcs = dcs + 1
                  css = css + 1
                  if dcs <= 300 then
                    dx, dy = PolarXY(dx, dy, 25, jd)
                    for index, value in ipairs(txz) do
                      SetEffectAngle(value, 10)
                      SetEffectXY(value, dx, dy)
                    end
                  end
                  if css == 3 then
                    css = 0
                    if tg ~= u then
                      local dx2, dy2 = tg:getxy()
                      jd = AngleXY(dx, dy, dx2, dy2)
                    else
                      for _, xq in ac.selector():in_rangexy(dx, dy, 1800):is_enemy(u.handle):ipairs() do
                        xq = getunit(xq)
                        tg = xq
                        break
                      end
                    end
                    if not tg:isalive() then
                      tg = u
                    end
                    for _, xq in ac.selector():in_rangexy(dx, dy, 2200):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      DamageUnit({
                        bj = "狱龙破",
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
                      xq:changedata("狱龙破命中次数", 1)
                      if 10 <= xq:getdata("狱龙破命中次数") then
                        xq:setdata("狱龙破命中次数", 0)
                        if xq:isnormal() then
                          xq:losshp(u, 0, 20, 1)
                        else
                          LossHpUnit({
                            u = u,
                            tg = xq,
                            damage = 0,
                            perhp = 5,
                            maxhp = 1,
                            bj = "[生命损耗]狱龙破"
                          })
                        end
                      end
                    end
                  end
                  if dcs == 380 then
                    timer:remove()
                  end
                end)
              end)
            end
            if args.skill == S2ID("A0CW") then
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local jd = AngleXY(x, y, x2, y2)
              local yxz = {
                Sound_Qyc_Fzs_01,
                Sound_Qyc_Fzs_S01,
                Sound_Qyc_Fzs_S02
              }
              u:playsound(yxz[GetRandomInt(1, #yxz)])
              u:buffset(u.handle, 3, "绝对闪避")
              u:buffset(u.handle, 2.5, "暂停")
              ac.wait(1, function()
                u:animeact("attack")
                u:animespeed(0.1)
              end)
              ac.wait(2500, function()
                u:animespeed(1)
              end)
              ac.wait(2500, function()
                local txsh = 12222 + 1111 * u:getlevel()
                txsh = txsh * 1.5
                local tx = Effectcreate("effect\\2212\\Tx_Jg_30 (9).mdl", x, y)
                local a3 = jd - 15
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
                    x2, y2 = PolarXY(x2, y2, 50, a2)
                    Effectcreate("new_qyc_01.mdx", x2, y2, 0, 3, 0, GetRandomAngle())
                    if cs2 == 2 then
                      cs2 = 0
                      Effectcreate("war3mapImported\\az_jugg_e1.mdx", x2, y2, 0, 3, 100, a2, 0, -60)
                    end
                    for _, xq in ac.selector():in_rangexy(x2, y2, 150):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      DamageUnit({
                        bj = "风之伤",
                        unit = xq.handle,
                        source = u.handle,
                        damage = txsh,
                        isattack = true
                      })
                      local kztime = 2
                      if xq:isboss() then
                        kztime = 0.5
                      end
                      xq:buffset(u.handle, kztime, "僵直")
                    end
                    if cs == 60 then
                      DestroyEffectLua(tx)
                      t:remove()
                    end
                  end)
                end
              end)
            end
            if args.skill == S2ID("A0CV") then
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local jd = AngleXY(x, y, x2, y2)
              local txsh = 8888 + 888 * u:getlevel()
              txsh = txsh * 1.5
              local da = GetRandomReal(0, 360)
              u:buffset(u.handle, 1.5, "绝对闪避")
              u:buffset(u.handle, 1, "暂停")
              ac.wait(1, function()
                u:animeact("attack")
              end)
              ac.wait(100, function()
                u:animespeed(0.25)
              end)
              if GetRandom100(50) then
                u:playsound(Sound_Qyc_Blp_02)
              else
                u:playsound(Sound_Qyc_Blp_01)
              end
              ac.wait(1000, function()
                u:animespeed(1)
                u:playsound(Sound_Qyc_Blp_03)
                for i = 1, 3 do
                  local a2 = da + 120 * i
                  local dchange
                  if i == 1 then
                    dchange = 30
                  else
                    dchange = -30
                  end
                  local cs = 0
                  local cs2 = 0
                  local x2, y2 = x, y
                  local g = CreateGroupLua()
                  local jl = 100
                  local jl2 = 100
                  local x3, y3
                  ac.loop(60, function(t)
                    cs = cs + 1
                    cs2 = cs2 + 1
                    jl = jl + 25
                    x2, y2 = PolarXY(x, y, jl, jd)
                    if cs2 == 3 then
                      cs2 = 0
                      Effectcreate("effect\\2212\\Tx_Jg_30 (3).mdl", x2, y2, 0, 3)
                    end
                    a2 = a2 + dchange
                    jl2 = jl2 + 6
                    x3, y3 = PolarXY(x2, y2, jl2, a2)
                    Effectcreate("effect\\2212\\Tx_Jg_30 (6).mdl", x3, y3, 0, 1, 30)
                    for _, xq in ac.selector():in_rangexy(x3, y3, 250):is_enemy(u.handle):allow_unify():ipairs() do
                      xq = getunit(xq)
                      if not xq:hasdata("系统-弹幕") then
                        DamageUnit({
                          bj = "爆流破",
                          unit = xq.handle,
                          source = u.handle,
                          damage = txsh,
                          isattack = true
                        })
                      else
                        xq:setdata("弹幕-生命值", 0)
                      end
                    end
                    if cs == 100 then
                      t:remove()
                    end
                  end)
                end
              end)
            end
            if args.skill == S2ID("A1HM") then
              local x, y = u:getxy()
              local jd = u:getface()
              Effectcreate("war3mapImported\\bbb.mdx", x, y)
              local x3, y3 = PolarXY(x, y, 150, jd)
              Effectcreate("war3mapImported\\2.20.607 (4).mdl", x3, y3, 0, 2, 75, jd)
              u:playsound(bac134)
              local txsh = 2500 + 500 * u:getlevel()
              txsh = txsh * 3
              local b = false
              for _, xq in ac.selector():in_rangexy(x, y, 400):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                b = true
                xq:buffset(u.handle, 0.5, "僵直")
                DamageUnit({
                  bj = "犬夜叉爪击",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "物理",
                  isvest = false,
                  isattack = true,
                  isnoarmor = false,
                  element = "无",
                  extradata = {""}
                })
                xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
              end
              if b then
                u:setskillcd("A1JV", u:getskillcd("A1JV") - 0.5)
                u:setskillcd("A1JW", u:getskillcd("A1JW") - 0.5)
                u:setskillcd("A1HN", u:getskillcd("A1HN") - 0.5)
                u:setskillcd("A0CV", u:getskillcd("A0CV") - 0.5)
                u:setskillcd("A0CW", u:getskillcd("A0CW") - 0.5)
              end
              ac.wait(1, function()
                u:animeact(1)
              end)
              if u:hasdata("犬夜叉-连招FAW") then
                u:deldata("犬夜叉-连招FAW")
                u:setdata("犬夜叉-连招FAWA")
                u:setdata("犬夜叉-连招时间", 1)
              end
              if u:hasdata("犬夜叉-连招FA") then
                u:deldata("犬夜叉-连招FA")
                u:setdata("犬夜叉-连招FAA")
                u:setdata("犬夜叉-连招时间", 1)
              end
              if u:hasdata("犬夜叉-连招F") then
                u:deldata("犬夜叉-连招F")
                u:setdata("犬夜叉-连招FA")
                u:setdata("犬夜叉-连招时间", 1)
              end
              if u:hasdata("犬夜叉-连招AE") then
                u:deldata("犬夜叉-连招AE")
                u:setdata("犬夜叉-连招AEA")
                u:setdata("犬夜叉-连招时间", 1)
                u:banskill("A1HN")
                u:banskill("A0CW", false)
                ac.wait(500, function()
                  u:banskill("A1HN", false)
                  u:banskill("A0CW")
                end)
              end
              if u:getdata("犬夜叉-连招时间") == 0 then
                u:setdata("犬夜叉-连招A")
                u:setdata("犬夜叉-连招时间", 1)
              end
            end
            if args.skill == S2ID("A1HN") then
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local jd = AngleXY(x, y, x2, y2)
              local dis = 2000
              u:buffset(u.handle, 4.5, "绝对闪避")
              u:buffset(u.handle, 4, "暂停")
              u:effectadd("effect\\2212\\Tx_Jg_30 (14).mdl", "weapon", 2)
              ac.wait(1, function()
                u:animeact(15)
              end)
              ac.wait(300, function()
                u:animespeed(0)
              end)
              ac.wait(2500, function()
                u:animespeed(1)
              end)
              u:playsound(Sound_Qyc_111)
              local txsh = 500000 + 500 * u:getallattri()
              ac.wait(2500, function()
                Effectcreate("war3mapImported\\bbb.mdl", x, y)
                local dis3 = dis / 2
                local x3, y3 = PolarXY(x, y, dis3, jd)
                local dx = dis / 800
                local jl2 = dx * 40
                local jd2 = jd + 90
                Effectcreate("war3mapImported\\2.21.247 (1).mdl", x3, y3, 0, dx, 0, jd)
                local x1, y1 = PolarXY(x3, y3, jl2, jd2)
                Effectcreate("war3mapImported\\2.21.247 (1).mdl", x1, y1, 0, dx, 0, jd)
                jd2 = jd - 90
                local x1, y1 = PolarXY(x3, y3, jl2, jd2)
                Effectcreate("war3mapImported\\2.21.247 (1).mdl", x1, y1, 0, dx, 0, jd)
                Effectcreate("war3mapImported\\nitu.mdl", x, y, 0, dx, 0, jd)
                local mj = u:createunit("u0D0", x, y, jd)
                ac.wait(1, function()
                  mj:animeact(0)
                end)
                local g = CreateGroupLua()
                unitmove({
                  unit = u.handle,
                  time = 0.2,
                  distance = dis,
                  angle = jd,
                  isfly = true,
                  loops = {
                    {
                      looptime = 0.01,
                      func = function(dx, dy)
                        mj:setxy(dx, dy)
                        for _, xq in ac.selector():in_rangexy(dx, dy, 400):is_enemy(u.handle):isnotingroup(g):ipairs() do
                          xq = getunit(xq)
                          xq:groupadd(g)
                          xq:buffset(u.handle, 0.75, "暂停")
                          xq:animespeed(0)
                          xq:effectadd("war3mapImported\\2.21.247 (3).mdl", "chest")
                        end
                      end
                    }
                  },
                  endfunc = function(dx, dy)
                    mj:remove()
                    ForGroupLuaNew(g, function(xq)
                      xq:buffset(u.handle, 1.5, "暂停")
                    end)
                    ac.wait(1000, function()
                      ForGroupLuaNew(g, function(xq)
                        xq:buffset(u.handle, 2, "暂停")
                        xq:animespeed(1)
                        xq:animeact("death")
                        xq:effectadd("war3mapImported\\texiao_xuebao.mdx", "chest")
                        DamageUnit({
                          bj = "散魂铁爪",
                          unit = xq.handle,
                          source = u.handle,
                          damage = txsh,
                          level = 1,
                          type = "物理",
                          isvest = false,
                          isattack = true,
                          isnoarmor = false,
                          element = "无",
                          extradata = {""}
                        })
                      end)
                    end)
                  end
                })
              end)
              if u:hasdata("犬夜叉-妖化") then
                u:setskillcd("A1HN", 20)
              end
            end
            if args.skill == S2ID("A1JV") then
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local jd = AngleXY(x, y, x2, y2)
              local dis = 3000
              u:buffset(u.handle, 4.5, "绝对闪避")
              u:buffset(u.handle, 4, "暂停")
              u:effectadd("effect\\2212\\Tx_Jg_30 (14).mdl", "weapon", 2)
              ac.wait(1, function()
                u:animeact(5)
              end)
              ac.wait(300, function()
                u:animespeed(0)
              end)
              ac.wait(2000, function()
                u:animespeed(1)
              end)
              if GetRandom100(50) then
                u:playsound(Sound_Qyc_61)
              else
                u:playsound(Sound_Qyc_Jgqp_01)
              end
              local txsh = 24444 + 2222 * u:getlevel()
              txsh = txsh * 1.5
              ac.wait(2000, function()
                Effectcreate("effect\\2212\\Tx_Jg_30 (7).mdl", x, y, 0, 2)
                local a2 = u:getface()
                local a3 = a2 + 90
                ac.timer(20, 100, function()
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
              end)
              if u:hasdata("犬夜叉-妖化") then
                u:setskillcd("A1JV", 35)
              end
            end
            if args.skill == S2ID("A1JW") then
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local a = AngleXY(x, y, x2, y2)
              local dis = 3000
              u:buffset(u.handle, 3.5, "绝对闪避")
              u:buffset(u.handle, 3, "暂停")
              u:effectadd("effect\\2212\\Tx_Jg_30 (14).mdl", "weapon", 2)
              ac.wait(1, function()
                u:animeact(9)
              end)
              ac.wait(1300, function()
                u:animeact(7)
              end)
              local yxz = {
                Sound_Qyc_62,
                Sound_Qyc_My_01,
                Sound_Qyc_My_02,
                Sound_Qyc_Mycdp_S01
              }
              u:playsound(yxz[GetRandomInt(1, #yxz)])
              local txsh = 24444 + 2222 * u:getlevel()
              txsh = txsh * 1.5
              ac.wait(1300, function()
                local jl = 100
                local cs3 = 0
                ac.loop(20, function(timer)
                  cs3 = cs3 + 1
                  local a2 = a + GetRandomReal(-45, 45)
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
                        bj = "冥月残道破",
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
                    if cs == 100 then
                      DestroyEffectLua(tx)
                      timer2:remove()
                    end
                  end)
                  if cs3 == 80 then
                    timer:remove()
                  end
                end)
              end)
              if u:hasdata("犬夜叉-妖化") then
                u:setskillcd("A1JW", 50)
              end
            end
          end
          
          u:addtrgevent("单位-发动技能", function(args)
            skill(args)
          end)
        end
      })
      local dskill = S2ID("A1M1")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            if not u:hasdata("犬夜叉-妖化台词") then
              u:setdata("犬夜叉-妖化台词")
              PlayGlobalSound(Sound_Jg_70)
              PlayBGM({
                bgm = BGM_Jg_80,
                time = 194,
                ID = 139,
                unit = u.handle
              })
              u:buffset(u.handle, 11.5, "暂停")
              u:buffset(u.handle, 13, "无敌")
              SendDtimeMsgAll(0, "|cFFFF0000犬|r|cFFFF3333夜|r|cFFFF6666叉|r|cFFFF9999：『流淌在我体内的妖怪之血』|r")
              SendDtimeMsgAll(5.4, "|cFFFF0000犬|r|cFFFF3333夜|r|cFFFF6666叉|r|cFFFF9999：『跟你比起来』|r")
              SendDtimeMsgAll(9.4, "|cFFFF0000犬|r|cFFFF3333夜|r|cFFFF6666叉|r|cFFFF9999：『是不完全不同层次的！』|r")
              local x, y = u:getxy()
              ac.wait(4000, function()
                Effectcreate("4.4.834 (14).mdl", x, y)
              end)
              ac.wait(11400, function()
                Effectcreate("4.4.834 (16).mdl", x, y)
              end)
            end
            u:animeact(4)
            u:setdata("犬夜叉-妖化抵挡", 3)
            u:setdata("犬夜叉-妖化")
            AddUnitAnimationProperties(u.handle, "alternate", true)
            ChangeValue(DamageSystem_Shjc, sy, 0.1)
            ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 300)
            u:effectadd("4.18.1255 (1).mdl", "origin", 194)
            u:effectadd("4.18.1255 (2).mdl", "origin", 194)
            u:effectadd("4.18.1255 (3).mdl", "origin", 194)
            u:effectadd("4.18.1255 (4).mdl", "origin", 194)
            if not u:hasdata("犬夜叉-全妖化") then
              if u:ishasitem("I0CE") then
                u:changedata("幸运", -6)
                u:removeitem("I0CE")
                u:setdata("犬夜叉-全妖化")
              else
                ewl:delskill("A1M1")
                ac.wait(194000, function()
                  AddUnitAnimationProperties(u.handle, "alternate", false)
                  u:deldata("犬夜叉-妖化抵挡")
                  u:deldata("犬夜叉-妖化")
                  ChangeValue(DamageSystem_Shjc, sy, -0.1)
                  ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -300)
                end)
              end
            end
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      
      local function chat(args)
        if args.chat == "-清醒" then
          local u = getunit(args.unit)
          if u:isalive() and u:hasdata("犬夜叉-全妖化") and u:hasdata("犬夜叉-妖化") then
            AddUnitAnimationProperties(u.handle, "alternate", false)
            u:deldata("犬夜叉-妖化抵挡")
            u:deldata("犬夜叉-妖化")
            ChangeValue(DamageSystem_Shjc, sy, -0.1)
            ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -300)
          end
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chat(args)
      end)
      local dskill = S2ID("A1IX")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          local ewl = getunit(args.unit)
          if 2000 <= dis then
            b = false
            u:sendmessage("|cFF7DBEF1距离超过2000|r")
          end
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            u:setface(angle)
            local txsh = 2500 + 500 * u:getlevel()
            local cs = 0
            ac.loop(200, function(timer)
              cs = cs + 1
              x, y = u:getxy()
              angle = AngleXY(x, y, x2, y2)
              unifycreate({
                owner = u.handle,
                model = "war3mapImported\\2.22.431.mdl",
                modelname = "剑气",
                modelsize = 3.25,
                height = 0,
                damage = 0,
                damagetype = 1,
                x = x,
                y = y,
                range = 2500,
                speed = 3000,
                volume = 140,
                angle = angle,
                angleoffset = 0,
                attenua = 1,
                attenuacount = 999,
                life = 10,
                isbullet = false,
                isvest = true,
                isignorearmor = false
              })
              if cs == 2 then
                if GetRandom100(60) then
                  cs = 0
                else
                  timer:remove()
                end
              end
            end)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
    end)
    PlayBGM({
      bgm = 0,
      time = 161,
      ID = 120,
      unit = u.handle
    })
    ac.wait(86000, function()
      PlayGlobalSound(BGM_Quanyecha_10)
    end)
  end,
  ["无元剑制"] = function(u, x2, y2)
    ShowUnit(u.handle, false)
    u:buffset(u.handle, 24, "暂停")
    u:buffset(u.handle, 25, "绝对闪避")
    FogEnable(false)
    FogMaskEnable(false)
    DayNightRun = false
    SetDayNightModels("Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdx", "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdx")
    u:setplayername("|cFFFF9900千|r|cFFFF7A00子|r|cFFFF5C00村|r|cFFFF3D00正|r")
    local x, y = u:getxy()
    local jd = AngleXY(x, y, x2, y2)
    local jl = 1200
    x2, y2 = PolarXY(x, y, 1200, jd)
    local mj = u:createunit("u0B0", x, y, jd)
    Effectcreate("AATX\\[AATxNew]Fire16.mdl", x, y)
    Movie_Boolean = true
    PlayBGM({
      bgm = 0,
      time = 100,
      ID = 32,
      unit = u.handle
    })
    ac.wait(24000, function()
      Movie_Boolean = false
      DayNightRun = true
    end)
    local dcs = 0
    local g = CreateGroupLua()
    ac.loop(1000, function(timer)
      dcs = dcs + 1
      for _, xq in ac.selector():in_rangexy(x, y, 2700):is_enemy(u.handle):isnotingroup(g):ipairs() do
        xq = getunit(xq)
        xq:groupadd(g)
        xq:buffset(u.handle, 2, "暂停")
      end
      if dcs == 16 then
        ForGroupLuaNew(g, function(xq)
          xq:animeact("death")
          ac.wait(1000, function()
            xq:animespeed(0)
          end)
        end)
      end
      if dcs == 19 then
        local dehp = 0.2
        local dam = 0.2
        for i = 1, 6 do
          local wp = u:getcountitem(i)
          if wp ~= 0 then
            local wptype = GetItemTypeId(wp)
            local prio = tonumber(slk.item[ID2S(wptype)].prio)
            local wphp = tonumber(slk.item[ID2S(wptype)].HP)
            if GetItemType(wp) == ITEM_TYPE_PURCHASABLE and (prio == 20 or 0 < prio and prio <= 11) then
              if wphp ~= 75 then
                if wptype == Weapons["都牟刈村正"] or wptype == Weapons["天殛之镜.裁决"] or wptype == Weapons["轩辕剑(封)"] or wptype == Weapons["神刀-丛雨丸"] or wptype == Weapons["九字兼定-境界"] or wptype == Weapons["压切长谷部"] then
                  dehp = dehp + 0.06
                  dam = dam + 0.06
                else
                  dehp = dehp + 0.1
                  dam = dam + 0.1
                  RemoveItemLua(wp)
                end
              else
                dehp = dehp + 0.03
                dam = dam + 0.03
                RemoveItemLua(wp)
              end
            end
          end
        end
        if 0.5 <= dehp then
          dehp = 0.5
        end
        ForGroupLuaNew(g, function(xq)
          xq:animespeed(1)
          xq:buffset(u.handle, 10, "暂停")
          if not xq:isboss() then
            xq:kill(u.handle, true)
          else
            xq:changemaxhp(-dehp * xq:getmaxhp())
            DamageUnit({
              bj = "无元剑制",
              unit = xq.handle,
              source = u.handle,
              damage = dam * xq:getmaxhp(),
              level = 5,
              type = "灵力",
              isvest = false,
              isattack = false,
              isnoarmor = false,
              element = "无",
              extradata = {""}
            })
          end
        end)
        timer:remove()
      end
    end)
    PlayGlobalSound(Sound_Senji_01)
    ac.wait(300, function()
      Effectcreate("AATX\\[AATxNew]Red19.mdl", x, y, 0, 2)
    end)
    ac.wait(600, function()
      mj:effectadd("AATX\\[AATxNew]Red41.mdl", "overhead")
    end)
    ac.wait(1000, function()
      mj:animeact(11)
      ac.wait(200, function()
        mj:animespeed(0)
      end)
      Effectcreate("ATX\\[ATxNew]Fire_07.mdl", x, y, 0, 2)
    end)
    ac.wait(1900, function()
      SendMsgAll("|cFFFF9900『|r|cFFFF8C00到|r|cFFFF8000达|r|cFFFF7300于|r|cFFFF6600此|r|cFFFF5900乃|r|cFFFF4C00无|r|cFFFF4000数|r|cFFFF3300钻|r|cFFFF2600研|r|cFFFF1A00』|r")
      for i = 1, 5 do
        Effectcreate("AATX\\[AATxNew]FireAC.mdl", x, y, 70.1, 3)
      end
      Effectcreate("ATX\\[ATxNew]Fire_03.mdl", x, y, 0, 1.5)
      Effectcreate("AATX\\[AATxNew]Fire28.mdl", x, y, 11.3, 5)
      local dx = 0
      ac.timer(400, 4, function()
        dx = dx + 1
        local dmj = u:createunit("u0B2", x, y)
        dmj:setsize(dx)
        dmj:timetoremove(70.1)
      end)
    end)
    ac.wait(3600, function()
      SetTerrainFogEx(0, 1000.0, 8000, 2.0, 1.0, 0.5, 0.1)
      Effectcreate("AATX\\[AATxNew]Fire25.mdl", x, y, 0, 5)
      Effectcreate("AATX\\[AATxNew]Fire25.mdl", x, y, 0, 5, 0, 90)
    end)
    ac.wait(4000, function()
      for i = 1, 20 do
        local a = GetRandomAngle()
        local djl = GetRandomReal(400, 1500)
        local xx, yy = PolarXY(x, y, jl, a)
        Effectcreate("AATX\\[AATxNew]FireAB.mdl", xx, yy, 3.4, GetRandomReal(1, 2), 0, GetRandomAngle())
        Effectcreate("AATX\\[AATxNew]Fire47.mdl", xx, yy, 3.4, GetRandomReal(1, 2), GetRandomReal(0, 90), GetRandomAngle())
        ac.wait(3400, function()
          Effectcreate("AATX\\[AATxNew]Fire30.mdl", xx, yy, 0, 3)
          local cs = GetRandomInt(20, 40)
          djl = djl / 2
          xx, yy = PolarXY(x, y, djl, a)
          local add = 180 / cs
          if GetRandom100(50) then
            add = add * -1
          end
          local tx2 = Effectcreate("AATX\\[AATxNew]Fire07.mdl", xx, yy, -1, 5)
          ac.loop(50, function(timer2)
            a = a + add
            cs = cs - 1
            local x3, y3 = PolarXY(xx, yy, djl, a)
            SetEffectXY(tx2, x3, y3)
            Effectcreate("AATX\\[AATxNew]Fire26.mdl", x3, y3)
            if cs == 0 then
              Effectcreate("AATX\\[AATxNew]Fire20.mdl", x3, y3)
              DestroyEffectLua(tx2)
              timer2:remove()
            end
          end)
        end)
      end
    end)
    ac.wait(4700, function()
      local a = jd
      local djl = 900
      for i = 1, 5 do
        a = a + 60
        local xx, yy = PolarXY(x, y, djl, a)
        Effectcreate("AATX\\[AATxNew]FireAA.mdl", xx, yy, 8, 3, 0, GetRandomAngle())
      end
    end)
    ac.wait(5400, function()
      SendMsgAll("|cFFFF9900『|r|cFFFF8300累|r|cFFFF6D00累|r|cFFFF5700刀|r|cFFFF4200冢|r|cFFFF2C00』|r")
    end)
    ac.wait(7400, function()
      mj:animespeed(1)
    end)
    ac.wait(8500, function()
      SendMsgAll("|cFFFF9900『|r|cFFFF8D00以|r|cFFFF8100因|r|cFFFF7600缘|r|cFFFF6A00将|r|cFFFF5E00宿|r|cFFFF5200业|r|cFFFF4700一|r|cFFFF3B00刀|r|cFFFF2F00两|r|cFFFF2300断|r|cFFFF1800』|r")
      Effectcreate("AATX\\[AATxNew]Yellow01.mdl", x, y, 0, 5, 150)
    end)
    ac.wait(9000, function()
      CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 1.0, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0)
    end)
    ac.wait(10000, function()
      CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 2.0, "war3mapImported\\Ph_Senji.blp", 100.0, 100.0, 100.0, 0)
    end)
    ac.wait(11200, function()
      SendMsgAll("|cFFFF9900『|r|cFFFF8F00建|r|cFFFF8500造|r|cFFFF7A00八|r|cFFFF7000重|r|cFFFF6600垣|r|cFFFF5C00的|r|cFFFF5200乃|r|cFFFF4700是|r|cFFFF3D00千|r|cFFFF3300子|r|cFFFF2900之|r|cFFFF1F00刃|r|cFFFF1400』|r")
    end)
    ac.wait(13200, function()
      mj:animeact(16)
      mj:animespeed(2)
      CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.0, "war3mapImported\\Ph_Senji.blp", 100.0, 100.0, 100.0, 0)
    end)
    ac.wait(13300, function()
      Effectcreate("AATX\\[AATxNew]Katana57.mdl", x, y, 0, 3, 0, jd)
    end)
    ac.wait(13400, function()
      Effectcreate("AATX\\[AATxNew]Katana33.mdl", x2, y2, 0, 5, 0, jd)
      Effectcreate("AATX\\[AATxNew]Katana61.mdl", x2, y2, 0, 2)
      Effectcreate("AATX\\[AATxNew]Katana62", x2, y2, 0, 2)
    end)
    ac.wait(14700, function()
      u:chat("你给我——")
      local xx = x
      local yy = y
      local a = jd
      for i = 1, 10 do
        xx, yy = PolarXY(xx, yy, 250, a)
        Effectcreate("AATX\\[AATxNew]Katana62", xx, yy, 0, GetRandomReal(3, 5))
        local tx = Effectcreate("ATX\\[ATxNew]ShockBoom_26.mdl", xx, yy, -1, 2, 0, GetRandomAngle(), 0, 0, 0.1)
        ac.wait(1300, function()
          SetEffectActSpeed(tx, 1)
          DestroyEffectLua(tx)
        end)
      end
    end)
    ac.wait(15400, function()
      u:chat("成佛去吧！！！")
    end)
    ac.wait(16000, function()
      local xx = x
      local yy = y
      local a = jd
      for i = 1, 6 do
        xx, yy = PolarXY(xx, yy, 400, a)
        Effectcreate("AATX\\[AATxNew]Fire19.mdl", xx, yy, 5, 2)
      end
      Effectcreate("AATX\\[AATxNew]Fire07.mdl", x2, y2, 0, 5)
      Effectcreate("AATX\\[AATxNew]Fire19.mdl", x2, y2, 0, 10)
      local dmj = u:createunit("u0B3", x2, y2, jd)
      dmj:timetoremove(5)
      ac.timer(200, 10, function()
        Effectcreate("AATX\\[AATxNew]ShockBoom24.mdl", xx, yy, 1, 5)
      end)
    end)
    ac.wait(18000, function()
      CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 2.0, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 100.0, 100.0, 0)
    end)
    ac.wait(19400, function()
      ResetTerrainFog()
      PlayGlobalSound(Sound_Senji_02)
    end)
    ac.wait(21000, function()
      CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 2.0, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 100.0, 100.0, 0)
    end)
    ac.wait(24000, function()
      mj:remove()
      ShowUnit(u.handle, true)
      u:select()
      Effectcreate("AATX\\[AATxNew]Fire16.mdl", x, y, 0, 2)
      FogEnable(true)
      FogMaskEnable(true)
    end)
  end,
  ["23夜杀"] = function(u, tg)
    ShowUnit(u.handle, false)
    musiccolortext({
      strz = {
        {
          str = "ありのままで生きて行けたらいいよね",
          time = 0,
          staytime = 7,
          fadetime = 10,
          showtexttime = 3,
          dx = 50
        },
        {
          str = "大事な時もう一人の私が邪魔をするの",
          time = 7.5,
          staytime = 7,
          fadetime = 10,
          showtexttime = 4.5,
          dx = 50
        },
        {
          str = "So Goodbye Happiness",
          time = 16,
          staytime = 7,
          fadetime = 10,
          showtexttime = 1.6,
          dx = 50
        },
        {
          str = "何も知らずにはしゃいでた",
          time = 19.6,
          staytime = 7,
          fadetime = 10,
          showtexttime = 1.8,
          dx = 50
        },
        {
          str = "あの頃へ戻りたいね Baby",
          time = 23.4,
          staytime = 7,
          fadetime = 10,
          showtexttime = 4,
          dx = 50
        },
        {
          str = "そしてもう一度 Kiss me ",
          time = 29.2,
          staytime = 7,
          fadetime = 10,
          showtexttime = 3,
          dx = 50
        }
      },
      colorstart = "00FFFFFF",
      colorend = "FF5263FF"
    })
    local cd = 0
    local x, y = u:getxy()
    local x2, y2 = tg:getxy()
    local ang = AngleXY(x, y, x2, y2)
    local jl = -50
    x, y = PolarXY(x2, y2, ang, jl)
    local mj = u:createunit("u0BB", x, y, ang)
    Effectcreate("war3mapImported\\d95aed2944e02a85.mdl", x, y)
    DayNightRun = false
    SetDayNightModels("Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdx", "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdx")
    PlayBGM({
      bgm = 0,
      time = 45,
      ID = 124,
      unit = u.handle
    })
    u:buffset(u.handle, 14, "暂停")
    u:buffset(u.handle, 15, "绝对闪避")
    local g = CreateGroupLua()
    for _, xq in ac.selector():in_rangexy(x2, y2, 200):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      xq:groupadd(g)
    end
    Movie_Boolean = true
    ForGroupLuaNew(g, function(xq)
      xq:buffset(xq.handle, 15, "暂停")
      xq:buffset(xq.handle, 15, "沉默")
      xq:buffset(xq.handle, 15, "锁定")
    end)
    local time = -170
    mj:animeact(17)
    local mj2 = u:createunit("u0DM", x, y, ang + 180)
    mj2:setcolor(255, 255, 255, 0)
    local ang2 = ang + 180
    local j = 0
    local angDD = 0
    local d = 0
    ac.loop(10, function(timer)
      time = time + 1
      if time == -168 then
        PlayGlobalSound(Shiki_3_1)
      end
      if time == -68 then
        ASound("war3mapImported\\23YS_Hit5.wav")
        mj:animeact(24)
        PlayGlobalSound(BGM_23YS)
      end
      if time == -58 then
        ForGroupLuaNew(g, function(xq)
          xq:effectadd("war3mapImported\\QQQQQ.mdx", "chest")
          xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
          if xq:isboss() then
            LossHpUnit({
              u = u,
              tg = xq,
              damage = 0,
              perhp = 0.5,
              maxhp = 0,
              bj = "[生命损耗]二十三夜杀"
            })
          else
            xq:losshp(u, 0, 0, 1)
          end
        end)
        mj:animeact(24)
        ASound("war3mapImported\\Shiki_26-0.wav")
        unitjump({
          unit = mj.handle,
          time = 0.4,
          distance = 200,
          height = 50,
          angle = ang2,
          isfly = true
        })
        Effectcreate("war3mapImported\\dd75fb129289fac0.mdl", x2, y2, 12, 1.5, 5)
        Effectcreate("war3mapImported\\dd75fb129289fac0.mdl", x2, y2, 12, 1.5, 5, 60)
      end
      if time == -8 then
        ASound("war3mapImported\\23YS11_G.wav")
        local x, y = PolarXY(x2, y2, 250, ang)
        mj2:setxy(x, y)
        Effectcreate("war3mapImported\\d95aed2944e02a85.mdl", x, y)
      end
      if time == 40 then
        mj:animeact(18)
        mj2:animeact(17)
        unitmove({
          unit = mj.handle,
          time = 0.3,
          distance = 120,
          angle = ang2,
          isfly = true
        })
        unitmove({
          unit = mj2.handle,
          time = 0.3,
          distance = 120,
          angle = ang,
          isfly = true
        })
        local tm = 100
        ac.timer(30, 10, function()
          tm = tm - 10
          mj:setcolor(255, 255, 255, tm * 2.55)
          mj2:setcolor(255, 255, 255, tm * 2.55)
        end)
      end
      if time == 90 then
        ASound("war3mapImported\\23YS12_G.wav")
      end
      if 90 <= time and time <= 160 then
        cd = cd + 0.01
        if 0.2 <= cd then
          cd = 0
          if 11 < d then
            d = 0
          end
          mj:setcolor(255, 255, 255, 255)
          mj2:setcolor(255, 255, 255, 255)
          ac.wait(100, function()
            for i = 1, 2 do
              local m = u:createunit("e004", x2, y2, ang)
              m:setsize(GetRandomReal(0.3, 0.75), 1, 1)
              if GetRandomInt(1, 2) == 1 then
                m:animeact(math.floor(GetRandomReal(0, 60) * 0.69))
              else
                m:animeact(math.floor(GetRandomReal(300, 359) * 0.69))
              end
              m:setflyheight(GetRandomReal(20, 150))
              m:effectadd("war3mapImported\\coarse slash blue.mdx")
              UnitApplyTimedLife(m.handle, S2ID("BHwe"), 0.1)
            end
            if GetRandom100(50) then
              CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.12, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 100.0, 100.0, 0)
              DisplayCineFilter(false)
              if tg:isbeseenlocal() then
                DisplayCineFilter(true)
              end
            end
            ASound("war3mapImported\\blade_hit.wav")
            ASound("war3mapImported\\SE05.wav")
            ForGroupLuaNew(g, function(xq)
              xq:effectadd("war3mapImported\\QQQQQ.mdx", "chest")
              xq:animeact("stand hit")
              if xq:isboss() then
                LossHpUnit({
                  u = u,
                  tg = xq,
                  damage = 0,
                  perhp = 0.5,
                  maxhp = 0,
                  bj = "[生命损耗]二十三夜杀"
                })
              else
                xq:losshp(u, 0, 0, 1)
              end
            end)
            mj:setcolor(255, 255, 255, 0)
            mj2:setcolor(255, 255, 255, 0)
          end)
          j = j + 1
          local angle
          if j == 1 then
            angle = ang
          else
            j = 0
            angle = ang + 180
          end
          local dx, dy = PolarXY(x2, y2, -150, angle)
          mj2:setxy(dx, dy)
          dx, dy = PolarXY(x2, y2, 150, angle)
          mj:setxy(dx, dy)
          mj2:animeact(Shiki_Animation[d])
          mj:animeact(Shiki_Animation[d + 20])
          d = d + 1
        end
      end
      if time == 190 then
        cd = 0
        mj:animeact(0)
        mj2:animeact(6)
        mj:setcolor(255, 255, 255, 255)
        mj2:setcolor(255, 255, 255, 255)
        local dx, dy = PolarXY(x2, y2, 150, ang)
        mj:setxy(dx, dy)
        mj:setface(ang + 180)
        Effectcreate("war3mapImported\\ShikinDG.mdx", x2, y2, 1.7, 1, 10, ang + 180)
        dx, dy = PolarXY(x2, y2, -150, ang)
        mj2:setxy(dx, dy)
        mj2:setface(ang)
        Effectcreate("war3mapImported\\ShikinDG.mdx", x2, y2, 1.7, 1, 10, ang)
      end
      if 190 <= time and time <= 360 then
        cd = cd + 0.01
        if 0.1 <= cd then
          cd = 0
          ASound("war3mapImported\\ZJ-01.mp3")
          ASound("war3mapImported\\23YS_Hit2.wav")
          ForGroupLuaNew(g, function(xq)
            xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
            xq:animeact("stand hit")
            if xq:isboss() then
              LossHpUnit({
                u = u,
                tg = xq,
                damage = 0,
                perhp = 0.5,
                maxhp = 0,
                bj = "[生命损耗]二十三夜杀"
              })
            else
              xq:losshp(u, 0, 0, 1)
            end
          end)
        end
      end
      if time == 362 then
        mj2:animespeed(10)
        cd = 0
        local dx, dy = PolarXY(x2, y2, -300, ang)
        mj2:setxy(dx, dy)
        mj2:setface(ang)
        dx, dy = PolarXY(x2, y2, 300, ang)
        mj:setxy(dx, dy)
        mj:setface(ang + 180)
      end
      if 364 < time and time <= 650 then
        cd = cd + 0.01
        if 0.1 <= cd then
          cd = 0
          if 11 < d then
            d = 0
          end
          mj:setcolor(255, 255, 255, 255)
          mj2:setcolor(255, 255, 255, 255)
          ASound("war3mapImported\\23YS_Hit1.wav")
          ASound("war3mapImported\\23YS_Hit3.wav")
          mj2:animeact(Shiki_Animation[d])
          mj:animeact(Shiki_Animation[d + 20])
          ac.wait(50, function()
            for i = 1, 4 do
              local m = u:createunit("e004", x2, y2, ang2)
              m:setsize(GetRandomReal(0.5, 1.5), 1, 1)
              if GetRandomInt(1, 2) == 1 then
                m:animeact(math.floor(GetRandomReal(0, 30) * 0.69))
                m:effectadd("war3mapImported\\QY23YS_FDFireFx1.mdx", "origin")
              else
                m:animeact(math.floor(GetRandomReal(330, 359) * 0.69))
                m:effectadd("war3mapImported\\QY23YS_FDFireFx.mdx", "origin")
              end
              m:setflyheight(GetRandomReal(20, 150))
              UnitApplyTimedLife(m.handle, S2ID("BHwe"), 0.1)
            end
            CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.12, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 100.0, 100.0, 0)
            DisplayCineFilter(false)
            if tg:isbeseenlocal() then
              DisplayCineFilter(true)
            end
            ASound("war3mapImported\\ZJ-01.mp3")
            ASound("war3mapImported\\23YS_Hit4.wav")
            ForGroupLuaNew(g, function(xq)
              xq:effectadd("war3mapImported\\QQQQQR.mdx", "chest")
              xq:animeact("stand hit")
              if xq:isboss() then
                LossHpUnit({
                  u = u,
                  tg = xq,
                  damage = 0,
                  perhp = 0.5,
                  maxhp = 0,
                  bj = "[生命损耗]二十三夜杀"
                })
              else
                xq:losshp(u, 0, 0, 1)
              end
            end)
            mj:setcolor(255, 255, 255, 0)
            mj2:setcolor(255, 255, 255, 0)
          end)
          d = d + 1
        end
      end
      if time == 656 then
        mj:setcolor(255, 255, 255, 255)
        mj2:setcolor(255, 255, 255, 255)
        mj:animespeed(1)
        mj2:animespeed(1)
        ForGroupLuaNew(g, function(xq)
          xq:animespeed(3)
        end)
        local dx, dy = PolarXY(x2, y2, 250, ang)
        mj2:setxy(dx, dy)
        mj2:setface(ang2)
        dx, dy = PolarXY(x2, y2, -250, ang)
        mj:setxy(dx, dy)
        mj:setface(ang)
        mj:animeact(10)
        mj2:animeact(10)
        cd = 0
      end
      if time == 660 then
        unitmove({
          unit = mj.handle,
          time = 0.3,
          distance = 400,
          angle = ang,
          isfly = true
        })
        unitmove({
          unit = mj2.handle,
          time = 0.3,
          distance = 400,
          angle = ang2,
          isfly = true
        })
      end
      if time == 666 then
        ASound("war3mapImported\\Shiki_36-0.mp3")
        mj:setcolor(255, 255, 255, 0)
        mj2:setcolor(255, 255, 255, 0)
      end
      if 670 <= time and time <= 990 then
        cd = cd + 0.01
        if 0.08 <= cd then
          cd = 0
          angDD = angDD + GetRandomReal(-45, 45)
          local zz = 100 + GetRandomReal(-50, 50)
          local xx = x2 + GetRandomReal(-100, 100)
          local yy = y2 + GetRandomReal(-100, 100)
          local vv = 1 + GetRandomReal(-0.8, 0)
          local m = u:createunit("e005", xx, yy, angDD)
          m:setsize(vv, 1, 1)
          m:animeact(math.floor(GetRandomReal(35, 90) * 0.69))
          SetUnitBlendTime(m.handle, 0.0)
          m:setflyheight(GetRandomReal(20, 150))
          m:effectadd("war3mapImported\\23_fastSlash_Blue.mdx")
          UnitApplyTimedLife(m.handle, S2ID("BHwe"), 0.3)
          m:setflyheight(zz)
          angDD = angDD + GetRandomReal(-45, 45)
          local zz = 100 + GetRandomReal(-50, 50)
          local xx = x2 + GetRandomReal(-100, 100)
          local yy = y2 + GetRandomReal(-100, 100)
          local vv = 1 + GetRandomReal(-0.8, 0)
          local m = u:createunit("e005", xx, yy, angDD)
          m:setsize(vv, 1, 1)
          m:animeact(math.floor(GetRandomReal(35, 90) * 0.69))
          SetUnitBlendTime(m.handle, 0.0)
          m:setflyheight(GetRandomReal(20, 150))
          m:effectadd("war3mapImported\\23_fastSlash_Red.mdx")
          UnitApplyTimedLife(m.handle, S2ID("BHwe"), 0.3)
          m:setflyheight(zz)
          for i = 1, 3 do
            local m = u:createunit("e004", x2, y2, ang2)
            m:setsize(GetRandomReal(0.3, 0.75), 1, 1)
            if GetRandomInt(1, 2) == 1 then
              m:animeact(math.floor(GetRandomReal(0, 60) * 0.69))
            else
              m:animeact(math.floor(GetRandomReal(300, 359) * 0.69))
            end
            m:setflyheight(GetUnitFlyHeight(m.handle) + GetRandomReal(20, 150))
            m:effectadd("war3mapImported\\coarse slash blue.mdx")
            m:setcolor(255, 100, 100)
            UnitApplyTimedLife(m.handle, S2ID("BHwe"), 0.1)
          end
          if GetRandom100(50) then
            CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.06, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 100.0, 100.0, 0)
            DisplayCineFilter(false)
            if tg:isbeseenlocal() then
              DisplayCineFilter(true)
            end
          end
          ASound("war3mapImported\\ZJ-01.mp3")
          ASound("war3mapImported\\23YS_Hit2.wav")
          ASound("war3mapImported\\23YS_Hit4.wav")
          ForGroupLuaNew(g, function(xq)
            xq:effectadd("war3mapImported\\splash.mdx", "chest")
            xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
            xq:animeact("stand hit")
            xq:setflyheight(GetUnitFlyHeight(xq.handle) + 3)
            if xq:isboss() then
              LossHpUnit({
                u = u,
                tg = xq,
                damage = 0,
                perhp = 0.5,
                maxhp = 0,
                bj = "[生命损耗]二十三夜杀"
              })
            else
              xq:losshp(u, 0, 0, 1)
            end
          end)
        end
      end
      if 960 <= time then
      end
      if time == 1010 then
        ASound("war3mapImported\\Nanaya_23ye2.mp3")
        ASound("war3mapImported\\SE03.wav")
        mj:setcolor(255, 255, 255, 255)
        mj2:setcolor(255, 255, 255, 255)
        ForGroupLuaNew(g, function(xq)
          xq:animespeed(1)
          xq:animeact("death")
          xq:setflyheight(0)
          if xq:isboss() then
            LossHpUnit({
              u = u,
              tg = xq,
              damage = 0,
              perhp = 23,
              maxhp = 0,
              bj = "[生命损耗]二十三夜杀"
            })
            DamageUnit({
              bj = "二十三夜杀",
              unit = xq.handle,
              source = u.handle,
              damage = 0.23 * xq:getmaxhp(),
              level = 5,
              type = "物理",
              isvest = false,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
          elseif xq:iselite() then
            DamageUnit({
              bj = "二十三夜杀",
              unit = xq.handle,
              source = u.handle,
              damage = 1 * xq:getmaxhp(),
              level = 5,
              type = "物理",
              isvest = false,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
          else
            xq:kill(u.handle, true)
          end
        end)
        local m = u:createunit("e004", x2, y2, ang)
        m:setsize(1.3, 1, 1)
        m:animeact(0)
        SetUnitBlendTime(m.handle, 0.0)
        m:setflyheight(GetUnitFlyHeight(tg.handle) + 110)
        Effectcreate("war3mapImported\\baojiang.mdx", x2, y2)
        m:effectadd("war3mapImported\\bloodex-special-3.mdx", "origin")
        UnitApplyTimedLife(m.handle, S2ID("BHwe"), 1)
        local m = u:createunit("e004", x2, y2, ang)
        m:setsize(1.5, 1, 1)
        m:animeact(0)
        SetUnitBlendTime(m.handle, 0.0)
        m:setflyheight(GetUnitFlyHeight(tg.handle) + 80)
        m:effectadd("war3mapImported\\coarse slash blue.mdx", "origin")
        UnitApplyTimedLife(m.handle, S2ID("BHwe"), 1.5)
        local m = u:createunit("e004", x2, y2, ang)
        m:setsize(3.75, 1, 1)
        m:animeact(0)
        SetUnitBlendTime(m.handle, 0.0)
        m:setflyheight(GetUnitFlyHeight(tg.handle) + 80)
        m:effectadd("war3mapImported\\coarse slash blue.mdx", "origin")
        m:effectadd("war3mapImported\\arcdirve02b.mdx", "origin", 1.5)
        m:effectadd("war3mapImported\\QQQQQR.mdx", "origin", 1.5)
        UnitApplyTimedLife(m.handle, S2ID("BHwe"), 1.5)
        CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 2.0, "ReplaceableTextures\\CameraMasks\\DreamFilter_Mask.blp", 100.0, 0.0, 0.0, 0)
        DisplayCineFilter(false)
        if tg:isbeseenlocal() then
          DisplayCineFilter(true)
        end
        Effectcreate("war3mapImported\\970fee14296a3286.mdl", x2, y2, 25, 1.5)
        local nn = 0
        local angle = ang
        local bz = 0
        ac.loop(80, function(timer2)
          if nn < 5 then
          else
            timer2:remove()
          end
          local tempreal = 20 + 5 * nn
          local r = nn * 100
          for i = 1, 2 do
            angle = angle + 180
            for i = 1, 10 do
              local dx, dy = PolarXY(x2, y2, r, angle)
              local m = u:createunit("e004", x2, y2, ang)
              m:setsize(2, 1, 1)
              m:animeact(R2I(0.695 * (90 - tempreal)))
              SetUnitBlendTime(m.handle, 0.0)
              m:setflyheight(GetUnitFlyHeight(tg.handle) + 150)
              m:effectadd("war3mapImported\\zhanji-blueX-shu.mdx", "origin")
              m:effectadd("war3mapImported\\zhanji-blueX-shu2.mdx", "origin")
              UnitApplyTimedLife(m.handle, S2ID("BHwe"), 0.3)
              local m = u:createunit("e004", x2, y2, ang)
              m:setsize(2, 1, 1)
              m:animeact(R2I(0.695 * (90 + tempreal)))
              SetUnitBlendTime(m.handle, 0.0)
              m:setflyheight(GetUnitFlyHeight(tg.handle) + 150)
              m:effectadd("war3mapImported\\zhanji-blueX-shu.mdx", "origin")
              m:effectadd("war3mapImported\\zhanji-blueX-shu2.mdx", "origin")
              UnitApplyTimedLife(m.handle, S2ID("BHwe"), 0.3)
            end
            nn = nn + 1
          end
        end)
        mj2:animeact(22)
        mj:animeact(1)
      end
      if time == 1300 then
        ShowUnit(u.handle, true)
        u:select()
        x, y = mj:getxy()
        u:setxy(x, y)
        Effectcreate("war3mapImported\\d95aed2944e02a85.mdl", x, y)
        mj:remove()
        mj2:remove()
        Movie_Boolean = false
        DayNightRun = true
        timer:remove()
      end
    end)
  end,
  ["不死斩"] = function(u, tg)
    u:buffset(u.handle, 18, "暂停")
    u:buffset(u.handle, 20, "绝对闪避")
    tg:buffset(tg.handle, 18, "暂停")
    tg:buffset(u.handle, 18, "沉默")
    tg:buffset(tg.handle, 11, "无敌")
    PlayBGM({
      bgm = 0,
      time = 18,
      ID = 0
    })
    local x, y = u:getxy()
    local x2, y2 = tg:getxy()
    local angle = AngleXY(x, y, x2, y2)
    tg:animespeed(0)
    ac.wait(2500, function()
      CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 1.0, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0.0, 0.0, 0)
    end)
    ac.wait(3000, function()
      PlayGlobalSound(Zhilang_Busizhan)
      ac.wait(500, function()
        u:setxy(x2, y2)
        u:setface(angle)
        CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 1.0, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0.0, 0.0, 0)
        ac.wait(500, function()
          tg:effectadd("war3mapImported\\Texiao_Xuebao.mdx", "chest")
        end)
      end)
      ac.wait(1500, function()
        CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 1.0, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0.0, 0.0, 0)
        ac.wait(500, function()
          local dx, dy = PolarXY(x, y, 400, angle)
          u:setxy(dx, dy)
          u:setface(AngleBetweenUnits(u.handle, tg.handle))
        end)
      end)
      ac.wait(3000, function()
        tg:animespeed(1)
        x2, y2 = tg:getxy()
        local jd = u:getface()
        CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.5, "ReplaceableTextures\\CameraMasks\\DreamFilter_Mask.blp", 0.0, 0.0, 0.0, 0)
        Effectcreate("war3mapImported\\176.mdl", x2, y2, 8, 1.5, 100, jd + 110)
        ac.wait(500, function()
          CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.5, "ReplaceableTextures\\CameraMasks\\DreamFilter_Mask.blp", 0.0, 0.0, 0.0, 0)
          Effectcreate("war3mapImported\\176.mdl", x2, y2, 8, 1.5, 100, jd + 80)
        end)
      end)
    end)
    ac.wait(11220, function()
      tg:animeact("death")
      tg:kill(u.handle, true)
      ac.wait(300, function()
        PlayGlobalSound(Zhilang_Busizhan_Pojie)
      end)
      flashphoto({
        photo = "war3mapImported\\Busizhan1.blp",
        timeout = 2,
        timehold = 3,
        timein = 2
      })
      if u:ishasitem("I03J") then
        local wp = u:getitem("I03J")
        ChangeItemCount(wp, 1000)
        if GetItemCharges(wp) >= 999 then
          SendMsgAll("|cFFCC0000吾无从得知|r")
          ac.wait(3000, function()
            SendMsgAll("|cFFCC0000杀戮的尽头，真的存在么|r")
          end)
          u:dropitem(wp)
          RemoveItemLua(wp)
          u:additem("I03K")
        end
      end
    end)
  end,
  ["霜星"] = function(u)
    local sy = u.ownerid
    u:setdata("霜星-彩蛋触发")
    Movie_Boolean = true
    PlayBGM({
      bgm = 0,
      time = 245,
      ID = 172,
      unit = u.handle
    })
    PlayGlobalSound(BGM_Shuangxing_01)
    ac.wait(3000, function()
      PlayGlobalSound(Sound_Shuangxing_01)
      u:chat("|cFFCCFFFF『|r|cFFBBEEFF不|r|cFFAADDFF要|r|cFF99CCFF紧|r|cFF88BBFF张|r|cFF77AAFF…|r|cFF6699FF…|r|cFF5588FF』|r")
      ac.wait(1300, function()
        u:chat("|cFFCCFFFF『|r|cFFC0F3FF我|r|cFFB4E7FF会|r|cFFA9DCFF让|r|cFF9DD0FF各|r|cFF91C4FF位|r|cFF85B8FF毫|r|cFF7AADFF无|r|cFF6EA1FF痛|r|cFF6295FF苦|r|cFF5689FF地|r|cFF4B7EFF』|r")
      end)
      ac.wait(3700, function()
        u:chat("|cFFCCFFFF『|r|cFFBDF0FF迎|r|cFFADE0FF接|r|cFF9ED1FF自|r|cFF8FC2FF己|r|cFF7FB2FF的|r|cFF70A3FF死|r|cFF6194FF亡|r|cFF5285FF』|r")
      end)
    end)
    ac.wait(10000, function()
      Movie_Boolean = false
      u:sendmessage("|cFF990000你的生命进入倒计时……倒计时:230秒|r")
      SendMsgAll("|cFF999999大|r|cFF97999C地|r|cFF9699A0的|r|cFF9499A3凛|r|cFF9299A6冽|r|cFF9199A9已|r|cFF8F99AD经|r|cFF8D99B0有|r|cFF8C99B3所|r|cFF8A99B7觉|r|cFF8999BA悟|r|cFF8799BD，|r" .. u:getplayername() .. "|cFF8599C0为|r|cFF8499C4了|r|cFF8299C7最|r|cFF8099CA后|r|cFF7F99CE的|r|cFF7D99D1战|r|cFF7B99D4斗|r|cFF7A99D8解|r|cFF7899DB放|r|cFF7699DE了|r|cFF7599E1所|r|cFF7399E5剩|r|cFF7299E8无|r|cFF7099EB几|r|cFF6E99EF的|r|cFF6D99F2生|r|cFF6B99F5命|r|cFF6999F8。|r")
    end)
    ac.wait(60000, function()
      PlayGlobalSound(BGM_Shuangxing_02)
    end)
    ac.wait(240000, function()
      if not u:hasdata("霜星-结束") then
        u:setdata("霜星-结束")
        u:shanmo()
        SendMsgAll(u:getplayername() .. "|cFF6699FF随风飘逝了……|r")
      end
    end)
    flashphoto({
      photo = "Ph_Shuangxing_01.tga",
      timeout = 3,
      timehold = 4,
      timein = 3
    })
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:buffset(u.handle, 12, "绝对闪避")
    end)
    local g = u:getdata("霜星-冰晶特效组")
    local cs = 0
    for i = 1, 3 do
      u:changedata("霜星-冰晶数量", 1)
      local x, y = u:getxy()
      local tx = Effectcreate("Shuang_02.mdx", x, y, -1)
      g[#g + 1] = tx
    end
    ac.loop(1000, function(timer)
      u:clearbuff()
      u:clearbuff("僵直")
      u:clearbuff("眩晕")
      u:clearbuff("缠绕")
      u:clearbuff("混乱")
      u:addrandomdamage(3)
      u:changedata("全属性增幅", 0.0025)
      u:changemaxhp(-0.01 * u:getmaxhp())
      if u:hasdata("霜星-结束") then
        timer:remove()
      end
    end)
    u:addstexiao("霜星彩蛋", "直接伤害变更", function(args)
      local info = args.damageinfo
      info.level = 5
      info.element = "冰"
    end)
    AddAllSTexiao("霜星彩蛋", "伤害系统计算效果", function(args)
      local info = args.damageinfo
      if args.tg:ishasbuff("B0EV") then
        info.ewss = info.ewss + 0.25
      end
    end)
    u:delskill("S0AQ")
    u:addskill("S0AS")
    u:uivar_change({
      keyname = "霜星",
      keytype = "传奇栏",
      text = "|cFFDDDDDD霜|r|cFFA6A6A6星,|r|cFF6699FF\"冬|r|cFFCCFFFF痕\"|r\n|cFFDDDDDDFrostNova|r\n|cFFCCFFFF提升100%冰属性伤害|r\n|cFFADE0FF提升250%法术修正|r\n|cFF8FC2FF直接伤害造成冰属性抹除伤害|r\n|cFF70A3FF直接伤害时附带[1000*等级*源石]冰魔力伤害与1秒冰冻，触发冷却0.25秒|r\n|cFFDDDDDD破碎中的维生晶体|r\n|cFFCCFFFF免疫大部分负面状态|r\n|cFFADE0FF免疫矿石病|r\n|cFF8FC2FF每秒提升0.25%全属性与3%伤害修正|r\n|cFF70A3FF每秒降低1%最大生命上限|r\n|cFFDDDDDD\"寒灾\"|r\n|cFFCCFFFF减速1000范围50%速度,降低25%冰属性抗性并提升25%额外受伤|r\n|cFFADE0FF直接伤害时冻结1秒并附带[1000*等级*源石]冰魔力伤害,独立冷却3秒|r\n|cFF8FC2FF生成6枚冰晶环绕自身,攻击间隔0.5秒|r",
      icon = "Ewl_Shuangxing_03",
      isclearclick = true
    })
  end,
  ["爱国者"] = function(u)
    local sy = u.ownerid
    Movie_Boolean = true
    PlayBGM({
      bgm = 0,
      time = 275,
      ID = 171,
      unit = u.handle
    })
    PlayGlobalSound(BGM_Aiguozhe_01)
    u:setplayername("|cFF990000爱|r|cFF992626国|r|cFF994C4C者|r")
    u:chat("|cFF666666已经，够了。|r")
    DayNightRun = false
    SetDayNightModels("Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdx", "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdx")
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:buffset(u.handle, 12, "绝对闪避")
      xq:buffset(u.handle, 12, "暂停")
    end)
    ac.wait(1, function()
      local cs = 0
      local cs2 = 0
      local tm = 0
      ac.loop(60, function(timer)
        cs = cs + 1
        if cs == 11 then
          cs = 1
        end
        local str = "Ph_Dalaodie (" .. cs .. ").tga"
        if tm ~= 100 then
          tm = tm + 0.5
        end
        CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 0, str, tm, tm, tm, 0.0)
        cs2 = cs2 + 1
        if cs2 == 180 then
          CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 3, str, 100.0, 100.0, 100.0, 0.0)
          timer:remove()
        end
      end)
    end)
    ac.wait(4000, function()
      u:chat("|cFF666666好结局，从不理所应当。|r")
    end)
    ac.wait(8000, function()
      u:chat("|cFF666666孩子，才相信童谣。|r")
    end)
    ac.wait(12000, function()
      DayNightRun = true
      Movie_Boolean = false
      SendMsgAll(u:getplayername() .. "|cFF990000的矿石病彻底爆发了，生命进入了最后的倒计时……|r")
    end)
    ac.wait(15000, function()
      PlayGlobalSound(BGM_Aiguozhe_02)
    end)
    ac.wait(255000, function()
      u:shanmo(15)
      local color = 255
      ac.timer(30, 500, function()
        color = color - 0.5
        u:setcolor(color, color, color, color)
      end)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:buffset(u.handle, 12, "绝对闪避")
        xq:buffset(u.handle, 12, "暂停")
      end)
      local b = false
      ForGroupLuaNew(Group_AllHero, function(xq)
        if xq:hasdata("变异判定-霜星") then
          b = true
        end
      end)
      if b then
        local mj = getunit(BOSS_DEATH)
        mj:setplayername("|cFFDDDDDD女|r|cFFA6A6A6儿|r")
        mj:chat("爸爸，爸爸！长大以后，长大以后……我一定给你做一种让你不会被冻坏的药！")
        ac.wait(3000, function()
          mj:chat("这样你就不会再被疼哭了，对吗？")
        end)
        ac.wait(6000, function()
          mj:chat("只要永远和爸爸，还有兄弟姐妹们在一起……一直在一起就好了……")
        end)
        ac.wait(9000, function()
          u:chat("……")
        end)
        ac.wait(12000, function()
          u:chat("我的女儿……")
        end)
        ac.wait(15000, function()
          u:chat("父亲，什么，都没能，为你做到。")
        end)
        flashphoto({
          photo = "Ph_Aiguozhe_02.tga",
          timeout = 4,
          timehold = 4,
          timein = 4
        })
      else
        flashphoto({
          photo = "Ph_Aiguozhe_01.tga",
          timeout = 4,
          timehold = 4,
          timein = 4
        })
        SendMsgAll("|cFF990000『|r|cFF980303一|r|cFF960505步|r|cFF950808也|r|cFF940A0A不|r|cFF930D0D曾|r|cFF910F0F后|r|cFF901212退|r|cFF8F1414。|r|cFF8E1717一|r|cFF8C1A1A秒|r|cFF8B1C1C也|r|cFF8A1F1F没|r|cFF882121有|r|cFF872424放|r|cFF862626弃|r|cFF852929。|r|cFF832B2B』|r")
        ac.wait(5000, function()
          SendMsgAll("|cFF822E2E『|r|cFF813030即|r|cFF7F3333使|r|cFF7E3636如|r|cFF7D3838此|r|cFF7C3B3B，|r|cFF7A3D3D死|r|cFF794040亡|r|cFF784242还|r|cFF774545是|r|cFF754747停|r|cFF744A4A下|r|cFF734C4C了|r|cFF714F4F一|r|cFF705252生|r|cFF6F5454的|r|cFF6E5757行|r|cFF6C5959军|r|cFF6B5C5C…|r|cFF6A5E5E…|r|cFF696161』|r")
        end)
      end
    end)
    if u:hasdata("爱国者-行军形态") then
      u:setdata("爱国者-毁灭形态")
      ChangeValue(DamageSplit_CountJzMax, sy, 0.5)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
    else
      u:setdata("爱国者-行军形态")
      ChangeValue(DamageSplit_CountJzMax, sy, 0.25)
      ChangeValue(DamageSplit_CountJzHit, sy, 3)
    end
    u:uivar_change({
      keyname = "爱国者",
      keytype = "传奇栏",
      text = "|cFF990000最|r|cFF920F0F后|r|cFF8A1D1D的温|r|cFF754949迪戈|r\n|cFF990000被信赖的人，|r|cFF930D0D背弃了诺言。|r\n\n|cFF8C1A1A背弃诺言的人，|r|cFF862626依然活着。|r\n\n|cFF803333即使如此，|r|cFF794040诺言，|r|cFF734C4C依然还在。|r\n\n|cFF949596我的女儿……父亲，什么，都没能，为你做到。|r",
      icon = "Ewl_Aiguozhe_03",
      isclearclick = true
    })
  end,
  ["噩梦の羁绊"] = function(u, tg)
    local x, y = u:getxy()
    local angle = u:getface()
    local mj = u:createunit("u09C", x, y, angle)
    local tg = getunit(BOSS)
    local qy = u
    ForGroupLuaNew(Group_AllHero, function(xq)
      if xq:hasdata("变异判定-七夜志贵") then
        qy = xq
      end
    end)
    local x2, y2 = tg:getxy()
    qy:setplayername("|cFF3366FF七|r|cFF4770EB夜|r|cFF5C7AD6志|r|cFF7085C2贵|r")
    u:setplayername("|cFF3366FF远|r|cFF5C85CC野|r|cFF85A399志|r|cFFADC266贵|r")
    u:buffset(u.handle, 110, "暂停")
    Movie_Boolean = true
    DayNightRun = false
    local cs = 0
    ac.loop(1000, function(t)
      cs = cs + 1
      DayNightRun = false
      Movie_Boolean = true
      ShowUnit(u.handle, false)
      if cs == 120 then
        DayNightRun = true
        Movie_Boolean = false
        t:remove()
      end
    end)
    ForGroupLuaNew(Group_PlayHero, function(xq)
      ShowUnit(xq.handle, false)
      xq:buffset(u.handle, 120, "绝对闪避")
    end)
    ForGroupLuaNew(Group_Monster, function(xq)
      xq:buffset(xq.handle, 120, "暂停")
    end)
    PlayBGM({
      bgm = BGM_Shiki_12,
      time = 130,
      ID = 24,
      unit = u.handle
    })
    ac.wait(52000, function()
      StopSoundBJ(BGM_Shiki_12, true)
    end)
    local a2 = angle + 45
    mj:setface(a2)
    local mj2 = u:createunit("u09B", x, y, a2)
    mj2:setcolor(255, 255, 255, 0)
    local xx, yy = PolarXY(x, y, -75, a2)
    local mj3 = u:createunit("u08H", xx, yy, angle + 225)
    mj3:setcolor(255, 255, 255, 0)
    do
      local tm = 0
      ac.loop(80, function(t2)
        tm = tm + 1.2750000000000001
        mj3:setcolor(255, 255, 255, tm)
        if 250 <= tm then
          t2:remove()
        end
      end)
      ac.wait(23000, function()
        ac.loop(200, function(t3)
          tm = tm - 2.5500000000000003
          mj3:setcolor(255, 255, 255, tm)
          if tm <= 0 then
            mj3:remove()
            t3:remove()
          end
        end)
      end)
      mj:animeact(9)
      ac.wait(12000, function()
        qy:chat("哟，兄弟，有没有好好享受啊。")
        PlayGlobalSound(Movie_Dream_01)
      end)
      ac.wait(15000, function()
        u:chat("呃……")
        PlayGlobalSound(Movie_Dream_09)
      end)
      ac.wait(17000, function()
        qy:chat("别老是挂着一副背负着什么重担的表情嘛")
        PlayGlobalSound(Movie_Dream_02)
      end)
      ac.wait(21500, function()
        u:chat("……")
      end)
      ac.wait(23500, function()
        qy:chat("哎呀，这可真是失礼了呢")
        PlayGlobalSound(Movie_Dream_03)
      end)
      ac.wait(27500, function()
        qy:chat("但是啊，今晚也该全部结束了。")
        PlayGlobalSound(Movie_Dream_04)
      end)
      ac.wait(31500, function()
        qy:chat("让我们双方都不去远虑地互相燃尽吧")
        PlayGlobalSound(Movie_Dream_05)
      end)
      ac.wait(38000, function()
        qy:chat("结果怎么样都好，多多少少让自己轻松一些吧")
        PlayGlobalSound(Movie_Dream_06)
      end)
      ac.wait(43500, function()
        u:chat("……")
      end)
      ac.wait(46500, function()
        u:chat("啊，的确是个不好的梦呢")
        PlayGlobalSound(Movie_Dream_07)
      end)
      ac.wait(50000, function()
        CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 1.0, "ReplaceableTextures\\CameraMasks\\DreamFilter_Mask.blp", 100.0, 0, 0, 0)
        u:chat("呃……")
        PlayGlobalSound(Movie_Dream_09)
        PlayGlobalSound(Movie_Dream_43)
        Effectcreate("ATX\\[ATxNew]Red_12.mdl", x, y, 0, 2, 50)
        Effectcreate("ATX\\[ATxNew]Purple_40.mdl", x, y, 0, 2, 50)
        Effectcreate("ATX\\[ATxNew]Black_09.mdl", x, y, 8, 2)
        mj2:animeact(9)
      end)
      ac.wait(55000, function()
        PlayGlobalSound(Movie_Dream_55)
        PlayGlobalSound(Movie_Dream_54)
        PlayGlobalSound(Movie_Dream_43)
        Effectcreate("ATX\\[ATxNew]Red_15.mdl", x, y, 0, 0.5)
        u:chat("直死魔眼……")
        Effectcreate("ATX\\[ATxNew]Halo_01.mdl", x, y, 3)
      end)
      ac.wait(58000, function()
        u:setplayername("|cFF003399志|r|cFF990000贵|r")
        u:chat("撒，来厮杀吧")
        PlayGlobalSound(Movie_Dream_41)
        PlayGlobalSound(Movie_Dream_53)
        mj:remove()
        mj2:setcolor(255, 255, 255, 255)
        mj2:animespeed(0.1)
        ResetUnitAnimation(mj2.handle)
        Effectcreate("ATX\\[ATxNew]Black_10.mdl", x, y, 0, 2)
        Effectcreate("ATX\\[ATxNew]Red_10.mdl", x, y, 0, 2)
      end)
    end
    ac.wait(61000, function()
      local jd2 = AngleBetweenUnits(mj2.handle, tg.handle)
      mj2:setface(jd2)
      u:chat("极死——")
      PlayGlobalSound(Movie_Dream_11)
      PlayGlobalSound(SE031)
      PlayGlobalSound(BGM_Shiki_11)
      mj2:animespeed(1)
      mj2:animeact(3)
      tg:effectadd("ATX\\[ATxNew]Purple_35.mdl", "overhead")
      mj2:effectadd("ATX\\[ATxNew]Blood_06.mdl", "overhead")
      ac.wait(700, function()
        u:chat("处以斩刑！")
        PlayGlobalSound(Movie_Dream_22)
        PlayGlobalSound(Sound_Yuanye_CD021)
      end)
      ac.wait(1000, function()
        Effectcreate("ATX\\[ATxNew]Black_11.mdl", x2, y2, 0, 3)
        CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 1.0, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0)
        SendMsgAll("|cFF3300CC「|r|cFF4400AA夜|r|cFF550088の|r|cFF660066光|r|cFF770044」|r")
        SetDayNightModels("Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdx", "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdx")
      end)
      ac.wait(1500, function()
        local djd = tg:getface()
        local xx, yy = PolarXY(x2, y2, 1000, djd)
        mj2:setxy(xx, yy)
        djd = djd + 180
        mj2:setface(djd)
        SetCameraTargetController(tg.handle, 0, 0, false)
        ForGroupLuaNew(Group_Monster, function(xq)
          if not xq:isboss() then
            xq:kill(u.handle, true)
          end
        end)
      end)
      ac.wait(2000, function()
        mj2:animeact("stand")
        for i = 1, 4 do
          local dmj = u:createunit("u09K", x2, y2, GetRandomAngle())
          dmj:timetoremove(34.2)
        end
        for i = 1, GetRandomInt(6, 12) do
          local dx, dy = PolarXY(x2, y2, GetRandomReal(900, 1800), GetRandomAngle())
          local dtx = Effectcreate("ATX\\[ATxNew]Model_07.mdl", dx, dy, 34.2, GetRandomReal(3, 8), 50, GetRandomAngle())
          SetEffectColor(dtx, 255, 0, 0)
          ac.wait(34000, function()
            SetEffectSize(dtx, 0.01)
          end)
        end
        for i = 1, GetRandomInt(3, 6) do
          local dx, dy = PolarXY(x2, y2, GetRandomReal(500, 1000), GetRandomAngle())
          local dtx = Effectcreate("ATX\\[ATxNew]Model_06.mdl", dx, dy, 34.2, GetRandomReal(3, 8), GetRandomReal(300, 700), GetRandomAngle())
          SetEffectColor(dtx, 255, 0, 0)
          ac.wait(34000, function()
            SetEffectSize(dtx, 0.01)
          end)
        end
      end)
      ac.wait(3000, function()
        CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 2.0, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0)
        u:chat("——欢迎来到、这华丽的惨杀空间")
        PlayGlobalSound(Movie_Dream_23)
      end)
      ac.wait(7300, function()
        u:chat("折其一为母……")
        PlayGlobalSound(Movie_Dream_24)
      end)
      ac.wait(7600, function()
        PlayGlobalSound(Movie_Dream_42)
        PlayGlobalSound(Movie_Dream_45)
        mj2:animeact(6)
      end)
      ac.wait(7900, function()
        local dx, dy = mj2:getxy()
        tg:animeact("death")
        local dmj = u:createunit("u09L", dx, dy, jd2)
        dmj:timetoremove(1)
        LossHpUnit({
          u = u,
          tg = tg,
          damage = 0,
          perhp = 0,
          maxhp = 10,
          bj = "[生命损耗]噩梦の羁绊"
        })
      end)
      ac.wait(8000, function()
        CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 0.0, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0, 0, 0)
      end)
      ac.wait(8300, function()
        Effectcreate("ATX\\[ATxNew]Blood_07.mdl", x2, y2, 0, 3)
        CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.8, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0, 0, 0)
        ac.timer(100, 12, function()
          Effectcreate("ATX\\[ATxNew]Blood_04.mdl", x2, y2)
        end)
      end)
      ac.wait(8400, function()
        mj2:animespeed(0)
      end)
      ac.wait(9800, function()
        u:chat("折其二为父……")
      end)
      ac.wait(10100, function()
        PlayGlobalSound(Movie_Dream_42)
        PlayGlobalSound(Movie_Dream_45)
        mj2:animespeed(1)
        mj2:animeact(7)
      end)
      ac.wait(10400, function()
        local dx, dy = mj2:getxy()
        tg:animeact("death")
        CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 0.0, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0, 0, 0)
        local dmj = u:createunit("u09M", dx, dy, jd2)
        dmj:timetoremove(1)
        LossHpUnit({
          u = u,
          tg = tg,
          damage = 0,
          perhp = 0,
          maxhp = 10,
          bj = "[生命损耗]噩梦の羁绊"
        })
      end)
      ac.wait(10700, function()
        Effectcreate("ATX\\[ATxNew]Blood_07.mdl", x2, y2, 0, 3)
        CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.8, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0, 0, 0)
        ac.timer(100, 12, function()
          Effectcreate("ATX\\[ATxNew]Blood_04.mdl", x2, y2)
        end)
      end)
      ac.wait(10900, function()
        mj2:animespeed(0)
      end)
      ac.wait(12300, function()
        local dx, dy = PolarXY(x2, y2, 150, jd2 + 180)
        Effectcreate("ATX\\[ATxNew]Black_01.mdl", x, y)
        Effectcreate("ATX\\[ATxNew]Black_01.mdl", dx, dy)
        Effectcreate("ATX\\[ATxNew]Blood_07.mdl", x2, y2, 0, 3)
        Effectcreate("ATX\\[ATxNew]ShockBoom_32.mdl", x2, y2, 0, 3)
        Effectcreate("ATX\\[ATxNew]Dust_01.mdl", x2, y2, 0, 3)
        mj2:setxy(dx, dy)
        mj2:animespeed(1)
        mj2:animeact(1)
        u:chat("撒，斩断你多少次命才会有无常到来呢……")
        PlayGlobalSound(Movie_Dream_41)
      end)
      ac.wait(14500, function()
        mj2:animeact(18)
        unitmove({
          unit = mj2.handle,
          time = 0.7,
          distance = 400,
          angle = angle,
          isfly = true
        })
      end)
      ac.wait(15200, function()
        local dx, dy = mj2:getxy()
        Effectcreate("war3mapImported\\specialanimedustwave.mdx", dx, dy)
        Effectcreate("ATX\\[ATxNew]Dust_01.mdl", dx, dy)
      end)
      ac.wait(15500, function()
        local dx, dy = mj2:getxy()
        Effectcreate("ATX\\[ATxNew]Black_01.mdl", dx, dy)
        mj2:setcolor(255, 255, 255, 0)
        SendMsgAll("|cFF3300CC「|r|cFF4400AA七|r|cFF550088之|r|cFF660066解|r|cFF770044」|r")
        ac.wait(1500, function()
          u:chat("这位客人，请小心了，我的脚法正在逐渐变差")
          PlayGlobalSound(Movie_Dream_25)
        end)
        ac.wait(9000, function()
          u:chat("英勇而去之人，也会迅驰而逝")
          PlayGlobalSound(Movie_Dream_26)
        end)
        ac.wait(13000, function()
          u:chat("被我贯穿脑袋之后老老实实死掉才是应有的礼仪吧？")
          PlayGlobalSound(Movie_Dream_27)
        end)
        ac.wait(500, function()
          local g = CreateGroupLua()
          mj2:setcolor(255, 255, 255, 255)
          ResetUnitAnimation(mj2.handle)
          mj2:animeact(8)
          mj2:animespeed(4)
          for i = 1, 5 do
            local dmj = u:createunit("u09E", xx, yy, jd2 + 90)
            ResetUnitAnimation(dmj.handle)
            dmj:animeact(8)
            dmj:animespeed(4)
            dmj:setcolor(255, 255, 255, 0)
            dmj:groupadd(g)
            ac.wait(20, function()
              dmj:setcolor(255, 255, 255, 255)
            end)
          end
          local x2, y2 = tg:getxy()
          local jd2 = GetRandomAngle()
          local jl = 1000
          local cs = 0
          local cs2 = 0
          local cs3 = 0
          local cs4 = 0
          local cs5 = 0
          local cs6 = 65
          local v = 3
          ac.loop(10, function(t)
            if cs4 == 0 then
              cs = cs + 1
              cs2 = cs2 + 1
              if cs6 == 0 then
                v = v + 0.01
              end
              jd2 = jd2 + v
              if 300 <= v then
                v = 300
              end
              jl = jl + GetRandomReal(-10, 10)
              if 1200 <= jl then
                jl = 1200
              end
              if jl <= 800 then
                jl = 800
              end
              local xx, yy = PolarXY(x2, y2, jl, jd2)
              mj2:setxy(xx, yy)
              mj2:setface(jd2 + 90)
              ForGroupLuaNew(g, function(xq)
                xq:setxy(xx, yy)
                xq:setface(jd2 + 90)
              end)
              if cs2 == 3 then
                cs2 = 0
                Effectcreate("ATX\\[ATxNew]Black_01.mdl", xx, yy, 0, 0.5, 0, jd2, 0, 0, 0.5)
                local dmj = Group_Randomunit(g)
                dmj:animespeed(0)
                dmj:groupremove(g)
                local tm = 255
                ac.loop(10, function(dt)
                  tm = tm - 5.1000000000000005
                  dmj:setcolor(255, 255, 255, tm)
                  if tm <= 0 then
                    dmj:remove()
                    dt:remove()
                  end
                end)
              end
              if cs == 12 then
                for i = 1, 5 do
                  local dmj = u:createunit("u09E", xx, yy, jd2 + 90)
                  ac.wait(30, function()
                    ResetUnitAnimation(dmj.handle)
                    dmj:animeact(8)
                    dmj:animespeed(4)
                    dmj:groupadd(g)
                  end)
                  dmj:setcolor(255, 255, 255, 0)
                  ac.wait(50, function()
                    dmj:setcolor(255, 255, 255, 255)
                  end)
                end
              end
              if cs == 15 then
                cs = 0
                if cs6 == 0 then
                  cs3 = cs3 + 1
                  if cs3 == 4 then
                    cs3 = 0
                    cs4 = 30
                    cs5 = cs5 + 1
                    local jd3 = jd2 + 180
                    jd2 = jd2 + 180
                    local jl2 = jl / 60
                    local g2 = CreateGroupLua()
                    for i = 1, 10 do
                      local dmj = u:createunit("u09E", xx, yy, jd3)
                      ResetUnitAnimation(dmj.handle)
                      dmj:animeact(16)
                      dmj:animespeed(3)
                      dmj:groupadd(g2)
                      dmj:setcolor(255, 255, 255, 0)
                      ac.wait(40, function()
                        dmj:setcolor(255, 255, 255, 255)
                      end)
                    end
                    ResetUnitAnimation(mj2.handle)
                    mj2:animeact(16)
                    mj2:animespeed(3)
                    PlayGlobalSound(Movie_Dream_46)
                    if cs5 == 7 then
                      ac.wait(10, function()
                        ForGroupLuaNew(g, function(xq)
                          xq:remove()
                        end)
                        ForGroupLuaNew(g2, function(xq)
                          xq:remove()
                        end)
                      end)
                      Effectcreate("BTX\\[BTxNew]zhanji-red.mdl", x2, y2, 0, 2, 0, jd3)
                      Effectcreate("ATX\\[ATxNew]Blood_04.mdl", x2, y2, 0, 3)
                      PlayGlobalSound(Movie_Dream_47)
                      PlayGlobalSound(Movie_Dream_48)
                      tg:animeact("death")
                      CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 0.0, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0, 0, 0)
                      ac.wait(500, function()
                        CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.5, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0, 0, 0)
                      end)
                    else
                      do
                        local dcs = 0
                        local dcs2 = 0
                        local dxx = xx
                        local dyy = yy
                        ac.loop(10, function(dt2)
                          dcs = dcs + 1
                          dcs2 = dcs2 + 1
                          dxx, dyy = PolarXY(dxx, dyy, jl2, jd2)
                          mj2:setxy(dxx, dyy)
                          mj2:setface(jd3)
                          ForGroupLuaNew(g2, function(xq)
                            xq:setxy(dxx, dyy)
                            xq:setface(jd3)
                          end)
                          if dcs2 == 3 then
                            dcs2 = 0
                            local dmj = Group_Randomunit(g2)
                            dmj:animespeed(0)
                            dmj:groupremove(g2)
                            local tm = 255
                            ac.loop(10, function(dt)
                              tm = tm - 5.1000000000000005
                              dmj:setcolor(255, 255, 255, tm)
                              if tm <= 0 then
                                dmj:remove()
                                dt:remove()
                              end
                            end)
                          end
                          if dcs == 30 then
                            Effectcreate("BTX\\[BTxNew]zhanji-red.mdl", x2, y2, 0, 2, 0, jd3)
                            Effectcreate("ATX\\[ATxNew]Blood_04.mdl", x2, y2, 0, 3)
                            PlayGlobalSound(Movie_Dream_48)
                            CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.5, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0, 0, 0)
                            tg:animeact("death")
                            LossHpUnit({
                              u = u,
                              tg = tg,
                              damage = 0,
                              perhp = 7,
                              maxhp = 0,
                              bj = "[生命损耗]噩梦の羁绊"
                            })
                            dt2:remove()
                          end
                        end)
                      end
                    end
                  else
                    ResetUnitAnimation(mj2.handle)
                    mj2:animeact(8)
                    mj2:animespeed(4)
                  end
                else
                  cs6 = cs6 - 1
                end
              end
            else
              cs4 = cs4 - 1
            end
            if cs5 == 7 then
              t:remove()
            end
          end)
        end)
      end)
      ac.wait(31500, function()
        SendMsgAll("|cFF3300CC「|r|cFF4400AA狱|r|cFF550088杀|r|cFF660066门|r|cFF770044」|r")
        u:chat("结束了")
        PlayGlobalSound(Movie_Dream_28)
      end)
      ac.wait(32500, function()
        local jd3 = tg:getface()
        local x2, y2 = tg:getxy()
        PlayGlobalSound(Movie_Dream_49)
        local jd4 = jd3 + 90
        local jl2 = 600
        local xx, yy = PolarXY(x2, y2, jl2, jd4)
        Effectcreate("war3mapImported\\specialanimedustwave.mdx", xx, yy)
        Effectcreate("ATX\\[ATxNew]Black_01.mdx", xx, yy)
        local dtx = Effectcreate("ATX\\[ATxNew]Model_07.mdl", xx, yy, 1.5, 1.4)
        SetEffectColor(dtx, 255, 0, 255)
        mj2:setxy(xx, yy)
        mj2:setface(jd4 + 180)
        local g3 = CreateGroupLua()
        for i = 1, 15 do
          local dmj = u:createunit("u09E", xx, yy, jd4 + 180)
          ResetUnitAnimation(dmj.handle)
          dmj:animeact(22)
          dmj:animespeed(0.75)
          dmj:groupadd(g3)
          dmj:setcolor(255, 255, 255, 0)
          ac.wait(90, function()
            dmj:setcolor(255, 255, 255, 255)
          end)
        end
        ResetUnitAnimation(mj2.handle)
        mj2:animeact(22)
        mj2:animespeed(0.75)
        local cs = 0
        local cs2 = 0
        local v = 1
        local h = 0
        local dx = xx
        local dy = yy
        local jd4 = jd4 + 180
        ac.loop(10, function(t4)
          cs = cs + 1
          cs2 = cs2 + 1
          dx, dy = PolarXY(dx, dy, v, jd4)
          h = h + 0.5
          if cs < 290 then
            mj2:setflyheight(h)
            mj2:setxy(dx, dy)
          end
          ForGroupLuaNew(g3, function(xq)
            xq:setflyheight(h)
            xq:setxy(dx, dy)
          end)
          if cs2 == 20 then
            cs2 = 0
            local dmj = Group_Randomunit(g3)
            dmj:animespeed(0)
            dmj:groupremove(g3)
            local tm = 255
            ac.loop(10, function(dt)
              tm = tm - 5.1000000000000005
              dmj:setcolor(255, 255, 255, tm)
              if tm <= 0 then
                dmj:remove()
                dt:remove()
              end
            end)
          end
          if cs == 300 then
            t4:remove()
          end
        end)
        local jd4 = jd3 - 90
        local jl2 = 600
        local xx, yy = PolarXY(x2, y2, jl2, jd4)
        local dmj2 = u:createunit("u09D", xx, yy, jd4 + 180)
        Effectcreate("war3mapImported\\specialanimedustwave.mdx", xx, yy)
        Effectcreate("ATX\\[ATxNew]Black_01.mdx", xx, yy)
        local dtx = Effectcreate("ATX\\[ATxNew]Model_07.mdl", xx, yy, 1.5, 1.4)
        SetEffectColor(dtx, 255, 0, 255)
        dmj2:setxy(xx, yy)
        dmj2:setface(jd4 + 180)
        local g3 = CreateGroupLua()
        for i = 1, 15 do
          local dmj = u:createunit("u09D", xx, yy, jd4 + 180)
          ResetUnitAnimation(dmj.handle)
          dmj:animeact(22)
          dmj:animespeed(0.75)
          dmj:groupadd(g3)
          dmj:setcolor(255, 255, 255, 0)
          ac.wait(90, function()
            dmj:setcolor(255, 255, 255, 255)
          end)
        end
        ResetUnitAnimation(dmj2.handle)
        dmj2:animeact(22)
        dmj2:animespeed(0.75)
        local cs = 0
        local cs2 = 0
        local v = 1
        local h = 0
        local dx = xx
        local dy = yy
        local jd4 = jd4 + 180
        ac.loop(10, function(t4)
          cs = cs + 1
          cs2 = cs2 + 1
          dx, dy = PolarXY(dx, dy, v, jd4)
          h = h + 0.5
          if cs < 290 then
            dmj2:setflyheight(h)
            dmj2:setxy(dx, dy)
          end
          ForGroupLuaNew(g3, function(xq)
            xq:setflyheight(h)
            xq:setxy(dx, dy)
          end)
          if cs2 == 20 then
            cs2 = 0
            local dmj = Group_Randomunit(g3)
            dmj:animespeed(0)
            dmj:groupremove(g3)
            local tm = 255
            ac.loop(10, function(dt)
              tm = tm - 5.1000000000000005
              dmj:setcolor(255, 255, 255, tm)
              if tm <= 0 then
                dmj:remove()
                dt:remove()
              end
            end)
          end
          if cs == 300 then
            t4:remove()
          end
        end)
        ac.wait(2900, function()
          StopSoundBJ(Movie_Dream_49, false)
          PlayGlobalSound(Movie_Dream_50)
          PlayGlobalSound(Movie_Dream_41)
          LossHpUnit({
            u = u,
            tg = tg,
            damage = 0,
            perhp = 0,
            maxhp = 10,
            bj = "[生命损耗]噩梦の羁绊"
          })
          Effectcreate("war3mapImported\\bbb.mdx", x2, y2, 0, 2)
          Effectcreate("ATX\\[ATxNew]Dust_33.mdl", x2, y2, 0, 2)
          Effectcreate("BTX\\[BTxNew]ymps-wb10.mdx", x2, y2, 10, 1, 0, 270)
          Effectcreate("BTX\\[BTxNew]ymps-wb10.mdx", x2, y2, 10, 1, 0, 225)
          Effectcreate("BTX\\[BTxNew]Attack_bw.mdl", x2, y2, 2, 2)
          local jd4 = jd3 + 90
          local xx, yy = PolarXY(x2, y2, 100, jd4)
          EffectcreateArgs({
            effect = "BTX\\[BTxNew]zhanji-red.mdl",
            x = xx,
            y = yy,
            time = 2,
            size = 1.5,
            height = 250,
            zxz = jd4 + 180,
            xxz = 45
          })
          EffectcreateArgs({
            effect = "war3mapImported\\zhanji-blue-shu.mdl",
            x = x2,
            y = y2,
            time = 2,
            size = 0.6,
            height = 150,
            zxz = jd4,
            xxz = 45
          })
          local xx, yy = PolarXY(x2, y2, jl2, jd4)
          dmj2:setxy(xx, yy)
          dmj2:animespeed(1)
          mj2:animeact(23)
          dmj2:setflyheight(0)
          jd4 = jd3 - 90
          local xx, yy = PolarXY(x2, y2, jl2, jd4)
          mj2:setxy(xx, yy)
          mj2:animespeed(1)
          mj2:animeact(23)
          mj2:setflyheight(0)
          for i = 1, 5 do
            Effectcreate("BTX\\[BTxNew]ymps-wb2.mdl", x2, y2, 30, 1.5 + 0.5 * i)
          end
        end)
        ac.wait(3150, function()
          CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 0.25, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 100.0, 100.0, 0)
        end)
        ac.wait(3150, function()
          CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 3.0, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 100.0, 100.0, 0)
        end)
        ac.wait(7000, function()
          u:chat("你的死期已经确定了")
          PlayGlobalSound(Movie_Dream_29)
          mj2:setface(mj2:getface() + 180)
          dmj2:setface(dmj2:getface() + 180)
          mj2:animeact(18)
          dmj2:animeact(18)
        end)
        ac.wait(7200, function()
          tg:animeact("death")
          tg:effectadd("ATX\\[ATxNew]Hit_02.mdl", "chest")
          Effectcreate("war3mapImported\\bbb.mdx", x2, y2, 0, 2)
          local cs2 = 0
          ac.loop(20, function(t2)
            cs2 = cs2 + 1
            tg:setflyheight(cs2 * 12)
            if cs2 == 20 then
              t2:remove()
            end
          end)
        end)
        ac.wait(7700, function()
          tg:animespeed(0)
        end)
        ac.wait(10000, function()
          u:chat("知道要去哪里了吗？")
          PlayGlobalSound(Movie_Dream_30)
          PlayGlobalSound(SE031)
          local dx, dy = mj2:getxy()
          Effectcreate("ATX\\[ATxNew]Purple_35.mdl", dx, dy, 0, 1.4)
          local dx, dy = dmj2:getxy()
          Effectcreate("war3mapImported\\[Murasame]01 (4).mdl", dx, dy, 0, 2)
          mj2:animeact(3)
          dmj2:animeact(3)
        end)
        ac.wait(10500, function()
          mj2:animespeed(0)
          dmj2:animespeed(0)
        end)
        ac.wait(12000, function()
          local x, y = mj2:getxy()
          Effectcreate("ATx\\[ATxNew]Black_01.mdl", x, y)
          Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
          mj2:setcolor(255, 255, 255, 0)
          mj2:animeact(29)
          mj2:animespeed(3)
          mj2:setflyheight(125)
          local x, y = dmj2:getxy()
          Effectcreate("ATx\\[ATxNew]Black_01.mdl", x, y)
          Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
          dmj2:setcolor(255, 255, 255, 0)
          dmj2:animeact(29)
          dmj2:animespeed(3)
          dmj2:setflyheight(125)
        end)
        ac.wait(12430, function()
          local dx, dy = PolarXY(x2, y2, 25, jd3 + 90)
          dmj2:setxy(dx, dy)
          dmj2:setcolor(255, 255, 255, 255)
          dmj2:animespeed(0)
          Effectcreate("ATx\\[ATxNew]Black_01.mdl", dx, dy, 0, 1, 325)
          local dx, dy = PolarXY(x2, y2, 25, jd3 - 90)
          mj2:setxy(dx, dy)
          mj2:setcolor(255, 255, 255, 255)
          mj2:animespeed(0)
          Effectcreate("ATx\\[ATxNew]Black_01.mdl", dx, dy, 0, 1, 325)
        end)
        ac.wait(12800, function()
          u:chat("如果是下地狱的话——")
        end)
        ac.wait(14700, function()
          u:chat("代我向阎王问好")
        end)
        ac.wait(15000, function()
          Effectcreate("BTX\\[BTxNew]zhanji-red.mdl", x2, y2, 0, 1.5, 325, jd3 + 45)
          Effectcreate("war3mapImported\\zhanji-blue-shu.mdl", x2, y2, 0, 0.6, 325, jd3 - 45)
          local dx, dy = PolarXY(x2, y2, 200, jd3 + 90)
          mj2:setxy(dx, dy)
          mj2:setflyheight(0)
          mj2:animespeed(1)
          mj2:animeact(23)
          local dx, dy = PolarXY(x2, y2, 200, jd3 - 90)
          dmj2:setxy(dx, dy)
          dmj2:setflyheight(0)
          dmj2:animespeed(1)
          dmj2:animeact(23)
          PlayGlobalSound(Movie_Dream_44)
          Effectcreate("ATX\\[ATxNew]Blood_03.mdl", x2, y2, 0, 1, 325)
        end)
        ac.wait(17100, function()
          u:chat("消散吧")
          tg:zsdamage(u.handle)
          PlayGlobalSound(Movie_Dream_52)
          PlayGlobalSound(Movie_Dream_48)
          PlayGlobalSound(Movie_Dream_47)
          PlayGlobalSound(Movie_Dream_50)
          tg:effectadd("war3mapImported\\Texiao_Xuebao.mdx", "origin")
          tg:effectadd("ATx\\[ATxNew]Blood_01.mdl", "head")
          tg:effectadd("ATx\\[ATxNew]Hit_01.mdx", "chest")
          tg:setflyheight(0)
          tg:animespeed(1)
          Effectcreate("ATx\\[ATxNew]Dust_01.mdl", x2, y2)
          Effectcreate("ATX\\[ATxNew]Purple_02.mdl", x2, y2, 0, 2)
          Effectcreate("ATX\\[ATxNew]ShockBoom_20.mdl", x2, y2, 0, 2)
        end)
        ac.wait(28000, function()
          local dx, dy = mj2:getxy()
          local dtx = Effectcreate("ATX\\[ATxNew]Blue_11.mdl", dx, dy, 1.5, 1.4)
          SetEffectColor(dtx, 255, 0, 255)
          local dx, dy = dmj2:getxy()
          local dtx = Effectcreate("ATX\\[ATxNew]Blue_11.mdl", dx, dy, 1.5, 1.4)
          local x, y = mj2:getxy()
          local jd4 = mj2:getface()
          mj2:remove()
          dmj2:remove()
          u:setxy(x, y)
          u:setface(jd4)
          ShowUnit(u.handle, true)
          ResetToGameCamera(0)
          ForGroupLuaNew(Group_PlayHero, function(xq)
            ShowUnit(xq.handle, true)
            xq:buffset(u.handle, 10, "绝对闪避")
            local p = getplayer(xq.owner)
            p:setcameraheight(Cam_height[xq.ownerid], 0)
          end)
          u:select()
          AdvanceGet["噩梦志贵"](u)
        end)
      end)
    end)
  end,
  ["樱总司禁忌"] = function(u)
    local sy = u.ownerid
    u:setdata("禁忌判定-樱总司")
    u:reduceshw()
    u:removeitem(u:getitem("I020"))
    u:removeitem(u:getitem("I021"))
    PlayGlobalSound(Chongtianzongsi_2)
    ac.wait(1, function()
      u:additem("I0G6")
    end)
    u:addskill("A0M9")
    ChangeValue(DamageSystem_Shjc, sy, 0.08)
    ChangeValue(DamageSystem_Shjc, sy, 0.04)
    ChangeValue(DamageSystem_Baoshang, sy, 0.32)
    ChangeValue(DamageSystem_Baoji, sy, 8)
    ChangeValue(DamageSystem_Txsh, sy, 0.25)
    u:setskilldatareal("A14T", "施法间隔", 1.5)
    u:setskilldatareal("A052", "施法间隔", 1.5)
    local jc = 0
    ac.loop(3000, function()
      ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * jc))
      jc = 0.0025 * u:getdata("闪避值")
      ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * jc))
    end)
    ForGroupLuaNew(Group_PlayHero, function(xq)
      local sy2 = xq.ownerid
      ChangeValue(DamageSystem_Baoshang, sy2, 0.15)
      ChangeValue(DamageSystem_Baoji, sy2, 15)
    end)
    u:buffset(u.handle, 20, "暂停")
    u:buffset(u.handle, 22, "绝对闪避")
    u:buffset(u.handle, 22, "无敌")
    u:addstexiao("樱总司", "暴击系统触发效果", function(args)
      local tg = args.tg
      local u = args.u
      local info = args.damageinfo
      u:changetimedata("闪避值", 1, 6)
      if not u:hasdata("樱总司-绝刀冷却") then
        u:settimedata("樱总司-绝刀冷却", 0.5)
        u:curetili(1)
      end
    end)
    AddAllSTexiao("樱总司", "直接伤害特效", function(args)
      local tg = args.tg
      local info = args.damageinfo
      local dy = info.hero
      if dy.handle ~= u.handle then
        local xs = 0.05
        if not u:isalive() then
          xs = 0.15
        end
        DamageUnit({
          bj = "樱总司附伤",
          unit = tg.handle,
          source = u.handle,
          damage = xs * info.yssh,
          level = 5,
          type = "灵力",
          isvest = true,
          isattack = false,
          isnoarmor = false,
          element = "无"
        })
      end
    end)
    ac.wait(2000, function()
      SendMsgAll("|cFFFF66FF「既然同为我的你」|r")
    end)
    ac.wait(8000, function()
      SendMsgAll("|cFFFF66FF「一定能够理解吧」|r")
    end)
    ac.wait(14000, function()
      SendMsgAll("|cFFFF66FF「就让我助你一程」|r")
    end)
    ac.wait(20000, function()
      SendMsgAll("|cFFFF66FF「继续战斗下去吧！」|r")
      ModelReplace({
        u = u,
        model = "CTZS_HF2.mdx",
        modelsize = 1,
        modelname = "|cFFFF99FF樱|r|cFFFF73BF总|r|cFFFF4C80司|r",
        modelicon = "CTZS_HF2_portrait.tga"
      })
      NameID[sy] = "|cFFFF99FF樱|r|cFFFF73BF总|r|cFFFF4C80司|r"
      u:setplayername(NameID[sy])
      u:uivar_change({
        keyname = "病弱",
        keytype = "传奇栏",
        text = "|cFFFF66FF觉悟の念|r\n|cFFFF66FF无明三|r\n|cFFFF99FF直接伤害时额外造成三次无视护甲物理伤害,冷却0.25秒|r\n|cFFFF66FF绝刀|r\n|cFFFF99FF提升[闪避值*0.25%]基础伤害\n暴击时提升1点闪避值,持续6秒\n暴击时恢复1点体力,触发冷却0.5秒|r\n|cFFFF66FF寸土|r\n|cFFFF99FF[缩地]最大距离提升50%\n[缩地]冷却降低0.25秒|r\n|cFFFF66FF止水|r\n|cFFFF99FF提升12%伤害加成\n提升4%伤害加成\n提升32%暴击率\n提升32%暴击伤害\n提升50%非近战特效伤害\n受伤时20%格挡伤害|r\n|cFFFF66FF徒樱|r\n|cFFFF99FF自身闪避值提供的闪避效果减半\n提升全队15%暴击率与15%暴击伤害\n队友的直接伤害附带伤害来源为你的5%抹除伤害;自身死亡时效果为15%|r\n|cFF949596易凋之樱|r",
        icon = "NewIcon_Yzs",
        ishasphoto = true
      })
    end)
    PlayBGM({
      bgm = 0,
      time = 255,
      ID = 145,
      unit = u.handle
    })
    ac.wait(30000, function()
      PlayGlobalSound(BGM_Ctzs_01)
    end)
    u:settimedata("樱总司-复活", 245)
  end,
  ["代而亡逝之光"] = function(u, tg)
    local sy = u.ownerid
    Danwei_Gzl = 0
    Movie_Boolean = true
    u:buffset(u.handle, 50, "暂停")
    PlayBGM({
      bgm = BGM_Gzl_01,
      time = 125,
      ID = 166,
      unit = u.handle
    })
    u:chat("『反狱』六十，盈满产声。")
    u:chat("惟愿与君，同日降生。", 3)
    ac.wait(6000, function()
      local str = "——我于此弃旗"
      SendColorfulMsgAll(str, "|cFFBFA68F", "|cFFBA9379", "|cFF9C8C7E")
    end)
    ac.wait(9000, function()
      local str = "世界的祝福已然无关紧要"
      SendColorfulMsgAll(str, "|cFFBFA68F", "|cFFBA9379", "|cFF9C8C7E")
    end)
    ac.wait(12000, function()
      local str = "我才是那未得降诞之生命的祝福之光——"
      SendColorfulMsgAll(str, "|cFFBFA68F", "|cFFBA9379", "|cFF9C8C7E")
    end)
    ac.wait(15000, function()
      local str = "——魔法『代而亡逝之光』"
      SendColorfulMsgAll(str, "|cFFBFA68F", "|cFFBA9379", "|cFF9C8C7E")
    end)
    ac.wait(18000, function()
      local str = "此身血肉，徒具人形，未曾降世"
      SendColorfulMsgAll(str, "|cFFBFA68F", "|cFFBA9379", "|cFF9C8C7E")
    end)
    ac.wait(21000, function()
      local str = "诞生之梦逐而不及，往赴九泉更为奢望"
      SendColorfulMsgAll(str, "|cFFBFA68F", "|cFFBA9379", "|cFF9C8C7E")
    end)
    ac.wait(24000, function()
      local str = "……及至今日，终于得生。"
      SendColorfulMsgAll(str, "|cFFBFA68F", "|cFFBA9379", "|cFF9C8C7E")
    end)
    ac.wait(27000, function()
      flashphoto({
        photo = "Ph_Gzl.tga",
        timeout = 3,
        timehold = 3,
        timein = 3
      })
      local str = "所谓人者，必能以生命降诞之光，一扫不生不死之暗"
      SendColorfulMsgAll(str, "|cFFBFA68F", "|cFFBA9379", "|cFF9C8C7E")
    end)
    ac.wait(30000, function()
      local str = "……至爱之声响彻魂灵，"
      SendColorfulMsgAll(str, "|cFFBFA68F", "|cFFBA9379", "|cFF9C8C7E")
    end)
    ac.wait(33000, function()
      tg:clearbuff("暂停")
      tg:clearbuff("绝对闪避")
      tg:clearbuff("无敌")
      u:shanmo()
      tg:setdata("光之理-代而亡逝之光")
      local sy2 = tg.ownerid
      ChangeValue(HeroMenu_HpForever_MaxHp, sy2, 0.75)
      tg:uivar_change({
        keyname = "代而亡逝之光",
        keytype = "传奇栏",
        text = "|cFFC9BDA5『代而亡逝之光』|r\n|cFFC9BDA5提升0.75%永恒恢复\n降低50%所受伤害|r\n|cFF949596『此身血肉，徒具人形，未曾降世』\n『诞生之梦逐而不及，往赴九泉更为奢望』\n……及至今日，终于得生。\n『所谓人者，必能以生命降诞之光，一扫不生不死之暗』\n……『至爱之声响彻魂灵』，\n倘此声不绝，则我生不灭，直至永远……——|r",
        icon = "Ewl_Gzl_02"
      })
      local str = "倘此声不绝，则我生不灭，直至永远……——"
      SendColorfulMsgAll(str, "|cFFBFA68F", "|cFFBA9379", "|cFF9C8C7E")
    end)
  end,
  ["歌月十夜"] = function(u, tg)
    local sy = u.ownerid
    PlayBGM({
      bgm = Nanaya_BGM2,
      time = 40,
      ID = 30,
      unit = u.handle
    })
    local x, y = u:getxy()
    local x2, y2 = tg:getxy()
    local jd = AngleXY(x, y, x2, y2)
    local mj
    u:buffset(u.handle, 70, "无敌")
    u:buffset(u.handle, 45, "暂停")
    u:buffset(u.handle, 70, "绝对闪避")
    u:buffset(u.handle, 45, "永恒")
    tg:buffset(u.handle, 7, "暂停")
    tg:buffset(u.handle, 7, "沉默")
    Movie_Boolean = true
    local g = CreateGroupLua()
    for _, xq in ac.selector():in_rangexy(x2, y2, 450):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      xq:groupadd(g)
      xq:buffset(u.handle, 40, "暂停")
      xq:animespeed(0)
    end
    EnableWeatherEffect(Tqxg, false)
    RemoveWeatherEffect(Tqxg)
    ac.wait(4000, function()
      Tqxg = AddWeatherEffect(RECT_PlayArea, S2ID("SNls"))
      EnableWeatherEffect(Tqxg, true)
      PlayGlobalSound(Nanaya_G1)
      u:chat("极死----")
    end)
    ac.wait(6500, function()
      local dx, dy = PolarXY(x, y, 400, jd)
      u:setxy(dx, dy)
      u:setface(jd)
      Effectcreate("Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl", dx, dy)
      PlayGlobalSound(Nanaya_G2)
      u:chat("七夜……")
      flashphoto({
        photo = "war3mapImported\\Qiye_2.blp",
        timeout = 3,
        timehold = 3,
        timein = 3
      })
    end)
    ac.wait(10500, function()
      ForGroupLuaNew(g, function(xq)
        xq:animespeed(1)
        xq:animeact("death")
      end)
      tg:groupremove(g)
      ForGroupLuaNew(g, function(xq)
        xq:effectadd("war3mapImported\\Texiao_Xuebao.mdx")
        xq:kill(u.handle, true)
      end)
      tg:effectadd("war3mapImported\\Texiao_Xuebao.mdx")
      if tg:isingroup(HellGroup) then
        LossHpUnit({
          u = u,
          tg = tg,
          damage = 0,
          perhp = 90,
          maxhp = 0,
          bj = "[生命损耗]歌月十夜"
        })
      else
        tg:kill(u.handle)
      end
    end)
    ac.wait(12000, function()
      PlayGlobalSound(NanayaYinxiao__8_u)
      local wl = false
      local lp
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq:hasdata("变异判定-水月") and xq.handle ~= u.handle then
          wl = true
          lp = xq
        end
      end)
      local cs = 0
      ac.loop(1000, function(timer)
        cs = cs + 1
        u:setcolor(255, 255, 255, 255 - 8 * cs)
        if cs == 28 then
          if not wl then
            Movie_Boolean = false
            EnableWeatherEffect(Tqxg, false)
            RemoveWeatherEffect(Tqxg)
            Tqxg = AddWeatherEffect(RECT_PlayArea, S2ID("RAlr"))
            EnableWeatherEffect(Tqxg, true)
            u:shanmo()
            ForGroupLuaNew(Group_DeathHero, function(xq)
              HeroRelive(xq.handle, x, y, 3)
            end)
          end
          timer:remove()
        end
      end)
      u:chat("我与你都是……")
      u:chat("不确切的水月……", 2)
      u:chat("乃原本不存于世之物", 4.6)
      u:chat("在夏之雪中消散掉", 8.8)
      u:chat("对你我来说都是幸福吧----", 12.2)
      ac.wait(12200, function()
        u:buffset(u.handle, 73, "绝对闪避")
        u:buffset(u.handle, 73, "永恒")
        if wl then
          HeroRelive(lp.handle, x, y, 3)
          local sy2 = lp.ownerid
          lp:settimedata("真夏的白雪", 140)
          lp:setdata("变异判定-白莲")
          lp:setdata("变异判定-真夏的白雪")
          Qiyue_WhiteLen_Len = lp.handle
          Qiyue_WhiteLen_Nanaya = u.handle
          ModelReplace({
            u = lp,
            model = "Bailian.mdx",
            modelsize = 1,
            modelname = "|cFFB8B8B9白|r|cFF949596莲|r",
            modelicon = "Bailian_portrait.tga"
          })
          lp:uivar_change({
            keyname = "水月",
            keytype = "传奇栏",
            text = "|cFFCCFFFF真夏|r|cFFA3CCFF的|r|cFF7A99FF白|r|cFF5266FF雪|r\n|cFFCCFFFF七夜志贵极死七夜出现概率固定为1%,释放极死七夜不再消耗杀意值|r\n|cFFA3CCFF七夜志贵无需七夜便可获取杀意值,拥有七夜时提升100%杀意值获取|r\n|cFF7A99FF七夜志贵提升[杀意值*0.002%]伤害加成|r\n|cFF5266FF自身杀敌时也会为七夜志贵获取一半杀意值\n自身死亡时如果七夜志贵存活则七夜志贵代替死亡|r",
            icon = "war3mapImported\\PASBTNEwl_Teshu_WLen.blp"
          })
          u:setdata("七夜-杀戮值", 0)
          ac.loop(1000, function()
            u:changedata("七夜-杀戮值", 1)
            local wqlx = Hero_Equip_WeaponType[sy]
            if wqlx == Weapons["七夜"] then
              u:changedata("七夜-杀戮值", 1)
            end
            if not u:ishasskill("A0CG") and u:getluckrandom(1) then
              u:banweaponskill(false)
              u:addskill("A0CG")
              u:banskill("A0CG", false)
            end
          end)
          StopSoundBJ(NanayaYinxiao__8_u, false)
          StopSoundBJ(Nanaya_BGM2, false)
          NameID[sy] = "|cFF3366FF七|r|cFF4770EB夜|r|cFF5C7AD6志|r|cFF7085C2贵|r"
          u:setplayername(NameID[sy])
          NameID[sy2] = "|cFFB8B8B9白|r|cFF949596莲|r"
          lp:setplayername(NameID[sy2])
          PlayGlobalSound(Sound_Len_10)
          PlayGlobalSound(Sound_Len_09)
          PlayGlobalSound(Sound_Len_08)
          SetTimeOfDay(12)
          ac.wait(6000, function()
            local x, y = u:getxy()
            local mj = u:createunit("u07S", x, y, GetRandomAngle())
            mj:timetoremove(60)
            for i = 1, 6 do
              local angle = i * 60
              local dx, dy = PolarXY(x, y, 1500, angle)
              local mj = u:createunit("u07S", dx, dy, GetRandomAngle())
              mj:timetoremove(60)
            end
          end)
          flashphoto({
            photo = "ReplaceableTextures\\CameraMasks\\White_mask.blp",
            timeout = 3,
            timehold = 7,
            timein = 3
          })
          lp:buffset(lp.handle, 60, "暂停")
          lp:buffset(lp.handle, 60, "无敌")
          PlayBGM({
            bgm = 0,
            time = 140,
            ID = 312,
            unit = lp.handle
          })
          lp:chat("哼----")
          ac.wait(13000, function()
            PlayGlobalSound(BGM_Len)
            PlayGlobalSound(Sound_Len_01)
            songtext({
              text = {
                {
                  starttime = 0.5,
                  str = "飞舞的雪花是星星的碎片 向着天空伸出双手"
                },
                {
                  starttime = 8.9,
                  str = "你亦感受到那交错的愿望吧"
                },
                {
                  starttime = 12.7,
                  str = "此刻一切尽在黑白之间",
                  time = 8
                },
                {
                  starttime = 44,
                  str = "轻轻呼出的白气"
                },
                {
                  starttime = 48,
                  str = "是想要传达的话语的轮廓"
                },
                {
                  starttime = 52,
                  str = "一定是由于那份温暖"
                },
                {
                  starttime = 55.7,
                  str = "让天空洒下一线光明"
                },
                {
                  starttime = 59.4,
                  str = "推动着自身的邂逅"
                },
                {
                  starttime = 63,
                  str = "那必定是梦寐以求的起端"
                },
                {
                  starttime = 67.1,
                  str = "全神贯注地盯着黑暗"
                },
                {
                  starttime = 71,
                  str = "孤独早已不存在"
                },
                {
                  starttime = 75,
                  str = "悲痛伤感沾湿的翅膀"
                },
                {
                  starttime = 79,
                  str = "向着彼此重叠的纯白"
                },
                {
                  starttime = 82.6,
                  str = "互相交托出"
                },
                {
                  starttime = 84.5,
                  str = "那展向未来的温柔勇气"
                },
                {
                  starttime = 90.4,
                  str = "心中悸动等候着"
                },
                {
                  starttime = 94.3,
                  str = "不为人知世界的黎明"
                },
                {
                  starttime = 98.1,
                  str = "带着光芒踏上旅途"
                },
                {
                  starttime = 100.2,
                  str = "明天因我而开始转动"
                },
                {
                  starttime = 105.8,
                  str = "纷纷雪花，是星的碎屑"
                },
                {
                  starttime = 109.7,
                  str = "向天体伸出双手"
                },
                {
                  starttime = 113,
                  str = "我亦相信着那交错的愿望"
                },
                {
                  starttime = 117,
                  str = "此刻一切万物尽在黑白之间",
                  time = 10
                }
              },
              color = "FFCCFFFF"
            })
            lp:chat("笨蛋")
            lp:chat("超级笨蛋", 0.8)
            lp:chat("不可理喻的笨蛋", 2.1)
            lp:chat("难以置信的笨蛋", 3.4)
            lp:chat("无法饶恕的笨蛋", 5.1)
            ac.wait(8000, function()
              PlayGlobalSound(Sound_Len_02)
              lp:chat("--真是的")
              lp:chat("就是因为你不管别人是谁你都动起刀子才会这样吧", 1.7)
              lp:chat("所以呢，你打算怎么样？", 8.4)
              lp:chat("就这样消失掉？", 10.7)
            end)
            ac.wait(21000, function()
              PlayGlobalSound(Sound_Len_03)
              u:chat("理所当然的吧")
              u:chat("本就没有再活着的理由了", 1.8)
              u:chat("既然没有人能杀死我", 5.1)
              u:chat("我也不想自杀", 7)
              u:chat("这样消散也算达成愿望了", 9.1)
            end)
            ac.wait(34000, function()
              PlayGlobalSound(Sound_Len_04)
              lp:chat("是吗")
              lp:chat("那么，就来做你最不想做的事吧", 1.3)
              lp:chat("你就作为我的Master", 5.6)
              lp:chat("在我消失前一直活下去吧", 8)
            end)
            ac.wait(44500, function()
              PlayGlobalSound(Sound_Len_05)
              lp:chat("不要以为那么容易就能消失哟")
            end)
            ac.wait(49000, function()
              u:setcolor(255, 255, 255, 255)
              PlayGlobalSound(Sound_Len_06)
              flashphoto({
                photo = "war3mapImported\\Photo_WLen.blp",
                timeout = 3,
                timehold = 4,
                timein = 3
              })
              u:chat("是是，无论什么时候都有事情要做的话")
              u:chat("本就没有再活着的理由了", 1.8)
              u:chat("像一条看门狗也心甘情愿了", 4.2)
            end)
            ac.wait(56000, function()
              Movie_Boolean = false
              PlayGlobalSound(Sound_Len_07)
              u:chat("作为代替守护雪原的天狼星么")
              u:chat("嘛，要负起的责任也不少呢", 3.6)
            end)
          end)
        end
      end)
    end)
  end,
  ["极死七夜"] = function(u, tg)
    PlayBGM({
      bgm = Nanaya_BGM,
      time = 35,
      ID = 29,
      unit = u.handle
    })
    local x, y = u:getxy()
    local x2, y2 = tg:getxy()
    local jd = AngleXY(x, y, x2, y2)
    local mj
    if u:hasdata("变异判定-噩梦志贵") then
      mj = u:createunit("u09B", x, y, jd)
    else
      mj = u:createunit("u08G", x, y, jd)
    end
    ShowUnit(u.handle, false)
    u:buffset(u.handle, 5, "无敌")
    u:buffset(u.handle, 3.5, "暂停")
    u:buffset(u.handle, 5, "绝对闪避")
    tg:buffset(u.handle, 7, "暂停")
    tg:buffset(u.handle, 7, "沉默")
    Movie_Boolean = true
    local g = CreateGroupLua()
    for _, xq in ac.selector():in_rangexy(x2, y2, 350):is_enemy(u.handle):ipairs() do
      xq = getunit(xq)
      xq:groupadd(g)
      xq:buffset(u.handle, 10, "暂停")
    end
    mj:setface(jd)
    local jd2 = jd + 180
    u:setdata("演出-极死七夜")
    ac.wait(100, function()
      tg:effectadd("war3mapImported\\blink_1.mdl", "overhead")
      PlayGlobalSound(SE031)
      ac.wait(250, function()
        if u:hasdata("变异判定-噩梦志贵") then
          Effectcreate("ATX\\[ATxNew]Purple_35.mdl", x, y, 0, 1.4)
        else
          Effectcreate("war3mapImported\\[Murasame]01 (4).mdl", x, y, 0, 1, 75)
        end
        PlayGlobalSound(Nanaya_G1)
        mj:animeact(29)
        u:chat("极死————")
      end)
      ac.wait(550, function()
        x2, y2 = PolarXY(x2, y2, 100, jd2)
        local jl = DistanceXY(x, y, x2, y2)
        local xx, yy = PolarXY(x, y, 100, jd)
        Effectcreate("ATx\\[ATxNew]Dust_10.mdl", xx, yy, 0, 0.5, 0, jd)
        mj:setcolor(255, 255, 255, 0)
        mj:animespeed(0)
        local cs = 0
        xx, yy = x, y
        local jl2 = jl / 12
        ac.loop(10, function(timer)
          cs = cs + 1
          xx, yy = PolarXY(xx, yy, jl2, jd)
          if cs ~= 12 then
            local txmj = u:createunit("u08H", xx, yy, jd)
            txmj:animeact(13)
            txmj:setcolor(255, 255, 255, 0)
            local cs2 = 0
            ac.loop(40, function(timer2)
              cs2 = cs2 + 1
              txmj:setcolor(75, 75, 255, (100 - 5 * cs2) / 100 * 255)
              if cs2 == 20 then
                txmj:remove()
                timer2:remove()
              end
            end)
          else
            Effectcreate("ATx\\[ATxNew]Hit_01.mdl", xx, yy, 0, 1, 75)
            mj:setxy(xx, yy)
            mj:setcolor(255, 255, 255, 255)
            mj:animespeed(1)
            mj:animeact(17)
            tg:setxy(xx, yy)
            ForGroupLuaNew(g, function(xq)
              xq:animeact("death")
              local cs2 = 0
              local xx2, yy2 = xq:getxy()
              ac.timer(5, 20, function()
                cs2 = cs2 + 1
                xx2, yy2 = PolarXY(xx2, yy2, 25, jd)
                xq:setxy(xx2, yy2)
                xq:setflyheight(14 * cs2)
              end)
            end)
            PlayGlobalSound(SE005)
            timer:remove()
          end
        end)
      end)
      ac.wait(750, function()
        local x, y = mj:getxy()
        Effectcreate("ATx\\[ATxNew]Black_01.mdl", x, y)
        mj:setcolor(255, 255, 255, 0)
        mj:animeact(29)
        mj:animespeed(2)
      end)
      ac.wait(1250, function()
        PlayGlobalSound(SE039)
        local x2, y2 = tg:getxy()
        mj:setxy(x2, y2)
        mj:setcolor(255, 255, 255, 255)
        mj:animespeed(0)
        if u:hasdata("变异判定-噩梦志贵") then
          Effectcreate("BTX\\[BTxNew]zhanji-red.mdl", x2, y2, 0, 1.5, 300, jd)
        else
          Effectcreate("ATx\\[ATxNew]Daoguang_14.mdl", x2, y2, 0, 1.5, 300, jd)
        end
        Effectcreate("ATx\\[ATxNew]Black_01.mdx", x2, y2, 0, 1, 325)
        ForGroupLuaNew(g, function(xq)
          xq:animespeed(0)
        end)
        flashphoto({
          photo = "war3mapImported\\Qiye_1.blp",
          timeout = 0.5,
          timehold = 1.5,
          timein = 1
        })
      end)
      ac.wait(1750, function()
        u:chat("七夜！")
        PlayGlobalSound(Nanaya_G2)
      end)
      ac.wait(2000, function()
        local x2, y2 = tg:getxy()
        mj:animespeed(1)
        x2, y2 = PolarXY(x2, y2, 150, jd)
        mj:setxy(x2, y2)
        mj:setface(jd)
      end)
      ac.wait(2500, function()
        local txsh = 100000 + 10000 * u:getlevel()
        PlayGlobalSound(Sound_Shiki_99)
        PlayGlobalSound(SE008)
        ForGroupLuaNew(g, function(xq)
          xq:setflyheight(0)
          xq:animespeed(1)
          xq:effectadd("war3mapImported\\Texiao_Xuebao.mdx")
          xq:effectadd("ATx\\[ATxNew]Blood_01.mdl", "head")
          xq:effectadd("ATx\\[ATxNew]Hit_01.mdx", "chest")
          local x3, y3 = xq:getxy()
          Effectcreate("ATx\\[ATxNew]Dust_01.mdl", x3, y3)
          if xq.handle ~= tg.handle then
            if xq:isboss() then
              LossHpUnit({
                u = u,
                tg = xq,
                damage = 0,
                perhp = 0,
                maxhp = 7,
                bj = "[生命损耗]极死七夜"
              })
              DamageUnit({
                bj = "极死七夜",
                unit = xq.handle,
                source = u.handle,
                damage = txsh + 0.01 * xq:getmaxhp(),
                level = 5,
                type = "物理",
                isvest = false,
                isattack = false,
                isnoarmor = false,
                element = "无"
              })
            elseif xq:iselite() then
              DamageUnit({
                bj = "极死七夜",
                unit = xq.handle,
                source = u.handle,
                damage = txsh + 0.01 * xq:getmaxhp(),
                level = 5,
                type = "物理",
                isvest = false,
                isattack = false,
                isnoarmor = false,
                element = "无"
              })
            else
              xq:kill(u.handle, true)
            end
          end
        end)
        if tg:isboss() then
          LossHpUnit({
            u = u,
            tg = tg,
            damage = 0,
            perhp = 0,
            maxhp = 7,
            bj = "[生命损耗]极死七夜"
          })
          DamageUnit({
            bj = "极死七夜",
            unit = tg.handle,
            source = u.handle,
            damage = txsh + 0.01 * tg:getmaxhp(),
            level = 5,
            type = "物理",
            isvest = false,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
        else
          tg:kill(u.handle, true)
        end
      end)
      ac.wait(3500, function()
        local zs = GetRandomInt(1, 5)
        if zs == 1 then
          PlayGlobalSound(NanayaYinxiao__1_u)
          u:chat("嘛")
          u:chat("就是这么回事吧？", 1.3)
          u:chat("既然人总有一死", 4.1)
          u:chat("那死在这里也没什么区别的吧", 6.1)
        end
        if zs == 2 then
          PlayGlobalSound(NanayaYinxiao__3_u)
          u:chat("知道要去哪里了吗？")
          u:chat("如果是下地狱的话", 2.9)
          u:chat("请代我向阎王问好", 4.7)
        end
        if zs == 3 then
          PlayGlobalSound(NanayaYinxiao__4_u)
          u:chat("处以斩刑")
          u:chat("要知道冥河之旅费——", 2.2)
          u:chat("亦是无用", 3.6)
        end
        if zs == 4 then
          PlayGlobalSound(NanayaYinxiao__5_u)
          u:chat("判决自奈落、翻山河、越大路而临")
          u:chat("从那阎王之帖来看", 5.4)
          u:chat("你的死期已经确定了", 8)
        end
        if zs == 5 then
          PlayGlobalSound(NanayaYinxiao__9_u)
          u:chat("不值一提")
          u:chat("来世再重来一遍吧", 2.3)
        end
      end)
      ac.wait(3500, function()
        Movie_Boolean = false
        local x, y = mj:getxy()
        u:setxy(x, y)
        ShowUnit(u.handle, true)
        Effectcreate("ATx\\[ATxNew]Black_01.mdx", x, y, 0, 1.5)
        mj:remove()
        u:select()
        u:setface(jd)
        u:deldata("演出-极死七夜")
        IssueImmediateOrder(u.handle, "stop")
      end)
    end)
  end,
  ["天下布武"] = function(u, tg)
    PlayGlobalSound(Tianxiabuwu)
    tg:buffset(u.handle, 51, "暂停")
    tg:buffset(u.handle, 15, "无敌")
    u:buffset(u.handle, 18, "无敌")
    u:buffset(u.handle, 15, "暂停")
    u:buffset(u.handle, 18, "绝对闪避")
    Movie_Boolean = true
    ac.wait(15000, function()
      Movie_Boolean = false
    end)
    ac.wait(12001, function()
      tg:clearbuff("无敌")
      tg:zsdamage(u.handle)
    end)
    local x, y = u:getxy()
    local x2, y2 = tg:getxy()
    u:chat("就让你命丧于此吧")
    u:chat("阻碍在孤霸王之道上的蝼蚁啊", 2.5)
    ac.wait(5500, function()
      ClearTextMessages()
      SendMsgAll("|cFF990000「|r|cFF991624天")
    end)
    ac.wait(6200, function()
      ClearTextMessages()
      SendMsgAll("|cFF990000「|r|cFF991624天|r|cFF992C49下|r")
    end)
    ac.wait(6500, function()
      ClearTextMessages()
      SendMsgAll("|cFF990000「|r|cFF991624天|r|cFF992C49下|r|cFF99426D布|r")
    end)
    ac.wait(6900, function()
      ClearTextMessages()
      SendMsgAll("|cFF990000「|r|cFF991624天|r|cFF992C49下|r|cFF99426D布|r|cFF995792武|r|cFF996DB6」|r")
    end)
    u:chat("孤乃", 8.2)
    u:chat("织田信长", 10)
    local jd = GetRandomAngle()
    local jd2 = tg:getface()
    Effectcreate("war3mapimported\\176.mdl", x2, y2, 5, 1.6, 250, jd)
    Effectcreate("war3mapimported\\176.mdl", x2, y2, 5, 1.6, 250, jd + 60)
    ac.wait(1000, function()
      local mj = u:createunit("u06H", x2, y2, 0)
      tg:animeact("death")
      mj:timetoremove(12)
      ac.wait(200, function()
        tg:animespeed(0)
        mj:animespeed(0)
      end)
      ac.wait(10500, function()
        tg:animespeed(1)
        mj:animespeed(1)
      end)
    end)
    ac.wait(2500, function()
      Effectcreate("war3mapImported\\[TX] (1057).mdl", x, y, 0, 4)
    end)
    ac.wait(5500, function()
      local jd3 = jd2 + 45
      local x3, y3 = PolarXY(x2, y2, 1000, jd3)
      Effectcreate("war3mapImported\\[TX] (514).mdl", x3, y3, 6, 1)
      Effectcreate("war3mapImported\\[TX] (780).mdl", x3, y3, 0, 2)
    end)
    ac.wait(6200, function()
      local jd3 = jd2 + 135
      local x3, y3 = PolarXY(x2, y2, 1000, jd3)
      Effectcreate("war3mapImported\\[TX] (514).mdl", x3, y3, 5.3, 1)
      Effectcreate("war3mapImported\\[TX] (780).mdl", x3, y3, 0, 2)
    end)
    ac.wait(6500, function()
      local jd3 = jd2 + 225
      local x3, y3 = PolarXY(x2, y2, 1000, jd3)
      Effectcreate("war3mapImported\\[TX] (514).mdl", x3, y3, 5, 1)
      Effectcreate("war3mapImported\\[TX] (780).mdl", x3, y3, 0, 2)
    end)
    ac.wait(6900, function()
      local jd3 = jd2 + 315
      local x3, y3 = PolarXY(x2, y2, 1000, jd3)
      Effectcreate("war3mapImported\\[TX] (514).mdl", x3, y3, 4.6, 1)
      Effectcreate("war3mapImported\\[TX] (780).mdl", x3, y3, 0, 2)
    end)
    ac.wait(8200, function()
      Effectcreate("war3mapImported\\[TX] (1357).mdl", x, y, 0, 2)
    end)
    ac.wait(11500, function()
      Effectcreate("war3mapImported\\[TX] (416).mdl", x2, y2, 0, 4)
    end)
    PlayBGM({
      bgm = 0,
      time = 50,
      ID = 12,
      unit = u.handle
    })
  end,
  ["克苏鲁的呼唤"] = function(u)
    ForGroupLuaNew(Group_PlayHero, function(xq)
      if xq:getshenxing() >= 51 then
        return
      end
    end)
    if Boolean_KesuluHuhuanzhong or Boolean_Jinselingyu then
      return
    end
    local sy = u.ownerid
    Boolean_KesuluHuhuanzhong = true
    FlashFog()
    u:sendmessage("|cFF009999你感觉被某种存在注视着……|r")
    local x, y = u:getxy()
    if u:hasdata("变异判定-恶魔附体") then
      Effectcreate("ATx\\[ATxNew]Black_04.mdx", x, y, 5, 2)
      Effectcreate("ATx\\[ATxNew]Cthulhu_02.mdx", x, y, 5, 2)
    end
    u:buffset(u.handle, 0.2, "无敌")
    if u:hasdata("变异判定-特莉波卡") or u:hasdata("变异判定-恶魔附体") then
    else
      u:buffset(u.handle, 0.2, "暂停")
    end
    u:buffset(u.handle, 0.2, "绝对闪避")
    local cs = 0
    ac.loop(100, function(timer)
      cs = cs + 1
      u:buffset(u.handle, 0.2, "无敌")
      if u:hasdata("变异判定-特莉波卡") or u:hasdata("变异判定-恶魔附体") then
      else
        u:buffset(u.handle, 0.2, "暂停")
      end
      u:buffset(u.handle, 0.2, "绝对闪避")
      if cs == 30 then
        Boolean_KesuluHuhuanzhong = false
        FlashFog()
        local b = true
        if u:hasdata("变异判定-恶魔附体") or u:hasdata("变异判定-阿比盖尔") then
          b = false
          Effectcreate("ATx\\[ATxNew]Cthulhu_01.mdx", x, y, 0, 2)
          if u:hasdata("变异判定-阿比盖尔") then
            u:changedata("全属性增幅", 0.025)
          else
            u:addallstats(10)
          end
          if u:getdata("阿比盖尔-疯狂程度") < 70 then
            u:changedata("阿比盖尔-疯狂程度", 10)
          end
          if not Weiyi[21] and u:ishasshw() and u:getdata("阿比盖尔-疯狂程度") >= 70 then
            Weiyi[21] = true
            u:reduceshw()
            MovieAct["光壳流溢的虚树"](u)
          else
            u:chat("父亲大人……")
            PlayGlobalSound(Sound_Abigaier_03)
          end
        end
        if u:hasdata("隐藏职业-无貌之人") then
          b = false
          if not u:hasdata("隐藏职业-无貌之人揭露") then
            u:setdata("隐藏职业-无貌之人揭露")
            ChangeValue(Damage_Touzhiwu, sy, 1)
            hideproshow(u.handle)
          end
        end
        if u:hasdata("特典-普罗维登斯的绅士") then
          b = false
        end
        if u:hasdata("变异判定-尤格索托斯") then
          b = false
        end
        if u:hasdata("变异判定-特莉波卡") then
          b = false
        end
        if u:hasdata("变异判定-源堡") then
          b = false
          u:addallstats(3)
          u:changedata("全属性增幅", 0.005)
        end
        if u:hasdata("变异判定-星之彩") then
          local lv = u:getdata("星之彩等级")
          if lv == 1 and u:getluckrandom(99) then
            u:sendmessage("|cFF6633FF星|r|cFF8044FF之|r|cFF9955FF彩|r|cFFB266FF进|r|cFFCC77FF阶|r")
            u:changedata("星之彩等级", 1)
            ChangeValue(Correction_Exp, sy, 0.025)
            u:changedata("全属性增幅", 0.0125)
            u:addallstats(15)
            u:uivar_change({
              keyname = "星之彩",
              keytype = "冥王栏",
              text = "|cFF6633FF星之彩|r\n|cFF6633FF一阶\n外域 星 唯一\n提升5%经验获取\n提升3.75%全属性\n提升30全属性|r",
              icon = "Mwx_Waiyu_Xingzhicai_01_15"
            })
          end
          if lv == 2 and u:getluckrandom(66) then
            u:sendmessage("|cFF6633FF星|r|cFF8044FF之|r|cFF9955FF彩|r|cFFB266FF进|r|cFFCC77FF阶|r")
            u:changedata("星之彩等级", 1)
            ChangeValue(Correction_Exp, sy, 0.025)
            u:changedata("全属性增幅", 0.0125)
            u:addallstats(15)
            local xg = 0
            local xiuzheng = 0
            ac.loop(3000, function()
              u:changedata("全属性效果提升", -xg)
              xg = 0.0025 * u:getstate("星变异")
              if u:getdata("星之彩等级") == 4 then
                xg = xg * 2
              end
              u:changedata("全属性效果提升", xg)
            end)
            u:uivar_change({
              keyname = "星之彩",
              keytype = "冥王栏",
              text = "|cFF6633FF星|r|cFF8C4CFF之|r|cFFB266FF彩|r\n|cFF6633FF一阶\n外域 星 唯一|r\n|cFFB266FF提升7.5%经验获取\n提升5%全属性\n提升45全属性\n提升[星变异*0.125%]全属性的数值效果|r",
              icon = "Mwx_Waiyu_Xingzhicai_03_15"
            })
          end
          if lv == 3 and u:getluckrandom(33) then
            u:changedata("星之彩等级", 1)
            ChangeValue(Correction_Exp, sy, 0.025)
            u:changedata("全属性增幅", 0.025)
            u:addallstats(55)
            SendMsgAll(u:getplayername() .. "|cFF6633FF被|r|cFF753DFF星|r|cFF8547FF之|r|cFF9452FF彩|r|cFFA35CFF所|r|cFFB366FF环|r|cFFC270FF绕|r|cFFD17AFF…|r|cFFE085FF…|r")
            u:uivar_change({
              keyname = "星之彩",
              keytype = "冥王栏",
              text = "|cFFFF6699星|r|cFFD959B2之|r|cFFB24CCC彩|r\n|cFF6633FF一阶\n外域 星 唯一|r\n|cFF7C42FF提升10%经验获取|r\n|cFF9250FF提升7.5%全属性|r\n|cFFA85FFF提升100全属性|r\n|cFFBD6DFF提升[星变异*0.25%]全属性的数值效果|r",
              icon = "NewIcon_Xingzhicai",
              ishasphoto = true
            })
          end
        end
        if u:hasdata("变异判定-海嗣化") then
          b = false
          u:sendmessage("|cFF009999你感受到了深海的呼唤……|r")
          u:changexueroutonghua(10)
        end
        if b then
          u:sendmessage("|cFF009999你感觉身体与精神处于崩溃边缘。|r")
          ChangeValue(DamageSystem_LwSs, sy, 1.25, 1)
          if u:hasdata("变异判定-吱吱") and u:isgirl() then
          else
            u:changemaxhp(-0.1 * u:getmaxhp())
          end
        end
        timer:remove()
      end
    end)
  end,
  ["光壳流溢的虚树"] = function(u)
    local x, y = u:getxy()
    local hero = u
    local sy = u.ownerid
    hero:buffset(hero.handle, 50, "无敌")
    ShowUnit(hero.handle, false)
    local u = hero:createunit("u093", x, y, 315)
    local jd = u:getface()
    hero:setplayername("|cFFFFCC33阿|r|cFFAAAA55比|r|cFF8E9F60盖|r|cFF397D82尔|r")
    NameID[sy] = "|cFFFFCC33阿|r|cFFAAAA55比|r|cFF8E9F60盖|r|cFF397D82尔|r"
    Movie_Boolean = true
    SetCameraTargetController(u.handle, 0, 0, false)
    FogEnable(false)
    FogMaskEnable(false)
    SetDayNightModels("Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdx", "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdx")
    DayNightRun = false
    do
      local g = GetUnitsOfTypeIdAllLua("o000")
      ForGroupLuaNew(g, function(xq)
        xq:remove()
      end)
      local g = GetUnitsOfTypeIdAllLua("o003")
      ForGroupLuaNew(g, function(xq)
        xq:remove()
      end)
    end
    ShowUnit(NPC_Molijiedian, false)
    ForGroupLuaNew(Group_Monster, function(xq)
      ShowUnit(xq.handle, false)
    end)
    ForGroupLuaNew(Group_PlayHero, function(xq)
      local sy2 = xq.ownerid
      ShowUnit(xq.handle, false)
      xq:buffset(hero.handle, 55, "绝对闪避")
      ShowUnit(Beibao[sy2], false)
    end)
    hero:buffset(hero.handle, 49, "暂停")
    do
      local cs = 0
      ac.loop(1000, function(timer)
        cs = cs + 1
        DayNightRun = false
        Movie_Boolean = true
        ForGroupLuaNew(Group_Monster, function(xq)
          ShowUnit(xq.handle, false)
          xq:animespeed(0)
          xq:buffset(hero.handle, 2, "暂停")
        end)
        if cs == 55 then
          ForGroupLuaNew(Group_Monster, function(xq)
            ShowUnit(xq.handle, true)
            xq:animespeed(1)
            xq:buffset(hero.handle, 1, "暂停")
          end)
          Movie_Boolean = false
          DayNightRun = true
          timer:remove()
        end
      end)
    end
    u:animeact("spell two")
    hero:chat("吾乃是禁断的秘钥——引导它之人！")
    PlayGlobalSound(Sound_Abigaier_09)
    PlayBGM({
      bgm = BGM_Abigaier_01,
      time = 110,
      ID = 23,
      unit = u.handle
    })
    do
      local txz = {
        "ATx\\[ATxNew]Cthulhu_16_01.mdl",
        "ATx\\[ATxNew]Cthulhu_16_02.mdl",
        "ATx\\[ATxNew]Cthulhu_16_03.mdl",
        "ATx\\[ATxNew]Cthulhu_16_04.mdl",
        "ATx\\[ATxNew]Cthulhu_16_05.mdl"
      }
      local yxz = {
        DemonHunterMissileHit1,
        DemonHunterMissileHit2,
        DemonHunterMissileHit3
      }
      do
        local jl = 75
        local jl1 = 700
        local cs1 = math.floor(jl1 / jl)
        local cs = 0
        local xx = x
        local yy = y
        local jd2 = jd
        ac.loop(100, function(timer)
          xx, yy = PolarXY(xx, yy, jl, jd2)
          Effectcreate(txz[GetRandomInt(1, 5)], xx, yy, 26 - 0.1 * cs, 1, 0, GetRandomAngle())
          Effectcreate("ATx\\[ATxNew]Cthulhu_01.mdl", xx, yy)
          cs = cs + 1
          if cs == cs1 then
            local mj = u:createunit("u095", xx, yy, GetRandomAngle())
            mj:timetoremove(38.5 - 0.1 * cs)
            Effectcreate("ATx\\[ATxNew]Cthulhu_07.mdl", xx, yy, 0, 5)
            u:playsound(Sound_Mugen_01__5_u)
            timer:remove()
          end
        end)
      end
      do
        local jl = 75
        local jl1 = 600
        local jl2 = 600
        local cs1 = math.floor(jl1 / jl)
        local cs2 = math.floor(jl2 / jl)
        cs2 = cs1 + cs2
        local xx = x
        local yy = y
        local jd2 = jd
        local cs = 0
        ac.loop(100, function(timer)
          if cs == 0 then
            jd2 = jd2 - 90
          end
          if cs == cs1 then
            jd2 = jd2 - 90
          end
          xx, yy = PolarXY(xx, yy, jl, jd2)
          Effectcreate(txz[GetRandomInt(1, 5)], xx, yy, 26 - 0.1 * cs, 1, 0, GetRandomAngle())
          Effectcreate("ATx\\[ATxNew]Cthulhu_01.mdl", xx, yy)
          cs = cs + 1
          if cs == cs2 then
            local mj = u:createunit("u095", xx, yy, GetRandomAngle())
            mj:timetoremove(31 - 0.1 * cs)
            Effectcreate("ATx\\[ATxNew]Cthulhu_07.mdl", xx, yy, 0, 5)
            u:playsound(Sound_Mugen_01__5_u)
            timer:remove()
          end
        end)
      end
      do
        local jl = 75
        local jl1 = 600
        local jl2 = 600
        local cs1 = math.floor(jl1 / jl)
        local cs2 = math.floor(jl2 / jl)
        cs2 = cs1 + cs2
        local xx = x
        local yy = y
        local jd2 = jd
        local cs = 0
        ac.loop(100, function(timer)
          if cs == 0 then
            jd2 = jd2 + 90
          end
          if cs == cs1 then
            jd2 = jd2 + 90
          end
          xx, yy = PolarXY(xx, yy, jl, jd2)
          Effectcreate(txz[GetRandomInt(1, 5)], xx, yy, 26 - 0.1 * cs, 1, 0, GetRandomAngle())
          Effectcreate("ATx\\[ATxNew]Cthulhu_01.mdl", xx, yy)
          cs = cs + 1
          if cs == cs2 then
            local mj = u:createunit("u095", xx, yy, GetRandomAngle())
            mj:timetoremove(31 - 0.1 * cs)
            Effectcreate("ATx\\[ATxNew]Cthulhu_07.mdl", xx, yy, 0, 5)
            timer:remove()
          end
        end)
      end
      do
        local jl = 75
        local jl1 = 300
        local jl2 = 1100
        local jl3 = 450
        local jl4 = 450
        local jl5 = 400
        local jl6 = 200
        local cs1 = math.floor(jl1 / jl)
        local cs2 = math.floor(jl2 / jl)
        local cs3 = math.floor(jl3 / jl)
        local cs4 = math.floor(jl4 / jl)
        local cs5 = math.floor(jl5 / jl)
        local cs6 = math.floor(jl6 / jl)
        cs2 = cs1 + cs2
        cs3 = cs2 + cs3
        cs4 = cs3 + cs4
        cs5 = cs4 + cs5
        cs6 = cs5 + cs6
        local xx = x
        local yy = y
        local jd2 = jd
        local cs = 0
        ac.loop(100, function(timer)
          if cs == 0 then
            jd2 = jd2 + 180
          end
          if cs == cs1 then
            jd2 = jd2 + 90
          end
          if cs == cs2 then
            jd2 = jd2 + 135
          end
          if cs == cs3 then
            jd2 = jd2 - 90
          end
          if cs == cs4 then
            jd2 = jd2 + 135
          end
          if cs == cs5 then
            jd2 = jd2 + 90
          end
          xx, yy = PolarXY(xx, yy, jl, jd2)
          Effectcreate(txz[GetRandomInt(1, 5)], xx, yy, 26 - 0.1 * cs, 1, 0, GetRandomAngle())
          Effectcreate("ATx\\[ATxNew]Cthulhu_01.mdl", xx, yy)
          cs = cs + 1
          if cs == cs6 then
            local mj = u:createunit("u095", xx, yy, GetRandomAngle())
            mj:timetoremove(31 - 0.1 * cs)
            Effectcreate("ATx\\[ATxNew]Cthulhu_07.mdl", xx, yy, 0, 5)
            timer:remove()
          end
        end)
      end
      do
        local jl = 75
        local jl1 = 300
        local jl2 = 1100
        local jl3 = 450
        local jl4 = 450
        local jl5 = 400
        local jl6 = 200
        local cs1 = math.floor(jl1 / jl)
        local cs2 = math.floor(jl2 / jl)
        local cs3 = math.floor(jl3 / jl)
        local cs4 = math.floor(jl4 / jl)
        local cs5 = math.floor(jl5 / jl)
        local cs6 = math.floor(jl6 / jl)
        cs2 = cs1 + cs2
        cs3 = cs2 + cs3
        cs4 = cs3 + cs4
        cs5 = cs4 + cs5
        cs6 = cs5 + cs6
        local xx = x
        local yy = y
        local jd2 = jd
        local cs = 0
        ac.loop(100, function(timer)
          if cs == 0 then
            jd2 = jd2 + 180
          end
          if cs == cs1 then
            jd2 = jd2 - 90
          end
          if cs == cs2 then
            jd2 = jd2 - 135
          end
          if cs == cs3 then
            jd2 = jd2 + 90
          end
          if cs == cs4 then
            jd2 = jd2 - 135
          end
          if cs == cs5 then
            jd2 = jd2 - 90
          end
          u:playsound(yxz[GetRandomInt(1, 3)])
          xx, yy = PolarXY(xx, yy, jl, jd2)
          Effectcreate(txz[GetRandomInt(1, 5)], xx, yy, 26 - 0.1 * cs, 1, 0, GetRandomAngle())
          Effectcreate("ATx\\[ATxNew]Cthulhu_01.mdl", xx, yy)
          cs = cs + 1
          if cs == cs6 then
            local mj = u:createunit("u095", xx, yy, GetRandomAngle())
            mj:timetoremove(31 - 0.1 * cs)
            Effectcreate("ATx\\[ATxNew]Cthulhu_07.mdl", xx, yy, 0, 5)
            u:playsound(Sound_Mugen_01__5_u)
            timer:remove()
          end
        end)
      end
    end
    ac.wait(4500, function()
      ac.timer(1500, 15, function()
        local xx, yy = PolarXY(x, y, GetRandomReal(0, 1800), GetRandomAngle())
        Effectcreate("ATx\\[ATxNew]Cthulhu_12.mdl", xx, yy, 0, GetRandomReal(1, 3))
        u:playsound(LightningBolt)
      end)
      do
        local xx, yy = PolarXY(x, y, 675, jd)
        local mj = u:createunit("u094", xx, yy, jd + 180)
        mj:animeact("birth")
        ac.wait(1000, function()
          mj:animeact("stand")
          PlayGlobalSound(Sound_Sanae_03)
          Effectcreate("ATx\\[ATxNew]Dust_03.mdl", xx, yy, 0, 3)
          Effectcreate("ATx\\[ATxNew]Dust_33.mdl", xx, yy, 0, 3)
          Effectcreate("ATx\\[ATxNew]Dust_01.mdl", xx, yy, 0, 3)
        end)
        ac.wait(2000, function()
          PlayGlobalSound(Sound_Abigaier_07)
          u:chat("吾可以感知到门之所在，而汝，无从知晓")
        end)
        ac.wait(4000, function()
          local dx, dy = PolarXY(x, y, 500, jd)
          IssuePointOrder(u.handle, "move", dx, dy)
        end)
        ac.wait(8000, function()
          PlayGlobalSound(Sound_Abigaier_03)
          u:chat("父亲大人……")
        end)
        ac.wait(12000, function()
          PlayGlobalSound(Sound_Abigaier_10)
          u:animeact("spell one")
          u:chat("开启吧")
        end)
        ac.wait(13000, function()
          u:playsound(Sound_Mugen_01__4_u)
          u:animeact("spell one")
          u:chat("门啊")
          local dx, dy = PolarXY(x, y, 675, jd)
          local tx = Effectcreate("ATx\\[ATxNew]ShockBoom_07.mdl", dx, dy, -1, 3)
          ac.wait(500, function()
            SetEffectActSpeed(tx, 0)
            ac.wait(1500, function()
              SetEffectActSpeed(tx, 1)
              DestroyEffectLua(tx)
            end)
          end)
        end)
        ac.wait(13500, function()
          u:animespeed(0)
        end)
        ac.wait(15000, function()
          mj:kill()
          u:animespeed(1)
          local dx, dy = PolarXY(x, y, 675, jd)
          u:playsound(Sound_Mugen_01__5_u)
          Effectcreate("ATx\\[ATxNew]ShockBoom_05.mdl", dx, dy, 0, 4)
          Effectcreate("ATx\\[ATxNew]Cthulhu_11.mdl", dx, dy, 0, 4)
          Effectcreate("ATx\\[ATxNew]Cthulhu_02.mdl", dx, dy, 10, 4)
        end)
        ac.wait(16000, function()
          mj:remove()
          local dx, dy = PolarXY(x, y, 675, jd)
          IssuePointOrder(u.handle, "move", dx, dy)
        end)
        ac.wait(18000, function()
          PlayGlobalSound(Sound_Abigaier_51)
          u:chat("Ygnaiih")
          local dx, dy = u:getxy()
          local tx = Effectcreate("ATx\\[ATxNew]Black_15.mdl", dx, dy, -1)
          local cs = 0
          local size = 0
          ac.loop(200, function(timer)
            cs = cs + 1
            size = size + 0.2
            SetEffectSize(tx, 1 + size)
            if cs == 60 then
              DestroyEffectLua(tx)
              timer:remove()
            end
          end)
        end)
        ac.wait(18500, function()
          PlayGlobalSound(Sound_Abigaier_72)
          u:effectadd("ATx\\[ATxNew]Light_17.mdl", "overhead", 1)
        end)
        ac.wait(19000, function()
          PlayGlobalSound(Sound_Abigaier_61)
          local dx, dy = u:getxy()
          Effectcreate("ATx\\[ATxNew]Colour_04.mdl", dx, dy, 2, 2)
        end)
        ac.wait(20000, function()
          u:chat("Ygnaiih Thflthkh’ngha")
        end)
        ac.wait(22200, function()
          PlayGlobalSound(Sound_Abigaier_52)
          u:chat("吾之手中持白银之钥")
        end)
        ac.wait(23500, function()
          PlayGlobalSound(Sound_Abigaier_62)
          CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 2.99, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0)
        end)
        ac.wait(24500, function()
          PlayGlobalSound(Sound_Abigaier_53)
          u:chat("自虚无中显现，以您的指尖相触……")
        end)
        ac.wait(26500, function()
          PlayGlobalSound(Sound_Abigaier_63)
          CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 1.0, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0.0)
          local dx, dy = u:getxy()
          Effectcreate("ATx\\[ATxNew]Purple_28.mdl", dx, dy, 7, 10)
          for i = 1, 6 do
            Effectcreate("ATx\\[ATxNew]Purple_08.mdl", dx, dy, 7, 8, 0, i * 60)
          end
        end)
        ac.wait(27500, function()
          PlayGlobalSound(Sound_Abigaier_64)
        end)
        ac.wait(28000, function()
          u:chat("吾之父神啊")
        end)
        ac.wait(28500, function()
          PlayGlobalSound(Sound_Abigaier_65)
        end)
        ac.wait(30000, function()
          PlayGlobalSound(Sound_Abigaier_54)
          u:chat("吾将化身寄宿您神髓的现世之身")
        end)
        ac.wait(30500, function()
          PlayGlobalSound(Sound_Abigaier_67)
          local dx, dy = u:getxy()
          for i = 1, 12 do
            local xx, yy = PolarXY(dx, dy, 200, 30 * i)
            Effectcreate("ATx\\[ATxNew]Purple_44.mdl", xx, yy, 0, 2, 0, i * 30)
          end
          ac.wait(500, function()
            for i = 1, 12 do
              local xx, yy = PolarXY(dx, dy, 400, 30 * i)
              Effectcreate("ATx\\[ATxNew]Purple_44.mdl", xx, yy, 0, 2.5, 0, i * 30)
            end
          end)
          ac.wait(1000, function()
            for i = 1, 12 do
              local xx, yy = PolarXY(dx, dy, 600, 30 * i)
              Effectcreate("ATx\\[ATxNew]Purple_44.mdl", xx, yy, 0, 3, 0, i * 30)
            end
          end)
          ac.wait(1500, function()
            for i = 1, 12 do
              local xx, yy = PolarXY(dx, dy, 800, 30 * i)
              Effectcreate("ATx\\[ATxNew]Purple_44.mdl", xx, yy, 0, 3.5, 0, i * 30)
            end
          end)
          ac.wait(2000, function()
            for i = 1, 12 do
              local xx, yy = PolarXY(dx, dy, 1000, 30 * i)
              Effectcreate("ATx\\[ATxNew]Purple_44.mdl", xx, yy, 0, 4, 0, i * 30)
            end
          end)
        end)
        ac.wait(32000, function()
          local dx, dy = u:getxy()
          Effectcreate("ATx\\[ATxNew]Purple_38.mdl", dx, dy, 0, 6)
          for i = 1, 12 do
            local xx, yy = PolarXY(dx, dy, 850, 30 * i)
            Effectcreate("ATx\\[ATxNew]Purple_38.mdl", xx, yy, 1, 6, 0, i * 30)
          end
          CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 1.0, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0)
        end)
        ac.wait(33000, function()
          ForGroupLuaNew(Group_Monster, function(xq)
            if xq:isboss() then
              LossHpUnit({
                u = u,
                tg = xq,
                damage = 0,
                perhp = 0,
                maxhp = 25,
                bj = "[生命损耗]光壳流溢的虚树"
              })
            else
              xq:kill(hero.handle, true)
            end
          end)
          u:setxy(-5000, 11800)
          hero:setxy(-5000, 11800)
          u:setface(270)
          SetSkyModel("Environment\\Sky\\FoggedSky\\FoggedSky.mdl")
          u:setflyheight(600)
          local dx, dy = u:getxy()
          for i = 1, 12 do
            Effectcreate("ATx\\[ATxNew]Arround_14.mdl", dx, dy, 7, 2, 0, i * 30)
          end
          for i = 1, 3 do
            Effectcreate("ATx\\[ATxNew]Arround_07.mdl", dx, dy, 7, 2, 800)
          end
        end)
        ac.wait(35000, function()
          SetDayNightModels("", "")
          CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 1.0, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0)
          ResetToGameCamera(0)
          CameraSetupApplyForceDuration(Glo.gg_cam_Camera_004, true, 0)
          PlayGlobalSound(Sound_Abigaier_55)
          PlayGlobalSound(Sound_Abigaier_68)
          u:chat("跨越蔷薇的沉睡，抵达穷极之门吧！")
        end)
        ac.wait(36000, function()
          local cs = 0
          ac.timer(100, 89, function()
            cs = cs + 1
            if cs <= 50 then
              CameraSetupApplyForceDuration(Glo.gg_cam_Camera_005, true, 5 - 0.1 * cs)
            else
              CameraSetupApplyForceDuration(Glo.gg_cam_Camera_005, true, 0)
            end
          end)
        end)
        ac.wait(39000, function()
          PlayGlobalSound(Sound_Abigaier_56)
          u:chat("|cFF330099『Qliphoth Rhizome』|r")
        end)
        ac.wait(43000, function()
          CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 1.0, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0)
        end)
        ac.wait(45000, function()
          SetDayNightModels("Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdx", "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdx")
          local dx, dy = u:getxy()
          u:remove()
          u = hero
          hero:setxy(dx, dy)
          ShowUnit(hero.handle, true)
          Effectcreate("ATx\\[ATxNew]Cthulhu_07.mdl", dx, dy, 0, 2)
          CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 1.0, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0)
          ResetToGameCamera(0)
          CameraSetupApplyForceDuration(Glo.gg_cam_Camera_0, true, 0)
          World_Cthulhu = true
          FogEnable(true)
          FogMaskEnable(true)
          ForGroupLuaNew(Group_PlayHero, function(xq)
            local sy2 = xq.ownerid
            ShowUnit(xq.handle, true)
            ShowUnit(Beibao[sy2], true)
          end)
          ShowUnit(NPC_Molijiedian, true)
          AdvanceGet["阿比盖尔"](u)
        end)
      end
    end)
  end,
  ["昆仑现世"] = function(u)
    ac.wait(5000, function()
      shigecolortext({
        strz = {
          {
            str = "昆仑之虚，帝之下都，玉为槛，兽为守，",
            time = 0,
            showtime = 3,
            fadetime = 30
          },
          {
            str = "天地之枢，通天之路，自此始。",
            time = 3,
            showtime = 3,
            fadetime = 30
          },
          {
            str = "经纪山川，蹈腾昆仑，排阊阖，沦天门，",
            time = 6,
            showtime = 3,
            fadetime = 30
          },
          {
            str = "参天地玄伏，造昆仑之镜。",
            time = 9,
            showtime = 3,
            fadetime = 30
          },
          {
            str = "天不容，地不受，日月不敢偷照耀，",
            time = 12,
            showtime = 3,
            fadetime = 30
          },
          {
            str = "开鉴心智，导通天机，悟人之道。",
            time = 15,
            showtime = 3,
            fadetime = 30
          }
        },
        colorstart = "00FFFFFF",
        colorend = "FFFFCC00"
      })
    end)
    SetTimeOfDay(12)
    PlayBGM({
      bgm = BGM_Thing_Klj1,
      time = 90,
      ID = 131,
      unit = u.handle
    })
    u:sendmessage("|cFFFFCC33这是......|r")
    ac.wait(3000, function()
      u:sendmessage("|cFFFFCC33你手持这件古物时，一股神秘的能量涌入身体，让你感到一种强烈的联系和契合......|r")
    end)
    ac.wait(6000, function()
      u:sendmessage("|cFFFFCC33你闭上眼睛，沉浸在这种感觉中......|r")
    end)
    ac.wait(5000, function()
      local x, y = u:getxy()
      ac.wait(18000, function()
        u:addskill("A1JG")
      end)
      ac.timer(250, 30, function()
        local jd = GetRandomAngle()
        local jl = GetRandomReal(500, 1000)
        local x2, y2 = PolarXY(x, y, jl, jd)
        local tx = Effectcreate("Abilities\\Spells\\NightElf\\FaerieFire\\FaerieFireTarget.mdl", x2, y2, -1, GetRandomReal(2, 4), 2500)
        local cs = 0
        local jdc = 3
        local jlc = 4
        local hec = 10
        local he = 2500
        ac.loop(30, function(timer)
          cs = cs + 1
          jd = jd + jdc
          jl = jl - jlc
          he = he - hec
          x, y = u:getxy()
          x2, y2 = PolarXY(x, y, jl, jd)
          SetEffectXY(tx, x2, y2)
          if jl <= 200 then
            jl = 200
          end
          if he <= 0 then
            he = 0
          end
          SetEffectHeight(tx, he)
          if cs == 600 then
            DestroyEffectLua(tx)
            Effectcreate("war3mapImported\\3.11.348 (2).mdl", x2, y2, 0, GetRandomReal(2, 4), 100, 0, 0, 0, 0.25)
            timer:remove()
          end
        end)
      end)
      ac.wait(5000, function()
        ac.timer(150, 40, function()
          local jl = GetRandomReal(500, 1000)
          local jd = GetRandomAngle()
          x, y = u:getxy()
          local x2, y2 = PolarXY(x, y, jl, jd)
          local dx = GetRandomReal(1, 2)
          Effectcreate("war3mapImported\\3.11.348 (3).mdl", x2, y2, 0, dx)
          local tx = Effectcreate("war3mapImported\\3.11.348 (4).mdl", x2, y2, -1, dx, 0, GetRandomAngle())
          ac.wait(25000, function()
            DestroyEffectLua(tx)
            Effectcreate("Objects\\Spawnmodels\\NightElf\\NEDeathSmall\\NEDeathSmall.mdl", x2, y2, 0, dx)
          end)
        end)
        local txz = {
          "war3mapImported\\3.12.723 (2).mdl",
          "war3mapImported\\3.12.723 (3).mdl",
          "war3mapImported\\3.12.723 (4).mdl",
          "war3mapImported\\3.12.723 (5).mdl"
        }
        ac.timer(250, 50, function()
          local jl = GetRandomReal(0, 100)
          local jd = GetRandomAngle()
          x, y = u:getxy()
          local x2, y2 = PolarXY(x, y, jl, jd)
          local dx = GetRandomReal(1.25, 2.75)
          Effectcreate("war3mapImported\\3.12.723 (1).mdl", x2, y2, 0, 1)
          local tx = Effectcreate(txz[GetRandomInt(1, 4)], x2, y2, -1, dx, 0, GetRandomAngle())
          ac.wait(25000, function()
            SetEffectSize(tx, 0.01)
            DestroyEffectLua(tx)
            Effectcreate("war3mapImported\\3.12.723 (1).mdl", x2, y2, 0, 1)
          end)
        end)
      end)
    end)
  end,
  ["无垢识.空之境界"] = function(u)
    local x, y = u:getxy()
    local hero = u
    local sy = u.ownerid
    hero:buffset(hero.handle, 27, "无敌")
    hero:buffset(hero.handle, 25, "暂停")
    hero:buffset(hero.handle, 27, "绝对闪避")
    ShowUnit(hero.handle, false)
    Effectcreate("AATX\\[Sakura]03_CC.mdl", x, y, 1)
    hero:deldata("两仪式-痛觉残留")
    ModelReplace({
      u = u,
      model = "HERO\\214_new.mdl",
      modelsize = 1.2,
      modelname = "|cFFFFCCFF根|r|cFFFFA6FF源|r|cFFFF80FF式|r",
      modelicon = "214_new_portrait.tga"
    })
    local angle = u:getface()
    local u = hero:createunit("u0B4", x, y, angle)
    NameID[sy] = "|cFFFF66FF两|r|cFFFF8CFF仪|r|cFFFFB2FF式|r"
    hero:setplayername(NameID[sy])
    Movie_Boolean = true
    FogEnable(false)
    FogMaskEnable(false)
    SetDayNightModels("Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdx", "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdx")
    DayNightRun = false
    local xx, yy = PolarXY(x, y, 1000, angle)
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:setdata("无垢识空之境界释放中")
      xq:buffset(hero.handle, 30, "无敌")
    end)
    ac.wait(1000, function()
      PanCameraToTimed(xx, yy, 0)
    end)
    local cs = 0
    ac.loop(100, function(timer)
      cs = cs + 1
      ForGroupLuaNew(Group_Monster, function(xq)
        xq:buffset(xq.handle, 0.2, "暂停")
      end)
      if cs == 230 then
        timer:remove()
      end
    end)
    PlayGlobalSound(Sound_214_96)
    Effectcreate("AATX\\[AATxNew]Pink11.mdl", x, y)
    SetTimeOfDay(5.99)
    ac.wait(1000, function()
      PlayGlobalSound(Sound_215_11)
      hero:chat("天已破晓")
    end)
    ac.wait(2700, function()
      hero:chat("该是告别之时")
    end)
    ac.wait(3000, function()
      u:animeact(15)
    end)
    ac.wait(4500, function()
      PlayGlobalSound(SE032)
      Effectcreate("AATX\\[AATxNew]Pink15.mdl", x, y)
    end)
    ac.wait(5000, function()
      PlayGlobalSound(Sound_215_12)
      hero:chat("恕我失礼")
    end)
    ac.wait(6000, function()
      PlayGlobalSound(Sound_214_97)
      hero:chat("全部斩杀")
      Effectcreate("AATX\\[AATxNew]Pink22.mdl", xx, yy, 0, 3)
      ForGroupLuaNew(Group_Monster, function(xq)
        xq:setxy(xx, yy)
        xq:animespeed(0)
        xq:eliteschange(-100)
        xq:clearbuff()
        xq:buffset(xq.handle, 10, "无敌")
      end)
      u:setcolor(255, 255, 255, 0)
      Effectcreate("AATX\\[Sakura]03_CC.mdl", x, y)
    end)
    ac.wait(6500, function()
      local dx, dy = PolarXY(x, y, -300, angle)
      u:setxy(dx, dy)
      local tm = 0
      ac.loop(10, function(timer)
        tm = tm + 2.55
        u:setcolor(255, 255, 255, tm)
        if 255 <= tm then
          timer:remove()
        end
      end)
      u:animeact(16)
      unitmove({
        unit = u.handle,
        time = 2,
        distance = 1000,
        angle = angle,
        loops = {
          {
            looptime = 0.03,
            func = function(dx, dy)
              Effectcreate("AATX\\[Sakura]06.mdl", dx, dy)
            end
          }
        }
      })
    end)
    ac.wait(8000, function()
      PlayGlobalSound(Sound_215_32)
      u:chat("直死————")
      SetTimeOfDay(6.01)
      ac.wait(500, function()
        CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 0.5, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 60.0, 100.0, 0)
        PlayGlobalSound(Sound_Katana_23)
        Effectcreate("AATX\\[AATxNew]Katana01.mdl", xx, yy, 0, 1, 90, angle, 0, 0, 0.5)
        local dx, dy = PolarXY(x, y, 1500, angle)
        u:setxy(dx, dy)
        u:animeact(18)
      end)
      ac.wait(600, function()
        PlayGlobalSound(Sound_Katana_23)
      end)
      ac.wait(2500, function()
        PlayGlobalSound(Sound_215_33)
        hero:chat("在两仪之间消散吧")
      end)
    end)
    ac.wait(11500, function()
      local dx, dy = PolarXY(x, y, 1500, angle)
      Effectcreate("war3mapImported\\bbb.mdx", xx, yy)
    end)
    ac.wait(12000, function()
      u:animespeed(0)
    end)
    ac.wait(13000, function()
      PlayGlobalSound(Sound_215_30)
      u:chat("一切皆为梦——")
      flashphoto({
        photo = "war3mapImported\\Pho_214.blp",
        timeout = 2,
        timehold = 3,
        timein = 2,
        notchangetime = true
      })
      ac.wait(3000, function()
        PlayGlobalSound(Sound_215_31)
        u:chat("此乃余韵之花啊")
        ac.wait(1000, function()
          PlayGlobalSound(Sound_214_98)
          PlayGlobalSound(SE15401)
          Effectcreate("AATX\\[Sakura]03_CC.mdl", xx, yy, 3, 10)
          Effectcreate("AATX\\[AATxNew]Katana16_C.mdl", xx, yy, 0, 5, 200, GetRandomAngle(), 0, 0, 0.5)
          ForGroupLuaNew(Group_Monster, function(xq)
            xq:animespeed(1)
            xq:clearbuff("无敌")
            if xq:isboss() then
              xq:zsdamage(hero.handle)
            else
              xq:kill(hero.handle, true)
            end
          end)
        end)
      end)
    end)
    ac.wait(23000, function()
      u:setcolor(255, 255, 255, 255)
      ShowUnit(u.handle, false)
      FogEnable(true)
      FogMaskEnable(true)
      Movie_Boolean = false
      DayNightRun = true
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:deldata("无垢识空之境界释放中")
      end)
      ac.wait(1, function()
        hero:select()
      end)
      hero:sethp(100, true)
      Hero_Tili[sy] = Hero_Tili_Max[sy]
      ShowUnit(hero.handle, true)
      local dx, dy = u:getxy()
      hero:setxy(dx, dy)
      Effectcreate("AATX\\[Sakura]03_CC.mdl", dx, dy, 1)
      AdvanceGet["根源式"](hero)
    end)
    ac.wait(25000, function()
      PlayGlobalSound(Sound_215_10)
      hero:chat("对您来说，我只不过是短暂的梦境吧")
    end)
    ac.wait(28000, function()
      hero:chat("虽然我是不该存在的幻象——")
    end)
    ac.wait(31500, function()
      hero:chat("但确实有东西留存了下来")
    end)
    ac.wait(35000, function()
      hero:chat("谢谢您，不知名的温柔人儿")
    end)
    ac.wait(39000, function()
      hero:chat("哪怕总有一天我将消失……")
    end)
    ac.wait(41700, function()
      hero:chat("这把刀也会继续留在此处。")
      u:remove()
    end)
    StopSoundBJ(BGM_214_1, false)
    local t
    if GetRandom100(50) then
      t = 205
      PlayBGM({
        bgm = BGM_214_2,
        time = 205,
        ID = 33,
        unit = u.handle
      })
      for i = 1, 4 do
        local mj = hero:createunit("u016", xx, yy)
        mj:timetoremove(205)
      end
      songtext({
        text = {
          {
            starttime = 107,
            str = "正因为早已知晓能够迎空翱翔"
          },
          {
            starttime = 115,
            str = "才会于展翅之时害怕得忘记了风向"
          },
          {
            starttime = 122,
            str = "即使忘却 去向何方"
          },
          {
            starttime = 126,
            str = "远处可见的的那海市蜃楼"
          },
          {
            starttime = 130,
            str = "总有一天 也会在惴惴不安中"
          },
          {
            starttime = 133.6,
            str = "映照出两人的未来"
          },
          {
            starttime = 141.8,
            str = "当两颗无依无靠的心相互依偎之时"
          },
          {
            starttime = 149.5,
            str = "真正的悲伤将会展翅翱翔"
          },
          {
            starttime = 156.6,
            str = "即使忘却 身处暗夜"
          },
          {
            starttime = 160,
            str = "仿佛梦见了白昼的幻影"
          },
          {
            starttime = 164.9,
            str = "终究定会坠向 光芒之中",
            time = 10
          }
        },
        color = "FFFF99FF"
      })
    else
      t = 120
      PlayBGM({
        bgm = BGM_214_3,
        time = 120,
        ID = 33,
        unit = u.handle
      })
      for i = 1, 4 do
        local mj = hero:createunit("u016", xx, yy)
        mj:timetoremove(120)
      end
    end
    hero:settimedata("根源式复活", t)
  end
}
MovieAct["爱憎之园"] = function(u)
  local sy = u.ownerid
  local soul_enough = u:getdata("孔瑞丽-灵魂碎片") >= 5 or u:hasdata("孔涛罗-复仇成功")
  Movie_Boolean = true
  
  local function kongruili_get_myth()
    if u:hasdata("神话判定-孔瑞丽") then
      return
    end
    u:changedata("灵魂变异数量", 1)
    u:setdata("神话判定-孔瑞丽")
    u:changedata("全属性增幅", 0.33)
    u:addallstats(666)
    local damage_bonus = 0
    local melee_bonus = 0
    ac.loop(3000, function()
      ChangeValue(DamageSystem_Shjc, sy, 0.1 * -damage_bonus)
      ChangeValue(Correction_Jzsh, sy, 0.1 * -melee_bonus)
      local mutation_count = u:getstate("机械变异") + u:getstate("战士变异")
      damage_bonus = 0.66 * mutation_count
      melee_bonus = 0.33 * mutation_count
      ChangeValue(Correction_Jzsh, sy, 0.1 * melee_bonus)
      ChangeValue(DamageSystem_Shjc, sy, 0.1 * damage_bonus)
    end)
    NameID[sy] = "|cFFF1CCC3孔|r|cFFF4BFD2瑞|r|cFFF8B2E1丽|r"
    u:setplayername("|cFFF1CCC3孔|r|cFFF4BFD2瑞|r|cFFF8B2E1丽|r")
    ChatIcon[sy] = "Chat_Krl4.tga"
    u:uivar_change({
      keyname = "孔瑞丽",
      keytype = "传奇栏",
      icon = "Cq_Ktl_Ruili03.tga",
      size_h = 0.75,
      dx = 6,
      text = "|cFFF1CCC3孔|r|cFFF4BFD2瑞|r|cFFF8B2E1丽|r\n|cFFFF3366[神话]|r\n|cFFF1CCC3唯一 灵魂 灵魂|r\n|cFFF8B2E1提升33%全属性\n提升666全属性|r\n|cFFF1CCC3铭记之铃|r\n|cFFF8B2E1提升[(机械变异+战士变异)*3.3%]近战伤害\n提升[(机械变异+战士变异)*6.6%]伤害加成|r\n|cFFF1CCC3泪尽铃音响|r\n|cFFF8B2E1彻底死亡时复活,冷却188秒\n触发决死效果时,获得1秒绝对闪避|r",
      ishasphoto = true,
      smallicon = "Cq_Ktl_Ruili03_S.tga"
    })
  end
  
  local whitephoto = class.panel:builder({
    parent = OriginPanel,
    x = 0,
    y = 0,
    w = 1920,
    h = 850,
    normal_image = "White.tga"
  })
  whitephoto:set_alpha(0)
  PlayGlobalSound(BGM_Kongtaoluo_01)
  SetSoundVolumeBJ(BGM_Kongtaoluo_01, 50.0)
  PlayGlobalSound(Sound_Ktl_Lhj02)
  flashphoto({
    photo = "Ph_Ktl_02.tga",
    timeout = 4,
    timehold = 3,
    timein = 3
  })
  ForGroupLuaNew(Group_PlayHero, function(xq)
    xq:buffset(u.handle, 20, "绝对闪避")
  end)
  NPCChat({
    name = "|cFF616368刘|r|cFF777B7C豪|r|cFF8E9291军|r",
    chaticon = "Chat_Lhj.tga",
    chattext = {
      {
        text = "|cFF777B7C哈哈哈……哈哈哈！|r",
        time = 0.9
      },
      {
        text = "|cFF777B7C这副落魄的样子真适合你啊，涛罗|r",
        time = 4.9
      },
      {
        text = "|cFF777B7C剑内寄宿着的荣耀，维系着今日与明日的生命|r",
        time = 10.1
      },
      {
        text = "|cFF777B7C全部都奉献给瑞丽了吗|r",
        time = 13.6
      }
    }
  })
  ac.wait(17000, function()
    ac.wait(2000, function()
      PlayGlobalSound(Sound_Ktl_Lhj03)
    end)
    NPCChat({
      name = "|cFF3F3F49孔|r|cFF696C6F涛|r|cFF939896罗|r",
      chaticon = "Chat_Ktl2.tga",
      chattext = {
        {
          text = "|cFF696C6F……|r",
          time = 0
        },
        {
          text = "|cFF696C6F刘！！|r",
          time = 2
        }
      }
    })
  end)
  ac.wait(19500, function()
    PlayGlobalSound(Sound_Ktl_Lhj04)
    local alpha = 0
    ac.loop(25, function(timer)
      alpha = alpha + 12
      whitephoto:set_alpha(alpha)
      if 250 <= alpha then
        timer:remove()
      end
    end)
  end)
  if not soul_enough then
    PlayBGM({
      bgm = 0,
      time = 200,
      ID = 182,
      unit = u.handle
    })
    ac.wait(23000, function()
      local alpha = 255
      ac.loop(25, function(timer)
        alpha = alpha - 3
        whitephoto:set_alpha(alpha)
        if alpha <= 10 then
          whitephoto:set_alpha(alpha)
          whitephoto:destroy()
          timer:remove()
        end
      end)
    end)
    ac.wait(28000, function()
      SendMsgAll(u:getplayername() .. "|cFF3F3F49复仇失败……死于[刘豪军]之手|r", 60)
      PlayGlobalSound(Sound_Ktl_Lhj05)
      NPCChat({
        name = "|cFF616368刘|r|cFF777B7C豪|r|cFF8E9291军|r",
        chaticon = "Chat_Lhj.tga",
        chattext = {
          {
            text = "|cFF777B7C这样就好|r",
            time = 0
          },
          {
            text = "|cFF777B7C你的血与肉乃至魂魄|r",
            time = 2
          },
          {
            text = "|cFF777B7C都会在这里被蚕食殆尽不留一丝痕迹|r",
            time = 4.6
          },
          {
            text = "|cFF777B7C在瑞丽的面前|r",
            time = 7.4
          }
        }
      })
      ac.wait(10000, function()
        PlayGlobalSound(Sound_Ktl_Lhj06)
        NPCChat({
          name = "|cFF616368刘|r|cFF777B7C豪|r|cFF8E9291军|r",
          chaticon = "Chat_Lhj.tga",
          chattext = {
            {
              text = "|cFF777B7C你已经不需要在做人了|r",
              time = 0
            },
            {
              text = "|cFF777B7C只活在瑞丽的记忆中就好|r",
              time = 3.2
            },
            {
              text = "|cFF777B7C如果是那样的话……|r",
              time = 7.1
            },
            {
              text = "|cFF777B7C我倒还可以原谅你，涛罗……|r",
              time = 9.1
            }
          }
        })
      end)
      ac.wait(20000, function()
        Movie_Boolean = false
        local volume = 50
        ac.timer(100, 25, function()
          volume = volume + 2
          SetSoundVolumeBJ(BGM_Kongtaoluo_01, volume)
        end)
      end)
    end)
    return
  end
  PlayBGM({
    bgm = 0,
    time = 300,
    ID = 182,
    unit = u.handle
  })
  ForGroupLuaNew(Group_PlayHero, function(xq)
    xq:buffset(u.handle, 90, "绝对闪避")
  end)
  ac.wait(23000, function()
    flashphoto({
      photo = "Ph_Ktl_03.tga",
      timeout = 0.1,
      timehold = 30,
      timein = 30
    })
    local alpha = 255
    ac.loop(50, function(timer)
      alpha = alpha - 1
      whitephoto:set_alpha(alpha)
      if alpha <= 10 then
        whitephoto:set_alpha(alpha)
        timer:remove()
      end
    end)
  end)
  ac.wait(27000, function()
    local volume = 50
    ac.timer(50, 20, function()
      volume = volume - 2.5
      SetSoundVolumeBJ(BGM_Kongtaoluo_01, volume)
    end)
    ac.wait(4000, function()
      PlayGlobalSound(BGM_Ktl_N02)
      SetSoundVolumeBJ(BGM_Ktl_N02, 0)
      local next_volume = 0
      ac.timer(50, 80, function()
        next_volume = next_volume + 1
        SetSoundVolumeBJ(BGM_Ktl_N02, next_volume)
      end)
    end)
    ac.wait(8000, function()
      StopSoundBJ(BGM_Kongtaoluo_01, false)
      PlayGlobalSound(Sound_Ktl_Lhj07)
      NPCChat({
        name = "|cFF3F3F49孔|r|cFF696C6F涛|r|cFF939896罗|r",
        chaticon = "Chat_Ktl3.tga",
        chattext = {
          {
            text = "|cFF696C6F……为什么……|r",
            time = 0
          },
          {
            text = "|cFF696C6F……为什么，我们的结局会是这样……|r",
            time = 2
          },
          {
            text = "|cFF696C6F我……|r",
            time = 8
          },
          {
            text = "|cFF696C6F我明明那么深爱着你们……|r",
            time = 9.3
          },
          {
            text = "|cFF696C6F不管是你，还是瑞丽……|r",
            time = 12.8
          },
          {
            text = "|cFF696C6F不要说了……|r",
            time = 31
          },
          {
            text = "|cFF696C6F豪军！|r",
            time = 60
          },
          {
            text = "|cFF696C6F豪……军……|r",
            time = 68
          }
        }
      })
      ac.wait(2000, function()
        PlayGlobalSound(Sound_Ktl_Lhj08)
      end)
      ac.wait(8000, function()
        PlayGlobalSound(Sound_Ktl_Lhj09)
      end)
      ac.wait(31000, function()
        PlayGlobalSound(Sound_Ktl_Lhj12)
      end)
      ac.wait(60000, function()
        PlayGlobalSound(Sound_Ktl_Lhj15)
        ac.wait(2700, function()
          local alpha = 200
          whitephoto:set_alpha(alpha)
          ac.wait(1000, function()
            ac.loop(25, function(timer)
              alpha = alpha - 3
              whitephoto:set_alpha(alpha)
              if alpha <= 10 then
                whitephoto:set_alpha(alpha)
                timer:remove()
              end
            end)
          end)
        end)
      end)
      ac.wait(68000, function()
        PlayGlobalSound(Sound_Ktl_Lhj16)
        whitephoto:set_normal_image("war3mapImported\\Black.blp")
        local alpha = 0
        whitephoto:set_alpha(0)
        ac.loop(25, function(timer)
          alpha = alpha + 1
          whitephoto:set_alpha(alpha)
          if 255 <= alpha then
            whitephoto:set_alpha(alpha)
            timer:remove()
          end
        end)
      end)
      NPCChat({
        name = "|cFF616368刘|r|cFF777B7C豪|r|cFF8E9291军|r",
        chaticon = "Chat_Lhj2.tga",
        chattext = {
          {
            text = "|cFF777B7C即使如此，你爱的方式也是错的|r",
            time = 17
          },
          {
            text = "|cFF777B7C对你感到绝望的瑞丽，令我彻底陷入疯狂|r",
            time = 24
          },
          {
            text = "|cFF777B7C哈……哈哈哈……|r",
            time = 33
          },
          {
            text = "|cFF777B7C一切的一切……都是你亲手毁掉的|r",
            time = 41
          },
          {
            text = "|cFF777B7C我也好，她也好……|r",
            time = 49.2
          },
          {
            text = "|cFF777B7C涛罗，都是被你……|r",
            time = 55.6
          }
        }
      })
      ac.wait(17000, function()
        PlayGlobalSound(Sound_Ktl_Lhj10)
      end)
      ac.wait(24000, function()
        PlayGlobalSound(Sound_Ktl_Lhj11)
      end)
      ac.wait(33000, function()
        PlayGlobalSound(Sound_Ktl_Lhj13)
      end)
      ac.wait(41000, function()
        PlayGlobalSound(Sound_Ktl_Lhj14)
      end)
      ac.wait(75000, function()
        flashphoto({
          photo = "Ph_Ktl_04.tga",
          timeout = 0.1,
          timehold = 30,
          timein = 30
        })
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:buffset(u.handle, 160, "绝对闪避")
        end)
        local alpha = 255
        whitephoto:set_alpha(255)
        ac.loop(50, function(timer)
          alpha = alpha - 0.5
          whitephoto:set_alpha(alpha)
          if alpha <= 5 then
            whitephoto:set_alpha(alpha)
            timer:remove()
          end
        end)
        NPCChat({
          name = "|cFF3F3F49孔|r|cFF696C6F涛|r|cFF939896罗|r",
          chaticon = "Chat_Ktl4.tga",
          chattext = {
            {
              text = "|cFF777B7C……|r",
              time = 2
            },
            {
              text = "|cFF777B7C……瑞丽？|r",
              time = 8
            },
            {
              text = "|cFF777B7C瑞丽……真的是……瑞丽吗？|r",
              time = 10
            },
            {
              text = "|cFF777B7C啊啊……|r",
              time = 35
            },
            {
              text = "|cFF777B7C为了这样的结局，我……|r",
              time = 37
            },
            {
              text = "|cFF777B7C我想……留在你身边……|r",
              time = 43
            },
            {
              text = "|cFF777B7C和你一起生活下去……|r",
              time = 51.2
            },
            {
              text = "|cFF777B7C瑞丽，好不容易才找回了你……|r",
              time = 57
            },
            {
              text = "|cFF777B7C如今，却轮到我消失了吗……|r",
              time = 61.2
            },
            {
              text = "|cFF777B7C这下，我又要变成一个人了吗……|r",
              time = 67
            },
            {
              text = "|cFF777B7C这次，怕是再也无法……|r",
              time = 74
            },
            {
              text = "|cFF777B7C带上我一起走吧……拜托了……|r",
              time = 107.6
            },
            {
              text = "|cFF777B7C不要再离开我了……|r",
              time = 112
            },
            {
              text = "|cFF777B7C不要再丢下我一个人……|r",
              time = 117
            },
            {
              text = "|cFF777B7C瑞丽……|r",
              time = 144
            }
          }
        })
        NPCChat({
          name = "|cFF3F3F49孔|r|cFF696C6F涛|r|cFF939896罗|r",
          chaticon = "Chat_Ktl.tga",
          chattext = {
            {
              text = "|cFF777B7C我发誓，不管拿什么作为代价|r",
              time = 146
            },
            {
              text = "|cFF777B7C只要能与你在一起，我……|r",
              time = 152
            }
          }
        })
        ac.wait(2000, function()
          PlayGlobalSound(Sound_Ktl_Rl01)
        end)
        ac.wait(8000, function()
          PlayGlobalSound(Sound_Ktl_Rl03)
        end)
        ac.wait(10000, function()
          PlayGlobalSound(Sound_Ktl_Rl04)
        end)
        ac.wait(35000, function()
          PlayGlobalSound(Sound_Ktl_Rl08)
        end)
        ac.wait(37000, function()
          PlayGlobalSound(Sound_Ktl_Rl09)
        end)
        ac.wait(43000, function()
          PlayGlobalSound(Sound_Ktl_Rl10)
        end)
        ac.wait(57000, function()
          PlayGlobalSound(Sound_Ktl_Rl11)
        end)
        ac.wait(67000, function()
          PlayGlobalSound(Sound_Ktl_Rl12)
        end)
        ac.wait(74000, function()
          PlayGlobalSound(Sound_Ktl_Rl13)
        end)
        ac.wait(106000, function()
          PlayGlobalSound(Sound_Ktl_Rl17)
        end)
        ac.wait(112000, function()
          PlayGlobalSound(Sound_Ktl_Rl18)
        end)
        ac.wait(144000, function()
          PlayGlobalSound(Sound_Ktl_Rl20)
          local alpha = 10
          whitephoto:set_alpha(10)
          ac.loop(25, function(timer)
            alpha = alpha + 0.5
            whitephoto:set_alpha(alpha)
            if 255 <= alpha then
              whitephoto:set_alpha(alpha)
              StopSoundBJ(BGM_Ktl_N02, true)
              PlayGlobalSound(BGM_Ktl_N03)
              SetSoundVolumeBJ(BGM_Ktl_N03, 50)
              songtext({
                text = {
                  {
                    starttime = 24.16,
                    str = "在思念的尽头"
                  },
                  {
                    starttime = 30.97,
                    str = "呼唤悲伤的泪水已经流尽",
                    time = 7
                  },
                  {
                    starttime = 51.85,
                    str = "依旧无所畏惧地"
                  },
                  {
                    starttime = 58.61,
                    str = "从黑暗里传来短促的风铃声",
                    time = 7
                  },
                  {
                    starttime = 80.49,
                    str = "即使抱着旧时的幻影，也无法再回到从前",
                    time = 8
                  },
                  {
                    starttime = 94.2,
                    str = "反抗着命运，不知不觉间开始寻找着奇迹",
                    time = 8
                  },
                  {
                    starttime = 108.56,
                    str = "请回应我",
                    time = 4
                  },
                  {
                    starttime = 119.88,
                    str = "渐渐开始满足"
                  },
                  {
                    starttime = 126.99,
                    str = "目送着花开的季节远去",
                    time = 7
                  },
                  {
                    starttime = 145.58,
                    str = "与我的思念合而为一"
                  },
                  {
                    starttime = 152.3,
                    str = "紧抱着虚幻又真实的伤口将其治愈",
                    time = 7
                  },
                  {
                    starttime = 173.32,
                    str = "这里是安静的地方"
                  },
                  {
                    starttime = 180.08,
                    str = "向黑暗射入光芒内心便充满平静",
                    time = 7
                  },
                  {
                    starttime = 202.02,
                    str = "即使身躯腐朽也绝不会再与你分离",
                    time = 8
                  },
                  {
                    starttime = 215.82,
                    str = "你我的灵魂被囚禁在生与死的夹缝里",
                    time = 8
                  },
                  {
                    starttime = 229.86,
                    str = "紧紧相依",
                    time = 4
                  },
                  {
                    starttime = 241.52,
                    str = "一边目送着悠久的时光"
                  },
                  {
                    starttime = 248.95,
                    str = "缓缓流逝"
                  },
                  {
                    starttime = 256,
                    str = "一边紧靠着你缓缓而行"
                  },
                  {
                    starttime = 262.73,
                    str = "我渐渐开始满足于"
                  },
                  {
                    starttime = 269.62,
                    str = "沉醉在这"
                  },
                  {
                    starttime = 276.69,
                    str = "笑看花开花落的悠远时光里",
                    time = 8
                  }
                },
                color = "FFECBBFF"
              })
              timer:remove()
            end
          end)
        end)
        ac.wait(146000, function()
          PlayGlobalSound(Sound_Ktl_Rl21)
        end)
        ac.wait(152000, function()
          PlayGlobalSound(Sound_Ktl_Rl22)
          ac.wait(4000, function()
            ForGroupLuaNew(Group_PlayHero, function(xq)
              xq:buffset(u.handle, 40, "绝对闪避")
            end)
            local blackphoto = class.panel:builder({
              parent = OriginPanel,
              x = 0,
              y = 0,
              w = 1920,
              h = 850,
              normal_image = "war3mapImported\\Black.blp"
            })
            whitephoto:set_alpha(255)
            whitephoto:set_normal_image("White.tga")
            flashphoto({
              photo = "Ph_Ktl_05.tga",
              timeout = 0,
              timehold = 0,
              timein = 0
            })
            local alpha = 255
            ac.loop(25, function(timer)
              alpha = alpha - 1
              blackphoto:set_alpha(alpha)
              if alpha <= 5 then
                blackphoto:destroy()
                timer:remove()
              end
            end)
            ac.wait(6500, function()
              local next_alpha = 255
              ac.loop(25, function(timer)
                next_alpha = next_alpha - 1
                whitephoto:set_alpha(next_alpha)
                if next_alpha <= 5 then
                  timer:remove()
                end
              end)
            end)
            ac.wait(8000, function()
              NPCChat({
                name = "|cffc5c5c5？|r",
                chaticon = "Chat_Ktl5.tga",
                chattext = {
                  {
                    text = "|cFF777B7C啊啊，那舞蹈……|r",
                    time = 0
                  }
                }
              })
              PlayGlobalSound(Sound_Ktl_Rl30)
              NPCChat({
                name = "|cfff2baf7？|r",
                chaticon = "Chat_Krl3.tga",
                chattext = {
                  {
                    text = "|cffeab4ff欢迎前来，涛罗|r",
                    time = 4
                  },
                  {
                    text = "|cffeab4ff按照约定那样，终于来了呢|r",
                    time = 10
                  },
                  {
                    text = "|cffeab4ff从此以后，我们便会永远在一起|r",
                    time = 16
                  },
                  {
                    text = "|cffeab4ff绝不会再让你独自离开了|r",
                    time = 23.3
                  }
                }
              })
              ac.wait(4000, function()
                PlayGlobalSound(Sound_Ktl_Rl31)
              end)
              ac.wait(10000, function()
                PlayGlobalSound(Sound_Ktl_Rl32)
              end)
              ac.wait(16000, function()
                PlayGlobalSound(Sound_Ktl_Rl33)
                local next_alpha = 0
                ac.loop(25, function(timer)
                  next_alpha = next_alpha + 5
                  whitephoto:set_alpha(next_alpha)
                  if 255 <= next_alpha then
                    timer:remove()
                  end
                end)
              end)
              ac.wait(18000, function()
                flashphoto({
                  photo = "Ph_Ktl_06.tga",
                  timeout = 0.1,
                  timehold = 13,
                  timein = 10
                })
                local next_alpha = 255
                ac.loop(25, function(timer)
                  next_alpha = next_alpha - 5
                  whitephoto:set_alpha(next_alpha)
                  if next_alpha <= 5 then
                    whitephoto:destroy()
                    timer:remove()
                  end
                end)
              end)
              ac.wait(31000, function()
                NPCChat({
                  name = "|cffc5c5c5涛罗|r",
                  chaticon = "Chat_Ktl5.tga",
                  chattext = {
                    {
                      text = "|cFF777B7C瑞丽……|r",
                      time = 0
                    }
                  }
                })
                PlayGlobalSound(Sound_Ktl_Rl34)
                kongruili_get_myth()
                local next_volume = 50
                ac.timer(100, 50, function()
                  next_volume = next_volume + 1
                  SetSoundVolumeBJ(BGM_Ktl_N03, next_volume)
                end)
                Movie_Boolean = false
              end)
            end)
          end)
        end)
        NPCChat({
          name = "|cff5689b3瑞丽|r",
          chaticon = "Chat_Krl2.tga",
          chattext = {
            {
              text = "|cff87bec5哥哥，听得到吗？|r",
              time = 4
            },
            {
              text = "|cff87bec5是，哥哥|r",
              time = 18
            },
            {
              text = "|cff87bec5……很久不见了|r",
              time = 22.5
            },
            {
              text = "|cff87bec5我始终坚信能有与你再会的一天|r",
              time = 26
            },
            {
              text = "|cff87bec5这一天……真的，让我等得太久了|r",
              time = 30
            },
            {
              text = "|cff87bec5不会的，没关系|r",
              time = 80
            },
            {
              text = "|cff87bec5哥哥，这么期盼的话……|r",
              time = 84
            },
            {
              text = "|cff87bec5我们就不会再分离|r",
              time = 90
            },
            {
              text = "|cff87bec5和我在一起，愿意这样吗？|r",
              time = 96
            },
            {
              text = "|cff87bec5不管到哪里都在一起|r",
              time = 101.6
            },
            {
              text = "|cff87bec5谢谢你，哥哥。好高兴啊|r",
              time = 126
            },
            {
              text = "|cff87bec5约定了哦，我们永远都在一起，好吗？|r",
              time = 133.8
            }
          }
        })
        ac.wait(4000, function()
          PlayGlobalSound(Sound_Ktl_Rl02)
        end)
        ac.wait(18000, function()
          PlayGlobalSound(Sound_Ktl_Rl05)
        end)
        ac.wait(26000, function()
          PlayGlobalSound(Sound_Ktl_Rl06)
        end)
        ac.wait(30000, function()
          PlayGlobalSound(Sound_Ktl_Rl07)
        end)
        ac.wait(80000, function()
          PlayGlobalSound(Sound_Ktl_Rl14)
        end)
        ac.wait(84000, function()
          PlayGlobalSound(Sound_Ktl_Rl15)
        end)
        ac.wait(96000, function()
          PlayGlobalSound(Sound_Ktl_Rl16)
        end)
        ac.wait(126000, function()
          PlayGlobalSound(Sound_Ktl_Rl19)
        end)
      end)
    end)
  end)
end
MovieAct["孔涛罗第一次复仇"] = function(u)
  u:chat("|cFF3F3F49孔涛罗在澳门已经死了。|r")
  ac.wait(3100, function()
    u:chat("|cFF3F3F49如今在这儿握着剑的，只是一只鬼……|r")
  end)
  ac.wait(8300, function()
    u:chat("|cFF3F3F49复仇之鬼!!|r")
  end)
  ac.wait(10500, function()
    flashphoto({
      photo = "Ph_Ktl_07.tga",
      timeout = 1,
      timehold = 2,
      timein = 3
    })
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:buffset(u.handle, 7, "绝对闪避")
    end)
  end)
  ac.wait(11000, function()
    PlayGlobalSound(BGM_Kongtaoluo_01)
    SendMsgAll("|cFF3F3F49BGM:《Vow Of Sword(剑的誓言)》|r")
  end)
  PlayGlobalSound(Sound_Kongtaoluo_01)
  PlayBGM({
    bgm = 0,
    time = 200,
    ID = 182,
    unit = u.handle
  })
end
MovieAct["幻想杀手反击"] = function(actor, target, blocked_damage)
  local u = actor
  local mb = target
  blocked_damage = tonumber(blocked_damage) or 0
  actor:buffset(actor.handle, 8, "绝对闪避")
  actor:buffset(actor.handle, 8, "永恒")
  actor:buffset(actor.handle, 7.5, "暂停")
  target:buffset(target.handle, 10, "沉默")
  target:buffset(target.handle, 10, "暂停")
  PlayBGM({
    bgm = 0,
    time = 103,
    ID = 255,
    unit = actor.handle
  })
  local x, y = actor:getxy()
  local target_x, target_y = target:getxy()
  local target_face = target:getface()
  local strike_x, strike_y = PolarXY(target_x, target_y, 150, target_face)
  actor:setface(target_face + 180)
  Effectcreate("war3mapImported\\blackblink.mdx", x, y)
  Effectcreate("war3mapImported\\blackblink.mdx", strike_x, strike_y)
  actor:setxy(strike_x, strike_y)
  x, y = actor:getxy()
  PlayGlobalSound(Sound_Dangma_13)
  ac.timer(100, 62, function()
    EffectcreateArgs({
      effect = "Tx_Stdm (5).mdx",
      x = x,
      y = y,
      size = 1,
      animespeed = 5,
      zxz = GetRandomAngle()
    })
  end)
  ac.wait(6500, function()
    local tx = EffectcreateArgs({
      effect = "Tx_Stdm (7).mdx",
      x = x,
      y = y,
      time = 0.4,
      size = 1,
      height = -50,
      zxz = actor:getface(),
      animespeed = 1
    })
    ac.wait(200, function()
      local jd1 = actor:getface()
      local dx, dy = x, y
      local cs = 0
      ac.timer(10, 10, function()
        cs = cs + 1
        dx, dy = PolarXY(x, y, 100 + cs * 15, jd1)
        japi.EXSetEffectXY(tx, dx, dy)
        japi.EXSetEffectSize(tx, cs / 5)
      end)
    end)
  end)
  ac.wait(6800, function()
    actor:shockcamera(1000, 0.2)
    EffectcreateArgs({
      effect = "war3mapImported\\tx_rongrong_chongjibo1.mdx",
      x = x,
      y = y,
      size = 2,
      height = 0,
      zxz = actor:getface(),
      animespeed = 2
    })
    EffectcreateArgs({
      effect = "war3mapImported\\qiye_chongji1.mdx",
      x = x,
      y = y,
      size = 2,
      height = 0,
      zxz = actor:getface(),
      animespeed = 1
    })
    unitmove({
      unit = target.handle,
      time = 0.1,
      distance = 500,
      angle = u:getface()
    })
    unitmove({
      unit = target.handle,
      time = 0.8,
      distance = 500,
      angle = u:getface()
    })
    PlayGlobalSound(Sound_Dangma_14)
    ac.wait(1600, function()
      actor:shockcamera(500, 0.4)
      local cs = 0
      ac.timer(30, 10, function()
        cs = cs + 1
        target_x, target_y = target:getxy()
        EffectcreateArgs({
          effect = "Tx_Stdm (6).mdx",
          x = target_x,
          y = target_y,
          zxz = target_face,
          time = 0.1,
          size = cs,
          animespeed = cs
        })
      end)
    end)
    local cs1 = 0
    ac.timer(70, 20, function()
      cs1 = cs1 + 1
      target_x, target_y = target:getxy()
      actor:shockcamera(100, 0.1)
      EffectcreateArgs({
        effect = "Tx_Stdm (5).mdx",
        x = target_x,
        y = target_y,
        size = cs1 / 10,
        animespeed = 5
      })
      if 20 <= cs1 then
        target:animeact("death")
        EffectcreateArgs({
          effect = "Tx_Stdm (5).mdx",
          x = target_x,
          y = target_y,
          size = 10,
          animespeed = 5
        })
        local tx1 = EffectcreateArgs({
          effect = "Tx_Stdm (5).mdx",
          x = target_x,
          y = target_y,
          size = 20,
          animespeed = 5
        })
        local cs2 = 20
        ac.timer(10, 10, function()
          cs2 = cs2 - 2
          japi.EXSetEffectSize(tx1, cs2)
        end)
      end
      DamageUnit({
        bj = "竜王の颚反击",
        unit = target.handle,
        source = actor.handle,
        damage = blocked_damage * 100,
        level = 5,
        type = "反物质",
        isvest = false,
        isattack = false,
        isnoarmor = false,
        element = "无",
        extradata = {
          "竜王の颚固定伤害"
        }
      })
    end)
    PlayGlobalSound(BGM_Huanxiangshashou)
  end)
end

function huanxiangshashou(actor, target, blocked_damage)
  return MovieAct["幻想杀手反击"](actor, target, blocked_damage)
end

MovieAct["幻想杀手进阶"] = function(actor, target)
  local u = actor
  local mb = target
  local sy = u.ownerid
  local x, y = actor:getxy()
  local jd = AngleBetweenUnits(actor.handle, target.handle)
  actor:setface(jd)
  actor:buffset(actor.handle, 38, "绝对闪避")
  actor:buffset(actor.handle, 38, "永恒")
  actor:buffset(actor.handle, 38, "暂停")
  target:buffset(target.handle, 38, "沉默")
  target:buffset(target.handle, 38, "暂停")
  flashphoto({photo = "Black.tga", timeout = 8})
  ac.wait(4200, function()
    flashphoto({
      photo = "Black.tga",
      timeout = 0,
      timehold = 0,
      timein = 0.1
    })
  end)
  local charge_effect = EffectcreateArgs({
    effect = "Tx_Stdm (2).mdx",
    x = x,
    y = y,
    time = 4,
    size = 1,
    animespeed = 0.1
  })
  ac.wait(4200, function()
    actor:shockcamera(100, 0.5)
    EffectcreateArgs({
      effect = "Tx_Stdm (1).mdx",
      x = x,
      y = y,
      size = 5,
      height = 100,
      animespeed = 2
    })
    local size = 1
    ac.timer(30, 10, function()
      size = size + 0.5
      SetEffectSize(charge_effect, size)
      SetEffectActSpeed(charge_effect, 1)
    end)
    EffectcreateArgs({
      effect = "Tx_Stdm (3).mdx",
      x = x,
      y = y,
      size = 5,
      height = 100,
      animespeed = 2
    })
  end)
  Movie_Boolean = true
  PlayBGM({
    bgm = 0,
    time = 50,
    ID = 255,
    unit = u.handle
  })
  PlayGlobalSound(Sound_Dangma_10)
  NPCChat({
    name = "|cFF3B6FFF上条当麻|r",
    chaticon = "Chat_Stdm.tga",
    chattext = {
      {
        time = 1.0,
        text = "哼哼哼……"
      },
      {
        time = 4.2,
        text = "呵哈哈哈哈！"
      },
      {
        time = 8.5,
        text = "哈哈……"
      },
      {
        time = 11.0,
        text = "哈哈……"
      },
      {
        time = 13.0,
        text = "哼哼……"
      },
      {
        time = 14.5,
        text = "呵哈哈……"
      },
      {
        time = 16.6,
        text = "呵哈哈哈……"
      }
    }
  })
  ac.wait(19500, function()
    PlayGlobalSound(Sound_Dangma_11)
    NPCChat({
      name = "|cFF3B6FFF上条当麻|r",
      chaticon = "Chat_Stdm.tga",
      chattext = {
        {time = 0, text = "喂……"},
        {
          time = 1.2,
          text = "你这家伙难道以为这种程度"
        },
        {
          time = 4.2,
          text = "就能消灭我的|cFF9966CC“幻想杀手”|r？"
        }
      }
    })
    ac.wait(8500, function()
      PlayGlobalSound(Sound_Dangma_12)
      NPCChat({
        name = "|cFF3B6FFF上条当麻|r",
        chaticon = "Chat_Stdm.tga",
        chattext = {
          {
            time = 0,
            text = "杂念也不能摒除了吧？"
          },
          {
            time = 3.2,
            text = "怎么了，下令吧"
          },
          {
            time = 6.6,
            text = "用你的话语扭曲现实吧"
          }
        }
      })
      ac.wait(9600, function()
        huanxiangshashou(actor, target)
        u:setdata("神化判定-上条当麻")
        u:changedata("龙变异数量", 1)
        u:setplayername("|cFF909090[神|r|cFF7C7C7C魔|r|cFF686868净|r|cFF545454讨]|r" .. NameID[sy])
        u:uivar_change({
          keyname = "幻想杀手",
          keytype = "传奇栏",
          icon = "Cq_Dangma_Big.tga",
          ishasphoto = true,
          size_h = 0.715,
          dx = 4.5,
          smallicon = "Cq_Dangma.tga",
          text = "|cFF909090上|r|cFF7C7C7C条|r|cFF686868当|r|cFF545454麻|r\n|cFF990000[凡俗?]|r\n|cFF909090唯一 龙\n【幻想杀手】|r\n|cFF545454幸运锁定0\n魔力值锁定0\n法术修正锁定为0%\n降低10000%魔导补正|r\n|cFF909090【神魔净讨】|r\n|cFF545454提升[20%+1%*累积等级]近战伤害(独立)\n来自正面(180°)的伤害只造成1%伤害\n解锁技能[竜王の颚]|r\n|cFF909090【基准点】|r\n|cFF545454自身不会被删模|r"
        })
        Fskillreplace({
          unit = u.handle,
          level = 2,
          skill_F = "S0DE",
          skill_X = "S0DF",
          name = "竜王の颚",
          icon = "Cq_Dangma_F.tga",
          isforce = false,
          efunc = function()
            if u:hasdata("竜王の颚-技能事件已注册") then
              return
            end
            u:setdata("竜王の颚-技能事件已注册")
            u:addtrgevent("单位-发动技能", function(args)
              if args.skill == S2ID("S0DE") or args.skill == S2ID("S0DF") then
                u:settimedata("竜王の颚-格挡判定时间", 0.25)
              end
            end)
          end
        })
        ac.wait(6800, function()
          Movie_Boolean = false
        end)
      end)
    end)
  end)
end
