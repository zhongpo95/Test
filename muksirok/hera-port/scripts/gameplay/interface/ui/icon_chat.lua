-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local japi = require("jass.japi")
local icon_chat = {}

function icon_chat.try_send(kind, name)
  if not (game.alt_click_enabled and japi.GetKeyState(KEY.ALT)) or japi.GetChatState() then
    return false
  end
  if not name or name == "" then
    return false
  end
  local text = kind .. "：【" .. name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|n", " "):gsub("[%z\r\n]", " ") .. "】"
  if 255 < #text then
    print("[图标喊话] 名称超过聊天通道的 255 字节限制。")
    return true
  end
  local sent, err = pcall(japi.DzSyncData, "ChatTool", text)
  if not sent then
    print("[图标喊话] 发送失败", err)
  end
  return true
end

local function send_native_icon()
  local frame = japi.DzGetMouseFocus()
  if frame == 0 then
    return false
  end
  for slot = 0, 5 do
    if frame == japi.DzFrameGetItemBarButton(slot) then
      local unit = japi.GetRealSelectUnit()
      if unit ~= 0 then
        local item = UnitItemInSlot(unit, slot)
        if item ~= 0 then
          icon_chat.try_send("物品", GetItemName(item))
        end
      end
      return true
    end
  end
  for row = 0, 2 do
    for column = 0, 3 do
      if frame == japi.DzFrameGetCommandBarButton(row, column) then
        local ability = japi.KKCommandButtonGetAbilityId(frame)
        if ability ~= 0 then
          icon_chat.try_send("技能", GetObjectName(ability))
        end
        return true
      end
    end
  end
  return false
end

function icon_chat.on_mouse_alt_click()
  if not game.alt_click_enabled then
    return false
  end
  local ok, consumed = pcall(send_native_icon)
  if not ok then
    print("[图标喊话] 读取图标失败", consumed)
    return true
  end
  return consumed
end

return icon_chat
