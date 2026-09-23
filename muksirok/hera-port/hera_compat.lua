-- RPG 모듈을 읽기 전에 기본 UI 이름을 JASS 연결 코드로 설치한다.
local M = {}
local installed

function M.install()
  if installed then return installed end
  local japi = require("jass.japi")
  local ui = require("hera_ui_bridge").bind()
  local names = {
    "GetGameUI", "FrameGetTooltip", "GetMouseFocus", "CreateFrameByTagName", "DestroyFrame", "FrameSetPoint",
    "FrameSetAbsolutePoint", "FrameSetSize", "FrameSetText", "FrameSetTexture",
    "FrameShow", "FrameSetEnable", "FrameSetScriptByCode", "LoadToc", "FrameGetHeight",
    "TriggerRegisterSyncData", "SyncData", "GetTriggerSyncData", "GetTriggerSyncPlayer",
    "FrameSetPriority", "FrameSetAlpha", "FrameGetAlpha", "FrameSetTextColor",
    "FrameHideInterface", "FrameEditBlackBorders", "FrameGetMinimap", "FrameGetUpperButtonBarButton", "FrameGetChatMessage", "FrameClearAllPoints", "SimpleFrameFindByName", "SimpleFontStringFindByName", "SimpleTextureFindByName", "FrameSetFont", "FrameGetCommandBarButton",
    "FrameSetModel", "FrameSetAnimate", "FrameSetAnimateOffset", "FrameSetModelSize", "FrameSetModelSpeed", "FrameSetModelScale", "FrameSetModelRotateX", "FrameSetModelRotateY", "FrameSetModelRotateZ", "FrameSetModelXY", "FrameSetModelColor", "FrameSetModelTexture"
  }
  -- YDWE japi의 일반 대입은 __newindex에서 무시되므로 Lua 테이블에 직접 넣는다.
  for _, name in ipairs(names) do
    rawset(japi, name, ui[name])
    rawset(japi, "Dz" .. name, ui[name])
  end
  -- 설치 JN의 JNFrameSetLevel도 1.28에서는 DzFrameSetPriority를 사용한다.
  rawset(japi, "FrameSetLevel", ui.FrameSetPriority)
  rawset(japi, "FrameSetTextFont", ui.FrameSetTextFont)
  rawset(japi, "SetUnitModel", ui.SetUnitModel)
  rawset(japi, "DzSetUnitModel", ui.SetUnitModel)
  rawset(japi, "GetTargetObject", ui.GetTargetObject)
  rawset(japi, "GetMouseVectorX", ui.GetMouseVectorX)
  rawset(japi, "GetMouseVectorY", ui.GetMouseVectorY)
  if type(japi.GetRealSelectUnit) ~= "function" then
    rawset(japi, "GetRealSelectUnit", function()
      local selection = require("jass.message").selection
      assert(type(selection) == "function", "HERA_SELECTION_UNAVAILABLE: jass.message.selection")
      return selection() or 0
    end)
  end
  installed = {ui=ui, names=names}
  M.installed = installed
  return installed
end

return M
