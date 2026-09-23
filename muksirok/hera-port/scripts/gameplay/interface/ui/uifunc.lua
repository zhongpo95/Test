-- 툴팁의 UTF-8 줄바꿈과 설명 영역 크기를 동일한 글꼴 계산에 맞춘다.
local slk = require("jass.slk")
Biankuang_Youshang = nil

function is_supported_image(path)
  local lower = path:lower()
  return lower:match("%.jpg$") or lower:match("%.png$") or lower:match("%.webp$")
end

do
  local korean = require("hera_korean")
  local tooltip_font
  local tooltip_size = 10
  local max_width = 450
  local function measure_tooltip(text)
    local metrics = require("hera_text_width")
    return metrics.height(text, tooltip_size, tooltip_font), metrics.pixels(text, tooltip_size, tooltip_font)
  end
  local dsize = 100
  local image_type_config = {
    Buff = {
      x = 50,
      y = -dsize * 2.04 * 0.71,
      w = dsize * 1.65 * 0.91,
      h = dsize * 2.04 * 0.71
    },
    Item = {
      x = -dsize * 3 * 0.88,
      y = 0,
      w = dsize * 3 * 0.88,
      h = dsize * 3 * 0.68
    },
    LeftShowButton = {
      x = -400,
      y = 0,
      w = 1,
      h = 1
    },
    Relic = {
      x = -dsize * 1.5 * 0.88 - 5,
      y = 15,
      w = dsize * 1.5 * 0.88,
      h = dsize * 1.5 * 0.68
    },
    Var = {
      x = 0,
      y = 0,
      w = 1,
      h = 1
    }
  }
  
  local function smartWrapText(rawtext)
    return require("hera_text_width").wrap(rawtext, tooltip_size, tooltip_font or TEXT_FONT_PATH or "Fonts\\gamefont.ttc", max_width)
  end
  
  local uiy_hint_panel = class.panel:builder({
    parent = OriginPanel,
    x = -500,
    y = -500,
    w = 1,
    h = 1,
    normal_image = "war3mapImported\\Black.blp"
  })
  local text_show = class.text:builder({
    parent = uiy_hint_panel,
    x = 3,
    y = 3,
    w = 1,
    h = 1,
    text = "",
    align = "topleft",
    font_size = 10
  })
  -- 오른쪽 가방 설명도 배경 전체가 화면 안에 들어오도록 배치한다.
  function uiy_hint_panel:set_real_position(x, y)
    if x > -500 or y > -500 then
      x = math.max(8, math.min(1912 - self.w, x))
      y = math.max(8, math.min(1072 - self.h, y))
    end
    class.ui_base.set_real_position(self, x, y)
  end
  local biankuangset
  do
    local cd = 10
    local hsize = 0.71
    local ssize = 0.88
    local aaa = uiy_hint_panel
    local u_zuoshang = class.panel:builder({
      parent = aaa,
      x = -cd * 0.6,
      y = -cd * 0.5,
      w = cd * 1.5 * 0.88,
      h = cd * 1.5 * 0.68,
      normal_image = "UI_Biankuang_Zuoshang.blp"
    })
    local u_zuoxia = class.panel:builder({
      parent = aaa,
      x = -cd * 0.6,
      y = -cd * 0.55 + aaa:get_height(),
      w = cd * 1.5 * 0.88,
      h = cd * 1.5 * 0.68,
      normal_image = "UI_Biankuang_Zuoxia.blp"
    })
    local u_youshang = class.panel:builder({
      parent = aaa,
      x = -cd * 0.7 + aaa:get_width(),
      y = -cd * 0.5,
      w = cd * 1.5 * 0.88,
      h = cd * 1.5 * 0.68,
      normal_image = "UI_Biankuang_Youshang.blp"
    })
    local u_youxia = class.panel:builder({
      parent = aaa,
      x = -cd * 0.7 + aaa:get_width(),
      y = -cd * 0.55 + aaa:get_height(),
      w = cd * 1.5 * 0.88,
      h = cd * 1.5 * 0.68,
      normal_image = "UI_Biankuang_Youxia.blp"
    })
    local u_heng_shang = class.panel:builder({
      parent = aaa,
      x = 0,
      y = -cd * 0.8 * hsize,
      w = aaa:get_width(),
      h = cd * hsize,
      normal_image = "UI_Biankuang_Shang.tga"
    })
    local u_heng_xia = class.panel:builder({
      parent = aaa,
      x = 0,
      y = aaa:get_height() - 0.2 * cd * hsize,
      w = aaa:get_width(),
      h = cd * hsize,
      normal_image = "UI_Biankuang_Xia.tga"
    })
    local u_shu_zuo = class.panel:builder({
      parent = aaa,
      x = -cd * 0.8 * ssize,
      y = 0,
      w = cd * ssize,
      h = aaa:get_height(),
      normal_image = "UI_Biankuang_Zuo.tga"
    })
    local u_shu_you = class.panel:builder({
      parent = aaa,
      x = aaa:get_width() - 0.2 * cd * ssize,
      y = 0,
      w = cd * ssize,
      h = aaa:get_height(),
      normal_image = "UI_Biankuang_You.tga"
    })
    Biankuang_Xia = u_heng_xia
    Biankuang_Zuo = u_shu_zuo
    Biankuang_You = u_shu_you
    Biankuang_shang = u_heng_shang
    
    function biankuangset()
      u_heng_shang:set_width(aaa:get_width())
      u_heng_xia:set_width(aaa:get_width())
      u_shu_zuo:set_height(aaa:get_height())
      u_shu_you:set_height(aaa:get_height())
      u_zuoxia:set_position(-cd * 0.6, -cd * 0.55 + aaa:get_height())
      u_youshang:set_position(-cd * 0.7 + aaa:get_width(), -cd * 0.5)
      u_youxia:set_position(-cd * 0.7 + aaa:get_width(), -cd * 0.55 + aaa:get_height())
      u_heng_shang:set_position(0, -cd * 0.8 * hsize)
      if Biankuang_Zhuangshi then
        Biankuang_Zhuangshi:set_position(Biankuang_shang:get_width() * 0.76 - 5, -50)
      end
      u_heng_xia:set_position(0, aaa:get_height() - 0.2 * cd * hsize)
      u_shu_you:set_position(aaa:get_width() - 0.2 * cd * ssize, 0)
    end
  end
  uiy_hint_panel:set_alpha(200)
  uiy_hint_panel:hide()
  uiy_hint_panel:set_level(5)
  uiy_hint_panel.type = "Normal"
  text_show:set_color("FF7DBEF1")
  uiy_hint_panel.showtext = text_show
  local image_show = class.panel:builder({
    parent = uiy_hint_panel,
    x = 0,
    y = 0,
    w = 1,
    h = 1,
    normal_image = "Touming.tga"
  })
  image_show:hide()
  uiy_hint_panel.showimage = image_show
  
  local function ish5imageposition()
  end
  
  ac.loop(30, function()
    if uiy_hint_panel:get_is_show() then
      local x, y = game.get_mouse_pos()
      local type = uiy_hint_panel.type
      if type == "Var" or type == "NativeSkill" then
        uiy_hint_panel:set_real_position(1900 - uiy_hint_panel:get_width(), 817 - uiy_hint_panel:get_height())
        ish5imageposition()
        return
      end
      if type == "Item" then
        uiy_hint_panel:set_real_position(x - 0.2 * uiy_hint_panel:get_width(), y - 1.05 * uiy_hint_panel:get_height())
        ish5imageposition()
        return
      end
      if type == "Skill" then
        uiy_hint_panel:set_real_position(x + 30, y - 40)
        ish5imageposition()
        return
      end
      if type == "Relic" then
        uiy_hint_panel:set_real_position(x + 30, y + 45)
        ish5imageposition()
        return
      end
      if type == "Buff" then
        uiy_hint_panel:set_real_position(x + 30, y - 0.75 * uiy_hint_panel:get_height())
        ish5imageposition()
        return
      end
      if type == "LeftShowButton" then
        uiy_hint_panel:set_real_position(x + 10 - 0.5 * uiy_hint_panel:get_width(), y + 45)
        ish5imageposition()
        return
      end
      if type == "Yuanzhu" then
        uiy_hint_panel:set_real_position(x - 45, y + 40)
        ish5imageposition()
        return
      end
      uiy_hint_panel:set_real_position(x + 30, y + 30)
      ish5imageposition()
    else
      uiy_hint_panel:set_real_position(-1000, -1000)
    end
  end)
  
  function uiy_show_text(text, type)
    text = korean.translate(text)
    tooltip_font = korean.has_hangul(text) and korean.font or TEXT_FONT_PATH or "Fonts\\gamefont.ttc"
    type = type or "Normal"
    tooltip_size = 10
    if korean.has_hangul(text) then
      local original = text
      text = smartWrapText(text)
      if type == "NativeSkill" then
        while measure_tooltip(text) > 760 and tooltip_size > 7 do
          tooltip_size = tooltip_size - 0.5
          text = require("hera_text_width").wrap(original, tooltip_size, tooltip_font, max_width)
        end
      end
    end
    if type == "Item" or type == "Skill" or type == "NativeSkill" then
      text_show:set_color("FF7DBEF1")
    else
      text_show:set_color("FFFFCC33")
    end
    uiy_hint_panel.type = type
    if (type == "Var" or type == "Item") and Boolean_UIYName and UIYNameKey == UIYNameUseKey then
      local he, wt = measure_tooltip(text)
      if wt <= 400 then
        wt = 400
      end
      if he <= 60 then
        he = 60
      end
      uiy_hint_panel.showtext:set_text(text)
      uiy_hint_panel:set_height(he + 6)
      uiy_hint_panel:set_width(math.ceil(wt) + 28)
      local hover_key = UIYNameKey
      local last_dynamic_text
      ac.loop(72, function(timer)
        if UIYNameKey ~= hover_key or UIYNameKey ~= UIYNameUseKey or not Boolean_UIYName then
          timer:remove()
        elseif UIYNameShow and UIYNameShow ~= last_dynamic_text then
          last_dynamic_text = UIYNameShow
          local display_text = korean.translate(UIYNameShow)
          tooltip_font = korean.has_hangul(display_text) and korean.font or TEXT_FONT_PATH or "Fonts\\gamefont.ttc"
          if korean.has_hangul(display_text) then display_text = smartWrapText(display_text) end
          local height, width = measure_tooltip(display_text)
          height, width = math.max(60, height), math.max(400, width)
          uiy_hint_panel:set_control_size(math.ceil(width) + 28, height + 6)
          uiy_hint_panel.showtext:set_control_size(math.ceil(width) + 20, height)
          japi.FrameSetSize(uiy_hint_panel.showtext._id, (math.ceil(width) + 20) / 1920 * 0.8, height / 1080 * 0.6)
          uiy_hint_panel.showtext:set_text(display_text)
          biankuangset()
        end
      end)
    else
      local he, wt = measure_tooltip(text)
      if wt > max_width and type ~= "Var" then
        text = smartWrapText(text)
        he, wt = measure_tooltip(text)
      end
      if type == "Var" then
        if wt <= 400 then
          wt = 400
        end
        if he <= 60 then
          he = 60
        end
      end
      uiy_hint_panel.showtext:set_text(text)
      uiy_hint_panel:set_height(he + 6)
      uiy_hint_panel:set_width(math.ceil(wt) + 28)
    end
    uiy_hint_panel.showtext:set_control_size(math.max(1, uiy_hint_panel.w - 8), math.max(1, uiy_hint_panel.h - 6))
    text_show.font_path = tooltip_font
    text_show._real_size = tooltip_size
    japi.FrameSetTextFont(text_show._id, tooltip_font, tooltip_size / 1000)
    japi.FrameSetSize(uiy_hint_panel.showtext._id, math.max(1, uiy_hint_panel.w - 8) / 1920 * 0.8, math.max(1, uiy_hint_panel.h - 6) / 1080 * 0.6)
    local x, y = game.get_mouse_pos()
    local b = true
    if type == "Var" or type == "NativeSkill" then
      b = false
      uiy_hint_panel:set_real_position(1900 - uiy_hint_panel:get_width(), 817 - uiy_hint_panel:get_height())
    end
    if type == "Item" then
      b = false
      uiy_hint_panel:set_real_position(x - 0.2 * uiy_hint_panel:get_width(), y - 1.05 * uiy_hint_panel:get_height())
    end
    if type == "Buff" then
      b = false
      uiy_hint_panel:set_real_position(x + 30, y - 0.75 * uiy_hint_panel:get_height())
    end
    if type == "Relic" then
      b = false
      uiy_hint_panel:set_real_position(x + 30, y + 45)
    end
    if type == "Skill" then
      b = false
      uiy_hint_panel:set_real_position(x + 30, y - 40)
    end
    if type == "LeftShowButton" then
      b = false
      uiy_hint_panel:set_real_position(x + 10 - 0.5 * uiy_hint_panel:get_width(), y + 45)
    end
    if type == "Yuanzhu" then
      b = false
      uiy_hint_panel:set_real_position(x - 45, y + 40)
    end
    if b then
      uiy_hint_panel:set_real_position(x + 30, y + 30)
    end
    uiy_hint_panel:show()
    if uiy_hint_panel.showimage then
      uiy_hint_panel.showimage:hide()
    end
    biankuangset()
  end
  
  function uiy_hide()
    uiy_hint_panel.showtext:set_text("")
    uiy_hint_panel:hide()
    if uiy_hint_panel.showimage then
      uiy_hint_panel.showimage:hide()
      uiy_hint_panel.showimage:set_normal_image("Touming.tga")
    end
    uiy_hint_panel.type = "Normal"
  end
  
  local function clamp(v, min, max)
    if v < min then
      return min
    end
    if max < v then
      return max
    end
    return v
  end
  
  function uiy_show_text_and_image(text, image, imagetype, custom_size)
    uiy_show_text(text, imagetype)
    if image then
      local config = image_type_config[imagetype or "Item"]
      local w = custom_size and custom_size.w or config.w
      local h = custom_size and custom_size.h or config.h
      local x = custom_size and custom_size.x or config.x
      local y = custom_size and custom_size.y or config.y
      if imagetype == "Item" then
        y = custom_size and custom_size.y or (uiy_hint_panel:get_height() - h) / 2
        x = x - 5
      end
      if imagetype == "Buff" then
        x = 0.5 * uiy_hint_panel:get_width() - 0.5 * uiy_hint_panel.showimage:get_width()
      end
      uiy_hint_panel.imagetype = imagetype
      uiy_hint_panel.showimage:set_normal_image(image)
      uiy_hint_panel.showimage:set_width(w)
      uiy_hint_panel.showimage:set_height(h)
      uiy_hint_panel.showimage:set_position(x, y)
      uiy_hint_panel.showimage:show()
    end
  end
  
  do
    local dzapi = require("jass.dzapi")
    local trace = require("hera_ui_trace")
    local ui = japi.DzFrameGetTooltip()
    for i = 0, 5 do
      local btn = japi.DzFrameGetItemBarButton(i)
      pcall(trace.label_frame, btn, "inventory_slot=" .. i)
      dzapi.DzFrameSetScriptByCode(btn, 2, function()
        local unit = japi.GetRealSelectUnit()
        if unit ~= 0 then
          local wp = UnitItemInSlot(unit, i)
          if wp ~= 0 then
            pcall(trace.item_hover, "inventory", i, wp)
            local itemtype = GetItemTypeId(wp)
            local text = slk.item[itemtype].Name
            local text2 = slk.item[itemtype].Ubertip
            text2 = text2:gsub(",DataA1.*", "")
            text2 = text2:gsub(",Dur1.*", "")
            local str = text .. "\n" .. text2
            UIYNameKey = wp
            Boolean_UIYName = false
            if HasData(itemtype, "绑定文字") then
              UIYNameUseKey = wp
              Boolean_UIYName = true
              GetData(itemtype, "绑定文字")()
            end
            if HasData(itemtype, "绑定图片") then
              if HasData(itemtype, "绑定尺寸W") or HasData(itemtype, "绑定尺寸H") then
                local w = 1
                local h = 1
                if HasData(itemtype, "绑定尺寸W") then
                  w = GetData(itemtype, "绑定尺寸W")
                end
                if HasData(itemtype, "绑定尺寸H") then
                  h = GetData(itemtype, "绑定尺寸H")
                end
                uiy_show_text_and_image(str, GetData(itemtype, "绑定图片"), "Item", {
                  x = -dsize * 3 * 0.88 * w,
                  w = dsize * 3 * 0.88 * w,
                  h = dsize * 3 * 0.68 * h
                })
              else
                uiy_show_text_and_image(str, GetData(itemtype, "绑定图片"), "Item")
              end
            else
              uiy_show_text(str, "Item")
            end
            if YuanshengTooltip then
              YuanshengTooltip.set_enabled(false)
            end
            -- 다음 스킬 진입 때 엔진이 사용할 기본 앵커는 옮기지 않는다.
            japi.FrameShow(ui, false)
          end
        end
      end, false)
      dzapi.DzFrameSetScriptByCode(btn, 3, function()
        if YuanshengTooltip then
          YuanshengTooltip.set_enabled(true)
        end
        uiy_hide()
        UIYNameKey = 0
        Boolean_UIYName = false
      end, false)
    end
    game.register_event({
      on_item_mouse_enter = function(wp)
        pcall(trace.item_hover, "ground_tooltip", nil, wp)
        local itemtype = GetItemTypeId(wp)
        local data = slk.item[itemtype]
        if not data or not data.Name then
          return
        end
        local text = data.Name .. "\n" .. (data.Ubertip or ""):gsub(",DataA1.*", ""):gsub(",Dur1.*", "")
        UIYNameKey = wp
        Boolean_UIYName = false
        uiy_show_text(text, "Item")
        if YuanshengTooltip then
          YuanshengTooltip.set_enabled(false)
        end
        japi.FrameShow(ui, false)
      end,
      on_item_mouse_leave = function(wp)
        if UIYNameKey == wp then
          uiy_hide()
          UIYNameKey = 0
          Boolean_UIYName = false
          if YuanshengTooltip then
            YuanshengTooltip.set_enabled(true)
          end
        end
      end
    })
  end
end
ac.wait(1000, function()
  SetData(S2ID("I0Z3"), "绑定图片", "Thing_Ams_Big.blp")
  SetData(S2ID("I0Z3"), "绑定尺寸W", 1.5933333333333333)
  SetData(S2ID("I0Z3"), "绑定文字", function()
    UIYNameCount = 2
    UIYName[1] = {
      method = 1,
      name = "小小奇迹",
      colors = {
        "F588FF",
        "6B9FFF",
        "FAE3FF",
        "FAE3FF",
        "6B9FFF",
        "F588FF"
      },
      length = 3,
      lengthcd = 15,
      math = 1,
      offsetspeed = 0.25,
      extratext = "\n"
    }
    UIYName[2] = {
      method = 1,
      name = "如雪绒般漂浮的音符 \n炽烈在静默间延展如初 \n远航至那星海尽处\nBon voyage\nMay your path be clear\nMay you get to where dreams are all crystalline and sweet",
      colors = {
        "F588FF",
        "6B9FFF",
        "FAE3FF",
        "FAE3FF",
        "6B9FFF",
        "F588FF"
      },
      length = 10,
      lengthcd = 150,
      math = 1,
      offsetspeed = 3,
      extratext = ""
    }
  end)
  SetData(S2ID("I0L4"), "绑定图片", "Thing_Pho_SishenzhilianBig.blp")
  SetData(S2ID("I0L4"), "绑定文字", function()
    UIYNameCount = 2
    UIYName[1] = {
      method = 1,
      name = "罪之镰",
      colors = {
        "FF8894",
        "B40012",
        "B40012",
        "FF8894"
      },
      length = 3,
      lengthcd = 15,
      math = 1,
      offsetspeed = 0.25,
      extratext = "\n" .. "|cFFFF6600武器类型：|r|cFFFFCC33副武|r" .. "\n"
    }
    UIYName[2] = {
      method = 1,
      name = "[执罪]\n纷争系数+2\n对精英与BOSS提升20%伤害\n无视精英特性守护\n提升5%近战伤害\n[断魂]\n直接伤害0.77%即死普通单位\n直接伤害时10%挥出血刃造成直线伤害,触发冷却3秒\n[灵魂收割]杀敌额外获得0.5灵魂计数\n[死神契约]收割概率提升5%",
      colors = {
        "FF8894",
        "B40012",
        "B40012",
        "FF8894"
      },
      length = 10,
      lengthcd = 150,
      math = 1,
      offsetspeed = 3,
      extratext = "\n" .. "|cFF949596“昔日的神明已失语，唯有它仍在审判生者。”|r"
    }
  end)
  SetData(S2ID("I0PA"), "绑定图片", "Ewl_Yuzhe_Thing_Mojing.tga")
  SetData(S2ID("I0PB"), "绑定图片", "Ewl_Yuzhe_04.tga")
  SetData(S2ID("I0PE"), "绑定图片", "Ryr_Ydmd.tga")
  SetData(S2ID("I0PF"), "绑定图片", "Lianlian_Xiaodao.tga")
  SetData(S2ID("I0PM"), "绑定图片", "ItemPh_Alice.tga")
  SetData(S2ID("I0PM"), "绑定尺寸W", 1.4133333333333333)
  SetData(S2ID("I0PM"), "绑定文字", function()
    UIYNameCount = 1
    UIYName[1] = {
      method = 1,
      name = "无名众神的王女",
      colors = {
        "FFFFFF",
        "0041FF",
        "FFFFFF",
        "6600FF",
        "FFFFFF"
      },
      length = 3,
      lengthcd = 20,
      math = 1,
      offsetspeed = 0.25,
      extratext = [[


]] .. "|cFFFFFFFF爱丽丝必须生活在与我不同的地方\n逃出色彩\n在爱丽丝变的和王女一样之前\n我无法在将祭祀全部斩杀都同时，确保爱丽丝的安全\n把爱丽丝藏起来。藏在祭祀们难以进入的意识体里\n让爱丽丝在里面避难，那里面是安全的\n然后用我的记忆留下锚点\n等我再次回来时，那记忆锚点会再次显现出来，\n即使是和其他意识体混在一起也能凭它辨认\n想要藏匿一棵树，就该把它藏在森林里\n无论花费了多长时间，我都希望对爱丽丝来说只是一刹那|r"
    }
  end)
end)
