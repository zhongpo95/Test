-- 가방 마우스 입력을 먼저 처리하고 설치 JN의 능력 조회 함수로 단축키 시전을 연결한다.
local message = require("jass.message")
local player = require("jh.ac.player")
local slk = require("jass.slk")
local jass = require("jass.common")
local keyboard = message.keyboard
local japi = require("jass.japi")
local input_trace = require("hera_gameplay_diagnostic")
local yae_release = require("gameplay.feature.shot.yae_release")
local minato_summon = require("gameplay.feature.shot.minato_summon")

local function has_selected_hero(sy)
  return Xuanze and Xuanze[sy] and Hero and Hero[sy] and Hero[sy] ~= 0
end

local function is_cooling(ability_handle)
  local cool = japi.EXGetAbilityState(ability_handle, 1)
  if 0 < cool then
    return true
  end
  return false
end

local FLAG = {
  ["地面"] = 2,
  ["空中"] = 4,
  ["建筑"] = 8,
  ["守卫"] = 16,
  ["物品"] = 32,
  ["树木"] = 64,
  ["墙"] = 128,
  ["残骸"] = 256,
  ["装饰物"] = 512,
  ["桥"] = 1024,
  ["位置"] = 2048,
  ["自己"] = 4096,
  ["玩家单位"] = 8192,
  ["联盟"] = 16384,
  ["中立"] = 32768,
  ["敌人"] = 65536,
  ["未知"] = 524288,
  ["可攻击的"] = 1048576,
  ["无敌"] = 2097152,
  ["英雄"] = 4194304,
  ["非-英雄"] = 8388608,
  ["存活"] = 16777216,
  ["死亡"] = 33554432,
  ["有机生物"] = 67108864,
  ["机械类"] = 134217728,
  ["非-自爆工兵"] = 268435456,
  ["自爆工兵"] = 536870912,
  ["非-古树"] = 1073741824,
  ["古树"] = 2147483648
}
FLAG["敌我判断"] = FLAG["自己"] | FLAG["玩家单位"] | FLAG["联盟"] | FLAG["中立"] | FLAG["敌人"]

local function target_filter(unit, flag, slk)
  local player = jass.GetOwningPlayer(message.selection())
  if jass.IsUnitInvisible(unit, player) then
    return false
  end
  if flag & FLAG["死亡"] == 0 and jass.IsUnitType(unit, jass.UNIT_TYPE_DEAD) then
    return false
  end
  if flag & FLAG["无敌"] == 0 and jass.GetUnitAbilityLevel(unit, 1098282348) == 1 then
    return false
  end
  if (not tonumber(slk.reqLevel) or 1 >= tonumber(slk.reqLevel)) and jass.IsUnitType(unit, jass.UNIT_TYPE_MAGIC_IMMUNE) then
    return false
  end
  if flag & FLAG["敌我判断"] ~= 0 then
    if flag & FLAG["敌人"] == 0 and jass.IsUnitEnemy(unit, player) then
      return false
    end
    if flag & FLAG["自己"] == 0 and unit == message.selection() then
      return false
    end
    if flag & FLAG["玩家单位"] == 0 and jass.GetOwningPlayer(unit) == player then
      return false
    end
    if flag & FLAG["联盟"] == 0 and jass.IsUnitAlly(unit, player) then
      return false
    end
  end
  if flag & FLAG["非-英雄"] ~= 0 and jass.IsHeroUnitId(unit) then
    return false
  end
  if flag & FLAG["英雄"] ~= 0 and not jass.IsHeroUnitId(unit) then
    return false
  end
  return true
end

local jass_group = CreateGroup()

local function find_target(caster, ability_handle, x, y)
  local ability = japi.EXGetAbilityId(ability_handle)
  local data = slk.ability[ability]
  if not data then
    return nil
  end
  local level = jass.GetUnitAbilityLevel(caster, ability)
  if level < 1 then
    return nil
  end
  local target_type = japi.EXGetAbilityDataInteger(ability_handle, level, 100)
  local group = {}
  jass.GroupEnumUnitsInRange(jass_group, x, y, 200, nil)
  while true do
    local unit = jass.FirstOfGroup(jass_group)
    if unit == nil or unit == 0 then
      break
    end
    if target_filter(unit, target_type, data) then
      table.insert(group, unit)
    end
    jass.GroupRemoveUnit(jass_group, unit)
  end
  table.sort(group, function(u1, u2)
    local h1 = jass.IsHeroUnitId(u1)
    local h2 = jass.IsHeroUnitId(u2)
    if h1 and not h2 then
      return true
    end
    if h2 and not h1 then
      return false
    end
    local x1 = jass.GetUnitX(u1)
    local y1 = jass.GetUnitY(u1)
    local x2 = jass.GetUnitX(u2)
    local y2 = jass.GetUnitY(u2)
    return (x1 - x) * (x1 - x) + (y1 - y) * (y1 - y) < (x2 - x) * (x2 - x) + (y2 - y) * (y2 - y)
  end)
  return group[1]
end

local FLAG = {
  ["队列"] = 1,
  ["瞬发"] = 2,
  ["独立"] = 4,
  ["物品"] = 8,
  ["恢复"] = 32
}

local function cast_ability(unit, ability_handle, order, target_type)
  local x, y = message.mouse()
  if target_type == 2 then
    message.order_point(order, x, y, FLAG["独立"] | FLAG["恢复"])
    return false
  elseif target_type == 4 then
    local target = find_target(unit, ability_handle, x, y)
    if target then
      message.order_target(order, x, y, target, FLAG["独立"] | FLAG["恢复"])
    end
    return false
  elseif target_type == 6 then
    message.order_target(order, x, y, nil, FLAG["独立"] | FLAG["恢复"])
    return false
  elseif target_type == 1 then
    message.order_immediate(order, FLAG["独立"] | FLAG["恢复"])
    return false
  end
  return true
end

local event_map = {
  mouse_down = function(msg)
    local code = msg.code
    local id1 = LocalPlayerID
    local unit = japi.GetRealSelectUnit()
    local id2 = GetConvertedPlayerId(GetOwningPlayer(unit))
    local x, y = message.mouse()
    local x2, y2 = GetCameraTargetPositionX(), GetCameraTargetPositionY()
    local re = true
    local jlx, jly
    if msg.code == 1 and UI_MwxAlice and UI_MwxAlice:get_is_show() then
      local mx, my = game.get_mouse_pos()
      Local_IsRunAliveVar = false
      local panel = UI_MwxAlice
      local px = panel.__rx or 0
      local py = panel.__ry or 0
      local pw = panel:get_width()
      local ph = panel:get_height()
      local inside = mx >= px and mx <= px + pw and my >= py and my <= py + ph
      if not inside then
        panel:hide()
      end
    end
    if unit ~= 0 and unit == Hero[id1] then
      local u = getunit(unit)
      local zgun = u:getdata("装备枪支")
      local zguntype = GetItemTypeId(zgun)
      local lx = GetData(zguntype, "枪械类型")
      if lx == 3 and u:hasdata("狙击模式-开启") and code == 1 then
        message.order_point(YDWEAbilityId2OrderId(u:getdata("系统-狙击技能")), x, y, FLAG["独立"] | FLAG["恢复"])
        if u:hasdata("系统-空弹") then
          message.order_immediate(YDWEAbilityId2OrderId(u:getdata("系统-狙击换弹")), FLAG["独立"] | FLAG["恢复"])
        end
        re = false
      end
      if u:hasdata("英雄-千咲") and (u:getdata("千咲-浮空高度") > 50 or 0 < u:getdata("千咲-浮空时间") or 0 < u:getdata("千咲-电锯模式时间")) then
        re = false
        if code == 4 then
          local sy = u.ownerid
          local bb = getunit(Beibao[sy])
          bb:select()
          message.order_point(YDWEAbilityId2OrderId("A0BO"), x, y)
          u:select()
        end
      end
      if (u.type == HeroType["志贵"] or u.type == HeroType["两仪式"] or u.type == HeroType["千咲"] or u.type == HeroType["史尔特尔"]) and (0 < u:getdata("志贵连招暂停时间") or 0 < u:getdata("千咲-连招暂停时间") or 0 < u:getdata("两仪式连招暂停时间") or 0 < u:getdata("史尔特尔-连招暂停时间")) then
        re = false
      end
    end
    return re
  end,
  key_down = function(msg)
    local code = msg.code
    local state = msg.state
    local id1 = LocalPlayerID
    local unit = japi.GetRealSelectUnit()
    local re = true
    local sy = id1
    if code == KEY.I and ToggleTestConsumeItemBagUI then
      ToggleTestConsumeItemBagUI(id1)
      return false
    end
    if CheXuanze[id1] == true then
      local msg2
      if code == 87 then
        msg2 = tostring(id1) .. "W" .. "ON"
      end
      if code == 83 then
        msg2 = tostring(id1) .. "S" .. "ON"
      end
      if msg2 ~= nil then
        japi.DzSyncData("car", msg2)
      end
      local hero = getunit(Hero[id1])
      if hero:hasdata("英雄-千咲") and (code == KEY.ESC or code == KEY.X) then
        local sy = hero.ownerid
        local bb = getunit(Beibao[sy])
        bb:select()
        local x, y = hero:getxy()
        x, y = PolarXY(x, y, 100, hero:getface())
        message.order_point(YDWEAbilityId2OrderId("A0BO"), x, y)
        hero:select()
      end
    end
    if unit ~= 0 and unit == Hero[id1] then
      local u = getunit(unit)
      if u:hasdata("弓箭系统-装备中") and code == 65 then
        message.order_immediate(YDWEAbilityId2OrderId("A0DL"), FLAG["独立"] | FLAG["恢复"])
        local x, y = message.mouse()
        message.order_point(YDWEAbilityId2OrderId("A0DJ"), x, y, FLAG["独立"] | FLAG["恢复"])
      end
      local zgun = u:getdata("装备枪支")
      local zguntype = GetItemTypeId(zgun)
      local lx = GetData(zguntype, "枪械类型")
      if lx == 3 and (code == 71 or code == 65 and state == 4) then
        message.order_immediate(YDWEAbilityId2OrderId("A0CM"), FLAG["独立"] | FLAG["恢复"])
      end
      if u:hasdata("英雄-千咲") then
        if not (0 < u:getdata("千咲-电锯模式时间")) or code == KEY.E or code == KEY.R or (u:getdata("千咲连携") == "E" or u:getdata("千咲连携") == "EE") and code == KEY.Q or u:getdata("千咲连携") == "EER" and (code == KEY.Q or KEY.W) then
        else
          re = false
        end
        if 0 < u:getdata("千咲-连招暂停时间") then
          re = false
        end
      end
      if u.type == HeroType["两仪式"] and code ~= 83 and 0 < u:getdata("两仪式连招暂停时间") then
        re = false
      end
      if u.type == HeroType["史尔特尔"] and 0 < u:getdata("史尔特尔-连招暂停时间") then
        re = false
        if 0 < u:getdata("史尔特尔-看破连携时间") and (code == 67 or code == 68 or code == 82) then
          re = true
        end
        if u:getdata("42连携") == "EEEE" and code == 68 then
          re = true
        end
      end
      if re then
        for x = 0, 3 do
          for y = 0, 2 do
            local ability, order, target_type = message.button(x, y)
            local ability_data = slk.ability[ability]
            if ability_data and keyboard[ability_data.Hotkey] == msg.code and (ability_data.Name == "替换-A-莲华-蝴蝶" or ability_data.Name == "开枪弓箭发射" or ability_data.Name == "开枪-点" or ability_data.Name == "诡异柴刀-E2" or ability_data.Name == "开枪-魔导军枪" or ability_data.Name == "换弹-增幅术式" or ability_data.Name == "史莱姆剑-E2" or ability_data.Name == "开枪-点2" or ability_data.Name == "志贵-E2" or ability_data.Name == "志贵-V2" or ability_data.Name == "史尔特尔-C" or ability_data.Name == "史尔特尔-R" or ability_data.Name == "两仪式-V点地" or ability_data.Name == "两仪式-E点地" or ability_data.Name == "两仪式-A点地" or ability_data.Name == "位移-龙宫礼奈-鬼步" or ability_data.Name == "物品-Appa" or ability_data.Name == "物品-Exp" or ability_data.Name == "替换-A-十六夜-银色飞刀" or ability_data.Name == "替换-R-十六夜-月时计" or ability_data.Name == "物品-Expe" or ability_data.Name == "物品-Sect" or ability_data.Name == "位移-空之律者-相位穿梭" or ability_data.Name == "志贵-S" or ability_data.Name == "波风水门-A" or ability_data.Name == "波风水门-S" or ability_data.Name == "波风水门-E" or ability_data.Name == "两仪式-S" or ability_data.Name == "妖梦-A点地" or ability_data.Name == "妖梦-E点地" or ability_data.Name == "千咲-R点地" or ability_data.Name == "千咲-A点地" or ability_data.Name == "千咲-E点地" or ability_data.Name == "千咲-F点地" or ability_data.Name == "千咲-V" or ability_data.Name == "千咲-X" or ability_data.Name == "妖梦-F点地" or ability_data.Name == "紫电掌" or ability_data.Name == "妖梦-R点地" or ability_data.Name == "妖梦-终结-点" or ability_data.Name == "开枪弓箭发射" or ability_data.Name == "开枪-手枪" or ability_data.Name == "位移-祢豆子-飞踢" or ability_data.Name == "N毒刺炸裂" or ability_data.Name == "近战武器EGO-潮枯" or ability_data.Name == "近战武器枪-雷霆长枪" or ability_data.Name == "近战武器武士刀-七雷" or ability_data.Name == "开枪弓箭" or ability_data.Name == "开枪弓箭" or ability_data.Name == "近战武器EGO-缠魇丸3" or ability_data.Name == "替换-装备型-A-龙刃-镖" or ability_data.Name == "替换-A-幽灵鲨-串刺" or ability_data.Name == "替换-R-幽灵鲨-极刑" or ability_data.Name == "替换-装备型-R-青怒-奔夜" or ability_data.Name == "替换-装备型-A-青怒-绝影" or ability_data.Name == "替换-装备型-A-星辰短剑-Celia/Sable") then
              if ability_data.Name == "史尔特尔-R" or target_type == 2 or target_type == 4 or target_type == 6 then
                require("hera_boot").note("NATIVE TARGETING: " .. tostring(ability) .. "; " .. ability_data.Name)
                return true
              end
              local ability_handle = japi.EXGetUnitAbility(unit, type(ability) == "string" and S2ID(ability) or ability)
              if 0 < ability_handle and not is_cooling(ability_handle) then
                return cast_ability(unit, ability_handle, order, target_type)
              end
            end
          end
        end
      end
      if u.type == HeroType["志贵"] then
        if code ~= 83 and 0 < u:getdata("志贵连招暂停时间") then
          re = false
        end
        if code == 67 and u:getdata("志贵-魔术回路值") >= 300 and u:hasdata("志贵天赋-推土机") then
          u:select(Beibao[id1])
          message.order_immediate(852555)
          u:select()
        end
      end
      if u.type == HeroType["波风水门"] then
        if code == 70 then
          if 100 > u:getdata("波风水门-奥义充能值") then
            u:sendmessage("|cFFFFCC66奥义充能值不足|r")
          end
          if u:hasdata("波风水门-替身术冷却") then
            u:sendmessage("|cFFFFCC66替身术冷却中|r")
          end
          if 100 <= u:getdata("波风水门-奥义充能值") and not u:hasdata("波风水门-替身术冷却") and not u:hasdata("波风水门-零式发动中") then
            local mj = getunit(Beibao[id1])
            ClearSelection()
            SelectUnit(mj.handle, true)
            local ddx, ddy = message.mouse()
            message.order_point(YDWEAbilityId2OrderId("A0KO"), ddx, ddy)
            ClearSelection()
            SelectUnit(u.handle, true)
          end
        end
        if code == 86 and not u:hasdata("波风水门-通灵之术冷却") and not u:hasdata("茉子-兽化状态") then
          minato_summon.request()
        end
      end
      if u.type == HeroType["史尔特尔"] and code == 88 and 0 < u:getdata("史尔特尔-翔虫数量") and not u:hasdata("史尔特尔-翔虫释放中") and u:hasbuff("眩晕") then
        local mj = getunit(Beibao[id1])
        ClearSelection()
        SelectUnit(mj.handle, true)
        local ddx, ddy = message.mouse()
        message.order_point(YDWEAbilityId2OrderId("A0H8"), ddx, ddy)
        ClearSelection()
        SelectUnit(u.handle, true)
      end
      if u:hasdata("武器判定-无影剑") and not u:hasdata("无影剑-释放中") and not u:hasdata("无影剑-结束标记") and code == 69 then
        local mj = getunit(Ewl_Moniskill[id1])
        ClearSelection()
        SelectUnit(mj.handle, true)
        local ddx, ddy = message.mouse()
        message.order_point(YDWEAbilityId2OrderId("A017"), ddx, ddy)
        ClearSelection()
        SelectUnit(unit, true)
      end
    end
    if Xuanze[id1] then
      if code == 66 then
        local u = getunit(Hero[id1])
        if WsltButton:get_is_show() and not u:hasdata("往世乐土-B键关闭") then
          if WsltButton.showpanel:get_is_show() then
            WsltButton.showpanel:hide()
            uiy_hide()
          else
            WsltButton.showpanel:show()
          end
        end
      end
      if code == 512 and WsltButton.showpanel:get_is_show() then
        WsltButton.showpanel:hide()
        uiy_hide()
      end
    end
    if Xuanze[id1] then
      local ui_info = BQBInfo
      local Panel = ui_info.panel
      if code == KEY.T and not ui_info.is_show and Bqb_OpenClose then
        local x, y = game.get_mouse_pos()
        ui_info.x = x
        ui_info.y = y
        ui_info.id = 0
        x = x / 1920 * 0.8
        y = (1 - y / 1080) * 0.6
        japi.FrameSetAbsolutePoint(Panel._id, 4, x, y)
        Panel:show()
        ui_info.is_show = true
      end
    end
    return re
  end,
  key_up = function(msg)
    local code = msg.code
    local state = msg.state
    local id1 = LocalPlayerID
    local unit = japi.GetRealSelectUnit()
    if CheXuanze[id1] == true then
      local msg2
      if code == 87 then
        msg2 = tostring(id1) .. "W" .. "OFF"
      end
      if code == 83 then
        msg2 = tostring(id1) .. "S" .. "OFF"
      end
      if msg2 ~= nil then
        japi.DzSyncData("car", msg2)
      end
    end
    if unit ~= 0 and unit == Hero[id1] then
      local u = getunit(unit)
      if u:hasdata("弓箭系统-装备中") and code == 65 then
        local x, y = message.mouse()
        message.order_point(YDWEAbilityId2OrderId("A0DY"), x, y, FLAG["独立"] | FLAG["恢复"])
      end
      if code == 69 and Xuanze[id1] then
        if u.type == HeroType["八重樱"] and not u:hasdata("八重樱拔刀斩蓄力取消") then
          yae_release.request()
        end
        if u:hasdata("无影剑-释放中") then
          local mj = getunit(Ewl_Moniskill[id1])
          ClearSelection()
          SelectUnit(mj.handle, true)
          message.order_immediate(YDWEAbilityId2OrderId("A019"))
          ClearSelection()
          SelectUnit(unit, true)
        end
      end
    end
    if Xuanze[id1] then
      local ui_info = BQBInfo
      local Panel = ui_info.panel
      if code == KEY.T and Bqb_OpenClose and ui_info.is_show then
        local id = ui_info.id
        if id ~= 0 then
          local index = ui_info.bqb[id]
          ui_info.frame[id]:set_normal_image(ui_info.path[id])
          japi.DzSyncData("MSG", "BQB|" .. index)
        end
        ui_info.is_show = false
        Panel:hide()
      end
    end
    return true
  end
}

function message.hook(msg)
  local trace_input = msg.type == "mouse_down" or
    ((msg.type == "key_down" or msg.type == "key_up") and (msg.code == 81 or msg.code == 87 or msg.code == 69))
  if trace_input then
    local mx, my = message.mouse()
    input_trace.local_input(msg.type, japi.GetRealSelectUnit(),
      "code=" .. tostring(msg.code) .. " mouse_x=" .. tostring(mx) .. " mouse_y=" .. tostring(my))
  end
  if TestConsumeItemBagUIHandleMouse and TestConsumeItemBagUIHandleMouse(msg) then
    return false
  end
  local info = event_map[msg.type]
  if info then
    local result = info(msg)
    if trace_input then
      input_trace.local_input("RESULT " .. msg.type, japi.GetRealSelectUnit(), "allow=" .. tostring(result))
    end
    return result
  end
  return true
end

local event_map = {
  order_immediate = function(unit_handle, info)
    local id1 = LocalPlayerID
    local name, order_id, unknow, flag = table.unpack(info)
    local x, y = message.mouse()
    local unit = japi.GetRealSelectUnit()
    if unit ~= 0 and unit == Hero[id1] then
      local u = getunit(unit)
      if order_id == YDWEAbilityId2OrderId("S0CZ") then
        local sy = u.ownerid
        local bb = getunit(Beibao[sy])
        bb:select()
        message.order_point(YDWEAbilityId2OrderId("S0CY"), x, y, FLAG["独立"] | FLAG["恢复"])
        u:select()
      end
    end
    return true
  end
}

function message.order_hook(info)
  input_trace.local_input("ORDER_HOOK", japi.GetRealSelectUnit(), "kind=" .. tostring(info[1]) .. " order=" .. tostring(info[2]))
  local unit_handle = japi.GetRealSelectUnit()
  local event = event_map[info[1]]
  if event then
    return event(unit_handle, info)
  end
  return true
end
