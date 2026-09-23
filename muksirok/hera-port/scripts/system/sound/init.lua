-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local handle_ref = require("jh.base.handle_ref")
SoundPath = SoundPath or {}
SoundHandleByPath = SoundHandleByPath or {}
SoundName = SoundName or {}
SoundNonOnce = SoundNonOnce or {}
SoundIs3D = SoundIs3D or {}
local sound_non_once = require("system.sound.sound_non_once")

local function register_sound(varname, path, looping, is_3d)
  local snd = CreateSound(path, looping, is_3d, is_3d, 10, 10, "DefaultEAXON")
  handle_ref.ref(snd)
  _G[varname] = snd
  SoundPath[varname] = path
  SoundPath[snd] = path
  SoundHandleByPath[path] = SoundHandleByPath[path] or snd
  SoundName[snd] = varname
  SoundNonOnce[snd] = looping == true or sound_non_once.contains(varname)
  SoundIs3D[snd] = is_3d == true
end

local function register_sounds(items)
  for _, name in ipairs(items) do
    register_sound(name, name .. ".mp3", false, false)
  end
end

local function register_3d_sounds(items)
  for _, name in ipairs(items) do
    register_sound(name, name .. ".mp3", false, true)
  end
end

local function register_looping_sounds(items)
  for _, name in ipairs(items) do
    register_sound(name, name .. ".mp3", true, false)
  end
end

local function register_prefixed_sounds(items, prefix)
  for _, name in ipairs(items) do
    register_sound(name, prefix .. "\\" .. name .. ".mp3", false, false)
  end
end

local function register_prefixed_defs(items, prefix)
  for _, item in ipairs(items) do
    register_sound(item.var, prefix .. "\\" .. item.file .. ".mp3", false, false)
  end
end

local function register_prefixed_3d_defs(items, prefix)
  for _, item in ipairs(items) do
    register_sound(item.var, prefix .. "\\" .. item.file .. ".mp3", false, true)
  end
end

local function register_prefixed_files(items, prefix)
  for _, item in ipairs(items) do
    register_sound(item.var, prefix .. "\\" .. item.file, false, false)
  end
end

local function register_defs(items)
  for _, item in ipairs(items) do
    register_sound(item.var, item.path, item.looping == true, item.is_3d == true)
  end
end

local sound_data = require("system.sound.sound_data")
register_sounds(sound_data.sound_vars)
register_3d_sounds(sound_data.sound3d_vars)
register_looping_sounds(sound_data.sound_bgm)
register_prefixed_sounds(sound_data.sound_vars2, "Bfsmyx")
register_prefixed_defs(sound_data.sound_vars_bfsm_extra, "Bfsmyx")
register_prefixed_3d_defs(sound_data.sound_vars_bfsm_3d, "Bfsmyx")
register_prefixed_sounds(sound_data.sound_vars3, "Luolan")
register_prefixed_sounds(sound_data.sound_vars4, "mz")
register_prefixed_sounds(sound_data.sound_vars_qx, "Qx")
register_prefixed_sounds(sound_data.sound_vars_sm, "Sm")
register_prefixed_files(sound_data.sound_vars_dqgex, "DqgEX")
register_defs(sound_data.sound_defs)
require("system.sound.sound_legacy")

function ClearBGM()
  SetSoundVolume(BGM, 0)
  StopSoundBJ(BGM, false)
end

ac.loop(1000, function()
  BGMChangeTime = BGMChangeTime - 1
  if BGMChangeTime > 0 then
    BGMIsChange = true
    SetSoundVolumeBJ(BGM, 0.0)
  else
    BGMChangeTime = 0
    if BGMIsChange then
      BGMIsChange = false
      PlayGlobalSound(BGM)
      if BGMBoolean[LocalPlayerID] then
        SetSoundVolumeBJ(BGM, 100)
      else
        SetSoundVolumeBJ(BGM, 0)
      end
    end
  end
end)

function ChangeBGM(snd)
  if not snd then
    local bgma = {
      BGM_N1,
      BGM_N2,
      BGM_N3,
      BGM_N4
    }
    local b = true
    for index, value in ipairs(bgma) do
      if BGM == value then
        b = false
      end
    end
    if b or GetRandom100(50) then
      ChangeBGM(bgma[GetRandomInt(1, #bgma)])
    end
    return
  end
  ClearBGM()
  StopSoundBJ(BGM, true)
  BGM = snd
  ac.wait(2000, function()
    PlaySoundBJ(BGM)
    if BGMBoolean[LocalPlayerID] == true and not BGMIsChange then
      SetSoundVolumeBJ(BGM, 100.0)
    else
      SetSoundVolumeBJ(BGM, 0)
    end
  end)
end

NowBGM = {}

function PlayBGM(args)
  args = args or {}
  local bgm = args.bgm or 0
  local time = args.time or 0
  local ID = args.ID or 0
  local unit = args.unit or NPC_BAYUNZI
  unit = unit or NPC_BAYUNZI
  local u = getunit(unit)
  if bgm ~= 0 then
    StopSoundBJ(BGM, false)
    PlayGlobalSound(bgm)
  end
  if time >= BGMChangeTime then
    BGMChangeTime = time
  end
  local str = "MU" .. ID
  local sy = u.ownerid
  local sy2 = (sy - 1) * 30 + 1
  local is_new_for_player = true
  if BGMLoadCount[sy] ~= 0 then
    for i = sy2, sy2 - 1 + BGMLoadCount[sy] do
      if str == BGMLoadId[i] then
        is_new_for_player = false
        break
      end
    end
  end
  if is_new_for_player then
    BGMLoadCount[sy] = BGMLoadCount[sy] + 1
    local cd = sy2 + BGMLoadCount[sy] - 1
    BGMLoadId[cd] = str
    if u:hasdata("变异判定-地狱歌姬") then
      if u:hasdata("变异判定-月见英子") then
        u:addallstats(5)
      else
        u:addrandomstats(5)
      end
    end
    if u:hasdata("变异判定-普利凯特") then
      u:changemaxhp(0.03 * u:getmaxhp())
      u:addint(0.02 * u:getoriginint())
      ChangeValue(Hero_Tili_Max, sy, 0.5)
    end
    if u:hasdata("变异判定-星野爱") then
      u:addallstats(10)
    end
    if u:hasdata("莲华-罪与罚的少女") then
      local qy = getunit(u:getdata("莲华-结约对象"))
      qy:addrandomstats(5)
      qy:addrandomdamage(5)
    end
  end
  if not BGMIsChange then
    StopSoundBJ(BGM, false)
    BGMChange = true
  end
  if u:hasdata("变异判定-光芒歌姬") and time >= u:getdata("光芒歌姬-持续时间") then
    u:setdata("光芒歌姬-持续时间", time)
  end
  if u:hasdata("变异判定-星野爱") then
    u:addrandomdamage(5)
  end
  if u:hasdata("变异判定-心动之焰") then
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:addrandomdamage(3)
    end)
  end
  local is_new_global = true
  if BGMAllCount ~= 0 then
    for i = 1, BGMAllCount do
      if str == BGMAllId[i] then
        is_new_global = false
        break
      end
    end
    if is_new_global and u:hasdata("羁绊-派对浪客") then
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:addrandomstats(5)
      end)
    end
  end
  if is_new_global then
    BGMAllCount = BGMAllCount + 1
    BGMLoadId[BGMAllCount] = str
  end
  ForGroupLuaNew(Group_PlayHero, function(xq)
    if xq:hasdata("变异判定-燕") and not xq:hasdata("燕-不可解冷却") then
      xq:addrandomstats(3)
      xq:addrandomdamage(1)
      xq:settimedata("燕-不可解冷却", 60)
    end
  end)
end

function StopBGM(time)
  local cs = time / 100
  SetSoundVolumeBJ(BGM, 0)
  ac.loop(100, function(t)
    cs = cs - 1
    if cs <= 0 then
      if BGMBoolean[LocalPlayerID] and not BGMIsChange then
        SetSoundVolumeBJ(BGM, 100)
      else
        SetSoundVolumeBJ(BGM, 0)
      end
      t:remove()
    end
  end)
end
