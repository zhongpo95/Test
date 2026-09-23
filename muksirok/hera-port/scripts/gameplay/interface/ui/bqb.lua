-- T키 이모티콘 선택창의 방향 판정과 채팅 표시를 관리한다.
local M = {}
Bqb_OpenClose = true
ChatEmojiMap = {
  [1] = {
    path = "BLP\\Image_bqb_1.blp",
    ratio = 1.2941176470588236
  },
  [2] = {
    path = "BLP\\Image_bqb_2.blp",
    ratio = 1.7964615151973387
  },
  [3] = {
    path = "BLP\\Image_bqb_3.blp",
    ratio = 1.2941176470588236
  },
  [4] = {
    path = "BLP\\Image_bqb_4.blp",
    ratio = 1.2941176470588236
  },
  [5] = {
    path = "BLP\\Image_bqb_5.blp",
    ratio = 2.156862745098039
  },
  [6] = {
    path = "BLP\\Image_bqb_2_2.blp",
    ratio = 1.5071927075915112
  },
  [7] = {
    path = "BLP\\Image_bqb_2_3.blp",
    ratio = 1.2941176470588236
  },
  [8] = {
    path = "BLP\\Image_bqb_2_4.blp",
    ratio = 1.2941176470588236
  },
  [9] = {
    path = "BLP\\Bqb_Leiheng_01.blp",
    ratio = 1.2941176470588236
  },
  [10] = {
    path = "BLP\\Bqb_Leiheng_02.blp",
    ratio = 1.2941176470588236
  },
  [11] = {
    path = "BLP\\Image_bqb_2_1.blp",
    ratio = 1.2941176470588236
  },
  [12] = {
    path = "BLP\\Bqb_Mingshen_01.blp",
    ratio = 0.9749019607843138
  },
  [13] = {
    path = "BLP\\Bqb_Motou_01.blp",
    ratio = 1.2941176470588236
  },
  [14] = {
    path = "BLP\\Bqb_Mygo_01.blp",
    ratio = 1.5788235294117647
  },
  [15] = {
    path = "BLP\\Bqb_Mygo_02.blp",
    ratio = 2.2949019607843137
  },
  [16] = {
    path = "BLP\\Bqb_Mygo_03.blp",
    ratio = 1.9584313725490194
  },
  [17] = {
    path = "BLP\\Bqb_Feiai_01.blp",
    ratio = 1.1215686274509804
  },
  [18] = {
    path = "BLP\\Bqb_Feiai_02.blp",
    ratio = 1.1043137254901962
  },
  [19] = {
    path = "BLP\\Bqb_Feiai_03.blp",
    ratio = 1.5270588235294118
  },
  [20] = {
    path = "BLP\\Bqb_Feiai_04.blp",
    ratio = 1.1215686274509804
  },
  [21] = {
    ratio = 1.2941176470588236,
    interval = 90,
    loop = true,
    frames = {}
  },
  [22] = {
    path = "BLP\\Bqb_Juwang_02.blp",
    ratio = 1.2682352941176471
  },
  [23] = {
    path = "BLP\\Bqb_Juwang_03.blp",
    ratio = 1.3631372549019607
  },
  [24] = {
    path = "BLP\\Bqb_Juwang_04.blp",
    ratio = 1.4752941176470589
  },
  [101] = {
    path = "BLP\\Bqb_42_01.blp",
    ratio = 2.070588235294118
  },
  [102] = {
    path = "BLP\\Bqb_42_02.blp",
    ratio = 1.7341176470588235
  },
  [103] = {
    path = "BLP\\Bqb_42_03.blp",
    ratio = 1.0956862745098042
  },
  [104] = {
    path = "BLP\\Bqb_42_04.blp",
    ratio = 1.2941176470588236
  },
  [105] = {
    path = "BLP\\Bqb_Mozi_01.blp",
    ratio = 1.7513725490196081
  },
  [106] = {
    path = "BLP\\Bqb_Mozi_02.blp",
    ratio = 1.1043137254901962
  },
  [107] = {
    path = "BLP\\Bqb_Mozi_03.blp",
    ratio = 1.1474509803921569
  },
  [108] = {
    path = "BLP\\Bqb_Mozi_04.blp",
    ratio = 1.2164705882352942
  },
  [201] = {
    ratio = 1.2941176470588236,
    interval = 60,
    loop = true,
    frames = {}
  },
  [202] = {
    path = "Qx\\Bqb_Qx_2.blp",
    ratio = 2.036078431372549
  },
  [203] = {
    path = "Qx\\Bqb_Qx_3.blp",
    ratio = 1.2941176470588236
  },
  [204] = {
    path = "Qx\\Bqb_Qx_4.blp",
    ratio = 1.2941176470588236
  },
  [9001] = {
    path = "BLP\\Bqb_Sam_01.tga",
    ratio = 1.8985558295174358
  },
  [9002] = {
    path = "BLP\\Bqb_Sam_02.blp",
    ratio = 1.8055653399084186
  }
}
ChatEmojiMap[201].frames = {}
for i = 1, 37 do
  table.insert(ChatEmojiMap[201].frames, "Qx\\Bqb_Qx_1 (" .. i .. ").blp")
end
ChatEmojiMap[21].frames = {}
for i = 1, 11 do
  table.insert(ChatEmojiMap[21].frames, "BLP\\Bqb_Juwang_01 (" .. i .. ").blp")
end
local ui_info = {
  path = {
    "BLP\\Expression_Left.blp",
    "BLP\\Expression_Up.blp",
    "BLP\\Expression_Right.blp",
    "BLP\\Expression_Down.blp"
  },
  sel_path = {
    "BLP\\Expression_Left_Select.blp",
    "BLP\\Expression_Up_Select.blp",
    "BLP\\Expression_Right_Select.blp",
    "BLP\\Expression_Down_Select.blp"
  },
  bqb = {
    1,
    2,
    3,
    4
  },
  is_show = false,
  id = 0,
  x = 0,
  y = 0,
  eff = nil,
  timer = nil
}
local BQB_GROUPS = {
  ["1"] = {
    name = "表情包组1",
    ids = {
      1,
      2,
      3,
      4
    }
  },
  ["2"] = {
    name = "表情包组2",
    ids = {
      5,
      6,
      7,
      8
    }
  },
  ["3"] = {
    name = "表情包组3",
    ids = {
      9,
      10,
      11,
      12
    }
  },
  ["4"] = {
    name = "表情包组4",
    ids = {
      13,
      14,
      15,
      16
    }
  },
  ["5"] = {
    name = "表情包组5",
    ids = {
      17,
      18,
      19,
      20
    }
  },
  ["6"] = {
    name = "哈密瓜雪糕表情包组",
    ids = {
      21,
      22,
      23,
      24
    },
    condition = function(u)
      return u:hasdata("权限-哈密瓜雪糕")
    end
  },
  s = {
    name = "史尔特尔表情包组",
    ids = {
      101,
      102,
      103,
      104
    },
    condition = function(u)
      return u:hasdata("英雄-史尔特尔")
    end
  },
  m = {
    name = "常陆茉子表情包组",
    ids = {
      105,
      106,
      107,
      108
    },
    condition = function(u)
      return u:hasdata("青水皮肤-茉子")
    end
  },
  q = {
    name = "千咲表情包组",
    ids = {
      201,
      202,
      203,
      204
    },
    condition = function(u)
      return u:hasdata("英雄-千咲")
    end
  }
}

local function get_bqb_preview_path(id)
  local cfg = ChatEmojiMap[id]
  if not cfg then
    return "BLP\\Image_bqb_1.blp"
  end
  if cfg.preview then
    return cfg.preview
  end
  if cfg.frames and cfg.frames[1] then
    return cfg.frames[1]
  end
  if cfg.path then
    return cfg.path
  end
  return "BLP\\Image_bqb_1.blp"
end

local function bqbui_init()
  local Panel = class.texture:builder({
    x = 700,
    y = 700,
    w = 156,
    h = 117,
    normal_image = "BLP\\Expression_Point.blp",
    Up = {
      type = "texture",
      w = 336,
      h = 126,
      normal_image = "BLP\\Expression_Up.blp",
      img = {
        type = "texture",
        w = 120,
        h = 90,
        normal_image = get_bqb_preview_path(ui_info.bqb[2])
      }
    },
    Left = {
      type = "texture",
      w = 168,
      h = 252,
      normal_image = "BLP\\Expression_Left.blp",
      img = {
        type = "texture",
        w = 120,
        h = 90,
        normal_image = get_bqb_preview_path(ui_info.bqb[1])
      }
    },
    Right = {
      type = "texture",
      w = 168,
      h = 252,
      normal_image = "BLP\\Expression_Right.blp",
      img = {
        type = "texture",
        w = 120,
        h = 90,
        normal_image = get_bqb_preview_path(ui_info.bqb[3])
      }
    },
    Down = {
      type = "texture",
      w = 336,
      h = 126,
      normal_image = "BLP\\Expression_Down.blp",
      img = {
        type = "texture",
        w = 120,
        h = 90,
        normal_image = get_bqb_preview_path(ui_info.bqb[4])
      }
    }
  })
  japi.FrameClearAllPoints(Panel._id)
  Panel.Up:set_position(-90, -70, "底部", "顶部", true)
  Panel.Up.img:set_position(115, -10, "中心", "中心", true)
  Panel.Left:set_position(-90, -68, "右侧", "左侧", true)
  Panel.Left.img:set_position(-10, 60, "中心", "中心", true)
  Panel.Right:set_position(75, -68, "左侧", "右侧", true)
  Panel.Right.img:set_position(45, 70, "中心", "中心", true)
  Panel.Down:set_position(-90, 60, "顶部", "底部", true)
  Panel.Down.img:set_position(115, 40, "中心", "中心", true)
  ui_info.frame = {
    Panel.Left,
    Panel.Up,
    Panel.Right,
    Panel.Down,
    Panel
  }
  ui_info.panel = Panel
  BQBInfo = ui_info
  local event = {
    on_key_down = function(code)
      if code == 84 then
        M.key_down("window")
      end
    end,
    on_key_up = function(code)
      if code == 84 then
        M.key_up("window")
      end
    end,
    on_update = function()
      if not ui_info.is_show then
        return
      end
      local ux, uy = ui_info.x, ui_info.y
      local x, y = game.get_mouse_pos()
      local p1 = ac.point(ux, uy)
      local p2 = ac.point(x, y)
      if p1 * p2 <= 27 then
        return
      end
      local angle = math.deg(p1 / p2)
      local id = math.floor(math.fmod(angle + 215, 360) / 90) + 1
      if id ~= ui_info.id then
        local old_id = ui_info.id
        if old_id ~= 0 then
          ui_info.frame[old_id]:set_normal_image(ui_info.path[old_id])
        end
        ui_info.frame[id]:set_normal_image(ui_info.sel_path[id])
        ui_info.id = math.floor(id)
      end
    end
  }
  game.register_event(event)
  local trg = CreateTrigger()
  japi.DzTriggerRegisterSyncData(trg, "MSG", false)
  TriggerAddAction(trg, function()
    local msg = japi.DzGetTriggerSyncData()
    local player = japi.DzGetTriggerSyncPlayer()
    local sy = GetConvertedPlayerId(player)
    local id = string.match(msg, "BQB|(%d+)")
    if id then
      local p = getplayer(player)
      if Xuanze[sy] then
        local hero = getunit(Hero[sy])
        local localhero = getunit(Hero[LocalPlayerID])
        local x, y = hero:getxy()
        local snd
        local sndsize = 127
        if id == "1" then
          snd = Sound_Bfsm_Ang
          sndsize = 100
        end
        if id == "2" then
          snd = Sound_Bqb_02
          sndsize = 70
        end
        if id == "3" then
          snd = Sound_Bqb_03
          sndsize = 110
        end
        if id == "4" then
          snd = Sound_Bqb_Aytx
        end
        if id == "5" then
          snd = Sound_Bqb_05
          sndsize = 100
        end
        if id == "6" then
          snd = Sound_Bqb_01
          sndsize = 100
        end
        if id == "8" then
          snd = Sound_Bqb_04
        end
        if id == "9" then
          snd = Sound_Bqb_Leiheng02
        end
        if id == "10" then
          snd = Sound_Bqb_Leiheng01
        end
        if id == "11" then
          snd = Sound_Bqb_Yaha01
        end
        if id == "14" then
          snd = Sound_Aiyin_02
        end
        if id == "15" then
          snd = Sound_Aiyin_01
        end
        if id == "16" then
          snd = Sound_Sushi_01
        end
        if id == "17" then
          snd = Sound_Bqb_Feiai_01
        end
        if id == "18" then
          snd = Sound_Bqb_Feiai_02
        end
        if id == "19" then
          snd = Sound_Bqb_Feiai_03
        end
        if id == "20" then
          snd = Sound_Bqb_Feiai_04
        end
        if id == "21" then
          snd = Sound_Bqb_Wang_01
        end
        if id == "22" then
          snd = Sound_Bqb_Wang_02
        end
        if id == "23" then
          snd = Sound_Bqb_Wang_03
        end
        if id == "24" then
          snd = Sound_Bqb_Wang_04
        end
        if id == "102" then
          snd = Sound_Bqb_Laiwanting
        end
        if Hero[LocalPlayerID] ~= 0 and localhero:hasdata("聊天-关闭表情包语音") then
          sndsize = 0
        end
        if snd and 0 < sndsize then
          PlayGlobalSound(snd, sndsize)
        end
        if id == "2" and hero:hasdata("判定-朝武芳乃") then
          hero:changedata("朝武芳乃-Cia次数", 1)
        end
        UI_NewChat(getplayer(hero.owner), nil, "[bqb:" .. tonumber(id) .. "]")
      end
    end
  end)
end

bqbui_init()

function change_bqb(index, id)
  ui_info.bqb[index] = id
  ui_info.frame[index].img:set_normal_image(get_bqb_preview_path(id))
end

function bqb_group_can_use(u, group_key)
  local group = BQB_GROUPS[tostring(group_key)]
  if not group then
    return false
  end
  return not group.condition or group.condition(u)
end

function bqb_change_group(u, group_key, is_save)
  group_key = tostring(group_key or "1")
  local group = BQB_GROUPS[group_key]
  if not group or not bqb_group_can_use(u, group_key) then
    return false
  end
  if u:islocal() then
    for index, id in ipairs(group.ids) do
      change_bqb(index, id)
    end
    if is_save then
      BqbGroup = group_key
      if playerconfigsave then
        playerconfigsave()
      end
    end
  end
  return true
end

function bqb_apply_config_group(u)
  if not u or not u:islocal() then
    return false
  end
  local group_key = tostring(BqbGroup or "1")
  if not bqb_change_group(u, group_key, false) then
    bqb_change_group(u, "1", false)
    return false
  end
  return true
end

function M.key_down(source)
  local sy = LocalPlayerID
  local selected = Xuanze and Xuanze[sy]
  require("hera_gameplay_diagnostic").local_input("emoji_key_down", Hero and Hero[sy],
    "source=" .. tostring(source) .. " selected=" .. tostring(selected) .. " enabled=" .. tostring(Bqb_OpenClose))
  if not selected or not Bqb_OpenClose or ui_info.is_show then
    return
  end
  local x, y = game.get_mouse_pos()
  ui_info.x = x
  ui_info.y = y
  ui_info.id = 0
  japi.FrameSetAbsolutePoint(ui_info.panel._id, 4, x / 1920 * 0.8, (1 - y / 1080) * 0.6)
  ui_info.panel:show()
  ui_info.is_show = true
end

function M.key_up(source)
  local sy = LocalPlayerID
  require("hera_gameplay_diagnostic").local_input("emoji_key_up", Hero and Hero[sy],
    "source=" .. tostring(source) .. " open=" .. tostring(ui_info.is_show) .. " choice=" .. tostring(ui_info.id))
  if not ui_info.is_show then
    return
  end
  local id = ui_info.id
  if id ~= 0 then
    ui_info.frame[id]:set_normal_image(ui_info.path[id])
    japi.DzSyncData("MSG", "BQB|" .. ui_info.bqb[id])
  end
  ui_info.is_show = false
  ui_info.panel:hide()
end

return M
