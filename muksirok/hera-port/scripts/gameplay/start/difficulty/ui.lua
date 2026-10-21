-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local button_nanduselect = {}
local button_extraselect = {}
local nanduselect, select
local bsize = 1

local function flashshowtext()
  local text = ""
  local xs = 0
  local nanduname = nanduselect.name
  if nanduname == "梦境" then
    xs = 1
    text = text .. "|cFF33FF66Dreamland\n怪物伤害:100%\n怪物生命值:100%\nBOSS伤害:100%\nBOSS生命值:100%|r"
  elseif nanduname == "现实" then
    xs = 5
    text = text .. "|cFFFF3300Real\n怪物伤害:110%\n怪物生命值:120%\nBOSS伤害:110%\nBOSS生命值:168%|r"
  elseif nanduname == "噩梦" then
    xs = 10
    text = text .. "|cFFCCCCCCNightmare\n怪物伤害:120%\n怪物生命值:140%\nBOSS伤害:120%\nBOSS生命值:280%|r"
  elseif nanduname == "地狱" then
    xs = 25
    text = text .. "|cFF990000Hell\n怪物伤害:140%\n怪物生命值:160%\nBOSS伤害:140%\nBOSS生命值:400%|r"
  elseif nanduname == "幻梦" then
    xs = 100
    text = text .. "|cFF6600FFFantasy\n怪物伤害:160%\n怪物生命值:180%\nBOSS伤害:160%\nBOSS生命值:900%|r"
  elseif nanduname == "神兆" then
    xs = 101
    text = text .. "|cFF3333FF☆☆☆恶意模式☆☆☆(不一定适合所有玩家)|r\n|cFF6666FF怪物伤害:180%\n怪物生命值:200%\nBOSS伤害:180%\nBOSS生命值:2000%\nBOSS技能强化(威胁性大幅度提升)|r"
  end
  for index, value in ipairs(button_extraselect) do
    if value.isopen == true then
      text = text .. "\r" .. value.extratext
      xs = xs + value.add
    end
  end
  if xs <= 0 then
    xs = 0
  end
  select.xstext:set_text("|cFF990000混沌系数[" .. math.floor(xs) .. "]")
  select.showtext:set_text(text)
end

select = class.panel:builder({
  x = 200,
  y = 100,
  w = 1500,
  h = 700,
  sync_key = "modeselect",
  normal_image = "UI_Start_Back.tga",
  on_button_clicked = function(self, button)
    local w, h = button:get_width(), button:get_height()
    local scale = 0.9
    local new_w, new_h = w * scale, h * scale
    local dx, dy = (w - new_w) / 2, (h - new_h) / 2
    local gx, gy = button:get_position()
    button:set_control_size(new_w, new_h)
    button:set_position(gx + dx, gy + dy)
    PlayGlobalSound(UI_Start_MouseDown)
    ac.wait(100, function()
      if button ~= 0 then
        local gx, gy = button:get_position()
        button:set_control_size(w, h)
        button:set_position(gx - dx, gy - dy)
      end
    end)
  end,
  on_sync_button_clicked = function(self, button, p)
    p = getplayer(p.handle)
    if p.id == SeletPlayerID and button:func() ~= false then
      flashshowtext()
    end
  end
})
do
  local start1 = class.text:builder({
    parent = select,
    x = 750,
    y = 30,
    w = 1,
    h = 1,
    text = "游  戏  模  式  选  择",
    align = "center",
    font_size = 16
  })
  local buttontext = class.text:builder({
    parent = select,
    x = 30,
    y = 30,
    w = 1,
    h = 1,
    text = "|cFF990000混沌系数[1]|r",
    align = "left"
  })
  buttontext:set_size(1, "fontnm.ttf")
  select.xstext = buttontext
end
do
  local start2 = class.panel:builder({
    parent = select,
    x = 0,
    y = 80,
    w = 1500,
    h = 30,
    normal_image = "UI_Start_Up.tga"
  })
  local start2text = class.text:builder({
    parent = start2,
    x = 750,
    y = 15,
    w = 1,
    h = 1,
    text = "难       度",
    align = "center",
    font_size = 13
  })
  local text = {
    "梦境",
    "现实",
    "噩梦",
    "地狱",
    "幻梦",
    "神兆"
  }
  local showtext = {
    "梦    境",
    "现    实",
    "噩    梦",
    "地    狱",
    "幻    梦",
    "神    兆"
  }
  for i = 1, #text do
    local button = class.button:builder({
      parent = select,
      x = -40.5 + 201 * i,
      y = 125.5,
      w = bsize * 129,
      h = bsize * 33,
      name = text[i],
      sync_key = "nanduselect_nandu_" .. i,
      normal_image = "UI_Start_Button.blp",
      func = function(self)
        for index, value in ipairs(button_nanduselect) do
          value:set_normal_image("UI_Start_Button.blp")
        end
        nanduselect = self
        self:set_normal_image("UI_Start_Buttondown.blp")
      end,
      on_button_mouse_enter = function(self)
        self.redpanel:show()
        PlayGlobalSound(UI_Start_MouseEnter)
        SetSoundVolume(UI_Start_MouseEnter, 77)
      end,
      on_button_mouse_leave = function(self)
        self.redpanel:hide()
      end
    })
    local redpanel = class.panel:builder({
      parent = button,
      x = 0,
      y = 0,
      w = bsize * 129,
      h = bsize * 33,
      normal_image = "UI_Start_Mouseenter.blp"
    })
    redpanel:hide()
    button.redpanel = redpanel
    table.insert(button_nanduselect, button)
    local buttontext = class.text:builder({
      parent = button,
      x = 63.5,
      y = 17,
      w = 1,
      h = 1,
      text = showtext[i],
      align = "center",
      font_size = 11
    })
    button.showtext = buttontext
    if i == 1 then
      nanduselect = button
      button:set_normal_image("UI_Start_Buttondown.blp")
    end
  end
end
do
  local start3 = class.panel:builder({
    parent = select,
    x = 0,
    y = 175,
    w = 1500,
    h = 30,
    normal_image = "UI_Start_Up.tga"
  })
  local start3text = class.text:builder({
    parent = start3,
    x = 750,
    y = 15,
    w = 1,
    h = 1,
    text = "额  外  模  式",
    align = "center",
    font_size = 13
  })
  local text = {
    {
      name = "混沌原初",
      add = 25,
      text = "|cFF990000神之花瓣与魔之原质不会生效\n只有常规掉落权限生效\n略微提升权限掉落概率|r"
    },
    {
      name = "银河模式",
      add = -1000,
      text = "|cFF66CCFF增强部分效果\n允许复选英雄\n不限制过波时间\n☆不掉落权限☆|r"
    },
    {
      name = "往世乐土",
      add = -1000,
      text = "|cffff98f1往世乐土被极大幅度强化\n杀敌追忆值获取上限翻倍\n交互建筑刷新减半\n不再定时刷新次元匣\n☆不掉落权限☆|r"
    },
    {
      name = "打靶模式",
      add = -1000,
      text = "|cffffe5fb可试用当前的氪金机体和皮肤\n可以输入指令召唤靶子\n游戏环境等同混沌模式与银河模式\n不会刷怪\n无法获取变异|r"
    },
    {
      name = "测试模式",
      add = 0,
      text = "|cFFA6FCF9开启测试内容:\n波数减少\nBOSS连战|r"
    },
    {
      name = "单一神器",
      add = -1000,
      text = "|cFFA6FCF9整局只会出现一种神器\n☆不掉落权限☆|r"
    },
    {
      name = "科研模式",
      add = 25,
      text = "|cff5ddee7出现随机减益效果参数,随着游戏进程推进解锁更多\n提升权限掉落概率\n☆警告:难度可能极高☆\n(初始带有2/3/4个(非幻梦/幻梦/神兆)个参数\n每5/4/3波(非幻梦/幻梦/神兆)解锁一个新的参数\n每击败一个BOSS解锁一个新的参数)|r"
    }
  }
  local cd = 13
  for i = 1, #text do
    local dy = 205 + cd + (cd + 33) * 0
    local dx = -40.5 + 242 * i
    if 5 < i then
      dy = 205 + cd + (cd + 33) * 1
      dx = -40.5 + 242 * (i - 5)
    end
    local button = class.button:builder({
      parent = select,
      x = dx,
      y = dy,
      w = bsize * 129,
      h = bsize * 33,
      name = text[i].name,
      isopen = false,
      extratext = text[i].text,
      add = text[i].add,
      sync_key = "nanduselect_extra_" .. i,
      normal_image = "UI_Start_Button.blp",
      func = function(self)
        if self.isopen then
          self.isopen = false
          self:set_normal_image("UI_Start_Button.blp")
        else
          self.isopen = true
          self:set_normal_image("UI_Start_Buttondown.blp")
        end
      end,
      on_button_mouse_enter = function(self)
        self.redpanel:show()
        PlayGlobalSound(UI_Start_MouseEnter)
        SetSoundVolume(UI_Start_MouseEnter, 77)
      end,
      on_button_mouse_leave = function(self)
        self.redpanel:hide()
      end
    })
    local redpanel = class.panel:builder({
      parent = button,
      x = 0,
      y = 0,
      w = bsize * 129,
      h = bsize * 33,
      normal_image = "UI_Start_Mouseenter.blp"
    })
    redpanel:hide()
    button.redpanel = redpanel
    table.insert(button_extraselect, button)
    local buttontext = class.text:builder({
      parent = button,
      x = 63.5,
      y = 17,
      w = 1,
      h = 1,
      text = text[i].name,
      align = "center",
      font_size = 12
    })
    button.showtext = buttontext
  end
end
do
  local start4 = class.panel:builder({
    parent = select,
    x = 0,
    y = 355,
    w = 1500,
    h = 30,
    normal_image = "UI_Start_Up.tga"
  })
  local start4text = class.text:builder({
    parent = start4,
    x = 750,
    y = 15,
    w = 1,
    h = 1,
    text = "介       绍",
    align = "center",
    font_size = 13
  })
  local start4tip = class.panel:builder({
    parent = start4,
    x = 150,
    y = 27,
    w = 1200,
    h = 248,
    normal_image = "UI_Start_Text.blp"
  })
  local start4tiptext = class.text:builder({
    parent = start4tip,
    x = 9,
    y = 9,
    w = 1,
    h = 1,
    text = "|cFF33FF66Dreamland\n怪物伤害:100%\n怪物生命值:100%\nBOSS伤害:100%\nBOSS生命值:100%|r",
    align = "topleft",
    font_size = 11
  })
  select.showtext = start4tiptext
end
do
  local text = {
    {
      name = "标准模式",
      dx = 415.0,
      func = function()
        for index, value in ipairs(button_nanduselect) do
          if value.name ~= "地狱" then
            value:set_normal_image("UI_Start_Button.blp")
          else
            nanduselect = value
            value:set_normal_image("UI_Start_Buttondown.blp")
          end
        end
        for index, value in ipairs(button_extraselect) do
          if value.name ~= "命运抉择" and value.name ~= "尖塔模式" then
            value.isopen = false
            value:set_normal_image("UI_Start_Button.blp")
          else
            value.isopen = true
            value:set_normal_image("UI_Start_Buttondown.blp")
          end
        end
      end
    },
    {
      name = "新手模式",
      dx = 950.5,
      func = function()
        for index, value in ipairs(button_nanduselect) do
          if value.name ~= "梦境" then
            value:set_normal_image("UI_Start_Button.blp")
          else
            nanduselect = value
            value:set_normal_image("UI_Start_Buttondown.blp")
          end
        end
        for index, value in ipairs(button_extraselect) do
          if value.name ~= "银河模式" and value.name ~= "祝佑模式" then
            value.isopen = false
            value:set_normal_image("UI_Start_Button.blp")
          else
            value.isopen = true
            value:set_normal_image("UI_Start_Buttondown.blp")
          end
        end
      end
    }
  }
  for i = 1, #text do
    local button = class.button:builder({
      parent = select,
      x = text[i].dx,
      y = 648,
      w = bsize * 129,
      h = bsize * 33,
      name = text[i].name,
      sync_key = "nanduselect_moren_" .. i,
      normal_image = "UI_Start_Button.tga",
      func = function(self)
        text[i]:func()
      end,
      on_button_mouse_enter = function(self)
        self.redpanel:show()
        PlayGlobalSound(UI_Start_MouseEnter)
        SetSoundVolume(UI_Start_MouseEnter, 77)
      end,
      on_button_mouse_leave = function(self)
        self.redpanel:hide()
      end
    })
    local redpanel = class.panel:builder({
      parent = button,
      x = 0,
      y = 0,
      w = bsize * 129,
      h = bsize * 33,
      normal_image = "UI_Start_Mouseenter.blp"
    })
    redpanel:hide()
    button.redpanel = redpanel
    local buttontext = class.text:builder({
      parent = button,
      x = 63.5,
      y = 17,
      w = 1,
      h = 1,
      text = text[i].name,
      align = "center",
      font_size = 11
    })
  end
end
local run = false
do
  local button = class.button:builder({
    parent = select,
    x = 615.0,
    y = 640,
    w = 271,
    h = 48,
    sync_key = "nanduselect_end",
    normal_image = "UI_Start_GameStart.blp",
    func = function(self)
      if run then
        return false
      end
      run = true
      for index, value in ipairs(button_extraselect) do
        if value.isopen == true then
          if value.name == "晦暗之夜" then
            ModeSelect_DarkNight = true
          end
          if value.name == "混沌原初" then
            ModeSelect_Difficult = true
          end
          if value.name == "银河模式" then
            ModeSelect_Infinite = true
            IsBOSSDead = true
            ModeSelect_NoDrop = true
          end
          if value.name == "祝佑模式" then
            ModeSelect_Light = true
            ModeSelect_Xinshou = true
          end
          if value.name == "混乱模式" then
            ModeSelect_Muss = true
          end
          if value.name == "末日环境" then
            Boolean_Morihuanjing = true
          end
          if value.name == "测试模式" then
            Boolean_TestMode = true
            Stage_boss = {
              7,
              8,
              9,
              11
            }
          end
          if value.name == "单一神器" then
            Mode_DanyiShenqi = true
          end
          if value.name == "科研模式" then
            Mode_Keyan = true
          end
          if value.name == "复仇模式" then
            ModeSelect_Revenge = true
          end
          if value.name == "往世乐土" then
            Mode_Wangshiletu = true
            ModeSelect_NoDrop = true
          end
          if value.name == "打靶模式" then
            Mode_Dabamoshi = true
            ModeSelect_NoDrop = true
            ModeSelect_Infinite = true
            ModeSelect_Difficult = true
            IsBOSSDead = true
            FogEnable(false)
            FogMaskEnable(false)
          end
        end
      end
      local nanduname = nanduselect.name
      Huanjing_Change = 0.01
      NanduJc_Hp = 1
      NanduJc_Atk = 1
      if nanduname == "梦境" then
        BOSSEWHp = 1
        Nandu_Jianglixishu = 1
        Nandu_Choose = 1
        DayNightSpeed = 0.7
        PlayerGuoboCount = {}
        for i = 1, 6 do
          PlayerGuoboCount[i] = 0
          Hero_Tili_Huifu_Zq[i] = Hero_Tili_Huifu_Zq[i] + 0.4
        end
      elseif nanduname == "现实" then
        BOSSEWHp = 1.4
        NanduJc_Hp = 1.2
        NanduJc_Atk = 1.1
        Nandu_Jianglixishu = 3
        Nandu_Choose = 2
        DayNightSpeed = 0.85
        for i = 1, 6 do
          Hero_Tili_Huifu_Zq[i] = Hero_Tili_Huifu_Zq[i] + 0.2
        end
      elseif nanduname == "噩梦" then
        BOSSEWHp = 2
        NanduJc_Hp = 1.4
        NanduJc_Atk = 1.2
        Nandu_Jianglixishu = 5
        Nandu_Choose = 3
        DayNightSpeed = 1.0
      elseif nanduname == "地狱" then
        BOSSEWHp = 2.5
        NanduJc_Hp = 1.6
        NanduJc_Atk = 1.4
        Nandu_Jianglixishu = 7
        Nandu_Choose = 4
        DayNightSpeed = 1.2
        Boolean_Morihuanjing = true
      elseif nanduname == "幻梦" then
        BOSSEWHp = 5
        NanduJc_Hp = 1.8
        NanduJc_Atk = 1.6
        Nandu_Jianglixishu = 7.7
        Nandu_Choose = 5
        DayNightSpeed = 1.4
        Boolean_Morihuanjing = true
      elseif nanduname == "神兆" then
        BOSSEWHp = 10
        NanduJc_Hp = 2
        NanduJc_Atk = 1.8
        Nandu_Jianglixishu = 7.7
        Nandu_Shenzhao = true
        Nandu_Choose = 5
        DayNightSpeed = 1.4
        Boolean_Morihuanjing = true
      end
      BOSSKX = 0.8 / 1.25 ^ (Nandu_Choose - 1)
      if Nandu_Shenzhao then
        BOSSKX = 0.262144
      end
      difselectact()
      select:hide()
      ac.wait(1000, function()
        select:destroy()
      end)
      ac.wait(1, function()
        if EnableCustomUI then
          require("gameplay.interface.ui.yuansheng")
        else
          require("gameplay.interface.ui.yuansheng.yuansheng2")
        end
        require("gameplay.interface.ui.wslt")
      end)
    end,
    on_button_mouse_enter = function(self)
      self.redpanel:show()
      PlayGlobalSound(UI_Start_MouseEnter)
      SetSoundVolume(UI_Start_MouseEnter, 77)
    end,
    on_button_mouse_leave = function(self)
      self.redpanel:hide()
    end
  })
  local redpanel = class.panel:builder({
    parent = button,
    x = 0,
    y = 0,
    w = 271,
    h = 48,
    normal_image = "UI_Start_Mouseenter.blp"
  })
  redpanel:hide()
  button.redpanel = redpanel
  local buttontext = class.text:builder({
    parent = button,
    x = 135.5,
    y = 24,
    w = 1,
    h = 1,
    text = "开 始 游 戏",
    align = "center",
    font_size = 17
  })
end
