-- 만화경 구형 LNI의 기본값·열거값·부모 상속을 순수 Lua로 읽는다.
local function clone(value)
    if type(value) ~= 'table' then return value end
    local out = {}
    for k, v in pairs(value) do out[k] = clone(v) end
    return out
end

return function(source, filename, previous)
    previous = previous or {}
    local data, defaults, enum = previous[1] or {}, clone(previous[2] or {}), clone(previous[3] or {})
    source = source:gsub('^\239\187\191', ''):gsub('\r\n', '\n'):gsub('\r', '\n')
    local p, n, section = 1, #source, data
    local function fail(text)
        local _, line = source:sub(1, p):gsub('\n', '')
        error((filename or 'LNI') .. ':' .. (line + 1) .. ': ' .. text, 0)
    end
    local function at() return source:sub(p, p) end
    local function skip()
        while p <= n do
            local _, last = source:find('^%s+', p)
            if last then p = last + 1
            elseif source:sub(p, p + 1) == '--' or source:sub(p, p + 1) == '//' or at() == ';' then
                p = (source:find('\n', p, true) or n) + 1
            else break end
        end
    end
    local function quoted()
        local first, quote = p, at()
        p = p + 1
        while p <= n do
            if at() == '\\' then p = p + 2
            elseif at() == quote then
                p = p + 1
                local fn, err = load('return ' .. source:sub(first, p - 1), '=LNI string', 't', {})
                if not fn then fail(err) end
                return fn()
            else p = p + 1 end
        end
        fail('unterminated string')
    end
    local function long_string()
        local eq = source:match('^%[(=*)%[', p)
        if not eq then fail('invalid long string') end
        local first = p + #eq + 2
        local last, finish = source:find(']' .. eq .. ']', first, true)
        if not last then fail('unterminated long string') end
        p = finish + 1
        return source:sub(first, last - 1):gsub('^\n', '')
    end
    local value
    local function atom(stops)
        if at() == "'" or at() == '"' then return quoted() end
        if source:match('^%[=*%[', p) then return long_string() end
        local first = p
        while p <= n and not at():match(stops) do
            if source:sub(p, p + 1) == '--' or source:sub(p, p + 1) == '//' then break end
            p = p + 1
        end
        local word = source:sub(first, p - 1):match('^%s*(.-)%s*$')
        if word == '' then fail('expected value') end
        if word == 'true' then return true end
        if word == 'false' then return false end
        if word == 'nil' then return nil end
        if tonumber(word) then return tonumber(word) end
        return word
    end
    value = function(in_table)
        skip()
        if at() ~= '{' then
            local first = at()
            local result = atom(in_table and '[,}\n=]' or '[\n]')
            if first ~= "'" and first ~= '"' and first ~= '[' and enum[result] ~= nil then return clone(enum[result]) end
            return result
        end
        local out, index = {}, 1
        p = p + 1
        skip()
        while at() ~= '}' do
            if p > n then fail('unterminated table') end
            local first = value(true)
            skip()
            if at() == '=' then
                p = p + 1
                out[first] = value(true)
            else
                out[index], index = first, index + 1
            end
            skip()
            if at() == ',' then p = p + 1; skip()
            elseif at() ~= '}' then fail('expected comma or table end') end
        end
        p = p + 1
        return out
    end
    skip()
    while p <= n do
        if at() == '[' or at() == '<' then
            local closing = at() == '[' and ']' or '>'
            p = p + 1; skip()
            local name = atom('[:%]>]')
            skip()
            local parent
            if at() == ':' then
                p = p + 1; skip()
                local parent_name = atom('[%]>]')
                parent = data[parent_name]
                if not parent then fail('missing parent ' .. tostring(parent_name)) end
            end
            skip()
            if at() ~= closing then fail('expected section end') end
            p = p + 1
            if name == 'default' then
                defaults = {}; section = defaults
            elseif name == 'enum' then
                enum = {}; section = enum
            else
                section = clone(parent or defaults)
                data[name] = section
            end
        else
            local key = atom('[=\n]')
            skip()
            if at() ~= '=' then fail('expected assignment') end
            p = p + 1
            section[key] = value(false)
        end
        skip()
    end
    return data, defaults, enum
end
