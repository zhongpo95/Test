-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
Morihuanjing_Time = 0
Morihuanjing_MaxTime = 0
Morihuanjing_String = ""
Boolean_Tianqi = false
Boolean_Haifeng = false
Boolean_Siwang = false
Boolean_CallofCthulhu = false
CallofCthulhuGroup = {}
Boolean_Fuxiuchen = false
Boolean_Pandora = false
Boolean_Wuxinganye = false
local text = class.text:builder({
  x = 1240,
  y = 675,
  w = 300,
  h = 300,
  text = "",
  align = "left",
  font_size = 12,
  color = "FFFFFFFF"
})
text:hide()
UI_Text_Huanjing2 = text

local function init()
  local change = GetRandomReal(90, 240)
  local tz = NPC_TIANZI
  SendMsgAll(math.floor(change) .. "초 후 종말 환경 시작")
  tz = getunit(tz)
  tz:setdata("天气数字", GetRandomInt(1, 10))
  local cs = 0
  local g = CreateGroupLua()
  local color = 4294294559
  ac.loop(1000, function()
    cs = cs + 1
    Morihuanjing_Time = Morihuanjing_Time - 1
    if Boolean_Tianqi and GetRandom100(1) and Group_Counts(Group_Monster) > 0 then
      local skill
      if GetRandom100(50) then
        skill = "S05X"
      else
        skill = "S05Y"
      end
      if Group_Counts(Group_Monster) > 0 then
        local monster = Group_Randomunit(Group_Monster)
        if type(monster) == "table" then
          monster:addskill(skill)
        end
      end
    end
    if change <= cs or tz:hasdata("环境变更") then
      local yxb = false
      ForGroupLuaNew(BeibaoGroup, function(bb)
        if not yxb and bb:hasdata("背包-艾露猫") and GetRandom100(25) then
          yxb = true
          bb:animeact(GetRandomInt(2, 4))
          Srtr_sound(bb, Sound_Alm_Huanjing)
          flytext({
            unit = bb.handle,
            text = "대장, 날씨가 바뀐다냥!",
            size = 8,
            time = 3,
            r = 51,
            g = 102,
            b = 255,
            height = -50,
            yspeed = 0.02
          })
        end
      end)
      cs = 0
      tz:deldata("环境变更")
      change = GetRandomInt(60, 150)
      SendMsgAll(math.floor(change) .. "초 후 환경 전환")
      Morihuanjing_Time = change
      Morihuanjing_MaxTime = change
      PlayGlobalSound(AbominationAlternateDeath1)
      tz:delskill("A13V")
      ForGroupLuaNew(Group_Monster, function(xq)
        if xq:hasdata("迅捷特性") then
          xq:addskill("S00G")
          xq:delskill("迅捷特性")
        end
        xq:delskill("S05X")
        xq:delskill("S05Y")
      end)
      Boolean_Haifeng = false
      Boolean_Siwang = false
      Boolean_CallofCthulhu = false
      Boolean_Fuxiuchen = false
      Boolean_Pandora = false
      Boolean_Tianqi = false
      Boolean_Wuxinganye = false
      ForGroupLuaNew(g, function(xq)
        local sy = xq.ownerid
        xq:deldata("环境-坏星")
        xq:deldata("环境-雷鸣")
        xq:deldata("环境-交错次元")
        xq:deldata("环境-腐朽尘")
        xq:deldata("环境-死网")
        xq:deldata("环境-天启")
        xq:delskill("S05W")
        xq:deldata("环境-无星暗夜")
        if xq:hasdata("环境-海风") then
          ChangeValue(HeroMenu_MpCure_MaxMp, sy, -3)
          ChangeValue(Hero_Tili_Huifu, sy, -1)
          xq:deldata("环境-海风")
        end
        if xq:hasdata("环境-怒炎") then
          if xq:hasdata("伊芙利特-怒炎") then
            ChangeValue(HeroMenu_HpChange_MaxHp, sy, -10)
            xq:deldata("伊芙利特-怒炎")
          else
            ChangeValue(HeroMenu_HpRemove_CurHp, sy, -10)
          end
          xq:deldata("环境-怒炎")
        end
        if xq:hasdata("变异判定-麦哲伦") then
          xq:changedata("麦哲伦-考察记录", 3)
        end
        if xq:hasdata("魔镜-无法丢弃") then
          xq:changedata("魔镜-天气切换计数", 1)
          if xq:getdata("魔镜-天气切换计数") == 6 then
            xq:setdata("魔镜-天气切换计数", 0)
            tz:setdata("魔镜天气切换")
          end
        end
      end)
      GroupClearLua(g)
      for i = 1, 6 do
        if Xuanze[i] then
          getunit(Hero[i]):groupadd(g)
        end
      end
      if Nandu_Choose < 5 then
        ForGroupLuaNew(g, function(xq)
          if (xq:hasdata("变异判定-天子") or xq:hasdata("小天鹅-炸鱼薯条") or xq:hasdata("薄暝甲-守望者") and xq:hasdata("物品-薄暝甲") or xq:hasdata("禁忌化-星神の辉光") or xq:ishasitem(Weapons["九字兼定"]) or xq:ishasitem(Weapons["九字兼定-境界"]) or xq:hasdata("卡斯特-人理辅助装置") and xq:hasdata("Caber-剑形态") or xq:hasdata("天子帮助") or xq:getdata("天气免疫") > 0) and not xq:hasdata("变异判定-麦哲伦") then
            xq:groupremove(g)
          end
        end)
      else
        ForGroupLuaNew(g, function(xq)
          if xq:hasdata("天子帮助") and not xq:hasdata("变异判定-麦哲伦") then
            xq:groupremove(g)
          end
        end)
      end
      local max = 9
      local xh = GetRandomInt(1, max)
      if tz:hasdata("椿天气切换") then
        xh = 5
        tz:deldata("椿天气切换")
      end
      if tz:hasdata("翁斯坦天气切换") then
        xh = 2
        tz:deldata("翁斯坦天气切换")
      end
      if tz:hasdata("雷律天气切换") then
        xh = 2
        tz:deldata("雷律天气切换")
      end
      if tz:hasdata("魔镜天气切换") then
        xh = 3
        tz:deldata("魔镜天气切换")
      end
      if tz:hasdata("暗神天气切换") then
        xh = 3
        tz:deldata("暗神天气切换")
      end
      if tz:hasdata("诡秘之主天气切换") then
        xh = 3
        change = 233
        tz:deldata("诡秘之主天气切换")
      end
      if tz:getdata("天气数字") == xh then
        if xh == max then
          xh = 1
        else
          xh = xh + 1
        end
      end
      if Boolean_AnshenBattle then
        xh = 3
      end
      tz:setdata("天气数字", xh)
      if tz:hasdata("真红-任务中") then
        local boss = tz:getdata("真红-任务中")
        boss:changedata("天子环境切换个数", 1)
      end
      if xh == 1 then
        Morihuanjing_String = "坏星"
        color = 4294967193
        Morihuanjing_BaocunString = require("hera_korean").translate("|cFFFFFF99[坏星]\n[所有伤害免疫与伤害闪避效果无效化]|r")
        if not Boolean_Jinselingyu then
          SendMsgAll(Morihuanjing_BaocunString)
        end
        ForGroupLuaNew(g, function(xq)
          xq:setdata("环境-坏星")
        end)
      end
      if xh == 2 then
        AddAllSTexiao("雷鸣", "伤害系统计算效果", function(args)
          local u = args.u
          local info = args.damageinfo
          if u:hasdata("环境-雷鸣") then
            info.lw = info.lw + 1
          end
        end)
        Morihuanjing_String = "雷鸣"
        color = 4294967040
        Morihuanjing_BaocunString = require("hera_korean").translate("|cFFFFFF00[雷鸣]\n[提升所有单位10%伤害加成\n所有单位论外减伤及以下的减伤失效]|r")
        if not Boolean_Jinselingyu then
          SendMsgAll(Morihuanjing_BaocunString)
        end
        ForGroupLuaNew(g, function(xq)
          local sy = xq.ownerid
          xq:setdata("环境-雷鸣")
          if xq:hasdata("变异判定-影之革命者") then
            if xq:hasdata("变异判定-宇智波佐助") then
              ChangeValue(DamageSystem_Shjc, sy, 0.003)
            else
              ChangeValue(DamageSystem_Shjc, sy, 0.002)
            end
          end
        end)
      end
      if xh == 3 then
        Morihuanjing_String = "交错次元"
        color = 4283629696
        Morihuanjing_BaocunString = require("hera_korean").translate("|cFF530080[交错次元]\n[提升50%额外移速\n回忆类药剂基础成功率提升5%但失败时反噬\n冥王星药剂成功率翻倍但失败时反噬，成功时1%被注视\n出现的怪物种类将不再受到波数限制]|r")
        if not Boolean_Jinselingyu and not Boolean_AnshenBattle then
          SendMsgAll(Morihuanjing_BaocunString)
        end
        Boolean_CallofCthulhu = true
        ForGroupLuaNew(g, function(xq)
          xq:setdata("环境-交错次元")
        end)
        local t = "    光明\n    黑暗\n    水\n    炎\n    冰\n    雷\n    毒\n    影\n\n    兽\n    战士\n    机械\n    恶魔\n    吸血鬼\n    龙\n    魔导\n    同奏\n    东方\n\n    童话\n    歌姬\n    根源\n    自然\n    念力\n    灵魂\n"
        local items = {}
        for item in t:gmatch("%S+") do
          table.insert(items, item)
        end
        local result = {}
        for i = 1, 5 do
          local index = GetRandomInt(1, #items)
          table.insert(result, items[index])
          table.remove(items, index)
        end
        table.insert(result, "外域")
        CallofCthulhuGroup = result
      end
      if xh == 4 then
        Morihuanjing_String = "海风"
        color = 4281571839
        Morihuanjing_BaocunString = require("hera_korean").translate("|cFF3399FF[海风]\n[野生植物生长数量翻倍\n视为在水域中\n提升1体力恢复\n提升3%魔力恢复\n杀敌时损耗2%+2点体力\n血肉同化获取值提升50%\n血液源石结晶密度自然增长速率减半]|r")
        if not Boolean_Jinselingyu then
          SendMsgAll(Morihuanjing_BaocunString)
        end
        Boolean_Haifeng = true
        ForGroupLuaNew(g, function(xq)
          local sy = xq.ownerid
          xq:setdata("环境-海风")
          ChangeValue(Hero_Tili_Huifu, sy, 1)
          ChangeValue(HeroMenu_MpCure_MaxMp, sy, 3)
          xq:addskill("S05W")
        end)
      end
      if xh == 5 then
        Morihuanjing_String = "怒炎"
        color = 4294901760
        Morihuanjing_BaocunString = require("hera_korean").translate("|cFFFF0000[怒炎]\n[玩家每秒损耗10%当前生命值\n杀死单位时恢复8%最大生命值,永恒恢复]|r")
        if not Boolean_Jinselingyu then
          SendMsgAll(Morihuanjing_BaocunString)
        end
        ForGroupLuaNew(g, function(xq)
          local sy = xq.ownerid
          xq:setdata("环境-怒炎")
          if xq:getdata("伊芙利特-精灵阶级") >= 3 then
            xq:setdata("伊芙利特-怒炎")
            ChangeValue(HeroMenu_HpChange_MaxHp, sy, 10)
          elseif not xq:hasdata("朱雀院椿-BOSS战") then
            ChangeValue(HeroMenu_HpRemove_CurHp, sy, 10)
          end
        end)
      end
      if xh == 6 then
        Morihuanjing_String = "腐朽尘"
        color = 4281584742
        Morihuanjing_BaocunString = require("hera_korean").translate("|cFF33CC66[腐朽尘]\n[强抑制所有单位生命恢复]|r")
        if not Boolean_Jinselingyu then
          SendMsgAll(Morihuanjing_BaocunString)
        end
        Boolean_Fuxiuchen = true
        ForGroupLuaNew(Group_Monster, function(xq)
          xq:groupadd(HpGroup)
        end)
        ForGroupLuaNew(g, function(xq)
          xq:setdata("环境-腐朽尘")
        end)
      end
      if xh == 7 then
        Morihuanjing_String = "死网"
        color = 4294940928
        Morihuanjing_BaocunString = require("hera_korean").translate("|cFFFF9900[死网]\n[所有玩家额外移速失效\n所有怪物迅捷特性失效,环境结束后将会重新生效]|r")
        if not Boolean_Jinselingyu then
          SendMsgAll(Morihuanjing_BaocunString)
        end
        Boolean_Siwang = true
        ForGroupLuaNew(Group_Monster, function(xq)
          if xq:ishasskill("S00G") then
            xq:delskill("S00G")
            xq:setdata("迅捷特性")
          end
        end)
        ForGroupLuaNew(g, function(xq)
          xq:setdata("环境-死网")
        end)
      end
      if xh == 8 then
        Morihuanjing_String = "潘多拉"
        color = 4284888063
        Morihuanjing_BaocunString = require("hera_korean").translate("|cFF6633FF[潘多拉]\n[总是生效\n魔王特性出现概率翻倍\n拾取补给箱时生命值随机在[50%~150%]之间波动\n补给箱数量15%+1 无触发上限 结算时受到[2%*该效果增加数量*该效果增加数量]生命损耗,生命值不足则即死]|r")
        if not Boolean_Jinselingyu then
          SendMsgAll(Morihuanjing_BaocunString)
        end
        Boolean_Pandora = true
      end
      if xh == 9 then
        Morihuanjing_String = "天启"
        color = 4294954137
        Morihuanjing_BaocunString = require("hera_korean").translate("|cFFFFCC99[天启]\n[提升所有单位10%生命恢复速度(不包括BOSS)\n怪物出现时1%携带环境专属特性\n每秒1%随机给予一只存活怪物环境专属特性\n专属特性在环境持续结束时失去]|r")
        if not Boolean_Jinselingyu then
          SendMsgAll(Morihuanjing_BaocunString)
        end
        tz:addskill("A13V")
        Boolean_Tianqi = true
        ForGroupLuaNew(g, function(xq)
          xq:setdata("环境-天启")
        end)
      end
    end
    if Morihuanjing_String ~= "" then
      if not EnableCustomUI then
        text = UI_Text_Huanjing2
        text:show()
        text:set_text(require("hera_korean").translate(Morihuanjing_String) .. ":" .. math.floor(Morihuanjing_Time))
        text:set_color(color)
      elseif Morihuanjing_Time >= 0 then
        UI_Text_Huanjing:set_text(require("hera_korean").translate(Morihuanjing_String))
        UI_Text_Huanjing:set_color(color)
        UI_Text_Huanjing.timetext:set_color(color)
        UI_Text_Huanjing.timetext:set_text(math.floor(Morihuanjing_Time))
      end
    end
  end)
end

init()
