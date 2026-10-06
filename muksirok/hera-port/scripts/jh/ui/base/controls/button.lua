-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
require("jh.ui.base.controls.class")
require("jh.ui.base.controls.panel")
class.button = extends(class.panel)({
  button_map = {},
  is_enable = true,
  has_ani = false,
  normal_image = "",
  hover_image = "",
  active_image = "",
  _type = "button",
  _base = "GLUETEXTBUTTON",
  build = function(self)
    local panel = class.panel:builder({
      _type = self._panel_type,
      parent = self.parent,
      w = self.w,
      h = self.h
    })
    if panel == nil then
      print("按钮背景创建失败")
      return
    end
    self._id = japi.CreateFrameByTagName(self._base, self._name, panel._id, self._type, 0)
    if self._id == nil or self._id == 0 then
      class.ui_base.destroy(self)
      log.error("创建按钮失败")
      return
    end
    panel._control = self
    self._panel = panel
    self.button_map[self._id] = self
    self:reset()
    if self.has_ani then
      self:add_traceable_animation()
    end
    require("hera_button_input").bind_button(self)
    return self
  end,
  reset = function(self)
    self:init()
    self:set_normal_image(self.normal_image)
  end,
  new = function(parent, image_path, x, y, width, height, has_ani)
    local ui = class.button:builder({
      parent = parent,
      normal_image = image_path,
      x = x,
      y = y,
      w = width,
      h = height,
      has_ani = has_ani
    })
    return ui
  end,
  destroy = function(self)
    if self._id == nil or self._id == 0 then
      return
    end
    require("hera_button_input").unbind_button(self)
    self._panel:destroy()
    self.button_map[self._id] = nil
    class.ui_base.destroy(self)
  end,
  show = function(self)
    class.ui_base.show(self)
    self._panel:show()
  end,
  hide = function(self)
    class.ui_base.hide(self)
    self._panel:hide()
  end,
  add_traceable_animation = function(self)
    function self:on_button_mouse_enter()
      if not self._is_ani then
        self._is_ani = true
        
        local w, h = self.w, self.h
        self._scale = 1.05
        self:set_relative_size(self.relative_size or 1)
        self:set_position(self.x - (self.w - w) / 2, self.y - (self.h - h) / 2)
      end
    end
    
    function self:on_button_mouse_leave()
      if self._is_ani then
        local w, h = self.w, self.h
        self._scale = 1
        self:set_relative_size(self.relative_size or 1)
        self:set_position(self.x - (self.w - w) / 2, self.y - (self.h - h) / 2)
        self._is_ani = false
      end
    end
    
    function self:on_button_mousedown()
      self:on_button_mouse_leave()
    end
    
    function self:on_button_mouseup()
      local x, y = game.get_mouse_pos()
      if self:point_in_rect(x, y) and self:get_is_show() then
        self:on_button_mouse_enter()
      else
        self:on_button_mouse_leave()
      end
    end
  end,
  add_cd_animation = function(self, x, y, width, height)
    if self._cd_animation == nil then
      local texture = self:add_texture("", x, y, width, height)
      texture.bx = x
      texture.by = y
      texture.bw = width
      texture.bh = height
      texture:set_alpha(0.7)
      texture:hide()
      self._cd_animation = texture
      self._cd = 0
      self._max_cd = 1
    end
  end,
  set_cd = function(self, currentValue, maxValue)
    if self._cd_animation == nil then
      print("该按钮缺少cd动画 要调用add_cd_animation 初始化")
      return
    end
    if currentValue ~= nil and 0 < currentValue then
      self:set_enable(false, true)
      self.is_cooldown = true
      self._cd = currentValue
      self._max_cd = maxValue
      self._cd_animation:set_normal_image("war3mapImported\\Black.blp")
      self._cd_animation:show()
      game.loop(50, function(timer)
        local button = self
        local texture = self._cd_animation
        button._cd = button._cd - 0.05
        button:event_callback("on_button_update_cooldown", math.max(button._cd, 0), button._max_cd)
        if button._cd >= 0 then
          local value = texture.bh * button._cd / button._max_cd
          texture:show()
          texture:set_position(texture.bx, texture.by + texture.bh - value)
          texture:set_control_size(texture.bw, value)
        else
          texture:set_normal_image("Blue.tga")
          texture:set_position(texture.bx, texture.by)
          texture:set_control_size(texture.bw, texture.bh)
          if button._cd < -0.1 then
            local texture = button._cd_animation
            button:set_enable(true)
            button.is_cooldown = nil
            texture:hide()
            button:event_callback("on_button_cooldown_end")
            timer:remove()
          end
        end
      end)
    end
  end,
  get_cd = function(self)
    return self._cd, self._max_cd
  end,
  set_enable_image = function(self, image_path, x, y, width, height)
    self._enable_param = {
      image_path or "core\\black_icon.tga",
      x,
      y,
      width,
      height
    }
  end,
  set_enable = function(self, is_enable, not_black)
    self.is_enable = is_enable
    if self._id and self._id ~= 0 then japi.FrameSetEnable(self._id, is_enable == true) end
    if is_enable then
      if self._normal ~= nil then
        self._normal:destroy()
        self._normal = nil
      end
    elseif self._normal == nil and self.normal_image ~= "" and storm.load(self.normal_image) ~= nil and not_black ~= true then
      if self._enable_param then
        self._normal = self:add_texture(table.unpack(self._enable_param))
      else
        self._normal = self:add_texture("core\\black_icon.tga", 0, 0, self.w, self.h)
      end
      self._normal:set_alpha(0.7)
    end
  end,
  set_message_stop = function(self, is_stop)
    self.message_stop = is_stop
  end,
  set_enable_drag = function(self, enable)
    self.is_drag = enable
  end,
  set_enable_move_event = function(self, enable)
    self.is_move_event = enable
  end,
  set_normal_image = function(self, image_path, flag)
    self.normal_image = image_path
    if self._panel_type == nil then
      self._panel:set_normal_image(image_path, flag)
    end
  end,
  set_hover_image = function(self, image_path)
    self.hover_image = image_path
    if image_path == "" then
      image_path = "Transparent.tga"
    end
    if self.is_enter and self._panel_type == nil then
      self._panel:set_normal_image(image_path)
    end
  end,
  set_active_image = function(self, image_path)
    self.active_image = image_path
    if image_path == "" then
      image_path = "Transparent.tga"
    end
    if self.is_enter and self._panel_type == nil then
      self._panel:set_normal_image(image_path)
    end
  end,
  set_control_size = function(self, width, height)
    class.ui_base.set_control_size(self, width, height)
    if self._panel then
      self._panel:set_control_size(width, height)
    end
  end,
  set_position = function(self, x, y)
    class.ui_base.set_position(self, x, y)
    self._panel:set_position(x, y)
  end,
  set_alpha = function(self, alpha)
    self.alpha = alpha
    self._panel:set_alpha(alpha)
  end,
  set_level = function(self, level)
    class.panel.set_level(self, level)
    self._panel:set_level(level)
  end,
  __tostring = function(self)
    local str = string.format("按钮 %d", self._id or 0)
    return str
  end
})
