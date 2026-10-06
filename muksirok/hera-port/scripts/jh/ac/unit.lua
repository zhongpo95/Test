-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local japi = require("jass.japi")
local handle_ref = require("jh.base.handle_ref")
local jhplayer = require("jh.ac.player")
local UnitData = require("jh.data")
local on_root_shiki_ready, data_change_handlers, on_data_cleared
local unit = {}
unit.allunits = {}
unit.handle = 0
unit.type = 0
unit.user_data = nil
unit.owner = 0
unit.ownerid = 0
unit.id = unit.ownerid

function unit.configure_gameplay(config)
  on_root_shiki_ready = assert(config.on_root_shiki_ready, "root shiki callback is required")
  data_change_handlers = config.data_change_handlers
  on_data_cleared = config.on_data_cleared
end

function getunit(handle)
  if handle == 0 then
    print("尝试获取句柄0")
    printCallStack()
    error("尝试获取句柄0", 2)
  end
  local existing = unit.allunits[handle]
  if existing then
    return existing
  end
  local initialized = unit:init(handle)
  if initialized then
    return initialized
  end
  error("初始化单位失败", 2)
end

function unit:init(newunit)
  local handle = newunit
  if handle == 0 then
    print("尝试初始化句柄0")
    printCallStack()
    return
  end
  if unit.allunits[handle] then
    return unit.allunits[handle]
  end
  if handle == 0 then
    print("句柄0")
    printCallStack()
    return nil
  end
  local u = {}
  setmetatable(u, {__index = self})
  u.handle = handle
  u.owner = GetOwningPlayer(handle)
  u.ownerid = GetConvertedPlayerId(u.owner)
  u.type = GetUnitTypeId(handle)
  u.user_data = {}
  if handle == nil then
    handle = 0
  end
  handle_ref.ref(handle)
  u.handle_generation = handle_ref.generation(handle)
  unit.allunits[handle] = u
  return u
end

function unit:createunit(unittype, x, y, face)
  local handle = CreateUnitLua(self.owner, unittype, x, y, face or 0)
  return getunit(handle)
end

function unit:get(handle)
  return getunit(handle)
end

function unit:setdata(key, value)
  local handler = data_change_handlers and data_change_handlers[key]
  if not handler then
    UnitData.set(self, key, value)
    return
  end
  local old_value = UnitData.get(self, key)
  UnitData.set(self, key, value)
  local new_value = UnitData.get(self, key)
  if old_value ~= new_value then
    handler(self, old_value, new_value)
  end
end

function unit:cleardata()
  UnitData.clear(self)
  if on_data_cleared then
    on_data_cleared(self)
  end
end

function unit:settimedata(key, time, value)
  UnitData.set_timed(self, key, time, value)
end

function unit:getdata(key)
  return UnitData.get(self, key)
end

function unit:deldata(key)
  local handler = data_change_handlers and data_change_handlers[key]
  if not handler then
    UnitData.delete(self, key)
    return
  end
  local old_value = UnitData.get(self, key)
  UnitData.delete(self, key)
  local new_value = UnitData.get(self, key)
  if old_value ~= new_value then
    handler(self, old_value, new_value)
  end
end

function unit:hasdata(key)
  return UnitData.has(self, key)
end

function unit:addstats(str, agi, int, all)
  str = str or 0
  agi = agi or 0
  int = int or 0
  all = all or 0
  if self:hasdata("隐藏职业-混沌之种揭露") then
    local add = str + agi + int + all
    self:addallstats(add)
    return
  end
  str = str or 0
  agi = agi or 0
  int = int or 0
  all = all or 0
  self:addstr(str + all)
  self:addagi(agi + all)
  self:addint(int + all)
end

function unit:addmainstats(stats)
  local u = self
  local str = "str"
  local max = u:getstr()
  if max <= u:getagi() then
    str = "agi"
    max = u:getagi()
  end
  if max <= u:getint() then
    str = "int"
  end
  if u:hasdata("隐藏职业-混沌之种揭露") then
    self:addallstats(stats)
    return
  end
  if str == "str" then
    self:addstr(stats)
  end
  if str == "agi" then
    self:addagi(stats)
  end
  if str == "int" then
    self:addint(stats)
  end
end

function unit:addstr(str)
  if self:hasdata("隐藏职业-混沌之种揭露") and not self:hasdata("混沌之种-属性添加中") then
    self:setdata("混沌之种-属性添加中")
    self:addagi(str)
    self:addint(str)
    self:deldata("混沌之种-属性添加中")
  end
  self:changedata("力量", str)
  if not self:hasdata("变异判定-幼小的魔王") and not self:hasdata("系统-力量不提升上限") and not self:hasdata("混沌之种-属性添加中") then
    self:changeoriginmaxhp(1 * str)
  end
end

function unit:addagi(agi)
  if self:hasdata("隐藏职业-混沌之种揭露") and not self:hasdata("混沌之种-属性添加中") then
    self:setdata("混沌之种-属性添加中")
    self:addstr(agi)
    self:addint(agi)
    self:deldata("混沌之种-属性添加中")
  end
  self:changedata("敏捷", agi)
end

function unit:addint(int)
  if self:hasdata("隐藏职业-混沌之种揭露") and not self:hasdata("混沌之种-属性添加中") then
    self:setdata("混沌之种-属性添加中")
    self:addstr(int)
    self:addagi(int)
    self:deldata("混沌之种-属性添加中")
  end
  self:changedata("智力", int)
  self:setmaxmp(self:getmaxmp() + 0.25 * int)
end

function unit:addallstats(all)
  all = all or 0
  self:addstr(all)
  self:addagi(all)
  self:addint(all)
end

function unit:getowner()
  return self.owner
end

function unit:getownerid()
  return self.ownerid
end

function unit:gethp()
  local hp = self:getdata("生命值") or 0
  if hp < 0 then
    return 0
  end
  return hp
end

function unit:getmaxhp()
  local maxhp = self:getdata("生命上限") + 1.0E-4
  if maxhp < 0 then
    return 1.0E-4
  end
  return maxhp
end

function unit:setmp(mp, ispercent)
  ispercent = ispercent or false
  local max = self:getmaxmp()
  if ispercent then
    mp = mp * 0.01 * max
  end
  if max < mp then
    mp = max
  end
  if mp <= 0 then
    mp = 0
  end
  self:setdata("魔法值", mp)
end

function unit:curemp(mp, permaxmp)
  permaxmp = permaxmp or 0
  local max = self:getmaxmp()
  mp = mp + permaxmp * 0.01 * max
  if 0 < mp and self:hasdata("英雄-C呆") then
    mp = mp * self:getdata("C呆-抑制魔力恢复")
  end
  mp = self:getmp() + mp
  if max < mp then
    mp = max
  end
  if mp <= 0 then
    mp = 0
  end
  self:setdata("魔法值", mp)
end

function unit:getmp()
  return self:getdata("魔法值")
end

function unit:getmaxmp()
  return self:getdata("魔法上限")
end

function unit:changemaxmp(mp, permp)
  permp = permp or 0
  mp = mp + 0.01 * permp * self:getmaxmp()
  self:setdata("魔法上限", self:getmaxmp() + mp)
end

function unit:setmaxmp(mp)
  self:setdata("魔法上限", mp)
end

function unit:getagi()
  local data = self:getdata("敏捷")
  data = data * (1 + 0.0 * self:getdata("始源值") + self:getdata("效果增强-全属性"))
  return data
end

function unit:getstr()
  local data = self:getdata("力量")
  data = data * (1 + 0.02 * self:getdata("始源值") + self:getdata("效果增强-全属性"))
  return data
end

function unit:getint()
  local data = self:getdata("智力")
  data = data * (1 + 0.02 * self:getdata("始源值") + self:getdata("效果增强-全属性"))
  return data
end

function unit:getoriginagi()
  return self:getdata("敏捷")
end

function unit:getoriginstr()
  return self:getdata("力量")
end

function unit:getoriginint()
  return self:getdata("智力")
end

function unit:getlevel()
  return GetHeroLevel(self.handle)
end

function unit:getattack()
  return GetUnitState(self.handle, ConvertUnitState(18)) + GetUnitState(self.handle, ConvertUnitState(19))
end

function unit:getallattri()
  return self:getstr() + self:getagi() + self:getint()
end

function unit:getperhp()
  local per = self:gethp() / self:getmaxhp() * 100
  if per < 0 then
    per = 0
  elseif 100 < per then
    per = 100
  end
  return per
end

function unit:getmissperhp()
  return 100 - self:getperhp()
end

function unit:mousexyflash()
  if self.owner == LocalPlayer then
    japi.DzSyncData("mousex", japi.DzGetMouseTerrainX())
    japi.DzSyncData("mousey", japi.DzGetMouseTerrainY())
  end
end

function unit:getmousexy()
  return tonumber(self:getdata("鼠标位置X")), tonumber(self:getdata("鼠标位置Y"))
end

function unit:islocal()
  if LocalPlayer == self.owner then
    return true
  else
    return false
  end
end

function unit:getmisshp()
  return self:getmaxhp() - self:gethp()
end

function unit:getpermp()
  return self:getmp() / self:getmaxmp() * 100
end

function unit:systemkill()
  KillUnit(self.handle)
end

function unit:sethp(hp, ispercent)
  ispercent = ispercent or false
  if self:gethp() > 0 and not self:hasdata("系统-已删模") then
    if ispercent then
      hp = hp * 0.01 * self:getmaxhp()
    end
    if hp > self:getmaxhp() then
      hp = self:getmaxhp()
    end
    self:setdata("生命值", hp)
    if 0 >= self:getdata("生命值") then
      self:setdata("死亡判定延迟")
    end
    self:flashhp()
  end
end

function unit:relive(x, y, boolean)
  local x2, y2 = self:getxy()
  self:setdata("生命值", self:getdata("生命上限"))
  SetUnitState(self.handle, UNIT_STATE_LIFE, 10000)
  self:setmapxy(x, y)
  ReviveHero(self.handle, x or x2, y or y2, boolean or false)
  if self:hasdata("死亡中英雄") then
    self:deldata("死亡中英雄")
  end
end

function unit:changeoriginmaxhp(hp, perhp)
  local sy = self:getownerid()
  hp = hp + (perhp or 0) * 0.01 * Correction_MHpOrigin[sy]
  Correction_MHpOrigin[sy] = Correction_MHpOrigin[sy] + hp
  self:flashmaxhp()
end

function unit:changemaxhp(hp, perhp)
  if self:hasdata("免疫生命修改") or self:hasdata("系统-免疫生命修改") or self:hasbuff("永恒") and hp <= 0 then
    return
  end
  if self:isingroup(Group_AllHero) then
    local sy1 = self:getownerid()
    hp = hp + (perhp or 0) * 0.01 * Correction_MHpOrigin[sy1]
    if 0 < hp and not self:hasdata("系统-降低减少上限") then
      if Keyan_Gaiyazuzhou then
        hp = hp * 0.5
      end
      Correction_MHpDeOrigin[sy1] = Correction_MHpDeOrigin[sy1] + hp
      self:flashmaxhp()
    else
      Correction_MHpDeOrigin[sy1] = Correction_MHpDeOrigin[sy1] + hp
      self:flashmaxhp()
      if self:hasdata("模组-魅魔模组") then
        self:changedata("魅魔模组-基础伤害加成", 3.0E-4)
        DamageSystem_Shjc[sy1] = DamageSystem_Shjc[sy1] + 3.0E-5
      end
      if self:hasdata("变异判定-幼小的魔王") then
        self:changedata("阿米娅-减少生命上限", -1 * hp)
      end
    end
  else
    if (self:hasdata("BOSS-真红") or self:hasdata("BOSS-暗神")) and hp < 0 then
      if Nandu_Choose >= 5 then
        hp = hp * 0.4
      else
        hp = hp * 0.6
      end
    end
    hp = hp + (perhp or 0) * 0.01 * self:getmaxhp()
    local bfb = self:getperhp()
    self:setdata("免疫生命修改")
    if 0 >= hp + self:getmaxhp() then
      self:setdata("生命上限", 1)
    else
      self:setdata("生命上限", hp + self:getmaxhp())
    end
    self:deldata("免疫生命修改")
    self:sethp(bfb, true)
  end
end

function unit:changedata(DataName, value, type)
  type = type or 0
  if type == 0 then
    self:setdata(DataName, self:getdata(DataName) + value)
  end
  if type == 1 then
    self:setdata(DataName, self:getdata(DataName) * value)
  end
  if type == 2 then
    self:setdata(DataName, self:getdata(DataName) / value)
  end
end

function unit:changetimedata(DataName, value, time, type)
  time = time or 0
  type = type or 0
  if type == 0 then
    self:setdata(DataName, self:getdata(DataName) + value)
  end
  if type == 1 then
    self:setdata(DataName, self:getdata(DataName) * value)
  end
  if type == 2 then
    self:setdata(DataName, self:getdata(DataName) / value)
  end
  if time ~= 0 then
    ac.wait(time * 1000, function()
      if type == 0 then
        self:setdata(DataName, self:getdata(DataName) - value)
      end
      if type == 1 then
        self:setdata(DataName, self:getdata(DataName) / value)
      end
      if type == 2 then
        self:setdata(DataName, self:getdata(DataName) * value)
      end
    end)
  end
end

function unit:select(handle)
  handle = handle or self.handle
  if type(handle) == "number" then
    handle = getunit(handle)
  end
  SelectUnitForPlayerSingle(handle.handle, self.owner)
end

function unit:clearselect()
  if self:islocal() then
    ClearSelection()
  end
end

function LossHpUnit(args)
  local u = args.u
  local tg = args.tg
  local damage = args.damage or 0
  local perhp = args.perhp or 0
  local maxhp = args.maxhp or 0
  local bj = args.bj or "未整合损耗"
  u:setdata("伤害统计-生命损耗标记", bj)
  tg:losshp(u, damage, perhp, maxhp)
  u:deldata("伤害统计-生命损耗标记")
end

function unit:losshp(soc, dehp, perdehp, perdemaxhp)
  if not self:isalive() or self:hasdata("免疫生命损耗") or self:hasdata("生命值-损耗判定中") or self:hasdata("生命值-数值设定中") or self:hasbuff("永恒") or self:hasbuff("停滞") then
    return
  end
  local u = self
  self:setdata("生命值-损耗判定中")
  if not perdehp then
    perdehp = 0
  else
    perdehp = perdehp * 0.01 * self:gethp()
  end
  if not perdemaxhp then
    perdemaxhp = 0
  else
    perdemaxhp = perdemaxhp * 0.01 * self:getmaxhp()
  end
  dehp = dehp + perdehp + perdemaxhp
  local loss_bonus = soc:getdata("生命损耗效果增强")
  if loss_bonus ~= 0 and u.handle ~= soc.handle then
    dehp = dehp * (1 + loss_bonus)
  end
  if soc:hasdata("神器判定-枯枝") then
    dehp = dehp * 1.25
  end
  local sy1 = self:getownerid()
  if self:hasdata("两仪式-根源接续") then
    dehp = dehp * 0.9
    if not self:hasdata("两仪式-根源接续冷却") then
      ChangeValue(DamageSystem_Shjc, sy1, 0.1 * (3.0E-4 * self:getperhp() * 0.01))
      self:settimedata("两仪式-根源接续冷却", 0.5)
    end
  end
  if self:hasdata("魔镜-强化") and self:hasdata("物品-魔镜") then
    dehp = dehp * 0.9
  end
  if self:hasdata("变异判定-根源式") then
    dehp = dehp * 0.75
  end
  if self:hasdata("物品-潘多拉之心") and Boolean_Pandora then
    dehp = dehp * 0.5
  end
  if u:hasdata("神器判定-混沌之种") then
    dehp = dehp * 0.5
  end
  if soc:hasdata("神器判定-混沌之种") then
    dehp = dehp * 0.25
  end
  if soc:hasdata("无序之力-影响深度") and u.handle ~= soc.handle then
    dehp = dehp * soc:getdata("无序之力-影响深度")
  end
  if soc:hasdata("食物-曼陀罗汁效果") then
    dehp = dehp * 0.05
  end
  if self:hasdata("BOSS-暗神") then
    if Nandu_Choose >= 5 then
      dehp = dehp * 0.4
    else
      dehp = dehp * 0.6
    end
    if soc:hasdata("超维晶域") then
      dehp = dehp * 0.01
    end
  end
  if self:hasdata("BOSS-真红") then
    if Nandu_Choose >= 5 then
      dehp = dehp * 0.4
    else
      dehp = dehp * 0.6
    end
    if u:hasdata("小爱帮助") then
      dehp = dehp * 0.5
    else
      dehp = 0
    end
  end
  if 0 < self:getdata("魔王特性数量") and Nandu_Choose >= 5 then
    dehp = dehp * (1 - 0.1 * self:getdata("魔王特性数量"))
  end
  if Nandu_Choose >= 5 and self:isboss() then
    if Nandu_Shenzhao then
      dehp = dehp * 0.34
    else
      dehp = dehp * 0.67
    end
  end
  if Keyan_Yuanshililiang and u.handle ~= soc.handle then
    dehp = dehp * 0.2
  end
  if dehp < 0 then
    dehp = 0
  end
  if 100 <= dehp then
    if soc:hasdata("神器判定-刺河豚") and soc.handle ~= u.handle then
      local bjl = u:getdata("显示-暴击率") / 2
      local bjsh = 1.25 + (u:getdata("显示-暴击伤害") - 1.25) / 2
      if GetRandom100(bjl) then
        dehp = dehp * bjsh
      end
    end
    local wz, length
    local big = 8
    if 1000000 < dehp then
      wz = tostring(math.floor(dehp / 10000))
      length = string.len(wz)
      wz = string.sub(wz, 1, length - 2) .. "." .. string.sub(wz, length - 1, length) .. "M"
      big = 16
    elseif 100000 < dehp then
      wz = tostring(math.floor(dehp / 1000))
      length = string.len(wz)
      wz = string.sub(wz, 1, length - 1) .. "." .. string.sub(wz, length, length) .. "W"
      big = 12
    else
      wz = tostring(math.floor(dehp))
    end
    flytext({
      unit = self.handle,
      text = wz,
      size = big,
      time = 0.75,
      r = 0,
      g = 255,
      b = 255,
      height = GetRandomReal(-50.0, 0.0),
      xspeed = GetRandomReal(-0.03, 0.03),
      yspeed = 0.05
    })
  end
  if u:hasdata("亚波伦-回光返照") then
    u:curehp(u.handle, dehp, 0, 2)
    dehp = 0
  end
  if 0 < u:getdata("生命损耗临时护盾") then
    dehp = HdzLifeLossFlash(u, dehp)
  end
  if u:hasdata("幽冥之心-增强") or u:hasdata("神器判定-心之壁") then
    dehp = Hdzflash(u, dehp)
  end
  if 0 < dehp and u:hasdata("神器判定-痛苦徽章") and not u:hasdata("痛苦徽章-恢复冷却") then
    u:settimedata("痛苦徽章-恢复冷却", 0.5)
    u:curehp(u.handle, 0, 4, 2)
  end
  if u:hasbuff("无实体") then
    local max = 0.01
    if soc:isboss() then
      max = 0.05
    end
    if dehp >= max * u:getmaxhp() then
      dehp = max * u:getmaxhp()
    end
  end
  local add = dehp
  if dehp >= self:gethp() then
    add = self:gethp() - 2
    if u:hasdata("神器判定-扭曲之光") then
      self:deldata("生命值-损耗判定中")
      return
    end
    self:sethp(2)
    if u:getdata("法则侵蚀叠加层数") > 15 then
      u:kill()
    end
  else
    self:sethp(self:gethp() - dehp)
    if self:hasdata("栗山未来-血液逆流") then
      self:changedata("栗山未来-血液逆流累积值", dehp)
    end
  end
  if soc:isingroup(Group_PlayHero) then
    soc:changedata("伤害统计-累积造成伤害", add)
    if self:hasdata("伤害测试标记") and not self:hasdata("伤害测试标记-运行中") then
      self:settimedata("伤害测试标记-运行中", 1)
      ac.wait(999, function()
        soc:sendmessage("当前DPS:" .. soc:getdata("伤害测试-累积造成伤害"))
        soc:setdata("伤害测试-累积造成伤害", 0)
      end)
    end
    if u:hasdata("系统-BOSS") then
      local sy2 = soc.ownerid
      u:changedata("伤害统计-来自玩家累积伤害" .. sy2, add)
      u:changedata("伤害统计-来自玩家累积伤害总和", add)
      if not u:hasdata("伤害统计-分钟数") then
        u:setdata("伤害统计-分钟数", Time_M)
        u:setdata("伤害统计-秒钟数", Time_S)
      end
      local bj = "未整合损耗"
      if soc:hasdata("伤害统计-生命损耗标记") then
        bj = soc:getdata("伤害统计-生命损耗标记")
      end
      local dmg = add
      local pid = soc.ownerid
      local pStat = DAMAGE_STAT_BY_BJ[pid]
      local stat = pStat[bj]
      if not stat then
        stat = {
          total = 0,
          times = 0,
          max = 0
        }
        pStat[bj] = stat
      end
      stat.total = stat.total + dmg
      stat.times = stat.times + 1
      if dmg > stat.max then
        stat.max = dmg
      end
    end
  end
  self:deldata("生命值-损耗判定中")
end

function unit:flashhp()
  if not self:hasdata("生命值刷新间隔") then
    self:setdata("生命值刷新间隔")
    ac.wait(10, function()
      self:deldata("死亡判定延迟")
      self:deldata("生命值刷新间隔")
      if self:getdata("生命值") > 0 then
        local bfb = self:getdata("生命值") / self:getdata("生命上限")
        SetUnitState(self.handle, UNIT_STATE_LIFE, bfb * 10000 + 0.5)
      else
        if self:ishasrelive() then
          ac.wait(950, function()
            self:setdata("生命值", self:getdata("生命上限"))
            self:flashhp()
          end)
        end
        if self:hasdata("系统-怪物模板") then
          Monsterdeadfunc(self.handle)
        else
          KillUnit(self.handle)
        end
      end
    end)
  end
end

function unit:banrelive()
  self:delskill("A0AB")
  self:delskill("A02E")
end

function unit:ishasrelive()
  if self:ishasskill("A0AB") then
    return true
  end
  if self:ishasskill("A02E") then
    return true
  end
  if self:ishasskill("A0P2") then
    return true
  end
  return false
end

function unit:flashmaxhp()
  if not self:hasdata("生命上限刷新间隔") then
    self:setdata("生命上限刷新间隔")
    ac.wait(10, function()
      self:deldata("生命上限刷新间隔")
      local u = self
      local sy = u.ownerid
      local hpbfb = u:getperhp()
      if Correction_MHpOrigin[sy] <= 1 then
        Correction_MHpOrigin[sy] = 1
      end
      local bfb = Correction_MHp[sy] * Correction_MHpDe[sy]
      local mhp = bfb * Correction_MHpOrigin[sy]
      mhp = mhp + Correction_MHpDeOrigin[sy]
      if u:hasdata("神器判定-黑蜡烛") then
        mhp = mhp * 1.1
      end
      if u:hasdata("神器判定-APTX4869") then
        mhp = mhp * (1 - u:getdata("APTX4869-降低数值"))
      end
      if u:hasdata("染血的冠军腰带-诅咒") then
        mhp = mhp * 0.7
      end
      if u:hasdata("神器判定-嗝屁猫") then
        mhp = mhp * u:getdata("嗝屁猫-生命上限调整")
      end
      if u:hasdata("永恒王座-锁定生命上限") then
        mhp = u:getdata("永恒王座-锁定生命上限")
      end
      mhp = math.floor(mhp)
      if mhp <= 1 then
        mhp = 1
      end
      u:setdata("系统-刷新生命上限中")
      if mhp ~= u:getmaxhp() then
        u:setmaxhp(mhp)
      end
      u:sethp(hpbfb, true)
      u:flashhp()
      u:deldata("系统-刷新生命上限中")
    end)
  end
end

function unit:damagelosshp(dehp, soc)
  if not self:isalive() then
    return
  end
  local u = self
  soc = soc or getunit(BOSS_DEATH)
  u:setdata("系统-最后伤害单位", soc.handle)
  if 0 <= dehp then
    u:changedata("生命值", -dehp)
  elseif 0 < self:gethp() then
    u:changedata("生命值", -dehp)
  end
  if 0 >= u:getdata("生命值") then
    u:setdata("死亡判定延迟")
  end
  self:flashhp()
end

function unit:isalive()
  if self:hasdata("死亡判定延迟") then
    return true
  end
  return self:gethp() > 0 and not self:hasdata("系统-已删模")
end

function unit:ishasbuff(buff)
  if type(buff) == "string" then
    buff = S2ID(buff)
  end
  return GetUnitAbilityLevel(self.handle, buff) > 0
end

function unit:ishasskill(skill)
  if type(skill) == "string" then
    skill = S2ID(skill)
  end
  return GetUnitAbilityLevel(self.handle, skill) > 0
end

function unit:ishasitem(item)
  local index = 0
  if type(item) == "string" then
    item = S2ID(item)
  end
  if item ~= 0 then
    while index < 6 do
      if GetItemTypeId(UnitItemInSlot(self.handle, index)) == item then
        return true
      end
      index = index + 1
    end
  end
  return false
end

function unit:ishasspeitem(item)
  return UnitHasItem(self.handle, item)
end

function unit:istype(unittype)
  if type(unittype) == "string" then
    unittype = S2ID(unittype)
  end
  return GetUnitTypeId(self.handle) == unittype
end

function unit:addskill(skill)
  if type(skill) == "string" then
    skill = S2ID(skill)
  end
  UnitAddAbility(self.handle, skill)
  UnitMakeAbilityPermanent(self.handle, true, skill)
end

function unit:addtimeskill(skill, time)
  if type(skill) == "string" then
    skill = S2ID(skill)
  end
  UnitAddAbility(self.handle, skill)
  UnitMakeAbilityPermanent(self.handle, true, skill)
  time = time or 0
  if time ~= 0 then
    ac.wait(time * 1000, function()
      self:delskill(skill)
    end)
  end
end

function unit:delskill(skill)
  if type(skill) == "string" then
    skill = S2ID(skill)
  end
  if self:ishasskill(skill) then
    UnitRemoveAbility(self.handle, skill)
  end
end

function unit:isingroup(group)
  return IsUnitInGroupLua(self, group)
end

function unit:isnotingroup(group)
  return not IsUnitInGroupLua(self, group)
end

function unit:isgirl()
  if self:getdata("性别") == "女" or self:hasdata("系统-不受性别限制") then
    return true
  else
    return false
  end
end

function unit:isboy()
  if self:getdata("性别") == "男" or self:hasdata("系统-不受性别限制") then
    return true
  else
    return false
  end
end

function unit:gettianziqi(value)
  local u = self
  u:changedata("幸运", value)
  u:changedata("天子气", value)
  u:changedata("幸运系数", 0.01 * value)
end

function unit:getgoddessforce(value, boolean)
  if boolean ~= nil then
  else
    boolean = false
  end
  if not self:isgirl() then
    return
  end
  if boolean and not self:hasdata("属性-女神") then
    self:become("女神")
  end
  self:changedata("女神力", value)
end

function unit:effectadd(effect, loc, time)
  time = time or 0
  local tx = AddSpecialEffectTarget(effect, self.handle, loc or "origin")
  handle_ref.ref(tx)
  if 0 <= time then
    if time == 0 then
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

function unit:groupadd(group)
  GroupAdd(self, group)
end

function unit:groupremove(group)
  GroupRemove(self, group)
end

function unit:getxy()
  return GetUnitX(self.handle), GetUnitY(self.handle)
end

function unit:getplayername()
  return NowNameID[self.ownerid]
end

function unit:chat(text, time, target_sy)
  text = require("hera_korean").translate(text)
  local rb
  time = time or 0
  if self:hasdata("变异判定-战术少女") and GetRandom100(25) then
    text = text .. "nico~"
  end
  if self:hasdata("隐藏职业-喵星人已揭露") and GetRandom100(25) then
    text = text .. "喵"
  end
  if time ~= 0 then
    ac.wait(time * 1000, function()
      local p = getplayer(self.owner)
      local showname = p:getname()
      if Boolean_ColorName[p.id] then
        showname = ShowName[p.id] or ""
      end
      local message = string.format("%s%s|r:%s", p:getColorWord(), showname, text)
      rb = UI_NewChat(p, message, text, nil, target_sy)
      if System_Chat[self.ownerid] then
        for i = target_sy or 1, target_sy or 8 do
          jhplayer[i]:sendMsg(self:getplayername() .. "|cFF7DBEF1：" .. text .. "|r")
        end
      end
    end)
  else
    local p = getplayer(self.owner)
    local showname = p:getname()
    if Boolean_ColorName[p.id] then
      showname = ShowName[p.id] or ""
    end
    local message = string.format("%s%s|r:%s", p:getColorWord(), showname, text)
    rb = UI_NewChat(p, message, text, nil, target_sy)
    if System_Chat[self.ownerid] then
      for i = target_sy or 1, target_sy or 8 do
        jhplayer[i]:sendMsg(self:getplayername() .. "|cFF7DBEF1：" .. text .. "|r")
      end
    end
  end
  Time_PlayerNotChatTime[self.ownerid] = 0
  return rb
end

function unit:sendmessage(text, time)
  time = time or 10
  if UI_SystemMessage then
    UI_SystemMessage(self.owner, text, time)
  else
    DisplayTimedTextToPlayer(self.owner, 0, 0, time, text)
  end
end

function unit:getitem(item)
  if type(item) == "string" then
    item = S2ID(item)
  end
  return GetItemOfTypeFromUnitBJ(self.handle, item)
end

function unit:setplayername(name)
  NowNameID[self.ownerid] = name
  if not Lockname[self.ownerid] then
    japi.SetUnitProperName(self.handle, name)
  end
  if self:hasdata("NCDU-色彩名字开启") then
    Boolean_ColorName[self.ownerid] = true
    self:deldata("NCDU-色彩名字开启")
  end
  if self:hasdata("NCDU-色彩名字改变") then
    local zu = self:getdata("NCDU-色彩名字改变")
    ColorName[self.ownerid][1] = zu
    self:deldata("NCDU-色彩名字改变")
  end
  if self:hasdata("NCDU-色彩名字变化函数") then
    self:getdata("NCDU-色彩名字变化函数")()
    self:deldata("NCDU-色彩名字变化函数")
  end
end

function unit:setsize(size)
  SetUnitScale(self.handle, size, size, size)
end

function unit:byladdskill(skill, func)
  local u = self
  local sy = u.ownerid
  local ewl = getunit(Ewl_Skill[sy])
  Ewl_Skill_Count[sy] = Ewl_Skill_Count[sy] + 1
  local dqsl = Ewl_Skill_Count[sy]
  local dqys = ewl:getdata("当前页数")
  ewl:getdata("最大页数")
  local zs = (sy - 1) * 30
  local zs2 = zs + dqsl
  if type(skill) == "string" then
    skill = S2ID(skill)
  end
  Ewl_Skill_ID[zs2] = skill
  ewl:addskill(skill)
  if dqsl >= dqys * 10 - 9 and dqsl <= dqys * 10 + 0 then
  else
    u:banskill(skill)
  end
  ewl:addtrgevent("单位-发动技能", func)
end

function unit:timetoremove(time)
  local info = debug.getinfo(2, "Sl")
  local remove_src = info and info.short_src
  local remove_line = info and info.currentline
  time = time or 0
  if time < 0 then
    time = 0
  end
  if time ~= 0 then
    local held = handle_ref.hold(self.handle)
    ac.wait(time * 1000, function()
      RemoveUnitLua(self.handle, self.handle_generation, remove_src, remove_line)
      if unit.allunits[self.handle] == self then
        unit.allunits[self.handle] = nil
      end
      if held then
        handle_ref.release(self.handle)
      end
    end)
  else
    RemoveUnitLua(self.handle, self.handle_generation, remove_src, remove_line)
    if unit.allunits[self.handle] == self then
      unit.allunits[self.handle] = nil
    end
  end
end

function unit:remove()
  local info = debug.getinfo(2, "Sl")
  RemoveUnitLua(self.handle, self.handle_generation, info and info.short_src, info and info.currentline)
  if unit.allunits[self.handle] == self then
    unit.allunits[self.handle] = nil
  end
end

function unit:getdragonbloodpower()
  local sy1 = self.ownerid
  local lxxg = Race_Dragon_Cdxs[sy1] * Race_Dragon_Nd[sy1]
  return lxxg
end

function unit:getdragonpower()
  local sy1 = self.ownerid
  local dragonpower
  if Ewaishu[sy1] ~= 0 then
    dragonpower = self:getdata("龙变异数量") / Ewaishu[sy1]
  else
    dragonpower = 0.5
  end
  local xs
  if 0.5 <= dragonpower then
    xs = 0.5 + dragonpower
  else
    xs = 1 - dragonpower
  end
  return xs
end

function unit:setskilllevel(skill, level)
  if type(skill) == "string" then
    skill = S2ID(skill)
  end
  SetUnitAbilityLevel(self.handle, skill, level)
end

function unit:adddragonpower(value)
  self:changedata("龙血浓度", value)
end

-- 제거된 핸들과 다른 세대의 유닛에는 확장 방어력 네이티브를 호출하지 않는다.
function unit:changearmor(value)
  if not self.handle_generation or unit.allunits[self.handle] ~= self
      or not handle_ref.is_alive(self.handle, self.handle_generation) then
    return false
  end
  if GetUnitTypeId(self.handle) == 0 then
    return false
  end
  SetUnitState(self.handle, ConvertUnitState(32), GetUnitState(self.handle, ConvertUnitState(32)) + value)
  return true
end

function unit:changetimearmor(value, time)
  time = time or 0
  if not self:changearmor(value) then
    return
  end
  if time ~= 0 then
    local epoch = self.armor_pool_epoch or 0
    ac.wait(time * 1000, function()
      -- 풀에 반환된 몬스터의 이전 효과를 다음 사용 주기에 복원하지 않는다.
      if (self.armor_pool_epoch or 0) == epoch then
        self:changearmor(-1 * value)
      end
    end)
  else
    print("尝试0秒计时删除护甲")
  end
end

function unit:playsound(sound)
  if not sound or sound == 0 then
    print("尝试播放不存在音效")
    printCallStack()
    return
  end
  PlaySoundByUnitVisible(self, sound, 100)
end

function unit:kill(source, boolean)
  source = source or self.handle
  if boolean ~= nil then
  else
    boolean = false
  end
  local u = self
  local soc = getunit(source)
  u:setdata("系统-最后伤害单位", soc.handle)
  if u:isboss() then
    u:zsdamage(source)
    return
  end
  if u:hasdata("免疫即死效果") or u:hasbuff("永恒") then
    return
  end
  if u:isingroup(Group_PlayHero) or u:isingroup(Group_Monster) or u:isingroup(HellGroup) then
    if u:isingroup(Group_PlayHero) then
      local b2 = true
      if u:getdata("空观剑判定时间") > 0 then
        b2 = false
        u:setdata("空观剑判定时间", 0)
        on_root_shiki_ready(u, soc)
      end
      if u:hasdata("隐藏职业-天谴之子") and not u:hasdata("隐藏职业-天谴之子冷却") then
        b2 = false
        if u:hasdata("真红次元闭锁超即死") then
          if not u:hasdata("真红世界锁间隔") then
            u:settimedata("真红世界锁间隔", 1)
            if u:hasdata("真红-世界锁") then
              u:changedata("真红-世界锁", 0.85, 1)
            else
              u:setdata("真红-世界锁", 0.85)
            end
            u:changemaxhp(-0.2 * u:getmaxhp())
          end
          u:deldata("真红次元闭锁超即死")
        end
        local t = 15
        if soc:isboss() then
          t = 60
        end
        u:settimedata("隐藏职业-天谴之子冷却", t)
        if not u:hasdata("隐藏职业-天谴之子揭露") then
          u:setdata("隐藏职业-天谴之子揭露")
          hideproshow(u.handle)
        end
        u:curehp(u.handle, 0, 50, 4)
        u:sendmessage("|cFF949596天谴之子-免疫即死|r")
      end
      if u:hasdata("变异判定-百百") and not u:hasdata("百百-免疫即死冷却") then
        b2 = false
        if u:hasdata("真红次元闭锁超即死") then
          if not u:hasdata("真红世界锁间隔") then
            u:settimedata("真红世界锁间隔", 1)
            if u:hasdata("真红-世界锁") then
              u:changedata("真红-世界锁", 0.85, 1)
            else
              u:setdata("真红-世界锁", 0.85)
            end
            u:changemaxhp(-0.2 * u:getmaxhp())
          end
          u:deldata("真红次元闭锁超即死")
        end
        local t = 360
        u:settimedata("百百-免疫即死冷却", t)
        u:sendmessage("|cFF949596百百-死神之力|r")
      end
      if u:hasdata("变异判定-特莉波卡") and not u:hasdata("特莉波卡-免疫即死冷却") then
        b2 = false
        if u:hasdata("真红次元闭锁超即死") then
          if not u:hasdata("真红世界锁间隔") then
            u:settimedata("真红世界锁间隔", 1)
            if u:hasdata("真红-世界锁") then
              u:changedata("真红-世界锁", 0.85, 1)
            else
              u:setdata("真红-世界锁", 0.85)
            end
            u:changemaxhp(-0.2 * u:getmaxhp())
          end
          u:deldata("真红次元闭锁超即死")
        end
        local t = 120
        u:settimedata("特莉波卡-免疫即死冷却", t)
        u:sendmessage("|cFFCC0000特|r|cFFD11414莉|r|cFFD62929波|r|cFFDB3D3D卡|r|cFFE05252-|r|cFFE56666冥|r|cFFEB7A7A狩|r|cFFF08F8F死|r|cFFF5A3A3神|r")
      end
      if u:hasdata("变异判定-歼灭天使") and soc:isingroup(Group_PlayHero) then
        b2 = false
      end
      if b2 then
        if boolean then
          u:setdata("超即死")
        end
        u:sethp(-1)
        u:deldata("超即死")
      end
    else
      if boolean then
        u:banrelive()
      end
      u:sethp(-1)
      ac.wait(30, function()
        if not u:isalive() then
          if soc:hasdata("断头台即死奖励") then
            soc:changemaxhp(soc:getdata("断头台即死奖励"))
          end
          if soc:hasdata("变异判定-百百") then
            soc:curehp(soc.handle, 0, 1, 5)
          end
        end
      end)
    end
  else
    u:sethp(-1)
  end
end

function unit:addrandomstats(value)
  local b = false
  if value < 0 then
    b = true
    value = value * -1
  end
  local rd1 = GetRandomInt(0, value)
  local rd2 = GetRandomInt(0, value)
  if rd1 > rd2 then
    rd1, rd2 = rd2, rd1
  end
  local var1 = rd1
  local var2 = rd2 - rd1
  local var3 = value - rd2
  if b then
    var1 = var1 * -1
    var2 = var2 * -1
    var3 = var3 * -1
  end
  self:addstats(var1, var2, var3)
end

ShockCameraBoolean = true

function unit:shockcamera(value, time)
  if ShockCameraBoolean then
    time = time or 0
    local richter = value
    if 5.0 < richter then
      richter = 5.0
    end
    if richter < 2.0 then
      richter = 2.0
    end
    if self:islocal() then
      CameraSetTargetNoiseEx(value * 2.0, value * Pow(10, richter), true)
      CameraSetSourceNoiseEx(value * 2.0, value * Pow(10, richter), true)
    end
    if time ~= 0 then
      ac.wait(time * 1000, function()
        if self:islocal() then
          CameraSetTargetNoiseEx(0, 0, true)
          CameraSetSourceNoiseEx(0, 0, true)
        end
      end)
    end
  end
end

function unit:shockcamerastop()
  CameraClearNoiseForPlayer(self.owner)
end

function unit:setcamera(x, y, time)
  local p = getplayer(self.owner)
  p:setcamera(x, y, time)
end

function unit:banskill(skill, boolean)
  if boolean ~= nil then
    boolean = not boolean
  else
    boolean = false
  end
  if skill == 0 then
    return
  end
  if type(skill) == "string" then
    skill = S2ID(skill)
  end
  SetPlayerAbilityAvailable(self.owner, skill, boolean)
end

function unit:useweapon()
  local u = self
  local sy = u.ownerid
  if Hero_Equip_WeaponBoolean[sy] then
    local wptype = Hero_Equip_WeaponType[sy]
    local skill = GetData(wptype, "绑定技能")
    u:setskillcd(skill, 0)
    ac.wait(15, function()
      IssueNeutralImmediateOrderById(u.owner, u.handle, 852149)
    end)
  end
end

local bufftype = {
  {name = "冰冻"},
  {name = "缠绕"},
  {name = "沉默"},
  {name = "混乱"},
  {name = "僵直"},
  {name = "麻痹"},
  {name = "燃烧"},
  {name = "石化"},
  {name = "睡眠"},
  {name = "眩晕"},
  {name = "无敌"},
  {name = "暂停"},
  {
    name = "绝对闪避"
  }
}

function unit:clearbuff(buff)
  if not buff then
    UnitRemoveBuffs(self.handle, false, true)
  elseif buff == "all" then
    UnitRemoveBuffs(self.handle, true, true)
  elseif type(buff) == "number" then
    UnitRemoveAbility(self.handle, buff)
  elseif string.match(buff, "^%w%w%w%w$") then
    buff = S2ID(buff)
    UnitRemoveAbility(self.handle, buff)
  else
    for _, value in ipairs(bufftype) do
      if value.name == buff then
        if self:getdata(buff .. "时间") > 0 then
          self:setdata(buff .. "时间", 0.01)
          if buff == "无敌" then
            SetUnitInvulnerable(self.handle, false)
          end
        end
        if buff == "无敌" and 0 < self:getdata("伪无敌" .. "时间") then
          self:setdata("伪无敌" .. "时间", 0.01)
        end
      end
    end
  end
end

function unit:createfogcorrector(x, y, size)
  local xzq = CreateFogModifierRadius(self.owner, FOG_OF_WAR_VISIBLE, x, y, size, false, false)
  FogModifierStart(xzq)
  handle_ref.ref(xzq)
  return xzq
end

function unit:createrectfogcorrector(rect)
  local cor = CreateFogModifierRect(self.owner, FOG_OF_WAR_VISIBLE, rect, false, false)
  FogModifierStart(cor)
  handle_ref.ref(cor)
  return cor
end

function unit:removefogcorrector(corrector)
  handle_ref.unref(corrector)
  DestroyFogModifier(corrector)
end

function unit:openfogcorrector(corrector)
  FogModifierStart(corrector)
end

function unit:closefogcorrector(corrector)
  FogModifierStop(corrector)
end

function unit:addtrgevent(text, func)
  if not self.trigger then
    self.trigger = {}
  end
  if text == "玩家-聊天" then
    local p = getplayer(self.owner)
    p:addtrgevent(text, func)
    return
  end
  if text == "玩家-选择单位" or text == "玩家-取消选择单位" then
    local player = require("jh.ac.player")
    for i = 1, 6 do
      player[i]:addtrgevent(text, func)
    end
    return
  end
  if text == "单位-获取物品" then
    text = "单位-获得物品"
  end
  if not self.trigger[text] then
    self.trigger[text] = {}
  end
  table.insert(self.trigger[text], func)
end

function unit:registertrgevent(text)
  if not self.registeredEvents then
    self.registeredEvents = {}
  end
  if not self.registeredEvents[text] then
    if text == "单位-使用物品" then
      TriggerRegisterUnitEvent(Trg_ItemUse, self.handle, EVENT_UNIT_USE_ITEM)
    elseif text == "单位-发动技能" then
      TriggerRegisterUnitEvent(Trg_UnitSkill, self.handle, EVENT_UNIT_SPELL_EFFECT)
    elseif text == "单位-获得物品" then
      TriggerRegisterUnitEvent(Trg_ItemGet, self.handle, EVENT_UNIT_PICKUP_ITEM)
    elseif text == "单位-丢弃物品" then
      TriggerRegisterUnitEvent(Trg_ITEM_DROP, self.handle, EVENT_UNIT_DROP_ITEM)
    elseif text == "单位-指定点目标指令" then
      TriggerRegisterUnitEvent(Trg_UNIT_ISSUED_POINT_ORDER, self.handle, EVENT_UNIT_ISSUED_POINT_ORDER)
    elseif text == "单位-指定物体指令" then
      TriggerRegisterUnitEvent(Trg_UNIT_ISSUED_TARGET_ORDER, self.handle, EVENT_UNIT_ISSUED_TARGET_ORDER)
    elseif text == "单位-攻击" then
      TriggerRegisterUnitEvent(Trg_UNIT_ATTACKED, self.handle, EVENT_UNIT_ATTACKED)
    elseif text == "单位-开始研究科技" then
      TriggerRegisterUnitEvent(Trg_UNIT_RESEARCH_START, self.handle, EVENT_UNIT_RESEARCH_START)
    elseif text == "单位-完成研究科技" then
      TriggerRegisterUnitEvent(Trg_UNIT_RESEARCH_FINISH, self.handle, EVENT_UNIT_RESEARCH_FINISH)
    elseif text == "单位-被取消选择" then
      TriggerRegisterUnitEvent(Trg_EVENT_UNIT_DESELECTED, self.handle, EVENT_UNIT_DESELECTED)
    elseif text == "单位-被选择" then
      TriggerRegisterUnitEvent(Trg_EVENT_UNIT_SELECTED, self.handle, EVENT_UNIT_SELECTED)
    end
    self.registeredEvents[text] = true
  else
    print("单位已经注册了事件：" .. text)
  end
end

function unit:triggeraddevent(trg, event)
  TriggerRegisterUnitEvent(trg, self.handle, event)
end

function unit:triggeraddplayerevent(trg, text, boolean)
  TriggerRegisterPlayerChatEvent(trg, self.owner, text, boolean or true)
end

function unit:trgrun(trg)
end

function unit:getcountitem(count)
  return UnitItemInSlot(self.handle, count - 1)
end

function unit:useitem(item)
  UnitUseItem(self.handle, item)
end

function unit:setskillforever(skill)
  UnitMakeAbilityPermanent(self.handle, true, S2ID(skill))
end

function unit:setcolor(r, g, b, aplha)
  SetUnitVertexColor(self.handle, r, g, b, aplha or 255)
end

function unit:setxy(x, y, move_context)
  local trace = package.loaded["hera_move_trace"]
  local previous_context = trace and trace.context
  if move_context then
    trace.context = move_context
    trace.step(move_context, "SETXY_BEGIN", "target_x=" .. tostring(x) .. " target_y=" .. tostring(y))
  end
  SetUnitX(self.handle, x or 0)
  if move_context then trace.step(move_context, "SETX_END", "") end
  SetUnitY(self.handle, y or 0)
  if move_context then trace.step(move_context, "SETY_END", "") end
  if self["脚本位移后效果"] and 0 < #self["脚本位移后效果"] then
    StexiaoFunc({
      text = "脚本位移后效果",
      u = self
    })
  end
  if move_context then
    trace.step(move_context, "SETXY_END", "")
    trace.context = previous_context
  end
end

function unit:setmapxy(x, y)
  self:setdata("系统-穿越地图标记")
  SetUnitX(self.handle, x or 0)
  SetUnitY(self.handle, y or 0)
  if self["脚本位移后效果"] and 0 < #self["脚本位移后效果"] then
    StexiaoFunc({
      text = "脚本位移后效果",
      u = self
    })
  end
  self:setdata("位移点X", x)
  self:setdata("位移点Y", y)
  ac.wait(100, function()
    self:deldata("系统-穿越地图标记")
    local p = getplayer(self.owner)
    local rectz = {
      RECT_Xingxing1,
      RECT_Xingxing2,
      RECT_Xingxing3,
      RECT_Kongjianzhan
    }
    for _, rect in ipairs(rectz) do
      if IsXYinRect(x, y, rect) then
        local sy = self.ownerid
        MoveRectTo(System_PlayerQuyu[sy], x, y)
        p:cameralimit(System_PlayerQuyu[sy])
        self:setdata("当前镜头区域", System_PlayerQuyu[sy])
        self:setdata("当前镜头区域X", x)
        self:setdata("当前镜头区域Y", y)
        RECT_PlayerNowArea[sy] = rect
        self:setcamera(x, y)
        return
      end
    end
    p:cameralimit(RECT_PlayArea)
    self:setcamera(x, y)
    RECT_PlayerNowArea[self.ownerid] = RECT_PlayArea
  end)
end

function unit:setface(face)
  SetUnitFacing(self.handle, face)
  japi.EXSetUnitFacing(self.handle, face)
end

function unit:getface()
  return GetUnitFacing(self.handle)
end

function unit:adddivinity(value)
  HeroMenu_Shenxing[self.ownerid] = HeroMenu_Shenxing[self.ownerid] + value
end

function unit:addgold(gold)
  if 0 < gold then
    if Keyan_Ziyuankujie then
      gold = gold * 0.5
    end
    if self:hasdata("系统-信用卡判定") then
      gold = 0
    end
  end
  SetPlayerState(self.owner, PLAYER_STATE_GOLD_GATHERED, GetPlayerState(self.owner, PLAYER_STATE_GOLD_GATHERED) + gold)
  SetPlayerState(self.owner, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(self.owner, PLAYER_STATE_RESOURCE_GOLD) + gold)
end

function unit:setgold(gold)
  SetPlayerState(self.owner, PLAYER_STATE_GOLD_GATHERED, gold)
  SetPlayerState(self.owner, PLAYER_STATE_RESOURCE_GOLD, gold)
end

function unit:changhuanqiankuan()
  local u = self
  if u:getdata("系统-贷款") > 0 then
    local gold = u:getgold()
    local dk = u:getdata("系统-贷款")
    local ch = dk
    if gold >= dk then
      ch = dk
    else
      ch = gold
    end
    u:addgold(-ch)
    u:changedata("系统-贷款", -ch)
    u:sendmessage(("|cFF7DBEF1[系统]贷款偿还%d积分,还剩余%d积分未偿还|r"):format(ch, u:getdata("系统-贷款")))
  end
end

function unit:addqiankuan(add)
  if self:getdata("系统-贷款") > 0 then
    self:changhuanqiankuan()
  end
  if self:getdata("系统-贷款") > 0 then
    return false
  end
  if add <= self:getgold() then
    self:addgold(-add)
  else
    self:sendmessage(("|cFFCC0000[系统]贷款增加了%d|r"):format(add))
    self:changedata("系统-贷款", add)
  end
  return true
end

function unit:addwood(wood)
  if 0 < wood and Keyan_Ziyuankujie then
    wood = wood * 0.5
  end
  self:changedata("系统-追忆值", wood)
  SetPlayerState(self.owner, PLAYER_STATE_RESOURCE_LUMBER, self:getdata("系统-追忆值"))
end

function unit:setwood(wood)
  SetPlayerState(self.owner, PLAYER_STATE_RESOURCE_LUMBER, self:getdata("系统-追忆值"))
  self:setdata("系统-追忆值", wood)
end

function unit:getwood()
  return self:getdata("系统-追忆值")
end

function unit:setusedfodd(food)
  SetPlayerState(self.owner, PLAYER_STATE_RESOURCE_FOOD_USED, food)
end

function unit:addlevel(level)
  if level ~= 0 then
    self:setlevel(self:getlevel() + level)
  end
end

function unit:animespeed(speed)
  SetUnitTimeScale(self.handle, speed)
  self:setdata("动画速度", speed)
end

function unit:animeact(string)
  if type(string) == "string" then
    SetUnitAnimation(self.handle, string)
  else
    SetUnitAnimationByIndex(self.handle, string)
  end
  self:setdata("播放动作", string)
end

function unit:reanimeact()
  ResetUnitAnimation(self.handle)
end

function unit:setlevel(level)
  local originlevel = self:getlevel()
  if level ~= originlevel then
    if level > originlevel then
      for _ = 1, level - originlevel do
        SetHeroLevel(self.handle, self:getlevel() + 1, true)
      end
    else
      level = originlevel - level
      UnitStripHeroLevel(self.handle, level)
    end
  end
end

function unit:additem(item, count)
  if type(item) == "string" then
    item = S2ID(item)
  end
  local x, y = self:getxy()
  local wp = CreateItemLua(item, x, y)
  if count and 0 <= count then
    SetItemCharges(wp, count)
  end
  UnitAddItem(self.handle, wp)
  return wp
end

function unit:setguard(matser, area)
  area = area or 2000
  local u = getunit(matser)
  local mj = self
  ac.loop(4000, function(timer)
    local x, y = u:getxy()
    local x2, y2 = mj:getxy()
    local dis = DistanceXY(x, y, x2, y2)
    if dis >= area + 1000 then
      mj:setxy(x, y)
      IssueImmediateOrder(mj.handle, "stop")
    else
      local dx, dy = PolarXY(x, y, GetRandomReal(0, area), GetRandomReal(0, 360))
      local dx2, dy2 = PolarXY(x, y, GetRandomReal(0, area), GetRandomReal(0, 360))
      IssuePointOrder(mj.handle, "attack", dx, dy)
      ac.wait(2000, function()
        IssuePointOrder(mj.handle, "patrol", dx2, dy2)
      end)
    end
    if GetUnitTypeId(mj.handle) == 0 then
      timer:remove()
    end
  end)
end

function unit:setanimerate(rate)
  SetUnitTimeScale(self.handle, rate)
end

function unit:isinrect(rect)
  local x, y = self:getxy()
  return x >= GetRectMinX(rect) and x <= GetRectMaxX(rect) and y >= GetRectMinY(rect) and y <= GetRectMaxY(rect)
end

function unit:setmaxhp(hp)
  local change = hp - self:getdata("生命上限")
  if (self:gethp() > 0 or self:getdata("生命上限") == 0) and not self:hasdata("系统-刷新生命上限中") then
    self:changedata("生命值", change)
  end
  self:setdata("生命上限", hp)
  self:flashhp()
end

function unit:addrandomdamage(value)
  ChangeValue(DamageSystem_Shjc, self.ownerid, 0.1 * (0.01 * value))
end

function unit:addspeitem(item)
  local x, y = self:getxy()
  SetItemPosition(item, x, y)
  UnitAddItem(self.handle, item)
end

function unit:removecountitem(count)
  RemoveItemLua(self:getcountitem(count))
end

function unit:isnormal()
  if self:hasdata("系统-BOSS") or self:hasdata("系统-精英") then
    return false
  else
    return true
  end
end

function unit:isboss()
  if self:hasdata("系统-BOSS") then
    return true
  else
    return false
  end
end

function unit:iselite()
  if self:hasdata("系统-精英") and not self:hasdata("系统-BOSS") then
    return true
  else
    return false
  end
end

function unit:changeowner(player)
  local owner = player
  SetUnitOwner(self.handle, player, true)
  player = getplayer(player)
  if not player then
    if type(owner) == "userdata" then
      self.owner = owner
      self.ownerid = GetPlayerId(owner) + 1
      return
    end
    return
  end
  self.owner = player.handle
  self.ownerid = player.id
end

-- 제거, 래퍼 교체, 풀 반환 이후의 유닛 접근을 차단한다.
function unit:isvalid(epoch)
  if not self.handle_generation or unit.allunits[self.handle] ~= self
      or not handle_ref.is_alive(self.handle, self.handle_generation)
      or self.pool_idle or (epoch ~= nil and (self.armor_pool_epoch or 0) ~= epoch) then
    return false
  end
  return GetUnitTypeId(self.handle) ~= 0
end

function unit:getarmor()
  if not self:isvalid() then return 0 end
  return GetUnitState(self.handle, ConvertUnitState(32))
end

function unit:allowfly()
  if not self:hasdata("允许飞行") then
    self:setdata("允许飞行")
    UnitAddAbility(self.handle, S2ID("Amrf"))
    UnitRemoveAbility(self.handle, S2ID("Amrf"))
  end
end

function unit:setflyheight(height, heightspeed)
  if not self:hasdata("允许飞行") then
    self:allowfly()
  end
  heightspeed = heightspeed or 0
  SetUnitFlyHeight(self.handle, height, heightspeed)
end

function unit:banmoveskill()
  local skill = {}
  skill[1] = "A055"
  skill[2] = "A056"
  skill[3] = "A0RL"
  skill[4] = "A0X8"
  skill[5] = "A0S8"
  skill[6] = "A02G"
  skill[7] = "A002"
  skill[8] = "A01R"
  skill[9] = "A03M"
  skill[10] = "A0IX"
  skill[11] = "A0IY"
  skill[12] = "A070"
  skill[13] = "A06Z"
  skill[14] = "A0X0"
  skill[15] = "A0X1"
  skill[16] = "A0WE"
  skill[17] = "A0WF"
  skill[18] = "A0UM"
  skill[19] = "A0UN"
  skill[20] = "A04R"
  skill[21] = "A04Y"
  skill[22] = "A0RR"
  skill[23] = "A0RS"
  skill[24] = "A14I"
  skill[25] = "A14H"
  skill[26] = "A14T"
  skill[27] = "A052"
  skill[28] = "A0CH"
  skill[29] = "A0CI"
  skill[30] = "A0RL"
  skill[31] = "A0X8"
  skill[32] = "A0S8"
  skill[33] = "A0VI"
  skill[34] = "A0UL"
  skill[35] = "A13A"
  skill[36] = "A17R"
  skill[37] = "A1BS"
  skill[38] = "A1BT"
  skill[39] = "A0C9"
  skill[40] = "A0C8"
  for i = 1, #skill do
    self:banskill(skill[i])
  end
end

function unit:banweaponskill(boolean)
  if boolean ~= nil then
  else
    boolean = false
  end
  for i = 1, #AllWeaponskill do
    self:banskill(AllWeaponskill[i], not boolean)
  end
end

function unit:setskilldatastring(skill, typeid, string)
  if typeid == "提示" then
    typeid = 215
  end
  if typeid == "提示拓展" or typeid == "提示-拓展" then
    typeid = 218
  end
  if typeid == "图标" then
    typeid = 204
  end
  if typeid ~= 215 and typeid ~= 218 and typeid ~= 204 then
    return
  end
  if type(skill) == "string" then
    skill = S2ID(skill)
  end
  string = string:gsub("^%s*", "", 1)
  japi.EXSetAbilityString(skill, 1, typeid, string)
end

function unit:setskilldatareal(skill, typeid, value)
  if type(skill) == "string" then
    skill = S2ID(skill)
  end
  if typeid == "施法间隔" then
    typeid = 105
  end
  if typeid == "持续时间(英雄)" then
    typeid = 103
  end
  if typeid ~= 105 and typeid ~= 104 and typeid ~= 103 and typeid ~= 108 and typeid ~= 109 then
    return
  end
  if type(skill) == "string" then
    skill = S2ID(skill)
  end
  local str = "real"
  if typeid == 104 then
    str = "integer"
  end
  if str == "real" then
    japi.EXSetAbilityDataReal(japi.EXGetUnitAbility(self.handle, skill), 1, typeid, value)
  end
  if str == "integer" then
    japi.EXSetAbilityDataInteger(japi.EXGetUnitAbility(self.handle, skill), 1, typeid, value)
  end
end

function unit:dropitem(item)
  UnitRemoveItem(self.handle, item)
  return item
end

function unit:removeitem(item)
  if type(item) == "string" then
    item = self:getitem(item)
  end
  UnitRemoveItem(self.handle, item)
  RemoveItemLua(item)
end

function unit:getname()
  if self:hasdata("模型-名字") then
    return self:getdata("模型-名字")
  end
  return GetUnitName(self.handle)
end

function unit:isexist()
  if self:isingroup(Group_Xingcunzu) or self:ishasskill("A0HS") or self:hasdata("变异判定-信长残魂") or self:hasdata("变异判定-秋静叶") then
    return true
  else
    return false
  end
end

function unit:ishasshw()
  if Hero_Shenhua_Left[self.ownerid] > 0 then
    return true
  else
    return false
  end
end

function unit:isbeseenlocal()
  return IsUnitVisible(self.handle, LocalPlayer)
end

function unit:isbeseen(target)
  local tg = getunit(target)
  return IsUnitVisible(self.handle, tg.owner)
end

function unit:playseensound(snd, sndsize)
  if snd == 0 then
    print("尝试播放不存在可见音效")
    printCallStack()
    return
  end
  sndsize = sndsize or 127
  PlaySoundByUnitVisible(self, snd, sndsize)
end

function unit:playselfsound(snd)
  if snd == 0 then
    print("尝试播放不存在的本地玩家音效")
    printCallStack()
    return
  end
  if self:islocal() then
    PlaySoundByPath(snd, 127)
  end
end

function unit:getgold()
  return GetPlayerState(self.owner, PLAYER_STATE_RESOURCE_GOLD)
end

function unit:setskillcd(skill, cd, diagnostic_context)
  if type(skill) == "string" then
    skill = S2ID(skill)
  end
  local diagnostic
  if diagnostic_context then
    diagnostic = require("hera_gameplay_diagnostic")
    diagnostic.monster("QW_COOLDOWN_SCHEDULE", {unit=self.handle, skill=skill, key=diagnostic_context.key, cd=cd, due=ac.clock()+1})
  end
  ac.wait(1, function()
    if diagnostic then diagnostic.monster("QW_COOLDOWN_APPLY_BEGIN", {unit=self.handle, skill=skill, cd=cd}) end
    japi.EXSetAbilityState(japi.EXGetUnitAbility(self.handle, skill), 1, cd)
    if diagnostic then diagnostic.monster("QW_COOLDOWN_APPLY_END", {unit=self.handle, skill=skill, cd=cd}) end
  end)
end

function unit:getskillcd(skill)
  if type(skill) == "string" then
    skill = S2ID(skill)
  end
  local cd = 0
  cd = japi.EXGetAbilityState(japi.EXGetUnitAbility(self.handle, skill), 1)
  return cd
end

function unit:reduceshw(count)
  local sy = self.ownerid
  count = count or 1
  Hero_Shenhua_Left[sy] = Hero_Shenhua_Left[sy] - 1
  Hero_Shenhua_Now[sy] = Hero_Shenhua_Now[sy] + 1
end

function unit:changekyx(value)
  self:changedata("抗药性", value)
  if self:getdata("抗药性") < 0 then
    self:setdata("抗药性", 0)
  end
  if self:getdata("抗药性") >= 100 then
    self:setdata("抗药性", 100)
  end
end

function unit:changeysnd(value)
  local u = self
  if u:hasdata("变异判定-霜星") and u:getdata("战斗时间") > 0 then
    value = value * 2
  end
  self:changedata("系统-血液源石结晶密度", value)
  if 0 > self:getdata("系统-血液源石结晶密度") then
    self:setdata("系统-血液源石结晶密度", 0)
  end
  if 0 < self:getdata("系统-血液源石结晶密度") then
    if not self:hasdata("变异判定-矿石病") then
      local sy = u.ownerid
      self:setdata("变异判定-矿石病")
      local fs = 0
      ac.loop(1000, function(timer)
        local nd = u:getdata("系统-血液源石结晶密度")
        ChangeValue(Correction_Magic, sy, -1 * fs)
        fs = nd * 5.0E-5 * Correction_Magic[sy]
        local yz = nd * 0.001
        local sh = nd * 0.001
        if 1 <= yz then
          yz = 1
        end
        if u:hasdata("变异判定-海嗣化") then
          yz = yz * 0.25
          sh = sh * 0.25
          fs = fs * 0.25
        end
        if u:hasdata("变异判定-爱国者") then
          sh = sh * 2
          fs = fs * 2
        end
        ChangeValue(Correction_Magic, sy, 1 * fs)
        yz = 1 - yz
        u:setdata("矿石病-抑制生命恢复", yz)
        u:changedata("效果增强-源石", -1 * u:getdata("矿石病-源石伤害提升"))
        u:setdata("矿石病-源石伤害提升", sh)
        u:changedata("效果增强-源石", 1 * u:getdata("矿石病-源石伤害提升"))
        if u:isalive() and not u:hasdata("霜星-彩蛋触发") and not u:hasdata("变异判定-海嗣化") and 100 <= nd then
          local gl = 1 + nd * 1.0E-5
          if u:hasdata("源石冰晶-持有") then
            gl = gl * 0.5
          end
          if GetRandom100(gl) then
            local dehp = 0.1 * u:getmaxhp() + GetRandomReal(0.1, 0.5) * u:gethp()
            u:sendmessage("|cFFFF9900矿石病症状迸发了！|r")
            if u:hasdata("变异判定-爱国者") and not u:hasdata("爱国者-彩蛋触发") and 1 >= Group_Counts(Group_Xingcunzu) and BossBattle then
              u:setdata("爱国者-彩蛋触发")
              MovieAct["爱国者"](u)
              return
            end
            u:changedata("矿石病爆发次数", 1)
            u:effectadd("Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl")
            if not u:hasdata("变异判定-博士") then
              u:buffset(u.handle, 0.5, "眩晕")
              if u:hasdata("变异判定-霜星") and dehp >= 0.8 * u:gethp() then
                dehp = 0.8 * u:gethp()
              end
              if 300 <= nd then
                if dehp >= u:gethp() then
                  u:losshp(u, dehp)
                  u:setdata("矿石病-致死")
                  u:kill()
                  u:deldata("矿石病-致死")
                else
                  u:losshp(u, dehp)
                end
              else
                u:losshp(u, dehp)
              end
            end
          end
        end
        if not u:hasdata("变异判定-海嗣化") and not u:hasdata("霜星-彩蛋触发") then
          if 800 <= nd and not u:hasdata("变异判定-博士") then
            if u:isalive() then
              local gl = 0.15
              if u:hasdata("源石冰晶-持有") then
                gl = gl * 0.5
              end
              if GetRandom100(gl) then
                if u:hasdata("变异判定-爱国者") and not u:hasdata("爱国者-彩蛋触发") and 1 >= Group_Counts(Group_Xingcunzu) and BossBattle then
                  u:setdata("爱国者-彩蛋触发")
                  MovieAct["爱国者"](u)
                  return
                end
                u:changedata("矿石病爆发次数", 1)
                u:sendmessage("|cFFFF9900矿石病彻底爆发了！|r")
                u:effectadd("Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl")
                if Boolean_Amiya_Shenhua and not u:hasdata("阿米娅-内化宇宙冷却") then
                  if u:hasdata("神化判定-阿米娅") then
                    u:settimedata("阿米娅-内化宇宙冷却", 15)
                  else
                    u:settimedata("阿米娅-内化宇宙冷却", 90)
                  end
                  u:sendmessage("|cFFCCCCCC阿|r|cFFBBBBBB米|r|cFFAAAAAA娅|r|cFF999999-|r|cFF888888内|r|cFF777777化|r|cFF666666宇|r|cFF555555宙|r")
                else
                  u:setdata("矿石病-致死")
                  u:kill()
                  u:deldata("矿石病-致死")
                end
              end
            end
          else
            local add = 0.01 + nd * 1.0E-4
            if u:hasdata("爱国者-感染者之盾") then
              add = add * 0.75
            end
            if u:hasdata("霜星-雪中至亲") and not u:hasdata("变异判定-霜星") then
              add = add * 0.75
            end
            if u:hasdata("环境-海风") then
              add = add * 0.5
            end
            u:changeysnd(add)
          end
        end
      end)
    end
    if not self:hasdata("矿石病-显示") then
      local nd = u:getdata("系统-血液源石结晶密度")
      if 100 <= nd then
        self:setdata("矿石病-显示")
        u:uivar_add({
          keyname = "矿石病",
          keytype = "疾病栏",
          text = "|cFF666666矿石病|r\n|cFF666666受血液源石结晶密度影响效果\n法术修正提升[每1u/ml提升0.05%](独立)\n生命恢复效果[每1u/ml降低0.1%]\n以[源石]为媒介的属性或伤害[每1u/ml提升0.1%]\n每秒有概率损耗[10%最大生命值+10%~50%当前生命值](矿石病严重阶段以上时致死)并短暂眩晕|r\n|cFF949596由活性源石感染造成的不治之症|r",
          icon = "Ewl_New_Kuangshibing"
        })
      end
    end
  end
end

function unit:changexueroutonghua(value)
  local u = self
  self:changedata("系统-血肉同化度", value)
  if self:getdata("系统-血肉同化度") < 0 then
    self:setdata("系统-血肉同化度", 0)
  end
  if self:getdata("系统-血肉同化度") > 0 and not self:hasdata("变异判定-海嗣化") then
    local sy = u.ownerid
    self:setdata("变异判定-海嗣化")
    local hp = 0
    local xgzq = 0
    ac.loop(1000, function(timer)
      u:changedata("效果增强-水", -xgzq)
      local nd = u:getdata("系统-血肉同化度")
      local add = GetRandomReal(0.01, 0.05)
      if u:hasdata("阿比盖尔-虚伪之海") then
        add = add * 2
      end
      u:changexueroutonghua(add)
      xgzq = 0.005 * nd
      u:setdata("海嗣化-生命恢复效果强化", nd * 0.01)
      ChangeValue(HeroMenu_HpForever_MaxHp, sy, -1 * hp)
      hp = nd * 0.01
      ChangeValue(HeroMenu_HpForever_MaxHp, sy, 1 * hp)
      u:changedata("效果增强-水", xgzq)
      if 100 <= nd then
        u:changedata("效果增强-水", -xgzq)
        u:setdata("变异判定-海嗣同化完毕")
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, -1 * hp)
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, 1)
        u:setdata("效果增强-机械", -1)
        ac.loop(3000, function()
          u:changedata("效果增强-水", -xgzq)
          u:changedata("效果增强-水", xgzq)
        end)
        u:setdata("海嗣化-生命恢复效果强化", 1)
        u:changedata("机械变异补正", -1000)
        if u:islocal() then
          u:sendmessage("|cFF339999彻底海嗣化……|r")
          u:uivar_change({
            keyname = "海嗣化",
            keytype = "疾病栏",
            text = "|cFF26BDBC海|r|cFF8CABB5嗣|r\n|cFF1EA5A6免疫矿石病\n免疫[海风]负面效果\n血液源石结晶密度不会自然增长|r\n|cFF43A6AA提升75%水变异效果\n提升1%永恒恢复|r\n|cFF4FA6AB提升100%生命恢复效果\n降低100%机械变异效果|r\n|cFF5BA6AC降低1000%机械变异补正|r\n|cFF80A6AF处于虚伪之海时额外提升50%水变异效果|r\n|cFF8CA7B1处于水域中时生命恢复恒为永恒恢复|r\n|cFF949596嘘，倾听……茫茫万物之主的教诲……|r",
            icon = "Ewl_New_Haisi"
          })
        end
        timer:remove()
      end
    end)
    u:uivar_add({
      keyname = "海嗣化",
      keytype = "疾病栏",
      text = "|cFF6BB5C1海嗣化|r\n|cFF6BB5C1矿石病效果降低75%,病状不会爆发或致死\n[海风]负面效果降低[100%*同化度]\n血液源石结晶密度不再自然增长\n[阿戈尔之赞]不提升血液源石结晶密度,提升[1~10%]同化度与1~100点属性\n[血肉同化]:\n逐渐血肉同化拥抱进化\n被注视时不会有负面效果,提升10%同化度\n提升[50%*同化度]水变异效果\n提升[1%*同化度]永恒恢复\n提升[100%*同化度]生命恢复效果|r",
      icon = "Ewl_New_Haisihua"
    })
  end
end

function unit:bzzfadian()
end

function unit:lossstamina(tili)
  local sy = self.ownerid
  local u = self
  if self:hasbuff("麻痹") and not u:hasdata("免疫-麻痹额外消耗体力") then
    tili = tili * 2
  end
  if self:hasdata("凤凰庭园-强化2") then
    tili = tili * 0.5
  end
  if u:hasdata("神器判定-异次元术士") then
    tili = tili * 2
  end
  if u:hasdata("神器判定-魔力锁") and 3 <= tili then
    tili = 3
  end
  if u:hasdata("神器判定-法力电池") and 3 <= tili then
    u:curetili(0.33 * tili)
  end
  if self:hasdata("变异判定-苍河龙女") then
    self:curehp(self.handle, 0, 3 * tili, 2)
  end
  if self:hasdata("志贵-BH状态") or self:hasdata("八重樱-红莲业火强化") or self:hasdata("两仪式-BH状态") then
    tili = 0
  end
  if u:hasdata("千束-子弹时间") then
    u:changedata("千束-子弹时间体力消耗", tili)
    tili = 0
  end
  if tili <= Hero_Tili[sy] then
    Hero_Tili[sy] = Hero_Tili[sy] - tili
    return true
  else
    if u:hasdata("花瓣-阿斯塔罗特") and not u:hasdata("阿斯塔罗特-体力恢复冷却") then
      u:settimedata("阿斯塔罗特-体力恢复冷却", 1200)
      Hero_Tili[sy] = Hero_Tili_Max[sy]
      Hero_Tili[sy] = Hero_Tili[sy] - tili
      u:sendmessage("|cFF020982阿斯塔罗特|r|cFF31208C - 无感动|r")
      return true
    end
    return false
  end
end

function unit:curetili(tili)
  local sy = self.ownerid
  local u = self
  if self:hasdata("千束-子弹时间") then
    self:changedata("千束-子弹时间体力消耗", tili)
    return
  end
  if 0 < tili then
    if Keyan_Jinglikujie then
      tili = tili * 0.5
    end
  else
    if self:hasbuff("麻痹") and not u:hasdata("免疫-麻痹额外消耗体力") then
      tili = tili * 2
    end
    if self:hasdata("凤凰庭园-强化2") then
      tili = tili * 0.5
    end
    if u:hasdata("神器判定-异次元术士") then
      tili = tili * 2
    end
  end
  if self:hasdata("神器判定-魔力锁") and tili <= -3 then
    tili = -3
  end
  if self:hasdata("神器判定-法力电池") and tili <= -3 then
    self:curetili(-0.33 * tili)
  end
  Hero_Tili[sy] = Hero_Tili[sy] + tili
  if Hero_Tili[sy] > Hero_Tili_Max[sy] then
    Hero_Tili[sy] = Hero_Tili_Max[sy]
  end
  if 0 >= Hero_Tili[sy] then
    Hero_Tili[sy] = 0
  end
end

function unit:delweaponskill()
  for i = 1, #AllWeaponskill do
    self:delskill(AllWeaponskill[i])
  end
end

function unit:beenemy()
  for i = 1, 6 do
    SetPlayerAllianceStateBJ(ConvertedPlayer(i), self.owner, bj_ALLIANCE_UNALLIED)
    SetPlayerAllianceStateBJ(self.owner, ConvertedPlayer(i), bj_ALLIANCE_UNALLIED)
  end
end

function unit:beunion()
  for i = 1, 6 do
    SetPlayerAllianceStateBJ(ConvertedPlayer(i), self.owner, bj_ALLIANCE_ALLIED)
    SetPlayerAllianceStateBJ(self.owner, ConvertedPlayer(i), bj_ALLIANCE_ALLIED)
  end
end

function unit:is_enemy(target)
  return IsUnitEnemy(target, self.owner)
end

function unit:addxp(xp)
  AddHeroXP(self.handle, xp, true)
end

function unit:addexp(exp)
  AddHeroXP(self.handle, exp, true)
end

function unit:shanmo(time, force)
  time = time or 0
  local u = self
  if not force and u:hasdata("神化判定-上条当麻") then
    u:sendmessage("|cff9e1414[上条当麻]基准点已复原")
    return
  end
  if not force and Danwei_Gzl ~= 0 and Danwei_Gzl ~= u.handle then
    MovieAct["代而亡逝之光"](getunit(Danwei_Gzl), u)
    return
  end
  u:buffset(u.handle, 3600, "暂停")
  u:buffset(u.handle, 3600, "无敌")
  SetUnitOwner(u.handle, Player(PLAYER_NEUTRAL_PASSIVE), true)
  u:setdata("系统-已删模")
  u:groupremove(Group_Xingcunzu)
  u:groupremove(Group_DeathHero)
  u:groupremove(Group_PlayHero)
  ac.wait(time * 1000, function()
    ForGroupLuaNew(Group_PlayHero, function(xq)
      if xq.handle ~= u.handle and xq:hasdata("变异判定-百百") then
        xq:setdata("百百-爱哭鬼判定")
      end
    end)
    ShowUnit(u.handle, false)
    u:addskill("Aloc")
    u:addskill("A00N")
    u:addskill("A0P2")
    u:setdata("系统-已删模")
    if u:hasdata("特典-春秋蝉") then
      local gl = u:getdata("春秋蝉-触发概率")
      if GetRandom100(gl) then
        ac.wait(1000, function()
          u:shanmorelive()
          MovieAct["春秋蝉"](u)
        end)
      end
      return
    end
    ac.loop(3000, function(timer)
      if u:isingroup(Group_PlayHero) then
        timer:remove()
      else
        ShowUnit(u.handle, false)
        u:deldata("系统-已删模")
        u:addskill("Aloc")
        u:addskill("A00N")
        u:addskill("A0P2")
        for i = 1, 6 do
          SetPlayerAllianceStateBJ(ConvertedPlayer(i), u.owner, bj_ALLIANCE_ALLIED_VISION)
        end
      end
    end)
  end)
end

function unit:shanmorelive()
  local tg = self
  local x, y = tg:getxy()
  tg:delskill("Aloc")
  tg:delskill("A00N")
  tg:delskill("A0P2")
  tg:deldata("系统-已删模")
  ShowUnit(tg.handle, false)
  tg:setxy(x, y)
  ShowUnit(tg.handle, true)
  tg:setxy(x, y)
  tg:groupadd(Group_PlayHero)
  tg:groupadd(Group_Xingcunzu)
  SetUnitOwner(tg.handle, tg.owner, true)
  tg:setcolor(255, 255, 255, 255)
  tg:buffset(tg.handle, 1, "无敌")
  tg:buffset(tg.handle, 1, "暂停")
  tg:setdata("暂停时间", 1)
  tg:setdata("无敌时间", 1)
  tg:clearbuff("暂停")
  tg:clearbuff("无敌")
end

local statestr = {
  "吸血鬼",
  "魅魔",
  "不死",
  "源石",
  "机械",
  "同奏",
  "外域",
  "光明",
  "黑暗",
  "恶魔",
  "歌姬",
  "战士",
  "自然",
  "念力",
  "魔导",
  "童话",
  "灵魂",
  "质点",
  "根源",
  "人形",
  "精灵",
  "东方",
  "德丽莎",
  "蛇",
  "水",
  "冰",
  "土",
  "龙",
  "兽",
  "星",
  "影",
  "炎",
  "风",
  "雷"
}
local state_lookup = {}
for _, name in ipairs(statestr) do
  local enhance_key = "效果增强-" .. name
  local is_dragon = name == "龙"
  state_lookup[name] = {enhance_key = enhance_key, is_dragon = is_dragon}
  state_lookup[name .. "变异"] = {
    enhance_key = enhance_key,
    count_key = name .. "变异数量",
    is_dragon = is_dragon
  }
end

function unit:getstate(key, perhp)
  if key == "累积杀敌" then
    return KillCumCount[self.ownerid] * (1 + 0.05 * self:getdata("原罪值"))
  end
  if key == "狂化值" then
    return self:getdata(key) * (1 + 0.1 * self:getdata("原罪值"))
  end
  if key == "背水" then
    perhp = perhp or self:getperhp()
    return (1 - perhp * 0.01) * (1 + self:getdata("效果增强-背水"))
  end
  if key == "浑身" then
    perhp = perhp or self:getperhp()
    return perhp * 0.01 * (1 + self:getdata("效果增强-浑身"))
  end
  local state = state_lookup[key]
  if not state then
    return nil
  end
  local jc = 1
  if self:hasdata("神器判定-索林原虫虫后") then
    jc = jc + 0.04 * self:getdata("心脏变异数量")
  end
  local data = jc + self:getdata(state.enhance_key) + self:getdata("效果增强-全词条")
  if state.count_key then
    data = self:getdata(state.count_key) * data
  end
  if state.is_dragon then
    data = data * self:getdragonbloodpower()
  end
  return data
end

local health_refresh_mt = {}
health_refresh_mt.__index = health_refresh_mt

function health_refresh_mt:setvalue(target, key, value)
  local target_values = self.values[target]
  if not target_values then
    target_values = {}
    self.values[target] = target_values
  end
  local old_value = target_values[key] or 0
  if value == old_value then
    return
  end
  local change = value - old_value
  if target == self.unit then
    self.unit:changedata(key, change)
  else
    ChangeValue(target, key, change)
  end
  target_values[key] = value
end

function health_refresh_mt:remove()
  if self.removed then
    return
  end
  for target, target_values in pairs(self.values) do
    for key, value in pairs(target_values) do
      if target == self.unit then
        self.unit:changedata(key, -value)
      else
        ChangeValue(target, key, -value)
      end
    end
  end
  self.values = {}
  self.removed = true
  UnitData.set(self.unit, "系统-生命派生刷新")
end

function unit:addhealthrefresh(callback)
  if not self.health_refresh_callbacks then
    self.health_refresh_callbacks = {}
  end
  local entry = setmetatable({
    callback = callback,
    unit = self,
    values = {}
  }, health_refresh_mt)
  
  function entry.set_value(target, key, value)
    entry:setvalue(target, key, value)
  end
  
  local callbacks = self.health_refresh_callbacks
  callbacks[#callbacks + 1] = entry
  local perhp = self:getperhp()
  callback(entry.set_value, self:getstate("背水", perhp), self:getstate("浑身", perhp))
  return entry
end

function unit:refreshhealthstate(perhp, backwater, hunshen)
  local callbacks = self.health_refresh_callbacks
  if not callbacks then
    return
  end
  backwater = backwater or self:getstate("背水", perhp)
  hunshen = hunshen or self:getstate("浑身", perhp)
  for index = #callbacks, 1, -1 do
    local entry = callbacks[index]
    if entry.removed then
      table.remove(callbacks, index)
    else
      entry.callback(entry.set_value, backwater, hunshen)
    end
  end
  if #callbacks == 0 then
    self.health_refresh_callbacks = nil
  end
end

function unit:zsdamage(source)
  local u = self
  source = source or BOSS_DEATH
  local soc = getunit(source)
  local b = false
  local yx = {}
  if soc:hasdata("两仪式") then
    b = true
    yx[#yx + 1] = Sound_214_41
    yx[#yx + 1] = Sound_214_42
  end
  if b then
    soc:playsound(yx[GetRandomInt(1, #yx)])
  end
  u:losshp(u, 0, 90)
  DamageUnit({
    bj = "斩杀判定",
    unit = u.handle,
    source = soc.handle,
    damage = u:getmaxhp(),
    level = 5,
    type = "灵力",
    isvest = true,
    isattack = false,
    isnoarmor = false,
    element = "无"
  })
end

function unit:ispozhao()
  local b = false
  local u = self
  if u:hasdata("BOSS-施法时间") or u:getdata("破防时间") > 0 or 0 < u:getdata("无极-技能释放中时间") or u:hasdata("无极-破气状态") or u:hasdata("史尔特尔-硬直破防中") or u:hasdata("只狼-破势判定") then
    b = true
  end
  return b
end

function unit:getluckrandom(gl, boolean)
  if boolean == nil then
    boolean = true
  end
  local rd = GetRandomReal(0, 100)
  local xs = 1 + self:getdata("幸运系数")
  if self:hasdata("超高校级的幸运-诅咒") then
    boolean = false
  end
  if boolean then
    gl = gl * (1 + 0.02 * self:getdata("幸运") * xs)
  else
    gl = gl * (1 - 0.02 * self:getdata("幸运") * xs)
  end
  if rd <= gl then
    return true
  else
    return false
  end
end

function unit:getgedangrandom(gl)
  local u = self
  local rd = GetRandomReal(0, 100)
  if u:hasdata("物品判定-双刃下弦月") then
    gl = gl + 20
  end
  if rd <= gl then
    return true
  else
    return false
  end
end

function unit:distancetotg(tg)
  DistanceBetweenUnits(self.handle, tg.handle)
end

function unit:getbloodcd(text)
  local u = self
  if u:getdata("总血统补正浓度") == 0 then
    return 0
  else
    return u:getdata(text .. "血统补正浓度") / u:getdata("总血统补正浓度")
  end
end

function unit:isinsecvar(text)
  local b = false
  b = TableContains(countainmaxvar(self).second, text)
  b = b or TableContains(countainmaxvar(self).var, text)
  return b
end

function unit:isinmaxvar(text)
  return TableContains(countainmaxvar(self).var, text)
end

function unit:returnmaxvar()
  return countainmaxvar(self).var[1]
end

function unit:isonlymaxvar(text)
  return countainmaxvar(self).only == text
end

function unit:hasbuff(buff)
  local b = false
  local u = self
  if u:getdata(buff .. "时间") > 0 then
    b = true
  elseif buff == "无敌" and 0 < u:getdata("伪无敌" .. "时间") then
    b = true
  end
  if u:hasdata("变异判定-G11") and buff == "睡眠" and 0 < u:getdata("战斗时间") then
    b = true
  end
  return b
end

return unit
