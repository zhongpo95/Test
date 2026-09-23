-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local slk = require("jass.slk")
local removezuzhou = {
  "髑髅饥",
  "胧车面",
  "天狗相",
  "土蛛毒",
  "妖狐咒",
  "憎恶荆棘",
  "血武士",
  "虚无咒文",
  "王家诅咒",
  "雾隐恶魔",
  "技能抽取",
  "血之刻印",
  "破坏欲"
}

local function arkt_nailuosha(u, tg)
  u:buffset(u.handle, 20, "暂停")
  tg:buffset(u.handle, 22, "暂停")
  Qiyue_Nailuo_Yuanye = u.handle
  Qiyue_Nailuo_Gongzhu = tg.handle
  local sy = u.ownerid
  local sy2 = tg.ownerid
  local x, y = u:getxy()
  local x2, y2 = tg:getxy()
  NameID[sy] = "|cFF3366FF远|r|cFF5C85CC野|r|cFF85A399志|r|cFFADC266贵|r"
  u:setplayername(NameID[sy])
  Movie_Boolean = true
  ForGroupLuaNew(Group_PlayHero, function(xq)
    xq:buffset(u.handle, 22, "无敌")
  end)
  ac.timer(1000, 22, function()
    ForGroupLuaNew(Group_Monster, function(xq)
      xq:buffset(u.handle, 2, "暂停")
    end)
  end)
  u:deldata("奈落杀可能")
  local time = GetTimeOfDay()
  u:chat("直死魔眼")
  PlayGlobalSound(Sound_Yuanye_CD004)
  ac.wait(2000, function()
    PlayGlobalSound(BGM_Yuanye_1)
  end)
  ac.wait(4000, function()
    PlayGlobalSound(Sound_Yuanye_CD023)
    SetTimeOfDay(12)
    SetDayNightModels("Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdx", "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdx")
    DayNightRun = false
    flashphoto({
      photo = "war3mapImported\\Yuanye_P1.blp",
      timeout = 0,
      timehold = 0,
      timein = 0,
      notchangetime = true
    })
    Effectcreate("war3mapImported\\Rain_xueying.mdx", x, y, 60, 1.5)
    Effectcreate("war3mapImported\\Rain_xueying.mdx", x2, y2, 60, 1.5)
  end)
  ac.wait(7000, function()
    PlayGlobalSound(Sound_Yuanye_CD023)
    flashphoto({
      photo = "war3mapImported\\Yuanye_P2.blp",
      timeout = 0,
      timehold = 0,
      timein = 0,
      notchangetime = true
    })
  end)
  ac.wait(10000, function()
    PlayGlobalSound(Sound_Yuanye_CD023)
    flashphoto({
      photo = "war3mapImported\\Yuanye_P3.blp",
      timeout = 0,
      timehold = 0,
      timein = 0,
      notchangetime = true
    })
  end)
  ac.wait(13000, function()
    PlayGlobalSound(Sound_Yuanye_CD023)
    flashphoto({
      photo = "war3mapImported\\Yuanye_P4.blp",
      timeout = 0,
      timehold = 0,
      timein = 0,
      notchangetime = true
    })
  end)
  ac.wait(14000, function()
    PlayGlobalSound(Sound_Yuanye_CD023)
    flashphoto({
      photo = "war3mapImported\\Yuanye_P5.blp",
      timeout = 0,
      timehold = 0,
      timein = 0,
      notchangetime = true
    })
  end)
  ac.wait(15000, function()
    PlayGlobalSound(Sound_Yuanye_CD023)
    PlayGlobalSound(Sound_Yuanye_CD022)
    flashphoto({
      photo = "ReplaceableTextures\\CameraMasks\\Black_mask.blp",
      timeout = 0,
      timehold = 0,
      timein = 0,
      notchangetime = true
    })
  end)
  ac.wait(17500, function()
    PlayGlobalSound(Sound_Yuanye_CD003)
    PlayGlobalSound(Sound_Yuanye_CD020)
    PlayBGM({
      bgm = BGM_Yuanye_2,
      time = 0,
      ID = 0
    })
    flashphoto({
      photo = "war3mapImported\\Yuanye_P6.blp",
      timeout = 0,
      timehold = 1,
      timein = 2,
      notchangetime = true
    })
    u:chat("真是毫无色彩的人生啊")
    ac.wait(2800, function()
      SetTimeOfDay(time)
      DayNightRun = true
    end)
    ForGroupLuaNew(Group_Monster, function(xq)
      xq:animespeed(0)
    end)
  end)
  ac.wait(21000, function()
    PlayGlobalSound(Sound_Yuanye_CD000)
    PlayGlobalSound(Sound_Yuanye_CD021)
    u:chat("消逝吧")
    ForGroupLuaNew(Group_Monster, function(xq)
      xq:animespeed(1)
      xq:effectadd("war3mapImported\\texiao_xuebao.mdx")
      xq:kill(u.handle, true)
    end)
    Movie_Boolean = false
  end)
  songtext({
    text = {
      {
        starttime = 17.5,
        str = "挣脱 尽力挣脱吧"
      },
      {
        starttime = 22,
        str = "逃离这场太过悲惨的命运"
      },
      {
        starttime = 27,
        str = "你并非注定属于奈落的花"
      },
      {
        starttime = 33,
        str = "别在那片阴暗的国度"
      },
      {
        starttime = 35,
        str = "绽放 又一轮绽放"
      },
      {
        starttime = 39.5,
        str = "然后身心被牢牢束缚"
      },
      {
        starttime = 45.7,
        str = "一段段破碎的时光 悄然纷飞",
        time = 6
      }
    },
    color = "FFCC0000"
  })
  ac.wait(21000, function()
    tg:effectadd("war3mapImported\\texiao_xuebao.mdx")
    tg:setdata("跳过复活")
    tg:kill()
  end)
  ac.wait(30000, function()
    tg:deldata("跳过复活")
    NameID[sy2] = "|cFFFFFF00爱|r|cFFD6E033尔|r|cFFADC266奎|r|cFF85A399特|r"
    tg:setplayername(NameID[sy2])
    x, y = u:getxy()
    HeroRelive(tg.handle, x, y, 3)
  end)
  u:setdata("奈落の羁绊")
  tg:setdata("奈落の羁绊")
  u:setdata("变异判定-奈落の花")
  ChangeValue(DamageSystem_EndSh, sy, 0.007000000000000001)
  ChangeValue(DamageSystem_Shjc, sy, 0.017)
  local by = CreateFogModifierRect(u.owner, FOG_OF_WAR_VISIBLE, RECT_PlayArea, false, false)
  ac.loop(1000, function()
    if IsTimeNight() then
      FogModifierStart(by)
    else
      FogModifierStop(by)
    end
  end)
  PlayBGM({
    bgm = 0,
    time = 70,
    ID = 13,
    unit = u.handle
  })
  PlayBGM({
    bgm = 0,
    time = 70,
    ID = 13,
    unit = tg.handle
  })
  SetSoundVolume(BGM_Aierkuite_01, 0)
  SetSoundVolume(BGM_Yuanye_01, 0)
  ac.wait(70000, function()
    SetSoundVolume(BGM_Aierkuite_01, 127)
    SetSoundVolume(BGM_Yuanye_01, 127)
  end)
  u:uivar_add({
    keyname = "奈落の花",
    keytype = "传奇栏",
    text = "|cFF3366FF奈|r|cFF5C85D6落|r|cFF85A3ADの|r|cFFADC285花|r\n|cFF5C85D6视野范围扩大至全图\n夜晚时获得全图视野\n直死魔眼不再消耗生命值\n提升0.7%终结伤害\n提升1.7%伤害加成|r\n|cFF85A3AD自身或公主死亡复活时将会在对方处复活\n自身或公主死亡300秒后仍未复活将会损耗当前生命值一半复活对方|r",
    icon = "war3mapImported\\BTNEwl_Teshu_Nailuodehua.blp"
  })
  if not u:hasdata("变异判定-远野志贵") then
    AdvanceGet["远野志贵"](u)
  end
end

Vars_Ciyuan_Shenhua = {
  {
    name = "芙宁娜",
    weight = 1200,
    key = {
      "唯一",
      "水",
      "白毛",
      "歌姬"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:ishasshw() and u:hasdata("变异判定-若水之躯") and u:isonlymaxvar("水") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:setplayername("|cFF7DBEF1[|r|cFF3366FF水|r|cFF7799FF神|r|cFF7DBEF1]|r" .. NameID[sy])
      u:reduceshw()
      SendMsgAll("|cFF3366FF欢|r|cFF4A77FF唱|r|cFF6088FF！|r|cFF7799FF以|r|cFF8EAAFF我|r|cFFA4BBFF之|r|cFFBBCCFF名|r|cFFD2DDFF！|r")
      u:setdata("属性-海洋神化")
      PlayGlobalSound(Sound_Funingna_Get)
      u:setdata("属性-歌姬传奇")
      u:setdata("属性-歌姬神化")
      ModelReplace({
        u = u,
        model = "furina.mdx",
        modelsize = 1,
        modelname = "|cFF3366FF芙|r|cFF4073FF宁|r|cFF4C80FF娜|r",
        modelicon = "Portrait_Funingna.tga"
      })
      ChangeValue(Damage_Element_Water, sy, 0.1)
      u:changedata("效果增强-水", 0.25)
      u:changedata("水变异补正", 50)
      u:setdata("芙宁娜-生命恢复增强", 0.36)
      local qsxsh = 0
      local lw = 0
      local mhp = 0
      u:addhealthrefresh(function(set_value, bs, hs)
        local water = 0.005 * u:getstate("水变异") * hs
        set_value(Damage_Element_Water, sy, water)
        set_value(DamageSystem_Shjc, sy, 0.1 * (water * 20))
      end)
      ac.loop(1000, function()
        ChangeValue(Damage_Element_All, sy, -1 * qsxsh)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * lw))
        ChangeValue(Correction_MHp, sy, 0.1 * (-1 * mhp))
        qsxsh = 7.0E-4 * math.floor(u:getmaxhp() / 1000)
        if 0.21 <= qsxsh then
          qsxsh = 0.21
        end
        local qfz = u:getdata("芙宁娜-气氛值")
        lw = 0.01 * qfz
        mhp = 0.005 * qfz
        ChangeValue(Correction_MHp, sy, 0.1 * (1 * mhp))
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * lw))
        ChangeValue(Damage_Element_All, sy, 1 * qsxsh)
      end)
      u:setdata("芙宁娜-气氛值", 0)
      u:addstexiao(var.name, "伤害判定后效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if info.element == "水" and u:getdata("芙宁娜-气氛值") < 100 then
          u:changetimedata("芙宁娜-气氛值", 1, 10)
        end
      end)
    end,
    effectname = "|cFF3366FF芙|r|cFF4073FF宁|r|cFF4C80FF娜|r",
    effecttext = "|cFF3366FF传奇 神化 唯一 水 歌姬\n仿若水中萍|r\n|cFF4C80FF[芙卡洛斯之愿]强化:\n减少时积累120%变化数值\n增加时只积累80%变化数值\n失效时不再使生命值损耗\n至多保存30%生命上限|r\n|cFF3366FF普世欢腾|r\n|cFF4C80FF造成水属性伤害时提升1点气氛值,持续10秒,上限100,分立计时\n提升[气氛值*0.5%]生命上限\n提升[气氛值*0.1%]伤害加成|r\n|cFF3366FF众水的歌者|r\n|cFF4C80FF提升[浑身*水变异*0.5%]水属性伤害\n提升[浑身*水变异*10%]基础伤害|r\n|cFF3366FF无人听的自白|r\n|cFF4C80FF提升36%生命恢复效果\n每1000生命上限提升0.07%全属性伤害(上限21%)|r\n|cFF3366FF神之眼:水|r\n|cFF4C80FF提升25%水效果增强\n提升10%水属性伤害\n无属性伤害造成水属性伤害\n提升50%水变异补正|r",
    effectart = "Ewl_Shenhua_Funingna"
  },
  {
    name = "窥星者",
    weight = 5,
    key = {"唯一", "星"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:ishasshw() and (u:hasdata("判定-窥星") or u:hasdata("权限-窥星") and (u:ishasitem("I036") or GetTimeOfDay() >= 23 or GetTimeOfDay() <= 1)) then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      SendMsgAll("|cFF6699FF引诸神之光辉 赐星月之福佑|r")
      u:setplayername("|cFF7DBEF1[|r|cFF663399群星之子|r|cFF7DBEF1]|r" .. NameID[sy])
      u:reduceshw()
      PlayBGM({
        bgm = BGM_Kuixing_01,
        time = 160,
        ID = 105,
        unit = u.handle
      })
      u:adddivinity(2)
      u:setdata("星座数", 0)
      u:addskill("S01H")
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.88, 1)
      ChangeValue(DamageSystem_Baoji, sy, 12)
      u:changedata("闪避值", 12)
      local jc = 0
      local ys = 0
      local ysjd = 1
      local ewys = 0
      local zs = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jc)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * -ys)
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -ewys)
        ChangeValue(DamageSystem_Ysshjd, sy, ysjd, 2)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -zs)
        local xzs = u:getdata("星座数")
        if IsTimeNight() or u:hasdata("变异判定-塞勒涅") then
          u:setdata("窥星-夜晚判定")
          jc = 0.12 * xzs
          ys = 0.012 * xzs
          ewys = 12 * xzs
          u:setdata("窥星-太阳神罚惩罚", 0)
        else
          u:deldata("窥星-夜晚判定")
          jc = 0
          ys = 0
          ewys = 0
          u:setdata("窥星-太阳神罚惩罚", 0.05 * xzs)
        end
        zs = 0.12 * u:getstate("星变异")
        ysjd = 1 - u:getdata("窥星-太阳神罚惩罚")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * zs)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * jc)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * ys)
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, ewys)
        ChangeValue(DamageSystem_Ysshjd, sy, ysjd, 1)
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:hasdata("窥星-夜晚判定") and u:getluckrandom(12 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 0.5)
          tg:effectadd("war3mapImported\\meteorstrike.mdl", "origin")
          DamageUnit({
            bj = "破碎的记忆(附伤)",
            unit = tg.handle,
            source = u.handle,
            damage = info.yssh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
        end
      end)
      ac.loop(1000, function(timer)
        if GetTimeOfDay() >= 23 or GetTimeOfDay() <= 1 then
          u:uivar_change({
            keyname = "窥星者",
            keytype = "传奇栏",
            text = "|cFFCCFFFF星空|r|cFFADE0FF的|r|cFF8FC2FF记|r|cFF70A3FF忆|r\n|cFF70A3FF神性 2\n传奇 唯一 星\n奥秘窥探\n星之力|r\n|cFFCCFFFF提升[星座数*12%]基础伤害\n提升[星座数*0.12%]终结伤害\n直接伤害12%附带等值伤害|r\n|cFF70A3FF月之祝|r\n|cFFCCFFFF受到致死伤害时免疫该次伤害并完全恢复,午夜时分刷新冷却(至低120秒)\n杀敌时提升0.012%伤害加成|r\n|cFF70A3FF星辰之舞|r\n|cFFCCFFFF提升[星座数*12]额外移速\n绝对闪避成功时12秒内提升[星座数*0.6%]伤害加成,触发冷却1.2秒|r\n|cFF70A3FF群星庇佑|r\n|cFFCCFFFF受到伤害时12%格挡并永恒恢复自身5%最大生命值与5点体力值\n[星辉注射剂]效果增强|r\n|cFF70A3FF星象图|r\n|cFFCCFFFF使用回忆药剂或星辉注射剂时概率激活不同星座|r\n|cFF70A3FF星海苍穹|r\n|cFFCCFFFF自身为女神且女神力达到9时解锁|r",
            icon = "war3mapImported\\BTNEwl_Kuixing_10"
          })
        elseif IsTimeNight() then
          u:uivar_change({
            keyname = "窥星者",
            keytype = "传奇栏",
            text = "|cFF70A3FF破碎的记忆|r\n|cFF70A3FF神性 2\n传奇 唯一 星\n奥秘窥探|r\n|cFFCCFFFF提升[1.2%*星变异]伤害加成\n提升12%受伤减少\n提升12%移速\n提升12%暴击率\n提升12闪避值|r\n|cFF70A3FF星之力|r\n|cFFCCFFFF提升[星座数*12%]基础伤害\n提升[星座数*0.12%]终结伤害\n直接伤害12%附带等值伤害|r\n|cFF70A3FF月之祝|r\n|cFFCCFFFF受到致死伤害时免疫该次伤害并完全恢复,午夜时分刷新冷却(至低120秒)\n杀敌时提升0.012%伤害加成|r\n|cFF70A3FF星辰之舞|r\n|cFFCCFFFF提升[星座数*12]额外移速\n绝对闪避成功时12秒内提升[星座数*0.6%]伤害加成,触发冷却1.2秒|r\n|cFF70A3FF群星庇佑|r\n|cFFCCFFFF受到伤害时12%格挡并永恒恢复自身5%最大生命值与5点体力值\n[星辉注射剂]效果增强|r\n|cFF70A3FF星象图|r\n|cFFCCFFFF使用回忆药剂或星辉注射剂时概率激活不同星座|r",
            icon = "war3mapImported\\BTNEwl_Kuixingzhe.blp"
          })
        else
          u:uivar_change({
            keyname = "窥星者",
            keytype = "传奇栏",
            text = "|cFFFFFF00破碎的记忆|r\n|cFF1FBF00神性 2\n传奇 唯一 星\n奥秘窥探|r\n|cFFFFFF00提升[1.2%*星变异]伤害加成\n提升12%受伤减少\n提升12%移速\n提升12%暴击率\n提升12闪避值|r\n|cFF1FBF00太阳神罚|r\n|cFFFFFF00降低[5%*星座数]原始伤害\n提升[10%*星座数]机制受伤|r",
            icon = "war3mapImported\\BTNEwl_Kuixingzhe.blp"
          })
        end
        if u:hasdata("属性-女神") and u:getdata("女神力") >= 9 and not u:hasdata("变异判定-塞勒涅") then
          NameID[sy] = "|cFFCCFFFF塞|r|cFFA6D9FF勒|r|cFF80B2FF涅|r"
          u:setplayername("|cFFCCFFFF塞|r|cFFA6D9FF勒|r|cFF80B2FF涅|r")
          u:setdata("变异判定-塞勒涅")
          u:adddivinity(1)
          u:addallstats(12 * u:getdata("星座数"))
          u:addstexiao(var.name .. "塞勒涅", "直接伤害特效", function(args)
            local tg = args.tg
            local u = args.u
            local info = args.damageinfo
            if not u:hasdata(var.name .. "-塞勒涅特效冷却") and u:getluckrandom(12 * info.txgl) then
              u:settimedata(var.name .. "-塞勒涅特效冷却", 1.2)
              local txsh = (120 + 12 * u:getdata("星座数")) * u:getallattri()
              tg:effectadd("0Tx\\0Tx_Kuixing_11.mdx", "origin", 1)
              DamageUnit({
                bj = "塞勒涅(附伤)",
                unit = tg.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "魔力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "无"
              })
            end
          end)
          SendMsgAll("|cFFCCFFFF「当|r|cFFC9FCFF我|r|cFFC7FAFF爱|r|cFFC4F7FF你|r|cFFC2F4FF时|r|cFFBFF2FF，|r|cFFBCEFFF风|r|cFFBAECFF中|r|cFFB7EAFF的|r|cFFB4E7FF松|r|cFFB2E4FF树|r|cFFAFE2FF，|r|cFFADDFFF要|r|cFFAADCFF以|r|cFFA7DAFF她|r|cFFA5D7FF们|r|cFFA2D5FF丝|r|cFF9FD2FF线|r|cFF9DCFFF般|r|cFF9ACDFF的|r|cFF98CAFF叶|r|cFF95C7FF子|r|cFF92C5FF唱|r|cFF90C2FF你|r|cFF8DBFFF的|r|cFF8ABDFF名|r|cFF88BAFF字|r|cFF85B7FF。」|r")
          StopSoundBJ(BGM_Kuixing_01)
          PlayBGM({
            bgm = BGM_Kuixing_11,
            time = 140,
            ID = 106,
            unit = u.handle
          })
          u:uivar_change({
            keyname = "窥星者",
            keytype = "传奇栏",
            text = "|cFFCCFFFF星空|r|cFFADE0FF的|r|cFF8FC2FF记|r|cFF70A3FF忆|r\n|cFF70A3FF神性 3\n传奇 唯一 星\n奥秘窥探\n星之力|r\n|cFFCCFFFF提升[星座数*12%]基础伤害\n提升[星座数*0.12%]终结伤害\n直接伤害12%附带等值伤害|r\n|cFF70A3FF月之祝|r\n|cFFCCFFFF提升[12*星座数]全属性\n受到致死伤害时免疫该次伤害并完全恢复,午夜时分刷新冷却(至低120秒)\n杀敌时提升0.012%伤害加成|r\n|cFF70A3FF星辰之舞|r\n|cFFCCFFFF直接伤害时12%附带星辰伤害\n提升[星座数*12]额外移速\n绝对闪避成功时12秒内提升[星座数*0.6%]伤害加成,触发冷却1.2秒|r\n|cFF70A3FF群星庇佑|r\n|cFFCCFFFF受到伤害时12%格挡并永恒恢复自身5%最大生命值与5点体力值\n[星辉注射剂]效果增强|r\n|cFF70A3FF星象图|r\n|cFFCCFFFF使用回忆药剂或星辉注射剂时概率激活不同星座|r\n|cFF70A3FF星海苍穹|r\n|cFFCCFFFF自身为女神且女神力达到9时解锁|r",
            icon = "war3mapImported\\BTNEwl_Kuixing_10"
          })
          timer:remove()
        end
      end)
      
      local function getxingzuo()
        local sj = GetRandomInt(1, 12)
        local b = false
        if sj == 1 then
          if not u:hasdata("星座-水瓶座激活") then
            u:setdata("星座-水瓶座激活")
            u:uivar_add({
              keyname = "窥星-水瓶座",
              keytype = "传奇栏",
              text = "|cFF66FFFF水瓶座|r\n|cFF66FFFF提升全队1点永恒恢复\n提升30%医疗修正\n每10秒积累[100+全属性*2]甘露值\n水瓶座每秒会消耗甘露值治愈自己与300范围友军 每个单位每次最多治愈[600]点|r",
              icon = "war3mapImported\\BTNEwl_12Xz_Shuipingzuo.blp"
            })
            ChangeValue(Correction_CureUp, sy, 0.3)
            ForGroupLuaNew(Group_PlayHero, function(xq)
              local sy2 = xq.ownerid
              ChangeValue(HeroMenu_HpForever_Inr, sy2, 1)
            end)
            local cs = 0
            local gl = 0
            ac.loop(1000, function()
              if u:isalive() then
                cs = cs + 1
                if cs == 10 then
                  cs = 0
                  gl = gl + 100 + 2 * u:getallattri()
                  u:effectadd("Abilities\\Spells\\Undead\\ReplenishMana\\ReplenishManaCasterOverhead.mdl", "origin")
                end
                if 0 < gl then
                  local x, y = u:getxy()
                  for _, xq in ac.selector():in_rangexy(x, y, 300):isingroup(Group_PlayHero):ipairs() do
                    xq = getunit(xq)
                    if xq:getperhp() <= 99 then
                      local hp = xq:getmaxhp() - xq:gethp()
                      if 600 <= hp then
                        hp = 600
                      end
                      if hp >= gl then
                        hp = gl
                      end
                      gl = gl - hp
                      xq:effectadd("Abilities\\Spells\\Other\\HealingSpray\\HealBottleMissile.mdl", "chest")
                      xq:curehp(u.handle, hp, 0, 1)
                    end
                  end
                end
              end
            end)
          else
            b = true
          end
        end
        if sj == 2 then
          if not u:hasdata("星座-处女座激活") then
            u:setdata("星座-处女座激活")
            u:uivar_add({
              keyname = "窥星-处女座",
              keytype = "传奇栏",
              text = "|cFFFF99FF处女座|r\n|cFFFF99FF提升777.7固定伤害\n造成个位数为7的伤害时该次伤害提升1.7%伤害加成\n造成个位数为7的伤害时17秒内提升自身1.7%伤害加成修正(触发冷却1.7秒)|r",
              icon = "war3mapImported\\BTNEwl_12Xz_Chunvzuo.blp"
            })
            u:changedata("固定伤害", 777.7)
            u:addstexiao(var.name, "伤害系统计算效果", function(args)
              local info = args.damageinfo
              local u = args.u
              if math.floor(info.damage % 10) == 7 then
                info.gl = info.gl + 0.17
                if not u:hasdata("窥星-处女座冷却") then
                  u:settimedata("窥星-处女座冷却", 1.7)
                  ChangeTimeValue(DamageSystem_Shjc, sy, 0.017, 17)
                end
              end
            end)
          else
            b = true
          end
        end
        if sj == 3 then
          if not u:hasdata("星座-天蝎座激活") then
            u:setdata("星座-天蝎座激活")
            u:uivar_add({
              keyname = "窥星-天蝎座",
              keytype = "传奇栏",
              text = "|cFF9966CC天蝎座|r\n|cFF9966CC受到伤害时12%免疫该次伤害\n受到伤害时12%反馈该次伤害*12的纯粹伤害\n造成伤害时12%使该次伤害终结伤害提升0.1%~5%\n造成伤害时12%使该次伤害无视闪避\n造成伤害时12%使该次伤害无视免疫\n死亡时12%复活\n复活时12%提升12点全属性|r",
              icon = "war3mapImported\\BTNEwl_12Xz_Tianxiezuo.blp"
            })
            u:addstexiao(var.name, "终结伤害计算效果", function(args)
              local u = args.u
              local tg = args.tg
              local info = args.damageinfo
              if u:getluckrandom(12) then
                info.endup = info.endup + GetRandomReal(0.01, 0.5)
              end
            end)
            u:addstexiao(var.name, "抗性破坏阶段", function(args)
              local u = args.u
              local tg = args.tg
              local info = args.damageinfo
              if u:getluckrandom(12) then
                info.wssb = true
              end
              if u:getluckrandom(12) then
                info.wsmy = true
              end
            end)
          else
            b = true
          end
        end
        if sj == 4 then
          if not u:hasdata("星座-摩羯座激活") then
            u:setdata("星座-摩羯座激活")
            u:uivar_add({
              keyname = "窥星-摩羯座",
              keytype = "传奇栏",
              text = "|cFFCC66FF摩羯座|r\n|cFFCC66FF杀敌时12%提升自身0.12%伤害加成修正\n杀敌时12%提升自身0.12%伤害加成修正\n受到伤害时12%提升自身12生命值上限(时限伤害无效 触发冷却12秒)\n升级时额外提升1点全属性并有12%概率额外获得1点天赋点\n常规复活队友时12%提升自身1~12点全属性|r",
              icon = "war3mapImported\\BTNEwl_12Xz_Mojiezuo.blp"
            })
            u:addstexiao(var.name, "英雄升级时效果", function(args)
              u:addallstats(1)
              if u:getluckrandom(12) then
                ChangeValue(TalentCode, sy, 1)
              end
            end)
          else
            b = true
          end
        end
        if sj == 5 then
          if not u:hasdata("星座-白羊座激活") then
            u:setdata("星座-白羊座激活")
            u:uivar_add({
              keyname = "窥星-白羊座",
              keytype = "传奇栏",
              text = "|cFFFFFFCC白羊座|r\n|cFFFFFFCC被攻击时12%使攻击单位混乱3秒(触发冷却6秒 BOSS无效)\n被攻击时12%使自身隐身3秒（触发冷却12秒）\n直接伤害时12%使目标暂停1.2秒(独立冷却1秒 BOSS触发冷却9秒)\n直接伤害时12%使目标冰冻1.2秒(独立冷却1秒 BOSS触发冷却9秒)|r",
              icon = "war3mapImported\\BTNEwl_12Xz_Baiyang.blp"
            })
            u:addstexiao(var.name .. "白羊座", "直接伤害特效", function(args)
              local u = args.u
              local tg = args.tg
              local info = args.damageinfo
              if u:getluckrandom(12 * info.txgl) and not tg:hasdata(var.name .. "-暂停特效冷却") then
                if tg:isboss() then
                  tg:settimedata(var.name .. "-暂停特效冷却", 9)
                else
                  tg:settimedata(var.name .. "-暂停特效冷却", 1)
                end
                tg:buffset(u.handle, 1.2, "暂停")
              end
              if u:getluckrandom(12 * info.txgl) and not tg:hasdata(var.name .. "-冰冻特效冷却") then
                if tg:isboss() then
                  tg:settimedata(var.name .. "-冰冻特效冷却", 9)
                else
                  tg:settimedata(var.name .. "-冰冻特效冷却", 1)
                end
                tg:buffset(u.handle, 1.2, "冰冻")
              end
            end)
            u:addtrgevent("单位-被攻击", function(args)
              local soc = args.soc
              local u = args.u
              if not u:hasdata("白羊座-混乱冷却") and u:getluckrandom(12) and not soc:isboss() then
                u:settimedata("白羊座-混乱冷却", 6)
                soc:buffset(u.handle, 3, "混乱")
              end
              if not u:hasdata("白羊座-隐身冷却") and u:getluckrandom(12) then
                u:settimedata("白羊座-隐身冷却", 12)
                u:buffset(u.handle, 3, "隐身")
              end
            end)
          else
            b = true
          end
        end
        if sj == 6 then
          if not u:hasdata("星座-金牛座激活") then
            u:setdata("星座-金牛座激活")
            u:uivar_add({
              keyname = "窥星-金牛座",
              keytype = "传奇栏",
              text = "|cFFFF6600金牛座|r\n|cFFFF6600提升12点生命恢复\n提升12点护甲\n提升12%额外移速\n提升12%论外减伤\n每次受到大于100点伤害30秒内降低2点固有恢复与2点护甲|r",
              icon = "war3mapImported\\BTNEwl_12Xz_Jinniuizuo.blp"
            })
            u:changearmor(12)
            ChangeValue(HeroMenu_HpChange_Inr, sy, 12)
            ChangeValue(DamageSystem_Ssjianshao, sy, 0.88, 1)
            ChangeValue(HeroMenu_ExtraMoveSpeed_Bfb, sy, 0.12)
          else
            b = true
          end
        end
        if sj == 7 then
          if not u:hasdata("星座-双鱼座激活") then
            u:setdata("星座-双鱼座激活")
            u:uivar_add({
              keyname = "窥星-双鱼座",
              keytype = "传奇栏",
              text = "|cFF99CCFF双鱼座|r\n|cFF99CCFF提升全队0.12体力恢复\n提升1200范围友军4点永恒恢复\n提升1200范围友军12%移速\n提升1200范围友军6点护甲\n自身开箱时12%数量+1 多次判定 判定次数为1+1800范围内友军数量|r",
              icon = "war3mapImported\\BTNEwl_12Xz_Shuangyuzuo.blp"
            })
            ForGroupLuaNew(Group_PlayHero, function(xq)
              local sy2 = xq.ownerid
              ChangeValue(Hero_Tili_Huifu, sy2, 0.12)
            end)
            u:addskill("A0D1")
            u:addskill("A0EB")
          else
            b = true
          end
        end
        if sj == 8 then
          if not u:hasdata("星座-双子座激活") then
            u:setdata("星座-双子座激活")
            u:uivar_add({
              keyname = "窥星-双子座",
              keytype = "传奇栏",
              text = "|cFF0066FF双子座|r\n|cFF0066FF每隔60秒切换形态\n矛形态：\n提升2%终结伤害\n提升2%伤害加成\n提升2%伤害加成\n提升2%伤害加成\n提升20%额外受伤修正\n提升20%追加受伤\n提升20%论外受伤\n盾形态：\n降低40%原始伤害\n降低20%所受原始伤害\n提升20固有格挡\n提升20固有恢复|r",
              icon = "war3mapImported\\BTNEwl_12Xz_Shuangzizuo.blp"
            })
            u:sendmessage("|cFF7DBEF1双子座-矛形态|r")
            u:setdata("双子座矛形态")
            ChangeValue(DamageSystem_Shjc, sy, 0.02)
            ChangeValue(DamageSystem_Shjc, sy, 0.02)
            ChangeValue(DamageSystem_Shjc, sy, 0.02)
            ChangeValue(DamageSystem_Sszengjia, sy, 0.2)
            ChangeValue(DamageSystem_EndSh, sy, 0.020000000000000004)
            ChangeValue(DamageSystem_LwSs, sy, 1.2, 1)
            ac.wait(60000, function()
              u:sendmessage("|cFF7DBEF1双子座-盾形态|r")
              u:deldata("双子座矛形态")
              u:setdata("双子座盾形态")
              ChangeValue(DamageSystem_Shjc, sy, -0.02)
              ChangeValue(DamageSystem_Shjc, sy, -0.02)
              ChangeValue(DamageSystem_Shjc, sy, -0.02)
              ChangeValue(DamageSystem_Sszengjia, sy, -0.2)
              ChangeValue(DamageSystem_EndSh, sy, -0.020000000000000004)
              ChangeValue(DamageSystem_LwSs, sy, 1.2, 2)
              ChangeValue(DamageSystem_Ysshjd, sy, 0.6, 1)
              ChangeValue(HeroMenu_HpChange_Inr, sy, 20)
              u:changedata("固定格挡", 20)
            end)
            ac.loop(120000, function()
              ChangeValue(DamageSystem_Ysshjd, sy, 0.6, 2)
              ChangeValue(HeroMenu_HpChange_Inr, sy, -20)
              u:changedata("固定格挡", -20)
              u:deldata("双子座盾形态")
              u:sendmessage("|cFF7DBEF1双子座-矛形态|r")
              u:setdata("双子座矛形态")
              ChangeValue(DamageSystem_Shjc, sy, 0.02)
              ChangeValue(DamageSystem_Shjc, sy, 0.02)
              ChangeValue(DamageSystem_Shjc, sy, 0.02)
              ChangeValue(DamageSystem_Sszengjia, sy, 0.2)
              ChangeValue(DamageSystem_EndSh, sy, 0.020000000000000004)
              ChangeValue(DamageSystem_LwSs, sy, 1.2, 1)
              ac.wait(60000, function()
                u:sendmessage("|cFF7DBEF1双子座-盾形态|r")
                u:deldata("双子座矛形态")
                u:setdata("双子座盾形态")
                ChangeValue(DamageSystem_Shjc, sy, -0.02)
                ChangeValue(DamageSystem_Shjc, sy, -0.02)
                ChangeValue(DamageSystem_Shjc, sy, -0.02)
                ChangeValue(DamageSystem_Sszengjia, sy, -0.2)
                ChangeValue(DamageSystem_EndSh, sy, -0.020000000000000004)
                ChangeValue(DamageSystem_LwSs, sy, 1.2, 2)
                ChangeValue(DamageSystem_Ysshjd, sy, 0.6, 1)
                ChangeValue(HeroMenu_HpChange_Inr, sy, 20)
                u:changedata("固定格挡", 20)
              end)
            end)
          else
            b = true
          end
        end
        if sj == 9 then
          if not u:hasdata("星座-天秤座激活") then
            u:setdata("星座-天秤座激活")
            u:uivar_add({
              keyname = "窥星-天秤座",
              keytype = "传奇栏",
              text = "|cFFFF9999天秤座|r\n|cFFFF9999每90秒随机选择一名友军成为测量者\n提升双方1%伤害加成\n提升双方10%论外减伤\n分摊对方所受伤害25%(生命损耗)\n杀敌计数共享\n没存活友军时只提升自身1%伤害加成与10%论外减伤|r",
              icon = "war3mapImported\\BTNEwl_12Xz_Tianchengzuo.blp"
            })
            ChangeValue(DamageSystem_Shjc, sy, 0.01)
            ChangeValue(DamageSystem_Ssjianshao, sy, 0.9, 1)
            Kuixingzhe_Tianchengzuo[1] = u.handle
            if Group_Counts(Group_PlayHero) == 1 then
            else
              Kuixingzhe_Tianchengzuo[2] = 0
              local g = CreateGroupLua()
              ForGroupLuaNew(Group_PlayHero, function(xq)
                xq:groupadd(g)
              end)
              u:groupremove(g)
              local sy2 = 7
              local b2 = false
              if Group_Counts(g) == 0 then
                b2 = true
              else
                local tg = Group_Randomunit(g)
                sy2 = tg.ownerid
                Kuixingzhe_Tianchengzuo[2] = tg.handle
                u:sendmessage(tg:getplayername() .. "|cFF7DBEF1成为了测量者|r")
                tg:sendmessage("|cFF7DBEF1你成为了测量者|r")
                ChangeValue(DamageSystem_Shjc, sy2, 0.01)
                ChangeValue(DamageSystem_Ssjianshao, sy2, 0.9, 1)
              end
              GroupClearLua(g)
              ac.loop(90000, function()
                if not b2 then
                  ChangeValue(DamageSystem_Shjc, sy2, -0.01)
                  ChangeValue(DamageSystem_Ssjianshao, sy2, 0.9, 2)
                end
                Kuixingzhe_Tianchengzuo[2] = 0
                ForGroupLuaNew(Group_PlayHero, function(xq)
                  xq:groupadd(g)
                end)
                u:groupremove(g)
                b2 = false
                if Group_Counts(g) == 0 then
                  b2 = true
                else
                  local tg = Group_Randomunit(g)
                  sy2 = tg.ownerid
                  Kuixingzhe_Tianchengzuo[2] = tg.handle
                  u:sendmessage(tg:getplayername() .. "|cFF7DBEF1成为了测量者|r")
                  tg:sendmessage("|cFF7DBEF1你成为了测量者|r")
                  ChangeValue(DamageSystem_Shjc, sy2, 0.01)
                  ChangeValue(DamageSystem_Ssjianshao, sy2, 0.9, 1)
                end
                GroupClearLua(g)
              end)
            end
          else
            b = true
          end
        end
        if sj == 10 then
          if not u:hasdata("星座-巨蟹座激活") then
            u:setdata("星座-巨蟹座激活")
            u:uivar_add({
              keyname = "窥星-巨蟹座",
              keytype = "传奇栏",
              text = "|cFFFFCC33巨蟹座|r\n|cFFFFCC33提升自身所有友军1%伤害加成修正\n提升自身所有友军1%伤害加成修正\n提升自身所有友军1%伤害加成修正\n享受所有友军25%医疗恢复\n\n全队提升自身1%伤害加成修正\n全队提升自身1%伤害加成修正\n全队提升自身1%伤害加成修正\n全队享受自身25%医疗恢复\n\n巨蟹座本身不影响本身效果|r",
              icon = "war3mapImported\\BTNEwl_12Xz_Juxiezuo.blp"
            })
            local jc1 = 0
            local sj1 = 0
            local zz1 = 0
            local jc2 = 0
            local sj2 = 0
            local zz2 = 0
            ac.loop(3000, function()
              for i = 1, 6 do
                if i == sy then
                  ChangeValue(DamageSystem_Shjc, i, 0.1 * -jc1)
                  ChangeValue(DamageSystem_Shjc, i, 0.1 * -sj1)
                  ChangeValue(DamageSystem_Shjc, i, 0.1 * -zz1)
                else
                  ChangeValue(DamageSystem_Shjc, i, 0.1 * -jc2)
                  ChangeValue(DamageSystem_Shjc, i, 0.1 * -sj2)
                  ChangeValue(DamageSystem_Shjc, i, 0.1 * -zz2)
                end
              end
              jc1 = 0
              sj1 = 0
              zz1 = 0
              jc2 = 0
              sj2 = 0
              zz2 = 0
              for i = 1, 6 do
                if i ~= sy then
                  jc1 = jc1 + 0.1 * (DamageSystem_Shjc[i] - 1)
                  sj1 = sj1 + 0.1 * (DamageSystem_Shjc[i] - 1)
                  zz1 = zz1 + 0.1 * (DamageSystem_Shjc[i] - 1)
                else
                  jc2 = jc2 + 0.1 * (DamageSystem_Shjc[i] - 1)
                  sj2 = sj2 + 0.1 * (DamageSystem_Shjc[i] - 1)
                  zz2 = zz2 + 0.1 * (DamageSystem_Shjc[i] - 1)
                end
              end
              for i = 1, 6 do
                if i == sy then
                  ChangeValue(DamageSystem_Shjc, i, 0.1 * jc1)
                  ChangeValue(DamageSystem_Shjc, i, 0.1 * sj1)
                  ChangeValue(DamageSystem_Shjc, i, 0.1 * zz1)
                else
                  ChangeValue(DamageSystem_Shjc, i, 0.1 * jc2)
                  ChangeValue(DamageSystem_Shjc, i, 0.1 * sj2)
                  ChangeValue(DamageSystem_Shjc, i, 0.1 * zz2)
                end
              end
            end)
          else
            b = true
          end
        end
        if sj == 11 then
          if not u:hasdata("星座-射手座激活") then
            u:setdata("星座-射手座激活")
            u:uivar_add({
              keyname = "窥星-射手座",
              keytype = "传奇栏",
              text = "|cFF3366FF射手座|r\n|cFF3366FF每秒积攒1点星力\n可以输入“向群星祈祷”清空星力(至少需要100点)\n根据星力随机触发效果|r",
              icon = "war3mapImported\\BTNEwl_12Xz_Sheshouzuo.blp"
            })
            u:setdata("射手座-星力", 0)
            ac.loop(1000, function()
              u:changedata("射手座-星力", 1)
            end)
            
            local function skill(args)
              if args.chat == "向群星祈祷" and u:isalive() then
                local xl = u:getdata("射手座-星力")
                if 100 <= xl then
                  u:setdata("射手座-星力", 0)
                  if 900 <= xl then
                    local sjs = GetRandomInt(1, 5)
                    u:sendmessage("|cFF7DBEF1星刻：|r" .. sjs)
                    if sjs == 1 then
                      u:additem("I036")
                    end
                    if sjs == 2 then
                      u:additem("I030")
                    end
                    if sjs == 3 then
                      for i = 1, 10 do
                        u:additem("I00X")
                      end
                    end
                    if sjs == 4 then
                      ChangeValue(DamageSystem_Shjc, sy, 0.01)
                    end
                    if sjs == 5 then
                      ChangeValue(DamageSystem_Ssjianshao, sy, 0.95, 1)
                    end
                  else
                    local max = 6
                    if 225 <= xl then
                      max = 9
                    end
                    if 350 <= xl then
                      max = 11
                    end
                    if 550 <= xl then
                      max = 14
                    end
                    local sjs = GetRandomInt(1, max)
                    u:sendmessage("|cFF7DBEF1星刻：|r" .. sjs)
                    if sjs == 1 then
                      u:effectadd("war3mapImported\\great lightning.mdl", "origin")
                      u:losshp(u, 0, 50)
                      u:buffset(u.handle, 3, "眩晕")
                    end
                    if sjs == 2 then
                      u:effectadd("war3mapImported\\great lightning.mdl", "origin")
                      u:buffset(u.handle, 5, "僵直")
                    end
                    if sjs == 3 then
                      u:effectadd("war3mapImported\\great lightning.mdl", "origin")
                      u:buffset(u.handle, 5, "伤害限制")
                    end
                    if sjs == 4 then
                      u:effectadd("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", "origin")
                      ChangeValue(DamageSystem_Shjc, sy, 0.01)
                    end
                    if sjs == 5 then
                      u:effectadd("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", "origin")
                      ChangeValue(DamageSystem_Ssjianshao, sy, 0.95, 1)
                    end
                    if sjs == 6 then
                      u:effectadd("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", "origin")
                      u:changemaxhp(500)
                    end
                    if sjs == 7 then
                      u:effectadd("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", "origin")
                      ChangeValue(DamageSystem_Shjc, sy, 0.015)
                    end
                    if sjs == 8 then
                      u:effectadd("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", "origin")
                      u:additem(MEDICINE_YITAI)
                      u:additem(MEDICINE_MWX)
                    end
                    if sjs == 9 then
                      u:effectadd("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", "origin")
                      ChangeValue(HeroMenu_HpChange_Inr, sy, 2)
                    end
                    if sjs == 10 then
                      u:effectadd("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", "origin")
                      u:additem(MEDICINE_BLOOD)
                      u:additem(MEDICINE_HUIYI)
                    end
                    if sjs == 11 then
                      u:effectadd("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", "origin")
                      u:changedata("固定格挡", 5)
                    end
                    if sjs == 12 then
                      u:effectadd("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", "origin")
                      ChangeValue(DamageSystem_Shjc, sy, 0.01)
                    end
                    if sjs == 13 then
                      u:effectadd("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", "origin")
                      for i = 1, 5 do
                        u:additem("I00X")
                      end
                    end
                    if sjs == 14 then
                      u:effectadd("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", "origin")
                      u:addallstats(10)
                    end
                  end
                else
                  u:sendmessage("|cFF7DBEF1星力不足|r")
                end
              end
            end
            
            u:addtrgevent("玩家-聊天", function(args)
              skill(args)
            end)
          else
            b = true
          end
        end
        if sj == 12 then
          if not u:hasdata("星座-狮子座激活") then
            u:setdata("星座-狮子座激活")
            u:uivar_add({
              keyname = "窥星-狮子座",
              keytype = "传奇栏",
              text = "|cFFFF0000狮子座|r\n|cFFFF0000提升全队[0.5%*存活数量]伤害加成\n提升全队1幸运\n提升全队[0.15%*存活数量]终结伤害\n提升自身100力量\n提升自身25护甲|r",
              icon = "war3mapImported\\BTNEwl_12Xz_Shizizuo.blp"
            })
            u:addskill("A0G3")
            ForGroupLuaNew(Group_PlayHero, function(xq)
              xq:changedata("幸运", 1)
            end)
            u:addstr(100)
            u:changearmor(25)
            local zjsh = 0
            local endsh = 0
            ac.loop(3000, function()
              ForGroupLuaNew(Group_PlayHero, function(xq)
                local sy2 = xq.ownerid
                ChangeValue(DamageSystem_Shjc, sy2, 0.1 * -zjsh)
                ChangeValue(DamageSystem_EndSh, sy2, 0.1 * -endsh)
              end)
              zjsh = 0.05 * Group_Counts(Group_Xingcunzu)
              endsh = 0.015 * Group_Counts(Group_Xingcunzu)
              ForGroupLuaNew(Group_PlayHero, function(xq)
                local sy2 = xq.ownerid
                ChangeValue(DamageSystem_Shjc, sy2, 0.1 * zjsh)
                ChangeValue(DamageSystem_EndSh, sy2, 0.1 * endsh)
              end)
            end)
          else
            b = true
          end
        end
        if b then
          if 12 > u:getdata("星座数") then
            getxingzuo()
          end
        else
          u:changedata("星座数", 1)
          if u:hasdata("变异判定-塞勒涅") then
            u:addallstats(12)
          end
        end
      end
      
      u:setdata("窥星-获取星座", getxingzuo)
    end,
    effectname = "|cFF70A3FF破碎的记忆|r",
    effecttext = "|cFF70A3FF神性 2\n传奇 唯一 星\n奥秘窥探|r\n|cFFCCFFFF提升[1.2%*星变异]伤害加成\n提升12%受伤减少\n提升12%移速\n提升12%暴击率\n提升12闪避值|r\n|cFF70A3FF星之力|r\n|cFFCCFFFF提升[星座数*12%]基础伤害\n提升[星座数*1.2%]原始伤害\n直接伤害12%附带等值伤害|r\n|cFF70A3FF月之祝|r\n|cFFCCFFFF受到致死伤害时免疫该次伤害并完全恢复,午夜时分刷新冷却(至低120秒)\n杀敌时提升0.012%伤害加成|r\n|cFF70A3FF星辰之舞|r\n|cFFCCFFFF提升[星座数*12]额外移速\n绝对闪避成功时12秒内提升[星座数*0.6%]伤害加成,触发冷却1.2秒|r\n|cFF70A3FF群星庇佑|r\n|cFFCCFFFF受到伤害时12%格挡并永恒恢复自身5%最大生命值与5点体力值\n[星辉注射剂]效果增强|r\n|cFF70A3FF星象图|r\n|cFFCCFFFF使用回忆药剂或星辉注射剂时概率激活不同星座|r",
    effectart = "war3mapImported\\BTNEwl_Kuixingzhe.blp",
    test = [[

        ]]
  },
  {
    name = "雨宫莲",
    clickfunc = function(u)
      local sy = u.ownerid
      if not u:hasdata("雨宫莲-心之怪盗团") then
        if u:getdata("雨宫莲-怪盗团成员数量") >= 10 then
          u:setdata("雨宫莲-心之怪盗团")
          u:changedata("固定伤害", 250.0)
          ChangeValue(DamageSystem_Shjc, sy, 0.025)
          ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 12.5)
          ChangeValue(HeroMenu_ExtraMoveSpeed_Bfb, sy, 0.125)
          ChangeValue(Correction_Jzsh, sy, 0.025)
          ChangeValue(Hero_Tili_Huifu, sy, 0.075)
          ChangeValue(Correction_Gun, sy, 0.025)
          ChangeValue(Correction_Unify, sy, 0.25)
          ChangeValue(DamageSystem_Baoji, sy, 5)
          ChangeValue(DamageSystem_Baoshang, sy, 0.1)
          local add = 0
          local bjadd = 0
          ac.loop(3000, function()
            ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * add))
            ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * add))
            ChangeValue(DamageSystem_Baoshang, sy, -1 * bjadd)
            add = 0.1 * Stage
            if DamageSystem_Baoji[sy] > 100 then
              bjadd = (DamageSystem_Baoji[sy] - 100) / 100
            else
              bjadd = 0
            end
            ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * add))
            ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * add))
            ChangeValue(DamageSystem_Baoshang, sy, 1 * bjadd)
          end)
          u:addstexiao("雨宫莲", "杀敌效果", function(args)
            ChangeValue(DamageSystem_Shjc, sy, 1.0E-4)
          end)
          PlayGlobalSound(Sound_Ygl_02)
          SendMsgAll("|cFF6633FF「|r|cFF6930F0很|r|cFF6C2DE1好|r|cFF6F2AD2.|r|cFF7227C3.|r|cFF7524B4.|r|cFF7821A5我|r|cFF7B1E96听|r|cFF7E1B87见|r|cFF811878你|r|cFF841569的|r|cFF87125A觉|r|cFF8A0F4B悟|r|cFF8D0C3C了|r|cFF90092D!|r|cFF93061E」|r")
          ac.wait(10000, function()
            SendMsgAll("|cFF6633FF「|r|cFF6C2DE3立|r|cFF7128C6下|r|cFF7722AA契|r|cFF7D1C8E约|r|cFF821771吧|r|cFF881155!|r|cFF8E0B39」|r")
          end)
          ac.wait(12000, function()
            SendMsgAll("|cFF6633FF『|r|cFF6A2FEA吾|r|cFF6E2AD4即|r|cFF7326BF是|r|cFF7722AA汝|r|cFF7B1E95，|r|cFF801A80汝|r|cFF84156A便|r|cFF881155是|r|cFF8C0D40吾|r|cFF90082A』|r")
          end)
          ac.wait(15300, function()
            SendMsgAll("|cFF6633FF「|r|cFF6831F6为|r|cFF6A2FEC了|r|cFF6C2DE3自|r|cFF6E2BD9己|r|cFF6F2AD0所|r|cFF7128C6信|r|cFF7326BD奉|r|cFF7524B3的|r|cFF7722AA正|r|cFF7920A1义|r|cFF7B1E97,|r|cFF7D1C8E而|r|cFF7F1A84不|r|cFF80197B惧|r|cFF821771一|r|cFF841568切|r|cFF86135E亵|r|cFF881155渎|r|cFF8A0F4C之|r|cFF8C0D42举|r|cFF8E0B39的|r|cFF90092F人|r|cFF910826啊|r|cFF93061C!|r|cFF950413」|r")
          end)
          ac.wait(21000, function()
            SendMsgAll("|cFF6633FF「|r|cFF6930F1将|r|cFF6C2DE3此|r|cFF6E2AD5愤|r|cFF7128C6怒|r|cFF7425B8,|r|cFF7722AA与|r|cFF7A1F9C吾|r|cFF7D1C8E之|r|cFF7F1980名|r|cFF821771一|r|cFF851463同|r|cFF881155解|r|cFF8B0E47放|r|cFF8E0B39!|r|cFF90082B」|r|cFF93061C |r")
          end)
          ac.wait(25000, function()
            SendMsgAll("|cFF6633FF「|r|cFF6831F7解|r|cFF6930EF放|r|cFF6B2EE6那|r|cFF6D2CDE即|r|cFF6E2BD6便|r|cFF7029CE坠|r|cFF7227C5入|r|cFF7326BD地|r|cFF7524B5狱|r|cFF7623AD,|r|cFF7821A5亦|r|cFF7A1F9C要|r|cFF7B1E94自|r|cFF7D1C8C己|r|cFF7F1A84确|r|cFF80197B定|r|cFF821773一|r|cFF84156B切|r|cFF851463真|r|cFF87125A伪|r|cFF891052的|r|cFF8A0F4A坚|r|cFF8C0D42定|r|cFF8D0C3A意|r|cFF8F0A31志|r|cFF910829之|r|cFF920721力|r|cFF940519!|r|cFF960310」|r")
          end)
          ac.wait(32000, function()
            PlayBGM({
              bgm = BGM_Ygl_01,
              time = 240,
              ID = 169,
              unit = u.handle
            })
          end)
          local count = u:getdata("雨宫莲-怪盗团成员数量")
          u:addallstats(5 * count)
          u:changedata("全属性增幅", 0.015 * count)
          u:uivar_change({
            keyname = "雨宫莲",
            keytype = "传奇栏",
            text = "|cFFFAF9F6心|r|cFF837E7A之|r|cFFCC0000怪盗团|r\n|cFFCC0000影 念力 同奏\n劳尔|r\n|cFFBE504C根据自身周围1000范围怪物数量,提升[4%*数量]暴击率与[8%*数量]暴击伤害|r\n|cFFCC0000反抗神祇之人|r\n|cFFBE504C提升[波数*1%]伤害加成\n提升[波数*1%]伤害加成|r\n|cFFCC0000逆境的觉悟|r\n|cFFBE504C获取时提升[(5+1.5%)*怪盗团成员数量]全属性\n暴击率超过100%的部分以1:1转换为暴击伤害|r\n|cFFCC0000不羁之力|r\n|cFFBE504C怪盗团属性效果提升50%\n杀敌时提升0.01%伤害加成与0.01%伤害加成|r",
            icon = "BTNEwl_Ygl_Jinjie"
          })
        else
          u:sendmessage("|cFF7DBEF1成员数量不足|r")
        end
      end
    end,
    weight = 100,
    key = {
      "唯一",
      "影",
      "念力",
      "同奏"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      if not u:hasdata("系统-特殊获取中") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Sound_Ygl_01)
      SendMsgAll("|cFF6699FF「|r|cFF6A99FF这|r|cFF6E99FF是|r|cFF7199FF一|r|cFF7599FF个|r|cFF7999FF不|r|cFF7D99FF极|r|cFF8099FF为|r|cFF8499FF不|r|cFF8899FF合|r|cFF8C99FF理|r|cFF9099FF的|r|cFF9399FF游|r|cFF9799FF戏|r|cFF9B99FF，|r|cFF9F99FF胜|r|cFFA299FF算|r|cFFA699FF几|r|cFFAA99FF乎|r|cFFAE99FF等|r|cFFB299FF同|r|cFFB599FF于|r|cFFB999FF没|r|cFFBD99FF有|r|cFFC199FF。|r|cFFC499FF」|r")
      ac.wait(6700, function()
        SendMsgAll("|cFF6699FF「|r|cFF6999FF但|r|cFF6C99FF是|r|cFF7099FF,|r|cFF7399FF既|r|cFF7699FF然|r|cFF7999FF你|r|cFF7C99FF能|r|cFF8099FF听|r|cFF8399FF到|r|cFF8699FF这|r|cFF8999FF个|r|cFF8C99FF声|r|cFF8F99FF音|r|cFF9399FF,|r|cFF9699FF那|r|cFF9999FF应|r|cFF9C99FF该|r|cFF9F99FF还|r|cFFA399FF残|r|cFFA699FF留|r|cFFA999FF着|r|cFFAC99FF一|r|cFFAF99FF丝|r|cFFB299FF可|r|cFFB699FF能|r|cFFB999FF性|r|cFFBC99FF.|r|cFFBF99FF.|r|cFFC299FF.|r|cFFC699FF」|r")
      end)
      ac.wait(15000, function()
        SendMsgAll("|cFF6633FF「|r|cFF6A2FED怎|r|cFF6D2CDB么|r|cFF7128C8了|r|cFF7524B6?|r|cFF7821A4只|r|cFF7C1D92是|r|cFF7F197F看|r|cFF83166D着|r|cFF87125B么|r|cFF8A0F49?|r|cFF8E0B37 |r|cFF920724」|r")
      end)
      ac.wait(19000, function()
        SendMsgAll("|cFF6633FF「|r|cFF6930EF为|r|cFF6C2DDF了|r|cFF7029CF明|r|cFF7326BF哲|r|cFF7623AF保|r|cFF79209F身|r|cFF7C1D8F要|r|cFF801A80见|r|cFF831670死|r|cFF861360不|r|cFF891050救|r|cFF8C0D40么|r|cFF8F0A30？|r|cFF930620」|r")
      end)
      ac.wait(22200, function()
        SendMsgAll("|cFF6633FF「|r|cFF6930EF再|r|cFF6C2DDF这|r|cFF7029CF么|r|cFF7326BF下|r|cFF7623AF去|r|cFF79209F他|r|cFF7C1D8F真|r|cFF801A80的|r|cFF831670要|r|cFF861360死|r|cFF891050了|r|cFF8C0D40哦|r|cFF8F0A30!|r|cFF930620」|r")
      end)
      ac.wait(25300, function()
        SendMsgAll("|cFF6633FF「|r|cFF6930F1还|r|cFF6C2DE3是|r|cFF6E2AD5说|r|cFF7128C6，|r|cFF7425B8那|r|cFF7722AA件|r|cFF7A1F9C事|r|cFF7D1C8E.|r|cFF7F1980.|r|cFF821771.|r|cFF851463是|r|cFF881155错|r|cFF8B0E47的|r|cFF8E0B39么|r|cFF90082B?|r|cFF93061C」|r")
      end)
      u:reduceshw()
      u:setdata("雨宫莲-怪盗团成员数量", 1)
      local bjl = 0
      local bjsh = 0
      ac.loop(1000, function()
        local x, y = u:getxy()
        local count = 0
        for _, xq in ac.selector():in_rangexy(x, y, 1000):is_enemy(u.handle):ipairs() do
          count = count + 1
        end
        ChangeValue(DamageSystem_Baoji, sy, -1 * bjl)
        ChangeValue(DamageSystem_Baoshang, sy, -1 * bjsh)
        bjl = 1 * count
        bjsh = 0.02 * count
        if u:hasdata("雨宫莲-心之怪盗团") then
          bjl = bjl * 4
          bjsh = bjsh * 4
        end
        ChangeValue(DamageSystem_Baoji, sy, 1 * bjl)
        ChangeValue(DamageSystem_Baoshang, sy, 1 * bjsh)
      end)
      local zs = 0
      local lw = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * lw))
        zs = Group_Counts(Group_Guaidaotuan) + u:getdata("雨宫莲-怪盗团成员数量")
        lw = 0.1 * zs
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * lw))
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        u:changedata("雨宫莲-素材数量", GetRandomInt(2, 5))
        ChangeValue(DamageSystem_Shjc, sy, 1.0E-4)
      end)
      local dskill = S2ID("A00G")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if u:getdata("雨宫莲-素材数量") < 150 then
            b = false
            u:sendmessage("|cFFCCCCCC素材不足|r")
          end
          if b then
            u:additem("I0IP")
            u:changedata("雨宫莲-素材数量", -150)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
    end,
    effectname = "|cFFFFFFFF雨|r|cFF949596宫|r|cFFCC0000莲|r",
    effecttext = "|cFFFFFFFF影 念力 同奏\n亚森\n根据自身周围1000范围怪物数量,提升[1%*数量]暴击率与[2%*数量]暴击伤害|r\n|cFF949596不羁之力\n杀敌时获得2~5素材计数\n杀敌时提升0.01%伤害加成|r\n|cFFCC0000心之怪盗团\n提升[(怪盗数量+怪盗团成员数量)*1%]伤害加成\n使用时消耗面具激发人格面具的力量|r",
    effectart = "BTNEwl_Ygl_01"
  },
  {
    name = "幽灵鲨",
    weight = 5,
    lv = 5,
    key = {
      "唯一",
      "战士",
      "水",
      "白毛",
      "黑暗"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      if u:ishasitem("I04I") or u:ishasitem("I04K") then
        add = add + 3000
      end
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("判定-幽灵鲨") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      if not u:hasdata("深海姐妹-消耗神化位") then
        u:setdata("深海姐妹-消耗神化位")
        u:setplayername("|cFF7DBEF1[|r|cFF0041FF스펙터|r|cFF7DBEF1]|r" .. NameID[sy])
      else
        u:setplayername("|cFF7DBEF1[|r|cFF6699FF深|r|cFF5C8FFF海|r|cFF5285FF姐|r|cFF477AFF妹|r|cFF7DBEF1]|r" .. NameID[sy])
      end
      u:chat("……听，茫茫的万物之主，在黑暗中，喃喃自语……")
      u:setdata("属性-海洋神化")
      PlayGlobalSound(Sound_Specter_Get)
      u:become("深海猎人")
      u:changeysnd(0.01)
      u:changexueroutonghua(0.01)
      ac.wait(10, function()
        u:uivar_change({
          keyname = "幽灵鲨",
          keytype = "传奇栏",
          icon = "Ewl_Yls_BigIcon.blp",
          ishasphoto = true,
          smallicon = "Ewl_Yls_SmallIcon.blp"
        })
      end)
      if u:islocal() then
        BuffUI.apply({
          id = "幽灵鲨-低语值计数",
          duration = 99999
        })
      end
      u:setdata("幽灵鲨-低语值", 0)
      local add = 0
      local add2 = 0
      local gs = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        local zd = u:returnmaxvar()
        add = 0.1 * u:getdata(zd .. "变异数量")
        if u:hasdata("幽灵鲨-终焉之音") then
          add = add + 1 * u:getdata("肉斩骨断次数")
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        u:changedata("固定伤害", 0.1 * -gs)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add2)
        local count = u:getdata("幽灵鲨-低语值")
        gs = count * 1
        add2 = 1.0E-4 * count
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add2)
        u:changedata("固定伤害", 0.1 * gs)
      end)
      u:addstexiao(var.name, "受伤后效果", function(args)
        local sh = args.damage
        if 0 < sh and not u:hasdata("幽灵鲨-受伤低语值冷却") then
          u:changedata("幽灵鲨-低语值", 10)
          u:settimedata("幽灵鲨-受伤低语值冷却", 1)
        end
      end)
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        local addz = 0
        if tg:isboss() then
          addz = 1000
        elseif tg:iselite() then
          addz = 100
        else
          addz = 10
        end
        if u:hasdata("幽灵鲨-伤鸣节拍") then
          addz = addz + 5
        end
        u:changedata("幽灵鲨-低语值", addz)
      end)
      local c = 0
      local v = 20
      ac.loop(100, function()
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, -1 * c)
        if u:isalive() and u:hasdata("幽灵鲨-伤鸣节拍") then
          local mhp = 75
          v = 20
          if u:hasdata("幽灵鲨-痛觉止符") then
            mhp = 50
            v = 15
          end
          if u:hasdata("幽灵鲨-兽穷则啮") then
            mhp = 25
            v = 10
          end
          if u:hasdata("幽灵鲨-终焉之音") then
            mhp = 1
            v = 5
          end
          c = (mhp - u:getperhp()) / v
        else
          c = 0
        end
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, 1 * c)
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata("幽灵鲨-特效低语值冷却") then
          u:changedata("幽灵鲨-低语值", 1)
          u:settimedata("幽灵鲨-特效低语值冷却", 0.1)
        end
        if u:hasdata("幽灵鲨-伤鸣节拍") and u:getluckrandom(5 * info.txgl) and not u:hasdata(var.name .. "-减甲特效冷却") then
          u:settimedata(var.name .. "-减甲特效冷却", 0.5)
          tg:buffset(u.handle, 1, "僵直")
          tg:effectadd("war3mapImported\\[TxNew1]001.mdl", "chest")
          tg:changetimearmor(-5, 10)
        end
        if u:hasdata("幽灵鲨-痛觉止符") and not u:hasdata(var.name .. "-痛觉止符冷却") then
          u:settimedata(var.name .. "-痛觉止符冷却", 1)
          local txsh = info.yssh * 0.14
          local x2, y2 = tg:getxy()
          local cs = 0
          local g = CreateGroupLua()
          ac.loop(100, function(timer)
            cs = cs + 1
            for _, xq in ac.selector():in_rangexy(x2, y2, 450):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              xq:groupadd(g)
            end
            if Group_Counts(g) > 0 then
              local xq = Group_Randomunit(g)
              local x3, y3 = xq:getxy()
              Effectcreate("war3mapImported\\[TxNew]T22 (2).mdl", x3, y3)
              Effectcreate("Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl", x3, y3)
              DamageUnit({
                bj = "幽灵鲨(痛觉止符)",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "物理",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "无"
              })
            end
            if cs == 7 or Group_Counts(g) == 0 then
              timer:remove()
            end
          end)
        end
      end)
      
      local function skill(args)
        if u:isalive() then
          if args.chat == "-arfix" and u:hasdata("幽灵鲨-痛觉止符") then
            if u:ishasskill("A13T") then
              u:banskill("A13T", false)
              u:banskill("A13U", false)
            else
              ARskillreplace({
                unit = u.handle,
                level = 2,
                skill_A = "A13T",
                skill_R = "A13U",
                isforce = false,
                efunc = function()
                end
              })
            end
          end
          if args.chat == "伤鸣节拍" and not u:hasdata("幽灵鲨-伤鸣节拍") and u:getdata("幽灵鲨-低语值") >= 1500 then
            u:setdata("幽灵鲨-伤鸣节拍")
            ChangeValue(DamageSystem_Baoji, sy, 12)
            ChangeValue(DamageSystem_Baoshang, sy, 0.24)
            PlayGlobalSound(Sound_Specter_Teshu01)
            u:chat("力量……流入了我的身体……")
            u:addskill("S063")
            u:uivar_change({
              keyname = "幽灵鲨",
              keytype = "传奇栏",
              text = "|cFF3366FF幽|r|cFF4C4CBF灵|r|cFF663380鲨|r\n|cFFCC66FF[超凡]|r\n|cFF3366FF水 战士 黑暗 白毛 海嗣 唯一|r\n|cFF4C4CBF提升[1%*主变异数量]伤害加成|r\n|cFF3366FF【情绪吸收】|r\n|cFF4C4CBF直接伤害时获得1点低语值,冷却0.1秒\n受伤时获得10点低语值,冷却1秒\n杀敌时获得10(100/1000)点低语值\n提升[低语值*0.1]固定伤害\n提升[低语值*0.001%]伤害加成|r\n|cFF3366FF【伤鸣节拍】|r\n|cFF4C4CBF生命值趋向75%\n提升12%暴击率\n提升24%暴击伤害\n杀敌时额外获取5点低语值\n直接伤害时5%使目标10秒内降低5点护甲并僵直1秒,冷却0.5秒|r\n|cFF3366FF【痛觉止符】|r\n|cFF4C4CBF- 需\"伤鸣节拍\"已解锁\n- 需低语值达到3000时输入\"痛觉止符\"解锁|r\n|cFF3366FF【兽穷则啮】|r\n|cFF4C4CBF- 需\"痛觉止符\"已解锁\n- 需低语值达到4500时输入\"兽穷则啮\"解锁|r\n|cFF3366FF【终焉之音】\n|cFF4C4CBF- 需\"兽穷则啮\"已解锁\n- 需低语值达到6000时输入\"终焉之音\"解锁|r"
            })
          end
          if args.chat == "痛觉止符" and u:hasdata("幽灵鲨-伤鸣节拍") and not u:hasdata("幽灵鲨-痛觉止符") and u:getdata("幽灵鲨-低语值") >= 3000 then
            u:setdata("幽灵鲨-痛觉止符")
            PlayGlobalSound(Sound_Specter_Teshu02)
            u:chat("呵呵，切割啊……切割是件很快乐的事")
            ac.wait(9700, function()
              u:chat("是啊，有些东西，相互之间并什么没有联系，从一开始，就不该结合在一起……")
            end)
            ChangeValue(Correction_Jzsh, sy, 0.05)
            u:changedata("效果增强-背水", 0.25)
            u:addstexiao(var.name, "近战伤害特效", function(args)
              local tg = args.tg
              local u = args.u
              local info = args.damageinfo
              if not u:hasdata("幽灵鲨-血旋冷却") then
                local x, y = u:getxy()
                u:settimedata("幽灵鲨-血旋冷却", 5)
                Effectcreate("war3mapImported\\texiao_YLS6.mdx", x, y, 1, 4, 0, GetRandomAngle())
                Effectcreate("war3mapImported\\texiao_YLS5.mdx", x, y, 1, 1)
                local txsh = 25000 + 1000 * u:getlevel()
                for _, xq in ac.selector():in_rangexy(x, y, 750):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  local xs = 0
                  if xq:isnormal() then
                    xs = 0.05 * xq:getmaxhp()
                  else
                    xs = 0.005 * xq:gethp()
                  end
                  xq:effectadd("Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl", "chest")
                  Effectcreate("Objects\\Spawnmodels\\Undead\\UndeadLargeDeathExplode\\UndeadLargeDeathExplode.mdl", x, y)
                  xq:buffset(u.handle, 2, "眩晕")
                  LossHpUnit({
                    u = u,
                    tg = xq,
                    damage = xs,
                    perhp = 0,
                    maxhp = 0,
                    bj = "[生命损耗]幽灵鲨(痛觉止符)"
                  })
                  DamageUnit({
                    bj = "幽灵鲨(痛觉止符)",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    type = "物理",
                    isvest = true,
                    isattack = true,
                    extradata = {"近战"}
                  })
                end
              end
            end)
            ARskillreplace({
              unit = u.handle,
              level = 2,
              skill_A = "A13T",
              skill_R = "A13U",
              isforce = false,
              efunc = function()
                gunban(u.handle)
                ac.loop(3000, function()
                  gunban(u.handle)
                end)
                
                local function skill(args)
                  if args.skill == S2ID("A13T") then
                    local tilixh = 1
                    local skill = S2ID("A13T")
                    if not u:hasdata("位移体力消耗标记") then
                      if u:lossstamina(tilixh) then
                        u:settimedata("位移体力消耗标记", 0.001)
                      else
                        u:setskillcd(skill, 0.01)
                        u:sendmessage("|cFFFF3300体力值不足|r")
                        return
                      end
                    end
                    local sy = u.ownerid
                    local x, y = u:getxy()
                    local x2 = args.x
                    local y2 = args.y
                    local angle = AngleXY(x, y, x2, y2)
                    local dis = DistanceXY(x, y, x2, y2)
                    if 1200 <= dis then
                      dis = 1200
                    end
                    local txsh = 10000 + 1000 * u:getlevel() + 100 * u:getallattri()
                    txsh = txsh * 1.1 ^ u:getdata("幽灵鲨-串刺叠加伤害次数")
                    Effectcreate("war3mapImported\\nitu.mdl", x, y, 0, 1, 0, angle)
                    u:buffset(u.handle, 0.2, "绝对闪避")
                    local tx = Effectcreate("war3mapImported\\[TxNew]T23.mdl", x, y, -1, 1, 0, angle)
                    unitmove({
                      unit = u.handle,
                      time = 0.2,
                      distance = dis,
                      angle = angle,
                      loops = {
                        {
                          looptime = 0.02,
                          func = function(dx, dy)
                            SetEffectXY(tx, dx, dy)
                            for _, xq in ac.selector():in_rangexy(dx, dy, 225):is_enemy(u.handle):ipairs() do
                              xq = getunit(xq)
                              xq:buffset(u.handle, 0.25, "暂停")
                              if not xq:hasdata("免疫击退效果") then
                                xq:setxy(dx, dy)
                              end
                            end
                          end
                        },
                        {
                          looptime = 0.04,
                          func = function(dx, dy)
                            Effectcreate("war3mapImported\\effect gran rey cero by deckai 3.mdl", dx, dy, 5, 2, 0, angle + 180)
                            Effectcreate("war3mapImported\\bbb.mdx", dx, dy)
                          end
                        }
                      },
                      endfunc = function(dx, dy)
                        DestroyEffectLua(tx)
                        Effectcreate("war3mapImported\\texiao_YLS7.mdl", dx, dy)
                        Effectcreate("war3mapImported\\[TX] (1335).mdl", dx, dy, 0, 2)
                        local b = false
                        for _, xq in ac.selector():in_rangexy(dx, dy, 275):is_enemy(u.handle):ipairs() do
                          xq = getunit(xq)
                          xq:buffset(u.handle, 0.9, "眩晕")
                          xq:animeact("death")
                          xq:effectadd("war3mapImported\\texiao_xuebao.mdx", "chest")
                          u:setdata("世界之门-伤害加成", 4)
                          DamageUnit({
                            bj = "幽灵鲨(串刺)",
                            unit = xq.handle,
                            source = u.handle,
                            damage = txsh,
                            level = 1,
                            type = "物理",
                            isvest = false,
                            isattack = true,
                            isnoarmor = false,
                            element = "无",
                            extradata = {"近战"}
                          })
                          u:deldata("世界之门-伤害加成")
                          unitmove({
                            unit = xq.handle,
                            time = 0.5,
                            distance = 250,
                            angle = AngleBetweenUnits(u.handle, xq.handle)
                          })
                          if xq:isboss() then
                            b = true
                          end
                        end
                        if b then
                          u:changetimedata("幽灵鲨-串刺叠加伤害次数", 1, 10)
                        end
                      end
                    })
                  end
                  if args.skill == S2ID("A13U") then
                    local tilixh = 2
                    local skill = S2ID("A13U")
                    if not u:hasdata("位移体力消耗标记") then
                      if u:lossstamina(tilixh) then
                        u:settimedata("位移体力消耗标记", 0.001)
                      else
                        u:setskillcd(skill, 0.01)
                        u:sendmessage("|cFFFF3300体力值不足|r")
                        return
                      end
                    end
                    local sy = u.ownerid
                    local x, y = u:getxy()
                    local x2 = args.x
                    local y2 = args.y
                    local angle = AngleXY(x, y, x2, y2)
                    local dis = DistanceXY(x, y, x2, y2)
                    local txsh = 20000 + 2000 * u:getlevel() + 100 * u:getallattri()
                    txsh = txsh * 1.1 ^ u:getdata("幽灵鲨-串刺叠加伤害次数")
                    if 1600 <= dis then
                      dis = 1600
                    end
                    Effectcreate("war3mapImported\\blackblink.mdl", x, y)
                    Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
                    Effectcreate("war3mapImported\\bbb.mdx", x, y)
                    Effectcreate("war3mapImported\\blackblink.mdl", x2, y2, 0, 1, 500, angle)
                    u:setflyheight(300)
                    u:buffset(u.handle, 0.6, "无敌")
                    u:buffset(u.handle, 0.4, "暂停")
                    u:buffset(u.handle, 1, "绝对闪避")
                    u:setxy(x2, y2)
                    ac.wait(100, function()
                      u:setflyheight(0, 10000)
                      ac.wait(100, function()
                        u:playsound(ThunderClapCaster)
                        Effectcreate("war3mapImported\\bbb.mdx", x2, y2, 0, 2)
                        Effectcreate("war3mapImported\\effect_by_wood_effect_d2_shadowfiend_shadowraze_1.mdl", x2, y2, 0.1, 2)
                        Effectcreate("war3mapImported\\effect_red-texiao-shandian.mdl", x2, y2, 1, 2)
                        ac.timer(100, 10, function()
                          Effectcreate("war3mapImported\\texiao_YLS7.mdx", x2, y2, 1, 1, 0, GetRandomAngle())
                          Effectcreate("war3mapImported\\texiao_YLS6.mdx", x2, y2, 0, 2.5, 0, GetRandomAngle())
                          Effectcreate("war3mapImported\\176.mdx", x2 + GetRandomReal(-400, 400), y2 + GetRandomReal(-400, 400), 7, 0.5, 0, GetRandomAngle())
                          u:playsound(ImpaleHit)
                          for _, xq in ac.selector():in_rangexy(x2, y2, 400):is_enemy(u.handle):ipairs() do
                            xq = getunit(xq)
                            xq:buffset(u.handle, 0.25, "眩晕")
                            DamageUnit({
                              bj = "幽灵鲨(技能)",
                              unit = xq.handle,
                              source = u.handle,
                              damage = txsh,
                              level = 1,
                              type = "物理",
                              isvest = false,
                              isattack = true,
                              isnoarmor = false,
                              element = "无",
                              extradata = {"近战"}
                            })
                          end
                        end)
                      end)
                    end)
                  end
                end
                
                u:addtrgevent("单位-发动技能", function(args)
                  skill(args)
                end)
              end
            })
            u:addskill("S06E")
            u:uivar_change({
              keyname = "幽灵鲨",
              keytype = "传奇栏",
              text = "|cFFA32929幽|r|cFFAD5252灵|r|cffc7c7c7鲨|r\n|cFFCC66FF[超凡]|r\n|cFFA32929水 战士 黑暗 白毛 海嗣 唯一|r\n|cffc7c7c7提升[1%*主变异数量]伤害加成|r\n|cFFA32929【情绪吸收】|r\n|cffc7c7c7直接伤害时获得1点低语值,冷却0.1秒\n受伤时获得10点低语值,冷却1秒\n杀敌时获得10(100/1000)点低语值\n提升[低语值*0.1]固定伤害\n提升[低语值*0.001%]伤害加成|r\n|cFFA32929【伤鸣节拍】|r\n|cffc7c7c7提升12%暴击率\n提升24%暴击伤害\n杀敌时额外获取5点低语值\n直接伤害时5%使目标10秒内降低5点护甲并僵直1秒,冷却0.5秒|r\n|cFFA32929【痛觉止符】|r\n|cffc7c7c7生命值趋向50%\n提升25%背水效果\n替换AR技能\n提升5%近战伤害\n直接伤害时附带7次450范围[14%*伤害值]物理伤害,冷却1秒\n近战伤害附带[25000+1000*等级]750范围近战物理伤害与[5%最大(0.5%当前)]生命损耗,冷却5秒|r\n|cFFA32929【兽穷则啮】|r\n|cffc7c7c7- 需\"痛觉止符\"已解锁\n- 需低语值达到4500时输入\"兽穷则啮\"解锁|r\n|cFFA32929【终焉之音】|r\n|cffc7c7c7- 需\"兽穷则啮\"已解锁\n- 需低语值达到6000时输入\"终焉之音\"解锁|r",
              icon = "Ewl_Yls_BigIcon2.blp",
              ishasphoto = true,
              smallicon = "Ewl_Yls_SmallIcon.blp"
            })
          end
          if args.chat == "兽穷则啮" and u:hasdata("幽灵鲨-痛觉止符") and not u:hasdata("幽灵鲨-兽穷则啮") and u:getdata("幽灵鲨-低语值") >= 4500 then
            u:setdata("幽灵鲨-兽穷则啮")
            ChangeValue(Correction_Cbxs, sy, 0.12)
            ChangeValue(DamageSystem_XxzJz, sy, 15)
            ChangeValue(DamageSystem_XxzJzLv, sy, 4)
            ChangeValue(DamageSystem_Xxz, sy, 15)
            ChangeValue(DamageSystem_XxzLv, sy, 4)
            ChangeValue(DamageSystem_Baoji, sy, 12)
            ChangeValue(DamageSystem_Baoshang, sy, 0.24)
            u:addhealthrefresh(function(set_value, bs)
              set_value(u, "固定伤害", 2 * bs * u:getmaxhp())
            end)
            PlayGlobalSound(Sound_Specter_Teshu03)
            u:chat("呵呵呵……哈哈……哈哈哈哈……")
            u:addskill("S06D")
            u:uivar_change({
              keyname = "幽灵鲨",
              keytype = "传奇栏",
              text = "|cFFA32929幽|r|cFFAD5252灵|r|cffc7c7c7鲨|r\n|cFFCC66FF[超凡]|r\n|cFFA32929水 战士 黑暗 白毛 海嗣 唯一|r\n|cffc7c7c7提升[1%*主变异数量]伤害加成|r\n|cFFA32929【情绪吸收】|r\n|cffc7c7c7直接伤害时获得1点低语值,冷却0.1秒\n受伤时获得10点低语值,冷却1秒\n杀敌时获得10(100/1000)点低语值\n提升[低语值*0.1]固定伤害\n提升[低语值*0.001%]伤害加成|r\n|cFFA32929【伤鸣节拍】|r\n|cffc7c7c7提升12%暴击率\n提升24%暴击伤害\n杀敌时额外获取5点低语值\n直接伤害时5%使目标10秒内降低5点护甲并僵直1秒,冷却0.5秒|r\n|cFFA32929【痛觉止符】|r\n|cffc7c7c7提升25%背水效果\n替换AR技能\n提升5%近战伤害\n直接伤害时附带7次450范围[14%*伤害值]物理伤害,冷却1秒\n近战伤害附带[25000+1000*等级]750范围近战物理伤害与[5%最大(0.1%当前)]生命损耗,冷却5秒|r\n|cFFA32929【兽穷则啮】|r\n|cffc7c7c7生命值趋向25%\n提升0.12超暴系数\n提升12%暴击率\n提升24%暴击伤害\n提升[15+等级*4]近战吸血\n提升[15+等级*4]伤害吸血\n提升[背水*生命上限*0.2]固定伤害|r\n|cFFA32929【终焉之音】|r\n|cffc7c7c7- 需\"兽穷则啮\"已解锁\n- 需低语值达到6000时输入\"终焉之音\"解锁|r"
            })
          end
          if args.chat == "终焉之音" and u:hasdata("幽灵鲨-兽穷则啮") and not u:hasdata("幽灵鲨-终焉之音") and u:getdata("幽灵鲨-低语值") >= 6000 then
            PlayGlobalSound(Sound_Specter_End02)
            u:chat("那个人告诉我的都是对的……")
            ac.wait(9000, function()
              u:chat("解剖、撕裂、切碎，一切都是、都是给予他们的救赎！")
            end)
            u:setdata("幽灵鲨-终焉之音")
            if u:islocal() then
              BuffUI.apply({
                id = "幽灵鲨-肉斩骨断计数",
                duration = 99999
              })
            end
            u:setdata("肉斩骨断次数", 5)
            ac.loop(100000, function()
              if u:getdata("肉斩骨断次数") < 5 then
                u:changedata("肉斩骨断次数", 1)
                u:sendmessage("|cFF990000[肉骨斩断]恢复次数|r")
              end
            end)
            u:uivar_change({
              keyname = "幽灵鲨",
              keytype = "传奇栏",
              text = "|cFFA32929幽|r|cFFAD5252灵|r|cffc7c7c7鲨|r\n|cFFCC66FF[超凡]|r\n|cFFA32929水 战士 黑暗 白毛 海嗣 唯一|r\n|cffc7c7c7提升[1%*主变异数量]伤害加成|r\n|cFFA32929【情绪吸收】|r\n|cffc7c7c7直接伤害时获得1点低语值,冷却0.1秒\n受伤时获得10点低语值,冷却1秒\n杀敌时获得10(100/1000)点低语值\n提升[低语值*0.1]固定伤害\n提升[低语值*0.001%]伤害加成|r\n|cFFA32929【伤鸣节拍】|r\n|cffc7c7c7提升12%暴击率\n提升24%暴击伤害\n杀敌时额外获取5点低语值\n直接伤害时5%使目标10秒内降低5点护甲并僵直1秒,冷却0.5秒|r\n|cFFA32929【痛觉止符】|r\n|cffc7c7c7提升25%背水效果\n替换AR技能\n提升5%近战伤害\n直接伤害时附带7次450范围[14%*伤害值]物理伤害,冷却1秒\n近战伤害附带[25000+1000*等级]750范围近战物理伤害与[5%最大(0.5%当前)]生命损耗,冷却5秒|r\n|cFFA32929【兽穷则啮】|r\n|cffc7c7c7提升0.12超暴系数\n提升12%暴击率\n提升24%暴击伤害\n提升[15+等级*4]近战吸血\n提升[15+等级*4]伤害吸血\n提升[背水*生命上限*0.2]固定伤害|r\n|cFFA32929【终焉之音】|r\n|cffc7c7c7生命值趋向1%\n提升[肉斩骨断层数*10%]伤害加成\n获得5层[肉斩骨断]\n每层[肉斩骨断]在受到致死伤害时抵挡并消耗,获得[500*等级]临时护盾\n每100秒恢复1层[肉斩骨断],上限5层\n死亡时立刻恢复3层[肉斩骨断]\n彻底死亡时删模|r"
            })
          end
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        skill(args)
      end)
    end,
    effectname = "|cFF3366FF幽|r|cFF4C4CBF灵|r|cFF663380鲨|r",
    effecttext = "|cFFCC66FF[超凡]|r\n|cFF3366FF水 战士 黑暗 白毛 海嗣 唯一|r\n|cFF4C4CBF提升[1%*主变异数量]伤害加成|r\n|cFF3366FF【情绪吸收】|r\n|cFF4C4CBF直接伤害时获得1点低语值,冷却0.1秒\n受伤时获得10点低语值,冷却1秒\n杀敌时获得10(100/1000)点低语值\n提升[低语值*0.1]固定伤害\n提升[低语值*0.001%]伤害加成|r\n|cFF3366FF【伤鸣节拍】|r\n|cFF4C4CBF- 需低语值达到1500时输入\"伤鸣节拍\"解锁|r\n|cFF3366FF【痛觉止符】|r\n|cFF4C4CBF- 需\"伤鸣节拍\"已解锁\n- 需低语值达到3000时输入\"痛觉止符\"解锁|r\n|cFF3366FF【兽穷则啮】|r\n|cFF4C4CBF- 需\"痛觉止符\"已解锁\n- 需低语值达到4500时输入\"兽穷则啮\"解锁|r\n|cFF3366FF【终焉之音】\n|cFF4C4CBF- 需\"兽穷则啮\"已解锁\n- 需低语值达到6000时输入\"终焉之音\"解锁|r",
    effectart = "war3mapImported\\BTNEwl_Yls.blp"
  },
  {
    name = "斯卡蒂",
    weight = 5,
    lv = 3,
    key = {
      "唯一",
      "战士",
      "水",
      "白毛",
      "光明"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      if u:ishasitem("I04J") or u:ishasitem("I04K") then
        add = add + 3000
      end
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:hasdata("判定-斯卡蒂") then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      if not u:hasdata("深海姐妹-消耗神化位") then
        u:setdata("深海姐妹-消耗神化位")
        u:setplayername("|cFF7DBEF1[|r|cFF0041FF斯卡蒂|r|cFF7DBEF1]|r" .. NameID[sy])
      else
        u:setplayername("|cFF7DBEF1[|r|cFF6699FF深|r|cFF5C8FFF海|r|cFF5285FF姐|r|cFF477AFF妹|r|cFF7DBEF1]|r" .. NameID[sy])
      end
      SendMsgAll("|cFF0000FF『|r|cFF1313FF斯|r|cFF2525FF卡|r|cFF3838FF蒂|r|cFF4A4AFF，|r|cFF5D5DFF赏|r|cFF6F6FFF金|r|cFF8282FF猎|r|cFF9494FF人|r|cFFA7A7FF』|r")
      ac.wait(4100, function()
        SendMsgAll("|cFF0000FF『|r|cFF0B0BFF我|r|cFF1515FF可|r|cFF2020FF是|r|cFF2B2BFF那|r|cFF3636FF种|r|cFF4040FF，|r|cFF4B4BFF会|r|cFF5656FF给|r|cFF6161FF你|r|cFF6B6BFF带|r|cFF7676FF来|r|cFF8181FF灾|r|cFF8C8CFF祸|r|cFF9696FF的|r|cFFA1A1FF人|r|cFFACACFF哦|r|cFFB7B7FF』|r")
      end)
      u:setdata("属性-海洋神化")
      PlayGlobalSound(Sound_Skd_Get)
      u:become("深海猎人")
      u:changeysnd(0.01)
      u:changexueroutonghua(0.01)
      Danwei_Skd = u.handle
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
      ac.wait(10, function()
        u:uivar_change({
          keyname = "斯卡蒂",
          keytype = "传奇栏",
          icon = "Ewl_Skd_BigIcon.blp",
          ishasphoto = true,
          smallicon = "Ewl_Skd_SmallIcon.blp"
        })
      end)
      local add = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        local zd = u:returnmaxvar()
        add = 0.15 * u:getdata(zd .. "变异数量")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        if u:hasdata("系统-水域中") then
          if not u:hasdata("斯卡蒂-水域强化") then
            u:setdata("斯卡蒂-水域强化")
            ChangeValue(HeroMenu_HpChange_MaxHp, sy, 0.25)
            ChangeValue(Hero_Tili_Huifu, sy, 0.5)
          end
        elseif u:hasdata("斯卡蒂-水域强化") then
          u:deldata("斯卡蒂-水域强化")
          ChangeValue(HeroMenu_HpChange_MaxHp, sy, -0.25)
          ChangeValue(Hero_Tili_Huifu, sy, -0.5)
        end
        local b = true
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq.handle ~= u.handle and DistanceBetweenUnits(u.handle, xq.handle) <= 3000 then
            b = false
          end
        end)
        if b then
          if not u:hasdata("斯卡蒂-独处强化") then
            u:setdata("斯卡蒂-独处强化")
            ChangeValue(DamageSystem_Shjc, sy, 0.1)
            ChangeValue(DamageSystem_Baoji, sy, 12)
            ChangeValue(DamageSystem_Baoshang, sy, 0.24)
          end
        elseif u:hasdata("斯卡蒂-独处强化") then
          u:deldata("斯卡蒂-独处强化")
          ChangeValue(DamageSystem_Shjc, sy, -0.1)
          ChangeValue(DamageSystem_Baoji, sy, -12)
          ChangeValue(DamageSystem_Baoshang, sy, -0.24)
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not tg:hasdata("巨物猎杀破甲") then
          tg:setdata("巨物猎杀破甲")
          tg:changearmor(-50)
        end
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(var.name .. "-特效冷却", 0.5)
          local x, y = tg:getxy()
          local txsh = 2000 * u:getlevel()
          Effectcreate("Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl", x, y)
          Effectcreate("war3mapImported\\blue-guangzhu-special.mdx", x, y)
          for _, xq in ac.selector():in_rangexy(x, y, 225):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "斯卡蒂(附伤)",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "水"
            })
          end
        end
      end)
      u:addskill("S02L")
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("斯卡蒂-水域强化") then
          info.wssb = true
          info.wsmy = true
        end
      end)
      local dskill
      if u:ishasskill("A1AM") and u.type ~= HeroType["C呆"] and u.type ~= HeroType["莲华"] then
        dskill = "A1S9"
      else
        dskill = "A0PD"
      end
      Fskillreplace({
        unit = u.handle,
        level = 2,
        skill_F = dskill,
        skill_X = dskill,
        isforce = false,
        efunc = function()
          local function skill(args)
            if args.skill == S2ID(dskill) then
              local tilixh = 2
              
              local skill = S2ID(dskill)
              if not u:hasdata("位移体力消耗标记") then
                if u:lossstamina(tilixh) then
                  u:settimedata("位移体力消耗标记", 0.001)
                else
                  u:setskillcd(skill, 0.01)
                  u:sendmessage("|cFFFF3300体力值不足|r")
                  return
                end
              end
              local sy = u.ownerid
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local angle = AngleXY(x, y, x2, y2)
              local dis = DistanceXY(x, y, x2, y2)
              if 2500 <= dis then
                dis = 2500
              end
              x2, y2 = PolarXY(x, y, dis, angle)
              Effectcreate("Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl", x, y)
              Effectcreate("Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl", x2, y2)
              Effectcreate("war3mapImported\\3.23.1102.mdx", x2, y2, 0, 2)
              u:buffset(u.handle, 0.3, "绝对闪避")
              u:setxy(x2, y2)
              u:settimedata("跃浪击-水域", 5)
              ChangeTimeValue(DamageSystem_Shjc, sy, 0.05, 5)
              ChangeTimeValue(DamageSystem_Shjc, sy, 0.05, 10)
              ChangeTimeValue(DamageSystem_Shjc, sy, 0.05, 15)
              for _, xq in ac.selector():in_rangexy(x2, y2, 450):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:buffset(u.handle, 2, "眩晕")
                xq:buffset(u.handle, 5, "破坏-伤害抗性")
              end
              local yx = {
                Sound_Skd_F1,
                Sound_Skd_F2,
                Sound_Skd_F3,
                Sound_Skd_F4,
                Sound_Skd_F5,
                Sound_Skd_F6
              }
              u:playsound(yx[GetRandomInt(1, #yx)])
            end
          end
          
          u:addtrgevent("单位-发动技能", function(args)
            skill(args)
          end)
        end
      })
    end,
    effectname = "|cFF3366FF斯|r|cFF668CFF卡|r|cFF99B2FF蒂|r",
    effecttext = "|cFFFFAA00[传奇]|r\n|cFF3366FF水 战士 光明 白毛 海嗣 唯一|r\n|cFF99B2FF提升[1.5%*主变异数量]伤害加成|r\n|cFF3366FF【巨物猎杀】|r\n|cFF99B2FF直接伤害时降低目标50护甲,无法叠加|r\n|cFF3366FF【迅捷打击】|r\n|cFF99B2FF提升25额外移速\n提升100%移速|r\n|cFF3366FF【跃浪击】|r\n|cFF99B2FF变化F技能\n直接伤害时10%附带225范围[2000*等级]水魔力伤害,冷却0.5秒\n自身处于水域时:\n[提升0.25%生命恢复\n提升0.5体力恢复\n无视地形\n无视伤害免疫与闪避]|r\n|cFF3366FF【独处】|r\n|cFF99B2FF周围3000范围没有友军时:\n[提升10%伤害加成\n提升12%暴击率\n提升24%暴击伤害]|r\n|cFF3366FF【涌潮悲歌】|r\n|cFF99B2FF[数据删除]|r",
    effectart = "war3mapImported\\BTNEwl_Skadi.blp"
  },
  {
    name = "惠惠",
    clickfunc = function(u)
      if u:isalive() then
        local sy = u.ownerid
        local lv = u:getdata("惠惠-暴走魔法阶级")
        if lv == 1 then
          if Damage_Element_Fire[sy] - u:getdata("惠惠-红魔族加成") >= 0.55 then
            u:sendmessage("|cFFCC0000进阶成功|r")
            u:changedata("惠惠-暴走魔法阶级", 1)
            ChangeValue(Damage_Element_Fire, sy, 0.05)
            ChangeValue(Damage_Element_All, sy, -0.05)
            u:uivar_change({
              keyname = "惠惠",
              keytype = "传奇栏",
              text = "|cFFDD001A惠|r|cFFBA0033惠|r\n|cFFDD001A魔导 炎\n爆裂魔法|r\n|cFFCC0000使用爆裂魔法前每句吟唱咒语提升150%爆裂魔法基础伤害\n吟唱“Explosion”在前方500码处发动爆裂魔法造成[10000+智力*25]点火属性魔力伤害,发动后自己会瘫痪9秒\n冷却时间 一天（480秒)|r\n|cFFDD001AHappy Everyday|r\n|cFFCC0000每次使用爆裂魔法提升0.3%法术修正,爆裂魔法伤害与火属性伤害,触发冷却480秒\n炸到队友时,每名队友提升2%效果\n炸到敌军时,每名敌军提升0.1%效果|r\n|cFFDD001A红魔族|r\n|cFFCC0000杀敌时提升0.01%法术修正与3魔力值\n提升[0.75%*魔导变异数量]法术修正\n提升[1.5%*炎变异数量]火属性伤害\n提升25%火属性抗性\n提升[7.5%*法术修正]伤害加成\n所有伤害33%提升5%原始伤害|r\n|cFFDD001A暴走魔力 - 二阶|r\n|cFFCC0000提升15%火属性伤害\n降低15%全属性伤害\n魔力伤害只会造成火属性伤害|r\n|cFFBA0033进阶条件：火属性伤害达到111%(不计入红魔族效果提升)时点击进阶|r",
              icon = "war3mapImported\\BTNThing_Huihui_4.blp"
            })
          end
          return
        end
        if lv == 2 then
          if Damage_Element_Fire[sy] - u:getdata("惠惠-红魔族加成") >= 1.11 then
            u:sendmessage("|cFFCC0000进阶成功|r")
            u:changedata("惠惠-暴走魔法阶级", 1)
            u:changedata("炎变异数量", 1)
            ChangeValue(Damage_Element_Fire, sy, 0.05)
            ChangeValue(Damage_Element_All, sy, -0.05)
            u:addstexiao("惠惠-暴走魔法附伤", "近战伤害特效", function(args)
              local tg = args.tg
              local u = args.u
              if u:hasdata("惠惠-暴走魔法") and not args.isvestdamage and not u:hasdata("惠惠-暴走魔法" .. "-特效冷却") then
                u:settimedata("惠惠-暴走魔法" .. "-特效冷却", 0.1)
                local x, y = tg:getxy()
                local txsh = u:getint() * 25 + u:getdata("魔力值") * 10
                Effectcreate("Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl", x, y)
                for _, xq in ac.selector():in_rangexy(x, y, 250):ipairs() do
                  xq = getunit(xq)
                  if xq:is_enemy(u.handle) then
                    DamageUnit({
                      bj = "惠惠(暴走魔法)",
                      unit = xq.handle,
                      source = u.handle,
                      damage = txsh,
                      level = 1,
                      type = "魔力",
                      isvest = true,
                      isattack = false,
                      isnoarmor = false,
                      element = "火"
                    })
                  else
                    xq:losshp(u, txsh * 0.1)
                  end
                end
              end
            end)
            local dskill = S2ID("A1M5")
            u:byladdskill(dskill, function(args)
              if args.skill == dskill then
                local b = true
                local ewl = getunit(args.unit)
                if not u:isalive() then
                  b = false
                  u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
                end
                if b then
                  if u:getdata("惠惠-暴走魔法阶级") < 4 then
                    if not u:hasdata("惠惠-暴走魔法") then
                      u:setdata("惠惠-暴走魔法")
                      u:sendmessage("|cFF990000暴走魔法-[开启]|r")
                      u:setskilldatastring(dskill, "提示", "|cFF990000暴走魔法-[开启]|r")
                    else
                      u:deldata("惠惠-暴走魔法")
                      u:sendmessage("|cFF990000暴走魔法-[关闭]|r")
                      u:setskilldatastring(dskill, "提示", "|cFF990000暴走魔法-[关闭]|r")
                    end
                  else
                    u:sendmessage("|cFF990000无法关闭|r")
                  end
                else
                  ewl:setskillcd(dskill, 1)
                end
              end
            end)
            u:uivar_change({
              keyname = "惠惠",
              keytype = "传奇栏",
              text = "|cFFDD001A惠|r|cFFBA0033惠|r\n|cFFDD001A魔导 炎\n爆裂魔法|r\n|cFFCC0000使用爆裂魔法前每句吟唱咒语提升150%爆裂魔法基础伤害\n吟唱“Explosion”在前方500码处发动爆裂魔法造成[10000+智力*50]点火属性魔力伤害,发动后自己会瘫痪9秒\n冷却时间 一天（480秒)|r\n|cFFDD001AHappy Everyday|r\n|cFFCC0000每次使用爆裂魔法提升0.3%法术修正,爆裂魔法伤害与0.05%火属性伤害,触发冷却480秒\n炸到队友时,每名队友提升2%(0.33%)效果\n炸到敌军时,每名敌军提升0.1%(0.016%)效果|r\n|cFFDD001A红魔族|r\n|cFFCC0000杀敌时提升0.01%法术修正与3魔力值\n提升[1%*魔导变异数量]法术修正\n提升[2%*炎变异数量]火属性伤害\n提升25%火属性抗性\n提升[10%*法术修正]伤害加成\n所有伤害33%提升10%原始伤害|r\n|cFFDD001A暴走魔力 - 三阶|r\n|cFFCC0000炎\n提升20%火属性伤害\n降低20%全属性伤害\n魔力伤害只会造成火属性伤害\n解锁[暴走魔法]|r\n|cFFBA0033进阶条件：火属性伤害达到222%(不计入红魔族效果)|r",
              icon = "war3mapImported\\BTNThing_Huihui_3.blp"
            })
          end
          return
        end
        if lv == 3 and Damage_Element_Fire[sy] - u:getdata("惠惠-红魔族加成") >= 2.22 then
          u:chat("吾乃森罗万象之法则")
          u:chat("崩坏与破坏之代行者", 3)
          u:chat("现终焉之时机已至", 6)
          u:chat("潜伏于现世的反逆魔天", 9)
          u:chat("苏醒现身于我面前吧！", 12)
          PlayBGM({
            bgm = BGM_Huihui_10,
            time = 130,
            ID = 198,
            unit = u.handle
          })
          u:setplayername("|cFFCC0000[|r|cFF66FF99森|r|cFF99FFFF罗|r|cFFFF99FF万|r|cFFFFFF99象|r|cFFCC0000]|r" .. NameID[sy])
          u:adddxdstats("幻想", 2)
          u:changedata("根源变异数量", 1)
          u:changedata("影变异数量", 1)
          u:changedata("黑暗变异数量", 1)
          u:changedata("光明变异数量", 1)
          u:changedata("外域变异数量", 1)
          u:setdata("惠惠-暴走魔法")
          u:setskilldatastring(S2ID("A1M5"), "提示", "|cFF990000暴走魔法-[开启]|r")
          ChangeValue(Damage_ElementRes_Fire, sy, 53)
          ChangeValue(Damage_Type_Moli, sy, 0.15)
          ChangeValue(Damage_Element_Fire, sy, 0.2)
          ChangeValue(Damage_Element_All, sy, -0.2)
          do
            local tl = 0
            local hp = 0
            local bs = 0
            local ewys = 0
            local endsh = 0
            ac.loop(3000, function()
              ChangeValue(Hero_Tili_Huifu, sy, -1 * tl)
              ChangeValue(HeroMenu_HpChange_MaxHp, sy, -1 * hp)
              ChangeValue(DamageSystem_Baoshang, sy, -1 * bs)
              ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -1 * ewys)
              ChangeValue(DamageSystem_EndSh, sy, 0.1 * (-1 * endsh))
              tl = 0.02 * u:getstate("外域变异")
              hp = 0.1 * u:getstate("光明变异")
              bs = 0.03 * u:getdata("黑暗变异数量")
              ewys = 100 * u:getstate("影变异")
              endsh = 0.01 * u:getdata("根源变异数量")
              ChangeValue(Hero_Tili_Huifu, sy, 1 * tl)
              ChangeValue(HeroMenu_HpChange_MaxHp, sy, 1 * hp)
              ChangeValue(DamageSystem_Baoshang, sy, 1 * bs)
              ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 1 * ewys)
              ChangeValue(DamageSystem_EndSh, sy, 0.1 * (1 * endsh))
            end)
            u:changedata("惠惠-暴走魔法阶级", 1)
            u:uivar_change({
              keyname = "惠惠",
              keytype = "传奇栏",
              text = "|cFF990000惠|r|cFFCC0000惠.|r|cFF66FF99森|r|cFF99FFFF罗|r|cFFFF99FF万|r|cFFFFFF99象|r\n|cFF990000魔导 炎 根源 影 黑暗 光明 外域\n吾之究极破坏魔法|r\n|cFFCC0000需求消耗所有体力\n允许吟唱爆裂魔法;吟唱时僵直1800范围敌军1.5秒|r\n|cFFFFFF99崩坏红魔之名|r\n|cFFFFFFCC提升15%魔力伤害\n提升88%火属性抗性\n提升[2%*魔导变异数量]法术修正\n提升[2.5%*炎变异数量]火属性伤害|r\n|cFF6633FF现世の反逆魔天|r\n|cFF9999FF提升[0.02*外域变异数量]体力恢复\n提升[0.1%*光明变异数量]生命恢复\n提升[3%*黑暗变异数量]暴击伤害\n提升[100*影变异数量]额外移速\n提升[0.1%*根源变异数量]终结伤害|r\n|cFF990000漆黑之炎鸣\n炎|r\n|cFFCC0000提升40%火属性伤害\n降低40%全属性伤害\n魔力伤害只会造成火属性伤害\n[暴走魔法]强制开启|r\n|cFFFF99FF延伸天地の挽回之音|r\n|cFFFFCCFF44%提升15%原始伤害\n提升[20%*法术修正]伤害加成\n自身触发游戏失败再续效果时,提升100全属性与10%伤害加成,一次复活机会|r",
              icon = "NewIcon_Huihui",
              dx = 4.5,
              ishasphoto = true
            })
            return
          end
        end
      end
    end,
    weight = 0,
    key = {
      "唯一",
      "炎",
      "魔导"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I042") then
        add = add + 2500
      end
      return add
    end,
    condition = function(u)
      local b = false
      if u:ishasshw() and u:ishasitem("I042") and u:getdata("魔导变异数量") > 0 then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      PlayGlobalSound(Huihui_Start)
      u:chat("吾名乃惠惠", 4)
      u:chat("职业是大魔法师", 6)
      u:chat("吾乃最强攻击魔法", 7.5)
      u:chat("爆裂魔法的精通者！", 9.3)
      u:setplayername("|cFF7DBEF1[|r|cFFFF0000惠惠|r|cFF7DBEF1]|r" .. NameID[sy])
      u:reduceshw()
      u:setdata("惠惠-暴走魔法阶级", 1)
      u:setdata("爆裂魔法释放次数", 0)
      u:setdata("爆裂魔法基础伤害加成", 0)
      PlayBGM({
        bgm = BGM_Huihui_01,
        time = 102,
        ID = 119,
        unit = u.handle
      })
      ChangeValue(Damage_ElementRes_Fire, sy, 25)
      ChangeValue(Damage_Element_Fire, sy, 0.1)
      ChangeValue(Damage_Element_All, sy, -0.1)
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local u = args.u
        local jl = 33
        local lv = u:getdata("惠惠-暴走魔法阶级")
        local info = args.damageinfo
        if lv == 4 then
          jl = 44
        end
        if u:getluckrandom(jl) then
          local add = 0.05
          if lv == 3 then
            add = 0.1
          end
          if lv == 4 then
            add = 0.15
          end
          info.endup = info.endup + add
        end
      end)
      local mg = 0
      local hs = 0
      local gl = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Magic, sy, -1 * mg)
        ChangeValue(Damage_Element_Fire, sy, -1 * hs)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * gl))
        local xs = 0.05
        local hsxs = 0.01
        local lv = u:getdata("惠惠-暴走魔法阶级")
        if lv == 2 then
          xs = 0.075
          hsxs = 0.015
        end
        if lv == 3 then
          xs = 0.1
          hsxs = 0.02
        end
        if lv == 4 then
          xs = 0.2
          hsxs = 0.025
        end
        mg = xs * u:getstate("魔导变异")
        hs = hsxs * u:getstate("炎变异")
        gl = xs * (Correction_Magic[sy] - 1)
        u:setdata("惠惠-红魔族加成", hs)
        ChangeValue(Correction_Magic, sy, 1 * mg)
        ChangeValue(Damage_Element_Fire, sy, 1 * hs)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * gl))
      end)
      local strz = {
        {
          {
            str = "笼罩光明之漆黑",
            snd = Huihui1_1,
            time = 2.8
          },
          {
            str = "缠绕黑夜之爆炎",
            snd = Huihui1_2,
            time = 2.6
          },
          {
            str = "吾之究极破坏魔法",
            snd = Huihui1_3,
            time = 4.4
          }
        },
        {
          {
            str = "可悲的怪物",
            snd = Huihui2_1,
            time = 2.8
          },
          {
            str = "跟赤色烟雾融为一体",
            snd = Huihui2_2,
            time = 1.5
          },
          {
            str = "在窒息中惨叫以赎罪吧",
            snd = Huihui2_3,
            time = 1.9
          },
          {
            str = "贯穿吧",
            snd = Huihui2_4,
            time = 0.5
          }
        },
        {
          {
            str = "遮掩光明之漆黑",
            snd = Huihui3_1,
            time = 2.2
          },
          {
            str = "纠结黑夜之爆炎",
            snd = Huihui3_2,
            time = 1.7
          },
          {
            str = "于红魔之名下显现崩坏现象",
            snd = Huihui3_3,
            time = 3.3
          },
          {
            str = "于终焉王国之地",
            snd = Huihui3_4,
            time = 1.5
          },
          {
            str = "隐匿力量根源之物",
            snd = Huihui3_5,
            time = 2.5
          },
          {
            str = "于吾面前显现吧",
            snd = Huihui3_6,
            time = 0.9
          }
        },
        {
          {
            str = "红之黑炎",
            snd = Huihui4_1,
            time = 1
          },
          {
            str = "挽回之音",
            snd = Huihui4_2,
            time = 1
          },
          {
            str = "天地之延伸",
            snd = Huihui4_3,
            time = 1.4
          },
          {
            str = "吾乃森罗万象之法则",
            snd = Huihui4_4,
            time = 2.7
          },
          {
            str = "崩坏与破坏之别名",
            snd = Huihui4_5,
            time = 1.9
          },
          {
            str = "荣光之铁槌降于吾之下",
            snd = Huihui4_6,
            time = 3.2
          }
        },
        {
          {
            str = "潜伏于现世的反逆魔天",
            snd = Huihui5_1,
            time = 3.2
          },
          {
            str = "现身于我面前的寂静信赖",
            snd = Huihui5_2,
            time = 2.7
          },
          {
            str = "时机已到",
            snd = Huihui5_3,
            time = 0.8
          },
          {
            str = "现在苏醒",
            snd = Huihui5_4,
            time = 1.8
          },
          {
            str = "以我的狂傲进行戒备",
            snd = Huihui5_5,
            time = 1.9
          },
          {
            str = "贯穿吧",
            snd = Huihui5_6,
            time = 0.8
          }
        },
        {
          {
            str = "远甚于黑甚于黑暗之漆黑",
            snd = Huihui6_1,
            time = 3.3
          },
          {
            str = "渴求与吾之真红之融合吧",
            snd = Huihui6_2,
            time = 2.2
          },
          {
            str = "觉醒之时已降临",
            snd = Huihui6_3,
            time = 1.4
          },
          {
            str = "真理坠入无谬之境界",
            snd = Huihui6_4,
            time = 2
          },
          {
            str = "化为无谬之畸形显现吧",
            snd = Huihui6_5,
            time = 2.2
          },
          {
            str = "起舞吧起舞吧起舞吧",
            snd = Huihui6_6,
            time = 2.5
          },
          {
            str = "吾之力量渴求崩坏",
            snd = Huihui6_7,
            time = 2.7
          },
          {
            str = "无可比拟的崩坏之力",
            snd = Huihui6_8,
            time = 1.7
          },
          {
            str = "万象具化尘自深渊而来",
            snd = Huihui6_9,
            time = 3.7
          },
          {
            str = "这就是人类最强威力的攻击手段",
            snd = Huihui6_10,
            time = 3
          },
          {
            str = "这就是究极的攻击魔法",
            snd = Huihui6_11,
            time = 2.8
          }
        }
      }
      local exp = {
        {
          snd = Huihui1_Exp,
          time = 7
        },
        {
          snd = Huihui2_Exp,
          time = 4
        },
        {
          snd = Huihui3_Exp,
          time = 5
        },
        {
          snd = Huihui4_Exp,
          time = 4
        },
        {
          snd = Huihui5_Exp,
          time = 3
        },
        {
          snd = Huihui6_Exp,
          time = 9
        }
      }
      u:setdata("吟唱咒语", 0)
      u:setdata("吟唱句数", 0)
      u:setdata("有效吟唱句数", 0)
      
      local function skill(args)
        local str = string.lower(args.chat)
        if not u:hasdata("惠惠-吟唱中") and not u:hasdata("爆裂魔法冷却") and u:isalive() then
          if str == "explosion" then
            local x, y = u:getxy()
            local jd = u:getface()
            local lv = u:getdata("惠惠-暴走魔法阶级")
            local b = true
            if u:getpermp() <= 10 then
              b = false
            end
            if lv == 4 and Hero_Tili[sy] <= 0.99 * Hero_Tili_Max[sy] then
              b = false
            end
            if b then
              u:curemp(-0.1 * u:getmaxmp())
              local x2, y2 = PolarXY(x, y, 500, jd)
              local zy = u:getdata("吟唱咒语")
              local js = u:getdata("有效吟唱句数")
              u:effectadd("war3mapImported\\Texiao_Baozha5.mdx", "chest")
              if zy == 0 then
                zy = GetRandomInt(1, 5)
              end
              PlayGlobalSound(exp[zy].snd)
              local t = exp[zy].time
              ac.timer(100, t / 0.1, function()
                Effectcreate("Abilities\\Spells\\Other\\Charm\\CharmTarget.mdl", x, y, 0, 2)
              end)
              u:buffset(u.handle, t + 2 + 9, "暂停")
              u:buffset(u.handle, t + 2, "无敌")
              u:settimedata("惠惠-吟唱中", t + 2 + 9)
              local mzcount = 0
              local mzhero = 0
              ac.wait(t * 1000, function()
                u:losshp(u, 0, GetRandomReal(0, 90))
                PlayGlobalSound(boom1)
                Effectcreate("war3mapImported\\blast2.MDX", x2, y2)
                Effectcreate("war3mapImported\\skybigbang.mdx", x2, y2)
                local g = CreateGroupLua()
                local txsh = 10000
                local damagelv = 1
                if lv == 1 then
                  txsh = txsh + u:getint() * 10
                end
                if lv == 2 then
                  txsh = txsh + u:getint() * 25
                end
                if lv == 3 then
                  txsh = txsh + u:getint() * 50
                end
                if lv == 4 then
                  txsh = txsh + u:getint() * 100
                  damagelv = 5
                end
                txsh = txsh * (1 + u:getdata("爆裂魔法基础伤害加成"))
                if 0 < js then
                  txsh = txsh * (1.5 * js)
                end
                local hpsh = 1 * js
                for _, xq in ac.selector():in_rangexy(x, y, 350):isnotingroup(g):is_not(u.handle):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(g)
                  ac.wait(1, function()
                    xq:animeact("death")
                  end)
                  if xq:is_enemy(u.handle) then
                    LossHpUnit({
                      u = u,
                      tg = xq,
                      damage = 0,
                      perhp = 0,
                      maxhp = js,
                      bj = "[生命损耗]惠惠爆裂魔法"
                    })
                    DamageUnit({
                      bj = "惠惠(爆裂魔法)",
                      unit = xq.handle,
                      source = u.handle,
                      damage = txsh,
                      level = damagelv,
                      type = "魔力",
                      isvest = true,
                      isattack = false,
                      isnoarmor = false,
                      element = "火"
                    })
                    xq:buffset(u.handle, 10, "眩晕")
                    mzcount = mzcount + 1
                  else
                    local dtxsh = GetRandomReal(0, 125)
                    if dtxsh < 100 then
                      xq:losshp(u, 0, 0, dtxsh)
                    else
                      xq:kill(u.handle)
                    end
                    xq:buffset(u.handle, 10, "眩晕")
                    mzhero = mzhero + 1
                  end
                end
                local cs = 0
                ac.timer(100, 5, function()
                  cs = cs + 1
                  for _, xq in ac.selector():in_rangexy(x2, y2, 350 + 400 * cs):isnotingroup(g):is_not(u.handle):ipairs() do
                    xq = getunit(xq)
                    xq:groupadd(g)
                    ac.wait(1, function()
                      xq:animeact("death")
                    end)
                    if xq:is_enemy(u.handle) then
                      LossHpUnit({
                        u = u,
                        tg = xq,
                        damage = 0,
                        perhp = 0,
                        maxhp = js,
                        bj = "[生命损耗]惠惠爆裂魔法"
                      })
                      DamageUnit({
                        bj = "惠惠(爆裂魔法)",
                        unit = xq.handle,
                        source = u.handle,
                        damage = txsh,
                        level = damagelv,
                        type = "魔力",
                        isvest = true,
                        isattack = false,
                        isnoarmor = false,
                        element = "火",
                        extradata = {
                          "系统-本次伤害无视伤害闪避"
                        }
                      })
                      xq:buffset(u.handle, 10, "眩晕")
                      mzcount = mzcount + 1
                    else
                      local dtxsh = GetRandomReal(0, 125)
                      if dtxsh < 100 then
                        xq:losshp(u, 0, 0, dtxsh)
                      else
                        xq:kill(u.handle)
                      end
                      xq:buffset(u.handle, 10, "眩晕")
                      mzhero = mzhero + 1
                    end
                  end
                end)
                ac.wait(100, function()
                  for i = 1, 6 do
                    local x1, y1 = PolarXY(x2, y2, 500, i * 60)
                    Effectcreate("war3mapImported\\blast2.MDX", x1, y1)
                    Effectcreate("war3mapImported\\Texiao_Baozha.mdx", x1, y1)
                    Effectcreate("war3mapImported\\Texiao_Baozha4.mdx", x1, y1)
                    Effectcreate("Objects\\Spawnmodels\\Human\\SmallFlameSpawn\\SmallFlameSpawn.mdl", x1, y1)
                  end
                end)
                ac.wait(200, function()
                  for i = 1, 12 do
                    local x1, y1 = PolarXY(x2, y2, 900, i * 30)
                    Effectcreate("war3mapImported\\blast2.MDX", x1, y1)
                    Effectcreate("war3mapImported\\Texiao_Baozha4.mdx", x1, y1)
                    Effectcreate("Objects\\Spawnmodels\\Human\\SmallFlameSpawn\\SmallFlameSpawn.mdl", x1, y1)
                  end
                end)
                ac.wait(300, function()
                  for i = 1, 18 do
                    local x1, y1 = PolarXY(x2, y2, 1500, i * 20)
                    Effectcreate("war3mapImported\\blast2.MDX", x1, y1)
                    Effectcreate("war3mapImported\\Texiao_Baozha.mdx", x1, y1)
                    Effectcreate("Objects\\Spawnmodels\\Human\\SmallFlameSpawn\\SmallFlameSpawn.mdl", x1, y1)
                  end
                end)
                ac.wait(400, function()
                  for i = 1, 24 do
                    local x1, y1 = PolarXY(x2, y2, 2000, i * 15)
                    Effectcreate("war3mapImported\\Texiao_Baozha.mdx", x1, y1)
                    Effectcreate("war3mapImported\\Texiao_Baozha4.mdx", x1, y1)
                    Effectcreate("Objects\\Spawnmodels\\Human\\SmallFlameSpawn\\SmallFlameSpawn.mdl", x1, y1)
                  end
                end)
                ac.wait(500, function()
                  for i = 1, 36 do
                    local x1, y1 = PolarXY(x2, y2, 2000, i * 10)
                    Effectcreate("war3mapImported\\blast2.MDX", x1, y1)
                    Effectcreate("Objects\\Spawnmodels\\Human\\SmallFlameSpawn\\SmallFlameSpawn.mdl", x1, y1)
                  end
                end)
                ac.wait(600, function()
                end)
              end)
              ac.wait((t + 2) * 1000, function()
                u:setdata("吟唱咒语", 0)
                u:setdata("吟唱句数", 0)
                u:setdata("有效吟唱句数", 0)
                ChangeTimeValue(Hero_Tili_Max, sy, -1 * Hero_Tili_Max[sy] / 2, 240)
                if lv == 4 then
                  Hero_Tili[sy] = 0
                else
                  u:settimedata("爆裂魔法冷却", 480)
                  ac.wait(480000, function()
                    u:sendmessage("|cFF7DBEF1爆裂魔法冷却完毕|r")
                  end)
                end
                if u:getdata("爆裂魔法释放次数") == 0 then
                  PlayGlobalSound(Huihui_Lijie)
                  u:chat("吾之奥义爆裂魔法")
                  u:chat("由于威力极其强大", 2.5)
                  u:chat("魔力消耗也极大", 4.4)
                  u:chat("导致现在无法动弹", 6.2)
                else
                  PlayGlobalSound(meguming_3)
                end
                u:changedata("爆裂魔法释放次数", 1)
                u:animeact("death")
                if u:getdata("惠惠-暴走魔法阶级") <= 3 then
                  local xg = 0.03 + 0.02 * mzhero + 0.001 * mzcount
                  u:changedata("爆裂魔法基础伤害加成", xg)
                  ChangeValue(Damage_Element_Fire, sy, xg / 6)
                  ChangeValue(Correction_Magic, sy, xg)
                end
              end)
            else
              u:setdata("吟唱咒语", 0)
              u:setdata("吟唱句数", 0)
              u:setdata("有效吟唱句数", 0)
              PlayGlobalSound(Sound_Huihui_Fail)
              u:buffset(u.handle, 7.8, "暂停")
              u:buffset(u.handle, 8, "无敌")
              u:settimedata("惠惠-吟唱中", 7.8)
              if lv == 4 then
              else
                u:settimedata("爆裂魔法冷却", 200)
                ac.wait(200000, function()
                  u:sendmessage("|cFF7DBEF1爆裂魔法冷却完毕|r")
                end)
              end
            end
          end
          local count = u:getdata("吟唱咒语")
          local count2 = u:getdata("吟唱句数")
          if count == 0 then
            for i1, str1 in ipairs(strz) do
              if str1[1].str == str then
                u:setdata("吟唱咒语", i1)
                u:changedata("吟唱句数", 1)
                local xh = 1 + 0.08 * u:getmaxmp()
                if xh <= u:getmp() then
                  u:curemp(-1 * xh)
                  u:changedata("有效吟唱句数", 1)
                end
                u:setdata("吟唱允许时间", 20)
                u:settimedata("惠惠-吟唱中", str1[1].time)
                PlayGlobalSound(str1[1].snd)
                ac.loop(1000, function(timer)
                  u:changedata("吟唱允许时间", -1)
                  if u:getdata("吟唱允许时间") == 0 then
                    if u:getdata("吟唱咒语") ~= 0 then
                      u:sendmessage("吟唱取消")
                    end
                    u:setdata("吟唱咒语", 0)
                    u:setdata("吟唱句数", 0)
                    u:setdata("有效吟唱句数", 0)
                    timer:remove()
                  end
                end)
              end
            end
          elseif strz[count][count2 + 1] and strz[count][count2 + 1].str == str then
            u:changedata("吟唱句数", 1)
            u:setdata("吟唱允许时间", 20)
            local xh = 1 + 0.08 * u:getmaxmp()
            if xh <= u:getmp() then
              u:curemp(-1 * xh)
              u:changedata("有效吟唱句数", 1)
            end
            u:settimedata("惠惠-吟唱中", strz[count][count2 + 1].time)
            PlayGlobalSound(strz[count][count2 + 1].snd)
          end
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        skill(args)
      end)
    end,
    effectname = "|cFFDD001A惠|r|cFFBA0033惠|r",
    effecttext = "|cFFDD001A魔导 炎\n爆裂魔法|r\n|cFFCC0000使用爆裂魔法前每句吟唱咒语提升150%爆裂魔法基础伤害\n吟唱“Explosion”在前方500码处发动爆裂魔法造成[10000+智力*10]点火属性魔力伤害,发动后自己会瘫痪9秒\n冷却时间 一天（480秒)|r\n|cFFDD001AHappy Everyday|r\n|cFFCC0000每次使用爆裂魔法提升0.3%法术修正,爆裂魔法伤害与0.05%火属性伤害,触发冷却480秒\n炸到队友时,每名队友提升2%(0.33%)效果\n炸到敌军时,每名敌军提升0.1%(0.016%)效果|r\n|cFFDD001A红魔族|r\n|cFFCC0000杀敌时提升0.01%法术修正与3魔力值\n提升[0.5%*魔导变异数量]法术修正\n提升[1%*炎变异]火属性伤害\n提升25%火属性抗性\n提升[5%*法术修正]伤害加成\n所有伤害33%提升5%原始伤害|r\n|cFFDD001A暴走魔力 - 一阶|r\n|cFFCC0000提升10%火属性伤害\n降低10%全属性伤害|r\n|cFFBA0033进阶条件：火属性伤害达到55%(不计入红魔族效果提升)时点击进阶|r",
    effectart = "war3mapImported\\BTNEwl_Baoliemofa.blp"
  },
  {
    name = "Roman",
    weight = 0,
    key = {"唯一"},
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I01N") then
        add = add + 2500
      end
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:ishasshw() and u:ishasitem("I01N") and not Weiyi_Dz[12] then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:setplayername("|cFF7DBEF1[|rRoman|cFF7DBEF1]|r" .. NameID[sy])
      u:reduceshw()
      SendMsgAll("|cFFFFFF00这个世界虽然有各种各样的痛苦 但是人类诞生降世的意义 就是为了采集这个世界中美丽之物啊|r")
      Weiyi_Dz[12] = true
      u:setdata("美丽之物", 1)
      ac.loop(240000, function()
        u:changedata("美丽之物", 1)
        u:sendmessage("|cFFFFCC66美丽之物点数：" .. math.floor(u:getdata("美丽之物")))
        ChangeValue(DamageSystem_Ssjianshao, sy, 0.99, 1)
        u:addallstats(1)
        u:changedata("固定格挡", 2)
        if not u:hasdata("美丽之物-神化位") and u:getdata("美丽之物") >= 25 then
          u:setdata("美丽之物-神化位")
          SendMsgAll("|cFFFFFF00「我看见了——这世上最美丽的光，我会把那花朵抱在胸前，带着Laurant的份继续歌唱。」|r")
          ChangeValue(Hero_Shenhua_Left, sy, 1)
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          local x, y = tg:getxy()
          u:settimedata(var.name .. "-特效冷却", 3)
          Effectcreate("Objects\\Spawnmodels\\NightElf\\NEDeathMedium\\NEDeath.mdl", x, y)
          local txsh = 8000 * u:getdata("美丽之物")
          for _, xq in ac.selector():in_rangexy(x, y, 375):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "美丽之物(附伤)",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "风"
            })
            xq:removecharacteristics(3)
          end
        end
      end)
      Qiyue_Meilizhiwu_Zishen = u.handle
      
      local function skill(args)
        local chat = string.sub(args.chat, 1, 3)
        if chat == "-rm" then
          if string.len(args.chat) >= 4 then
            local sy2 = tonumber(string.sub(args.chat, 4, 4))
            if Hero[sy2] ~= 0 and Hero[sy2] ~= u.handle and getunit(Hero[sy2]):isalive() and not u:hasdata("美丽之物-契约加成") then
              local tg = getunit(Hero[sy2])
              tg:sendmessage("|cFFF7C295你成为了契约者|r")
              u:sendmessage("|cFFF7C295契约成功|r")
              tg:setdata("美丽之物-契约加成")
              u:setdata("美丽之物-契约加成")
              Qiyue_Meilizhiwu_Duixiang = tg.handle
              ChangeValue(DamageSystem_Ssjianshao, sy2, 0.88, 1)
              ChangeValue(DamageSystem_Baoji, sy2, 6)
              ChangeValue(DamageSystem_Baoshang, sy2, 0.13)
            else
              u:sendmessage("目标不合法")
            end
          else
            u:sendmessage("指令错误")
          end
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        skill(args)
      end)
    end,
    effectname = "|cFFFFFF00Roman|r",
    effecttext = "|cFFFFCC66春之风花|r\n|cFFFFFF00从特殊补给箱中获取独特物品时获得1点[美丽之物]并有10%提升1点幸运|r\n|cFFFFCC66夏之流云|r\n|cFFFFFF00每点[美丽之物]提升1%减伤与2点固定减伤|r\n|cFFFFCC66秋之夜月|r\n|cFFFFFF00每隔480秒提升自身2点[美丽之物]\n提升[美丽之物*1]点全属性|r\n|cFFFFCC66冬之初雪|r\n|cFFFFFF00累积[美丽之物]达到25点时获得神化位|r\n|cFFFFCC66生与死的\"Roman\"|r\n|cFFFFFF00直接伤害时10%对目标与其375范围单位附带[8000*美丽之物]风属性伤害并移除精英特性3秒,触发冷却3秒\n通过契约复活时降低7%最大生命值与1.5%伤害(乘算)\n输入-rm1~6 契约目标 自身死亡时复活在契约目标身边并伤害限制9秒\n目标死亡时自身死亡并解除契约关系|r\n|cFF949596四季流逝，每一个季节都仿佛美丽无比的风景画。|r",
    effectart = "war3mapImported\\BTNEwl_Roman.blp"
  },
  {
    name = "纳兹",
    weight = 0,
    key = {
      "唯一",
      "龙",
      "炎",
      "战士"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I09A") then
        add = add + 2500
      end
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:ishasshw() and u:ishasitem("I09A") and u:getdata("龙变异数量") > 0 and not Weiyi[23] then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:setplayername("|cFF7DBEF1[|r|cFFFF0000纳|r|cFFFF4400兹|r|cFF7DBEF1]|r" .. NameID[sy])
      u:reduceshw()
      u:chat("放马过来吧！")
      PlayGlobalSound(Sound_Nazi_01)
      Weiyi[23] = true
      u:addstr(100)
      u:changedata("力量增幅", 0.075)
      local ys = 0
      local lw = 0
      local ss = 1
      local zj = 0
      local gs = 0
      local b = false
      ac.loop(1000, function()
        if u:isalive() then
          u:changedata("力量增幅", -1 * ys)
          u:changedata("固定伤害", 0.1 * (-1 * gs))
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * lw))
          ChangeValue(DamageSystem_Ssjianshao, sy, ss, 2)
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * zj))
          gs = u:getstr() * 5 * u:getdata("龙变异数量")
          zj = (100 - u:getperhp()) / 100
          ss = 1 - (100 - u:getperhp()) / 333
          ys = 0.025 * u:getdata("龙变异数量")
          if 2 <= u:getdata("龙变异数量") and b == false then
            b = true
            AddUISkill({
              text = "火龙之炎",
              u = u,
              cd = 90,
              icon = "war3mapImported\\btnskill_huolongdepaoxiao.blp",
              func = function(args)
                local u = args.u
                if u:isalive() then
                end
              end
            })
          end
          local lv = 2
          if u:getdata("龙变异数量") >= 3 then
            u:setdata("系统-无视伤害免疫")
          end
          if u:getdata("龙变异数量") >= 4 then
            lv = 4
          end
          u:curehp(u.handle, 0, 0.5, lv)
          if 5 <= u:getdata("龙变异数量") then
            lw = 0.08 * u:getdata("龙变异数量")
          else
            lw = 0
          end
          if u:hasdata("纳兹-不屈锁血冷却") and u:getperhp() >= 99 then
            u:deldata("纳兹-不屈锁血冷却")
            u:sendmessage("|cFFFF0000不屈锁血冷却完毕|r")
          end
          u:changedata("力量增幅", 1 * ys)
          u:changedata("固定伤害", 0.1 * (1 * gs))
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * lw))
          ChangeValue(DamageSystem_Ssjianshao, sy, ss, 1)
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * zj))
        end
      end)
    end,
    effectname = "|cFFFF0000纳|r|cFFFF3300兹|r",
    effecttext = "|cFFFF0000龙 炎 战士\n体质强化|r\n|cFFFF9900提升15点力量\n提升[2.5%*龙变异数量]力量增幅\n每秒恢复1%最大生命值|r\n|cFFFF0000不屈|r\n|cFFFF9900提升[生命缺失百分比*30%]受伤减少\n提升[缺失生命百分比]伤害加成\n生命值百分比≤50%时受到伤害时有[50-自身生命百分比]%免疫\n受到的单次伤害超过最大生命值50%时格挡并恢复自身[5%*龙变异数量]最大生命值同时30秒内提升2.5%伤害加成 冷却30秒\n在10%生命值时锁血，在自身生命值恢复到99%时可以再次触发|r\n|cFFFF0000灭龙魔法|r\n|cFFFF9900提升[力量*5*龙变异数量]固定伤害，根据龙变异数量解锁：\n1：无视精英特性铁壁与力场\n2：获得技能[火龙之炎]\n3：无视伤害免疫\n4：该变异相关恢复均变为永恒恢复\n5：提升[龙变异数量*0.8%]伤害加成|r\n|cFF949596明天会怎样，就算不知道也无所谓。我只是竭尽全力活在今天",
    effectart = "war3mapImported\\BTNEwl_Meilongmofa.blp"
  },
  {
    name = "楚子航",
    weight = 0,
    key = {
      "唯一",
      "炎",
      "影",
      "战士",
      "龙"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      if u:ishasitem("I0EY") then
        add = add + 2500
      end
      if u:hasdata("神器判定-雨夜的迈巴赫") then
        add = add + 2500
      end
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:ishasshw() and u:ishasitem("I0EY") and (Race_Dragon_Cd[sy] >= 0.2 or u:getdata("血统浓度") == 0 or u:hasdata("神器判定-雨夜的迈巴赫")) then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:setplayername("|cFF7DBEF1[|r|cFF667399右京·橘|r|cFF7DBEF1]|r" .. NameID[sy])
      u:chat("又下雨了吗……")
      if Hero_Shenhua_Now[sy] == 0 then
        u:setdata("楚子航-首发神化")
        u:setdata("楚子航-暴血冷却", 5)
      else
        u:setdata("楚子航-暴血冷却", 30)
      end
      if u:hasdata("神器判定-雨夜的迈巴赫") then
        u:setdata("楚子航-暴血冷却", 0.1)
      end
      u:reduceshw()
      ChangeValue(WeaponCount_Katana, sy, 0.33)
      Weiyi[18] = true
      
      local function sishihua(gl)
        if GetRandom100(gl) and u:hasdata("死侍化可能") and not u:hasdata("楚子航-死侍化") and not u:hasdata("隐藏职业-龙太子") then
          local x, y = u:getxy()
          HeroRelive(u.handle, x, y, 3)
          u:setdata("楚子航-死侍化")
          u:deldata("死侍化可能")
          SendMsgAll("|cFFCC9999“超越极限会怎样？”|r")
          YisiStory["楚子航死侍化"](u)
          ac.wait(3000, function()
            SendMsgAll("|cFFCC9999“龙类血统将永远压过人类血统，他会永远地异化为……龙类！”|r")
          end)
          u:shanmo()
          local mj = CreateMonster("u07K", x, y)
          local boss = getunit(mj)
          boss:setdata("玩家名字", NameID[sy])
          bossstateset(boss)
          boss_sishi(mj)
          ac.wait(7000, function()
            SendMsgAll("|cFF999999「|r|cFF949699孤|r|cFF8F9499独|r|cFF8A9199地|r|cFF858F99死|r|cFF808C99去|r|cFF7A8A99，|r|cFF758799你|r|cFF708599难|r|cFF6B8299道|r|cFF667F99一|r|cFF617D99点|r|cFF5C7A99也|r|cFF577899不|r|cFF527599难|r|cFF4D7399过|r|cFF477099么|r|cFF426E99？|r|cFF3D6B99」|r")
          end)
          local bjl = u:getdata("显示-暴击率")
          local bjsh = u:getdata("显示-暴击伤害")
          local all = u:getdata("显示-伤害加成")
          if all <= 10 then
            all = 10
          end
          boss:setdata("无尽极意暴击率", bjl)
          boss:setdata("无尽极意暴击伤害", bjsh)
          boss:setdata("无尽极意伤害倍数", all)
          SetUnitState(boss.handle, ConvertUnitState(18), all)
          ForGroupLuaNew(Group_PlayHero, function(xq)
            xq:buffset(xq.handle, 10, "绝对闪避")
          end)
          if u:hasdata("隐藏职业-天谴之子") or u:hasdata("隐藏职业-歼灭天使") then
            SetPlayerAllianceStateBJ(boss.owner, u.owner, bj_ALLIANCE_ALLIED_UNITS)
            ac.loop(3000, function(timer)
              SetPlayerAllianceStateBJ(boss.owner, u.owner, bj_ALLIANCE_ALLIED_UNITS)
              if not boss:isalive() then
                SetPlayerAllianceStateBJ(boss.owner, u.owner, bj_ALLIANCE_UNALLIED)
                timer:remove()
              end
            end)
          end
        end
      end
      
      u:addstexiao(var.name, "被施加Buff时效果-眩晕", function(args)
        local u = args.u
        if u:getdata("狮心会暴血重数") > 3 and not Keyan_Guomintizhi then
          args.time = 0
        end
      end)
      u:addstexiao(var.name, "被施加Buff时效果-僵直", function(args)
        local u = args.u
        if u:getdata("狮心会暴血重数") > 3 and not Keyan_Guomintizhi then
          args.time = 0
        end
      end)
      u:addstexiao(var.name, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:getdata("狮心会暴血重数") > 0 then
          info.wsmy = true
        end
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") then
          local jl = 10
          local fw = 275
          local lv = u:getdata("狮心会暴血重数")
          if 1 <= lv then
            jl = 20
            fw = 343.75
          end
          if u:getluckrandom(jl * info.txgl) then
            u:settimedata(var.name .. "-特效冷却", 1)
            local damlv = 1
            local txsh
            if 4 <= lv then
              damlv = 5
              txsh = (15 + 5 * u:getdata("龙变异数量")) * u:getallattri() * u:getdragonbloodpower()
            elseif 2 <= lv then
              txsh = 25 * u:getallattri() * u:getdragonbloodpower()
            else
              txsh = 15 * u:getallattri() * u:getdragonbloodpower()
            end
            local x, y = tg:getxy()
            Effectcreate("war3mapImported\\[TX] (1422).mdl", x, y)
            for _, xq in ac.selector():in_rangexy(x, y, fw):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              DamageUnit({
                bj = "楚子航(君焰)",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = damlv,
                type = "魔力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "火",
                extradata = {"龙属性"}
              })
            end
          end
        end
      end)
      u:setdata("死侍意原始伤害惩罚", 1)
      u:setdata("死侍意损失生命上限", 0)
      u:setdata("死侍意", 0)
      u:setdata("楚子航-龙血纯度", 0)
      u:addskill("S05N")
      ChangeValue(DamageSystem_EndSh, sy, 0.003)
      ChangeValue(Correction_Cbxs, sy, 0.1)
      u:setdata("狮心会暴血重数", 0)
      u:setdata("狮心会暴血持续时间", 0)
      local cs = 0
      local cs2 = 0
      local bfb = 1
      local bfb2 = 0
      local sj = 0
      local zj = 0
      local lw = 0
      local gl = 0
      local bfb3 = 1
      local yscf = 1
      ac.loop(130, function(timer)
        local lv = u:getdata("狮心会暴血重数")
        cs = cs + 1
        if cs == 20 then
          local lxxg = u:getdragonbloodpower()
          cs = 0
          ChangeValue(Correction_MHpDe, sy, bfb, 2)
          if lv == 0 then
            bfb = 1
            for i = 1, math.floor(u:getdata("死侍意")) do
              bfb = bfb * 0.9925
            end
            bfb3 = 0.01 * u:getdata("死侍意")
          else
            bfb = 1
            bfb2 = 0
            bfb3 = 0
          end
          ChangeValue(Correction_MHpDe, sy, bfb, 1)
          u:flashmaxhp()
          u:setdata("死侍意原始伤害惩罚", bfb)
          u:setdata("死侍意额外受伤惩罚", bfb3)
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * sj))
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * zj))
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * lw))
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * gl))
          if 0 < lv then
            sj = 0.25 * lxxg
            if 3 <= lv then
              zj = 0.5 * lxxg
            elseif 2 <= lv then
              zj = 0.25 * lxxg
            else
              zj = 0
            end
            if 4 <= lv then
              lw = 0.25 * lxxg
              gl = 0.1 * lxxg
            else
              lw = 0
              gl = 0
            end
          else
            sj = 0
            zj = 0
            lw = 0
            gl = 0
          end
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * sj))
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * zj))
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * lw))
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * gl))
        end
        if u:getdata("楚子航-龙血纯度") >= 100 then
          u:setdata("楚子航-龙血纯度", 100)
        end
        if u:isalive() then
          local x, y = u:getxy()
          for _, xq in ac.selector():in_rangexy(x, y, 500):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            if xq:ishasbuff("B00Q") or xq:ishasbuff("B0CV") then
              xq:clearbuff("B00Q")
              xq:clearbuff("B0CV")
            end
          end
          if 3 <= lv then
            cs2 = cs2 + 1
            if cs2 == 7 then
              cs2 = 0
              local txsh
              local damlv = 1
              if 4 <= lv then
                damlv = 5
                txsh = (15 + 5 * u:getdata("龙变异数量")) * u:getallattri() * u:getdragonbloodpower()
              else
                txsh = 25 * u:getallattri() * u:getdragonbloodpower()
              end
              for _, xq in ac.selector():in_rangexy(x, y, 450):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:effectadd("Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl")
                DamageUnit({
                  bj = "楚子航(君焰)",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = damlv,
                  type = "魔力",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = "火",
                  extradata = {"龙属性"}
                })
              end
            end
          end
        else
          u:setdata("狮心会暴血持续时间", 0)
        end
        if 0 < u:getdata("狮心会暴血冷却时间") then
          u:changedata("狮心会暴血冷却时间", -0.13)
        else
          u:setdata("狮心会暴血冷却时间", 0)
          if u:hasdata("狮心会暴血-冷却中") then
            u:deldata("狮心会暴血-冷却中")
            u:sendmessage("|cFFCC0000暴血冷却完毕|r")
          end
        end
        ChangeValue(DamageSystem_Ysshjd, sy, yscf, 2)
        if 0 < u:getdata("狮心会暴血持续时间") then
          yscf = 1
          u:changedata("狮心会暴血持续时间", -0.13)
          sishihua(0.012 * Race_Dragon_Cd[sy])
        else
          u:setdata("狮心会暴血持续时间", 0)
          yscf = u:getdata("死侍意原始伤害惩罚")
        end
        ChangeValue(DamageSystem_Ysshjd, sy, yscf, 1)
        if u:hasdata("楚子航-死侍化") then
          timer:remove()
        end
      end)
      
      local function skill(args)
        if args.chat == "暴血" and u:isalive() and not u:hasdata("楚子航-死侍化") and u:getdata("狮心会暴血重数") < 4 and not u:hasdata("狮心会暴血-冷却中") then
          local lv = u:getdata("狮心会暴血重数")
          if lv == 1 and Race_Dragon_Cd[sy] < 0.2 then
            u:sendmessage("|cFFFFCC00龙血纯度不足|r")
            return
          end
          if lv == 2 and Race_Dragon_Cd[sy] < 0.4 then
            u:sendmessage("|cFFFFCC00龙血纯度不足|r")
            return
          end
          if lv == 3 and Race_Dragon_Cd[sy] < 0.6 then
            u:sendmessage("|cFFFFCC00龙血纯度不足|r")
            return
          end
          u:changedata("狮心会暴血重数", 1)
          lv = u:getdata("狮心会暴血重数")
          u:setdata("狮心会暴血持续时间", 40)
          if lv == 1 then
            local tx = u:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile.mdl", "hand left", -1)
            u:effectadd("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl")
            PlayGlobalSound(Czh_Baoxue)
            ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
            u:changedata("力量增幅", 0.125)
            u:changedata("楚子航-龙血纯度", 1)
            ac.loop(1000, function(timer)
              if u:getdata("狮心会暴血持续时间") == 0 then
                DestroyEffectLua(tx)
                u:setdata("狮心会暴血冷却时间", u:getdata("楚子航-暴血冷却"))
                u:setdata("狮心会暴血-冷却中")
                u:changedata("狮心会暴血重数", -1)
                ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -25)
                u:changedata("力量增幅", -0.125)
                u:changedata("死侍意", 1)
                sishihua(0.12 * Race_Dragon_Cd[sy])
                timer:remove()
              end
            end)
          end
          if lv == 2 then
            u:effectadd("war3mapImported\\effect_red-texiao-shandian.mdl")
            local tx = u:effectadd("war3mapImported\\[TX] (832).mdl", "origin", -1)
            u:changedata("力量增幅", 0.125)
            u:changedata("敏捷增幅", 0.125)
            u:changedata("楚子航-龙血纯度", 2)
            ac.loop(1000, function(timer)
              if u:getdata("狮心会暴血持续时间") == 0 then
                DestroyEffectLua(tx)
                u:setdata("狮心会暴血冷却时间", u:getdata("楚子航-暴血冷却"))
                u:setdata("狮心会暴血-冷却中")
                u:changedata("狮心会暴血重数", -1)
                u:changedata("力量增幅", -0.125)
                u:changedata("敏捷增幅", -0.125)
                u:changedata("死侍意", 2)
                sishihua(0.24 * Race_Dragon_Cd[sy])
                timer:remove()
              end
            end)
          end
          if lv == 3 then
            u:effectadd("war3mapImported\\effect_red-texiao-shandian.mdl")
            u:effectadd("war3mapImported\\[TX] (327).mdl")
            local x, y = u:getxy()
            local tx = Effectcreate("war3mapImported\\[TX] (320).mdl", x, y, -1, 4)
            local tx2 = Effectcreate("war3mapImported\\[TX] (857).mdl", x, y, -1, 4)
            ChangeValue(DamageSystem_Baoji, sy, 25)
            ChangeValue(DamageSystem_Baoshang, sy, 0.25)
            u:changedata("楚子航-龙血纯度", 3)
            ac.loop(25, function(timer)
              x, y = u:getxy()
              SetEffectXY(tx, x, y)
              SetEffectXY(tx2, x, y)
              if u:getdata("狮心会暴血持续时间") == 0 then
                DestroyEffectLua(tx)
                DestroyEffectLua(tx2)
                u:setdata("狮心会暴血冷却时间", u:getdata("楚子航-暴血冷却"))
                u:setdata("狮心会暴血-冷却中")
                u:changedata("狮心会暴血重数", -1)
                ChangeValue(DamageSystem_Baoji, sy, -25)
                ChangeValue(DamageSystem_Baoshang, sy, -0.25)
                u:changedata("死侍意", 4)
                sishihua(0.36 * Race_Dragon_Cd[sy])
                timer:remove()
              end
            end)
          end
          if lv == 4 then
            u:effectadd("war3mapImported\\effect_red-texiao-shandian.mdl")
            u:effectadd("war3mapImported\\[TX] (327).mdl")
            local tx = u:effectadd("war3mapimported\\blood-buff-fulan.mdl", "origin", -1)
            PlayGlobalSound(Czh_Baoxue)
            u:changedata("楚子航-龙血纯度", 4)
            if not u:hasdata("死侍化可能") then
              u:chat("无论接下来怎么样，我都已经回不去了……")
              u:setdata("死侍化可能")
            end
            ChangeValue(DamageSystem_EndSh, sy, 0.010000000000000002)
            ac.loop(100, function(timer)
              u:clearbuff()
              if u:getdata("狮心会暴血持续时间") == 0 then
                DestroyEffectLua(tx)
                u:setdata("狮心会暴血冷却时间", u:getdata("楚子航-暴血冷却"))
                u:setdata("狮心会暴血-冷却中")
                u:changedata("狮心会暴血重数", -1)
                ChangeValue(DamageSystem_EndSh, sy, -0.010000000000000002)
                u:changedata("死侍意", 8)
                sishihua(0.48 * Race_Dragon_Cd[sy])
                timer:remove()
              end
            end)
          end
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        skill(args)
      end)
    end,
    effectname = "|cFF3399CC永燃|r|cFF667399的瞳|r|cFF994C66术师|r",
    effecttext = "|cFF3399CC混血种|r\n|cFF667399血统获取受龙变异补正影响\n不处于暴血状态时受到龙之意志层数惩罚|r\n|cFF3399CC极意|r\n|cFF667399提升33%武士刀伤害\n提升1.1%近战伤害\n提升11%近战范围|r\n|cFF3399CC君焰|r\n|cFF667399直接伤害10%对275范围单位附带[全属性*150*纯度浓度相关]火系龙属性魔力伤害,冷却1秒|r\n|cFF3399CC不灭的黄金瞳|r\n|cFF667399提升0.3%终结伤害\n提升0.1超暴系数\n降低周围500范围单位25%速度并使迅捷特性失效|r\n|cFF3399CC狮心会|r\n|cFF667399输入\"暴血\"在40秒内强化自身,可连续发动,上限四重,结束后进入冷却60秒|r\n|cFF3399CC悼亡洗礼|r\n|cFF667399[数据删除]|r",
    effectart = "war3mapImported\\BTNEwl_Czh.blp"
  },
  {
    name = "爱尔奎特",
    weight = 200,
    key = {
      "唯一",
      "根源",
      "吸血鬼",
      "月姬"
    },
    unique = true,
    addweight = function(u, var)
      local add = 0
      return add
    end,
    condition = function(u)
      local b = false
      local sy = u.ownerid
      if u:ishasshw() and u:getdata("吸血鬼变异数量") > 0 and 0 < u:getdata("根源变异数量") and not u:hasdata("变异判定-水月") and not Weiyi[19] and u:isgirl() then
        b = true
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ciyuanget(u, var)
      u:setplayername("|cFF7DBEF1[|r|cFFFFFF00爱尔奎特|r|cFF7DBEF1]|r" .. NameID[sy])
      u:reduceshw()
      u:chat("嗯~今晚也是一个美丽的月亮呢——")
      PlayGlobalSound(Sound_Arc_00)
      Weiyi[19] = true
      u:setdata("系统-无视伤害免疫")
      u:become("王")
      u:adddivinity(2)
      u:getgoddessforce(2, true)
      u:groupadd(Group_Yueji)
      ChangeValue(HeroMenu_ExtraMoveSpeed_Bfb, sy, 0.1)
      ac.wait(1000, function()
        PlayBGM({
          bgm = BGM_Aierkuite_01,
          time = 240,
          ID = 107,
          unit = u.handle
        })
        coopjudge("瓦拉齐亚之夜")
      end)
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(GetRandomReal(1, 10) * info.txgl) then
          local x, y = tg:getxy()
          u:settimedata(var.name .. "-特效冷却", 1)
          local fw = {
            300,
            175,
            600,
            450,
            225,
            225,
            275,
            600,
            275,
            825
          }
          local txz = {
            "war3mapImported\\[ake]war3ake.com - 1709800651073528605518801.mdl",
            "war3mapImported\\[TX] (1337).mdl",
            "war3mapImported\\[TX] (276).mdl",
            "war3mapImported\\[TX] (327).mdl",
            "war3mapImported\\132.mdl",
            "war3mapImported\\190.mdl",
            "war3mapImported\\ancientexplodeblue.mdl",
            "war3mapImported\\blast2.mdl",
            "war3mapImported\\effect_red-texiao-shandian.mdl",
            "war3mapImported\\skybigbang.mdl"
          }
          local byx = {
            Sound_Arc_51,
            Sound_Arc_52,
            Sound_Arc_53,
            Sound_Arc_54,
            Sound_Arc_55,
            Sound_Arc_56,
            Sound_Arc_57,
            Sound_Arc_58,
            Sound_Arc_59,
            Sound_Arc_60,
            Sound_Arc_61
          }
          local sj = GetRandomInt(1, #fw)
          Effectcreate(txz[sj])
          local txsh = u:getallattri()
          for _, xq in ac.selector():in_rangexy(x, y, fw[sj]):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            local txsh2 = txsh * GetRandomReal(10, 20 + 10 * u:getdata("根源变异数量"))
            local lv
            if sj == 10 then
              lv = GetRandomInt(3, 5)
            else
              lv = GetRandomInt(1, 5)
            end
            DamageUnit({
              bj = "爱尔奎特(附伤)",
              unit = xq.handle,
              source = u.handle,
              damage = txsh2,
              level = lv,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
          end
        end
      end)
      u:addstexiao(var.name, "伤害系统计算效果", function(args)
        local u = args.u
        local info = args.damageinfo
        info.gl = info.gl + GetRandomReal(-0.4, 0.4 + 0.2 * u:getdata("根源变异数量"))
      end)
      if u:hasdata("变异判定-血之刻印") then
        u:deldata("变异判定-血之刻印")
        u:setdata("变异判定-真祖刻印")
        u:addstexiao(var.name, "伤害判定后特效", function(args)
          local tg = args.tg
          local u = args.u
          local info = args.damageinfo
          if not u:hasdata(var.name .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
            u:settimedata(var.name .. "-特效冷却", 0.5)
            local x, y = tg:getxy()
            local sy = u.ownerid
            Effectcreate("war3mapImported\\explotion_red.mdx", x, y)
            local txsh = 6000 + 350 * u:getlevel()
            txsh = txsh * (1 + 0.02 * u:getmissperhp())
            for _, xq in ac.selector():in_rangexy(x, y, 350):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              DamageUnit({
                bj = "爱尔奎特(真祖刻印)",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "魔力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "无"
              })
            end
          end
        end)
        u:changedata("血统浓度上限", 75)
        u:uivar_change({
          keyname = "血之刻印",
          keytype = "疾病栏",
          text = "|cFFCC0000真祖刻印|r\n|cFFCC0000血统浓度上限提升75%\n造成大于100的伤害时有10%发动血咒造成350范围[6000+300*等级]魔力伤害(法)\n生命值每减少1%血咒伤害提升2%|r",
          icon = "war3mapImported\\BTNEwl_Xuezhikeyin.blp"
        })
      end
      local x, y = u:getxy()
      local by = CreateFogModifierRect(u.owner, FOG_OF_WAR_VISIBLE, RECT_PlayArea, false, false)
      local cs = 0
      local cs2 = 0
      ac.loop(1000, function()
        cs = cs + 1
        cs2 = cs2 + 1
        if cs == 12 then
          cs = 0
          u:clearbuff()
          u:effectadd("war3mapImported\\[TX] (988).mdl")
        end
        if cs2 == 60 then
          cs2 = 0
          u:addrandomstats(1 * u:getdata("根源变异数量"))
        end
        if IsTimeNight() then
          FogModifierStart(by)
        else
          FogModifierStop(by)
        end
        if u:isalive() then
          local x, y = u:getxy()
          for _, xq in ac.selector():in_rangexy(x, y, 2000):ipairs() do
            xq = getunit(xq)
            if xq:isingroup(Group_PlayHero) then
              if (xq:hasdata("变异判定-远野志贵") or not Weiyi[4] and xq:ishasshw()) and xq.handle ~= u.handle and xq:isalive() and not xq:hasdata("变异判定-七夜志贵") and xq:hasdata("奈落杀可能") then
                arkt_nailuosha(xq, u)
              end
            elseif xq:is_enemy(u.handle) then
              local a1 = xq:getface()
              local a2 = AngleBetweenUnits(xq.handle, u.handle)
              local a = a1 - a2
              if 340 <= a then
                a = a - 360
              end
              if a <= -340 then
                a = a + 360
              end
              local j4 = 25
              local t = 1.5
              if u:hasdata("瓦拉齐亚之夜-夜晚强化") then
                j4 = j4 * 2
              end
              if u:hasdata("物品-粉色墨镜") then
                t = t * 1.5
              end
              if a <= 20 and -20 <= a and u:getluckrandom(j4) then
                xq:effectadd("Abilities\\Spells\\Orc\\EtherealForm\\SpiritWalkerChange.mdl", "origin", t)
                local sj = GetRandomInt(1, 3)
                if sj == 1 then
                  if xq:isnormal() then
                    xq:buffset(u.handle, t, "石化")
                  else
                    xq:buffset(u.handle, t * 0.13, "石化")
                  end
                end
                if sj == 2 then
                  if xq:isnormal() then
                    xq:buffset(u.handle, t * 0.3, "混乱")
                  else
                    xq:buffset(u.handle, t * 0.1, "混乱")
                  end
                end
                if sj == 3 then
                  local hp = 0
                  xq:effectadd("war3mapImported\\texiao_xuebao.mdx")
                  if xq:isnormal() then
                    hp = 50
                  elseif xq:iselite() then
                    hp = 10
                  else
                    hp = 1
                  end
                  LossHpUnit({
                    u = u,
                    tg = xq,
                    damage = 0,
                    perhp = hp,
                    maxhp = 0,
                    bj = "[生命损耗]爱尔奎特魅惑之魔眼"
                  })
                  xq:buffset(u.handle, t, "眩晕")
                end
              end
            end
          end
        end
      end)
    end,
    effectname = "|cFFFFFF00爱|r|cFFFFCC00尔|r|cFFFF9900奎|r|cFFFF6600特|r",
    effecttext = "|cFFFFCC00神性 2 女神力 2\n吸血鬼 根源\n魅惑之魔眼|r\n|cFFFF9900自身2000范围内看向自身单位每秒25%触发以下一种效果：\n①石化1.5(0.25)秒\n②混乱0.45(0.15)秒\n③损耗当前50(10/1)%生命值并眩晕1.5秒|r\n|cFFFFCC00空想具现化|r\n|cFFFF9900每经过60秒提升[根源变异数量*1%]随机伤害修正\n自身伤害加成波动[-40%~(40%+20%*自身根源变异数量)]\n直接伤害时1~10%附带[250~600]范围[全属性*10~(20+10*自身根源变异数量)]随机类型魔力伤害,冷却1秒|r\n|cFFFFCC00血之姐妹|r\n|cFFFF9900无视伤害抗性\n夜晚时无视伤害减免\n视野范围扩大至全图\n夜晚时获得全图视野\n每隔12秒清除自身负面状态\n提升10%额外移速|r",
    effectart = "war3mapImported\\BTNEwl_Aierkuite.blp"
  }
}
