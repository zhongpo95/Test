-- 보상 카드 설명을 먼저 번역하고 원문 단편의 반복 번역 없이 줄바꿈한다.
local slk = require("jass.slk")
local slk = require("jass.slk")
RLChoice = {
  _cfg = {},
  _ui = {},
  _collapsed = false,
  _session = {
    active = false,
    items = nil,
    picked_by = {},
    expected_pids = nil,
    fading = false
  },
  effect = nil,
  _keys_rev = {},
  _actions = {
    all = {},
    per_player = {},
    all_default = nil,
    per_player_default = {},
    on_cancel = "rlc_cancel"
  }
}
do
  local DEFAULT_CFG = {
    panel_x = 50,
    panel_y = 150,
    panel_w = 1820,
    panel_h = 640,
    panel_bg = "Touming.tga",
    panel_alpha = 2,
    card_scale = 0.9,
    card_w = 418,
    card_h = 538,
    card_gap = 24,
    card_y = 60,
    card_bg = "war3mapImported\\Black.blp",
    card_frame = "UI_Biankuang_01.blp",
    card_back = "UI_Card_Back.blp",
    icon_w = 88,
    icon_h = 68,
    icon_x_offset = 210,
    icon_y = 20,
    title_font = 13,
    text_font = 13,
    text_w = 420,
    text_x = 23,
    text_y = 120,
    title_x = -5,
    title_y = 105,
    auto_scale = true,
    min_card_scale = 0.7,
    max_card_scale = 1.0,
    panel_lr_padding = 20,
    title_pad = 8,
    text_pad = 18,
    tip_w = 300,
    tip_h = 600,
    tip_margin = 10,
    tip_marginy = 10,
    tip_bg = "Touming.tga",
    tip_alpha = 255,
    minimize_x = 1725,
    minimize_y = 668,
    minimize_w = 88,
    minimize_h = 68,
    minimize_textsize = 10,
    skip_img = "UI_Button_X.tga",
    skip_w = 88,
    skip_h = 93.16,
    skip_gap = 16,
    refresh_img = "UI_Button_X.tga",
    refresh_w = 88,
    refresh_h = 93.16,
    refresh_gap = 8,
    refresh_text = "|cFF99FFFF刷新|r",
    anim_ms = 250,
    measure_font = 13,
    placeholder_icon = "war3mapImported\\Black.blp",
    rarity_frame = {
      ["普通"] = "UI_Select_White.blp",
      ["稀有"] = "UI_Select_Blue.blp",
      ["史诗"] = "UI_Select_Purple.blp",
      ["传说"] = "UI_Select_Orange.blp",
      ["神话"] = "UI_Select_Colorful.blp"
    },
    rarity_title_color = {
      ["普通"] = "|cFFFFFFFF",
      ["稀有"] = "|cFF5687ED",
      ["史诗"] = "|cFFC03FFE",
      ["传说"] = "|cFFF95521",
      ["神话"] = "|cFFFF99FF"
    },
    list_side_margin = 200,
    list_top_margin = 24,
    list_mid_gap = 16,
    list_bottom_margin = 20,
    list_desc_w = 1400,
    list_desc_h = 615,
    list_banner_w = 600,
    list_banner_h = 600,
    list_opt_w = 700,
    list_opt_h = 40,
    list_opt_gap = 10,
    list_opt_bg = "UI_T_button.blp",
    list_opt_font = 12
  }
  
  local function _tween_alpha(nodes, from_a, to_a, dur_ms, on_done, ease)
    local steps = math.max(1, math.floor((dur_ms or 150) / 16))
    local t = 0
    
    local function easing(x)
      if ease == "quad_in" then
        return x * x
      end
      if ease == "quad_out" then
        return 1 - (1 - x) * (1 - x)
      end
      if ease == "quad_inout" then
        if x < 0.5 then
          return 2 * x * x
        else
          return 1 - (-2 * x + 2) ^ 2 / 2
        end
      end
      return x
    end
    
    for _, n in ipairs(nodes) do
      if n.obj.show then
        n.obj:show()
      end
    end
    local my_gen = RLChoice._anim.gen
    
    local function step()
      t = t + 1
      local p = t / steps
      local k = easing(p)
      local cur = from_a + (to_a - from_a) * k
      for _, n in ipairs(nodes) do
        local target = math.floor(cur * (n.base or 255) / 255)
        if n.obj.set_alpha then
          n.obj:set_alpha(target)
        end
      end
      if t >= steps then
        return true
      end
      return false
    end
    
    local timer
    timer = ac.loop(16, function(self_timer)
      if RLChoice._anim.gen ~= my_gen then
        self_timer:remove()
        RLChoice._anim.timers[self_timer] = nil
        return
      end
      if step() then
        self_timer:remove()
        RLChoice._anim.timers[self_timer] = nil
        if on_done and RLChoice._anim.gen == my_gen then
          on_done()
        end
      end
    end)
    RLChoice._anim.timers[timer] = true
  end
  
  local function ensure_measure(cfg, ui)
    if ui.measure then
      return
    end
    ui.measure = class.text:builder({
      x = 0,
      y = 0,
      w = 1,
      h = 1,
      align = "auto_size",
      font_size = cfg.measure_font,
      text = ""
    })
    ui.measure:hide()
  end
  
  local function _strip_w3_color_tags(s)
    s = tostring(s or "")
    s = s:gsub("|[cC]%x%x%x%x%x%x%x%x", ""):gsub("|[rR]", "")
    return s
  end
  
  local function text_width(ui, s)
    local korean = require("hera_korean")
    return require("hera_text_width").pixels(s, ui.measure.font_size or 13,
      korean.has_hangul(s) and korean.font or ui.measure.font_path)
  end
  
  local function _tokenize_with_w3color(s)
    local t, i, n = {}, 1, #(s or "")
    while i <= n do
      local ch = s:sub(i, i)
      if ch == "|" then
        local seg = s:sub(i)
        local m = seg:match("^|[cC]%x%x%x%x%x%x%x%x")
        if m then
          t[#t + 1] = {text = m, tag = "color"}
          i = i + #m
        elseif seg:sub(1, 2) == "|r" or seg:sub(1, 2) == "|R" then
          t[#t + 1] = {text = "|r", tag = "reset"}
          i = i + 2
        elseif seg:sub(1, 2) == "|n" or seg:sub(1, 2) == "|N" then
          t[#t + 1] = {text = "\n", tag = "newline"}
          i = i + 2
        else
          t[#t + 1] = {text = ch}
          i = i + 1
        end
      else
        local b = s:byte(i)
        local len = b < 128 and 1 or b >> 5 == 6 and 2 or b >> 4 == 14 and 3 or b >> 3 == 30 and 4 or 1
        t[#t + 1] = {
          text = s:sub(i, i + len - 1)
        }
        i = i + len
      end
    end
    return t
  end
  
  local function smart_wrap(ui, raw, maxw)
    local tokens = _tokenize_with_w3color(require("hera_korean").translate(tostring(raw or "")))
    local line, out = "", ""
    for _, tk in ipairs(tokens) do
      if tk.tag == "newline" or tk.text == "\n" then
        out = out .. line .. "\n"
        line = ""
      elseif tk.tag == "color" or tk.tag == "reset" then
        line = line .. tk.text
      else
        local test = line .. tk.text
        if maxw < text_width(ui, test) then
          out = out .. line .. "\n"
          line = tk.text
        else
          line = test
        end
      end
    end
    return out .. line
  end
  
  local function compute_auto_scale(cfg, count)
    local want = cfg.card_scale or 1.0
    local W = cfg.panel_w - 2 * (cfg.panel_lr_padding or 0)
    local gaps = (count - 1) * (cfg.card_gap or 0)
    if count <= 0 then
      return want
    end
    local cap = (W - gaps) / (cfg.card_w * count)
    local s = math.min(want, cap)
    s = math.max(cfg.min_card_scale or 0.6, s)
    s = math.min(cfg.max_card_scale or 1.0, s)
    return s
  end
  
  local function compute_cards_layout(cfg, count)
    count = math.max(1, math.min(5, count))
    local s = cfg.card_scale or 1.0
    local card_w_eff = cfg.card_w * s
    local total_w = count * card_w_eff + (count - 1) * cfg.card_gap
    local start_x = (cfg.panel_w - total_w) * 0.5
    local xs = {}
    for i = 1, count do
      xs[i] = start_x + (i - 1) * (card_w_eff + cfg.card_gap)
    end
    return xs, cfg.card_y
  end
  
  local function rescale_card(btn, cfg)
    local s = cfg.card_scale or 1.0
    btn:set_control_size(cfg.card_w * s, cfg.card_h * s)
    btn.frame:set_position(0, 0)
    btn.frame:set_control_size(420 * s, 540 * s)
    btn.back:set_position(0, 0)
    btn.back:set_control_size(440.0 * s, 509.32000000000005 * s)
    local icon_cx = cfg.icon_x_offset or cfg.card_w * 0.5
    local icon_x = (icon_cx - cfg.icon_w * 0.5) * s
    btn.icon:set_position(icon_x, cfg.icon_y * s)
    btn.icon:set_control_size(cfg.icon_w * s, cfg.icon_h * s)
    local title_w = math.max(1, cfg.card_w * s - 2 * (cfg.title_pad or 0))
    if btn.title.set_control_size then
      btn.title:set_control_size(title_w, 1)
      btn.title:set_position(cfg.title_pad or 0, cfg.title_y * s)
    end
    local text_w = math.max(1, cfg.card_w * s - 2 * (cfg.text_pad or 0))
    if btn.text.set_control_size then
      btn.text:set_control_size(text_w, 1)
      btn.text:set_position(cfg.text_pad or 0, cfg.text_y * s)
    end
  end
  
  RLROUND = {}
  RLROUND.func = {}
  for i = 1, 6 do
    RLROUND.func[i] = {}
  end
  RLROUND.roundcount = {}
  for i = 1, 6 do
    RLROUND.roundcount[i] = 0
  end
  RLROUND.context = {}
  for i = 1, 6 do
    RLROUND.context[i] = {}
  end
  RLChoice._active_cards = {}
  RLChoice._anim = {
    timers = {},
    gen = 0
  }
  
  function RLChoice._anim_stop_all()
    for t in pairs(RLChoice._anim.timers) do
      t:remove()
    end
    RLChoice._anim.timers = {}
    RLChoice._anim.gen = RLChoice._anim.gen + 1
    RLChoice._session.fading = false
  end
  
  RLChoice._queue = {}
  
  local function _queue_push(u, data, opts)
    local key = u.handle
    local q = RLChoice._queue[key]
    if not q then
      q = {}
      RLChoice._queue[key] = q
    end
    q[#q + 1] = {data = data, opts = opts}
  end
  
  local function _queue_pop_next(u)
    local key = u.handle
    local q = RLChoice._queue[key]
    if not q or #q == 0 then
      return
    end
    local next_one = table.remove(q, 1)
    RLChoice.open(next_one.data, next_one.opts)
  end
  
  RLChoice.effect = {}
  
  local function make_round_token(sy, rid)
    return ("%d:%d"):format(sy, rid)
  end
  
  local function resolve_round_context(p, token)
    if not p or not p.handle then
      return
    end
    local player = getplayer(p.handle)
    if not player then
      return
    end
    local sy = player.id
    local token_sy, token_rid = tostring(token or ""):match("^(%d+):(%d+)$")
    token_sy = tonumber(token_sy)
    token_rid = tonumber(token_rid)
    if token_sy ~= sy or RLROUND.roundcount[sy] ~= token_rid then
      return
    end
    local contexts = RLROUND.context[sy]
    local context = contexts and contexts[token_rid]
    if not context or context.token ~= token then
      return
    end
    local u = context.unit
    if not (u and u.ownerid == sy and Hero[sy]) or Hero[sy] == 0 or Hero[sy] ~= u.handle then
      return
    end
    return sy, u, token_rid
  end
  
  function RLChoice.effect.rlc_set(u)
    local sy = u.ownerid
    local rid = RLROUND.roundcount[sy]
    rid = rid + 1
    RLROUND.roundcount[sy] = rid
    RLROUND.func[sy][rid] = {}
    local token = make_round_token(sy, rid)
    RLROUND.context[sy][rid] = {
      unit = u,
      ownerid = sy,
      token = token
    }
    return rid, token
  end
  
  function RLChoice.effect.rlc_get_token(u)
    if not u then
      return
    end
    local sy = u.ownerid
    local rid = RLROUND.roundcount[sy]
    local contexts = RLROUND.context[sy]
    local context = contexts and contexts[rid]
    if context and context.unit == u and context.ownerid == sy then
      return context.token
    end
  end
  
  function RLChoice.effect.rlc_cancel(p, token)
    local sy, u, rid = resolve_round_context(p, token)
    if not sy then
      return
    end
    RLChoice._active_cards[sy] = nil
    u:deldata("系统-正在选择选项")
    if u:islocal() then
      RLChoice._fade_out_all()
      RLChoice._ui.minimize:hide()
      RLChoice._session.active = false
      uiy_hide()
    end
    if u:hasdata("系统-取消函数") and type(u:getdata("系统-取消函数")) == "function" then
      u:getdata("系统-取消函数")()
      u:deldata("系统-取消函数")
    end
    RLChoice.effect.clear_round(sy, rid)
    _queue_pop_next(u)
  end
  
  function RLChoice.effect.rlc_pick(p, index, token)
    local sy, u, rid = resolve_round_context(p, token)
    if not sy then
      return
    end
    RLChoice._active_cards[sy] = nil
    u:deldata("系统-正在选择选项")
    if u:islocal() then
      RLChoice._fade_out_all()
      RLChoice._ui.minimize:hide()
      RLChoice._session.active = false
      uiy_hide()
    end
    if u:hasdata("系统-取消函数") then
      u:deldata("系统-取消函数")
    end
    local round = RLROUND.func[sy] and RLROUND.func[sy][rid]
    local callback = round and round[index]
    if callback then
      callback(u)
    end
    RLChoice.effect.clear_round(sy, rid)
    _queue_pop_next(u)
  end
  
  local function get_refresh_cost(count)
    count = count or 0
    return 1 + count * 4
  end
  
  local function get_refresh_count_key(state, index)
    if state and state.refresh and state.refresh.shared_cost then
      return 0
    end
    return index
  end
  
  local function get_refresh_remaining_count(state, u)
    if not state or not state.refresh then
      return 0
    end
    local refresh = state.refresh
    if type(refresh.remaining_func) == "function" then
      local ok, value = pcall(refresh.remaining_func, u, state)
      if ok then
        return math.max(0, math.floor(tonumber(value) or 0))
      end
    end
    local key = refresh.remaining_key
    if key and u then
      return math.max(0, math.floor(tonumber(u:getdata(key)) or 0))
    end
    return math.max(0, math.floor(tonumber(refresh.remaining) or 0))
  end
  
  function RLChoice.effect.rlc_refresh(p, index, token)
    local sy, u, rid = resolve_round_context(p, token)
    if not sy then
      return
    end
    local state = RLChoice._active_cards[sy]
    if not state or state.ownerid ~= sy or state.rid ~= rid or state.token ~= token or state.unit ~= u then
      return
    end
    if not (state.data and state.refresh) or not state.refresh.func then
      return
    end
    local shared_all = state.refresh.shared_all
    if not shared_all and (not state.data.options or not state.data.options[index]) then
      return
    end
    if shared_all then
      local remaining_key = state.refresh.remaining_key
      local remaining = get_refresh_remaining_count(state, u)
      if remaining <= 0 then
        u:sendmessage("|cffa9ffb5剩余刷新次数不足|r")
        return
      end
      local old_options = state.data.options or {}
      local sim_options = {}
      for i = 1, #old_options do
        sim_options[i] = old_options[i]
      end
      local sim_data = {
        options = sim_options,
        desc = state.data.desc,
        skip_medicinegetend = state.data.skip_medicinegetend,
        option_func_wrapper = state.data.option_func_wrapper
      }
      local new_options = {}
      for i = 1, #old_options do
        local new_option = state.refresh.func(u, sim_data, i)
        if not new_option then
          u:sendmessage("|cFFFF6666刷新失败|r")
          return
        end
        sim_options[i] = new_option
        new_options[i] = new_option
      end
      if remaining_key then
        u:changedata(remaining_key, -1)
      end
      for i = 1, #new_options do
        local new_option = new_options[i]
        state.data.options[i] = new_option
        if RLROUND.func[sy] and RLROUND.func[sy][state.rid] then
          RLROUND.func[sy][state.rid][i] = new_option.func
        end
        if u:islocal() and RLChoice._render_card_option then
          RLChoice._render_card_option(i, new_option)
        end
      end
      if u:islocal() then
        RLChoice._update_refresh_button()
        PlayGlobalSound(Sound_UI_Buy)
      end
      return
    end
    local refresh_count_key = get_refresh_count_key(state, index)
    local cost = get_refresh_cost(state.refresh_counts[refresh_count_key] or 0)
    local use_wood = state.refresh.resource == "wood"
    local current
    if use_wood then
      current = tonumber(u:getwood()) or 0
    else
      local resource_key = state.refresh.resource_key or "系统-次元值"
      current = tonumber(u:getdata(resource_key)) or 0
    end
    if cost > current then
      u:sendmessage("|cFFFF6666追忆值不足，需要" .. cost .. "点|r")
      return
    end
    local new_option = state.refresh.func(u, state.data, index)
    if not new_option then
      u:sendmessage("|cFFFF6666刷新失败|r")
      return
    end
    if use_wood then
      u:addwood(-cost)
    else
      local resource_key = state.refresh.resource_key or "系统-次元值"
      u:changedata(resource_key, -cost)
    end
    state.refresh_counts[refresh_count_key] = (state.refresh_counts[refresh_count_key] or 0) + 1
    state.data.options[index] = new_option
    if RLROUND.func[sy] and RLROUND.func[sy][state.rid] then
      RLROUND.func[sy][state.rid][index] = new_option.func
    end
    if u:islocal() and RLChoice._render_card_option then
      RLChoice._render_card_option(index, new_option)
      RLChoice._update_refresh_button()
      PlayGlobalSound(Sound_UI_Buy)
    end
  end
  
  function RLChoice.effect.clear_round(sy, rid)
    if RLROUND.func[sy] then
      RLROUND.func[sy][rid] = nil
    end
    if RLROUND.context[sy] then
      RLROUND.context[sy][rid] = nil
    end
  end
  
  function RLChoice._fade_in_cards(count)
    local ui = RLChoice._ui
    local cfg = RLChoice._cfg
    if RLChoice._collapsed then
      return
    end
    if not (ui and ui.showg) or #ui.showg == 0 then
      return
    end
    local nodes = {}
    for _, o in ipairs(ui.showg) do
      if o and o.get_is_show and o:get_is_show() then
        table.insert(nodes, {
          obj = o,
          base = o._base_alpha or 255
        })
      end
    end
    if #nodes == 0 then
      return
    end
    for _, n in ipairs(nodes) do
      if n.obj.set_alpha then
        n.obj:set_alpha(0)
      end
    end
    RLChoice._session.fading = true
    _tween_alpha(nodes, 3, 254, cfg.anim_ms or 150, function()
      ac.wait(200, function()
        RLChoice._session.fading = false
      end)
    end, "quad_out")
  end
  
  function RLChoice._fade_in_list(count)
    local ui = RLChoice._ui
    local cfg = RLChoice._cfg
    if RLChoice._collapsed then
      return
    end
    if not (ui and ui.showg) or #ui.showg == 0 then
      return
    end
    local nodes = {}
    for _, o in ipairs(ui.showg) do
      if o and o.get_is_show and o:get_is_show() then
        table.insert(nodes, {
          obj = o,
          base = o._base_alpha or 255
        })
      end
    end
    if #nodes == 0 then
      return
    end
    for _, n in ipairs(nodes) do
      if n.obj.set_alpha then
        n.obj:set_alpha(0)
      end
    end
    RLChoice._session.fading = true
    _tween_alpha(nodes, 3, 254, cfg.anim_ms or 150, function()
      ac.wait(200, function()
        RLChoice._session.fading = false
      end)
    end, "quad_out")
  end
  
  function RLChoice._fade_out_all(on_done)
    local ui = RLChoice._ui
    local cfg = RLChoice._cfg
    if not (not RLChoice._collapsed and ui and ui.showg) or #ui.showg == 0 then
      RLChoice._hide_all()
      if on_done then
        on_done()
      end
      return
    end
    local nodes = {}
    for _, o in ipairs(ui.showg) do
      if o and o.get_is_show and o:get_is_show() then
        table.insert(nodes, {
          obj = o,
          base = o._base_alpha or 255
        })
      end
    end
    if #nodes == 0 then
      RLChoice._hide_all()
      if on_done then
        on_done()
      end
      return
    end
    _tween_alpha(nodes, 255, 0, cfg.anim_ms or 150, function()
      RLChoice._hide_all()
      if on_done then
        on_done()
      end
    end, "quad_in")
  end
  
  local function ensure_card(ui, cfg, i)
    if ui.cards[i] then
      return ui.cards[i]
    end
    local btn = class.button:builder({
      parent = ui.card_container,
      sync_key = "newuibtn" .. i,
      x = 0,
      y = cfg.card_y,
      w = cfg.card_w,
      h = cfg.card_h,
      normal_image = cfg.card_bg,
      on_button_mouse_enter = function(self)
        self:set_alpha(100)
        self.back:set_alpha(0)
      end,
      on_button_mouse_leave = function(self)
        self:set_alpha(200)
        self.back:set_alpha(25)
        self.icon:set_alpha(255)
        self.title:set_alpha(255)
        self.text:set_alpha(255)
        self.frame:set_alpha(225)
      end,
      on_button_clicked = function(self)
        if not RLChoice._session.active or RLChoice._session.fading then
          return
        end
        uiy_hide()
        RLChoice._fade_out_all()
      end,
      on_sync_button_clicked = function(self, p)
        p = getplayer(p.handle)
        RLChoice.effect.rlc_pick(p, i, self.sync_data)
      end
    })
    btn.icon = class.panel:builder({
      parent = btn,
      x = cfg.icon_x_offset - cfg.icon_w * 0.5,
      y = cfg.icon_y,
      w = cfg.icon_w,
      h = cfg.icon_h,
      normal_image = cfg.placeholder_icon
    })
    btn.frame = class.panel:builder({
      parent = btn,
      x = 0,
      y = 0,
      w = 420,
      h = 540,
      normal_image = cfg.card_frame
    })
    btn.back = class.panel:builder({
      parent = btn,
      x = -7,
      y = 8,
      w = 440.0,
      h = 509.32000000000005,
      normal_image = cfg.card_back
    })
    btn.title = class.text:builder({
      parent = btn,
      x = cfg.title_x,
      y = cfg.title_y,
      w = cfg.text_w,
      h = 1,
      text = "",
      align = "center",
      font_size = cfg.title_font
    })
    btn.text = class.text:builder({
      parent = btn,
      x = cfg.text_x,
      y = cfg.text_y,
      w = cfg.text_w,
      h = 1,
      text = "",
      align = "topleft",
      font_size = 10
    })
    btn:set_alpha(200)
    btn.back:set_alpha(25)
    btn:set_alpha(200)
    btn._base_alpha = 200
    btn.back:set_alpha(25)
    btn.back._base_alpha = 25
    btn.frame:set_alpha(225)
    btn.frame._base_alpha = 225
    btn.icon:set_alpha(255)
    btn.icon._base_alpha = 255
    btn.title:set_alpha(255)
    btn.title._base_alpha = 255
    btn.text:set_alpha(255)
    btn.text._base_alpha = 255
    btn.title:set_level(3)
    btn.text:set_level(3)
    btn.icon:set_level(3)
    btn:hide()
    ui.cards[i] = btn
    return btn
  end
  
  local function build_ui(ui)
    local cfg = RLChoice._cfg
    ui.panel = class.panel:builder({
      x = cfg.panel_x,
      y = cfg.panel_y,
      w = cfg.panel_w,
      h = cfg.panel_h,
      normal_image = cfg.panel_bg
    })
    ui.panel:hide()
    ui.panel:set_alpha(cfg.panel_alpha)
    ui.panel._base_alpha = cfg.panel_alpha
    GloPanel = ui.panel
    ui.tip_panel = class.panel:builder({
      parent = ui.panel,
      x = cfg.panel_w * 0.5,
      y = cfg.tip_marginy,
      w = cfg.tip_w,
      h = cfg.tip_h,
      normal_image = cfg.tip_bg
    })
    ui.tip_panel:set_alpha(cfg.tip_alpha)
    ui.tip_panel._base_alpha = cfg.tip_alpha
    ui.tip_text = class.text:builder({
      parent = ui.tip_panel,
      x = 10,
      y = 10,
      w = 1,
      h = 1,
      text = "",
      align = "center"
    })
    ui.cards = {}
    ui.card_container = class.panel:builder({
      parent = ui.panel,
      x = 0,
      y = 0,
      w = cfg.panel_w,
      h = cfg.panel_h,
      normal_image = "Touming.tga"
    })
    ui.skip = class.button:builder({
      parent = ui.panel,
      sync_key = "newuiskip",
      x = cfg.panel_w * 0.5 - cfg.skip_w * 0.5,
      y = cfg.card_y + cfg.card_h + cfg.skip_gap,
      w = cfg.skip_w,
      h = cfg.skip_h,
      normal_image = cfg.skip_img,
      on_button_mouse_enter = function(self)
        self:set_alpha(155)
        uiy_show_text("|cffa9ffb5跳过所有选项,不返还消耗资源|r", "Yuanzhu")
      end,
      on_button_mouse_leave = function(self)
        self:set_alpha(255)
        uiy_hide()
      end,
      on_button_clicked = function(self)
        if not RLChoice._session.active or RLChoice._session.fading then
          return
        end
        uiy_hide()
        RLChoice._fade_out_all()
      end,
      on_sync_button_clicked = function(self, p)
        p = getplayer(p.handle)
        RLChoice.effect.rlc_cancel(p, self.sync_data)
      end
    })
    ui.skip:hide()
    ui.refresh_button = class.button:builder({
      parent = ui.panel,
      sync_key = "newuirefresh_all",
      x = 0,
      y = cfg.card_y + cfg.card_h + cfg.refresh_gap,
      w = cfg.refresh_w,
      h = cfg.refresh_h,
      normal_image = cfg.refresh_img,
      on_button_mouse_enter = function(self)
        self:set_alpha(155)
        local count = self.__refresh_remaining
        if count ~= nil then
          uiy_show_text("|cffa9ffb5刷新全部选项\n任意BOSS被击败时获得2次|r", "Yuanzhu")
        else
          local cost = self.__refresh_cost or 1
          uiy_show_text("|cffa9ffb5消耗" .. cost .. "点追忆值刷新|r", "Yuanzhu")
        end
      end,
      on_button_mouse_leave = function(self)
        self:set_alpha(255)
        uiy_hide()
      end,
      on_button_clicked = function(self)
        if not RLChoice._session.active or RLChoice._session.fading then
          return
        end
        uiy_hide()
      end,
      on_sync_button_clicked = function(self, p)
        p = getplayer(p.handle)
        RLChoice.effect.rlc_refresh(p, nil, self.sync_data)
      end
    })
    ui.refresh_button.label = class.text:builder({
      parent = ui.refresh_button,
      x = 0,
      y = 18 + cfg.refresh_h,
      w = cfg.refresh_w,
      h = 1,
      text = "|cffa9ffb5剩余次数:0",
      align = "center",
      font_size = 11
    })
    ui.refresh_button:hide()
    local b2 = true
    ui.minimize = class.button:builder({
      x = cfg.minimize_x,
      y = cfg.minimize_y,
      w = cfg.minimize_w,
      h = cfg.minimize_h,
      normal_image = "UI_Ys_Book_Close.blp",
      hover_image = "UI_Ys_Book_Open.blp",
      on_button_mouse_enter = function(self)
        self:set_alpha(155)
        uiy_show_text("|cFFCC99FF点击打开奖励界面|r", "Yuanzhu")
      end,
      on_button_mouse_leave = function(self)
        self:set_alpha(255)
        uiy_hide()
      end,
      on_button_clicked = function(self)
        self:set_control_size(self:get_width() * 0.9, self:get_height() * 0.9)
        if ac and ac.wait then
          ac.wait(cfg.anim_ms + 10, function()
            self:set_control_size(self:get_width() / 0.9, self:get_height() / 0.9)
          end)
        end
        if ui.panel:get_is_show() then
          RLChoice._collapse()
        else
          RLChoice._expand()
        end
      end,
      on_button_right_clicked = function(self)
        if not b2 then
          b2 = true
          self:set_enable_drag(true)
        else
          b2 = false
          self:set_enable_drag(false)
        end
      end,
      on_button_update_drag = function(self, icon, x, y)
        self:set_position(x, y)
      end
    })
    ui.minimize:set_enable_drag(true)
    ui.minimize_gantan = class.texture:builder({
      parent = ui.minimize,
      x = 40,
      y = -10,
      w = 25,
      h = 25,
      normal_image = "UI_Chat_ICONGANTAN.tga"
    })
    ui.minimize_gantan:hide()
    ui.minimize_label = class.text:builder({
      parent = ui.minimize,
      x = cfg.minimize_w * 0.5,
      y = cfg.minimize_h,
      w = 1,
      h = 1,
      text = "|cFFCC99FF奖励选择(点击)",
      align = "center",
      font_size = cfg.minimize_textsize
    })
    ui.minimize:hide()
    Glominimize = ui.minimize
    for i = 1, 5 do
      ensure_card(ui, cfg, i)
    end
    ui.list_container = class.panel:builder({
      parent = ui.panel,
      x = 0,
      y = 0,
      w = cfg.panel_w,
      h = cfg.panel_h,
      normal_image = nil
    })
    ui.list_desc_panel = class.panel:builder({
      parent = ui.list_container,
      x = 0,
      y = 0,
      w = cfg.list_desc_w,
      h = cfg.list_desc_h,
      normal_image = "UI_Yisi_Biankuang.tga"
    })
    ui.list_desc_text = class.text:builder({
      parent = ui.list_desc_panel,
      x = 625,
      y = 25,
      w = 1,
      h = 1,
      text = "",
      align = "topleft",
      font_size = cfg.text_font
    })
    ui.list_desc_panel:set_alpha(55)
    ui.list_desc_panel._base_alpha = 55
    ui.list_desc_text:set_alpha(255)
    ui.list_desc_text._base_alpha = 255
    ui.list_banner = class.panel:builder({
      parent = ui.list_container,
      x = 0,
      y = 0,
      w = cfg.list_banner_w,
      h = cfg.list_banner_h,
      normal_image = cfg.placeholder_icon
    })
    ui.list_opts = {}
    for i = 1, 5 do
      local btn = class.button:builder({
        parent = ui.list_container,
        sync_key = "newuiopt" .. i,
        x = 0,
        y = 0,
        w = cfg.list_opt_w,
        h = cfg.list_opt_h,
        normal_image = cfg.list_opt_bg,
        on_button_clicked = function(self)
          if not RLChoice._session.active or RLChoice._session.fading then
            return
          end
          uiy_hide()
          RLChoice._fade_out_all()
        end,
        on_sync_button_clicked = function(self, p)
          p = getplayer(p.handle)
          RLChoice.effect.rlc_pick(p, i, self.sync_data)
        end
      })
      local tx = class.text:builder({
        parent = btn,
        x = 20,
        y = 20,
        w = cfg.list_opt_w - 24,
        h = 1,
        text = "",
        align = "left",
        font_size = cfg.list_opt_font
      })
      btn._index = i
      btn._label = tx
      btn:hide()
      ui.list_opts[i] = btn
    end
    ensure_measure(cfg, ui)
  end
  
  for k, v in pairs(DEFAULT_CFG) do
    RLChoice._cfg[k] = v
  end
  build_ui(RLChoice._ui)
  
  function RLChoice._collapse()
    RLChoice._hide_all()
  end
  
  function RLChoice._expand()
    RLChoice._ui.minimize_gantan:hide()
    RLChoice._show_all()
    if RLChoice._dtype == "cards" then
      RLChoice._fade_in_cards(RLChoice._items)
    else
      RLChoice._fade_in_list(RLChoice._items)
    end
  end
  
  function RLChoice._show_all()
    local ui = RLChoice._ui
    ui.showg = {}
    if RLChoice._dtype == "cards" then
      local zu = {
        ui.card_container,
        ui.tip_panel,
        ui.tip_text,
        ui.panel
      }
      for index, value in ipairs(zu) do
        value:show()
        table.insert(ui.showg, value)
      end
      if not ui.noskip then
        ui.skip:show()
        table.insert(ui.showg, ui.skip)
      end
      if ui.refresh_enabled and ui.refresh_button then
        ui.refresh_button:show()
        if ui.refresh_button.label then
          ui.refresh_button.label:show()
        end
        table.insert(ui.showg, ui.refresh_button)
        if ui.refresh_button.label then
          table.insert(ui.showg, ui.refresh_button.label)
        end
      end
      for i = 1, RLChoice._items do
        local b = ui.cards[i]
        b:show()
        b.icon:show()
        b.title:show()
        b.text:show()
        b.frame:show()
        b.back:show()
        table.insert(ui.showg, b)
        table.insert(ui.showg, b.icon)
        table.insert(ui.showg, b.title)
        table.insert(ui.showg, b.text)
        table.insert(ui.showg, b.frame)
        table.insert(ui.showg, b.back)
      end
    else
      local zu = {
        ui.list_container,
        ui.list_banner,
        ui.list_desc_panel,
        ui.list_desc_text,
        ui.panel
      }
      for index, value in ipairs(zu) do
        value:show()
        table.insert(ui.showg, value)
      end
      for i = 1, RLChoice._items do
        local b = ui.list_opts[i]
        b:show()
        table.insert(ui.showg, b)
      end
    end
    RLChoice._collapsed = false
  end
  
  function RLChoice._hide_all()
    local ui = RLChoice._ui
    local zu = {
      ui.card_container,
      ui.tip_panel,
      ui.tip_text,
      ui.list_container,
      ui.list_banner,
      ui.list_desc_panel,
      ui.list_desc_text,
      ui.skip,
      ui.refresh_button,
      ui.refresh_button and ui.refresh_button.label,
      ui.panel
    }
    for index, value in ipairs(zu) do
      if value then
        value:hide()
      end
    end
    for _, b in ipairs(ui.cards) do
      b:hide()
      b.icon:hide()
      b.title:hide()
      b.text:hide()
      b.back:hide()
      b.frame:hide()
    end
    for _, b in ipairs(ui.list_opts) do
      b:hide()
    end
    RLChoice._collapsed = true
  end
  
  local function update_refresh_button()
    local ui = RLChoice._ui
    local btn = ui.refresh_button
    local sy = ui.refresh_sy
    local state = sy and RLChoice._active_cards[sy]
    if not btn or not state then
      return
    end
    if state.refresh and state.refresh.shared_all then
      local count = get_refresh_remaining_count(state, getunit(Hero[sy]))
      btn.__refresh_remaining = count
      if count <= 0 then
        btn:set_normal_image("UI_Button_ReflashNBlack.blp")
      else
        btn:set_normal_image(state.refresh and state.refresh.image or RLChoice._cfg.refresh_img)
      end
      if btn.label then
        btn.label:set_text((state.refresh.remaining_text or "|cffa9ffb5剩余次数") .. ":" .. count)
      end
    else
      local refresh_count_key = get_refresh_count_key(state, 1)
      local cost = get_refresh_cost(state.refresh_counts[refresh_count_key] or 0)
      btn.__refresh_cost = cost
      if btn.label then
        btn.label:set_text((state.refresh.text or RLChoice._cfg.refresh_text or "|cFF99FFFF刷新|r") .. ":" .. cost)
      end
    end
    btn:add_cd_animation(0, 0, 1, 1)
    btn:set_cd(SYNC_BUTTON_CD, SYNC_BUTTON_CD)
  end
  
  local function render_card_option(i, it)
    local ui = RLChoice._ui
    local cfg = RLChoice._cfg
    local btn = ui.cards[i]
    local s = cfg.card_scale or 1.0
    if not btn then
      return
    end
    it = it or {}
    local icon = it.icon and tostring(it.icon) ~= "" and it.icon or cfg.placeholder_icon
    if not icon:match("%.tga$") and not icon:match("%.blp$") then
      icon = icon .. ".tga"
    end
    btn.icon:set_normal_image(icon)
    local rarity_key = it.rarity and tostring(it.rarity):lower() or "普通"
    btn.frame:set_normal_image(cfg.rarity_frame[rarity_key] or cfg.card_frame)
    local title_text = it.title or ""
    if not title_text:match("^|c%x%x%x%x%x%x%x%x") then
      local color = cfg.rarity_title_color[rarity_key]
      if color then
        title_text = color .. title_text .. "|r"
      end
    end
    btn.title:set_text(title_text)
    local wrap_w = math.max(1, cfg.card_w * s - 2 * (cfg.text_pad or 0))
    local korean = require("hera_korean")
    local metrics = require("hera_text_width")
    local display = korean.translate(it.text or "")
    local font = korean.has_hangul(display) and korean.font or btn.text.font_path
    local size = cfg.text_font or 13
    local available_h = math.max(1, (cfg.card_h - cfg.text_y) * s - (cfg.text_pad or 0))
    local wrapped = metrics.wrap(display, size, font, wrap_w)
    while size > 7 and metrics.height(wrapped, size, font) > available_h do
      size = size - 0.5
      wrapped = metrics.wrap(display, size, font, wrap_w)
    end
    btn.text:set_size(size / btn.text.font_size, font)
    btn.text:set_text(wrapped)
    btn:show()
    btn.icon:show()
    btn.title:show()
    btn.text:show()
    btn.frame:show()
    btn.back:show()
    btn:set_alpha(175)
    btn.icon:set_alpha(255)
    btn.title:set_alpha(255)
    btn.text:set_alpha(255)
    btn.back:set_alpha(25)
    btn.frame:set_alpha(225)
    rescale_card(btn, cfg)
  end
  
  RLChoice._render_card_option = render_card_option
  RLChoice._update_refresh_button = update_refresh_button
  
  local function enter_cards(data, opts)
    local ui = RLChoice._ui
    local cfg = RLChoice._cfg
    local u = opts.u
    local isshownow = opts.isshownow
    if isshownow == nil then
      isshownow = true
    end
    local sy = u.ownerid
    local rid, round_token = RLChoice.effect.rlc_set(u)
    local items = data.options
    local count = #items
    local noskip = data.noskip or false
    local refresh = data.refresh
    for i = 1, count do
      local it = items[i] or {}
      RLROUND.func[sy][rid][i] = it.func
    end
    RLChoice._active_cards[sy] = {
      data = data,
      refresh = refresh,
      refresh_counts = {},
      rid = rid,
      token = round_token,
      unit = u,
      ownerid = sy
    }
    if not u:islocal() then
      return
    end
    ui.skip.sync_data = round_token
    ui.refresh_button.sync_data = round_token
    ui.noskip = noskip
    ui.refresh_enabled = refresh and refresh.func ~= nil
    ui.refresh_sy = ui.refresh_enabled and sy or nil
    ui.tip_text:set_text(data.desc or "|cFFFFCC66【选择一项】[跳过]放弃本次选择|r")
    ui.tip_panel:show()
    if cfg.auto_scale then
      cfg.card_scale = compute_auto_scale(cfg, count)
    end
    local xs, card_y = compute_cards_layout(cfg, count)
    local s = cfg.card_scale or 1.0
    ui.card_container:show()
    local bottom_y = card_y + cfg.card_h * s + cfg.skip_gap
    local bottom_center = cfg.panel_w * 0.5
    local side_offset = (cfg.skip_w or 88) * 0.5
    if ui.refresh_enabled and ui.refresh_button then
      if refresh and refresh.image then
        ui.refresh_button:set_normal_image(refresh.image)
      else
        ui.refresh_button:set_normal_image(cfg.refresh_img)
      end
      ui.refresh_button:set_position(bottom_center + 16 + side_offset, bottom_y)
      if ui.refresh_button.label then
        ui.refresh_button.label:set_position(0, 18 + cfg.refresh_h)
      end
      ui.refresh_button:show()
      if ui.refresh_button.label then
        ui.refresh_button.label:show()
      end
    end
    if not noskip then
      if ui.refresh_enabled then
        ui.skip:set_position(bottom_center - cfg.skip_w - 16 - side_offset, bottom_y)
      else
        ui.skip:set_position(bottom_center - cfg.skip_w * 0.5, bottom_y)
      end
      ui.skip:show()
      ui.skip:add_cd_animation(0, 0, 1, 1)
      ui.skip:set_cd(SYNC_BUTTON_CD, SYNC_BUTTON_CD)
    end
    for i = 1, count do
      local it = items[i] or {}
      local btn = ui.cards[i]
      btn.sync_data = round_token
      btn.__index_in_cards = i
      btn:set_position(xs[i], card_y)
      btn:add_cd_animation(0, 0, 1, 1)
      btn:set_cd(SYNC_BUTTON_CD, SYNC_BUTTON_CD)
      render_card_option(i, it)
    end
    for i = count + 1, #ui.cards do
      local b = ui.cards[i]
      if b then
        b:hide()
      end
    end
    if ui.refresh_enabled then
      update_refresh_button()
    elseif ui.refresh_button then
      ui.refresh_button:hide()
      if ui.refresh_button.label then
        ui.refresh_button.label:hide()
      end
    end
    RLChoice._session.active = true
    ui.minimize:show()
    RLChoice._dtype = "cards"
    RLChoice._items = #items
    if isshownow then
      RLChoice._expand()
    else
      RLChoice._collapse()
      ui.minimize_gantan:show()
    end
  end
  
  local function enter_list(data, opts)
    local ui = RLChoice._ui
    local cfg = RLChoice._cfg
    local u = opts.u
    local isshownow = opts.isshownow
    if isshownow == nil then
      isshownow = true
    end
    local sy = u.ownerid
    local rid, round_token = RLChoice.effect.rlc_set(u)
    local items = data.options
    local count = #items
    for i = 1, count do
      local it = items[i] or {}
      RLROUND.func[sy][rid][i] = it.func
    end
    if not u:islocal() then
      return
    end
    RLChoice._session.active = true
    ui.tip_panel:hide()
    local banner = data.banner
    local desc_raw = data.desc or ""
    local opts_list = data.options or {}
    local side = cfg.list_side_margin or 40
    local mid_gap = cfg.list_mid_gap or 16
    local top_margin = cfg.list_top_margin or 24
    local bottom_margin = cfg.list_bottom_margin or 20
    local desc_w = cfg.list_desc_w or cfg.panel_w - 2 * side
    local desc_h = cfg.list_desc_h or 180
    local desc_x = side + 500
    local desc_y = top_margin
    if ui.list_desc_panel.set_control_size then
      ui.list_desc_panel:set_control_size(desc_w, desc_h)
    end
    ui.list_desc_panel:set_position(140, desc_y - 7)
    ui.list_desc_text:set_text(smart_wrap(ui, desc_raw, 740))
    ui.list_desc_panel:show()
    local cur_y_top = desc_y
    local has_banner = type(banner) == "string" and 0 < #banner
    if has_banner then
      if not banner:match("%.tga$") and not banner:match("%.blp$") then
        banner = banner .. ".tga"
      end
      local bw = 550
      local bh = 550
      local bx = 175
      local by = 49
      ui.list_banner:set_normal_image(banner)
      if ui.list_banner.set_control_size then
        ui.list_banner:set_control_size(bw, bh)
      end
      ui.list_banner:set_position(bx, by)
      ui.list_banner:show()
      cur_y_top = by
    else
      ui.list_banner:hide()
    end
    local opt_w = cfg.list_opt_w or cfg.panel_w - 2 * side
    local opt_h = cfg.list_opt_h or 40
    local gap = cfg.list_opt_gap or 10
    local y_start = 574
    for i = 1, 5 do
      local b = ui.list_opts[i]
      b.sync_data = round_token
      if count >= i then
        local opt = opts_list[i]
        local ox = 765
        local oy = y_start - (i - 1) * (opt_h + gap)
        if b.set_control_size then
          b:set_control_size(opt_w, opt_h)
        end
        b:set_position(ox, oy)
        b._index = i
        b:add_cd_animation(0, 0, 1, 1)
        b:set_cd(SYNC_BUTTON_CD, SYNC_BUTTON_CD)
        b._label:set_text(opt.text or "选项 " .. i)
        if b._label.set_control_size then
          b._label:set_control_size(opt_w - 24, 1)
        end
        b:show()
      else
        b:hide()
      end
    end
    ui.list_container:show()
    local last_opt_y = y_start - (count - 1) * (opt_h + gap)
    local skip_y = math.max(bottom_margin, last_opt_y - cfg.skip_h - 10)
    ui.minimize:show()
    RLChoice._dtype = "list"
    RLChoice._items = #items
    if isshownow then
      RLChoice._expand()
    else
      RLChoice._collapse()
      ui.minimize_gantan:show()
    end
  end
  
  function RLChoice.open(items_or_data, opts)
    local u = opts.u
    local mode = opts.layout or "cards"
    if u:hasdata("系统-正在选择选项") then
      _queue_push(u, items_or_data, opts)
      return
    end
    if u:islocal() then
      RLChoice._anim_stop_all()
      RLChoice._session.active = false
      RLChoice._hide_all()
      RLChoice._ui.showg = nil
      uiy_hide()
    end
    u:setdata("系统-正在选择选项")
    if mode == "list" then
      enter_list(items_or_data, opts)
    else
      enter_cards(items_or_data, opts)
    end
  end
end

function RLChoose(u, data, eventtype, isshownow)
  if isshownow == nil then
    isshownow = true
  end
  eventtype = eventtype or "cards"
  ac.wait(1, function()
    if eventtype == "list" then
      RLChoice.open(data, {
        u = u,
        layout = "list",
        isshownow = isshownow
      })
      return
    end
    RLChoice.open(data, {
      u = u,
      layout = "cards",
      isshownow = isshownow
    })
  end)
end

function RLCShowchange(u)
  if u:islocal() then
    if RLChoice._ui.panel:get_is_show() then
      RLChoice._collapse()
    else
      RLChoice._expand()
    end
  end
end

local function _normalize_icon(path)
  if not path or path == "" then
    return "war3mapImported\\Black.blp"
  end
  path = tostring(path):gsub("/", "\\")
  if not path:match("%.tga$") and not path:match("%.blp$") then
    path = path .. ".blp"
  end
  return path
end

local function _clean_ubertip(s)
  s = tostring(s or "")
  local cut = s:find(",Data[%a]+%d+")
  if cut then
    s = s:sub(1, cut - 1)
  end
  local cut = s:find(",Dur%d+")
  if cut then
    s = s:sub(1, cut - 1)
  end
  s = s:gsub("|n", "\n")
  s = s:gsub("\r", "")
  return s
end

local function build_option_from_itemtype(itemtype, extra)
  local t = slk.item[itemtype]
  if not t then
    return {
      icon = "war3mapImported\\Black.blp",
      title = ("未知物品(%s)"):format(tostring(itemtype)),
      text = "未在 slk.item 中找到该物品。",
      func = function(u)
      end
    }
  end
  local icon = _normalize_icon(t.Art)
  local title = tostring(t.Name or "")
  local text = _clean_ubertip(t.Ubertip)
  local opt = {
    icon = icon,
    title = title,
    text = text,
    func = function(u)
      u:additem(itemtype)
      if itemtype == "I00R" then
        u:additem(itemtype)
      end
    end
  }
  if extra then
    for k, v in pairs(extra) do
      opt[k] = v
    end
  end
  return opt
end

local function build_options_from_list(item_list)
  local out = {}
  out.options = {}
  for i, it in ipairs(item_list or {}) do
    if type(it) == "table" and it.id then
      table.insert(out.options, build_option_from_itemtype(it.id, it.extra))
    else
      table.insert(out.options, build_option_from_itemtype(it, nil))
    end
  end
  return out
end

function Make_cards_items(item_list)
  return build_options_from_list(item_list)
end

function Make_list_data(item_list, banner, desc)
  return {
    banner = banner or "war3mapImported\\Black.blp",
    desc = desc or "",
    options = build_options_from_list(item_list)
  }
end

function sample_unique(t, n)
  local seen, arr = {}, {}
  for _, v in ipairs(t or {}) do
    if not seen[v] then
      seen[v] = true
      arr[#arr + 1] = v
    end
  end
  local len = #arr
  if n >= len then
    return arr
  end
  local rand = type(GetRandomInt) == "function" and function(a, b)
    return GetRandomInt(a, b)
  end or function(a, b)
    return math.random(a, b)
  end
  for i = len, 2, -1 do
    local j = rand(1, i)
    arr[i], arr[j] = arr[j], arr[i]
  end
  local out = {}
  for i = 1, n do
    out[i] = arr[i]
  end
  return out
end
