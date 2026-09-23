-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local slk = require("jass.slk")
local w, h = 88, 68
local panel
local optionButtons = {}
local relicRelics = {}
local cancelButton, hintPanel, hintText, hintPanel2, hintText2, relicPanel

local function _ensure_icon(path)
  local d = path or "war3mapImported\\Black.blp"
  d = tostring(d)
  if not d:match("%.tga$") and not d:match("%.blp$") then
    d = d .. ".tga"
  end
  return d
end

function _make_rlc_data_from_dvar(u, dvars, poolsstr, str, args)
  args = args or {}
  local data = {
    noskip = false,
    desc = str,
    skip_medicinegetend = args.skip_medicinegetend == true,
    options = {}
  }
  for _, v in ipairs(dvars or {}) do
    local icon = _ensure_icon(v.effectart)
    local title = v.effectname or v.name or "未知选项"
    local text = v.effecttext or ""
    table.insert(data.options, {
      icon = icon,
      title = title,
      rarity = v.rarity or "普通",
      text = text,
      __var_name = v.name,
      func = function(u2)
        if not u2 or u2.handle ~= u.handle or u2.ownerid ~= u.ownerid then
          return "失败"
        end
        local reward_u = u
        reward_u:setdata("伊丝-过波奖励获取变异")
        local result = herogetvar(reward_u.handle, v.pools, v.poolsstr, v.name)
        reward_u:deldata("伊丝-过波奖励获取变异")
        if result == "失败" then
          reward_u:sendmessage("|cFFCC0000获取失败|r")
          return
        end
        if v.poolsstr == "普通过波遗物" or v.poolsstr == "稀有过波遗物" or v.poolsstr == "BOSS过波遗物" then
          yiwuhuoqu(reward_u, v)
        elseif not data.skip_medicinegetend and medicinegetend then
          medicinegetend(reward_u.handle, true, v.medicine or MEDICINE_HUIYI)
        end
        return result
      end
    })
  end
  return data
end

local BIOMES = {
  "陆地",
  "辐射",
  "冰原",
  "火山",
  "半影",
  "风暴",
  "海洋",
  "高山",
  "森林",
  "荒芜"
}
local BIOME_DISPLAY_NAME = {}
for index, value in ipairs(BIOMES) do
  BIOME_DISPLAY_NAME[value] = value .. "行星"
end
local BIOME_DESCRIPTIONS = {
  ["陆地"] = "陆地生态",
  ["冰原"] = "冰原生态",
  ["火山"] = "火山生态",
  ["海洋"] = "海洋生态",
  ["高山"] = "高山生态",
  ["森林"] = "森林生态",
  ["辐射"] = "辐射生态",
  ["荒芜"] = "荒芜生态",
  ["风暴"] = "风暴生态",
  ["半影"] = "半影生态"
}

local function _rand_biome()
  return BIOMES[GetRandomInt(1, #BIOMES)]
end

local function _merge_kind(kind)
  if kind == "精英" then
    return "危险行星"
  elseif kind == "行商" then
    return "空间站"
  elseif kind == "乐土" then
    return "乐土商店"
  end
  return kind
end

local function _normalize_node(node)
  if type(node) == "table" then
    local k = _merge_kind(node.kind or "袭击")
    local b = node.biome
    local d = node.data or {}
    return k, b, d
  else
    local k = _merge_kind(tostring(node or "袭击"))
    return k, nil, {}
  end
end

local function _weightedRandom(weights)
  local orderedKeys = {
    "Elite",
    "Merchant",
    "Normal"
  }
  local total = 0
  for _, k in ipairs(orderedKeys) do
    total = total + (weights[k] or 0)
  end
  if total <= 0 then
    return "Normal"
  end
  local r = GetRandomReal(0, 1) * total
  local sum = 0
  for _, k in ipairs(orderedKeys) do
    sum = sum + (weights[k] or 0)
    if r <= sum then
      return k
    end
  end
  return "Normal"
end

local function _build_single_lane(waveCount, bossWaves, stationWaves, eliteCdInit)
  local lane = {}
  local eliteWeight, merchantWeight = 0, 0
  local eliteCooldown = eliteCdInit or 2
  local merchantCooldown = 0
  local di = 2
  if Nandu_Shenzhao then
    di = -1
  end
  for i = 0, waveCount do
    if bossWaves[i] then
      lane[i] = {
        kind = "BOSS",
        biome = nil,
        data = {has_event = false, hazard = true}
      }
      eliteCooldown, merchantCooldown = 1, 1
    elseif stationWaves[i] then
      lane[i] = {
        kind = "空间站",
        biome = nil,
        data = {has_event = false, station = true}
      }
    elseif i == 0 or i == 1 then
      lane[i] = {
        kind = "袭击",
        biome = _rand_biome(),
        data = {
          has_event = GetRandomReal(0, 1) < 0.2
        }
      }
    else
      eliteWeight = eliteWeight + 25
      merchantWeight = merchantWeight + 15
      local weights = {
        Elite = (0 < eliteCooldown or i <= di) and 0 or eliteWeight,
        Merchant = 0 < merchantCooldown and 0 or merchantWeight,
        Normal = 100
      }
      local pick = _weightedRandom(weights)
      local biome = _rand_biome()
      local has_event = GetRandomReal(0, 1) < 0.22
      local upgrade_to_hazard = 3 <= eliteCooldown or pick == "Normal" and i % 5 == 0
      if pick == "Elite" then
        lane[i] = {
          kind = "危险行星",
          biome = biome,
          data = {has_event = has_event, hazard = true}
        }
        eliteCooldown = 2
      elseif pick == "Merchant" then
        lane[i] = {
          kind = "空间站",
          biome = nil,
          data = {has_event = false, station = true}
        }
        if not Mode_Wangshiletu then
          merchantCooldown = 2
        else
          merchantCooldown = 3
        end
      else
        lane[i] = {
          kind = upgrade_to_hazard and "危险行星" or "袭击",
          biome = biome,
          data = {has_event = has_event, hazard = upgrade_to_hazard}
        }
        eliteCooldown = math.max(0, eliteCooldown - 1)
        merchantCooldown = math.max(0, merchantCooldown - 1)
      end
    end
  end
  return lane
end

local function BuildTwoLanes(waveCount, bossWaves, stationWaves)
  local lane1 = _build_single_lane(waveCount, bossWaves, stationWaves, 2)
  local lane2 = _build_single_lane(waveCount, bossWaves, stationWaves, 2)
  for i, _ in pairs(bossWaves) do
    lane1[i] = {
      kind = "BOSS",
      biome = nil,
      data = {has_event = false, hazard = true}
    }
    lane2[i] = {
      kind = "BOSS",
      biome = nil,
      data = {has_event = false, hazard = true}
    }
  end
  for i, _ in pairs(stationWaves) do
    if not bossWaves[i] then
      lane1[i] = {
        kind = "空间站",
        biome = nil,
        data = {has_event = false, station = true}
      }
      lane2[i] = {
        kind = "空间站",
        biome = nil,
        data = {has_event = false, station = true}
      }
    end
  end
  return {
    waveCount = waveCount,
    bossWaves = bossWaves,
    stationWaves = stationWaves,
    lanes = {
      [1] = lane1,
      [2] = lane2
    }
  }
end

Daohangtu = Daohangtu or {}
Daohangtu.yqcs = Daohangtu.yqcs or 1
Daohangtu.count = Daohangtu.count or 1
Daohangtu.postion = Daohangtu.postion or 1
Daohangtu.active_lane = Daohangtu.active_lane or 1
Daohangtu.curr_wave = Daohangtu.curr_wave or 0
Daohangtu.route = Daohangtu.route or nil
Daohangtu.data = Daohangtu.data or {
  {name = "M78", type = "星系"},
  {name = "A68", type = "星系"}
}

function Daohangtu:init_routes()
  local waveCount = 38
  local bossWaves = {}
  local stationWaves = {}
  for index, value in ipairs(Stage_boss) do
    bossWaves[value] = true
    stationWaves[value + 1] = true
  end
  self.route = BuildTwoLanes(waveCount, bossWaves, stationWaves)
  self.nextboss = self:_calc_next_boss_dist()
end

function Daohangtu:sync_from_stage()
  self.nextboss = self:_calc_next_boss_dist()
end

function Daohangtu:_display_label(kind, biome)
  return self:change_str(kind, biome)
end

function Daohangtu:_next_index()
  if not self.route then
    return 0
  end
  local curr = Stage or 0
  return math.min(curr + 1, self.route.waveCount)
end

function Daohangtu:get_next_wave_info()
  if not self.route then
    return "袭击", _rand_biome(), {has_event = false}
  end
  local nxt = self:_next_index()
  local lane = self.route.lanes[self.active_lane]
  local node = lane[nxt]
  local kind, biome, data = _normalize_node(node)
  if not kind or kind == "" then
    kind = "袭击"
  end
  return kind, biome, data
end

function Daohangtu:get_next_wave_type()
  local kind, biome = self:get_next_wave_info()
  return self:change_str(kind, biome)
end

function Daohangtu:_biome_intro_for_current()
  local kind, biome = self:get_current_wave_info()
  if (kind == "袭击" or kind == "危险行星") and biome and BIOME_DESCRIPTIONS[biome] then
    return BIOME_DESCRIPTIONS[biome]
  end
  if kind == "空间站" then
    return "空间站：补给与调整航线的安全节点。"
  end
  if kind == "乐土商店" then
    return "乐土商店：可以购买往世乐土中的变异补给。"
  end
  if kind == "BOSS" then
    return "危险星团：前方高危，请谨慎准备。"
  end
  return "该星区情报有限，请谨慎前进。"
end

function Daohangtu:_biome_intro_for_next()
  local kind, biome = self:get_next_wave_info()
  if (kind == "袭击" or kind == "危险行星") and biome and BIOME_DESCRIPTIONS[biome] then
    return BIOME_DESCRIPTIONS[biome]
  end
  if kind == "空间站" then
    return "空间站：补给与调整航线的安全节点。"
  end
  if kind == "乐土商店" then
    return "乐土商店：可以购买往世乐土中的变异补给。"
  end
  if kind == "BOSS" then
    return "危险星团：前方高危，请谨慎准备。"
  end
  return "该星区情报有限，请谨慎前进。"
end

function Daohangtu:_brief_intro_from_lane(max_ahead)
  if not self.route then
    return "暂无情报"
  end
  local lane = self.route.lanes[self.active_lane]
  local i = Stage or 0
  local ahead = max_ahead or 3
  local parts = {}
  local w = i + 1
  while w <= self.route.waveCount and ahead > #parts do
    if self.route.bossWaves[w] then
      table.insert(parts, string.format("#%d |cFF990000危险星团|r", w))
      break
    else
      local kind, biome = _normalize_node(lane[w])
      local t = self:_display_label(kind, biome)
      table.insert(parts, string.format("#%d %s", w, t))
    end
    w = w + 1
  end
  if #parts == 0 then
    return Stage <= 0 and "未知" or "前方即将进入危险星团"
  end
  return table.concat(parts, "  →  ")
end

function Daohangtu:_calc_next_boss_dist()
  if not self.route then
    return 0
  end
  local i = Stage or 0
  local wc = self.route.waveCount
  for w = i, wc do
    if self.route.bossWaves[w] then
      return math.max(0, w - i - 1)
    end
  end
  return 0
end

function Daohangtu:_star_names()
  local data = self.data[self.count]
  local data2 = self.data[self.count + 1] or self.data[self.count - 1] or self.data[1]
  return data, data2
end

function Daohangtu:_lane_name(idx)
  return idx == 1 and "α 航线" or "β 航线"
end

function Daohangtu:_history_from_lane(max_back)
  if not self.route then
    return "#0 |cFF7DBEF1母星|r"
  end
  local lane = self.route.lanes[self.active_lane]
  local last_done = math.max(0, (Stage or 0) - 1)
  if last_done <= 0 then
    return "#0 |cFF7DBEF1母星|r"
  end
  local back = max_back or 4
  local first = math.max(0, last_done - back)
  local parts = {}
  if last_done <= 5 then
    table.insert(parts, "#0 |cFF7DBEF1母星|r")
  end
  local start_w = math.max(1, first)
  for w = start_w, last_done do
    local kind, biome = _normalize_node(lane[w] or "袭击")
    local t = self:_display_label(kind, biome)
    table.insert(parts, string.format("#%d %s", w, t))
  end
  return table.concat(parts, "  →  ")
end

function Daohangtu:get_current_wave_type()
  if not self.route then
    return "|cFF949596敌对行星|r"
  end
  local lane = self.route.lanes[self.active_lane]
  local idx = Stage or 0
  local kind, biome = _normalize_node(lane[idx])
  return self:_display_label(kind, biome)
end

function Daohangtu:get_current_wave_info()
  if not self.route then
    return "袭击", _rand_biome(), {has_event = false}
  end
  local lane = self.route.lanes[self.active_lane]
  local idx = Stage or 0
  local node = lane[idx]
  local kind, biome, data = _normalize_node(node)
  if not kind or kind == "" then
    kind = "袭击"
  end
  return kind, biome, data
end

function Daohangtu:advance_wave()
  self.nextboss = self:_calc_next_boss_dist()
end

function Daohangtu:change_str(kind, biome)
  if kind == "空间站" then
    return "|cFF66CCFF空间站|r"
  elseif kind == "乐土商店" then
    return "|cFFFF99FF乐土商店|r"
  elseif kind == "BOSS" then
    return "|cFF990000危险星团|r"
  end
  local name = biome and BIOME_DISPLAY_NAME[biome]
  if name then
    if kind == "危险行星" then
      return "|cFFCC0000" .. name .. "（危险）|r"
    elseif kind == "袭击" then
      return "|cFF949596" .. name .. "|r"
    end
  end
  if kind == "危险行星" then
    return "|cFFCC0000危险行星|r"
  elseif kind == "袭击" then
    return "|cFFFF6699敌对行星|r"
  else
    return "|cFFFF6699敌对行星|r"
  end
end

GuoboAllSet = GuoboAllSet or {}

local function _refresh_GuoboAllSet_from_route()
  if not Daohangtu.route then
    return
  end
  local lane = Daohangtu.route.lanes[Daohangtu.active_lane]
  if not lane then
    return
  end
  for i = 0, Daohangtu.route.waveCount do
    local kind = select(1, _normalize_node(lane[i]))
    GuoboAllSet[i] = kind
  end
end

function guoboallsetstart()
  Daohangtu:init_routes()
  Daohangtu:sync_from_stage()
  _refresh_GuoboAllSet_from_route()
end

local b2 = true
Daohangtu.showbutton = class.button:builder({
  parent = OriginPanel,
  x = 1510,
  y = 785,
  w = 67.6923076923077,
  h = 52.30769230769231,
  sync_key = "Daohangtu",
  normal_image = "UI_Daohangtu.tga",
  on_button_clicked = function(self)
    self:set_control_size(self:get_width() * 0.9, self:get_height() * 0.9)
    ac.wait(100, function()
      self:set_control_size(self:get_width() / 0.9, self:get_height() / 0.9)
    end)
  end,
  on_button_mouse_enter = function(self)
    self:set_alpha(155)
    local sy = SeletPlayerID
    local u = getunit(Hero[sy])
    local text = "|cFF7DBEF1打开当前导航\n当前导航员:" .. u:getplayername() .. "|r"
    self.showtext = text
    uiy_show_text(self.showtext)
  end,
  on_button_mouse_leave = function(self)
    self:set_alpha(255)
    uiy_hide()
  end,
  on_button_right_clicked = function(self)
    if not b2 then
      b2 = true
      self:set_enable_drag(true)
    else
      b2 = false
      self:set_enable_drag(false)
    end
  end,
  on_button_update_drag = function(self, icon, x, y)
    self:set_position(x, y)
  end,
  on_sync_button_clicked = function(self, p, button)
    p = getplayer(p.handle)
    local sy = p.id
    local sy2 = SeletPlayerID
    local u = getunit(Hero[sy])
    local dhy = getunit(Hero[sy2])
    if not Daohangtu.route then
      Daohangtu:init_routes()
    end
    Daohangtu:sync_from_stage()
    _refresh_GuoboAllSet_from_route()
    local data, data2 = Daohangtu:_star_names()
    local showdata = {
      banner = "event_03.tga",
      options = {}
    }
    local desc
    local nextType = Daohangtu:get_next_wave_type()
    local nextboss = Daohangtu:_calc_next_boss_dist()
    local currType = Daohangtu:get_current_wave_type()
    local currIndex = Stage or 0
    local laneName = Daohangtu.active_lane == 1 and "α 航线" or "β 航线"
    if nextboss == 0 then
      desc = ("|cFF6699FF当前所在星系:|r" .. "|cFF990000危险星团|r" .. "\n" .. "|cFF6699FF当前航线:|r" .. laneName .. "\n" .. string.format("|cFF6699FF当前波次(#%d):|r", currIndex) .. currType .. "\n" .. "|cFF1BE6B8剩余跃迁次数:|r" .. tostring(Daohangtu.yqcs)) .. "\n" .. "|cFF6699FF已经过航线:|r" .. Daohangtu:_history_from_lane(5)
      table.insert(showdata.options, {
        text = "1) 关闭导航",
        func = function(_)
        end
      })
    else
      local intro_next = Daohangtu:_biome_intro_for_next()
      local ahead_preview = Daohangtu:_brief_intro_from_lane(3)
      desc = ("|cFF6699FF当前所在星系:|r" .. data.name .. data.type .. "\n" .. "|cFF6699FF下一站:|r" .. data.name .. "-" .. Daohangtu.postion + 1 .. "\n" .. "|cFF6699FF简要介绍:|r" .. intro_next .. "\n" .. "|cFF6699FF前方情报:|r" .. ahead_preview .. "\n" .. "|cFF6699FF当前航线:|r" .. laneName .. "\n" .. string.format("|cFF6699FF当前波次(#%d):|r", currIndex) .. currType .. "\n" .. "|cFF990000危险星团距离:|r" .. tostring(nextboss) .. "\n" .. "|cFF1BE6B8剩余跃迁次数:|r" .. tostring(Daohangtu.yqcs)) .. "\n" .. "|cFF6699FF已经过航线:|r" .. Daohangtu:_history_from_lane(5)
      table.insert(showdata.options, {
        text = "1) 关闭导航",
        func = function(_)
        end
      })
      if sy == sy2 and 1 < nextboss then
        local other = Daohangtu.active_lane == 1 and 2 or 1
        table.insert(showdata.options, {
          text = "2) 切换至" .. Daohangtu:_lane_name(other) .. "（消耗1次跃迁）",
          func = function(_)
            if not dhy:isinrect(RECT_PlayArea) then
              u:sendmessage("|cFF6699FF无法发布导航命令(未处于空间站)|r")
              return
            end
            local ok, reason = (function()
              local dist = Daohangtu:_calc_next_boss_dist()
              if dist <= 1 then
                return false, "离危险星团太近，无法切换"
              end
              if Daohangtu.yqcs <= 0 then
                return false, "剩余跃迁次数不足"
              end
              Daohangtu.yqcs = Daohangtu.yqcs - 1
              Daohangtu.active_lane = Daohangtu.active_lane == 1 and 2 or 1
              return true
            end)()
            if ok then
              SendMsgAll(dhy:getplayername() .. "|cFF6699FF切换至" .. Daohangtu:_lane_name(Daohangtu.active_lane))
              _refresh_GuoboAllSet_from_route()
            else
              u:sendmessage("|cFFCC0000切换失败：" .. (reason or "未知原因") .. "|r")
            end
          end
        })
        if not Boolean_Likeqifei then
          table.insert(showdata.options, {
            text = #showdata.options + 1 .. ") 紧急起飞 （10秒后强制起飞 无过波奖励）",
            func = function(_)
              if not dhy:isinrect(RECT_PlayArea) then
                u:sendmessage("|cFF6699FF无法发布导航命令(未处于空间站)|r")
                return
              end
              SendMsgAll(dhy:getplayername() .. "|cFF6699FF准备紧急起飞|r")
              Boolean_Likeqifei = true
            end
          })
        end
        if not Boolean_Zhiliu then
          table.insert(showdata.options, {
            text = #showdata.options + 1 .. ") 多停留一会 （延长300秒起飞时间）",
            func = function(_)
              if not dhy:isinrect(RECT_PlayArea) then
                u:sendmessage("|cFF6699FF无法发布导航命令(未处于空间站)|r")
                return
              end
              SendMsgAll(dhy:getplayername() .. "|cFF6699FF准备多停留一会|r")
              Boolean_Zhiliu = true
            end
          })
        end
      end
    end
    showdata.desc = desc
    RLChoose(u, showdata, "list")
  end
})
Daohangtu.showbutton:set_enable_drag(true)
Daohangtu.showbutton:hide()
local AllDVar = {}
for i = 1, 6 do
  AllDVar[i] = {}
end

function generateThreeRandomVars(u, pools, poolsstr, count)
  local dvar = {}
  count = count or 3
  local retry_limit = 20
  local sy = u.ownerid
  local is_multi_pools = pools and pools._is_multi_pools == true
  
  local function get_dpools(i)
    if u:hasdata("以太药水-临时池") and i == 1 then
      return u:getdata("以太药水-临时池")
    elseif is_multi_pools then
      return pools[i] or pools[1]
    else
      return pools
    end
  end
  
  for i = 1, count do
    local attempt = 0
    while retry_limit > attempt do
      attempt = attempt + 1
      local dpools = get_dpools(i)
      local var = herogetvar(u.handle, dpools, poolsstr, "只返回变异")
      local is_duplicate = false
      for j = 1, #dvar do
        if var and var ~= "失败" and dvar[j].name == var.name then
          is_duplicate = true
          break
        end
      end
      if poolsstr == "普通过波遗物" or poolsstr == "BOSS过波遗物" or poolsstr == "稀有过波遗物" then
        for j = 1, #AllDVar[sy] do
          if var and var ~= "失败" and AllDVar[sy][j].name == var.name then
            is_duplicate = true
            break
          end
        end
      end
      if not is_duplicate and var ~= "失败" and var ~= nil then
        var.pools = dpools
        var.poolsstr = poolsstr
        table.insert(dvar, var)
        if poolsstr == "普通过波遗物" or poolsstr == "稀有过波遗物" or poolsstr == "BOSS过波遗物" then
          table.insert(AllDVar[sy], var)
        end
        break
      end
    end
  end
  if 0 < #dvar and count > #dvar then
    for i = #dvar + 1, count do
      local attempt = 0
      while retry_limit > attempt do
        attempt = attempt + 1
        local dpools = get_dpools(i)
        local var = herogetvar(u.handle, dpools, poolsstr, "只返回变异")
        local can_use = var ~= nil and var ~= "失败"
        if can_use and (poolsstr == "普通过波遗物" or poolsstr == "BOSS过波遗物" or poolsstr == "稀有过波遗物") then
          for j = 1, #AllDVar[sy] do
            if var and AllDVar[sy][j].name == var.name then
              can_use = false
              break
            end
          end
        end
        if can_use then
          var.pools = dpools
          var.poolsstr = poolsstr
          table.insert(dvar, var)
          if poolsstr == "普通过波遗物" or poolsstr == "稀有过波遗物" or poolsstr == "BOSS过波遗物" then
            table.insert(AllDVar[sy], var)
          end
          break
        end
      end
    end
  end
  if u:hasdata("系统-强制返回Vars") then
    return dvar
  end
  if #dvar == 0 then
    return {}
  end
  return dvar
end

local function generateOneRandomVarByIndex(u, pools, poolsstr, index)
  index = index or 1
  local retry_limit = 30
  local sy = u.ownerid
  local is_multi_pools = pools and pools._is_multi_pools == true
  
  local function get_dpools(i)
    if u:hasdata("以太药水-临时池") and i == 1 then
      return u:getdata("以太药水-临时池")
    elseif is_multi_pools then
      return pools[i] or pools[1]
    else
      return pools
    end
  end
  
  for _ = 1, retry_limit do
    local dpools = get_dpools(index)
    local var = herogetvar(u.handle, dpools, poolsstr, "只返回变异")
    if type(var) == "table" then
      local can_use = true
      if poolsstr == "普通过波遗物" or poolsstr == "BOSS过波遗物" or poolsstr == "稀有过波遗物" then
        for j = 1, #AllDVar[sy] do
          if AllDVar[sy][j].name == var.name then
            can_use = false
            break
          end
        end
      end
      if can_use then
        var.pools = dpools
        var.poolsstr = poolsstr
        return var
      end
    end
  end
end

local function is_guobo_relic_pool(poolsstr)
  return poolsstr == "普通过波遗物" or poolsstr == "稀有过波遗物" or poolsstr == "BOSS过波遗物"
end

local function make_potion_refresh(u, data, pools, poolsstr)
  return {
    text = "|cFF99FFFF刷新",
    image = "UI_Button_ReflashN.blp",
    resource = "wood",
    func = function(u2, rlc_data, index)
      local refresh = data.refresh
      if refresh.regenerate_pools and (not refresh.shared_all or index == 1) then
        pools = refresh.regenerate_pools(u2)
      end
      for _ = 1, 20 do
        local var = generateOneRandomVarByIndex(u2, pools, poolsstr, index)
        if var then
          local duplicate = false
          for i, opt in ipairs(rlc_data.options or {}) do
            if opt.__var_name == var.name then
              duplicate = true
              break
            end
          end
          if not duplicate then
            local new_data = _make_rlc_data_from_dvar(u2, {var}, poolsstr, data.desc, {
              skip_medicinegetend = data.skip_medicinegetend
            })
            if new_data.options and new_data.options[1] then
              if data.option_func_wrapper then
                data.option_func_wrapper(new_data.options[1])
              end
              return new_data.options[1]
            end
          end
        end
      end
    end
  }
end

local function generateThreeSpecialItems(u, item_pools, count)
  count = count or 3
  local retry_limit = 30
  local got = {}
  local picked_types = {}
  for i = 1, count do
    local attempt = 0
    local picked
    while retry_limit > attempt do
      attempt = attempt + 1
      u:setdata("只返回值")
      local x, y = u:getxy()
      local data = herogetitem(u.handle, item_pools, x, y)
      u:deldata("只返回值")
      if data and data.itemtype and not picked_types[data.itemtype] then
        picked = data
        break
      end
    end
    if not picked then
      return {}
    end
    local itemtype = picked.itemtype
    picked_types[itemtype] = true
    local name = slk.item[itemtype] and slk.item[itemtype].Name or "未知物品"
    local tip = slk.item[itemtype] and slk.item[itemtype].Ubertip or ""
    local icon = slk.item[itemtype] and slk.item[itemtype].Art or "war3mapImported\\Black.blp"
    if not icon:match("%.tga$") and not icon:match("%.blp$") then
      icon = icon .. ".tga"
    end
    tip = tip:gsub(",DataA1.*", "")
    tip = tip:gsub(",Dur1.*", "")
    table.insert(got, {
      itemtype = itemtype,
      name = name,
      desc = tip,
      icon = icon,
      func = function()
        local sy = u.ownerid
        local x, y = u:getxy()
        local nwp = herogetitem(u.handle, item_pools, x, y, itemtype)
        if GetItemTypeId(nwp) == S2ID("I0H1") then
          local bb = getunit(Beibao[sy])
          bb:addspeitem(nwp)
        else
          u:addspeitem(nwp)
        end
      end
    })
  end
  return got
end

local function _make_rlc_data_from_items(u, items)
  local opts = {}
  for i = 1, #items do
    local it = items[i]
    table.insert(opts, {
      icon = it.icon,
      title = it.name,
      text = it.desc,
      func = it.func
    })
  end
  return {options = opts}
end

function guobodvarget(args)
  local u = args.u
  local pools = args.pools
  local poolsstr = args.poolsstr
  local refresh = args.refresh
  local option_count = args.option_count or args.count or 3
  local option_func_wrapper = args.option_func_wrapper
  if u:hasdata("神器判定-至尊魔戒") and (poolsstr == "普通过波遗物" or poolsstr == "稀有过波遗物" or poolsstr == "BOSS过波遗物") then
    u:sendmessage("|cFFFF0000至尊魔戒-神器获取失败|r")
    return false
  end
  local show = false
  if u:getdata("战斗时间") == 0 then
    show = true
  end
  local dvar
  if poolsstr == "特殊物品" then
    dvar = generateThreeSpecialItems(u, pools, option_count)
  else
    dvar = generateThreeRandomVars(u, pools, poolsstr, option_count)
  end
  if #dvar == 0 then
    return false
  end
  local data
  if poolsstr == "特殊物品" then
    data = _make_rlc_data_from_items(u, dvar)
  else
    data = _make_rlc_data_from_dvar(u, dvar, poolsstr, "|cFFFFCC66选择一项|r", {
      skip_medicinegetend = args.skip_medicinegetend
    })
  end
  if refresh and not is_guobo_relic_pool(poolsstr) and poolsstr ~= "特殊物品" then
    if type(refresh) == "table" then
      data.option_func_wrapper = option_func_wrapper
      data.refresh = make_potion_refresh(u, data, pools, poolsstr)
      for k, v in pairs(refresh) do
        data.refresh[k] = v
      end
    else
      data.option_func_wrapper = option_func_wrapper
      data.refresh = make_potion_refresh(u, data, pools, poolsstr)
    end
  end
  if option_func_wrapper then
    for _, option in ipairs(data.options or {}) do
      option_func_wrapper(option)
    end
  end
  if u:hasdata("药水判定-禁止跳过") then
    data.noskip = true
  end
  RLChoose(u, data, "cards", show)
  return true
end

local function gbjlget(u, kind)
  local jlb = true
  if u:hasdata("神器判定-真空之花") and kind ~= "BOSS" then
    if u:getdata("真空之花-惩罚次数") > 0 then
      jlb = false
      u:changedata("真空之花-惩罚次数", -1)
      u:sendmessage("|cFFFF0000真空之花-获取失败|r")
    else
      u:sendmessage("|cFFFF0000真空之花-额外奖励|r")
      u:addwood(40)
      u:addgold(400)
    end
  end
  if jlb then
    local add = 50
    if Nandu_Choose >= 5 then
      add = 25
    end
    local wood = add
    local gold = 100
    if kind == "危险行星" then
      wood = add
      gold = 150
    elseif kind == "BOSS" then
      wood = 100 + add
      gold = 250
    end
    if Stage > 8 then
      wood = math.floor(wood * 0.5)
      gold = math.floor(gold * 0.5)
    end
    u:addwood(wood)
    u:addgold(gold)
    if 0 < wood then
      u:sendmessage(("|cFF99CCFF过波奖励:%s积分与%s追忆值|r"):format(gold, wood))
    else
      u:sendmessage(("|cFF99CCFF过波奖励:%s积分|r"):format(gold))
    end
  end
end

local relicxcount, relicycount = 0, 0

function addRelicToPanel(relic)
  local count = #relicRelics
  local dicon = relic.effectart or "war3mapImported\\Black.blp"
  if not dicon:match("%.tga$") and not dicon:match("%.blp$") then
    dicon = dicon .. ".tga"
  end
  relicxcount = count % 12
  relicycount = math.floor(count / 12)
  if relicycount <= 0 then
    relicycount = 0
  end
  local icon = class.button:builder({
    parent = relicPanel,
    x = 20 + relicxcount * 40,
    y = 5 + relicycount * 30,
    w = w * 0.4,
    h = h * 0.4,
    normal_image = dicon,
    on_button_mouse_enter = function(self)
      local text = relic.effectname .. "\n" .. relic.effecttext
      uiy_show_text(text, "Relic")
      self:set_alpha(155)
    end,
    on_button_mouse_leave = function(self)
      uiy_hide()
      self:set_alpha(255)
    end
  })
  table.insert(relicRelics, icon)
end

do
  local ddx2, ddy2 = 120, 50
  if EnableCustomUI then
    ddx2, ddy2 = 220, 95
  end
  relicPanel = class.panel:builder({
    parent = panel,
    x = ddx2,
    y = ddy2,
    w = 950,
    h = 60,
    normal_image = "Touming.tga"
  })
  relicPanel:set_alpha(100)
end

function RLChoose_Guobo(u)
  local count = math.max(1, Stage - 1)
  local kind = GuoboAllSet[count]
  local sy = u.ownerid
  if u:hasdata("食物-曼陀罗汁效果") then
    u:deldata("食物-曼陀罗汁效果")
  end
  if u:hasdata("食物-巧克力棒") then
    u:deldata("食物-巧克力棒")
    ChangeValue(Correction_Exp, sy, -0.25)
  end
  if u:hasdata("系统-信用卡判定") then
    u:deldata("系统-信用卡判定")
    u:sendmessage("|cFFF7F3F3[信用卡]负面效果结束")
  end
  gbjlget(u, kind)
  ac.wait(3000, function()
    nextguobopanding(u, kind)
  end)
end

local function getguobofunc(u)
  local zu = {
    {
      icon = "Guobo_Bantiaoxiang.tga",
      title = "|cFFE1A458板条箱",
      rarity = "普通",
      text = "|cFFE1A458获得300积分\n50%额外获得200积分\n1%额外获得2000积分|r",
      func = function(u)
        u:addgold(300)
        if GetRandom100(50) then
          u:addgold(200)
          u:sendmessage("|cFFE1A458你在板条箱里面搜出来了一些有价值的东西……(额外获得200积分)")
        end
        if GetRandom100(1) then
          u:addgold(2000)
          SendMsgAll(u:getplayername() .. "|cFFE1A458在板条箱里面搜出来金条")
        end
      end
    },
    {
      icon = "Guobo_Qiaokelibang.tga",
      title = "|cFFE1A458巧克力棒",
      rarity = "普通",
      text = "|cFFE1A458提升3级\n接下来的一波提升25%经验获取率直至波数结束|r",
      func = function(u)
        local sy = u.ownerid
        u:addlevel(3)
        u:setdata("食物-巧克力棒")
        ChangeValue(Correction_Exp, sy, 0.25)
      end
    },
    {
      icon = "Guobo_Rekeke.tga",
      title = "|cffa55b54热可可|r",
      rarity = "普通",
      text = "|cffa55b54触发以下一项:\n95%提升1点启动承载上限\n5%提升3点启动承载上限|r",
      func = function(u)
        if GetRandom100(95) then
          u:sendmessage("|cffa55b54喝下热可可提升1启动承载上限")
          u:changedata("系统-启动承载上限", 1)
        else
          u:sendmessage("|cffa55b54喝下热可可提升3启动承载上限")
          u:changedata("系统-启动承载上限", 3)
        end
      end
    },
    {
      icon = "Guobo_Shengdai.tga",
      title = "|cFF72ECCD圣代|r",
      rarity = "普通",
      text = "|cFF72ECCD获得25杀敌奖励\n接下来75次杀敌会额外触发一次(同类效果不叠加,次数可累积)|r",
      func = function(u)
        local sy = u.ownerid
        ac.timer(1, 25, function()
          KillCount[sy] = KillCount[sy] + 1
          monsterrewardget1(u.handle, BOSS_DEATH)
          monsterrewardget2(u.handle, BOSS_DEATH)
        end)
        u:changedata("食物-圣代杀戮祝福次数", 75)
        u:sendmessage("|cFF72ECCD圣代剩余杀敌奖励次数：" .. math.floor(u:getdata("食物-圣代杀戮祝福次数")) .. "|r")
      end
    },
    {
      icon = "Guobo_Xiaoxiongbinggan.tga",
      title = "|cFFF7CF8D小熊饼干|r",
      rarity = "普通",
      text = "|cFFF7CF8D获得[29~49]追忆值|r",
      func = function(u)
        local add = GetRandomInt(29, 49)
        u:addwood(add)
        u:sendmessage("|cFFF7CF8D小熊饼干获得追忆值:" .. add .. "|r")
      end
    },
    {
      icon = "Guobo_Xinyongka.tga",
      title = "|cFFF7F3F3信用卡|r",
      rarity = "普通",
      text = "|cFFF7F3F3获得1888积分\n接下来的一波内无法通过任何方式获取积分直至波数结束|r",
      func = function(u)
        u:addgold(1888)
        u:setdata("系统-信用卡判定")
      end
    },
    {
      icon = "Guobo_Yitaisuipian.tga",
      title = "|cFF90B5EA次|r|cFF97AEEB元|r|cFF9DA8EC碎|r|cFFA4A1ED片|r",
      rarity = "普通",
      text = "|cFF90B5EA提升1神力承载上限\n降低神名之石20购买价格|r",
      func = function(u)
        u:changedata("系统-神力承载上限", 1)
        u:changedata("神名之石-累积价格", -20)
      end
    }
  }
  local show3 = sample_unique(zu, 3)
  if GetRandom100(5) then
    table.insert(show3, {
      icon = "Guobo_Mingyunjinbi.tga",
      title = "|cFFEFC649命运金币|r",
      rarity = "史诗",
      text = "|cFFEFC649触发以下一项:\n50%即死自身\n50%提升4神力承载上限",
      func = function(u)
        PlayGlobalSound(Sound_Guobo_Yingbi)
        SendMsgAll(u:getplayername() .. "|cFFEFC649投掷了命运金币")
        ac.wait(3000, function()
          local x, y = u:getxy()
          if GetRandom100(50) then
            local tx = Effectcreate("war3mapImported\\by_wood_effect_yubanmeiqin_lightning_zhenzhengdeluolei.mdl", x, y, -1)
            SetEffectSize(tx, 2, 2, 4.5)
            DestroyEffectLua(tx)
            Effectcreate("Abilities\\Weapons\\Bolt\\BoltImpact.mdl", x, y)
            u:kill()
            SendMsgAll(u:getplayername() .. "|cFF990000死了|r")
          else
            Effectcreate("Abilities\\Spells\\Human\\Resurrect\\ResurrectCaster.mdl", x, y, 0, 2)
            u:changedata("系统-神力承载上限", 4)
            SendMsgAll(u:getplayername() .. "|cFFFFCC00获得了赐福|r")
          end
        end)
      end
    })
  end
  if GetRandom100(2) then
    table.insert(show3, {
      icon = "Guobo_Mantuoluozhi.tga",
      title = "|cFF27DCC9曼陀罗汁|r",
      rarity = "史诗",
      text = "|cFF27DCC9提升3级\n提升40全属性\n获得50追忆值\n获得300积分\n接下来的一波降低95%伤害与损耗效果直至波数结束|r\n|cFF949596回过神来，已是豪饮|r",
      func = function(u)
        u:addlevel(3)
        u:addallstats(40)
        u:addwood(50)
        u:addgold(300)
        u:setdata("食物-曼陀罗汁效果")
        SendMsgAll(u:getplayername() .. "|cFF27DCC9干了一杯曼陀罗汁|r")
        u:addstexiao("曼陀罗汁", "终结伤害计算效果", function(args)
          local tg = args.tg
          local u = args.u
          local info = args.damageinfo
          if u:hasdata("食物-曼陀罗汁效果") then
            info.enddown = info.enddown * 0.05
          end
        end)
      end
    })
  end
  return show3
end

function nextguobopanding(u, kind)
  if u:getdata("真空之花-惩罚次数") > 0 and kind ~= "BOSS" then
    u:sendmessage("|cFFFF0000真空之花-获取失败|r")
    return
  end
  if kind == "危险行星" then
    if GetRandom100(50) then
      guobodvarget({
        u = u,
        pools = {
          Guoboyiwu_Normal
        },
        poolsstr = "普通过波遗物"
      })
    else
      guobodvarget({
        u = u,
        pools = {
          Guoboyiwu_Rare,
          Guoboyiwu_SuperRare
        },
        poolsstr = "稀有过波遗物"
      })
    end
    return
  end
  if kind == "BOSS" then
    if Stage - 1 == 7 then
      guobodvarget({
        u = u,
        pools = {
          Guoboyiwu_BOSS
        },
        poolsstr = "BOSS过波遗物"
      })
    else
      guobodvarget({
        u = u,
        pools = {
          Guoboyiwu_Rare,
          Guoboyiwu_SuperRare
        },
        poolsstr = "稀有过波遗物"
      })
    end
    return
  end
  if kind == "空间站" or kind == "乐土商店" then
    return
  end
  if Quanju_Shenqiboolean or Boolean_TestMode then
    if GetRandom100(90) then
      guobodvarget({
        u = u,
        pools = {
          Guoboyiwu_Normal
        },
        poolsstr = "普通过波遗物"
      })
    else
      guobodvarget({
        u = u,
        pools = {
          Guoboyiwu_Rare,
          Guoboyiwu_SuperRare
        },
        poolsstr = "稀有过波遗物"
      })
    end
  else
    local show3 = getguobofunc(u)
    local data = {
      desc = "|cFFFFCC66【过波奖励】|r",
      options = show3
    }
    local show = false
    if u:getdata("战斗时间") == 0 then
      show = true
    end
    RLChoose(u, data, "cards", show)
  end
end

local function _build_endplanet_all_options()
  return {
    {
      icon = "UI_NewB_P3.blp",
      title = "|cFFFF9966找到了些许记忆碎片",
      rarity = "普通",
      text = "|cFFFF9966选择获得一份传奇力量|r",
      func = function(u)
        ac.wait(250, function()
          guobodvarget({
            u = u,
            pools = VarsCiyuanPools(Vars_Ciyuan_Spe, Vars_Ciyuan_Shenhua, Vars_Huiyi_Dz, Vars_Ciyuan_Yuanshi, Vars_Ciyuan_Yuanshi_Spe, Vars_Lingjiejing, Vars_Shalujiejing, Vars_Ciyuan_Longmenshi),
            poolsstr = "次元"
          })
        end)
      end
    },
    {
      icon = "Shenqi_N_45.blp",
      title = "|cFF99CCFF找回了遗失的神器",
      rarity = "普通",
      text = "|cFF99CCFF选择获得一件神器|r",
      func = function(u)
        ac.wait(250, function()
          if GetRandom100(75) then
            guobodvarget({
              u = u,
              pools = {
                Guoboyiwu_Normal
              },
              poolsstr = "普通过波遗物"
            })
          else
            guobodvarget({
              u = u,
              pools = {
                Guoboyiwu_Rare,
                Guoboyiwu_SuperRare
              },
              poolsstr = "稀有过波遗物"
            })
          end
        end)
      end
    },
    {
      icon = "Shenqi_N_Fenliejinbi.blp",
      title = "|cffffe554忙着收集资源",
      rarity = "普通",
      text = "|cffffe554获得 200 积分 与 100 追忆值|r",
      func = function(u)
        local sy = u.ownerid
        u:addgold(200)
        u:addwood(100)
      end
    },
    {
      icon = "UI_NewB_Spe.blp",
      title = "|cFFCC99FF找到了有用的物品",
      rarity = "普通",
      text = "|cFFCC99FF选择获得一件特殊物品|r",
      func = function(u)
        guobodvarget({
          u = u,
          pools = {
            Pools_Spe,
            Pools_SpeDzWeapon
          },
          poolsstr = "特殊物品"
        })
      end
    }
  }
end

function OpenEndPlanetSummaryChoices(u, isshownow)
  if GetRandom100(75) then
    guobodvarget({
      u = u,
      pools = {
        Guoboyiwu_Normal
      },
      poolsstr = "普通过波遗物"
    })
  else
    guobodvarget({
      u = u,
      pools = {
        Guoboyiwu_Rare,
        Guoboyiwu_SuperRare
      },
      poolsstr = "稀有过波遗物"
    })
  end
end
