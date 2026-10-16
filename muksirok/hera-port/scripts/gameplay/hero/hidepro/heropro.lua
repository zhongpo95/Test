-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local function proget(u, var)
  u:setdata("职业判定-" .. var.name)
  
  u:setdata("系统-玩家职业", var.name)
  if var.key then
    for index, value in ipairs(var.key) do
      u:changedata(value .. "变异数量", 1)
    end
  end
  SendMsgAll(u:getplayername() .. "成为了" .. var.effectname)
end

HeroPro_Lv0 = {
  {
    name = "佣兵",
    key = {},
    effect = function(u, var)
      local sy = u.ownerid
      proget(u, var)
      u:addstr(25)
      u:addstexiao("职业判定-" .. var.name, "英雄升级时效果", function(args)
        if u:getdata("系统-玩家职业") == var.name then
          u:addstr(5)
        end
      end)
    end,
    effectname = "|cFFCC0000佣兵|r",
    effecttext = "|cFFCC0000提升25力量\n提升5力量成长|r",
    effectart = "war3mapImported\\BTNPro_1_Yongbing.blp"
  },
  {
    name = "浪人",
    key = {},
    effect = function(u, var)
      local sy = u.ownerid
      proget(u, var)
      u:addagi(25)
      u:addstexiao("职业判定-" .. var.name, "英雄升级时效果", function(args)
        if u:getdata("系统-玩家职业") == var.name then
          u:addagi(5)
        end
      end)
    end,
    effectname = "|cff8bff9b浪人|r",
    effecttext = "|cff8bff9b提升25敏捷\n提升5敏捷成长|r",
    effectart = "war3mapImported\\BTNPro_1_Langren.blp"
  },
  {
    name = "学徒",
    key = {},
    effect = function(u, var)
      local sy = u.ownerid
      proget(u, var)
      u:addint(25)
      u:addstexiao("职业判定-" .. var.name, "英雄升级时效果", function(args)
        if u:getdata("系统-玩家职业") == var.name then
          u:addint(5)
        end
      end)
      if Correction_Magic_Count[sy] <= 1 then
        Correction_Magic_Count[sy] = 1
      end
    end,
    effectname = "|cff7bdaff学徒|r",
    effecttext = "|cff7bdaff提升25智力\n提升5智力成长\n法术继承≤100%时则变为100%|r",
    effectart = "war3mapImported\\BTNPro_1_Xuetu.blp"
  }
}
HeroPro_Lv1 = {
  {
    name = "骑士",
    key = {},
    before = {"佣兵"},
    effect = function(u, var)
      local sy = u.ownerid
      proget(u, var)
      local hp = 0
      ac.loop(3000, function()
        ChangeValue(HeroMenu_HpChange_Inr, sy, -1 * hp)
        hp = 0.02 * u:getstr()
        ChangeValue(HeroMenu_HpChange_Inr, sy, 1 * hp)
      end)
      u:addstr(100)
      u:changearmor(20)
      u:addstexiao("职业判定-" .. var.name, "英雄升级时效果", function(args)
        if u:getdata("系统-玩家职业") == var.name then
          u:addstr(10)
          u:changearmor(2)
        end
      end)
    end,
    effectname = "|cFFFFFF33骑士|r",
    effecttext = "|cFFFFFF33提升[力量*0.02]生命恢复\n提升100力量与20护甲\n提升10力量成长与2护甲成长|r",
    effectart = "war3mapImported\\BTNPro_2_Qishi.blp"
  },
  {
    name = "战士",
    key = {},
    before = {"佣兵"},
    effect = function(u, var)
      local sy = u.ownerid
      proget(u, var)
      u:changedata("固定格挡", 200)
      u:changedata("固定伤害", 500.0)
      u:addstr(100)
      u:addstexiao("职业判定-" .. var.name, "英雄升级时效果", function(args)
        if u:getdata("系统-玩家职业") == var.name then
          u:addstr(10)
          u:changedata("固定伤害", 50.0)
        end
      end)
    end,
    effectname = "|cFFFF6666战士|r",
    effecttext = "|cFFFF6666提升200固定格挡\n提升100力量与500固定伤害\n提升10力量成长与50固定伤害成长|r",
    effectart = "war3mapImported\\BTNPro_2_Zhanshi.blp"
  },
  {
    name = "武士",
    key = {},
    before = {"浪人"},
    effect = function(u, var)
      local sy = u.ownerid
      proget(u, var)
      u:changedata("近战机体-基础伤害提升", 5000)
      ChangeValue(Correction_Jzsh, sy, 0.05)
      u:addagi(100)
      u:addstexiao("职业判定-" .. var.name, "英雄升级时效果", function(args)
        if u:getdata("系统-玩家职业") == var.name then
          u:addagi(10)
          ChangeValue(Correction_Jzsh, sy, 0.005000000000000001)
        end
      end)
    end,
    effectname = "|cFF99FFCC武士|r",
    effecttext = "|cFF99FFCC提升5000近战基础伤害与近战武器基础伤害\n提升100敏捷与5%近战伤害\n提升10敏捷成长与0.5%近战伤害成长|r",
    effectart = "war3mapImported\\BTNPro_2_Wushi.blp"
  },
  {
    name = "猎手",
    key = {},
    before = {"浪人"},
    effect = function(u, var)
      local sy = u.ownerid
      proget(u, var)
      ChangeValue(Correction_RPM, sy, 0.15)
      ChangeValue(Correction_Gun, sy, 0.05)
      u:addagi(100)
      u:addstexiao("职业判定-" .. var.name, "英雄升级时效果", function(args)
        if u:getdata("系统-玩家职业") == var.name then
          u:addagi(10)
          ChangeValue(Correction_Gun, sy, 0.005000000000000001)
        end
      end)
    end,
    effectname = "|cFF66FF99猎手|r",
    effecttext = "|cFF66FF99提升15%RPM\n提升100敏捷与5%枪械伤害\n提升10敏捷成长与0.5%枪械伤害成长|r",
    effectart = "war3mapImported\\BTNPro_2_Lieshou.blp"
  },
  {
    name = "盗贼",
    key = {},
    before = {"佣兵", "浪人"},
    effect = function(u, var)
      local sy = u.ownerid
      proget(u, var)
      ChangeValue(DamageSystem_Baoji, sy, 10)
      ChangeValue(DamageSystem_Baoshang, sy, 0.1)
      u:addstr(50)
      u:addagi(50)
      u:addstexiao("职业判定-" .. var.name, "英雄升级时效果", function(args)
        if u:getdata("系统-玩家职业") == var.name then
          u:addstr(5)
          u:addagi(5)
          ChangeValue(DamageSystem_Baoshang, sy, 0.01)
        end
      end)
    end,
    effectname = "|cFF6699CC盗贼|r",
    effecttext = "|cFF6699CC提升10%暴击率\n提升10%暴击伤害\n提升50敏捷\n提升50力量\n提升5力量成长,5敏捷成长与1%暴击伤害成长|r",
    effectart = "war3mapImported\\BTNPro_2_Daozei.blp"
  },
  {
    name = "魔法师",
    key = {},
    before = {"学徒"},
    effect = function(u, var)
      local sy = u.ownerid
      proget(u, var)
      u:changemaxmp(25)
      u:changedata("魔力值", 5000)
      u:addint(100)
      u:addstexiao("职业判定-" .. var.name, "英雄升级时效果", function(args)
        if u:getdata("系统-玩家职业") == var.name then
          u:changedata("魔力值", 500)
          u:addint(10)
        end
      end)
    end,
    effectname = "|cFF3399FF魔法师|r",
    effecttext = "|cFF3399FF提升25魔力上限\n提升100智力与5000魔力值\n提升10智力成长与500魔力值成长|r",
    effectart = "war3mapImported\\BTNPro_2_Mofashi.blp"
  },
  {
    name = "学者",
    key = {},
    before = {"学徒"},
    effect = function(u, var)
      local sy = u.ownerid
      proget(u, var)
      ChangeValue(HeroMenu_MpCure_MaxMp, sy, 1)
      ChangeValue(Correction_Exp, sy, 0.2)
      u:addint(100)
      u:addstexiao("职业判定-" .. var.name, "英雄升级时效果", function(args)
        if u:getdata("系统-玩家职业") == var.name then
          ChangeValue(Correction_Exp, sy, 0.02)
          u:addint(10)
        end
      end)
    end,
    effectname = "|cFF3399FF学者|r",
    effecttext = "|cFF3399FF提升1%魔力恢复\n提升100智力与20%经验获取\n提升10智力成长与2%经验获取成长|r",
    effectart = "war3mapImported\\BTNPro_2_Xuezhe.blp"
  },
  {
    name = "术士",
    key = {},
    before = {"学徒"},
    effect = function(u, var)
      local sy = u.ownerid
      proget(u, var)
      ChangeValue(Correction_Magic_Count, sy, 0.25)
      ChangeValue(Correction_Magic, sy, 0.005000000000000001)
      u:addint(100)
      u:addstexiao("职业判定-" .. var.name, "英雄升级时效果", function(args)
        if u:getdata("系统-玩家职业") == var.name then
          ChangeValue(Correction_Magic, sy, 5.0E-4)
          u:addint(10)
        end
      end)
    end,
    effectname = "|cFFCC3366术士|r",
    effecttext = "|cFFCC3366提升25%法术伤害继承\n提升100智力与50%法术伤害\n提升10智力成长与5%法术伤害成长|r",
    effectart = "war3mapImported\\BTNPro_2_Shushi.blp"
  },
  {
    name = "女巫",
    key = {},
    before = {"学徒"},
    effect = function(u, var)
      local sy = u.ownerid
      proget(u, var)
      ChangeValue(DamageSystem_Shjc, sy, 0.05)
      u:addallstats(50)
      u:addstexiao("职业判定-" .. var.name, "英雄升级时效果", function(args)
        if u:getdata("系统-玩家职业") == var.name then
          ChangeValue(DamageSystem_Shjc, sy, 0.005)
          u:addallstats(5)
        end
      end)
    end,
    effectname = "|cFFCC99FF女巫|r",
    effecttext = "|cFFCC99FF提升50全属性与5%伤害加成\n提升5全属性成长与0.5%伤害加成|r",
    effectart = "war3mapImported\\BTNPro_2_Nvwu.blp"
  }
}
HeroPro_Lv1_Hide = {
  {
    name = "救世主",
    key = {
      "光明",
      "黑暗",
      "战士",
      "唯一"
    },
    before = {"佣兵", "浪人"},
    glfunc = function(u, var)
      local gl = 1
      if u:hasdata("血统判定-英雄") then
        gl = gl + 10
      end
      if u:hasdata("变异判定-戈登") then
        gl = gl + 10
      end
      return gl
    end,
    effect = function(u, var)
      local sy = u.ownerid
      proget(u, var)
      var.hasbeenget = true
      ChangeValue(KillReward_MHp, sy, 1)
      u:addstr(200)
      u:addagi(200)
      ChangeValue(DamageSystem_Baoji, sy, 22)
      ChangeValue(DamageSystem_Baoshang, sy, 0.44)
      u:changearmor(33)
      u:addstexiao("职业判定-" .. var.name, "英雄升级时效果", function(args)
        if u:hasdata("职业判定-" .. var.name) then
          u:addstr(20)
          u:addagi(20)
        end
      end)
      local add = 0
      ac.loop(3000, function()
        u:changedata("固定伤害", 0.1 * -add)
        add = 11 * u:getallattri()
        u:changedata("固定伤害", 0.1 * add)
      end)
      SetTimeOfDay(0)
      local x, y = u:getxy()
      local jd = GetRandomAngle()
      local jd2 = u:getface()
      Effectcreate("Abilities\\Spells\\Human\\Resurrect\\ResurrectCaster.mdl", x, y, 60, 5, 0, jd2, 0, 0, 0.05)
      Effectcreate("war3mapImported\\[TX] (148).mdl", x, y, 0, 2)
      local ttt = 56
      ac.timer(4000, 12, function()
        jd = jd + 30
        local xx, yy = PolarXY(x, y, 600, jd)
        Effectcreate("war3mapImported\\174.mdl", xx, yy, ttt, 3)
        ttt = ttt - 4
      end)
      local cs = 0
      ac.loop(250, function(timer)
        cs = cs + 1
        x, y = u:getxy()
        u:sethp(100, true)
        for _, xq in ac.selector():in_rangexy(x, y, 3000):is_enemy(u.handle):ipairs() do
          xq = getunit(xq)
          xq:animespeed(0)
          xq:buffset(u.handle, 1, "暂停")
        end
        if cs == 280 then
          for _, xq in ac.selector():in_rangexy(x, y, 3000):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:animespeed(1)
          end
          timer:remove()
        end
      end)
      PlayBGM({
        bgm = BGM_Pro_Jsz,
        time = 80,
        ID = 14,
        unit = u.handle
      })
      u:buffset(u.handle, 60, "无敌")
      ac.timer(1000, 55, function()
        u:buffset(u.handle, 1.5, "暂停")
        u:buffset(u.handle, 1.5, "绝对闪避")
      end)
      songtext({
        text = {
          {
            starttime = 0,
            str = "Shadows fall and Hope has fled",
            time = 9.5
          },
          {
            starttime = 9.5,
            str = "Steel your heart"
          },
          {
            starttime = 12.5,
            str = "The Dawn will come"
          },
          {
            starttime = 17,
            str = "The Night is long and the Path is dark"
          },
          {
            starttime = 25,
            str = "Look to the sky, for one day soon"
          },
          {
            starttime = 33.5,
            str = "The Dawn will Come"
          },
          {
            starttime = 37.8,
            str = "The Shepherds lost and his Home is far"
          },
          {
            starttime = 46.9,
            str = "Keep to the stars"
          },
          {
            starttime = 50.5,
            str = "The Dawn will come"
          },
          {
            starttime = 55.2,
            str = "The Night is long and the Path is dark"
          },
          {
            starttime = 63,
            str = "Look to the sky, for one day soon"
          },
          {
            starttime = 71.7,
            str = "The Dawn will Come",
            time = 4
          }
        },
        color = "FF804C4C"
      })
    end,
    effectname = "|cFF666666救|r|cFF804C4C世|r|cFF993333主|r",
    effecttext = "|cFFFFCC00[隐藏职业]|r\n|cFF666666光明 黑暗 战士 唯一\n杀敌时提升1生命上限\n杀敌时8%提升1力量\n杀敌时8%提升1敏捷|r\n|cFF804C4C提升200力量与200敏捷\n提升20力量成长与20敏捷成长|r\n|cFF993333提升22%暴击率\n提升33护甲\n提升44%暴击伤害\n提升[全属性*1.1]固定伤害|r",
    effectart = "war3mapImported\\PASBTNPro_4_Jiushizhu.blp"
  },
  {
    name = "阿库娅",
    key = {
      "光明",
      "歌姬",
      "唯一"
    },
    before = {"学徒"},
    glfunc = function(u, var)
      local gl = 1
      if u:hasdata("血统判定-天使") then
        gl = gl + 5
      end
      if u:hasdata("特典-天之少女-女主") then
        gl = gl + 10
      end
      return gl
    end,
    effect = function(u, var)
      local sy = u.ownerid
      proget(u, var)
      var.hasbeenget = true
      u:getgoddessforce(3, true)
      u:chat("|cFF0099FF「|r|cFF0C9EFA和|r|cFF17A2F6你|r|cFF23A7F1一|r|cFF2EACEC起|r|cFF3AB0E8续|r|cFF46B5E3写|r|cFF51B9DF这|r|cFF5DBEDA首|r|cFF68C3D5歌|r|cFF74C7D1，|r|cFF80CCCC开|r|cFF8BD1C7创|r|cFF97D5C3世|r|cFFA2DABE界|r|cFFAEDFB9的|r|cFFB9E3B5未|r|cFFC5E8B0来|r|cFFD1ECAC…|r|cFFDCF1A7…|r|cFFE8F6A2」|r")
      u:addallstats(100)
      u:addint(100)
      u:addstexiao("职业判定-" .. var.name, "英雄升级时效果", function(args)
        if u:hasdata("职业判定-" .. var.name) then
          u:addallstats(10)
          u:addint(10)
          if GetRandom100(25) then
            u:addlevel(-1)
          end
        end
      end)
      u:addskill("A0OT")
      ac.loop(1000, function()
        if u:isalive() and Group_Counts(Group_Xingcunzu) == 1 and not u:hasdata("祝福的音冷却") then
          u:sendmessage("|cFF6699FF阿库娅-祝福的音|r")
          u:settimedata("祝福的音冷却", 1200)
          ac.wait(1200000, function()
            u:sendmessage("|cFF6699FF祝福の音冷却完毕")
          end)
          PlayBGM({
            bgm = BGM_Pro_Azura,
            time = 130,
            ID = 15,
            unit = u.handle
          })
          local x, y = u:getxy()
          ForGroupLuaNew(Group_DeathHero, function(xq)
            HeroRelive(xq.handle, x, y, 3)
          end)
        end
      end)
      u:settimedata("祝福的音冷却", 1200)
      ac.wait(1200000, function()
        u:sendmessage("|cFF6699FF祝福の音冷却完毕")
      end)
      u:settimedata("阿库娅-祝福的音", 130)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:settimedata("阿库娅-和平之声", 130)
      end)
      PlayBGM({
        bgm = BGM_Pro_Azura,
        time = 130,
        ID = 15,
        unit = u.handle
      })
      ac.loop(10000, function()
        local fw = 2000
        if u:hasdata("阿库娅-祝福的音") then
          fw = 20000
        end
        ForGroupLuaNew(Group_PlayHero, function(xq)
          local dis = DistanceBetweenUnits(xq.handle, u.handle)
          if dis <= fw then
            xq:settimedata("治愈之声强化", 1)
            xq:curehp(u.handle, 0, 10, 1)
          end
        end)
      end)
    end,
    effectname = "|cFF99CCFF阿|r|cFF73BFFF库|r|cFF4CB2FF娅|r",
    effecttext = "|cFFFFCC00[隐藏职业]|r\n|cFF0099FF神性 0\n光明 歌姬 唯一\n天之公主|r\n|cFF99CCFF升级时25%降低1级\n提升100全属性与100智力\n提升10全属性成长与10智力成长|r\n|cFF0099FF治愈之声|r\n|cFF99CCFF每隔10秒使自身周围2000范围内友军在1秒内免疫生命抑制并恢复10%最大生命值|r\n|cFF0099FF和平之声|r\n|cFF99CCFF提升自身与周围2000范围友军20%受伤减少与10%终结减伤|r\n|cFF0099FF祝福の音|r\n|cFF99CCFF[数据删除]|r",
    effectart = "war3mapImported\\PASBTNPro_4_Azura.blp"
  }
}
HeroPro_Hide = {
  {
    name = "刀姬",
    key = {"唯一"},
    effect = function(u, var)
      local sy = u.ownerid
      proget(u, var)
      Weiyi_Pro[1] = true
      u:setdata("职业判定-刀姬")
      u:addallstats(25)
      u:addstexiao("职业判定-刀姬", "英雄升级时效果", function(args)
        u:changedata("刀计数", 1)
        if u:getdata("系统-玩家职业") == var.name then
          u:addallstats(5)
        end
      end)
      u:setdata("刀计数", 1)
      ac.loop(10000, function(t)
        if u:getdata("刀计数") >= 40 then
          u:addstexiao("职业判定-闪刀姬", "直接伤害特效", function(args)
            local tg = args.tg
            local u = args.u
            local info = args.damageinfo
            if u:getluckrandom(5 * info.txgl) and not u:hasdata("职业判定-刀姬" .. "-炎刀特效冷却") then
              local x, y = tg:getxy()
              u:settimedata("职业判定-刀姬" .. "-炎刀特效冷却", 1)
              Effectcreate("war3mapImported\\[TX] (327).mdl", x, y)
              local txsh = 750 * u:getdata("刀计数")
              for _, xq in ac.selector():in_rangexy(x, y, 300):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                DamageUnit({
                  bj = "闪刀姬炎",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 1,
                  type = "物理",
                  isvest = true,
                  isattack = true,
                  isnoarmor = false,
                  element = "火"
                })
              end
            end
          end)
          u:addstexiao("职业判定-闪刀姬", "近战伤害效果", function(args)
            local tg = args.tg
            if u:hasdata("闪刀姬-炎") then
              if args.element == "无" then
                args.element = "火"
              end
              if GetRandom100(5) then
                args.level = 5
              end
            end
            if u:hasdata("闪刀姬-风") and args.element == "无" then
              args.element = "风"
            end
            if u:hasdata("闪刀姬-水") and args.element == "无" then
              args.element = "水"
            end
            if u:hasdata("闪刀姬-暗") then
              if args.element == "无" then
                args.element = "暗"
              end
              if tg:isnormal() then
                local jl
                if tg:hasdata("隐藏职业-天谴之子") then
                  jl = 5
                else
                  jl = 2.5
                end
                if GetRandom100(jl) then
                  tg:effectadd("war3mapImported\\[TX] (1337).mdl")
                  tg:kill(u.handle)
                end
              end
            end
          end)
          PlayBGM({
            bgm = BGM_Shandaoji,
            time = 60,
            ID = 45,
            unit = u.handle
          })
          u:settimedata("闪刀姬-吟唱", 60)
          u:deldata("职业判定-刀姬")
          u:setdata("职业判定-闪刀姬")
          u:uivar_change({
            keyname = "职业图标",
            keytype = "传奇栏",
            text = "|cFFFF0000闪|r|cFFCC0D33刀|r|cFF991A66姬|r\n|cFFFF0000杀死单位时提升0.01%近战伤害修正\n每级提升1点刀计数,初始1点\n提升[刀计数*1]点全属性\n杀死精英单位时提升1点计数\n杀死BOSS时提升5点计数|r\n|cFFCC0D33获得切换形态能力,1秒冷却|r\n|cFFCC0000[炎]|r|cFFCC6600[地]|r|cFFCCFFFF[风]|r|cFF6699FF[水]|r|cFF660066[暗]|r",
            icon = "war3mapImported\\PASBTNPro_4_Shandaoji.blp"
          })
          SendMsgAll("|cFFFF0000「|r|cFFF60006凡|r|cFFEE000D人|r|cFFE50013，|r|cFFDD001A你|r|cFFD40020以|r|cFFCB0026后|r|cFFC3002D只|r|cFFBA0033要|r|cFFB2003A看|r|cFFA90040着|r|cFFA00046我|r|cFF98004D一|r|cFF8F0053个|r|cFF87005A人|r|cFF7E0060就|r|cFF750066够|r|cFF6D006D了|r|cFF640073」|r")
          PlayGlobalSound(Sound_Pro_Shandaoji)
          ac.wait(100, function()
            u:effectadd("war3mapImported\\[TX] (985).mdl")
          end)
          ac.wait(250, function()
            u:effectadd("war3mapImported\\[TX] (780).mdl")
          end)
          ac.wait(500, function()
            u:effectadd("war3mapImported\\[TX] (986).mdl")
          end)
          ac.wait(750, function()
            u:effectadd("war3mapImported\\[ake]war3ake.com - 1709800651073528605518801.mdl")
          end)
          ac.wait(1000, function()
            u:effectadd("war3mapImported\\[TX] (988).mdl")
          end)
          local xt = {
            {
              name = "炎",
              color = "CC0000",
              text = "|cFFCC0000炎：\n提升25%火属性伤害\n提升15%受伤减少\n提升[刀计数*0.01%]医疗恢复\n提升[刀计数*1.5]额外移速\n提升[刀计数*0.01]体力恢复\n提升12%暴击率\n提升[刀计数*0.5]%暴击伤害\n直接伤害时5%对300范围附带[刀计数*750]近战物理伤害\n近战无属性伤害变为火属性伤害\n近战伤害5%变为抹除伤害|r",
              func = function(self, u)
                local sy = u.ownerid
                u:effectadd("war3mapImported\\[TX] (985).mdl")
                ChangeValue(DamageSystem_Baoji, sy, 12)
                ChangeValue(DamageSystem_Ssjianshao, sy, 0.85, 1)
                ChangeValue(Damage_Element_Fire, sy, 0.25)
                local zs = u:getdata("刀计数")
                local ewys = 1.5 * zs
                local bjsh = 0.005 * zs
                local tlhf = 0.01 * zs
                ChangeValue(DamageSystem_Baoshang, sy, 1 * bjsh)
                ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 1 * ewys)
                ChangeValue(Hero_Tili_Huifu, sy, 1 * tlhf)
                ac.loop(3000, function(timer)
                  ChangeValue(DamageSystem_Baoshang, sy, -1 * bjsh)
                  ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -1 * ewys)
                  ChangeValue(Hero_Tili_Huifu, sy, -1 * tlhf)
                  local zs = u:getdata("刀计数")
                  ewys = 1.5 * zs
                  bjsh = 0.005 * zs
                  tlhf = 0.01 * zs
                  ChangeValue(DamageSystem_Baoshang, sy, 1 * bjsh)
                  ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 1 * ewys)
                  ChangeValue(Hero_Tili_Huifu, sy, 1 * tlhf)
                  if not u:hasdata("闪刀姬-" .. self.name) then
                    ChangeValue(DamageSystem_Baoshang, sy, -1 * bjsh)
                    ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -1 * ewys)
                    ChangeValue(Hero_Tili_Huifu, sy, -1 * tlhf)
                    ChangeValue(Damage_Element_Fire, sy, -0.25)
                    ChangeValue(DamageSystem_Baoji, sy, -12)
                    ChangeValue(DamageSystem_Ssjianshao, sy, 0.85, 2)
                    timer:remove()
                  end
                end)
              end
            },
            {
              name = "地",
              color = "CC6600",
              text = "|cFFCC6600地：\n提升50%受伤减少\n提升[25+刀计数*2]护甲\n每隔5秒清除自身负面状态,包括僵直与眩晕|r",
              func = function(self, u)
                local sy = u.ownerid
                u:effectadd("war3mapImported\\[TX] (780).mdl")
                ChangeValue(DamageSystem_Ssjianshao, sy, 0.5, 1)
                local zs = u:getdata("刀计数")
                local hj = 25 + 2 * zs
                u:changearmor(1 * hj)
                ac.loop(5000, function(timer)
                  u:changearmor(-1 * hj)
                  local zs = u:getdata("刀计数")
                  hj = 25 + 2 * zs
                  u:changearmor(1 * hj)
                  u:clearbuff()
                  u:clearbuff("僵直")
                  u:clearbuff("眩晕")
                  if not u:hasdata("闪刀姬-" .. self.name) then
                    u:changearmor(-1 * hj)
                    ChangeValue(DamageSystem_Ssjianshao, sy, 0.5, 2)
                    timer:remove()
                  end
                end)
              end
            },
            {
              name = "风",
              color = "CCFFFF",
              text = "|cFFCCFFFF风：\n提升25%风属性伤害\n提升[5+刀计数*5]额外移速\n提升[10+刀计数*1]闪避值\n提升0.1闪避系数\n近战无属性伤害变为风属性伤害|r",
              func = function(self, u)
                local sy = u.ownerid
                u:effectadd("war3mapImported\\[TX] (986).mdl")
                ChangeValue(HeroMenu_Sbxs, sy, 0.1)
                ChangeValue(Damage_Element_Wind, sy, 0.25)
                local zs = u:getdata("刀计数")
                local ewys = 50 + 5 * zs
                local sbz = 10 + 1 * zs
                ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 1 * ewys)
                u:changedata("闪避值", 1 * sbz)
                ac.loop(3000, function(timer)
                  ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -1 * ewys)
                  u:changedata("闪避值", -1 * sbz)
                  local zs = u:getdata("刀计数")
                  ewys = 50 + 5 * zs
                  sbz = 10 + 1 * zs
                  ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 1 * ewys)
                  u:changedata("闪避值", 1 * sbz)
                  if not u:hasdata("闪刀姬-" .. self.name) then
                    u:changedata("闪避值", -1 * sbz)
                    ChangeValue(Damage_Element_Wind, sy, -0.25)
                    ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -1 * ewys)
                    ChangeValue(HeroMenu_Sbxs, sy, -0.1)
                    timer:remove()
                  end
                end)
              end
            },
            {
              name = "水",
              color = "6699FF",
              text = "|cFF6699FF水：\n提升25%水属性伤害\n提升[0.5%+刀计数*0.01%]医疗恢复\n提升[0.5+刀计数*0.02]体力恢复\n受到伤害时25%无视该次伤害并反弹[刀计数*1000]物理近战纯粹伤害\n近战无属性伤害变为水属性伤害|r",
              func = function(self, u)
                local sy = u.ownerid
                u:effectadd("war3mapImported\\[ake]war3ake.com - 1709800651073528605518801.mdl")
                ChangeValue(Damage_Element_Water, sy, 0.25)
                local zs = u:getdata("刀计数")
                local hp = 2 + 0.08 * zs
                local tlhf = 0.5 + 0.01 * zs
                ChangeValue(Hero_Tili_Huifu, sy, 1 * tlhf)
                ChangeValue(HeroMenu_HpCure_MaxHp, sy, 1 * hp)
                ac.loop(3000, function(timer)
                  ChangeValue(Hero_Tili_Huifu, sy, -1 * tlhf)
                  ChangeValue(HeroMenu_HpCure_MaxHp, sy, -1 * hp)
                  local zs = u:getdata("刀计数")
                  hp = 2 + 0.08 * zs
                  tlhf = 0.5 + 0.01 * zs
                  ChangeValue(Hero_Tili_Huifu, sy, 1 * tlhf)
                  ChangeValue(HeroMenu_HpCure_MaxHp, sy, 1 * hp)
                  if not u:hasdata("闪刀姬-" .. self.name) then
                    ChangeValue(Hero_Tili_Huifu, sy, -1 * tlhf)
                    ChangeValue(HeroMenu_HpCure_MaxHp, sy, -1 * hp)
                    ChangeValue(Damage_Element_Water, sy, -0.25)
                    timer:remove()
                  end
                end)
              end
            },
            {
              name = "暗",
              color = "660066",
              text = "|cFF660066暗：\n提升25%暗属性伤害\n提升20%暴击率\n提升[15+刀计数*0.6]%暴击伤害\n提升0.1超暴系数\n近战伤害2.5%即死普通单位\n近战无属性伤害变为暗属性伤害|r",
              func = function(self, u)
                local sy = u.ownerid
                u:effectadd("war3mapImported\\[ake]war3ake.com - 1709800651073528605518801.mdl")
                ChangeValue(Damage_Element_Dark, sy, 0.25)
                ChangeValue(DamageSystem_Baoji, sy, 20)
                ChangeValue(Correction_Cbxs, sy, 0.1)
                local zs = u:getdata("刀计数")
                local bjsh = 0.2 + 0.008 * zs
                ChangeValue(DamageSystem_Baoshang, sy, 1 * bjsh)
                ac.loop(3000, function(timer)
                  ChangeValue(DamageSystem_Baoshang, sy, -1 * bjsh)
                  local zs = u:getdata("刀计数")
                  bjsh = 0.15 + 0.006 * zs
                  ChangeValue(DamageSystem_Baoshang, sy, 1 * bjsh)
                  if not u:hasdata("闪刀姬-" .. self.name) then
                    ChangeValue(DamageSystem_Baoshang, sy, -1 * bjsh)
                    ChangeValue(DamageSystem_Baoji, sy, -20)
                    ChangeValue(Correction_Cbxs, sy, -0.1)
                    ChangeValue(Damage_Element_Dark, sy, -0.25)
                    timer:remove()
                  end
                end)
              end
            }
          }
          u:setdata("闪刀姬-当前形态", 0)
          AddUISkill({
            text = "闪刀姬-形态切换",
            u = u,
            cd = 1,
            icon = "war3mapImported\\PASBTNPro_4_Shandaoji.blp",
            func = function(args)
              local u = args.u
              if u:isalive() then
                for index, value in ipairs(xt) do
                  u:deldata("闪刀姬-" .. value.name)
                end
                u:changedata("闪刀姬-当前形态", 1)
                if u:getdata("闪刀姬-当前形态") > #xt then
                  u:setdata("闪刀姬-当前形态", 1)
                end
                local count = u:getdata("闪刀姬-当前形态")
                u:setdata("闪刀姬-" .. xt[count].name)
                u:sendmessage("|cFF" .. xt[count].color .. "切换至[" .. xt[count].name .. "]形态|r")
                xt[count]:func(u)
                u:sendmessage(xt[count].text)
              end
            end
          })
          t:remove()
        end
      end)
    end,
    effectname = "|cFF6699FF刀姬|r",
    effecttext = "|cFF6699FF杀敌时提升0.01%近战伤害\n提升25全属性\n提升5全属性成长\n每级提升1点刀计数,初始1点\n杀死精英单位时提升1点计数\n杀死BOSS时提升5点计数\n累积刀计数达到40点时解锁形态切换|r",
    effectart = "war3mapImported\\BTNPro_1_Daoji.blp"
  },
  {
    name = "落难旅人",
    key = {},
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("职业判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao("职业判定-" .. var.name, "英雄升级时效果", function(args)
        if u:hasdata("职业判定-" .. var.name) then
          u:addallstats(1)
        end
      end)
    end,
    effectname = "|cFFFF6600落难旅人|r",
    effecttext = "|cFFFF6600升级时提升1点全属性\n药水失败时提升1点失败值\n药水失败时[10%+0.1%*失败值]随机提升自身1点属性（上限50%）\n药水失败时降低[0.01%*失败值]抗药性（上限1%）\n药水失败时[5%+0.05%*失败值]随机获得一瓶药水(上限30%)\n每开启15个特殊补给箱随机获得一瓶药水\n累积达到175点失败值时允许再次神化|r",
    effectart = "war3mapImported\\BTNPro_2_Luonanlvren.blp"
  }
}
