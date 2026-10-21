-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local japi = require("jass.japi")
local handle_ref = require("jh.base.handle_ref")
local slk = require("jass.slk")
HxPool = HxPool or {}
HxPool.x = HxPool.x or PX_X
HxPool.y = HxPool.y or PX_Y

local function get_source_model_and_scale(u)
  if not u then
    return nil, 1
  end
  local model
  local scale = 1
  if u:hasdata("主播皮套") then
    model = u:getdata("主播皮套")
  end
  if u:hasdata("模型-变化") then
    model = u:getdata("模型-变化")
  end
  if u:hasdata("模型-大小") then
    scale = u:getdata("模型-大小")
  end
  if u:hasdata("恩奇都-变容中") then
    model = u:getdata("恩奇都-变容模型")
    scale = u:getdata("恩奇都-变容模型大小")
  end
  if model then
    return model, tonumber(scale) or 1
  end
  local id = ID2S(u.type)
  if slk.unit[id] then
    return slk.unit[id].file, tonumber(slk.unit[id].modelScale) or 1
  end
  return nil, 1
end

local function get_model_and_scale(model_id)
  if not model_id or model_id == "" then
    return nil, 1
  end
  if slk.unit[model_id] then
    return slk.unit[model_id].file, tonumber(slk.unit[model_id].modelScale) or 1
  end
  local lower = string.lower(model_id)
  if lower:match("%.mdx$") or lower:match("%.mdl$") then
    return model_id, 1
  end
  if model_id:find("\\") or model_id:find("/") then
    return model_id .. ".mdx", 1
  end
  return nil, 1
end

local HxEffect = {}
HxEffect.__index = HxEffect

local function create_effect(model, x, y)
  local effect = AddSpecialEffect(model, x, y)
  handle_ref.ref(effect)
  return effect
end

local function set_effect_visible(effect, visible)
  if type(japi.EXSetEffectVisible) == "function" then
    japi.EXSetEffectVisible(effect, visible)
  end
end

local function set_effect_alpha(effect, alpha)
  if type(japi.DzSetEffectVertexAlpha) == "function" then
    japi.DzSetEffectVertexAlpha(effect, alpha)
  end
end

local function set_effect_model(effect, model)
  if type(japi.DzSetEffectModel) ~= "function" then return false end
  japi.DzSetEffectModel(effect, model)
  return true
end

local function make_argb(r, g, b, a)
  r = r or 255
  g = g or 255
  b = b or 255
  a = a or 255
  return a * 16777216 + r * 65536 + g * 256 + b
end

local function get_location_z(x, y)
  local loc = Location(x, y)
  local z = GetLocationZ(loc)
  RemoveLocation(loc)
  return z
end

local function effect_rotate_to(hx, axis, value)
  value = value or 0
  local key = "__hx_rot_" .. axis
  local old_value = hx[key] or 0
  local change = value - old_value
  if change == 0 then
    return
  end
  if axis == "x" then
    japi.EXEffectMatRotateX(hx.handle, change)
  elseif axis == "y" then
    japi.EXEffectMatRotateY(hx.handle, change)
  else
    japi.EXEffectMatRotateZ(hx.handle, change)
  end
  hx[key] = value
end

function HxEffect:setxy(x, y)
  x = x or HxPool.x
  y = y or HxPool.y
  japi.EXSetEffectXY(self.handle, x, y)
  self.__hx_x = x
  self.__hx_y = y
end

function HxEffect:setflyheight(height)
  height = height or 0
  japi.EXSetEffectZ(self.handle, height)
  self.__hx_height = height
end

function HxEffect:setface(face)
  effect_rotate_to(self, "z", face or 0)
end

function HxEffect:setrotate(x, y, z)
  if x ~= nil then
    effect_rotate_to(self, "x", x)
  end
  if y ~= nil then
    effect_rotate_to(self, "y", y)
  end
  if z ~= nil then
    effect_rotate_to(self, "z", z)
  end
end

function HxEffect:setsize(scale)
  scale = scale or 1
  if self.__hx_scale == scale then
    return
  end
  japi.EXSetEffectSize(self.handle, scale)
  self.__hx_scale = scale
end

function HxEffect:setmodel(model)
  if not model or self.__hx_model == model then
    return
  end
  print(model)
  -- 교체할 수 없을 때 기존 모델 정보를 유지하고 다음 처리를 계속한다.
  if not set_effect_model(self.handle, model) then return false end
  self.__hx_model = model
  self:reanimeact()
end

local deferred_hx_color = false
function HxEffect:setcolor(r, g, b, alpha)
  r = r or 255
  g = g or 255
  b = b or 255
  alpha = alpha or 255
  if type(japi.EXSetEffectColor) == "function" then
    japi.EXSetEffectColor(self.handle, make_argb(r, g, b, alpha))
  elseif not deferred_hx_color then
    deferred_hx_color = true
    require("hera_boot").note("DEFERRED illusion color: EXSetEffectColor; keep original appearance and continue cleanup")
  end
  set_effect_alpha(self.handle, alpha)
end

function HxEffect:animespeed(speed)
  speed = speed or 1
  japi.EXSetEffectSpeed(self.handle, speed)
  self.__hx_speed = speed
end

function HxEffect:animeact(act)
  if act == nil then
    return
  end
  if type(act) == "number" and type(japi.EXSetEffectAnimation) == "function" then
    japi.EXSetEffectAnimation(self.handle, act)
  elseif type(act) == "string" and type(japi.EXPlayEffectAnimation) == "function" then
    japi.EXPlayEffectAnimation(self.handle, act, "")
  end
  self.__hx_act = act
end

function HxEffect:reanimeact()
  if type(japi.EXSetEffectAnimation) == "function" then
    japi.EXSetEffectAnimation(self.handle, 0)
  end
  self.__hx_act = nil
end

function get_hx_unit(source, args)
  args = args or {}
  local model, scale
  if args.model then
    model = args.model
    scale = args.scale or 1
  end
  if args.model_id then
    model, scale = get_model_and_scale(args.model_id)
  end
  if args.use_source_model then
    model, scale = get_source_model_and_scale(source)
  end
  if args.scale then
    scale = args.scale
  end
  if not model then
    return nil
  end
  scale = scale or 1
  local hx = setmetatable({
    handle = create_effect(model, HxPool.x, HxPool.y),
    __hx_model = model,
    __hx_rot_x = 0,
    __hx_rot_y = 0,
    __hx_rot_z = 0
  }, HxEffect)
  hx.__hx_using = true
  hx.__hx_token = (hx.__hx_token or 0) + 1
  local token = hx.__hx_token
  local face = args.face
  if face == nil and source and source.getface then
    face = source:getface()
  end
  set_effect_visible(hx.handle, true)
  hx:setmodel(model)
  hx:animespeed(1)
  hx:setsize(scale)
  hx:setxy(args.x or HxPool.x, args.y or HxPool.y)
  hx:setrotate(args.xxz or 0, args.yxz or 0, face or args.zxz or 0)
  return hx, token
end

function clear_hx_unit(hx, token)
  if not hx or not hx.handle then
    return
  end
  if token and hx.__hx_token ~= token then
    return
  end
  hx.__hx_using = false
  hx:animespeed(1)
  hx:setcolor(255, 255, 255, 0)
  set_effect_visible(hx.handle, false)
  DestroyEffectLua(hx.handle)
  hx.handle = nil
end

function play_shadow_slow_series(u, args)
  args = args or {}
  local act = args.act or 4
  local count = args.count or 10
  local interval = args.interval or 0.03
  local main_speed = args.main_speed or 1
  local wait_time = args.wait_time or 0.05
  local model = args.model
  local model_id = args.model_id
  local scale = args.scale
  local offset_x = args.offset_x or -16
  local offset_y = args.offset_y or -16
  local rotate = args.rotate or args.extra_angle or args.face_offset or 0
  local z = args.z or args.height or args.height_offset or args.flyheight_offset or 0
  local no_freeze = args.no_freeze or args.not_freeze or args.keep_playing or false
  local fixed_x = args.x or args.shadow_x
  local fixed_y = args.y or args.shadow_y
  local has_fixed_position = fixed_x ~= nil or fixed_y ~= nil
  local stay_position = args.stay_position or args.fixed_position or args.stay or has_fixed_position
  local r = args.r or 255
  local g = args.g or 255
  local b = args.b or 255
  local hide_alpha = args.hide_alpha or 1
  local show_alpha = args.show_alpha or 155
  local noact = args.noact or false
  local fade_interval = args.fade_interval or 30
  local fade_sub = args.fade_sub or 20
  local fade_end_alpha = args.fade_end_alpha or 10
  if not noact then
    ResetUnitAnimation(u.handle)
    u:animespeed(10)
    ac.wait(wait_time * 1000, function()
      u:animeact(act)
      u:animespeed(main_speed)
    end)
  end
  
  local function create_shadow(show_time)
    local function get_shadow_height(x, y)
      return GetUnitFlyHeight(u.handle) + get_location_z(x, y) + z
    end
    
    local hx_args = {
      x = HxPool.x,
      y = HxPool.y,
      scale = scale
    }
    if model then
      hx_args.model = model
    elseif model_id then
      hx_args.model_id = model_id
    else
      hx_args.use_source_model = true
    end
    local bb, token = get_hx_unit(u, hx_args)
    if not bb then
      return
    end
    local x, y = u:getxy()
    local shadow_x = x + offset_x
    local shadow_y = y + offset_y
    if has_fixed_position then
      shadow_x = fixed_x or shadow_x
      shadow_y = fixed_y or shadow_y
    end
    if bb.__hx_token ~= token then
      return
    end
    bb:animeact(act)
    bb:animespeed(main_speed)
    ac.wait((wait_time + show_time) * 1000, function()
      if bb.__hx_token ~= token then
        return
      end
      local x2, y2 = u:getxy()
      local show_x = x2 + offset_x
      local show_y = y2 + offset_y
      if stay_position then
        show_x = shadow_x
        show_y = shadow_y
      end
      bb:setxy(show_x, show_y)
      bb:setflyheight(get_shadow_height(show_x, show_y))
      bb:setface(u:getface() + rotate)
      if not no_freeze then
        bb:animespeed(0)
      end
      bb:setcolor(r, g, b, show_alpha)
      local alpha = show_alpha
      ac.loop(fade_interval, function(timer)
        if bb.__hx_token ~= token then
          timer:remove()
          return
        end
        alpha = alpha - fade_sub
        if alpha <= fade_end_alpha then
          clear_hx_unit(bb, token)
          timer:remove()
        else
          bb:setcolor(r, g, b, alpha)
        end
      end)
    end)
  end
  
  for i = 1, count do
    local show_time = i * interval
    create_shadow(show_time)
  end
end
