-- 만화경의 모듈 로딩과 기본 이미지·텍스트 UI를 헤라 JN 프레임 및 입력 경로에 연결한다.
local M = {version = 'v3', status = 'not started', errors = {}, modules = {}, limitations = {}}
local common = require('jass.common')
local japi = require('jass.japi')
local globals = require('jass.globals')
local runtime = require('jass.runtime')
local native_require, native_xpcall = require, xpcall
local env = _G
local log_path = 'Logs/Hera_Wanhua_v3.txt'
local ui, bindings, frame_counter, draw_counter, epoch = {}, {}, 0, 0, 0
local records = setmetatable({}, {__mode = 'k'})
local frame_records, owned_frames = setmetatable({}, {__mode = 'v'}), {}
local resources = {}
local frame_metadata = {}
local handle_kinds = {}
local font = 'fonts3.ttf'
local last_tick, tick_rate = nil, 0

function M.note(text)
    local file = io.open(log_path, 'ab')
    if file then file:write(tostring(text), '\n'); file:close() end
end

function M.error(err)
    local message = tostring(err)
    if not M.errors[message] then
        M.errors[message] = true
        M.status = 'BLOCKED'
        M.note('ERROR ' .. message .. '\n' .. debug.traceback())
    end
    return message
end

local function limitation(name)
    if not M.limitations[name] then
        M.limitations[name] = true
        M.note('LIMITATION ' .. name)
    end
end

function M.enter(id)
    M.modules[#M.modules + 1] = id
    M.note('MODULE ' .. id)
end

function M.model_info(cache)
    for _, item in pairs(cache) do
        if type(item) == 'table' then
            for _, seq in ipairs(item) do
                if type(seq) == 'table' and seq.short_name then item[seq.short_name] = item[seq.short_name] or seq end
            end
        end
    end
    return function(path, refresh)
        local name = path:lower()
        if not refresh then
            local found = cache[name] or cache[name:gsub('l$', 'x')] or cache[name:gsub('x$', 'l')]
            if found then return found end
        end
        local storm = native_require('jass.storm')
        local data = storm.load(path) or storm.load(path:gsub('l$', 'x'))
        local item = {path = name}
        cache[name] = item
        if not data or data:sub(1, 4) ~= 'MDLX' then
            limitation('model animation metadata missing: ' .. name)
            return item
        end
        local offset = 5
        while offset + 7 <= #data do
            local tag = data:sub(offset, offset + 3)
            local size = string.unpack('<I4', data, offset + 4)
            assert(offset + 7 + size <= #data, 'Invalid MDX chunk: ' .. name)
            if tag == 'SEQS' then
                assert(size % 132 == 0, 'Invalid MDX sequences: ' .. name)
                for p = offset + 8, offset + 7 + size, 132 do
                    local title = data:sub(p, p + 79):match('^[^%z]*'):match('^%s*(.-)%s*$')
                    local first, last = string.unpack('<I4I4', data, p + 80)
                    local short = (title:match('^(%g*)') or ''):lower()
                    local seq = {id = #item, name = title, short_name = short, time = last - first}
                    item[#item + 1] = seq
                    item[short] = item[short] or seq
                end
            end
            offset = offset + 8 + size
        end
        return item
    end
end

function M.attach(values, indices)
    env = setmetatable({}, {
        __index = function(_, name)
            local i = indices[name]
            if i then return values[i] end
            return _G[name]
        end,
        __newindex = function(_, name, value)
            local i = indices[name]
            if i then values[i] = value else rawset(_G, name, value) end
        end,
    })
    M.env = env
    values[indices.xpcall] = function(fn, handler, ...)
        local result = table.pack(native_xpcall(fn, function(err)
            M.error(err)
            return handler and handler(err) or err
        end, ...))
        return table.unpack(result, 1, result.n)
    end
    values[indices.BJDebugMsg] = M.note
    env.register_japi = function(declarations)
        for name in declarations:gmatch('native%s+(%w+)') do
            if type(japi[name]) ~= 'function' and type(common[name]) ~= 'function' then
                limitation('optional native declaration unavailable: ' .. name)
            end
        end
    end
end

local function bind()
    local specs = native_require('hera_bindings')
    for _, spec in ipairs(specs) do
        local name, operation, result, args = spec[1], spec[2], spec[3], spec[4]
        bindings[name] = function(...)
            assert(not globals.HWBusy, 'Nested UI bridge call: ' .. name)
            globals.HWBusy = true
            local values = table.pack(...)
            if name == 'DzFrameSetTexture' then values[2] = M.resolve_texture(values[2]) end
            local ok, value = pcall(function()
                globals.HWOperation = operation
                globals.HWCompleted = false
                for i, field in ipairs(args) do
                    local arg = values[i]
                    if field:match('^String') then arg = tostring(arg or '') end
                    globals['HW' .. field] = arg
                end
                common.TriggerEvaluate(globals.HWEvaluator)
                assert(globals.HWCompleted, 'UI bridge did not complete: ' .. name)
                if name == 'DzFrameSetText' or name == 'DzFrameSetFont' or name == 'DzFrameSetSize' then
                    local meta = frame_metadata[values[1]] or {}
                    frame_metadata[values[1]] = meta
                    if name == 'DzFrameSetText' then meta.text = values[2]
                    elseif name == 'DzFrameSetSize' then meta.width, meta.height = values[2], values[3]
                    else meta.font_size = values[3] end
                elseif name == 'DzFrameShow' then
                    local meta = frame_metadata[values[1]] or {}
                    frame_metadata[values[1]] = meta; meta.visible = values[2]
                elseif name == 'DzDestroyFrame' then frame_metadata[values[1]] = nil end
                if result ~= 'nothing' then return globals['HW' .. result .. 'Result'] end
            end)
            globals.HWBusy = false
            if not ok then error(value, 2) end
            return value
        end
    end
end

local function native(name, ...)
    local fn = bindings[name] or japi[name] or common[name]
    assert(type(fn) == 'function', 'HERA_MISSING_NATIVE: ' .. name)
    return fn(...)
end

local function screen()
    local width = native('DzGetWindowWidth')
    local height = native('DzGetWindowHeight')
    return math.max(1, width), math.max(1, height)
end

local function text_width(text, size)
    local width = 0
    text = tostring(text or ''):gsub('|c%x%x%x%x%x%x%x%x', ''):gsub('|r', '')
    for _, cp in utf8.codes(text) do width = width + (cp < 128 and 0.55 or 1) end
    return width * (size or 16)
end

local gl = {}
function gl.get_screen_width() local w = screen(); return w end
function gl.get_screen_height() local _, h = screen(); return h end
function gl.get_elpased_time() return 1000 / 30 end
function gl.get_resource(path)
    if type(path) ~= 'string' or path == '' then return nil end
    local key = path:gsub('/', '\\'):lower()
    if not resources[key] then
        local manifest = native_require('hera_assets')
        resources[key] = manifest[key] or {path = path, width = 0, height = 0}
    end
    return resources[key]
end
function M.resolve_texture(path)
    local resource = gl.get_resource(path)
    return resource and resource.path or path or ''
end

local crop_counter = 0
function M.crop_texture(source, target, x, y, width, height)
    local resource = gl.get_resource(source)
    local storm = native_require('jass.storm')
    local data = resource and storm.load(resource.path)
    local output = resource
    if data and #data >= 18 and data:byte(3) == 2 and data:byte(17) == 32 and data:byte(18) == 0x28 then
        local sw, sh = string.unpack('<I2I2', data, 13)
        assert(width > 0 and height > 0 and x >= 0 and y >= 0 and x + width <= sw and y + height <= sh, 'Invalid UI crop rectangle')
        local rows = {string.pack('<BBBBBBBBBBBBI2I2BB',0,0,2,0,0,0,0,0,0,0,0,0,width,height,32,0x28)}
        for row = y, y + height - 1 do
            local start = 19 + (row * sw + x) * 4
            rows[#rows + 1] = data:sub(start, start + width * 4 - 1)
        end
        crop_counter = crop_counter + 1
        local path = 'HeraWanhua\\crop_v1_' .. crop_counter .. '.tga'
        assert(storm.save(path, table.concat(rows)), 'Failed to save UI crop')
        output = {path = path, width = width, height = height}
    else
        limitation('UI crop source unavailable; full icon retained: ' .. tostring(source))
    end
    resources[target:gsub('/', '\\'):lower()] = output
    return output ~= nil
end
function gl.create_program(vertex, fragment)
    return {vertex = vertex, fragment = fragment, uniforms = {}}
end
function gl.register_uniform(program, name, kind, value) program.uniforms[name] = value end
function gl.set_font(path) font = path end
function gl.set_callback(...) M.render_callbacks = {...} end
function gl.get_framebuffer() limitation('framebuffer preview'); return {} end
function gl.create_video_player() error('HERA_UNSUPPORTED_VIDEO: embedded video player') end

function ui.create()
    local record = {x = 0, y = 0, width = 0, height = 0, attributes = {render_type = 2}, last = {}}
    records[record] = true
    return record
end
function ui.set_attribute(record, name, value) record.attributes[name] = value end
function ui.set_position(record, x, y) record.x, record.y = x, y end
function ui.set_size(record, width, height) record.width, record.height = width, height end
function ui.set_rotate(record, x, y, z)
    if x ~= 0 or y ~= 0 or z ~= 0 then limitation('3D UI rotation') end
end
function ui.set_uv(record, x, y, width, height)
    record.uv = {x, y, width, height}
    if x ~= 0 or y ~= 0 or width ~= 1 or height ~= 1 then limitation('texture UV crop') end
end
function ui.is_in_region(record, x, y)
    return x >= record.x and y >= record.y and x <= record.x + record.width and y <= record.y + record.height
end
function ui.get_mouse_x() return native('DzGetMouseXRelative') end
function ui.get_mouse_y() return native('DzGetMouseYRelative') end
function ui.get_text_width_of_size(text, size) return text_width(text, size) end
function ui.get_text_width(record) return text_width(record.attributes.text, record.height) end
function ui.get_element_size(record) return record.width, record.height end
function ui.scissor(x, y, width, height, enabled)
    if enabled then M.clip = {x, y, width, height} else M.clip = nil end
end

local function changed(record, key, value, callback)
    if record.last[key] ~= value then callback(value); record.last[key] = value end
end

function ui.render(record)
    local attrs = record.attributes
    if attrs.render_type == 2 then return end
    assert(attrs.render_type ~= 3, 'HERA_UNSUPPORTED_VIDEO: UI video element')
    local kind = attrs.render_type == 1 and 'TEXT' or 'BACKDROP'
    if not record.frame then
        frame_counter = frame_counter + 1
        record.frame = native('DzCreateFrameByTagName', kind, 'HW' .. frame_counter, native('DzGetGameUI'), '', 0)
        assert(record.frame ~= 0, 'HERA_FRAME_CREATE_FAILED: ' .. kind)
        native('DzFrameSetEnable', record.frame, false)
        frame_records[record.frame], owned_frames[record.frame] = record, true
    end
    local width, height = screen()
    local x, y, w, h = record.x, record.y, record.width, record.height
    local visible = w >= 0 and h > 0
    if M.clip then
        local cx, cy, cw, ch = table.unpack(M.clip)
        cy = height - cy - ch
        visible = visible and x + w > cx and y + h > cy and x < cx + cw and y < cy + ch
    end
    record.epoch = epoch
    draw_counter = draw_counter + 1
    changed(record, 'position', x .. ':' .. y .. ':' .. width .. ':' .. height, function()
        native('DzFrameClearAllPoints', record.frame)
        native('DzFrameSetAbsolutePoint', record.frame, 0, x / width * 0.8, 0.6 - y / height * 0.6)
    end)
    changed(record, 'size', w .. ':' .. h .. ':' .. width .. ':' .. height, function()
        native('DzFrameSetSize', record.frame, math.max(w, 1) / width * 0.8, h / height * 0.6)
    end)
    changed(record, 'order', draw_counter, function(v) native('DzFrameSetPriority', record.frame, v) end)
    changed(record, 'alpha', math.floor(math.max(0, math.min(1, attrs.u_alpha or 1)) * 255),
        function(v) native('DzFrameSetAlpha', record.frame, v) end)
    if kind == 'TEXT' then
        changed(record, 'text', tostring(attrs.text or ''), function(v) native('DzFrameSetText', record.frame, v) end)
        changed(record, 'font', font .. ':' .. h .. ':' .. height, function() native('DzFrameSetFont', record.frame, font, h / height * 0.6, 0) end)
        changed(record, 'color', (attrs.color or 0xffffffff) | 0xff000000, function(v) native('DzFrameSetTextColor', record.frame, v) end)
    else
        local resource = attrs.resource
        if attrs.resource2 and attrs.program and attrs.program.fragment:find('mix(texture2D', 1, true) and (attrs.u_progress or 0) > 0.5 then resource = attrs.resource2 end
        local path = resource and resource.path or 'UI\\Widgets\\EscMenu\\Human\\blank-background.blp'
        changed(record, 'texture', path, function(v) native('DzFrameSetTexture', record.frame, v, 0) end)
    end
    changed(record, 'visible', visible, function(v) native('DzFrameShow', record.frame, v) end)
end

local sound = {}
function sound.get_sound(path) return path end
function sound.create_buffer(path) return common.CreateSound(path, false, false, false, 10, 10, '') end
function sound.set_volume(handle, volume) common.SetSoundVolume(handle, math.floor(math.max(0, math.min(1, volume)) * 127)) end
function sound.play(handle) common.StartSound(handle) end
function sound.stop(handle) common.StopSound(handle, false, false) end
function sound.release(handle) common.KillSoundWhenDone(handle) end
function sound.is_playing(handle) return common.GetSoundIsPlaying(handle) end
local hack = {}
function hack.get_skill_button(index) return native('DzFrameGetCommandBarButton', math.floor(index / 4), index % 4) end
function hack.click_button(frame) return native('DzClickFrame', frame) end

function M.library(name)
    if name == 'opengl' then return gl end
    if name == 'ui' then return ui end
    if name == 'sound' then return sound end
    if name == 'hack' then return hack end
    error('HERA_MISSING_LIBRARY: ' .. tostring(name))
end

function M.platform()
    env.get_war3_commandline = function() return '' end
    env.is_load_dll = function() return false end
    env.isWindowZoomed = function() return nil end
    env.isWindowIconic = function() return nil end
    env.getScreenSize = screen
    env.calculateWindowPosition = function(w, h) return 0, 0, w, h end
    for _, name in ipairs({'OpenUrl', 'Shell', 'setClipboard', 'maximizeWindow', 'unmaximizeWindow'}) do
        env[name] = function() limitation(name .. ' unavailable in map adapter') end
    end
end

function M.chat_input()
    env.UI.move_chat_box = function() limitation('chat input keeps native placement') end
end

function M.plugins()
    -- JN Lua의 로그·MPQ 경로는 UTF-8 문자열을 그대로 사용한다.
    env.Plugins = {unicode = {u2a = function(s) return s end, a2u = function(s) return s end}}
    limitation('Chinese process memory and development reload plugins excluded')
end

function M.window()
    local result = {GetTopWindowSize = function() local w, h = screen(); return {width = w, height = h} end}
    for _, name in ipairs({'OffsetWindow', 'ClickWindowButtons', 'SetWindowedMaxWorkArea', 'SetWindowed', 'SetBorderless'}) do
        result[name] = function() limitation(name .. ' uses launcher window settings'); return false end
    end
    return result
end

function M.scenery()
    local result = {}
    for _, name in ipairs({'init', 'log_memory', 'update_view_area', 'remove_view_area', 'register_debug_event'}) do
        result[name] = function() limitation('native map scenery retained; dynamic doodad culling unavailable') end
    end
    result.get_doodad_info = function() return nil end
    result.get_doodad_count = function() return 0 end
    return result
end

function M.chat_key(key)
    if key == 13 then M.chat_open = not M.chat_open elseif key == 27 then M.chat_open = false end
    return ''
end

function M.key_input(kind, key)
    M.trigger_key = key
    if kind == 7 then M.chat_key(key) end
    M.input(kind)
    M.trigger_key = nil
    return ''
end

local ability_dummy, ability_templates = nil, {}
function M.ability_template(id)
    if ability_templates[id] then return ability_templates[id] end
    if not ability_dummy then
        ability_dummy = common.CreateUnit(common.Player(15), string.unpack('>I4', 'hfoo'), 0, 0, 0)
        assert(ability_dummy and ability_dummy ~= 0, 'Ability template helper unit creation failed')
        common.UnitAddAbility(ability_dummy, string.unpack('>I4', 'Aloc'))
        common.SetUnitInvulnerable(ability_dummy, true)
        common.PauseUnit(ability_dummy, true)
        common.ShowUnit(ability_dummy, false)
        native_require('jass.debug').handle_ref(ability_dummy)
    end
    local code = string.unpack('>I4', id)
    common.UnitAddAbility(ability_dummy, code)
    local handle = native('EXGetUnitAbility', ability_dummy, code)
    ability_templates[id] = handle
    env.game.wait(0, function()
        common.SetUnitAbilityLevel(ability_dummy, code, 2)
        common.SetUnitAbilityLevel(ability_dummy, code, 1)
        common.UnitRemoveAbility(ability_dummy, code)
        ability_templates[id] = nil
    end)
    return handle
end

function M.input(kind)
    local fn = _G.WindowEventCallBack
    if fn then native_xpcall(function() fn(kind, 0, 0) end, M.error) end
    return ''
end

function M.tick()
    if M.status == 'not started' then return '' end
    epoch, draw_counter = epoch + 1, 0
    local time = os.clock()
    if last_tick and time > last_tick then tick_rate = 1 / (time - last_tick) end
    last_tick = time
    native_xpcall(function()
        M.input(10)
        if env.new_sound then env.new_sound.sound_update() end
        if env.newui then
            env.newui.render_gui()
            env.newui.render_gui2()
        end
        for record in pairs(records) do
            if record.frame and record.epoch ~= epoch then
                changed(record, 'visible', false, function(v) native('DzFrameShow', record.frame, v) end)
            end
        end
        for handle in pairs(owned_frames) do
            if not frame_records[handle] then native('DzDestroyFrame', handle); owned_frames[handle] = nil end
        end
    end, M.error)
    runtime.error_handle = M.error
    if M.status == 'BLOCKED' and not M.reported_error then M.reported_error = true; return M.summary() end
    return ''
end

function M.summary()
    local first = next(M.errors)
    return 'Wanhua 0.175 Hera TEST ' .. M.version .. '\n' .. M.status .. '\n임시 세션 / 서버 저장 미지원' ..
        '\nModules: ' .. #M.modules .. ' / frames: ' .. frame_counter ..
        (first and '\n' .. first:sub(1, 220) or '')
end

function M.start()
    if M.status ~= 'not started' then return M.summary() end
    M.status = 'initializing'
    local slot = common.GetPlayerId(common.GetLocalPlayer()) + 1
    log_path = 'Logs/Hera_Wanhua_v3_p' .. slot .. '.txt'
    local file = io.open(log_path, 'wb'); if file then file:close() end
    M.note('Wanhua v0.175 Hera v3 / ' .. _VERSION)
    runtime.handle_level, runtime.sleep, runtime.error_handle = 0, false, M.error
    local console = native_require('jass.console')
    console.enable = false
    console.write = function(...)
        local items = {}
        for i = 1, select('#', ...) do items[i] = tostring(select(i, ...)) end
        M.note(table.concat(items, ' '))
    end
    local ok = native_xpcall(function()
        bind()
        local has_code = pcall(native_require, 'jass.code')
        if not has_code then
            local code = {}
            for _, name in ipairs({'get_player_name', 'YDWERPGBillingGetItem', 'YDWERPGBillingHasStatus', 'YDWERPGBillingHasItem'}) do
                code[name] = assert(bindings[name], 'Missing map JASS bridge: ' .. name)
            end
            package.preload['jass.code'] = function() return code end
            limitation('jass.code uses the map JASS dispatcher')
        end
        for _, spec in ipairs({{'CreateUnit', 'unit'}, {'CreateUnitAtLoc', 'unit'}, {'CreateItem', 'item'},
                {'AddSpecialEffect', 'effect'}, {'AddSpecialEffectTarget', 'effect'}}) do
            local name, kind, original = spec[1], spec[2], common[spec[1]]
            rawset(common, name, function(...)
                local handle = original(...)
                if handle and handle ~= 0 then handle_kinds[handle] = kind end
                return handle
            end)
        end
        for _, name in ipairs({'RemoveUnit', 'RemoveItem', 'DestroyEffect'}) do
            local original = common[name]
            rawset(common, name, function(handle) local result = original(handle); handle_kinds[handle] = nil; return result end)
        end
        for name, fn in pairs(bindings) do
            rawset(japi, name, fn)
            if name:sub(1, 2) == 'Dz' then rawset(japi, name:sub(3), fn) end
        end
        for _, name in ipairs({'SetOwner', 'SetFrameLimitScreen', 'UnlockFps', 'FrameSetViewPort'}) do
            if type(japi[name]) ~= 'function' then
                rawset(japi, name, function() limitation(name .. ' uses launcher defaults') end)
            end
        end
        for _, suffix in ipairs({'Speed', 'Color', 'Size', 'Scale', 'RotateX', 'RotateY', 'RotateZ',
                'XY', 'X', 'Y', 'Z', 'Texture', 'CameraSource', 'CameraTarget'}) do
            local name = 'FrameSetModel' .. suffix
            if type(japi[name]) ~= 'function' then
                rawset(japi, name, function() limitation('model preview transform: ' .. name) end)
            end
        end
        rawset(japi, 'FrameAddModel', function(parent)
            frame_counter = frame_counter + 1
            return native('DzCreateFrameByTagName', 'SPRITE', 'HWM' .. frame_counter, parent, '', 0)
        end)
        rawset(japi, 'FrameSetModel2', function(frame, path) return native('DzFrameSetModel', frame, path, 0, 0) end)
        rawset(japi, 'FrameGetTextWidth', function(frame)
            local meta = frame_metadata[frame] or {}
            limitation('text width uses estimated glyph metrics')
            return text_width(meta.text or native('DzFrameGetText', frame), (meta.font_size or 0.012) * 0.75)
        end)
        rawset(japi, 'FrameGetTextHeight', function(frame) return native('DzFrameGetHeight', frame) end)
        rawset(japi, 'FrameSetWidth', function(frame, width)
            return native('DzFrameSetSize', frame, width, (frame_metadata[frame] or {}).height or native('DzFrameGetHeight', frame))
        end)
        rawset(japi, 'FrameSetHeight', function(frame, height)
            return native('DzFrameSetSize', frame, (frame_metadata[frame] or {}).width or 0, height)
        end)
        rawset(japi, 'FrameGetWidth', function(frame) return (frame_metadata[frame] or {}).width or 0 end)
        rawset(japi, 'EXBlpRect', M.crop_texture)
        rawset(japi, 'GetMouseVectorX', function() local w = screen(); return ui.get_mouse_x() / w * 1024 end)
        rawset(japi, 'GetMouseVectorY', function() local _, h = screen(); return ui.get_mouse_y() / h * 768 end)
        rawset(japi, 'GetKeyState', function(key) return native('DzIsKeyDown', key) end)
        rawset(japi, 'GetTriggerKey', function() return M.trigger_key or native('DzGetTriggerKey') end)
        rawset(japi, 'GetChatState', function() return M.chat_open == true end)
        rawset(japi, 'FrameIsShow', function(frame) return (frame_metadata[frame] or {}).visible ~= false end)
        rawset(japi, 'SetUnitState', common.SetUnitState)
        rawset(japi, 'GetUnitState', common.GetUnitState)
        rawset(japi, 'GetRealSelectUnit', function() return native_require('jass.message').selection() end)
        rawset(japi, 'SetUnitModel', function(handle, path)
            if handle_kinds[handle] == 'unit' then return native('DzSetUnitModel', handle, path) end
            limitation('dynamic ' .. tostring(handle_kinds[handle] or 'unknown') .. ' model swap retained original: ' .. tostring(path))
        end)
        if type(japi.EXSetEffectColor) ~= 'function' then
            rawset(japi, 'EXSetEffectColor', function() limitation('effect tint unavailable') end)
        end
        rawset(japi, 'SetUnitPressUIVisible', function() limitation('native unit health bar visibility retained') end)
        rawset(japi, 'GetFps', function() limitation('performance counter reports adapter tick rate'); return math.floor(tick_rate) end)
        rawset(japi, 'GetUsedMemory', function() limitation('memory counter reports Lua heap only'); return math.floor(collectgarbage('count') / 1024) end)
        rawset(japi, 'ReleaseAllModel', function() limitation('model cache remains owned by JN') end)
        rawset(japi, 'UnBindEffect', function() limitation('native attachments are released when their effect is destroyed') end)
        if type(japi.EXSetEffectVisible) ~= 'function' then
            local hidden_size = {}
            rawset(japi, 'EXSetEffectVisible', function(effect, visible)
                if visible then
                    if hidden_size[effect] then japi.EXSetEffectSize(effect, hidden_size[effect]); hidden_size[effect] = nil end
                elseif not hidden_size[effect] then
                    hidden_size[effect] = japi.EXGetEffectSize(effect)
                    japi.EXSetEffectSize(effect, 0)
                end
            end)
            local destroy = common.DestroyEffect
            rawset(common, 'DestroyEffect', function(effect) hidden_size[effect] = nil; return destroy(effect) end)
        end
        rawset(japi, 'GetLoadingProgress', function() return 1 end)
        -- 기본 사운드 경로는 워크래프트 믹서가 마스터 음량을 이미 적용한다.
        rawset(japi, 'GetGlobalSoundVolume', function() return 100 end)
        rawset(japi, 'GetUserId', function() return 0 end)
        rawset(japi, 'GetUserIdEx', function() return 0 end)
        rawset(japi, 'RequestExtraStringData', function(kind, player)
            if kind == 81 then return common.GetPlayerName(player) end
            if kind == 93 then return '0' end
            return ''
        end)
        rawset(japi, 'RequestExtraIntegerData', function() return 0 end)
        rawset(japi, 'RequestExtraBooleanData', function() return false end)
        rawset(japi, 'RequestExtraRealData', function() return 0 end)
        rawset(japi, 'timer_start', os.clock)
        rawset(japi, 'timer_end', function(start) return os.clock() - start end)
        rawset(japi, 'timer_destroy', function() end)
        limitation('Chinese platform identity and cloud persistence unavailable')
        local message = native_require('jass.message')
        if not message.origin_load then message.origin_load = native_require('jass.storm').load end
        message.create_list = function() return {} end
        message.list_add = function(list, handle)
            for _, value in ipairs(list) do if value == handle then return end end
            list[#list + 1] = handle
        end
        message.list_remove = function(list, handle)
            for i, value in ipairs(list) do if value == handle then table.remove(list, i); return end end
        end
        message.list_enum_range = function(list, x, y, radius)
            local result = {}
            for _, handle in ipairs(list) do
                local mover = env.game.mover.mover_map[handle]
                if mover and not mover.removed then
                    local mx, my = mover.mover:get_point():get()
                    if (mx - x)^2 + (my - y)^2 <= radius^2 then result[#result + 1] = handle end
                end
            end
            return result
        end
        package.preload['jass.lni'] = function() return native_require('hera_lni') end
        package.preload['jass.dzapi'] = function() return japi end
        package.preload.mprender = function()
            local renderer = native_require('hera_render')(M)
            _G.render, env.render = renderer, renderer
            limitation('MDXS shaders and custom animation renderer unavailable')
            return renderer
        end
        native_require('run')
    end, M.error)
    if ok and M.status ~= 'BLOCKED' then M.status = 'initialized; gameplay unverified' end
    M.note(M.summary())
    return M.summary()
end

return M
