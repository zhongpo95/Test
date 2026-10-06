-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local slk = require("jass.slk")
local util = require("gameplay.interface.ui.yuansheng.util")
local update_cache = util.create_update_cache()
require("gameplay.interface.ui.yuansheng.native")
do
  local ui_alllevel = class.panel:builder({
    parent = OriginPanel,
    x = 0,
    y = 0,
    w = 1,
    h = 1,
    normal_image = "Touming.tga"
  })
  ui_alllevel:set_level(2)
  local ui_topleft_exp = class.model:builder({
    parent = ui_alllevel,
    model = "yuanxing_white.mdx",
    x = 20,
    y = -92,
    w = 0,
    h = 0
  })
  local ui_topleft_exphide = class.model:builder({
    parent = ui_alllevel,
    model = "yuanxing_black.mdx",
    x = 26,
    y = -99,
    w = 0,
    h = 0
  })
  ui_topleft_exp:set_speed(0.1)
  local ui_topleft = class.panel:builder({
    parent = ui_alllevel,
    x = 0,
    y = 0,
    w = 455,
    h = 248.5,
    normal_image = "UI_TopLeft.blp"
  })
  local ui_topleft_icon = class.button:builder({
    parent = ui_topleft,
    x = 56,
    y = 25,
    w = 122.85000000000001,
    h = 95.85000000000001,
    normal_image = "Touming.blp",
    keys = {"TAB"},
    on_button_key_down = function(self, str)
      local p = getplayer(GetLocalPlayer())
      local sy = p.id
      if Xuanze[sy] then
        local u = getunit(Hero[sy])
        local uis = HeroState[sy]
        uis:show()
      end
    end,
    on_button_key_up = function(self, str)
      local p = getplayer(GetLocalPlayer())
      local sy = p.id
      if Xuanze[sy] then
        local u = getunit(Hero[sy])
        local uis = HeroState[sy]
        uis:hide()
        if UIS_ChatShow then
          UIS_ChatShow = false
          uiy_hide()
        end
      end
    end,
    on_button_clicked = function(self)
      self:set_control_size(self:get_width() * 0.95, self:get_height() * 0.95)
      ac.wait(100, function()
        self:set_control_size(self:get_width() / 0.95, self:get_height() / 0.95)
      end)
      local p = getplayer(GetLocalPlayer())
      local sy = p.id
      if Xuanze[sy] then
        local u = getunit(Hero[sy])
        local uis = HeroState[sy]
        if uis:get_is_show() then
          uis:hide()
        else
          uis:show()
        end
        local su = japi.GetRealSelectUnit()
        if su ~= 0 then
          su = getunit(su)
          if su.handle == u.handle then
            local x, y = u:getxy()
            u:setcamera(x, y)
          else
            u:select()
          end
        end
      end
    end,
    on_button_mouse_enter = function(self)
      local sy = LocalPlayerID
      if Xuanze[sy] then
        local u = getunit(Hero[sy])
        local lv = u:getlevel()
        local exp = GetHeroXP(u.handle) - (lv * (lv + 1) / 2 - 1) * 100
        local needexp = (lv + 1) * 100
        local text = "点击选中并查看英雄详细数据(快捷键TAB)\nExp:" .. math.floor(exp) .. "/" .. math.floor(needexp)
        uiy_show_text(text)
      end
    end,
    on_button_mouse_leave = function(self)
      uiy_hide()
    end
  })
  local uss_sx_lv = class.text:builder({
    parent = ui_alllevel,
    x = 150,
    y = 145,
    w = 1,
    h = 1,
    font_size = 15,
    text = "",
    align = "right"
  })
  uss_sx_lv:set_color("FFFDBF19")
  uss_sx_lv:set_level(3)
  local ui_topleft_szzph
  local ui_topleft_szz = class.button:builder({
    parent = ui_topleft,
    x = 220,
    y = 35,
    w = 1,
    h = 1,
    normal_image = "Touming.tga"
  })
  ui_topleft_szzph = class.panel:builder({
    parent = ui_topleft_szz,
    x = 0,
    y = 5,
    w = 322.48125,
    h = 52.806250000000006,
    normal_image = "UI_S_Fangxing.blp"
  })
  do
    local ui_topleft_z_jnl = class.button:builder({
      parent = ui_topleft,
      x = 5,
      y = 120,
      w = 59.15,
      h = 46.15,
      normal_image = "war3mapImported\\BTNTianfu_Mofashu.blp",
      on_button_mousedown = function(self)
        self:set_control_size(self:get_width() * 0.9, self:get_height() * 0.9)
        ac.wait(100, function()
          self:set_control_size(self:get_width() / 0.9, self:get_height() / 0.9)
        end)
        local p = getplayer(GetLocalPlayer())
        local sy = p.id
        if Xuanze[sy] then
          local u = getunit(Hero[sy])
          u:select(Ewl_Skill[sy])
        end
      end,
      on_button_mouse_enter = function(self)
        local text = "点击查看额外技能栏(快捷键F2)"
        uiy_show_text(text)
      end,
      on_button_mouse_leave = function(self)
        uiy_hide()
      end
    })
    local ui_topleft_z_sxl = class.button:builder({
      parent = ui_topleft,
      x = 5,
      y = 170,
      w = 59.15,
      h = 46.15,
      normal_image = "war3mapImported\\BTNCommand_Skill.blp",
      on_button_mousedown = function(self)
        self:set_control_size(self:get_width() * 0.9, self:get_height() * 0.9)
        ac.wait(100, function()
          self:set_control_size(self:get_width() / 0.9, self:get_height() / 0.9)
        end)
        local p = getplayer(GetLocalPlayer())
        local sy = p.id
        if Xuanze[sy] then
          local u = getunit(Hero[sy])
          u:select(Ewl_Shuxinglan[sy])
        end
      end,
      on_button_mouse_enter = function(self)
        local text = "点击查看属性栏(快捷键F3)"
        uiy_show_text(text)
      end,
      on_button_mouse_leave = function(self)
        uiy_hide()
      end
    })
    local ui_topleft_z_sxl = class.button:builder({
      parent = ui_topleft,
      x = 5,
      y = 220,
      w = 59.15,
      h = 46.15,
      normal_image = "war3mapImported\\BTNTianfushu.blp",
      on_button_mousedown = function(self)
        self:set_control_size(self:get_width() * 0.9, self:get_height() * 0.9)
        ac.wait(100, function()
          self:set_control_size(self:get_width() / 0.9, self:get_height() / 0.9)
        end)
        local p = getplayer(GetLocalPlayer())
        local sy = p.id
        if Xuanze[sy] then
          local u = getunit(Hero[sy])
          u:select(TalentDw[sy])
        end
      end,
      on_button_mouse_enter = function(self)
        local text = "点击查看英雄天赋树(快捷键F5)"
        uiy_show_text(text)
      end,
      on_button_mouse_leave = function(self)
        uiy_hide()
      end
    })
  end
  do
    local dsx = 16.25
    local dsy = 8.75
    local ddx = 60.0
    local size = 1.25
    local ui_topleft_szsmall_1 = class.button:builder({
      parent = ui_topleft_szzph,
      x = dsx + ddx * 0,
      y = dsy,
      w = size * 0.4 * 91,
      h = size * 0.4 * 71,
      normal_image = "UI_NewB_P1.tga",
      on_button_mousedown = function(self)
        local p = getplayer(GetLocalPlayer())
        local sy = p.id
        if Xuanze[sy] then
          local u = getunit(Hero[sy])
          u:select(Ewl_Body[sy])
        end
      end,
      on_button_mouse_enter = function(self)
        local text = "点击查看|cFF33CC33以太栏|r"
        uiy_show_text(text)
        self:set_control_size(size * 0.5 * 91, size * 0.5 * 71)
      end,
      on_button_mouse_leave = function(self)
        uiy_hide()
        self:set_control_size(size * 0.4 * 91, size * 0.4 * 71)
      end
    })
    local ui_topleft_szsmall_2 = class.button:builder({
      parent = ui_topleft_szzph,
      x = dsx + ddx * 1,
      y = dsy,
      w = size * 0.4 * 91,
      h = size * 0.4 * 71,
      normal_image = "UI_NewB_P2.tga",
      on_button_mousedown = function(self)
        local p = getplayer(GetLocalPlayer())
        local sy = p.id
        if Xuanze[sy] then
          local u = getunit(Hero[sy])
          u:select(Ewl_Mind[sy])
        end
      end,
      on_button_mouse_enter = function(self)
        local text = "点击查看|cFF3366FF精神栏|r"
        uiy_show_text(text)
        self:set_control_size(size * 0.5 * 91, size * 0.5 * 71)
      end,
      on_button_mouse_leave = function(self)
        uiy_hide()
        self:set_control_size(size * 0.4 * 91, size * 0.4 * 71)
      end
    })
    local ui_topleft_szsmall_3 = class.button:builder({
      parent = ui_topleft_szzph,
      x = dsx + ddx * 2,
      y = dsy,
      w = size * 0.4 * 91,
      h = size * 0.4 * 71,
      normal_image = "UI_NewB_P3.tga",
      on_button_mousedown = function(self)
        local p = getplayer(GetLocalPlayer())
        local sy = p.id
        if Xuanze[sy] then
          local u = getunit(Hero[sy])
          u:select(Ewl_Third[sy])
        end
      end,
      on_button_mouse_enter = function(self)
        local text = "点击查看|cFFFFCC00传奇栏|r"
        uiy_show_text(text)
        self:set_control_size(size * 0.5 * 91, size * 0.5 * 71)
      end,
      on_button_mouse_leave = function(self)
        uiy_hide()
        self:set_control_size(size * 0.4 * 91, size * 0.4 * 71)
      end
    })
    local ui_topleft_szsmall_4 = class.button:builder({
      parent = ui_topleft_szzph,
      x = dsx + ddx * 3,
      y = dsy,
      w = size * 0.4 * 91,
      h = size * 0.4 * 71,
      normal_image = "UI_NewB_P4.tga",
      on_button_mousedown = function(self)
        local p = getplayer(GetLocalPlayer())
        local sy = p.id
        if Xuanze[sy] then
          local u = getunit(Hero[sy])
          u:select(Ewl_Blood[sy])
          local hero = u
          local str = ""
          for index, value in ipairs(BloodType) do
            if hero:getdata(value.name .. "血统补正浓度") ~= 0 then
              str = str .. value.color .. math.floor(100 * hero:getdata(value.name .. "血统补正浓度") / hero:getdata("总血统补正浓度")) .. "%|r/"
            end
          end
          str = string.sub(str, 1, -2)
          if str ~= "" then
            hero:sendmessage(str)
          else
            hero:sendmessage("|cFF7DBEF1纯净|r")
          end
          hero:sendmessage("|cFF7DBEF1总血统浓度:" .. string.format("%.0f", hero:getdata("总血统补正浓度")) .. "%/" .. string.format("%.0f", hero:getdata("血统浓度上限") + 1.0E-4) .. "%|r")
          if 0 < Race_Dragon_Nd[sy] then
            hero:sendmessage("|cFF7DBEF1龙血纯度:|r" .. Race_Dragon_Cdxs_Str[sy])
            hero:sendmessage("|cFF7DBEF1龙血浓度:" .. math.floor(Race_Dragon_Nd[sy] * 100) .. "%|r")
          end
        end
      end,
      on_button_mouse_enter = function(self)
        local text = "点击查看|cFFCC0000血统栏|r"
        uiy_show_text(text)
        self:set_control_size(size * 0.5 * 91, size * 0.5 * 71)
      end,
      on_button_mouse_leave = function(self)
        uiy_hide()
        self:set_control_size(size * 0.4 * 91, size * 0.4 * 71)
      end
    })
    local ui_topleft_szsmall_5 = class.button:builder({
      parent = ui_topleft_szzph,
      x = dsx + ddx * 4,
      y = dsy,
      w = size * 0.4 * 91,
      h = size * 0.4 * 71,
      normal_image = "UI_NewB_P6.tga",
      on_button_mousedown = function(self)
        local p = getplayer(GetLocalPlayer())
        local sy = p.id
        if Xuanze[sy] then
          local u = getunit(Hero[sy])
          if UI_Wslt:get_is_show() then
            UI_Wslt:hide()
          else
            UI_Wslt:show()
          end
        end
      end,
      on_button_mouse_enter = function(self)
        local text = "点击查看|cFFFF99FF往|r|cFFEB8FFF世|r|cFFD685FF乐|r|cFFC27AFF土|r"
        uiy_show_text(text)
        self:set_control_size(size * 0.5 * 91, size * 0.5 * 71)
      end,
      on_button_mouse_leave = function(self)
        uiy_hide()
        self:set_control_size(size * 0.4 * 91, size * 0.4 * 71)
      end
    })
  end
  do
    local ui_topleft_fk = class.button:builder({
      parent = ui_alllevel,
      x = 230,
      y = 0,
      w = 149.058,
      h = 31.382,
      normal_image = "UI_S_Fangxing.blp",
      sync_key = "ui_topleft_gold",
      on_button_clicked = function(self)
        self:add_cd_animation(0, 0, 1, 1)
        self:set_cd(SYNC_BUTTON_CD, SYNC_BUTTON_CD)
      end,
      on_sync_button_clicked = function(self, p, button)
        p = getplayer(p.handle)
        local sy = p.id
        if Xuanze[sy] then
          local u = getunit(Hero[sy])
          u:chat("剩余积分:" .. u:getgold())
        end
      end,
      on_button_mouse_enter = function(self)
        local text = "|cFF6699FF积分\n用于各种NPC处消费|r"
        uiy_show_text(text)
      end,
      on_button_mouse_leave = function(self)
        uiy_hide()
      end
    })
    ui_topleft_fk:set_level(2)
    local ui_topleft_fkph = class.panel:builder({
      parent = ui_topleft_fk,
      x = 6,
      y = 5,
      w = 25.480000000000004,
      h = 19.880000000000003,
      normal_image = "UI_S_Gold.blp"
    })
    local ui_topleft_fktext = class.text:builder({
      parent = ui_topleft_fk,
      x = 140,
      y = 16,
      w = 1,
      h = 1,
      font_size = 10,
      text = "0",
      align = "right"
    })
    local ui_topleft_fk2 = class.button:builder({
      parent = ui_alllevel,
      x = 400,
      y = 0,
      w = 149.058,
      h = 31.382,
      normal_image = "UI_S_Fangxing.blp",
      sync_key = "ui_topleft_wood",
      on_button_clicked = function(self)
        self:add_cd_animation(0, 0, 1, 1)
        self:set_cd(SYNC_BUTTON_CD, SYNC_BUTTON_CD)
      end,
      on_sync_button_clicked = function(self, p, button)
        p = getplayer(p.handle)
        local sy = p.id
        if Xuanze[sy] then
          local u = getunit(Hero[sy])
          u:chat("剩余追忆值:" .. string.format("%.1f", u:getwood()))
        end
      end,
      on_button_mouse_enter = function(self)
        local text = "|cFFFF99FF追忆值\n在往世乐土中使用|r"
        uiy_show_text(text)
      end,
      on_button_mouse_leave = function(self)
        uiy_hide()
      end
    })
    ui_topleft_fk2:set_level(3)
    local ui_topleft_fk2ph = class.panel:builder({
      parent = ui_topleft_fk2,
      x = 6,
      y = 5,
      w = 25.480000000000004,
      h = 19.880000000000003,
      normal_image = "UI_S_Wood.blp"
    })
    local ui_topleft_fk2text = class.text:builder({
      parent = ui_topleft_fk2,
      x = 140,
      y = 16,
      w = 1,
      h = 1,
      font_size = 10,
      text = "0",
      align = "right"
    })
    local ui_topleft_fk3 = class.button:builder({
      parent = ui_alllevel,
      x = 570,
      y = 0,
      w = 149.058,
      h = 31.382,
      normal_image = "UI_S_Fangxing.blp",
      sync_key = "ui_topleft_canji",
      on_button_clicked = function(self)
        self:add_cd_animation(0, 0, 1, 1)
        self:set_cd(SYNC_BUTTON_CD, SYNC_BUTTON_CD)
      end,
      on_sync_button_clicked = function(self, p, button)
        p = getplayer(p.handle)
        local sy = p.id
        if Xuanze[sy] then
          local u = getunit(Hero[sy])
          u:chat("剩余残机:" .. u:getdata("残机剩余数量"))
        end
      end,
      on_button_mouse_enter = function(self)
        local text = "|cFFFF66FF残机\n杀敌积分达到一定数值时获取\n死亡时会消耗残机复活|r"
        uiy_show_text(text)
      end,
      on_button_mouse_leave = function(self)
        uiy_hide()
      end
    })
    ui_topleft_fk3:set_level(3)
    local ui_topleft_fk3ph = class.panel:builder({
      parent = ui_topleft_fk3,
      x = 6,
      y = 5,
      w = 25.480000000000004,
      h = 19.880000000000003,
      normal_image = "UI_S_1Up.blp"
    })
    local ui_topleft_fk3text = class.text:builder({
      parent = ui_topleft_fk3,
      x = 140,
      y = 16,
      w = 1,
      h = 1,
      font_size = 10,
      text = "0",
      align = "right"
    })
    ui_topleft_exp:set_color(4281597747)
    ui_topleft_exp:set_scale(0.67, 0.67, 0.67)
    ui_topleft_exphide:set_scale(0.658, 0.658, 0.658)
    ui_topleft_exphide:set_animation(0, false)
    ui_topleft_exphide:set_progress(0.999)
    ac.loop(200, function()
      if not IsWindowActive() then
        return
      end
      local player_id = LocalPlayerID
      if not Xuanze[player_id] then
        return
      end
      local hero = getunit(Hero[player_id])
      local level = hero:getlevel()
      local experience = GetHeroXP(hero.handle) - (level * (level + 1) / 2 - 1) * 100
      local required_experience = (level + 1) * 100
      update_cache.set_text(ui_topleft_fktext, hero:getgold())
      update_cache.set_text(ui_topleft_fk2text, string.format("%.1f", hero:getwood()))
      update_cache.set_text(ui_topleft_fk3text, hero:getdata("残机剩余数量"))
      update_cache.set_progress(ui_topleft_exphide, util.safe_inverse_ratio(experience, required_experience))
      update_cache.set_text(uss_sx_lv, "Lv." .. level)
      if hero:hasdata("单位-左上头像") then
        update_cache.set_image(ui_topleft_icon, hero:getdata("单位-左上头像"))
      end
    end)
  end
end
local environment_text = require("gameplay.interface.ui.yuansheng.clock")
require("gameplay.interface.ui.yuansheng.backpack")
do
  local unithpstate = class.panel:builder({
    x = 645,
    y = 920,
    w = 1,
    h = 1,
    normal_image = "Touming.tga"
  })
  local uss_nameitem = class.text:builder({
    x = 510,
    y = 890,
    w = 1,
    h = 1,
    font_size = 11,
    text = "",
    align = "center"
  })
  local uss_hp = class.model:builder({
    parent = unithpstate,
    model = "bar_red.mdx",
    x = 0,
    y = 0,
    w = 0,
    h = 0,
    uihide = {
      type = "model",
      model = "bar_unit_black.mdx"
    }
  })
  uss_hp:set_speed(0.1)
  local uss_hp_show = class.text:builder({
    parent = uss_hp,
    x = 335,
    y = 75,
    w = 1,
    h = 1,
    font_size = 12,
    text = "",
    align = "center"
  })
  local uss_hp_hf = class.text:builder({
    parent = uss_hp,
    x = 663,
    y = 75,
    w = 1,
    h = 1,
    font_size = 10,
    text = "",
    align = "right"
  })
  local uss_hp_hdz = class.text:builder({
    parent = uss_hp,
    x = 10,
    y = 75,
    w = 1,
    h = 1,
    font_size = 11,
    text = "",
    align = "left"
  })
  uss_hp_hf:set_color("FF66FF99")
  uss_hp_hdz:set_color("FF99CCFF")
  uss_hp_hdz:hide()
  local progress = uss_hp.uihide
  uss_hp:set_scale(1, 1, 1)
  uss_hp:set_color(4280270592)
  uss_hp:set_animation(0, true)
  progress:set_animation(0, false)
  local uss_tili = class.model:builder({
    parent = unithpstate,
    model = "bar_red.mdx",
    x = 0,
    y = 35,
    w = 0,
    h = 0,
    uihide = {
      type = "model",
      model = "bar_unit_black.mdx"
    }
  })
  uss_tili:set_speed(0.1)
  local uss_tili_show = class.text:builder({
    parent = uss_tili,
    x = 175,
    y = 75,
    w = 1,
    h = 1,
    font_size = 12,
    text = "",
    align = "center"
  })
  local uss_tili_hf = class.text:builder({
    parent = uss_tili,
    x = 328,
    y = 75,
    w = 1,
    h = 1,
    font_size = 10,
    text = "",
    align = "right"
  })
  uss_tili_hf:set_color("FF00FFFF")
  local progress = uss_tili.uihide
  uss_tili:set_scale(0.5, 1, 1)
  uss_tili:set_color(4288282623)
  uss_tili:set_animation(0, true)
  progress:set_animation(0, false)
  progress:set_scale(0.5, 1, 1)
  progress:set_size(1)
  local uss_mp = class.model:builder({
    parent = unithpstate,
    model = "bar_red.mdx",
    x = 336,
    y = 35,
    w = 0,
    h = 0,
    uihide = {
      type = "model",
      model = "bar_unit_black.mdx"
    }
  })
  uss_mp:set_speed(0.1)
  local uss_mp_show = class.text:builder({
    parent = uss_mp,
    x = 175,
    y = 75,
    w = 1,
    h = 1,
    font_size = 12,
    text = "",
    align = "center"
  })
  local uss_mp_hf = class.text:builder({
    parent = uss_mp,
    x = 328,
    y = 75,
    w = 1,
    h = 1,
    font_size = 10,
    text = "",
    align = "right"
  })
  uss_mp_hf:set_color("FF6699FF")
  local progress = uss_mp.uihide
  uss_mp:set_scale(0.5, 1, 1)
  uss_mp:set_color(4281558783)
  uss_mp:set_animation(0, true)
  progress:set_animation(0, false)
  progress:set_scale(0.5, 1, 1)
  progress:set_size(1)
  local uss_jht = class.model:builder({
    parent = unithpstate,
    model = "bar_red.mdx",
    x = 336,
    y = 35,
    w = 0,
    h = 0,
    uihide = {
      type = "model",
      model = "bar_unit_black.mdx"
    }
  })
  local uss_jht_show, uss_jht_text
  uss_jht:set_speed(0.1)
  uss_jht_show = class.text:builder({
    parent = uss_jht,
    x = 175,
    y = 75,
    w = 1,
    h = 1,
    font_size = 12,
    text = "",
    align = "center"
  })
  uss_jht_text = class.text:builder({
    parent = uss_jht,
    x = 8,
    y = 75,
    w = 1,
    h = 1,
    font_size = 9,
    text = "|cffff40bc锯环残响:",
    align = "left"
  })
  do
    local progress = uss_jht.uihide
    uss_jht:set_scale(0.5, 1, 1)
    uss_jht:set_color(4294940893)
    uss_jht:set_animation(0, true)
    progress:set_animation(0, false)
    progress:set_scale(0.5, 1, 1)
    progress:set_size(1)
  end
  local uss_name = class.text:builder({
    parent = unithpstate,
    x = -135,
    y = -30,
    w = 1,
    h = 1,
    font_size = 11,
    text = "",
    align = "center"
  })
  local uss_name2 = class.text:builder({
    parent = unithpstate,
    x = -135,
    y = -50,
    w = 1,
    h = 1,
    font_size = 11,
    text = "",
    align = "center"
  })
  local uss_phshow = class.panel:builder({
    parent = unithpstate,
    x = -233,
    y = -5,
    w = 200.20000000000002,
    h = 156.20000000000002,
    normal_image = "Touming.blp"
  })
  local ui = japi.DzFrameGetPortrait()
  japi.FrameShow(ui, true)
  japi.DzFrameClearAllPoints(ui)
  japi.DzFrameSetAbsolutePoint(ui, 4, 0.215, 0.05)
  japi.DzFrameSetSize(ui, 0.0865, 0.0865)
  
  local function create_bar_text(parent, x, y, font_size, text, align)
    return class.text:builder({
      parent = parent,
      x = x,
      y = y,
      w = 1,
      h = 1,
      font_size = font_size,
      text = text or "",
      align = align
    })
  end
  
  local function create_resource_bar(options)
    local bar = class.model:builder({
      parent = unithpstate,
      model = "bar_red.mdx",
      x = options.x or 0,
      y = -35,
      w = 0,
      h = 0,
      uihide = {
        type = "model",
        model = "bar_unit_black.mdx"
      }
    })
    bar:set_speed(0.1)
    bar:set_color(options.color)
    if options.animate then
      bar:set_animation(0, true)
    end
    bar.uihide:set_animation(0, false)
    if options.scale then
      bar:set_scale(options.scale, 1, 1)
      bar.uihide:set_scale(options.scale, 1, 1)
    end
    local label
    if options.label then
      label = create_bar_text(bar, 10, options.label_y or 74, 10, options.label, "left")
    end
    local value = create_bar_text(bar, options.value_x or 335, 75, 12, "", "center")
    return bar, value, label
  end
  
  local uss_spe_1, uss_spe_1_show = create_resource_bar({
    color = 4294940928,
    animate = true,
    scale = 1,
    label = "|cFFFF9900弹药:",
    label_y = 73
  })
  local uss_spe_2, uss_spe_2_show = create_resource_bar({
    x = 336,
    color = 4294940928,
    animate = true,
    scale = 0.5,
    value_x = 170
  })
  local uss_spe_3, uss_spe_3_show, uss_spe_3_text = create_resource_bar({
    color = 4278190335,
    animate = true,
    label = "|cFF6699FF魔术回路值:"
  })
  local uss_spe_3_text2 = create_bar_text(uss_spe_3, 665, 74, 10, "连携点数:", "right")
  local uss_spe_3_text3 = create_bar_text(uss_spe_3, 535, 74, 10, "连击时间:", "right")
  uss_spe_3_text2:set_color("FF6699FF")
  uss_spe_3_text3:set_color("FF6699FF")
  local uss_spe_4, uss_spe_4_show = create_resource_bar({
    color = 4294928127,
    label = "|cFFFF99FF拔刀时间:"
  })
  local uss_spe_4_text2 = create_bar_text(uss_spe_4, 665, 74, 10, "拔刀强度:", "right")
  uss_spe_4_text2:set_color("FFFF99FF")
  local uss_spe_5, uss_spe_5_show = create_resource_bar({
    color = 4294928127,
    scale = 0.5,
    label = "|cFFFF99FF精神值:",
    value_x = 175
  })
  local uss_spe_5_text2 = create_bar_text(uss_spe_5, 345, 74, 10, "", "left")
  local uss_spe_6, uss_spe_6_show, uss_spe_6_text = create_resource_bar({
    color = 4284914175,
    label = "|cff8db3ff剑气值:"
  })
  local uss_spe_7, uss_spe_7_show, uss_spe_7_text = create_resource_bar({
    color = 4279745512,
    label = "|cFFDAF6F7奥义充能值:"
  })
  local uss_spe_8, uss_spe_8_show = create_resource_bar({
    color = 4292565600,
    label = "|cffff525b共鸣解放值:"
  })
  local psize = 0.25
  local cs = 5
  local statex = -255
  local uss_sx_attack = class.text:builder({
    parent = unithpstate,
    x = statex,
    y = cs,
    w = 1,
    h = 1,
    font_size = 8,
    text = "100",
    align = "right"
  })
  local uss_sx_attack_p = class.panel:builder({
    parent = uss_sx_attack,
    x = -91 * psize,
    y = -71 * psize * 0.2,
    w = 91 * psize,
    h = 71 * psize,
    normal_image = "UI_S_Attack.blp",
    align = "right"
  })
  uss_sx_attack:set_color("FFFDBF19")
  local uss_sx_fangyu = class.text:builder({
    parent = unithpstate,
    x = statex,
    y = cs + 25,
    w = 1,
    h = 1,
    font_size = 8,
    text = "100",
    align = "right"
  })
  local uss_sx_fangyu_p = class.panel:builder({
    parent = uss_sx_fangyu,
    x = -91 * psize,
    y = -71 * psize * 0.2,
    w = 91 * psize,
    h = 71 * psize,
    normal_image = "UI_S_Fangyu.blp",
    align = "right"
  })
  uss_sx_fangyu:set_color("FFFDBF19")
  local uss_sx_shecheng = class.text:builder({
    parent = unithpstate,
    x = statex,
    y = cs + 50,
    w = 1,
    h = 1,
    font_size = 8,
    text = "100",
    align = "right"
  })
  local uss_sx_shecheng_p = class.panel:builder({
    parent = uss_sx_shecheng,
    x = -91 * psize,
    y = -71 * psize * 0.2,
    w = 91 * psize,
    h = 71 * psize,
    normal_image = "UI_S_Shecheng.blp",
    align = "right"
  })
  uss_sx_shecheng:set_color("FFFDBF19")
  local uss_sx_yisu = class.text:builder({
    parent = unithpstate,
    x = statex,
    y = cs + 75,
    w = 1,
    h = 1,
    font_size = 8,
    text = "100",
    align = "right"
  })
  local uss_sx_yisu_p = class.panel:builder({
    parent = uss_sx_yisu,
    x = -91 * psize,
    y = -71 * psize * 0.2,
    w = 91 * psize,
    h = 71 * psize,
    normal_image = "UI_S_Move.blp",
    align = "right"
  })
  uss_sx_yisu:set_color("FFFDBF19")
  local uss_sx_str = class.text:builder({
    parent = unithpstate,
    x = statex,
    y = cs + 100,
    w = 1,
    h = 1,
    font_size = 8,
    text = "100",
    align = "right"
  })
  local uss_sx_str_p = class.panel:builder({
    parent = uss_sx_str,
    x = -91 * psize,
    y = -71 * psize * 0.2,
    w = 91 * psize,
    h = 71 * psize,
    normal_image = "UI_S_STR.blp",
    align = "right"
  })
  uss_sx_str:set_color("FFEE3E06")
  local uss_sx_agi = class.text:builder({
    parent = unithpstate,
    x = statex,
    y = cs + 119,
    w = 1,
    h = 1,
    font_size = 8,
    text = "100",
    align = "right"
  })
  local uss_sx_agi_p = class.panel:builder({
    parent = uss_sx_agi,
    x = -91 * psize,
    y = -71 * psize * 0.2,
    w = 91 * psize,
    h = 71 * psize,
    normal_image = "UI_S_AGI.blp",
    align = "right"
  })
  uss_sx_agi:set_color("FF1EA826")
  local uss_sx_int = class.text:builder({
    parent = unithpstate,
    x = statex,
    y = cs + 138,
    w = 1,
    h = 1,
    font_size = 8,
    text = "100",
    align = "right"
  })
  local uss_sx_int_p = class.panel:builder({
    parent = uss_sx_int,
    x = -91 * psize,
    y = -71 * psize * 0.2,
    w = 91 * psize,
    h = 71 * psize,
    normal_image = "UI_S_INT.blp",
    align = "right"
  })
  uss_sx_int:set_color("FF008294")
  local last_invalid_handle
  local dual_wield_layout = false
  ac.loop(100, function()
    if not IsWindowActive() then
      return
    end
    local su = japi.GetRealSelectUnit()
    if su and su ~= 0 then
      unithpstate:show()
      su = getunit(su)
      local typeid = GetUnitTypeId(su.handle)
      local typestr = ID2S(typeid)
      if typeid == 0 then
        unithpstate:hide()
        if last_invalid_handle ~= su.handle then
          last_invalid_handle = su.handle
          print("尝试UI选中不存在的单位类型")
        end
        return
      end
      last_invalid_handle = nil
      if su:hasdata("模型-名字") then
        update_cache.set_text(uss_name, su:getdata("模型-名字"))
      else
        update_cache.set_text(uss_name, GetUnitName(su.handle))
      end
      if su:hasdata("单位-大头像") then
        update_cache.set_image(uss_phshow, su:getdata("单位-大头像"))
        uss_phshow:show()
      else
        uss_phshow:hide()
      end
      local nowhp = su:gethp()
      local hpmax = su:getmaxhp()
      local hp = util.safe_ratio(nowhp, hpmax)
      update_cache.set_text(uss_hp_show, math.floor(nowhp) .. " / " .. math.floor(hpmax))
      update_cache.set_progress(uss_hp.uihide, hp)
      local mpmax = su:getmaxmp()
      if su:hasdata("英雄-千咲") then
        mpmax = 0
        uss_jht:show()
        local now = su:getdata("千咲-锯环残响值")
        local max = su:getdata("千咲-锯环残响值上限")
        local tili = util.safe_ratio(now, max)
        update_cache.set_text(uss_jht_show, math.floor(now) .. " / " .. math.floor(max))
        update_cache.set_progress(uss_jht.uihide, tili)
      else
        uss_jht:hide()
      end
      if 0 < mpmax then
        local nowmp = su:getmp()
        uss_mp:show()
        local mp = util.safe_ratio(nowmp, mpmax)
        update_cache.set_text(uss_mp_show, math.floor(nowmp) .. " / " .. math.floor(mpmax))
        update_cache.set_progress(uss_mp.uihide, mp)
        if su:hasdata("系统-英雄") then
          if not uss_mp_hf:get_is_show() then
            uss_mp_hf:show()
            uss_mp_show:set_position(175, 75)
            uss_mp:set_position(336, 35)
            uss_mp:set_scale(0.5, 1, 1)
            uss_mp.uihide:set_scale(0.5, 1, 1)
          end
          local change = su:getdata("系统-目前魔法值变动")
          local str = string.format("%.1f", change)
          if 0 <= change then
            update_cache.set_text(uss_mp_hf, "+" .. str)
          else
            update_cache.set_text(uss_mp_hf, "|cFFCC0000" .. str)
          end
        elseif uss_mp_hf:get_is_show() then
          uss_mp_hf:hide()
          uss_mp:set_position(0, 35)
          uss_mp_show:set_position(335, 75)
          uss_mp:set_scale(2, 1, 1)
          uss_mp.uihide:set_scale(2, 1, 1)
        end
      else
        uss_mp:hide()
      end
      local unit_slk = typestr and slk.unit[typestr]
      if unit_slk and tonumber(unit_slk.weapsOn) == 0 then
        update_cache.set_text(uss_sx_attack, 0)
        update_cache.set_text(uss_sx_shecheng, 0)
      else
        update_cache.set_text(uss_sx_attack, math.floor(GetUnitState(su.handle, ConvertUnitState(18))))
        update_cache.set_text(uss_sx_shecheng, math.floor(GetUnitState(su.handle, ConvertUnitState(22))))
      end
      if su:hasbuff("位移闪避") then
        update_cache.set_text(uss_sx_fangyu, "|cFFCC0000位移闪避|r")
      elseif su:hasbuff("永恒") then
        update_cache.set_text(uss_sx_fangyu, "|cFFCC0000永|r|cFFAA1155恒|r")
      elseif 0 < su:getdata("绝对闪避时间") then
        update_cache.set_text(uss_sx_fangyu, "绝对闪避")
      elseif su:hasdata("系统-无敌") or su:hasbuff("无敌") then
        update_cache.set_text(uss_sx_fangyu, "无敌")
      elseif su:hasbuff("无实体") then
        update_cache.set_text(uss_sx_fangyu, "|cFFCCFFCC无|r|cFFBFE6BF实|r|cFFB2CCB2体|r")
      else
        update_cache.set_text(uss_sx_fangyu, math.floor(GetUnitState(su.handle, ConvertUnitState(32))))
      end
      if su:hasdata("系统-英雄") then
        local sy = su.ownerid
        uss_sx_str:show()
        uss_sx_agi:show()
        uss_sx_int:show()
        update_cache.set_text(uss_sx_str, math.floor(su:getoriginstr()))
        update_cache.set_text(uss_sx_agi, math.floor(su:getoriginagi()))
        update_cache.set_text(uss_sx_int, math.floor(su:getoriginint()))
        update_cache.set_text(uss_sx_yisu, math.floor(GetUnitMoveSpeed(su.handle) + su:getdata("当前显示额外移速")))
        if su:hasdata("UI-精神值") then
          uss_spe_5:show()
          local now = su:getdata("Caber-精神值")
          local max = 100
          local tili = util.safe_ratio(now, max)
          update_cache.set_text(uss_spe_5_show, math.floor(now) .. " / " .. math.floor(max))
          update_cache.set_progress(uss_spe_5.uihide, tili)
          local zb = false
          local str = "|cFFFF9900武装魔导术形态:"
          if su:getdata("Caber-枪支类型") == 1 then
            zb = true
            str = str .. "魔力弹"
          end
          if su:getdata("Caber-枪支类型") == 2 then
            zb = true
            str = str .. "魔炮"
          end
          if su:getdata("Caber-枪支类型") == 3 then
            zb = true
            str = str .. "魔力爆破"
          end
          str = str .. "|r"
          if zb then
            update_cache.set_text(uss_spe_5_text2, str)
          else
            update_cache.set_text(uss_spe_5_text2, "")
          end
        else
          uss_spe_5:hide()
        end
        if su:hasdata("UI-拔刀强度条") then
          uss_spe_4:show()
          local now = su:getdata("八重樱-拔刀时间")
          local max = su:getdata("八重樱-拔刀时间上限")
          local tili = util.safe_ratio(now, max)
          update_cache.set_text(uss_spe_4_show, string.format("%.1f", now) .. " / " .. string.format("%.1f", max))
          update_cache.set_progress(uss_spe_4.uihide, tili)
          update_cache.set_text(uss_spe_4_text2, "拔刀强度:" .. math.floor(su:getdata("八重樱-拔刀强度") * 100) .. "%")
        else
          uss_spe_4:hide()
        end
        if su:hasdata("英雄-千咲") then
          uss_spe_8:show()
          local now = su:getdata("千咲-共鸣解放值")
          local max = su:getdata("千咲-共鸣解放值上限")
          local tili = util.safe_ratio(now, max)
          update_cache.set_text(uss_spe_8_show, math.floor(now) .. " / " .. math.floor(max))
          update_cache.set_progress(uss_spe_8.uihide, tili)
        else
          uss_spe_8:hide()
        end
        if su:hasdata("UI-剑气槽") then
          uss_spe_6:show()
          local now = su:getdata("妖梦-剑气值")
          local max = su:getdata("妖梦-剑气值上限")
          local tili = util.safe_ratio(now, max)
          update_cache.set_text(uss_spe_6_show, math.floor(now) .. " / " .. math.floor(max))
          if su:hasdata("剑气槽颜色改变") then
            update_cache.set_color(uss_spe_6, su:getdata("剑气槽颜色改变"))
            update_cache.set_text(uss_spe_6_text, "|cFFCC99FF剑气值:")
          end
          update_cache.set_progress(uss_spe_6.uihide, tili)
        else
          uss_spe_6:hide()
        end
        if su:hasdata("UI-奥义充能槽") then
          uss_spe_7:show()
          local now = su:getdata("波风水门-奥义充能值")
          local max = su:getdata("波风水门-奥义充能上限")
          local tili = util.safe_ratio(now, max)
          update_cache.set_text(uss_spe_7_show, math.floor(now) .. " / " .. math.floor(max))
          if 0.9999 <= tili then
            update_cache.set_color(uss_spe_7, 4294953984)
            update_cache.set_text(uss_spe_7_text, "|cFFFF9900奥义充能值:")
          else
            update_cache.set_color(uss_spe_7, 4279745512)
            update_cache.set_text(uss_spe_7_text, "|cFFDAF6F7奥义充能值:")
          end
          update_cache.set_progress(uss_spe_7.uihide, tili)
        else
          uss_spe_7:hide()
        end
        if su:hasdata("UI-魔术回路条") then
          uss_spe_3:show()
          local str = "志贵"
          if su.type == HeroType["两仪式"] then
            str = "两仪式"
          end
          if 0 < su:getdata(str .. "-爆气时间") then
            update_cache.set_text(uss_spe_3_text3, "")
            local now = su:getdata(str .. "-爆气时间")
            local max = su:getdata("UI-爆气上限")
            local tili = util.safe_ratio(now, max)
            update_cache.set_text(uss_spe_3_show, string.format("%.1f", now) .. " / " .. string.format("%.1f", max))
            update_cache.set_progress(uss_spe_3.uihide, tili)
            if su:hasdata(str .. "-BH状态") then
              update_cache.set_color(uss_spe_3, 4291559424)
              update_cache.set_color(uss_spe_3_text2, "FFCC0000")
              update_cache.set_text(uss_spe_3_text, "|cFFFF0000BLOOD HEAT:")
            else
              update_cache.set_color(uss_spe_3, 4281571737)
              update_cache.set_text(uss_spe_3_text, "|cFF66CCCC魔术回路值:MAX%")
              update_cache.set_color(uss_spe_3_text2, "FF66CCCC")
            end
          else
            update_cache.set_color(uss_spe_3_text2, "FF6699FF")
            update_cache.set_color(uss_spe_3, 4278190335)
            local now = su:getdata(str .. "-魔术回路值")
            local max = 300
            local tili = util.safe_ratio(now, max)
            update_cache.set_text(uss_spe_3_show, math.floor(now) .. " / " .. math.floor(max))
            update_cache.set_text(uss_spe_3_text, "|cFF6699FF魔术回路值:")
            update_cache.set_text(uss_spe_3_text3, "连击时间:" .. string.format("%.1f", su:getdata(str .. "-连击时间")))
            update_cache.set_progress(uss_spe_3.uihide, tili)
          end
          update_cache.set_text(uss_spe_3_text2, "连携点数:" .. math.floor(su:getdata(str .. "-连携点数值")))
        else
          uss_spe_3:hide()
        end
        if su:hasdata("UI-弹药显示") and (su:getdata("装备枪支") ~= ITEM_KONG or su:hasdata("英雄-铃仙")) and not su:hasdata("枪械-丧钟") then
          uss_spe_1:show()
          local now = su:getdata("UI-弹药数量")
          local max = su:getdata("UI-弹药数量上限")
          local sw = util.safe_ratio(now, max)
          update_cache.set_text(uss_spe_1_show, math.floor(now) .. " / " .. math.floor(max))
          update_cache.set_progress(uss_spe_1.uihide, sw)
          if su:hasdata("UI-双持") then
            if not dual_wield_layout then
              dual_wield_layout = true
              uss_spe_1:set_scale(0.5, 1, 1)
              uss_spe_1.uihide:set_scale(0.5, 1, 1)
              uss_spe_1_show:set_position(175, 75)
            end
            uss_spe_2:show()
            local now2 = su:getdata("UI-弹药数量2")
            local max2 = su:getdata("UI-弹药数量上限2")
            local sw2 = util.safe_ratio(now2, max2)
            update_cache.set_text(uss_spe_2_show, math.floor(now2) .. " / " .. math.floor(max2))
            update_cache.set_progress(uss_spe_2.uihide, sw2)
          else
            if dual_wield_layout then
              dual_wield_layout = false
              uss_spe_1_show:set_position(335, 75)
              uss_spe_1:set_scale(2, 1, 1)
              uss_spe_1.uihide:set_scale(2, 1, 1)
            end
            uss_spe_2:hide()
          end
        else
          uss_spe_1:hide()
          uss_spe_2:hide()
        end
        update_cache.set_color(uss_hp, 4280270592)
        uss_name2:show()
        update_cache.set_text(uss_name2, GetHeroProperName(su.handle))
        uss_hp_hf:show()
        do
          local change = su:getdata("系统-目前生命值变动") / 0.03
          local str = string.format("%.1f", change)
          if 0 <= change then
            update_cache.set_text(uss_hp_hf, "+" .. str)
          else
            update_cache.set_text(uss_hp_hf, "|cFFCC0000" .. str)
          end
        end
        uss_tili:show()
        do
          local nowtili = Hero_Tili[sy]
          local tilimax = Hero_Tili_Max[sy]
          if Keyan_Jinglikujie then
            tilimax = tilimax * 0.5
          end
          local tili = util.safe_ratio(nowtili, tilimax)
          update_cache.set_text(uss_tili_show, string.format("%.1f", nowtili) .. " / " .. string.format("%.1f", tilimax))
          update_cache.set_progress(uss_tili.uihide, tili)
          uss_tili_hf:show()
          local change = su:getdata("系统-目前体力值变动")
          local str = string.format("%.1f", change)
          if 0 <= change then
            update_cache.set_text(uss_tili_hf, "+" .. str)
          else
            update_cache.set_text(uss_tili_hf, "|cFFCC0000" .. str)
          end
        end
        if 0 < su:getdata("系统-当前护盾值") then
          uss_hp_hdz:show()
          update_cache.set_text(uss_hp_hdz, "보호막:" .. math.floor(su:getdata("系统-当前护盾值")))
        else
          uss_hp_hdz:hide()
        end
      else
        uss_name2:hide()
        if su.ownerid >= 9 then
          update_cache.set_color(uss_hp, 4291559424)
        else
          update_cache.set_color(uss_hp, 4280270592)
        end
        uss_hp_hf:hide()
        uss_hp_hdz:hide()
        uss_tili:hide()
        uss_spe_1:hide()
        uss_spe_2:hide()
        uss_spe_3:hide()
        uss_spe_4:hide()
        uss_spe_5:hide()
        uss_spe_6:hide()
        uss_spe_7:hide()
        uss_spe_8:hide()
        uss_sx_str:hide()
        uss_sx_agi:hide()
        uss_sx_int:hide()
        update_cache.set_text(uss_sx_yisu, math.floor(GetUnitMoveSpeed(su.handle)))
      end
    else
      unithpstate:hide()
    end
    local item = 0
    if type(japi.GetRealSelectItem) == "function" then
      item = japi.GetRealSelectItem()
    elseif not HeraSelectedItemNameDeferred then
      HeraSelectedItemNameDeferred = true
      require("hera_boot").note("DEFERRED GetRealSelectItem: selected ground-item name unavailable; HUD updates remain active")
    end
    if item ~= 0 then
      local typestr = ID2S(GetItemTypeId(item))
      if slk.item[typestr] then
        update_cache.set_text(uss_nameitem, slk.item[typestr].Name)
      else
        update_cache.set_text(uss_nameitem, "")
      end
      uss_nameitem:show()
    else
      uss_nameitem:hide()
    end
  end)
end
local tooltip = require("gameplay.interface.ui.yuansheng.tooltip")
return {
  environment_text = environment_text,
  wave_state_text = environment_text.wave_state_text,
  wave_state_time_text = environment_text.wave_state_time_text,
  tooltip = tooltip
}
