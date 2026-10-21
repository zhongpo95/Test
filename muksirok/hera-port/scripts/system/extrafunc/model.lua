-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local japi = require("jass.japi")
local player = require("jh.ac.player")
local vestmodel = {}
for i = 1, 6 do
  vestmodel[i] = player[i]:createunit("hhhh", 0, 0)
  KillUnit(vestmodel[i].handle)
end

function GetEffectXY(effect)
  local x = japi.EXGetEffectX(effect)
  local y = japi.EXGetEffectY(effect)
  return x, y
end

function GetEffectHeight(effect)
  return japi.EXGetEffectZ(effect)
end

function SetEffectXY(effect, x, y)
  japi.EXSetEffectXY(effect, x, y)
end

function SetEffectHeight(effect, z)
  japi.EXSetEffectZ(effect, z)
end

function SetEffectAngle(effect, angle)
  japi.EXEffectMatRotateZ(effect, angle)
end

function SetEffectZ(effect, angle)
  japi.EXEffectMatRotateZ(effect, angle)
end

local deferred_effect_visuals = {}
local function defer_effect_visual(name)
  if not deferred_effect_visuals[name] then
    deferred_effect_visuals[name] = true
    require("hera_boot").note("DEFERRED effect appearance: " .. name .. "; keep original model appearance")
  end
end

function SetEffectColor(effect, r, g, b, a)
  if type(japi.EXSetEffectColor) == "function" then
    japi.EXSetEffectColor(effect, 4278190080 + 65536 * r + 256 * g + b)
  else
    defer_effect_visual("EXSetEffectColor")
  end
  if a ~= nil then
    SetEffectAlpha(effect, a)
  end
end

function SetEffectAlpha(effect, a)
  if type(japi.DzSetEffectVertexAlpha) == "function" then
    japi.DzSetEffectVertexAlpha(effect, a or 255)
  else
    defer_effect_visual("DzSetEffectVertexAlpha")
  end
end

function ModelReplace(args)
  local u = args.u
  local isforce = args.isforce or false
  local model = args.model
  local modelsize = args.modelsize or 1
  local modelname = args.modelname
  local modelicon = args.modelicon
  if model and (not u:hasdata("模型-变化") or isforce) then
    u:setdata("模型-变化", model)
    u:setdata("模型-大小", modelsize)
    japi.SetUnitModel(u.handle, u:getdata("模型-变化"))
    u:setsize(u:getdata("模型-大小"))
  end
  if modelname and (not u:hasdata("模型-名字") or isforce) then
    u:setdata("模型-名字", modelname)
    japi.SetUnitName(u.handle, u:getdata("模型-名字"))
  end
  if modelicon and (not u:hasdata("模型-大头像") or isforce) then
    u:setdata("模型-大头像", modelicon)
    u:setdata("单位-大头像", u:getdata("模型-大头像"))
  end
end

function ModelReSet(args)
  local u = args.u
  local model = args.model
  local isforce = args.isforce or false
  local modelsize = args.modelsize or 1
  local modelname = args.modelname
  local modelicon = args.modelicon
  if not isforce then
    if u:hasdata("主播皮套") then
      model = u:getdata("主播皮套")
    end
    if u:hasdata("模型-变化") then
      model = u:getdata("模型-变化")
    end
    if u:hasdata("模型-大小") then
      modelsize = u:getdata("模型-大小")
    end
    if u:hasdata("模型-名字") then
      modelname = u:getdata("模型-名字")
    end
    if u:hasdata("模型-大头像") then
      modelicon = u:getdata("模型-大头像")
    end
    if u:hasdata("恩奇都-变容中") then
      model = u:getdata("恩奇都-变容模型")
      modelsize = u:getdata("恩奇都-变容模型大小")
    end
  end
  if model then
    japi.SetUnitModel(u.handle, model)
    u:setsize(modelsize)
  end
  if modelname then
    japi.SetUnitName(u.handle, modelname)
  end
  if modelicon then
    u:setdata("单位-大头像", modelicon)
  end
end

function modelchange(args)
  local unit = args.unit
  local u = getunit(unit)
  local sy = u.ownerid
  local x, y = u:getxy()
  local sfun = args.sfunc or function(mj)
  end
  local efun = args.efunc or function(mj)
  end
  local model = args.model or ""
  local modelactspeed = args.modelactspeed or 1
  local modelact = args.modelact or 1
  local modelsize = args.modelsize or 1
  if u:hasdata("系统-模型变化中") or u:hasdata("变身状态") then
    return
  end
  u:setdata("系统-模型变化中")
  local mj = vestmodel[sy]
  KillUnit(mj.handle)
  local dt = 20
  local time = args.time * 1000 or 300
  japi.DzSetUnitModel(mj.handle, model)
  SetUnitScale(mj.handle, modelsize, modelsize, modelsize)
  ResetUnitAnimation(mj.handle)
  mj:animeact(modelact)
  mj:animespeed(modelactspeed)
  mj:setface(u:getface())
  u:setcolor(255, 255, 255, 0)
  mj:setcolor(255, 255, 255, 255)
  sfun(mj)
  ac.loop(dt, function(t)
    time = time - dt
    x, y = u:getxy()
    mj:setxy(x, y)
    mj:setface(u:getface())
    u:setcolor(255, 255, 255, 0)
    if time <= 0 then
      efun(mj)
      japi.DzSetUnitModel(mj.handle, "")
      mj:setcolor(255, 255, 255, 0)
      u:setcolor(255, 255, 255, 255)
      mj:setxy(0, 0)
      u:deldata("系统-模型变化中")
      t:remove()
    end
  end)
end
