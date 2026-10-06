-- 복호화한 바이트코드에서 역컴파일한 분석용 소스이며 게임 실행 검증 전입니다.
local Relic = require("gameplay.var.relic.init")
Count_Tuanzidajiazu = 0
Guoboyiwu_Normal = {
  {
    name = "龙飨印记",
    weight = 10,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      add = add + 250
      if u:hasdata("补正神器已选择") or Stage > 3 then
        add = 0
      end
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      if u:hasdata("补正神器已选择") or Stage > 3 or u:getdata("龙" .. "变异数量") == 0 then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("补正神器已选择")
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      local ct = "龙"
      u:changedata(ct .. "变异补正", 100)
      local count = 0
      u:addstexiao(var.name, "过波时效果", function(args)
        count = count + 1
        if count == 2 then
          count = 0
          u:changedata(ct .. "变异数量", 1)
        end
      end)
    end,
    effectname = "|cFF990000龙飨印记|r",
    effecttext = "|cFF33FF33普通 补正神器|r\n|cFF990000龙词条补正提升100%\n每2波提升1龙词条\n可以携带多个龙纹章|r",
    effectart = "Shenqi_R_1.blp",
    test = "    "
  },
  {
    name = "拟造圣杯",
    weight = 10,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      add = add + 250
      if u:hasdata("补正神器已选择") or Stage > 3 then
        add = 0
      end
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      if u:hasdata("补正神器已选择") or Stage > 3 or u:getdata("魔导" .. "变异数量") == 0 then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("补正神器已选择")
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:deldata("圣杯残片使用")
      local ct = "魔导"
      u:changedata(ct .. "变异补正", 100)
      local count = 0
      u:addstexiao(var.name, "过波时效果", function(args)
        count = count + 1
        if count == 2 then
          count = 0
          u:changedata(ct .. "变异数量", 1)
        end
      end)
    end,
    effectname = "|cFFFFFF00拟造圣杯|r",
    effecttext = "|cFF33FF33普通 补正神器|r\n|cFFFFFF00魔导补正提升100%\n每2波提升1魔导词条\n可以无限制使用圣杯残片,第一次后效果减半(且不享受从者加成)\n每使用过一次，额外提升20%魔导补正|r",
    effectart = "Shenqi_R_2.blp",
    test = "    "
  },
  {
    name = "甩葱人偶",
    weight = 50,
    key = {"歌姬"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      if u:hasdata("隐藏职业-虚拟主播") then
        add = add + 500
      end
      add = add + 250
      if u:hasdata("补正神器已选择") or Stage > 3 then
        add = 0
      end
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      if u:hasdata("补正神器已选择") or Stage > 3 or u:getdata("歌姬" .. "变异数量") == 0 then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("补正神器已选择")
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:changedata("歌姬变异数量", 2)
      local ct = "歌姬"
      u:changedata(ct .. "变异补正", 100)
      local count = 0
      u:addstexiao(var.name, "过波时效果", function(args)
        count = count + 1
        if count == 2 then
          count = 0
          u:changedata(ct .. "变异数量", 1)
        end
      end)
    end,
    effectname = "|cFF66FF99甩葱人偶|r",
    effecttext = "|cFF33FF33普通 补正神器|r\n|cFF66FF99歌姬补正提升100%\n每2波提升1歌姬词条\n歌姬词条+3|r",
    effectart = "Shenqi_N_18.blp",
    test = "    "
  },
  {
    name = "五芒星徽章",
    weight = 10,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      if u:isinmaxvar("恶魔") then
        add = add + 500
      end
      add = add + 250
      if u:hasdata("补正神器已选择") or Stage > 3 then
        add = 0
      end
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      if u:hasdata("补正神器已选择") or Stage > 3 or u:getdata("恶魔" .. "变异数量") == 0 then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("补正神器已选择")
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      local ct = "恶魔"
      u:changedata(ct .. "变异补正", 100)
      local count = 0
      u:addstexiao(var.name, "过波时效果", function(args)
        count = count + 1
        if count == 2 then
          count = 0
          u:changedata(ct .. "变异数量", 1)
        end
      end)
    end,
    effectname = "|cFFCC0000五芒星徽章|r",
    effecttext = "|cFF33FF33普通 补正神器|r\n|cFFCC0000恶魔词条补正提升100%\n每2波提升1恶魔词条|r",
    effectart = "Shenqi_N_26.blp",
    test = "    "
  },
  {
    name = "告死鸟",
    weight = 10,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      if u:isinmaxvar("不死") then
        add = add + 500
      end
      add = add + 250
      if u:hasdata("补正神器已选择") or Stage > 3 then
        add = 0
      end
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      if u:hasdata("补正神器已选择") or Stage > 3 or u:getdata("不死" .. "变异数量") == 0 then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("补正神器已选择")
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      ChangeValue(Revise_PoisonResist, sy, 1)
      local ct = "不死"
      u:changedata(ct .. "变异补正", 100)
      local count = 0
      u:addstexiao(var.name, "过波时效果", function(args)
        count = count + 1
        if count == 2 then
          count = 0
          u:changedata(ct .. "变异数量", 1)
        end
      end)
    end,
    effectname = "|cFF666699告死鸟|r",
    effecttext = "|cFF33FF33普通 补正神器|r\n|cFF666699不死词条补正提升100%\n每2波提升1不死词条\n免疫毒素|r",
    effectart = "Shenqi_N_27.blp",
    test = "    "
  },
  {
    name = "碎片整理程序",
    weight = 10,
    key = {"机械"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      if u:isinmaxvar("机械") then
        add = add + 500
      end
      add = add + 250
      if u:hasdata("补正神器已选择") or Stage > 3 then
        add = 0
      end
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      if u:hasdata("补正神器已选择") or Stage > 3 or u:getdata("机械" .. "变异数量") == 0 then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("补正神器已选择")
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      local ct = "机械"
      u:changedata(ct .. "变异补正", 100)
      local count = 0
      u:addstexiao(var.name, "过波时效果", function(args)
        count = count + 1
        if count == 2 then
          count = 0
          u:changedata(ct .. "变异数量", 1)
        end
      end)
    end,
    effectname = "|cFF999999碎片整理程序|r",
    effecttext = "|cFF33FF33普通 补正神器|r\n|cFF999999机械补正提升100%\n每2波提升1机械词条\n机械词条+1|r",
    effectart = "Shenqi_N_7.blp",
    test = "    "
  },
  {
    name = "吸血鬼之魅",
    weight = 10,
    key = {"吸血鬼"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      if u:isinmaxvar("吸血鬼") then
        add = add + 500
      end
      add = add + 250
      if u:hasdata("补正神器已选择") or Stage > 3 then
        add = 0
      end
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      if u:hasdata("补正神器已选择") or Stage > 3 or u:getdata("吸血鬼" .. "变异数量") == 0 then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("补正神器已选择")
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      local ct = "吸血鬼"
      u:changedata(ct .. "变异补正", 100)
      local count = 0
      u:addstexiao(var.name, "过波时效果", function(args)
        count = count + 1
        if count == 2 then
          count = 0
          u:changedata(ct .. "变异数量", 1)
        end
      end)
    end,
    effectname = "|cFFFF3300吸血鬼之魅|r",
    effecttext = "|cFF33FF33普通 补正神器|r\n|cFFFF3300吸血鬼补正提升100%\n每2波提升1吸血鬼词条\n吸血鬼词条+1|r",
    effectart = "Shenqi_N_8.blp",
    test = "    "
  },
  {
    name = "异兽雕塑",
    weight = 10,
    key = {"兽"},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      if u:isinmaxvar("兽") then
        add = add + 500
      end
      add = add + 250
      if u:hasdata("补正神器已选择") or Stage > 3 then
        add = 0
      end
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      if u:hasdata("补正神器已选择") or Stage > 3 or u:getdata("兽" .. "变异数量") == 0 then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("补正神器已选择")
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      local ct = "兽"
      u:changedata(ct .. "变异补正", 100)
      local count = 0
      u:addstexiao(var.name, "过波时效果", function(args)
        count = count + 1
        if count == 2 then
          count = 0
          u:changedata(ct .. "变异数量", 1)
        end
      end)
    end,
    effectname = "|cFFFF9900异兽雕塑|r",
    effecttext = "|cFF33FF33普通 补正神器|r\n|cFFFF9900兽补正提升100%\n每2波提升1兽词条\n兽词条+1|r",
    effectart = "Shenqi_N_9.blp",
    test = "    "
  },
  {
    name = "密歇根大学毕业证",
    weight = 10,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      if u:isinmaxvar("外域") then
        add = add + 500
      end
      add = add + 250
      if u:hasdata("补正神器已选择") or Stage > 3 then
        add = 0
      end
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      if u:hasdata("补正神器已选择") or Stage > 3 or u:getdata("外域" .. "变异数量") == 0 then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("补正神器已选择")
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      local ct = "外域"
      u:changedata(ct .. "变异补正", 100)
      local count = 0
      u:addstexiao(var.name, "过波时效果", function(args)
        count = count + 1
        if count == 2 then
          count = 0
          u:changedata(ct .. "变异数量", 1)
        end
      end)
    end,
    effectname = "|cFF996699密歇根大学毕业证|r",
    effecttext = "|cFF33FF33普通 补正神器|r\n|cFF996699外域补正提升100%\n每2波提升1外域词条\n被注视概率翻倍|r",
    effectart = "Shenqi_N_10.blp",
    test = "    "
  },
  {
    name = "luce人偶",
    weight = 10,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      if u:isinmaxvar("光明") then
        add = add + 500
      end
      add = add + 250
      if u:hasdata("补正神器已选择") or Stage > 3 then
        add = 0
      end
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      if u:hasdata("补正神器已选择") or Stage > 3 or u:getdata("光明" .. "变异数量") == 0 then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("补正神器已选择")
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:adddivinity(1)
      local ct = "光明"
      u:changedata(ct .. "变异补正", 100)
      local count = 0
      u:addstexiao(var.name, "过波时效果", function(args)
        count = count + 1
        if count == 2 then
          count = 0
          u:changedata(ct .. "变异数量", 1)
        end
      end)
    end,
    effectname = "|cFFFFCCCCluce人偶|r",
    effecttext = "|cFF33FF33普通 补正神器|r\n|cFFFFCCCC神性+1\n光明补正提升100%\n每2波提升1光明词条|r",
    effectart = "Shenqi_N_11.blp",
    test = "    "
  },
  {
    name = "幻想乡缘起",
    weight = 10,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      if u:isinmaxvar("东方") then
        add = add + 500
      end
      add = add + 250
      if u:hasdata("补正神器已选择") or Stage > 3 then
        add = 0
      end
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      if u:hasdata("补正神器已选择") or Stage > 3 or u:getdata("东方" .. "变异数量") == 0 then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("补正神器已选择")
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      local ct = "东方"
      u:changedata(ct .. "变异补正", 100)
      local count = 0
      u:addstexiao(var.name, "过波时效果", function(args)
        count = count + 1
        if count == 2 then
          count = 0
          u:changedata(ct .. "变异数量", 1)
        end
      end)
    end,
    effectname = "|cFFFF99FF幻想乡缘起|r",
    effecttext = "|cFF33FF33普通 补正神器|r\n|cFFFF99FF提升100%东方变异补正\n每2波提升1东方词条|r",
    effectart = "Shenqi_N_12.blp",
    test = "    "
  },
  {
    name = "黑暗之环",
    weight = 10,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      if u:isinmaxvar("黑暗") then
        add = add + 500
      end
      add = add + 250
      if u:hasdata("补正神器已选择") or Stage > 3 then
        add = 0
      end
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      if u:hasdata("补正神器已选择") or Stage > 3 or u:getdata("黑暗" .. "变异数量") == 0 then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("补正神器已选择")
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      local max = 100
      ac.loop(100, function()
        if u:isinmaxvar("黑暗") then
          max = 100 - 5 * u:getdata("黑暗变异数量")
          if max <= 15 then
            max = 15
          end
          if u:getperhp() >= max then
            u:sethp(max, true)
          end
        end
      end)
      local ct = "黑暗"
      u:changedata(ct .. "变异补正", 100)
      local count = 0
      u:addstexiao(var.name, "过波时效果", function(args)
        count = count + 1
        if count == 2 then
          count = 0
          u:changedata(ct .. "变异数量", 1)
        end
      end)
    end,
    effectname = "|cFF666666黑暗之环|r",
    effecttext = "|cFF33FF33普通 补正神器|r\n|cFF666666黑暗补正提升100%\n每2波提升1黑暗词条\n主变异是黑暗时:\n[每有1条黑暗词条，你的当前生命值上限降低5%，最多降低至15%]|r",
    effectart = "Shenqi_N_13.blp",
    test = "    "
  },
  {
    name = "至尊魔戒",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      if Stage > 2 then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:sendmessage("|cFF990066你|r|cFF9F0060将|r|cFFA60059沉|r|cFFAC0053沦|r|cFFB2004C在|r|cFFB90046无|r|cFFBF0040尽|r|cFFC60039的|r|cFFCC0033欲|r|cFFD2002D望|r|cFFD90026与|r|cFFDF0020迷|r|cFFE6001A茫|r|cFFEC0013之|r|cFFF2000D中|r")
      u:changedata("系统-神力承载上限", 36)
    end,
    effectname = "|cFFFF6666至|r|cFFFF5C5C尊|r|cFFFF5252魔|r|cFFFF4747戒|r",
    effecttext = "|cFF990000传说神器|r\n|cFFFF3333神力承载上限+36|r\n|cFFCC0033禁止获取其他神器|r",
    effectart = "Shenqi_B_5.blp",
    test = "    "
  },
  {
    name = "心之壁",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
    end,
    effectname = "|cFFCC66CC心之壁|r",
    effecttext = "|cFF33FF33普通|r\n|cFFCC66CC你的护盾可以抵挡生命损耗|r",
    effectart = "Shenqi_N_14.blp",
    test = "    "
  },
  {
    name = "旧印",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      if Morihuanjing_String == "" then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
    end,
    effectname = "|cFF996699旧印|r",
    effecttext = "|cFF33FF33普通|r\n|cFF996699非[交错次元]天气时外域变异获取权重固定为1\n[交错次元]时获取外域变异时必定被注视|r",
    effectart = "Shenqi_N_15.blp",
    test = "    "
  },
  {
    name = "闪耀的偏方三八面体",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      if u:hasdata("隐藏职业-无貌之人") then
        add = add + 500
      end
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      if u:hasdata("原质-王国获取中") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:changedata("外域变异补正", 10000)
      u:changedata("八面体-剩余次数", 6)
      if u:hasdata("隐藏职业-无貌之人") and not u:hasdata("隐藏职业-无貌之人揭露") then
        u:setdata("隐藏职业-无貌之人揭露")
        ChangeValue(Damage_Touzhiwu, sy, 1)
        hideproshow(u.handle)
      end
    end,
    effectname = "|cFF996699闪耀的偏方三八面体|r",
    effecttext = "|cFF33FF33普通|r\n|cFF996699提升10000%外域变异补正直到获取了6个外域变异\n之后除外域，黑暗以外的变异补正归0|r",
    effectart = "Shenqi_N_16.blp",
    test = "    "
  },
  {
    name = "投币式铠甲",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      local hdmax = 0
      ac.loop(3000, function(timer)
        ChangeValue(Hudun_Max, sy, -hdmax)
        hdmax = 10 * u:getgold()
        if u:hasdata("投币式铠甲-冷却中") then
          hdmax = 0
        end
        ChangeValue(Hudun_Max, sy, hdmax)
      end)
      u:addstexiao(var.name, "过波时效果", function(args)
        u:deldata("投币式铠甲-冷却中")
      end)
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt and not u:hasdata("投币式铠甲-冷却中") then
          args.dt = false
          u:setdata("投币式铠甲-冷却中")
          u:addqiankuan(1000)
          u:sendmessage("|cFF999933[投币式铠甲]无敌|r")
          u:buffset(u.handle, 3, "无敌")
          Hdzflash(u)
        end
      end)
    end,
    effectname = "|cFF999933投币式铠甲|r",
    effecttext = "|cFF33FF33普通|r\n|cFF999933提升[当前积分*10]护盾上限\n受到致死伤害时效果失效并消耗1000积分抵挡无敌3秒(可以贷款触发)\n过波时重置冷却|r",
    effectart = "Shenqi_N_17.blp",
    test = "    "
  },
  {
    name = "真空之花",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      if u:hasdata("原质-王国获取中") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:setdata("真空之花-惩罚次数", 3)
    end,
    effectname = "|cFFCCCCFF真空之花|r",
    effecttext = "|cFF33FF33普通|r\n|cFFCCCCFF获取后3个回合不能获取回合奖励(不包括BOSS波)\n之后回合奖励额外获得400积分与40点追忆值|r",
    effectart = "Shenqi_N_19.blp",
    test = "    "
  },
  {
    name = "记忆回想",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:changedata("系统-神力承载上限", 4)
      local pools = VarsCiyuanPools(Vars_Ciyuan_Shenhua, Vars_Huiyi_Dz, Vars_Ciyuan_Yuanshi, Vars_Ciyuan_Yuanshi_Spe, Vars_Lingjiejing, Vars_Shalujiejing, Vars_Ciyuan_Niuqu, Vars_Ciyuan_Longmenshi)
      for i = 1, 2 do
        u:setdata("伊丝-过波奖励获取变异")
        local result = herogetvar(u.handle, pools, "次元")
        u:deldata("伊丝-过波奖励获取变异")
      end
    end,
    effectname = "|cFF996633记忆回想|r",
    effecttext = "|cFF33FF33普通|r\n|cFF996633提升4神力承载上限\n立刻随机获取2个传奇|r",
    effectart = "Shenqi_N_20.blp",
    test = "    "
  },
  {
    name = "返老还童药",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      local downlevel
      if u:getlevel() > 15 then
        downlevel = 15
      else
        downlevel = u:getlevel() - 1
      end
      u:addlevel(-1 * downlevel)
    end,
    effectname = "|cFFFF66FF返老还童药|r",
    effecttext = "|cFF00FFFF稀有|r\n|cFFFF66FF获取时等级降低15级,至低1级|r",
    effectart = "Shenqi_N_22.blp",
    test = "    "
  },
  {
    name = "绿蘑菇",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:changedata("残机剩余数量", 1)
      u:setusedfodd(u:getdata("残机剩余数量"))
      u:playsound(Sound_Shenqi_1up)
      flytext({
        unit = u.handle,
        text = "|cFF66FF991up|r",
        size = 8,
        time = 2,
        height = -50,
        yspeed = 0.02
      })
    end,
    effectname = "|cFF33FF33绿蘑菇|r",
    effecttext = "|cFF33FF33普通|r\n|cFF33FF33获取时残机+1|r",
    effectart = "Shenqi_N_23.blp",
    test = "    "
  },
  {
    name = "1up!",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:changedata("残机剩余数量", 1)
      u:setusedfodd(u:getdata("残机剩余数量"))
      u:playsound(Sound_Shenqi_1up)
      flytext({
        unit = u.handle,
        text = "|cFF66FF991up|r",
        size = 8,
        time = 2,
        height = -50,
        yspeed = 0.02
      })
    end,
    effectname = "|cFF33FF331up!|r",
    effecttext = "|cFF33FF33普通|r\n|cFF33FF33获取时残机+1|r",
    effectart = "Shenqi_N_24.blp",
    test = "    "
  },
  {
    name = "25美分",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addwood(150)
    end,
    effectname = "|cFFFFCC6625美分|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFFCC66获取时一次性获得150追忆值|r",
    effectart = "Shenqi_N_25.blp",
    test = "    "
  },
  {
    name = "豆奶",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      if u:ishasskill(SKILL_TESHUYINGXIONG) then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      ChangeValue(Correction_RPM, sy, 2)
      u:addstexiao(var.name, "伤害显示后效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        info.damage = info.damage * 0.5
      end)
    end,
    effectname = "|cFFCCCC66豆奶|r",
    effecttext = "|cFF33FF33普通|r\n|cFFCCCC66RPM提升200%\n结算伤害降低50%|r\n|cFF949596“幸好不是豆汁”|r",
    effectart = "Shenqi_N_28.blp",
    test = "    "
  },
  {
    name = "BFFS",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      ChangeValue(Correction_Summon, sy, 2)
      ForGroupLuaNew(u:getdata("召唤物组"), function(xq)
        if not xq:hasdata("BFFS-攻速提升") then
          xq:setdata("BFFS-攻速提升")
          xq:addskill("A0IK")
        end
      end)
      ac.loop(5000, function()
        ForGroupLuaNew(u:getdata("召唤物组"), function(xq)
          if not xq:hasdata("BFFS-攻速提升") then
            xq:setdata("BFFS-攻速提升")
            xq:addskill("A0IK")
          end
        end)
      end)
    end,
    effectname = "|cFFFF0000BFFS!|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFF0000召唤物伤害提升200%\n召唤物攻击速度提升50%|r",
    effectart = "Shenqi_N_29.blp",
    test = "    "
  },
  {
    name = "黑蜡烛",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
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
      local zu = {}
      for index, value in ipairs(removezuzhou) do
        if u:hasdata("变异判定-" .. value) then
          u:deldata("变异判定-" .. value)
          u:uivar_remove(value, "疾病栏")
          Ewaishu[sy] = Ewaishu[sy] - 1
        end
      end
      ac.loop(100, function()
        if u:getperhp() >= 90 then
          u:sethp(90, true)
        end
      end)
    end,
    effectname = "|cFF663366黑蜡烛|r",
    effecttext = "|cFF33FF33普通|r\n|cFF663366提升10%生命上限(独立)\n生命百分比不会超过90%\n移除现有的诅咒变异，并不再获得诅咒神器|r\n|cFF949596”据我所知，它至少有4个兄弟姐妹“|r",
    effectart = "Shenqi_N_30.blp",
    test = "    "
  },
  {
    name = "蜘蛛的爱",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
    end,
    effectname = "|cFFCC99CC蜘蛛的爱|r",
    effecttext = "|cFF33FF33普通|r\n|cFFCC99CC免疫蜘蛛的缠绕|r",
    effectart = "Shenqi_N_31.blp",
    test = "    "
  },
  {
    name = "妈妈的钱包",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      for i = 1, 6 do
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
      for k = 1, 6 do
        local b = false
        local pid = sy * System_YiwulanCount - 4
        local pid2 = sy * System_YiwulanCount - 3
        for i = pid, pid2 do
          local ywl2 = getunit(System_Yiwulan[i])
          if not b then
            for j = 1, 6 do
              if GetItemTypeId(ywl2:getcountitem(j)) == S2ID("I07Q") then
                b = true
                u:sendmessage("|cFF7DBEF1遗物栏容量提升|r")
                RemoveItemLua(ywl2:getcountitem(j))
                break
              end
            end
          else
            break
          end
        end
      end
    end,
    effectname = "|cFFCC99CC妈妈的钱包|r",
    effecttext = "|cFF33FF33普通|r\n|cFFCC99CC获得6个遗物与6个遗物栏|r",
    effectart = "Shenqi_N_32.blp",
    test = "    "
  },
  {
    name = "倒影",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      ac.loop(5000, function()
        if u:isalive() then
        else
          u:addmainstats(5)
          u:addgold(14)
        end
      end)
    end,
    effectname = "|cFF666633倒影|r",
    effecttext = "|cFF33FF33普通|r\n|cFF666633处于死亡状态时,每5秒+5点主属性与14点可用积分|r",
    effectart = "Shenqi_N_33.blp",
    test = "    "
  },
  {
    name = "大胃王",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
    end,
    effectname = "|cFF999900大胃王|r",
    effecttext = "|cFF33FF33普通|r\n|cFF999900使用食物会获得三倍效果|r",
    effectart = "Shenqi_N_34.blp",
    test = "    "
  },
  {
    name = "巨口储存罐",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      ac.wait(100, function()
        u:setdata("神器判定-" .. var.name)
      end)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "过波时效果", function(args)
        if not u:hasdata("巨口储存罐-失效") then
          u:sendmessage("|cFF6699FF巨口储存罐-额外奖励|r")
          u:addwood(30)
          u:addgold(150)
        end
      end)
    end,
    effectname = "|cFF6699FF巨口储存罐|r",
    effecttext = "|cFF33FF33普通|r\n|cFF6699FF过波时获得30追忆值与150积分;在乐土商店或天穹交易所消费时失效|r",
    effectart = "Shenqi_N_35.blp",
    test = "    "
  },
  {
    name = "荆棘王冠",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      ChangeValue(DamageSystem_EndSh, sy, 0.022000000000000002)
    end,
    effectname = "|cFFFFFF00荆棘王冠|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFFFF00所受伤害不会低于原始值\n提升2.2%终结伤害|r",
    effectart = "Shenqi_N_36.blp",
    test = "    "
  },
  {
    name = "陶瓷小鱼",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
    end,
    effectname = "|cFFFFFFFF陶瓷小鱼|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFFFFFF获得任意变异时获得100积分|r",
    effectart = "Shenqi_N_37.blp",
    test = "    "
  },
  {
    name = "百年积木",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "受伤后效果", function(args)
        local u = args.u
        local tg = args.tg
        if not u:hasdata(var.name .. "-冷却中") then
          u:setdata(var.name .. "-冷却中")
          u:sendmessage("|cFF99FFFF[百年积木]变异获取")
          for i = 1, 2 do
            local sjz = GetRandomInt(1, 4)
            local poolstr, pools
            if sjz == 1 then
              poolstr = "以太"
              pools = GetYitaiVar(u, "合集", 3)
            end
            if sjz == 2 then
              poolstr = "冥王星"
              pools = MWXPools(u)
            end
            if sjz == 3 then
              poolstr = "次元"
              pools = VarsCiyuanPools(Vars_Ciyuan_Spe, Vars_Ciyuan_Shenhua, Vars_Huiyi_Dz, Vars_Ciyuan_Yuanshi, Vars_Ciyuan_Yuanshi_Spe, Vars_Lingjiejing, Vars_Shalujiejing, Vars_Ciyuan_Niuqu, Vars_Ciyuan_Longmenshi)
            end
            if sjz == 4 then
              poolstr = "血晶"
              pools = {
                Vars_Blood
              }
            end
            herogetvar(u.handle, pools, poolstr)
          end
        end
      end)
      u:addstexiao(var.name, "过波时效果", function(args)
        u:deldata(var.name .. "-冷却中")
      end)
    end,
    effectname = "|cFF99FFFF百年积木|r",
    effecttext = "|cFF33FF33普通|r\n|cFF99FFFF每波首次受伤时,随机获取2个变异|r",
    effectart = "Shenqi_N_39.blp",
    test = "        "
  },
  {
    name = "弹珠袋",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if not u:hasdata("弹珠袋-易伤已生效") then
          u:setdata("弹珠袋-易伤已生效")
          tg:changetimedata("怪物-额外受伤", 0.25, 10)
        end
      end)
    end,
    effectname = "|cFFCC9966弹珠袋|r",
    effecttext = "|cFF33FF33普通|r\n|cFFCC9966首次直接伤害命中时提升目标25%额外受伤持续10秒,无法叠加|r",
    effectart = "Shenqi_N_40.blp",
    test = "        "
  },
  {
    name = "小血瓶",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "过波时效果", function(args)
        local add = 200 + 0.02 * u:getmaxhp()
        u:changemaxhp(add)
      end)
    end,
    effectname = "|cFFFF6666小血瓶|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFF6666过波时提升[200+2%]当前生命上限|r",
    effectart = "Shenqi_N_41.blp",
    test = "        "
  },
  {
    name = "悟史的棒球棍",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
    end,
    effectname = "|cFFFF0000悟史的棒球棍|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFF0000提升150%棍武器伤害|r\n|cFF949596大杀四方的最终神器，更是三神器之首|r",
    effectart = "Shenqi_N_Bangqiugun.blp",
    test = "        "
  },
  {
    name = "礼奈的柴刀",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "近战伤害效果", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        info.damage = info.damage * 1.05
      end)
      local add = 0
      ac.loop(3000, function()
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * -add)
        if u:hasdata("神器判定-诗音的电击器") and u:hasdata("神器判定-悟史的棒球棍") then
          add = 0.11
        else
          add = 0
        end
        ChangeValue(DamageSystem_EndSh, sy, 0.1 * add)
      end)
    end,
    effectname = "|cFFFF0000礼奈的柴刀|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFF0000提升5%近战伤害(独立)\n同时拥有[诗音的电击器]和[悟史的棒球棍]时:\n【获得雏见泽综合症:提升1.1%终结伤害】|r",
    effectart = "Shenqi_N_Linaichaidao.blp",
    test = "        "
  },
  {
    name = "诗音的电击器",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "过波时效果", function(args)
        ChangeValue(DamageSystem_Shjc, sy, 0.01)
      end)
    end,
    effectname = "|cFFFF0000诗音的电击器|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFF0000过波时提升1%伤害加成|r",
    effectart = "Shenqi_N_Dianjiqi.blp",
    test = "        "
  },
  {
    name = "团子大家族",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      Count_Tuanzidajiazu = Count_Tuanzidajiazu + 1
      u:changedata("同奏变异补正", 50)
      u:changedata("效果增强-同奏", 0.2)
      ac.loop(60000, function()
        local add = 0.5 * TONGZOU_Count + 2 * PlayerCount * Count_Tuanzidajiazu
        u:addrandomstats(add)
        u:sendmessage("|cFFDBB49C[团子大家族]提升" .. add .. "点属性|r")
      end)
    end,
    effectname = "|cFFDAB39B团子大家族|r",
    effecttext = "|cFF33FF33普通|r\n|cFFDAB39B提升20%同奏效果增强\n提升50%同奏补正\n每60秒提升[全队同奏变异数量*0.5+2*游戏人数*该神器拥有人数]点属性|r\n|cFF949596团子！团子！团子！团子！团子！|r",
    effectart = "Shenqi_N_Tuanzi.blp",
    test = "        "
  },
  {
    name = "铜制鳞片",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "受伤后效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        if args.damage > 10 then
          local txsh = 5000 * u:getlevel()
          DamageUnit({
            bj = "铜制鳞片反伤",
            unit = tg.handle,
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
      end)
    end,
    effectname = "|cFFFFFF33铜制鳞片|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFFFF33受伤时对伤害来源附带[5000*等级]物理伤害|r",
    effectart = "Shenqi_N_42.blp",
    test = "        "
  },
  {
    name = "发条靴",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
    end,
    effectname = "|cFF00CC66发条靴|r",
    effecttext = "|cFF33FF33普通|r\n|cFF00CC66对单位伤害低于1%(0.25%/0.1%)时,至少造成1%(0.25%/0.1%)伤害(不会超过原始伤害值),如果是附伤只有10%效果\n伤害被闪避/被免疫时仍造成30%伤害\n只造成1点伤害的情况至低造成3点伤害|r",
    effectart = "Shenqi_N_43.blp",
    test = "        "
  },
  {
    name = "小宝箱",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "过波时效果", function(args)
        if GuoboAllSet[Stage] == "空间站" or GuoboAllSet[Stage] == "乐土商店" then
          u:sendmessage("|cFF66FFFF小宝箱-获取遗物|r")
          local pools = {
            Guoboyiwu_Normal
          }
          local poolsstr = "普通过波遗物"
          u:setdata("伊丝-过波奖励获取变异")
          local bind = herogetvar(u.handle, pools, poolsstr, "只返回变异")
          u:deldata("伊丝-过波奖励获取变异")
          if bind then
            local result = herogetvar(u.handle, pools, poolsstr, bind.name)
            if result == "失败" then
              u:sendmessage("|cFFCC0000获取失败|r")
            elseif bind then
              yiwuhuoqu(u, bind)
            end
          else
            u:sendmessage("|cFFCC0000获取失败|r")
          end
        end
      end)
    end,
    effectname = "|cFF66FFFF小宝箱|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFF0033进入事件或行商轮时获得一个随机普通遗物|r",
    effectart = "Shenqi_N_45.blp",
    test = "    "
  },
  {
    name = "金刚杵",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      ChangeValue(DamageSystem_EndSh, sy, 0.009)
    end,
    effectname = "|cFFFFFF00金刚杵|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFFFF00提升0.9%终结伤害|r",
    effectart = "Shenqi_N_46.blp",
    test = "    "
  },
  {
    name = "磨刀石",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:changedata("近战机体-基础伤害提升", 5000)
    end,
    effectname = "|cFFFF0033磨|r|cFFFF1A40刀|r|cFFFF334C石|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFFFF00提升[10%+5000]近战机体伤害\n近战武器提升10%伤害加成|r",
    effectart = "Shenqi_N_47.blp",
    test = "    "
  },
  {
    name = "灯笼",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
    end,
    effectname = "|cFF66FF66灯笼|r",
    effecttext = "|cFF33FF33普通|r\n|cFF66FF66BOSS战结束时,随机获得一个传奇并提升对应神力承载上限|r",
    effectart = "Shenqi_N_48.blp",
    test = "    "
  },
  {
    name = "御守",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:changedata("御守-剩余次数", 2)
    end,
    effectname = "|cFFFF0066御守|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFF0066抵挡常规诅咒,疾病获取与高塔诅咒获取(仍然有可能获取相同疾病/诅咒)\n生效2次|r",
    effectart = "Shenqi_N_49.blp",
    test = "    "
  },
  {
    name = "意外光滑的石头",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:changedata("闪避值", 25)
      ChangeValue(HeroMenu_Sbxs, sy, 0.1)
    end,
    effectname = "|cFF669999意外光滑的石头|r",
    effecttext = "|cFF33FF33普通|r\n|cFF669999提升25闪避值\n提升0.1闪避系数|r",
    effectart = "Shenqi_N_50.blp",
    test = "    "
  },
  {
    name = "奥利哈钢",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      local dt = 0
      ac.loop(1000, function()
        if u:isalive() then
          dt = dt + 1
          if 60 <= dt then
            dt = 0
            local dsh, hdz = Hdzflash(u)
            if hdz == 0 then
              u:sendmessage("|cFF66FF00[奥利哈钢]护盾获取|r")
              hdzlinshiadd(u, 500 * u:getlevel())
            end
          end
        end
      end)
    end,
    effectname = "|cFF66FF00奥利哈钢|r",
    effecttext = "|cFF33FF33普通|r\n|cFF66FF00每存活60秒如果没有护盾则获得[500*等级]护盾值|r",
    effectart = "Shenqi_N_51.blp",
    test = "    "
  },
  {
    name = "皇家枕头",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      local cs = 0
      ac.loop(1000, function()
        if u:getdata("战斗时间") == 0 then
          cs = cs + 1
          local max = 30
          if Keyan_Weizhanshike then
            max = max * Weizhanxishu
          end
          if max <= cs then
            cs = 0
            u:sendmessage("|cFFFF0000[皇家枕头]完全恢复|r")
            u:sethp(100, true)
            u:setmp(100, true)
            Hero_Tili[sy] = Hero_Tili_Max[sy]
          end
        else
          cs = 0
        end
      end)
    end,
    effectname = "|cFFFF0000皇家枕头|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFF0000脱战时,每30秒恢复所有状态|r",
    effectart = "Shenqi_N_52.blp",
    test = "    "
  },
  {
    name = "微笑面具",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
    end,
    effectname = "|cFF33CCFF微笑面具|r",
    effecttext = "|cFF33FF33普通|r\n|cFF33CCFF行商处个人打折商品提升至6件|r",
    effectart = "Shenqi_N_53.blp",
    test = "        "
  },
  {
    name = "草莓",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:changemaxhp(0.07 * u:getmaxhp())
      ChangeValue(Hero_Tili_Max, sy, 7)
      u:changedata("全属性增幅", 0.035)
    end,
    effectname = "|cFFFF6699草莓|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFF6699获取时提升7%当前生命上限\n提升7点体力上限\n提升3.5%全属性|r",
    effectart = "Shenqi_N_54.blp",
    test = "    "
  },
  {
    name = "餐券",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
    end,
    effectname = "|cFF00FFFF餐券|r",
    effecttext = "|cFF33FF33普通|r\n|cFF00FFFF往世乐土或行商处消费时获得一张兑换券|r",
    effectart = "Shenqi_N_55.blp",
    test = "    "
  },
  {
    name = "双节棍",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "直接伤害特效", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        u:changedata("双节棍-累积次数", 1)
        if u:getdata("双节棍-累积次数") >= 10 then
          u:setdata("双节棍-累积次数", -1)
          DamageUnit({
            bj = "双节棍附伤",
            unit = tg.handle,
            source = u.handle,
            damage = info.yssh,
            level = 1,
            type = info.damagetype,
            isvest = false,
            isattack = false,
            isnoarmor = false,
            element = "无"
          })
        end
      end)
    end,
    effectname = "|cFFCC3333双节棍|r",
    effecttext = "|cFF33FF33普通|r\n|cFFCC3333每10次直接伤害,下一次直接伤害额外造成1次直接伤害|r",
    effectart = "Shenqi_N_56.blp",
    test = "    "
  },
  {
    name = "昆虫标本",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        if tg:iselite() and GetRandom100(25) then
          local a = GetRandomReal(0, 100)
          local wplx
          if a <= 36 then
            wplx = "I02F"
          elseif a <= 72 then
            wplx = "I02H"
          elseif a <= 81 then
            wplx = "I02E"
          elseif a <= 90 then
            wplx = "I011"
          else
            wplx = "I030"
          end
          local x, y = tg:getxy()
          CreateItemLua(wplx, x, y)
        end
      end)
    end,
    effectname = "|cFFCC6666昆虫标本|r",
    effecttext = "|cFF33FF33普通|r\n|cFFCC6666击杀精英怪25%时掉落一瓶随机药剂|r",
    effectart = "Shenqi_N_57.blp",
    test = "    "
  },
  {
    name = "钢笔尖",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "怪物减伤计算", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not info.iscrit then
          info.damage = info.damage * 1.2
        end
      end)
    end,
    effectname = "|cFFFFFFCC钢笔尖|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFFFFCC伤害未暴击时,伤害提升20%|r",
    effectart = "Shenqi_N_58.blp",
    test = "    "
  },
  {
    name = "赤牛",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "直接伤害变更", function(args)
        local u = args.u
        local tg = args.tg
        local info = args.damageinfo
        if not tg:hasdata("红牛-已触发" .. sy) then
          tg:setdata("红牛-已触发" .. sy)
          info.damage = info.damage * 1.44
        end
      end)
    end,
    effectname = "|cFFFF0000赤牛|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFF0000对敌人造成的第一次伤害提升44%|r",
    effectart = "Shenqi_N_59.blp",
    test = "    "
  },
  {
    name = "战纹涂料",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      local ctg = countainmaxvar(u).var
      u:setdata("战纹涂料-主变异", ctg)
      for index, value in ipairs(ctg) do
        u:changedata(value .. "变异补正", 10000)
      end
      u:changedata("战纹涂料-剩余次数", 2)
    end,
    effectname = "|cFF6699FF战纹|r|cFFFF3333涂料|r",
    effecttext = "|cFF33FF33普通|r\n|cFF6699FF巨幅提升获取时的主变异相关补正|r\n|cFFFF3333获得2个变异后失效|r",
    effectart = "Shenqi_N_60.blp",
    test = "    "
  },
  {
    name = "玩具扑翼飞机",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
    end,
    effectname = "|cFFFFFFFF玩具扑翼飞机|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFFFFFF使用药水时提升[0.05%+20]生命上限|r",
    effectart = "Shenqi_N_61.blp",
    test = "    "
  },
  {
    name = "佛珠手链",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      local xy = 0
      ac.loop(3000, function()
        u:changedata("幸运", -xy)
        xy = 2 * u:getdata("残机剩余数量")
        u:changedata("幸运", xy)
      end)
    end,
    effectname = "|cFF6699FF佛珠手链|r",
    effecttext = "|cFF33FF33普通|r\n|cFF6699FF每拥有一个残机提升2点幸运|r",
    effectart = "Shenqi_N_62.blp",
    test = "    "
  },
  {
    name = "净化石",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:changedata("净化石-剩余次数", 1)
    end,
    effectname = "|cFF33FFFF净化石|r",
    effecttext = "|cFF33FF33普通|r\n|cFF33FFFF抵挡下一次任意诅咒|r",
    effectart = "Shenqi_N_64.blp",
    test = "    "
  },
  {
    name = "无尽的灵魂",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "杀敌效果", function(args)
        local tg = args.tg
        u:curetili(1)
        u:changemaxhp(1)
        if tg:isboss() then
          ChangeValue(Hero_Tili_Max, sy, 1)
        end
      end)
    end,
    effectname = "|cFFCC3399无尽的灵魂|r",
    effecttext = "|cFF33FF33普通|r\n|cFFCC3399杀敌时恢复1点体力值与1点生命上限\n杀死BOSS时提升1点体力上限|r",
    effectart = "Shenqi_N_65.blp",
    test = "    "
  },
  {
    name = "远古盾牌",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "进入战斗状态时", function(args)
        local u = args.u
        local add = 500 * Stage
        hdzlinshiadd(u, add)
      end)
    end,
    effectname = "|cFFCCCCFF远古盾牌|r",
    effecttext = "|cFF33FF33普通|r\n|cFFCCCCFF入战时获得[500*波数]临时护盾值|r",
    effectart = "Shenqi_N_66.blp",
    test = "    "
  },
  {
    name = "古老的怀表",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      ChangeValue(HeroMenu_ExtraMoveSpeed, sy, 100)
    end,
    effectname = "|cFFCC99FF古老的怀表|r",
    effecttext = "|cFF33FF33普通|r\n|cFFCC99FF提升100额外移速|r",
    effectart = "Shenqi_N_67.blp",
    test = "    "
  },
  {
    name = "闪光石",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
    end,
    effectname = "|cFFFFFF00闪光石|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFFFF00降低90%时限伤害|r",
    effectart = "Shenqi_N_68.blp",
    test = "    "
  },
  {
    name = "魔方",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "终结伤害计算效果", function(args)
        local tg = args.tg
        local u = args.u
        local info = args.damageinfo
        local b = false
        if tg:hasbuff("睡眠") or tg:hasbuff("石化") or tg:hasbuff("缠绕") or tg:hasbuff("僵直") or tg:hasbuff("混乱") or tg:hasbuff("麻痹") or tg:hasbuff("暂停") or tg:hasbuff("冰冻") or tg:hasbuff("燃烧") then
          info.end2 = info.end2 + 0.16
        end
      end)
    end,
    effectname = "|cFF660033魔方|r",
    effecttext = "|cFF33FF33普通|r\n|cFF660033对拥有负面状态的单位提升16%伤害|r",
    effectart = "Shenqi_N_69.blp",
    test = "    "
  },
  {
    name = "古茶具套餐",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      local hp = 0
      local tl = 0
      ac.loop(1000, function()
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, -hp)
        ChangeValue(Hero_Tili_Huifu, sy, -tl)
        if u:getdata("战斗时间") == 0 then
          hp = 3
          tl = 1
        else
          hp = 0
          tl = 0
        end
        ChangeValue(HeroMenu_HpChange_MaxHp, sy, hp)
        ChangeValue(Hero_Tili_Huifu, sy, tl)
      end)
    end,
    effectname = "|cFF009999古茶具套餐|r",
    effecttext = "|cFF33FF33普通|r\n|cFF009999脱战时提升3%生命恢复与1体力恢复|r",
    effectart = "Shenqi_N_70.blp",
    test = "    "
  },
  {
    name = "孙子兵法",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:sendmessage("|cFFCCFF33[孙子兵法]等级提升|r")
      u:addlevel(1)
      ChangeValue(DamageSystem_EndSh, sy, 0.002)
      u:addstexiao(var.name, "过波时效果", function(args)
        u:sendmessage("|cFFCCFF33[孙子兵法]等级提升|r")
        u:addlevel(1)
        ChangeValue(DamageSystem_EndSh, sy, 0.001)
      end)
    end,
    effectname = "|cFFCCFF33孙子兵法|r",
    effecttext = "|cFF33FF33普通|r\n|cFFCCFF33获取或过波时提升1级,0.1%终结伤害|r",
    effectart = "Shenqi_N_71.blp",
    test = "    "
  },
  {
    name = "锚",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "过波时效果", function(args)
        u:sendmessage("|cFF333366锚-护盾获取|r")
        local add = 2000 * Stage
        hdzlinshiadd(u, add)
      end)
    end,
    effectname = "|cFF9999CC锚|r",
    effecttext = "|cFF33FF33普通|r\n|cFF9999CC每波开始时获得[2000*波数]临时护盾值|r",
    effectart = "Shenqi_N_72.blp",
    test = "    "
  },
  {
    name = "开心小花",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "过波时效果", function(args)
        u:changedata("开心小花-计数", 1)
        if u:getdata("开心小花-计数") >= 3 then
          u:sendmessage("|cFF66FF66开心小花-神力承载上限提升|r")
          u:changedata("开心小花-计数", -3)
          u:changedata("系统-神力承载上限", 1)
        end
      end)
    end,
    effectname = "|cFF66FF66开心小花|r",
    effecttext = "|cFF33FF33普通|r\n|cFF66FF66每经过3个回合提升1神力承载上限|r",
    effectart = "Shenqi_N_73.blp",
    test = "    "
  },
  {
    name = "旋转弹膛",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      local add = 0
      local sy = u.ownerid
      return add
    end,
    condition = function(u)
      local b = true
      local sy = u.ownerid
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for index, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      ChangeValue(DamageSystem_Txsh, sy, 0.66)
    end,
    effectname = "|cFFFFCC00旋转弹膛|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFFCC00提升66%特效伤害|r",
    effectart = "Shenqi_N_74.blp",
    test = "    "
  },
  {
    name = "烫手山芋",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      return 0
    end,
    condition = function(u)
      return true
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for _, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:setdata("烫手山芋-爆炸立即", true)
      ChangeValue(Damage_Touzhiwu, sy, 1)
    end,
    effectname = "|cFF996600烫手山芋|r",
    effecttext = "|cFF33FF33普通|r\n|cFF996600提升100%投掷物伤害\n投掷物爆炸时间变为0|r",
    effectart = "Shenqi_N_Shanyu.blp",
    test = ""
  },
  {
    name = "染血的冠军腰带",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      return 0
    end,
    condition = function(u)
      local b = true
      if u:hasdata("神器判定-黑蜡烛") or u:hasdata("原质-王国获取中") then
        b = false
      end
      return b
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for _, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      ChangeValue(DamageSystem_EndSh, sy, 0.18)
      local sxsl = Relic.try_block_curse(u, 1, "城堡诅咒")
      if 0 < sxsl then
        u:setdata("染血的冠军腰带-诅咒")
      end
    end,
    effectname = "|cFFFF0000染血的冠军腰带|r",
    effecttext = "|cFF00FFFF普通|r\n|cFFFF0033提高18%终结伤害|r\n|cFF9933CC城堡诅咒：最大生命值降低30%（动态）|r",
    effectart = "Shenqi_N_Ranxuedeyaodai.blp",
    test = ""
  },
  {
    name = "分裂银币",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      return 0
    end,
    condition = function(u)
      return true
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for _, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      local current = u:getgold()
      local bonus = math.floor(current * 0.5)
      u:addgold(bonus)
      u:sendmessage("|cFF0099CC[分裂银币]|r 使你获得了额外积分：" .. bonus)
    end,
    effectname = "|cFF0099CC分裂银币|r",
    effecttext = "|cFF33FF33普通|r\n|cFF0099CC一次性获得你当前积分50%的积分|r",
    effectart = "Shenqi_N_Fenlieyinbi.blp",
    test = ""
  },
  {
    name = "海绵王",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      return 0
    end,
    condition = function(u)
      return true
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for _, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "过波时效果", function(args)
        local u = args.u
        ChangeValue(Correction_MHp, sy, 0.005000000000000001)
        u:sendmessage("|cFFFF9933[海绵王]提升生命上限")
      end)
    end,
    effectname = "|cFFFF9933海绵王|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFF9933过波时提升0.5%生命上限|r",
    effectart = "Shenqi_N_Haimianwang.blp",
    test = ""
  },
  {
    name = "神圣屏障",
    weight = 100,
    key = {},
    unique = false,
    addweight = function(u, var)
      return 0
    end,
    condition = function(u)
      return true
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for _, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:addstexiao(var.name, "过波时效果", function(args)
        if u:hasdata("神圣屏障-已触发") then
          u:sendmessage("|cFFFFCC00[神圣屏障]|r已刷新")
          u:deldata("神圣屏障-已触发")
        end
      end)
      u:addstexiao(var.name, "决死效果", function(args)
        if args.dt ~= false and u:isalive() and not u:hasdata("神圣屏障-已触发") and args.damage >= u:gethp() then
          args.dt = false
          u:sethp(1)
          u:setdata("神圣屏障-已触发")
          u:effectadd("Abilities\\Spells\\Human\\DivineShield\\DivineShieldTarget.mdl", "origin")
          u:sendmessage("|cFFFFCC00[神圣屏障]|r免疫致死伤害！")
        end
      end)
    end,
    effectname = "|cFFFFCC00神圣屏障|r",
    effecttext = "|cFF33FF33普通|r\n|cFFFFCC00每回合免疫一次致死伤害|r",
    effectart = "Shenqi_N_Shenshengpingzhang.blp",
    test = ""
  },
  {
    name = "热水壶",
    weight = 500,
    key = {},
    unique = false,
    addweight = function(u, var)
      return 0
    end,
    condition = function(u)
      return Stage == 1
    end,
    effect = function(u, var)
      local sy = u.ownerid
      u:setdata("神器判定-" .. var.name)
      if var.key then
        for _, value in ipairs(var.key) do
          u:changedata(value .. "变异数量", 1)
        end
      end
      u:changedata("残机剩余数量", 1)
      u:setusedfodd(u:getdata("残机剩余数量"))
      u:addwood(100)
    end,
    effectname = "|cFF6666FF热水壶|r",
    effecttext = "|cFF33FF33普通|r\n|cFF6666FF残机+1，追忆值+100|r\n|cFF949596“曾经创下了14秒就烧开水的记录”|r",
    effectart = "Shenqi_N_Reshuihu.blp",
    test = ""
  }
}
