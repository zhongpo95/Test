-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local display_tag = require("hera_display_tag")
local unit = require("jh.ac.unit")
local japi = require("jass.japi")
local uivar_main, uivar_extraphoto, uivar_text
local dx = 3
local w, h = 88, 68
uivar_main = class.panel:builder({
  x = 1900,
  y = 800,
  w = 1,
  h = 1,
  normal_image = "war3mapImported\\Black.blp"
})
uivar_main:set_level(1)
uivar_text = class.text:builder({
  parent = uivar_main,
  x = 0,
  y = 0,
  w = 1,
  h = 1,
  text = "",
  font_size = 10
})
uivar_extraphoto = class.panel:builder({
  parent = uivar_main,
  x = 1,
  y = 1,
  w = w * dx,
  h = h * dx,
  normal_image = "war3mapImported\\Black.blp"
})
uivar_main:hide()
local clickGCD = false
local clickTextGCD = false

local function uivar_is_valid_control(control)
  return control and control ~= 0 and control._id and control._id ~= 0
end

local function uivar_click_scale(control)
  if not uivar_is_valid_control(control) then
    return
  end
  if control._uivar_click_scaling then
    return
  end
  control._uivar_click_scaling = true
  local oldw = control.uivar_base_w or control.w or control:get_width()
  local oldh = control.uivar_base_h or control.h or control:get_height()
  control:set_control_size(oldw - 4, oldh - 4)
  ac.wait(100, function()
    if uivar_is_valid_control(control) then
      control:set_control_size(oldw, oldh)
      control._uivar_click_scaling = false
    end
  end)
end

local function uivar_set_base_size(control)
  if not uivar_is_valid_control(control) then
    return
  end
  control.uivar_base_w = control:get_width()
  control.uivar_base_h = control:get_height()
end

local function uivar_complete_image_suffix(image)
  if type(image) ~= "string" or image == "" then
    return image
  end
  local lower = string.lower(image)
  if not lower:match("%.tga$") and not lower:match("%.blp$") then
    return image .. ".tga"
  end
  return image
end

local uivarg = {}
for i = 1, 6 do
  uivarg[i] = {}
end
local alltype = {
  "传奇栏",
  "以太栏",
  "冥王栏",
  "血统栏",
  "疾病栏",
  "羁绊栏",
  "属性栏"
}
local newtype = {}
local nowkey = "传奇栏"
local lastkey = "冥王栏"
local countx = {}
local county = {}
local count = {}
for i = 1, 6 do
  count[i] = {}
end
local countdangqianye = {}

local function registertype(value)
  for i = 1, 6 do
    uivarg[i][value] = {}
    count[i][value] = 0
  end
  countx[value] = 0
  county[value] = 1
  countdangqianye[value] = 1
end

local function logintype(value)
  if uivarg[1][value] == nil then
    print("注册新的表类型" .. value)
    table.insert(alltype, value)
    table.insert(newtype, value)
    registertype(value)
  end
end

for index, value in ipairs(alltype) do
  registertype(value)
end
local newup, newnext, newback, BlackPANEL
local startx = 1490
local starty = 847
local dilx = 103
local dily = 76.5
local buttonsize = 0.98
if EnableCustomUI then
  startx = 1534
  starty = 864
  dilx = 95
  dily = 71
  buttonsize = 0.93
end
local w2, h2 = 92, 68
local startx2 = 1528
local starty2 = 861
local dilx2 = 95.5
local dily2 = 70.5
local buttonsize2 = 1.04
local uivar_branch_panel, uivar_branch_title, uivar_branch_empty
local uivar_branch_buttons = {}
local uivar_branch_page_text, uivar_branch_prev, uivar_branch_next
local uivar_branch_list = {}
local uivar_branch_page = 1
local uivar_branch_lock_token = 0
local uivar_branch_is_locked = false
local uivar_branch_source_button
local uivar_branch_is_panel_enter = false
local uivar_branch_last_detail_button
local UIVAR_BRANCH_LOCK_TIME = 1250
local UIVAR_BRANCH_MAX_COUNT = 7
local UIVAR_BRANCH_W = 430
local UIVAR_BRANCH_H = 500
local UIVAR_BRANCH_X = startx - UIVAR_BRANCH_W - 20
local UIVAR_BRANCH_Y = starty - UIVAR_BRANCH_H + h * buttonsize - 40
local UIVAR_BRANCH_ICON_W = 66
local UIVAR_BRANCH_ICON_H = 51
local UIVAR_BRANCH_ROW_H = 54
local UIVAR_BRANCH_PAGE_Y = UIVAR_BRANCH_H - 24
local UIVAR_BRANCH_SYNC_SEP = string.char(31)
local UIVAR_YITAI_BRANCH_SYNC = "YitaiBranch"
local yitai_branch_data = {}
local synczu = {}
local synccount = 0
local syncrightzu = {}
local syncrightcount = 0
local func1, func1_click, func1_rightclick

local function uivar_var_plain_name(button)
  if button and button.vardata and button.vardata.name then
    return button.vardata.name
  end
  return button and button.keyname or ""
end

local function uivar_var_show_name(button)
  if button and button.vardata and button.vardata.effectname then
    return button.vardata.effectname
  end
  return uivar_var_plain_name(button)
end

local function uivar_get_yitai_resonance_key(var)
  local keys = var and var.key
  if type(keys) ~= "table" then
    return nil
  end
  for _, key in ipairs(keys) do
    if key == "心脏" or key == "体质" then
      return nil
    end
  end
  for _, key in ipairs(keys) do
    if key ~= "启动" and key ~= "德丽莎" and not is_not_vartype(key) then
      return key
    end
  end
  return nil
end

local function uivar_is_yitai_resonance_key(key)
  return type(key) == "string" and key ~= "" and key ~= "心脏" and key ~= "体质" and key ~= "启动" and key ~= "德丽莎" and not is_not_vartype(key)
end

local function uivar_yitai_branch_keyname(key)
  return "以太分支-" .. key
end

local function uivar_yitai_branch_title(key)
  return "|cFF7DBEF1" .. display_tag(key) .. " 계열 에테르 변이|r"
end

local function uivar_yitai_branch_text(key)
  return "|cFF949596마우스를 올려 획득한 " .. display_tag(key) .. " 계열 에테르 분기 변이 확인|r"
end

local function uivar_get_yitai_branch_store(sy)
  yitai_branch_data[sy] = yitai_branch_data[sy] or {}
  return yitai_branch_data[sy]
end

local function uivar_branch_title_text(source)
  local title = source.branch_title or "|cFF7DBEF1同词条分支：|r" .. uivar_var_show_name(source)
  local key = source and source.vardata and uivar_get_yitai_resonance_key(source.vardata)
  local hero = Hero and Hero[LocalPlayerID]
  local u = hero and getunit(hero)
  if key and u and u:getdata("以太共鸣对象") == key then
    title = title .. "|cFFFFCC66 [共鸣激活]|r"
  end
  return title
end

local function uivar_refresh_branch_title()
  if uivar_branch_title and uivar_branch_source_button then
    uivar_branch_title:set_text(uivar_branch_title_text(uivar_branch_source_button))
  end
end

local function uivar_set_yitai_resonance_key(u, key, name)
  if not uivar_is_yitai_resonance_key(key) then
    return false
  end
  u:setdata("以太共鸣对象", key)
  u:setdata("以太共鸣对象名称", name or uivar_yitai_branch_title(key))
  u:sendmessage("|cFF66CCFF以太共鸣对象已标记：" .. key .. "|r")
  if u:islocal() then
    uivar_refresh_branch_title()
  end
  return true
end

local function uivar_set_yitai_resonance(u, var)
  local key = uivar_get_yitai_resonance_key(var)
  return uivar_set_yitai_resonance_key(u, key, var and (var.effectname or var.name))
end

local function uivar_sync_yitai_resonance(key)
  if not uivar_is_yitai_resonance_key(key) then
    return
  end
  if japi.DzSyncData then
    japi.DzSyncData(UIVAR_YITAI_BRANCH_SYNC, key)
  else
    local hero = Hero and Hero[LocalPlayerID]
    local u = hero and getunit(hero)
    if u then
      uivar_set_yitai_resonance_key(u, key)
    end
  end
end

do
  local trg = CreateTrigger()
  if japi.DzTriggerRegisterSyncData then
    japi.DzTriggerRegisterSyncData(trg, UIVAR_YITAI_BRANCH_SYNC, false)
    TriggerAddAction(trg, function()
      local key = japi.DzGetTriggerSyncData()
      local p = getplayer(japi.DzGetTriggerSyncPlayer())
      local hero = p and Hero[p.id]
      if hero then
        local u = getunit(hero)
        if u then
          uivar_set_yitai_resonance_key(u, key)
        end
      end
    end)
  end
end

local function uivar_build_branch_entry(var)
  return {
    vardata = var,
    keyname = var.name,
    savetext = (var.effectname or var.name or "") .. "\n" .. (var.effecttext or ""),
    saveicon = uivar_complete_image_suffix(var.effectart or "war3mapImported\\Black.blp"),
    savehe = 60,
    dx = 3,
    ishasphoto = false,
    is_branch_entry = true,
    clickfunc = var.clickfunc,
    rightclickfunc = var.rightclickfunc,
    local_rightclickfunc = var.local_rightclickfunc,
    savecd = var.cd or 1,
    saverightcd = var.rightcd or 1
  }
end

local function uivar_branch_sync_name(name)
  name = tostring(name or "")
  return name:gsub(UIVAR_BRANCH_SYNC_SEP, "")
end

local function uivar_make_branch_sync_data(source_keyname, branch_keyname)
  return uivar_branch_sync_name(source_keyname) .. UIVAR_BRANCH_SYNC_SEP .. uivar_branch_sync_name(branch_keyname)
end

local function uivar_parse_branch_sync_data(data)
  if type(data) ~= "string" then
    return nil, nil
  end
  local pos = data:find(UIVAR_BRANCH_SYNC_SEP, 1, true)
  if not pos then
    return nil, nil
  end
  return data:sub(1, pos - 1), data:sub(pos + 1)
end

local function uivar_find_button_by_keyname(sy, keyname)
  if not keyname or keyname == "" then
    return nil
  end
  for _, uivarname in ipairs(alltype) do
    local list = uivarg[sy] and uivarg[sy][uivarname]
    if list then
      for _, button in ipairs(list) do
        if button and button.keyname == keyname then
          return button
        end
      end
    end
  end
  return nil
end

local function uivar_find_branch_var(source, branch_keyname)
  if not (source and source.branch_vars and branch_keyname) or branch_keyname == "" then
    return nil
  end
  for _, var in ipairs(source.branch_vars) do
    if var and var.name == branch_keyname then
      return var
    end
  end
  return nil
end

local function uivar_run_synced_branch_action(row, p, is_right)
  local player = getplayer(p.handle)
  local u = getunit(Hero[player.id])
  local source_keyname, branch_keyname = uivar_parse_branch_sync_data(row.sync_data)
  local source = uivar_find_button_by_keyname(player.id, source_keyname)
  local var = uivar_find_branch_var(source, branch_keyname)
  if not var then
    return
  end
  uiy_hide()
  if is_right then
    if var.rightclickfunc then
      var.rightclickfunc(u, var, row)
    elseif var.clickfunc then
      var.clickfunc(u, var, row)
    end
  elseif var.clickfunc then
    var.clickfunc(u, var, row)
  end
end

local function uivar_branch_bind_actions(entry)
  if not entry or entry.branch_syncid or not entry.clickfunc and not entry.rightclickfunc then
    return
  end
  synccount = synccount + 1
  entry.branch_syncid = synccount
  if entry.clickfunc then
    synczu[synccount] = entry.clickfunc
  end
  if entry.rightclickfunc then
    syncrightzu[synccount] = entry.rightclickfunc
  end
end

local function uivar_render_branch_page()
  local max_page = math.max(1, math.floor((#uivar_branch_list - 1) / UIVAR_BRANCH_MAX_COUNT) + 1)
  if max_page < uivar_branch_page then
    uivar_branch_page = max_page
  end
  if uivar_branch_page < 1 then
    uivar_branch_page = 1
  end
  local start_index = (uivar_branch_page - 1) * UIVAR_BRANCH_MAX_COUNT
  for i = 1, UIVAR_BRANCH_MAX_COUNT do
    local row = uivar_branch_buttons[i]
    local bind = uivar_branch_list[start_index + i]
    if bind then
      row.source_button = bind
      row.branch_source_keyname = uivar_branch_source_button and uivar_branch_source_button.keyname
      row.branch_target_keyname = bind.keyname
      row.icon:set_normal_image(bind.saveicon or bind.normal_image or "war3mapImported\\Black.blp")
      row.icon:set_alpha(255)
      row.label:set_text(uivar_var_show_name(bind))
      row.vardata = bind.vardata
      row.savecd = bind.savecd or 1
      row.saverightcd = bind.saverightcd or 1
      row.uivar_cd_x = 3
      row.uivar_cd_y = 0
      row.uivar_cd_w = UIVAR_BRANCH_ICON_W
      row.uivar_cd_h = UIVAR_BRANCH_ICON_H
      row.branch_local_rightclickfunc = bind.local_rightclickfunc
      row.branch_has_sync_action = bind.clickfunc ~= nil or bind.rightclickfunc ~= nil
      row:show()
    else
      row.source_button = nil
      row.branch_source_keyname = nil
      row.branch_target_keyname = nil
      row.vardata = nil
      row.branch_local_rightclickfunc = nil
      row.branch_has_sync_action = nil
      row.uivar_cd_x = nil
      row.uivar_cd_y = nil
      row.uivar_cd_w = nil
      row.uivar_cd_h = nil
      row:hide()
    end
  end
  if uivar_branch_page_text then
    uivar_branch_page_text:set_text("|cFF949596" .. uivar_branch_page .. "/" .. max_page .. "|r")
  end
  if uivar_branch_prev then
    if 1 < max_page then
      uivar_branch_prev:show()
      uivar_branch_next:show()
    else
      uivar_branch_prev:hide()
      uivar_branch_next:hide()
    end
  end
end

local function uivar_has_same_key(source, target)
  local source_key = source and source.vardata and source.vardata.key
  local target_key = target and target.vardata and target.vardata.key
  if type(source_key) ~= "table" or type(target_key) ~= "table" then
    return false
  end
  for _, svalue in ipairs(source_key) do
    for _, tvalue in ipairs(target_key) do
      if svalue == tvalue then
        return true
      end
    end
  end
  return false
end

local function uivar_collect_branch_buttons(source)
  local result = {}
  if source and source.branch_vars then
    for _, var in ipairs(source.branch_vars) do
      table.insert(result, uivar_build_branch_entry(var))
    end
    return result
  end
  local sy = LocalPlayerID
  for _, uivarname in ipairs(alltype) do
    local list = uivarg[sy][uivarname]
    if list then
      for _, button in ipairs(list) do
        if button and button.vardata and uivar_has_same_key(source, button) then
          table.insert(result, button)
        end
      end
    end
  end
  if #result == 0 and source then
    table.insert(result, source)
  end
  table.sort(result, function(a, b)
    if a == source then
      return true
    end
    if b == source then
      return false
    end
    return uivar_var_plain_name(a) < uivar_var_plain_name(b)
  end)
  return result
end

local function uivar_show_branch_button_detail(button)
  if not button then
    return
  end
  UIYNameKey = button
  if button.ishasphoto then
    if button.dx_h then
      uiy_show_text_and_image(button.savetext, button.saveicon, "Var", {
        w = w * button.dx,
        h = h * button.dx * button.dx_h,
        x = -w * button.dx - 6,
        y = 0.5 * button.savehe - 0.5 * h * button.dx * button.dx_h
      })
    else
      uiy_show_text_and_image(button.savetext, button.saveicon, "Var", {
        w = w * button.dx,
        h = h * button.dx,
        x = -w * button.dx - 6,
        y = 0.5 * button.savehe - 0.5 * h * button.dx
      })
    end
  else
    uiy_show_text(button.savetext, "Var")
  end
end

local function uivar_show_default_button_detail(button)
  uivar_show_branch_button_detail(button)
end

local function uivar_hide_branch_panel()
  uivar_branch_lock_token = uivar_branch_lock_token + 1
  uivar_branch_is_locked = false
  uivar_branch_source_button = nil
  uivar_branch_is_panel_enter = false
  uivar_branch_last_detail_button = nil
  if uivar_branch_panel then
    uivar_branch_panel:hide()
  end
  uiy_hide()
end

local function uivar_ensure_branch_panel()
  if uivar_branch_panel then
    return
  end
  uivar_branch_panel = class.panel:builder({
    parent = OriginPanel,
    x = UIVAR_BRANCH_X,
    y = UIVAR_BRANCH_Y,
    w = UIVAR_BRANCH_W,
    h = UIVAR_BRANCH_H,
    normal_image = "war3mapImported\\Black.blp"
  })
  uivar_branch_panel:set_alpha(225)
  uivar_branch_panel:set_level(15)
  local border_cd = 10
  local border_hsize = 0.71
  local border_ssize = 0.88
  local border_corner_w = border_cd * 1.5 * 0.88
  local border_corner_h = border_cd * 1.5 * 0.68
  local branch_border = {
    class.panel:builder({
      parent = uivar_branch_panel,
      x = -border_cd * 0.6,
      y = -border_cd * 0.5,
      w = border_corner_w,
      h = border_corner_h,
      normal_image = "UI_Biankuang_Zuoshang.blp"
    }),
    class.panel:builder({
      parent = uivar_branch_panel,
      x = -border_cd * 0.6,
      y = -border_cd * 0.55 + UIVAR_BRANCH_H,
      w = border_corner_w,
      h = border_corner_h,
      normal_image = "UI_Biankuang_Zuoxia.blp"
    }),
    class.panel:builder({
      parent = uivar_branch_panel,
      x = -border_cd * 0.7 + UIVAR_BRANCH_W,
      y = -border_cd * 0.5,
      w = border_corner_w,
      h = border_corner_h,
      normal_image = "UI_Biankuang_Youshang.blp"
    }),
    class.panel:builder({
      parent = uivar_branch_panel,
      x = -border_cd * 0.7 + UIVAR_BRANCH_W,
      y = -border_cd * 0.55 + UIVAR_BRANCH_H,
      w = border_corner_w,
      h = border_corner_h,
      normal_image = "UI_Biankuang_Youxia.blp"
    }),
    class.panel:builder({
      parent = uivar_branch_panel,
      x = 0,
      y = -border_cd * 0.8 * border_hsize,
      w = UIVAR_BRANCH_W,
      h = border_cd * border_hsize,
      normal_image = "UI_Biankuang_Shang.tga"
    }),
    class.panel:builder({
      parent = uivar_branch_panel,
      x = 0,
      y = UIVAR_BRANCH_H - 0.2 * border_cd * border_hsize,
      w = UIVAR_BRANCH_W,
      h = border_cd * border_hsize,
      normal_image = "UI_Biankuang_Xia.tga"
    }),
    class.panel:builder({
      parent = uivar_branch_panel,
      x = -border_cd * 0.8 * border_ssize,
      y = 0,
      w = border_cd * border_ssize,
      h = UIVAR_BRANCH_H,
      normal_image = "UI_Biankuang_Zuo.tga"
    }),
    class.panel:builder({
      parent = uivar_branch_panel,
      x = UIVAR_BRANCH_W - 0.2 * border_cd * border_ssize,
      y = 0,
      w = border_cd * border_ssize,
      h = UIVAR_BRANCH_H,
      normal_image = "UI_Biankuang_You.tga"
    })
  }
  for _, border in ipairs(branch_border) do
    border:set_level(16)
  end
  uivar_branch_title = class.text:builder({
    parent = uivar_branch_panel,
    x = 16,
    y = 12,
    w = UIVAR_BRANCH_W - 32,
    h = 30,
    text = "",
    font_size = 12,
    align = "left"
  })
  uivar_branch_title:set_level(17)
  uivar_branch_empty = class.text:builder({
    parent = uivar_branch_panel,
    x = 16,
    y = 48,
    w = UIVAR_BRANCH_W - 32,
    h = 42,
    text = "",
    font_size = 10,
    align = "left"
  })
  uivar_branch_empty:set_level(17)
  for i = 1, UIVAR_BRANCH_MAX_COUNT do
    local y = 96 + (i - 1) * UIVAR_BRANCH_ROW_H
    local row = class.button:builder({
      parent = uivar_branch_panel,
      x = 12,
      y = y,
      w = UIVAR_BRANCH_W - 24,
      h = UIVAR_BRANCH_ROW_H - 4,
      normal_image = "war3mapImported\\Black.blp"
    })
    row:set_alpha(170)
    row:set_level(17)
    local icon = class.panel:builder({
      parent = row,
      x = 3,
      y = 0,
      w = UIVAR_BRANCH_ICON_W,
      h = UIVAR_BRANCH_ICON_H,
      normal_image = "war3mapImported\\Black.blp"
    })
    icon:set_level(18)
    local text = class.text:builder({
      parent = row,
      x = 79,
      y = 14,
      w = UIVAR_BRANCH_W - 114,
      h = 24,
      text = "",
      font_size = 10,
      align = "left"
    })
    text:set_level(18)
    row.icon = icon
    row.label = text
    row.sync_key = "uivarbranchrow" .. i
    
    function row:on_sync_button_clicked(p)
      uivar_run_synced_branch_action(self, p, false)
    end
    
    function row:on_sync_button_right_clicked(p)
      uivar_run_synced_branch_action(self, p, true)
    end
    
    function row:on_button_mouse_enter()
      self:set_alpha(155)
      uivar_branch_is_panel_enter = true
      uivar_branch_last_detail_button = self.source_button
      uivar_show_branch_button_detail(self.source_button)
    end
    
    function row:on_button_mouse_leave()
      self:set_alpha(255)
      uivar_branch_last_detail_button = nil
      uiy_hide()
    end
    
    function row:on_button_clicked(player)
      if self.sync_key and self.branch_has_sync_action then
        self.sync_data = uivar_make_branch_sync_data(self.branch_source_keyname, self.branch_target_keyname)
        func1_click(self, player)
      else
        func1(self, player)
      end
    end
    
    function row:on_button_right_clicked(player)
      if self.branch_local_rightclickfunc then
        local u = getunit(Hero[LocalPlayerID])
        uiy_hide()
        self.branch_local_rightclickfunc(u, self.vardata, self)
      elseif self.sync_key and self.branch_has_sync_action and self.on_sync_button_right_clicked then
        self.sync_data = uivar_make_branch_sync_data(self.branch_source_keyname, self.branch_target_keyname)
        func1_rightclick(self, player)
      elseif self.sync_key and self.branch_has_sync_action then
        self.sync_data = uivar_make_branch_sync_data(self.branch_source_keyname, self.branch_target_keyname)
        func1_click(self, player)
      else
        func1(self, player)
      end
    end
    
    row:hide()
    uivar_branch_buttons[i] = row
  end
  uivar_branch_prev = class.button:builder({
    parent = uivar_branch_panel,
    x = UIVAR_BRANCH_W - 118,
    y = UIVAR_BRANCH_PAGE_Y,
    w = 30,
    h = 24,
    normal_image = "war3mapImported\\Black.blp"
  })
  uivar_branch_prev:set_alpha(170)
  uivar_branch_prev:set_level(17)
  uivar_branch_prev.label = class.text:builder({
    parent = uivar_branch_prev,
    x = 0,
    y = 3,
    w = 30,
    h = 18,
    text = "<",
    font_size = 10,
    align = "center"
  })
  uivar_branch_prev.label:set_level(18)
  
  function uivar_branch_prev.on_button_clicked()
    uivar_branch_page = uivar_branch_page - 1
    uivar_render_branch_page()
  end
  
  function uivar_branch_prev:on_button_mouse_enter()
    self:set_alpha(230)
    uivar_branch_is_panel_enter = true
  end
  
  function uivar_branch_prev:on_button_mouse_leave()
    self:set_alpha(170)
  end
  
  uivar_branch_page_text = class.text:builder({
    parent = uivar_branch_panel,
    x = UIVAR_BRANCH_W - 84,
    y = UIVAR_BRANCH_PAGE_Y + 3,
    w = 38,
    h = 18,
    text = "",
    font_size = 9,
    align = "center"
  })
  uivar_branch_page_text:set_level(17)
  uivar_branch_next = class.button:builder({
    parent = uivar_branch_panel,
    x = UIVAR_BRANCH_W - 42,
    y = UIVAR_BRANCH_PAGE_Y,
    w = 30,
    h = 24,
    normal_image = "war3mapImported\\Black.blp"
  })
  uivar_branch_next:set_alpha(170)
  uivar_branch_next:set_level(17)
  uivar_branch_next.label = class.text:builder({
    parent = uivar_branch_next,
    x = 0,
    y = 3,
    w = 30,
    h = 18,
    text = ">",
    font_size = 10,
    align = "center"
  })
  uivar_branch_next.label:set_level(18)
  
  function uivar_branch_next.on_button_clicked()
    uivar_branch_page = uivar_branch_page + 1
    uivar_render_branch_page()
  end
  
  function uivar_branch_next:on_button_mouse_enter()
    self:set_alpha(230)
    uivar_branch_is_panel_enter = true
  end
  
  function uivar_branch_next:on_button_mouse_leave()
    self:set_alpha(170)
  end
  
  uivar_branch_panel:hide()
end

uivar_ensure_branch_panel()

local function uivar_show_branch_panel(source)
  uivar_ensure_branch_panel()
  uivar_branch_list = uivar_collect_branch_buttons(source)
  uivar_branch_page = 1
  uivar_branch_lock_token = uivar_branch_lock_token + 1
  local token = uivar_branch_lock_token
  uivar_branch_is_locked = false
  uivar_branch_source_button = source
  uivar_branch_last_detail_button = nil
  uivar_branch_title:set_text(uivar_branch_title_text(source))
  uivar_branch_empty:set_text("|cFF949596悬停条目查看详情，停留1.25秒锁定|r\n|cFF66CCFF点击分支图标可激活以太共鸣|r\n|cFF66CCFF提升对应词条权重|r")
  uivar_render_branch_page()
  uivar_branch_panel:show()
  ac.wait(UIVAR_BRANCH_LOCK_TIME, function()
    if token == uivar_branch_lock_token and uivar_branch_panel and uivar_branch_panel:get_is_show() and source and source.is_enter then
      uivar_branch_is_locked = true
      uivar_branch_empty:set_text("|cFFFFCC66已锁定：点击框外关闭|r\n|cFF66CCFF点击分支图标可激活以太共鸣|r\n|cFF66CCFF提升对应词条权重|r")
    end
  end)
end

local function uivar_maybe_hide_unlocked_branch(source)
  if uivar_branch_is_locked then
    return
  end
  if uivar_branch_panel and uivar_branch_panel:get_is_show() and uivar_branch_source_button == source then
    uivar_hide_branch_panel()
  end
end

game.register_event({
  on_mouse_move = function()
    if uivar_branch_panel and uivar_branch_panel:get_is_show() then
      local x, y = game.get_mouse_pos()
      uivar_branch_is_panel_enter = uivar_branch_panel:point_in_rect(x, y)
    end
  end,
  on_mouse_down = function()
    if uivar_branch_panel and uivar_branch_panel:get_is_show() and uivar_branch_is_locked then
      local x, y = game.get_mouse_pos()
      if not uivar_branch_panel:point_in_rect(x, y) then
        uivar_hide_branch_panel()
      end
    end
  end
})

local function FlashUIhide()
  uivar_hide_branch_panel()
  local sy = LocalPlayerID
  for index, value in ipairs(alltype) do
    if 0 < count[sy][value] then
      for i = 1, count[sy][value] do
        uivarg[sy][value][i]:hide()
      end
    end
  end
  if newback then
    newback:hide()
  end
  if newup then
    newup:hide()
  end
  if BlackPANEL then
    BlackPANEL:hide()
  end
  if newnext then
    newnext:hide()
  end
  if UI_MwxAlice:get_is_show() then
    Local_IsRunAliveVar = false
    UI_MwxAlice:hide()
  end
end

BlackPANEL = class.panel:builder({
  parent = OriginPanel,
  x = startx2,
  y = starty2,
  w = w2 * buttonsize2 * 4,
  h = h2 * buttonsize2 * 3,
  normal_image = "war3mapImported\\Black.blp"
})
BlackPANEL:set_alpha(220)
BlackPANEL:hide()

local function FlashUIvar(key, noback)
  FlashUIhide()
  noback = noback or false
  if key then
    if noback == true then
      lastkey = "hero"
    else
      lastkey = nowkey
    end
    nowkey = key
    newback:set_alpha(255)
    newback:show()
  end
  local sy = LocalPlayerID
  local datu = false
  local change = false
  local datustr = ""
  local tg = {}
  if countdangqianye[nowkey] ~= nil then
    local c = (countdangqianye[nowkey] - 1) * 10
    for i = c + 1, c + 10 do
      local a = uivarg[sy][nowkey][i]
      if a then
        table.insert(tg, a)
        if not datu and a.Datu then
          datu = true
          datustr = a.Datu
        end
      end
    end
    for i, a in ipairs(tg) do
      if datu and 10 <= #tg then
        change = true
        local img = datustr .. " (" .. i .. ").blp"
        if not a.originnormalimag or a.datuloccount ~= i then
          a.originnormalimag = a.normal_image
          a.originicon = a.icon
          a.datuloccount = i
        end
        if a.normal_image ~= img then
          a:set_normal_image(img)
          a.icon = img
          a:set_position(startx2 + dilx2 * (a.iconx - 1), starty2 + dily2 * (a.icony - 1))
          a:set_width(w2 * buttonsize2)
          a:set_height(h2 * buttonsize2)
          a:set_control_size(a:get_width(), a:get_height())
          uivar_set_base_size(a)
        end
      elseif a.originnormalimag then
        a.normal_image = a.originnormalimag
        a.icon = a.originicon
        a.originnormalimag = nil
        a.originicon = nil
        a.datuloccount = nil
        a:set_normal_image(a.normal_image)
        a:set_position(startx + dilx * (a.iconx - 1), starty + dily * (a.icony - 1))
        a:set_width(w * buttonsize)
        a:set_height(h * buttonsize)
        a:set_control_size(a:get_width(), a:get_height())
        uivar_set_base_size(a)
      end
      a:set_alpha(255)
      a:show()
    end
    if change then
      BlackPANEL:show()
      local a = newup
      if not a.originnormalimag then
        a.originnormalimag = a.normal_image
        local img = datustr .. " (" .. 11 .. ").blp"
        a:set_normal_image(img)
        a:set_position(startx2 + dilx2 * 2, starty2 + dily2 * 2)
        a:set_width(w2 * buttonsize2)
        a:set_height(h2 * buttonsize2)
        a:set_control_size(a:get_width(), a:get_height())
        uivar_set_base_size(a)
      end
      local a = newnext
      if not a.originnormalimag then
        a.originnormalimag = a.normal_image
        local img = datustr .. " (" .. 12 .. ").blp"
        a:set_normal_image(img)
        a:set_position(startx2 + dilx2 * 3, starty2 + dily2 * 2)
        a:set_width(w2 * buttonsize2)
        a:set_height(h2 * buttonsize2)
        a:set_control_size(a:get_width(), a:get_height())
        uivar_set_base_size(a)
      end
    else
      BlackPANEL:hide()
      local a = newup
      if a.originnormalimag then
        a.originnormalimag = nil
        a:set_normal_image("war3mapImported\\BTNCommand_Change.blp")
        a:set_position(startx + dilx * 2, starty + dily * 2)
        a:set_width(w * buttonsize)
        a:set_height(h * buttonsize)
        a:set_control_size(a:get_width(), a:get_height())
        uivar_set_base_size(a)
      end
      local a = newnext
      if a.originnormalimag then
        a.originnormalimag = nil
        a:set_normal_image("war3mapImported\\BTNCommand_Change.blp")
        a:set_position(startx + dilx * 3, starty + dily * 2)
        a:set_width(w * buttonsize)
        a:set_height(h * buttonsize)
        a:set_control_size(a:get_width(), a:get_height())
        uivar_set_base_size(a)
      end
    end
  end
  newup:show()
  newnext:show()
end

function FlashUIVarGlobal(u, key, noback)
  if u:islocal() then
    FlashUIvar(key, noback)
  end
end

ac.loop(3000, function()
  if newup:get_is_show() and japi.GetRealSelectUnit() ~= 0 then
    local u = getunit(japi.GetRealSelectUnit())
    if not u:hasdata("系统-变异栏") then
      FlashUIhide()
      uivar_main:hide()
    end
  end
end)
local YITAI_UI_TAGS = {
  "恶魔",
  "不死",
  "吸血鬼",
  "兽",
  "雷",
  "黑暗",
  "冰",
  "光明",
  "炎",
  "水",
  "公共"
}

local function uivar_get_vartype_color(key)
  if key == "公共" or key == "通用" then
    return "|cFF7DBEF1"
  end
  if type(vartype) == "table" then
    for _, data in ipairs(vartype) do
      if data.name == key then
        return data.color or "|cff5eff5e"
      end
    end
  end
  return "|cff5eff5e"
end

local function uivar_join_yitai_parts(parts, empty_text)
  if #parts <= 0 then
    return empty_text or "|cff949596없음|r"
  end
  return table.concat(parts, " ")
end

local function uivar_yitai_lv1_part(u, tag)
  local count
  if tag == "公共" and GetYitaiSourceCount then
    count = GetYitaiSourceCount(u, 1, "公共")
  else
    count = u:getdata("以太变异数量-1阶" .. tag)
  end
  if count <= 0 then
    return nil
  end
  local color = uivar_get_vartype_color(tag)
  return color .. display_tag(tag) .. "*" .. count .. "|r"
end

local function uivar_yitai_slot_part(u, lv, tag)
  if not GetYitaiSlotCount or not GetYitaiSlotUsed then
    return nil
  end
  local count = GetYitaiSlotCount(u, lv, tag)
  local used = GetYitaiSlotUsed(u, lv, tag)
  if count <= 0 and used <= 0 then
    return nil
  end
  local color = uivar_get_vartype_color(tag)
  return color .. display_tag(tag) .. used .. "/" .. count .. "|r"
end

local function uivar_yitai_heart_text(u)
  local parts = {}
  local limit = u:getdata("心脏承载上限")
  for _, tag in ipairs(YITAI_UI_TAGS) do
    if tag ~= "公共" then
      local count = u:getdata("以太心脏数量-" .. tag)
      if 0 < count then
        local color = uivar_get_vartype_color(tag)
        table.insert(parts, color .. display_tag(tag) .. count .. "/" .. limit .. "|r")
      end
    end
  end
  if 0 < #parts then
    return table.concat(parts, " ")
  end
  return "|cff5eff5e" .. u:getdata("心脏变异数量") .. "/" .. limit .. "|r"
end

local function uivar_yitai_body_weight(u, tag)
  return u:getdata("以太变异数量-1阶" .. tag) + u:getdata("以太变异数量-2阶" .. tag) * 2 + u:getdata("以太变异数量-3阶" .. tag) * 5 + u:getdata("以太心脏数量-" .. tag) * 25
end

local function uivar_yitai_body_composition_text(u)
  local weights = {}
  local total = 0
  for _, tag in ipairs(YITAI_UI_TAGS) do
    if tag ~= "公共" then
      local weight = uivar_yitai_body_weight(u, tag)
      if 0 < weight then
        table.insert(weights, {tag = tag, weight = weight})
        total = total + weight
      end
    end
  end
  local parts = {}
  if 0 < total then
    for _, data in ipairs(weights) do
      local color = uivar_get_vartype_color(data.tag)
      table.insert(parts, color .. display_tag(data.tag) .. string.format("%.1f%%", data.weight / total * 100) .. "|r")
    end
  else
    table.insert(parts, "|cff949596없음|r")
  end
  return "\n|cff5eff5e신체 구성:|r" .. table.concat(parts, " ")
end

local function uivar_yitai_load_text(u)
  local lv1_parts = {}
  local lv2_parts = {}
  local lv3_parts = {}
  for _, tag in ipairs(YITAI_UI_TAGS) do
    local part = uivar_yitai_lv1_part(u, tag)
    if part then
      table.insert(lv1_parts, part)
    end
    if tag ~= "公共" then
      part = uivar_yitai_slot_part(u, 2, tag)
      if part then
        table.insert(lv2_parts, part)
      end
      part = uivar_yitai_slot_part(u, 3, tag)
      if part then
        table.insert(lv3_parts, part)
      end
    end
  end
  local common_lv2 = uivar_yitai_slot_part(u, 2, "通用")
  if common_lv2 then
    table.insert(lv2_parts, common_lv2)
  end
  local common_lv3 = uivar_yitai_slot_part(u, 3, "通用")
  if common_lv3 then
    table.insert(lv3_parts, common_lv3)
  end
  return "|cff5eff5e1단계:|r" .. uivar_join_yitai_parts(lv1_parts, "|cff949596없음/∞|r") .. "\n|cff5eff5e2단계:|r" .. uivar_join_yitai_parts(lv2_parts) .. "\n|cff5eff5e3단계:|r" .. uivar_join_yitai_parts(lv3_parts) .. "\n|cff5eff5e심장:|r" .. uivar_yitai_heart_text(u) .. uivar_yitai_body_composition_text(u)
end

function unit:registeruivar()
  local u = self
  u:addtrgevent("玩家-选择单位", function(args)
    local tg = getunit(args.unit)
    if u:islocal() then
      local p = getplayer(args.player)
      if p.handle == u.owner then
        local sy = u.ownerid
        if tg.handle == Ewl_Shuxinglan[sy] then
          u:sendmessage("|cFF7DBEF1---------------")
          u:sendmessage(uivar_yitai_load_text(u))
          local text1 = "|cff659bff기동 수용량:" .. u:getdata("系统-启动负载力") .. "/" .. u:getdata("系统-启动承载上限")
          u:sendmessage(text1)
          local spirit_load = u:getdata("系统-精神负载力")
          local spirit_load_limit = u:getdata("系统-精神负载力上限")
          local actual_spirit_load = math.max(0, spirit_load - spirit_load_limit)
          local text2 = "|cff659bff정신 부하:" .. actual_spirit_load
          u:sendmessage(text2)
          local divinity_load = u:getdata("系统-神力承载")
          local divinity_load_limit = u:getdata("系统-神力承载上限")
          local actual_divinity_load = math.max(0, divinity_load - divinity_load_limit)
          local text1 = "|cffffe054신력 부하:" .. actual_divinity_load .. " (실제 부하" .. divinity_load .. "-한도에 따른 부하 감소" .. divinity_load_limit .. ")"
          u:sendmessage(text1)
          u:sendmessage("|cFF7DBEF1---------------")
        end
        if tg.handle == Ewl_Third[sy] then
          nowkey = "传奇栏"
          FlashUIvar()
          local divinity_load = u:getdata("系统-神力承载")
          local divinity_load_limit = u:getdata("系统-神力承载上限")
          local actual_divinity_load = math.max(0, divinity_load - divinity_load_limit)
          local text1 = "|cffffe054신력 부하:" .. actual_divinity_load .. " (실제 부하" .. divinity_load .. "-한도에 따른 부하 감소" .. divinity_load_limit .. ")"
          u:sendmessage(text1)
        end
        if tg.handle == Ewl_Mind[sy] then
          nowkey = "冥王栏"
          FlashUIvar()
          local text1 = "|cff659bff기동 수용량:" .. u:getdata("系统-启动负载力") .. "/" .. u:getdata("系统-启动承载上限")
          u:sendmessage(text1)
          local spirit_load = u:getdata("系统-精神负载力")
          local spirit_load_limit = u:getdata("系统-精神负载力上限")
          local actual_spirit_load = math.max(0, spirit_load - spirit_load_limit)
          local text2 = "|cff659bff정신 부하:" .. actual_spirit_load
          u:sendmessage(text2)
        end
        if tg.handle == Ewl_Body[sy] then
          nowkey = "以太栏"
          FlashUIvar()
          u:sendmessage(uivar_yitai_load_text(u))
        end
        if tg.handle == Ewl_Blood[sy] then
          nowkey = "血统栏"
          FlashUIvar()
        end
        if tg.handle == Ewl_Disease[sy] then
          nowkey = "疾病栏"
          FlashUIvar()
        end
        if tg.handle == Ewl_Coop[sy] then
          nowkey = "羁绊栏"
          FlashUIvar()
        end
        if tg.handle == Ewl_State[sy] then
          nowkey = "属性栏"
          FlashUIvar()
          if 0 < u:getdata("女神力") then
            local str = ""
            str = str .. "|cFF6699FF女神力：" .. u:getdata("女神力")
            u:sendmessage(str)
          end
        end
        if tg.handle == Hero[sy] then
          FlashUIhide()
          uivar_main:hide()
        end
      end
    end
  end)
  u:addtrgevent("玩家-取消选择单位", function(args)
    local tg = getunit(args.unit)
    if u:islocal() then
      local p = getplayer(args.player)
      if p.handle == u.owner then
        local sy = u.ownerid
        if tg.handle == Ewl_Third[sy] or tg.handle == Ewl_Mind[sy] or tg.handle == Ewl_Body[sy] or tg.handle == Ewl_Blood[sy] or tg.handle == Ewl_Disease[sy] or tg.handle == Ewl_Coop[sy] or tg.handle == Ewl_State[sy] then
          FlashUIhide()
          uivar_main:hide()
        end
      end
    end
  end)
end

function func1(self, player)
  uivar_click_scale(self)
  if not clickGCD then
    clickGCD = true
    ac.wait(500, function()
      clickGCD = false
    end)
  elseif not clickTextGCD then
    local u = getunit(Hero[LocalPlayerID])
    u:sendmessage("|cFF6699FF点击过快|r")
    clickTextGCD = true
    ac.wait(3000, function()
      clickTextGCD = false
    end)
  end
end

local function func1gg(self, player)
  uivar_click_scale(self)
end

local function uivar_add_button_cd_animation(button)
  local x = button.uivar_cd_x or 0
  local y = button.uivar_cd_y or 0
  local width = button.uivar_cd_w or w
  local height = button.uivar_cd_h or h
  if button._cd_animation == nil then
    button:add_cd_animation(x, y, width, height)
  else
    local texture = button._cd_animation
    texture.bx = x
    texture.by = y
    texture.bw = width
    texture.bh = height
    texture:set_position(x, y)
    texture:set_control_size(width, height)
  end
end

function func1_click(self, player)
  func1gg(self, player)
  if not clickGCD then
    clickGCD = true
    ac.wait(500, function()
      clickGCD = false
    end)
    uivar_add_button_cd_animation(self)
    local nowcd = self:get_cd()
    if 0 < nowcd then
      local u = getunit(Hero[LocalPlayerID])
      u:sendmessage("|cFF6699FF冷却:" .. math.floor(nowcd) .. "秒|r")
    else
      self:set_cd(self.savecd, self.savecd)
    end
  elseif not clickTextGCD then
    local u = getunit(Hero[LocalPlayerID])
    u:sendmessage("|cFF6699FF点击过快|r")
    clickTextGCD = true
    ac.wait(3000, function()
      clickTextGCD = false
    end)
  end
end

function func1_rightclick(self, player)
  func1gg(self, player)
  if not clickGCD then
    clickGCD = true
    ac.wait(500, function()
      clickGCD = false
    end)
    uivar_add_button_cd_animation(self)
    local nowcd = self:get_cd()
    if 0 < nowcd then
      local u = getunit(Hero[LocalPlayerID])
      u:sendmessage("|cFF6699FF冷却:" .. math.floor(nowcd) .. "秒|r")
    else
      self:set_cd(self.saverightcd, self.saverightcd)
    end
  elseif not clickTextGCD then
    local u = getunit(Hero[LocalPlayerID])
    u:sendmessage("|cFF6699FF点击过快|r")
    clickTextGCD = true
    ac.wait(3000, function()
      clickTextGCD = false
    end)
  end
end

local function func2(self, player)
  if self.hashover then
    self:set_alpha(225)
  else
    self:set_alpha(150)
  end
  UIYNameKey = self
  Boolean_UIYName = false
  if self.ishasjbtext then
    UIYNameUseKey = self
    Boolean_UIYName = true
    self.ishasjbtext()
  end
  if self.has_branch_ui then
    if not uivar_branch_is_locked then
      uivar_show_branch_panel(self)
    end
  else
    uivar_show_default_button_detail(self)
  end
  local cdshow = self._cd_animation
  if cdshow then
    cdshow:set_alpha(0.7)
  end
end

local function func3(self, player)
  self:set_alpha(255)
  if self.has_branch_ui then
    uivar_maybe_hide_unlocked_branch(self)
  else
    uiy_hide()
  end
  Boolean_UIYName = false
  local cdshow = self._cd_animation
  if cdshow then
    cdshow:set_alpha(0.7)
  end
end

local function bind_uivar_button_events(u, btn, ishasclick, syncid, clickfunc, rightclickfunc)
  btn.sync_owner_id = u.ownerid
  if ishasclick then
    btn.on_button_clicked = func1_click
    btn.on_button_right_clicked = func1_rightclick
  else
    btn.on_button_clicked = func1
    btn.on_button_right_clicked = func1
  end
  btn.on_button_mouse_enter = func2
  btn.on_button_mouse_leave = func3
  if syncid ~= 0 then
    btn.sync_key = "btn" .. syncid
    if clickfunc then
      function btn:on_sync_button_clicked()
        uiy_hide()
        
        if synczu[syncid] then
          synczu[syncid](u, btn.vardata, self)
        end
      end
    else
      btn.on_sync_button_clicked = nil
    end
    if rightclickfunc then
      function btn:on_sync_button_right_clicked()
        uiy_hide()
        
        if syncrightzu[syncid] then
          syncrightzu[syncid](u, btn.vardata, self)
          if u:islocal() then
          end
        end
      end
    else
      btn.on_sync_button_right_clicked = nil
    end
  else
    btn.sync_key = nil
    btn.on_sync_button_clicked = nil
    btn.on_sync_button_right_clicked = nil
  end
end

function unit:uivar_add(args)
  local u = self
  local ishasclick = false
  local clickfunc = args.clickfunc
  local rightclickfunc = args.rightclickfunc
  local local_rightclickfunc = args.local_rightclickfunc
  local yitai_resonance_key
  if args.branch_ui == true and not clickfunc and uivar_get_yitai_resonance_key(args.vardata) then
    yitai_resonance_key = uivar_get_yitai_resonance_key(args.vardata)
  end
  local syncid = 0
  if clickfunc or rightclickfunc then
    synccount = synccount + 1
    if clickfunc then
      synczu[synccount] = clickfunc
      ishasclick = true
    end
    if rightclickfunc then
      syncrightzu[synccount] = rightclickfunc
      ishasclick = true
    end
    syncid = synccount
  end
  local sy = u.ownerid
  local jbtext = args.jbtext
  local keyname = args.keyname
  local text = args.text
  local keytype = args.keytype
  if args.seckey then
    keytype = keytype .. args.seckey
  end
  local ishasphoto = args.ishasphoto or false
  local icon = args.icon
  local smallicon = args.smallicon or icon
  local hoverimage = args.hoverimage
  if uivarg[sy][keytype] == nil then
    logintype(keytype)
  end
  for index, value in ipairs(uivarg[sy][keytype]) do
    if value.keyname == keyname then
      print("已存在变异")
      return
    end
  end
  local new = class.button:builder({
    parent = OriginPanel,
    x = 0,
    y = 0,
    w = 1,
    h = 1
  })
  count[sy][keytype] = count[sy][keytype] + 1
  new.vardata = args.vardata
  new.keyname = keyname
  if u:islocal() then
    local he, wt = textjisuan(text)
    if wt <= 400 then
      wt = 400
    end
    if he <= 60 then
      he = 60
    end
    countx[keytype] = countx[keytype] + 1
    if 5 <= countx[keytype] then
      countx[keytype] = 1
      county[keytype] = county[keytype] + 1
    end
    if 3 <= county[keytype] and 3 <= countx[keytype] then
      countx[keytype] = 1
      county[keytype] = 1
    end
    local is_h5 = false
    icon = uivar_complete_image_suffix(icon)
    smallicon = uivar_complete_image_suffix(smallicon)
    local cdtime = args.cd or 1
    local cdtime2 = args.rightcd or 1
    new:set_position(startx + dilx * (countx[keytype] - 1), starty + dily * (county[keytype] - 1))
    new:set_width(w * buttonsize)
    new:set_height(h * buttonsize)
    new:set_control_size(new:get_width(), new:get_height())
    uivar_set_base_size(new)
    new:set_normal_image(smallicon)
    if hoverimage then
      new.hover_image = hoverimage
      new.hashover = true
    end
    new.saveicon = icon
    new.savehe = he
    new.savewt = wt
    new.dx = args.dx or 3
    new.dx_h = args.size_h
    new.savecd = cdtime
    new.saverightcd = cdtime2
    new.iconx = countx[keytype]
    new.icony = county[keytype]
    new.savetext = text
    new.ishasjbtext = jbtext
    new.ishasphoto = ishasphoto
    new.has_branch_ui = args.branch_ui == true
    new.branch_vars = args.branch_vars
    new.branch_title = args.branch_title or args.branch_name
    if u:hasdata("环都市-感染中") then
      local delisha = class.panel:builder({
        parent = new,
        x = 0,
        y = 0,
        w = w * buttonsize,
        h = h * buttonsize,
        normal_image = "Icon_Delisha.blp"
      })
      new.tubiao_delisha = delisha
    end
    if u:hasdata("幻想乡-临时获取") then
      local delisha = class.panel:builder({
        parent = new,
        x = w * buttonsize * 0.3,
        y = h * buttonsize * 0.3,
        w = w * buttonsize * 0.7,
        h = h * buttonsize * 0.7,
        normal_image = "Icon_Limited.blp"
      })
      new.tubiao_xianshi = delisha
    end
    if u:hasdata("变异大图-伊利亚") then
      new.Datu = "PhFg_Yly"
    end
  end
  uivarg[sy][keytype][count[sy][keytype]] = new
  new.has_branch_ui = args.branch_ui == true
  new.branch_vars = args.branch_vars
  new.branch_title = args.branch_title or args.branch_name
  bind_uivar_button_events(u, new, ishasclick, syncid, clickfunc, rightclickfunc)
  new:hide()
  if u:islocal() then
    if yitai_resonance_key then
      function new:on_button_clicked(player)
        uivar_click_scale(self)
        
        if not clickGCD then
          clickGCD = true
          ac.wait(500, function()
            clickGCD = false
          end)
          uivar_sync_yitai_resonance(yitai_resonance_key)
        elseif not clickTextGCD then
          local hero = getunit(Hero[LocalPlayerID])
          hero:sendmessage("|cFF6699FF点击过快|r")
          clickTextGCD = true
          ac.wait(3000, function()
            clickTextGCD = false
          end)
        end
      end
    end
    if local_rightclickfunc then
      function new:on_button_right_clicked()
        uiy_hide()
        
        local_rightclickfunc(u, new.vardata, self)
      end
    end
    if newup:get_is_show() then
      FlashUIvar()
    end
  end
end

local dhe, dwt = textjisuan("|cFF7DBEF1————현재 페이지:[1]————\n————다음 페이지————")
newup = class.button:builder({
  parent = OriginPanel,
  x = startx + dilx * 2,
  y = starty + dily * 2,
  w = w * buttonsize,
  h = h * buttonsize,
  normal_image = "war3mapImported\\BTNCommand_Change.blp",
  keys = {},
  on_button_mousedown = function(self, palyer)
    uivar_click_scale(self)
    if countdangqianye[nowkey] then
      countdangqianye[nowkey] = countdangqianye[nowkey] - 1
      if countdangqianye[nowkey] <= 1 then
        countdangqianye[nowkey] = 1
      end
    end
    local show = false
    if newback:get_is_show() then
      show = true
    end
    FlashUIvar()
    if show then
      newback:show()
    end
    local dcount = countdangqianye[nowkey] or 1
    uiy_show_text("|cFF7DBEF1————현재 페이지:[" .. dcount .. "]————\n————이전 페이지————|r", "Var")
  end,
  on_button_mouse_enter = function(self)
    self:set_alpha(150)
    UIYNameKey = self
    local dcount = countdangqianye[nowkey] or 1
    uiy_show_text("|cFF7DBEF1————현재 페이지:[" .. dcount .. "]————\n————이전 페이지————|r", "Var")
  end,
  on_button_mouse_leave = function(self)
    self:set_alpha(255)
    uiy_hide()
  end
})
uivar_set_base_size(newup)
newup:hide()
newup:set_level(2)
newback = class.button:builder({
  x = startx + dilx * -0.75,
  y = starty + dily * -0.75,
  w = w * buttonsize * 0.75,
  h = h * buttonsize * 0.75,
  normal_image = "UIButton_Back.blp",
  keys = {},
  on_button_mousedown = function(self, palyer)
    uivar_click_scale(self)
    self:set_alpha(255)
    uiy_hide()
    if lastkey == "hero" then
      local u = getunit(Hero[LocalPlayerID])
      u:select()
      lastkey = ""
    else
      nowkey = lastkey
      FlashUIvar()
    end
  end,
  on_button_mouse_enter = function(self)
    self:set_alpha(150)
    UIYNameKey = self
    uiy_show_text("|cFF7DBEF1————返回————\n————返回上一栏————|r", "Var")
  end,
  on_button_mouse_leave = function(self)
    self:set_alpha(255)
    uiy_hide()
  end
})
uivar_set_base_size(newback)
newback:hide()
newnext = class.button:builder({
  parent = OriginPanel,
  x = startx + dilx * 3,
  y = starty + dily * 2,
  w = w * buttonsize,
  h = h * buttonsize,
  normal_image = "war3mapImported\\BTNCommand_Change.blp",
  keys = {},
  on_button_mousedown = function(self, palyer)
    uivar_click_scale(self)
    if countdangqianye[nowkey] then
      countdangqianye[nowkey] = countdangqianye[nowkey] + 1
      local max = math.floor(count[LocalPlayerID][nowkey] / 10) + 1
      if max <= countdangqianye[nowkey] then
        countdangqianye[nowkey] = max
      end
    end
    local show = false
    if newback:get_is_show() then
      show = true
    end
    FlashUIvar()
    if show then
      newback:show()
    end
    local dcount = countdangqianye[nowkey] or 1
    uiy_show_text("|cFF7DBEF1————현재 페이지:[" .. dcount .. "]————\n————다음 페이지————|r", "Var")
  end,
  on_button_mouse_enter = function(self)
    self:set_alpha(150)
    UIYNameKey = self
    local dcount = countdangqianye[nowkey] or 1
    uiy_show_text("|cFF7DBEF1————현재 페이지:[" .. dcount .. "]————\n————다음 페이지————|r", "Var")
  end,
  on_button_mouse_leave = function(self)
    self:set_alpha(255)
    uiy_hide()
  end
})
uivar_set_base_size(newnext)
newnext:hide()
newnext:set_level(2)

function unit:uivar_change(args)
  local u = self
  local ishasclick = false
  local clickfunc = args.clickfunc
  local rightclickfunc = args.rightclickfunc
  local local_rightclickfunc = args.local_rightclickfunc
  local isclearclick = args.isclearclick
  local syncid = 0
  if clickfunc or rightclickfunc then
    synccount = synccount + 1
    if clickfunc then
      synczu[synccount] = clickfunc
      ishasclick = true
    end
    if rightclickfunc then
      syncrightzu[synccount] = rightclickfunc
      ishasclick = true
    end
    syncid = synccount
  end
  if isclearclick then
    ishasclick = false
    syncid = 0
  end
  local sy = u.ownerid
  local keyname = args.keyname
  local keytype = args.keytype or "all"
  if args.seckey then
    keytype = keytype .. args.seckey
  end
  if uivarg[sy][keytype] == nil then
    logintype(keytype)
  end
  local varbut = args.varbutton
  local text = args.text
  local ishasphoto = args.ishasphoto
  local cdtime = args.cd
  local icon = args.icon
  local jbtext = args.jbtext
  local smallicon = args.smallicon
  local cd = args.cd
  local size = args.dx
  local size_h = args.size_h
  local hoverimage = args.hoverimage
  if not varbut then
    if keytype == "all" then
      for _, uivarname in ipairs(alltype) do
        for index, value in ipairs(uivarg[sy][uivarname]) do
          if value.keyname == keyname then
            varbut = value
            break
          end
        end
      end
    else
      local uivar = uivarg[sy][keytype]
      for index, value in ipairs(uivar) do
        if value.keyname == keyname then
          varbut = value
          break
        end
      end
    end
  end
  if not varbut then
    for _, uivarname in ipairs(newtype) do
      local z = uivarg[sy][uivarname]
      if z then
        for index, value in ipairs(z) do
          if value.keyname == keyname then
            varbut = value
            break
          end
        end
      end
    end
    if not varbut then
      print("指定按钮不存在")
      return
    end
  end
  if u:islocal() then
    if size then
      varbut.dx = size
    end
    if size_h then
      varbut.dx_h = size_h
    end
    if jbtext then
      varbut.ishasjbtext = jbtext
    end
    if text then
      local he, wt = textjisuan(text)
      if wt <= 400 then
        wt = 400
      end
      if he <= 60 then
        he = 60
      end
      varbut.savehe = he
      varbut.savewt = wt
      varbut.savetext = text
    end
    if hoverimage then
      varbut.hover_image = hoverimage
      varbut.hashover = true
    end
    if icon or smallicon then
      icon = icon or varbut.saveicon
      icon = uivar_complete_image_suffix(icon)
      if smallicon then
        smallicon = uivar_complete_image_suffix(smallicon)
        varbut:set_normal_image(smallicon)
      else
        varbut:set_normal_image(icon)
      end
      varbut.saveicon = icon
    end
    if u:hasdata("变异大图-伊利亚") then
      varbut.Datu = "PhFg_Yly"
    end
    if cdtime then
      varbut.savecd = cdtime
    end
    if cd then
      varbut.savecd = cd
    end
    if ishasphoto == true or ishasphoto == false then
      varbut.ishasphoto = ishasphoto
    end
    if args.branch_ui ~= nil then
      varbut.has_branch_ui = args.branch_ui == true
    end
    if args.branch_vars ~= nil then
      varbut.branch_vars = args.branch_vars
    end
    if args.branch_title ~= nil or args.branch_name ~= nil then
      varbut.branch_title = args.branch_title or args.branch_name
    end
  end
  if args.branch_ui ~= nil then
    varbut.has_branch_ui = args.branch_ui == true
  end
  if args.branch_vars ~= nil then
    varbut.branch_vars = args.branch_vars
  end
  if args.branch_title ~= nil or args.branch_name ~= nil then
    varbut.branch_title = args.branch_title or args.branch_name
  end
  if isclearclick or ishasclick then
    bind_uivar_button_events(u, varbut, ishasclick, syncid, clickfunc, rightclickfunc)
  end
  if u:islocal() and local_rightclickfunc then
    function varbut:on_button_right_clicked()
      uiy_hide()
      
      local_rightclickfunc(u, varbut.vardata, self)
    end
  end
end

function unit:uivar_add_branch_var(args)
  local u = self
  local sy = u.ownerid
  local varbut = args.varbutton
  local keyname = args.keyname
  local keytype = args.keytype or "all"
  if args.seckey then
    keytype = keytype .. args.seckey
  end
  if uivarg[sy][keytype] == nil then
    logintype(keytype)
  end
  if not varbut then
    if keytype == "all" then
      for _, uivarname in ipairs(alltype) do
        for _, value in ipairs(uivarg[sy][uivarname]) do
          if value.keyname == keyname then
            varbut = value
            break
          end
        end
        if varbut then
          break
        end
      end
    else
      local uivar = uivarg[sy][keytype]
      for _, value in ipairs(uivar) do
        if value.keyname == keyname then
          varbut = value
          break
        end
      end
    end
  end
  if not varbut then
    for _, uivarname in ipairs(newtype) do
      local z = uivarg[sy][uivarname]
      if z then
        for _, value in ipairs(z) do
          if value.keyname == keyname then
            varbut = value
            break
          end
        end
      end
      if varbut then
        break
      end
    end
    if not varbut then
      print("指定按钮不存在")
      return
    end
  end
  local vars = args.vars or args.branch_vars or args.var
  if not vars then
    print("未指定分支变异")
    return
  end
  if vars.name then
    vars = {vars}
  end
  varbut.has_branch_ui = true
  varbut.branch_vars = varbut.branch_vars or {}
  if args.branch_title ~= nil or args.branch_name ~= nil then
    varbut.branch_title = args.branch_title or args.branch_name
  end
  local added = 0
  for _, var in ipairs(vars) do
    if var then
      local exists = false
      if args.allow_duplicate ~= true then
        for _, old in ipairs(varbut.branch_vars) do
          if old == var or old.name and var.name and old.name == var.name then
            exists = true
            break
          end
        end
      end
      if not exists then
        table.insert(varbut.branch_vars, var)
        added = added + 1
      end
    end
  end
  return added, varbut
end

function unit:uivar_flush_yitai_branch_var(branch_key)
  local u = self
  local sy = u.ownerid
  local store = uivar_get_yitai_branch_store(sy)
  local record = store[branch_key]
  if not record then
    return false
  end
  local button = uivar_find_button_by_keyname(sy, record.keyname)
  if not button then
    u:uivar_add({
      keyname = record.keyname,
      keytype = "以太栏",
      text = record.title .. "\n" .. record.text,
      icon = record.icon,
      vardata = record.vardata,
      branch_ui = true,
      branch_title = record.title,
      branch_vars = record.vars
    })
    return true
  end
  u:uivar_add_branch_var({
    varbutton = button,
    branch_title = record.title,
    vars = record.vars
  })
  return true
end

function unit:uivar_flush_yitai_branch_vars()
  local u = self
  local sy = u.ownerid
  local store = uivar_get_yitai_branch_store(sy)
  for branch_key in pairs(store) do
    u:uivar_flush_yitai_branch_var(branch_key)
  end
end

function unit:uivar_record_yitai_branch_var(args)
  local u = self
  local sy = u.ownerid
  local branch_key = args and args.branch_key
  local var = args and args.var
  if not uivar_is_yitai_resonance_key(branch_key) or not var then
    return false
  end
  local store = uivar_get_yitai_branch_store(sy)
  local record = store[branch_key]
  if not record then
    local title = uivar_yitai_branch_title(branch_key)
    local text = uivar_yitai_branch_text(branch_key)
    local icon = args.icon or var.effectart or "war3mapImported\\BTNCommand_Change.blp"
    record = {
      key = branch_key,
      keyname = uivar_yitai_branch_keyname(branch_key),
      title = title,
      text = text,
      icon = icon,
      vardata = {
        name = uivar_yitai_branch_keyname(branch_key),
        effectname = title,
        effecttext = text,
        effectart = icon,
        key = {branch_key}
      },
      vars = {}
    }
    store[branch_key] = record
  end
  local exists = false
  for _, old in ipairs(record.vars) do
    if old == var or old.name and old.name == var.name then
      exists = true
      break
    end
  end
  if not exists then
    table.insert(record.vars, var)
  end
  u:uivar_flush_yitai_branch_var(branch_key)
  ac.wait(100, function()
    u:uivar_flush_yitai_branch_var(branch_key)
  end)
  return true
end

function unit:uivar_setcd(args)
  local u = self
  local sy = u.ownerid
  local keyname = args.keyname
  local keytype = args.keytype or "all"
  if args.seckey then
    keytype = keytype .. args.seckey
  end
  if uivarg[sy][keytype] == nil then
    logintype(keytype)
  end
  if u:islocal() then
    local varbut = args.varbutton
    local nowcd = args.nowcd
    local isclearcd = args.isclearcd or false
    if not varbut then
      if keytype == "all" then
        for _, uivarname in ipairs(alltype) do
          for index, value in ipairs(uivarg[sy][uivarname]) do
            if value.keyname == keyname then
              varbut = value
              break
            end
          end
        end
      else
        local uivar = uivarg[sy][keytype]
        for index, value in ipairs(uivar) do
          if value.keyname == keyname then
            varbut = value
            break
          end
        end
      end
    end
    if not varbut then
      for _, uivarname in ipairs(newtype) do
        local z = uivarg[sy][uivarname]
        if z then
          for index, value in ipairs(z) do
            if value.keyname == keyname then
              varbut = value
              break
            end
          end
        end
      end
      if not varbut then
        print("指定按钮不存在")
        return
      end
    end
    local cd = args.cd or varbut.savecd
    if varbut._cd_animation == nil then
      varbut:add_cd_animation(0, 0, w * buttonsize, h * buttonsize)
    end
    if cd then
      varbut.savecd = cd
    end
    if nowcd then
      varbut:set_cd(nowcd, cd)
    else
      varbut:set_cd(cd, cd)
    end
  end
end

function unit:uivar_each_var(name, keytype, seckey, callback)
  local sy = self.ownerid
  if seckey then
    keytype = keytype .. seckey
  end
  local buttons = uivarg[sy][keytype]
  if not buttons then
    return 0
  end
  local matched = 0
  for _, button in ipairs(buttons) do
    if button and button.vardata and button.vardata.name == name then
      matched = matched + 1
      callback(button)
    end
  end
  return matched
end

function unit:uivar_get(keyname, keytype, seckey)
  local u = self
  local sy = u.ownerid
  keytype = keytype or "all"
  if seckey then
    keytype = keytype .. seckey
  end
  if uivarg[sy][keytype] == nil then
    logintype(keytype)
  end
  local varbut
  if keytype == "all" then
    for _, uivarname in ipairs(alltype) do
      for index, value in ipairs(uivarg[sy][uivarname]) do
        if value.keyname == keyname then
          varbut = value
          keytype = uivarname
          break
        end
      end
    end
  else
    local uivar = uivarg[sy][keytype]
    for index, value in ipairs(uivar) do
      if value.keyname == keyname then
        varbut = value
        break
      end
    end
  end
  if not varbut then
    for _, uivarname in ipairs(newtype) do
      local z = uivarg[sy][uivarname]
      if z then
        for index, value in ipairs(z) do
          if value.keyname == keyname then
            varbut = value
            break
          end
        end
      end
    end
    if not varbut then
      print("指定按钮不存在:varget")
      return
    end
  end
  return varbut
end

function unit:uivar_remove(keyname, keytype, seckey)
  local u = self
  local sy = u.ownerid
  keytype = keytype or "all"
  if seckey then
    keytype = keytype .. seckey
  end
  if uivarg[sy][keytype] == nil then
    logintype(keytype)
  end
  local varbut
  if keytype == "all" then
    for _, uivarname in ipairs(alltype) do
      for index, value in ipairs(uivarg[sy][uivarname]) do
        if value.keyname == keyname then
          varbut = value
          keytype = uivarname
          break
        end
      end
    end
  else
    local uivar = uivarg[sy][keytype]
    for index, value in ipairs(uivar) do
      if value.keyname == keyname then
        varbut = value
        break
      end
    end
  end
  if not varbut then
    for _, uivarname in ipairs(newtype) do
      local z = uivarg[sy][uivarname]
      if z then
        for index, value in ipairs(z) do
          if value.keyname == keyname then
            keytype = uivarname
            varbut = value
            break
          end
        end
      end
    end
    if not varbut then
      print("指定按钮不存在")
      return
    end
  end
  local uivar = uivarg[sy][keytype]
  for index, value in ipairs(uivar) do
    if value.keyname == keyname then
      uivar[index]:destroy()
      uivar[index] = nil
      if index ~= count[sy][keytype] then
        for i = index, count[sy][keytype] - 1 do
          uivar[i] = uivar[i + 1]
          if u:islocal() then
            local panel = uivar[i]
            panel.iconx = panel.iconx - 1
            if panel.iconx <= 0 then
              panel.iconx = 4
              panel.icony = panel.icony - 1
              if 0 >= panel.icony then
                panel.iconx = 2
                panel.icony = 3
              end
            end
            panel:set_position(startx + dilx * (panel.iconx - 1), starty + dily * (panel.icony - 1))
          end
        end
        uivar[count[sy][keytype]] = nil
      end
      count[sy][keytype] = count[sy][keytype] - 1
      if u:islocal() then
        countx[keytype] = countx[keytype] - 1
        if countx[keytype] <= 0 then
          countx[keytype] = 4
          county[keytype] = county[keytype] - 1
          if county[keytype] <= 0 then
            countx[keytype] = 2
            county[keytype] = 3
          end
        end
        if 0 < count[sy][keytype] then
          FlashUIvar()
          if japi.GetRealSelectUnit() == u.handle then
            FlashUIhide()
          end
        end
      end
      return
    end
  end
end
