-- 조명·시야·안개·필터를 기록하고 수동 비교 뒤 최신 게임 설정으로 복귀한다.
local M = {installed=false, changes=0, lighting="not observed", lighting_calls=0}
local last = {}
local lighting_original, lighting_args
local terrain_args
local function note(text)
  local boot = package.loaded["hera_boot"]
  if boot and boot.note then boot.note(text) end
end
local function read(name, ...)
  local f = _G[name]
  if type(f) ~= "function" then return "unavailable" end
  local ok, value = pcall(f, ...)
  return ok and tostring(value) or "error"
end
function M.snapshot()
  note("SCENE SAMPLE time=" .. tostring(Time_M) .. ":" .. tostring(Time_S) ..
    " rest=" .. tostring(WaveStateText_Time) .. " calls=" .. M.lighting_calls ..
    " day=" .. read("GetTimeOfDay") .. " fog=" .. read("IsFogEnabled") ..
    " mask=" .. read("IsFogMaskEnabled") .. " farZ=" .. read("GetCameraField", CAMERA_FIELD_FARZ) ..
    " distance=" .. read("GetCameraField", CAMERA_FIELD_TARGET_DISTANCE) ..
    " cine=" .. read("IsCineFilterDisplayed") ..
    " angle=" .. read("GetCameraField", CAMERA_FIELD_ANGLE_OF_ATTACK) ..
    " z=" .. read("GetCameraField", CAMERA_FIELD_ZOFFSET))
  if type(GetCameraTargetPositionX) == "function" and type(GetCameraTargetPositionY) == "function" and type(GetLocalPlayer) == "function" then
    local ok, result = pcall(function()
      local x, y, player = GetCameraTargetPositionX(), GetCameraTargetPositionY(), GetLocalPlayer()
      return "SCENE VIEW x=" .. x .. " y=" .. y ..
        " visible=" .. read("IsVisibleToPlayer", x, y, player) ..
        " fogged=" .. read("IsFoggedToPlayer", x, y, player) ..
        " masked=" .. read("IsMaskedToPlayer", x, y, player)
    end)
    if ok then note(result) end
  end
end
function M.install()
  if M.installed then return end
  M.installed = true
  for _, name in ipairs({"SetDayNightModels", "SetTerrainFogEx", "ResetTerrainFog", "FogEnable", "FogMaskEnable",
      "DisplayCineFilter", "SetCineFilterTexture", "SetCineFilterStartColor", "SetCineFilterEndColor", "SetCineFilterDuration"}) do
    local original = _G[name]
    if type(original) == "function" then
      if name == "SetDayNightModels" then lighting_original = original end
      _G[name] = function(...)
        if name == "SetDayNightModels" then
          M.lighting_calls = M.lighting_calls + 1
          lighting_args = table.pack(...)
          local near_trigger = type(WaveStateText_Time) == "number" and WaveStateText_Time >= 156 and WaveStateText_Time <= 164
          if M.lighting_calls <= 140 and (M.lighting_calls % 20 == 1 or near_trigger) then M.snapshot() end
          if M.light_test then return end
        end
        if name == "SetTerrainFogEx" then terrain_args = table.pack(...) end
        if name == "ResetTerrainFog" then terrain_args = false end
        local values = {}
        for i = 1, select("#", ...) do values[i] = tostring(select(i, ...)) end
        local signature = table.concat(values, " | ")
        if last[name] ~= signature then
          last[name] = signature
          M.changes = M.changes + 1
          if name == "SetDayNightModels" then
            M.lighting = values[1] == "" and "empty terrain lighting" or "terrain lighting set"
            local storm = require("jass.storm")
            for i = 1, 2 do
              if values[i] and values[i] ~= "" then
                local ok, data = pcall(storm.load, values[i])
                note("SCENE ASSET " .. values[i] .. " = " .. (ok and type(data) == "string" and tostring(#data) .. " bytes" or "unavailable"))
              end
            end
          end
          if M.changes <= 60 then note("SCENE " .. name .. " " .. signature .. "\n" .. debug.traceback("", 2)) end
        end
        local test = M.scene_test
        if test then
          if test.phase == 1 and (name == "FogEnable" or name == "FogMaskEnable") then
            local bit = name == "FogEnable" and 1 or 2
            if select(1, ...) then test.visibility = test.visibility | bit else test.visibility = test.visibility & ~bit end
            return
          end
          if test.phase == 2 and (name == "SetTerrainFogEx" or name == "ResetTerrainFog") then return end
          if test.phase == 3 and name == "DisplayCineFilter" then test.cine = select(1, ...); return end
        end
        return original(...)
      end
    end
  end
end
function M.test_lighting()
  if M.scene_test then return "Scene comparison already running." end
  if M.light_test then return "Lighting comparison already running." end
  if not lighting_original or not lighting_args or not ac or type(ac.wait) ~= "function" then
    return "Select a hero before the lighting comparison."
  end
  M.snapshot()
  local ui = require("hera_ui_bridge").bind()
  ui.TestDayNightModels("Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdl",
    "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdl")
  M.light_test = true
  note("SCENE LIGHT TEST begin; JASS default models; original lighting calls held for 15 seconds")
  ac.wait(15000, function()
    M.light_test = false
    lighting_original(table.unpack(lighting_args, 1, lighting_args.n))
    note("SCENE LIGHT TEST restored latest original lighting request")
    M.snapshot()
  end)
  return "Lighting comparison active for 15 seconds. Watch the ground; original lighting restores automatically."
end

function M.test_scene()
  if M.light_test then return "Wait for the lighting comparison to finish." end
  if terrain_args == nil or not ac or type(ac.wait) ~= "function" then
    return "Start the game and select a hero before the scene comparison."
  end
  if M.scene_test then
    return M.scene_test.cancel()
  end
  local ui = require("hera_ui_bridge").bind()
  local test = {phase=0}
  local labels = {
    "A / 3 - VISION FOG OFF (10 sec)",
    "B / 3 - TERRAIN FOG RESET (10 sec)",
    "C / 3 - SCREEN FILTER OFF (10 sec)"
  }
  local function restore()
    if test.phase == 1 then
      ui.SceneVisibility(test.visibility)
    elseif test.phase == 2 then
      if terrain_args then ui.SceneTerrainFog(table.unpack(terrain_args, 1, terrain_args.n)) else ui.SceneTerrainFog() end
    elseif test.phase == 3 then
      ui.SceneCineFilter(test.cine)
    end
    test.phase = 0
  end
  local function finish(reason)
    local ok, err = pcall(restore)
    if not ok then
      note("SCENE TEST RESTORE ERROR " .. tostring(err))
      pcall(ui.SceneMessage, "Scene restore failed. Type -hera-scene to retry.")
      return "Scene restore failed; diagnostic state retained for retry."
    end
    M.scene_test = nil
    note("SCENE TEST " .. reason .. "; latest game settings restored")
    M.snapshot()
    pcall(ui.SceneMessage, "Scene test " .. reason .. " - ORIGINAL SETTINGS RESTORED")
    return "Scene comparison " .. reason .. "; original settings restored."
  end
  test.cancel = function() return finish("cancelled") end
  M.scene_test = test
  local function advance(phase)
    if M.scene_test ~= test then return end
    local ok, err = pcall(function()
      restore()
      if phase == 4 then finish("complete"); return end
      if phase == 1 then
        test.visibility = ui.SceneVisibility(-1)
        test.phase = 1
        ui.SceneVisibility(0)
      elseif phase == 2 then
        test.phase = 2
        ui.SceneTerrainFog()
      else
        test.cine = ui.SceneCineFilter() == 1
        test.phase = 3
        ui.SceneCineFilter(false)
      end
      note("SCENE TEST " .. labels[phase])
      M.snapshot()
      ui.SceneMessage(labels[phase] .. "\nNote the letter if the ground becomes visible. -hera-scene cancels.")
      ac.wait(10000, function() advance(phase + 1) end)
    end)
    if not ok then
      note("SCENE TEST ERROR " .. tostring(err))
      finish("aborted")
    end
  end
  note("SCENE TEST begin; each phase isolated; 30 seconds; no lighting/time/camera changes")
  M.snapshot()
  advance(1)
  if M.scene_test ~= test then return "Scene comparison did not start; check the SCENE TEST log." end
  return "Scene comparison A / B / C started. Each phase lasts 10 seconds."
end
function M.summary()
  local flags = "dark=" .. tostring(ModeSelect_DarkNight) .. "/" .. tostring(Boolean_Wuxinganye) ..
    "; night=" .. tostring(TimeisNightB)
  if last.flags ~= flags then last.flags = flags; note("SCENE FLAGS " .. flags) end
  M.snapshot()
  return "Scene = " .. (M.scene_test and "comparison phase " .. M.scene_test.phase or M.light_test and "JASS lighting test" or M.lighting) .. "; " .. flags
end
return M
