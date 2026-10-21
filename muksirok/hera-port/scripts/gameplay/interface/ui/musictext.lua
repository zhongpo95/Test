-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local function hexToARGB(hex)
  local a = tonumber("0x" .. hex:sub(1, 2)) / 255
  
  local r = tonumber("0x" .. hex:sub(3, 4)) / 255
  local g = tonumber("0x" .. hex:sub(5, 6)) / 255
  local b = tonumber("0x" .. hex:sub(7, 8)) / 255
  return {
    r,
    g,
    b,
    a
  }
end

local function ARGBToHex(color)
  local a = math.floor(color[4] * 255 + 0.5)
  local r = math.floor(color[1] * 255 + 0.5)
  local g = math.floor(color[2] * 255 + 0.5)
  local b = math.floor(color[3] * 255 + 0.5)
  return string.format("%02X%02X%02X%02X", a, r, g, b)
end

local function interpolateColor(color1, color2, alpha)
  local r = color1[1] * (1 - alpha) + color2[1] * alpha
  local g = color1[2] * (1 - alpha) + color2[2] * alpha
  local b = color1[3] * (1 - alpha) + color2[3] * alpha
  local a = color1[4] * (1 - alpha) + color2[4] * alpha
  return {
    r,
    g,
    b,
    a
  }
end

local function interpolateColorPalette(colors, alpha)
  if type(colors) ~= "table" or #colors == 0 then
    return nil
  end
  if #colors == 1 then
    return hexToARGB(colors[1])
  end
  local position = math.max(0, math.min(1, alpha)) * (#colors - 1)
  local index = math.floor(position) + 1
  if index >= #colors then
    return hexToARGB(colors[#colors])
  end
  return interpolateColor(hexToARGB(colors[index]), hexToARGB(colors[index + 1]), position - index + 1)
end

local MusicnotUse = {}
local MusicnotUseYT = {}
local MusicnotUseYT10 = {}
local isOccupied = {}
local isOccupiedYT = {}
local isOccupiedYT10 = {}
local music_color_text_timers = {}

local function music_color_text_wait(timeout, on_timer)
  local timer
  timer = ac.wait(timeout, function(wait_timer)
    music_color_text_timers[wait_timer] = nil
    on_timer()
  end)
  music_color_text_timers[timer] = true
  return timer
end

local function music_color_text_loop(timeout, on_timer)
  local timer = ac.loop(timeout, on_timer)
  music_color_text_timers[timer] = true
  
  function timer.on_remove(removed_timer)
    music_color_text_timers[removed_timer] = nil
  end
  
  return timer
end

for i = 1, 20 do
  local buttonText = class.text:builder({
    parent = OriginPanel,
    _type = "musictext",
    x = 0,
    y = 0,
    align = "topleft",
    text = "",
    font_size = 10
  })
  table.insert(MusicnotUse, buttonText)
  isOccupied[i] = false
  buttonText:hide()
  buttonText:set_level(5)
end
for i = 1, 20 do
  local buttonText = class.text:builder({
    parent = OriginPanel,
    _type = "fontyt",
    x = 0,
    y = 0,
    align = "topleft",
    text = "",
    font_size = 7
  })
  table.insert(MusicnotUseYT, buttonText)
  isOccupiedYT[i] = false
  buttonText:hide()
  buttonText:set_level(5)
end
for i = 1, 20 do
  local buttonText = class.text:builder({
    parent = OriginPanel,
    _type = "fontyt",
    x = 0,
    y = 0,
    align = "topleft",
    text = "",
    font_size = 10
  })
  table.insert(MusicnotUseYT10, buttonText)
  isOccupiedYT10[i] = false
  buttonText:hide()
  buttonText:set_level(5)
end

local function music_text_jitter(seed)
  local value = math.sin(seed * 12.9898) * 43758.5453
  return (value - math.floor(value)) * 2 - 1
end

local function is_sloped_music_text_mode(mode)
  return mode == "slope_shake" or mode == "slope_rise"
end

local function update_music_text_position(butext, base_x, base_y, options, pool_index, character_index, character_count, tick, rise_progress, fade_progress)
  if options.mode == "slope_shake" then
    local shake = options.shake or 4
    local seed = pool_index * 97 + tick * 31
    local offset_x = music_text_jitter(seed) * shake
    local offset_y = music_text_jitter(seed + 53) * shake
    local float_y = (options.float_y or 28) * (fade_progress or 0)
    butext:set_position(base_x + offset_x, base_y - float_y + offset_y)
    return
  end
  if options.mode ~= "slope_rise" then
    return
  end
  local progress = math.max(0, math.min(1, rise_progress or 1))
  local fade = math.max(0, math.min(1, fade_progress or 0))
  local rise_offset = (options.rise_y or 60) * (1 - progress) * (1 - progress)
  local spread_offset = (character_index - (character_count + 1) * 0.5) * (options.spread_x or 6) * fade
  local float_y = (options.float_y or 28) * fade
  butext:set_position(base_x + spread_offset, base_y + rise_offset - float_y)
end

local function count_music_text_characters(str)
  local count = 0
  for _ in utf8Iter(str) do
    count = count + 1
  end
  return count
end

local function random_music_text_range(ranges)
  if type(ranges) ~= "table" or #ranges == 0 then
    return nil
  end
  local range = ranges[GetRandomInt(1, #ranges)]
  if type(range) ~= "table" then
    return nil
  end
  local slope_min = range.min or range.lower or range[1]
  local slope_max = range.max or range.upper or range[2]
  if type(slope_min) ~= "number" or type(slope_max) ~= "number" then
    return nil
  end
  if slope_min > slope_max then
    slope_min, slope_max = slope_max, slope_min
  end
  return GetRandomReal(slope_min, slope_max)
end

local function resolve_music_text_offset(offset, default)
  if type(offset) == "number" then
    return offset
  end
  if type(offset) ~= "table" then
    return default
  end
  if type(offset.min) == "number" or type(offset.max) == "number" or type(offset.lower) == "number" or type(offset.upper) == "number" then
    return random_music_text_range({offset}) or default
  end
  if type(offset[1]) == "number" and type(offset[2]) == "number" then
    return GetRandomReal(math.min(offset[1], offset[2]), math.max(offset[1], offset[2]))
  end
  return random_music_text_range(offset) or default
end

local function music_text_side_sx(str, spacing, center, side, left_offset_x, right_offset_x)
  local character_count = count_music_text_characters(str)
  local start_x
  if side == "left" then
    start_x = left_offset_x
  else
    start_x = 1920 - right_offset_x - spacing * character_count
  end
  if center then
    return start_x + spacing * (character_count - 1) * 0.5
  end
  return start_x
end

local function music_text_center_x(str, spacing, center, sx)
  if center then
    return sx
  end
  return sx + spacing * (count_music_text_characters(str) - 1) * 0.5
end

local function func1(strz, colorStartHex, colorEndHex, showtexttime, showtime, staytime, fadetime, sx, sy, dx, fontj, options)
  options = options or {}
  local colorStart = hexToARGB(colorStartHex)
  local colorEnd = hexToARGB(colorEndHex)
  local enter_interval_ms = options.enter_interval_ms
  if type(enter_interval_ms) ~= "number" or enter_interval_ms <= 0 then
    enter_interval_ms = 70
  end
  local enter_interval = enter_interval_ms / 1000
  local length = math.max(2, math.floor(showtime / enter_interval + 0.5))
  local length2 = math.max(1, math.floor(staytime / enter_interval + 0.5))
  local fade_interval_ms = options.fade_interval_ms
  if type(fade_interval_ms) ~= "number" or fade_interval_ms <= 0 then
    fade_interval_ms = 70
  end
  local fade_interval = fade_interval_ms / 1000
  local cs = 0
  local zu = {}
  for char in utf8Iter(strz) do
    table.insert(zu, char)
  end
  local max = #zu
  if max == 0 then
    return
  end
  local cs2 = 0
  local dt = math.max(0.001, showtexttime / max)
  music_color_text_loop(dt * 1000, function(dtimer)
    if options.can_spawn and not options.can_spawn() then
      dtimer:remove()
      return
    end
    cs2 = cs2 + 1
    local dstr = zu[cs2]
    local index = 1
    local butext
    if fontj == "fontj" then
      while index <= #MusicnotUse and isOccupied[index] do
        index = index + 1
      end
      if index > #MusicnotUse then
        local buttonText = class.text:builder({
          parent = OriginPanel,
          _type = "musictext",
          x = 0,
          y = 0,
          align = "topleft",
          text = "",
          font_size = 10
        })
        table.insert(MusicnotUse, buttonText)
        isOccupied[index] = false
        buttonText:hide()
        buttonText:set_level(5)
      end
      isOccupied[index] = true
      butext = MusicnotUse[index]
    end
    if fontj == "fontyt" then
      while index <= #MusicnotUseYT and isOccupiedYT[index] do
        index = index + 1
      end
      if index > #MusicnotUseYT then
        local buttonText = class.text:builder({
          parent = OriginPanel,
          _type = "fontyt",
          x = 0,
          y = 0,
          align = "topleft",
          text = "",
          font_size = 7
        })
        table.insert(MusicnotUseYT, buttonText)
        isOccupiedYT[index] = false
        buttonText:hide()
        buttonText:set_level(5)
      end
      isOccupiedYT[index] = true
      butext = MusicnotUseYT[index]
    end
    if fontj == "fontyt10" then
      while index <= #MusicnotUseYT10 and isOccupiedYT10[index] do
        index = index + 1
      end
      if index > #MusicnotUseYT10 then
        local buttonText = class.text:builder({
          parent = OriginPanel,
          _type = "fontyt",
          x = 0,
          y = 0,
          align = "topleft",
          text = "",
          font_size = 10
        })
        table.insert(MusicnotUseYT10, buttonText)
        isOccupiedYT10[index] = false
        buttonText:hide()
        buttonText:set_level(5)
      end
      isOccupiedYT10[index] = true
      butext = MusicnotUseYT10[index]
    end
    cs = cs + 1
    butext:set_alpha(255)
    butext.keep_original_text = options.keep_original_text == true
    butext:set_text(dstr)
    local base_x, base_y
    if is_sloped_music_text_mode(options.mode) then
      local offset = cs - 1
      local start_x = sx
      if options.center then
        start_x = sx - dx * (max - 1) * 0.5
      end
      base_x = start_x + dx * offset
      base_y = sy + (options.slope or -0.45) * offset
    else
      base_x = sx + dx * cs
      base_y = sy
    end
    butext:set_position(base_x, base_y)
    local i = 0
    ac.loop(enter_interval_ms, function(timer)
      i = i + 1
      if i == 1 then
        butext:show()
      end
      if i <= length then
        local alpha = math.max(0.01, (i - 1) / (length - 1))
        local color = interpolateColorPalette(options.colors, alpha) or interpolateColor(colorStart, colorEnd, alpha)
        local hexColor = ARGBToHex(color)
        butext:set_color(hexColor)
      end
      local rise_progress = math.min(1, (i - 1) / (length - 1))
      update_music_text_position(butext, base_x, base_y, options, index, cs, max, i, rise_progress, 0)
      if i == length + length2 then
        local alpha2 = 255
        local fade_length = math.max(1, math.floor(fadetime / fade_interval + 0.5))
        local dalpha = 255 / fade_length
        local fade_index = 0
        ac.loop(fade_interval_ms, function(timer2)
          i = i + 1
          fade_index = fade_index + 1
          alpha2 = alpha2 - dalpha
          if is_sloped_music_text_mode(options.mode) then
            local fade_progress = math.min(1, fade_index / fade_length)
            update_music_text_position(butext, base_x, base_y, options, index, cs, max, i, 1, fade_progress)
          end
          butext:set_alpha(alpha2)
          if alpha2 <= 10 then
            butext:set_position(base_x, base_y)
            butext:set_text("")
            butext:hide()
            if fontj == "fontj" then
              isOccupied[index] = false
            end
            if fontj == "fontyt" then
              isOccupiedYT[index] = false
            end
            if fontj == "fontyt10" then
              isOccupiedYT10[index] = false
            end
            timer2:remove()
          end
        end)
        timer:remove()
      end
    end)
    if cs2 == max then
      dtimer:remove()
    end
  end)
end

function stopmusiccolortext()
  local timers = music_color_text_timers
  music_color_text_timers = {}
  for timer in pairs(timers) do
    timer:remove()
    timer.on_timer = nil
    timer.on_remove = nil
  end
end

function musiccolortext(args)
  local stop_previous_line = args.stop_previous_line
  if stop_previous_line == nil then
    stop_previous_line = true
  end
  local line_generation = 0
  for i, value in ipairs(args.strz) do
    local line_time = value.time or value.starttime or 0
    music_color_text_wait(line_time * 1000, function()
      line_generation = line_generation + 1
      local current_line_generation = line_generation
      
      local function can_spawn()
        if stop_previous_line and current_line_generation ~= line_generation then
          return false
        end
        return true
      end
      
      local mode = value.mode or args.mode
      local sloped = is_sloped_music_text_mode(mode)
      local showtexttime, showtime, staytime, fadetime
      if sloped then
        local next_value = args.strz[i + 1]
        local next_time = next_value and (next_value.time or next_value.starttime)
        local duration = value.duration or next_time and math.max(0.3, next_time - line_time) or args.default_duration or 5
        showtexttime = value.showtexttime or args.showtexttime or math.min(0.6, duration * 0.25)
        showtime = value.showtime or args.showtime or math.min(0.5, duration * 0.2)
        fadetime = value.fadetime or args.fadetime or math.min(0.7, duration * 0.25)
        local requested_staytime = value.staytime or args.staytime
        if next_time then
          local next_line_staytime = math.max(0.05, next_time - line_time - 1)
          staytime = requested_staytime and math.min(requested_staytime, next_line_staytime) or next_line_staytime
        else
          staytime = requested_staytime or math.max(0.05, duration - showtexttime - showtime - fadetime)
        end
      else
        showtexttime = value.showtexttime or 1
        showtime = value.showtime or 3
        staytime = value.staytime or 1
        fadetime = value.fadetime or 7
      end
      local sy = value.sy or args.sy or sloped and 680 or 100 * i
      sy = value.sy == nil and random_music_text_range(value.sy_ranges or args.sy_ranges) or sy
      local dx = value.str_spacing or value.dx or args.str_spacing or args.dx or sloped and 24 or 100
      local font = value.font or args.font or "fontj"
      local center = value.center
      if center == nil then
        center = args.center
      end
      if center == nil then
        center = sloped
      end
      local left_offset_value = value.left_offset_x
      if left_offset_value == nil then
        left_offset_value = args.left_offset_x
      end
      local right_offset_value = value.right_offset_x
      if right_offset_value == nil then
        right_offset_value = args.right_offset_x
      end
      local left_offset_x = left_offset_value
      local right_offset_x = right_offset_value
      local side
      if sloped and (left_offset_value ~= nil or right_offset_value ~= nil) then
        left_offset_x = resolve_music_text_offset(left_offset_value, 0)
        right_offset_x = resolve_music_text_offset(right_offset_value, 0)
        side = i % 2 == 1 and "left" or "right"
      end
      local sx = value.sx or args.sx or sloped and 960 or 50 + 25 * i
      if side then
        sx = music_text_side_sx(value.str, dx, center, side, left_offset_x, right_offset_x)
      end
      local line_colors = value.colors or value.color or args.colors or args.color
      local colorstart = value.colorstart or args.colorstart or type(line_colors) == "table" and line_colors[1] or "00FFFFFF"
      local colorend = value.colorend or args.colorend or type(line_colors) == "table" and line_colors[#line_colors] or "FFFFFFFF"
      local slope = value.slope
      if slope == nil then
        slope = random_music_text_range(value.slope_ranges or args.slope_ranges) or args.slope
      end
      local animation_options = {
        keep_original_text = args.keep_original_text == true,
        mode = mode,
        center = center,
        slope = slope,
        shake = value.str_shake or value.shake or args.str_shake or args.shake,
        float_y = value.float_y or args.float_y,
        rise_y = value.rise_y or args.rise_y,
        spread_x = value.spread_x or args.spread_x,
        enter_interval_ms = value.enter_interval_ms or args.enter_interval_ms,
        fade_interval_ms = value.fade_interval_ms or args.fade_interval_ms,
        can_spawn = can_spawn,
        colors = line_colors
      }
      func1(value.str, colorstart, colorend, showtexttime, showtime, staytime, fadetime, sx, sy, dx, font, animation_options)
      if sloped and value.translation and value.translation ~= "" then
        local translation_color = value.translation_colors or value.translation_color or args.translation_colors or args.translation_color
        local translation_colors, translation_end
        if type(translation_color) == "table" then
          translation_colors = translation_color
          translation_end = translation_color[#translation_color] or colorend
        else
          translation_end = translation_color or colorend
        end
        local translation_start = value.translation_colorstart or args.translation_colorstart or translation_colors and translation_colors[1]
        if not translation_start and type(translation_end) == "string" and #translation_end == 8 then
          translation_start = "00" .. translation_end:sub(3)
        end
        translation_start = translation_start or colorstart
        local str_slope = animation_options.slope or -0.45
        local translation_character_count = count_music_text_characters(value.translation)
        local translation_slope = str_slope * count_music_text_characters(value.str) / translation_character_count
        local translation_spacing = value.translation_spacing or value.translation_dx or args.translation_spacing or args.translation_dx or math.max(16, dx * 0.8)
        local translation_center = value.translation_center
        if translation_center == nil then
          translation_center = args.translation_center
        end
        local translation_sx = value.translation_sx or args.translation_sx or sx
        local translation_align_center = center
        if translation_center then
          translation_align_center = true
          translation_sx = music_text_center_x(value.str, dx, center, sx)
        elseif side then
          translation_sx = music_text_side_sx(value.translation, translation_spacing, translation_align_center, side, left_offset_x, right_offset_x)
        end
        local translation_options = {
          mode = mode,
          center = translation_align_center,
          slope = value.translation_slope or args.translation_slope or translation_slope,
          shake = value.translation_shake or args.translation_shake or animation_options.shake,
          float_y = value.translation_float_y or args.translation_float_y or animation_options.float_y,
          rise_y = value.translation_rise_y or args.translation_rise_y or animation_options.rise_y,
          spread_x = value.translation_spread_x or args.translation_spread_x or animation_options.spread_x,
          enter_interval_ms = animation_options.enter_interval_ms,
          fade_interval_ms = animation_options.fade_interval_ms,
          can_spawn = can_spawn,
          colors = translation_colors
        }
        func1(value.translation, translation_start, translation_end, showtexttime, showtime, staytime, fadetime, translation_sx, value.translation_sy or args.translation_sy or sy + (value.translation_offset_y or args.translation_offset_y or 42), translation_spacing, value.translation_font or args.translation_font or "fontyt", translation_options)
      end
    end)
  end
end

local ShigenotUse = {}
local isShigeOccupied = {}
for i = 1, 20 do
  local buttonText = class.text:builder({
    _type = "shigetext",
    x = 0,
    y = 0,
    align = "topleft",
    text = "",
    font_size = 20
  })
  table.insert(ShigenotUse, buttonText)
  isShigeOccupied[i] = false
  buttonText:hide()
end

local function func2(strz, colorStartHex, colorEndHex, showtime, staytime, fadetime, sx, sy, dx)
  local colorStart = hexToARGB(colorStartHex)
  local colorEnd = hexToARGB(colorEndHex)
  local length = math.floor(staytime / 0.07 + 0.5)
  local cs = 0
  local zu = {}
  for char in utf8Iter(strz) do
    table.insert(zu, char)
  end
  local max = #zu
  local cs2 = 0
  local dt = showtime / #zu
  ac.loop(dt * 1000, function(dtimer)
    cs2 = cs2 + 1
    local dstr = zu[cs2]
    local index = 1
    while index <= #ShigenotUse and isShigeOccupied[index] do
      index = index + 1
    end
    if index > #ShigenotUse then
      local buttonText = class.text:builder({
        _type = "shigetext",
        x = 0,
        y = 0,
        align = "topleft",
        text = "",
        font_size = 20
      })
      table.insert(ShigenotUse, buttonText)
      isShigeOccupied[index] = false
      buttonText:hide()
    end
    isShigeOccupied[index] = true
    local butext = ShigenotUse[index]
    cs = cs + 1
    butext:set_text(dstr)
    butext:set_position(sx, sy + dx * cs)
    local i = 0
    ac.loop(70, function(timer)
      i = i + 1
      local alpha = (i - 1) / (length - 1)
      local color = interpolateColor(colorStart, colorEnd, alpha)
      local hexColor = ARGBToHex(color)
      butext:set_color(hexColor)
      if i == 1 then
        butext:show()
      end
      if i == length then
        local alpha2 = 255
        local dalpha = 255 / math.floor(fadetime / 0.07 + 0.5)
        ac.loop(70, function(timer2)
          i = i + 1
          alpha2 = alpha2 - dalpha
          butext:set_alpha(alpha2)
          if alpha2 <= 10 then
            butext:set_text("")
            butext:hide()
            isShigeOccupied[index] = false
            timer2:remove()
          end
        end)
        timer:remove()
      end
    end)
    if cs2 == max then
      dtimer:remove()
    end
  end)
end

function shigecolortext(args)
  for i, value in ipairs(args.strz) do
    ac.wait(value.time * 1000, function()
      local showtime = value.showtime or 1
      local staytime = value.staytime or 3
      local fadetime = value.fadetime or 7
      local sx = value.sx or 1900 - 100 * i
      local sy = value.sy or 0
      local dx = value.dx or 40
      func2(value.str, args.colorstart, args.colorend, showtime, staytime, fadetime, sx, sy, dx)
    end)
  end
end
