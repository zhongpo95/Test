-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local dx = 0.8
local csa = 75
local w, h = 91 * dx, 71 * dx
local ddx = 1200
local ddy = 778
local ddsize = 1
if EnableCustomUI then
  ddx = 1185
  ddy = 856
  ddsize = 0.7
end
ZBButton = class.button:builder({
  x = ddx,
  y = ddy,
  w = w * ddsize,
  h = h * ddsize,
  sync_key = "zbbutton",
  showtext = "点击切换准备完毕(所有人准备完毕时跳过过波等待)",
  normal_image = "UI_ZbButton.blp",
  on_button_clicked = function(self)
    self:add_cd_animation(0, 0, 1, 1)
    self:set_cd(SYNC_BUTTON_CD, SYNC_BUTTON_CD)
    self:set_control_size(self:get_width() * 0.9, self:get_height() * 0.9)
    ac.wait(100, function()
      self:set_control_size(self:get_width() / 0.9, self:get_height() / 0.9)
    end)
    uiy_hide()
  end,
  on_button_mouse_enter = function(self)
    self:set_alpha(255)
    if self.showtext then
      uiy_show_text(self.showtext)
    end
  end,
  on_button_mouse_leave = function(self)
    self:set_alpha(csa)
    if self.showtext then
      uiy_hide()
    end
  end,
  on_sync_button_clicked = function(self, p, button)
    p = getplayer(p.handle)
    local sy = p.id
    if PlayerReady[sy] then
      PlayerReady[sy] = false
      SendMsgAll(p:getname() .. "|cFF7DBEF1取消了准备|r")
    else
      PlayerReady[sy] = true
      SendMsgAll(p:getname() .. "|cFF7DBEF1준비 완료|r")
    end
  end
})
ZBButton:set_alpha(csa)
ZBButton:hide()
MEDICINE_BLOOD = S2ID("I011")
MEDICINE_BLOOD_TC = S2ID("I0GR")
MEDICINE_YITAI = S2ID("I02F")
MEDICINE_MWX = S2ID("I02H")
MEDICINE_LNS = S2ID("I02E")
MEDICINE_HUIYI = S2ID("I030")
MEDICINE_XINGYOU = S2ID("I0GQ")
MEDICINE_NIUQU = S2ID("I0DK")
MEDICINE_JINGHUA = S2ID("I00J")
MEDICINE_QIANGHUA = S2ID("I0Q0")
MEDICINE_JINGHUA_SJ = S2ID("I0EV")
MEDICINE_FENGMOHU = S2ID("I071")
MEDICINE_ZHENYAOHU = S2ID("I072")
MEDICINE_LINGJIEJING = S2ID("I0GT")
MEDICINE_SHALUJIEJING = S2ID("I09P")
MEDICINE_XUEHUAI = S2ID("I01Q")
local med1 = {
  MEDICINE_BLOOD,
  MEDICINE_YITAI,
  MEDICINE_MWX,
  MEDICINE_LNS,
  MEDICINE_JINGHUA
}
local med2 = {
  MEDICINE_HUIYI,
  MEDICINE_XINGYOU
}
local strz = {
  {
    text = "war3mapImported\\BTNMedcine_Xingyou.blp",
    func = function(u)
      local sy = u.ownerid
      u:deldata("商店购买中")
      local count = u:getdata("商店购买次数")
      local xh = 10 + 10 * count * (count - 1)
      if xh <= u:getgold() then
        u:changedata("商店购买次数", 1)
        u:additem(MEDICINE_XINGYOU, 2)
        u:addgold(-1 * xh)
        YisiSystem.chat({
          u = u,
          text = "选择成功"
        })
      else
        YisiSystem.chat({
          u = u,
          text = "你的积分不够！"
        })
      end
    end
  },
  {
    text = "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp",
    func = function(u)
      local sy = u.ownerid
      u:deldata("商店购买中")
      local count = u:getdata("商店购买次数")
      local xh = 10 + 10 * count * (count - 1)
      if xh <= u:getgold() then
        u:changedata("商店购买次数", 1)
        for i = 1, 2 do
          if GetRandom100(80) then
            u:additem(med1[GetRandomInt(1, #med1)])
          else
            u:additem(med2[GetRandomInt(1, #med2)])
          end
        end
        u:addgold(-1 * xh)
        YisiSystem.chat({
          u = u,
          text = "选择成功"
        })
      else
        YisiSystem.chat({
          u = u,
          text = "你的积分不够！"
        })
      end
    end
  },
  {
    text = "ReplaceableTextures\\CommandButtons\\BTNGatherGold.blp",
    func = function(u)
      local sy = u.ownerid
      u:deldata("商店购买中")
      local count = u:getdata("商店购买次数")
      local xh = 10 + 10 * count * (count - 1)
      if xh <= u:getgold() then
        u:changedata("商店购买次数", 1)
        for i = 1, 2 do
          local wpid = "I085"
          if GetRandom100(0.5) then
            wpid = "I087"
          elseif GetRandom100(1) then
            wpid = "I08A"
          elseif GetRandom100(5) then
            wpid = "I086"
          else
            wpid = "I085"
          end
          u:additem(wpid)
        end
        u:addgold(-1 * xh)
        YisiSystem.chat({
          u = u,
          text = "选择成功"
        })
      else
        YisiSystem.chat({
          u = u,
          text = "你的积分不够！"
        })
      end
    end
  },
  {
    text = "war3mapImported\\BTNCommand_Stop.blp",
    func = function(u)
      local sy = u.ownerid
      u:deldata("商店购买中")
      YisiSystem.chat({
        u = u,
        text = "谢谢惠顾！"
      })
    end
  }
}

function yisisdgoumai(u)
  if not u:hasdata("商店购买中") then
    u:setdata("商店购买中")
    local count = u:getdata("商店购买次数")
    local xh = 10 + 10 * count * (count - 1)
    YisiSelectChat(u, "给我" .. math.floor(xh) .. "积分,便可以增强你的力量,你想要什么呢", strz, "图标", {
      "|cFFCC99FF获得两瓶星幽药剂|r",
      "|cFFCC99FF获得两瓶随机药剂|r",
      "|cFFCC99FF获得两件遗物|r",
      "|cFFCC99FF返回|r"
    })
  end
end

local dddx = 1285
local dddy = 778
local dddsize = 1
if EnableCustomUI then
  dddx = 1255
  dddy = 856
  dddsize = 0.7
end
ShangdianButton = class.button:builder({
  x = dddx,
  y = dddy,
  w = w * dddsize,
  h = h * dddsize,
  sync_key = "SDButton",
  normal_image = "BTNICON_Shangdian.tga",
  on_button_clicked = function(self)
    self:set_control_size(self:get_width() * 0.9, self:get_height() * 0.9)
    ac.wait(100, function()
      self:set_control_size(self:get_width() / 0.9, self:get_height() / 0.9)
    end)
  end,
  on_button_mouse_enter = function(self)
    self:set_alpha(255)
  end,
  on_button_mouse_leave = function(self)
    self:set_alpha(csa)
  end,
  on_sync_button_clicked = function(self, p, button)
    p = getplayer(p.handle)
    local sy = p.id
    local u = getunit(Hero[sy])
    yisisdgoumai(u)
  end
})
ShangdianButton:set_alpha(csa)
ShangdianButton:hide()

function heroselect3(unit)
  local u = getunit(unit)
  local p = getplayer(u.owner)
  local sy = u.ownerid
  if WsltInitPersonalShopHero then
    WsltInitPersonalShopHero(u)
  end
  if u:islocal() then
    if not EnableCustomUI then
      HeroStateButton[sy]:show()
    end
    UI_YisiChat:show()
    UI_YisiChatButton:show()
  end
  TriggerRegisterUnitEvent(Trg_ItemUse, u.handle, EVENT_UNIT_USE_ITEM)
  TriggerRegisterUnitEvent(Trg_ItemGet, u.handle, EVENT_UNIT_PICKUP_ITEM)
  TriggerRegisterUnitEvent(Trg_UnitSkill, u.handle, EVENT_UNIT_SPELL_EFFECT)
  TriggerRegisterUnitEvent(Trg_UNIT_ISSUED_POINT_ORDER, u.handle, EVENT_UNIT_ISSUED_POINT_ORDER)
  TriggerRegisterUnitEvent(Trg_UNIT_ATTACKED, u.handle, EVENT_UNIT_ATTACKED)
  TriggerRegisterUnitEvent(Trg_UNIT_ISSUED_TARGET_ORDER, u.handle, EVENT_UNIT_ISSUED_TARGET_ORDER)
  TriggerRegisterUnitEvent(Trg_ITEM_DROP, u.handle, EVENT_UNIT_DROP_ITEM)
  TriggerRegisterUnitEvent(Trg_UnitReadySkill, u.handle, EVENT_UNIT_SPELL_CHANNEL)
  TriggerRegisterUnitEvent(Trg_UnitEndSkill, u.handle, EVENT_UNIT_SPELL_FINISH)
  TriggerRegisterUnitEvent(Trg_EVENT_UNIT_SELECTED, u.handle, EVENT_UNIT_SELECTED)
  u:addtrgevent("玩家-选择单位", function(args)
    if u.handle == args.unit and u:hasdata("假面-持有") and u.owner ~= args.player then
      ClearSelectionForPlayer(u.owner)
    end
  end)
  u:addtrgevent("单位-使用物品", function(args)
    weaponchangetrg(args.unit, args.item)
    local medicine_sample
    if GetItemTypeId(args.item) == MEDICINE_XINGYOU then
      medicine_sample = require("hera_medicine_trace").begin(u, args.item)
    end
    MedicineAct(args.unit, args.item)
    if medicine_sample then require("hera_medicine_trace").finish(medicine_sample) end
    itemuseTrg(args.unit, args.item)
    RemainsUse(args.unit, args.item)
    modelChangeTrg(args.unit, args.item)
    QuanxianUse(args.unit, args.item)
    gunchangetrg(args.unit, args.item)
  end)
  u:addtrgevent("单位-发动技能", function(args)
    weapondowntrg(args.unit, args.skill)
    weaponusetrg(args.unit, args.skill)
    moveskilltrg(args)
    stopskillfunc(args)
    heroGiveItemTrg(args.unit, args.skill)
    itemskillTrg(args)
    modeldowntrg(args.unit, args.skill)
    currency_E_Hero(args)
    if HasData(args.skill, "固有技能") or HasData(args.skill, "位移技能") then
      Guyouskill(args)
    end
  end)
  u:addtrgevent("单位-获得物品", function(args)
    itemgetTrg(args.unit, args.item)
    boxgettrg(args.unit, args.item)
    itempowergetTrg(args.unit, args.item)
    RemainsGet(args.unit, args.item)
  end)
  u:addtrgevent("单位-丢弃物品", function(args)
    itemdropTrg(args.unit, args.item)
  end)
  u:addtrgevent("单位-指定物体指令", function(args)
    local order = args.orderid
    if 852002 <= order and order <= 852007 then
      local u = getunit(args.unit)
      if RightGive[u.ownerid] then
        local item = args.item
        local wp = u:getcountitem(order - 852001)
        if item == wp then
          givewp(u, wp)
        end
      end
    end
  end)
  u:addtrgevent("单位-发动技能", function(args)
    gunskilltrg(args)
  end)
  local x, y = u:getxy()
  u:setdata("位移点X", x)
  u:setdata("位移点Y", y)
  u:triggeraddevent(GunCommand, EVENT_UNIT_ISSUED_POINT_ORDER)
  u:triggeraddevent(Ewys_02, EVENT_UNIT_ISSUED_POINT_ORDER)
  u:triggeraddevent(Ewys_02, EVENT_UNIT_ISSUED_TARGET_ORDER)
  u:triggeraddevent(Ewys_03, EVENT_UNIT_ISSUED_ORDER)
  u:triggeraddevent(HeroDeath, EVENT_UNIT_DEATH)
  u:triggeraddevent(DamageSystemTrg2, EVENT_UNIT_DAMAGED)
  TriggerRegisterUnitEvent(Levelup, u.handle, EVENT_UNIT_HERO_LEVEL)
  p:addtrgevent("玩家-聊天", function(args)
    local msg = args.chat
    local str = msg:sub(1, 1)
    if msg == "爡欙猣巎戃噍堮愱爤爥愳灉幠攐攑牗喭犤犥斄毊嬚嶳爨爩廧廨廪" or string.lower(msg) == "kikyo" or string.lower(msg) == "-ryr598" or string.lower(msg) == "inuyasha" then
      return
    end
    -- 채팅 숨김은 명령 실행까지 막지 않는다.
    chatcommand(args)
    if u:hasdata("聊天-过滤指令") and (str == "-" or str == "+") then
      if string.lower(msg) == "-cc" and u.owner == LocalPlayer then
        ClearTextMessages()
        UI_NewChatClear()
      end
      return
    end

    -- 명령 판정 후에는 사용자가 입력한 한국어 원문을 채팅에 표시한다.
    msg = args.raw_chat or msg
    if u:hasdata("变异判定-矢泽妮可") and GetRandom100(25) then
      msg = msg .. "nico~"
      if GetRandom100(25) and not u:hasdata("矢泽妮可-激励冷却") then
        if GetRandom100(10) then
          PlayGlobalSound(Sound_Shizenike_03)
        else
          PlayGlobalSound(Sound_Shizenike_02)
        end
        u:settimedata("矢泽妮可-激励冷却", 10)
        ForGroupLuaNew(Group_PlayHero, function(xq)
          local sy2 = xq.ownerid
          if xq.handle ~= u.handle then
            xq:sendmessage("|cFFFF537E[矢泽妮可-激励]提升25%伤害加成60秒")
            ChangeTimeValue(DamageSystem_Shjc, sy, 0.25, 60)
          end
        end)
      end
    end
    if u:hasdata("隐藏职业-喵星人已揭露") and GetRandom100(25) then
      msg = msg .. "喵"
    end
    local showname = p:getname()
    if Boolean_ColorName[p.id] then
      showname = ShowName[p.id] or ""
    end
    local message = string.format("%s%s|r:%s", p:getColorWord(), showname, msg)
    UI_NewChat(p, message, msg)
    Time_PlayerNotChatTime[p.id] = 0
  end)
  if u:islocal() then
    Shouce_Button:show()
    UIskillbutton:show()
    ZBButton:show()
    WsltButton:show()
  end
end

local jhplayer = require("jh.ac.player")
local slk = require("jass.slk")
local clearb = false
local spshotskill = {
  "A1N7",
  "A1N6",
  "A1N3",
  "A1N2",
  "A1N4",
  "A1N5",
  "A1N8",
  "A1N9",
  "A1NA",
  "A1NB",
  "A1NC",
  "A1NC",
  "A1ND",
  "A1NE",
  "A1NF"
}
local notspshotskill = {
  "A0DO",
  "A06V",
  "A034",
  "A00P",
  "A008",
  "A02J",
  "A08G",
  "A0DP",
  "A03A",
  "A03B",
  "A03D",
  "A0N4",
  "A0N5",
  "A0N6"
}
UI_Newchatfont = 1
CD_Omaiwamo = false

function formatNumber(num)
  local str = tostring(math.floor(num))
  local formatted = str:reverse():gsub("(%d%d%d)", "%1,")
  return formatted:reverse():gsub("^,", "")
end

local moviecd = false
local K_W = 10000
local K_M = 1000000
local K_G = 1000000000
local K_T = 1000000000000
local K_P = 1000000000000000
local K_E = 1000000000000000000

local function format_damage_value(v)
  v = tonumber(v) or 0
  if v < 100000 then
    return tostring(math.floor(v + 0.5))
  end
  v = v / 10000
  local unit = "W"
  if 1000 <= v then
    v = v / 1000
    unit = "M"
    if 1000 <= v then
      v = v / 1000
      unit = "G"
      if 1000 <= v then
        v = v / 1000
        unit = "T"
        if 1000 <= v then
          v = v / 1000
          unit = "P"
          if 1000 <= v then
            v = v / 1000
            unit = "E"
          end
        end
      end
    end
  end
  return ("%.1f%s"):format(v, unit)
end

local function format_damage_with_percent(v, total)
  v = tonumber(v) or 0
  total = tonumber(total) or 0
  local vStr = format_damage_value(v)
  local p = 0
  if 0 < total then
    p = v / total * 100
  end
  return vStr, p
end

local function get_percent_color(rate)
  if 50 <= rate then
    return "|cFFFF4040"
  elseif 20 <= rate then
    return "|cFFFFA040"
  elseif 5 <= rate then
    return "|cFFFFFF80"
  else
    return "|cFF808080"
  end
end

local function get_sorted_damage_list_for_player(pid)
  local pStat = DAMAGE_STAT_BY_BJ[pid]
  if not pStat then
    return {}, 0
  end
  local totalAll = 0
  for _, stat in pairs(pStat) do
    totalAll = totalAll + (stat.total or 0)
  end
  local list = {}
  for bj, stat in pairs(pStat) do
    table.insert(list, {bj = bj, stat = stat})
  end
  table.sort(list, function(a, b)
    return (a.stat.total or 0) > (b.stat.total or 0)
  end)
  return list, totalAll
end

local function build_damage_row_text(bj, stat, totalAll)
  local totalStr, rate = format_damage_with_percent(stat.total or 0, totalAll)
  local maxStr = format_damage_value(stat.max or 0)
  local color = get_percent_color(rate)
  local line = ("[%s] %d次 总伤%s(%.1f%%) 最高%s"):format(tostring(bj), stat.times or 0, totalStr, rate, maxStr)
  return color .. line .. "|r"
end

local function SaveDPSFile(pid)
  local u = getunit(Hero[pid])
  local list, totalAll = get_sorted_damage_list_for_player(pid)
  local dateStr = os.date("%Y-%m-%d_%H%M%S")
  local savestr = "[DPS_Result]\n"
  savestr = savestr .. string.format("Player = %s\n", GetPlayerName(u.owner))
  savestr = savestr .. string.format([[
TotalDamage = %s

]], format_damage_value(totalAll))
  savestr = savestr .. "[Ranking]\n"
  savestr = savestr .. "; 排名 | 标记名称 | 次数 | 总伤 | 最高 | 占总伤比\n"
  for index, item in ipairs(list) do
    local stat = item.stat or {}
    local times = tonumber(stat.times) or 0
    local total = tonumber(stat.total) or 0
    local max = tonumber(stat.max) or 0
    local totalStr, rate = format_damage_with_percent(total, totalAll)
    local maxStr = format_damage_value(max)
    savestr = savestr .. string.format("%d = %s | %d次 | %s | %s | %.1f%%\n", index, tostring(item.bj), times, totalStr, maxStr, rate)
  end
  local filename = string.format("dps_%s.ini", dateStr)
  storm.save("tloc\\" .. filename, savestr)
  u:sendmessage(string.format("|cFF7DBEF1已导出详细 DPS 清单 → tloc\\%s|r", filename))
end

local function ShowDamageStatToUnit(u)
  local pid = u.ownerid
  if not pid then
    return
  end
  local list, totalAll = get_sorted_damage_list_for_player(pid)
  u:sendmessage("|cFF99CCFF========== 伤害统计 =========|r")
  for index, item in ipairs(list) do
    if 10 < index then
      break
    end
    local line = build_damage_row_text(item.bj, item.stat, totalAll)
    u:sendmessage(line)
  end
end

local mjz = CreateGroupLua()

function chatcommand(args)
  local str = args.chat
  local player = args.player
  local p = getplayer(player)
  local sy = p.id
  local unit = Hero[sy]
  local u = getunit(unit)
  if not u then
    return
  end
  local first = string.sub(str, 1, 1)
  local len = string.len(str)
  local p = getplayer(player)
  str = string.lower(str)
  -- 사용자가 입력한 순서도 원래 조회 명령으로 받는다.
  local aliases = {["-zx"] = "-xz", ["-zx2"] = "-xz2", ["-zx4"] = "-xz4"}
  str = aliases[str] or str
  if str == "-xz" or str == "-xz2" or str == "-xz4" then
    require("hera_boot").note("CHAT COMMAND " .. str .. "; player=" .. tostring(sy))
  end
  if System_Chat[sy] then
    for i = 1, 8 do
      jhplayer[i]:sendMsg(u:getplayername() .. "|cFF7DBEF1：" .. str .. "|r")
    end
  end
  if p.id == SeletPlayerID then
    if str == "-next" then
      SendMsgAll("|cFF7DBEF1强行准备完毕|r")
      for i = 1, 6 do
        if Xuanze[i] and not PlayerReady[i] then
          PlayerReady[i] = true
        end
      end
    end
    if str == "-banrelive" and Boolean_AnshenBattle and not u:hasdata("暗神指令冷却") then
      u:settimedata("暗神指令冷却", 360)
      if not Boolean_AnshenBattleBanFuhuo then
        Boolean_AnshenBattleBanFuhuo = true
        SendMsgAll("|cFF9999FF禁用了多人复活|r")
      else
        Boolean_AnshenBattleBanFuhuo = false
        SendMsgAll("|cFF9999FF启用了多人复活|r")
      end
    end
    if str == "-clear" and not clearb then
      clearb = true
      SendMsgAll("20秒后清理地面")
      ac.wait(20000, function()
        SendMsgAll("清理地面")
        clearb = false
        EnumItemsInRectBJ(RECT_PlayArea, function()
          local wp = GetEnumItem()
          if not HasData(wp, "不会被清除") and (tonumber(slk.item[ID2S(GetItemTypeId(wp))].HP) == 75 or GetItemTypeId(wp) == S2ID("I0L5") or HasData(GetItemTypeId(wp), "模块等级")) then
            RemoveItemLua(wp)
          end
        end)
      end)
    end
  end
  local wish = tonumber(str:match("^%-xy([1-5])$"))
  if wish then
    if YangjianUseWish then
      YangjianUseWish(u, wish)
    end
    return
  end
  if str:match("-hpmon(%d+)") then
    local multiplier = tonumber(str:match("-hpmon(%d+)"))
    if 1 <= multiplier and multiplier <= 100 then
      MWTQ_HpMon = multiplier
      SendMsgAll("|cFF990000魔王天囚-怪物生命上限倍率:" .. MWTQ_HpMon)
    end
  end
  if str:match("-hpboss(%d+)") then
    local multiplier = tonumber(str:match("-hpboss(%d+)"))
    if 1 <= multiplier and multiplier <= 1000 then
      MWTQ_HpBOSS = multiplier
      SendMsgAll("|cFF990000魔王天囚-BOSS生命上限倍率:" .. MWTQ_HpBOSS)
    end
  end
  if str:match("-atkmon(%d+)") then
    local multiplier = tonumber(str:match("-atkmon(%d+)"))
    if 1 <= multiplier and multiplier <= 1000 then
      MWTQ_AtkMon = multiplier
      SendMsgAll("|cFF990000魔王天囚-怪物伤害倍率:" .. MWTQ_AtkMon)
    end
  end
  if str:match("-atkboss(%d+)") then
    local multiplier = tonumber(str:match("-atkboss(%d+)"))
    if 1 <= multiplier and multiplier <= 1000 then
      MWTQ_AtkBOSS = multiplier
      SendMsgAll("|cFF990000魔王天囚-BOSS伤害倍率:" .. MWTQ_AtkBOSS)
    end
  end
  if str:match("-mw(%d+)") then
    local multiplier = tonumber(str:match("-mw(%d+)"))
    if 0 <= multiplier and multiplier <= 7 then
      MWTQ_Mw = multiplier
      SendMsgAll("|cFF990000魔王天囚-BOSS魔王特性数量:" .. MWTQ_Mw)
    end
  end
  if str == "-debug1" then
    SendMsgAll("过波修复")
    if AllNumofMonster <= 5 and 5 >= LeftNumofMonster then
      attack_next:resume()
      BossBattle = false
      ExtraBattle = false
      ExBossBattle = false
    end
  end
  if str == "-debug4" then
    SendMsgAll("游戏结束判定")
    local b = false
    if ModeSelect_Light then
      b = true
      ModeSelect_Light = false
    end
    CommandDeath = true
    GameOver()
    CommandDeath = false
    if b then
      ModeSelect_Light = true
    end
  end
  if str == "-clearmemory" or str == "-qchc" then
    SendMsgAll("清除游戏缓存")
    clearmemory()
  end
  if str == "-recam" then
    ResetToGameCameraForPlayer(u.owner, 0)
    p:setcameraheight(Cam_height[u.ownerid], 0)
  end
  if (str == "-jytx" or str == "-monsterfx" or str == "-魔王特效" or str == "-怪物特效") and IsMonsterTraitEffectVisible and SetMonsterTraitEffectVisible then
    local visible = not IsMonsterTraitEffectVisible()
    SetMonsterTraitEffectVisible(visible)
    if visible then
      SendMsgAll("|cFF7DBEF1已开启魔王/怪物特性特效|r")
    else
      SendMsgAll("|cFF999999已屏蔽魔王/怪物特性特效|r")
    end
  end
  if str == "-qx" and 0 < #QxString[sy] then
    QuanxianShow(u)
  end
  if str == "-mfsx" and 0 >= u:getmaxmp() then
    u:setmaxmp(1)
  end
  if str == "你已经死了" and not CD_Omaiwamo then
    SendMsgAll(u:getplayername() .. "|cFF999999：おまえはもうしんでいる|r")
    PlayGlobalSound(Sound_Jiancilang_01)
    CD_Omaiwamo = true
    Boolean_Nani = false
    if BossBattle then
      local boss = getunit(BOSS)
      if boss:getperhp() >= 95 and not boss:hasdata("健次郎-你已经死了") then
        boss:setdata("健次郎-你已经死了")
        if not Caidan_Jiancilang or u:hasdata("变异判定-健次郎") then
          flashphoto({
            photo = "Ph_Jiancilang.tga"
          })
          ForGroupLuaNew(Group_PlayHero, function(xq)
            xq:buffset(u.handle, 3, "无敌")
          end)
        end
        ac.wait(3000, function()
          if not boss:hasdata("空白-驳回效果") then
            SendMsgAll(boss:getname() .. "|cFF999999：なに？|r")
            PlayGlobalSound(Sound_Jiancilang_02)
            SendMsgAll(boss:getname() .. "|cFF990000被激怒了|r")
            ac.wait(1, function()
              boss:elitesextrachange()
            end)
            if not Caidan_Jiancilang and 1 >= Group_Counts(Group_Xingcunzu) and u:isalive() and Hero_Shenhua_Now[sy] == 0 and u:getdata("传奇数量") == 0 then
              AdvanceGet["健次郎"](u)
            end
          else
            boss:deldata("空白-驳回效果")
          end
        end)
      end
    end
    ac.wait(5000, function()
      Boolean_Nani = false
    end)
    ac.wait(30000, function()
      CD_Omaiwamo = false
    end)
  end
  if str == "-ewys" then
    if u:hasdata("系统-关闭额外移速") then
      u:deldata("系统-关闭额外移速")
      u:sendmessage("|cFF6633FF开启额外移速|r")
    else
      u:setdata("系统-关闭额外移速")
      u:sendmessage("|cFF6633FF关闭额外移速|r")
    end
  end
  if str == "-verfix" then
    u:clearbuff("B02U")
    u:buffset(u.handle, 1, "眩晕")
  end
  if str == "-sd" then
    u:deldata("商店购买中")
  end
  if str == "-fly" then
    if u:hasdata("系统-关闭飞行") then
      u:deldata("系统-关闭飞行")
      u:sendmessage("|cFF6633FF开启飞行|r")
    else
      u:setdata("系统-关闭飞行")
      u:sendmessage("|cFF6633FF关闭飞行|r")
    end
  end
  if str == "-filtered" then
    if u:hasdata("聊天-过滤指令") then
      u:deldata("聊天-过滤指令")
      u:sendmessage("|cFF6633FF关闭指令过滤|r")
    else
      u:setdata("聊天-过滤指令")
      u:sendmessage("|cFF6633FF开启指令过滤|r")
      if GetRandom100(4) then
        if GetRandom100(50) then
          u:playseensound(Sound_Filter_01)
        else
          u:playseensound(Sound_Filter_03)
        end
      else
        u:playseensound(Sound_Filter_02)
      end
    end
  end
  if str == "bqbc" then
    if u:hasdata("聊天-关闭表情包语音") then
      u:deldata("聊天-关闭表情包语音")
      u:sendmessage("|cFF6633FF开启表情包语音|r")
    else
      u:setdata("聊天-关闭表情包语音")
      u:sendmessage("|cFF6633FF关闭表情包语音|r")
    end
  end
  if (str == "胜利的法则已然确定" or str == "现在我的手中抓住了未来" or str == "来细数你的罪恶吧" or str == "神说我还不能死在这里" or str == "我也要加把劲啊") and u:isingroup(Group_DeathHero) then
    Youxianfuhuo = u.handle
    u:setdata("复活台词", str)
    u:sendmessage("|cFF7DBEF1复活优先级上升|r")
  end
  if str == "-dps" then
    ShowDamageStatToUnit(u)
  end
  if str == "-dpslist" and u:islocal() then
    SaveDPSFile(u.ownerid)
  end
  if str == "-dpsc" then
    u:sendmessage("|cFFCC0000清空伤害统计细分")
    DAMAGE_STAT_BY_BJ[sy] = {}
  end
  if str == "-xz4" then
    getunit(Ewl_State[sy]):select()
  end
  if str == "-model" and u:hasdata("模型-变化") then
    japi.SetUnitModel(u.handle, u:getdata("模型-变化"))
    u:setsize(u:getdata("模型-大小"))
    japi.SetUnitName(u.handle, u:getdata("模型-名字"))
    u:setdata("单位-大头像", u:getdata("模型-大头像"))
  end
  if str == "-font" and player == LocalPlayer then
    UI_Newchatfont = UI_Newchatfont + 1
    if UI_Newchatfont == 4 then
      UI_Newchatfont = 1
    end
    p:sendMsg("切换聊天字体" .. UI_Newchatfont)
  end
  if str == "-relive" then
    if Boolean_Zhenhong_Ciyuanbisuo then
      u:sendmessage("|cFF33CCFF次元闭锁中|r")
      return
    end
    if Keyan_Posuilingyu then
      u:sendmessage("|cFF33CCFF[科研模式]破碎领域阻止|r")
      return
    end
    if u:hasdata("暗神-禁用复活") or Boolean_AnshenBattle then
      u:sendmessage("|cff8133ff已禁用|r")
      return
    end
    if u:isingroup(Group_PlayHero) and u:gethp() <= 0 and not u:hasdata("死亡中英雄") then
      herodeath(u.handle, BOSS_DEATH)
    end
    if u:hasdata("诅咒-灵体化") and not u:hasdata("变异判定-歼灭天使") and not u:hasdata("阿卡多-死河限制") and not u:hasdata("吉普利露-禁忌化") and u:isingroup(Group_DeathHero) then
      local g = GetUnitsOfPlayerAndTypeIdLua(u.owner, S2ID("e000"))
      if Group_Counts(g) == 0 then
        local zs = 240
        if ModeSelect_Light then
          zs = 120
        end
        if Nandu_Choose == 4 then
          zs = zs * 1.5
        end
        if 5 <= Nandu_Choose then
          zs = zs * 2
        end
        if Nandu_Choose == 1 then
          zs = zs * 0.5
        end
        if zs <= System_Fuhuo_Linglizhi[sy] then
          System_Fuhuo_Linglizhi[sy] = System_Fuhuo_Linglizhi[sy] - zs
          local x, y = u:getxy()
          HeroRelive(u.handle, x, y, 3)
        else
          u:sendmessage("|cFF33CCFF灵力值不足，所需灵力值：" .. math.floor(zs) .. "|r")
          u:sendmessage("|cFF33CCFF当前灵力值：" .. math.floor(System_Fuhuo_Linglizhi[sy]))
        end
      end
    end
  end
  if str == "-spshot" then
    if u:hasdata("枪械射击-快捷施法") then
      u:deldata("枪械射击-快捷施法")
      u:sendmessage("|cFF6633FF关闭快捷射击|r")
      for i = 1, #spshotskill do
        u:banskill(spshotskill[i])
      end
      for i = 1, #notspshotskill do
        u:banskill(notspshotskill[i], false)
      end
    else
      u:setdata("枪械射击-快捷施法")
      u:sendmessage("|cFF6633FF开启快捷射击|r")
      for i = 1, #spshotskill do
        u:banskill(spshotskill[i], false)
      end
      for i = 1, #notspshotskill do
        u:banskill(notspshotskill[i])
      end
    end
  end
  if Mode_Dabamoshi then
    local x, y = u:getxy()
    local jd = u:getface()
    x, y = PolarXY(x, y, 500, jd)
    if str == "bz" then
      local mj = CreateMonster("h008", x, y, 0)
      mj = getunit(mj)
      mj:setdata("伤害测试标记")
      mj:groupadd(mjz)
      attackshuaguai(mj.handle)
      mj:setmaxhp(1.0E7)
    end
    if str == "bossbz" then
      local mj = CreateMonster("h008", x, y, 0)
      mj = getunit(mj)
      mj:setdata("伤害测试标记")
      mj:groupadd(mjz)
      bossstateset(mj)
      mj:setmaxhp(1.0E7)
    end
    if str == "qcbz" then
      ForGroupLuaNew(mjz, function(xq)
        xq:groupremove(mjz)
        xq:remove()
      end)
    end
    if str == "hf" then
      u:sethp(100, true)
      u:setmp(100, true)
      Hero_Tili[sy] = Hero_Tili_Max[sy]
    end
    if string.sub(str, 1, 2) == "lv" then
      local number = tonumber(string.sub(str, 3, len))
      if number == 0 or number == nil then
        number = 5
      end
      u:addlevel(number)
    end
  end
  if str == "-movie" and not moviecd then
    flashphoto({
      photo = "Ph_Akalin.tga"
    })
    PlayGlobalSound(Sound_Akalin)
    moviecd = true
    ac.wait(180000, function()
      moviecd = false
    end)
  end
  if str == "-uid" then
    u:sendmessage("平台ID：" .. OID[sy])
    u:sendmessage("UID：" .. NCDU[sy])
  end
  if string.sub(str, 1, 5) == "-roll" then
    local number = tonumber(string.sub(str, 6, len))
    if number and 0 < number then
      SendMsgAll(u:getplayername() .. "|cFF7DBEF1掷出了" .. math.floor(GetRandomInt(1, number)) .. "点(上限" .. math.floor(number) .. ")|r")
    else
      SendMsgAll(u:getplayername() .. "|cFF7DBEF1掷出了" .. math.floor(GetRandomInt(1, 100)) .. "点(上限" .. math.floor(100) .. ")|r")
    end
  end
  if str == "dmg off" then
    if Dmgshow[sy] == 1 then
      Dmgshow[sy] = 2
      u:sendmessage("|cFF7DBEF1关闭伤害显示|r")
    else
      Dmgshow[sy] = 1
      u:sendmessage("|cFF7DBEF1开启伤害显示|r")
    end
  end
  if str == "-dxd" and player == LocalPlayer then
    if Dxdtextshow then
      p:sendMsg("隐藏属性值判定结果")
      Dxdtextshow = false
    else
      p:sendMsg("显示属性值判定结果")
      Dxdtextshow = true
    end
  end
  if str == "-tt" and player == LocalPlayer then
    if Bqb_OpenClose then
      u:sendmessage("|cFF7DBEF1关闭表情包|r")
      Bqb_OpenClose = false
    else
      u:sendmessage("|cFF7DBEF1开启表情包|r")
      Bqb_OpenClose = true
    end
  end
  if str == "-noshock" and u:islocal() then
    if ShockCameraBoolean then
      u:sendmessage("|cFF7DBEF1关闭所有镜头摇晃|r")
      ShockCameraBoolean = false
    else
      u:sendmessage("|cFF7DBEF1开启所有镜头摇晃|r")
      ShockCameraBoolean = true
    end
  end
  if str == "-summon" then
    if Summon_Damageoff[sy] then
      u:sendmessage("|cFF7DBEF1开启召唤物伤害|r")
      Summon_Damageoff[sy] = false
    else
      u:sendmessage("|cFF7DBEF1关闭召唤物伤害|r")
      Summon_Damageoff[sy] = true
    end
  end
  if str == "-shutup" then
    if not u:hasdata("系统-清净模式") then
      u:setdata("系统-清净模式")
      u:sendmessage("|cFF7DBEF1关闭部分变异音效|r")
    else
      u:deldata("系统-清净模式")
      u:sendmessage("|cFF7DBEF1开启部分变异音效|r")
    end
  end
  if str == "bqbyx" then
    local group_key
    if u:hasdata("英雄-史尔特尔") then
      group_key = "s"
    end
    if u:hasdata("青水皮肤-茉子") then
      group_key = "m"
    end
    if u:hasdata("英雄-千咲") then
      group_key = "q"
    end
    if group_key and bqb_change_group(u, group_key, true) then
      u:sendmessage("|cFF7DBEF1切换特殊表情包组")
    else
      u:sendmessage("|cFF7DBEF1未满足特殊表情包组条件")
    end
  end
  if str == "-kzt" and u:islocal() then
    console.enable = true
  end
  if str == "-testyb" then
    if u:islocal() then
      console.enable = true
    end
    local l = {}
    require("util.异步检测")(l)
    l.begin_async_check()
  end
  if str == "-test2222" and CIUC[sy] == "-294228084" then
    ForGroupLuaNew(Group_PlayHero, function(xq)
      xq:additem(MEDICINE_YITAI, 10000)
      xq:additem(MEDICINE_HUIYI, 10000)
      xq:additem(MEDICINE_MWX, 10000)
      xq:additem(MEDICINE_BLOOD, 10000)
      xq:addwood(1000000)
      xq:addgold(1000000)
      xq:setdata("残机剩余数量", 10000)
      xq:setusedfodd(u:getdata("残机剩余数量"))
      ac.loop(100, function()
        xq:changekyx(-100)
      end)
    end)
  end
  if str == "bqb1" then
    bqb_change_group(u, "1", true)
    u:sendmessage("|cFF7DBEF1切换表情包组1")
  end
  if str == "bqb2" then
    bqb_change_group(u, "2", true)
    u:sendmessage("|cFF7DBEF1切换表情包组2")
  end
  if str == "bqb3" then
    bqb_change_group(u, "3", true)
    u:sendmessage("|cFF7DBEF1切换表情包组3")
  end
  if str == "bqb4" then
    bqb_change_group(u, "4", true)
    u:sendmessage("|cFF7DBEF1切换表情包组4")
  end
  if str == "bqb5" then
    bqb_change_group(u, "5", true)
    u:sendmessage("|cFF7DBEF1切换表情包组5")
  end
  if str == "bqb6" or str == "bqbwang" then
    if bqb_change_group(u, "6", true) then
      u:sendmessage("|cFF7DBEF1切换表情包组[哈密瓜雪糕]")
    else
      u:sendmessage("|cFF7DBEF1未拥有权限[哈密瓜雪糕]")
    end
  end
  if str == "-hlp" then
    u:sendmessage("|cFF7DBEF1切换边框装饰是否显示")
    if u:islocal() then
      if Biankuang_Zhuangshi then
        if Biankuang_Zhuangshi.close then
          Biankuang_Zhuangshi.close = nil
          Biankuang_Zhuangshi:set_alpha(255)
        else
          Biankuang_Zhuangshi.close = true
          Biankuang_Zhuangshi:set_alpha(0)
        end
      end
      if Biankuang_Zhuangshi1 then
        if Biankuang_Zhuangshi1.close then
          Biankuang_Zhuangshi1.close = nil
          Biankuang_Zhuangshi1:set_alpha(255)
        else
          Biankuang_Zhuangshi1.close = true
          Biankuang_Zhuangshi1:set_alpha(0)
        end
      end
      if Biankuang_Zhuangshi2 then
        if Biankuang_Zhuangshi2.close then
          Biankuang_Zhuangshi2.close = nil
          Biankuang_Zhuangshi2:set_alpha(255)
        else
          Biankuang_Zhuangshi2.close = true
          Biankuang_Zhuangshi2:set_alpha(0)
        end
      end
    end
  end
  if str == "-xz2" then
    if u:hasdata("变异判定-千子村正") then
      u:sendmessage("|cFF7DBEF1累积现世神兵：" .. System_Count_Weapon)
    end
    if u:hasdata("两仪式-根源接续") then
      if u:hasdata("根源接续") then
        u:sendmessage("|cFF7DBEF1根源接续：√")
      else
        u:sendmessage("|cFF7DBEF1根源接续：×")
      end
    end
    local strz = {
      {
        name = "|cff852020灾祸等级:",
        value = u:getdata("灾祸等级")
      },
      {
        name = "|cffbdbdbd白眼回天次数:",
        value = u:getdata("白眼回天")
      },
      {
        name = "|cFFFA818E解弦之眼杀敌数量:",
        value = u:getdata("解弦之眼杀敌数量")
      },
      {
        name = "|cFFF7DBA9灵梦-近战杀敌数:",
        value = u:getdata("灵梦-近战杀敌数")
      },
      {
        name = "|cFFF7DBA9藤田琴音-育成度:",
        value = u:getdata("藤田琴音-育成度")
      },
      {
        name = "|cffff4a32伊利亚-诅咒力量数量:",
        value = u:getdata("伊利亚-诅咒数量")
      },
      {
        name = "|cffff4a32矿石病爆发次数:",
        value = u:getdata("矿石病爆发次数")
      },
      {
        name = "|cffff4a32备用躯体数量:",
        value = u:getdata("老男人-备用躯体")
      },
      {
        name = "|cFF6699FF愿望之力:",
        value = u:getdata("愚者-愿望之力")
      },
      {
        name = "|cFF6699FF怨念值:",
        value = u:getdata("怨念值")
      },
      {
        name = "|cFF66FF99司命计数:",
        value = u:getdata("司命计数")
      },
      {
        name = "|cFF009966团长-团员的意志:",
        value = u:getdata("植物学硕士-团员的意志")
      },
      {
        name = "|cFF7DBEF1破碎的梦-计数:",
        value = u:getdata("破碎的梦-计数")
      },
      {
        name = "|cFF990000八重樱-红莲业火斩杀累积:",
        value = math.floor(10 * u:getdata("八重樱-红莲业火斩杀累积"))
      },
      {
        name = "|cFFCC0000小死神-死神计数:",
        value = u:getdata("小死神-死神计数")
      },
      {
        name = "|cFF666666里炎姬杀敌:",
        value = u:getdata("里炎姬杀敌")
      },
      {
        name = "|cFF666666阿米娅-情绪值:",
        value = u:getdata("阿米娅-情绪值")
      },
      {
        name = "|cFF666666阿米娅-魔王值:",
        value = u:getdata("阿米娅-魔王值")
      },
      {
        name = "|cFFF55D5C暗之书-书页数:",
        value = u:getdata("暗书书页数")
      },
      {
        name = "|cFFF55D5C间桐樱-污染值:",
        value = u:getdata("污染值")
      },
      {
        name = "|cFFF55D5C巴御前-真名解放杀敌:",
        value = u:getdata("巴御前-四阶杀敌")
      },
      {
        name = "|cFFF55D5C薄暝-杀敌计数:",
        value = u:getdata("薄暝甲-杀敌计数")
      },
      {
        name = "|cFFF55D5C智慧树的枝条-使用次数:",
        value = u:getdata("智慧树的枝条-使用次数")
      },
      {
        name = "|cFFF55D5C薄暝-罪痕层数:",
        value = u:getdata("薄暝-罪痕层数")
      },
      {
        name = "|cFFF55D5C猫头鹰因子-杀敌计数:",
        value = u:getdata("猫头鹰计数")
      },
      {
        name = "|cFFF55D5C灵魂宝石-污染度:",
        value = u:getdata("污染度")
      },
      {
        name = "|cFFFF4B4B罗丽娜-灵魂值:",
        value = u:getdata("红城的律令-杀敌数")
      },
      {
        name = "|cFF66FF99魂魄妖梦-连续完美格挡次数:",
        value = u:getdata("妖梦-连续完美格挡次数")
      },
      {
        name = "|cFF6699FF圣白莲-拳系武器杀敌数量:",
        value = u:getdata("系统-杀敌数量-拳系")
      },
      {
        name = "|cFF6699FF圣白莲-累积锻炼跑步距离:",
        value = u:getdata("圣白莲-只是兴趣使然累积距离")
      },
      {
        name = "|cFF6699FF三月兔-醉酒杀敌:",
        value = u:getdata("三月兔-醉酒杀敌")
      },
      {
        name = "|cFF6699FF爱丽丝-梦境值:",
        value = u:getdata("爱丽丝-梦境值")
      },
      {
        name = "|cFFFFFF99沙海之晶-计数:",
        value = u:getdata("沙海之晶-计数")
      },
      {
        name = "|cFF66FF99东风谷早苗-信仰之力:",
        value = u:getdata("东风谷早苗-信仰之力")
      },
      {
        name = "|cFFFF6699红叶-境界点数:",
        value = u:getdata("红叶-境界点数")
      },
      {
        name = "|cFF6699FF雪菜-神气值:",
        value = u:getdata("雪菜-神气值")
      },
      {
        name = "|cFFD8BBD3朝武芳乃-巫女层数:",
        value = u:getdata("朝武芳乃-巫女层数")
      },
      {
        name = "|cFFD8BBD3艾拉-记忆:",
        value = u:getdata("艾拉-记忆")
      },
      {
        name = "|cFF7DBEF1雪霞狼杀敌:",
        value = u:getdata("雪霞狼杀敌")
      },
      {
        name = "|cFF7DBEF1射手座-星力:",
        value = u:getdata("射手座-星力")
      },
      {
        name = "|cFFA0896C麦哲伦-考察记录:",
        value = u:getdata("麦哲伦-考察记录")
      },
      {
        name = "|cFF6699FF洗衣女仆-精准堆墓次数:",
        value = u:getdata("洗衣女仆-精准堆墓次数")
      },
      {
        name = "|cFF66FF99灭诤草蔓使用数量:",
        value = u:getdata("灭诤草蔓使用数量")
      },
      {
        name = "|cFFFF9900只狼-杀敌计数:",
        value = u:getdata("只狼-杀敌计数")
      },
      {
        name = "|cFFFF99FF樱小路露娜-杀敌数量:",
        value = u:getdata("露娜-杀敌数量")
      },
      {
        name = "|cFF6699FF安吉拉-魔弹杀敌:",
        value = u:getdata("安吉拉-魔弹杀敌")
      },
      {
        name = "|cFFFFFFCC忍野忍-刀刃杀敌:",
        value = u:getdata("忍野忍-破碎刀刃杀敌")
      },
      {
        name = "|cFFFFFFCC忍野忍-甜食值:",
        value = u:getdata("忍野忍-甜食值")
      },
      {
        name = "|cFFF0977D白银城主-时间计数：",
        value = u:getdata("白银城主-城内时间")
      },
      {
        name = "|cFFF0977D闪刀姬-计数：",
        value = u:getdata("刀计数")
      },
      {
        name = "|cFFF0977D酒之妖精-问答计数：",
        value = u:getdata("ZUN-答题成功次数")
      },
      {
        name = "|cFFF0977D生命吞噬数量：",
        value = u:getdata("阿卡多-生命吞噬数量")
      },
      {
        name = "|cFFF0977D睡梦杀敌：",
        value = u:getdata("红美铃-睡梦杀敌")
      },
      {
        name = "|cFF990000杀戮值：",
        value = u:getdata("杀戮值")
      },
      {
        name = "|cFF990000杀戮值：",
        value = u:getdata("七夜-杀戮值")
      },
      {
        name = "|cFF7DBEF1龙之意志：",
        value = u:getdata("死侍意"),
        endname = "层"
      },
      {
        name = "|cFF7DBEF1鬼灭之刃杀敌计数：",
        value = u:getdata("鬼灭之刃杀敌")
      },
      {
        name = "|cFF7DBEF1鸽度：",
        value = u:getdata("鸽度"),
        endname = "秒"
      },
      {
        name = "|cFF990000血液储量：",
        value = u:getdata("阿卡多-血液储量")
      },
      {
        name = "|cFF990000生命吞噬数：",
        value = u:getdata("阿卡多-生命吞噬数")
      },
      {
        name = "|cFF990000永恒之命：",
        value = u:getdata("阿卡多-永恒之命")
      },
      {
        name = "|cFF9900CC支配死灵数量：",
        value = u:getdata("西行寺幽幽子-支配死灵")
      },
      {
        name = "|cFFCC66FF返魂度：",
        value = u:getdata("返魂度")
      },
      {
        name = "|cFFFFCC66疯狂程度：",
        value = u:getdata("阿比盖尔-疯狂程度")
      },
      {
        name = "|cFF7DBEF1失败值：",
        value = u:getdata("失败值")
      },
      {
        name = "|cFF7DBEF1涅槃次数：",
        value = u:getdata("涅槃次数"),
        endname = "次"
      },
      {
        name = "|cFF7DBEF1涅槃时间：",
        value = u:getdata("涅槃时间"),
        endname = "秒"
      },
      {
        name = "|cFF7DBEF1龙咳层数：",
        value = u:getdata("只狼-龙咳层数")
      },
      {
        name = "|cFF7DBEF1时钟计数：",
        value = u:getdata("拉比琳丝-时钟计数")
      },
      {
        name = "|cFF6699FF酒杀杀敌：",
        value = u:getdata("文向酒杀杀敌")
      },
      {
        name = "|cFF6699FF滑步值：",
        value = u:getdata("Bloo-滑步值")
      },
      {
        name = "|cFFF2E2C6孤狼-伤逝伤害提升：",
        value = u:getdata("孤狼-伤逝近战提升") * 100,
        endname = "%|r"
      },
      {
        name = "|cFF7DBEF1카타나 처치 수:",
        value = KillCount_Katana[sy]
      },
      {
        name = "|cFF7DBEF1退魔眼杀敌计数：",
        value = u:getdata("退魔杀敌")
      },
      {
        name = "|cFF7DBEF1反转杀敌计数：",
        value = u:getdata("退魔冲动杀敌")
      },
      {
        name = "|cFF7DBEF1鹰眼暴击杀敌：",
        value = u:getdata("鹰眼暴击杀敌")
      },
      {
        name = "|cFF7DBEF1总司杀敌计数：",
        value = u:getdata("咳血杀敌")
      },
      {
        name = "|cFFFF99FF精|r|cFFD980FF灵|r|cFFB266FF力：",
        value = u:getdata("精灵力")
      },
      {
        name = "|cFF990000狂|r|cFF800D0D化|r|cFF661A1A值：",
        value = u:getdata("狂化值")
      },
      {
        name = "|cFF990000苍之男-获取后杀敌：",
        value = u:getdata("苍之男-获取后杀敌")
      },
      {
        name = "|cFF990000唤雷师-获取后杀敌：",
        value = u:getdata("唤雷师-获取后杀敌")
      },
      {
        name = "|cFF990000神父-获取后杀敌：",
        value = u:getdata("神父-获取后杀敌")
      },
      {
        name = "|cFF990000鬼剑豪-获取后杀敌:",
        value = u:getdata("巴御前-获取后杀敌")
      },
      {
        name = "|cFF990000雏芥子-获取后杀敌:",
        value = u:getdata("虞美人-获取后杀敌")
      },
      {
        name = "|cFF990000崔斯坦-获取后杀敌:",
        value = u:getdata("崔斯坦-获取后杀敌")
      },
      {
        name = "|cFF990000低语值:",
        value = u:getdata("幽灵鲨-低语值")
      }
    }
    local ddstr = ""
    local cs = 0
    for index, dstr in ipairs(strz) do
      if 0 < dstr.value then
        if dstr.endname then
          ddstr = ddstr .. dstr.name .. math.floor(dstr.value) .. dstr.endname
        else
          ddstr = ddstr .. dstr.name .. math.floor(dstr.value)
        end
        ddstr = ddstr .. "  "
        cs = cs + 1
        if cs == 4 then
          cs = 0
          ddstr = ddstr .. "\n"
        end
      end
    end
    if ddstr ~= "" then
      u:sendmessage(ddstr)
    end
  end
  if str == "-rr" then
    if RightGive[sy] then
      RightGive[sy] = false
      u:sendmessage("双击右键传递物品关闭")
    else
      RightGive[sy] = true
      u:sendmessage("双击右键传递物品开启")
    end
  end
  if str == "-shopb" then
    if not u:hasdata("往世乐土-B键关闭") then
      u:setdata("往世乐土-B键关闭")
      u:sendmessage("|cffc3afff[系统]关闭乐土商店快捷键B|r")
    else
      u:deldata("往世乐土-B键关闭")
      u:sendmessage("|cffc3afff[系统]开启乐土商店快捷键B|r")
    end
  end
  if str == "bgm off" then
    playerconfig_set_bgm_enabled(sy, false, true)
  end
  if str == "bgm on" then
    playerconfig_set_bgm_enabled(sy, true, true)
  end
  if str == "-chat" then
    ac.wait(10, function()
      if System_Chat[sy] then
        u:sendmessage("关闭聊天字幕")
        System_Chat[sy] = false
      else
        u:sendmessage("开启聊天字幕")
        System_Chat[sy] = true
      end
    end)
  end
  if str == "-getitem" then
    if u:hasdata("系统-直接获取补给箱物品") then
      u:deldata("系统-直接获取补给箱物品")
      u:sendmessage("|cffc3afff[系统]关闭直接获取补给箱物品|r")
    else
      u:setdata("系统-直接获取补给箱物品")
      u:sendmessage("|cffc4b0ff[系统]开启直接获取补给箱物品|r")
    end
  end
  if str == "-show" then
    if Tipshow then
      Tipshow = false
    else
      Tipshow = true
    end
  end
  if str == "-test2" then
    BossBattle = false
    ExBossBattle = false
    ExtraBattle = false
  end
  if str == "-testrun" then
    require("test")
  end
  if str == "-move" then
    if MoveBoolean[sy] then
      mapmove(unit, "Move指令")
    else
      u:sendmessage("Move指令冷却中")
    end
  end
  if str == "-wz" then
    local npc = getunit(NPC_Wuzicangku)
    local parts = {}
    for _, mat in ipairs(MATERIALS) do
      local count = npc:getdata("素材数量-" .. mat.name)
      if 0 < count then
        local showname = itemnamechange(mat.name)
        table.insert(parts, showname .. "x" .. math.floor(count))
      end
    end
    for _, mat in ipairs(PRODUCTS) do
      local count = npc:getdata("素材数量-" .. mat.name)
      if 0 < count then
        local showname = itemnamechange(mat.name)
        table.insert(parts, showname .. "x" .. math.floor(count))
      end
    end
    local summary = table.concat(parts, "，")
    u:sendmessage("|cff6faeff空间站物资仓库:|r " .. summary, 30)
  end
  if str == "-awsl" and not u:hasdata("系统-已删模") and not Movie_Boolean and not Boolean_Jinselingyu then
    if u:hasdata("变异判定-桔梗") or u:hasdata("变异判定-Roman") or u:hasdata("变异判定-藤原妹红") or u:hasdata("变异判定-只狼") then
      u:settimedata("指令死亡", 1)
    end
    CommandDeath = true
    u:settimedata("指令死亡-不触发残机", 0.1)
    ac.wait(100, function()
      CommandDeath = false
    end)
    u:sethp(-9999)
  end
  if first == "-" then
    local number = tonumber(str)
    if number ~= nil then
      local change = math.abs(number)
      playerconfig_set_camera_height(sy, Cam_height[sy] - change, 0.5, true)
    end
    if string.sub(str, 1, 5) == "-give" then
      local sy2 = tonumber(string.sub(str, 6, 6))
      if 0 < u:getdata("残机剩余数量") then
        if Hero[sy2] ~= 0 then
          local u2 = getunit(Hero[sy2])
          if u:hasdata("神器判定-嗝屁猫") or u2:hasdata("神器判定-嗝屁猫") then
            u:sendmessage("|cFF7DBEF1无法给予残机(嗝屁猫)|r")
            return
          end
          u:changedata("残机剩余数量", -1)
          u:setusedfodd(u:getdata("残机剩余数量"))
          u2:changedata("残机剩余数量", 1)
          u2:setusedfodd(u2:getdata("残机剩余数量"))
          u:sendmessage("成功给予残机")
        else
          u:sendmessage("玩家不存在")
        end
      else
        u:sendmessage("残机不足")
      end
    end
  end
  if string.sub(str, 1, 4) == "+cam" then
    local number = tonumber(string.sub(str, 5, len))
    if number ~= nil then
      local change = math.abs(number)
      playerconfig_set_camera_height(sy, Cam_height[sy] + change, 0.5, true)
    end
  elseif first == "+" then
    local number = tonumber(str)
    if number ~= nil then
      local change = math.abs(number)
      playerconfig_set_camera_height(sy, Cam_height[sy] + change, 0.5, true, 2050)
    end
  end
  if str == "-xz" then
    p:clearMsg()
    local xzstr = ""
    xzstr = xzstr .. "|cFFFFFF33신성:" .. math.floor(HeroMenu_Shenxing[sy]) .. "|r "
    if 0 < u:getdata("始源值") then
      local sx2 = u:getdata("始源值")
      if u:hasdata("隐藏职业-始源精灵") then
        sx2 = sx2 - 1
        if sx2 ~= 0 then
          xzstr = xzstr .. "|cFFCC99FF시원:" .. math.floor(sx2) .. "|r "
        end
      else
        xzstr = xzstr .. "|cFFCC99FF시원:" .. math.floor(sx2) .. "|r "
      end
    end
    if 0 < u:getdata("原罪值") then
      local sx2 = u:getdata("原罪值")
      xzstr = xzstr .. "|cFF8F0A33원죄:" .. math.floor(sx2) .. "|r "
    end
    u:sendmessage(xzstr, 20)
    xzstr = ""
    xzstr = xzstr .. "|cFF7DBEF1이동 속도" .. "[" .. math.floor(GetUnitMoveSpeed(u.handle)) .. "+" .. math.floor(u:getdata("当前额外移速")) .. "]|r "
    xzstr = xzstr .. "|cFF7DBEF1마력:" .. math.floor(u:getdata("魔力值")) .. "|r "
    local ea = expget(u, 0)
    ea = ea * 100
    xzstr = xzstr .. "|cFF7DBEF1경험치 획득:|r|cFF1BE6B8" .. math.floor(ea) .. "%|r "
    u:sendmessage(xzstr, 20)
    xzstr = ""
    local mg = (Correction_Magic[sy] - 1) * 100
    local showjz = u:getdata("显示-近战伤害加成")
    local gun = u:getdata("显示-枪械伤害加成") * 100
    local ebp, jf, ejf = bpget(u.handle, u.handle, 0)
    jf = jf * 100
    ejf = ejf * 100
    xzstr = xzstr .. "|cFF7DBEF1총기 피해:|r|cFF1BE6B8" .. math.floor(gun) .. "%|r "
    xzstr = xzstr .. "|cFF7DBEF1근접 보정[|r|cFF1BE6B8" .. math.floor(showjz * 100) .. "%|r|cFF7DBEF1]|r"
    xzstr = xzstr .. "|cFF7DBEF1주문 보정:|r|cFF1BE6B8" .. math.floor(mg) .. "%|r "
    xzstr = xzstr .. "|cFF7DBEF1점수 획득[|r|cFF1BE6B8" .. math.floor(jf) .. "%(" .. math.floor(ejf) .. "%)+" .. math.floor(ebp) .. "|r|cFF7DBEF1]|r "
    u:sendmessage(xzstr, 20)
    xzstr = ""
    local all2 = (u:getdata("显示-伤害加成") - 1) * 100
    local jsxz = (1 - u:getdata("显示-减伤修正")) * 100
    local ssxz = (u:getdata("显示-额外受伤") - 1) * 100
    xzstr = xzstr .. "|cFF7DBEF1피해 증가:|r|cFF1BE6B8" .. string.format("%.1f", all2) .. "%|r "
    xzstr = xzstr .. "|cFF7DBEF1받는 피해 감소:|r|cFF1BE6B8" .. string.format("%.1f", jsxz) .. "%|r "
    xzstr = xzstr .. "|cFF7DBEF1추가 받는 피해:|r|cFF1BE6B8" .. string.format("%.1f", ssxz) .. "%|r "
    u:sendmessage(xzstr, 20)
    xzstr = ""
    local bjl = u:getdata("显示-暴击率")
    local bjsh = u:getdata("显示-暴击伤害") * 100
    local cb = u:getdata("显示-超暴系数")
    xzstr = xzstr .. "|cFF7DBEF1치명타 확률:|r|cFF1BE6B8" .. string.format("%.1f", bjl) .. "%|r"
    if 0 < cb then
      xzstr = xzstr .. "|cFFFF0000+" .. math.floor(cb) .. "|r "
    else
      xzstr = xzstr .. " "
    end
    xzstr = xzstr .. "|cFF7DBEF1치명타 피해:|r|cFF1BE6B8" .. string.format("%.1f", bjsh) .. "%|r"
    u:sendmessage(xzstr, 20)
    xzstr = ""
    local gs = u:getdata("显示-固定伤害")
    local gj = u:getdata("显示-固定减伤") - u:getdata("固定受伤")
    if gs ~= 0 then
      xzstr = xzstr .. "|cFFFF9900고정 피해:|r|cFFFF6633" .. math.floor(gs) .. "|r "
    end
    if gj ~= 0 then
      xzstr = xzstr .. "|cFFFF9900고정 피해 감소:|r|cFFFF6633" .. math.floor(gj) .. "|r "
    end
    if xzstr ~= "" then
      u:sendmessage(xzstr, 20)
    end
    xzstr = ""
    local lwss = u:getdata("显示-最终受伤") * u:getdata("显示-最终减伤")
    local glss = u:getdata("显示-终结受伤") * u:getdata("显示-终结减伤")
    if lwss ~= 1 then
      if lwss < 1 then
        lwss = (1 - lwss) * 100
        xzstr = xzstr .. "|cFF3366FF최종 받는 피해 감소:|r|cFF6699FF" .. string.format("%.1f", lwss) .. "%|r "
      else
        lwss = (lwss - 1) * 100
        xzstr = xzstr .. "|cFFFF0000최종 받는 피해:|r|cFFFF6699" .. string.format("%.1f", lwss) .. "%|r "
      end
    end
    if glss ~= 1 then
      if glss < 1 then
        glss = (1 - glss) * 100
        xzstr = xzstr .. "|cFF6633FF종결 받는 피해 감소:|r|cFF9999FF" .. string.format("%.1f", glss) .. "%|r "
      else
        glss = (glss - 1) * 100
        xzstr = xzstr .. "|cFFFF0000종결 받는 피해:|r|cFFFF6699" .. string.format("%.1f", glss) .. "%|r "
      end
    end
    if xzstr ~= "" then
      u:sendmessage(xzstr, 20)
    end
    xzstr = ""
    local ys = (DamageSystem_Yssh[sy] * DamageSystem_Ysshjd[sy] - 1) * 100
    local endup = u:getdata("显示-终结增伤")
    local enddown = u:getdata("显示-终结降低")
    local endshow = (endup * enddown - 1) * 100
    if ys ~= 0 then
      xzstr = xzstr .. "|cFFFFCC66원초 피해:" .. string.format("%.1f", ys) .. "%|r "
    end
    if endshow ~= 0 then
      xzstr = xzstr .. "|cFFCC22AA종결 피해:" .. string.format("%.1f", endshow) .. "%|r "
    end
    if xzstr ~= "" then
      u:sendmessage(xzstr, 20)
    end
    if 0 < u:getdata("角色基础伤害") then
      u:sendmessage("|cFF7DBEF1캐릭터 기본 피해:" .. math.floor(u:getdata("角色基础伤害")), 20)
    end
    u:sendmessage("|cFF7DBEF1남은 신화 슬롯:" .. math.floor(Hero_Shenhua_Left[sy]), 20)
    u:sendmessage("|cFF7DBEF1신화 수:" .. math.floor(Hero_Shenhua_Now[sy]), 20)
    if 0 < u:getdata("醉酒度") then
      u:sendmessage("|cFF7DBEF1취기:" .. math.floor(u:getdata("醉酒度")), 20)
    end
    if 0 < u:getdata("传奇数量") then
      u:sendmessage("|cFF7DBEF1전설 수:" .. math.floor(u:getdata("传奇数量")), 20)
    end
  end
end
