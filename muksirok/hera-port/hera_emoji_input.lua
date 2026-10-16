-- JASS T키 콜백을 초기화된 이모티콘 UI에 전달한다.
local M = {}

function M.key_down()
  local bqb = package.loaded["gameplay.interface.ui.bqb"]
  if type(bqb) == "table" then
    bqb.key_down("jass")
  end
end

function M.key_up()
  local bqb = package.loaded["gameplay.interface.ui.bqb"]
  if type(bqb) == "table" then
    bqb.key_up("jass")
  end
end

return M
