-- 엔진 기본 툴팁의 앵커와 크기를 보존하고 커스텀 시계 설명만 갱신한다.
local util = require("gameplay.interface.ui.yuansheng.util")
local tooltip = {enabled = true}

function tooltip.set_enabled(enabled)
  tooltip.enabled = enabled == true
end

local clock_tooltip_visible = false
local last_clock_text

local function update_clock_tooltip(mouse_x, mouse_y)
  local hovering_clock = 866 <= mouse_x and mouse_x <= 993 and 5 <= mouse_y and mouse_y <= 86
  if not hovering_clock then
    if clock_tooltip_visible then
      clock_tooltip_visible = false
      last_clock_text = nil
      uiy_hide()
    end
    return
  end
  clock_tooltip_visible = true
  local time = GetTimeOfDay()
  local day_color = 6 <= time and time < 18 and "FFFFFF66" or "FF3366FF"
  local apocalypse = "|cFFFFFF66없음|r"
  if Morihuanjing_BaocunString ~= "" then
    apocalypse = require("hera_korean").translate(Morihuanjing_BaocunString)
  end
  local text = "|cFF7DBEF1게임 경과 시간:" .. util.format_time(Time_M, Time_S) .. "|r\n" .. "|c" .. day_color .. "현재 게임 시각:" .. util.format_day_time(time) .. "|r\n" .. "|cFF7DBEF1현재 종말 환경:|r" .. apocalypse
  if text ~= last_clock_text then
    last_clock_text = text
    uiy_show_text(text)
  end
end

local tooltip_timer = ac.loop(30, function()
  if not IsWindowActive() then
    return
  end
  local mouse_x, mouse_y = game.get_mouse_pos()
  update_clock_tooltip(mouse_x, mouse_y)
end)
tooltip.timer = tooltip_timer
return tooltip
