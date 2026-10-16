-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
require("gameplay.permission.click_id")
local PermissionConfig = require("gameplay.permission.permission_config")
local M = {}

local function getPermissionSkill(str)
  local qxid = "权限-" .. str
  return QXM[qxid] or GetVarID_Name(qxid, true)
end

function M.move(args)
  local str = args.str
  local u = args.u
  local sy = args.sy
  local function trace(phase)
    require("hera_boot").note("PERMISSION STEP p=" .. sy .. " id=" .. str .. " " .. phase, true)
  end
  trace("resolve skill")
  local isnew = QXM["权限-" .. str] == nil
  local dskill = getPermissionSkill(str)
  for index = 1, #Mtashow[sy] do
    if Mtashow[sy][index] == dskill then
      return
    end
  end
  if isnew then
    trace("set title " .. dskill)
    u:setskilldatastring(dskill, "提示", args.name)
    trace("set icon " .. tostring(args.icon))
    u:setskilldatastring(dskill, "图标", args.icon)
    trace("icon complete")
  end
  local count = #Mtashow[sy]
  Mtashow[sy][count + 1] = dskill
  local ewl = getunit(QXL[sy])
  trace("add ability " .. dskill)
  ewl:addskill(dskill)
  trace("ability complete")
  if not ModeSelect_Difficult then
    u:setdata("判定-" .. str)
    local effecttext = "|cFF9999FF当前状态:[开启]|r"
    trace("set state tooltip")
    u:setskilldatastring(dskill, "提示拓展", effecttext)
    trace("state tooltip complete")
    for _, value in ipairs(PermissionConfig) do
      if str == value.id and value.etfunc then
        trace("enable callback")
        value.etfunc(u, sy)
        trace("callback complete")
      end
    end
  else
    local effecttext = "|cFF9999FF当前状态:[关闭]|r"
    trace("set state tooltip")
    u:setskilldatastring(dskill, "提示拓展", effecttext)
    trace("state tooltip complete")
  end
end

function M.addl(ewl, skill)
  local sy = ewl.ownerid
  local u = getunit(Hero[sy])
  for _, value in ipairs(PermissionConfig) do
    local qxskill = getPermissionSkill(value.id)
    if skill == S2ID(qxskill) then
      local str = value.id
      if not ModeSelect_Difficult then
        do
          local b = true
          if Stage > 1 then
            b = false
            u:sendmessage("|cFF9999FF失败-已经度过第一波|r")
          end
          if b then
            if u:hasdata("判定-" .. str) then
              u:deldata("判定-" .. str)
              u:sendmessage("|cFF9999FF成功关闭|r")
              if u:islocal() then
                local effecttext = "|cFF9999FF当前状态:[关闭]|r"
                u:setskilldatastring(skill, "提示拓展", effecttext)
              end
              if value.etendfunc then
                value.etendfunc(u, sy)
              end
              break
            end
            u:setdata("判定-" .. str)
            u:sendmessage("|cFF9999FF成功开启|r")
            if u:islocal() then
              local effecttext = "|cFF9999FF当前状态:[开启]|r"
              u:setskilldatastring(skill, "提示拓展", effecttext)
            end
            if value.etfunc then
              value.etfunc(u, sy)
            end
          end
        end
        break
      end
      u:sendmessage("|cFF9999FF混沌模式无法开启|r")
      break
    end
  end
end

return M
