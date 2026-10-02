-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
storm = require("jass.storm")
japi = require("jass.japi")
game_ui = japi.GetGameUI()
global_blp_map = {}

function blp_rect(path, left, top, right, bottom)
  left = math.modf(left)
  top = math.modf(top)
  right = math.modf(right)
  bottom = math.modf(bottom)
  local key = string.format("%i_%i_%i_%i.blp", left, top, right, bottom)
  local newPath = path:gsub("%.blp", key .. ".blp")
  if global_blp_map[newPath] == nil then
    japi.EXBlpRect(path, newPath, left, top, right, bottom)
    global_blp_map[newPath] = true
  end
  return newPath
end

function blp_sector(path, x, y, r, angle, section)
  x = math.modf(x)
  y = math.modf(y)
  angle = math.modf(angle)
  r = math.modf(r)
  section = math.modf(section)
  local key = string.format("%i_%i_%i_%i_%i", x, y, r, angle, section)
  local newPath = path:gsub("%.blp", key .. ".blp")
  if global_blp_map[newPath] == nil then
    japi.EXBlpSector(path, newPath, x, y, r, angle, section)
    global_blp_map[newPath] = true
  end
  return newPath
end

-- 실행 중 파일 저장 대신 맵에 미리 포함한 UI 정의를 읽는다.
function load_fdf(data)
  require("hera_fdf").load(data)
end

function converScreenPosition(x, y)
  x = x / 1920 * 0.8
  y = (1080 - y) / 1080 * 0.6
  return x, y
end

function converScreenSize(width, height)
  width = width / 1920 * 0.8
  height = height / 1080 * 0.6
  return width, height
end

function extends(...)
  local parents = {
    ...
  }
  local count = select("#", ...)
  return function(child_class)
    local parent_class = parents[1]
    local tbl = {}
    local mt = getmetatable(parent_class)
    if mt ~= nil then
      tbl.__tostring = mt.__tostring
      tbl.__call = mt.__call
    end
    if count == 1 then
      tbl.__index = parent_class
    else
      function tbl:__index(key)
        for i = 1, count do
          local v = parents[i]
          
          if v and v[key] then
            return v[key]
          end
        end
      end
    end
    setmetatable(child_class, tbl)
    return child_class
  end
end

class = {
  __newindex = function(self, name, value)
    if not rawget(value, "create") then
      function value.create(...)
        return value.new(nil, ...)
      end
    end
    if not rawget(value, "add_child") then
      function value.add_child(...)
        return value.new(...)
      end
    end
    if not rawget(value, "get_instance") then
      function value.get_instance()
        local instance = value.instance
        
        if instance == nil then
          instance = value.create()
          value.instance = instance
        end
        return instance
      end
    end
    rawset(self, name, value)
    if class.panel and not class.panel["add_" .. name] then
      class.panel["add_" .. name] = function(parent, ...)
        return parent:add(value, ...)
      end
    end
  end
}
setmetatable(class, class)
class.handle_manager = {
  create = function()
    local object = {
      top = 1,
      stack = {},
      map = {},
      id_table = {},
      __index = class.handle_manager
    }
    setmetatable(object, object)
    return object
  end,
  destroy = function(self)
  end,
  allocate = function(self)
    local _id = self.top
    local stack = self.stack
    if #stack == 0 then
      _id = self.top
      self.top = self.top + 1
    else
      _id = stack[#stack]
      table.remove(stack, #stack)
      self.map[_id] = nil
    end
    self.id_table[_id] = 1
    return _id
  end,
  free = function(self, _id)
    if self.id_table[_id] == nil and self.map[_id] ~= nil then
      print("重复回收", _id, debug.traceback())
    elseif self.id_table[_id] == nil then
      print("非法回收", _id, debug.traceback())
    end
    if self.map[_id] == nil and self.id_table[_id] ~= nil then
      self.map[_id] = 1
      self.id_table[_id] = nil
      table.insert(self.stack, _id)
    end
  end
}
class.ui_base = {
  parent_id = game_ui,
  handle_manager = class.handle_manager.create(),
  x = 0,
  y = 0,
  w = 0,
  h = 0,
  is_show = true,
  level = 0,
  alpha = 1,
  _index = nil,
  _name = nil,
  children = nil,
  bind_world = false,
  world_x = 0,
  world_y = 0,
  world_z = 0,
  world_unit = nil,
  world_anchor = "top",
  world_auto_remove = true,
  _controls = {},
  create = function(parent, types, x, y, width, height)
    local index = class.ui_base.handle_manager:allocate()
    local ui = {
      x = x,
      y = y,
      w = width,
      h = height,
      children = {},
      _index = index,
      _name = (parent and parent._name or "object_") .. tostring(index) .. "_"
    }
    setmetatable(ui, ui)
    class.ui_base._controls[ui] = true
    return ui
  end,
  destroy = function(self)
    if self._id == nil or self._id == 0 then
      return
    end
    if self.bind_world then
      self:unbind_world()
    end
    if self.parent and self.parent.children then
      for i, child in ipairs(self.parent.children) do
        if child == self then
          table.remove(self.parent.children, i)
          break
        end
      end
      if self.parent.on_update_child then
        self.parent:on_update_child(self)
      end
    end
    class.ui_base._controls[self] = nil
    japi.DestroyFrame(self._id)
    class.ui_base.handle_manager:free(self._index)
    self._id = nil
    local children = self.children
    self.children = nil
    for i = #children, 1, -1 do
      local object = children[i]
      if object then
        object:destroy()
      end
    end
  end,
  init = function(self)
    self:set_position(self.x, self.y)
    self:set_control_size(self.w, self.h)
    if self.parent == nil and rawget(self, "level") then
      self:set_level(self.level)
    end
    self:set_alpha(self.alpha)
    if self.is_show == false or self.scroll_hide then
      japi.FrameShow(self._id, false)
    end
    return self
  end,
  show = function(self)
    if self.is_show then
      return
    end
    self.is_show = true
    japi.FrameShow(self._id, true)
  end,
  hide = function(self)
    if self.is_show == false then
      return
    end
    self.is_show = false
    japi.FrameShow(self._id, false)
  end,
  set_alpha = function(self, value)
    if value <= 1 then
      value = value * 255
    end
    japi.FrameSetAlpha(self._id, value)
  end,
  set_time = function(self, time)
    game.wait(time * 1000, function()
      self:destroy()
    end)
  end,
  get_alpha = function(self)
    return japi.FrameGetAlpha(self._id)
  end,
  get_position = function(self)
    return self.x, self.y
  end,
  set_position = function(self, x, y)
    if self._id == nil or self._id == 0 then
      return
    end
    self.x = x
    self.y = y
    if self.parent and self.parent.is_scroll and not self.is_scroll_button then
      y = y - self.parent.scroll_y
    end
    if self:is_in_scroll_panel() then
      return
    end
    if self._panel then
      local align = self.align or 0
      if type(self.align) == "string" then
        align = self.align_map[self.align] or 0
      end
      align = math.max(align, 0)
      japi.FrameSetPoint(self._id, align, self._panel._id, align, 0, 0)
      return
    end
    if self.parent == nil then
      x, y = converScreenPosition(x, y)
      japi.FrameSetAbsolutePoint(self._id, 0, x, y)
    else
      x = x / 1920 * 0.8
      y = -y / 1080 * 0.6
      japi.FrameSetPoint(self._id, 0, self.parent._id, 0, x, y)
    end
  end,
  get_width = function(self)
    -- 이 컨트롤의 폭은 모든 크기 변경 경로에서 self.w로 유지된다.
    return self.w
  end,
  get_height = function(self)
    return japi.FrameGetHeight(self._id) / 0.6 * 1080
  end,
  set_width = function(self, width)
    self.w = width
    japi.FrameSetSize(self._id, width / 1920 * 0.8, self.h / 1080 * 0.6)
  end,
  set_height = function(self, height)
    self.h = height
    japi.FrameSetSize(self._id, self.w / 1920 * 0.8, height / 1080 * 0.6)
  end,
  set_control_size = function(self, width, height)
    if self._id == nil or self._id == 0 then
      return
    end
    self.w = width
    self.h = height
    width, height = converScreenSize(width, height)
    japi.FrameSetSize(self._id, width, height)
    self:is_in_scroll_panel()
  end,
  set_level = function(self, level)
    self.level = level
    japi.FrameSetLevel(self._id, level)
  end,
  set_relative_size = function(self, size, not_scale_font)
    local scale = self._scale or 1
    local default = self.default_size or 1
    local old_size = (self.relative_size or 1) * default
    local real_size = 1 / old_size * size * scale
    self.relative_size = size
    self.default_size = scale
    if self.set_size and not_scale_font ~= true then
      self:set_size(self.size or 1)
    end
    if self._control == nil then
      self:set_control_size(self.w * real_size, self.h * real_size)
    end
    for index, child in ipairs(self.children) do
      if child._control == nil then
        child._scale = scale
        child:set_relative_size(size, not_scale_font)
        child:set_position(child.x * real_size, child.y * real_size)
      end
    end
  end,
  set_normal_image = function(self, image_path, flag)
    if self._id == nil or self._id == 0 then
      return
    end
    self.normal_image = image_path
    if image_path == "" then
      image_path = "core\\Transparent.tga"
    end
    japi.FrameSetTexture(self._id, image_path, flag or 0)
  end,
  update_normal_image = function(self)
    if self._id == nil or self._id == 0 then
      return
    end
    local image = self.normal_image or ""
    self.normal_image = ""
    self:set_normal_image(image)
  end,
  set_tooltip = function(self, tip, x, y, width, height, font_size, offset)
  end,
  remove_tooltip = function()
  end,
  get_this_class = function(self)
    local metatable = getmetatable(self)
    return metatable.__index
  end,
  get_parent_class = function(self)
    local class = self:get_this_class()
    if class ~= nil then
      local metatable = getmetatable(class)
      return metatable.__index
    end
    return nil
  end,
  point_in_rect = function(self, x, y)
    local ox, oy = self:get_real_position()
    if x >= ox and y >= oy and x <= ox + self.w and y <= oy + self.h then
      return true
    end
    return false
  end,
  get_root_control = function(self)
    local root = self
    for i = 1, 1000 do
      if root.parent then
        root = root.parent
      else
        break
      end
    end
    return root
  end,
  get_stack_count = function(self)
    local stack = 0
    local root = self
    for i = 1, 1000 do
      if root.parent then
        stack = stack + 1
        root = root.parent
      else
        break
      end
    end
    return stack
  end,
  get_real_position = function(self)
    local ox, oy = 0, 0
    local object = self
    while object ~= nil do
      ox = ox + (object.x or 0)
      oy = oy + (object.y or 0)
      if object.parent then
        oy = oy - (object.parent.scroll_y or 0)
      end
      object = object.parent
    end
    return ox, oy
  end,
  set_real_position = function(self, x, y, anchor)
    if anchor then
      local offect_x, offect_y = self:get_anchor_offset(anchor)
      x = x + offect_x
      y = y + offect_y
    end
    local rx, ry = self:get_real_position()
    x = x - (rx - self.x)
    y = y - (ry - self.y)
    self:set_position(x, y)
  end,
  get_is_show = function(self)
    local object = self
    while object ~= nil do
      if object.is_show == false or object.scroll_hide then
        return false
      end
      object = object.parent
    end
    return true
  end,
  get_child_max_y = function(self, is_depth)
    local function find(object)
      local y = 0
      
      if object.children then
        for name, control in ipairs(object.children) do
          if control._id and y < control.y + control.h and not control.is_scroll_button and control.is_show then
            y = control.y + control.h
            if is_depth then
              y = y + find(control)
            end
          end
        end
      end
      return y
    end
    
    return find(self)
  end,
  get_child_max_h = function(self, is_depth)
    local function find(object)
      local y = 0
      
      if object.children then
        for name, control in ipairs(object.children) do
          if control._id and y < control.y + control.h and not control.is_scroll_button and control.is_show then
            y = control.h
            if is_depth then
              y = y + find(control)
            end
          end
        end
      end
      return y
    end
    
    return find(self)
  end,
  is_in_scroll_panel = function(self)
    local parent = self.parent
    if parent == nil then
      return false
    end
    local scroll = parent.scroll_button
    if scroll == nil then
      return false
    end
    if self == scroll or self == scroll._panel then
      return false
    end
    local max_y = self.parent_max_y or parent:get_child_max_y()
    local y = self.y - (parent.scroll_y or 0)
    if (0 > self.x or 0 > y + self.h or y > parent.h) and self ~= scroll then
      self.scroll_hide = true
      japi.FrameShow(self._id, false)
      scroll:show()
      local size = math.min(1, parent.h / max_y)
      local max_height = size * parent.h
      scroll:set_control_size(scroll.w, math.max(64, max_height))
      return false
    end
    if max_y < parent.h then
      scroll:hide()
    end
    if self.is_show then
      self.scroll_hide = nil
      japi.FrameShow(self._id, true)
    end
    return false
  end,
  bind_unit_overhead = function(self, unit, anchor)
    self.world_unit = unit
    self.bind_world = true
    if anchor then
      self.world_anchor = anchor
    end
    game.bind_world(self, true)
  end,
  set_world_position = function(self, x, y, z, anchor)
    if self.parent then
      print("必须是底层控件才可以绑定到世界坐标", debug.traceback())
      return
    end
    self.world_x = x or 0
    self.world_y = y or 0
    self.world_z = z or 0
    self.bind_world = true
    if anchor then
      self.world_anchor = anchor
    end
    game.bind_world(self, true)
  end,
  unbind_world = function(self)
    self.bind_world = false
    self.world_unit = nil
    self.world_anchor = "top"
    game.bind_world(self, false)
  end,
  event_notify = function(self, event_name, ...)
    local object = self
    if not object.hide_has_event then
      while object ~= nil do
        if object.is_show == false then
          return
        end
        object = object.parent
      end
    end
    self:event_callback(event_name, ...)
    if self.sync_key then
      game.add_event_sync(self, event_name, ...)
    end
  end,
  event_callback = function(self, event_name, ...)
    local retval = true
    local func = self[event_name]
    if func then
      retval = func(self, ...)
    end
    if self.message_stop == true then
      return
    end
    if retval == nil then
      retval = true
    end
    local object = self.parent
    while object ~= nil and retval ~= false do
      local method = object[event_name]
      if method ~= nil then
        retval = method(object, self, ...)
      end
      object = object.parent
    end
  end,
  get_anchor_offset = function(self, anchor, is_negation)
    anchor = anchor or 0
    anchor = class.text.align_map[anchor] or anchor
    if is_negation then
      anchor = math.abs(8 - anchor)
    end
    if anchor == 0 then
      return 0, 0
    elseif anchor == 1 then
      return self.w / 2, 0
    elseif anchor == 2 then
      return self.w, 0
    elseif anchor == 3 then
      return 0, self.h / 2
    elseif anchor == 4 then
      return self.w / 2, self.h / 2
    elseif anchor == 5 then
      return self.w, self.h / 2
    elseif anchor == 6 then
      return 0, self.h
    elseif anchor == 7 then
      return self.w / 2, self.h
    elseif anchor == 8 then
      return self.w, self.h
    end
    return 0, 0
  end,
  get_anchor_offset_position = function(self, anchor, is_negation)
    local x, y = self:get_real_position()
    local ox, oy = self:get_anchor_offset(anchor, is_negation)
    return x + ox, y + oy
  end,
  set_anchor_position = function(self, self_anchor, target, target_anchor, x, y)
    local self_x, self_y = self:get_anchor_offset(self_anchor)
    local target_x, target_y = target:get_anchor_offset_position(target_anchor)
    self:set_real_position(target_x - self_x + x, target_y - self_y + y)
  end,
  set_tooltip_follow = function(self, tooltip, anchor, offset_x, offset_y)
    local self_x, self_y = self:get_anchor_offset_position(anchor)
    local w, h = tooltip:get_anchor_offset(anchor, true)
    local x, y = self_x + (offset_x or 0), self_y + (offset_y or 0)
    x = x - w
    y = y - h
    x = math.max(0, math.min(1920 - tooltip.w, x))
    y = math.max(0, math.min(1080 - tooltip.h, y))
    tooltip:set_real_position(x, y)
  end,
  set_ignore_trackevents = function(self, bool)
    self.ignore = bool
    japi.FrameSetIgnoreTrackEvents(self._id, bool)
  end,
  set_view_port = function(self, bool)
    japi.FrameSetViewPort(self._id, bool)
  end
}
