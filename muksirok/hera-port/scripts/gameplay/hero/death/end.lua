-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local player = require("jh.ac.player")
local slk = require("jass.slk")
local OshinoTaboo = require("gameplay.var.advance.oshino_taboo")

local function deathself(unit, murder)
  local live = false
  local xs = getunit(murder)
  local u = getunit(unit)
  local sy = u.ownerid
  local sy2 = xs.ownerid
  local x, y = u:getxy()
  local bb = getunit(Beibao[sy])
  StexiaoFunc({
    text = "英雄死亡时效果",
    u = u,
    tg = xs,
    soc = xs
  })
  if u:getdata("幻想乡-P点") > 0 then
    local down = math.floor(0.6 * u:getdata("幻想乡-P点"))
    local count = math.floor(0.5 * u:getdata("幻想乡-P点"))
    PdianAdd(u, -down)
    local wp = CreateItemLua(S2ID("I0MT"), x, y)
    SetData(wp, "P点数量", count)
  end
  if ModeSelect_Muss then
    if xs:isingroup(Group_PlayHero) then
      SendMsgAll(xs:getplayername() .. "|cFFCC0000杀害了|r" .. u:getplayername())
      ac.loop(1000, function(t)
        UnitShareVision(murder, u.owner, true)
        if u:isalive() then
          UnitShareVision(murder, u.owner, false)
          t:remove()
        end
      end)
    else
      SendMsgAll(u:getplayername() .. "|cFFCC0000被怪物杀害了|r")
    end
  end
  if u:hasdata("变异判定-朱雀院红叶") then
    u:getdata("红叶-境界增加函数")(10, 0.1)
  end
  if u:hasdata("史尔特尔-登龙释放中") and not u:hasdata("史尔特尔-全是爱播放冷却") and not u:hasdata("史尔特尔-关闭彩蛋语音") then
    PlayBGM({
      bgm = Sound_42_Caidan,
      time = 25,
      ID = 196,
      unit = u.handle
    })
    u:settimedata("史尔特尔-全是爱播放冷却", 600)
    u:chat("↑↓↑→←→←→")
  end
  if xs:hasdata("变异判定-莉可莉丝") and GetUnitTypeId(murder) == HeroType["切嗣"] and murder ~= unit then
    xs:getdata("千束-进阶检定")()
  end
  if u:hasdata("背包-艾露猫") then
    AilumaoSnd(u, "死亡")
  end
  if u:hasdata("八重樱-购物达人") then
    local rd = GetRandomInt(5, 25)
    u:sendmessage("|cFFFF99FF来|r|cFFFB9DFF自|r|cFFF8A0FF粉|r|cFFF4A4FF色|r|cFFF0A8FF妖|r|cFFEDABFF精|r|cFFE9AFFF小|r|cFFE6B2FF姐|r|cFFE2B6FF的|r|cFFDEBAFF抚|r|cFFDBBDFF恤|r|cFFD7C1FF金|r|cFFD3C5FF：|r" .. rd)
    u:addwood(rd)
  end
  if u:hasdata("隐藏职业-无用之人") and xs:isingroup(Group_PlayHero) then
    hideproshow(unit)
    for i = 1, 2 do
      RandomNormalMedcine(murder)
    end
  end
  if xs:hasdata("变异判定-枪之恶魔") then
    ChangeValue(Correction_Gun_Bullet, sy2, 8.0E-4)
    ChangeValue(Correction_Unify, sy2, 8.0E-4)
    if xs:getdata("枪之恶魔-杀敌时间") <= 180 then
      xs:setdata("枪之恶魔-杀敌时间", 180)
    end
  end
  if xs:hasdata("变异判定-阿波菲斯") and murder ~= unit and not Boolean_Abfs then
    SendMsgAll(u:getplayername() .. "|cFF990000被阿波菲斯杀害了|r")
    u:addallstats(5)
    Boolean_Abfs = true
    ac.wait(60000, function()
      Boolean_Abfs = false
    end)
  end
  if u:hasdata("里三天赋-永恒的梦魇") and not u:hasdata("里三-永恒的梦魇冷却") then
    u:settimedata("里三-永恒的梦魇冷却", 12)
    if u:getluckrandom(12) then
      ChangeValue(DamageSystem_Shjc, sy, 0.0121)
    end
    if u:getluckrandom(12) then
      u:addallstats(12)
    end
    if u:getluckrandom(12) then
      ChangeValue(Correction_Magic, sy, 0.0012000000000000001)
    end
  end
  if u:hasdata("特殊判定-宇智波复仇者") then
    u:changedata("佐助-复仇值", 5)
  end
  if u:hasdata("吉普利露-禁忌化") and 5 < u:getlevel() then
    live = true
    u:addlevel(-5)
    local shlx = u:getdata("吉普利露-禁忌化受伤类型")
    if shlx == 1 then
      u:changedata("吉普利露-禁忌化类型减伤1", 0.2)
      if 0.6 <= u:getdata("吉普利露-禁忌化类型减伤1") then
        u:setdata("吉普利露-禁忌化类型减伤1", 0.6)
      end
    end
    if shlx == 2 then
      u:changedata("吉普利露-禁忌化类型减伤2", 0.2)
      if 0.6 <= u:getdata("吉普利露-禁忌化类型减伤2") then
        u:setdata("吉普利露-禁忌化类型减伤2", 0.6)
      end
    end
    if shlx == 3 then
      u:changedata("吉普利露-禁忌化类型减伤3", 0.2)
      if 0.6 <= u:getdata("吉普利露-禁忌化类型减伤3") then
        u:setdata("吉普利露-禁忌化类型减伤3", 0.6)
      end
    end
    if shlx == 4 then
      u:changedata("吉普利露-禁忌化类型减伤4", 0.2)
      if 0.6 <= u:getdata("吉普利露-禁忌化类型减伤4") then
        u:setdata("吉普利露-禁忌化类型减伤4", 0.6)
      end
    end
    if shlx == 5 then
      u:changedata("吉普利露-禁忌化类型减伤5", 0.2)
      if 0.6 <= u:getdata("吉普利露-禁忌化类型减伤5") then
        u:setdata("吉普利露-禁忌化类型减伤5", 0.6)
      end
    end
  end
  if u:hasdata("诱导法存活标记") then
    u:deldata("诱导法存活标记")
  end
  Hero_Tili[sy] = Hero_Tili_Max[sy]
  if u:hasdata("竹取飞翔-辉夜") then
    getunit(Qiyue_Meihonghuiye_Meihong):effectadd("ATX\\[ATxNew]Purple_15.mdl", "origin", 3)
    getunit(Qiyue_Meihonghuiye_Meihong):buffset(unit, 3, "绝对闪避")
  end
  if u:hasdata("竹取飞翔-妹红") then
    getunit(Qiyue_Meihonghuiye_Huiye):effectadd("ATX\\[ATxNew]Purple_15.mdl", "origin", 3)
    getunit(Qiyue_Meihonghuiye_Huiye):buffset(unit, 3, "绝对闪避")
  end
  if u:hasdata("变异判定-吃货") and not Weiyi[22] and u:ishasshw() and u:getdata("返魂度") >= 1800 then
    local jl = 30
    if u:hasdata("血统判定-幽灵") then
      jl = 60
    end
    if GetRandom100(jl) then
      live = true
      AdvanceGet["西行寺幽幽子"](u)
    end
  end
  if u:hasdata("变异判定-西行寺幽幽子") and not u:hasdata("死亡操纵冷却") and not u:hasdata("莲华-即死判定") and not live then
    live = true
    local t = 12
    if u:hasdata("血统判定-幽灵") then
      t = 24
    end
    u:setdata("死亡操纵-无限复活")
    u:effectadd("ATX\\[ATxNew]Pink_12.mdl")
    u:effectadd("ATX\\[ATxNew]Pink_07.mdl", "origin", t)
    ac.wait(t * 1000, function()
      u:deldata("死亡操纵-无限复活")
      u:setdata("死亡操纵-必死判定")
      u:kill()
      u:deldata("死亡操纵-必死判定")
    end)
    u:settimedata("死亡操纵冷却", 600)
    ac.wait(600000, function()
      u:sendmessage("|cFF9900CC死亡操纵冷却完毕|r")
    end)
  end
  if u:hasdata("变异判定-武神护佑") then
    u:addallstats(2)
  end
  if unit == Qiyue_Troline_Duixiang then
    getunit(Qiyue_Troline_Zishen):addrandomstats(5)
  end
  if u:hasdata("奥尔加-卡其脱离太") or u:hasdata("奥尔加-杀意感知失败") or u:hasdata("奥尔加-车已经准备好了") then
    PlayGlobalSound(Sound_Aoerjia_04)
  end
  if u:hasdata("变异判定-奥尔加团长") then
    ChangeValue(DamageSystem_Shjc, sy, 0.1 * -u:getdata("奥尔加-提升伤害加成"))
    u:setdata("奥尔加-提升伤害加成", 0)
    if not u:hasdata("希望之花冷却") then
      u:settimedata("希望之花冷却", 480)
      SendMsgAll("|cff55f9ffBGM:《希望の花》|r")
      PlayBGM({
        bgm = BGM_Tuanzhang,
        time = 145,
        ID = 210,
        unit = u.handle
      })
      ForGroupLuaNew(Group_DeathHero, function(xq2)
        if xq2 ~= u then
          HeroRelive(xq2.handle, x, y, 3)
        end
      end)
    end
  end
  if Boolean_Nani then
    SendMsgAll(u:getplayername() .. "|cFF999999：なに？|r")
    Boolean_Nani = false
    PlayGlobalSound(Sound_Jiancilang_02)
  end
  if not u:hasdata("莲华-即死判定") and unit == Qiyue_WhiteLen_Len and getunit(Qiyue_WhiteLen_Nanaya):isalive() and not live then
    live = true
    local nanaya = getunit(Qiyue_WhiteLen_Nanaya)
    nanaya:setxy(x, y)
    nanaya:kill(unit)
    local yx = {}
    yx[1] = Sound_Len_11
    yx[2] = Sound_Len_12
    yx[3] = Sound_Len_13
    PlayGlobalSound(yx[GetRandomInt(1, 3)])
  end
  if not live and u:hasdata("变异判定-狼") and not u:hasdata("变异判定-只狼") then
    local z = 95
    local g = CreateGroupLua()
    ForGroupLuaNew(Group_Xingcunzu, function(xq)
      xq:groupadd(g)
    end)
    u:groupremove(g)
    if 0 < Group_Counts(g) then
      do
        local lk = Group_Randomunit(g)
        if type(lk) ~= "table" then
          error("龙咳候选组计数与内容不一致")
        end
        local sy2 = lk.ownerid
        DamageSystem_Sszengjia[sy2] = DamageSystem_Sszengjia[sy2] + 0.08
        lk:changedata("只狼-龙咳层数", 1)
        if 5 <= lk:getdata("只狼-龙咳层数") then
          lk:changedata("只狼-龙咳层数", -5)
          ac.wait(1000, function()
            DamageSystem_Sszengjia[sy2] = DamageSystem_Sszengjia[sy2] - 0.4
            lk:sendmessage("你死于龙咳")
            lk:kill(unit)
          end)
        end
      end
    end
  end
  if not live and not u:hasdata("莲华-即死判定") and u:hasdata("露娜-终焉樱解锁") and not u:hasdata("露娜-终焉樱复活") then
    live = true
    u:setdata("露娜-终焉樱复活")
    u:sendmessage("|cFFFF99FF终焉樱-复活|r")
    u:buffset(u.handle, 5, "绝对闪避")
    u:buffset(u.handle, 5, "无敌")
  end
  if not live and not u:hasdata("莲华-即死判定") and 0 < u:getdata("阿卡多-永恒之命") then
    live = true
    u:changedata("阿卡多-永恒之命", -1)
    local yx = {}
    yx[1] = Yuyue_1
    yx[2] = Yuyue_2
    yx[3] = Yuyue_3
    yx[4] = Yuyue_4
    yx[5] = Yuyue_5
    yx[6] = Yuyue_6
    yx[7] = Yuyue_7
    yx[8] = Yuyue_8
    yx[9] = Yuyue_9
    u:playsound(yx[GetRandomInt(1, 9)])
  end
  if not live and not u:hasdata("莲华-即死判定") and 0 < u:getdata("愚者-宿命计数") and 4 > u:getdata("愚者-宿命复活次数") then
    live = true
    u:changedata("愚者-宿命复活次数", 1)
    u:changedata("愚者-宿命计数", -1)
    u:sendmessage("|cFF838383[天尊意志]宿命|r")
  end
  if not live and u:hasdata("神话判定-孔瑞丽") and not u:hasdata("孔瑞丽-复活冷却") then
    live = true
    u:settimedata("孔瑞丽-复活冷却", 188)
    u:sendmessage("|cFFF1CCC3[孔|r|cFFF4BFD2瑞|r|cFFF8B2E1丽]泪尽铃音响|r")
  end
  if u:hasdata("幽灵鲨-终焉之音") then
    if 2 > u:getdata("肉斩骨断次数") then
      u:changedata("肉斩骨断次数", 3)
    else
      u:setdata("肉斩骨断次数", 5)
    end
  end
  if u:hasdata("依神凭依-天子") and unit == Qiyue_Zuiqiangerren_Tianzi then
    getunit(Qiyue_Zuiqiangerren_Zhenmiaowa):kill(unit)
  end
  if u:hasdata("变异判定-祸灵梦") then
    PlayGlobalSound(Sound_Hlm_Death)
  end
  if u:ishasitem("I03J") then
    local wp = u:getitem("I03J")
    if GetItemCharges(wp) < 400 then
      ChangeItemCount(wp, -1 * GetItemCharges(wp) / 4)
    end
  end
  if u:hasdata("血统判定-亡灵") or u:hasdata("血统判定-深海驱逐") then
    u:changedata("怨念值", 10)
    u:addrandomstats(1)
  end
  if u:hasdata("血统判定-深海空母") then
    ForGroupLuaNew(Group_PlayHero, function(xq)
      if xq:getdata("怨念值") > 0 then
        xq:changedata("怨念值", 10)
        xq:addrandomstats(1)
      end
    end)
  end
  if u:hasdata("变异判定-蕾米莉亚") then
    u:changedata("觉醒度", 1)
  end
  if unit == Qiyue_Meilizhiwu_Duixiang then
    ChangeValue(DamageSystem_Ssjianshao, sy, 0.88, 2)
    Qiyue_Meilizhiwu_Duixiang = 0
    local ml = getunit(Qiyue_Meilizhiwu_Zishen)
    ml:kill(unit)
    u:deldata("美丽之物-契约加成")
    ChangeValue(DamageSystem_Baoji, sy, -6)
    ChangeValue(DamageSystem_Baoshang, sy, -0.13)
  end
  if u:hasdata("变异判定-斯卡蒂") and not u:hasdata("冬结束") then
    if u:getdata("冬之殇") >= 10 then
      u:setdata("冬结束")
    else
      u:setdata("冬之殇", 0)
    end
  end
  if u.type == HeroType["十六夜"] then
    u:setdata("累积伤害", 0)
  end
  if u:hasdata("铃仙-弱心丧意") then
    ChangeValue(DamageSystem_Sszengjia, sy, 0.05)
  end
  if unit == Danwei_Yuzaoqian then
    ForGroupLuaNew(Group_Yzq_Mimizhiyin, function(xq)
      xq:kill(unit)
    end)
  end
  if u:hasdata("变异判定-蓬莱山辉夜") then
    ForGroupLuaNew(Group_Xingcunzu, function(xq)
      xq:sethp(100, true)
      xq:curemp(0, 100)
      xq:effectadd("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", "origin", 3)
      xq:settimedata("永夜永恒", 3)
    end)
  end
  if u:hasdata("变异判定-麦哲伦") then
    local down = 0.5 * u:getdata("麦哲伦-考察记录生命上限")
    local down2 = 0.5 * u:getdata("麦哲伦-考察记录伤害加成")
    u:changedata("麦哲伦-考察记录生命上限", -down)
    u:changedata("麦哲伦-考察记录伤害加成", -down2)
    u:changemaxhp(-down)
    ChangeValue(DamageSystem_Shjc, sy, 0.1 * -down2)
    PlayGlobalSound(Sound_Maizhelun_03)
  end
  if u:hasdata("变异判定-雪怨") then
    ChangeValue(Hero_Tili_Max, sy, 1)
    u:addallstats(1)
  end
  if unit == Qiyue_Qiurangzi_Duixiang then
    local qydx = getunit(Qiyue_Qiurangzi_Zishen)
    local sy3 = qydx.ownerid
    qydx:changedata("祝福对象死亡次数", 1)
    if qydx:hasdata("秋穰子-禁忌化") then
    else
      qydx:changedata("幸运", -1)
      ChangeValue(DamageSystem_Sszengjia, sy3, 0.025)
      if qydx:getdata("祝福对象死亡次数") == 10 then
      end
    end
  end
  return live
end

local function deathother(unit, murder)
  local u = getunit(unit)
  local xs = getunit(murder)
  local sy = u.ownerid
  local sy2 = xs.ownerid
  local x, y = u:getxy()
  ForGroupLuaNew(Group_PlayHero, function(xq)
    local sy3 = xq.ownerid
    if xq.handle ~= unit and xq:isalive() then
      if xq:hasdata("特殊判定-宇智波复仇者") then
        xq:changedata("佐助-复仇值", 3)
      end
      if xq:hasdata("变异判定-朱雀院红叶") and DistanceBetweenUnits(xq.handle, u.handle) then
        xq:getdata("红叶-境界增加函数")(5, 0.05)
      end
      if xq:hasdata("月面-雨中提琴") and not xq:hasdata("刀光哥-台词冷却中") and GetRandom100(10) then
        xq:chat("在我活着的期间，是不会让同伴死的。")
        xq:settimedata("刀光哥-台词冷却中", 10)
      end
      if Weiyi_Dz[32] and xq:hasdata("变异判定-虚无魔女") then
        xq:addallstats(2)
        ChangeValue(Correction_Magic, sy3, 1.0E-4)
      end
      if not Weiyi[15] and xq:hasdata("变异判定-写轮眼") and xq:ishasshw() then
        local jl = 0.5
        if IsUnitVisible(unit, xq.owner) then
          jl = 2
        end
        if GetRandom100(jl) or xq:hasdata("邪王真眼-进阶满足") then
          xq:deldata("邪王真眼-进阶满足")
          AdvanceGet["旗木卡卡西"](xq)
        end
      end
      if xq:hasdata("血统判定-妖魔之子") then
        xq:changemaxhp(10)
        xq:addrandomstats(GetRandomInt(1, 3))
      end
      if xq:hasdata("丛雨-神化") then
        xq:addallstats(5)
        ChangeValue(Correction_Jzsh, sy3, 0.005000000000000001)
      end
      if xq:hasdata("变异判定-斯卡蒂") and not xq:hasdata("冬结束") then
        xq:changedata("冬之殇", 1)
        xq:addrandomstats(1)
      end
    end
  end)
  if Danwei_Baoming ~= 0 and not Boolean_BaomingIng and not Boolean_BaomingTip[3] then
    AdvanceGet["终末鸟-小鸟事件"](u)
  end
  if murder ~= unit then
    if xs:hasdata("变异判定-魔术师杀手") then
      ChangeValue(Correction_Gun, sy2, 0.01)
      if u:hasdata("魔术师杀手-切嗣强化") then
        ChangeValue(Correction_Gun, sy2, 0.01)
        ChangeValue(DamageSystem_Shjc, sy2, 0.025)
      end
    end
    if xs:hasdata("变异判定-龙宫礼奈") then
      u:changedata("礼奈击杀次数", 1)
      if 3 <= u:getdata("礼奈击杀次数") then
      else
        xs:changedata("礼奈击杀队友强化", 0.15)
      end
      local yx = {}
      yx[1] = Sound_Rena_Laugh_01
      yx[2] = Sound_Rena_Laugh_02
      yx[3] = Sound_Rena_Laugh_03
      yx[4] = Sound_Rena_Laugh_04
      yx[5] = Sound_Rena_Laugh_05
      u:playsound(yx[GetRandomInt(1, 5)])
    end
    if xs:hasdata("切嗣的正义") then
      ChangeTimeValue(DamageSystem_EndSh, sy, 0.010000000000000002)
    end
    if xs:hasdata("玉藻前-轩辕冥府") then
      xs:addstr(10)
      xs:changemaxhp(-90)
      ChangeValue(DamageSystem_Shjc, sy, 0.015)
    end
    if Danwei_Yuzaoqian ~= 0 and unit ~= Danwei_Yuzaoqian then
      getunit(Danwei_Yuzaoqian):changemaxhp(50)
    end
    if u:hasdata("变异判定-特里诺") then
      Trinoline_Jilv = Trinoline_Jilv - 5
      ChangeValue(DamageSystem_Sszengjia, sy, 0.05)
      if Trinoline_Jilv <= 25 then
        Trinoline_Jilv = 25
      end
      if DamageSystem_Shjc[sy] > 1 then
        DamageSystem_Shjc[sy] = DamageSystem_Shjc[sy] - 0.005
      end
    end
    if u:hasdata("特里诺-契约对象") then
      local tro = getunit(Qiyue_Troline_Zishen)
      local sy3 = tro.ownerid
      tro:addstr(2)
      if not tro:ishasskill("A05O") then
        tro:addskill("A05O")
        ChangeTimeValue(DamageSystem_Shjc, sy3, 0.03, 30)
        ChangeTimeValue(DamageSystem_Sszengjia, sy3, 1.5, 30)
        ac.wait(30000, function()
          tro:delskill("A05O")
        end)
      end
    end
  end
  if xs:hasdata("噩梦之主-获命永恒") then
    xs:sethp(xs:gethp() + 0.01 * u:getmaxhp() * Nandu_Choose)
    if not xs:hasdata("获命永恒恢复") then
      xs:settimedata("获命永恒恢复", 120)
    end
  end
  for _, xq in ac.selector():in_rangexy(x, y, 1800):isingroup(Group_PlayHero):ipairs() do
    xq = getunit(xq)
    if xq:hasdata("钢铁之躯-愉悦") and not u:hasdata("愉悦冷却") then
      xq:settimedata("愉悦冷却", 100)
      xq:changedata("愉悦时间", 9)
      local yx = {}
      yx[1] = Yuyue_1
      yx[2] = Yuyue_5
      xq:playsound(yx[GetRandomInt(1, 2)])
    end
  end
end

function ThingDrop(unit, boolean)
  local u = getunit(unit)
  local sy = u.ownerid
  if boolean == nil then
    boolean = false
  end
  if not boolean then
    if u.type == HeroType["魔理沙"] or u:hasdata("变异判定-桔梗") or Nandu_Choose <= 3 or u:hasdata("变异判定-藤原妹红") or u:hasdata("变异判定-在原七海") or u:hasdata("物品-四叶草的初心") or u:hasdata("变异判定-月见英子") then
      for i = 1, 6 do
        local wp = u:getcountitem(i)
        local hp = GetWidgetLife(wp)
        if hp == 444 then
          u:dropitem(wp)
        end
      end
    else
      for i = 1, 6 do
        local wp = u:getcountitem(i)
        local wplx = GetItemTypeId(wp)
        local hp = GetWidgetLife(wp)
        if hp == 999 or hp == 33333 or hp == 500000 or wplx == Guns["加斯尔.豺狼"] and u:getdata("加斯尔豺狼-生命上限提升") >= u:getmaxhp() then
        else
          u:dropitem(wp)
        end
      end
    end
  else
    for i = 1, 6 do
      u:dropitem(u:getcountitem(i))
    end
  end
end

local gameoverboolean = false

function GameOverRun()
  if gameoverboolean then
    return
  end
  require('hera_desync_diagnostic').event('MAP_GAME_OVER', '')
  YisiStory["游戏失败"]()
  gameoverboolean = true
  if GetUnitTypeId(Hero_Bzz) == HeroType["白洲梓"] then
    local bzz = getunit(Hero_Bzz)
    if bzz:hasdata("语音-白洲梓") then
      local yx = {}
      yx[1] = Sound_Bzz_Fail_1
      yx[2] = Sound_Bzz_Fail_2
      local snd = yx[GetRandomInt(1, 2)]
      bzz:playsndmsg({
        str = GetData(snd, "绑定台词"),
        snd = snd,
        time = GetData(snd, "语音长度"),
        colors = {
          "F3D9F0",
          "FFFEFF",
          "8A6CAE"
        },
        isignorecd = true,
        isallpeople = true,
        isignoredeath = true
      })
    end
  end
  ForGroupLuaNew(Group_PlayHero, function(xq)
    xq:buffset(xq.handle, 100, "绝对闪避")
    xq:buffset(xq.handle, 100, "暂停")
  end)
  if BOSS == Boss_Zhenhong then
    flashphoto({
      photo = "Ph_Zhenhong_Fail.tga",
      timeout = 3,
      timehold = 3,
      timein = 1
    })
    SendMsgAll("|cFF990000二阶堂真红：消散吧,与这个世界一起……|r")
    ac.wait(6000, function()
      CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 0, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0)
    end)
  elseif BOSS == BOSS_Gesi and getunit(BOSS):hasdata("格斯-狂战士形态") then
    flashphoto({
      photo = "Ph_Gesi_03.tga",
      timeout = 3,
      timehold = 3,
      timein = 1
    })
    SendMsgAll("|cFF990000格斯：献上血肉……献上一切……|r")
    StopSoundBJ(BGM_Gesi_01, false)
    PlayGlobalSound(BGM_Gesi_02)
    ac.wait(6000, function()
      CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 0, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0)
    end)
  else
    CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 4.0, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0)
    SendMsgAll("|cFF7DBEF1所有人都没有足够的灵力再重构身体|r")
    ac.wait(2000, function()
      SendMsgAll("|cFF7DBEF1灵力残骸在这个错位世界中消散化为了魔力。|r")
    end)
  end
  ac.wait(4000, function()
    local cs5 = 0
    ac.loop(2000, function(t)
      cs5 = cs5 + 1
      if Xuanze[cs5] then
        SendMsgAll(NameID[cs5] .. "是" .. Count_RandomPro_Str[Count_RandomPro[cs5]])
        SendMsgAll(" ")
      end
      if cs5 == 6 then
        t:remove()
      end
    end)
  end)
  ac.wait(18000, function()
    local string = {}
    string[1] = "胜败乃兵家常事，请大侠重新来过"
    string[2] = "Game Over"
    string[3] = "同步失败"
    string[4] = "丢人，你马上给我退出战场！"
    string[5] = "你在期待什么失败台词？"
    for i = 1, 6 do
      require('hera_desync_diagnostic').event('MAP_DEFEAT_REQUEST', 'slot=' .. tostring(i))
      CustomDefeatBJ(ConvertedPlayer(i), string[GetRandomInt(1, 5)])
    end
  end)
end

function GameOver()
  if gameoverboolean then
    return
  end
  local fail = true
  local live = false
  if Group_Counts(Group_Xingcunzu) == 0 and (ExBossBattle or CommandDeath or 0 < WaveTimeLimitTimeoutSeconds or Nandu_Shenzhao) then
    ForGroupLuaNew(Group_PlayHero, function(xq)
      if xq:isalive() and xq:hasdata("变异判定-秋静叶") and xq:hasdata("变异判定-信长残魂") and xq:ishasskill("A0HS") then
        fail = false
      end
    end)
    if Lianhua_Jinshibai then
      fail = false
    end
    if Wj_NoFailBattle then
      fail = false
      local boss = getunit(BOSS_Wj)
      boss:setdata("无极-失败标记")
      live = true
    end
    if Nofail_Biaoji then
      fail = false
    end
    local nofail = false
    ForGroupLuaNew(Group_PlayHero, function(xq)
      local x, y = xq:getxy()
      if fail and xq:hasdata("特典-春秋蝉") then
        local gl = xq:getdata("春秋蝉-触发概率")
        if GetRandom100(gl) then
          fail = false
          nofail = true
          live = true
          local sy2 = xq.ownerid
          local p = player[sy2]
          RemoveLinglijutuan(sy2)
          HeroRelive(xq.handle, x, y, 3)
          xq:buffset(xq.handle, 3, "绝对闪避")
          MovieAct["春秋蝉"](xq)
        end
      end
      if fail and xq:hasdata("血统判定-冥神") and xq:getmaxhp() > 1000 and xq:hasdata("冥神-现冥") and not xq:hasdata("冥神-现冥逆转冷却") then
        fail = false
        nofail = true
        live = true
        local sy2 = xq.ownerid
        local p = player[sy2]
        RemoveLinglijutuan(sy2)
        local x, y = xq:getxy()
        for i = 1, 6 do
          p:setalliance(player[i].handle, true, true)
        end
        xq:chat("现界只是虚幻的真实")
        ac.wait(3000, function()
          xq:chat("此刻，现界与冥界逆转")
          CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 2.99, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0)
          PlayGlobalSound(Sound_Mugen_10000_27)
          ac.wait(3000, function()
            SendMsgAll("|cFF3366FF现|r|cFF3352EB冥|r|cFF333DD6逆|r|cFF3329C2转|r")
            SetTimeOfDay(0)
            CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 2, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0)
            AddWeatherEffectSaveLast(RECT_PlayArea, S2ID("MEds"))
            EnableWeatherEffect(GetLastCreatedWeatherEffect(), true)
            HeroRelive(xq.handle, x, y, 5)
            xq:buffset(xq.handle, 5, "绝对闪避")
            if not xq:hasdata("变异判定-西行寺幽幽子") then
              xq:changemaxhp(-1000)
              xq:changemaxhp(-0.1 * xq:getmaxhp())
            end
            ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy2, 500, 15)
            xq:settimedata("冥神-冥行", 15)
            xq:buffset(xq.handle, 15, "无实体")
            local cs5 = 0
            ac.loop(250, function(t)
              cs5 = cs5 + 1
              local x, y = xq:getxy()
              Effectcreate("Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl", x, y)
              if cs5 == 60 then
                t:remove()
              end
            end)
            ForGroupLuaNew(Group_PlayHero, function(xq2)
              if not xq2:hasdata("系统-已删模") and xq2:hasdata("变异判定-西行寺幽幽子") and xq2.handle ~= xq.handle then
                xq2:sendmessage("|cFF3366FF是|r|cFF4A6CFF熟|r|cFF6071FF悉|r|cFF7777FF的|r|cFF8E7DFF世|r|cFFA482FF界|r|cFFBB88FF…|r|cFFD28EFF…|r")
                HeroRelive(xq2.handle, x, y)
              end
            end)
          end)
        end)
        xq:settimedata("冥神-现冥逆转冷却", 1200)
        ac.wait(1200000, function()
          xq:sendmessage("|cFF3366FF现|r|cFF335BF4冥|r|cFF334FE8逆|r|cFF3344DD转|r|cFF3339D2冷|r|cFF332DC6却|r|cFF3322BB完|r|cFF3317B0毕|r")
        end)
        if not xq:hasdata("冥神-现冥背景音乐") then
          xq:setdata("冥神-现冥背景音乐")
          ChangeBGM(BGM_Mingshen_Xianming)
          PlayBGM({
            bgm = 0,
            time = 0,
            ID = 76,
            unit = xq.handle
          })
        end
      end
      if fail and xq:hasdata("遗物-DIO最好的朋友") and not xq:hasdata("系统-已删模") then
        fail = false
        nofail = true
        live = true
        local sy2 = xq.ownerid
        local p = player[sy2]
        RemoveLinglijutuan(sy2)
        for i = 1, 6 do
          p:setalliance(player[i].handle, true, true)
        end
        HeroRelive(xq.handle, x, y, 3)
        xq:buffset(xq.handle, 3, "绝对闪避")
        xq:deldata("遗物-DIO最好的朋友")
        NameID[sy2] = "|cFFFF6699DIO友|r"
        xq:chat("贫弱！贫弱！")
        PlayGlobalSound(Sound_DIO_01)
        xq:setplayername("|cFFFF6699DIO友|r")
      end
      if fail and xq:hasdata("千咲-游戏失败轮回判定") and not xq:hasdata("系统-已删模") then
        local u = xq
        local sy = u.ownerid
        local sy2 = xq.ownerid
        local p = player[sy2]
        local fs = Fenshu[sy]
        local b = true
        for i = 1, 6 do
          if sy ~= i and fs < Fenshu[i] then
            b = false
          end
        end
        if b == true then
          fail = false
          nofail = true
          live = true
          xq:deldata("千咲-游戏失败轮回判定")
          RemoveLinglijutuan(sy2)
          for i = 1, 6 do
            p:setalliance(player[i].handle, true, true)
          end
          HeroRelive(xq.handle, x, y, 3)
          flashphoto({
            photo = "Ph_Qianxiao_Caidan.tga",
            timeout = 8,
            timehold = 4,
            timein = 1
          })
          u:chat("|cFFEC2935……这才是现实！")
          u:chat("|cFFEC2935没有游戏", 3)
          u:chat("|cFFEC2935只有一如往常的悲鸣", 4.7)
          u:chat("|cFFEC2935和过往的每一次", 8.2)
          u:chat("|cFFEC2935都没有区别……", 10.8)
          ac.wait(11000, function()
            flashphoto({
              photo = "Black.tga",
              timeout = 0,
              timehold = 1,
              timein = 3
            })
            SendMsgAll(u:getplayername() .. "|cFFEC2935开启了新的轮回……", 10)
          end)
          ac.wait(13000, function()
            PlayBGM({
              bgm = BGM_Qianxiao_CaidanB,
              time = 50,
              ID = 240,
              unit = u.handle
            })
          end)
          u:settimedata("千咲-轮回无限复活", 58)
          if u:hasdata("千咲-日配") then
            PlayGlobalSound(Sound_Qx_Caidan_Jp)
          else
            PlayGlobalSound(Sound_Qx_Caidan)
          end
          ForGroupLuaNew(Group_PlayHero, function(xq)
            xq:buffset(u.handle, 15, "绝对闪避")
          end)
        end
      end
      if fail and xq:hasdata("神器判定-时螶之鳞") and not xq:hasdata("时螶之鳞-已触发") and not xq:hasdata("系统-已删模") then
        fail = false
        nofail = true
        live = true
        local sy2 = xq.ownerid
        local p = player[sy2]
        RemoveLinglijutuan(sy2)
        for i = 1, 6 do
          p:setalliance(player[i].handle, true, true)
        end
        HeroRelive(xq.handle, x, y, 3)
        xq:buffset(xq.handle, 3, "绝对闪避")
        xq:setdata("时螶之鳞-已触发")
        SendMsgAll("|cFF99CCFF时|r|cFF96C9FF螶|r|cFF93C6FF之|r|cFF8FC2FF鳞|r|cFF8CBFFF逆|r|cFF89BCFF转|r|cFF86B9FF时|r|cFF83B6FF光|r|cFF80B2FF，|r|cFF7CAFFF她|r|cFF79ACFF拥|r" .. xq:getplayername() .. "|cFF73A6FF归|r|cFF70A3FF来|r|cFF6C9FFF。|r")
      end
      if fail and xq:hasdata("狐仙女友") then
        fail = false
        nofail = true
        live = true
        local sy2 = xq.ownerid
        local p = player[sy2]
        RemoveLinglijutuan(sy2)
        for i = 1, 6 do
          p:setalliance(player[i].handle, true, true)
        end
        HeroRelive(xq.handle, x, y, 3)
        xq:buffset(xq.handle, 3, "绝对闪避")
        SetTimeOfDay(12)
        AddWeatherEffectSaveLast(RECT_PlayArea, S2ID("LRaa"))
        EnableWeatherEffect(GetLastCreatedWeatherEffect(), true)
        PlayBGM({
          bgm = BGM_Huxiannvyou,
          time = 390,
          ID = 77,
          unit = xq.handle
        })
        NameID[sy2] = "|cFFFFCCCC耕太|r"
        xq:setplayername("|cFFFFCCCC耕太|r")
        xq:deldata("狐仙女友")
        xq:setdata("传奇数量", 0)
        Hero_Shenhua_Left[sy2] = Hero_Shenhua_Left[sy2] + 1
        xq:uivar_change({
          keyname = "狐仙女友",
          keytype = "传奇栏",
          text = "|cFFFFCCFF狐仙花嫁|r\n|cFFFFCCFF那个时候我就在想，这就是命运的邂逅了。\n那么接下来就交给你了喔，耕太君~|r"
        })
        SendMsgAll("|cFFFFCCFF这种在晴天降下的雨？没错！『狐狸出嫁』！|r")
      end
      if fail and xq:hasdata("玉藻前-永恒的约定") and not xq:hasdata("玉藻前-永恒的约定特殊") then
        fail = false
        nofail = true
        live = true
        local sy2 = xq.ownerid
        local p = player[sy2]
        RemoveLinglijutuan(sy2)
        for i = 1, 6 do
          p:setalliance(player[i].handle, true, true)
        end
        HeroRelive(xq.handle, x, y, 3)
        xq:buffset(xq.handle, 3, "绝对闪避")
        SetTimeOfDay(12)
        PlayBGM({
          bgm = BGM_Yuzaoqian_2,
          time = 295,
          ID = 78,
          unit = xq.handle
        })
        xq:deldata("玉藻前-永恒的约定")
        SendMsgAll("|cFFFFCCFF如果有下一次的话…小玉藻也会依旧和你们一起~|r")
      end
      if fail and xq:hasdata("秦心-我的希望") and xq:ishasshw() then
        fail = false
        nofail = true
        live = true
        local sy2 = xq.ownerid
        local p = player[sy2]
        RemoveLinglijutuan(sy2)
        for i = 1, 6 do
          p:setalliance(player[i].handle, true, true)
        end
        HeroRelive(xq.handle, x, y, 3)
        xq:buffset(xq.handle, 3, "绝对闪避")
        PlayBGM({
          bgm = BGM_Qx_03,
          time = 246,
          ID = 79,
          unit = xq.handle
        })
        NameID[sy2] = "|cFFFF6699秦|r|cFFEB70ADこ|r|cFFD67AC2こ|r|cFFC285D6ろ|r"
        xq:setplayername("|cFFFF6699秦|r|cFFEB70ADこ|r|cFFD67AC2こ|r|cFFC285D6ろ|r")
        xq:deldata("秦心-我的希望")
        xq:adddivinity(1)
        SendMsgAll("|cFFFF6699在|r|cFFFB689D那|r|cFFF76AA1通|r|cFFF36CA5彻|r|cFFEF6EA9透|r|cFFEB70AD明|r|cFFE772B1的|r|cFFE274B6一|r|cFFDE76BA滴|r|cFFDA78BE之|r|cFFD67AC2中|r")
        ac.wait(4000, function()
          SendMsgAll("|cFFCE7ECA请|r|cFFCA81CE告|r|cFFC683D2诉|r|cFFC285D6我|r|cFFBE87DA万|r|cFFBA89DE事|r|cFFB68BE2万|r|cFFB18DE7物|")
        end)
        xq:setdata("秦心-禁忌化")
        local zjsh = 0
        ac.loop(3000, function()
          ChangeValue(DamageSystem_Shjc, sy2, 0.1 * (-1 * zjsh))
          zjsh = 0.3 + 0.007 * xq:getdata("白面具数量")
          ChangeValue(DamageSystem_Shjc, sy2, 0.1 * (1 * zjsh))
        end)
        for i = 1, 6 do
          ChangeValue(HeroMenu_ExtraMoveSpeed, i, 25)
          ChangeValue(DamageSystem_Ssjianshao, i, 0.9, 1)
          ChangeValue(DamageSystem_Shjc, i, 0.01)
          ChangeValue(HeroMenu_HpForever_MaxHp, i, 0.1)
        end
      end
      if nofail then
        if Huanjing_Lingli <= 800 then
          Huanjing_Lingli = 800
          Huanjing_Moli = 0
        end
        if 4 <= xq:getdata("惠惠-暴走魔法阶级") then
          local sy2 = xq.ownerid
          xq:changedata("惠惠-挽回之音复活次数", 1)
          xq:addallstats(100)
          ChangeValue(DamageSystem_Shjc, sy2, 0.1)
          ChangeValue(DamageSystem_Shjc, sy2, 0.1)
          ChangeValue(DamageSystem_Shjc, sy2, 0.1)
        end
      end
    end)
    if fail then
      if ModeSelect_Light or Nandu_Choose <= 1 then
        return
      end
      GameOverRun()
    end
  end
  return live, fail
end

local function deathend(unit, murder)
  local u = getunit(unit)
  local sy = u.ownerid
  local x, y = u:getxy()
  SendMsgAll("活人" .. math.floor(Group_Counts(Group_Xingcunzu)))
  local live = deathself(unit, murder)
  if not live and u:hasdata(OshinoTaboo.LIGHT_FLAG) then
    local should_revive, remaining_revives = OshinoTaboo.consume_final_revive(u:getdata("忍野忍-禁忌终局复活次数"))
    if should_revive then
      live = true
      u:setdata("忍野忍-禁忌终局复活次数", remaining_revives)
      u:sendmessage("|cFFFFE680[忍野忍禁忌]复活剩余" .. remaining_revives .. "次|r")
    end
  end
  if live then
    HeroRelive(unit, x, y, 3)
  end
  deathother(unit, murder)
  if not live then
    local drop = true
    if Nandu_Choose <= 5 or u.type == HeroType["魔理沙"] or u:hasdata("变异判定-桔梗") or u:hasdata("变异判定-在原七海") or u:hasdata("变异判定-藤原妹红") or u:hasdata("物品-四叶草的初心") or u:hasdata("变异判定-地狱歌姬") or u:hasdata("变异判定-月见英子") or u:hasdata("莲华-即死判定") then
      drop = false
    end
    if drop then
      if Hero_Equip_WeaponBoolean[sy] then
        local wq = u:getdata("装备武器")
        local wqlx = Hero_Equip_WeaponType[sy]
        if wqlx == Weapons["绯"] and DamageSystem_Shjc[sy] >= GetData(wq, "绯-最终伤害提升") then
          local zz = 0.1 * (DamageSystem_Shjc[sy] - GetData(wq, "绯-最终伤害提升"))
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-0.25 * zz))
          ChangeData(wq, "绯-最终伤害提升", 0.75 * zz)
          u:sendmessage("|cFFCC0000绯汲取了" .. math.floor(zz * 100) .. "%伤害加成|r")
        end
        if wqlx == Weapons["鬼丸国纲"] and u:getmaxhp() >= GetData(wq, "鬼丸国纲-生命上限提升") then
          local zz = 0.1 * (u:getmaxhp() - GetData(wq, "鬼丸国纲-生命上限提升"))
          u:changemaxhp(-0.2 * zz)
          ChangeData(wq, "鬼丸国纲-生命上限提升", 0.8 * zz)
          u:sendmessage("|cFFCC0000鬼丸国纲汲取了" .. math.floor(zz) .. "点生命上限|r|r")
        end
        weapondown(unit, false)
      end
      modeldown(unit)
      if u.type ~= HeroType["铃仙"] then
        gunchangedel(unit)
      end
    else
      for i = 1, 6 do
        local wp = u:getcountitem(i)
        if GetItemLifeBJ(wp) == 4444 then
          u:dropitem(wp)
        end
      end
      if Hero_Equip_WeaponBoolean[sy] then
        local wq = u:getdata("装备武器")
        local wqlx = Hero_Equip_WeaponType[sy]
        if wqlx == Weapons["村正"] or wqlx == Weapons["绯"] or wqlx == Weapons["鬼丸国纲"] or wqlx == Weapons["压切长谷部"] or wqlx == Weapons["轩辕剑(封)"] then
          if wqlx == Weapons["绯"] and DamageSystem_Shjc[sy] >= GetData(wq, "绯-最终伤害提升") then
            local zz = 0.1 * (DamageSystem_Shjc[sy] - GetData(wq, "绯-最终伤害提升"))
            ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-0.25 * zz))
            ChangeData(wq, "绯-最终伤害提升", 0.75 * zz)
            u:sendmessage("|cFFCC0000绯汲取了" .. math.floor(zz * 100) .. "%伤害加成|r")
          end
          if wqlx == Weapons["鬼丸国纲"] and u:getmaxhp() >= GetData(wq, "鬼丸国纲-生命上限提升") then
            local zz = 0.1 * (u:getmaxhp() - GetData(wq, "鬼丸国纲-生命上限提升"))
            u:changemaxhp(-0.2 * zz)
            ChangeData(wq, "鬼丸国纲-生命上限提升", 0.8 * zz)
            u:sendmessage("|cFFCC0000鬼丸国纲汲取了" .. math.floor(zz) .. "点生命上限|r|r")
          end
        end
      end
    end
    if Weapon_Yaqiechanggubu and not u:hasdata("本能寺变") then
      u:setdata("本能寺变")
    end
  end
  if not live then
    local cs = 0
    local cs2 = 0
    local fhd, sjs
    if u:hasdata("变异判定-藤原妹红") then
      fhd = u:createunit("h01R", x, y)
      sjs = u:getdata("涅槃时间")
      fhd:setmp(sjs * 10)
      PlayGlobalSound(boom1)
      local cs3 = 0
      ac.loop(250, function(timer)
        cs3 = cs3 + 1
        Effectcreate("war3mapImported\\blast3.mdx", x, y, 0, 5)
        if cs3 == 5 then
          timer:remove()
        end
      end)
      local txsh = 10000 * (1 + u:getdata("涅槃次数"))
      for _, xq in ac.selector():in_rangexy(x, y, 1800):is_enemy(unit):ipairs() do
        xq = getunit(xq)
        xq:settimedata("涅槃破防", 10)
        xq:buffset(unit, 10, "眩晕")
        DamageUnit({
          bj = "藤原妹红涅槃",
          unit = xq.handle,
          source = u.handle,
          damage = txsh,
          level = 5,
          type = "灵力",
          isvest = true,
          isnoarmor = false
        })
      end
    end
    local run = false
    ac.loop(1000, function(timer)
      cs = cs + 1
      local fhboolean = false
      local rel = false
      if u:hasdata("变异判定-歼灭天使") then
        run = true
        if cs >= u:getdata("歼灭天使-复活") then
          rel = true
          u:changedata("歼灭天使-复活", 22)
          u:effectadd("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl")
        end
      end
      if u:hasdata("蕾米莉亚-白夜公主") then
        run = true
        if not u:hasdata("蕾米莉亚-白夜公主复活冷却") and 90 <= cs then
          rel = true
          u:effectadd("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl")
        end
      end
      if u:hasdata("利姆露-契约对象") then
        run = true
        local qy = getunit(Qiyue_Rimuru_Zishen)
        if qy:isalive() then
          fhboolean = true
        end
        if 360 <= cs2 then
          rel = true
          x, y = qy:getxy()
        end
      end
      if u:hasdata("奈落の羁绊") then
        run = true
        local qy
        if unit == Qiyue_Nailuo_Gongzhu then
          qy = getunit(Qiyue_Nailuo_Yuanye)
        else
          qy = getunit(Qiyue_Nailuo_Gongzhu)
        end
        if qy:isalive() then
          fhboolean = true
        end
        if 300 <= cs2 then
          rel = true
          x, y = qy:getxy()
          do
            local perhp = qy:getperhp() * 2
            ac.wait(1, function()
              qy:sethp(perhp, true)
              u:sethp(perhp, true)
            end)
          end
        end
      end
      if u:hasdata("爱丽丝-无魂人形") then
        run = true
        if cs >= 180 + u:getdata("爱丽丝-无魂人形复活") then
          rel = true
          u:changedata("爱丽丝-无魂人形复活", 30)
          u:effectadd("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl")
          if not u:hasdata("无魂人形首次苏生") then
            u:setdata("无魂人形首次苏生")
            SendMsgAll("|cFF990000此后正直者就不复存在。|r")
            u:uivar_add({
              keyname = "正直者之死",
              keytype = "疾病栏",
              text = "|cFF990000正直者之死|r\n|cFF990000森林里的废洋馆中走出来的美丽金发少女。虽然我觉得我该在哪里见过她，但那种琐碎的事我就记不清了。\n那女孩恶作剧地吐出舌头并点头行礼，然后大笑着往乐园的出口走去。奇怪的女孩呢。\n　　提起这个，那女孩该是正直者八人组里唯一一位女性吧，虽然那些事怎样都好。\n　　啊——，今天又是无聊的一天啊…|r",
              icon = "war3mapImported\\BTNTianfu_F_Wuhunrenxing.blp"
            })
          end
        end
      end
      if u:hasdata("轮回之廊无尽") then
        run = true
        if cs >= u:getdata("轮回时间") then
          rel = true
          u:changedata("轮回时间", 24)
          u:changedata("时间点", 120)
          u:effectadd("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl")
          ChangeValue(DamageSystem_Shjc, sy, 0.0012)
          ChangeValue(DamageSystem_Shjc, sy, 0.0012)
          ChangeValue(DamageSystem_Shjc, sy, 0.0012)
          if GetRandom100(12) then
            ChangeValue(DamageSystem_Shjc, sy, 0.0012)
            ChangeValue(DamageSystem_Shjc, sy, 0.0012)
            ChangeValue(DamageSystem_Shjc, sy, 0.0012)
          end
          if not u:hasdata("轮回之廊首次苏生") then
            u:setdata("轮回之廊首次苏生")
            SendMsgAll("|cFFE55AAF「|r|cFFE65CAE会|r|cFFE75FAD站|r|cFFE861AC起|r|cFFE964AC来|r|cFFEA66AB的|r|cFFEB69AA，|r|cFFEC6BA9为|r|cFFED6DA8了|r|cFFEE70A7你|r|cFFEF72A7的|r|cFFF075A6话|r|cFFF177A5，|r|cFFF279A4即|r|cFFF37CA3使|r|cFFF47EA2千|r|cFFF581A1百|r|cFFF683A1遍|r|cFFF786A0也|r|cFFF8889F会|r|cFFF98A9E站|r|cFFFA8D9D起|r|cFFFB8F9C来|r|cFFFC929C！|r|cFFFD949B」|r")
          end
        end
      end
      if u:getdata("黑龙血统阶级") >= 4 then
        run = true
        if 180 <= cs then
          rel = true
          u:effectadd("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl")
        end
      end
      if u:hasdata("变异判定-藤原妹红") then
        run = true
        sjs = sjs - 1
        if sjs == 6 then
          PlayGlobalSound(Meihong_Baozha)
        end
        if sjs <= 6 then
          Effectcreate("war3mapImported\\41.mdx", x, y, 6, 3)
        end
        if sjs <= 0 then
          rel = true
          u:changedata("涅槃时间", 30)
          u:changedata("涅槃次数", 1)
          u:addallstats(1)
          u:addlevel(1)
          ChangeTimeValue(HeroMenu_HpForever_MaxHp, sy, 1, 10)
          ChangeTimeValue(HeroMenu_HpForever_MaxHp, sy, 0.2, 100)
          u:sendmessage("|cFFFF6633「|r|cFFFF6130不|r|cFFFF5C2E知|r|cFFFF572B这|r|cFFFF5229是|r|cFFFF4D26第|r|cFFFF4724几|r|cFFFF4221次|r|cFFFF3D1F的|r|cFFFF381C生|r|cFFFF331A命|r|cFFFF2E17，|r|cFFFF2914燃|r|cFFFF2412烧|r|cFFFF1F0F殆|r|cFFFF1A0D尽|r|cFFFF140A吧|r|cFFFF0F08！|r|cFFFF0A05」|r")
          u:effectadd("Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl")
          local cs3 = 0
          ac.loop(250, function(timer2)
            cs3 = cs3 + 1
            Effectcreate("war3mapImported\\blast3.mdx", x, y, 0, 5)
            if cs3 == 5 then
              timer2:remove()
            end
          end)
          local txsh = 10000 * (1 + u:getdata("涅槃次数"))
          for _, xq in ac.selector():in_rangexy(x, y, 1800):is_enemy(unit):ipairs() do
            xq = getunit(xq)
            xq:settimedata("涅槃破防", 10)
            xq:buffset(unit, 10, "眩晕")
            DamageUnit({
              bj = "藤原妹红涅槃",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 5,
              type = "灵力",
              isvest = true,
              isnoarmor = false
            })
          end
        end
      end
      if u:hasdata("丛雨-神化") then
        run = true
        local qy = getunit(Qiyue_Murasame_Master)
        if qy:isalive() then
          fhboolean = true
        end
        if cs2 >= u:getdata("丛雨复活时间") then
          rel = true
          u:changedata("丛雨复活时间", 10)
          x, y = qy:getxy()
        end
      end
      if u:hasdata("依神凭依-针妙丸") then
        run = true
        local qy = getunit(Qiyue_Zuiqiangerren_Tianzi)
        if qy:isalive() then
          fhboolean = true
        end
        if cs2 >= u:getdata("依神凭依复活时间") then
          rel = true
          u:changedata("依神凭依复活时间", 10)
          x, y = qy:getxy()
        end
      end
      if u:hasdata("血统判定-冥神") then
        run = true
        if 240 <= cs2 then
          rel = true
          u:effectadd("Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl", x, y)
        end
      end
      if fhboolean then
        cs2 = cs2 + 1
      end
      if Keyan_Posuilingyu then
        run = false
      end
      if run then
        if rel or u:isalive() then
          if not u:isalive() then
            HeroRelive(unit, x, y, 3)
          end
          if u:hasdata("变异判定-藤原妹红") then
            fhd:remove()
          end
          timer:remove()
        end
      else
        timer:remove()
      end
    end)
    ThingDrop(unit)
    local fordeath_b = false
    if u:hasdata("变异判定-藤原妹红") or u:hasdata("依神凭依-针妙丸") or u:hasdata("丛雨-神化") or u:ishasskill("A0HS") or u:hasdata("变异判定-信长残魂") or u:hasdata("变异判定-秋静叶") or u:hasdata("特殊判定-士郎的正义") or u:getdata("黑龙血统阶级") >= 4 or u:hasdata("礼奈-永久黑化") or u:hasdata("利姆露-契约对象") or u:hasdata("矿石病-致死") and u:hasdata("变异判定-爱国者") or u:hasdata("露娜-终焉樱解锁") or u:getdata("礼奈击杀次数") >= 3 or u:hasdata("秦心-禁忌化") and not u:hasdata("秦心复活冷却") then
      u:groupremove(Group_DeathHero)
      u:setdata("系统-永久死亡标记")
      u:sendmessage("|cFF7DBEF1你已永久死亡|r")
      ForGroupLuaNew(Group_PlayHero, function(xq)
        if xq.handle ~= u.handle and xq:hasdata("变异判定-百百") then
          xq:setdata("百百-爱哭鬼判定")
        end
      end)
      print("英雄永久死亡")
      fordeath_b = true
      if u:hasdata("变异判定-秋静叶") and not u:hasdata("秋静叶祈福") then
        u:setdata("秋静叶祈福")
        SendMsgAll("|cFFFF3300「|r|cFFEE3304秋|r|cFFDD3308天|r|cFFCC330D就|r|cFFBB3311这|r|cFFAA3315样|r|cFF99331A结|r|cFF88331E束|r|cFF773322了|r|cFF663326呢|r|cFF55332A」|r")
        for i = 1, 6 do
          ChangeValue(DamageSystem_Shjc, sy, 1.01, 1)
        end
        ForGroupLuaNew(Group_DeathHero, function(xq2)
          local x2 = GetUnitX(NPC_BAYUNZI)
          local y2 = GetUnitY(NPC_BAYUNZI)
          xq2:sendmessage("你已复活")
          HeroRelive(xq2.handle, x2, y2, 5)
        end)
      end
      if u:hasdata("变异判定-信长残魂") and not u:hasdata("信长台词") then
        u:setdata("信长台词")
        SendMsgAll("|cFF949596「人生五十载,去事恍如梦幻,天下之内,岂有长生不灭者」|r")
      end
      if u:ishasskill("A0HS") and not u:hasdata("只狼台词") then
        u:setdata("只狼台词")
        SendMsgAll("|cFFFFFF33「犹豫，就会败北」|r")
      end
      if u:hasdata("特殊判定-士郎的正义") and not u:hasdata("士郎台词") then
        u:setdata("士郎台词")
        SendMsgAll("|cFFFF3300「|r|cFFF73605我|r|cFFF0380A不|r|cFFE83B0F会|r|cFFE03D14放|r|cFFD9401A弃|r|cFFD1421F，|r|cFFC94524就|r|cFFC24729算|r|cFFBA4A2E愚|r|cFFB24C33蠢|r|cFFAB4F38也|r|cFFA3523D不|r|cFF9C5442会|r|cFF945747回|r|cFF8C594C头|r|cFF855C52…|r|cFF7D5E57…|r|cFF75615C」|r")
        ac.wait(4000, function()
          SendMsgAll("|cFFFF3300「|r|cFFFA3504这|r|cFFF43707个|r|cFFEF380B梦|r|cFFE93A0F，|r|cFFE43C12即|r|cFFDE3E16便|r|cFFD9401A到|r|cFFD3421D最|r|cFFCE4321后|r|cFFC84524我|r|cFFC34728仍|r|cFFBD492C是|r|cFFB84B2F一|r|cFFB24C33个|r|cFFAD4E37赝|r|cFFA8503A品|r|cFFA2523E也|r|cFF9D5442绝|r|cFF975645对|r|cFF925749不|r|cFF8C594D是|r|cFF875B50错|r|cFF815D54误|r|cFF7C5F57的|r|cFF76615B。|r|cFF71625F」|r")
        end)
      end
      if u:hasdata("秦心-禁忌化") and not u:hasdata("秦心复活冷却") then
        u:setdata("秦心复活冷却")
        local cs3 = 0
        ac.loop(1000, function(timer)
          cs3 = cs3 + 1
          u:groupremove(Group_DeathHero)
          if u:isalive() then
            timer:remove()
          elseif 300 <= cs3 then
            u:deldata("秦心复活冷却")
            u:sendmessage("现在可以通过常规方式复活了")
            u:groupadd(Group_DeathHero)
            timer:remove()
          end
        end)
        ForGroupLuaNew(Group_DeathHero, function(xq2)
          local x2 = GetUnitX(NPC_BAYUNZI)
          local y2 = GetUnitY(NPC_BAYUNZI)
          xq2:sendmessage("你已复活")
          HeroRelive(xq2.handle, x2, y2, 5)
        end)
      end
    else
      u:sendmessage("|cFF7DBEF1你已经死亡，等待复活", 3600)
    end
    if not fordeath_b and not Boolean_AnshenBattle and u:hasdata("诅咒-灵体化") then
      local mj = u:createunit("e000", x, y)
      mj:changeowner(u.owner)
      mj:setface(u:getface())
      local modeltext = slk.unit[ID2S(u.type)].file
      if u:hasdata("青水皮肤-茉子") then
        modeltext = "HERO\\CLMZ.mdx"
      end
      if u:hasdata("妖梦皮肤-渎白之渊") then
        modeltext = "paopao_umpf1.mdx"
      end
      japi.SetUnitModel(mj.handle, modeltext)
      mj:setcolor(255, 255, 255, 125)
      SetLinglijutuanHandle(sy, mj.handle)
      mj:triggeraddevent(Npcfuhuo02, EVENT_UNIT_SELECTED)
      TriggerRegisterUnitEvent(Trg_UnitSkill, mj.handle, EVENT_UNIT_SPELL_EFFECT)
      mj:addtrgevent("单位-发动技能", function(args)
        npcfuhuo01Trg(args.unit, args.skill)
      end)
      if u.type == HeroType["莲华"] then
        mj:addskill("A1QO")
      end
    else
    end
    local dl, fail = GameOver()
  end
end

return deathend
