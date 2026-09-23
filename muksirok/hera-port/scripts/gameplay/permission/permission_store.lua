-- 서버 접속 없이 모든 등록 권한을 해금하고 조각 수는 이번 실행에만 유지한다.
local jass = require("jass.common")
local M = {}
local entries = {
  {
    key = "pem_qlzr",
    permission = "权力之刃"
  },
  {
    key = "pem_qlzg",
    permission = "权力之冠"
  },
  {key = "pem_cbx", permission = "残暴心"},
  {key = "pem_pjd", permission = "破戒刀"},
  {key = "pem_rlz", permission = "日轮竹"},
  {
    key = "pem_gpcyd",
    permission = "高频村雨刀"
  },
  {
    key = "pem_dasl",
    permission = "大阿阇黎"
  },
  {key = "pem_gl", permission = "孤狼"},
  {key = "pem_zl", permission = "只狼"},
  {
    key = "pem_gmzr",
    permission = "鬼灭之刃"
  },
  {
    key = "pem_hmgxg",
    permission = "哈密瓜雪糕"
  },
  {
    key = "pem_hxss",
    permission = "幻想杀手"
  },
  {key = "pem_kx", permission = "窥星"},
  {
    key = "pem_kzdewz",
    permission = "卡兹戴尔纹章"
  },
  {
    key = "pem_kzlz",
    permission = "空之律者"
  },
  {
    key = "pem_llkj",
    permission = "猎龙盔甲"
  },
  {
    key = "pem_ltcq",
    permission = "雷霆长枪"
  },
  {
    key = "pem_lysm",
    permission = "轮椅水门"
  },
  {key = "pem_qs", permission = "千矢"},
  {
    key = "pem_sdnl",
    permission = "圣诞尼禄"
  },
  {key = "pem_smn", permission = "赛马娘"},
  {
    key = "pem_srgz",
    permission = "塞壬公主"
  },
  {
    key = "pem_szjz",
    permission = "狮子戒指"
  },
  {
    key = "pem_wxzy",
    permission = "无暇之钥"
  },
  {
    key = "pem_xnqx",
    permission = "新年权限"
  },
  {
    key = "pem_xxjg",
    permission = "吸血剑鬼"
  },
  {key = "pem_yy", permission = "玉月"},
  {
    key = "pem_yzhx",
    permission = "炎之呼吸"
  },
  {
    key = "pem_zhzg",
    permission = "朱红之瑰"
  },
  {key = "pem_zzj", permission = "粽子精"},
  {
    key = "pem_alszg",
    permission = "爱丽丝之馆"
  },
  {
    key = "pem_bdbb",
    permission = "布丁背包"
  },
  {
    key = "pem_bszy",
    permission = "巴蛇之影"
  },
  {
    key = "pem_bycz",
    permission = "白银城主"
  },
  {key = "pem_cx", permission = "潮汐"},
  {
    key = "pem_dlsgx",
    permission = "德丽莎观星"
  },
  {
    key = "pem_etjbbt",
    permission = "儿童节棒棒糖"
  },
  {
    key = "pem_etjxg",
    permission = "儿童节雪糕"
  },
  {key = "pem_flj", permission = "芙兰酱"},
  {key = "pem_hb1", permission = "花瓣1"},
  {key = "pem_hb2", permission = "花瓣2"},
  {key = "pem_hb3", permission = "花瓣3"},
  {key = "pem_hb4", permission = "花瓣4"},
  {key = "pem_hb5", permission = "花瓣5"},
  {key = "pem_hb6", permission = "花瓣6"},
  {key = "pem_hb7", permission = "花瓣7"},
  {key = "pem_hb8", permission = "花瓣8"},
  {key = "pem_hb9", permission = "花瓣9"},
  {key = "pem_hb10", permission = "花瓣10"},
  {key = "pem_yz1", permission = "原质1"},
  {key = "pem_yz2", permission = "原质2"},
  {key = "pem_yz3", permission = "原质3"},
  {key = "pem_yz4", permission = "原质4"},
  {key = "pem_yz5", permission = "原质5"},
  {key = "pem_yz6", permission = "原质6"},
  {key = "pem_yz7", permission = "原质7"},
  {key = "pem_yz8", permission = "原质8"},
  {key = "pem_yz9", permission = "原质9"},
  {key = "pem_yz10", permission = "原质10"},
  {
    key = "pay_yzbzz",
    permission = "白洲梓语音"
  },
  {
    key = "pay_clmz",
    permission = "茉子皮肤"
  },
  {
    key = "pay_dbzy",
    permission = "妖梦皮肤"
  },
  {key = "pay_yls", permission = "幽灵鲨"},
  {key = "pay_skd", permission = "斯卡蒂"},
  {
    key = "pay_42",
    permission = "42英雄选择"
  },
  {
    key = "pay_qx",
    permission = "千咲英雄选择"
  },
  {
    key = "pay_cd",
    permission = "C呆英雄选择"
  }
}
local readonly_group_keys = {
  pay_yzbzz = true,
  pay_clmz = true,
  pay_dbzy = true,
  pay_yls = true,
  pay_skd = true,
  pay_42 = true,
  pay_qx = true,
  pay_cd = true
}
local entry_by_key = {}
local entry_by_permission = {}
local permission_aliases = {
  ["破碎的记忆"] = "窥星"
}
for _, entry in ipairs(entries) do
  entry_by_key[entry.key] = entry
  entry_by_permission[entry.permission] = entry
end
local client_api
local client_ready = false
local permissions_loaded = false
local player_permissions = {}
local selected_heroes = {}
local fragment_keys = {pem_hbsp = true, pem_yzsp = true}
local player_store_values = {}
local pending_permission_saves = {}
local pending_fragment_saves = {}
local item_hash_key = "权限物品校验"
local session_salt = table.concat({
  tostring(jass.GetRandomInt(100000, 999999)),
  tostring(jass.GetRandomInt(100000, 999999)),
  tostring(jass.GetRandomInt(100000, 999999))
}, ":")

local function send_local_message(text)
  DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 5, text)
end

local function item_hash(item)
  return jass.StringHash(session_salt .. ":" .. tostring(jass.GetHandleId(item)))
end

local function check_key(key)
  if not entry_by_key[key] then
  end
end

local function is_enabled(value)
  return value == true or value == 1
end

local function apply_permission(u, permission)
  local data_key = "权限-" .. permission
  if u:hasdata(data_key) then
    return
  end
  u:setdata(data_key)
  local default_effects = require("gameplay.permission.permission_default_effects")
  local effect = default_effects[permission]
  if effect then
    effect(u, u.ownerid)
  end
end

function M.init(api)
  -- 로컬 시험 맵에서는 전달된 서버 클라이언트를 사용하지 않는다.
end

function M.read_all_players()
  if permissions_loaded then
    return
  end
  if not client_ready then
    return
  end
  local permissions = {}
  for id = 1, 6 do
    local player_handle = jass.Player(id - 1)
    local is_player = jass.GetPlayerController(player_handle) == jass.MAP_CONTROL_USER and jass.GetPlayerSlotState(player_handle) == jass.PLAYER_SLOT_STATE_PLAYING
    if is_player then
      local values = {}
      for _, entry in ipairs(entries) do
        values[entry.key] = true
      end
      for key in pairs(fragment_keys) do
        values[key] = 0
      end
      permissions[id] = values
    end
  end
  player_permissions = permissions
  player_store_values = permissions
  permissions_loaded = true
  for id = 1, 6 do
    M.apply(selected_heroes[id])
  end
end

function M.apply(u)
  if not permissions_loaded or not u then
    return
  end
  local values = player_permissions[u.ownerid]
  if not values then
    return
  end
  for _, entry in ipairs(entries) do
    if values[entry.key] then
      apply_permission(u, entry.permission)
    end
  end
  local permission_read = require("gameplay.permission.permission_read")
  if permission_read.ApplyStore then
    permission_read.ApplyStore(u)
  end
end

function M.on_ready()
  client_ready = true
  M.read_all_players()
end

local group_keys = {
  ["皮肤权限-白洲梓语音"] = "pay_yzbzz",
  ["皮肤权限-常陆茉子"] = "pay_clmz",
  ["皮肤权限-渎白之渊"] = "pay_dbzy",
  ["变异权限-幽灵鲨"] = "pay_yls",
  ["变异权限-斯卡蒂"] = "pay_skd",
  ["英雄权限-42"] = "pay_42",
  ["英雄权限-千咲"] = "pay_qx",
  ["英雄权限-C呆"] = "pay_cd"
}

function M.has_permission_group(player_handle, group)
  local key = group_keys[group] or group
  if not entry_by_key[key] or not permissions_loaded then
    return false
  end
  local id = jass.GetPlayerId(player_handle) + 1
  return player_permissions[id] and player_permissions[id][key] == true or false
end

function M.on_hero_selected(u)
  if not u then
    return
  end
  selected_heroes[u.ownerid] = u
  if permissions_loaded then
    M.apply(u)
  elseif client_ready then
    M.read_all_players()
  end
end

function M.get_player_store(player_handle, key)
  if not permissions_loaded or not entry_by_key[key] then
    return nil
  end
  return true
end

function M.set_player_store(player_handle, key, value)
  -- 전체 해금은 유지하며 서버 저장 요청은 보내지 않는다.
end

function M.set_player_stored(u, permission)
  -- 이미 전체 해금되어 있으므로 저장 대기나 성공 메시지를 표시하지 않는다.
end

function M.add_player_store(u, key, delta)
  if not u or not fragment_keys[key] or type(delta) ~= "number" or delta ~= math.floor(delta) then
    return nil
  end
  local values = player_store_values[u.ownerid]
  if not values then
    values = {}
    player_store_values[u.ownerid] = values
  end
  values[key] = (values[key] or 0) + delta
  return values[key]
end

function M.get_fragment_store(u, key)
  if not u or not fragment_keys[key] then
    return 0
  end
  local values = player_store_values[u.ownerid]
  return values and values[key] or 0
end

function M.mark_item(item)
  if item then
    SetData(item, "权限获取物品")
    SetData(item, item_hash_key, item_hash(item))
  end
end

function M.create_permission_item(itemtype, x, y)
  local item = CreateItemLua(itemtype, x, y)
  M.mark_item(item)
  return item
end

function M.verify_item(item)
  return item ~= nil and GetData(item, item_hash_key) == item_hash(item)
end

function M.ready()
  return permissions_loaded
end

return M
