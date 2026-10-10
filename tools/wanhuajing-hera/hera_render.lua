-- 기본 카메라 투영과 JN 효과 속도를 제공하고 전용 MDXS 렌더 기능의 제한을 기록한다.
return function(port)
    local common, japi = require('jass.common'), require('jass.japi')
    local M, warned = {}, {}
    local function unsupported(feature)
        if not warned[feature] then warned[feature] = true; port.note('LIMITATION custom renderer: ' .. feature) end
    end
    function M.set_render_cursor_callback(callback) port.cursor_render = callback end
    function M.world_to_screen(x, y, z)
        local ex, ey, ez = common.GetCameraEyePositionX(), common.GetCameraEyePositionY(), common.GetCameraEyePositionZ()
        local fx, fy, fz = common.GetCameraTargetPositionX() - ex, common.GetCameraTargetPositionY() - ey, common.GetCameraTargetPositionZ() - ez
        local length = math.sqrt(fx * fx + fy * fy + fz * fz)
        if length < 0.001 then return nil end
        fx, fy, fz = fx / length, fy / length, fz / length
        local horizontal = math.sqrt(fx * fx + fy * fy)
        if horizontal < 0.001 then return nil end
        local rx, ry = fy / horizontal, -fx / horizontal
        local ux, uy, uz = ry * fz, -rx * fz, rx * fy - ry * fx
        local dx, dy, dz = x - ex, y - ey, z - ez
        local depth = dx * fx + dy * fy + dz * fz
        if depth <= 0.001 then return nil end
        local width, height = japi.GetWindowWidth(), japi.GetWindowHeight()
        local fov = common.GetCameraField(common.ConvertCameraField(3))
        if fov <= 0 or fov >= math.pi or height <= 0 then return nil end
        local focal = 1 / math.tan(fov / 2)
        local nx = (dx * rx + dy * ry) * focal / (width / height) / depth
        local ny = (dx * ux + dy * uy + dz * uz) * focal / depth
        return (1 + nx) * width / 2, (1 - ny) * height / 2, depth
    end
    function M.set_animation_speed(handle, speed) return japi.EXSetEffectSpeed(handle, speed) end
    for _, name in ipairs({'set_model', 'set_animation', 'set_animation_time', 'set_color', 'set_rotate'}) do
        M[name] = function() unsupported(name) end
    end
    return M
end
