-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local japi = require("jass.japi")
local Crafting = {}
local SYNC_KEY = "CraftItem"
local recipes = {}
local recipe_order = {}
local local_result_handler, local_registry_handler

local function normalize_rawcode(value, field_name)
  if type(value) == "number" then
    assert(value ~= 0, field_name .. " cannot be zero")
    return value
  end
  assert(type(value) == "string" and value ~= "", field_name .. " must be a rawcode")
  local typeid = S2ID(value)
  assert(typeid and typeid ~= 0, field_name .. " must resolve to a rawcode")
  return typeid
end

local function assert_callback(value, field_name)
  assert(value == nil or type(value) == "function", field_name .. " must be a function")
end

local function normalize_ingredients(source)
  assert(type(source) == "table", "ingredients must be a list")
  local normalized = {}
  local index_by_key = {}
  for index, ingredient in ipairs(source) do
    assert(type(ingredient) == "table", "ingredient " .. index .. " must be a table")
    local count = ingredient.count or 1
    assert(type(count) == "number" and 0 < count and count % 1 == 0, "ingredient " .. index .. " count must be a positive integer")
    local source_items = ingredient.items
    if source_items == nil then
      source_items = {
        ingredient.item
      }
    end
    assert(type(source_items) == "table" and 0 < #source_items, "ingredient " .. index .. " needs item or items")
    local items = {}
    local key_parts = {}
    for item_index, value in ipairs(source_items) do
      local typeid = normalize_rawcode(value, "ingredient " .. index .. " item " .. item_index)
      items[item_index] = typeid
      key_parts[item_index] = tostring(typeid)
    end
    local key = table.concat(key_parts, ":")
    local normalized_index = index_by_key[key]
    if normalized_index then
      normalized[normalized_index].count = normalized[normalized_index].count + count
    else
      normalized[#normalized + 1] = {items = items, count = count}
      index_by_key[key] = #normalized
    end
  end
  return normalized
end

local function normalize_number_or_callback(value, default_value, field_name, minimum, maximum)
  value = value == nil and default_value or value
  if type(value) == "function" then
    return value
  end
  assert(type(value) == "number" and minimum <= value and (not maximum or value <= maximum), field_name .. " is out of range")
  return value
end

local function normalize_recipe(id, source)
  assert(type(id) == "string" and id ~= "", "recipe id must be a non-empty string")
  assert(type(source) == "table", "recipe must be a table")
  local output_to = source.output_to or "backpack"
  assert(output_to == "backpack" or output_to == "hero", "output_to must be backpack or hero")
  assert(source.listed == nil or type(source.listed) == "boolean", "listed must be a boolean")
  assert_callback(source.visible, "visible")
  assert_callback(source.can_craft, "can_craft")
  assert_callback(source.on_success, "on_success")
  assert_callback(source.attempt, "attempt")
  local recipe = {
    id = id,
    output = normalize_rawcode(source.output, "output"),
    output_count = normalize_number_or_callback(source.output_count, 1, "output_count", 1),
    ingredients = normalize_ingredients(source.ingredients or {}),
    chance = normalize_number_or_callback(source.chance, 100, "chance", 0, 100),
    output_to = output_to,
    listed = source.listed ~= false,
    name = source.name,
    description = source.description,
    text = source.text,
    visible = source.visible,
    can_craft = source.can_craft,
    on_success = source.on_success,
    attempt = source.attempt
  }
  return recipe
end

local function call_local(callback, ...)
  if not callback then
    return
  end
  local ok, err = pcall(callback, ...)
  if not ok then
    print("[Crafting] local callback failed: " .. tostring(err))
  end
end

local function notify_registry_changed()
  call_local(local_registry_handler)
end

function Crafting.add(id, recipe)
  local normalized = normalize_recipe(id, recipe)
  if not recipes[id] then
    recipe_order[#recipe_order + 1] = id
  end
  recipes[id] = normalized
  notify_registry_changed()
  return normalized
end

function Crafting.remove(id)
  if not recipes[id] then
    return false
  end
  recipes[id] = nil
  for index, current_id in ipairs(recipe_order) do
    if current_id == id then
      table.remove(recipe_order, index)
      break
    end
  end
  notify_registry_changed()
  return true
end

function Crafting.get(id)
  return recipes[id]
end

local function is_visible(recipe, context)
  if not recipe.visible then
    return true
  end
  local ok, visible = pcall(recipe.visible, context, recipe)
  if not ok then
    print("[Crafting] recipe visible failed: " .. recipe.id .. ": " .. tostring(visible))
    return false
  end
  return visible == true
end

function Crafting.list(context)
  local result = {}
  for _, id in ipairs(recipe_order) do
    local recipe = recipes[id]
    if recipe and recipe.listed and (not context or is_visible(recipe, context)) then
      result[#result + 1] = recipe
    end
  end
  return result
end

local function resolve_context(sy)
  local hero_handle = Hero and Hero[sy]
  local backpack_handle = Beibao and Beibao[sy]
  if not (hero_handle and hero_handle ~= 0 and backpack_handle) or backpack_handle == 0 then
    return
  end
  local hero = getunit(hero_handle)
  local backpack = getunit(backpack_handle)
  if not hero or not backpack then
    return
  end
  return {
    sy = sy,
    hero = hero,
    backpack = backpack
  }
end

local function item_amount(item)
  local charges = GetItemCharges(item)
  if 0 < charges then
    return charges
  end
  return 1
end

local function append_unit_inventory(result, unit)
  if not unit or not unit.getcountitem then
    return
  end
  for slot = 1, 6 do
    local item = unit:getcountitem(slot)
    if item and item ~= 0 and GetItemTypeId(item) ~= 0 then
      result[#result + 1] = item
    end
  end
end

local function collect_item_pool(context)
  local result = {}
  append_unit_inventory(result, context.hero)
  if context.backpack.handle ~= context.hero.handle then
    append_unit_inventory(result, context.backpack)
  end
  local state = TestConsumeItemBagUI_State
  local items = state and state.item_areas and state.item_areas[context.sy]
  if items then
    for slot = 1, 64 do
      local data = items[slot]
      local item = data and data.item
      if item and item ~= 0 and GetItemTypeId(item) ~= 0 then
        result[#result + 1] = item
      end
    end
  end
  return result
end

local function plan_item_type(item_pool, typeid, needed, reserved)
  local candidate = {}
  local remaining = needed
  for _, item in ipairs(item_pool) do
    if GetItemTypeId(item) == typeid then
      local available = item_amount(item) - (reserved[item] or 0)
      if 0 < available then
        local take = math.min(available, remaining)
        candidate[#candidate + 1] = {item = item, count = take}
        remaining = remaining - take
        if remaining == 0 then
          return candidate
        end
      end
    end
  end
end

local function build_consumption_plan(recipe, context)
  local plan = {}
  local reserved_items = {}
  local reserved_medicines = {}
  local item_pool = collect_item_pool(context)
  for _, ingredient in ipairs(recipe.ingredients) do
    local candidate
    for _, typeid in ipairs(ingredient.items) do
      if CountedMedicine and CountedMedicine.by_type[typeid] then
        local available = CountedMedicine.get_count(context.hero, typeid) - (reserved_medicines[typeid] or 0)
        if available >= ingredient.count then
          candidate = {
            {
              medicine = typeid,
              count = ingredient.count
            }
          }
        end
      else
        candidate = plan_item_type(item_pool, typeid, ingredient.count, reserved_items)
      end
      if candidate then
        break
      end
    end
    if not candidate then
      return
    end
    for _, entry in ipairs(candidate) do
      if entry.medicine then
        reserved_medicines[entry.medicine] = (reserved_medicines[entry.medicine] or 0) + entry.count
      else
        reserved_items[entry.item] = (reserved_items[entry.item] or 0) + entry.count
      end
      plan[#plan + 1] = entry
    end
  end
  return plan
end

local function resolve_recipe_number(value, context, recipe, field_name)
  if type(value) ~= "function" then
    return value
  end
  local ok, result = pcall(value, context, recipe)
  if not ok then
    print("[Crafting] recipe " .. field_name .. " failed: " .. recipe.id .. ": " .. tostring(result))
    return
  end
  return result
end

local function send_result_message(context, recipe, success, reason)
  if success then
    if recipe.text and recipe.text ~= "" then
      context.hero:sendmessage(recipe.text)
    end
    context.hero:sendmessage("|cFF7DBEF1제작 성공|r")
  elseif reason == "materials" then
    context.hero:sendmessage("|cFF7DBEF1재료가 부족합니다.|r")
  elseif reason == "chance" then
    context.hero:sendmessage("|cFF7DBEF1제조 실패|r")
  elseif reason == "unavailable" then
    context.hero:sendmessage("|cFF7DBEF1현재 이 아이템을 제작할 수 없습니다.|r")
  end
end

local function check_recipe_condition(recipe, context)
  if not is_visible(recipe, context) then
    return false, "unavailable"
  end
  if not recipe.can_craft then
    return true
  end
  local ok, allowed, reason = pcall(recipe.can_craft, context, recipe)
  if not ok then
    print("[Crafting] recipe can_craft failed: " .. recipe.id .. ": " .. tostring(allowed))
    return false, "unavailable"
  end
  return allowed == true, reason or "unavailable"
end

function Crafting.try(sy, id, silent)
  local context = resolve_context(sy)
  local recipe = recipes[id]
  if not context or not recipe then
    return false, "missing"
  end
  local allowed, reason = check_recipe_condition(recipe, context)
  if not allowed then
    if not silent then
      send_result_message(context, recipe, false, reason)
    end
    return false, reason or "unavailable"
  end
  if recipe.attempt then
    local ok, success, custom_reason = pcall(recipe.attempt, context, recipe)
    if not ok then
      print("[Crafting] recipe attempt failed: " .. recipe.id .. ": " .. tostring(success))
      return false, "error"
    end
    reason = custom_reason or success and "success" or "unavailable"
    if not silent then
      send_result_message(context, recipe, success == true, reason)
    end
    return success == true, reason
  end
  local plan = build_consumption_plan(recipe, context)
  if not plan then
    if not silent then
      send_result_message(context, recipe, false, "materials")
    end
    return false, "materials"
  end
  local output_count = resolve_recipe_number(recipe.output_count, context, recipe, "output_count")
  local chance = resolve_recipe_number(recipe.chance, context, recipe, "chance")
  if type(output_count) ~= "number" or output_count < 1 or type(chance) ~= "number" or chance < 0 or 100 < chance then
    return false, "invalid"
  end
  output_count = math.floor(output_count)
  for _, entry in ipairs(plan) do
    if entry.medicine then
      CountedMedicine.consume(context.hero, entry.medicine, entry.count)
    else
      if GetItemCharges(entry.item) <= entry.count then
        RemoveItemLua(entry.item)
      else
        ChangeItemCount(entry.item, -entry.count)
      end
      if RefreshPlayerBagLikeItem then
        RefreshPlayerBagLikeItem(context.hero, entry.item)
      end
    end
  end
  if chance < 100 and not GetRandom100(chance) then
    if not silent then
      send_result_message(context, recipe, false, "chance")
    end
    return false, "chance"
  end
  local target = recipe.output_to == "hero" and context.hero or context.backpack
  local output_item = target:additem(recipe.output, output_count)
  if recipe.on_success then
    local ok, err = pcall(recipe.on_success, context, output_item, recipe)
    if not ok then
      print("[Crafting] recipe on_success failed: " .. recipe.id .. ": " .. tostring(err))
    end
  end
  if not silent then
    send_result_message(context, recipe, true, "success")
  end
  return true, "success"
end

function Crafting.request(id)
  if recipes[id] and recipes[id].listed then
    japi.DzSyncData(SYNC_KEY, id)
  end
end

function Crafting.set_local_result_handler(handler)
  assert_callback(handler, "local result handler")
  local_result_handler = handler
end

function Crafting.set_local_registry_handler(handler)
  assert_callback(handler, "local registry handler")
  local_registry_handler = handler
end

local sync_trigger = CreateTrigger()
japi.DzTriggerRegisterSyncData(sync_trigger, SYNC_KEY, false)
TriggerAddAction(sync_trigger, function()
  local sy = GetConvertedPlayerId(japi.DzGetTriggerSyncPlayer())
  local id = japi.DzGetTriggerSyncData()
  local success, reason = Crafting.try(sy, id)
  if sy == LocalPlayerID then
    call_local(local_result_handler, success, reason, id)
  end
end)
AddCraftableItem = Crafting.add
RemoveCraftableItem = Crafting.remove
return Crafting
