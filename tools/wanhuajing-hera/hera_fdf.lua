-- 원본 UI 정의 요청을 확인하고 맵에 미리 포함한 프레임 템플릿을 읽는다.
local catalog = require('hera_fdf_catalog')
local loaded = false
local M = {}

function M.load(data)
    if data ~= catalog.base then
        local name, digits = data:match('^%s*Frame%s+"%u+"%s+"([%a_]+)(%d+)"')
        local template, size = catalog.templates[name], tonumber(digits)
        assert(template and size and size <= catalog.maximum, 'Unsupported UI definition: ' .. tostring(name) .. tostring(digits))
        local expected
        if name == 'edit' then expected = template:format(size, size, size, size / 1000)
        else expected = template:format(size, size / 1000) end
        assert(data == expected, 'UI definition differs from packaged template: ' .. name .. digits)
    end
    if not loaded then
        require('jass.japi').DzLoadToc('HeraWanhua_ui.toc')
        loaded = true
        require('hera_wanhua').note('FDF packaged templates requested; native rendering unverified')
    end
end

return M
