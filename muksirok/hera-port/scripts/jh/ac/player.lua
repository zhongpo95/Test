-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local jass = require("jass.common")
local handle_ref = require("jh.base.handle_ref")
local player = {}
local ac_game = ac and ac.game
jh = jh or {}
NameID = {}
for i = 1, 16 do
  NameID[i] = jass.GetPlayerName(jass.Player(i - 1))
end
NowNameID = {}
for i = 1, 16 do
  NowNameID[i] = jass.GetPlayerName(jass.Player(i - 1))
end
setmetatable(player, player)
jh.player = player
if ac then
  ac.player = player
end

function player:__tostring()
  return ("玩家%02d|%s|%s"):format(self.id, self.base_name or self.originname or "", jass.GetPlayerName(self.handle))
end

local mt = {}
player.__index = mt
mt.handle = 0
mt.id = 1
mt.type = "player"
mt.id2 = 0
mt.id3 = 0
mt.id4 = 0
mt.gold = 0
mt.gold_pool = 0
mt.mouse_x = 0
mt.mouse_y = 0
player.allplayer = {}

function getplayer(player2)
  if type(player2) == "number" then
    return player[player2]
  end
  if type(player2) == "table" then
    if player2.jh_player then
      return player2.jh_player
    end
    if player2.handle then
      return player.allplayer[player2.handle] or player[player2.handle]
    end
  end
  return player.allplayer[player2] or player[player2]
end

function mt:get()
  return self.id
end

function mt:event(name)
  return ac.event_register(self, name)
end

function mt:event_dispatch(name, ...)
  local res = ac.event_dispatch(self, name, ...)
  if res ~= nil then
    return res
  end
  if ac_game then
    res = ac.event_dispatch(ac_game, name, ...)
    if res ~= nil then
      return res
    end
  end
  return nil
end

function mt:event_notify(name, ...)
  ac.event_notify(self, name, ...)
  if ac_game then
    ac.event_notify(ac_game, name, ...)
  end
end

function player:__call(i)
  return player[i]
end

function mt:get_name()
  return jass.GetPlayerName(self.handle)
end

function mt:getname()
  return NowNameID[self.id]
end

function mt:chatmsg(trg, msg)
  TriggerRegisterPlayerChatEvent(trg, self.handle, msg, true)
end

function mt:unitselect(trg)
  TriggerRegisterPlayerUnitEvent(trg, self.handle, EVENT_PLAYER_UNIT_SELECTED, nil)
end

function mt:isplayer()
  return jass.GetPlayerController(self.handle) == jass.MAP_CONTROL_USER and jass.GetPlayerSlotState(self.handle) == jass.PLAYER_SLOT_STATE_PLAYING
end

function mt:islocal()
  return self == player.self or self.handle == player.self_handle
end

function mt:is_self()
  return self:islocal()
end

function mt:select(u)
  SelectUnitForPlayerSingle(u, self.handle)
end

local color_word = {}

function mt:getColorWord()
  local i = self:get()
  return color_word[i]
end

function mt:setalliance(player2, boolean1, boolean2)
  player2 = getplayer(player2)
  if boolean1 == nil then
    boolean1 = true
  end
  if boolean2 == nil then
    boolean2 = true
  end
  if boolean1 then
    SetPlayerAllianceStateBJ(self.handle, player2.handle, bj_ALLIANCE_ALLIED)
  else
    SetPlayerAllianceStateBJ(self.handle, player2.handle, bj_ALLIANCE_UNALLIED)
  end
  if boolean2 then
    SetPlayerAllianceStateBJ(player2.handle, self.handle, bj_ALLIANCE_ALLIED)
  else
    SetPlayerAllianceStateBJ(player2.handle, self.handle, bj_ALLIANCE_UNALLIED)
  end
end

function mt:get_team()
  if not self.team_id then
    self.team_id = jass.GetPlayerTeam(self.handle) + 1
  end
  return self.team_id
end

function mt:is_enemy(dest)
  return self:get_team() ~= dest:get_team()
end

function mt:is_ally(dest)
  return self:get_team() == dest:get_team()
end

function mt:cameralimit(rect)
  SetCameraBoundsToRectForPlayerBJ(self.handle, rect)
end

function mt:createrectfogcorrector(rect)
  local cor = CreateFogModifierRect(self.handle, FOG_OF_WAR_VISIBLE, rect, false, false)
  FogModifierStart(cor)
  return cor
end

function mt:is_visible(where)
  local x, y = where:get_point():get()
  return jass.IsVisibleToPlayer(x, y, self.handle)
end

function mt:setcamera(x, y, time)
  if self:islocal() then
    x = x or jass.GetCameraTargetPositionX()
    y = y or jass.GetCameraTargetPositionY()
    if time then
      jass.PanCameraToTimed(x, y, time)
    else
      jass.SetCameraPosition(x, y)
    end
  end
end

function mt:addtrgevent(text, func)
  if not self.trigger then
    self.trigger = {}
  end
  if not self.trigger[text] then
    self.trigger[text] = {}
  end
  table.insert(self.trigger[text], func)
end

function mt:dispatch_chat(str)
  local listeners = self.trigger and self.trigger["玩家-聊天"]
  if not listeners then
    return
  end
  local hero = Hero[self.id]
  local args = {
    p = self,
    player = self.handle,
    sy = self.id,
    raw_chat = str,
    chat = require("hera_korean_commands").normalize(str)
  }
  if hero and hero ~= 0 then
    args.unit = hero
    args.u = getunit(hero)
  end
  for _, func in ipairs(listeners) do
    func(args)
  end
end

function mt:setcameraheight(height, time)
  time = time or 0
  SetCameraFieldForPlayer(self.handle, CAMERA_FIELD_TARGET_DISTANCE, height + 1650, time)
  SetCameraFieldForPlayer(self.handle, CAMERA_FIELD_FARZ, 999999, 0)
end

function mt:addgold(gold)
  SetPlayerState(self.handle, PLAYER_STATE_GOLD_GATHERED, GetPlayerState(self.handle, PLAYER_STATE_GOLD_GATHERED) + gold)
  SetPlayerState(self.handle, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(self.handle, PLAYER_STATE_RESOURCE_GOLD) + gold)
end

function mt:getwood()
  return GetPlayerState(self.handle, PLAYER_STATE_RESOURCE_LUMBER)
end

function mt:addwood(count)
  AdjustPlayerStateBJ(count, self.handle, PLAYER_STATE_RESOURCE_LUMBER)
end

function mt:sendMsg(text, time)
  if UI_SystemMessage then
    UI_SystemMessage(self.handle, text, time or 10)
  else
    jass.DisplayTimedTextToPlayer(self.handle, 0, 0, time or 10, text)
  end
end

function mt:clearMsg()
  if self:islocal() then
    jass.ClearTextMessages()
    if UI_SystemMessageClear then UI_SystemMessageClear() end
  end
end

function mt:createunit(unittype, x, y, face)
  if type(unittype) == "string" then
    unittype = S2ID(unittype)
  end
  local handle = CreateUnitLua(self.handle, unittype, x, y, face or 0)
  local unit = require("jh.ac.unit")
  local u = unit:init(handle)
  return u
end

function mt:shockcamera(value, time)
  time = time or 0
  CameraSetEQNoiseForPlayer(self.handle, value)
  if time ~= 0 then
    ac.wait(time * 1000, function()
      CameraClearNoiseForPlayer(self.handle)
    end)
  end
end

local function create_player_leave_trigger()
  PlayerLeave = war3.CreateTrigger(function()
    local p = getplayer(GetTriggerPlayer())
    local sy = p.id
    require('hera_desync_diagnostic').event('PLAYER_LEAVE_BEGIN', 'slot=' .. tostring(sy))
    SendMsgAll(p:getname() .. "离开了游戏")
    require("hera_boot").note("PLAYER LEAVE slot=" .. tostring(sy) .. "; local=" .. tostring(LocalPlayerID) .. "; clock=" .. tostring(ac.clock()) .. "; count=" .. tostring(PlayerCount), true)
    -- 난이도 확정 전에는 인원 집계가 아직 생성되지 않는다.
    if type(PlayerCount) == "number" then
      PlayerCount = PlayerCount - 1
    end
    if Xuanze[sy] then
      local u = getunit(Hero[sy])
      if type(u) ~= "table" then
        require('hera_desync_diagnostic').event('PLAYER_LEAVE_NO_HERO', 'slot=' .. tostring(sy))
        return
      end
      u:groupremove(Group_PlayHero)
      u:groupremove(Group_Xingcunzu)
      u:groupremove(Group_DeathHero)
      Xuanze[sy] = false
      u:setdata("超即死")
      u:sethp(-1)
      u:deldata("超即死")
      ShowUnit(u.handle, false)
      u:buffset(u.handle, 3600, "无敌")
    end
    require('hera_desync_diagnostic').event('PLAYER_LEAVE_END', 'slot=' .. tostring(sy))
  end)
end

function player.create(id, jplayer)
  if player[id] then
    return player[id]
  end
  local p = {}
  setmetatable(p, player)
  p.handle = jplayer
  handle_ref.ref(jplayer)
  player[jplayer] = p
  player.allplayer[jplayer] = p
  p.id = id
  p.base_name = p:get_name()
  p.originname = p:getname()
  player[id] = p
  return p
end

local function init_color_words()
  color_word[1] = "|cFFFF0303"
  color_word[2] = "|cFF0042FF"
  color_word[3] = "|cFF1CE6B9"
  color_word[4] = "|cFF540081"
  color_word[5] = "|cFFFFFC01"
  color_word[6] = "|cFFFE8A0E"
  color_word[7] = "|cFF20C000"
  color_word[8] = "|cFFE55BB0"
  color_word[9] = "|cFF959697"
  color_word[10] = "|cFF7EBFF1"
  color_word[11] = "|cFF106246"
  color_word[12] = "|cFF4E2A04"
  color_word[11] = "|cFFFFFC01"
  color_word[12] = "|cFF0042FF"
  color_word[13] = "|cFF282828"
  color_word[14] = "|cFF282828"
  color_word[15] = "|cFF282828"
  color_word[16] = "|cFF282828"
end

local function init_core()
  if player.core_inited then
    return
  end
  player.core_inited = true
  player.count = 0
  for i = 1, 16 do
    player.create(i, jass.Player(i - 1))
    if player[i]:isplayer() then
      player.count = player.count + 1
    end
  end
  LocalPlayer = jass.GetLocalPlayer()
  LocalPlayerID = jass.GetPlayerId(LocalPlayer) + 1
  LocalP = getplayer(LocalPlayer)
  player.self = LocalP
  player.self_handle = LocalPlayer
  player.local_player = LocalP
  player.ac_self = LocalP
  init_color_words()
  require("jh.ac.player_select")
end

function player.init_runtime()
  if player.runtime_inited then
    return
  end
  init_core()
  player.runtime_inited = true
  create_player_leave_trigger()
  Trg_PlayerChat = war3.CreateTrigger(function()
    getplayer(GetTriggerPlayer()):dispatch_chat(GetEventPlayerChatString())
  end)
  Trg_EVENT_PLAYER_UNIT_SELECTED = war3.CreateTrigger(function()
    local unit = GetTriggerUnit()
    local player = GetTriggerPlayer()
    local p = getplayer(player)
    local text = "玩家-选择单位"
    local args = {}
    args.p = p
    args.unit = unit
    args.player = player
    if not p.trigger then
      p.trigger = {}
    end
    if not p.trigger[text] then
      p.trigger[text] = {}
    end
    for index, func in ipairs(p.trigger[text]) do
      if func then
        args.u = getunit(unit)
        func(args)
      else
        print("函数不存在" .. text)
      end
    end
  end)
  Trg_EVENT_PLAYER_UNIT_DESELECTED = war3.CreateTrigger(function()
    local unit = GetTriggerUnit()
    local player = GetTriggerPlayer()
    local p = getplayer(player)
    local text = "玩家-取消选择单位"
    local args = {}
    args.p = p
    args.unit = unit
    args.player = player
    if not p.trigger then
      p.trigger = {}
    end
    if not p.trigger[text] then
      p.trigger[text] = {}
    end
    for index, func in ipairs(p.trigger[text]) do
      if func then
        args.u = getunit(unit)
        func(args)
      else
        print("函数不存在" .. text)
      end
    end
  end)
  for i = 1, 16 do
    TriggerRegisterPlayerEvent(PlayerLeave, player[i].handle, EVENT_PLAYER_LEAVE)
    TriggerRegisterPlayerUnitEvent(Trg_EVENT_PLAYER_UNIT_SELECTED, player[i].handle, EVENT_PLAYER_UNIT_SELECTED, nil)
    TriggerRegisterPlayerUnitEvent(Trg_EVENT_PLAYER_UNIT_DESELECTED, player[i].handle, EVENT_PLAYER_UNIT_DESELECTED, nil)
    TriggerRegisterPlayerChatEvent(Trg_PlayerChat, player[i].handle, "", false)
    player[i]:addtrgevent("玩家-聊天", function(args)
      if args.chat == "-lockname" then
        if Lockname[i] == false then
          player[i]:sendMsg("锁定英雄名字")
          Lockname[i] = true
        else
          player[i]:sendMsg("取消锁定英雄名字")
          Lockname[i] = false
        end
      end
    end)
  end
  for i = 7, 8 do
    player[i]:addtrgevent("玩家-聊天", function(args)
      local player = args.player
      local p = getplayer(player)
      local str = string.lower(args.chat)
      local first = string.sub(str, 1, 1)
      local len = string.len(str)
      local sy = p.id
      if first == "-" then
        ResetToGameCameraForPlayer(p.handle, 0)
        local number = tonumber(str)
        if number ~= nil then
          local change = math.abs(number)
          playerconfig_set_camera_height(sy, Cam_height[sy] - change, 0, true)
        end
      end
      if string.sub(str, 1, 4) == "+cam" then
        ResetToGameCameraForPlayer(p.handle, 0)
        local number = tonumber(string.sub(str, 5, len))
        if number ~= nil then
          local change = math.abs(number)
          playerconfig_set_camera_height(sy, Cam_height[sy] + change, 0, true)
        end
      elseif first == "+" then
        ResetToGameCameraForPlayer(p.handle, 0)
        local number = tonumber(str)
        if number ~= nil then
          local change = math.abs(number)
          playerconfig_set_camera_height(sy, Cam_height[sy] + change, 0, true, 2050)
        end
      end
    end)
  end
end

init_core()
return player
