-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
do
  local text_width = require('hera_text_width')
  local function set_chat_text(frame, text)
    local korean = require('hera_korean')
    text = korean.translate(text)
    local size = frame._real_size or frame.font_size
    local font = korean.has_hangul(text) and korean.font or frame._hera_original_font or frame.font_path or 'Fonts\\gamefont.ttc'
    local wrapped = text_width.wrap(text, size, font, 1100)
    frame:set_text(wrapped)
    -- 엔진이 한 줄 높이를 반환해도 실제 출력 줄 수만큼 공간을 확보한다.
    local height = math.max(24, text_width.height(frame._hera_render_text or wrapped, size, frame.font_path or font))
    local changed = frame._hera_chat_height ~= height
    frame._hera_chat_height = height
    frame:set_control_size(1100, height)
    japi.FrameSetSize(frame._id, 1100 / 1920 * 0.8, height / 1080 * 0.6)
    return changed
  end
  local usefulbox = {}
  local usebox = {}
  local unusefulbox = {}
  local w, h = 88, 68
  local dx = 0.35
  local dw, dh = w * dx * 2, h * dx
  local cz = 5
  local CHAT_EMOJI_H = 68
  local CHAT_FADE_INTERVAL = 70
  local CHAT_FADE_ALPHA = 200
  local CHAT_FADE_STEP = 7
  
  local function createnewtextui()
    local newchaticon = class.panel:builder({
      parent = OriginPanel,
      x = cz,
      y = 0,
      w = dw,
      h = dh,
      normal_image = "ChatIcon (17).tga"
    })
    newchaticon:hide()
    newchaticon:set_level(2)
    local text = class.text:builder({
      parent = newchaticon,
      x = dw,
      w = 1100,
      h = 28,
      align = "topleft",
      text = " ",
      font_size = 13
    })
    text:set_level(0)
    text:hide()
    local text2 = class.text:builder({
      parent = newchaticon,
      x = dw,
      align = "topleft",
      text = "test"
    })
    text2:set_level(0)
    text2:set_size(0.75, "fontnm.ttf")
    text2:hide()
    local text3 = class.text:builder({
      parent = newchaticon,
      x = dw,
      align = "topleft",
      text = "test"
    })
    text3:set_level(0)
    text3:set_size(0.75, "fontxs.ttf")
    text3:hide()
    local dsize = 1.1
    local emoji = class.panel:builder({
      parent = newchaticon,
      x = dw,
      y = 0,
      w = w * dsize,
      h = h * dsize,
      normal_image = "Image_bqb_1.blp"
    })
    emoji:set_level(1)
    emoji:hide()
    table.insert(unusefulbox, {
      chaticon = newchaticon,
      frame = text,
      frame2 = text2,
      frame3 = text3,
      emoji = emoji,
      emoji_w = w * dsize,
      emoji_h = h * dsize,
      nowuse = nil,
      isemoji = false,
      endbj = false,
      emoji_anim_timer = nil,
      emoji_anim_index = nil,
      emoji_anim_frames = nil
    })
  end
  
  local ChatEmojiGap = 10
  local ChatEmojiFallbackNameWidth = 70
  
  local function get_chat_emoji_x(frame)
    local namew
    if frame and frame.get_width then
      local ok, w = pcall(function()
        return frame:get_width()
      end)
      if ok and type(w) == "number" and 0 < w then
        namew = w
      end
    end
    namew = namew or ChatEmojiFallbackNameWidth
    return dw + namew + ChatEmojiGap
  end
  
  local function remove_chat_from_list(t, chat)
    for i = #t, 1, -1 do
      if t[i] == chat then
        table.remove(t, i)
      end
    end
  end
  
  local function stop_chat_emoji_anim(chat)
    if chat and chat.emoji_anim_timer then
      chat.emoji_anim_timer:remove()
      chat.emoji_anim_timer = nil
    end
    if chat then
      chat.emoji_anim_index = nil
      chat.emoji_anim_frames = nil
      chat.emoji_needs_refresh = nil
    end
  end
  
  local function start_chat_emoji_anim(chat, emojiCfg)
    stop_chat_emoji_anim(chat)
    if not chat or not emojiCfg then
      return
    end
    if not emojiCfg.frames or #emojiCfg.frames <= 0 then
      if emojiCfg.path then
        chat.emoji:set_normal_image(emojiCfg.path)
      end
      return
    end
    local frames = emojiCfg.frames
    local interval = emojiCfg.interval or 30
    local loop = emojiCfg.loop ~= false
    local index = 1
    chat.emoji_anim_index = index
    chat.emoji_anim_frames = frames
    chat.emoji_needs_refresh = false
    chat.emoji:set_normal_image(frames[index])
    chat.emoji_anim_timer = ac.loop(interval, function(t)
      if chat.endbj or not chat.isemoji then
        t:remove()
        if chat.emoji_anim_timer == t then
          chat.emoji_anim_timer = nil
        end
        return
      end
      index = index + 1
      if index > #frames then
        if loop then
          index = 1
        else
          t:remove()
          if chat.emoji_anim_timer == t then
            chat.emoji_anim_timer = nil
          end
          return
        end
      end
      chat.emoji_anim_index = index
      if IsWindowActive() then
        chat.emoji:set_normal_image(frames[index])
        chat.emoji_needs_refresh = false
      else
        chat.emoji_needs_refresh = true
      end
    end)
  end
  
  local function get_chat_emoji_y(chat)
    local emoji_h = chat.emoji_show_h or CHAT_EMOJI_H
    return (dh - emoji_h) / 2
  end
  
  local function get_chat_item_height(chat)
    local text_h = chat.nowuse and chat.nowuse._hera_chat_height or 23.294
    if chat.nowuse and not chat.nowuse._hera_chat_height and chat.nowuse.get_height then
      local ok, h2 = pcall(function()
        return chat.nowuse:get_height()
      end)
      if ok and type(h2) == "number" and 0 < h2 then
        text_h = math.max(h2, 23.294)
      end
    end
    if chat.isemoji then
      return math.max(text_h, chat.emoji_show_h or CHAT_EMOJI_H)
    end
    return text_h
  end
  
  local function refresh_chat_position()
    local y = 700
    for i = #usebox, 1, -1 do
      local chat = usebox[i]
      local high = get_chat_item_height(chat)
      y = y - high - 4
      local py = y
      if chat.isemoji then
        py = y + (high - dh) / 2
      end
      chat.chaticon:set_position(cz, py)
    end
  end
  
  function UI_NewChatClear()
    for i = 1, #usebox do
      usebox[i].endbj = true
    end
  end
  
  function UI_SystemMessageClear()
    for i = #usebox, 1, -1 do
      local chat = usebox[i]
      if chat.system then
        if chat.fade_timer then chat.fade_timer:remove(); chat.fade_timer = nil end
        stop_chat_emoji_anim(chat)
        chat.chaticon:hide()
        chat.nowuse:hide()
        chat.emoji:hide()
        remove_chat_from_list(usebox, chat)
        remove_chat_from_list(usefulbox, chat)
        table.insert(unusefulbox, chat)
      end
    end
    refresh_chat_position()
  end

  local function parse_chat_emoji(msg)
    local id = string.match(msg or "", "^%[bqb:(%d+)%]$")
    if id then
      id = tonumber(id)
      return ChatEmojiMap[id], id
    end
    return nil, nil
  end
  
  local function render_new_chat(p, message, msg, time, elapsed, identity)
    time = time or 12000
    elapsed = elapsed or 0
    local initial_alpha = CHAT_FADE_ALPHA
    if time <= elapsed then
      local fade_count = math.floor((elapsed - time) / CHAT_FADE_INTERVAL) + 1
      initial_alpha = initial_alpha - fade_count * CHAT_FADE_STEP
      if initial_alpha <= 0 then
        return
      end
    end
    local chat
    if #unusefulbox == 0 then
      createnewtextui()
    end
    chat = table.remove(unusefulbox, 1)
    remove_chat_from_list(usefulbox, chat)
    remove_chat_from_list(usebox, chat)
    local frame
    if UI_Newchatfont == 1 then
      frame = chat.frame
    elseif UI_Newchatfont == 2 then
      frame = chat.frame2
    else
      frame = chat.frame3
    end
    chat.endbj = false
    chat.system = identity and identity.system or false
    chat.isemoji = false
    chat.expired_while_inactive = false
    chat.nowuse = frame
    stop_chat_emoji_anim(chat)
    local icon = identity and identity.icon or ChatIcon[p.id] or "ChatIcon (17).tga"
    chat.chaticon:set_normal_image(icon)
    table.insert(usefulbox, chat)
    table.insert(usebox, chat)
    if 13 < #usefulbox then
      local removechat = table.remove(usefulbox, 1)
      if removechat then
        removechat.endbj = true
      end
    end
    local showname = identity and identity.name or p:getname()
    if not identity and Boolean_ColorName[p.id] then
      showname = ShowName[p.id] or ""
    end
    frame:hide()
    chat.frame2:hide()
    chat.frame3:hide()
    chat.emoji:hide()
    local emojiCfg, emojiId = parse_chat_emoji(msg)
    if emojiCfg then
      chat.isemoji = true
      chat.nowuse = frame
      local prefix = string.format("%s%s|r:", p:getColorWord(), showname)
      frame.showtext = prefix
      set_chat_text(frame, prefix)
      frame:set_alpha(255)
      frame:show()
      chat.last_prefix_text = prefix
      local emoji_h = CHAT_EMOJI_H
      local emoji_w = math.floor(emoji_h * (emojiCfg.ratio or 1) + 0.5)
      chat.emoji_show_w = emoji_w
      chat.emoji_show_h = emoji_h
      chat.emoji_id = emojiId
      chat.emoji:set_width(emoji_w)
      chat.emoji:set_height(emoji_h)
      start_chat_emoji_anim(chat, emojiCfg)
      local ex = get_chat_emoji_x(frame)
      local ey = get_chat_emoji_y(chat)
      chat.last_emoji_x = ex
      chat.last_emoji_y = ey
      chat.emoji:set_position(ex, ey)
      chat.emoji:set_alpha(255)
      chat.emoji:show()
    else
      frame.showtext = msg
      message = identity and identity.system and frame.showtext or string.format("%s%s|r:%s", p:getColorWord(), showname, frame.showtext)
      set_chat_text(frame, message)
      frame:set_alpha(255)
      frame:show()
    end
    chat.chaticon:set_alpha(220)
    chat.chaticon:show()
    refresh_chat_position()
    local alpha = initial_alpha
    local cs = elapsed
    local originname = showname
    if time <= cs then
      chat.chaticon:set_alpha(alpha)
      frame:set_alpha(alpha)
      if chat.isemoji then
        chat.emoji:set_alpha(alpha)
      end
    end
    chat.fade_timer = ac.loop(CHAT_FADE_INTERVAL, function(t)
      cs = cs + CHAT_FADE_INTERVAL
      local window_active = IsWindowActive()
      if chat.expired_while_inactive then
        if not window_active then
          return
        end
        chat.chaticon:hide()
        frame:hide()
        chat.emoji:hide()
        stop_chat_emoji_anim(chat)
        remove_chat_from_list(usebox, chat)
        remove_chat_from_list(usefulbox, chat)
        table.insert(unusefulbox, chat)
        refresh_chat_position()
        t:remove()
        return
      end
      if window_active then
        if identity then
          showname = originname
        else
          showname = p:getname()
          if Boolean_ColorName[p.id] then
            showname = ShowName[p.id] or ""
          end
        end
        if chat.isemoji then
          if chat.emoji_needs_refresh and chat.emoji_anim_frames and chat.emoji_anim_index then
            chat.emoji:set_normal_image(chat.emoji_anim_frames[chat.emoji_anim_index])
            chat.emoji_needs_refresh = false
          end
          local prefix = string.format("%s%s|r:", p:getColorWord(), showname)
          frame.showtext = prefix
          set_chat_text(frame, prefix)
          if prefix ~= chat.last_prefix_text then
            chat.last_prefix_text = prefix
            local ex = get_chat_emoji_x(frame)
            local ey = get_chat_emoji_y(chat)
            if ex ~= chat.last_emoji_x or ey ~= chat.last_emoji_y then
              chat.last_emoji_x = ex
              chat.last_emoji_y = ey
              chat.emoji:set_position(ex, ey)
            end
          end
        else
          message = identity and identity.system and frame.showtext or string.format("%s%s|r:%s", p:getColorWord(), showname, frame.showtext)
          if set_chat_text(frame, message) then
            refresh_chat_position()
          end
        end
      end
      if cs >= time or chat.endbj then
        alpha = alpha - CHAT_FADE_STEP
        if 0 < alpha then
          if window_active then
            chat.chaticon:set_alpha(alpha)
            if chat.isemoji then
              frame:set_alpha(alpha)
              chat.emoji:set_alpha(alpha)
            else
              frame:set_alpha(alpha)
            end
          end
        else
          if not window_active then
            chat.expired_while_inactive = true
            stop_chat_emoji_anim(chat)
            return
          end
          chat.chaticon:hide()
          frame:hide()
          chat.emoji:hide()
          stop_chat_emoji_anim(chat)
          remove_chat_from_list(usebox, chat)
          remove_chat_from_list(usefulbox, chat)
          table.insert(unusefulbox, chat)
          refresh_chat_position()
          t:remove()
        end
      end
    end)
    return chat.nowuse
  end
  
  -- 시스템 조회 결과도 숨겨진 기본 메시지 프레임 대신 같은 채팅 영역에 표시한다.
  function UI_SystemMessage(player, text, time)
    if player ~= GetLocalPlayer() or text == nil or text == '' then return end
    local p = getplayer(player)
    return render_new_chat(p, text, tostring(text), (time or 10) * 1000, 0,
      {name='', icon='core\\Transparent.tga', system=true})
  end
  local pending_chat = {}
  local MAX_PENDING_CHAT = 13
  
  local function flush_pending_chat()
    if not IsWindowActive() or #pending_chat == 0 then
      return
    end
    local queue = pending_chat
    pending_chat = {}
    local now = ac.clock()
    for _, data in ipairs(queue) do
      local elapsed = math.max(0, now - data.queued_at)
      render_new_chat(data.p, data.message, data.msg, data.time, elapsed, data.identity)
    end
  end
  
  function UI_NewChat(p, message, msg, time, target_sy)
    if target_sy and target_sy ~= LocalPlayerID then
      return
    end
    local identity
    if p.id == 16 then
      identity = {
        name = p:getname(),
        icon = ChatIcon[p.id] or "ChatIcon (17).tga"
      }
    end
    if not IsWindowActive() then
      table.insert(pending_chat, {
        p = p,
        message = message,
        msg = msg,
        time = time,
        queued_at = ac.clock(),
        identity = identity
      })
      if #pending_chat > MAX_PENDING_CHAT then
        table.remove(pending_chat, 1)
      end
      return
    end
    flush_pending_chat()
    return render_new_chat(p, message, msg, time, nil, identity)
  end
  
  -- 표시 전용 오류는 기록만 남기고 호출자의 공유 게임 처리를 계속한다.
  local chat_errors = 0
  local function protect_chat_display(func)
    return function(...)
      local ok, result = pcall(func, ...)
      if ok then return result end
      chat_errors = chat_errors + 1
      if chat_errors <= 8 then
        local boot = package.loaded["hera_boot"]
        if boot and boot.note then
          pcall(boot.note, "CHAT DISPLAY ERROR v138 (contained) = " .. tostring(result), true)
        end
      end
      return nil
    end
  end
  UI_SystemMessage = protect_chat_display(UI_SystemMessage)
  UI_NewChat = protect_chat_display(UI_NewChat)
  flush_pending_chat = protect_chat_display(flush_pending_chat)

  ac.loop(100, function()
    flush_pending_chat()
  end)
end
