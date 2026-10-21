-- 원래 커스텀 UI 배치를 유지하면서 헤라의 상단 기본 버튼 숨김을 보완한다.
local japi = require("jass.japi")
local M = {}

function M.apply_upper_buttons()
  if not EnableCustomUI then return end
  -- 엔진이 표시를 다시 켜도 퀘스트·동맹·채팅 버튼이 화면으로 돌아오지 않게 한다.
  for _, index in ipairs({0, 2, 3}) do
    local frame = japi.DzFrameGetUpperButtonBarButton(index)
    if frame ~= nil and frame ~= 0 then
      japi.FrameShow(frame, false)
      japi.FrameClearAllPoints(frame)
      japi.FrameSetAbsolutePoint(frame, 0, 2, 2)
    end
  end
  japi.FrameShow(japi.DzFrameGetUpperButtonBarButton(1), true)
  local ui = japi.DzFrameGetUpperButtonBarButton(1)
  japi.FrameClearAllPoints(ui)
  japi.FrameSetSize(ui, 0.057291666666666664, 0.017777777777777778)
  japi.FrameSetPoint(ui, 4, japi.GetGameUI(), 0, 0.7395833333333334, -0.011111111111111112)
end

function M.apply_custom_ui()
  if not EnableCustomUI then
    return
  end
  japi.FrameHideInterface()
  if UITransparency == 0 then
    japi.DzFrameEditBlackBorders(0, 0)
  else
    japi.DzFrameEditBlackBorders(0, 0.127)
  end
  M.apply_upper_buttons()
  local mapui = japi.FrameGetMinimap()
  japi.FrameShow(mapui, false)
  ac.wait(2, function()
    japi.FrameShow(mapui, true)
    japi.DzFrameClearAllPoints(mapui)
    japi.DzFrameSetAbsolutePoint(mapui, 4, 0.05, 0.05)
    japi.DzFrameSetSize(mapui, 0.1, 0.1)
  end)
  local ui = japi.DzSimpleFrameFindByName("SimpleHeroLevelBar", 0)
  japi.FrameClearAllPoints(ui)
  ui = japi.DzSimpleFrameFindByName("SimpleInfoPanelIconHero", 6)
  japi.FrameClearAllPoints(ui)
  ui = japi.DzSimpleFontStringFindByName("SimpleNameValue", 0)
  japi.FrameClearAllPoints(ui)
  ui = japi.DzSimpleTextureFindByName("InfoPanelIconBackdrop", 0)
  japi.FrameClearAllPoints(ui)
  ui = japi.DzSimpleTextureFindByName("InfoPanelIconBackdrop", 1)
  japi.FrameClearAllPoints(ui)
  ui = japi.DzSimpleTextureFindByName("InfoPanelIconBackdrop", 2)
  japi.FrameClearAllPoints(ui)
  ui = japi.DzSimpleFrameFindByName("SimpleInfoPanelUnitDetail", 0)
  japi.FrameClearAllPoints(ui)
  japi.FrameSetSize(ui, 0.057291666666666664, 0.017777777777777778)
  japi.FrameSetPoint(ui, 4, japi.GetGameUI(), 0, 0.39166666666666666, -0.5944444444444444)
end

function M.clear_chat_frame()
  japi.FrameClearAllPoints(japi.FrameGetChatMessage())
  japi.FrameSetAbsolutePoint(japi.FrameGetChatMessage(), 8, 1, 1)
end

function M.apply_camera_far_z()
  ac.wait(1000, function()
    for i = 0, 5 do
      SetCameraFieldForPlayer(Player(i), CAMERA_FIELD_FARZ, 999999, 0)
    end
  end)
end

function M.init()
  M.apply_custom_ui()
  M.clear_chat_frame()
  M.apply_camera_far_z()
end

return M
