-- 폰트 문자 폭 자료로 색상 코드와 줄바꿈을 처리하는 텍스트 폭 근사치를 계산한다.
local metrics = require("hera_font_metrics")
local fonts = {
  ["fonts\\nanumgothic-regular.ttf"]=require("hera_font_metrics_korean"),
  ["fonts\\gamefont.ttc"]=metrics,
  ["fzmwfont.ttf"]=require("hera_font_metrics_fzmw"),
  ["fontnm.ttf"]=require("hera_font_metrics_fontnm"),
  ["fontj.ttf"]=require("hera_font_metrics_fontj"),
  ["fontxs.ttf"]=require("hera_font_metrics_fontxs")
}
local M = {}

function M.advance(codepoint, font_metrics)
  local metrics = font_metrics or metrics
  local low, high = 1, #metrics.ranges
  while low <= high do
    local middle = (low + high) // 2
    local row = metrics.ranges[middle]
    if codepoint < row[1] then high = middle - 1
    elseif codepoint > row[2] then low = middle + 1
    else return row[3] end
  end
  return metrics.fallback
end

local function decode(text, i)
  local first = text:byte(i)
  if first < 128 then return first, i + 1 end
  local count = first >= 194 and first <= 223 and 2 or
    first >= 224 and first <= 239 and 3 or first >= 240 and first <= 244 and 4
  if not count or i + count - 1 > #text then return 65533, i + 1 end
  local cp = first % (2 ^ (7 - count))
  for offset = 1, count - 1 do
    local value = text:byte(i + offset)
    if value < 128 or value > 191 then return 65533, i + 1 end
    cp = cp * 64 + value - 128
  end
  if cp < ({[2]=128,[3]=2048,[4]=65536})[count] or cp > 1114111 or cp >= 55296 and cp <= 57343 then
    return 65533, i + 1
  end
  return cp, i + count
end

-- 손상된 바이트는 대체문자로 바꾸고 정상 문자와 색상 코드는 보존한다.
function M.sanitize_utf8(text)
  text = tostring(text or "")
  local out, start, i = nil, 1, 1
  while i <= #text do
    local cp, next_i = decode(text, i)
    if cp == 65533 and next_i == i + 1 then
      out = out or {}
      out[#out + 1] = text:sub(start, i - 1)
      out[#out + 1] = utf8.char(65533)
      start = next_i
    end
    i = next_i
  end
  if not out then return text end
  out[#out + 1] = text:sub(start)
  return table.concat(out)
end

function M.units(text, font_metrics)
  text = tostring(text or "")
  local current, maximum, i = 0, 0, 1
  while i <= #text do
    local mark = text:sub(i, i + 1):lower()
    if mark == "|c" and text:sub(i + 2, i + 9):match("^%x%x%x%x%x%x%x%x$") then
      i = i + 10
    elseif mark == "|r" then
      i = i + 2
    elseif mark == "|n" then
      maximum, current, i = math.max(maximum, current), 0, i + 2
    elseif mark == "||" then
      current, i = current + M.advance(124, font_metrics), i + 2
    else
      local cp
      cp, i = decode(text, i)
      if cp == 10 or cp == 13 then
        if cp == 13 and text:byte(i) == 10 then i = i + 1 end
        maximum, current = math.max(maximum, current), 0
      elseif cp == 9 then
        current = current + M.advance(32, font_metrics) * 4
      else
        current = current + M.advance(cp, font_metrics)
      end
    end
  end
  return math.max(maximum, current)
end

function M.pixels(text, font_size, font_path)
  local path = font_path:lower():gsub("/", "\\")
  local selected = assert(fonts[path], "HERA_TEXT_METRICS_FONT: " .. font_path)
  assert(type(font_size) == "number" and font_size >= 0, "HERA_TEXT_METRICS_SIZE")
  -- FDF 글자 높이의 세로 기준을 사용하는 근사치다. 실제 엔진 폭과의 일치는 미검증이다.
  return M.units(text, selected) / selected.units_per_em * font_size / 1000 / 0.6 * 1080
end

-- 색상 태그를 유지하고 UTF-8 문자를 분리하지 않는 줄바꿈이다.
function M.wrap(text, font_size, font_path, width)
  text = tostring(text or "")
  assert(width > 0, "HERA_TEXT_WRAP_WIDTH")
  local result, line, advances = {}, {}, {}
  local used, last_space, i = 0, nil, 1
  local function flush()
    result[#result + 1] = table.concat(line)
    line, advances, used, last_space = {}, {}, 0, nil
  end
  while i <= #text do
    local start, mark = i, text:sub(i, i + 1):lower()
    local token, advance, cp
    if mark == "|c" and text:sub(i + 2, i + 9):match("^%x%x%x%x%x%x%x%x$") then
      token, advance, i = text:sub(i, i + 9), 0, i + 10
    elseif mark == "|r" then
      token, advance, i = text:sub(i, i + 1), 0, i + 2
    elseif mark == "|n" then
      cp, i = 10, i + 2
    elseif mark == "||" then
      token, advance, i = "||", M.pixels("||", font_size, font_path), i + 2
    else
      cp, i = decode(text, i)
      if cp == 13 then
        if text:byte(i) == 10 then i = i + 1 end
        cp = 10
      end
      if cp ~= 10 then
        token = text:sub(start, i - 1)
        advance = M.pixels(token, font_size, font_path)
      end
    end
    if cp == 10 then
      flush()
    else
      if used > 0 and used + advance > width then
        if last_space then
          local tail, widths = {}, {}
          for index = last_space + 1, #line do
            tail[#tail + 1], widths[#widths + 1] = line[index], advances[index]
            line[index] = nil
          end
          flush()
          line, advances = tail, widths
          for _, value in ipairs(widths) do used = used + value end
        else
          flush()
        end
        if used > 0 and used + advance > width then flush() end
      end
      line[#line + 1], advances[#advances + 1] = token, advance
      used = used + advance
      if cp == 32 or cp == 9 then last_space = #line end
    end
  end
  flush()
  return table.concat(result, "\n")
end

function M.height(text, font_size, font_path)
  text = tostring(text or "")
  if text == "" then return 0 end
  -- 숨겨진 TEXT의 DzFrameGetHeight는 0일 수 있으므로 명시적 줄과 글자 높이로 계산한다.
  local lines = 1
  local normalized = text:gsub("\r\n", "\n"):gsub("\r", "\n")
  local i = 1
  while i <= #normalized do
    local mark = normalized:sub(i, i + 1):lower()
    if mark == "||" then i = i + 2
    elseif mark == "|n" then lines, i = lines + 1, i + 2
    elseif normalized:sub(i, i) == "\n" then lines, i = lines + 1, i + 1
    else i = i + 1 end
  end
  return math.ceil(lines * font_size / 1000 / 0.6 * 1080 * 1.2)
end

return M
