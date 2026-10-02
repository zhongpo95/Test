-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local BuffUI = {}
local size = 5
local xx, yy = 360, 780
local buff_map = {}
local buff_library = {}
local active_buffs = {}

local function get_duration_label_y(stack)
  local base_y = size * 7.1 * 1.23 + 2.5
  if stack and 1 < stack then
    return base_y + 8
  end
  return base_y
end

local function rearrange_buffs()
  for i, buff in ipairs(active_buffs) do
    local new_x = 40 + (i - 1) * (size * 9.1 + 10)
    buff.icon:set_position(new_x, 0)
  end
end

function BuffUI.register(id, config, overwrite)
  assert(id, "必须提供 Buff 的 id")
  assert(type(config) == "table", "config 必须是 table")
  if not overwrite and buff_library[id] then
    return
  end
  if config.show_time == nil then
    config.show_time = true
  end
  config.show_stack_in_time = config.show_stack_in_time or false
  buff_library[id] = {
    image = config.image or "Touming.tga",
    color = config.color or "FFFFCC33",
    on_enter = config.on_enter or function(self)
      uiy_show_text("|cFFAAAAAA状态：" .. id .. "|r", "Buff")
    end,
    on_leave = config.on_leave or uiy_hide,
    stack = config.stack,
    show_time = config.show_time,
    show_stack_in_time = config.show_stack_in_time
  }
end

local function create_buff_icon(config)
  local lib = buff_library[config.id]
  for k, v in pairs(lib) do
    config[k] = config[k] or v
  end
  local buff = {
    id = config.id,
    remaining = config.duration,
    stack = config.stack or 1,
    is_hovered = false
  }
  local icon = class.button:builder({
    parent = BuffPanel,
    x = 0,
    y = 0,
    w = size * 9.1,
    h = size * 7.1 * 1.23,
    normal_image = config.image,
    on_button_mouse_enter = function(self)
      buff.is_hovered = true
      config.on_enter(self)
    end,
    on_button_mouse_leave = function(self)
      buff.is_hovered = false
      config.on_leave(self)
    end
  })
  local label_y = get_duration_label_y(buff.stack)
  local label
  if config.show_stack_in_time then
    label = class.text:builder({
      parent = icon,
      x = 0,
      y = label_y,
      w = size * 9.1,
      h = 24,
      text = buff.stack > 1 and buff.stack or "",
      align = "center",
      font_size = 10
    })
  elseif config.show_time then
    label = class.text:builder({
      parent = icon,
      x = 0,
      y = label_y,
      w = size * 9.1,
      h = 24,
      text = math.floor(config.duration),
      align = "center",
      font_size = 10
    })
  end
  if label then
    japi.FrameSetSize(label._id, size * 9.1 / 1920 * 0.8, 24 / 1080 * 0.6)
    label:set_color(config.color)
  end
  local stack_label
  if not config.show_stack_in_time then
    stack_label = class.text:builder({
      parent = icon,
      x = -3,
      y = size * 7.1 * 1.23 - 4,
      w = size * 9.1,
      h = 24,
      text = buff.stack > 1 and "×" .. buff.stack or "",
      align = "right",
      font_size = 10
    })
    stack_label:set_color(config.color)
    japi.FrameSetSize(stack_label._id, size * 9.1 / 1920 * 0.8, 24 / 1080 * 0.6)
  end
  buff.icon = icon
  buff.label = label
  buff.stack_label = stack_label
  table.insert(active_buffs, buff)
  buff_map[buff.id] = buff
  rearrange_buffs()
end

function BuffUI.apply(input)
  local u = input.u
  if u and not u:islocal() then
    return
  end
  local id = input.id
  local duration = input.duration or 5
  assert(id, "BuffUI.apply 必须传入 id")
  if not buff_library[id] then
    print("未注册的Buff种类")
    return
  end
  local existing = buff_map[id]
  if existing then
    existing.remaining = duration
    return
  end
  local lib = buff_library[id]
  local stack_value = 1
  if type(lib.stack) == "function" then
    local ok, result = pcall(lib.stack, lib)
    if ok and type(result) == "number" then
      stack_value = result
    end
  end
  create_buff_icon({
    id = id,
    duration = duration,
    stack = stack_value
  })
  BuffUI.set_visible(true)
end

function BuffUI.remove(id, u)
  if u and not u:islocal() then
    return
  end
  local buff = buff_map[id]
  if not buff then
    return
  end
  if buff.is_hovered then
    uiy_hide()
  end
  if buff.icon then
    buff.icon:destroy()
  end
  for i, b in ipairs(active_buffs) do
    if b == buff then
      table.remove(active_buffs, i)
      break
    end
  end
  buff_map[id] = nil
  rearrange_buffs()
  if #active_buffs == 0 then
    BuffUI.set_visible(false)
  end
end

function BuffUI.clear_all(u)
  if u and not u:islocal() then
    return
  end
  for _, buff in ipairs(active_buffs) do
    if buff.icon then
      buff.icon:destroy()
    end
  end
  active_buffs = {}
  buff_map = {}
end

function BuffUI.set_visible(flag)
  if flag then
    BuffPanel:show()
  else
    BuffPanel:hide()
  end
end

if BuffPanel then
  BuffPanel:destroy()
end
BuffPanel = class.button:builder({
  x = xx,
  y = yy,
  w = 35.2,
  h = 27.200000000000003,
  normal_image = "war3mapImported\\BTNCommand_Skill.blp",
  on_button_update_drag = function(self, icon, x, y)
    self:set_position(x, y)
  end
})
BuffPanel:set_enable_drag(true)
BuffPanel:set_alpha(55)
BuffPanel:hide()
ac.loop(100, function()
  local dt = 0.1
  for i = #active_buffs, 1, -1 do
    local buff = active_buffs[i]
    local lib = buff_library[buff.id]
    local new_stack = 1
    if lib and type(lib.stack) == "function" then
      local ok, result = pcall(lib.stack, lib)
      if ok and type(result) == "number" then
        new_stack = result
      end
    end
    if not lib.show_stack_in_time then
      buff.remaining = buff.remaining - dt
    end
    local text = 1 < new_stack and "×" .. new_stack or ""
    local changed = false
    if buff.stack ~= new_stack then
      buff.stack = new_stack
      changed = true
    end
    if buff.stack_label then
      buff.stack_label:set_text(text)
    end
    if buff.label and lib then
      if lib.show_stack_in_time then
        text = 0 <= new_stack and tostring(math.floor(new_stack)) or "0"
        buff.label:set_text(text)
        if changed then
          buff.label:set_position(0, get_duration_label_y(new_stack))
        end
      elseif lib.show_time then
        buff.label:set_text(math.floor(buff.remaining))
        if changed then
          buff.label:set_position(0, get_duration_label_y(new_stack))
        end
      else
        buff.label:set_text("")
      end
    end
    if buff.remaining <= 0 then
      BuffUI.remove(buff.id)
    end
  end
end)
return BuffUI
