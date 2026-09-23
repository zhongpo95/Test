-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local slk = require("jass.slk")
local Crafting = require("gameplay.feature.item.crafting")
local Korean = require("hera_korean")
local CraftingUI = {}
local state = {
  visible = false,
  page = 1,
  page_size = 15,
  buttons = {},
  slot_backgrounds = {}
}
local layout = {
  x = 690,
  y = 250,
  w = 540,
  h = 350,
  cols = 5,
  rows = 3,
  slot_w = 82,
  slot_h = 76,
  icon_w = 66.0,
  icon_h = 51.0,
  gap_x = 12,
  gap_y = 10,
  grid_x = 34,
  grid_y = 54
}

local function ui_texture(path)
  if not path or path == "" then
    return "Black.tga"
  end
  local lower_path = string.lower(path)
  if string.sub(lower_path, -4) == ".blp" or string.sub(lower_path, -4) == ".tga" then
    return path
  end
  return path .. ".tga"
end

local function item_data(typeid)
  local id = ID2S(typeid)
  return slk.item and (slk.item[id] or slk.item[typeid]) or {}, id
end

local function item_icon(typeid)
  local data = item_data(typeid)
  return ui_texture(data.Art)
end

local function item_name(typeid)
  local data, id = item_data(typeid)
  return Korean.translate(tostring(data.Name or id))
end

local function slot_position(index)
  local column = (index - 1) % layout.cols
  local row = math.floor((index - 1) / layout.cols)
  return layout.grid_x + column * (layout.slot_w + layout.gap_x), layout.grid_y + row * (layout.slot_h + layout.gap_y)
end

local function ingredient_text(ingredient)
  local names = {}
  for index, typeid in ipairs(ingredient.items) do
    names[index] = item_name(typeid)
  end
  return table.concat(names, " / ") .. " x" .. ingredient.count
end

local function recipe_tip(recipe)
  local lines = {
    "|cFFFFCC66" .. Korean.translate(recipe.name or item_name(recipe.output)) .. "|r",
    "|cFFCCCCCC제작 재료.|r"
  }
  if #recipe.ingredients == 0 then
    lines[#lines + 1] = "없음"
  else
    for _, ingredient in ipairs(recipe.ingredients) do
      lines[#lines + 1] = ingredient_text(ingredient)
    end
  end
  if type(recipe.output_count) == "number" and 1 < recipe.output_count then
    lines[#lines + 1] = "제작 수량. " .. recipe.output_count
  elseif type(recipe.output_count) == "function" then
    lines[#lines + 1] = "제작 수량. 아이템 소모 수에 따라 결정"
  end
  if type(recipe.chance) == "number" and recipe.chance < 100 then
    lines[#lines + 1] = "성공률. " .. recipe.chance .. "%"
  end
  if recipe.description and recipe.description ~= "" then
    lines[#lines + 1] = Korean.translate(recipe.description)
  end
  lines[#lines + 1] = "|cFF7DBEF1클릭하여 제작|r"
  return table.concat(lines, "\n")
end

local function resolve_context()
  local sy = LocalPlayerID
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

local function clear_recipe_buttons()
  for index, button in ipairs(state.buttons) do
    button:destroy()
    state.buttons[index] = nil
  end
end

local function page_count(recipe_count)
  return math.max(1, math.ceil(recipe_count / state.page_size))
end

local function refresh()
  if not state.panel then
    return
  end
  local context = resolve_context()
  if not context then
    return
  end
  clear_recipe_buttons()
  local recipe_list = Crafting.list(context)
  local pages = page_count(#recipe_list)
  state.page = math.max(1, math.min(state.page, pages))
  state.page_text:set_text(state.page .. " / " .. pages)
  state.empty_text:set_text(#recipe_list == 0 and "제작 가능한 아이템이 없습니다." or "")
  local first_index = (state.page - 1) * state.page_size + 1
  local last_index = math.min(first_index + state.page_size - 1, #recipe_list)
  local view_index = 0
  for recipe_index = first_index, last_index do
    view_index = view_index + 1
    local recipe = recipe_list[recipe_index]
    local x, y = slot_position(view_index)
    local button = class.button:builder({
      parent = state.panel,
      x = x + (layout.slot_w - layout.icon_w) * 0.5,
      y = y + (layout.slot_h - layout.icon_h) * 0.5,
      w = layout.icon_w,
      h = layout.icon_h,
      normal_image = item_icon(recipe.output),
      on_button_clicked = function()
        Crafting.request(recipe.id)
      end,
      on_button_mouse_enter = function(self)
        self:set_alpha(220)
        uiy_show_text(recipe_tip(recipe), "Item")
        return false
      end,
      on_button_mouse_leave = function(self)
        self:set_alpha(255)
        uiy_hide()
        return false
      end
    })
    state.buttons[#state.buttons + 1] = button
  end
end

local function set_visible(visible)
  state.visible = visible
  if visible then
    refresh()
    state.panel:show()
  else
    state.panel:hide()
    uiy_hide()
  end
end

local function build()
  if state.panel then
    return
  end
  local panel = class.button:builder({
    x = layout.x,
    y = layout.y,
    w = layout.w,
    h = layout.h,
    normal_image = "Touming.tga"
  })
  state.panel = panel
  local background = class.panel:builder({
    parent = panel,
    x = 0,
    y = 0,
    w = layout.w,
    h = layout.h,
    normal_image = "Black.tga"
  })
  background:set_alpha(165)
  state.background = background
  state.title = class.text:builder({
    parent = panel,
    x = 42,
    y = 10,
    w = layout.w - 84,
    h = 32,
    font_size = 14,
    text = "|cFFFFCC66아이템 제작|r",
    align = "center"
  })
  local drag_area = class.button:builder({
    parent = panel,
    x = 0,
    y = 0,
    w = layout.w - 42,
    h = 44,
    normal_image = "Touming.tga",
    on_button_update_drag = function(_, _, x, y)
      panel:set_position(x, y)
      layout.x = x
      layout.y = y
      return false
    end
  })
  drag_area:set_enable_drag(true)
  state.drag_area = drag_area
  local close_button = class.button:builder({
    parent = panel,
    x = layout.w - 38,
    y = 8,
    w = 28,
    h = 28,
    normal_image = "Black.tga",
    on_button_clicked = function()
      set_visible(false)
    end
  })
  close_button:set_alpha(210)
  state.close_button = close_button
  state.close_text = class.text:builder({
    parent = close_button,
    x = 0,
    y = 0,
    w = 28,
    h = 28,
    font_size = 12,
    text = "X",
    align = "center"
  })
  for index = 1, state.page_size do
    local x, y = slot_position(index)
    local slot = class.panel:builder({
      parent = panel,
      x = x,
      y = y,
      w = layout.slot_w,
      h = layout.slot_h,
      normal_image = "Black.tga"
    })
    slot:set_alpha(115)
    state.slot_backgrounds[index] = slot
  end
  state.empty_text = class.text:builder({
    parent = panel,
    x = 0,
    y = 165,
    w = layout.w,
    h = 30,
    font_size = 11,
    text = "",
    align = "center"
  })
  local previous_button = class.button:builder({
    parent = panel,
    x = layout.w * 0.5 - 92,
    y = layout.h - 36,
    w = 44,
    h = 26,
    normal_image = "Black.tga",
    on_button_clicked = function()
      if state.page > 1 then
        state.page = state.page - 1
        refresh()
      end
    end
  })
  previous_button:set_alpha(180)
  state.previous_button = previous_button
  state.previous_text = class.text:builder({
    parent = previous_button,
    x = 0,
    y = 0,
    w = 44,
    h = 26,
    font_size = 11,
    text = "<",
    align = "center"
  })
  state.page_text = class.text:builder({
    parent = panel,
    x = layout.w * 0.5 - 42,
    y = layout.h - 36,
    w = 84,
    h = 26,
    font_size = 10,
    text = "1 / 1",
    align = "center"
  })
  local next_button = class.button:builder({
    parent = panel,
    x = layout.w * 0.5 + 48,
    y = layout.h - 36,
    w = 44,
    h = 26,
    normal_image = "Black.tga",
    on_button_clicked = function()
      local context = resolve_context()
      if context and state.page < page_count(#Crafting.list(context)) then
        state.page = state.page + 1
        refresh()
      end
    end
  })
  next_button:set_alpha(180)
  state.next_button = next_button
  state.next_text = class.text:builder({
    parent = next_button,
    x = 0,
    y = 0,
    w = 44,
    h = 26,
    font_size = 11,
    text = ">",
    align = "center"
  })
  panel:hide()
end

function CraftingUI.toggle(sy)
  if sy ~= LocalPlayerID then
    return
  end
  build()
  state.page = state.visible and state.page or 1
  set_visible(not state.visible)
end

function CraftingUI.hide()
  if state.panel then
    set_visible(false)
  end
end

function CraftingUI.refresh()
  if state.visible then
    refresh()
  end
end

Crafting.set_local_result_handler(function()
  CraftingUI.refresh()
end)
Crafting.set_local_registry_handler(function()
  CraftingUI.refresh()
end)
return CraftingUI
