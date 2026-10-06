-- 게임 핸들이나 타이머 없이 최근 진단을 네 개의 순환 파일에 즉시 저장한다.
local M = {}
function M.new(path, limit)
  local seq, count, part, generation = 0, 0, 0, 0
  local failed = false
  local function report_failure()
    pcall(function()
      local boot = package.loaded.hera_boot
      if boot and boot.note then boot.note("TRACE IO FAILED path=" .. path, true) end
    end)
  end
  limit = limit or 4096
  local function filename(n) return path:gsub('%.txt$', '_part' .. n .. '.txt') end
  local function save(text, mode, n)
    local f
    local ok = pcall(function()
      f = assert(io.open(filename(n), mode))
      assert(f:write(text))
      assert(f:close())
      f = nil
    end)
    if f then pcall(function() f:close() end) end
    return ok
  end
  for n = 0, 3 do
    if not save('v160 circular log; part=' .. n .. '; sequence is chronological; new session\n', 'wb', n) then failed = true end
  end
  if failed then report_failure() end
  local function write(text)
    if failed then return false end
    if count >= limit then
      part = (part + 1) % 4
      count = 0
      generation = generation + 1
    end
    seq = seq + 1
    local header = count == 0 and ('v160 generation=' .. generation .. ' first_sequence=' .. seq .. '\n') or ''
    local ok = save(header .. 'record=' .. seq .. ' ' .. tostring(text) .. '\n', count == 0 and 'wb' or 'ab', part)
    if not ok then failed = true; report_failure(); return false end
    count = count + 1
    return true
  end
  return {write=write}
end
return M
