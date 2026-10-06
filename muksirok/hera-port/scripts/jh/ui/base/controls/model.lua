-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
require("jh.ui.base.controls.class")
require("jh.ui.base.controls.panel")
class.model = extends(class.panel)({
  model_map = {},
  model = "",
  color = 4294967295,
  texture_map = nil,
  size = 1,
  animation = 0,
  animation_loop = true,
  animation_index = 0,
  scale_x = 1,
  scale_y = 1,
  scale_z = 1,
  rotate_x = 0,
  rotate_y = 0,
  rotate_z = 0,
  team_color = 0,
  offset_x = 0,
  offset_y = 0,
  _type = "model",
  _base = "SPRITE",
  build = function(self)
    local panel
    if self.parent then
      self.parent_id = self.parent._id
    end
    self._id = japi.CreateFrameByTagName(self._base, self._name, self.parent_id, self._type, 0)
    if self._id == nil or self._id == 0 then
      class.ui_base.destroy(self)
      print("创建模型失败")
      return
    end
    self.model_map[self._id] = self
    self.texture_map = {}
    self:reset()
    return self
  end,
  reset = function(self)
    self:set_model(self.model)
    self:set_animation(self.animation, self.animation_loop)
    self:set_progress(1)
    self:set_size(self.size)
    self:init()
    self:set_scale(self.scale_x, self.scale_y, self.scale_z)
    self:set_rotate_x(self.rotate_x)
    self:set_rotate_y(self.rotate_y)
    self:set_rotate_z(self.rotate_z)
    self:set_model_offset(self.offset_x, self.offset_y)
    self:set_team_color(self.team_color)
    if rawget(self, "animation_index") then
      self:set_animation_by_index(self.animation_index)
    end
  end,
  new = function(parent, model_path, x, y, width, height)
    local control = class.model:builder({
      parent = parent,
      model = model_path,
      x = x,
      y = y,
      w = width,
      h = height
    })
    return control
  end,
  destroy = function(self)
    if self._id == nil or self._id == 0 then
      return
    end
    self.model_map[self._id] = nil
    class.ui_base.destroy(self)
  end,
  set_progress = function(self, rote)
    self.progress_value = rote
    japi.FrameSetAnimateOffset(self._id, rote)
  end,
  set_animation = function(self, index, bool)
    japi.FrameSetAnimate(self._id, index, bool == true)
  end,
  set_animation_by_index = function(self, index)
    if type(japi.FrameSetAnimationByIndex) == "function" then
      japi.FrameSetAnimationByIndex(self._id, index)
    else
      -- 기존 Dz 애니메이션 연결로 재생하고 후속 연출과 삭제 예약을 이어간다.
      self:set_animation(index, self.animation_loop)
    end
  end,
  set_model = function(self, path)
    self.model = path
    self.texture_map = {}
    japi.FrameSetModel(self._id, path, 0, 0)
  end,
  set_color = function(self, color)
    self.color = color
    japi.FrameSetModelColor(self._id, color)
  end,
  set_size = function(self, size)
    self.size = size
    local real_size = (self.relative_size or 1) * size
    japi.FrameSetModelSize(self._id, real_size)
  end,
  get_size = function(self)
    return japi.FrameGetModelSize(self._id)
  end,
  set_scale = function(self, x, y, z)
    self.scale_x = x
    self.scale_y = y
    self.scale_z = z
    local size = self.relative_size or 1
    x = size * x
    y = size * y
    z = size * z
    japi.FrameSetModelScale(self._id, x, y, z)
  end,
  set_rotate_x = function(self, value)
    japi.FrameSetModelRotateX(self._id, 0)
    japi.FrameSetModelRotateX(self._id, value)
    self.rotate_x = value
  end,
  set_rotate_y = function(self, value)
    japi.FrameSetModelRotateY(self._id, 0)
    japi.FrameSetModelRotateY(self._id, value)
    self.rotate_y = value
  end,
  set_rotate_z = function(self, value)
    japi.FrameSetModelRotateZ(self._id, 0)
    japi.FrameSetModelRotateZ(self._id, value)
    self.rotate_z = value
  end,
  get_speed = function(self)
    return japi.FrameGetModelSpeed(self._id)
  end,
  set_speed = function(self, value)
    japi.FrameSetModelSpeed(self._id, value)
  end,
  set_model_offset = function(self, x, y)
    self.offset_x = x
    self.offset_y = y
    x = x / 1920 * 0.8
    y = -y / 1080 * 0.6
    japi.FrameSetModelXY(self._id, x, y)
  end,
  get_model_offset = function(self)
    local x = japi.FrameGetModelX(self._id)
    local y = japi.FrameGetModelY(self._id)
    x = x / 0.8 * 1920
    y = y / 0.6 * 1080 * -1
    return x, y
  end,
  replace_id_texture = function(self, image_path, _id)
    if self.texture_map[_id] == image_path then
      return
    end
    self.texture_map[_id] = image_path
    if image_path == "" then
      image_path = "core\\Transparent.tga"
    end
    japi.FrameSetModelTexture(self._id, image_path, _id)
  end,
  _color_map = {
    ["红"] = 0,
    ["蓝"] = 1,
    ["青"] = 2,
    ["紫"] = 3,
    ["黄"] = 4,
    ["橙"] = 5,
    ["绿"] = 6,
    ["粉"] = 7,
    ["灰"] = 8,
    ["淡蓝"] = 9,
    ["暗绿"] = 10,
    ["棕"] = 11
  },
  set_team_color = function(self, color_id)
    local path1, path2 = "", ""
    if color_id or color_id ~= "" then
      if type(color_id) == "string" then
        color_id = self._color_map[color_id] or 0
      end
      self.team_color = color_id
      path1 = string.format("ReplaceableTextures\\TeamColor\\TeamColor%02d.blp", color_id)
      path2 = string.format("ReplaceableTextures\\TeamGlow\\TeamGlow%02d.blp", color_id)
    end
    self:replace_id_texture(path1, 1)
    self:replace_id_texture(path2, 2)
    self:replace_id_texture("ReplaceableTextures\\LordaeronTree\\LordaeronSummerTree.blp", 31)
  end,
  __tostring = function(self)
    local str = string.format("模型 %d", self._id or 0)
    return str
  end
})
