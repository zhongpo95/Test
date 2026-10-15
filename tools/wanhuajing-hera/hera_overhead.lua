-- 전용 머리 위 좌표 API가 없을 때 모델 경계 높이로 체력바 위치를 근사한다.
return function(port)
    local common, storm = require('jass.common'), require('jass.storm')
    local heights = {}
    return function(handle)
        if not handle or handle == 0 or common.GetUnitTypeId(handle) == 0 then return 0 end
        local units = port.env.game and port.env.game.unit
        local unit = units and units.all_units and units.all_units[handle]
        local path = unit and unit:get_model_file()
        if not path or path == '' then
            local row = require('jass.slk').unit[string.pack('>I4', common.GetUnitTypeId(handle))]
            path = row and row.file or ''
        end
        path = path:lower():gsub('%.mdl$', '.mdx')
        if heights[path] then return heights[path] end
        local height, data = nil, path ~= '' and storm.load(path)
        if data and data:sub(1, 4) == 'MDLX' then
            local offset = 5
            while offset + 7 <= #data do
                local size = string.unpack('<I4', data, offset + 4)
                if offset + 7 + size > #data then break end
                if data:sub(offset, offset + 3) == 'MODL' and size >= 372 then
                    local top = string.unpack('<f', data, offset + 8 + 364)
                    if top == top and top > 0 and top < math.huge then height = top end
                    break
                end
                offset = offset + 8 + size
            end
        end
        heights[path] = height or 60
        port.note('LIMITATION unit overhead uses ' .. (height and 'model bounds: ' or 'default height 60: ') .. path)
        return heights[path]
    end
end
