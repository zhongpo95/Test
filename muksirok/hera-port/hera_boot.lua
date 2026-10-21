-- 복원 RPG의 저장 없는 초기화와 지연 실행 실패를 단계별로 기록한다.
local M = {}
local original_require = require
local lines, stack, seen_errors = {}, {}, {}
local status, failed_module, failure = "not started", "", ""
local saved, save_error, started = false, "", false
local loaded_count, runtime_errors = 0, 0
local runtime
local first_runtime_error
local report_path = "Logs/Hera_RPG_Boot_v160.txt"

local function save()
  local ok, result, reason = pcall(function()
    local file, err = io.open(report_path, "wb")
    if not file then return false, err end
    local wrote, write_err = file:write(table.concat(lines, "\n") ..
      "\nSTATUS = " .. status .. "\nFAILED MODULE = " .. failed_module ..
      "\nERROR = " .. failure .. "\n")
    local closed, close_err = file:close()
    return wrote ~= nil and closed ~= nil, write_err or close_err
  end)
  saved = ok and result == true
  save_error = saved and "" or tostring(ok and reason or result)
end

local function note(text, important)
  if important or #lines < 1600 then lines[#lines + 1] = tostring(text) end
  save()
end

M.note = note

local function runtime_error(err)
  local text = tostring(err)
  if seen_errors[text] then return end
  seen_errors[text] = true
  first_runtime_error = first_runtime_error or text:match("[^\r\n]+")
  runtime_errors = runtime_errors + 1
  if runtime_errors <= 20 then
    note("ASYNC ERROR " .. runtime_errors .. " = " .. text .. "\n" .. debug.traceback(), true)
  end
end

M.record_runtime_error = runtime_error

function M.summary()
  local first = failure:match("[^\r\n]+") or ""
  local sync = package.loaded["jh.ui.server.trigger"]
  local difficulty_input = package.loaded["hera_button_input"]
  local scene = package.loaded["hera_scene_diagnostic"]
  local gameplay = package.loaded["hera_gameplay_diagnostic"]
  local tooltip = package.loaded["hera_native_tooltip"]
  local compat = package.loaded["hera_compat"]
  local models = type(compat) == "table" and compat.installed and compat.installed.ui.model_stats
  local targets = type(compat) == "table" and compat.installed and compat.installed.ui.target_stats
  local sync_line = "not registered"
  if type(sync) == "table" and sync.registered then
    sync_line = "registered; sent=" .. tostring(sync.sent) .. "; received=" .. sync.received .. "; player=" .. sync.sender
  end
  return "Hera RPG initialization v160\nStatus = " .. status ..
    "\nLoaded modules = " .. loaded_count ..
    (failed_module ~= "" and "\nModule = " .. failed_module or "") ..
    (first ~= "" and "\n" .. first:sub(1, 220) or "") ..
    "\nStorage = disabled; text width = font-metric estimate" ..
    "\nAsync errors = " .. runtime_errors ..
    (first_runtime_error and "\nFirst error = " .. first_runtime_error:sub(1, 200) or "") ..
    (gameplay and "\n" .. gameplay.summary() or "") ..
    (tooltip and "\n" .. tooltip.summary() or "") ..
    "\nUI sync = " .. sync_line ..
    (models and "\nHUD models = " .. models.loaded .. "; DLL writes = " .. models.writes .. "; unused texture IDs = " .. models.unused_textures or "") ..
    (targets and "\nHover unit/item/empty = " .. targets.units .. "/" .. targets.items .. "/" .. targets.empty .. "; unit models = " .. targets.models or "") ..
    (type(difficulty_input) == "table" and "\n" .. difficulty_input.summary() or "") ..
    (type(scene) == "table" and "\n" .. scene.summary() or "") ..
    "\nReport = " .. (saved and report_path or "NOT SAVED: " .. save_error) ..
    "\nInitialization test; RPG play is not verified."
end

local function traced_require(name)
  if name == "w3rs_client_obf" then
    error("HERA_SERVER_BOUNDARY: initialization test stops before storage client startup", 0)
  end
  if package.loaded[name] then return original_require(name) end
  stack[#stack + 1] = name
  note("BEGIN " .. name)
  local ok, result = xpcall(function() return original_require(name) end, debug.traceback)
  if not ok then
    if failed_module == "" then failed_module, failure = name, tostring(result) end
    note("FAIL " .. name)
    stack[#stack] = nil
    error(result, 0)
  end
  loaded_count = loaded_count + 1
  note("PASS " .. name)
  stack[#stack] = nil
  if runtime then runtime.error_handle = runtime_error end
  return result
end

function M.run_stage(name, callback)
  if status == "BLOCKED" or status == "reached storage-client boundary" then return false end
  status = "initializing " .. name
  note("STAGE BEGIN " .. name)
  local ok, result = xpcall(callback, debug.traceback)
  if ok then
    status = "completed " .. name .. "; storage disabled"
    note("STAGE PASS " .. name)
  else
    status = "BLOCKED"
    if failed_module == "" then failed_module, failure = name, tostring(result) end
    note("STAGE FAIL " .. name .. " = " .. tostring(result))
  end
  if runtime then runtime.error_handle = runtime_error end
  save()
  return ok
end

function M.start()
  if started then return M.summary() end
  local identity_ok, slot = pcall(function()
    local common = original_require("jass.common")
    return common.GetPlayerId(common.GetLocalPlayer()) + 1
  end)
  if identity_ok and type(slot) == "number" then
    report_path = "Logs/Hera_RPG_Boot_v160_p" .. tostring(slot) .. ".txt"
  end
  started, status = true, "loading recovered RPG modules"
  note("CLIENT SLOT = " .. tostring(identity_ok and slot or "unavailable"))
  note("Hera RPG initialization v160 / " .. _VERSION)
  local ok, result = xpcall(function()
    runtime = original_require("jass.runtime")
    runtime.handle_level = 0
    runtime.sleep = false
    runtime.error_handle = runtime_error
    base = {error_handle=runtime_error}
    print = function(...)
      local values = {}
      for i = 1, select("#", ...) do values[i] = tostring(select(i, ...)) end
      note("PRINT " .. table.concat(values, " "))
    end
    require = traced_require
    require("path")
    package.path = package.path .. ";?/init.lua;scripts/?/init.lua;scripts/?.lua"
    require("hera_compat").install()
    local japi = original_require("jass.japi")
    note("WORLD HOVER uses installed Dz target handle; unit/item transitions require live verification")
    if type(japi.SetOwner) == "function" then
      japi.SetOwner("问号")
    else
      note("UNRESOLVED SetOwner; Chinese plugin entry is replaced for this initialization test")
    end
    local message = original_require("jass.message")
    if type(message.load_window_infos) ~= "function" then
      note("Window-title enumeration unavailable; source defaults retained; replay/stream title detection not verified")
    end
    require("hera_startup_trace").install()
    require("main")
    require("hera_gameplay_diagnostic").install()
  end, debug.traceback)
  if ok then
    status = "main returned; inspect asynchronous errors"
  elseif tostring(result):find("HERA_SERVER_BOUNDARY", 1, true) then
    status = "reached storage-client boundary"
    failure = tostring(result)
  else
    status = "BLOCKED"
    if failure == "" then failure = tostring(result) end
  end
  if runtime then runtime.error_handle = runtime_error end
  save()
  return M.summary()
end

return M
