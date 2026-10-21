-- 개인 설정은 이번 실행의 메모리에만 유지하고 파일을 읽거나 쓰지 않는다.
local M = {}
local CAMERA_HEIGHT_MIN = 0
local CAMERA_HEIGHT_MAX = 5050
local ENABLE_BGM_CONFIG = false

local function parse_ini(content)
  local config = {}
  local section
  for line in content:gmatch("[^\r\n]+") do
    local key, value
    line = line:match("^(.-)%s-;") or line
    line = line:match("^%s*(.-)%s*$")
    local section_match = line:match("^%[([%w_]+)%]$")
    if section_match then
      section = section_match
      config[section] = {}
    else
      key, value = line:match("^([%w_]+)%s-=%s-(.+)$")
      if key and value and section then
        value = value:match("^%s*(.-)%s*$")
        config[section][key] = value
      end
    end
  end
  return config
end

local function read_bool(value, default)
  if value == nil then
    return default
  end
  return string.lower(value) ~= "false"
end

local function read_number(value, default, min_value, max_value)
  local number = tonumber(value) or default
  if max_value < number then
    number = max_value
  end
  if min_value > number then
    number = min_value
  end
  return number
end

local function apply_defaults()
  Backpack = "无"
  EnableCustomUI = true
  UITransparency = 1
  UIInstructions = true
  CamHeight = 0
  BGMEnabled = true
  BqbGroup = "1"
  ShowHeadName = true
  UIBagPickupToUI = true
  UIBagHeroPickupToUI = false
end

local function apply_config(config)
  local settings = config.UI_Settings
  if not settings then
    apply_defaults()
    return
  end
  EnableCustomUI = read_bool(settings.EnableCustomUI, true)
  UITransparency = read_number(settings.UITransparency, 1, 0, 1)
  UIInstructions = read_bool(settings.UIInstructions, true)
  Backpack = settings.Backpack or "无"
  CamHeight = read_number(settings.CamHeight, 0, CAMERA_HEIGHT_MIN, CAMERA_HEIGHT_MAX)
  BGMEnabled = ENABLE_BGM_CONFIG and read_bool(settings.BGMEnabled, true) or true
  BqbGroup = settings.BqbGroup or "1"
  ShowHeadName = read_bool(settings.ShowHeadName, true)
  UIBagPickupToUI = read_bool(settings.UIBagPickupToUI, true)
  UIBagHeroPickupToUI = read_bool(settings.UIBagHeroPickupToUI, false)
end

function M.load()
  return {}
end

function M.save()
  if Client_ready then
    return PlayerConfig
  end
  local savestr = [[
[UI_Settings]
    EnableCustomUI = ]] .. tostring(EnableCustomUI) .. "  ; 是否启用自定义UI (true/false)\n    UITransparency = " .. tostring(UITransparency) .. "  ; 下方UI透明度 (0.0(完全透明) - 1.0(完全不透明))\n    UIInstructions = " .. tostring(UIInstructions) .. "  ; 技能/物品说明是否固定位置 (true/false)\n    Backpack = " .. tostring(Backpack) .. "  ; 背包皮肤\n    CamHeight = " .. tostring(CamHeight) .. "  ; 镜头高度(0~5050)\n    BGMEnabled = " .. tostring(BGMEnabled) .. "  ; 是否开启背景音乐 (true/false)\n    BqbGroup = " .. tostring(BqbGroup or "1") .. "  ; 表情包组\n    ShowHeadName = " .. tostring(ShowHeadName) .. "  ; 是否显示头顶名字 (true/false)\n    UIBagPickupToUI = " .. tostring(UIBagPickupToUI) .. "  ; -bb 背包单位捡起物品是否进入UI背包 (true/false)\n    UIBagHeroPickupToUI = " .. tostring(UIBagHeroPickupToUI) .. "  ; -bb2 英雄拾取消耗品是否进入UI背包 (true/false)"
  PlayerConfig = parse_ini(savestr)
  return PlayerConfig
end

function M.init()
  PlayerConfig = M.load()
  apply_config(PlayerConfig)
  if Client_ready then
    EnableCustomUI = false
  else
    M.save()
  end
  return PlayerConfig
end

function M.set_camera_height(sy, height, time, is_save, max_height)
  local player_table = jh and jh.player
  if not (sy and Cam_height and player_table) or not player_table[sy] then
    return false
  end
  max_height = max_height or CAMERA_HEIGHT_MAX
  height = read_number(height, 0, CAMERA_HEIGHT_MIN, max_height)
  Cam_height[sy] = height
  if sy == LocalPlayerID then
    CamHeight = height
  end
  player_table[sy]:setcameraheight(Cam_height[sy], time or 0)
  if is_save and sy == LocalPlayerID then
    M.save()
  end
  return height
end

function M.apply_camera_height(sy, time)
  sy = sy or LocalPlayerID
  return M.set_camera_height(sy, CamHeight, time, false)
end

function M.set_bgm_enabled(sy, enabled, is_save)
  if not sy or not BGMBoolean then
    return false
  end
  enabled = enabled == true
  BGMBoolean[sy] = enabled
  if sy == LocalPlayerID then
    if ENABLE_BGM_CONFIG then
      BGMEnabled = enabled
    end
    if not enabled and BGM_Start then
      StopSoundBJ(BGM_Start, false)
    end
    if BGM and BGMBoolean[LocalPlayerID] == true and not BGMIsChange then
      SetSoundVolumeBJ(BGM, 100.0)
    elseif BGM then
      SetSoundVolumeBJ(BGM, 0.0)
    end
    if NowBGM then
      for _, value in ipairs(NowBGM) do
        value:set_volume(enabled and 100 or 0)
      end
    end
    if is_save and ENABLE_BGM_CONFIG then
      M.save()
    end
  end
  return enabled
end

function M.apply_bgm_enabled(sy)
  if not ENABLE_BGM_CONFIG then
    return false
  end
  sy = sy or LocalPlayerID
  return M.set_bgm_enabled(sy, BGMEnabled, false)
end

function M.save_camera_height(sy)
  if not (sy == LocalPlayerID and Cam_height) or Cam_height[sy] == nil then
    return PlayerConfig
  end
  CamHeight = read_number(Cam_height[sy], 0, CAMERA_HEIGHT_MIN, CAMERA_HEIGHT_MAX)
  return M.save()
end

function M.set_ui_bag_pickup_to_ui(sy, enabled, is_save)
  enabled = enabled == true
  if sy == LocalPlayerID then
    UIBagPickupToUI = enabled
    if is_save then
      M.save()
    end
  end
  return enabled
end

function M.set_ui_bag_hero_pickup_to_ui(sy, enabled, is_save)
  enabled = enabled == true
  if sy == LocalPlayerID then
    UIBagHeroPickupToUI = enabled
    if is_save then
      M.save()
    end
  end
  return enabled
end

function playerconfigsave()
  return M.save()
end

function playerconfig_apply_camera_height(sy, time)
  return M.apply_camera_height(sy, time)
end

function playerconfig_set_camera_height(sy, height, time, is_save, max_height)
  return M.set_camera_height(sy, height, time, is_save, max_height)
end

function playerconfig_apply_bgm_enabled(sy)
  return M.apply_bgm_enabled(sy)
end

function playerconfig_set_bgm_enabled(sy, enabled, is_save)
  return M.set_bgm_enabled(sy, enabled, is_save)
end

function playerconfig_save_camera_height(sy)
  return M.save_camera_height(sy)
end

function playerconfig_set_ui_bag_pickup_to_ui(sy, enabled, is_save)
  return M.set_ui_bag_pickup_to_ui(sy, enabled, is_save)
end

function playerconfig_set_ui_bag_hero_pickup_to_ui(sy, enabled, is_save)
  return M.set_ui_bag_hero_pickup_to_ui(sy, enabled, is_save)
end

return M
