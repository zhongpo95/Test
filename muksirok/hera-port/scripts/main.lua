-- 헤라에서 저장 클라이언트를 실행하지 않고 원래 게임 모듈 초기화를 진단한다.
local message = require("jass.message")
local japi = require("jass.japi")
local console = require("jass.console")
Glo = require("jass.globals")
require("jh.japi")
require("hera_scene_diagnostic").install()
require("system.war3.id")
local DebugConsole = require("system.bootstrap.debug_console")
local ModuleLoader = require("system.bootstrap.module_loader")
local NativeUI = require("system.bootstrap.native_ui")
local NeutralName = require("system.bootstrap.neutral_name")
local PlayerConfigBootstrap = require("system.bootstrap.player_config")
local QuestInfo = require("system.bootstrap.quest_info")
BOSS_TEST = 0
TEST_MODE = false
Client_online = true
Client_ready = false
Client_AllMap = false
Client_online_ready = false
local list = type(message.load_window_infos) == "function" and message.load_window_infos() or {}
for index, info in ipairs(list) do
  local title = info.title or ""
  if title:find("直播") then
    Client_online = false
    Client_online_ready = true
    console.enable = true
  elseif title:find("录像") then
    Client_online = false
    Client_ready = true
    console.enable = true
  end
end
if Client_ready then
  DebugConsole.enable()
end
PlayerConfigBootstrap.init()
if not Client_ready then
  local b = false
  DebugConsole.init(b)
  console.enable = b
end

local function main()
  GameVersion = "0.1.6b"
  if type(japi.DzDisableLoadingPressAKey) == "function" then
    japi.DzDisableLoadingPressAKey()
  end
  local boot = require("hera_boot")
  boot.note("STORAGE DISABLED: game initialization test; local all permissions unlocked; personal settings are session-only")
  if type(japi.UnLockFPS) == "function" then
    japi.UnLockFPS(true)
  else
    boot.note("OPTIONAL UnLockFPS unavailable; host FPS setting retained")
  end
  NativeUI.init()
  NeutralName.apply()
  require("system.sound")
  ac.wait(1, function()
    boot.run_stage("game modules", function()
      ModuleLoader.load_game_modules()
      require("hera_api_audit").run("game modules loaded")
      require("gameplay.permission.permission_store").on_ready()
      PlayerConfigBootstrap.apply_bgm_enabled(LocalPlayerID)
    end)
  end)
  ac.wait(2, function()
    if boot.run_stage("quest info", QuestInfo.create) then
      NativeUI.apply_upper_buttons()
      boot.run_stage("difficulty loader", function()
        require("gameplay.start.difficulty.loader")
      end)
    end
  end)
end

main()
