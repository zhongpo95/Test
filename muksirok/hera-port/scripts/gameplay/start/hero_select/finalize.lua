-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local player = require("jh.ac.player")

function heroselect4(unit)
  local u = getunit(unit)
  local p = getplayer(u.owner)
  local sy = u.ownerid
  local x, y = u:getxy()
  if u:ishasskill(SKILL_TESHUYINGXIONG) then
    u:setskillforever("A1AM")
  else
    gunbankj(u)
    u:setdata("弹药带-启用")
  end
  local ng, njz
  if u.type ~= HeroType["缇娜"] and u.type ~= HeroType["爱丽丝"] and (u.type == HeroType["C呆"] or not u:ishasskill(SKILL_TESHUYINGXIONG)) then
    ac.wait(100, function()
      local q = {}
      q[1] = "I00S"
      q[2] = "I00P"
      q[3] = "I00Q"
      q[4] = "I00R"
      local zs = GetRandomInt(1, 4)
      local guntype = q[zs]
      local armortype
      ng = u:additem(guntype)
      if zs == 3 then
        armortype = "I000"
      else
        armortype = "I00T"
      end
      local dy = CreateItemLua(S2ID(armortype), x, y)
      SetItemCharges(dy, GetItemCharges(dy) * 6)
      u:addspeitem(dy)
    end)
  end
  if u.type == HeroType["爱丽丝"] then
    u:additem("I0BU")
  end
  if u.type == HeroType["志贵"] or u.type == HeroType["两仪式"] then
    njz = u:additem("I00A")
  end
  if u.type == HeroType["八重樱"] or u.type == HeroType["妖梦"] or u.type == HeroType["史尔特尔"] then
    njz = u:additem("I00M")
  end
  if Nandu_Choose == 1 then
    u:changedata("残机剩余数量", 5)
    u:setusedfodd(u:getdata("残机剩余数量"))
    ac.wait(1, function()
      local wp = CreateItemLua("I0KR", x, y)
      SetData(wp, "所属玩家", u.owner)
      u:addspeitem(wp)
      local wp = CreateItemLua("I0JQ", x, y)
      SetData(wp, "所属玩家", u.owner)
      u:addspeitem(wp)
      local wp = CreateItemLua("I0GQ", x, y)
      SetItemCharges(wp, 5)
      u:addspeitem(wp)
      u:addstexiao("新手补助", "过波时效果", function(args)
        local x, y = u:getxy()
        local wp = CreateItemLua("I0GQ", x, y)
        SetItemCharges(wp, 5)
        u:addspeitem(wp)
      end)
    end)
  end
  if Nandu_Choose == 2 then
    u:changedata("残机剩余数量", 3)
    u:setusedfodd(u:getdata("残机剩余数量"))
  end
  if Nandu_Choose == 3 then
    u:changedata("残机剩余数量", 1)
    u:setusedfodd(u:getdata("残机剩余数量"))
  end
  if Nandu_Choose >= 5 then
    u:addwood(0)
    u:addgold(50)
  else
    u:addwood(50)
    u:addgold(150)
  end
  if not Mode_Dabamoshi then
    local wp = CreateItemLua(S2ID("I00C"), x, y)
    SetItemCharges(wp, GetItemCharges(wp) * 3)
    u:addspeitem(wp)
    wp = CreateItemLua(S2ID("I009"), x, y)
    SetItemCharges(wp, GetItemCharges(wp) * 2)
    u:addspeitem(wp)
  end
  if Mode_Dabamoshi then
    StopSoundBJ(BGM_Start, false)
    BGMChangeTime = 0
    BGMBoolean[sy] = false
    if BGMBoolean[LocalPlayerID] == true and not BGMIsChange then
      SetSoundVolumeBJ(BGM, 100.0)
    else
      SetSoundVolumeBJ(BGM, 0.0)
    end
    Cam_height[sy] = 4000
    player[sy]:setcameraheight(Cam_height[sy], 0)
    u:setdata("系统-无法获取变异")
    ac.loop(100, function()
      u:setwood(0)
      u:setgold(0)
    end)
    u:sendmessage("bz 召唤一个普通单位靶子(1000W基础血量)\nbossbz 召唤一个BOSS级别靶子(1000W基础血量)\nqcbz 清除靶子\nlv+数值 提升指定等级,如果未输入则为5级\nhf 完全恢复状态")
    ac.loop(30000, function()
      if u:getdata("战斗时间") == 0 then
        u:sendmessage("bz 召唤一个普通单位靶子(1000W血量)\nbossbz 召唤一个BOSS级别靶子(1000W血量)\nqcbz 清除靶子\nlv+数值 提升指定等级,如果未输入则为5级\nhf 完全恢复状态")
      end
    end)
  end
  if u.type == HeroType["莲华"] or u.type == HeroType["C呆"] or not u:ishasskill(SKILL_TESHUYINGXIONG) then
    njz = u:additem("I00A")
  end
  return njz
end
