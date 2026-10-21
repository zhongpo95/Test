-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local ui = require("jh.ui.server.util")
local event = {
  on_sync = function(key_hash, event_hash, args, sync_data)
    local key = ui.get_str(key_hash)
    local event_name = ui.get_str(event_hash)
    if key == nil then
      print("同步错误， 不存在的键值", key_hash, debug.traceback())
    end
    if event_name == nil then
      print("同步错误， 不存在的事件名", event_hash, debug.traceback())
    end
    args = args or {}
    local button = ac.sync_key_map[key]
    if button == nil then
      print("同步错误， 不存在的按钮", key, debug.traceback())
      return
    end
    if event_name == "on_sync_button_right_clicked" then
      local trace = require("hera_button_input").trace_right
      trace("receive", tostring(key) .. " player=" .. tostring(ui.player.id))
      if button.sync_owner_id and button.sync_owner_id ~= ui.player.id then
        trace("reject", "owner-mismatch " .. tostring(key))
        return
      end
      trace("execute", key)
    end
    for k, v in pairs(args) do
      if type(v) == "table" then
        local str = ui.get_str(v[1])
        if str then
          local col = ac.sync_key_map[str]
          if col then
            args[k] = col
          end
        end
      end
    end
    local previous_sync_data = button.sync_data
    button.sync_data = sync_data
    
    local function restore_sync_data()
      if button.sync_data == sync_data then
        button.sync_data = previous_sync_data
      end
    end
    
    if ac.game then
      local player = ui.player
      if player:event_dispatch("ui:" .. event_name, player, button, table.unpack(args)) then
        restore_sync_data()
        return
      end
    end
    button:event_callback(event_name, ui.player, table.unpack(args))
    restore_sync_data()
  end
}
ui.register_event("sync", event)
