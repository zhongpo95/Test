-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local heroname = "千咲天赋"
local talentrun = {
  {
    name = "命定之弦",
    id = "R07M",
    level = 0,
    codeuse = 8,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
    end
  },
  {
    name = "循环劫章",
    id = "R07I",
    level = 0,
    codeuse = 8,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
      ChangeValue(Hero_Tili_Huifu, sy, 0.25)
      ChangeValue(Correction_Exp, sy, 0.2)
      u:addstexiao(self.name, "杀敌效果", function(args)
        ChangeValue(Correction_Jzsh, sy, 1.0E-4)
        u:changedata("近战机体-基础伤害提升", 10)
      end)
      u:addstexiao(self.name, "英雄升级时效果", function(args)
        u:addallstats(3)
      end)
    end
  },
  {
    name = "薛定谔的猫",
    id = "R07O",
    level = 0,
    codeuse = 4,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
      ac.loop(618, function()
        if u:isalive() and GetRandomInt(1, 137) == 1 then
          local sj = GetRandomInt(1, 6)
          if sj == 1 then
            u:addwood(12)
            u:sendmessage("|cFF992B30[薛定谔的猫]追忆值")
          end
          if sj == 2 then
            u:addgold(222)
            u:sendmessage("|cFF992B30[薛定谔的猫]积分")
          end
          if sj == 3 then
            u:addallstats(2)
            u:sendmessage("|cFF992B30[薛定谔的猫]全属性")
          end
          if sj == 4 then
            ChangeValue(DamageSystem_Shjc, sy, 0.00314)
            u:sendmessage("|cFF992B30[薛定谔的猫]伤害加成")
          end
          if sj == 5 then
            u:changedata("系统-启动承载上限", 1)
            u:sendmessage("|cFF992B30[薛定谔的猫]启动上限")
          end
          if sj == 6 then
            u:addlevel(1)
            u:sendmessage("|cFF992B30[薛定谔的猫]等级")
          end
        end
      end)
    end
  },
  {
    name = "空相引擎",
    id = "R07L",
    level = 0,
    codeuse = 3,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
    end
  },
  {
    name = "相位弦网",
    id = "R07R",
    level = 0,
    codeuse = 6,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
    end
  },
  {
    name = "零坠空间",
    id = "R07K",
    level = 0,
    codeuse = 6,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
    end
  },
  {
    name = "光锥天域",
    id = "R07P",
    level = 0,
    codeuse = 6,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
    end
  },
  {
    name = "第五象限",
    id = "R07N",
    level = 0,
    codeuse = 14,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
    end
  },
  {
    name = "虚夜环锯",
    id = "R07G",
    level = 0,
    codeuse = 8,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
    end
  },
  {
    name = "负界弦锯",
    id = "R07H",
    level = 0,
    codeuse = 8,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
    end
  },
  {
    name = "坍缩视界",
    id = "R07Q",
    level = 0,
    codeuse = 8,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
      ac.loop(1000, function()
        if u:isalive() and u:getdata("千咲-电锯热力时间") == 0 then
          local z = u:getdata("千咲-锯环残响值")
          z = z + 1
          if z >= u:getdata("千咲-锯环残响值上限") then
            z = u:getdata("千咲-锯环残响值上限")
          end
          u:setdata("千咲-锯环残响值", z)
        end
      end)
    end
  },
  {
    name = "奇点裂相",
    id = "R07J",
    level = 0,
    codeuse = 12,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
    end
  },
  {
    name = "昙切",
    id = "R07S",
    level = 0,
    codeuse = 8,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
    end
  },
  {
    name = "断续疾走",
    id = "R07T",
    level = 0,
    codeuse = 8,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
    end
  },
  {
    name = "伊始之剪",
    id = "R07U",
    level = 0,
    codeuse = 8,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
    end
  },
  {
    name = "虚数断章",
    id = "R07V",
    level = 0,
    codeuse = 12,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
    end
  },
  {
    name = "无解的命途",
    id = "R07W",
    level = 0,
    codeuse = 8,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
    end
  },
  {
    name = "终点在此处",
    id = "R07X",
    level = 0,
    codeuse = 8,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
    end
  },
  {
    name = "拖拽终焉之弦",
    id = "R07Y",
    level = 0,
    codeuse = 15,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
    end
  },
  {
    name = "万理归尘",
    id = "R07Z",
    level = 0,
    codeuse = 15,
    startfunc = function(self, u)
      local b = true
      return b
    end,
    finishfunc = function(self, u)
      local sy = u.ownerid
      u:setdata(heroname .. "-" .. self.name)
    end
  }
}
local talent

local function talent_start(args)
  local res = args.res
  local tfs = args.u
  local sy = tfs.ownerid
  local u = getunit(Hero[sy])
  for index, value in ipairs(talentrun) do
    if S2ID(value.id) == res then
      if TalentCode[sy] >= value.codeuse then
        if not value:startfunc(u) then
          goto lbl_28
        end
        do break end
        ::lbl_28::
        IssueImmediateOrderById(tfs.handle, 851976)
        break
      end
      IssueImmediateOrderById(tfs.handle, 851976)
      u:sendmessage("|cFF7DBEF1天赋点不足")
      break
    end
  end
end

local function talent_finish(args)
  local res = args.res
  local tfs = args.u
  local sy = tfs.ownerid
  local unittype = GetUnitTypeId(tfs.handle)
  tfs:remove()
  local u = getunit(Hero[sy])
  TalentCount[sy] = TalentCount[sy] + 1
  tfs = getunit(CreateUnitLua(Player(PLAYER_NEUTRAL_PASSIVE), unittype, Talent_X, Talent_Y, 0))
  TalentDw[sy] = tfs.handle
  tfs:changeowner(u.owner)
  tfs:setlevel(999)
  tfs:triggeraddevent(Byltalentshow, EVENT_UNIT_SELECTED)
  tfs:triggeraddevent(Trg_UNIT_RESEARCH_START, EVENT_UNIT_RESEARCH_START)
  tfs:triggeraddevent(Trg_UNIT_RESEARCH_FINISH, EVENT_UNIT_RESEARCH_FINISH)
  local talents = u:getdata("英雄-天赋树表")
  tfs:addtrgevent("单位-开始研究科技", function(args)
    talents.start(args)
  end)
  tfs:addtrgevent("单位-完成研究科技", function(args)
    talents.finish(args)
  end)
  for index, value in ipairs(talentrun) do
    if S2ID(value.id) == res then
      value.level = value.level + 1
      TalentCode[sy] = TalentCode[sy] - value.codeuse
      value:finishfunc(u)
      break
    end
  end
end

local function talent_replace(args)
  local tfs = getunit(args.unit)
  local sy = tfs.ownerid
  local unittype = GetUnitTypeId(tfs.handle)
  tfs:remove()
  local u = getunit(Hero[sy])
  if unittype == S2ID("H05Z") then
    unittype = S2ID("H060")
  else
    unittype = S2ID("H05Z")
  end
  u:select()
  tfs = getunit(CreateUnitLua(Player(PLAYER_NEUTRAL_PASSIVE), unittype, Talent_X, Talent_Y, 0))
  TalentDw[sy] = tfs.handle
  tfs:changeowner(u.owner)
  tfs:setlevel(999)
  tfs:triggeraddevent(Byltalentshow, EVENT_UNIT_SELECTED)
  tfs:triggeraddevent(Trg_UNIT_RESEARCH_START, EVENT_UNIT_RESEARCH_START)
  tfs:triggeraddevent(Trg_UNIT_RESEARCH_FINISH, EVENT_UNIT_RESEARCH_FINISH)
  local talents = u:getdata("英雄-天赋树表")
  TriggerRegisterUnitEvent(Trg_UnitSkill, tfs.handle, EVENT_UNIT_SPELL_EFFECT)
  tfs:addtrgevent("单位-发动技能", function(args)
    if args.skill == S2ID("A0HC") then
      talent.replace(args)
    end
  end)
  tfs:addtrgevent("单位-开始研究科技", function(args)
    talent.start(args)
  end)
  tfs:addtrgevent("单位-完成研究科技", function(args)
    talent.finish(args)
  end)
  tfs:select()
end

talent = {
  start = talent_start,
  finish = talent_finish,
  replace = talent_replace
}
return talent
