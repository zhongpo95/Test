-- 변신 발동 조건과 재사용 대기시간 및 종료를 처리한다.
-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local unit = require("jh.ac.unit")

local function add_heshin_buff_block(u, key, state_name)
  u:addstexiao(key, "被施加Buff时效果-僵直", function(args)
    local u = args.u
    local soc = args.soc
    if u:hasdata(state_name) and soc.handle ~= u.handle then
      args.time = 0
    end
  end)
  u:addstexiao(key, "被施加Buff时效果-眩晕", function(args)
    local u = args.u
    local soc = args.soc
    if u:hasdata(state_name) and soc.handle ~= u.handle then
      args.time = 0
    end
  end)
end

local function refresh_hero_extra_skill(u)
  local dskill
  if u.type == HeroType["八重樱"] then
    dskill = "A1AJ"
  elseif u.type == HeroType["志贵"] then
    dskill = "A1MP"
  elseif u.type == HeroType["妖梦"] then
    dskill = "A0EU"
  elseif u.type == HeroType["两仪式"] then
    dskill = "A0EP"
  elseif u.type == HeroType["史尔特尔"] then
    dskill = "A0H6"
  elseif u.type == HeroType["波风水门"] then
    dskill = "A0KE"
  elseif u.type == HeroType["千咲"] then
    dskill = "A0NY"
  else
    dskill = "A00B"
  end
  u:delskill(dskill)
  u:addskill(dskill)
end

local HeshinFunc = {add_buff_block = add_heshin_buff_block}
local heshingroup = require("gameplay.var.heshin.data")(HeshinFunc)

local function utf8_sub(s, startChar, numChars)
  local startIndex = 1
  while 1 < startChar do
    startIndex = startIndex + 1
    local char = string.byte(s, startIndex)
    while char and 128 <= char and char <= 191 do
      startIndex = startIndex + 1
      char = string.byte(s, startIndex)
    end
    startChar = startChar - 1
  end
  local currentIndex = startIndex
  while 0 < numChars and currentIndex <= #s do
    currentIndex = currentIndex + 1
    local char = string.byte(s, currentIndex)
    while char and 128 <= char and char <= 191 do
      currentIndex = currentIndex + 1
      char = string.byte(s, currentIndex)
    end
    numChars = numChars - 1
  end
  return s:sub(startIndex, currentIndex - 1)
end

function unit:heshin(text)
  local u = self
  if u:isalive() and not IsUnitPausedBJ(u.handle) and not u:hasdata("变身状态") then
    local heshin
    for index, value in ipairs(heshingroup) do
      if value.name == text then
        heshin = value
        break
      end
    end
    if not heshin then
      print("不存在的变身" .. text)
      return
    end
    if u:hasdata("变身冷却-" .. heshin.name) then
      print("变身技能冷却中")
      return
    end
    u:setdata("变身状态")
    u:addskill(heshin.skill)
    local basict = heshin.time
    local addt = 0
    if u:hasdata("遗物-变身自在") and utf8_sub(text, 1, 2) ~= "盖亚" then
      addt = addt + 0.5 * basict
    end
    if u:hasdata("变异判定-缇欧") then
      addt = addt + 0.25 * basict
    end
    u:setskilldatareal(heshin.skill, "持续时间(英雄)", basict + addt)
    IssueImmediateOrder(u.handle, "metamorphosis")
    heshin.startfunc(u)
    ac.wait(1000, function()
      ac.loop(1000, function(timer)
        if GetUnitTypeId(u.handle) == S2ID(heshin.unittype) then
          heshin.loopfunc(u)
        else
          u:deldata("变身状态")
          u:delskill(heshin.skill)
          heshin.endfunc(u)
          refresh_hero_extra_skill(u)
          timer:remove()
        end
      end)
    end)
    local str = "变身冷却-" .. heshin.name
    u:setdata(str, heshin.cd)
    ac.loop(1000, function(timer)
      u:changedata(str, -1)
      if u:getdata(str) <= 0 then
        u:deldata(str)
        u:sendmessage("|cFF7DBEF1变身冷却完毕:" .. heshin.name)
        timer:remove()
      end
    end)
    if u:hasdata("变异判定-缇欧") then
      u:addallstats(15)
    end
  end
end
