-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local varskill = {}
local japi = require("jass.japi")
local icon_chat = require("gameplay.interface.ui.icon_chat")
local dx = 0.6
local csa = 75
local w, h = 91 * dx, 71 * dx
local startx = 1370
local starty = 780
local buttonsize = 0.7
local dchange = 1
local ddheight = 60
local dstarty = 20
if EnableCustomUI then
  startx = 630
  starty = 856
  buttonsize = 0.6
  dchange = -1
  ddheight = 55
  dstarty = 0
end
local uiskillpanel = class.panel:builder({
  x = startx + 91 * buttonsize + 5,
  y = starty - dstarty,
  w = 1,
  h = 1,
  normal_image = "Touming.tga"
})
local show = true
UIskillbutton = class.button:builder({
  x = startx,
  y = starty,
  w = 91 * buttonsize,
  h = 71 * buttonsize,
  showtext = "技能拓展栏\n点击切换技能拓展栏是否显示",
  normal_image = "war3mapImported\\BTNCommand_Skill.blp",
  on_button_clicked = function(self)
    self:set_control_size(self:get_width() * 0.9, self:get_height() * 0.9)
    ac.wait(100, function()
      self:set_control_size(self:get_width() / 0.9, self:get_height() / 0.9)
    end)
    local sy = LocalPlayerID
    local u = getunit(Hero[sy])
    if show then
      show = false
      u:sendmessage("隐藏拓展技能栏")
      uiskillpanel:hide()
    else
      show = true
      u:sendmessage("显示拓展技能栏")
      uiskillpanel:show()
    end
  end,
  on_button_mouse_enter = function(self)
    self:set_alpha(255)
    if self.showtext then
      uiy_show_text(self.showtext, "Skill")
    end
  end,
  on_button_mouse_leave = function(self)
    self:set_alpha(csa)
    if self.showtext then
      uiy_hide()
    end
  end
})
UIskillbutton:set_alpha(csa)
UIskillbutton:hide()

local function bind_uivar_button_events(u, btn, syncid, skill_name)
  function btn.on_button_alt_click()
    icon_chat.try_send("技能", skill_name)
  end
  
  function btn:on_button_clicked()
    self:add_cd_animation(0, 0, self.w, self.h)
    self:set_control_size(self:get_width() * 0.9, self:get_height() * 0.9)
    self._cd_animation:set_control_size(self:get_width() * 0.9, self:get_height() * 0.9)
    ac.wait(100, function()
      self._cd_animation:set_control_size(self:get_width() / 0.9, self:get_height() / 0.9)
      self:set_control_size(self:get_width() / 0.9, self:get_height() / 0.9)
    end)
    local nowcd = self:get_cd()
    if 0 < nowcd then
      u:sendmessage("|cFF6699FF冷却:" .. math.floor(nowcd) .. "秒|r")
    else
      japi.DzSyncData("UISKILL", syncid)
      self:set_cd(self.cdtime, self.cdtime)
    end
  end
  
  function btn:on_button_mouse_enter()
    self:set_alpha(255)
    if self.showtext then
      uiy_show_text(self.showtext, "Skill")
    end
  end
  
  function btn:on_button_mouse_leave()
    self:set_alpha(csa)
    if self.showtext then
      uiy_hide()
    end
  end
end

local func = {}
local trg = CreateTrigger()
japi.DzTriggerRegisterSyncData(trg, "UISKILL", false)
TriggerAddAction(trg, function()
  local sy = GetConvertedPlayerId(japi.DzGetTriggerSyncPlayer())
  local key = japi.DzGetTriggerSyncData()
  for index, value in ipairs(func) do
    if value.key == key then
      value.data.func(value.data)
      break
    end
  end
end)

function AddUISkill(args)
  local cd = args.cd
  local u
  if args.u then
    u = args.u
  elseif args.unit then
    u = getunit(args.unit)
    args.u = u
  else
    print("添加额外技能不存在的单位")
    return
  end
  local text = "us" .. args.text .. u.ownerid
  local icon = args.icon
  local is_h5 = false
  local lowerFilename = string.lower(icon)
  if not lowerFilename:match("%.tga$") and not lowerFilename:match("%.blp$") then
    icon = icon .. ".tga"
  end
  args.icon = icon
  local dx = 0.7
  local csa = args.csa or 105
  local w, h = 91 * dx, 71 * dx
  if not u.varskill then
    u.varskill = {}
  end
  for index, value in ipairs(u.varskill) do
    if value.name == text then
      print("重复的技能按钮")
      return
    end
  end
  local count = #u.varskill
  local meihangcount = 7
  local xc = count % meihangcount
  local yc = math.floor(count / meihangcount)
  local x = 0 + 70 * xc
  local y = 0 - dchange * ddheight * yc
  local run = true
  local button
  button = class.button:builder({
    parent = uiskillpanel,
    x = x,
    y = y,
    w = w,
    h = h,
    normal_image = icon,
    cdtime = cd,
    showtext = args.showtext
  })
  bind_uivar_button_events(u, button, text, args.text)
  table.insert(u.varskill, {name = text, button = button})
  args.button = button
  button:set_alpha(csa)
  button:hide()
  if u:islocal() and show then
    button:show()
  end
  table.insert(func, {key = text, data = args})
  return button
end
