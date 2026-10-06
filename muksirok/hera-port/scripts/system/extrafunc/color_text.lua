-- 채팅 연출은 문장 번역을 마친 다음 글자별 색상을 적용한다.
function ColorfulMsg(text, colorargs)
  local colors = {}
  
  local count = #colorargs
  local chars = {}
  for char, length in utf8Iter(text) do
    table.insert(chars, char)
  end
  for i, color in ipairs(colorargs) do
    if string.sub(color, 1, 4) ~= "|cFF" then
      color = "|cFF" .. color
    end
    colors[i] = color
  end
  local dtext = ""
  for index, value in ipairs(chars) do
    dtext = dtext .. colors[GetRandomInt(1, count)] .. value
  end
  return dtext
end

function SendColorfulMsgAll(text, ...)
  local translated = require("hera_korean").translate(text)
  local original = ColorfulMsg("『" .. text .. "』", {...})
  if translated == text then
    SendMsgAll(original)
    return
  end
  -- 기존 난수 호출 수는 유지하고 이미 뽑은 색상을 번역문에 순서대로 적용한다.
  local colors = {}
  for color in original:gmatch("|[cC]%x%x%x%x%x%x%x%x") do colors[#colors + 1] = color end
  local result, index = {}, 0
  for char in utf8Iter("『" .. translated .. "』") do
    index = index + 1
    result[#result + 1] = (colors[(index - 1) % math.max(1, #colors) + 1] or "|cFFFFFFFF") .. char
  end
  SendMsgAll(table.concat(result))
end

function extractTextAndColors(encodedText)
  local texts = {}
  local colors = {}
  local pattern = "|cFF(%x%x%x%x%x%x)(.-)|r"
  local lastEnd = 1
  for color, text in encodedText:gmatch(pattern) do
    table.insert(texts, text)
    table.insert(colors, color)
  end
  return texts, colors
end

function interpolateColor(color1, color2, fraction)
  local r1, g1, b1 = tonumber(color1:sub(1, 2), 16), tonumber(color1:sub(3, 4), 16), tonumber(color1:sub(5, 6), 16)
  local r2, g2, b2 = tonumber(color2:sub(1, 2), 16), tonumber(color2:sub(3, 4), 16), tonumber(color2:sub(5, 6), 16)
  local r = math.floor(r1 + (r2 - r1) * fraction + 0.5)
  local g = math.floor(g1 + (g2 - g1) * fraction + 0.5)
  local b = math.floor(b1 + (b2 - b1) * fraction + 0.5)
  return string.format("%02X%02X%02X", r, g, b)
end

function colorGradientTextShanguang(textArr, colors, flashIndex, flashWidth, flashcolor, minLength, mathmethod)
  local coloredText = ""
  local effectiveLength = math.max(#textArr, minLength)
  local actualFlashIndex = (flashIndex - 1) % effectiveLength + 1
  local halfFlashWidth = flashWidth / 2
  for i = 1, #textArr do
    local color
    local position = (i - actualFlashIndex + effectiveLength) % effectiveLength
    if flashWidth > position then
      local fraction
      if halfFlashWidth > position then
        fraction = position / halfFlashWidth
      else
        fraction = 1 - (position - halfFlashWidth) / halfFlashWidth
      end
      if mathmethod == 1 then
      end
      if mathmethod == 2 then
        if fraction < 0.5 then
          fraction = 4 * fraction * fraction * fraction
        else
          fraction = 1 - (-2 * fraction + 2) ^ 3 / 2
        end
      end
      color = interpolateColor(colors[math.min(i, #colors)], flashcolor, fraction)
    else
      color = colors[math.min(i, #colors)]
    end
    coloredText = coloredText .. "|cFF" .. color .. textArr[i] .. "|r"
  end
  return coloredText
end

function convertColorsToUpper(str)
  local result = string.gsub(str, "(cFF)(%x%x%x%x%x%x)", function(prefix, color)
    return prefix .. string.upper(color)
  end)
  return result
end

local function is_valid_utf8_char(char)
  local success = pcall(function()
    return utf8.codepoint(char)
  end)
  return success
end

function colorGradientTextBolang(text, colors, offset, minLength)
  local coloredText = ""
  local chars = {}
  text = convertColorsToUpper(text)
  for char in text:gmatch("([%z\001-\127�-�][�-�]*)") do
    table.insert(chars, char)
  end
  local actualLength = #chars
  local length = math.max(actualLength, minLength)
  local segmentSize = length / (#colors - 1)
  for i = 1, actualLength do
    local position = (i - 1 + offset) % length
    local segmentIndex = math.floor(position / segmentSize)
    local fraction = position % segmentSize / segmentSize
    if segmentIndex >= #colors then
      segmentIndex = #colors - 2
      fraction = 1
    end
    local color = interpolateColor(colors[segmentIndex + 1], colors[segmentIndex + 2], fraction)
    if is_valid_utf8_char(chars[i]) then
      coloredText = coloredText .. "|cFF" .. color .. chars[i] .. "|r"
    end
  end
  return coloredText
end

TP_ID = {}

function transition_phrases(args)
  local name = args.name
  local sy = args.sy
  if TP_ID[sy] then
    TP_ID[sy]:remove()
  end
  local restart_each_line = args.restart_each_line or false
  local subIndex = 1
  local index = 1
  local delay = args.delay or 100
  local pause_time = args.pause_time or 3000
  local isaddfuhao = args.isaddfuhao
  if isaddfuhao == nil then
    isaddfuhao = true
  end
  local is_paused = false
  local pause_counter = 0
  
  local function split_utf8(str)
    local chars = {}
    for char in str:gmatch("([%z\001-\127�-�][�-�]*)") do
      table.insert(chars, char)
    end
    return chars
  end
  
  local function join_chars(chars, start_i, end_i)
    local str = ""
    for i = start_i, end_i do
      if chars[i] then
        str = str .. chars[i]
      end
    end
    return str
  end
  
  local current = name[index]
  local next = name[index + 1] or name[1]
  local current_chars = split_utf8(current)
  local next_chars = split_utf8(next)
  
  local function set_show_text(str)
    if isaddfuhao then
      ColorName[sy][1].name = "『" .. str .. "』"
    else
      ColorName[sy][1].name = str
    end
  end
  
  local function loop_function()
    if is_paused then
      pause_counter = pause_counter - delay
      if pause_counter <= 0 then
        is_paused = false
        subIndex = 1
        index = index + 1
        if index > #name then
          index = 1
        end
        current = name[index]
        next = name[index + 1] or name[1]
        current_chars = split_utf8(current)
        next_chars = split_utf8(next)
      else
        return
      end
    end
    local str = ""
    if restart_each_line then
      str = join_chars(current_chars, 1, subIndex)
      if subIndex >= #current_chars then
        is_paused = true
        pause_counter = pause_time
      else
        subIndex = subIndex + 1
      end
    else
      local current_substring = join_chars(current_chars, subIndex + 1, #current_chars)
      local next_substring = join_chars(next_chars, 1, subIndex)
      str = current_substring .. next_substring
      if subIndex >= math.max(#current_chars, #next_chars) then
        is_paused = true
        pause_counter = pause_time
      else
        subIndex = subIndex + 1
      end
    end
    set_show_text(str)
  end
  
  TP_ID[sy] = ac.loop(delay, loop_function)
end

Boolean_UIYName = false
UIYName = {}
ac.loop(70, function()
  local newText
  for i = 1, 6 do
    if Boolean_ColorName[i] then
      local strcount = ShowNameCount[i] or 1
      local str = ""
      for j = 1, strcount do
        local flashmethod = ColorName[i][j].method or 1
        local name = ColorName[i][j].name
        local colors = ColorName[i][j].colors
        local flashWidth = ColorName[i][j].length or 10
        local minLength = ColorName[i][j].lengthcd or 30
        local mathmethod = ColorName[i][j].math or 1
        local offsetspeed = ColorName[i][j].offsetspeed or 1
        if flashmethod == 2 then
          ColorName_offset[i][j] = ColorName_offset[i][j] % minLength + offsetspeed
          local flashcolor
          if 1 < #colors then
            local d = minLength - 10
            if d <= 20 then
              d = 20
            end
            if ColorName_offset[i][j] == d then
              ColorName_index[i][j] = ColorName_index[i][j] % #colors + 1
            end
            flashcolor = colors[ColorName_index[i][j]]
          else
            flashcolor = colors[1]
          end
          local text, colors = extractTextAndColors(name)
          newText = colorGradientTextShanguang(text, colors, ColorName_offset[i][j], flashWidth, flashcolor, minLength, mathmethod)
        end
        if flashmethod == 1 then
          ColorName_offset[i][j] = (ColorName_offset[i][j] - offsetspeed) % minLength
          newText = colorGradientTextBolang(name, colors, ColorName_offset[i][j], minLength)
        end
        str = str .. newText
      end
      ShowName[i] = str
    end
  end
  if Boolean_UIYName then
    local strcount = UIYNameCount or 1
    local str = ""
    for j = 1, strcount do
      local flashmethod = UIYName[j].method or 1
      local name = UIYName[j].name
      local colors = UIYName[j].colors
      local flashWidth = UIYName[j].length or 10
      local minLength = UIYName[j].lengthcd or 30
      local mathmethod = UIYName[j].math or 1
      local offsetspeed = UIYName[j].offsetspeed or 1
      local offset = UIYName[j].offset or 0
      local index = UIYName[j].index or 0
      if flashmethod == 2 then
        UIYName[j].offset = offset % minLength + offsetspeed
        local flashcolor
        if 1 < #colors then
          if UIYName[j].offset == 20 then
            UIYName[j].index = index % #colors + 1
          end
          flashcolor = colors[UIYName[j].index]
        else
          flashcolor = colors[1]
        end
        local text, colors = extractTextAndColors(name)
        newText = colorGradientTextShanguang(text, colors, UIYName[j].offset, flashWidth, flashcolor, minLength, mathmethod)
      end
      if flashmethod == 1 then
        UIYName[j].offset = (offset - offsetspeed) % minLength
        newText = colorGradientTextBolang(name, colors, offset, minLength)
      end
      local starttext = UIYName[j].starttext or ""
      local extratext = UIYName[j].extratext or ""
      str = str .. starttext .. newText .. extratext
    end
    UIYNameShow = str
  end
end)
