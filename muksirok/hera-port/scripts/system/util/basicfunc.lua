-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local japi = require("jass.japi")
local player = require("jh.ac.player")
local handle_ref = require("jh.base.handle_ref")

function IsWindowActive()
  return true
end

function generateRandomString(length)
  local chars = {}
  for i = 1, length do
    local randomChar = string.char(GetRandomInt(32, 126))
    table.insert(chars, randomChar)
  end
  return table.concat(chars)
end

function TableContains(table, value)
  for _, v in ipairs(table) do
    if v == value then
      return true
    end
  end
  return false
end

function utf8Iter(str)
  local i = 1
  return function()
    if i > #str then
      return nil
    end
    local byte = str:byte(i)
    local step = byte < 128 and 1 or byte < 224 and 2 or byte < 240 and 3 or 4
    local char = str:sub(i, i + step - 1)
    i = i + step
    return char, step
  end
end

function CreateUnitLua(player, unittype, x, y, face)
  if type(unittype) == "string" then
    unittype = S2ID(unittype)
  end
  local handle = CreateUnit(player, unittype, x, y, face or 0)
  handle_ref.ref(handle)
  return handle
end

function RemoveUnitLua(unit, generation, remove_src, remove_line)
  if generation and not handle_ref.is_current(unit, generation) then
    return false
  end
  if GetUnitTypeId(unit) ~= 0 then
    RemoveUnit(unit)
  else
    print("访问了已移除单位", unit)
    if remove_src then
      print("删除任务来源", remove_src, remove_line)
    end
    print(debug.traceback())
  end
  handle_ref.unref(unit, generation)
  return true
end

function DestroyEffectLua(effect, generation)
  if not handle_ref.begin_remove(effect, generation) then
    return false
  end
  DestroyEffect(effect)
  handle_ref.unref(effect, generation)
  return true
end

function RemoveItemLua(item, generation)
  if generation and not handle_ref.is_current(item, generation) then
    return false
  end
  if not item or item == 0 or GetItemTypeId(item) == 0 then
    return false
  end
  RemoveItem(item)
  handle_ref.unref(item, generation)
  return true
end

function HoldHandleRefLua(handle)
  return handle_ref.hold(handle)
end

function ReleaseHandleRefLua(handle)
  return handle_ref.release(handle)
end

function DelayHandleRefLua(handle, timeout, callback)
  local held = handle_ref.hold(handle)
  local function release()
    if held then
      held = false
      handle_ref.release(handle)
    end
  end
  local timer = ac.wait(timeout, function()
    local ok, err = xpcall(callback, debug.traceback)
    release()
    if not ok then
      error(err, 0)
    end
  end)
  timer.on_remove = release
  return timer
end

function DelayRemoveItemLua(item, timeout)
  return DelayHandleRefLua(item, timeout, function()
    RemoveItemLua(item)
  end)
end

function DelayRemoveUnitLua(unit, timeout)
  local info = debug.getinfo(2, "Sl")
  local remove_src = info and info.short_src
  local remove_line = info and info.currentline
  return DelayHandleRefLua(unit, timeout, function()
    RemoveUnitLua(unit, nil, remove_src, remove_line)
  end)
end

function CreateItemLua(itemtype, x, y)
  if type(itemtype) == "string" then
    itemtype = S2ID(itemtype)
  end
  local wp = CreateItem(itemtype, x, y)
  handle_ref.ref(wp)
  ClearData(wp)
  return wp
end

function GetRandomAngle()
  return GetRandomReal(0, 360)
end

local dataStorage = {}

function SetData(key, DataName, Data)
  if not dataStorage[key] then
    dataStorage[key] = {}
  end
  if Data == nil then
    Data = true
  end
  dataStorage[key][DataName] = Data
end

function ClearData(key)
  dataStorage[key] = {}
end

function DelData(key, DataName)
  if dataStorage[key] and dataStorage[key][DataName] ~= nil then
    dataStorage[key][DataName] = nil
  elseif DebugText then
    print("自定义值不存在:" .. DataName)
  end
end

function GetData(key, DataName)
  if dataStorage[key] and dataStorage[key][DataName] ~= nil then
    return dataStorage[key][DataName]
  else
    if DebugText then
      print("尝试获取空自定义值" .. DataName)
    end
    return 0
  end
end

function HasData(key, DataName)
  if dataStorage[key] and dataStorage[key][DataName] ~= nil then
    return true
  else
    return false
  end
end

function ChangeData(unit, DataName, value, type)
  type = type or 0
  if type == 0 then
    SetData(unit, DataName, GetData(unit, DataName) + value)
  end
  if type == 1 then
    SetData(unit, DataName, GetData(unit, DataName) * value)
  end
  if type == 2 then
    SetData(unit, DataName, GetData(unit, DataName) / value)
  end
end

function SendMsgAll(string, time)
  for i = 1, 8 do
    player[i]:sendMsg(string, time or 10)
  end
end

function SendDtimeMsgAll(dtime, string, time)
  ac.wait(dtime * 1000, function()
    for i = 1, 8 do
      player[i]:sendMsg(string, time or 10)
    end
  end)
end

function SendJbMsgAll(args)
  local strz = args.strz
  local strstart = args.strstart
  local strend = args.strend
  local time = args.time
  local wait = args.waittime or 0
  local shunxu = args.shunxu or 1
  local origintext = args.origintext
  local endtext = args.endtext
  local cs = 0
  local chars = {}
  for char, length in utf8Iter(strz) do
    table.insert(chars, char)
  end
  local len = #chars
  local dt = time / len
  ac.wait(wait * 1000, function()
    ac.timer(dt * 1000, len, function()
      cs = cs + 1
      ClearTextMessages()
      if UI_SystemMessageClear then UI_SystemMessageClear() end
      local dstr = ""
      if shunxu == 2 then
        for i = len - (cs - 1), len do
          dstr = dstr .. chars[i]
        end
      else
        for i = 1, cs do
          dstr = dstr .. chars[i]
        end
      end
      if origintext then
        SendMsgAll(origintext, 10)
      end
      SendMsgAll(strstart .. dstr .. strend, 10)
      if endtext then
        SendMsgAll(endtext, 10)
      end
    end)
  end)
end

function Effectcreate(effect, x, y, time, size, height, zxz, xxz, yxz, animespeed)
  local tx = AddSpecialEffect(effect, x, y)
  handle_ref.ref(tx)
  zxz = zxz or 0
  xxz = xxz or 0
  yxz = yxz or 0
  if size then
    japi.EXSetEffectSize(tx, size)
  end
  if xxz ~= 0 then
    japi.EXEffectMatRotateX(tx, xxz)
  end
  if yxz ~= 0 then
    japi.EXEffectMatRotateY(tx, yxz)
  end
  if zxz ~= 0 then
    japi.EXEffectMatRotateZ(tx, zxz)
  end
  if height and height ~= 0 then
    japi.EXSetEffectZ(tx, height)
  end
  if animespeed then
    japi.EXSetEffectSpeed(tx, animespeed)
  end
  -- 모든 모델 설정을 마친 뒤 수명 처리를 수행한다.
  time = time or 0
  if 0 <= time then
    if not time or time == 0 then
      DestroyEffectLua(tx)
    else
      local generation = handle_ref.generation(tx)
      ac.wait(time * 1000, function()
        DestroyEffectLua(tx, generation)
      end)
    end
  end
  return tx
end

function EffectcreateArgs(args)
  local effect = args.effect
  local x = args.x
  local y = args.y
  local time = args.time or 0
  local size = args.size or 0
  local height = args.height or 0
  local zxz = args.zxz or 0
  local xxz = args.xxz or 0
  local yxz = args.yxz or 0
  local animespeed = args.animespeed or 1
  local tx = AddSpecialEffect(effect, x, y)
  handle_ref.ref(tx)
  if size ~= 0 then
    japi.EXSetEffectSize(tx, size)
  end
  if xxz ~= 0 then
    japi.EXEffectMatRotateX(tx, xxz)
  end
  if yxz ~= 0 then
    japi.EXEffectMatRotateY(tx, yxz)
  end
  if zxz ~= 0 then
    japi.EXEffectMatRotateZ(tx, zxz)
  end
  if height and height ~= 0 then
    japi.EXSetEffectZ(tx, height)
  end
  if animespeed ~= 1 then
    japi.EXSetEffectSpeed(tx, animespeed)
  end
  -- 모델 설정을 완료한 뒤 이펙트를 파괴한다.
  if 0 <= time then
    if not time or time == 0 then
      DestroyEffectLua(tx)
    else
      local generation = handle_ref.generation(tx)
      ac.wait(time * 1000, function()
        DestroyEffectLua(tx, generation)
      end)
    end
  end
  return tx
end

function EffectShowAll(tx, boolean)
  local b
  if boolean ~= nil then
    b = boolean
  else
    b = true
  end
  if type(japi.EXSetEffectFogVisible) == "function" then
    japi.EXSetEffectFogVisible(tx, b)
  end
  if type(japi.EXSetEffectMaskVisible) == "function" then
    japi.EXSetEffectMaskVisible(tx, b)
  end
end

function SetEffectModel(tx, model)
  if type(japi.DzSetEffectModel) == "function" then
    japi.DzSetEffectModel(tx, model)
    return true
  end
  return false
end

function SetEffectAnimation(tx, anime, link)
  link = link or ""
  if type(anime) == "number" then
    if type(japi.EXSetEffectAnimation) == "function" then
      japi.EXSetEffectAnimation(tx, anime)
    end
  elseif type(japi.EXPlayEffectAnimation) == "function" then
    japi.EXPlayEffectAnimation(tx, anime, link)
  end
end

function SetEffectSize(effect, x, y, z)
  x = x or 1
  if y or z then
    y = y or x
    z = z or x
    japi.EXEffectMatScale(effect, x, y, z)
  else
    japi.EXSetEffectSize(effect, x)
  end
end

function SetEffectActSpeed(effect, speed)
  speed = speed or 1
  japi.EXSetEffectSpeed(effect, speed)
end

function DistanceBetweenUnits(a, b)
  local x1 = GetUnitX(a)
  local x2 = GetUnitX(b)
  local y1 = GetUnitY(a)
  local y2 = GetUnitY(b)
  local dis = ((x1 - x2) ^ 2 + (y1 - y2) ^ 2) ^ 0.5
  return dis
end

function TimerDestroyTextTag(time, tt)
  local N = 0
  local i = 0
  if time <= 0 then
    time = 0.01
  end
  SetTextTagPermanent(tt, false)
  SetTextTagLifespan(tt, time)
  SetTextTagFadepoint(tt, time)
end

function AngleBetweenUnits(fromunit, tounit)
  return bj_RADTODEG * Atan2(GetUnitY(tounit) - GetUnitY(fromunit), GetUnitX(tounit) - GetUnitX(fromunit))
end

SoundPath = SoundPath or {}
SoundNonOnce = SoundNonOnce or {}
SoundName = SoundName or {}
SoundIs3D = SoundIs3D or {}

local function resolve_sound_path(sound)
  if type(sound) == "string" then
    return SoundPath[sound] or sound
  end
  return SoundPath[sound]
end

local function resolve_unit_handle(unit)
  if type(unit) == "table" then
    return unit.handle
  end
  return unit
end

local function should_play_by_handle(sound)
  if not (type(sound) ~= "string" and sound) or sound == 0 then
    return false
  end
  return SoundPath[sound] == nil or sound == BGM or SoundNonOnce[sound] == true
end

local prepared_sound_paths = {}
local sound_first_reports = 0
local sound_request_ids = {}

local function begin_sound_request(handle)
  local request = (sound_request_ids[handle] or 0) + 1
  sound_request_ids[handle] = request
  return request
end

local function play_sound_by_path(sound, volume, unit_context, x, y)
  local path = resolve_sound_path(sound)
  if not path or path == "" then
    local name = SoundName[sound] or tostring(sound)
    if name == "" then
      name = "<empty>"
    end
    print("尝试播放不存在路径音效：" .. name)
    printCallStack()
    return false
  end
  if type(japi.PlaySoundByName) == "function" then
    japi.PlaySoundByName(path, volume or 127)
  else
    -- 로컬 시야/입력 경로에서는 새 게임 핸들을 생성하지 않는다.
    local handle = type(sound) ~= "string" and sound or (SoundHandleByPath and SoundHandleByPath[path])
    if not handle or handle == 0 then
      require("hera_boot").note("SOUND UNREGISTERED path=" .. path)
      return false
    end
    local request = begin_sound_request(handle)
    local unit_generation = unit_context and handle_ref.generation(unit_context)
    local function position_sound()
      if SoundIs3D[handle] then
        if unit_context then
          if unit_generation and not handle_ref.is_alive(unit_context, unit_generation) or GetUnitTypeId(unit_context) == 0 then
            return false
          end
          AttachSoundToUnit(handle, unit_context)
        elseif x ~= nil and y ~= nil then
          SetSoundPosition(handle, x, y, 0)
        end
      end
      return true
    end
    local first = not prepared_sound_paths[path]
    prepared_sound_paths[path] = true
    local duration
    if type(GetSoundFileDuration) == "function" and type(SetSoundDuration) == "function" then
      duration = GetSoundFileDuration(path)
      if type(duration) == "number" and duration > 0 then SetSoundDuration(handle, duration) end
    end
    local function start()
      StopSound(handle, false, false)
      if not position_sound() then return false end
      SetSoundVolume(handle, volume or 127)
      StartSound(handle)
      -- 초기화 때 등록한 핸들은 다음 재생에서도 재사용한다.
      return true
    end
    if first and ac and type(ac.wait) == "function" then
      -- 첫 디코딩은 무음으로 시작하고 같은 핸들을 처음부터 다시 재생한다.
      -- 무음 준비 단계에서는 KillSoundWhenDone을 호출하지 않는다.
      if not position_sound() then return false end
      SetSoundVolume(handle, 0)
      StartSound(handle)
      ac.wait(150, function()
        -- 같은 핸들의 새 재생을 이전 무음 준비 콜백이 덮어쓰지 않는다.
        if sound_request_ids[handle] ~= request then return end
        StopSound(handle, false, false)
        start()
      end)
      if sound_first_reports < 12 then
        sound_first_reports = sound_first_reports + 1
        local context = "none"
        if SoundIs3D[handle] and unit_context then
          context = "attach:" .. tostring(unit_context)
        elseif SoundIs3D[handle] and x ~= nil and y ~= nil then
          context = "point:" .. tostring(x) .. "," .. tostring(y)
        end
        require('hera_boot').note('SOUND FIRST prime=150ms; path=' .. path .. '; duration=' .. tostring(duration) .. '; 3d=' .. tostring(SoundIs3D[handle] == true) .. '; context=' .. context, true)
      end
    else
      return start()
    end
  end
  return true
end

function PlaySoundByPath(sound, volume)
  if should_play_by_handle(sound) then
    return PlaySoundByHandle(sound, volume) ~= false
  end
  return play_sound_by_path(sound, volume)
end

function PlaySoundByUnitVisible(unit_handle, sound, volume)
  local handle = resolve_unit_handle(unit_handle)
  if not handle or handle == 0 or GetUnitTypeId(handle) == 0 or not IsUnitVisible(handle, GetLocalPlayer()) then
    return false
  end
  if should_play_by_handle(sound) then
    return PlaySoundByHandleUnitVisible(handle, sound, volume) ~= false
  end
  return play_sound_by_path(sound, volume, handle)
end

function PlaySoundByPointVisible(x, y, sound, volume)
  if type(x) ~= "number" or type(y) ~= "number" then
    return false
  end
  if not IsVisibleToPlayer(x, y, GetLocalPlayer()) then
    return false
  end
  if should_play_by_handle(sound) then
    return PlaySoundByHandlePoint(x, y, sound, volume) ~= false
  end
  return play_sound_by_path(sound, volume, nil, x, y)
end

function PlaySoundByHandle(sound, volume)
  if not sound or sound == 0 then
    return false
  end
  begin_sound_request(sound)
  StopSound(sound, false, false)
  SetSoundVolume(sound, volume or 127)
  StartSound(sound)
  return sound
end

function PlaySoundByHandleUnitVisible(unit_handle, sound, volume)
  local handle = resolve_unit_handle(unit_handle)
  if not (handle and handle ~= 0 and sound) or sound == 0 then
    return false
  end
  begin_sound_request(sound)
  StopSound(sound, false, false)
  AttachSoundToUnit(sound, handle)
  StartSound(sound)
  if IsUnitVisible(handle, GetLocalPlayer()) then
    SetSoundVolume(sound, volume or 127)
  else
    SetSoundVolume(sound, 0)
  end
  return sound
end

function PlaySoundByHandlePoint(x, y, sound, volume)
  if not (type(x) == "number" and type(y) == "number" and sound) or sound == 0 then
    return false
  end
  begin_sound_request(sound)
  StopSound(sound, false, false)
  SetSoundPosition(sound, x, y, 0)
  StartSound(sound)
  if IsVisibleToPlayer(x, y, GetLocalPlayer()) then
    SetSoundVolume(sound, volume or 127)
  else
    SetSoundVolume(sound, 0)
  end
  return sound
end

function PlayGlobalSound(sound, size)
  PlaySoundByPath(sound, size or 127)
  return sound
end

function GetRandom100(gl)
  local rd = GetRandomReal(0, 100)
  if gl >= rd then
    return true
  else
    return false
  end
end

function RefreshCritWeaponBonus(unit)
  local u = getunit(unit)
  local sy = u.ownerid
  if not DamageSystem_Baoji_JzWeapon or not DamageSystem_Baoji_GunWeapon then
    return
  end
  DamageSystem_Baoji_JzWeapon[sy] = 0
  DamageSystem_Baoji_GunWeapon[sy] = 0
  local wqlx = Hero_Equip_WeaponType[sy]
  if wqlx and GetData(wqlx, "近战武器类型") ~= 0 then
    DamageSystem_Baoji_JzWeapon[sy] = 10
  end
  local gun
  if u.type == HeroType["铃仙"] then
    gun = u:getdata("吞噬枪支")
    if not gun or gun == 0 then
      local zgun = u:getdata("专属枪支")
      if zgun and zgun ~= ITEM_KONG then
        gun = GetItemTypeId(zgun)
      end
    end
  else
    local zgun = u:getdata("装备枪支")
    if zgun and zgun ~= ITEM_KONG then
      gun = GetItemTypeId(zgun)
    end
  end
  if gun and gun ~= 0 then
    local lx = GetData(gun, "枪械类型")
    if lx == 3 then
      DamageSystem_Baoji_GunWeapon[sy] = 25
    elseif lx and 0 < lx then
      DamageSystem_Baoji_GunWeapon[sy] = 10
    end
  end
end

function ChangeValue(tbl, key, value, type)
  type = type or 0
  if type == 0 then
    tbl[key] = tbl[key] + value
  end
  if type == 1 then
    tbl[key] = tbl[key] * value
  end
  if type == 2 then
    tbl[key] = tbl[key] / value
  end
end

function ChangeTimeValue(tbl, key, value, time, type)
  time = time or 0
  type = type or 0
  if type == 0 then
    tbl[key] = tbl[key] + value
  end
  if type == 1 then
    tbl[key] = tbl[key] * value
  end
  if type == 2 then
    tbl[key] = tbl[key] / value
  end
  if time ~= 0 then
    ac.wait(time * 1000, function()
      if type == 0 then
        tbl[key] = tbl[key] - value
      end
      if type == 1 then
        tbl[key] = tbl[key] / value
      end
      if type == 2 then
        tbl[key] = tbl[key] * value
      end
    end)
  end
end

function IsTimeDay()
  local b
  if GetTimeOfDay() >= 18 or GetTimeOfDay() <= 6 then
    b = false
  else
    b = true
  end
  return b
end

function IsTimeNight()
  local b
  if GetTimeOfDay() >= 18 or GetTimeOfDay() <= 6 then
    b = true
  else
    b = false
  end
  return b
end

function IsXYinRect(x, y, rect)
  return RectContainsCoords(rect, x, y)
end

function IsXYInLimRECT(x, y)
  return x >= Limx1 and x <= Limx2 and y >= Limy1 and y <= Limy2
end

function IsXYinAnyPlayRect(x, y)
  if IsXYinRect(x, y, RECT_PlayArea) then
    return true
  end
  for i = 1, 6 do
    if Xuanze[i] and IsXYinRect(x, y, RECT_PlayerNowArea[i]) then
      return true
    end
  end
end

function GetRandomXYInRect(rect)
  local x = GetRandomReal(GetRectMinX(rect), GetRectMaxX(rect))
  local y = GetRandomReal(GetRectMinY(rect), GetRectMaxY(rect))
  return x, y
end

function CreateMonster(type2, x, y, face)
  face = face or GetRandomReal(0, 360)
  if type(type2) == "string" then
    type2 = S2ID(type2)
  end
  require("hera_gameplay_diagnostic").monster("DIRECT_CREATE_BEGIN", {type=type2, x=x, y=y, face=face})
  local monster = CreateUnitLua(ConvertedPlayer(GetRandomInt(9, 12)), type2, x, y, face)
  require("hera_gameplay_diagnostic").monster("DIRECT_CREATE_END", {handle=monster})
  return monster
end

function EffectShowAll(tx, boolean)
  local b
  if boolean ~= nil then
    b = boolean
  else
    b = true
  end
  if type(japi.EXSetEffectFogVisible) == "function" then
    japi.EXSetEffectFogVisible(tx, b)
  end
  if type(japi.EXSetEffectMaskVisible) == "function" then
    japi.EXSetEffectMaskVisible(tx, b)
  end
end

function PlaySoundXY(x, y, sound)
  PlaySoundByPointVisible(x, y, sound, 127)
end

function PolarXY(x, y, dis, angle)
  x = x or 0
  y = y or 0
  local x2 = x + dis * math.cos(angle)
  local y2 = y + dis * math.sin(angle)
  return x2, y2
end

function DistanceXY(x1, y1, x2, y2)
  local dis = (((x1 or 0) - (x2 or 0)) ^ 2 + ((y1 or 0) - (y2 or 0)) ^ 2) ^ 0.5
  return dis
end

function AngleXY(x1, y1, x2, y2)
  local a = Atan2BJ(y2 - y1, x2 - x1)
  return a
end

function CreateTimeItem(typeid, x, y, time)
  time = time or 0
  if type(typeid) == "string" then
    typeid = S2ID(typeid)
  end
  local wp = CreateItemLua(typeid, x, y)
  if time ~= 0 then
    DelayRemoveItemLua(wp, time * 1000)
  end
  return wp
end

NCDU = {}
CIUC = {}
OID = {}
FID = {}
SID = {}
TID = {}
THID = {}
PlayerID = {}
ac.wait(3000, function()
  if type(japi.GetUserIdEx) ~= "function" then
    require("hera_boot").note("DEFERRED GetUserIdEx: platform identity unavailable; no synthetic ID sent")
    return
  end
  local trg = CreateTrigger()
  local name = "ciuc" .. GetRandomReal(0, 100)
  japi.DzTriggerRegisterSyncData(trg, name, false)
  TriggerAddAction(trg, function()
    local id = japi.DzGetTriggerSyncData()
    local player = japi.DzGetTriggerSyncPlayer()
    local sy = GetConvertedPlayerId(player)
    if id ~= nil or id ~= "" then
      NCDU[sy] = id
      CIUC[sy] = "UID" .. id
      for i = 1, 99 do
        CIUC[sy] = I2S(StringHash(CIUC[sy]))
      end
    end
  end)
  japi.DzSyncData(name, japi.GetUserIdEx())
end)
for i = 1, 8 do
  OID[i] = GetPlayerName(ConvertedPlayer(i))
  local b = false
  for j = 1, string.len(OID[i]) do
    if "#" == string.sub(OID[i], j, j) and not b then
      b = true
      OID[i] = string.sub(OID[i], 1, j - 1)
    end
  end
  SetPlayerName(ConvertedPlayer(i), OID[i])
  NameID[i] = OID[i]
  PlayerID[i] = "111" .. OID[i]
  FID[i] = "POWER" .. OID[i]
  FID[i] = I2S(StringHash(FID[i]))
  SID[i] = I2S(StringHash(FID[i]))
  local p = player[i]
  local id3 = "SUPER" .. GetPlayerName(p.handle)
  for k = 1, 99 do
    id3 = StringHash(id3)
  end
  TID[i] = I2S(id3)
  local id4 = "CABER" .. GetPlayerName(p.handle)
  for k = 1, 78 do
    id4 = StringHash(id4)
  end
  THID[i] = I2S(id4)
  p.id3 = id3
  p.id4 = id4
  if TID[i] == "-908769494" then
    NCDU[i] = "32016841"
    CIUC[i] = "374288340"
  end
  if TID[i] == "-224833415" then
    NCDU[i] = "51341885"
    CIUC[i] = "193004530"
  end
  if TID[i] == "-1477076798" then
    NCDU[i] = "30005517"
    CIUC[i] = "-294228084"
  end
end

function ChangeItemCount(item, count)
  if 0 < count then
    SetItemCharges(item, GetItemCharges(item) + count)
  elseif GetItemCharges(item) > -1 * count then
    SetItemCharges(item, GetItemCharges(item) + count)
  elseif GetItemType(item) == ITEM_TYPE_CHARGED or GetItemType(item) == ITEM_TYPE_ARTIFACT then
    RemoveItemLua(item)
  else
    SetItemCharges(item, 0)
  end
end

function IsItemStackExcluded(item)
  if not item or item == 0 then
    return true
  end
  local itemtype = GetItemTypeId(item)
  return itemtype == MEDICINE_BLOOD_TC or itemtype == S2ID("I0JQ") or itemtype == S2ID("I0PG") or itemtype == S2ID("I0PH") or itemtype == S2ID("I0KY") or itemtype == S2ID("I0KR") or itemtype == S2ID("I0JK") or itemtype == MEDICINE_YITAI_JJ or HasData(item, "赝造女巫-赝造药水") or HasData(item, "掌天瓶-已催生")
end

function GetItemStackLimit(item, hero)
  local limit = GetData(GetItemTypeId(item), "最大容量") or 0
  if hero then
    if hero:hasdata("变异判定-在原七海") then
      limit = limit * 2
    end
    if hero:hasdata("白洲梓-战略整装") then
      limit = limit * 2
    end
  end
  return limit
end

local function GetItemStackOwnerId(item)
  if not HasData(item, "所属玩家") then
    return nil
  end
  local owner = GetData(item, "所属玩家")
  if owner == 0 then
    return nil
  end
  return GetPlayerId(owner) + 1
end

function IsSameItemStackOwner(item, target)
  local owner1 = GetItemStackOwnerId(item)
  local owner2 = GetItemStackOwnerId(target)
  if owner1 or owner2 then
    return owner1 == owner2
  end
  return true
end

function TryStackItemToItem(item, target, hero)
  if not (item and item ~= 0 and target) or target == 0 or item == target then
    return false
  end
  if GetItemTypeId(item) ~= GetItemTypeId(target) then
    return false
  end
  if not IsSameItemStackOwner(item, target) then
    return false
  end
  if IsItemStackExcluded(item) or IsItemStackExcluded(target) then
    return false
  end
  local item_class = GetItemType(item)
  if item_class ~= ITEM_TYPE_CHARGED and item_class ~= ITEM_TYPE_ARTIFACT then
    return false
  end
  local count = GetItemCharges(item)
  if item_class == ITEM_TYPE_ARTIFACT then
    local limit = GetItemStackLimit(target, hero)
    local target_count = GetItemCharges(target)
    if limit <= 0 or limit <= target_count then
      return false
    end
    if HasData(item, "不可回收") then
      SetData(target, "不可回收")
    end
    local add = math.min(count, limit - target_count)
    SetItemCharges(target, target_count + add)
    if count <= add then
      RemoveItemLua(item)
      return "all", add
    end
    SetItemCharges(item, count - add)
    return "part", add
  end
  if HasData(item, "不可回收") then
    SetData(target, "不可回收")
  end
  SetItemCharges(target, GetItemCharges(target) + count)
  RemoveItemLua(item)
  return "all", count
end

function TryStackItemToUnit(item, unit, hero)
  if not item or item == 0 or not unit then
    return false
  end
  local item_class = GetItemType(item)
  if item_class ~= ITEM_TYPE_CHARGED and item_class ~= ITEM_TYPE_ARTIFACT then
    return false
  end
  if IsItemStackExcluded(item) then
    return false
  end
  local stacked
  for i = 1, 6 do
    local target = unit:getcountitem(i)
    local result = TryStackItemToItem(item, target, hero)
    if result then
      if result == "all" then
        return result
      end
      stacked = result
    end
  end
  return stacked or false
end

function TryStackItemToUnits(item, units, hero)
  if not units then
    return false
  end
  local stacked
  for _, unit in ipairs(units) do
    local result = TryStackItemToUnit(item, unit, hero)
    if result then
      if result == "all" then
        return result
      end
      stacked = result
    end
  end
  return stacked or false
end

-- 차량 이동 등 일반 원형 검사도 임시 위치와 영역 핸들을 만들지 않는다.
local destructable_select_rect = Rect(0, 0, 0, 0)
function EnumDestrucSelect(x, y, r, func)
  if r < 0 then return end
  SetRect(destructable_select_rect, x - r, y - r, x + r, y + r)
  EnumDestructablesInRect(destructable_select_rect, nil, function()
    local dc = GetEnumDestructable()
    local dx = GetDestructableX(dc) - x
    local dy = GetDestructableY(dc) - y
    if dx * dx + dy * dy <= r * r then
      func()
    end
  end)
end

function flytext(args)
  local unit = args.unit
  local x = args.x
  local y = args.y
  local time = args.time or 1.5
  local height = args.height or -50
  local r = args.r or 255
  local g = args.g or 255
  local b = args.b or 255
  local a = args.a or 255
  local xspeed = args.xspeed or 0
  local yspeed = args.yspeed or 0.05
  local text = args.text or ""
  local size = args.size or 10
  local tt = CreateTextTag()
  SetTextTagText(tt, text, TextTagSize2Height(size))
  if not unit then
    SetTextTagPos(tt, x, y, height)
  else
    SetTextTagPosUnit(tt, unit, height)
  end
  SetTextTagColor(tt, r, g, b, a)
  SetTextTagVelocity(tt, xspeed, yspeed)
  if 0 < time then
    TimerDestroyTextTag(time, tt)
  end
  return tt
end

function Rect_Randomitem(rect)
  local g = {}
  EnumItemsInRect(rect, nil, function()
    table.insert(g, GetEnumItem())
  end)
  if 0 < #g then
    return g[GetRandomInt(1, #g)]
  else
    return 0
  end
end
