-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local AIManager = require("gameplay.feature.yisi.manager")
local w, h, dx = 88, 68, 1.75
local YisiFunction = {}
YisiSystem = YisiFunction
local YisiIsChatting, UIyschat, createUIButton, GetYisiRandom100, GetYisiRandomInt, YisiFuncAct, YisiFuncAll
local staytime = 0
local dt = 0.05
local YisiRun = true
local YisiRunTime = 0
YisiHelp = false
local YisiXuanxiangchat = false
YisiName = "伊斯特娲儿"
local Yisichattime = 0
local yisirandom = {}
YisiChatButton = {}
local YisiChatButtonText = {}
YisiChatIconText = {}
for i = 1, 6 do
  YisiChatIconText[i] = {}
end
YisiChatIcon = {}
local YisiFunc = {}
setmetatable(YisiFunc, {
  __index = function()
    return function()
    end
  end
})

local function YisiNormalizeIcon(icon)
  icon = tostring(icon or "war3mapImported\\BTNCommand_Skill.blp")
  local lowerFilename = string.lower(icon)
  if not lowerFilename:match("%.tga$") and not lowerFilename:match("%.blp$") then
    icon = icon .. ".tga"
  end
  return icon
end

function YisiFunction.set_help_enabled(enabled)
  YisiHelp = enabled and true or false
end

function YisiFunction.is_help_enabled()
  return YisiHelp == true
end

function YisiFunction.chat(args)
  local u = args.u
  local chat = args.text or ""
  local priority = args.priority or 1
  local breaktime = args.breaktime or 3
  local title = args.title or ""
  if 1 < priority and not UI_YisiChat:get_is_show() then
    UI_YisiChat:show()
    staytime = 5
  end
  if u then
    if u:islocal() then
      local task = {
        type = "聊天",
        text = chat,
        breaktime = breaktime,
        priority = priority,
        title = title
      }
      AIManager.addTask(task)
    end
  else
    local task = {
      type = "聊天",
      text = chat,
      breaktime = breaktime,
      priority = priority,
      title = title
    }
    AIManager.addTask(task)
  end
end

function YisiFunction.optionchat(args)
  local u = args.u
  local chat = args.text or ""
  local priority = args.priority or 1
  local breaktime = args.breaktime or 3
  local type = args.type or "选择项聊天"
  local title = args.title or ""
  if u then
    if u:islocal() then
      local task = {
        type = type,
        text = chat,
        breaktime = breaktime,
        priority = priority,
        title = title,
        selectend = false,
        func = args.func
      }
      AIManager.addTask(task)
    end
  else
    local task = {
      type = type,
      text = chat,
      breaktime = breaktime,
      priority = priority,
      title = title,
      selectend = false
    }
    AIManager.addTask(task)
  end
end

function AIManager.speak(task)
  AIManager.isSpeaking = true
  local text = require("hera_korean").translate(task.text)
  local str = ""
  local chars = {}
  for char, length in utf8Iter(text) do
    table.insert(chars, {char = char, length = length})
  end
  local index = 1
  UI_YisiChatText.len = 0
  if not UI_YisiChat:get_is_show() then
    UI_YisiChatButtonGantan:show()
  end
  Ystimer = ac.loop(50, function(timer)
    if not UI_YisiChatButtonGantan:get_is_show() then
      if index <= #chars then
        local len = 2
        if chars[index].length ~= 1 then
          len = 4.4
        end
        UI_YisiChatText.len = UI_YisiChatText.len + len
        if UI_YisiChatText.len > 90 then
          UI_YisiChatText.len = len
          str = str .. "\n"
        end
        str = str .. chars[index].char
        UI_YisiChatText:set_text(str)
        index = index + 1
      else
        AIManager.endTask(task)
        timer:remove()
      end
    end
  end)
end

local tipshow = class.panel:builder({
  x = 0,
  y = 0,
  w = 200,
  h = 100,
  normal_image = "war3mapImported\\Black.blp"
})
local tiptext = class.text:builder({
  parent = tipshow,
  x = 5,
  y = 5,
  w = 1,
  h = 1,
  text = "",
  align = "auto_size",
  font_size = 13
})
tipshow:hide()
tipshow:set_alpha(200)
tipshow:set_level(1)

function YisiFunction.ischatting()
  if AIManager.isSpeaking then
    return true
  else
    return false
  end
end

function YisiFunction.GetRandom100(gl, u)
  local sy
  if u then
    sy = u.ownerid
  else
    sy = 1
  end
  local rd = yisirandom[sy]
  if gl >= rd then
    return true
  else
    return false
  end
end

function YisiFunction.GetRandomInt(value, u)
  local sy
  if u then
    sy = u.ownerid
  else
    sy = 1
  end
  local c = math.floor(0.5 + yisirandom[sy] / 100 * value)
  if c == 0 then
    c = 1
  end
  return c
end

function YisiFunction.OptionAct(value, text, func, type)
  type = type or "对话框"
  if type == "对话框" then
    YisiFunc[value] = func
    YisiChatButtonText[value]:set_text(text)
    YisiChatButton[value].run = true
  elseif type == "图标" then
    YisiFunc[value] = func
    text = YisiNormalizeIcon(text)
    YisiChatIcon[value]:set_normal_image(text)
    YisiChatIcon[value]:set_alpha(255)
    YisiChatIcon[value].run = true
  end
end

function YisiFunction.OptionClear()
  if AIManager.currentTask then
    AIManager.currentTask.selectend = true
  end
  for index, value in ipairs(YisiChatButton) do
    YisiFunc[index] = function()
    end
    YisiChatButton[index]:hide()
    YisiChatButton[index].run = false
  end
  for index, value in ipairs(YisiChatIcon) do
    YisiFunc[index] = function()
    end
    YisiChatIcon[index]:hide()
    YisiChatIcon[index].run = false
  end
end

AIManager.set_option_clear(YisiFunction.OptionClear)

function createUIButton(index, parent, x, y, image, text, onClick)
  local button = class.button:builder({
    parent = parent,
    x = x,
    y = y,
    w = w * 0.75,
    h = h * 0.75,
    normal_image = image,
    on_button_clicked = function(self)
      onClick()
      self:set_control_size(self:get_width() * 0.9, self:get_height() * 0.9)
      ac.wait(100, function()
        self:set_control_size(self:get_width() / 0.9, self:get_height() / 0.9)
      end)
    end
  })
  button:hide()
  local buttonText = class.text:builder({
    parent = button,
    x = 5,
    y = 5,
    w = 1,
    h = 1,
    text = text,
    align = "auto_size",
    font_size = 12
  })
  buttonText:set_size(1, "fontxs.ttf")
  buttonText:set_color("FFBEAFF2")
  YisiChatButton[index] = button
  YisiChatButtonText[index] = buttonText
end

function InitYisiUI()
  local b2 = false
  UI_YisiChat = class.button:builder({
    x = 500,
    y = 650,
    w = w * dx,
    h = h * dx,
    normal_image = "UI_Chat_ICON.tga",
    on_button_right_clicked = function(self)
      staytime = 0
      if not b2 then
        b2 = true
        self:set_enable_drag(false)
      else
        b2 = false
        self:set_enable_drag(true)
      end
    end,
    on_button_update_drag = function(self, icon, x, y)
      self:set_position(x, y)
    end
  })
  UI_YisiChat:hide()
  UI_YisiChat:set_enable_drag(true)
  local texture2 = class.panel:builder({
    parent = UI_YisiChat,
    x = w * dx,
    y = 0,
    w = w * dx * 4,
    h = h * dx,
    normal_image = "UI_Chat_Black.tga"
  })
  texture2:set_alpha(200)
  UI_YisiChatText = class.text:builder({
    parent = texture2,
    x = 15,
    y = 15,
    w = 1,
    h = 1,
    text = "",
    align = "topleft",
    font_size = 12
  })
  UI_YisiChatText:set_size(1, "fontxs.ttf")
  UI_YisiChatText:set_color("FFBEAFF2")
  local b = false
  local ddx = 205
  local ddy = 712
  if EnableCustomUI then
    ddx = 90
    ddy = 790
  end
  UI_YisiChatButton = class.button:builder({
    x = ddx,
    y = ddy,
    w = w * 0.75,
    h = h * 0.75,
    normal_image = "UI_Chat_LittleICON.tga",
    hover_image = "UI_Chat_LittleICON2.tga",
    on_button_clicked = function(self, str)
      self:set_control_size(self:get_width() * 0.9, self:get_height() * 0.9)
      UI_YisiChatButtonGantan:set_control_size(UI_YisiChatButtonGantan:get_width() * 0.9, UI_YisiChatButtonGantan:get_height() * 0.9)
      ac.wait(100, function()
        self:set_control_size(self:get_width() / 0.9, self:get_height() / 0.9)
        UI_YisiChatButtonGantan:set_control_size(UI_YisiChatButtonGantan:get_width() / 0.9, UI_YisiChatButtonGantan:get_height() / 0.9)
      end)
      staytime = 0
      if UI_YisiChat:get_is_show() then
        UI_YisiChat:hide()
      else
        UI_YisiChat:show()
        UI_YisiChatButtonGantan:hide()
        if AIManager.currentTask == nil and not YisiChatIcon[1].run and not YisiChatButton[1].run then
          YisiStory["空闲"]()
        end
      end
    end,
    on_button_right_clicked = function(self)
      if not b then
        b = true
        self:set_enable_drag(false)
      else
        b = false
        self:set_enable_drag(true)
      end
    end,
    on_button_update_drag = function(self, icon, x, y)
      b = false
      self:set_position(x, y)
    end
  })
  UI_YisiChatButton:hide()
  UI_YisiChatButton:set_enable_drag(true)
  UI_YisiChatButtonGantan = class.texture:builder({
    parent = UI_YisiChatButton,
    x = 40,
    y = -10,
    w = 25,
    h = 25,
    normal_image = "UI_Chat_ICONGANTAN.tga"
  })
  UI_YisiChatButtonGantan:hide()
  for i = 1, 4 do
    createUIButton(i, texture2, 630, (i - 1) * 50, "UI_Chat_Black.tga", "选项" .. i, function()
      YisiFunc[i]()
      YisiFunction.OptionClear()
    end)
  end
  local tipicon = {}
  local count = 5
  
  local function iconset(i)
    tipicon[i] = class.button:builder({
      parent = UI_YisiChatText,
      x = -130 + 130 * i,
      y = -100,
      w = w * 1.2,
      h = h * 1.2,
      normal_image = "war3mapImported\\BTNCommand_Skill.blp",
      keys = {},
      on_button_mousedown = function(self, palyer)
        self:set_control_size(self:get_width() - 4, self:get_height() - 4)
        ac.wait(100, function()
          self:set_control_size(self:get_width() + 4, self:get_height() + 4)
        end)
        YisiFunc[i]()
        YisiFunction.OptionClear()
        uiy_hide()
      end,
      on_button_mouse_enter = function(self)
        local x, y = game.get_mouse_pos()
        local sy = LocalPlayerID
        self:set_alpha(150)
        uiy_show_text(YisiChatIconText[sy][i], "LeftShowButton")
      end,
      on_button_mouse_leave = function(self)
        self:set_alpha(255)
        uiy_hide()
      end
    })
    tipicon[i]:hide()
    YisiChatIcon[i] = tipicon[i]
  end
  
  for i = 1, count do
    iconset(i)
  end
end

function Main()
  InitYisiUI()
  ac.loop(1000, function()
    YisiRunTime = YisiRunTime + 1
    if not AIManager.isSpeaking and not YisiChatButton[1]:get_is_show() and not YisiChatIcon[1]:get_is_show() and #AIManager.taskQueue.items == 0 then
      staytime = staytime + 1
    else
      staytime = 0
    end
    if 6 <= staytime then
      UI_YisiChat:hide()
    end
  end)
  for i = 1, 6 do
    yisirandom[i] = GetRandomReal(0, 100)
  end
  ac.loop(100, function()
    for i = 1, 6 do
      yisirandom[i] = GetRandomReal(0, 100)
    end
  end)
  local gamename = {
    "Hearts of Iron IV",
    "Terraria",
    "Starbound",
    "Stellaris",
    "Minecraft",
    "Chrono Ark",
    "NEKOPARA",
    "Library Of Ruina",
    "Lobotomy Corporation",
    "Lethal Company",
    "Baldur’s Gate 3",
    "Dark Souls",
    "Slay the Spire",
    "Risk of Rain",
    "Left 4 Dead 2",
    "千恋 * 万花",
    "Ark:Survival Evolved",
    "天使☆嚣嚣RE-BOOT!",
    "天结Castle Meister",
    "Riddle Joker",
    "Project Zomboid",
    "我也不知道是什么的游戏",
    "Hyperdimension Neptunia",
    "Sekiro:Shadows Die Twice"
  }
  YisiFunction.gamename = ""
  ac.loop(1000, function()
    YisiFunction.gamename = gamename[GetRandomInt(1, #gamename)]
  end)
end

Main()
YisiStory = require("gameplay.feature.yisi.story")
return YisiFunction
