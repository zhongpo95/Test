-- 기본 UI 요청과 클릭·진입·이탈·버튼 놓기 이벤트를 JASS 경로로 연결한다.
local M = {}
local callbacks = {}
local trace = require("hera_ui_trace")

function M.dispatch_event(frame, event, player)
  local callback = callbacks[frame] and callbacks[frame][event]
  if not callback then return "" end
  local previous = trace.begin_event(frame, event, player)
  local ok, result = xpcall(function() return callback(frame, event, player) end, debug.traceback)
  trace.end_event(previous, ok, result)
  if not ok then
    local boot = package.loaded["hera_boot"]
    if type(boot) == "table" and boot.record_runtime_error then boot.record_runtime_error(result) end
    return "Lua UI callback ERROR: " .. tostring(result)
  end
  return type(result) == "string" and result or ""
end

function M.bind(common, globals)
  common = common or require("jass.common")
  globals = globals or require("jass.globals")
  assert(type(common.TriggerEvaluate) == "function", "JASS TriggerEvaluate unavailable")
  assert(globals.HeraUIBridgeEvaluator and globals.HeraUIBridgeEvaluator ~= 0, "Hera UI evaluator is not initialized")
  assert(globals.HeraUIBridgeOperation ~= nil, "hera_ui_bridge.j is not included")
  trace.install(common)
  local ui = {}
  local model_paths = {}
  local model_assets = require("hera_model_assets")
  ui.model_stats = {loaded=0, writes=0, unused_textures=0}
  ui.target_stats = {units=0, items=0, empty=0, models=0}
  local previous_target

  local function invoke(operation, arguments)
    assert(not globals.HeraUIBridgeBusy, "nested Hera UI bridge request")
    local ticket = trace.before(operation, arguments)
    globals.HeraUIBridgeBusy = true
    local ok, result = pcall(function()
      globals.HeraUIBridgeOperation = operation
      globals.HeraUIBridgeResult = 0
      globals.HeraUIBridgeRealResult = 0.0
      globals.HeraUIBridgeStringResult = ""
      globals.HeraUIBridgePlayerResult = 0
      globals.HeraUIBridgeTriggerA = 0
      globals.HeraUIBridgeUnitA = 0
      globals.HeraUIBridgeWidgetResult = 0
      globals.HeraUIBridgeCompleted = false
      globals.HeraUIBridgeIntA = 0
      globals.HeraUIBridgeIntB = 0
      globals.HeraUIBridgeIntC = 0
      globals.HeraUIBridgeIntD = 0
      globals.HeraUIBridgeRealA = 0.0
      globals.HeraUIBridgeRealB = 0.0
      globals.HeraUIBridgeRealC = 0.0
      globals.HeraUIBridgeRealD = 0.0
      globals.HeraUIBridgeRealE = 0.0
      globals.HeraUIBridgeRealF = 0.0
      globals.HeraUIBridgeBoolA = false
      for name, value in pairs(arguments) do globals["HeraUIBridge" .. name] = value end
      common.TriggerEvaluate(globals.HeraUIBridgeEvaluator)
      assert(globals.HeraUIBridgeCompleted, "Hera UI bridge did not complete operation " .. operation)
      if operation == 13 or operation == 42 or operation == 43 then return globals.HeraUIBridgeRealResult end
      if operation == 16 then return globals.HeraUIBridgeStringResult end
      if operation == 17 then return globals.HeraUIBridgePlayerResult end
      if operation == 41 then
        return {handle=globals.HeraUIBridgeWidgetResult or 0, kind=globals.HeraUIBridgeResult}
      end
      return globals.HeraUIBridgeResult
    end)
    globals.HeraUIBridgeStringA = ""
    globals.HeraUIBridgeStringB = ""
    globals.HeraUIBridgeStringC = ""
    globals.HeraUIBridgeStringResult = ""
    globals.HeraUIBridgePlayerResult = 0
    globals.HeraUIBridgeTriggerA = 0
    globals.HeraUIBridgeUnitA = 0
    globals.HeraUIBridgeWidgetResult = 0
    globals.HeraUIBridgeBusy = false
    trace.after(ticket, ok, result)
    if not ok then error(result, 2) end
    return result
  end

  function ui.FrameGetTooltip()
    return invoke(49, {})
  end
  function ui.GetMouseFocus()
    return invoke(50, {})
  end
  function ui.GetGameUI()
    return invoke(1, {})
  end
  function ui.GetMouseVectorX()
    return invoke(42, {})
  end
  function ui.GetMouseVectorY()
    return invoke(43, {})
  end
  function ui.TestDayNightModels(terrain, units)
    return invoke(44, {StringA=terrain, StringB=units})
  end
  function ui.SceneVisibility(flags)
    return invoke(45, {IntA=flags})
  end
  function ui.SceneTerrainFog(style, start_z, end_z, density, red, green, blue)
    return invoke(46, {BoolA=style == nil, IntA=style or 0,
      RealA=start_z or 0, RealB=end_z or 0, RealC=density or 0,
      RealD=red or 0, RealE=green or 0, RealF=blue or 0})
  end
  function ui.SceneCineFilter(visible)
    return invoke(47, {IntA=visible == nil and 0 or 1, BoolA=visible == true})
  end
  function ui.SceneMessage(text)
    return invoke(48, {StringA=text})
  end
  function ui.SetUnitModel(unit, path)
    invoke(40, {UnitA=unit, StringA=path})
    ui.target_stats.models = ui.target_stats.models + 1
  end
  function ui.GetTargetObject()
    local target = invoke(41, {})
    if target.handle ~= previous_target then
      local key = target.kind == 1 and "items" or target.kind == 2 and "units" or "empty"
      ui.target_stats[key] = ui.target_stats[key] + 1
      previous_target = target.handle
    end
    return target.handle
  end
  function ui.CreateFrameByTagName(kind, name, parent, template, context)
    return invoke(2, {StringA=kind, StringB=name, IntA=parent, StringC=template, IntB=context})
  end
  function ui.DestroyFrame(frame)
    invoke(3, {IntA=frame})
    callbacks[frame] = nil
    model_paths[frame] = nil
  end
  function ui.FrameSetPoint(frame, point, relative, relative_point, x, y)
    invoke(4, {IntA=frame, IntB=point, IntC=relative, IntD=relative_point, RealA=x, RealB=y})
  end
  function ui.FrameSetAbsolutePoint(frame, point, x, y)
    invoke(5, {IntA=frame, IntB=point, RealA=x, RealB=y})
  end
  function ui.FrameSetSize(frame, width, height)
    invoke(6, {IntA=frame, RealA=width, RealB=height})
  end
  function ui.FrameSetText(frame, text)
    invoke(7, {IntA=frame, StringA=text})
  end
  function ui.FrameSetTexture(frame, texture, flag)
    invoke(8, {IntA=frame, StringA=texture, IntB=flag})
  end
  function ui.FrameShow(frame, visible)
    invoke(9, {IntA=frame, BoolA=visible})
  end
  function ui.FrameSetScriptByCode(frame, event, callback, sync)
    assert(event == 1 or event == 2 or event == 3 or event == 4 or event == 5, "unsupported Hera UI event " .. tostring(event))
    assert(type(callback) == "function", "Hera UI callback must be a function")
    local entries = callbacks[frame] or {}
    local previous = entries[event]
    callbacks[frame] = entries
    entries[event] = callback
    local ok, err = pcall(invoke, 10, {IntA=frame, IntB=event, BoolA=sync == true})
    if not ok then entries[event] = previous; error(err, 2) end
  end
  function ui.FrameSetEnable(frame, enable)
    invoke(11, {IntA=frame, BoolA=enable})
  end
  function ui.LoadToc(path)
    invoke(12, {StringA=path})
  end
  function ui.FrameGetHeight(frame)
    return invoke(13, {IntA=frame})
  end
  function ui.TriggerRegisterSyncData(trigger, prefix, server)
    invoke(14, {TriggerA=trigger, StringA=prefix, BoolA=server == true})
  end
  function ui.SyncData(prefix, data)
    invoke(15, {StringA=prefix, StringB=tostring(data)})
  end
  function ui.GetTriggerSyncData()
    return invoke(16, {})
  end
  function ui.GetTriggerSyncPlayer()
    return invoke(17, {})
  end
  function ui.FrameSetPriority(frame, priority)
    invoke(18, {IntA=frame, IntB=priority})
  end
  function ui.FrameSetAlpha(frame, alpha)
    invoke(19, {IntA=frame, IntB=math.floor(math.max(0, math.min(255, alpha)))})
  end
  function ui.FrameGetAlpha(frame)
    return invoke(20, {IntA=frame})
  end
  function ui.FrameSetTextColor(frame, color)
    -- 복원 코드의 64비트 색상 값을 JASS의 부호 있는 32비트 색상으로 전달한다.
    color = color & 0xffffffff
    if color >= 0x80000000 then color = color - 0x100000000 end
    invoke(21, {IntA=frame, IntB=color})
  end
  function ui.FrameHideInterface()
    invoke(22, {})
  end
  function ui.FrameEditBlackBorders(upper, bottom)
    invoke(23, {RealA=upper, RealB=bottom})
  end
  function ui.FrameGetMinimap()
    return invoke(24, {})
  end
  function ui.FrameGetUpperButtonBarButton(button)
    return invoke(25, {IntA=button})
  end
  function ui.FrameGetChatMessage()
    return invoke(26, {})
  end
  function ui.FrameClearAllPoints(frame)
    invoke(27, {IntA=frame})
  end
  function ui.SimpleFrameFindByName(name, id)
    return invoke(28, {StringA=name, IntA=id})
  end
  function ui.SimpleFontStringFindByName(name, id)
    return invoke(29, {StringA=name, IntA=id})
  end
  function ui.SimpleTextureFindByName(name, id)
    return invoke(30, {StringA=name, IntA=id})
  end
  function ui.FrameSetFont(frame, path, height, flags)
    invoke(31, {IntA=frame, StringA=path, RealA=height, IntB=flags or 0})
  end
  function ui.FrameSetTextFont(frame, path, height)
    ui.FrameSetFont(frame, path, height, 0)
  end
  function ui.FrameGetCommandBarButton(row, column)
    return invoke(32, {IntA=row, IntB=column})
  end
  function ui.FrameSetModel(frame, path, model_type, flags)
    model_paths[frame] = nil
    invoke(33, {IntA=frame, StringA=path, IntB=model_type, IntC=flags})
    model_paths[frame] = path:gsub("/", "\\"):lower()
    ui.model_stats.loaded = ui.model_stats.loaded + 1
  end
  function ui.FrameSetAnimate(frame, animation, looping)
    invoke(34, {IntA=frame, IntB=animation, BoolA=looping == true})
  end
  function ui.FrameSetAnimateOffset(frame, offset)
    invoke(35, {IntA=frame, RealA=offset})
  end
  local function model_write(operation, arguments, name)
    assert(invoke(operation, arguments) == 1, "HERA_MODEL_NATIVE: " .. name .. " rejected frame " .. tostring(arguments.IntA))
    ui.model_stats.writes = ui.model_stats.writes + 1
  end
  function ui.FrameSetModelSize(frame, value)
    model_write(36, {IntA=frame, RealA=value}, "size")
  end
  function ui.FrameSetModelSpeed(frame, value)
    model_write(37, {IntA=frame, RealA=value}, "speed")
  end
  function ui.FrameSetModelScale(frame, x, y, z)
    model_write(38, {IntA=frame, IntB=2, RealA=x, RealB=y, RealC=z}, "scale")
  end
  function ui.FrameSetModelRotateX(frame, value)
    model_write(38, {IntA=frame, IntB=3, RealA=value}, "rotate X")
  end
  function ui.FrameSetModelRotateY(frame, value)
    model_write(38, {IntA=frame, IntB=4, RealA=value}, "rotate Y")
  end
  function ui.FrameSetModelRotateZ(frame, value)
    model_write(38, {IntA=frame, IntB=5, RealA=value}, "rotate Z")
  end
  function ui.FrameSetModelXY(frame, x, y)
    model_write(38, {IntA=frame, IntB=1, RealA=x, RealB=y}, "XY")
  end
  function ui.FrameSetModelColor(frame, color)
    color = color & 0xffffffff
    if color >= 0x80000000 then color = color - 0x100000000 end
    model_write(39, {IntA=frame, IntB=color}, "color")
  end
  function ui.FrameSetModelTexture(frame, path, replace_id)
    local model = model_paths[frame]
    local ids = model and model_assets[model]
    -- 포함한 MDX에서 사용하지 않는 팀색·나무 ID만 영향 없는 요청으로 처리한다.
    assert(ids and math.type(replace_id) == "integer" and replace_id > 0 and not ids[replace_id],
      "HERA_MODEL_TEXTURE_UNSUPPORTED: " .. tostring(model) .. " id=" .. tostring(replace_id) .. " path=" .. tostring(path))
    ui.model_stats.unused_textures = ui.model_stats.unused_textures + 1
  end
  return ui
end

return M
