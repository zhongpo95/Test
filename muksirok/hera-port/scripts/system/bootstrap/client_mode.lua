-- 헤라의 창 열거 미지원 시 기본 분류를 유지하는 RPG 초기화 검사용 사본이다.
local console = require("jass.console")
local M = {}

function M.init(message)
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
  return {
    online = Client_online,
    replay = Client_ready,
    all_map = Client_AllMap,
    online_replay = Client_online_ready,
    windows = list
  }
end

return M
