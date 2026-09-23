-- 복원 UI의 기본 함수 9개를 JN의 Dz 함수에 연결하며 원본 모듈은 변경하지 않는다.
local M = {}
local aliases = {
  GetGameUI = "DzGetGameUI",
  CreateFrameByTagName = "DzCreateFrameByTagName",
  DestroyFrame = "DzDestroyFrame",
  FrameSetPoint = "DzFrameSetPoint",
  FrameSetAbsolutePoint = "DzFrameSetAbsolutePoint",
  FrameSetSize = "DzFrameSetSize",
  FrameSetText = "DzFrameSetText",
  FrameSetTexture = "DzFrameSetTexture",
  FrameShow = "DzFrameShow"
}

function M.bind(japi)
  local bound, routes = {}, {}
  for original, alternative in pairs(aliases) do
    local ok, value = pcall(function() return japi[original] end)
    if ok and type(value) == "function" then
      bound[original], routes[original] = value, original
    else
      ok, value = pcall(function() return japi[alternative] end)
      if ok and type(value) == "function" then
        bound[original], routes[original] = value, alternative
      else
        routes[original] = "unavailable"
      end
    end
  end
  return bound, routes
end

return M
