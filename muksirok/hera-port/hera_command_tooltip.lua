-- 현재 명령 버튼의 실제 스킬과 레벨에 해당하는 원본 설명을 표시한다.
local M = {}
local message = require('jass.message')
local slk = require('jass.slk')
local shown, last_text, last_error
local reports = 0

local function value(data, field, level)
  local result = data and (data[field .. level] or data[field])
  local list_string = type(result) == 'string' and result ~= ''
  if type(result) == 'table' then result = result[level] or result[1] end
  if result == nil or result == '' then result = data and data[field .. level] end
  -- SLK 프로필의 레벨 목록은 문자열로도 오며 참조 토큰 안의 쉼표는 구분자가 아니다.
  if list_string and field ~= 'Ubertip' and (tonumber(data.levels or data.maxlevel) or 1) > 1 then
    local parts, start, reference = {}, 1, false
    for i = 1, #result do
      local c = result:sub(i, i)
      if c == '<' then reference = true
      elseif c == '>' then reference = false
      elseif c == ',' and not reference then
        parts[#parts + 1] = result:sub(start, i - 1)
        start = i + 1
      end
    end
    parts[#parts + 1] = result:sub(start)
    result = parts[math.min(level, #parts)]
  end
  return result
end

local function rawcode(id)
  if id == nil or id == 0 or id == '' then return nil end
  local code = id
  if type(id) ~= 'string' then
    local ok, result = pcall(ID2S, id)
    if not ok then return nil end
    code = result
  end
  if type(code) == 'string' and #code == 4 and code:match('^[%w_]+$') then return code end
end

local function research_at(unit, column, row)
  if not slk.unit or not slk.upgrade or type(GetUnitTypeId) ~= 'function' then return nil end
  local unit_code = rawcode(GetUnitTypeId(unit))
  local data = unit_code and slk.unit[unit_code]
  local researches = data and data.Researches
  if type(researches) == 'table' then researches = table.concat(researches, ',') end
  if type(researches) ~= 'string' then return nil end
  local match
  for code in researches:gmatch('[%w_]+') do
    local entry = slk.upgrade[code]
    if entry then
      local position = entry.Buttonpos
      local x, y
      if type(position) == 'table' then x, y = position[1], position[2]
      elseif type(position) == 'string' then x, y = position:match('(%d+),%s*(%d+)') end
      x, y = tonumber(x or entry.Buttonpos1) or 0, tonumber(y or entry.Buttonpos2) or 0
      if column == x and row == y then
        -- 같은 칸 후보가 여러 개면 현재 버튼 ID 없이 임의로 고르지 않는다.
        if match then return nil end
        match = code
      end
    end
  end
  return match
end

function M.describe(unit, column, row)
  if type(message.button) ~= 'function' then return nil end
  local ability, order = message.button(column, row)
  local code, order_code = rawcode(ability), rawcode(order)
  -- 판매 버튼은 스킬 ID 대신 주문 값에 상품 rawcode를 반환할 수 있다.
  local stock_code = (order_code and slk.item and slk.item[order_code] and order_code)
    or (code and slk.item and slk.item[code] and code)
    or (order_code and slk.unit and slk.unit[order_code] and order_code)
    or (code and slk.unit and slk.unit[code] and code)
  local data = stock_code and ((slk.item and slk.item[stock_code]) or (slk.unit and slk.unit[stock_code]))
  if stock_code then code = stock_code else data = code and slk.ability[code] end
  local research = not data
  if research then
    code = (code and slk.upgrade and slk.upgrade[code] and code)
      or (order_code and slk.upgrade and slk.upgrade[order_code] and order_code)
      or research_at(unit, column, row)
    data = code and slk.upgrade and slk.upgrade[code]
  end
  if not data then return nil end
  local level = 1
  if research then
    level = GetPlayerTechCount(GetOwningPlayer(unit), S2ID(code), true) + 1
    level = math.max(1, math.min(level, tonumber(data.maxlevel) or 1))
  elseif not stock_code then
    level = math.max(1, GetUnitAbilityLevel(unit, S2ID(code)))
  end
  local title = value(data, 'Tip', level) or data.Name
  local description = value(data, 'Ubertip', level)
  if not title and not description then return nil end
  local text = tostring(title or code)
  if description and description ~= '' then text = text .. '\n' .. tostring(description) end
  text = text:gsub('<([^,<>]+),([^,<>]+)>', function(object, field)
    local entry = slk.ability[object] or (slk.upgrade and slk.upgrade[object]) or (slk.item and slk.item[object]) or (slk.unit and slk.unit[object])
    local resolved = entry and entry[field]
    if type(resolved) == 'string' or type(resolved) == 'number' then return tostring(resolved) end
    return '<' .. object .. ',' .. field .. '>'
  end):gsub('|n', '\n')
  return text, code, order
end

function M.hide()
  if shown then uiy_hide() end
  shown, last_text = false, nil
end

function M.update(unit, column, row)
  if type(uiy_show_text) ~= 'function' then return false end
  local ok, text, code, order = pcall(M.describe, unit, column, row)
  if not ok then
    M.hide()
    if text ~= last_error then
      require('hera_boot').note('DEFERRED command tooltip: ' .. tostring(text))
      last_error = text
    end
    return false
  end
  if not text then M.hide(); return false end
  if text ~= last_text then
    uiy_show_text(text, 'NativeSkill')
    shown, last_text = true, text
    reports = reports + 1
    if reports <= 30 then
      require('hera_boot').note('COMMAND TOOLTIP code=' .. code .. '; order=' .. tostring(order) .. '; text=' .. text:sub(1,100))
    end
  end
  return true
end

return M
