-- 계정 인증 없이 등록된 모든 재능 권한을 공통 순서로 해금한다.
local PermissionConfig = require("gameplay.permission.permission_config")
local PermissionDama = require("gameplay.permission.permission_dama")
local M = {}

function M.apply(u)
  local sy = u.ownerid
  for _, entry in ipairs(PermissionConfig) do
    require("hera_boot").note("PERMISSION p=" .. sy .. " BEGIN " .. entry.id, true)
    PermissionDama[entry.id](u, sy)
    require("hera_boot").note("PERMISSION p=" .. sy .. " END " .. entry.id, true)
  end
end

return M
