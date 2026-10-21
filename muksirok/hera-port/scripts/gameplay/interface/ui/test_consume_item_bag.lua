-- 헤라 공유 가방은 좌클릭으로 꺼내며 비충전 아이템 한 개를 0개로 표시하지 않는다.
local japi = require("jass.japi")
local slk = require("jass.slk")
local icon_chat = require("gameplay.interface.ui.icon_chat")
local TEAM_BAG_COLS = 8
local TEAM_BAG_ROWS = 8
local TEAM_BAG_SLOT_COUNT = TEAM_BAG_COLS * TEAM_BAG_ROWS

function TestConsumeItemBagUIGetItem(target_sy, typeid)
  if type(typeid) == "string" then
    typeid = S2ID(typeid)
  end
  local state = TestConsumeItemBagUI_State
  local items = state and not state.shared_items and state.item_areas and state.item_areas[target_sy]
  if not (items and typeid) or typeid == 0 then
    return 0
  end
  for slot = 1, TEAM_BAG_SLOT_COUNT do
    local data = items[slot]
    if data and data.item and data.item ~= 0 and GetItemTypeId(data.item) == typeid then
      return data.item
    end
  end
  return 0
end

function TestConsumeItemBagUIRefreshItem(target_sy, item)
  if not item or item == 0 then
    return false
  end
  local state = TestConsumeItemBagUI_State
  local instance = state and state.instances and state.instances[target_sy]
  local items = state and not state.shared_items and state.item_areas and state.item_areas[target_sy]
  if not items then
    return false
  end
  local remove_ui_item = state.shared_ui_remove_item or instance and instance.remove_ui_item
  local refresh_ui_item = state.shared_ui_refresh_item or instance and instance.refresh_ui_item
  for index = 1, TEAM_BAG_SLOT_COUNT do
    local data = items[index]
    if data and data.item == item then
      local charges = GetItemCharges(item)
      local typeid = GetItemTypeId(item)
      local itemtype = GetItemType(item)
      if typeid == 0 or charges <= 0 and (itemtype == ITEM_TYPE_CHARGED or itemtype == ITEM_TYPE_ARTIFACT) and not HasData(typeid, "枪械类型") then
        items[index] = nil
        if remove_ui_item then
          remove_ui_item(index)
        end
        return true
      end
      data.charges = charges
      if refresh_ui_item then
        refresh_ui_item(index)
      end
      return true
    end
  end
  return false
end

function GetPlayerBagLikeItem(u, typeid)
  if type(typeid) == "string" then
    typeid = S2ID(typeid)
  end
  if not (u and typeid) or typeid == 0 then
    return 0
  end
  local sy = u.ownerid
  if u.ishasitem and u:ishasitem(typeid) then
    return u:getitem(typeid)
  end
  local bb = Beibao and Beibao[sy] and Beibao[sy] ~= 0 and getunit(Beibao[sy])
  if bb and bb:ishasitem(typeid) then
    return bb:getitem(typeid)
  end
  if TestConsumeItemBagUIGetItem then
    return TestConsumeItemBagUIGetItem(sy, typeid)
  end
  return 0
end

function RefreshPlayerBagLikeItem(u, item)
  if not (u and item) or item == 0 then
    return false
  end
  return TestConsumeItemBagUIRefreshItem(u.ownerid, item)
end

function DestroyTestConsumeItemBagUI(target_sy)
  local state = TestConsumeItemBagUI_State
  if not state then
    return
  end
  local local_ui = state.local_ui
  if local_ui and (not target_sy or local_ui.sy == target_sy) then
    if local_ui.panel then
      local_ui.panel:destroy()
      local_ui.panel = nil
    end
    if local_ui.toggle_button then
      local_ui.toggle_button:destroy()
      local_ui.toggle_button = nil
    end
    state.local_ui = nil
    state.shared_ui_remove_item = nil
    state.shared_ui_refresh_item = nil
  end
  if target_sy and state.instances then
    local instance = state.instances[target_sy]
    if instance then
      instance.bag = nil
    end
    state.instances[target_sy] = nil
  elseif not target_sy then
    state.instances = {}
  end
  if target_sy and state.sync_handlers then
    state.sync_handlers[target_sy] = nil
  end
end

function FlushTestConsumeItemBagUIItems(target_sy)
  local state = TestConsumeItemBagUI_State
  if not state or not state.item_areas then
    return
  end
  local items = state.shared_items or state.item_areas[target_sy]
  if not items then
    return
  end
  local remove_ui_item = state.shared_ui_remove_item
  local hero = Hero and Hero[target_sy] and Hero[target_sy] ~= 0 and getunit(Hero[target_sy])
  local x, y
  if hero and hero.handle and hero.handle ~= 0 then
    x, y = hero:getxy()
  else
    x, y = PX_X or 0, PX_Y or 0
  end
  for index = 1, TEAM_BAG_SLOT_COUNT do
    local data = items[index]
    if data and data.item and data.item ~= 0 then
      local dx, dy = PolarXY(x, y, GetRandomReal(80, 180), GetRandomAngle())
      SetItemPosition(data.item, dx, dy)
    end
    items[index] = nil
    if remove_ui_item then
      remove_ui_item(index)
    end
  end
end

function DestroyTestConsumeItemBagUIByPlayer(target_sy)
  DestroyTestConsumeItemBagUI(target_sy)
end

function ToggleTestConsumeItemBagUI(target_sy)
  local state = TestConsumeItemBagUI_State
  local local_ui = state and state.local_ui
  if local_ui and local_ui.sy == target_sy and local_ui.set_bag_open then
    local_ui.set_bag_open(not local_ui.is_open)
  end
end

local function SaveTestConsumeItemBagUIConfig(sy, pickup_to_ui, hero_pickup_to_ui)
  if sy ~= LocalPlayerID then
    return
  end
  if playerconfig_set_ui_bag_pickup_to_ui then
    playerconfig_set_ui_bag_pickup_to_ui(sy, pickup_to_ui == true, false)
  else
    UIBagPickupToUI = pickup_to_ui == true
  end
  if playerconfig_set_ui_bag_hero_pickup_to_ui then
    playerconfig_set_ui_bag_hero_pickup_to_ui(sy, hero_pickup_to_ui == true, true)
  else
    UIBagHeroPickupToUI = hero_pickup_to_ui == true
    if playerconfigsave then
      playerconfigsave()
    end
  end
end

local function SyncTestConsumeItemBagUIConfig(pickup_to_ui, hero_pickup_to_ui)
  japi.DzSyncData("TestBagUI", table.concat({
    "config",
    pickup_to_ui and 1 or 0,
    hero_pickup_to_ui and 1 or 0
  }, "|"))
end

function InitTestConsumeItemBagUISync()
  if TestConsumeItemBagUI_SyncInited then
    return
  end
  TestConsumeItemBagUI_SyncInited = true
  local trg = CreateTrigger()
  japi.DzTriggerRegisterSyncData(trg, "TestBagUI", false)
  TriggerAddAction(trg, function()
    local state = TestConsumeItemBagUI_State
    if not state or not state.sync_handlers then
      return
    end
    local player = japi.DzGetTriggerSyncPlayer()
    local sy2 = GetConvertedPlayerId(player)
    local handler = state.sync_handlers[sy2]
    if handler then
      handler(japi.DzGetTriggerSyncData())
    end
  end)
  local leave_trg = CreateTrigger()
  for i = 0, 5 do
    TriggerRegisterPlayerEvent(leave_trg, Player(i), EVENT_PLAYER_LEAVE)
  end
  TriggerAddAction(leave_trg, function()
    local sy2 = GetConvertedPlayerId(GetTriggerPlayer())
    DestroyTestConsumeItemBagUIByPlayer(sy2)
  end)
  local chat_trg = CreateTrigger()
  for i = 0, 5 do
    TriggerRegisterPlayerChatEvent(chat_trg, Player(i), "-bb", true)
    TriggerRegisterPlayerChatEvent(chat_trg, Player(i), "-bb2", true)
  end
  TriggerAddAction(chat_trg, function()
    local state = TestConsumeItemBagUI_State
    if not state then
      return
    end
    local command = GetEventPlayerChatString()
    local sy2 = GetConvertedPlayerId(GetTriggerPlayer())
    local hero = Hero and Hero[sy2] and Hero[sy2] ~= 0 and getunit(Hero[sy2])
    if command == "-bb2" then
      state.hero_pickup_to_ui = state.hero_pickup_to_ui or {}
      state.hero_pickup_to_ui[sy2] = not state.hero_pickup_to_ui[sy2]
      if sy2 == LocalPlayerID then
        SaveTestConsumeItemBagUIConfig(sy2, state.pickup_to_ui and state.pickup_to_ui[sy2], state.hero_pickup_to_ui[sy2])
      end
      if hero then
        if state.hero_pickup_to_ui[sy2] then
          hero:sendmessage("|cFF7DBEF1开启英雄拾取消耗品进入UI背包|r")
        else
          hero:sendmessage("|cFF7DBEF1关闭英雄拾取消耗品进入UI背包|r")
        end
      end
      return
    end
    state.pickup_to_ui = state.pickup_to_ui or {}
    state.pickup_to_ui[sy2] = not state.pickup_to_ui[sy2]
    if sy2 == LocalPlayerID then
      SaveTestConsumeItemBagUIConfig(sy2, state.pickup_to_ui[sy2], state.hero_pickup_to_ui and state.hero_pickup_to_ui[sy2])
    end
    if hero then
      if state.pickup_to_ui[sy2] then
        hero:sendmessage("|cFF7DBEF1开启物品塞入UI背包|r")
      else
        hero:sendmessage("|cFF7DBEF1关闭物品塞入UI背包|r")
      end
    end
  end)
end

function TestConsumeItemBagUI(hero_unit)
  InitTestConsumeItemBagUISync()
  local hero = hero_unit
  if type(hero) ~= "table" or not hero.handle then
    hero = getunit(hero or Hero[LocalPlayerID] or Hero[1])
  end
  if not (hero and hero.handle) or hero.handle == 0 then
    return
  end
  local hero_sy = hero.ownerid
  local layout = {
    panel_x = 500,
    panel_y = 185,
    slot_w = 77,
    slot_h = 60,
    gap_x = 10,
    gap_y = 9,
    grid_x = 14,
    grid_y = 48,
    panel_padding_w = 28,
    panel_padding_h = 62,
    toggle_x = 1640,
    toggle_y = 730,
    toggle_w = 58.08,
    toggle_h = 56.72832
  }
  local state = TestConsumeItemBagUI_State or {
    item_areas = {},
    shared_items = {},
    next_shared_item_id = 0,
    move_queue = {},
    move_queue_head = 1,
    move_queue_processing = false,
    instances = {},
    sync_handlers = {},
    layouts = {},
    get_item_events = {},
    hero_get_item_events = {},
    pickup_to_ui = {},
    hero_pickup_to_ui = {},
    config_ready = {}
  }
  state.item_areas = state.item_areas or {}
  state.shared_items = state.shared_items or state.item_areas[1] or {}
  state.next_shared_item_id = state.next_shared_item_id or 0
  state.move_queue = state.move_queue or {}
  state.move_queue_head = state.move_queue_head or 1
  state.move_queue_processing = state.move_queue_processing == true
  for slot = 1, TEAM_BAG_SLOT_COUNT do
    local data = state.shared_items[slot]
    if data then
      if type(data.shared_id) == "number" then
        state.next_shared_item_id = math.max(state.next_shared_item_id, data.shared_id)
      else
        state.next_shared_item_id = state.next_shared_item_id + 1
        data.shared_id = state.next_shared_item_id
      end
    end
  end
  state.instances = state.instances or {}
  state.sync_handlers = state.sync_handlers or {}
  state.layouts = state.layouts or {}
  state.get_item_events = state.get_item_events or {}
  state.hero_get_item_events = state.hero_get_item_events or {}
  state.pickup_to_ui = state.pickup_to_ui or {}
  state.hero_pickup_to_ui = state.hero_pickup_to_ui or {}
  state.config_ready = state.config_ready or {}
  if state.pickup_to_ui[hero_sy] == nil then
    if hero_sy == LocalPlayerID then
      state.pickup_to_ui[hero_sy] = UIBagPickupToUI ~= false
    else
      state.pickup_to_ui[hero_sy] = true
    end
  end
  if state.hero_pickup_to_ui[hero_sy] == nil then
    if hero_sy == LocalPlayerID then
      state.hero_pickup_to_ui[hero_sy] = UIBagHeroPickupToUI == true
    else
      state.hero_pickup_to_ui[hero_sy] = false
    end
  end
  if state.config_ready[hero_sy] == nil then
    local waits_for_player_config = GetPlayerController(hero.owner) == MAP_CONTROL_USER and GetPlayerSlotState(hero.owner) == PLAYER_SLOT_STATE_PLAYING
    state.config_ready[hero_sy] = not waits_for_player_config
  end
  state.layouts[hero_sy] = state.layouts[hero_sy] or {
    x = layout.panel_x,
    y = layout.panel_y,
    toggle_x = layout.toggle_x,
    toggle_y = layout.toggle_y
  }
  TestConsumeItemBagUI_State = state
  DestroyTestConsumeItemBagUI(hero_sy)
  local bag_cols = TEAM_BAG_COLS
  local bag_rows = TEAM_BAG_ROWS
  local bag_slot_count = TEAM_BAG_SLOT_COUNT
  local bag_unit = Beibao and Beibao[hero_sy] and Beibao[hero_sy] ~= 0 and Beibao[hero_sy] or hero.handle
  local bag_items = state.shared_items
  state.item_areas[hero_sy] = bag_items
  local bag = {
    owner = hero,
    unit = bag_unit,
    sy = hero_sy,
    store_x = (PX_X or -7500) + 200,
    store_y = (PX_Y or -7500) + 200,
    items = bag_items,
    ignore_items = {},
    ignore_token = 0,
    pending_get_items = {}
  }
  local instance = {bag = bag}
  state.instances[hero_sy] = instance
  local state_layout = state.layouts[hero_sy]
  local ui = {
    sy = hero_sy,
    x = state_layout.x,
    y = state_layout.y,
    cols = bag_cols,
    rows = bag_rows,
    slot_w = layout.slot_w,
    slot_h = layout.slot_h,
    gap_x = layout.gap_x,
    gap_y = layout.gap_y,
    buttons = {},
    charge_texts = {},
    is_open = false
  }
  ui.grid_w = ui.cols * ui.slot_w + (ui.cols - 1) * ui.gap_x
  ui.grid_h = ui.rows * ui.slot_h + (ui.rows - 1) * ui.gap_y
  ui.w = ui.grid_w + layout.panel_padding_w
  ui.h = ui.grid_h + layout.panel_padding_h
  ui.bg_w = ui.w
  ui.bg_h = ui.h
  ui.bg_x = 0
  ui.bg_y = 0
  ui.grid_x = layout.grid_x
  ui.grid_y = layout.grid_y
  
  local function ui_texture(path)
    if not path or path == "" then
      return path
    end
    local lower_path = string.lower(path)
    if string.sub(lower_path, -4) == ".blp" or string.sub(lower_path, -4) == ".tga" then
      return path
    end
    return path .. ".tga"
  end
  
  local function item_icon(typeid)
    local id = ID2S(typeid)
    local icon = slk.item[id] and slk.item[id].Art
    if not icon or icon == "" then
      return ui_texture("ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp")
    end
    return ui_texture(icon)
  end
  
  local function is_shared_bag_item(item)
    local typeid = GetItemTypeId(item)
    local itemtype = GetItemType(item)
    return HasData(typeid, "物品类型-药水") or itemtype == ITEM_TYPE_CHARGED or itemtype == ITEM_TYPE_PURCHASABLE or itemtype == ITEM_TYPE_CAMPAIGN and HasData(item, "遗物-表") or itemtype == ITEM_TYPE_ARTIFACT and HasData(typeid, "子弹类型") or HasData(typeid, "枪械类型")
  end
  
  local function in_bag_area(cx, cy)
    return cx >= ui.x and cy >= ui.y and cx <= ui.x + ui.w and cy <= ui.y + ui.h
  end
  
  local function slot_position(index)
    local col = (index - 1) % ui.cols
    local row = math.floor((index - 1) / ui.cols)
    return ui.grid_x + col * (ui.slot_w + ui.gap_x), ui.grid_y + row * (ui.slot_h + ui.gap_y)
  end
  
  local function slot_at_mouse(mx, my)
    local rx = mx - ui.x
    local ry = my - ui.y
    for i = 1, ui.cols * ui.rows do
      local sx, sy2 = slot_position(i)
      if rx >= sx and ry >= sy2 and rx <= sx + ui.slot_w and ry <= sy2 + ui.slot_h then
        return i
      end
    end
  end
  
  local function set_icon_to_slot(index)
    local button = ui.buttons[index]
    if not button then
      return
    end
    local sx, sy2 = slot_position(index)
    button:set_position(sx + 6, sy2 + 6)
  end
  
  local request_move_item_slot
  
  local function stored_item_position(index)
    local col = (index - 1) % bag_cols
    local row = math.floor((index - 1) / bag_cols)
    return bag.store_x + col * 32, bag.store_y + row * 32
  end
  
  local function first_empty_slot()
    for i = 1, bag_slot_count do
      if not bag.items[i] then
        return i
      end
    end
  end
  
  local function update_charge_text(index)
    local data = bag.items[index]
    if not data then
      return
    end
    data.charges = data.item and data.item ~= 0 and GetItemCharges(data.item) or data.charges
    local charge_text = ui.charge_texts[index]
    if charge_text then
      charge_text:set_text("|cFF7DBEF1x" .. tostring(math.max(1, tonumber(data.charges) or 0)))
    end
  end
  
  local function stack_item_to_bag(item)
    if IsItemStackExcluded(item) then
      return false
    end
    local stacked
    for i = 1, bag_slot_count do
      local data = bag.items[i]
      if data and data.item and data.item ~= 0 then
        local result = TryStackItemToItem(item, data.item, bag.owner)
        if result then
          if state.shared_ui_refresh_item then
            state.shared_ui_refresh_item(i)
          else
            update_charge_text(i)
          end
          if result == "all" then
            return result
          end
          stacked = result
        end
      end
    end
    return stacked or false
  end
  
  local function is_local_hero_selected()
    if not (bag.owner and bag.owner.handle) or bag.owner.handle == 0 then
      return false
    end
    return IsUnitSelected(bag.owner.handle, Player(LocalPlayerID - 1))
  end
  
  local function is_local_bag_selected()
    if not bag.unit or bag.unit == 0 then
      return false
    end
    return IsUnitSelected(bag.unit, Player(LocalPlayerID - 1))
  end
  
  local function sync_bag_action(action, index, value)
    if not hero:islocal() then
      return
    end
    japi.DzSyncData("TestBagUI", table.concat({
      action,
      index or 0,
      value or 0
    }, "|"))
  end
  
  function request_move_item_slot(from_index, to_index)
    if not hero:islocal() then
      return false
    end
    if not to_index or from_index == to_index then
      set_icon_to_slot(from_index)
      return false
    end
    local data = bag.items[from_index]
    if not data or not data.shared_id then
      set_icon_to_slot(from_index)
      return false
    end
    sync_bag_action("move", data.shared_id, to_index)
    return true
  end
  
  local function find_shared_item_slot(shared_id)
    for slot = 1, bag_slot_count do
      local data = bag.items[slot]
      if data and data.shared_id == shared_id then
        return slot
      end
    end
  end
  
  local function call_shared_ui(handler, index, action)
    if not handler then
      return
    end
    local ok, error_message = pcall(handler, index)
    if not ok then
      print("[SharedBagUI] " .. action .. " slot " .. index .. ": " .. tostring(error_message))
    end
  end
  
  local function refresh_shared_ui_slot(index)
    call_shared_ui(state.shared_ui_remove_item, index, "remove")
    call_shared_ui(state.shared_ui_refresh_item, index, "refresh")
  end
  
  local function move_shared_item(shared_id, to_index)
    if type(shared_id) ~= "number" or type(to_index) ~= "number" or to_index ~= math.floor(to_index) or to_index < 1 or to_index > bag_slot_count then
      return false
    end
    local from_index = find_shared_item_slot(shared_id)
    if not from_index or from_index == to_index then
      return false
    end
    local moved_data = bag.items[from_index]
    local replaced_data = bag.items[to_index]
    bag.items[from_index], bag.items[to_index] = replaced_data, moved_data
    if moved_data.item and moved_data.item ~= 0 then
      local x, y = stored_item_position(to_index)
      SetItemPosition(moved_data.item, x, y)
    end
    if replaced_data and replaced_data.item and replaced_data.item ~= 0 then
      local x, y = stored_item_position(from_index)
      SetItemPosition(replaced_data.item, x, y)
    end
    refresh_shared_ui_slot(from_index)
    refresh_shared_ui_slot(to_index)
    return true
  end
  
  local function enqueue_shared_item_move(shared_id, to_index)
    if type(shared_id) ~= "number" or type(to_index) ~= "number" then
      return false
    end
    local move_queue = state.move_queue
    move_queue[#move_queue + 1] = {shared_id = shared_id, to_index = to_index}
    if state.move_queue_processing then
      return true
    end
    state.move_queue_processing = true
    while state.move_queue_head <= #move_queue do
      local request = move_queue[state.move_queue_head]
      state.move_queue_head = state.move_queue_head + 1
      local ok, error_message = pcall(move_shared_item, request.shared_id, request.to_index)
      if not ok then
        print("[SharedBag] move " .. request.shared_id .. ": " .. tostring(error_message))
      end
    end
    state.move_queue = {}
    state.move_queue_head = 1
    state.move_queue_processing = false
    return true
  end
  
  local function ignore_next_item_event(item)
    bag.ignore_token = bag.ignore_token + 1
    local token = bag.ignore_token
    bag.ignore_items[item] = token
    ac.wait(500, function()
      if bag.ignore_items[item] == token then
        bag.ignore_items[item] = nil
      end
    end)
  end
  
  local function drop_item_from_slot_sync(shared_id, target_type)
    local index = find_shared_item_slot(shared_id)
    local data = index and bag.items[index]
    if not data then
      return
    end
    if data.item and data.item ~= 0 then
      if target_type == "hero" then
        ignore_next_item_event(data.item)
        bag.owner:addspeitem(data.item)
      elseif target_type == "bag" then
        ignore_next_item_event(data.item)
        getunit(bag.unit):addspeitem(data.item)
      else
        local ux, uy = bag.owner:getxy()
        local dx, dy = PolarXY(ux, uy, GetRandomReal(80, 160), GetRandomAngle())
        SetItemPosition(data.item, dx, dy)
      end
    end
    if state.shared_ui_remove_item then
      state.shared_ui_remove_item(index)
    end
    bag.items[index] = nil
  end
  
  local function drop_item_from_slot(index, use_selected_target)
    local data = bag.items[index]
    if not data or not data.shared_id then
      return
    end
    local target_type = "drop"
    if use_selected_target and is_local_hero_selected() then
      target_type = "hero"
    elseif use_selected_target and is_local_bag_selected() then
      target_type = "bag"
    end
    sync_bag_action("drop", data.shared_id, target_type)
  end
  
  state.sync_handlers[hero_sy] = function(message)
    local action, a, b = string.match(message or "", "([^|]*)|([^|]*)|?(.*)")
    if action == "move" then
      enqueue_shared_item_move(tonumber(a), tonumber(b))
    elseif action == "drop" then
      drop_item_from_slot_sync(tonumber(a), b)
    elseif action == "config" then
      state.pickup_to_ui[hero_sy] = tonumber(a) == 1
      state.hero_pickup_to_ui[hero_sy] = tonumber(b) == 1
      state.config_ready[hero_sy] = true
      local current_instance = state.instances and state.instances[hero_sy]
      if current_instance and current_instance.flush_pending_get_items then
        current_instance.flush_pending_get_items()
      end
    end
  end
  if hero:islocal() then
    ac.wait(0, function()
      SyncTestConsumeItemBagUIConfig(state.pickup_to_ui[hero_sy], state.hero_pickup_to_ui[hero_sy])
    end)
  end
  local create_icon
  
  local function build_local_ui()
    local panel = class.panel:builder({
      x = ui.x,
      y = ui.y,
      w = ui.w,
      h = ui.h,
      normal_image = ui_texture("Touming.tga")
    })
    ui.panel = panel
    state.local_ui = ui
    local bg = class.panel:builder({
      parent = panel,
      x = ui.bg_x,
      y = ui.bg_y,
      w = ui.bg_w,
      h = ui.bg_h,
      normal_image = ui_texture("Black.blp")
    })
    bg:set_alpha(165)
    ui.bg = bg
    ui.title = class.text:builder({
      parent = panel,
      x = 14,
      y = 8,
      w = ui.w - 28,
      h = 34,
      font_size = 11,
      text = "|cFFFFCC66全队共享背包（左键取出到选中单位 Alt+左键喊话 右键取出 I关闭）|r",
      align = "center"
    })
    ui.drag_area = class.button:builder({
      parent = panel,
      x = 0,
      y = 0,
      w = ui.w,
      h = 42,
      normal_image = ui_texture("Touming.tga"),
      on_button_update_drag = function(self, icon, px, py)
        panel:set_position(px, py)
        ui.x = px
        ui.y = py
        state_layout.x = px
        state_layout.y = py
        return false
      end
    })
    ui.drag_area:set_enable_drag(true)
    
    local function set_bag_open(is_open)
      ui.is_open = is_open
      if ui.is_open then
        panel:show()
        SetSoundVolumeBJ(Sound_Beibao_Open, 70.0)
        PlayGlobalSound(Sound_Beibao_Open)
      else
        panel:hide()
      end
    end
    
    ui.set_bag_open = set_bag_open
    
    local function set_toggle_drag_locked(is_locked)
      state_layout.toggle_locked = is_locked
      if ui.toggle_button then
        ui.toggle_button:set_enable_drag(not is_locked)
      end
    end
    
    local function show_toggle_tip()
      local lock_text = state_layout.toggle_locked and "잠김" or "이동 가능"
      uiy_show_text("|cFFFFCC66팀 공유 가방(I)\n우클릭으로 이동 잠금 전환:" .. lock_text .. "\n-bb 가방 아이템의 공유 가방 보관 전환\n-bb2 영웅이 줍는 소모품의 공유 가방 보관 전환|r", "Yuanzhu")
    end
    
    ui.toggle_button = class.button:builder({
      x = state_layout.toggle_x,
      y = state_layout.toggle_y,
      w = layout.toggle_w,
      h = layout.toggle_h,
      normal_image = ui_texture("UI_Beibao_Small.blp"),
      on_button_clicked = function(self)
        set_bag_open(not ui.is_open)
      end,
      on_button_mouse_enter = function(self)
        self:set_alpha(155)
        show_toggle_tip()
        return false
      end,
      on_button_mouse_leave = function(self)
        self:set_alpha(255)
        uiy_hide()
        return false
      end,
      on_button_update_drag = function(self, icon, px, py)
        self:set_position(px, py)
        state_layout.toggle_x = px
        state_layout.toggle_y = py
        return false
      end,
      on_button_right_clicked = function(self)
        set_toggle_drag_locked(not state_layout.toggle_locked)
        show_toggle_tip()
        return false
      end
    })
    set_toggle_drag_locked(state_layout.toggle_locked == true)
    set_bag_open(false)
    ui.slotbg = {}
    for i = 1, ui.cols * ui.rows do
      local sx, sy2 = slot_position(i)
      local slot = class.panel:builder({
        parent = panel,
        x = sx,
        y = sy2,
        w = ui.slot_w,
        h = ui.slot_h,
        normal_image = ui_texture("Black.blp")
      })
      slot:set_alpha(115)
      ui.slotbg[i] = slot
    end
    
    function create_icon(sync_index)
      local data = bag.items[sync_index]
      if not data then
        return
      end
      if ui.buttons[sync_index] then
        ui.buttons[sync_index]:destroy()
        ui.buttons[sync_index] = nil
      end
      ui.charge_texts[sync_index] = nil
      local sx, sy2 = slot_position(sync_index)
      local button = class.button:builder({
        parent = panel,
        x = sx + 6,
        y = sy2 + 6,
        w = ui.slot_w - 12,
        h = ui.slot_h - 12,
        normal_image = item_icon(data.typeid),
        on_button_clicked = function(self)
          drop_item_from_slot(self.bag_index, true)
        end,
        on_button_alt_click = function(self)
          local current = bag.items[self.bag_index]
          if current then
            icon_chat.try_send("物品", GetItemName(current.item))
          end
        end,
        on_button_update_drag = function(self, icon, px, py)
          icon:set_position(px, py)
          return false
        end,
        on_button_drag_and_drop = function(self, target, mx, my)
          local current_index = self.bag_index
          if in_bag_area(mx, my) then
            request_move_item_slot(current_index, slot_at_mouse(mx, my))
          else
            drop_item_from_slot(current_index, false)
          end
        end,
        on_button_right_clicked = function(self)
          drop_item_from_slot(self.bag_index, true)
        end
      })
      button.bag_index = sync_index
      button:set_enable_drag(true)
      ui.buttons[sync_index] = button
      if data.charges then
        ui.charge_texts[sync_index] = class.text:builder({
          parent = button,
          x = 38,
          y = 48,
          w = 25,
          h = 16,
          font_size = 8,
          text = "|cFF7DBEF1x" .. tostring(math.max(1, tonumber(data.charges) or 0)),
          align = "right"
        })
      end
    end
    
    for i = 1, ui.cols * ui.rows do
      if bag.items[i] then
        create_icon(i)
      end
    end
  end
  
  if hero:islocal() then
    build_local_ui()
  end
  
  function instance.remove_ui_item(sync_index)
    if ui.buttons[sync_index] then
      ui.buttons[sync_index]:destroy()
      ui.buttons[sync_index] = nil
    end
    ui.charge_texts[sync_index] = nil
  end
  
  function instance.refresh_ui_item(sync_index)
    if create_icon and bag.items[sync_index] and not ui.buttons[sync_index] then
      create_icon(sync_index)
    else
      update_charge_text(sync_index)
    end
  end
  
  if hero:islocal() then
    state.shared_ui_remove_item = instance.remove_ui_item
    state.shared_ui_refresh_item = instance.refresh_ui_item
  end
  
  local function add_item_to_bag_sync(item, unit)
    if not item or item == 0 or not is_shared_bag_item(item) then
      return false
    end
    local typeid = GetItemTypeId(item)
    local stack_result = stack_item_to_bag(item)
    if stack_result == "all" then
      return true
    end
    local index = first_empty_slot()
    if not index then
      return false
    end
    local charges = GetItemCharges(item)
    local store_x, store_y = stored_item_position(index)
    state.next_shared_item_id = state.next_shared_item_id + 1
    bag.items[index] = {
      item = item,
      typeid = typeid,
      charges = charges,
      shared_id = state.next_shared_item_id
    }
    UnitRemoveItem(unit or bag.unit, item)
    SetItemPosition(item, store_x, store_y)
    if state.shared_ui_refresh_item then
      state.shared_ui_refresh_item(index)
    end
    return true
  end
  
  local function should_ignore_item_event(item)
    if not bag.ignore_items[item] then
      return false
    end
    bag.ignore_items[item] = nil
    return true
  end
  
  local function process_get_item(args, from_hero)
    if from_hero then
      if not state.hero_pickup_to_ui[hero_sy] then
        return
      end
    elseif not state.pickup_to_ui[hero_sy] then
      return
    end
    add_item_to_bag_sync(args.item, args.unit)
  end
  
  local function flush_pending_get_items()
    local pending_get_items = bag.pending_get_items
    bag.pending_get_items = {}
    for _, pending in ipairs(pending_get_items) do
      process_get_item(pending, pending.from_hero)
    end
  end
  
  instance.flush_pending_get_items = flush_pending_get_items
  
  local function on_get_item(args, from_hero)
    if TestConsumeItemBagUI_State ~= state then
      return
    end
    if should_ignore_item_event(args.item) then
      return
    end
    if not state.config_ready[hero_sy] then
      bag.pending_get_items[#bag.pending_get_items + 1] = {
        item = args.item,
        unit = args.unit,
        from_hero = from_hero
      }
      return
    end
    process_get_item(args, from_hero)
  end
  
  instance.on_get_item = on_get_item
  if Beibao and Beibao[hero_sy] and Beibao[hero_sy] ~= 0 and not state.get_item_events[hero_sy] then
    state.get_item_events[hero_sy] = true
    getunit(Beibao[hero_sy]):addtrgevent("单位-获得物品", function(args)
      local now_state = TestConsumeItemBagUI_State
      local instance = now_state and now_state.instances and now_state.instances[hero_sy]
      if instance and instance.on_get_item then
        instance.on_get_item(args, false)
      end
    end)
  end
  if not state.hero_get_item_events[hero_sy] then
    state.hero_get_item_events[hero_sy] = true
    hero:addtrgevent("单位-获得物品", function(args)
      local now_state = TestConsumeItemBagUI_State
      local instance = now_state and now_state.instances and now_state.instances[hero_sy]
      if instance and instance.on_get_item then
        instance.on_get_item(args, true)
      end
    end)
  end
end
