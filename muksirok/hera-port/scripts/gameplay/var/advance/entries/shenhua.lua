-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local AdvanceHelpers = require("gameplay.var.advance.helpers")
local medea_lily_slot_granted = false

function TryDisasterDemonLevelUp(u, newlv)
  if newlv <= u:getdata("灾祸等级") then
    return false
  end
  u:setdata("灾祸等级", newlv)
  u:sendmessage("|cFFCC0000灾祸等级提升至Lv" .. newlv .. "|r")
  return true
end

local function DisasterDemonPlaySound(sound)
  if sound and sound ~= 0 then
    PlayGlobalSound(sound)
  end
end

local function DisasterDemonLegendChat(lines, interval, starttime)
  interval = interval or 2
  starttime = starttime or 0
  local chattext = {}
  for index, text in ipairs(lines) do
    chattext[index] = {
      time = starttime + (index - 1) * interval,
      text = "|cFFCC0000" .. text .. "|r"
    }
  end
  NPCChat({
    name = "|cFF990000灾祸魔神|r",
    chaticon = "Chat_Hlm.tga",
    chattext = chattext
  })
  return starttime + #lines * interval
end

local function DisasterDemonShowAiLoading(u, lv, delay)
  delay = delay or 0
  SendDtimeMsgAll(delay, "|cFFCC0000论外技术加载中|r")
  SendDtimeMsgAll(delay + 1.1, "|cFFCC0000当前AI  lv" .. lv .. "|r")
end

local function DisasterDemonLv6Movie(u)
  local first_lines = {
    "论外技术加载完毕",
    "AI等级强制提升",
    "凶恶化"
  }
  for index, text in ipairs(first_lines) do
    SendDtimeMsgAll((index - 1) * 0.55, "|cFFCC0000" .. text .. "|r")
  end
  local tech_lines = {
    "永续-------------开启",
    "即死-------------开启",
    "落下即死-------------开启",
    "超即死-------------开启",
    "时止冻结-------------开启",
    "混线-------------开启",
    "变数弄-------------开启",
    "Othkill-------------搭载",
    "邪眼Kill-------------搭载",
    "亲变更-------------开启",
    "直死-------------开启",
    "亲捏造-------------开启",
    "绝对冻结-------------开启",
    "CNS指空-------------开启",
    "超直死-------------开启",
    "Statedef溢出-------------开启"
  }
  local starttime = 3.2
  for index, text in ipairs(tech_lines) do
    SendDtimeMsgAll(starttime + (index - 1) * 0.25, "|cFFCC0000" .. text .. "|r")
  end
  local flashtime = starttime + #tech_lines * 0.25 + 2
  ac.wait(flashtime * 1000, function()
    flashphoto({
      photo = "Ph_Hlm_02.tga",
      timeout = 0.15,
      timehold = 1.2,
      timein = 0.35
    })
    DisasterDemonPlaySound(Sound_Hlm_ai6)
    DisasterDemonLegendChat({
      "以魔神的名义命令你退下"
    }, 1.6)
  end)
end

function DisasterDemonBossKillShow(u, boss)
  if not u or not u:hasdata("神化判定-灾祸魔神") then
    return
  end
  local stage_key = boss and GetHandleId(boss) or nil
  if DisasterDemonBossKillShowLastKey == stage_key then
    return
  end
  DisasterDemonBossKillShowLastKey = stage_key
  DisasterDemonPlaySound(Sound_Hlm_Jiance)
  flashphoto({
    photo = "Ph_Hlm_01.tga",
    timeout = 0.1,
    timehold = 1.1,
    timein = 0.35
  })
  ac.wait(1500, function()
    DisasterDemonPlaySound(Sound_Hlm_KillBOSS)
    DisasterDemonLegendChat({
      "阻碍吾等魔神之人",
      "在此消失吧"
    }, 1.8)
  end)
end

RegisterAdvanceEntries({
  ["美狄亚Lily神化"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-美狄亚Lily神化"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      u:adddivinity(2)
      u:getgoddessforce(1, true)
      ChangeValue(Correction_Magic, sy, 0.020000000000000004)
      for i = 1, 6 do
        ChangeValue(DamageSystem_Shjc, i, 0.2)
      end
      ac.loop(60000, function()
        local add = u:getdata("女神力")
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:addallstats(add)
        end)
        u:sendmessage("|cFFCCB2FF[泡影之恋]提升全队" .. add .. "点全属性|r")
      end)
      PlayGlobalSound(Sound_Meidiya_N01)
      NPCChat({
        name = "|cFF9966FF美|r|cFFB28CFF狄|r|cFFCCB2FF亚|r",
        chaticon = "Chat_Meidiya.tga",
        chattext = {
          {
            text = "|cFFCCB2FF我……我这样的人获得如此幸福真的好吗……|r",
            time = 0
          },
          {
            text = "|cFFCCB2FF不，我不应该这样自卑！|r",
            time = 6.9
          },
          {
            text = "|cFFCCB2FF为了让您的战斗能平安结束|r",
            time = 10.2
          },
          {
            text = "|cFFCCB2FF我一定会尽全力的，御主。|r",
            time = 13.3
          }
        }
      })
      u:setplayername("|cFF7DBEF1[|r|cFF9966FF美狄|r|cFFB28CFF亚|r|cFF7DBEF1]|r" .. NameID[sy])
      local dskill = S2ID("A181")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          local tg = getunit(args.target)
          local x, y = u:getxy()
          local sy2 = tg.ownerid
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if not tg:isingroup(Group_PlayHero) then
            b = false
            u:sendmessage("|cFF7DBEF1目标不合法|r")
          end
          if tg.handle == u.handle then
            b = false
            u:sendmessage("|cFF7DBEF1无法对自身释放|r")
          end
          if b then
            u:buffset(u.handle, 8, "绝对闪避")
            u:buffset(u.handle, 7, "暂停")
            u:effectadd("ATX\\[ATxNew]Light_17.mdl", "overhead")
            Effectcreate("ATX\\[ATxNew]Light_11.mdl", x, y, 0, 2, 100)
            Effectcreate("ATX\\[ATxNew]Halo_02.mdl", x, y, 9, 2)
            ac.wait(6500, function()
              tg:effectadd("ATX\\[ATxNew]Magic_41.mdl", "origin", 10)
              tg:effectadd("ATX\\[ATxNew]Colour_05.mdl", "origin", 10)
            end)
            ac.wait(7000, function()
              tg:effectadd("ATX\\[ATxNew]White_15.mdl", "origin", 10)
            end)
            ac.wait(6000, function()
              ac.timer(100, 100, function()
                if tg:isalive() then
                  tg:sethp(100, true)
                  tg:setmp(100, true)
                  Hero_Tili[sy2] = Hero_Tili_Max[sy2]
                end
              end)
              tg:changekyx(-25)
              tg:addallstats(60)
              if u:getdata("女神力") >= 18 and not medea_lily_slot_granted then
                medea_lily_slot_granted = true
                ChangeValue(Hero_Shenhua_Left, sy2, 1)
                tg:sendmessage("|cFFCCB2FF[万疵必应修补]获得1个神化位|r")
              end
              if not u:hasdata("美狄亚-宝具已发动") then
                u:setdata("美狄亚-宝具已发动")
                ChangeValue(Hero_Shenhua_Left, sy2, 1)
                tg:setdata("抗药性", 0)
                tg:changemaxhp(0.25 * tg:getmaxhp())
                tg:sendmessage("|cFFCCB2FF[万疵必应修补]首次释放效果生效|r")
              end
            end)
            PlayGlobalSound(Sound_Meidiya_03)
            NPCChat({
              name = "|cFF9966FF美|r|cFFB28CFF狄|r|cFFCCB2FF亚|r",
              chaticon = "Chat_Meidiya.tga",
              chattext = {
                {
                  text = "|cFFCCB2FF希望……|r",
                  time = 1
                },
                {
                  text = "|cFFCCB2FF能有一个不会伤害他人|r",
                  time = 1.8
                },
                {
                  text = "|cFFCCB2FF也不会被他人所伤害的世界存在……|r",
                  time = 3.6
                },
                {
                  text = "|cFFCCB2FF「万疵必应修补」|r",
                  time = 6.9
                }
              }
            })
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      u:uivar_change({
        keyname = "美狄亚Lily",
        keytype = "传奇栏",
        text = "|cFF9966FF美狄|r|cFFB28CFF亚|r|cFFCCB2FFLily|r\n|cFFFF3366[神话]|r\n|cFF9966FF神性3 女神力3 女神\n唯一 魔导 同奏|r\n|cFFCCB2FF提升30%法术修正|r\n|cFF9966FF【科尔基斯的公主】|r\n|cFFCCB2FF提升全队25%伤害加成\n每60秒降低全队3%抗药性|r\n|cFF9966FF【泡影之恋】|r\n|cFFCCB2FF每60秒提升全队[自身女神力*1]全属性|r\n|cFF9966FF【万疵必应修补】|r\n|cFFCCB2FF获得额外技能[万疵必应修补]|r",
        icon = "Cq_Meidiya_Lily.tga",
        isclearclick = true
      })
    end
  end,
  ["伊利亚神化"] = function(u)
    local sy = u.ownerid
    local str = "神化判定-伊利亚"
    if not u:hasdata(str) then
      u:setdata(str)
      u:deldata("变异判定-伊利亚")
      PlayBGM({
        bgm = BGM_Yly_02,
        time = 250,
        ID = 222,
        unit = u.handle
      })
      SendMsgAll("|cFF8F220BBGM：「Allure of the Dark」")
      songtext({
        text = {
          {
            starttime = 18.6,
            str = "假如我 假如我 从此逃亡远走 世界会发生什么？"
          },
          {
            starttime = 28.2,
            str = "你与我 能不能 牵着彼此的手 看世界走向没落"
          },
          {
            starttime = 37.6,
            str = "敲响破灭之门 万物从此归于静默"
          },
          {
            starttime = 46.8,
            str = "往日憧憬的爱 仿佛在雀跃地跳动"
          },
          {
            starttime = 55.4,
            str = "啊 黑暗就快将光芒吞没"
          },
          {
            starttime = 64.5,
            str = "记忆 还保有原始的轮廓"
          },
          {
            starttime = 73.8,
            str = "啊 没有了光 就有自由",
            time = 9.2
          },
          {
            starttime = 89.5,
            str = "恶魔在引诱 悄悄对我说"
          },
          {
            starttime = 94.3,
            str = "心中有一个 好陌生的我"
          },
          {
            starttime = 98.9,
            str = "种子萌芽的场所 土壤越丑陋 越能开出艳丽的花朵"
          },
          {
            starttime = 108.3,
            str = "奏响破灭之声 生命从此归于新生"
          },
          {
            starttime = 117.5,
            str = "往日憧憬的梦 仿佛在雀跃地跳动"
          },
          {
            starttime = 126.3,
            str = "啊 黑暗就快将光芒吞没"
          },
          {
            starttime = 135.6,
            str = "残像 还凝望着我",
            time = 9.2
          },
          {
            starttime = 160.6,
            str = "矢志不渝的使命 神火焚烧的阴影"
          },
          {
            starttime = 170,
            str = "是与非 黑与白 审判由谁来决裁？"
          },
          {
            starttime = 179,
            str = "啊 黑夜就快将光明遗落"
          },
          {
            starttime = 188.3,
            str = "闪光 将天空划破",
            time = 4.7
          },
          {
            starttime = 201.9,
            str = "啊 黑暗就快将光芒吞没"
          },
          {
            starttime = 210.9,
            str = "记忆 还保有原始的轮廓"
          },
          {
            starttime = 220,
            str = "啊 我做着梦 宁静的梦",
            time = 9
          }
        },
        color = {"FF9E1818", "FFB6B6B6"}
      })
      ChangeValue(Correction_Jzsh, sy, -0.025)
      ChangeValue(Damage_Element_Light, sy, -0.05)
      u:changedata("黑暗变异数量", 1)
      u:changedata("光明变异数量", 1)
      u:changedata("根源变异数量", 1)
      u:changedata("魔导变异数量", 1)
      u:adddivinity(2)
      ChangeValue(DamageSystem_Shjc, sy, 0.2)
      ChangeValue(Correction_Jzsh, sy, 0.1)
      ChangeValue(Damage_Element_Dark, sy, 0.15)
      ChangeValue(Damage_Element_Light, sy, 0.15)
      u:changedata("全属性增幅", 0.1)
      u:changedata("效果增强-黑暗", 0.15)
      u:changedata("效果增强-光明", 0.15)
      local jz = 0
      local jc = 0
      local gm = 0
      local dark = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Jzsh, sy, 0.1 * -jz)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jc)
        ChangeValue(Damage_Element_Dark, sy, -dark)
        ChangeValue(Damage_Element_Light, sy, -gm)
        jc = 0.3 * u:getstate("根源")
        jz = 0.1 * u:getstate("战士变异")
        gm = 0.02 * u:getstate("光明变异")
        dark = 0.02 * u:getstate("黑暗变异")
        ChangeValue(Damage_Element_Light, sy, gm)
        ChangeValue(Damage_Element_Dark, sy, dark)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * jc)
        ChangeValue(Correction_Jzsh, sy, 0.1 * jz)
      end)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        local sy2 = xq.ownerid
        xq:setdata("伊利亚神化-减伤")
        xq:changedata("系统-生命恢复增强", 0.2)
      end)
      u:addstexiao(str, "过波时效果", function(args)
        if u:getdata("伊利亚-复活次数") < 2 then
          u:changedata("伊利亚-复活次数", 1)
          u:sendmessage("|cFF990000[伊利亚]复活次数增加")
        end
      end)
      u:addstexiao(str, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata(str .. "-特效冷却") then
          u:settimedata(str .. "-特效冷却", 1)
          local sh = 1000 * u:getlevel() * u:getstate("光明变异")
          DamageUnit({
            bj = "神咒魔女伊利亚附伤",
            unit = tg.handle,
            source = u.handle,
            damage = sh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = true,
            isnoarmor = false,
            element = "光"
          })
          sh = 1000 * u:getlevel() * u:getstate("黑暗变异")
          DamageUnit({
            bj = "神咒魔女伊利亚附伤",
            unit = tg.handle,
            source = u.handle,
            damage = sh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = true,
            isnoarmor = false,
            element = "暗"
          })
        end
        if not tg:hasdata("伊利亚-减抗") then
          tg:setdata("伊利亚-减抗")
          tg:changedata("光属性抗性", -15)
          tg:changedata("暗属性抗性", -15)
        end
      end)
      u:addstexiao(str, "决死效果", function(args)
        if args.dt and not u:hasdata("伊利亚神化-决死冷却") then
          args.dt = false
          u:settimedata("伊利亚神化-决死冷却", 360)
          u:sendmessage("|cFF990000[伊利亚]神咒护佑|r")
          u:settimedata("伊利亚神化-死亡抗拒", 5)
          ac.wait(5000, function()
            u:sethp(100, true)
          end)
        end
      end)
      u:setdata("变异大图-伊利亚")
      u:uivar_change({
        keyname = "伊利亚",
        keytype = "传奇栏",
        text = "|cFF990000「|r|cFF970803神|r|cFF941106咒|r|cFF921908魔|r|cFF8F220B女|r|cFF8D2A0E」|r|cFF8B3211伊|r|cFF883B14利|r|cFF864316亚|r\n|cFFFF3366[神话]|r\n|cFF990000唯一 战士 黑暗 光明 根源 魔导 神性2|r\n|cFF81541C提升[10%+1%*战士变异]近战伤害\n提升[20%+3%*根源变异]伤害加成|r\n|cFF990000【天命剑闪】|r\n|cFF81541C提升[15%+2%*光明变异]光属性伤害\n提升[15%+2%*黑暗变异]暗属性伤害\n直接伤害时附带[等级*1000*光明变异]光近战魔力伤害,冷却1秒\n直接伤害时附带[等级*1000*黑暗变异]暗近战魔力伤害,冷却1秒|r\n|cFF990000【噬光神咒】|r\n|cFF81541C提升15%黑暗变异效果\n提升15%光明变异效果\n直接伤害时降低目标15%光属性抗性与15%暗属性抗性,无法叠加|r\n|cFF990000【神咒护佑】|r\n|cFF81541C受到致死伤害时抵挡该次伤害并死亡抗拒5秒\n死亡抗拒效果结束时恢复全部生命值\n冷却360秒|r\n|cFF990000【第0号守护天使】|r\n|cFF81541C提升10%全属性\n提升全队20%终结减伤\n提升全队20%生命恢复效果\n过波时获得1次复活机会(上限2次)|r",
        icon = "NewIcon_Yly",
        hoverimage = "Cq_Yly_Shenhua.blp",
        isclearclick = true,
        dx = 4,
        ishasphoto = true,
        jbtext = function()
          UIYNameCount = 1
          UIYName[1] = {
            method = 1,
            name = "「神咒魔女」伊利亚",
            colors = {
              "990000",
              "81541C",
              "81541C",
              "990000",
              "DBA500",
              "DBA500",
              "990000"
            },
            length = 5,
            lengthcd = 30,
            math = 1,
            offsetspeed = 0.3,
            extratext = "\n" .. "|cFFFF3366[神话]|r\n|cFF990000唯一 战士 黑暗 光明 根源 魔导 神性2|r\n|cFF81541C提升[10%+1%*战士变异]近战伤害\n提升[20%+3%*根源变异]伤害加成|r\n|cFF990000【天命剑闪】|r\n|cFF81541C提升[150%+15%*光明变异]光属性伤害\n提升[150%+15%*黑暗变异]暗属性伤害\n直接伤害时附带[等级*1000*光明变异]光近战魔力伤害,冷却1秒\n直接伤害时附带[等级*1000*黑暗变异]暗近战魔力伤害,冷却1秒|r\n|cFF990000【噬光神咒】|r\n|cFF81541C提升15%黑暗变异效果\n提升15%光明变异效果\n直接伤害时降低目标15%光属性抗性与15%暗属性抗性,无法叠加|r\n|cFF990000【神咒护佑】|r\n|cFF81541C受到致死伤害时抵挡该次伤害并死亡抗拒5秒\n死亡抗拒效果结束时恢复全部生命值\n冷却360秒|r\n|cFF990000【第0号守护天使】|r\n|cFF81541C提升10%全属性\n提升全队20%终结减伤\n提升全队20%生命恢复效果\n过波时获得1次复活机会(上限2次)|r"
          }
        end
      })
      u:deldata("变异大图-伊利亚")
    end
  end,
  ["利姆露"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-利姆露"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      u:become("王")
      PlayBGM({
        bgm = BGM_Rimuru_011,
        time = 280,
        ID = 56,
        unit = u.handle
      })
      u:setplayername("|cFF7DBEF1[|r|cFF99CCFF利姆露|r|cFF7DBEF1]|r" .. NameID[sy])
      u:sendmessage("|cFF3366FF没|r|cFF3C6DFF有|r|cFF4573FF力|r|cFF4E7AFF量|r|cFF5681FF的|r|cFF5F87FF理|r|cFF688EFF想|r|cFF7195FF是|r|cFF7A9BFF戏|r|cFF83A2FF言|r|cFF8CA9FF，|r|cFF95AFFF没|r|cFF9DB6FF有|r|cFFA6BCFF理|r|cFFAFC3FF想|r|cFFB8CAFF的|r|cFFC1D0FF力|r|cFFCAD7FF量|r|cFFD3DEFF是|r|cFFDCE4FF空|r|cFFE4EBFF虚|r|cFFEDF2FF。|r")
      ChangeValue(DamageSystem_Shjc, sy, 0.12)
      ChangeValue(Correction_HealUp, sy, 0.25)
      u:setdata("利姆露-无限再生能量", math.floor(1 + u:getlevel() / 10))
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 50)
      u:addallstats(120)
      local cs = 0
      ac.loop(1000, function()
        ForGroupLuaNew(u:getdata("利姆露-命中组"), function(xq)
          if u:hasdata("利姆露-禁忌化") then
            LossHpUnit({
              u = u,
              tg = xq,
              damage = 0,
              perhp = 0,
              maxhp = 2,
              bj = "利姆露[生命损耗]"
            })
          else
            LossHpUnit({
              u = u,
              tg = xq,
              damage = 0,
              perhp = 0,
              maxhp = 1,
              bj = "利姆露[生命损耗]"
            })
          end
        end)
        cs = cs + 1
        if 320 <= cs then
          u:setdata("利姆露-无限再生能量", math.floor(1 + u:getlevel() / 10))
        end
      end)
      u:addstexiao(str, "直接伤害变更", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:getluckrandom(10) and info.level <= 5 then
          info.level = 5
        end
      end)
      u:uivar_change({
        keyname = "转生史莱姆",
        keytype = "传奇栏",
        text = "|cFF99CCFF利|r|cFF80B2FF姆|r|cFF6699FF露|r\n|cFF99CCFF神性 1\n暴风之纹章|r\n|cFF6699FF[数据删除]|r\n|cFF99CCFF无限再生|r\n|cFF6699FF[数据删除]|r\n|cFF99CCFF万能感知|r\n|cFF6699FF[数据删除]|r\n|cFF99CCFF万能变化|r\n|cFF6699FF[数据删除]|r\n|cFF99CCFF魔王霸气|r\n|cFF6699FF[数据删除]|r\n|cFF99CCFF黑炎|r\n|cFF6699FF[数据删除]|r\n|cFF99CCFF万能丝|r\n|cFF6699FF[数据删除]|r\n|cFF99CCFF暴食者|r\n|cFF6699FF[数据删除]|r",
        icon = "war3mapImported\\BTNEwl_Rimuru_Shenhua.blp"
      })
    end
  end,
  ["大月下"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-大月下"
    if not u:hasdata(str) then
      -- 슬롯이 없으면 각성 표시와 신력 부하를 변경하지 않는다.
      if not u:ishasshw() then
        u:sendmessage("|cFFCCB2FF남은 신화 슬롯이 부족합니다.|r")
        return
      end
      u:setdata(str)
      u:reduceshw()
      u:changedata("系统-神力承载", 4)
      u:changedata("雷变异数量", 1)
      u:changedata("狂化值", 3)
      u:changedata("原罪值", 1)
      PlayBGM({
        bgm = 0,
        time = 207,
        ID = 246,
        unit = u.handle
      })
      NPCChat({
        name = "|cFFA21520月|r|cFFAC1E29下|r|cFFB62631誓|r|cFFC12E3A约|r|cFFCB3742.|r|cFFD5404B予|r|cFFE04854爱|r|cFFEA505C以|r|cFFF45965心|r",
        chaticon = "Chat_Delisha.tga",
        chattext = {
          {
            text = "|cFFCB3742谢谢你，握住了我的手",
            time = 0
          },
          {
            text = "|cFFCB3742我再也…再也不会放你了……",
            time = 4
          }
        }
      })
      flashphoto({
        photo = "Ph_Dayuexia.tga",
        timeout = 3,
        timehold = 3,
        timein = 5
      })
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:buffset(u.handle, 12, "绝对闪避")
      end)
      PlayGlobalSound(Sound_Dayuexia_02)
      ac.wait(7000, function()
        SendMsgAll("|cFFF45965BGM:《月下誓约.予爱以心》|r", 30)
        PlayGlobalSound(BGM_Dayuexia_01)
        songtext({
          text = {
            {
              starttime = 9.6,
              str = "捉迷藏穿过旧时光隙"
            },
            {
              starttime = 13.2,
              str = "你笑声漫过月光阶梯"
            },
            {
              starttime = 16.9,
              str = "石棺里垂下丝绒帷幕"
            },
            {
              starttime = 20.1,
              str = "颤抖的掌心藏着温度"
            },
            {
              starttime = 23.9,
              str = "警报刺穿回廊的寂静"
            },
            {
              starttime = 27.1,
              str = "斗篷裹住未落的泪滴"
            },
            {
              starttime = 31,
              str = "\"别出声\" 耳语如咒文"
            },
            {
              starttime = 34.5,
              str = "睫毛压着黎明的灰尘"
            },
            {
              starttime = 41.7,
              str = "血色月轮下缔结誓约"
            },
            {
              starttime = 45.3,
              str = "血红丝线缠绕此刻永恒"
            },
            {
              starttime = 48.7,
              str = "故事书页间追逐倒影"
            },
            {
              starttime = 52.5,
              str = "你衣摆掠过的每一帧"
            },
            {
              starttime = 56.2,
              str = "背叛所有既定的黄昏"
            },
            {
              starttime = 62.8,
              str = "这誓言永不蒙尘",
              time = 8.5
            },
            {
              starttime = 85.7,
              str = "空荡街巷没有笑声沸腾"
            },
            {
              starttime = 89.1,
              str = "褪色贝壳盛满海风咸腥"
            },
            {
              starttime = 92.6,
              str = "旋转木马困在褪色黎明"
            },
            {
              starttime = 96.2,
              str = "没有你连光都失去姓名"
            },
            {
              starttime = 99.9,
              str = "法典刻着虚伪的公正"
            },
            {
              starttime = 103.4,
              str = "说我们注定走向牺牲"
            },
            {
              starttime = 106.8,
              str = "但我会咬碎所有囚笼"
            },
            {
              starttime = 110.5,
              str = "用你教我的那种英勇"
            },
            {
              starttime = 117.5,
              str = "血色月轮下缔结誓约"
            },
            {
              starttime = 121,
              str = "血红丝线缠绕此刻永恒"
            },
            {
              starttime = 124.5,
              str = "命运废墟里拾取回声"
            },
            {
              starttime = 128.4,
              str = "你指尖残留的每一寸"
            },
            {
              starttime = 132.2,
              str = "改写命运既定的剧本"
            },
            {
              starttime = 138.6,
              str = "为你偷取新生"
            },
            {
              starttime = 147.7,
              str = "褪下借来的温暖斗篷"
            },
            {
              starttime = 154.7,
              str = "刺破喉间凝固的冰棱"
            },
            {
              starttime = 161.9,
              str = "我要让世界听清"
            },
            {
              starttime = 168.3,
              str = "利刃出鞘的声音"
            },
            {
              starttime = 175.5,
              str = "\"现在睁开眼吧\" 你说"
            },
            {
              starttime = 179.0,
              str = "故事的终章永不坠落"
            },
            {
              starttime = 182.6,
              str = "晨光里凝固的笑纹"
            },
            {
              starttime = 186.2,
              str = "借来的时光里永续晨昏",
              time = 4.2
            }
          },
          isjbcolor = true,
          color = {
            "FF610000",
            "FFDB4444",
            "FFDB4444",
            "FF610000"
          }
        })
      end)
      u:setplayername("|cFF84141F月|r|cFF9A1C28下|r|cFFB02431誓|r|cFFC72B39约.|r" .. NameID[sy])
      ChangeValue(DamageSystem_Baoji, sy, 10)
      local khz = 0
      local add = 0
      local xgzq = 0
      local xxg = 0
      ac.loop(3000, function()
        u:changedata("吸血鬼变异数量", -xxg)
        xxg = math.floor(0.25 * u:getdata("德丽莎变异数量"))
        u:changedata("吸血鬼变异数量", xxg)
        u:changedata("效果增强-德丽莎", -xgzq)
        xgzq = 0.5 * u:getdata("效果增强-吸血鬼")
        u:changedata("效果增强-德丽莎", xgzq)
        u:changedata("狂化值", -khz)
        khz = 2 * u:getdata("原罪值")
        u:changedata("狂化值", khz)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        add = 0.005 * u:getstate("狂化值") * u:getstate("吸血鬼变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      end)
      u:addstexiao(str, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata(str .. "-特效冷却") then
          u:settimedata(str .. "-特效冷却", 1)
          u:curetili(0.25)
        end
      end)
      u:uivar_change({
        keyname = "月下初拥",
        keytype = "传奇栏",
        text = "|cFFA21520月|r|cFFAC1E29下|r|cFFB62631誓|r|cFFC12E3A约|r|cFFCB3742.|r|cFFD5404B予|r|cFFE04854爱|r|cFFEA505C以|r|cFFF45965心|r\n|cFFFF3366[神话]|r\n|cFFA21520原罪 1\n吸血鬼 雷 德丽莎 战士 唯一|r\n|cFFA21520【破除规则的束缚】|r\n|cFFF45965提升3点狂化值\n提升[2*原罪值]点狂化值\n提升[狂化值*0.05%*吸血鬼变异]伤害加成\n直接伤害时恢复0.25体力,冷却1秒|r\n|cFFA21520【逾越命运的告白】|r\n|cFFF45965提升[德丽莎变异*0.2%+吸血鬼变异*0.1%]近战伤害\n每造成4次近战直接伤害,附带一次[2%*(德丽莎变异+吸血鬼变异)*伤害值]物理伤害\n同时施加1级[流血强度]与1层[流血层数]|r\n|cFFA21520【隐忍克制的疏离】|r\n|cFFF45965提升22%暴击率\n提升50%流血伤害\n提升[德丽莎变异*1.5%+吸血鬼变异*0.75%]暴击伤害\n降低25%基础位移技能冷却|r\n|cFFA21520【永不凋零的誓约】|r\n|cFFF45965自身吸血鬼变异数量视为提升[德丽莎变异数量*25%](取整)\n自身德丽莎变异享受50%吸血鬼变异效果增强\n提升[德丽莎变异*1%+吸血鬼变异*0.5%]伤害加成\n提升[德丽莎变异*0.2%++吸血鬼变异*0.1%]终结伤害\n提升12%全属性抗性|r",
        icon = "Cq_Delisha_Dayuexia_Big.tga",
        smallicon = "Cq_Delisha_Dayuexia.tga",
        ishasphoto = true,
        isclearclick = true,
        dx = 4
      })
    end
  end,
  ["星国储君"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-星国储君"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      u:changedata("系统-神力承载", 2)
      u:changedata("唯一变异数量", 1)
      Weiyi_New[24] = true
      u:chat("|cFFFFFF99败北！？我！！？|r")
      u:chat("|cFFFF9900星国储君|r|cFFFFFF99的词典中没有败北！", 3)
      PlayBGM({
        bgm = BGM_Chujun_01,
        time = 130,
        ID = 245,
        unit = u.handle
      })
      u:setplayername("|cFF7DBEF1[|r|cFFFF9900星|r|cFFFFAD0A国|r|cFFFFC214储|r|cFFFFD61F君|r|cFF7DBEF1]|r" .. NameID[sy])
      local x, y = u:getxy()
      local wp = CreateItemLua("I0PH", x, y)
      SetData(wp, "所属玩家", u.owner)
      u:addspeitem(wp)
      u:changedata("储君-铸造值", 15)
      u:changedata("效果增强-星", 0.15)
      local zzz = 0
      ac.loop(3000, function()
        u:changedata("储君-铸造值", -zzz)
        zzz = math.floor(0.25 * u:getdata("储君-铸造值"))
        u:changedata("储君-铸造值", zzz)
      end)
      u:uivar_change({
        keyname = "储君",
        keytype = "传奇栏",
        text = "|cFFFF8040星|r|cFFFC9663国|r|cFFF8AC86储|r|cFFF5C2A8君|r\n|cFFCC66FF[超凡]|r\n|cFFFF8040星 唯一|r\n|cFFFF8040【天命所归】|r\n|cFFD8A575过波时降低1级并提升1级\n提升[3%*星变异]伤害加成\n提升30%星变异效果|r\n|cFFFF8040【我铸剑！】|r\n|cFFD8A575进阶时获得15点铸造值\n提升25%铸造值\n[君王之剑]基础伤害翻倍\n[君王之剑]近战基础伤害加成提升50%|r\n|cFFFF8040【我选卡！】|r\n|cFFD8A575[点击]查看当前拥有的卡牌效果\n进阶时获得一张稀有卡牌奖励\n过波时选择一张卡牌奖励|r\n|cFFFF8040【我已到来！】|r\n|cFFD8A575提升稀有卡牌与罕见卡牌出现概率\n死亡时复活,冷却180秒|r",
        icon = "Cq_Chujun_Big.tga",
        smallicon = "Cq_Chujun.tga",
        ishasphoto = true,
        dx = 5,
        size_h = 0.7
      })
    end
  end,
  ["千咲神化"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-千咲神化"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      u:changedata("系统-神力承载", 5)
      u:changedata("战士变异数量", 1)
      Weiyi_New[23] = true
      if u:hasdata("千咲-日配") then
        PlayGlobalSound(Sound_Qianxiao_Shenhua_Jp)
      else
        PlayGlobalSound(Sound_Qianxiao_Shenhua)
      end
      u:chat("|cFFEC2935闭嘴！")
      u:chat("|cFFEC2935怪物也好……", 1.6)
      u:chat("|cFFEC2935被拖下深渊也好……", 3.1)
      u:chat("|cFFEC2935那又如何", 5)
      u:chat("|cFFEC2935我不要在虚假的平和里", 8.2)
      u:chat("|cFFEC2935对一切视而不见", 10.1)
      u:chat("|cFFEC2935我会切断循环的源头", 12.7)
      u:chat("|cFFEC2935我会切出一条足以撕碎\"它\"的道路！", 15.6)
      u:chat("|cFFEC2935哪怕下一步是泥沼", 19.8)
      u:chat("|cFFEC2935下一步是深渊----", 21.3)
      u:chat("|cFFEC2935我也会踩着你们，踏过去！", 23.5)
      PlayBGM({
        bgm = 0,
        time = 232.5,
        ID = 239,
        unit = u.handle
      })
      ac.wait(27500, function()
        SendMsgAll("|cffEC2935BGM:《破茧之华》|r")
        PlayGlobalSound(BGM_QianxiaoShenhua)
        songtext({
          text = {
            {
              starttime = 10.3,
              str = "已听不见，快要听不见"
            },
            {
              starttime = 13,
              str = "那记忆中的声线"
            },
            {
              starttime = 15.5,
              str = "只剩下模糊的孤独感在吞噬着一切"
            },
            {
              starttime = 20.3,
              str = "能实现吗？还能实现吗？"
            },
            {
              starttime = 22.7,
              str = "虚无缥缈的心愿"
            },
            {
              starttime = 24.7,
              str = "我只想知道如何找到心灵的依靠"
            },
            {
              starttime = 29.6,
              str = "在这如梦似幻扭曲而又反复的世界"
            },
            {
              starttime = 34.9,
              str = "我日以继夜苦苦追寻破局的奇点"
            },
            {
              starttime = 39.7,
              str = "若可以跨越循环实现心中的信念"
            },
            {
              starttime = 44.6,
              str = "就不会再犹豫不决破茧成蝶",
              time = 5.3
            },
            {
              starttime = 50.8,
              str = "把眼泪都撕裂，不愿再做妥协"
            },
            {
              starttime = 55.6,
              str = "被封印的诅咒能否找到出口？"
            },
            {
              starttime = 60.8,
              str = "脉搏不断地跳跃，挣扎中变得强烈"
            },
            {
              starttime = 65.7,
              str = "即使再小的火焰，也可能会燎原"
            },
            {
              starttime = 70.6,
              str = "来不及去纪念，已忘记了时间"
            },
            {
              starttime = 75.3,
              str = "等回头才明白失去的感觉"
            },
            {
              starttime = 80.4,
              str = "这个冰冷的世界，总会有一些温暖"
            },
            {
              starttime = 85.7,
              str = "等你发现",
              time = 2.6
            },
            {
              starttime = 90.4,
              str = "伤口刺痛，心碎的淤血，在无止尽地蔓延"
            },
            {
              starttime = 95.2,
              str = "抬头仰望，假装看不见，脚底下的深渊"
            },
            {
              starttime = 100.3,
              str = "一步一步，小心地捡起，回忆之中的碎片"
            },
            {
              starttime = 104.6,
              str = "努力拼凑，那曙光欲现的明天"
            },
            {
              starttime = 109.6,
              str = "熟悉的城市熟悉的街和熟悉的季节"
            },
            {
              starttime = 114.9,
              str = "只是熟悉的一切已变得不再像从前"
            },
            {
              starttime = 119.6,
              str = "未能完成的夙愿，还能重新被唤醒吗？"
            },
            {
              starttime = 124.8,
              str = "去照亮昏暗的夜，连成一片",
              time = 9.4
            },
            {
              starttime = 139.4,
              str = "消失不见的雨点，随风而去的落叶"
            },
            {
              starttime = 144.4,
              str = "终有一天会涅槃重生在轮回之间",
              time = 6.4
            },
            {
              starttime = 151.7,
              str = "把眼泪都撕裂，不愿再做妥协"
            },
            {
              starttime = 156.7,
              str = "被封印的诅咒能否找到出口？"
            },
            {
              starttime = 161.7,
              str = "脉搏不断地跳跃，挣扎中变得强烈"
            },
            {
              starttime = 166.7,
              str = "即使再小的火焰，也可能会燎原"
            },
            {
              starttime = 171.4,
              str = "来不及去纪念，已忘记了时间"
            },
            {
              starttime = 176.3,
              str = "破晓钟声会驱散最黑的夜"
            },
            {
              starttime = 181.4,
              str = "这个冰冷的世界，用温柔的爱去理解"
            },
            {
              starttime = 187.2,
              str = "会绽放出新的希望"
            },
            {
              starttime = 191.3,
              str = "让我再次听见",
              time = 5.2
            }
          },
          color = {"FFEC2935", "FFF79DA2"},
          isjbcolor = true
        })
      end)
      ChangeValue(Correction_Jzsh, sy, 0.1)
      u:addstexiao(str, "近战伤害效果", function(args)
        local tg = args.tg
        local u = args.u
        if not u:hasdata(str .. "-特效冷却") then
          u:settimedata(str .. "-特效冷却", 2)
          LossHpUnit({
            u = u,
            tg = tg,
            damage = 0,
            perhp = 2,
            maxhp = 0,
            bj = "[生命损耗]断命之铗"
          })
        end
      end)
      local jz = 0
      local add = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        ChangeValue(Correction_Jzsh, sy, 0.1 * -jz)
        local zd = u:returnmaxvar()
        jz = 0.1 * u:getdata(zd .. "变异数量")
        add = 0.18 * u:getdata(zd .. "变异数量")
        if u:hasdata("英雄-千咲") then
          add = add * 2
        end
        ChangeValue(Correction_Jzsh, sy, 0.1 * jz)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      end)
      ChangeValue(DamageSystem_EndSh, sy, 0.009)
      ChangeValue(Hero_Tili_Huifu, sy, 0.18)
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not tg:hasdata("千咲-解弦之眼破甲") then
          tg:setdata("千咲-解弦之眼破甲")
          tg:changearmor(-36)
        end
      end)
      u:addstexiao(str, "暴击系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:getarmor() < 0 then
          local z = tg:getarmor() * -1
          info.bjsh = info.bjsh + z * 0.005
        end
      end)
      if u:hasdata("英雄-千咲") then
        u:setdata("千咲-游戏失败轮回判定")
        ChangeValue(DamageSystem_EndSh, sy, 0.009)
        ChangeValue(Hero_Tili_Huifu, sy, 0.18)
        u:changedata("千咲-共鸣解放值上限", 50)
        u:uivar_change({
          keyname = "解弦之眼",
          keytype = "传奇栏",
          text = "|cFFEC2935C|r|cFFEF4650h|r|cFFF2636Ci|r|cFFF48087s|r|cFFF79DA2a|r\n|cFFCC66FF[超凡]|r\n|cFFEC2935唯一 根源 战士|r\n|cFFF79DA2提升10%近战伤害\n提升25%招式基础伤害|r\n|cFFEC2935【断命之铗】|r\n|cFFF79DA2提升[1%*主变异数量]近战伤害\n近战伤害附带2%当前生命值损耗,冷却2秒|r\n|cFFEC2935【解弦之眼】|r\n|cFFF79DA2直接伤害时降低目标36护甲,无法叠加\n对负护甲单位提升[护甲负值*0.5%]暴击伤害\n自身招式伤害命中BOSS时:\n[降低目标1护甲并提升其0.5%额外受伤,持续7秒,可叠加,分立计时]|r\n|cFFEC2935【解弦式第零定律】|r\n|cFFF79DA2提升1.8%终结伤害\n提升0.36体力恢复\n提升[3.6%*主变异数量]伤害加成\n提升50共鸣解放上限|r\n|cFF949596“颈间的装置平静无声，此刻她的共鸣波谱正呈现出罕见的稳定曲线。\n就像被雨水洗过的夏日天空，终于透出一丝光亮。”|r",
          icon = "Shenhua_Qianxiao_Big.tga",
          ishasphoto = true,
          size_h = 1.38,
          smallicon = "Shenhua_Qianxiao.tga",
          isclearclick = true
        })
      else
        u:uivar_change({
          keyname = "解弦之眼",
          keytype = "传奇栏",
          text = "|cFFEC2935C|r|cFFEF4650h|r|cFFF2636Ci|r|cFFF48087s|r|cFFF79DA2a|r\n|cFFCC66FF[超凡]|r\n|cFFEC2935唯一 根源 战士|r\n|cFFF79DA2提升10%近战伤害|r\n|cFFEC2935【断命之铗】|r\n|cFFF79DA2提升[1%*主变异数量]近战伤害\n近战伤害附带2%当前生命值损耗,冷却2秒|r\n|cFFEC2935【解弦之眼】|r\n|cFFF79DA2直接伤害时降低目标36护甲,无法叠加\n对负护甲单位提升[护甲负值*0.5%]暴击伤害\n近战伤害命中BOSS时:\n[降低目标1护甲并提升其0.5%额外受伤,持续7秒,可叠加,分立计时,冷却0.25秒]|r\n|cFFEC2935【解弦式第零定律】|r\n|cFFF79DA2提升0.9%终结伤害\n提升0.18体力恢复\n提升[1.8%*主变异数量]伤害加成|r\n|cFF949596“颈间的装置平静无声，此刻她的共鸣波谱正呈现出罕见的稳定曲线。\n就像被雨水洗过的夏日天空，终于透出一丝光亮。”|r",
          icon = "Shenhua_Qianxiao_Big.tga",
          ishasphoto = true,
          size_h = 1.38,
          smallicon = "Shenhua_Qianxiao.tga",
          isclearclick = true
        })
        u:addstexiao(str .. "2", "近战伤害效果", function(args)
          local tg = args.tg
          local u = args.u
          if tg:isboss() and not u:hasdata(str .. "-近战特效冷却") then
            u:settimedata(str .. "-近战特效冷却", 0.25)
            tg:changetimearmor(-1, 7)
            tg:changetimedata("怪物-额外受伤", 0.005, 7)
          end
        end)
      end
    end
  end,
  ["古明地恋神化2"] = function(u)
    local sy = u.ownerid
    local str = "神化判定-古明地恋2"
    if not u:hasdata(str) then
      u:setdata(str)
      SendMsgAll("|cFF80B074B|r|cFF83A976G|r|cFF86A377M|r|cFF889C79:|r|cFF8B957A《|r|cFF8E8E7C無|r|cFF91887D意|r|cFF93817F識|r|cFF967A81レ|r|cFF997482ク|r|cFF9C6D84イ|r|cFF9E6685エ|r|cFFA15F87ム|r|cFFA45988 |r|cFFA7528Aあ|r|cFFA94B8Cや|r|cFFAC458Dぽ|r|cFFAF3E8Fん|r|cFFB23790ず|r|cFFB43092》|r")
      PlayBGM({
        bgm = BGM_Lianlian_Shenhua2,
        time = 210,
        ID = 235,
        unit = u.handle
      })
      NPCChat({
        name = "|cFF80B074玛丽小姐|r",
        chaticon = "Chat_Lianlian.blp",
        chattext = {
          {
            text = "|cFFB43092晚上好",
            time = 70.6
          },
          {
            text = "|cFFB43092呐",
            time = 71.4
          },
          {
            text = "|cFFB43092你知道吗？",
            time = 72
          },
          {
            text = "|cFFB43092初次见面",
            time = 92.5
          },
          {
            text = "|cFFB43092晚上好",
            time = 93.6
          },
          {
            text = "|cFFB43092你是雨吗？",
            time = 94.6
          },
          {
            text = "|cFFB43092现在就去你身边",
            time = 100.3
          },
          {
            text = "|cFFB43092我的存在",
            time = 132.0
          },
          {
            text = "|cFFB43092你察觉到了吗？",
            time = 133.1
          }
        }
      })
      songtext({
        text = {
          {
            starttime = 35.3,
            str = "午前二时 点灭 水银灯"
          },
          {
            starttime = 38.6,
            str = "仄暗い交差点"
          },
          {
            starttime = 40.6,
            str = "后ろの正面から 听こえる声"
          },
          {
            starttime = 45.1,
            str = "谁かが嘯いていた"
          },
          {starttime = 48.0, str = "噂话に"},
          {
            starttime = 50.5,
            str = "曰く、そいつは"
          },
          {
            starttime = 53.0,
            str = "ひっそりと立っていた"
          },
          {
            starttime = 55.4,
            str = "无机质プッシュ音そっと谺する"
          },
          {
            starttime = 60.4,
            str = "后には戻れないよ 连ぐ先に待つ天国か地狱",
            time = 8.1
          },
          {
            starttime = 72.9,
            str = "见て见て あなたのそばで"
          },
          {
            starttime = 75.3,
            str = "谁かが窥いているよ"
          },
          {
            starttime = 77.9,
            str = "トラウマの雨を降らし、ポトリ"
          },
          {
            starttime = 80.3,
            str = "今日も一羽だけ煮えていく ha",
            time = 2.6
          },
          {
            starttime = 96.3,
            str = "隠れんぼしたのよ イタズラ",
            time = 3.7
          },
          {
            starttime = 101.8,
            str = "会いに行くから"
          },
          {starttime = 103.9, str = "邻の邻"},
          {
            starttime = 107.0,
            str = "そう谁が作った"
          },
          {starttime = 110, str = "噂话に"},
          {
            starttime = 112.4,
            str = "曰く、そいつは"
          },
          {
            starttime = 114.8,
            str = "后ろの正面に嗤うそれは?"
          },
          {
            starttime = 118.5,
            str = "闻いてもっと镇魂歌"
          },
          {
            starttime = 121.0,
            str = "确かな存在は？"
          },
          {
            starttime = 123.4,
            str = "受话器越しの境界"
          },
          {
            starttime = 125.8,
            str = "どこにもなくてそこにある"
          },
          {
            starttime = 128.4,
            str = "幻视する世界",
            time = 2.6
          },
          {
            starttime = 134.4,
            str = "ガチャガチャ ノブ转す音"
          },
          {
            starttime = 136.7,
            str = "真夜中二时のヒメゴト"
          },
          {
            starttime = 139.4,
            str = "影すら见えない足音が"
          },
          {
            starttime = 141.8,
            str = "ここには来れない二羽がなく",
            time = 2.6
          },
          {
            starttime = 145,
            str = "溃れてた 脸见てたって"
          },
          {
            starttime = 147.3,
            str = "谁もかも连なって"
          },
          {
            starttime = 149.8,
            str = "头から裂れ裂れ"
          },
          {
            starttime = 152.5,
            str = "这って伝うの赤信号"
          },
          {
            starttime = 155.1,
            str = "ここから ここまで"
          },
          {
            starttime = 156.9,
            str = "どこかの 迷い道通りゃんせ"
          },
          {
            starttime = 160,
            str = "天神さま言いました"
          },
          {
            starttime = 162.1,
            str = "归りは剥がれます けれど"
          },
          {
            starttime = 164.6,
            str = "平气平气平气平气"
          },
          {
            starttime = 167,
            str = "ちぎれ ちぎる きみと きみも"
          },
          {
            starttime = 170.7,
            str = "まじる あかい あかい 无駄骨よ"
          },
          {
            starttime = 174.6,
            str = "せかい ひとり あなた わたし"
          },
          {
            starttime = 178.0,
            str = "ゆめも ついに おわり"
          },
          {
            starttime = 180.8,
            str = "いたい いたい いたイ",
            time = 4.2
          }
        },
        color = {"FF80B074", "FFB43092"},
        isjbcolor = true
      })
      local strname = "古明地恋神化2"
      if not u:hasdata("恋恋-神化位使用") then
        u:setdata("恋恋-神化位使用")
        u:reduceshw()
      end
      u:changedata("系统-神力承载", 2)
      u:changedata("黑暗变异数量", 1)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      local jz = 0
      local add = 0
      local heart = 0
      ac.loop(3000, function()
        ChangeValue(DamageSplit_CountJzMax, sy, -add)
        ChangeValue(Correction_Jzsh, sy, 0.1 * -jz)
        ChangeValue(Damage_Element_Heart, sy, -heart)
        jz = 0.001 * u:getstate("累积杀敌")
        add = 0.02 * u:getstate("东方变异")
        heart = 0.03 * u:getstate("东方变异")
        ChangeValue(Correction_Jzsh, sy, 0.1 * jz)
        ChangeValue(DamageSplit_CountJzMax, sy, add)
        ChangeValue(Damage_Element_Heart, sy, heart)
      end)
      u:addstexiao(strname, "近战伤害效果", function(args)
        if args.element == "无" then
          args.element = "心灵"
        end
      end)
      u:addstexiao(strname, "近战伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(strname .. "-特效冷却") then
          u:settimedata(strname .. "-特效冷却", 1)
          local txsh = 5000 + u:getallattri() * 100
          DamageUnit({
            bj = "先祖之影附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "灵力",
            isvest = true,
            isattack = true,
            isnoarmor = false,
            element = "心灵",
            extradata = {}
          })
        end
      end)
      u:addstexiao(strname, "决死效果", function(args)
        if args.dt and not u:hasdata("古明地恋-决死冷却") then
          args.dt = false
          u:settimedata("古明地恋-决死冷却", 180)
          u:buffset(u.handle, 0.5, "绝对闪避")
          u:sethp(100, true)
          u:sendmessage("|cff910000[古明地恋]先祖之影|r")
        end
      end)
      u:addstexiao(strname, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:hasbuff("B0GT") then
          if not tg:hasdata("蔷薇花园-心灵抗性降低") then
            tg:setdata("蔷薇花园-心灵抗性降低")
            tg:changedata("心灵属性抗性", -20)
          end
          if not u:hasdata(strname .. "-特效冷却") then
            u:settimedata(strname .. "-特效冷却", 1)
            DamageUnit({
              bj = "蔷薇地狱附伤",
              unit = tg.handle,
              source = u.handle,
              damage = info.yssh * 1,
              level = 1,
              type = "灵力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "心灵",
              extradata = {}
            })
          end
        end
      end)
      u:addstexiao(strname, "杀敌效果", function(args)
        local u = args.u
        local tg = args.tg
        ChangeValue(DamageSystem_Shjc, sy, 1.5E-4)
        if tg:hasbuff("B0GT") then
          ChangeValue(Correction_Magic, sy, 1.4999999999999999E-5)
        end
      end)
      local dskill = S2ID("A0MY")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          local tg = getunit(args.target)
          local dis = DistanceBetweenUnits(u.handle, args.target)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法打电话|r")
          end
          if tg:isboss() or tg:isingroup(Group_PlayHero) then
          else
            b = false
            u:sendmessage("|cFF7DBEF1无法对目标打电话|r")
          end
          if tg == u then
            b = false
            u:sendmessage("|cFF7DBEF1无法对自己打电话|r")
          end
          if b then
            if tg:isingroup(Group_PlayHero) then
              ewl:setskillcd(dskill, 120)
            end
            MovieAct["玛丽小姐的电话"](u, tg)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      u:uivar_add({
        keyname = "古明地恋神化2",
        keytype = "传奇栏",
        text = "|cff910000察觉到了读心所导致的他人的厌恶和恐惧，\n所以闭上可以读心的第三只眼，\n这样便不会遭到地底居民们的厌恶、恐惧，\n但也不会被他人所喜欢了。|r",
        icon = "Lianlian_Shenhua2",
        ishasphoto = true
      })
    end
  end,
  ["古明地恋神化1"] = function(u)
    local sy = u.ownerid
    local str = "神化判定-古明地恋"
    if not u:hasdata(str) then
      u:setdata(str)
      local strname = "古明地恋神化"
      if not u:hasdata("恋恋-神化位使用") then
        u:setdata("恋恋-神化位使用")
        u:reduceshw()
      end
      u:changedata("系统-神力承载", 2)
      u:changedata("光明变异数量", 1)
      SendMsgAll("|cFFFF66FFB|r|cFFF66FF9G|r|cFFED78F3M|r|cFFE481ED:|r|cff030303《|r|cFFD293E1瞳|r|cFFC99CDBを|r|cFFC0A5D5閉|r|cFFB7AECFじ|r|cFFAEB7C9て|r|cFFA5C0C3、|r|cFF9CC9BD映|r|cFF93D2B7す|r|cFF8ADBB1夢|r|cFF81E4AB幻|r|cFF78EDA5》|r")
      PlayBGM({
        bgm = BGM_Lianlian_Shenhua1,
        time = 290,
        ID = 234,
        unit = u.handle
      })
      songtext({
        text = {
          {
            starttime = 0.7,
            str = "夢見る私は静かに"
          },
          {
            starttime = 4.3,
            str = "瞳を閉ざすだけでいい"
          },
          {
            starttime = 7.6,
            str = "今も鮮やかなに蘇る"
          },
          {
            starttime = 11.2,
            str = "儚き夢幻を抱きしめて",
            time = 3.1
          },
          {
            starttime = 28.3,
            str = "密かに想いを寄せてたの"
          },
          {
            starttime = 35.1,
            str = "いつでも優しい君だから"
          },
          {
            starttime = 41.8,
            str = "普段の会話も嬉しくて"
          },
          {
            starttime = 48.8,
            str = "今宵も溺れ胸を焦がす"
          },
          {
            starttime = 55.7,
            str = "あぁ知りたいけど壊せないーー"
          },
          {
            starttime = 59.1,
            str = "些細な幸せを"
          },
          {
            starttime = 62.7,
            str = "ひとり夜空を見上げては"
          },
          {
            starttime = 66,
            str = "泣きたくなるの"
          },
          {
            starttime = 69.3,
            str = "君のせいだよ"
          },
          {
            starttime = 72.9,
            str = "夢見る私は静かに"
          },
          {
            starttime = 76.3,
            str = "期待に胸を躍らせ"
          },
          {
            starttime = 79.6,
            str = "君の瞳が見つめる先"
          },
          {
            starttime = 83.1,
            str = "私であれと願い込めた"
          },
          {
            starttime = 86.7,
            str = "踏み出す事が恐くても"
          },
          {
            starttime = 90,
            str = "変わる事に怯えても"
          },
          {
            starttime = 93.3,
            str = "いつか理想を歩めるように"
          },
          {
            starttime = 97,
            str = "祈りに似た希望を抱いて",
            time = 3
          },
          {
            starttime = 114.1,
            str = "微かに覚えた違和感は"
          },
          {
            starttime = 120,
            str = "偽れぬ無意識を悟り"
          },
          {
            starttime = 127.6,
            str = "彼方へ向けたあまい表情は"
          },
          {
            starttime = 134.5,
            str = "呼吸が止まる程 胸を刺す"
          },
          {
            starttime = 141.5,
            str = "もう知りたく無くて逸らしたーー"
          },
          {
            starttime = 144.9,
            str = "幸せそうな2人"
          },
          {
            starttime = 148.4,
            str = "淡い思い出なぞっては"
          },
          {
            starttime = 151.9,
            str = "泣きたくなるの"
          },
          {
            starttime = 155.3,
            str = "君のせいだよ"
          },
          {
            starttime = 158.7,
            str = "そして人知れず静かに"
          },
          {
            starttime = 162.1,
            str = "瞳を閉ざすだけでいい"
          },
          {
            starttime = 165.5,
            str = "君の優しさに酔いしれた"
          },
          {
            starttime = 168.9,
            str = "独りよがりの無様の恋"
          },
          {
            starttime = 172.3,
            str = "音無く零れた雫に"
          },
          {
            starttime = 175.8,
            str = "秘めた想いを託して"
          },
          {
            starttime = 179.2,
            str = "明日も君と笑えるように"
          },
          {
            starttime = 182.7,
            str = "今日までの全てを流した"
          },
          {
            starttime = 186.1,
            str = "胸の痛みを抱いたまま"
          },
          {
            starttime = 189.5,
            str = "それでも変わらぬ恋心",
            time = 4.4
          },
          {
            starttime = 225.4,
            str = "季節は無常に巡れて"
          },
          {
            starttime = 228.8,
            str = "痛む想いは変わらず"
          },
          {
            starttime = 232.2,
            str = "新たな風が背中押せば"
          },
          {
            starttime = 235.8,
            str = "願う君の幸せ…",
            time = 4.3
          },
          {
            starttime = 243.5,
            str = "そして人知れず静かに"
          },
          {
            starttime = 245.9,
            str = "瞳を閉ざすだけでいい"
          },
          {
            starttime = 249.2,
            str = "君の優しさに酔いしれた"
          },
          {
            starttime = 252.9,
            str = "独りよがりの無様の恋"
          },
          {
            starttime = 256.4,
            str = "音無く零れた雫に"
          },
          {
            starttime = 259.8,
            str = "秘めた想いを託して"
          },
          {
            starttime = 263.1,
            str = "明日も君と笑えるように"
          },
          {
            starttime = 266.6,
            str = "今日までの全てを流した"
          },
          {
            starttime = 270,
            str = "二度と叶う事はなくても"
          },
          {
            starttime = 273.5,
            str = "それでも変わらぬ恋心",
            time = 5
          }
        },
        color = {"FFFF66FF", "FF78EDA5"},
        isjbcolor = true
      })
      local x, y = u:getxy()
      local mj = u:createunit("u00A", x, y)
      local tx2 = Effectcreate("Lianlian_Tx_Guanghuan.mdx", x, y, -1, 11, -90)
      mj:animespeed(0.1)
      mj:setcolor(255, 255, 255, 125)
      ac.loop(30, function()
        if u:hasdata("蔷薇花园-固定X") then
          local dx = u:getdata("蔷薇花园-固定X")
          local dy = u:getdata("蔷薇花园-固定Y")
          mj:setxy(dx, dy)
          SetEffectXY(tx2, dx, dy)
        else
          local dx, dy = u:getxy()
          if u:isalive() then
            mj:setxy(dx, dy)
            SetEffectXY(tx2, dx, dy)
          else
            mj:setxy(PX_X, PX_Y)
            SetEffectXY(PX_X, dx, PX_Y)
          end
        end
      end)
      u:addstexiao(strname, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:hasbuff("B0GT") then
          if u:hasdata("蔷薇花园-固定X") then
            if not tg:hasdata("蔷薇花园-额外受伤") then
              tg:setdata("蔷薇花园-额外受伤")
              tg:changedata("怪物-额外受伤", 0.25)
            end
            if not tg:hasdata(strname .. "-缠绕特效冷却") then
              local t = 10
              if tg:isboss() then
                t = 30
              end
              tg:settimedata(strname .. "-缠绕特效冷却", t)
              local kzt = 3
              tg:effectadd("Lianlian_Tx_Cr.mdx", "origin", kzt)
              tg:buffset(u.handle, 3, "僵直")
              tg:buffset(u.handle, 3, "眩晕")
            end
          end
          if not u:hasdata(strname .. "-特效冷却") then
            u:settimedata(strname .. "-特效冷却", 6)
            local add = 3 + u:getmissperhp() * 0.12
            u:curehp(u.handle, 0, add, 4)
          end
        end
      end)
      u:addstexiao(strname, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("蔷薇花园-固定X") and tg:hasbuff("B0GT") then
          info.wsmy = true
          info.wssb = true
        end
      end)
      u:addstexiao(strname, "怪物减伤计算", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("蔷薇花园-固定X") and tg:hasbuff("B0GT") then
          info.ewjs = 1
        end
      end)
      ChangeValue(Damage_ElementRes_Heart, sy, 25)
      u:addtrgevent("单位-指定点目标指令", function(args)
        if args.orderid == String2OrderIdBJ("smart") and u:hasdata("蔷薇花园-固定X") then
          local x = u:getdata("蔷薇花园-固定X")
          local y = u:getdata("蔷薇花园-固定Y")
          local x2 = args.x
          local y2 = args.y
          local dis = DistanceXY(x, y, x2, y2)
          if 900 < dis or u:hasdata("蔷薇花园-位移冷却") then
            return
          end
          u:settimedata("蔷薇花园-位移冷却", 1)
          local x3, y3 = u:getxy()
          u:setxy(x2, y2)
          Effectcreate("war3mapImported\\blackblink.mdx", x2, y2)
          Effectcreate("war3mapImported\\blackblink.mdx", x3, y3)
        end
      end)
      local gun = 0
      local zd = 0
      local cs = 0
      ac.loop(3000, function()
        ChangeValue(Correction_Gun, sy, 0.1 * -gun)
        gun = 0.001 * u:getstate("累积杀敌")
        ChangeValue(Correction_Gun, sy, 0.1 * gun)
        ChangeValue(Correction_Gun_Bullet, sy, -zd)
        zd = 0.0025 * u:getdata("系统-累积等级")
        ChangeValue(Correction_Gun_Bullet, sy, zd)
        if u:isalive() then
          cs = cs + 1
          if 30 <= cs then
            cs = 0
            local r = GetRandomInt(1, 5)
            if r == 1 then
              u:additem("I00X")
              u:additem("I00X")
              u:sendmessage("|cFF9999FF[恋]获得次元匣")
            elseif r == 2 then
              ChangeValue(Hero_Tili_Huifu, sy, 0.1)
              ChangeValue(Hero_Tili_Max, sy, 1)
              u:sendmessage("|cFF9999FF[恋]提升体力上限与恢复")
            elseif r == 3 then
              u:changedata("全属性增幅", 0.0025)
              u:sendmessage("|cFF9999FF[恋]提升全属性")
            elseif r == 4 then
              ChangeValue(Correction_MHp, sy, 0.001)
              u:sendmessage("|cFF9999FF[恋]提升生命上限")
            elseif r == 5 then
              mapmove(u.handle)
              u:sendmessage("|cFF9999FF[恋]随机传送")
            end
          end
        end
      end)
      local dskill = S2ID("A0MR")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          local tg = getunit(args.target)
          local dis = DistanceBetweenUnits(u.handle, args.target)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            if u:hasdata("蔷薇花园-固定X") then
              u:deldata("蔷薇花园-固定X")
              u:deldata("蔷薇花园-固定Y")
              u:sendmessage("|cFF7DBEF1解除蔷薇花园固定|r")
            else
              local x, y = u:getxy()
              u:setdata("蔷薇花园-固定X", x)
              u:setdata("蔷薇花园-固定Y", y)
              u:sendmessage("|cFF7DBEF1蔷薇花园固定|r")
              local cs = 0
              ac.loop(1000, function(timer)
                if u:isalive() then
                  cs = cs + 1
                  if 2 <= cs then
                    cs = 0
                    local txsh = 100 * u:getlevel()
                    for _, xq in ac.selector():in_rangexy(x, y, 900):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      local xs = 0.01
                      if xq:isnormal() then
                        xs = 0.05
                      end
                      DamageUnit({
                        bj = "蔷薇地狱附伤",
                        unit = xq.handle,
                        source = u.handle,
                        damage = txsh + xs * xq:getmaxhp(),
                        level = 4,
                        type = "物理",
                        isvest = true,
                        isattack = false,
                        isnoarmor = false,
                        element = "心灵",
                        extradata = {}
                      })
                    end
                  end
                end
                if not u:hasdata("蔷薇花园-固定X") then
                  timer:remove()
                end
              end)
            end
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      u:uivar_change({
        keyname = "古明地恋",
        keytype = "传奇栏",
        text = "|cFF60D1E7就算看到她，她也什么都不会做，\n所以应该没有对策的必要。\n但是只有打算去刺激她这件事是万万不可。\n万一，作为妖怪觉而复活的话，对谁都没好处。|r",
        icon = "Lianlian_Shenhua",
        ishasphoto = true
      })
    end
  end,
  ["炼狱杏寿郎"] = function(u)
    local sy = u.ownerid
    local str = "神化判定-炎之呼吸"
    if not u:hasdata(str) then
      u:setdata(str)
      u:setplayername("|cFF7DBEF1[|r|cFFFF0000炎|r|cFFFF6633柱|r|cFF7DBEF1]|r" .. NameID[sy])
      u:chat("|cFFFF0000若|r|cFFFF0C08你|r|cFFFF1810敢|r|cFFFF2318对|r|cFFFF2F1F无|r|cFFFF3B27辜|r|cFFFF472F之|r|cFFFF5237人|r|cFFFF5E3F露|r|cFFFF6A47出|r|cFFFF764E獠|r|cFFFF8156牙|r")
      ac.wait(4300, function()
        u:chat("|cFFFF0000『|r|cFFFF0805炼|r|cFFFF0F0A狱|r|cFFFF170F的|r|cFFFF1F14赤|r|cFFFF261A炎|r|cFFFF2E1F刀|r|cFFFF3624，|r|cFFFF3D29定|r|cFFFF452E将|r|cFFFF4C33你|r|cFFFF5438烧|r|cFFFF5C3D的|r|cFFFF6342尸|r|cFFFF6B47骨|r|cFFFF734C无|r|cFFFF7A52存|r|cFFFF8257！|r|cFFFF8A5C』|r")
      end)
      PlayGlobalSound(Sound_Dage_Get_01)
      PlayBGM({
        bgm = 0,
        time = 11,
        ID = 0
      })
      ac.wait(10000, function()
        PlayBGM({
          bgm = BGM_Dage_01,
          time = 95,
          ID = 225,
          unit = u.handle
        })
        SendMsgAll("|cFFFF0000【BGM:炼狱の战斗】")
      end)
      flashphoto({
        photo = "Ph_Dage_01.tga",
        timeout = 2,
        timehold = 2,
        timein = 2
      })
      u:changedata("系统-神力承载", 4)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:buffset(u.handle, 8, "绝对闪避")
      end)
      ChangeValue(DamageSystem_Shjc, sy, 0.1)
      ChangeValue(Correction_Jzsh, sy, 0.1)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      ChangeValue(DamageSplit_CountJzMax, sy, 0.4)
      local jc = 0
      local huo = 0
      ac.loop(3000, function(timer)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jc)
        ChangeValue(Damage_Element_Fire, sy, -huo)
        jc = 0.05 * u:getdata("灼烧层数")
        huo = 0.02 * u:getstate("战士变异")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * jc)
        ChangeValue(Damage_Element_Fire, sy, huo)
      end)
      u:addstexiao(str, "直接伤害特效", function(args)
        if not u:hasdata(str .. "-特效冷却") then
          local u = args.u
          local tg = args.tg
          local txsh = 3000 * u:getlevel()
          u:settimedata(str .. "-特效冷却", 0.25)
          DamageUnit({
            bj = "炎之呼吸(上升炎天)",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "灵力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "火"
          })
        end
      end)
      u:addstexiao(str, "决死效果", function(args)
        if args.dt and not u:hasdata("炼狱杏寿郎-决死冷却") then
          args.dt = false
          u:sendmessage("|cFFF95C24[炼狱杏寿郎]上升炎天决死|r")
          u:settimedata("炼狱杏寿郎-决死冷却", 270)
          u:settimedata("炼狱杏寿郎-死亡抗拒", 9)
        end
      end)
      u:uivar_change({
        keyname = "炎之呼吸",
        keytype = "传奇栏",
        text = "|cFFF95C24炼|r|cFFF7742E狱|r|cFFF58C38杏|r|cFFF3A442寿|r|cFFF1BC4C郎|r\n|cFFFF3366[神话]|r\n|cFFF95C24唯一 战士 炎|r\n|cFFF1BC4C提升15%伤害加成\n提升15%近战伤害\n提升[1%*背水]生命恢复|r\n|cFFF95C24【全集中.常中】|r\n|cFFF1BC4C提升0.1体力恢复\n杀敌时提升0.01%近战伤害\n直接伤害时恢复2%体力值,冷却0.5秒|r\n|cFFF95C24【一之型.不知火】|r\n|cFFF1BC4C提升[0.5%*炎变异]近战伤害\n免疫灼烧负面\n免疫燃烧抑制恢复\n直接伤害时对目标与自身施加一层灼烧,冷却1秒\n受到伤害时对目标与自身施加两层灼烧,冷却1秒\n对灼烧中目标,目标每层灼烧伤害提升0.5%,护甲效果降低[1+1%]\n自身每有一层灼烧所受伤害降低1%(上限25%)\n自身灼烧达到10层时,直接伤害时附带[10%*原始伤害值]火灵力伤害,触发冷却0.5秒\n自身灼烧达到15层时,无属性伤害变为炎属性伤害|r\n|cFFF95C24【贰之型.上升炎天】|r\n|cFFF1BC4C近战伤害段数+1(火灵力)\n近战伤害多段上限+40%\n提升[0.5%*自身灼烧层数]伤害加成\n提升[2%*战士变异]火属性伤害\n直接伤害时附带[等级*3000]火灵力伤害,冷却0.25秒\n受到致死伤害时抵挡并死亡抗拒9秒,冷却270秒|r",
        icon = "Cq_Yanzhu_01",
        ishasphoto = true,
        isclearclick = true
      })
    end
  end,
  ["阿米娅"] = function(u)
    local sy = u.ownerid
    local str = "神化判定-阿米娅"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      Boolean_Amiya_Shenhua = true
      NameID[sy] = "|cFF000000■■■|r|cFFCCCCCC阿|r|cFFA6A6A6米|r|cFF808080娅|r|cFF000000■■■|r"
      u:setplayername(NameID[sy])
      SendMsgAll("|cFFCCCCCC『|r|cFFC6C6C6我|r|cFFC0C0C0知|r|cFFBABABA道|r|cFFB4B4B4“|r|cFFADADAD魔|r|cFFA7A7A7王|r|cFFA1A1A1”|r|cFF9B9B9B的|r|cFF959595力|r|cFF8F8F8F量|r|cFF898989并|r|cFF838383非|r|cFF7C7C7C是|r|cFF767676征|r|cFF707070服|r|cFF6A6A6A或|r|cFF646464者|r|cFF5E5E5E统|r|cFF585858御|r|cFF525252而|r|cFF4B4B4B存|r|cFF454545在|r|cFF3F3F3F』|r", 10)
      SendDtimeMsgAll(3, "|cFFCCCCCC『|r|cFFB9B9B9它|r|cFFA6A6A6的|r|cFF939393本|r|cFF808080意|r|cFF6C6C6C是|r|cFF595959』|r", 10)
      SendDtimeMsgAll(6, "|cFFCCCCCC『|r|cFFB6B6B6“|r|cFFA0A0A0存|r|cFF8A8A8A续|r|cFF757575”|r|cFF5F5F5F』|r", 10)
      PlayBGM({
        bgm = Amiya_BGM_02,
        time = 190,
        ID = 205,
        unit = u.handle
      })
      u:additem("I0LA")
      local x, y = u:getxy()
      local tx = Effectcreate("Shio_Amiya_Tx_Fz.mdx", x, y, -1, 2)
      ac.loop(30, function()
        x, y = u:getxy()
        SetEffectXY(tx, x - 16, y - 16)
      end)
      u:effectadd("Shio_Amiya_Tx_Cr_2.mdx", "chest", -1)
      ac.wait(180000, function()
        SendMsgAll("|cFFCCCCCC『|r|cFFB9B9B9我|r|cFFA6A6A6始|r|cFF939393终|r|cFF808080如|r|cFF6C6C6C一|r|cFF595959』|r", 10)
        SendDtimeMsgAll(3, "|cFFCCCCCC『|r|cFFB6B6B6终|r|cFFA0A0A0点|r|cFF8A8A8A—|r|cFF757575—|r|cFF5F5F5F』|r", 10)
        SendDtimeMsgAll(6, "|cFFCCCCCC『|r|cFFBEBEBE.|r|cFFB0B0B0.|r|cFFA2A2A2.|r|cFF949494.|r|cFF868686.|r|cFF797979.|r|cFF6B6B6B已|r|cFF5D5D5D至|r|cFF4F4F4F』|r", 10)
        ac.wait(7000, function()
          flashphoto({
            photo = "Ph_Amiya.tga",
            timeout = 2,
            timehold = 2,
            timein = 2
          })
        end)
      end)
      AddAllSTexiao(str, "决死效果", function(args)
        local u = args.u
        local sy = u.ownerid
        if args.dt and not u:hasdata("神化判定-阿米娅") and not u:hasdata("一切苦难的奇迹-决死冷却") then
          args.dt = false
          u:settimedata("一切苦难的奇迹-决死冷却", 1200)
          u:sendmessage("|cFFCCCCCC阿|r|cFFBFBFBF米|r|cFFB2B2B2娅|r|cFFA6A6A6-|r|cFF999999一|r|cFF8C8C8C切|r|cFF808080苦|r|cFF737373难|r|cFF666666的|r|cFF595959奇|r|cFF4C4C4C迹|r")
          local add = 1 * u:getmaxhp() + 100 * u:getlevel()
          hdzlinshiadd(u, add)
        end
      end)
      ChangeValue(HeroMenu_HpChange_MaxHp, sy, 1.5)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        local sy2 = xq.ownerid
        ChangeValue(Correction_MEDCgl, sy2, 0.1)
      end)
      u:addstexiao(str .. "弹幕", "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata("阿米娅-弹幕附伤冷却") then
          u:settimedata("阿米娅-弹幕附伤冷却", 9)
          local txsh = 10000 + (1 + 10 * u:getallattri() * u:getdata("系统-血液源石结晶密度") / 100)
          local count = math.floor(3 + u:getallattri() / 100)
          if 9 <= count then
            count = 9
          end
          local x, y = u:getxy()
          local x2, y2 = tg:getxy()
          local angle = GetRandomAngle()
          for i = 1, count do
            angle = angle + 360 / count
            unifycreate({
              owner = u.handle,
              model = "Shio_Amiya_Tx_Dm.mdx",
              modelname = "弹幕",
              modelsize = 4.5,
              height = 90,
              damage = txsh,
              damagetype = 4,
              x = x2,
              y = y2,
              range = 1000,
              speed = 3000,
              volume = 90,
              angle = angle,
              angleoffset = 0,
              attenua = 1,
              attenuacount = 999,
              life = 10,
              isbullet = false,
              isvest = true,
              isignorearmor = false,
              startfunc = function(mj)
                mj:setdata("循环计数", 0)
              end,
              loopfunc = function(mj)
                mj:changedata("循环计数", UnifyDT)
                if mj:getdata("循环计数") >= 0.03 then
                  mj:setdata("循环计数", 0)
                end
              end,
              hitfunc = function(mj, damage)
                return damage
              end,
              hitbeforefunc = function(mj, xq, damage2)
              end,
              hitafterfunc = function(mj, xq, damage2)
              end,
              endfunc = function(mj)
              end
            })
          end
        end
      end)
      u:uivar_change({
        keyname = "幼小的魔王",
        keytype = "传奇栏",
        text = "|cFFCCCCCC阿|r|cFFA6A6A6米|r|cFF808080娅|r\n|cFFCCCCCC我知道“魔王”的力量并非是征服或者统御而存在|r\n|cFFB6B6B6它的本意是|r\n|cFFA0A0A0“存续”|r\n|cFF8A8A8A我始终如一|r\n|cFF757575终点——|r\n|cFF5F5F5F......已至|r",
        icon = "Amiya_Shenhua.tga",
        ishasphoto = true
      })
    end
  end,
  ["虹猫神化"] = function(u)
    local sy = u.ownerid
    local str = "神化判定-虹猫"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      u:setplayername("|cFF7DBEF1[|r|cFF990000白衣少侠|r|cFF7DBEF1]|r" .. NameID[sy])
      u:chat("|cFFFF0000心中无我，方能无欲无求无畏无惧无畏无悔方能收发自如|r")
      ac.wait(7000, function()
        u:chat("|cFFFF0000人剑合一，终能无坚不摧，爹！我终于悟到了")
      end)
      PlayGlobalSound(Sound_Hongmao_Shenhua)
      ac.wait(10000, function()
        PlayBGM({
          bgm = BGM_Hongmao_01,
          time = 95,
          ID = 203,
          unit = u.handle
        })
      end)
      u:addallstats(20)
      ChangeValue(DamageSplit_CountJzMax, sy, 0.25)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      ChangeValue(Correction_Jzsh, sy, 0.020000000000000004)
      ChangeValue(DamageSystem_Shjc, sy, 0.035)
      ChangeValue(DamageSystem_Shjc, sy, 0.035)
      ChangeValue(Correction_Cbxs, sy, 0.05)
      ChangeValue(DamageSystem_EndSh, sy, 0.010000000000000002)
      ChangeValue(DamageSystem_Shjc, sy, 0.03)
      ChangeValue(Hero_Tili_Huifu, sy, 0.1)
      ChangeValue(KillReward_MHp, sy, 1)
      u:addstexiao(str, "杀敌效果", function(args)
        local tg = args.tg
        if GetRandom100(10) then
          u:addstr(1)
        end
        ChangeValue(Correction_Jzsh, sy, 1.0E-4)
      end)
      local gs = 0
      ac.loop(3000, function()
        u:changedata("固定伤害", 0.1 * -gs)
        gs = 1000 * u:getlevel()
        u:changedata("固定伤害", 0.1 * gs)
      end)
      u:addstexiao(str, "决死效果", function(args)
        if args.dt and not u:hasdata("虹猫神化-决死冷却") then
          args.dt = false
          u:settimedata("虹猫神化-决死冷却", 360)
          u:buffset(u.handle, 2, "绝对闪避")
          u:sendmessage("|cFFE8443D虹猫-火舞旋风心法|r")
          ac.timer(100, 20, function()
            u:sethp(100, true)
          end)
        end
      end)
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(str .. "-特效2冷却") then
          local gl = 4 * u:getdata("虹猫-七剑数量")
          if u:getluckrandom(info.txgl * gl) then
            u:settimedata(str .. "-特效2冷却", 1)
            local txsh = info.yssh * 0.4 + 300 * u:getallattri()
            DamageUnit({
              bj = "虹猫七剑附伤",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "灵力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
          end
        end
      end)
      u:uivar_change({
        keyname = "虹猫",
        keytype = "传奇栏",
        text = "|cFFE8443D白|r|cFFED6964衣|r|cFFF18F8B少|r|cFFF6B4B1侠|r\n|cFFE8443D唯一 战士 光明\n消灭魔教|r\n|cFFF6B4B1[数据删除]|r\n|cFFE8443D火舞旋风|r\n|cFFF6B4B1[数据删除]|r\n|cFFE8443D至阳至刚|r\n|cFFF6B4B1[数据删除]|r\n|cFFE8443D长虹剑法|r\n|cFFF6B4B1[数据删除]|r\n|cFFE8443D火舞旋风心法|r\n|cFFF6B4B1[数据删除]|r\n|cFFE8443D火舞旋风剑法|r\n|cFFF6B4B1[数据删除]|r",
        icon = "Ewl_Cq_Hongmao"
      })
    end
  end,
  ["丛雨神化"] = function(u)
    local sy = u.ownerid
    local str = "丛雨-神化"
    if not u:hasdata(str) then
      u:setdata(str)
      if u:getdata("锁魂计数") > 0 then
        u:changedata("锁魂计数", -1)
      else
        u:reduceshw()
      end
      NameAChange[sy] = "|cFF66FF99丛|r|cFFCCFFCC雨|r"
      u:addskill("A0OY")
      u:adddivinity(2)
      u:getgoddessforce(1)
      u:deldata("诅咒-灵体化")
      u:uivar_remove("灵体化", "传奇栏")
      u:setdata("丛雨复活时间", 60)
      PlayGlobalSound(Sound_Murasame_07)
      SendDtimeMsgAll(0, "|cFF66FF99「唔姆~你就是吾辈的主人吗？」|r")
      SendDtimeMsgAll(4.5, "|cFF66FF99「吾辈名为丛雨」|r")
      SendDtimeMsgAll(7.2, "|cFF66FF99「是『丛雨丸』的管理者。」|r")
      SendDtimeMsgAll(9.6, "|cFF66FF99「嘛，就像是『丛雨丸』的灵魂一样的东西。」|r")
      PlayBGM({
        bgm = BGM_Murasame_01,
        time = 190,
        ID = 52,
        unit = u.handle
      })
      u:setdata("守护灵概率", 75)
      local zr = getunit(Qiyue_Murasame_Master)
      local sy2 = zr.ownerid
      zr:setdata("丛雨-神刀寄魂")
      ChangeValue(DamageSystem_EndSh, sy2, 0.012)
      ChangeValue(DamageSystem_Shjc, sy2, 0.012)
      zr:addstexiao(str, "近战伤害效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if zr:hasdata("丛雨-神刀寄魂解放") then
          info.damage = info.damage * 1.18
        else
          info.damage = info.damage * 1.06
        end
      end)
      local kill = KillCount[sy] + KillCount[sy2]
      KillCount[sy] = kill
      KillCount[sy2] = kill
      local sm = 5 + kill / 100
      if 15 <= sm then
        sm = 15
      end
      zr:setdata("司命计数", sm)
      local b = false
      ac.loop(1000, function(timer)
        if zr:getdata("司命杀敌计数") >= 100 then
          zr:changedata("司命杀敌计数", -100)
          zr:changedata("司命计数", 1)
        end
        if zr:getdata("司命计数") <= 0 and not b then
          b = true
          PlayGlobalSound(Sound_Murasame_05)
          SendMsgAll("|cFF66FF99「主人！天诛！无礼也要有个限度啊！」|r")
          ac.wait(5000, function()
            SendMsgAll(zr:getplayername() .. "|cFF66FF99,你这样是不会有小丛雨喜欢你的。|r")
          end)
        end
        if zr:getdata("司命计数") >= 20 then
          zr:deldata("司命计数")
          AdvanceGet["丛雨解放"](u)
          timer:remove()
        end
      end)
      local cy = u
      zr:addstexiao(str, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata(str .. "-特效冷却") then
          local gl = 7
          if u:hasdata("丛雨-神刀寄魂解放") then
            gl = 14
          end
          if u:getluckrandom(gl * info.txgl) then
            u:settimedata(str .. "-特效冷却", 0.7)
            local txsh
            if u:hasdata("丛雨-神刀寄魂解放") then
              txsh = 0.6 * info.yssh + cy:getallattri() * 144
            else
              txsh = 0.3 * info.yssh
            end
            DamageUnit({
              bj = "丛雨神刀寄魂",
              unit = tg.handle,
              source = cy.handle,
              damage = txsh,
              level = 1,
              type = "物理",
              isvest = true,
              isattack = true,
              isnoarmor = false,
              element = "风"
            })
          end
        end
      end)
      zr:uivar_add({
        keyname = "神刀寄魂",
        keytype = "传奇栏",
        text = "|cFF00FF99神刀寄魂|r\n|cFF66FF99与丛雨共享杀敌\n初始获得(杀敌数/100)点司命计数,不会超过十五点\n每杀死100个敌人增加一点司命计数\n提升6%近战伤害(独立)\n提升1.2%伤害加成\n提升1.2%终结伤害\n直接伤害时7%附带[30%*伤害值]近战物理纯粹伤害(伤害来源为丛雨),触发冷却0.7秒|r",
        icon = "war3mapImported\\BTNMurasame_Jihun.blp"
      })
      u:uivar_change({
        keyname = "丛雨初始",
        keytype = "传奇栏",
        text = "|cFF00FF99丛雨|r\n|cFF00FF99神性 2\n五百年的守望|r\n|cFF66FF99每隔480秒提升1点神性\n每次队友死亡永久增加自身0.5%近战伤害与5点全属性|r\n|cFF00FF99神刀寄魂|r\n|cFF00FF99守护灵|r\n|cFF66FF99受到大于100伤害时75%格挡该次伤害\n触发时在60秒内降低10%无效化概率,下限25%|r\n|cFF00FF99护主|r\n|cFF66FF99无法常规复活,死亡60秒后在主人处复活,每次触发提升10秒延迟,仅主人存活时计时\n主人彻底死亡且幼刀存活时,由幼刀代为死亡并降低3点司命计数|r\n|cFF00FF99神刀管理者|r\n|cFF00FF99供奉仪式|r\n|cFF66FF99司命计数达到二十点时解放丛雨|r",
        icon = "war3mapImported\\PASBTNMurasame_Shenhua"
      })
    end
  end,
  ["黄金体验"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-黄金体验"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      PlayGlobalSound(Sound_RR_102)
      SendDtimeMsgAll(0, "|cFFFF0000『|r|cFFFF0C02残|r|cFFFF1805存|r|cFFFF2407下|r|cFFFF310A来|r|cFFFF3D0C的|r|cFFFF490F |r|cFFFF5511只|r|cFFFF6113会|r|cFFFF6D16是|r|cFFFF7918这|r|cFFFF861B个|r|cFFFF921D世|r|cFFFF9E20界|r|cFFFFAA22的|r|cFFFFB624「|r|cFFFFC227真|r|cFFFFCE29实|r|cFFFFDB2C」|r|cFFFFE72E』|r")
      SendDtimeMsgAll(3.8, "|cFFFF0000『|r|cFFFF0902而|r|cFFFF1304从|r|cFFFF1C06「|r|cFFFF2608真|r|cFFFF2F09实|r|cFFFF390B」|r|cFFFF420D中|r|cFFFF4C0F衍|r|cFFFF5511生|r|cFFFF5E13出|r|cFFFF6815来|r|cFFFF7117的|r|cFFFF7B19真|r|cFFFF841A挚|r|cFFFF8E1C行|r|cFFFF971E动|r|cFFFFA120 |r|cFFFFAA22是|r|cFFFFB324绝|r|cFFFFBD26不|r|cFFFFC628会|r|cFFFFD02A毁|r|cFFFFD92B灭|r|cFFFFE32D的|r|cFFFFEC2F』|r")
      SendDtimeMsgAll(8.1, "|cFFFF0000『|r|cFFFF0A02虽|r|cFFFF1404然|r|cFFFF1F06同|r|cFFFF2908伴|r|cFFFF330A们|r|cFFFF3D0C已|r|cFFFF470E逝|r|cFFFF5210 |r|cFFFF5C12但|r|cFFFF6614他|r|cFFFF7016们|r|cFFFF7A18的|r|cFFFF851B行|r|cFFFF8F1D动|r|cFFFF991F和|r|cFFFFA321意|r|cFFFFAD23志|r|cFFFFB825却|r|cFFFFC227没|r|cFFFFCC29被|r|cFFFFD62B毁|r|cFFFFE02D灭|r|cFFFFEB2F』|r")
      SendDtimeMsgAll(13.2, "|cFFFF0000『|r|cFFFF0F03是|r|cFFFF1E06他|r|cFFFF2D09们|r|cFFFF3C0C吧|r|cFFFF4B0F这|r|cFFFF5A12只|r|cFFFF6915箭|r|cFFFF7818交|r|cFFFF871B到|r|cFFFF961E了|r|cFFFFA521我|r|cFFFFB424的|r|cFFFFC327手|r|cFFFFD22A中|r|cFFFFE12D』|r")
      SendDtimeMsgAll(16.3, "|cFFFF0000『|r|cFFFF0C02而|r|cFFFF1705你|r|cFFFF2307的|r|cFFFF2E09行|r|cFFFF3A0C为|r|cFFFF460E究|r|cFFFF5110竟|r|cFFFF5D13是|r|cFFFF6815从|r|cFFFF7417「|r|cFFFF801A真|r|cFFFF8B1C实|r|cFFFF971E」|r|cFFFFA220中|r|cFFFFAE23衍|r|cFFFFB925生|r|cFFFFC527出|r|cFFFFD12A来|r|cFFFFDC2C的|r|cFFFFE82E』|r")
      SendDtimeMsgAll(20.2, "|cFFFF0000『|r|cFFFF0F03还|r|cFFFF1E06是|r|cFFFF2D09从|r|cFFFF3C0C表|r|cFFFF4B0F面|r|cFFFF5A12的|r|cFFFF6915邪|r|cFFFF7818恶|r|cFFFF871B中|r|cFFFF961E衍|r|cFFFFA521生|r|cFFFFB424出|r|cFFFFC327来|r|cFFFFD22A的|r|cFFFFE12D』|r")
      SendDtimeMsgAll(23.9, "|cFFFF0000『|r|cFFFF1404我|r|cFFFF2708们|r|cFFFF3B0C马|r|cFFFF4E10上|r|cFFFF6214就|r|cFFFF7618能|r|cFFFF891B见|r|cFFFF9D1F分|r|cFFFFB123晓|r|cFFFFC427了|r|cFFFFD82B』|r")
      SendDtimeMsgAll(26.5, "|cFFFF0000『|r|cFFFF1204你|r|cFFFF2407真|r|cFFFF370B的|r|cFFFF490F可|r|cFFFF5B12以|r|cFFFF6D16不|r|cFFFF801A被|r|cFFFF921D毁|r|cFFFFA421灭|r|cFFFFB624么|r|cFFFFC828？|r|cFFFFDB2C』|r")
      u:changedata("闪避值", 10)
      ChangeValue(Hero_Tili_Huifu, sy, 0.1)
      ChangeValue(DamageSystem_Baoji, sy, 10)
      ChangeValue(DamageSystem_Baoshang, sy, 0.1)
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(str .. "-特效2冷却") then
          u:settimedata(str .. "-特效2冷却", 1)
          local txsh = 500 * u:getallattri()
          DamageUnit({
            bj = "黄金体验神化紫烟附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 5,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "暗",
            extradata = {""}
          })
          if not tg:hasdata("茸茸-紫烟抑制") then
            tg:groupadd(HpGroup)
            tg:setdata("茸茸-紫烟抑制")
            tg:setdata("茸茸-紫烟来源", u)
          end
        end
        if not u:hasdata(str .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(str .. "-特效冷却", 1)
          local zs = GetRandomInt(2, 4)
          if zs == 2 then
            if tg:isnormal() then
              ac.wait(1000, function()
                tg:kill()
              end)
            elseif tg:iselite() then
              local txsh = 0.25 * tg:getmaxhp()
              DamageUnit({
                bj = "茸茸甲虫附伤",
                unit = tg.handle,
                source = u.handle,
                damage = txsh,
                level = 5,
                type = "魔力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "暗",
                extradata = {""}
              })
            else
              LossHpUnit({
                u = u,
                tg = tg,
                damage = 0,
                perhp = 1,
                maxhp = 0,
                bj = "[生命损耗]茸茸甲虫附伤"
              })
            end
          end
          if zs == 3 then
            tg:eliteschange(-1)
          end
          if zs == 4 and 5 > tg:getdata("茸茸-毒蝎子层数") then
            tg:changedata("茸茸-毒蝎子层数", 1)
            tg:changedata("怪物-额外受伤", 0.05)
            tg:buffset(u.handle, tg:getdata("茸茸-毒蝎子层数"), "僵直")
          end
        end
      end)
      u:uivar_change({
        keyname = "流氓巨星",
        keytype = "传奇栏",
        text = "|cFFFFFF00黄金体验|r\n|cFFFF0000速度A\n成长A\n破坏力C\n持久力D\n射程C\n精密度C|r\n|cFFFFFF00「生命赋予」|r\n|cFFFF0000[数据删除]|r\n|cFF949596这个世界的「真实」|r",
        icon = "war3mapImported\\BTNEwl_Qiaolunuo2.blp"
      })
    end
  end,
  ["朱雀院椿"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-朱雀院椿"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      u:setplayername("|cFF7DBEF1[|r|cFFFFCCFF朱雀院つばき|r|cFF7DBEF1]|r" .. NameID[sy])
      PlayGlobalSound(Sound_Chun_03)
      SendJbMsgAll({
        strstart = "|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『",
        strz = "那一天，",
        strend = "』|r",
        time = 0.7,
        shunxu = 1,
        waittime = 0
      })
      SendJbMsgAll({
        strstart = "|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『那一天，",
        strz = "被朱雀院之名所束缚的我已经死了",
        strend = "』|r",
        time = 2.7,
        shunxu = 1,
        waittime = 1.4
      })
      SendJbMsgAll({
        strstart = "|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『",
        strz = "所以现在，",
        strend = "』|r",
        time = 0.7,
        shunxu = 1,
        waittime = 4.8,
        origintext = "|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『那一天，被朱雀院之名所束缚的我已经死了』|r"
      })
      SendJbMsgAll({
        strstart = "|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『所以现在，",
        strz = "我要作为只为自己而战的剑士复活",
        strend = "』|r",
        time = 4.2,
        shunxu = 1,
        waittime = 6.3,
        origintext = "|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『那一天，被朱雀院之名所束缚的我已经死了』|r"
      })
      u:adddivinity(1)
      PlayBGM({
        bgm = BGM_Chun_04,
        time = 240,
        ID = 100,
        unit = u.handle
      })
      ChangeValue(DamageSystem_Baoji, sy, 10)
      ChangeValue(DamageSystem_Baoshang, sy, 0.1)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.9, 1)
      u:changedata("闪避值", 35)
      u:addskill("A1E7")
      u:addskill("A1E5")
      u:setskillforever("A1E6")
      u:banskill("A1E5")
      
      local function skill(args)
        if args.skill == S2ID("A1E6") then
          if u:hasdata("椿-里幻剑惩罚") then
            u:sendmessage("|cFF7DBEF1无法释放|r")
            u:setskillcd("A1E5", 1)
            return
          end
          local x, y = u:getxy()
          if not u:hasdata("椿-里炎姬") then
            local bhtime = 1.4
            local dt = 0
            if not u:hasdata("椿-第一次里炎姬") then
              bhtime = 24.4
              dt = 23.5
              u:setdata("椿-第一次里炎姬")
              u:playsound(bac305)
              PlayGlobalSound(Sound_Chun_30)
              SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFFCCFF『所谓招式，就是反复练习千次万次，让身体记住。』|r")
              SendDtimeMsgAll(7.5, "|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFFA3CC『所以为了学会炎姬我废寝忘食的练习』|r")
              SendDtimeMsgAll(13.9, "|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF7A99『不过,多亏了你我才能打破炎姬原本的招式！』|r")
              SendDtimeMsgAll(20, "|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『|r|cFFFF0000里|r|cFFFF2640炎|r|cFFFF4C80姬|r|cFFFF6699』|r")
              SendDtimeMsgAll(21.6, "|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF5266『这就是努力的结果』|r")
              ac.wait(20000, function()
                Effectcreate("ATX\\[ATxNew]Fire_12.mdl", x, y)
                flashphoto({
                  photo = "war3mapImported\\Chun_Lyj_01.tga",
                  timeout = 0.5,
                  timehold = 2,
                  timein = 2
                })
              end)
            end
            modelchange({
              unit = u.handle,
              model = "Hero\\Hero_Chun.mdl",
              modelsize = 1.03,
              modelact = 8,
              modelactspeed = 1,
              time = bhtime,
              sfunc = function(mj)
                mj:effectadd("0Tx\\0Tx_Chun (14).mdl", "origin", 1.39)
                Effectcreate("war3mapImported\\blackblink.mdx", x, y)
              end,
              efunc = function(mj)
                local x, y = mj:getxy()
                Effectcreate("war3mapImported\\blackblink.mdx", x, y)
              end
            })
            u:setdata("椿-里炎姬")
            u:buffset(u.handle, bhtime, "暂停")
            u:buffset(u.handle, bhtime + 1, "无敌")
            u:buffset(u.handle, bhtime + 1, "绝对闪避")
            ac.wait(dt * 1000, function()
              u:playsound(bac305)
              ac.wait(400, function()
                u:playsound(Sound_Chun_04)
                u:chat("|cFFFF0066里|r|cFFFF1485炎|r|cFFFF29A3姬|r|cFFFF3DC2！|r")
                Effectcreate("ATX\\[ATxNew]Fire_12.mdl", x, y)
              end)
              ac.wait(1400, function()
                u:playsound(bac315)
                Effectcreate("ATX\\[ATxNew]Fire_14.mdl", x, y)
                ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 150)
                ChangeValue(DamageSystem_Shjc, sy, 0.15)
                local tx = u:effectadd("0Tx\\0Tx_Chun (15).mdl", "origin", -1)
                local cs = 0
                local hs = 0
                local zs = 0
                ac.loop(100, function(timer)
                  ChangeValue(DamageSystem_EndSh, sy, 0.1 * -zs)
                  ChangeValue(Damage_Element_Fire, sy, -hs)
                  hs = 0.03 * u:getstate("炎变异")
                  zs = 0.1 + 0.005 * u:getdata("白毛变异数量")
                  ChangeValue(Damage_Element_Fire, sy, hs)
                  ChangeValue(DamageSystem_EndSh, sy, 0.1 * zs)
                  cs = cs + 1
                  if 3 <= cs then
                    cs = 0
                    if not u:hasdata("朱雀院椿-BOSS战") then
                      u:losshp(u, 0, 0, 0.5)
                    end
                    local ng = CreateGroupLua()
                    local x, y = u:getxy()
                    for _, xq in ac.selector():in_rangexy(x, y, 600):is_enemy(u.handle):ipairs() do
                      xq = getunit(xq)
                      xq:groupadd(ng)
                    end
                    local txsh = 200 * (u:getallattri() + u:getlevel())
                    if 0 < Group_Counts(ng) then
                      local mb = Group_Randomunit(ng)
                      mb:playsound(bac80)
                      mb:effectadd("AATX\\[AATxNew]Fire26.mdl", "chest")
                      DamageUnit({
                        bj = "椿-里炎姬",
                        unit = mb.handle,
                        source = u.handle,
                        damage = txsh,
                        level = 1,
                        type = "灵力",
                        isvest = true,
                        isattack = false,
                        isnoarmor = false,
                        element = "火",
                        extradata = {
                          "系统-本次伤害无视伤害免疫"
                        }
                      })
                    end
                  end
                  if not u:isalive() or not u:hasdata("椿-里炎姬") then
                    u:deldata("椿-里炎姬")
                    DestroyEffectLua(tx)
                    ChangeValue(DamageSystem_EndSh, sy, 0.1 * -zs)
                    ChangeValue(Damage_Element_Fire, sy, -hs)
                    ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -150)
                    ChangeValue(DamageSystem_Shjc, sy, -0.15)
                    timer:remove()
                  end
                end)
              end)
            end)
          else
            u:deldata("椿-里炎姬")
          end
        end
      end
      
      u:addtrgevent("单位-发动技能", function(args)
        skill(args)
      end)
      
      local function skill2(args)
        if args.chat == "里幻剑" then
          if u:getdata("椿-里炎姬杀敌") >= 150 then
            local b = true
            if not u:isalive() then
              b = false
              u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
            end
            if not u:ishasitem("I0BI") then
              b = false
              u:sendmessage("|cFF7DBEF1未拥有无铭|r")
            end
            if b then
              NameID[sy] = "|cFFFF6699朱|r|cFFF85783雀|r|cFFF0496D院|r|cFFE93A57つ|r|cFFE22C42ば|r|cFFDB1D2Cき|r"
              local wp = u:getitem("I0BI")
              PlayGlobalSound(Sound_Chun_24)
              SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『不管对手是谁，赢得一定是我！』|r")
              ac.wait(5300, function()
                SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『撒，尽管放马过来。』|r")
              end)
              ac.wait(10900, function()
                SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『我会将你折磨致死。』|r")
              end)
              ac.wait(11500, function()
                flashphoto({
                  photo = "war3mapImported\\Photo_Chun_01.tga",
                  timeout = 0.5,
                  timehold = 3,
                  timein = 1
                })
              end)
              local x, y = u:getxy()
              u:setdata("椿-里幻剑状态")
              u:setdata("椿-里幻剑复活限制", 5)
              DelayHandleRefLua(wp, 300000, function()
                StopSoundBJ(BGM_Chun_02, false)
                if u:isingroup(Group_PlayHero) then
                  RemoveItemLua(wp)
                  u:additem("I0BW")
                  u:setdata("椿-里幻剑惩罚")
                  u:deldata("椿-里炎姬")
                  u:sendmessage("|cFFFF6699无铭破碎了|r")
                  PlayGlobalSound(Sound_Chun_33)
                  ac.wait(100, function()
                    SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『我身为剑士的灵魂与刀一起被斩断了』|r")
                  end)
                  ac.wait(5900, function()
                    SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『被斩断翅膀坠落在地上的鸟』|r")
                  end)
                  ac.wait(8000, function()
                    SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『连丑陋的苟活下去也做不到』|r")
                    flashphoto({
                      photo = "war3mapImported\\Chun_Sd.tga",
                      timeout = 3,
                      timehold = 3,
                      timein = 2
                    })
                  end)
                  ac.wait(11200, function()
                    SendMsgAll("|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿：|r|cFFFF6699『只是等待着死亡』|r")
                  end)
                end
              end)
              PlayBGM({
                bgm = BGM_Chun_02,
                time = 300,
                ID = 109,
                unit = u.handle
              })
            end
          else
            u:sendmessage("|cFFCC0000里炎姬杀敌不足|r")
          end
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        skill2(args)
      end)
      u:uivar_change({
        keyname = "刀仕禰宜",
        keytype = "传奇栏",
        text = "|cFFFFCCFF朱|r|cFFFFA3CC雀|r|cFFFF7A99院|r|cFFFF5266椿|r\n|cFFFF5266神性 1\n刀仕襧宜|r\n|cFFFFCCFF[数据删除]|r\n|cFFFF5266心眼(真)|r\n|cFFFFCCFF[数据删除]|r\n|cFFFF5266二刀流|r\n|cFFFFCCFF[数据删除]|r\n|cFFFF5266炎姬|r\n|cFFFFCCFF[数据删除]|r\n|cFFFF5266里炎姬|r\n|cFFFFCCFF[数据删除]|r",
        icon = "war3mapImported\\BTNEwl_Chun_04"
      })
    end
  end,
  ["星神之嗣"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-星神之嗣"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      u:setplayername("|cFF7DBEF1[|r|cFF990036星|r|cFFA60437神|r|cFFB40838之|r|cFFC10C3A嗣|r|cFF7DBEF1]|r" .. NameID[sy])
      SendMsgAll("|cFF990000星神の嗣はあなたの宿願を実現したいです——|r")
      u:adddivinity(1)
      u:getgoddessforce(1, true)
      u:changedata("幸运", 2)
      u:changedata("根源变异数量", 1)
      u:changedata("光明变异数量", 1)
      u:addskill("S07R")
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 24)
      ChangeValue(Correction_Jzsh, sy, 0.036)
      ChangeValue(Correction_Gun, sy, 0.036)
      ChangeValue(Correction_JzFw, sy, 0.24)
      ChangeValue(DamageSystem_Baoji, sy, 6)
      ChangeValue(DamageSystem_Baoshang, sy, 0.09)
      ChangeValue(HeroMenu_Sbxs, sy, 0.06)
      local cs = 0
      local qsxa = 0
      local sbz = 0
      ac.loop(3000, function(timer)
        if u:isalive() then
          cs = cs + 1
          if cs == 20 then
            cs = 0
            u:setdata("星之泪-护盾值", 0.3 * u:getmaxhp())
            Hdzflash(u)
          end
        end
        u:changedata("全属性增幅", -qsxa)
        u:changedata("闪避值", -sbz)
        qsxa = 0.05 + 0.00125 * u:getlevel()
        sbz = 10 + 0.5 * u:getlevel()
        u:changedata("全属性增幅", qsxa)
        u:changedata("闪避值", sbz)
      end)
      u:setdata("星神之怒释放次数", 0)
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(str .. "-特效冷却") then
          u:settimedata(str .. "-特效冷却", 0.5)
          local txsh = 24 * u:getallattri()
          tg:effectadd("war3mapImported\\[Xszs]t3_effect_azes114.mdx", "chest")
          DamageUnit({
            bj = "星神之嗣附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 5,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
        end
        if u:getdata("星神之怒释放次数") >= 1 and not u:hasdata(str .. "-特效2冷却") and u:getluckrandom(3 * info.txgl) then
          u:settimedata(str .. "-特效2冷却", 1)
          local dx, dy = tg:getxy()
          local txsh = 240 * u:getallattri()
          u:curetili(3)
          ChangeTimeValue(DamageSystem_Shjc, sy, 0.012, 7)
          ChangeTimeValue(DamageSystem_Shjc, sy, 0.012, 7)
          ChangeTimeValue(DamageSystem_Shjc, sy, 0.012, 7)
          Effectcreate("war3mapImported\\[Xszs]Flamestrike Mystic II.mdx", dx, dy)
          DamageUnit({
            bj = "星神之怒附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 5,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
        end
        if u:getdata("星神之怒释放次数") >= 2 then
          if not tg:hasdata("星神之怒破甲") and tg:getarmor() > 0 then
            local hj = 0.5 * tg:getarmor()
            tg:setdata("星神之怒破甲")
            tg:changearmor(-1 * hj)
          end
          if not u:hasdata(str .. "-特效3冷却") then
            local gl = 1
            if u:hasdata("隐藏职业-天谴之子") then
              gl = gl * 2
            end
            if u:getluckrandom(gl * info.txgl) then
              u:settimedata(str .. "-特效3冷却", 1)
              local dx, dy = tg:getxy()
              local txz = {
                "war3mapImported\\[Xszs]Swordlight_Black.mdl",
                "war3mapImported\\[Xszs]Swordlight_Blue.mdl",
                "war3mapImported\\[Xszs]Swordlight_Green.mdl",
                "war3mapImported\\[Xszs]Swordlight_Orange.mdl",
                "war3mapImported\\[Xszs]Swordlight_Pink.mdl",
                "war3mapImported\\[Xszs]Swordlight_Purple.mdl"
              }
              Effectcreate(txz[GetRandomInt(1, 6)], dx, dy, 1, 1.5)
              if tg:isnormal() then
                tg:kill(u.handle)
              else
                local txsh = 0.01 * tg:gethp()
                DamageUnit({
                  bj = "星神之怒附伤",
                  unit = tg.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 5,
                  type = "魔力",
                  isvest = true,
                  isattack = false,
                  isnoarmor = false,
                  element = "无"
                })
              end
            end
          end
        end
      end)
      local dskill = S2ID("A04T")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local x, y = u:getxy()
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if u:hasdata("星神之怒") then
            b = false
            u:sendmessage("|cFF7DBEF1已发动|r")
          end
          if b then
            local b2 = true
            u:changedata("星神之怒释放次数", 1)
            u:playsound(bac213)
            Effectcreate("effect\\Tx001\\Xszs_Tx (2).mdl", x, y, 0, 3)
            if u:getdata("星神之怒释放次数") == 2 then
              u:uivar_add({
                keyname = "星虹之瞳",
                keytype = "传奇栏",
                text = "|cFFFF0066星|r|cFFFF1452虹|r|cFFFF293Dの|r|cFFFF3D29瞳|r",
                icon = "war3mapImported\\PASBTNXszs_06"
              })
              if u:hasdata("力量系职业") then
                u:changedata("力量增幅", 0.06)
              end
              if u:hasdata("敏捷系职业") then
                u:changedata("敏捷增幅", 0.06)
              end
              if u:hasdata("智力系职业") then
                u:changedata("智力增幅", 0.06)
              end
            end
            if 3 <= u:getdata("星神之怒释放次数") and u:ishasshw() and BossBattle and 1 >= Group_Counts(Group_Xingcunzu) and not u:hasdata("禁忌化-星神の辉光") and not u:hasdata("星神之怒特化") and u:ishasitem("I036") then
              ac.wait(2000, function()
                u:playsound(bac163)
                EffectcreateArgs({
                  effect = "effect\\Tx001\\Xszs_Tx (1).mdl",
                  x = x,
                  y = y,
                  time = 2,
                  size = 3,
                  height = 500
                })
                EffectcreateArgs({
                  effect = "effect\\Tx001\\Xszs_Tx (1).mdl",
                  x = x,
                  y = y,
                  time = 2,
                  size = 3
                })
                EffectcreateArgs({
                  effect = "effect\\Tx001\\Xszs_Tx (3).mdl",
                  x = x,
                  y = y,
                  time = 2,
                  size = 3
                })
                ac.wait(1000, function()
                  u:playsound(bac215)
                  EffectcreateArgs({
                    effect = "effect\\Tx001\\Xszs_Tx (4).mdl",
                    x = x,
                    y = y
                  })
                  u:setdata("星神之怒特效", u:effectadd("effect\\Tx001\\Xszs_Tx (5).mdl", "origin", -1))
                end)
              end)
              u:setdata("星神之怒")
              u:setdata("星神之怒特化")
              b2 = false
              u:effectadd("tx_x573.mdx", "origin", -1)
              ChangeItemCount(u:getitem("I036"), -1)
              ChangeValue(DamageSystem_Shjc, sy, 0.12)
              AdvanceGet["星神之嗣禁忌"](u)
              local tx = u:effectadd("war3mapImported\\[Xszs]134.mdx", "origin", -1)
              local g = CreateGroupLua()
              ac.loop(500, function(timer)
                local dx, dy = u:getxy()
                for _, xq in ac.selector():in_rangexy(dx, dy, 1200):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  if xq:isnormal() then
                    xq:losshp(u, 0, 0, 12)
                  else
                    xq:setdata("星神之怒-抑制回血")
                    xq:groupadd(HpGroup)
                    xq:groupadd(g)
                  end
                end
                if not u:hasdata("星神之怒特化") then
                  DestroyEffectLua(tx)
                  u:deldata("星神之怒")
                  ForGroupLuaNew(g, function(xq)
                    xq:deldata("星神之怒-抑制回血")
                  end)
                  ChangeValue(DamageSystem_Shjc, sy, -0.12)
                  timer:remove()
                end
              end)
              ac.wait(255000, function()
                if u:hasdata("星神之怒特化") then
                  u:shanmo(70)
                  u:effectadd("war3mapImported\\[ake]war3ake.com - 7346841038772226188179609.mdx", "origin", -1)
                  ForGroupLuaNew(Group_PlayHero, function(xq)
                    if xq.handle ~= u.handle then
                      u:sendmessage("|cFF0000FF你|r|cFF1200F0的|r|cFF2400E2眼|r|cFF3700D3睛|r|cFF4900C5变|r|cFF5B00B6得|r|cFF6D00A8如|r|cFF800099同|r|cFF92008A水|r|cFFA4007C晶|r|cFFB6006D般|r|cFFC8005F透|r|cFFDB0050彻|r")
                      u:adddivinity(1)
                      u:changedata("幸运", 2)
                      u:getgoddessforce(1)
                      ChangeValue(HeroMenu_HpChange_MaxHp, sy, 0.6)
                      ac.loop(6000, function()
                        u:changemaxhp(1)
                      end)
                      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 24)
                      u:addskill("S04B")
                      ChangeValue(DamageSystem_Shjc, sy, 0.006)
                      ChangeValue(DamageSystem_Shjc, sy, 0.006)
                      ChangeValue(DamageSystem_Shjc, sy, 0.006)
                      ChangeValue(DamageSystem_Ssjianshao, sy, 0.94, 1)
                      ChangeValue(DamageSystem_Baoji, sy, 12)
                      ChangeValue(DamageSystem_Baoshang, sy, 0.12)
                      ChangeValue(KillReward_MHp, sy, 1)
                      u:uivar_add({
                        keyname = "星虹之眸",
                        keytype = "传奇栏",
                        text = "|cFFFF0066星虹之眸|r\n|cFFCC0033【彤の璎】|r\n|cFFFF0066[数据删除]|r\n|cFF0000FF【岚の溟】|r\n|cFFFF0066[数据删除]|r",
                        icon = "war3mapImported\\PASBTNXszs_05"
                      })
                    end
                  end)
                end
              end)
            end
            if b2 then
              local t = 9
              if u:hasdata("禁忌化-星神の辉光") then
                t = 18
              end
              local cs = 0
              local max = t / 0.5
              local g = CreateGroupLua()
              ac.loop(500, function(timer)
                cs = cs + 1
                local x, y = u:getxy()
                for _, xq in ac.selector():in_rangexy(x, y, 1500):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  if xq:isnormal() then
                    xq:losshp(u, 0, 0, 12)
                  else
                    xq:setdata("星神之怒-抑制回血")
                    xq:groupadd(g)
                    xq:groupadd(HpGroup)
                  end
                end
                if cs >= max then
                  ForGroupLuaNew(g, function(xq)
                    xq:deldata("星神之怒-抑制回血")
                  end)
                  timer:remove()
                end
              end)
              u:settimedata("星神之怒", t)
              u:effectadd("war3mapImported\\[Xszs]134.mdx", "origin", t)
              ChangeTimeValue(DamageSystem_Shjc, sy, 0.12, t)
              ChangeTimeValue(DamageSystem_Shjc, sy, 0.08, t)
            end
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      u:uivar_change({
        keyname = "星虹之眸",
        keytype = "传奇栏",
        text = "|cFF990036星|r|cFFA60437神|r|cFFB40838之|r|cFFC10C3A嗣|r\n|cFFCC0033私は星神の後継者であり，あなたの悲願を叶える者だ——|r",
        icon = "war3mapImported\\PASBTNXszs_03"
      })
    end
  end,
  ["吉普利露"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-吉普利露"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      NameID[sy] = "|cFFFF99FFジ|r|cFFF680EEブ|r|cFFEE66DDリ|r|cFFE64CCCー|r|cFFDD33BBル|r"
      u:setplayername(NameID[sy])
      SendMsgAll("|cFFCC00FF「|r|cFFD000F4请|r|cFFD300E9你|r|cFFD700DE们|r|cFFDB00D3以|r|cFFDE00C8无|r|cFFE200BD能|r|cFFE500B3的|r|cFFE900A8人|r|cFFED009D类|r|cFFF00092之|r|cFFF40087身|r|cFFF8007C」|r")
      PlayGlobalSound(Sound_Jpll_003)
      ac.wait(2000, function()
        SendMsgAll("|cFFCC00FF「|r|cFFCF00F5在|r|cFFD200EC『不|r|cFFD600E2会|r|cFFD900D9死|r|cFFDC00CF亡|r|cFFDF00C6的|r|cFFE200BC范|r|cFFE600B2围|r|cFFE900A9内』|r|cFFEC009F取|r|cFFEF0096悦|r|cFFF2008C我|r|cFFF50083吧|r|cFFF90079」|r")
      end)
      ChangeValue(DamageSystem_Baoji, sy, 15)
      u:adddivinity(2)
      u:addskill("S07B")
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 10 + 0.2 * u:getlevel())
      local zq = 0
      local gs = 0
      ac.loop(3000, function()
        ChangeValue(HeroMenu_MpCure_Add, sy, -zq)
        zq = 0
        if u:getpermp() <= 80 then
          zq = 0.2
        end
        if u:getpermp() <= 60 then
          zq = 0.4
        end
        if u:getpermp() <= 40 then
          zq = 0.6
        end
        ChangeValue(HeroMenu_MpCure_Add, sy, zq)
        u:setdata("吉普利露-回廊计数", math.floor(u:getmaxmp() / 20))
        u:changedata("固定伤害", 0.1 * -gs)
        gs = 1000 * (Correction_Magic[sy] - 1)
        u:changedata("固定伤害", 0.1 * gs)
      end)
      local dskill = S2ID("A1D4")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local jd = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          local ewl = getunit(args.unit)
          if 4000 <= dis then
            b = false
            u:sendmessage("|cFF7DBEF1距离超过4000|r")
          end
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            local mj = u:createunit("u0CA", x, y, jd)
            Effectcreate("0Tx\\0Tx_Jpll_07.mdl", x, y, 0, 2)
            u:buffset(u.handle, 6, "无敌")
            u:buffset(u.handle, 6, "绝对闪避")
            u:buffset(u.handle, 5, "暂停")
            ShowUnit(u.handle, false)
            ac.wait(1, function()
              mj:animeact("spell")
            end)
            if u:hasdata("吉普利露-禁忌化") and not u:hasdata("神击冷却") and BossBattle and 1 >= Group_Counts(Group_Xingcunzu) then
              PlayGlobalSound(Sound_Jpll_102)
              u:buffset(u.handle, 18, "无敌")
              u:buffset(u.handle, 18, "绝对闪避")
              u:buffset(u.handle, 17, "暂停")
              local txsh = 77777
              local txsh2 = 59999 * u:getlevel() ^ 0.5
              local add = u:getlevel() / 10
              u:adddivinity(add)
              ac.timer(1000, 30, function()
                for _, xq in ac.selector():in_rangexy(x2, y2, 3000):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  xq:buffset(u.handle, 1.05, "僵直")
                  xq:buffset(u.handle, 1.05, "锁定")
                end
              end)
              SendDtimeMsgAll(0.9, "|cFFCC00FF『|r|cFFD300DB是|r|cFFDB00B6这|r|cFFE20092样|r|cFFE9006D啊|r|cFFF00049』|r")
              SendDtimeMsgAll(3.1, "|cFFCC00FF『|r|cFFD100E8抱|r|cFFD500D1歉|r|cFFDA00B9称|r|cFFDF00A2呼|r|cFFE3008B你|r|cFFE80074为|r|cFFEC005D废|r|cFFF10046物|r|cFFF6002E』|r")
              SendDtimeMsgAll(5.9, "|cFFCC00FF『|r|cFFD400D4我|r|cFFDD00AA收|r|cFFE60080回|r|cFFEE0055』|r")
              SendDtimeMsgAll(8, "|cFFCC00FF『|r|cFFCF00EE判|r|cFFD300DD断|r|cFFD600CC你|r|cFFDA00BB为|r|cFFDD00AA必|r|cFFE00099须|r|cFFE40088排|r|cFFE70077除|r|cFFEB0066掉|r|cFFEE0055的|r|cFFF10044威|r|cFFF50033胁|r|cFFF80022』|r")
              SendDtimeMsgAll(12, "|cFFCC00FF『|r|cFFD000EB是|r|cFFD400D8值|r|cFFD800C4得|r|cFFDC00B1全|r|cFFE0009D力|r|cFFE40089以|r|cFFE70076赴|r|cFFEB0062的|r|cFFEF004E敌|r|cFFF3003B人|r|cFFF70027』|r")
              SendDtimeMsgAll(15.3, "|cFFCC00FF『|r|cFFD600CC神|r|cFFE00099击|r|cFFEB0066』|r")
              local mjd = u:createunit("u0CZ", x, y)
              mjd:timetoremove(16.5)
              local dx = 0
              local cs = 0
              local jl = 1500
              local a = GetRandomAngle()
              ac.timer(100, 150, function()
                cs = cs + 1
                dx = dx + 0.1
                mjd:setsize(dx)
                a = a + 20
                for i = 1, 3 do
                  a = a + 120
                  local x3, y3 = PolarXY(x2, y2, jl, a)
                  Effectcreate("effect\\622_2113 (4).mdl", x3, y3, 0, 5)
                end
                local x3, y3 = PolarXY(x2, y2, GetRandomReal(0, 2500), GetRandomAngle())
                Effectcreate("effect\\622_2113 (5).mdl", x3, y3, 0, 3)
                Effectcreate("effect\\622_2113 (1).mdl", x3, y3, 0)
                for _, xq in ac.selector():in_rangexy(x3, y3, 500):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  DamageUnit({
                    bj = "吉普利露神击",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh2,
                    level = 5,
                    type = "魔力",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {""}
                  })
                end
              end)
              ac.wait(16000, function()
                Effectcreate("effect\\622_2113 (2).mdl", x2, y2, 0, 10, 0, 0, 0, 0, 0.5)
              end)
              ac.wait(16500.0, function()
                local da = GetRandomAngle()
                for i = 1, 6 do
                  da = da + 60
                  local x3, y3 = PolarXY(x2, y2, 500, da)
                  Effectcreate("effect\\622_2113 (6).mdl", x3, y3, 0, 5)
                end
                PlayGlobalSound(bac439)
                local vest = getunit(System_SkillVest)
                vest:addskill("A1FY")
                for _, xq in ac.selector():in_rangexy(x2, y2, 2500):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  LossHpUnit({
                    u = u,
                    tg = xq,
                    damage = 0,
                    perhp = 30,
                    maxhp = 0,
                    bj = "[生命损耗]神击"
                  })
                  xq:setdata("神击破坏")
                  xq:groupadd(HpGroup)
                  IssueTargetOrder(vest.handle, "soulburn", xq.handle)
                  DamageUnit({
                    bj = "吉普利露神击",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 5,
                    type = "魔力",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {""}
                  })
                end
                vest:delskill("A1FY")
              end)
              ac.wait(17000, function()
                u:adddivinity(-add)
                Effectcreate("0Tx\\0Tx_Jpll_07.mdl", x, y, 0, 2)
                mj:remove()
                ShowUnit(u.handle, true)
                u:select()
              end)
              u:setdata("神击冷却")
              local dcs = 0
              ac.loop(1000, function(timer)
                dcs = dcs + 1
                if dcs == 1200 or not u:hasdata("神击冷却") then
                  u:deldata("神击冷却")
                  u:sendmessage("神击冷却完毕")
                  timer:remove()
                end
              end)
              return
            end
            PlayGlobalSound(Sound_Jpll_005)
            local txsh = 49999
            local txsh2 = 10000 * u:getlevel() ^ 0.5
            local cs = 0
            local jl = 750
            local a = GetRandomAngle()
            ac.loop(30, function(timer)
              cs = cs + 1
              a = a + 10
              local x3, y3 = PolarXY(x2, y2, jl, a)
              Effectcreate("0Tx\\Tx_Jpll_04.mdl", x3, y3, 0, 3)
              local a2 = a + 180
              x3, y3 = PolarXY(x2, y2, jl, a2)
              Effectcreate("0Tx\\Tx_Jpll_04.mdl", x3, y3, 0, 3)
              Effectcreate("Abilities\\Spells\\Other\\Charm\\CharmTarget.mdl", x, y, 0, 2, 0, GetRandomAngle())
              for _, xq in ac.selector():in_rangexy(x3, y3, 1500):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                DamageUnit({
                  bj = "吉普利露天击",
                  unit = xq.handle,
                  source = u.handle,
                  damage = txsh,
                  level = 5,
                  type = "魔力",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "无",
                  extradata = {""}
                })
              end
              if cs == 36 then
                timer:remove()
              end
            end)
            ac.wait(1000, function()
              local txmj = u:createunit("u0C6", x2, y2, 0)
              txmj:animespeed(0.5)
              txmj:timetoremove(6.5)
              Effectcreate("0Tx\\0Tx_Jpll_12.mdl", x2, y2, 4, 5, 0, 0, 0, 0, 0.18)
            end)
            ac.timer(100, 70, function()
              for _, xq in ac.selector():in_rangexy(x2, y2, 1500):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:buffset(u.handle, 0.2, "暂停")
              end
            end)
            u:settimedata("天击永恒", 5)
            ac.wait(5000, function()
              Effectcreate("0Tx\\0Tx_Jpll_07.mdl", x, y, 0, 2)
              mj:remove()
              ShowUnit(u.handle, true)
              u:select()
              local dcs = 0
              local yx = {
                bac217,
                bac218,
                bac219
              }
              ac.loop(50, function(timer)
                dcs = dcs + 1
                local x3, y3 = PolarXY(x2, y2, GetRandomReal(0, 750), GetRandomAngle())
                Effectcreate("0Tx\\0Tx_Jpll_11.mdl", x3, y3, 0, 3)
                Effectcreate("Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl", x3, y3, 0, 3)
                u:playsound(yx[GetRandomInt(1, 3)])
                for _, xq in ac.selector():in_rangexy(x3, y3, 500):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  DamageUnit({
                    bj = "吉普利露天击",
                    unit = xq.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 5,
                    type = "魔力",
                    isvest = false,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {""}
                  })
                  local dsh = 0
                  if xq:isnormal() then
                    dsh = dsh + 0.05 * xq:getmaxhp()
                  else
                    dsh = dsh + 0.01 * xq:gethp()
                  end
                  DamageUnit({
                    bj = "吉普利露天击",
                    unit = xq.handle,
                    source = u.handle,
                    damage = dsh,
                    level = 5,
                    type = "魔力",
                    isvest = true,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {""}
                  })
                end
                if dcs == 49 then
                  Effectcreate("0Tx\\0Tx_Jpll_07.mdl", x2, y2, 0, 6)
                  for _, xq in ac.selector():in_rangexy(x2, y2, 1500):is_enemy(u.handle):ipairs() do
                    xq = getunit(xq)
                    DamageUnit({
                      bj = "吉普利露天击",
                      unit = xq.handle,
                      source = u.handle,
                      damage = txsh2,
                      level = 5,
                      type = "魔力",
                      isvest = false,
                      isattack = false,
                      isnoarmor = false,
                      element = "无",
                      extradata = {""}
                    })
                  end
                  timer:remove()
                end
              end)
            end)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      u:uivar_change({
        keyname = "天翼种",
        keytype = "传奇栏",
        text = "|cFFCC00FF吉|r|cFFD600E0普|r|cFFE000C2莉|r|cFFEB00A3尔|r\n|cFFEB00A3神性 2\n番外个体-突破|r\n|cFFCC00FF[]|r\n|cFFEB00A3精灵回廊-魔法|r\n|cFFCC00FF[]|r\n|cFFEB00A3弑神兵器|r\n|cFFCC00FF[]|r\n|cFFEB00A3杀戮天使|r\n|cFFCC00FF[]|r\n|cFFEB00A3在251秒内与心擦肩而过，用3205页将心重新书写|r\n|cFFCC00FF[]|r",
        icon = "war3mapImported\\BTNEwl_Jpll_Shenhua",
        isclearclick = true
      })
    end
  end,
  ["神化天子"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-神化天子"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      NameID[sy] = "|cFFFF0000比|r|cFFFF2933那|r|cFFFF5266名居|r|cFFFF7A99地子|r"
      u:setplayername(NameID[sy])
      SendMsgAll("|cFFFF99FF「就凭我的话，也是可以引发异变的！」|r")
      u:playsound(Sound_Tenshi_Get)
      u:adddivinity(2)
      u:getgoddessforce(1)
      flashphoto({
        photo = "war3mapImported\\Tianzi_33.blp",
        timeout = 0.5,
        timehold = 2,
        timein = 2
      })
      u:additem("I04Z")
      u:addskill("S05B")
      PlayBGM({
        bgm = BGM_Tianzi_02_C,
        time = 240,
        ID = 53,
        unit = u.handle
      })
      local hp = 0
      ac.loop(1000, function()
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, -hp)
        hp = 2 * u:getmissperhp() / 100
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, hp)
      end)
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(str .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(str .. "-特效冷却", 0.5)
          local txsh = 5 * u:getmaxhp()
          DamageUnit({
            bj = "神化天子附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "灵力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无",
            extradata = {""}
          })
        end
      end)
      if TID[sy] == "-58375553" or CIUC[sy] == "-403162424" or CIUC[sy] == "1932310753" then
        local function skill(args)
          if args.chat == "我，对无聊的天人生活已经忍无可忍了！就凭我的话，也是可以引发个异变的" and Group_Counts(Group_Xingcunzu) <= 1 and u:isalive() and not u:hasdata("天子-绯想天") and BossBattle then
            MovieAct["绯想天"](u)
          end
        end
        
        u:addtrgevent("玩家-聊天", function(args)
          skill(args)
        end)
      end
      u:uivar_change({
        keyname = "天子",
        keytype = "传奇栏",
        text = "|cFFFF66CC有顶天の大小姐|r\n|cFF3399FF神性 2\n居住在天界|r|cFF4099FF有顶天的天人，|r|cFF4C99FF比那名居一族|r|cFF5999FF的大小姐。|r\n|cFF6699FF能够镇压和|r|cFF7399FF引发地震，|r|cFF8099FF并能操纵要石|r|cFF8C99FF和使用绯想之剑。|r\n|cFF9999FF性格我行我素|r|cFFA699FF，似乎不想|r|cFFB299FF住在天上。|r",
        icon = "war3mapImported\\BTNEwl_Sh_Tz.blp"
      })
    end
  end,
  ["伊蕾娜"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-伊蕾娜"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      NameID[sy] = "|cFF949596灰|r|cFF8F9DA8之|r|cFF8BA5BA魔|r|cFF86AECD女|r"
      u:setplayername(NameID[sy])
      PlayGlobalSound(Sound_Yln_01)
      SendDtimeMsgAll(2.2, "|cFFFF99FF『|r|cFFEC9EFD日|r|cFFDAA4FB记|r|cFFC7A9F9本|r|cFFB5AEF7吗|r|cFFA2B3F5』|r")
      SendDtimeMsgAll(5, "|cFF949596『|r|cFF93979B就|r|cFF9299A0像|r|cFF909BA4妮|r|cFF8F9EA9可|r|cFF8EA0AE那|r|cFF8DA2B3样|r|cFF8CA4B8 |r|cFF8AA6BC你|r|cFF89A8C1也|r|cFF88ABC6写|r|cFF87ADCB下|r|cFF85AFCF旅|r|cFF84B1D4行|r|cFF83B3D9日|r|cFF82B5DE记|r|cFF81B8E3吧|r|cFF7FBAE7』|r")
      SendDtimeMsgAll(8.1, "|cFF949596『|r|cFF93979A等|r|cFF92999F以|r|cFF919BA3后|r|cFF909DA7回|r|cFF8F9FAC来|r|cFF8DA1B0的|r|cFF8CA3B4时|r|cFF8BA5B9候|r|cFF8AA7BD |r|cFF89A9C1给|r|cFF88AAC6我|r|cFF87ACCA们|r|cFF86AECE讲|r|cFF85B0D3讲|r|cFF84B2D7你|r|cFF82B4DB的|r|cFF81B6E0故|r|cFF80B8E4事|r|cFF7FBAE8』|r")
      SendDtimeMsgAll(12.7, "|cFFFF99FF『|r|cFFF19DFD那|r|cFFE2A1FC我|r|cFFD4A5FA就|r|cFFC5A9F9带|r|cFFB7AEF7上|r|cFFA8B2F6吧|r|cFF9AB6F4』|r")
      SendDtimeMsgAll(15.2, "|cFFFF99FF『|r|cFFF79BFE好|r|cFFF09DFD好|r|cFFE8A0FD期|r|cFFE0A2FC待|r|cFFD9A4FB灰|r|cFFD1A6FA之|r|cFFC9A8F9魔|r|cFFC2AAF8女|r|cFFBAADF8的|r|cFFB3AFF7旅|r|cFFABB1F6行|r|cFFA3B3F5故|r|cFF9CB5F4事|r|cFF94B7F3吧|r|cFF8CBAF3』|r")
      SendDtimeMsgAll(20.6, "|cFF949596『|r|cFF8E9FAD嗯|r|cFF88AAC4』|r")
      SendDtimeMsgAll(25.3, "|cFF949596『|r|cFF92999E一|r|cFF909CA7路|r|cFF8EA0AF顺|r|cFF8CA4B7风|r|cFF8AA8BF |r|cFF87ABC8伊|r|cFF85AFD0蕾|r|cFF83B3D8娜|r|cFF81B7E0』|r")
      SendDtimeMsgAll(27.6, "|cFFFF99FF『|r|cFFE99FFD我|r|cFFD4A5FA走|r|cFFBEABF8了|r|cFFA8B2F6』|r")
      SendDtimeMsgAll(30.4, "|cFF99FFFF「|r|cFF9DF2FF就|r|cFFA2E6FF这|r|cFFA6D9FF样|r|cFFAACCFF我|r|cFFAEBFFF踏|r|cFFB2B2FF上|r|cFFB7A6FF了|r|cFFBB99FF旅|r|cFFBF8CFF途|r|cFFC480FF」|r")
      SendDtimeMsgAll(33.2, "|cFF99FFFF「|r|cFF9CF6FF随|r|cFF9FEDFF风|r|cFFA2E4FF而|r|cFFA5DBFF去|r|cFFA8D2FF |r|cFFABC9FF任|r|cFFAEC0FF心|r|cFFB1B7FF而|r|cFFB4AEFF行|r|cFFB7A5FF |r|cFFBA9CFF周|r|cFFBD93FF游|r|cFFC08AFF各|r|cFFC381FF地|r|cFFC678FF」|r")
      SendDtimeMsgAll(37.4, "|cFF99FFFF「|r|cFF9CF6FF体|r|cFF9FEDFF验|r|cFFA2E4FF各|r|cFFA5DBFF种|r|cFFA8D2FF经|r|cFFABC9FF历|r|cFFAEC0FF |r|cFFB1B7FF如|r|cFFB4AEFF今|r|cFFB7A5FF已|r|cFFBA9CFF过|r|cFFBD93FF了|r|cFFC08AFF三|r|cFFC381FF年|r|cFFC678FF」|r")
      SendDtimeMsgAll(42.4, "|cFF99FFFF「|r|cFF9DF4FF嗨|r|cFFA0E9FF~|r|cFFA4DEFF那|r|cFFA8D3FF么|r|cFFABC8FF |r|cFFAFBDFF请|r|cFFB2B3FF回|r|cFFB6A8FF答|r|cFFBA9DFF问|r|cFFBD92FF题|r|cFFC187FF~|r|cFFC57CFF」|r")
      SendDtimeMsgAll(44.9, "|cFF99FFFF「|r|cFF9CF5FF漫|r|cFFA0EBFF步|r|cFFA3E0FF在|r|cFFA7D6FF层|r|cFFAACCFF岩|r|cFFADC2FF峭|r|cFFB1B8FF壁|r|cFFB4ADFF的|r|cFFB8A3FF山|r|cFFBB99FF岳|r|cFFBE8FFF地|r|cFFC285FF带|r|cFFC57AFF」|r")
      SendDtimeMsgAll(47.6, "|cFF99FFFF「|r|cFF9BF8FF有|r|cFF9EF1FF着|r|cFFA0EAFF沉|r|cFFA2E3FF鱼|r|cFFA5DCFF落|r|cFFA7D5FF雁|r|cFFA9CEFF般|r|cFFACC7FF美|r|cFFAEC0FF貌|r|cFFB0B9FF的|r|cFFB2B2FF魔|r|cFFB5ACFF女|r|cFFB7A5FF |r|cFFB99EFF究|r|cFFBC97FF竟|r|cFFBE90FF是|r|cFFC089FF谁|r|cFFC382FF呢|r|cFFC57BFF？|r|cFFC774FF」|r")
      SendDtimeMsgAll(53.6, "|cFF99FFFF「|r|cFF9DF3FF没|r|cFFA1E7FF错|r|cFFA5DCFF |r|cFFA9D0FF就|r|cFFADC4FF是|r|cFFB1B8FF1|r|cFFB4ADFF8|r|cFFB8A1FF岁|r|cFFBC95FF的|r|cFFC089FF我|r|cFFC47EFF」|r")
      ac.wait(1, function()
        songtext({
          text = {
            {
              starttime = 59.8,
              str = "无论是被他人赋以期待"
            },
            {
              starttime = 64,
              str = "亦或是不受理睬"
            },
            {
              starttime = 67,
              str = "哪一种更好呢 其实两方都一样"
            },
            {
              starttime = 71.8,
              str = "内心充盈的喜悦伴随着不安"
            },
            {
              starttime = 75.8,
              str = "即使是我也会拼尽全力成长"
            },
            {
              starttime = 80,
              str = "作为主人公已经习惯了吗"
            },
            {
              starttime = 88,
              str = "雨点从天而降 一点一滴倾注大地"
            },
            {
              starttime = 92.2,
              str = "空灵的世界仿若无人之境"
            },
            {
              starttime = 96.2,
              str = "一边作出好像没有注意到满月的样子"
            },
            {
              starttime = 100.6,
              str = "却满心期待着明天"
            },
            {
              starttime = 104.2,
              str = "仅仅是相信着 就能够实现"
            },
            {
              starttime = 108.9,
              str = "一个人的时候这样得到了勇气"
            },
            {
              starttime = 112.3,
              str = "只要去相信 就能得到拯救"
            },
            {
              starttime = 117,
              str = "一个人像这样仿佛是祈祷一般"
            },
            {
              starttime = 121.8,
              str = "终于 在湛蓝的天空之上"
            },
            {
              starttime = 130,
              str = "漫天繁星绽放了笑容"
            },
            {
              starttime = 136.8,
              str = "宛如曾在书中看到的夜晚"
            },
            {
              starttime = 141,
              str = "雨后的空气拂过面庞"
            },
            {
              starttime = 145,
              str = "黎明到来时 请一定不要忘记"
            },
            {
              starttime = 149.1,
              str = "旅途中所见的那些浪漫"
            },
            {
              starttime = 153.1,
              str = "要去往哪里呢 向着稍远的地方"
            },
            {
              starttime = 157.2,
              str = "那些留存于心的回忆 就让它们全部化作梦境"
            },
            {
              starttime = 161.2,
              str = "正因为喜欢才选择踏上旅途 一边选择着"
            },
            {
              starttime = 165.4,
              str = "成为了独一无二的自己"
            },
            {
              starttime = 169.3,
              str = "一定会再见面的 因为约定好了"
            },
            {
              starttime = 173.9,
              str = "你如此这般露出了微笑"
            },
            {
              starttime = 177.5,
              str = "一定会再见面的 缠绕小指的约定咒语"
            },
            {
              starttime = 181.5,
              str = "即使去相信谁也是可以的吧",
              time = 5
            }
          },
          color = "FFD4A5FA"
        })
      end)
      PlayBGM({
        bgm = 0,
        time = 210,
        ID = 99,
        unit = u.handle
      })
      local bb = getunit(Beibao[sy])
      bb:addskill("A1FU")
      bb:delskill("A1FU")
      u:addskill("A1DG")
      u:addskill("A1DI")
      ChangeValue(DamageSystem_Baoji, sy, 18)
      local ss2 = 0
      local ss3 = 0
      local ss4 = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Baoshang, sy, -ss2)
        ChangeValue(Correction_Magic, sy, -ss3)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -ss4)
        local int = u:getint()
        ss2 = int * 0.001
        ss3 = int * 3.0E-4
        ss4 = u:getdata("元素变异数量") * 0.04
        ChangeValue(DamageSystem_Baoshang, sy, ss2)
        ChangeValue(Correction_Magic, sy, ss3)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * ss4)
      end)
      local dskill = S2ID("A1DF")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local x, y = u:getxy()
          local tg = getunit(args.target)
          local x2, y2 = tg:getxy()
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          local ewl = getunit(args.unit)
          if 1000 <= dis then
            b = false
            u:sendmessage("|cFF7DBEF1距离超过1000|r")
          end
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if not tg:isnormal() then
            b = false
            u:sendmessage("|cFF7DBEF1无效目标|r")
          end
          if b then
            u:playsound(Sound_Yln_03)
            SendMsgAll("|cFFFF9900『|r|cFFFF9E05哇|r|cFFFFA30A~|r|cFFFFA80F好|r|cFFFFAD14厉|r|cFFFFB21A害|r|cFFFFB81F啊|r|cFFFFBD24，|r|cFFFFC229这|r|cFFFFC72E就|r|cFFFFCC33是|r|cFFFFD138有|r|cFFFFD63D钱|r|cFFFFDB42人|r|cFFFFE047吗|r|cFFFFE54C~|r|cFFFFEB52！|r|cFFFFF057！|r|cFFFFF55C』|r", 10)
            local add
            if tg:isingroup(Group_Monster) then
              tg:kill(u.handle, true)
              add = 200 * Stage
            else
              add = 200 + tg:getgold() / 10
              tg:addgold(-add)
            end
            if u:hasdata("伊蕾娜-禁忌化开始") then
              u:changedata("财迷偷钱", add)
            end
            u:addgold(add)
            Effectcreate("Abilities\\Spells\\Other\\Transmute\\PileofGold.mdl", x, y)
            Effectcreate("Abilities\\Spells\\Other\\Transmute\\PileofGold.mdl", x2, y2)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        local dx, dy = tg:getxy()
        local txsh = 5000 + 25 * u:getallattri() * u:getstate("魔导变异")
        if not u:hasdata(str .. "-冰冷却") and u:getluckrandom(4 * info.txgl) then
          u:settimedata(str .. "-冰冷却", 1)
          tg:playsound(FrostBoltHit1)
          Effectcreate("0Tx\\0Tx_Yln (23).mdl", dx, dy, 0, 1.5)
          Effectcreate("0Tx\\0Tx_Yln (14).mdl", dx, dy, 0, 1.5)
          for _, xq in ac.selector():in_rangexy(dx, dy, 250):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "神化伊蕾娜附伤",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "冰"
            })
            local time = 1
            if xq:isboss() then
              time = 0.1
            end
            xq:effectadd("0Tx\\0Tx_Yln (2).mdx", "origin", time)
            xq:buffset(u.handle, time, "冻结")
          end
        end
        if not u:hasdata(str .. "-雷冷却") and u:getluckrandom(4 * info.txgl) then
          u:settimedata(str .. "-雷冷却", 1)
          tg:playsound(Midouzi_2)
          Effectcreate("0Tx\\0Tx_Yln (21).mdl", dx, dy, 0, 1.5)
          Effectcreate("0Tx\\0Tx_Yln (14).mdl", dx, dy, 0, 1.5)
          for _, xq in ac.selector():in_rangexy(dx, dy, 380):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "神化伊蕾娜附伤",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "雷"
            })
            xq:buffset(u.handle, 1.5, "僵直")
          end
        end
        if not u:hasdata(str .. "-火冷却") and u:getluckrandom(4 * info.txgl) then
          u:settimedata(str .. "-火冷却", 1)
          tg:playsound(BuildingDeathLargeHuman)
          Effectcreate("AATX\\[AATxNew]Fire07.mdl", dx, dy)
          Effectcreate("AATX\\[AATxNew]Fire11.mdl", dx, dy)
          Effectcreate("0Tx\\0Tx_Yln (14).mdl", dx, dy, 0, 1.5)
          for _, xq in ac.selector():in_rangexy(dx, dy, 270):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "神化伊蕾娜附伤",
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
          end
        end
      end)
      local cs = 0
      ac.loop(1000, function()
        if u:isalive() then
          cs = cs + 1
          if 30 <= cs and GetRandom100(5) then
            cs = 0
            local yx = {
              Sound_Yln_06,
              Sound_Yln_07,
              Sound_Yln_08
            }
            u:playsound(yx[GetRandomInt(1, 3)])
            ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 200, 9)
          end
        end
      end)
      ModelReplace({
        u = u,
        model = "Hero\\Hero_Elaina.mdx",
        modelsize = 1.2,
        modelname = "|cFFFF99FF伊|r|cFFF2B2FF蕾|r|cFFE6CCFF娜|r",
        modelicon = "Portrait_Yln.tga"
      })
      u:uivar_change({
        keyname = "见习魔女",
        keytype = "传奇栏",
        text = "|cFFFF99FF伊|r|cFFF2B2FF蕾|r|cFFE6CCFF娜|r",
        icon = "war3mapImported\\PASBTNEwl_Yln_Jinji"
      })
    end
  end,
  ["茶会爱丽丝"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-茶会爱丽丝"
    if not u:hasdata(str) then
      u:setdata(str)
      u:sendmessage("|cFFFFCC00「来自异次元的爱丽丝邀请你加入茶会」|r")
      u:changedata("爱丽丝-梦境值", 1)
      u:changedata("童话变异补正", 100)
      NameID[sy] = "|cFFFFFF00爱|r|cFF66CCFF丽|r|cFFCC3366丝|r"
      u:setplayername(NameID[sy])
      PlayBGM({
        bgm = alice_bgm9,
        time = 210,
        ID = 186,
        unit = u.handle
      })
      ModelReplace({
        u = u,
        model = "alice_chahui1.mdx",
        modelsize = 1,
        modelname = "|cFFFFFF00爱|r|cFFFFFFCC丽|r|cFF99FFFF丝|r",
        modelicon = "alice_portrait.tga"
      })
      u:effectadd("shizhongtx1.mdx", "origin", -1)
      local xy = 0
      local hp = 0
      local add = 0
      local xg = 0
      local qsxsh = 0
      local qsxsh2 = 0
      ac.loop(3000, function()
        local time = GetTimeOfDay()
        if 18 <= time and time <= 20 then
          if not u:hasdata("爱丽丝-茶会增强") then
            u:setdata("爱丽丝-茶会增强")
            ChangeValue(Correction_MEDCgl, sy, 0.1)
            u:addskill("S0BS")
          end
        elseif u:hasdata("爱丽丝-茶会增强") then
          u:deldata("爱丽丝-茶会增强")
          ChangeValue(Correction_MEDCgl, sy, -0.1)
          u:delskill("S0BS")
        end
        u:changedata("幸运", -xy)
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, -hp)
        xy = u:getdata("爱丽丝-梦境值") * 0.5
        hp = 0.1 * u:getstate("童话变异")
        u:changedata("幸运", xy)
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, hp)
        u:changedata("童话变异数量", -add)
        add = u:getdata("爱丽丝-梦境值") * 0.5
        u:changedata("童话变异数量", add)
        u:changedata("效果增强-童话", -xg)
        if u:isonlymaxvar("童话") then
          xg = 0.5
        else
          xg = 0
        end
        u:changedata("效果增强-童话", xg)
        ChangeValue(Damage_Element_All, sy, -qsxsh)
        qsxsh = 0.01 * u:getstate("童话变异")
        ChangeValue(Damage_Element_All, sy, qsxsh)
        ChangeValue(Correction_Jzsh, sy, 0.1 * -qsxsh2)
        qsxsh2 = 0.25 * (Correction_Magic[sy] - 1)
        ChangeValue(Correction_Jzsh, sy, 0.1 * qsxsh2)
      end)
      ChangeValue(Hero_Tili_Huifu, sy, 0.15)
      u:addstexiao(str, "杀敌效果", function(args)
        ChangeValue(Correction_Magic, sy, 1.0E-5)
      end)
      local add2 = 0.03 * Time_M
      ChangeValue(DamageSystem_Shjc, sy, 0.1 * add2)
      ChangeValue(Correction_Jzsh, sy, 0.1 * add2)
      ChangeValue(DamageSplit_CountJzMax, sy, add2)
      u:setdata("爱丽丝-属性", "光")
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      u:addstexiao(str, "直接伤害变更", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if info.ismeleedamage and not info.isvestdamage then
          info.damagetype = "魔力"
          info.element = u:getdata("爱丽丝-属性")
        end
      end)
      local nowcount = 1
      u:uivar_add({
        keyname = "茶会爱丽丝",
        keytype = "冥王栏",
        seckey = "梦游仙境",
        text = "|cFFFFCC33爱|r|cFFECD24C丽|r|cFFD9D966丝|r|cFFC6DF80「|r|cFFB2E699茶|r|cFF9FECB2匙|r|cFF8CF2CC」|r\n三阶\n梦境值 1\n|cFF9999FF爱|r|cFFA8A8F8丽|r|cFFB6B6F0丝|r|cFFC5C5E9的|r|cFFD3D3E2旅|r|cFFE2E2DB途|r\n|cFF9999FF[梦游仙境]不再降低以太基础成功率|r\n|cFFA8A8F8提升[梦境值*1]幸运|r\n|cFFB6B6F0提升0.15体力恢复|r\n|cFFC5C5E9提升[童话变异*0.1%]永恒恢复|r\n|cFF9999FF童|r|cFF8F99FF话|r|cFF8599FF王|r|cFF7A99FF国|r\n|cFF9999FF提升100%童话变异补正|r\n|cFF8F99FF童话变异词条数量提升[梦境值/2]|r\n|cFF8599FF唯一主变异为童话时,提升50%童话变异效果|r\n|cFFFF9900爱|r|cFFFFA81D丽|r|cFFFFB63A丝|r|cFFFFC557的|r|cFFFFD375茶|r|cFFFFE292匙|r\n|cFFFF9900杀敌时提升0.01%法术修正|r\n|cFFFFA81D近战伤害享受25%法术修正|r\n|cFFFFB63A提升[1%*童话变异]全属性伤害|r\n|cFFFFC557近战直接伤害变为指定属性魔力伤害|r\n|cFFFFD375近战上限段数+1|r\n|cFFFFE292获取时提升[逝去分钟数*0.3%]伤害加成,近战伤害与近战多段伤害上限|r\n|cFF66FFFF爱|r|cFF7CFFF8丽|r|cFF92FFF0丝|r|cFFA8FFE9的|r|cFFBDFFE2茶|r|cFFD3FFDB会|r\n|cFF66FFFF18:00到20:00时:|r\n|cFF7CFFF8【爱丽丝服用任意药水时3000范围内友军视为使用相同药水|r\n|cFF92FFF0提升爱丽丝30%药水成功率|r\n|cFFA8FFE9周围2000范围友军提升20%药水成功率|r\n|cFFBDFFE2必定触发[永不终焉的茶会]】|r",
        icon = "NewIcon_Alice.tga",
        cd = 3,
        ishasphoto = true,
        clickfunc = function(u, button)
          local sxz = {
            "光",
            "暗",
            "火",
            "雷",
            "冰"
          }
          nowcount = nowcount + 1
          if 5 < nowcount then
            nowcount = 1
          end
          u:setdata("爱丽丝-属性", sxz[nowcount])
          u:sendmessage("|cFFFFFF66爱丽丝-当前属性:" .. sxz[nowcount])
        end
      })
    end
  end,
  ["罗丽娜"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-罗丽娜"
    if not u:hasdata(str) then
      u:setdata(str)
      u:changedata("传奇数量", 1)
      u:sendmessage("|cFFFF4B4B「爱丽丝!死刑!」|r")
      Fskillreplace({
        unit = u.handle,
        level = 2,
        skill_F = "A0FV",
        skill_X = "A0FZ",
        isforce = false,
        efunc = function()
          local function skill(args)
            if args.skill == S2ID("A0FV") or args.skill == S2ID("A0FZ") then
              u:playsound(hongxin8)
              
              u:settimedata("红城的律令-格挡效果", 0.5)
              u:effectadd("Abilities\\Spells\\Human\\ControlMagic\\ControlMagicTarget.mdl", "overhead", 0.5)
            end
          end
          
          u:addtrgevent("单位-发动技能", function(args)
            skill(args)
          end)
        end
      })
      u:additem("I0KF")
      u:changedata("爱丽丝-梦境值", 1)
      PlayBGM({
        bgm = alice_bgm4,
        time = 120,
        ID = 188,
        unit = u.handle
      })
      u:addstexiao(str, "杀敌效果", function(args)
        local add = 0.25 * u:getstate("童话变异")
        u:changedata("魔力值", add)
      end)
      u:addstexiao(str, "近战伤害效果", function(args)
        local tg = args.tg
        ac.wait(10, function()
          if not tg:isalive() then
            ChangeValue(Correction_Jzsh, sy, 1.0E-4)
          end
        end)
      end)
      ChangeValue(DamageSplit_CountJzHit, sy, 1)
      local jz = 0
      local max = 0
      ac.loop(3000, function(timer)
        ChangeValue(Correction_Jzsh, sy, 0.1 * -jz)
        ChangeValue(DamageSplit_CountJzMax, sy, -max)
        max = 0.33 * u:getdata("遗物-陈旧断头台数量")
        jz = 0.33 * u:getdata("遗物-刽子手之妻数量")
        ChangeValue(Correction_Jzsh, sy, 0.1 * jz)
        ChangeValue(DamageSplit_CountJzMax, sy, max)
      end)
      u:uivar_change({
        keyname = "红心女王",
        keytype = "冥王栏",
        text = "|cFFFF4B4B罗丽娜\n三阶\n童话 黑暗 唯一\n杀敌时提升[童话变异*0.25]魔力值\n增加[刽子手之妻遗物数量*3.3%]近战伤害\n增加[陈旧断头台遗物数量*33%]近战伤害上限\n近战伤害段数+1\n近战伤害杀敌时提升0.01%近战伤害\n提高[3000+100*等级]近战基础伤害与角色基础伤害|r",
        icon = "NewIcon_Luolina.tga",
        isclearclick = true,
        ishasphoto = true
      })
    end
  end,
  ["神代の御神子"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-神代の御神子"
    if not u:hasdata(str) then
      u:setdata(str)
      NameID[sy] = "|cFF60AA91神代|r|cFF5B718Bの御|r|cFF573986神子|r"
      u:setplayername(NameID[sy])
      u:adddivinity(3)
      u:getgoddessforce(2)
      u:addskill("S069")
      local cs = 0
      ac.loop(1000, function()
        if u:isalive() then
          cs = cs + 1
          if cs == 8 then
            cs = 0
            u:effectadd("ATx\\[ATxNew]Cthulhu_19.mdl")
            u:curehp(u.handle, 0, 8, 4)
          end
        end
      end)
      u:addstexiao(str, "伤害系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        info.gl = info.gl + GetRandomReal(0.21, 1.2)
      end)
      u:addstexiao(str, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if info.distance <= 450 then
          info.endup = info.endup + 0.18
        end
      end)
      u:addstexiao(str, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not tg:hasdata("圣荒灾乱破坏") then
          tg:setdata("圣荒灾乱破坏")
          tg:effectadd("ATx\\[ATxNew]Cthulhu_20.mdl", "overhead")
          local sl = tg:eliteschange()
          sl = GetRandomInt(1, sl)
          local hp = 0.1 * sl
          if tg:isboss() then
            hp = 0.01 * sl
          end
          tg:eliteschange(-sl)
          if 1 <= hp then
            tg:kill(u.handle)
          else
            tg:changemaxhp(-hp * tg:getmaxhp())
          end
        end
        if u:getluckrandom(1 * info.txgl) and not u:hasdata(str .. "-特效1冷却") then
          u:settimedata(str .. "-特效冷却", 0.25)
          u:adddivinity(1)
          u:effectadd("ATx\\[ATxNew]Cthulhu_20.mdl", "overhead")
          ac.wait(15000, function()
            u:adddivinity(-1)
          end)
        end
        if u:getluckrandom(10 * info.txgl) and not u:hasdata(str .. "-特效冷却") then
          local txsh = 3000 * u:getshenxing()
          local x, y = tg:getxy()
          Effectcreate("ATx\\[ATxNew]Cthulhu_07.mdl", x, y)
          u:settimedata(str .. "-特效冷却", 1)
          local strlx = {
            "物理",
            "魔力",
            "灵力",
            "反物质",
            "能量",
            "震荡"
          }
          local lvlv = {
            1,
            4,
            5
          }
          DamageUnit({
            bj = "神代御神子附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = lvlv[GetRandomInt(1, #lvlv)],
            type = strlx[GetRandomInt(1, #strlx)],
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
          if not tg:isboss() then
            local gl = 20
            if tg:iselite() then
              gl = 2
            end
            if u:getluckrandom(gl) then
              tg:kill(u.handle)
            end
          end
        end
      end)
      u:setdata("系统-无视伤害免疫")
      u:uivar_add({
        keyname = "神代の御神子",
        keytype = "传奇栏",
        text = "|cFF52D6AD神代|r|cFF4DCCB2の御|r|cFF47C2B8神子|r\n|cFF4DCCB2神性 3|r\n|cFF52D6AD奇迹武礼|r\n|cFF47C2B8对450范围内单位提升1.8%终结伤害\n直接伤害时使该次伤害加成提升21%~120%|r\n|cFF52D6AD神之典经|r\n|cFF47C2B8神性差带来的增伤提升50%\n造成伤害无视伤害免疫同时降低自身周围1800范围单位20%移速并使其伤害闪避失效|r\n|cFF52D6AD圣荒灾乱|r\n|cFF47C2B8直接伤害时移除目标1~N(目标精英特性数量)种精英特性并降低其[10%(1%)*移除数量]生命上限(同一单位只生效一次)\n直接伤害时1%在15秒内提升1点神性,可叠加,分立计时|r\n|cFF52D6AD极无之蛇|r\n|cFF47C2B8免疫僵直且额外移速不会失效\n免疫无限类技能大部分效果\n直接伤害时10%附带[神性*3000]随机类型随机伤害,触发时20%即死普通单位,2%精英|r\n|cFF52D6AD八岐降灵|r\n|cFF47C2B8杀敌时提升自身1~3点生命上限并永恒恢复1%最大生命值\n每隔8秒永恒恢复8%最大生命值,死亡时原地复活,冷却188秒|r",
        icon = "war3mapImported\\PASBTNEwl_Sanae_Yushenzi.blp"
      })
    end
  end,
  ["桔梗"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-桔梗"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      PlayGlobalSound(Sound_Jiegeng_01)
      SendDtimeMsgAll(0, "|cFF826DCA『可以自由的憎恨了』|r")
      SendDtimeMsgAll(2.48, "|cFF826DCA『我的灵魂......』|r")
      SendDtimeMsgAll(4.5, "|cFF7A62C7『比那时候更自由』|r")
      SendDtimeMsgAll(8, "|cFF7A62C7『怨恨也好，爱怜也好』|r")
      ac.wait(13000, function()
        PlayGlobalSound(BGM_Jiegeng_02)
        songtext({
          text = {
            {
              starttime = 32.8,
              str = "若是除了最重要的东西"
            },
            {
              starttime = 43.1,
              str = "能够将其他的一切舍弃"
            },
            {
              starttime = 50.7,
              str = "那该有多好"
            },
            {
              starttime = 55.5,
              str = "但现实总是残酷无情"
            },
            {
              starttime = 63,
              str = "这时我只要"
            },
            {
              starttime = 65.8,
              str = "闭上眼睛"
            },
            {
              starttime = 70.5,
              str = "便可以看见含笑的你",
              time = 7.5
            },
            {
              starttime = 78,
              str = "只希望在踏入"
            },
            {
              starttime = 85.6,
              str = "永恒的长眠之前"
            },
            {
              starttime = 93.3,
              str = "可否让你的笑容"
            },
            {
              starttime = 100.8,
              str = "永远伴随着我",
              time = 7.4
            },
            {
              starttime = 123.5,
              str = "人是否都是悲哀的呢"
            },
            {
              starttime = 131,
              str = "但是我们懂得如何忘记"
            },
            {
              starttime = 138.5,
              str = "为了我爱的人"
            },
            {
              starttime = 141.5,
              str = "为了爱我的人"
            },
            {
              starttime = 149,
              str = "能够做些什么",
              time = 4.2
            },
            {
              starttime = 155.7,
              str = "回想相识的当初"
            },
            {
              starttime = 163.1,
              str = "凡事手足无措"
            },
            {
              starttime = 170.7,
              str = "绕了好一段远路"
            },
            {
              starttime = 178.3,
              str = "伤害了彼此好多",
              time = 7.9
            },
            {
              starttime = 216.2,
              str = "只希望在踏入"
            },
            {
              starttime = 223.6,
              str = "永恒的长眠之前"
            },
            {
              starttime = 230.5,
              str = "可否让你的笑容"
            },
            {
              starttime = 238.8,
              str = "永远伴随着我"
            },
            {
              starttime = 248.4,
              str = "回想相识的当初"
            },
            {
              starttime = 255.8,
              str = "凡事手足无措"
            },
            {
              starttime = 263.4,
              str = "绕了好一段远路"
            },
            {
              starttime = 270.8,
              str = "终究走到了结果",
              time = 8.2
            }
          },
          color = "FF6633FF"
        })
      end)
      PlayBGM({
        bgm = 0,
        time = 345,
        ID = 117,
        unit = u.handle
      })
      NameID[sy] = "|cFF826DCA桔|r|cFF7A62C7梗|r"
      u:setplayername(NameID[sy])
      for i = 1, 6 do
        u:changedata("召唤物数量", 1)
        local x, y = u:getxy()
        local mj = u:createunit("n00D", x, y)
        mj:setguard(u.handle)
        mj:groupadd(u:getdata("召唤物组"))
        mj:groupadd(Group_ZhaohuanwuAll)
        mj:setdata("常规召唤物", "死魂虫")
      end
      for i = 9, 12 do
        SetPlayerAlliance(ConvertedPlayer(i), u.owner, ALLIANCE_SHARED_VISION, true)
      end
      u:setdata("桔梗-净魂")
      local zs = 0
      local zhuijian = 1
      local cs = 0
      ac.loop(1000, function()
        if u:isalive() then
          u:clearbuff("眩晕")
          u:clearbuff("僵直")
          u:clearbuff("缠绕")
          u:clearbuff()
        end
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -zs)
        ChangeValue(DamageSystem_Ssjianshao, sy, zhuijian, 2)
        zs = 1.25
        zhuijian = 0.7
        ChangeValue(DamageSystem_Ssjianshao, sy, zhuijian, 1)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * zs)
      end)
      ChangeValue(DamageSystem_Shjc, sy, 0.03)
      ChangeValue(Correction_Jzsh, sy, 0.03)
      ChangeValue(KillReward_MHp, sy, 1)
      ChangeValue(Correction_Exp, sy, 0.2)
      ChangeValue(DamageSystem_EndSh, sy, 0.010000000000000002)
      ChangeValue(Correction_Jzsh, sy, 0.05)
      ModelReplace({
        u = u,
        model = "war3mapImported\\Hero_Jg.mdl",
        modelsize = 1.7,
        modelname = "|cFF826DCA桔|r|cFF7A62C7梗|r",
        modelicon = "Portrait_Jg.tga"
      })
      local dskill = S2ID("A1M2")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            u:animeact("spell")
            u:animespeed(2)
            ac.wait(1000, function()
              u:animespeed(1)
            end)
            PlayGlobalSound(Sound_Jg_N0S1)
            SendDtimeMsgAll(0, "|cFF826DCA桔|r|cFF7A62C7梗|r|cFFC5B6E4：『" .. "能拯救的人我都会尽力去救，仅此而已。" .. "』|r", 10)
            local x, y = u:getxy()
            local fw = 1400
            local dx = fw / 440
            local cs2 = 0
            local tx = Effectcreate("war3mapImported\\chronospher_fx_mediumq.mdx", x, y, -1, dx, 200)
            ac.timer(30, 1000, function()
              x, y = u:getxy()
              SetEffectXY(tx, x, y)
              cs2 = cs2 + 1
              ForGroupLuaNew(Group_PlayHero, function(xq)
                if DistanceBetweenUnits(xq.handle, u.handle) <= 1400 then
                  xq:setdata("桔梗-结界减伤")
                else
                  xq:deldata("桔梗-结界减伤")
                end
              end)
              for _, xq in ac.selector():in_rangexy(x, y, 1400):allow_unify():ipairs() do
                xq = getunit(xq)
                if not xq:hasdata("系统-弹幕") then
                  if xq:is_enemy(u.handle) then
                    local x2, y2 = xq:getxy()
                    local jd = AngleXY(x, y, x2, y2)
                    x2, y2 = PolarXY(x, y, 1450, jd)
                    xq:setxy(x2, y2)
                  end
                elseif xq.owner ~= u.owner then
                  xq:setdata("弹幕-生命值", 0)
                end
              end
              if cs2 == 1000 then
                DestroyEffectLua(tx)
                ForGroupLuaNew(Group_PlayHero, function(xq)
                  xq:deldata("桔梗-结界减伤")
                end)
              end
            end)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      local dskill = S2ID("A1M3")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          local ewl = getunit(args.unit)
          if 2000 <= dis then
            b = false
            u:sendmessage("|cFF7DBEF1距离超过2000|r")
          end
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            u:animeact("attack")
            u:setface(angle)
            u:buffset(u.handle, 0.4, "暂停")
            u:buffset(u.handle, 0.8, "无敌")
            PlayGlobalSound(Sound_Jg_N0S2)
            SendDtimeMsgAll(0, "|cFF826DCA桔|r|cFF7A62C7梗|r|cFFC5B6E4：『" .. "这就是封印之箭，用来对付那些特别难缠的妖怪" .. "』|r", 10)
            ac.wait(300, function()
              u:playsound(Sound_Bow_02)
              unifycreate({
                owner = u.handle,
                model = "4.20.613 (7).mdl",
                modelname = "封魔箭",
                modelsize = 1.5,
                height = 90,
                damage = 0,
                damagetype = 1,
                x = x,
                y = y,
                range = 3600,
                speed = 4000,
                volume = 120,
                angle = angle,
                angleoffset = 0,
                attenua = 1,
                attenuacount = 1,
                life = 10,
                isbullet = false,
                isvest = false,
                isignorearmor = false,
                startfunc = function(mj)
                  mj:animespeed(3)
                  mj:setdata("循环计数", 0)
                end,
                loopfunc = function(mj)
                  mj:changedata("循环计数", UnifyDT)
                  if mj:getdata("循环计数") >= 0.03 then
                    mj:setdata("循环计数", 0)
                  end
                end,
                hitfunc = function(mj, damage)
                  return damage
                end,
                hitbeforefunc = function(mj, xq, damage2)
                end,
                hitafterfunc = function(mj, xq, damage2)
                end,
                endfunc = function(mj)
                  local dx, dy = mj:getxy()
                  mj:playsound(Sound_Reimu_05)
                  mj:animespeed(1)
                  Effectcreate("4.20.613 (2).mdl", dx, dy, 0, 3)
                  Effectcreate("4.20.613 (1).mdl", dx, dy, 0.5, 5)
                  for _, xq in ac.selector():in_rangexy(dx, dy, 500):is_enemy(u.handle):ipairs() do
                    xq = getunit(xq)
                    xq:effectadd("Abilities\\Spells\\Human\\AerialShackles\\AerialShacklesTarget.mdl", "chest")
                    xq:buffset(u.handle, 10, "眩晕")
                    xq:buffset(u.handle, 10, "僵直")
                    xq:buffset(u.handle, 10, "暂停")
                    xq:changetimedata("怪物-额外受伤", 0.3, 10)
                    xq:removecharacteristics(10)
                  end
                end
              })
            end)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      local dskill = S2ID("A1M4")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local x, y = u:getxy()
          local tg = getunit(args.target)
          local x2, y2 = tg:getxy()
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          local ewl = getunit(args.unit)
          if 1000 <= dis then
            b = false
            u:sendmessage("|cFF7DBEF1距离超过1000|r")
          end
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            u:animeact(8)
            u:setface(angle)
            u:buffset(u.handle, 0.5, "暂停")
            u:buffset(u.handle, 0.5, "绝对闪避")
            local jd = angle + 180
            Effectcreate("war3mapImported\\blackblink.mdx", x, y, 0, 1.5)
            x, y = PolarXY(x, y, 100, jd)
            u:setxy(x, y)
            Effectcreate("war3mapImported\\blackblink.mdx", x, y, 0, 1.5)
            local cs = 0
            ac.loop(50, function(timer)
              cs = cs + 1
              tg:effectadd("4.20.613 (6).mdl", "origin", 0.1)
              tg:buffset(u.handle, 0.5, "僵直")
              DamageUnit({
                bj = "桔梗技能",
                unit = tg.handle,
                source = u.handle,
                damage = 1000 * u:getlevel(),
                level = 1,
                type = "灵力",
                isvest = false,
                isattack = false,
                isnoarmor = false,
                element = "无",
                extradata = {
                  "系统-本次伤害无视伤害抗性"
                }
              })
              if cs == 10 then
                local x, y = u:getxy()
                Effectcreate("4.20.613 (4).mdl", x, y, 0, 3)
                Effectcreate("4.20.613 (5).mdl", x, y, 0, 3)
                unitmove({
                  unit = tg.handle,
                  time = 0.1,
                  distance = 600,
                  angle = u:getface()
                })
                tg:buffset(u.handle, 2, "眩晕")
                for _, xq in ac.selector():in_rangexy(x, y, 300):is_enemy(u.handle):is_not(tg.handle):ipairs() do
                  xq = getunit(xq)
                  unitmove({
                    unit = xq.handle,
                    time = 0.1,
                    distance = 600,
                    angle = u:getface()
                  })
                  xq:buffset(u.handle, 2, "眩晕")
                end
                u:buffset(u.handle, 0.25, "绝对闪避")
                timer:remove()
              end
            end)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      u:setskilldatastring("A1M2", "提示", "|cFF6699FF小范围防御式结界|r")
      u:setskilldatastring("A1M2", "图标", "war3mapImported\\BTNEwl_Jg_80.tga")
      u:setskilldatastring("A1M3", "提示", "|cFF6699FF封印之箭|r")
      u:setskilldatastring("A1M3", "图标", "war3mapImported\\BTNEwl_Jg_82.tga")
      u:setskilldatastring("A1M4", "提示", "|cFF6699FF灵力迸发|r")
      u:setskilldatastring("A1M4", "图标", "war3mapImported\\BTNEwl_Jg_50.tga")
      u:addstexiao(str, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not u:hasdata(str .. "-特效冷却") then
          u:settimedata(str .. "-特效冷却", 0.5)
          DamageUnit({
            bj = "桔梗附伤",
            unit = tg.handle,
            source = u.handle,
            damage = 0.5 * info.yssh,
            level = 1,
            type = "灵力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
        end
        if not u:hasdata(str .. "-特效2冷却") then
          u:settimedata(str .. "-特效2冷却", 0.5)
          DamageUnit({
            bj = "桔梗附伤",
            unit = tg.handle,
            source = u.handle,
            damage = 50000 + 100 * u:getallattri(),
            level = 1,
            type = "灵力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
        end
      end)
      
      local function skill(args)
        if string.lower(args.chat) == "inuyasha" then
          u:setdata("桔梗-犬夜叉获取")
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        skill(args)
      end)
      local bb = getunit(Beibao[sy])
      bb:addskill("A1GJ")
      bb:delskill("A1GJ")
      u:uivar_change({
        keyname = "圣大人",
        keytype = "传奇栏",
        text = "|cFF826DCA桔|r|cFF7A62C7梗|r\n|cFF826DCA犬夜叉 自从遇到你以后 我就不再是个巫女了\n变成了一个普通的女人 我活着的时候就一直想这样做. |r\n|cFF7A62C7我···终于成为一个普通女人了.\n第一次看到 犬夜叉 你哭泣时 会是这幅面孔啊.\n你赶到了我身边 这样就足够了. |r",
        icon = "war3mapImported\\BTNEwl_Jg_02.tga",
        isclearclick = true
      })
    end
  end,
  ["队长神化"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-人理之光"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      u:setplayername("|cFF7DBEF1[|r|cFFFFCC00人理之光|r|cFF7DBEF1]|r" .. NameID[sy])
      PlayBGM({
        bgm = 0,
        time = 145,
        ID = 130,
        unit = u.handle
      })
      SendDtimeMsgAll(0, "|cFFFFCC00基尔什塔利亚·沃戴姆：『人们仰望天空，看到了很久以前就存在于天空的神明，那是一直以来都无法抵达的神圣。』|r", 30)
      SendDtimeMsgAll(14, "|cFFFFCC00基尔什塔利亚·沃戴姆：『但是我们不知从何时，开始挑战天空。』|r", 30)
      SendDtimeMsgAll(21.6, "|cFFFFCC00基尔什塔利亚·沃戴姆：『无所畏惧，无所顾忌』|r", 30)
      SendDtimeMsgAll(25.2, "|cFFFFCC00基尔什塔利亚·沃戴姆：『天空成为了必须要解明的对象』|r", 30)
      SendDtimeMsgAll(28.6, "|cFFFFCC00基尔什塔利亚·沃戴姆：『没错，你们』|r", 30)
      SendDtimeMsgAll(32.2, "|cFFFFCC00基尔什塔利亚·沃戴姆：『我们会用我们精准的计算，将你们粉碎。』|r", 30)
      SendDtimeMsgAll(37.7, "|cFFFFCC00基尔什塔利亚·沃戴姆：『我们不可以停下脚步，为了终有一天可以到达那片天空，我们是挑战天空之人。 』|r", 30)
      PlayGlobalSound(Sound_Duizhang_02)
      ac.wait(47500.0, function()
        PlayGlobalSound(BGM_Duizhang_03)
        songtext({
          text = {
            {
              starttime = 12.8,
              str = "无比忧郁"
            },
            {
              starttime = 15.2,
              str = "每当苏醒眼前都是同样的天花板"
            },
            {
              starttime = 24.25,
              str = "现实被摆在了面前"
            },
            {
              starttime = 30.1,
              str = "这里没有出口"
            },
            {
              starttime = 35.1,
              str = "该如何终结"
            },
            {
              starttime = 38,
              str = "这个永远没有完成与崩溃的故事"
            },
            {
              starttime = 46,
              str = "倘若命运早已注定"
            },
            {
              starttime = 49.4,
              str = "我明明已经发誓不去想象没有选择的未来"
            },
            {
              starttime = 57.8,
              str = "在绝望的边缘"
            },
            {
              starttime = 60,
              str = "呐喊着思念之人的名字"
            },
            {
              starttime = 65,
              str = "犹如远方的惊雷"
            },
            {
              starttime = 69,
              str = "只求能告诉你"
            },
            {
              starttime = 72,
              str = "我还在风暴的另一侧战斗",
              time = 12
            }
          },
          color = "FFCCFFFF"
        })
      end)
      u:addskill("S08A")
      u:addskill("A1J9")
      u:changedata("幸运", 2)
      u:addallstats(20)
      u:addint(20)
      ChangeValue(DamageSystem_Shjc, sy, 0.025)
      ChangeValue(DamageSystem_Shjc, sy, 0.025)
      ChangeValue(DamageSystem_Shjc, sy, 0.02)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 75)
      ChangeValue(DamageSystem_LwSs, sy, 1.1, 1)
      ChangeValue(Correction_Gold, sy, 0.05)
      ChangeValue(Hero_Tili_Huifu, sy, 0.1)
      u:setdata("人理之光-星光计数", 0)
      u:setdata("人理之光-强运星辰数量", 1)
      u:setdata("人理之光-星辰开启")
      u:addstexiao(str, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:getluckrandom(10 * info.txgl) and not u:hasdata(str .. "-特效冷却") then
          local txsh = 5000 + 150 * u:getint() + 10 * u:getdata("魔力值")
          u:settimedata(str .. "-特效冷却", 0.5)
          tg:playsound(bac165)
          local x2, y2 = tg:getxy()
          Effectcreate("war3mapImported\\2.26.831 (5).mdl", x2, y2, 1, 2)
          ac.wait(100, function()
            tg:playsound(bac164)
            Effectcreate("war3mapImported\\2.19.335 (8).mdl", x2, y2)
            for _, xq in ac.selector():in_rangexy(x2, y2, 300):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              DamageUnit({
                bj = "队长神化附伤",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 5,
                type = "魔力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "光"
              })
            end
          end)
        end
        if u:hasdata("变异判定-队长禁忌") and not u:hasdata("队长-禁忌特效冷却") then
          u:settimedata("队长-禁忌特效冷却", 0.25)
          DamageUnit({
            bj = "队长禁忌附伤",
            unit = tg.handle,
            source = u.handle,
            damage = info.yssh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "光"
          })
        end
      end)
      local cs = 0
      local cs2 = 0
      local zs = 0
      local mb = false
      local add = 0
      local zu = CreateGroupLua()
      ac.loop(1000, function()
        if u:isalive() then
          cs = cs + 1
          u:changedata("魔力值", 1)
          if cs == 360 then
            cs = 0
            u:additem("I01D")
            u:playsound(Sound_Duizhang_03)
          end
          GroupClearLua(zu)
          if u:hasdata("人理之光-星辰开启") then
            local x, y = u:getxy()
            for _, xq in ac.selector():in_rangexy(x, y, 1200):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              xq:groupadd(zu)
            end
            for i = 1, u:getdata("人理之光-强运星辰数量") do
              if 0 < Group_Counts(zu) then
                local tg = Group_Randomunit(zu)
                tg:groupremove(zu)
                local txsh = 5000 + 2 * u:getdata("魔力值")
                tg:effectadd("Abilities\\Spells\\NightElf\\Starfall\\StarfallTarget.mdl")
                ac.wait(500, function()
                  DamageUnit({
                    bj = "队长星辰",
                    unit = tg.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 2,
                    type = "魔力",
                    isvest = true,
                    isattack = false,
                    isnoarmor = false,
                    element = "无",
                    extradata = {""}
                  })
                end)
              end
            end
          end
          if not u:hasdata("人理之光-星之修复") and u:ishasitem("I0EF") then
            local wp = u:getitem("I0EF")
            if GetItemCharges(wp) >= 300 then
              u:sendmessage("|cFF3366FF星之修复|r")
              u:setdata("人理之光-星之修复")
              ChangeValue(DamageSystem_LwSs, sy, 1.1, 2)
              ChangeValue(DamageSystem_Ssjianshao, sy, 0.85, 1)
              ChangeValue(Correction_CureUp, sy, 0.1)
              ChangeValue(HeroMenu_HpChange_MaxHp, sy, 0.5)
            end
          end
          u:changedata("固定伤害", 0.1 * -add)
          add = 2 * u:getdata("魔力值")
          u:changedata("固定伤害", 0.1 * add)
          if zs <= 5 then
            if zs == u:getdata("人理之光-星光计数") then
              mb = false
              zs = zs + 1
            elseif mb == false then
              cs2 = cs2 + 1
              if 150 <= cs2 then
                cs2 = 0
                mb = true
                local x2, y2 = GetRandomXYInRect(RECT_PlayArea)
                local tx1 = Effectcreate("war3mapImported\\2.26.831 (4).mdl", x2, y2, -1, 2)
                local tx2 = Effectcreate("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", x2, y2, -1)
                PingMinimapEx(x2, y2, 5, 51, 153, 255, false)
                u:sendmessage("|cFF3366FF星光坠落|r")
                local xzq = u:createfogcorrector(x2, y2, 512)
                ac.loop(1000, function(timer)
                  for _, xq in ac.selector():in_rangexy(x2, y2, 300):ipairs() do
                    xq = getunit(xq)
                    if xq.handle == u.handle then
                      u:changedata("人理之光-星光计数", 1)
                      u:removefogcorrector(xzq)
                      u:sendmessage("|cFF3366FF星光收集|r")
                      DestroyEffectLua(tx1)
                      DestroyEffectLua(tx2)
                      timer:remove()
                      break
                    end
                  end
                end)
              end
            end
          end
        end
      end)
      
      local function chattrg(args)
        if args.chat == "强运之星辰" and u:isalive() and u:ishasitem("I0EF") and u:getdata("人理之光-强运星辰数量") < 3 and GetItemCharges(u:getitem("I0EF")) >= 300 then
          ChangeItemCount(u:getitem("I0EF"), -300)
          u:changedata("人理之光-强运星辰数量", 1)
          u:playsound(Sound_Duizhang_10)
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chattrg(args)
      end)
      local dskill = S2ID("A1JE")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            if u:hasdata("人理之光-星辰开启") then
              u:deldata("人理之光-星辰开启")
              u:sendmessage("|cFF6699FF星辰关闭|r")
            else
              u:setdata("人理之光-星辰开启")
              u:sendmessage("|cFF6699FF星辰开启|r")
            end
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      local dskill = S2ID("A1JB")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          local tg = getunit(args.target)
          local dis = DistanceBetweenUnits(u.handle, tg.handle)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if tg.handle == u.handle then
            b = false
            u:sendmessage("|cFF7DBEF1无法以自身为目标|r")
          end
          if 2000 <= dis then
            b = false
            u:sendmessage("|cFF7DBEF1距离超过2000|r")
          end
          if b then
            PlayGlobalSound(Sound_Duizhang_08)
            tg:playsound(bac165)
            local x, y = u:getxy()
            local x2, y2 = tg:getxy()
            Effectcreate("war3mapImported\\2.27.345 (4).mdl", x, y, 12)
            Effectcreate("war3mapImported\\2.27.345 (2).mdl", x2, y2, 12, 2, 0, 0, 0, 0, 0.5)
            Effectcreate("war3mapImported\\2.26.831 (4).mdl", x2, y2, 12, 4)
            local mj = u:createunit("u0D7", x2, y2, 0)
            mj:timetoremove(12)
            local dx = 1
            ac.loop(40, function(timer)
              dx = dx + 0.04
              mj:setsize(dx)
              if 3 <= dx then
                timer:remove()
              end
            end)
            SendDtimeMsgAll(0.5, "|cFFFFCC33『天体即为空洞，』|r", 30)
            SendDtimeMsgAll(3, "|cFFFFCC33『空洞即为虚空，』|r", 30)
            SendDtimeMsgAll(5.8, "|cFFFFCC33『虚空即为神之所在。』|r", 30)
            SendDtimeMsgAll(10.6, "|cFFFFCC33『御主的生命就在这里消散吧。』|r", 30)
            ac.wait(11500, function()
              ac.wait(500, function()
                tg:playsound(bac224)
              end)
              Effectcreate("war3mapImported\\2.27.345 (3).mdl", x2, y2, 0, 4)
              Effectcreate("war3mapImported\\2.27.345 (5).mdl", x2, y2, 0, 0.5)
              if not tg:hasdata("队长-人理保障天球已生效") then
                tg:setdata("队长-人理保障天球已生效")
                local down = -0.4 * tg:getmaxhp()
                if tg:hasdata("BOSS-真红") or tg:hasdata("BOSS-暗神") then
                  down = -0.1 * tg:getmaxhp()
                end
                tg:changemaxhp(down)
                DamageUnit({
                  bj = "人理保障天球",
                  unit = tg.handle,
                  source = u.handle,
                  damage = 0.25 * tg:getmaxhp(),
                  level = 5,
                  type = "魔力",
                  isvest = false,
                  isattack = false,
                  isnoarmor = false,
                  element = "无",
                  extradata = {""}
                })
              end
            end)
            tg:buffset(u.handle, 15, "锁定")
            tg:buffset(u.handle, 15, "暂停")
            u:buffset(u.handle, 15, "绝对闪避")
            u:buffset(u.handle, 12, "暂停")
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      u:uivar_change({
        keyname = "隐匿者",
        keytype = "传奇栏",
        text = "|cFFFFCC00人理之光|r\n|cFF3366FF宙不止\n[数据删除]|r\n|cFF6699FF星不邀\n[数据删除]|r\n|cFFFFFF99「天体大魔术」\n[数据删除]|r\n|cFFFFCC33神不落\n[数据删除]|r\n|cFFFFCC00枯竭的身体\n[数据删除]\n冠位指定/人理保障天球\n[数据删除]|r",
        icon = "war3mapImported\\BTNEwl_Duizhang_05"
      })
    end
  end,
  ["千子村正神化"] = function(u)
    local sy = u.ownerid
    local str = "神化判定-千子村正"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      PlayGlobalSound(Sound_Senji_11)
      u:chat("Saber、千子村正。应召唤而来。")
      u:setplayername("|cFF7DBEF1[|r|cFFFF3300刀|r|cFFFF5500匠|r|cFF7DBEF1]|r" .. NameID[sy])
      local z1 = 0
      local z2 = 0
      local z3 = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -z3)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -z3)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -z3)
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, -z1)
        u:addallstats(-z2)
        z1 = 0.1 * System_Count_Weapon
        z2 = 5 * System_Count_Weapon
        z3 = 0.04 * System_Count_Weapon
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * z3)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * z3)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * z3)
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, z1)
        u:addallstats(z2)
      end)
      AddAllSTexiao(str, "伤害系统计算效果", function(args)
        local tg = args.tg
        local info = args.damageinfo
        if tg:ishasskill("A0DV") then
          info.ewss = info.ewss + 0.25
        end
      end)
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(str .. "-特效冷却") then
          u:settimedata(str .. "-特效冷却", 1)
          u:curetili(0.3)
          u:effectadd("AATX\\[AATxNew]Fire33.mdl", "origin")
        end
      end)
      u:addtrgevent("单位-指定点目标指令", function(args)
        if args.orderid == String2OrderIdBJ("smart") and u:hasdata("千子村正-二天一流") and Hero_Tili[sy] >= 5 then
          u:lossstamina(0.75)
          u:playsound(Sound_Katana_15)
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local angle = AngleXY(x, y, x2, y2)
          local dis = DistanceXY(x, y, x2, y2)
          local mjl = 800
          if dis >= mjl then
            dis = mjl
          end
          Effectcreate("Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl", x, y)
          Effectcreate("war3mapImported\\blackblink.mdx", x, y)
          Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
          Effectcreate("war3mapImported\\bbb.mdx", x, y)
          unitmove({
            unit = u.handle,
            time = 0.15,
            distance = dis,
            angle = angle,
            endfunc = function(dx, dy)
              Effectcreate("Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl", dx, dy)
              Effectcreate("war3mapImported\\blackblink.mdx", dx, dy)
              u:setdata("位移点X", dx)
              u:setdata("位移点Y", dy)
              u:useweapon()
            end,
            isblink = true
          })
          ac.wait(10, function()
            u:deldata("千子村正-二天一流")
          end)
        end
      end)
      ac.loop(10000, function()
        if u:isalive() then
          u:clearbuff("眩晕")
          u:clearbuff("僵直")
          u:clearbuff()
          u:effectadd("AATX\\[AATxNew]Fire30.mdl", "origin")
        end
      end)
      u:uivar_change({
        keyname = "千子村正",
        keytype = "传奇栏",
        text = "|cFFFF0000千|r|cFFFF3D00子|r|cFFFF5C00村正|r\n|cFFFF0000业之眼|r\n|cFFFF3D00是只为战斗行动而特化的眼力。以这个肉体的话是无法像千里眼那样看穿命运的……本应如此的，\n但由于一生都在火焰中凝视着『宿业』的村正的价值观，他的鹰之瞳不但能洞察猎物，甚至还达到了能洞察因果的地步。|r\n|cFFFF0000焰|r\n|cFFFF3D00倾注全心全力，将自身燃烧殆尽的程度来铸造炼成。|r\n|cFFFF0000样品|r\n|cFFFF3D00千子村正能将手中的武器所具有的威力运用自如地释放出来。只要愿意的话，\n一挥就能释放出能让武器自毁的程度的最大威力。|r",
        icon = "war3mapImported\\BTNEwl_Senji_03",
        isclearclick = true
      })
    end
  end,
  ["金色的梦幻之瞳"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-金色的梦幻之瞳"
    if not u:hasdata(str) then
      u:setdata(str)
      PlayBGM({
        bgm = BGM_Ryr_Yanjingjinjie,
        time = 255,
        ID = 256,
        unit = u.handle
      })
      u:changedata("幸运", 2)
      ChangeValue(DamageSystem_Baoji, sy, 10)
      ChangeValue(DamageSystem_Baoshang, sy, 0.1)
      u:addstexiao(str, "伤害判定后效果", function(args)
        local info = args.damageinfo
        local original_damage = info.yssh or 0
        if 0 < (info.damage or 0) and 0 < original_damage then
          LossHpUnit({
            u = args.u,
            tg = args.tg,
            damage = original_damage * 0.5,
            bj = "[生命损耗]金色的梦幻之瞳"
          })
        end
      end)
      u:addstexiao(str, "被施加Buff时效果-眩晕", function(args)
        if not Keyan_Guomintizhi then
          args.time = 0
        end
      end)
      u:addstexiao(str, "被施加Buff时效果-僵直", function(args)
        if not Keyan_Guomintizhi then
          args.time = 0
        end
      end)
      u:uivar_change({
        keyname = "萤眸",
        keytype = "传奇栏",
        icon = "Cq_Ryr_Jinsezhitong.tga",
        ishasphoto = true,
        text = "|cFFFFCC00金|r|cFFFFB200色|r|cFFFF9900的|r|cFFFF8000梦|r|cFFFF6600幻|r|cFFFF4C00之|r|cFFFF3300瞳|r\n|cFFCC99FF那|r|cFFCE9EF3如|r|cFFD1A2E8同|r|cFFD3A7DC碎|r|cFFD5ACD1星|r|cFFD8B0C5流|r|cFFDAB5B9动|r|cFFDCB9AE的|r|cFFDFBEA2眼|r|cFFE1C397眸|r|cFFE3C78B，|r|cFFE5CC7F眼|r|cFFE8D174波|r|cFFEAD568流|r|cFFECDA5D转|r|cFFEFDF51，|r|cFFF1E346泛|r|cFFF3E83A起|r|cFFF6EC2E涟|r|cFFF8F123漪|r|cFFFAF617。|r",
        isclearclick = true,
        size = 2
      })
    end
  end,
  ["忍野忍神化"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-忍野忍神化"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      u:setplayername("|cffff99ccお|r|cffffada4し|r|cffffc17bの|r|cffffd652し|r|cffffea29の|r|cffffff00ぶ|r")
      NameID[sy] = "|cffff99ccお|r|cffffada4し|r|cffffc17bの|r|cffffd652し|r|cffffea29の|r|cffffff00ぶ|r"
      u:adddivinity(1)
      PlayBGM({
        bgm = 0,
        time = 140,
        ID = 0
      })
      PlayGlobalSound(Sound_Ryr_Shenhua)
      local strz = {
        {
          rw = 1,
          time = 3.7,
          str = "那样就可以了吗 汝啊"
        },
        {
          rw = 1,
          time = 6.6,
          str = "不是积攒了很多话要说吗"
        },
        {
          rw = 2,
          time = 9.4,
          str = "才没有呢，在这个世界里 她并不认识我"
        },
        {
          rw = 2,
          time = 13.8,
          str = "虽然在某人的计策下 与我见了一面"
        },
        {
          rw = 2,
          time = 17.4,
          str = "但是这个世界上的我和这个世界上的她 其实并没有相遇"
        },
        {
          rw = 1,
          time = 23,
          str = "那么 汝准备怎么做呢"
        },
        {
          rw = 2,
          time = 25.2,
          str = "什么怎么做"
        },
        {
          rw = 1,
          time = 26.7,
          str = "就是说要不要去拯救这个世界呢"
        },
        {
          rw = 2,
          time = 29.7,
          str = "不 我是要去拯救一个女孩子 能不能助我一臂之力呢"
        },
        {
          rw = 1,
          time = 35.3,
          str = "吾能说不吗 不是说过要死在一起吗"
        },
        {
          rw = 2,
          time = 40.8,
          str = "你果然认为我会死吗"
        },
        {
          rw = 1,
          time = 43,
          str = "没可能赢的吧 面对全盛时期的吸血鬼"
        },
        {
          rw = 1,
          time = 47,
          str = "就凭半吊子吸血鬼的吾和半吊子人类的汝组成的二人组"
        },
        {
          rw = 2,
          time = 52.7,
          str = "大概吧 不过并不是因为被某人所托"
        },
        {
          rw = 2,
          time = 57.1,
          str = "而是在这个存在她活下来可能性的世界"
        },
        {
          rw = 2,
          time = 59.6,
          str = "竟然是世界毁灭的世界中 这种事怎么说得过去"
        },
        {
          rw = 2,
          time = 62.5,
          str = "你难道不希望他活下来的这个世界是一个美好的世界么"
        },
        {
          rw = 1,
          time = 66,
          str = "也是 只是让她活下来就因此导致世界毁灭 这还真是个想不得了的倾国美女啊"
        },
        {
          rw = 2,
          time = 74.5,
          str = "倾国美女啊"
        },
        {
          rw = 1,
          time = 76.5,
          str = "只凭一个人想要去改变世界是相当困难的 但是让世界稍微倾斜一下 也不是做不到呢"
        },
        {
          rw = 2,
          time = 85,
          str = "姑且不说世界 如果只是个故事的话 谁都能让他倾斜呢"
        },
        {
          rw = 1,
          time = 90,
          str = "倾斜世界吗"
        },
        {
          rw = 2,
          time = 92,
          str = "在这种场合下 应该倾斜的应该是我们吧"
        },
        {
          rw = 1,
          time = 95,
          str = "那样就可真的是爱逞英雄呢以了吗汝啊"
        },
        {
          rw = 2,
          time = 97,
          str = "这个我不否认"
        },
        {
          rw = 1,
          time = 98.6,
          str = "咔咔咔 汝啊 想要倾斜的话 准备怎么倾斜呢"
        },
        {
          rw = 2,
          time = 104.5,
          str = "说的是啊 暂且先让世界为眼前的女子所倾斜吧"
        },
        {
          rw = 1,
          time = 110.6,
          str = "将江山和美人放在天平两端 结果还是选择了美人 对吧 真是符合时代呢"
        },
        {
          rw = 2,
          time = 116.6,
          str = "已经早就过时了"
        },
        {
          rw = 1,
          time = 118,
          str = "咔咔咔"
        },
        {
          rw = 2,
          time = 119,
          str = "想要拯救世界 也要拯救女人 这种贪婪才是现代的英雄形象吧"
        },
        {
          rw = 1,
          time = 125.8,
          str = "没错 是这样的"
        },
        {
          rw = 1,
          time = 129,
          str = "既然是一同赴死 那么活着的时候就更加不可分离了"
        },
        {
          rw = 2,
          time = 137,
          str = "那也不错"
        }
      }
      for index, value in ipairs(strz) do
        local namestr, colorstr
        if value.rw == 1 then
          namestr = "|cFFFFAA22忍|r"
          colorstr = "|cFFFF0000"
        else
          namestr = "|cFF999999历|r"
          colorstr = "|cFFCCCCCC"
        end
        local showstr = "：『" .. value.str .. "』"
        SendDtimeMsgAll(value.time, namestr .. colorstr .. showstr, 10)
      end
      ac.wait(140000, function()
        local count = GetRandomInt(1, 5)
        local zu = {
          {
            bgm = BGM_Ryr_01,
            time = 280
          },
          {
            bgm = BGM_Ryr_02,
            time = 95
          },
          {
            bgm = BGM_Ryr_03,
            time = 260
          },
          {
            bgm = BGM_Ryr_04,
            time = 250
          },
          {
            bgm = BGM_Ryr_05,
            time = 345
          }
        }
        PlayBGM({
          bgm = zu[count].bgm,
          time = zu[count].time,
          ID = 163,
          unit = u.handle
        })
      end)
      ac.loop(1000, function()
        if u:isalive() then
          local dx, dy = u:getxy()
          Effectcreate("ZK_PP3.mdx", dx, dy, 3, 1, 0, GetRandomAngle())
        end
      end)
      local dx, dy = u:getxy()
      local tx = Effectcreate("ZK_TTQ_RED6.mdx", dx, dy, -1, 1, 75, GetRandomAngle())
      ac.loop(30, function()
        local dx, dy = u:getxy()
        SetEffectXY(tx, dx, dy)
      end)
      u:effectadd("GameBABY_m58.mdx", "origin", -1)
      u:additem("I0KE")
      u:additem("I0KC")
      moveskillreplace({
        unit = u.handle,
        level = 1,
        skill_Q = "A0C9",
        skill_W = "A0C8",
        efunc = function()
          u:setdata("忍野忍-瞬移次数", 0)
          u:addtrgevent("单位-指定点目标指令", function(args)
            if args.orderid == String2OrderIdBJ("smart") and u:getdata("忍野忍-瞬移次数") > 0 and not u:hasdata("忍野忍-瞬移冷却") then
              u:settimedata("忍野忍-瞬移冷却", 0.1)
              u:changedata("忍野忍-瞬移次数", -1)
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local angle = AngleXY(x, y, x2, y2)
              local dis = DistanceXY(x, y, x2, y2)
              local mjl = 400
              if dis >= mjl then
                dis = mjl
              end
              Effectcreate("Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl", x, y)
              Effectcreate("war3mapImported\\blackblink.mdx", x, y)
              Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
              Effectcreate("war3mapImported\\bbb.mdx", x, y)
              unitmove({
                unit = u.handle,
                time = 0.15,
                distance = dis,
                angle = angle,
                endfunc = function(dx, dy)
                  Effectcreate("Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl", dx, dy)
                  Effectcreate("war3mapImported\\blackblink.mdx", dx, dy)
                  u:setdata("位移点X", dx)
                  u:setdata("位移点Y", dy)
                end,
                isblink = true
              })
            end
          end)
        end
      })
      u:setdata("忍野忍-甜腻层数上限", 100)
      ForGroupLuaNew(u:getdata("忍野忍-甜腻施加组"), function(xq)
        xq:deldata("忍野忍-甜腻负面")
        xq:deldata("忍野忍-甜腻层数")
        xq:groupremove(u:getdata("忍野忍-甜腻施加组"))
      end)
      ChangeValue(DamageSystem_EndSh, sy, 0.1)
      local add = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, -add)
        ChangeValue(Correction_Jzsh, sy, -add)
        ChangeValue(Correction_Gun, sy, -add)
        add = 0.05 * u:getstate("吸血鬼变异")
        ChangeValue(DamageSystem_Shjc, sy, add)
        ChangeValue(Correction_Jzsh, sy, add)
        ChangeValue(Correction_Gun, sy, add)
      end)
      ChangeValue(DamageSystem_Shjc, sy, 1)
      ChangeValue(Correction_Jzsh, sy, 0.5)
      ChangeValue(Correction_Gun, sy, 0.5)
      ac.loop(1000, function()
        if u:isalive() then
          local sx = u:getallattri()
          ForGroupLuaNew(u:getdata("忍野忍-甜腻施加组"), function(xq)
            if xq:isboss() then
              local txsh = xq:getdata("忍野忍-甜腻层数") * sx
              DamageUnit({
                bj = "忍野忍甜腻持续伤害",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "魔力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "无",
                extradata = {""}
              })
            end
          end)
        end
      end)
      u:addstexiao(str, "杀敌效果", function(args)
        local tg = args.tg
        if tg:isboss() then
          local dx, dy = tg:getxy()
          if GetRandom100(100) then
            local g2 = {}
            for index, value in ipairs(Pools_Spe) do
              if (value.name == "Episode夺走的左腿" or value.name == "Dramaturgy夺走的右腿" or value.name == "Cutter夺走的双臂") and not value.hasbeenget then
                table.insert(g2, value.name)
              end
            end
            if 0 < #g2 then
              local dstr = g2[GetRandomInt(1, #g2)]
              for index, value in ipairs(Pools_Spe) do
                if value.name == dstr then
                  if not value.hasbeenget then
                    local item = u:additem(value.itemtype)
                    value.hasbeenget = true
                  end
                  break
                end
              end
            end
          end
        end
      end)
      u:addskill("S0BN")
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(str .. "-损耗特效冷却") then
          u:settimedata(str .. "-损耗特效冷却", 0.25)
          local sh = u:getdata("忍野忍-甜食值") * 1 * tg:getdata("忍野忍-甜腻层数")
          LossHpUnit({
            u = u,
            tg = tg,
            damage = sh,
            bj = "[生命损耗]忍野忍甜腻"
          })
        end
        if not u:hasdata(str .. "-特效冷却") and u:getluckrandom(25 * info.txgl) then
          u:settimedata(str .. "-特效冷却", 2)
          local dcs = 0
          for i = 1, 2 do
            if u:getluckrandom(25 * info.txgl) then
              dcs = dcs + 1
            end
          end
          local txsh = info.yssh * 0.5
          for i = 1, dcs do
            DamageUnit({
              bj = "忍野忍神化附伤",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无",
              extradata = {""}
            })
          end
        end
        if not u:hasdata(str .. "-特效2冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(str .. "-特效2冷却", 3)
          local txsh = info.yssh * 0.5
          local dx, dy = tg:getxy()
          Effectcreate("tx120.mdx", dx, dy, 0, 1.5, 0, GetRandomAngle())
          for _, xq in ac.selector():in_rangexy(dx, dy, 500):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "忍野忍神化附伤",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无",
              extradata = {""}
            })
          end
        end
      end)
      u:uivar_change({
        keyname = "忍野忍",
        keytype = "传奇栏",
        text = "|cFFFFFF00金|r|cFFDFDF00发|r|cFFBFBF00幼|r|cFF9F9F00女|r|cFF808000吸|r|cFF606000血|r|cFF404000鬼|r\n|cFFFFF240曾经的她是美丽高贵的人类公主,拥有柔顺的金发，瓜子脸加上大大的双眼，\n鲜红的嘴唇，柔细的颈子，清透的肌肤，白皙的手指，柳腰的位置比常人高，\n窈窕的曲线就这么延伸到修长的双腿。直到有一天....|r",
        icon = "Ewl_Ryr_Shenhua"
      })
    end
  end,
  ["姬柊雪菜"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-姬柊雪菜"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFF6699FF高神之森的剑巫|r|cFF7DBEF1]|r" .. NameID[sy])
      u:setdata(str)
      u:reduceshw()
      SendMsgAll("|cFF3399FF狮子の神子たる高神の剣巫が愿い奉る。|r")
      u:adddivinity(2)
      u:playsound(Jianwu_1)
      u:addskill("A1OH")
      ac.wait(6500, function()
        u:addskill("A1OI")
        SendMsgAll("|cFF3399FF破魔の曙光、雪霞の神狼、钢の神威をもちて我に悪神百鬼を讨たせ给え！|r")
        u:effectadd("war3mapimported\\[ake]war3ake.com - 1709800651073528605518801.mdl")
      end)
      local zj = 0
      local gl = 0
      local ys = 0
      local jc = 0
      local fs = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -zj)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -gl)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * -ys)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jc)
        ChangeValue(Correction_Magic, sy, -fs)
        jc = 0.015 * u:getdata("雪菜-神气值")
        if IsTimeDay() then
          zj = 0
          gl = 0
          ys = 0
        else
          zj = 0.1
          gl = 0.05
          ys = 0.05
        end
        if u:getperhp() >= 30 then
          local hp = u:getmissperhp() / 100
          if u:hasdata("雪菜-第三眷兽") then
            jc = jc + 0.625 * hp
            zj = zj + 0.625 * hp
            fs = 0.625 * hp
          else
            jc = jc + 0.5 * hp
            zj = zj + 0.5 * hp
            fs = 0.5 * hp
          end
        else
          fs = 0
        end
        ChangeValue(Correction_Magic, sy, fs)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * jc)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * ys)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * gl)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * zj)
      end)
      ChangeValue(Correction_MHp, sy, 0.010000000000000002)
      ChangeValue(DamageSystem_Shjc, sy, 0.015)
      ChangeValue(HeroMenu_HpChange_MaxHp, sy, 1)
      ChangeValue(DamageSystem_EndSh, sy, 0.010000000000000002)
      u:changedata("闪避值", 10)
      ChangeValue(HeroMenu_Sbxs, sy, 0.04)
      u:addstexiao(str, "终结伤害计算效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if (tg:hasdata("雪菜-天使化") or tg:hasdata("雪菜-第六眷兽强化")) and tg:isnormal() then
          info.endup = info.endup + 0.25
        end
      end)
      u:setdata("雪菜-神气值", 0)
      ac.loop(40000, function(timer)
        u:changedata("雪菜-神气值", 1)
        if u:getdata("雪菜-神气值") >= 50 then
          u:setdata("雪菜-神气值", 50)
        end
        if u:hasdata("雪菜-天使化已发动") then
          timer:remove()
        end
      end)
      
      local function trg(args)
        if args.chat == "天使化" and u:getdata("雪菜-神气值") >= 50 and not u:hasdata("雪菜-天使化已发动") then
          SendMsgAll("|cFF3366FF『|r|cFF3669FF前|r|cFF396CFF辈|r|cFF3C6FFF，|r|cFF3F72FF接|r|cFF4275FF下|r|cFF4578FF来|r|cFF487BFF就|r|cFF4B7EFF是|r|cFF4E81FF我|r|cFF5184FF们|r|cFF5487FF的|r|cFF578AFF战|r|cFF5A8DFF斗|r|cFF5D90FF了|r|cFF6093FF』|r")
          u:setdata("雪菜-天使化已发动")
          u:setdata("雪菜-天使化")
          ChangeValue(DamageSystem_Shjc, sy, 0.04)
          local dx, dy = u:getxy()
          Effectcreate("Tx_Jzxc_Tsh1.mdx", dx, dy)
          Effectcreate("Tx_Jzxc_Tsh2.mdx", dx, dy)
          u:effectadd("Tx_Jzxc_Tshcb.mdx", "chest", 30)
          u:effectadd("Tx_Jzxc_Tshcx.mdx", "origin", 30)
          ac.wait(30000, function()
            u:setdata("雪菜-神气值", 0)
            u:setdata("雪菜-第三眷兽")
            u:deldata("雪菜-天使化")
            ChangeValue(DamageSystem_Shjc, sy, -0.04)
            ChangeValue(DamageSystem_Shjc, sy, 0.004)
            ChangeValue(DamageSystem_EndSh, sy, 0.0025000000000000005)
            ChangeValue(HeroMenu_HpChange_MaxHp, sy, 0.25)
            local dskill = S2ID("A1OG")
            u:byladdskill(dskill, function(args)
              if args.skill == dskill then
                local b = true
                local ewl = getunit(args.unit)
                if not u:isalive() then
                  b = false
                  u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
                end
                if b then
                  local x, y = u:getxy()
                  local jd = u:getface()
                  local g = CreateGroupLua()
                  PlayGlobalSound(lszsy_yx3)
                  PlayGlobalSound(Sound_Jtxc_01)
                  u:buffset(u.handle, 3, "暂停")
                  u:buffset(u.handle, 3, "绝对闪避")
                  ac.wait(500, function()
                    CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.3, "ReplaceableTextures\\CameraMasks\\DreamFilter_Mask.blp", 25.0, 0, 0, 0)
                    u:shockcamera(15, 0.5)
                  end)
                  ac.wait(1500, function()
                    PlayGlobalSound(lszsy_yx2)
                    CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.5, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0, 0, 0)
                    u:shockcamera(300, 0.15)
                    Effectcreate("war3mapImported\\lszsy_dizhen.mdx", x, y, 5.5, 2, 10, jd)
                    Effectcreate("war3mapImported\\lszsy_bodong.mdx", x, y, 3.5, 1, 10, jd)
                    Effectcreate("war3mapImported\\lszsy_heidong.mdx", x, y, 4.5, 10, -200, jd)
                    Effectcreate("war3mapImported\\lszsy_heidong.mdx", x, y, 4.5, 10, -400, jd)
                    for _, xq in ac.selector():in_rangexy(dx, dy, 800):ipairs() do
                      xq = getunit(xq)
                      xq:groupadd(g)
                      ShowUnit(xq.handle, false)
                    end
                  end)
                  ac.wait(6500, function()
                    PlayGlobalSound(lszsy_yx1)
                    CinematicFadeBJ(bj_CINEFADETYPE_FADEOUTIN, 0.5, "ReplaceableTextures\\CameraMasks\\White_mask.blp", 100.0, 0, 0, 0)
                    u:shockcamera(300)
                    ac.wait(150, function()
                      u:shockcamera(50, 0.7)
                    end)
                    Effectcreate("war3mapImported\\lszsy_bo.mdx", x, y, 0.7, 1, 0, jd)
                    Effectcreate("war3mapImported\\lszsy_dizhen.mdx", x, y, 1, 2, 10, jd)
                    Effectcreate("war3mapImported\\lszsy_dizhen.mdx", x, y, 1, 4, 10, jd)
                    Effectcreate("war3mapImported\\lszsy_dizhen.mdx", x, y, 1, 4, 10, jd)
                    ForGroupLuaNew(g, function(xq)
                      ShowUnit(xq.handle, true)
                      xq:select()
                      if xq:is_enemy(u.handle) and xq:isnormal() then
                        xq:kill(u.handle, true)
                      end
                    end)
                  end)
                else
                  ewl:setskillcd(dskill, 1)
                end
              end
            end)
          end)
          PlayBGM({
            bgm = BGM_Jianwu_1,
            time = 100,
            ID = 33,
            unit = u.handle
          })
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        trg(args)
      end)
      u:uivar_change({
        keyname = "见习剑巫",
        keytype = "传奇栏",
        text = "|cFF3333FF狮子王|r|cFF3D47FF机关|r|cFF475CFF见习|r|cFF5270FF剑巫|r\n|cFF3333FF神性 2\n光明 魔导\n见习剑巫|r\n|cFF475CFF[数据删除]|r\n|cFF3333FF未来视|r\n|cFF475CFF[数据删除]|r\n|cFF3333FF八雷神法|r\n|cFF475CFF[数据删除]|r\n|cFF3333FF血之伴侣|r\n|cFF475CFF[数据删除]|r\n|cFF3333FF天使化|r\n|cFF475CFF[数据删除]|r",
        icon = "war3mapImported\\BTNEwl_Jianwu_1.blp",
        isclearclick = true
      })
    end
  end,
  ["安吉拉神化"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-安吉拉神化"
    if not u:hasdata(str) then
      NameID[sy] = "|cFF8BB8CB安|r|cFFA8CAD8吉|r|cFFC5DCE5拉|r"
      u:setplayername(NameID[sy])
      u:setdata(str)
      u:reduceshw()
      PlayGlobalSound(Sound_Angela_S01)
      local str = "『尽管仍不算完美，但这是不争的事实。』"
      str = ColorfulMsg(str, {
        "|cFF8BB8CB",
        "|cFFA8CAD8",
        "|cFFC5DCE5"
      })
      SendMsgAll(str)
      ac.wait(3000, function()
        local str = "『在这段旅程的终点，我也许能成为一名真正的人类。』"
        str = ColorfulMsg(str, {
          "|cFF8BB8CB",
          "|cFFA8CAD8",
          "|cFFC5DCE5"
        })
        SendMsgAll(str)
      end)
      ac.wait(8200, function()
        local str = "『成为人类的话，就能轻易忘记许多事情了吧？』"
        str = ColorfulMsg(str, {
          "|cFF8BB8CB",
          "|cFFA8CAD8",
          "|cFFC5DCE5"
        })
        SendMsgAll(str)
      end)
      ac.wait(12000, function()
        local str = "『能从淹没我的记忆洪流中解脱...』"
        str = ColorfulMsg(str, {
          "|cFF8BB8CB",
          "|cFFA8CAD8",
          "|cFFC5DCE5"
        })
        SendMsgAll(str)
      end)
      ac.wait(14000, function()
        PlayGlobalSound(BGM_Angela_Shenhua_01)
      end)
      PlayBGM({
        bgm = 0,
        time = 254,
        ID = 179,
        unit = u.handle
      })
      local cs = 0
      local gs = 0
      local endsh = 0
      local js = 0
      u:addhealthrefresh(function(set_value, bs)
        local value = 0
        if 2 <= cs then
          value = 0.05 * u:getdata("安吉拉-邀请函完成次数")
        end
        if u:hasdata("安吉拉-语言层") then
          value = value + 2 * bs
        end
        set_value(DamageSystem_Shjc, sy, 0.1 * value)
      end)
      ac.loop(1000, function()
        if u:hasdata("安吉拉-社会层") then
          if u:isalive() then
            js = js + 1
          end
          if js == 60 then
            js = 0
            u:additem("I05G", GetRandomInt(1, 3))
          end
        end
        if 0 < u:getdata("战斗时间") then
          cs = cs + 1
          if 10 <= cs then
            cs = 10
          end
        else
          cs = cs - 1
          if cs <= 0 then
            cs = 0
          end
        end
        if 4 <= cs then
          u:setdata("安吉拉-情感等级2")
        else
          u:deldata("安吉拉-情感等级2")
        end
        u:changedata("固定伤害", 0.1 * -gs)
        if 6 <= cs then
          gs = 10 * u:getdata("魔力值")
        else
          gs = 0
        end
        u:changedata("固定伤害", 0.1 * gs)
        if 8 <= cs then
          u:setdata("安吉拉-情感等级4")
        else
          u:deldata("安吉拉-情感等级4")
        end
        if 10 <= cs then
          if not u:hasdata("情感等级5-增强") then
            u:setdata("情感等级5-增强")
            endsh = 0.01 * u:getdata("安吉拉-邀请函完成次数")
            ChangeValue(DamageSystem_EndSh, sy, 0.1 * endsh)
          end
        elseif u:hasdata("情感等级5-增强") then
          u:deldata("情感等级5-增强")
          ChangeValue(DamageSystem_EndSh, sy, 0.1 * -endsh)
        end
      end)
      u:addstexiao(str, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("安吉拉-情感等级4") and u:getluckrandom(10 * info.txgl) and not u:hasdata(str .. "-特效冷却") then
          local txsh = info.yssh
          u:settimedata(str .. "-特效冷却", 1.5)
          DamageUnit({
            bj = "安吉拉附伤",
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
      u:changedata("机械变异数量", 1)
      ChangeValue(HeroMenu_HpForever_MaxHp, sy, 1)
      ChangeValue(DamageSystem_Baoji, sy, 15)
      ChangeValue(DamageSystem_Baoshang, sy, 0.3)
      u:uivar_change({
        keyname = "安吉拉初始",
        keytype = "传奇栏",
        text = "|cFF8BB8CB安|r|cFFA8CAD8吉|r|cFFC5DCE5拉|r\n|cFF8BB8CB尽管仍不算完美，但这是不争的事实。|r\n|cFF7393A7在这段旅程的终点，我也许能成为一名真正的人类。|r\n|cFF678095成为人类的话，就能轻易忘记许多事情了吧？|r\n|cFF5C6E84能从淹没我的记忆洪流中解脱...|r",
        icon = "Angela_Shenhua_01_1",
        isclearclick = true
      })
    end
  end,
  ["纳西妲神化"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-纳西妲神化"
    if not u:hasdata(str) then
      NameID[sy] = "|cFF66FF99纳|r|cFF8CFFB2西|r|cFFB2FFCC妲|r"
      u:setplayername(NameID[sy])
      u:setdata(str)
      u:reduceshw()
      PlayBGM({
        bgm = BGM_Naxida_01,
        time = 140,
        ID = 177,
        unit = u.handle
      })
      ac.wait(4900, function()
        local str = "『藏好了吗？』"
        str = ColorfulMsg(str, {
          "|cFF66FF99",
          "|cFF99FF99",
          "|cFFCCFF99",
          "|cFFCCFFCC",
          "|cFF66FF66"
        })
        SendMsgAll(str)
      end)
      ac.wait(8200, function()
        local str = "『3~』"
        str = ColorfulMsg(str, {
          "|cFF66FF99",
          "|cFF99FF99",
          "|cFFCCFF99",
          "|cFFCCFFCC",
          "|cFF66FF66"
        })
        SendMsgAll(str)
      end)
      ac.wait(10300, function()
        local str = "『2~』"
        str = ColorfulMsg(str, {
          "|cFF66FF99",
          "|cFF99FF99",
          "|cFFCCFF99",
          "|cFFCCFFCC",
          "|cFF66FF66"
        })
        SendMsgAll(str)
      end)
      ac.wait(12300, function()
        local str = "『1~』"
        str = ColorfulMsg(str, {
          "|cFF66FF99",
          "|cFF99FF99",
          "|cFFCCFF99",
          "|cFFCCFFCC",
          "|cFF66FF66"
        })
        SendMsgAll(str)
      end)
      ac.wait(25800, function()
        flashphoto({
          photo = "Ph_Naxida_01.tga",
          timeout = 2,
          timehold = 2,
          timein = 2
        })
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:buffset(u.handle, 6, "绝对闪避")
        end)
      end)
      ac.wait(26300, function()
        local str = "『好像...还有新朋友呢』"
        str = ColorfulMsg(str, {
          "|cFF66FF99",
          "|cFF99FF99",
          "|cFFCCFF99",
          "|cFFCCFFCC",
          "|cFF66FF66"
        })
        SendMsgAll(str)
      end)
      u:adddivinity(1)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 100)
      u:addskill("A0AE")
      if not u:hasdata("角色语音") then
        local snd = Sound_Naxida_Day_01
        SetData(snd, "绑定台词", "不知道干什么的话，要不要我带你去转转呀？")
        SetData(snd, "语音长度", 4)
        local snd = Sound_Naxida_Day_02
        SetData(snd, "绑定台词", "又有心事吗？我来陪你一起想吧")
        SetData(snd, "语音长度", 5)
        local snd = Sound_Naxida_Day_03
        SetData(snd, "绑定台词", "果然要亲眼去看，才能感受到世界的美。")
        SetData(snd, "语音长度", 5)
        local snd = Sound_Naxida_MedUse
        SetData(snd, "绑定台词", "变聪明啦~")
        SetData(snd, "语音长度", 1)
        local snd = Sound_Naxida_Attack_01
        SetData(snd, "绑定台词", "记住你啦~")
        SetData(snd, "语音长度", 1)
        local snd = Sound_Naxida_Attack_02
        SetData(snd, "绑定台词", "嘿！~")
        SetData(snd, "语音长度", 1)
        local snd = Sound_Naxida_Attack_03
        SetData(snd, "绑定台词", "全都看见咯。")
        SetData(snd, "语音长度", 2)
        local snd = Sound_Naxida_GetSpe
        SetData(snd, "绑定台词", "有你想要的吗？")
        SetData(snd, "语音长度", 2)
        local snd = Sound_Naxida_Injure
        SetData(snd, "绑定台词", "好疼啊…")
        SetData(snd, "语音长度", 1.5)
        local snd = Sound_Naxida_Death
        SetData(snd, "绑定台词", "生命…终有尽时…")
        SetData(snd, "语音长度", 3.5)
        u:setdata("角色语音", "纳西妲")
        u:addtrgevent("玩家-选择单位", function(args)
          if not u:hasdata("语音播放冷却") and GetRandom100(10) then
            u:settimedata("语音播放冷却", 20)
            local yxz = {
              Sound_Naxida_Day_01,
              Sound_Naxida_Day_02,
              Sound_Naxida_Day_03
            }
            local count = GetRandomInt(1, #yxz)
            local snd = yxz[count]
            u:playsndmsg({
              str = GetData(snd, "绑定台词"),
              snd = snd,
              time = GetData(snd, "语音长度"),
              colors = {
                "66FF99",
                "99FF99",
                "CCFF99",
                "CCFFCC",
                "66FF66"
              },
              isneedseen = true,
              image = "ChatIcon_Naxida.tga"
            })
          end
        end)
      end
      ac.loop(10000, function()
        if u:isalive() then
          local x, y = u:getxy()
          for _, xq in ac.selector():in_rangexy(x, y, 1000):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:changetimedata("怪物-额外受伤", 0.2, 10)
            xq:effectadd("Naxida_05.mdx", "origin", 10)
          end
        end
      end)
      u:addstexiao(str, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if tg:hasdata("纳西妲-虚空终端破抗") or tg:hasdata("纳西妲-无视抗性") then
          info.wssb = true
          info.wsmy = true
        end
      end)
      local cs = 0
      ac.loop(1000, function(t)
        if u:isalive() then
          u:changedata("纳西妲-未受伤时间", -1)
          local x, y = u:getxy()
          local g = CreateGroupLua()
          for _, xq in ac.selector():in_rangexy(x, y, 1000):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:groupadd(g)
          end
          if Group_Counts(g) > 0 then
            local tg = Group_Randomunit(g)
            local angle = AngleBetweenUnits(u.handle, tg.handle)
            unifycreate({
              owner = u.handle,
              model = "Naxida_06.mdx",
              modelname = "虚空终端弹幕",
              modelsize = 2,
              height = 90,
              damage = 0,
              damagetype = 1,
              x = x,
              y = y,
              range = 2000,
              speed = 3000,
              volume = 90,
              angle = angle,
              angleoffset = 0,
              attenua = 1,
              attenuacount = 1,
              life = 10,
              isbullet = false,
              isvest = false,
              isignorearmor = false,
              startfunc = function(mj)
                mj:setdata("循环计数", 0)
              end,
              loopfunc = function(mj)
                mj:changedata("循环计数", UnifyDT)
                if mj:getdata("循环计数") >= 0.03 then
                  mj:setdata("循环计数", 0)
                end
              end,
              hitfunc = function(mj, damage)
                return damage
              end,
              hitbeforefunc = function(mj, xq, damage2)
              end,
              hitafterfunc = function(mj, xq, damage2)
              end,
              endfunc = function(mj)
                local dx, dy = mj:getxy()
                Effectcreate("Objects\\Spawnmodels\\NightElf\\NEDeathMedium\\NEDeath.mdl", dx, dy)
                Effectcreate("Naxida_04.mdx", dx, dy)
                local txsh = 100000 + 200 * u:getallattri()
                for _, xq in ac.selector():in_rangexy(dx, dy, 300):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  if not xq:hasdata("纳西妲-虚空终端破抗") then
                    xq:setdata("纳西妲-虚空终端破抗")
                    xq:effectadd("Naxida_05.mdx", "origin", -1)
                  end
                  DamageUnit({
                    bj = "纳西妲虚空终端附伤",
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
                end
              end
            })
          end
        end
        if u:getdata("纳西妲-未受伤时间") <= 0 and not u:hasdata("纳西妲-护盾值") then
          local hd = 0.3 * u:getmaxhp()
          u:setdata("纳西妲-护盾值", hd)
          Hdzflash(u)
        else
          u:setdata("纳西妲-未受伤时间", 60)
        end
      end)
      u:uivar_change({
        keyname = "纳西妲",
        keytype = "传奇栏",
        text = "|cFF66FF99纳|r|cFF8CFFB2西|r|cFFB2FFCC妲|r\n|cFF66FF99神性 2\n唯一 自然 光明 风\n【行相】|r\n|cFFB2FFCC直接伤害时10%附带风魔力伤害,冷却1秒;触发时10%附带四段,冷却5秒\n提升[2%*主变异数量]伤害加成\n提升[2%*主变异数量]风属性伤害\n提升10%风属性伤害(独立)\n无属性伤害转换为风伤害|r\n|cFF66FF99【净善摄受明论】|r\n|cFFB2FFCC升级时提升5点全属性\n提升20%经验获取\n杀敌时提升0.005%伤害加成与0.05%风属性伤害|r\n|cFF66FF99【诸相随念净行】|r\n|cFFB2FFCC提升[2.5%*(自然变异+风变异)]伤害加成\n替换F技能|r\n|cFF66FF99【熏习成就之芽】|r\n|cFFB2FFCC提升100额外移速\n飞行|r\n|cFF66FF99【慧明绝缘智论】|r\n|cFFB2FFCC每10秒使周围1000范围敌军在10秒内提升20%额外受伤|r\n|cFF66FF99【心识蕴藏之种】|r\n|cFFB2FFCC提升自身与1000范围友军1%永恒恢复与25%移速|r\n|cFF66FF99【正等善见之根】|r\n|cFFB2FFCC根据生命值提供护盾,破碎后60秒复原|r\n|cFF66FF99【虚空终端】|r\n|cFFB2FFCC每隔一段时间射击1000范围内随机单位附带风魔力伤害,自身无视命中单位的伤害抗性|r",
        icon = "Ewl_Naxida_11_10",
        isclearclick = true
      })
    end
  end,
  ["只狼"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-只狼"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r只狼|cFF7DBEF1]|r" .. NameID[sy])
      u:setdata(str)
      u:reduceshw()
      u:sendmessage("|cFFFFFF00狼，和我的血一起活下去吧……|r")
      local add = u:getdata("只狼-杀敌计数")
      local add1 = add * 5.0E-4
      local add2 = add * 0.001
      ChangeValue(DamageSystem_Shjc, sy, 0.1 * add1)
      ChangeValue(Correction_Jzsh, sy, 0.1 * add2)
      u:deldata("只狼-杀敌计数")
      u:addstexiao(str, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:ispozhao() then
          info.end4 = info.end4 + 0.12
        end
      end)
      u:deldata("诅咒-灵体化")
      u:uivar_remove("灵体化", "传奇栏")
      ac.loop(1000, function(timer)
        if u:getmaxhp() <= 200 then
          u:addskill("A0HS")
          u:setdata("龙胤回光返照")
          timer:remove()
        end
      end)
      u:addskill("A0HP")
      u:setskillforever("A0HO")
      u:banskill("A0HP")
      
      local function skill(args)
        if args.skill == S2ID("A0HO") then
          local b = true
          local dskill = args.skill
          if u:hasdata("只狼-不死斩冷却") then
            b = false
            u:sendmessage("|cFF7DBEF1冷却中|r")
          end
          if b then
            local x, y = u:getxy()
            local x2 = args.x
            local y2 = args.y
            local angle = AngleXY(x, y, x2, y2)
            u:setface(angle)
            u:settimedata("只狼-不死斩冷却", 60)
            angle = angle - 130
            local g = CreateGroupLua()
            local cs = 0
            local txsh = 1000 * u:getlevel()
            ac.loop(20, function(timer)
              cs = cs + 1
              angle = angle + 10
              for i = 1, 5 do
                local x3, y3 = PolarXY(x, y, 200 * i, angle)
                Effectcreate("war3mapImported\\explotion_red.mdx", x3, y3)
                Effectcreate("war3mapImported\\shinratensei.mdx", x3, y3)
                for _, xq in ac.selector():in_rangexy(x3, y3, 325):is_enemy(u.handle):isnotingroup(g):ipairs() do
                  xq = getunit(xq)
                  local txsh2
                  if xq:isboss() then
                    txsh2 = txsh + 0.0025 * xq:getmaxhp()
                  else
                    txsh2 = txsh + 0.5 * xq:getmaxhp()
                  end
                  xq:banrelive()
                  if xq.handle == BOSS_Pj and 5 >= xq:getperhp() then
                    MovieAct["不死斩"](u, xq)
                  else
                    DamageUnit({
                      bj = "不死斩",
                      unit = xq.handle,
                      source = u.handle,
                      damage = txsh2,
                      level = 4,
                      type = "物理",
                      isvest = false,
                      isattack = false,
                      isnoarmor = false,
                      element = "无"
                    })
                  end
                  xq:effectadd("war3mapImported\\Texiao_Xuebao.mdx")
                  xq:effectadd("Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl")
                  xq:groupadd(g)
                  xq:groupadd(HpGroup)
                  xq:buffset(u.handle, 3, "暂停")
                  xq:settimedata("只狼-不死斩完全抑制", 10)
                  xq:setdata("只狼-不死斩抗性破坏")
                  xq:setdata("破坏-伤害抗性")
                end
              end
              if cs == 24 then
                timer:remove()
              end
            end)
          else
            u:setskillcd(dskill, 1)
          end
        end
      end
      
      u:addtrgevent("单位-发动技能", function(args)
        skill(args)
      end)
      ac.loop(1000, function()
        local count = 0
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq:isalive() then
            count = count + 1
          end
        end)
        if u:isalive() and count <= 1 then
          if not u:hasdata("只狼-独行效果") then
            ChangeValue(DamageSystem_EndSh, sy, 0.018)
            u:setdata("只狼-独行效果")
            u:addskill("S0AP")
          end
        elseif u:hasdata("只狼-独行效果") then
          ChangeValue(DamageSystem_EndSh, sy, -0.018)
          u:deldata("只狼-独行效果")
          u:delskill("S0AP")
          u:clearbuff("B0ES")
        end
      end)
      u:uivar_change({
        keyname = "狼",
        keytype = "传奇栏",
        text = "|cFFFFFF00龙胤忍者|r\n|cFF1FBF00战士 影\n龙咳|r\n|cFFFFFF00触发[龙胤]时对随机一名队友施加一层龙咳,每层增加8%额外受伤;达到五层时即死目标并清空层数|r\n|cFF1FBF00忍杀|r\n|cFFFFFF00对[僵直、暂停、眩晕]中普通单位造成伤害时,提升[目标100%最大生命值]固定伤害,触发冷却0.5秒|r\n|cFF1FBF00战斗记忆|r\n|cFFFFFF00杀敌时提升0.001%近战伤害和伤害加成\n杀死BOSS时提升5%伤害加成|r\n|cFF1FBF00不死斩|r\n|cFFFFFF00解锁[不死斩]|r\n|cFF1FBF00龙胤|r\n|cFFFFFF00死亡时立即复活并降低(100+8%)生命上限;生命上限不足200时失效|r\n|cFF1FBF00衡势|r\n|cFFFFFF00直接伤害时对目标叠加破势;达到100%时清空累积值,暂停目标单位并破坏抗性3(10)秒\n对破招中单位提升12%伤害|r\n|cFF1FBF00只狼|r\n|cFFFFFF00仅自身存活时极速并提升1.8%终结伤害|r\n|cFF949596既非今日，人亦非彼。|r",
        icon = "war3mapImported\\BTNEwl_Zhilang_Tubiao",
        isclearclick = true
      })
    end
  end,
  ["露娜神化"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-露娜神化"
    if not u:hasdata(str) then
      NameID[sy] = "|cFFFFCCFF樱|r|cFFF6D4FF小|r|cFFEEDDFF路|r|cFFE6E6FFル|r|cFFDDEEFFナ|r"
      u:setplayername(NameID[sy])
      u:setdata(str)
      u:reduceshw()
      PlayBGM({
        bgm = BGM_Luna_Shenhua,
        time = 330,
        ID = 170,
        unit = u.handle
      })
      SendMsgAll("|cFFFFCCFF樱|r|cFFFFCFFC小|r|cFFFFD1FA路|r|cFFFFD4F7ル|r|cFFFFD6F5ナ:|cFFFFCCFF好|r|cFFFFC2F3可|r|cFFFFB9E7怕|r|cFFFFAFDB，|r|cFFFFA5CE信|r|cFFFF9BC2任|r|cFFFF92B6了|r|cFFFF88AA你|r|cFFFF7E9E的|r|cFFFF7592自|r|cFFFF6B86己|r|cFFFF6179，|r|cFFFF576D从|r|cFFFF4E61心|r|cFFFF4455里|r|cFFFF3A49感|r|cFFFF313D到|r|cFFFF2731害|r|cFFFF1D24怕|r|cFFFF1318。|r", 10)
      ac.wait(10000, function()
        SendMsgAll("|cFFFFCCFF樱|r|cFFFFCFFC小|r|cFFFFD1FA路|r|cFFFFD4F7ル|r|cFFFFD6F5ナ:|cFFFFCCFF所|r|cFFFFC4F4以|r|cFFFFBBEA我|r|cFFFFB2DF祈|r|cFFFFAAD4祷|r|cFFFFA2CA你|r|cFFFF99BF背|r|cFFFF90B5叛|r|cFFFF88AA我|r|cFFFF809F一|r|cFFFF7795次|r|cFFFF6E8A，|r|cFFFF6680然|r|cFFFF5E75后|r|cFFFF556A一|r|cFFFF4C60次|r|cFFFF4455又|r|cFFFF3C4A一|r|cFFFF3340次|r|cFFFF2A35的|r|cFFFF222A确|r|cFFFF1A20认|r|cFFFF1115着|r", 10)
      end)
      ac.wait(18000, function()
        SendMsgAll("|cFFFFCCFF樱|r|cFFFFCFFC小|r|cFFFFD1FA路|r|cFFFFD4F7ル|r|cFFFFD6F5ナ:|cFFFFCCFF我|r|cFFFFC5F6以|r|cFFFFBEEE前|r|cFFFFB8E6打|r|cFFFFB1DD算|r|cFFFFAAD4再|r|cFFFFA3CC也|r|cFFFF9CC4不|r|cFFFF96BB信|r|cFFFF8FB2任|r|cFFFF88AA任|r|cFFFF81A2何|r|cFFFF7A99人|r|cFFFF7490，|r|cFFFF6D88打|r|cFFFF6680算|r|cFFFF5F77从|r|cFFFF586E今|r|cFFFF5266以|r|cFFFF4B5E后|r|cFFFF4455永|r|cFFFF3D4C远|r|cFFFF3644一|r|cFFFF303C个|r|cFFFF2933人|r|cFFFF222A生|r|cFFFF1B22活|r|cFFFF141A下|r|cFFFF0E11去|r", 10)
      end)
      ac.wait(29000, function()
        SendMsgAll("|cFFFFCCFF樱|r|cFFFFCFFC小|r|cFFFFD1FA路|r|cFFFFD4F7ル|r|cFFFFD6F5ナ:|cFFFF0066再|r|cFFFF1072也|r|cFFFF1F7E不|r|cFFFF2F89想|r|cFFFF3F95被|r|cFFFF4EA1人|r|cFFFF5EAD背|r|cFFFF6EB8叛|r|cFFFF7EC4了|r|cFFFF8DD0，|r|cFFFF9DDC但|r|cFFFFADE7是|r", 10)
      end)
      ac.wait(33000, function()
        SendMsgAll("|cFFFFCCFF樱|r|cFFFFCFFC小|r|cFFFFD1FA路|r|cFFFFD4F7ル|r|cFFFFD6F5ナ:|cFFFF0066如|r|cFFFF076B果|r|cFFFF0D70连|r|cFFFF1475至|r|cFFFF1A7A今|r|cFFFF217F为|r|cFFFF2784止|r|cFFFF2E89都|r|cFFFF358D在|r|cFFFF3B92为|r|cFFFF4297我|r|cFFFF489C尽|r|cFFFF4FA1忠|r|cFFFF56A6的|r|cFFFF5CAB你|r|cFFFF63B0都|r|cFFFF69B5不|r|cFFFF70BA相|r|cFFFF76BF信|r|cFFFF7DC4，|r|cFFFF84C9那|r|cFFFF8ACE我|r|cFFFF91D3就|r|cFFFF97D8是|r|cFFFF9EDC最|r|cFFFFA5E1差|r|cFFFFABE6劲|r|cFFFFB2EB的|r|cFFFFB8F0人|r|cFFFFBFF5了|r", 10)
      end)
      ac.wait(43000, function()
        SendMsgAll("|cFFFFCCFF樱|r|cFFFFCFFC小|r|cFFFFD1FA路|r|cFFFFD4F7ル|r|cFFFFD6F5ナ:|cFFFF0066谢|r|cFFFF0B6E谢|r|cFFFF1777你|r|cFFFF2280来|r|cFFFF2D88这|r|cFFFF3990里|r|cFFFF4499，|r|cFFFF4FA2如|r|cFFFF5BAA果|r|cFFFF66B2没|r|cFFFF71BB有|r|cFFFF7DC4对|r|cFFFF88CC我|r|cFFFF93D4说|r|cFFFF9FDD这|r|cFFFFAAE6些|r|cFFFFB5EE话|r", 10)
      end)
      ac.wait(48000, function()
        flashphoto({
          photo = "Ph_Luna.tga",
          timeout = 4,
          timehold = 4,
          timein = 4
        })
        ForGroupLuaNew(Group_PlayHero, function(xq)
          xq:buffset(u.handle, 12, "绝对闪避")
        end)
        SendMsgAll("|cFFFFCCFF樱|r|cFFFFCFFC小|r|cFFFFD1FA路|r|cFFFFD4F7ル|r|cFFFFD6F5ナ:|cFFFF0066我|r|cFFFF086C也|r|cFFFF1173不|r|cFFFF1A79会|r|cFFFF2280再|r|cFFFF2A86相|r|cFFFF338C信|r|cFFFF3C93你|r|cFFFF4499，|r|cFFFF4C9F很|r|cFFFF55A6快|r|cFFFF5EAC就|r|cFFFF66B2会|r|cFFFF6EB9沦|r|cFFFF77BF落|r|cFFFF80C6为|r|cFFFF88CC轻|r|cFFFF90D2蔑|r|cFFFF99D9别|r|cFFFFA2DF人|r|cFFFFAAE6的|r|cFFFFB2EC人|r|cFFFFBBF2了|r", 10)
      end)
      ac.wait(325000, function()
        PlayGlobalSound(Sound_Luna_01)
        SendMsgAll("|cFFFFCCD3「樱|r|cFFFFCCD7小|r|cFFFFCCDB路|r|cFFFFCCDE家|r|cFFFFCCE2的|r|cFFFFCCE5小|r|cFFFFCCE9女|r|cFFFFCCF0 |r|cFFFFCCF4露|r|cFFFFCCF8娜」|r")
        ac.wait(4000, function()
          SendMsgAll("|cFFFFCCCC「梦|r|cFFFFCCD1想|r|cFFFFCCD5是|r|cFFFFCCDA成|r|cFFFFCCDF为|r|cFFFFCCE3一|r|cFFFFCCE8名|r|cFFFFCCEC设|r|cFFFFCCF1计|r|cFFFFCCF6师」|r")
        end)
        ac.wait(7000, function()
          SendMsgAll("|cFFFFCCCC「对|r|cFFFFCCD0服|r|cFFFFCCD3饰|r|cFFFFCCD7之|r|cFFFFCCDB外|r|cFFFFCCDE的|r|cFFFFCCE2东|r|cFFFFCCE5西|r|cFFFFCCE9没|r|cFFFFCCED什|r|cFFFFCCF0么|r|cFFFFCCF4兴|r|cFFFFCCF8趣」|r")
        end)
        ac.wait(10000, function()
          SendMsgAll("|cFFFFCCFF「|r|cFFFFCFFC但|r|cFFFFD2F9最|r|cFFFFD5F6近|r|cFFFFD8F3觉|r|cFFFFDBF0得|r|cFFFFDEED沉|r|cFFFFE1EA迷|r|cFFFFE4E7于|r|cFFFFE7E4恋|r|cFFFFEAE1爱|r|cFFFFEDDE中|r|cFFFFF0DB也|r|cFFFFF3D8不|r|cFFFFF6D5错|r|cFFFFF9D2」|r")
        end)
      end)
      ChangeValue(Correction_Exp, sy, 0.1)
      ChangeValue(Correction_Gold, sy, 0.05)
      u:setdata("系统-无视伤害免疫")
      ac.loop(500, function()
        local x, y = u:getxy()
        Effectcreate("Sakura_04.mdx", x, y, 1, 1, 0, GetRandomAngle())
      end)
      u:addstexiao(str, "决死效果", function(args)
        if args.dt and not u:hasdata("露娜-决死冷却") then
          args.dt = false
          u:sendmessage("|cFFFF99FF露娜-Desire|r")
          u:settimedata("露娜-决死冷却", 232.7)
          u:buffset(u.handle, 3, "无敌")
          u:sethp(32.7, true)
        end
      end)
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(str .. "-特效冷却") and u:getluckrandom(32.7 * info.txgl) then
          local x, y = tg:getxy()
          u:settimedata(str .. "-特效冷却", 2)
          local txsh = 20 * u:getint() + 1000
          Effectcreate("Sakura_02.mdx", x, y, 0, 1, 0, GetRandomAngle())
          tg:effectadd("Sakura_01.mdx", "origin", 1)
          ac.timer(100, 10, function()
            DamageUnit({
              bj = "露娜神化附伤",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "灵力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
          end)
        end
      end)
      local cgl = 0
      local gl = 0
      ac.loop(1000, function()
        ChangeValue(Correction_MEDCgl, sy, -1 * cgl)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * gl))
        if IsTimeNight() then
          cgl = 0.2
          u:setdata("露娜-飞行")
        else
          cgl = 0
          u:deldata("露娜-飞行")
        end
        if u:hasdata("露娜-终焉樱解锁") then
          gl = 0.327 + 0.05 * u:getlevel()
        else
          gl = 0
        end
        ChangeValue(Correction_MEDCgl, sy, 1 * cgl)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * gl))
      end)
      u:addstexiao(str, "杀敌效果", function(args)
        local tg = args.tg
        ChangeValue(DamageSystem_Shjc, sy, 1.0E-4)
        ChangeValue(DamageSystem_Shjc, sy, 1.0E-4)
        if tg:isboss() then
          PlayGlobalSound(Sound_Luna_11)
          SendMsgAll("|cFFFFCCFF樱|r|cFFFFCFFC小|r|cFFFFD1FA路|r|cFFFFD4F7ル|r|cFFFFD6F5ナ|r|cFFFFD9F2『|r|cFFFFDBF0卯|r|cFFFFDEED衣|r|cFFFFE0EB』|r|cFFFFE3E8:|r|cFFFFE6E5最|r|cFFFFE8E3后|r|cFFFFEBE0胜|r|cFFFFEDDE利|r|cFFFFF0DB的|r|cFFFFF2D9只|r|cFFFFF5D6会|r|cFFFFF7D4是|r|cFFFFFAD1我|r")
          if u:getdata("露娜-BOSS杀敌数") < 3 then
            u:changedata("露娜-BOSS杀敌数", 1)
            ChangeValue(DamageSystem_Shjc, sy, 0.025)
            ChangeValue(DamageSystem_Shjc, sy, 0.025)
          end
        elseif tg:iselite() then
          ChangeValue(DamageSystem_Shjc, sy, 0.001)
          ChangeValue(DamageSystem_Shjc, sy, 0.001)
        end
      end)
      
      local function trg(args)
        if args.chat == "终焉樱" and u:isalive() and not u:hasdata("露娜-终焉樱解锁") then
          u:sendmessage("|cFFFF99FF终焉樱效果解锁|r")
          u:setdata("露娜-终焉樱解锁")
          u:addskill("S0AO")
          u:addstexiao(str, "位移技能后效果", function(args)
            if not u:hasdata("露娜-终焉樱") then
              u:settimedata("露娜-终焉樱", 1)
            end
          end)
          u:addtrgevent("单位-指定点目标指令", function(args)
            if args.orderid == String2OrderIdBJ("smart") and u:hasdata("露娜-终焉樱") then
              u:deldata("露娜-终焉樱")
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local angle = AngleXY(x, y, x2, y2)
              local dis = DistanceXY(x, y, x2, y2)
              local mjl = 800
              if dis >= mjl then
                dis = mjl
              end
              x2, y2 = PolarXY(x, y, dis, angle)
              if not IsXYinRect(x2, y2, RECT_PlayArea) then
                return
              end
              Effectcreate("Sakura_02.mdx", x, y)
              Effectcreate("war3mapImported\\blackblink.mdx", x, y)
              Effectcreate("war3mapImported\\blackblink.mdx", x2, y2)
              Effectcreate("Sakura_02.mdx", x2, y2)
              u:setxy(x2, y2)
              local txsh = 32.7 * u:getint()
              for _, xq in ac.selector():in_rangexy(x2, y2, 175):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                DamageUnit({
                  bj = "终焉樱附伤",
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
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        trg(args)
      end)
      u:uivar_change({
        keyname = "露娜",
        keytype = "传奇栏",
        text = "|cFFFFCCFF樱|r|cFFFFC4FF小|r|cFFFFBCFF路|r|cFFFFB4FFル|r|cFFFFADFFナ|r\n|cffacffffDesire\n[渴望身处耀眼未来的天空下]|r\n|cffe9c1ff月见樱\n[不纯洁的关系非我所求]|r\n|cfff2c4f7凄风乱樱|r\n[碎樱也好明月也好，请都来实现这份心愿吧]|r\n|cfffff195夜晚独自绽放的樱花\n[接下来就交给我吧]|r\n|cffff96ff终焉樱\n[向漫天的樱花许愿]\nXII XIII XIV|r\n|cffebddff露|cfff5ddff娜\n[近月少女的礼仪]|r\n|cffffbeff“只要有你在，无论前方有何险阻 无论将会失去什么,我也能够相信未来之路”|r",
        icon = "BTNEwl_Luna_Shenhua",
        isclearclick = true
      })
    end
  end,
  ["噩梦志贵"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-噩梦志贵"
    if not u:hasdata(str) then
      u:setdata(str)
      u:addstexiao(str, "怪物减伤计算", function(args)
        local info = args.damageinfo
        info.ewjs = 1
      end)
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(str .. "-特效冷却") then
          local gl = 7
          if u:hasdata("隐藏职业-天谴之子") then
            gl = gl * 2
          end
          if u:hasdata("瓦拉齐亚之夜-夜晚强化") then
            gl = gl * 2
          end
          if u:getluckrandom(gl) then
            u:settimedata(str .. "-特效冷却", 1.7)
            u:playsound(Sound_Katana_20)
            tg:buffset(u.handle, 0.3, "暂停")
            local angle = GetRandomAngle()
            local dis = GetRandomReal(600, 800)
            local x, y = u:getxy()
            local x2, y2 = tg:getxy()
            x, y = PolarXY(x2, y2, dis, angle + 180)
            local g2 = CreateGroupLua()
            for i = 1, 5 do
              local dmj = u:createunit("u09E", x, y, angle)
              ResetUnitAnimation(dmj.handle)
              dmj:animeact(16)
              dmj:animespeed(3)
              dmj:groupadd(g2)
              dmj:setcolor(255, 255, 255, 0)
              ac.wait(40, function()
                dmj:setcolor(255, 255, 255, 255)
              end)
            end
            PlayGlobalSound(Movie_Dream_46)
            local dcs = 0
            local dcs2 = 0
            local dxx = x
            local dyy = y
            ac.loop(10, function(dt2)
              dcs = dcs + 1
              dcs2 = dcs2 + 1
              dxx, dyy = PolarXY(dxx, dyy, dis / 60, angle)
              ForGroupLuaNew(g2, function(xq)
                xq:setxy(dxx, dyy)
              end)
              if dcs2 == 6 then
                dcs2 = 0
                local dmj = Group_Randomunit(g2)
                dmj:animespeed(0)
                dmj:groupremove(g2)
                local tm = 255
                ac.loop(10, function(dt)
                  tm = tm - 5.1000000000000005
                  dmj:setcolor(255, 255, 255, tm)
                  if tm <= 0 then
                    dmj:remove()
                    dt:remove()
                  end
                end)
              end
              if dcs == 30 then
                Effectcreate("BTX\\[BTxNew]zhanji-red.mdl", x2, y2, 0, 2, 0, angle)
                Effectcreate("ATX\\[ATxNew]Blood_04.mdl", x2, y2, 0, 3)
                PlayGlobalSound(Movie_Dream_48)
                tg:animeact("death")
                if tg:isnormal() then
                  tg:kill(u.handle, true)
                elseif tg:iselite() then
                  local down = tg:getmaxhp() / 77
                  tg:changemaxhp(-1 * down)
                  tg:losshp(u, 1 * down)
                else
                  local down = tg:getmaxhp() / 177
                  tg:changemaxhp(-1 * down)
                  LossHpUnit({
                    u = u,
                    tg = tg,
                    damage = down,
                    perhp = 0,
                    maxhp = 0,
                    bj = "[生命损耗]噩梦志贵"
                  })
                end
                ForGroupLuaNew(g2, function(xq)
                  xq:remove()
                end)
                dt2:remove()
              end
            end)
          end
        end
      end)
      u:deldata("变异判定-远野志贵")
      u:become("噩梦具现化")
      ChangeValue(DamageSystem_EndSh, sy, 0.014000000000000002)
      ChangeValue(DamageSystem_Shjc, sy, 0.144)
      ChangeValue(DamageSystem_Shjc, sy, 0.144)
      if u.type == HeroType["志贵"] then
        u:changedata("志贵-回路获取", 2)
        u:changedata("志贵-连击伤害获取", 2.5)
      end
      moveskillreplace({
        unit = u.handle,
        level = 1,
        skill_Q = "A0WF",
        skill_W = "A0WE",
        isforce = false,
        efunc = function()
          u:addtrgevent("单位-指定点目标指令", function(args)
            if args.orderid == String2OrderIdBJ("smart") and u:hasdata("闪走水月") then
              u:deldata("闪走水月")
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local angle = AngleXY(x, y, x2, y2)
              local dis = DistanceXY(x, y, x2, y2)
              local mjl = 700
              if dis >= mjl then
                dis = mjl
              end
              play_shadow_slow_series(u, {
                act = u:getdata("播放动作"),
                count = 1,
                interval = 0.01,
                main_speed = u:getdata("动画速度"),
                wait_time = 0,
                r = 255,
                g = 100,
                b = 100,
                fade_sub = 5,
                noact = true
              })
              Effectcreate("Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl", x, y)
              movexg(u.handle, 0.1, S2ID("A0EW"), "W", "七夜志贵-冲刺")
              u:setdata("刷新W时间", 0.1)
              unitmove({
                unit = u.handle,
                time = 0.1,
                distance = dis,
                angle = angle,
                isfly = true,
                endfunc = function(dx, dy)
                  u:setdata("位移点X", dx)
                  u:setdata("位移点Y", dy)
                end,
                isblink = true
              })
            end
          end)
        end
      })
      u:uivar_change({
        keyname = "退魔眼",
        keytype = "传奇栏",
        text = "|cFF003399噩梦|r|cFF990000志贵|r\n|cFF003399死眼杀.改|r\n|cFF990000改变冲刺与后撤\n降低50%位移技能冷却\n无视伤害闪避与伤害免疫\n无视大部分精英特性\n无视常规伤害减免\n伤害加成提升144%\n终结伤害提升2.8%|r\n|cFF003399七之解|r\n|cFF990000直接伤害时7%损耗目标1/77(1/177)当前生命值并降低等额生命上限，\n超即死普通单位(触发冷却1.7秒)|r\n|cFF003399极死.狱沙门|r\n|cFF990000[数据删除]|r\n|cFF949596远野梦境中的杀人鬼，已经逝去了。\n噩梦也已经终结，\n但这已经死去的杀人鬼人格已经在远野灵魂深处留下了无法磨灭的痕迹，\n包括这位杀人鬼那可有可无的温柔。|r",
        icon = "NewIcon_Emzg",
        ishasphoto = true
      })
    end
  end,
  ["根源式"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-根源式"
    if not u:hasdata(str) then
      u:setdata(str)
      ChatIcon[sy] = "Chat_215.blp"
      u:adddivinity(4)
      ChangeValue(DamageSystem_Baoshang, sy, -0.25)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        local sy2 = xq.ownerid
        ChangeValue(DamageSystem_Shjc, sy2, 0.1)
        ChangeValue(DamageSystem_EndSh, sy2, 0.010000000000000002)
      end)
      u:addstexiao(str, "直接伤害变更", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if info.level <= 5 then
          info.level = 5
        end
      end)
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata("根源式-矛盾螺旋冷却") then
          u:settimedata("根源式-矛盾螺旋冷却", 0.1)
          ChangeTimeValue(DamageSystem_Baoshang, sy, 0.05, 9)
        end
      end)
      u:addstexiao(str, "暴击系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        info.bjl = info.bjl * 2
      end)
      u:getgoddessforce(2, true)
      ChangeValue(Hero_Tili_Huifu, sy, 0.5)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 100)
      ChangeValue(DamageSystem_Shjc, sy, 0.1)
      local addh = 0
      local add = 0
      ac.loop(3000, function()
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, -addh)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -add)
        addh = 2.5 * Hero_Tili_Huifu[sy]
        add = 0.25 * u:getdata(u:returnmaxvar() .. "变异数量")
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, addh)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
      end)
      u:addskill("S07W")
      u:setdata("根源式-根源之涡次数", u:getdata("根源变异数量"))
      u:setdata("根源式-根源之涡触发次数", 0)
      u:addallstats(100 * u:getstate("根源变异"))
      ChangeValue(DamageSystem_Shjc, sy, 0.1 * (0.2 * Time_M))
      ac.loop(60000, function()
        u:sendmessage("|cFFFF99FF未来福音|r")
        u:effectadd("AATX\\[AATxNew]Pink24.mdl")
        u:addallstats(5 * u:getstate("根源变异"))
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (0.01 * Time_M))
      end)
      u:uivar_change({
        keyname = "两仪式净眼",
        keytype = "传奇栏",
        text = "|cFFFFCCFF根|r|cFFFFA6FF源|r|cFFFF80FF式|r\n|cFFFFA6FF神性 4\n概念斩断|r\n|cFFFF80FF暴击率翻倍\n提升50%当前暴击伤害\n所有直接伤害变为抹除伤害\n直接伤害时5%即死普通单位,1%即死精英单位\n直接伤害时削除5%(1%/0.5%)当前生命值,触发冷却0.5秒\n伤害结算后附带[原始伤害值*50%]生命损耗效果|r\n|cFFFFA6FF根源之涡|r\n|cFFFF80FF获得[根源变异数量*1]次复活\n每次消耗根源重生,降低对应根源变异数量,提升自身10%终结减伤,不会超过50%|r\n|cFFFFA6FF心空妙有|r\n|cFFFF80FF全队提升10%伤害加成与10%终结伤害\n所有玩家获得效果：\n受伤时抵挡该次伤害,独立冷却15秒|r\n|cFFFFA6FF俯瞰风景|r\n|cFFFF80FF绝对闪避成功时神降持续1秒(触发冷却3.0秒)\n提升[体力恢复*2.5%]永恒恢复与0.5体力恢复\n提升[10%+主变异*2.5%]伤害加成\n提升100额外移速|r\n|cFFFFA6FF矛盾螺旋|r\n|cFFFF80FF直接伤害时10%附带一次等额抹除灵力伤害\n直接伤害时在9秒内提升5%暴击伤害,冷却0.1秒 分立计时 可叠加|r\n|cFFFFA6FF空之境界|r\n|cFFFF80FF降低25%所受生命损耗\n免疫不超过自身生命上限的时限伤害\n自身受到的伤害不会超过伤害的原始值|r\n|cFFFFA6FF未来福音|r\n|cFFFF80FF获取时提升[根源变异*100]全属性与[游戏逝去分钟数*2%]伤害加成\n每60秒提升[根源变异*5]全属性与[游戏逝去分钟数*0.1%]伤害加成|r\n|cFF949596一切皆为梦——此乃余韵之花啊|r",
        icon = "NewIcon_215",
        ishasphoto = true
      })
    end
  end,
  ["两仪式"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-两仪式"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFF530080两仪式|r|cFF7DBEF1]|r" .. NameID[sy])
      u:setdata(str)
      u:reduceshw()
      PlayGlobalSound(Sound_214_33)
      PlayGlobalSound(SE052)
      u:chat("了结你")
      if not u:hasdata("两仪式彩蛋语音触发") then
        ac.wait(2500, function()
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if u.handle ~= xq.handle then
              if xq:hasdata("变异判定-远野志贵") and not xq:hasdata("两仪式彩蛋语音触发") then
                u:setdata("两仪式彩蛋语音触发")
                xq:setdata("两仪式彩蛋语音触发")
                PlayGlobalSound(Ryougi_S2AA023)
                u:chat("所以，这里是终点的话，你就是我的猎物了吧？")
                ac.wait(6000, function()
                  PlayGlobalSound(Ryougi_S2AA024)
                  xq:chat("要那样想也好。")
                  ac.wait(2100, function()
                    xq:chat("很赞同你所说的今夜是特殊的话。")
                  end)
                  ac.wait(6600, function()
                    xq:chat("你的那双眼睛——")
                  end)
                  ac.wait(8100, function()
                    xq:chat("就应该在这里干净地消失。")
                  end)
                end)
                ac.wait(18000, function()
                  PlayGlobalSound(Ryougi_S2AA025)
                  u:chat("哈，用这双眼看到还是第一次呢……")
                  ac.wait(4700, function()
                    u:chat("原来如此，的确这家伙有着魔性。")
                  end)
                  ac.wait(8900, function()
                    u:chat("那么——")
                  end)
                end)
                ac.wait(30000, function()
                  PlayGlobalSound(Ryougi_S2AA026)
                  xq:chat("我也有同样的感觉呢。")
                  ac.wait(2100, function()
                    xq:chat("这种玩意，就应该干干净净地——")
                  end)
                end)
                ac.wait(36000, function()
                  PlayGlobalSound(Ryougi_S2AA027)
                  u:chat("啊，干脆利落地杀掉才行啊——！")
                end)
              end
              if xq:hasdata("变异判定-七夜志贵") then
                PlayGlobalSound(Sound_214_31)
              end
            end
          end)
        end)
      end
      Weiyi[5] = true
      u:changedata("月姬变异数量", 1)
      u:groupadd(Group_Yueji)
      coopjudge("瓦拉齐亚之夜")
      PlayBGM({
        bgm = BGM_214_1,
        time = 140,
        ID = 64,
        unit = u.handle
      })
      if u.type == HeroType["两仪式"] then
        u:changedata("两仪式-回路获取", 1)
      end
      u:setdata("系统-无视伤害闪避")
      u:setdata("系统-无视伤害免疫")
      u:addstexiao(str, "伤害系统计算效果", function(args)
        local tg = args.tg
        local info = args.damageinfo
        local u = args.u
        if tg:hasdata("连携斩击叠加值") then
          info.zj = info.zj + tg:getdata("连携斩击叠加值") / 100
        end
      end)
      AddAllSTexiao(str, "伤害系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:hasdata("两仪式-死之线受伤") then
          info.ewss = info.ewss + tg:getdata("两仪式-死之线受伤")
        end
      end)
      u:addstexiao(str, "暴击系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:getluckrandom(50) then
          info.bjl = info.bjl + 50
        end
        if tg:hasdata("连携斩击叠加值") then
          info.bjl = info.bjl + tg:getdata("连携斩击叠加值")
          info.bjsh = info.bjsh + tg:getdata("连携斩击叠加值") / 100
        end
      end)
      u:addstexiao(str, "暴击系统触发效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not tg:hasdata("两仪式-死之线冷却") then
          tg:settimedata("两仪式-死之线冷却", 3)
          tg:changetimedata("两仪式-死之线受伤", 0.03, 10)
          local xs = 0.005
          if tg:isnormal() then
            xs = 0.25
          elseif u:iselite() then
            xs = 0.05
          end
          LossHpUnit({
            u = u,
            tg = tg,
            damage = 0,
            perhp = 0,
            maxhp = xs,
            bj = "[生命损耗]死之线"
          })
        end
      end)
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        if not tg:hasdata("连携斩击冷却") and not u:hasdata("变异判定-根源式") then
          tg:changetimedata("连携斩击叠加值", 3, 7)
          tg:settimedata("连携斩击冷却", 0.5)
        end
      end)
      
      local function chattrg(args)
        if (args.chat == "那么 请多关照" or args.chat == "Sate yoroshiku") and u:isalive() and not u:hasdata("两仪式-根源接续") then
          u:effectadd("Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosDone.mdl", "overhead")
          u:setdata("两仪式-根源接续")
          local jx = 0
          local cw = 0
          local t = 100
          ac.loop(t, function(timer)
            if u:isalive() then
              if u:getperhp() >= 1 and u:gethp() >= 100 then
                cw = cw + 1
              else
                jx = jx + 1
                cw = 0
              end
              if 30 <= cw then
                jx = 0
              end
              if 600 <= jx then
                u:setdata("根源接续")
              else
                u:deldata("根源接续")
              end
            end
            if not u:hasdata("两仪式-根源接续") then
              u:deldata("根源接续")
              timer:remove()
            end
          end)
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chattrg(args)
      end)
      ChangeValue(DamageSystem_Shjc, sy, 0.1)
      ChangeValue(Correction_Jzsh, sy, 0.1)
      local tl = 0
      local ys = 0
      u:addhealthrefresh(function(set_value, bs)
        local value = 0
        if u:isalive() and 0 < u:getdata("战斗时间") and not u:hasdata("变异判定-根源式") then
          value = 0.01 * u:getlevel() + 2.5 * bs
        end
        set_value(DamageSystem_Shjc, sy, 0.1 * value)
      end)
      ac.loop(1000, function()
        ChangeValue(Hero_Tili_Huifu, sy, -1 * tl)
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -1 * ys)
        if u:isalive() then
          if u:getdata("战斗时间") > 0 then
            if u:hasdata("变异判定-根源式") then
              tl = 0
              ys = 0
            else
              tl = 0
              ys = 25 + 0.5 * u:getlevel()
            end
            if not u:hasdata("两仪式-俯瞰风景") then
              u:setdata("两仪式-俯瞰风景")
              u:setdata("两仪式-俯瞰风景特效", u:effectadd("war3mapImported\\-!shikieye3!-.mdx", "origin", -1))
            end
          else
            tl = 0.5
            ys = 0
            if u:hasdata("两仪式-俯瞰风景") then
              u:deldata("两仪式-俯瞰风景")
              DestroyEffectLua(u:getdata("两仪式-俯瞰风景特效"))
              u:deldata("两仪式-俯瞰风景特效")
            end
          end
        else
          tl = 0
          ys = 0
          if u:hasdata("两仪式-俯瞰风景") then
            u:deldata("两仪式-俯瞰风景")
            DestroyEffectLua(u:getdata("两仪式-俯瞰风景特效"))
            u:deldata("两仪式-俯瞰风景特效")
          end
        end
        ChangeValue(Hero_Tili_Huifu, sy, 1 * tl)
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 1 * ys)
      end)
      u:addstexiao(str, "伤害判定后特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if args.damage >= 10 then
          local hp
          if u:hasdata("变异判定-根源式") then
            hp = 0.5 * info.yssh
          else
            hp = 0.01 * info.yssh
          end
          LossHpUnit({
            u = u,
            tg = tg,
            damage = hp,
            perhp = 0,
            maxhp = 0,
            bj = "[生命损耗]根源式"
          })
        end
      end)
      u:addstexiao("两仪式", "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:ishasskill("A0FD") then
          info.end1 = info.end1 + 0.12
        end
      end)
      u:uivar_change({
        keyname = "两仪式净眼",
        keytype = "传奇栏",
        text = "|cFF6699FF虹|r|cFF5C7AEB之|r|cFF525CD6魔|r|cFF473DC2眼|r\n|cFF473DC2提升10%伤害加成\n提升10%近战伤害\n无视伤害免疫与闪避\n直接伤害时1%即死目标(10%/1%当前)|r\n|cFF6699FF死之线|r\n|cFF473DC2伤害如果没有暴击,则50%暴击\n暴击时使目标移除25%(5%/0.5%当前)最大生命值并在10秒内提升25%额外受伤,独立冷却3秒|r\n|cFF6699FF连携斩击|r\n|cFF473DC2直接伤害同一单位时在7秒内提升自身属性|r\n|cFF6699FF俯瞰风景|r\n|cFF473DC2脱战时提升0.5体力恢复\n战斗时提升[等级*0.1%+背水*25%]伤害加成\n战斗时提升[25+等级*0.5]额外移速|r\n|cFFFFCC66【继承】|r\n|cFF6699FF根源接续|r\n|cFF473DC2输入\"那么 请多关照\"开启 无法关闭|r\n|cFFFFCC66【恩惠】|r\n|cFF473DC2拥有[直死魔眼]时,连携斩击效果与持续时间翻倍|r\n|cFF6699FF概念干涉|r\n|cFF473DC2对无实体提升12%伤害\n伤害结算后附带[原始伤害值*1%]生命损耗效果|r",
        icon = "war3mapImported\\BTNEwl_Tong_Hzmy",
        isclearclick = true
      })
    end
  end,
  ["神主ZUN"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-神主ZUN"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFFADC700神主ZUN|r|cFF7DBEF1]|r" .. NameID[sy])
      u:chat("在玩的时候常常产生这样的疑惑：游戏是这么创作的吗？")
      u:setdata(str)
      u:reduceshw()
      Boolean_Zun2 = true
      u:setdata("神主ZUN-强化")
      u:addallstats(100)
      u:addrandomdamage(100)
      ForGroupLuaNew(Group_PlayHero, function(xq)
        local sy2 = xq.ownerid
        ChangeValue(Correction_Exp, sy2, 0.05)
        if xq.handle ~= u.handle and (xq.type == HeroType["爱丽丝"] or xq.type == HeroType["灵梦"] or xq.type == HeroType["魔理沙"] or xq.type == HeroType["蕾米"] or xq.type == HeroType["十六夜"] or xq.type == HeroType["圣白莲"] or xq.type == HeroType["琪露诺"] or xq.type == HeroType["秦心"]) then
          xq:sendmessage("|cFF009999你被神主强化了|r")
          xq:setdata("神主ZUN-强化")
          xq:addallstats(100)
          xq:addrandomdamage(100)
        end
      end)
      local gs = 0
      ac.loop(3000, function()
        u:changedata("固定伤害", 0.1 * (-1 * gs))
        gs = 500 * GetItemCharges(u:getitem("I034"))
        u:changedata("固定伤害", 0.1 * (1 * gs))
      end)
      local zunquestion = require("gameplay.var.data.zun_wd")
      local dskill = S2ID("A1SH")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local tg = getunit(args.target)
          local ewl = getunit(args.unit)
          if not tg:isingroup(Group_PlayHero) then
            b = false
            u:sendmessage("|cFF7DBEF1目标不合法|r")
          end
          if b then
            tg:playseensound(Sound_Zun_01)
            SendMsgAll(tg:getplayername() .. "|cFFADC700请注意，本关考验你，蒙答案能力|r")
            tg:setdata("神主ZUN-回答问题中")
            ac.loop(1000, function(timer)
              tg:buffset(u.handle, 1.1, "伤害限制")
              if not tg:hasdata("神主ZUN-回答问题中") then
                timer:remove()
              end
            end)
            zunquestion(tg, "技能")
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      u:uivar_remove("酒之妖精", "冥王栏")
      u:uivar_add({
        keyname = "神主ZUN",
        keytype = "传奇栏",
        text = "|cFF009999神主ZUN|r\n|cFF009999东方\n酒豪|r\n|cFF33CCCC酒使用冷却延长至8秒\n每使用一瓶酒50%提升全队1点属性,50%提升全队1%随机伤害修正|r\n|cFF009999神主|r\n|cFF33CCCC自身与所有东方英雄提升50%药水成功率与100全属性与100%伤害修正\n提升全队100%东方变异补正\n提升全队10%经验获取率\n全队获取东方变异时,其提升2点全属性或5%随机伤害修正|r\n|cFF009999超无限续杯|r\n|cFF33CCCC每持有一瓶啤酒提升100固定伤害\n每饮用任意酒便立刻获得一杯啤酒|r\n|cFF009999适当、普通、完全|r\n|cFF33CCCC60秒饮过酒时提升全队20%终结伤害\n60秒内不饮酒便会降低自身90%、队友50%的额外终结增伤，不影响基础伤害|r\n|cFF009999你不回答问题不准玩游戏|r\n|cFF33CCCC解锁额外技能[压力马斯内]|r",
        icon = "BTNEwl_Zun_Shenhua"
      })
    end
  end,
  ["红美铃"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-红美铃"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFFD0645E红|r|cFFA08B5C美|r|cFFB0403F铃|r|cFF7DBEF1]|r" .. NameID[sy])
      u:chat("我的名字叫红.美.铃!")
      u:setdata(str)
      u:reduceshw()
      ChangeValue(Correction_Jzsh, sy, 0.025)
      ChangeValue(DamageSystem_Shjc, sy, 0.05)
      u:addstexiao(str, "伤害格挡效果", function(args)
        if not args.b then
          local u = args.u
          local gl = 18
          if u:hasbuff("睡眠") then
            gl = 36
          end
          if u:getgedangrandom(gl) then
            args.b = true
            u:effectadd("Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageCaster.mdl", "chest")
            u:effectadd("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdl", "chest")
          end
        end
      end)
      ChangeValue(Damage_Type_Zhendang, sy, 0.2)
      ChangeValue(DamageSystem_GushangBeilv, sy, 0.4)
      u:addstexiao(str, "近战伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(str .. "-特效冷却") and u:getluckrandom(5) then
          tg:effectadd("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl")
          u:settimedata(str .. "-特效冷却", 1)
          local txsh = u:getdata("固定伤害") * 10
          DamageUnit({
            bj = "红美铃附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "震荡",
            isvest = true,
            isattack = true,
            isnoarmor = false,
            element = "无"
          })
        end
      end)
      u:addstexiao(str, "伤害判定后效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if info.damagetype == "震荡" and not u:hasdata(str .. "-猛虎内劲冷却") then
          tg:buffset(u.handle, 2, "僵直")
          tg:changetimearmor(-5, 10)
          if not tg:hasdata("红美铃-猛虎内劲抑制恢复") then
            tg:settimedata("红美铃-猛虎内劲抑制恢复", 15)
          end
          u:settimedata(str .. "-猛虎内劲冷却", 0.5)
        end
      end)
      u:uivar_remove("门番", "冥王栏")
      u:uivar_add({
        keyname = "红美铃",
        keytype = "传奇栏",
        text = "|cFFD0645E红|r|cFFA08B5C美|r|cFFB0403F铃|r\n|cFFC7AB72午睡门番|r\n|cFFD86B63每10秒50%自身睡眠5秒|r\n|cFFC7AB72虹色太极拳|r\n|cFFD86B63提升2.5%近战伤害\n提升5%伤害加成\n受到伤害时18%格挡,如果处于[睡眠]状态则概率翻倍\n[睡眠]状态不会受到额外伤害与降低伤害\n处于[睡眠]状态时,提升0.8%生命恢复,7.5%伤害加成与5%近战伤害|r\n|cFFC7AB72猛虎内劲|r\n|cFFD86B63提升20%震荡伤害\n提升40%固定伤害\n近战直接伤害5%附带[固定伤害*10]近战震荡伤害,触发冷却1秒\n造成震荡伤害时,僵直目标2秒,降低目标5点护甲10秒,并在15秒内抑制生命恢复,触发冷却0.5秒|r\n|cFFC7AB72芳华绚烂|r\n|cFFD86B63杀敌时提升0.0075%近战伤害与5经验值\n处于[睡眠]状态时杀敌加成翻倍|r",
        icon = "Ewl_Hongmeiling"
      })
    end
  end,
  ["日向雏田"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-日向雏田"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFF7DBEF1日向雏田|r|cFF7DBEF1]|r" .. NameID[sy])
      Weiyi[6] = true
      u:chat("眼无所不见，渴望……一切")
      u:deldata("白眼")
      u:setdata(str)
      u:reduceshw()
      u:addskill("A0SW")
      u:createrectfogcorrector(RECT_PlayArea)
      u:changedata("闪避值", 25)
      ChangeValue(Correction_CureUp, sy, 0.25)
      u:setdata("白眼净")
      ChangeValue(HeroMenu_Sbxs, sy, 0.06)
      u:uivar_change({
        keyname = "白眼",
        keytype = "传奇栏",
        text = "|cFF7DBEF1白眼-净|r\n|cFF7DBEF1柔拳法.八卦百二十八掌|r\n|cFF6699FF直接伤害时移除目标特性5秒并造成[自身等级*力量*8*目标精英特性数量]伤害(独立冷却5秒)|r\n|cFF7DBEF1回天|r\n|cFF6699FF每次使用鲁纳斯泉水提升1%随机伤害修正与2点属性\n受到伤害时24%免疫该次伤害并反馈2倍抹除伤害|r\n|cFF7DBEF1掌仙术|r\n|cFF6699FF提升900范围0.1点体力恢复\n提升25%医疗效果|r\n|cFF7DBEF1洞察|r\n|cFF6699FF视野扩大\n造成伤害无视目标的伤害闪避\n提升25闪避值与0.05闪避系数|r\n|cFF7DBEF1命运|r\n|cFF6699FF神性惩罚对自身降低一个等级\n当有队友删模时 自身将无法再通过常规方式复活|r",
        icon = "war3mapImported\\BTNEwl_Baiyan-jing.blp",
        isclearclick = true
      })
    end
  end,
  ["健次郎"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-健次郎"
    if not u:hasdata(str) then
      u:setdata(str)
      NameID[sy] = "|cFF333333健|r|cFF596666次|r|cFF809999郎|r"
      u:setplayername(NameID[sy])
      Caidan_Jiancilang = true
      Caidan_Jiancilang_2 = true
      u:setdata("特殊判定-一碗虾")
      PlayBGM({
        bgm = BGM_Jiancilang_01,
        time = 180,
        ID = 96,
        unit = u.handle
      })
      u:addskill("S0A6")
      ac.loop(1000, function()
        if Hero_Shenhua_Left[sy] >= 1 then
          Hero_Shenhua_Left[sy] = Hero_Shenhua_Left[sy] - 1
          u:addstr(100)
          u:changeoriginmaxhp(500.0)
        end
      end)
      local txz = {
        "7Stars_11.mdx",
        "7Stars_12.mdx",
        "7Stars_13.mdx",
        "7Stars_14.mdx",
        "7Stars_15.mdx",
        "7Stars_16.mdx",
        "7Stars_17.mdx"
      }
      
      local function jiancilangsizhaoxing(tg)
        tg:effectadd("Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl")
        if tg:hasdata("健次郎-死兆星特效") then
          DestroyEffectLua(tg:getdata("健次郎-死兆星特效"))
          tg:deldata("健次郎-死兆星特效")
        end
        tg:setdata("健次郎-死兆星特效", tg:effectadd(txz[tg:getdata("健次郎-死兆星层数")], "overhead", -1))
        if tg:getdata("健次郎-死兆星层数") >= 7 then
          ac.wait(500, function()
            DestroyEffectLua(tg:getdata("健次郎-死兆星特效"))
            tg:deldata("健次郎-死兆星特效")
          end)
          tg:effectadd("war3mapImported\\texiao_xuebao.mdx")
          tg:setdata("健次郎-死兆星层数", 0)
          if tg:isboss() then
            tg:buffset(u.handle, 1, "眩晕")
            tg:buffset(u.handle, 1, "暂停")
            tg:buffset(u.handle, 1, "沉默")
            DamageUnit({
              bj = "健次郎死兆星",
              unit = tg.handle,
              source = u.handle,
              damage = 1,
              level = 1,
              type = "物理",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无",
              extradata = {
                "健次郎-死兆星固定伤害"
              }
            })
          else
            tg:kill(u.handle)
          end
        end
      end
      
      u:addstexiao(str, "近战伤害效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(str .. "-近战特效冷却") then
          u:settimedata(str .. "-近战特效冷却", 1)
          tg:changedata("健次郎-死兆星层数", 1)
          jiancilangsizhaoxing(tg)
        end
      end)
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(str .. "-直接特效冷却") then
          u:settimedata(str .. "-直接特效冷却", 1)
          tg:changedata("健次郎-死兆星层数", 1)
          jiancilangsizhaoxing(tg)
        end
      end)
      local dskill
      if u:ishasskill("A1AM") and u.type ~= HeroType["C呆"] and u.type ~= HeroType["莲华"] then
        dskill = "A1SF"
      else
        dskill = "A1SE"
      end
      Fskillreplace({
        unit = u.handle,
        level = 2,
        skill_F = dskill,
        skill_X = dskill,
        isforce = true,
        efunc = function()
          local function skill(args)
            if args.skill == S2ID(dskill) then
              u:setdata("健次郎-无想转生时间", 0.2)
              
              u:effectadd("Abilities\\Spells\\Human\\ControlMagic\\ControlMagicTarget.mdl", "overhead", 0.2)
            end
          end
          
          ac.loop(10, function()
            if u:getdata("健次郎-无想转生时间") > 0 then
              u:changedata("健次郎-无想转生时间", -0.01)
              if u:getdata("健次郎-无想转生时间") <= 0 then
                u:deldata("健次郎-无想转生时间")
              end
            end
          end)
          u:addtrgevent("单位-发动技能", function(args)
            skill(args)
          end)
        end
      })
      u:uivar_add({
        keyname = "健次郎",
        keytype = "传奇栏",
        text = "|cFFA2ADCB拳四郎|r\n|cFFA2ADCB北斗百裂拳|r\n|cFFE2F6F7直接伤害为目标施加一层死兆星,触发冷却1秒\n近战伤害为目标施加一层死兆星,触发冷却1秒\n施加七层死兆星时,眩晕,暂停并沉默目标1秒,对目标造成即死(1%最大生命值固定伤害[不会被加成 不会被减免])并清空层数\n死兆星触发时拥有7%斩杀线|r\n|cFFA2ADCB转龙呼吸法|r\n|cFFE2F6F7极速\n额外移速锁定为125\n无法获得神化位\n回忆类药剂成功率锁定为0%\n所受伤害不会超过75%最大生命值,受到超额伤害时清空自身负面状态\n每消耗一个神化位为自身提供500基础生命上限与100力量|r\n|cFFA2ADCB无想转生|r\n|cFFE2F6F7强制替换F技能|r\n|cFF949596你已经死了|r",
        icon = "BTNEwl_Jiancilang_01"
      })
    end
  end,
  ["菲琳"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-菲琳"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      u:chat("白银吐息，绽放冰河。")
      u:playsound(Sound_Filene_04)
      u:setplayername("|cFF7DBEF1[|r|cFF99CCFF菲|r|cFF77AAFF琳|r|cFF7DBEF1]|r" .. NameID[sy])
      ChangeValue(DamageSystem_Txsh, sy, 0.25)
      u:addskill("A1BB")
      ChangeValue(Hero_Tili_Huifu, sy, 0.05)
      local ice = 0
      local lw = 0
      local hf = 0
      ac.loop(3000, function()
        local dr = u:getdragonbloodpower()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * lw))
        ChangeValue(Damage_Element_Ice, sy, -1 * ice)
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, -1 * hf)
        ice = (0.1 + 0.002 * u:getlevel()) * dr
        lw = (0.5 + 0.025 * u:getlevel()) * dr
        hf = 0.75 * dr
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * lw))
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, 1 * hf)
        ChangeValue(Damage_Element_Ice, sy, 1 * ice)
      end)
      u:addstexiao(str, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:hasbuff("冰冻") then
          info.end2 = info.end2 + 0.12
        end
        if info.element == "冰" then
          info.endup = info.endup + 0.09
        end
      end)
      u:addstexiao(str, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if tg:hasbuff("冰冻") then
          info.wssb = true
        end
      end)
      ac.loop(1000, function()
        if u:isalive() and not u:hasdata("永冻之心加速冷却") and GetUnitMoveSpeed(u.handle) <= 100 then
          u:settimedata("永冻之心加速", 10)
          u:effectadd("AATX\\[AATxNew]Ice10.mdl", "chest")
          u:clearbuff("僵直")
          u:addskill("S06W")
          ac.wait(10000, function()
            u:delskill("S06W")
          end)
          u:settimedata("永冻之心加速冷却", 60)
        end
      end)
      AddAllSTexiao(str, "终结伤害计算效果", function(args)
        local tg = args.tg
        local info = args.damageinfo
        if tg:ishasbuff("B0A6") then
          info.endup = info.endup + 0.05
        end
      end)
      u:uivar_change({
        keyname = "银冰的加护",
        keytype = "传奇栏",
        text = "|cFF3366FF绝对|r|cFF5C85FF零度|r|cFF85A3FF.菲|r|cFFADC2FF琳|r\n|cFF5C85FF银冰龙息|r\n|cFFADC2FF提升[(10%+0.2%*等级)*纯度浓度相关]冰属性伤害\n直接伤害10%发动龙息,触发冷却1.5秒|r\n|cFF5C85FF寒龙血|r\n|cFFADC2FF冰属性伤害提升0.9%终结伤害\n提升[0.75%*浓度相关]永恒恢复\n受到大于10伤害时冰冻目标2秒,独立冷却5(10/15)秒\n所受伤害大于原始伤害时降低30%所受伤害|r\n|cFF5C85FF白银雪花|r\n|cFFADC2FF降低900范围单位10%攻击力与1%伤害加成并受到额外5%终结伤害\n提升[(5%+0.25%*等级)*纯度浓度相关]伤害加成\n提升25%特效伤害|r\n|cFF5C85FF永冻之心|r\n|cFFADC2FF免疫冰冻\n提升0.15体力恢复\n移动速度低于100时在10秒内免疫僵直并获得极限移速,触发冷却60秒\n无视冰冻单位的伤害减免与伤害闪避\n对冰冻单位提升12%伤害|r\n|cFF949596「……不需要，除了我以外的存在。」|r",
        icon = "war3mapImported\\BTNEwl_Filene_04",
        isclearclick = true
      })
    end
  end,
  ["阿比盖尔"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-阿比盖尔"
    if not u:hasdata(str) then
      u:setdata(str)
      ChangeValue(Damage_Element_Heart, sy, 0.1)
      ChangeValue(Damage_ElementRes_Heart, sy, 25)
      ChangeValue(Correction_Cbxs, sy, 0.1)
      u:adddivinity(2)
      u:getgoddessforce(2, true)
      u:changedata("智力增幅", 0.25)
      local npc = getunit(NPC_Molijiedian)
      npc:addskill("A07A")
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:addskill("S02C")
        xq:setdata("阿比盖尔-虚伪之海")
        xq:changedata("效果增强-外域", 0.25)
      end)
      u:changedata("效果增强-外域", 0.25)
      local add = 0
      local add2 = 0
      ac.loop(3000, function()
        ChangeValue(Damage_Element_Heart, sy, -add)
        add = 0.02 * u:getstate("外域变异")
        ChangeValue(Damage_Element_Heart, sy, add)
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * -add2)
        add2 = 0.01 * Stage
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * add2)
      end)
      u:addstexiao(str, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if tg:hasbuff("混乱") then
          info.wssb = true
          info.wsmy = true
        end
      end)
      u:addstexiao(str, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:hasbuff("混乱") then
          info.end2 = info.end2 + 0.12
        end
      end)
      ModelReplace({
        u = u,
        model = "Hero\\abger1.mdl",
        modelsize = 1,
        modelname = "|cFFFFCC33阿比|r|cFFAAAA55盖尔·|r|cFF8E9F60威廉|r|cFF397D82姆斯|r",
        modelicon = "abger1_portrait.tga"
      })
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(str .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(str .. "-特效冷却", 3)
          local x2, y2 = tg:getxy()
          Effectcreate("ATX\\[ATxNew]Cthulhu_01.mdl", x2, y2, 0, 4)
          Effectcreate("ATX\\[ATxNew]Cthulhu_07.mdl", x2, y2, 0, 3)
          local xx2, yy2 = PolarXY(x2, y2, GetRandomReal(100, 300), GetRandomAngle())
          local mj = u:createunit("u097", xx2, yy2, 0)
          local jd = AngleBetweenUnits(mj.handle, tg.handle)
          mj:setface(jd)
          mj:timetoremove(1.5)
          mj:setcolor(255, 255, 255, 125)
          local yxz = {
            DemonHunterMissileHit1,
            DemonHunterMissileHit2,
            DemonHunterMissileHit3
          }
          u:playsound(yxz[GetRandomInt(1, 3)])
          local txsh = 45 * u:getallattri() + 10 * u:getdata("魔力值")
          for _, xq in ac.selector():in_rangexy(x2, y2, 350):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:buffset(u.handle, 1, "混乱")
            DamageUnit({
              bj = "阿比盖尔神化附伤",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "魔力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "心灵"
            })
          end
        end
      end)
      local cs = 0
      local cs2 = 0
      local cs3 = 0
      local gs = 0
      ac.loop(1000, function(timer)
        u:changedata("固定伤害", 0.1 * (-8 * gs))
        gs = u:getdata("魔力值")
        u:changedata("固定伤害", 0.1 * (8 * gs))
        if not Movie_Boolean then
          cs = cs + 1
          cs2 = cs2 + 1
          cs3 = cs3 + 1
          if cs3 == 10 then
            cs3 = 0
            if u:isalive() then
              local x, y = u:getxy()
              Effectcreate("ATx\\[ATxNew]Black_10.mdl", x, y, 0, 1.5)
              if GetRandom100(10) then
                u:playsound(Sound_Abigaier_04)
              end
              for _, xq in ac.selector():in_rangexy(x, y, 900):is_not(u.handle):ipairs() do
                xq = getunit(xq)
                if xq:is_enemy(u.handle) or xq:isingroup(Group_PlayHero) then
                  if xq:is_enemy(u) then
                    xq:buffset(u.handle, 3, "混乱")
                    xq:buffset(u.handle, 3, "破坏-伤害抗性")
                    xq:effectadd("Abilities\\Spells\\Other\\Parasite\\ParasiteTarget.mdl", "head", 3)
                  end
                  if xq:isingroup(Group_PlayHero) then
                    xq:effectadd("Abilities\\Spells\\Other\\Parasite\\ParasiteTarget.mdl", "head", 3)
                    SelectUnitRemoveForPlayer(xq.handle, GetOwningPlayer(xq.handle))
                    xq:settimedata("阿比盖尔-理智丧失失控", 3)
                    xq:buffset(u.handle, 3, "绝对闪避")
                  end
                end
              end
            end
          end
          if cs == 480 then
            cs = 0
            u:changedata("魔力值", 200)
            u:chat("もっと~もっと~楽しませてね")
            PlayGlobalSound(Sound_Abigaier_04)
            u:effectadd("ATx\\[ATxNew]Purple_24.mdl")
          end
          if cs2 == 60 then
            cs2 = 0
            if u:hasbuff("眩晕") then
              u:setdata("眩晕时间", 0)
            end
            if u:hasbuff("僵直") then
              u:setdata("僵直时间", 0)
            end
            u:clearbuff()
            u:effectadd("ATx\\[ATxNew]Purple_01.mdl")
          end
        end
      end)
      u:addstexiao(str, "被施加Buff时效果-眩晕", function(args)
        if not Keyan_Guomintizhi then
          args.time = 0
        end
      end)
      u:uivar_change({
        keyname = "恶魔附体",
        keytype = "传奇栏",
        text = "|cFFFFCC33阿|r|cFFAAAA55比|r|cFF8E9F60盖尔|r\n|cFF397D82神性 2\n外域 黑暗 魔导\n领域外生命|r\n|cFFFFCC33免疫眩晕\n提升0.1超暴系数\n提升[波数*0.1%]终结伤害\n被外神注视时提升2.5%全属性|r\n|cFF397D82理智丧失-疯狂|r\n|cFFFFCC33免疫精英特性疯狂\n免疫混乱的失控效果\n提升25%心灵抗性\n提升25%外域变异效果\n提升[10%+2%*外域变异]心灵伤害\n提升25%智力\n提升[魔力值*0.8]固定伤害\n每隔10秒使自身周围900单位进入混乱状态3秒\n使用冥王星或扭曲药剂时额外恢复并提升1~2点全属性与1~4.5%伤害修正|r\n|cFF397D82蔷薇的沉睡|r\n|cFFFFCC33无视混乱中单位伤害免疫与闪避\n对混乱中单位提升12%伤害\n无属性伤害变为心灵伤害\n直接伤害时10%附带350范围[全属性*45+魔力值*10]心灵魔力伤害并使其混乱1秒(触发冷却3秒)|r\n|cFF949596钥匙的禁歌|r",
        icon = "NewIcon_Abi",
        isclearclick = true,
        ishasphoto = true
      })
    end
  end,
  ["洛琪希"] = function(u)
    local sy = u.ownerid
    local str = "神化判定-洛琪希"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFF3366FF洛琪希|r|cFF7DBEF1]|r" .. NameID[sy])
      u:setdata(str)
      u:reduceshw()
      PlayGlobalSound(Sound_Lqx_03)
      SendMsgAll("|cFF3366FF『|r|cFF3A6DFF也|r|cFF4174FF是|r|cFF477AFF呢|r|cFF4E81FF，|r|cFF5588FF确|r|cFF5C8FFF实|r|cFF6396FF有|r|cFF699CFF过|r|cFF70A3FF这|r|cFF77AAFF种|r|cFF7EB1FF时|r|cFF85B8FF期|r|cFF8BBEFF』|r")
      SendDtimeMsgAll(4.3, "|cFF3366FF『|r|cFF396CFF因|r|cFF4073FF为|r|cFF4679FF以|r|cFF4C80FF前|r|cFF5386FF的|r|cFF598CFF我|r|cFF6093FF不|r|cFF6699FF懂|r|cFF6C9FFF得|r|cFF73A6FF认|r|cFF79ACFF清|r|cFF80B2FF自|r|cFF86B9FF我|r|cFF8CBFFF』|r")
      SendDtimeMsgAll(8.6, "|cFF3366FF『|r|cFF396CFF总|r|cFF3E71FF是|r|cFF4477FF想|r|cFF4A7DFF着|r|cFF4F82FF如|r|cFF5588FF何|r|cFF5B8EFF不|r|cFF6093FF被|r|cFF6699FF当|r|cFF6C9FFF成|r|cFF71A4FF小|r|cFF77AAFF孩|r|cFF7DB0FF子|r|cFF82B5FF看|r|cFF88BBFF待|r|cFF8EC1FF』|r")
      SendDtimeMsgAll(13.4, "|cFF3366FF『|r|cFF3C6FFF现|r|cFF4679FF在|r|cFF4F82FF则|r|cFF588BFF是|r|cFF6194FF反|r|cFF6B9EFF了|r|cFF74A7FF过|r|cFF7DB0FF来|r|cFF86B9FF』|r")
      SendDtimeMsgAll(14.8, "|cFF3366FF『|r|cFF3B6EFF成|r|cFF4376FF为|r|cFF4B7EFF了|r|cFF5285FF水|r|cFF5A8DFF王|r|cFF6295FF级|r|cFF6A9DFF魔|r|cFF72A5FF术|r|cFF7AADFF师|r|cFF81B4FF后|r|cFF89BCFF』|r")
      SendDtimeMsgAll(16.8, "|cFF3366FF『|r|cFF3C6EFF空|r|cFF4477FF有|r|cFF4C80FF名|r|cFF5588FF声|r|cFF5E90FF在|r|cFF6699FF传|r|cFF6EA2FF来|r|cFF77AAFF传|r|cFF80B2FF去|r|cFF88BBFF』|r")
      SendDtimeMsgAll(19.3, "|cFF3366FF『|r|cFF396CFF总|r|cFF3E71FF是|r|cFF4477FF被|r|cFF4A7DFF期|r|cFF4F82FF待|r|cFF5588FF能|r|cFF5B8EFF做|r|cFF6093FF到|r|cFF6699FF无|r|cFF6C9FFF咏|r|cFF71A4FF唱|r|cFF77AAFF使|r|cFF7DB0FF用|r|cFF82B5FF魔|r|cFF88BBFF术|r|cFF8EC1FF』|r")
      SendDtimeMsgAll(21.9, "|cFF3366FF『|r|cFF3A6DFF这|r|cFF4275FF种|r|cFF497CFF我|r|cFF5083FF根|r|cFF578AFF本|r|cFF5F92FF办|r|cFF6699FF不|r|cFF6DA0FF到|r|cFF75A8FF的|r|cFF7CAFFF事|r|cFF83B6FF情|r|cFF8ABDFF』|r")
      ChangeValue(HeroMenu_MpCure_Inr, sy, 1)
      ChangeValue(DamageSystem_EndSh, sy, 0.010000000000000002)
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        if not u:hasdata(str .. "-特效冷却") then
          u:settimedata(str .. "-特效冷却", 1)
          local txsh = 1000 * u:getlevel()
          local x, y = tg:getxy()
          Effectcreate("4.8.528 (5).mdl", x, y)
          for _, xq in ac.selector():in_rangexy(x, y, 225):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "洛琪希附伤",
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
      u:addstexiao(str, "直接伤害变更", function(args)
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("洛琪希-活水吟唱") and info.damagetype == "魔力" and u:getmp() >= 1 then
          local xh = 0.5 + 0.005 * u:getmp()
          local up = 0.1
          u:curemp(-1 * xh)
          args.shadd = args.shadd + up
        end
      end)
      local dskill = S2ID("A1LO")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            if not u:hasdata("洛琪希-活水吟唱") then
              u:setdata("洛琪希-活水吟唱")
              u:sendmessage("|cFF3366FF活水吟唱-[开启]|r")
              u:setskilldatastring(dskill, "提示", "|cFF3366FF活水吟唱-[开启]|r")
            else
              u:deldata("洛琪希-活水吟唱")
              u:sendmessage("|cFF3366FF活水吟唱-[关闭]|r")
              u:setskilldatastring(dskill, "提示", "|cFF3366FF活水吟唱-[关闭]|r")
            end
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      local dskill = S2ID("A1LI")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            local x, y = u:getxy()
            PlayGlobalSound(Sound_Lqx_02)
            u:buffset(u.handle, 26, "暂停")
            u:buffset(u.handle, 26, "绝对闪避")
            u:buffset(u.handle, 28, "无敌")
            local cf = {
              {
                str = "伟大的水之精灵",
                time = 0.5
              },
              {
                str = "登上天空的雷帝之王子啊",
                time = 3
              },
              {
                str = "实现吾愿",
                time = 5.8
              },
              {
                str = "降下凶暴的恩惠",
                time = 7.4
              },
              {
                str = "将力量展现给渺小的存在吧",
                time = 9.6
              },
              {
                str = "神之铁锤击打铁砧 展现你的威严",
                time = 13.7
              },
              {
                str = "让大地被水淹没",
                time = 16.7
              },
              {str = "啊 雨啊", time = 19},
              {
                str = "冲毁全部",
                time = 20.4
              },
              {
                str = "驱逐一切吧",
                time = 22
              }
            }
            local cs = 0
            ac.loop(1000, function(timer)
              cs = cs + 1
              for _, xq in ac.selector():in_rangexy(x, y, 2000):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:buffset(u.handle, 2, "僵直")
              end
              if cs == 26 then
                timer:remove()
              end
            end)
            local str1 = "|cFF3366FF「"
            local str2 = "」|r"
            for index, value in ipairs(cf) do
              SendDtimeMsgAll(value.time, str1 .. value.str .. str2)
            end
            SendJbMsgAll({
              strstart = "|cFF3366FF『",
              strz = "豪雷积雨云",
              strend = "』|r",
              time = 0.9,
              shunxu = 1,
              waittime = 25.5
            })
            ac.wait(11000, function()
              Effectcreate("4.8.825 (1).mdl", x, y)
            end)
            ac.wait(12000, function()
              Effectcreate("4.8.825 (4).mdl", x, y, 0, 2)
              Effectcreate("4.8.825 (2).mdl", x, y, 15, 2, 0, 0, 0, 0, 0.1)
              Effectcreate("4.8.825 (7).mdl", x, y, 15, 20)
              local tx = Effectcreate("war3mapImported\\d36ae7ecb73a5644.mdl", x, y, -1, 0.1, 100)
              local tx2 = Effectcreate("war3mapImported\\2.26.831 (7).mdl", x, y, -1)
              local cs = 0
              ac.timer(100, 150, function()
                cs = cs + 1
                SetEffectHeight(tx, GetEffectHeight(tx) + 7)
                SetEffectSize(tx, 0.01 * cs)
                SetEffectSize(tx2, 1 + 0.05 * cs)
                if cs == 150 then
                  DestroyEffectLua(tx)
                  DestroyEffectLua(tx2)
                end
                if cs == 85 then
                  Effectcreate("war3mapImported\\d132a2592e2b3f28.mdl", x, y, 0, 3, 300)
                end
                if cs == 95 then
                  for i = 1, 5 do
                    Effectcreate("war3mapImported\\5badc8faadad48f1.mdl", x, y, 0, GetRandomReal(1, 7))
                  end
                end
              end)
            end)
            ac.wait(26000, function()
              local cs2 = 0
              ac.loop(100, function(timer)
                cs2 = cs2 + 1
                Effectcreate("war3mapImported\\2bdd35e361e17cc8.mdx", x, y, 0, 7 + 5 * cs2)
                if cs2 <= 3 then
                  Effectcreate("war3mapImported\\8754230c8af88716.mdl", x, y, 0, 3, 1000)
                end
                if cs2 == 3 then
                  local tx = Effectcreate("war3mapImported\\f6661d681eaab06c.mdl", x, y, 13, 1, 1000)
                  local cs3 = 0
                  ac.timer(100, 7, function()
                    cs3 = cs3 + 1
                    SetEffectSize(tx, 1 + 0.5 * cs3)
                  end)
                  Effectcreate("war3mapImported\\30c866543cb8ff36.mdl", x, y, 0, 6)
                  Effectcreate("war3mapImported\\3.26.130 (11).mdl", x, y, 0, 10)
                end
                if cs2 == 13 then
                  Effectcreate("war3mapImported\\3.27.1101 (4).mdl", x, y, 0, 10)
                  timer:remove()
                end
              end)
              for i = 1, 6 do
                ChangeTimeValue(Damage_Element_Water, i, 0.25, 90)
                ChangeTimeValue(Damage_Type_Moli, i, 0.25, 90)
                ChangeTimeValue(Hero_Tili_Huifu, i, 0.25, 90)
              end
            end)
            ac.wait(29000, function()
              local txsh = 10000 * u:getlevel()
              local cs2 = 0
              ac.loop(100, function(timer)
                cs2 = cs2 + 1
                for i = 1, 2 do
                  local x1, y1 = PolarXY(x, y, GetRandomReal(0, 2000), GetRandomAngle())
                  local tx = Effectcreate("war3mapImported\\by_wood_effect_yubanmeiqin_lightning_zhenzhengdeluolei.mdl", x1, y1, -1)
                  SetEffectSize(tx, 2, 2, 4.5)
                  DestroyEffectLua(tx)
                  Effectcreate("Abilities\\Weapons\\Bolt\\BoltImpact.mdl", x1, y1)
                  for _, xq in ac.selector():in_rangexy(x1, y1, 425):is_enemy(u.handle):ipairs() do
                    xq = getunit(xq)
                    DamageUnit({
                      bj = "豪雷积雨云",
                      unit = xq.handle,
                      source = u.handle,
                      damage = txsh,
                      level = 1,
                      type = "魔力",
                      isvest = true,
                      isattack = false,
                      isnoarmor = false,
                      element = "雷"
                    })
                  end
                end
                if cs2 == 100 then
                  Effectcreate("war3mapImported\\8754230c8af88716.mdl", x, y, 0, 4, 1000)
                  Effectcreate("war3mapImported\\30c866543cb8ff36.mdl", x, y, 0, 8)
                  timer:remove()
                end
              end)
            end)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      ChangeValue(Correction_CureUp, sy, 0.25)
      u:uivar_change({
        keyname = "洛琪希",
        keytype = "传奇栏",
        text = "|cFF3366FF洛|r|cFF668CFF琪|r|cFF99B2FF希|r\n|cFF3366FF水王魔法|r\n|cFF99B2FF提升25%水属性伤害\n提升1%生命恢复\n提升0.04体力恢复\n提升男性队友10%移速与10%额外移速\n直接伤害时10%附带225范围[等级*1000]水属性魔力伤害(继承法伤),触发冷却1秒|r\n|cFF3366FF师匠|r\n|cFF99B2FF提升[全队等级之和*0.05%]法术修正\n自身升级时提升全队1点全属性\n提升全队[自身智力*0.025%]经验获取(上限50%)\n提升自身与不为女神的队友[自身女神力*0.1%]伤害加成与[自身女神力*0.2%]生命恢复|r\n|cFF3366FF阿拉弥赛亚|r\n|cFF99B2FF提升25%医疗效果|r\n|cFF3366FF魔族|r\n|cFF99B2FF提升2魔力恢复\n提升1%终结伤害|r",
        icon = "war3mapImported\\BTNEwl_Lqx_02",
        isclearclick = true
      })
    end
  end,
  ["阿卡多"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-阿卡多"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFF990000阿卡多|r|cFF7DBEF1]|r" .. NameID[sy])
      u:setdata(str)
      u:reduceshw()
      PlayGlobalSound(Sound_Akaduo_01)
      PlayBGM({
        bgm = 0,
        time = 150,
        ID = 133,
        unit = u.handle
      })
      SendMsgAll("|cFF990000阿卡多：『想与我战斗是吧』|r")
      ac.wait(3000, function()
        SendMsgAll("|cFF990000阿卡多：『不这样做的话』|r")
      end)
      ac.wait(4100, function()
        SendMsgAll("|cFF990000阿卡多：『你一步也无法向前迈出吧』|r")
      end)
      ac.wait(7600, function()
        SendMsgAll("|cFF990000阿卡多：『如何前进你都不知道吧』|r")
      end)
      ac.wait(10200, function()
        SendMsgAll("|cFF990000阿卡多：『成为无用之人很可怕吗』|r")
      end)
      ac.wait(13000, function()
        SendMsgAll("|cFF990000阿卡多：『衰老很可怕吗』|r")
      end)
      ac.wait(14900, function()
        SendMsgAll("|cFF990000阿卡多：『被忘却很可怕吗』|r")
      end)
      ac.wait(17000, function()
        PlayGlobalSound(BGM_Akaduo_01)
      end)
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        if not u:hasdata("阿卡多-混乱冷却") then
          u:settimedata("阿卡多-混乱冷却", 15)
          tg:buffset(u.handle, 5, "混乱")
        end
      end)
      u:setdata("系统-不受性别限制")
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
      ChangeValue(Correction_Gun_Pistol, sy, 0.1)
      ChangeValue(Correction_Gun, sy, 0.05)
      ChangeValue(DamageSystem_Baoji, sy, 5)
      ChangeValue(DamageSystem_Baoshang, sy, 0.12)
      u:changedata("召唤物数量", 1)
      local x, y = u:getxy()
      local mj = u:createunit("n00H", x, y)
      mj:groupadd(u:getdata("召唤物组"))
      mj:groupadd(Group_ZhaohuanwuAll)
      mj:setdata("常规召唤物", "魔犬")
      mj:setguard(u.handle)
      u:setdata("阿卡多-魔犬", mj.handle)
      local dskill = S2ID("A1JN")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if b then
            local mj = getunit(u:getdata("阿卡多-魔犬"))
            u:playsound(Sound_Akaduo_05)
            mj:buffset(u.handle, 9.6, "暂停")
            ac.wait(8000, function()
              mj:animeact("spell slam")
            end)
            ac.wait(9600, function()
              mj:setsize(2.8)
              mj:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "hand left", 40)
              mj:effectadd("Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl", "hand right", 40)
              mj:addskill("A1JR")
              ac.wait(40000, function()
                mj:setsize(2)
                mj:delskill("A1JR")
              end)
            end)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      local dskill = S2ID("A1JO")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if u:getdata("阿卡多-永恒之命") < 6 then
            b = false
            u:sendmessage("|cFF990000永恒之命不足|r")
          end
          if b then
            AddAllSTexiao("阿卡多-死河", "抗性破坏阶段", function(args)
              local tg = args.tg
              local u = args.u
              local info = args.damageinfo
              if tg:ishasbuff("B0C8") then
                info.wsmy = true
              end
            end)
            ewl:delskill(dskill)
            local player = require("jh.ac.player")
            local x, y = u:getxy()
            x = x - 16
            y = y - 16
            local angle = u:getface()
            PlayBGM({
              bgm = Sound_Akaduo_04,
              time = 95,
              ID = 137,
              unit = u.handle
            })
            u:buffset(u.handle, 50, "暂停")
            u:buffset(u.handle, 52, "绝对闪避")
            u:buffset(u.handle, 50, "锁定")
            u:buffset(u.handle, 50, "无敌")
            SendDtimeMsgAll(0.2, "|cFFCC9933海|r|cFFD9B259尔|r|cFFE6CC80辛：『限制禁缚术0式』|r")
            SendDtimeMsgAll(2.4, "|cFFCC9933海|r|cFFD9B259尔|r|cFFE6CC80辛：『解放！』|r")
            SendDtimeMsgAll(3.9, "|cFFCC9933海|r|cFFD9B259尔|r|cFFE6CC80辛：『归来吧！』|r")
            SendDtimeMsgAll(5.5, "|cFFCC9933海|r|cFFD9B259尔|r|cFFE6CC80辛：『千万之众归来吧！』|r")
            SendDtimeMsgAll(8.9, "|cFFCC9933海|r|cFFD9B259尔|r|cFFE6CC80辛：『吟唱！』|r")
            SendJbMsgAll({
              strstart = "|cFF990000『",
              strz = "my name",
              strend = "』|r",
              time = 1,
              shunxu = 2,
              waittime = 14.5
            })
            SendJbMsgAll({
              strstart = "|cFF990000『",
              strz = "The Bird of the Hermes is",
              strend = "』|r",
              time = 1.4,
              shunxu = 2,
              waittime = 16.3
            })
            SendDtimeMsgAll(37, "|cFF990000『I』|r")
            SendJbMsgAll({
              strstart = "|cFF990000『I",
              strz = " devourd",
              strend = "』|r",
              time = 0.8,
              shunxu = 2,
              waittime = 39
            })
            SendJbMsgAll({
              strstart = "|cFF990000『I devourd",
              strz = " my own wings",
              strend = "』|r",
              time = 1.4,
              shunxu = 2,
              waittime = 40.7
            })
            SendJbMsgAll({
              strstart = "|cFF990000『",
              strz = "That's how I was tamed",
              strend = "』|r",
              time = 2.8,
              shunxu = 2,
              waittime = 43.8
            })
            do
              local mj = u:createunit("u0DV", x, y, 0)
              mj:timetoremove(50)
              local tmd = 0.17
              local tm = 0
              ac.timer(20, 1500, function()
                tm = tm + tmd
                mj:setcolor(255, 255, 255, tm)
              end)
              Effectcreate("4.4.834 (4).mdl", x, y, 21, 3)
              local tx = Effectcreate("4.4.834 (12).mdl", x, y, 30, 0.1, 50, 0, 0, 0, 0.05)
              local dx = 0.1
              ac.timer(40, 490, function()
                dx = dx + 0.01
                SetEffectSize(tx, dx)
              end)
              ac.wait(2500, function()
                Effectcreate("war3mapImported\\25b92993ea9959e5.mdl", x, y, 21, 15)
                Effectcreate("war3mapImported\\25b92993ea9959e5.mdl", x, y, 21, 15)
              end)
              ac.wait(8500, function()
                Effectcreate("4.4.834 (10).mdl", x, y, 10, 1, 350, 0, 0, 0, 0.1)
              end)
              ac.wait(10000, function()
                Effectcreate("war3mapImported\\cf81eb545b1c0d17.mdl", x, y, 5, 3, 0, 0, 0, 0, 0.1)
                local cs = 0
                ac.loop(100, function(timer)
                  cs = cs + 1
                  Effectcreate("war3mapImported\\237e13c5b9c7a178.mdl", x, y, 0, 1 + 0.48 * cs, 0, 0, 0, 0, 1)
                  for i = 1, 6 do
                    player[i]:shockcamera(0.2 * cs)
                  end
                  if cs == 100 then
                    for i = 1, 6 do
                      player[i]:shockcamera(200, 0.5)
                    end
                    Effectcreate("war3mapImported\\9a10b3473e1ee17a.mdl", x, y, 0, 8, 0, angle)
                    local cs2 = 0
                    ac.loop(1000, function(timer2)
                      cs2 = cs2 + 1
                      for i = 1, 3 do
                        Effectcreate("war3mapImported\\b1ce9e23f379a803.mdl", x, y, 0, 30, 0, -400)
                      end
                      local x4, y4 = PolarXY(x, y, GetRandomReal(0, 1000), GetRandomAngle())
                      Effectcreate("war3mapImported\\237e13c5b9c7a178.mdl", x4, y4)
                      if cs2 == 26 then
                        for i = 1, 6 do
                          player[i]:shockcamera(200, 3)
                        end
                        local cs3 = 0
                        ac.timer(100, 10, function()
                          cs3 = cs3 + 1
                          Effectcreate("war3mapImported\\237e13c5b9c7a178.mdl", x, y, 0, 40 - 4 * cs3)
                        end)
                        Effectcreate("war3mapImported\\1ad186020cb9a889.mdl", x4, y4, 0, 2)
                        timer2:remove()
                      end
                    end)
                    timer:remove()
                  end
                end)
              end)
              ac.wait(23000, function()
                local cs = 0
                ac.timer(500, 12, function()
                  cs = cs + 1
                  local x4, y4 = PolarXY(x, y, GetRandomReal(400, 1000), GetRandomAngle())
                  Effectcreate("4.4.834 (8).mdl", x4, y4, 0, GetRandomReal(1, 2))
                  Effectcreate("4.4.834 (13).mdl", x4, y4, 7 - 0.25 * cs, GetRandomReal(1, 2), 100, GetRandomAngle())
                end)
              end)
              ac.wait(30000, function()
                local mj = u:createunit("u0DU", x, y, 0)
                mj:timetoremove(20)
                local tmd = 5.1
                local tm = 0
                ac.timer(20, 50, function()
                  tm = tm + tmd
                  mj:setcolor(255, 255, 255, tm)
                end)
              end)
              ac.wait(31100, function()
                Effectcreate("4.4.834 (5).mdl", x, y, 2, 10)
              end)
              ac.wait(33400, function()
                for i = 1, 6 do
                  local x4, y4 = PolarXY(x, y, GetRandomReal(400, 1000), GetRandomAngle())
                  local mj = u:createunit("u0DX", x4, y4, 0)
                  mj:animeact("birth")
                  ac.wait(700, function()
                    mj:remove()
                    Effectcreate("4.4.834 (3).mdl", x4, y4, 0, 5)
                    Effectcreate("4.4.834 (14).mdl", x4, y4, 0, 5)
                  end)
                end
              end)
              ac.wait(34900, function()
                for i = 1, 6 do
                  local x4, y4 = PolarXY(x, y, GetRandomReal(400, 1000), GetRandomAngle())
                  local mj = u:createunit("u0DX", x4, y4, 0)
                  mj:animeact("birth")
                  ac.wait(700, function()
                    mj:remove()
                    Effectcreate("4.4.834 (3).mdl", x4, y4, 0, 5)
                    Effectcreate("4.4.834 (14).mdl", x4, y4, 0, 5)
                  end)
                end
              end)
              ac.wait(47800, function()
                Effectcreate("4.4.834 (16).mdl", x, y, 2.5, 10)
                CinematicFadeBJ(bj_CINEFADETYPE_FADEOUT, 2, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0)
              end)
              ac.wait(49800, function()
                local cs = 0
                ac.timer(10, 100, function()
                  cs = cs + 1
                  local x4, y4 = PolarXY(x, y, GetRandomReal(0, 3600), GetRandomAngle())
                  Effectcreate("4.4.834 (3).mdl", x4, y4, 42 - 0.01 * cs, GetRandomReal(3, 8))
                  Effectcreate("war3mapImported\\h_yanjing.mdx", x4, y4, 38 - 0.01 * cs, GetRandomReal(3, 8), 100, GetRandomAngle())
                end)
                local cs = 0
                ac.timer(100, 30, function()
                  cs = cs + 1
                  local x4, y4 = PolarXY(x, y, GetRandomReal(0, 3600), GetRandomAngle())
                  Effectcreate("4.4.834 (3).mdl", x4, y4, 42 - 0.01 * cs, GetRandomReal(3, 8))
                  Effectcreate("Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl", x4, y4)
                  local mj = u:createunit("n01J", x4, y4, GetRandomAngle())
                  SetUnitInvulnerable(mj.handle, true)
                  mj:setdata("系统-无敌")
                  UnitApplyTimedLife(mj.handle, S2ID("BTLF"), 151.0)
                  mj:timetoremove(150)
                  mj:setdata("阿卡多-死河单位")
                end)
              end)
              ac.wait(50800, function()
                u:setdata("阿卡多-零式死河")
                u:settimedata("阿卡多-死河限制", 150)
                u:uivar_remove("灵体化", "传奇栏")
                local tx = Effectcreate("4.4.834 (1).mdl", x, y, 42, 10)
                SetEffectXY(tx, x, y)
                local mj = u:createunit("u0DW", x, y)
                mj:timetoremove(42)
                for i = 1, 6 do
                  UnitShareVision(mj.handle, ConvertedPlayer(i), true)
                end
                Effectcreate("4.4.834 (11).mdl", x, y, 42, 10)
                local count = u:getdata("阿卡多-永恒之命")
                local add1 = 0.2 * count
                local add2 = 0.2 * count
                local add3 = 75 * count
                ChangeValue(Correction_Gun, sy, 0.1 * add1)
                ChangeValue(DamageSystem_Shjc, sy, 0.1 * add2)
                u:changedata("阿卡多-血液储量", add3)
                u:setdata("阿卡多-永恒之命", 0)
              end)
              ac.wait(51000, function()
                CinematicFadeBJ(bj_CINEFADETYPE_FADEIN, 2.0, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0)
                for _, xq in ac.selector():in_rangexy(x, y, 3600):is_enemy(u.handle):ipairs() do
                  xq = getunit(xq)
                  xq:groupadd(HpGroup)
                  if xq:isnormal() then
                    xq:kill(u.handle, true)
                  end
                end
                ac.timer(3000, 14, function()
                  for _, xq in ac.selector():in_rangexy(x, y, 3600):is_enemy(u.handle):ipairs() do
                    xq = getunit(xq)
                    xq:groupadd(HpGroup)
                  end
                end)
              end)
            end
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      u:uivar_change({
        keyname = "穿刺伯爵",
        keytype = "传奇栏",
        text = "|cFFFF0000阿|r|cFFFF401A卡|r|cFFFF8033多|r\n|cFFFF0000吸血鬼 黑暗\n不死|r\n|cFFFF8033直接伤害时15%混乱目标5秒,触发冷却15秒\n夜晚血液储量每秒恢复0.2%\n生命值缺失时,每秒恢复[血液储量上限/10]生命并消耗血液储量,白天上限1.6%,夜晚上限3%|r\n|cFFFF0000血海|r\n|cFFFF8033杀敌时提升2.0%血液储量与[0.5+等级/12]生命上限\n杀死BOSS单位时提升100%血液储量与1点永恒之命\n每杀死500个单位提升1点永恒之命\n提升[血液储量*10%]基础伤害\n提升[永恒之命*2.5%]伤害加成|r\n|cFFFF0000王牌死神|r\n|cFFFF8033提升5%暴击率与12%暴击伤害\n提升20%手枪伤害\n提升[7.5%+2.5%*永恒之命]枪械伤害|r\n|cFFFF0000形态变化|r\n|cFFFF8033无视地形\n提升25额外移速\n不受性别限制|r",
        icon = "war3mapImported\\BTNEwl_Akaduo_02",
        isclearclick = true
      })
    end
  end,
  ["拉比琳丝"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-拉比琳丝"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFF6699CC拉比琳丝|r|cFF7DBEF1]|r" .. NameID[sy])
      u:setdata(str)
      u:reduceshw()
      u:changedata("炎变异数量", 1)
      u:changedata("龙变异数量", 1)
      SendMsgAll("|cFF6699CC『|r|cFF699FCF永|r|cFF6CA5D2远|r|cFF6FABD5让|r|cFF72B1D8你|r|cFF75B7DB们|r|cFF78BDDE看|r|cFF7BC3E1到|r|cFF7EC9E4不|r|cFF81CFE7朽|r|cFF84D5EA的|r|cFF87DBED希|r|cFF8AE1F0望|r|cFF8DE7F3…|r|cFF90EDF6…|r|cFF93F3F9』|r")
      u:addskill("A1DQ")
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if Group_Counts(Group_Xingcunzu) <= 1 and not u:hasdata("拉比琳丝-火吹触发冷却") and u:getluckrandom(5 * info.txgl) then
          local x, y = u:getxy()
          local x2, y2 = tg:getxy()
          u:settimedata("拉比琳丝-火吹触发冷却", 1)
          Effectcreate("Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl", x, y, 0, 2.5)
          Effectcreate("AATX\\[AATxNew]Fire16.mdl", x, y, 0, 2.5)
          local txsh = 45 * u:getallattri()
          for _, xq in ac.selector():in_rangexy(x2, y2, 450):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "拉比琳丝火吹附伤",
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
            if not xq:hasdata("拉比琳丝-火吹破抗") then
              xq:settimedata("拉比琳丝-火吹破抗", 5)
              xq:buffset(u.handle, 5, "破坏-伤害免疫")
              xq:effectadd("AATX\\[AATxNew]Fire08.mdl")
            end
          end
        end
      end)
      u:addstexiao(str, "被施加Buff时效果-暂停", function(args)
        local u = args.u
        if args.time <= 10 and not Movie_Boolean and not u:hasdata("次元闭锁锁定") and u:hasdata("变异判定-拉比琳丝") and not u:hasdata("拉比琳丝-时钟冷却") and u:getdata("拉比琳丝-时钟计数") > 0 then
          if not Keyan_Guomintizhi then
            args.time = 0.01
            u:clearbuff("暂停")
          end
          u:changedata("拉比琳丝-时钟计数", -1)
          u:sendmessage("|cFF7DBEF1拉比琳丝-时钟|r")
          u:settimedata("拉比琳丝-时钟冷却", 10)
          u:buffset(u.handle, 0.5, "绝对闪避")
        end
      end)
      u:addstexiao(str, "被施加Buff时效果-眩晕", function(args)
        local u = args.u
        if not Movie_Boolean and u:hasdata("变异判定-拉比琳丝") and not u:hasdata("拉比琳丝-时钟冷却") and u:getdata("拉比琳丝-时钟计数") > 0 then
          if not Keyan_Guomintizhi then
            args.time = 0.01
            u:setdata("眩晕时间", 0)
          end
          u:changedata("拉比琳丝-时钟计数", -1)
          u:sendmessage("|cFF7DBEF1拉比琳丝-时钟|r")
          u:settimedata("拉比琳丝-时钟冷却", 10)
          u:buffset(u.handle, 0.5, "绝对闪避")
        end
      end)
      u:setdata("拉比琳丝-时钟计数", 0)
      local hj = 0
      local hf = 0
      local zj = 0
      local ys = 0
      local cs = 0
      local hpm = 0
      local jy1 = 0
      local jy2 = 1
      local gl = 0
      ac.loop(3000, function()
        u:changearmor(-1 * hj)
        ChangeValue(HeroMenu_HpChange_Inr, sy, -1 * hf)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * zj))
        if u:isinrect(RECT_Feichengqu) or u:isinrect(RECT_Feichezhan) or u:isinrect(RECT_Feichangqu) then
          hj = 25 * u:getstate("恶魔变异")
          hf = 2 * u:getdata("龙变异数量")
          zj = 0.25 * u:getstate("恶魔变异")
        else
          hj = 0
          hf = 0
          zj = 0
        end
        u:changearmor(1 * hj)
        ChangeValue(HeroMenu_HpChange_Inr, sy, 1 * hf)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * zj))
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -1 * ys)
        ys = 5 * u:getdata("龙变异数量")
        ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 1 * ys)
        cs = cs + 3
        if 60 <= cs then
          cs = 0
          u:changedata("拉比琳丝-时钟计数", 1)
          u:changemaxhp(1000)
          u:sendmessage("|cFF7DBEF1时钟计数：" .. math.floor(u:getdata("拉比琳丝-时钟计数")) .. "点|r")
        end
        ChangeValue(Correction_MHp, sy, 0.1 * (-1 * hpm))
        hpm = 0.01 * u:getdata("拉比琳丝-时钟计数")
        ChangeValue(Correction_MHp, sy, 0.1 * (1 * hpm))
        u:flashmaxhp()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * jy1))
        ChangeValue(DamageSystem_Ssjianshao, sy, jy2, 2)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * gl))
        if 1 >= Group_Counts(Group_Xingcunzu) then
          jy1 = 0.22 * u:getstate("恶魔变异")
          jy2 = 1 - 0.11 * u:getstate("恶魔变异")
          gl = 0.1 * u:getstate("恶魔变异")
          if jy2 <= 0.01 then
            jy2 = 0.01
          end
        else
          jy1 = 0
          jy2 = 1
          gl = 0
        end
        jy1 = jy1 + 0.25 * u:getdata("龙变异数量")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * jy1))
        ChangeValue(DamageSystem_Ssjianshao, sy, jy2, 1)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * gl))
      end)
      local dskill = S2ID("A1HC")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if KillCount[sy] < 50 then
            b = false
            u:sendmessage("|cFF7DBEF1杀敌数不足|r")
          end
          if b then
            u:changedata("龙炎灯次数", 1)
            u:changemaxhp(25 * u:getdata("龙炎灯次数"))
            local add = 0
            for i = 1, 50 do
              if u:getluckrandom(5) then
                add = add + 1
              end
            end
            u:addrandomstats(add)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      u:uivar_change({
        keyname = "白银城主",
        keytype = "传奇栏",
        text = "|cFF6699CC拉|r|cFF70ADD6比|r|cFF7AC2E0琳|r|cFF85D6EB丝|r\n|cFF6699CC龙 炎 恶魔 唯一 光明\n白银迷宫城\n魔像|r\n|cFF99FFFF城内提升[恶魔变异数量*2.5%]伤害加成与[恶魔变异数量*25]护甲\n城内受伤时格挡该次伤害,触发冷却5秒\n密道内提升1000护甲|r\n|cFF6699CC龙灯|r\n|cFF99FFFF提升[龙变异数量*2]生命恢复\n提升[龙变异数量*5]额外移速\n提升[龙变异数量*25%]基础伤害\n密道内效果翻倍|r\n|cFF6699CC火吹|r\n|cFF99FFFF杀敌时提升0.01%伤害加成,如果目标处于火吹状态则提升0.2%\n杀敌时使其爆炸,冷却1秒|r\n|cFF6699CC时钟|r\n|cFF99FFFF提升[时钟计数*0.1%]生命上限\n每隔60秒获得1点时钟计数并提升1000生命上限\n进入暂停或眩晕时消耗时钟计数并脱离,冷却10秒|r\n|cFF6699CC恶魔技艺|r\n|cFF99FFFF提升[1%*恶魔变异数量]伤害加成\n仅剩自身一人时获得增强|r",
        icon = "war3mapImported\\BTNEwl_lbls_02",
        isclearclick = true
      })
    end
  end,
  ["克鲁鲁"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-克鲁鲁"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFFFF0066克|r|cFFFF408C鲁|r|cFFFF80B2鲁|r|cFF7DBEF1]|r" .. NameID[sy])
      u:setdata(str)
      u:reduceshw()
      SendMsgAll("|cFFFF0066『|r|cFFFF0D6E永|r|cFFFF1A75远|r|cFFFF267D地|r|cFFFF3385…|r|cFFFF408C…|r|cFFFF4C94无|r|cFFFF599C尽|r|cFFFF66A3地|r|cFFFF73AB…|r|cFFFF80B3…|r|cFFFF8CBA永|r|cFFFF99C2恒|r|cFFFFA6C9持|r|cFFFFB2D1续|r|cFFFFBFD9着|r|cFFFFCCE0…|r|cFFFFD9E8…|r|cFFFFE6F0』|r")
      u:addskill("A1DQ")
      u:addstexiao(str, "伤害吸血效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("克鲁鲁-血镰无视抑制") then
          info.xxzq = info.xxzq + 1
          info.xxcurelv = 4
        end
      end)
      ModelReplace({
        u = u,
        model = "Hero\\Hero_Kll.mdl",
        modelsize = 0.75,
        modelname = "|cFFFF0066克|r|cFFFF1A79鲁|r|cFFFF338C鲁|r|cFFFF4C9F.|r|cFFFF66B2采|r|cFFFF80C6佩|r|cFFFF99D9西|r",
        modelicon = "Hero_Kll_portrait.tga"
      })
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local x, y = u:getxy()
        local x2, y2 = tg:getxy()
        local info = args.damageinfo
        if not u:hasdata(str .. "-血镰冷却") and u:getluckrandom(5 * info.txgl) then
          modelchange({
            unit = u.handle,
            model = "Hero\\Hero_Kll.mdl",
            modelsize = 0.65,
            modelact = "attack",
            modelactspeed = 2,
            time = 0.6,
            sfunc = function(mj)
              Effectcreate("Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl", x, y, 0, 1.5)
              mj:effectadd("Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl", "hand left")
            end,
            efunc = function(mj)
              local x, y = u:getxy()
              Effectcreate("Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl", x, y, 0, 1.5)
            end
          })
          local angle = AngleBetweenUnits(u.handle, tg.handle)
          u:settimedata(str .. "-血镰冷却", 5)
          u:losshp(u, 0, 15)
          Effectcreate("0Tx\\0Tx_Kll (7).mdl", x2, y2, 0, 5)
          Effectcreate("0Tx\\0Tx_Kll (15).mdl", x2, y2, 0, 3.5, 0, angle)
          local txsh = 150 * u:getstr() + 12 * u:getmaxhp()
          local hpt = 1 + 0.5 * u:getdata("吸血鬼变异数量")
          if u:hasdata("变异判定-圣魔之血") then
            txsh = txsh * 2
          end
          ac.wait(1400, function()
            u:settimedata("克鲁鲁-血镰无视抑制", 0.2)
          end)
          for _, xq in ac.selector():in_rangexy(x2, y2, 600):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            xq:buffset(u.handle, 2, "暂停")
          end
          ac.wait(1500, function()
            for _, xq in ac.selector():in_rangexy(x2, y2, 600):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              local x3, y3 = xq:getxy()
              Effectcreate("0Tx\\0Tx_Kll (7).mdl", x3, y3, 0, 1.5)
              DamageUnit({
                bj = "克鲁鲁血镰附伤",
                unit = xq.handle,
                source = u.handle,
                damage = txsh,
                level = 1,
                type = "魔力",
                isvest = true,
                isattack = false,
                isnoarmor = false,
                element = "暗"
              })
              ac.wait(100, function()
                if not xq:isalive() then
                  u:changemaxhp(hpt)
                end
              end)
              if not xq:hasdata("克鲁鲁-血镰抑制") then
                xq:effectadd("Abilities\\Spells\\Undead\\Cripple\\CrippleTarget.mdl", "chest", 10)
                xq:groupadd(HpGroup)
                xq:settimedata("克鲁鲁-血镰抑制", 10)
              end
            end
          end)
        end
        if not u:hasdata(str .. "-血爆冷却") and u:getluckrandom(15) then
          u:settimedata(str .. "-血爆冷却", 0.5)
          Effectcreate("war3mapImported\\texiao_xuebao.mdx", x2, y2, 0, 5)
          local txsh
          if tg:isnormal() then
            tg:buffset(u.handle, 0.5, "眩晕")
            txsh = 0.01 * tg:gethp() + 100 * u:getstr() + 5 * u:getmaxhp()
          else
            tg:buffset(u.handle, 0.1, "眩晕")
            txsh = 0.001 * tg:gethp() + 100 * u:getstr() + 5 * u:getmaxhp()
          end
          if u:hasdata("变异判定-圣魔之血") then
            txsh = txsh * 2
          end
          DamageUnit({
            bj = "克鲁鲁血爆附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 1,
            type = "魔力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "暗"
          })
        end
      end)
      AddAllSTexiao(str, "伤害系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:ishasbuff("B0AX") and (u:isingroup(Group_Kelulu_Juanzu) or u:hasdata("变异判定-克鲁鲁")) then
          info.gl = info.gl + 0.5
        end
      end)
      u:addstexiao(str, "近战伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        if not args.isvestdamage and not u:hasdata(str .. "-血影冷却") and u:getluckrandom(20) then
          local x, y = u:getxy()
          local x2, y2 = tg:getxy()
          local angle = AngleXY(x, y, x2, y2)
          u:playsound(Sound_Katana_05)
          u:losshp(u, 0, 5)
          u:settimedata(str .. "-血影冷却", 0.5)
          local txsh = 10000 + 150 * u:getstr()
          unifycreate({
            owner = u.handle,
            model = "0Tx\\0Tx_Kll (9).mdl",
            modelname = "克鲁鲁-血影",
            modelsize = 1,
            height = 90,
            damage = txsh,
            damagetype = 4,
            x = x,
            y = y,
            time = 1,
            speed = 1000,
            volume = 135,
            angle = angle,
            angleoffset = 0,
            attenua = 1,
            attenuacount = 999,
            life = 10,
            isbullet = false,
            isvest = false,
            isignorearmor = false,
            startfunc = function(mj)
              mj:setdata("循环计数", 0)
            end,
            loopfunc = function(mj)
              mj:changedata("循环计数", UnifyDT)
              if mj:getdata("循环计数") >= 0.2 then
                mj:setdata("循环计数", 0)
                local x, y = mj:getxy()
                Effectcreate("0Tx\\0Tx_Kll (5).mdl", x, y, 0.5)
                mj:playsound(Sound_Katana_07)
              end
            end,
            hitfunc = function(mj, damage)
              return damage
            end,
            hitbeforefunc = function(mj, xq, damage2)
            end,
            hitafterfunc = function(mj, xq, damage2)
              xq:effectadd("war3mapImported\\texiao_xuebao.mdx")
            end,
            endfunc = function(mj)
              mj:playsound(BuildingDeathLargeHuman)
              local x, y = mj:getxy()
              Effectcreate("0Tx\\0Tx_Kll (20).mdl", x, y, 0, 2)
              Effectcreate("0Tx\\0Tx_Kll (12).mdl", x, y, 0, 2)
            end
          })
        end
      end)
      u:setdata("克鲁鲁-进食时间", 60)
      ac.loop(1000, function()
        if u:isalive() then
          u:changedata("克鲁鲁-进食时间", -1)
          if u:getdata("克鲁鲁-进食时间") < 0 then
            u:setdata("克鲁鲁-进食时间", 0)
            if not u:hasdata("克鲁鲁-饥饿状态") then
              u:sendmessage("|cFF990000饥饿状态|r")
              u:setdata("克鲁鲁-饥饿状态")
              u:setdata("克鲁鲁-饥饿特效", u:effectadd("war3mapImported\\blood-buff-fulan.mdl", "origin", -1))
              ChangeValue(HeroMenu_HpRemove_CurHp, sy, 5)
              ChangeValue(Hero_Tili_Huifu, sy, 0.15)
              ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 100)
              ChangeValue(DamageSystem_Shjc, sy, 0.1)
            end
          elseif u:hasdata("克鲁鲁-饥饿状态") then
            u:deldata("克鲁鲁-饥饿状态")
            DestroyEffectLua(u:getdata("克鲁鲁-饥饿特效"))
            u:deldata("克鲁鲁-饥饿特效")
            ChangeValue(HeroMenu_HpRemove_CurHp, sy, -5)
            ChangeValue(Hero_Tili_Huifu, sy, -0.15)
            ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -100)
            ChangeValue(DamageSystem_Shjc, sy, -0.1)
          end
        end
      end)
      u:uivar_change({
        keyname = "始祖吸血鬼",
        keytype = "传奇栏",
        text = "|cFFFF0066克鲁|r|cFFFF408C鲁·采|r|cFFFF80B2佩西|r\n|cFFFF0066吸血鬼 吸血鬼\n血液拟态.镰|r\n|cFFFF80B2直接伤害时5%损耗15%当前生命值发动血之巨镰,触发冷却5秒|r\n|cFFFF0066血之领域|r\n|cFFFF80B2允许发动[血之领域]|r\n|cFFFF0066血液操纵.影|r\n|cFFFF80B2近战伤害5%发动血色冲击,触发冷却0.5秒|r\n|cFFFF0066血液操纵.雾|r\n|cFFFF80B2直接伤害15%引爆对方血液,触发冷却0.5秒|r\n|cFFFF0066进食|r\n|cFFFF80B2杀敌时在60秒内提升0.2%伤害加成 分立计时\n杀敌时永恒恢复0.5%最大生命值且20%提升0.05%伤害加成\n60秒内未杀敌时进入饥渴状态,每秒损耗5%当前生命值并获得以下效果：\n①提升100额外移速\n②单次受伤不超过33%最大生命值\n③提升10%伤害加成\n④提升0.15体力恢复\n杀敌时将会退出饥渴状态|r",
        icon = "war3mapImported\\BTNEwl_kll_shenhua",
        isclearclick = true
      })
    end
  end,
  ["徐盛"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-徐盛"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFF0099FF江|r|cFF14ADEB东|r|cFF29C2D6铁|r|cFF3DD6C2壁|r|cFF7DBEF1]|r" .. NameID[sy])
      u:setdata(str)
      u:reduceshw()
      SendMsgAll("|cFF66FF99『|r|cFF66F6A2战|r|cFF66EEAA将|r|cFF66E6B2临|r|cFF66DDBB阵|r|cFF66D4C4,|r|cFF66CCCC斩|r|cFF66C4D4官|r|cFF66BBDD易|r|cFF66B2E6城|r|cFF66AAEE』|r")
      PlayGlobalSound(Sound_Xusheng_01)
      u:changedata("战士变异数量", 1)
      u:changedata("闪避值", 5)
      u:setdata("属性-海洋神化")
      ChangeValue(HeroMenu_Sbxs, sy, 0.04)
      u:addstexiao(str, "伤害系统计算效果", function(args)
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("徐盛-酒") then
          info.gl = info.gl + 0.75
        end
      end)
      u:addstexiao(str, "暴击系统触发效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:getluckrandom(4) and not u:hasdata("徐盛-落樱流冷却") then
          u:changedata("徐盛-落樱点数", 1)
          u:sendmessage("|cFFFFCCFF落樱点数：" .. math.floor(u:getdata("徐盛-落樱点数")) .. "|r")
          tg:playsound(bac118)
          if 4 <= u:getdata("徐盛-落樱点数") then
            local x2, y2 = tg:getxy()
            u:setdata("徐盛-落樱点数", 0)
            u:playsound(bac126)
            u:settimedata("徐盛-落樱状态", 15)
            Effectcreate("AATX\\[AATxNew]Pink12.mdl", x2, y2)
            Effectcreate("AATX\\[AATxNew]Pink05.mdl", x2, y2)
            u:effectadd("AATX\\[Sakura]04.mdl", 15)
            u:settimedata("徐盛-落樱流冷却", 90)
            ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 250, 15)
            u:changetimedata("闪避值", 50, 15)
          end
        end
      end)
      AddAllSTexiao(str, "伤害系统计算效果", function(args)
        local tg = args.tg
        local info = args.damageinfo
        if tg:hasdata("徐盛-界破军") then
          info.ewss = info.ewss + 0.33
        end
      end)
      ac.loop(60000, function()
        if u:isalive() then
          local str = 0
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if xq:hasdata("属性-沉重") then
              str = str + 2
            end
          end)
          u:addstr(str)
          if not u:hasdata("文向-蛮勇") then
            u:setdata("文向-蛮勇")
          end
        end
      end)
      u:uivar_change({
        keyname = "文向",
        keytype = "传奇栏",
        text = "|cFF0099FF徐|r|cFF22BBDD盛|r\n|cFF0099FF水 战士\n界.破军|r\n|cFF3DD6C2生命值大于75%时提升[6%+1.5%*水变异数量]伤害加成\n直伤时使目标伤害抗性、伤害免疫与精英特性暂时失效,提升33%受伤,持续3秒,独立冷却10秒|r\n|cFF0099FF百里疑城|r\n|cFF3DD6C2提升20闪避值\n提升0.05闪避系数\n绝对闪避或伤害闪避时眩晕目标与其300范围敌军3秒并破坏其免疫抗性,触发冷却2.5秒|r\n|cFF0099FF胆略器用|r\n|cFF3DD6C2首次伤害瞬杀敌人时提升自身0.012%伤害加成|r\n|cFF0099FF万军取首|r\n|cFF3DD6C2每隔60秒下一次伤害加成提升75%,无法叠加\n饮酒时,下一次直接伤害原始伤害提升50%,可叠加,加算\n叠加值超过1200%时,视为超限伤害,同时伤害传导全场|r\n|cFF0099FF月曜日のたわわ|r\n|cFF3DD6C2提升1200范围20%减伤\n每存活60秒提升[2*沉重英雄数量]力量|r\n|cFF0099FF落樱流|r\n|cFF3DD6C2暴击4%积累1点落樱,4点时进入樱落状态15秒,冷却90秒\n期间提升250额外移速与100闪避值,直接伤害附带[额外移速*10]灵力纯粹伤害|r",
        icon = "Ewl_Xusheng_02",
        isclearclick = true
      })
    end
  end,
  ["星莲华"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-星莲华"
    if not u:hasdata(str) then
      Weiyi[16] = true
      u:deldata("变异判定-大阿阇黎")
      u:setplayername("|cFF7DBEF1[|r|cFFB26680圣白莲|r|cFF7DBEF1]|r" .. NameID[sy])
      u:setdata(str)
      u:reduceshw()
      SendMsgAll("|cFF6633FF吾|r|cFF753DE6已|r|cFF8547CC现|r|cFF9452B2世|r|cFFA35C99，|r|cFFB36680普|r|cFFC27066天|r|cFFD17A4C同|r|cFFE08533庆|r")
      PlayBGM({
        bgm = BGM_Shengbailian,
        time = 220,
        ID = 111,
        unit = u.handle
      })
      u:addallstats(20)
      ChangeValue(DamageSystem_Shjc, sy, 0.02)
      ChangeValue(DamageSystem_Shjc, sy, 0.02)
      ChangeValue(DamageSystem_Shjc, sy, 0.02)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.8, 1)
      ChangeValue(HeroMenu_HpChange_MaxHp, sy, 0.25)
      u:changedata("固定格挡", 50)
      u:addskill("A131")
      u:addstexiao(str, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:ishasbuff("B009") then
          info.wssb = true
          info.wsmy = true
        end
      end)
      u:addstexiao(str, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not tg:isnormal() then
          info.end3 = info.end3 + 0.09
        end
        if tg:isboss() then
          info.end3 = info.end3 + 0.09
        end
      end)
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(str .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          tg:effectadd("war3mapImported\\[TX] (972).mdl")
          u:settimedata(str .. "-特效冷却", 1)
          local txsh = 40 * u:getallattri() + 20 * KillCount[sy]
          DamageUnit({
            bj = "星莲华附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 5,
            type = "灵力",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "光"
          })
        end
      end)
      u:uivar_change({
        keyname = "大阿阇黎",
        keytype = "传奇栏",
        text = "|cFFFF9900星|r|cFFD98040莲|r|cFFB26680华|r\n|cFFB26680神性 2\n极乐紫云之路|r\n|cFFFF9900提升20全属性与2%伤害加成|r\n|cFFB26680超人魔法|r\n|cFFFF9900提升0.6%生命恢复速度、50固定减伤与20%受伤减少修正|r\n|cFFB26680迦楼罗之翼|r\n|cFFFF9900提升50额外移速且自身额外移速不会被任何影响减少\n生命值在16%时会锁血一次并在1秒内无敌,生命值恢复至99%时刷新冷却,最低冷却60秒|r\n|cFFB26680圣德斩|r\n|cFFFF9900继承[袈裟]效果\n直接伤害时10%附带[全属性*40+杀敌数*20]灵力抹除伤害|r\n|cFFB26680魔神复诵|r\n|cFFFF9900对精英提升9%伤害\n对BOSS提升9%伤害\n场上存在阿修罗或天魔时,每种存在提升自身2.5%伤害加成|r\n|cFF949596与吾一战，三生有幸。|r",
        icon = "war3mapImported\\BTNEwl_Shenhua_Xinglianhua.blp",
        isclearclick = true
      })
    end
  end,
  ["炭治郎"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-炭治郎"
    if not u:hasdata(str) then
      Weiyi_Dz[15] = true
      u:setplayername("|cFF7DBEF1[|r|cFFFF6600灶门炭治郎|r|cFF7DBEF1]|r" .. NameID[sy])
      u:setdata(str)
      u:reduceshw()
      u:playseensound(Tanzhilang_1)
      u:changedata("炎变异数量", 1)
      ChangeValue(DamageSystem_Baoji, sy, 8)
      ChangeValue(Hero_Tili_Huifu, sy, 0.08)
      u:changedata("闪避值", 5)
      u:addstexiao(str, "近战伤害效果", function(args)
        local u = args.u
        if u:hasdata("火之神神乐") then
          u:changetimedata("火之神神乐增伤", 1, 50)
          u:curetili(0.2)
          if u:getluckrandom(30) then
            args.level = 5
          end
        end
      end)
      u:addstexiao(str, "伤害系统计算效果", function(args)
        local u = args.u
        local info = args.damageinfo
        if u:ishasskill(SKILL_TESHUYINGXIONG) and u:hasdata("火之神神乐") then
          if not u:hasdata("神乐之舞冷却") then
            u:settimedata("神乐之舞冷却", 0.1)
          end
          u:changetimedata("神乐之舞", 0.01, 25)
          info.gl = info.gl + u:getdata("神乐之舞")
        end
      end)
      u:addstexiao(str, "伤害吸血效果", function(args)
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("炭治郎-通透世界") then
          info.xxz = info.xxz + 5
          info.lvxxz = info.lvxxz + 0.5
        end
      end)
      
      local function chattrg(args)
        if (args.chat == "通透世界" or args.chat == "Sukitooru Sekai") and u:isalive() and not u:hasdata("炭治郎-通透世界") and not u:hasdata("通透世界冷却") then
          u:settimedata("通透世界冷却", 180)
          u:settimedata("炭治郎-通透世界", 30)
          ChangeTimeValue(HeroMenu_Sbxs, sy, 0.25, 30)
          ChangeTimeValue(DamageSystem_Baoji, sy, 25, 30)
          u:changetimedata("闪避值", 50, 30)
          ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 50, 30)
          ChangeTimeValue(DamageSystem_Shjc, sy, 0.1, 30)
          ac.wait(180000, function()
            u:sendmessage("|cFF7DBEF1通透世界冷却完毕|r")
          end)
        end
        if (args.chat == "火之神神乐" or args.chat == "Hinokami Kagura") and u:isalive() and BossBattle and u:hasdata("炭治郎-通透世界") and not u:hasdata("火之神神乐") and not u:hasdata("火之神神乐已释放") then
          u:addstexiao("火之神神乐", "被施加Buff时效果-暂停", function(args)
            if args.u:hasdata("火之神神乐") and not Movie_Boolean and args.time > 1 then
              args.time = 1
            end
          end)
          u:addstexiao("火之神神乐", "被施加Buff时效果-眩晕", function(args)
            if args.u:hasdata("火之神神乐") and args.time > 1 then
              args.time = 1
            end
          end)
          u:setdata("火之神神乐已释放")
          u:setdata("火之神神乐")
          PlayBGM({
            bgm = BGM_Tanzhilang,
            time = 240,
            ID = 11,
            unit = u.handle
          })
          u:addskill("S03N")
          ChangeValue(HeroMenu_HpRemove_MaxHp, sy, 5)
          ac.wait(240000, function()
            if u:hasdata("火之神神乐") then
              u:shanmo()
            end
          end)
        end
        if (args.chat == "伍之型" or args.chat == "Go no Kata") and u:isalive() and not u:hasdata("乾天的慈雨冷却") then
          local x, y = u:getxy()
          local g = CreateGroupLua()
          for _, xq in ac.selector():in_rangexy(x, y, 1800):is_enemy(u.handle):isingroup(Group_Monster):ipairs() do
            xq = getunit(xq)
            if xq:isboss() then
            elseif xq:iselite() then
              if 25 >= xq:getperhp() then
                xq:groupadd(g)
              end
            else
              xq:groupadd(g)
            end
          end
          PlayGlobalSound(Sound_Tanzhilang_01)
          u:playsound(Sound_Tanzhilang_02)
          u:buffset(u.handle, 4, "暂停")
          u:buffset(u.handle, 5, "绝对闪避")
          local jl = 1800
          local jd = GetRandomAngle()
          ac.timer(100, 30, function()
            jd = jd - 15
            jl = jl - 60
            local x1, y1 = PolarXY(x, y, jl, jd)
            Effectcreate("war3mapImported\\[ake]war3ake.com - 5467718799163621931506138.mdl", x1, y1)
          end)
          u:settimedata("乾天的慈雨冷却", 300 + 15 * Group_Counts(g))
          ac.wait(3500, function()
            u:chat("乾天的慈雨")
            for _, xq in ac.selector():in_rangexy(x, y, 1800):is_enemy(u.handle):isingroup(Group_Monster):ipairs() do
              xq = getunit(xq)
              xq:effectadd("Abilities\\Spells\\Other\\CrushingWave\\CrushingWaveDamage.mdl", "chest")
              if xq:isboss() then
              elseif xq:iselite() then
                if xq:getperhp() <= 25 then
                  xq:groupadd(g)
                end
              else
                xq:groupadd(g)
              end
            end
            Effectcreate("war3mapImported\\specialanimedustwave.mdl", x, y, 0, 5)
            Effectcreate("war3mapImported\\[ake]war3ake.com - 1709800651073528605518801.mdl", x, y, 0, 10)
            Effectcreate("war3mapImported\\[TxNew]Water (6).mdl", x, y, 0, 3)
            for i = 1, 6 do
              local jd = GetRandomAngle()
              local jl = GetRandomReal(0, 900)
              local x1, y1 = PolarXY(x, y, jl, jd)
              Effectcreate("war3mapImported\\[TxNew]sun1.mdx", x1, y1, 45, 1, 0, 30, 0, 0, 0.1)
            end
            for i = 1, 24 do
              local jd = 15 * i
              local tx = Effectcreate("war3mapImported\\[TxNew]Water3.mdx", x, y, 1, 1, 0, jd)
              local jl = 0
              ac.timer(30, 30, function()
                jl = jl + 60
                local x1, y1 = PolarXY(x, y, jl, jd)
                SetEffectXY(tx, x1, y1)
              end)
            end
            ac.wait(1000, function()
              Effectcreate("war3mapImported\\[TxNew]Water32.mdl", x, y, 0, 2)
              local mj = u:createunit("u07Z", x, y)
              mj:timetoremove(45)
              mj:animespeed(0.1)
              mj:setcolor(255, 255, 255, 125)
              for i = 1, 6 do
                local jd = 60 * i
                local jl = 900
                local x1, y1 = PolarXY(x, y, jl, jd)
                Effectcreate("war3mapImported\\[TxNew]RainDrapsArea.mdl", x1, y1, 45, 1, 0, 0, 0, 0, 0.5)
                Effectcreate("war3mapImported\\[TxNew]rain2.mdl", x1, y1, 45)
              end
              for i = 1, 24 do
                local jd = 15 * i
                local tx = Effectcreate("war3mapImported\\[TxNew]Water3.mdx", x, y, 36.1, 1, 0, jd)
                local jl = 0
                ac.timer(100, 360, function()
                  jl = jl + 5
                  local x1, y1 = PolarXY(x, y, jl, jd)
                  SetEffectXY(tx, x1, y1)
                end)
              end
            end)
            local tm = 255
            ac.loop(250, function(timer)
              tm = tm - 1.5
              ForGroupLuaNew(g, function(xq)
                xq:animespeed(0)
                xq:buffset(u.handle, 1, "暂停")
                xq:setcolor(255, 255, 255, tm)
              end)
              if tm <= 25 then
                ForGroupLuaNew(g, function(xq)
                  ShowUnit(xq.handle, false)
                  local x2, y2 = xq:getxy()
                  Effectcreate("Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl", x2, y2)
                  xq:kill(u.handle, true)
                end)
                timer:remove()
              end
            end)
          end)
          ac.wait(5000, function()
            SetTimeOfDay(12)
            PlayGlobalSound(Sound_Tanzhilang_02)
          end)
          PlayBGM({
            bgm = 0,
            time = 55,
            ID = 10,
            unit = u.handle
          })
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chattrg(args)
      end)
      u:uivar_change({
        keyname = "鬼灭之刃",
        keytype = "传奇栏",
        text = "|cFFD6295C灶门炭治郎|r\n|cFF33FFFF战士 水 炎\n水之呼吸|r\n|cFF33FFFF参之型 流流舞|r\n|cFF33FFFF贰之型改 横水车|r\n|cFF33FFFF全集中.常中|r\n|cFF33FFFF鬼杀队|r\n|cFFFF3300拾之型 生生流转|r\n|cFFFF6600消耗体力 1\n使用基础位移技能后0.5秒内可以点击地面发动[流转之舞]|r\n|cFFFF3300拾贰之型 炎舞|r\n|cFFFF6600输入\"通透世界\"发动,在30秒内获得[日之呼吸]强化,冷却180秒|r\n|cFFFF3300火之神神乐|r\n|cFFFF6600[数据删除]|r",
        icon = "war3mapImported\\BTNEwl_Guimiezhiren2.blp",
        isclearclick = true
      })
    end
  end,
  ["Lily安娜"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-Lily安娜"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFF6633FF美杜莎|r|cFF7DBEF1]|r" .. NameID[sy])
      u:setdata(str)
      u:reduceshw()
      local wp = u:getitem("I02D")
      u:dropitem(wp)
      RemoveItemLua(wp)
      u:additem("I02C")
      u:become("从者")
      SendMsgAll("|cFF6633FF『|r|cFF6A38FF以|r|cFF6D3EFFL|r|cFF7143FFa|r|cFF7549FFn|r|cFF784EFFc|r|cFF7C54FFe|r|cFF7F59FFr|r|cFF835FFF的|r|cFF8764FF职|r|cFF8A6AFF阶|r|cFF8E6FFF现|r|cFF9275FF界|r|cFF957AFF。|r|cFF997FFF真|r|cFF9D85FF名|r|cFFA08AFF，|r|cFFA490FF美|r|cFFA895FF杜|r|cFFAB9BFF莎|r|cFFAFA0FF。|r|cFFB2A6FF请|r|cFFB6ABFF多|r|cFFBAB1FF指|r|cFFBDB6FF教|r|cFFC1BCFF。|r|cFFC5C1FF』|r", 30)
      PlayGlobalSound(Sound_Mds_02)
      u:addskill("S06S")
      u:adddivinity(3)
      AddUISkill({
        text = "女神的拥抱",
        u = u,
        cd = 210,
        icon = "war3mapImported\\BTNEwlSkill_Nvshendeyongbao.blp",
        func = function(args)
          local u = args.u
          if u:isalive() then
            u:chat("|cFF6633FF『|r|cFF7346FF女|r|cFF8059FF神|r|cFF8C6CFF的|r|cFF9980FF拥|r|cFFA693FF抱|r|cFFB2A6FF』|r")
            PlayGlobalSound(Sound_Mds_01)
            u:adddivinity(5)
            ac.wait(30000, function()
              u:adddivinity(-5)
            end)
            ac.timer(250, 120, function()
              local x, y = u:getxy()
              for _, xq in ac.selector():in_rangexy(x, y, 1200):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                local a1 = xq:getface()
                local a2 = AngleBetweenUnits(xq.handle, u.handle)
                local a = a1 - a2
                if 340 <= a then
                  a = a - 360
                end
                if a <= -340 then
                  a = a + 360
                end
                if a <= 20 and -20 <= a then
                  xq:effectadd("Abilities\\Spells\\Orc\\EtherealForm\\SpiritWalkerChange.mdl", "origin", 0.5)
                  xq:buffset(u.handle, 1, "石化")
                end
              end
            end)
          end
        end
      })
      u:addskill("S02Y")
      ForGroupLuaNew(Group_PlayHero, function(xq)
        local sy2 = xq.ownerid
        ChangeValue(DamageSystem_Baoji, sy, 10)
        ChangeValue(DamageSystem_Baoshang, sy, 0.15)
      end)
      local gl = 0
      local lwjs = 1
      local qsx = 0
      ac.loop(3000, function()
        u:changedata("全属性增幅", -1 * qsx)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * gl))
        ChangeValue(DamageSystem_Ssjianshao, sy, lwjs, 2)
        gl = 0.03 * u:getshenxing()
        lwjs = 1 - 0.02 * u:getshenxing()
        if lwjs <= 0.1 then
          lwjs = 0.1
        end
        qsx = 0.03 * u:getdata("女神力")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * gl))
        ChangeValue(DamageSystem_Ssjianshao, sy, lwjs, 1)
        u:changedata("全属性增幅", 1 * qsx)
      end)
      u:uivar_change({
        keyname = "魔眼",
        keytype = "传奇栏",
        text = "|cFFFFFF00Lily安娜|r\n|cFF1FBF00神性 3|r\n|cFF1FBF00女神的拥抱|r\n|cFFFFFF00允许使用宝具|r\n|cFF1FBF00女神的加护|r\n|cFFFFFF00每点神性提升0.3%伤害加成与2%论外减伤\n每点女神力提升1.5%全属性增幅\n降低周围敌军移速并有概率石化|r\n|cFF1FBF00魔眼Cybele|r\n|cFFFFFF00降低自身16%移速\n1200距离内敌军看向自己时每秒概率被石化\n距离自身越近被石化概率越高|r\n|cFF1FBF00彼方的追想|r\n|cFFFFFF00死亡后当有其他队友存活时自身复活 冷却400秒|r\n|cFF1FBF00屠戮不死之刃|r\n|cFFFFFF00杀敌时提升0.01%近战伤害与0.01%伤害加成\n提升150%镰刀武器伤害\n提升50%镰刀武器范围\n使用近战武器时会自动挥动不死之刃\n造成[75%*近战武器伤害值+10%(1%当前)最大生命值]近战物理生命移除伤害同时25%石化1秒|r\n|cFF1FBF00骑英之缰绳|r\n|cFFFFFF00提升全体15%移速\n提升全体10%暴击率与15%暴击伤害|r\n|cFFFF0000不可能の明日|r",
        icon = "war3mapImported\\BTNEwl_Lilyana.blp",
        clickfunc = function(u, button)
          if not u:hasdata("Lily安娜-不死之刃关闭") then
            u:setdata("Lily安娜-不死之刃关闭")
            u:sendmessage("|cFF7DBEF1屠戮不死之刃关闭|r")
          else
            u:deldata("Lily安娜-不死之刃关闭")
            u:sendmessage("|cFF7DBEF1屠戮不死之刃开启|r")
          end
        end
      })
    end
  end,
  ["西行寺幽幽子"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-西行寺幽幽子"
    if not u:hasdata(str) then
      u:deldata("变异判定-吃货")
      u:setplayername("|cFF7DBEF1[|r|cFFFF99FF西行寺幽幽子|r|cFF7DBEF1]|r" .. NameID[sy])
      u:setdata(str)
      u:reduceshw()
      Weiyi[22] = true
      SendMsgAll("|cFFFF99FF「|r|cFFF290FF厌|r|cFFE688FF离|r|cFFD980FF秽|r|cFFCC77FF士|r|cFFBF6EFF |r|cFFB266FF欣|r|cFFA65EFF求|r|cFF9955FF净|r|cFF8C4CFF土|r|cFF8044FF」|r")
      u:changedata("灵魂数量", 1)
      u:changedata("灵魂变异数量", 1)
      u:setdata("西行寺幽幽子-支配死灵", 0)
      u:getgoddessforce(2)
      local jc = 0
      ac.loop(2500, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-0.01 * jc))
        jc = u:getdata("西行寺幽幽子-支配死灵")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (0.01 * jc))
        if u:isingroup(Group_DeathHero) then
          ForGroupLuaNew(Group_Monster, function(xq)
            AdvanceHelpers.uuz_szbmzl(u, xq)
          end)
        end
      end)
      AddUISkill({
        text = "幽幽子-返魂",
        u = u,
        cd = 180,
        icon = "war3mapImported\\BTNEwlSkill_Yuyuko_01.blp",
        func = function(args)
          local u = args.u
          if u:isalive() then
            local zu = {}
            for i = 1, 6 do
              if Xuanze[i] then
                local xq = getunit(Hero[i])
                if not xq:isalive() and xq:isingroup(Group_PlayHero) and not xq:hasdata("身体判定-蓬莱人") then
                  table.insert(zu, xq)
                end
              end
            end
            if 0 < #zu then
              local mb = zu[GetRandomInt(1, #zu)]
              local name = mb:getplayername()
              local str2 = {}
              str2[1] = "|cFFCC66FF此刻正是，审判之时！|r" .. name .. "|cFFCC66FF!|r"
              str2[2] = "|cFFCC66FF此时此刻正乃极致之时！|r" .. name .. "|cFFCC66FF!|r"
              str2[3] = "|cFFCC66FF苏醒吧，|r" .. name
              str2[4] = "|cFFCC66FF站起来吧，我的朋友，|r" .. name
              str2[5] = "|cFFCC66FF我们的路程,致死不休。|r"
              local zs
              if u:getluckrandom(1) then
                zs = 5
              else
                zs = GetRandomInt(1, 4)
              end
              SendMsgAll(str2[zs])
              local x, y = u:getxy()
              HeroRelive(mb.handle, x, y, 3)
              mb:effectadd("ATX\\[ATxNew]Pink_12.mdl")
              if zs ~= 5 then
                mb:effectadd("ATX\\[ATxNew]Pink_07.mdl", "origin", 60)
                ac.wait(60000, function()
                  mb:setdata("返魂-致死判定")
                  mb:kill()
                  mb:deldata("返魂-致死判定")
                end)
              end
            else
              u:sendmessage("|cFFCC66FF没有可复活单位|r")
            end
          end
        end
      })
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        AdvanceHelpers.uuz_szbmzl(u, tg)
        local info = args.damageinfo
        if u:getluckrandom(5 * info.txgl) and not u:hasdata("返魂蝶冷却") then
          u:playsound(Sound_Yoyoko_02)
          u:settimedata("返魂蝶冷却", 1)
          local x, y = u:getxy()
          local angle = AngleBetweenUnits(u.handle, tg.handle)
          unifycreate({
            owner = u.handle,
            model = "war3mapImported\\hudiedanmu.mdl",
            modelname = "返魂蝶",
            modelsize = 1.5,
            height = 50,
            damage = 0,
            damagetype = 6,
            x = x,
            y = y,
            range = 1250,
            time = 1.5,
            volume = 120,
            angle = angle,
            angleoffset = 0,
            attenua = 1,
            attenuacount = 1,
            life = 10,
            isbullet = false,
            isvest = false,
            isignorearmor = false,
            startfunc = function(mj)
              mj:setdata("循环计数", 0)
              mj:setcolor(153, 0, 204)
            end,
            loopfunc = function(mj)
              mj:changedata("循环计数", UnifyDT)
              if mj:getdata("循环计数") >= 0.03 then
                mj:setdata("循环计数", 0)
              end
            end,
            hitfunc = function(mj, damage)
              return damage
            end,
            hitbeforefunc = function(mj, xq, damage2)
            end,
            hitafterfunc = function(mj, xq, damage2)
              xq:playsound(Sound_Yoyoko_04)
              for i = 1, 10 do
                AdvanceHelpers.uuz_szbmzl(u, xq)
              end
              local x2, y2 = xq:getxy()
              Effectcreate("ATX\\[ATxNew]Pink_01.mdl", x2, y2)
            end,
            endfunc = function(mj)
              mj:setcolor(255, 255, 255)
            end
          })
        end
      end)
      if u:hasdata("血统判定-冥神") and not u:hasdata("冥神-现冥") then
        u:setdata("冥神-现冥进阶标记")
        u:deldata("冥神-现冥杀敌计数")
      end
      u:uivar_remove("吃货", "冥王栏")
      u:uivar_add({
        keyname = "西行寺幽幽子",
        keytype = "传奇栏",
        text = "|cFFFF99FF西行|r|cFFD980FF寺幽|r|cFFB266FF幽子|r\n|cFFB266FF东方 灵魂\n支配死灵|r\n|cFFFF99FF免疫灵魂类伤害\n每杀死一个单位提升0.05%伤害加成修正,死亡时减半|r\n|cFFB266FF死亡操纵|r\n|cFFFF99FF允许使用[返魂](随机复活一名死亡玩家持续60秒,持续时间结束时目标必定死亡,无视彻底死亡以外的效果)\n自身彻底死亡时将复活并在12(24)秒内无限复活,到达时间后死亡,无视任何复活效果,触发冷却600秒|r\n|cFFB266FF生者必灭之理|r\n|cFFFF99FF直接伤害时(1%/0.1%/1%)超即死目标(对BOSS为造成1%最大生命值灵力生命移除伤害),如果没有触发则概率提升至1.01倍,无叠加上限\n自身处于死亡状态时,每2.5秒对所有敌对存活单位触发一次生者必灭之理|r\n|cFFB266FF反魂蝶|r\n|cFFFF99FF直接伤害时5%召唤一只反魂蝶向前方飞行,对触碰到的第一个单位判定十次生者必灭之理(触发冷却1秒)|r\n|cFFB266FF反魂胃|r\n|cFFFF99FF杀敌20%提升1点属性\n吃下食物时35%提升1点属性\n喝下药水时25%提升1点属性\n降低20%抗药性获取|r",
        icon = "war3mapImported\\BTNEwl_Yuyuko_Shenhua.blp",
        isclearclick = true
      })
    end
  end,
  ["散华礼弥"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-散华礼弥"
    if not u:hasdata(str) then
      u:changedata("唯一变异数量", 1)
      u:deldata("血统判定-僵尸")
      u:setplayername("|cFF7DBEF1[|r|cFF9999FF散华礼弥|r|cFF7DBEF1]|r" .. NameID[sy])
      u:setdata(str)
      u:reduceshw()
      Weiyi[17] = true
      SendMsgAll("|cFF9999FF四|r|cFF9797F8散|r|cFF9494F1的|r|cFF9292EA华|r|cFF9090E3丽|r|cFF8D8DDC之|r|cFF8B8BD5乐|r|cFF8989CE章|r|cFF8686C7，|r|cFF8484C0讴|r|cFF8282B9歌|r|cFF8080B2着|r|cFF7D7DAC圣|r|cFF7B7BA5弥|r|cFF79799E赛|r|cFF767697亚|r|cFF747490的|r|cFF727289降|r|cFF6F6F82临|r|cFF6D6D7B…|r|cFF6B6B74…|r")
      u:getgoddessforce(1)
      ChangeValue(Revise_PoisonResist, sy, 1)
      ChangeValue(DamageSystem_EndSh, sy, 0.010000000000000002)
      u:changedata("全属性增幅", 0.05)
      u:addallstats(100)
      u:addstexiao(str, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("散华礼弥-紫阳花超强化") then
          info.wsmy = true
          info.wssb = true
        end
      end)
      local jz = 0
      local hp = 0
      local hd = 0
      ac.loop(1000, function()
        ChangeValue(Correction_Jzsh, sy, 0.1 * -jz)
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, -hp)
        ChangeValue(Hudun_Huifu, sy, -hd)
        if u:isalive() then
          if u:getdata("无感累积伤害") > 0 then
            u:effectadd("Abilities\\Spells\\Human\\Feedback\\ArcaneTowerAttack.mdl")
            local shz = 0.1 * u:getdata("无感累积伤害")
            u:changedata("无感累积伤害", -1 * shz)
            u:losshp(u, shz)
          end
          if u:hasdata("散华礼弥-尸骸活化") then
            u:changedata("紫阳花强化时间", 2)
          end
          if 0 < u:getdata("紫阳花超强化时间") then
            u:changedata("紫阳花超强化时间", -1)
            if not u:hasdata("散华礼弥-紫阳花超强化") then
              u:setdata("散华礼弥-紫阳花超强化")
            end
          else
            u:setdata("紫阳花超强化时间", 0)
            if u:hasdata("散华礼弥-紫阳花超强化") then
              u:deldata("散华礼弥-紫阳花超强化")
            end
          end
          if 0 < u:getdata("紫阳花强化时间") then
            jz = 0.18 * u:getstate("不死变异")
            hd = 1 * u:getstate("不死")
            hp = 1 * u:getstate("不死")
            u:changedata("紫阳花强化时间", -1)
            if not u:hasdata("散华礼弥-紫阳花强化") then
              u:setdata("散华礼弥-紫阳花强化")
              u:addskill("A136")
              ChangeValue(DamageSystem_EndSh, sy, 0.010000000000000002)
              ChangeValue(HeroMenu_HpForever_MaxHp, sy, 1)
            end
          else
            jz = 0
            hd = 0
            hp = 0
            u:setdata("紫阳花强化时间", 0)
            if u:hasdata("散华礼弥-紫阳花强化") then
              u:deldata("散华礼弥-紫阳花强化")
              u:delskill("A136")
              ChangeValue(DamageSystem_EndSh, sy, -0.010000000000000002)
              ChangeValue(HeroMenu_HpForever_MaxHp, sy, -1)
            end
          end
        else
          u:setdata("无感累积伤害", 0)
          jz = 0
          hd = 0
          hp = 0
        end
        ChangeValue(Correction_Jzsh, sy, 0.1 * jz)
        ChangeValue(Hudun_Huifu, sy, hd)
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, hp)
      end)
      u:addstexiao(str, "被施加Buff时效果-僵直", function(args)
        if not Keyan_Guomintizhi then
          args.time = 0
        end
      end)
      u:addstexiao(str, "被施加Buff时效果-眩晕", function(args)
        if not Keyan_Guomintizhi then
          args.time = 0
        end
      end)
      ac.loop(1000, function(timer)
        if u:hasdata("礼祢-解锁拓展技能") then
          u:sendmessage("|cFF6633FF解锁拓展技能|r")
          timer:remove()
          u:deldata("礼祢-解锁拓展技能")
          local dskill = S2ID("A1S6")
          u:byladdskill(dskill, function(args)
            if args.skill == dskill then
              local b = true
              local ewl = getunit(args.unit)
              local tg = getunit(args.target)
              if not u:isalive() then
                b = false
                u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
              end
              if not tg:isingroup(Group_PlayHero) then
                b = false
                u:sendmessage("|cFF7DBEF1只能以英雄为目标|r")
              end
              if tg.handle == u.handle then
                b = false
                u:sendmessage("|cFF7DBEF1不能以自己为目标|r")
              end
              if tg:getmaxhp() <= 20000 or tg:getstr() <= 100 or 100 >= tg:getagi() or 100 >= tg:getint() then
                b = false
                u:sendmessage("|cFF7DBEF1目标属性不足|r")
              end
              if b then
                u:sendmessage("|cFF6633FF你想要吃掉|r" .. tg:getplayername())
                tg:sendmessage("|cFF6633FF礼祢想要吃掉你,在10秒内输入“拒绝”来拒绝被吃掉|r")
                ac.wait(10000, function()
                  local b2 = true
                  if tg:hasdata("散华礼弥-拒绝被吃") then
                    b2 = false
                    tg:deldata("散华礼弥-拒绝被吃")
                  end
                  if not b2 and u:getmaxhp() > tg:getmaxhp() and u:getallattri() > tg:getallattri() then
                    b2 = true
                    tg:sendmessage("|cFF6633FF你拒绝被吃,但是礼祢直接压上来了……|r")
                  end
                  if b2 then
                    SendMsgAll(tg:getplayername() .. "|cFF6633FF被|r" .. u:getplayername() .. "|cFF6633FF吃掉了|r")
                    ewl:delskill("A1S6")
                    local downhp = 0.5 * tg:getmaxhp()
                    local downall = 100
                    tg:changemaxhp(-1 * downhp)
                    u:changemaxhp(1 * downhp)
                    tg:addallstats(-1 * downall)
                    u:addallstats(downall)
                    tg:kill(u.handle, true)
                    flashphoto({
                      photo = "Ph_Limi.tga"
                    })
                    local cs = 0
                    ac.loop(1000, function()
                      cs = cs + 1
                      u:changemaxhp(1)
                      tg:changemaxhp(-1)
                      if cs == 60 then
                        cs = 0
                        u:addrandomstats(3)
                        tg:addallstats(-1)
                      end
                    end)
                    ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 125)
                    u:setdata("散华礼弥-尸骸活化")
                    u:uivar_change({
                      keyname = "散华礼弥",
                      keytype = "传奇栏",
                      text = "|cFF6633FF散华礼弥|r\n|cFF6633FF不死 黑暗 唯一\n尸骸活化|r\n|cFF9999FF提升250%移速\n提升1%终结伤害\n提升[1.8%*不死变异]近战伤害\n提升[1%*不死]永恒恢复\n提升[1%*不死]护盾恢复速度|r\n|cFF6633FF混沌思维|r\n|cFF9999FF食用紫阳花时永久提升50护盾上限\n提升5%全属性\n提升1%终结伤害\n提升100点全属性|r\n|cFF6633FF僵尸意识|r\n|cFF9999FF免疫精神类影响\n免疫僵直与眩晕\n免疫毒素与疾病\n食用紫阳花提升2%随机伤害修正与1点属性,30秒内提升2.5%伤害加成,无视伤害抗性与伤害减免,可叠加,分立计时\n食用紫阳花不会降低属性与生命值且属性固定概率提升至30%;食用紫阳花时立刻进行一次属性结算判定|r\n|cFF6633FF钝感|r\n|cFF9999FF每秒损耗[10%当前累积伤害]生命值,不致死,单次受伤不会超过100%最大生命值\n只受到40%有效伤害,剩余40%伤害累积\n死亡或复活时清零|r\n|cFF6633FF吃夫证道|r\n|cFF9999FF每秒提升1点生命上限\n每60秒提升3点属性|r",
                      icon = "Ewl_Limi_01",
                      isclearclick = true
                    })
                    tg:uivar_add({
                      keyname = "散华礼弥-死亡迟钝",
                      keytype = "疾病栏",
                      text = "|cFF6633FF死亡迟钝|r\n|cFF6633FF失去了心脏,但是被散华注入了过量僵尸毒素导致对[死亡]的钝感\n每秒降低1点生命上限\n每60秒降低1点全属性|r",
                      icon = "Ewl_Limi_03"
                    })
                  else
                    u:sendmessage(tg:getplayername() .. "|cFF6633FF拒绝被吃掉|r")
                    tg:sendmessage("|cFF6633FF你拒绝了被礼祢吃掉|r")
                  end
                end)
              else
                ewl:setskillcd(dskill, 1)
              end
            end
          end)
          
          local function chattrg(args)
            if args.chat == "拒绝" then
              local tg = args.u
              tg:setdata("散华礼弥-拒绝被吃")
            end
          end
          
          ForGroupLuaNew(Group_PlayHero, function(xq)
            if xq.handle ~= u.handle then
              xq:addtrgevent("玩家-聊天", function(args)
                chattrg(args)
              end)
            end
          end)
        end
      end)
      u:uivar_remove("僵尸", "血统栏")
      u:uivar_add({
        keyname = "散华礼弥",
        keytype = "传奇栏",
        text = "|cFF6633FF散华礼弥|r\n|cFF6633FF不死 黑暗 唯一\n尸化|r\n|cFF9999FF提升250%移速\n提升10%原始伤害\n提升[18*不死变异]近战伤害\n提升[1%*不死]永恒恢复\n提升[1%*不死]护盾恢复速度|r\n|cFF6633FF混沌思维|r\n|cFF9999FF食用紫阳花时永久提升50护盾上限\n提升5%全属性\n提升1%终结伤害\n提升100点全属性|r\n|cFF6633FF僵尸意识|r\n|cFF9999FF免疫精神类影响\n免疫僵直与眩晕\n免疫毒素与疾病\n[尸化]效果无效化,降低自身99%生命恢复效果,食用紫阳花时这个效果失效180秒\n食用紫阳花提升1%随机伤害修正,30秒内提升2.5%伤害加成,无视伤害抗性与伤害减免,可叠加,分立计时\n食用紫阳花不会降低属性与生命值且属性固定概率提升至30%|r\n|cFF6633FF无感|r\n|cFF9999FF每秒损耗[10%当前累积伤害]生命值,不致死,单次受伤不会超过100%最大生命值\n只受到50%有效伤害,剩余50%伤害累积\n死亡或复活时清零|r",
        icon = "war3mapImported\\BTNEwl_Xuetong_Jiangshi.blp",
        isclearclick = true
      })
    end
  end,
  ["旗木卡卡西"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-卡卡西"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFF336699旗木卡卡西|r|cFF7DBEF1]|r" .. NameID[sy])
      u:deldata("变异判定-写轮眼")
      u:setdata(str)
      u:reduceshw()
      Weiyi[15] = true
      u:chat("万花筒写轮眼！")
      PlayGlobalSound(Yinxiao_Kakaxi1)
      u:changedata("雷变异数量", 1)
      u:changedata("影变异数量", 1)
      u:changedata("闪避值", 18)
      ChangeValue(DamageSystem_Baoji, sy, 12)
      u:addstexiao(str, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if u:hasdata("卡卡西-神威") then
          info.wsmy = true
        end
      end)
      u:addstexiao("旗木卡卡西", "近战伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        if not u:hasdata("旗木卡卡西-特效冷却") then
          local x, y = tg:getxy()
          local cd = 2.5
          local lv = 1
          if u:hasdata("卡卡西-神威") then
            lv = 5
            cd = 0.5
          end
          u:settimedata("旗木卡卡西-特效冷却", cd)
          ChangeTimeValue(HeroMenu_ExtraMoveSpeed, sy, 125, 3)
          u:effectadd("Abilities\\Spells\\Orc\\LightningShield\\LightningShieldTarget.mdl", "origin", 3)
          Effectcreate("war3mapimported\\great lightning.mdl", x, y, 0, 2.5)
          u:buffset(u.handle, 0.25, "绝对闪避")
          u:playsound(Yinxiao_Kakaxi2)
          local txsh = 7500 + 200 * u:getlevel()
          for _, xq in ac.selector():in_rangexy(x, y, 350):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "旗木卡卡西附伤",
              unit = xq.handle,
              source = u.handle,
              damage = txsh,
              level = lv,
              type = "灵力",
              isvest = false,
              isattack = false,
              isnoarmor = false,
              element = "雷"
            })
            xq:buffset(u.handle, 1, "眩晕")
          end
        end
      end)
      u:addstexiao(str, "伤害判定后特效", function(args)
        local tg = args.tg
        local u = args.u
        if u:hasdata("卡卡西-神威") then
          tg:changemaxhp(-0.25 * args.damage)
        end
      end)
      
      local function chattrg(args)
        if (args.chat == "神威" or args.chat == "Kamui") and u:isalive() and not u:hasdata("卡卡西-神威") and not u:hasdata("神威冷却") then
          u:setdata("卡卡西-神威")
          u:playsound(Yinxiao_Kakaxi3)
          u:changedata("闪避值", 200)
          ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 400)
          local zjsh = 0
          ac.loop(250, function(t)
            ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * zjsh))
            zjsh = 0.002 * u:getdata("卡卡西-神威杀敌")
            ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * zjsh))
            u:losshp(u, 0, 0, 1.25)
            local x, y = u:getxy()
            Effectcreate("war3mapimported\\bbb.mdl", x, y, 0, 3.2)
            for _, xq in ac.selector():in_rangexy(x, y, 900):is_enemy(u.handle):ipairs() do
              xq = getunit(xq)
              xq:effectadd("Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl", "overhead")
              if xq:isnormal() then
                xq:buffset(u.handle, 1, "暂停")
              else
                xq:buffset(u.handle, 1, "僵直")
              end
            end
            if not (not (u:getperhp() <= 5) and u:hasdata("卡卡西-神威")) or not u:isalive() then
              ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * zjsh))
              u:changedata("闪避值", -200)
              ChangeValue(HeroMenu_ExtraMoveSpeed, sy, -400)
              u:deldata("卡卡西-神威")
              u:settimedata("神威冷却", 15)
              ac.wait(15000, function()
                u:sendmessage("神威冷却完毕")
              end)
              t:remove()
            end
          end)
        end
        if args.chat == "闭" then
          u:deldata("卡卡西-神威")
          u:sendmessage("神威关闭")
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chattrg(args)
      end)
      u:uivar_change({
        keyname = "写轮眼",
        keytype = "传奇栏",
        text = "|cFF336699旗木卡卡西|r\n|cFF336699雷 影\n百景千微|r\n|cFF6699CC无视精英特性交错与模糊\n提升27%暴击率与33闪避值\n反弹普通弹幕(触发冷却1秒)\n受到来自自身视野内单位伤害时33%(11%)免疫|r\n|cFF336699复刻|r\n|cFF6699CC受到伤害时,在7.5(3/1.5)秒内不再受到该单位类型伤害|r\n|cFF336699神威|r\n|cFF6699CC杀敌时提升在神威状态下0.02%伤害加成\n输入“神威”发动神威 输入\"闭\"关闭 冷却15秒\n神威状态：\n每秒损耗5%最大生命值,不足5%时强制关闭\n雷切冷却降低至0.5秒且变为抹除伤害\n无视伤害抗性与伤害减免且削除[25%*最终值]生命上限\n每0.25秒时停(僵直)自身周围900范围敌军1秒\n提升200闪避值与400额外移速同时无视地形|r\n|cFF336699雷切|r\n|cFF6699CC造成近战伤害时造成350范围[7500+200*等级]灵力纯粹伤害与1秒眩晕(触发冷却2.5秒)\n发动后0.25秒绝对闪避并在3秒内提升125额外移速|r",
        icon = "war3mapImported\\BTNEwl_qimukakaxi.blp",
        isclearclick = true
      })
    end
  end,
  ["冲田总司"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-冲田总司"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFFFF66FF冲田总司|r|cFF7DBEF1]|r" .. NameID[sy])
      u:setdata(str)
      u:reduceshw()
      Weiyi[2] = true
      u:chat("一起战斗至最后一刻吧！")
      u:become("从者")
      PlayBGM({
        bgm = BGM_Chongtianzongsi_1,
        time = 95,
        ID = 87,
        unit = u.handle
      })
      if u:hasdata("隐藏职业-天才剑士") then
        u:setdata("天才剑士-近战加成系数", 0.02)
        hideproshow(u.handle)
      end
      ChangeValue(DamageSystem_Shjc, sy, 0.012)
      ChangeValue(DamageSystem_Shjc, sy, 0.012)
      ChangeValue(DamageSystem_Shjc, sy, 0.012)
      ChangeValue(DamageSystem_Shjc, sy, 0.012)
      ChangeValue(DamageSystem_Baoji, sy, 12)
      ChangeValue(DamageSystem_Txsh, sy, 0.25)
      moveskillreplace({
        unit = u.handle,
        level = 1,
        skill_Q = "A14T",
        skill_W = "A052",
        isforce = false,
        efunc = function()
          u:setdata("冲田总司-缩地次数", 0)
          u:addtrgevent("单位-指定点目标指令", function(args)
            if args.orderid == String2OrderIdBJ("smart") and u:getdata("冲田总司-缩地次数") > 0 then
              u:changedata("冲田总司-缩地次数", -1)
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local angle = AngleXY(x, y, x2, y2)
              local dis = DistanceXY(x, y, x2, y2)
              local mjl = GetUnitMoveSpeed(u.handle) + 0.1 * u:getdata("当前额外移速")
              if u:hasdata("禁忌判定-樱总司") then
                mjl = mjl * 1.5
              end
              if dis >= mjl then
                dis = mjl
              end
              local key = "Q"
              if GetRandom100(50) then
                key = "W"
              end
              Effectcreate("Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl", x, y)
              Effectcreate("war3mapImported\\blackblink.mdx", x, y)
              Effectcreate("war3mapImported\\specialanimedustwave.mdx", x, y)
              Effectcreate("war3mapImported\\bbb.mdx", x, y)
              movexg(u.handle, 0.25, S2ID("A14T"), key, "冲田总司-缩地")
              unitmove({
                unit = u.handle,
                time = 0.15,
                distance = dis,
                angle = angle,
                endfunc = function(dx, dy)
                  Effectcreate("Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl", dx, dy)
                  Effectcreate("war3mapImported\\blackblink.mdx", dx, dy)
                  u:setdata("位移点X", dx)
                  u:setdata("位移点Y", dy)
                end,
                isblink = true
              })
            end
          end)
        end
      })
      local sbz = 0
      ac.loop(3000, function()
        u:changedata("闪避值", -1 * sbz)
        sbz = 0.4 * u:getdata("显示-暴击率")
        u:changedata("闪避值", 1 * sbz)
      end)
      u:addstexiao(str, "暴击系统触发效果", function(args)
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(str .. "-心眼冷却") then
          u:settimedata(str .. "-心眼冷却", 2)
          u:changetimedata("闪避值", 200, 0.5)
          u:effectadd("Abilities\\Spells\\Human\\ControlMagic\\ControlMagicTarget.mdl", "overhead")
        end
      end)
      u:uivar_change({
        keyname = "病弱",
        keytype = "传奇栏",
        text = "|cFFFFFF00冲田总司|r\n|cFF1FBF00无明三段突|r\n|cFFFFFF00每次造成伤害时33%造成二次伤害(物理伤害 触发特效) 同一次伤害中最多连续触发两次,冷却0.25秒|r\n|cFF1FBF00缩地|r\n|cFFFFFF00基础位移技能变更为[缩地]|r\n|cFF1FBF00心眼|r\n|cFFFFFF00杀敌时提升0.01%近战伤害,如果装备武器是武士刀则提升0.15%\n提升2.4%伤害加成\n提升24%暴击率\n提升[暴击率*40%]闪避值\n触发暴击时自身0.5秒内提升200闪避值(冷却2秒)|r\n|cFF1FBF00病弱|r\n|cFFFFFF00每10秒18%触发咳血使该效果失效10秒\n允许[无明三段突]触发第三段\n提升2%最终伤害与伤害加成\n提升25%非近战特效伤害|r\n|cFF949596“现在就是那个时候了。”|r",
        icon = "war3mapImported\\BTNEwl_Chongtianzongsi_Shenhua.blp",
        isclearclick = true
      })
    end
  end,
  ["少名针妙丸"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-少名针妙丸"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFFFF3399少名针妙丸|r|cFF7DBEF1]|r" .. NameID[sy])
      u:setdata(str)
      u:reduceshw()
      Weiyi[20] = true
      SendMsgAll("|cFFFF3399『来吧，让我们构筑起一个不会遗弃弱者的乐园吧！』|r")
      u:changedata("闪避值", 20)
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 25)
      ChangeValue(Hero_Tili_Huifu, sy, 1)
      ChangeValue(DamageSystem_Shjc, sy, 0.025)
      u:addskill("A0D3")
      ForGroupLuaNew(Group_PlayHero, function(xq)
        xq:changedata("幸运", 1)
      end)
      u:addrandomstats(20 + u:getlevel())
      Qiyue_Zuiqiangerren_Zhenmiaowa = u.handle
      u:addstexiao("少名针妙丸", "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata("少名针妙丸" .. "-特效冷却") and u:getluckrandom(1 * info.txgl) then
          tg:effectadd("war3mapImported\\59.mdl")
          local txsh = GetRandomReal(1, 9999) * u:getdata("幸运")
          u:changetimedata("幸运", 1, 15)
          DamageUnit({
            bj = "少名针妙丸附伤",
            unit = tg.handle,
            source = u.handle,
            damage = txsh,
            level = 5,
            type = "物理",
            isvest = true,
            isattack = true,
            isnoarmor = false,
            element = "无"
          })
          u:settimedata("少名针妙丸" .. "-特效冷却", 1)
        end
      end)
      u:uivar_remove("小人族", "冥王栏")
      u:uivar_add({
        keyname = "少名针妙丸",
        keytype = "传奇栏",
        text = "|cFFFF99CC少名针妙丸|r\n|cFFFF3399小人族|r\n|cFFFF99CC获取时提升[20+等级]属性同时提升1点属性成长\n单次受伤不会大于80%MHP\n吸收妖气时提升1点属性、吸收血晶时提升1-3点属性\n血统反噬时使自身在60秒内提升10点力量与2.5%伤害加成 可叠加 分立计时|r\n|cFFFF3399一寸法师|r\n|cFFFF99CC提升20%移速与25额外移速\n提升1魔力恢复与2.5%伤害加成\n提升0.06闪避系数与20闪避值|r\n|cFFFF3399辉针剑|r\n|cFFFF99CC直接伤害时1%附带[幸运*1~9999]近战物理抹除伤害并在15秒内提升自身1点幸运值,冷却1秒|r\n|cFFFF3399全小人族的绯想天|r\n|cFFFF99CC提升所有玩家10%移速与1点幸运\n提升[存活玩家数量*2.5%]伤害加成\n提升[存活玩家数量*10%]追加减伤\n提升[存活玩家数量*1]幸运|r\n|cFFFF3399可爱的太公望|r\n|cFFFF99CC使用万宝槌(伪)时提升自身3点属性\n开箱时几率获得万宝槌|r",
        icon = "war3mapImported\\BTNEwl_Shenhua_Shaomingzhenmiaowan.blp",
        isclearclick = true
      })
    end
  end,
  ["远野志贵"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-远野志贵"
    if not u:hasdata(str) then
      if not u:hasdata("奈落の羁绊") then
        u:setplayername("|cFF7DBEF1[|r|cFF0033FF远野志贵|r|cFF7DBEF1]|r" .. NameID[sy])
        u:chat("那么,让我们开始吧")
        PlayGlobalSound(ZG_G2_Words)
      end
      u:deldata("变异判定-退魔眼")
      u:setdata(str)
      u:reduceshw()
      Weiyi[4] = true
      u:groupadd(Group_Yueji)
      PlayBGM({
        bgm = BGM_Yuanye_01,
        time = 215,
        ID = 108,
        unit = u.handle
      })
      coopjudge("瓦拉齐亚之夜")
      u:addstexiao(str, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        info.pk_shouhu = true
        info.pk_jiaocuo = true
        if u:hasdata("远野志贵-直死魔眼") then
          info.pk_genxing = true
          info.pk_benyuan = true
          info.pk_jinshou = true
          info.pk_mohu = true
          info.pk_tiebi = true
          info.pk_zhiyuan = true
        end
      end)
      u:changedata("月姬变异数量", 1)
      ChangeValue(DamageSystem_Shjc, sy, 0.013)
      ChangeValue(DamageSystem_Shjc, sy, 0.013)
      u:addstexiao("远野志贵", "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if args.damage >= 777 then
          local jl = 13
          if u:ishasskill("S031") then
            jl = 26
          end
          if u:hasdata("瓦拉齐亚之夜-夜晚强化") then
            jl = jl * 2
          end
          if not u:hasdata("远野志贵-特效冷却") and u:getluckrandom(jl * info.txgl) then
            u:settimedata("远野志贵-特效冷却", 0.5)
            local x, y = tg:getxy()
            Effectcreate("war3mapImported\\arcdirve02b.mdl", x, y)
            local txsh
            if tg:isnormal() then
              txsh = 0.07 * tg:getmaxhp()
            elseif tg:iselite() then
              txsh = 0.017 * tg:getmaxhp()
            else
              txsh = 0.017 * tg:gethp()
            end
            DamageUnit({
              bj = "远野志贵附伤",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 4,
              type = "物理",
              isvest = true,
              isattack = true,
              isnoarmor = false,
              element = "无"
            })
            if u:ishasskill("S031") then
              u:changedata("分割计数", 1)
              if tg:isnormal() then
                if tg:getdata("分割计数") >= 7 then
                  tg:deldata("分割计数")
                  tg:kill(u.handle, false)
                end
              elseif tg:getdata("分割计数") >= 17 then
                tg:deldata("分割计数")
                if not tg:isboss() then
                  txsh = 0.17 * tg:getmaxhp()
                  DamageUnit({
                    bj = "远野志贵分割附伤",
                    unit = tg.handle,
                    source = u.handle,
                    damage = txsh,
                    level = 4,
                    type = "物理",
                    isvest = true,
                    isattack = true,
                    isnoarmor = true,
                    element = "无"
                  })
                else
                  LossHpUnit({
                    u = u,
                    tg = tg,
                    damage = 0,
                    perhp = 3.7,
                    maxhp = 0,
                    bj = "[生命损耗]远野志贵"
                  })
                end
              end
            end
          end
        end
      end)
      
      local function chattrg(args)
        if (args.chat == "直死魔眼" or args.chat == "Chokushi no Magan") and u:isalive() and not u:hasdata("变异判定-噩梦志贵") and not u:ishasskill("S031") then
          u:addskill("S031")
          u:setdata("远野志贵-直死魔眼")
          local add = 0.17
          if u:hasdata("物品-粉色墨镜") then
            add = add * 2
          end
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
          u:playsound(ZG_T1)
          ac.loop(250, function(t)
            if not u:hasdata("变异判定-奈落の花") and not u:hasdata("瓦拉齐亚之夜-夜晚强化") then
              local loss = 0.25
              if u:hasdata("物品-粉色墨镜") then
                loss = loss * 0.5
              end
              u:losshp(u, 0, loss * 1.7, loss * 0.7)
            end
            if not (not (u:getperhp() <= 5) and not u:hasdata("变异判定-噩梦志贵") and u:isalive()) or not u:hasdata("远野志贵-直死魔眼") then
              ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * add))
              ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * add))
              u:delskill("S031")
              u:clearbuff("B04X")
              if u:hasdata("远野志贵-直死魔眼") then
                u:deldata("远野志贵-直死魔眼")
                u:playsound(ZG_T)
              end
              t:remove()
            end
          end)
        end
        if args.chat == "魔眼杀" or args.chat == "Magan Koroshi" then
          u:deldata("远野志贵-直死魔眼")
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chattrg(args)
      end)
      
      local function shikianimeact(u, value, speed)
        ac.wait(1, function()
          ResetUnitAnimation(u.handle)
          u:animespeed(speed)
          u:animeact(value)
        end)
      end
      
      local dskill
      if u:ishasskill("A1AM") and u.type ~= HeroType["C呆"] and u.type ~= HeroType["莲华"] then
        dskill = "A1SC"
      else
        dskill = "A1LL"
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
              local tilixh = 3
              
              if not u:hasdata("位移体力消耗标记") then
                if u:lossstamina(tilixh) then
                  u:settimedata("位移体力消耗标记", 0.001)
                else
                  u:setskillcd(args.skill, 0.01)
                  u:sendmessage("|cFFFF3300体力值不足|r")
                  return
                end
              end
              local x, y = u:getxy()
              local x1 = args.x
              local y1 = args.y
              local angle = AngleXY(x, y, x1, y1)
              local dis = DistanceXY(x, y, x1, y1)
              u:setface(angle)
              local txsh = 777 * u:getagi()
              local xh = 0
              if u:hasdata("远野志贵-直死魔眼") then
                xh = 0.7
              end
              u:buffset(u.handle, 2.1, "暂停")
              u:buffset(u.handle, 2.5, "无敌")
              u:buffset(u.handle, 0.4, "绝对闪避")
              local g2 = CreateGroupLua()
              for _, xq in ac.selector():in_rangexy(x1, y1, 350):is_enemy(u.handle):ipairs() do
                xq = getunit(xq)
                xq:groupadd(g2)
              end
              ForGroupLuaNew(g2, function(xq)
                xq:buffset(u.handle, 3, "暂停")
                xq:buffset(u.handle, 3, "沉默")
              end)
              local tx = Effectcreate("war3mapImported\\Heiquan.mdx", x1, y1, 4, 0.75, 0, 0, 0, 0, 2)
              ac.wait(100, function()
                SetEffectActSpeed(tx, 0.3)
              end)
              shikianimeact(u, 12, 3)
              unitmove({
                unit = u.handle,
                time = 0.1,
                distance = 400,
                angle = angle + 180,
                isfly = true
              })
              ac.wait(200, function()
                u:playsound(Sound_214_chongfeng_2)
                Effectcreate("war3mapImported\\chongci_Bo.mdx", x, y, 0, 1, 0, angle + 180, 0, 0, 1)
                play_shadow_slow_series(u, {
                  model = "war3mapImported\\Toono shiki.mdl",
                  scale = 0.73,
                  act = 19,
                  count = 47,
                  interval = 0.03,
                  main_speed = 0.5,
                  wait_time = 0,
                  r = 100,
                  g = 100,
                  b = 255,
                  fade_sub = 10,
                  noact = true
                })
                ac.wait(1430, function()
                  u:animeact(18)
                end)
                ac.wait(150, function()
                  u:setcolor(255, 255, 255, 0)
                end)
                unitmove({
                  unit = u.handle,
                  time = 0.1,
                  distance = dis - 200,
                  angle = angle,
                  isfly = true,
                  endfunc = function()
                    u:playsound(Sound_214_R2)
                    unitmove({
                      unit = u.handle,
                      time = 1.5,
                      distance = 100,
                      angle = angle,
                      isfly = true,
                      endfunc = function(dx, dy)
                        u:setcolor(255, 255, 255, 255)
                        ResetUnitAnimation(u.handle)
                        u:animeact(20)
                        u:animespeed(1)
                        u:playsound(Sound_214_R3)
                        u:playsound(Sound_214_R4)
                        for i = 1, 3 do
                          Effectcreate("war3mapImported\\Daji_fen.mdx", x1, y1, 0, 2, 0, GetRandomReal(0, 360))
                        end
                        Effectcreate("war3mapImported\\Daji_Kuoshan2.mdx", x1, y1, 0, 2, 0, 0, 0, 0, 1.25)
                        for i = 1, 7 do
                          local x3, y3 = PolarXY(x1, y1, GetRandomReal(-500, 500), GetRandomReal(0, 360))
                          Effectcreate("war3mapImported\\File00000650.mdl", x3, y3, 0, GetRandomReal(1, 8), GetRandomReal(100, 400), GetRandomReal(0, 360), GetRandomReal(0, 180), GetRandomReal(-110, -80), GetRandomReal(0.5, 2))
                          Effectcreate("war3mapImported\\File00006330.mdl", x3, y3, 0, GetRandomReal(1, 10), GetRandomReal(100, 400), GetRandomReal(0, 360), GetRandomReal(0, 180), GetRandomReal(-110, -80), GetRandomReal(0.5, 2))
                        end
                        u:shockcamera(20, 0.2)
                        local x2, y2 = PolarXY(x1, y1, 200, angle)
                        u:setxy(x2, y2)
                        u:setdata("位移点X", x2)
                        u:setdata("位移点Y", y2)
                        for _, xq in ac.selector():in_rangexy(dx, dy, 350):is_enemy(u.handle):ipairs() do
                          xq = getunit(xq)
                          xq:groupadd(g2)
                        end
                        if 0 < Group_Counts(g2) then
                          u:playsound(Sound_214_Gongji)
                        end
                        ForGroupLuaNew(g2, function(xq)
                          xq:buffset(u.handle, 3, "眩晕")
                          xq:effectadd("war3mapImported\\Daji_Hong1.mdx", "head")
                          DamageUnit({
                            bj = "远野志贵十七分割",
                            unit = xq.handle,
                            source = u.handle,
                            damage = txsh,
                            level = 1,
                            type = "物理",
                            isvest = false,
                            isattack = true,
                            isnoarmor = false,
                            element = "无"
                          })
                          LossHpUnit({
                            u = u,
                            tg = xq,
                            damage = 0,
                            perhp = xh,
                            maxhp = 0,
                            bj = "[生命损耗]十七分割"
                          })
                        end)
                        local txsh2 = 0.1 * txsh
                        local cs = 0
                        ac.loop(30, function(timer)
                          cs = cs + 1
                          ForGroupLuaNew(g2, function(xq)
                            DamageUnit({
                              bj = "远野志贵十七分割",
                              unit = xq.handle,
                              source = u.handle,
                              damage = txsh2,
                              level = 1,
                              type = "物理",
                              isvest = true,
                              isattack = true,
                              isnoarmor = false,
                              element = "无"
                            })
                            LossHpUnit({
                              u = u,
                              tg = xq,
                              damage = 0,
                              perhp = xh,
                              maxhp = 0,
                              bj = "[生命损耗]十七分割"
                            })
                          end)
                          if cs == 16 then
                            timer:remove()
                          end
                        end)
                      end
                    })
                  end
                })
              end)
            end
          end
          
          u:addtrgevent("单位-发动技能", function(args)
            skill(args)
          end)
        end
      })
      u:uivar_change({
        keyname = "退魔眼",
        keytype = "传奇栏",
        text = "|cFF0033FF远野志贵|r\n|cFF0033FF直死魔眼|r\n|cFF3366CC杀敌时提升0.01%伤害加成,如果处于直死魔眼状态下则提升0.15%\n无视精英特性守护和交错\n伤害加成增加13%\n输入\"直死魔眼\"开启直死魔眼,输入\"魔眼杀\"关闭\n魔眼开启时:\n每秒损耗[1.7%当前生命值+0.7%最大生命值],生命值不足5%时强制关闭\n无视绝大部分精英特性\n伤害加成增加17%\n提升13%十七分割触发概率\n每次触发十七分割对目标叠加一层分割计数 分割计数达到7层(17层)时即死目标同时清空层数(强敌17%最大生命值无视护甲物理生命移除伤害 BOSS7%当前生命值削除)|r\n|cFF0033FF十七分割|r\n|cFF3366CC直接伤害大于777时13%触发分割,触发冷却0.5秒|r\n|cFF949596理解了吗,这就是所谓的将事物杀死啊。|r",
        icon = "war3mapImported\\BTNEwl_Jinhua_Zhisimoyan.blp",
        isclearclick = true
      })
    end
  end,
  ["七夜志贵"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-七夜志贵"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFF0033FF七夜志贵|r|cFF7DBEF1]|r" .. NameID[sy])
      u:chat("那么,开始厮杀吧")
      PlayGlobalSound(Sound_Shiki_00)
      u:deldata("变异判定-退魔眼")
      u:setdata(str)
      u:reduceshw()
      Weiyi[25] = true
      u:groupadd(Group_Yueji)
      coopjudge("瓦拉齐亚之夜")
      u:setdata("系统-无视伤害免疫")
      u:setdata("系统-无视伤害闪避")
      u:become("噩梦具现化")
      if u.type == HeroType["志贵"] then
        u:changedata("志贵-连击伤害获取", 2.5)
      end
      u:changedata("月姬变异数量", 1)
      ChangeValue(DamageSystem_Shjc, sy, 0.013)
      ChangeValue(DamageSystem_Shjc, sy, 0.013)
      u:addstexiao(str, "伤害系统计算效果", function(args)
        local info = args.damageinfo
        info.lw = info.lw + 2.0E-4 * args.u:getdata("七夜-杀戮值")
      end)
      local bs = 0
      local bjl = 0
      local jz = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_Baoshang, sy, -bs)
        ChangeValue(DamageSystem_Baoji, sy, -bjl)
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * -jz)
        bs = 0.07 * u:getstate("影")
        bjl = 0.03 * u:getstate("影")
        jz = 0.25 * u:getstate("影")
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * jz)
        ChangeValue(DamageSystem_Baoji, sy, bjl)
        ChangeValue(DamageSystem_Baoshang, sy, bs)
      end)
      moveskillreplace({
        unit = u.handle,
        level = 1,
        skill_Q = "A0WF",
        skill_W = "A0WE",
        isforce = false,
        efunc = function()
          u:addtrgevent("单位-指定点目标指令", function(args)
            if args.orderid == String2OrderIdBJ("smart") and u:hasdata("闪走水月") then
              u:deldata("闪走水月")
              local x, y = u:getxy()
              local x2 = args.x
              local y2 = args.y
              local angle = AngleXY(x, y, x2, y2)
              local dis = DistanceXY(x, y, x2, y2)
              local mjl = 700
              if dis >= mjl then
                dis = mjl
              end
              play_shadow_slow_series(u, {
                act = u:getdata("播放动作"),
                count = 1,
                interval = 0.01,
                main_speed = u:getdata("动画速度"),
                wait_time = 0,
                r = 100,
                g = 100,
                b = 255,
                fade_sub = 5,
                noact = true
              })
              Effectcreate("Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl", x, y)
              movexg(u.handle, 0.1, S2ID("A0EW"), "W", "七夜志贵-冲刺")
              u:setdata("刷新W时间", 0.1)
              unitmove({
                unit = u.handle,
                time = 0.1,
                distance = dis,
                angle = angle,
                isfly = true,
                endfunc = function(dx, dy)
                  u:setdata("位移点X", dx)
                  u:setdata("位移点Y", dy)
                end,
                isblink = true
              })
            end
          end)
        end
      })
      
      local function chattrg(args)
        if args.chat == "知道要去哪里了吗？" and not u:hasdata("七夜志贵-歌月十夜准备就绪") then
          u:setdata("七夜志贵-歌月十夜准备就绪")
          PlayGlobalSound(Sound_Nanaya_Gysy)
        end
      end
      
      u:addtrgevent("玩家-聊天", function(args)
        chattrg(args)
      end)
      u:addtrgevent("单位-发动技能", function(args)
        if args.skill == S2ID("A0CG") then
          local x, y = u:getxy()
          local x2 = args.x
          local y2 = args.y
          local angle = AngleXY(x, y, x2, y2)
          u:playsound(Sound_Shiki_52)
          PlayGlobalSound(Sound_Shiki_38)
          unifycreate({
            owner = u.handle,
            model = "war3mapImported\\sakuya_knife.mdl",
            modelname = "极死七夜小刀",
            modelsize = 1,
            height = 75,
            damage = 0,
            damagetype = 4,
            time = 0.5,
            speed = 8000,
            volume = 75,
            angle = angle,
            angleoffset = 0,
            attenua = 1,
            attenuacount = 1,
            life = 10,
            isbullet = false,
            isvest = false,
            isignorearmor = false,
            startfunc = function(mj)
              mj:setcolor(255, 0, 0)
            end,
            loopfunc = function(mj)
            end,
            hitafterfunc = function(mj, xq, damage2)
              mj:setcolor(255, 255, 255)
              if xq:isboss() and Group_Counts(Group_Xingcunzu) <= 1 and not u:hasdata("变异判定-真夏的白雪") and u:hasdata("七夜志贵-歌月十夜准备就绪") then
                MovieAct["歌月十夜"](u, xq)
              else
                MovieAct["极死七夜"](u, xq)
              end
            end
          })
          ac.wait(1000, function()
            if u:hasdata("变异判定-真夏的白雪") then
              u:delskill("A0CG")
              u:banweaponskill(true)
            else
              u:delskill("A0CG")
              u:addskill("A0WG")
            end
          end)
        end
      end)
      u:uivar_change({
        keyname = "退魔眼",
        keytype = "传奇栏",
        text = "|cFF0033FF七夜志贵|r\n|cFF0033FF影 唯一\n蜘蛛步|r\n|cFF3366CC改变冲刺与后撤\n绝对闪避成功时,降低0.1秒位移技能冷却,触发冷却0.1秒|r\n|cFF0033FF迷狱沙门|r\n|cFF3366CC提升[影变异*3%]暴击率\n提升[影变异*7%]暴击伤害\n无视伤害闪避与伤害免疫\n提升[影变异*2.5%]伤害加成|r\n|cFF0033FF极死七夜|r\n|cFF3366CC[数据删除]|r\n|cFF0033FF歌月十夜|r\n|cFF3366CC[数据删除]|r\n|cFF949596英勇而去之人，又会迅驰而逝。|r",
        icon = "war3mapImported\\BTNEwl_Geyueshiyue.blp",
        isclearclick = true
      })
    end
  end,
  ["米霍克"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-米霍克"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFF3333CC米霍克|r|cFF7DBEF1]|r" .. NameID[sy])
      Weiyi[14] = true
      PlayGlobalSound(Yinxiao_Yingyan4)
      u:chat("那么 命运啊")
      ac.wait(2800, function()
        u:chat("新时代的天之骄子")
      end)
      ac.wait(6100, function()
        u:chat("是到此为止呢")
      end)
      ac.wait(7900, function()
        u:chat("还是")
      end)
      ac.wait(9100, function()
        u:chat("能从这把黑刀下活下来")
      end)
      u:deldata("变异判定-鹰眼")
      u:setdata(str)
      u:reduceshw()
      ChangeValue(Correction_Range, sy, 0.38)
      ChangeValue(DamageSystem_Baoji, sy, -12)
      ac.loop(1000, function()
        Correction_Angle[sy] = 0.01
      end)
      u:addstexiao(str, "近战伤害效果", function(args)
        local info = args.damageinfo
        if info.distance <= 350 then
          info.damage = info.damage * 1.12
        end
      end)
      u:addstexiao(str, "抗性破坏结算阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not info.wssb then
          info.damage = info.damage * (1 + 0.01 * info.sbl)
          info.wssb = true
        end
      end)
      u:addstexiao(str, "暴击系统计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if tg:getdata("鹰眼印记层数") > 0 then
          info.bjl = info.bjl + 5 * tg:getdata("鹰眼印记层数")
          info.bjsh = info.bjsh + u:getdata("鹰眼-杀敌暴击伤害提升")
        end
      end)
      u:addstexiao(str, "伤害判定后效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if u:hasdata("米霍克暴击判定") and not u:hasdata("鹰眼暴击判定间隔2") then
          u:deldata("米霍克暴击判定")
          if not info.iscrit then
            tg:changedata("鹰眼印记层数", 1)
            if tg:getdata("鹰眼印记层数") >= 10 then
              DamageUnit({
                bj = "米霍克鹰眼印记附伤",
                unit = tg.handle,
                source = u.handle,
                level = 5,
                damage = 5000 * tg:getdata("鹰眼印记层数"),
                type = "物理",
                isvest = true
              })
              tg:deldata("鹰眼印记层数")
            end
          end
          u:settimedata("鹰眼暴击判定间隔2", 0.1)
        end
      end)
      u:addstexiao(str, "近战伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata("鹰眼暴击增伤冷却") then
          ChangeTimeValue(DamageSystem_Shjc, sy, 0.01, 10)
          u:settimedata("鹰眼暴击增伤冷却", 0.5)
        end
        if not tg:hasdata("鹰眼击杀判定") then
          tg:settimedata("鹰眼击杀判定", 0.05)
          ac.wait(50, function()
            if not tg:isalive() then
              u:changedata("鹰眼-杀敌暴击伤害提升", 0.001)
            end
          end)
        end
        if tg:getdata("鹰眼印记层数") > 0 and not u:hasdata("米霍克-特效冷却") then
          u:settimedata("米霍克-特效冷却", 0.25)
          DamageUnit({
            bj = "米霍克鹰眼印记附伤",
            unit = tg.handle,
            source = u.handle,
            damage = 5000 * tg:getdata("鹰眼印记层数"),
            level = 4,
            type = "物理",
            isvest = true,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
        end
      end)
      u:setdata("武装色霸气格挡冷却时间", 0)
      ac.loop(1000, function()
        if u:getdata("武装色霸气格挡冷却时间") > 0 then
          u:changedata("武装色霸气格挡冷却时间", -1)
        else
          u:setdata("武装色霸气格挡冷却时间", 0)
        end
        local b = false
        if u:isalive() then
          local x, y = u:getxy()
          for _, xq in ac.selector():in_rangexy(x, y, 200):is_enemy(u.handle):ipairs() do
            b = true
            break
          end
        end
        if b then
          u:setdata("武装色霸气近战范围强化")
        else
          u:deldata("武装色霸气近战范围强化")
        end
      end)
      u:uivar_change({
        keyname = "鹰眼",
        keytype = "传奇栏",
        text = "|cFF401AB2米霍克|r\n|cFF401AB2鹰眼|r\n|cFF4C3399无视精英特性制远与模糊\n暴击杀死的敌人时提升对鹰眼印记影响下单位0.1%暴击伤害\n造成伤害无视闪避且目标每点闪避率提升1%原始伤害\n造成暴击伤害时10秒内提升自身1%伤害加成修正(触发冷却0.5秒)分立计时 可叠加\n枪械射击角度修正锁定为1%同时枪械射程提升50%|r\n|cFF401AB2见闻色霸气.乔拉可尔|r\n|cFF4C3399提升[目标鹰眼印记层数*5%]暴击率\n直接伤害没有暴击时给目标叠加一层鹰眼印记,达到10层时则强制触发\n造成暴击伤害时对目标造成[鹰眼印记*5000]物理生命移除伤害并清除鹰眼印记层数,冷却0.25秒|r\n|cFF401AB2武装色霸气.乔拉可尔|r\n|cFF4C3399对350范围内敌人提升12%近战伤害(独立)\n自身200范围内存在敌人时提升25%近战伤害范围\n受到来自750范围外敌人伤害时格挡该次伤害并向其所在方向发射剑气造成[5000+500*等级]物理抹除伤害(冷却15秒)\n杀敌时减少1秒",
        icon = "war3mapImported\\BTNEwl_Yingyanmihuoke.blp",
        isclearclick = true
      })
    end
  end,
  ["蓬莱山辉夜"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-蓬莱山辉夜"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFFCC33FF蓬莱山辉夜|r|cFF7DBEF1]|r" .. NameID[sy])
      Weiyi[9] = true
      Qiyue_Meihonghuiye_Huiye = u.handle
      if not Weiyi[12] then
        PlayGlobalSound(Sound_Huiye_01)
        SendMsgAll("|cFFCC66FF『|r|cFFC770FF我|r|cFFC27AFF是|r|cFFBD85FF蓬|r|cFFB88FFF莱|r|cFFB399FF山|r|cFFADA3FF辉|r|cFFA8ADFF夜|r|cFFA3B8FF』|r")
        ac.wait(2300, function()
          SendMsgAll("|cFFCC66FF『|r|cFFC86DFF犯|r|cFFC575FF下|r|cFFC17CFF了|r|cFFBD83FF罪|r|cFFBA8AFF行|r|cFFB692FF被|r|cFFB399FF月|r|cFFAFA0FF亮|r|cFFABA8FF所|r|cFFA8AFFF追|r|cFFA4B6FF赶|r|cFFA0BDFF』|r")
        end)
        ac.wait(4900, function()
          SendMsgAll("|cFFCC66FF『|r|cFFC96CFF现|r|cFFC672FF在|r|cFFC378FF在|r|cFFC07EFF地|r|cFFBD84FF球|r|cFFBA8AFF上|r|cFFB790FF度|r|cFFB496FF过|r|cFFB19CFF着|r|cFFAEA2FF永|r|cFFABA8FF恒|r|cFFA8AEFF的|r|cFFA5B4FF时|r|cFFA2BAFF间|r|cFF9FC0FF』|r")
        end)
        ac.wait(8000, function()
          SendMsgAll("|cFFCC66FF『|r|cFFC27AFF莫|r|cFFB88FFF非|r|cFFADA3FF』|r")
        end)
        ac.wait(9800, function()
          SendMsgAll("|cFFCC66FF『|r|cFFCA6BFF这|r|cFFC76FFF次|r|cFFC574FF相|r|cFFC379FF遇|r|cFFC07DFF会|r|cFFBE82FF成|r|cFFBC86FF为|r|cFFB98BFF令|r|cFFB790FF我|r|cFFB594FF的|r|cFFB399FF历|r|cFFB09EFF史|r|cFFAEA2FF变|r|cFFACA7FF化|r|cFFA9ACFF的|r|cFFA7B0FF一|r|cFFA5B5FF部|r|cFFA2B9FF分|r|cFFA0BEFF呢|r|cFF9EC3FF』|r")
        end)
      else
        PlayGlobalSound(Sound_Huiye_02)
        SendMsgAll("|cFFCC66FF『|r|cFFC671FF要|r|cFFC17DFF全|r|cFFBB88FF力|r|cFFB593FF上|r|cFFB09FFF了|r|cFFAAAAFF哦|r|cFFA4B5FF』|r")
        local qy1 = getunit(Qiyue_Meihonghuiye_Huiye)
        local qy2 = getunit(Qiyue_Meihonghuiye_Meihong)
        local sy1 = qy1.ownerid
        local sy2 = qy2.ownerid
        NameID[sy1] = "|cFF99CCFF蓬|r|cFFA3A3FF莱|r|cFFAD7AFF山|r|cFFB852FF辉夜|r"
        NameID[sy2] = "|cFFFF9900藤|r|cFFF57A00原|r|cFFEB5C00妹|r|cFFE03D00红|r"
        qy1:setplayername(NameID[sy1])
        qy2:setplayername(NameID[sy2])
        qy1:setdata("竹取飞翔-辉夜")
        qy2:setdata("竹取飞翔-妹红")
        flashphoto({
          photo = "war3mapImported\\Pho_Meihonghuiye.tga"
        })
        qy1:uivar_add({
          keyname = "蓬莱玉枝",
          keytype = "传奇栏",
          text = "|cFF99CCFF蓬|r|cFFA3A3FF莱|r|cFFAD7AFF玉|r|cFFB852FF枝|r\n|cFFAD7AFF永夜归返|r\n|cFF99CCFF刹那锁血降低至8%\n须臾触发间隔降低[已逝去分钟数*0.2]秒,至低20秒\n每次触发须臾降低场上所有存活的BOSS与精英单位4%当前生命上限并在3秒内时停所有敌军|r\n|cFFAD7AFF相爱相杀|r\n|cFF99CCFF血量会极速向妹红血量靠拢|r\n|cFFAD7AFF至死不渝|r\n|cFF99CCFF彻底死亡时使对方完全恢复并获得3秒绝对闪避|r",
          icon = "war3mapImported\\PASBTNEwlCP_Meihonghuiye_huiye.tga"
        })
        qy2:uivar_add({
          keyname = "不死鸟之尾",
          keytype = "传奇栏",
          text = "|cFFFF9900不|r|cFFF68000死|r|cFFEE6600鸟|r|cFFE64C00之|r|cFFDD3300尾|r\n|cFFE64C00永恒晦暗|r\n|cFFFF9900不死鸟生命损耗降低至5%\n不灭火趋向生命提升为75%|r\n|cFFE64C00相爱相杀|r\n|cFFFF9900血量会极速向辉夜血量靠拢|r\n|cFFE64C00至死不渝|r\n|cFFFF9900彻底死亡时使对方完全恢复并获得3秒绝对闪避|r",
          icon = "war3mapImported\\PASBTNEwlCP_Meihonghuiye_Meihong"
        })
        local c = 0
        local c2 = 0
        ac.loop(100, function()
          ChangeValue(HeroMenu_HpForever_MaxHp, sy1, -1 * c)
          ChangeValue(HeroMenu_HpForever_MaxHp, sy2, -1 * c2)
          if qy1:isalive() and qy2:isalive() then
            local hps1 = qy2:getperhp()
            local hps2 = qy1:getperhp()
            if hps1 <= 1 then
              hps1 = 1
            end
            if hps2 <= 1 then
              hps2 = 1
            end
            c = (hps1 - hps2) / 20
            c2 = (hps2 - hps1) / 20
          else
            c = 0
            c2 = 0
          end
          ChangeValue(HeroMenu_HpForever_MaxHp, sy2, 1 * c2)
          ChangeValue(HeroMenu_HpForever_MaxHp, sy1, 1 * c)
        end)
        PlayBGM({
          bgm = BGM_Meihonghuiye_01,
          time = 270,
          ID = 61,
          unit = qy1.handle
        })
        PlayBGM({
          bgm = 0,
          time = 270,
          ID = 61,
          unit = qy2.handle
        })
      end
      u:setdata(str)
      u:reduceshw()
      u:setdata("身体判定-蓬莱人")
      u:changedata("东方变异数量", 1)
      ChangeValue(Ewaishu, sy, 1)
      u:become("大和抚子")
      u:sethp(100, true)
      u:settimedata("永夜永恒", 3)
      u:effectadd("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", "origin", 3)
      u:getgoddessforce(2, false)
      local dskill = S2ID("A0IN")
      u:byladdskill(dskill, function(args)
        if args.skill == dskill then
          local b = true
          local ewl = getunit(args.unit)
          local tg = getunit(args.target)
          if not u:isalive() then
            b = false
            u:sendmessage("|cFF7DBEF1死亡状态无法释放|r")
          end
          if not tg:isingroup(Group_PlayHero) then
            b = false
            u:sendmessage("|cFF7DBEF1只能以英雄为目标|r")
          end
          if b then
            tg:effectadd("war3mapImported\\Area_Jinguangfuzhen.mdx", "chest", 15)
            tg:effectadd("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", "origin", 2)
            ac.wait(2000, function()
              tg:effectadd("Objects\\Spawnmodels\\NightElf\\NEDeathSmall\\NEDeathSmall.mdl")
            end)
            local cs = 0
            tg:setdata("辉夜-一念永恒")
            local xl = tg:gethp()
            local smz = 0
            local smzj = 0
            local sj = 0
            ac.loop(10, function(timer)
              cs = cs + 1
              tg:clearbuff("混乱")
              tg:clearbuff("眩晕")
              tg:clearbuff("僵直")
              tg:clearbuff("缠绕")
              tg:clearbuff()
              if tg:gethp() < xl then
                smzj = smzj + xl - tg:gethp()
                tg:sethp(xl)
              elseif tg:gethp() > xl then
                smz = smz + tg:gethp() - xl
                tg:sethp(xl)
              end
              if cs == 1500 then
                local hx = 2 * smz - 0.5 * smzj
                tg:effectadd("war3mapImported\\dead spirit by deckai2.mdx", "overhead")
                tg:effectadd("war3mapImported\\ThunderclapCaster.mdx", "overhead")
                if xl + hx <= 0 then
                  tg:sethp(1)
                else
                  tg:sethp(xl + hx)
                end
                tg:deldata("辉夜-一念永恒")
                timer:remove()
              end
            end)
          else
            ewl:setskillcd(dskill, 1)
          end
        end
      end)
      ChangeValue(Revise_PoisonResist, sy, 1)
      local cs = 0
      ac.loop(1000, function()
        if u:isalive() then
          cs = cs + 1
          local z
          if u:hasdata("竹取飞翔-辉夜") then
            z = 48 - 0.2 * Time_M
            if z <= 20 then
              z = 20
            end
          else
            z = 48
          end
          if Keyan_Weizhanshike then
            z = z * Weizhanxishu
          end
          if z <= cs then
            cs = 0
            u:sethp(100, true)
            u:settimedata("永夜永恒", 3)
            u:effectadd("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdl", "origin", 3)
            u:addrandomstats(GetRandomInt(1, 10))
            u:changemaxhp(GetRandomReal(1, 100))
            if u:hasdata("竹取飞翔-辉夜") then
              ForGroupLuaNew(Group_Monster, function(xq)
                xq:buffset(u.handle, 3, "暂停")
                if not xq:isnormal() then
                  xq:changemaxhp(-0.04 * xq:getmaxhp())
                end
              end)
            end
          end
        end
      end)
      u:uivar_add({
        keyname = "蓬莱山辉夜",
        keytype = "传奇栏",
        text = "|cFFCC33FF蓬莱山辉夜|r\n|cFFCC33FF东方\n永恒|r\n|cFFCC66FF自身伤害免疫效果均视为永恒抗性|r\n|cFFCC33FF须臾|r\n|cFFCC66FF每48秒生命值恢复为100%并在3秒内获得永恒抗性,触发时提升自身1~100生命上限与1~10点属性|r\n|cFFCC33FF刹那|r\n|cFFCC66FF单次受伤不会超过最大生命值10%(独立效果)\n受到致死伤害时抵挡该次伤害并时停世界6秒,期间移速提升500并永恒(触发冷却600秒)|r\n|cFFCC33FF一念|r\n|cFFCC66FF获得技能[一念永恒]\n自身死亡时使所有友军状态完全恢复并在3秒内获得永恒|r",
        icon = "war3mapImported\\BTNEwl_Neet.blp"
      })
    end
  end,
  ["藤原妹红"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-藤原妹红"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFFFF3300藤原妹红|r|cFF7DBEF1]|r" .. NameID[sy])
      Weiyi[12] = true
      Qiyue_Meihonghuiye_Meihong = u.handle
      if not Weiyi[9] then
        PlayGlobalSound(Sound_Meihong_01)
        SendMsgAll("|cFFFF6699『|r|cFFFF6293每|r|cFFFF5E8D次|r|cFFFF5A87涅|r|cFFFF5681槃|r|cFFFF527C都|r|cFFFF4E76会|r|cFFFF4B70变|r|cFFFF476A得|r|cFFFF4364更|r|cFFFF3F5E强|r|cFFFF3B58的|r|cFFFF3752不|r|cFFFF334C死|r|cFFFF2F47鸟|r|cFFFF2B41，|r|cFFFF273B就|r|cFFFF2335让|r|cFFFF1F2F你|r|cFFFF1B29见|r|cFFFF1823识|r|cFFFF141D一|r|cFFFF1018下|r|cFFFF0C12吧|r|cFFFF080C』|r")
      else
        PlayGlobalSound(Sound_Meihong_02)
        SendMsgAll("|cFFFF6699『|r|cFFFF5E8D来|r|cFFFF5681吧|r|cFFFF4E76，|r|cFFFF476A不|r|cFFFF3F5E必|r|cFFFF3752手|r|cFFFF2F47下|r|cFFFF273B留|r|cFFFF1F2F情|r|cFFFF1823哦|r|cFFFF1018』|r")
        local qy1 = getunit(Qiyue_Meihonghuiye_Huiye)
        local qy2 = getunit(Qiyue_Meihonghuiye_Meihong)
        local sy1 = qy1.ownerid
        local sy2 = qy2.ownerid
        NameID[sy1] = "|cFF99CCFF蓬|r|cFFA3A3FF莱|r|cFFAD7AFF山|r|cFFB852FF辉夜|r"
        NameID[sy2] = "|cFFFF9900藤|r|cFFF57A00原|r|cFFEB5C00妹|r|cFFE03D00红|r"
        qy1:setplayername(NameID[sy1])
        qy2:setplayername(NameID[sy2])
        qy1:setdata("竹取飞翔-辉夜")
        qy2:setdata("竹取飞翔-妹红")
        flashphoto({
          photo = "war3mapImported\\Pho_Meihonghuiye.tga"
        })
        qy1:uivar_add({
          keyname = "蓬莱玉枝",
          keytype = "传奇栏",
          text = "|cFF99CCFF蓬|r|cFFA3A3FF莱|r|cFFAD7AFF玉|r|cFFB852FF枝|r\n|cFFAD7AFF永夜归返|r\n|cFF99CCFF刹那锁血降低至8%\n须臾触发间隔降低[已逝去分钟数*0.2]秒,至低20秒\n每次触发须臾降低场上所有存活的BOSS与精英单位4%当前生命上限并在3秒内时停所有敌军|r\n|cFFAD7AFF相爱相杀|r\n|cFF99CCFF血量会极速向妹红血量靠拢|r\n|cFFAD7AFF至死不渝|r\n|cFF99CCFF彻底死亡时使对方完全恢复并获得3秒绝对闪避|r",
          icon = "war3mapImported\\PASBTNEwlCP_Meihonghuiye_huiye.tga"
        })
        qy2:uivar_add({
          keyname = "不死鸟之尾",
          keytype = "传奇栏",
          text = "|cFFFF9900不|r|cFFF68000死|r|cFFEE6600鸟|r|cFFE64C00之|r|cFFDD3300尾|r\n|cFFE64C00永恒晦暗|r\n|cFFFF9900不死鸟生命损耗降低至5%\n不灭火趋向生命提升为75%|r\n|cFFE64C00相爱相杀|r\n|cFFFF9900血量会极速向辉夜血量靠拢|r\n|cFFE64C00至死不渝|r\n|cFFFF9900彻底死亡时使对方完全恢复并获得3秒绝对闪避|r",
          icon = "war3mapImported\\PASBTNEwlCP_Meihonghuiye_Meihong"
        })
        local c = 0
        local c2 = 0
        ac.loop(100, function()
          ChangeValue(HeroMenu_HpForever_MaxHp, sy1, -1 * c)
          ChangeValue(HeroMenu_HpForever_MaxHp, sy2, -1 * c2)
          if qy1:isalive() and qy2:isalive() then
            local hps1 = qy2:getperhp()
            local hps2 = qy1:getperhp()
            if hps1 <= 1 then
              hps1 = 1
            end
            if hps2 <= 1 then
              hps2 = 1
            end
            c = (hps1 - hps2) / 20
            c2 = (hps2 - hps1) / 20
          else
            c = 0
            c2 = 0
          end
          ChangeValue(HeroMenu_HpForever_MaxHp, sy2, 1 * c2)
          ChangeValue(HeroMenu_HpForever_MaxHp, sy1, 1 * c)
        end)
        PlayBGM({
          bgm = BGM_Meihonghuiye_01,
          time = 270,
          ID = 61,
          unit = qy1.handle
        })
        PlayBGM({
          bgm = 0,
          time = 270,
          ID = 61,
          unit = qy2.handle
        })
      end
      u:setdata(str)
      u:reduceshw()
      u:changedata("东方变异数量", 1)
      u:changedata("炎变异数量", 1)
      u:setdata("身体判定-蓬莱人")
      ChangeValue(Ewaishu, sy, 1)
      u:sethp(100, true)
      u:setdata("涅槃时间", 60)
      u:setdata("涅槃次数", 0)
      u:deldata("诅咒-灵体化")
      u:uivar_remove("灵体化", "传奇栏")
      ChangeValue(Revise_PoisonResist, sy, 1)
      local c = 0
      ac.loop(100, function()
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, -1 * c)
        if u:isalive() then
          local mhp = 50
          if u:hasdata("竹取飞翔-妹红") then
            mhp = 75
          end
          c = (mhp - u:getperhp()) / 20
        else
          c = 0
        end
        ChangeValue(HeroMenu_HpForever_MaxHp, sy, 1 * c)
      end)
      u:addstexiao(str, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata(str .. "-特效冷却") and u:getluckrandom(10 * info.txgl) then
          u:settimedata(str .. "-特效冷却", 0.5)
          local xh = 0.1 * u:gethp()
          if u:hasdata("竹取飞翔-妹红") then
            u:losshp(u, xh * 0.5)
          else
            u:losshp(u, xh)
          end
          local txsh = xh * 1 + 2000 * u:getdata("涅槃次数")
          unifycreate({
            owner = u.handle,
            model = "units\\human\\phoenix\\phoenix.mdl",
            modelname = "妹红-不死鸟",
            modelsize = 1.5,
            height = 90,
            damage = txsh,
            damagetype = 6,
            x = GetUnitX(u.handle),
            y = GetUnitY(u.handle),
            range = 2500,
            speed = 2500,
            volume = 225,
            angle = AngleBetweenUnits(u.handle, tg.handle),
            angleoffset = 0,
            attenua = 1,
            attenuacount = 999,
            life = 10,
            isbullet = false,
            isvest = true,
            isignorearmor = false,
            hitbeforefunc = function(mj, xq, damage2)
              u:setdata("属性伤害", "炎")
              u:setdata("伤害阶级", 5)
              xq:groupadd(HpGroup)
            end,
            hitafterfunc = function(mj, xq, damage2)
              u:changemaxhp(1)
              u:curehp(u.handle, 0, 0.75, 3)
              xq:effectadd("Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl", "origin")
              local vest = getunit(System_SkillVest)
              vest:addskill("A0XD")
              IssueTargetOrder(vest.handle, "soulburn", xq.handle)
              vest:delskill("A0XD")
            end
          })
        end
      end)
      u:addstexiao(str, "伤害系统计算效果", function(args)
        local info = args.damageinfo
        info.jc = info.jc + 0.25 * (info.jc - 1)
      end)
      u:uivar_add({
        keyname = "藤原妹红",
        keytype = "传奇栏",
        text = "|cFFFF0000藤原妹红|r\n|cFFFF0000炎 东方\n不灭火|r\n|cFFFF3300生命值高速趋向50%|r\n|cFFFF0000不死鸟|r\n|cFFFF3300直接伤害时10%损耗10%当前生命发射火羽对前方造成[损耗生命值*1+2000*涅槃次数]火属性抹除灵力伤害并在3秒内降低攻击力并抑制生命恢复,冷却0.5秒\n命中单位时提升1点生命上限并恢复自身0.75%最大生命值|r\n|cFFFF0000超新星|r\n|cFFFF3300死亡或涅槃复活时对1800范围造成[10000*(1+涅槃次数)]抹除伤害并在10秒内眩晕且破坏抗性与减伤|r\n|cFFFF0000涅槃|r\n|cFFFF3300涅槃复活后提升1级与1全属性 在10秒内提升10%永恒恢复并在100秒内提升2%永恒恢复\n死亡后涅槃复活 初始60秒 每次涅槃复活提升30秒涅槃时间\n杀敌降低0.15秒涅槃时间,至低60秒|r\n|cFFFF0000不死之烟|r\n|cFFFF3300杀敌时提升0.01%伤害加成\n基础伤害对自身的加成提升25%\n死亡时[10+涅槃次数*1%]立刻涅槃复活并触发,上限35%,存活翻倍|r",
        icon = "war3mapImported\\BTNEwl_Bumiezhihuo.blp"
      })
    end
  end,
  ["诸葛亮"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-诸葛亮"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFFFFFF00武|r|cFFCCFF33侯|r|cFF7DBEF1]|r" .. NameID[sy])
      PlayGlobalSound(Sound_Kongming__5_u)
      SendMsgAll("|cFFFFFF33『|r|cFFF2FF3C天|r|cFFE6FF44下|r|cFFD9FF4C的|r|cFFCCFF55事|r|cFFBFFF5E情|r|cFFB2FF66分|r|cFFA6FF6E为|r|cFF99FF77五|r|cFF8CFF80种|r|cFF80FF88』|r")
      ac.wait(3000, function()
        SendMsgAll("|cFFFFFF33『|r|cFFE9FF42凭|r|cFFD3FF50我|r|cFFBDFF5F一|r|cFFA8FF6D手|r|cFF92FF7C』|r")
      end)
      ac.wait(4800, function()
        SendMsgAll("|cFFFFFF33『|r|cFFF5FF39天|r|cFFECFF40下|r|cFFE2FF46的|r|cFFD9FF4C三|r|cFFCFFF53分|r|cFFC6FF59.|r|cFFBCFF60.|r|cFFB2FF66.|r|cFFA9FF6C三|r|cFF9FFF73分|r|cFF96FF79.|r|cFF8CFF80.|r|cFF83FF86.|r|cFF79FF8C』|r")
      end)
      ac.wait(9100, function()
        SendMsgAll("|cFFFFFF33『|r|cFFF0FF3D啊|r|cFFE0FF47咧|r|cFFD1FF52，|r|cFFC2FF5C要|r|cFFB2FF66涂|r|cFFA3FF70吗|r|cFF94FF7A。|r|cFF85FF85』|r")
      end)
      ac.wait(1200, function()
        PlayBGM({
          bgm = BGM_Kongming_20,
          time = 205,
          ID = 62,
          unit = u.handle
        })
      end)
      u:deldata("变异判定-卧龙")
      u:setdata(str)
      u:reduceshw()
      Qiyue_Langkepaidu_Kongming = u.handle
      coopjudge("浪客派对")
      u:addstexiao(str, "抗性破坏阶段", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if IsTimeDay() then
          info.wssb = true
          info.wsmy = true
        end
      end)
      u:changedata("智力增幅", 0.1)
      local zs = 0
      local hp = 0
      local cs = 0
      ac.loop(1000, function()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (-1 * zs))
        zs = 0.1 + 0.01 * u:getlevel()
        ChangeValue(DamageSystem_Shjc, sy, 0.1 * (1 * zs))
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, -1 * hp)
        if IsTimeDay() then
          hp = 0.25
          if u:isalive() then
            cs = cs + 1
            if 10 <= cs then
              cs = 0
              local sj = GetRandomInt(1, 3)
              if sj == 1 then
                u:addint(1)
              end
              if sj == 2 then
                u:changemaxhp(10)
              end
              if sj == 3 then
              end
            end
          end
        else
          hp = 0
        end
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, 1 * hp)
      end)
      u:uivar_change({
        keyname = "卧龙",
        keytype = "传奇栏",
        text = "|cFFFFFF00诸|r|cFFD9FF26葛|r|cFFB2FF4C亮|r\n|cFFFFFF00帷幄|r\n|cFFB2FF4C伤害加成提升2%法术修正|r\n|cFFFFFF00休憩时刻啦~|r\n|cFFB2FF4C受到伤害时50%抵挡本次伤害,触发冷却3秒|r\n|cFFFFFF00赤猿.苍狼|r\n|cFFB2FF4C杀敌时提升0.1%法伤\n杀死单位时在8秒内提升0.1%法术修正,可叠加 刷新计时\n提升[20+10%]智力\n提升[1%+0.1%*等级]法术修正\n提升[1%+0.1%*等级]伤害加成|r\n|cFFFFFF00日照|r\n|cFFB2FF4C白昼时造成伤害无视伤害免疫与闪避\n白昼时提升0.25%生命恢复\n白昼时每10秒随机触发效果:①提升1点智力②提升10点生命上限③无事发生|r\n|cFFFFFF00啊呜~不想动！|r\n|cFFB2FF4C受到大于10伤害时50%触发,自身周围800范围单位50%混乱3秒,50%眩晕3秒,触发冷却10秒|r\n|cFFFFFF00落樱流|r\n|cFFB2FF4C每次暴击4%积累1点落樱,累积达到4点时进入樱落状态持续15秒,触发冷却90秒\n期间提升15%全属性,直接伤害时附带[全属性*15]灵力纯粹伤害|r",
        icon = "war3mapImported\\BTNEwl_Kongming_01",
        isclearclick = true
      })
    end
  end,
  ["神化灾祸魔神"] = function(u)
    local sy = u.ownerid
    local str = "神化判定-灾祸魔神"
    if not u:hasdata(str) then
      u:setdata(str)
      u:reduceshw()
      u:setplayername("|cFF7DBEF1[|r|cFF990000灾祸魔神|r|cFF7DBEF1]|r" .. NameID[sy])
      PlayBGM({
        bgm = 0,
        time = 243,
        ID = 251,
        unit = u.handle
      })
      PlayGlobalSound(Sound_Hlm_Shenhua)
      NPCChat({
        name = "|cFF990000灾祸魔神|r",
        chaticon = "Chat_Hlm.tga",
        chattext = {
          {
            time = 0,
            text = "|cFFCC0000游戏结束了|r"
          },
          {
            time = 1.3,
            text = "|cFFCC0000你的层次太低|r"
          },
          {
            time = 4.8,
            text = "|cFFCC0000力量即是正义|r"
          },
          {
            time = 7.1,
            text = "|cFFCC0000真是一个好时代啊|r"
          },
          {
            time = 9.1,
            text = "|cFFCC0000让你见识一下|r"
          },
          {
            time = 10.5,
            text = "|cFFCC0000臣服于吾等魔神的力量|r"
          }
        }
      })
      local endtime = 13
      ac.wait((endtime + 0.4) * 1000, function()
        PlayGlobalSound(BGM_Hlm_01)
        songtext({
          text = {
            {
              starttime = 15.66,
              str = "回答我吧 吶"
            },
            {
              starttime = 20.34,
              str = "向着突然降下驟雨的黑夜小鎮"
            },
            {
              starttime = 24.39,
              str = "下沉的世界 感覺溯流而上"
            },
            {
              starttime = 28.61,
              str = "於我誕生於世上的同時"
            },
            {
              starttime = 31.83,
              str = "也一定是在尋找着那不存在的『答案』",
              time = 5
            },
            {
              starttime = 40.61,
              str = "回應我吧 吶",
              time = 4.5
            },
            {
              starttime = 48.89,
              str = "要去實現些 什麼？"
            },
            {
              starttime = 53.11,
              str = "今天的世界如何呢？"
            },
            {
              starttime = 55.62,
              str = "一定不用說"
            },
            {
              starttime = 57.62,
              str = "你也是清楚知道你自己的吧"
            },
            {
              starttime = 63.24,
              str = "只是你依然無法相信而已吧"
            },
            {
              starttime = 71.8,
              str = "在哭泣起來的思想的彼方"
            },
            {
              starttime = 73.69,
              str = "無盡的善與惡的祭典"
            },
            {
              starttime = 75.7,
              str = "我連些許的期待都沒有呢"
            },
            {
              starttime = 77.77,
              str = "那樣說道的你將你消抹掉了"
            },
            {
              starttime = 80.17,
              str = "在時間之流裹就連希望"
            },
            {
              starttime = 82.17,
              str = "亦無法想像得到的世界"
            },
            {
              starttime = 84.18,
              str = "何謂正確誰亦無法知曉"
            },
            {
              starttime = 86.45,
              str = "所以你許下怎樣的願望也沒關係的呢",
              time = 5
            },
            {
              starttime = 101.11,
              str = "…答案？ 沒有哦..."
            },
            {
              starttime = 105.83,
              str = "像我這樣的人一定還是不行的"
            },
            {
              starttime = 109.69,
              str = "就只得悲傷的感情在心中迴響"
            },
            {
              starttime = 114.04,
              str = "在孤獨之中遠遠浮現出的昨天",
              time = 5
            },
            {
              starttime = 121.89,
              str = "世界就於今天終結了"
            },
            {
              starttime = 124.45,
              str = "即使你拒絕了於這結末之時"
            },
            {
              starttime = 128.38,
              str = "死之花亦依然綻放"
            },
            {
              starttime = 130.93,
              str = "世事皆亦不如人意"
            },
            {
              starttime = 134.94,
              str = "這就是你的一切了吧",
              time = 5
            },
            {
              starttime = 142.3,
              str = "在不止的憂鬱深處"
            },
            {
              starttime = 144.75,
              str = "兩種的感情成雙成對流露出願望"
            },
            {
              starttime = 147.41,
              str = "你還記得清楚嗎"
            },
            {
              starttime = 149.06,
              str = "那天眼淚的意義"
            },
            {
              starttime = 150.92,
              str = "這個世界依然未完結的"
            },
            {
              starttime = 152.95,
              str = "即使無明之夜阻擋着今天"
            },
            {
              starttime = 155.11,
              str = "我亦會歌唱着 我並不討厭這樣呢"
            },
            {
              starttime = 157.08,
              str = "來吧讓漆黑的天黑 再次放晴"
            },
            {
              starttime = 159.44,
              str = "與不再哭泣的今天說再見吧"
            },
            {
              starttime = 161.4,
              str = "就如高舉着這份不變的思念一樣"
            },
            {
              starttime = 162.43,
              str = "生活下去"
            },
            {
              starttime = 164.04,
              str = "即使一邊哭着也沒關係啊"
            },
            {
              starttime = 165.55,
              str = "在重複着這樣過後就能歡笑的生涯"
            },
            {
              starttime = 167.66,
              str = "即使明天會也再次被受雨打"
            },
            {
              starttime = 170.19,
              str = "也終有一天會能說出"
            },
            {
              starttime = 172.52,
              str = "誕生於這世上實在太好了的吧"
            },
            {
              starttime = 174.04,
              str = "直到那天為止"
            },
            {
              starttime = 175.45,
              str = "我決不會認輸的啊"
            },
            {
              starttime = 179.56,
              str = "不會認輸的哦...",
              time = 4
            }
          },
          color = "FF941919"
        })
      end)
      DisasterDemonShowAiLoading(u, 1, endtime + 2.4)
      u:additem("I0PT")
      u:adddivinity(3)
      u:setdata("传奇灾祸之力成长加成倍率", 2)
      u:setdata("灾祸等级", 1)
      u:changedata("全属性增幅", 0.12)
      ChangeValue(Correction_MHp, sy, 0.024)
      ChangeValue(DamageSystem_Shjc, sy, 0.096)
      ChangeZhanzhengqiyue(2)
      ChangeValue(DamageSystem_Ssjianshao, sy, 0.6, 1)
      u:changedata("东方变异补正", 40)
      u:changedata("黑暗变异补正", 40)
      local disaster_block = 0
      local dark_add = 0
      ac.loop(3000, function()
        u:changedata("固定格挡", -disaster_block)
        disaster_block = u:getallattri()
        u:changedata("固定格挡", disaster_block)
        u:changedata("效果增强-黑暗", -dark_add)
        dark_add = 0.005 * u:getdata("东方变异数量")
        u:changedata("效果增强-黑暗", dark_add)
      end)
      local disaster_dolls = {}
      
      local function get_disaster_doll_position(index, total)
        local x, y = u:getxy()
        local angle = u:getface()
        local dd = 500 / total
        local col = index - (total + 1) / 2
        x, y = PolarXY(x, y, -50, angle)
        x, y = PolarXY(x, y, col * dd, angle + 90)
        return x, y
      end
      
      local function refresh_disaster_doll_index()
        local new_dolls = {}
        for _, doll in ipairs(disaster_dolls) do
          if doll and GetUnitTypeId(doll.handle) ~= 0 then
            new_dolls[#new_dolls + 1] = doll
            doll:setdata("灾祸魔神-魔神人形序号", #new_dolls)
          end
        end
        disaster_dolls = new_dolls
      end
      
      ac.loop(250, function()
        refresh_disaster_doll_index()
        local total = #disaster_dolls
        for index, doll in ipairs(disaster_dolls) do
          local x, y = get_disaster_doll_position(index, total)
          local x2, y2 = doll:getxy()
          local dis = DistanceXY(x, y, x2, y2)
          if 2000 < dis then
            doll:setxy(x, y)
            IssueImmediateOrder(doll.handle, "stop")
          elseif 50 <= dis then
            unitmove({
              unit = doll.handle,
              time = 0.25,
              distance = math.max(0, dis - 50),
              angle = AngleXY(x2, y2, x, y),
              isfly = true
            })
          end
        end
      end)
      
      local function create_disaster_doll()
        refresh_disaster_doll_index()
        local x, y = get_disaster_doll_position(#disaster_dolls + 1, #disaster_dolls + 1)
        local angle = u:getface()
        local doll = u:createunit("u0F1", x, y, angle)
        doll:setdata("召唤物-魔神人形")
        doll:setdata("常规召唤物", "魔神人形")
        doll:setdata("灾祸魔神-魔神人形序号", #disaster_dolls + 1)
        doll:groupadd(u:getdata("召唤物组"))
        doll:groupadd(Group_ZhaohuanwuAll)
        disaster_dolls[#disaster_dolls + 1] = doll
        refresh_disaster_doll_index()
        u:changedata("召唤物数量", 1)
        return doll
      end
      
      local function disaster_level_up(newlv)
        local ok = TryDisasterDemonLevelUp(u, newlv)
        if ok and newlv == 2 then
          for i = 1, 3 do
            create_disaster_doll()
          end
          u:sendmessage("|cFFCC0000灾祸魔神-援护开启|r")
        end
        if ok and newlv < 6 then
          DisasterDemonShowAiLoading(u, newlv)
        end
        if ok and newlv == 5 then
          Fskillreplace({
            unit = u.handle,
            level = 2,
            skill_F = "S0DA",
            skill_X = "S0DB",
            name = "祸·无相转生",
            icon = "Cq_HlmN_F.tga",
            isforce = false,
            efunc = function()
              u:addtrgevent("单位-发动技能", function(args)
                if args.skill == S2ID("S0DA") or args.skill == S2ID("S0DB") then
                  u:settimedata("祸无相转生时间", 0.25)
                  u:playseensound(Sound_Hlm_Wuxiangzhuansheng)
                  u:effectadd("war3mapImported\\blackblink.mdx", "origin")
                end
              end)
            end
          })
        end
        if ok and newlv == 6 then
          DisasterDemonLv6Movie(u)
          NameID[sy] = "|cFF990000祸|r|cFF800D0D灵|r|cFF661A1A梦|r"
          Boolean_ColorName[sy] = true
          u:setplayername(NameID[sy])
          ColorName[sy][1] = {
            method = 1,
            name = "祸灵梦",
            colors = {
              "ff5353",
              "661A1A",
              "ff5353"
            },
            lengthcd = 14,
            offsetspeed = 0.25
          }
        end
        return ok
      end
      
      ac.loop(1000, function()
        local lv = u:getdata("灾祸等级")
        if lv == 1 and KillCumCount[sy] > 100 then
          disaster_level_up(2)
        elseif lv == 2 and u:hasdata("灾祸魔神-BOSS击杀进阶") then
          disaster_level_up(3)
        elseif lv == 3 and (u:getdata("东方变异数量") >= 5 or u:getdata("黑暗变异数量") >= 15) then
          disaster_level_up(4)
        elseif lv == 4 and u:getallattri() >= 500 then
          disaster_level_up(5)
        elseif lv == 5 and u:getdata("系统-累积升级") >= 60 then
          disaster_level_up(6)
        end
      end)
      
      local function disaster_lv6_boss_alone()
        if not (not (u:getdata("灾祸等级") < 6) and u:isalive()) or not BossBattle then
          return false, 0
        end
        local alive_count = 0
        local dead_teammates = 0
        local play_count = 0
        ForGroupLuaNew(Group_PlayHero, function(xq)
          if xq.owner ~= Player(PLAYER_NEUTRAL_PASSIVE) and not xq:hasdata("系统-已删模") then
            play_count = play_count + 1
          end
          if xq:isalive() and xq.owner ~= Player(PLAYER_NEUTRAL_PASSIVE) and not xq:hasdata("系统-已删模") then
            alive_count = alive_count + 1
          elseif xq.handle ~= u.handle and xq.owner ~= Player(PLAYER_NEUTRAL_PASSIVE) and not xq:hasdata("系统-已删模") then
            dead_teammates = dead_teammates + 1
          end
        end)
        return play_count <= 1 or alive_count <= 1, dead_teammates
      end
      
      local lv6_move = 0
      local lv6_stats = 0
      local lv6_crit = 0
      local lv6_active_stage
      local lv6_dead_teammates = 0
      ac.loop(1000, function()
        if not lv6_active_stage then
          local can_active, dead_teammates = disaster_lv6_boss_alone()
          if can_active then
            lv6_active_stage = Stage
            lv6_dead_teammates = dead_teammates
          end
        elseif not BossBattle or Stage ~= lv6_active_stage then
          lv6_active_stage = nil
          lv6_dead_teammates = 0
        end
        local active = lv6_active_stage ~= nil
        local dead_teammates = lv6_dead_teammates
        local new_move = active and 800 or 0
        local new_stats = active and math.floor((KillCumCount[sy] or 0) * 0.1) or 0
        local new_crit = active and 0.5 + dead_teammates * 0.1 or 0
        if lv6_move ~= new_move then
          ChangeValue(HeroMenu_ExtraMoveSpeed, sy, new_move - lv6_move)
          lv6_move = new_move
        end
        if lv6_stats ~= new_stats then
          u:addallstats(new_stats - lv6_stats)
          lv6_stats = new_stats
        end
        if lv6_crit ~= new_crit then
          ChangeValue(DamageSystem_Baoshang, sy, new_crit - lv6_crit)
          lv6_crit = new_crit
        end
        if active then
          u:setdata("灾祸魔神-Lv6决死层数", dead_teammates)
          if not u:hasdata(str .. "-Lv6凶恶技术") then
            u:setdata(str .. "-Lv6凶恶技术")
            u:sendmessage("|cFF990000凶恶技术开启")
            ChangeBGM(BGM_Shenyuan_Zaihuo)
          end
        else
          StopSoundBJ(BGM_Shenyuan_Zaihuo, true)
          u:setdata("灾祸魔神-Lv6决死层数", 0)
          if u:hasdata(str .. "-Lv6凶恶技术") then
            u:deldata(str .. "-Lv6凶恶技术")
          end
        end
      end)
      u:addstexiao(str, "决死效果", function(args)
        if args.dt and not u:hasdata(str .. "-天上道冷却") then
          args.dt = false
          u:settimedata(str .. "-天上道冷却", 180)
          u:buffset(u.handle, 4, "绝对闪避")
          u:sethp(100, true)
          u:sendmessage("|cFFCC0000天上道-免疫致死伤害|r")
        end
        if args.dt and u:getdata("灾祸魔神-Lv6决死层数") > 0 then
          args.dt = false
          u:changedata("灾祸魔神-Lv6决死层数", -1)
          u:sendmessage("|cFF990000[祸灵梦]决死剩余次数:" .. math.floor(u:getdata("灾祸魔神-Lv6决死层数")))
          u:effectadd("Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl")
          u:effectadd("war3mapImported\\texiao_xuebao.mdx")
          u:buffset(u.handle, 0.1, "无敌")
        end
      end)
      u:addstexiao(str, "终结伤害计算效果", function(args)
        if u:hasdata(str .. "-Lv6凶恶技术") then
          local info = args.damageinfo
          local add = (u:getdata("黑暗变异数量") + u:getdata("东方变异数量")) * 0.01
          info.endup = info.endup + add
        end
      end)
      u:addstexiao(str, "直接伤害特效", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        tg:buffset(u.handle, 1, "破坏-伤害免疫")
        tg:buffset(u.handle, 1, "破坏-伤害抗性")
        if u:getdata("灾祸等级") >= 6 and not u:hasdata(str .. "-Lv6暗伤冷却") then
          u:settimedata(str .. "-Lv6暗伤冷却", 0.3)
          if not u:hasdata(str .. "-附伤音效冷却") then
            u:settimedata(str .. "-附伤音效冷却", 5)
            u:playseensound(Sound_Hlm_Haoruo)
          end
          for i = 1, 3 do
            DamageUnit({
              bj = "[灾祸魔神]凶恶技术",
              unit = tg.handle,
              source = u.handle,
              damage = info.damage * 0.4,
              level = 1,
              type = "灵力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "暗"
            })
          end
        end
        if not u:hasdata(str .. "-魔力抹除冷却") and GetRandom100(25) then
          u:settimedata(str .. "-魔力抹除冷却", 1)
          local x, y = tg:getxy()
          local txsh = 15000 + u:getstr() * 500 + u:getlevel() * 100
          Effectcreate("Hlm (4).mdx", x, y)
          for _, xq in ac.selector():in_rangexy(x, y, 300):is_enemy(u.handle):ipairs() do
            xq = getunit(xq)
            DamageUnit({
              bj = "灾祸魔神-魔力抹除",
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
        if not tg:hasdata(str .. "-地狱道冷却") and GetRandom100(20) then
          tg:settimedata(str .. "-地狱道冷却", 1)
          local max_count = math.max(1, u:getdata("灾祸等级")) * 3
          if max_count > tg:getdata("灾祸魔神-侵蚀层数") then
            tg:changetimedata("灾祸魔神-侵蚀层数", 1, 7)
            tg:effectadd("Hlm (5).mdx", "origin")
            if tg:getdata("灾祸魔神-侵蚀层数") == max_count then
              u:playseensound(Sound_Hlm_Haoruo)
            end
          end
        end
      end)
      AddAllSTexiao(str, "伤害系统计算效果", function(args)
        local tg = args.tg
        local info = args.damageinfo
        if tg:hasdata("灾祸魔神-侵蚀层数") then
          info.ewss = info.ewss + 0.02 * tg:getdata("灾祸魔神-侵蚀层数")
        end
      end)
      u:addstexiao(str, "近战伤害效果", function(args)
        local u = args.u
        local tg = args.tg
        if not u:hasdata(str .. "-修罗道冷却") then
          u:settimedata(str .. "-修罗道冷却", 0.5)
          local maxhp_rate = math.max(1, u:getdata("灾祸等级")) * 1
          if tg:isboss() then
            maxhp_rate = math.max(1, u:getdata("灾祸等级")) * 0.1
          end
          LossHpUnit({
            u = u,
            tg = tg,
            damage = 0,
            perhp = 0,
            maxhp = maxhp_rate,
            bj = "[生命损耗]灾祸魔神-修罗道"
          })
        end
      end)
      
      local function disaster_escape()
        if u:getdata("灾祸等级") < 4 or u:hasdata(str .. "-受击脱离冷却") then
          return false
        end
        u:settimedata(str .. "-受击脱离冷却", 5)
        u:clearbuff("眩晕")
        u:clearbuff("僵直")
        u:clearbuff("缠绕")
        u:clearbuff("混乱")
        u:clearbuff("麻痹")
        u:clearbuff("冰冻")
        u:clearbuff("石化")
        local x, y = u:getxy()
        local dx, dy = PolarXY(x, y, GetRandomReal(100, 300), GetRandomAngle())
        mapmove(u.handle, "祸灵梦-境界操控", dx, dy)
        return true
      end
      
      local control_buffs = {
        "眩晕",
        "僵直",
        "缠绕",
        "混乱",
        "麻痹",
        "冰冻",
        "石化"
      }
      for _, buff in ipairs(control_buffs) do
        u:addstexiao(str, "被施加Buff时效果-" .. buff, function(args)
          if disaster_escape() then
            args.time = 0
          end
        end)
      end
      local summon_cache = {}
      ForGroupLuaNew(u:getdata("召唤物组"), function(xq)
        summon_cache[xq.handle] = true
      end)
      ac.loop(500, function(timer)
        ForGroupLuaNew(u:getdata("召唤物组"), function(xq)
          if not summon_cache[xq.handle] then
            summon_cache[xq.handle] = true
            if not xq:hasdata(str .. "-畜生道复制物") and GetRandom100(10) then
              local x, y = xq:getxy()
              local mj = u:createunit(GetUnitTypeId(xq.handle), x, y, xq:getface())
              mj:setdata(str .. "-畜生道复制物")
              if xq:hasdata("常规召唤物") then
                mj:setdata("召唤物-" .. xq:getdata("常规召唤物"))
                mj:setdata("常规召唤物", xq:getdata("常规召唤物"))
              end
              mj:groupadd(u:getdata("召唤物组"))
              mj:groupadd(Group_ZhaohuanwuAll)
              mj:setguard(u.handle)
              summon_cache[mj.handle] = true
              u:sendmessage("|cFFCC0000畜生道-复制召唤物|r")
            end
          end
        end)
      end)
      ModelReplace({
        u = u,
        model = "M-Reimu.mdx",
        modelsize = 1,
        modelname = "|cFF990000祸|r|cFF800D0D灵|r|cFF661A1A梦|r",
        modelicon = "Portrait_Huolingmeng.tga",
        isforce = true
      })
      u:uivar_change({
        keyname = "祸灵梦",
        keytype = "传奇栏",
        text = "|cFF990000灾|r|cFFAD0000祸|r|cFFC20000魔|r|cFFD60000神|r\n|cFF990000敵を拒んだ 苦痛を拒んだ|r\n|cFF850A0A怨恨を拒んだ 悲哀を拒んだ|r\n|cFF701414死を拒んだ 滅びを拒んだ|r\n|cFF5C1F1F忌避すべき全てを拒んだと思う|r",
        icon = "Cq_HlmN_Shenhua.tga",
        clickfunc = function(u, button)
          if u:getdata("灾祸等级") < 2 then
            u:sendmessage("|cFFCC0000灾祸等级Lv2后才能生成魔神人形|r")
            return
          end
          local need = u:getdata("灾祸魔神-生成人形次数") + 1
          local left = need
          for i = 1, 6 do
            local item = u:getcountitem(i)
            if GetItemTypeId(item) == S2ID("I0KJ") then
              local count = math.max(1, GetItemCharges(item))
              left = left - count
              if left <= 0 then
                break
              end
            end
          end
          if 0 < left then
            u:sendmessage("|cFFCC0000需要消耗" .. need .. "个灾祸药剂|r")
            return
          end
          left = need
          for i = 1, 6 do
            local item = u:getcountitem(i)
            if GetItemTypeId(item) == S2ID("I0KJ") then
              local count = math.max(1, GetItemCharges(item))
              if left < count then
                SetItemCharges(item, count - left)
                left = 0
              else
                left = left - count
                RemoveItemLua(item)
              end
              if left <= 0 then
                break
              end
            end
          end
          u:changedata("灾祸魔神-生成人形次数", 1)
          create_disaster_doll()
          u:sendmessage("|cFFCC0000消耗" .. need .. "个灾祸药剂,召唤魔神人形|r")
        end
      })
    end
  end,
  ["月见英子"] = function(u)
    local sy = u.ownerid
    local str = "变异判定-月见英子"
    if not u:hasdata(str) then
      u:setplayername("|cFF7DBEF1[|r|cFFFFFF99月见英子|r|cFF7DBEF1]|r" .. NameID[sy])
      PlayBGM({
        bgm = BGM_Kongming_20,
        time = 205,
        ID = 62,
        unit = u.handle
      })
      u:setdata(str)
      u:reduceshw()
      Qiyue_Langkepaidu_Yueying = u.handle
      coopjudge("浪客派对")
      u:setdata("属性-歌姬神化")
      u:addskill("A1F6")
      local ky = u:getdata("抗药性")
      ac.loop(1000, function()
        if ky > u:getdata("抗药性") then
          local add = 0.005 * u:getdata("抗药性")
          ChangeValue(DamageSystem_Shjc, sy, 0.1 * add)
        end
        ky = u:getdata("抗药性")
      end)
      u:addstexiao(str, "伤害判定后特效", function(args)
        local u = args.u
        local tg = args.tg
        if not u:hasdata(str .. "-特效冷却") and not u:hasdata("七窍玲珑无法触发") then
          u:settimedata(str .. "-特效冷却", 0.1)
          u:changedata("七窍玲珑叠加次数", 1)
          if u:getdata("七窍玲珑叠加次数") >= 7 then
            local txsh = 150 * u:getint()
            u:setdata("七窍玲珑叠加次数", 0)
            local x, y = tg:getxy()
            Effectcreate("0Tx\\0Tx_Yueying_01.mdl", x, y)
            u:setdata("七窍玲珑无法触发")
            DamageUnit({
              bj = "月见英子七窍玲珑",
              unit = tg.handle,
              source = u.handle,
              damage = txsh,
              level = 1,
              type = "灵力",
              isvest = true,
              isattack = false,
              isnoarmor = false,
              element = "无"
            })
            u:deldata("七窍玲珑无法触发")
          end
        end
      end)
      u:uivar_change({
        keyname = "地狱歌姬",
        keytype = "传奇栏",
        text = "|cFFFFFF99月|r|cFFF5E0AD见|r|cFFEBC2C2英|r|cFFE0A3D6子|r\n|cFFE0A3D6歌姬 唯一\n地狱歌姬|r\n|cFFFFFF99提升[歌姬变异数量*1%]伤害加成\n提升[歌姬变异数量*0.2%]终结伤害\n处于歌曲播放时,提升自身150额外移速、5%伤害加成与25%终结减伤\n每次播放非重复歌曲时提升自身5点全属性\n不处于[BGM OFF]状态时,杀敌时15%提升1点属性|r\n|cFFE0A3D6明智春馨|r\n|cFFFFFF99使用任何非净化药剂的药剂时同时视为使用一瓶净化药剂\n降低抗药性时提升[5%*降低抗药性]伤害加成|r\n|cFFE0A3D6秀外慧中|r\n|cFFFFFF99技能栏施法距离翻倍\n死亡不会掉落物品|r\n|cFFE0A3D6七窍玲珑|r\n|cFFFFFF99对同一目标每造成7次特效伤害时附带[智力*150]灵力伤害,叠加冷却0.1秒(该伤害不计入特效次数)|r",
        icon = "war3mapImported\\BTNEwl_Yueying_02",
        isclearclick = true
      })
    end
  end
})
