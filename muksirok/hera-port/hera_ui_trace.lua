-- 로컬 UI 이벤트와 JASS 호출 전후를 슬롯별 파일에 기록하며 게임 객체를 생성하지 않는다.
local M = {}
local path, context
local sequence, calls, lines = 0, 0, 0
local counts = {}
local names = {[1]="click", [2]="enter", [3]="leave", [4]="up", [5]="down"}
local writer
local frame_labels = {}

local function short(value)
  return tostring(value):gsub("[\r\n]", " "):sub(1, 120)
end

local function frame_detail(frame)
  local detail = frame_labels[frame] or ""
  local button = class and class.button and class.button.button_map and class.button.button_map[frame]
  if button then
    detail = detail .. " name=" .. short(button._name) .. " key=" .. short(button.sync_key) ..
      " image=" .. short(button.normal_image) .. " parent=" .. tostring(button.parent and button.parent._id)
  end
  return detail
end
local function write(text)
  if not writer then return end
  pcall(function()
    local clock = ac and ac.clock and ac.clock() or -1
    writer.write(tostring(clock) .. " " .. text)
  end)
end
function M.install(common)
  if path then return end
  pcall(function()
    path = "Logs/Hera_RPG_UITrace_v160_p" .. tostring(common.GetPlayerId(common.GetLocalPlayer()) + 1) .. ".txt"
    writer = require("hera_trace_ring").new(path)
    write("BUILD v170 MP wall=" .. os.date("%Y-%m-%dT%H:%M:%S"))
  end)
end

function M.label_frame(frame, label)
  if frame and frame ~= 0 then frame_labels[frame] = short(label) end
end

function M.forget_frame(frame)
  frame_labels[frame] = nil
end

function M.item_hover(place, slot, item)
  write("ITEM HOVER wall=" .. os.date("%Y-%m-%dT%H:%M:%S") .. " place=" .. tostring(place) .. " slot=" .. tostring(slot) .. " handle=" .. tostring(item))
  local ok, typeid = pcall(GetItemTypeId, item)
  local named, name = pcall(function()
    local data = ok and slk and slk.item and slk.item[typeid]
    return data and data.Name
  end)
  write("ITEM TYPE place=" .. tostring(place) .. " handle=" .. tostring(item) ..
    " type=" .. tostring(ok and typeid or "error") .. " name=" .. short(named and name))
  local got, item_name = pcall(GetItemName, item)
  write("ITEM ENGINE NAME place=" .. tostring(place) .. " handle=" .. tostring(item) ..
    " type=" .. tostring(ok and typeid or "error") .. " name=" .. short(got and item_name))
end

function M.target_change(kind, handle)
  write("TARGET wall=" .. os.date("%Y-%m-%dT%H:%M:%S") .. " kind=" .. tostring(kind) .. " handle=" .. tostring(handle))
  if kind == 1 and handle and handle ~= 0 then
    M.item_hover("ground", nil, handle)
  elseif kind == 2 and handle and handle ~= 0 then
    local ok, typeid = pcall(GetUnitTypeId, handle)
    write("TARGET UNIT handle=" .. tostring(handle) .. " type=" .. tostring(ok and typeid or "error"))
  end
end
function M.begin_event(frame, event, player)
  local previous = context
  sequence = sequence + 1
  context = sequence
  local totals = {}
  for op = 1, 50 do
    if counts[op] then totals[#totals+1] = tostring(op) .. "=" .. tostring(counts[op]) end
  end
  local described, detail = pcall(frame_detail, frame)
  write("EVENT BEGIN id=" .. sequence .. " wall=" .. os.date("%Y-%m-%dT%H:%M:%S") .. " kind=" .. tostring(names[event] or event) .. " frame=" .. tostring(frame) .. " player=" .. tostring(player) .. " detail=" .. (described and detail or "unknown") .. " calls=" .. calls .. " ops=" .. table.concat(totals, ","))
  return previous
end
function M.end_event(previous, ok, result)
  write("EVENT END id=" .. tostring(context) .. " ok=" .. tostring(ok) .. (ok and "" or " error=" .. tostring(result)))
  context = previous
end
function M.before(operation, arguments)
  calls = calls + 1
  counts[operation] = (counts[operation] or 0) + 1
  local detailed = context ~= nil or calls <= 20 or calls % 1000 == 0
  if detailed then
    local info = debug.getinfo(3, "Sl") or {}
    write("EXEC BEGIN call=" .. calls .. " event=" .. tostring(context) .. " op=" .. operation .. " frame=" .. tostring(arguments.IntA) .. " @" .. tostring(info.short_src) .. ":" .. tostring(info.currentline))
  end
  return detailed and calls or nil
end
function M.after(ticket, ok, result)
  if ticket then write("EXEC END call=" .. ticket .. " ok=" .. tostring(ok) .. (ok and "" or " error=" .. tostring(result))) end
end
return M
