-- 헤라 UI의 자동 높이와 폭 변경을 지원하며 나머지 복원 동작을 유지한다.
require("jh.ui.base.controls.class")
require("jh.ui.base.controls.panel")
local korean = require("hera_korean")
local text_width = require("hera_text_width")
local FALLBACK_FONT = "Fonts\\gamefont.ttc"
local PRIORITY_FONT = "Fonts\\gamefont2.ttc"

local function file_exists(path)
  if not io or not io.open then
    return false
  end
  local ok, file = pcall(io.open, path, "rb")
  if not ok then
    return false
  end
  if file then
    file:close()
    return true
  end
  return false
end

local function get_default_font()
  if TEXT_FONT_PATH then
    return TEXT_FONT_PATH
  end
  TEXT_FONT_PATH = FALLBACK_FONT
  if file_exists(PRIORITY_FONT) then
    TEXT_FONT_PATH = PRIORITY_FONT
  end
  return TEXT_FONT_PATH
end

local DEFAULT_FONT = get_default_font()
local font = [[
    Frame "TEXT" "text%d" {
        LayerStyle "IGNORETRACKEVENTS",
        FrameFont "%s", %s, "",
    }
]]
local font_map = {}

local function load_font(font, size)
  if font_map[size] ~= nil then
    return
  end
  size = math.modf(size)
  font_map[size] = 1
  local data = string.format(font, size, DEFAULT_FONT, size / 1000)
  load_fdf(data)
end

class.text = extends(class.panel)({
  _type = "text",
  _base = "TEXT",
  text = "",
  align = 0,
  font_size = 16,
  normal_image = "",
  color = nil,
  text_map = {},
  align_map = {
    auto_newline = -1,
    auto_size = -2,
    auto_width = -3,
    auto_height = -4,
    topleft = 0,
    top = 1,
    topright = 2,
    left = 3,
    center = 4,
    right = 5,
    bottomleft = 6,
    bottom = 7,
    bottomright = 8
  },
  build = function(self)
    self.align = class.text.align_map[self.align or ""] or self.align or 0
    local panel = class.panel:builder({
      _type = self._panel_type,
      parent = self.parent,
      w = self.w,
      h = self.h
    })
    if panel == nil then
      print("文字背景创建失败")
      return
    end
    panel._control = self
    self._panel = panel
    if self.font_size == nil then
      self.font_size = 16
    end
    if type(self.font_size) == "boolean" then
      self._type = "old_text"
    else
      load_font(font, self.font_size)
      self._type = string.format("%s%s", self._type, self.font_size)
    end
    self._id = japi.CreateFrameByTagName(self._base, self._name, panel._id, self._type, math.max(0, self.align))
    if self._id == nil or self._id == 0 then
      panel:destroy()
      class.ui_base.destroy(self)
      print("创建文字失败")
      return
    end
    self.text_map[self._id] = self
    self:reset()
    return self
  end,
  reset = function(self)
    if rawget(self, "normal_image") then
      self._panel:set_normal_image(self.normal_image)
    end
    self:init()
    self:set_text(self.text)
    if self.color then
      self.color = "FFFFFFFF"
    end
    self:set_color(self.color)
  end,
  new = function(parent, text, x, y, width, height, font_size, align)
    local control = class.text:builder({
      parent = parent,
      text = text,
      x = x,
      y = y,
      w = width,
      h = height,
      font_size = font_size,
      align = align
    })
    return control
  end,
  destroy = function(self)
    if self._id == nil or self._id == 0 then
      return self._id
    end
    self._panel:destroy()
    self.text_map[self._id] = nil
    class.ui_base.destroy(self)
  end,
  show = function(self)
    self._panel:show()
    class.ui_base.show(self)
  end,
  hide = function(self)
    self._panel:hide()
    class.ui_base.hide(self)
  end,
  get_width = function(self)
    return text_width.pixels(self._hera_render_text or self.text or "", self._real_size or self.font_size, self.font_path or DEFAULT_FONT)
  end,
  get_height = function(self)
    if self.align < -1 then
      return text_width.height(self._hera_render_text or self.text or "", self._real_size or self.font_size, self.font_path or DEFAULT_FONT)
    end
    return japi.FrameGetHeight(self._id) / 0.6 * 1080
  end,
  set_text = function(self, text)
    self.text = text
    if not self.keep_original_text then text = korean.translate(text) end
    local translated = korean.has_hangul(text)
    if translated ~= (self._hera_korean == true) then
      if translated then self._hera_original_font = self.font_path or DEFAULT_FONT end
      self.font_path = translated and korean.font or (self._hera_original_font or self.font_path or DEFAULT_FONT)
      japi.FrameSetTextFont(self._id, self.font_path, (self._real_size or self.font_size) / 1000)
      self._hera_korean = translated
    end
    self._hera_render_text = text
    japi.FrameSetText(self._id, text)
    if self.align == -4 then
      -- 명시적 줄바꿈과 같은 줄 수로 글자 프레임과 배경 높이를 맞춘다.
      local width = self.w
      local wrap_width = math.max(0, width - self.font_size * 2)
      if wrap_width > 0 then
        self._hera_render_text = text_width.wrap(text, self._real_size or self.font_size, self.font_path or DEFAULT_FONT, wrap_width)
        japi.FrameSetText(self._id, self._hera_render_text)
      end
      japi.FrameSetSize(self._id, wrap_width / 1920 * 0.8, self:get_height() / 1080 * 0.6)
      local height = self:get_height() + self.y + 6 + (self.ext_h or 0)
      width = width + (self.ext_w or 0)
      if 0 < width and 0 < height then
        self:set_control_size(width, height)
        if self.parent then
          self.parent:set_control_size(width, height)
        end
      end
      return
    end
    if self.align < -1 then
      local measured_width = self:get_width()
      japi.FrameSetSize(self._id, measured_width / 1920 * 0.8, self:get_height() / 1080 * 0.6)
      local _id = self._panel._id
      local width = self:get_width() + self.x + 8
      local height = self:get_height() + self.y + 6
      if self.align == -3 then
        height = self.h
        if 0 < height then
          self:set_height(math.max(0, height - self.font_size * 2))
        end
      elseif self.align == -4 then
        width = self.w
        if 0 < width then
          self:set_width(width - self.font_size * 2)
        end
      end
      width = width + (self.ext_w or 0)
      height = height + (self.ext_h or 0)
      if 0 < width and 0 < height then
        self:set_control_size(width, height)
        if self.parent then
          self.parent:set_control_size(width, height)
        end
      end
    elseif self.normal_image ~= "core\\Transparent.tga" then
    end
  end,
  get_text = function(self)
    return japi.FrameGetText(self._id)
  end,
  set_spacing = function(self, spacing)
    japi.FrameSetTextFontSpacing(self._id, spacing)
  end,
  set_size = function(self, size, path)
    local real_size = size * self.font_size * (self.relative_size or 1) * (self.default_size or 1)
    path = path or self.font_path
    path = self._hera_korean and korean.font or path or DEFAULT_FONT
    if self._real_size == real_size and self.font_path == path then
      return
    end
    japi.FrameSetTextFont(self._id, path, real_size / 1000)
    self.size = size
    self._real_size = real_size
    self.font_path = path
    if self.align < -1 then self:set_text(self.text) end
  end,
  set_color = function(self, ...)
    local arg = {
      ...
    }
    local color
    if #arg == 1 then
      local param = arg[1]
      if type(param) == "table" then
        self.color = param
        color = 4278190080 + param.r * 65536 + param.g * 256 + param.b
        self._panel:set_alpha(param.a)
      elseif type(param) == "string" then
        color = tonumber("c" .. param, 16)
        local a = color >> 24 & 255
        local r = color >> 16 & 255
        local g = color >> 8 & 255
        local b = color & 255
        self._panel:set_alpha(a)
        self.color = {
          r = r,
          g = g,
          b = b,
          a = a / 255
        }
      else
        color = param
        local a = color << 32 >> 56
        local r = color << 40 >> 56
        local g = color << 48 >> 56
        local b = color << 56 >> 56
        self.color = {
          r = r,
          g = g,
          b = b,
          a = a / 255
        }
      end
    else
      local r, g, b, a = table.unpack(arg)
      self._panel:set_alpha(a)
      self.color = {
        r = r,
        g = g,
        b = b,
        a = a
      }
      color = 4278190080 + r * 65536 + g * 256 + b
    end
    japi.FrameSetTextColor(self._id, color)
  end,
  set_alpha = function(self, alpha)
    local r, g, b = 255, 255, 255
    local a = alpha
    if type(self.color) == "table" then
      r = self.color.r
      g = self.color.g
      b = self.color.b
    elseif type(self.color) == "string" then
      local color = tonumber("c" .. self.color, 16)
      a = color >> 24 & 255
      r = color >> 16 & 255
      g = color >> 8 & 255
      b = color & 255
    elseif self.color then
      local color = self.color
      r = color << 40 >> 56
      g = color << 48 >> 56
      b = color << 56 >> 56
    end
    if a < 2 then
      a = 0
    end
    self:set_color(r, g, b, a)
  end,
  set_width = function(self, width)
    if self.align == -4 then
      self.w = width
      self:set_text(self.text)
      return
    end
    class.panel.set_width(self, width)
    self._panel:set_width(width)
  end,
  set_height = function(self, height)
    class.panel.set_height(self, height)
    self._panel:set_height(height)
  end,
  set_control_size = function(self, width, height)
    self.w = width
    self.h = height
    if self.align == -1 then
      class.panel.set_control_size(self, width, height)
    end
    self._panel:set_control_size(width, height)
  end,
  set_position = function(self, x, y)
    class.ui_base.set_position(self, x, y)
    self._panel:set_position(x, y)
  end,
  set_normal_image = function(self, path, flag)
    self._panel:set_normal_image(path, flag)
  end,
  set_level = function(self, level)
    class.panel.set_level(self, level)
    self._panel:set_level(level)
  end,
  __tostring = function(self)
    local str = string.format("文本 %d", self._id or 0)
    return str
  end
})
